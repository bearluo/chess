
require("config/path_config");

require(BASE_PATH.."chessController");

ConsoleController = class(ChessController);

ConsoleController.s_cmds = 
{	
    back_action    = 1;
    reset_progress = 2;
    add_coin       = 3;
    entryRoom      = 4;
    syn_console    = 5;
    get_progress   = 6;
};

ConsoleController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end

ConsoleController.resume = function(self)
    ChessController.resume(self);

end;

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



ConsoleController.onEntryRoom = function(self, index)
    UserInfo.getInstance():setPlayingLevel(index)
    StateMachine.getInstance():pushState(States.ConsoleRoom,StateMachine.STYPE_CUSTOM_WAIT);

end;


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
    if not flag then
        self:updateView(ConsoleScene.s_cmds.syn_progress, 2);        
    else
        if not HttpModule.explainPHPFlag(message) then
		    return;
	    end  
        local progress = message.data.progress["1"]:get_value();
        local zhanji = {};
        if message.data.combat_gains:get_value() then 
            for index = 1 , COSOLE_MODEL_GATE_NUM do 
                zhanji[index] = {};
                local item = message.data.combat_gains[index ..""];
                zhanji[index].wintimes = ((not item.wintimes and 0) or item.wintimes:get_value());
                zhanji[index].losetimes = ((not item.losetimes and 0) or item.losetimes:get_value());
            end;
            GameCacheData.getInstance():saveString(GameCacheData.CONSOLE_ZHANJI..UserInfo.getInstance():getUid(),json.encode(zhanji));
        end;
        self:updateView(ConsoleScene.s_cmds.syn_progress, progress,zhanji);       
    end;
end;




--------------------------------config--------------------------------------

ConsoleController.s_cmdConfig = 
{
	[ConsoleController.s_cmds.back_action]		= ConsoleController.onBack;
    [ConsoleController.s_cmds.reset_progress]	= ConsoleController.onResetProgress;
    [ConsoleController.s_cmds.add_coin]		    = ConsoleController.onAddCoin;
    [ConsoleController.s_cmds.entryRoom]		= ConsoleController.onEntryRoom;
    [ConsoleController.s_cmds.syn_console]		= ConsoleController.onSynConsole;
    [ConsoleController.s_cmds.get_progress]		= ConsoleController.onGetProgress;


}

ConsoleController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.uploadConsoleProgress]         = ConsoleController.onSynConsoleProgressCallBack;
    [HttpModule.s_cmds.getConsoleProgress]            = ConsoleController.onGetConsoleProgressCallBack;
};
--ConsoleController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
--	ConsoleController.s_httpRequestsCallBackFuncMap or {});