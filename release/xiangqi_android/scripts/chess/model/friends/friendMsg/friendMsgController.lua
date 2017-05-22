--region friendMsgController.lua
--Author : LeoLi
--Date   : 2015/7/14

require("config/path_config");

require(BASE_PATH.."chessController");

FriendMsgController = class(ChessController);

FriendMsgController.s_cmds = 
{	
    onBack = 1;
    updateLocal = 2;
    updataUnReadNum = 3;
    toEntryChatRoom = 4;
};

FriendMsgController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end


FriendMsgController.resume = function(self)
	ChessController.resume(self);
    --self:getRoomData();
    --self:sendSocketMsg(OB_CMD_GET_OB_LIST,info);
end


FriendMsgController.exit_action = function(self)
	sys_exit();
end

FriendMsgController.pause = function(self)
	ChessController.pause(self);
	Log.i("FriendMsgController.pause");
end

FriendMsgController.dtor = function(self)

end

-------------------------------- father func -----------------------



-------------------------------- function --------------------------
FriendMsgController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end


FriendMsgController.onUpdateUserData = function(self, data)
    self:updateView(FriendMsgScene.s_cmds.changeFriendsData,data);
end;

FriendMsgController.onUpdateUserMsg = function(self, data)
    self:updateView(FriendMsgScene.s_cmds.changeFriendsMsg,data);
end;

FriendMsgController.onGetDownloadImage = function(self, flag, data)
    Log.i("FriendMsgController.onGetDownloadImage");
    if not flag then 
        --下载失败
    end
    local info = json.analyzeJsonNode(data);
    for i,v in pairs(info) do
        Log.i(i ..":".. v );
    end
    self:updateView(FriendMsgScene.s_cmds.changeFriendsIcon,info);
end;

FriendMsgController.updataRoomMsgNum = function(self,packetInfo)
--    self:sendSocketMsg(CHATROOM_CMD_GET_UNREAD_MSG,packetInfo);
    self:sendSocketMsg(CHATROOM_CMD_GET_UNREAD_MSG2,packetInfo);
end

FriendMsgController.toEntryChatRoom = function(self,roomData)
    local packetInfo = {};
    packetInfo.room_id = roomData.id;
    self:sendSocketMsg(CHATROOM_CMD_ENTER_ROOM,packetInfo);
end

FriendMsgController.onRecvServerEntryChatRoom = function(self,packetInfo)
    self:updateView(FriendMsgScene.s_cmds.entryChatRoom,packetInfo);
end

FriendMsgController.onRecvServerUnreadMsgNum = function(self,packetInfo)
    self:updateView(FriendMsgScene.s_cmds.unreadNum,packetInfo);
end

-------------------------------- config ----------------------------

FriendMsgController.s_httpRequestsCallBackFuncMap  = {
};

FriendMsgController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	FriendMsgController.s_httpRequestsCallBackFuncMap or {});


--本地事件 包括lua dispatch call事件
FriendMsgController.s_nativeEventFuncMap = {

   [kFriend_UpdateUserData]             = FriendMsgController.onUpdateUserData;
   [kFriend_UpdateChatMsg]              = FriendMsgController.onUpdateUserMsg;
   [kCacheImageManager]                 = FriendMsgController.onGetDownloadImage;
};


FriendMsgController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	FriendMsgController.s_nativeEventFuncMap or {});



FriendMsgController.s_socketCmdFuncMap = {
--	[HALL_SINGLE_BROADCARD_CMD_MSG]  = FriendMsgController.onSingleBroadcastCallback;
    [CHATROOM_CMD_ENTER_ROOM]               = FriendMsgController.onRecvServerEntryChatRoom;
    [CHATROOM_CMD_GET_UNREAD_MSG]           = FriendMsgController.onRecvServerLastMsg; -- 获得未读消息数量
    [CHATROOM_CMD_GET_UNREAD_MSG2]           = FriendMsgController.onRecvServerUnreadMsgNum; -- 获得未读消息数量 (时间)
}

FriendMsgController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	FriendMsgController.s_socketCmdFuncMap or {});


------------------------------------- 命令响应函数配置 ------------------------
FriendMsgController.s_cmdConfig = 
{
    [FriendMsgController.s_cmds.onBack] = FriendMsgController.onBack;
    [FriendMsgController.s_cmds.updateLocal] = FriendMsgController.updateLocal;
    [FriendMsgController.s_cmds.updataUnReadNum] = FriendMsgController.updataRoomMsgNum;
    [FriendMsgController.s_cmds.toEntryChatRoom] = FriendMsgController.toEntryChatRoom;
}