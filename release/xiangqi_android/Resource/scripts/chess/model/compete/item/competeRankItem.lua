require(VIEW_PATH .. "compete_rank_item")

CompeteRankItem = class(Node)

CompeteRankItem.ctor = function( self, data ,handler)
    self.mHandler = handler
	self:loadView()
	self:initControl()
	self:refresh(data)
    EventDispatcher.getInstance():register(Event.Call,self,self.onEvenCall)
end

CompeteRankItem.dtor = function( self )
	-- body
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onEvenCall)
    
    delete(self.m_up_user_info_dialog)
end

CompeteRankItem.loadView = function( self )
	self.root_view = SceneLoader.load(compete_rank_item)
	self.root_view:setAlign(kAlignCenter)
	self:addChild(self.root_view)
	self:setSize(self.root_view:getSize())
end

CompeteRankItem.initControl = function( self )
    self.mRankView = self.root_view:getChildByName("rank_view")
    self.mHeadView = self.root_view:getChildByName("btn_head")
    self.mRankIcon = self.mHeadView:getChildByName("rank_icon")
    self.mRankIcon:setVisible(false)
    self.mMyBg = self.root_view:getChildByName("my_bg")
    self.mMyBg:setVisible(false)
    self.mHeadBg = self.mHeadView:getChildByName("head_bg")
    self.mLevelIcon   = self.mHeadBg:getChildByName("level")
    self.mLevelIcon:setLevel(3)
    self.mMask   = new(Mask,UserInfo.DEFAULT_ICON[1], "common/background/head_mask_bg_46.png")
    self.mHeadBg:addChild(self.mMask)
    self.mMask:setSize(70,70);
    self.mName = self.root_view:getChildByName("txt_name")
    self.mLife = self.root_view:getChildByName("txt_life")
	self.mBtnPraise = self.root_view:getChildByName("btn_praise")
    self.mPraiseNumTxt = self.mBtnPraise:getChildByName("praise_num")
	self.mBtnTrack = self.root_view:getChildByName("btn_track")
	self.mBtnPraise:setOnClick(self, self.onPraiseClick)
	self.mBtnTrack:setOnClick(self, self.onTrackClick)
    self.mBtnPraise:setVisible(false)
    self.mBtnTrack:setVisible(false)
    self.mHeadView:setEventTouch(self,self.onEventTouch)
end

function CompeteRankItem:refresh(data)
    self.mData = data
    self.mUid = data.mid
    local match_score = tostring(data.match_score)
    self.mLife:setText( string.format("生命值:%s",match_score) ) 
    self.mRankView:removeAllChildren(true)
    local addView = nil
    if tonumber(data.rank) then
        if tonumber(data.rank) == 0 then
            addView = new(Text,"未上榜", width, height, align, fontName, 28, 80,80,80)
        else
            addView = new(Text,data.rank, width, height, align, fontName, 28, 80,80,80)
        end

        if tonumber(data.rank) <= 3 and tonumber(data.rank) >= 1 then
            self.mRankIcon:setFile( string.format("common/icon/rank_icon_%d.png",tonumber(data.rank)))
            self.mRankIcon:setVisible(true)
        else
            self.mRankIcon:setVisible(false)
        end
    else
        addView = new(Text,data.rank, width, height, align, fontName, 28, 80,80,80)
        self.mRankIcon:setVisible(false)
    end
    addView:setAlign(kAlignCenter)
    self.mRankView:addChild(addView)

    if tonumber(data.iconType) == -1 then
        self.mMask:setUrlImage(data.icon_url)
    else
        local icon = tonumber(data.iconType) or 1
        self.mMask:setFile(UserInfo.DEFAULT_ICON[icon] or UserInfo.DEFAULT_ICON[1])
    end
    self.mName:setText(data.mnick or "博雅象棋")
    self.mLevelIcon:setFile( string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevelByScore(data.score)))

    local praiseBtn = self.mBtnPraise
    local trackBtn = self.mBtnTrack
    if self.mUid == UserInfo.getInstance():getUid() then
--        self.mMyBg:setVisible(self.mUserBg)
        praiseBtn:setVisible(false)
        trackBtn:setVisible(false)
    else
--        self.mMyBg:setVisible(false)
    end

    local relation = FriendsData.getInstance():getUserStatus(self.mUid,false)
    if relation then
        self:setStatus(relation)
    end

    self:setPraiseStatus( tonumber(data.is_like) == 1 )
    self.mPraiseNum = tonumber(data.like_num) or 0
    self.mPraiseNumTxt:setText(self.mPraiseNum)
    if self.mUid == UserInfo.getInstance():getUid() then
        self.mBtnTrack:setVisible(false)
        self.mBtnPraise:setVisible(false)
    end
end

-- btn event ---------------------------------------
CompeteRankItem.onHeadClick = function( self )
	-- body
end

CompeteRankItem.onPraiseClick = function( self )
	-- body
    local datas = self.mHandler.datas or {}
    local params = {}
    params.param = {}
    params.param.match_id = datas.match_id
    params.param.target_mid = self.mUid
    params.param.rank_type = self.mRankType or ""
    HttpModule.getInstance():execute2(HttpModule.s_cmds.MatchLike,params,function(isSuccess,resultStr)
        if isSuccess then 
            local data = json.decode(resultStr)
            if not data or data.error then 
                local msg = data.error or "操作失败！"
                ChessToastManager.getInstance():showSingle(msg) 
                return
            end
            self.mPraiseNum = self.mPraiseNum + 1
            self.mPraiseNumTxt:setText(self.mPraiseNum)
            self:setPraiseStatus(true)
        end
    end)
end

CompeteRankItem.onPraiseClick2 = function( self )
	-- body
    local datas = self.mHandler.datas or {}
    local params = {}
    params.param = {}
    params.param.match_id = datas.match_id
    params.param.target_mid = self.mUid
    params.param.rank_type = self.mRankType or ""
    HttpModule.getInstance():execute2(HttpModule.s_cmds.MatchCancelLike,params,function(isSuccess,resultStr)
        if isSuccess then 
            local data = json.decode(resultStr)
            if not data or data.error then 
                local msg = data.error or "操作失败！"
                ChessToastManager.getInstance():showSingle(msg) 
                return
            end
            self.mPraiseNum = self.mPraiseNum - 1
            self.mPraiseNumTxt:setText(self.mPraiseNum)
            self:setPraiseStatus(false)
        end
    end)
end

function CompeteRankItem:setPraiseStatus(isPraise)
    if isPraise then
        self.mBtnPraise:getChildByName("praise_icon"):setFile("common/icon/praise_1.png")
        self.mPraiseNumTxt:setColor(215,75,45)
        self.mBtnPraise:setOnClick(self, self.onPraiseClick2)
    else
        self.mBtnPraise:getChildByName("praise_icon"):setFile("common/icon/praise_3.png")
        self.mPraiseNumTxt:setColor(135,100,95)
        self.mBtnPraise:setOnClick(self, self.onPraiseClick)
    end
end

-- 追踪
CompeteRankItem.onTrackClick = function( self )
	-- body
    local status = self.mStatus
    if not status then 
        ChessToastManager.getInstance():showSingle("该玩家未在对局中！")
        return 
    end
    local config = RoomConfig.getInstance():getMatchRoomConfig(status.matchId)
    if config then
        RoomProxy.getInstance():gotoMetierRoomByWatch(status.matchId,status.tid)
        self.mHandler:dismiss()
    end
end

--[Comment]
--更新界面
function CompeteRankItem.onEvenCall(self,cmd,...)
    if cmd == kFriend_UpdateStatus then
        local statusTab = unpack({...})
        for _,status in ipairs(statusTab) do
            if self.mUid == status.uid then
                self:setStatus(status)
            end
        end
    end
end

function CompeteRankItem:setStatus(status)
    if not self.mBtnTrack then return end
    self.mStatus = status
    local trackBtn = self.mBtnTrack
    if status.uid == UserInfo.getInstance():getUid() then
        return 
    end
    if status.matchId ~= "" and status.tid > 0 then
	    trackBtn:setOnClick(self, self.onTrackClick)
        trackBtn:setGray(false)
    else
	    trackBtn:setOnClick(self, function()
            ChessToastManager.getInstance():showSingle("该玩家未在对局中！")
        end)
        trackBtn:setGray(true)
    end
end

function CompeteRankItem:setHeadIconSize(w,h)
    self.mMask:setSize(w,h)
    self.mHeadBg:setSize(w,h)
end

function CompeteRankItem:setUseBg(flag)
    self.mUserBg = flag
--    self.mMyBg:setVisible(self.mMyBg:getVisible() and self.mUserBg)
end

function CompeteRankItem:setPreRank(flag,rank_type)
    self.mBtnTrack:setVisible(not flag)
    self.mBtnPraise:setVisible(flag)
    self.mRankType = rank_type or ""
    if self.mUid == UserInfo.getInstance():getUid() then
        self.mBtnTrack:setVisible(false)
        self.mBtnPraise:setVisible(false)
    end
end


function CompeteRankItem:onEventTouch(finger_action,x,y,drawing_id_first,drawing_id_current)
    if not self.mUid then return end
    if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
     
        if self.m_up_user_info_dialog and self.m_up_user_info_dialog:isShowing() then 
            self.m_up_user_info_dialog:dismiss();
            return 
        end
        delete(self.m_up_user_info_dialog)
        self.m_up_user_info_dialog = new(UserInfoDialog2);

        if UserInfo.getInstance():getUid() == self.mUid then
            self.m_up_user_info_dialog:setShowType(UserInfoDialog2.SHOW_TYPE.OTHER)
        else
            self.m_up_user_info_dialog:setShowType(UserInfoDialog2.SHOW_TYPE.UNION)
        end

        FriendsData.getInstance():sendCheckUserData(self.mUid)
        self.m_up_user_info_dialog:show(nil,self.mUid);
    end
end