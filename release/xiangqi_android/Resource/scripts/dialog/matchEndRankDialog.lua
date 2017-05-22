require(VIEW_PATH .. "match_end_rank_dialog_view")

MatchEndRankDialog = class(ChessDialogScene,false)

function MatchEndRankDialog:ctor()
    super(self,match_end_rank_dialog_view)
    self.mBg            = self.m_root:getChildByName("bg")
    self.mRankList      = self.mBg:getChildByName("rank_list")

    
    local w,h = self.mRankList:getSize();
    self.mDownRefreshView = new(DownRefreshView,0,0,w,h);
    self.mDownRefreshView:setRefreshListener(self,self.getRankList);
    self.mRankList:addChild(self.mDownRefreshView);
    self.mTitle         = self.m_root:getChildByName("title")
    self.mMyRankView    = self.mBg:getChildByName("my_rank_view")
    self.mTips          = self.mBg:getChildByName("tips")
    self.mLoadingAnimIcon   = self.mBg:getChildByName("loading_anim")
    self.mTips:setVisible(false)
    self.mLoadingAnimIcon:setVisible(false)
    self:setShieldClick(self,self.cancel)
    self:setNeedBackEvent(false)
    self.mBg:setEventTouch(self,function()end)
end

function MatchEndRankDialog:dtor()
    self:stopRefreshAnim()
    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpCallBack)
    self:stopRankStatusTimer()
end

function MatchEndRankDialog:show()
    self.super.show(self)
    self:getRankList()
    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpCallBack)
end

function MatchEndRankDialog:dismiss()
    self.super.dismiss(self)
    self:stopRefreshAnim()
    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpCallBack)
    self:stopRankStatusTimer()
end

function MatchEndRankDialog:onHttpCallBack(command,isSuccess,message)
    if command == HttpModule.s_cmds.MatchRank then
        self:stopRefreshAnim()
        if HttpModule.explainPHPMessage(isSuccess,message,"拉取排名失败") then
            self:initList({})
            return 
        end
        local msg = json.analyzeJsonNode(message)
        if msg.data and type(msg.data) == "table" then
            self:initList(msg.data.list)
            self:initMyRank(msg.data.me)
        end
    end
end

function MatchEndRankDialog:setMatchOver(isMatchOver,title)
    local msg = title or self.mTitle:getText()
    self.mTitle:setText(msg)
end

function MatchEndRankDialog:getRankList()
    local params = {}
    params.param = {}
    params.param.match_id= self.mMatchId
    params.param.rank_num = 30
    HttpModule.getInstance():execute(HttpModule.s_cmds.MatchRank,params);
    self:startRefreshAnim()
end


function MatchEndRankDialog:startRefreshAnim()
    self:stopRefreshAnim()
    self.mLoadingAnimIcon:setVisible(true)
    self.mTips:setVisible(false)
    self.mLoadingAnim = AnimFactory.createAnimInt(kAnimLoop, 0, 1, 200, -1)
    local index = 0
    self.mLoadingAnim:setEvent(self,function()
        self.mLoadingAnimIcon:removeProp(1)
        self.mLoadingAnimIcon:addPropRotateSolid(1,45*index,kCenterDrawing)
        index = ( index + 1 ) % 8
    end)
end

function MatchEndRankDialog:stopRefreshAnim()
    self.mLoadingAnimIcon:setVisible(false)
    self.mLoadingAnimIcon:removeProp(1)
    delete(self.mLoadingAnim)
end

function MatchEndRankDialog:setMatchId(matchId)
    self.mMatchId = matchId;
end

function MatchEndRankDialog:initList(data)
    if data and type(data) == "table" and #data > 0 then
        local params = {}
        for _,v in ipairs(data) do
            local param = {}
            param.data = v
            param.trackClickEventFunc = self.onTrackClick
            param.trackClickEventObj = self
            table.insert(params,param)
        end

        
        self.mDownRefreshView:refreshEnd(params,function(itemData)
            return new(MatchEndRankDialogItem,itemData)
        end)
        self.mTips:setVisible(false)
        self:startRankStatusTimer(data)
    else
        self.mDownRefreshView:refreshEnd({},function(itemData)
            return new(MatchEndRankDialogItem,itemData)
        end)
        self.mTips:setVisible(true)
        self:stopRankStatusTimer()
    end
end


function MatchEndRankDialog:startRankStatusTimer(datas)
	local array = {}
	for _, v in ipairs(datas.list or {}) do
		table.insert(array, v.mid)
	end
    self:stopRankStatusTimer()
    self.mRankStatusTimer = AnimFactory.createAnimInt(kAnimLoop,0,1,5000,-1)
    self.mRankStatusTimer:setEvent(self,function()
        FriendsData.getInstance():sendCheckUserStatus(array)
    end)
end

function MatchEndRankDialog:stopRankStatusTimer()
    delete(self.mRankStatusTimer)
end


function MatchEndRankDialog:initMyRank(data)
    if not self.mMyRankItem then
        local param = {}
        param.data = data
        param.trackClickEventFunc = self.onTrackClick
        param.trackClickEventObj = self
        self.mMyRankItem = new(MatchEndRankDialogItem,param)
        self.mMyRankView:addChild(self.mMyRankItem)
        return
    end
    self.mMyRankItem:refresh(data)
    self.mMyRankItem:setHeadIconSize(70,70)
    self.mMyRankItem:setUseBg(false)
end

function MatchEndRankDialog:onTrackClick(status)
    if type(self.mTrackClickEventFunc) == "function" then
        self.mTrackClickEventFunc(self.mTrackClickEventObj,status.matchId,status.tid)
    end
end

function MatchEndRankDialog:setTrackClickEvent(obj,func)
    self.mTrackClickEventFunc = func
    self.mTrackClickEventObj = obj
end


function MatchEndRankDialog:cancel()
    if self.mCancelClickTime and os.time() - self.mCancelClickTime < 1 then return end
    if type(self.mCancelEventFunc) == "function" then
        self.mCancelEventFunc(self.mCancelEventObj)
    end
    self.MatchEndDialog = os.time()
end

function MatchEndRankDialog:setCancelEvent(obj,func)
    self.mCancelEventObj = obj;
    self.mCancelEventFunc = func;
end

--[Comment]
--更新界面
function MatchEndRankDialog.onEvenCall(self,cmd,userInfoTab)
    if cmd == kFriend_UpdateUserData then
        for _,userInfo in ipairs(userInfoTab) do
            if userInfo.mid == self.mData.mid then
                self:updateUserView(userInfo)
                break;
            end
        end
    end
end
require(VIEW_PATH .. "match_end_rank_dialog_item")

MatchEndRankDialogItem = class(Node)

MatchEndRankDialogItem.ctor = function( self, params )
    self.mParams = params
	self:loadView()
	self:initControl()
	self:refresh(params.data)
    EventDispatcher.getInstance():register(Event.Call,self,self.onEvenCall)
end

MatchEndRankDialogItem.dtor = function( self )
	-- body
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onEvenCall)
end

MatchEndRankDialogItem.loadView = function( self )
	self.root_view = SceneLoader.load(match_end_rank_dialog_item)
	self.root_view:setAlign(kAlignCenter)
	self:addChild(self.root_view)
	self:setSize(self.root_view:getSize())
end

MatchEndRankDialogItem.initControl = function( self )
    self.mRankView = self.root_view:getChildByName("rank_view")
    self.mHeadView = self.root_view:getChildByName("btn_head")
    self.mMyBg = self.root_view:getChildByName("my_bg")
    self.mHeadView:setPickable(false)
	self.mHeadView:setOnClick(self, self.onHeadClick)
    self.mHeadBg = self.mHeadView:getChildByName("head_bg")
    self.mLevelIcon   = self.mHeadBg:getChildByName("level")
    self.mLevelIcon:setLevel(3)
    self.mVip   = self.mHeadBg:getChildByName("vip")
    self.mVip:setLevel(2)
    self.mVip:setVisible(false)
    self.mMask   = new(Mask,UserInfo.DEFAULT_ICON[1], "common/background/head_mask_bg_46.png")
    self.mHeadBg:addChild(self.mMask)
    self.mMask:setSize(70,70);
    self.mName = self.root_view:getChildByName("txt_name")
    self.mLife = self.root_view:getChildByName("txt_life")
	self.mBtnFollow = self.root_view:getChildByName("btn_follow")
	self.mBtnTrack = self.root_view:getChildByName("btn_track")
	self.mBtnFollow:setOnClick(self, self.onFollowClick)
	self.mBtnTrack:setOnClick(self, self.onTrackClick)
    self.mBtnFollow:setVisible(false)
    self.mBtnTrack:setVisible(false)
end

function MatchEndRankDialogItem:refresh(data)
    self.mUserBg = true
    self.mData = data
    self.mUid = data.mid
    self.mLife:setText(data.match_score or "...") 
    self.mRankView:removeAllChildren(true)
    local addView = nil
    if tonumber(data.rank) then
        if tonumber(data.rank) == 0 then
            addView = new(Text,"未上榜", width, height, align, fontName, 24, 80,80,80)
        elseif tonumber(data.rank) <= 3 and tonumber(data.rank) >= 1 then
            addView = new(Image, string.format("rank/rank_medal%d.png",data.rank))
            self.mMask:setSize(70,70)
            self.mHeadBg:setSize(70,70)
        else
            addView = new(Text,data.rank, width, height, align, fontName, 24, 80,80,80)
            self.mMask:setSize(50,50)
            self.mHeadBg:setSize(50,50)
        end
    else
        addView = new(Text,data.rank, width, height, align, fontName, 24, 80,80,80)
        self.mMask:setSize(50,50)
        self.mHeadBg:setSize(50,50)
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

    local relationBtn = self.mBtnFollow
    local trackBtn = self.mBtnTrack
    if self.mUid == UserInfo.getInstance():getUid() then
        self.mMyBg:setVisible(self.mUserBg)
        relationBtn:setVisible(false)
        trackBtn:setVisible(false)
    else
        self.mMyBg:setVisible(false)
    end

    local frameRes = UserSetInfo.getInstance():getFrameRes(data.my_set);
    self.mVip:setVisible(false)
    if not frameRes then return end
    self.mVip:setVisible(frameRes.visible);
    if frameRes.frame_res then
        self.mVip:setFile(string.format(frameRes.frame_res,70));
    end
end

-- btn event ---------------------------------------
MatchEndRankDialogItem.onHeadClick = function( self )
	-- body
end

-- 关注
MatchEndRankDialogItem.onFollowClick = function( self )
	-- body
    local info = {};
    info.uid = UserInfo.getInstance():getUid();
    info.target_uid = self.mUid;
    info.op = 1;
    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_ADD_FLLOW,info);
end

-- 追踪
function MatchEndRankDialogItem:onTrackClick()
	-- body
    if type(self.mParams.trackClickEventFunc) == "function" and self.mStatus then
        self.mParams.trackClickEventFunc(self.mParams.trackClickEventObj,self.mStatus)
    end
end

function MatchEndRankDialogItem:setHeadIconSize(w,h)
    self.mMask:setSize(w,h)
    self.mHeadBg:setSize(w,h)
end

function MatchEndRankDialogItem:setUseBg(flag)
    self.mUserBg = flag
    self.mMyBg:setVisible(self.mMyBg:getVisible() and self.mUserBg)
end

--[Comment]
--更新界面
function MatchEndRankDialogItem.onEvenCall(self,cmd,...)
    if cmd == kFriend_UpdateStatus then
        local statusTab = unpack({...})
        for _,status in ipairs(statusTab) do
            if self.mUid == status.uid then
                self:setRelation(status)
            end
        end
    end
end

function MatchEndRankDialogItem:setRelation(status)
    if not self.mBtnFollow or not self.mBtnTrack then return end
    self.mStatus = status
    local relationBtn = self.mBtnFollow
    local trackBtn = self.mBtnTrack
    if status.uid == UserInfo.getInstance():getUid() then
        return
    end

    if status.relation == 0 or status.relation == 1 then
        relationBtn:setVisible(true)
        trackBtn:setVisible(false)
    else
        relationBtn:setVisible(false)
        trackBtn:setVisible(true)
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
end

