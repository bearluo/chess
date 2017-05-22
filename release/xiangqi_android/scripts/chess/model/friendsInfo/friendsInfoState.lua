require("view/view_config");
require(VIEW_PATH.."friends_info_view");
require(MODEL_PATH.."friendsInfo/friendsInfoController");
require(MODEL_PATH.."friendsInfo/friendsInfoScene");
require(BASE_PATH.."chessState");

FriendsInfoState = class(ChessState);


FriendsInfoState.ctor = function(self, uid)
	self.m_controller = nil;
    self.m_uid = uid;
end

FriendsInfoState.getController = function(self)
	return self.m_controller;
end

FriendsInfoState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(FriendsInfoController, self, FriendsInfoScene, friends_info_view);
	return true;
end

FriendsInfoState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end

FriendsInfoState.onExit = function(self)
	sys_exit();
end


FriendsInfoState.onClose = function(self)
end

FriendsInfoState.dtor = function(self)
end