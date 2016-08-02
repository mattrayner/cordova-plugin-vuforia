# ![Cordova-Plugin-Vuforia][logo]
Cordova-Plugin-Vuforia is a [Cordova][cordova] plugin that uses [Vuforia][vuforia] to perform image recognition.

You can see a live example in the [Peugeot 208][peugeot] app on iOS and Android, and an open source example in the [cordova-vuforia-example][example-repo] repo.

[![NPM Version][shield-npm]][info-npm]
[![Supported Cordova Versions][shield-cordova]][info-npm]
[![Build Status][shield-travis]][info-travis]
[![Bithound Score][shield-bithound]][info-bithound]
[![License][shield-license]][info-license]


### Contents
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Supported Platforms](#supported-platforms)
- [Requirements](#requirements)
  - [Dependencies](#dependencies)
- [Getting Started](#getting-started)
  - [Plugin Installation](#plugin-installation)
  - [JavaScript](#javascript)
    - [`startVuforia` - Start your Vuforia session](#startvuforia---start-your-vuforia-session)
      - [`options` object](#options-object)
        - [Examples](#examples)
      - [Success callback `data` API](#success-callback-data-api)
    - [`stopVuforia` - Stop your Vuforia session](#stopvuforia---stop-your-vuforia-session)
    - [`stopVuforiaTrackers` - Stop Vuforia image trackers](#stopvuforiatrackers---stop-vuforia-image-trackers)
    - [`startVuforiaTrackers` - Start Vuforia image trackers](#startvuforiatrackers---start-vuforia-image-trackers)
    - [`updateVuforiaTargets` - Update the list of targets Vuforia is searching for](#updatevuforiatargets---update-the-list-of-targets-vuforia-is-searching-for)
  - [Using your own data](#using-your-own-data)
    - [`www/targets/`](#wwwtargets)
    - [JavaScript](#javascript-1)
      - [`startVuforia(...)`](#startvuforia)
    - [`config.xml`](#configxml)
- [Contributing](#contributing)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Supported Platforms
Android (Minimum 4), iOS (Minimum 8)


## Requirements
> **NOTE:** You will require an Android or iOS device for development and testing. Cordova-Plugin-Vuforia requires hardware and software support that is not present in either the iOS or Android simulators.

Cordova-Plugin-Vuforia requires the following:
* [npm][npm]
* [Cordova 6.*][cordova] - 6.* is required as of v2.1 of this plugin, it adds support for Android 6 (Marshmellow) and iOS 9.
  * If you haven't yet installed the Cordova CLI, grab the latest version by following [these steps][install-cordova].
  * If you've already got a project running with an older version of Cordova, [see here][updating-cordova] for instructions on how to update your project's Cordova version.
  * Or if you want to upgrade to the latest version on a platform-by-platform basis, see either [upgrading to cordova-ios 4][upgrading-ios] or [upgrading to cordova-android 5][upgrading-android].

### Dependencies
At present there is one major dependency for Cordova-Plugin-Vuforia:
* [Cordova-Plugin-Vuforia-SDK][cordova-plugin-vuforia-sdk] - This plugin is used to inject the Vuforia SDK into our Cordova applications


## Getting Started
### Plugin Installation
```bash
cordova plugin add cordova-plugin-vuforia
```


### JavaScript
Cordova-Plugin-Vuforia comes with the following JavaScript methods:

Method | Description
--- | ---
[`startVuforia`][start-vuforia-doc-link] | **Begin a Vuforia session** - Launch the camera and begin searching for images to recognise.
[`stopVuforia`][stop-vuforia-doc-link] | **Stop a Vuforia session** - Close the camera and return back to Cordova.
[`stopVuforiaTrackers`][stop-vuforia-trackers-doc-link] | **Stop the Vuforia tracking system** - Leave the Vuforia camera running, just stop searching for images.
[`startVuforiaTrackers`][start-vuforia-trackers-doc-link] | **Start the Vuforia tracking system** - Leave the Vuforia camera running and start searching for images again.
[`updateVuforiaTargets`][update-vuforia-targets-doc-link] | **Update Vuforia target list** - Update the list of images we are searching for, but leave the camera and Vuforia running.

#### `startVuforia` - Start your Vuforia session
From within your JavaScript file, add the following to launch the [Vuforia][vuforia] session.

```javascript
var options = {
  databaseXmlFile: 'PluginTest.xml',
  targetList: [ 'logo', 'iceland', 'canterbury-grass', 'brick-lane' ],
  overlayMessage: 'Point your camera at a test image...',
  vuforiaLicense: 'YOUR_VUFORIA_KEY'
};

navigator.VuforiaPlugin.startVuforia(
  options,
  function(data) {
    // To see exactly what `data` can return, see 'Success callback `data` API' within the plugin's documentation.
    console.log(data);
    
    if(data.status.imageFound) {
      alert("Image name: "+ data.result.imageName);
    }
    else if (data.status.manuallyClosed) {
      alert("User manually closed Vuforia by pressing back!");
    }
  },
  function(data) {
    alert("Error: " + data);
  }
);
```

> **NOTES:**
> * You will need to replace `YOUR_VUFORIA_KEY` with a valid license key for the plugin to launch correctly.
> * For testing you can use the `targets/PluginTest_Targets.pdf` file inside the plugin folder; it contains all four testing targets.

##### `options` object
The options object has a number of properties, some of which are required, and some which are not. Below if a full reference and some example options objects

Option | Required | Default Value | Description
--- | --- | --- | ---
`databaseXmlFile` | `true` | `null` | The Vuforia database file (.xml) with our target data inside.
`targetList` | `true` | `null` | An array of images we are going to search for within our database. For example you may have a database of 100 images, but only be interested in 5 right now.
`vuforiaLicense` | `true` | `null` | Your application's Vuforia license key.
`overlayMessage` | `false` | `null` | A piece of copy displayed as a helpful hint to users i.e. 'Point your camera at the orange target'. *Providing no message will hide the overlay entirely*
`showDevicesIcon` | `false` | `false` | Display a device icon within the overlay. This can be a helpful hint for users i.e. 'Scan any page with the device icon on it.' *By default, this is false (the icon is hidden)*
`showAndroidCloseButton` | `false` | `false` | Show a close icon on-screen on Android devices. This is helpful if your Android device's back button is hidden/disabled. *By default, this is false (no close button is shown on Android)*
`autostopOnImageFound` | `false` | `true` | Should Vuforia automatically return to Cordova when an image is found? This is helpful if you want to scan for multiple images without re-launching the plugin. *By default, this is true (when an image is found, Vuforia returns to Cordova)*

###### Examples
**Minumum required**
```javascript
var options = {
  databaseXmlFile: 'PluginTest.xml',
  targetList: [ 'logo', 'iceland', 'canterbury-grass', 'brick-lane' ],
  vuforiaLicense: 'YOUR_VUFORIA_KEY'
};
```

**Complete options**
```javascript
var options = {
  databaseXmlFile: 'PluginTest.xml',
  targetList: [ 'logo', 'iceland', 'canterbury-grass', 'brick-lane' ],
  vuforiaLicense: 'YOUR_VUFORIA_KEY',
  overlayMessage: 'Point your camera at a test image...',
  showDevicesIcon: true,
  showAndroidCloseButton: true,
  autostopOnImageFound: false
};
```


##### Success callback `data` API
`startVuforia` takes two callbacks - one for `success` and one for `faliure`. When `success` is called, a `data` object is passed to Cordova. This will be in one of the following formats:

**Image Found** - when an image has been successfully found, `data` returns:

```json
{
  "status": {
    "imageFound": true,
    "message": "Image found."
  },
  "result": {
    "imageName": "IMAGE_NAME"
  }
}
```

> **NOTE:** `imageName` will return the name of the image found by Vuforia. For example, with the above options objects, `brick-lane` would be sent when the brick-lane image was found.

**Manually Closed** - when a user has exited Vuforia via pressing the close/back button, `data` returns: 

```json
{
  "status": {
    "manuallyClosed": true,
    "message": "User manually closed the plugin."
  }
}
```

#### `stopVuforia` - Stop your Vuforia session
From within your JavaScript file, add the following to stop the [Vuforia][vuforia] session. `stopVuforia` takes two callbacks - one for `success` and one for `faliure`.

**Why?** - Well, you could pair this with a setTimeout to give users a certain amount of time to search for an image. Or you can pair it with the `autostopOnImageFound` option within `startVuforia` to have more granular control over when Vuforia actually stops.

```javascript
navigator.VuforiaPlugin.stopVuforia(
  function (data) {
    console.log(data);

    if (data.success == 'true') {
        alert('Stopped Vuforia');
    } else {
        alert('Couldn\'t stop Vuforia\n'+data.message);
    }
  },
  function (data) {
    console.log("Error: " + data);
  }
);
```

This script could be paired with a timer, or other method to trigger the session close.

> **NOTE:** You do not need to call `stopVuforia()` other than to force the session to end. If the user scans an image, or chooses to close the session themselves, the session will be automatically closed.


#### `stopVuforiaTrackers` - Stop Vuforia image trackers
From within your JavaScript file, add the following to stop the [Vuforia][vuforia] image trackers (but leave the camera running). `stopVuforiaTrackers` takes two callbacks - one for `success` and one for `faliure`.

**Why?** - Well, you may want to play a sound after an image rec, or have some kind of delay between recognitions.

```javascript
navigator.VuforiaPlugin.stopVuforiaTrackers(
  function (data) {
    console.log(data);
    
    alert('Stopped Vuforia Trackers');
  },
  function (data) {
    console.log("Error: " + data);
  }
);
```


#### `startVuforiaTrackers` - Start Vuforia image trackers
From within your JavaScript file, add the following to start the [Vuforia][vuforia] image trackers. This method only makes sense when called after `stopVuforiaTrackers`. `startVuforiaTrackers` takes two callbacks - one for `success` and one for `faliure`.

**Why?** - Well, you may want to play a sound after an image rec, or have some kind of delay between recognitions.

```javascript
navigator.VuforiaPlugin.startVuforiaTrackers(
  function (data) {
    console.log(data);
    
    alert('Started Vuforia Trackers');
  },
  function (data) {
    console.log("Error: " + data);
  }
);
```


#### `updateVuforiaTargets` - Update the list of targets Vuforia is searching for
From within your JavaScript file, add the following to update the list of images [Vuforia][vuforia] is searching for. `updateVuforiaTargets` takes three options, an array of images you want to scan for, a callback for `success` and a callback for `faliure`.

**Why?** - Well, you may want to change the images you are searching for after launching Vuforia. For example, consider a scenario where a game requires users to scan images one after another in a certain order. For example, a museum app may want you to scan all of the Rembrandt paintings in a room from oldest to newest to unlock some content. This method can offload the burdon of decision from your app to Vuforia, instead of writing login in your JavaScript, we're letting Vuforia take care of it.

```javascript
navigator.VuforiaPlugin.updateVuforiaTargets(
    ['iceland', 'canterbury-grass'], // Only return a success if the 'iceland' or 'canterbury-grass' images are found.
    function(data){
        console.log(data);
        
        alert('Updated trackers');
    },
    function(data) {
        alert("Error: " + data);
    }
);
```


### Using your own data
We know that eventually you're going to want to use your own data. To do so, follow these extra steps.

#### `www/targets/`
First, create a `targets/` folder inside `www/` and place your own `.xml` and `.dat` files inside.

> **NOTE:** Adding a `.pdf` file isn't required, but might be helpful for testing and development purposes.

#### JavaScript
##### `startVuforia(...)`
There are two pieces you will need to replace:

1. `PluginTest.xml` - Replace with a reference to your custom data file e.g. `www/targets/CustomData.xml`
1. `[ 'logo', 'iceland', 'canterbury-grass', 'brick-lane' ]` - Replace with the specific images for your data file that you are searching for.

> **NOTES:**
> * You don't have to search for all of the images in your data file each time. Your data file may contain 20 images, but for this particular action you may be only interested in two.
> * Data file paths can be either from the **resources folder** (which is the default) or **absolute** (in which case you'd start the `src` with `file://`). Absolute paths are useful if you'd like to access files in specific folders, like the iTunes sharing document folder for iOS, or the app root folder for Android.


#### `config.xml`
Add the following to your `config.xml` file:

```xml
<platform name="android">
    <resource-file src="www/targets/CustomData.xml" target="assets/CustomData.xml" />
    <resource-file src="www/targets/CustomData.dat" target="assets/CustomData.dat" />
</platform>

<platform name="ios">
    <resource-file src="targets/CustomData.xml" />
    <resource-file src="targets/CustomData.dat" />
</platform>
```


## Contributing
If you wish to submit a bug fix or feature, you can create a pull request and it will be merged pending a code review.

1. Clone it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request


## License
Cordova-Plugin-Vuforia is licensed under the [MIT License][info-license].

[logo]: https://cdn.rawgit.com/mattrayner/cordova-plugin-vuforia/d14d00720569fea02d29cded4de3c6e617c87537/images/logo.svg

[cordova]: https://cordova.apache.org/
[vuforia]: https://www.vuforia.com/
[example-repo]: https://github.com/dsgriffin/cordova-vuforia-example
[npm]: https://www.npmjs.com
[install-cordova]: https://cordova.apache.org/docs/en/latest/guide/cli/index.html#installing-the-cordova-cli
[updating-cordova]: https://cordova.apache.org/docs/en/latest/guide/cli/index.html#updating-cordova-and-your-project
[upgrading-ios]: https://cordova.apache.org/docs/en/latest/guide/platforms/ios/upgrade.html#upgrading-360-projects-to-400
[upgrading-android]: https://cordova.apache.org/docs/en/latest/guide/platforms/android/upgrade.html#upgrading-to-5xx
[cordova-plugin-vuforia-sdk]: https://github.com/mattrayner/cordova-plugin-vuforia-sdk
[issue-16]: https://github.com/mattrayner/cordova-plugin-vuforia/issues/16
[cordova-orientation-issue]: https://github.com/apache/cordova-lib/pull/260
[peugeot]: https://itunes.apple.com/gb/app/new-peugeot-208/id1020630968?mt=8

[info-npm]: https://www.npmjs.com/package/cordova-plugin-vuforia
[info-travis]: https://travis-ci.org/mattrayner/cordova-plugin-vuforia
[info-license]: LICENSE
[info-bithound]: https://www.bithound.io/github/mattrayner/cordova-plugin-vuforia
[shield-npm]: https://img.shields.io/npm/v/cordova-plugin-vuforia.svg
[shield-travis]: https://img.shields.io/travis/mattrayner/cordova-plugin-vuforia.svg
[shield-license]: https://img.shields.io/badge/license-MIT-blue.svg
[shield-bithound]: https://www.bithound.io/github/mattrayner/cordova-plugin-vuforia/badges/score.svg
[shield-cordova]: https://img.shields.io/badge/cordova%20support-6.*-blue.svg

[start-vuforia-doc-link]: #startvuforia---start-your-vuforia-session
[stop-vuforia-doc-link]: #stopvuforia---stop-your-vuforia-session
[stop-vuforia-trackers-doc-link]: #stopvuforiatrackers---stop-vuforia-image-trackers
[start-vuforia-trackers-doc-link]: #startvuforiatrackers---start-vuforia-image-trackers
[update-vuforia-targets-doc-link]: #updatevuforiatargets---update-the-list-of-targets-vuforia-is-searching-for
