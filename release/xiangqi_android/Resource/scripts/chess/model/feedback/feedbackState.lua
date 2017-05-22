require("view/view_config");
require(VIEW_PATH.."feedback_view");
require(MODEL_PATH.."feedback/feedbackController");
require(MODEL_PATH.."feedback/feedbackScene");
require(BASE_PATH.."chessState");

FeedbackState = class(ChessState);


FeedbackState.ctor = function(self)
	self.m_controller = nil;
end

FeedbackState.getController = function(self)
	return self.m_controller;
end

FeedbackState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(FeedbackController, self, FeedbackScene, feedback_view);
	return true;
end

FeedbackState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


FeedbackState.onExit = function(self)
end


FeedbackState.onClose = function(self)
end

FeedbackState.dtor = function(self)
end