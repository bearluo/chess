require(VIEW_PATH .. "relationship_dialog");
require(BASE_PATH.."chessDialogScene")

RelationshipDialog = class(ChessDialogScene,false)

function RelationshipDialog:ctor()
    super(self,relationship_dialog)

    self.mBlacklistBtn = self.m_root:getChildByName("title_bg"):getChildByName("blacklist_btn")
    self.mBlacklistBtn:setOnClick(self,self.showBlacklistDialog)

    local contentView = self.m_root:getChildByName("content_view")
    self.mListBg = contentView:getChildByName("list_bg")

    self.mFollowViewInviteFriendsView = self.mListBg:getChildByName("follow_view"):getChildByName("invite_friends_view")
    self.mFollowViewInviteFriendsView:getChildByName("btn"):setOnClick(self,self.shareGame)
    self.mListBg:getChildByName("follow_view"):getChildByName("invite_btn"):setOnClick(self,self.shareGame)
    self.mListBg:getChildByName("follow_view"):getChildByName("mask"):setLevel(2)
    self.mFollowViewInviteFriendsView:setVisible(false)
    self.mFansViewInviteFriendsView = self.mListBg:getChildByName("fans_view"):getChildByName("invite_friends_view")
    self.mFansViewInviteFriendsView:getChildByName("btn"):setOnClick(self,self.shareGame)
    self.mListBg:getChildByName("fans_view"):getChildByName("invite_btn"):setOnClick(self,self.shareGame)
    self.mListBg:getChildByName("fans_view"):getChildByName("mask"):setLevel(2)
    self.mFansViewInviteFriendsView:setVisible(false)


    local noRecentPlayerView = self.mListBg:getChildByName("recent_player_view"):getChildByName("no_recent_player_view")
    noRecentPlayerView:getChildByName("btn"):setOnClick(self,function()
        local roomConfig = RoomConfig.getInstance();
        local money = UserInfo.getInstance():getMoney();
        local gotoRoom = RoomProxy.getInstance():getMatchRoomByMoney(money);
        if not gotoRoom then 
            ChessToastManager.getInstance():showSingle("没有合适的场次");
        else
            StatisticsManager.getInstance():onCountQuickPlay(gotoRoom);
            RoomProxy.getInstance():gotoLevelRoom(gotoRoom.level);
        end
    end)
    self.mListBg:getChildByName("recent_player_view"):getChildByName("mask_1"):setLevel(2)
    self.mListBg:getChildByName("recent_player_view"):getChildByName("mask_2"):setLevel(2)

    self.mFollowBtn = contentView:getChildByName("follow_btn")
    self.mFollowNewBg = self.mFollowBtn:getChildByName("new_bg")
    self.mFollowNewBg:setVisible(false)
    self.mFansBtn = contentView:getChildByName("fans_btn")
    self.mFansNewBg = self.mFansBtn:getChildByName("new_bg")
    self.mFansNewBg:setVisible(false)
    self.mRecentPlayerBtn = contentView:getChildByName("recent_player_btn")
    self.mFollowBtn:setOnClick(self,self.showFollowView)
    self.mFansBtn:setOnClick(self,self.showFansView)
    self.mRecentPlayerBtn:setOnClick(self,self.showRecentPlayerView)
    self.setCheckStatus(self.mFollowBtn,false)
    self.setCheckStatus(self.mFansBtn,false)
    self.setCheckStatus(self.mRecentPlayerBtn,false)
    self.m_root:getChildByName("cancel_btn"):setOnClick(self,self.dismiss)
    EventDispatcher.getInstance():register(Event.Call,self,self.onNativeEvent)
    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
    self:initFollowView()
    self:initFansView()
end

function RelationshipDialog:dtor()
    delete(self.commonShareDialog)
    delete(self.m_add_friends_dialog)
    delete(self.mBlacklistDialog)
    delete(RelationshipDialog.m_up_user_info_dialog)
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeEvent)
    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpRequestsCallBack);
end

function RelationshipDialog:onNativeEvent(cmd,...)
    if cmd == kFriend_UpdateFollowList then
        local data = unpack({...})
        self.mFollowData = data or {}
        self:updateFollowViewData()
    elseif cmd == kFriend_UpdateFriendsList then
        local data = unpack({...})
        self.mFriendsData = data or {}
        -- 因为更新数据先发更新好友再发更新关注所以这里不更新界面
--        self:updateFollowViewData()
    elseif cmd == kFriend_UpdateFansList then
        local data = unpack({...})
        self.mFansData = data or {}
        self:updateFansViewData()
    end
end

RelationshipDialog.onHttpRequestsCallBack = function(self,command,...)
	Log.i("ChessController.onHttpRequestsCallBack");
    if not self.s_httpRequestsCallBackFuncMap then
        self.s_httpRequestsCallBackFuncMap = {
            [HttpModule.s_cmds.FriendsGetRecentWarUser] = self.onFriendsGetRecentWarUserResponse;
        }
    end
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self,...);
	end 
end

function RelationshipDialog:selectBtn(index)
    self.setCheckStatus(self.mFollowBtn,false)
    self.setCheckStatus(self.mFansBtn,false)
    self.setCheckStatus(self.mRecentPlayerBtn,false)
    self.mListBg:getChildByName("follow_view"):setVisible(false)
    self.mListBg:getChildByName("fans_view"):setVisible(false)
    self.mListBg:getChildByName("recent_player_view"):setVisible(false)
    if index == 1 then
        self.setCheckStatus(self.mFollowBtn,true)
        self.mListBg:getChildByName("follow_view"):setVisible(true)
        self.mFollowNewBg:setVisible(false)
    elseif index == 2 then
        self.setCheckStatus(self.mFansBtn,true)
        self.mListBg:getChildByName("fans_view"):setVisible(true)
        self.mFansNewBg:setVisible(false)
    else
        self.setCheckStatus(self.mRecentPlayerBtn,true)
        self.mListBg:getChildByName("recent_player_view"):setVisible(true)
    end
    -- 每次切换页面后 检测下数据更新
    self:onSendUpdataNum()
end

function RelationshipDialog.setCheckStatus(view,flag)
    if not view then return end
    local txt = view:getChildByName("title")
    if flag then
        view:setFile("common/button/table_chose_5.png")
        txt:setColor(95,15,15)
    else
        view:setFile("common/button/table_nor_5.png")
        txt:setColor(230,185,140)
    end
end

function RelationshipDialog.onSendUpdataNum(self)
    FriendsModuleController.getInstance():getFollowNum()
    FriendsModuleController.getInstance():getFansNum()
    FriendsModuleController.getInstance():getFriendsNum()
end

function RelationshipDialog:showFollowView()
    if not self.mFollowListView then
        local followView = self.mListBg:getChildByName("follow_view")
        local w,h = followView:getSize()
        self.mFollowListView = new(ListView,0, 0, w, h)
        self.mFollowListView:setDirection(kVertical)
        followView:addChild(self.mFollowListView)
    end

    local data = FriendsData.getInstance():getFrendsListData() or {}
    for i,uid in pairs(data) do
        if FriendsData.getInstance():isNewFriends(uid) == 1 then
            FriendsData.getInstance():setIsNewFriends(uid,0)
        end
    end
    
    local data = FriendsData.getInstance():getFollowListData() or {}
    for i,uid in pairs(data) do
        if FriendsData.getInstance():isNewFollow(uid) == 1 then
            FriendsData.getInstance():setIsNewFollow(uid,0)
        end
    end

    self:initFollowView()
    self:selectBtn(1)
end

function RelationshipDialog:initFollowView()
    self.mFriendsData = FriendsData.getInstance():getFrendsListData() or {}
    self.mFollowData = FriendsData.getInstance():getFollowListData() or {}
    self:updateFollowViewData()
end

function RelationshipDialog:updateFollowViewData()
    self.mFollowViewData = {}
    if self.mFriendsData then
        table.foreach(self.mFriendsData,function(i,v) 
            self.mFollowViewData[#self.mFollowViewData+1] = v
        end)
    end
    if self.mFollowData then
        table.foreach(self.mFollowData,function(i,v) 
            self.mFollowViewData[#self.mFollowViewData+1] = v
        end)
    end

    self.mListBg:getChildByName("follow_view"):getChildByName("num"):setText( string.format("关注人数:%d",#self.mFollowViewData))

    local friendsNum = 0;
    if self.mFriendsData~= nil then
        for i,uid in pairs(self.mFriendsData) do
            if FriendsData.getInstance():isNewFriends(uid) == 1 then
                friendsNum = friendsNum + 1;
            end
        end
    end
    --好友和粉丝后面要显示新增加的好友和粉丝的数量
    if friendsNum <= 0 then
        self.mFollowNewBg:setVisible(false);
    else
        self.mFollowNewBg:setVisible(true);
        self.mFollowNewBg:getChildByName("new_add_num"):setText("+"..friendsNum);--新增好友数量
    end
    self:updateFollowView()
end

function RelationshipDialog:updateFollowView()
    if not self.mFollowListView then return end
    local followView = self.mListBg:getChildByName("follow_view")
    if self.mFollowViewData and next(self.mFollowViewData) then
        table.sort(self.mFollowViewData,FriendsData.sort_cmp)
        self.mFollowListViewAdapter = new(CacheAdapter,RelationshipDialogFollowItem,self.mFollowViewData)
        self.mFollowViewInviteFriendsView:setVisible(false)
        followView:getChildByName("mask"):setVisible(true)
        followView:getChildByName("line"):setVisible(true)
        followView:getChildByName("invite_btn"):setVisible(true)
        self.mFollowListView:setVisible(true)
        self.mFollowListView:setAdapter(self.mFollowListViewAdapter)
    else
        self.mFollowViewInviteFriendsView:setVisible(true)
        followView:getChildByName("mask"):setVisible(false)
        followView:getChildByName("line"):setVisible(false)
        followView:getChildByName("invite_btn"):setVisible(false)
        self.mFollowListView:setVisible(false)
    end
end


function RelationshipDialog:showFansView()
    if not self.mFansListView then
        local fansView = self.mListBg:getChildByName("fans_view")
        local w,h = fansView:getSize()
        self.mFansListView = new(ListView,0, 0, w, h)
        self.mFansListView:setDirection(kVertical)
        fansView:addChild(self.mFansListView)
    end

    local data = FriendsData.getInstance():getFansListData() or {}
    for i,uid in pairs(data) do
        if FriendsData.getInstance():isNewFans(uid) == 1 then
            FriendsData.getInstance():setIsNewFans(uid,0)
        end
    end

    self:initFansView()
    self:selectBtn(2)
end

function RelationshipDialog:initFansView()
    self.mFansData = FriendsData.getInstance():getFansListData() or {}
    self:updateFansViewData()
end

function RelationshipDialog:updateFansViewData()
    self.mFansViewData = {}
    if self.mFansData then
        table.foreach(self.mFansData,function(i,v) 
            self.mFansViewData[#self.mFansViewData+1] = v
        end)
    end
    local fansNum = 0;
    if self.mFansData~= nil then
        for i,uid in pairs(self.mFansData) do
            if FriendsData.getInstance():isNewFans(uid) == 1 then
                fansNum = fansNum + 1;
            end
        end
    end
    --好友和粉丝后面要显示新增加的好友和粉丝的数量
    if fansNum <= 0 then
        self.mFansNewBg:setVisible(false);
    else
        self.mFansNewBg:setVisible(true);
        self.mFansNewBg:getChildByName("new_add_num"):setText("+"..fansNum);--新增好友数量
    end

    self.mListBg:getChildByName("fans_view"):getChildByName("num"):setText( string.format("粉丝人数:%d",#self.mFansData))
    self:updateFansView()
end

function RelationshipDialog:updateFansView()
    if not self.mFansListView then return end
    local fansView = self.mListBg:getChildByName("fans_view")
    if self.mFansViewData and next(self.mFansViewData) then
        self.mFansListViewAdapter = new(CacheAdapter,RelationshipDialogFansItem,self.mFansViewData)
        self.mFansViewInviteFriendsView:setVisible(false)
        fansView:getChildByName("mask"):setVisible(true)
        fansView:getChildByName("line"):setVisible(true)
        fansView:getChildByName("invite_btn"):setVisible(true)
        self.mFansListView:setVisible(true)
        self.mFansListView:setAdapter(self.mFansListViewAdapter)
    else
        self.mFansViewInviteFriendsView:setVisible(true)
        fansView:getChildByName("mask"):setVisible(false)
        fansView:getChildByName("line"):setVisible(false)
        fansView:getChildByName("invite_btn"):setVisible(false)
        self.mFansListView:setVisible(false)
    end
end

function RelationshipDialog:showRecentPlayerView()
    if not self.mRecentPlayerListView then
        local recentPlayerView = self.mListBg:getChildByName("recent_player_view")
        local w,h = recentPlayerView:getSize()
        self.mRecentPlayerListView = new(SlidingLoadView,0, 0, w, h)
        self.mRecentPlayerListView:setOnLoad(self,function(self)
            self:requestFriendsGetRecentWarUser()
        end)
        self.mRecentPlayerListView:setNoDataTip("没有更多数据");
        recentPlayerView:addChild(self.mRecentPlayerListView)
    end
    self.requestFriendsGetRecentWarUserIndex = 0
    self.sendFriendsGetRecentWarUserIng = false
    self.sendFriendsGetRecentWarUserNoMore = false
    self.mRecentPlayerListView:reset()
    self.mRecentPlayerListView:loadView();
    self:selectBtn(3)
end

RelationshipDialog.requestFriendsGetRecentWarUser = function(self)
    if self.sendFriendsGetRecentWarUserIng or self.sendFriendsGetRecentWarUserNoMore then return end;
    self.sendFriendsGetRecentWarUserIng = true;
    self.requestFriendsGetRecentWarUserIndex = self.requestFriendsGetRecentWarUserIndex or 0;
    local params = {};
    params.mid = UserInfo.getInstance():getUid();
	params.offset = self.requestFriendsGetRecentWarUserIndex;
	params.limit = 10;
    HttpModule.getInstance():execute(HttpModule.s_cmds.FriendsGetRecentWarUser,params);
end

RelationshipDialog.onFriendsGetRecentWarUserResponse = function(self,isSuccess,message)
    if not self.sendFriendsGetRecentWarUserIng then return end
    self.sendFriendsGetRecentWarUserIng = false
    if not isSuccess or (type(message) == "table" and message.data:get_value() == nil ) then
        if type(message) == "table" and message.flag:get_value() == 10009 then
            self:addRecentlyPlayerItem({},true);
            self.sendFriendsGetRecentWarUserNoMore = true;
            return ;
        end
        return ;
    end
    
    local tab = json.analyzeJsonNode(message.data);
    local list = tab.list;
    if type(list) ~= "table" or #list == 0 then
        if tab.total ~= 0 then
            self:addRecentlyPlayerItem({},true);
        end
        self.sendFriendsGetRecentWarUserNoMore = true;
        return ;
    end
    
    self.requestFriendsGetRecentWarUserIndex = self.requestFriendsGetRecentWarUserIndex + #list;

    self:addRecentlyPlayerItem(list,false);
end

RelationshipDialog.addRecentlyPlayerItem = function(self,datas,isNoData)
--    for i=1,3 do 
    for i,v in ipairs(datas) do
        if tonumber(v.mid) then
            local item = new(RelationshipDialogRecentPlayerItem,tonumber(v.mid))
            self.mRecentPlayerListView:addChild(item);
        end
    end
--    end
    self.mRecentPlayerListView:loadEnd(isNoData);
    if next(self.mRecentPlayerListView:getChildren()) then
        self.mRecentPlayerListView:setVisible(true)
        self.mListBg:getChildByName("recent_player_view"):getChildByName("mask_1"):setVisible(true)
        self.mListBg:getChildByName("recent_player_view"):getChildByName("mask_2"):setVisible(true)
        self.mListBg:getChildByName("recent_player_view"):getChildByName("no_recent_player_view"):setVisible(false)
    else
        self.mRecentPlayerListView:setVisible(false)
        self.mListBg:getChildByName("recent_player_view"):getChildByName("mask_1"):setVisible(false)
        self.mListBg:getChildByName("recent_player_view"):getChildByName("mask_2"):setVisible(false)
        self.mListBg:getChildByName("recent_player_view"):getChildByName("no_recent_player_view"):setVisible(true)
    end
end


function RelationshipDialog:shareGame()
    if not self.m_add_friends_dialog  then
        self.m_add_friends_dialog = new(AddFriendDialog,false);
        self.m_add_friends_dialog:setMaskDialog(true)
    end
    self.m_add_friends_dialog:show()
end

require(DIALOG_PATH .. "blacklistDialog")
function RelationshipDialog:showBlacklistDialog()
    if not self.mBlacklistDialog then
        self.mBlacklistDialog = new(BlacklistDialog)
        self.mBlacklistDialog:setMaskDialog(true)
    end
    self.mBlacklistDialog:show()
end

function RelationshipDialog.showUserInfoDialog(uid)
    uid = tonumber(uid)
    if not uid then return end
    delete(RelationshipDialog.m_up_user_info_dialog)
    RelationshipDialog.m_up_user_info_dialog = new(UserInfoDialog2);

    if UserInfo.getInstance():getUid() == uid then
        RelationshipDialog.m_up_user_info_dialog:setShowType(UserInfoDialog2.SHOW_TYPE.OTHER)
    else
        RelationshipDialog.m_up_user_info_dialog:setShowType(UserInfoDialog2.SHOW_TYPE.UNION)
    end

    FriendsData.getInstance():sendCheckUserData(uid)
    RelationshipDialog.m_up_user_info_dialog:show(nil,uid);
end

--function RelationshipDialog.registerRefreshUserStatus(uid)

--end

--function RelationshipDialog.unregisterRefreshUserStatus(uid)

--end

--function RelationshipDialog.startRefreshUserStatus()
--    RelationshipDialog.s_refreshAnim = AnimFactory.createAnimInt(kAnimNormal,0,1,5000, -1)

--end

-------------
require(VIEW_PATH .. "relationship_dialog_follow_item")
RelationshipDialogFollowItem = class(Node)

function RelationshipDialogFollowItem:ctor(uid)
    self.m_root = SceneLoader.load(relationship_dialog_follow_item)
    self:addChild(self.m_root)
    self:setSize(self.m_root:getSize())
    self.mHeadBg = self.m_root:getChildByName("head_bg")
    self.mName = self.m_root:getChildByName("name")
    self.mLevel = self.m_root:getChildByName("level")
    self.mScore = self.m_root:getChildByName("score")
    self.mPk = self.m_root:getChildByName("pk")
    self.mPkTxt = self.mPk:getChildByName("txt")
    self.mRelationshipView = self.m_root:getChildByName("relationship_view")
    self.mRelationshipViewIcon = self.mRelationshipView:getChildByName("icon")
    self.mRelationshipViewStatusTxt = self.mRelationshipView:getChildByName("status_txt")
    self.mActionBtn = self.m_root:getChildByName("action_btn")
    self.mHead = new(Mask,"common/icon/default_head.png","common/background/head_mask_bg_86.png")
    self.mHead:setSize(90,90)
    self.mHead:setAlign(kAlignCenter)
    self.mHeadBg:addChild(self.mHead)
    self:reset()
    self:setUid(uid)
    EventDispatcher.getInstance():register(Event.Call,self,self.onNativeEvent)
    self:setEventTouch(self,self.onEventTouch)
end

function RelationshipDialogFollowItem:dtor()
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeEvent)
end

function RelationshipDialogFollowItem:onNativeEvent(cmd,...)
    if cmd == kFriend_UpdateUserData then
        local data = unpack({...})
        if not self.mUid then return end
        for _,userData in ipairs(data) do
            if self.mUid == userData.mid then
                self:setUserData(userData)
            end
        end
    elseif cmd == kFriend_UpdateStatus then
        if not self.mUid then return end
        local statusTab = unpack({...})
        for _,status in ipairs(statusTab) do
            if self.mUid == status.uid then
                self:setUserStatus(status)
            end
        end
    elseif cmd == kFriend_UpdateUserCombat then
        if not self.mUid then return end
        local statusTab = unpack({...})
        for _,status in ipairs(statusTab) do
            if self.mUid == status.target_mid then
                self:setUserComcat(status)
            end
        end
    end
end

function RelationshipDialogFollowItem:reset()
    self.mPk:setVisible(false)
    self.mRelationshipView:setVisible(false)
    self.mActionBtn:setVisible(false)
    self.mScore:setText("")
    self.mLevel:setVisible(false)
    self.mName:setText("")
    self.mHead:setFile("common/icon/default_head.png")
    self.mUid = nil
end

function RelationshipDialogFollowItem:setUid(uid)
    if not tonumber(uid) then return end
    self.mUid = tonumber(uid)
    FriendsData.getInstance():sendCheckUserStatus(self.mUid)
    local data = FriendsData.getInstance():getUserData(self.mUid)
    if data then
        self:setUserData(data)
    else
        self.mName:setText(self.mUid)
    end

    local status = FriendsData.getInstance():getUserStatus(self.mUid)
    if status then
        self.mHead:setGray(false)
        self:setUserStatus(status)
    else
        self.mHead:setGray(true)
    end
end

function RelationshipDialogFollowItem:setUserComcat(data)
    if not data then return end
    local str = string.format("%d胜%d负%d和",data.wintimes,data.losetimes,data.drawtimes)
    self.mPkTxt:setText(str)
end

function RelationshipDialogFollowItem:setUserData(data)
    if not data then return end
    self:setHead(data)
    local length = string.lenutf8(data.mnick)
    if length <= 4 then
        self.mName:setText(data.mnick)
    else
        local prefix = string.subutf8(data.mnick,1,4)
        self.mName:setText(prefix .. "...")
    end
end

function RelationshipDialogFollowItem:setHead(data)
    if type(data) ~= "table" then return end
    if tonumber(data.iconType) == -1 then
        self.mHead:setUrlImage(data.icon_url,"common/icon/default_head.png")
    else
        local icon = tonumber(data.iconType) or 1
        self.mHead:setFile(UserInfo.DEFAULT_ICON[icon] or UserInfo.DEFAULT_ICON[1])
    end
    self.mLevel:setFile( string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevelByScore(data.score)))
    self.mLevel:setVisible(true)
    self.mScore:setText( string.format("积分:%d",data.score))
end

function RelationshipDialogFollowItem:setUserStatus(data)
    if not data then return end
    if data.hallid == 0 then
        self.mHead:setGray(true)
        self.mRelationshipViewStatusTxt:setText( "离线" )
        self.mRelationshipViewStatusTxt:setColor(80,80,80)
        self.mActionBtn:setVisible(false)
    else
        self.mHead:setGray(false)
        if RoomConfig.getInstance():isPlaying(data) then
            local strname = RoomConfig.getInstance():onGetScreenings(self.status);
            self.mRelationshipViewStatusTxt:setText( strname or "游戏中" )
            self.mRelationshipViewStatusTxt:setColor(115,145,55)
            self.mActionBtn:setVisible(true)
            self.mActionBtn:getChildByName("txt"):setText("观战")
            self.mActionBtn:getChildByName("txt"):setColor(115,65,35)
            self.mActionBtn:setFile("common/button/button_1.png")
            self.mActionBtn:setOnClick(self,function()
                --观战
                local isSuccess,msg = RoomProxy.getInstance():followUserByStatus(data)
                if not isSuccess then
                    ChessToastManager.getInstance():showSingle(msg)
                end
            end)
        else
            self.mRelationshipViewStatusTxt:setText("闲逛中")
            self.mRelationshipViewStatusTxt:setColor(115,145,55)
            if data.relation == 3 then
                self.mActionBtn:setVisible(true)
                self.mActionBtn:getChildByName("txt"):setText("挑战")
                self.mActionBtn:getChildByName("txt"):setColor(95,15,15)
                self.mActionBtn:setFile("common/button/button_2.png")
                self.mActionBtn:setOnClick(self,self.challenge)
            else
                self.mActionBtn:setVisible(false)
            end
        end
    end

-- relation, =0,陌生人,=1粉丝，=2关注，=3好友
    if data.relation == 3 then
        self.mRelationshipViewIcon:setFile("common/icon/friends_icon.png")
        self.mRelationshipView:setVisible(true)
        local comcat = FriendsData.getInstance():getUserCombat(self.mUid)
        if comcat then
            self.mPk:setVisible(true)
            self:setUserComcat(comcat)
        else
            self.mPk:setVisible(false)
        end
    elseif data.relation == 2 then
        self.mRelationshipViewIcon:setFile("common/icon/follow_icon.png")
        self.mRelationshipView:setVisible(true)
    elseif data.relation == 1 then
        self.mRelationshipView:setVisible(false)
    elseif data.relation == 0 then
        self.mRelationshipView:setVisible(false)
    else
        self.mRelationshipView:setVisible(false)
    end

end

function RelationshipDialogFollowItem:challenge()
    if not self.mUid then return end
    local isCanCreate = RoomProxy.getInstance():canAccessRoom(RoomConfig.ROOM_TYPE_FRIEND_ROOM,UserInfo.getInstance():getMoney());
    if not isCanCreate then
        ChessToastManager.getInstance():show("金币不足或超出上限，发起挑战失败", 1000);
        return;
    end
    UserInfo.getInstance():setTargetUid(self.mUid);
    local post_data = {};
    post_data.uid = tonumber(UserInfo.getInstance():getUid());
    post_data.level = 320;
    OnlineSocketManager.getHallInstance():sendMsg(CLIENT_HALL_CREATE_FRIENDROOM,post_data,nil,1);
end


function RelationshipDialogFollowItem:follow()
    if not self.mUid then return end
    local info = {};
    info.uid = UserInfo.getInstance():getUid();
    info.target_uid = self.mUid;
    info.op = 1;
    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_ADD_FLLOW,info);
end

function RelationshipDialogFollowItem:onEventTouch(finger_action,x,y,drawing_id_first,drawing_id_current)
    if not self.mUid then return end
    if kFingerDown == finger_action then
        self.mDownX,self.mDownY = x,y
    end

    if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
        if self.mDownX and self.mDownY and math.abs(self.mDownY - y ) < 20 then
            StateMachine.getInstance():pushState(States.FriendsInfo,StateMachine.STYPE_CUSTOM_WAIT,nil,tonumber(self.mUid));
        end
--        RelationshipDialog.showUserInfoDialog(self.mUid)
    end
end
-------------

RelationshipDialogFansItem = class(RelationshipDialogFollowItem)


function RelationshipDialogFansItem:setUid(uid)
    self.super.setUid(self,uid)
    if not tonumber(uid) then return end
    self.mActionBtn:setVisible(true)
    self.mActionBtn:getChildByName("txt"):setText("关注")
    self.mActionBtn:getChildByName("txt"):setColor(115,65,35)
    self.mActionBtn:setFile("common/button/button_1.png")
    self.mActionBtn:setOnClick(self,self.follow)
end

function RelationshipDialogFansItem:setUserStatus(data)
    if not data then return end
    if data.hallid == 0 then
        self.mHead:setGray(true)
    else
        self.mHead:setGray(false)
    end
    self.mRelationshipView:setVisible(false)
end

RelationshipDialogRecentPlayerItem = class(RelationshipDialogFollowItem)


function RelationshipDialogRecentPlayerItem:setUid(uid)
    self.super.setUid(self,uid)
    if not tonumber(uid) then return end
end

function RelationshipDialogRecentPlayerItem:setUserStatus(data)
    if not data then return end
    if data.hallid == 0 then
        self.mHead:setGray(true)
    else
        self.mHead:setGray(false)
    end
    self.mRelationshipView:setVisible(false)
end