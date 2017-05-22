
require("config/path_config");
require(DATA_PATH .. "dailyTaskData");

require(BASE_PATH.."chessController");
TaskController = class(ChessController);

TaskController.s_cmds = 
{	
    back_action         = 1;
    entryRoom           = 2;
    watch_action        = 3;
    challenge           = 4;
    getPrivateRoomNum   = 5;
    private_action      = 6;
    get_activity        = 7;
};

TaskController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end

TaskController.resume = function(self)
    ChessController.resume(self)
    DailyTaskManager.getInstance():register(self,self.refreshDailyItem)
    DailyTaskManager.getInstance():register(self,self.refreshGrowTaskItem)
    self:updateView(TaskScene.s_cmds.refreshView)
end

TaskController.pause = function(self)
    ChessController.pause(self)
    DailyTaskManager.getInstance():unregister(self,self.refreshDailyItem)
    DailyTaskManager.getInstance():unregister(self,self.refreshGrowTaskItem)
end

TaskController.dtor = function(self)
end

TaskController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end;

--------------------------------function------------------------------------

function TaskController:refreshDailyItem(taskId,data,isDailyTask)
    self:updateView(TaskScene.s_cmds.updateDailyItemStatus,taskId,data,isDailyTask);
end

function TaskController:refreshGrowTaskItem(taskId,data,isDailyTask)
    self:updateView(TaskScene.s_cmds.updateGrowItemStatus,taskId,data,isDailyTask);
end

--------------------------------http----------------------------------------

--------------------------------config--------------------------------------

TaskController.s_cmdConfig = 
{
	[TaskController.s_cmds.back_action]		            = TaskController.onBack;

}
TaskController.s_socketCmdFuncMap = {

};

TaskController.s_httpRequestsCallBackFuncMap  = {
};

TaskController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	TaskController.s_httpRequestsCallBackFuncMap or {});

TaskController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	TaskController.s_socketCmdFuncMap or {});