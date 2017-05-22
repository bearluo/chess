require("view/view_config");
require(VIEW_PATH.."recent_chess");
require(MODEL_PATH.."dapu/recentChessController");
require(MODEL_PATH.."dapu/recentChessScene");
require(BASE_PATH.."chessState");

RecentChessState = class(ChessState);


RecentChessState.ctor = function(self)
	self.m_controller = nil;
end

RecentChessState.getController = function(self)
	return self.m_controller;
end

RecentChessState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(RecentChessController, self, RecentChessScene, recent_chess);
	return true;
end

RecentChessState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


RecentChessState.onExit = function(self)
	sys_exit();
end


RecentChessState.onClose = function(self)
end

RecentChessState.dtor = function(self)
end