#!/usr/bin/env node
'use strict';

module.exports = function(context) {
    let cwd = process.cwd();
    let fs = require('fs');
    let path = require('path');
    let hookData = require('./hook_data.json');

    // Using the ConfigParser from Cordova to get the project's name.
    let cordova_util = context.requireCordovaModule("cordova-lib/src/cordova/util");
    let ConfigParser = context.requireCordovaModule('cordova-common').ConfigParser;
    let projectRoot = cordova_util.isCordova();
    let cordovaConfig = new ConfigParser(cordova_util.projectConfig(projectRoot));
    let projectName =  cordovaConfig.doc.findtext('./name');

    let xcConfigBuildFilePath = path.join(cwd, 'platforms', 'ios', 'cordova', 'build.xcconfig');

    console.log('Vuforia BeforePluginUninstall.js, attempting to modify build.xcconfig');

    try {
      let xcConfigBuildFileExists = fs.accessSync(xcConfigBuildFilePath);
    }
    catch(e) {
      console.log('Could not locate build.xcconfig.');
      return;
    }

    console.log('xcConfigBuildFilePath: ', xcConfigBuildFilePath);

    let lines = fs.readFileSync(xcConfigBuildFilePath, 'utf8').split('\n');

    let headerSearchPathLineNumber;
    lines.forEach((l, i) => {
      if (l.indexOf('HEADER_SEARCH_PATHS') > -1) {
        headerSearchPathLineNumber = i;
      }
    });

    if (!headerSearchPathLineNumber) {
      console.log('build.xcconfig does not have HEADER_SEARCH_PATHS');
      return;
    }


    let paths = hookData.headerPaths;

    for(let actualPath of paths){
        if (lines[headerSearchPathLineNumber].indexOf(actualPath) === -1) {
          console.log('build.xcconfig does not have header path for Instagram Assets Picker');
          continue;
        }
        let line = lines[headerSearchPathLineNumber];
        lines[headerSearchPathLineNumber] = line.replace(' '+actualPath, '');
    }
    let newConfig = lines.join('\n');

    fs.writeFile(xcConfigBuildFilePath, newConfig, function (err) {
      if (err) {
        console.log('error updating build.xcconfig, err: ', err);
        return;
      }
      console.log('successfully updated HEADER_SEARCH_PATHS in build.xcconfig');
    });


    console.log("Attempt to modify the AppDelegate.m for iOs");

    let appDelegateFilePath = path.join(cwd, 'platforms', 'ios', projectName, 'Classes', 'AppDelegate.m');

    // Ugly file modification but does the job.
    let oldMethod = hookData.methodToReplace;

    let newMethod = hookData.replaceMethod;

    try {
      let appDelegateFileExists = fs.accessSync(appDelegateFilePath);
    } catch(e) {
      console.log('Could not locate AppDelegate.m, you will need to modify it manually.');
      return;
    }

    let appDelegateContent = fs.readFileSync(appDelegateFilePath, 'utf8');
    if(appDelegateContent.indexOf(newMethod) > -1){
        let newAppDelegateContent = appDelegateContent.replace(newMethod, oldMethod);
        fs.writeFile(appDelegateFilePath, newAppDelegateContent, function (err) {
              if (err) {
                console.log('error updating AppDelegate.m, err: ', err);
                return;
            }
            console.log('Successfully updated the AppDelegate.m file with the old code.');
        });
    }else{
        if(appDelegateContent.indexOf(oldMethod) > -1){
            console.log("AppDelegate.m has not been modified");
        }else{
            console.log("Didn't find the code to modify");
        }
    }
};
