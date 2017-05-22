require("view/view_config");
require(VIEW_PATH.."dapu_custom_board_view");
require(MODEL_PATH.."dapu/customBoard/customBoardController");
require(MODEL_PATH.."dapu/customBoard/customBoardScene");
require(BASE_PATH.."chessState");

CustomBoardState = class(ChessState);


CustomBoardState.ctor = function(self)
	self.m_controller = nil;
end

CustomBoardState.getController = function(self)
	return self.m_controller;
end

CustomBoardState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(CustomBoardController, self, CustomBoardScene, dapu_custom_board_view);
	return true;
end

CustomBoardState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


CustomBoardState.onExit = function(self)
	sys_exit();
end


CustomBoardState.onClose = function(self)
end

CustomBoardState.dtor = function(self)
end