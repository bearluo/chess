require(MODEL_PATH .. "room/roomController")

DapuRoomController = class(RoomController)



DapuRoomController.s_cmds = 
{	
    share_action    = 1;
    leave_action    = 2;
    switch_menu     = 3;
    start_game      = 4;
    retry_action    = 5;
    event_state     = 6;
    undo_action     = 7;

};

DapuRoomController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
    self.m_room  = self.m_view;
end

DapuRoomController.resume = function(self)
    RoomController.resume(self);
end;

DapuRoomController.pause = function(self)
    RoomController.pause(self);
end;

DapuRoomController.dtor = function(self)
    
end;

DapuRoomController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end;