require(VIEW_PATH .. "arena_rank_dialog_view");
require(BASE_PATH.."chessDialogScene");

ArenaRankDialog = class(ChessDialogScene,false);

require("chess/include/downRefreshView");
function ArenaRankDialog.ctor(self)
    super(self,arena_rank_dialog_view);
    self.mCloseBtn = self.m_root:getChildByName("close_btn");
    self.mCloseBtn:setOnClick(self,self.dismiss)

    self.mBg = self.m_root:getChildByName("bg");
    self.mBg:setEventDrag(self,function()end);
    self.mBg:setEventTouch(self,function()end);

    
    self.mInviteBtn = self.mBg:getChildByName("invite_btn");
    self.mInviteBtn:setOnClick(self,self.onInviteBtnClick)

    local func = function(view,enable)
        if view then
            local txt = view:getChildByName("txt");
            local horn = view:getChildByName("horn");
            if txt then
                if enable then
                    txt:setColor(125,80,65);
                else
                    txt:setColor(255,255,255);
                end
            end
            if horn then
                horn:setVisible(not enable)
            end
        end
    end

    self.mLeftTabBtn = self.mBg:getChildByName("left_tab_btn");
    self.mRightTabBtn = self.mBg:getChildByName("right_tab_btn");
    self.mLeftTabBtn:setOnTuchProcess(self.mLeftTabBtn,func);
    self.mRightTabBtn:setOnTuchProcess(self.mRightTabBtn,func);
    
    self.mLeftHandler   = self.mBg:getChildByName("left_handler");
    self.mRightHandler  = self.mBg:getChildByName("right_handler");

    self.mLeftMeItems = new(ArenaRankDialogItem,true);
    self.mLeftMeItems:setAlign(kAlignBottom);
    local w,h = self.mLeftMeItems:getSize();
    self.mLeftMeItems:setPos(0,-h);
    self.mLeftHandler:addChild(self.mLeftMeItems);
    self.mRightMeItems = new(ArenaRankDialogItem,true);
    self.mRightMeItems:setAlign(kAlignBottom);
    local w,h = self.mRightMeItems:getSize();
    self.mRightMeItems:setPos(0,-h);
    self.mRightHandler:addChild(self.mRightMeItems);


    self.mLeftHandlerAnim = self.mLeftHandler:getChildByName("load_anim");
    self.mRightHandlerAnim = self.mRightHandler:getChildByName("load_anim");
    self.mLeftHandlerAnim:setLevel(1);
    self.mRightHandlerAnim:setLevel(2);
    local w,h = self.mLeftHandler:getSize();
    self.mLeftDownRefreshView = new(DownRefreshView,0,0,w,h);
    self.mLeftDownRefreshView:setRefreshListener(self,self.resetCurRank);
    self.mLeftHandler:addChild(self.mLeftDownRefreshView);
    local w,h = self.mRightHandler:getSize();
    self.mRightDownRefreshView = new(DownRefreshView,0,0,w,h);
    self.mRightDownRefreshView:setRefreshListener(self,self.resetPreRank);
    self.mRightHandler:addChild(self.mRightDownRefreshView);
    
    self.mRuleBtn = self.mBg:getChildByName("rule_btn");
    self.mRuleDisBtn = self.mBg:getChildByName("rule_dis_btn");
    self.mRuleBg = self.mRuleDisBtn:getChildByName("rule_bg");
    self.mRuleContentView = self.mRuleBg:getChildByName("content_view");
    self.mRuleLoadAnim = self.mRuleBg:getChildByName("load_anim");

    self.mLeftTabBtn:setOnClick(self,function()
        self.mLeftTabBtn:setEnable(false);
        self.mRightTabBtn:setEnable(true);
        self.mLeftHandler:setVisible(true);
        self.mRightHandler:setVisible(false);
    end)

    self.mRightTabBtn:setOnClick(self,function()
        self.mRightTabBtn:setEnable(false);
        self.mLeftTabBtn:setEnable(true);
        self.mLeftHandler:setVisible(false);
        self.mRightHandler:setVisible(true);
    end)

    self.mRuleDisBtn:setOnClick(self,function()
            self.mRuleDisBtn:setVisible(false);
        end);

    self.mRuleBtn:setOnClick(self,function()
        self.mRuleDisBtn:setVisible(not self.mRuleDisBtn:getVisible());
    end)
    self.mRuleDisBtn:setVisible(false);

    self:setShieldClick(self,function()
        if self.mRuleDisBtn:getVisible() then
            self.mRuleDisBtn:setVisible(false)
            return;
        end
        self:dismiss();
    end);
    self.mDismiss = true
end

function ArenaRankDialog.dtor(self)
    delete(self.mLoadAnim);
    self.mLoadAnim = nil;
    delete(self.commonShareDialog)
end

function ArenaRankDialog:onInviteBtnClick()
    local tab = {}
    tab.url = SchemesProxy.getWebSchemesUrl({})
    tab.title = "对弈获胜可以赢话费，快来加入吧";
    tab.description = "博雅象棋竞技场火热开场，对局可赢话费，下棋赢钱两不误";
    if not self.commonShareDialog then
        self.commonShareDialog = new(CommonShareDialog);
    end
    self.commonShareDialog:setShareDate(tab,"arena_share");
    self.commonShareDialog:show();
    self:dismiss()
end

function ArenaRankDialog.getVisible(self)
    return not self.mDismiss;
end

function ArenaRankDialog.show(self,isNotRefresh)
    self.super.show(self,false)
    if not self.mDismiss then return end
    self.mDismiss = false;
    self:setVisible(true);
    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);

    local x,y = self.mBg:getPos();
    local w,h = self.mBg:getSize();
    local duration = 300;
    local delay = -1;
    self.mBg:removeProp(1);
    self.mBg:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, -y-h, 0);
    
    self.m_root:removeProp(1);
    local anim = self.m_root:addPropTransparency(1, kAnimNormal, duration, delay, 0, 1);
    anim:setEvent(self,function()
            if not isNotRefresh then
                self:resetCurRank();
                self:resetPreRank();
                self:getRuleText();
            end
        end)
    delete(self.mLoadAnim);
    self.mLoadAnim = nil;
    self.mLoadAnim = AnimFactory.createAnimInt(kAnimLoop, 0, 1, 100, -1);
    self.mLoadAnim:setEvent(self,self.loadingEvent)
    self.mRuleLoadIndex = 0
    if not isNotRefresh then
        self:reset();
    end
end

function ArenaRankDialog.dismiss(self)
    self.super.dismiss(self,false)
    if self.mDismiss then return end
    self.mDismiss = true;
    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpRequestsCallBack);

    local x,y = self.mBg:getPos();
    local w,h = self.mBg:getSize();
    local duration = 300;
    local delay = -1;

    self.mBg:removeProp(1);
    local anim = self.mBg:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, 0, -y-h);

    self.m_root:removeProp(1);
    self.m_root:addPropTransparency(1, kAnimNormal, duration, delay, 1, 0);

    anim:setEvent(self,function()
            self:setVisible(false);
            delete(self.mLoadAnim);
            self.mLoadAnim = nil;
        end)

end

function ArenaRankDialog.reset(self)
    self.mLeftTabBtn:setEnable(false);
    self.mRightTabBtn:setEnable(true);
    self.mRuleDisBtn:setVisible(false);
    self.mLeftHandler:setVisible(true);
    self.mRightHandler:setVisible(false);
end

function ArenaRankDialog.getRuleText(self)
    self.mRuleLoadAnim:setVisible(false);
    if self.mRuleText then return end
    self.mRuleLoadAnim:setVisible(true);
    
    local param = {}
    param.param = {}
    param.param.help_key = "ArenaRankDialog"
    HttpModule.getInstance():execute(HttpModule.s_cmds.IndexGameHelp,param)
end

function ArenaRankDialog.resetCurRank(self)

    self.mLeftHandlerAnim:setVisible(true);
    self.mLeftHandler:getChildByName("tips"):setVisible(false);
    HttpModule.getInstance():execute(HttpModule.s_cmds.ArenaGetCurrentRank)
end

function ArenaRankDialog.resetPreRank(self)

    self.mRightHandlerAnim:setVisible(true);
    self.mRightHandler:getChildByName("tips"):setVisible(false);
    HttpModule.getInstance():execute(HttpModule.s_cmds.ArenaGetPrevRank)
end

function ArenaRankDialog.setRuleContext(self,str)
    if type(str) ~= "string" then str = "#c7D5041每周结算一次竞技场战绩并根据战绩发放奖励。奖励将会在三个工作日内完成发放。#l #l结算时间：#l#n   每天开场时间为 #c19732D09:00—22:00#l#n   每周日 #c19732D22:00#n 关闭统计进行结算。#l#n   每周一 #c19732D09:00#n 开启新一轮的累计。#l #l#c7D5041排名方式：#l#n   仅竞技场内的对弈计入统计，按照场次内获得的总奖杯数进行排名，获得奖杯数越多，越有机会获得棋魂大奖。 奖杯数相同时，优先高高胜率的棋友。奖杯数每周清空。#l #l#c7D5041奖励说明：#l#n   第 1 名奖励 #c19732D10,000#n 棋魂(价值100元)#l#n   第 2 名奖励  #c19732D5,000#n 棋魂(价值50元)#l#n   第 3 名奖励  #c19732D2,000#n 棋魂(价值20元)#l#n   第4~10名奖励 #c19732D1,000#n 棋魂#l#n   第11~50名奖励  ##c19732D300#n 棋魂#l#n   第51~100名奖励 ##c19732D100#n 棋魂#l#n"; end
    self.mRuleContentView:removeAllChildren(true);
    local width, height = self.mRuleContentView:getSize();
    self.mRuleText = new(RichText,str, width, 0, kAlignTopLeft, fontName, 28, 80, 80, 80, true,10)
    self.mRuleContentView:addChild(self.mRuleText);
end

function ArenaRankDialog.loadingEvent(self)
    self.mRuleLoadIndex = self.mRuleLoadIndex%8;

    if self.mRuleLoadAnim and self.mRuleLoadAnim:getVisible() then
        self.mRuleLoadAnim:setFile( string.format("animation/loading%d.png",self.mRuleLoadIndex+1));
    end

    if self.mLeftHandlerAnim and self.mLeftHandlerAnim:getVisible() then
        self.mLeftHandlerAnim:setFile( string.format("animation/loading%d.png",self.mRuleLoadIndex+1));
    end

    if self.mRightHandlerAnim and self.mRightHandlerAnim:getVisible() then
        self.mRightHandlerAnim:setFile( string.format("animation/loading%d.png",self.mRuleLoadIndex+1));
    end

    self.mRuleLoadIndex = self.mRuleLoadIndex + 1;
end

function ArenaRankDialog.onHttpRequestsCallBack(self,command,...)
	Log.i("ChessController.onHttpRequestsCallBack");
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self,...);
	end 
end

function ArenaRankDialog.onArenaGetCurrentRank(self,isSuccess,message)
    self.mLeftHandlerAnim:setVisible(false);
    if not isSuccess then
        ChessToastManager.getInstance():showSingle("刷新失败");
        self.mLeftDownRefreshView:refreshEnd();
        return 
    end

    local data = json.analyzeJsonNode(message.data);
    if not data then 
        ChessToastManager.getInstance():showSingle("刷新失败");
        self.mLeftDownRefreshView:refreshEnd();
        return 
    end
    local list = data.list;
    local me = data.me;
    if type(list) ~= "table" or #list == 0 then
        self.mLeftHandler:getChildByName("tips"):setVisible(true);
    else
        self.mLeftHandler:getChildByName("tips"):setVisible(false);
    end
    self.mLeftDownRefreshView:refreshEnd(list,function(data)
            local item = new(ArenaRankDialogItem);
            item:setData(data);
            item:setShowType(false);
            return item;
        end);
    if not me or not me.mid then
        me = {};
        me.mid      = UserInfo.getInstance():getUid();
        me.score    = UserInfo.getInstance():getScore();
        me.mnick    = UserInfo.getInstance():getName();
        me.icon_url = UserInfo.getInstance():getIcon();
        me.iconType = UserInfo.getInstance():getIconType();
        me.rank     = 0;
        me.prize_soul = 0;
        me.arena_score = 0;
    end
    self.mLeftMeItems:setData(me);
    self.mLeftMeItems:setShowType(false);
end

function ArenaRankDialog.onArenaGetPrevRank(self,isSuccess,message)
    self.mRightHandlerAnim:setVisible(false);
    if not isSuccess then
        ChessToastManager.getInstance():showSingle("刷新失败");
        self.mRightDownRefreshView:refreshEnd();
        return 
    end
    local data = json.analyzeJsonNode(message.data);
    if not data then 
        ChessToastManager.getInstance():showSingle("刷新失败");
        self.mRightDownRefreshView:refreshEnd();
        return 
    end
    local list = data.list;
    local me = data.me;
    if type(list) ~= "table" or #list == 0 then
        self.mRightHandler:getChildByName("tips"):setVisible(true);
    else
        self.mRightHandler:getChildByName("tips"):setVisible(false);
    end
    self.mRightDownRefreshView:refreshEnd(list, function(data)
            local item = new(ArenaRankDialogItem);
            item:setData(data);
            item:setShowType(true);
            return item;
        end);
    if not me or not me.mid then
        me = {};
        me.mid      = UserInfo.getInstance():getUid();
        me.score    = UserInfo.getInstance():getScore();
        me.mnick    = UserInfo.getInstance():getName();
        me.icon_url = UserInfo.getInstance():getIcon();
        me.iconType = UserInfo.getInstance():getIconType();
        me.rank     = 0;
        me.prize_soul = 0;
        me.arena_score = 0;
    end
    self.mRightMeItems:setData(me);
    self.mRightMeItems:setShowType(true);
end

function ArenaRankDialog.onArenaGetRuleText(self,isSuccess,message)
    self.mRuleLoadAnim:setVisible(false);
    if not isSuccess then
        ChessToastManager.getInstance():showSingle("获取失败");
        return 
    end
    local help_text = message.data.help_text:get_value()
    self:setRuleContext(help_text);
end

ArenaRankDialog.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.ArenaGetCurrentRank] = ArenaRankDialog.onArenaGetCurrentRank;
    [HttpModule.s_cmds.ArenaGetPrevRank]    = ArenaRankDialog.onArenaGetPrevRank;
    [HttpModule.s_cmds.IndexGameHelp]       = ArenaRankDialog.onArenaGetRuleText;
};


ArenaRankDialogItem = class(Node)

require(VIEW_PATH .. "arena_rank_dialog_item");
function ArenaRankDialogItem.ctor(self,isMe)
    self.mScene = SceneLoader.load(arena_rank_dialog_item)
    self:addChild(self.mScene);
    local w,h = self.mScene:getSize();
    self:setSize(w,h);
    self.mBg = self.mScene:getChildByName("bg");
    self.mRankIcon = self.mScene:getChildByName("rank_icon");
    self.mHeadView = self.mScene:getChildByName("head_view");
    self.mName = self.mScene:getChildByName("name");
    self.mScore = self.mScene:getChildByName("score");
    self.mCup1 = self.mScene:getChildByName("cup1");
    self.mCup2 = self.mScene:getChildByName("cup2");
    self.mPrizeSoul = self.mScene:getChildByName("prize_soul");
    self.mClickBtn = self.mScene:getChildByName("click_btn");
    self.mClickBtn:setSrollOnClick()
    self.mClickBtn:setOnClick(self,self.onBtnClick)
    self:updateBg(isMe);
end

--[Comment]
-- 更新背景
-- isMe ： 是否是自己
function ArenaRankDialogItem.updateBg(self,isMe)
    if isMe then
        self.mBg:setVisible(true);
    else
        self.mBg:setVisible(false);
    end
end

--[Comment]
-- 初始化显示数据
-- data ： 数据
function ArenaRankDialogItem.setData(self,data)
    self.mData = data;
    local isMe = tonumber(data.mid) == UserInfo.getInstance():getUid();
    local rank = self:getRankIcon(data.rank or 0);
    rank:setAlign(kAlignCenter)
    self.mRankIcon:removeAllChildren(true);
    self.mRankIcon:addChild(rank);
    local score = data.score or 0
    local icon_url = data.icon_url or ""
    local iconType = data.iconType
    local nick = data.mnick
    if isMe then
        score = UserInfo.getInstance():getScore()
        icon_url = UserInfo.getInstance():getIcon()
        iconType = UserInfo.getInstance():getIconType()
        nick = UserInfo.getInstance():getName()
    end
    
    self:setHeadIcon(score,icon_url,iconType);
    self:setSafeName(nick,tonumber(data.mid));

    self.mScore:setText( string.format("积分:%d",data.score or 0));
    self.mCup1:setText( string.format("%d 奖杯",data.arena_score or 0));
    self.mCup2:setText( string.format("%d 奖杯",data.arena_score or 0));
    self.mPrizeSoul:setText( string.format("%d 棋魂",data.prize_soul or 0));
    self:updateBg(isMe);
end
--[Comment]
-- 更改显示模式
-- isShowSoul ： 是否显示棋魂
function ArenaRankDialogItem.setShowType(self,isShowSoul)
    if isShowSoul then
        self.mCup1:setVisible(false);
        self.mCup2:setVisible(true);
        self.mPrizeSoul:setVisible(true);
    else
        self.mCup1:setVisible(true);
        self.mCup2:setVisible(false);
        self.mPrizeSoul:setVisible(false);
    end
end
--[Comment]
-- 设置 head
-- score ： 积分
-- iconUrl ：头像url
function ArenaRankDialogItem.setHeadIcon(self,score,iconUrl,iconType)
    self.mHeadView:getChildByName("level_icon"):setFile( string.format("common/icon/level_%d.png",10 - UserInfo.getInstance():getDanGradingLevelByScore(score)));
    self.mHeadView:getChildByName("level_icon"):setLevel(1);
    if not self.mHeadIcon then
        local w,h = self.mHeadView:getSize();
        self.mHeadIcon = new(Mask,"common/background/head_bg_92.png", "common/background/head_bg_92.png")
        self.mHeadIcon:setAlign(kAlignCenter);
        self.mHeadView:addChild(self.mHeadIcon);
    end
    iconType = tonumber(iconType) or 1;
    if iconType ~= -1 then
        if iconType < 1 or iconType > 4 then iconType = 1 end
        self.mHeadIcon:setFile(UserInfo.DEFAULT_ICON[iconType]);
    else
        self.mHeadIcon:setUrlImage(iconUrl);
    end
end
--[Comment]
-- 获得排名icon
-- num ： 排名数
function ArenaRankDialogItem.getRankIcon(self,num)
    num = tonumber(num);
    if not num or num < 1 then 
        local bg = new(Image,"rank/rank_medal.png");
        local numGroup = new(Image,"rank/out_rank.png");
        numGroup:setAlign(kAlignCenter);
        bg:addChild(numGroup);
        return bg;
    end
    if num >= 1 and num <= 3 then 
        return new(Image, string.format("rank/rank_medal%d.png",num));
    end
    local numTxt = {};
    local w,h = 0, 0;
    local bg  = new(Image,"rank/rank_medal.png");
    local numGroup = new(Node);
    numGroup:setAlign(kAlignCenter);
    bg:addChild(numGroup);

    while num ~= 0 do
        local txtNum = num % 10;
        num = num - txtNum;
        num = num / 10
        local insert = new(Image,string.format("rank/number_%d.png",txtNum))
        table.insert(numTxt,1,insert);
    end

    for i,bmp in ipairs(numTxt) do
        local iW,iH = bmp:getSize();
        bmp:setAlign(kAlignLeft);
        bmp:setPos(w,0);
        numGroup:addChild(bmp);
        w = w + iW;
    end
    numGroup:setSize(w,0);
    return bg;
end

function ArenaRankDialogItem:setSafeName(name,default)
    default = default or "博雅象棋"
    local w,h = self.mName:getSize()
    if not name or name == "" then name = default end
    self.mName:setText(name,w)
    local mw = self.mName:getSize()
    local len = string.lenutf8(name)
    while mw > w and len > 0 do
        len = len - 1
        self.mName:setText( lua_string_sub(name,len) ,w)
        mw = self.mName:getSize()
    end
end

function ArenaRankDialogItem:onBtnClick()
    Log.i("ArenaRankDialogItem.onBtnClick");
    if self.mData and self.mData.mid then
--        if tonumber(self.mData.mid) == UserInfo.getInstance():getUid() then
--            StateMachine.getInstance():pushState(States.gradeModel,StateMachine.STYPE_CUSTOM_WAIT);
--        else
            StateMachine.getInstance():pushState(States.FriendsInfo,StateMachine.STYPE_CUSTOM_WAIT,nil,tonumber(self.mData.mid));
--        end
    end
end