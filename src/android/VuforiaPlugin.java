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
    public static final String CAMERA = Manifest.permission.CAMERA;
    public static final String PLUGIN_ACTION = "org.cordova.plugin.vuforia.action";
    public static final String DISMISS_ACTION = "dismiss";

    private static final int CAPTURE_VIDEO_ACTIVITY_REQUEST_CODE = 200;

    private static String ACTION;
    private static JSONArray ARGS;

    static final String LOGTAG = "CordovaVuforiaPlugin";

    static final int IMAGE_REC_REQUEST = 1;

    private boolean vuforiaStarted = false;

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

        if(action.equals("cordovaStartVuforia")) {
            ACTION = action;
            ARGS = args;

            String targetFile = args.getString(0);
            String targets = args.getJSONArray(1).toString();
            String overlayText = (args.isNull(2)) ? null : args.getString(2);
            String vuforiaLicense = args.getString(3);

            Log.d(LOGTAG, "Args: "+args);
            Log.d(LOGTAG, "Text: "+overlayText);
            Log.d(LOGTAG, "License: "+vuforiaLicense);

            Context context =  cordova.getActivity().getApplicationContext();

            Intent intent = new Intent(context, ImageTargets.class);
            intent.putExtra("IMAGE_TARGET_FILE", targetFile);
            intent.putExtra("IMAGE_TARGETS", targets);
            if(overlayText != null)
                intent.putExtra("OVERLAY_TEXT", overlayText);
            intent.putExtra("LICENSE_KEY", vuforiaLicense);

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
        else if(action.equals("cordovaStopVuforia")) {
            JSONObject json = new JSONObject();

            if(vuforiaStarted) {
                Log.d(LOGTAG, "Stopping plugin");

                json.put("success", "true");
            }
            else {
                Log.d(LOGTAG, "Cannot stop the plugin because it wasn't started");
                json.put("success", "false");
                json.put("message", "No Vuforia session running");
            }

            callback.sendPluginResult(new PluginResult(PluginResult.Status.OK, json));

            if(vuforiaStarted) {
                Intent dismissIntent = new Intent(PLUGIN_ACTION);
                dismissIntent.putExtra(PLUGIN_ACTION, DISMISS_ACTION);

                this.cordova.getActivity().sendBroadcast(dismissIntent);
                vuforiaStarted = false;
            }
        }

        return true;
    }

    public void onRequestPermissionResult(int requestCode, String[] permissions, int[] grantResults) throws JSONException {
        for(int r:grantResults) {
            if(r == PackageManager.PERMISSION_DENIED) {
                this.callback.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "CAMERA_PERMISSION_ERROR"));
                return;
            }
        }
        switch(requestCode) {
            case CAPTURE_VIDEO_ACTIVITY_REQUEST_CODE:
                execute(ACTION, ARGS, this.callback);
                break;
        }

    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        String name;

        if (data == null) {
            name = "ERROR";
        }
        else {
            name = data.getStringExtra("name");
        }

        Log.d(LOGTAG, "Plugin Received: '" + name + "' from Vuforia.");

        // Check which request we're responding to
        if (requestCode == IMAGE_REC_REQUEST) {
            // Make sure the request was successful
            if (resultCode == 0) {
                try {
                    JSONObject json = new JSONObject();
                    json.put("imageName", name);
                    callback.sendPluginResult(new PluginResult(PluginResult.Status.OK, json));
                }
                catch( JSONException e ) {
                    Log.d(LOGTAG, "JSON ERROR: " + e);
                }
            }
            else {
                Log.d(LOGTAG, "Error - received code: " + resultCode);
            }
        }
        vuforiaStarted = false;
    }
}
