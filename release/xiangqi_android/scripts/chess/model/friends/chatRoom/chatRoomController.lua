require(MODEL_PATH .. "friends/friendChat/friendChatController");
require(BASE_PATH .. "chessController");
require("config/path_config");

ChatRoomController = class(ChessController);

ChatRoomController.s_cmds = 
{
	onBack = 1;
	send_msg = 2;
}

ChatRoomController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
    self.m_lastMsg = state.m_lastMsgData;
    self.m_roomData = state.m_room_data;	
    self:initChatView();
end

ChatRoomController.resume = function(self)
	ChessController.resume(self);
	local infoTab = ChatRoomData.getInstance():getString(GameCacheData.CHAT_USER_INFO .. "user_info", nil);
    self.m_user_info = json.decode(infoTab);
    self:toGetHistoryMsg();
end   

ChatRoomController.pause = function(self)
	ChessController.pause(self);
    local time = os.time();
    local room_id = self.m_roomData.id;
    ChatRoomData.getInstance():saveInt(GameCacheData.QUIT_ROOM_TIME,time);
    ChatRoomData.getInstance():saveInt(GameCacheData.LAST_ENTRY_ROOM_ID,room_id);
    ChatRoomData.getInstance():saveRoomData(room_id,time);
end

ChatRoomController.dtor = function(self)

end


ChatRoomController.onBack = function(self)
	local info = {};
	local time = os.time();
	info.room_id = self.m_roomData.id;
	info.uid = UserInfo.getInstance():getUid();
	self:sendSocketMsg(CHATROOM_CMD_LEAVE_ROOM,info);
end

ChatRoomController.onSendMsg = function(self, data)
	self:sendSocketMsg(CHATROOM_CMD_USER_CHAT_MSG, data);	
end

--------------------about socket and http and native func----------------------
--历史未读消息
ChatRoomController.onRecvServerUnreadMsg = function(self, packetInfo)
    local msgUnread = {};
    local total_num = packetInfo.total_count;
    local roomId = packetInfo.room_id;
    local page_num = packetInfo.page_num;
    local curr_page = packetInfo.curr_page;
    local item_num = packetInfo.item_num;
    if page_num == 0 then
--        self:updateView(FriendChatScene.s_cmds.get_history_msg,self.m_history);
        return;
    end

    msgItem = packetInfo.item;
    for i = 1,item_num do 
        msgUnread[i] = json.decode(msgItem[i]);
    end
    
    ChatRoomData.getInstance():saveHistoryMsg(msgUnread,roomId);

    local tab = msgUnread;
    local unUpdataUserData = {};
    if self.m_user_info  then
        for i,v in pairs(msgUnread) do
            for m,n in pairs(self.m_user_info) do
                if v.uid == n.uid then
                    table.insert(unUpdataUserData,v);
                    break;
                end
            end
        end
    end

    if #unUpdataUserData ~= #tab then
        local post_data = {};
        post_data.mid_arr = {};
        for i = 1,#tab do
            post_data.mid_arr["mid"..i] = tab[i].uid;
        end
        HttpModule.getInstance():execute(HttpModule.s_cmds.getFriendUserInfo,post_data);
    end

    self:updateView(ChatRoomScene.s_cmds.get_history_msg,msgUnread,total_num,curr_page);
end

ChatRoomController.onRecvServerUserMsg = function(self, data)
	self:updateView(ChatRoomScene.s_cmds.send_msg_status,data);

end

ChatRoomController.onRecvServerLeftChatRoom = function(self, packetInfo)
	if packetInfo.status == 0 then
        StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
        --保存最后聊天记录和历史消息
    else
        -- 退出房间失败
    end
end

ChatRoomController.onRecvServerChatMsg = function(self, packetInfo)
	local msgtab = json.decode(packetInfo.msg_json);
    self.m_lastMsgTime = msgtab.time;  

    local infoTab = ChatRoomData.getInstance():getString(GameCacheData.CHAT_USER_INFO .. "user_info",nil);
    self.m_user_info = json.decode(infoTab);

    local msginfo = {};
    local msgData = {};
    msginfo.room_id = packetInfo.room_id;
    msginfo.uid = msgtab.uid
    msginfo.msg_time = msgtab.time;
    msginfo.msg_id = msgtab.msg_id;

    msgData.uid = msgtab.uid;
    msgData.time = msgtab.time + 1;
    msgData.msg = msgtab.msg;
    msgData.msg_id = msgtab.msg_id;

    local post_data = {};
    post_data.mid_arr = {};
    post_data.mid_arr["mid"..1] = msgtab.uid;
    self:sendSocketMsg(CHATROOM_CMD_BROAdCAST_CHAT_MSG,msginfo);
    self:saveMsg(msgData,packetInfo.room_id);
   
    if msgtab.uid == UserInfo.getInstance():getUid() then
        self:updateView(ChatRoomScene.s_cmds.recv_chat_msg,msgData,nil,true);
        return;
    end
    
    if self.m_user_info then       
        for i,v in pairs(self.m_user_info) do
            if v.uid == msgtab.uid then
                self:updateView(ChatRoomScene.s_cmds.recv_chat_msg,msgtab,v);
                return;
            end
        end
    end
    HttpModule.getInstance():execute(HttpModule.s_cmds.getFriendUserInfo,post_data);
    self:updateView(ChatRoomScene.s_cmds.recv_chat_msg,msgtab);

end

ChatRoomController.onFriendCmdCheckUserData = function(self, isSuccess, message)
    if isSuccess then
        local tab = {};
        local info = {};
        local data = message.data;
        for i,v in pairs(data) do
            local item = {};
            item.uid = tonumber(v.mid:get_value()) or 0;
            item.mnick = v.mnick:get_value() or "";
            item.mactivetime = v.mactivetime:get_value() or 0;
            item.iconType = v.iconType:get_value() or 0;
            item.score = tonumber(v.score:get_value()) or 0;
            item.money = tonumber(v.money:get_value()) or 0;
            item.drawtimes = tonumber(v.drawtimes:get_value()) or 0;
            item.wintimes = tonumber(v.wintimes:get_value()) or 0;
            item.losetimes = tonumber(v.losetimes:get_value()) or 0;
            item.icon_url = v.icon_url:get_value();
            item.rank = tonumber(v.rank:get_value()) or 0;
            item.sex = tonumber(v.sex:get_value()) or 0;
            table.insert(info,item);
            --info = item;
            tab = item;
        end
        ChatRoomData.getInstance():saveChatOtherUserInfo(info);
        -- 更新其他玩家信息
        local infoTab = ChatRoomData.getInstance():getString(GameCacheData.CHAT_USER_INFO .. "user_info",nil);
        self.m_user_info = json.decode(infoTab);
        -----------
        self:updateView(ChatRoomScene.s_cmds.change_other_icon,info);
    end
end

ChatRoomController.onGetDownloadImage = function(self)
    Log.i("FriendChatController.onGetDownloadImage");
    if not flag then 
        --下载失败
    end
    local info = json.analyzeJsonNode(data);
    for i,v in pairs(info) do
        Log.i(i ..":".. v );
    end
    self:updateView(ChatRoomScene.s_cmds.change_friend_icon, info);
end
--------------------------------------------------------------------------------
ChatRoomController.initChatView = function(self)
    local roomId = self.m_roomData.id;
    local historyMsg = ChatRoomData.getInstance():getHistoryMsg(roomId);
    local chatMsg = {};
    if not historyMsg then
        return;
    end
    if #historyMsg > 50 then
        local num = 50
        local index = #historyMsg;
        while num > 0 do
            chatMsg[num] = historyMsg[index];
            index = index - 1;
            num = num - 1;
        end
    else
        chatMsg = historyMsg;
    end
    self:updateView(ChatRoomScene.s_cmds.init_msg,chatMsg);
end

ChatRoomController.toGetHistoryMsg = function(self)
    local roomId = self.m_roomData.id;
--    self.m_roomLastData = ChatRoomData.getInstance():getLastRoomMsg(roomId);
    local info = {};
    info.uid = UserInfo.getInstance():getUid();
    info.room_id = roomId;
    info.last_msg_time = ChatRoomData.getInstance():getInt(GameCacheData.QUIT_ROOM_TIME);
    info.entry_room_time = os.time();

    if roomId == ChatRoomData.getInstance():getInt(GameCacheData.LAST_ENTRY_ROOM_ID,0) then
        self:sendSocketMsg(CHATROOM_CMD_GET_HISTORY_MSG,info);
    end
end

ChatRoomController.saveMsg = function(self,msgData,room_id)
    ChatRoomData.getInstance():saveRecvMsg(msgData,room_id);
end

------------------------------ config -----------------------------------
ChatRoomController.s_httpRequestsCallBackFuncMap = 
{
	[HttpModule.s_cmds.getFriendUserInfo] = ChatRoomController.onFriendCmdCheckUserData;
}

ChatRoomController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap, 
	ChatRoomController.s_httpRequestsCallBackFuncMap or {});

ChatRoomController.s_nativeEventFuncMap = 
{
	[kCacheImageManager] = ChatRoomController.onGetDownloadImage;
	[kNetStateResume] = ChatRoomController.onNetStateResume;
}

ChatRoomController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	ChatRoomController.s_nativeEventFuncMap or {});

ChatRoomController.s_socketCmdFuncMap = 
{
	[CHATROOM_CMD_GET_HISTORY_MSG]    = ChatRoomController.onRecvServerUnreadMsg;
    [CHATROOM_CMD_USER_CHAT_MSG]      = ChatRoomController.onRecvServerUserMsg;
    [CHATROOM_CMD_LEAVE_ROOM]         = ChatRoomController.onRecvServerLeftChatRoom;
    [CHATROOM_CMD_BROAdCAST_CHAT_MSG] = ChatRoomController.onRecvServerChatMsg;
}

ChatRoomController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	ChatRoomController.s_socketCmdFuncMap or {});

ChatRoomController.s_cmdConfig = 
{
	[ChatRoomController.s_cmds.onBack] = ChatRoomController.onBack;
	[ChatRoomController.s_cmds.send_msg] = ChatRoomController.onSendMsg;
}
