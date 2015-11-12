# Cordova Vuforia Plugin

min target = 7

`ENABLE BITCODE NO`

orientation stuff

Work out what we actually NEED from the other README - do we really need the orientation stuff?

JS Example
```javascript
navigator.KTVuforiaPlugin.startVuforia(
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