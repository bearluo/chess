--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23

require(BASE_PATH.."chessController")

WatchlistController = class(ChessController);

WatchlistController.s_cmds = 
{
    back_action = 1;
    follow_user = 2;
};


WatchlistController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
    self.m_list_data = {};
end

WatchlistController.dtor = function(self)
end

WatchlistController.resume = function(self)
	ChessController.resume(self);
	Log.i("WatchlistController.resume");
    local info = {};
    info.tid = RoomProxy.getInstance():getTid();
    self:sendSocketMsg(OB_CMD_GET_OB_LIST,info);
end

WatchlistController.pause = function(self)
	ChessController.pause(self);
	Log.i("WatchlistController.pause");

end

-------------------- func ----------------------------------
WatchlistController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end

WatchlistController.onGetObList = function(self,info)
    if not info then return end
    if info.curr_page == 0 then
        self.m_list_data = {};
    end
    if info.item_num > 0 then 
        for i,v in pairs(info.watch_items) do 
            table.insert(self.m_list_data,v);
        end
    end
    if info.curr_page+1 >= info.page_num then
        self:updateView(WatchlistScene.s_cmds.updateWatchUserList,self.m_list_data);
    end
end

WatchlistController.onFollowBack = function(self,info)
    if not info then return end
    if info.ret ~= 0 then
        ChessToastManager.getInstance():show("关注失败!");
        return ;
    end

    self:updateView(WatchlistScene.s_cmds.updateWatchUserListItem,info);

end


WatchlistController.onFollowUser = function(self,uid)
    local info = {};

    info.uid = UserInfo.getInstance():getUid();
    info.target_uid = uid;
    info.op = 1;
    self:sendSocketMsg(FRIEND_CMD_ADD_FLLOW,info);
end

WatchlistController.onGetDownloadImage = function(self,flag,data) -- 用户头像
    Log.i("FriendsController.onGetDownloadImage");
    if not flag then 
        --下载失败
    end
    local info = json.analyzeJsonNode(data);
    for i,v in pairs(info) do
        Log.i(i ..":".. v );
    end
    self:updateView(WatchlistScene.s_cmds.change_userIcon,info);
end
-------------------------------- father func -----------------------


-------------------- http event ----------------------------------------------


-------------------- config --------------------------------------------------
WatchlistController.s_httpRequestsCallBackFuncMap  = {
};

WatchlistController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	WatchlistController.s_httpRequestsCallBackFuncMap or {});

WatchlistController.s_nativeEventFuncMap = {
   [kCacheImageManager]                 = WatchlistController.onGetDownloadImage;
   [kFriend_FollowCallBack]             = WatchlistController.onFollowBack;
};

WatchlistController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	WatchlistController.s_nativeEventFuncMap or {});

WatchlistController.s_socketCmdFuncMap = {
    [OB_CMD_GET_OB_LIST] = WatchlistController.onGetObList;
--    [FRIEND_CMD_ADD_FLLOW] = WatchlistController.onFollowBack;
};

WatchlistController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	WatchlistController.s_socketCmdFuncMap or {});


------------------------------------- 命令响应函数配置 ------------------------
WatchlistController.s_cmdConfig = 
{
    [WatchlistController.s_cmds.back_action]    = WatchlistController.onBack;
    [WatchlistController.s_cmds.follow_user]    = WatchlistController.onFollowUser;
    
}