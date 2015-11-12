var VuforiaPlugin = {
  startVuforia: function(imageFile ,imageTargets, overlayCopy, vuforiaLicense, imageFoundCallback){

    cordova.exec(

      // Register the callback handler
      function callback(data) {
        imageFoundCallback(data);
      },
      // Register the errorHandler
      function errorHandler(err) {
        console.error('Vuforia Plugin Error:');
        console.error(err);
      },
      // Define what class to route messages to
      'VuforiaPlugin',
      // Execute this method on the above class
      'cordovaStartVuforia',
      // An array containing one String.
      [ imageFile , imageTargets, overlayCopy, vuforiaLicense ]
    );
  }
};
module.exports = VuforiaPlugin;