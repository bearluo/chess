require("config/path_config");

require(BASE_PATH.."chessController");

CustomBoardController = class(ChessController);

CustomBoardController.s_cmds = 
{	
    onBack = 1;
    tip_action = 2;
    undoMove = 3;
};

CustomBoardController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
    self.m_load_socket_dialog = HttpLoadingDialogFactory.createLoadingDialog(HttpLoadingDialog.s_type.Simple);
    self.m_load_socket_dialog:setNeedBackEvent(false);
end


CustomBoardController.resume = function(self)
	ChessController.resume(self);
end


CustomBoardController.exit_action = function(self)
	sys_exit();
end

CustomBoardController.pause = function(self)
	ChessController.pause(self);
	Log.i("CustomBoardController.pause");
end

CustomBoardController.dtor = function(self)
    delete(self.m_load_socket_dialog);
    self:stopTimeout();
    delete(self.m_pay_dialog);
    ShowMessageAnim.deleteAll();
    ChatMessageAnim.deleteAll();
end

--------------------------- father func ----------------------
CustomBoardController.updateUserInfoView = function(self)
    self:updateView(CustomBoardScene.s_cmds.updateView);
end


-------------------------------- function --------------------------
CustomBoardController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end


CustomBoardController.engine2Gui = function(self, flag, data)
    Log.i("Engine2Gui:get_value()--->"..data.Engine2Gui:get_value());
    self:updateView(CustomBoardScene.s_cmds.engine2Gui,data.Engine2Gui:get_value());

end;


CustomBoardController.onBoardAiMove = function(self)
    self:updateView(CustomBoardScene.s_cmds.board_ai_move);
    

end;


CustomBoardController.onBoardAiUnChangeMove = function(self)
--    ShowMessageAnim.play(self.m_view,"和棋");
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


CustomBoardController.tip_action = function(self)
    if self:isLogined() and not self.user_prop_func then
        self.m_load_socket_dialog:show();
        self.user_prop_func = CustomBoardController.use_tip;
        self:startTimeout();
        self:sendSocketMsg(PROP_CMD_QUERY_USERDATA);
    end
end

CustomBoardController.startTimeout = function(self)
	self:stopTimeout();
	self.m_timeoutAnim = new(AnimInt,kAnimNormal,0,1,10000,-1);
	self.m_timeoutAnim:setDebugName("LoadingDialog.startTimeout.m_timeoutAnim");
	
	self.m_timeoutAnim:setEvent(self,self.timeoutRun);
end

CustomBoardController.timeoutRun = function(self)
    self.user_prop_func = nil;
    self.m_load_socket_dialog:dismiss();
    ChessToastManager.getInstance():showSingle("请求超时!");
end

CustomBoardController.stopTimeout = function(self)
	if self.m_timeoutAnim then
		delete(self.m_timeoutAnim);
		self.m_timeoutAnim = nil;
	end
end

CustomBoardController.onPropCmdQueryUserData = function(self,info)
    self:stopTimeout();
    self.super.onPropCmdQueryUserData(self,info);
    if info.ret == 0 then
        if self.user_prop_func then
            self.user_prop_func(self);
            self.user_prop_func = nil;
        end
    end
    self.m_load_socket_dialog:dismiss();
end

CustomBoardController.use_tip = function(self)
	local tips_num = UserInfo.getInstance():getTipsNum();
	if tips_num < 1 then
		self.m_payInterface = PayUtil.getPayInstance(PayUtil.s_payType.Exchange);
        delete(self.m_pay_dialog);
		self.m_pay_dialog = self.m_payInterface:buy(nil,ENDING_ROOM_TIPS);	
        if ChessToastManager.getInstance():isEmpty()  then
            ChessToastManager.getInstance():show("提示不足！");
        end
		return false;
	end

    --先使用道具
    self:updateView(CustomBoardScene.s_cmds.use_tip);

    self.m_used_tip_num = (self.m_used_tip_num or 0) + 1;
        
    local sendData = {};
    local item = {};
    item.op = 2; -- =1相加，=2相减，=3覆盖
    item.op_id = 12; -- 11 => '单机中使用道具', 12 => '残局中使用道具',
    item.num = 1;--修改数量
    item.prop_id = kTipsNum; --道具id
    table.insert(sendData,item);
    self:sendSocketMsg(PROP_CMD_UPDATE_USERDATA,sendData);
end

CustomBoardController.undoMove = function(self)
	local undo_num = UserInfo.getInstance():getUndoNum();
	if undo_num < 1 then
		 local message = "你的悔棋次数不足请购买！！！";
		-- ShowMessageAnim.play(self.m_root_view,message);
		self.m_payInterface = PayUtil.getPayInstance(PayUtil.s_payType.Exchange);
		self.m_pay_dialog = self.m_payInterface:buy(nil,ENDING_ROOM_UNDO);
        if ChessToastManager.getInstance():isEmpty()  then
            ChessToastManager.getInstance():show(message);
        end
		return ;
	end
    if self:isLogined() and not self.user_prop_func then
        self.m_load_socket_dialog:show();
        self:startTimeout();
        self.user_prop_func = CustomBoardController.use_undoMove;
        self:sendSocketMsg(PROP_CMD_QUERY_USERDATA);
    end
end

CustomBoardController.use_undoMove = function(self)
	local sendData = {};
    local item = {};
    item.op = 2; -- =1相加，=2相减，=3覆盖
    item.op_id = 12; -- 11 => '单机中使用道具', 12 => '残局中使用道具',
    item.num = 1;--修改数量
    item.prop_id = kUndoNum; --道具id
    table.insert(sendData,item);
    self:sendSocketMsg(PROP_CMD_UPDATE_USERDATA,sendData);
	local undo_num = UserInfo.getInstance():getUndoNum();
    --先使用
    --成功悔棋次数减一
    self:updateView(CustomBoardScene.s_cmds.use_undoMove);
end

CustomBoardController.onPropCmdUpdateUserData = function(self,info)
    if info.ret == 0 then
        local prop = json.decode(info.data_json);
        if not prop then return end;
        for i,v in pairs(prop) do
            UserInfo.saveProp(i,v);
        end
        self:updateUserInfoView();
    else
       --ChessToastManager.getInstance():showSingle("使用失败,请稍后再试!");
       self:sendSocketMsg(PROP_CMD_QUERY_USERDATA);
    end
end



CustomBoardController.onCustomBoardChessMove = function(self, mv)
   


end;

CustomBoardController.onCustomEngateTipsEnable = function(self)
    self:updateView(CustomBoardScene.s_cmds.tip_enable);
end;

-------------------------------- http event ------------------------



-------------------------------- config ----------------------------

CustomBoardController.s_httpRequestsCallBackFuncMap  = {
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
    [CUSTOMENGATE_TIPS_ENABLE]              = CustomBoardController.onCustomEngateTipsEnable;

};


CustomBoardController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	CustomBoardController.s_nativeEventFuncMap or {});



CustomBoardController.s_socketCmdFuncMap = {
	[PROP_CMD_UPDATE_USERDATA]  = CustomBoardController.onPropCmdUpdateUserData;
    [PROP_CMD_QUERY_USERDATA]   = CustomBoardController.onPropCmdQueryUserData;--查询道具
}

CustomBoardController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	CustomBoardController.s_socketCmdFuncMap or {});


------------------------------------- 命令响应函数配置 ------------------------
CustomBoardController.s_cmdConfig = 
{
    [CustomBoardController.s_cmds.onBack] = CustomBoardController.onBack;
    [CustomBoardController.s_cmds.tip_action] = CustomBoardController.tip_action;
    [CustomBoardController.s_cmds.undoMove] = CustomBoardController.undoMove;
}