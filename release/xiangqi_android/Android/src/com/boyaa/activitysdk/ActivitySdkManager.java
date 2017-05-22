package com.boyaa.activitysdk;

import org.json.JSONObject;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Build;
import android.util.Log;

//import com.boyaa.adsdk.AdMananger;
import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.entity.core.HandMachine;
import com.boyaa.until.Util;

public class ActivitySdkManager {
	private static int activityDebug;
	private static String mid;
	private static String appid;
	private static String api;
	private static String version;
	private static String sitemid;
	private static String usertype;
	private static String deviceno;
//    -- 复制收藏（h5）
	private static int collect_manual;
//    -- 收藏棋谱(lua内)
	private static int save_manual;
//    -- 评论
	private static int comment_manual;
//   php 校验码
	private static String access_token;
	public static void init(Context context, String jsonStr) throws Exception {
//		BoyaaAPI boyaa_api = BoyaaAPI.getInstance(context);
//		BoyaaAPI.BoyaaData boyaa_data = boyaa_api.getBoyaaData(context);
		JSONObject jsonObject = new JSONObject(jsonStr);
//		boyaa_data.cut_service(jsonObject.getInt("activityDebug")); // 这里1代表测试服务器，0代表正式服务器，传其他的值没有用的哦
//		boyaa_data.setMid(jsonObject.getString("mid"));
//		boyaa_data.setVersion(jsonObject.getString("version"));
//		boyaa_data.setApi("A_" + jsonObject.getString("usertype"));// 不清楚为什么要用这个··？
//		boyaa_data.setAppid(jsonObject.getString("bid")); //
//		boyaa_data.setSitemid(jsonObject.getString("sitemid"));// 第三方登录的
//		boyaa_data.setUsertype(jsonObject.getString("usertype"));//
//		boyaa_data.setDeviceno(Util.getImeiNum());//
//		boyaa_data.set_lua_class("com.boyaa.activitysdk.ActivitySdkManager"); // 设定sdk调用lua
//																				// 的类名
//		boyaa_data.set_lua_method("activityCallBack"); // 设定sdk调用lua 的方法名
//		boyaa_data.finish();

		/* 活动推荐 自定义 */
		ActivitySdkManager.activityDebug = jsonObject.getInt("activityDebug");
		ActivitySdkManager.mid = jsonObject.getString("mid");
		ActivitySdkManager.version = jsonObject.getString("version");
		ActivitySdkManager.usertype = jsonObject.getString("usertype");
		ActivitySdkManager.appid = jsonObject.getString("bid");
		ActivitySdkManager.sitemid = jsonObject.getString("sitemid");
		ActivitySdkManager.api = "A_" + jsonObject.getString("usertype");

//	    -- 复制收藏（h5）
		ActivitySdkManager.collect_manual = jsonObject.getInt("collect_manual");
//	    -- 收藏棋谱(lua内)
		ActivitySdkManager.save_manual  = jsonObject.getInt("save_manual");
//	    -- 评论
		ActivitySdkManager.comment_manual  = jsonObject.getInt("comment_manual");
	//   php 校验码
		ActivitySdkManager.access_token  = jsonObject.optString("access_token");
		ActivitySdkManager.deviceno = Util.getImeiNum();
		/* 初始化广告sdk  */
		ApplicationInfo info;
		String msg = "unknow";
		try {
			info = Game.mActivity.getPackageManager().getApplicationInfo(Game.mActivity.getPackageName(),PackageManager.GET_META_DATA);
			msg = info.metaData.getString("UMENG_CHANNEL");
		} catch (NameNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		Log.e("channelname", " msg == " + msg );
//		AdMananger.init(Game.mActivity, msg,jsonObject.getString("mid"));
	}

	public static String getAPIUrl() {
		String url = "";
		url = url + "{";
		if (mid != null)
			url = url + "\"mid\":\"" + mid + "\",";
		if (api != null)
			url = url + "\"api\":\"" + api + "\",";
		if (version != null)
			url = url + "\"version\":\"" + version + "\",";
		if (sitemid != null)
			url = url + "\"sitemid\":\"" + sitemid + "\",";
		if (appid != null)
			url = url + "\"appid\":\"" + appid + "\",";
		if (usertype != null)
			url = url + "\"sid\":\"" + usertype + "\",";
		if (deviceno != null)
			url = url + "\"deviceno\":\"" + deviceno + "\",";
		url = url + "\"networkstate\":\"" + getNetWorkAccess(Game.mActivity) + "\",";
		url = url + "\"osversion\":\"" + Build.VERSION.RELEASE + "\",";

		url = url.substring(0, url.length() - 1);
		url = url + "}";
		return url;
	}
	
	public static String getNetWorkAccess(Context context) {
		ConnectivityManager conMan = (ConnectivityManager) context
				.getSystemService("connectivity");

		NetworkInfo.State mobile = conMan.getNetworkInfo(0).getState();

		NetworkInfo.State wifi = conMan.getNetworkInfo(1).getState();
		if (mobile == NetworkInfo.State.CONNECTED)
			return "WLAN";
		if (wifi == NetworkInfo.State.CONNECTED)
			return "WIFI";
		return "UNKNOWN";
	}

	public static void activityCallBack(final String a, final String json) {
		if (a != null)
			Log.e("aaa", a);// 这个参数没用···
		if (json != null)
			Log.e("aaa", json);
		Game.mActivity.runOnLuaThread(new Runnable() {

			@Override
			public void run() {
				// TODO Auto-generated method stub
				HandMachine.getHandMachine().luaCallEvent(
						HandMachine.kActivitySdkCallBack, json);
			}
		});
	}

	public static void gotoActivityView(Context context) {
//		BoyaaAPI boyaa_api = BoyaaAPI.getInstance(context);
//		boyaa_api.display(); // 执行sdk，进入活动中心
	}
	

	public static String getMid() {
		return mid;
	}

	public static void setMid(String mid) {
		ActivitySdkManager.mid = mid;
	}

	public static String getAppid() {
		return appid;
	}

	public static void setAppid(String appid) {
		ActivitySdkManager.appid = appid;
	}

	public static String getApi() {
		return api;
	}

	public static void setApi(String api) {
		ActivitySdkManager.api = api;
	}

	public static String getVersion() {
		return version;
	}

	public static void setVersion(String version) {
		ActivitySdkManager.version = version;
	}

	public static String getSitemid() {
		return sitemid;
	}

	public static void setSitemid(String sitemid) {
		ActivitySdkManager.sitemid = sitemid;
	}

	public static String getUsertype() {
		return usertype;
	}

	public static void setUsertype(String usertype) {
		ActivitySdkManager.usertype = usertype;
	}

	public static String getDeviceno() {
		return deviceno;
	}

	public static void setDeviceno(String deviceno) {
		ActivitySdkManager.deviceno = deviceno;
	}

	public static int getActivityDebug() {
		return activityDebug;
	}

	public static void setActivityDebug(int activityDebug) {
		ActivitySdkManager.activityDebug = activityDebug;
	}

	public static int getCollect_manual() {
		return collect_manual;
	}

	public static void setCollect_manual(int collect_manual) {
		ActivitySdkManager.collect_manual = collect_manual;
	}

	public static int getSave_manual() {
		return save_manual;
	}

	public static void setSave_manual(int save_manual) {
		ActivitySdkManager.save_manual = save_manual;
	}

	public static int getComment_manual() {
		return comment_manual;
	}

	public static void setComment_manual(int comment_manual) {
		ActivitySdkManager.comment_manual = comment_manual;
	}

	public static String getAccess_token() {
		return access_token;
	}

	public static void setAccess_token(String access_token) {
		ActivitySdkManager.access_token = access_token;
	}
}
