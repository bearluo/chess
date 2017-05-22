require(VIEW_PATH .. "match_vs_dialog_view")

MatchVsDialog = class(ChessDialogScene,false)

function MatchVsDialog:ctor()
    super(self,match_vs_dialog_view)
    self.mTopUserView   = self.m_root:getChildByName("top_user_view")
    self.mDownUserView  = self.m_root:getChildByName("down_user_view")
--    local cubicBezier = require("libs.cubicBezier")
    self.mTopAnimBg     = self.m_root:getChildByName("up_anim_bg")
    self.mDownAnimBg    = self.m_root:getChildByName("down_anim_bg")
    self.mDuiIcon       = self.m_root:getChildByName("dui_icon")
    self.mDuiIcon1      = self.m_root:getChildByName("dui_icon1")
    self.mJuIcon        = self.m_root:getChildByName("ju_icon")
    self.mJuIcon1       = self.m_root:getChildByName("ju_icon1")
    self.mBombView      = self.m_root:getChildByName("bomb_view")
    self.mBombViewImages = {} 
end

function MatchVsDialog:dtor()
    self:stopShowAnim()
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeEvent)
end

function MatchVsDialog:show()
    self.super.show(self)
    self:startShowAnim()
    EventDispatcher.getInstance():register(Event.Call,self,self.onNativeEvent)
end

function MatchVsDialog:dismiss()
    self.super.dismiss(self)
    self:stopShowAnim()
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeEvent)
end

function MatchVsDialog:onNativeEvent(param,data)
    if param == kFriend_UpdateUserData then
        for _,userData in ipairs(data) do
            if self.mTopUserUid == userData.mid then
                self:setUserView(self.mTopUserView,userData)
            end
            if self.mDownUserUid == userData.mid then
                self:setUserView(self.mDownUserView,userData)
            end
        end
    end
end

function MatchVsDialog:startShowAnim()
    self:stopShowAnim()
    self.mAnim = AnimFactory.createAnimInt(kAnimNormal, 0, 1, 5000, -1)
    self.mAnim:setEvent(self,self.dismiss)
    local v = 3
    local offset = 120
    local w,h = self.mTopUserView:getSize()
    self.mTopUserView:addPropTranslate(1, kAnimNormal, w/v, -1,-w, 0, 0, 0)
    self.mTopUserView:addPropTranslateWithEasing(2, kAnimNormal, 250, w/v,"easeOutBounce",nil,-25, 25, 0, 0)
    local w,h = self.mTopAnimBg:getSize()
    self.mTopAnimBg:addPropTranslate(1, kAnimNormal, (w+offset)/v, -1,-w, offset, 0, 0)
    self.mTopAnimBg:addPropTransparency(2, kAnimNormal, 250, (w+offset)/v/2,1,0)
    local w,h = self.mDownUserView:getSize()
    self.mDownUserView:addPropTranslate(1, kAnimNormal, w/v, -1,w, 0, 0, 0)
    self.mDownUserView:addPropTranslateWithEasing(2, kAnimNormal, 250, w/v,"easeOutBounce",nil,25, -25, 0, 0)
    local w,h = self.mDownAnimBg:getSize()
    self.mDownAnimBg:addPropTranslate(1, kAnimNormal, (w+offset)/v, -1,w, -offset, 0, 0)
    self.mDownAnimBg:addPropTransparency(2, kAnimNormal, 250, (w+offset)/v,1,0)
    
    local maxScale = 8
    local scaleTime = 250
    local w,h = self.mDuiIcon:getSize()
    self.mDuiIcon:addPropScale(1, kAnimNormal, scaleTime, -1,maxScale, 1, maxScale, 1,kCenterXY,w,h/2)
    local anim = self.mJuIcon:addPropScale(1, kAnimNormal, scaleTime, -1,maxScale, 1, maxScale, 1,kCenterXY,0,h/2)
    self.mDuiIcon1:setVisible(false)
    self.mJuIcon1:setVisible(false)
    anim:setEvent(self,function()
         self.mDuiIcon1:setVisible(true)
         self.mJuIcon1:setVisible(true)
    end)
    
    self.mCurFrame = 1
    self.mMaxFrame = 12
    local time = (self.mMaxFrame)*50
    local w,h = self.mDuiIcon:getSize()
    self.mDuiIcon1:addPropScale(1, kAnimNormal, time, scaleTime,1, maxScale/4, 1, maxScale/4,kCenterXY,w,h/2)
    self.mJuIcon1:addPropScale(1, kAnimNormal, time, scaleTime,1, maxScale/4, 1, maxScale/4,kCenterXY,0,h/2)
    self.mDuiIcon1:addPropTransparency(2, kAnimNormal, time, scaleTime,0.6,0)
    self.mJuIcon1:addPropTransparency(2, kAnimNormal, time, scaleTime,0.6,0)
    self.mAnim = AnimFactory.createAnimInt(kAnimLoop, 0, 1, 100, scaleTime)
    self.mAnim:setEvent(self,self.onFrameEvent)
end

function MatchVsDialog:onFrameEvent()
    if self.mBombViewImages[self.mCurFrame-1] then
        self.mBombViewImages[self.mCurFrame-1]:setVisible(false)
    end 
    if self.mCurFrame > self.mMaxFrame then
        if self.mCurFrame > self.mMaxFrame+5 then
            self:dismiss()
        end
        self.mCurFrame = self.mCurFrame+1
        return
    end

    if not self.mBombViewImages[self.mCurFrame] then
        self.mBombViewImages[self.mCurFrame] = new(Image, string.format("animation/vs/bomb_%d.png",self.mCurFrame))
        self.mBombViewImages[self.mCurFrame]:setSize(400,400)
        self.mBombViewImages[self.mCurFrame]:setAlign(kAlignCenter)
        self.mBombView:addChild(self.mBombViewImages[self.mCurFrame])
    end
    self.mBombViewImages[self.mCurFrame]:setVisible(true)
    self.mCurFrame = self.mCurFrame+1
end

function MatchVsDialog:stopShowAnim()
    self.mTopUserView:removeProp(1)
    self.mDownUserView:removeProp(1)
    self.mTopUserView:removeProp(2)
    self.mDownUserView:removeProp(2)
    self.mTopAnimBg:removeProp(1)
    self.mDownAnimBg:removeProp(1)
    self.mTopAnimBg:removeProp(2)
    self.mDownAnimBg:removeProp(2)
    self.mDuiIcon:removeProp(1)
    self.mJuIcon:removeProp(1)
    self.mDuiIcon1:removeProp(1)
    self.mJuIcon1:removeProp(1)
    self.mDuiIcon1:removeProp(2)
    self.mJuIcon1:removeProp(2)

    delete(self.mAnim)
end
-- flag 1 红方 2 黑方
function MatchVsDialog:setTopUserView(uid,life,flag)
    self.mTopUserUid = uid
    local data = FriendsData.getInstance():getUserData(uid)
    self:setUserView(self.mTopUserView,data,life)
    local bg = self.mTopUserView:getChildByName("bg")
    local flag_icon = self.mTopUserView:getChildByName("flag_icon")
    local lifeNum = self.mTopUserView:getChildByName("life_num")
    lifeNum:setText( string.format("生命值:%d",life))
    if flag == 1 then
        bg:setFile("common/background/red_bg_3.png")
        flag_icon:setFile("common/icon/red_king.png")
        self.mTopAnimBg:setFile("animation/vs/top_r.png")
    else
        bg:setFile("common/background/black_bg_3.png")
        flag_icon:setFile("common/icon/black_king.png")
        self.mTopAnimBg:setFile("animation/vs/top_b.png")
    end
end

-- flag 1 红方 2 黑方
function MatchVsDialog:setDownUserView(uid,life,flag)
    self.mDownUserUid = uid
    local data = FriendsData.getInstance():getUserData(uid)
    self:setUserView(self.mDownUserView,data)
    local bg = self.mDownUserView:getChildByName("bg")
    local flag_icon = self.mDownUserView:getChildByName("flag_icon")
    local lifeNum = self.mDownUserView:getChildByName("life_num")
    lifeNum:setText( string.format("生命值:%d",life))
    if flag == 1 then
        bg:setFile("common/background/red_bg_4.png")
        flag_icon:setFile("common/icon/red_king.png")
        self.mDownAnimBg:setFile("animation/vs/botton_r.png")
    else
        bg:setFile("common/background/black_bg_4.png")
        flag_icon:setFile("common/icon/black_king.png")
        self.mDownAnimBg:setFile("animation/vs/botton_b.png")
    end
end

function MatchVsDialog:setUserView(view,data)
    if view ~= self.mTopUserView and view ~= self.mDownUserView then return end
    local headBg = view:getChildByName("head_bg")
    local level_icon = headBg:getChildByName("level")
    local vip = headBg:getChildByName("vip")
    
    local mask   = headBg:getChildByName("mask")
    if not mask then
        mask = new(Mask,UserInfo.DEFAULT_ICON[1],"common/background/head_mask_bg_122.png")
        local w,h = headBg:getSize()
        mask:setSize(w,h)
        mask:setName("mask")
        headBg:addChild(mask)
        vip:setLevel(2)
        level_icon:setLevel(3)
    end
    local name          = view:getChildByName("name")
    if not data then 
        level_icon:setFile("common/icon/level_1.png")
        vip:setVisible(false)
        mask:setFile(UserInfo.DEFAULT_ICON[1])
        name:setText("")
        return 
    end
    name:setText(data.mnick or "博雅象棋")
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