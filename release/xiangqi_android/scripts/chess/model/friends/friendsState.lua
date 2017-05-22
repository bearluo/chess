require("view/view_config");
require(VIEW_PATH.."friendsList_view");
require(MODEL_PATH.."friends/friendsController");
require(MODEL_PATH.."friends/friendsScene");
require(BASE_PATH.."chessState");

FriendsState = class(ChessState);


FriendsState.ctor = function(self,num)
	self.m_controller = nil;
    self.kinf_num = num;
end

FriendsState.getController = function(self)
	return self.m_controller;
end

FriendsState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(FriendsController, self, FriendsScene, friendsList_view);
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