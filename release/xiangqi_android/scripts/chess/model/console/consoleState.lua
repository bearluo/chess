require("view/view_config");
require(VIEW_PATH.."console_view");
require(MODEL_PATH.."console/consoleController");
require(MODEL_PATH.."console/consoleScene");
require(BASE_PATH.."chessState");

ConsoleState = class(ChessState);


ConsoleState.ctor = function(self)
	self.m_controller = nil;
end

ConsoleState.getController = function(self)
	return self.m_controller;
end

ConsoleState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(ConsoleController, self, ConsoleScene, console_view);
	return true;
end

ConsoleState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


ConsoleState.onExit = function(self)
	sys_exit();
end


ConsoleState.onClose = function(self)
end

ConsoleState.dtor = function(self)
end
