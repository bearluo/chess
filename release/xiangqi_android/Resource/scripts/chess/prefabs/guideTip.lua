require(VIEW_PATH .. "guide_tip_prefab")
GuideTip = class(Node)
function GuideTip:ctor()
    self.mRoot = SceneLoader.load(guide_tip_prefab)
    local w,h = self.mRoot:getSize()
    local fw,fh = self.mRoot:getFillParent()
    self:setSize(w,h)
    self:setFillParent(fw,fh)
    self:addChild(self.mRoot)

    self.mTipdec = self.mRoot:getChildByName("tip_dec")
end

function GuideTip:dtor()
    if self.mReleaseCallBack and type(self.mReleaseCallBack.func) == "function" then
        self.mReleaseCallBack.func(self.mReleaseCallBack.obj,self)
    end
end

function GuideTip:setTipSize(w,h)
    w = math.max(tonumber(w) or 90,90)
    h = math.max(tonumber(h) or 90,90)
    self.mStart = {}
    self.mStart.w = w
    self.mStart.h = h
    self.mOffset = {}
    self.mOffset.w = self.mStart.w * 0.003
    self.mOffset.h = self.mStart.h * 0.003
    self.mEnd = {}
    self.mEnd.w = self.mStart.w * 1.1
    self.mEnd.h = self.mStart.h * 1.1
    self.mTipdec:setSize(self.mStart.w,self.mStart.h)
end

function GuideTip:startAnim()
    self:stopAnim()
    self.mTipdec:addPropScale(1, kAnimLoop, 1000, -1, 1, 1.2, 1, 1.2, kCenterDrawing, x, y)
--    self.mAnim = AnimFactory.createAnimInt(kAnimLoop,0,1,1000/60,-1)
--    self.mAnim:setEvent(self,self.onAnimEvent)
end

function GuideTip:onAnimEvent()
    local w,h = self.mTipdec:getSize()
    if not self.mStart or not self.mOffset or not self.mEnd then return end
    if w < self.mStart.w then
        self.mOffset.w = math.abs(self.mOffset.w)
    elseif w > self.mEnd.w then
        self.mOffset.w = math.abs(self.mOffset.w) * -1
    end
    if h < self.mStart.h then
        self.mOffset.h = math.abs(self.mOffset.h)
    elseif h > self.mEnd.h then
        self.mOffset.h = math.abs(self.mOffset.h) * -1
    end
    self.mTipdec:setSize(w + self.mOffset.w, h + self.mOffset.h)
end

function GuideTip:stopAnim()
--    if self.mAnim then
--        delete(self.mAnim)
--        self.mAnim = nil
--    end
    self.mTipdec:removeProp(1)
end

function GuideTip:setReleaseCallBack(obj,func)
    self.mReleaseCallBack = {}
    self.mReleaseCallBack.obj = obj
    self.mReleaseCallBack.func = func
end

function GuideTip:setTopTipText(str,x,y,w,h,rx)
    if self.mBg then delete(self.mBg) end
    self.mBg = new(Image, "common/background/tips_bg_3.png", fmt, filter, 50, 50, 48, 48)
    self.mBg:setAlign(kAlignBottom)
    self.mBg:setPos(x,y)
    self.mBg:setSize(w,h)
    local richText = new(RichText,str, w-30, height, kAlignTopLeft, fontName, 30, 255, 250, 215, true,5)
    richText:setPos(15,15)
    local rw,rh = richText:getSize()
    if rh > h - 30 then
        self.mBg:setSize(w,rh + 30)
    end
    self.mBg:addChild(richText)
    local dec = new(Image, "common/decoration/down_dec.png")
    dec:setAlign(kAlignBottom)
    dec:setPos(rx, select(2,dec:getSize()) * -1)
    self.mBg:addChild(dec)
    self:addChild(self.mBg)
end

--rx ¼ýÍ·µÄxÖáÎ»ÖÃ
function GuideTip:setBottomTipText(str,x,y,w,h,rx)
    if self.mBg then delete(self.mBg) end
    self.mBg = new(Image, "common/background/tips_bg_3.png", fmt, filter, 50, 50, 48, 48)
    self.mBg:setAlign(kAlignTop)
    self.mBg:setPos(x,y)
    self.mBg:setSize(w,h)
    local richText = new(RichText,str, w-30, height, kAlignTopLeft, fontName, 24, 255, 250, 215, true,5)
    richText:setPos(15,15)
    local rw,rh = richText:getSize()
    if rh > h - 30 then
        self.mBg:setSize(w,rh + 30)
    end
    self.mBg:addChild(richText)
    local dec = new(Image, "common/decoration/up_dec.png")
    dec:setAlign(kAlignTop)
    dec:setPos(rx, select(2,dec:getSize()) * -1)
    self.mBg:addChild(dec)
    self:addChild(self.mBg)
end


function GuideTip:pause()
end

function GuideTip:resume()
end
