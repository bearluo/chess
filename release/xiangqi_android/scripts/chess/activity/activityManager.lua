ActivityManager = class()

ActivityManager.config = {};

ActivityManager.appid = 1300;
-- ps 每个项目的链接地址不同 记得修改
ActivityManager.setMode = function(debug)
    if debug then
	    ActivityManager.config.get_related = "http://192.168.204.68/operating/web/index.php?m=activities&p=actrelated&appid=" .. ActivityManager.appid .. "&";
	    ActivityManager.config.FirstUrl = "http://192.168.204.68/operating/web/index.php?m=activities&p=index&appid=" .. ActivityManager.appid .. "&";
	    ActivityManager.config.CountUrl = "http://192.168.204.68/operating/web/index.php?m=activities&p=actrelated&appid=" .. ActivityManager.appid .. "&";
	    ActivityManager.config.SendPHPUrl = "http://192.168.204.70/apps/interface.php?m=data&p=initdata&appid=" .. ActivityManager.appid .. "&";
	    ActivityManager.config.SecondUrl = "http://192.168.204.70/apps/interface.php?m=apps&p=data&appid=" .. ActivityManager.appid .. "&";
	    ActivityManager.config.img = 'http://192.168.204.68/web/cdn/ns/xqimod/';
	    ActivityManager.config.img_old = 'http://192.168.204.68/web/cdn/';
	    ActivityManager.config.h5_develop = "http://chess153.by.com/chess/h5/";
	    ActivityManager.config.old_act = 'http://192.168.204.68/operating/web/index.php?m=activities&p=show&appid=' .. ActivityManager.appid .. "&";
    else
	    ActivityManager.config.get_related = "http://mvusspcs01.ifere.com/?m=activities&p=actrelated&appid=" .. ActivityManager.appid .. "&";
	    ActivityManager.config.FirstUrl = "http://mvusspcs01.ifere.com/?m=activities&p=index&appid=" .. ActivityManager.appid .. "&";
	    ActivityManager.config.CountUrl = "http://mvusspcs01.ifere.com/?m=activities&p=actrelated&appid=" .. ActivityManager.appid .. "&";
	    ActivityManager.config.SendPHPUrl = "http://mvusspcs01.ifere.com/interface.php?m=data&p=initdata&appid=" .. ActivityManager.appid .. "&";
	    ActivityManager.config.SecondUrl = "http://mvusspcs01.ifere.com/interface.php?m=apps&p=data&appid=" .. ActivityManager.appid .. "&";
	    ActivityManager.config.img = 'http://cache.17c.cn/mobile/activities/ns/xqimod/';
	    ActivityManager.config.img_old = 'http://cache.17c.cn/mobile/activities/';
	    ActivityManager.config.h5_develop = "http://cnchess.17c.cn/chess/h5/";
	    ActivityManager.config.old_act = 'http://mvusspcs01.ifere.com/?m=activities&p=show&appid=' .. ActivityManager.appid .. "&";
    end
end

ActivityManager.getActivityIconUrl = function(data)
    local str="";
    if string.match(data.tpl,'_newtpl$') then
		str = ActivityManager.config.img .. data.icon;
	else
		str = ActivityManager.config.img_old .. data.icon;
	end
    return str;
end

ActivityManager.getActivityUrl = function(data)
    local apiUrl = "";
    local url = "";
    if string.match(data.tpl,'_newtpl$') then
		apiUrl = ActivityManager.getAPIUrl();
		url = ActivityManager.config.FirstUrl .. 'newapi=' .. ActivityManager.encodeURI(apiUrl) .. '&#act/' .. data.id;
	elseif string.match(data.tpl,'_vuetpl$') then
		apiUrl = ActivityManager.getAPIUrl();
		url = ActivityManager.config.FirstUrl .. 'newapi=' .. ActivityManager.encodeURI(apiUrl) .. '&#act/' .. data.id;
    else
	    apiUrl = ActivityManager.getAPIUrl();
		apiUrl = string.gsub(apiUrl,'/\"api\"/','\"pid\"');
		url = ActivityManager.config.old_act .. 'act_id=' .. data.id .. '&api=' .. ActivityManager.encodeURI(apiUrl);
	end
    return url;
end

ActivityManager.getAPIUrl = function()
	local url = "";
	url = url .. "{";
    if ActivityManager.getMid() ~= nil then
	    url = url .. "\"mid\":\"" .. ActivityManager.getMid() .. "\",";
    end
    if ActivityManager.getApi() ~= nil then
	    url = url .. "\"api\":\"" .. ActivityManager.getApi() .. "\",";
    end
    if ActivityManager.getVersion() ~= nil then
	    url = url .. "\"version\":\"" .. ActivityManager.getVersion() .. "\",";
    end
    if ActivityManager.getSitemid() ~= nil then
	    url = url .. "\"sitemid\":\"" .. ActivityManager.getSitemid() .. "\",";
    end
    if ActivityManager.getAppid() ~= nil then
	    url = url .. "\"appid\":\"" .. ActivityManager.getAppid() .. "\",";
    end
    if ActivityManager.getSid() ~= nil then 
	    url = url .. "\"sid\":\"" .. ActivityManager.getSid() .. "\",";
    end
    if ActivityManager.getDeviceno() ~= nil then
	    url = url .. "\"deviceno\":\"" .. ActivityManager.getDeviceno() .. "\",";
    end
    if ActivityManager.getNetworkstate() ~= nil then
	    url = url .. "\"networkstate\":\"" .. ActivityManager.getNetworkstate() .. "\",";
    end
    if ActivityManager.getOsversion() ~= nil then
	    url = url .. "\"osversion\":\"" .. ActivityManager.getOsversion() .. "\",";
    end

	url = string.sub(url,1,-2);
	url = url .. "}";
	return url;
end

-- 根据活动中心指定的参数 自行修改
-- mid
ActivityManager.getMid = function()
    return UserInfo.getInstance():getUid();
    --return ActivityManager.mid;
end

-- api
ActivityManager.getApi = function()
    if PhpConfig.getSidPlatform() then
        return "A_" .. PhpConfig.getSidPlatform();
    end
    return ;
    --return ActivityManager.api;
end

-- game version
ActivityManager.getVersion = function()
    return kLuaVersion;
--    return ActivityManager.version;
end

-- sitemid 
ActivityManager.getSitemid = function()
    return UserInfo.getInstance():getSitemid();
--    return ActivityManager.sitemid;
end

-- bid
ActivityManager.getAppid = function()
    return PhpConfig.getBid_();
--    return ActivityManager.appid;
end

-- sid
ActivityManager.getSid = function()
    return PhpConfig.getSidPlatform();
--    return ActivityManager.sid;
end

-- Imei 
ActivityManager.getDeviceno = function()
    return PhpConfig.getImeiNum();
--    return ActivityManager.deviceno;
end

-- network state 网络状态
ActivityManager.getNetworkstate = function()
    return ActivityManager.networkstate;
end

-- android system version 安卓系统版本
ActivityManager.getOsversion = function()
    return PhpConfig.getOsVersion();
--    return ActivityManager.osversion;
end

ActivityManager.decodeURI = function(s)
    s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
    return s
end

ActivityManager.encodeURI = function(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end