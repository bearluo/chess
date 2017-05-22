require("view/view_config");
require(VIEW_PATH.."ending_room_view");
require(MODEL_PATH.."endgate/endgateSubModel/endgateRoom/endgateRoomController");
require(MODEL_PATH.."endgate/endgateSubModel/endgateRoom/endgateRoomScene");
require(MODEL_PATH.."room/roomState");
require(DATA_PATH.."endgateData");

EndgateRoomState = class(RoomState);


EndgateRoomState.ctor = function(self)
	self.m_controller = nil;
end

EndgateRoomState.getController = function(self)
	return self.m_controller;
end

EndgateRoomState.load = function(self)
	RoomState.load(self);
	self.m_controller = new(EndgateRoomController, self, EndgateRoomScene, ending_room_view);
	return true;
end

EndgateRoomState.unload = function(self)
	RoomState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


EndgateRoomState.onExit = function(self)
	sys_exit();
end


EndgateRoomState.onClose = function(self)
end

EndgateRoomState.dtor = function(self)
end