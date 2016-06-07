var VuforiaPlugin = {
  startVuforia: function(imageFile ,imageTargets, overlayCopy, vuforiaLicense, imageFoundCallback, errorCallback){

    cordova.exec(

      // Register the callback handler
      function callback(data) {
        imageFoundCallback(data);
      },
      // Register the error handler
      function errorHandler(err) {
        if(typeof errorCallback !== 'undefined') {
          errorCallback(err);
        }
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