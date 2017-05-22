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
    if not isSuccess or message.data:get_value() == nil then
        if message.flag:get_value() == 10009 then
            self:updateView(RecentlyPlayerScene.s_cmds.addRecentlyPlayerItem,{},true);
            self.sendWulinBoothMyCreateBoothNoMore = true;
            return ;
        end
        self:updateView(RecentlyPlayerScene.s_cmds.initRecentlyPlayerView);
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

    self:updateView(RecentlyPlayerScene.s_cmds.onFriendsAddFriendResponse,tab);
end


-------------------- func ----------------------------------

RecentlyPlayerController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end



RecentlyPlayerController.isForbidPlayOnline = function(self)
    -- 封号状态
    if UserInfo.getInstance():getUserStatus() == 1 then
        local freeze_time = UserInfo.getInstance():getUserFreezEndTime();
        local tip_msg;
        if freeze_time ~= 0 then
            tip_msg = "很抱歉，您的账号被多次举报，经核实已被冻结，将于"..os.date("%Y-%m-%d %H:%M",freeze_time) .."解封，期间仅能进入单机和残局版块。"
        else        
            tip_msg = "很抱歉，您的账号被多次举报，经核实已被冻结，仅能进入单机和残局版块。"
        end;
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

RecentlyPlayerController.onEntryRoom = function(self, index, flag)
    UserInfo.getInstance():setGameType(index);
    StateMachine.getInstance():pushState(States.OnlineRoom,StateMachine.STYPE_CUSTOM_WAIT);
end

function RecentlyPlayerController:quickPlay()
    -- 封号状态
    if self:isForbidPlayOnline() then return end;
    -- 判断是否联网
    if not self:isLogined() then return ;end
    local data = UserInfo.getInstance():getRoomDataList();
    local money = UserInfo.getInstance():getMoney();
    local gotoRoom = nil;
    if not data then 
        ChessToastManager.getInstance():showSingle("没有房间数据，请重新登录");
        return 
    end
    for i,room in ipairs(data) do
        if money >= room.minmoney then
            gotoRoom = room;
        end
    end
    if not gotoRoom then 
        ChessToastManager.getInstance():showSingle("没有合适的场次");
    else
        UserInfo.getInstance():setMoneyType(tonumber(gotoRoom.room_type));--room_type:1,2,3
        UserInfo.getInstance():setRoomLevel(tonumber(gotoRoom.level));
	    self:onEntryRoom(tonumber(gotoRoom.type));
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