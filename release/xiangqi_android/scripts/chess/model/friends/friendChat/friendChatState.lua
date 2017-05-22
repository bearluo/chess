--region FriendChatState.lua.lua
--Author : LeoLi
--Date   : 2015/7/14

require("view/view_config");
require(VIEW_PATH.."friends_chat_view");
require(MODEL_PATH.."friends/friendChat/friendChatController");
require(MODEL_PATH.."friends/friendChat/friendChatScene");
require(BASE_PATH.."chessState");

FriendChatState = class(ChessState);


FriendChatState.ctor = function(self, friend)
	self.m_controller = nil;
    self.m_friend_data = friend;
end

FriendChatState.getController = function(self)
	return self.m_controller;
end

FriendChatState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(FriendChatController, self, FriendChatScene, friends_chat_view);
	return true;
end

FriendChatState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


FriendChatState.onExit = function(self)
	sys_exit();
end


FriendChatState.onClose = function(self)
end

FriendChatState.dtor = function(self)
end