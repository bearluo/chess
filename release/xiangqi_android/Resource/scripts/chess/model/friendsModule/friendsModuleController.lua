--FriendsModuleController.lua
--Date 2016.8.23
--好友界面
--endregion

FriendsModuleController = class();--{}

FriendsModuleController.s_manager = nil;
FriendsModuleController.s_httpRequestsCallBackFuncMap = nil

function FriendsModuleController.getInstance()
    if not FriendsModuleController.s_manager then 
		FriendsModuleController.s_manager = new(FriendsModuleController);
	end
	return FriendsModuleController.s_manager;
end

function FriendsModuleController.releaseInstance()
    delete(FriendsModuleController.s_manager);
	FriendsModuleController.s_manager = nil;
    FriendsModuleController.s_httpRequestsCallBackFuncMap = nil;
end

function FriendsModuleController.ctor(self)
    self:initHttpManager()
    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
    EventDispatcher.getInstance():register(Event.Call,self,self.onNativeCallDone);
end

function FriendsModuleController.dtor(self)
    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpRequestsCallBack);
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeCallDone);
end

--[Comment]
--新增好友推荐
--data:需要的参数
function FriendsModuleController.onChangecNewfriendsNum(self)
    HttpModule.getInstance():execute(HttpModule.s_cmds.recommendMailListCll)
end

--[Comment]
--新增好友推荐回调
function FriendsModuleController.getrecommendMailListCallResponse(self,isSuccess,message)
    if not isSuccess then
        return ;
    end

    local data = message.data;
	if not data then
		return
	end

    local ranks  = {};
    ranks.total = data.total_no_check:get_value();
    ranks.list = {};
	for _,value in pairs(data.list) do 
		local user = {};
        if type(value) == "table" then
		    user.drawtimes     = tonumber(value.drawtimes:get_value()) or 0;
            user.mid      = tonumber(value.mid:get_value()) or 0;
            user.score    = tonumber(value.score:get_value()) or 0;
            user.losetimes= tonumber(value.losetimes:get_value()) or 0;
            user.iconType     = value.iconType:get_value();
            user.icon_url = value.icon_url:get_value() or "";
            user.mnick     = ToolKit.subString(value.mnick:get_value(),16);
            user.mactivetime  = tonumber(value.mactivetime:get_value()) or 0;
            user.wintimes = tonumber(value.wintimes:get_value()) or 0;
		    user.money    = value.money:get_value();
		    user.rank    = value.rank:get_value();
            user.concat_name = value.concat_name:get_value() or "";
		    table.insert(ranks.list,user);
        end
	end

    if #ranks >= 0 then
        EventDispatcher.getInstance():dispatch(FriendsModuleView.s_event.UpdateView,FriendsModuleView.s_cmds.newfriendsNum,ranks);
    end
end


function FriendsModuleController.onUpdateStatus(self,tab)--状态
    EventDispatcher.getInstance():dispatch(FriendsModuleView.s_event.UpdateView,FriendsModuleView.s_cmds.changeFriendstatus,tab);
end

function FriendsModuleController.onUpdateUserData(self,tab)--数据
    EventDispatcher.getInstance():dispatch(FriendsModuleView.s_event.UpdateView,FriendsModuleView.s_cmds.changeFriendsData,tab);
end

function FriendsModuleController.onUpdateFriendsList(self,tab,ret)--好友列表
    if ret then
        tab = FriendsData.getInstance():getFrendsListData();
    end
    EventDispatcher.getInstance():dispatch(FriendsModuleView.s_event.UpdateView,FriendsModuleView.s_cmds.changeFriendsList,tab);
end

function FriendsModuleController.onUpdateFollowList(self,tab)--关注列表
--    local data = FriendsData.getInstance():getFollowListData();
    EventDispatcher.getInstance():dispatch(FriendsModuleView.s_event.UpdateView,FriendsModuleView.s_cmds.changeFollowList,tab);
end

function FriendsModuleController.onUpdateFansList(self,tab)--粉丝列表
--    local data = FriendsData.getInstance():getFansListData();
    EventDispatcher.getInstance():dispatch(FriendsModuleView.s_event.UpdateView,FriendsModuleView.s_cmds.changeFansList,tab);
end

function FriendsModuleController.getFriendsNum(self)--好友数量
    local info = {};
    info.uid = UserInfo.getInstance():getUid();
    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_GET_FRIENDS_NUM,info,nil,1);
end

function FriendsModuleController.getFansNum(self)--粉丝数量
    local info = {};
    info.uid = UserInfo.getInstance():getUid();
    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_GET_FANS_NUM,info,nil,1);
end

function FriendsModuleController.getFollowNum(self)--关注数量
    local info = {};
    info.uid = UserInfo.getInstance():getUid();
    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_GET_FOLLOW_NUM,info,nil,1);
end

function FriendsModuleController.onUpdateFriendsNum(self,data)--更新好友数量
    EventDispatcher.getInstance():dispatch(FriendsModuleView.s_event.UpdateView,FriendsModuleView.s_cmds.updataFriendsNum,data);
end

function FriendsModuleController.onUpdateFollowNum(self,data)--更新关注数量
    EventDispatcher.getInstance():dispatch(FriendsModuleView.s_event.UpdateView,FriendsModuleView.s_cmds.updataFollowNum,data);
end

function FriendsModuleController.onUpdateFansNum(self,data)--更新粉丝数量
    EventDispatcher.getInstance():dispatch(FriendsModuleView.s_event.UpdateView,FriendsModuleView.s_cmds.updataFansNum,data);
end

function FriendsModuleController.onUpdateComcat(self,data)--更新好友对局信息
    EventDispatcher.getInstance():dispatch(FriendsModuleView.s_event.UpdateView,FriendsModuleView.s_cmds.updataFriendsGames,data);
end
------------------- [END] ----------------------------------

function FriendsModuleController.onHttpRequestsCallBack(self,command,...)
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self,...);
	end 
end

function FriendsModuleController.onNativeCallDone(self ,param , ...)
	if self.s_nativeEventFuncMap[param] then
		self.s_nativeEventFuncMap[param](self,...);
	end
end

--Test
--暂时没想好
function FriendsModuleController.initHttpManager(self)

    FriendsModuleController.s_httpRequestsCallBackFuncMap  = {
        [HttpModule.s_cmds.recommendMailListCll]    = FriendsModuleController.getrecommendMailListCallResponse;
    };

    FriendsModuleController.s_nativeEventFuncMap = {
        [kFriend_UpdateStatus]               = FriendsModuleController.onUpdateStatus;
        [kFriend_UpdateUserData]             = FriendsModuleController.onUpdateUserData;
        [kFriend_UpdateFriendsList]          = FriendsModuleController.onUpdateFriendsList;
        [kFriend_UpdateFollowList]           = FriendsModuleController.onUpdateFollowList;
        [kFriend_UpdateFansList]             = FriendsModuleController.onUpdateFansList;
        [kFriend_FollowCallBack]             = FriendsModuleController.onRecvServerMsgFollowSuccess;
        [kFriend_UpdateUserCombat]           = FriendsModuleController.onUpdateComcat;
--       [kCacheImageManager]                 = FriendsModuleController.onGetDownloadImage;
--       [kFriend_FollowCallBack]             = FriendsModuleController.onRecvServerMsgFollowSuccess;
    }
end