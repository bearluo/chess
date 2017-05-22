require("view/view_config");
require(VIEW_PATH.."online_view");
require(MODEL_PATH.."online/onlineController");
require(MODEL_PATH.."online/onlineScene");
require(BASE_PATH.."chessState");

OnlineState = class(ChessState);


OnlineState.ctor = function(self)
	self.m_controller = nil;
end

OnlineState.getController = function(self)
	return self.m_controller;
end

OnlineState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(OnlineController, self, OnlineScene, online_view);
	return true;
end

OnlineState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


OnlineState.onExit = function(self)
	sys_exit();
end


OnlineState.onClose = function(self)
end

OnlineState.dtor = function(self)
end
