require("config/path_config");

require(BASE_PATH.."chessController");
require(DATA_PATH.."friendsData");

FriendsInfoController = class(ChessController);

FriendsInfoController.friendsID = 0;

FriendsInfoController.s_cmds = 
{	
    back_action           = 1;        
    attentionTo           = 2;        
    changePaiHang         = 3;
    changeFriends         = 4;   --目前不用了
    challenge             = 5;
    get_usersuggestchess  = 6;
    save_mychess          = 7;
    modifyUserInfo        = 8;
    getRecordData = 9;
    getHonorData = 10;

};
FriendsInfoController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
    FriendsInfoController.friendsID = self.m_state.m_uid
    self:registerHttpDataEvent()
--    Log.d("FriendsInfoController.friendsID = "..FriendsInfoController.friendsID.." =========");
end

FriendsInfoController.resume = function(self)  
--    print_string("FriendsInfoController.resume");
	ChessController.resume(self);
    --拉取好友数量相关数据
    --FriendsData.getInstance():getNormalFriendsData(FriendsInfoController.friendsID);
    --FriendsData.getInstance():getRecordFriendsData(FriendsInfoController.friendsID);
    self:updateView(FriendsInfoScene.s_cmds.setShowUserViewMid,FriendsInfoController.friendsID)
    FriendsData.getInstance():getUserStatus(FriendsInfoController.friendsID);
    --拉去自己的好友数量
    self:getFollowNum()
    self:getFansNum()
    self:getWinCombo()
end

FriendsInfoController.pause = function(self)
	ChessController.pause(self);
    EventDispatcher:getInstance():unregister(FriendsData.event.RECORD, self, FriendsInfoController.onRecordDataCallBack )
    EventDispatcher:getInstance():unregister(FriendsData.event.HONOR, self, FriendsInfoController.onHonorDataCallBack )  
end

FriendsInfoController.dtor = function(self)
    if self.m_forbid_dialog then
        delete(self.m_forbid_dialog);
        self.m_forbid_dialog = nil;
    end; 
    delete(self.m_sociaty_dialog)
end

function FriendsInfoController.registerHttpDataEvent(self)
    EventDispatcher:getInstance():register(FriendsData.event.RECORD, self, FriendsInfoController.onRecordDataCallBack )
    EventDispatcher:getInstance():register(FriendsData.event.HONOR, self, FriendsInfoController.onHonorDataCallBack )  
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
--    local data = FriendsData.getInstance():getFrendsListData();
--    self:updateView(FriendsScene.s_cmds.changeFriendsList,data);
end

FriendsInfoController.onUpdateStatus = function(self,tab) --状态更新
    self:updateView(FriendsInfoScene.s_cmds.changeFriendstatus,tab);
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


--拉取推荐棋局
function FriendsInfoController.onGetSuggestChess(self,startIndex,num,ret,id)
    self.isClick = ret;
    if not id then return end
    local post_data = {};
    post_data.target_mid = tonumber(id); 
    post_data.offset = startIndex;
    post_data.limit = num;
    self:sendHttpMsg(HttpModule.s_cmds.getManualByMid,post_data);
end
--http获取个人信息的回调接口
function FriendsInfoController.onUpdateUserData(self, datas)
    for _,data in ipairs(datas) do
        if data.mid == FriendsInfoController.friendsID then
            self:updateView(FriendsInfoScene.s_cmds.changeFriendsData,data)
        end
    end
end
--http获取战绩信息的回调接口
function FriendsInfoController.onRecordDataCallBack(self, datas)
    for _,data in ipairs(datas) do
        if data.mid == FriendsInfoController.friendsID then
            self:updateView(FriendsInfoScene.s_cmds.updateRecordData,data)
        end
    end
end

--http获取荣誉信息的回调接口
function FriendsInfoController.onHonorDataCallBack(self, datas)
    for _,data in ipairs(datas) do
        if data.mid == FriendsInfoController.friendsID then
            self:updateView(FriendsInfoScene.s_cmds.updateHonorData,data)
        end
    end
end

--收藏棋谱
function FriendsInfoController.onSaveMychess(self,isSelf, chessData)
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
    self:sendHttpMsg(HttpModule.s_cmds.saveMychess,post_data);  --如果http被处理，会全局播放HttpModule.s_cmds.saveMychess事件广播
end

function FriendsInfoController.getRecordData (self, id)
    local data = FriendsData:getInstance():getRecordFriendsData(id)   
    if data then 
        if data.mid then 
            self:updateView(FriendsInfoScene.s_cmds.updateRecordData,data, nData);
        end
    end
end

function FriendsInfoController.getHonorData (self, id)
    local data = FriendsData:getInstance():getHonorFriendsData(id)
    if data then
        if data.mid then  
            self:updateView(FriendsInfoScene.s_cmds.updateHonorData,data);
        end
    end 
end

function FriendsInfoController.onModifyUserInfo(self,str)
    local info = {}
    info.signature = str
    HttpModule.getInstance():execute(HttpModule.s_cmds.uploadMySet,info);
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

--[Comment]
--推荐棋局回调
function FriendsInfoController.onGetSuggestCallBack(self, flag, message)
    if not flag then
        self:updateView(FriendsInfoScene.s_cmds.get_suggestchess,nil); 
        if type(message) == "number" then
            return; 
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
            return;
        end;   
            
    end;
    local data = json.analyzeJsonNode(message.data);
    data.isClick = self.isClick;
    self:updateView(FriendsInfoScene.s_cmds.get_suggestchess,data);
end

--[Comment]
--收藏棋谱回调
function FriendsInfoController.onSaveChessCallBack(self, flag, message)
    if not flag then
        if type(message) == "number" then
            return; 
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
            return;
        end;        
    end;
    local data = json.analyzeJsonNode(message.data);
    self:updateView(FriendsInfoScene.s_cmds.save_mychess,data);
end

function FriendsInfoController.onGetSociatyInfoCall(self,data)
    if not data then
--        ChessToastManager.getInstance():showSingle("")
        return
    end
    if not self.m_sociaty_dialog then
        self.m_sociaty_dialog = new(CreateAndCheckSociatyDialog);
    end
    self.m_sociaty_dialog:setSociatyData(data)
    self.m_sociaty_dialog:setDialogStatus(CreateAndCheckSociatyDialog.s_check_mode);
    self.m_sociaty_dialog:show();
end

function FriendsInfoController.onSaveUserInfoCallBack(self,isSuccess,message)
    if not isSuccess then
        ChessToastManager.getInstance():showSingle("修改失败")
        return
    end
    if not message.data or message.data == "" then return end
    if not message.data.aUser or message.data.aUser == "" then return end
    local aUser = message.data.aUser;
    if not aUser.signature or aUser.signature == "" then return end
    local signature = aUser.signature:get_value();
    UserInfo.getInstance():setSignAture(signature)
    self:updateView(FriendsInfoScene.s_cmds.modify_sign,signature);
end

function FriendsInfoController.getWinCombo(self)
    local info = {}
    info.target_id = FriendsInfoController.friendsID
    self:sendSocketMsg(CHECK_WIN_COMBO,info)
end

function FriendsInfoController.onRecvWinCombo(self,data)
    if data then
        local win_combo = data.win_combo
        self:updateView(FriendsInfoScene.s_cmds.updataWinCombo,win_combo)
    end
end

function FriendsInfoController.getFansNum(self)
    --粉丝数量
    local info = {};
    info.uid = UserInfo.getInstance():getUid();
    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_GET_FANS_NUM,info,nil,1);
end

function FriendsInfoController.getFollowNum(self)
    --关注数量
    local info = {};
    info.uid = UserInfo.getInstance():getUid();
    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_GET_FOLLOW_NUM,info,nil,1);
end

function FriendsInfoController.onFriendCmdGetFollowNum(self,info)
    --关注数量回调
    local num = 0
    if info then
        num = info.num or 0
    end
    self:updateView(FriendsInfoScene.s_cmds.follow_num,num);
end

function FriendsInfoController.onFriendCmdGetFansNum(self,info)
    --粉丝数量回调
    local num = 0
    if info then
        num = info.num or 0
    end
    self:updateView(FriendsInfoScene.s_cmds.fans_num,num);
end

-------------------------------- config ---------------------------------------------

--http请求的一些回调函数配置
FriendsInfoController.s_httpRequestsCallBackFuncMap  = {
--    [HttpModule.s_cmds.getFriendUserInfo] = FriendsInfoController.onGetPaiHangBangResponse;
    [HttpModule.s_cmds.getManualByMid]               = FriendsInfoController.onGetSuggestCallBack;
    [HttpModule.s_cmds.saveMychess]                  = FriendsInfoController.onSaveChessCallBack;
    [HttpModule.s_cmds.uploadMySet]                  = FriendsInfoController.onSaveUserInfoCallBack;
};

FriendsInfoController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	FriendsInfoController.s_httpRequestsCallBackFuncMap or {});


FriendsInfoController.s_nativeEventFuncMap = {
   [kFriend_UpdateStatus]               = FriendsInfoController.onUpdateStatus;
   [kFriend_UpdateUserData]             = FriendsInfoController.onUpdateUserData;
   [kCacheImageManager]                 = FriendsInfoController.onGetDownloadImage;
   [kFriend_FollowCallBack]             = FriendsInfoController.onRecvServerMsgFollowSuccess;
   [kSociaty_updataSociatyData]         = FriendsInfoController.onGetSociatyInfoCall;
};

FriendsInfoController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	FriendsInfoController.s_nativeEventFuncMap or {});


FriendsInfoController.s_socketCmdFuncMap = {

    [FRIEND_CMD_CHAT_MSG]      = FriendsInfoController.onReceChatMsgState;
    [FRIEND_CMD_CHAT_MSG2]      = FriendsInfoController.onReceChatMsgState2;
    [CHECK_WIN_COMBO]       =  FriendsInfoController.onRecvWinCombo;

    [FRIEND_CMD_GET_FOLLOW_NUM]         = FriendsInfoController.onFriendCmdGetFollowNum;
    [FRIEND_CMD_GET_FANS_NUM]           = FriendsInfoController.onFriendCmdGetFansNum;


}

FriendsInfoController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	FriendsInfoController.s_socketCmdFuncMap or {});

------------------------------------- 命令响应函数配置 ------------------------
FriendsInfoController.s_cmdConfig = 
{
	[FriendsInfoController.s_cmds.back_action]		= FriendsInfoController.onBack;
    [FriendsInfoController.s_cmds.attentionTo]      = FriendsInfoController.attentionToCall;
    --[FriendsInfoController.s_cmds.changePaiHang]  = FriendsInfoController.attentionPaiHangCall;
    [FriendsInfoController.s_cmds.changeFriends]    = FriendsInfoController.attentionFriendsCall;
    [FriendsInfoController.s_cmds.challenge]        = FriendsInfoController.onChallenge;
    [FriendsInfoController.s_cmds.get_usersuggestchess] = FriendsInfoController.onGetSuggestChess; 
    [FriendsInfoController.s_cmds.save_mychess]     = FriendsInfoController.onSaveMychess; 
    [FriendsInfoController.s_cmds.modifyUserInfo]   = FriendsInfoController.onModifyUserInfo; 
    [FriendsInfoController.s_cmds.getRecordData] = FriendsInfoController.getRecordData ; 
    [FriendsInfoController.s_cmds.getHonorData] = FriendsInfoController.getHonorData ;
}