--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23
require("view/view_config");
require(VIEW_PATH.."set_view");
require(MODEL_PATH.."ownModel/setModel/setController");
require(MODEL_PATH.."ownModel/setModel/setScene");
require(BASE_PATH.."chessState");

SetState = class(ChessState);


SetState.ctor = function(self)
	self.m_controller = nil;
end

SetState.getController = function(self)
	return self.m_controller;
end

SetState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(SetController, self, SetScene, set_view);
	return true;
end

SetState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end

SetState.onExit = function(self)
	sys_exit();
end


SetState.onClose = function(self)
end

SetState.dtor = function(self)
end
