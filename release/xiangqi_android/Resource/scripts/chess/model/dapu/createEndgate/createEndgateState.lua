require("view/view_config");
require(VIEW_PATH.."dapu_create_endgate_view");
require(MODEL_PATH.."dapu/createEndgate/createEndgateController");
require(MODEL_PATH.."dapu/createEndgate/createEndgateScene");
require(BASE_PATH.."chessState");

CreateEndgateState = class(ChessState);


CreateEndgateState.ctor = function(self)
	self.m_controller = nil;
end

CreateEndgateState.getController = function(self)
	return self.m_controller;
end

CreateEndgateState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(CreateEndgateController, self, CreateEndgateScene, dapu_create_endgate_view);
	return true;
end

CreateEndgateState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


CreateEndgateState.onExit = function(self)
	sys_exit();
end


CreateEndgateState.onClose = function(self)
end

CreateEndgateState.dtor = function(self)
end