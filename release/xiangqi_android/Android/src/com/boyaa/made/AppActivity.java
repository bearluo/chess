package com.boyaa.made;

import java.io.File;
import java.util.Locale;
import java.util.UUID;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.KeyguardManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.res.Configuration;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.os.Process;
import android.telephony.PhoneStateListener;
import android.telephony.SignalStrength;
import android.telephony.TelephonyManager;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.entity.update.ApkInstall;
import com.boyaa.util.NetworkUtil;

public class AppActivity extends Activity {

	public AppGLSurfaceView mGLView = null;
	public int mWidth = 0;
	public int mHeight = 0;

	private AppEditBoxDialog mEdit = null;
	private String mImagePath = "";
	private String mAudioPath = "";
	public static AppActivity mActivity = null;
	public static String appPackageResourcePath = null;
	private static AppMusic mBackgroundMusicPlayer = null;
	private static AppSound mSoundPlayer = null;
	private static AppAccelerometer mAccelerometer = null;
	private static boolean mAccelerometerEnabled = false;
	private static Handler mHandler = null;
	private static NetworkType mNetworkType = null;

	public final static int BACKGROUND_MAX_MS = 10 * 60 * 1000;
//	public final static int BACKGROUND_MAX_MS = 10* 1000;

	private final static int HANDLER_SHOW_DIALOG = 0;
	private final static int HANDLER_SHOW_EDIT = 1;
	public final static int HANDLER_OPENGL_NOT_SUPPORT = 2;
	public final static int HANDLER_BACKGROUND_REMAIN = 3;
	public final static int HANDLER_HTTPPOST_TIMEOUT = 4;
	public final static int HANDLER_HTTPGET_UPDATE_TIMEOUT = 5;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		Log.e("lua","onCreate");
	}
	
	@Override
	public void onConfigurationChanged(Configuration newConfig) {
		// TODO Auto-generated method stub
		super.onConfigurationChanged(newConfig);
		Log.e("lua","onConfigurationChanged");
	}
	
	public boolean CreateApp(View layout, View glSurfaceview) {
		mActivity = this;
		appPackageResourcePath = getPackageResourcePath();
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
//		KeyguardManager mKeyguardManager = (KeyguardManager) getSystemService(KEYGUARD_SERVICE);
//		if (mKeyguardManager.inKeyguardRestrictedInputMode()) {
//			return false;
//		}
		
//		DisplayMetrics metrics = new DisplayMetrics();
//		if (Build.VERSION.SDK_INT >= 17){
//			getWindowManager().getDefaultDisplay().getRealMetrics(metrics);
//		}else{
//			getWindowManager().getDefaultDisplay().getMetrics(metrics);
//		}
//		
//		mWidth = metrics.widthPixels;
//		mHeight = metrics.heightPixels;

		mAccelerometer = new AppAccelerometer(this);
		mBackgroundMusicPlayer = new AppMusic();
		mSoundPlayer = new AppSound();
		AppBitmap.setContext(this);

		mEdit = null;
		
		setContentView(layout);
		mGLView = (AppGLSurfaceView) glSurfaceview;
		mGLView.requestFocus();

		mHandler = new AppHandler();

		mNetworkType = new NetworkType(this);
		return true;
	}

	public void OnSetEnv()
	{		
		String strPackageName = getPackageName();
		FileUtil.initFile(this, strPackageName);
		ApplicationInfo appInfo = null;
		PackageInfo packInfo = null;
		PackageManager packMgmr = getApplication().getPackageManager();
		try {
			appInfo = packMgmr.getApplicationInfo(strPackageName, 0);
			packInfo = packMgmr.getPackageInfo(strPackageName, 0);
		} catch (NameNotFoundException e) {
			
		}
		int versionCode = packInfo.versionCode;
		String versionName = packInfo.versionName;
		String apkFilePath = appInfo.sourceDir;
		String libraryPath = getApplicationInfo().dataDir + "/lib";
		String strFilePath = getApplication().getFilesDir().toString();
		String strSDPath = Environment.getExternalStorageDirectory().getAbsolutePath();
		String strLang = Locale.getDefault().getLanguage();
		String strCountry = Locale.getDefault().getCountry();
        String uuid = UUID.randomUUID().toString();		
		String deviceId = "";
		String imsi = "";
		String imei = "";
		String iccid = "";
		String phoneNumber = "";
		TelephonyManager telephonyManager = (TelephonyManager) AppActivity.mActivity.getApplication().getSystemService(Context.TELEPHONY_SERVICE);
		if (null != telephonyManager) {
			deviceId = telephonyManager.getDeviceId();
			phoneNumber = telephonyManager.getLine1Number();
			imsi = telephonyManager.getSubscriberId();
			imei = telephonyManager.getDeviceId();
			iccid = telephonyManager.getSimSerialNumber();
		}
		
//		String cache = getApplicationInfo().dataDir + "/cache";
		File cacheDir = this.getCacheDir();
		String cache = "";
		if( cacheDir != null ) {
			cache = cacheDir.getAbsolutePath();
		}
		
		String rootPath=Environment.getExternalStorageDirectory().getPath()+"/."+getPackageName();
		String androidId = android.provider.Settings.Secure.getString(AppActivity.mActivity.getContentResolver(), android.provider.Settings.Secure.ANDROID_ID);
		String phoneModel = android.os.Build.MODEL;

		dict_set_int("android_app_info","version_code",versionCode);
		dict_set_string("android_app_info","version_name",versionName);
		dict_set_string("android_app_info","packages",strPackageName);
		dict_set_string("android_app_info","apk_path",apkFilePath);
		dict_set_string("android_app_info","lib_path",libraryPath);
		dict_set_string("android_app_info","files_path",strFilePath);
		dict_set_string("android_app_info","sd_path",strSDPath);
		dict_set_string("android_app_info","lang",strLang);
		dict_set_string("android_app_info","country",strCountry);
		dict_set_string("android_app_info","uuid",uuid);
		dict_set_string("android_app_info","device_id",deviceId);
		dict_set_string("android_app_info","cache",cache);
		dict_set_string("android_app_info","rootPath",rootPath);
		dict_set_string("android_app_info","imsi",imsi);
		dict_set_string("android_app_info","imei",imei);
		dict_set_string("android_app_info","iccid",iccid);
		dict_set_string("android_app_info","phoneNumber",phoneNumber);
		dict_set_string("android_app_info","androidId",androidId);
		dict_set_string("android_app_info","phoneModel",phoneModel);
		String packageName = Game.mActivity.getPackageName();
		String userDirPath = strSDPath + File.separator + "." + packageName + File.separator + "user";
		dict_set_string("android_storage_user", "path", userDirPath);

		AppActivity.sys_set_int("android_log_extract_file",1);
		clearAllExternalStorageWhenInstall();
		//System.gc();
	}
	
	/**
	 * android下每次apk升级安装后第一次运行，清除旧版本apk在external storage上的目录.
	 */
	private void clearAllExternalStorageWhenInstall() {
		
		sysSetInt("clear_cache_update_when_app_install",1);
		
		sysSetInt("clear_storage_scripts_when_app_install",1);
//		sysSetInt("clear_storage_images_when_app_install",1);
		sysSetInt("clear_storage_audio_when_app_install",1);
		sysSetInt("clear_storage_fonts_when_app_install",1);
		sysSetInt("clear_storage_xml_when_app_install",1);
//		sysSetInt("clear_storage_dic_when_app_install",1);
//		sysSetInt("clear_storage_log_when_app_install",1);
		sysSetInt("clear_storage_temp_when_app_install",1);
		sysSetInt("clear_storage_user_when_app_install",1);
		
	}

	// 所有在UI线程中调用c接口的,都需要使用此函数将调用放入到render线程执行
	public void runOnLuaThread(Runnable ra) {
		if (null != mGLView) {
			mGLView.queueEvent(ra);
		}else{
			Log.e("lua", "mGLView is null");
		}
	}

	// 本函数是在Lua的event_load之前被执行,是在Lua线程被调用
	// 重载本函数,调用AppActivity.sys_set_xxx或dict_set_xxx
	protected void OnBeforeLuaLoad()
{
		Log.e("lua","OnBeforeLuaLoad");
		mImagePath = sys_get_string("storage_images");
		if ( null != mImagePath && mImagePath.length() > 0 )
		{
			mImagePath += File.separator;
		}
		
		mAudioPath = sys_get_string("storage_audio");
		if ( null != mAudioPath && mAudioPath.length() > 0 )
		{
			mAudioPath += File.separator;
		}
	}

	public String getImagePath()
	{
		return mImagePath;
	}
	public String getAudioPath()
	{
		return mAudioPath;
	}
	// 本函数是响应Lua的call_native("OnLuaCall");
	// 重载本函数,响应Lua的调用
	protected void OnLuaCall() {

	}

	@Override
	protected void onResume() {
		Log.e("lua","onResume");
		super.onResume();
		if(null != mHandler){			
//			mHandler.removeMessages(HANDLER_BACKGROUND_REMAIN);
		}

		if (null != mNetworkType) {
			mNetworkType.onResume();
		}
		if (null != mAccelerometer) {
			if (mAccelerometerEnabled) {
				mAccelerometer.enable();
			}
		}

		if (null != mGLView) {
			mGLView.onResume();
		}
	}

	@Override
	protected void onPause() {
		Log.e("lua","onPause");
		super.onPause();
		if(null != mHandler){			
//			mHandler.sendEmptyMessageDelayed(HANDLER_BACKGROUND_REMAIN, BACKGROUND_MAX_MS);
		}

		if (null != mNetworkType) {
			mNetworkType.onPause();
		}

		if (null != mAccelerometer) {
			if (mAccelerometerEnabled) {
				mAccelerometer.disable();
			}
		}
		if (null != mGLView) {
			mGLView.onPause();
		}
	}
	@Override
	protected void onStart() {
		// TODO Auto-generated method stub
		Log.e("lua","onStart");
		super.onStart();
	}
	
	@Override
	protected void onStop() {
		// TODO Auto-generated method stub
		Log.e("lua","onStop");
		super.onStop();
	}
	
	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		Log.e("lua","onDestroy");
		super.onDestroy();
	}
	
	public static Handler getHandler() {
		return mHandler;
	}

	protected void showDialog(String title, String message) {
		Dialog dialog = new AlertDialog.Builder(this).setTitle(title).setMessage(message).setPositiveButton("Ok", new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int whichButton) {

			}
		}).create();

		dialog.show();

	}

	// lua <---> java
	public static int sys_set_int(String strKey, int iValue) {
		if (false == checkThread()) {
			return -1;
		}
		return sysSetInt(strKey, iValue);
	}

	public static int sys_set_double(String strKey, double fValue) {
		if (false == checkThread()) {
			return -1;
		}
		return sysSetDouble(strKey, fValue);
	}

	public static int sys_set_string(String strKey, String strValue) {
		if (false == checkThread()) {
			return -1;
		}
		return sysSetString(strKey, strValue);
	}

	public static int sys_get_int(String strKey, int iDefaultValue) {
		if (false == checkThread()) {
			return iDefaultValue;
		}
		return sysGetInt(strKey, iDefaultValue);
	}

	public static double sys_get_double(String strKey, double fDefaultValue) {
		if (false == checkThread()) {
			return fDefaultValue;
		}
		return sysGetDouble(strKey, fDefaultValue);
	}

	public static String sys_get_string(String strKey) {
		if (false == checkThread()) {
			return null;
		}
		return sysGetString(strKey);

	}

	public static int dict_set_int(String strDictName, String strKey, int iValue) {
		if (false == checkThread()) {
			return -1;
		}
		return dictSetInt(strDictName, strKey, iValue);
	}

	public static int dict_set_double(String strDictName, String strKey, double fValue) {
		if (false == checkThread()) {
			return -1;
		}
		return dictSetDouble(strDictName, strKey, fValue);
	}

	public static int dict_set_string(String strDictName, String strKey, String strValue) {
		if (false == checkThread()) {
			return -1;
		}
		if ( null == strValue || 0 == strValue.length()){
			return dictSetString(strDictName, strKey, null); 
		}
		byte[] barr = strValue.getBytes();
		return dictSetString(strDictName, strKey, barr);
	}

	public static int dict_get_int(String strDictName, String strKey, int iDefaultValue) {
		if (false == checkThread()) {
			return iDefaultValue;
		}
		return dictGetInt(strDictName, strKey, iDefaultValue);
	}

	public static double dict_get_double(String strDictName, String strKey, double fDefaultValue) {
		if (false == checkThread()) {
			return fDefaultValue;
		}
		return dictGetDouble(strDictName, strKey, fDefaultValue);
	}

	public static String dict_get_string(String strDictName, String strKey) {
		if (false == checkThread()) {
			return null;
		}
		byte[] barr =  dictGetString(strDictName, strKey);
		if ( null == barr || 0 == barr.length ) return "";
		return new String(barr);
	}

	public static int dict_delete(String strDictName) {
		if (false == checkThread()) {
			return -1;
		}
		return dictDelete(strDictName);
	}

	public static int call_lua(String strFunctionName) {
		if (false == checkThread()) {
			return -1;
		}
		return callLua(strFunctionName);
	}

	public static boolean checkThread(){
		if ( AppActivity.mActivity.mGLView.isGLThread())
		{
			return true;
		}
			return false;
		}
	
	// call by c function
	public static void openIMEEdit(byte[] textArray, byte[] titleArray, int inputMode, int inputFlag, int returnType, int maxLength) {

		Message msg = new Message();
		msg.what = HANDLER_SHOW_EDIT;
		String content = "";
		String title = "";
		if ( null != textArray && textArray.length > 0 )
		{
			content = new String(textArray);
		}
		if ( null != titleArray && titleArray.length > 0 )
		{
			title = new String(titleArray);
		}		
		inputMode = AppEditBoxDialog.kEditBoxInputModeSingleLine;
		inputFlag = AppEditBoxDialog.kEditBoxInputFlagSensitive;
		returnType = AppEditBoxDialog.kKeyboardReturnTypeDone;
		msg.obj = new EditBoxMessage(title, content, inputMode, inputFlag, returnType, maxLength);
		mHandler.sendMessage(msg);
	}
	public static void closeIMEEdit()
	{
		if ( null != AppActivity.mActivity.mEdit )
		{
			//Dismiss this dialog, removing it from the screen. This method can be invoked safely from any thread. 
			AppActivity.mActivity.mEdit.close();
			AppActivity.mActivity.mEdit = null;
		}
	}
	public static void showMessageBox(String title, String message) {
		if (0 == title.compareTo("FATAL")) {
			Message msg = new Message();
			msg.what = HANDLER_SHOW_DIALOG;
			msg.obj = new DialogMessage(title, message);
			mHandler.sendMessage(msg);
		}
	}

	public static void setAnimationInterval(double interval) {
		AppRenderer.animationInterval = (long) (interval * AppRenderer.NANOSECONDSPERSECOND);
	}

	public static void enableAccelerometer() {
		mAccelerometerEnabled = true;
		mAccelerometer.enable();
	}

	public static void disableAccelerometer() {
		mAccelerometerEnabled = false;
		mAccelerometer.disable();
	}

	public static void preloadBackgroundMusic(String path) {
		mBackgroundMusicPlayer.preloadBackgroundMusic(path);
	}

	public static void playBackgroundMusic(String path, boolean isLoop) {
		mBackgroundMusicPlayer.playBackgroundMusic(path, isLoop);
	}

	public static void stopBackgroundMusic() {
		mBackgroundMusicPlayer.stopBackgroundMusic();
	}

	public static void pauseBackgroundMusic() {
		mBackgroundMusicPlayer.pauseBackgroundMusic();
	}

	public static void resumeBackgroundMusic() {
		mBackgroundMusicPlayer.resumeBackgroundMusic();
	}

	public static void rewindBackgroundMusic() {
		mBackgroundMusicPlayer.rewindBackgroundMusic();
	}

	public static boolean isBackgroundMusicPlaying() {
		return mBackgroundMusicPlayer.isBackgroundMusicPlaying();
	}

	public static float getBackgroundMusicVolume() {
		return mBackgroundMusicPlayer.getBackgroundVolume();
	}

	public static void setBackgroundMusicVolume(float volume) {
		mBackgroundMusicPlayer.setBackgroundVolume(volume);
	}

	public static int playEffect(String path, boolean isLoop) {
		return mSoundPlayer.playEffect(path, isLoop);
	}

	public static void stopEffect(int soundId) {
		mSoundPlayer.stopEffect(soundId);
	}

	public static void pauseEffect(int soundId) {
		mSoundPlayer.pauseEffect(soundId);
	}

	public static void resumeEffect(int soundId) {
		mSoundPlayer.resumeEffect(soundId);
	}

	public static float getEffectsVolume() {
		return mSoundPlayer.getEffectsVolume();
	}

	public static void setEffectsVolume(float volume) {
		mSoundPlayer.setEffectsVolume(volume);
	}

	public static void preloadEffect(String path) {
		mSoundPlayer.preloadEffect(path);
	}

	public static void unloadEffect(String path) {
		mSoundPlayer.unloadEffect(path);
	}

	public static void stopAllEffects() {
		mSoundPlayer.stopAllEffects();
	}

	public static void pauseAllEffects() {
		mSoundPlayer.pauseAllEffects();
	}

	public static void resumeAllEffects() {
		mSoundPlayer.resumeAllEffects();
	}

	public static void end() {
		mBackgroundMusicPlayer.end();
		mSoundPlayer.end();
	}

	public static void terminateProcess() {
		if (null != mActivity) {
			mActivity.finish();
		}
		mBackgroundMusicPlayer.Release();
		mSoundPlayer.Release();

		Process.killProcess(Process.myPid());
	}
	
	// c native function
	public static native void nativeCloseIme(byte[] textArray, int flag);

	private static native int sysSetInt(String strKey, int iValue);

	private static native int sysSetDouble(String strKey, double fValue);

	private static native int sysSetString(String strKey, String strValue);

	private static native int sysGetInt(String strKey, int iDefaultValue);

	private static native double sysGetDouble(String strKey, double fDefaultValue);

	private static native String sysGetString(String strKey);

	private static native int dictSetInt(String strDictName, String strKey, int iValue);

	private static native int dictSetDouble(String strDictName, String strKey, double fValue);

	private static native int dictSetString(String strDictName, String strKey, byte[] utf8ByteArray);

	private static native int dictGetInt(String strDictName, String strKey, int iDefaultValue);

	private static native double dictGetDouble(String strDictName, String strKey, double fDefaultValue);

	private static native byte[] dictGetString(String strDictName, String strKey);

	private static native int dictDelete(String strDictName);

	private static native int callLua(String strFunctionName);

	static {
		System.loadLibrary("lua");
		System.loadLibrary("boyaa20");
		System.loadLibrary("cjson");
		System.loadLibrary("lua_pb");
	}

	public static class AppHandler extends Handler {
		@Override
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case HANDLER_SHOW_DIALOG:
				mActivity.showDialog(((DialogMessage) msg.obj).title, ((DialogMessage) msg.obj).message);
				break;
			case HANDLER_OPENGL_NOT_SUPPORT:
				final Dialog alertDialog = new AlertDialog.Builder(mActivity).setTitle("message").setMessage("device not support!").setIcon(android.R.drawable.ic_dialog_alert)
						.setPositiveButton("ok", new DialogInterface.OnClickListener() {
							@Override
							public void onClick(DialogInterface dialog, int which) {
								AppActivity.terminateProcess();
							}
						}).create();
				alertDialog.show();
				break;
			case HANDLER_SHOW_EDIT:
				EditBoxMessage editBoxMessage = (EditBoxMessage) msg.obj;
				mActivity.mEdit = new AppEditBoxDialog(mActivity, editBoxMessage.title, editBoxMessage.content, editBoxMessage.inputMode, editBoxMessage.inputFlag, editBoxMessage.returnType,
						editBoxMessage.maxLength);
				mActivity.mEdit.show();
				break;
			case HANDLER_HTTPPOST_TIMEOUT:
				AppHttpPost.HandleTimeout(msg);
				break;
				
			case HANDLER_HTTPGET_UPDATE_TIMEOUT:
				AppHttpGetUpdate.HandleTimeout(msg);
				break;
			case HANDLER_BACKGROUND_REMAIN:
				terminateProcess();
				break;
			default:
			}
			super.handleMessage(msg);
		}
	}

	public static class DialogMessage {
		public String title;
		public String message;

		public DialogMessage(String title, String message) {
			this.message = message;
			this.title = title;
		}
	}

	public static class EditBoxMessage {
		public String title;
		public String content;
		public int inputMode;
		public int inputFlag;
		public int returnType;
		public int maxLength;

		public EditBoxMessage(String title, String content, int inputMode, int inputFlag, int returnType, int maxLength) {
			this.content = content;
			this.title = title;
			this.inputMode = inputMode;
			this.inputFlag = inputFlag;
			this.returnType = returnType;
			this.maxLength = maxLength;
		}
	}

	public static class IllegalThreadException extends Exception {
		private static final long serialVersionUID = 5014653039158031528L;
		private String mistake;

		public IllegalThreadException() {
			super();
			mistake = "can't call this function by current thread";
		}

		public IllegalThreadException(String err) {
			super(err);
			mistake = err;
		}

		public String getError() {
			return mistake;
		}
	}

	public static class NetworkType {

		private BroadcastReceiver receiver = null;
		TelephonyManager Tel;
		MyPhoneStateListener MyListener;
		private static int networkType;

		public void onResume() {
			if (null != receiver) {
				IntentFilter intentFilter = new IntentFilter();
				intentFilter.addAction(ConnectivityManager.CONNECTIVITY_ACTION);
				intentFilter.addAction(WifiManager.RSSI_CHANGED_ACTION);
				//intentFilter.addAction(Intent.ACTION_TIME_TICK);
				AppActivity.mActivity.registerReceiver(receiver, intentFilter);
			}
			Tel.listen(MyListener, PhoneStateListener.LISTEN_SIGNAL_STRENGTHS);
		}

		public void onPause() {
			if (null != receiver) {
				AppActivity.mActivity.unregisterReceiver(receiver);
			}
			Tel.listen(MyListener, PhoneStateListener.LISTEN_NONE);
		}
		
		public NetworkType(Context context) {
			MyListener = new MyPhoneStateListener();
			Tel = (TelephonyManager) context
					.getSystemService(Context.TELEPHONY_SERVICE);
			Tel.listen(MyListener, PhoneStateListener.LISTEN_SIGNAL_STRENGTHS);
			
			networkType = NetworkUtil.getNetworkType(mActivity);
			
			receiver = new BroadcastReceiver() {
				@Override
				public void onReceive(Context ctx, Intent intent) {
					if(intent.getAction().equals(WifiManager.RSSI_CHANGED_ACTION)){
						final int wifiStrength = NetworkUtil.getNetworkStrength(mActivity);
						AppActivity.mActivity.runOnLuaThread(new Runnable() {
							@Override
							public void run() {
								if(networkType == 1)
									AppActivity.dict_set_int("network_info", "strength_wifi", wifiStrength);
								AppActivity.call_lua("event_signalChange");
							}

						});
					}
					if(intent.getAction().equals(ConnectivityManager.CONNECTIVITY_ACTION)){
						NetworkInfo info = (NetworkInfo) intent.getParcelableExtra(ConnectivityManager.EXTRA_NETWORK_INFO);
						final String typeName = info.getTypeName();
						final String subTypeName = info.getSubtypeName();
						final String extraInfo = info.getExtraInfo();
						networkType = NetworkUtil.getNetworkType(mActivity);
						AppActivity.mActivity.runOnLuaThread(new Runnable() {
							@Override
							public void run() {
								String typeName2 = typeName;
								if (null == typeName2 || 0 == typeName2.length()) {
									typeName2 = "0";
								}
								String subTypeName2 = subTypeName;
								if (null == subTypeName2 || 0 == subTypeName2.length()) {
									subTypeName2 = "0";
								}
								String extraInfo2 = extraInfo;
								if (null == extraInfo2 || 0 == extraInfo2.length()) {
									extraInfo2 = "0";
								}
								if(networkType == 1){
									final int wifiStrength = NetworkUtil.getNetworkStrength(mActivity);
									AppActivity.dict_set_int("network_info", "strength_wifi", wifiStrength);
								}
								AppActivity.dict_set_int("network_info", "type", networkType);
								AppActivity.dict_set_string("network_info", "type_name", typeName2);
								AppActivity.dict_set_string("network_info", "type_sub_name", subTypeName2);
								AppActivity.dict_set_string("network_info", "extra_info", extraInfo2);
								AppActivity.call_lua("event_wifiStateChange");
							}
	
						});
					}
					if(intent.getAction().equals(Intent.ACTION_TIME_TICK)){
						System.out.println("i can recive");
					}
				}
			};
		}
		
		private class MyPhoneStateListener extends PhoneStateListener {
			@Override
			public void onSignalStrengthsChanged(SignalStrength signalStrength) {
				final int signalStrengthNum;
				super.onSignalStrengthsChanged(signalStrength);
				final int asu = signalStrength.getGsmSignalStrength();
				if (asu <= 2 || asu == 99)
					signalStrengthNum = 1;
				else if (asu >= 12)
					signalStrengthNum = 4;
				else if (asu >= 8)
					signalStrengthNum = 3;
				else if (asu >= 5)
					signalStrengthNum = 2;
				else
					signalStrengthNum = 1;
				AppActivity.mActivity.runOnLuaThread(new Runnable() {
					@Override
					public void run() {
						if(networkType != 1){
							AppActivity.dict_set_int("network_info", "strength_signal", signalStrengthNum);
							AppActivity.dict_set_int("network_info", "asu", asu);
							AppActivity.call_lua("event_signalChange");
						}
					}

				});
			}
		};
	}
}
