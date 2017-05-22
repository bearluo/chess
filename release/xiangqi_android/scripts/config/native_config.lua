kLoginWin32 = "gen_guid"; -- win32登录

kLuacallEvent="event_call"; -- 原生语言调用lua 入口方法
kcallEvent = "LuaEventCall"; -- 获得 指令值的key

Kwin32Call="gen_guid";

kFBLogin="FBLogin"; -- facebook 登陆
kFBShare="FBShare"; -- facebook 分享
kFBLogout="FBLogout" -- facebook 退出
kGuestZhLogin="GuestZhLogin"; -- 简体游客 登陆
kGuestZwLogin="GuestZwLogin"; -- 繁体游客 登陆
kGuestLogout="GuestLogout" -- 游客 退出

----------------------ios----------------------
-- login
kIOSGuestZhLogin="IOSGuestZhLogin"; -- ios 游客登录

-- AppStorePay
kPayIOSAppStoreFail="payIOSAppStoreFailed"; --AppStore支付失败
kDeliverIOSProduct="deliverIOSProduct"; --通知后端发货 AppStore
kIOSLoading="iOSLoading";
kIosAppStoreEvaluate = "iosAppStoreEvaluate"-- AppStore评价
-----------------------------------------------
kLogin360 = "Login360"; --360登录
kRequest360UserInfo = "Request360UserInfo";
kOnGot360UserInfo = "OnGot360UserInfo";
kLogout360 = "Logout360"; --360退出
kSinaLogin="SinaLogin"; -- 新浪 登陆
kSinaShare="SinaShare"; -- 新浪 分享
kSinaLogout="SinaLogout" -- 新浪 退出
kQQConnectLogin="QQConnectLogin"; -- QQ互联 登陆
kQQConnectLogout="QQConnectLogout" -- QQ互联 退出
kRenRenLogin="RenRenLogin"; --人人 登陆
kRenRenShare="RenRenShare"; -- 人人 分享
kRenRenLogout="RenRenLogout" -- 人人 退出
kKaiXinLogin="KaiXinLogin"; -- 开心 登陆
kKaiXinLogout="KaiXinLogout" -- 开心 退出
kCallResult="CallResult"; --结果标示  0 -- 成功， 1--失败,2 -- ...
kResultPostfix="_result"; --返回结果后缀  与call_native(key) 中key 连接(key.._result)组成返回结果key
kparmPostfix="_parm"; --参数后缀 
kDownLoadImage = "DownLoadImage"  --下载图片

kUpLoadImage  = "UpLoadImage";    --上传图片
kNetStateChange  = "NetStateChange";    --上传图片
kLoadFeedBackImage  = "LoadFeedBackImage";-- 加载反馈图片,不需要上传
kUpLoadFeedBackImage = "UpLoadFeedBackImage"-- 用户点击提交反馈，上传反馈图片
kNetStateResume = "NetStateResume";-- 网络状态恢复
kStartWirelessSetting  = "StartWirelessSetting";    --跳转到无线设置
kStartHuoDongActivity = "StartHuoDongActivity";
kStartActivitySdk = "startActivitySdk";
kInitActivitySdk = "initActivitySdk";
kActivitySdkCallBack = "activitySdkCallBack";
kChangeStates = "changeStates";

kGetNetStateLevel  = "GetNetStateLevel";    --获取网络状态
kRegisterSinalReceiver = "registerSinalReceiver";
kUnregisterSinalReceiver  = "unregisterSinalReceiver";    
kUpdateUserInfo 	= "UpdateUserInfo";
kGetPhoneContacts 	= "GetPhoneContacts";
kAdSDKStatus = "AdSDKStatus";
kGetCityInfo = "GetCityInfo";
--获取手机信息
kGetPhoneInfo = "GetPhoneInfo";
kShowPointWall = "ShowPointWall";

kSendContactsSMS	= "SendContactsSMS";
kSendSMS	= "SendSMS";
kPhoneNo	= "PhoneNo";
kMsgContent= "MsgContent";
kMsgDownLoadUrl = "MsgDownLoadUrl";
kMsgConactName = "MsgConactName";
kParseEndGate =	"ParseEndGate";
kLoadEndGate = "LoadEndGate";
kLoadEndBoard = "LoadEndBoard";
kUpdateEndGate = "UpdateEndGate";
kDddDeliverLog = "DddDeliverLog";
kLoginWithQQ = "LoginWithQQ";
kAccessToken = "AccessToken";
kQQOpenid = "QQOpenid";

kLoginWithWeibo = "LoginWithWeibo";
kWeiboAccessToken = "WeiboAccessToken";
kWeiboUserId = "WeiboUserId";

kLoginMode = "LoginMode"
kLoginWaySelect = "LoginWaySelect"
kShowLoadProgress = "ShowLoadProgress"

kGetSIMCardType = "GetSIMCardType"
kEgameFeePay = "EgameFeePay"
kEndGateReplace = "EndGateReplace"

kGetNetConfig= "GetNetConfig";
kUpdateNetConfig = "UpdateNetConfig";
kForceUpdateNetConfig = "ForceUpdateNetConfig";
kVersionUpdateNetConfig = "VersionUpdateNetConfig";

kCancelSetting= "CancelSetting";

kLoginBoyaa = "LoginBoyaa";
kRegisterBoyaa = "RegisterBoyaa";
kInitBoyaaPay = "InitBoyaaPay";
kSaveNewUUID = "saveNewUUID";
kGetOldUUID = "getOldUUID";

kLoginWeChat = "loginWeChat";
kCacheImageManager = "CacheImageManager";
---ad 广告
AD_INIT = 1;
AD_SHOW_SUDOKU_DIALOG = 2;
AD_CANCEL = 3;
AD_SHOW_SUDOKU_DIALOG = 4;
AD_SHOW_BANNER_AD_DIALOG = 6;
AD_REMOVE_RECOMMEND_BAR = 7;
kAdMananger = "adMananger";

---friend 

kFriend_UpdateFriendOnlineNum = "friend_updateFriendOnlineNum";
kFriend_UpdateStatus = "friend_updateStatus";
kFriend_UpdateUserData = "friend_updateUserData";
kFriend_UpdateFriendsList = "friend_updateFriendsList";
kFriend_UpdateFollowList = "friend_updateFollowList";
kFriend_UpdateFansList = "friend_updateFansList";
kFriend_UpdateChatsList = "friend_updateChatsList";
kFriend_UpdateChatMsg = "friend_updateChatMsg";
kFriend_FollowCallBack = "friend_followCallBack";

--添加手机通讯录
kGetPhoneNumByPhoneAndSIM = "GetPhoneNumByPhoneAndSIM";

--棋友分享web页
kShareWebView = "ShareWebView";--显示webView
kShareWebViewRefresh = "ShareWebViewRefresh";--刷新网页
kShareWebViewClose = "ShareWebViewClose";--隐藏webView

--本地自己分享web页
kNativeWebView = "NativeWebView";--显示webView
kNativeViewRefresh = "NativeWebViewRefresh";--刷新webView
kNativeWebViewClose = "NativeWebViewClose";--隐藏webView

--收藏分享web页
kCollectWebView = "CollectWebView";--显示自己分享的webView
kCollectViewRefresh = "CollectWebViewRefresh";--刷新webView
kCollectWebViewClose = "CollectWebViewClose";--隐藏webView

kShareWebViewShare = "ShareWebViewShare";--调起分享页面
kShareWebViewForward = "ShareWebViewForward";--调起转发页面

kActivityWebView = "ActivityWebView" -- 调起活动
kActivityWebViewClose = "ActivityWebViewClose" -- 调起活动

--kShareInfo = "ShareInfo";--点击Android ShareDialog界面item，返回qipuName
kResponseShareInfo = "ResponseShareInfo"--php响应ShareInfo事件
kResponseShareInfoFail = "ResponseShareInfoFail"--php响应ShareInfo事件失败回调
kShareToBoyaa = "ShareToBoyaa"--分享到博雅棋友
kShareToPYQ = "ShareToPYQ";--分享到朋友圈
kShareToWX = "ShareToWX";--分享到微信
kUpLoadLog = "UpLoadLog";--分享到微信等平台数据上报
kShareToBoyaaSuccess = "ShareToBoyaaSuccess"--分享到博雅棋友成功
kShareToBoyaaFail = "ShareToBoyaaFail"--分享到博雅棋友失败

kSaveChess = "saveChess";--保存棋牌到本地
kSaveImage = "SaveImage";

-- 个推 2015/10/8
kInitGetuiSdk = "InitGetuiSdk";
kPushGeTuiMsg = "PushGeTuiMsg";


-- 残局

kEndingUtilNewInit = "EndingUtilNewInit";
kEndingUtilNewGetGatesData = "EndingUtilNewGetGatesData";
kEndingUtilNewGetSubGateJsonStrByTidAndSort = "JsonStrByTidAndSort";

-- 分享成功返回
kShareSuccessCallBack = "shareSuccessCallBack";

-- 获得应用缓存大小
kGetAppCacheSize = "GetAppCacheSize";
-- 清空缓存（或文件夹大小）
kCleanAppCache      = "CleanAppCache";