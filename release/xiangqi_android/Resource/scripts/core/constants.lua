-- constants.lua
-- Author: Vicent Gong
-- Date: 2012-09-21
-- Last modification : 2013-07-02
-- Description: Babe kernel Constants and Definition

---------------------------------------Anim---------------------------------------
kAnimNormal	= 0;
kAnimRepeat	= 1;
kAnimLoop	= 2;
----------------------------------------------------------------------------------

---------------------------------------Res----------------------------------------
--format
kRGBA8888	= 0;
kRGBA4444	= 1;
kRGBA5551	= 2;
kRGB565		= 3;
kRGBGray	=0x100;

--filter
kFilterNearest	= 0;
kFilterLinear	= 1;
----------------------------------------------------------------------------------

---------------------------------------Prop---------------------------------------
--for rotate/scale
kNotCenter		= 0;
kCenterDrawing	= 1;
kCenterXY		= 2;
----------------------------------------------------------------------------------

--------------------------------------Align--------------------------------------
kAlignCenter		= 0;
kAlignTop			= 1;
kAlignTopRight		= 2;
kAlignRight			= 3;
kAlignBottomRight	= 4;
kAlignBottom		= 5;
kAlignBottomLeft	= 6;
kAlignLeft			= 7;
kAlignTopLeft		= 8;
---------------------------------------------------------------------------------

---------------------------------------Text---------------------------------------
--TextMulitLines
kTextSingleLine	= 0;
kTextMultiLines = 1;

kDefaultFontName	= ""
kDefaultFontSize 	= 24;

kDefaultTextColorR 	= 0;
kDefaultTextColorG 	= 0;
kDefaultTextColorB 	= 0;
----------------------------------------------------------------------------------

---------------------------------------Touch--------------------------------------
kFingerDown		= 0;
kFingerMove		= 1;
kFingerUp		= 2;
kFingerCancel	= 3;
----------------------------------------------------------------------------------

---------------------------------------Focus--------------------------------------
kFocusIn 	= 0;
kFocusOut 	= 1;
----------------------------------------------------------------------------------

---------------------------------------Scroll-------------------------------------
kScrollerStatusStart	= 0;
kScrollerStatusMoving	= 1;
kScrollerStatusStop		= 2;
----------------------------------------------------------------------------------

---------------------------------------Socket-------------------------------------
--SocketProtocal
kProtocalVersion 	= 1;
kProtocalSubversion	= 1;
KClientVersionCode 	= 1024;

--SocketStatus
kSocketConnected 		= 1;
kSocketReconnecting		= 2;
kSocketConnectivity		= 3;
kSocketConnectFailed	= 4;
kSocketUserClose		= 5;
kSocketSendFailed       = 6;
kSocketReadFailed       = 7;
kSocketRecvPacket		= 9;

kCloseSocketAsycWithEvent 	= 0;
kCloseSocketAsyc 			= 1;
kCloseSocketSync 			= -1;

--Socket type
kSocketRoom = "room";
kSocketHall	= "hall";
----------------------------------------------------------------------------------

---------------------------------------Http---------------------------------------
--http get/post
kHttpGet		= 0;
kHttpPost		= 1;
kHttpReserved	= 0;
-----------------------------------------------------------------------------------

-------------------------------------Bool values-----------------------------------
kTrue 	= 1;
kFalse 	= 0;
kNone 	= -1;
-----------------------------------------------------------------------------------

-------------------------------------Button----------------------------------------
kButtonUpInside 	= 1;
kButtonUpOutside 	= 2;
kButtonUp 			= 3;

-----------------------------------------------------------------------------------

-------------------------------------Direction-------------------------------------
kHorizontal 	= 1;
kVertical 		= 2;
-----------------------------------------------------------------------------------

---------------------------------------Platform------------------------------------
--ios
kScreen480x320		= "480x320" -- ios/android
kScreen960x640		= "960x640"
kScreen1024x768		= "1024x768"
kScreen2048x1536	= "2048x1536"

--android
kScreen1280x720		= "1280x720"
kScreen1280x800		= "1280x800"
kScreen1024x600		= "1024x600"
kScreen960x540		= "960x540"
kScreen854x480		= "854x480"
kScreen800x480		= "800x480"

--platform
kPlatformIOS 		= "ios";
kPlatformAndroid 	= "android";
kPlatformWp8 		= "wp8";
kPlatformWin32 		= "win32";
-----------------------------------------------------------------------------------

---------------------------------------Custom Render-------------------------------
kRenderPoints 			= 1;
kRenderLineStrip 		= 2;
kRenderLineLoop 		= 3;
kRenderLines 			= 4;
kRenderTriangleStrip 	= 5;
kRenderTriangleFan 		= 6;
kRenderTriangles 		= 7;

kRenderDataDefault 		= 0;
kRenderDataTexture 		= 16;
kRenderDataColors 		= 32;
kRenderDataAll 			= 48;
-----------------------------------------------------------------------------------

---------------------------------------Custom Blend--------------------------------

kBlendSrcZero=0;
kBlendSrcOne=1;
kBlendSrcDstColor=2;
kBlendSrcOneMinusDstColor=3;
kBlendSrcSrcAlpha=4;
kBlendSrcOneMinusSrcAlpha=5;
kBlendSrcDstAlpha=6;
kBlendSrcOneMinusDstAlpha=7;
kBlendSrcSrcAlphaSaturate=8;

kBlendDstZero=0;
kBlendDstOne=1;
kBlendDstSrcColor=2;
kBlendDstOneMinusSrcColor=3;
kBlendDstSrcAlpha=4;
kBlendDstOneMinusSrcAlpha=5;
kBlendDstDstAlpha=6;
kBlendDstOneMinusDstAlpha=7;

----------------------------------------------------------------------------------

----------------------------------Input ------------------------------------------
kEditBoxInputModeAny  		= 0;
kEditBoxInputModeEmailAddr	= 1;
kEditBoxInputModeNumeric	= 2;
kEditBoxInputModePhoneNumber= 3;
kEditBoxInputModeUrl		= 4;
kEditBoxInputModeDecimal	= 5;
kEditBoxInputModeSingleLine	= 6;


kEditBoxInputFlagPassword					= 0;
kEditBoxInputFlagSensitive					= 1;
kEditBoxInputFlagInitialCapsWord			= 2;
kEditBoxInputFlagInitialCapsSentence		= 3;
kEditBoxInputFlagInitialCapsAllCharacters	= 4;


kKeyboardReturnTypeDefault = 0;
kKeyboardReturnTypeDone = 1;
kKeyboardReturnTypeSend = 2;
kKeyboardReturnTypeSearch = 3;
kKeyboardReturnTypeGo = 4;



kKeyboardReturnTypeSend = 2;
kKeyboardReturnTypeSearch = 3;
kKeyboardReturnTypeGo = 4;

NO_SIMCARD= 0;     --no card	
CHINA_MOBILE_MM_STRONGCONN = 1;  --移动
CHINA_UNICOM = 2;  --联通 
CHINA_TELECOM = 3; --电信
CHINA_TIETONG= 4;  --中国铁通
CHINA_MOBILE_MM_RUOCONN = 5;  --移动mm弱联网

--site
UNKNOWN = -1; 
--hall
-- 1) 正常购买：0
-- 2) 破产购买：1
HALL_ORDER_SITE = 0;
HALL_BANKRUPT_ORDER = 1;
HALL_MALL_ORDER = 3;--金币商城

HALL_BUY_GOLD = 1;
NOT_ENOUGH_GOLD = 2;
ROOM_BUY_RICE = 3;
ROOM_BUY_GOLD = 4;
BANKRUPT_BUY_GOLD = 5;
HALL_SIGNUP_GOLD = 6;
MATCH_RELIVE_GOLD = 7;




-- 2、房间内（roomid）
-- 1) 正常购买：2000,2010,2020    // roomid + 0
-- 3) 破产购买：2001,2011,2021    // roomid + 1
-- ROOM_BANKRUPT_ORDER = 2011;


-- 房间 位置用房间号--buypos----


--================活动中心跳转类型==============
MATCH = 1;--比赛
FEEDBACK = 2;--反馈
STORE = 3;--比赛
LOBBY = 4;--反馈
EXCHANGECENTER = 5;--兑换
SMALLFARM = 6;--小农场
MIDDLEFARM = 7;--中农场
RICHFARM = 8;--富农场
NOTICE = 9;--公告

----------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

------------------------------------Language---------------------------------------
kZhCNLang="zh_CN";
kZhLang="zh";
kZhTW="zh_TW";
kZhHKLang="zh_HK";
kEnLang="en";
kFRLang="fr_FR";
-----------------------------------------------------------------------------------

------------------------------------Android Keys-----------------------------------
kBackKey="BackKey";
kHomeKey="HomeKey";
kEventPause="EventPause";
kEventResume="EventResume";
kExit="Exit";
-----------------------------------------------------------------------------------


-------------------------------------Sound-----------------------------------------
ksetBgSound = "setBgSound"; -- 设置音效 
kbgSoundsync="bgSound__sync";--设置音效数据 key
ksetBgMusic = "setBgMusic"; -- 设置音乐
kbgMusicsync="bgMusic__sync";-- 设置音乐数据 key
kPreloadSound="preloadSound";-- 预加载声音
-----------------------------------------------------------------------------------



-------------------------------------Android Update version------------------------
kVersion_sync="Version_sync"; -- 获得android 版本 
kversionCode  = "versionCode"; -- 获得android versionCode  数据 key
kversionName  = "versionName"; --  获得android versionName  数据 key
kupdateVersion ="updateVersion"; -- 更新版本
kupdateUrl = "updateUrl"; -- 设置更新版本数据 key

-----------------------------------------------------------------------------------
kCloseStartScreen = "CloseStartScreen"
kOSTimeoutCallback="OSTimeoutCallback";
kSetOSTimeout="SetOSTimeout";
kOSTimeout="OSTimeout";
kOSTimeoutId="id";
kOSTimeoutMs="ms";
kClearOSTimeout="ClearOSTimeout";
kWin32ConsoleColor = "win32_console_color"; -- win32 print_string 设置颜色
-----------------------------------------------------------------------------------


---------------- prop id -----------------
kLifeNum = "1";
kUndoNum = "2";
kTipsNum = "3";
kReviveNum = "4";
kLifeLimitNum = "5";



---------------- mail type ---------------
kMailAll = '1'; --全服消息
kMailSys = '2'; --系统消息
kMailUser = '3'; --用户消息
kMailMatch = '4'; --比赛消息
kMailGood = '5'; --商品消息

---------------- mail model type ---------
kMailTplDefault = '1'; --消息模板。只有关闭
kMailTplAction = '2'; --有动作。动作按钮的文本由action_text指定
kMailTplJump = '3'; --指定跳转
kMailTplMatch = '4'; --比赛领奖
kMailTplGoodPay = '5'; --商品支付
kMailTplGoodExchange = '6' --商品兑换 
kMailTpModifyMnick = '7' --修改个人昵称