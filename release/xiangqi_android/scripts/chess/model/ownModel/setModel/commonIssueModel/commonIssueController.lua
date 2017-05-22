require(BASE_PATH.."chessController")

CommonIssueController = class(ChessController);

CommonIssueController.s_cmds = 
{
    onBack = 1;
};


CommonIssueController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end

CommonIssueController.dtor = function(self)
end

CommonIssueController.resume = function(self)
	ChessController.resume(self);
	Log.i("CommonIssueController.resume");
end

CommonIssueController.pause = function(self)
	ChessController.pause(self);
	Log.i("CommonIssueController.pause");

end

-------------------- func ----------------------------------

CommonIssueController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end


-------------------- config --------------------------------------------------
CommonIssueController.s_httpRequestsCallBackFuncMap  = {
};


CommonIssueController.s_nativeEventFuncMap = {
    
};
CommonIssueController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	CommonIssueController.s_nativeEventFuncMap or {});

CommonIssueController.s_socketCmdFuncMap = {
};
-- 合并父类 方法
CommonIssueController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	CommonIssueController.s_httpRequestsCallBackFuncMap or {});

CommonIssueController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	CommonIssueController.s_socketCmdFuncMap or {});

------------------------------------- 命令响应函数配置 ------------------------
CommonIssueController.s_cmdConfig = 
{
    [CommonIssueController.s_cmds.onBack]                   = CommonIssueController.onBack;
}
