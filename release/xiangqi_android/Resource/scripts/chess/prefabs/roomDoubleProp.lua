require(VIEW_PATH .. "room_double_prop_prefab")
RoomDoubleProp = class(Node)

function RoomDoubleProp:ctor()
    self.mRoot = SceneLoader.load(room_double_prop_prefab)
    local w,h = self.mRoot:getSize()
    local fw,fh = self.mRoot:getFillParent()
    self:setSize(w,h)
    self:setFillParent(fw,fh)
    self:addChild(self.mRoot)

    self.mTipsBg = self.mRoot:getChildByName("tips_bg")
    self.mTipsBg:setEventTouch(self,function()end)
    self.mTipsBg:setVisible(false)
    self.mCountDownHandler = self.mTipsBg:getChildByName("count_down_handler")
    self.mUseTimeHandler = self.mTipsBg:getChildByName("use_time_handler")
    
    self.mShowTipsBtn = self.mRoot:getChildByName("show_tips_btn")
    self.mShowTipsBtn:setOnClick(self,function()
        if self.mTipsBg:getVisible() then
            self:dismissTips()
        else
            self:showTips()
        end
    end)
end

function RoomDoubleProp:dtor()
    self:stopAnim()
end

function RoomDoubleProp:showTips()
    self.mTipsBg:setVisible(true)
    self:startAnim()
    self:updateView()
    HttpModule.getInstance():execute(HttpModule.s_cmds.UserGetDoubleCardsInfo,{});
end

function RoomDoubleProp:dismissTips()
    self.mTipsBg:setVisible(false)
    self:stopAnim()
end

function RoomDoubleProp:startAnim()
    self:stopAnim()
    self.mShowTime = 4
    self.mAnim = AnimFactory.createAnimInt(kAnimLoop, 0, 1, 1000, -1)
    self.mAnim:setEvent(self,self.updateView)
end

function RoomDoubleProp:stopAnim()
    if self.mAnim then
        delete(self.mAnim)
        self.mAnim = nil
    end
end

function RoomDoubleProp:updateView()
    if self.mShowTime <= 0 then self:dismissTips() end
    local countTime = UserInfo.getInstance():getDoublePropEndTime() - os.time()
    local useTime = UserInfo.getInstance():getDoublePropUseTime()
    local countTimeStr = string.format("剩余时间:%02d:%02d:%02d",countTime/3600,(countTime%3600)/60,countTime%60)
    self.mShowTime = self.mShowTime - 1
    if not self.mCountDownText then
        self.mCountDownText = new(Text,countTimeStr, width, height, kAlignTopLeft, fontName, 24, 255, 250, 215)
        self.mCountDownHandler:addChild(self.mCountDownText)
    else
        self.mCountDownText:setText(countTimeStr)
    end
    if self.mPreUseTime ~= useTime then
        local useTimeStr = string.format("积分翻倍:剩余#cF53732%d#n次",useTime)
        self.mPreUseTime = useTime
        self.mUseTimeHandler:removeAllChildren()
        local richText = new(RichText,useTimeStr,width, height, align, fontName, 24, 255, 250, 215, false)
        self.mUseTimeHandler:addChild(richText)
    end
end

function RoomDoubleProp:pause()
end

function RoomDoubleProp:resume()
end
