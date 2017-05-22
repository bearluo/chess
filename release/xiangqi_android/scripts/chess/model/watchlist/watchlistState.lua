--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23
require("view/view_config");
require(VIEW_PATH.."watchList_view");
require(MODEL_PATH.."watchlist/watchlistController");
require(MODEL_PATH.."watchlist/watchlistScene");
require(BASE_PATH.."chessState");

WatchlistState = class(ChessState);


WatchlistState.ctor = function(self)
	self.m_controller = nil;
end

WatchlistState.getController = function(self)
	return self.m_controller;
end

WatchlistState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(WatchlistController, self, WatchlistScene, watchList_view);
	return true;
end

WatchlistState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end

WatchlistState.onExit = function(self)
	sys_exit();
end


WatchlistState.onClose = function(self)
end

WatchlistState.dtor = function(self)
end
