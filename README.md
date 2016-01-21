# Cordova Vuforia Plugin

min target = 7

`ENABLE BITCODE NO`

orientation stuff

Work out what we actually NEED from the other README - do we really need the orientation stuff?

JS Example
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

Build path

`../../plugins/cordova-plugin-vuoria/build/include`

`"$(OBJROOT)/UninstalledProducts/$(PLATFORM_NAME)/include"`

ApplicationViewController

Find:
```objective-c
self.window.rootViewController = self.viewController;
[self.window makeKeyAndVisible];

return YES;
```

```objective-c
UINavigationController * nc = [[UINavigationController alloc]initWithRootViewController:self.viewController];
[nc setNavigationBarHidden:YES animated:NO];


self.window.rootViewController = nc;
[self.window makeKeyAndVisible];

return YES;
```