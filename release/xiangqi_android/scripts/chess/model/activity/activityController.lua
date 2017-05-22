
require("config/path_config");
require(DATA_PATH .. "dailyTaskData");

require(BASE_PATH.."chessController");
ActivityController = class(ChessController);

ActivityController.s_cmds = 
{	
    back_action         = 1;
    entryRoom           = 2;
    watch_action        = 3;
    challenge           = 4;
    getPrivateRoomNum   = 5;
    private_action      = 6;
    get_activity        = 7;
};

ActivityController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
    DailyTaskManager.getInstance():register(self,self.refreshDailyItem);
end

ActivityController.resume = function(self)
    ChessController.resume(self);
    self:getActivity();
end;

ActivityController.pause = function(self)
    ChessController.pause(self);
    DailyTaskManager.getInstance():unregister(self,self.refreshDailyItem);
end;

ActivityController.dtor = function(self)
end;

ActivityController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end;

--------------------------------function------------------------------------

function ActivityController:refreshDailyItem(taskId,data)
    self:updateView(ActivityScene.s_cmds.updateDailyItemStatus,taskId,data);
end


function ActivityController:getActivity()
    local params = {};
    params.bid = PhpConfig.getSidPlatform();
    params.versions = kLuaVersion;
    HttpModule.getInstance():execute(HttpModule.s_cmds.IndexGetActionList,params);
end

--------------------------------http----------------------------------------

ActivityController.onIndexGetActionListResponse = function(self,isSuccess,message)

    if not isSuccess or message.data:get_value() == nil then
        self:updateView(ActivityScene.s_cmds.getActionList);
        return ;
    end

    local tab = json.analyzeJsonNode(message.data);

    self:updateView(ActivityScene.s_cmds.getActionList,tab);
end
--------------------------------config--------------------------------------

ActivityController.s_cmdConfig = 
{
	[ActivityController.s_cmds.back_action]		            = ActivityController.onBack;
	[ActivityController.s_cmds.get_activity]		        = ActivityController.getActivity;

}
ActivityController.s_socketCmdFuncMap = {

};

ActivityController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.IndexGetActionList]      = ActivityController.onIndexGetActionListResponse;
};

ActivityController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	ActivityController.s_httpRequestsCallBackFuncMap or {});

ActivityController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	ActivityController.s_socketCmdFuncMap or {});