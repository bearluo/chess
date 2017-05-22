require("view/view_config");
require(VIEW_PATH.."private_view");
require(MODEL_PATH.."online/private/privateController");
require(MODEL_PATH.."online/private/privateScene");
require(BASE_PATH.."chessState");

PrivateState = class(ChessState);


PrivateState.ctor = function(self)
	self.m_controller = nil;
end

PrivateState.getController = function(self)
	return self.m_controller;
end

PrivateState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(PrivateController, self, PrivateScene, private_view);
	return true;
end

PrivateState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


PrivateState.onExit = function(self)
	sys_exit();
end


PrivateState.onClose = function(self)
end

PrivateState.dtor = function(self)
end
