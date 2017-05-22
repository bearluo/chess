
require("config/path_config");

require(BASE_PATH.."chessController");

WatchController = class(ChessController);

WatchController.s_cmds = 
{	
    back_action           = 1;
    refresh_action        = 2;
    entry_action          = 3;
    refresh_friends_game  = 4;
};

WatchController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
    self.kick_map = {};
    self.cache_follow_room_data = {};
    self.m_isMasterList = false
end

WatchController.resume = function(self)
    ChessController.resume(self);
    self:initContentView();
end;

WatchController.pause = function(self)
    ChessController.pause(self);
end;

WatchController.dtor = function(self)
    
end;

WatchController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end;

--------------------------------function------------------------------------


WatchController.initContentView = function(self)
    self.friend_room_num = 0
    self.charm_room_num = 0
--    self:onRefreshFriendsGame(); 
    if self.m_isMasterList then
        self:requestWatchList();
    else
        self:onRefreshFriendsGame();
    end
end

WatchController.onRefreshFriendsGame = function(self)
    self.kick_map = {}
    local data = UserInfo.getInstance():getUid();
    self:sendSocketMsg(FRIEND_CMD_GET_FRIEND_OB_LIST,data);
end

WatchController.onRefreshCharmGame = function(self)
    local data = UserInfo.getInstance():getUid();
    self:sendSocketMsg(OB_CMD_GET_CHARM_OB_LIST,data);
end


WatchController.requestWatchList = function(self)
    self:sendSocketMsg(CLIENT_WATCH_LIST,nil,nil,1);
end


WatchController.onBackAction = function(self)
    
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);

end;

WatchController.onRefreshAction = function(self,isMasterList)
    self.m_isMasterList = isMasterList
    if self.m_isMasterList then
        self:requestWatchList();
    else
        self:onRefreshFriendsGame();
    end
end;

WatchController.onRecvClientWatchList = function(self, data)
    if data then
        if data.curr_page == 0 then
            self.m_cache_room_data = {};
        end

        if self.m_cache_room_data then 
            for i,v in ipairs((data.watch_items or {})) do
                table.insert(self.m_cache_room_data,v);
            end
            self:updateView(WatchScene.s_cmds.updata_watch_game, self.m_cache_room_data);
        end

        if data.total_page == data.curr_page-1 or data.total_page == 0 then
            self.m_cache_room_data = nil;
        end
    end

end;


WatchController.onRecvServerFriendsWatchList = function(self, data)
    if data then
        if data.curr_page == 0 then
            self.cache_follow_room_data = {}
            self.cache_room_id = {}
            self.friend_room_num = 0
        end

        local temp_tab = {};
        for k,v in pairs((data.watch_items or {})) do   
            if v and self.kick_map[v.tid] ~= 1 then
                self.kick_map[v.tid] = 1;
                v.sort_key = 0
                table.insert(temp_tab,v);
            end
        end

        if temp_tab and self.cache_follow_room_data then 
            for i,v in ipairs((temp_tab or {})) do
                
                table.insert(self.cache_follow_room_data,v);
            end
        end

        if data.total_page == data.curr_page+1 or data.total_page == 0 then
            local num = #self.cache_follow_room_data or 0

            if num > 7 then
                local subTab = {}
                for i=1,7 do
                    subTab[i] = self.cache_follow_room_data[i]
                end
                self.cache_follow_room_data = subTab;
                num = 7
            end

            self.friend_room_num = num

--            if num < 10 then
                self:onRefreshCharmGame()
--            else
--                self:updateView(WatchScene.s_cmds.updata_friend_watch_game, self.cache_follow_room_data);
--                self:sendCheckTid()
--                self.cache_follow_room_data = nil;
--            end
        end
    end
end

WatchController.onRecvServerCharmWatchList = function(self, data)
    if data then
--        if data.curr_page == 0 then
--            self.charm_room_num = 10 - self.friend_room_num
--        end
        
        local temp_tab = {};
        for k,v in pairs((data.watch_items or {})) do   
            if v and self.kick_map[v.tid] ~= 1 then
                self.kick_map[v.tid] = 1;
                v.sort_key = 1
                table.insert(temp_tab,v);
            end
        end

        if type(temp_tab) == "table" and self.cache_follow_room_data then 
            local num = table.maxn(self.cache_follow_room_data)
            for i,v in ipairs(temp_tab) do
                if not v then break end
                if num > 10 then break end
                table.insert(self.cache_follow_room_data,v);
                num = num + 1
            end
        end

        if data.total_page == data.curr_page+1 or data.total_page == 0 then
            if self.cache_follow_room_data then
                table.sort(self.cache_follow_room_data,function(data1,data2)
                    local num1 = data1.ob_num or 0
                    local num2 = data2.ob_num or 0
                    local sort_key1 = data1.sort_key or -1
                    local sort_key2 = data2.sort_key or -1

                    if sort_key1 ~= sort_key2 then return sort_key1 < sort_key2 end

                    return num1 > num2
                end)
            end
            self:updateView(WatchScene.s_cmds.updata_charm_watch_game, self.cache_follow_room_data);
            self:sendCheckTid()
            self.cache_follow_room_data = {};
        end
    end
end

function WatchController.sendCheckTid(self)
    for k,v in pairs(self.cache_follow_room_data) do
        if v then
            table.insert(self.cache_room_id,v.tid)
        end
    end
    local num = #self.cache_room_id
    if num > 0 then 
        local info = {}
        info.num = num
        info.tab = self.cache_room_id
        self:sendSocketMsg(CHECK_ROOM_TYPE,info);
    end
    self.cache_room_id = {}
end

WatchController.onDownLoadImage = function(self , flag,json_data)
--	if not json_data then
--		return;
--	end

--	local info = json.analyzeJsonNode(data);
--	self:updateView(WatchScene.s_cmds.updataUserIcon,info.ImageName,tonumber(info.what));
end

function WatchController.onRecvCheckRoom(self,data)
    if data and data.watch_item then
        local tab = data.watch_item
        for k,v in pairs(tab) do
            if v then
                local roomConfig = RoomConfig.getInstance():getRoomLevelConfig(v.level)
                local str = "联网房间"
                if roomConfig then
                    str = roomConfig.name
                end
                v.roomName = str
            end
        end
        self:updateView(WatchScene.s_cmds.updata_tid_status,tab)
    end
end
--------------------------------config--------------------------------------

WatchController.s_cmdConfig = 
{
	[WatchController.s_cmds.back_action]		        = WatchController.onBackAction;
    [WatchController.s_cmds.refresh_action]	            = WatchController.onRefreshAction;
    [WatchController.s_cmds.refresh_friends_game]	    = WatchController.onRefreshFriendsGame; -- 更新棋友观战列表

}

WatchController.s_socketCmdFuncMap = {

    [CLIENT_WATCH_LIST]             = WatchController.onRecvClientWatchList;
    [FRIEND_CMD_GET_FRIEND_OB_LIST] = WatchController.onRecvServerFriendsWatchList;
    [OB_CMD_GET_CHARM_OB_LIST]      = WatchController.onRecvServerCharmWatchList;
    [CHECK_ROOM_TYPE]               = WatchController.onRecvCheckRoom;

    

};

WatchController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	WatchController.s_socketCmdFuncMap or {});

WatchController.s_httpRequestsCallBackFuncMap  = {
};

WatchController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	WatchController.s_httpRequestsCallBackFuncMap or {});

    
WatchController.s_nativeEventFuncMap = {
    [kCacheImageManager]               = WatchController.onDownLoadImage;
};
WatchController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	WatchController.s_nativeEventFuncMap or {});