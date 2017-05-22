
PhpConfig = class();

------------------------------------------------------------------------------------




PhpConfig.FEEDBACK_URL = "http://feedback.kx88.net/api/api.php";   --   反馈地址

PhpConfig.developTest = "http://chesstest.boyaa.com:90/"; -- 测试服
PhpConfig.developMainUrl = "http://snspcs03.ifere.com/"; -- 正式服

PhpConfig.isTest = kDebug; -- 一键修改正式服测试服

PhpConfig.developUrl = (PhpConfig.isTest and PhpConfig.developTest) or PhpConfig.developMainUrl;

PhpConfig.chess_android= "chess_android/application/";

PhpConfig.develop = PhpConfig.developUrl..PhpConfig.chess_android;
PhpConfig.requestUrl =PhpConfig.developUrl;

PhpConfig.new_developTest = "http://192.168.100.153/chess/" -- 新测试服
PhpConfig.new_developMainUrl = "http://cnchess.17c.cn/chess/"-- 新正式服

PhpConfig.h5_developTest = "http://chess153.by.com/chess/h5/";--测试服H5地址
PhpConfig.h5_developMainUrl = "http://cnchess.17c.cn/chess/h5/";--正式服H5地址

PhpConfig.new_developUrl = (PhpConfig.isTest and PhpConfig.new_developTest) or PhpConfig.new_developMainUrl;
PhpConfig.h5_developUrl = (PhpConfig.isTest and PhpConfig.h5_developTest) or PhpConfig.h5_developMainUrl;

------------------feedback
PhpConfig.APPID_FEEDBACK = 4005;   --
PhpConfig.GAME = "xq";
PhpConfig.FTYPE = 1;   --INITFEEDBACK接口返回的类型之一
if kPlatform == kPlatformIOS then
    PhpConfig.TITLE = "ios象棋"
else
    PhpConfig.TITLE = "Android象棋"
end;
PhpConfig.CURRENT_KEY = "M";

PhpConfig.getFeedBackOSInfo = function()
    local title = PhpConfig.getOsInfo() .. "客户端版本:" .. VERSIONS .. "#bid:" .. PhpConfig.getBid();
    return title;
end

---------------feedback end

---------------------------method

PhpConfig.METHOD_VISITOR_UPLOADICON        = "IconAndroid.upload";   --头像上传;
PhpConfig.METHOD_FEEDBACK_SENDFEEDBACK     = "Feedback.sendFeedBack"; --上传反馈内容
PhpConfig.METHOD_FEEDBACK_SENDFEEDBACK_IMG = "Feedback.mSendFeedBackPicture";  --上传反馈图片
PhpConfig.METHOD_GET_FEEDBACK   = "Feedback.mGetFeedback";
PhpConfig.METHOD_SEMD_FEEDBACK_SCORE   = "Feedback.mPostScore";
PhpConfig.METHOD_NOTICE_GETLIST = "notice.getList";
PhpConfig.METHOD_SHOW   = "show";   --是否显示登陆奖
PhpConfig.METHOD_REWARD = "Reward";   --2、领取登陆奖
PhpConfig.METHOD_COLLAPSE_REWARD = "getCollapseReward";  --破产
PhpConfig.METHOD_USERINFO = "getGameInfoByMid" --根据游戏ID获取玩家游戏信息
PhpConfig.METHOD_GOODS_ID = "getMonetary" --获取商品ID
PhpConfig.METHOD_PLACE_ORDER = "createOrder" --下订单
PhpConfig.METHOD_PAY_ORDER = "payOrder" --请求发货
PhpConfig.METHOD_GET_360ACCESSTOKEN = "get360AccessToken"
PhpConfig.METHOD_GET_MSG = "getMsgByMid" --获取消息
PhpConfig.METHOD_GET_MSG_COUNT = "getCountBymid" --获取消息数量
PhpConfig.METHOD_DEL_MSG = "delMsg" --删除消息
PhpConfig.METHOD_WATCH_GAME_LIST = "getWatchGameList";   --观战列表


PhpConfig.METHOD_ADD_IDCARD_INFO = "addIdcardInfo";   --addIdcardInfo
PhpConfig.METHOD_GETPROP = "getPropList";--获取道具列表
PhpConfig.METHOD_GETONEPROP = "getOneProp";--获取道具详细信息
PhpConfig.METHOD_ENDING_GAME_RSYNC = "rsync";   --上传关卡进度
PhpConfig.METHOD_ENDING_GAME_BOOTH_INFO = "getGateInfo";   ----获取残局数据
PhpConfig.METHOD_ENDING_GAME_SEVERDATA = "getServerData";   --下载关卡进度
PhpConfig.METHOD_ADDDELIVERLOG = "addDeliverLog";--客户端通知php已发货
PhpConfig.METHOD_CHECK_ENDING_UPDATE = "checkUpdate";--检查残局更新
PhpConfig.METHOD_GET_FRIENDS_LIST = "getList" --获取好友列表
PhpConfig.METHOD_VERIFY_TELNO = "sendSms" --发送验证码短信
PhpConfig.METHOD_CHECK_VERIFY_CODE = "checkSmsCode" --验证验证码
PhpConfig.METHOD_UPLOAD_ADDRESS_BOOK = "uploadAddressBook" --上传通讯录
PhpConfig.METHOD_GET_MYFRIEND_LIST = "getMyFriendList" --获取好友列表
PhpConfig.METHOD_GET_FPLAY_PROGRESS = "getFPlayProgress";--获取玩家好友残局游戏进度

PhpConfig.METHOD_GET_CONSOLE_PROGRESS = "getServerData";--获取玩家单机游戏进度
PhpConfig.METHOD_SYNC_CONSOLE_PROGRESS = "rsync";--上传玩家单机游戏进度

PhpConfig.METHOD_SYNC_PROPINFO = "propInfo"; --上传或下载道具数量
PhpConfig.METHOD_GET_PAYLOG = "getPayLog"; --上传或下载道具数量
PhpConfig.METHOD_SYNC_STATPEOPLEATPLAYALONE = "statPeopleAtPlayAlone"; --统计每日玩棋人数（去重）;
PhpConfig.METHOD_SYNC_STATREWARDPERLEVEL  = "statRewardPerLevel";  --每日每层奖励发放统计（包括金币和道具）
PhpConfig.METHOD_GETPROPLIST = "getRstPropList";--获取玩家没有使用的悔棋数量
PhpConfig.METHOD_GETDAILYLIST = "getDailyList";--获取每日任务列表
PhpConfig.METHOD_GETDAILYREWARD = "getDailyReward";--每日/连续签到签到领取奖励
PhpConfig.METHOD_GETONLINE_REWARD = "getLoginLongReward";--领取在线时长奖励
PhpConfig.METHOD_GETSOULLIST = "getSoulList";--获取兑换列表
PhpConfig.METHOD_EXCHANGE_SOUL = "exchangeSoul";--棋魂兑换道具
PhpConfig.METHOD_GET_SOUL = "getSoul";--残局单机获取棋魂

PhpConfig.METHOD_EXCHANGEPROP  = "exchangeProp";  --元宝兑换道具
PhpConfig.METHOD_GETPROPCONGIF  = "getPropConfig";  --获取道具列表道具
 
PhpConfig.METHOD_BIND_BOYAA  = "bind";  --绑定博雅
PhpConfig.METHOD_CHECK_BIND_BOYAA = "check";  --检查绑定博雅


PhpConfig.METHOD_GETLEVELCONFIG = "openByMoney";--单机小关卡付费（金币）开启配置
PhpConfig.METHOD_OPENLEVEL = "opendo";--开启单机小关卡（扣金币）
PhpConfig.METHOD_OPENTOLLGATE = "openTollgate";--开启残局大关卡（扣金币）
PhpConfig.METHOD_GETTOLLGATECONFIG = "getTollgateConfig";--开启残局大关卡（金币）开启配置
PhpConfig.getActivityURL = function()
    local url = PhpConfig.develop .. "?m=action&page=index&bid=" .. PhpConfig.getBid() .. "&mid=" .. PhpConfig.getMid();
    return url;
end

------
PhpConfig.initURL = function()
    PhpConfig.MODIFY_USERINFO = PhpConfig.develop .. "?m=core&p=modify";
    PhpConfig.LOGIN_URL = PhpConfig.develop .. "?m=core&p=platform"; --第三方登录
    PhpConfig.UPLOAD_IMAGE_URL = PhpConfig.develop .. "?m=icon&p=iconupload";
    PhpConfig.CHECK_VERSION_URL = PhpConfig.develop .. "?m=version";  --检测新版本
    PhpConfig.LOGIN_REWARD_URL = PhpConfig.develop .. "?m=loginreward";  --登录奖励
    PhpConfig.SCORE_RANK_URL = PhpConfig.develop .. "?m=rank"; --获取积分排行榜列表
    PhpConfig.NEW_SCORE_RANK_URL = "http://192.168.100.153/chess/"; --获取积分排行榜列表 新
    PhpConfig.MONEY_RANK_URL = PhpConfig.develop .. "?m=rank&p=money";   --金币排行榜
    PhpConfig.COLLAPSE_REWARD_URL = PhpConfig.develop .. "?m=collapsereward" --破产补助
    PhpConfig.ANSY_URL =  PhpConfig.develop .. "?m=ansy&p=api" --异步API
    PhpConfig.MALL_SHOP_URL = PhpConfig.develop .. "?m=pay&p=list";   --商品信息列表
    PhpConfig.MALL_GOODS_ID_URL = PhpConfig.develop .. "?m=pay";   --商品信息ID
    PhpConfig.MALL_PLACE_ORDER_URL = PhpConfig.develop .. "?m=pay&p=api"  --下订单
    PhpConfig.MALL_PAY_ORDER_URL = PhpConfig.develop .. "?m=pay" --请求发货
    --象棋积分墙接入添加:积分商城商品列表，2014/8/25
    PhpConfig.POINT_MALL_SHOP_URL = PhpConfig.develop .. "?m=scorewall&p=api";   --积分商品信息列表
    --PhpConfig.POINT_MALL_SHOP_URL = PhpConfig.developTest .. "?m=scorewall&p=api";   --测试
    PhpConfig.GET_360ACCESS_TOKEN = PhpConfig.develop .. "?m=core&p=get360AccessToken";
    PhpConfig.MSG_URL = PhpConfig.develop .."?m=message&p=api"; --获取消息
    PhpConfig.WATCH_GAME_LIST_URL = PhpConfig.develop .. "?m=watchgame"  --观战
    PhpConfig.WATCH_GAME_LIST_URL = PhpConfig.develop .. "?m=watchgame";  --观战
    PhpConfig.ENTHRAL_MENT_URL = PhpConfig.develop .. "?m=enthralment";  --防沉迷
    PhpConfig.DAILY_TASK_URL = PhpConfig.develop .. "?m=action&p=dailytask&act=dailytasktip"
    PhpConfig.PROP_URL = PhpConfig.develop .. "?m=pay"--道具URL
    PhpConfig.ENDING_GAME_URL = PhpConfig.develop .. "?m=booth&p=api";
    PhpConfig.QQ_BINDING_URL = PhpConfig.develop .. "?m=core&p= binding";
    PhpConfig.FRIENDS_URL = PhpConfig.develop .. "?m=friend&p=api";
    PhpConfig.VERIFY_TELNO_URL = PhpConfig.develop .. "/?m=bysms&p=api";--短信验证
    PhpConfig.FRIEND_SYS_URL = PhpConfig.develop .. "?m=friendsys&p=api";--棋友系统
    PhpConfig.CONSOLE_GET_SERVER_DATA_URL = PhpConfig.develop .. "?m=standalone&p=api";
    PhpConfig.GET_DAILY_URL = PhpConfig.develop .. "?m=daily&p=api"--获取每日列表 
    PhpConfig.ONLINE_TIME = PhpConfig.develop .. "?m=loginlong&p=api"--获取每日列表 
    PhpConfig.EXCHANGE_GOODS_LIST = PhpConfig.develop .. "?m=shop&p=soul"--兑换列表
    PhpConfig.MALL_PROP_URL = PhpConfig.develop .. "?m=shop&p=prop";--商城道具
    PhpConfig.NOTICE_URL = PhpConfig.requestUrl.."mobile/application/api.php";  --公告
    PhpConfig.BIND_BOYAA_URL = PhpConfig.develop .. "?m=core&p=boyaa";--博雅通行证
end 

--生成php调用的基础参数
PhpConfig.genTreeMap=function(t)
    t.versions = kPhpVersion; 
    t.sid=PhpConfig.getSid() .. "";
    t.bid=PhpConfig.getBid() .. "";
    t.mtkey=PhpConfig.getMtkey() .. "";
    t.mid=PhpConfig.getMid() .. "";
    t.username= "mid" .. PhpConfig.getUid();
    t.api=PhpConfig.getApi() .. "";
    t.phoneModel = PhpConfig.getPhoneType();--手机类型
    t.phoneSdkVersion = PhpConfig.getOsVersion();--手机系统版本
    t.phoneMac = PhpConfig.getMacAddr();--手机物理地址
    t.phoneNetType = PhpConfig.getNetType();--手机网络类型
    t.phoneIpAddr = PhpConfig.getIpAddr();--手机ip地址
    t.phoneImei = PhpConfig.getImeiNum();--手机imei号
    t.access_token = PhpConfig.getAccessToken();
end

--帐号类型
PhpConfig.setSid= function(sid)
    PhpConfig.sid = sid;
end
PhpConfig.getSid= function()
    return PhpConfig.sid or 200;
end
--php统计使用
PhpConfig.setBid = function(bid)
    PhpConfig.bid = bid;
end

PhpConfig.getBid = function()
    return PhpConfig.bid or 0;
end

PhpConfig.setMtkey= function(mtkey)
    PhpConfig.mtkey = mtkey;
end

PhpConfig.getMtkey= function()
    return PhpConfig.mtkey or "";
end

--int 用户ID，自己服务器中的
PhpConfig.setMid= function(mid)
    PhpConfig.mid = mid;
end
PhpConfig.getMid= function()
    return PhpConfig.mid or 0;
end

PhpConfig.setUid = function(uid)
    PhpConfig.uid = uid;
end
PhpConfig.getUid = function()
    return PhpConfig.uid or 0;
end

PhpConfig.setAccessToken = function(access_token)
    PhpConfig.access_token = access_token;
end

PhpConfig.getAccessToken = function()
    return PhpConfig.access_token;
end

--int
PhpConfig.setApi= function(api)
    PhpConfig.api = api;
end
PhpConfig.getApi= function()
    return PhpConfig.api or 2;
end

--象棋积分墙接入添加：2014/8/29     --start

-------------------------------------------------------
--手机型号、OS版本、MAC地址、网络类型、ip地址、IMEI号--
-------------------------------------------------------

PhpConfig.setPhoneType = function(phType)   --设置手机型号
    PhpConfig.phoneType = phType;
end;
PhpConfig.getPhoneType = function()
    return PhpConfig.phoneType or "";
end;


PhpConfig.setOsVersion = function(ov)       --设置手机系统版本
    PhpConfig.osVersion = ov;
end;
PhpConfig.getOsVersion = function()
    return PhpConfig.osVersion or "";
end;


PhpConfig.setMacAddr = function(Mac)        --设置手机MAC地址
    PhpConfig.phoneMac = Mac;
end;
PhpConfig.getMacAddr = function()
    return PhpConfig.phoneMac or "";
end;


PhpConfig.setNetType = function(NetType)    --设置手机网络类型
    PhpConfig.phoneNetType = NetType;
end;
PhpConfig.getNetType = function()
    return PhpConfig.phoneNetType or "";
end;

PhpConfig.setNetTypeLevel = function(level) --设置手机网络类型 wifi 2g 3g 4g 
    PhpConfig.phoneNetTypeLevel = level;
end

PhpConfig.getNetTypeLevel = function()
    return PhpConfig.phoneNetTypeLevel or "-1";
end;


PhpConfig.setIpAddr = function(ip)          --设置手机ip地址
    PhpConfig.phoneIpAddr = ip;
end;
PhpConfig.getIpAddr = function()
    return PhpConfig.phoneIpAddr or "";
end;



PhpConfig.setImeiNum = function(imei)   --设置imei号（Imei空，则返回空），不同于setImei（Imei空，则返回Mac）
    PhpConfig.phoneImei = imei;
end;
PhpConfig.getImeiNum = function()
    return PhpConfig.phoneImei or "";
end;

PhpConfig.setOsInfo = function(osinfo)
    PhpConfig.osinfo = osinfo;
end
PhpConfig.getOsInfo = function()
    return PhpConfig.osinfo or "win32";
end


--象棋积分墙接入添加：2014/8/29    --end

--string 用户key
PhpConfig.setMnick= function(mnick)
    PhpConfig.mnick = mnick;
end

PhpConfig.getMnick= function()
    return PhpConfig.mnick or "";
end

PhpConfig.setImei= function(imei)
    PhpConfig.imei = imei;
end

PhpConfig.getImei= function()
    return PhpConfig.imei or "";
end
PhpConfig.setVersions = function(versions)
    PhpConfig.versions = versions;
end

PhpConfig.getVersions = function()
    --return PhpInfo.versions or VERSIONS;
    return VERSIONS;
end


PhpConfig.setAppid = function(appid)
    PhpConfig.appid = appid;
end
PhpConfig.getAppid = function()
    return PhpConfig.appid or 0;
end

PhpConfig.setAppKey = function(appKey)
    PhpConfig.appKey = appKey;
end

PhpConfig.getAppKey = function()
    return PhpConfig.appKey or 0;
end

--平台类型
PhpConfig.setSidPlatform = function(psid)
    PhpConfig.p_sid = psid;
end
PhpConfig.getSidPlatform = function()
    return PhpConfig.p_sid;
end

--推广渠道
PhpConfig.setBid_ = function(bid)
    PhpConfig.bid_ = bid;
end

PhpConfig.getBid_ = function()
    return PhpConfig.bid_ or 0;
end

PhpConfig.setType = function(type)
    PhpConfig.type = type;
end
PhpConfig.getType = function()
    return PhpConfig.type or 0;
end

PhpConfig.saveWebUrl = function(url)
    GameCacheData.getInstance():saveString(GameCacheData.WEB_REQUEST_URL,url); 
end

PhpConfig.setDevelopUrl = function(url)
    PhpConfig.developUrl = url;
    PhpConfig.develop = url..PhpConfig.chess_android;
    PhpConfig.requestUrl = url;
    PhpConfig.setMid();
    PhpConfig.initURL();    
    return PhpConfig.develop ;
end


PhpConfig.setLoginType = function(loginType)
    PhpConfig.setType(loginType);
    typePar = loginType;
    if kPlatform == kPlatformIOS then
	    PhpConfig.setBid(PhpConfig.getBid_());
    else
	    PhpConfig.setBid("A_" .. PhpConfig.getSidPlatform() .. typePar ..  PhpConfig.getBid_());
    end;
    PhpConfig.setSid(PhpConfig.getSidPlatform());
end

PhpConfig.setPlatform = function(appid,appkey,bid,sid,typePar)
    
    if appid == PhpConfig.APPID_EMPTY then
        appid = kGameCacheData:getString(GameCacheData.PHP_APPID,PhpConfig.APPID_BOYAA);
    else
       kGameCacheData:saveString(GameCacheData.PHP_APPID,appid);
    end

    if appkey == PhpConfig.APPKEY_EMPTY then
        appkey = kGameCacheData:getString(GameCacheData.PHP_APPKEY,PhpConfig.APPKEY_BOYAA);
    else
       kGameCacheData:saveString(GameCacheData.PHP_APPKEY,appkey);
    end
    
    if bid == PhpConfig.BID_EMPTY then
        bid = kGameCacheData:getString(GameCacheData.PHP_BID,PhpConfig.BID_BOYAA);
    else
       kGameCacheData:saveString(GameCacheData.PHP_BID,bid);
    end
    PhpConfig.setBid_(bid);
    PhpConfig.setAppid(appid);

    PhpConfig.setAppKey(appkey);
    PhpConfig.setSidPlatform(sid);

end

------------------------------------------------------------------------------------------
--运营平台
PhpConfig.SID_91 = 200;          -- 服务端自定义应用ID，例如：ios iphone 100 ;ios ipad:101; android:200   
    
PhpConfig.SID_WEIBO = 10;        -- weibo登录

PhpConfig.SID_BOYAA = 40;         --博雅通行证登录

PhpConfig.SID_360 = 20;          -- 360登录
PhpConfig.SID_qq = 30;          -- qq登录

PhpConfig.SID_IOS = 101;  -- ios简体
PhpConfig.SID_GOOGLEPLAY = 201;  -- 简体
PhpConfig.SID_EGAME = 204;
PhpConfig.SID_OPPO = 202;        --OPPO
PhpConfig.SID_HUAWEI = 210;  -- 华为登陆
PhpConfig.SID_BAIDUGAME = 217;  --百度

PhpConfig.APPID_shenmass = "110939";    -- 推广渠道ID
PhpConfig.APPKEY_shenmass = "2C1F3188BB2DF8EEAE98E9FEE128241D";   --推广渠道key
PhpConfig.BID_shenmass = "_shenmass";

PhpConfig.APPID_sougouss = "110938";    -- 推广渠道ID
PhpConfig.APPKEY_sougouss = "051B9AE53BBCC17046BBCA4FF321DF99";   --推广渠道key
PhpConfig.BID_sougouss = "_sougouss";

PhpConfig.APPID_baoruan = "113890";    -- 推广渠道ID
PhpConfig.APPKEY_baoruan = "2404212110303933EA246CB9C0F0CC2A";   --推广渠道key
PhpConfig.BID_baoruan = "_baoruan";

PhpConfig.APPID_xq1 = "113911";    -- 推广渠道ID
PhpConfig.APPKEY_xq1 = "5B0B6EA608F2D30D4C243699E9A22A37";   --推广渠道key
PhpConfig.BID_xq1 = "_xq1"

PhpConfig.APPID_leshi = "114172";    -- 推广渠道ID
PhpConfig.APPKEY_leshi = "47F69248F875E9E3166669523363A30B";   --推广渠道key
PhpConfig.BID_leshi = "_leshi"

PhpConfig.APPID_aliyun = "114304";    -- 推广渠道ID
PhpConfig.APPKEY_aliyun = "12ED1166EB58B0D6F9104A174CD3D892";   --推广渠道key
PhpConfig.BID_aliyun = "_aliyun"

PhpConfig.APPID_APPCHINA = "100313";    -- 推广渠道ID
PhpConfig.APPKEY_APPCHINA = "96868f1a59d0fde1fafe29f42caecfdf";   --推广渠道key
PhpConfig.BID_APPCHINA = "_appchina";
    
PhpConfig.APPID_ANZHI = "100314";
PhpConfig.APPKEY_ANZHI = "086044a057a69f5f85e8fbde374db9de";
PhpConfig.BID_ANZHI = "_anzhi";
    
PhpConfig.APPID_HIAPK = "100315";
PhpConfig.APPKEY_HIAPK = "90c5dd936b16469bb8f9d4890bcd55f5";
PhpConfig.BID_HIAPK = "_hiapk";
    
PhpConfig.APPID_360 = "100316";
PhpConfig.APPKEY_360 = "6f2a264e92488c999462c48f1424bd6a";
PhpConfig.BID_360 = "_360";
    
PhpConfig.APPID_NDUO = "100317";
PhpConfig.APPKEY_NDUO = "674f0eb67d97faa4ec40b6abc97a70eb";
PhpConfig.BID_NDUO = "_nduo";

PhpConfig.APPID_WDJ = "100318";
PhpConfig.APPKEY_WDJ = "44f507f8fd8d0446f4c01532b765f250";
PhpConfig.BID_WDJ = "_wdj";
    
PhpConfig.APPID_SLB = "100319";
PhpConfig.APPKEY_SLB = "bf29fb9a5d4b01fcc399110721dd924c";
PhpConfig.BID_SLB = "_slb";
if kPlatform == kPlatformIOS then    
    PhpConfig.APPID_BOYAA = "";
    PhpConfig.APPKEY_BOYAA = "";
    PhpConfig.BID_BOYAA = "b7";
else
    PhpConfig.APPID_BOYAA = "100320";
    PhpConfig.APPKEY_BOYAA = "98db45ab911ec3f3a44e7326dadf248e";
    PhpConfig.BID_BOYAA = "_boyaa";
end;
PhpConfig.APPID_ALI = "100811";
PhpConfig.APPKEY_ALI = "40c34ead5752e89bc7d25d9d2fcd2195";
PhpConfig.BID_ALI = "_ali";

PhpConfig.APPID_GOOGLE = "100859";
PhpConfig.APPKEY_GOOGLE = "9df830fb50f0bb44eeefa6d4efcdd099";
PhpConfig.BID_GOOGLE = "_google";

PhpConfig.APPID_BAIDU = "100899";
PhpConfig.APPKEY_BAIDU = "bf4271a7f9c12b47de40da08e13cd5b9";
PhpConfig.BID_BAIDU = "_baidu";

PhpConfig.APPID_12114 = "100958";
PhpConfig.APPKEY_12114 = "a72186766c9af9019f7298e5a17e6646";
PhpConfig.BID_12114 = "_12114";

--大厅
PhpConfig.APPID_DATING = "100974";  
PhpConfig.APPKEY_DATING = "3554c6347e258135a5201e60a13fdc49";
PhpConfig.BID_DATING = "_dating";

--腾讯无线博雅象棋
PhpConfig.APPID_TENCENT = "101221";  
PhpConfig.APPKEY_TENCENT = "d0260a36134c4c7b843a46c7237b2758";
PhpConfig.BID_TENCENT = "_tencent";

--网易
PhpConfig.APPID_WANGYI = "101286";  
PhpConfig.APPKEY_WANGYI = "7955062dfcbff7387477e5d6505a0aa1";
PhpConfig.BID_WANGYI = "_wangyi";

PhpConfig.APPID_LENOVO = "101388";  
PhpConfig.APPKEY_LENOVO = "b6db658b48b62191df310017eb94026e";
PhpConfig.BID_LENOVO = "_lenovo";

PhpConfig.APPID_LENOPAD = "101514";  
PhpConfig.APPKEY_LENOPAD = "d29cced22666054af4e5c48a2bb6e1f5";
PhpConfig.BID_LENOPAD = "_levOPad";

PhpConfig.APPID_YOUYA = "101634";  
PhpConfig.APPKEY_YOUYA = "85be77777f0246161cffb9ded1ef460b";
PhpConfig.BID_YOUYA = "_youya";

--联想 
PhpConfig.APPID_LIANXIANG = "101715";  
PhpConfig.APPKEY_LIANXIANG = "af472d682f3b948f9e65a34dfafe3303";
PhpConfig.BID_LIANXIANG = "_lianxiang";


PhpConfig.APPID_YIGUO = "101743";  
PhpConfig.APPKEY_YIGUO = "599ba86cb7652c66f9d5ba89260c9c91";
PhpConfig.BID_YIGUO = "_yiguo";

PhpConfig.APPID_BAIDUSS = "110170";
PhpConfig.APPKEY_BAIDUSS = "E280F579B28B9B51890D89FABAF33626";
PhpConfig.BID_BAIDUSS = "_baiduss";

PhpConfig.APPID_gangyunxj = "114315";
PhpConfig.APPKEY_gangyunxj = "ABC05605F8CB889386A5463B8AF7FF91";
PhpConfig.BID_gangyunxj = "_gangyunxj";

PhpConfig.APPID_nm = "114427";
PhpConfig.APPKEY_nm = "ECBED3962CD0335C869DF92B3B7C90F7";
PhpConfig.BID_nm = "_nm";

PhpConfig.APPID_ltbl = "113486";
PhpConfig.APPKEY_ltbl = "E15855A074EC12B1D6792681B68207F4";
PhpConfig.BID_ltbl = "_ltbl";


PhpConfig.APPID_EGAME = "1";
PhpConfig.APPKEY_EGAME = "1";
PhpConfig.BID_EGAME = "_egame";

PhpConfig.APPID_EMPTY = "0";
PhpConfig.APPKEY_EMPTY = "0";
PhpConfig.BID_EMPTY = "_empty";

--OPPO
PhpConfig.APPID_OPPO = "804";
PhpConfig.APPKEY_OPPO = "5BxcY0ooYBKyg85aUI0KY3adc";
PhpConfig.BID_OPPO = "_oppo";

--帐号类型
PhpConfig.TYPE_YOUKE = "_youke";   -- 游客
PhpConfig.TYPE_WEIBO = "_weibo";   -- 微博 

PhpConfig.TYPE_360 = "_360";   -- 360登录 

PhpConfig.TYPE_qq = "_qq";   -- qq登录 

PhpConfig.TYPE_BOYAA = "_boyaa";   -- boyaa登录 