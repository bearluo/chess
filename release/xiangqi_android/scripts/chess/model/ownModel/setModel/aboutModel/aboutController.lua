--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23

require(BASE_PATH.."chessController")

AboutController = class(ChessController);

AboutController.s_cmds = 
{
    onBack = 1;
};


AboutController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end

AboutController.dtor = function(self)
end

AboutController.resume = function(self)
	ChessController.resume(self);
	Log.i("AboutController.resume");
end

AboutController.pause = function(self)
	ChessController.pause(self);
	Log.i("AboutController.pause");

end

-------------------- func ----------------------------------

AboutController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end



-------------------- config --------------------------------------------------
AboutController.s_httpRequestsCallBackFuncMap  = {
};


AboutController.s_nativeEventFuncMap = {
};
AboutController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	AboutController.s_nativeEventFuncMap or {});

AboutController.s_socketCmdFuncMap = {
};
-- 合并父类 方法
AboutController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	AboutController.s_httpRequestsCallBackFuncMap or {});

AboutController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	AboutController.s_socketCmdFuncMap or {});

------------------------------------- 命令响应函数配置 ------------------------
AboutController.s_cmdConfig = 
{
    [AboutController.s_cmds.onBack]                   = AboutController.onBack;
}