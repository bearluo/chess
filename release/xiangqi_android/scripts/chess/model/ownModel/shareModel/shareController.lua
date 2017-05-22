--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23

require(BASE_PATH.."chessController")

ShareController = class(ChessController);

ShareController.s_cmds = 
{
    onBack              = 1;
};


ShareController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end

ShareController.dtor = function(self)
end

ShareController.resume = function(self)
	ChessController.resume(self);
	Log.i("ShareController.resume");
end

ShareController.pause = function(self)
	ChessController.pause(self);
	Log.i("ShareController.pause");

end

-------------------- func ----------------------------------

ShareController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end

-------------------- config --------------------------------------------------
ShareController.s_httpRequestsCallBackFuncMap  = {
};


ShareController.s_nativeEventFuncMap = {
};
ShareController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	ShareController.s_nativeEventFuncMap or {});

ShareController.s_socketCmdFuncMap = {
};
-- 合并父类 方法
ShareController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	ShareController.s_httpRequestsCallBackFuncMap or {});

ShareController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	ShareController.s_socketCmdFuncMap or {});

------------------------------------- 命令响应函数配置 ------------------------
ShareController.s_cmdConfig = 
{
    [ShareController.s_cmds.onBack]                        = ShareController.onBack;
}