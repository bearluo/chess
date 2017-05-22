-- HttpManager.lua
-- Author: Vicent.Gong
-- Date: 2013-01-08
-- Last modification : 2013-07-12
-- Description: Implemented a http manager,to manager all http request.

require("core/constants");
require("core/object");
require("core/http");
require("core/eventDispatcher");
require("libs/json_wrap");
require("core/anim");

HttpConfigContants = 
{
	URL = 1,
	METHOD = 2,
	TYPE = 3,
	TIMEOUT = 4,
};

HttpErrorType = 
{
	SUCCESSED = 1,
	TIMEOUT = 2,
	NETWORKERROR = 3,
	JSONERROR = 4,
};

HttpManager = class();
HttpManager.s_event = EventDispatcher.getInstance():getUserEvent();

HttpManager.ctor = function(self,configMap,postDataOrganizer,urlOrganizer)
	self.m_httpCommandMap = {};
	self.m_commandHttpMap = {};
	self.m_commandTimeoutAnimMap = {};
	
	HttpManager.setConfigMap(self,configMap);
	HttpManager.setPostDataOrganizer(self,postDataOrganizer);
	HttpManager.setUrlOrganizer(self,urlOrganizer);

	self.m_timeout  = 30000;
end

HttpManager.getConfigMap = function(self)
	return self.m_configMap;
end

HttpManager.setConfigMap = function(self,configMap)
	HttpManager.destroyAllHttpRequests(self);
	self.m_configMap = configMap or {};
end

HttpManager.appendConfigs = function(self,configMap)
	for k,v in pairs(configMap or {}) do
		self.m_configMap[k] = v;
	end
end

HttpManager.setDefaultTimeout = function(self,time)
	self.m_timeout = time or self.m_timeout;
end

HttpManager.setPostDataOrganizer = function(self,postDataOrganizer)
	self.m_postDataOrganizer = postDataOrganizer;
end

HttpManager.setUrlOrganizer = function(self,urlOrganizer)
	self.m_urlOrganizer = urlOrganizer;
end

HttpManager.execute = function(self,command,data,tip,canCancel,level)
	if not HttpManager.checkCommand(self,command) then
		return false;
	end

	HttpManager.destroyHttpRequest(self,self.m_commandHttpMap[command]);

	local config = self.m_configMap[command];
	local httpType = config[HttpConfigContants.TYPE] or kHttpPost;

	local url = self.m_urlOrganizer(config[HttpConfigContants.URL],
								config[HttpConfigContants.METHOD],
								httpType);
	
	local method = config[HttpConfigContants.METHOD];
	Log.i(method .. " |  url:---------->" .. config[HttpConfigContants.URL]);
	Log.i(method .. " |  method:---------->" .. method);


	local httpRequest = new(Http,httpType,kHttpReserved,url)
	httpRequest:setEvent(self, self.onResponse);
	httpRequest:setTimeout(self.m_timeout,self.m_timeout);

    if config[HttpConfigContants.URL] == PhpConfig.h5_developTest or config[HttpConfigContants.URL] == PhpConfig.h5_developMainUrl then
        if httpType == kHttpPost then 
		    local postData =  HttpModule.postDataOrganizerH5(config[HttpConfigContants.METHOD],data);
		    httpRequest:setData(postData);
		    Log.i(method .. " |  data:---------->" .. postData);
	    end
    elseif config[HttpConfigContants.URL] ~= "http://feedback.kx88.net/api/api.php" then
        if httpType == kHttpPost then 
		    local postData =  self.m_postDataOrganizer(config[HttpConfigContants.METHOD],data,false,config[HttpConfigContants.URL] == PhpConfig.new_developUrl);
		    httpRequest:setData(postData);
		    Log.i(method .. " |  data:---------->" .. postData);
	    end
    else
        local postData =  self.m_postDataOrganizer(config[HttpConfigContants.METHOD],data,true);
        httpRequest:setData(postData);
        Log.i(method .. " |  data:---------->" .. postData);
    end

	local timeoutAnim = HttpManager.createTimeoutAnim(self,command,config[HttpConfigContants.TIMEOUT] or self.m_timeout);

    self.m_httpCommandMap[httpRequest] = command;
    self.m_commandHttpMap[command] = httpRequest;
    self.m_commandTimeoutAnimMap[command] = timeoutAnim;
    
    HttpLoadDialogManager.getInstance():push(command,tip,level,canCancel)

	httpRequest:execute();
end

HttpManager.dtor = function (self)
	HttpManager.destroyAllHttpRequests(self);

    self.m_httpCommandMap = nil;
    self.m_commandHttpMap = nil;
	self.m_commandTimeoutAnimMap = nil;

	self.m_configMap = nil;
end

---------------------------------private functions-----------------------------------------

HttpManager.checkCommand = function(self, command)
	local errLog = nil;

	repeat 
		if not (command or self.m_configMap[command]) then
			errLog = "There is not command like this";
			break;
		end

		local config = self.m_configMap[command];

		if not config[HttpConfigContants.URL] then 
			
			errLog = "There is not url in command";
			break;
		end

		if not config[HttpConfigContants.METHOD] then
			errLog = "There is not method in command";
			break;
		end

		local httpType = config[HttpConfigContants.TYPE];
		if httpType ~= nil and httpType ~= kHttpPost and  httpType ~= kHttpGet then
			errLog = "Not supported http request type";
			break;
		end
	until true

	if errLog then
		HttpManager.log(self,command,errLog);
		return false;
	end

	return true;
end

HttpManager.log = function(self, command, str)
	local prefixStr = "HttpRequest error :";
	if config then
		prefixStr =prefixStr .. " command |" .. command;
	end

	FwLog(prefixStr .. " | " .. str);
end

HttpManager.onResponse = function(self , httpRequest)
    if self.m_httpCommandMap == {} or not self.m_httpCommandMap then
        return;
    end

	local command = self.m_httpCommandMap[httpRequest];

	if not command then
		HttpManager.destroyHttpRequest(self,httpRequest);
		return;
	end

	HttpManager.destoryTimeoutAnim(self,command);
 
 	local errorCode = HttpErrorType.SUCCESSED;
 	local data = nil;
   		
	repeat 
		-- 判断http请求的错误码,0--成功 ，非0--失败.
		-- 判断http请求的状态 , 200--成功 ，非200--失败.
		if 0 ~= httpRequest:getError() or 200 ~= httpRequest:getResponseCode() then
			errorCode = HttpErrorType.NETWORKERROR;
			break;
		end
	
		-- http 请求返回值
		local resultStr =  httpRequest:getResponse();
		

		Log.i("resultStr:"..resultStr);


		-- http 请求返回值的json 格式
		local json_data = json.decode_node(resultStr);
		--返回错误json格式.
	    if not json_data:get_value() then
	    	errorCode = HttpErrorType.JSONERROR;
			break;
	    end

	    data = json_data;
	until true;

	if errorCode ==HttpErrorType.SUCCESSED then
		Log.i("errorCode:SUCCESSED");
	elseif errorCode == HttpErrorType.TIMEOUT then
		Log.i("errorCode:TIMEOUT");
        ChessToastManager.getInstance():showSingle("网络超时");
	elseif errorCode == HttpErrorType.NETWORKERROR  then
		Log.i("errorCode:NETWORKERROR");	
        ChessToastManager.getInstance():showSingle("网络异常");
	elseif errorCode == HttpErrorType.JSONERROR  then
		Log.i("errorCode:JSONERROR");	
        ChessToastManager.getInstance():showSingle("网络错误");
	end

    HttpManager.destroyHttpRequest(self,httpRequest);
    EventDispatcher.getInstance():dispatch(HttpManager.s_event,command,errorCode,data);
end

HttpManager.onTimeout = function(callbackObj)
	Log.i("[HttpManager.onTimeout]");

	local self = callbackObj["obj"];
	local command = callbackObj["command"];
    
	EventDispatcher.getInstance():dispatch(HttpManager.s_event,command,HttpErrorType.TIMEOUT);

	HttpManager.destroyHttpRequest(self,self.m_commandHttpMap[command]);
end

HttpManager.createTimeoutAnim = function(self,command,timeoutTime)
	local timeoutAnim = new(AnimInt,kAnimRepeat,0,1,timeoutTime,-1);
	timeoutAnim:setDebugName("AnimInt | httpTimeoutAnim");
    timeoutAnim:setEvent({["obj"] = self,["command"] = command},self.onTimeout);

    return timeoutAnim;
end

HttpManager.destoryTimeoutAnim = function(self,command)
	local anim = self.m_commandTimeoutAnimMap[command];
	delete(anim);

	self.m_commandTimeoutAnimMap[command] = nil;
end

HttpManager.destroyHttpRequest = function(self,httpRequest)
	if not httpRequest then 
		return;
	end

	local command = self.m_httpCommandMap[httpRequest];
	
	if not command then
		delete(httpRequest);
	    return;
	end

    HttpLoadDialogManager.getInstance():remove(command);

	HttpManager.destoryTimeoutAnim(self,command);
	self.m_commandHttpMap[command] = nil;
	self.m_httpCommandMap[httpRequest] = nil;
end

HttpManager.destroyAllHttpRequests = function(self)
	for _,v in pairs(self.m_commandHttpMap)do 
		HttpManager.destroyHttpRequest(self,v);
	end
end

HttpManager.getMethodData = function(param,method)
	local post_data = {};

    PhpConfig.genTreeMap(post_data); 
    post_data.method = method;  
    post_data.param = param or {["uid"] = UserInfo.getInstance():getUid()} ;    
    local signature = Joins(post_data, PhpConfig.getMtkey() .. "");


    post_data.sig = md5_string(signature);
	return json.encode(post_data) ;
end
----------------------------Loading dialog -------------------------
---by bearluo
---data 2015.04.14
HttpLoadDialogManager = class()

HttpLoadDialogManager.ctor = function(self)
    self.m_httpCmd = {};
    self.m_preHttpCmd = {};
    self.m_preRemoveHttpCmd = {};
    require("dialog/http_loading_dialog");
    self.m_loadingDialog = HttpLoadingDialog.getInstance();
end

HttpLoadDialogManager.dtor = function(self)
    
end

HttpLoadDialogManager.cmp = function(tabA,tabB)
    return tabA.level > tabB.level or ( tabA.level == tabB.level and tabA.time < tabB.time );
end

HttpLoadDialogManager.getInstance = function()
    if not HttpLoadDialogManager.s_instance then
        HttpLoadDialogManager.s_instance = new(HttpLoadDialogManager);
    end
    return HttpLoadDialogManager.s_instance;
end

HttpLoadDialogManager.push = function(self,cmd,str,level,canCancel)
    local tbl = {};
    tbl.cmd = cmd;
    tbl.str = str;
    tbl.level = level or 0;
    tbl.canCancel = canCancel;
    tbl.time = os.clock();

    self.m_httpCmd[cmd] = tbl;
    self:changeLoadingDialog();
end

HttpLoadDialogManager.changeLoadingDialog = function(self)
    local newCmd = nil
    for _,v in pairs(self.m_httpCmd) do
        if v and v.str then
            if not newCmd or HttpLoadDialogManager.cmp(v,newCmd) then
                newCmd = Copy(v);
            end
        end
    end

    if newCmd then
        self.m_loadingDialog:setType(HttpLoadingDialog.s_type.Normel,newCmd.str,newCmd.canCancel);
        self.m_loadingDialog:show();
    else
        self.m_loadingDialog:dismiss();
    end
end

HttpLoadDialogManager.remove = function(self,cmd)
    self.m_httpCmd[cmd] = nil;
    self:changeLoadingDialog();
end