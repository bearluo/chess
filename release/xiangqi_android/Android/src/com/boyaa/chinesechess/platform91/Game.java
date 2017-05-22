package com.boyaa.chinesechess.platform91;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.URISyntaxException;
import java.util.HashMap;
import java.util.Timer;
import java.util.TimerTask;
import java.util.TreeMap;

import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.TargetApi;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.os.PowerManager;
import android.os.Vibrator;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.PopupWindow;
import android.widget.Toast;

import com.boyaa.chinesechess.platform91.wxapi.SendToWXUtil;
import com.boyaa.entity.common.BoyaaProgressDialog;
import com.boyaa.entity.common.SDTools;
import com.boyaa.entity.common.utils.JsonUtil;
import com.boyaa.entity.core.HandMachine;
import com.boyaa.entity.guest.uuidProxy;
import com.boyaa.entity.images.CacheImageManager;
import com.boyaa.entity.images.DownLoadImage;
import com.boyaa.entity.images.SaveImage;
import com.boyaa.entity.images.UploadImage;
import com.boyaa.entity.php.PHPResult;
import com.boyaa.entity.sysInfo.SystemInfo;
import com.boyaa.entity.update.ApkInstall;
import com.boyaa.godsdk.GodSDKManager;
import com.boyaa.godsdk.core.GodSDK;
import com.boyaa.kefu.KefuFeedbackSys;
import com.boyaa.made.APNUtil;
import com.boyaa.made.AppActivity;
import com.boyaa.made.AppStartAdDialog;
import com.boyaa.made.AppStartDialog;
import com.boyaa.made.FileUtil;
import com.boyaa.made.LuaEvent;
import com.boyaa.pointwall.PointWallActivity;
import com.boyaa.proxy.SchemesProxy;
import com.boyaa.proxy.share.ShareManager;
import com.boyaa.qqapi.SendToQQUtil;
import com.boyaa.share.NativeShare;
import com.boyaa.snslogin.ISNSInterface;
import com.boyaa.snslogin.ISNSInterface.AuthCallBack;
import com.boyaa.snslogin.SinaMethod;
import com.boyaa.snslogin.UserInfo;
import com.boyaa.until.DataCleanManager;
import com.boyaa.until.NetConfig;
import com.boyaa.until.NetworkManager;
import com.boyaa.until.NetworkManager.SinalCallBackInterface;
import com.boyaa.until.SIMCardInfo;
import com.boyaa.until.Streams;
import com.boyaa.until.Util;
import com.boyaa.util.LocationInfo;
import com.boyaa.webview.ShareToBoyaaDialog;
import com.boyaa.webview.WebViewManager;
import com.igexin.sdk.PushManager;
import com.umeng.analytics.MobclickAgent;
//import com.boyaa.adsdk.AdMananger;
//import com.boyaa.boyaaad.widget.InterstitialView.OnInterstitialListener;

public class Game extends AppActivity {
	private AppStartDialog mStartDialog;
	private AppStartAdDialog mStartAdDialog;
	private final static int HANDLER_SHOW_DIALOG = 1;
	private final static int HANDLER_SHOW_EDIT = 2;
	public final static int HANDLER_CLOSE_START_DIALOG = 3;
	public final static int HANDLER_OPENGL_NOT_SUPPORT = 4;
	public final static int HANDLER_SHOW_START_DIALOG = 6;
	
	public final static int HANDLER_CLOSE_START_AD_DIALOG = 7; //关闭广告页面
	public final static int HANDLER_START_AD_DIALOG_JUMP_URL = 8;//广告页面跳转
	
	private static Vibrator vib;// 震动
	private static Handler gameHandler;
	private static PowerManager.WakeLock wakeLock;//系统休眠锁
	private static PowerManager powerManager;//电源管理
	private boolean swakeLockState = false; //当前系统自动休眠状态false开启 true禁用

	public PopupWindow mPopupWindow;
	public static int versionCode = 0;
	public static String versionName = "";
	private SaveImage saveImage = null;

	public static final int TIMEOUT_MSG_ID_BEGIN = 1000;
	public static final int TIMEOUT_MSG_ID_END = 2000;
	public static HashMap<Integer, Integer> mTimeoutMsgIds = new HashMap<Integer, Integer>();
	public static Object mSyncMsgIds = new Object();
	public static Object mFeedback = new Object();
	public static BoyaaProgressDialog progressDialog;
	public final static boolean DEBUG = true;

	private static boolean isRequestOnline = true;
	public static int curScene = -1;
	// ai start
	private PrintWriter outEngine;
	private Handler handler;
	private int engine;
	private NetworkManager netWorkManager;
	private int sinalLevel = 0;
	private Object mTencent;
	private static final String ENGINE_LOG_TAG = "ENGINE_LOG_TAG";
	private static final boolean ENGINE_LOG = true;
	// Engine Status
	private static final int ENGINE_EXIT = -1;
	private static final int ENGINE_IDLE = 0;
	private static final int ENGINE_STOP = 1;
	private static final int ENGINE_HINT = 2;
	private static final int ENGINE_MOVE = 3;
	// ai end
	
	private static int is_open = 0;
	private static String ad_url = "";
	private static int ad_sec = 5;
//	private static String ad_jump_url = "";
	/**
	 * 判断Activity是已经创建，用于区分BoyaaLogo弹窗和返回游戏弹窗的重叠
	 */
	public static boolean mIsActivityCreated = false;
	
	//ad 
//	private static OnInterstitialListener interstitialListener = new OnInterstitialListener() {
//		
//		@Override
//		public void onSureListener() {
//			AdMananger.clearAll(Game.mActivity);
//			AdMananger.d1.cancelInterstitialAdDialog();
//			Game.mActivity.runOnLuaThread(new Runnable() {
//				
//				@Override
//				public void run() {
//					// TODO Auto-generated method stub
//					HandMachine.getHandMachine().luaCallEvent(
//							HandMachine.kAdMananger, "");
//				}
//			});
//		}
//		
//		@Override
//		public void onCancelListener() {
//			AdMananger.d1.cancelInterstitialAdDialog();
//		}
//	}; 
	
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		// 防止 java.lang.NoClassDefFoundError: android/os/AsyncTask
		try {
		      Class.forName("android.os.AsyncTask");
		      Class.forName("com.boyaa.entity.common.SyncTaskSimpleWrap");
		}
		catch(Throwable ignore) {
		      // ignored
		}
		
		
//		com.umeng.common.Log.LOG = true;
//		MobclickAgent.onError(this); // 友盟统计错误
		long timeStart = System.currentTimeMillis();
		DisplayMetrics metrics = new DisplayMetrics();
		getWindowManager().getDefaultDisplay().getMetrics(metrics);
		mWidth = metrics.widthPixels;
		mHeight = metrics.heightPixels;
		
		LayoutInflater inflater = LayoutInflater.from(this);
		FrameLayout mainLayout = (FrameLayout) inflater.inflate(R.layout.main, null);
		mainLayout.setLayoutParams(new FrameLayout.LayoutParams(mWidth, mHeight));
		View surfaceview = mainLayout.findViewById(R.id.gl_surfaceview);
		surfaceview.setLayoutParams(new FrameLayout.LayoutParams(mWidth, mHeight));

		
		super.CreateApp(mainLayout, surfaceview);
		loadEngine();
		long timeEnd = System.currentTimeMillis();
		long timeTotal = timeEnd - timeStart;
		Log.i("Game", "timeStart = " + timeStart + "timeEnd = " + timeEnd
				+ "timeTotal = " + timeTotal);
		if (null == savedInstanceState) {
			mStartDialog = new AppStartDialog(this);
			mStartAdDialog = new AppStartAdDialog(this);
			double scale = 720/(double)mWidth;
			mStartAdDialog.setWindowScale(scale);
		} else {
			mStartDialog = null;
			mStartAdDialog = null;
		}

		NetConfig.writeNetNetconfig(this);
		GodSDKManager.initGodSDK(this);
		GodSDKManager.onCreate();
		init();
		// url 启动解析
		SchemesProxy.getInstance().setIntent(this.getIntent());
		
		float xdpi = getResources().getDisplayMetrics().xdpi;
		float ydpi = getResources().getDisplayMetrics().ydpi;
		float xsdpi = getResources().getDisplayMetrics().xdpi;
		float ysdpi = getResources().getDisplayMetrics().ydpi;
	}

	protected void init() {
		SendToWXUtil.onCreate(this);
		SendToQQUtil.onCreate(this);
		ApplicationInfo info;
		String msg = "unknow";
		try {
			info = this.getPackageManager().getApplicationInfo(getPackageName(),PackageManager.GET_META_DATA);
			msg = info.metaData.getString("UMENG_CHANNEL");
		} catch (NameNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		Log.e("channelname", " msg == " + msg );
//		AdMananger.init(this, msg,"0");
		gameHandler = new GameHandler();
		if (null != mStartDialog) {
			gameHandler.sendEmptyMessageDelayed(HANDLER_CLOSE_START_DIALOG,
					15000);
			Log.i("lua", "mStartDialog is delayed dismiss");
		}else{
			Log.i("lua", "mStartDialog is null");
		}
		
		powerManager = (PowerManager)(getSystemService(Context.POWER_SERVICE));   
		wakeLock = powerManager.newWakeLock(PowerManager.SCREEN_BRIGHT_WAKE_LOCK, "My Tag"); 
		
	}

	private void loadEngine() {
		// Start Engine
		final String engineFile = getFilesDir() + "/ELEEYE";
		final String bookFile = getFilesDir() + "/BOOK.DAT";
		Log.e("test", bookFile);
		Runtime runtime = Runtime.getRuntime();

		try {
			InputStream in = null;
			if (Build.VERSION.SDK_INT >= 21) {
				in = getAssets().open("eleeye5.0/eleeye");
			} else {
				in = getAssets().open("eleeye");
			}
//			/data/data/com.boyaa.chinesechess.platform91/files/ELEEYE
			FileOutputStream out = new FileOutputStream(engineFile);
			Streams.copy(in, out);
			in.close();
			out.flush();
			out.close();
			runtime.exec("chmod 777 " + engineFile).waitFor();

			in = getAssets().open("book.dat");
			out = new FileOutputStream(bookFile);
			Streams.copy(in, out);
			in.close();
			out.flush();
			out.close();
			runtime.exec("chmod 777 " + bookFile).waitFor();
		} catch (InterruptedException e) {
			Log.w("XQWDroid", e.getMessage()); // Ignored
		} catch (IOException e) {
			Log.w("XQWDroid", e.getMessage()); // Ignored
		}

		Process p;
		try {
			p = runtime.exec(engineFile, null, getFilesDir());
		} catch (IOException e) {
			Log.e("XQWDroid", "", e);
//			new File(bookFile).delete();
//			new File(engineFile).delete();
			alertExit("无法加载引擎：" + e.getMessage());
			return;
		}
		outEngine = new PrintWriter(p.getOutputStream());
		send("ucci");
		// 查程序运行是否报错
		// final BufferedReader in_1 = new BufferedReader(new InputStreamReader(
		// p.getErrorStream()));
		// new Thread() {
		// @Override
		// public void run() {
		// try {
		// String line;
		// while ((line = in_1.readLine()) != null) {
		// final String line_ = line;
		// Log.e("XQWDroid ERROR",line_);
		//
		// }
		// Log.i("XQWDroid", "Engine Closed");
		// } catch (IOException e) {
		// Log.w("XQWDroid", e.getMessage());
		// } finally {
		// new File(bookFile).delete();
		// new File(engineFile).delete();
		// }
		// }
		// }.start();

		final BufferedReader in_ = new BufferedReader(new InputStreamReader(
				p.getInputStream()));

		handler = new Handler();
		new Thread() {
			@Override

			public void run() {
				try {
					String line;
					while ((line = in_.readLine()) != null) {
						final String line_ = line;
						Log.e("XQWDroid", line_);
						handler.post(new Runnable() {
							@Override
							public void run() {
								onReceive(line_);
							}
						});
					}
					Log.i("XQWDroid", "Engine Closed");
				} catch (IOException e) {
					Log.w("XQWDroid", e.getMessage());
				} finally {
					handler.post(new Runnable() {
						@Override
						public void run() {
							// board.running = false; // Stop SurfaceView.draw
							// ASAP
							if (engine == ENGINE_EXIT) {
								finish();
							} else {
								new File(bookFile).delete();
//								new File(engineFile).delete();
								alertExit("游戏引擎异常，请重新启动");
							}
						}
					});
					new File(bookFile).delete();
//					new File(engineFile).delete();
				}
			}
		}.start();

		engine = ENGINE_IDLE;
	}

	void alertExit(String message) {
//		final Intent intent = new Intent(Game.this,Game.class);
		new AlertDialog.Builder(this).setTitle("警告").setMessage(message)
				.setCancelable(false)
				.setPositiveButton("游戏重启", new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog, int which) {
						dialog.cancel();
						loadEngine();
//						loadEngine();
//						Intent intent = getIntent();
//						finish();
//						startActivity(intent);
					}
				})
				.setNegativeButton("退出游戏", new DialogInterface.OnClickListener(){
					@Override
					public void onClick(DialogInterface dialog, int which) {
						finish();
					}
				}).show();
	}

	void send(String line) {
		Log.e(ENGINE_LOG_TAG, "GUI->ENG:" + line);

		if (ENGINE_LOG) {
			Log.i(ENGINE_LOG_TAG, "GUI->ENG:" + line);
		}

		if (outEngine == null) {
			Log.i(ENGINE_LOG_TAG, "GUI->ENG:" + "outEngine == null");
			return;
		}

		outEngine.println(line);
		outEngine.flush();
	}

	void onReceive(final String line) {

		if (ENGINE_LOG) {
			Log.i(ENGINE_LOG_TAG, "ENG->GUI:" + line);
		}
		final JSONObject jsonStr = new JSONObject();
		try {
			jsonStr.put("Engine2Gui", line);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		runOnLuaThread(new Runnable() {

			@Override
			public void run() {
				HandMachine.getHandMachine().luaCallEvent(
						HandMachine.kEngine2Gui, jsonStr.toString());
			}
		});

	}

	// ai end
	public static Handler getGameHandler() {
		return gameHandler;
	}

	// call by render thread
	public static void SetTimeout(int id, long ms) {
		System.out.println("Game.SetTimeout");
		if (id < TIMEOUT_MSG_ID_BEGIN || id >= TIMEOUT_MSG_ID_END) {
			return;
		}
		synchronized (mSyncMsgIds) {
			Game.mTimeoutMsgIds.put(id, id);
		}
		Log.d("ClosePointWall", "Before Game.SetTimeOut.sendEmptyMessageDelayed");
		AppActivity.getHandler().sendEmptyMessageDelayed(id, ms);

	}

	// call by render thread
	public static void ClearTimeout(int id) {
		System.out.println("Game.SetTimeout");
		synchronized (mSyncMsgIds) {
			if (Game.mTimeoutMsgIds.containsKey(id)) {
				Game.mTimeoutMsgIds.remove(id);
				AppActivity.getHandler().removeMessages(id);
			}
		}
	}

	// @Override
	// protected void showDialog(String title, String message) {
	// Dialog dialog = new AlertDialog.Builder(this).setTitle(title)
	// .setMessage(message)
	// .setPositiveButton("Ok", new DialogInterface.OnClickListener() {
	// public void onClick(DialogInterface dialog, int whichButton) {
	//
	// }
	// }).create();
	//
	// dialog.show();
	//
	// PendingIntent pendingIntent = PendingIntent.getActivity(
	// getApplicationContext(), 0, new Intent(), 0);
	// // final NotificationManager notifyManager = (NotificationManager)
	// // getSystemService(Context.NOTIFICATION_SERVICE);
	// // Notification notifyData = new
	// // Notification(android.R.drawable.stat_notify_chat, message,
	// // System.currentTimeMillis());
	// // notifyData.flags |= Notification.FLAG_AUTO_CANCEL;
	// // notifyData.setLatestEventInfo(this, title, message, pendingIntent);
	// // notifyManager.cancel(0);
	// // notifyManager.notify(0,notifyData);
	//
	// }

	protected void onBeforeInitGL(Bundle savedInstanceState) {
		initVersion(this);
		// if(!SDTools.isExternalStorageWriteable()){
		// this.showdialog();
		// }
		// SDTools.batchSaveBmp(this, FileUtil.getmStrImagesPath());
	}

	// 手机没有sd卡，弹出提示框
	protected void showdialog() {
		Dialog dialog = new AlertDialog.Builder(this).setTitle("提示")
				.setMessage("你的手机没有sd卡,游戏不支持")
				.setPositiveButton("确定", new DialogInterface.OnClickListener() {
					public void onClick(DialogInterface dialog, int whichButton) {
						Game.terminateProcess();
					}
				}).create();

		dialog.show();

	}

	@TargetApi(Build.VERSION_CODES.HONEYCOMB) protected void onHandleMessage(Message msg) throws URISyntaxException {
		// call by ui thread
		synchronized (mSyncMsgIds) {
			if (mTimeoutMsgIds.containsKey(msg.what)) {
				final int id = msg.what;
				System.out.println("Game.onHandleMessage id =  " + id);
				mTimeoutMsgIds.remove(id);
				AppActivity.mActivity.runOnLuaThread(new Runnable() {
					@Override
					public void run() {
						AppActivity.dict_set_int("OSTimeout", "id", id);
						AppActivity.call_lua("OSTimeoutCallback");

					}
				});
			}
		}

		switch (msg.what) {
		case HandMachine.HANDLER_AD_MANANAGER: {
			Bundle bundle = msg.getData();
			String data = (String) bundle.get("data");
			int key = Integer.valueOf(data);
			int status = 0;//AdMananger.AdManangerDistribution(key,Game.mActivity,interstitialListener);
			Log.e("ad","status:"+status);
			if (status != 1){
				try {
					final JSONObject ret = new JSONObject();
				
					ret.put("status", 0);
					ret.put("key", key);
					runOnLuaThread(new Runnable() {
						@Override
						public void run() {
							HandMachine.getHandMachine().luaCallEvent(
									HandMachine.kAdSDKStatus, ret.toString());
						}
					});
				} catch (JSONException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				

				}
			}

		}

			break;
		case HANDLER_CLOSE_START_DIALOG: {
			Game.mActivity.runOnLuaThread(new Runnable() {
				
				@Override
				public void run() {
					// TODO Auto-generated method stub
					getAdDialogPram();
					Log.e("lua", "dismissStartDialog");
					dismissStartDialog();
				}
			});
		}
			break;
		case HANDLER_CLOSE_START_AD_DIALOG: {
			dismissStartAdDialog();
		}
			break;
		case HANDLER_START_AD_DIALOG_JUMP_URL: {
			try {
				if("".equals(ad_url) || "null".equals(ad_url)){
					
				}else{
					String eventState = "ad_start_page_click"; //统计启动页广告点击事件
					onEventStat(eventState);
					//跳转网页链接
					dismissStartAdDialog();
					Intent i = new Intent(Intent.ACTION_VIEW);
					i.setData(Uri.parse(ad_url));
					startActivity(i);
				}
			} catch (Exception e) {
				// TODO: handle exception
			}
		}
			break;	
		case HandMachine.GUI_ENGINE: {
			Bundle bundleLine = msg.getData();
			String line = bundleLine.getString("data");
			if (line == "quit") {
				engine = ENGINE_EXIT;
			}
			// Log.e("XQWDroid GUI_ENGINE", line);
			send(line);
		}
			break;
		case HandMachine.HANDLER_INITGETUISDK: {
			//个推初始化
			PushManager.getInstance().initialize(this.getApplicationContext());
		}
			break;
		case HandMachine.HANDLER_INITFEEDBACKSDK:{
			String data = msg.getData().getString("data");
			KefuFeedbackSys.getInstance().init(this, data);
		}	
		case HandMachine.HANDLER_LOADFEEDBACKSDK:{
			String data = msg.getData().getString("data");
			KefuFeedbackSys.getInstance().entryFeedbackSys(this, data);
		}
			break;
		case HandMachine.HANDLER_BANDEVICELSLEEP: {
			//禁止系统自动休眠
			if  (!swakeLockState) {
				boolean tempbool = closeSystemSleep();
				if (tempbool){
					swakeLockState = true;
				}
			}
		}
			break;	
		case HandMachine.HANDLER_OPENDEVICELSELLP: {
			//开启系统自动休眠
			if (swakeLockState) {
				boolean tempbool = openSystemSleep();
				if (tempbool){
					swakeLockState = false;
				}
			}
		}
			break;	
		case HandMachine.HANDLER_START_GET_CITY_INFO: {
			LocationInfo.getCityByHttp();
		}
			break;
		case HandMachine.HANDLER_START_GET_LOCATION_INFO: {
			LocationInfo.getLoLaByNetWork(this);
		}
			break;
		case HandMachine.TOWEBPAGE: {
			Bundle topage = msg.getData();
			String topage_url = topage.getString("data");
			SystemInfo topage_update = new SystemInfo();
			topage_update.toWebPage(topage_url);
		}
			break;
		case HandMachine.HANDLER_PAY: {
				Bundle bundleData = msg.getData();
				String data = bundleData.getString("data");
				GodSDKManager.pay(data);
			}
			break;
		case HandMachine.HANDLER_DOWNLOAD_IMAGE: {
			Bundle bundleDLImg = msg.getData();
			DownLoadImage downloadImage = new DownLoadImage(
					HandMachine.kDownLoadImage);
			downloadImage.doDownLoadPic((String) bundleDLImg.get("data"));
		}
			break;
		case HandMachine.HANDLER_SAVE_IMAGE: {
			saveImage = new SaveImage(Game.this, HandMachine.kUpLoadImage);
			Bundle bundleSaveImage = msg.getData();
			Log.i("Game", "onHandleMessage HandMachine.HANDLER_SAVE_IMAGE ");
			saveImage.doPickPhotoFromGallery((String) bundleSaveImage
					.get("data"),false);
		}
			break;		
		case HandMachine.HANDLER_UPLOAD_IMAGE: {
			saveImage = new SaveImage(Game.this, HandMachine.kUpLoadImage);
			Bundle bundleSaveImage = msg.getData();
			String imageNamePar = (String) bundleSaveImage.get("data");
			JSONObject jsonResult = null;
			try {
				jsonResult = new JSONObject(imageNamePar);
				String imageName = jsonResult.getString("ImageName");
				String Api = jsonResult.getString("Api");
				String Url = jsonResult.getString("Url");
				Log.i("boyaa","upload_image imageName = " + imageName);
				Log.i("boyaa","upload_image Api = " + Api);
				Log.i("boyaa","upload_image Url = " + Url);
				Log.i("boyaa","upload_image Url = " + Url);
				String imgPath = FileUtil.getmStrImagesPath() + imageName + ".png";
				UploadImage.uploadPhoto(this , imgPath , Api , Url , HandMachine.kUpLoadImage2,false,null);
			} catch (JSONException e) {
				Log.i("boyaa","upload_image JSONException e = " + e.getMessage());
				Log.i("boyaa","upload_image JSONException e = " + e.getStackTrace());
				Toast.makeText(this, "上传失败", Toast.LENGTH_SHORT).show();
				return;
			}
		}
			break;		
			
		case HandMachine.TAKE_SCREEN_SHOT:{
			Bundle bundleTakeshot = msg.getData();
			final String imageName = bundleTakeshot.getString("data");
			runOnLuaThread(new Runnable() {
				@Override
				public void run() {
					NativeShare.takeShot(imageName);
					HandMachine.getHandMachine().luaCallEvent(
							HandMachine.kTakeShotComplete, "");
				}
			});
		}
			break;
		case HandMachine.HANDLER_SAVE_FEED_BACK_IMAGE: {
			saveImage = new SaveImage(Game.this, HandMachine.kLoadFeedBackImage);
			Bundle bundleSaveImage = msg.getData();
			Log.i("Game", "onHandleMessage HandMachine.HANDLER_SAVE_FEED_BACK_IMAGE ");
			saveImage.doPickPhotoFromGallery((String) bundleSaveImage
					.get("data"),true);
		}
			break;

		case HandMachine.HANDLER_UPLOAD_FEED_BACK_IMAGE: {
			Bundle bundleSaveImage = msg.getData();
			try {
				JSONObject jsonResult = new JSONObject((String) bundleSaveImage.get("data"));
				String imageName = jsonResult.getString("ImageName");
				String filePath = FileUtil.getmStrImagesPath() + imageName + SDTools.PNG_SUFFIX;
				String surl = jsonResult.getString("Url");
				String api = jsonResult.getString("Api");
				PHPResult result = new PHPResult();
				UploadImage.uploadPhoto(Game.this,filePath, api, surl,HandMachine.kUpLoadFeedBackImage, true);
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

		}
			break;
		case HandMachine.HANDLER_LOGIN_WITH_WEIBO: {
			loginWithWeibo(msg);
		}
			break;
		case HandMachine.HANDLER_GET_WEIBO_USERINFO: {
			loginWithWeiboUserInfo(msg);
		}
			break;

		case HandMachine.HANDLER_GET_NET_STATE_LEVEL:
			if (netWorkManager != null) {
				netWorkManager.getNetStateSinalLevel();
			}
			break;
		case HandMachine.HANDLER_REGISTER_NET_STATE_LISTNER:
			registerSinalListener();
			break;
		case HandMachine.HANDLER_UNREGISTER_NET_STATE_LISTNER:
			if (netWorkManager != null)
				netWorkManager.unregisterSinalReceiver();
			break;
		case HandMachine.HANDLER_START_WIRELESS_SETTING:
			if (netWorkManager != null)
				netWorkManager.StartWirelessSetting();
			break;
		case HandMachine.HANDLER_SAVE_UUID: {
			String uuid = (String) msg.obj;
			uuidProxy.saveOtherUUID(uuid);
			runOnLuaThread(new Runnable() {

				@Override
				public void run() {
					HandMachine.getHandMachine().luaCallEvent(
							HandMachine.kSaveNewUUID, "");
				}
			});
		}
			break;
		case HandMachine.HANDLER_GET_UUID: {
			String uuid = uuidProxy.getUUID();
			final JSONObject jsonObject = new JSONObject();
			try {
				jsonObject.put("new_uuid", uuid);
				runOnLuaThread(new Runnable() {

					@Override
					public void run() {
						HandMachine.getHandMachine().luaCallEvent(
								HandMachine.kGetOldUUID, jsonObject.toString());
					}
				});
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
			break;
		case HandMachine.REPORT_LUA_ERROR:
		{
			Bundle bundleError = msg.getData();
			String error_info = bundleError.getString("data");
			reportLuaError(error_info);
		}
			break;
		case HandMachine.ON_EVENT_STAT: // 事件统计OnEventStat
		{
			Bundle bundleEvent = msg.getData();
			String event_info = bundleEvent.getString("data");
			onEventStat(event_info);
		}
			break;
		case HandMachine.COPY_URL: // 分享棋谱
		{
			final Bundle bundle = msg.getData();
			String url = bundle.getString("data");
			Util.copyStr(url, this);
		}
		break;
			
		case HandMachine.HANDLER_GET_PHONE_INFO: {
			TreeMap<String, Object> map = new TreeMap<String, Object>();
			// 积分墙版本上报一维数据
			map.put("model", Build.MODEL == null ? "" : Build.MODEL);// 手机型号
			map.put("sdkVersion", Build.VERSION.RELEASE);
			map.put("mac", Util.getMacAddr());// 物理地址
			map.put("netType", APNUtil.getNetWorkName(Game.mActivity));// 网络类型
			map.put("ip", Util.getIpAddr());// ip地址
			map.put("imeiNum", Util.getImeiNum());

			JsonUtil json = new JsonUtil(map);
			final String phoneStr = json.toString();

			runOnLuaThread(new Runnable() {

				@Override
				public void run() {
					HandMachine.getHandMachine().luaCallEvent(
							HandMachine.kGetPhoneInfo, phoneStr);
				}
			});
		}
			break;
		case HandMachine.HANDLER_SHOW_POINT_WALL: {
			Bundle bundlePW = msg.getData();
			String dataPW = (String) bundlePW.get("data");
			try {
				JSONObject ooo = new JSONObject(dataPW);
				String mid = ooo.getString("uid");
				String mtkey = ooo.getString("mtkey");
				String developUrl = ooo.getString("developUrl");
				Intent intent = new Intent(this, PointWallActivity.class);
				intent.putExtra("appid", "100001");
				intent.putExtra("uid", mid);
				intent.putExtra("mtkey", mtkey);
				intent.putExtra("developUrl", developUrl);
				startActivityForResult(intent, REQUSET_CODE);
			} catch (JSONException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}
			break;
		case HandMachine.UPDATEVERSION: {
			Bundle bundleUrl = msg.getData();
			String url = bundleUrl.getString("data");
			String type = bundleUrl.getString("type");

			SystemInfo update = new SystemInfo();
			update.updateVersion(url, type);
		}
			break;
		case HandMachine.HANDLER_SHAREWEB: {
			WebViewManager.getNativeInstance().hideView();
			Bundle bundleUrl = msg.getData();
			String data = bundleUrl.getString("data");
			WebViewManager.getShareInstance().newWebView(data);
		}
			break;
		case HandMachine.HANDLER_SHAREWEBREFRESH: {
//			ShareListView.getInstance().refreshView();
		}
			break;
		case HandMachine.HANDLER_SHAREWEBCLOSE: {
			WebViewManager.getShareInstance().hideView();
		}
			break;
		case HandMachine.HANDLER_NATIVEWEB: {
			WebViewManager.getShareInstance().hideView();
			Bundle bundleUrl = msg.getData();
			String data = bundleUrl.getString("data");
			WebViewManager.getNativeInstance().newWebView(data);
		}
			break;
		case HandMachine.HANDLER_NATIVEWEBREFRESH: {
			WebViewManager.getNativeInstance().refreshView();
		}
			break;
		case HandMachine.HANDLER_NATIVEWEBCLOSE: {
			WebViewManager.getNativeInstance().hideView();
		}
			break;
		case HandMachine.HANDLER_ACTIVITYWEB: {
			WebViewManager.getActivityInstance().hideView();
			Bundle bundleUrl = msg.getData();
			String data = bundleUrl.getString("data");
			WebViewManager.getActivityInstance().newWebView2(data);
		}
			break;
		case HandMachine.HANDLER_ACTIVITYWEBCLOSE: {
			WebViewManager.getActivityInstance().hideView();
		}
			break;
		case HandMachine.HANDLER_INSTALL_NWE_APK: {
			Bundle apkPathBundle = msg.getData();
			String newApkPath = apkPathBundle.getString("newApkPath");
			ApkInstall apkInstall = new ApkInstall();
			apkInstall.startInstall(newApkPath);
		}
			break;
		case HandMachine.HANDLER_SAVEIMAGE: {
			Bundle bundle = msg.getData();
			String imageName = bundle.getString("imageName");
			CacheImageManager.saveImageDCIM(imageName);
		}
			break;
		case HandMachine.HANDLER_GET_CACHE_SIZE: {
			if (Environment.getExternalStorageState().equals(android.os.Environment.MEDIA_MOUNTED)){
				String formatSize;
				String sdPath = Environment.getExternalStorageDirectory() + "/." + this.getPackageName() + "/images";
				File file =  new File(sdPath);
				final JSONObject jsonStr = new JSONObject();
				try {
//					double size = DataCleanManager.getFolderSize(file);
					formatSize = DataCleanManager.getFormatSize(DataCleanManager.getFolderSize(file));
					jsonStr.put("CacheSize", formatSize);
				} catch (Exception e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				runOnLuaThread(new Runnable() {
					@Override
					public void run() {
						HandMachine.getHandMachine().luaCallEvent(
								HandMachine.kGetAppCacheSize, jsonStr.toString());
					}
				});
			}
		}
			break;
		case HandMachine.HANDLER_CLEAN_CACHE: {
			String sdPath = Environment.getExternalStorageDirectory() + "/." + this.getPackageName() + "/images";
			DataCleanManager.cleanCustomCache(sdPath);
			// 根目录不能删
			File file = new File(sdPath);
			if( !file.exists() ) {
				file.mkdirs();
			}
			TimerTask task = new TimerTask(){
				@Override
				public void run() {
					runOnLuaThread(new Runnable() {
						@Override
						public void run() {
							HandMachine.getHandMachine().luaCallEvent(
									HandMachine.kCleanAppCache, "");
						}
					});
				}    
			};
			Timer timer = new Timer();  
			timer.schedule(task, 1000);  
		}
			break;
		default:
			Log.w("lua", "lua call event msg.what not find. what:" + msg.what);
			break;
		}
	}

	private static final int PASS_REQUEST_CODE = 9000;

	protected boolean onHandleKeyDown(int keyCode, KeyEvent event) {

		if (keyCode == KeyEvent.KEYCODE_BACK
				|| keyCode == KeyEvent.KEYCODE_MENU) {
			final int kc = keyCode;
			runOnLuaThread(new Runnable() {
				@Override
				public void run() {
					HandMachine.getHandMachine().handle(kc, "");
				}
			});
			return true;
		}
		return false;
	}

	/**
	 * 分享图片
	 * 
	 * @param info
	 */
	public void shareImg(final String info) {

		runOnLuaThread(new Runnable() {

			@Override
			public void run() {

				// //微信不可用
				// if(!Weixin.isWxAvailable()){
				// String line = "您未安装或微信版本过低";
				// HandMachine.getHandMachine().luaCallEvent(
				// HandMachine.kShareImgMsg, line);
				// }
				//
				String[] str = info.split(",");

				if (str.length > 1) {
					// Weixin.shareWXImg(str[0],str[1],str[2]);
				} else {
					NativeShare.takeShot(info);
					NativeShare.shareImg(info);
				}
				//

				// showSend(str[0]);
			}
		});
	}

	/**
	 * 事件统计
	 * 
	 * @param event_info
	 */
	public void onEventStat(final String event_info) {

		runOnUiThread(new Runnable() {

			@Override
			public void run() {

				System.out.println("Game.onEventStat : " + event_info);

				String[] str = event_info.split(",");

				if (str.length > 1) {
					String event_id = str[0];
					String event_label = str[1];
					MobclickAgent.onEvent(Game.this, event_id, event_label);
				} else {
					String event_id = str[0];
					MobclickAgent.onEvent(Game.this, event_id);
				}
			}
		});
	}

	public static int loginCount = 0;
	private ISNSInterface ISNS;

	

	private void loginWithWeibo(Message msg) {
		loginCount++;

		ISNS = new SinaMethod(this);
		ISNS.Login(new AuthCallBack() {
			//http://open.weibo.com/wiki/2/users/show
			@Override
			public void onSuccess(UserInfo userInfo) {
				String nickname = userInfo.getNickname();
				String sitemid = userInfo.getOpenid();
				String gender = userInfo.getGender();
				String accessToken = userInfo.getAccessToken();
				String avatarLarge = userInfo.getAvatarLarge();
				final JSONObject ret = new JSONObject();
				try {
					ret.put("nickname", nickname);
					ret.put("sitemid", sitemid);
					ret.put("gender", gender);
					ret.put("avatarLarge", avatarLarge);
					String osinfo = "设备类型:" + Build.MODEL + "系统版本:"
							+ Build.VERSION.RELEASE + "联网方式:"
							+ APNUtil.getNetWorkName(Game.mActivity);
					String versionName = Game.versionName;
					ret.put("osinfo", osinfo);
					ret.put("versionName", versionName);
					ret.put("accessToken", accessToken);
					ret.put("uid", Util.getMachineId());
					ret.put("sdkVersion", Build.VERSION.RELEASE);
					ret.put("netType", APNUtil.getNetWorkName(Game.mActivity));
					ret.put("model", Build.MODEL == null ? "" : Build.MODEL);
					DisplayMetrics dm = new DisplayMetrics();
					getWindowManager().getDefaultDisplay().getMetrics(dm);

					SIMCardInfo cardInfo = new SIMCardInfo(Game.this);
					int type = cardInfo.getProvidersType();
					String operator = null;

					if (type == SIMCardInfo.CHINA_MOBILE) {
						operator = "CHINA_MOBILE";
					} else if (type == SIMCardInfo.CHINA_UNICOM) {
						operator = "CHINA_UNICOM";
					} else if (type == SIMCardInfo.CHINA_TELECOM) {
						operator = "CHINA_TELECOM";
					} else if (type == SIMCardInfo.CHINA_TIETONG) {
						operator = "CHINA_TIETONG";

					} else {
						operator = "";
					}

					String imei = Util.getMachineId();
					ret.put("pixel", dm.widthPixels + "x" + dm.heightPixels);
					ret.put("imei", imei);
					ret.put("operator", operator);

				} catch (JSONException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}

				runOnLuaThread(new Runnable() {

					@Override
					public void run() {
						HandMachine.getHandMachine().luaCallEvent(
								HandMachine.kLoginWithWeibo, ret.toString());
					}
				});
			}

			@Override
			public void onFail(String result) {
				if (loginCount < 3) {
					LuaEvent.sendMessage(HandMachine.kLoginWithWeibo,
							HandMachine.HANDLER_LOGIN_WITH_WEIBO);
				} else {
//					runOnLuaThread(new Runnable() {
//
//						@Override
//						public void run() {
//							HandMachine.getHandMachine().luaCallEvent(
//									HandMachine.kLoginWaySelect, "");
//						}
//					});
				}
			}
		});
	}

	private void loginWithWeiboUserInfo(Message msg) {
		UserInfo mUserInfo = (UserInfo) msg.obj;
		SinaMethod mSinaMethod = new SinaMethod(this);
		mSinaMethod.getUserInfo(mUserInfo, new AuthCallBack() {

			@Override
			public void onSuccess(UserInfo userInfo) {
				String nickname = userInfo.getNickname();
				String sitemid = userInfo.getOpenid();
				String gender = userInfo.getGender();
				String accessToken = userInfo.getAccessToken();

				final JSONObject ret = new JSONObject();
				try {
					ret.put("nickname", nickname);
					ret.put("sitemid", sitemid);
					ret.put("gender", gender);
					String osinfo = "设备类型:" + Build.MODEL + "系统版本:"
							+ Build.VERSION.RELEASE + "联网方式:"
							+ APNUtil.getNetWorkName(Game.mActivity);
					String versionName = Game.versionName;
					ret.put("osinfo", osinfo);
					ret.put("versionName", versionName);
					ret.put("accessToken", accessToken);
					ret.put("uid", Util.getMachineId());
					ret.put("sdkVersion", Build.VERSION.RELEASE);
					ret.put("netType", APNUtil.getNetWorkName(Game.mActivity));
					ret.put("model", Build.MODEL == null ? "" : Build.MODEL);
					DisplayMetrics dm = new DisplayMetrics();
					getWindowManager().getDefaultDisplay().getMetrics(dm);

					SIMCardInfo cardInfo = new SIMCardInfo(Game.this);
					int type = cardInfo.getProvidersType();
					String operator = null;

					if (type == SIMCardInfo.CHINA_MOBILE) {
						operator = "CHINA_MOBILE";
					} else if (type == SIMCardInfo.CHINA_UNICOM) {
						operator = "CHINA_UNICOM";
					} else if (type == SIMCardInfo.CHINA_TELECOM) {
						operator = "CHINA_TELECOM";
					} else if (type == SIMCardInfo.CHINA_TIETONG) {
						operator = "CHINA_TIETONG";

					} else {
						operator = "";
					}

					String imei = Util.getMachineId();
					ret.put("pixel", dm.widthPixels + "x" + dm.heightPixels);
					ret.put("imei", imei);
					ret.put("operator", operator);

				} catch (JSONException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}

				runOnLuaThread(new Runnable() {

					@Override
					public void run() {
						HandMachine.getHandMachine().luaCallEvent(
								HandMachine.kLoginWithWeibo, ret.toString());
					}
				});

			}

			@Override
			public void onFail(String result) {
				LuaEvent.sendMessage(HandMachine.kLoginWithWeibo,
						HandMachine.HANDLER_LOGIN_WITH_WEIBO);

			}

		});
	}

	@Override
	protected void onStart() {
		super.onStart();
		if (null != mStartDialog) {
			mStartDialog.show();

			/**
			 * 解决欢迎动画在Android4.0版本手机中 有时出现无法全屏的问题
			 */
			WindowManager.LayoutParams params = mStartDialog.getWindow()
					.getAttributes();
			DisplayMetrics dm = getResources().getDisplayMetrics();
			this.getWindowManager().getDefaultDisplay().getMetrics(dm);
			params.width = dm.widthPixels;
			params.height = dm.heightPixels;
			mStartDialog.getWindow().setAttributes(params);
		}
	}

	@Override
	protected void onPause() {
		Log.d("CDH", "Game's onPause");
		super.onPause();
	    MobclickAgent.onPause(this);
	    GodSDKManager.onPause();
	    WebViewManager.getCollectInstance().onPause();
	    WebViewManager.getNativeInstance().onPause();
	    WebViewManager.getShareInstance().onPause();
	    if (swakeLockState) {
	    	openSystemSleep();
		}
	}
	
	@Override
	protected void onResume() {
		Log.d("CDH", "Game's onResume");
		super.onResume();
	    MobclickAgent.onResume(this);
	    MobclickAgent.setDebugMode(true);
	    GodSDKManager.onResume();
	    WebViewManager.getCollectInstance().onResume();
	    WebViewManager.getNativeInstance().onResume();
	    WebViewManager.getShareInstance().onResume();
		if (swakeLockState) {
			closeSystemSleep();
		}
	}

	@Override
	protected void onStop() {
		// TODO Auto-generated method stub
		super.onStop();
		GodSDKManager.onStop();
		Log.d("CDH","Game's onStop");
	}

	@Override
	protected void onDestroy() {
		// TODO Auto-generated method stub
		Log.d("CDH", "Game's onDestroy");
		super.onDestroy();
		GodSDKManager.onDestroy();
		if(GodSDKManager.shouldDestoryAndKillProcess()) {
			GodSDK.getInstance().release(this);
			android.os.Process.killProcess(android.os.Process.myPid());
		}
//		Matrix.destroy(this);
	}

	public void initVersion(Context context) {
		PackageManager packageManager = context.getPackageManager();
		try {
			PackageInfo packageInfo = packageManager.getPackageInfo(
					AppActivity.mActivity.getPackageName(), 0);
			versionName = packageInfo.versionName;
			versionCode = packageInfo.versionCode;

		} catch (NameNotFoundException e) {
			Log.i("", e.toString());
		}
	}

	private static final int PAY_SDK_REQUEST_CODE = 8889;
	private static final int REQUSET_CODE = 998;// startActivityForResult,跳入积分墙Code。
	private static final int SHARE_DIALOG_CODE = 11;// share_dialog_hide隐藏回调code。
	/**
	 * 因为调用了Camera和Gally所以要判断他们各自的返回情况， 他们启动时是这样的startActivityForResult
	 */
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		GodSDKManager.onActivityResult(requestCode, resultCode, data);
		if (resultCode == RESULT_OK && requestCode == SaveImage.PHOTO_PICKED_WITH_DATA) {
			if (data!=null && null != saveImage) {
				saveImage.onSaveBitmap(data);
			}
		}
		// 积分墙返回处理函数
		if (resultCode == RESULT_OK && requestCode == REQUSET_CODE) {
			if (data!=null&&data.getBooleanExtra("isAddCoins", false)) {
				runOnLuaThread(new Runnable() {
					@Override
					public void run() {
						HandMachine.getHandMachine().luaCallEvent(
								HandMachine.kUpdateUserInfo, null);
					}
				});
			}
		}
		
		// 分享截图弹窗隐藏回调
		if (requestCode == SHARE_DIALOG_CODE) {
			runOnLuaThread(new Runnable() {
				@Override
				public void run() {
					HandMachine.getHandMachine().luaCallEvent(
							HandMachine.kShareDialogHide, null);
				}
			});
		}		
		
		//
		// 通过以上方法可以获得PaySDK返回的订单号和状态码,如果状态码是"0000"代表支付成功,
		// 如果是"1111"代表支付失败,支付失败时,订单号为空;其它返回码请看
		// 0000 支付成功
		// 1111 支付失败
		// 8400 计费点为空
		// 8200 appKey为NULL或空
		// 8201 appKey必须为数字，且4位
		// 8101 amount不是数字且大于2位小数
		// 8100 amount为NULL或空
		// 8000 请求数据为空
		if (data!=null && resultCode == 8888 && requestCode == PAY_SDK_REQUEST_CODE) {
			Bundle bundle = data.getExtras();
			String orderId = bundle.getString("orderId");
			String result = bundle.getString("resultCode");
			// String result =
			// bundle.getString("reqOrderId");//(非必须，同serialNum,如果传入了serialNum,则该值等于serialNum,否则该值为空)
		}
		SendToQQUtil.onActivityResult(requestCode, resultCode, data);
	}
	
	public void showStartDialog() {
		if (null == mStartDialog) {
			mStartDialog = new AppStartDialog(this);
			mStartDialog.show();
		}
	}

	public void dismissStartDialog() {
		if (null != mStartDialog) {
			Game.mActivity.runOnUiThread(new Runnable() {
				@Override
				public void run() {
					// TODO Auto-generated method stub
					showStartAdDialog();
				}
			});
			try {
				Thread.sleep(1000);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			if (mStartDialog.isShowing()) {
				mStartDialog.dismiss();
			}
			mStartDialog = null;
		}
	}
	
	public void showStartAdDialog() {
		if (null == mStartAdDialog) {
			return;
		}
		if (is_open == 1){
			try {
				int time = ad_sec * 1000;
				String eventState = "ad_start_page_show"; //统计启动页展示事件
				onEventStat(eventState);
				mStartAdDialog.show();
				Window win = mStartAdDialog.getWindow();
				win.getDecorView().setPadding(0, 0, 0, 0);
				WindowManager.LayoutParams lp = win.getAttributes();
		        lp.width = WindowManager.LayoutParams.MATCH_PARENT;
		        lp.height = WindowManager.LayoutParams.MATCH_PARENT;
		        win.setAttributes(lp);
				gameHandler.sendEmptyMessageDelayed(HANDLER_CLOSE_START_AD_DIALOG,
						time);
            } catch (OutOfMemoryError e) {
            }
		}else{
			Game.mActivity.runOnLuaThread(new Runnable() {
				@Override
				public void run() {
					// TODO Auto-generated method stub
					HandMachine.getHandMachine()
					.luaCallEvent("CheckVersion","");
				}
			});
		}
	}
	
	public void dismissStartAdDialog() {
		if (null != mStartAdDialog) {
			if (mStartAdDialog.isShowing()) {
				mStartAdDialog.dismiss();
			}
			mStartAdDialog = null;
		}
		Game.mActivity.runOnLuaThread(new Runnable() {
			@Override
			public void run() {
				// TODO Auto-generated method stub
				HandMachine.getHandMachine()
				.luaCallEvent("CheckVersion","");
			}
		});
	}
	/*
	 * 获得广告页配置
	 */
	public static void getAdDialogPram(){
		is_open = dict_get_int("chinesechess_cache_data","start_is_open" ,0);
		ad_sec = dict_get_int("chinesechess_cache_data", "start_ad_sec", 5);
		ad_url = dict_get_string("chinesechess_cache_data","start_ad_jump");
//		ad_jump_url = dict_get_string("chinesechess_cache_data","start_ad_jump");
	}

	private void registerSinalListener() {
		// ---监听网络变化-----
		netWorkManager = new NetworkManager(Game.this);
		netWorkManager.registerSinalListener(new SinalCallBackInterface() {

			@Override
			public void onSinalChange(int level) {
				sinalLevel = level;
				final JSONObject jsonStr = new JSONObject();
				try {
					jsonStr.put("netState", sinalLevel + "");
				} catch (JSONException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				runOnLuaThread(new Runnable() {

					@Override
					public void run() {
						HandMachine.getHandMachine()
								.luaCallEvent(HandMachine.kNetStateChange,
										jsonStr.toString());
					}
				});

			}
		});
	}

	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		SchemesProxy.getInstance().setIntent(intent);
	}

	/**
	 * 报告lua错误
	 */
	public void reportLuaError(String error_info) {
		System.out.println("Game.reportLuaError : " + error_info);
		Log.e("lua", "Game.reportLuaError : " + error_info);
		MobclickAgent.reportError(this, error_info); // 向友盟发送错误报告

	}

	/**
	 * 打开一个ProgressDialog，适用于界面切换，等待
	 */
	private void showBackgroundDialog() {

	}

	/**
	 * 发一个延迟消息，通知关闭等待dialog
	 */
	private void sendDelayMessage() {

	}

	private void dismissBackgroundDialog() {

	}

	public class GameHandler extends Handler {
		@Override
		public void handleMessage(Message msg) {
			try {
				onHandleMessage(msg);
			} catch (URISyntaxException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
	public boolean closeSystemSleep() {
		if (null != wakeLock){
			Log.i("Lua", "Game --------------> BanDeviceSleep");
			wakeLock.acquire();
			return true;
		}
		return false;
	}
	
	public boolean openSystemSleep() {
		if (null != wakeLock){
			if (wakeLock.isHeld()){
				wakeLock.release();
				Log.i("Lua", "Game --------------> OpenDeviceSleep");
				return true;
			}
		}
		return false;
	} 

}
