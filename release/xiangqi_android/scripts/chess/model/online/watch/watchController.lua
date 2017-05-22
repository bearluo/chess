
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
    if self.m_isMasterList == false then
        self:onRefreshFriendsGame();
    else
        self:requestWatchList();
    end
end

WatchController.onRefreshFriendsGame = function(self)
    local data = UserInfo.getInstance():getUid();
    self:sendSocketMsg(FRIEND_CMD_GET_FRIEND_OB_LIST,data);
end

WatchController.requestWatchList = function(self)
--	print_string("WatchController.requestWatchList");
--	local tips = "请稍候...";
--	local post_data = {};
--	post_data.pageNo = 0;
--	post_data.pageNum = 0;

--	HttpModule.getInstance():execute(HttpModule.s_cmds.getWatchGame,post_data,tips);
    self:sendSocketMsg(CLIENT_WATCH_LIST,nil,nil,1);
end


WatchController.onBackAction = function(self)
    
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);

end;

WatchController.onRefreshAction = function(self,isMasterList)
    self.m_isMasterList = isMasterList;
    if isMasterList then
        self:requestWatchList();
    else
        self:onRefreshFriendsGame();
    end
end;

WatchController.onEntryAction = function(self, index, flag)
    UserInfo.getInstance():setGameType(GAME_TYPE_WATCH);
    StateMachine.getInstance():pushState(States.OnlineRoom,StateMachine.STYPE_CUSTOM_WAIT);
end;

WatchController.onGetWatchGameResponse = function(self, flag, data)
Log.i("WatchController.onGetWatchGameResponse");
    if not flag then
        return;

    end;
    self:updateView(WatchScene.s_cmds.updata_watch_game, data.data);
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
            self.m_cache_room_data = {};
        end

        if self.m_cache_room_data then 
            for i,v in ipairs((data.watch_items or {})) do
                table.insert(self.m_cache_room_data,v);
            end
            self:updateView(WatchScene.s_cmds.updata_friend_watch_game, self.m_cache_room_data);
        end

        if data.total_page == data.curr_page-1 or data.total_page == 0 then
            self.m_cache_room_data = nil;
        end
    end
end

WatchController.onDownLoadImage = function(self , flag,json_data)
	if not json_data then
		return;
	end

	local info = json.analyzeJsonNode(data);
	self:updateView(WatchController.s_cmds.updataUserIcon,info.ImageName,tonumber(info.what));
end
--------------------------------config--------------------------------------

WatchController.s_cmdConfig = 
{
	[WatchController.s_cmds.back_action]		        = WatchController.onBackAction;
    [WatchController.s_cmds.refresh_action]	            = WatchController.onRefreshAction;
    [WatchController.s_cmds.entry_action]	            = WatchController.onEntryAction;
    [WatchController.s_cmds.refresh_friends_game]	    = WatchController.onRefreshFriendsGame; -- 更新棋友观战列表

}

WatchController.s_socketCmdFuncMap = {

    [CLIENT_WATCH_LIST]             = WatchController.onRecvClientWatchList;
    [FRIEND_CMD_GET_FRIEND_OB_LIST] = WatchController.onRecvServerFriendsWatchList;
};

WatchController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	WatchController.s_socketCmdFuncMap or {});

WatchController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.getWatchGame] = WatchController.onGetWatchGameResponse
};

WatchController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	WatchController.s_httpRequestsCallBackFuncMap or {});

    
WatchController.s_nativeEventFuncMap = {
    [kCacheImageManager]               = WatchController.onDownLoadImage;
};
WatchController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	WatchController.s_nativeEventFuncMap or {});