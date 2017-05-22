require(BASE_PATH.."chessController");
OfflineController = class(ChessController);

OfflineController.s_cmds = 
{	
    back_action         = 1;
};

OfflineController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end

OfflineController.resume = function(self)
    ChessController.resume(self);
end;

OfflineController.pause = function(self)
    ChessController.pause(self);
end;

OfflineController.dtor = function(self)
end;

OfflineController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);  
end


OfflineController.updateUserInfoView = function(self)
    self:updateView(OfflineScene.s_cmds.refreshUserInfo);
end

--------------------------------function------------------------------------


--------------------------------config--------------------------------------

OfflineController.s_cmdConfig = 
{
	[OfflineController.s_cmds.back_action]		            = OfflineController.onBack;

}
OfflineController.s_socketCmdFuncMap = {

};

OfflineController.s_httpRequestsCallBackFuncMap  = {

};


--本地事件 包括lua dispatch call事件
OfflineController.s_nativeEventFuncMap = {
    [kEndingUtilNewInit]               = OfflineController.updateUserInfoView;
};


OfflineController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	OfflineController.s_nativeEventFuncMap or {});

OfflineController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	OfflineController.s_httpRequestsCallBackFuncMap or {});

OfflineController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	OfflineController.s_socketCmdFuncMap or {});