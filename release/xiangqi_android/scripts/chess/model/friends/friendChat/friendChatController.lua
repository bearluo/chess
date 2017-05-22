--region FriendChatController.lua
--Author : LeoLi
--Date   : 2015/7/16

require("config/path_config");

require(BASE_PATH.."chessController");

FriendChatController = class(ChessController);

FriendChatController.s_cmds = 
{	
    onBack = 1;
    send_msg = 2;
    fight = 3;
};

FriendChatController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end


FriendChatController.resume = function(self)
	ChessController.resume(self);
end


FriendChatController.exit_action = function(self)
	sys_exit();
end

FriendChatController.pause = function(self)
	ChessController.pause(self);
	Log.i("FriendChatController.pause");
end

FriendChatController.dtor = function(self)
    if self.m_forbid_dialog then
        delete(self.m_forbid_dialog);
        self.m_forbid_dialog = nil;
    end;
end

-------------------------------- father func -----------------------



-------------------------------- function --------------------------
FriendChatController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end



FriendChatController.onSendMsg = function(self, data)
    self:sendSocketMsg(FRIEND_CMD_CHAT_MSG, data);
end;

FriendChatController.onFight = function(self,post_data)
    self:onCreateFriendRoom(post_data);
end;

FriendChatController.onReceFriendMsg = function(self, data)
    self:updateView(FriendChatScene.s_cmds.recv_friend_msg, data);
end;

FriendChatController.onGetDownloadImage = function(self, flag, data)
    Log.i("FriendChatController.onGetDownloadImage");
    if not flag then 
        --下载失败
    end
    local info = json.analyzeJsonNode(data);
    for i,v in pairs(info) do
        Log.i(i ..":".. v );
    end
    self:updateView(FriendChatScene.s_cmds.change_friend_icon, info);

end;


FriendChatController.onNetStateResume = function(self)
    Log.i("FriendChatController.onNetStateResume");   
    self:updateView(FriendChatScene.s_cmds.resend_chat_msg);
end;

FriendChatController.isForbidSendMsg = function(self,packetInfo)
    if packetInfo.forbid_time and packetInfo.forbid_time > 0 then
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

FriendChatController.onReceChatMsgState = function(self, packetInfo)
    if self:isForbidSendMsg(packetInfo) then return end;  
    self:updateView(FriendChatScene.s_cmds.recv_chat_msg_state, packetInfo);
end;

-------------------------------- config ----------------------------

FriendChatController.s_httpRequestsCallBackFuncMap  = {
};

FriendChatController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	FriendChatController.s_httpRequestsCallBackFuncMap or {});


--本地事件 包括lua dispatch call事件
FriendChatController.s_nativeEventFuncMap = {

    [kFriend_UpdateChatMsg]     = FriendChatController.onReceFriendMsg;
    [kCacheImageManager]        = FriendChatController.onGetDownloadImage;
    [kNetStateResume]           = FriendChatController.onNetStateResume;
};


FriendChatController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	FriendChatController.s_nativeEventFuncMap or {});



FriendChatController.s_socketCmdFuncMap = {
--	[HALL_SINGLE_BROADCARD_CMD_MSG]  = FriendChatController.onSingleBroadcastCallback;
    [FRIEND_CMD_CHAT_MSG]   = FriendChatController.onReceChatMsgState;

}

FriendChatController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	FriendChatController.s_socketCmdFuncMap or {});


------------------------------------- 命令响应函数配置 ------------------------
FriendChatController.s_cmdConfig = 
{
    [FriendChatController.s_cmds.onBack] = FriendChatController.onBack;
    [FriendChatController.s_cmds.send_msg] = FriendChatController.onSendMsg;
    [FriendChatController.s_cmds.fight] = FriendChatController.onFight;
}