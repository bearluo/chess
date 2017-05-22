--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23
require("view/view_config");
require(VIEW_PATH.."userinfo_view");
require(MODEL_PATH.."userInfo/userInfoController");
require(MODEL_PATH.."userInfo/userInfoScene");
require(BASE_PATH.."chessState");

UserInfoState = class(ChessState);


UserInfoState.ctor = function(self)
	self.m_controller = nil;
end

UserInfoState.getController = function(self)
	return self.m_controller;
end

UserInfoState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(UserInfoController, self, UserInfoScene, userinfo_view);
	return true;
end

UserInfoState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end

UserInfoState.onExit = function(self)
	sys_exit();
end


UserInfoState.onClose = function(self)
end

UserInfoState.dtor = function(self)
end
