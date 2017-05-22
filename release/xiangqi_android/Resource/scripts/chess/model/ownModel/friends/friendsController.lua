--region NewFile_1.lua
--Author : FordFan
--Date   : 2015/11/7
--endregion

require("config/path_config");

require(BASE_PATH.."chessController");
require(DATA_PATH.."friendsData");
require(MODEL_PATH.."friendsModule/friendsModuleController");
FriendsController = class(ChessController);

FriendsController.s_cmds = 
{	
    back_action        = 1;
    ongetfriendslist   = 2;
    ongetfollowlist    = 3;
    ongetfanslist      = 4;
    ongetuserdata      = 5;
--    addfriends         = 6;
    friendsNum         = 7;
    followNum          = 8;
    fans_num           = 9;
    newfriendsNum      = 10;
--    shareUrl           = 6;
    getUnionRecommend  = 11;
    getUnionMember     = 12;
    challenge          = 13;
};

FriendsController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end


FriendsController.resume = function(self)
	ChessController.resume(self);
	Log.i("FriendsController.resume");
--    self:onChangecNewfriendsNum(); --新增好友推荐
--    self:onGetFriendsNum(); -- 好友数目
--    self:onUpdateFriendsList();
--    FriendsModuleController.getInstance():getFriendsNum()
    FriendsModuleController.getInstance():getFansNum()
    FriendsModuleController.getInstance():getFollowNum()
    FriendsModuleController.getInstance():onUpdateFriendsList(nil,true)
--    FriendsData.getInstance():refresh();
--    self:onGetFollowNum(); -- 关注数目
--    self:onGetFansNum(); -- 粉丝数目
--    self:updateMyHead();
    self.m_share_code_url,self.m_share_download_url = UserInfo.getInstance():getGameShareUrl();
end

FriendsController.dtor = function(self)

end

FriendsController.onBack = function(self)
--    if not self:updateView(FriendsScene.s_cmds.closeShareDialog) then
        StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
--    end
    
end

--FriendsController.updateMyHead = function(self)
--    local data = {};
--    data.iconType = UserInfo.getInstance():getIconType();
--    data.iconUrl = UserInfo.getInstance():getIcon();
--    self:updateView(FriendsScene.s_cmds.change_myHead,data);
--end

--FriendsController.onGoAddFriends = function(self,datas) --跳转添加关注界面
--end
----------------------------
--FriendsController.onGetFriendsList = function(self)--好友列表
--    return FriendsData.getInstance():getFrendsListData();
--end

--FriendsController.onGetFollowList = function(self)--关注列表
--    return FriendsData.getInstance():getFollowListData();
--end

--FriendsController.onGetFansList = function(self)--粉丝列表
--    return FriendsData.getInstance():getFansListData();
--end

--FriendsController.onGetUserData = function(self,uids) --数据
--    return FriendsData.getInstance():getUserData(uids);
--end

--FriendsController.onGetUserStatus = function(self,uids)--状态
--    return FriendsData.getInstance():getUserStatus(uids);
--end

--FriendsController.onChangecNewfriendsNum = function(self) --新增好友推荐
--    self:sendHttpMsg(HttpModule.s_cmds.recommendMailListCll);
--end


--FriendsController.onGetFriendsNum = function(self) --好友数目
--    local info = {};
--    info.uid = UserInfo.getInstance():getUid();
--    self:sendSocketMsg(FRIEND_CMD_GET_FRIENDS_NUM,info);
--end

--FriendsController.onGetFollowNum = function(self) --关注数目
--    local info = {};
--    info.uid = UserInfo.getInstance():getUid();
--    self:sendSocketMsg(FRIEND_CMD_GET_FOLLOW_NUM,info);
--end

--FriendsController.onGetFansNum = function(self) --粉丝数目
--    local info = {};
--    info.uid = UserInfo.getInstance():getUid();
--    self:sendSocketMsg(FRIEND_CMD_GET_FANS_NUM,info);
--end

----[[
--    分享
----]]
--function FriendsController:shareUrl()
----	local id = kEndgateData:getBoardTableId();
----    local url = "http://h5.oa.com/chess/?type=1&id="..id;--测试服
----    local url = "http://cnchess.17c.cn/h5/?type=1&id="..id;--正式服
--    local data = {};
--    data.booth_id = id;
--    HttpModule.getInstance():execute(HttpModule.s_cmds.boothShare,data);
--    data.flag = UserInfo.getInstance():getOpenWeixinShare();
--    data.url = url;
--    data.title = kEndgateData:getBoardTableSubTitle();
--end
-------------------------------
--FriendsController.onUpdateFriendsList = function(self,tab)--好友列表
--    local data = FriendsData.getInstance():getFrendsListData();
--    self:updateView(FriendsScene.s_cmds.changeFriendsList,data);
--end

--FriendsController.onUpdateFollowList = function(self,tab)--关注列表
--    local data = FriendsData.getInstance():getFollowListData();
--    self:updateView(FriendsScene.s_cmds.changeFollowList,data);
--end

--FriendsController.onUpdateFansList = function(self,tab)--粉丝列表
--    local data = FriendsData.getInstance():getFansListData();
--    self:updateView(FriendsScene.s_cmds.changeFansList,data);
--end


--FriendsController.onUpdateStatus = function(self,tab)--状态
--    self:updateView(FriendsScene.s_cmds.changeFriendstatus,tab);
--end

--FriendsController.onUpdateUserData = function(self,tab)--数据
--    self:updateView(FriendsScene.s_cmds.changeFriendsData,tab);
--end

--FriendsController.onGetDownloadImage = function(self,flag,data) -- 用户头像
--    Log.i("FriendsController.onGetDownloadImage");
--    if not flag then 
--        --下载失败
--    end
--    local info = json.analyzeJsonNode(data);
--    for i,v in pairs(info) do
--        Log.i(i ..":".. v );
--    end
--    self:updateView(FriendsScene.s_cmds.change_userIcon,info);
--end

--function FriendsController:onGetUnionRecommend()
--    local post_data = {};
--    post_data.method =  "Friends.getSameCityRecommend";
--    post_data.mid = UserInfo.getInstance():getUid();
--    post_data.recommend_num = 3;
--    post_data.access_token = "chess";
--    HttpModule.getInstance():execute(HttpModule.s_cmds.getSameCityRecommend,post_data);
--end

--function FriendsController:onGetUnionMember()
--    local post_data = {};
--    post_data.method =  "Friends.getSameCityMember";
--    post_data.mid = UserInfo.getInstance():getUid();
--    post_data.offset = 0;
--    post_data.limit = 50;
--    HttpModule.getInstance():execute(HttpModule.s_cmds.getSameCityMember,post_data);
--end

-------------------------------------

--server返回----------------------------
FriendsController.onRecvServerMsgFriendsNum = function(self,info) --好友数目
    ChessController.onFriendCmdGetFriendsNum(self,info);
    if not info then 
        return;
    end
    FriendsModuleController.getInstance():onUpdateFriendsNum(info)

--   self:updateView(FriendsScene.s_cmds.friends_num,info);
end

FriendsController.onRecvServerMsgFollowNum = function(self,info) --关注数目
    ChessController.onFriendCmdGetFollowNum(self,info);
    if not info then 
        return;
    end
    FriendsModuleController.getInstance():onUpdateFollowNum(info)

--    self:updateView(FriendsScene.s_cmds.follow_num,info);

end

FriendsController.onRecvServerMsgFansNum = function(self,info) --粉丝数目
    ChessController.onFriendCmdGetFansNum(self,info);
    if not info then 
        return;
    end
    FriendsModuleController.getInstance():onUpdateFansNum(info)

--    self:updateView(FriendsScene.s_cmds.fans_num,info);

end

--FriendsController.onRecvServerMsgFollowSuccess = function(self,info) -- 添加好友
--    if not info then return end   --0,陌生人,=1粉丝，=2关注，=3好友

--    local addfriendsDialog = self.m_view:getAddFriendDialog();
--    local uniondialog = self.m_view:getUnionDialog();

----    if addfriendsDialog and addfriendsDialog:isShowing() then
----        addfriendsDialog:onRecvServerAddFllow(info);
----        return;
----    end
--    if uniondialog and uniondialog:isShowing() then
--        uniondialog:onRecvServerAddFllow(info);
--        return;
--    end
----    if info.ret == 2 then 
----        ChessToastManager.getInstance():show("超出上限！",500);
----    elseif info.ret == 0 then
----        self:updateView(FriendsScene.s_cmds.changeAtt,info);
----    end
--end

--FriendsController.getrecommendMailListCallResponse = function(self,isSuccess,message)

--    if not isSuccess then
--        Log.d("ZY getrecommendMailListCallResponse false");
--        return ;
--    end

--    local data = message.data;

--	if not data then
--		print_string("not data");
--		return
--	end

--    local ranks  = {};
--    ranks.total = data.total_no_check:get_value();
--    ranks.list = {};

--	for _,value in pairs(data.list) do 
--		local user = {};
--        if type(value) == "table" then
--		    user.drawtimes     = tonumber(value.drawtimes:get_value()) or 0;
--            user.mid      = tonumber(value.mid:get_value()) or 0;
--            user.score    = tonumber(value.score:get_value()) or 0;
--            user.losetimes= tonumber(value.losetimes:get_value()) or 0;
--            user.iconType     = value.iconType:get_value();
--            user.icon_url = value.icon_url:get_value() or "";
--            user.mnick     = ToolKit.subString(value.mnick:get_value(),16);
--            user.mactivetime  = tonumber(value.mactivetime:get_value()) or 0;
--            user.wintimes = tonumber(value.wintimes:get_value()) or 0;
--		    user.money    = value.money:get_value();
--		    user.rank    = value.rank:get_value();
--            user.concat_name = value.concat_name:get_value() or "";
--		    table.insert(ranks.list,user);
--        end
--	end

--    if #ranks >= 0 then
--        self:updateView(FriendsScene.s_cmds.newfriendsNum,ranks);
--    end


--end


--function FriendsController:onGetUnionRecommendResponse(isSuccess,message)
--    Log.i("FriendsController.onGetUnionRecommendResponse");
--    if not isSuccess then return end

--    local data = message.data;
--	if not data then
--		print_string("not data");
--		return
--	end

--    local unionData = json.analyzeJsonNode(data);
--    self:updateView(FriendsScene.s_cmds.updata_union_dialog,unionData,msg);
--end

--function FriendsController:onGetUnionMemberResponse(isSuccess,message)
--    Log.i("FriendsController.onGetUnionMemberResponse");
--    if not isSuccess then return end

--    local data = message.data;
--	if not data then
--		print_string("not data");
--		return
--	end

--    local memberData = json.analyzeJsonNode(data);
--    self:updateView(FriendsScene.s_cmds.updata_union_member,memberData,msg);
--end

--function FriendsController.onJoinWatchRoom(self,data)
--    self:onCreateFriendRoom(data);
--end

function FriendsController.onHallMsgCreateRoom(self, info)
    if not info or info.ret ~= 0 then
		if not self.m_chioce_dialog then
			self.m_chioce_dialog = new(ChioceDialog);
		end

		self.m_chioce_dialog:setMode(ChioceDialog.MODE_OK);
		local message="创建自定义房间失败";
		self.m_chioce_dialog:setMessage(message);
	    self.m_chioce_dialog:setPositiveListener(nil,nil);
		self.m_chioce_dialog:show();
        return;
    end;
    ToolKit.schedule_once(self,function() 
        RoomProxy.getInstance():setTid(info.tid);
        UserInfo.getInstance():setCustomRoomID(info.tid);
        UserInfo.getInstance():setCustomRoomType(1);
        RoomProxy.getInstance():gotoPrivateRoom(true)    
    end,170)
--    RoomProxy.getInstance():setTid(info.tid);
--    UserInfo.getInstance():setCustomRoomID(info.tid);
--    RoomProxy.getInstance():setSelfRoom(true);--  设置是自己创建的房间
--    self:onEntryRoom(RoomConfig.ROOM_TYPE_PRIVATE_ROOM);
end

function FriendsController.onRecvServerCheckUserState(self, status)
--    if status then
--        if tonumber(status.hallId) ~= 0 and tonumber(status.tid) == 0 then
        EventDispatcher.getInstance():dispatch(Event.Call,kStranger_isOnline,status);
--        elseif tonumber(status.hallId) == 0 then
--            ChessToastManager.getInstance():showSingle("对方不在线");
--        elseif tonumber(status.tid) ~= 0 then
--            ChessToastManager.getInstance():showSingle("对方正在对局中");
--        end;
--    end;
end

----------------------------------
--本地事件 包括lua dispatch call事件------
FriendsController.s_nativeEventFuncMap = {
--   [kFriend_UpdateStatus]               = FriendsController.onUpdateStatus;
--   [kFriend_UpdateUserData]             = FriendsController.onUpdateUserData;


--   [kFriend_UpdateFriendsList]          = FriendsController.onUpdateFriendsList;
--   [kFriend_UpdateFollowList]           = FriendsController.onUpdateFollowList;
--   [kFriend_UpdateFansList]             = FriendsController.onUpdateFansList;
--   [kCacheImageManager]                 = FriendsController.onGetDownloadImage;
--   [kFriend_FollowCallBack]             = FriendsController.onRecvServerMsgFollowSuccess;
};

FriendsController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	FriendsController.s_nativeEventFuncMap or {});

FriendsController.s_socketCmdFuncMap = {

--    [CLIENT_HALL_CREATE_PRIVATEROOM]                        = FriendsController.onHallMsgCreateRoom;
    
   [FRIEND_CMD_GET_FRIENDS_NUM]         = FriendsController.onRecvServerMsgFriendsNum;--好友数目
   [FRIEND_CMD_GET_FOLLOW_NUM]          = FriendsController.onRecvServerMsgFollowNum;--关注数目
   [FRIEND_CMD_GET_FANS_NUM]            = FriendsController.onRecvServerMsgFansNum;--粉丝数目


    --聊天室私人房邀请
    [FRIEND_CMD_GET_USER_STATUS]        = FriendsController.onRecvServerCheckUserState;   --发起挑战请求
    [CLIENT_HALL_CREATE_PRIVATEROOM]    = FriendsController.onHallMsgCreateRoom; -- 聊天室创建私人房回调
--   [FRIEND_CMD_ADD_FLLOW]            = FriendsController.onRecvServerMsgFollowSuccess;

}

FriendsController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	FriendsController.s_socketCmdFuncMap or {});
---------------------命令相应函数配置------
FriendsController.s_cmdConfig = 
{
    [FriendsController.s_cmds.back_action]          = FriendsController.onBack;

--    [FriendsController.s_cmds.ongetfriendslist]		= FriendsController.onGetFriendsList;
--    [FriendsController.s_cmds.ongetfollowlist]		= FriendsController.onGetFollowList;
--    [FriendsController.s_cmds.ongetfanslist]		= FriendsController.onGetFansList;
--    [FriendsController.s_cmds.ongetuserdata]		= FriendsController.onGetUserData;  
--    [FriendsController.s_cmds.addfriends]		    = FriendsController.onGoAddFriends; --跳转到添加关注页面
--    [FriendsController.s_cmds.friendsNum]		    = FriendsController.onGetFriendsNum; 
--    [FriendsController.s_cmds.followNum]		    = FriendsController.onGetFollowNum; 
--    [FriendsController.s_cmds.fans_num]		        = FriendsController.onGetFansNum; 

--    [FriendsController.s_cmds.newfriendsNum]		= FriendsController.onChangecNewfriendsNum; 
--    [FriendsController.s_cmds.getUnionRecommend]	= FriendsController.onGetUnionRecommend; 
--    [FriendsController.s_cmds.getUnionMember]	    = FriendsController.onGetUnionMember; 
--    [FriendsController.s_cmds.challenge]	        = FriendsController.onJoinWatchRoom; 
    
--    [FriendsController.s_cmds.shareUrl]		        = FriendsController.shareUrl; 
}


FriendsController.s_httpRequestsCallBackFuncMap  = {

--    [HttpModule.s_cmds.recommendMailListCll] = FriendsController.getrecommendMailListCallResponse;
--    [HttpModule.s_cmds.getSameCityRecommend] = FriendsController.onGetUnionRecommendResponse;
--    [HttpModule.s_cmds.getSameCityMember]    = FriendsController.onGetUnionMemberResponse;
};

FriendsController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	FriendsController.s_httpRequestsCallBackFuncMap or {});

