--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23

require(BASE_PATH.."chessController")

AssetsController = class(ChessController);

AssetsController.s_cmds = 
{
    onBack = 1;
};


AssetsController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end

AssetsController.dtor = function(self)
end

AssetsController.resume = function(self)
	ChessController.resume(self);
	Log.i("AssetsController.resume");
end

AssetsController.pause = function(self)
	ChessController.pause(self);
	Log.i("AssetsController.pause");

end

-------------------- func ----------------------------------

AssetsController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end



-------------------- config --------------------------------------------------
AssetsController.s_httpRequestsCallBackFuncMap  = {
};


AssetsController.s_nativeEventFuncMap = {
};
AssetsController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	AssetsController.s_nativeEventFuncMap or {});

AssetsController.s_socketCmdFuncMap = {
};
-- 合并父类 方法
AssetsController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	AssetsController.s_httpRequestsCallBackFuncMap or {});

AssetsController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	AssetsController.s_socketCmdFuncMap or {});

------------------------------------- 命令响应函数配置 ------------------------
AssetsController.s_cmdConfig = 
{
    [AssetsController.s_cmds.onBack]                   = AssetsController.onBack;
}