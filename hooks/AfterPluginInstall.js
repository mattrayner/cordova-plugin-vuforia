#!/usr/bin/env node
'use strict';

module.exports = function(context) {

  let cwd = process.cwd();
  let fs = require('fs');
  let path = require('path');
  let hookData = require('./hook_data.json');

  // Using the ConfigParser from Cordova to get the project name.
  let cordova_util = context.requireCordovaModule("cordova-lib/src/cordova/util");
  let ConfigParser = context.requireCordovaModule('cordova-common').ConfigParser;
  let projectRoot = cordova_util.isCordova();
  let cordovaConfig = new ConfigParser(cordova_util.projectConfig(projectRoot));
  let projectName =  cordovaConfig.doc.findtext('./name');

  // Modify the xcconfig build path and pass the resulting file path to the addHeaderSearchPaths function.
  const modifyBuildConfig = function() {
    let xcConfigBuildFilePath = path.join(cwd, 'platforms', 'ios', 'cordova', 'build.xcconfig');

    try {
      let xcConfigBuildFileExists = fs.accessSync(xcConfigBuildFilePath);
    }
    catch(e) {
      console.log('Could not locate build.xcconfig, you will need to set HEADER_SEARCH_PATHS manually');
      return;
    }

    console.log(`xcConfigBuildFilePath: ${xcConfigBuildFilePath}`);

    addHeaderSearchPaths(xcConfigBuildFilePath);
  };

  // Read the build config, add the correct Header Search Paths to the config before calling modifyAppDelegate.
  const addHeaderSearchPaths = function(xcConfigBuildFilePath) {
    let lines = fs.readFileSync(xcConfigBuildFilePath, 'utf8').split('\n');
    let paths = hookData.headerPaths;

    let headerSearchPathLineNumber;

    lines.forEach((l, i) => {
      if (l.indexOf('HEADER_SEARCH_PATHS') > -1) {
        headerSearchPathLineNumber = i;
      }
    });

    if (headerSearchPathLineNumber) {
      for(let actualPath of paths) {
        if (lines[headerSearchPathLineNumber].indexOf(actualPath) == -1) {
          lines[headerSearchPathLineNumber] += ` ${actualPath}`;
          console.log(`${actualPath} was added to the search paths`);
        }
        else {
          console.log(`${actualPath} was already setup in build.xcconfig`);
        }
      }
    }
    else {
      lines[lines.length - 1] = 'HEADER_SEARCH_PATHS = ';
      for(let actualPath of paths) {
        lines[lines.length - 1] += actualPath;
      }
    }

    let newConfig = lines.join('\n');

    fs.writeFile(xcConfigBuildFilePath, newConfig, function (err) {
      if (err) {
        console.log(`Error updating build.xcconfig: ${err}`);
        return;
      }
      console.log('Successfully updated HEADER_SEARCH_PATHS in build.xcconfig');
    });

    modifyAppDelegate();
  };

  // Finally, modify the AppDelegate file by searching for and replacing the old method with the newer required one.
  const modifyAppDelegate = function() {
    console.log('Attempting to modify the AppDelegate.m for iOS');

    let appDelegateFilePath = path.join(cwd, 'platforms', 'ios', projectName, 'Classes', 'AppDelegate.m');

    // Ugly file modification but it does the job.
    let oldMethod = hookData.methodToReplace;
    let newMethod = hookData.replaceMethod;

    try {
      let appDelegateFileExists = fs.accessSync(appDelegateFilePath);
    }
    catch(e) {
      console.log('Could not locate AppDelegate.m, you will need to modify it manually');
      return;
    }

    let appDelegateContent = fs.readFileSync(appDelegateFilePath, 'utf8');

    if(appDelegateContent.indexOf(oldMethod) > -1) {
      let newAppDelegateContent = appDelegateContent.replace(oldMethod, newMethod);

      fs.writeFile(appDelegateFilePath, newAppDelegateContent, function (err) {
        if (err) {
          console.log(`Error updating AppDelegate.m! err: ${err}`);
          return;
        }
        console.log('Successfully updated the AppDelegate.m file with the right code');
      });
    }
    else {
      if(appDelegateContent.indexOf(newMethod) > -1) {
        console.log('AppDelegate.m has already been modified');
      }
      else {
        console.log('Did not find the code to modify');
      }
    }
  };

  modifyBuildConfig();
};
