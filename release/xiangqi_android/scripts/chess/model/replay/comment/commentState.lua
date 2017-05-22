require("view/view_config");
require(VIEW_PATH.."comment_view");
require(MODEL_PATH.."replay/comment/commentController");
require(MODEL_PATH.."replay/comment/commentScene");
require(BASE_PATH.."chessState");

CommentState = class(ChessState);


CommentState.ctor = function(self)
	self.m_controller = nil;
end

CommentState.getController = function(self)
	return self.m_controller;
end

CommentState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(CommentController, self, CommentScene, comment_view);
	return true;
end

CommentState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


CommentState.onExit = function(self)
	sys_exit();
end


CommentState.onClose = function(self)
end

CommentState.dtor = function(self)
end
