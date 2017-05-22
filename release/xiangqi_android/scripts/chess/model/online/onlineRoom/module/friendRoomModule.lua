--region onlineRoomModule.lua
--Date
--此文件由[BabeLua]插件自动生成
--[[
            普通联网游戏模块
     模块结构分：初始化界面和数据(onLineRoomInit)、
--]]
--require(MODEL_PATH.."online/onlineRoom/onlineRoomSceneNew");
FriendRoomModule = class(Node);

FriendRoomModule.s_cmds = 
{
    createFriendRoom    = 201;
    invitFail           = 202;
}

-------------------------------private function----------------------------
OnlineRoomSceneNew.onFriendRoomDtor = function(self)

end

OnlineRoomSceneNew.onFriendRoomInitView = function(self)
end

OnlineRoomSceneNew.onFriendRoomInitGame = function(self)
    self.m_multiple_img_bg:setVisible(true);--倍数
    self:downComeIn(UserInfo.getInstance());
    self:onBaseRoomInitGame();
    self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_login); 
    self.m_down_user_start_btn:setVisible(true);
    if UserInfo.getInstance():getChallenger() == true then
        ChessToastManager.getInstance():show("点击开始按钮向对方发起挑战",2000);
    end
    if UserInfo.getInstance():getChallenger() == false then
        ChessToastManager.getInstance():show("对方正在设置棋局，请稍等");
    end
end

OnlineRoomSceneNew.onFriendRoomResetGame = function(self)
    self.m_chest_btn:setVisible(false);
	self.m_multiple_img_bg:setVisible(false);
	self.m_down_name:setVisible(false);
	self.m_up_name:setVisible(false);
    self.m_net_state_view:setVisible(false);
	self.m_net_state_view_bg:setVisible(false);
    self:showNetSinalIcon(false);
    self.m_down_user_start_btn:setVisible(false);
end

OnlineRoomSceneNew.onFriendRoomDismissDialog = function(self)

end

OnlineRoomSceneNew.onFriendRoomReady = function(self)
    if self.m_ready_time and self.m_ready_time > 0 then
        ChessToastManager.getInstance():show("请等待"..self.m_ready_time.."s再次准备挑战");
        return;
    end
    if UserInfo.getInstance():getChallenger() == false then
        if self.m_upUser == nil then
            self:onForceLeave("对方已经离开，请退出房间");
        end
    end
    if UserInfo.getInstance():getChallenger() then
        local post_data = {};
        post_data.uid = tonumber(UserInfo.getInstance():getUid());
        post_data.target_uid = tonumber(UserInfo.getInstance():getTargetUid());
        post_data.tid = UserInfo.getInstance():getTid();
        UserInfo.getInstance():setChallenger(nil);
        self:requestCtrlCmd(OnlineRoomController.s_cmds.invit_request,post_data);
        self:showMoneyRent();
    end
end

OnlineRoomSceneNew.onCreateFriendRoom = function(self)
    self.m_down_user_start_btn:setVisible(true);
end

--登陆房间成功
OnlineRoomSceneNew.onFriendUserLoginSucc = function(self, data)
    self.m_login_succ = true;
    if data.user then
        self:upComeIn(data.user);
    end;
    self:downComeIn(UserInfo.getInstance());
end;

OnlineRoomSceneNew.onFriendBack = function(self)
	print_string("Room.onFriendBack");
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

--邀请返回【函数内区分失败还是成功】
OnlineRoomSceneNew.onInvitFail = function(self,data)
    require("dialog/friend_chioce_dialog");
    if data and data.ret == 0 then
        if self.m_invit_time_anim then
            delete(self.m_invit_time_anim);
            self.m_invit_time_anim = nil;
        end
        self.m_invit_time_anim_time = (data.time_out or 20)*1000;
        self.m_invit_time_anim = new(AnimInt,kAnimRepeat, 0, 1, self.m_invit_time_anim_time, -1);
        self.m_invit_time_anim:setDebugName("OnlineRoomSceneNew.m_invit_time_anim");
        self.m_invit_time_anim:setEvent(self,self.onInvitTimeOut);
    elseif data and data.ret == 1 then
        self:onDismissDialog();
        local friendData = FriendsData.getInstance():getUserData(data.target_uid);
        delete(self.m_friendChoiceDialog);
        self.m_friendChoiceDialog = new(FriendChoiceDialog);
        if data and data.target_tid ~= 0 and data.target_hallid ~= 0 then   --好友处在下棋中
            self.m_friendChoiceDialog:setMode(2,friendData);
            self.m_friendChoiceDialog:setPositiveListener(self,
                function()         
                    UserInfo.getInstance():setTid(data.target_tid);       --转到好友观战
                    UserInfo.getInstance():setGameType(GAME_TYPE_WATCH);   
                    if WatchRoomModule.IS_NEW then
                        self:onWatchRoomInitView(); 
                    end          
                    self:resume(); end);
            self.m_friendChoiceDialog:setNegativeListener(self,
                function()
                    self:exitRoom();
                    end);
        else
            self.m_friendChoiceDialog:setMode(4,friendData);
            self.m_friendChoiceDialog:setPositiveListener(self,
                function()         
                    self:exitRoom();
                    end);
            self.m_friendChoiceDialog:setNegativeListener(self,
                function()
                    self:exitRoom();
                    end);
        end
        self.m_friendChoiceDialog:show();
    elseif data and data.ret == 2 then
        local message = "该好友今天无心对战，请换个对手挑战吧。"
        if not self.m_chioce_dialog then
		    self.m_chioce_dialog = new(ChioceDialog);
	    end
        self.m_chioce_dialog:setMode();
        self.m_chioce_dialog:setPositiveListener(self,self.exitRoom);
	    self.m_chioce_dialog:setMessage(message);
	    self.m_chioce_dialog:setNegativeListener(self,self.exitRoom);
	    self.m_chioce_dialog:show();
    end
end

--邀请超时
OnlineRoomSceneNew.onInvitTimeOut = function(self)
    self:onDeleteInvitAnim();
    local message = "对方无响应，即将离开房间！"
    if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end
    self.m_chioce_dialog:setMode();
    self.m_chioce_dialog:setPositiveListener(self,self.exitRoom);
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:setNegativeListener(self,self.exitRoom);
	self.m_chioce_dialog:show();
end

OnlineRoomSceneNew.onDeleteInvitAnim = function(self)
    if self.m_invit_time_anim then
        delete(self.m_invit_time_anim);
        self.m_invit_time_anim = nil;
    end
end

------------------------------------config--------------------------
--不同房间类型不同的处理函数
FriendRoomModule.s_privateFunc = {
    initGame        = OnlineRoomSceneNew.onFriendRoomInitGame;
    back_action          = OnlineRoomSceneNew.onFriendBack;
    ready_action    = OnlineRoomSceneNew.onFriendRoomReady;
}

FriendRoomModule.s_cmdConfig =
{
    [FriendRoomModule.s_cmds.createFriendRoom] = OnlineRoomSceneNew.onCreateFriendRoom;
    [FriendRoomModule.s_cmds.invitFail]              = OnlineRoomSceneNew.onInvitFail;           --邀请返回
}

OnlineRoomSceneNew.s_cmds =CombineTables(OnlineRoomSceneNew.s_cmds,
	FriendRoomModule.s_cmds or {});

OnlineRoomSceneNew.s_cmdConfig =CombineTables(OnlineRoomSceneNew.s_cmdConfig,
	FriendRoomModule.s_cmdConfig or {});
--endregion
