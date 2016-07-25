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


};
