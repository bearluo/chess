require(VIEW_PATH .. "match_result_dialog")

MatchResultDialog = class(ChessDialogScene,false)

function MatchResultDialog:ctor()
    super(self,match_result_dialog)
    
    self.mResultIconView = self.m_root:getChildByName("result_icon_view")
    self.mRankView      = self.m_root:getChildByName("rank_view")
    self.mRankRatio     = self.m_root:getChildByName("rank_ratio")
    self.mTimeBg        = self.m_root:getChildByName("time_bg")
    self.mMyResultBg    = self.m_root:getChildByName("my_result_bg")
    self.mOtherResultBg = self.m_root:getChildByName("other_result_bg")
    self.mPlayAgainBtn  = self.m_root:getChildByName("play_again_btn")
    self.mPlayAgainBtn:setOnClick(self,self.onPlayAgainBtnClick)
    self.mCountDownBtn  = self.m_root:getChildByName("count_down_btn")
    self.mCountDownBtn:setOnClick(self,self.onCountDownBtn)
    self.mCloseBtn  = self.m_root:getChildByName("close_btn")
    self.mCloseBtn:setOnClick(self,self.cancel)
    self.mSaveChessBtn  = self.m_root:getChildByName("save_chess_btn")
    self.mSaveChessBtn:setOnClick(self,self.onSaveMychess)
    self.mShowRankBtn  = self.m_root:getChildByName("show_rank_btn")
    self.mShowRankBtn:setOnClick(self,self.onShowRank)
    
    self.mRankScrollView    = self.mRankView:getChildByName("rank_scroll_view")
    self.mRankScrollView.m_autoPositionChildren = true
    self.mRankScrollView:setDirection(kHorizontal)
    self.mLoadingAnimIcon   = self.mRankView:getChildByName("loading_anim")
    self.mLoadingAnimIcon:setVisible(false)
    self:setNeedBackEvent(false)
    -- 用来拉取复活提示文本
    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.httpEventCallBack)
    local result_icon   = self.mOtherResultBg:getChildByName("result_icon")
    result_icon:setTransparency(0.5)
    local result_icon   = self.mMyResultBg:getChildByName("result_icon")
    result_icon:setTransparency(0.5)
end

function MatchResultDialog:dtor()
    self:stopRefreshAnim()
    self:stopDownTime()
    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpCallBack)
    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.httpEventCallBack)
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeEvent)
end

function MatchResultDialog:show()
    self.super.show(self)
    local params = {}
    params.param = {}
    params.param.match_id= self.mMatchId
    params.param.rank_num = 3
    HttpModule.getInstance():execute(HttpModule.s_cmds.MatchRank2,params);
    self:startRefreshAnim()
    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpCallBack)
    EventDispatcher.getInstance():register(Event.Call,self,self.onNativeEvent)
    self:startDownTime()
    self:resetSaveChess()
end

function MatchResultDialog:dismiss()
    self.super.dismiss(self)
    self:stopRefreshAnim()
    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpCallBack)
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeEvent)
    self:stopDownTime()
    self:resetResultView()
end

function MatchResultDialog:saveChessSuccess()
    self.mSaveChessBtn:setFile("dialog/has_save.png");
    self.mSaveChessBtn:setPickable(false);
end

function MatchResultDialog:resetSaveChess()
    self.mSaveChessBtn:setFile("dialog/save_mychess.png");
    self.mSaveChessBtn:setPickable(true);
end

function MatchResultDialog:onPlayAgainBtnClick()
    if self.mPlayAgainBtnClickTime and os.time() - self.mPlayAgainBtnClickTime < 1 then return end
    if type(self.mPlayAgainBtnEventFunc) == "function" then
        self.mPlayAgainBtnEventFunc(self.mPlayAgainBtnEventObj)
    end
    self.mPlayAgainBtnClickTime = os.time()
end

function MatchResultDialog:onCountDownBtn()
    if self.mCountDownBtnClickTime and os.time() - self.mCountDownBtnClickTime < 1 then return end
    if type(self.mCountDownBtnEventFunc) == "function" then
        self.mCountDownBtnEventFunc(self.mCountDownBtnEventObj)
    end
    self.mCountDownBtnClickTime = os.time()
end

function MatchResultDialog:cancel()
    if self.mCancelClickTime and os.time() - self.mCancelClickTime < 1 then return end
    if type(self.mCancelEventFunc) == "function" then
        self.mCancelEventFunc(self.mCancelEventObj)
    end
    self.mCancelClickTime = os.time()
end

function MatchResultDialog:onSaveMychess()
    if self.mSaveChessEventClickTime and os.time() - self.mSaveChessEventClickTime < 1 then return end
    if type(self.mSaveChessEventFunc) == "function" then
        self.mSaveChessEventFunc(self.mSaveChessEventObj)
    end
    self.mSaveChessEventClickTime = os.time()
end

function MatchResultDialog:onShowRank()
    if self.mShowRankEventClickTime and os.time() - self.mShowRankEventClickTime < 1 then return end
    if type(self.mShowRankEventFunc) == "function" then
        self.mShowRankEventFunc(self.mShowRankEventObj)
    end
    self.mShowRankEventClickTime = os.time()
end

function MatchResultDialog:setShowRankEvent(obj,func)
    self.mShowRankEventObj = obj;
    self.mShowRankEventFunc = func;
end

function MatchResultDialog:setSaveChessEvent(obj,func)
    self.mSaveChessEventObj = obj;
    self.mSaveChessEventFunc = func;
end

function MatchResultDialog:setCancelEvent(obj,func)
    self.mCancelEventObj = obj;
    self.mCancelEventFunc = func;
end

function MatchResultDialog:setCountDownBtnEvent(obj,func)
    self.mCountDownBtnEventObj = obj;
    self.mCountDownBtnEventFunc = func;
end

function MatchResultDialog:setPlayAgainBtnEvent(obj,func)
    self.mPlayAgainBtnEventObj = obj;
    self.mPlayAgainBtnEventFunc = func;
end

function MatchResultDialog:setReviveView()
    self.isNormalView = false
    self.mPlayAgainBtn:setVisible(self.isNormalView and not self.isMatchOver)
    self.mCountDownBtn:setVisible(not self.isNormalView and not self.isMatchOver)
    self.mCloseBtn:setVisible(true)
end

function MatchResultDialog:setNormalView()
    self.isNormalView = true
    self.playAgainDownTime = 10
    self.mPlayAgainBtn:setVisible(self.isNormalView and not self.isMatchOver)
    self.mCountDownBtn:setVisible(not self.isNormalView and not self.isMatchOver)
    self.mCloseBtn:setVisible(self.isMatchOver)
end

function MatchResultDialog:setMatchOver(isMatchOver,title)
    local msg = title or self.mShowRankBtn:getChildByName("title"):getText()
    self.isMatchOver = isMatchOver
    self.mShowRankBtn:getChildByName("title"):setText(msg)
    self.mShowRankBtn:setVisible(self.isMatchOver)
    self.mPlayAgainBtn:setVisible(self.isNormalView and not self.isMatchOver)
    self.mCountDownBtn:setVisible(not self.isNormalView and not self.isMatchOver)
    self.mCloseBtn:setVisible(true)
end

function MatchResultDialog:resetResultView()
    self.mShowRankBtn:setVisible(false)
    self.mPlayAgainBtn:setVisible(false)
    self.mCountDownBtn:setVisible(false)
    self.mCloseBtn:setVisible(false)
end
--[[
    info.matchId    = self.m_socket:readString(packetId,ERROR_STRING);
    info.canReviveTime = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.maxScore   = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.countDown  = self.m_socket:readInt(packetId,ERROR_NUMBER);
]]--
function MatchResultDialog:setReviveViewData(info)
    self.mCountDownTimeStart = true
    self.mCountDownTime = tonumber(info.countDown) or 0
    self.mCountDownBtn:setPickable(true)
    self.mCountDownBtn:setGray(false)
    local title = self.mCountDownBtn:getChildByName("title")
    local count_down_text = self.mCountDownBtn:getChildByName("count_down_text")
    if info.canReviveTime <= 0 then
        title:setText("无法复活")
        title:setPos(0)
        self.mCountDownBtn:setPickable(false)
        self.mCountDownBtn:setGray(true)
        count_down_text:setVisible(false)
--    elseif info.canReviveTime <= 10 then
--        title:setText( string.format("(复活剩余次数:%d)") )
    else
        title:setText( "立即复活" )
        title:setPos(-63)
        count_down_text:setVisible(true)
    end

    local msg = self.mCountDownBtn:getChildByName("msg")
    msg:setText("拉取数据中...")
    count_down_text:setText( string.format("(%d)",self.mCountDownTime))

    
    local params = {}
    params.param = {}
    params.param.match_id = RoomProxy.getInstance():getMatchId()
    HttpModule.getInstance():execute(HttpModule.s_cmds.MatchGetRebuyMoney,params)
end

function MatchResultDialog:startDownTime()
    self:stopDownTime()
    self.mDownTimeAnim = AnimFactory.createAnimInt(kAnimLoop, 0, 1, 1000, -1)
    self.mDownTimeAnim:setEvent(self,self.downTimeEvent)
end

function MatchResultDialog:downTimeEvent()
    local timeTxt = self.mTimeBg:getChildByName("time")
    if self.mOverTime then
        local time = self.mOverTime - TimerHelper.getServerCurTime()
        if time < 0 then time = 0 end
        local SS = time % 60
        local MM = (time - SS) / 60
        timeTxt:setText( string.format("%02d:%02d",MM,SS))
    else
        timeTxt:setText("00:00")
    end

    if self.mCountDownTime and self.mCountDownTimeStart then
        self.mCountDownTime = self.mCountDownTime - 1
        local count_down_text = self.mCountDownBtn:getChildByName("count_down_text")
        if self.mCountDownTime <= 0 then
            self.mCountDownTime = 0
        end
        count_down_text:setText( string.format("(%d)",self.mCountDownTime))
        if self.mCountDownTime == 0 then
            local title = self.mCountDownBtn:getChildByName("title")
            title:setPos(0)
            title:setText("无法复活")
            self.mCountDownBtn:setPickable(false)
            self.mCountDownBtn:setGray(true)
            count_down_text:setVisible(false)
            count_down_text:setText("")
        end
    end

    --count_down_text
    if self.playAgainDownTime and self.isNormalView and not self.isMatchOver then
        self.playAgainDownTime = self.playAgainDownTime - 1
        local count_down_text = self.mPlayAgainBtn:getChildByName("count_down_text")
        if self.playAgainDownTime <= 0 then
            self.playAgainDownTime = 0
        end
        count_down_text:setText( string.format("(%d)",self.playAgainDownTime))
        if self.playAgainDownTime == 0 then
            self:onPlayAgainBtnClick()
        end
    end 
end


function MatchResultDialog:stopDownTime()
    delete(self.mDownTimeAnim)
end

function MatchResultDialog:setOverTime(time)
    self.mOverTime = time
end

function MatchResultDialog:setRedGiftData(data)
    if not data then return end
    local sum = 0
    for k,v in pairs(data) do 
        sum = sum + v
    end
    local gift          = self.mMyResultBg:getChildByName("gift")
    if self.mMyFlag == FLAG_RED then
        gift:setText("获得互动:"..sum)
    end
end

function MatchResultDialog:setBlackGiftData(data)
    if not data then return end
    local sum = 0
    for k,v in pairs(data) do 
        sum = sum + v
    end
    local gift          = self.mMyResultBg:getChildByName("gift")
    if self.mMyFlag == FLAG_BLACK then
        gift:setText("获得互动:"..sum)
    end
end

function MatchResultDialog:setRankRatio(ratio)
    self.mRankRatio:setText( string.format("领先%d%%的选手",ratio))
end

function MatchResultDialog:onNativeEvent(param,data)
    if param == kFriend_UpdateUserData then
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
        end
    end
end

-- 0 和 1 红方  2 黑方
function MatchResultDialog:setMyResult(uid,winflag,flag)
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

function MatchResultDialog:setOtherResult(uid,winflag,flag)
    self.mOtherUid = uid
    self.mOtherFlag = flag
    local result_icon   = self.mOtherResultBg:getChildByName("result_icon")
    local head_bg       = self.mOtherResultBg:getChildByName("head_bg")
    local name          = self.mOtherResultBg:getChildByName("name")
    local flag_icon     = self.mOtherResultBg:getChildByName("flag_icon")
    local data          = FriendsData.getInstance():getUserData(uid)
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
        self.mOtherResultBg:setFile("common/background/red_bg_2.png")
        result_icon:setFile("dialog/draw.png")
        flag_icon:setGray(false)
        name:setColor(255,250,215)
    elseif winflag == flag then
        self.mOtherResultBg:setFile("common/background/red_bg_2.png")
        result_icon:setFile("dialog/win.png")
        flag_icon:setGray(false)
        name:setColor(255,250,215)
    else
        self.mOtherResultBg:setFile("common/background/gray_bg_2.png")
        result_icon:setFile("dialog/lose.png")
        flag_icon:setGray(true)
        name:setColor(80,80,80)
    end
end

function MatchResultDialog:setHeadIcon(view,data)
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
    local frameRes = UserSetInfo.getInstance():getFrameRes(data.my_set);
    vip:setVisible(false)
    if not frameRes then return end
    vip:setVisible(frameRes.visible);
    if frameRes.frame_res then
        vip:setFile(string.format(frameRes.frame_res,110));
    end
    level_icon:setFile( string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevelByScore(data.score)))
end

function MatchResultDialog:setMyScoreChange(score,change)
    local life = self.mMyResultBg:getChildByName("lifeView")
    life:removeAllChildren(true)
    local addView = self:getScoreView(score,change,36)
    life:addChild(addView)
end

function MatchResultDialog:setOtherScoreChange(score,change)
    local life = self.mOtherResultBg:getChildByName("lifeView")
    life:removeAllChildren(true)
    local addView = self:getScoreView(score,change,26)
    life:addChild(addView)
end

function MatchResultDialog:getScoreView(score,change,fontSize)
    local node = new(Node)
    local w = 0;
    local text1 = new(Text, string.format("生命值:%d",score),width, height, align, fontName, fontSize, 255, 255, 255)
    text1:setPos(w)
    local addw,addh = text1:getSize()
    w = w + addw
    node:addChild(text1)
    if change > 0 then
        local text2 = new(Text, string.format("(+%d)",change),width, height, align, fontName, fontSize, 255, 220, 75)
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
        local text2 = new(Text, string.format("(%d)",change),width, height, align, fontName, fontSize, 200, 25, 25)
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

function MatchResultDialog:setMyRankChange(rank,change)
    local rankView = self.mMyResultBg:getChildByName("rankView")
    rankView:removeAllChildren(true)
    local addView = self:getRankView(rank,change,36)
    rankView:addChild(addView)
end

function MatchResultDialog:setOtherRankChange(rank,change)
    local rankView = self.mOtherResultBg:getChildByName("rankView")
    rankView:removeAllChildren(true)
    local addView = self:getRankView(rank,change,26)
    rankView:addChild(addView)
end

function MatchResultDialog:getRankView(rank,change,fontSize)
    local node = new(Node)
    local w = 0;
    local text1 = new(Text, string.format("排名:"),width, height, align, fontName, fontSize, 255, 255, 255)
    text1:setPos(w)
    local addw,addh = text1:getSize()
    w = w + addw
    node:addChild(text1)
    if change < 0 then
        local text2 = new(Text, string.format("%d",rank),width, height, align, fontName, fontSize, 255, 220, 75)
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
        local text2 = new(Text, string.format("%d",rank),width, height, align, fontName, fontSize, 200, 25, 25)
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
        local text2 = new(Text, string.format("%d",rank),width, height, align, fontName, fontSize, 255, 255, 255)
        text2:setPos(w)
        local addw,addh = text2:getSize()
        w = w + addw
        node:addChild(text2)
    end
    return node
end

function MatchResultDialog:onHttpCallBack(command,isSuccess,message)
    if command == HttpModule.s_cmds.MatchRank2 then
        self:stopRefreshAnim()
        if HttpModule.explainPHPMessage(isSuccess,message,"拉取排名失败") then return end
        local msg = json.analyzeJsonNode(message)
        if msg.data and type(msg.data) == "table" then
            self:initList(msg.data.list)
--            self:initMyRank(msg.data.me)
        end
    end
end

function MatchResultDialog:startRefreshAnim()
    self:stopRefreshAnim()
    self.mLoadingAnimIcon:setVisible(true)
    self.mLoadingAnim = AnimFactory.createAnimInt(kAnimLoop, 0, 1, 200, -1)
    local index = 0
    self.mLoadingAnim:setEvent(self,function()
        self.mLoadingAnimIcon:removeProp(1)
        self.mLoadingAnimIcon:addPropRotateSolid(1,45*index,kCenterDrawing)
        index = ( index + 1 ) % 8
    end)
end

function MatchResultDialog:stopRefreshAnim()
    self.mLoadingAnimIcon:setVisible(false)
    self.mLoadingAnimIcon:removeProp(1)
    delete(self.mLoadingAnim)
end

function MatchResultDialog:setMatchId(matchId)
    self.mMatchId = matchId;
end
require(VIEW_PATH .. "match_result_rank_item")
function MatchResultDialog:initList(list)
    self.mRankScrollView:removeAllChildren(true)
    for _,data in ipairs(list) do
        local view = SceneLoader.load(match_result_rank_item)
        self.mRankScrollView:addChild(view)
        local rank_icon = view:getChildByName("rank_icon")
        local head_bg = view:getChildByName("head_bg")
        local level_icon = head_bg:getChildByName("level_icon")
        level_icon:setLevel(3)
        local vip = head_bg:getChildByName("vip")
        vip:setLevel(2)
        local mask = new(Mask,UserInfo.DEFAULT_ICON[1], "common/background/head_mask_bg_46.png")
        mask:setSize(68,68);
        head_bg:addChild(mask)
        local life = view:getChildByName("life")
        local name = view:getChildByName("name")
        life:setText("生命值:" .. (data.match_score or "...")) 
        local addView = nil
        if tonumber(data.rank) then
            if tonumber(data.rank) == 0 then
                addView = new(Text,"未上榜", width, height, align, fontName, 24, 80,80,80)
            elseif tonumber(data.rank) <= 3 and tonumber(data.rank) >= 1 then
                addView = new(Image, string.format("rank/rank_medal%d.png",data.rank))
                local w,h = addView:getSize()
                addView:setSize(w*2/3,h*2/3)
            else
                addView = new(Text,data.rank, width, height, align, fontName, 24, 80,80,80)
            end
        else
            addView = new(Text,data.rank, width, height, align, fontName, 24, 80,80,80)
        end
        addView:setAlign(kAlignCenter)
        rank_icon:addChild(addView)

        if tonumber(data.iconType) == -1 then
            mask:setUrlImage(data.icon_url)
        else
            local icon = tonumber(data.iconType) or 1
            mask:setFile(UserInfo.DEFAULT_ICON[icon] or UserInfo.DEFAULT_ICON[1])
        end
        name:setText(data.mnick or "博雅象棋")
        local frameRes = UserSetInfo.getInstance():getFrameRes(data.my_set);
        vip:setVisible(false)
        if not frameRes then return end
        vip:setVisible(frameRes.visible);
        if frameRes.frame_res then
            vip:setFile(string.format(frameRes.frame_res,70));
        end

        level_icon:setFile( string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevelByScore(data.score)))
    end
end

function MatchResultDialog:setDrawView()
    self.mResultIconView:removeAllChildren(true)
    local animView = new(AnimWin);
    animView:setAlign(kAlignTop);
    animView:setDraw("animation/draw.png");
    self.mResultIconView:addChild(animView);
    animView:play();  
end;

function MatchResultDialog:setWinView()
    self.mResultIconView:removeAllChildren(true)
    local animView = new(AnimWin);
    animView:setAlign(kAlignTop);
--    if animView.m_win_clip then
--        local w,h = animView.m_win_shine:getSize()
--        animView.m_win_clip:setClip(-w/2,-h/2,w,h-110)
--    end
    self.mResultIconView:addChild(animView);
    animView:play();  
end

function MatchResultDialog:setLoseView()
    self.mResultIconView:removeAllChildren(true)
    local animView = new(AnimLose);
    animView:setAlign(kAlignTop);
    self.mResultIconView:addChild(animView);
    animView:play();  
end


function MatchResultDialog:httpEventCallBack(cmd,isSuccess,message)
    if cmd == HttpModule.s_cmds.MatchGetRebuyMoney then
        local msg = self.mCountDownBtn:getChildByName("msg")
        if HttpModule.explainPHPMessage(isSuccess,message,"复活提示文本拉取失败") then
            msg:setText("拉取数据失败")
            return
        end
        msg:setText(message.data.tip_text:get_value())
    end
end