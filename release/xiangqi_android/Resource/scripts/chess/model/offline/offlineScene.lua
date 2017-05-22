
require(BASE_PATH.."chessScene");

OfflineScene = class(ChessScene);

OfflineScene.s_controls = 
{
    back_btn = 1;
    helpBtn  = 2;
}

OfflineScene.s_cmds = 
{
    refreshUserInfo = 1;
}

OfflineScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = OfflineScene.s_controls;
    self:initView();
end 

OfflineScene.resume = function(self)
    ChessScene.resume(self);
    self:refreshUserInfo()
end

OfflineScene.pause = function(self)
	ChessScene.pause(self);
    self:removeAnimProp();
end 


OfflineScene.dtor = function(self)
    self:removeAnimProp();
end 

------------------------------anim----------------------------------
OfflineScene.removeAnimProp = function(self)
end

OfflineScene.resumeAnimStart = function(self,lastStateObj,timer,func)
    
end

OfflineScene.pauseAnimStart = function(self,newStateObj,timer)
   
end

------------------------------function------------------------------

OfflineScene.initView = function(self)
    self.m_top_view = self.m_root:getChildByName("top_view")
    self.m_leaf_right = self.m_top_view:getChildByName("leaf_right");
    self.m_leaf_left = self.m_top_view:getChildByName("leaf_left");


    self.m_content_view = self.m_root:getChildByName("content_view")
    self.m_content_view:setVisible(true)
    local w,h = self:getSize()
    local func = function(view,enable,prePath)
        local title = view:getChildByName("content"):getChildByName("icon");
        if title then
            if enable then
                title:setFile( prePath .. 1 .. ".png" )
            else
                title:setFile( prePath .. 2 .. ".png")
            end
        end
    end
    
    self.m_custom_btn = self.m_content_view:getChildByName("custom_btn")
    self.m_custom_btn:setOnTuchProcess(self.m_custom_btn,function(view,enable)
        func(view,enable,"common/decoration/custom_txt_dec_")
    end);
    self.m_console_btn = self.m_content_view:getChildByName("console_btn")
    self.m_console_btn:setOnTuchProcess(self.m_console_btn,function(view,enable)
        func(view,enable,"common/decoration/console_txt_dec_")
    end);
    self.m_two_btn = self.m_content_view:getChildByName("two_btn")
    self.m_two_btn:setOnTuchProcess(self.m_two_btn,function(view,enable)
        func(view,enable,"common/decoration/two_txt_dec_")
    end);
    self.m_endgate_btn = self.m_content_view:getChildByName("endgate_btn")
    self.m_endgate_btn:setOnTuchProcess(self.m_endgate_btn,function(view,enable)
        func(view,enable,"common/decoration/endgate_txt_dec_")
    end);



    local func = function(self)
        StateMachine.getInstance():pushState(States.findModel,StateMachine.STYPE_CUSTOM_WAIT)
    end
    self.m_custom_btn:setOnClick(self,func);

    local func = function(self)
        UserInfo.getInstance():setIsFromHall(true)
        StateMachine.getInstance():pushState(States.Console,StateMachine.STYPE_CUSTOM_WAIT)
    end
    self.m_console_btn:setOnClick(self,func);

    local func = function(self)
        RoomProxy.getInstance():gotoDapuRoom();
    end
    self.m_two_btn:setOnClick(self,func);

    local func = function(self)
        StateMachine.getInstance():pushState(States.EndGate,StateMachine.STYPE_CUSTOM_WAIT)
    end
    self.m_endgate_btn:setOnClick(self,func);

end

OfflineScene.refreshUserInfo = function(self)
    local uid = UserInfo.getInstance():getUid();
	local latest_tid = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_GATE .. uid,17);
	local latest_sort = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_SORT .. uid,0);
	local data = EndgateData.getInstance():getEndgateData();
    local gates = data;
    local gate = nil;
    for i,v in ipairs(gates) do
        if v.tid == latest_tid then
            gate = v
            break
        end
    end
    if gate then
        self.m_endgate_btn:getChildByName("txt_bg"):getChildByName("txt"):setText("解锁至:"..gate.title)
    end
    
    local consoleLevel = ConsoleData.getInstance():getMaxStarOpenLevel()
    local title = User.CONSOLE_TITLE[consoleLevel]
    if title then
        self.m_console_btn:getChildByName("txt_bg"):getChildByName("txt"):setText("解锁至:"..title)
    end
end

OfflineScene.onOnlineBackActionBtnClick = function(self)
    self:requestCtrlCmd(OnlineController.s_cmds.back_action);
end;

OfflineScene.showHelpDialog = function(self)
--    if not self.helpDialog then
--        self.helpDialog = new(CommonHelpDialog)
--        self.helpDialog:setMode(CommonHelpDialog.online_mode)
--    end 
--    self.helpDialog:show()
end


-- 残局
OfflineScene.onHallEndingBtnClick = function(self)
    Log.d("HallScene.onHallEndingBtnClick");
    StatisticsManager.getInstance():onCountToUM(HALL_MODEL_ENDING_BTN);
    self:requestCtrlCmd(HallController.s_cmds.endgateChess);
end

-- 单机
OfflineScene.onHallConsoleBtnClick = function(self)
    Log.d("HallScene.onHallConsoleBtnClick");
    StatisticsManager.getInstance():onCountToUM(HALL_MODEL_CONSOLE_BTN);
    self:requestCtrlCmd(HallController.s_cmds.consoleChess);
end


---------------------------------config-------------------------------
OfflineScene.s_controlConfig = 
{
	[OfflineScene.s_controls.back_btn]               = {"back_btn"};
	[OfflineScene.s_controls.helpBtn]                = {"top_view","help_btn"};
};

--定义控件的触摸响应函数
OfflineScene.s_controlFuncMap =
{
	[OfflineScene.s_controls.back_btn]               = OfflineScene.onOnlineBackActionBtnClick;
    [OfflineScene.s_controls.helpBtn]                = OfflineScene.showHelpDialog;
};

OfflineScene.s_cmdConfig = 
{
    [OfflineScene.s_cmds.refreshUserInfo]               = OfflineScene.refreshUserInfo;
}