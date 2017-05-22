--region onlineRoomModule.lua
--Date
--此文件由[BabeLua]插件自动生成
--[[
        普通联网游戏模块
     模块结构分：初始化界面和数据(onLineRoomInit)、
--]]
--require(MODEL_PATH.."online/onlineRoom/onlineRoomSceneNew");
CustomRoomModule = class(Node);

CustomRoomModule.s_cmds = 
{
    enter_customroom_fail  = 401;
    custom_msg_login_room  = 402;
}

-------------------------------初始化----------------------------

OnlineRoomSceneNew.onCustomRoomDtor = function(self)

end

OnlineRoomSceneNew.onCustomRoomInitView = function(self)
    self.m_roomid_text = self.m_root_view:getChildByName("roomid"):getChildByName("roomid_text");    
    self.m_roomid = self.m_root_view:getChildByName("roomid");             --房间ID(View)
    self.m_roomid:setVisible(false);
end

OnlineRoomSceneNew.onCustomRoomInitGame = function(self)
	if self.m_customRoomExit then
        self.m_customRoomExit = false;
        StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
        return;
    end
    self.m_down_user_start_btn:setVisible(true);
    self.m_private_change_player_btn:setVisible(UserInfo.getInstance():isSelfRoom());
    self.m_private_change_player_btn:setPickable(self.m_upUser ~= nil);
    self.m_private_change_player_btn:setGray(self.m_upUser == nil);
--    if self.m_upUser then
--        self.m_private_change_player_btn:setFile({"common/button/change_player_pre.png","common/button/change_player_nor.png"});
--    else
--        self.m_private_change_player_btn:setFile({"common/button/invite_friend_btn_pre.png","common/button/invite_friend_btn_nor.png"});
--    end
    self.m_private_change_player_btn:setOnClick(self,self.onPrivateChangePlayerBtnClick);
	self.m_roomid:setVisible(true);
    self:onBaseRoomInitGame();
    self:downComeIn(UserInfo.getInstance());
    self:start_customroom();
end

OnlineRoomSceneNew.onPrivateChangePlayerBtnClick = function(self)
    if UserInfo.getInstance():getGameType() == GAME_TYPE_CUSTOMROOM then
        if self.m_upUser then
            if tonumber(self.m_upUser:getClient_version()) and tonumber(self.m_upUser:getClient_version()) >= 215 then
--                ChessToastManager.getInstance():showSingle("可以悔棋");
                self:requestCtrlCmd(OnlineRoomController.s_cmds.server_cmd_kick_player);
            else
                ChessToastManager.getInstance():showSingle("对方版本过低不支持踢人功能");
            end
--        else
--            --挑战好友
--            self:onClickChallenge();
        end
    end
end

--[[
    需求去掉了，下面两个方法没有使用
--]]
OnlineRoomSceneNew.onClickChallenge = function(self)
    Log.i("OnlineRoomSceneNew.onClickChallenge");
    if not self.m_custom_challenge_dialog then
        require("dialog/friends_pop_dialog");
        self.m_custom_challenge_dialog = new(FriendPopDialog,self);
    end
    self.m_custom_challenge_dialog:setMode(FriendPopDialog.MODE_FIGHT);
    self.m_custom_challenge_dialog:setPositiveListener(self, self.onPopDialogSureBtnClick);
    self.m_custom_challenge_dialog:setJumpFriendsCallBack(self, self.onFriendPopAddBtnClick);
    self.m_custom_challenge_dialog:show();
end

OnlineRoomSceneNew.onFriendPopAddBtnClick = function(self)
    StateMachine.getInstance():pushState(States.Friends,StateMachine.STYPE_CUSTOM_WAIT);
end

OnlineRoomSceneNew.onCustomRoomResetGame = function(self)
	self.m_up_name:setVisible(false);
    self.m_down_user_start_btn:setVisible(false);
    self.m_net_state_view:setVisible(false);
	self.m_net_state_view_bg:setVisible(false);
    self.m_roomid:setVisible(false);
    self:showNetSinalIcon(false);
end

OnlineRoomSceneNew.onCustomRoomDismissDialog = function(self)
    if self.m_inputPwdDialog and self.m_inputPwdDialog:isShowing() then
		self.m_inputPwdDialog:dismiss();
	end
end

OnlineRoomSceneNew.onCustomRoomClearDialog = function(self)
    if self.m_inputPwdDialog then
        delete(self.m_inputPwdDialog);
        self.m_inputPwdDialog = nil;
    end
end

--登陆房间成功
OnlineRoomSceneNew.onCustomUserLoginSucc = function(self, data)
    self.m_login_succ = true;
    if data.user then
        self:upComeIn(data.user);
    end;
    self:downComeIn(UserInfo.getInstance());
end;

OnlineRoomSceneNew.onCustomRoomReady = function(self)
    if UserInfo.getInstance():getStatus() > STATUS_PLAYER_LOGIN then  --网络游戏
        self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_start);
	else
	  	self.m_roomid_text:setText("房间ID "..UserInfo.getInstance():getCustomRoomID());
	end
end

OnlineRoomSceneNew.start_customroom = function(self)
	print_string("Room.start_customroom ... ");
  	self.m_roomid_text:setText("房间ID "..UserInfo.getInstance():getCustomRoomID());
    self:requestCtrlCmd(OnlineRoomController.s_cmds.start_customroom);
end;

OnlineRoomSceneNew.onCustomBack = function(self)
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

OnlineRoomSceneNew.onShowInputPwdDialog = function(self, isAnother)
	self.m_inputPwdDialog = new(InputPwdDialog,50,260,370,286,self);
	self.m_inputPwdDialog:setPositiveListener(self,self.loginStartCustomRoom);
	self.m_inputPwdDialog:setNegativeListener(self,self.exitRoom)
    self.m_inputPwdDialog:show(isAnother,self.m_root_view);
end;

OnlineRoomSceneNew.onEnterCustomRoomFail = function(self, data)

	if data~=nil then
		if data == 2 then
			self:onShowInputPwdDialog(true);
			return;
		else
	        local message = "登陆失败";
			if data == -3 then
		        message = "你的金币不足以进入房间";
		    elseif data == -5 then
				message = "棋桌已满";
			elseif data == -8 then
		        message = "用户不合法";
		    elseif data == -2 then
		        message = "房间已不存在";
			end
			self:loginFail(message);
		end
	end
end;

OnlineRoomSceneNew.onCustomMsgLoginRoom = function(self, data)
    if not data then

        return 
    end;
    if data.retCode ~= 0 then

        self.Undomovenum = 0;
        self:upComeIn(data.user);
    end;
    self:setGameType(data.gameType);
	self.m_tid = data.tableID;
	self:setStatus(data.tableStatus) ;
	self:downComeIn(UserInfo.getInstance());
	self:setStartReadyVisible();
end;

OnlineRoomSceneNew.loginStartCustomRoom = function(self,pwdStr)
    UserInfo.getInstance():setCustomRoomPwd(pwdStr);
    self:requestCtrlCmd(OnlineRoomController.s_cmds.start_customroom);
end

------------------------------------config--------------------------
--不同房间类型不同的处理函数
CustomRoomModule.s_privateFunc = {
    initGame        = OnlineRoomSceneNew.onCustomRoomInitGame;
    back_action          = OnlineRoomSceneNew.onCustomBack;
    ready_action    = OnlineRoomSceneNew.onCustomRoomReady;
}

CustomRoomModule.s_cmdConfig =
{
    [CustomRoomModule.s_cmds.enter_customroom_fail]  = OnlineRoomSceneNew.onEnterCustomRoomFail;
    [CustomRoomModule.s_cmds.custom_msg_login_room]  = OnlineRoomSceneNew.onCustomMsgLoginRoom;
}

OnlineRoomSceneNew.s_cmds =CombineTables(OnlineRoomSceneNew.s_cmds,
	CustomRoomModule.s_cmds or {});

OnlineRoomSceneNew.s_cmdConfig =CombineTables(OnlineRoomSceneNew.s_cmdConfig,
	CustomRoomModule.s_cmdConfig or {});
--endregion
