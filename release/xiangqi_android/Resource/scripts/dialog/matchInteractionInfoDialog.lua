require(VIEW_PATH .. "match_interaction_info_dialog")

MatchInteractionInfoDialog = class(ChessDialogScene,false)

function MatchInteractionInfoDialog:ctor()
    super(self,match_interaction_info_dialog)
    self.mBg   = self.m_root:getChildByName("bg")
    self.mRedUserInfo   = self.mBg:getChildByName("red_user_info")
    self.mBlackUserInfo  = self.mBg:getChildByName("black_user_info")
    self.mBlackGiftData = {}
    self.mRedGiftData = {}
    
    self.mRedGiftView   = self.mRedUserInfo:getChildByName("gift_view")
    self.mBlackGiftView   = self.mBlackUserInfo:getChildByName("gift_view")
    local rw,rh = self.mRedGiftView:getSize()
    local rscrSize = {w = rw,h = rh}
    local ritemSize = {w = 100,h = 100}
    local rbgSize = {w = 80,h = 26}
    self.mRedGiftModuleScrollList = new(GiftModuleScrollList,rscrSize,ritemSize,rbgSize,GiftModuleItem.s_mode_user)
--    self.mRedGiftModuleScrollList:initScrollView(GiftModuleScrollList.s_ssize)
    self.mRedGiftView:addChild(self.mRedGiftModuleScrollList)
    self.mRedGiftParams ={}
    self.mRedGiftParams.gift ={}
    

    local bw,bh = self.mBlackGiftView:getSize()
    local bscrSize = {w = bw,h = bh}
    local bitemSize = {w = 100,h = 100}
    local bgSize = {w = 80,h = 26}
    self.mBlackGiftModuleScrollList = new(GiftModuleScrollList,bscrSize,bitemSize,bgSize,GiftModuleItem.s_mode_user)
--    self.mBlackGiftModuleScrollList:initScrollView(GiftModuleScrollList.s_ssize)
    self.mBlackGiftView:addChild(self.mBlackGiftModuleScrollList)
    self.mBlackGiftParams ={}
    self.mBlackGiftParams.gift ={}
    
    self.mInteractionLogBg  = self.mBg:getChildByName("content_view")
    
    local svW, svH = self.mInteractionLogBg:getSize();
    self.mInteractionLog = new(ScrollView2,0,0,svW,svH,true);
    self.mInteractionLog:setFillParent(true,true);
    self.mInteractionLogBg:addChild(self.mInteractionLog);

    self.mBg:setEventTouch(self,function()end)
    self:setShieldClick(self,self.dismiss)
    EventDispatcher.getInstance():register(Event.Call,self,self.onNativeEvent)
end

function MatchInteractionInfoDialog:dtor()
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeEvent)
end

function MatchInteractionInfoDialog:show()
    self.super.show(self)
end

function MatchInteractionInfoDialog:dismiss()
    self.super.dismiss(self)
end


function MatchInteractionInfoDialog:addInteractionLog(data)
    if not data then return end
--    local item = WatchItemStyle.createNode(data)
    local item = WatchItemStyle.createNoNumNode(data)
    self.mInteractionLog:addChild(item);
    self.mInteractionLog:gotoBottom();
end

function MatchInteractionInfoDialog:resetInteraction()
    self.mRedGiftModuleScrollList:clearItemNum()
    self.mBlackGiftModuleScrollList:clearItemNum()
end

function MatchInteractionInfoDialog:setRedGiftData(data)
    if data then
--        self.mRedGiftParams.gift ={}
--        for k,v in pairs(data) do 
--            local insert = {}
--            insert.gift_id = tonumber(k)
--            insert.gift_num = tonumber(v)
--            table.insert(self.mRedGiftParams.gift,insert)
--        end
        self.mRedGiftModuleScrollList:onUpdateItem(data)
    end
end

function MatchInteractionInfoDialog:setBlackGiftData(data)
    if data then
--        self.mBlackGiftParams.gift ={}
--        for k,v in pairs(data) do 
--            local insert = {}
--            insert.gift_id = tonumber(k)
--            insert.gift_num = tonumber(v)
--            table.insert(self.mBlackGiftParams.gift,insert)
--        end
        self.mBlackGiftModuleScrollList:onUpdateItem(data)
    end
end

function MatchInteractionInfoDialog:onNativeEvent(param,data)
    if param == kFriend_UpdateUserData then
        for _,userData in ipairs(data) do
            if self.mTopUserUid == userData.mid then
                self:setUserView(self.mRedUserInfo,userData)
            end
            if self.mDownUserUid == userData.mid then
                self:setUserView(self.mBlackUserInfo,userData)
            end
        end
    end
end

-- flag 1 红方 2 黑方
function MatchInteractionInfoDialog:setRedUserView(uid)
    self.mTopUserUid = uid
    local data = FriendsData.getInstance():getUserData(uid)
    self:setUserView(self.mRedUserInfo,data)
end

-- flag 1 红方 2 黑方
function MatchInteractionInfoDialog:setBlackUserView(uid)
    self.mDownUserUid = uid
    local data = FriendsData.getInstance():getUserData(uid)
    self:setUserView(self.mBlackUserInfo,data)
end

function MatchInteractionInfoDialog:setUserView(view,data)
    if view ~= self.mRedUserInfo and view ~= self.mBlackUserInfo then return end
    local headBg = view:getChildByName("head")
    local level_icon = view:getChildByName("level")
    local flag = headBg:getChildByName("flag")
    local vip = headBg:getChildByName("vip")
    local name  = view:getChildByName("name")
    
    local mask   = headBg:getChildByName("mask")
    if not mask then
        mask = new(Mask,UserInfo.DEFAULT_ICON[1],"common/background/head_mask_bg_122.png")
        local w,h = headBg:getSize()
        mask:setSize(w,h)
        mask:setName("mask")
        headBg:addChild(mask)
        vip:setLevel(2)
        flag:setLevel(3)
    end
    if not data then 
        level_icon:setVisible(false)
        vip:setVisible(false)
        mask:setFile("common/background/head_bg_92.png")
        name:setText("")
        return 
    end
    name:setText(data.mnick or "博雅象棋")
    level_icon:setVisible(true)
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