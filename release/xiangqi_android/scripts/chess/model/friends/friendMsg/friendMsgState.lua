--region friendMsgState.lua.lua
--Author : LeoLi
--Date   : 2015/7/14

require("view/view_config");
require(VIEW_PATH.."friend_msg_view");
require(MODEL_PATH.."friends/friendMsg/friendMsgController");
require(MODEL_PATH.."friends/friendMsg/friendMsgScene");
require(BASE_PATH.."chessState");
require(DATA_PATH.."chatRoomData");

FriendMsgState = class(ChessState);


FriendMsgState.ctor = function(self)
	self.m_controller = nil;
end

FriendMsgState.getController = function(self)
	return self.m_controller;
end

FriendMsgState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(FriendMsgController, self, FriendMsgScene, friend_msg_view);
	return true;
end

FriendMsgState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


FriendMsgState.onExit = function(self)
	sys_exit();
end


FriendMsgState.onClose = function(self)
end

FriendMsgState.dtor = function(self)
end