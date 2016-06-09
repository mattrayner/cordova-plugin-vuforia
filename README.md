# ![Cordova-Plugin-Vuforia][logo]
Cordova-Plugin-Vuforia is a [Cordova][cordova] plugin that uses [Vuforia][vuforia] to perform image recognition. 

You can see a live example in the [Peugeot 208][peugeot] app on iOS and Android and a basic open source example in the [cordova-vuforia-example][example-repo] repo.

[![NPM Version][shield-npm]][info-npm]
[![Supported Cordova Versions][shield-cordova]][info-npm]
[![Build Status][shield-travis]][info-travis]
[![Bithound Score][shield-bithound]][info-bithound]
[![License][shield-license]][info-license]


## Supported Platforms
Android (Minimum 4), iOS (Minimum 8)


## Requirements
Cordova-Plugin-Vuforia requires the following:
* [npm][npm]
* [Cordova 6.*][cordova] - 6.* is required as it adds support for Android 6 (Marshmellow) and iOS 9.
  * If you haven't yet installed the Cordova CLI, grab the latest version by following [these steps][install-cordova].
  * If you've already got a project running with an older version of Cordova (e.g. 4 or 5), [see here][updating-cordova] how to update your project's Cordova version.
  * Or if you want to upgrade to the latest version on a platform-by-platform basis, see either [upgrading to cordova-ios 4][upgrading-ios] or [upgrading to cordova-android 5][upgrading-android].

**NOTE:** You will require an Android or iOS device. Cordova-Plugin-Vuforia requires hardware and software support that is not present in either the iOS or Android simulators. 


## Getting Started
### Plugin Installation
```bash
cordova plugin add cordova-plugin-vuforia
```

#### Javascript example
From within your Javascript file, add the following to launch the [Vuforia][vuforia] plugin.
```javascript
navigator.VuforiaPlugin.startVuforia(
  'PluginTest.xml',
  [ 'logo', 'iceland', 'canterbury-grass', 'brick-lane' ],
  'Point your camera at a test image...',
  'YOUR_VUFORIA_KEY',
  function(data){
    console.log(data);
    alert("Image found: "+data.imageName);
  },
  function(data) {
    alert("Error: " + data);
  }
);
```

**NOTES**: 
* You will need to replace `YOUR_VUFORIA_KEY` with a valid license key for the plugin to launch correctly.
* For testing you can use the `targets/PluginTest_Targets.pdf` file inside the plugin folder; it contains all four testing targets.

#### Using your own data
We know that eventually you're going to want to use your own data. To do so, follow these extra steps.

##### `www/`
First, create a `targets/` folder inside `www/` and place your own `.xml`/`.dat`/`.pdf` files inside.

##### `.js`
You will need to replace the `PluginTest.xml` argument with `www/targets/CustomData.xml` and the `[ 'logo', 'iceland', 'canterbury-grass', 'brick-lane' ]` argument with the specific information for your application. These are here for initial setup and demo purposes only.

##### `config.xml`
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

**NOTE:** 
* File paths can be either from the **resources folder** (which is the default) or **absolute** (in which case you'd start the `src` with `file://`). Absolute paths are useful if you'd like to access files in specific folders, like the iTunes sharing document folder for iOS, or the app root folder for Android.


## Known Issues
### Fixed orientation - [issue #16][issue-16]
With the release of Cordova 6 and `cordova-ios` 4, orientation locking appears to be broken - [see this cordova issue][cordova-orientation-issue]. For now, if you wish to lock your orientation, please use `cordova-ios` 3.* and follow the instructions on the `cordova-ios-3` branch.


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