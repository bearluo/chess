--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23
require("view/view_config");
require(VIEW_PATH.."about_view");
require(MODEL_PATH.."ownModel/setModel/aboutModel/aboutController");
require(MODEL_PATH.."ownModel/setModel/aboutModel/aboutScene");
require(BASE_PATH.."chessState");

AboutState = class(ChessState);


AboutState.ctor = function(self)
	self.m_controller = nil;
end

AboutState.getController = function(self)
	return self.m_controller;
end

AboutState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(AboutController, self, AboutScene, about_view);
	return true;
end

AboutState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end

AboutState.onExit = function(self)
	sys_exit();
end


AboutState.onClose = function(self)
end

AboutState.dtor = function(self)
end
