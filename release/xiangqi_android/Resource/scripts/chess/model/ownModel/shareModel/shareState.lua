--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23
require("view/view_config");
require(VIEW_PATH.."share_view");
require(MODEL_PATH.."ownModel/shareModel/shareController");
require(MODEL_PATH.."ownModel/shareModel/shareScene");
require(BASE_PATH.."chessState");

ShareState = class(ChessState);


ShareState.ctor = function(self)
	self.m_controller = nil;
end

ShareState.getController = function(self)
	return self.m_controller;
end

ShareState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(ShareController, self, ShareScene, share_view);
	return true;
end

ShareState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end

ShareState.onExit = function(self)
	sys_exit();
end


ShareState.onClose = function(self)
end

ShareState.dtor = function(self)
end
