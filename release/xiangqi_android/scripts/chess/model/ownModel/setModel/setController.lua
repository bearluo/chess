--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23

require(BASE_PATH.."chessController")

SetController = class(ChessController);

SetController.s_cmds = 
{
    onBack     = 1;
    cleanCache = 2;
};


SetController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end

SetController.dtor = function(self)
end

SetController.resume = function(self)
	ChessController.resume(self);
	Log.i("SetController.resume");
    call_native(kGetAppCacheSize);
    -- 检测版本
    if not self:checkVersion() then
        require(UPDATE_PATH.."onlineUpdate");
        self:updateView(SetScene.s_cmds.update_version_view,OnlineUpdate.getInstance():getUpdateData());
    end
end

SetController.pause = function(self)
	ChessController.pause(self);
	Log.i("SetController.pause");

end

-------------------- func ----------------------------------

SetController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end

SetController.onCheckVersion = function(self,isSuccess,message) 
    if not isSuccess then
        return ;
    end

    if tonumber(message.flag:get_value()) == 40000 then
	    UserInfo.getInstance():setCheckVersion(true);
  		return;
  	end

  	if(message.data ~= nil) then
  		self:explainCheckVersionResult(message.data);
  	end
end

function SetController:cleanCache()
    call_native(kCleanAppCache);
end

function SetController:onRecvCacheSize(status,json_data)
    if not status or not json_data then 
        return ;
    end

    local cacheSize;
    if json_data.CacheSize:get_value() then
		cacheSize = json_data.CacheSize:get_value();
        self:updateView(SetScene.s_cmds.updataCacheSize,cacheSize);
    end
end

function SetController:onCleanAppCacheCallBack(status,json_data)
    if not status then 
        return ;
    end

    self:updateView(SetScene.s_cmds.updataCacheSize);
end

-------------------- config --------------------------------------------------
SetController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.checkVersion_new] = SetController.onCheckVersion;
};


SetController.s_nativeEventFuncMap = {
    [kGetAppCacheSize]        = SetController.onRecvCacheSize;
    [kCleanAppCache]          = SetController.onCleanAppCacheCallBack;

};
SetController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	SetController.s_nativeEventFuncMap or {});

SetController.s_socketCmdFuncMap = {
};
-- 合并父类 方法
SetController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	SetController.s_httpRequestsCallBackFuncMap or {});

SetController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	SetController.s_socketCmdFuncMap or {});

------------------------------------- 命令响应函数配置 ------------------------
SetController.s_cmdConfig = 
{
    [SetController.s_cmds.onBack]                   = SetController.onBack;
    [SetController.s_cmds.cleanCache]               = SetController.cleanCache;
}