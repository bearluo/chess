--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23

require(BASE_PATH.."chessController")

AssetsController = class(ChessController);

AssetsController.s_cmds = 
{
    onBack = 1;
};


AssetsController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end

AssetsController.dtor = function(self)
end

AssetsController.resume = function(self)
	ChessController.resume(self);
    self:getTicketNum()
--    User.getUserTicket
	Log.i("AssetsController.resume");
end

AssetsController.pause = function(self)
	ChessController.pause(self);
	Log.i("AssetsController.pause");

end

-------------------- func ----------------------------------

AssetsController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end

AssetsController.getTicketNum = function(self)
    self:sendHttpMsg(HttpModule.s_cmds.getUserTicket)
end

AssetsController.onGetTicketResponse = function(self, flag, message)
    if not flag then
        if type(message) == "number" then
            return; 
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
            return;
        end;        
    end;
    local data = json.analyzeJsonNode(message.data);
    UserInfo.getInstance():setTicketData(data)
    self:updateView(AssetsScene.s_cmds.updata_ticket_num,data);
end

function AssetsController:onUserExchangeHistory(flag, message)
    self:updateView(AssetsScene.s_cmds.onLoadExchangeHistory,flag, message);
end
-------------------- config --------------------------------------------------
AssetsController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.getUserTicket]     = AssetsController.onGetTicketResponse;
    [HttpModule.s_cmds.UserExchangeHistory] = AssetsController.onUserExchangeHistory;
};


AssetsController.s_nativeEventFuncMap = {
};
AssetsController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	AssetsController.s_nativeEventFuncMap or {});

AssetsController.s_socketCmdFuncMap = {
};
-- 合并父类 方法
AssetsController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	AssetsController.s_httpRequestsCallBackFuncMap or {});

AssetsController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	AssetsController.s_socketCmdFuncMap or {});

------------------------------------- 命令响应函数配置 ------------------------
AssetsController.s_cmdConfig = 
{
    [AssetsController.s_cmds.onBack]                   = AssetsController.onBack;
}