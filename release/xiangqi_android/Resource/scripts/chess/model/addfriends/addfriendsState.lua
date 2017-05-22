require("view/view_config");
require(VIEW_PATH.."addfriends_view");
require(MODEL_PATH.."addfriends/addfriendsController");
require(MODEL_PATH.."addfriends/addfriendsScene");
require(BASE_PATH.."chessState");

AddFriendsState = class(ChessState);


AddFriendsState.ctor = function(self,datas)
	self.m_controller = nil;
    self.m_datas = datas;
end

AddFriendsState.getController = function(self)
	return self.m_controller;
end

AddFriendsState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(AddFriendsController, self, AddFriendsScene, addfriends_view);
	return true;
end

AddFriendsState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end

AddFriendsState.onExit = function(self)
	sys_exit();
end


AddFriendsState.onClose = function(self)
end

AddFriendsState.dtor = function(self)
end