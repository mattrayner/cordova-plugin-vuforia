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
   * @param {object} options An object containing different parameters needed to start Vuforia
   * @param {string} options.databaseXmlFile The Vuforia database file (.xml) with our target data inside.
   * @param {Array.<string>} options.targetList An array of images we are going to search for within our database. For example
   *                                      you may have a database of 100 images, but only be interested in 5 right now.
   * @param {string} options.overlayMessage A piece of copy displayed as a helpful hint to users i.e. 'Point your camera at the
   *                             orange target'.
   * @param {string} options.vuforiaLicense Your Vuforia license key. This is required for Vuforia to initialise successfully.
   * @param {boolean} options.showAndroidCloseButton (Optional). Display or not the close button on Android.
   * @param {boolean} options.showDevicesIcon (Optional). Display or not the devices icon
   * @param {boolean} options.autoStopOnImageFound (Optional). When finding an image, should the plugin automatically return to Cordova?
   * @param {function} successCallback A callback for when an image is found. Passes a data object with the image
   *                                      name inside.
   * @param {function|null} errorCallback A callback for when an error occurs. Could include device not having a camera,
   *                                      or invalid Vuforia key. Passes an error string with more information.
   */
  startVuforia: function(options, successCallback, errorCallback){
    var exec_options,
      databaseXmlFile = options.databaseXmlFile,
      targetList = options.targetList,
      overlayMessage = options.overlayMessage,
      vuforiaLicense = options.vuforiaLicense,
      showAndroidCloseButton = !!options.showAndroidCloseButton,
      showDevicesIcon = !!options.showDevicesIcon,
      autostopOnImageFound = true;

    if (typeof options.autostopOnImageFound !== "undefined" && options.autostopOnImageFound !==null && !options.autostopOnImageFound)
      autostopOnImageFound = false;

    exec_options = [ databaseXmlFile , targetList, overlayMessage, vuforiaLicense, showAndroidCloseButton, showDevicesIcon, autostopOnImageFound ];

    VuforiaPlugin.exec(successCallback, errorCallback, 'cordovaStartVuforia', exec_options);
  },

  /**
   * Close an existing Vuforia image recognition session on the user's device.
   *
   * @param {function} successCallback A callback for when the session is closed successfully.
   * @param {function|null} errorCallback A callback for when an error occurs.
   */
  stopVuforia: function(successCallback, errorCallback){
    VuforiaPlugin.exec(successCallback, errorCallback, 'cordovaStopVuforia', []);
  },

  /**
   * Stop Vuforia image trackers.
   *
   * @param {function} successCallback A callback for when the session is paused successfully.
   * @param {function|null} errorCallback A callback for when an error occurs.
   */
  stopVuforiaTrackers: function(successCallback, errorCallback){
    VuforiaPlugin.exec(successCallback, errorCallback, 'cordovaStopTrackers', []);
  },

  /**
   * Start Vuforia image trackers.
   *
   * @param {function} successCallback A callback for when the session is resumed successfully.
   * @param {function|null} errorCallback A callback for when an error occurs.
   */
  startVuforiaTrackers: function(successCallback, errorCallback){
    VuforiaPlugin.exec(successCallback, errorCallback, 'cordovaStartTrackers', []);
  },

  /**
   * Update Vuforia image targets.
   *
   * @param {Array.<string>} targets An array of images we are going to search for within our database. For example
   *                                  you may have a database of 100 images, but only be interested in 5 right now.
   * @param {function} successCallback A callback for when the session is resumed successfully.
   * @param {function|null} errorCallback A callback for when an error occurs.
   */
  updateVuforiaTargets: function(targets, successCallback, errorCallback){
    VuforiaPlugin.exec(successCallback, errorCallback, 'cordovaUpdateTargets', [ targets ]);
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
  },

  /**
   * Trigger a method within our native plugin, passing the options we need.
   *
   * @param {function} success A callback to handle successful execution of our native method.
   * @param {function|null} error A callback to handle any errors in the execution of our native method. Can be null.
   * @param {string} method The method we should execute on our native plugin.
   * @param {Array.<string|boolean>} options The options we should pass to our native method. Can be null.
   */
  exec: function(success, error, method, options) {
    cordova.exec(
      // Register the success callback
      success,
      // Register the error callback
      function errorCallback(err) {
        VuforiaPlugin.errorHandler(err, error);
      },
      // Define what native class to route messages to
      VuforiaPlugin.pluginClass,
      // Execute this method on the above native class
      method,
      // Provide an array of arguments to the above method
      options
    );
  }
};

module.exports = VuforiaPlugin;
