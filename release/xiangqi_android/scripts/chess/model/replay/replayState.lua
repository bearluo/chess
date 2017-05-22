require("view/view_config");
require(VIEW_PATH.."replay_view");
require(MODEL_PATH.."replay/replayController");
require(MODEL_PATH.."replay/replayScene");
require(BASE_PATH.."chessState");

ReplayState = class(ChessState);


ReplayState.ctor = function(self)
	self.m_controller = nil;
end

ReplayState.getController = function(self)
	return self.m_controller;
end

ReplayState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(ReplayController, self, ReplayScene, replay_view);
	return true;
end

ReplayState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


ReplayState.onExit = function(self)
	sys_exit();
end


ReplayState.onClose = function(self)
end

ReplayState.dtor = function(self)
end
