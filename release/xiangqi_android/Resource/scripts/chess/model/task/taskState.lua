require("view/view_config");
require(VIEW_PATH.."task_view_new");
require(MODEL_PATH.."task/taskController");
require(MODEL_PATH.."task/taskScene");
require(BASE_PATH.."chessState");

TaskState = class(ChessState);


TaskState.ctor = function(self,status)
	self.m_controller = nil;
    self.m_show_dailyTask = status;
end

TaskState.getController = function(self)
	return self.m_controller;
end

TaskState.load = function(self)
	ChessState.load(self);
	self.m_controller = new(TaskController, self, TaskScene, task_view_new);
	return true;
end

TaskState.unload = function(self)
	ChessState.unload(self);
	delete(self.m_controller);
	self.m_controller = nil;
end


TaskState.onExit = function(self)
	sys_exit();
end


TaskState.onClose = function(self)
end

TaskState.dtor = function(self)
end
