require("core/constants");
require("core/object");

NetConfig = {};

NetConfig.ctor = function (self,obj)
	print_string("NetConfig.ctor");
	self.m_obj = obj;
end

NetConfig.dtor = function(self)
	print_string("NetConfig.dtor");
end

NetConfig.saveWebUrl = function(url)
    GameCacheData.getInstance():saveString(GameCacheData.WEB_REQUEST_URL,url); 
end

NetConfig.getNetConfig = function()
	NetConfig.m_CNDtb=nil
	NetConfig.m_WEBtb=nil; 
	NetConfig.m_CONFIGtb=nil;
	NetConfig.m_REPORTtb=nil;

	dict_set_string(kGetNetConfig , kGetNetConfig.. kparmPostfix,PhpConfig.getBid());
	call_native(kGetNetConfig);
end

NetConfig.UpdateNetConfig = function()
	NetConfig.m_CNDtb=nil
	NetConfig.m_WEBtb=nil; 
	NetConfig.m_CONFIGtb=nil;
	NetConfig.m_REPORTtb=nil;

	dict_set_string(kUpdateNetConfig , kUpdateNetConfig.. kparmPostfix,PhpConfig.getBid());
	call_native(kUpdateNetConfig);
end


NetConfig.GetNetworkConnectedStatus = function()
	call_native(kGetNetworkConnectedStatus);
end

NetConfig.isForceUpdate = false;

--登录时候强制更新配置文件 1是强制更新 2、是版本更新 
NetConfig.ForceUpdateNetConfig = function()
	print_string("======ForceUpdateNetConfig==================");
	NetConfig.m_CNDtb=nil
	NetConfig.m_WEBtb=nil; 
	NetConfig.m_CONFIGtb=nil;
	NetConfig.m_REPORTtb=nil;

	local isUpdate = UserInfo.getInstance():getNetConfigUpdate();
	local version = UserInfo.getInstance():getNetConfigVersion();		

	if isUpdate == 1 and not NetConfig.isForceUpdate  then
		print_string("===isUpdate=1=======");
		local tips = "正在更新网络配置信息，请稍候！"
		ProgressDialog.show(tips , true, NetConfig,NetConfig.onAbort);
		
		dict_set_string(kForceUpdateNetConfig , kForceUpdateNetConfig.. kparmPostfix,PhpConfig.getBid());
		call_native(kForceUpdateNetConfig);
		return true;
	elseif isUpdate == 2   then
		print_string("===isUpdate=0=======");
		dict_set_string(kVersionUpdateNetConfig , kVersionUpdateNetConfig.. kparmPostfix,PhpConfig.getBid());
		call_native(kVersionUpdateNetConfig);
	end
	NetConfig.isForceUpdate  = false;

	return false;
end

NetConfig.onAbort = function()

end

NetConfig.m_CNDtb=nil
NetConfig.m_WEBtb=nil; 
NetConfig.m_CONFIGtb=nil;
NetConfig.m_REPORTtb=nil;

NetConfig.EventRespone = function (eventName,json_str,tryNetConfigCallBack,model)

	if eventName == kGetNetConfig or eventName == kForceUpdateNetConfig 
		or eventName == kVersionUpdateNetConfig or eventName== kUpdateNetConfig then
		-- print_string("================json_str============="..json_str);

		if json_str and json_str ~= ""then
			local config  = json.decode(json_str);
   
   			local netStatus = config.netstatus;

			if netStatus then
				UserInfo.getInstance():setNetStatus(tonumber(netStatus));
			end

			local WEBstr = config.web;
			local tb = NetConfig.getResultTable(WEBstr);
			NetConfig.m_WEBtb = NetConfig.getWebUrlTable(tb);

			local CNDstr = config.cnd;
			NetConfig.m_CNDtb = NetConfig.getResultTable(CNDstr);

			local REPORTstr = config.report;
			NetConfig.m_REPORTtb = NetConfig.getResultTable(REPORTstr);

			local CONFIGstr = config.config;
			NetConfig.m_CONFIGtb = NetConfig.getResultTable(CONFIGstr);

			-- if WEBstr then
			-- 	print_string("===WEBstr===="..WEBstr);
			-- end

			-- if CNDstr then
			-- 	print_string("===CNDstr===="..CNDstr);
			-- end

			-- if REPORTstr then
			-- 	print_string("===REPORTstr===="..REPORTstr);
			-- end

			-- if CONFIGstr then
			-- 	print_string("===CONFIGstr===="..CONFIGstr);
			-- end	
		end
	end
end

NetConfig.isPollAble = function()
	if  NetConfig.m_WEBtb and #NetConfig.m_WEBtb>0 then
		return true
	end

	return false
end

NetConfig.getResultTable = function(line)
	local result;
	if line  and line ~= "" then
		result = ToolKit.split(line,"-"); 
	end
	return result
end

NetConfig.getWebUrlTable = function(tb)
	NetConfig.m_WEBtb={};

	if tb then
		local len = #tb;
		local weburl;
		for i=1,len do
			weburl = {};
			weburl.url = tb[i];
			weburl.used = 0;
			table.insert(NetConfig.m_WEBtb,weburl);
		end 
	end

	return NetConfig.m_WEBtb;
end

NetConfig.getWebUrl = function()
	local url = nil;

	if NetConfig.m_WEBtb then
		local len = #NetConfig.m_WEBtb;

		for i=1,len do
			local weburl = NetConfig.m_WEBtb[i]
			if weburl and weburl.used == 0 then
				weburl.used = 1;
				url = weburl.url;
				break;
			end
		end 
	end

	return url;
end

NetConfig.getAvailableWebUrl = function()
	local url = nil;

	if NetConfig.m_WEBtb then
		local len = #NetConfig.m_WEBtb;
		if len>0 then
			for i=1,len do
				if NetConfig.m_WEBtb[i] then
					url = NetConfig.m_WEBtb[i].url;
				end
			
				if url and url~="" then
					break;
				end
			end
		end
	end

	return url;
end