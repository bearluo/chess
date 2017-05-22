-- 是否为测试环境
kDebug = false;
kPlatform = System.getPlatform();
require("core/constants");
require("config/php_config");
require("config/chess_config");
require("config/php_config");
require("config/game_config");
require("config/path_config");
require("config/native_config");
require("config/anim_config");
require("config/server_config");
require(ACTIVITY_PATH .. "activityManager");
-- ResConfig is a global val to config res path and format for multi-platform.  
ResConfig = {} 
ResConfig.Path = nil 
ResConfig.Filter = kFilterLinear;
ResConfig.FormatFileMap = {} 
ResConfig.FormatFolderMap = {} 
-- LanguageConfig is a global val to config language for multi-platform.  
LanguageConfig = {} 
LanguageConfig.isZhHant = false; 


-- 活动中心
kActivityDebug = ((kDebug and 1) or 0);--这里1代表测试服务器，0代表正式服务器，传其他的值没有用的哦
ActivityManager.setMode(kActivityDebug == 1)
------------客户端版本号--------------

kLuaVersion = "2.3.0";
kLuaVersionCode = 230;

VERSIONS = kLuaVersion;
VERSIONS_CODE = kLuaVersionCode;

------------服务器版本号--------------
kServerVersion = 2;
------------php版本号--------------
kPhpVersion = kLuaVersion;

------------php配置--------------
if kPlatform == kPlatformIOS then
    kAppid = PhpConfig.APPID_BOYAA
    kAppkey = PhpConfig.APPKEY_BOYAA
    kBid = PhpConfig.BID_BOYAA
    kSid = PhpConfig.SID_IOS
    kTypePar = PhpConfig.TYPE_YOUKE
else
    kAppid = PhpConfig.APPID_SLB
    kAppkey = PhpConfig.APPKEY_SLB
    kBid = PhpConfig.BID_SLB
    kSid = PhpConfig.SID_GOOGLEPLAY
    kTypePar = PhpConfig.TYPE_YOUKE
end;
PhpConfig.developUrl = PhpConfig.developMainUrl;--正式环境