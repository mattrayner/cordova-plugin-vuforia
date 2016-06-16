/**
 * VuforiaPlugin module, used within our Cordova front-end to both start and stop a Vuforia image recognition session.
 *
 * @type {object}
 */
var VuforiaPlugin = {
  /**
   * The plugin class to route messages to.
   * @type {string}
   */
  pluginClass: 'VuforiaPlugin',

  /**
   * Start a new Vuforia image recognition session on the user's device.
   *
   * @param {string} imageFile The Vuforia database file (.xml) with our target data inside.
   * @param {Array.<string>} imageTargets An array of images we are going to search for within our database. For example
   *                                      you may have a database of 100 images, but only be interested in 5 right now.
   * @param {string} overlayCopy A piece of copy displayed as a helpful hint to users i.e. 'Point your camera at the
   *                             orange target'.
   * @param {string} vuforiaLicense Your Vuforia license key. This is required for Vuforia to initialise successfully.
   * @param {function} imageFoundCallback A callback for when an image is found. Passes a data object with the image
   *                                      name inside.
   * @param {function|null} errorCallback A callback for when an error occurs. Could include device not having a camera,
   *                                      or invalid Vuforia key. Passes an error string with more information.
   */
  startVuforia: function(imageFile ,imageTargets, overlayCopy, vuforiaLicense, imageFoundCallback, errorCallback){
    cordova.exec(
      // Register the callback handler
      function callback(data) {
        imageFoundCallback(data);
      },
      // Register the error handler
      function errorHandler(err) {
        VuforiaPlugin.errorHandler(err, errorCallback);
      },
      // Define what class to route messages to
      VuforiaPlugin.pluginClass,
      // Execute this method on the above class
      'cordovaStartVuforia',
      // Provide an array of arguments above method
      [ imageFile , imageTargets, overlayCopy, vuforiaLicense ]
    );
  },

  /**
   * Close an existing Vuforia image recognition session on the user's device.
   *
   * @param {function} success A callback for when the session is closed successfully.
   * @param {function|null} errorCallback A callback for when an error occurs.
   */
  stopVuforia: function(success, errorCallback){
    cordova.exec(
      // Register the callback handler
      function callback(data) {
        success(data);
      },
      // Register the error handler
      function errorHandler(err) {
        VuforiaPlugin.errorHandler(err, errorCallback);
      },
      // Define what class to route messages to
      VuforiaPlugin.pluginClass,
      // Execute this method on the above class
      'cordovaStopVuforia',
      // Provide an empty array of arguments to the above method
      []
    );
  },

  /**
   * Handle an error from one of the plugin methods. If a callback is defined, an error message is passed to it. If not,
   * the error message is logged to the console.
   *
   * @param {string} err A (hopefully) helpful error message.
   * @param {function|null} callback A callback for when an error occurs.
   */
  errorHandler: function(err, callback) {
    if(typeof callback !== 'undefined') {
      callback(err);
    } else {
      console.log('Received error from Vuforia Plugin:');
      console.log(err);
    }
  }
};

module.exports = VuforiaPlugin;
