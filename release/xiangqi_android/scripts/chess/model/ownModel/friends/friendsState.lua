--region NewFile_1.lua
--Author : FordFan
--Date   : 2015/11/7
-- 我的模块 好友界面
--endregion

require("view/view_config");
require(VIEW_PATH.."chess_friend_view");
require(MODEL_PATH.."ownModel/friends/friendsController");
require(MODEL_PATH.."ownModel/friends/friendsScene");
require(BASE_PATH.."chessState");

FriendsState = class(ChessState);

FriendsState.ctor = function(self)
	self.m_controller = nil;
--    self.kinf_num = num;
end

FriendsState.getController = function(self)
	return self.m_controller;
end

FriendsState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(FriendsController, self, FriendsScene, chess_friend_view);
	return true;
end

FriendsState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


FriendsState.onExit = function(self)
	sys_exit();
end


FriendsState.onClose = function(self)
end

FriendsState.dtor = function(self)
end
