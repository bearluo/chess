require("config/path_config");

require(BASE_PATH.."chessController");

EndgateSubController = class(ChessController);

EndgateSubController.s_cmds = 
{	
    onBack = 1;
    entryGame = 2;
    gotoMall = 3;
};

EndgateSubController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end


EndgateSubController.resume = function(self)
	ChessController.resume(self);
	Log.i("EndgateSubController.resume");
end

EndgateSubController.pause = function(self)
	ChessController.pause(self);
	Log.i("EndgateSubController.pause");
end

EndgateSubController.dtor = function(self)

end

EndgateSubController.updateUserInfoView = function(self)
    self:updateView(EndgateSubScene.s_cmds.updateUserInfoView);
end

-------------------------------- func ------------------------------

EndgateSubController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end

EndgateSubController.onEntryGame = function(self)
    StateMachine:getInstance():pushState(States.EndingRoom,StateMachine.STYPE_CUSTOM_WAIT);
end

EndgateSubController.gotoMall = function(self)
    if not self:isLogined() then return ;end
    StateMachine.getInstance():pushState(States.Mall,StateMachine.STYPE_CUSTOM_WAIT);
end

-------------------------------- http event ------------------------



-------------------------------- config ----------------------------

EndgateSubController.s_httpRequestsCallBackFuncMap  = {

};

EndgateSubController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	EndgateSubController.s_httpRequestsCallBackFuncMap or {});


--本地事件 包括lua dispatch call事件
EndgateSubController.s_nativeEventFuncMap = {
};


EndgateSubController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	EndgateSubController.s_nativeEventFuncMap or {});



EndgateSubController.s_socketCmdFuncMap = {
--	[HALL_SINGLE_BROADCARD_CMD_MSG]  = EndgateSubController.onSingleBroadcastCallback;
}

EndgateSubController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	EndgateSubController.s_socketCmdFuncMap or {});


------------------------------------- 命令响应函数配置 ------------------------
EndgateSubController.s_cmdConfig = 
{
    [EndgateSubController.s_cmds.onBack] = EndgateSubController.onBack;
    [EndgateSubController.s_cmds.entryGame] = EndgateSubController.onEntryGame;
    [EndgateSubController.s_cmds.gotoMall] = EndgateSubController.gotoMall;
    
}

