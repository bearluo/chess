require("core/object");
require("util/log4lua");
HttpFileGrap = class();

HttpFileGrap.s_keys = {
	Id = "id";
	Url = "url";
	SaveAs = "saveas";
	Timeout = "timeout";
	Event = "event";
	Result = "result";
	IdDictName = "http_get_update";
    Md5 = "md5";
};

kHttpGetUpdateResultSuccess = 1;
kHttpGetUpdateResultTimeout = 0;
kHttpGetUpdateResultError = -1;

HttpFileGrap.getInstance = function()
	if not HttpFileGrap.s_instance then
		HttpFileGrap.s_instance = new(HttpFileGrap);
	end
	return HttpFileGrap.s_instance;
end

HttpFileGrap.releaseInstance = function()
	delete(HttpFileGrap.s_instance);
	HttpFileGrap.s_instance = nil;
end

HttpFileGrap.ctor = function(self)
	self.m_curid = 0; 
	self.m_callbacks = {};
end

HttpFileGrap.dtor = function(self)
	self.m_curid = 0; 
	self.m_callbacks = {};
end

HttpFileGrap.reset = function(self)
    if self.m_callbacks then
        for k,v in pairs(self.m_callbacks) do 
			self:cancleGrapFile(k);
	    end
    end
--    self.m_curid = 0; 
	self.m_callbacks = {};
end

--url:              下载URL
--file:             保存文件完整路径
--timeout:          超时
--obj:              回调对象
--func:             回调函数
--periodFunc:       进度回调
--needPause:        WIFI切换是否需要暂停
--tryNumber:        下载失败尝试次数
HttpFileGrap.grapApkFile = function(self,url,file,timeout,obj,func,periodFunc,needPause,tryNumber,md5)
    Log.i("HttpFileGrap file :" .. file .. "  url :" .. url);
	local id = self:getId();

	self:saveInfo(id,obj,func,periodFunc,file,url,needPause,tryNumber);

	dict_set_int(HttpFileGrap.s_keys.IdDictName,HttpFileGrap.s_keys.Id,id);
	
	local dictName = self:getDictName(id);

	dict_set_string(dictName,HttpFileGrap.s_keys.Url,url);
	dict_set_string(dictName,HttpFileGrap.s_keys.SaveAs,file);
	dict_set_int(dictName,HttpFileGrap.s_keys.Timeout,timeout);
    dict_set_string(dictName,HttpFileGrap.s_keys.Md5,md5);
	dict_set_string(dictName,HttpFileGrap.s_keys.Event,"httpFileGrap");
	dict_set_int(dictName,"timerPeriod",1000);

    if System.getPlatform() == kPlatformAndroid then
	    call_native("HttpGetUpdate");
	end
end

HttpFileGrap.cancleGrapFile = function(self,id)
	local id = id;
	if id then
		if System.getPlatform() == kPlatformAndroid and id ~= -1 then
			-- 取消下载更新包
			dict_set_int(HttpFileGrap.s_keys.IdDictName,HttpFileGrap.s_keys.Id,id);
			call_native("HttpCancelUpdate");
		end
		self.m_callbacks[id] = nil;
	end
end

HttpFileGrap.exitApkFile = function(self,filePath)
    dict_set_string("ExistApkFile","filePath",filePath);
    if System.getPlatform() == kPlatformAndroid then
	    call_native("ExistApkFile");
	end
    local existFlag = dict_get_int("ExistApkFile", "fileExist",0);
    if existFlag == 1 then
        Log.i("HttpFileGrap.exitApkFile " .. filePath .. " is exist!");
        return true;
    else
        Log.i("HttpFileGrap.exitApkFile " .. filePath .. " is no exist.");
        return false;
    end
end

HttpFileGrap.getDictName = function(self,id)
	return string.format("http_get_update%d",id);
end

HttpFileGrap.getId = function(self)
	self.m_curid = self.m_curid + 1;
	return self.m_curid;
end

HttpFileGrap.saveInfo = function(self,id,obj,func,periodFunc,file,url,needPause,tryNumber)
	self.m_callbacks[id] = {["obj"] = obj,["func"]=func,["file"]=file,["url"] = url,["periodFunc"]=periodFunc,["needPause"]=needPause,["tryNumber"]=tryNumber};
end

HttpFileGrap.onResponse = function(self)
	Log.i("HttpFileGrap.onResponse");
	local id = dict_get_int(HttpFileGrap.s_keys.IdDictName,HttpFileGrap.s_keys.Id,-1);
	local dictName = self:getDictName(id);
	local result = dict_get_int(dictName,HttpFileGrap.s_keys.Result,-1);
    local resultReason = "";
    local callback = self.m_callbacks[id];
	self.m_callbacks[id] = nil;
    Log.i("HttpFileGrap.onResponse result " .. result);
    if callback and result == -2 then    --MD5校验失败
        self:removeFile(callback["file"]);
        resultReason = dict_get_string(dictName,"resultReason") or "";
        callback["func"](callback["obj"],result == 1,resultReason);
        self:reset();
        return;
    end
    if callback and callback["func"] then
        if callback["tryNumber"] and callback["tryNumber"] > 1 and result ~=1 then
        	Log.i("HttpFileGrap.onResponse download fail and try");
            if callback["tryNumber"] == 999 then
                callback["tryNumber"] = 1000;
            end
            self:grapApkFile(callback["url"],callback["file"],3000,callback["obj"],callback["func"],callback["periodFunc"],callback["needPause"],callback["tryNumber"]-1);
        else
            if result ~=1 then
            	Log.i("HttpFileGrap.onResponse download fail");
                resultReason = dict_get_string(dictName,"resultReason") or "";
                Log.i("HttpFileGrap.onResponse false and resultReason ：" ..resultReason);
            end
		    callback["func"](callback["obj"],result == 1,resultReason);
            self:reset();
        end
    end
end

HttpFileGrap.onResponsePeriod = function(self)
	local id = dict_get_int(HttpFileGrap.s_keys.IdDictName,HttpFileGrap.s_keys.Id,-1);
	local dictName = self:getDictName(id);
	local period = dict_get_double(dictName,HttpFileGrap.s_keys.Result,0);
    Log.i("HttpFileGrap.onResponsePeriod 已下载："..period);
    local callback = self.m_callbacks[id];
    if callback then
    	callback["periodFunc"](callback["obj"],period);
    end
end

function event_http_get_update_response_httpFileGrap()
	HttpFileGrap.getInstance():onResponse();
end

function event_http_get_update_timer_period()
	HttpFileGrap.getInstance():onResponsePeriod();
end

HttpFileGrap.onResponseWifiChange = function(self,networkTypeFlag)
    Log.i("HttpFileGrap.event_wifiStateChange type = "..tostring(networkTypeFlag));
    local flag = false;
    if networkTypeFlag ~= 1 and self.m_callbacks then
        for k,v in pairs(self.m_callbacks) do 
		    if v.needPause then
			    self:cancleGrapFile(k);
                flag = true;
		    end
	    end
        if flag then
--            kGameData:setUpdating(false);
        end
    end
end

HttpFileGrap.removeFile = function(self,path)
	System.removeFile(path);
end
