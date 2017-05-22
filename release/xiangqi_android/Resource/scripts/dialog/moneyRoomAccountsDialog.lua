require(VIEW_PATH .. "money_room_accounts_dialog_view")

MoneyRoomAccountsDialog = class(ChessDialogScene,false)

function MoneyRoomAccountsDialog:ctor()
    super(self,money_room_accounts_dialog_view)
    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)
    self.mShareBtn = self.m_root:getChildByName("share_btn")
    self.mShareBtn:setOnClick(self,self.onShareClick)
    self.mRotatingHaloIcon = self.m_root:getChildByName("rotating_halo_icon")
    self.mRankIcon = self.m_root:getChildByName("rank_icon")
    self.mRankIcon:setEventTouch(self,function()end)
    self.mBg = self.m_root:getChildByName("bg")
    self.mBg:setEventTouch(self,function()end)
    self.mRankTxt  = self.m_root:getChildByName("bg"):getChildByName("rank_txt")
    self.mHeadBg    = self.m_root:getChildByName("head_bg")
    self.mLevelIcon = self.m_root:getChildByName("level_icon")
    self.mNameTxt   = self.m_root:getChildByName("name_txt")
    self.mReward = self.m_root:getChildByName("reward")
    self.mStar      = {}
    self:setShieldClick(self,self.dismiss)
end

function MoneyRoomAccountsDialog:setVisible(...)
    self.super.setVisible(self,...)
end

function MoneyRoomAccountsDialog:dtor()
    self.mDialogAnim.stopAnim()
end

function MoneyRoomAccountsDialog:setRank(rank)
    self.mRankNum = tonumber(rank)
    self.mBg:setFile( string.format("common/background/money_room_bg%d.png",self.mRankNum))
    self.mRankIcon:setFile( string.format("common/decoration/rank_%d.png",self.mRankNum))
    self.mRankTxt:setText( string.format("恭喜您获得第%d名",self.mRankNum))
    self.mHeadBg:removeAllChildren()
    local headIcon = new(Mask,UserInfo.DEFAULT_ICON[1],"hall/icon_frame_mask.png");
    local w,h = self.mHeadBg:getSize()
    headIcon:setSize(w-5,h-5);
    headIcon:setAlign(kAlignCenter)
    self.mHeadBg:addChild(headIcon)
    if UserInfo.getInstance():getIconType() == -1 then
       headIcon:setUrlImage(UserInfo.getInstance():getIcon())
    else
        headIcon:setFile(UserInfo.DEFAULT_ICON[UserInfo.getInstance():getIconType()] or UserInfo.DEFAULT_ICON[1])
    end
    self.mNameTxt:setText(UserInfo.getInstance():getName())
    self.mLevelIcon:setFile(string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevel()))
end

function MoneyRoomAccountsDialog:setReward(rewardTxt)
    self.mReward:removeAllChildren(true)
    local rich = new(RichText,rewardTxt, 0, 0, align, fontName, 36, 255, 235, 45, false,10)
    rich:setAlign(kAlignTop)
    self.mReward:addChild(rich)
end

function MoneyRoomAccountsDialog:show()
    self.super.show(self,self.mDialogAnim.showAnim)
    self:showAnim()
end

function MoneyRoomAccountsDialog:dismiss()
    self.super.dismiss(self,self.mDialogAnim.dismissAnim)
    self:stopAnim()
end
-- 1秒延迟播放星星
function MoneyRoomAccountsDialog:showAnim()
    self:stopAnim()
    self.mRotatingHaloIcon:addPropRotate(1, kAnimLoop, 3000, -1, 0, 360, kCenterDrawing)
    if self.mRankNum == 1 then
        self.mRankIcon:getChildByName("star"):setVisible(true)
        local num = math.random(20,30)
        local angle = 360 / num 
        for i=1,num do
            local star = new(MoneyRoomAccountsDialogStar, math.random(1,3))
            local len = math.random(65,160)
            local x,y = math.sin( math.rad(angle)*i)*len, math.cos( math.rad(angle)*i)*len
            star:addMoveAnim(x,y,1000)
            star:setAlign(kAlignCenter)
            self.mRankIcon:addChild(star)
            self.mStar[i] = star
        end
    else
        self.mRankIcon:getChildByName("star"):setVisible(false) 
    end
end

function MoneyRoomAccountsDialog:stopAnim()
    self.mRotatingHaloIcon:removeProp(1)
    for _,star in ipairs(self.mStar) do
        delete(star)
    end
    self.mStar = {}
end

function MoneyRoomAccountsDialog:onShareClick()
    dict_set_string(kTakeScreenShot , kTakeScreenShot .. kparmPostfix , "egame_share");
    call_native(kTakeScreenShot);
end

MoneyRoomAccountsDialogStar = class(Image,false)

function MoneyRoomAccountsDialogStar:ctor(index)
    super(self, string.format("common/decoration/star_%d.png",index))
    self:addPropRotate(2, kAnimRepeat, math.random(1000,2000), -1, 0, 360, kCenterDrawing)
    local scale = math.random(10,13)/10
    local w,h = self:getSize()
    self:setSize(w*scale,h*scale)
end

function MoneyRoomAccountsDialogStar:dtor()
    self:removeProp(1)
    self:removeProp(2)
    self:removeProp(3)
end

function MoneyRoomAccountsDialogStar:addMoveAnim(x,y,delay)
    self:setPos(x,y)
    local duration = math.random(200,300)
    self:addPropTranslate(1,kAnimNormal,duration ,delay,-x,0,-y,0)
    local duration = math.random(1000,2000)
    self:addPropTransparency(3,kAnimLoop,duration,delay,0,1)
end
