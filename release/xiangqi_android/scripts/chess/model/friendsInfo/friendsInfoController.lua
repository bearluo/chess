require("config/path_config");

require(BASE_PATH.."chessController");
require(DATA_PATH.."friendsData");

FriendsInfoController = class(ChessController);

FriendsInfoController.friendsID = 0;

FriendsInfoController.s_cmds = 
{	
    back_action = 1;
    attentionTo = 2;
    changePaiHang = 3;
    changeFriends = 4;
    challenge = 5;
};

FriendsInfoController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
--    Log.d("FriendsInfoController.friendsID = "..FriendsInfoController.friendsID.." =========");
end

FriendsInfoController.resume = function(self)
	ChessController.resume(self);
end

FriendsInfoController.pause = function(self)
	ChessController.pause(self);
end

FriendsInfoController.dtor = function(self)
    if self.m_forbid_dialog then
        delete(self.m_forbid_dialog);
        self.m_forbid_dialog = nil;
    end; 
end

-------------------------------- function --------------------------------------------

FriendsInfoController.onRecvServerMsgFollowSuccess = function(self,info)
    if not info then return end   --0,陌生人,=1粉丝，=2关注，=3好友

    if info.ret == 2 then
        ChessToastManager.getInstance():show("超出上限！",500);
    elseif info.ret == 0 then
        self:updateView(FriendsInfoScene.s_cmds.changeFriendTile,info);
    end
    
end

FriendsInfoController.isForbidSendMsg = function(self,packetInfo)
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


FriendsInfoController.onReceChatMsgState = function(self,packetInfo)
    self:isForbidSendMsg(packetInfo);
    self:updateView(FriendsInfoScene.s_cmds.recv_chat_msg_state,packetInfo);
end

FriendsInfoController.onReceChatMsgState2 = function(self,packetInfo)
    self:isForbidSendMsg(packetInfo);
    self:updateView(FriendsInfoScene.s_cmds.recv_chat_msg_state,packetInfo);
end

---不需要--
--FriendsInfoController.onRecvServerMsgFriendsRankSuccess = function(self,info)
--    if not info then return end   
--    self:updateView(FriendsInfoScene.s_cmds.changeFriendsRank,info);

--end

FriendsInfoController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end;

--关注
FriendsInfoController.attentionToCall = function(self,data)
    if not data then return end
    local info = {};
    info.uid = UserInfo.getInstance():getUid();
    info.target_uid = data.target_uid;
    info.op = data.op;

    self:sendSocketMsg(FRIEND_CMD_ADD_FLLOW,info);

end;


--查询单个用户的好友榜排名 不需要
--FriendsInfoController.attentionFriendsCall = function(self,data)

--    if not data then return end
--    local info = {};
--    info.target_uid = data.target_uid;
--    info.uid = data.id;

--    if info.target_uid == nil or info.uid == nil then --ZHENGYI
--        return;
--    end

--    self:sendSocketMsg(FRIEND_CMD_CHECK_PLAYER_RANK,info);
--end;

FriendsInfoController.onChallenge = function(self,data)
    self:onCreateFriendRoom(data);
end

FriendsInfoController.onUpdateFriendsList = function(self,tab)
    local data = FriendsData.getInstance():getFrendsListData();
    self:updateView(FriendsScene.s_cmds.changeFriendsList,data);
end

FriendsInfoController.onUpdateStatus = function(self,tab) --状态更新
    self:updateView(FriendsInfoScene.s_cmds.changeFriendstatus,tab);
end

FriendsInfoController.onUpdateUserData = function(self,tab)--数据更新
    self:updateView(FriendsInfoScene.s_cmds.changeFriendsData,tab);
end

FriendsInfoController.onGetDownloadImage = function(self,flag,data) -- 用户头像
    Log.i("FriendsController.onGetDownloadImage");
    if not flag then 
        --下载失败
    end
    local info = json.analyzeJsonNode(data);
    for i,v in pairs(info) do
        Log.i(i ..":".. v );
    end
    self:updateView(FriendsInfoScene.s_cmds.change_userIcon,info);
end
------------------------------------------------------------------------------------
FriendsInfoController.onGetFriendsList = function(self)
    return FriendsData.getInstance():getFrendsListData();
end

FriendsInfoController.onGetUserData = function(self,uids)
    return FriendsData.getInstance():getUserData(uids);
end

FriendsInfoController.onGetUserStatus = function(self,uids)
    return FriendsData.getInstance():getUserStatus(uids);
end

-------------------------------- config ---------------------------------------------

FriendsInfoController.s_httpRequestsCallBackFuncMap  = {
--    [HttpModule.s_cmds.getFriendUserInfo] = FriendsInfoController.onGetPaiHangBangResponse;
};

FriendsInfoController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	FriendsInfoController.s_httpRequestsCallBackFuncMap or {});


FriendsInfoController.s_nativeEventFuncMap = {
   [kFriend_UpdateStatus]               = FriendsInfoController.onUpdateStatus;
   [kFriend_UpdateUserData]             = FriendsInfoController.onUpdateUserData;
   [kCacheImageManager]                 = FriendsInfoController.onGetDownloadImage;
   [kFriend_FollowCallBack]             = FriendsInfoController.onRecvServerMsgFollowSuccess;
};

FriendsInfoController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	FriendsInfoController.s_nativeEventFuncMap or {});


FriendsInfoController.s_socketCmdFuncMap = {
--    [FRIEND_CMD_ADD_FLLOW]     = FriendsInfoController.onRecvServerMsgFollowSuccess;
    [FRIEND_CMD_CHAT_MSG]      = FriendsInfoController.onReceChatMsgState;
    [FRIEND_CMD_CHAT_MSG2]      = FriendsInfoController.onReceChatMsgState2;
--    [FRIEND_CMD_CHECK_PLAYER_RANK] = FriendsInfoController.onRecvServerMsgFriendsRankSuccess;
}

FriendsInfoController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	FriendsInfoController.s_socketCmdFuncMap or {});

------------------------------------- 命令响应函数配置 ------------------------
FriendsInfoController.s_cmdConfig = 
{
	[FriendsInfoController.s_cmds.back_action]		= FriendsInfoController.onBack;
    [FriendsInfoController.s_cmds.attentionTo] = FriendsInfoController.attentionToCall;
    --[FriendsInfoController.s_cmds.changePaiHang] = FriendsInfoController.attentionPaiHangCall;
    [FriendsInfoController.s_cmds.changeFriends] = FriendsInfoController.attentionFriendsCall;
    [FriendsInfoController.s_cmds.challenge] = FriendsInfoController.onChallenge;
    
}