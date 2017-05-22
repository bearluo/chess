--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23
require("view/view_config");
require(VIEW_PATH.."find_view");
require(MODEL_PATH.."findModel/findController");
require(MODEL_PATH.."findModel/findScene");
require(BASE_PATH.."chessState");

FindState = class(ChessState);


FindState.ctor = function(self)
	self.m_controller = nil;
end

FindState.getController = function(self)
	return self.m_controller;
end

FindState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(FindController, self, FindScene, find_view);
	return true;
end

FindState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end

FindState.onExit = function(self)
	sys_exit();
end


FindState.onClose = function(self)
end

FindState.dtor = function(self)
end
