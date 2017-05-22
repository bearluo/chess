require(VIEW_PATH .. "match_notice_view")


MatchNoticeView = class(Node)

function MatchNoticeView:ctor()
    self.mRoot = SceneLoader.load(match_notice_view)
    self:addChild(self.mRoot)
    local w,h = self.mRoot:getSize()
    self:setFillParent(true,false)
    self.mAddW = select(1,self:getSize()) - 720
    self.mContent = self.mRoot:getChildByName("bg"):getChildByName("content_view")
    self.mCancelBtn = self.mRoot:getChildByName("bg"):getChildByName("cancel_btn")
    self.mCancelBtn:setOnClick(self,self.dismiss)
    self.mSureBtn = self.mRoot:getChildByName("bg"):getChildByName("sure_btn")
    self.mIconView = self.mRoot:getChildByName("bg"):getChildByName("icon_view")
    local w,h = self.mIconView:getSize()
    self.mHead = new(Mask,UserInfo.DEFAULT_ICON[1],"common/background/head_mask_bg_86.png")
    self.mHead:setSize(w,h)
    self.mIconView:addChild(self.mHead)
    self.mBg = self.mRoot:getChildByName("bg")
    self.mBg:setEventDrag(self,function()end);
    self.mBg:setEventTouch(self,function()end);
    self:setConfirmType(0)
end

function MatchNoticeView:dtor()
    self:removeProp(1)
    self:stopShowAnim()
end

function MatchNoticeView:setText(richText)
    self.mContent:removeAllChildren(true)
    local w,h = self.mContent:getSize()
    if not richText then return end
    self.mRichTextStr = richText
    local richTextView = new(RichText,richText, w, h, kAlignTopLeft, fontName, fontSize, 80, 80, 80, true,5)
    local rw,rh = richTextView:getSize()
    self:setSize(nil,81 + rh - h )
    self.mContent:addChild(richTextView)
end

function MatchNoticeView:show(time)
    self:setVisible(true)
    self.mShowTime = (tonumber(time) or 5) * 1000
    local w,h = self:getSize()
    self:removeProp(1)
    local anim = self:addPropTranslate(1,kAnimNormal,500,-1,0,0,h,0)
    anim:setEvent(self,self.startShowAnim)
end

function MatchNoticeView:dismiss()
    self:removeProp(1)
    local w,h = self:getSize()
    local anim = self:addPropTranslate(1,kAnimNormal,500,-1,0,0,0,h)
    anim:setEvent(self,function()
        self:setVisible(false)
    end)
    self:stopShowAnim()
end

--跳转类型（0:不跳转，1:跳转聊天室，2:跳转比赛）
function MatchNoticeView:setConfirmType(jumpType,obj,func)
    jumpType = tonumber(jumpType) or 0
    self.mSureBtn:setVisible(false)
    self.mSureBtn:setOnClick(nil,nil)
    if jumpType == 0 then
    elseif jumpType == 1 then
        self.mSureBtn:setVisible(true)
        self.mSureBtn:setOnClick(obj,func)
    elseif jumpType == 2 then
        self.mSureBtn:setVisible(true)
        self.mSureBtn:setOnClick(obj,func)
    end
    self.mJumpType = jumpType
    self:resetSize()
end

function MatchNoticeView:setHeadUrl(url)
    self.mHead:setUrlImage(url,UserInfo.DEFAULT_ICON[1])
end


function MatchNoticeView:resetSize()
    local jumpType = self.mJumpType or 0
    local w = 500 + self.mAddW
    if jumpType == 0 then
    elseif jumpType == 1 then
        w = 370 + self.mAddW
    elseif jumpType == 2 then
        w = 370 + self.mAddW
    end
    self.mContent:setSize(w)
end

function MatchNoticeView:startShowAnim()
    self:stopShowAnim()
    self.mShowTime = self.mShowTime or 5000
    self.mStartShowAnim = AnimFactory.createAnimInt(kAnimNormal, 0, 1, self.mShowTime, -1)
    self.mStartShowAnim:setEvent(self,self.dismiss)
end

function MatchNoticeView:stopShowAnim()
    delete(self.mStartShowAnim)
end