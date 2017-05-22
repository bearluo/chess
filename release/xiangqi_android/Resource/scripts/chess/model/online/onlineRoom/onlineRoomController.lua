
require("config/path_config");

require(MODEL_PATH.."room/roomController");
--require(MODEL_PATH.."giftModule/giftModuleController");

OnlineRoomController = class(RoomController);

OnlineRoomController.s_cmds = 
{	
    back_action                     = 1;
    start_watch                     = 2;
    syn_watch_data                  = 3;
    send_watch_chat                 = 4;
    hall_game_info                  = 5;
    hall_cancel_match               = 6;
    syn_room_data                   = 7;
    client_msg_watchlist            = 8;
    client_get_openbox_time         = 9;
    client_msg_chat                 = 11;
    client_msg_move                 = 12;
    room_get_reward                 = 13;
    client_msg_draw1                = 14;
    client_msg_draw2                = 15;
    client_msg_undomove             = 16;
    client_msg_surrender1           = 17;
    client_msg_surrender2           = 18;
    client_msg_login                = 19;
    send_ready_msg                  = 20;
    client_msg_logout               = 21;
    client_msg_offline              = 22;
    server_msg_forestall            = 23;
    server_msg_handicap             = 24;
    invit_request                   = 25;
    set_time_finish                 = 26;
    set_time_response               = 27;
    client_add                      = 28;
    server_msg_forestall_new        = 29;
    invit_response                  = 30;
    save_recent_chess_data          = 31;
    sharePicture                    = 32;
    save_mychess                    = 33;
    start_customroom                = 34;
    server_cmd_kick_player          = 35;
    get_private_room_info           = 36;
    send_custom_stranger_invite     = 37;
    save_chess_and_share            = 38;
    server_msg_forestall_320        = 39;
};

OnlineRoomController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end

OnlineRoomController.resume = function(self)
    RoomController.resume(self);
end

OnlineRoomController.pause = function(self)
    RoomController.pause(self);
end

OnlineRoomController.dtor = function(self)
    if self.m_forbid_dialog then
        delete(self.m_forbid_dialog);
        self.m_forbid_dialog = nil;
    end

end

OnlineRoomController.onBack = function(self)
    self:updateView(OnlineRoomSceneNew.s_cmds.exit_room);
end

function OnlineRoomController.getSceneModule(self)
    return self.m_view.mModule;
end

----------------------------------function---------------------------------


--玩家返回游戏通知对手
OnlineRoomController.onEventResume = function(self)
    ChessController.onEventResume()
	print_string("Room.onHomeResume");
	local roomType = RoomProxy.getInstance():getCurRoomType();
--	local status = UserInfo.getInstance():getStatus();
	if roomType == RoomConfig.ROOM_TYPE_WATCH_ROOM then
		return;
	end

	if roomType == RoomConfig.ROOM_TYPE_MONEY_MATCH_ROOM then
        local mModule = self:getSceneModule();
        if mModule and mModule.onEventResume then
            mModule:onEventResume();
        end
		return
	end

    self:updateView(OnlineRoomSceneNew.s_cmds.resume_from_homekey)
end

--玩家在游戏过程中按下Home键通知对手
OnlineRoomController.onEventPause = function(self)
    ChessController.onEventPause();
	print_string("Room.onHomePause");
	local gametype = RoomProxy.getInstance():getCurRoomType();
	if roomType == RoomConfig.ROOM_TYPE_WATCH_ROOM then
		return;
	end
end

OnlineRoomController.sendSocketMsg = function(self,cmd,info,subcmd, writeType, socketType)
   self.m_hallSocket:sendMsg(cmd,info,subcmd, writeType); 
end

OnlineRoomController.s_switch_func = nil

OnlineRoomController.onBackAction = function(self)
    if type(OnlineRoomController.s_switch_func) == "function" then
        local func = OnlineRoomController.s_switch_func
        OnlineRoomController.s_switch_func = nil
        func()
    else
        StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
    end
end

OnlineRoomController.onStartWatch = function(self)
    self:sendSocketMsg(CLIENT_MSG_LOGIN, 1,nil,1);
end

OnlineRoomController.onStartCustom = function(self)
    self:sendSocketMsg(CLIENT_MSG_LOGIN, nil,nil,1);
end

OnlineRoomController.onRecvServerWatchStart = function(self, packetInfo)
    local mModule = self:getSceneModule();
    if mModule and mModule.onWatchRoomStart then
        mModule.onWatchRoomStart(mModule,packetInfo);
    end
end


OnlineRoomController.onRecvServerWatchMove = function(self, packetInfo)
    local mModule = self:getSceneModule();
    if mModule and mModule.onWatchRoomMove then
        mModule.onWatchRoomMove(mModule,packetInfo);
    end
end

OnlineRoomController.onRecvServerWatchDraw = function(self, packetInfo)
    local mModule = self:getSceneModule();
    if mModule and mModule.onWatchRoomDraw then
        mModule.onWatchRoomDraw(mModule,packetInfo);
    end
end

OnlineRoomController.onRecvServerWatchSurrender = function(self, packetInfo)
    local mModule = self:getSceneModule();
    if mModule and mModule.onWatchRoomSurrender then
        mModule.onWatchRoomSurrender(mModule,packetInfo);
    end
end

OnlineRoomController.onRecvServerWatchUndo = function(self, packetInfo)
    local mModule = self:getSceneModule();
    if mModule and mModule.onWatchRoomUndo then
        mModule.onWatchRoomUndo(mModule,packetInfo);
    end
end

OnlineRoomController.onRecvServerWatchUserLeave = function(self, packetInfo)
    local mModule = self:getSceneModule();
    if mModule and mModule.onWatchRoomUserLeave then
        mModule.onWatchRoomUserLeave(mModule,packetInfo);
    end    
end

OnlineRoomController.onRecvServerWatchGameOver = function(self, packetInfo)
    local mModule = self:getSceneModule();
    if mModule and mModule.onWatchRoomClose then
        mModule.onWatchRoomClose(mModule,packetInfo);
    end  
end

OnlineRoomController.onRecvServerWatchAllReady = function(self, packetInfo)
    local mModule = self:getSceneModule();
    if mModule and mModule.onWatchRoomAllReady then
        mModule.onWatchRoomAllReady(mModule,packetInfo);
    end 
end

OnlineRoomController.onRecvServerWatchError = function(self, packetInfo)
    local mModule = self:getSceneModule();
    if mModule and mModule.onWatchRoomError then
        mModule.onWatchRoomError(mModule,packetInfo);
    end 
end

OnlineRoomController.onRecvClientWatchChat = function(self, packetInfo)
    local mModule = self:getSceneModule();
    if mModule and mModule.onWatcherChatMsg then
        mModule.onWatcherChatMsg(mModule,packetInfo);
    end 
end

OnlineRoomController.sharePicture = function(self)
    Log.i("OnlineRoomController.onShareAction");
    dict_set_string(kTakeScreenShot , kTakeScreenShot .. kparmPostfix , "egame_share");
    call_native(kTakeScreenShot);
end


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
    local mModule = self:getSceneModule();
    if mModule and mModule.onWatchRoomMsg then
        mModule.onWatchRoomMsg(mModule,packetInfo);
    end
end

OnlineRoomController.onRecvServerNewTableInfo = function(self,packetInfo)
    --和老接口一样
    Log.i("onClientWatchLogin");
    local mModule = self:getSceneModule();
    if not packetInfo then
        if mModule and mModule.onUpdateWatchRoom then
            mModule.onUpdateWatchRoom(mModule,nil, "进入观战棋局失败，请刷新后选择其他棋局进行观战");
        end
        return;
    end;
    if mModule and mModule.onUpdateWatchRoom then
        mModule.onUpdateWatchRoom(mModule,packetInfo);
    end
    local info = {};
    info.tid = RoomProxy.getInstance():getTid();
    self:sendSocketMsg(OB_CMD_GET_NUM, info,nil,1);
end


OnlineRoomController.onRecvServerNewPlayerEnter = function(self,packetInfo)
    local mModule = self:getSceneModule();
    if mModule and mModule.onWatchRoomUserEnter then
        mModule.onWatchRoomUserEnter(mModule,packetInfo);
    end 
end

OnlineRoomController.onRecvServerNewPlayerLeave = function(self,packetInfo)
    --和老接口一样
    local mModule = self:getSceneModule();
    if mModule and mModule.onWatchRoomUserLeave then
        mModule.onWatchRoomUserLeave(mModule,packetInfo);
    end  
end

OnlineRoomController.onRecvServerNewUpdateTable = function(self,packetInfo)
    local mModule = self:getSceneModule();
    if mModule and mModule.onWatchRoomUpdateTable then
        mModule.onWatchRoomUpdateTable(mModule,packetInfo);
    end
end

OnlineRoomController.onRecvServerNewGameStart = function(self,packetInfo)
    --和老接口一样
    local mModule = self:getSceneModule();
    if mModule and mModule.onWatchRoomStart then
        mModule.onWatchRoomStart(mModule,packetInfo);
    end
    -- 观战 获取开局时间
    RoomProxy.getInstance():sendGetRoomStartTimeCmd()
end

OnlineRoomController.onRecvServerNewChessMove = function(self,packetInfo)
    --和老接口不一样，少了个观战人数，不影响
    local mModule = self:getSceneModule();
    if mModule and mModule.onWatchRoomMove then
        mModule.onWatchRoomMove(mModule,packetInfo);
    end
    local info = {};
    info.tid = RoomProxy.getInstance():getTid();
    self:sendSocketMsg(OB_CMD_GET_NUM, info,nil,1);
end

OnlineRoomController.onRecvServerNewChessUndo = function(self,packetInfo)
    --和老接口一样
    local mModule = self:getSceneModule();
    if mModule and mModule.onWatchRoomUndo then
        mModule.onWatchRoomUndo(mModule,packetInfo);
    end
end

OnlineRoomController.onRecvServerNewChessDraw = function(self,packetInfo)
    --和老接口一样
    local mModule = self:getSceneModule();
    if mModule and mModule.onWatchRoomDraw then
        mModule.onWatchRoomDraw(mModule,packetInfo);
    end
end

OnlineRoomController.onRecvServerNewChessSurrender = function(self,packetInfo)
    --和老接口一样
    local mModule = self:getSceneModule();
    if mModule and mModule.onWatchRoomSurrender then
        mModule.onWatchRoomSurrender(mModule,packetInfo);
    end 
end

OnlineRoomController.onRecvServerNewGameOver = function(self,packetInfo)
    --和老接口一样
    local mModule = self:getSceneModule();
    if mModule and mModule.onWatchRoomClose then
        mModule.onWatchRoomClose(mModule,packetInfo);
    end   
end

OnlineRoomController.onRecvServerNewGetNumber = function(self,packetInfo)
    self:updateView(OnlineRoomSceneNew.s_cmds.watchNumber,packetInfo); 
end

OnlineRoomController.onRecvServerNewHistoryMsgs = function(self,packetInfo)
    self:updateView(OnlineRoomSceneNew.s_cmds.get_watch_history_msg,packetInfo); 
end

--新观战接口end
OnlineRoomController.onRecvServerInvitRequest = function(self, packetInfo)
    local mModule = self:getSceneModule();
    if packetInfo.ret == 0 then
        --邀请消息发送成功
        if mModule and mModule.onInvitFail then
            mModule.onInvitFail(mModule,packetInfo);
        end 
    else
        --邀请消息发送失败
        if mModule and mModule.onInvitFail then
            mModule.onInvitFail(mModule,packetInfo);
        end 
    end
end

OnlineRoomController.onRecvServerInvitResponse = function(self, packetInfo)
    local mModule = self:getSceneModule();
    if mModule and mModule.onDeleteInvitAnim then
        mModule.onDeleteInvitAnim(mModule,packetInfo);
    end 
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
end

OnlineRoomController.onRecvServerResetTable = function(self, packetInfo)
    local mModule = self:getSceneModule();
    if packetInfo.ret == 0 then
        --重置状态成功
        ChessToastManager.getInstance():show("对方拒绝应战，请稍后再挑战!");
        if mModule and mModule.resetGame then
            mModule.resetGame(mModule,packetInfo);
        end 
    else
        --重置状态失败
        ChessToastManager.getInstance():show("重置房间错误,请重新邀请!", 5000);
        self:onBackAction();
    end
end;

OnlineRoomController.onInvitNotify = function(self,packetInfo)
    --需要判断是否在下棋中
    if not packetInfo or not packetInfo.uid or not packetInfo.tid then
        return;
    end
    if FriendsData.getInstance():isInBlacklist(tonumber(packageInfo.uid)) then return end
    local mModule = self:getSceneModule();
    if mModule and mModule.onInvitNotify then
        mModule.onInvitNotify(mModule,packetInfo);
    end  
end

OnlineRoomController.onRecvCustomStrangerInvite = function(self,packetInfo)
    if not next(packetInfo) then return end;
    local mModule = self:getSceneModule();
    if mModule and mModule.onInvitNotify then
        mModule.onInvitNotify(mModule,packetInfo);
    end  
end

OnlineRoomController.onRecvCustomInviteResp = function(self,packetInfo)
    if not next(packetInfo) then return end;
    if packetInfo and packetInfo.ret == 0 then
        ChessToastManager.getInstance():showSingle("对方接受了您的挑战请求",2000);
    elseif packetInfo and packetInfo.ret == 1 then
        ChessToastManager.getInstance():showSingle("对方拒绝了您的挑战请求",2000);
        self:onBack();
    end;
    delete(CustomModule.schedule_repeat_time);
end;

OnlineRoomController.onRecvServerSetTime = function(self, packetInfo)
    if packetInfo.uid == UserInfo.getInstance():getUid() then
        self:updateView(OnlineRoomSceneNew.s_cmds.setTime,packetInfo.time_out);
    else
        self:updateView(OnlineRoomSceneNew.s_cmds.waitSetTime,packetInfo.time_out);
    end
end;

OnlineRoomController.onRecvServerSetTimeNotify = function(self, packetInfo)
    if packetInfo.uid == UserInfo.getInstance():getUid() then
        self:updateView(OnlineRoomSceneNew.s_cmds.setTimeShow,packetInfo); 
    else
        self:updateView(OnlineRoomSceneNew.s_cmds.waitSetTimeShow,packetInfo); 
    end
end;

OnlineRoomController.onRecvServerSetTimeResponse = function(self, packetInfo)
    if packetInfo.ret == 0 then
        if packetInfo.uid ~= UserInfo.getInstance():getUid() then
            ChessToastManager.getInstance():show("对方同意棋局设置！");
        end
        self:updateView(OnlineRoomSceneNew.s_cmds.setTimeResponse,true)
    else
        if packetInfo.uid ~= UserInfo.getInstance():getUid() then
            ChessToastManager.getInstance():show("对方拒绝棋局设置！");
        end
        self:updateView(OnlineRoomSceneNew.s_cmds.setTimeResponse,false)
    end
end

OnlineRoomController.onSynWatchData = function(self)
    local params = {};
    params.tid = RoomProxy.getInstance():getTid();
    self:sendSocketMsg(OB_CMD_GET_TABLE_INFO,params);
end

OnlineRoomController.onSendWatchChat = function(self, message)
    self:sendSocketMsg(OB_CMD_CHAT_MSG,message,nil,1);
end

OnlineRoomController.onHallGameInfo = function(self,data)
    self.mMatchGameStartTime =  os.time()
    self:sendSocketMsg(HALL_MSG_GAMEINFO,data,SUBCMD_MONEY,2);
end

OnlineRoomController.onHallCancelMatch = function(self,roomid)
    self:sendSocketMsg(CLIENT_HALL_CANCEL_MATCH,nil,1);
end

OnlineRoomController.onServerMsgForestall = function(self, befirst)
    self:sendSocketMsg(SERVER_MSG_FORESTALL,befirst,nil,1);
end

OnlineRoomController.onServerMsgForestallNew = function(self, money)
    self:sendSocketMsg(SERVER_MSG_FORESTALL_NEW,money,nil,1);
end;

OnlineRoomController.onServerMsgForestall320 = function(self, money)
    self:sendSocketMsg(SERVER_MSG_FORESTALL_320,money,nil,1);
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
    self:sendSocketMsg(CLIENT_MSG_LOGIN,nil,nil,1);
end;

OnlineRoomController.onSendReadyMsg = function(self)
    self:sendSocketMsg(CLIENT_MSG_READY,nil,nil,1)
end

OnlineRoomController.onClientMsgLogout = function(self)
    self:sendSocketMsg(CLIENT_MSG_LOGOUT,nil, nil,1);
end
-- 强制退出房间
OnlineRoomController.onClientMsgOffline = function(self)
    self:sendSocketMsg(CLIENT_MSG_OFFLINE,nil, nil,1);
end

OnlineRoomController.onClientMsgChat = function(self, info)
    self:sendSocketMsg(CLIENT_MSG_CHAT, info, 1 ,2);
end

OnlineRoomController.onClientMsgMove = function(self, info)
    self:sendSocketMsg(CLIENT_MSG_MOVE, info, nil,1);
end

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

OnlineRoomController.onInviteRequest = function(self,post_data)
    self:sendSocketMsg(FRIEND_CMD_FRIEND_INVITE_REQUEST,post_data,nil,1);
end

OnlineRoomController.onInviteResponse = function(self,post_data)
    self:sendSocketMsg(FRIEND_CMD_FRIEND_INVIT_RESPONSE2,post_data,nil,1);
end

OnlineRoomController.onSetTimeFinish = function(self,post_data)
    self:sendSocketMsg(SERVER_BROADCAST_SET_TIME,post_data,nil,1);
end

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
    local sceneModule = self:getSceneModule();
    if sceneModule and type(sceneModule.sendFllowCallback) == "function" then
        sceneModule:sendFllowCallback(info);
    end
    if info.ret ~= 0 then
        ChessToastManager.getInstance():show("关注失败!");
        return ;
    end
    self:updateView(OnlineRoomSceneNew.s_cmds.updateUserInfoDialog,info);
end

OnlineRoomController.saveRecentChessData = function(self,recent_data)
    self.m_recent_data = recent_data;
    if RoomProxy.getInstance():getCurRoomType() == RoomConfig.ROOM_TYPE_MONEY_MATCH_ROOM 
        or RoomProxy.getInstance():getCurRoomType() == RoomConfig.ROOM_TYPE_METIER_ROOM  then 
        -- 比赛房间走服务器广播通知 MATCH_BROADCAST_TABLESTEP
        return 
    end
    self:sendSocketMsg(CLIENT_CMD_GETTABLESTEP);
end

OnlineRoomController.onRecvShareDialogHide = function(self)
    self:updateView(OnlineRoomSceneNew.s_cmds.shareDialogHide);
end

OnlineRoomController.onTakeScreenShotComplete = function(self)
    self.super.onTakeScreenShotComplete(self);
    self:updateView(OnlineRoomSceneNew.s_cmds.take_picture_complete);
end;

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
-- isSelf,是否个人收藏
OnlineRoomController.onSaveChessAndShare = function(self)
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
        post_data.collect_type = 2; -- 收藏类型, 1公共收藏，2人个收藏 
        post_data.is_old = chessData.is_old or 0;
        self:sendHttpMsg(HttpModule.s_cmds.saveMychessAndShare,post_data);
    end;
end;

----------------------------------socket-----------------------------------

OnlineRoomController.onMatchSuccess = function(self, socket)

    Log.i("房间匹配到对手了，将要登陆到房间");
    self:sendSocketMsg(CLIENT_MSG_LOGIN,nil,nil,1);
end

OnlineRoomController.onRecvClientGetOpenboxTime = function(self, packetInfo)

	OnlineConfig.setPlaytime(packetInfo.playtime);
	OnlineConfig.setOpenboxtime(packetInfo.openbox_time);
	OnlineConfig.setOpenboxid(packetInfo.openbox_id);

    self:updateView(OnlineRoomSceneNew.s_cmds.client_get_openbox_time);   
    
end

OnlineRoomController.onRecvClientMsgChat = function(self, packetInfo)
    if self:isForbidSendMsg(packetInfo) then return end; 
    self:updateView(OnlineRoomSceneNew.s_cmds.client_msg_chat, packetInfo);
end

OnlineRoomController.onRecvClientMsgHandicap = function(self, packetInfo)

    self:updateView(OnlineRoomSceneNew.s_cmds.client_msg_handicap, packetInfo);

end;


OnlineRoomController.onRecvClientMsgMove = function(self, packetInfo)
    local info = {};
    info.tid = RoomProxy.getInstance():getTid();
    self:sendSocketMsg(OB_CMD_GET_NUM, info,nil,1);
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
    if UserInfo.getInstance():isHasEvaluation() then
        HttpModule.getInstance():execute(HttpModule.s_cmds.UserGetDoubleCardsInfo,{});
    end
    StatisticsManager.getInstance():onNewUserCountToPHPOnilnePlay(UserInfo.getInstance():getIsFirstLogin())
end;


OnlineRoomController.onRecvServerMsgWarning = function(self, packetInfo)

    self:updateView(OnlineRoomSceneNew.s_cmds.server_msg_warning, packetInfo);

end;


OnlineRoomController.onRecvServerMsgTips  = function(self, packetInfo)

    self:updateView(OnlineRoomSceneNew.s_cmds.server_msg_tips, packetInfo);

end

OnlineRoomController.onRecvClientMsgLoginSuccess = function(self, packetInfo)
    self:updateView(OnlineRoomSceneNew.s_cmds.client_user_login_succ, packetInfo);   
    --self:onSendReadyMsg();
end

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

OnlineRoomController.onRecvServerMsgForestall320 = function(self, packetInfo)
   self:updateView(OnlineRoomSceneNew.s_cmds.server_msg_forestall_320, packetInfo); 
end;

OnlineRoomController.onRecvServerMsgHandicap = function(self, packetInfo)
   self:updateView(OnlineRoomSceneNew.s_cmds.server_msg_handicap, packetInfo);
end;

OnlineRoomController.onRecvServerMsgHandicapResult = function(self, packetInfo)
   self:updateView(OnlineRoomSceneNew.s_cmds.server_msg_handicap_result, packetInfo)
end

OnlineRoomController.onRecvServerMsgHandicapConfirm = function(self, packetInfo)
   self:updateView(OnlineRoomSceneNew.s_cmds.server_msg_handicap_confirm, packetInfo)
end

OnlineRoomController.onRecvServerMsgGameStartInfo = function(self, packetInfo)
   self:updateView(OnlineRoomSceneNew.s_cmds.server_msg_game_start_info, packetInfo)
end

OnlineRoomController.onRecvServerHandicapAgreeResult = function(self, packetInfo)
    if packetInfo then
        if packetInfo.mulpity == 1 then
            ChessToastManager.getInstance():showSingle("对方拒绝让子",3000)
        else
            ChessToastManager.getInstance():showSingle("对方同意让子",3000)
        end
    end
end


OnlineRoomController.onRecvServerMsgTimeCountStart = function(self, packetInfo)
    -- 倒计时开始 发送查询server 游戏开始时间
    RoomProxy.getInstance():sendGetRoomStartTimeCmd()
    self:updateView(OnlineRoomSceneNew.s_cmds.server_msg_timecount_start, packetInfo);

end;

OnlineRoomController.onRecvServerMsgReconnect = function(self, packetInfo)
    -- 断线重连 发送查询server 游戏开始时间
    RoomProxy.getInstance():sendGetRoomStartTimeCmd()
    self:updateView(OnlineRoomSceneNew.s_cmds.server_msg_reconnect, packetInfo);

end;


OnlineRoomController.onRecvServerMsgUserLeave = function(self, packetInfo)
    self:updateView(OnlineRoomSceneNew.s_cmds.server_msg_user_leave, packetInfo);
end;

OnlineRoomController.onRecvServerMsgLogoutSuccess = function(self, packetInfo)
    
    self:updateView(OnlineRoomSceneNew.s_cmds.server_msg_logout_succ, packetInfo);

end

OnlineRoomController.onRecvClientMsgForestall = function(self, packetInfo) 
end

OnlineRoomController.onRecvClientRoomSyn = function(self, packetInfo)

    self:updateView(OnlineRoomSceneNew.s_cmds.client_msg_syndata, packetInfo);

end;

--hallSocket

OnlineRoomController.onHallMsgLogin = function(self, packetInfo)
    Log.i("OnlineRoomController.onHallMsgLogin");
    RoomProxy.getInstance():setTid(packetInfo.tid);

    if RoomProxy.getInstance():getCurRoomType() == RoomConfig.ROOM_TYPE_MONEY_MATCH_ROOM 
        or RoomProxy.getInstance():getCurRoomType() == RoomConfig.ROOM_TYPE_METIER_ROOM then
        local mModule = self:getSceneModule();
        if mModule and mModule.onHallMsgLogin then
            mModule:onHallMsgLogin(packetInfo);
        end
        return
    end

    if packetInfo.tid == 0 then
        if RoomProxy.getInstance():getCurRoomType() == RoomConfig.ROOM_TYPE_CONSOLE_ROOM then
            ChessToastManager.getInstance():show("由于长时间未操作，您已被移出房间", 5000);
        elseif RoomProxy.getInstance():getCurRoomType() == RoomConfig.ROOM_TYPE_WATCH_ROOM then
            ChessToastManager.getInstance():show("网络不稳定请重新进入观战房间", 5000);
        else
            ChessToastManager.getInstance():show("房间棋局已经结束", 5000);
        end
        self:onBackAction();
    else
        self:sendSocketMsg(CLIENT_MSG_LOGIN,nil,nil,1);
    end
end

OnlineRoomController.onRecvHallMsgGameInfo = function(self, packetInfo)
    Log.i("OnlineRoomController.onRecvHallMsgGameInfo");
    local mModule = self:getSceneModule();
    if packetInfo.tid == 0 then
        if mModule and mModule.onMatchRoomFail then
            mModule.onMatchRoomFail(mModule,packetInfo);
        end   
        return
    end
    if self.mMatchGameStartTime then
        local diff = os.time() - self.mMatchGameStartTime;
        StatisticsManager.getInstance():onCountToUM(ONLINE_MATCH_SUCCESS_TIME,diff)
    end
    self:onMatchSuccess();
end
--self.m_recent_data
OnlineRoomController.onRecvGetTableStep = function(self, info)
    Log.i("OnlineRoomController.onRecvHallMsgGameInfo");
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
    -- 没走棋特殊判断
    if info.page_num == 0 then
        self.m_mvList = {};
--        self:updateView(OnlineRoomSceneNew.s_cmds.saveChessData) -- 获取scene 界面数据
        if self.m_recent_data then
            self:saveChessData(info.handicapschessman);
        end
        self.m_mvList = nil;
        self.m_recent_data = nil;
    end
end

OnlineRoomController.onMatchBroadcastTablestep = function(self, info)
    Log.i("OnlineRoomController.onRecvHallMsgGameInfo");
    if info.curr_page == 0 and info.page_num > 0 then
        self.m_mvList = {};
    end

    if self.m_mvList and info.item_num then
        for i = 1,info.item_num do
            table.insert(self.m_mvList,info.tab_step[i]);
        end
    end

    if self.m_mvList and info.curr_page == info.page_num-1 then  --- info.curr_page = info.page_num = 0
        self:updateView(OnlineRoomSceneNew.s_cmds.saveChessData) -- 获取scene 界面数据
        if self.m_recent_data then
            self:saveChessData(info.handicapschessman);
        end
        self.m_mvList = nil;
        self.m_recent_data = nil;
    end
    -- 没走棋特殊判断
    if info.page_num == 0 then
        self.m_mvList = {};
        self:updateView(OnlineRoomSceneNew.s_cmds.saveChessData) -- 获取scene 界面数据
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
    if retdata.msg ~= "" then
        ChessToastManager.getInstance():showSingle(retdata.msg)
    end

	retdata.playtime =  tonumber(data.playtime:get_value());
	retdata.openbox_id =  tonumber(data.openbox_id:get_value());
	retdata.openbox_time =  tonumber(data.openbox_time:get_value());

	local money = tonumber(data.reward.money:get_value());
	local soul = tonumber(data.reward.soul:get_value());

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
    self:updateUserInfoView()
end

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
    if flag then
        local mModule = self:getSceneModule();
        if mModule and mModule.onSaveChessCallBack then
            mModule:onSaveChessCallBack(data);
        end
    end
end;

--    if data.cost then
--        if data.cost > 0 then 
--            if self.m_account_dialog and self.m_account_dialog:isShowing() then
--                self.m_account_dialog:setHasSaved();
--            end;
--            self:exitRoom();
--        elseif data.cost == 0 then
--        elseif data.cost == -1 then
--            -- -1是老版本本地棋谱上传成功
--        end
--    end
OnlineRoomController.onSaveMychessAndShareCallBack = function(self, flag, message)
    if HttpModule.explainPHPMessage(flag, message,"分享失败") then return end
    local data = json.analyzeJsonNode(message.data);
    self:updateView(OnlineRoomSceneNew.s_cmds.save_chess_and_share,data);
    if flag then
        local mModule = self:getSceneModule();
        if mModule and mModule.onSaveChessCallBack then
            mModule:onSaveChessCallBack(data);
        end
    end
end

function OnlineRoomController:onRefreshRank(isSuccess,message)
    if isSuccess then
        local mModule = self:getSceneModule();
        if mModule and mModule.onRefreshRank then
            mModule:onRefreshRank(message);
        end
    end
end

function OnlineRoomController:onMatchRebuy(isSuccess,message)
    local mModule = self:getSceneModule();
    if mModule and mModule.onMatchRebuy then
        mModule:onMatchRebuy(isSuccess,message);
    end
end


OnlineRoomController.onIndexGetNotice = function(self,isSuccess,message)
    -- 屏蔽公告
end

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
    elseif code == CHESS_MOVE_LOOG_PLAY then
        message = "走法长打不变，请重新走棋！" 
	else
		message = "走法不合规则，请重新走棋！" 
	end

	ChatMessageAnim.play(self.m_view,3,message);

end

OnlineRoomController.onRecvServerEntryChatRoom = function(self,packetInfo)
    if self.m_view.m_chat_dialog and self.m_view.m_chat_dialog.isEntryChatRoom then
        self.m_view.m_chat_dialog:isEntryChatRoom(packetInfo);
    end
end

OnlineRoomController.onRecvServerUserMsg = function(self,packetInfo)
    if self.m_view.m_chat_dialog and self.m_view.m_chat_dialog.onRecvServerUserMsg then
        self.m_view.m_chat_dialog:onRecvServerUserMsg(packetInfo);
    end
end

OnlineRoomController.onRecvServerChatMsg = function(self,packetInfo)
    if self.m_view.m_chat_dialog and self.m_view.m_chat_dialog.onRecvServerChatMsg then
        self.m_view.m_chat_dialog:onRecvServerChatMsg(packetInfo);
    end
end

OnlineRoomController.onReceChatMsgState = function(self,packetInfo)
    if self:isForbidSendMsg(packetInfo) then return end;
    if self.m_view.m_chat_dialog and self.m_view.m_chat_dialog.onReceChatMsgState then
        self.m_view.m_chat_dialog:onReceChatMsgState(packetInfo);
    end
end

OnlineRoomController.onRecvServerUnreadMsg = function(self,packetInfo)
    if self.m_view.m_chat_dialog and self.m_view.m_chat_dialog.onRecvServerUnreadMsg then
        self.m_view.m_chat_dialog:onRecvServerUnreadMsg(packetInfo);
    end
end

OnlineRoomController.onRecvServerRoomKickOutUser = function(self,packetInfo)
    ChessToastManager.getInstance():show("您被房主请出了房间");
    self:onClientMsgLogout();
    self:onBackAction();
end

OnlineRoomController.onRecvClientAllocGetPrivateroomInfo = function(self,packetInfo)
    local mModule = self:getSceneModule();
    if mModule and mModule.onGetPrivateInfo then
        mModule:onGetPrivateInfo(packetInfo);
    end
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


OnlineRoomController.onRecvClientCmdForbidUserMsg = function(self,packetInfo)
    if packetInfo then
        self:updateView(OnlineRoomSceneNew.s_cmds.forbid_user_msg,packetInfo);
    end
end

OnlineRoomController.onServerCmdKickPlayer = function(self)
    self:sendSocketMsg(SERVER_CMD_KICK_PLAYER);
end

OnlineRoomController.sendGetPrivateRoomInfo = function(self)
    local params = {};
    params.tid = RoomProxy.getInstance():getTid();
    params.level = RoomProxy.getInstance():getCurRoomLevel();
    self:sendSocketMsg(CLIENT_ALLOC_GET_PRIVATEROOM_INFO,params);
end

OnlineRoomController.sendCustomStrangerInvite = function(self,params)
    self:sendSocketMsg(STRANGER_CMD_INVITE_REQUEST,params);
end

function OnlineRoomController.onRecvServerGiveGift(self,packetInfo)
    local ret = GiftModuleController.getInstance():onRecvSendGift(packetInfo)
    if packetInfo and ret then
        self:updateView(OnlineRoomSceneNew.s_cmds.send_gift_return,packetInfo);
    end
end

function OnlineRoomController.onRecvServerGiftMsg(self,packetInfo)
    if packetInfo then
        self:updateView(OnlineRoomSceneNew.s_cmds.ob_gift_msg,packetInfo);
    end
end

function OnlineRoomController:onFastmatchSignupRequest(info)
    local mModule = self:getSceneModule();
    if mModule and mModule.onFastmatchSignupRequest then
        mModule:onFastmatchSignupRequest(info);
    end
end

function OnlineRoomController:onFastmatchCanclesignupRequest(info)
    local mModule = self:getSceneModule();
    if mModule and mModule.onFastmatchCanclesignupRequest then
        mModule:onFastmatchCanclesignupRequest(info);
    end
end

function OnlineRoomController:onFastmatchSignupCountNotify(info)
    local mModule = self:getSceneModule();
    if mModule and mModule.onFastmatchSignupCountNotify then
        mModule:onFastmatchSignupCountNotify(info);
    end
end

function OnlineRoomController:onFastmatchDropoutNotify(info)
    local mModule = self:getSceneModule();
    if mModule and mModule.onFastmatchDropoutNotify then
        mModule:onFastmatchDropoutNotify(info);
    end
end

function OnlineRoomController:onFastmatchEnterroomNotify(info)
    local mModule = self:getSceneModule();
    if mModule and mModule.onFastmatchEnterroomNotify then
        mModule:onFastmatchEnterroomNotify(info);
    end
end

function OnlineRoomController:onFastmatchEnterNextroomNotify(info)
    local mModule = self:getSceneModule();
    if mModule and mModule.onFastmatchEnterNextroomNotify then
        mModule:onFastmatchEnterNextroomNotify(info);
    end
end


function OnlineRoomController:onFastmatchRoundover(info)
    local mModule = self:getSceneModule();
    if mModule and mModule.onFastmatchRoundover then
        mModule:onFastmatchRoundover(info);
    end
end

function OnlineRoomController:onFastmatchGiveUp(info)
    local mModule = self:getSceneModule();
    if mModule and mModule.onFastmatchGiveUp then
        mModule:onFastmatchGiveUp(info);
    end
end

function OnlineRoomController:onMatchLoginSuc(info)
    local mModule = self:getSceneModule();
    if mModule and mModule.onMatchLoginSuc then
        mModule:onMatchLoginSuc(info);
    end
end

function OnlineRoomController:onMatchGetmatchinfo(info)
    local mModule = self:getSceneModule();
    if mModule and mModule.onMatchGetmatchinfo then
        mModule:onMatchGetmatchinfo(info);
    end
end

function OnlineRoomController:onMatchGettableinfo(info)
    self:updateView(OnlineRoomSceneNew.s_cmds.client_msg_syndata, info);
end

function OnlineRoomController:onMatchGetobtableinfo(info)
    self:onRecvServerNewTableInfo(info)
end

function OnlineRoomController:onMatchPlayerChangeState(info)
    local mModule = self:getSceneModule();
    if mModule and mModule.onMatchPlayerChangeState then
        mModule:onMatchPlayerChangeState(info);
    end
end

function OnlineRoomController:onMatchLeaveOb(info)
    local mModule = self:getSceneModule();
    if mModule and mModule.onMatchLeaveOb then
        mModule:onMatchLeaveOb(info);
    end
end

function OnlineRoomController:onMatchGetRoundIndex(info)
    local mModule = self:getSceneModule();
    if mModule and mModule.onMatchGetRoundIndex then
        mModule:onMatchGetRoundIndex(info);
    end
end

function OnlineRoomController:onMatchEnterObserveTable(info)
    local mModule = self:getSceneModule();
    if mModule and mModule.onMatchEnterObserveTable then
        mModule:onMatchEnterObserveTable(info);
    end
end

function OnlineRoomController.updateUserInfoView(self)
    self:updateView(OnlineRoomSceneNew.s_cmds.refresh_userinfo,true);
end

function OnlineRoomController:onLoginMatchResponse(info)
    local mModule = self:getSceneModule();
    if mModule and mModule.onLoginMatchResponse then
        mModule:onLoginMatchResponse(info);
    end
end

function OnlineRoomController:onServerReturnsPlayerStatus(info)
    local mModule = self:getSceneModule();
    if mModule and mModule.onServerReturnsPlayerStatus then
        mModule:onServerReturnsPlayerStatus(info);
    end
end

function OnlineRoomController:onMetierResultMsg(info)
    local mModule = self:getSceneModule();
    if mModule and mModule.onMetierResultMsg then
        mModule:onMetierResultMsg(info);
    end
end

function OnlineRoomController:onUserRequestMatchingResult(info)
    local mModule = self:getSceneModule();
    if mModule and mModule.onUserRequestMatchingResult then
        mModule:onUserRequestMatchingResult(info);
    end
end

function OnlineRoomController:onGetMatchPlayerInfoResult(info)
    local mModule = self:getSceneModule();
    if mModule and mModule.onGetMatchPlayerInfoResult then
        mModule:onGetMatchPlayerInfoResult(info);
    end
end

function OnlineRoomController:onCheckOutStatusResult(info)
    local mModule = self:getSceneModule();
    if mModule and mModule.onCheckOutStatusResult then
        mModule:onCheckOutStatusResult(info);
    end
end

function OnlineRoomController:onCheckMatchUserGiftInfoResult(info)
    local mModule = self:getSceneModule();
    if mModule and mModule.onCheckMatchUserGiftInfoResult then
        mModule:onCheckMatchUserGiftInfoResult(info);
    end
end

function OnlineRoomController:onCheckMatchUserMaxScoreResult(info)
    local mModule = self:getSceneModule();
    if mModule and mModule.onCheckMatchUserMaxScoreResult then
        mModule:onCheckMatchUserMaxScoreResult(info);
    end
end

function OnlineRoomController:onMatchEndResult(info)
    local mModule = self:getSceneModule();
    if mModule and mModule.onMatchEndResult then
        mModule:onMatchEndResult(info);
    end
end

function OnlineRoomController:onMatchGetWatchTid(info)
    local mModule = self:getSceneModule();
    if mModule and mModule.onMatchGetWatchTid then
        mModule:onMatchGetWatchTid(info);
    end
end

function OnlineRoomController:onMatchGetMatchScore(info)
    local mModule = self:getSceneModule();
    if mModule and mModule.onMatchGetMatchScore then
        mModule:onMatchGetMatchScore(info);
    end
end

function OnlineRoomController:onMatchCheckUserRank(info)
    local mModule = self:getSceneModule();
    if mModule and mModule.onMatchCheckUserRank then
        mModule:onMatchCheckUserRank(info);
    end
end

function OnlineRoomController:onMatchEndMatchResult(info)
    local mModule = self:getSceneModule();
    if mModule and mModule.onMatchEndMatchResult then
        mModule:onMatchEndMatchResult(info);
    end
end

function OnlineRoomController:onRecvVipLoginWatchRoom(info)
    local mModule = self:getSceneModule();
    if mModule and mModule.onServerReturnsVipLogin then
        mModule:onServerReturnsVipLogin(info);
    end
end


OnlineRoomController.onMatchStartReminder = function(self,packageInfo)
    local data = json.decode(packageInfo.jsonStr)
    if not data then return end
    if not self.mMatchNoticeView then
        self.mMatchNoticeView = new(MatchNoticeView)
        self.mMatchNoticeView:setAlign(kAlignBottom)
        self.mMatchNoticeView:setLevel(11)
        self.mMatchNoticeView:addToRoot()
    end
    local obj,func 
--跳转类型（0:不跳转，1:跳转聊天室，2:跳转比赛）
    local jumpType = tonumber(data.confirm_type) or 0
    if jumpType == 0 then
    elseif jumpType == 1 then
        obj = data
        func = function(params)
            local mModule = self:getSceneModule();
            if mModule and mModule.backAction then
                OnlineRoomController.s_switch_func = function()
                    if UserInfo.getInstance():isFreezeUser() then return end;
                    CompeteScene.s_join_match_chat_room_id = params.match_id
                    StateMachine.getInstance():replaceState(States.Compete,StateMachine.STYPE_CUSTOM_WAIT);
                end
                mModule:backAction();
                self.mMatchNoticeView:dismiss()
            end
        end
    elseif jumpType == 2 then
        obj = data
        func = function(params)
            local mModule = self:getSceneModule();
            if mModule and mModule.backAction then
                OnlineRoomController.s_switch_func = function()
                    if UserInfo.getInstance():isFreezeUser() then return end;
                    CompeteScene.s_join_match_room_id = params.match_id
                    StateMachine.getInstance():replaceState(States.Compete,StateMachine.STYPE_CUSTOM_WAIT);
                end
                mModule:backAction();
                self.mMatchNoticeView:dismiss()
            end
        end
    end
    local roomConfig = RoomConfig.getInstance();
    local matchId = data.match_id
    local config = RoomConfig.getInstance():getMatchRoomConfig(matchId)
    if config then 
        self.mMatchNoticeView:setHeadUrl(config.img_url)
    end
    self.mMatchNoticeView:setConfirmType(data.confirm_type,obj,func)
    self.mMatchNoticeView:setText(data.notify_context)
    self.mMatchNoticeView:show(data.show_time)
end

OnlineRoomController.onMatchBroadcastOuts = function(self,packetInfo)
    local data = json.decode(packetInfo.jsonStr)
    if type(data)~="table" then return end
    local params = {}
    params.horn_msg = "#w" .. (data.notify_context or "")
    params.horn_type = 1 -- 全局
    if StateMachine.getInstance():getCurrentState() == 1 then
        BroadCastHorn.getInstance():setMsgAlign(1);
        BroadCastHorn.getInstance():switchBtnStatus(true);
    else
        BroadCastHorn.getInstance():setMsgAlign(2);
        BroadCastHorn.getInstance():switchBtnStatus(false);
    end;
    BroadCastHorn.getInstance():play(params);
end

OnlineRoomController.onMatchBroadcastEvent = function(self,packetInfo)
    local data = json.decode(packetInfo.jsonStr)
    if type(data)~="table" then return end
    local params = {}
    params.horn_msg = "#w" .. (data.notify_context or "")
    params.horn_type = 1 -- 全局
    if StateMachine.getInstance():getCurrentState() == 1 then
        BroadCastHorn.getInstance():setMsgAlign(1);
        BroadCastHorn.getInstance():switchBtnStatus(true);
    else
        BroadCastHorn.getInstance():setMsgAlign(2);
        BroadCastHorn.getInstance():switchBtnStatus(false);
    end;
    BroadCastHorn.getInstance():play(params);
end

--------------------------------config-------------------------------

OnlineRoomController.s_cmdConfig = 
{
	[OnlineRoomController.s_cmds.back_action]		            = OnlineRoomController.onBackAction;
    [OnlineRoomController.s_cmds.start_watch]                   = OnlineRoomController.onStartWatch;
    [OnlineRoomController.s_cmds.start_customroom]              = OnlineRoomController.onStartCustom;
    [OnlineRoomController.s_cmds.syn_watch_data]	            = OnlineRoomController.onSynWatchData;
    [OnlineRoomController.s_cmds.send_watch_chat]	            = OnlineRoomController.onSendWatchChat;
    [OnlineRoomController.s_cmds.hall_game_info]	            = OnlineRoomController.onHallGameInfo;
    [OnlineRoomController.s_cmds.hall_cancel_match]	            = OnlineRoomController.onHallCancelMatch;
    [OnlineRoomController.s_cmds.syn_room_data]	                = OnlineRoomController.onSynRoomData;
    [OnlineRoomController.s_cmds.client_msg_watchlist]          = OnlineRoomController.onClientMsgWatchlist;
    [OnlineRoomController.s_cmds.client_get_openbox_time]       = OnlineRoomController.onClientGetOpenboxTime;
    [OnlineRoomController.s_cmds.client_msg_login]              = OnlineRoomController.onClientMsgLogin;
    
    [OnlineRoomController.s_cmds.send_ready_msg]                = OnlineRoomController.onSendReadyMsg;
    [OnlineRoomController.s_cmds.client_msg_logout]             = OnlineRoomController.onClientMsgLogout;
    [OnlineRoomController.s_cmds.client_msg_offline]            = OnlineRoomController.onClientMsgOffline;

    [OnlineRoomController.s_cmds.server_msg_forestall]          = OnlineRoomController.onServerMsgForestall;
    [OnlineRoomController.s_cmds.server_msg_forestall_new]      = OnlineRoomController.onServerMsgForestallNew;
    [OnlineRoomController.s_cmds.server_msg_forestall_320]      = OnlineRoomController.onServerMsgForestall320;
    [OnlineRoomController.s_cmds.server_msg_handicap]           = OnlineRoomController.onServerMsgHandicap;







    [OnlineRoomController.s_cmds.client_msg_chat]               = OnlineRoomController.onClientMsgChat;
    [OnlineRoomController.s_cmds.client_msg_move]               = OnlineRoomController.onClientMsgMove;
--    [OnlineRoomController.s_cmds.close_room_socket]           = OnlineRoomController.onCloseRoomSocket;
    [OnlineRoomController.s_cmds.room_get_reward]               = OnlineRoomController.onRoomGetOnlineReward;
    [OnlineRoomController.s_cmds.client_msg_draw1]              = OnlineRoomController.onClientMsgDraw1;
    [OnlineRoomController.s_cmds.client_msg_draw2]              = OnlineRoomController.onClientMsgDraw2;
    [OnlineRoomController.s_cmds.client_msg_undomove]           = OnlineRoomController.onClientMsgUndomove;
    [OnlineRoomController.s_cmds.client_msg_surrender1]         = OnlineRoomController.onClientMsgSurrender1;
    [OnlineRoomController.s_cmds.client_msg_surrender2]         = OnlineRoomController.onClientMsgSurrender2;

    [OnlineRoomController.s_cmds.invit_request]                 = OnlineRoomController.onInviteRequest;
    [OnlineRoomController.s_cmds.invit_response]                = OnlineRoomController.onInviteResponse;
    [OnlineRoomController.s_cmds.set_time_finish]               = OnlineRoomController.onSetTimeFinish;
    [OnlineRoomController.s_cmds.set_time_response]             = OnlineRoomController.onSetTimeResponse;

    [OnlineRoomController.s_cmds.client_add]                    = OnlineRoomController.onClientAdd;
    [OnlineRoomController.s_cmds.save_recent_chess_data]        = OnlineRoomController.saveRecentChessData;
    [OnlineRoomController.s_cmds.sharePicture]                  = OnlineRoomController.sharePicture;
    [OnlineRoomController.s_cmds.save_mychess]		            = OnlineRoomController.onSaveMychess;
    [OnlineRoomController.s_cmds.save_chess_and_share]		    = OnlineRoomController.onSaveChessAndShare;
    [OnlineRoomController.s_cmds.server_cmd_kick_player]        = OnlineRoomController.onServerCmdKickPlayer;
    [OnlineRoomController.s_cmds.get_private_room_info]         = OnlineRoomController.sendGetPrivateRoomInfo;
    [OnlineRoomController.s_cmds.send_custom_stranger_invite]   = OnlineRoomController.sendCustomStrangerInvite;
    
--    [OnlineRoomController.s_cmds.send_gift]                 = OnlineRoomController.sendGift;

    
    
}


--响应socket响应事件
OnlineRoomController.s_socketCmdFuncMap = {
    [SERVER_MSG_LOGIN_SUCCESS]              = OnlineRoomController.onRecvClientMsgLoginSuccess;
    [SERVER_MSG_LOGIN_ERROR]                = OnlineRoomController.onRecvServerMsgLoginError;
    [SERVER_MSG_OTHER_ERROR]                = OnlineRoomController.onRecvServerMsgOtherError;
    [SERVER_MSG_OPP_USER_INFO]              = OnlineRoomController.onRecvClientMsgOppUserInfo;
    [SERVER_MSG_USER_READY]                 = OnlineRoomController.onRecvServerMsgUserReady;
    [SERVER_MSG_GAME_START]                 = OnlineRoomController.onRecvServerMsgGameStart;
    [SERVER_MSG_FORESTALL]                  = OnlineRoomController.onRecvServerMsgForestall;
    [SERVER_MSG_FORESTALL_NEW]              = OnlineRoomController.onRecvServerMsgForestallNew;
    [SERVER_MSG_FORESTALL_320]              = OnlineRoomController.onRecvServerMsgForestall320;
    [SERVER_MSG_HANDICAP]                   = OnlineRoomController.onRecvServerMsgHandicap;
    [SERVER_MSG_HANDICAP_RESULT]            = OnlineRoomController.onRecvServerMsgHandicapResult;
    [SERVER_MSG_HANDICAP_CONFIRM]           = OnlineRoomController.onRecvServerMsgHandicapConfirm; 
    [SERVER_MSG_GAME_START_INFO]            = OnlineRoomController.onRecvServerMsgGameStartInfo; 
    [SERVER_MSG_HANDICAP_AGREE_RESULT]      = OnlineRoomController.onRecvServerHandicapAgreeResult; 
    [SERVER_MSG_TIMECOUNT_START]            = OnlineRoomController.onRecvServerMsgTimeCountStart;
    [SERVER_MSG_RECONNECT]                  = OnlineRoomController.onRecvServerMsgReconnect;
    [SERVER_MSG_USER_LEAVE]                 = OnlineRoomController.onRecvServerMsgUserLeave;
    [SERVER_MSG_LOGOUT_SUCCESS]             = OnlineRoomController.onRecvServerMsgLogoutSuccess;



    --观战
    [CLIENT_WATCH_JOIN]                     = OnlineRoomController.onRecvClientWatchJoin;
    [SERVER_WATCH_START]                    = OnlineRoomController.onRecvServerWatchStart;
    [SERVER_WATCH_MOVE]                     = OnlineRoomController.onRecvServerWatchMove;
    [SERVER_WATCH_DRAW]                     = OnlineRoomController.onRecvServerWatchDraw;
    [SERVER_WATCH_SURRENDER]                = OnlineRoomController.onRecvServerWatchSurrender;
    [SERVER_WATCH_UNDO]                     = OnlineRoomController.onRecvServerWatchUndo;
    [SERVER_WATCH_USERLEAVE]                = OnlineRoomController.onRecvServerWatchUserLeave; 
    [SERVER_WATCH_GAMEOVER]                 = OnlineRoomController.onRecvServerWatchGameOver;
    [SERVER_WATCH_ALLREADY]                 = OnlineRoomController.onRecvServerWatchAllReady;
    [SERVER_WATCH_ERROR]                    = OnlineRoomController.onRecvServerWatchError;
    [CLIENT_WATCH_CHAT]                     = OnlineRoomController.onRecvClientWatchChat;


    --好友房
    [FRIEND_CMD_FRIEND_INVITE_REQUEST]      = OnlineRoomController.onRecvServerInvitRequest;     --发起好友邀请请求;
    [FRIEND_CMD_FRIEND_INVIT_RESPONSE]      = OnlineRoomController.onRecvServerInvitResponse;    --另一方回复结果;
    [CLIIENT_CMD_RESET_TABLE]               = OnlineRoomController.onRecvServerResetTable;    --重置房间状态;
    [FRIEND_CMD_FRIEND_INVIT_NOTIFY]        =  OnlineRoomController.onInvitNotify;   --好友挑战邀请通知

    --聊天室私人房挑战邀请
    [STRANGER_CMD_INVITE_REQUEST]           = OnlineRoomController.onRecvCustomStrangerInvite;       --发起挑战请求响应
    [STRANGER_CMD_INVIT_RESPONSE]           = OnlineRoomController.onRecvCustomInviteResp;           --被挑战者是否接受挑战

    --设置局时
    [SERVER_BROADCAST_SET_TIME]             = OnlineRoomController.onRecvServerSetTime;     --设置局时
    [SERVER_BROADCAST_SET_TIME_NOTIFY]      = OnlineRoomController.onRecvServerSetTimeNotify; --设置局时通知
    [SERVER_BROADCAST_SET_TIME_RESPONSE]    = OnlineRoomController.onRecvServerSetTimeResponse; --设置局时回复通知

    --好友观战
    [OB_CMD_CHAT_MSG]                       = OnlineRoomController.onRecvServerNewWatchMsg;              --观战聊天（读写）
    [OB_CMD_GET_TABLE_INFO]                 = OnlineRoomController.onRecvServerNewTableInfo;              --获取桌子信息(读写)
    [OB_CMD_PLAYER_ENTER]                   = OnlineRoomController.onRecvServerNewPlayerEnter;              --广播玩家进入（读）
    [OB_CMD_PLAYER_LEAVE]                   = OnlineRoomController.onRecvServerNewPlayerLeave;              --广播玩家离开(读)
    [OB_CMD_UPDATE_TABLE_STATUS]            = OnlineRoomController.onRecvServerNewUpdateTable;              --同步更新桌子状态（）
    [OB_CMD_GAMESTART]                      = OnlineRoomController.onRecvServerNewGameStart;              --游戏开始（读） 
    [OB_CMD_CHESS_MOVE]                     = OnlineRoomController.onRecvServerNewChessMove;              --广播走棋（读）
    [OB_CMD_CHESS_UNDOMOVE]                 = OnlineRoomController.onRecvServerNewChessUndo;              --悔棋（读）
    [OB_CMD_CHESS_DRAW]                     = OnlineRoomController.onRecvServerNewChessDraw;              --求和（读）
    [OB_CMD_CHESS_SURRENDER]                = OnlineRoomController.onRecvServerNewChessSurrender;              --认输（读）
    [OB_CMD_GAMEOVER]                       = OnlineRoomController.onRecvServerNewGameOver;              --游戏结束（读）
    [OB_CMD_GET_NUM]                        = OnlineRoomController.onRecvServerNewGetNumber;              --观战人数（读写）
    [OB_CMD_GET_HISTORY_MSGS]               = OnlineRoomController.onRecvServerNewHistoryMsgs;         --观战历史消息（读写）
--    [FRIEND_CMD_ADD_FLLOW]                = OnlineRoomController.onRecvServerAddFllow;                --添加或取消关注

    [CLIENT_MSG_FORESTALL]                  = OnlineRoomController.onRecvClientMsgForestall;
    [CLIENT_MSG_SYNCHRODATA]                = OnlineRoomController.onRecvClientRoomSyn;
    [CLIENT_GET_OPENBOX_TIME]               = OnlineRoomController.onRecvClientGetOpenboxTime;
    [CLIENT_MSG_CHAT]                       = OnlineRoomController.onRecvClientMsgChat;
    [CLIENT_MSG_HANDICAP]                   = OnlineRoomController.onRecvClientMsgHandicap;
    [CLIENT_MSG_MOVE]                       = OnlineRoomController.onRecvClientMsgMove;

    [CLIENT_MSG_DRAW1]                      = OnlineRoomController.onRecvClientMsgDraw1;
    [CLIENT_MSG_DRAW2]                      = OnlineRoomController.onRecvClientMsgDraw2;
    [SERVER_MSG_DRAW]                       = OnlineRoomController.onRecvServerMsgDraw;
    [CLIENT_MSG_UNDOMOVE]                   = OnlineRoomController.onRecvClientMsgUndomove;
    [SET_TIME_INFO]                         = OnlineRoomController.onRecvSetTimeInfo;

    [CLIENT_MSG_SURRENDER2]                 = OnlineRoomController.onRecvClientMsgSurrender2;
    [SERVER_MSG_SURRENDER]                  = OnlineRoomController.onRecvServerMsgSurrender;

    [SERVER_MSG_GAME_CLOSE]                 = OnlineRoomController.onRecvServerClientMsgGameClose;
    [SERVER_MSG_WARING]                     = OnlineRoomController.onRecvServerMsgWarning;
    [SERVER_MSG_TIPS]                       = OnlineRoomController.onRecvServerMsgTips;


    --房间内用大厅socket拉取匹配信息...
    [HALL_MSG_LOGIN]                        = OnlineRoomController.onHallMsgLogin;  
    [HALL_MSG_GAMEINFO]                     = OnlineRoomController.onRecvHallMsgGameInfo;

    -- 拉取房间走法
    [CLIENT_CMD_GETTABLESTEP]               = OnlineRoomController.onRecvGetTableStep;


    
    
    [FRIEND_CMD_CHAT_MSG]                   = OnlineRoomController.onReceChatMsgState;
    [CHATROOM_CMD_USER_CHAT_MSG]            = OnlineRoomController.onRecvServerUserMsg;
    [CHATROOM_CMD_BROAdCAST_CHAT_MSG]       = OnlineRoomController.onRecvServerChatMsg;
    [CHATROOM_CMD_ENTER_ROOM]               = OnlineRoomController.onRecvServerEntryChatRoom;
	[CHATROOM_CMD_GET_HISTORY_MSG]          = OnlineRoomController.onRecvServerUnreadMsg;
    [SERVER_CMD_ROOM_KICK_OUT_USER]         = OnlineRoomController.onRecvServerRoomKickOutUser;
    [CLIENT_ALLOC_GET_PRIVATEROOM_INFO]     = OnlineRoomController.onRecvClientAllocGetPrivateroomInfo;
    
    
    [SERVER_BROADCAST_USER_DISCONNECT]      = OnlineRoomController.onRecvServerBroadcastUserDisconnect;
    [SERVER_BROADCAST_USER_RECONNECT]       = OnlineRoomController.onRecvServerBroadcastUserReconnect;

    -- 联网房间屏蔽消息
    [CLIENT_CMD_FORBID_USER_MSG]            = OnlineRoomController.onRecvClientCmdForbidUserMsg;

    -- 玩家送礼物结果
    [CLIIENT_CMD_GIVEGIFT]                  = OnlineRoomController.onRecvServerGiveGift;

    --广播接收礼物消息
    [OB_CMD_GIVE_GIFT]                      = OnlineRoomController.onRecvServerGiftMsg;
    
    [FASTMATCH_SIGNUP_REQUEST]              = OnlineRoomController.onFastmatchSignupRequest;
    [FASTMATCH_CANCLESIGNUP_REQUEST]        = OnlineRoomController.onFastmatchCanclesignupRequest;
    [FASTMATCH_SIGNUP_COUNT_NOTIFY]         = OnlineRoomController.onFastmatchSignupCountNotify;
    [FASTMATCH_DROPOUT_NOTIFY]              = OnlineRoomController.onFastmatchDropoutNotify;
    [FASTMATCH_ENTERROOM_NOTIFY]            = OnlineRoomController.onFastmatchEnterroomNotify;
    [FASTMATCH_ENTERNEXTROOM_NOTIFY]        = OnlineRoomController.onFastmatchEnterNextroomNotify;
    [FASTMATCH_ROUNDOVER]                   = OnlineRoomController.onFastmatchRoundover;
    --比赛房间登录结果
    [MATCH_LOGIN_SUC]                       = OnlineRoomController.onMatchLoginSuc;
    -- 获得比赛战况
    [MATCH_GETMATCHINFO]                    = OnlineRoomController.onMatchGetmatchinfo;
    -- 速赛，放弃比赛
    [FASTMATCH_GIVE_UP]                     = OnlineRoomController.onFastmatchGiveUp;
    -- 获取比赛桌子信息
    [MATCH_GETTABLEINFO]                    = OnlineRoomController.onMatchGettableinfo;
    -- 获取观战的比赛桌子信息
    [MATCH_GETOBTABLEINFO]                  = OnlineRoomController.onMatchGetobtableinfo;
    -- 玩家在比赛中的状态改变
    [MATCH_PLAYER_CHANGE_STATE]             = OnlineRoomController.onMatchPlayerChangeState;
    -- 玩家在比赛中退出观战
    [MATCH_LEAVE_OB]                        = OnlineRoomController.onMatchLeaveOb;
    -- 玩家在比赛中退出观战
    [MATCH_GET_ROUND_INDEX]                 = OnlineRoomController.onMatchGetRoundIndex;
    -- 比赛进去观战桌子
    [MATCH_ENTER_OBSERVE_TABLE_REQUEST]     = OnlineRoomController.onMatchEnterObserveTable;
    [MATCH_BROADCAST_TABLESTEP]             = OnlineRoomController.onMatchBroadcastTablestep;

    --职业赛
    [SERVER_RETURNS_PLAYER_STATUS]          = OnlineRoomController.onServerReturnsPlayerStatus;
    [LOGIN_MATCH_RESPONSE]                  = OnlineRoomController.onLoginMatchResponse;
    [METIER_RESULT_MSG]                     = OnlineRoomController.onMetierResultMsg;
	-- 请求比赛匹配结果返回
    [USER_REQUEST_MATCHING_RESULT]          = OnlineRoomController.onUserRequestMatchingResult;
    [GET_MATCH_PLAYER_INFO_RESULT]          = OnlineRoomController.onGetMatchPlayerInfoResult;
    [CHECK_OUT_STATUS_RESULT]               = OnlineRoomController.onCheckOutStatusResult;
    [CHECK_MATCH_USER_GIFT_INFO_RESULT]     = OnlineRoomController.onCheckMatchUserGiftInfoResult;
    [CHECK_MATCH_USER_MAX_SCORE_RESULT]     = OnlineRoomController.onCheckMatchUserMaxScoreResult;
    [MATCH_END_MATCH_RESULT]                = OnlineRoomController.onMatchEndMatchResult;
    [MATCH_END_RESULT]                      = OnlineRoomController.onMatchEndResult;
    --获取新的观战桌子
    [MATCH_GET_WATCH_TID]                   = OnlineRoomController.onMatchGetWatchTid;
    --获取比赛积分
    [MATCH_GET_MATCH_SCORE]                 = OnlineRoomController.onMatchGetMatchScore;
    --查询用户比赛排名
    [MATCH_CHECK_USER_RANK]                 = OnlineRoomController.onMatchCheckUserRank;
    
    --职业赛 end

    [VIP_LOGIN_WATCHROOM]                   = OnlineRoomController.onRecvVipLoginWatchRoom;

    [MATCH_START_REMINDER]                  = OnlineRoomController.onMatchStartReminder;
    --赛况播报
    [MATCH_BROADCAST_OUTS]                  = OnlineRoomController.onMatchBroadcastOuts;
    --比赛事件播报
    [MATCH_BROADCAST_EVENT]                 = OnlineRoomController.onMatchBroadcastEvent;
    
}

OnlineRoomController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	OnlineRoomController.s_socketCmdFuncMap or {});




OnlineRoomController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.getOnlineReward] = OnlineRoomController.onHttpGetOnlineRewardCallBack;
    [HttpModule.s_cmds.saveMychess]     = OnlineRoomController.onSaveChessCallBack;
    [HttpModule.s_cmds.saveMychessAndShare] = OnlineRoomController.onSaveMychessAndShareCallBack;
    [HttpModule.s_cmds.MatchRank2]      = OnlineRoomController.onRefreshRank;
    [HttpModule.s_cmds.MatchRebuy]      = OnlineRoomController.onMatchRebuy;
--    [HttpModule.s_cmds.IndexGetNotice]  = OnlineRoomController.onIndexGetNotice;
};

OnlineRoomController.s_httpRequestsCallBackFuncMap = CombineTables(RoomController.s_httpRequestsCallBackFuncMap,
	OnlineRoomController.s_httpRequestsCallBackFuncMap or {});



OnlineRoomController.s_nativeEventFuncMap = {
                    
    [kNetStateChange]              = OnlineRoomController.onNativeNetStateChange;
    [Board.UNLEGALMOVE]            = OnlineRoomController.onBoardUnlegalMove;
    [kFriend_FollowCallBack]       = OnlineRoomController.onRecvServerAddFllow;
    [kShareDialogHide]             = OnlineRoomController.onRecvShareDialogHide;
    [kTakeShotComplete]            = OnlineRoomController.onTakeScreenShotComplete;
};
OnlineRoomController.s_nativeEventFuncMap = CombineTables(RoomController.s_nativeEventFuncMap,
	OnlineRoomController.s_nativeEventFuncMap or {});



