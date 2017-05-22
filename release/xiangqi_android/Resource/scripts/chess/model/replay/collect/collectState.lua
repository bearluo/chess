require("view/view_config");
require(VIEW_PATH.."collect_view");
require(MODEL_PATH.."replay/collect/collectController");
require(MODEL_PATH.."replay/collect/collectScene");
require(BASE_PATH.."chessState");

CollectState = class(ChessState);


CollectState.ctor = function(self)
	self.m_controller = nil;
end

CollectState.getController = function(self)
	return self.m_controller;
end

CollectState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(CollectController, self, CollectScene, collect_view);
	return true;
end

CollectState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


CollectState.onExit = function(self)
	sys_exit();
end


CollectState.onClose = function(self)
end

CollectState.dtor = function(self)
end
