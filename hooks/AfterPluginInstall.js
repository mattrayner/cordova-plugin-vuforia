#!/usr/bin/env node
'use strict';

module.exports = function(context) {
    let cwd = process.cwd();
    let fs = require('fs');
    let path = require('path');

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
    let path1 = '"../../plugins/cordova-plugin-vuforia/build/include"';
    let path2 = '"$(OBJROOT)/UninstalledProducts/$(PLATFORM_NAME)/include"';


    let headerSearchPathLineNumber;

    lines.forEach((l, i) => {
      if (l.indexOf('HEADER_SEARCH_PATHS') > -1) {
        headerSearchPathLineNumber = i;
      }
    });

    if (headerSearchPathLineNumber) {

      if (lines[headerSearchPathLineNumber].indexOf(path1) == -1) {
        lines[headerSearchPathLineNumber] += ' ' + path1;
        console.log(path1 + ' was added to the search paths');
      }else{
        console.log(path1 + ' was already setup in build.xcconfig');
      }

      if (lines[headerSearchPathLineNumber].indexOf(path2) < 0) {
        lines[headerSearchPathLineNumber] += ' ' + path2;
        console.log(path2 + ' was added to the search paths');
      }else{
        console.log(path2 + ' was already setup in build.xcconfig');
      }
    } else {
      lines[lines.length - 1] = 'HEADER_SEARCH_PATHS = ' + path1 + ' ' + path2;
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
    let oldMethod = 'self.viewController = [[MainViewController alloc] init];\n    return [super application:application didFinishLaunchingWithOptions:launchOptions];';

    let newMethod = 'CGRect screenBounds = [[UIScreen mainScreen] bounds];\n#if __has_feature(objc_arc)\nself.window = [[UIWindow alloc] initWithFrame:screenBounds];\n#else\nself.window = [[[UIWindow alloc] initWithFrame:screenBounds] autorelease];\n#endif\nself.window.autoresizesSubviews = YES;\n#if __has_feature(objc_arc)\nself.viewController = [[MainViewController alloc] init];\n#else\nself.viewController = [[[MainViewController alloc] init] autorelease];\n#endif\nUINavigationController * nc = [[UINavigationController alloc]initWithRootViewController:self.viewController];\n[nc setNavigationBarHidden:YES animated:NO];\nself.window.rootViewController = nc;\n[self.window makeKeyAndVisible];\nreturn YES;\n';

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
            console.log('Successfully updated the AppDelegate.m file with the right code :', newMethod);
        });
    }else{
        console.warn("Didn't find the code to modify");
    }
}
