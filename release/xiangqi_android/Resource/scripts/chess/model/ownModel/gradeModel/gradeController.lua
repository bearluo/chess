--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23

require(BASE_PATH.."chessController")

GradeController = class(ChessController);

GradeController.s_cmds = 
{
    onBack = 1;
};


GradeController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end

GradeController.dtor = function(self)
end

GradeController.resume = function(self)
	ChessController.resume(self);
	Log.i("GradeController.resume");
end

GradeController.pause = function(self)
	ChessController.pause(self);
	Log.i("GradeController.pause");

end

-------------------- func ----------------------------------

GradeController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end



-------------------- config --------------------------------------------------
GradeController.s_httpRequestsCallBackFuncMap  = {
};


GradeController.s_nativeEventFuncMap = {
};
GradeController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	GradeController.s_nativeEventFuncMap or {});

GradeController.s_socketCmdFuncMap = {
};
-- 合并父类 方法
GradeController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	GradeController.s_httpRequestsCallBackFuncMap or {});

GradeController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	GradeController.s_socketCmdFuncMap or {});

------------------------------------- 命令响应函数配置 ------------------------
GradeController.s_cmdConfig = 
{
    [GradeController.s_cmds.onBack]                   = GradeController.onBack;
}