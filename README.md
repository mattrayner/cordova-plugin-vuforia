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


## Requirements
Cordova-Plugin-Vuforia requires the following:
* [NPM][npm]
* [Cordova][cordova] (5.x - see [issue #4][issue-4] r.e Cordova 6.x support)


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

![[Deployment Target GIF][stage-1]][stage-5]


##### Run your build!
You should now be all setup! All that's left is to run your build.

**NOTE**: You are unable to run the Vuforia plugin within a simulator as is lacks a number of required hardware and software features.

![[Deployment Target GIF][stage-1]][stage-6]

## Additional Configurations
### Fixed orientation
Firstly, you will need to add an orientation preference to your config.xml file:
```xml
<preference name="Orientation" value="landscape" />
```

If you are building for iOS you will need to make the following change too within Xcode:-

Within `Classes>AppDeligate.m` scroll to the bottom and remove the references to Portrait and UpsideDown. It sould look something like this when finished:
```objective-c
- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    // iPhone doesn't support upside down by default, while the iPad does.  Override to allow all orientations always, and let the root view controller decide what's allowed (the supported orientations mask gets intersected).
    NSUInteger supportedInterfaceOrientations = (1 << UIInterfaceOrientationLandscapeLeft) | (1 << UIInterfaceOrientationLandscapeRight);

    return supportedInterfaceOrientations;
}
```

**NOTE:** The above example assumes you are looking for a fixed *LANDSCAPE* orientation. You will need to update the above with portrait values if you need portrait.


## Contributing
If you wish to submit a bug fix or feature, you can create a pull request and it will be merged pending a code review.

1. Clone it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request


## License
Cordova-Plugin-Vuforia is licensed under the [MIT License][info-license].

[logo]: https://cdn.rawgit.com/thisisbd/cordova-plugin-vuforia/d14d00720569fea02d29cded4de3c6e617c87537/images/logo.svg
[stage-1]: https://raw.githubusercontent.com/mattrayner/cordova-plugin-vuforia/cordova-ios-3/images/stage-1.gif
[stage-2]: https://raw.githubusercontent.com/mattrayner/cordova-plugin-vuforia/cordova-ios-3/images/stage-2.gif
[stage-3]: https://raw.githubusercontent.com/mattrayner/cordova-plugin-vuforia/cordova-ios-3/images/stage-3.gif
[stage-4]: https://raw.githubusercontent.com/mattrayner/cordova-plugin-vuforia/cordova-ios-3/images/stage-4.gif
[stage-5]: https://raw.githubusercontent.com/mattrayner/cordova-plugin-vuforia/cordova-ios-3/images/stage-5.gif
[stage-6]: https://raw.githubusercontent.com/mattrayner/cordova-plugin-vuforia/cordova-ios-3/images/stage-6.gif

[cordova]: https://cordova.apache.org/
[vuforia]: https://www.vuforia.com/
[npm]: https://www.npmjs.com
[issue-4]: https://github.com/thisisbd/cordova-plugin-vuforia/issues/4
[peugeot]: https://itunes.apple.com/gb/app/new-peugeot-208/id1020630968?mt=8

[info-npm]: https://www.npmjs.com/package/cordova-plugin-vuforia
[info-travis]: https://travis-ci.org/thisisbd/cordova-plugin-vuforia
[info-license]: LICENSE
[info-bithound]: https://www.bithound.io/github/thisisbd/cordova-plugin-vuforia
[shield-npm]: https://img.shields.io/npm/v/cordova-plugin-vuforia.svg
[shield-travis]: https://img.shields.io/travis/thisisbd/cordova-plugin-vuforia.svg
[shield-license]: https://img.shields.io/badge/license-MIT-blue.svg
[shield-bithound]: https://www.bithound.io/github/thisisbd/cordova-plugin-vuforia/badges/score.svg
