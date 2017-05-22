
require("config/path_config");

require(MODEL_PATH.."room/roomController");

OnlineRoomController = class(RoomController);

OnlineRoomController.s_cmds = 
{	
    back_action             = 1;
    start_watch             = 2;
    start_customroom        = 3;
    end_watch               = 4;
    syn_watch_data          = 5;
    send_watch_chat         = 6;
    hall_quick_start        = 7;
    hall_game_info          = 8;
    hall_cancel_match       = 9;
    client_msg_start        = 10;
    client_msg_forestall    = 11;
    syn_room_data           = 12;
    client_msg_watchlist    = 13;
    client_get_openbox_time = 14;
    client_msg_leave        = 15;
    client_msg_chat         = 16;
    client_msg_handicap     = 17;
    client_msg_comein       = 18;
    client_msg_move         = 19;
    close_room_socket       = 20;
    room_get_reward         = 21;
    client_msg_draw1        = 22;
    client_msg_draw2        = 23;
    client_msg_undomove     = 24;
    client_msg_surrender1   = 25;
    client_msg_surrender2   = 26;
    get_task_progress       = 27;
    open_room_socket        = 28;
    client_msg_login        = 29;
    send_ready_msg          = 30;
    client_msg_logout       = 31;
    client_msg_offline      = 32;

    server_msg_forestall    = 33;
    server_msg_handicap     = 34;

    invit_request           = 35;
    set_time_finish         = 36;
    set_time_response       = 37;
    client_add              = 38;
    server_msg_forestall_new = 39;
    invit_response          = 40;
    save_recent_chess_data  = 50;
    server_cmd_kick_player  =  51;
    sharePicture            = 52;
    save_mychess            = 53;
};

OnlineRoomController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end

OnlineRoomController.resume = function(self)
    RoomController.resume(self);
--    self:onNativeNetStateChange(true, "4");
--    self:addSocketTools();
end;

OnlineRoomController.pause = function(self)
    RoomController.pause(self);
--    self:removeSocketTools();
end;

OnlineRoomController.dtor = function(self)
    User.clearCacheIcon();
    if self.m_forbid_dialog then
        delete(self.m_forbid_dialog);
        self.m_forbid_dialog = nil;
    end;
end;

OnlineRoomController.onBack = function(self)
    self:updateView(OnlineRoomSceneNew.s_cmds.exit_room);
end;

OnlineRoomController.onRoomTouch = function(self,finger_action, x, y)
    self:updateView(OnlineRoomSceneNew.s_cmds.on_room_touch, finger_action, x, y);
end;

----------------------------------function---------------------------------


--玩家返回游戏通知对手
OnlineRoomController.onEventResume = function(self)
    ChessController.onEventResume()
	print_string("Room.onHomeResume");

	self:ClearOSTimeout();
	
	local gametype = UserInfo.getInstance():getGameType();
--	local status = UserInfo.getInstance():getStatus();
	if gametype == GAME_TYPE_WATCH then
		return;
	end
  
    self:sendSocketMsg(CLIENT_MSG_HOMEPRESS, 0,nil, 1);
    self:updateView(OnlineRoomSceneNew.s_cmds.resume_from_homekey);
    -- home 回来后重新登录大厅检测游戏状态
--    self:closeSocket(true);
--    self:openHallSocket();
--    self:sendSocketMsg(HALL_MSG_LOGIN, nil, SUBCMD_LADDER ,2);
--    self:sendSocketMsg(CLIENT_HALL_NET_DATA_REPORT);
end;

--玩家在游戏过程中按下Home键通知对手
OnlineRoomController.onEventPause = function(self)
    ChessController.onEventPause();
	print_string("Room.onHomePause");

	self:OSTimeout();
	local gametype = UserInfo.getInstance():getGameType();
	if gametype == GAME_TYPE_WATCH then
		return;
	end

    self:sendSocketMsg(CLIENT_MSG_HOMEPRESS, 2,nil, 1);
    self:sendSocketMsg(CLIENT_CMD_CALLTELPHONE);
end;

OnlineRoomController.initTimeout=function(self)
	-- 20s 退出房间
	-- 1m  关闭程序
	self.m_timeout={
		roomExitRoom={id=1001 , ms=1000*20};
	};
end

-- 设置一个timeout,当其到达时关闭 room socket
OnlineRoomController.OSTimeout = function(self)
	print_string("设置 timeout .... ");
	self:initTimeout();
	for k , v in pairs(self.m_timeout) do
		dict_set_int(kOSTimeout,kOSTimeoutId,v.id);
		dict_set_int(kOSTimeout,kOSTimeoutMs,v.ms);
		call_native(kSetOSTimeout);
	end
end

-- 无论timeout是否处理过，都清除
OnlineRoomController.ClearOSTimeout = function(self)
	print_string("无论timeout是否处理过，都清除...");
	for k , v in pairs(self.m_timeout) do
		dict_set_int(kOSTimeout,kOSTimeoutId,v.id);
		call_native(kClearOSTimeout);
	end 
end

-- OSTimeoutCallback 
OnlineRoomController.OSTimeoutCallback = function(self)
	--local id = dict_get_int(kOSTimeout,kOSTimeoutId,-1);

	local id = dict_get_string(kOSTimeoutCallback, kOSTimeoutCallback .. kResultPostfix);
	id = tonumber(id);
	--print_string("OSTimeoutCallback id:" .. id);当id为nil时会报错
    if id == self.m_timeout.roomExitRoom.id then 
    	-- 如果是关闭socket的timetou到达了，如果是在房间内，则退出房间  
        print_string("如果是关闭socket的timetou到达了，如果是在房间内，则关闭room socket   ...... ")      
        if UserInfo.getInstance():getGameType() == GAME_TYPE_WATCH then
        	self:updateView(OnlineRoomSceneNew.s_cmds.exit_room);
        end

    -- elseif id == self.m_timeout.exitGame.id then       
    --     --如果是关闭程序的timetou到达了，则关闭程序
    --     print_string("如果是关闭程序的timetou到达了，则关闭程序 ...... ")
    --     sys_exit();
    end
end

OnlineRoomController.sendSocketMsg = function(self,cmd,info,subcmd, writeType, socketType)
   self.m_hallSocket:sendMsg(cmd,info,subcmd, writeType); 
end

OnlineRoomController.onBackAction = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end;

OnlineRoomController.onStartWatch = function(self)
    self:sendSocketMsg(CLIENT_MSG_LOGIN, 1,nil,1);
end;

OnlineRoomController.onRecvClientWatchJoin = function(self, packetInfo)
    Log.i("onClientWatchLogin");
    if not packetInfo then
        self:updateView(OnlineRoomSceneNew.s_cmds.updateWatchRoom, nil, "进入观战棋局失败，请刷新后选择其他棋局进行观战")
        return;
    end;
    self:updateView(OnlineRoomSceneNew.s_cmds.updateWatchRoom, packetInfo);
end;

OnlineRoomController.onRecvServerWatchStart = function(self, packetInfo)
   self:updateView(OnlineRoomSceneNew.s_cmds.watchRoomStart,packetInfo);
end;


OnlineRoomController.onRecvServerWatchMove = function(self, packetInfo)
   self:updateView(OnlineRoomSceneNew.s_cmds.watchRoomMove,packetInfo);  
end;

OnlineRoomController.onRecvServerWatchDraw = function(self, packetInfo)
   self:updateView(OnlineRoomSceneNew.s_cmds.watchRoomDraw,packetInfo);  
end;

OnlineRoomController.onRecvServerWatchSurrender = function(self, packetInfo)
   self:updateView(OnlineRoomSceneNew.s_cmds.watchRoomSurrender,packetInfo);  
end;

OnlineRoomController.onRecvServerWatchUndo = function(self, packetInfo)
   self:updateView(OnlineRoomSceneNew.s_cmds.watchRoomUndo,packetInfo);     
end;

OnlineRoomController.onRecvServerWatchUserLeave = function(self, packetInfo)
   self:updateView(OnlineRoomSceneNew.s_cmds.watchRoomUserLeave,packetInfo);      
end;

OnlineRoomController.onRecvServerWatchGameOver = function(self, packetInfo)
   self:updateView(OnlineRoomSceneNew.s_cmds.watchRoomClose,packetInfo);      
end;

OnlineRoomController.onRecvServerWatchAllReady = function(self, packetInfo)
   self:updateView(OnlineRoomSceneNew.s_cmds.watchRoomAllready,packetInfo);  
end;

OnlineRoomController.onRecvServerWatchError = function(self, packetInfo)
   self:updateView(OnlineRoomSceneNew.s_cmds.watchRoomError);  
end;

OnlineRoomController.onRecvClientWatchChat = function(self, packetInfo)
    
    self:updateView(OnlineRoomSceneNew.s_cmds.watcherChatMsg, packetInfo); 
end;

OnlineRoomController.sharePicture = function(self)
    Log.i("OnlineRoomController.onShareAction");
	share_img_msg("egame_share");
end;


OnlineRoomController.isForbidSendMsg = function(self,packetInfo)
    if packetInfo and packetInfo.forbid_time and packetInfo.forbid_time > 0 then
        local tip_msg = "很抱歉，您的账号被多次举报，经核实已被禁言，将于"..os.date("%Y-%m-%d %H:%M",packetInfo.forbid_time) .."解禁，感谢您的配合和理解。"
        if not self.m_forbid_dialog then
            self.m_forbid_dialog = new(ChioceDialog);
        end;
        self.m_forbid_dialog:setMode(ChioceDialog.MODE_SURE);
        self.m_forbid_dialog:setMessage(tip_msg);
        self.m_forbid_dialog:show();
        return true;
    end; 
    return false;
end;

--以下是新的观战接口
OnlineRoomController.onRecvServerNewWatchMsg = function(self,packetInfo)
    if self:isForbidSendMsg(packetInfo) then return end;
    self:updateView(OnlineRoomSceneNew.s_cmds.watchRoomMsg, packetInfo);
end

OnlineRoomController.onRecvServerNewTableInfo = function(self,packetInfo)
    --和老接口一样
    Log.i("onClientWatchLogin");
    if not packetInfo then
        self:updateView(OnlineRoomSceneNew.s_cmds.updateWatchRoom, nil, "进入观战棋局失败，请刷新后选择其他棋局进行观战")
        return;
    end;
    self:updateView(OnlineRoomSceneNew.s_cmds.updateWatchRoom, packetInfo);
    local info = {};
    info.tid = UserInfo.getInstance():getTid();
    self:sendSocketMsg(OB_CMD_GET_NUM, info,nil,1);
end

OnlineRoomController.onRecvServerNewWatchList = function(self,info)
--    self:updateView(OnlineRoomSceneNew.s_cmds.watchRoomUserEnter,packetInfo);
    if not info then return end
    if info.curr_page == 0 then
        self.m_list_data = {};
    end
    if info.item_num > 0 then 
        for i,v in pairs(info.watch_items) do 
            table.insert(self.m_list_data,v);
        end
    end
    if info.curr_page+1 >= info.page_num then
        self:updateView(OnlineRoomSceneNew.s_cmds.updateWatchUserList,self.m_list_data);
    end
end

OnlineRoomController.onRecvServerNewPlayerEnter = function(self,packetInfo)
    self:updateView(OnlineRoomSceneNew.s_cmds.watchRoomUserEnter,packetInfo);
end

OnlineRoomController.onRecvServerNewPlayerLeave = function(self,packetInfo)
    --和老接口一样
    self:updateView(OnlineRoomSceneNew.s_cmds.watchRoomUserLeave,packetInfo);   
end

OnlineRoomController.onRecvServerNewUpdateTable = function(self,packetInfo)
    self:updateView(OnlineRoomSceneNew.s_cmds.watchRoomUpdateTable,packetInfo);
end

OnlineRoomController.onRecvServerNewGameStart = function(self,packetInfo)
    --和老接口一样
    self:updateView(OnlineRoomSceneNew.s_cmds.watchRoomStart,packetInfo);
end

OnlineRoomController.onRecvServerNewChessMove = function(self,packetInfo)
    --和老接口不一样，少了个观战人数，不影响
    self:updateView(OnlineRoomSceneNew.s_cmds.watchRoomMove,packetInfo);
    local info = {};
    info.tid = UserInfo.getInstance():getTid();
    self:sendSocketMsg(OB_CMD_GET_NUM, info,nil,1);
end

OnlineRoomController.onRecvServerNewChessUndo = function(self,packetInfo)
    --和老接口一样
    self:updateView(OnlineRoomSceneNew.s_cmds.watchRoomUndo,packetInfo);
end

OnlineRoomController.onRecvServerNewChessDraw = function(self,packetInfo)
    --和老接口一样
    self:updateView(OnlineRoomSceneNew.s_cmds.watchRoomDraw,packetInfo);
end

OnlineRoomController.onRecvServerNewChessSurrender = function(self,packetInfo)
    --和老接口一样
    self:updateView(OnlineRoomSceneNew.s_cmds.watchRoomSurrender,packetInfo);  
end

OnlineRoomController.onRecvServerNewGameOver = function(self,packetInfo)
    --和老接口一样
    self:updateView(OnlineRoomSceneNew.s_cmds.watchRoomClose,packetInfo);   
end

OnlineRoomController.onRecvServerNewGetNumber = function(self,packetInfo)
    self:updateView(OnlineRoomSceneNew.s_cmds.watchNumber,packetInfo); 
end

--新观战接口end

OnlineRoomController.onRecvServerInvitRequest = function(self, packetInfo)
    if packetInfo.ret == 0 then
        --邀请消息发送成功
        self:updateView(OnlineRoomSceneNew.s_cmds.invitFail,packetInfo);
    else
        --邀请消息发送失败
        self:updateView(OnlineRoomSceneNew.s_cmds.invitFail,packetInfo);
    end
end;

OnlineRoomController.onRecvServerInvitResponse = function(self, packetInfo)
	self:updateView(OnlineRoomSceneNew.s_cmds.deleteInvitAnim);
    if packetInfo.ret == 0 then
        --对方接受挑战
        ChessToastManager.getInstance():show("对方接受挑战");
    else
        --对方拒绝，请求重置状态
        local data = {};
        data.uid = UserInfo.getInstance():getUid();
        data.status = 1;
        self:sendSocketMsg(CLIIENT_CMD_RESET_TABLE,data,nil,1);
    end
end;

OnlineRoomController.onRecvServerResetTable = function(self, packetInfo)
    if packetInfo.ret == 0 then
        --重置状态成功
        ChessToastManager.getInstance():show("对方拒绝应战，请稍后再挑战!");
        self:updateView(OnlineRoomSceneNew.s_cmds.resetGame,true);
    else
        --重置状态失败
        ChessToastManager.getInstance():show("重置房间错误,请重新邀请!", 5000);
        self:onBackAction();
    end
end;

OnlineRoomController.onInvitNotify = function(self,packageInfo)
    --需要判断是否在下棋中
    if not packageInfo or not packageInfo.uid or not packageInfo.tid then
        return;
    end
    self:updateView(OnlineRoomSceneNew.s_cmds.invitNotify,packageInfo); 
end

OnlineRoomController.onRecvServerSetTime = function(self, packetInfo)
    if packetInfo.uid == UserInfo.getInstance():getUid() then
        self:updateView(OnlineRoomSceneNew.s_cmds.setTime,packetInfo.time_out);
    else
        ChessToastManager.getInstance():show("对方正在设置棋局，请稍等");
    end
end;

OnlineRoomController.onRecvServerSetTimeNotify = function(self, packetInfo)
    if packetInfo.uid == UserInfo.getInstance():getUid() then
        self:updateView(OnlineRoomSceneNew.s_cmds.setTimeShow,packetInfo); 
    end
end;

OnlineRoomController.onRecvServerSetTimeResponse = function(self, packetInfo)
    if packetInfo.ret == 0 then
        if packetInfo.uid ~= UserInfo.getInstance():getUid() then
            ChessToastManager.getInstance():show("对方同意棋局设置！");
        end
    else
        if packetInfo.uid ~= UserInfo.getInstance():getUid() then
            ChessToastManager.getInstance():show("对方拒绝棋局设置！");
        end
    end
end

OnlineRoomController.openRoomSocket = function(self)

end

OnlineRoomController.onEndWatch = function(self)
    self:sendSocketMsg(CLIENT_WATCH_LOGOUT,nil,nil,1);
end

OnlineRoomController.onSynWatchData = function(self)
    local params = {};
    params.tid = UserInfo.getInstance():getTid();
    self:sendSocketMsg(OB_CMD_GET_TABLE_INFO,params);
end

OnlineRoomController.onSendWatchChat = function(self, message)
    self:sendSocketMsg(OB_CMD_CHAT_MSG,message,nil,1);
end;

OnlineRoomController.onHallQuickStart = function(self)
    self:sendSocketMsg(HALL_MSG_QUICKSTART,nil,SUBCMD_MONEY,2, "hall");
end;

OnlineRoomController.onHallGameInfo = function(self,data)
    self:addSocketTools();
    self:sendSocketMsg(HALL_MSG_GAMEINFO,data,SUBCMD_MONEY,2);
end;

OnlineRoomController.onHallCancelMatch = function(self,roomid)
    self:sendSocketMsg(CLIENT_HALL_CANCEL_MATCH,roomid,nil,1);
end;

OnlineRoomController.onClientMsgStart = function(self)
    self:sendSocketMsg(CLIENT_MSG_START,nil,nil,1);
end;

OnlineRoomController.onClientMsgForestall = function(self, subcmd, befirst)
    
end;

OnlineRoomController.onServerMsgForestall = function(self, befirst)
    self:sendSocketMsg(SERVER_MSG_FORESTALL,befirst,nil,1);
end;

OnlineRoomController.onServerMsgForestallNew = function(self, befirst)
    self:sendSocketMsg(SERVER_MSG_FORESTALL_NEW,befirst,nil,1);
end;

OnlineRoomController.onServerMsgHandicap = function(self, info)
    self:sendSocketMsg(SERVER_MSG_HANDICAP,info,nil,1);
end;

OnlineRoomController.onSynRoomData = function(self)
    self:sendSocketMsg(CLIENT_MSG_SYNCHRODATA,nil,nil,1);
end;

OnlineRoomController.onClientMsgWatchlist = function(self)
    self:sendSocketMsg(CLIENT_MSG_WATCHLIST,nil, nil, 1);
end;

OnlineRoomController.onClientGetOpenboxTime = function(self, subcmd, changeMoney)
    if subcmd == 1 then
        self:sendSocketMsg(CLIENT_GET_OPENBOX_TIME,changeMoney, subcmd, 2);
    else
        self:sendSocketMsg(CLIENT_GET_OPENBOX_TIME,nil, nil, 1);
    end;
end;

OnlineRoomController.onClientMsgLogin = function(self)
    self:addSocketTools();
    self:sendSocketMsg(CLIENT_MSG_LOGIN,nil,nil,1);
end;

OnlineRoomController.onSendReadyMsg = function(self)
    self:sendSocketMsg(CLIENT_MSG_READY,nil,nil,1)
end;

OnlineRoomController.onClientMsgLogout = function(self)
    self:sendSocketMsg(CLIENT_MSG_LOGOUT,nil, nil,1);
end;

OnlineRoomController.onClientMsgOffline = function(self)
    self:sendSocketMsg(CLIENT_MSG_OFFLINE,nil, nil,1);
end;

OnlineRoomController.onClientMsgLeave = function(self)
    self:sendSocketMsg(CLIENT_MSG_LEAVE,nil, nil,1);
end;

OnlineRoomController.onClientMsgChat = function(self, info)
    self:sendSocketMsg(CLIENT_MSG_CHAT, info, 1 ,2);
end;

OnlineRoomController.onClientMsgHandicap = function(self, subcmd, info)
    self:sendSocketMsg(CLIENT_MSG_HANDICAP, info, subcmd, 2)
end;

OnlineRoomController.onClientMsgComein = function(self)
    self:sendSocketMsg(CLIENT_MSG_COMEIN,nil,nil,1);  
end;

OnlineRoomController.onClientMsgMove = function(self, info)
    self:sendSocketMsg(CLIENT_MSG_MOVE, info, nil,1);
end;

OnlineRoomController.onCloseRoomSocket = function(self)

end;

OnlineRoomController.onRoomGetOnlineReward = function(self, id)
	if id <= 0 then
		local retdata = {};
		retdata.flag =  2;
        self:updateView(OnlineRoomSceneNew.s_cmds.client_get_openbox_time, retdata);
        self:sendSocketMsg(CLIENT_GET_OPENBOX_TIME, nil , nil, 1);
		return;
	end
	local post_data = {};
	post_data.id = id;
	HttpModule.getInstance():execute(HttpModule.s_cmds.getOnlineReward,post_data,tips);    
end;

OnlineRoomController.onClientMsgDraw1 = function(self)
    self:sendSocketMsg(CLIENT_MSG_DRAW1,nil, nil, 1);
end;

OnlineRoomController.onClientMsgDraw2 = function(self, info)  
    self:sendSocketMsg(CLIENT_MSG_DRAW2,info, nil, 1);
end;

OnlineRoomController.onClientMsgUndomove = function(self,subcmd, info)   
    self:sendSocketMsg(CLIENT_MSG_UNDOMOVE, info, subcmd, 2);
end;

OnlineRoomController.onClientMsgSurrender1 = function(self)
    self:sendSocketMsg(CLIENT_MSG_SURRENDER1, nil, nil, 1);
end;

OnlineRoomController.onClientMsgSurrender2 = function(self, info)
    self:sendSocketMsg(CLIENT_MSG_SURRENDER2, info, nil, 1);
end;

OnlineRoomController.onGetTaskProgress = function(self, info)
    PhpConfig.getDailyURL = PhpConfig.DAILY_TASK_URL .. "&bid=".. PhpConfig.getBid() .. "&aid=" .. UserInfo.getInstance():getActionDailyAid() .. "&mid=" .. PhpConfig.getMid();
    local post_data = {};
    self:sendHttpMsg(HttpModule.s_cmds.getTaskProgress, post_data);
end;

OnlineRoomController.onOpenRoomSocket = function(self)   
    self:openRoomSocket();
end;

OnlineRoomController.onStartCustom = function(self)
    self:sendSocketMsg(CLIENT_MSG_LOGIN,nil,nil,1);
end;

OnlineRoomController.onInviteRequest = function(self,post_data)
    self:sendSocketMsg(FRIEND_CMD_FRIEND_INVITE_REQUEST,post_data,nil,1);
end;

OnlineRoomController.onInviteResponse = function(self,post_data)
    self:sendSocketMsg(FRIEND_CMD_FRIEND_INVIT_RESPONSE2,post_data,nil,1);
end;

OnlineRoomController.onSetTimeFinish = function(self,post_data)
    self:sendSocketMsg(SERVER_BROADCAST_SET_TIME,post_data,nil,1);
end;

OnlineRoomController.onSetTimeResponse = function(self,flag)
    print_string("OnlineRoomController.onSetTimeResponse");
    local post_data = {};
    post_data.uid = UserInfo.getInstance():getUid();
    if flag then
        post_data.ret = 0;
    else
        post_data.ret = 1;
    end
    self:sendSocketMsg(SERVER_BROADCAST_SET_TIME_RESPONSE,post_data,nil,1);
    if flag == false then
        self:onClientMsgLogout();
    end 
end;

OnlineRoomController.onClientAdd = function(self,data)
    local text = data;
    print_string("OnlineRoomController.onClientAdd");
    self:sendSocketMsg(FRIEND_CMD_ADD_FLLOW,data);
end;

OnlineRoomController.onRecvServerAddFllow = function(self,info)
    if not info then return end

    self:updateView(OnlineRoomSceneNew.s_cmds.updateWatchDialog,info);
    if info.ret ~= 0 then
        ChessToastManager.getInstance():show("关注失败!");
        return ;
    end
    self:updateView(OnlineRoomSceneNew.s_cmds.updateUserInfoDialog,info);
end

OnlineRoomController.saveRecentChessData = function(self,recent_data)
    self.m_recent_data = recent_data;
    self:sendSocketMsg(CLIENT_CMD_GETTABLESTEP);
end

OnlineRoomController.onServerCmdKickPlayer = function(self)
    self:sendSocketMsg(SERVER_CMD_KICK_PLAYER);
end


-- isSelf,是否个人收藏
OnlineRoomController.onSaveMychess = function(self,isSelf)
    if self.m_view and self.m_view.m_mvData and next(self.m_view.m_mvData) then
        local chessData = self.m_view.m_mvData;    
        local post_data = {};
        post_data.mid = UserInfo.getInstance():getUid();
        post_data.down_user = chessData.down_user;
        post_data.red_mid = chessData.red_mid;
        post_data.black_mid = chessData.black_mid;
        post_data.red_mnick = chessData.red_mnick;
        post_data.black_mnick = chessData.black_mnick;
        post_data.win_flag = chessData.win_flag;
        post_data.end_type = chessData.end_type;
        post_data.manual_type = chessData.manual_type;
        post_data.start_fen = chessData.start_fen;
        post_data.move_list = chessData.move_list;
        post_data.end_fen = chessData.end_fen;
        post_data.collect_type = (isSelf and 2) or 1; -- 收藏类型, 1公共收藏，2人个收藏 
        post_data.is_old = chessData.is_old or 0;
        self:sendHttpMsg(HttpModule.s_cmds.saveMychess,post_data);
    end;
end;

----------------------------------socket-----------------------------------

OnlineRoomController.onMatchSuccess = function(self, socket)

    Log.i("房间匹配到对手了，将要登陆到房间");
    UserInfo.getInstance():setConnectRoom(true);
    self:sendSocketMsg(CLIENT_MSG_LOGIN,nil,nil,1);
--    self:updateView(OnlineRoomSceneNew.s_cmds.matchSuccess);
end;

OnlineRoomController.onClientWatchLogin = function(self, packetInfo)
    Log.i("onClientWatchLogin");
    self:sendSocketMsg(CLIENT_WATCH_USERLIST, nil,nil, 1);--获取观战人数
    if not next(packetInfo) then
        self:updateView(OnlineRoomSceneNew.s_cmds.updateWatchRoom, nil, "进入观战棋局失败，请刷新后选择其他棋局进行观战")
        return;
    end;
    self:updateView(OnlineRoomSceneNew.s_cmds.updateWatchRoom, packetInfo);  
end

OnlineRoomController.onRecvClientWatchUserlist = function(self, packetInfo)
    Log.i("OnlineRoomController.onRecvServerMsg");
    if not packetInfo then
        return;
    end;
    self:updateView(OnlineRoomSceneNew.s_cmds.updateWatchRoomUser, packetInfo);
end;

OnlineRoomController.onRecvClientMsgWatchlist = function(self, packetInfo)

    if not packetInfo then
        return;
    end;
    self:updateView(OnlineRoomSceneNew.s_cmds.updateWatchRoomUser, packetInfo);

end;



OnlineRoomController.onRecvClientGetOpenboxTime = function(self, packetInfo)

	OnlineConfig.setPlaytime(packetInfo.playtime);
	OnlineConfig.setOpenboxtime(packetInfo.openbox_time);
	OnlineConfig.setOpenboxid(packetInfo.openbox_id);

    self:updateView(OnlineRoomSceneNew.s_cmds.client_get_openbox_time);   
    
end;

OnlineRoomController.onRecvClientMsgLeave = function(self, packetInfo)
    self:updateView(OnlineRoomSceneNew.s_cmds.client_msg_leave,packetInfo);
end;

OnlineRoomController.onRecvClientMsgChat = function(self, packetInfo)
    if self:isForbidSendMsg(packetInfo) then return end; 
    self:updateView(OnlineRoomSceneNew.s_cmds.client_msg_chat, packetInfo);
end;

OnlineRoomController.onRecvClientMsgHandicap = function(self, packetInfo)

    self:updateView(OnlineRoomSceneNew.s_cmds.client_msg_handicap, packetInfo);

end;


OnlineRoomController.onRecvClientMsgMove = function(self, packetInfo)

    self:updateView(OnlineRoomSceneNew.s_cmds.client_msg_move, packetInfo);

end;

OnlineRoomController.onRecvClientMsgDraw1 = function(self, packetInfo)

    self:updateView(OnlineRoomSceneNew.s_cmds.client_msg_draw1, packetInfo);

end; 


OnlineRoomController.onRecvClientMsgDraw2 = function(self, packetInfo)

    self:updateView(OnlineRoomSceneNew.s_cmds.client_msg_draw2, packetInfo);

end;


OnlineRoomController.onRecvClientMsgSurrender2 = function(self, packetInfo)

    self:updateView(OnlineRoomSceneNew.s_cmds.client_msg_surrender2, packetInfo);

end;


OnlineRoomController.onRecvServerMsgSurrender = function(self, packetInfo)

    self:updateView(OnlineRoomSceneNew.s_cmds.server_msg_surrender, packetInfo);

end;


OnlineRoomController.onRecvServerMsgDraw = function(self, packetInfo)
    self:updateView(OnlineRoomSceneNew.s_cmds.server_msg_draw, packetInfo);

end;


OnlineRoomController.onRecvClientMsgUndomove = function(self, packetInfo)
    self:updateView(OnlineRoomSceneNew.s_cmds.client_msg_undomove, packetInfo);

end;

OnlineRoomController.onRecvSetTimeInfo = function(self, packetInfo)
    self:updateView(OnlineRoomSceneNew.s_cmds.set_time_info, packetInfo);

end;

OnlineRoomController.onRecvServerClientMsgGameClose = function(self, packetInfo)
    
    self:updateView(OnlineRoomSceneNew.s_cmds.server_msg_gameclose, packetInfo);
    
end;


OnlineRoomController.onRecvServerMsgWarning = function(self, packetInfo)

    self:updateView(OnlineRoomSceneNew.s_cmds.server_msg_warning, packetInfo);

end;


OnlineRoomController.onRecvServerMsgTips  = function(self, packetInfo)

    self:updateView(OnlineRoomSceneNew.s_cmds.server_msg_tips, packetInfo);

end;

OnlineRoomController.onRecvCustomMsgLoginEnter = function(self, packetInfo)

    self:updateView(OnlineRoomSceneNew.s_cmds.custom_msg_login_room, packetInfo);

end;


OnlineRoomController.onRecvClientMsgHomepress = function(self, data)
    --服务器通知玩家按下了Home键
	print_string("Room.serverHomeEvent");
	if data and data.tid and data.time and data.uid then
		local tid = data.tid;
		local time = data.time;
		local uid = data.uid;
		print_string(string.format("Room.serverHomeEvent,tid = %d,time = %d,uid = %d",data.tid,data.time,data.uid));
		if data.tid ==  self.m_tid or data.uid ~= UserInfo.getInstance():getUid()  then
	
			if data.time > 0 then
				local msg = "对手暂时离开，请稍候..." ;
				RoomHomeScroll.play(self.m_view,msg,data.time);
			else
				RoomHomeScroll.close();
			end
		else
			print_string("Room.serverHomeEvent but not ");
		end
	end
end;


OnlineRoomController.onRecvClientMsgHeart = function(self)
    Log.i("OnlineRoomController.onRecvClientMsgHeart");
    self.m_heartbeat_time = 0;
end;

OnlineRoomController.onRecvClientWatchHeart = function(self)
    Log.i("OnlineRoomController.onRecvClientWatchHeart");
    self.m_heartbeat_time = 0;
end;

OnlineRoomController.onRecvClientWatchTrends = function(self, packetInfo)

Log.i("OnlineRoomController.onRecvWatchTrends");
    if not next(packetInfo) then
        return
    end;

    if packetInfo.subcmd == WATCH_SUB_LOGIN then
        self:updateView(OnlineRoomSceneNew.s_cmds.watcherCountChange,packetInfo.newUser);
    elseif packetInfo.subcmd == WATCH_SUB_LEAVE then
        self:updateView(OnlineRoomSceneNew.s_cmds.watcherCountChange,packetInfo.newUser);
    elseif packetInfo.subcmd == WATCH_MSG_LEAVE then
        self:updateView(OnlineRoomSceneNew.s_cmds.watchRoomUserLeave,packetInfo);
    elseif packetInfo.subcmd == WATCH_MSG_READY then
        self:updateView(OnlineRoomSceneNew.s_cmds.watchRoomReady,packetInfo);
    elseif packetInfo.subcmd == WATCH_MSG_GAME_START then
        self:updateView(OnlineRoomSceneNew.s_cmds.watchRoomStart,packetInfo);
    elseif packetInfo.subcmd == WATCH_MSG_GAME_CLOSE then
        self:updateView(OnlineRoomSceneNew.s_cmds.watchRoomClose,packetInfo);
    elseif packetInfo.subcmd == WATCH_MSG_MOVE then
        self:updateView(OnlineRoomSceneNew.s_cmds.watchRoomMove,packetInfo);
    elseif packetInfo.subcmd == WATCH_SUB_CHAT then
        self:updateView(OnlineRoomSceneNew.s_cmds.watcherChatMsg,packetInfo);
    elseif packetInfo.subcmd == WATCH_MSG_CHAT then
        self:updateView(OnlineRoomSceneNew.s_cmds.watchRoomPlayerChatMsg,packetInfo);
    elseif packetInfo.subcmd == WATCH_MSG_DRAW then
        self:updateView(OnlineRoomSceneNew.s_cmds.watchRoomDraw,packetInfo);
    elseif packetInfo.subcmd == WATCH_MSG_SURRENDER then
        self:updateView(OnlineRoomSceneNew.s_cmds.watchRoomSurrender,packetInfo);
    elseif packetInfo.subcmd == WATCH_MSG_UNDOMOVE then
        self:updateView(OnlineRoomSceneNew.s_cmds.watchRoomUndo,packetInfo);
    elseif packetInfo.subcmd == WATCH_MSG_WARING then
        self:updateView(OnlineRoomSceneNew.s_cmds.watchRoomWaring,packetInfo);
    else

    end;
end;


OnlineRoomController.onRecvClientWatchSynData = function(self, packetInfo)
    Log.i("onClientWatchLogin");
    self:sendSocketMsg(CLIENT_WATCH_USERLIST, nil,nil, 1);--获取观战人数
    if not next(packetInfo) then
        self:updateView(OnlineRoomSceneNew.s_cmds.updateWatchRoom, nil, "同步数据失败")
        UserInfo.getInstance():setTid(0);
        UserInfo.getInstance():setSeatID(0);
        UserInfo.getInstance():setGameType(GAME_TYPE_UNKNOW);
        UserInfo.getInstance():setStatus(STATUS_PLAYER_LOGOUT);
        return;
    end;
    self:updateView(OnlineRoomSceneNew.s_cmds.updateWatchRoom, packetInfo);
    
end;

OnlineRoomController.onRecvClientMsgLogin = function(self, packetInfo)
    
    if not next(packetInfo) then
        return;
    end;
    self:updateView(OnlineRoomSceneNew.s_cmds.client_msg_login, packetInfo);


end;

OnlineRoomController.onRecvClientMsgLoginSuccess = function(self, packetInfo)
    self:updateView(OnlineRoomSceneNew.s_cmds.client_user_login_succ, packetInfo);   
    --self:onSendReadyMsg();
end;

OnlineRoomController.onRecvServerMsgLoginError = function(self, packetInfo)
    self:updateView(OnlineRoomSceneNew.s_cmds.client_user_login_error, packetInfo);
end;

OnlineRoomController.onRecvServerMsgOtherError = function(self, packetInfo)
    self:updateView(OnlineRoomSceneNew.s_cmds.client_user_other_error, packetInfo);
end;

OnlineRoomController.onRecvClientMsgOppUserInfo = function(self, packetInfo)
    if not next(packetInfo) then
        return;
    end;
    self:updateView(OnlineRoomSceneNew.s_cmds.client_opp_user_login, packetInfo);    
end;


OnlineRoomController.onRecvServerMsgUserReady = function(self, packetInfo)
    if not next(packetInfo) then
        return;
    end;
    self:updateView(OnlineRoomSceneNew.s_cmds.server_msg_ready, packetInfo);    
end;

OnlineRoomController.onRecvServerMsgGameStart = function(self, packetInfo)
    self:updateView(OnlineRoomSceneNew.s_cmds.server_msg_gamestart, packetInfo);
end;

OnlineRoomController.onRecvServerMsgForestall = function(self, packetInfo)
   self:updateView(OnlineRoomSceneNew.s_cmds.server_msg_forestall, packetInfo); 
end;

OnlineRoomController.onRecvServerMsgForestallNew = function(self, packetInfo)
   self:updateView(OnlineRoomSceneNew.s_cmds.server_msg_forestall_new, packetInfo); 
end;

OnlineRoomController.onRecvServerMsgHandicap = function(self, packetInfo)
   self:updateView(OnlineRoomSceneNew.s_cmds.server_msg_handicap, packetInfo);
end;

OnlineRoomController.onRecvServerMsgHandicapResult = function(self, packetInfo)
   self:updateView(OnlineRoomSceneNew.s_cmds.server_msg_handicap_result, packetInfo); 

end;

OnlineRoomController.onRecvServerMsgTimeCountStart = function(self, packetInfo)

    self:updateView(OnlineRoomSceneNew.s_cmds.server_msg_timecount_start, packetInfo);

end;

OnlineRoomController.onRecvServerMsgReconnect = function(self, packetInfo)

    self:updateView(OnlineRoomSceneNew.s_cmds.server_msg_reconnect, packetInfo);

end;


OnlineRoomController.onRecvServerMsgUserLeave = function(self, packetInfo)
    self:updateView(OnlineRoomSceneNew.s_cmds.server_msg_user_leave, packetInfo);
end;

OnlineRoomController.onRecvServerMsgLogoutSuccess = function(self, packetInfo)
    
    self:updateView(OnlineRoomSceneNew.s_cmds.server_msg_logout_succ, packetInfo);

end;


OnlineRoomController.onRecvClientMsgComein = function(self, packetInfo) 

    if not next(packetInfo) then
        return;
    end;
	if packetInfo.mUserID  == UserInfo.getInstance():getUid() then 
		UserInfo.getInstance():setTid(packetInfo.tableID) ;
		UserInfo.getInstance():setSeatID(packetInfo.mSeatID) ;
		UserInfo.getInstance():setStatus(packetInfo.mUserStatus);
		UserInfo.getInstance():setFlag(packetInfo.mFlag);
	else
		print_string(string.format("mUserID != userInfo.uid mUserID = %d,userInfo.uid = %d",packetInfo.mUserID,UserInfo.getInstance():getUid()));
		return;
	end
    UserInfo.getInstance():setRank(packetInfo.rank1);
	UserInfo.getInstance():setMoney(packetInfo.coin1);
--    self:updateView(OnlineRoomSceneNew.s_cmds.client_user_comein, packetInfo);

end;


OnlineRoomController.onRecvClientMsgStart = function(self, packetInfo)  
    if not next(packetInfo) then
        return;
    end;
--    self:updateView(OnlineRoomSceneNew.s_cmds.client_msg_start, packetInfo);
end;


OnlineRoomController.onRecvClientMsgForestall = function(self, packetInfo) 
--    self:updateView(OnlineRoomSceneNew.s_cmds.client_msg_forestall, packetInfo);
end;

OnlineRoomController.onRecvClientMsgRelogin = function(self, packetInfo)

    	-- 元宝 
	UserInfo.getInstance():setBycoin(packetInfo.bycoin);
	-- 对手被强制悔棋获得金币数 
	UserInfo.getInstance():setOpponentgetCoin(packetInfo.opponentgetCoin);
	UserInfo.getInstance():setMaxOnlineUndoCount(packetInfo.Count)--一局棋最多悔棋次数 
	--当前悔棋次数要用到的元宝数
	UserInfo.getInstance():setUseBYCoinTb(packetInfo.useBYCoinTb);

    self:updateView(OnlineRoomSceneNew.s_cmds.client_msg_relogin, packetInfo);
end;

OnlineRoomController.onRecvClientRoomSyn = function(self, packetInfo)

    self:updateView(OnlineRoomSceneNew.s_cmds.client_msg_syndata, packetInfo);

end;

--hallSocket
OnlineRoomController.onRecvQuickStartMsg = function(self, packetInfo)
Log.i("OnlineRoomController.onRecvQuickStartMsg");

    UserInfo.getInstance():setRoomDomain(packetInfo.hostIP);
    UserInfo.getInstance():setRoomPort(packetInfo.port);
    UserInfo.getInstance():setGameType(packetInfo.gameType);
    -- UserInfo.getInstance():setMoneyType(moneyType);
    UserInfo.getInstance():setLtid(packetInfo.ltid);

end;

OnlineRoomController.onHallMsgLogin = function(self, packetInfo)
    Log.i("OnlineRoomController.onHallMsgLogin");
    UserInfo.getInstance():setTid(packetInfo.tid);
    if packetInfo.tid == 0 then
        ChessToastManager.getInstance():show("房间棋局已经结束", 5000);
        self:onBackAction();
    else
        self:sendSocketMsg(CLIENT_MSG_LOGIN,nil,nil,1);
    end; 
end;

OnlineRoomController.onRecvHallMsgGameInfo = function(self, packetInfo)
    Log.i("OnlineRoomController.onRecvHallMsgGameInfo");
    if not next(packetInfo) then
        self:updateView(OnlineRoomSceneNew.s_cmds.match_room_fail);
        return;
    end;
--    self:updateView(OnlineRoomSceneNew.s_cmds.match_room_success);
    self:onMatchSuccess();
end
--self.m_recent_data
OnlineRoomController.onRecvGetTableStep = function(self, info)
    Log.i("OnlineRoomController.onRecvHallMsgGameInfo");
--    info.total_count = self.m_socket:readShort(packetId,ERROR_NUMBER);
--    info.page_num = self.m_socket:readShort(packetId,ERROR_NUMBER);
--    info.curr_page = self.m_socket:readShort(packetId,ERROR_NUMBER);
--    info.item_num = self.m_socket:readShort(packetId,ERROR_NUMBER);
--    info.tab_step = {};
--    for i = 1,info.item_num do
--        info.tab_step[i].chessID = self.m_socket:readInt(packetId,ERROR_NUMBER);
--        info.tab_step[i].position1 = self.m_socket:readInt(packetId,ERROR_NUMBER);
--        info.tab_step[i].position2 = self.m_socket:readInt(packetId,ERROR_NUMBER);
--        info.tab_step[i].eat_chess = self.m_socket:readInt(packetId,ERROR_NUMBER);
--    end
    if info.curr_page == 0 and info.page_num > 0 then
        self.m_mvList = {};
    end

    if self.m_mvList and info.item_num then
        for i = 1,info.item_num do
            table.insert(self.m_mvList,info.tab_step[i]);
        end
    end

    if self.m_mvList and info.curr_page == info.page_num-1 then  --- info.curr_page = info.page_num = 0
        if self.m_recent_data then
            self:saveChessData(info.handicapschessman);
        end
        self.m_mvList = nil;
        self.m_recent_data = nil;
    end
end

OnlineRoomController.saveChessData = function(self,handicapschessman) -- 参数 handicapschessman 开局让子信息
    local uid = UserInfo.getInstance():getUid();
	local keys = GameCacheData.getInstance():getString(GameCacheData.RECENT_DAPU_KEY .. uid);
	local keys_table = lua_string_split(keys, GameCacheData.chess_data_key_split);
	local key;
    local time = os.time();
    key = "myRecentChessDataId_"..time;
    if #keys_table < UserInfo.getInstance():getSaveChessManualLimit() then
        table.insert(keys_table,1, key);
    elseif #keys_table == UserInfo.getInstance():getSaveChessManualLimit() then
        table.remove(keys_table,#keys_table);
        table.insert(keys_table,1, key);
    else
        while #keys_table > UserInfo.getInstance():getSaveChessManualLimit() do
            table.remove(keys_table,#keys_table);    
        end;
    end

	local index = os.date("-%x-%X",os.time());
    local mvData = self.m_recent_data;
    mvData.id = time;
    mvData.fileName = "棋局回放"..index;
    local mvList = {};
    for i,v in ipairs(self.m_mvList) do
        mvList[i] = Board.data2mv(nil,v);
    end
    local chess_map = CombineTables(red_down_game90);
    if handicapschessman > 0 then 
        for i,v in ipairs(chess_map) do
            if v == handicapschessman then
                chess_map[i] = NOCHESS;
            end
        end
--    else
--        mvData.start_fen = Postion.STARTUP_FEN[1];
    end
    mvData.chessString = table.concat(chess_map,MV_SPLIT)
    mvData.start_fen = Board.toFen(chess_map,true);
    mvData.move_list = table.concat(mvList,GameCacheData.chess_data_key_split);
    -- 结算收藏需要棋谱参数
    self.m_view.m_mvData = mvData;
    local mvData_str = json.encode(mvData);
    print_string("mvData_str = " .. mvData_str);
	GameCacheData.getInstance():saveString(GameCacheData.RECENT_DAPU_KEY .. uid,table.concat(keys_table,GameCacheData.chess_data_key_split));
	GameCacheData.getInstance():saveString(key .. uid,mvData_str);
end

--------------------------------http---------------------------------

OnlineRoomController.onHttpGetOnlineRewardCallBack = function(self, flag, message)
    Log.i("OnlineRoomController.onHttpGetOnlineRewardCallBack");
    if not flag then
        return;

    end;
	local data = message.data;

	if not data then
		return;
	end
	
	local retdata = {};
	retdata.flag =  tonumber(data.flag:get_value()); --:领取状态（-1在玩时间校验失败，0领奖失败，1成功，-2重复领取）

	retdata.msg =  data.msg:get_value() or "";
	retdata.playtime =  tonumber(data.playtime:get_value());
	retdata.openbox_id =  tonumber(data.openbox_id:get_value());
	retdata.openbox_time =  tonumber(data.openbox_time:get_value());

	local money = tonumber(data.reward.money:get_value());
	local soul = tonumber(data.reward.soul:get_value());
		-- local proplist = Json.decode(orderData);
	local proplist = data.reward.props;
	if proplist and #proplist>0 then
		local payLogs = {};

		for _,value in pairs(proplist) do 
			if value then
				local paylog = {};
				if value.pid then
					paylog.pid = value.pid:get_value();
					-- print_string("======paylog.pid==========="..paylog.pid);
				end
				if value.propid then
					paylog.propid = tonumber(value.propid:get_value()) or 0;
					-- print_string("======paylog.propid==========="..paylog.propid);
				end
				if value.num then
					paylog.num = tonumber(value.num:get_value()) or 0;
					-- print_string("======paylog.num==========="..paylog.num);
				end
				table.insert(payLogs,paylog);				
			end
		end

		if #payLogs >0 then
            self:updateView(OnlineRoomSceneNew.s_cmds.update_prop_info, payLogs);
--			EventDispatcher.getInstance():dispatch(Event.Call, PROP_BUDAN_EVENT,payLogs);
		end
	end

	UserInfo.getInstance():setSoulCount(soul);
    local oldMoney = UserInfo.getInstance():getMoney();
    retdata.changeMoney = 0;
    if money then
        retdata.changeMoney = money - oldMoney;
    end
	UserInfo.getInstance():setMoney(money);

	OnlineConfig.setPlaytime(retdata.playtime);
	OnlineConfig.setOpenboxtime(retdata.openbox_time);
	OnlineConfig.setOpenboxid(retdata.openbox_id);

    self:updateView(OnlineRoomSceneNew.s_cmds.client_get_openbox_time, retdata);
end;

OnlineRoomController.onHttpGetTaskProgressCallBack = function(self, flag, message)
    Log.i("OnlineRoomController.onHttpGetTaskProgressCallBack");
	print_string("PHPInterface.getTaskProgressCallBack.onSuccessed");
    if not flag then
        return;

    end;
	if not HttpModule.explainPHPFlag(message) then
		return;
	end
	local data = message.data;

	if not data and not data:get_value() then
		print_string("not data");
		return
	end
    UserInfo.getInstance():setActionSwitch(1);
    local message = "任务" .. data .. "已达成！";
	ChatMessageAnim.play(self.m_view,3,message);
end;

OnlineRoomController.onSaveChessCallBack = function(self, flag, message)
    if not flag then
        if type(message) == "number" then
            return; 
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
            return;
        end;        
    end;
    local data = json.analyzeJsonNode(message.data);
    self:updateView(OnlineRoomSceneNew.s_cmds.save_mychess,data);
end;


OnlineRoomController.onIndexGetNotice = function(self,isSuccess,message)
    -- 屏蔽公告
end


OnlineRoomController.onNativeEnterCustomRoomFail = function(self, info)
    Log.i("OnlineRoomController.onNativeEnterCustomRoomFail");
    self:updateView(OnlineRoomSceneNew.s_cmds.enter_customroom_fail,info);
end;

OnlineRoomController.onNativeNetStateChange = function(self, flag, data)
    if not flag or not data then
        return;
    end;
    local netlevel = data.netState:get_value();
    Log.i("OnlineRoomController.onNativeNetStateChange---->"..data.netState:get_value());
    local numNetLevel = tonumber(netlevel);
    if numNetLevel then
        if numNetLevel ~= 5 then
            if not self.m_hallSocket:isSocketOpen()  then
                self.m_hallSocket:openSocket(ServerConfig.getInstance():getHallIpPort());
            end;            
        else 
        end;
    end;
    self:updateView(OnlineRoomSceneNew.s_cmds.show_net_state, data.netState:get_value());
end;

OnlineRoomController.onBoardUnlegalMove = function(self, code)
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

OnlineRoomController.onDownLoadImage = function(self , flag,json_data)
	if not json_data then
		return;
	end

	local info = json.analyzeJsonNode(data);
	self:updateView(OnlineRoomScene.s_cmds.updataUserIcon,info.ImageName,tonumber(info.what));
end


OnlineRoomController.onRecvServerEntryChatRoom = function(self,packetInfo)
    if self.m_view.m_chat_dialog then
        self.m_view.m_chat_dialog:isEntryChatRoom(packetInfo);
    end
end

OnlineRoomController.onRecvServerUserMsg = function(self,packetInfo)
    if self.m_view.m_chat_dialog then
        self.m_view.m_chat_dialog:onRecvServerUserMsg(packetInfo);
    end
end

OnlineRoomController.onRecvServerChatMsg = function(self,packetInfo)
    if self.m_view.m_chat_dialog then
        self.m_view.m_chat_dialog:onRecvServerChatMsg(packetInfo);
    end
end

OnlineRoomController.onReceChatMsgState = function(self,packetInfo)
    if self:isForbidSendMsg(packetInfo) then return end;
    if self.m_view.m_chat_dialog then
        self.m_view.m_chat_dialog:onReceChatMsgState(packetInfo);
    end
end

OnlineRoomController.onRecvServerUnreadMsg = function(self,packetInfo)
    if self.m_view.m_chat_dialog then
        self.m_view.m_chat_dialog:onRecvServerUnreadMsg(packetInfo);
    end
end

OnlineRoomController.onRecvServerRoomKickOutUser = function(self,packetInfo)
    ChessToastManager.getInstance():show("您被房主请出了房间");
    self:onClientMsgLogout();
    self:onBackAction();
end

OnlineRoomController.onRecvServerCallTelphoneResponse = function(self,packetInfo)
--    ChessToastManager.getInstance():show("进入后台了:"..packetInfo.wait_time);
--    self:updateView(OnlineRoomSceneNew.s_cmds.callTelphoneResponse,packetInfo.wait_time);
end

OnlineRoomController.onRecvServerCallTelphoneBack = function(self,packetInfo)
--    self:updateView(OnlineRoomSceneNew.s_cmds.callTelphoneBack);
--    ChessToastManager.getInstance():show("进入前台了");
--    self:onSynRoomData();
end

OnlineRoomController.onRecvServerBroadcastUserDisconnect = function(self,packetInfo)
    if packetInfo and packetInfo.uid then
        self:updateView(OnlineRoomSceneNew.s_cmds.setDisconnect,packetInfo.uid,true);
    end
end

OnlineRoomController.onRecvServerBroadcastUserReconnect = function(self,packetInfo)
    if packetInfo and packetInfo.uid then
        self:updateView(OnlineRoomSceneNew.s_cmds.setDisconnect,packetInfo.uid,false);
    end
end
--------------------------------config-------------------------------

OnlineRoomController.s_cmdConfig = 
{
	[OnlineRoomController.s_cmds.back_action]		        = OnlineRoomController.onBackAction;
    [OnlineRoomController.s_cmds.start_watch]               = OnlineRoomController.onStartWatch;
    [OnlineRoomController.s_cmds.end_watch]                 = OnlineRoomController.onEndWatch;
    [OnlineRoomController.s_cmds.start_customroom]	        = OnlineRoomController.onStartCustom;
    [OnlineRoomController.s_cmds.syn_watch_data]	        = OnlineRoomController.onSynWatchData;
    [OnlineRoomController.s_cmds.send_watch_chat]	        = OnlineRoomController.onSendWatchChat;
    [OnlineRoomController.s_cmds.hall_quick_start]	        = OnlineRoomController.onHallQuickStart;
    [OnlineRoomController.s_cmds.hall_game_info]	        = OnlineRoomController.onHallGameInfo;
    [OnlineRoomController.s_cmds.hall_cancel_match]	        = OnlineRoomController.onHallCancelMatch;
    [OnlineRoomController.s_cmds.client_msg_start]	        = OnlineRoomController.onClientMsgStart;
    [OnlineRoomController.s_cmds.client_msg_forestall]	    = OnlineRoomController.onClientMsgForestall;
    [OnlineRoomController.s_cmds.syn_room_data]	            = OnlineRoomController.onSynRoomData;
    [OnlineRoomController.s_cmds.client_msg_watchlist]      = OnlineRoomController.onClientMsgWatchlist;
    [OnlineRoomController.s_cmds.client_get_openbox_time]   = OnlineRoomController.onClientGetOpenboxTime;
    [OnlineRoomController.s_cmds.client_msg_login]          = OnlineRoomController.onClientMsgLogin;
    [OnlineRoomController.s_cmds.send_ready_msg]            = OnlineRoomController.onSendReadyMsg;
    [OnlineRoomController.s_cmds.client_msg_logout]         = OnlineRoomController.onClientMsgLogout;
    [OnlineRoomController.s_cmds.client_msg_offline]        = OnlineRoomController.onClientMsgOffline;

    [OnlineRoomController.s_cmds.server_msg_forestall]      = OnlineRoomController.onServerMsgForestall;
    [OnlineRoomController.s_cmds.server_msg_forestall_new]  = OnlineRoomController.onServerMsgForestallNew;
    [OnlineRoomController.s_cmds.server_msg_handicap]       = OnlineRoomController.onServerMsgHandicap;







    [OnlineRoomController.s_cmds.client_msg_leave]          = OnlineRoomController.onClientMsgLeave;
    [OnlineRoomController.s_cmds.client_msg_chat]           = OnlineRoomController.onClientMsgChat;
    [OnlineRoomController.s_cmds.client_msg_handicap]       = OnlineRoomController.onClientMsgHandicap;
    [OnlineRoomController.s_cmds.client_msg_comein]         = OnlineRoomController.onClientMsgComein;
    [OnlineRoomController.s_cmds.client_msg_move]           = OnlineRoomController.onClientMsgMove;
--    [OnlineRoomController.s_cmds.close_room_socket]         = OnlineRoomController.onCloseRoomSocket;
    [OnlineRoomController.s_cmds.room_get_reward]           = OnlineRoomController.onRoomGetOnlineReward;
    [OnlineRoomController.s_cmds.client_msg_draw1]          = OnlineRoomController.onClientMsgDraw1;
    [OnlineRoomController.s_cmds.client_msg_draw2]          = OnlineRoomController.onClientMsgDraw2;
    [OnlineRoomController.s_cmds.client_msg_undomove]       = OnlineRoomController.onClientMsgUndomove;
    [OnlineRoomController.s_cmds.client_msg_surrender1]     = OnlineRoomController.onClientMsgSurrender1;
    [OnlineRoomController.s_cmds.client_msg_surrender2]     = OnlineRoomController.onClientMsgSurrender2;
    [OnlineRoomController.s_cmds.get_task_progress]         = OnlineRoomController.onGetTaskProgress;

    [OnlineRoomController.s_cmds.open_room_socket]          = OnlineRoomController.onOpenRoomSocket;

    [OnlineRoomController.s_cmds.invit_request]             = OnlineRoomController.onInviteRequest;
    [OnlineRoomController.s_cmds.invit_response]            = OnlineRoomController.onInviteResponse;
    [OnlineRoomController.s_cmds.set_time_finish]           = OnlineRoomController.onSetTimeFinish;
    [OnlineRoomController.s_cmds.set_time_response]         = OnlineRoomController.onSetTimeResponse;

    [OnlineRoomController.s_cmds.client_add]                = OnlineRoomController.onClientAdd;
    [OnlineRoomController.s_cmds.save_recent_chess_data]    = OnlineRoomController.saveRecentChessData;
    [OnlineRoomController.s_cmds.server_cmd_kick_player]    = OnlineRoomController.onServerCmdKickPlayer;
    [OnlineRoomController.s_cmds.sharePicture]              = OnlineRoomController.sharePicture;
    [OnlineRoomController.s_cmds.save_mychess]		        = OnlineRoomController.onSaveMychess;
}


--响应socket响应事件
OnlineRoomController.s_socketCmdFuncMap = {
    [CLIENT_WATCH_LOGIN]            = OnlineRoomController.onClientWatchLogin;
    [CLIENT_WATCH_USERLIST]         = OnlineRoomController.onRecvClientWatchUserlist;
    [CLIENT_WATCH_TRENDS]           = OnlineRoomController.onRecvClientWatchTrends;
    [CLIENT_WATCH_SYNCHRODATA]      = OnlineRoomController.onRecvClientWatchSynData;
    [CLIENT_MSG_LOGIN]              = OnlineRoomController.onRecvClientMsgLogin;
    [SERVER_MSG_LOGIN_SUCCESS]      = OnlineRoomController.onRecvClientMsgLoginSuccess;
    [SERVER_MSG_LOGIN_ERROR]        = OnlineRoomController.onRecvServerMsgLoginError;
    [SERVER_MSG_OTHER_ERROR]        = OnlineRoomController.onRecvServerMsgOtherError;
    [SERVER_MSG_OPP_USER_INFO]      = OnlineRoomController.onRecvClientMsgOppUserInfo;
    [SERVER_MSG_USER_READY]         = OnlineRoomController.onRecvServerMsgUserReady;
    [SERVER_MSG_GAME_START]         = OnlineRoomController.onRecvServerMsgGameStart;
    [SERVER_MSG_FORESTALL]          = OnlineRoomController.onRecvServerMsgForestall;
    [SERVER_MSG_FORESTALL_NEW]      = OnlineRoomController.onRecvServerMsgForestallNew;
    [SERVER_MSG_HANDICAP]           = OnlineRoomController.onRecvServerMsgHandicap;
    [SERVER_MSG_HANDICAP_RESULT]    = OnlineRoomController.onRecvServerMsgHandicapResult;
    [SERVER_MSG_TIMECOUNT_START]    = OnlineRoomController.onRecvServerMsgTimeCountStart;
    [SERVER_MSG_RECONNECT]          = OnlineRoomController.onRecvServerMsgReconnect;
    [SERVER_MSG_USER_LEAVE]         = OnlineRoomController.onRecvServerMsgUserLeave;
    [SERVER_MSG_LOGOUT_SUCCESS]     = OnlineRoomController.onRecvServerMsgLogoutSuccess;



    --观战
    [CLIENT_WATCH_JOIN]             = OnlineRoomController.onRecvClientWatchJoin;
    [SERVER_WATCH_START]            = OnlineRoomController.onRecvServerWatchStart;
    [SERVER_WATCH_MOVE]             = OnlineRoomController.onRecvServerWatchMove;
    [SERVER_WATCH_DRAW]             = OnlineRoomController.onRecvServerWatchDraw;
    [SERVER_WATCH_SURRENDER]        = OnlineRoomController.onRecvServerWatchSurrender;
    [SERVER_WATCH_UNDO]             = OnlineRoomController.onRecvServerWatchUndo;
    [SERVER_WATCH_USERLEAVE]        = OnlineRoomController.onRecvServerWatchUserLeave; 
    [SERVER_WATCH_GAMEOVER]         = OnlineRoomController.onRecvServerWatchGameOver;
    [SERVER_WATCH_ALLREADY]         = OnlineRoomController.onRecvServerWatchAllReady;
    [SERVER_WATCH_ERROR]            = OnlineRoomController.onRecvServerWatchError;
    [CLIENT_WATCH_CHAT]             = OnlineRoomController.onRecvClientWatchChat;


    --好友房
    [FRIEND_CMD_FRIEND_INVITE_REQUEST] = OnlineRoomController.onRecvServerInvitRequest;     --发起好友邀请请求;
    [FRIEND_CMD_FRIEND_INVIT_RESPONSE] = OnlineRoomController.onRecvServerInvitResponse;    --另一方回复结果;
    [CLIIENT_CMD_RESET_TABLE]          = OnlineRoomController.onRecvServerResetTable;    --重置房间状态;
    [FRIEND_CMD_FRIEND_INVIT_NOTIFY]   =  OnlineRoomController.onInvitNotify;   --好友挑战邀请通知
    --设置局时
    [SERVER_BROADCAST_SET_TIME]             = OnlineRoomController.onRecvServerSetTime;     --设置局时
    [SERVER_BROADCAST_SET_TIME_NOTIFY]      = OnlineRoomController.onRecvServerSetTimeNotify; --设置局时通知
    [SERVER_BROADCAST_SET_TIME_RESPONSE]    = OnlineRoomController.onRecvServerSetTimeResponse; --设置局时回复通知

    --好友观战
    [OB_CMD_CHAT_MSG]               = OnlineRoomController.onRecvServerNewWatchMsg;              --观战聊天（读写）
    [OB_CMD_GET_TABLE_INFO]         = OnlineRoomController.onRecvServerNewTableInfo;              --获取桌子信息(读写)
    [OB_CMD_GET_OB_LIST]            = OnlineRoomController.onRecvServerNewWatchList;              --获取观战列表（读写）
    [OB_CMD_PLAYER_ENTER]           = OnlineRoomController.onRecvServerNewPlayerEnter;              --广播玩家进入（读）
    [OB_CMD_PLAYER_LEAVE]           = OnlineRoomController.onRecvServerNewPlayerLeave;              --广播玩家离开(读)
    [OB_CMD_UPDATE_TABLE_STATUS]    = OnlineRoomController.onRecvServerNewUpdateTable;              --同步更新桌子状态（）
    [OB_CMD_GAMESTART]              = OnlineRoomController.onRecvServerNewGameStart;              --游戏开始（读） 
    [OB_CMD_CHESS_MOVE]             = OnlineRoomController.onRecvServerNewChessMove;              --广播走棋（读）
    [OB_CMD_CHESS_UNDOMOVE]         = OnlineRoomController.onRecvServerNewChessUndo;              --悔棋（读）
    [OB_CMD_CHESS_DRAW]             = OnlineRoomController.onRecvServerNewChessDraw;              --求和（读）
    [OB_CMD_CHESS_SURRENDER]        = OnlineRoomController.onRecvServerNewChessSurrender;              --认输（读）
    [OB_CMD_GAMEOVER]               = OnlineRoomController.onRecvServerNewGameOver;              --游戏结束（读）
    [OB_CMD_GET_NUM]                = OnlineRoomController.onRecvServerNewGetNumber;              --观战人数（读写）

--    [FRIEND_CMD_ADD_FLLOW]          = OnlineRoomController.onRecvServerAddFllow;                --添加或取消关注

    [CLIENT_MSG_COMEIN]             = OnlineRoomController.onRecvClientMsgComein;
    [CLIENT_MSG_START]              = OnlineRoomController.onRecvClientMsgStart;
    [CLIENT_MSG_FORESTALL]          = OnlineRoomController.onRecvClientMsgForestall;
    [CLIENT_MSG_RELOGIN]            = OnlineRoomController.onRecvClientMsgRelogin;
    [CLIENT_MSG_SYNCHRODATA]        = OnlineRoomController.onRecvClientRoomSyn;
    [CLIENT_MSG_WATCHLIST]          = OnlineRoomController.onRecvClientMsgWatchlist;
    [CLIENT_GET_OPENBOX_TIME]       = OnlineRoomController.onRecvClientGetOpenboxTime;
    [CLIENT_MSG_LEAVE]              = OnlineRoomController.onRecvClientMsgLeave;
    [CLIENT_MSG_CHAT]               = OnlineRoomController.onRecvClientMsgChat;
    [CLIENT_MSG_HANDICAP]           = OnlineRoomController.onRecvClientMsgHandicap;
    [CLIENT_MSG_MOVE]               = OnlineRoomController.onRecvClientMsgMove;

    [CLIENT_MSG_DRAW1]              = OnlineRoomController.onRecvClientMsgDraw1;
    [CLIENT_MSG_DRAW2]              = OnlineRoomController.onRecvClientMsgDraw2;
    [SERVER_MSG_DRAW]               = OnlineRoomController.onRecvServerMsgDraw;
    [CLIENT_MSG_UNDOMOVE]           = OnlineRoomController.onRecvClientMsgUndomove;
    [SET_TIME_INFO]                 = OnlineRoomController.onRecvSetTimeInfo;

    [CLIENT_MSG_SURRENDER2]         = OnlineRoomController.onRecvClientMsgSurrender2;
    [SERVER_MSG_SURRENDER]          = OnlineRoomController.onRecvServerMsgSurrender;

--    [SERVER_MSG_GAME_START]         = OnlineRoomController.onRecvServerClientMsgGameStart;
    [SERVER_MSG_GAME_CLOSE]         = OnlineRoomController.onRecvServerClientMsgGameClose;
    [SERVER_MSG_WARING]             = OnlineRoomController.onRecvServerMsgWarning;
    [SERVER_MSG_TIPS]               = OnlineRoomController.onRecvServerMsgTips;
    [CUSTOMROOM_MSG_LOGIN_ENTER]    = OnlineRoomController.onRecvCustomMsgLoginEnter;
    [CLIENT_MSG_HOMEPRESS]          = OnlineRoomController.onRecvClientMsgHomepress;

    [CLIENT_MSG_HEART]              = OnlineRoomController.onRecvClientMsgHeart;

    [CLIENT_WATCH_HEART]            = OnlineRoomController.onRecvClientWatchHeart;


    --房间内用大厅socket拉取匹配信息...
    [HALL_MSG_QUICKSTART]           = OnlineRoomController.onRecvQuickStartMsg;  
    [HALL_MSG_LOGIN]                = OnlineRoomController.onHallMsgLogin;  
    [HALL_MSG_GAMEINFO]             = OnlineRoomController.onRecvHallMsgGameInfo;

    -- 拉取房间走法
    [CLIENT_CMD_GETTABLESTEP]       = OnlineRoomController.onRecvGetTableStep;


    
    
    [FRIEND_CMD_CHAT_MSG]              = OnlineRoomController.onReceChatMsgState;
    [CHATROOM_CMD_USER_CHAT_MSG]       = OnlineRoomController.onRecvServerUserMsg;
    [CHATROOM_CMD_BROAdCAST_CHAT_MSG]  = OnlineRoomController.onRecvServerChatMsg;
    [CHATROOM_CMD_ENTER_ROOM]          = OnlineRoomController.onRecvServerEntryChatRoom;
	[CHATROOM_CMD_GET_HISTORY_MSG]     = OnlineRoomController.onRecvServerUnreadMsg;
    [SERVER_CMD_ROOM_KICK_OUT_USER]    = OnlineRoomController.onRecvServerRoomKickOutUser;
    [CLIENT_CMD_CALLTELPHONERESPONSE]  = OnlineRoomController.onRecvServerCallTelphoneResponse;
    [CLIENT_CMD_CALLTELPHONEBACK]      = OnlineRoomController.onRecvServerCallTelphoneBack;
    
    [SERVER_BROADCAST_USER_DISCONNECT]      = OnlineRoomController.onRecvServerBroadcastUserDisconnect;
    [SERVER_BROADCAST_USER_RECONNECT]       = OnlineRoomController.onRecvServerBroadcastUserReconnect;
}

OnlineRoomController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	OnlineRoomController.s_socketCmdFuncMap or {});




OnlineRoomController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.getOnlineReward] = OnlineRoomController.onHttpGetOnlineRewardCallBack;
    [HttpModule.s_cmds.getTaskProgress] = OnlineRoomController.onHttpGetTaskProgressCallBack;
    [HttpModule.s_cmds.saveMychess]     = OnlineRoomController.onSaveChessCallBack;
--    [HttpModule.s_cmds.IndexGetNotice]  = OnlineRoomController.onIndexGetNotice;
};

OnlineRoomController.s_httpRequestsCallBackFuncMap = CombineTables(RoomController.s_httpRequestsCallBackFuncMap,
	OnlineRoomController.s_httpRequestsCallBackFuncMap or {});



OnlineRoomController.s_nativeEventFuncMap = {
                    
    [ONLINE_ENTER_CUSTOMROOM_FAIL] = OnlineRoomController.onNativeEnterCustomRoomFail;
    [kNetStateChange]              = OnlineRoomController.onNativeNetStateChange;
    [Board.UNLEGALMOVE]            = OnlineRoomController.onBoardUnlegalMove;
    [kCacheImageManager]           = OnlineRoomController.onDownLoadImage;
    [kFriend_FollowCallBack]       = OnlineRoomController.onRecvServerAddFllow;
};
OnlineRoomController.s_nativeEventFuncMap = CombineTables(RoomController.s_nativeEventFuncMap,
	OnlineRoomController.s_nativeEventFuncMap or {});



