require("view/view_config");
require(VIEW_PATH.."room_view");
require(MODEL_PATH.."online/onlineRoom/onlineRoomController");
require(MODEL_PATH.."online/onlineRoom/onlineRoomSceneNew");
require(MODEL_PATH.."room/roomState");

OnlineRoomState = class(RoomState);


OnlineRoomState.ctor = function(self)
	self.m_controller = nil;
end

OnlineRoomState.getController = function(self)
	return self.m_controller;
end

OnlineRoomState.load = function(self)
	RoomState.load(self);
	self.m_controller = new(OnlineRoomController, self, OnlineRoomSceneNew, room_view);
	return true;
end

OnlineRoomState.unload = function(self)
	RoomState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


OnlineRoomState.onExit = function(self)
	sys_exit();
end


OnlineRoomState.onClose = function(self)
end

OnlineRoomState.dtor = function(self)
end