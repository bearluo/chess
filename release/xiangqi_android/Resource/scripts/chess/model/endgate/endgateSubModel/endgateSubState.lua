require("view/view_config");
require(VIEW_PATH.."endgate_sub_view");
require(MODEL_PATH.."endgate/endgateSubModel/endgateSubController");
require(MODEL_PATH.."endgate/endgateSubModel/endgateSubScene");
require(BASE_PATH.."chessState");
require(DATA_PATH.."endgateData");

EndgateSubState = class(ChessState);


EndgateSubState.ctor = function(self)
	self.m_controller = nil;
end

EndgateSubState.getController = function(self)
	return self.m_controller;
end

EndgateSubState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(EndgateSubController, self, EndgateSubScene, endgate_sub_view);
	return true;
end

EndgateSubState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


EndgateSubState.onExit = function(self)
	sys_exit();
end


EndgateSubState.onClose = function(self)
end

EndgateSubState.dtor = function(self)
end