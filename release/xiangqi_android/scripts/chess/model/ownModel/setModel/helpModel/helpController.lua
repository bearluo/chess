--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23

require(BASE_PATH.."chessController")

HelpController = class(ChessController);

HelpController.s_cmds = 
{
    onBack = 1;
};


HelpController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end

HelpController.dtor = function(self)
end

HelpController.resume = function(self)
	ChessController.resume(self);
	Log.i("HelpController.resume");
end

HelpController.pause = function(self)
	ChessController.pause(self);
	Log.i("HelpController.pause");

end

-------------------- func ----------------------------------

HelpController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end



-------------------- config --------------------------------------------------
HelpController.s_httpRequestsCallBackFuncMap  = {
};


HelpController.s_nativeEventFuncMap = {
};
HelpController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	HelpController.s_nativeEventFuncMap or {});

HelpController.s_socketCmdFuncMap = {
};
-- 合并父类 方法
HelpController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	HelpController.s_httpRequestsCallBackFuncMap or {});

HelpController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	HelpController.s_socketCmdFuncMap or {});

------------------------------------- 命令响应函数配置 ------------------------
HelpController.s_cmdConfig = 
{
    [HelpController.s_cmds.onBack]                   = HelpController.onBack;
}