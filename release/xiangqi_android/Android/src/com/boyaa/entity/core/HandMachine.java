package com.boyaa.entity.core;

import java.util.TreeMap;

import android.content.Context;
import android.os.Bundle;
import android.os.Message;
import android.os.Vibrator;
import android.util.Log;

import com.boyaa.chinesechess.platform91.Game;
import com.boyaa.entity.common.utils.JsonUtil;
import com.boyaa.entity.guest.Guset;
import com.boyaa.entity.sysInfo.SystemInfo;
import com.boyaa.made.AppActivity;

public class HandMachine {

	private static HandMachine handMachine = null;
	public static HandMachine getHandMachine() {
		if (null == handMachine) {
			handMachine = new HandMachine();
		}
		return handMachine;
	}

	public final static int HANDMACHINE = 100;

	public final static int HANDLER_FB_GETDATA = 110;
	public final static int HANDLER_FB_LOGIN = 111;
	public final static int HANDLER_FB_LOGOUT = 112;
	
	public final static int HANDLER_SINA_LOGIN = 120;
	public final static int HANDLER_SINA_LOGOUT = 121; // 新浪 登陆
	public final static int HANDLER_SINA_RELOGIN = 122;
	public final static int HANDLER_SINA_LOGINWEB = 123;
	public final static int HANDLER_SINA_GETDATA = 124;
	
	
	
	public final static int HANDLER_RENRNE_LOGIN = 130;
	public final static int HANDLER_RENRNE_LOGOUT = 131;
	public final static int HANDLER_KAIXIN_LOGIN = 140;
	public final static int HANDLER_QQ_LOGIN = 150;
	public final static int GUESTZH_LOGIN = 160;
	public final static int GUESTZW_LOGIN = 170;
	
	public final static int HANDLER_360_LOGIN = 180;//360登录
	public final static int HANDLER_360_LOGOUT = 181;
	public final static int HANDLER_360_REQUEST_USERINFO = 182;
	
	public final static int BACK_KEY = 4;
	public final static int HOME_KEY = 411;
	public final static int HANDLER_EXIT = 412;
	
	
	public final static int VERSION = 510;
	public final static int UPDATEVERSION = 511;
	public final static int TOWEBPAGE = 512;
	
	
	public final static int SETMUSIC = 610;
	public final static int SETSOUND = 611;

	public final static int HANDLER_SAVE_IMAGE= 810;
	public final static int HANDLER_DOWNLOAD_IMAGE = 811;
	
	public final static int HANDLER_SAVE_FEED_BACK_IMAGE= 812;
	public final static int HANDLER_UPLOAD_FEED_BACK_IMAGE = 813;
	public final static int HANDLER_UPLOAD_IMAGE= 814;
	
	public final static int GUI_ENGINE = 901;  //LUA界面给引擎发数据
	public final static int REPORT_LUA_ERROR = 902;  //上报LUA错误
	public final static int ON_EVENT_STAT = 903;  //事件统计OnEventStat
	public final static int SHARE_TEXT_MSG = 904;  //分享文本信息
	public final static int SHARE_IMG_MSG = 905;  //分享图片信息
	public final static int TAKE_SCREEN_SHOT = 906;  //截屏保存
	
	public final static int HANDLER_PAY = 910;  //LUA发送支付请求
	public final static int HANDLER_REGISTER_NET_STATE_LISTNER = 911;  //注册监听
	public final static int HANDLER_UNREGISTER_NET_STATE_LISTNER = 912;  //取消监听
	public final static int HANDLER_GET_NET_STATE_LEVEL = 913;  //获得当前信号状态
	public final static int HANDLER_START_WIRELESS_SETTING = 914;  //StartWirelessSetting
	public final static int HANDLER_GET_PHONE_CONTACTS = 915;  //GetPhoneContacts

	public final static int HANDLER_PARSE_ENDGATE = 916;  //ParseEndGate
	public final static int HANDLER_LOAD_ENDGATE = 917;
	public final static int HANDLER_LOAD_ENDBOARD = 918;
	public final static int HANDLER_UPDATE_ENDGATE = 919;

	public final static int HANDLER_LOGIN_WITH_QQ = 920;
	public final static int HANDLER_GET_QQ_USERINFO = 921;
	public final static int HANDLER_SEND_SMS = 922;
	
	public final static int HANDLER_LOGIN_WITH_WEIBO = 923;
	public final static int HANDLER_GET_WEIBO_USERINFO = 924;
	public final static int HANDLER_GET_SIMCARD_TYPE = 925;
	public final static int HANDLER_EGAMEFREE_PAY = 926;  //EGame pay

	public final static int HANDLER_REPLACE_ENDGATE = 927;
	
	public final static int HANDLER_CANCEL_SETTING_ACTION = 928;
	
	//更新获取网络配置 
	public final static int HANDLER_GET_NETCONFIG = 931;
	public final static int HANDLER_UPDATE_NETCONFIG = 932;
	public final static int HANDLER_FORCE_UPDATE_NETCONFIG = 933;
	public final static int HANDLER_VERSION_UPDATE_NETCONFIG = 934;
	public final static int HANDLER_GET_NETSTATUS = 935;	
	
	public final static int HANDLER_LOGIN_WITH_BOYAA = 936;
	public final static int HANDLER_REGISTER_BOYAA = 937;

	public final static int HANDLER_SHOW_POINT_WALL = 939;//积分墙
	
	public final static int HANDLER_GET_PHONE_INFO = 940; 
	
	public final static int HANDLER_SAVE_UUID = 941;//保存uuid
	public final static int HANDLER_GET_UUID = 942;//获取uuid
	
	public final static int HANDLER_AD_MANANAGER = 943;// 广告sdk
	
	public final static int HANDLER_DEVICESHAKE = 944;// 震动
	public final static int HANDLER_SHAREWEB = 945;			// 棋友分享网页
	public final static int HANDLER_SHAREWEBREFRESH = 946;	// 刷新棋友分享网页
	public final static int HANDLER_SHAREWEBCLOSE = 947;	// 关闭棋友分享网页
	public final static int HANDLER_SHAREWEBSHARE = 948;	// 分享棋谱
	public final static int HANDLER_INITGETUISDK = 949;	// 初始化个推sdk
	public final static int HANDLER_LOADFEEDBACKSDK = 950;	// 加载反馈sdk
	public final static int HANDLER_INITFEEDBACKSDK = 970;	// 初始化反馈sdk
	
	public final static int SHARE_QIPU_BOYAA = 951;			//分享棋谱给博雅棋友
	public final static int SHARE_QIPU_BOYAA_SUCCESS = 952;	//分享棋谱给博雅棋友成功
	public final static int SHARE_QIPU_BOYAA_FAIL = 953;	//分享棋谱给博雅棋友失败
	public final static int HANDLER_RESPONSE_SHAREINFO = 954;		//响应shareInfo事件
	public final static int HANDLER_RESPONSE_SHAREINFO_FAIL = 955;	//响应shareInfo事件失败
	public final static int HANDLER_INSTALL_NWE_APK = 956;	//调起安装
	
	public final static int HANDLER_NATIVEWEB = 958;		// 显示本地分享网页
	public final static int HANDLER_NATIVEWEBREFRESH = 959;	// 刷新本地分享网页
	public final static int HANDLER_NATIVEWEBCLOSE = 960;	// 关闭本地分享网页
	public final static int HANDLER_SAVEIMAGE = 961;	//保存图片
	public final static int HANDLER_COLLECTWEB = 962;		// 显示收藏网页
	public final static int HANDLER_COLLECTWEBREFRESH = 963;	// 刷新收藏网页
	public final static int HANDLER_COLLECTWEBCLOSE = 964;	// 关闭收藏网页
	public final static int HANDLER_ACTIVITYWEB = 965;	// 显示活动网页
	public final static int HANDLER_ACTIVITYWEBCLOSE = 966;	// 关闭活动网页
	
	public final static int HANDLER_BANDEVICELSLEEP = 2001;//禁止系统自动休眠
	public final static int HANDLER_OPENDEVICELSELLP = 2002;//开启系统自动休眠
	
	public final static int HANDLER_CLOSE_START_AD_DIALOG = 2003; //关闭广告页面
	public final static int HANDLER_START_AD_DIALOG_JUMP_URL = 2004;//广告页面跳转
	
	public final static int HANDLER_START_GET_LOCATION_INFO = 2005;//获取城市信息
	public final static int HANDLER_GET_CACHE_SIZE = 2006;//获得手机内存大小
	public final static int HANDLER_CLEAN_CACHE = 2007;//清空应用缓存
	public final static int HANDLER_START_GET_CITY_INFO = 2008;//获取城市信息
	public final static int COPY_URL = 2010;//复制字符串
	
	
	
	public final static String kLuacallEvent = "event_call"; // 原生语言调用lua 入口方法
	public final static String kcallEvent = "LuaEventCall"; // 获得 指令值的key
	/****************SDK 接入命名***************/
	public final static String kFBLogin = "FBLogin"; // facebook 登陆
	public final static String kFBShare = "FBShare"; // facebook 分享
	public final static String kFBLogout = "FBLogout"; // facebook 注销
	public final static String kGuestZhLogin = "GuestZhLogin"; // 简体游客 登陆
	public final static String kGuestZwLogin = "GuestZwLogin"; // 繁体游客 登陆
	public final static String kSinaLogin = "SinaLogin"; // 新浪 登陆
	public final static String kSinaLogout = "SinaLogout"; // 新浪 注销
	public final static String kSinaShare = "SinaShare"; // 新浪 分享
	public final static String kQQConnectLogin = "QQConnectLogin"; // QQ互联 登陆
	public final static String kRenRenLogin = "RenRenLogin"; // 人人 登陆
	public final static String kRenRenShare = "RenRenShare"; // 人人 分享
	public final static String kRenRenLogout = "RenRenLogout"; // 人人 注销
	public final static String kKaiXinLogin = "KaiXinLogin"; // 开心 登陆
	public final static String kGui2Engine = "Gui2Engine";   // LUA界面调引擎的接口
	public final static String kEngine2Gui = "Engine2Gui";
	
	
	public final static String kAdMananger = "adMananger";
	
	public final static String kOSTimeoutCallback="OSTimeoutCallback"; //lua超时计时器


	public final static String kLogin360 = "Login360"; //360登录
	public final static String kOnGot360UserInfo = "OnGot360UserInfo";
	public final static String kLogout360 = "Logout360";//360注销
	public final static String kRequest360UserInfo = "Request360UserInfo";

	public final static String kReportLuaError  = "ReportLuaError" ;//上报lua错误
	public final static String kOnEventStat  = "OnEventStat" ;//事件统计
	public final static String kShareTextMsg  = "ShareTextMsg" ;//分享文本信息ShareTextMsg
	public final static String kCopyUrl  = "CopyUrl" ;//复制链接
	public final static String kShareImgMsg  = "ShareImgMsg" ;//分享图片信息ShareTextMsg
	public final static String kIsTimelineCb  = "IsTimelineCb" ;//分享到朋友圈
	public final static String kTakeScreenShot  = "TakeScreenShot" ;//分享图片信息TakeScreenShot
	public final static String kGetSIMCardType  = "GetSIMCardType" ;//获得GetSIMCardProvidersType
	public final static String kEgameFeePay  = "EgameFeePay" ;//EgameFeePay
	public final static String kBindLogin  = "AuthBindLogin" ;//第三方授权登陆
	

	//更新获取网络配置 
	public final static String kGetNetConfig = "GetNetConfig";
	public final static String kUpdateNetConfig = "UpdateNetConfig";
	public final static String kForceUpdateNetConfig = "ForceUpdateNetConfig";
	public final static String kVersionUpdateNetConfig = "VersionUpdateNetConfig";
	
	public final static String kCancelSetting  = "CancelSetting" ;//EgameFeePay

	
	
	public final static String kPay = "Pay"; //支付
	
	public final static String kNetStateChange = "NetStateChange"; //网络信号状态变化
	
	// 结果标示 0 -- 成功， // 1--失败,2 -- ...
	public final static String kCallResult = "CallResult"; 
	//返回结果后缀 与call_native(key) 中key 连接(key.._result)组成返回结果key
	
	/****************按键 处理***************/
	public final static String KBackKey = "BackKey"; // 返回键
	public final static String KHomeKey = "HomeKey"; // home键
	/****************结束程序************************/
	public final static String KExit = "Exit"; // 结束程序
	
	public final static String kResultPostfix = "_result"; 
	public final static String kparmPostfix = "_parm"; 
	//系统信息
	public final static String kVersion_sync = "Version_sync";
	public final static String kversionCode  = "versionCode"; 
	public final static String kversionName  = "versionName"; 

	public final static String kupdateVersion  = "updateVersion";
	public final static String kToWebPage  = "ToWebPage";  //打开某个页面
	public final static String kToWechatWebPage  = "ToWechatWebPage";  //打开某个页面

	public final static String ksetBgMusic  = "setBgMusic"; 
	public final static String kbgMusic__sync  = "bgMusic__sync";
	public final static String ksetBgSound  = "setBgSound"; 
	public final static String kbgSound__sync  = "bgSound__sync";
	
	//sava
	public final static String kUpLoadImage  = "UpLoadImage";
	public final static String kUpLoadImage2  = "UpLoadImage2";
	public final static String kSaveImageName="SaveImageName";
	
	//load
	public final static String kDownLoadImage  = "DownLoadImage";
	public final static String kImageName="ImageName";
	public final static String kImageUrl="ImageUrl";
	
	//loadFeedBackimg
	public final static String kLoadFeedBackImage  = "LoadFeedBackImage";
	public final static String kUpLoadFeedBackImage="UpLoadFeedBackImage";	
	
	public final static String kStartHuoDongActivity = "StartHuoDongActivity";
	public final static String kActivitySdkCallBack = "activitySdkCallBack";
	public final static String kShareSuccessCallBack = "shareSuccessCallBack";
	public final static String kShareFailCallBack = "shareFailCallBack";
	public final static String kChangeStates = "changeStates";
	public final static String kInitActivitySdk = "initActivitySdk";
	
	public final static String kShowPointWall = "ShowPointWall";
	
	
	public final static String kParseEndGate = "ParseEndGate";
	public final static String kLoadEndGate = "LoadEndGate";
	public final static String kLoadEndBoard = "LoadEndBoard";
	public final static String kUpdateEndGate = "UpdateEndGate";
	
	public final static String kEndGateReplace = "EndGateReplace";
	//wan   网络状态
	public final static String kkJumpWireless  = "JumpWireless";
	public final static String kGetNetStateLevel  = "GetNetStateLevel";
	public final static String kRegisterSinalReceiver  = "registerSinalReceiver";
	public final static String kUnregisterSinalReceiver  = "unregisterSinalReceiver";
	
	public final static String kUpdateUserInfo 	= "UpdateUserInfo";
	public final static String kWirelessSetting	= "WirelessSetting";
	public final static String kStartWirelessSetting	= "StartWirelessSetting";
	public final static String kGetPhoneContacts	= "GetPhoneContacts";
	public final static String kGetPhoneInfo	= "GetPhoneInfo";
	public final static String kSendContactsSMS	= "SendContactsSMS";
	public final static String kPhoneNo	= "PhoneNo";
	public final static String kMsgContent= "MsgContent";
	public final static String kMsgDownLoadUrl = "MsgDownLoadUrl";
	public final static String kMsgConactName= "MsgConactName";
	
	public final static String kDddDeliverLog= "DddDeliverLog";
	
	public final static String kLoginWithQQ  = "LoginWithQQ";
	public final static String kAccessToken = "AccessToken";
	public final static String kQQOpenid = "QQOpenid";
	
	public final static String  kContactStr= "ContactStr";
	public final static String  kSendSms= "SendSms";
	public final static String  kLoginMode= "LoginMode";

	public final static String kLoginWithWeibo  = "LoginWithWeibo";
	public final static String kWeiboAccessToken = "WeiboAccessToken";
	public final static String kWeiboUserId= "WeiboUserId";
	public final static String kLoginWaySelect  = "LoginWaySelect";
	public final static String kInitBoyaaPay = "InitBoyaaPay";
	public final static String kLoginBoyaa = "LoginBoyaa";   //boyaa 帐号登录
	public final static String kSaveNewUUID = "saveNewUUID";   
	public final static String kGetOldUUID = "getOldUUID";   
	public final static String kAdSDKStatus = "AdSDKStatus";   //广告sdk状态
	public final static String kGetPhoneNumByPhoneAndSIM = "GetPhoneNumByPhoneAndSIM";
	public final static String kPushGeTuiMsg = "PushGeTuiMsg";
	public final static String kInitFeedbackSdk ="InitFeedbackSdk";
	public final static String kLoadFeedbackSdk ="LoadFeedbackSdk";
	public final static String kEndingUtilNewInit = "EndingUtilNewInit";
	public final static String kEndingUtilNewGetGatesData = "EndingUtilNewGetGatesData";
	public final static String kJsonStrByTidAndSort = "JsonStrByTidAndSort";
	
	public final static String kGetAppCacheSize = "GetAppCacheSize";
	public final static String kCleanAppCache = "CleanAppCache";
	public final static String kCountToPHP = "CountToPHP";
	public final static String kShareDialogHide = "shareDialogHide";
	
	public final static String kPayFailed  = "PayFailed";
	public final static String kPaySuccess = "PaySuccess";
	
	public final static String kTakeShotComplete = "takeShotComplete";  //截屏完成
	private static Vibrator vibrator; 
	/**
	 * @param what
	 * @param data
	 */
	public void handle(int what , Object data) {

		switch (what) {
		case HANDLER_FB_GETDATA:
			 String fbData = getParm(kFBLogin);
			 Message fbMsg = new Message();
			 Bundle fbBundle = new Bundle();// 存放数据
			 fbBundle.putString("data", fbData);
			 fbMsg.what = HandMachine.HANDLER_FB_LOGIN;
			 fbMsg.setData(fbBundle);
			 AppActivity.getHandler().sendMessage(fbMsg);
			 break;
		case GUESTZH_LOGIN:
			Guset guest = new Guset();
			String str = "";
			if (null != data){
				str = data.toString();
			}
			guest.login(kGuestZhLogin ,str);
			break;
		case GUESTZW_LOGIN:
			Guset guestTw = new Guset();
			guestTw.login(kGuestZwLogin ,null);
			break;
		//按键
		case BACK_KEY:
			KeyDispose backKey = new KeyDispose();
			backKey.back(KBackKey, "");
			break;
		case HOME_KEY:
			KeyDispose homeKey = new KeyDispose();
			homeKey.home(KHomeKey, "");
			break;
		case HANDLER_EXIT:
			KeyDispose keyDispose = new KeyDispose();
			keyDispose.exit(KExit, "");
			break;
		case VERSION:
			SystemInfo systemInfo = new SystemInfo();
			systemInfo.setVersion();
			break;	
		case SETMUSIC:
			float music = 0.5f;
			try {
				music = Float.valueOf(AppActivity.dict_get_string(ksetBgMusic, kbgMusic__sync));
			} catch (NumberFormatException e) {
				Log.i("" , e.toString());
			}
			AppActivity.setBackgroundMusicVolume(music);
			break;
		case SETSOUND:
			float sound = 0.5f;
			try {
				sound = Float.valueOf(AppActivity.dict_get_string(ksetBgSound,kbgSound__sync));

			} catch (NumberFormatException e) {
				Log.i("" , e.toString());
			}
			AppActivity.setEffectsVolume(sound);
			break;
		case HANDLER_SINA_RELOGIN:
			TreeMap<String, Object> map = new TreeMap<String, Object>();
			JsonUtil jsonUtil = new JsonUtil(map);
			String result = jsonUtil.toString();
			HandMachine.getHandMachine().luaCallEvent(kSinaLogin , result);
			break;
		case HANDLER_DEVICESHAKE:
			vibrator = (Vibrator)Game.mActivity.getSystemService(Context.VIBRATOR_SERVICE);  
	        long [] pattern = {100,400,100,400};   // 停止 开启 停止 开启   
	        vibrator.vibrate(pattern,-1);	//重复两次上面的pattern 如果只想震动一次，index设为-1
			break;
		}
	}
	
	
	/**
	 * 向lua 传送数据
	 * @param key 指令
	 * @param result 结果 一般为json 格式字符串
	 */
	public void luaCallEvent(String key, String result) {
		Log.i(key, "获取数据成功： " +  key + ":" + result);
		AppActivity.dict_set_string(kcallEvent, kcallEvent, key);
		if (null != result){
			AppActivity.dict_set_int(key, kCallResult, 0);
			AppActivity.dict_set_string(key, key + kResultPostfix, result);
		}else{
			AppActivity.dict_set_int(key, kCallResult, 1);
		}
		AppActivity.call_lua(kLuacallEvent);
	}
	
	
	/**
	 * 向lua 传送数据
	 * @param key 指令
	 * @param result 结果 一般为json 格式字符串
	 */
	public void luaCallEvent(String luacallEvent , String key, String result) {
		Log.i(key, "获取数据成功： " +  key + ":" + result);
		AppActivity.dict_set_string(kcallEvent, kcallEvent, key);
		if (null != result){
			AppActivity.dict_set_int(key, kCallResult, 0);
			AppActivity.dict_set_string(key, key + kResultPostfix, result);
		}else{
			AppActivity.dict_set_int(key, kCallResult, 1);
		}
		
		AppActivity.call_lua(luacallEvent);
	}
	
	
	/**
	 * 向lua 传送数据
	 * @param key 指令
	 * @param result 失败原因
	 */
	public void luaCallEventFail(String key, String result) {
		Log.i(key, "获取数据失败： " +  key + ":" + result);
		AppActivity.dict_set_string(kcallEvent, kcallEvent, key);
		AppActivity.dict_set_int(key, kCallResult, 1);
		AppActivity.call_lua(kLuacallEvent);
	}
	
	/**
	 *获取参数值
	 */
	public String getParm(String key) {
		String param = AppActivity.dict_get_string(key, key + kparmPostfix);
		Log.i(key, "获取参数值： " +  param);
		return param;
	}
	
	/**
	 *保存参数值
	 */
	public void saveParm(String key,String value) {
		AppActivity.dict_set_string("chinesechess_cache_data",key,value);
	}
	
	public void saveParm(String key,int value) {
		AppActivity.dict_set_int("chinesechess_cache_data",key,value);
	}
	
	public void saveParm(String key,double value) {
		AppActivity.dict_set_double("chinesechess_cache_data",key,value);
	}

}
