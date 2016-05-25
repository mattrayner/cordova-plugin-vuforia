# ![Cordova-Plugin-Vuforia][logo]
Cordova-Plugin-Vuforia is a [Cordova][cordova] plugin that uses [Vuforia][vuforia] to perform image recognition. You can see an example in the [Peugeot 208][peugeot] app on iOS and Android.

[![NPM Version][shield-npm]][info-npm]
[![Supported Cordova Versions][shield-cordova]][info-npm]
[![Build Status][shield-travis]][info-travis]
[![Bithound Score][shield-bithound]][info-bithound]
[![License][shield-license]][info-license]


## Key Features
- Image recognition using reliable [Vuforia][vuforia] library
- Comprehensive setup instructions


## Supported Platforms
- Android
- iOS


## Requirements
Cordova-Plugin-Vuforia requires the following:
* [NPM][npm]
* [Cordova][cordova] (Minimum 5.0 - tested to 6.1.1)
  * `cordova-ios@3.*` instructions on `cordova-ios-3` branch
  * `cordova-ios@4.*` (default for Cordova 6.*) instructions are below


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
  }
);
```

**NOTE**: You will need to replace `YOUR_VUFORIA_KEY` with a valid license key for the plugin to launch correctly.

For testing you can use the `targets/PluginTest_Targets.pdf` file, it contains all four testing targets.


#### Using your own data
##### Cordova `config.xml`
We know that eventually you're going to want to use your own data. You should place your .xml and .dat files inside a `targets` folder at the root of your project, then add the following to your config.xml file:

```xml
<platform name="android">
    <resource-file src="targets/CustomData.dat" target="assets/CustomData.dat" />
    <resource-file src="targets/CustomData.xml" target="assets/CustomData.xml" />
</platform>

<platform name="ios">
    <resource-file src="targets/CustomData.dat" target-dir="com.mattrayner.vuforia" />
    <resource-file src="targets/CustomData.xml" target-dir="com.mattrayner.vuforia" />
</platform>
```

##### JS Change
You will need to replace the `PluginTest.xml` and `[ 'logo', 'iceland', 'canterbury-grass', 'brick-lane' ]` lines with specific information for your application. These are here for initial setup and demo purposes only.


#### Android Steps
That's it... As far as setup goes... You're done! Android is nice and flexible, the plugin **should** have done everything for you!


#### iOS Steps
##### IMPORTANT
> If you are planning to use the plugin with iOS you have to complete the below steps for the application to properly compile.


##### Deployment Target
**NOTE:** `cordova-ios` version 4, the default ios platform version for cordova 6, has a minimum ios SDK version of `8.0`. Vuforia's minimum version is `7.0`, if you want your applications version to be `7.0` please check out the `cordova-ios-3` branch for instructions.


##### Header Search Paths
In order for Xcode to find the [Vuforia][vuforia] library we need to add it's location into our header search paths.

Within `Build Settings > Header Search Paths`, add the following:

`../../plugins/cordova-plugin-vuforia/build/include`

![[Deployment Target GIF][stage-3]][stage-3]

We also need to add the following:

`"$(OBJROOT)/UninstalledProducts/$(PLATFORM_NAME)/include"`

![[Deployment Target GIF][stage-4]][stage-4]

These paths will allow the Xcode compiler to find the Vuforia library and include it in your application.


##### Update `appdelegate.m`
In order to launch our [Vuforia][vuforia] plugin we have to make a change to the `appdelegate.m` file within Xcode.

Add this import statement at the top of the file:
```objective-c
#import <Cordova/CDVPlugin.h>
```

Then, search for and replace:
```objective-c
- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    self.viewController = [[MainViewController alloc] init];
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
```

with:
```objective-c
- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];

#if __has_feature(objc_arc)
    self.window = [[UIWindow alloc] initWithFrame:screenBounds];
#else
    self.window = [[[UIWindow alloc] initWithFrame:screenBounds] autorelease];
#endif
    self.window.autoresizesSubviews = YES;
#if __has_feature(objc_arc)
    self.viewController = [[MainViewController alloc] init];
#else
    self.viewController = [[[MainViewController alloc] init] autorelease];
#endif

    // Set your app's start page by setting the <content src='foo.html' /> tag in config.xml.
    // If necessary, uncomment the line below to override it.
    // self.viewController.startPage = @"index.html";

    // NOTE: To customize the view's frame size (which defaults to full screen), override
    // [self.viewController viewWillAppear:] in your view controller.

    UINavigationController * nc = [[UINavigationController alloc]initWithRootViewController:self.viewController];
    [nc setNavigationBarHidden:YES animated:NO];

    self.window.rootViewController = nc;
    [self.window makeKeyAndVisible];

    return YES;
}

```

![[Deployment Target GIF][stage-5-2]][stage-5-2]


##### Run your build!
You should now be all setup! All that's left is to run your build.

**NOTE**: You are unable to run the Vuforia plugin within a simulator as is lacks a number of required hardware and software features.

![[Deployment Target GIF][stage-6-2]][stage-6-2]

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
[stage-3]: https://raw.githubusercontent.com/mattrayner/cordova-plugin-vuforia/master/images/stage-3.gif
[stage-4]: https://raw.githubusercontent.com/mattrayner/cordova-plugin-vuforia/master/images/stage-4.gif
[stage-5-2]: https://raw.githubusercontent.com/mattrayner/cordova-plugin-vuforia/master/images/stage-5-2.gif
[stage-6-2]: https://raw.githubusercontent.com/mattrayner/cordova-plugin-vuforia/master/images/stage-6-2.gif

[cordova]: https://cordova.apache.org/
[vuforia]: https://www.vuforia.com/
[npm]: https://www.npmjs.com
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
[shield-cordova]: https://img.shields.io/badge/cordova%20support-5.*%20--%206.*-blue.svg
