#!/usr/bin/env node
'use strict';

module.exports = function(context) {
    let cwd = process.cwd();
    let fs = require('fs');
    let path = require('path');
    let xcodeInfos = require('./xcode_infos.json');

    // Using the ConfigParser from Cordova to get the project's name.
    let cordova_util = context.requireCordovaModule("cordova-lib/src/cordova/util");
    let ConfigParser = context.requireCordovaModule('cordova-common').ConfigParser;
    let projectRoot = cordova_util.isCordova();
    let cordovaConfig = new ConfigParser(cordova_util.projectConfig(projectRoot));
    let projectName =  cordovaConfig.doc.findtext('./name');

    console.log('Vuforia AfterPluginInstall.js, attempting to modify build.xcconfig');

    let xcConfigBuildFilePath = path.join(cwd, 'platforms', 'ios', 'cordova', 'build.xcconfig');

    try {
      let xcConfigBuildFileExists = fs.accessSync(xcConfigBuildFilePath);
    } catch(e) {
      console.log('Could not locate build.xcconfig, you will need to set HEADER_SEARCH_PATHS manually.');
      return;
    }

    console.log('xcConfigBuildFilePath: ', xcConfigBuildFilePath);

    let lines = fs.readFileSync(xcConfigBuildFilePath, 'utf8').split('\n');
    let paths = xcodeInfos.headerPaths;
    // = '"../../plugins/cordova-plugin-vuforia/build/include"';
    // let path2 = '"$(OBJROOT)/UninstalledProducts/$(PLATFORM_NAME)/include"';


    let headerSearchPathLineNumber;

    lines.forEach((l, i) => {
      if (l.indexOf('HEADER_SEARCH_PATHS') > -1) {
        headerSearchPathLineNumber = i;
      }
    });

    if (headerSearchPathLineNumber) {
        for(let actualPath of paths){
            if (lines[headerSearchPathLineNumber].indexOf(actualPath) == -1) {
                lines[headerSearchPathLineNumber] += ' ' + actualPath;
                console.log(actualPath + ' was added to the search paths');
              }else{
                console.log(actualPath + ' was already setup in build.xcconfig');
              }
        }
    } else {
        lines[lines.length - 1] = 'HEADER_SEARCH_PATHS = '
        for(let actualPath of paths){
            lines[lines.length - 1] += actualPath;
        }
    }

    let newConfig = lines.join('\n');

    fs.writeFile(xcConfigBuildFilePath, newConfig, function (err) {
      if (err) {
        console.log('error updating build.xcconfig, err: ', err);
        return;
      }
      console.log('Successfully updated HEADER_SEARCH_PATHS in build.xcconfig');
    });


    console.log("Attempt to modify the AppDelegate.m for iOs");

    let appDelegateFilePath = path.join(cwd, 'platforms', 'ios', projectName, 'Classes', 'AppDelegate.m');

    // Ugly file modification but does the job.
    let oldMethod = xcodeInfos.methodToReplace;

    let newMethod = xcodeInfos.replaceMethod;

    try {
      let appDelegateFileExists = fs.accessSync(appDelegateFilePath);
    } catch(e) {
      console.log('Could not locate AppDelegate.m, you will need to modify it manually.');
      return;
    }

    let appDelegateContent = fs.readFileSync(appDelegateFilePath, 'utf8');
    if(appDelegateContent.indexOf(oldMethod) > -1){
        let newAppDelegateContent = appDelegateContent.replace(oldMethod, newMethod);
        fs.writeFile(appDelegateFilePath, newAppDelegateContent, function (err) {
              if (err) {
                console.log('error updating AppDelegate.m, err: ', err);
                return;
            }
            console.log('Successfully updated the AppDelegate.m file with the right code.');
        });
    }else{
        if(appDelegateContent.indexOf(newMethod) > -1){
            console.log("AppDelegate.m was already modified");
        }else{
            console.log("Didn't find the code to modify");
        }
    }
}
