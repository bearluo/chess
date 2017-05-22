------------php配置--------------
if kPlatform == kPlatformIOS then
    kIphone = PhpConfig.iOS_Bundle_id ~= "com.boyaa.ChineseChessHD2";
    kAppid = PhpConfig.APPID_BOYAA
    kAppkey = PhpConfig.APPKEY_BOYAA
    kBid = kIphone and PhpConfig.BID_IPHONE or PhpConfig.BID_IPAD
    kSid = kIphone and PhpConfig.SID_IPHONE or PhpConfig.SID_IPAD
    kTypePar = PhpConfig.TYPE_YOUKE
else
    kAppid = PhpConfig.APPID_SLB
    kAppkey = PhpConfig.APPKEY_SLB
    kBid = PhpConfig.BID_SLB
    kSid = PhpConfig.SID_GOOGLEPLAY
    kTypePar = PhpConfig.TYPE_YOUKE
end