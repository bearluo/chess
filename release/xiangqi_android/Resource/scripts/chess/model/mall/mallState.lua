require("view/view_config");
require(VIEW_PATH.."mall_view");
require(MODEL_PATH.."mall/mallController");
require(MODEL_PATH.."mall/mallScene");
require(BASE_PATH.."chessState");

MallState = class(ChessState);


MallState.ctor = function(self)
	self.m_controller = nil;
end

MallState.getController = function(self)
	return self.m_controller;
end

MallState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(MallController, self, MallScene, mall_view);
	return true;
end

MallState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


MallState.onExit = function(self)
	sys_exit();
end


MallState.onClose = function(self)
end

MallState.dtor = function(self)
end