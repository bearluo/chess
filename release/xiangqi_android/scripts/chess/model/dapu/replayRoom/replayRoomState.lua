require("view/view_config");
require(VIEW_PATH.."replay_room_view");
require(MODEL_PATH.."dapu/replayRoom/replayRoomController");
require(MODEL_PATH.."dapu/replayRoom/replayRoomScene");
require(MODEL_PATH.."room/roomState");

ReplayRoomState = class(RoomState);


ReplayRoomState.ctor = function(self)
	self.m_controller = nil;
end

ReplayRoomState.getController = function(self)
	return self.m_controller;
end

ReplayRoomState.load = function(self)
	RoomState.load(self);
	self.m_controller = new(ReplayRoomController, self, ReplayRoomScene, replay_room_view);
	return true;
end

ReplayRoomState.unload = function(self)
	RoomState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


ReplayRoomState.onExit = function(self)
	sys_exit();
end


ReplayRoomState.onClose = function(self)
end

ReplayRoomState.dtor = function(self)
end
