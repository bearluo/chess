--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23

require(BASE_PATH.."chessController")

FindController = class(ChessController);

FindController.s_cmds = 
{
    onBack              = 1;
    requestFollow       = 2;
    requestWulinBoothRecommend  = 3;
    onEndgateMenuBtnClick = 4;
    requestData         = 5;
    quickPlay           = 6;
    save_mychess        = 7;
};


FindController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end

FindController.dtor = function(self)
    delete(self.m_forbid_dialog);
end

FindController.resume = function(self)
	ChessController.resume(self);
	Log.i("FindController.resume");
    require(BASE_PATH.."chessShareManager");
    ChessShareManager.getInstance();
    self:requestFriendsGetRecentWarUser();
--    self:requestData();
end

FindController.pause = function(self)
	ChessController.pause(self);
	Log.i("FindController.pause");

end

FindController.requestData = function(self)
    self.wulinBoothRecommendOffset = 0;
    self.wulinBoothOwnCreateOffset = 0;
    self.wulinBoothTimeSortOffset = 0;
    self.wulinBoothJackpotSortOffset = 0;
    self.sendWulinBoothRecommendNoMore = false;
    self.sendWulinBoothMyCreateBoothNoMore = false;
    self.sendWulinBoothGetBoothTimeListNoMore = false;
    self.sendWulinBoothGetBoothJackpotListNoMore = false;

    self:requestGetActionList();
    self:requestFriendsGetRecentWarUser();
    self:requestWulinBoothRecommend();
end


FindController.requestGetActionList = function(self)
    local params = {};
    params.bid = PhpConfig.getSidPlatform();
    params.versions = kLuaVersion;
    HttpModule.getInstance():execute(HttpModule.s_cmds.IndexGetActionList,params);
end

FindController.onIndexGetActionListResponse = function(self,isSuccess,message)

    if not isSuccess or message.data:get_value() == nil then
        self:updateView(FindScene.s_cmds.initAdScrollView);
        return ;
    end

    local tab = json.analyzeJsonNode(message.data);

    self:updateView(FindScene.s_cmds.initAdScrollView,tab);
end

FindController.requestFriendsGetRecentWarUser = function(self)
    local params = {};
    params.mid = UserInfo.getInstance():getUid();
	params.offset = 0;
	params.limit = 3;
    HttpModule.getInstance():execute(HttpModule.s_cmds.FriendsGetRecentWarUser,params);
end

FindController.onFriendsGetRecentWarUserResponse = function(self,isSuccess,message)
    if not isSuccess or message.data:get_value() == nil then
        self:updateView(FindScene.s_cmds.initRecentlyPlayerView);
        return ;
    end
    
    local tab = json.analyzeJsonNode(message.data);

    self:updateView(FindScene.s_cmds.initRecentlyPlayerView,tab.list);
end

FindController.requestFollow = function(self,data)
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

FindController.onFriendsAddFriendResponse = function(self,isSuccess,message)
    if HttpModule.explainPHPMessage(isSuccess,message,"操作失败") then
        return ;
    end
    
    local tab = json.analyzeJsonNode(message.data);

    self:updateView(FindScene.s_cmds.onFriendsAddFriendResponse,tab);
end

FindController.requestWulinBoothRecommend = function(self)
    if self.sendWulinBoothRecommendNoMore or self.sendWulinBoothRecommendIng then 
        return 
    end
    self.sendWulinBoothRecommendIng = true;
    self.wulinBoothRecommendOffset = self.wulinBoothRecommendOffset or 0;
    local params = {};
	params.limit = 3;
    params.offset = self.wulinBoothRecommendOffset;
    HttpModule.getInstance():execute(HttpModule.s_cmds.WulinBoothRecommend,params);
end

FindController.onWulinBoothRecommendResponse = function(self,isSuccess,message)
    self.sendWulinBoothRecommendIng = false;
    if not isSuccess or message.data:get_value() == nil then
        self:updateView(FindScene.s_cmds.onWulinBoothRecommendResponse);
        return ;
    end
    
    local tab = json.analyzeJsonNode(message.data);
    local list = tab.list;
    if type(list) ~= "table" or #list == 0 then
        if tab.total ~= 0 then
            self:updateView(FindScene.s_cmds.onWulinBoothRecommendResponse,{},true);
        end
        self.sendWulinBoothRecommendNoMore = true;
        return ;
    end
    self.wulinBoothRecommendOffset = self.wulinBoothRecommendOffset + #list;
    self:updateView(FindScene.s_cmds.onWulinBoothRecommendResponse,list,false);
end

FindController.requestWulinBooth = function(self,index,sort,offset)
    if index == 1 then
        if offset then
            self.sendWulinBoothMyCreateBoothNoMore = false
        end
        if self.sendWulinBoothMyCreateBoothIng or self.sendWulinBoothMyCreateBoothNoMore then return end;
        self.sendWulinBoothMyCreateBoothIng= true;
        self.wulinBoothOwnCreateOffset = offset or self.wulinBoothOwnCreateOffset or 0;
        local params = {};
	    params.limit = 5;
        params.offset = self.wulinBoothOwnCreateOffset;
        params.sort_type = sort;
        HttpModule.getInstance():execute(HttpModule.s_cmds.WulinBoothMyCreateBooth,params);
    elseif index == 2 then
        if offset then
            self.sendWulinBoothGetBoothTimeListNoMore = false
        end
        if self.sendWulinBoothGetBoothTimeListIng or self.sendWulinBoothGetBoothTimeListNoMore then return end;
        self.sendWulinBoothGetBoothTimeListIng= true;
        self.wulinBoothTimeSortOffset = offset or self.wulinBoothTimeSortOffset or 0;
        local params = {};
	    params.limit = 5;
        params.offset = self.wulinBoothTimeSortOffset;
        params.sort_type = sort;
		params.sort_field = "add_time";
        HttpModule.getInstance():execute(HttpModule.s_cmds.WulinBoothGetBoothTimeList,params);
    elseif index == 3 then
        if offset then
            self.sendWulinBoothGetBoothJackpotListNoMore = false
        end
        if self.sendWulinBoothGetBoothJackpotListIng or self.sendWulinBoothGetBoothJackpotListNoMore then return end;
        self.sendWulinBoothGetBoothJackpotListIng= true;
        self.wulinBoothJackpotSortOffset = offset or self.wulinBoothJackpotSortOffset or 0;
        local params = {};
	    params.limit = 5;
        params.offset = self.wulinBoothJackpotSortOffset;
        params.sort_type = sort;
		params.sort_field = "prize_pool";
        HttpModule.getInstance():execute(HttpModule.s_cmds.WulinBoothGetBoothJackpotList,params);
    end
end

FindController.onWulinBoothMyCreateBoothResponse = function(self,isSuccess,message)
    self.sendWulinBoothMyCreateBoothIng = false;
    if not isSuccess or message.data:get_value() == nil then
        self:updateView(FindScene.s_cmds.addEndgate,1);
        return ;
    end
    
    local tab = json.analyzeJsonNode(message.data);
    local list = tab.list;
    if type(list) ~= "table" or #list == 0 then
        self:updateView(FindScene.s_cmds.addEndgate,1,{},true,tab.total == 0);
        self.sendWulinBoothMyCreateBoothNoMore = true;
        return ;
    end

    self.wulinBoothOwnCreateOffset = self.wulinBoothOwnCreateOffset + #list;

    self:updateView(FindScene.s_cmds.addEndgate,1,list,false);
end

FindController.onWulinBoothGetBoothTimeListResponse = function(self,isSuccess,message)
    self.sendWulinBoothGetBoothTimeListIng = false;
    if not isSuccess or message.data:get_value() == nil then
        self:updateView(FindScene.s_cmds.addEndgate,2);
        return ;
    end
    
    local tab = json.analyzeJsonNode(message.data);
    local list = tab.list;
    if type(list) ~= "table" or #list == 0 then
        self:updateView(FindScene.s_cmds.addEndgate,2,{},true,tab.total == 0);
        self.sendWulinBoothGetBoothTimeListNoMore = true;
        return ;
    end

    self.wulinBoothTimeSortOffset = self.wulinBoothTimeSortOffset + #list;

    self:updateView(FindScene.s_cmds.addEndgate,2,list,false);
end

FindController.onWulinBoothGetBoothJackpotListResponse = function(self,isSuccess,message)
    self.sendWulinBoothGetBoothJackpotListIng = false;
    if not isSuccess or message.data:get_value() == nil then
        self:updateView(FindScene.s_cmds.addEndgate,3);
        return ;
    end
    
    local tab = json.analyzeJsonNode(message.data);
    local list = tab.list;
    if type(list) ~= "table" or #list == 0 then
        self:updateView(FindScene.s_cmds.addEndgate,3,{},true,tab.total == 0);
        self.sendWulinBoothGetBoothJackpotListNoMore = true;
        return ;
    end

    self.wulinBoothJackpotSortOffset = self.wulinBoothJackpotSortOffset + #list;

    self:updateView(FindScene.s_cmds.addEndgate,3,list,false);
end

FindController.isForbidPlayOnline = function(self)
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

FindController.onEntryRoom = function(self, index, flag)
    UserInfo.getInstance():setGameType(index);
    StateMachine.getInstance():pushState(States.OnlineRoom,StateMachine.STYPE_CUSTOM_WAIT);
end

function FindController:quickPlay()
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


-- isSelf,是否个人收藏
FindController.onSaveMychess = function(self,isSelf, chessData)
    local post_data = {};
    post_data.mid = UserInfo.getInstance():getUid();
    post_data.manual_id = chessData.manual_id;
    post_data.collect_type = (isSelf and 2) or 1; -- 收藏类型, 1公共收藏，2人个收藏 
    self:sendHttpMsg(HttpModule.s_cmds.openOrSelfChess,post_data,"请求中...");   
end

FindController.onSaveChessCallBack = function(self, flag, message)
    if not flag then
        if type(message) == "number" then
            return; 
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
            return;
        end;        
    end;
    local data = json.analyzeJsonNode(message.data);
    self:updateView(FindScene.s_cmds.save_mychess,data);
end

-------------------- func ----------------------------------

FindController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end

-------------------- config --------------------------------------------------
FindController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.IndexGetActionList]                      = FindController.onIndexGetActionListResponse;
    [HttpModule.s_cmds.FriendsGetRecentWarUser]                 = FindController.onFriendsGetRecentWarUserResponse;
    [HttpModule.s_cmds.FriendsAddFriend]                        = FindController.onFriendsAddFriendResponse;
    [HttpModule.s_cmds.WulinBoothRecommend]                     = FindController.onWulinBoothRecommendResponse;
    [HttpModule.s_cmds.WulinBoothMyCreateBooth]                 = FindController.onWulinBoothMyCreateBoothResponse;
    [HttpModule.s_cmds.WulinBoothGetBoothTimeList]              = FindController.onWulinBoothGetBoothTimeListResponse;
    [HttpModule.s_cmds.WulinBoothGetBoothJackpotList]           = FindController.onWulinBoothGetBoothJackpotListResponse;
    [HttpModule.s_cmds.openOrSelfChess]                         = FindController.onSaveChessCallBack;
};


FindController.s_nativeEventFuncMap = {
};
FindController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	FindController.s_nativeEventFuncMap or {});

FindController.s_socketCmdFuncMap = {
};
-- 合并父类 方法
FindController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	FindController.s_httpRequestsCallBackFuncMap or {});

FindController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	FindController.s_socketCmdFuncMap or {});

------------------------------------- 命令响应函数配置 ------------------------
FindController.s_cmdConfig = 
{
    [FindController.s_cmds.onBack]                          = FindController.onBack;
    [FindController.s_cmds.requestFollow]                   = FindController.requestFollow;
    [FindController.s_cmds.requestWulinBoothRecommend]      = FindController.requestWulinBoothRecommend;
    [FindController.s_cmds.onEndgateMenuBtnClick]           = FindController.requestWulinBooth;
    [FindController.s_cmds.requestData]                     = FindController.requestData;
    [FindController.s_cmds.quickPlay]                       = FindController.quickPlay;
    [FindController.s_cmds.save_mychess]                    = FindController.onSaveMychess;
    
    
}