--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23
require("view/view_config");
require(VIEW_PATH.."own_view");
require(MODEL_PATH.."ownModel/ownController");
require(MODEL_PATH.."ownModel/ownScene");
require(BASE_PATH.."chessState");

OwnState = class(ChessState);


OwnState.ctor = function(self)
	self.m_controller = nil;
end

OwnState.getController = function(self)
	return self.m_controller;
end

OwnState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(OwnController, self, OwnScene, own_view);
	return true;
end

OwnState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end

OwnState.onExit = function(self)
	sys_exit();
end


OwnState.onClose = function(self)
end

OwnState.dtor = function(self)
end
