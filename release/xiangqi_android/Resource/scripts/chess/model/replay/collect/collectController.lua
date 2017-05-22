
require("config/path_config");

require(BASE_PATH.."chessController");
CollectController = class(ChessController);

CollectController.s_cmds = 
{	
    back_action    = 1;
};

CollectController.ctor = function(self, state, viewClass, viewConfig)

end

CollectController.resume = function(self)
    ChessController.resume(self);
end;

CollectController.pause = function(self)
    ChessController.pause(self);
end;

CollectController.dtor = function(self)

end;




CollectController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end;


--------------------------------function------------------------------------

CollectController.onBackAction = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end;

--------------------------------http----------------------------------------

--------------------------------config--------------------------------------

CollectController.s_cmdConfig = 
{
	[CollectController.s_cmds.back_action]		            = CollectController.onBackAction;
    
}
CollectController.s_socketCmdFuncMap = {

};

CollectController.s_httpRequestsCallBackFuncMap  = {

};

CollectController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	CollectController.s_httpRequestsCallBackFuncMap or {});

CollectController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	CollectController.s_socketCmdFuncMap or {});