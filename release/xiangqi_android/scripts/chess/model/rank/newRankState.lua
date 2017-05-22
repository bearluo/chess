require("view/view_config");
require(VIEW_PATH.."rank_view");
require(MODEL_PATH.."rank/newRankController");
require(MODEL_PATH.."rank/newRankScene");
require(BASE_PATH.."chessState");

NewRankState = class(ChessState);


NewRankState.ctor = function(self,rankType)
	self.m_controller = nil;
    self.rankType = rankType;
end

NewRankState.getController = function(self)
	return self.m_controller;
end

NewRankState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(NewRankController, self, NewRankScene, rank_view);
	return true;
end

NewRankState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


NewRankState.onExit = function(self)
	sys_exit();
end


NewRankState.onClose = function(self)
end

NewRankState.dtor = function(self)
end