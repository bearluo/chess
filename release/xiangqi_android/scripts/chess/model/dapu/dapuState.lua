require("view/view_config");
require(VIEW_PATH.."dapu_view");
require(MODEL_PATH.."dapu/dapuController");
require(MODEL_PATH.."dapu/dapuScene");
require(BASE_PATH.."chessState");

DapuState = class(ChessState);


DapuState.ctor = function(self)
	self.m_controller = nil;
end

DapuState.getController = function(self)
	return self.m_controller;
end

DapuState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(DapuController, self, DapuScene, dapu_view);
	return true;
end

DapuState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


DapuState.onExit = function(self)
	sys_exit();
end


DapuState.onClose = function(self)
end

DapuState.dtor = function(self)
end