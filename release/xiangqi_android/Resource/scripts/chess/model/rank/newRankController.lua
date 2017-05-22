--region NewFile_2.lua
--Author : FordFan
--Date   : 2015/11/4
--此文件由[BabeLua]插件自动生成



--endregion
require("config/path_config");
require(BASE_PATH.."chessController");
require(DATA_PATH.."friendsData");

NewRankController = class(ChessController);

NewRankController.s_cmds = 
{	
    back_action             = 1;
    change_friends_master   = 2; -- 好友大师榜
    change_world_master     = 3; -- 世界大师榜
--    change_friends_charm    = 4; -- 好友魅力榜
    change_world_charm      = 5; -- 世界魅力榜
--    change_friends_money    = 6; -- 好友财富榜
    change_world_sociaty    = 7; -- 世界棋社榜


----    change_friends = 2;--好友
--    change_charm = 3;--魅力
--    change_master = 4;--大师榜
};

NewRankController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
    self.openView = true; -- 第一次进入界面发送 排行榜请求
    self.m_ranktype = self.m_state.rankType;
end


NewRankController.resume = function(self)
	ChessController.resume(self);
--	Log.i("NewRankController.resume");
    if self.openView then
        if self.m_ranktype == 1 then
            self:onChangeWorldMaster(); --如果是1则发世界大师榜
        elseif self.m_ranktype == 2 then
            self:onChangeWorldCharm(); --如果是2则发世界魅力榜
        elseif self.m_ranktype == 3 then
            self:onChangeWorldSociaty(); --如果是3则发棋社榜
        elseif self.m_ranktype == 4 then
            self:onChangeFriendsMaster(); --如果是4则发棋社榜
        end
        self.openView = false;
    end
end


NewRankController.pause = function(self)
	ChessController.pause(self);
--	Log.i("NewRankController.pause");
end

NewRankController.dtor = function(self)

end

NewRankController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end

NewRankController.onChangeWorldCharm = function(self) --世界魅力榜发送PHP请求
    self:sendHttpMsg(HttpModule.s_cmds.charmList);
end

NewRankController.onChangeFriendsMaster = function(self) --好友积分榜发送PHP请求
--    local info = {};
--    info.uid = UserInfo.getInstance():getUid();
--    self:sendSocketMsg(FRIEND_CMD_SCORE_RANK,info);
--    info.target_uid = info.uid;
--    self:sendSocketMsg(FRIEND_CMD_CHECK_PLAYER_RANK,info);
    self:sendHttpMsg(HttpModule.s_cmds.friendsScoreList);
end

NewRankController.onChangeWorldMaster = function(self) --世界大师榜发送PHP请求
	local post_data = {};
	post_data.mid = UserInfo.getInstance():getUid();
    self:sendHttpMsg(HttpModule.s_cmds.getScoreRank,post_data);
end

--[Comment]
--好友魅力榜
--function NewRankController.onChangeFriendsCharm(self)
--    self:sendHttpMsg(HttpModule.s_cmds.friendsCharmList);
--end

--[Comment]
--世界棋社榜
function NewRankController.onChangeWorldSociaty(self)
    self:sendHttpMsg(HttpModule.s_cmds.sociatyRank);
end

--[Comment]
--好友财富榜
--function NewRankController.onChangeFriendMoney(self)
--    self:sendHttpMsg(HttpModule.s_cmds.friendsMoneyList);
--end

NewRankController.onGetSearchCharmResponse = function(self,isSuccess,message) --世界魅力榜PHP回调
    if not isSuccess then
        self:updataNodataView()
        return;
    end

    local data = message.data;

	if not data then
        self:updataNodataView()
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
        user.is_me = value.is_me:get_value();
        local rank_str = value.rank:get_value();
        local sub = string.sub(rank_str,1,string.len(rank_str) + 1);
        user.rank = tonumber(sub) or 0;
        user.rank = tonumber(value.rank:get_value()) or 0;
        user.is_vip = tonumber(value.is_vip:get_value()) or 0;
        user.my_set = self:getMySetData(value.my_set:get_value())
		table.insert(ranks,user);
        if user.is_me == 1 then
            myData = user;
        end
	end
    local myData = {};
    myData = ranks[#data];

    if #ranks >= 0 then
        table.remove(ranks);
        self:updateView(NewRankScene.s_cmds.change_world_charm,ranks);
        self:updateView(NewRankScene.s_cmds.my_charm_rank,myData,2);
    end
end

function NewRankController.getMySetData(self,my_set)
    local info = {};
    if not my_set or my_set == "" then 
        info.picture_frame = "sys";
        info.piece = "sys";
        info.board = "sys";
    else
        local tab = json.decode_node(my_set);
        info = json.analyzeJsonNode(tab);
    end
    return info 
end

--NewRankController.onRecvServerMsgFriendsRankSuccess = function(self,info) --好友大师榜Php回调
--    if not info then 
--        return;
--    end
--    local data = info.item;

--    local num = 0;

--    local ranks  = {}
--	for _,value in pairs(data) do 
--        local user = {};
--        num = num + 1;
--        if num <= 20 then
--            user = value;
--            table.insert(ranks,user);
--        else
--            break;
--        end
--	end

--    self:updateView(NewRankScene.s_cmds.change_friends_master,ranks);
--    self:updateView(NewRankScene.s_cmds.my_master_rank,myData,0);
--end

NewRankController.getScoreRankCallResponse = function(self,isSuccess,message) --世界大师榜PHP回调
    if not isSuccess then
        self:updataNodataView()
        return ;
    end
    local data = message.data;

	if not data then
        self:updataNodataView()
		print_string("not data");
		return
	end

	local ranks  = {}
	for _,value in pairs(data) do 
		local user = {};
		user.rank     = tonumber(value.rank:get_value()) or 0;
		user.mnick     = ToolKit.subString(value.mnick:get_value(),16);
		user.bccoins  = tonumber(value.bccoins:get_value()) or 0;
		user.score    = tonumber(value.score:get_value()) or 0;
		user.wintimes = tonumber(value.wintimes:get_value()) or 0;
		user.losetimes= tonumber(value.losetimes:get_value()) or 0;
		user.drawtimes= tonumber(value.drawtimes:get_value()) or 0;
		user.icon_url     = value.icon:get_value();
		user.isweibo  = tonumber(value.isweibo:get_value()) or 0;
		user.usertype = tonumber(value.usertype:get_value()) or 0;
        user.iconType = tonumber(value.iconType:get_value()) or 0;
        user.mactivetime = tonumber(value.mactivetime:get_value()) or 0;
        user.is_vip = tonumber(value.is_vip:get_value()) or 0;
		--暂时用不上
		user.money    = tonumber(value.money:get_value()) or 0;
		user.level    = tonumber(value.level:get_value()) or 0;
		user.mid      = tonumber(value.mid:get_value()) or 0;
		user.sitemid  = value.sitemid:get_value();
        user.my_set = self:getMySetData(value.my_set:get_value())
		table.insert(ranks,user);
	end
    if #ranks >= 1 then
        local myData = ranks[table.maxn(ranks)];
        table.remove(ranks);
        self:updateView(NewRankScene.s_cmds.change_world_master,ranks);
        self:updateView(NewRankScene.s_cmds.my_master_rank,myData,1);
    end
end

NewRankController.getSociatyRankCallResponse = function(self,isSuccess,message) --世界棋社榜PHP回调
    if not isSuccess then
        self:updataNodataView()
        return;
    end

    local data = message.data;

	if not data then
        self:updataNodataView()
		print_string("not data");
		return
	end

    local ranks = json.analyzeJsonNode(data.list)
    local mySociatyRank = {}
    local sociatyList = {}
    sociatyList = ranks.list or {}
    mySociatyRank = ranks.me or {}

    self:updateView(NewRankScene.s_cmds.change_world_sociaty,sociatyList);
    self:updateView(NewRankScene.s_cmds.my_sociaty_rank,mySociatyRank,3);
end

NewRankController.getrecommendMailListCallResponse = function(self,isSuccess,message)

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
        self:updateView(NewRankScene.s_cmds.newfriendsNum,ranks);
    end


end

NewRankController.onRecvFriendCmdGetOnlyFriendsRank = function(self,info) -- 我的好友排行
    if not info then return end;
    self:updateView(NewRankScene.s_cmds.my_friend_rank,info,1);
end

--[Comment]
--好友魅力榜回调
--function NewRankController.getFriendCharmRankCallResponse(self,isSuccess,message)
--    if not isSuccess then
--        return;
--    end

--    local data = message.data;

--	if not data then
--		print_string("not data");
--		return
--	end

--    local ranks = json.analyzeJsonNode(data.list)
--    local myRanks = json.analyzeJsonNode(data.my)

--    local myFriendCharmRank = {}
--    local friendCharmRank = {}
--    friendCharmRank = ranks or {}
--    myFriendCharmRank = myRanks or {}

--    self:updateView(NewRankScene.s_cmds.change_friends_charm,friendCharmRank);
--    self:updateView(NewRankScene.s_cmds.my_friend_rank,myFriendCharmRank,2);
--end

--[Comment]
--好友积分榜回调
function NewRankController.getFriendScoreRankCallResponse(self,isSuccess,message)
    if not isSuccess then
        self:updataNodataView()
        return;
    end

    local data = message.data;

	if not data then
        self:updataNodataView()
		print_string("not data");
		return
	end

    local ranks = json.analyzeJsonNode(data.list)
    local myRanks = json.analyzeJsonNode(data.my)

    local myFriendScoreRank = {}
    local friendScoreRank = {}
    friendScoreRank = ranks or {}
    myFriendScoreRank = myRanks or {}

    self:updateView(NewRankScene.s_cmds.change_friends_master,friendScoreRank);
    self:updateView(NewRankScene.s_cmds.my_friend_rank,myFriendScoreRank,1);
end

--[Comment]
--好友财富榜回调
--function NewRankController.getFriendMoneyRankCallResponse(self,isSuccess,message)
--    if not isSuccess then
--        return;
--    end

--    local data = message.data;

--	if not data then
--		print_string("not data");
--		return
--	end

--    local ranks = json.analyzeJsonNode(data.list)
--    local myRanks = json.analyzeJsonNode(data.my)

--    local myFriendMoneyRank = {}
--    local friendMoneyRank = {}
--    friendMoneyRank = ranks or {}
--    myFriendMoneyRank = myRanks or {}

--    self:updateView(NewRankScene.s_cmds.change_friends_money,friendMoneyRank);
--    self:updateView(NewRankScene.s_cmds.my_money_rank,myFriendMoneyRank,4);
--end
----------------------------------------------------------------------
NewRankController.onUpdateStatus = function(self,tab)--状态
    self:updateView(NewRankScene.s_cmds.changeFriendstatus,tab);
end

NewRankController.onUpdateUserData = function(self,tab)--数据
    self:updateView(NewRankScene.s_cmds.changeFriendsData,tab);
end

NewRankController.onGetDownloadImage = function(self,flag,data) -- 用户头像
    Log.i("FriendsController.onGetDownloadImage");
    if not flag then 
        --下载失败
    end
    local info = json.analyzeJsonNode(data);
    for i,v in pairs(info) do
        Log.i(i ..":".. v );
    end
    self:updateView(NewRankScene.s_cmds.change_userIcon,info);
end

function NewRankController.updataNodataView(self)
    self:updateView(NewRankScene.s_cmds.dismissLoading);
end

--NewRankController.onGetUserStatus = function(self,uids)--状态
--    return FriendsData.getInstance():getUserStatus(uids);
--end

-------------------------------- config ---------------------------------------------
NewRankController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.charmList]                 = NewRankController.onGetSearchCharmResponse;
    [HttpModule.s_cmds.getScoreRank]              = NewRankController.getScoreRankCallResponse;
    [HttpModule.s_cmds.recommendMailListCll]      = NewRankController.getrecommendMailListCallResponse;
    [HttpModule.s_cmds.sociatyRank]               = NewRankController.getSociatyRankCallResponse;
--    [HttpModule.s_cmds.friendsCharmList]          = NewRankController.getFriendCharmRankCallResponse;
    [HttpModule.s_cmds.friendsScoreList]          = NewRankController.getFriendScoreRankCallResponse;
--    [HttpModule.s_cmds.friendsMoneyList]          = NewRankController.getFriendMoneyRankCallResponse;
};

NewRankController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	NewRankController.s_httpRequestsCallBackFuncMap or {});


--本地事件 包括lua dispatch call事件
NewRankController.s_nativeEventFuncMap = {
   [kFriend_UpdateStatus]               = NewRankController.onUpdateStatus;
--   [kFriend_UpdateUserData]             = NewRankController.onUpdateUserData;
   [kCacheImageManager]                 = NewRankController.onGetDownloadImage;
};

NewRankController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	NewRankController.s_nativeEventFuncMap or {});


NewRankController.s_socketCmdFuncMap = {
--   [FRIEND_CMD_SCORE_RANK]           = NewRankController.onRecvServerMsgFriendsRankSuccess;
--   [FRIEND_CMD_CHECK_PLAYER_RANK]    = NewRankController.onRecvFriendCmdGetOnlyFriendsRank;
}

NewRankController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	NewRankController.s_socketCmdFuncMap or {});


------------------------------------- 命令响应函数配置 ------------------------
NewRankController.s_cmdConfig = {
    [NewRankController.s_cmds.back_action]		         = NewRankController.onBack; 
    [NewRankController.s_cmds.change_world_charm]        = NewRankController.onChangeWorldCharm; 
    [NewRankController.s_cmds.change_friends_master]     = NewRankController.onChangeFriendsMaster; 
    [NewRankController.s_cmds.change_world_master]	     = NewRankController.onChangeWorldMaster;
--    [NewRankController.s_cmds.change_friends_charm]	     = NewRankController.onChangeFriendsCharm;
    [NewRankController.s_cmds.change_world_sociaty]	     = NewRankController.onChangeWorldSociaty;
--    [NewRankController.s_cmds.change_friends_money]	     = NewRankController.onChangeFriendMoney;

}