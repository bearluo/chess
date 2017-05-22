require(MODEL_PATH .. "online/onlineRoom/module/baseModule");
require(DIALOG_PATH.."invite_friends_dialog");

CustomModule = class(BaseModule);

function CustomModule.ctor(self,scene)
    BaseModule.ctor(self,scene);          --房间ID(View)
	self.mScene.m_multiple_text:setText("私人房");
end

function CustomModule.dtor(self)
    delete(self.mInviteFriendsDialog);
    delete(CustomModule.schedule_repeat_time)
	self.mScene.m_multiple_text:setText("");
end

function CustomModule.setStatus(self,status)
    if status == STATUS_TABLE_PLAYING then   --走棋状态
        self.mScene.m_private_change_player_btn:setVisible(false);
        self.mScene.m_private_invite_friends_btn:setVisible(false);
	elseif status == STATUS_TABLE_FORESTALL then  -- 抢先状态
        self.mScene.m_private_change_player_btn:setVisible(false);
        self.mScene.m_private_invite_friends_btn:setVisible(false);
	elseif status == STATUS_TABLE_HANDICAP then  -- 让子状态
        self.mScene.m_private_change_player_btn:setVisible(false);
        self.mScene.m_private_invite_friends_btn:setVisible(false);
	elseif self.mScene.m_t_statuss == STATUS_TABLE_RANGZI_CONFIRM then   -- 让子确认状态
        self.mScene.m_private_change_player_btn:setVisible(false);
        self.mScene.m_private_invite_friends_btn:setVisible(false);
	elseif status == STATUS_TABLE_SETTIME then -- 设置局时状态
        self.mScene.m_private_change_player_btn:setVisible(false);
        self.mScene.m_private_invite_friends_btn:setVisible(false);
    elseif status == STATUS_TABLE_SETTIMERESPONE then -- 设置局时响应状态
        self.mScene.m_private_change_player_btn:setVisible(false);
        self.mScene.m_private_invite_friends_btn:setVisible(false);
    else
    end
end

function CustomModule.initGame(self)
    if self.mScene.m_customRoomExit then
        self.mScene.m_customRoomExit = false;
        StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
        return;
    end
    self.mScene.m_down_user_start_btn:setVisible(true);
    self.mScene.m_private_change_player_btn:setVisible(RoomProxy.getInstance():isSelfRoom() and self.mScene.m_upUser ~= nil and UserInfo.getInstance():getCustomRoomType()==0);
    self.mScene.m_private_invite_friends_btn:setVisible(RoomProxy.getInstance():isSelfRoom() and self.mScene.m_upUser == nil and UserInfo.getInstance():getCustomRoomType()==0);
    self.mScene.m_private_change_player_btn:setOnClick(self,self.onPrivateChangePlayerBtnClick);
    self.mScene.m_private_invite_friends_btn:setOnClick(self,self.onPrivateInviteFriendsBtnClick);
	self.mScene.m_roomid:setVisible(true);
    self.mScene:downComeIn(UserInfo.getInstance());
    self:startCustomroom();
    -- 每次进入私人房重新初始化 结算加好友的逻辑
    AccountDialog.s_preUid = nil
end

function CustomModule.resetGame(self)
	self.mScene.m_up_view1.user_name:setVisible(false);
    self.mScene.m_down_user_start_btn:setVisible(false);
    self.mScene.m_roomid:setVisible(false);
end

function CustomModule.dismissDialog(self)

end

function CustomModule.readyAction(self)
    if RoomProxy.getInstance():isSelfRoom() then
        if UserInfo.getInstance():getCustomRoomType() == 0 then -- 来自普通私人房间
        elseif UserInfo.getInstance():getCustomRoomType() == 1 then -- 来自聊天室或其他场景挑战邀请
            local data = UserInfo.getInstance():getCustomRoomData();
            if not next(data) then 
                ChessToastManager.getInstance():showSingle("房间信息有误");
                self.mScene:exitRoom();
            else
                data.tid = UserInfo.getInstance():getCustomRoomID();
                self.mScene:requestCtrlCmd(OnlineRoomController.s_cmds.send_custom_stranger_invite,data);
            end;
        elseif UserInfo.getInstance():getCustomRoomType() == 3 then
            local data = UserInfo.getInstance():getCustomRoomData();
            if not next(data) then 
                ChessToastManager.getInstance():showSingle("房间信息有误");
                self.mScene:exitRoom();
            else
                data.tid = UserInfo.getInstance():getCustomRoomID();
                self.mScene:requestCtrlCmd(OnlineRoomController.s_cmds.send_custom_stranger_invite,data);
            end
        end
    end
end

function CustomModule.onInvitNotify(self,data)
    if data.ret and data.ret == 0 then
        CustomModule.schedule_repeat_time = ToolKit.schedule_repeat_time(self,function(self,a,b,c,cur_loopnum) 
            if not data.time_out then return end;
            local sec = tonumber(data.time_out) - tonumber(cur_loopnum);
            if sec <= 0 then return end;
            ChessToastManager.getInstance():showSingle("等待对方答复...("..sec..")" ,1000);
         end,1000,data.time_out)
    elseif data.ret and data.ret == 1 then
        ChessToastManager.getInstance():showSingle("对方不在线");
        delete(CustomModule.schedule_repeat_time)
        self.mScene:exitRoom();        
    elseif data.ret and data.ret == 2 then
        ChessToastManager.getInstance():showSingle("对方已拒绝应战");
        delete(CustomModule.schedule_repeat_time)
        self.mScene:exitRoom();
    end;
end;

function CustomModule.backAction(self)
    -- argly!!!argly!!!argly!!!
    -- 聊天室约战,等待玩家入场(等10s)
    if UserInfo.getInstance():getCustomRoomType() == 2 then
        if ToolKit.schedule_once_anim then
            ChessToastManager.getInstance():showSingle("请您等待玩家入场");
            OnlineRoomController.s_switch_func = nil
            return;
        end;
    end;
    local message = "亲，中途离开则会输掉棋局哦！"
    if not self.mScene.m_chioce_dialog then
		self.mScene.m_chioce_dialog = new(ChioceDialog);
	end
	self.mScene.m_chioce_dialog:setNegativeListener(nil,nil);
    if self.mScene.m_downUser and not self.mScene.m_game_start then
        message = "您确定离开吗？"
        self.mScene.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE,"退出","取消");
        self.mScene.m_chioce_dialog:setPositiveListener(self.mScene,self.mScene.exitRoom);
        self.mScene.m_chioce_dialog:setNegativeListener(self,function(self)
            OnlineRoomController.s_switch_func = nil
        end)
    elseif self.mScene.m_downUser then
        if not self.mScene:checkCanSurrender() then OnlineRoomController.s_switch_func = nil return end
        self.mScene.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE,"认输退出","取消");
        self.mScene.m_chioce_dialog:setPositiveListener(self.mScene,self.mScene.surrender_sure);
        self.mScene.m_chioce_dialog:setNegativeListener(self,function(self)
            OnlineRoomController.s_switch_func = nil
        end)
    else
        self.mScene.m_chioce_dialog:setPositiveListener(self.mScene,self.mScene.exitRoom);
        self.mScene.m_chioce_dialog:setNegativeListener(self,function(self)
            OnlineRoomController.s_switch_func = nil
        end)
    end
	self.mScene.m_chioce_dialog:setMessage(message);
	self.mScene.m_chioce_dialog:show();
end

function CustomModule.onPrivateChangePlayerBtnClick(self)
    if RoomProxy.getInstance():getCurRoomType() == RoomConfig.ROOM_TYPE_PRIVATE_ROOM then
        if self.mScene.m_upUser then
            if tonumber(self.mScene.m_upUser:getClient_version()) and tonumber(self.mScene.m_upUser:getClient_version()) >= 215 then
                self.mScene:requestCtrlCmd(OnlineRoomController.s_cmds.server_cmd_kick_player);
            else
                ChessToastManager.getInstance():showSingle("对方版本过低不支持踢人功能");
            end
        end
    end
end

function CustomModule.onPrivateInviteFriendsBtnClick(self)
    local url = UserInfo.getInstance():getInviteFriendsUrl();
    if not url then
       ChessToastManager.getInstance():showSingle("登录信息缺失，请重新登录");
       return ;
    end
    self.mScene:requestCtrlCmd(OnlineRoomController.s_cmds.get_private_room_info);
end

function CustomModule.startCustomroom(self)
	print_string("Room.start_customroom ... ");
  	self.mScene.m_roomid_text:setText("房间ID "..UserInfo.getInstance():getCustomRoomID());
    self.mScene:requestCtrlCmd(OnlineRoomController.s_cmds.start_customroom);
end

function CustomModule.onGetPrivateInfo(self,data)
    Log.i(json.encode(data));
    delete(self.mInviteFriendsDialog);
    self.mInviteFriendsDialog = new(InviteFriendsDialog);
    self.mInviteFriendsDialog:show(data);
end

function CustomModule.sendFllowCallback(self,info)
end

function CustomModule.upComeIn(self,user)
    -- argly!!!argly!!!argly!!!
    -- 约战客户端要搞个定时器，告诉玩家已经有人约战
    if UserInfo.getInstance():getCustomRoomType() == 2 then
        delete(ToolKit.schedule_once_anim);
        ToolKit.schedule_once_anim = nil;
    end;
end