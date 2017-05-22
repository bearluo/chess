--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23
require("view/view_config");
require(VIEW_PATH.."help_view");
require(MODEL_PATH.."ownModel/setModel/helpModel/helpController");
require(MODEL_PATH.."ownModel/setModel/helpModel/helpScene");
require(BASE_PATH.."chessState");

HelpState = class(ChessState);


HelpState.ctor = function(self)
	self.m_controller = nil;
end

HelpState.getController = function(self)
	return self.m_controller;
end

HelpState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(HelpController, self, HelpScene, help_view);
	return true;
end

HelpState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end

HelpState.onExit = function(self)
	sys_exit();
end


HelpState.onClose = function(self)
end

HelpState.dtor = function(self)
end
