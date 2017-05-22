require(MODEL_PATH .. "room/roomController")

ReplayRoomController = class(RoomController)



ReplayRoomController.s_cmds = 
{	
    onBack          = 1;
    save_mychess    = 2;
};

ReplayRoomController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
    self.m_room  = self.m_view;
end

ReplayRoomController.resume = function(self)
    RoomController.resume(self);
end;

ReplayRoomController.pause = function(self)
    RoomController.pause(self);
end;

ReplayRoomController.dtor = function(self)
    
end;

ReplayRoomController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end;


ReplayRoomController.onSaveMychess = function(self,isSelf, chessData)
    local post_data = {};
    post_data.mid = UserInfo.getInstance():getUid();
    post_data.down_user = chessData.down_user;
    post_data.red_mid = chessData.red_mid;
    post_data.black_mid = chessData.black_mid;
    post_data.win_flag = chessData.win_flag;
    post_data.end_type = chessData.end_type;
    post_data.manual_type = chessData.manual_type;
    post_data.start_fen = chessData.start_fen;
    post_data.move_list = chessData.move_list;
    post_data.end_fen = chessData.end_fen;
    post_data.collect_type = (isSelf and 2) or 1; -- 收藏类型, 1公共收藏，2人个收藏 
    self:sendHttpMsg(HttpModule.s_cmds.saveMychess,post_data);
end

-------------------------------- http ------------------------------------
ReplayRoomController.onSaveChessCallBack = function(self, flag, message)
    if not flag then
        if type(message) == "number" then
            return; 
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
            return;
        end;        
    end;
    local data = json.analyzeJsonNode(message.data);
    self:updateView(ReplayRoomScene.s_cmds.save_mychess,data);
end;
--------------------------------config-------------------------------------
ReplayRoomController.s_cmdConfig = 
{
    [ReplayRoomController.s_cmds.onBack]                = ReplayRoomController.onBack;
    [ReplayRoomController.s_cmds.save_mychess]          = ReplayRoomController.onSaveMychess;


};

ReplayRoomController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.saveMychess]                         = ReplayRoomController.onSaveChessCallBack;
};

ReplayRoomController.s_httpRequestsCallBackFuncMap = CombineTables(RoomController.s_httpRequestsCallBackFuncMap,
	ReplayRoomController.s_httpRequestsCallBackFuncMap or {});

ReplayRoomController.s_nativeEventFuncMap = {
};
ReplayRoomController.s_nativeEventFuncMap = CombineTables(RoomController.s_nativeEventFuncMap,
	ReplayRoomController.s_nativeEventFuncMap or {});