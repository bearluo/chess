require(VIEW_PATH.."watch_list_dialog");
require(BASE_PATH.."chessDialogScene");

WatchListDialog2 = class(ChessDialogScene,false);


WatchListDialog2.ctor = function(self,id)
    super(self,watch_list_dialog)

    self.mBg = self.m_root:getChildByName("bg")
    self.mBg:setEventTouch(self,function()end)
    local tabBg = self.mBg:getChildByName("tab_bg")
    self.mTabIcon = tabBg:getChildByName("tab_icon")
    self.mFollowBtn = tabBg:getChildByName("follow_btn")
    self.mMasterBtn = tabBg:getChildByName("master_btn")
    self.mFollowBtn:setOnClick(self,self.showFollowView)
    self.mMasterBtn:setOnClick(self,self.showMasterView)
    self.mWatchList = self.mBg:getChildByName("watch_list")
    self.mFollowList = self.mWatchList:getChildByName("follow_list")
    self.mMasterList = self.mWatchList:getChildByName("master_list")
    self.mNoFollowView = self.mWatchList:getChildByName("no_follow_view")
    self.mNoMasterView = self.mWatchList:getChildByName("no_master_view")
    -- 初始化界面
    local x,y = self.mBg:getAbsolutePos()
    local w,h = self.mBg:getSize()
    self.mBg:setClip(x,y,w,h)
    local w,h = self.mWatchList:getSize()
    self.mMoveW = w
    local x,y = self.mMasterList:getPos()
    self.mMasterList:setPos(x+w)
    self.mNoMasterView:setPos(x+w)
    self.mNoFollowView:setVisible(false)
    self.mNoMasterView:setVisible(false)

    self.mTabIcon:setAlign(kAlignLeft)
    self.mFollowBtn:getChildByName("txt"):setColor(170,135,100)
    self.mMasterBtn:getChildByName("txt"):setColor(115,65,35)

    self:setShieldClick(self, self.dismiss)
    self.m_root:getChildByName("back_btn"):setOnClick(self,self.dismiss)
end

WatchListDialog2.dtor = function(self)
    self:stopMoveAnim()
end

WatchListDialog2.show = function(self)
    self.super.show(self)
    self.mWatchList:setPos(0)
    self:showFollowView()
    if not self.mRegister then 
        self.mRegister = true
        OnlineSocketManagerProcesser.getInstance():register(CLIENT_WATCH_LIST,self,self.onRecvClientWatchList)
        OnlineSocketManagerProcesser.getInstance():register(FRIEND_CMD_GET_FRIEND_OB_LIST,self,self.onRecvServerFriendsWatchList)
        OnlineSocketManagerProcesser.getInstance():register(OB_CMD_GET_CHARM_OB_LIST,self,self.onRecvServerCharmWatchList)
        OnlineSocketManagerProcesser.getInstance():register(CHECK_ROOM_TYPE,self,self.onRecvCheckRoom)
    end
end

WatchListDialog2.dismiss = function(self)
    self.super.dismiss(self)
    if self.mRegister then 
        self.mRegister = false
        OnlineSocketManagerProcesser.getInstance():unregister(CLIENT_WATCH_LIST,self,self.onRecvClientWatchList)
        OnlineSocketManagerProcesser.getInstance():unregister(FRIEND_CMD_GET_FRIEND_OB_LIST,self,self.onRecvServerFriendsWatchList)
        OnlineSocketManagerProcesser.getInstance():unregister(OB_CMD_GET_CHARM_OB_LIST,self,self.onRecvServerCharmWatchList)
        OnlineSocketManagerProcesser.getInstance():unregister(CHECK_ROOM_TYPE,self,self.onRecvCheckRoom)
    end
end

function WatchListDialog2:setUpdateFollowListFunc(obj,func)
    self.mUpdateFollowListFuncObj = obj
    self.mUpdateFollowListFuncFunc = func
end

function WatchListDialog2:showFollowView()
    self.mTabIcon:setAlign(kAlignLeft)
    self.mFollowBtn:getChildByName("txt"):setColor(115,65,35)
    self.mMasterBtn:getChildByName("txt"):setColor(170,135,100)
    self:refreshFollowListView()
    self:startMoveAnim(0)
end

function WatchListDialog2:showMasterView()
    self.mTabIcon:setAlign(kAlignRight)
    self.mFollowBtn:getChildByName("txt"):setColor(170,135,100)
    self.mMasterBtn:getChildByName("txt"):setColor(115,65,35)
    self:refreshMasterListView()
    self:startMoveAnim(-self.mMoveW)
end

function WatchListDialog2:startMoveAnim(target)
    self:stopMoveAnim()
    target = tonumber(target) or 0
    self.mMoveAnim = AnimFactory.createAnimInt(kAnimLoop, 0, 1, 1000/60, -1)
    local x,y = self.mWatchList:getPos()
    local offset = target - x
    self.mMoveAnim:setEvent(self,function()
        local move = offset * 0.2
        offset = offset - move
        local x,y = self.mWatchList:getPos()
        if math.abs(offset) < 10 then
            self.mWatchList:setPos(target)
            self:stopMoveAnim()
        else
            self.mWatchList:setPos(x+move)
        end
    end)
end

function WatchListDialog2:stopMoveAnim()
    delete(self.mMoveAnim)
end

WatchListDialog2.onRecvClientWatchList = function(self, data)
    if data then
        if data.curr_page == 0 then
            self.m_cache_room_data = {};
            self.m_curr_page = 0
        end

        if self.m_cache_room_data and self.m_curr_page == data.curr_page then 
            for i,v in ipairs((data.watch_items or {})) do
                table.insert(self.m_cache_room_data,v);
            end
            self.m_curr_page = self.m_curr_page + 1
        end

        if data.total_page == self.m_curr_page or data.total_page == 0 then
            self:initMasterListView(self.m_cache_room_data);
            self:sendCheckTid(self.m_cache_room_data)
            self.m_cache_room_data = nil;
        end
    end
end

function WatchListDialog2:refreshMasterListView()
    OnlineSocketManager.getHallInstance():sendMsg(CLIENT_WATCH_LIST,nil,nil,1)
end

function WatchListDialog2:initMasterListView(data)
    if data and #data > 0 then
        self.mNoMasterView:setVisible(false)
        self.mMasterList:setVisible(true)
	    self.mMasterAdapter = new(WatchListDialog2ItemCacheAdapter,WatchListDialog2WatchGameItem,data);
        self.mMasterAdapter:setWatchSceneHandler(self);
        self.mMasterList:setAdapter(self.mMasterAdapter);
    else
        self.mMasterList:setAdapter()
        self.mNoMasterView:setVisible(true)
        self.mMasterList:setVisible(false)
    end
end

function WatchListDialog2:refreshFollowListView()
    local data = UserInfo.getInstance():getUid();
    self.mFriendCmdIndex = 0
    self.mOBCmdIndex = -1 -- 停止接收上一个魅力榜的消息
    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_GET_FRIEND_OB_LIST,data);
end

function WatchListDialog2:initFollowListView(data)
    if type(self.mUpdateFollowListFuncFunc) == "function" then
        self.mUpdateFollowListFuncFunc(self.mUpdateFollowListFuncObj,data)
    end
    if data and #data > 0 then
        self.mNoFollowView:setVisible(false)
        self.mFollowList:setVisible(true)
		self.mFollowAdapter = new(WatchListDialog2ItemCacheAdapter,WatchListDialog2FriendWatchItem,data);
        self.mFollowAdapter:setWatchSceneHandler(self);
        self.mFollowList:setAdapter(self.mFollowAdapter);
    else
        self.mFollowList:setAdapter()
        self.mFollowList:setVisible(false)
        self.mNoFollowView:setVisible(true)
    end
end

WatchListDialog2.onRefreshCharmGame = function(self)
    local data = UserInfo.getInstance():getUid();
    self.mOBCmdIndex = 0
    OnlineSocketManager.getHallInstance():sendMsg(OB_CMD_GET_CHARM_OB_LIST,data);
end


WatchListDialog2.onRecvServerFriendsWatchList = function(self, data)
    if data and self.mFriendCmdIndex == data.curr_page then
        self.mFriendCmdIndex = self.mFriendCmdIndex + 1
        if data.curr_page == 0 then
            self.cache_follow_room_data = {}
            self.kick_map = {}
        end

        local temp_tab = {};
        for k,v in pairs((data.watch_items or {})) do   
            if v and self.kick_map[v.tid] ~= 1 then
                self.kick_map[v.tid] = 1;
                v.sort_key = 0
                table.insert(temp_tab,v);
            end
        end

        if temp_tab then 
            for i,v in ipairs((temp_tab or {})) do
                table.insert(self.cache_follow_room_data,v);
            end
        end

        if data.total_page == data.curr_page+1 or data.total_page == 0 then
            self.mFriendCmdIndex = -1
            local num = #self.cache_follow_room_data or 0

            if num > 7 then
                local subTab = {}
                for i=1,7 do
                    subTab[i] = self.cache_follow_room_data[i]
                end
                self.cache_follow_room_data = subTab;
            end

            self:onRefreshCharmGame()
        end
    end
end


WatchListDialog2.onRecvServerCharmWatchList = function(self, data)
    if data and self.mOBCmdIndex == data.curr_page then
        self.mOBCmdIndex = self.mOBCmdIndex + 1
        local temp_tab = {};
        for k,v in pairs((data.watch_items or {})) do   
            if v and self.kick_map[v.tid] ~= 1 then
                self.kick_map[v.tid] = 1;
                v.sort_key = 1
                table.insert(temp_tab,v);
            end
        end

        if type(temp_tab) == "table" then 
            local num = table.maxn(self.cache_follow_room_data)
            for i,v in ipairs(temp_tab) do
                if not v then break end
                if num > 10 then break end
                table.insert(self.cache_follow_room_data,v);
                num = num + 1
            end
        end

        if data.total_page == data.curr_page+1 or data.total_page == 0 then
            self.mOBCmdIndex = -1
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
            self:initFollowListView(self.cache_follow_room_data);
            self:sendCheckTid(self.cache_follow_room_data)
        end
    end
end

function WatchListDialog2.sendCheckTid(self,data)
    if not data then return end
    local tab = {}
    for k,v in pairs(data) do
        if v then
            table.insert(tab,v.tid)
        end
    end
    local num = #tab
    if num > 0 then 
        local info = {}
        info.num = num
        info.tab = tab
        OnlineSocketManager.getHallInstance():sendMsg(CHECK_ROOM_TYPE,info);
    end
end


function WatchListDialog2.onRecvCheckRoom(self,data)
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
        self:onUpdataRoomLevel(tab)
    end
end

WatchListDialog2.onUpdataRoomLevel = function(self,data)
    if not data then return end
    local children = self.mFollowList:getChildren()
    for k,v in pairs(children) do
        if v and type(v.updataWatchRoomLevel) == "function" then
            v:updataWatchRoomLevel(data)
        end
    end
    local children = self.mMasterList:getChildren()
    for k,v in pairs(children) do
        if v and type(v.updataWatchRoomLevel) == "function" then
            v:updataWatchRoomLevel(data)
        end
    end
    self.mRoomLevelData = CombineTables(self.mRoomLevelData or {},data); 
end


WatchListDialog2.onWatchListItemClick = function(self,item)
    RoomProxy.getInstance():gotoWatchRoom(item.m_obtid,item.m_room_level)
end


----------------------

WatchListDialog2ItemCacheAdapter = class(CacheAdapter);

WatchListDialog2ItemCacheAdapter.setWatchSceneHandler = function(self,handler)
    self.m_handler = handler;
end

WatchListDialog2ItemCacheAdapter.getView = function(self,index)
    local view = self.m_views[index];

	if view and self.m_changedItems[view] then
		self.m_changedItems[view] = nil;
		delete(view);
		self.m_views[index] = nil
	end

    if self.m_views[index] then 
        self.m_views[index]:setVisible(true);
    else
		self.m_views[index] =  Adapter.getView(self,index);
        if self.m_views[index].setWatchSceneHandler then
            self.m_views[index]:setWatchSceneHandler(self.m_handler);
        end
	end

	return self.m_views[index];    
end
------观战列表Item
require(VIEW_PATH.."watch_list_dialog_item");
WatchListDialog2WatchGameItem = class(Node);
WatchListDialog2WatchGameItem.ICON_PRE = "record";

WatchListDialog2WatchGameItem.ctor = function(self,room)
    self.m_data = room;
    self.m_obtid = room.tid;
    self.m_root_view = SceneLoader.load(watch_list_dialog_item);
    self.m_root_view:setAlign(kAlignCenter);
    self:addChild(self.m_root_view);
    local w,h = self.m_root_view:getSize();
    self:setSize(w,h);

    self.m_btn = self.m_root_view:getChildByName("bg");
    self.m_btn:setOnClick(self,self.onClick);
    self.m_btn:setSrollOnClick();

    self.m_watch_count = self.m_btn:getChildByName("watch_num");
    self.m_watch_count:setText((room.ob_num or 0) .. " 人观战");
    self.m_watch_time = self.m_btn:getChildByName("watch_time");
    self.m_watch_time:setText("已进行: "..self:getTime(room.play_time));
    
    self.m_red_player = json.decode(room.red_info);
    self.m_red_name = self.m_btn:getChildByName("red_name");
    self.m_red_name:setText( lua_string_sub(self.m_red_player.user_name,4));
    self.m_red_vip_logo = self.m_btn:getChildByName("red_vip_logo");
    self.m_red_level_icon = self.m_btn:getChildByName("red_level")
    self.m_red_level_icon:setFile("common/icon/level_"..(10-UserInfo.getInstance():getDanGradingLevelByScore(self.m_red_player.score))..".png");
    
    self.m_black_player = json.decode(room.black_info);
    self.m_black_name = self.m_btn:getChildByName("black_name")
    self.m_black_name:setText(lua_string_sub(self.m_black_player.user_name,4))
    self.m_black_vip_logo = self.m_btn:getChildByName("black_vip_logo")
    self.m_black_level_icon = self.m_btn:getChildByName("black_level")
    self.m_black_level_icon:setFile("common/icon/level_"..(10-UserInfo.getInstance():getDanGradingLevelByScore(self.m_black_player.score))..".png");
    
    -- 红方头像
    self.m_red_user_head_mask = self.m_btn:getChildByName("red_head")
    self.m_red_vip_frame = self.m_btn:getChildByName("red_vip")
    self.m_red_user_head = new(Mask,UserInfo.DEFAULT_ICON[1],"hall/icon_frame_mask.png");
    self.m_red_user_head:setSize(self.m_red_user_head_mask:getSize());
    self.m_red_user_head_mask:addChild(self.m_red_user_head);

    local iconType = tonumber(self.m_red_player.icon);
    if iconType then
        if 0 ~= iconType then
            self.m_red_user_head:setFile(UserInfo.DEFAULT_ICON[iconType]  or UserInfo.DEFAULT_ICON[1]);
        end
    else
        if "" ~= self.m_red_player.icon then --兼容1.7.5之前的版本的头像为""时显示默认头像。
            self.m_red_user_head:setUrlImage(self.m_red_player.icon,UserInfo.DEFAULT_ICON[1]);
        end
    end

    -- 黑方头像
    self.m_black_user_head_mask = self.m_btn:getChildByName("black_head")
    self.m_black_vip_frame = self.m_btn:getChildByName("black_vip")
    self.m_black_user_head = new(Mask,UserInfo.DEFAULT_ICON[1],"hall/icon_frame_mask.png");
    self.m_black_user_head:setSize(self.m_black_user_head_mask:getSize());
    self.m_black_user_head_mask:addChild(self.m_black_user_head);

    local iconType = tonumber(self.m_black_player.icon);
    if iconType then
        if 0 ~= iconType then
            self.m_black_user_head:setFile(UserInfo.DEFAULT_ICON[iconType] or UserInfo.DEFAULT_ICON[1]);
        end
    else
        if "" ~= self.m_black_player.icon then --兼容1.7.5之前的版本的头像为""时显示默认头像。
            self.m_black_user_head:setUrlImage(self.m_black_player.icon,UserInfo.DEFAULT_ICON[1]);
        end
    end

    --红方vip
    if self.m_red_player and self.m_red_player.is_vip and self.m_red_player.is_vip == 1 then
        self.m_red_vip_frame:setVisible(true);
        self.m_red_vip_logo:setVisible(true);
    else
        self.m_red_vip_frame:setVisible(false);
        self.m_red_vip_logo:setVisible(false);
    end
    --黑方vip
    if self.m_black_player and self.m_black_player.is_vip and self.m_black_player.is_vip == 1 then 
        self.m_black_vip_frame:setVisible(true);
        self.m_black_vip_logo:setVisible(true);
    else
        self.m_black_vip_frame:setVisible(false);
        self.m_black_vip_logo:setVisible(false);
    end
end

function WatchListDialog2WatchGameItem.updataWatchRoomLevel(self,data)
    local level = 0
    if not self.m_obtid or not data[self.m_obtid] then
    else
        level = data[self.m_obtid].level or 0;
    end 
    self.m_room_level = level;
end

WatchListDialog2WatchGameItem.onClick = function(self)
    if self.m_handler then
        WatchListDialog2.onWatchListItemClick(self.m_handler,self);
    end
end

WatchListDialog2WatchGameItem.setWatchSceneHandler = function(self,handler)
    self.m_handler = handler;
    if self.m_handler and type(self.m_handler.mRoomLevelData) == "table" then
        self:updataWatchRoomLevel(self.m_handler.mRoomLevelData)
    end
end

WatchListDialog2WatchGameItem.getTime = function(self,time)
    local str = "";
    if time and time > 0 then
        local miao = time%60;
        local temp = time - miao;
        local fen = temp/60;
        str = fen .. "分" .. miao .. "秒";
    else
        str = "0分"
    end
    return str;
end

WatchListDialog2WatchGameItem.getData = function(self)
	return self.m_data;
end


WatchListDialog2WatchGameItem.dtor = function(self)
	
end


----------我的关注item--------
require(VIEW_PATH .. "watch_list_dialog_item2")

WatchListDialog2FriendWatchItem = class(Node);

function WatchListDialog2FriendWatchItem.ctor(self,room)
	self.m_data = room;
    self.m_obtid = room.tid;
    self.m_root_view = SceneLoader.load(watch_list_dialog_item2);
    self.m_root_view:setAlign(kAlignCenter);
    self:addChild(self.m_root_view);
    local w,h = self.m_root_view:getSize();
    self:setSize(w,h);
    self.red_player = json.decode(room.red_info);
    self.black_player = json.decode(room.black_info);
--    self.user = self.red_player
    self:setUserInfo()

    self.m_btn = self.m_root_view:getChildByName("btn");
    self.m_btn:setOnClick(self,self.onClick);
    self.m_btn:setSrollOnClick();

    self.icon = self.m_btn:getChildByName("head")
    self.level = self.m_btn:getChildByName("level")
    self.name = self.m_btn:getChildByName("name")
    self.watch_num = self.m_btn:getChildByName("watch_num")
    self.room_tip = self.m_btn:getChildByName("room_type")

    self:updataItem()
end

function WatchListDialog2FriendWatchItem.setUserInfo(self)
    self.setUser = false
    self.intent = FriendsData.getInstance()

    if self.intent:isYourFollow(tonumber(self.red_player.uid)) ~= -1 or self.intent:isYourFriend(tonumber(self.red_player.uid)) ~= -1 then
        self.user = self.red_player
        self.setUser = true
        return
    end
    if self.intent:isYourFollow(tonumber(self.black_player.uid)) ~= -1 or self.intent:isYourFriend(tonumber(self.black_player.uid)) ~= -1 then
        if not self.setUser then
            self.user = self.black_player
            self.setUser = true
            return
        end
    end
    local red_charm = self.m_data.red_charm_value or 0
    local black_charm = self.m_data.black_charm_value or 0
    if red_charm >= black_charm then
        if not self.setUser then
            self.user = self.red_player
            self.setUser = true
        end
    else
        if not self.setUser then
            self.user = self.black_player
            self.setUser = true
        end
    end
end

function WatchListDialog2FriendWatchItem.updataItem(self)
    self:setHeadIcon()
    self.name:setText(lua_string_sub(self.user.user_name,6));
    self.level:setFile("common/icon/level_"..(10-UserInfo.getInstance():getDanGradingLevelByScore(self.user.score))..".png");
    self.watch_num:setText((self.m_data.ob_num or 0) .. "人观战");
    local w,h = self.watch_num:getSize()
end

function WatchListDialog2FriendWatchItem.setHeadIcon(self)
    self.m_user_head = new(Mask,UserInfo.DEFAULT_ICON[1],"hall/icon_frame_mask.png");
    self.m_user_head:setSize(self.icon:getSize());
    self.icon:addChild(self.m_user_head);
    local iconType = tonumber(self.user.icon);
    if iconType then
        if 0 ~= iconType then
            self.m_user_head:setFile(UserInfo.DEFAULT_ICON[iconType]  or UserInfo.DEFAULT_ICON[1]);
        end
    else
        if "" ~= self.user.icon then --兼容1.7.5之前的版本的头像为""时显示默认头像。
            self.m_user_head:setUrlImage(self.user.icon,UserInfo.DEFAULT_ICON[1]);
        end
    end
end

function WatchListDialog2FriendWatchItem.setWatchSceneHandler(self,handler)
    self.m_handler = handler;
    if self.m_handler and type(self.m_handler.mRoomLevelData) == "table" then
        self:updataWatchRoomLevel(self.m_handler.mRoomLevelData)
    end
end

function WatchListDialog2FriendWatchItem.onClick(self)
    if self.m_handler then
        WatchListDialog2.onWatchListItemClick(self.m_handler,self);
    end
end

function WatchListDialog2FriendWatchItem.getData(self)
	return self.m_data;
end

function WatchListDialog2FriendWatchItem.updataWatchRoomLevel(self,data)
    local level = 0
    local str = "联网房间"
    if not self.m_obtid or not data[self.m_obtid] then
        str = "联网房间"
    else
        str = data[self.m_obtid].roomName or "联网房间"
        level = data[self.m_obtid].level or 0;
    end 
    self.room_tip:setText(str)
    self.m_room_level = level;
end

function WatchListDialog2FriendWatchItem.dtor(self)
	
end