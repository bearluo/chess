require("view/view_config");
require(VIEW_PATH.."play_create_ending_room_view");
require(MODEL_PATH.."dapu/playCreateEndgateRoom/playCreateEndgateRoomController");
require(MODEL_PATH.."dapu/playCreateEndgateRoom/playCreateEndgateRoomScene");
require(MODEL_PATH.."room/roomState");
require(DATA_PATH.."endgateData");

PlayCreateEndgateRoomState = class(RoomState);


PlayCreateEndgateRoomState.ctor = function(self)
	self.m_controller = nil;
end

PlayCreateEndgateRoomState.getController = function(self)
	return self.m_controller;
end

PlayCreateEndgateRoomState.load = function(self)
	RoomState.load(self);
	self.m_controller = new(PlayCreateEndgateRoomController, self, PlayCreateEndgateRoomScene, play_create_ending_room_view);
	return true;
end

PlayCreateEndgateRoomState.unload = function(self)
	RoomState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


PlayCreateEndgateRoomState.onExit = function(self)
	sys_exit();
end


PlayCreateEndgateRoomState.onClose = function(self)
end

PlayCreateEndgateRoomState.dtor = function(self)
end