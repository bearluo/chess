--region onlineRoomModule.lua
--Date
--此文件由[BabeLua]插件自动生成
--[[
        普通联网游戏模块
     模块结构分：初始化界面和数据(onLineRoomInit)、
--]]
--require(MODEL_PATH.."online/onlineRoom/onlineRoomSceneNew");
OnlineRoomModule = class(Node);

OnlineRoomModule.s_cmds = 
{
    matchSuccess        = 101;
    match_room_success  = 102;
    match_room_fail     = 103;
}

-------------------------------private function----------------------------
OnlineRoomSceneNew.onLineRoomDtor = function(self)
    delete(self.m_match_dialog);
    delete(self.m_room_select_player_dialog);
end

OnlineRoomSceneNew.onLineRoomInitView = function(self)
    
end

OnlineRoomSceneNew.onLineRoomInitGame = function(self)
    self.m_multiple_img_bg:setVisible(true);--倍数


--    delete(self.m_room_select_player_dialog);
--    self.m_room_select_player_dialog = new(SelectPlayerDialog,self);
--    self.m_room_select_player_dialog:show();
    self:downComeIn(UserInfo.getInstance());
    if UserInfo.getInstance():getRelogin() then
        self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_login); 
	end
    self:onBaseRoomInitGame();
    --初始化时弹出选择玩家弹窗
    if not UserInfo.getInstance():getRelogin() then
        self:matchRoom();
    end
end

OnlineRoomSceneNew.onLineRoomResetGame = function(self)
	self.m_chest_btn:setVisible(false);
	self.m_multiple_img_bg:setVisible(false);
	self.m_down_name:setVisible(false);
	self.m_up_name:setVisible(false);
    self.m_net_state_view:setVisible(false);
	self.m_net_state_view_bg:setVisible(false);
    self:showNetSinalIcon(false);
end

OnlineRoomSceneNew.onLineRoomDismissDialog = function(self)
    if self.m_match_dialog and self.m_match_dialog:isShowing() then
		self.m_match_dialog:dismiss();
	end
    if self.m_room_select_player_dialog and self.m_room_select_player_dialog:isShowing() then
		self.m_room_select_player_dialog:dismiss(false);
	end
end

OnlineRoomSceneNew.onLineBack = function(self)
	local message = "亲，中途离开则会输掉棋局哦！"
	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end
    if self.m_downUser and not self.m_game_start then
        message = "您确定离开吗？"
        self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE,"退出","取消");
        self.m_chioce_dialog:setPositiveListener(self,self.exitRoom);
    elseif self.m_downUser then
        self.m_start_time = self.m_start_time or os.time();  -- 防止 self.m_start_time 为空情况
        local time = os.time();
        if self.m_roominfo and self.m_roominfo.give_up_time and time - self.m_start_time >= 0 and time - self.m_start_time < self.m_roominfo.give_up_time then
            ChessToastManager.getInstance():showSingle(string.format("%d 秒后才能投降",math.ceil(self.m_roominfo.give_up_time - time + self.m_start_time)));
            return ;
        end
        self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE,"认输退出","取消");
        self.m_chioce_dialog:setPositiveListener(self,self.surrender_sure);
    else
        self.m_chioce_dialog:setPositiveListener(self,self.exitRoom);
    end
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:setNegativeListener(nil,nil);
	self.m_chioce_dialog:show();
end

-- 对方退出房间后弹出确认重新匹配对话框
OnlineRoomSceneNew.showRematchComfirmDialog = function(self)
    if self.m_match_dialog and self.m_match_dialog:isShowing() then
        self.m_match_dialog:setVisible(false);
    end
    if self.m_account_dialog and self.m_account_dialog:isShowing() then
        return;
    end
    local message = "对方退出房间，请重新匹配对手！"
    if not self.m_rematch_dialog then
		self.m_rematch_dialog = new(ChioceDialog);
	end
    self.m_rematch_dialog:setMode(ChioceDialog.MODE_SURE,"确定","退出房间");
    self.m_rematch_dialog:setPositiveListener(self,self.changeChessRoom);
    self.m_rematch_dialog:setMessage(message);
	self.m_rematch_dialog:setNegativeListener(self,self.exitRoom);
	self.m_rematch_dialog:show();
end

OnlineRoomSceneNew.changeChessRoom = function(self)
    self.changeRoom = true;
    UserInfo.getInstance():setChallenger(nil);
	OnlineConfig.deleteTimer(self); 
    self.m_board_menu_dialog:dismiss();
    self.m_connectCount = 0;
	UserInfo.getInstance():setRelogin(false) 

	local gametype = UserInfo.getInstance():getGameType();
    if self.m_login_succ then
        self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_logout);
--        self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_offline);
    else
        self:matchRoom();
    end
--    self:clearChangeInfo();
--    self:reMatch();
end

OnlineRoomSceneNew.showSelectPlayerDialog = function(self)
    if self.m_room_select_player_dialog and not self.m_room_select_player_dialog:isShowing() then
        self.m_room_select_player_dialog:show();
        self.m_down_user_ready_img:setVisible(false);
        self.m_down_user_start_btn:setVisible(false);
        self.m_canSetTimeFlag = nil;
    end
end;

OnlineRoomSceneNew.hideSelectPlayerDialog = function(self)
    if self.m_room_select_player_dialog and self.m_room_select_player_dialog:isShowing() then
        self.m_room_select_player_dialog:dismiss(false);
    end;
    if self.m_match_dialog and self.m_match_dialog:isShowing() then
        self.m_match_dialog:dismiss(false);
    end;

end;

--登陆房间成功
OnlineRoomSceneNew.onLineRoomUserLoginSucc = function(self, data)
    self.m_login_succ = true;
    if data.user then
        self:upComeIn(data.user);
    end;
    self:downComeIn(UserInfo.getInstance());
end;

--匹配对手
OnlineRoomSceneNew.matchRoom = function(self,isRematch)
	
    if not isRematch then
        self.m_matchIng = true;
	    if not self.m_match_dialog then
		    self.m_match_dialog = new(MatchDialog);
	    end
	    self:showMoneyRent();

	    self.m_match_dialog:show(self,UserInfo.getInstance():getMatchTime());
    end
    local data = {};
    local roomType = UserInfo.getInstance():getMoneyType();
    if 1 == roomType then
        data.roomType = UserInfo.getInstance():getRoomConfigById(1).level;
    elseif 2 == roomType then
        data.roomType = UserInfo.getInstance():getRoomConfigById(2).level;
    elseif 3 == roomType then
        data.roomType = UserInfo.getInstance():getRoomConfigById(3).level;
    else
        return ;
    end;
    data.playerLevel = self.m_upPlayer_level;
    self:requestCtrlCmd(OnlineRoomController.s_cmds.hall_game_info, data); 
end

--OnlineRoomSceneNew.reMatch = function(self)
--    if self.m_match_dialog then
--        self.m_match_dialog:setVisible(true);
--        self.m_match_dialog:rematch();
--    end
----    self:matchRoom(true);
--end

--取消匹配对手
OnlineRoomSceneNew.cancelMatch = function(self)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.hall_cancel_match,UserInfo.getInstance():getMoneyType()); 
end;

OnlineRoomSceneNew.onLineRoomReady = function(self)
    if self.m_match_dialog then
        self.m_match_dialog:dismiss();
    end
    self.m_upuser_leave = false;
    self:requestCtrlCmd(OnlineRoomController.s_cmds.send_ready_msg);
end

OnlineRoomSceneNew.onMatchSuccess = function(self,data)
--  if self.m_match_dialog then
--	    self.m_match_dialog:dismiss();
--	end
    if self.m_match_dialog then
        self.m_matchIng = false;
	    self.m_match_dialog:onMatchSuc(data);
	end
--    self.m_down_user_start_btn:setVisible(false);
end

OnlineRoomSceneNew.onMatchRoomFail = function(self)
	print_string("匹配失败");
--	self.m_down_user_start_btn:setVisible(true);

	local message = "大侠，对手已闻风而逃，请重新匹配。"
	if self.m_match_dialog then
		self.m_match_dialog:dismiss();
	end

	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end

	self.m_chioce_dialog:setMode(ChioceDialog.MODE_OK);
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:setPositiveListener(self,self.changeChessRoom);
	self.m_chioce_dialog:show();
end

--更换等级
OnlineRoomSceneNew.changeRoomType = function(self)
	self.m_need_change_room_type = true;
	self.m_account_dialog:dismiss();
	self:stopTimeout();

	if self.m_gametype <= GAME_TYPE_TWENTY and self.m_gametype >= GAME_TYPE_FREE then

		if self.m_downUser and self.m_downUser:getStatus() >= STATUS_PLAYER_LOGIN then
            self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_leave);
		end
	end
end

------------------------------------config--------------------------
--不同房间类型不同的处理函数
OnlineRoomModule.s_privateFunc = {
    initGame        = OnlineRoomSceneNew.onLineRoomInitGame;
    back_action          = OnlineRoomSceneNew.onLineBack;
    ready_action    = OnlineRoomSceneNew.onLineRoomReady;
}

OnlineRoomModule.s_cmdConfig =
{
    [OnlineRoomModule.s_cmds.matchSuccess]           = OnlineRoomSceneNew.onMatchSuccess;
    [OnlineRoomModule.s_cmds.match_room_fail]        = OnlineRoomSceneNew.onMatchRoomFail;
}

OnlineRoomSceneNew.s_cmds = CombineTables(OnlineRoomSceneNew.s_cmds,
	OnlineRoomModule.s_cmds or {});

OnlineRoomSceneNew.s_cmdConfig = CombineTables(OnlineRoomSceneNew.s_cmdConfig,
	OnlineRoomModule.s_cmdConfig or {});

--endregion
