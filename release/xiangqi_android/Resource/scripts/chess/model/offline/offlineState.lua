require("view/view_config");
require(VIEW_PATH.."offline_view");
require(MODEL_PATH.."offline/offlineController");
require(MODEL_PATH.."offline/offlineScene");
require(BASE_PATH.."chessState");

OfflineState = class(ChessState);


OfflineState.ctor = function(self)
	self.m_controller = nil;
end

OfflineState.getController = function(self)
	return self.m_controller;
end

OfflineState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(OfflineController, self, OfflineScene, offline_view);
	return true;
end

OfflineState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


OfflineState.onExit = function(self)
	sys_exit();
end


OfflineState.onClose = function(self)
end

OfflineState.dtor = function(self)
end
