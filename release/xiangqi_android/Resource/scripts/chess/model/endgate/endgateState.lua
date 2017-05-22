require("view/view_config");
require(VIEW_PATH.."endgate_view");
require(MODEL_PATH.."endgate/endgateController");
require(MODEL_PATH.."endgate/endgateScene");
require(BASE_PATH.."chessState");
require(DATA_PATH.."endgateData");

EndgateState = class(ChessState);


EndgateState.ctor = function(self)
	self.m_controller = nil;
end

EndgateState.getController = function(self)
	return self.m_controller;
end

EndgateState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(EndgateController, self, EndgateScene, endgate_view);
	return true;
end

EndgateState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


EndgateState.onExit = function(self)
	sys_exit();
end


EndgateState.onClose = function(self)
end

EndgateState.dtor = function(self)
end