require("config/path_config");

require(BASE_PATH.."chessController");

CreateEndgateController = class(ChessController);

CreateEndgateController.s_cmds = 
{	
    onBack = 1;
    tip_action = 2;
    undoMove = 3;
    release = 4;
};

CreateEndgateController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
    self.m_load_socket_dialog = HttpLoadingDialogFactory.createLoadingDialog(HttpLoadingDialog.s_type.Simple);
    self.m_load_socket_dialog:setNeedBackEvent(false);
end


CreateEndgateController.resume = function(self)
	ChessController.resume(self);
end


CreateEndgateController.exit_action = function(self)
	sys_exit();
end

CreateEndgateController.pause = function(self)
	ChessController.pause(self);
	Log.i("CreateEndgateController.pause");
end

CreateEndgateController.dtor = function(self)
    delete(self.m_load_socket_dialog);
    self:stopTimeout();
    delete(self.m_pay_dialog);
    ShowMessageAnim.deleteAll();
    ChatMessageAnim.deleteAll();
    delete(self.m_quit_chioce_dialog);
end

--------------------------- father func ----------------------
CreateEndgateController.updateUserInfoView = function(self)
    self:updateView(CreateEndgateScene.s_cmds.updateView);
end


-------------------------------- function --------------------------
CreateEndgateController.onBack = function(self)
    if not self.m_quit_chioce_dialog then
        self.m_quit_chioce_dialog = new(ChioceDialog)
        self.m_quit_chioce_dialog:setMode(ChioceDialog.MODE_COMMON,"取消","继续");
        self.m_quit_chioce_dialog:setMessage("返回将不会保存本残局,是否继续?");
        self.m_quit_chioce_dialog:setNegativeListener(self,function()
            StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
        end);
        self.m_quit_chioce_dialog:setPositiveListener(nil,nil);
    end 

    if self.m_view and #self.m_view.m_history_chesses > 1 then
        self.m_quit_chioce_dialog:show();
    else
        StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
    end
end


CreateEndgateController.engine2Gui = function(self, flag, data)
    Log.i("Engine2Gui:get_value()--->"..data.Engine2Gui:get_value());
    self:updateView(CreateEndgateScene.s_cmds.engine2Gui,data.Engine2Gui:get_value());

end;


CreateEndgateController.onBoardAiMove = function(self)
    self:updateView(CreateEndgateScene.s_cmds.board_ai_move);
    

end;


CreateEndgateController.onBoardAiUnChangeMove = function(self)
--    ShowMessageAnim.play(self.m_view,"和棋");
    local message =  "和棋"; 
    ChessToastManager.getInstance():showSingle(message); 

end;


CreateEndgateController.onBoardUnlegalMove = function(self, code)
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


CreateEndgateController.tip_action = function(self)
    if self:isLogined() and not self.user_prop_func then
        self.m_load_socket_dialog:show();
        self.user_prop_func = CreateEndgateController.use_tip;
        self:startTimeout();
        self:sendSocketMsg(PROP_CMD_QUERY_USERDATA);
    end
end

CreateEndgateController.startTimeout = function(self)
	self:stopTimeout();
	self.m_timeoutAnim = new(AnimInt,kAnimNormal,0,1,10000,-1);
	self.m_timeoutAnim:setDebugName("LoadingDialog.startTimeout.m_timeoutAnim");
	
	self.m_timeoutAnim:setEvent(self,self.timeoutRun);
end

CreateEndgateController.timeoutRun = function(self)
    self.user_prop_func = nil;
    self.m_load_socket_dialog:dismiss();
    ChessToastManager.getInstance():showSingle("请求超时!");
end

CreateEndgateController.stopTimeout = function(self)
	if self.m_timeoutAnim then
		delete(self.m_timeoutAnim);
		self.m_timeoutAnim = nil;
	end
end

CreateEndgateController.onPropCmdQueryUserData = function(self,info)
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

CreateEndgateController.use_tip = function(self)
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
    self:updateView(CreateEndgateScene.s_cmds.use_tip);

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

CreateEndgateController.undoMove = function(self)
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
        self.user_prop_func = CreateEndgateController.use_undoMove;
        self:sendSocketMsg(PROP_CMD_QUERY_USERDATA);
    end
end

CreateEndgateController.use_undoMove = function(self)
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
    self:updateView(CreateEndgateScene.s_cmds.use_undoMove);
end

CreateEndgateController.onPropCmdUpdateUserData = function(self,info)
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



CreateEndgateController.onCustomBoardChessMove = function(self, mv)
   


end;

CreateEndgateController.onCustomEngateTipsEnable = function(self)
    self:updateView(CreateEndgateScene.s_cmds.tip_enable);
end

CreateEndgateController.release = function(self,fen,title)
    local params = {};
    params.booth_fen = fen;
    params.booth_title = title;
    params.tid = UserInfo.getInstance():getUid();
    HttpModule.getInstance():execute(HttpModule.s_cmds.WulinBoothCreate,params,"上传中...");
end

CreateEndgateController.onReleaseResponse = function(self,success,message)
    if not success then 
        if type(message) == 'table' and message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value() or "上传失败");
        else
            ChessToastManager.getInstance():showSingle("上传失败");
        end
        return;
    end
    ChessToastManager.getInstance():showSingle("发布成功");
end
-------------------------------- http event ------------------------



-------------------------------- config ----------------------------

CreateEndgateController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.WulinBoothCreate]    = CreateEndgateController.onReleaseResponse;
};

CreateEndgateController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	CreateEndgateController.s_httpRequestsCallBackFuncMap or {});


--本地事件 包括lua dispatch call事件
CreateEndgateController.s_nativeEventFuncMap = {
    [ENGINE_GUI]                            = CreateEndgateController.engine2Gui;
    [Board.UNLEGALMOVE]                     = CreateEndgateController.onBoardUnlegalMove;
    [Board.AIUNLEGALMOVE]                   = CreateEndgateController.onBoardAiUnlegalMove;
    [Board.AIMOVE]                          = CreateEndgateController.onBoardAiMove;
    [Board.AI_UNCHANGE_MOVE]                = CreateEndgateController.onBoardAiUnChangeMove;
    [CUSTOM_BOARD_CHESS_MOVE]               = CreateEndgateController.onCustomBoardChessMove;
    [CUSTOMENGATE_TIPS_ENABLE]              = CreateEndgateController.onCustomEngateTipsEnable;

};


CreateEndgateController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	CreateEndgateController.s_nativeEventFuncMap or {});



CreateEndgateController.s_socketCmdFuncMap = {
	[PROP_CMD_UPDATE_USERDATA]  = CreateEndgateController.onPropCmdUpdateUserData;
    [PROP_CMD_QUERY_USERDATA]   = CreateEndgateController.onPropCmdQueryUserData;--查询道具
}

CreateEndgateController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	CreateEndgateController.s_socketCmdFuncMap or {});


------------------------------------- 命令响应函数配置 ------------------------
CreateEndgateController.s_cmdConfig = 
{
    [CreateEndgateController.s_cmds.onBack] = CreateEndgateController.onBack;
    [CreateEndgateController.s_cmds.tip_action] = CreateEndgateController.tip_action;
    [CreateEndgateController.s_cmds.undoMove] = CreateEndgateController.undoMove;
    [CreateEndgateController.s_cmds.release] = CreateEndgateController.release;
}