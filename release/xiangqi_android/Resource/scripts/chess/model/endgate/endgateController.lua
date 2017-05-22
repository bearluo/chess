require("config/path_config");

require(BASE_PATH.."chessController");

EndgateController = class(ChessController);

EndgateController.s_cmds = 
{	
    onBack = 1;
    onLoadListContent = 2;
    onDownloadProgress = 3;
    onGetBoothInfo = 4;
    onUploadGateInfo = 5;
    onEntryGame = 6;
    onCheckEndingUpdate = 7;
    gotoMall = 8;
    onCreateCustomEndgate = 9;
};

EndgateController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end


EndgateController.resume = function(self)
	ChessController.resume(self);
	Log.i("EndgateController.resume");
    if not self.sendFirst then
        self:checkEndGateVersion();
        self.sendFirst = true
    end
    StatisticsManager.getInstance():onNewUserCountToPHP(StatisticsManager.NEW_USER_COUNT_SYSTEM_ENDING,UserInfo.getInstance():getIsFirstLogin());
end

EndgateController.pause = function(self)
	ChessController.pause(self);
	Log.i("EndgateController.pause");
end

EndgateController.dtor = function(self)
    delete(self.mUpdateDialog)
    if self.mhttpRequest then
        self.mhttpRequest:setEvent(nil,nil)
        delete(self.mhttpRequest)
    end
end

-------------------------------- func ------------------------------

EndgateController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end

EndgateController.checkEndGateVersion = function(self)
    local params = {};
    params.booth_version = EndgateData.getInstance():getInt(GameCacheData.ENDGAME_VERSION_NEW,0);
    HttpModule.getInstance():execute(HttpModule.s_cmds.v2CheckUpdate,params);
end

--同步服务器数据
EndgateController.onDownloadProgress = function(self,flag)
    local uid = UserInfo.getInstance():getUid();
	local latest_tid = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_GATE .. uid,17);
	local latest_sort = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_SORT .. uid,0);
    local post_data = {};
	post_data.mid = uid;
	post_data.tid = latest_tid;
	post_data.pos = latest_sort;
    if flag == false then
        HttpModule.getInstance():execute(HttpModule.s_cmds.downloadGateInfo,post_data);
    else
        HttpModule.getInstance():execute(HttpModule.s_cmds.downloadGateInfo,post_data,"请稍候...");
    end
end

EndgateController.onGetBoothInfo = function(self)
    local post_data = {};
	local version = GameCacheData.getInstance():getString(GameCacheData.ENDGAME_VERSION,"");
	if version == "" then
		version = 0;
	end
	post_data.version = tonumber(version); --棋牌版本
	HttpModule.getInstance():execute(HttpModule.s_cmds.getBoothInfo,post_data,"请稍候...");
end

EndgateController.onUploadGateInfo = function(self)
    local tid = kEndgateData:getGateTid();
	local sort = kEndgateData:getGateSort()+1 ;

	local uid = UserInfo.getInstance():getUid();

	local post_data = {};
	post_data.tid = tid;
	post_data.pos = sort;
	post_data.id = kEndgateData:getBoardTableId() or -1; -------- 这个值不知道干嘛的
    HttpModule.getInstance():execute(HttpModule.s_cmds.uploadGateInfo,post_data);
end

EndgateController.onEntryGame = function(self,gate)
	kEndgateData:setGate(gate);
--	ToolKit.removeAllTipsDialog(); 
	StateMachine:getInstance():pushState(States.EndGateSub,StateMachine.STYPE_CUSTOM_WAIT);
end

EndgateController.onCheckEndingUpdate = function(self)

    local tips = nil;
	local post_data = {};
	local version = GameCacheData.getInstance():getString(GameCacheData.ENDGAME_VERSION,"");
	if version == "" then
		version = 0;
	end
	post_data.version = tonumber(version); --价格

    HttpModule.getInstance():execute(HttpModule.s_cmds.checkEndingUpdate,post_data,tips);
end

EndgateController.gotoMall = function(self)
    if not self:isLogined() then return ;end
    StateMachine.getInstance():pushState(States.Mall,StateMachine.STYPE_CUSTOM_WAIT);
end

EndgateController.updateUserInfoView = function(self)
    self:updateView(EndgateScene.s_cmds.updateUserInfoView);
end


EndgateController.onCreateCustomEndgate = function(self)
    UserInfo.getInstance():setCustomDapuType(1);
    StateMachine.getInstance():pushState(States.CustomBoard,StateMachine.STYPE_CUSTOM_WAIT);    
end;
-------------------------------- http event ------------------------

--解析服务器数据
EndgateController.serverDataResponse = function(self,isSuccess,message)
    Log.i("serverDataResponse");
    if not isSuccess then
        return ;
    end
    local data = message.data;
	if data then
        self:updateView(EndgateScene.s_cmds.serverDataResponse,data);
	end
end




EndgateController.getBoothInfoCallBack = function(self,isSuccess,message)
    Log.i("getBoothInfoCallBack");
    if not isSuccess then
        return ;
    end
    if message then
        local data = json.analyzeJsonNode(message);
		EndgateData.getInstance():saveString(GameCacheData.ENDGAME_DATA,json.encode(data));
        self:updateView(EndgateScene.s_cmds.updateListContent);
	else
		local message = "更新残局数据失败！"
		ChessToastManager.getInstance():show(message);
	end
end

EndgateController.checkEndingUpdateCallBack = function(self,isSuccess,message)
    Log.i("checkEndingUpdateCallBack");
    if not isSuccess then
        return ;
    end

    if not message.count then
		print_string("not data");
		return;
	end

	local count = message.count:get_value();
    local data = kEndgateData:getEndgateData();
    if count > #data then
	    kEndgateData:setEndingUpdateNum(count);
        self:updateView(EndgateScene.s_cmds.updataUpdateNode);
    end
end

EndgateController.v2CheckUpdateCallBack = function(self,isSuccess,message)
    Log.i("checkEndingUpdateCallBack");
    if not isSuccess then
        return ;
    end
    local data = message.data;
    if not data then return end

    local version = tonumber(data.booth_version:get_value()) or 0;
    local download_url = data.download_url:get_value();

    if not download_url then 
        ChessToastManager.getInstance():showSingle("残局版本检测失败");
        return ;
    end

    if not self.mUpdateDialog then
        self.mUpdateDialog = new(ChioceDialog);
    end
    self.mUpdateDialog:setMode(ChioceDialog.MODE_OTHER);
	self.mUpdateDialog:setMessage("正在更新残局，请稍后");
	self.mUpdateDialog:setPositiveListener(nil,nil);
	self.mUpdateDialog:show();
    self:getEndgateData(download_url,version);
end

function EndgateController:onBoothBuyGateCallback(isSuccess,message)
    if HttpModule.explainPHPMessage(isSuccess,message,"购买失败") then
        return 
    end

    local data = json.analyzeJsonNode(message.data)

    if data and tonumber(data.booth_tid) then
        local uid = UserInfo.getInstance():getUid();
		GameCacheData.getInstance():saveInt(GameCacheData.ENDGAME_LATETST_GATE .. uid,tonumber(data.booth_tid));
		GameCacheData.getInstance():saveInt(GameCacheData.ENDGAME_LATETST_SORT .. uid,0);
		GameCacheData.getInstance():saveInt(GameCacheData.ENDGAME_LATETST_SELECT_TID .. uid,tonumber(data.booth_tid));
		GameCacheData.getInstance():saveInt(GameCacheData.ENDGAME_LATETST_SELECT_POS .. uid,0);
        self:updateView(EndgateScene.s_cmds.showPassAnim)
    end
end

EndgateController.getEndgateData = function(self,download_url,version)
-- 用于清理请求
    if self.mhttpRequest then
        self.mhttpRequest:setEvent(nil,nil)
        delete(self.mhttpRequest)
    end
    local httpRequest = new(Http,kHttpPost,kHttpReserved,download_url)
    self.mhttpRequest = httpRequest
	self.mhttpRequest:setEvent(self, function(self)
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
            data = resultStr;
	    until true;

	    if errorCode ==HttpErrorType.SUCCESSED then
		    Log.i("errorCode:SUCCESSED");
            EndgateData.getInstance():saveInt(GameCacheData.ENDGAME_VERSION_NEW,version);
    		EndgateData.getInstance():saveEndgateData(data);
            if "win32"==System.getPlatform() then
                self:updateView(EndgateScene.s_cmds.resetEndgateList);
                if self.mUpdateDialog then
	                self.mUpdateDialog:setMessage("残局更新成功");
                end
            end
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
    end);
	self.mhttpRequest:setTimeout(30000,30000);
    self.mhttpRequest:execute();
    local time = os.clock();
    Log.i("aaaaaaaaaa:"..time);
end

EndgateController.resetEndgateList = function(self,status,data)
    if not status then return end
    -- 要求在残局数据先响应
    if self.mUpdateDialog then
	    self.mUpdateDialog:setMessage("残局更新成功");
    end
    self:updateView(EndgateScene.s_cmds.resetEndgateList);
end

-------------------------------- config ----------------------------

EndgateController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.downloadGateInfo] = EndgateController.serverDataResponse;
    [HttpModule.s_cmds.getBoothInfo] = EndgateController.getBoothInfoCallBack;
    [HttpModule.s_cmds.checkEndingUpdate] = EndgateController.checkEndingUpdateCallBack;
    [HttpModule.s_cmds.v2CheckUpdate]   = EndgateController.v2CheckUpdateCallBack;
    [HttpModule.s_cmds.BoothBuyGate]    = EndgateController.onBoothBuyGateCallback;
};

EndgateController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	EndgateController.s_httpRequestsCallBackFuncMap or {});


--本地事件 包括lua dispatch call事件
EndgateController.s_nativeEventFuncMap = {
    [kEndingUtilNewInit]               = EndgateController.resetEndgateList;
};


EndgateController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	EndgateController.s_nativeEventFuncMap or {});



EndgateController.s_socketCmdFuncMap = {
--	[HALL_SINGLE_BROADCARD_CMD_MSG]  = EndgateController.onSingleBroadcastCallback;
}

EndgateController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	EndgateController.s_socketCmdFuncMap or {});


------------------------------------- 命令响应函数配置 ------------------------
EndgateController.s_cmdConfig = 
{
    [EndgateController.s_cmds.onBack] = EndgateController.onBack;
    [EndgateController.s_cmds.onLoadListContent] = EndgateController.onLoadListContent;
    [EndgateController.s_cmds.onDownloadProgress] = EndgateController.onDownloadProgress;
    [EndgateController.s_cmds.onGetBoothInfo] = EndgateController.onGetBoothInfo;
    [EndgateController.s_cmds.onUploadGateInfo] = EndgateController.onUploadGateInfo;
    [EndgateController.s_cmds.onEntryGame] = EndgateController.onEntryGame;
    [EndgateController.s_cmds.onCheckEndingUpdate] = EndgateController.onCheckEndingUpdate;
    [EndgateController.s_cmds.gotoMall] = EndgateController.gotoMall;
    [EndgateController.s_cmds.onCreateCustomEndgate] = EndgateController.onCreateCustomEndgate;
    
}

