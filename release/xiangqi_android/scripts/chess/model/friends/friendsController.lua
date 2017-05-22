require("config/path_config");

require(BASE_PATH.."chessController");
require(DATA_PATH.."friendsData");
FriendsController = class(ChessController);

FriendsController.s_cmds = 
{	
    back_action = 1;
    ongetfriendslist = 2;
    ongetfollowlist = 3;
    ongetfanslist = 4;

    ongetuserdata = 5;
    addfriends = 6;

    change_friends = 7;--好友
    change_charm = 8;--魅力
    change_master = 9;--大师榜

    newfriendsNum = 10;

    friendsNum = 11;
    followNum = 12;
    fans_num = 13;

};

FriendsController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end


FriendsController.resume = function(self)
	ChessController.resume(self);
	Log.i("FriendsController.resume");
    self:onChangecNewfriendsNum(); --新增好友推荐
    self:onGetFriendsNum(); -- 好友数目
    self:onGetFollowNum(); -- 关注数目
    self:onGetFansNum(); -- 粉丝数目


    FriendsData.getInstance():refresh();
end

FriendsController.dtor = function(self)

end
-------------------------------- function --------------------------

FriendsController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end;

FriendsController.onGoAddFriends = function(self,datas) --跳转添加关注界面
    StateMachine.getInstance():pushState(States.AddFriends,StateMachine.STYPE_CUSTOM_WAIT,nil,datas);
end

FriendsController.onChangecCharm = function(self) --魅力榜发送PHP请求
    self:sendHttpMsg(HttpModule.s_cmds.charmList);
end

FriendsController.onChangecFriends = function(self) --好友榜发送server请求
    local info = {};
    info.uid = UserInfo.getInstance():getUid();
    self:sendSocketMsg(FRIEND_CMD_SCORE_RANK,info);
    info.target_uid = info.uid;
    self:sendSocketMsg(FRIEND_CMD_CHECK_PLAYER_RANK,info);
end


FriendsController.onChangecMaster = function(self) --大师榜发送PHP请求
	local post_data = {};
	post_data.mid = UserInfo.getInstance():getUid();
    self:sendHttpMsg(HttpModule.s_cmds.getScoreRank,post_data);
end

FriendsController.onChangecNewfriendsNum = function(self) --新增好友推荐
    self:sendHttpMsg(HttpModule.s_cmds.recommendMailListCll);
end


FriendsController.onGetFriendsNum = function(self) --好友数目
    local info = {};
    info.uid = UserInfo.getInstance():getUid();
    self:sendSocketMsg(FRIEND_CMD_GET_FRIENDS_NUM,info);
end

FriendsController.onGetFollowNum = function(self) --关注数目
    local info = {};
    info.uid = UserInfo.getInstance():getUid();
    self:sendSocketMsg(FRIEND_CMD_GET_FOLLOW_NUM,info);
end

FriendsController.onGetFansNum = function(self) --粉丝数目
    local info = {};
    info.uid = UserInfo.getInstance():getUid();
    self:sendSocketMsg(FRIEND_CMD_GET_FANS_NUM,info);
end


FriendsController.onGetSearchCharmResponse = function(self,isSuccess,message) --魅力榜PHP回调
    if not isSuccess then
        return;
    end

    local data = message.data;

	if not data then
		print_string("not data");
		return
	end

    local ranks  = {};
    local myData = {};
	for _,value in pairs(data) do 
		local user = {};
		user.mid     = tonumber(value.mid:get_value()) or 0;
		user.score    = tonumber(value.score:get_value()) or 0;
        user.money = tonumber(value.money:get_value()) or 0;
		user.iconType = tonumber(value.iconType:get_value()) or 0;
        user.icon_url     = value.icon_url:get_value() or "";
        user.mactivetime = tonumber(value.mactivetime:get_value()) or 0;
        user.mnick     = ToolKit.subString(value.mnick:get_value(),16);
        user.fans_num = tonumber(value.fans_num:get_value()) or 0;
--        user.is_me = value.is_me:get_value();
--        local rank_str = value.rank:get_value();
--        local sub = string.sub(rank_str,1,string.len(rank_str) + 1);
--        user.rank = tonumber(sub) or 0;
        user.rank = tonumber(value.rank:get_value()) or 0;
		table.insert(ranks,user);
--        if user.is_me == 1 then
--            myData = user;
--        end
	end
    local myData = {};
    myData = ranks[#data];

    if #ranks >= 0 then
        table.remove(ranks);
        self:updateView(FriendsScene.s_cmds.change_charm,ranks);
        self:updateView(FriendsScene.s_cmds.my_charm_rank,myData,2);
    end


end

FriendsController.onRecvServerMsgFriendsRankSuccess = function(self,info) --好友榜server回调
    if not info then 
        return;
    end
    local data = info.item;

    local num = 0;

    local ranks  = {}
	for _,value in pairs(data) do 
        local user = {};
        num = num + 1;
        if num <= 20 then
            user = value;
            table.insert(ranks,user);
        else
            break;
        end
	end


    self:updateView(FriendsScene.s_cmds.change_friends,ranks);

end

FriendsController.onRecvServerMsgFriendsNum = function(self,info) --好友数目
    if not info then 
        return;
    end
   self:updateView(FriendsScene.s_cmds.friends_num,info);

end

FriendsController.onRecvServerMsgFollowNum = function(self,info) --关注数目
    if not info then 
        return;
    end
    self:updateView(FriendsScene.s_cmds.follow_num,info);

end

FriendsController.onRecvServerMsgFansNum = function(self,info) --粉丝数目
    if not info then 
        return;
    end
    self:updateView(FriendsScene.s_cmds.fans_num,info);

end

FriendsController.onRecvFriendCmdGetOnlyFriendsRank = function(self,info) -- 我的好友排行
    if not info then return end;
    self:updateView(FriendsScene.s_cmds.my_friend_rank,info,1);
end


FriendsController.getScoreRankCallResponse = function(self,isSuccess,message) --大师榜PHP回调
    if not isSuccess then
        return ;
    end
    local data = message.data;

	if not data then
		print_string("not data");
		return
	end

	local ranks  = {}
	for _,value in pairs(data) do 
		local user = {};
		user.rank     = tonumber(value.rank:get_value()) or 0;
		user.name     = ToolKit.subString(value.mnick:get_value(),16);
		user.bccoins  = tonumber(value.bccoins:get_value()) or 0;
		user.score    = tonumber(value.score:get_value()) or 0;
		user.wintimes = tonumber(value.wintimes:get_value()) or 0;
		user.losetimes= tonumber(value.losetimes:get_value()) or 0;
		user.drawtimes= tonumber(value.drawtimes:get_value()) or 0;
		user.icon     = value.icon:get_value();
		user.isweibo  = tonumber(value.isweibo:get_value()) or 0;
		user.usertype = tonumber(value.usertype:get_value()) or 0;
        user.iconType = tonumber(value.iconType:get_value()) or 0;
		--暂时用不上
		user.money    = tonumber(value.money:get_value()) or 0;
		user.level    = tonumber(value.level:get_value()) or 0;
		user.mid      = tonumber(value.mid:get_value()) or 0;
		user.sitemid  = value.sitemid:get_value();

		table.insert(ranks,user);

	end
    if #ranks >= 1 then
        local myData = ranks[table.maxn(ranks)];
        table.remove(ranks);
        self:updateView(FriendsScene.s_cmds.change_master,ranks);
        self:updateView(FriendsScene.s_cmds.my_master_rank,myData,0);
    end
end

FriendsController.getrecommendMailListCallResponse = function(self,isSuccess,message)

    if not isSuccess then
        Log.d("ZY getrecommendMailListCallResponse false");
        return ;
    end

    local data = message.data;

	if not data then
		print_string("not data");
		return
	end

    local ranks  = {};
    ranks.total = data.total_no_check:get_value();
    ranks.list = {};

	for _,value in pairs(data.list) do 
		local user = {};
		user.drawtimes     = tonumber(value.drawtimes:get_value()) or 0;
        user.mid      = tonumber(value.mid:get_value()) or 0;
        user.score    = tonumber(value.score:get_value()) or 0;
        user.losetimes= tonumber(value.losetimes:get_value()) or 0;
        user.iconType     = value.iconType:get_value();
        user.name     = ToolKit.subString(value.mnick:get_value(),16);
        user.mactivetime  = tonumber(value.mactivetime:get_value()) or 0;
        user.wintimes = tonumber(value.wintimes:get_value()) or 0;
		user.money    = value.money:get_value();
		user.rank    = value.rank:get_value();
		table.insert(ranks.list,user);

	end

    if #ranks >= 0 then
        self:updateView(FriendsScene.s_cmds.newfriendsNum,ranks);
    end


end

------------------------------------------------------------------------------------

FriendsController.onUpdateFriendsList = function(self,tab)--好友列表
    local data = FriendsData.getInstance():getFrendsListData();
    self:updateView(FriendsScene.s_cmds.changeFriendsList,data);
end

FriendsController.onUpdateFollowList = function(self,tab)--关注列表
    local data = FriendsData.getInstance():getFollowListData();
    self:updateView(FriendsScene.s_cmds.changeFollowList,data);
end

FriendsController.onUpdateFansList = function(self,tab)--粉丝列表
    local data = FriendsData.getInstance():getFansListData();
    self:updateView(FriendsScene.s_cmds.changeFansList,data);
end


FriendsController.onUpdateStatus = function(self,tab)--状态
    self:updateView(FriendsScene.s_cmds.changeFriendstatus,tab);
end

FriendsController.onUpdateUserData = function(self,tab)--数据
    self:updateView(FriendsScene.s_cmds.changeFriendsData,tab);
end

FriendsController.onGetDownloadImage = function(self,flag,data) -- 用户头像
    Log.i("FriendsController.onGetDownloadImage");
    if not flag then 
        --下载失败
    end
    local info = json.analyzeJsonNode(data);
    for i,v in pairs(info) do
        Log.i(i ..":".. v );
    end
    self:updateView(FriendsScene.s_cmds.change_userIcon,info);
end
--------------------------------------------------------------------------------------

FriendsController.onGetFriendsList = function(self)--好友列表
    return FriendsData.getInstance():getFrendsListData();
end

FriendsController.onGetFollowList = function(self)--关注列表
    return FriendsData.getInstance():getFollowListData();
end

FriendsController.onGetFansList = function(self)--粉丝列表
    return FriendsData.getInstance():getFansListData();
end

FriendsController.onGetUserData = function(self,uids) --数据
    return FriendsData.getInstance():getUserData(uids);
end

FriendsController.onGetUserStatus = function(self,uids)--状态
    return FriendsData.getInstance():getUserStatus(uids);
end


-------------------------------- config ---------------------------------------------
FriendsController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.charmList] = FriendsController.onGetSearchCharmResponse;
    [HttpModule.s_cmds.getScoreRank] = FriendsController.getScoreRankCallResponse;
    [HttpModule.s_cmds.recommendMailListCll] = FriendsController.getrecommendMailListCallResponse;
    
};

FriendsController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	FriendsController.s_httpRequestsCallBackFuncMap or {});


--本地事件 包括lua dispatch call事件
FriendsController.s_nativeEventFuncMap = {
   [kFriend_UpdateStatus]               = FriendsController.onUpdateStatus;
   [kFriend_UpdateUserData]             = FriendsController.onUpdateUserData;


   [kFriend_UpdateFriendsList]          = FriendsController.onUpdateFriendsList;
   [kFriend_UpdateFollowList]           = FriendsController.onUpdateFollowList;
   [kFriend_UpdateFansList]             = FriendsController.onUpdateFansList;
   [kCacheImageManager]                 = FriendsController.onGetDownloadImage;
};

FriendsController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	FriendsController.s_nativeEventFuncMap or {});


FriendsController.s_socketCmdFuncMap = {
   [FRIEND_CMD_SCORE_RANK]           = FriendsController.onRecvServerMsgFriendsRankSuccess;
   [FRIEND_CMD_CHECK_PLAYER_RANK]    = FriendsController.onRecvFriendCmdGetOnlyFriendsRank;

   [FRIEND_CMD_GET_FRIENDS_NUM]      = FriendsController.onRecvServerMsgFriendsNum;--好友数目
   [FRIEND_CMD_GET_FOLLOW_NUM]       = FriendsController.onRecvServerMsgFollowNum;--关注数目
   [FRIEND_CMD_GET_FANS_NUM]         = FriendsController.onRecvServerMsgFansNum;--粉丝数目

}

FriendsController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	FriendsController.s_socketCmdFuncMap or {});


------------------------------------- 命令响应函数配置 ------------------------
FriendsController.s_cmdConfig = 
{
	[FriendsController.s_cmds.back_action]		= FriendsController.onBack;
    [FriendsController.s_cmds.ongetfriendslist]		= FriendsController.onGetFriendsList;
    [FriendsController.s_cmds.ongetfollowlist]		= FriendsController.onGetFollowList;
    [FriendsController.s_cmds.ongetfanslist]		= FriendsController.onGetFansList;

    [FriendsController.s_cmds.ongetuserdata]		= FriendsController.onGetUserData;  
    [FriendsController.s_cmds.addfriends]		= FriendsController.onGoAddFriends; 
    [FriendsController.s_cmds.change_charm]		= FriendsController.onChangecCharm; 
    [FriendsController.s_cmds.change_friends]		= FriendsController.onChangecFriends; 
    [FriendsController.s_cmds.change_master]		= FriendsController.onChangecMaster; 
    [FriendsController.s_cmds.newfriendsNum]		= FriendsController.onChangecNewfriendsNum; 
    

    [FriendsController.s_cmds.friendsNum]		= FriendsController.onGetFriendsNum; 
    [FriendsController.s_cmds.followNum]		= FriendsController.onGetFollowNum; 
    [FriendsController.s_cmds.fans_num]		    = FriendsController.onGetFansNum; 
    
}