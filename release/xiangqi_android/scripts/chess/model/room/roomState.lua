require("view/view_config");
require(VIEW_PATH.."room_view");
require(MODEL_PATH.."room/roomController");
require(MODEL_PATH.."room/roomScene");
require(BASE_PATH.."chessState");

RoomState = class(ChessState);


RoomState.ctor = function(self)
	self.m_controller = nil;
end

RoomState.getController = function(self)
	
end

RoomState.load = function(self)
	ChessState.load(self);
	return true;
end

RoomState.unload = function(self)
	ChessState.unload(self);
end


RoomState.onExit = function(self)
	sys_exit();
end


RoomState.onClose = function(self)
end

RoomState.dtor = function(self)
end