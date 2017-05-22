require("view/view_config");
require(VIEW_PATH.."console_room_view");
require(MODEL_PATH.."console/consoleRoom/consoleRoomController");
require(MODEL_PATH.."console/consoleRoom/consoleRoomScene");
require(MODEL_PATH.."room/roomState");

ConsoleRoomState = class(RoomState);


ConsoleRoomState.ctor = function(self)
	self.m_controller = nil;
end

ConsoleRoomState.getController = function(self)
	return self.m_controller;
end

ConsoleRoomState.load = function(self)
	RoomState.load(self);
	self.m_controller = new(ConsoleRoomController, self, ConsoleRoomScene, console_room_view);
	return true;
end

ConsoleRoomState.unload = function(self)
	RoomState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


ConsoleRoomState.onExit = function(self)
	sys_exit();
end


ConsoleRoomState.onClose = function(self)
end

ConsoleRoomState.dtor = function(self)
end