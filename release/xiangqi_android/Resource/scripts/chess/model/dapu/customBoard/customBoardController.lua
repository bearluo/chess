require("config/path_config");

require(BASE_PATH.."chessController");

CustomBoardController = class(ChessController);

CustomBoardController.s_cmds = 
{	
    onBack = 1;
};

CustomBoardController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end


CustomBoardController.resume = function(self)
	ChessController.resume(self);
end


CustomBoardController.exit_action = function(self)
	sys_exit();
end

CustomBoardController.pause = function(self)
	ChessController.pause(self);
end

CustomBoardController.dtor = function(self)
    ShowMessageAnim.deleteAll();
    ChatMessageAnim.deleteAll();
end

--------------------------- father func ----------------------
CustomBoardController.updateUserInfoView = function(self)
--    self:updateView(CustomBoardScene.s_cmds.updateView);
end


-------------------------------- function --------------------------
CustomBoardController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end


CustomBoardController.engine2Gui = function(self, flag, data)
    Log.i("Engine2Gui:get_value()--->"..data.Engine2Gui:get_value());
--    self:updateView(CustomBoardScene.s_cmds.engine2Gui,data.Engine2Gui:get_value());

end;


CustomBoardController.onBoardAiMove = function(self)
--    self:updateView(CustomBoardScene.s_cmds.board_ai_move);
end;


CustomBoardController.onBoardAiUnChangeMove = function(self)
    local message =  "和棋"; 
    ChessToastManager.getInstance():showSingle(message); 
end;


CustomBoardController.onBoardUnlegalMove = function(self, code)
    --[[//错误码 -1 走法不合规则 -2 相同方不可互吃 -3 找不到当前棋桌  -4 对手为空 -5 对方尚未走棋，请等待
        //  -6 客户端状态与服务端状态不一致，需要同步   -8 UID 不合法，找不到用户 -10 自己已经不在当前棋桌
        -9 此走法会导致自己被将军 -11 红方长捉黑方  -12 黑方长捉红方

        //0 成功   1红方胜利  2黑方胜利  9将军]]
    local message = nil;
    if code == -9 then
		message = "走法会导致自己被将军,请重新走棋!" 
	elseif code == -11 or code == -12 then
		message = "走法长捉长将，请重新走棋！" 
	else
		message = "走法不合规则，请重新走棋！" 
	end
	ChatMessageAnim.play(self.m_view,3,message);
end;

CustomBoardController.onCustomBoardChessMove = function(self, mv)
   
end;

-------------------------------- http event ------------------------
CustomBoardController.onSaveChessCallBack = function(self, flag, message)
    if not flag then
        if type(message) == "number" then
            return; 
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
            return;
        end;        
    end;
    ChessToastManager.getInstance():showSingle("收藏成功！");
end;

-------------------------------- config ----------------------------
CustomBoardController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.saveMychess]         = CustomBoardController.onSaveChessCallBack;
};

CustomBoardController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	CustomBoardController.s_httpRequestsCallBackFuncMap or {});


--本地事件 包括lua dispatch call事件
CustomBoardController.s_nativeEventFuncMap = {
    [ENGINE_GUI]                            = CustomBoardController.engine2Gui;
    [Board.UNLEGALMOVE]                     = CustomBoardController.onBoardUnlegalMove;
    [Board.AIUNLEGALMOVE]                   = CustomBoardController.onBoardAiUnlegalMove;
    [Board.AIMOVE]                          = CustomBoardController.onBoardAiMove;
    [Board.AI_UNCHANGE_MOVE]                = CustomBoardController.onBoardAiUnChangeMove;
    [CUSTOM_BOARD_CHESS_MOVE]               = CustomBoardController.onCustomBoardChessMove;

};

CustomBoardController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	CustomBoardController.s_nativeEventFuncMap or {});

CustomBoardController.s_socketCmdFuncMap = {
}

CustomBoardController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	CustomBoardController.s_socketCmdFuncMap or {});


------------------------------------- 命令响应函数配置 ------------------------
CustomBoardController.s_cmdConfig = 
{
    [CustomBoardController.s_cmds.onBack] = CustomBoardController.onBack;
}