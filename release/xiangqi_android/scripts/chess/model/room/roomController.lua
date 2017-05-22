require("config/path_config");

require(BASE_PATH.."chessController");
require("audio/sound_manager");
require(NET_PATH.."hall/hallSocketCmd");
RoomController = class(ChessController);

RoomController.s_cmds = 
{	
    back_action    = 1;
    reset_progress = 2;
    add_coin       = 3;
    entryRoom      = 4;
};

RoomController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;

    
end

RoomController.resume = function(self)
    ChessController.resume(self);
--    self:addSocketTools();
    kMusicPlayer.playRoomBg();
end;

RoomController.pause = function(self)
    ChessController.pause(self);
--    self:removeSocketTools();
end;

RoomController.dtor = function(self)
    kMusicPlayer.playHallBg();
end;

RoomController.clearDiechess = function(self)

end

RoomController.setDieChess = function(self,dieChess)

end

RoomController.showResultDialog = function(self)

end

RoomController.chessMove = function(self,data)

end

RoomController.setBoradCode = function(self,code)
    self.m_boradCode = code;
    self:setGameOver(true);
end

RoomController.setGameOver = function(self,flag)

end
--------------------------------function------------------------------------



RoomController.onBackAction = function(self)

    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);

end;




--------------------------------config--------------------------------------

RoomController.s_cmdConfig = 
{
	[RoomController.s_cmds.back_action]		= RoomController.onBackAction;
    [RoomController.s_cmds.reset_progress]	= RoomController.onResetProgress;
    [RoomController.s_cmds.add_coin]		= RoomController.onAddCoin;
    
}

--��Ӧsocket��Ӧ�¼�
RoomController.s_socketCmdFuncMap = {
--    [SERVER_OFFLINE_RECONNECTED]    = RoomController.onServerOfflineReconnected;
--    [CLIENT_WATCH_LOGIN]            = RoomController.onClientWatchLogin;
--    [CLIENT_WATCH_USERLIST]         = RoomController.onRecvClientWatchUserlist;
--    [CLIENT_WATCH_TRENDS]           = RoomController.onRecvClientWatchTrends;
--    [CLIENT_WATCH_SYNCHRODATA]      = RoomController.onRecvClientWatchSynData;
}

RoomController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	RoomController.s_httpRequestsCallBackFuncMap or {});

RoomController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	RoomController.s_nativeEventFuncMap or {});

RoomController.s_socketCmdFuncMap =CombineTables(ChessController.s_socketCmdFuncMap,
	RoomController.s_socketCmdFuncMap or {});