require(VIEW_PATH .. "match_end_dialog")

MatchEndDialog = class(ChessDialogScene,false)

function MatchEndDialog:ctor()
    super(self,match_end_dialog)
    
    self.mBg = self.m_root:getChildByName("bg")
    self.mHeadBg      = self.mBg:getChildByName("head_bg")
    self.mName     = self.mBg:getChildByName("name")
    self.mMatchName        = self.mBg:getChildByName("match_name")
    self.mMaxWin    = self.mBg:getChildByName("max_win")
    self.mMaxLife = self.mBg:getChildByName("max_life")
    self.mShareBtn  = self.m_root:getChildByName("share_btn")
    self.mShareBtn:setOnClick(self,self.onShareBtnClick)
    self.mWatchBtn  = self.m_root:getChildByName("watch_btn")
    self.mWatchBtn:setOnClick(self,self.onWatchBtnClick)
--    self:setShieldClick(self,self.dismiss);
    self:setNeedBackEvent(false)
end

function MatchEndDialog:dtor()
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeEvent)
end

function MatchEndDialog:show()
    self.super.show(self)
    EventDispatcher.getInstance():register(Event.Call,self,self.onNativeEvent)

    local config = RoomProxy.getInstance():getCurRoomConfig()
    if config then
        self.mMatchName:setText( string.format("恭喜您在%s职业赛中获得",config.name) )
    else
        self.mMatchName:setText( "" )
    end
end

function MatchEndDialog:dismiss()
    self.super.dismiss(self)
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeEvent)
end

function MatchEndDialog:onShareBtnClick()
    if self.mShareBtnClickTime and os.time() - self.mShareBtnClickTime < 1 then return end
    if type(self.mShareBtnEventFunc) == "function" then
        self.mShareBtnEventFunc(self.mShareBtnEventObj)
    end
    self.mShareBtnClickTime = os.time()
end

function MatchEndDialog:onWatchBtnClick()
    if self.mWatchBtnClickTime and os.time() - self.mWatchBtnClickTime < 1 then return end
    if type(self.mWatchBtnEventFunc) == "function" then
        self.mWatchBtnEventFunc(self.mWatchBtnEventObj)
    end
    self.mWatchBtnClickTime = os.time()
end

function MatchEndDialog:setWatchBtnEvent(obj,func)
    self.mWatchBtnEventObj = obj;
    self.mWatchBtnEventFunc = func;
end

function MatchEndDialog:setShareBtnEvent(obj,func)
    self.mShareBtnEventObj = obj;
    self.mShareBtnEventFunc = func;
end

function MatchEndDialog:setRankRatio(ratio)
    self.mMaxWin:setText( string.format("领先%d%%的选手",ratio))
end

function MatchEndDialog:setMaxLife(maxLife)
    self.mMaxLife:setText( string.format("最高生命值:%d",maxLife))
end

function MatchEndDialog:onNativeEvent(param,data)
    if param == kFriend_UpdateUserData then
        for _,userData in ipairs(data) do
            if self.mMyUid == userData.mid then
                local head_bg   = self.mBg:getChildByName("head_bg")
                local name      = self.mBg:getChildByName("name")
                self:setHeadIcon(head_bg,userData)
                name:setText(userData.mnick)
            end
        end
    end
end
-- 0 和 1 红方  2 黑方
function MatchEndDialog:setMyResult(uid)
    self.mMyUid = uid
    local head_bg       = self.mBg:getChildByName("head_bg")
    local name          = self.mBg:getChildByName("name")
    local data          = FriendsData.getInstance():getUserData(uid)
    if data then
        self:setHeadIcon(head_bg,data)
        name:setText(data.mnick or "博雅象棋")
    else
        -- 重置默认值
        self:setHeadIcon(head_bg)
        name:setText("...")
    end
end

function MatchEndDialog:setHeadIcon(view,data)
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