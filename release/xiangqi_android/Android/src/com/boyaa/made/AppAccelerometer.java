package com.boyaa.made;

import android.content.Context;
import android.content.res.Configuration;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;

/**
 * 
 * This class is used for controlling the Accelerometer
 * 
 */
public class AppAccelerometer implements SensorEventListener {

	private static final String TAG = "AppAccelerometer";
	private Context mContext;
	private SensorManager mSensorManager;
	private Sensor mAccelerometer;

	public AppAccelerometer(Context context) {
		mContext = context;

		mSensorManager = null;
		mAccelerometer = null;

		// Get an instance of the SensorManager
		// mSensorManager = (SensorManager)
		// mContext.getSystemService(Context.SENSOR_SERVICE);
		// mAccelerometer =
		// mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
	}

	public void enable() {
		if (null != mSensorManager) {
			mSensorManager.registerListener(this, mAccelerometer, SensorManager.SENSOR_DELAY_GAME);
		}
	}

	public void disable() {
		if (null != mSensorManager) {
			mSensorManager.unregisterListener(this);
		}
	}

	@Override
	public void onSensorChanged(SensorEvent event) {

		if (event.sensor.getType() != Sensor.TYPE_ACCELEROMETER) {
			return;
		}

		float x = event.values[0];
		float y = event.values[1];
		float z = event.values[2];

		/*
		 * Because the axes are not swapped when the device's screen orientation
		 * changes. So we should swap it here.
		 */
		int orientation = mContext.getResources().getConfiguration().orientation;
		if (orientation == Configuration.ORIENTATION_LANDSCAPE) {
			float tmp = x;
			x = -y;
			y = tmp;
		}

		onSensorChanged(x, y, z, event.timestamp);
		// Log.d(TAG, "x = " + event.values[0] + " y = " + event.values[1] +
		// " z = " + event.values[2]);
	}

	@Override
	public void onAccuracyChanged(Sensor sensor, int accuracy) {
	}

	// c native function
	private static native void onSensorChanged(float x, float y, float z, long timeStamp);
}
