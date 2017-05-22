require("view/view_config");
require(VIEW_PATH.."rank_view");
require(MODEL_PATH.."rank/newRankController");
require(MODEL_PATH.."rank/newRankScene");
require(BASE_PATH.."chessState");

RankState = class(ChessState);


RankState.ctor = function(self)
	self.m_controller = nil;
end

RankState.getController = function(self)
	return self.m_controller;
end

RankState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(NewRankController, self, NewRankScene, rank_view);
	return true;
end

RankState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


RankState.onExit = function(self)
	sys_exit();
end


RankState.onClose = function(self)
end

RankState.dtor = function(self)
end