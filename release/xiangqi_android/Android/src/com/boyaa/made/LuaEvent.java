package com.boyaa.made;

import java.io.File;
import java.io.UnsupportedEncodingException;
import java.security.NoSuchAlgorithmException;
import java.util.HashMap;
import java.util.UUID;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.Intent;
import android.os.Bundle;
import android.os.Message;
import android.util.Log;

import com.boyaa.activitysdk.ActivitySdkManager;
import com.boyaa.bl.tools.Crypt;
import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.chinesechess.platform91.HuoDongActivity;
import com.boyaa.chinesechess.platform91.wxapi.SendToWXUtil;
import com.boyaa.ending.EndingUtilNew;
import com.boyaa.entity.common.SDTools;
import com.boyaa.entity.core.HandMachine;
import com.boyaa.entity.update.ApkInstall;
import com.boyaa.entity.update.PatchUpdate;
import com.boyaa.proxy.SchemesProxy;
import com.boyaa.proxy.share.ShareManager;
import com.boyaa.qqapi.SendToQQUtil;
import com.boyaa.snslogin.UserInfo;
import com.boyaa.until.SMS;
import com.boyaa.util.MD5Util;
import com.boyaa.util.NetworkUtil;

public class LuaEvent {

	public static void test() {
	}

	public static void CommonEvent() {
		com.boyaa.common.CommonEvent.event();
	}
	
	public static void HttpPost() {
		AppHttpPost post = new AppHttpPost();
		post.Execute();
	}

	public static void OnLuaCall() {
		AppActivity.mActivity.OnLuaCall();
	}

	public static void HttpGetUpdate()
	{
//		AppHttpGetUpdate get = new AppHttpGetUpdate();
//		get.Execute();
		RefactorAppHttpGetUpdate get = new RefactorAppHttpGetUpdate();
		get.Execute();

	}
	
	public static void UUID()
	{
		String uuid = UUID.randomUUID().toString();
		AppActivity.dict_set_string("UUID", "ret",uuid);
	}
	public static void SetOSTimeout()
	{
		System.out.println("LuaEvent SetOSTimeout ");
		int id = AppActivity.dict_get_int("OSTimeout", "id", Game.TIMEOUT_MSG_ID_BEGIN);
		int ms = AppActivity.dict_get_int("OSTimeout", "ms", 1);
		System.out.println(String.format("LuaEvent SetOSTimeout id = %d,ms = %d",id,ms));
		Game.SetTimeout(id, ms);
	}
	public static void ClearOSTimeout()
	{
		int id = AppActivity.dict_get_int("OSTimeout", "id", Game.TIMEOUT_MSG_ID_BEGIN);
		System.out.println(String.format("LuaEvent ClearOSTimeout id = %d",id));
		Game.ClearTimeout(id);
	}
	//-------------------------应用分割线--------------------
	
	public static void Toast() {
		final String json = HandMachine.getHandMachine().getParm("Toast");
		Game.mActivity.runOnUiThread(new Runnable() {
			
			@Override
			public void run() {
				// TODO Auto-generated method stub
				android.widget.Toast.makeText(Game.mActivity, json, android.widget.Toast.LENGTH_LONG).show();
				
			}
		});
	}
	
	public static void CacheImageManager() {
		String json = HandMachine.getHandMachine().getParm("CacheImageManager");
		Log.e("aaa", json);
		try {
			com.boyaa.entity.images.CacheImageManager.doDownLoadImage(json);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public static void GetPhoneNumByPhoneAndSIM() throws UnsupportedEncodingException, JSONException {
		HashMap<String,String> ret = com.boyaa.bl.tools.Contacts.getPhoneContacts(Game.mActivity);
//		ret.addAll(com.boyaa.bl.tools.Contacts.getPhoneContacts(Game.mActivity));
		String retUrl = null;
		if(ret.size() > 0) {
			JSONObject jsonObject = new JSONObject(ret);
			try {
				jsonObject.put("ret",Crypt.encrypt(jsonObject.toString(), "^*%*&(boYaa^U*("));
				retUrl = jsonObject.toString();
			} catch (JSONException e) {
				e.printStackTrace();
				retUrl = null;
			} catch (NoSuchAlgorithmException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			Log.e("GetPhoneNumByPhoneAndSIM", retUrl);
		}else {
			retUrl = null;
			Log.e("GetPhoneNumByPhoneAndSIM", "null");
		}
		final String retStr = retUrl;
		Game.mActivity.runOnLuaThread(new Runnable() {
			
			@Override
			public void run() {
				// TODO Auto-generated method stub 
				HandMachine.getHandMachine().luaCallEvent(
						HandMachine.kGetPhoneNumByPhoneAndSIM, retStr);
			}
		});
	}
	
	public static void CloseStartScreen() {
		Message msg = new Message();
		msg.what = Game.HANDLER_CLOSE_START_DIALOG;
		Game.getGameHandler().sendMessage(msg);
	}
	
	/**通过登陆weibo登陆*/
	public static void LoginWithWeibo(){
		Game.loginCount = 0;

		String accessToken = HandMachine.getHandMachine().getParm(HandMachine.kWeiboAccessToken);
		String weiboUserId = HandMachine.getHandMachine().getParm(HandMachine.kWeiboUserId);	
		String LoginMode = HandMachine.getHandMachine().getParm(HandMachine.kLoginMode);

		if("0".equals(LoginMode)){
			sendMessage(HandMachine.kLoginWithWeibo , HandMachine.HANDLER_LOGIN_WITH_WEIBO);
		}else{
			UserInfo  mUserInfo = new UserInfo();
			mUserInfo.setAccessToken(accessToken);
			mUserInfo.setOpenid(weiboUserId);
			sendMessage(HandMachine.kLoginWithWeibo , HandMachine.HANDLER_GET_WEIBO_USERINFO,mUserInfo);		
		}
		
	}
	
	/**
	 * change new_uuid 找回帐号
	 */
	public static void saveNewUUID() {
		String uuid = HandMachine.getHandMachine().getParm(HandMachine.kSaveNewUUID);
		Message msg = Game.getGameHandler().obtainMessage();
		msg.what = HandMachine.HANDLER_SAVE_UUID;
		msg.obj = uuid;
		Game.getGameHandler().sendMessage(msg);
	}
	
	
	
	/**
	 * 获取本机uuid 
	 * 因为切换帐号的原因所以需要找回本机帐号
	 */
	public static void getOldUUID() {
		Message msg = Game.getGameHandler().obtainMessage();
		msg.what = HandMachine.HANDLER_GET_UUID;
		Game.getGameHandler().sendMessage(msg);
	}
	/**
	 * 简体游客登陆
	 */
	public static void GuestZhLogin() {

		HandMachine.getHandMachine().handle(HandMachine.GUESTZH_LOGIN, "");
	}
	
	/**
	 * 繁体游客登陆
	 */
	public static void GuestZwLogin() {
		HandMachine.getHandMachine().handle(HandMachine.GUESTZW_LOGIN , "");
	}
	
	public static void GetPhoneInfo(){
		Message msg = new Message();
		msg.what = HandMachine.HANDLER_GET_PHONE_INFO;
		Game.getGameHandler().sendMessage(msg);
	}

	public static void ShowPointWall(){
		String data = HandMachine.getHandMachine().getParm(HandMachine.kShowPointWall);
		Bundle bundle = new Bundle();
		bundle.putString("data", data);
//		Intent intent = new Intent(Game.,PointWallActivity.class);
//		intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
//		intent.putExtra("url", data);
//		Game.mActivity.startActivity(intent);		
		Message msg = new Message();
		msg.what = HandMachine.HANDLER_SHOW_POINT_WALL;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	}
	
	public static void Gui2Engine() {
		String line = HandMachine.getHandMachine().getParm(HandMachine.kGui2Engine);

		 Message msg = new Message();
		 Bundle bundle = new Bundle();// 存放数据
		 bundle.putString("data", line);
		 msg.what = HandMachine.GUI_ENGINE;
		 msg.setData(bundle);
		 Game.getGameHandler().sendMessage(msg);
	}
	
	/**
	 * 上报Lua错误
	 */
	public static void ReportLuaError() {
		System.out.println("LuaEvent.ReportLuaError");
		String line = HandMachine.getHandMachine().getParm(HandMachine.kReportLuaError);

		 Message msg = new Message();
		 Bundle bundle = new Bundle();// 存放数据
		 bundle.putString("data", line);
		 msg.what = HandMachine.REPORT_LUA_ERROR;
		 msg.setData(bundle);
		 Game.getGameHandler().sendMessage(msg);
	}
	
	
	/**
	 * 上报Lua错误
	 */
	public static void OnEventStat() {
		System.out.println("LuaEvent.OnEventStat");
		String line = HandMachine.getHandMachine().getParm(HandMachine.kOnEventStat);

		 Message msg = new Message();
		 Bundle bundle = new Bundle();// 存放数据
		 bundle.putString("data", line);
		 msg.what = HandMachine.ON_EVENT_STAT;
		 msg.setData(bundle);
		 Game.getGameHandler().sendMessage(msg);
	}
	
//	/**
//	 * 分享文字信息
//	 */
//	public static void ShareTextMsg() {
//		System.out.println("LuaEvent.ShareTextMsg");
//		String line = HandMachine.getHandMachine().getParm(HandMachine.kShareTextMsg);
//
//		 Message msg = new Message();
//		 Bundle bundle = new Bundle();// 存放数据
//		 bundle.putString("data", line);
//		 msg.what = HandMachine.SHARE_TEXT_MSG;
//		 msg.setData(bundle);
//		 Game.getGameHandler().sendMessage(msg);
//	}
	
//	/**
//	 * 分享图片信息
//	 */
//	public static void ShareImgMsg() {
//		String line = HandMachine.getHandMachine().getParm(HandMachine.kShareImgMsg);
//		com.boyaa.proxy.share.ShareManager.share(ShareManager.TYPE_IMG,line);
//	}
	
	/**
	 * 指定分享短信文本信息
	 */
	public static void ShareSMSMsg() {
		String line = HandMachine.getHandMachine().getParm("ShareSMSMsg");
		com.boyaa.proxy.share.ShareManager.share(ShareManager.TYPE_SMS,line);
	}
	
	/**
	 * 指定分享微博文本信息
	 */
	public static void ShareWEIBOMsg() {
		String line = HandMachine.getHandMachine().getParm("ShareWEIBOMsg");
		com.boyaa.proxy.share.ShareManager.share(ShareManager.TYPE_WEIBO,line);
	}
	
	/**
	 * 指定分享微信文本信息
	 */
	public static void ShareWEICHATMsg() {
		String line = HandMachine.getHandMachine().getParm("ShareWEICHATMsg");
		com.boyaa.proxy.share.ShareManager.share(ShareManager.TYPE_WEICHAT,line);
	}
	
	/**
	 * 指定分享朋友圈文本信息
	 */
	public static void SharePYQMsg() {
		String line = HandMachine.getHandMachine().getParm("SharePYQMsg");
		com.boyaa.proxy.share.ShareManager.share(ShareManager.TYPE_PYQ,line);
	}
	
	/**
	 * 指定分享QQ文本信息
	 */
	public static void ShareQQMsg() {
		String line = HandMachine.getHandMachine().getParm("ShareQQMsg");
		com.boyaa.proxy.share.ShareManager.share(ShareManager.TYPE_QQ,line);
	}
	
	/**
	 * 指定其他分享
	 */
	public static void ShareOther() {
		String line = HandMachine.getHandMachine().getParm(HandMachine.kShareImgMsg);
		com.boyaa.proxy.share.ShareManager.share(ShareManager.TYPE_OTHER,line);
	}
	
	/**
	 * 复制链接
	 */
	public static void CopyUrl() {
		String url = HandMachine.getHandMachine().getParm(HandMachine.kCopyUrl);
		Message msg = new Message();
		Bundle bundle = new Bundle();// 存放数据
		bundle.putString("data", url);
		msg.what = HandMachine.COPY_URL;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	} 
	
	/**
	 * 截屏
	 */
	public static void TakeScreenShot() {
		System.out.println("LuaEvent.TakeScreenShot");
		String line = HandMachine.getHandMachine().getParm(HandMachine.kTakeScreenShot);

		 Message msg = new Message();
		 Bundle bundle = new Bundle();// 存放数据
		 bundle.putString("data", line);
		 msg.what = HandMachine.TAKE_SCREEN_SHOT;
		 msg.setData(bundle);
		 Game.getGameHandler().sendMessage(msg);
	}
	
	public static void Pay() {				
		String data = HandMachine.getHandMachine().getParm(HandMachine.kPay);

		Message msg = new Message();
		Bundle bundle = new Bundle();// 存放数据
		bundle.putString("data", data);
		msg.what = HandMachine.HANDLER_PAY;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	}
	
	
	public static void EgameFeePay() {
		String data = HandMachine.getHandMachine().getParm(HandMachine.kEgameFeePay);
		
		Message msg = new Message();
		Bundle bundle = new Bundle();// 存放数据
		bundle.putString("data", data);
		msg.what = HandMachine.HANDLER_EGAMEFREE_PAY;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	}
	
//	public static void CMSmsPay() {		
//		 String data = HandMachine.getHandMachine().getParm(HandMachine.kCMSmsPay);
//
//		 Message msg = new Message();
//		 Bundle bundle = new Bundle();// 存放数据
//		 bundle.putString("data", data);
//		 msg.what = HandMachine.HANDLER_CM_SMSPAY;
//		 msg.setData(bundle);
//		 Game.getGameHandler().sendMessage(msg);
//	}
	
	public static void GetSIMCardType() {		
		String data = HandMachine.getHandMachine().getParm(HandMachine.kGetSIMCardType);

		 Message msg = new Message();
		 Bundle bundle = new Bundle();// 存放数据
		 bundle.putString("data", data);
		 msg.what = HandMachine.HANDLER_GET_SIMCARD_TYPE;
		 msg.setData(bundle);
		 Game.getGameHandler().sendMessage(msg);
	}
	
	/**
	 * FB登陆
	 */
	public static void FBLogout() {
		//HandMachine.getHandMachine().handle(HandMachine.HANDLER_FB_GETDATA , "");
		sendMessage(HandMachine.kFBLogout , HandMachine.HANDLER_FB_LOGOUT);
	}
	
	/**
	 * FB注销
	 */
	public static void FBLogin() {
		//HandMachine.getHandMachine().handle(HandMachine.HANDLER_FB_GETDATA , "");
		sendMessage(HandMachine.kFBLogin , HandMachine.HANDLER_FB_LOGIN);
	}
	
	/**
	 * 新浪(微游戏)登陆
	 */
	public static void SinaLogin() {
		//HandMachine.getHandMachine().handle(HandMachine.HANDLER_SINA_GETDATA , "");
		sendMessage(HandMachine.kSinaLogin , HandMachine.HANDLER_SINA_LOGIN);
	}
	
	
	/**
	 * RenRen登陆
	 */
	public static void RenRenLogin() {
		//HandMachine.getHandMachine().handle(HandMachine.HANDLER_FB_GETDATA , "");
		sendMessage(HandMachine.kRenRenLogin , HandMachine.HANDLER_RENRNE_LOGIN);
	}
	
	
	/**
	 *  RenRen 注销
	 */
	public static void RenRenLogout() {
		
		sendMessage(HandMachine.kRenRenLogout , HandMachine.HANDLER_RENRNE_LOGOUT);
	}
	
	/**
	 * 结束程序
	 */
	public static void Exit() {
		Message msg = new Message();
		msg.what = HandMachine.HANDLER_EXIT;
		Game.getGameHandler().sendMessage(msg);
	}
	
	/**
	 * 获得版本号
	 */
	public static void Version_sync() {
		HandMachine.getHandMachine().handle(HandMachine.VERSION, "");
	}
	
	
	/**
	 * 更新版本
	 */
	public static void updateVersion() {
				 
		Bundle bundle = new Bundle();// 存放数据
		String url = HandMachine.getHandMachine().getParm(HandMachine.kupdateVersion);
		String type = HandMachine.getHandMachine().getParm("UPDATEVERSION_FORCE");
	
		bundle.putString("data", url);
		bundle.putString("type", type);
		 
		Message msg = new Message();
		msg.what = HandMachine.UPDATEVERSION;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	}
	
	/**
	 * 转到某个页面
	 */
	public static void ToWebPage() {
		
		System.out.println("LuaEvent.ToWebPage");
				 
		Bundle bundle = new Bundle();// 存放数据
		String url = HandMachine.getHandMachine().getParm(HandMachine.kToWebPage);
		
		bundle.putString("data", url);
		 
		Message msg = new Message();
		msg.what = HandMachine.TOWEBPAGE;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	}
	
	/**
	 * 使用微信浏览器
	 */
	public static void ToWechatWebPage() {
		
		System.out.println("LuaEvent.ToWebPage");
				 
		Bundle bundle = new Bundle();// 存放数据
		String url = HandMachine.getHandMachine().getParm(HandMachine.kToWechatWebPage);
		SendToWXUtil.openWechatWeb(url);
	}
	
	/**
	 * 设置背景音乐
	 */
	public static void setBgMusic() {
		HandMachine.getHandMachine().handle(HandMachine.SETMUSIC, "");
	}
	
	/**
	 * 设置音效
	 */
	public static void setBgSound() {
		HandMachine.getHandMachine().handle(HandMachine.SETSOUND, "");
	}
	
	/**
	 * 震动
	 */
	public static void DeviceShake(){
		HandMachine.getHandMachine().handle(HandMachine.HANDLER_DEVICESHAKE, "");
	}
	
	/**
	 * 关闭屏幕自动休眠
	 */
	public static void BanDeviceSleep(){
		Log.i("Lua", " --------------> BanDeviceSleep");
		Message msg = new Message();
		Bundle bundle = new Bundle();
		msg.what = HandMachine.HANDLER_BANDEVICELSLEEP;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	}
	
	/**
	 * 开启屏幕自动休眠
	 */
	public static void OpenDeviceSleep(){
		Log.i("Lua", " --------------> OpenDeviceSleep");
		Message msg = new Message();
		Bundle bundle = new Bundle();
		msg.what = HandMachine.HANDLER_OPENDEVICELSELLP;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	}
	
	/**
	 * 获取城市信息
	 */
	public static void GetCityInfo(){
		Message msg = new Message();
		Bundle bundle = new Bundle();
		msg.what = HandMachine.HANDLER_START_GET_CITY_INFO;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	}
	
	/**
	 * 获取位置信息
	 */
	public static void GetLocationInfo(){
		Message msg = new Message();
		Bundle bundle = new Bundle();
		msg.what = HandMachine.HANDLER_START_GET_LOCATION_INFO;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	}
	
	
	/**
	 *  sina 注销
	 */
	public static void SinaLogout() {
		
		HandMachine.getHandMachine().handle(HandMachine.HANDLER_SINA_LOGOUT, "");
	}
	
	/**跳转到设置无线网络设置界面*/
	public static void StartWirelessSetting(){
		sendMessage(HandMachine.kWirelessSetting , HandMachine.HANDLER_START_WIRELESS_SETTING);
	}

	public static void GetPhoneContacts(){
		sendMessage(HandMachine.kGetPhoneContacts , HandMachine.HANDLER_GET_PHONE_CONTACTS);
	}
	
	
	/**发短信*/
	public static void SendSMS(){
//		SMS.registerReceiver(Game.mActivity);
		String phoneNo = HandMachine.getHandMachine().getParm(HandMachine.kPhoneNo);
		String MsgDownLoadUrl = HandMachine.getHandMachine().getParm(HandMachine.kMsgDownLoadUrl);
		String MsgConactName = HandMachine.getHandMachine().getParm(HandMachine.kMsgConactName);
		SMS.parseSendContent(phoneNo, MsgConactName, MsgDownLoadUrl);
	}
	
	
	public static void ContactStr(){
		String ContactStr = HandMachine.getHandMachine().getParm(HandMachine.kContactStr);
	}

	/**通过登陆QQ登陆*/
	public static void LoginWithQQ(){
		String accessToken = HandMachine.getHandMachine().getParm(HandMachine.kAccessToken);
		String openid = HandMachine.getHandMachine().getParm(HandMachine.kQQOpenid);	
		String LoginMode = HandMachine.getHandMachine().getParm(HandMachine.kLoginMode);

		if("0".equals(LoginMode)){
			sendMessage(HandMachine.kLoginWithQQ , HandMachine.HANDLER_LOGIN_WITH_QQ);
		}else{
			UserInfo  mUserInfo = new UserInfo();
			mUserInfo.setAccessToken(accessToken);
			mUserInfo.setOpenid(openid);
			sendMessage(HandMachine.kLoginWithQQ , HandMachine.HANDLER_GET_QQ_USERINFO,mUserInfo);		
		}
		
	}
	/**
	 * 广告
	 */
	public static void adMananger() {
		String data = HandMachine.getHandMachine().getParm(HandMachine.kAdMananger);
		Bundle bundle = new Bundle();
		bundle.putString("data", data);
		Message msg = new Message();
		msg.what = HandMachine.HANDLER_AD_MANANAGER;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	}
	
	
	public static void loginWeChat() {
		Log.e("loginWeChat","loginWeChat");
		SendToWXUtil.SendAuthToGetToken();
	}
	
	/**
	 *  选择并保存并上传图片
	 */
	public static void UpLoadImage() {
		sendMessage(HandMachine.kUpLoadImage , HandMachine.HANDLER_SAVE_IMAGE);
	}	
	
	/**
	 *  上传图片
	 */
	public static void UpLoadImage2() {
		sendMessage(HandMachine.kUpLoadImage2 , HandMachine.HANDLER_UPLOAD_IMAGE);
	}
	
	/**
	 * 下载图片
	 */
	public static void DownLoadImage() {
		//HandMachine.getHandMachine().handle(HandMachine.HANDLER_LOAD_IMAGE, "");

		sendMessage(HandMachine.kDownLoadImage , HandMachine.HANDLER_DOWNLOAD_IMAGE);
	}	
	// 上传反馈截图	
	public static void UpLoadFeedBackImage(){
		sendMessage(HandMachine.kUpLoadFeedBackImage , HandMachine.HANDLER_UPLOAD_FEED_BACK_IMAGE);
	}
	
	
	// 截取反馈图片
	public static void LoadFeedBackImage(){
		sendMessage(HandMachine.kLoadFeedBackImage , HandMachine.HANDLER_SAVE_FEED_BACK_IMAGE);
	}
	
	
	public static void GetNetStateLevel() {
		sendDelayMessage(HandMachine.kGetNetStateLevel , HandMachine.HANDLER_GET_NET_STATE_LEVEL,1000);
	}
	
	public static void registerSinalReceiver(){
		sendMessage(HandMachine.kRegisterSinalReceiver , HandMachine.HANDLER_REGISTER_NET_STATE_LISTNER);
    }
	
	public static void unregisterSinalReceiver(){
		sendMessage(HandMachine.kUnregisterSinalReceiver , HandMachine.HANDLER_UNREGISTER_NET_STATE_LISTNER);
    }


	public static void sendDelayMessage(String key , int what,long delayMills) {
		
		 String Data = HandMachine.getHandMachine().getParm(key);
		 Message msg = new Message();
		 Bundle bundle = new Bundle();// 存放数据
		 bundle.putString("data", Data);
		 msg.what = what;
		 msg.setData(bundle);
		 Game.getGameHandler().sendMessageDelayed(msg, delayMills);
	}	
	
	public static void sendMessage(String key , int what) {
	
		 String Data = HandMachine.getHandMachine().getParm(key);
		 Message msg = new Message();
		 Bundle bundle = new Bundle();// 存放数据
		 bundle.putString("data", Data);
		 msg.what = what;
		 msg.setData(bundle);
		 Game.getGameHandler().sendMessage(msg);
	}
	
	public static void sendMessage(String key , int what,Object obj) {
		 String Data = HandMachine.getHandMachine().getParm(key);
		 Message msg = Game.getGameHandler().obtainMessage(what, obj);
		 Game.getGameHandler().sendMessage(msg);
	}
	
	public static void startActivitySdk() {
		Game.mActivity.runOnUiThread(new Runnable() {
			
			@Override
			public void run() {
				ActivitySdkManager.gotoActivityView(Game.mActivity);
			}
		});
	}
	
	public static void initActivitySdk() {
		final String data = HandMachine.getHandMachine().getParm(HandMachine.kInitActivitySdk);
		Game.mActivity.runOnUiThread(new Runnable() {
			
			@Override
			public void run() {
				// TODO Auto-generated method stub
				try {
					ActivitySdkManager.init(Game.mActivity, data);
				} catch (Exception e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		});
	}
	
	public static void InitGetuiSdk() {
		Message msg = new Message();
		Bundle bundle = new Bundle();
		msg.what = HandMachine.HANDLER_INITGETUISDK;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	}
	
		public static void InitFeedbackSdk(){
		String data = HandMachine.getHandMachine().getParm(HandMachine.kInitFeedbackSdk);
		Message msg = new Message();
		Bundle bundle = new Bundle();
		bundle.putString("data", data);
		msg.what = HandMachine.HANDLER_INITFEEDBACKSDK;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);	
	}
	
	public static void LoadFeedbackSdk(){
		String data = HandMachine.getHandMachine().getParm(HandMachine.kLoadFeedbackSdk);
		Message msg = new Message();
		Bundle bundle = new Bundle();
		bundle.putString("data", data);
		msg.what = HandMachine.HANDLER_LOADFEEDBACKSDK;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);	
	}
	
	public static void StartHuoDongActivity(){
		String data = HandMachine.getHandMachine().getParm(HandMachine.kStartHuoDongActivity);
		Intent intent = new Intent(AppActivity.mActivity,HuoDongActivity.class);
		intent.putExtra("url", data);
		Game.mActivity.startActivity(intent);
	}
	
	public static void ParseEndGate(){
		String data = HandMachine.getHandMachine().getParm(HandMachine.kParseEndGate);
		Message msg = new Message();
		Bundle bundle = new Bundle();
		bundle.putString("data", data);
		msg.what = HandMachine.HANDLER_PARSE_ENDGATE;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	}
	
	public static void LoadEndGate(){
		Log.e("lua","LoadEndGate");
		String data = HandMachine.getHandMachine().getParm(HandMachine.kLoadEndGate);
		Message msg = new Message();
		Bundle bundle = new Bundle();
		bundle.putString("data", data);
		msg.what = HandMachine.HANDLER_LOAD_ENDGATE;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	}
	
	public static void LoadEndBoard(){
		String data = HandMachine.getHandMachine().getParm(HandMachine.kLoadEndBoard);
		Message msg = new Message();
		Bundle bundle = new Bundle();
		bundle.putString("data", data);
		msg.what = HandMachine.HANDLER_LOAD_ENDBOARD;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	}
	
	public static void UpdateEndGate(){
		String data = HandMachine.getHandMachine().getParm(HandMachine.kUpdateEndGate);
		Message msg = new Message();
		Bundle bundle = new Bundle();
		bundle.putString("data", data);
		msg.what = HandMachine.HANDLER_UPDATE_ENDGATE;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	}
	
	public static void EndGateReplace(){
		String data = HandMachine.getHandMachine().getParm(HandMachine.kEndGateReplace);
		Message msg = new Message();
		Bundle bundle = new Bundle();
		bundle.putString("data", data);
		msg.what = HandMachine.HANDLER_REPLACE_ENDGATE;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	}
	
	public static void GetNetConfig(){
		
		String data = HandMachine.getHandMachine().getParm(HandMachine.kGetNetConfig);
		Message msg = new Message();
		Bundle bundle = new Bundle();
		bundle.putString("data", data);
		msg.what = HandMachine.HANDLER_GET_NETCONFIG;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	}
	
	public static void UpdateNetConfig(){

		String data = HandMachine.getHandMachine().getParm(HandMachine.kUpdateNetConfig);
		Message msg = new Message();
		Bundle bundle = new Bundle();
		bundle.putString("data", data);
		msg.what = HandMachine.HANDLER_UPDATE_NETCONFIG;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	}
	
	public static void ForceUpdateNetConfig(){

		String data = HandMachine.getHandMachine().getParm(HandMachine.kForceUpdateNetConfig);
		Message msg = new Message();
		Bundle bundle = new Bundle();
		bundle.putString("data", data);
		msg.what = HandMachine.HANDLER_FORCE_UPDATE_NETCONFIG;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	}
	
	public static void VersionUpdateNetConfig(){

		String data = HandMachine.getHandMachine().getParm(HandMachine.kVersionUpdateNetConfig);
		Message msg = new Message();
		Bundle bundle = new Bundle();
		bundle.putString("data", data);
		msg.what = HandMachine.HANDLER_VERSION_UPDATE_NETCONFIG;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	}
	
	public static void ShareWebView(){
		String data = HandMachine.getHandMachine().getParm("ShareWebView");
		Message msg = new Message();
		Bundle bundle = new Bundle();
		bundle.putString("data", data);
		msg.what = HandMachine.HANDLER_SHAREWEB;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	}
	
	public static void ShareWebViewRefresh(){
		Message msg = new Message();
		Bundle bundle = new Bundle();
		msg.what = HandMachine.HANDLER_SHAREWEBREFRESH;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	}
	
	public static void ShareWebViewClose(){
		Message msg = new Message();
		Bundle bundle = new Bundle();
		msg.what = HandMachine.HANDLER_SHAREWEBCLOSE;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	}
	
	public static void NativeWebView(){
		String data = HandMachine.getHandMachine().getParm("NativeWebView");
		Message msg = new Message();
		Bundle bundle = new Bundle();
		bundle.putString("data", data);
		msg.what = HandMachine.HANDLER_NATIVEWEB;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
//		Intent intent = new Intent(AppActivity.mActivity,ShareActivity.class);
//		intent.putExtra("url", "file:///android_asset/t/index.html");
//		Game.mActivity.startActivity(intent);
	}
	
	public static void NativeWebViewRefresh(){
		Message msg = new Message();
		Bundle bundle = new Bundle();
		msg.what = HandMachine.HANDLER_NATIVEWEBREFRESH;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	}
	
	public static void NativeWebViewClose(){
		Message msg = new Message();
		Bundle bundle = new Bundle();
		msg.what = HandMachine.HANDLER_NATIVEWEBCLOSE;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	}
	
	public static void ActivityWebView() {
		String data = HandMachine.getHandMachine().getParm("ActivityWebView");
		Message msg = new Message();
		Bundle bundle = new Bundle();
		bundle.putString("data", data);
		msg.what = HandMachine.HANDLER_ACTIVITYWEB;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	}
	
	public static void ActivityWebViewClose(){
		Message msg = new Message();
		Bundle bundle = new Bundle();
		msg.what = HandMachine.HANDLER_ACTIVITYWEBCLOSE;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	}
	
	public static void GetInternalUpdatePathForLua(){
		SDTools.getInternalUpdatePathForLua(Game.mActivity);
	}

	public static void GetSDCardStateForLua() {
		SDTools.getSDCardStateForLua();
	}
	
	public static void ApkInstall(){
		String newApkPath = Game.dict_get_string("patchUpdate","newApkPath");
		Message msg = new Message();
		Bundle bundle = new Bundle();// 存放数据
		bundle.putString("newApkPath", newApkPath);
		msg.what = HandMachine.HANDLER_INSTALL_NWE_APK;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	}
	
	public static void PatchInstall() {
		String newPatchPath = Game.dict_get_string("patchUpdate","newPatchPath");
		PatchUpdate.exAsyncTask(Game.mActivity.appPackageResourcePath, newPatchPath+".apk", newPatchPath);
	}
	
	public static void LuaInstall() {
		String newLuaPath = Game.dict_get_string("patchUpdate","newLuaPath");
		ApkInstall apkInstall = new ApkInstall();
		String outFullPath = Game.mActivity.getFilesDir() + File.separator + "update";
		apkInstall.startZipInstall(newLuaPath,outFullPath);
	}
	
	public static void GetNetWorkTypeForLua(){
		String networkType = NetworkUtil.getNetworkType(Game.mActivity)+"";
		AppActivity.dict_set_string("TerminalInfoTable", "network_type", networkType);
	}
	
	public static void ExistApkFile(){
		String apkPath = Game.dict_get_string("ExistApkFile","filePath");
		if (new File(apkPath).exists()) {
			AppActivity.dict_set_int("ExistApkFile", "fileExist", 1);
		}else{
			AppActivity.dict_set_int("ExistApkFile", "fileExist", 0);
		}
	}
	
	public static void HttpCancelUpdate() {
		RefactorAppHttpGetUpdate.cancelUpdateDownloadById();
	}
	
	public static void VerifyMD5(){
		MD5Util.startVerify();
	}
	
	public static void SaveImage(){
		String imageName = HandMachine.getHandMachine().getParm("SaveImage");
		Message msg = new Message();
		Bundle bundle = new Bundle();// 存放数据
		bundle.putString("imageName", imageName);
		msg.what = HandMachine.HANDLER_SAVEIMAGE;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	}
	
	public static void EndingUtilNewInit() {
		String jsonStr = HandMachine.getHandMachine().getParm("EndingUtilNewInit");
		EndingUtilNew.Init(jsonStr);
	}
	
	public static void EndingUtilNewGetGatesData() {
		Game.mActivity.runOnLuaThread(new Runnable() {//
			@Override
			public void run() {
				HandMachine.getHandMachine().luaCallEvent(HandMachine.kEndingUtilNewGetGatesData,EndingUtilNew.getGatesData());
			}
		});
	}
	
	public static void JsonStrByTidAndSort() {
		String jsonStr = HandMachine.getHandMachine().getParm("JsonStrByTidAndSort");
		try {
			JSONObject jsonObject  = new JSONObject(jsonStr);
			final int tid = jsonObject.getInt("tid");
			final int sort = jsonObject.getInt("sort");
			Game.mActivity.runOnLuaThread(new Runnable() {//
				@Override
				public void run() {
					HandMachine.getHandMachine().luaCallEvent(
							HandMachine.kJsonStrByTidAndSort,
							EndingUtilNew.getSubGateJsonStrByTidAndSort(tid, sort));
				}
			});
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			Game.mActivity.runOnLuaThread(new Runnable() {//
				@Override
				public void run() {
					HandMachine.getHandMachine().luaCallEvent(
							HandMachine.kJsonStrByTidAndSort,
							null);
				}
			});
		}
		
//		EndingUtilNew.getSubGateJsonStrByTidAndSort(tid, sort);
	}
	
	/**
	 * 获得应用缓存大小
	 */
	public static void GetAppCacheSize(){
		Message msg = new Message();
		Bundle bundle = new Bundle();
		msg.what = HandMachine.HANDLER_GET_CACHE_SIZE;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	}
	
	/**
	 * 清空缓存
	 */
	public static void CleanAppCache(){
		Message msg = new Message();
		Bundle bundle = new Bundle();
		msg.what = HandMachine.HANDLER_CLEAN_CACHE;
		msg.setData(bundle);
		Game.getGameHandler().sendMessage(msg);
	}
	/**
	 * 获得唤醒应用的intent数据
	 */
	public static void getIntentData() {
		String data = SchemesProxy.getInstance().getIntentData();
		AppActivity.dict_set_string("Schemes", "IntentData", data);
	}
	
	/**
	 * 清理唤醒应用的intent数据
	 */
	public static void clearIntentData() {
		SchemesProxy.getInstance().clearIntentData();
	}
	
	/**
	 * QQ互联登陆授权
	 */
	public static void QQConnectLogin() {
		SendToQQUtil.qqAuthLogin();
	}
	
	
	/**
	 * 调用分享
	 * @param type
	 */
//	private static void ShareEvent(int type){
//		System.out.println("LuaEvent.ShareImgMsg");
//		String line = HandMachine.getHandMachine().getParm(HandMachine.kShareTextMsg);
//		String line1 = HandMachine.getHandMachine().getParm(HandMachine.kShareImgMsg);
//		com.boyaa.proxy.share.ShareManager.share(line, type);
//	}
}