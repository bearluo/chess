--region ticketModuleController.lua
--Date 2016.11.12
--
--endregion


require("config/path_config");

require(BASE_PATH.."chessController");

TicketModuleController = class(ChessController)

TicketModuleController.s_cmds = {
    onBack = 1
}

function TicketModuleController.ctor(self, state, viewClass, viewConfig)
    self.m_state = state;
end

function TicketModuleController.dtor(self)

end

function TicketModuleController.resume(self)
    ChessController.resume(self);
    self:getUserTicket()
end

function TicketModuleController.pause(self)
    ChessController.pause(self);
end

function TicketModuleController.onBack(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end

function TicketModuleController.getUserTicket(self)
    self:sendHttpMsg(HttpModule.s_cmds.getUserTicket)
end

function TicketModuleController.onGetTicketResponse(self, flag, message)
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
    self:updateView(TicketModuleScene.s_cmds.updata_ticket_list,data);
end

TicketModuleController.s_cmdConfig = 
{
    [TicketModuleController.s_cmds.onBack] = TicketModuleController.onBack;
}

TicketModuleController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.getUserTicket]     = TicketModuleController.onGetTicketResponse;
};


TicketModuleController.s_nativeEventFuncMap = {
};
TicketModuleController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	TicketModuleController.s_nativeEventFuncMap or {});

TicketModuleController.s_socketCmdFuncMap = {
};
-- 合并父类 方法
TicketModuleController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	TicketModuleController.s_httpRequestsCallBackFuncMap or {});

TicketModuleController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	TicketModuleController.s_socketCmdFuncMap or {});

--function TicketModuleController.ctor(self)

--end

--function TicketModuleController.ctor(self)

--end