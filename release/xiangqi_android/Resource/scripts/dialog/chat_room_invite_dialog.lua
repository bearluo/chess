require(VIEW_PATH .. "chat_room_invite_dialog")

ChatRoomInviteDialog = class(ChessDialogScene, false)

ChatRoomInviteDialog.ctor = function(self,data)
	super(self, chat_room_invite_dialog)
	self.anim_dlg = AnimDialogFactory.createMoveUpAnim(self)
	self:initView()
    self:init()
end

ChatRoomInviteDialog.dtor = function( self )
	self.anim_dlg:stopAnim()
end

ChatRoomInviteDialog.initView = function(self)
    self.m_root_view = self.m_root;
    self.m_dialog_bg = self.m_root_view:getChildByName("bg");
    -- close
    self.m_close_btn = self.m_dialog_bg:getChildByName("close");
    self.m_close_btn:setOnClick(self,self.dismiss);
    -- content
    self.m_content_view = self.m_dialog_bg:getChildByName("content");
    -- bet
    self.m_bet_view = self.m_content_view:getChildByName("bet");
    self.m_bet_left_btn = self.m_bet_view:getChildByName("left");
    self.m_bet_left_btn:setOnClick(self,self.onBetLeftBtnClick);
    self.m_bet_right_btn = self.m_bet_view:getChildByName("right");
    self.m_bet_right_btn:setOnClick(self,self.onBetRightBtnClick);
    self.m_bet_text = self.m_bet_view:getChildByName("txt");
    -- time
    self.m_time_view = self.m_content_view:getChildByName("time");
    self.m_time_left_btn = self.m_time_view:getChildByName("left");
    self.m_time_left_btn:setOnClick(self,self.onTimeLeftBtnClick);
    self.m_time_right_btn = self.m_time_view:getChildByName("right");
    self.m_time_right_btn:setOnClick(self,self.onTimeRightBtnClick);
    self.m_time_text = self.m_time_view:getChildByName("txt");
    -- bottom
    self.m_bottom_view = self.m_dialog_bg:getChildByName("bottom");
    self.m_create_btn = self.m_bottom_view:getChildByName("create");
    self.m_create_btn:setOnClick(self, self.createPrivateRoom);
end;

ChatRoomInviteDialog.init = function(self)
    self.m_bet_index = 1;
    self.m_time_index = 1;
    if UserInfo.getInstance():getChatRoomMatchConfig() then
        self.m_time_table = UserInfo.getInstance():getChatRoomMatchConfig().time_rule;
        self.m_bet_table = UserInfo.getInstance():getChatRoomMatchConfig().match_charge;
    end;
    if self.m_bet_table and self.m_time_table then
        self.m_bet_text:setText(self.m_bet_table[self.m_bet_index].basechip .."金币");
        self.m_time_text:setText(self.m_time_table[self.m_time_index].round_time.."分钟制");
    end;
end;

--详见文档:http://jd.oa.com/wiki/index.php?title=象棋_Server协议文档#.E8.81.8A.E5.A4.A9.E5.AE.A4.E7.BA.A6.E6.88.98.E5.8D.8F.E8.AE.AE.E6.96.87.E6.A1.A3
ChatRoomInviteDialog.createChessGame = function(self)
    if not self.m_bet_table or not self.m_time_table then 
        ChessToastManager.getInstance():showSingle("房间配置出错了:(");
        HttpModule.getInstance():execute(HttpModule.s_cmds.getChatMatchConfig,{});
        return 
    end;
    local msgdata = {};
	msgdata.room_id = self.m_room_item:getRoomId();
	msgdata.msg = self:formatSendTime().." 我正在发起友谊赛邀请，升级新版本可查看详情";
    msgdata.name = UserInfo.getInstance():getName();
	msgdata.uid = UserInfo.getInstance():getUid();
    msgdata.msg_type = 2;
    local other = {};
    other.tid = RoomProxy.getInstance():getTid();
    other.c_uid = UserInfo.getInstance():getUid();
    other.a_uid = 0;
    other.pwd = RoomProxy.getInstance():getSelfRoomPassword();
    other.act = 1;
    other.status = 0;
    other.rm_msgid = 0;
    other.rec_id = "";
    other.rd_t = self.m_time_table[self.m_time_index].round_time;
    other.step_t= self.m_time_table[self.m_time_index].step_time;
    other.sec_t= self.m_time_table[self.m_time_index].sec_time;
    other.base = self.m_bet_table[self.m_bet_index].basechip;
    msgdata.other = json.encode(other);    
    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_USER_CHAT_MSG,msgdata);
    self:dismiss();
end;

ChatRoomInviteDialog.createPrivateRoom = function(self)
    if not self.m_bet_table or not self.m_time_table then 
        ChessToastManager.getInstance():showSingle("房间配置出错了:(");
        HttpModule.getInstance():execute(HttpModule.s_cmds.getChatMatchConfig,{});
        return 
    end;
    local roomData = RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_PRIVATE_ROOM);
    local roompwdStr = "boyaa_chess";
    local roomnameStr = "友谊赛";
    local info = {};
    info.level = roomData.level;
    info.uid = UserInfo.getInstance():getUid();
    info.name = roomnameStr;
    info.password  = roompwdStr;
    info.basechip  = self.m_bet_table[self.m_bet_index].basechip;
    info.round_time= self.m_time_table[self.m_time_index].round_time * 60;
    info.step_time= self.m_time_table[self.m_time_index].step_time;
    info.sec_time= self.m_time_table[self.m_time_index].sec_time;
    RoomProxy.getInstance():setSelfRoomPassword(roompwdStr);
    RoomProxy.getInstance():setSelfRoomNameStr(roomnameStr);
    info.target_uid = 0;
    UserInfo.getInstance():setCustomRoomData(info);
    UserInfo.getInstance():setCustomRoomType(2);
    OnlineSocketManager.getHallInstance():sendMsg(CLIENT_HALL_CREATE_PRIVATEROOM,info);
end;

ChatRoomInviteDialog.formatSendTime = function(self)
    return os.date("%m/%d %H:%M:%S",os.time())
end;

ChatRoomInviteDialog.onBetLeftBtnClick = function(self)
    if not self.m_bet_table then return end;
    if self.m_bet_index > 1 then
        self.m_bet_index = self.m_bet_index - 1;
    else
        self.m_bet_index = 1;
    end;
    self.m_bet_text:setText(self.m_bet_table[self.m_bet_index].basechip .."金币");
end;

ChatRoomInviteDialog.onBetRightBtnClick = function(self)
    if not self.m_bet_table then return end;
    if self.m_bet_index < #self.m_bet_table then
        self.m_bet_index = self.m_bet_index + 1;
    else
        self.m_bet_index = #self.m_bet_table;
    end;
    self.m_bet_text:setText(self.m_bet_table[self.m_bet_index].basechip .."金币");
end;

ChatRoomInviteDialog.onTimeLeftBtnClick = function(self)
    if not self.m_time_table then return end;
    if self.m_time_index > 1 then
        self.m_time_index = self.m_time_index - 1;
    else
        self.m_time_index = 1;
    end;
    self.m_time_text:setText(self.m_time_table[self.m_time_index].round_time.."分钟制");
end;

ChatRoomInviteDialog.onTimeRightBtnClick = function(self)
    if not self.m_time_table then return end;
    if self.m_time_index < #self.m_time_table then
        self.m_time_index = self.m_time_index + 1;
    else
        self.m_time_index = #self.m_time_table;
    end;
    self.m_time_text:setText(self.m_time_table[self.m_time_index].round_time.."分钟制");
end;

ChatRoomInviteDialog.show = function(self,data)
    self.m_room_item = data;
	self.super.show(self, self.anim_dlg.showAnim)
end

ChatRoomInviteDialog.dismiss = function( self )
	self.super.dismiss(self, self.anim_dlg.dismissAnim)
end
