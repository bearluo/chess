require("view/view_config");
require(VIEW_PATH.."hall_view");
require(MODEL_PATH.."hall/hallController");
require(MODEL_PATH.."hall/hallScene");
require(BASE_PATH.."chessState");
require(DATA_PATH .. "cityData");

HallState = class(ChessState);


HallState.ctor = function(self)
	self.m_controller = nil;
end

HallState.getController = function(self)
	return self.m_controller;
end

HallState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(HallController, self, HallScene, hall_view);
	return true;
end

HallState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


HallState.onExit = function(self)
	sys_exit();
end


HallState.onClose = function(self)
end

HallState.dtor = function(self)
end