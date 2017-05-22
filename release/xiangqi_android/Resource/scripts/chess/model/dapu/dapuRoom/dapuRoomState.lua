require("view/view_config");
require(VIEW_PATH.."dapu_room_view");
require(MODEL_PATH.."dapu/dapuRoom/dapuRoomController");
require(MODEL_PATH.."dapu/dapuRoom/dapuRoomScene");
require(MODEL_PATH.."room/roomState");

DapuRoomState = class(RoomState);


DapuRoomState.ctor = function(self)
	self.m_controller = nil;
end

DapuRoomState.getController = function(self)
	return self.m_controller;
end

DapuRoomState.load = function(self)
	RoomState.load(self);
	self.m_controller = new(DapuRoomController, self, DapuRoomScene, dapu_room_view);
	return true;
end

DapuRoomState.unload = function(self)
	RoomState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


DapuRoomState.onExit = function(self)
	sys_exit();
end


DapuRoomState.onClose = function(self)
end

DapuRoomState.dtor = function(self)
end
