require(VIEW_PATH .. "watch_view_prefabs")
require(DIALOG_PATH .. "watchListDialog2")
WatchViewPrefabs = class(Node)

function WatchViewPrefabs:ctor()
    self.mRoot = SceneLoader.load(watch_view_prefabs)
    local w,h = self.mRoot:getSize()
    local fw,fh = self.mRoot:getFillParent()
    self:setSize(w,h)
    self:setFillParent(fw,fh)
    self:addChild(self.mRoot)

    self.mRefreshFriendsTime = 0
    self.mWatchItems = {}
    self.mRoot:setClip(0, 0, self.mRoot:getSize());
    self.m_watch_item_view = self.mRoot:getChildByName("watch_view");
    self.m_watch_item_view:setClip(0, 44, self.m_watch_item_view:getSize());

    self.m_show_watch_list_btn = self.mRoot:getChildByName("show_watch_list_btn");
    self.m_show_watch_list_btn:setOnClick(self,self.showDialog)
end

function WatchViewPrefabs:dtor()
end

function WatchViewPrefabs:showDialog()
--    StateMachine.getInstance():pushState(States.Watch,StateMachine.STYPE_CUSTOM_WAIT)
    StatisticsManager.getInstance():onCountToUM(HALL_MODEL_WATCH_BTN);
    self:getWatchDialog():show()
end

function WatchViewPrefabs:pause()
    if self.mRegister then 
        self.mRegister = false
        TimerHelper.unregisterSecondEvent(self,self.refreshFriendsGame)
        OnlineSocketManagerProcesser.getInstance():unregister(FRIEND_CMD_GET_FRIEND_OB_LIST,self,self.onRecvServerFriendsWatchList)
        OnlineSocketManagerProcesser.getInstance():unregister(OB_CMD_GET_CHARM_OB_LIST,self,self.onRecvServerCharmWatchList)
    end
    if self.mWatchDialog and self.mWatchDialog:isShowing() then
        self.mWatchDialog:dismiss()
    end
end

function WatchViewPrefabs:resume()
    
    if not self.mRegister then 
        self.mRegister = true
        TimerHelper.registerSecondEvent(self,self.refreshFriendsGame)
        OnlineSocketManagerProcesser.getInstance():register(FRIEND_CMD_GET_FRIEND_OB_LIST,self,self.onRecvServerFriendsWatchList)
        OnlineSocketManagerProcesser.getInstance():register(OB_CMD_GET_CHARM_OB_LIST,self,self.onRecvServerCharmWatchList)
    end
end

function WatchViewPrefabs:getWatchDialog()
    if not self.mWatchDialog then
        self.mWatchDialog = new(WatchListDialog2)
        self.mWatchDialog:setUpdateFollowListFunc(self,self.updateItemViewData)
    end
    return self.mWatchDialog
end

function WatchViewPrefabs:refreshFriendsGame()
    if UserInfo.getInstance():isLogin() and self.mRefreshFriendsTime and os.time() - self.mRefreshFriendsTime > 60 then
        self.mRefreshFriendsTime = os.time() -- 防止快速更新
        self:onRefreshFriendsGame()
    end
end

function WatchViewPrefabs:onRefreshFriendsGame()
    self.kick_map = {}
    local data = UserInfo.getInstance():getUid();
    self.mFriendCmdIndex = 0
    self.mOBCmdIndex = -1 -- 停止接收上一个魅力榜的消息
    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_GET_FRIEND_OB_LIST,data);
end

function WatchViewPrefabs:onRefreshCharmGame()
    local data = UserInfo.getInstance():getUid();
    self.mOBCmdIndex = 0
    OnlineSocketManager.getHallInstance():sendMsg(OB_CMD_GET_CHARM_OB_LIST,data);
end

function WatchViewPrefabs:onRecvServerFriendsWatchList(data)
    if data and self.mFriendCmdIndex == data.curr_page then
        self.mFriendCmdIndex = self.mFriendCmdIndex + 1
        if data.curr_page == 0 then
            self.mFriendsWatchListIndex = 0
            self.cache_follow_room_data = {}
        end

        if data.curr_page == self.mFriendsWatchListIndex then
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
            self.mFriendsWatchListIndex = self.mFriendsWatchListIndex + 1
        end

        if data.total_page == data.curr_page+1 or data.total_page == 0 then
            self.mFriendCmdIndex = -1
            local num = #self.cache_follow_room_data or 0

            if num > 5 then
                local subTab = {}
                for i=1,5 do
                    subTab[i] = self.cache_follow_room_data[i]
                end
                self.cache_follow_room_data = subTab;
                num = 5
            end

            if #self.cache_follow_room_data < 5 then
                self:onRefreshCharmGame()
            else
                self:updateItemViewData(self.cache_follow_room_data)
            end
        end
    end
end

function WatchViewPrefabs:onRecvServerCharmWatchList(data)
    if data and self.mOBCmdIndex == data.curr_page then
        self.mOBCmdIndex = self.mOBCmdIndex + 1
        if data.curr_page == 0 then
            self.mCharmWatchListIndex = 0
        end

        if data.curr_page == self.mCharmWatchListIndex then
            local temp_tab = {};
            for k,v in pairs((data.watch_items or {})) do   
                if v and self.kick_map[v.tid] ~= 1 then
                    self.kick_map[v.tid] = 1;
                    v.sort_key = 0
                    table.insert(temp_tab,v);
                end
            end

            if temp_tab and self.cache_follow_room_data then 
                local num = table.maxn(self.cache_follow_room_data)
                for i,v in ipairs(temp_tab) do
                    if not v then break end
                    if num >= 5 then break end
                    table.insert(self.cache_follow_room_data,v);
                    num = num + 1
                end
            end
            self.mCharmWatchListIndex = self.mCharmWatchListIndex + 1
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
            self:updateItemViewData(self.cache_follow_room_data)
            self.cache_follow_room_data = {};
        end
    end
end

function WatchViewPrefabs:updateItemViewData(data)
    if not data then return end
    self.mFollowRoomData = data
    self:updateItemView()
    self.mRefreshFriendsTime = os.time() -- 刷新界面更新时间
end

function WatchViewPrefabs:updateItemView()
    if not self.mFollowRoomData then return end
    local itemCount = 5;
    for i=1,itemCount do
        local data = self.mFollowRoomData[i]
        if not self.mWatchItems[i] then
            self.mWatchItems[i] = new(WatchViewPrefabsItem)
            self.mWatchItems[i]:setPos(0,(i-1) * select(2,self.mWatchItems[i]:getSize()))
            self.m_watch_item_view:addChild(self.mWatchItems[i])
        end
        self.mWatchItems[i]:setRoomData(data)
    end
end



WatchViewPrefabsItem = class(Node);

function WatchViewPrefabsItem:ctor()
    self:setSize(100,96)
end

function WatchViewPrefabsItem:setRoomData(data)
    if not data then 
        self:setVisible(false)
        return 
    end
    self:setVisible(true)
    local user = nil
    local red_player = json.decode(data.red_info);
    local black_player = json.decode(data.black_info);
    local frendsData = FriendsData.getInstance()
    
    if frendsData:isYourFollow(tonumber(red_player.uid)) ~= -1 or frendsData:isYourFriend(tonumber(red_player.uid)) ~= -1 then
        user = red_player
    end

    if not user and (frendsData:isYourFollow(tonumber(black_player.uid)) ~= -1 or frendsData:isYourFriend(tonumber(black_player.uid)) ~= -1) then
        user = black_player
    end
    
    local red_charm = data.red_charm_value or 0
    local black_charm = data.black_charm_value or 0
    if not user and red_charm >= black_charm then
        user = red_player
    elseif not user then
        user = black_player
    end

    self:setHeadIcon(user)
end

function WatchViewPrefabsItem:setHeadIcon(user)
    if not user then return end
    delete(self.m_user_head)
    self.m_user_head = new(Mask,UserInfo.DEFAULT_ICON[1],"hall/icon_frame_mask.png");
    self.m_user_head:setSize(80,80);
    self.m_user_head:setAlign(kAlignCenter)
    self:addChild(self.m_user_head)
    local iconType = tonumber(user.icon);
    if iconType then
        if 0 ~= iconType then
            self.m_user_head:setFile(UserInfo.DEFAULT_ICON[iconType]  or UserInfo.DEFAULT_ICON[1]);
        else
            self.m_user_head:setFile(UserInfo.DEFAULT_ICON[1]);
        end
    else
        if "" ~= user.icon then --兼容1.7.5之前的版本的头像为""时显示默认头像。
            self.m_user_head:setUrlImage(user.icon,UserInfo.DEFAULT_ICON[1]);
        else
            self.m_user_head:setFile(UserInfo.DEFAULT_ICON[1]);
        end
    end
end

function WatchViewPrefabsItem.dtor(self)
	
end