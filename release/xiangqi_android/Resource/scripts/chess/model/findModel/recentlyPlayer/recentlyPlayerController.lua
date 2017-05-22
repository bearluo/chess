--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23

require(BASE_PATH.."chessController")

RecentlyPlayerController = class(ChessController);

RecentlyPlayerController.s_cmds = 
{
    onBack              = 1;
    requestFollow       = 2;
    requestFriendsGetRecentWarUser  =3;
    quickPlay                       =4;
};


RecentlyPlayerController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end

RecentlyPlayerController.dtor = function(self)
end

RecentlyPlayerController.resume = function(self)
	ChessController.resume(self);
    if not self.init then
        self.init = true;
        self:requestFriendsGetRecentWarUser();
    end
end

RecentlyPlayerController.pause = function(self)
	ChessController.pause(self);

end

RecentlyPlayerController.requestFriendsGetRecentWarUser = function(self,offset)
    if offset then
        self.sendWulinBoothGetBoothJackpotListNoMore = false
    end
    if self.sendFriendsGetRecentWarUserIng or self.sendWulinBoothMyCreateBoothNoMore then return end;
    self.sendFriendsGetRecentWarUserIng = true;
    self.requestFriendsGetRecentWarUserIndex = offset or self.requestFriendsGetRecentWarUserIndex or 0;
    local params = {};
    params.mid = UserInfo.getInstance():getUid();
	params.offset = self.requestFriendsGetRecentWarUserIndex;
	params.limit = 15;
    HttpModule.getInstance():execute(HttpModule.s_cmds.FriendsGetRecentWarUser,params);
end

RecentlyPlayerController.onFriendsGetRecentWarUserResponse = function(self,isSuccess,message)
    self.sendFriendsGetRecentWarUserIng = false;
    if not isSuccess or (type(message) == "table" and message.data:get_value() == nil ) then
        if type(message) == "table" and message.flag:get_value() == 10009 then
            self:updateView(RecentlyPlayerScene.s_cmds.addRecentlyPlayerItem,{},true);
            self.sendWulinBoothMyCreateBoothNoMore = true;
            return ;
        end
        return ;
    end
    
    local tab = json.analyzeJsonNode(message.data);
    local list = tab.list;
    if type(list) ~= "table" or #list == 0 then
        if tab.total ~= 0 then
            self:updateView(RecentlyPlayerScene.s_cmds.addRecentlyPlayerItem,{},true);
        end
        self.sendWulinBoothMyCreateBoothNoMore = true;
        return ;
    end
    
    self.requestFriendsGetRecentWarUserIndex = self.requestFriendsGetRecentWarUserIndex + #list;

--    for i=1,10 do
--        local data = Copy(list[1]);
--        table.insert(list,data);
--    end

    self:updateView(RecentlyPlayerScene.s_cmds.addRecentlyPlayerItem,list,false);
end

RecentlyPlayerController.requestFollow = function(self,data)
    if type(data) ~= "table" then return end
    
    local params = {};
	params.target_mid = data.mid;
    if data.relation == 0 or data.relation == 1 then
	    params.op = 1;
    else
        params.op = 0;
    end

    HttpModule.getInstance():execute(HttpModule.s_cmds.FriendsAddFriend,params);
end

RecentlyPlayerController.onFriendsAddFriendResponse = function(self,isSuccess,message)
    if HttpModule.explainPHPMessage(isSuccess,message,"操作失败") then
        return ;
    end
    
    local tab = json.analyzeJsonNode(message.data);

    self:updateView(RecentlyPlayerScene.s_cmds.add_friend_response,tab);
end


-------------------- func ----------------------------------

RecentlyPlayerController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end


function RecentlyPlayerController:quickPlay()
    -- 封号状态
    if UserInfo.getInstance():isFreezeUser() then return end;
    -- 判断是否联网
    if not self:isLogined() then return ;end
    local roomConfig = RoomConfig.getInstance();
    local money = UserInfo.getInstance():getMoney();
    local gotoRoom = RoomProxy.getInstance():getMatchRoomByMoney(money);
    
    if not gotoRoom then 
        ChessToastManager.getInstance():showSingle("没有合适的场次");
    else
        RoomProxy.getInstance():gotoLevelRoom(gotoRoom.level);
    end
end
-------------------- config --------------------------------------------------
RecentlyPlayerController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.FriendsAddFriend]                = RecentlyPlayerController.onFriendsAddFriendResponse;
    [HttpModule.s_cmds.FriendsGetRecentWarUser]         = RecentlyPlayerController.onFriendsGetRecentWarUserResponse;
};


RecentlyPlayerController.s_nativeEventFuncMap = {
};
RecentlyPlayerController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	RecentlyPlayerController.s_nativeEventFuncMap or {});

RecentlyPlayerController.s_socketCmdFuncMap = {
};
-- 合并父类 方法
RecentlyPlayerController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	RecentlyPlayerController.s_httpRequestsCallBackFuncMap or {});

RecentlyPlayerController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	RecentlyPlayerController.s_socketCmdFuncMap or {});

------------------------------------- 命令响应函数配置 ------------------------
RecentlyPlayerController.s_cmdConfig = 
{
    [RecentlyPlayerController.s_cmds.onBack]                                            = RecentlyPlayerController.onBack;
    [RecentlyPlayerController.s_cmds.requestFollow]                                     = RecentlyPlayerController.requestFollow;
    [RecentlyPlayerController.s_cmds.requestFriendsGetRecentWarUser]                    = RecentlyPlayerController.requestFriendsGetRecentWarUser;
    [RecentlyPlayerController.s_cmds.quickPlay]                                         = RecentlyPlayerController.quickPlay;
}