require("view/view_config");
require(VIEW_PATH.."watch_view");
require(MODEL_PATH.."online/watch/watchController");
require(MODEL_PATH.."online/watch/watchScene");
require(BASE_PATH.."chessState");

WatchState = class(ChessState);


WatchState.ctor = function(self)
	self.m_controller = nil;
end

WatchState.getController = function(self)
	return self.m_controller;
end

WatchState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(WatchController, self, WatchScene, watch_view);
	return true;
end

WatchState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


WatchState.onExit = function(self)
	sys_exit();
end


WatchState.onClose = function(self)
end

WatchState.dtor = function(self)
end
