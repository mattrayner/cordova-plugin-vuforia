/*===============================================================================
Copyright (c) 2012-2014 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of QUALCOMM Incorporated, registered in the United States
and other countries. Trademarks of QUALCOMM Incorporated are used with permission.
===============================================================================*/

package com.mattrayner.vuforia.app;

import java.util.ArrayList;
import java.util.Vector;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.BroadcastReceiver;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.GestureDetector;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup.LayoutParams;
import android.view.Window;
import android.view.WindowManager;
import android.widget.CheckBox;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.ImageView;
import android.widget.Button;
import android.widget.Toast;
//import android.R;
//import com.example.hello.R;

import com.qualcomm.vuforia.CameraDevice;
import com.qualcomm.vuforia.DataSet;
import com.qualcomm.vuforia.ObjectTracker;
import com.qualcomm.vuforia.State;
import com.qualcomm.vuforia.STORAGE_TYPE;
import com.qualcomm.vuforia.Trackable;
import com.qualcomm.vuforia.Tracker;
import com.qualcomm.vuforia.TrackerManager;
import com.qualcomm.vuforia.Vuforia;
import com.mattrayner.vuforia.app.ApplicationControl;
import com.mattrayner.vuforia.app.ApplicationException;
import com.mattrayner.vuforia.app.ApplicationSession;
import com.mattrayner.vuforia.app.utils.LoadingDialogHandler;
import com.mattrayner.vuforia.app.utils.ApplicationGLView;
import com.mattrayner.vuforia.app.utils.Texture;

import com.mattrayner.vuforia.VuforiaPlugin;

public class ImageTargets extends Activity implements ApplicationControl
{
    private static final String LOGTAG = "ImageTargets";
    private static final String FILE_PROTOCOL = "file://";

    ApplicationSession vuforiaAppSession;

    private DataSet mCurrentDataset;
    private int mCurrentDatasetSelectionIndex = 0;
    private int mStartDatasetsIndex = 0;
    private int mDatasetsNumber = 0;
    private ArrayList<String> mDatasetStrings = new ArrayList<String>();

    // Our OpenGL view:
    private ApplicationGLView mGlView;

    // Our renderer:
    private ImageTargetRenderer mRenderer;

    private GestureDetector mGestureDetector;

    // The textures we will use for rendering:
    private Vector<Texture> mTextures;

    private boolean mSwitchDatasetAsap = false;
    private boolean mFlash = false;
    private boolean mContAutofocus = false;
    private boolean mExtendedTracking = false;

    private View mFlashOptionView;

    private RelativeLayout mUILayout;

    private ActionReceiver vuforiaActionReceiver;

    LoadingDialogHandler loadingDialogHandler = new LoadingDialogHandler(this);

    // Alert Dialog used to display SDK errors
    private AlertDialog mErrorDialog;

    boolean mIsDroidDevice = false;

    // Array of target names
    String mTargets;

    // Overlay message string
    String mOverlayMessage;

    // Display button boolean
    Boolean mDisplayCloseButton;

    // Display devices icon image
    Boolean mDisplayDevicesIcon;

    // Stop the activity
    Boolean mAutostopOnImageFound;

    // Vuforia license key
    String mLicenseKey;

    private class ActionReceiver extends BroadcastReceiver {

        @Override
        public void onReceive(Context ctx, Intent intent) {
            String receivedAction = intent.getExtras().getString(VuforiaPlugin.PLUGIN_ACTION);

            if (receivedAction.equals(VuforiaPlugin.DISMISS_ACTION)) {
                doFinish();
            }else if(receivedAction.equals(VuforiaPlugin.PAUSE_ACTION)){
                doStopTrackers();
            }else if(receivedAction.equals(VuforiaPlugin.RESUME_ACTION)){
                doStartTrackers();
            }else if(receivedAction.equals(VuforiaPlugin.UPDATE_TARGETS_ACTION)){
                String targets = intent.getStringExtra("ACTION_DATA");
                doUpdateTargets(targets);
            }
        }
    }


    // Called when the activity first starts or the user navigates back to an
    // activity.
    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        Log.d(LOGTAG, "onCreate");
        super.onCreate(savedInstanceState);

        //Remove title bar
        this.requestWindowFeature(Window.FEATURE_NO_TITLE);

        //Remove notification bar
        this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);

        //Force Landscape
        this.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);

        //Grab a reference to our Intent so that we can get the extra data passed into it
        Intent intent = getIntent();

        //Get the vuoria license key that was passed into the plugin
        mLicenseKey = intent.getStringExtra("LICENSE_KEY");

        try {
            vuforiaAppSession = new ApplicationSession(this, mLicenseKey);
        } catch(Exception e) {
            Intent mIntent = new Intent();
            mIntent.putExtra("name", "VUFORIA ERROR");
            setResult(VuforiaPlugin.ERROR_RESULT, mIntent);
            finish();
        }

        //Get the passed in targets file
        String target_file = intent.getStringExtra("IMAGE_TARGET_FILE");
        mTargets = intent.getStringExtra("IMAGE_TARGETS");
        mOverlayMessage = intent.getStringExtra("OVERLAY_TEXT");
        mDisplayCloseButton = intent.getBooleanExtra("DISPLAY_CLOSE_BUTTON", true);
        mDisplayDevicesIcon = intent.getBooleanExtra("DISPLAY_DEVICES_ICON", true);
        mAutostopOnImageFound = intent.getBooleanExtra("STOP_AFTER_IMAGE_FOUND", true);

        startLoadingAnimation();

        Log.d(LOGTAG, "MRAY :: VUFORIA RECEIVED FILE: " + target_file);
        Log.d(LOGTAG, "MRAY :: VUTORIA TARGETS: " + mTargets);
        Log.d(LOGTAG, "MRAY :: OVERLAY MESSAGE: " + mOverlayMessage);
        mDatasetStrings.add(target_file);

        vuforiaAppSession
            .initAR(this, ActivityInfo.SCREEN_ORIENTATION_FULL_SENSOR);

        mGestureDetector = new GestureDetector(this, new GestureListener());

        // Load any sample specific textures:
        mTextures = new Vector<Texture>();

        mIsDroidDevice = android.os.Build.MODEL.toLowerCase().startsWith(
            "droid");

    }

    // Process Single Tap event to trigger autofocus
    private class GestureListener extends
        GestureDetector.SimpleOnGestureListener {
        // Used to set autofocus one second after a manual focus is triggered
        private final Handler autofocusHandler = new Handler();


        @Override
        public boolean onDown(MotionEvent e) {
            return true;
        }


        @Override
        public boolean onSingleTapUp(MotionEvent e) {
            // Generates a Handler to trigger autofocus
            // after 1 second
            autofocusHandler.postDelayed(new Runnable() {
                public void run() {
                    boolean result = CameraDevice.getInstance().setFocusMode(
                            CameraDevice.FOCUS_MODE.FOCUS_MODE_TRIGGERAUTO);

                    if (!result)
                        Log.e("SingleTapUp", "Unable to trigger focus");
                }
            }, 1000L);

            return true;
        }
    }


    @Override
    protected void onStart()
    {
        if (vuforiaActionReceiver == null) {
            vuforiaActionReceiver = new ActionReceiver();
        }

        IntentFilter intentFilter = new IntentFilter(VuforiaPlugin.PLUGIN_ACTION);
        registerReceiver(vuforiaActionReceiver, intentFilter);

        Log.d(LOGTAG, "onStart");
        super.onStart();
    }

    @Override
    protected void onStop()
    {
        if (vuforiaActionReceiver != null) {
            unregisterReceiver(vuforiaActionReceiver);
        }
        Log.d(LOGTAG, "onStop");
        super.onStop();

    }

    // Called when the activity will start interacting with the user.
    @Override
    protected void onResume()
    {
        Log.d(LOGTAG, "onResume");
        super.onResume();

        // This is needed for some Droid devices to force landscape
        if (mIsDroidDevice)
        {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
        }

        try
        {
            vuforiaAppSession.resumeAR();
        } catch (ApplicationException e)
        {
            Log.e(LOGTAG, e.getString());
        }

        // Resume the GL view:
        if (mGlView != null)
        {
            mGlView.setVisibility(View.VISIBLE);
            mGlView.onResume();
        }

    }


    // Callback for configuration changes the activity handles itself
    @Override
    public void onConfigurationChanged(Configuration config)
    {
        Log.d(LOGTAG, "onConfigurationChanged");
        super.onConfigurationChanged(config);

        vuforiaAppSession.onConfigurationChanged();
    }


    // Called when the system is about to start resuming a previous activity.
    @Override
    protected void onPause()
    {
        Log.d(LOGTAG, "onPause");
        super.onPause();

        if (mGlView != null)
        {
            mGlView.setVisibility(View.INVISIBLE);
            mGlView.onPause();
        }

        // Turn off the flash
        if (mFlashOptionView != null && mFlash)
        {
            // OnCheckedChangeListener is called upon changing the checked state
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1)
            {
                ((Switch) mFlashOptionView).setChecked(false);
            } else
            {
                ((CheckBox) mFlashOptionView).setChecked(false);
            }
        }

        try
        {
            vuforiaAppSession.pauseAR();
        } catch (ApplicationException e)
        {
            Log.e(LOGTAG, e.getString());
        }
    }


    // The final call you receive before your activity is destroyed.
    @Override
    protected void onDestroy()
    {
        Log.d(LOGTAG, "onDestroy");
        super.onDestroy();

        try
        {
            vuforiaAppSession.stopAR();
        } catch (ApplicationException e)
        {
            Log.e(LOGTAG, e.getString());
        }

        // Unload texture:
        mTextures.clear();
        mTextures = null;

        System.gc();
    }


    // Initializes AR application components.
    private void initApplicationAR()
    {
        // Create OpenGL ES view:
        int depthSize = 16;
        int stencilSize = 0;
        boolean translucent = Vuforia.requiresAlpha();

        mGlView = new ApplicationGLView(this);
        mGlView.init(translucent, depthSize, stencilSize);

        mRenderer = new ImageTargetRenderer(this, vuforiaAppSession, mTargets);
        mGlView.setRenderer(mRenderer);

    }


    private void startLoadingAnimation()
    {
        // Get the project's package name and a reference to it's resources
        String package_name = getApplication().getPackageName();
        Resources resources = getApplication().getResources();

        LayoutInflater inflater = LayoutInflater.from(this);

        mUILayout = (RelativeLayout) inflater.inflate(resources.getIdentifier("camera_overlay", "layout", package_name),
            null, false);

        mUILayout.setVisibility(View.VISIBLE);
        mUILayout.setBackgroundColor(Color.BLACK);

        // Gets a reference to the loading dialog
        loadingDialogHandler.mLoadingDialogContainer = mUILayout
            .findViewById(resources.getIdentifier("loading_indicator", "id", package_name));

        // Shows the loading indicator at start
        loadingDialogHandler
            .sendEmptyMessage(LoadingDialogHandler.SHOW_LOADING_DIALOG);

        // Gets a reference to the overlay text
        TextView overlayText = (TextView) mUILayout.findViewById(resources.getIdentifier("overlay_message_top", "id", package_name));

        Log.d(LOGTAG, "Overlay Text: "+mOverlayMessage);

        // Hide the close button if needed
        Button closeButton = (Button) mUILayout.findViewById(resources.getIdentifier("close_button_top", "id", package_name));
        if(!mDisplayCloseButton)
            closeButton.setVisibility(View.GONE);

        ImageView devicesIconImage = (ImageView) mUILayout.findViewById(resources.getIdentifier("devices_icon_top", "id", package_name));

        if(!mDisplayDevicesIcon)
            devicesIconImage.setVisibility(View.GONE);
        // Updates the overlay message with the text passed-in
        overlayText.setText(mOverlayMessage);

        // If the message doesn't exist/is empty, set the black overlay container to be nearly transparent.
        LinearLayout overlayContainer = (LinearLayout) mUILayout.findViewById(resources.getIdentifier("layout_top", "id", package_name));
        if(overlayText == null || overlayText.getText().equals("")) {
            overlayContainer.setBackgroundColor(Color.parseColor("#00000000"));
        }

        // Adds the inflated layout to the view
        addContentView(mUILayout, new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));
    }


    // Methods to load and destroy tracking data.
    @Override
    public boolean doLoadTrackersData()
    {
        TrackerManager tManager = TrackerManager.getInstance();
        ObjectTracker objectTracker = (ObjectTracker) tManager
            .getTracker(ObjectTracker.getClassType());
        if (objectTracker == null)
            return false;

        if (mCurrentDataset == null)
            mCurrentDataset = objectTracker.createDataSet();

        if (mCurrentDataset == null)
            return false;

        //Determine the storage type.
        int storage_type;
        String dataFile = mDatasetStrings.get(mCurrentDatasetSelectionIndex);

        if(dataFile.startsWith(FILE_PROTOCOL)){
            storage_type = STORAGE_TYPE.STORAGE_ABSOLUTE;
            dataFile = dataFile.substring(FILE_PROTOCOL.length(), dataFile.length());
            mDatasetStrings.set(mCurrentDatasetSelectionIndex, dataFile);
            Log.d(LOGTAG, "Reading the absolute path: " + dataFile);
        }else{
            storage_type = STORAGE_TYPE.STORAGE_APPRESOURCE;
            Log.d(LOGTAG, "Reading the path " + dataFile + " from the assets folder.");
        }

        if (!mCurrentDataset.load(
            mDatasetStrings.get(mCurrentDatasetSelectionIndex), storage_type))
            return false;


        if (!objectTracker.activateDataSet(mCurrentDataset))
            return false;

        int numTrackables = mCurrentDataset.getNumTrackables();
        for (int count = 0; count < numTrackables; count++)
        {
            Trackable trackable = mCurrentDataset.getTrackable(count);
            if(isExtendedTrackingActive())
            {
                trackable.startExtendedTracking();
            }

            String obj_name = trackable.getName();

            String name = "Current Dataset : " + obj_name;
            trackable.setUserData(name);
            Log.d(LOGTAG, "UserData:Set the following user data "
                + (String) trackable.getUserData());
        }

        return true;
    }


    @Override
    public boolean doUnloadTrackersData()
    {
        // Indicate if the trackers were unloaded correctly
        boolean result = true;

        TrackerManager tManager = TrackerManager.getInstance();
        ObjectTracker objectTracker = (ObjectTracker) tManager
            .getTracker(ObjectTracker.getClassType());
        if (objectTracker == null)
            return false;

        if (mCurrentDataset != null && mCurrentDataset.isActive())
        {
            if (objectTracker.getActiveDataSet().equals(mCurrentDataset)
                && !objectTracker.deactivateDataSet(mCurrentDataset))
            {
                result = false;
            } else if (!objectTracker.destroyDataSet(mCurrentDataset))
            {
                result = false;
            }

            mCurrentDataset = null;
        }

        return result;
    }


    @Override
    public void onInitARDone(ApplicationException exception)
    {

        if (exception == null)
        {
            initApplicationAR();

            mRenderer.mIsActive = true;

            // Now add the GL surface view. It is important
            // that the OpenGL ES surface view gets added
            // BEFORE the camera is started and video
            // background is configured.
            addContentView(mGlView, new LayoutParams(LayoutParams.MATCH_PARENT,
                LayoutParams.MATCH_PARENT));

            // Sets the UILayout to be drawn in front of the camera
            mUILayout.bringToFront();

            // Sets the layout background to transparent
            mUILayout.setBackgroundColor(Color.TRANSPARENT);

            try
            {
                vuforiaAppSession.startAR(CameraDevice.CAMERA.CAMERA_DEFAULT);
            } catch (ApplicationException e)
            {
                Log.e(LOGTAG, e.getString());
            }

            boolean result = CameraDevice.getInstance().setFocusMode(
                CameraDevice.FOCUS_MODE.FOCUS_MODE_CONTINUOUSAUTO);

            if (result)
                mContAutofocus = true;
            else
                Log.e(LOGTAG, "Unable to enable continuous autofocus");

        } else
        {
            Log.e(LOGTAG, exception.getString());
            showInitializationErrorMessage(exception.getString());
        }
    }


    // Shows initialization error messages as System dialogs
    public void showInitializationErrorMessage(String message)
    {
        final String errorMessage = message;
        runOnUiThread(new Runnable()
        {
            public void run()
            {
                if (mErrorDialog != null)
                {
                    mErrorDialog.dismiss();
                }

                String package_name = getApplication().getPackageName();
                Resources resources = getApplication().getResources();

                // Generates an Alert Dialog to show the error message
                AlertDialog.Builder builder = new AlertDialog.Builder(
                    ImageTargets.this);
                builder
                    .setMessage(errorMessage)
                    .setTitle("Error")
                    .setCancelable(false)
                    .setIcon(0)
                    .setPositiveButton(resources.getIdentifier("button_OK", "string", package_name),
                        new DialogInterface.OnClickListener()
                        {
                            public void onClick(DialogInterface dialog, int id)
                            {
                                finish();
                            }
                        });

                mErrorDialog = builder.create();
                mErrorDialog.show();
            }
        });
    }


    @Override
    public void onQCARUpdate(State state)
    {
        if (mSwitchDatasetAsap)
        {
            mSwitchDatasetAsap = false;
            TrackerManager tm = TrackerManager.getInstance();
            ObjectTracker ot = (ObjectTracker) tm.getTracker(ObjectTracker
                .getClassType());
            if (ot == null || mCurrentDataset == null
                || ot.getActiveDataSet() == null)
            {
                Log.d(LOGTAG, "Failed to swap datasets");
                return;
            }

            doUnloadTrackersData();
            doLoadTrackersData();
        }
    }


    @Override
    public boolean doInitTrackers()
    {
        // Indicate if the trackers were initialized correctly
        boolean result = true;

        TrackerManager tManager = TrackerManager.getInstance();
        Tracker tracker;

        // Trying to initialize the image tracker
        tracker = tManager.initTracker(ObjectTracker.getClassType());
        if (tracker == null)
        {
            Log.e(
                LOGTAG,
                "Tracker not initialized. Tracker already initialized or the camera is already started");
            result = false;
        } else
        {
            Log.i(LOGTAG, "Tracker successfully initialized");
        }
        return result;
    }


    @Override
    public boolean doStartTrackers()
    {
        // Indicate if the trackers were started correctly
        boolean result = true;

        Tracker objectTracker = TrackerManager.getInstance().getTracker(
            ObjectTracker.getClassType());
        if (objectTracker != null)
            objectTracker.start();

        return result;
    }


    @Override
    public boolean doStopTrackers()
    {
        // Indicate if the trackers were stopped correctly
        boolean result = true;

        Tracker objectTracker = TrackerManager.getInstance().getTracker(
            ObjectTracker.getClassType());
        if (objectTracker != null)
            objectTracker.stop();

        return result;
    }


    @Override
    public boolean doDeinitTrackers()
    {
        // Indicate if the trackers were deinitialized correctly
        boolean result = true;

        TrackerManager tManager = TrackerManager.getInstance();
        tManager.deinitTracker(ObjectTracker.getClassType());

        return result;
    }


    @Override
    public boolean onTouchEvent(MotionEvent event)
    {
        return mGestureDetector.onTouchEvent(event);
    }


    boolean isExtendedTrackingActive()
    {
        return mExtendedTracking;
    }

    final public static int CMD_BACK = -1;
    final public static int CMD_EXTENDED_TRACKING = 1;
    final public static int CMD_AUTOFOCUS = 2;
    final public static int CMD_FLASH = 3;
    final public static int CMD_CAMERA_FRONT = 4;
    final public static int CMD_CAMERA_REAR = 5;
    final public static int CMD_DATASET_START_INDEX = 6;

    private void showToast(String text)
    {
        Toast.makeText(this, text, Toast.LENGTH_SHORT).show();
    }

    @Override
    public void onBackPressed() {
        Intent mIntent = new Intent();
        mIntent.putExtra("name", "CLOSED");
        setResult(VuforiaPlugin.MANUAL_CLOSE_RESULT, mIntent);
        super.onBackPressed();
    }

    public void doFinish() {
        Intent mIntent = new Intent();
        setResult(VuforiaPlugin.NO_RESULT, mIntent);
        super.onBackPressed();
    }

    public void handleCloseButton(View view){
        onBackPressed();
    }

    public void imageFound(String imageName) {
        Context context =  this.getApplicationContext();
        Intent resultIntent = new Intent();
        resultIntent.putExtra("name", imageName);

        this.setResult(0, resultIntent);

        doStopTrackers();

        Log.d(LOGTAG, "mAuto Stop On Image Found: " + mAutostopOnImageFound);

        if(mAutostopOnImageFound) {
            this.finish();
        } else {
            Log.d(LOGTAG, "Sending repeat callback");

            VuforiaPlugin.sendImageFoundUpdate(imageName);
        }
    }

    public void doUpdateTargets(String targets) {
        mTargets = targets;

        mRenderer.updateTargetStrings(mTargets);
    }
}
