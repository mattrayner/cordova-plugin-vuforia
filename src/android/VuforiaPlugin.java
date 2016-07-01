package com.mattrayner.vuforia;

import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;

import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;

import android.app.Activity;
import android.content.Intent;
import android.content.Context;
import android.content.pm.PackageManager;
import android.util.Log;
import android.Manifest;
import android.Manifest.permission;

import com.mattrayner.vuforia.app.ImageTargets;

public class VuforiaPlugin extends CordovaPlugin {
    static final String LOGTAG = "CordovaVuforiaPlugin";

    // Some public static variables used to communicate state
    public static final String CAMERA = Manifest.permission.CAMERA;
    public static final String PLUGIN_ACTION = "org.cordova.plugin.vuforia.action";
    public static final String DISMISS_ACTION = "dismiss";
    public static final String PAUSE_ACTION = "pause";
    public static final String RESUME_ACTION = "resume";
    public static final String UPDATE_TARGETS_ACTION = "update_targets";

    // Save some ENUM values to describe plugin results
    public static final int IMAGE_REC_RESULT = 0;
    public static final int MANUAL_CLOSE_RESULT = 1;
    public static final int ERROR_RESULT = 2;
    public static final int NO_RESULT = 3;

    // What access to the camera do we require?
    private static final int CAPTURE_VIDEO_ACTIVITY_REQUEST_CODE = 200;

    // Save a copy of our starting vuforia context so that we can start reference it later is needs be
    private static CallbackContext persistantVuforiaStartCallback;

    // Some internal variables for storing state across methods
    private static String ACTION;
    private static JSONArray ARGS;

    static final int IMAGE_REC_REQUEST = 1;

    // Internal variables for holding state
    private boolean vuforiaStarted = false;
    private boolean autostopOnImageFound = true;
    CallbackContext callback;

    public VuforiaPlugin() {
    }

    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);

        Log.d(LOGTAG, "Plugin initialized.");
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        callback = callbackContext;

        // Handle all expected actions
        if(action.equals("cordovaStartVuforia")) {
            startVuforia(action, args, callbackContext);
        }
        else if(action.equals("cordovaStopVuforia")) {
            stopVuforia(action, args, callbackContext);
        }
        else if(action.equals("cordovaStopTrackers")) {
            stopVuforiaTrackers(action, args, callbackContext);
        }
        else if(action.equals("cordovaStartTrackers")) {
            startVuforiaTrackers(action, args, callbackContext);
        }
        else if(action.equals("cordovaUpdateTargets")) {
            updateVuforiaTargets(action, args, callbackContext);
        }
        else {
            return false;
        }

        return true;
    }

    // Start our Vuforia activities
    public void startVuforia(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        // If we are starting Vuforia, set the public variable referencing our start callback for later use
        VuforiaPlugin.persistantVuforiaStartCallback = callbackContext;

        ACTION = action;
        ARGS = args;

        // Get all of our ARGS out and into local variables
        String targetFile = args.getString(0);
        String targets = args.getJSONArray(1).toString();
        String overlayText = (args.isNull(2)) ? null : args.getString(2);
        String vuforiaLicense = args.getString(3);
        Boolean closeButton = args.getBoolean(4);
        Boolean showDevicesIcon = args.getBoolean(5);
        autostopOnImageFound = args.getBoolean(6);

        Context context =  cordova.getActivity().getApplicationContext();

        // Create a new intent to pass data to Vuforia
        Intent intent = new Intent(context, ImageTargets.class);

        intent.putExtra("IMAGE_TARGET_FILE", targetFile);
        intent.putExtra("IMAGE_TARGETS", targets);

        if(overlayText != null)
            intent.putExtra("OVERLAY_TEXT", overlayText);

        intent.putExtra("LICENSE_KEY", vuforiaLicense);
        intent.putExtra("DISPLAY_CLOSE_BUTTON", closeButton);
        intent.putExtra("DISPLAY_DEVICES_ICON", showDevicesIcon);
        intent.putExtra("STOP_AFTER_IMAGE_FOUND", autostopOnImageFound);

        // Check to see if we have permission to access the camera
        if(cordova.hasPermission(CAMERA)) {
            // Launch a new activity with Vuforia in it. Expect it to return a result.
            cordova.startActivityForResult(this, intent, IMAGE_REC_REQUEST);
            vuforiaStarted = true;
        }
        else {
            // Request the camera permission and handle the outcome.
            cordova.requestPermission(this, CAPTURE_VIDEO_ACTIVITY_REQUEST_CODE, CAMERA);
        }
    }

    // Stop Vuforia
    public void stopVuforia(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        // JSON we will send back to Cordova
        JSONObject json = new JSONObject();

        // Is Vuforia sterts?
        if(vuforiaStarted) {
            Log.d(LOGTAG, "Stopping plugin");

            // Stop Vuforia
            sendAction(DISMISS_ACTION);
            vuforiaStarted = false;

            json.put("success", "true");
        }
        else {
            Log.d(LOGTAG, "Cannot stop the plugin because it wasn't started");

            json.put("success", "false");
            json.put("message", "No Vuforia session running");
        }

        // Send an OK result back to Cordova
        PluginResult result = new PluginResult(PluginResult.Status.OK, json);
        callback.sendPluginResult(result);
    }

    // Stop Vuforia trackers
    public void stopVuforiaTrackers(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        Log.d(LOGTAG, "Pausing trackers");

        sendAction(PAUSE_ACTION);

        sendSuccessPluginResult();
    }

    // Start Vuforia trackers
    public void startVuforiaTrackers(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        Log.d(LOGTAG, "Resuming trackers");

        sendAction(RESUME_ACTION);

        sendSuccessPluginResult();
    }

    // Start Vuforia trackers
    public void updateVuforiaTargets(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        Log.d(LOGTAG, "Updating targets");

        Log.d(LOGTAG, "ARGS: "+args);

        String targets = args.getJSONArray(0).toString();

        sendAction(UPDATE_TARGETS_ACTION, targets);

        sendSuccessPluginResult();
    }

    // Handle the results of our permissions request
    public void onRequestPermissionResult(int requestCode, String[] permissions, int[] grantResults) throws JSONException {
        for(int r:grantResults) {
            // Is the permission denied for our video request?
            if(r == PackageManager.PERMISSION_DENIED && requestCode == CAPTURE_VIDEO_ACTIVITY_REQUEST_CODE) {
                // Send a plugin error
                this.callback.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "CAMERA_PERMISSION_ERROR"));
                return;
            }
        }

        if(requestCode == CAPTURE_VIDEO_ACTIVITY_REQUEST_CODE)
            execute(ACTION, ARGS, this.callback); // Re-call execute with all the same values as before (will re-check for permissions)
    }

    // Called when we receive a response from an activity we've launched
    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        String name;

        // If we get to this point with no data  then we've likely got an error. Or the activity closed because of an error.
        if (data == null) {
            name = "ERROR";
        }
        else {
            name = data.getStringExtra("name");
        }

        Log.d(LOGTAG, "Plugin received '" + name + "' from Vuforia.");

        // Check which request we're responding to
        if (requestCode == IMAGE_REC_REQUEST) {
            JSONObject jsonObj = new JSONObject();

            // Check what result code we received
            switch(resultCode){
                case IMAGE_REC_RESULT: // We've received an image (hopefully)
                    // Attempt to build and send a result back to Cordova.
                    try {
                        // Create our status object
                        JSONObject jsonStatus = new JSONObject();
                        jsonStatus.put("imageFound", true);
                        jsonStatus.put("message", "An image was found.");

                        // Create our result object
                        JSONObject jsonResult = new JSONObject();
                        jsonResult.put("imageName", name);

                        // Create our response object
                        jsonObj.put("status", jsonStatus);
                        jsonObj.put("result", jsonResult);

                        // Create the plugin result
                        PluginResult result = new PluginResult(PluginResult.Status.OK, jsonObj);

                        // Send a result specifically to our PERSISTANT callback i.e. the callback given to startVuforia.
                        // This allows us to receive other messages from start/stop tracker events without losing this particular callback.
                        persistantVuforiaStartCallback.sendPluginResult(result);
                    }
                    catch(JSONException e) { // We encounter a JSONException
                        Log.d(LOGTAG, "JSON ERROR: " + e);
                        // Send an error to the plugin (so we don't just die quietly)
                        persistantVuforiaStartCallback.sendPluginResult( new PluginResult(PluginResult.Status.ERROR, "JSON ERROR BUILDING IMAGE FOUND RESPONSE: " + e) );
                    }
                    break;
                case MANUAL_CLOSE_RESULT: // The user has manually closed the plugin.
                    try {
                        // Create our status object
                        JSONObject jsonStatus = new JSONObject();
                        jsonStatus.put("manuallyClosed", true);
                        jsonStatus.put("message", "User manually closed the plugin.");

                        jsonObj.put("status", jsonStatus);

                        // Send the result back to the persistant callback
                        persistantVuforiaStartCallback.sendPluginResult(new PluginResult(PluginResult.Status.OK, jsonObj));
                    }
                    catch( JSONException e ) {
                        Log.d(LOGTAG, "JSON ERROR: " + e);
                        // Send an error to the plugin (so we don't just die quietly)
                        persistantVuforiaStartCallback.sendPluginResult( new PluginResult(PluginResult.Status.ERROR, "JSON ERROR BUILDING MANUAL CLOSE RESPONSE: " + e) );
                    }
                    break;
                default:
                    Log.d(LOGTAG, "Error - received unexpected code on Activity close: " + resultCode);
            }
        }

        // Mark Vuforia as closed
        vuforiaStarted = false;
    }

    // Send a broadcast to our open activity (probably Vuforia)
    private void sendAction(String action){
        Intent resumeIntent = new Intent(PLUGIN_ACTION);
        resumeIntent.putExtra(PLUGIN_ACTION, action);
        this.cordova.getActivity().sendBroadcast(resumeIntent);
    }

    // Send a broadcast to our open activity (probably Vuforia)
    private void sendAction(String action, String data){
        Intent resumeIntent = new Intent(PLUGIN_ACTION);
        resumeIntent.putExtra(PLUGIN_ACTION, action);
        resumeIntent.putExtra("ACTION_DATA", data);
        this.cordova.getActivity().sendBroadcast(resumeIntent);
    }

    // Send a generic 'success' result to the last callback given
    private void sendSuccessPluginResult(){
        try {
            JSONObject json = new JSONObject();
            json.put("success", "true");
            callback.sendPluginResult(new PluginResult(PluginResult.Status.OK, json));
        }
        catch( JSONException e ) {
            Log.d(LOGTAG, "JSON ERROR: " + e);
        }
    }

    // Send an asynchronous update when an image is found and Vuforia is set to stay open.
    public static void sendImageFoundUpdate(String imageName){
        Log.d(LOGTAG, "Attempting to send an update for image: " + imageName);

        // Create an object to hold our response
        JSONObject jsonObj = new JSONObject();

        // Try to build a JSON response to send to Cordova
        try {
            JSONObject jsonStatus = new JSONObject();
            jsonStatus.put("imageFound", true);
            jsonStatus.put("message", "An image was found.");

            JSONObject jsonResult = new JSONObject();
            jsonResult.put("imageName", imageName);

            jsonObj.put("status", jsonStatus);
            jsonObj.put("result", jsonResult);
        } catch (JSONException e) {
            Log.d(LOGTAG, "JSON ERROR: " + e);
        }

        // Build our response
        PluginResult result = new PluginResult(PluginResult.Status.OK, jsonObj);
        result.setKeepCallback(true); // Don't clean up our callback (we intend on sending more messages to it)

        // Send the result to our PERSISTANT callback
        persistantVuforiaStartCallback.sendPluginResult(result);
    }
}
