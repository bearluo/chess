
require("config/path_config");

require(BASE_PATH.."chessController");
require(DATA_PATH .. "consoleData")
ConsoleController = class(ChessController);

ConsoleController.s_cmds = 
{	
    back_action    = 1;
    reset_progress = 2;
    add_coin       = 3;
    entryRoom      = 4;
    syn_console    = 5;
    get_progress   = 6;
    dapu_action    = 7;
    check_console_config_version = 8;
};

ConsoleController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end

ConsoleController.resume = function(self)
    ChessController.resume(self);
    StatisticsManager.getInstance():onNewUserCountToPHP(StatisticsManager.NEW_USER_COUNT_OFFLINE_GAME,UserInfo.getInstance():getIsFirstLogin())
end

ConsoleController.pause = function(self)
    ChessController.pause(self);
end;

ConsoleController.dtor = function(self)
end;

--------------------------------function------------------------------------
ConsoleController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end;

ConsoleController.onAddCoin = function(self)
    StateMachine.getInstance():pushState(States.Mall,StateMachine.STYPE_CUSTOM_WAIT);
end;

ConsoleController.onDapuAction = function(self)
    RoomProxy.getInstance():gotoDapuRoom();
end;

ConsoleController.onEntryRoom = function(self, index)
    local config = ConsoleData.getInstance():getConfigByLevel(index)
    if not config then
        ChessToastManager.getInstance():showSingle("单机配置缺失,稍后再试")
        local params = {}
        params.cfg_version = 0
        self:sendHttpMsg(HttpModule.s_cmds.UserGetSingleProgressCfg)
        return 
    end
    UserInfo.getInstance():setPlayingLevel(index)
    ConsoleData.getInstance():setWillPlayLevel(index)
    RoomProxy.getInstance():gotoConsoleRoom();
end


ConsoleController.onSynConsole = function(self, data)
    local post_data = {};
    post_data.progress = {}
    post_data.progress["1"] = data or 1;   
    self:sendHttpMsg(HttpModule.s_cmds.uploadConsoleProgress,post_data);

end;

ConsoleController.onGetProgress = function(self)
    self:sendHttpMsg(HttpModule.s_cmds.getConsoleProgress);
end;



ConsoleController.onSynConsoleProgressCallBack = function(self, flag, message)
    if not flag then
        return;
    end;

	if not HttpModule.explainPHPFlag(message) then
		return;
	end  

end;

ConsoleController.onGetConsoleProgressCallBack = function(self, flag, message)
    if flag then
        local status = tonumber(message.flag:get_value())
        if status == 10000 then
            local msg = json.analyzeJsonNode(message)
            ConsoleData.getInstance():syncPhpOldData(msg.data)     
        end
    end
    self:updateView(ConsoleScene.s_cmds.update_progress)  
end

function ConsoleController:checkConsoleConfigVersion()
    local params = {}
    params.cfg_version = ConsoleData.getInstance():getConfigVersion()
    self:sendHttpMsg(HttpModule.s_cmds.UserGetSingleProgressCfg);
end

ConsoleController.onUserGetSingleProgressCfgCallBack = function(self, flag, message)
    if flag then
        local status = tonumber(message.flag:get_value())
        if status == 10000 then
            local msg = json.analyzeJsonNode(message)
            local version = message.cfg_version:get_value()
            local gunStatus = message.gunStatus:get_value()
            ConsoleData.getInstance():setFreeGunStatus(gunStatus)
            ConsoleData.getInstance():updateConfig(version,msg.data)
            self:updateView(ConsoleScene.s_cmds.update_console_config)
        end
    end
    -- 配置更新后 同步单机进度
    self:onGetProgress()
end

function ConsoleController.onUserBuyLevelCallBack(self, flag, message)
    if HttpModule.explainPHPMessage(flag, message,"购买失败") then return end
    local level = message.data.level:get_value()
    if level > 0 then
        self:onEntryRoom(level)
    else
        ChessToastManager.getInstance():showSingle("扣钱失败")
    end
end
--------------------------------config--------------------------------------

ConsoleController.s_cmdConfig = 
{
	[ConsoleController.s_cmds.back_action]		= ConsoleController.onBack;
    [ConsoleController.s_cmds.reset_progress]	= ConsoleController.onResetProgress;
    [ConsoleController.s_cmds.add_coin]		    = ConsoleController.onAddCoin;
    [ConsoleController.s_cmds.entryRoom]		= ConsoleController.onEntryRoom;
    [ConsoleController.s_cmds.syn_console]		= ConsoleController.onSynConsole;
    [ConsoleController.s_cmds.get_progress]		= ConsoleController.onGetProgress;
    [ConsoleController.s_cmds.dapu_action]		= ConsoleController.onDapuAction;
    [ConsoleController.s_cmds.check_console_config_version]		= ConsoleController.checkConsoleConfigVersion;
}

ConsoleController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.uploadConsoleProgress]         = ConsoleController.onSynConsoleProgressCallBack;
    [HttpModule.s_cmds.getConsoleProgress]            = ConsoleController.onGetConsoleProgressCallBack;
    [HttpModule.s_cmds.UserGetSingleProgressCfg]      = ConsoleController.onUserGetSingleProgressCfgCallBack;
    [HttpModule.s_cmds.UserBuyLevel]                  = ConsoleController.onUserBuyLevelCallBack;
    
};
--ConsoleController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
--	ConsoleController.s_httpRequestsCallBackFuncMap or {});