# ![Cordova-Plugin-Vuforia][logo]
Cordova-Plugin-Vuforia is a [Cordova][cordova] plugin that uses [Vuforia][vuforia] to perform image recognition. You can see an example in the [Peugeot 208][peugeot] app on iOS and Android.

[![NPM Version][shield-npm]][info-npm]
[![Build Status][shield-travis]][info-travis]
[![Bithound Score][shield-bithound]][info-bithound]
[![License][shield-license]][info-license]


## Key Features
- Image recognition using reliable [Vuforia][vuforia] library
- Comprehensive setup instructions


## Supported Platforms
- Android
- iOS
- WP8


## Getting Started
### Plugin Installation
```bash
cordova plugin add cordova-plugin-vuforia
```

#### Javascript example
From within your Javascript file, add the following to launch the [Vuforia][vuforia] plugin.
```javascript
navigator.VuforiaPlugin.startVuforia(
  'StonesAndChips.xml',
  [ 'stones', 'chips' ],
  'Point your camera at either the stones or the chips image...',
  'YOUR_VUFORIA_KEY',
  function(data){
    console.log(data);
    alert("Image found: "+data.imageName);
  }
);
```

**NOTE**: You will need to replace `YOUR_VUFORIA_KEY` with a valid license key for the plugin to launch correctly.

You will also need to replace the `StonesAndChips.xml` and `[ 'stones', 'chips' ]` array with specific information for your application. These are here for initial setup and demo purposes.


#### iOS Steps
##### IMPORTANT
> If you are planning to use the plugin with iOS you have to complete the below steps for the application to properly compile.


##### Deployment Target
The [Vuforia][vuforia] SDK has a minimum deployment target of `7.0`. This is set within the `General > Product Info` setting.

![[Deployment Target GIF][stage-1]][stage-1]


##### Disable `Bitcode`
Newer versions of Xcode and iOS have something called `Bitcode` enabled by default. Set `Build Settings > Enable Bitcode` to `NO`.

![[Deployment Target GIF][stage-1]][stage-2]


##### Header Search Paths
In order for Xcode to find the [Vuforia][vuforia] library we need to add it's location into our header search paths.

Within `Build Settings > Header Search Paths`, add the following:

`../../plugins/cordova-plugin-vuforia/build/include`

![[Deployment Target GIF][stage-1]][stage-3]

We also need to add the following:

`"$(OBJROOT)/UninstalledProducts/$(PLATFORM_NAME)/include"`

![[Deployment Target GIF][stage-1]][stage-4]


##### Update `appdelegate.m`
In order to launch our [Vuforia][vuforia] plugin we have to make a small change to the `appdelegate.m` file.

Search for and replace:
```objective-c
self.window.rootViewController = self.viewController;
[self.window makeKeyAndVisible];

return YES;
```

with:
```objective-c
UINavigationController * nc = [[UINavigationController alloc]initWithRootViewController:self.viewController];
[nc setNavigationBarHidden:YES animated:NO];


self.window.rootViewController = nc;
[self.window makeKeyAndVisible];

return YES;
```


## Requirements
SilverStripe-Capistrano requires the following:
* [NPM][npm]
* [Cordova][cordova]


## Contributing
If you wish to submit a bug fix or feature, you can create a pull request and it will be merged pending a code review.

1. Clone it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request


## License
Cordova-Plugin-Vuforia is licensed under the [GPL 2.0 License][info-license].

[logo]: https://raw.github.com/thisisbd/cordova-vuforia-plugin/master/images/logo.png
[stage-1]: https://raw.github.com/thisisbd/cordova-vuforia-plugin/master/images/stage-1.gif
[stage-2]: https://raw.github.com/thisisbd/cordova-vuforia-plugin/master/images/stage-2.gif
[stage-3]: https://raw.github.com/thisisbd/cordova-vuforia-plugin/master/images/stage-3.gif
[stage-4]: https://raw.github.com/thisisbd/cordova-vuforia-plugin/master/images/stage-4.gif
[stage-5]: https://raw.github.com/thisisbd/cordova-vuforia-plugin/master/images/stage-5.gif
[stage-6]: https://raw.github.com/thisisbd/cordova-vuforia-plugin/master/images/stage-6.gif

[cordova]: https://cordova.apache.org/
[vuforia]: https://www.vuforia.com/
[npm]: https://www.npmjs.com
[peugeot]: https://itunes.apple.com/gb/app/new-peugeot-208/id1020630968?mt=8

[info-npm]: https://github.com/mattrayner/silverstripe-capistrano
[info-travis]: https://github.com/mattrayner/silverstripe-capistrano
[info-license]: LICENSE
[info-bithound]: https://www.bithound.io/github/thisisbd/cordova-plugin-vuforia
[shield-npm]: https://img.shields.io/npm/v/cordova-plugin-vuforia.svg
[shield-travis]: https://img.shields.io/travis/thisisbd/cordova-plugin-vuforia.svg
[shield-license]: https://img.shields.io/badge/license-GPL2-blue.svg
[shield-bithound]: https://www.bithound.io/github/thisisbd/cordova-plugin-vuforia/badges/score.svg
