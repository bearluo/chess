require("view/view_config");
require(VIEW_PATH.."activity_view");
require(MODEL_PATH.."activity/activityController");
require(MODEL_PATH.."activity/activityScene");
require(BASE_PATH.."chessState");

ActivityState = class(ChessState);


ActivityState.ctor = function(self,status)
	self.m_controller = nil;
    self.m_show_dailyTask = status;
end

ActivityState.getController = function(self)
	return self.m_controller;
end

ActivityState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(ActivityController, self, ActivityScene, activity_view);
	return true;
end

ActivityState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


ActivityState.onExit = function(self)
	sys_exit();
end


ActivityState.onClose = function(self)
end

ActivityState.dtor = function(self)
end
