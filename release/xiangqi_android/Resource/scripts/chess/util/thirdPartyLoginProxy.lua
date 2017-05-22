ThirdPartyLoginProxy = {}

ThirdPartyLoginProxy.s_sid = {
    phone = 1;
    email = 2;
    weichat = 3;
    xinlang = 10;
    boyaa = 40;
    qq    = 30;
}

function ThirdPartyLoginProxy.loginWeixin(json_data)
    local bind_uuid = json_data.openid:get_value();
    local nickname = json_data.nickname:get_value();
    local sex = json_data.sex:get_value();--1为男性，2为女性
    local unionid = json_data.unionid:get_value();
    local headimgurl = json_data.headimgurl:get_value();
    UserInfo.getInstance():setUploadThridHeadImg(headimgurl)
    local mid = UserInfo.getInstance():getUid();
    UserInfo.getInstance():setAcountLoginType(UserInfo.s_acountType.wechat);
    Log.i("kLoginWeChat openid:"..bind_uuid);
    local post_data = {};
    post_data.bind_uuid = bind_uuid;
    post_data.mid = mid;
    post_data.sid = ThirdPartyLoginProxy.s_sid.weichat;
    post_data.mnick = nickname;
    post_data.sex = sex;
    post_data.unionid = unionid;
    post_data.uid = md5_string(PhpConfig.getImei());
    HttpModule.getInstance():execute(HttpModule.s_cmds.loginThirdLogin,post_data,"查询中...");
end

function ThirdPartyLoginProxy.bindWeixin(json_data)
    local bind_uuid = json_data.openid:get_value();
    local nickname = json_data.nickname:get_value();
    local sex = json_data.sex:get_value();--1为男性，2为女性
    local mid = UserInfo.getInstance():getUid();
    local unionid = json_data.unionid:get_value();
    local headimgurl = json_data.headimgurl:get_value();
    Log.i("kLoginWeChat openid:"..bind_uuid);
    local post_data = {};
    post_data.bind_uuid = bind_uuid;
    post_data.mid = mid;
    post_data.mnick = nickname;
    post_data.sex = sex;
    post_data.unionid = unionid;
    post_data.sid = ThirdPartyLoginProxy.s_sid.weichat;
    HttpModule.getInstance():execute(HttpModule.s_cmds.bindUid,post_data,"绑定中...");
end


function ThirdPartyLoginProxy.loginWeibo(json_data)
    local bind_uuid = json_data.sitemid:get_value();
    local nickname = json_data.nickname:get_value();
    local gender = json_data.gender:get_value();
    local avatarLarge = json_data.avatarLarge:get_value();
    UserInfo.getInstance():setUploadThridHeadImg(avatarLarge)
    local mid = UserInfo.getInstance():getUid();
    UserInfo.getInstance():setAcountLoginType(UserInfo.s_acountType.weibo);
    Log.i("kLoginWithWeibo sitemid:"..bind_uuid);
    local post_data = {};
    post_data.bind_uuid = bind_uuid;
    post_data.mid = mid;
    post_data.sid = ThirdPartyLoginProxy.s_sid.xinlang;
    post_data.mnick = nickname;
    post_data.sex = gender;
    post_data.uid = md5_string(PhpConfig.getImei());
    HttpModule.getInstance():execute(HttpModule.s_cmds.loginThirdLogin,post_data,"查询中...");
end

function ThirdPartyLoginProxy.bindWeibo(json_data)
    local bind_uuid = json_data.sitemid:get_value();
    local nickname = json_data.nickname:get_value();
    local gender = json_data.gender:get_value();
    local avatarLarge = json_data.avatarLarge:get_value();
    local mid = UserInfo.getInstance():getUid();
    Log.i("kLoginWeChat openid:"..bind_uuid);
    local post_data = {};
    post_data.bind_uuid = bind_uuid;
    post_data.mid = mid;
    post_data.mnick = nickname;
    post_data.sex = gender;
    post_data.sid = ThirdPartyLoginProxy.s_sid.xinlang;
    HttpModule.getInstance():execute(HttpModule.s_cmds.bindUid,post_data,"绑定中...");
end

function ThirdPartyLoginProxy.loginQQ(json_data)
    local bind_uuid = json_data.openId:get_value();
    local nickname = json_data.nickName:get_value();
    local gender = json_data.gender:get_value();
    local figureurl_qq_1 = json_data.figureurl_qq_1:get_value();
    UserInfo.getInstance():setUploadThridHeadImg(figureurl_qq_1)
    local mid = UserInfo.getInstance():getUid();
    UserInfo.getInstance():setAcountLoginType(UserInfo.s_acountType.qq);
    Log.i("kLoginWithWeibo sitemid:"..bind_uuid);
    local post_data = {};
    post_data.bind_uuid = bind_uuid;
    post_data.mid = mid;
    post_data.sid = ThirdPartyLoginProxy.s_sid.qq;
    post_data.mnick = nickname;
    post_data.sex = gender;
    post_data.uid = md5_string(PhpConfig.getImei());
    HttpModule.getInstance():execute(HttpModule.s_cmds.loginThirdLogin,post_data,"查询中...");
end