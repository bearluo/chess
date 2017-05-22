require("libs/json_wrap");
require(NET_PATH.."hall/hallSocketCmd");
require("gameBase/socketProcesser");


HallSocketProcesser = class(SocketProcesser);


HallSocketProcesser.onServerOfflineReconnected = function(self, packetInfo)

    Log.i("HallSocketProcesser.onServerOfflineReconnected");
    self.m_controller:handleSocketCmd(SERVER_OFFLINE_RECONNECTED, packetInfo);
end;

HallSocketProcesser.onSendLoginHall = function(self)
	Log.i("HallSocketProcesser.onSendLoginHall");

--	local user = {};
--	user.userId = kUserData:getUid();
--	user.isOnline = 1;
--	user.pid = HttpParam.pid;
--	user.sid =HttpParam.sid;
--	user.bid =HttpParam.bid;
--	user.versioncode = kServerVersion;
  	self.m_socket:sendMsg(HALL_MSG_LOGIN);



end
HallSocketProcesser.onHallMsgHeart = function(self)

    Log.i("HallSocketProcesser.onHallMsgHeart");

end;
HallSocketProcesser.onHallMsgLogin = function(self,packetInfo)
    self.m_controller:handleSocketCmd(HALL_MSG_LOGIN, packetInfo);
end

HallSocketProcesser.onHallMsgGameInfo = function(self,packetInfo)
    self.m_controller:handleSocketCmd(HALL_MSG_GAMEINFO,packetInfo);
end

HallSocketProcesser.onHallMsgGamePlay = function(self,packetInfo)
    self.m_controller:handleSocketCmd(HALL_MSG_GAMEPLAY,packetInfo);
end

HallSocketProcesser.onHallMsgAllPlayNum = function (self,packetInfo)
    self.m_controller:handleSocketCmd(HALL_MSG_ALL_PLAY_NUM,packetInfo);
end

HallSocketProcesser.onHallMsgKickUser = function(self,packetInfo)
    self.m_controller:handleSocketCmd(HALL_MSG_KICKUSER);
end

HallSocketProcesser.onHallMsgPrivateRoomPlayNum = function(self, packetInfo)
    self.m_controller:handleSocketCmd(HALL_MSG_PRIVATE_ROOM_PLAY_NUM, packetInfo);
end

HallSocketProcesser.onServerOfflineReconnected = function(self,packetInfo)

    Log.i("HallSocketProcesser.onServerOfflineReconnected");
    self.m_controller:handleSocketCmd(SERVER_OFFLINE_RECONNECTED, packetInfo);
end;

HallSocketProcesser.onRecvClientMsgLoginSuccess = function(self, packetInfo)

    Log.i("HallSocketProcesser.onRecvClientMsgLoginSuccess");
    self.m_controller:handleSocketCmd(SERVER_MSG_LOGIN_SUCCESS, packetInfo);     

end;

HallSocketProcesser.onRecvServerMsgLoginError = function(self, packetInfo)
    Log.i("HallSocketProcesser.onRecvServerMsgLoginError");
    self.m_controller:handleSocketCmd(SERVER_MSG_LOGIN_ERROR, packetInfo);      

end;

HallSocketProcesser.onRecvServerMsgOtherError = function(self, packetInfo)
    Log.i("HallSocketProcesser.onRecvServerMsgOtherError");
    self.m_controller:handleSocketCmd(SERVER_MSG_OTHER_ERROR, packetInfo);   

end;
HallSocketProcesser.onRecvClientMsgOppUserInfo = function(self, packetInfo)

    Log.i("HallSocketProcesser.onRecvClientMsgOppUserInfo");
    self.m_controller:handleSocketCmd(SERVER_MSG_OPP_USER_INFO, packetInfo);     

end;

HallSocketProcesser.onRecvServerMsgUserReady = function(self, packetInfo)

    Log.i("HallSocketProcesser.onRecvServerMsgUserReady");
    self.m_controller:handleSocketCmd(SERVER_MSG_USER_READY, packetInfo);     

end;


HallSocketProcesser.onRecvServerMsgGameStart = function(self, packetInfo)

    Log.i("HallSocketProcesser.onRecvServerMsgGameStart");
    self.m_controller:handleSocketCmd(SERVER_MSG_GAME_START, packetInfo);     

end;


HallSocketProcesser.onRecvServerMsgForestall = function(self, packetInfo)
    Log.i("HallSocketProcesser.onRecvServerMsgForestall");
    self.m_controller:handleSocketCmd(SERVER_MSG_FORESTALL, packetInfo); 
end;

HallSocketProcesser.onRecvServerMsgForestallNew = function(self, packetInfo)
    Log.i("HallSocketProcesser.onRecvServerMsgForestallNew");
    self.m_controller:handleSocketCmd(SERVER_MSG_FORESTALL_NEW, packetInfo); 
end;

HallSocketProcesser.onRecvServerMsgForestall320 = function(self, packetInfo)
    Log.i("HallSocketProcesser.onRecvServerMsgForestallNew");
    self.m_controller:handleSocketCmd(SERVER_MSG_FORESTALL_320, packetInfo); 
end;


HallSocketProcesser.onRecvServerMsgHandicap = function(self, packetInfo)
    Log.i("HallSocketProcesser.onRecvServerMsgHandicap");
    self.m_controller:handleSocketCmd(SERVER_MSG_HANDICAP, packetInfo); 

end;

HallSocketProcesser.onRecvServerMsgHandicapResult = function(self, packetInfo)
    Log.i("HallSocketProcesser.onRecvServerMsgHandicapResult");
    self.m_controller:handleSocketCmd(SERVER_MSG_HANDICAP_RESULT, packetInfo); 

end;

HallSocketProcesser.onRecvServerMsgHandicapConfirm = function(self, packetInfo)
    Log.i("HallSocketProcesser.onRecvServerMsgHandicapConfirm");
    self.m_controller:handleSocketCmd(SERVER_MSG_HANDICAP_CONFIRM, packetInfo); 

end;


HallSocketProcesser.onRecvServerMsgGameStartInfo = function(self, packetInfo)
    Log.i("HallSocketProcesser.onRecvServerMsgGameStartInfo");
    self.m_controller:handleSocketCmd(SERVER_MSG_GAME_START_INFO, packetInfo); 
end

HallSocketProcesser.onRecvServerHandicapAgreeResult = function(self, packetInfo)
    Log.i("HallSocketProcesser.onRecvServerHandicapAgreeResult");
    self.m_controller:handleSocketCmd(SERVER_MSG_HANDICAP_AGREE_RESULT, packetInfo); 
end


HallSocketProcesser.onRecvServerMsgTimeCountStart = function(self, packetInfo)

    Log.i("HallSocketProcesser.onRecvServerMsgTimeCountStart");
    self.m_controller:handleSocketCmd(SERVER_MSG_TIMECOUNT_START, packetInfo);     

end;

HallSocketProcesser.onRecvServerMsgReconnect = function(self, packetInfo)

    Log.i("HallSocketProcesser.onRecvServerMsgReconnect");
    self.m_controller:handleSocketCmd(SERVER_MSG_RECONNECT, packetInfo);  


end;

HallSocketProcesser.onRecvServerMsgUserLeave = function(self, packetInfo)
    Log.i("HallSocketProcesser.onRecvServerMsgUserLeave");
    self.m_controller:handleSocketCmd(SERVER_MSG_USER_LEAVE, packetInfo); 
end;

HallSocketProcesser.onRecvServerMsgLogoutSuccess = function(self, packetInfo)
    Log.i("HallSocketProcesser.onRecvServerMsgLogoutSuccess");
    self.m_controller:handleSocketCmd(SERVER_MSG_LOGOUT_SUCCESS, packetInfo); 
end;

HallSocketProcesser.onRecvClientWatchList = function(self, packetInfo)
    Log.i("HallSocketProcesser.onRecvClientWatchList");
    self.m_controller:handleSocketCmd(CLIENT_WATCH_LIST, packetInfo); 
end;


HallSocketProcesser.onRecvClientWatchJoin = function(self, packetInfo)
    Log.i("HallSocketProcesser.onRecvClientWatchJoin");
    self.m_controller:handleSocketCmd(CLIENT_WATCH_JOIN, packetInfo); 
end;

HallSocketProcesser.onRecvServerWatchStart = function(self, packetInfo)
    Log.i("HallSocketProcesser.onRecvServerWatchStart");
    self.m_controller:handleSocketCmd(SERVER_WATCH_START, packetInfo); 
end;

HallSocketProcesser.onRecvServerWatchMove = function(self, packetInfo)
    Log.i("HallSocketProcesser.onRecvServerWatchMove");
    self.m_controller:handleSocketCmd(SERVER_WATCH_MOVE, packetInfo);  


end;


HallSocketProcesser.onRecvServerWatchDraw = function(self, packetInfo)
    Log.i("HallSocketProcesser.onRecvServerWatchDraw");
    self.m_controller:handleSocketCmd(SERVER_WATCH_DRAW, packetInfo);     


end;

HallSocketProcesser.onRecvServerWatchSurrender = function(self, packetInfo)
    
    Log.i("HallSocketProcesser.onRecvServerWatchSurrender");
    self.m_controller:handleSocketCmd(SERVER_WATCH_SURRENDER, packetInfo);     
end;

HallSocketProcesser.onRecvServerWatchUndo = function(self, packetInfo)
    
    Log.i("HallSocketProcesser.onRecvServerWatchUndo");
    self.m_controller:handleSocketCmd(SERVER_WATCH_UNDO, packetInfo);     
end;


HallSocketProcesser.onRecvServerWatchUserLeave = function(self, packetInfo)
    
    Log.i("HallSocketProcesser.onRecvServerWatchUserLeave");
    self.m_controller:handleSocketCmd(SERVER_WATCH_USERLEAVE, packetInfo); 

end;

HallSocketProcesser.onRecvServerWatchGameOver = function(self, packetInfo)
    
    Log.i("HallSocketProcesser.onRecvServerWatchGameOver");
    self.m_controller:handleSocketCmd(SERVER_WATCH_GAMEOVER, packetInfo); 

end;


HallSocketProcesser.onRecvServerWatchAllReady = function(self, packetInfo)
    Log.i("HallSocketProcesser.onRecvServerWatchAllReady");
    self.m_controller:handleSocketCmd(SERVER_WATCH_ALLREADY, packetInfo);     

end;

HallSocketProcesser.onRecvServerWatchError = function(self, packetInfo)
    Log.i("HallSocketProcesser.onRecvServerWatchError");
    self.m_controller:handleSocketCmd(SERVER_WATCH_ERROR, packetInfo);     

end;

HallSocketProcesser.onRecvClientWatchChat = function(self, packetInfo)
    Log.i("HallSocketProcesser.onRecvClientWatchChat");
    self.m_controller:handleSocketCmd(CLIENT_WATCH_CHAT, packetInfo);     

end

HallSocketProcesser.onRecvClientMsgForestall = function(self, packetInfo)
    
    Log.i("HallSocketProcesser.onRecvClientMsgForestall");
    self.m_controller:handleSocketCmd(CLIENT_MSG_FORESTALL, packetInfo);  

end


HallSocketProcesser.onRecvClientRoomSyn = function(self, packetInfo)

    Log.i("HallSocketProcesser.onRecvClientRoomSyn");
    self.m_controller:handleSocketCmd(CLIENT_MSG_SYNCHRODATA, packetInfo);  


end;

HallSocketProcesser.onRecvClientMsgWatchlist = function(self, packetInfo)
        Log.i("HallSocketProcesser.onRecvClientMsgWatchlist");
    self.m_controller:handleSocketCmd(CLIENT_MSG_WATCHLIST, packetInfo);   

end;


HallSocketProcesser.onRecvClientGetOpenboxTime = function(self, packetInfo)

    Log.i("HallSocketProcesser.onRecvClientGetOpenboxTime");
    self.m_controller:handleSocketCmd(CLIENT_GET_OPENBOX_TIME, packetInfo);    


end;

HallSocketProcesser.onRecvClientMsgChat = function(self, packetInfo)

    Log.i("HallSocketProcesser.onRecvClientMsgChat");
    self.m_controller:handleSocketCmd(CLIENT_MSG_CHAT, packetInfo);       

end;




HallSocketProcesser.onRecvClientMsgHandicap = function(self, packetInfo)

    Log.i("HallSocketProcesser.onRecvClientMsgHandicap");
    self.m_controller:handleSocketCmd(CLIENT_MSG_HANDICAP, packetInfo);       
 

end;



HallSocketProcesser.onRecvClientMsgMove = function(self, packetInfo)

    Log.i("HallSocketProcesser.onRecvClientMsgMove");
    self.m_controller:handleSocketCmd(CLIENT_MSG_MOVE, packetInfo);       
   

end;

HallSocketProcesser.onRecvClientMsgDraw1 = function(self, packetInfo)

    Log.i("HallSocketProcesser.onRecvClientMsgDraw1");
    self.m_controller:handleSocketCmd(CLIENT_MSG_DRAW1, packetInfo);       
   

end;

HallSocketProcesser.onRecvClientMsgDraw2 = function(self, packetInfo)

    Log.i("HallSocketProcesser.onRecvClientMsgDraw2");
    self.m_controller:handleSocketCmd(CLIENT_MSG_DRAW2, packetInfo);       
   

end;


HallSocketProcesser.onRecvClientMsgSurrender2 = function(self, packetInfo)
    Log.i("HallSocketProcesser.onRecvClientMsgSurrender2");
    self.m_controller:handleSocketCmd(CLIENT_MSG_SURRENDER2, packetInfo);      

end;


HallSocketProcesser.onRecvServerMsgSurrender = function(self, packetInfo)
    Log.i("HallSocketProcesser.onRecvServerMsgSurrender");
    self.m_controller:handleSocketCmd(SERVER_MSG_SURRENDER, packetInfo);
end;

HallSocketProcesser.onRecvServerMsgDraw = function(self, packetInfo)
    Log.i("HallSocketProcesser.onRecvServerMsgDraw");
    self.m_controller:handleSocketCmd(SERVER_MSG_DRAW, packetInfo);    

end;


HallSocketProcesser.onRecvClientMsgUndomove = function(self, packetInfo)
    Log.i("HallSocketProcesser.onRecvClientMsgUndomove");
    self.m_controller:handleSocketCmd(CLIENT_MSG_UNDOMOVE, packetInfo);     

end;


HallSocketProcesser.onRecvSetTimeInfo = function(self, packetInfo)
    Log.i("HallSocketProcesser.onRecvSetTimeInfo");
    self.m_controller:handleSocketCmd(SET_TIME_INFO, packetInfo);     

end;

HallSocketProcesser.onRecvServerMsgGameClose = function(self, packetInfo)
    Log.i("HallSocketProcesser.onRecvServerMsgGameClose");
    self.m_controller:handleSocketCmd(SERVER_MSG_GAME_CLOSE, packetInfo);     

    

end;

HallSocketProcesser.onRecvServerMsgWarning = function(self, packetInfo)
    Log.i("HallSocketProcesser.onRecvServerMsgWarning");
    self.m_controller:handleSocketCmd(SERVER_MSG_WARING, packetInfo);     
    

end;


HallSocketProcesser.onRecvServerMsgTips  = function(self, packetInfo)
    Log.i("HallSocketProcesser.onRecvServerMsgTips");
    self.m_controller:handleSocketCmd(SERVER_MSG_TIPS, packetInfo);     
    
end

HallSocketProcesser.onRecvHallPrivateRoomList = function(self, packetInfo)
    self.m_controller:handleSocketCmd(CLIENT_HALL_PRIVATEROOM_LIST, packetInfo);  
end

HallSocketProcesser.onRecvHallCreatePrivateRoom = function(self, packetInfo)
    self.m_controller:handleSocketCmd(CLIENT_HALL_CREATE_PRIVATEROOM, packetInfo);  
end

HallSocketProcesser.onRecvHallJoinPrivateRoom = function(self,packetInfo)
    self.m_controller:handleSocketCmd(CLIENT_HALL_JOIN_PRIVATEROOM, packetInfo);  
end

HallSocketProcesser.onRecvClientHallBroadcastMsg = function(self,packetInfo)
    if not packetInfo.msg or packetInfo.msg == "" then return end;
    local data = json.decode(packetInfo.msg);
    self.m_controller:handleSocketCmd(CLIENT_HALL_BROADCAST_MGS, data);  
end

HallSocketProcesser.onRecvFriendCmdOnlineNum = function(self,packetInfo)
    self.m_controller:handleSocketCmd(FRIEND_CMD_ONLINE_NUM, packetInfo);  
end

HallSocketProcesser.onRecvFriendCmdCheckUserStatus = function(self,packetInfo)
    self.m_controller:handleSocketCmd(FRIEND_CMD_CHECK_USER_STATUS, packetInfo);  
end

HallSocketProcesser.onRecvFriendCmdCheckUserData = function(self,packetInfo)
    local items = {};
    for i,v in ipairs(packetInfo.items) do
        if v.userInfo then
            table.insert(items,v);
        end
    end
    local ret = {};
    ret.item_num = #items;
    ret.items = items;
    if ret.item_num > 0 then
        self.m_controller:handleSocketCmd(FRIEND_CMD_CHECK_USER_DATA, ret);
    end
end

HallSocketProcesser.onRecvFriendCmdGetFriendsNum = function(self,packetInfo)
    self.m_controller:handleSocketCmd(FRIEND_CMD_GET_FRIENDS_NUM, packetInfo);  
end

HallSocketProcesser.onRecvFriendCmdGetFollowNum = function(self,packetInfo)
    self.m_controller:handleSocketCmd(FRIEND_CMD_GET_FOLLOW_NUM, packetInfo);  
end

HallSocketProcesser.onRecvFriendCmdGetFansNum = function(self,packetInfo)
    self.m_controller:handleSocketCmd(FRIEND_CMD_GET_FANS_NUM, packetInfo);  
end

HallSocketProcesser.onRecvFriendCmdGetFriendsList = function(self,packetInfo)
    self.m_controller:handleSocketCmd(FRIEND_CMD_GET_FRIENDS_LIST, packetInfo);  
end

HallSocketProcesser.onRecvFriendCmdGetFollowList = function(self,packetInfo)
    self.m_controller:handleSocketCmd(FRIEND_CMD_GET_FOLLOW_LIST, packetInfo);  
end

HallSocketProcesser.onRecvFriendCmdGetFansList = function(self,packetInfo)
    self.m_controller:handleSocketCmd(FRIEND_CMD_GET_FANS_LIST, packetInfo);  
end

HallSocketProcesser.onRecvFriendCmdGetUnreadMsg = function(self,packetInfo)
    if packetInfo.unread_msg_num>0 then
        self.m_controller:handleSocketCmd(FRIEND_CMD_GET_UNREAD_MSG, packetInfo);
    end
end

HallSocketProcesser.onRecvFriendCmdGetFollow = function(self,packetInfo)
    if packetInfo and packetInfo.ret == 0 then
        FriendsData.getInstance():sendGetFriendsListCmd();
        FriendsData.getInstance():sendGetFollowListCmd();
        FriendsData.getInstance():sendGetFansListCmd();
    end
    self.m_controller:handleSocketCmd(FRIEND_CMD_ADD_FLLOW, packetInfo);  
end

HallSocketProcesser.onRecvFriendChatMsg = function(self,packetInfo)
   
    self.m_controller:handleSocketCmd(FRIEND_CMD_CHAT_MSG, packetInfo);
end;

HallSocketProcesser.onRecvFriendChatMsg2 = function(self,packetInfo)
    self.m_controller:handleSocketCmd(FRIEND_CMD_CHAT_MSG2, packetInfo);
end

HallSocketProcesser.onRecvFriendCmdGetFriendsRank = function(self,packetInfo)
   
    self.m_controller:handleSocketCmd(FRIEND_CMD_SCORE_RANK, packetInfo);
end;

HallSocketProcesser.onRecvFriendCmdGetOnlyFriendsRank = function(self,packetInfo)
    self.m_controller:handleSocketCmd(FRIEND_CMD_CHECK_PLAYER_RANK, packetInfo);
end;


HallSocketProcesser.onRecvServerCreateFriendRoom = function(self,packetInfo)
    self.m_controller:handleSocketCmd(CLIENT_HALL_CREATE_FRIENDROOM, packetInfo);  
end

HallSocketProcesser.onRecvServerInvitResponse = function(self,packetInfo)
    self.m_controller:handleSocketCmd(FRIEND_CMD_FRIEND_INVIT_RESPONSE, packetInfo);  
end

HallSocketProcesser.onRecvServerInvitResponse2 = function(self,packetInfo)
    self.m_controller:handleSocketCmd(FRIEND_CMD_FRIEND_INVIT_RESPONSE2, packetInfo);  
end

HallSocketProcesser.onRecvServerInvitRequest = function(self,packetInfo)
    self.m_controller:handleSocketCmd(FRIEND_CMD_FRIEND_INVITE_REQUEST, packetInfo);  
end

HallSocketProcesser.onRecvServerInvitNotify = function(self,packetInfo)
    self.m_controller:handleSocketCmd(FRIEND_CMD_FRIEND_INVIT_NOTIFY, packetInfo);  
end

HallSocketProcesser.onRecvServerCheckUserState = function(self,packetInfo)
    self.m_controller:handleSocketCmd(FRIEND_CMD_GET_USER_STATUS, packetInfo);  
end

HallSocketProcesser.onRecvCustomStrangerInvite = function(self,packetInfo)
    self.m_controller:handleSocketCmd(STRANGER_CMD_INVITE_REQUEST, packetInfo);  
end 

HallSocketProcesser.onRecvServerCustomInvite = function(self,packetInfo)
    self.m_controller:handleSocketCmd(STRANGER_CMD_INVIT_NOTIFY, packetInfo);  
end 

HallSocketProcesser.onRecvCustomInviteResp = function(self,packetInfo)
    self.m_controller:handleSocketCmd(STRANGER_CMD_INVIT_RESPONSE, packetInfo);  
end 

HallSocketProcesser.onRecvServerSetTime = function(self,packetInfo)
    self.m_controller:handleSocketCmd(SERVER_BROADCAST_SET_TIME, packetInfo);  
end

HallSocketProcesser.onRecvServerSetTimeNotify = function(self,packetInfo)
    self.m_controller:handleSocketCmd(SERVER_BROADCAST_SET_TIME_NOTIFY, packetInfo);  
end

HallSocketProcesser.onRecvServerSetTimeResponse = function(self,packetInfo)
    self.m_controller:handleSocketCmd(SERVER_BROADCAST_SET_TIME_RESPONSE, packetInfo);  
end

HallSocketProcesser.onRecvServerResetTable = function(self,packetInfo)
    self.m_controller:handleSocketCmd(CLIIENT_CMD_RESET_TABLE, packetInfo);  
end

HallSocketProcesser.onRecvServerWatchMsg = function(self,packetInfo)
    self.m_controller:handleSocketCmd(OB_CMD_CHAT_MSG, packetInfo);
end

HallSocketProcesser.onRecvServerTableInfo = function(self,packetInfo)
    self.m_controller:handleSocketCmd(OB_CMD_GET_TABLE_INFO, packetInfo);
end

HallSocketProcesser.onRecvServerWatchList = function(self,packetInfo)
    self.m_controller:handleSocketCmd(OB_CMD_GET_OB_LIST, packetInfo);
end

HallSocketProcesser.onRecvServerPlayerEnter = function(self,packetInfo)
    self.m_controller:handleSocketCmd(OB_CMD_PLAYER_ENTER, packetInfo);
end

HallSocketProcesser.onRecvServerPlayerLeave = function(self,packetInfo)
    self.m_controller:handleSocketCmd(OB_CMD_PLAYER_LEAVE, packetInfo);
end

HallSocketProcesser.onRecvServerUpdateTable = function(self,packetInfo)
    self.m_controller:handleSocketCmd(OB_CMD_UPDATE_TABLE_STATUS, packetInfo);
end

HallSocketProcesser.onRecvServerGameStart = function(self,packetInfo)
   self.m_controller:handleSocketCmd(OB_CMD_GAMESTART, packetInfo);
end

HallSocketProcesser.onRecvServerChessMove = function(self,packetInfo)
    self.m_controller:handleSocketCmd(OB_CMD_CHESS_MOVE, packetInfo);
end

HallSocketProcesser.onRecvServerChessUndo = function(self,packetInfo)
    self.m_controller:handleSocketCmd(OB_CMD_CHESS_UNDOMOVE, packetInfo);
end

HallSocketProcesser.onRecvServerChessDraw = function(self,packetInfo)
    self.m_controller:handleSocketCmd(OB_CMD_CHESS_DRAW, packetInfo);
end

HallSocketProcesser.onRecvServerChessSurrender = function(self,packetInfo)
    self.m_controller:handleSocketCmd(OB_CMD_CHESS_SURRENDER, packetInfo);
end

HallSocketProcesser.onRecvServerGameOver = function(self,packetInfo)
    self.m_controller:handleSocketCmd(OB_CMD_GAMEOVER, packetInfo);
end

HallSocketProcesser.onRecvServerGetNumber = function(self,packetInfo)
    self.m_controller:handleSocketCmd(OB_CMD_GET_NUM, packetInfo);
end

HallSocketProcesser.onRecvServerNewHistoryMsgs = function(self,packetInfo)
    self.m_controller:handleSocketCmd(OB_CMD_GET_HISTORY_MSGS, packetInfo);
end
-----------
HallSocketProcesser.onRecvServerEntryChatRoom = function(self,packetInfo)
    self.m_controller:handleSocketCmd(CHATROOM_CMD_ENTER_ROOM, packetInfo);
end

HallSocketProcesser.onRecvServerLeftChatRoom = function(self,packetInfo)
    self.m_controller:handleSocketCmd(CHATROOM_CMD_LEAVE_ROOM, packetInfo);
end
HallSocketProcesser.onRecvServerLastMsg = function(self,packetInfo)
    self.m_controller:handleSocketCmd(CHATROOM_CMD_GET_UNREAD_MSG, packetInfo);
end
HallSocketProcesser.onRecvServerUserMsg = function(self,packetInfo)
    self.m_controller:handleSocketCmd(CHATROOM_CMD_USER_CHAT_MSG, packetInfo);
end
HallSocketProcesser.onRecvClientChatMsg = function(self,packetInfo)
    self.m_controller:handleSocketCmd(CHATROOM_CMD_BROAdCAST_CHAT_MSG, packetInfo);
end
HallSocketProcesser.onRecvServerUnreadMsg = function(self,packetInfo)
    self.m_controller:handleSocketCmd(CHATROOM_CMD_GET_HISTORY_MSG, packetInfo);
end
HallSocketProcesser.onRecvServerUnreadMsgNew = function(self,packetInfo)
    self.m_controller:handleSocketCmd(CHATROOM_CMD_GET_HISTORY_MSG_NEW, packetInfo);
end
HallSocketProcesser.onRecvServerChessMatchMsg = function(self,packetInfo)
    self.m_controller:handleSocketCmd(CHATROOM_CMD_GET_CHESS_MATCH_MSG, packetInfo);
end
HallSocketProcesser.onRecvServerChessMatchMsgNum = function(self,packetInfo)
    self.m_controller:handleSocketCmd(CHATROOM_CMD_GET_CHESS_MATCH_MSG_NUM, packetInfo);
end
HallSocketProcesser.onRecvServerUnreadMsgNum = function(self,packetInfo)
    self.m_controller:handleSocketCmd(CHATROOM_CMD_GET_UNREAD_MSG2, packetInfo);
end
HallSocketProcesser.onRecvServerGetMemberList = function(self,packetInfo)
    self.m_controller:handleSocketCmd(CHATROOM_CMD_GET_MEMBER_LIST, packetInfo);
end
HallSocketProcesser.onRecvServerIsActAvaliable= function(self,packetInfo)
    self.m_controller:handleSocketCmd(CHATROOM_CMD_IS_ACT_AVALIABLE, packetInfo);
end
HallSocketProcesser.onRecvServerUpdateCRItem= function(self,packetInfo)
    self.m_controller:handleSocketCmd(CHATROOM_CMD_UPDATE_CHATROOM_ITEM, packetInfo);
end
HallSocketProcesser.onRecvServerPropCmdUpdateUserData = function(self,packetInfo)
    self.m_controller:handleSocketCmd(PROP_CMD_UPDATE_USERDATA, packetInfo);
end

HallSocketProcesser.onRecvServerPropCmdQueryUserData = function(self,packetInfo)
    self.m_controller:handleSocketCmd(PROP_CMD_QUERY_USERDATA, packetInfo);
end

HallSocketProcesser.onRecvServerFriendsWatchList = function(self,packetInfo)
    self.m_controller:handleSocketCmd(FRIEND_CMD_GET_FRIEND_OB_LIST, packetInfo);
end

HallSocketProcesser.onRecvServerClientAllocPrivateRoomNum  = function(self,packetInfo)
    self.m_controller:handleSocketCmd(CLIENT_ALLOC_PRIVATEROOMNUM, packetInfo);
end

HallSocketProcesser.onRecvServerFriendCmdGeetPlayerInfo  = function(self,packetInfo)
    self.m_controller:handleSocketCmd(FRIEND_CMD_GET_PLAYER_INFO, packetInfo);
end

HallSocketProcesser.onRecvServerClientCmdGetTableStep  = function(self,packetInfo)
    self.m_controller:handleSocketCmd(CLIENT_CMD_GETTABLESTEP, packetInfo);
end

HallSocketProcesser.onClientGetCurTidStartTime  = function(self,packetInfo)
    if packetInfo.tid == RoomProxy.getInstance():getTid() then
        RoomProxy.getInstance():setRoomStartTime(packetInfo.startTime)
    end
end

HallSocketProcesser.onRecvServerRoomKickOutUser  = function(self,packetInfo)
    self.m_controller:handleSocketCmd(SERVER_CMD_ROOM_KICK_OUT_USER, packetInfo);
end

HallSocketProcesser.onRecvServerBroadcastUserDisconnect = function(self,packetInfo)
    self.m_controller:handleSocketCmd(SERVER_BROADCAST_USER_DISCONNECT, packetInfo);
end

HallSocketProcesser.onRecvServerBroadcastUserReconnect = function(self,packetInfo)
    self.m_controller:handleSocketCmd(SERVER_BROADCAST_USER_RECONNECT, packetInfo);
end


HallSocketProcesser.onRecvClientCmdForbidUserMsg = function(self,packetInfo)
    self.m_controller:handleSocketCmd(CLIENT_CMD_FORBID_USER_MSG, packetInfo);
end;
HallSocketProcesser.onRecvClientAllocGetPrivateroomInfo = function(self,packetInfo)
    self.m_controller:handleSocketCmd(CLIENT_ALLOC_GET_PRIVATEROOM_INFO, packetInfo);

end

HallSocketProcesser.onRecvServerGiveGift = function(self,packetInfo)
    self.m_controller:handleSocketCmd(CLIIENT_CMD_GIVEGIFT, packetInfo);
end;


HallSocketProcesser.onRecvServerGiftMsg = function(self,packetInfo)
    self.m_controller:handleSocketCmd(OB_CMD_GIVE_GIFT, packetInfo);
end;

HallSocketProcesser.onRecvServerMatchLoginSucRequest = function(self,packetInfo)
    self.m_controller:handleSocketCmd(MATCH_LOGIN_SUC, packetInfo);
end

HallSocketProcesser.onRecvServerMatchGetmatchinfoRequest = function(self,packetInfo)
    self.m_controller:handleSocketCmd(MATCH_GETMATCHINFO, packetInfo);
end

HallSocketProcesser.onRecvServerFastmatchRoundover = function(self,packetInfo)
    self.m_controller:handleSocketCmd(FASTMATCH_ROUNDOVER, packetInfo);
end

HallSocketProcesser.onRecvServerFastmatchSignupRequest = function(self,packetInfo)
    self.m_controller:handleSocketCmd(FASTMATCH_SIGNUP_REQUEST, packetInfo);
end

HallSocketProcesser.onRecvServerFastmatchCanclesignupRequest = function(self,packetInfo)
    self.m_controller:handleSocketCmd(FASTMATCH_CANCLESIGNUP_REQUEST, packetInfo);
end

HallSocketProcesser.onRecvServerFastmatchGetSignupInfo = function(self,packetInfo)
    self.m_controller:handleSocketCmd(FASTMATCH_GET_SIGNUP_INFO, packetInfo);
end

HallSocketProcesser.onRecvServerFastmatchSignupCountNotify = function(self,packetInfo)
    self.m_controller:handleSocketCmd(FASTMATCH_SIGNUP_COUNT_NOTIFY, packetInfo);
end

HallSocketProcesser.onRecvServerFastmatchDropoutNotify = function(self,packetInfo)
    self.m_controller:handleSocketCmd(FASTMATCH_DROPOUT_NOTIFY, packetInfo);
end

HallSocketProcesser.onRecvServerFastmatchEnterroomNotify = function(self,packetInfo)
    self.m_controller:handleSocketCmd(FASTMATCH_ENTERROOM_NOTIFY, packetInfo);
end

HallSocketProcesser.onRecvServerFastmatchEnternextroomNotify = function(self,packetInfo)
    self.m_controller:handleSocketCmd(FASTMATCH_ENTERNEXTROOM_NOTIFY, packetInfo);
end

HallSocketProcesser.onRecvServerFastmatchGiveUp = function(self,packetInfo)
    self.m_controller:handleSocketCmd(FASTMATCH_GIVE_UP, packetInfo);
end

HallSocketProcesser.onFastSignUpList = function(self,packetInfo)
    self.m_controller:handleSocketCmd(FASTMATCH_SIGN_UP_LIST, packetInfo);
end

HallSocketProcesser.onRecvServerMatchGettableinfo = function(self,packetInfo)
    self.m_controller:handleSocketCmd(MATCH_GETTABLEINFO, packetInfo);
end

HallSocketProcesser.onRecvServerMatchGetobtableinfo = function(self,packetInfo)
    self.m_controller:handleSocketCmd(MATCH_GETOBTABLEINFO, packetInfo);
end

HallSocketProcesser.onRecvServerMatchPlayerChangeState = function(self,packetInfo)
    self.m_controller:handleSocketCmd(MATCH_PLAYER_CHANGE_STATE, packetInfo);
end

HallSocketProcesser.onRecvServerMatchLeaveOb = function(self,packetInfo)
    self.m_controller:handleSocketCmd(MATCH_LEAVE_OB, packetInfo);
end

HallSocketProcesser.onRecvServerMatchGetRoundIndex = function(self,packetInfo)
    self.m_controller:handleSocketCmd(MATCH_GET_ROUND_INDEX, packetInfo);
end

HallSocketProcesser.onRecvServerMatchEnterObserveTableRequest = function(self,packetInfo)
    self.m_controller:handleSocketCmd(MATCH_ENTER_OBSERVE_TABLE_REQUEST, packetInfo);
end

HallSocketProcesser.onRecvServerMatchBroadcastTablestep  = function(self,packetInfo)
    self.m_controller:handleSocketCmd(MATCH_BROADCAST_TABLESTEP, packetInfo);
end

HallSocketProcesser.onRecvSignBegin = function( self, packetInfo )
    self.m_controller:handleSocketCmd(COMPETE_SIGN_BEGIN, packetInfo)
end

HallSocketProcesser.onRecvDelaySignEnd = function( self, packetInfo )
    self.m_controller:handleSocketCmd(COMPETE_DELAY_SIGN_END, packetInfo)
end

HallSocketProcesser.onRecvMatchStart = function( self, packetInfo )
    self.m_controller:handleSocketCmd(COMPETE_MATCH_START, packetInfo)
end

HallSocketProcesser.onRecvLateEnterEnd = function( self, packetInfo )
    self.m_controller:handleSocketCmd(COMPETE_LATE_ENTER_END, packetInfo)
end

HallSocketProcesser.onServerReturnsPlayerStatus  = function(self,packetInfo)
    self.m_controller:handleSocketCmd(SERVER_RETURNS_PLAYER_STATUS, packetInfo);
end

HallSocketProcesser.onLoginMatchResponse  = function(self,packetInfo)
    self.m_controller:handleSocketCmd(LOGIN_MATCH_RESPONSE, packetInfo);
end

HallSocketProcesser.onMetierResultMsg  = function(self,packetInfo)
    self.m_controller:handleSocketCmd(METIER_RESULT_MSG, packetInfo);
end

HallSocketProcesser.onUserRequestMatchingResult  = function(self,packetInfo)
    self.m_controller:handleSocketCmd(USER_REQUEST_MATCHING_RESULT, packetInfo);
end

HallSocketProcesser.onGetMatchPlayerInfoResult  = function(self,packetInfo)
    self.m_controller:handleSocketCmd(GET_MATCH_PLAYER_INFO_RESULT, packetInfo);
end

HallSocketProcesser.onCheckOutStatusResult  = function(self,packetInfo)
    self.m_controller:handleSocketCmd(CHECK_OUT_STATUS_RESULT, packetInfo);
end

HallSocketProcesser.onWatchListResponse  = function(self,packetInfo)
    self.m_controller:handleSocketCmd(COMPETE_WATCH_LIST_RESPONSE, packetInfo);
end

HallSocketProcesser.onCheckMatchUserGiftInfoResult = function(self,packetInfo)
    self.m_controller:handleSocketCmd(CHECK_MATCH_USER_GIFT_INFO_RESULT, packetInfo);
end

HallSocketProcesser.onCheckMatchUserMaxScoreResult = function(self,packetInfo)
    self.m_controller:handleSocketCmd(CHECK_MATCH_USER_MAX_SCORE_RESULT, packetInfo);
end

HallSocketProcesser.onMatchEndMatchResult = function(self,packetInfo)
    self.m_controller:handleSocketCmd(MATCH_END_MATCH_RESULT, packetInfo);
end

HallSocketProcesser.onMatchEndResult = function(self,packetInfo)
    self.m_controller:handleSocketCmd(MATCH_END_RESULT, packetInfo);
end

HallSocketProcesser.onMatchStartReminder = function(self,packetInfo)
    self.m_controller:handleSocketCmd(MATCH_START_REMINDER, packetInfo);
end

HallSocketProcesser.onMatchBroadcastOuts = function(self,packetInfo)
    self.m_controller:handleSocketCmd(MATCH_BROADCAST_OUTS, packetInfo);
end

HallSocketProcesser.onMatchBroadcastEvent = function(self,packetInfo)
    self.m_controller:handleSocketCmd(MATCH_BROADCAST_EVENT, packetInfo);
end

HallSocketProcesser.onMatchGetWatchTid = function(self,packetInfo)
    self.m_controller:handleSocketCmd(MATCH_GET_WATCH_TID, packetInfo);
end

HallSocketProcesser.onMatchGetMatchScore = function(self,packetInfo)
    self.m_controller:handleSocketCmd(MATCH_GET_MATCH_SCORE, packetInfo);
end

HallSocketProcesser.onMatchCheckUserRank = function(self,packetInfo)
    self.m_controller:handleSocketCmd(MATCH_CHECK_USER_RANK, packetInfo);
end

HallSocketProcesser.onRecvVipLoginWatchRoom  = function(self,packetInfo)
    self.m_controller:handleSocketCmd(VIP_LOGIN_WATCHROOM, packetInfo);
end

HallSocketProcesser.onRecvServerCharmWatchList = function(self,packetInfo)
    self.m_controller:handleSocketCmd(OB_CMD_GET_CHARM_OB_LIST, packetInfo);
end

HallSocketProcesser.onRecvCheckRoom = function(self,packetInfo)
    self.m_controller:handleSocketCmd(CHECK_ROOM_TYPE, packetInfo);
end

HallSocketProcesser.onRecvWinCombo = function(self,packetInfo)
    self.m_controller:handleSocketCmd(CHECK_WIN_COMBO, packetInfo);
end

HallSocketProcesser.onRecvSociatyNotice = function(self,packetInfo)
    self.m_controller:handleSocketCmd(BROADCAST_SOCIATY_NOTICE, packetInfo);
end

HallSocketProcesser.onGetFreezeUserStatus = function(self,packetInfo)
    self.m_controller:handleSocketCmd(NOTICE_FREEZE_USER, packetInfo);
end

------------------------------------config-----------------------------------
HallSocketProcesser.s_severCmdEventFuncMap = {

    [SERVER_OFFLINE_RECONNECTED]    = HallSocketProcesser.onServerOfflineReconnected;
    [HALL_MSG_HEART]                = HallSocketProcesser.onHallMsgHeart;
	[HALL_MSG_LOGIN]		        = HallSocketProcesser.onHallMsgLogin;
    [HALL_MSG_GAMEINFO]             = HallSocketProcesser.onHallMsgGameInfo;
    [HALL_MSG_GAMEPLAY]             = HallSocketProcesser.onHallMsgGamePlay;
    [HALL_MSG_ALL_PLAY_NUM] = HallSocketProcesser.onHallMsgAllPlayNum;
    [HALL_MSG_KICKUSER]             = HallSocketProcesser.onHallMsgKickUser;
    [HALL_MSG_PRIVATE_ROOM_PLAY_NUM] = HallSocketProcesser.onHallMsgPrivateRoomPlayNum;

    [SERVER_OFFLINE_RECONNECTED]    = HallSocketProcesser.onServerOfflineReconnected;
    [SERVER_MSG_LOGIN_SUCCESS]      = HallSocketProcesser.onRecvClientMsgLoginSuccess;
    [SERVER_MSG_LOGIN_ERROR]        = HallSocketProcesser.onRecvServerMsgLoginError;
    [SERVER_MSG_OTHER_ERROR]        = HallSocketProcesser.onRecvServerMsgOtherError;
    [SERVER_MSG_OPP_USER_INFO]      = HallSocketProcesser.onRecvClientMsgOppUserInfo;
    [SERVER_MSG_USER_READY]         = HallSocketProcesser.onRecvServerMsgUserReady;
    [SERVER_MSG_GAME_START]         = HallSocketProcesser.onRecvServerMsgGameStart;
    [SERVER_MSG_FORESTALL]          = HallSocketProcesser.onRecvServerMsgForestall;
    [SERVER_MSG_FORESTALL_NEW]      = HallSocketProcesser.onRecvServerMsgForestallNew;
    [SERVER_MSG_FORESTALL_320]      = HallSocketProcesser.onRecvServerMsgForestall320;
    [SERVER_MSG_HANDICAP]           = HallSocketProcesser.onRecvServerMsgHandicap;
    [SERVER_MSG_HANDICAP_RESULT]    = HallSocketProcesser.onRecvServerMsgHandicapResult;
    [SERVER_MSG_HANDICAP_CONFIRM]   = HallSocketProcesser.onRecvServerMsgHandicapConfirm; 
    [SERVER_MSG_GAME_START_INFO]    = HallSocketProcesser.onRecvServerMsgGameStartInfo; 
    [SERVER_MSG_HANDICAP_AGREE_RESULT]    = HallSocketProcesser.onRecvServerHandicapAgreeResult; 
    [SERVER_MSG_TIMECOUNT_START]    = HallSocketProcesser.onRecvServerMsgTimeCountStart;
    [SERVER_MSG_RECONNECT]          = HallSocketProcesser.onRecvServerMsgReconnect;
    [SERVER_MSG_USER_LEAVE]         = HallSocketProcesser.onRecvServerMsgUserLeave;
    [SERVER_MSG_LOGOUT_SUCCESS]     = HallSocketProcesser.onRecvServerMsgLogoutSuccess;




    --观战
    [CLIENT_WATCH_LIST]             = HallSocketProcesser.onRecvClientWatchList;
    [CLIENT_WATCH_JOIN]             = HallSocketProcesser.onRecvClientWatchJoin;
    [SERVER_WATCH_START]            = HallSocketProcesser.onRecvServerWatchStart;
    [SERVER_WATCH_MOVE]             = HallSocketProcesser.onRecvServerWatchMove;
    [SERVER_WATCH_DRAW]             = HallSocketProcesser.onRecvServerWatchDraw;
    [SERVER_WATCH_SURRENDER]        = HallSocketProcesser.onRecvServerWatchSurrender;
    [SERVER_WATCH_UNDO]             = HallSocketProcesser.onRecvServerWatchUndo;
    [SERVER_WATCH_USERLEAVE]        = HallSocketProcesser.onRecvServerWatchUserLeave; 
    [SERVER_WATCH_GAMEOVER]         = HallSocketProcesser.onRecvServerWatchGameOver;
    [SERVER_WATCH_ALLREADY]         = HallSocketProcesser.onRecvServerWatchAllReady;
    [SERVER_WATCH_ERROR]            = HallSocketProcesser.onRecvServerWatchError;
    [CLIENT_WATCH_CHAT]             = HallSocketProcesser.onRecvClientWatchChat;

    [CLIENT_MSG_FORESTALL]          = HallSocketProcesser.onRecvClientMsgForestall;
    [CLIENT_MSG_SYNCHRODATA]        = HallSocketProcesser.onRecvClientRoomSyn;
    [CLIENT_MSG_WATCHLIST]          = HallSocketProcesser.onRecvClientMsgWatchlist;
    [CLIENT_GET_OPENBOX_TIME]       = HallSocketProcesser.onRecvClientGetOpenboxTime;
    [CLIENT_MSG_CHAT]               = HallSocketProcesser.onRecvClientMsgChat;
    [CLIENT_MSG_HANDICAP]           = HallSocketProcesser.onRecvClientMsgHandicap;
    [CLIENT_MSG_MOVE]               = HallSocketProcesser.onRecvClientMsgMove;


    --求和
    [CLIENT_MSG_DRAW1]              = HallSocketProcesser.onRecvClientMsgDraw1;
    [CLIENT_MSG_DRAW2]              = HallSocketProcesser.onRecvClientMsgDraw2;
    [SERVER_MSG_DRAW]               = HallSocketProcesser.onRecvServerMsgDraw;

    --悔棋
    [CLIENT_MSG_UNDOMOVE]           = HallSocketProcesser.onRecvClientMsgUndomove;
    [SET_TIME_INFO]                 = HallSocketProcesser.onRecvSetTimeInfo;
    --认输
    [CLIENT_MSG_SURRENDER1]         = HallSocketProcesser.onRecvClientMsgSurrender1;
    [CLIENT_MSG_SURRENDER2]         = HallSocketProcesser.onRecvClientMsgSurrender2;
    [SERVER_MSG_SURRENDER]          = HallSocketProcesser.onRecvServerMsgSurrender;

    [SERVER_MSG_GAME_CLOSE]         = HallSocketProcesser.onRecvServerMsgGameClose;
    [SERVER_MSG_WARING]             = HallSocketProcesser.onRecvServerMsgWarning;
    [SERVER_MSG_TIPS]               = HallSocketProcesser.onRecvServerMsgTips;



    [CLIENT_HALL_PRIVATEROOM_LIST]  = HallSocketProcesser.onRecvHallPrivateRoomList;
    [CLIENT_HALL_CREATE_PRIVATEROOM]= HallSocketProcesser.onRecvHallCreatePrivateRoom;
    [CLIENT_HALL_JOIN_PRIVATEROOM]  = HallSocketProcesser.onRecvHallJoinPrivateRoom;
    [CLIENT_HALL_BROADCAST_MGS]     = HallSocketProcesser.onRecvClientHallBroadcastMsg;

    -- friends  cmd 
    [FRIEND_CMD_ONLINE_NUM]         = HallSocketProcesser.onRecvFriendCmdOnlineNum;
    [FRIEND_CMD_CHECK_USER_STATUS]  = HallSocketProcesser.onRecvFriendCmdCheckUserStatus;
    [FRIEND_CMD_CHECK_USER_DATA]    = HallSocketProcesser.onRecvFriendCmdCheckUserData;
    [FRIEND_CMD_GET_FRIENDS_NUM]    = HallSocketProcesser.onRecvFriendCmdGetFriendsNum;
    [FRIEND_CMD_GET_FOLLOW_NUM]     = HallSocketProcesser.onRecvFriendCmdGetFollowNum;
    [FRIEND_CMD_GET_FANS_NUM]       = HallSocketProcesser.onRecvFriendCmdGetFansNum;
    [FRIEND_CMD_GET_FRIENDS_LIST]   = HallSocketProcesser.onRecvFriendCmdGetFriendsList;
    [FRIEND_CMD_GET_FOLLOW_LIST]    = HallSocketProcesser.onRecvFriendCmdGetFollowList;
    [FRIEND_CMD_GET_FANS_LIST]      = HallSocketProcesser.onRecvFriendCmdGetFansList;
    [FRIEND_CMD_GET_UNREAD_MSG]     = HallSocketProcesser.onRecvFriendCmdGetUnreadMsg;
    [FRIEND_CMD_ADD_FLLOW]          = HallSocketProcesser.onRecvFriendCmdGetFollow;
    [FRIEND_CMD_CHAT_MSG]           = HallSocketProcesser.onRecvFriendChatMsg;
    [FRIEND_CMD_CHAT_MSG2]           = HallSocketProcesser.onRecvFriendChatMsg2; -- 2.0.5之后使用
    [FRIEND_CMD_SCORE_RANK]          = HallSocketProcesser.onRecvFriendCmdGetFriendsRank;
    [FRIEND_CMD_CHECK_PLAYER_RANK]   = HallSocketProcesser.onRecvFriendCmdGetOnlyFriendsRank;


    [CLIENT_HALL_CREATE_FRIENDROOM] = HallSocketProcesser.onRecvServerCreateFriendRoom;    --创建好友房
    [FRIEND_CMD_FRIEND_INVIT_RESPONSE]=  HallSocketProcesser.onRecvServerInvitResponse;
    [FRIEND_CMD_FRIEND_INVIT_RESPONSE2]=  HallSocketProcesser.onRecvServerInvitResponse2;
    [FRIEND_CMD_FRIEND_INVITE_REQUEST] = HallSocketProcesser.onRecvServerInvitRequest;
    [FRIEND_CMD_FRIEND_INVIT_NOTIFY] = HallSocketProcesser.onRecvServerInvitNotify;

    --聊天室私人房邀请
    [FRIEND_CMD_GET_USER_STATUS]            = HallSocketProcesser.onRecvServerCheckUserState;       --聊天室被挑战者是否在线
    [STRANGER_CMD_INVITE_REQUEST]           = HallSocketProcesser.onRecvCustomStrangerInvite;       --发起挑战请求响应
    [STRANGER_CMD_INVIT_NOTIFY]             = HallSocketProcesser.onRecvServerCustomInvite;         --被挑战者接收server的通知
    [STRANGER_CMD_INVIT_RESPONSE]           = HallSocketProcesser.onRecvCustomInviteResp;           --被挑战者是否接受挑战

    [SERVER_BROADCAST_SET_TIME]             = HallSocketProcesser.onRecvServerSetTime;    --设置时间（读写）
    [SERVER_BROADCAST_SET_TIME_NOTIFY]      = HallSocketProcesser.onRecvServerSetTimeNotify;    --服务器通知设置时间结果（读）
    [SERVER_BROADCAST_SET_TIME_RESPONSE]    = HallSocketProcesser.onRecvServerSetTimeResponse;    --是否同意设置时间结果（读写）
    [CLIIENT_CMD_RESET_TABLE]               = HallSocketProcesser.onRecvServerResetTable;           --重置房间状态（读写）

    [OB_CMD_CHAT_MSG]               = HallSocketProcesser.onRecvServerWatchMsg;              --观战聊天（读写）
    [OB_CMD_GET_TABLE_INFO]         = HallSocketProcesser.onRecvServerTableInfo;              --获取桌子信息(读写)
    [OB_CMD_GET_OB_LIST]            = HallSocketProcesser.onRecvServerWatchList;              --获取观战列表（读写）
    [OB_CMD_PLAYER_ENTER]           = HallSocketProcesser.onRecvServerPlayerEnter;              --广播玩家进入（读）
    [OB_CMD_PLAYER_LEAVE]           = HallSocketProcesser.onRecvServerPlayerLeave;              --广播玩家离开(读)
    [OB_CMD_UPDATE_TABLE_STATUS]    = HallSocketProcesser.onRecvServerUpdateTable;              --同步更新桌子状态（）
    [OB_CMD_GAMESTART]              = HallSocketProcesser.onRecvServerGameStart;              --游戏开始（读） 
    [OB_CMD_CHESS_MOVE]             = HallSocketProcesser.onRecvServerChessMove;              --广播走棋（读）
    [OB_CMD_CHESS_UNDOMOVE]         = HallSocketProcesser.onRecvServerChessUndo;              --悔棋（读）
    [OB_CMD_CHESS_DRAW]             = HallSocketProcesser.onRecvServerChessDraw;              --求和（读）
    [OB_CMD_CHESS_SURRENDER]        = HallSocketProcesser.onRecvServerChessSurrender;              --认输（读）
    [OB_CMD_GAMEOVER]               = HallSocketProcesser.onRecvServerGameOver;              --游戏结束（读）
    [OB_CMD_GET_NUM]                = HallSocketProcesser.onRecvServerGetNumber;              --观战人数（读写）
    [OB_CMD_GET_HISTORY_MSGS]       = HallSocketProcesser.onRecvServerNewHistoryMsgs;         --观战历史消息（读写）

    [FRIEND_CMD_GET_FRIEND_OB_LIST] = HallSocketProcesser.onRecvServerFriendsWatchList;      --棋友观战列表（读写）
    [OB_CMD_GET_CHARM_OB_LIST]      = HallSocketProcesser.onRecvServerCharmWatchList;      --魅力榜观战列表（读写）
    --chatRoom
    [CHATROOM_CMD_ENTER_ROOM]               = HallSocketProcesser.onRecvServerEntryChatRoom;
    [CHATROOM_CMD_LEAVE_ROOM]               = HallSocketProcesser.onRecvServerLeftChatRoom;
    [CHATROOM_CMD_GET_UNREAD_MSG]           = HallSocketProcesser.onRecvServerLastMsg;   --获得未读消息数量
    [CHATROOM_CMD_USER_CHAT_MSG]            = HallSocketProcesser.onRecvServerUserMsg;      --用户发送聊天信息
    [CHATROOM_CMD_BROAdCAST_CHAT_MSG]       = HallSocketProcesser.onRecvClientChatMsg;
    [CHATROOM_CMD_GET_HISTORY_MSG]          = HallSocketProcesser.onRecvServerUnreadMsg;
    [CHATROOM_CMD_GET_UNREAD_MSG2]          = HallSocketProcesser.onRecvServerUnreadMsgNum;
    [CHATROOM_CMD_GET_MEMBER_LIST]          = HallSocketProcesser.onRecvServerGetMemberList;
    [CHATROOM_CMD_IS_ACT_AVALIABLE]         = HallSocketProcesser.onRecvServerIsActAvaliable;
    [CHATROOM_CMD_UPDATE_CHATROOM_ITEM]     = HallSocketProcesser.onRecvServerUpdateCRItem;
    [CHATROOM_CMD_GET_HISTORY_MSG_NEW]      = HallSocketProcesser.onRecvServerUnreadMsgNew;
    [CHATROOM_CMD_GET_CHESS_MATCH_MSG]      = HallSocketProcesser.onRecvServerChessMatchMsg;
    [CHATROOM_CMD_GET_CHESS_MATCH_MSG_NUM]  = HallSocketProcesser.onRecvServerChessMatchMsgNum;
    -- prop
    [PROP_CMD_UPDATE_USERDATA]              = HallSocketProcesser.onRecvServerPropCmdUpdateUserData; -- 更新道具
    [PROP_CMD_QUERY_USERDATA]               = HallSocketProcesser.onRecvServerPropCmdQueryUserData;    -- 查询道具
    -- 私人房个数
    [CLIENT_ALLOC_PRIVATEROOMNUM]           = HallSocketProcesser.onRecvServerClientAllocPrivateRoomNum;
    -- 观战和挑战数据
    [FRIEND_CMD_GET_PLAYER_INFO]            = HallSocketProcesser.onRecvServerFriendCmdGeetPlayerInfo;
    [CLIENT_CMD_GETTABLESTEP]               = HallSocketProcesser.onRecvServerClientCmdGetTableStep;
    -- 获取当前棋局开始时间
    [CLIENT_GET_CUR_TID_START_TIME]         = HallSocketProcesser.onClientGetCurTidStartTime;
    -- 私人房被踢
    [SERVER_CMD_ROOM_KICK_OUT_USER]         = HallSocketProcesser.onRecvServerRoomKickOutUser;
    -- 私人房请求房间tid 和 pwd
    [CLIENT_ALLOC_GET_PRIVATEROOM_INFO]     = HallSocketProcesser.onRecvClientAllocGetPrivateroomInfo;

    
    [SERVER_BROADCAST_USER_DISCONNECT]      = HallSocketProcesser.onRecvServerBroadcastUserDisconnect;
    [SERVER_BROADCAST_USER_RECONNECT]       = HallSocketProcesser.onRecvServerBroadcastUserReconnect;

        -- 联网房间屏蔽消息
    [CLIENT_CMD_FORBID_USER_MSG]            = HallSocketProcesser.onRecvClientCmdForbidUserMsg;

        -- 玩家送礼物结果
    [CLIIENT_CMD_GIVEGIFT]                  = HallSocketProcesser.onRecvServerGiveGift;

        --广播接收礼物消息
    [OB_CMD_GIVE_GIFT]                      = HallSocketProcesser.onRecvServerGiftMsg;
    
    --比赛房间登录结果
    [MATCH_LOGIN_SUC]                       = HallSocketProcesser.onRecvServerMatchLoginSucRequest;
    -- 获得比赛战况
    [MATCH_GETMATCHINFO]                    = HallSocketProcesser.onRecvServerMatchGetmatchinfoRequest;
--  比赛房间结果通知
    [FASTMATCH_ROUNDOVER]                   = HallSocketProcesser.onRecvServerFastmatchRoundover;
    -- 报名
    [FASTMATCH_SIGNUP_REQUEST]              = HallSocketProcesser.onRecvServerFastmatchSignupRequest;
    -- 取消报名
    [FASTMATCH_CANCLESIGNUP_REQUEST]        = HallSocketProcesser.onRecvServerFastmatchCanclesignupRequest;
    -- 比赛房间信息
    [FASTMATCH_GET_SIGNUP_INFO]             = HallSocketProcesser.onRecvServerFastmatchGetSignupInfo;
    
    -- 报名人数变动通知 
    [FASTMATCH_SIGNUP_COUNT_NOTIFY]         = HallSocketProcesser.onRecvServerFastmatchSignupCountNotify;
    -- server主动通知退出报名 
    [FASTMATCH_DROPOUT_NOTIFY]              = HallSocketProcesser.onRecvServerFastmatchDropoutNotify;
    -- 比赛进入通知 
    [FASTMATCH_ENTERROOM_NOTIFY]            = HallSocketProcesser.onRecvServerFastmatchEnterroomNotify;
    -- 下一场比赛进入通知 
    [FASTMATCH_ENTERNEXTROOM_NOTIFY]        = HallSocketProcesser.onRecvServerFastmatchEnternextroomNotify;
    -- 速赛，放弃比赛
    [FASTMATCH_GIVE_UP]                     = HallSocketProcesser.onRecvServerFastmatchGiveUp;
    -- 速战，报名列表
    [FASTMATCH_SIGN_UP_LIST]                = HallSocketProcesser.onFastSignUpList; 
    -- 获取比赛桌子信息
    [MATCH_GETTABLEINFO]                    = HallSocketProcesser.onRecvServerMatchGettableinfo;
    -- 获取观战的比赛桌子信息
    [MATCH_GETOBTABLEINFO]                  = HallSocketProcesser.onRecvServerMatchGetobtableinfo;
    -- 玩家在比赛中的状态改变
    [MATCH_PLAYER_CHANGE_STATE]             = HallSocketProcesser.onRecvServerMatchPlayerChangeState;
    -- 玩家在比赛中退出观战
    [MATCH_LEAVE_OB]                        = HallSocketProcesser.onRecvServerMatchLeaveOb;
    -- 玩家在比赛中退出观战
    [MATCH_GET_ROUND_INDEX]                 = HallSocketProcesser.onRecvServerMatchGetRoundIndex;
    -- 比赛进去观战桌子
    [MATCH_ENTER_OBSERVE_TABLE_REQUEST]     = HallSocketProcesser.onRecvServerMatchEnterObserveTableRequest;
    [MATCH_BROADCAST_TABLESTEP]             = HallSocketProcesser.onRecvServerMatchBroadcastTablestep;
    
    --职业赛
    -- 通知报名开始
    [COMPETE_SIGN_BEGIN]                    = HallSocketProcesser.onRecvSignBegin;
    -- 通知延时报名结束
    [COMPETE_DELAY_SIGN_END]                = HallSocketProcesser.onRecvDelaySignEnd;
    -- 通知比赛开始
    [COMPETE_MATCH_START]                   = HallSocketProcesser.onRecvMatchStart;
    -- 通知迟到进入结束
    [COMPETE_LATE_ENTER_END]                = HallSocketProcesser.onRecvLateEnterEnd;
    -- 服务器返回玩家状态
    [SERVER_RETURNS_PLAYER_STATUS]          = HallSocketProcesser.onServerReturnsPlayerStatus;
    -- 登录比赛结果返回
    [LOGIN_MATCH_RESPONSE]                  = HallSocketProcesser.onLoginMatchResponse;
    [METIER_RESULT_MSG]                     = HallSocketProcesser.onMetierResultMsg;
	-- 请求比赛匹配结果返回
    [USER_REQUEST_MATCHING_RESULT]          = HallSocketProcesser.onUserRequestMatchingResult;
    [GET_MATCH_PLAYER_INFO_RESULT]          = HallSocketProcesser.onGetMatchPlayerInfoResult;
    [CHECK_OUT_STATUS_RESULT]               = HallSocketProcesser.onCheckOutStatusResult;
    -- 观战列表数据
    [COMPETE_WATCH_LIST_RESPONSE]           = HallSocketProcesser.onWatchListResponse;
    [CHECK_MATCH_USER_GIFT_INFO_RESULT]     = HallSocketProcesser.onCheckMatchUserGiftInfoResult;
    [CHECK_MATCH_USER_MAX_SCORE_RESULT]     = HallSocketProcesser.onCheckMatchUserMaxScoreResult;
    [MATCH_END_MATCH_RESULT]                = HallSocketProcesser.onMatchEndMatchResult;
    [MATCH_END_RESULT]                      = HallSocketProcesser.onMatchEndResult;
    [MATCH_START_REMINDER]                  = HallSocketProcesser.onMatchStartReminder;
    --赛况播报
    [MATCH_BROADCAST_OUTS]                  = HallSocketProcesser.onMatchBroadcastOuts;
    --比赛事件播报
    [MATCH_BROADCAST_EVENT]                 = HallSocketProcesser.onMatchBroadcastEvent;
    --获取新的观战桌子
    [MATCH_GET_WATCH_TID]                   = HallSocketProcesser.onMatchGetWatchTid;
    --获取比赛积分
    [MATCH_GET_MATCH_SCORE]                 = HallSocketProcesser.onMatchGetMatchScore;
    --查询用户比赛排名
    [MATCH_CHECK_USER_RANK]                 = HallSocketProcesser.onMatchCheckUserRank;
    --职业赛 end

    --VIP玩家进入观战房
    [VIP_LOGIN_WATCHROOM]                   = HallSocketProcesser.onRecvVipLoginWatchRoom;

    [CHECK_ROOM_TYPE]                       = HallSocketProcesser.onRecvCheckRoom;
    [CHECK_WIN_COMBO]                       = HallSocketProcesser.onRecvWinCombo;

    [BROADCAST_SOCIATY_NOTICE]              = HallSocketProcesser.onRecvSociatyNotice;

    [NOTICE_FREEZE_USER]                    = HallSocketProcesser.onGetFreezeUserStatus;
};

	
HallSocketProcesser.s_severCmdEventFuncMap = CombineTables(HallSocketProcesser.s_severCmdEventFuncMap,
	{});
