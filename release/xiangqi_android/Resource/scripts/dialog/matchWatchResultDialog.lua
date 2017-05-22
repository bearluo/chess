require(VIEW_PATH .. "match_watch_result_dialog")

MatchWatchResultDialog = class(ChessDialogScene,false)

function MatchWatchResultDialog:ctor()
    super(self,match_watch_result_dialog)
    
    self.mResultIconView = self.m_root:getChildByName("result_icon_view")
    self.mTitle = self.m_root:getChildByName("title")
    self.mMyResultBg    = self.m_root:getChildByName("my_result_bg")
    self.mOtherResultBg = self.m_root:getChildByName("other_result_bg")
    self.mShareBtn  = self.m_root:getChildByName("share_btn")
    self.mShareBtn:setOnClick(self,self.onShareBtnClick)
    self.mCloseBtn  = self.m_root:getChildByName("close_btn")
    self.mCloseBtn:setOnClick(self,self.cancel)
    self.mSaveChessBtn  = self.m_root:getChildByName("save_chess_btn")
    self.mSaveChessBtn:setOnClick(self,self.onSaveMychess)
    self.mContinueWatchBtn = self.m_root:getChildByName("continue_watch_btn")
    self.mContinueWatchBtn:setOnClick(self,self.onContinueWatchBtnClick)
    self:setNeedBackEvent(false)
    local result_icon   = self.mOtherResultBg:getChildByName("result_icon")
    result_icon:setTransparency(0.5)
    local result_icon   = self.mMyResultBg:getChildByName("result_icon")
    result_icon:setTransparency(0.5)
end

function MatchWatchResultDialog:dtor()
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeEvent)
    self:stopRefreshUserStatus()
end

function MatchWatchResultDialog:show()
    self.super.show(self)
    EventDispatcher.getInstance():register(Event.Call,self,self.onNativeEvent)
    self:startRefreshUserStatus()
    self:resetSaveChess()
    self:resetRelation()
end

function MatchWatchResultDialog:dismiss()
    self.super.dismiss(self)
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeEvent)
    self:stopRefreshUserStatus()
end

function MatchWatchResultDialog:resetRelation()
    local relationBtn = self.mMyResultBg:getChildByName("relation_btn")
    local statusTxt   = self.mMyResultBg:getChildByName("status_txt")
    relationBtn:setVisible(false)
    statusTxt:setVisible(false)

    local relationBtn = self.mOtherResultBg:getChildByName("relation_btn")
    local statusTxt   = self.mOtherResultBg:getChildByName("status_txt")
    relationBtn:setVisible(false)
    statusTxt:setVisible(false)
end

function MatchWatchResultDialog:setGotoWatchEvent(obj,func)
    self.mGotoWatchEventObj = obj
    self.mGotoWatchEventFunc = func
end
--  =0,陌生人,=1粉丝，=2关注，=3好友
--[[
        info.items[i] = {};
        info.items[i].uid = self.m_socket:readInt(packetId,0);
        info.items[i].relation = self.m_socket:readByte(packetId,0); -- =0,陌生人,=1粉丝，=2关注，=3好友
        info.items[i].last_time = self.m_socket:readInt(packetId,0); --最后登录时间, <0为超出最大保存时间
        info.items[i].hallid = self.m_socket:readInt(packetId,0); -- >0标识用户在线
        info.items[i].tid = self.m_socket:readInt(packetId,0); -- >0标识用户在下棋=
        info.items[i].level = self.m_socket:readInt(packetId,0); -- 下棋所在的场次
        info.items[i].matchId = self.m_socket:readString(packetId,""); -- 下棋所在的场次
]]--
function MatchWatchResultDialog:setMyRelation(status)
    local relationBtn = self.mMyResultBg:getChildByName("relation_btn")
    local statusTxt   = self.mMyResultBg:getChildByName("status_txt")
    relationBtn:setVisible(true)
    statusTxt:setVisible(true)
    relationBtn:setPickable(true)
    relationBtn:setGray(false)

    relationBtn:getChildByName("follow_room"):setVisible(true)
    relationBtn:setOnClick(self,function()
        if status.matchId ~= "" and status.tid > 0 then
            if type(self.mGotoWatchEventFunc) == "function" then
                self.mGotoWatchEventFunc(self.mGotoWatchEventObj,status.matchId,status.tid)
            end
        end
    end)
    if status.matchId ~= "" and status.tid > 0 then
        relationBtn:setGray(false)
    else
	    relationBtn:setOnClick(self, function()
            ChessToastManager.getInstance():showSingle("该玩家未在对局中！")
        end)
        relationBtn:setGray(true)
    end

    if status.matchId ~= "" and status.tid > 0 then
        statusTxt:setText("对局中")
    else
        statusTxt:setText("等待中")
    end
end

function MatchWatchResultDialog:setOtherRelation(status)
    local relationBtn = self.mOtherResultBg:getChildByName("relation_btn")
    local statusTxt   = self.mOtherResultBg:getChildByName("status_txt")
    relationBtn:setVisible(true)
    statusTxt:setVisible(true)
    relationBtn:setPickable(true)
    relationBtn:setGray(false)

    relationBtn:getChildByName("follow_room"):setVisible(true)
    relationBtn:setOnClick(self,function()
        if status.matchId ~= "" and status.tid > 0 then
            if type(self.mGotoWatchEventFunc) == "function" then
                self.mGotoWatchEventFunc(self.mGotoWatchEventObj,status.matchId,status.tid)
            end
        end
    end)
    if status.matchId ~= "" and status.tid > 0 then
        relationBtn:setGray(false)
    else
	    relationBtn:setOnClick(self, function()
            ChessToastManager.getInstance():showSingle("该玩家未在对局中！")
        end)
        relationBtn:setGray(true)
    end

    if status.matchId ~= "" and status.tid > 0 then
        statusTxt:setText("对局中")
    else
        statusTxt:setText("等待中")
    end
end

function MatchWatchResultDialog:saveChessSuccess()
    self.mSaveChessBtn:setFile("dialog/has_save.png");
    self.mSaveChessBtn:setPickable(false);
end

function MatchWatchResultDialog:resetSaveChess()
    self.mSaveChessBtn:setFile("dialog/save_mychess.png");
    self.mSaveChessBtn:setPickable(true);
end

function MatchWatchResultDialog:onShareBtnClick()
    if self.mShareBtnClickTime and os.time() - self.mShareBtnClickTime < 1 then return end
    if type(self.mShareBtnEventFunc) == "function" then
        self.mShareBtnEventFunc(self.mShareBtnEventObj)
    end
    self.mShareBtnClickTime = os.time()
end

function MatchWatchResultDialog:cancel()
    if self.mCancelClickTime and os.time() - self.mCancelClickTime < 1 then return end
    if type(self.mCancelEventFunc) == "function" then
        self.mCancelEventFunc(self.mCancelEventObj)
    end
    self.mCancelClickTime = os.time()
end

function MatchWatchResultDialog:onSaveMychess()
    if self.mSaveChessEventClickTime and os.time() - self.mSaveChessEventClickTime < 1 then return end
    if type(self.mSaveChessEventFunc) == "function" then
        self.mSaveChessEventFunc(self.mSaveChessEventObj)
    end
    self.mSaveChessEventClickTime = os.time()
end

function MatchWatchResultDialog:onContinueWatchBtnClick()
    if self.mContinueWatchBtnClickTime and os.time() - self.mContinueWatchBtnClickTime < 1 then return end
    if type(self.mContinueWatchBtnEventFunc) == "function" then
        self.mContinueWatchBtnEventFunc(self.mContinueWatchBtnEventObj)
    end
    self.mContinueWatchBtnClickTime = os.time()
end

function MatchWatchResultDialog:setContinueWatchBtnEvent(obj,func)
    self.mContinueWatchBtnEventObj = obj;
    self.mContinueWatchBtnEventFunc = func;
end

function MatchWatchResultDialog:setSaveChessEvent(obj,func)
    self.mSaveChessEventObj = obj;
    self.mSaveChessEventFunc = func;
end

function MatchWatchResultDialog:setCancelEvent(obj,func)
    self.mCancelEventObj = obj;
    self.mCancelEventFunc = func;
end

function MatchWatchResultDialog:setShareBtnClick(obj,func)
    self.mShareBtnEventObj = obj;
    self.mShareBtnEventFunc = func;
end

function MatchWatchResultDialog:onNativeEvent(cmd,...)
    if cmd == kFriend_UpdateUserData then
        local data = unpack({...})
        for _,userData in ipairs(data) do
            if self.mMyUid == userData.mid then
                local head_bg   = self.mMyResultBg:getChildByName("head_bg")
                local name      = self.mMyResultBg:getChildByName("name")
                self:setHeadIcon(head_bg,userData)
                name:setText(userData.mnick)
            end
            if self.mOtherUid == userData.mid then
                local head_bg   = self.mOtherResultBg:getChildByName("head_bg")
                local name      = self.mOtherResultBg:getChildByName("name")
                self:setHeadIcon(head_bg,userData)
                name:setText(userData.mnick)
            end
            if self.mWinUid == userData.mid then
                self.mTitle:setText( string.format(self.mWinString or "%s胜",userData.mnick))
            end

        end
    elseif cmd == kFriend_UpdateStatus then
        local statusTab = unpack({...})
        for _,status in ipairs(statusTab) do
            if self.mMyUid == status.uid then
                self:setMyRelation(status)
            end
            if self.mOtherUid == status.uid then
                self:setOtherRelation(status)
            end
        end
    end
end

function MatchWatchResultDialog:setWatchResultView(redUid,blackUid,winflag,flag)
    if winflag == 0 then
        self.mWinUid = nil
        self.mTitle:setText("双方和棋");
    elseif winflag == FLAG_RED then
        self.mWinUid = redUid
        local data = FriendsData.getInstance():getUserData(redUid)
        if data then
            self.mTitle:setText( string.format("红方获胜:%s",data.mnick))
        else
            self.mTitle:setText("")
            self.mWinString = "红方获胜:%s"
        end
    elseif winflag == FLAG_BLACK then
        self.mWinUid = blackUid
        local data = FriendsData.getInstance():getUserData(blackUid)
        if data then
            self.mTitle:setText( string.format("黑方获胜:%s",data.mnick))
        else
            self.mTitle:setText("")
            self.mWinString = "黑方获胜:%s"
        end
    end
end

-- 0 和 1 红方  2 黑方
function MatchWatchResultDialog:setMyResult(uid,winflag,flag)
    self.mMyUid = uid
    self.mMyFlag = flag
    local result_icon   = self.mMyResultBg:getChildByName("result_icon")
    local head_bg       = self.mMyResultBg:getChildByName("head_bg")
    local name          = self.mMyResultBg:getChildByName("name")
    local win_num       = self.mMyResultBg:getChildByName("win_num")
    local gift          = self.mMyResultBg:getChildByName("gift")
    local flag_icon     = self.mMyResultBg:getChildByName("flag_icon")
    local data          = FriendsData.getInstance():getUserData(uid)
    gift:setText("获得互动:0")
    if data then
        self:setHeadIcon(head_bg,data)
        name:setText(data.mnick or "博雅象棋")
    else
        -- 重置默认值
        self:setHeadIcon(head_bg)
        name:setText("...")
    end
    if flag == 1 then
        flag_icon:setFile("common/icon/red_king.png")
    else
        flag_icon:setFile("common/icon/black_king.png")
    end

    if winflag == 0 then
        self.mMyResultBg:setFile("common/background/red_bg_1.png")
        result_icon:setFile("dialog/draw.png")
        flag_icon:setGray(false)
        name:setColor(255,250,215)
    elseif winflag == flag then
        self.mMyResultBg:setFile("common/background/red_bg_1.png")
        result_icon:setFile("dialog/win.png")
        flag_icon:setGray(false)
        name:setColor(255,250,215)
    else
        self.mMyResultBg:setFile("common/background/gray_bg_1.png")
        result_icon:setFile("dialog/lose.png")
        flag_icon:setGray(true)
        name:setColor(80,80,80)
    end
end

function MatchWatchResultDialog:setOtherResult(uid,winflag,flag)
    self.mOtherUid = uid
    self.mOtherFlag = flag
    local result_icon   = self.mOtherResultBg:getChildByName("result_icon")
    local head_bg       = self.mOtherResultBg:getChildByName("head_bg")
    local name          = self.mOtherResultBg:getChildByName("name")
    local flag_icon     = self.mOtherResultBg:getChildByName("flag_icon")
    local gift          = self.mOtherResultBg:getChildByName("gift")
    local data          = FriendsData.getInstance():getUserData(uid)
    gift:setText("获得互动:0")
    if data then
        self:setHeadIcon(head_bg,data)
        name:setText(data.mnick or "博雅象棋")
    else
        -- 重置默认值
        self:setHeadIcon(head_bg)
        name:setText("...")
    end
    if flag == 1 then
        flag_icon:setFile("common/icon/red_king.png")
    else
        flag_icon:setFile("common/icon/black_king.png")
    end

    if winflag == 0 then
        self.mOtherResultBg:setFile("common/background/red_bg_1.png")
        result_icon:setFile("dialog/draw.png")
        flag_icon:setGray(false)
        name:setColor(255,250,215)
    elseif winflag == flag then
        self.mOtherResultBg:setFile("common/background/red_bg_1.png")
        result_icon:setFile("dialog/win.png")
        flag_icon:setGray(false)
        name:setColor(255,250,215)
    else
        self.mOtherResultBg:setFile("common/background/gray_bg_1.png")
        result_icon:setFile("dialog/lose.png")
        flag_icon:setGray(true)
        name:setColor(80,80,80)
    end
end

function MatchWatchResultDialog:setHeadIcon(view,data)
    if not view then return end
    local vip = view:getChildByName("vip")
    local level_icon = view:getChildByName("level_icon")
    local mask = view:getChildByName("mask")
    if not mask then
        mask = new(Mask,UserInfo.DEFAULT_ICON[1],"common/background/head_mask_bg_86.png")
        local w,h = view:getSize()
        mask:setSize(w,h)
        mask:setName("mask")
        view:addChild(mask)
        vip:setLevel(2)
        level_icon:setLevel(3)
    end
    if not data then 
        level_icon:setFile("common/icon/level_1.png")
        vip:setVisible(false)
        mask:setFile(UserInfo.DEFAULT_ICON[1])
        return 
    end
    if tonumber(data.iconType) == -1 then
        mask:setUrlImage(data.icon_url)
    else
        local icon = tonumber(data.iconType) or 1
        mask:setFile(UserInfo.DEFAULT_ICON[icon] or UserInfo.DEFAULT_ICON[1])
    end
    level_icon:setFile( string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevelByScore(data.score)))

    local frameRes = UserSetInfo.getInstance():getFrameRes(data.my_set);
    vip:setVisible(false)
    if not frameRes then return end
    vip:setVisible(frameRes.visible);
    if frameRes.frame_res then
        vip:setFile(string.format(frameRes.frame_res,110));
    end
end

function MatchWatchResultDialog:setMyScoreChange(score,change)
    local life = self.mMyResultBg:getChildByName("lifeView")
    life:removeAllChildren(true)
    local addView = self:getScoreView(score,change)
    life:addChild(addView)
end

function MatchWatchResultDialog:setOtherScoreChange(score,change)
    local life = self.mOtherResultBg:getChildByName("lifeView")
    life:removeAllChildren(true)
    local addView = self:getScoreView(score,change)
    life:addChild(addView)
end

function MatchWatchResultDialog:getScoreView(score,change)
    local node = new(Node)
    local w = 0;
    local text1 = new(Text, string.format("生命值:%d",score),width, height, align, fontName, 36, 255, 255, 255)
    text1:setPos(w)
    local addw,addh = text1:getSize()
    w = w + addw
    node:addChild(text1)
    if change > 0 then
        local text2 = new(Text, string.format("(+%d)",change),width, height, align, fontName, 36, 255, 220, 75)
        text2:setPos(w)
        local addw,addh = text2:getSize()
        w = w + addw
        node:addChild(text2)

        local img = new(Image, "common/icon/up_icon_2.png")
        img:setPos(w + 10)
        local addw,addh = img:getSize()
        w = w + addw + 10
        node:addChild(img)
    elseif change < 0 then
        local text2 = new(Text, string.format("(%d)",change),width, height, align, fontName, 36, 200, 25, 25)
        text2:setPos(w)
        local addw,addh = text2:getSize()
        w = w + addw
        node:addChild(text2)

        local img = new(Image, "common/icon/down_icon_2.png")
        img:setPos(w + 10)
        local addw,addh = img:getSize()
        w = w + addw + 10
        node:addChild(img)
    else
        
    end
    return node
end

function MatchWatchResultDialog:setMyRankChange(rank,change)
    local rankView = self.mMyResultBg:getChildByName("rankView")
    rankView:removeAllChildren(true)
    local addView = self:getRankView(rank,change)
    rankView:addChild(addView)
end

function MatchWatchResultDialog:setOtherRankChange(rank,change)
    local rankView = self.mOtherResultBg:getChildByName("rankView")
    rankView:removeAllChildren(true)
    local addView = self:getRankView(rank,change)
    rankView:addChild(addView)
end

function MatchWatchResultDialog:getRankView(rank,change)
    local node = new(Node)
    local w = 0;
    local text1 = new(Text, string.format("排名:"),width, height, align, fontName, 36, 255, 255, 255)
    text1:setPos(w)
    local addw,addh = text1:getSize()
    w = w + addw
    node:addChild(text1)
    if change < 0 then
        local text2 = new(Text, string.format("%d",rank),width, height, align, fontName, 36, 255, 220, 75)
        text2:setPos(w)
        local addw,addh = text2:getSize()
        w = w + addw
        node:addChild(text2)

        local img = new(Image, "common/icon/up_icon_2.png")
        img:setPos(w + 10)
        local addw,addh = img:getSize()
        w = w + addw + 10
        node:addChild(img)
    elseif change > 0 then
        local text2 = new(Text, string.format("%d",rank),width, height, align, fontName, 36, 200, 25, 25)
        text2:setPos(w)
        local addw,addh = text2:getSize()
        w = w + addw
        node:addChild(text2)

        local img = new(Image, "common/icon/down_icon_2.png")
        img:setPos(w + 10)
        local addw,addh = img:getSize()
        w = w + addw + 10
        node:addChild(img)
    else
        local text2 = new(Text, string.format("%d",rank),width, height, align, fontName, 36, 255, 255, 255)
        text2:setPos(w)
        local addw,addh = text2:getSize()
        w = w + addw
        node:addChild(text2)
    end
    return node
end

function MatchWatchResultDialog:setMatchId(matchId)
    self.mMatchId = matchId;
end

function MatchWatchResultDialog:setRedGiftData(data)
    if not data then return end
    local sum = 0
    for k,v in pairs(data) do 
        sum = sum + v
    end
    local mGift          = self.mMyResultBg:getChildByName("gift")
    local oGift          = self.mOtherResultBg:getChildByName("gift")
    if self.mMyFlag == FLAG_RED then
        mGift:setText("获得互动:"..sum)
    else
        oGift:setText("获得互动:"..sum)
    end
end

function MatchWatchResultDialog:setBlackGiftData(data)
    if not data then return end
    local sum = 0
    for k,v in pairs(data) do 
        sum = sum + v
    end
    local mGift          = self.mMyResultBg:getChildByName("gift")
    local oGift          = self.mOtherResultBg:getChildByName("gift")
    if self.mMyFlag == FLAG_BLACK then
        mGift:setText("获得互动:"..sum)
    else
        oGift:setText("获得互动:"..sum)
    end
end

function MatchWatchResultDialog:startRefreshUserStatus()
    self:stopRefreshUserStatus()
    self.mRefreshUserStatusAnim = AnimFactory.createAnimInt(kAnimLoop,0,1,5000,-1)
    self.mRefreshUserStatusAnim:setEvent(self,self.onRefreshUserStatusEvent)
end

function MatchWatchResultDialog:onRefreshUserStatusEvent()
    if self.mMyUid then
        FriendsData.getInstance():sendCheckUserStatus(self.mMyUid)
    end
    if self.mOtherUid then
        FriendsData.getInstance():sendCheckUserStatus(self.mOtherUid)
    end
end

function MatchWatchResultDialog:stopRefreshUserStatus()
    delete(self.mRefreshUserStatusAnim)
end

-- 覆盖 matchResultDialog 的方法
function MatchWatchResultDialog:setDrawView()
end

function MatchWatchResultDialog:setWinView()

end

function MatchWatchResultDialog:setLoseView()
end

function MatchWatchResultDialog:setRankRatio(ratio)
    
end

function MatchWatchResultDialog:setNormalView()
end

function MatchWatchResultDialog:setReviveView()
end

function MatchWatchResultDialog:setMatchOver()
end

function MatchWatchResultDialog:setReviveViewData(info)
end