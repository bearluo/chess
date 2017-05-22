require("view/view_config");
require(VIEW_PATH .. "friends_chat_view");
require(MODEL_PATH .. "friends/chatRoom/chatRoomScene");
require(MODEL_PATH .. "friends/chatRoom/chatRoomController");
require(BASE_PATH .. "chessState");
require(DATA_PATH .. "chatRoomData");

ChatRoomState = class(ChessState);

ChatRoomState.ctor = function(self,data,msgData)
	self.m_controller = nil;
	self.m_room_data = data;
    self.m_lastMsgData = msgData;
end

ChatRoomState.getController = function(self)
	return self.m_controller;
end

ChatRoomState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(ChatRoomController, self, ChatRoomScene, friends_chat_view);
	return true;
end

ChatRoomState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end

ChatRoomState.onExit = function(self)
	sys_exit();
end

ChatRoomState.dtor = function(self)

end