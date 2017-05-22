--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23
require("view/view_config");
require(VIEW_PATH.."recently_player_view");
require(MODEL_PATH.."findModel/recentlyPlayer/recentlyPlayerController");
require(MODEL_PATH.."findModel/recentlyPlayer/recentlyPlayerScene");
require(BASE_PATH.."chessState");

RecentlyPlayerState = class(ChessState);


RecentlyPlayerState.ctor = function(self)
	self.m_controller = nil;
end

RecentlyPlayerState.getController = function(self)
	return self.m_controller;
end

RecentlyPlayerState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(RecentlyPlayerController, self, RecentlyPlayerScene, recently_player_view);
	return true;
end

RecentlyPlayerState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end

RecentlyPlayerState.onExit = function(self)
	sys_exit();
end


RecentlyPlayerState.onClose = function(self)
end

RecentlyPlayerState.dtor = function(self)
end
