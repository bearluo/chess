require(VIEW_PATH .. "match_rank_dialog_view")

MatchRankDialog = class(ChessDialogScene, false)

MatchRankDialog.ctor = function( self, datas )
	super(self, match_rank_dialog_view)
	self.anim_dlg = AnimDialogFactory.createNormalAnim(self)
	self.datas = datas
    self.rank_type = ""  -- 如果为空，表示取当前排名，last表示取最进结束比赛的排名
	self:initControl()
	self:initView()
end

MatchRankDialog.dtor = function( self )
	self.anim_dlg:stopAnim()
	self:stopTimer()
	delete(self.m_unsign_chioce_dialog)
    self:stopRankStatusTimer()
    delete(self.m_goto_mall_dialog)
    delete(self.m_invitcode_dialog)
    delete(self.m_chioce_dialog)
    delete(self.mRuleDialog)
    delete(self.m_up_user_info_dialog)
end

MatchRankDialog.show = function( self )
    if self:isShowing() then return end
	self.super.show(self, self.anim_dlg.showAnim)
	self:showRankView()
    self:joinChatRoom()
    EventDispatcher.getInstance():register(HttpModule.s_event, self, self.onHttpRequestsCallBack)
    OnlineSocketManagerProcesser.getInstance():register(CHATROOM_CMD_ENTER_ROOM,self,self.onJoinChatRoomCallBack)
    OnlineSocketManagerProcesser.getInstance():register(CHATROOM_CMD_LEAVE_ROOM,self,self.onLeaveChatRoomCallBack)
    OnlineSocketManagerProcesser.getInstance():register(CHATROOM_CMD_USER_CHAT_MSG,self,self.onUserChatMsgCallBack)
    OnlineSocketManagerProcesser.getInstance():register(CHATROOM_CMD_BROAdCAST_CHAT_MSG,self,self.onBroadcastChatCallBack)
    OnlineSocketManagerProcesser.getInstance():register(CHATROOM_CMD_GET_HISTORY_MSG_NEW,self,self.onGetHistoryMsgCallBack)
    EventDispatcher.getInstance():register(Event.Call,self,self.onEventResponse);
end

MatchRankDialog.dismiss = function( self )
    if not self:isShowing() then return end
	self.super.dismiss(self, self.anim_dlg.dismissAnim)
    self:stopRankStatusTimer()
    self.item_view:removeAllChildren(true)
    self:exitChatRoom()
    self:dismissMsgDialog()
	EventDispatcher.getInstance():unregister(HttpModule.s_event, self, self.onHttpRequestsCallBack)
    OnlineSocketManagerProcesser.getInstance():unregister(CHATROOM_CMD_ENTER_ROOM,self,self.onJoinChatRoomCallBack)
    OnlineSocketManagerProcesser.getInstance():unregister(CHATROOM_CMD_LEAVE_ROOM,self,self.onLeaveChatRoomCallBack)
    OnlineSocketManagerProcesser.getInstance():unregister(CHATROOM_CMD_USER_CHAT_MSG,self,self.onUserChatMsgCallBack)
    OnlineSocketManagerProcesser.getInstance():unregister(CHATROOM_CMD_BROAdCAST_CHAT_MSG,self,self.onBroadcastChatCallBack)
    OnlineSocketManagerProcesser.getInstance():unregister(CHATROOM_CMD_GET_HISTORY_MSG_NEW,self,self.onGetHistoryMsgCallBack)
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onEventResponse);
end

MatchRankDialog.initControl = function( self )
    self.m_chat_list_items = {}
	local root_view = self.m_root
	local top_view = root_view:getChildByName("top_view")
	local middle_view = root_view:getChildByName("middle_view")
	local bottom_view = root_view:getChildByName("middle_view"):getChildByName("match_view"):getChildByName("bottom_view")
    local w,h = middle_view:getSize()
    local x,y = middle_view:getAbsolutePos()
    middle_view:setClip(x,y,w,h)
	-- top
    self.img_border = root_view:getChildByName("img_border")
    self.img_content = root_view:getChildByName("img_content")
	self.txt_title = top_view:getChildByName("txt_title")
	self.btn_close = top_view:getChildByName("btn_close")
	self.btn_chat = top_view:getChildByName("btn_chat")
	self.btn_match = top_view:getChildByName("btn_match")
	self.btn_rank = top_view:getChildByName("btn_rank")
	self.txt_tchat = top_view:getChildByName("txt_tchat")
	self.txt_tmatch = top_view:getChildByName("txt_tmatch")
	self.txt_trank = top_view:getChildByName("txt_trank")
	self.img_line1 = top_view:getChildByName("img_line1")
	self.img_line2 = top_view:getChildByName("img_line2")
	self.img_line3 = top_view:getChildByName("img_line3")

	-- middle
	self.chat_view = middle_view:getChildByName("chat_view")
    self.chat_input_view = self.chat_view:getChildByName("input_view")
    local content_view = self.chat_view:getChildByName("content_view")
    local contentW,contentH = content_view:getSize();
    self.chat_content_sroll_view = new(ScrollView2,0,0,contentW,contentH,true);
    content_view:addChild(self.chat_content_sroll_view)

    self.chat_edit = self.chat_input_view:getChildByName("edit_bg"):getChildByName("edit")
    self.chat_edit:setHintText("请输入消息",140,140,140)
    self.chat_edit:setOnTextChange(self,self.sendRoomChat);
    self.chat_show_msg_dialog_btn = self.chat_input_view:getChildByName("show_msg_dialog_btn")
    self.chat_show_msg_dialog_view = self.chat_input_view:getChildByName("msg_view")
    self.chat_show_msg_dialog_bg = self.chat_input_view:getChildByName("msg_bg")
    self.chat_show_msg_dialog_btn:setOnClick(self,self.showAndDismissMsgDialog)
    local w,h = self.chat_show_msg_dialog_view:getSize()
    self.chat_book_view = new(ScrollView2,0,0,w,h,true);
    self.chat_book_view:setAlign(kAlignBottom);
    self.chat_show_msg_dialog_view:addChild(self.chat_book_view);

	self.match_view = middle_view:getChildByName("match_view")
    self.match_view_content_view = self.match_view:getChildByName("content_view")
	self.rank_view = middle_view:getChildByName("rank_view")
	self.scroll_view = self.rank_view:getChildByName("scroll_view")
	self.me_rank_view = self.rank_view:getChildByName("me_rank_view")
	self.content_view = self.scroll_view:getChildByName("content_view")
	self.item_view = self.content_view:getChildByName("item_view")
	self.empty_view = self.content_view:getChildByName("empty_view")
	local head_view = self.content_view:getChildByName("head_view")
	local scroll_top_view = self.scroll_view:getChildByName("top_view")


    -- 历史最高
	self.win3_name = scroll_top_view:getChildByName("txt_name")
	self.win3_num2 = scroll_top_view:getChildByName("txt_num2")
	self.win3_btn_head = scroll_top_view:getChildByName("btn_head")
	self.head_icon3 = new(Mask,"compete/rank_head.png","common/background/head_mask_bg_150.png")
    self.head_icon3:setAlign(kAlignCenter)
    self.head_icon3:setSize(self.win3_btn_head:getSize())
    self.win3_btn_head:addChild(self.head_icon3)
	self.head_level3 = self.win3_btn_head:getChildByName("level")
    self.head_level3:setVisible(false)
    self.head_level3:setLevel(1)

	-- bottom
	self.runing_view = bottom_view:getChildByName("runing_view")
	self.txt_run_time = self.runing_view:getChildByName("txt_run_time")
    self.runing_view:setVisible(true)
    

    -- match_view

    self.match_view_content_view_jackpot_txt = self.match_view_content_view:getChildByName("jackpot_bg"):getChildByName("jackpot_txt")
    self.match_view_content_view:getChildByName("Image3"):setColor(225,110,95)
    self.match_view_content_view:getChildByName("Image4"):setColor(225,110,95)
    self.match_info_view = self.match_view_content_view:getChildByName("match_info_view")
    self.match_rule_btn = self.match_info_view:getChildByName("match_rule_btn")
    self.match_rule_btn:setOnClick(self,self.showRuleDialog)
    self.show_sign_list_dialog_btn = self.match_view_content_view:getChildByName("show_sign_list_dialog_btn")
    self.show_sign_list_dialog_btn:setOnClick(self,self.showSignListDialog)
    self.sign_player_list = root_view:getChildByName("sign_player_list")
    self.sign_player_list:setVisible(false)
    self.sign_player_list_back_btn = self.sign_player_list:getChildByName("back_btn")
    self.sign_player_list_back_btn:setOnClick(self,self.dismissSignListDialog)
    self.sign_up_player_view = self.match_view_content_view:getChildByName("sign_up_player_view")
    self.sign_player_list_title_view = self.sign_player_list:getChildByName("sign_player_list_title_view")
    self.sign_player_listview = self.sign_player_list:getChildByName("sign_player_listview")
    local mw,mh             = self.sign_player_listview:getSize();
    self.mSignPlayerScrollView = new(SlidingLoadView, 0, 0, mw,mh, true)
    self.mSignPlayerScrollView:setOnLoad(self,function(self)
        self:requestMatchGetApplyList()
    end)
    self.mSignPlayerScrollView:setNoDataTip("嗯？暂时还没有排名");
    self.sign_player_listview:addChild(self.mSignPlayerScrollView);

    self.sign_player_list:getChildByName("bg"):setEventDrag(self,function()end);
    self.sign_player_list:getChildByName("bg"):setEventTouch(self,function()end);
    
	-- set click func
	self.btn_close:setOnClick(self, self.onCloseClick)
	self.btn_chat:setOnClick(self, self.onChatTabClick)
	self.btn_match:setOnClick(self, self.onMatchTabClick)
	self.btn_rank:setOnClick(self, self.onRankTabClick)

	-- show default view
	self.item_view:setVisible(false)
	self.empty_view:setVisible(true)
end

MatchRankDialog.initView = function( self )
	self:initMatchView()
	self:initChatView()
	self:initTipView()
end

-- 规则
MatchRankDialog.initChatView = function( self )
    --房间内常用语
	self.phrases = {
        "大家好，很高兴见到各位！",
        "谁来与我对战一局？",
        "我已经迫不及待要开始战斗了！",
        "箭在弦上，比赛一触即发！",
        "这里真是高手如云呀！",
        "不要走，我们来大战三百回合！",
        "我接受你的挑战！",
        "关注我，我们交个朋友吧！",
        "各位高手，教教我下棋吧！",
        "再见了，我要离开一会！",
    }
    self.phrases_btns = {};
    for i,v in ipairs(self.phrases) do
        self.phrases_btns[i] = new(MatchRankDialogChatPhrasesItem,v);
        self.phrases_btns[i]:setClickEvent(self,self.onPhrasesItemClick);
        if i == 1 then
            self.phrases_btns[i]:setCutlineVisible(false)
        end
        self.chat_book_view:addChild(self.phrases_btns[i]);
    end
end

-- 奖励
MatchRankDialog.initMatchView = function( self )
	local str = self.datas.prize_text[1]
	if not str or str=="" then
		str = "无配置"
	end
    self.m_rewardStr = "#s40奖励#n" .. str
--    self:refreshMatchText()

--	-- 由php拉取
--	local data = {}
--    data.param = { config_id = self.datas.id }
--	HttpModule.getInstance():execute(HttpModule.s_cmds.getMatchRule, data)

    
	local join_num = tonumber(self.datas.join_num) or 0
    local join_money = tonumber(self.datas.join_money) or 0
    local jackpot = join_num * join_money
	-- 开赛倒计时
    local postfix = ""
    if jackpot >= 100000000 then
        jackpot = jackpot / 100000000
        postfix = "亿"
    elseif jackpot >= 10000 then
        jackpot = jackpot / 10000
        postfix = "万"
    end

    local formatstr = "%d%s"
    if select(2,math.modf(jackpot)) >= 0.1 then
        formatstr = "%.1f%s"
    end

    self.match_view_content_view_jackpot_txt:setText( string.format(formatstr,jackpot,postfix) )

    -- 赛制


    -- 比赛时间
    local matchStartTime =  tonumber(self.datas.match_start_time) or 0
    local matchEndTime =  tonumber(self.datas.match_end_time) or 0
--    self.match_info_view
    local prefix = ToolKit.get_match_time_str_prefix(matchStartTime)
    local startTime = ToolKit.getDate(matchStartTime)
    local endTime = ToolKit.getDate(matchEndTime)
    local timeString = string.format("%s %02d:%02d～%02d:%02d",prefix,startTime.hour,startTime.min,endTime.hour,endTime.min)
    self.match_time_str = new(Text,timeString, width, height, align, fontName, 28, 25, 115, 45)
    local x,y = self.match_info_view:getChildByName("txt2"):getPos()
    self.match_info_view:addChild(self.match_time_str)
    self.match_time_str:setPos(x+80,y)


    -- 奖励
    local init_score = tonumber(self.datas.init_score) or 0 
    local lifePriceString = string.format("金币(%d生命值=%d金币)",init_score,join_money)
    self.match_life_price = new(Text,lifePriceString, width, height, align, fontName, 28, 25, 115, 45)
    local x,y = self.match_info_view:getChildByName("txt3"):getPos()
    self.match_info_view:addChild(self.match_life_price)
    self.match_life_price:setPos(x+80,y)

    -- 费用
    local joinMoneyString = string.format("%d金币",join_money)
    self.match_join_money = new(Text,joinMoneyString, width, height, align, fontName, 28, 25, 115, 45)
    local x,y = self.match_info_view:getChildByName("txt4"):getPos()
    self.match_info_view:addChild(self.match_join_money)
    self.match_join_money:setPos(x+80,y)

	local join_num = tonumber(self.datas.join_num) or 0
    
	local w, h = self.show_sign_list_dialog_btn:getSize()
	self.sign_player_txt = new(RichText, string.format("已报名#cc82828 %d #n人",join_num), w, h, kAlignLeft, nil, 32, 125, 80, 65, false, 16)
	self.sign_player_txt2 = new(RichText, string.format("已报名#cc82828 %d #n人",join_num), w, h, kAlignLeft, nil, 32, 125, 80, 65, false, 16)
    self.show_sign_list_dialog_btn:addChild(self.sign_player_txt)
    self.sign_player_list_title_view:addChild(self.sign_player_txt2)
    
    self.mSignUpPlayerDataList = {}
    self.mSignUpPlayerView = {}
    self.mMatchGetApplyListNoMore = false;
    self.mSignPlayerScrollView:reset()
    self.mSignPlayerScrollView:loadView();
end

function MatchRankDialog:showRuleDialog()
    if not self.mRuleDialog then
        self.mRuleDialog = new(CommonHelpDialog)
        self.mRuleDialog:setMode(CommonHelpDialog.match_rule_mode,self.datas)
    end 
    self.mRuleDialog:show()
end

function MatchRankDialog:requestMatchGetApplyList()
    if self.mMatchGetApplyListSendIng or self.mMatchGetApplyListNoMore then return end
    self.mMatchGetApplyListSendIng = true;
	local data = {}
	data.param = { match_id=self.datas.match_id, offset=#self.mSignUpPlayerDataList,limit = 10 }
	HttpModule.getInstance():execute(HttpModule.s_cmds.MatchGetApplyList, data)
end

function MatchRankDialog:updateSignUpPlayerView()
    -- 简单列表
    for i=1,8 do
        if self.mSignUpPlayerDataList[i] and not self.mSignUpPlayerView[i] then
            self.mSignUpPlayerView[i] = new(MatchRankDialogSignUpPlayer)
            self.sign_up_player_view:addChild(self.mSignUpPlayerView[i])
            local w,h = self.mSignUpPlayerView[i]:getSize()
            local index = 0
            if i <= 4 then 
                index = i-1 
                self.mSignUpPlayerView[i]:setPos(w*index,0)
            else 
                index = i - 5 
                self.mSignUpPlayerView[i]:setPos(w*index,h)
            end
            self.mSignUpPlayerView[i]:setPlayer(self.mSignUpPlayerDataList[i].mid)
        end
    end
end

-- 排名
MatchRankDialog.requestRankData = function( self )
	local data = {}
	data.param = { match_id=self.datas.match_id, rank_num=10 ,rank_type = self.rank_type }
	HttpModule.getInstance():execute(HttpModule.s_cmds.MatchRank, data)
end

MatchRankDialog.initTipView = function( self )
	-- 报名人数
	local join_num = tonumber(self.datas.join_num) or 0
	local title = self.datas.name or "比赛"
    self.txt_title:setText(title)
	-- 开赛倒计时
	self:startTimer()
end

MatchRankDialog.refreshRuleText = function( self, data )
	local str = data.rule_text:get_value()
	if not str or str=="" then
		str = "无配置"
	end
    self.m_ruleStr = "#s40规则#n" .. str
    self:refreshMatchText()
end

MatchRankDialog.refreshMatchText = function(self)
    self.m_rewardStr = self.m_rewardStr or ""
    self.m_ruleStr  = self.m_ruleStr or ""
--    local str = self.m_rewardStr .. "#l #l" .. self.m_ruleStr
--	local w, h = self.match_view_content_view:getSize()
--	local rt_match = new(RichText, str, w-80, h-60, kAlignTopLeft, nil, 30, 80, 80, 80, true, 16)
--	rt_match:setPos(40, 36)
--	self.match_view_content_view:removeAllChildren()
--	self.match_view_content_view:addChild(rt_match)
end

function MatchRankDialog:joinChatRoom()
    if self.datas and self.datas.chat_id then
        local packetInfo = {};
        packetInfo.room_id = self.datas.chat_id;
        OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_ENTER_ROOM,packetInfo);

    end
    self:clearAllChatLog()
end

function MatchRankDialog:exitChatRoom()
    if self.datas and self.datas.chat_id then
    	local info = {};
    	info.room_id = self.datas.chat_id;
    	info.uid = UserInfo.getInstance():getUid();
        OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_LEAVE_ROOM,info);
    end
end

MatchRankDialog.showChatView = function( self )
	self.curViewIndex = 1
	self:updateTitleText()
	self:showViewByIndex()
    self.img_border:setSize(nil,1043)
    self.img_content:setSize(nil,1025)
end

MatchRankDialog.showMatchView = function( self )
	self.curViewIndex = 2
	self:updateTitleText()
	self:showViewByIndex()

    self.img_border:setSize(nil,878)
    self.img_content:setSize(nil,861)
end

MatchRankDialog.showRankView = function( self )
	self.curViewIndex = 3
	self:updateTitleText()
	self:showViewByIndex()
    self.img_border:setSize(nil,1043)
    self.img_content:setSize(nil,1025)
--    if 
	self:requestRankData()
    local params = {}
    params.param = {}
    params.param.match_id = self.datas.match_id
    HttpModule.getInstance():execute(HttpModule.s_cmds.MatchGetHistory,params)
end

MatchRankDialog.updateTitleText = function( self )
	local titleMap = { self.txt_tchat, self.txt_tmatch, self.txt_trank }
	for i, title in ipairs(titleMap) do
		if self.curViewIndex == i then
			title:setColor(215, 75, 45)
		else
			title:setColor(135, 100, 95)
		end
	end
end

function MatchRankDialog:showSignListDialog()
    local w,h = self:getSize()
    self.sign_player_list:setVisible(true)
    self.sign_player_list:removeProp(1)
    self.sign_player_list:addPropTranslate(1,kAnimNormal,500,-1,w,0,nil,nil);
end

function MatchRankDialog:dismissSignListDialog()
    local w,h = self:getSize()
    self.sign_player_list:setVisible(true)
    self.sign_player_list:removeProp(1)
    self.sign_player_list:addPropTranslate(1,kAnimNormal,500,-1,0,w,nil,nil);
end

MatchRankDialog.showViewByIndex = function( self )
	if not self.curViewIndex then
		return
	end

	self.chat_view:setVisible(self.curViewIndex == 1)
	self.match_view:setVisible(self.curViewIndex == 2)
	self.rank_view:setVisible(self.curViewIndex == 3)

	self.img_line1:setVisible(self.curViewIndex == 1)
	self.img_line2:setVisible(self.curViewIndex == 2)
	self.img_line3:setVisible(self.curViewIndex == 3)
end

MatchRankDialog.updateRankHead = function( self, datas )
    local datas = datas or {}
    -- 战绩
    local rank = datas.rank or {}
    -- 人气
    local bet = datas.bet or {}
	-- 上期战绩冠军

	--历史最高战绩--later
    local max = rank.max
    if type(max) == "table" and next(max) then
	    self.win3_name:setText(max.mnick or "-")
	    self.win3_num2:setText( "生命值:" .. (max.match_score or "-"))--do
        local iconType = tonumber(max.iconType) or 0
        if iconType == -1 then
    	    self.head_icon3:setUrlImage(max.icon_url)
        else
            self.head_icon3:setFile(UserInfo.DEFAULT_ICON[iconType] or UserInfo.DEFAULT_ICON[1])
        end
        self.head_level3:setVisible(true)
        self.head_level3:setFile( string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevelByScore(max.score)) )
        self.win3_btn_head:setEventTouch(self,self.showWin3BtnUserInfo)
        self.win3_btn_head_mid = tonumber(max.mid)
    else
	    self.win3_name:setText("虚位以待")
        self.win3_num2:setText( "生命值:-")--do
        self.head_icon3:setFile("userinfo/default_head.png")
        self.head_level3:setVisible(false)
        self.win3_btn_head:setEventTouch(nil,nil)
        self.win3_btn_head_mid = nil
    end
end

function MatchRankDialog:showWin3BtnUserInfo(finger_action,x,y,drawing_id_first,drawing_id_current)
    if not self.win3_btn_head_mid then return end
    if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
     
        if self.m_up_user_info_dialog and self.m_up_user_info_dialog:isShowing() then 
            self.m_up_user_info_dialog:dismiss();
            return 
        end
        delete(self.m_up_user_info_dialog)
        self.m_up_user_info_dialog = new(UserInfoDialog2);

        if UserInfo.getInstance():getUid() == self.win3_btn_head_mid then
            self.m_up_user_info_dialog:setShowType(UserInfoDialog2.SHOW_TYPE.OTHER)
        else
            self.m_up_user_info_dialog:setShowType(UserInfoDialog2.SHOW_TYPE.UNION)
        end

        FriendsData.getInstance():sendCheckUserData(self.win3_btn_head_mid)
        self.m_up_user_info_dialog:show(nil,self.win3_btn_head_mid);
    end
end

-- 更新排名列表
MatchRankDialog.updateRankList = function( self, datas )
	if not datas or not next(datas) then
		return
	end

	-- create rank item
    self.item_view:removeAllChildren(true)
	local list = datas.list or {}
--    for i=1,200 do
--    table.insert(list,list[1])
--    end
	local height = 0
	for i, data in ipairs(list) do
		local rankItem = new(MatchRankDialogItem, data)
		rankItem:setPos(2, height)
		self.item_view:addChild(rankItem)
		local _, h = rankItem:getSize()
		height = height + h
	end

	-- adapt size
	local w, h = self.item_view:getSize()
    if height < 246 then height = 246 end  -- 保证不低于默认高度
	self.item_view:setSize(w, height)
	local cw, ch = self.content_view:getSize()
	self.content_view:setSize(cw, ch + (height-h))--?
	self.scroll_view:updateScrollView()
    local me = datas.me
    if not me then return end
    delete(self.me_rank_item)
    self.me_rank_item = new(MatchRankDialogItem,me)
    self.me_rank_item:setAlign(kAlignLeft)
    self.me_rank_view:addChild(self.me_rank_item)
end

MatchRankDialog.startRankStatusTimer = function( self, datas )
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

function MatchRankDialog:stopRankStatusTimer()
    delete(self.mRankStatusTimer)
end

MatchRankDialog.startTimer = function( self )
	delete(self.timer)
	self.timer = new(AnimInt, kAnimRepeat, 0, 1, 1000, -1)
	self.timer:setDebugName("MatchRankDialog|timer")
	self.timer:setEvent(self, function(self)
        self:updateRuningTime()
    end)
end

MatchRankDialog.updateRuningTime = function( self )
	local endTime = self.datas.match_end_time
	local diff = endTime - TimerHelper.getServerCurTime()
	if diff <= 0 then
	    local str = ToolKit.skipTime(0)
	    self.txt_run_time:setText(str)
		return
	end
	local str = ToolKit.skipTime(diff)
	self.txt_run_time:setText(str)
end

MatchRankDialog.stopTimer = function( self )
	delete(self.timer)
	self.timer = nil
end

-- btn event -----------------------------------------
-- 关闭
function MatchRankDialog:setCloseClickEvent(obj,func)
    self.mCloseClickEvent = {}
    self.mCloseClickEvent.obj = obj
    self.mCloseClickEvent.func = func
end

MatchRankDialog.onCloseClick = function( self )
	if self.mCloseClickEvent and type(self.mCloseClickEvent.func) == "function" then
        self.mCloseClickEvent.func(self.mCloseClickEvent.obj)
    end
end

-- 规则
MatchRankDialog.onChatTabClick = function( self )
	self:showChatView()
end

-- 奖励
MatchRankDialog.onMatchTabClick = function( self )
	self:showMatchView()
end

-- 排名
MatchRankDialog.onRankTabClick = function( self )
	self:showRankView()
end

MatchRankDialog.onHttpRequestsCallBack = function(self, command, ...)
	Log.i("MatchRankDialog.onHttpRequestsCallBack")
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self, ...)
	end 
end

-- callback -----------------------------------------
MatchRankDialog.onHttpGetMatchRule = function( self, isSuccess, message )
	if not isSuccess then
		return
	end

	local data = message.data or {}
--	self:refreshRuleText(data)
end

MatchRankDialog.onHttpMatchRank = function( self, isSuccess, message )
	if not isSuccess then
		return
	end

	local datas = json.analyzeJsonNode(message.data) or {}
	Log.d("onHttpMatchRank")
	Log.d(datas)

	local isEmpty = next(datas.list or {}) == nil
	self.empty_view:setVisible(isEmpty)
	self.item_view:setVisible(not isEmpty)

	self:updateRankList(datas)

	-- update rank status
	self:startRankStatusTimer(datas)
end

function MatchRankDialog:onHttpMatchGetHistory(isSuccess, message)
    if HttpModule.explainPHPMessage(isSuccess, message,"历史排名拉取失败") then return end
    local msg = json.analyzeJsonNode(message)
	self:updateRankHead(msg.data)
end

function MatchRankDialog:onHttpMatchGetApplyList(isSuccess, message)
    self.mMatchGetApplyListSendIng = false;
    if not isSuccess or message.data:get_value() == nil then
        return ;
    end
    
    local tab = json.analyzeJsonNode(message)
    local data = tab.data
    if type(data) ~= "table" or data.match_id ~= self.datas.match_id then 
        return 
    end
    local list = data.list;
    if type(list) ~= "table" or #list == 0 then
        self.mSignPlayerScrollView:loadEnd(true);
        self.mMatchGetApplyListNoMore = true;
        return ;
    end


    for i,v in pairs(data.list) do
        table.insert(self.mSignUpPlayerDataList,v)
    end

    for i,v in ipairs(data.list) do
        local item = new(MatchRankDialogSignUpPlayer2,v);
        self.mSignPlayerScrollView:addChild(item);
    end
    self.mSignPlayerScrollView:loadEnd(false);

    self:updateSignUpPlayerView()
end

function MatchRankDialog:refresh(datas)
end

MatchRankDialog.onPhrasesItemClick = function(self,item)
	local message = GameString.convert2UTF8(item:getText());
    self:sendRoomChatMsg(message);
end

--房间内聊天 item
MatchRankDialog.addChatLog = function(self,name,message,uid)
	if not message or message == "" then
		return
	end

    if FriendsData.getInstance():isInBlacklist(tonumber(uid)) then return end
	local data = {}
	data.mnick = GameString.convert2UTF8(name)
	data.msg = GameString.convert2UTF8(message)
    data.send_uid = uid
    
    Log.i("addChatLog" .. message )
    if data.send_uid and type(data.send_uid) == "number" then
        if not UserInfoDialog2.s_forbid_id_list[data.send_uid] then
	        local item = new(MatchRankDialogChatLogItem,data)
            if self.chat_content_sroll_view:isScrollToBottom() then
                self.chat_content_sroll_view:addChild(item)
                self.chat_content_sroll_view:gotoBottom()
            else
                self.chat_content_sroll_view:addChild(item)
                local _,h = self.chat_content_sroll_view:getMainNodeWH()
                self.chat_content_sroll_view:gotoOffset(h)
            end
            table.insert(self.m_chat_list_items,item)
        end
    end
end

function MatchRankDialog:clearAllChatLog()
    self.chat_content_sroll_view:removeAllChildren(true)
    self.m_chat_list_items = {}
end

function MatchRankDialog:showAndDismissMsgDialog()
    if self.chat_input_view:checkAddProp(1) then
        self:showMsgDialog()
    else
        self:dismissMsgDialog()
    end
end

function MatchRankDialog:showMsgDialog()
    local w,h = self.chat_show_msg_dialog_view:getSize()
    self.chat_show_msg_dialog_bg:setSize(nil,480)
    self.chat_input_view:removeProp(2);
    --常用语上滑动画
    self.chat_input_view:addPropTranslate(1, kAnimNormal, 100, -1, 0, 0, 0, -h);
end

function MatchRankDialog:dismissMsgDialog()
    if self.chat_input_view:checkAddProp(1) then return end
    local w,h = self.chat_show_msg_dialog_view:getSize()
    self.chat_show_msg_dialog_bg:setSize(nil,80)
    self.chat_input_view:removeProp(1);
    --常用语上滑动画
    self.chat_input_view:addPropTranslate(2, kAnimNormal, 100, -1, 0, 0, -h, 0);
end

function MatchRankDialog:sendRoomChat()
    local message = GameString.convert2UTF8(self.chat_edit:getText())
	if not message or message == "" or message == "" then
        ChessToastManager.getInstance():showSingle("消息不能为空！",800)
		return
	end
    local lens = string.lenutf8(GameString.convert2UTF8(message) or "")   
    if lens > 60 then--限制60字
        ChessToastManager.getInstance():showSingle("消息不能超过60字！",800)
		return      
    end
    self:sendRoomChatMsg(message)
    self.chat_edit:setText(nil)
end


function MatchRankDialog:sendRoomChatMsg(message)
    if self.datas.me_status == 1 then
        ChessToastManager.getInstance():showSingle("只有报名玩家才能聊天")
        return 
    end
	local msgdata = {};
	msgdata.room_id = self.datas.chat_id;
	msgdata.msg = message;
	msgdata.name = UserInfo.getInstance():getName();
	msgdata.uid = UserInfo.getInstance():getUid();
    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_USER_CHAT_MSG,msgdata);
    self:dismissMsgDialog()
end


function MatchRankDialog:onJoinChatRoomCallBack(packetInfo)
    if packetInfo and packetInfo.status == 0 and self.datas and packetInfo.room_id == self.datas.chat_id then
        local info = {};
        info.uid = UserInfo.getInstance():getUid();
        info.room_id = self.datas.chat_id;
        info.last_msg_time = TimerHelper.getServerCurTime()
        info.items = 15;
        info.version = kLuaVersionCode;
        OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_GET_HISTORY_MSG_NEW,info);
    end
end

function MatchRankDialog:onLeaveChatRoomCallBack(packetInfo)

end

function MatchRankDialog:onUserChatMsgCallBack(packetInfo)
    if self.datas.chat_id ~= packetInfo.room_id then return end
    if packetInfo.status > 0 then
        if self:isForbidSendMsg(packetInfo.status) then
            return    
        else
            ChessToastManager.getInstance():showSingle("消息发送失败了",2000);
        end
    elseif packetInfo.status == -1 then -- 屏蔽频繁聊天
        ChessToastManager.getInstance():showSingle("亲，消息不能为空或频繁发送哦",1500);
    end
end

MatchRankDialog.isForbidSendMsg = function(self,forbid_time)
    if forbid_time and forbid_time > 0 then
        local tip_msg = "很抱歉，您的账号被多次举报，经核实已被禁言，将于"..os.date("%Y-%m-%d %H:%M",forbid_time) .."解禁，感谢您的配合和理解。"
        if not self.m_chioce_dialog then
            self.m_chioce_dialog = new(ChioceDialog)
        end
        self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE)
        self.m_chioce_dialog:setMessage(tip_msg)
        self.m_chioce_dialog:show()
        return true
    end
    return false
end

function MatchRankDialog:onBroadcastChatCallBack(packetInfo)
    if packetInfo.room_id ~= self.datas.chat_id then return end
	local msgtab = json.decode(packetInfo.msg_json);
    local msgData = {};
    msgData.uid = msgtab.uid;
    msgData.name = msgtab.name;
    msgData.time = msgtab.time;
    msgData.msg = msgtab.msg;
    msgData.msg_id = msgtab.msg_id;
    if FriendsData.getInstance():isInBlacklist(tonumber(msgData.uid)) then return end
    Log.i("MatchRankDialog:onBroadcastChatCallBack:" .. packetInfo.msg_json)
    self:addChatLog(msgData.name,msgData.msg,msgData.uid)


    local msginfo = {};
    msginfo.room_id = packetInfo.room_id;
    msginfo.uid = UserInfo.getInstance():getUid();
    msginfo.msg_time = msgtab.time;
    msginfo.msg_id = msgtab.msg_id;
    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_BROAdCAST_CHAT_MSG,msginfo);
end

function MatchRankDialog:onGetHistoryMsgCallBack(packetInfo)
    local total_num = packetInfo.total_count;
    local roomId = packetInfo.room_id;
    local page_num = packetInfo.page_num;
    local curr_page = packetInfo.curr_page;
    local item_num = packetInfo.item_num;
    local msgItem = packetInfo.item;
    if packetInfo.room_id ~= self.datas.chat_id then return end
    
    Log.i("MatchRankDialog:onGetHistoryMsgCallBack:" .. (json.encode(msgItem) or "nil") )
    for i = 1,item_num do
        local data = msgItem[i]
        if not FriendsData.getInstance():isInBlacklist(tonumber(data.uid)) then 
            self:addChatLog(data.name,data.msg,data.uid)
        end
    end
end

MatchRankDialog.s_httpRequestsCallBackFuncMap = 
{
	[HttpModule.s_cmds.getMatchRule] = MatchRankDialog.onHttpGetMatchRule,
	[HttpModule.s_cmds.MatchRank] = MatchRankDialog.onHttpMatchRank,
    [HttpModule.s_cmds.MatchGetHistory] = MatchRankDialog.onHttpMatchGetHistory,
    [HttpModule.s_cmds.MatchGetApplyList] = MatchRankDialog.onHttpMatchGetApplyList,
}

MatchRankDialog.onEventResponse = function(self, cmd, status, data)
    if cmd == kFriend_UpdateUserData then
        for index =1,#self.m_chat_list_items do
            local uid = self.m_chat_list_items[index]:getUid();
            for _,sdata in pairs(status) do
                if uid and uid == tonumber(sdata.mid) then
                    self.m_chat_list_items[index]:updateUserData(sdata);
                    break;
                end
            end
        end
    end
end


MatchRankDialogChatPhrasesItem = class(Node);

MatchRankDialogChatPhrasesItem.ctor = function(self,str)
--	local text_x = 0;
--    super(self, "drawable/blank.png");
    local w,h = 670,73;
	print_string("MatchRankDialogChatPhrasesItem.ctor str = " .. str);

    self.m_bg_btn = new(Button,"drawable/blank.png","drawable/blank_press.png");
    self.m_bg_btn:setAlign(kAlignCenter);
    self.m_bg_btn:setSize(w,h);
    self:addChild(self.m_bg_btn);
	self.m_text = new(Text,str,nil,nil,nil,nil,32,80,80,80);
	self.m_text:setPos(10,0);
    self.m_text:setAlign(kAlignLeft);
	self.m_line = new(Image,"common/decoration/cutline.png");
	self.m_line:setPos(0,h);
    self.m_line:setSize(w,2);
    self.m_line:setAlign(kAlignBottom);
	self:addChild(self.m_text);
	self:addChild(self.m_line);
    self:setSize(w,h);
    self:setAlign(kAlignCenter);
    self.m_bg_btn:setOnClick(self,self.onItemClick);
    self.m_bg_btn:setSrollOnClick();
end


MatchRankDialogChatPhrasesItem.getText = function(self)
	return self.m_text:getText();
end

MatchRankDialogChatPhrasesItem.setCutlineVisible = function(self,visible)
	self.m_line:setVisible(visible)
end


MatchRankDialogChatPhrasesItem.onItemClick = function(self)
    if self.m_click_event and self.m_click_event.func then
        self.m_click_event.func(self.m_click_event.obj,self);
    end
end

MatchRankDialogChatPhrasesItem.setClickEvent = function(self,obj,func)
    self.m_click_event = {};
    self.m_click_event.obj = obj;
    self.m_click_event.func = func;
end

MatchRankDialogChatPhrasesItem.dtor = function(self)
	
end	

MatchRankDialogChatLogItem = class(Node)

MatchRankDialogChatLogItem.ctor = function(self, data)
    --{msg_id=-1 send_uid=1140 msg="啊啊啊" time=1447930284 }
    self.m_friend_info = FriendsData.getInstance():getUserData(data.send_uid);
	if data.send_uid == UserInfo.getInstance():getUid() then
        self.m_name = UserInfo.getInstance():getName();
	    self.m_str = data.msg;
        self.m_uid = data.send_uid;
    else
        self.m_name = data.mnick;
	    self.m_str = data.msg;
        self.m_uid = data.send_uid;
    end
    self.reportData = data.msg or ""
    --时间
    self.m_user_icon = new(Mask,"common/background/head_mask_bg_86.png","common/background/head_mask_bg_86.png")
    self.m_user_icon:setFile(UserInfo.DEFAULT_ICON[1]);
    self.m_user_icon:setAlign(kAlignCenter);
    
    self.m_user_icon_click_area = new(Button,"drawable/blank.png");
    self.m_user_icon_click_area:setSize(86,86);
    self.m_user_icon_click_area:setAlign(kAlignCenter);
    self.m_user_icon_click_area:setOnClick(self, self.onItemClick);

    self.m_icon_frame = new(Image,"common/background/head_bg_92.png");
    self.m_icon_frame:addChild(self.m_user_icon_click_area);
    self.m_icon_frame:addChild(self.m_user_icon);
    self.m_icon_frame:setPos(0);
    self:addChild(self.m_icon_frame);
    self.m_vip_frame = new(Image,"vip/vip_110.png");
    self.m_vip_frame:setAlign(kAlignCenter);
    self.m_vip_frame:setVisible(false);
    self.m_level_icon = new(Image,"common/icon/level_1.png");
    self.m_level_icon:setAlign(kAlignBottom);
    self.m_level_icon:setPos(0,-10);
    self.m_level_icon:setVisible(false);
    self.m_vip_logo = new(Image,"vip/vip_logo.png");
    self.m_vip_logo:setVisible(false);
    self.m_name_text = new(Text,self.m_name,nil,nil,nil,nil,24,100,100,100);
    local nw,nh = self.m_name_text:getSize();
    self:addChild(self.m_name_text);

    local itemX, itemY = 10, 30;
    if self.m_uid == UserInfo.getInstance():getUid() then
        self.m_message_bg = new(Image,"common/background/message_bg_7.png",nil, nil,46,46,50,16);
        self.m_message_bg:setPos(itemX + 100, itemY + 50);
        self.m_message_bg:setAlign(kAlignTopRight);
        self.m_icon_frame:setPos(itemX, itemY);
        self.m_icon_frame:setAlign(kAlignTopRight);
        self.m_name_text:setPos(itemX + 120, itemY + 10);
        self.m_name_text:setAlign(kAlignTopRight);
        self.m_vip_logo:setAlign(kAlignTopRight);
        self.m_vip_logo:setPos(itemX + 125 + nw,itemY + 5);
        if UserInfo.getInstance():getIsVip() == 1 then
            self.m_vip_logo:setVisible(true);
            self.m_name_text:setText(self.m_name,nil,nil,200,40,40)
        else
            self.m_name_text:setText(self.m_name,nil,nil,100,100,100)
            self.m_vip_logo:setVisible(false);
        end
        local frameRes = UserSetInfo.getInstance():getFrameRes();
        self.m_vip_frame:setVisible(frameRes.visible);
        local fw,fh = self.m_vip_frame:getSize();
        if frameRes.frame_res then
            self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
        end
        if UserInfo.getInstance():getIconType() == -1 then
            self.m_user_icon:setUrlImage(UserInfo.getInstance():getIcon());
        else
            local file = UserInfo.DEFAULT_ICON[UserInfo.getInstance():getIconType()] or UserInfo.DEFAULT_ICON[1];
            self.m_user_icon:setFile(file);
        end
        self.m_level_icon:setFile( string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevel()))
        self.m_level_icon:setVisible(true)
    else
        self.m_message_bg = new(Image,"common/background/message_bg_5.png",nil, nil, 46,46,50,16);
        self.m_message_bg:setPos(itemX + 100, itemY + 50);
        self.m_message_bg:setAlign(kAlignTopLeft);
        self.m_icon_frame:setPos(itemX, itemY);
        self.m_icon_frame:setAlign(kAlignTopLeft);
        self.m_name_text:setPos(itemX + 120, itemY + 10);
        self.m_name_text:setAlign(kAlignTopLeft);
        self.m_vip_logo:setAlign(kAlignTopLeft);
        self.m_vip_logo:setPos(itemX + 120,itemY + 5);
        local vw,vh = self.m_vip_logo:getSize();
        if self.m_friend_info then
            if self.m_friend_info.is_vip == 1 then
                self.m_name_text:setPos(itemX + 125 + vw,itemY + 10);
                self.m_name_text:setText(self.m_name,nil,nil,200,40,40)
                self.m_vip_logo:setVisible(true);
            else
                self.m_name_text:setPos(itemX + 120, itemY + 10);
                self.m_name_text:setText(self.m_name,nil,nil,100,100,100)
                self.m_vip_logo:setVisible(false);
            end;
            if self.m_friend_info.my_set then
                local frameRes = UserSetInfo.getInstance():getFrameRes(self.m_friend_info.my_set.picture_frame or "sys");
                self.m_vip_frame:setVisible(frameRes.visible);
                local fw,fh = self.m_vip_frame:getSize();
                if frameRes.frame_res then
                    self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
                end
            end
            if self.m_friend_info.iconType == -1 then
                self.m_user_icon:setUrlImage(self.m_friend_info.icon_url);
            else
                local file = UserInfo.DEFAULT_ICON[self.m_friend_info.iconType] or UserInfo.DEFAULT_ICON[1];
                self.m_user_icon:setFile(file);
            end
            self.m_level_icon:setFile( string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevelByScore(self.m_friend_info.score)))
            self.m_level_icon:setVisible(true)
        else
            self.m_name_text:setPos(itemX + 120, itemY + 10);
            self.m_vip_logo:setVisible(false);    
            local file = UserInfo.DEFAULT_ICON[1];
            self.m_user_icon:setFile(file);
            self.m_level_icon:setVisible(false)
        end
    end
    self.m_icon_frame:addChild(self.m_vip_frame);
    self.m_icon_frame:addChild(self.m_level_icon);
    self:addChild(self.m_vip_logo);
    self:addChild(self.m_message_bg);

    local msgStr, msgW, msgH = self:returnStrAndWH(self.m_str);
	self.m_text = new(TextView,msgStr,msgW,0,nil,nil,28,80,80,80);
    local w,h = self.m_text:getSize();
    self.m_message_bg:setSize(w+50,h+40);

    self.m_text:setAlign(kAlignCenter);
    if self.m_uid == UserInfo.getInstance():getUid() then
        self.m_text:setPos(-5);
    else
        self.m_text:setPos(5);
    end
    self.m_message_bg:addChild(self.m_text);
    local w,h = self.m_message_bg:getSize();
    w = math.max(w,64);
    h = math.max(h,64);
    self.m_message_bg:setSize(w,h);

    local itemW = 610;
    local itemH = select(2,self.m_message_bg:getSize()) + select(2,self.m_icon_frame:getSize());
	self:setSize(itemW,itemH);
end

MatchRankDialogChatLogItem.dtor = function(self)
    if self.m_userinfo_dialog then
        delete(self.m_userinfo_dialog);
        self.m_userinfo_dialog = nil;
    end;
end


MatchRankDialogChatLogItem.getUid = function(self)
    return self.m_uid or nil;
end

MatchRankDialogChatLogItem.getMsgTime = function(self)
    return self.m_time_str or "0";
end

MatchRankDialogChatLogItem.updateUserData = function(self, data)
    self:loadIcon(data);
    self:setVip(data);
    self:setUserName(data);
end;

MatchRankDialogChatLogItem.returnStrAndWH = function(self, msg)
    local strW, strH = 64,64; -- 默认气泡宽高
    local lens = string.lenutf8(GameString.convert2UTF8(msg) or "");    
    local strMsg = msg;
    if lens > 140 then--限制140字
        lens = 140;
        strMsg = GameString.convert2UTF8(string.subutf8(msg,1,140));
    end;
    local tempMsg = new(Text,msg,0, 0, kAlignLeft,nil,28,80, 80, 80);
    local tempMsgW, tempMsgH = tempMsg:getSize();
    if tempMsgW ~= 0 and tempMsgH ~= 0 then
        if tempMsgW >= 428 then -- 448,32字符宽，14个字
            tempMsgW = 428;
        elseif tempMsgW <= 64 then
            tempMsgW = 64;
        end;
        return strMsg,tempMsgW, tempMsgH;
    end;
    delete(tempMsg)
    return strMsg, strW, strH;
end;

MatchRankDialogChatLogItem.loadIcon = function(self,data)
    local icon = data.icon_url;
    if not self.m_user_icon then
        if not icon then 
            if data.iconType > 0 then
                icon = UserInfo.DEFAULT_ICON[data.iconType] or UserInfo.DEFAULT_ICON[1];
            else
                icon = UserInfo.DEFAULT_ICON[1]
            end;
            self.m_user_icon = new(Mask,icon ,"common/background/head_mask_bg_46.png");
        else
            self.m_user_icon = new(Mask,"drawable/blank.png" ,"common/background/head_mask_bg_46.png");
            self.m_user_icon:setUrlImage(icon,UserInfo.DEFAULT_ICON[1]);            
        end;
        self.m_user_icon:setSize(46,46);
        self.m_user_icon:setAlign(kAlignCenter);
        self.m_icon_frame:addChild(self.m_user_icon)
    else
        if not icon then 
            if data.iconType > 0 then
                icon = UserInfo.DEFAULT_ICON[data.iconType] or UserInfo.DEFAULT_ICON[1];
            else
                icon = UserInfo.DEFAULT_ICON[1]
            end;
            self.m_user_icon:setFile(icon);
        else
            self.m_user_icon:setUrlImage(icon,UserInfo.DEFAULT_ICON[1]);            
        end;   
    end   
    self.m_level_icon:setFile( string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevelByScore(data.score)))
    self.m_level_icon:setVisible(true)
end;

MatchRankDialogChatLogItem.setVip = function(self, data)
    if data.my_set then
        local frameRes = UserSetInfo.getInstance():getFrameRes(data.my_set.picture_frame or "sys");
        self.m_vip_frame:setVisible(frameRes.visible);
        local fw,fh = self.m_vip_frame:getSize();
        if frameRes.frame_res then
            self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
        end
    end
    if data and data.is_vip == 1 then
        local itemX, itemY = 10, 30;
        local vw,vh = self.m_vip_logo:getSize();
        self.m_name_text:setText(self.m_name,nil,nil,200,40,40)
        if data.mid and tonumber(data.mid) == UserInfo.getInstance():getUid() then
            self.m_name_text:setPos(itemX + 120,itemY + 10);
        else
            self.m_name_text:setPos(itemX + 125 + vw,itemY + 10);
        end;
        self.m_vip_logo:setVisible(true);
--        self.m_vip_frame:setVisible(true);
    else
        self.m_name_text:setText(self.m_name,nil,nil,100,100,100)
    end;    
end;

MatchRankDialogChatLogItem.setUserName = function(self,data)
    if data and data.mnick then
        self.m_name_text:setText(data.mnick or "博雅象棋");
    end;
end;

MatchRankDialogChatLogItem.getTime = function(self, time)
    if ToolKit.isSecondDay(time) then
        return os.date("%m-%d %H:%M",time);
    else
        return os.date("%H:%M",time);--%Y/%m/%d %X
    end;
end

MatchRankDialogChatLogItem.onItemClick = function(self)
    Log.i("MatchRankDialogChatLogItem.onItemClick--icon click!");
    if self.m_uid == UserInfo.getInstance():getUid() then
        Log.i("MatchRankDialogChatLogItem.onItemClick--icon click yourself!");
    else
        if not self.m_userinfo_dialog then
            -- TODO UserInfoDialog2 从场景中分离出来的dlg,后续会同步到联网对战
            self.m_userinfo_dialog = new(UserInfoDialog2);
        end;
        if self.m_userinfo_dialog:isShowing() then return end
        
        if UserInfo.getInstance():getUid() == self.m_uid then
            self.m_userinfo_dialog:setShowType(UserInfoDialog2.SHOW_TYPE.OTHER)
        else
            self.m_userinfo_dialog:setShowType(UserInfoDialog2.SHOW_TYPE.UNION)
        end
        self.m_userinfo_dialog:setReportInfo(self.reportData)

        local user = FriendsData.getInstance():getUserData(self.m_uid);
        self.m_userinfo_dialog:show(user,self.m_uid);
    end
end




MatchRankDialogSignUpPlayer = class(Node)

function MatchRankDialogSignUpPlayer:ctor()
    self:setSize(144,150)
    local head = new(Mask,"common/icon/default_head.png","common/background/head_mask_bg_110.png")
    head:setSize(80,80)
    head:setAlign(kAlignTop)
    local level = new(Image,"common/icon/level_1.png")
    level:setAlign(kAlignBottom)
    level:setPos(0,-12)
    level:setVisible(false)
    head:addChild(level)
    local name = new(Text,"", width, height, align, fontName, 26, 120, 120, 120)
    name:setAlign(kAlignBottom)
    name:setPos(0,15)
    self:addChild(head)
    self:addChild(name)
    self.mHead = head
    self.mLevel = level
    self.mName = name
    EventDispatcher.getInstance():register(Event.Call,self,self.onNativeEvent)
    self.mHead:setEventTouch(self,self.onEventTouch)
    self.mAddChatLog = {}
end

function MatchRankDialogSignUpPlayer:dtor()
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeEvent)
    delete(self.m_up_user_info_dialog)
end

function MatchRankDialogSignUpPlayer:onEventTouch(finger_action,x,y,drawing_id_first,drawing_id_current)
    if not self.mUid then return end
    if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
     
        if self.m_up_user_info_dialog and self.m_up_user_info_dialog:isShowing() then 
            self.m_up_user_info_dialog:dismiss();
            return 
        end
        delete(self.m_up_user_info_dialog)
        self.m_up_user_info_dialog = new(UserInfoDialog2);

        if UserInfo.getInstance():getUid() == self.mUid then
            self.m_up_user_info_dialog:setShowType(UserInfoDialog2.SHOW_TYPE.OTHER)
        else
            self.m_up_user_info_dialog:setShowType(UserInfoDialog2.SHOW_TYPE.UNION)
        end

        FriendsData.getInstance():sendCheckUserData(self.mUid)
        self.m_up_user_info_dialog:show(nil,self.mUid);
    end
end


function MatchRankDialogSignUpPlayer:onNativeEvent(cmd,...)
    if cmd == kFriend_UpdateUserData then
        local data = unpack({...})
        if not self.mUid then return end
        for _,userData in ipairs(data) do
            if self.mUid == userData.mid then
                self:setUserData(userData)
            end
        end
    end
end

function MatchRankDialogSignUpPlayer:setPlayer(uid)
    if self.mUid == tonumber(uid) then return end
    local preUid = self.mUid
    self.mUid = tonumber(uid)
    if not uid then
        self.mHead:setFile("common/icon/default_head.png")
        self.mName:setText("")
        self.mLevel:setVisible(false)
        self.mUserData = nil
        return
    end
    self.isAddJoinMsg = false
    local data = FriendsData.getInstance():getUserData(self.mUid)
    self:setUserData(data)
end

function MatchRankDialogSignUpPlayer:setUserData(data)
    self.mUserData = data
    if data then
        self:setHead(data)
        local length = string.lenutf8(data.mnick)
        if length <= 4 then
            self.mName:setText(data.mnick)
        else
            local prefix = string.subutf8(data.mnick,1,4)
            self.mName:setText(prefix .. "...")
        end
    else
        self.mHead:setFile("common/icon/default_head.png")
        self.mName:setText("")
        self.mLevel:setVisible(false)
    end
end

function MatchRankDialogSignUpPlayer:setHead(data)
    if type(data) ~= "table" then return end
    if tonumber(data.iconType) == -1 then
        self.mHead:setUrlImage(data.icon_url,"common/icon/default_head.png")
    else
        local icon = tonumber(data.iconType) or 1
        self.mHead:setFile(UserInfo.DEFAULT_ICON[icon] or UserInfo.DEFAULT_ICON[1])
    end
--    local frameRes = UserSetInfo.getInstance():getFrameRes(data.my_set);
--    vip:setVisible(false)
--    if not frameRes then return end
--    vip:setVisible(frameRes.visible);
--    if frameRes.frame_res then
--        vip:setFile(string.format(frameRes.frame_res,110));
--    end
    self.mLevel:setFile( string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevelByScore(data.score)))
    self.mLevel:setVisible(true)
end

require(VIEW_PATH .. "match_rank_dialog_sign_up_item")
MatchRankDialogSignUpPlayer2 = class(Node)

function MatchRankDialogSignUpPlayer2:ctor(data)
    self.root = SceneLoader.load(match_rank_dialog_sign_up_item);
    self:addChild(self.root);
    local w,h = self.root:getSize();
    self:setSize(w,h);
    self.data = data;


    local head = new(Mask,"common/icon/default_head.png","common/background/head_mask_bg_110.png")
    head:setSize(90,90)
    head:setAlign(kAlignCenter)
    local level = self.root:getChildByName("btn_head"):getChildByName("head_bg"):getChildByName("level")
    level:setVisible(false)
    level:setLevel(2)
    local name = self.root:getChildByName("txt_name")
    self.root:getChildByName("btn_head"):getChildByName("head_bg"):addChild(head)
    self:addChild(name)
    local score = self.root:getChildByName("txt_life")
    self.mHead = head
    self.mLevel = level
    self.mName = name
    self.mScore = score
    self.mBtnFollow = self.root:getChildByName("btn_follow")
	self.mBtnFollow:setOnClick(self, self.onFollowClick)
    self.mBtnUnFollow = self.root:getChildByName("btn_unfollow")
	self.mBtnUnFollow:setOnClick(self, self.onUnFollowClick)
    self.mBtnFollow:setVisible(false)
    self.mBtnUnFollow:setVisible(false)
    
    self:setUserData(data)
    self:setHead(data)
    self.mUid = tonumber(self.data.mid)
    self:setRelation(FriendsData.getInstance():getUserStatus(self.mUid))
    EventDispatcher.getInstance():register(Event.Call,self,self.onEvenCall)
    self.mHead:setEventTouch(self,self.onEventTouch)
end

function MatchRankDialogSignUpPlayer2:dtor()
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onEvenCall)
    delete(self.m_up_user_info_dialog)
end

function MatchRankDialogSignUpPlayer2:setUserData(data)
    self.mUserData = data
    if data then
        self:setHead(data)
        self.mName:setText(data.mnick)
        self.mScore:setText("积分:" .. (data.score or 0))
    else
        self.mHead:setFile("common/icon/default_head.png")
        self.mName:setText("")
        self.mScore:setText("")
        self.mLevel:setVisible(false)
    end
end

function MatchRankDialogSignUpPlayer2:setHead(data)
    if type(data) ~= "table" then return end
    if tonumber(data.iconType) == -1 then
        self.mHead:setUrlImage(data.icon_url,"common/icon/default_head.png")
    else
        local icon = tonumber(data.iconType) or 1
        self.mHead:setFile(UserInfo.DEFAULT_ICON[icon] or UserInfo.DEFAULT_ICON[1])
    end
    self.mLevel:setFile( string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevelByScore(data.score)))
    self.mLevel:setVisible(true)
end


-- 关注
MatchRankDialogSignUpPlayer2.onFollowClick = function( self )
	-- body
    local info = {};
    info.uid = UserInfo.getInstance():getUid();
    info.target_uid = self.mUid;
    info.op = 1;
    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_ADD_FLLOW,info);
end


-- 取消关注
MatchRankDialogSignUpPlayer2.onUnFollowClick = function( self )
	-- body
    local info = {};
    info.uid = UserInfo.getInstance():getUid();
    info.target_uid = self.mUid;
    info.op = 0;
    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_ADD_FLLOW,info);
end

--[Comment]
--更新界面
function MatchRankDialogSignUpPlayer2.onEvenCall(self,cmd,...)
    if cmd == kFriend_UpdateStatus then
        local statusTab = unpack({...})
        for _,status in ipairs(statusTab) do
            if self.mUid == status.uid then
                self:setRelation(status)
            end
        end
    elseif cmd == kFriend_FollowCallBack then
        local status = unpack({...})
        if status and status.target_uid == self.mUid then
            if not self.mBtnFollow or not self.mBtnUnFollow or not status then return end
            if status.relation == 0 or status.relation == 1 then
                self.mBtnFollow:setVisible(true)
                self.mBtnUnFollow:setVisible(false)
            else
                self.mBtnFollow:setVisible(false)
                self.mBtnUnFollow:setVisible(true)
            end
        end
    end
end


function MatchRankDialogSignUpPlayer2:setRelation(status)
    if not self.mBtnFollow or not self.mBtnUnFollow or not status then return end
    self.mStatus = status
    local relationBtn = self.mBtnFollow
    if status.uid == UserInfo.getInstance():getUid() then
        return
    end

    if status.relation == 0 or status.relation == 1 then
        self.mBtnFollow:setVisible(true)
        self.mBtnUnFollow:setVisible(false)
    else
        self.mBtnFollow:setVisible(false)
        self.mBtnUnFollow:setVisible(true)
    end
end

function MatchRankDialogSignUpPlayer2:onEventTouch(finger_action,x,y,drawing_id_first,drawing_id_current)
    if not self.mUid then return end
    if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
     
        if self.m_up_user_info_dialog and self.m_up_user_info_dialog:isShowing() then 
            self.m_up_user_info_dialog:dismiss();
            return 
        end
        delete(self.m_up_user_info_dialog)
        self.m_up_user_info_dialog = new(UserInfoDialog2);

        if UserInfo.getInstance():getUid() == self.mUid then
            self.m_up_user_info_dialog:setShowType(UserInfoDialog2.SHOW_TYPE.OTHER)
        else
            self.m_up_user_info_dialog:setShowType(UserInfoDialog2.SHOW_TYPE.UNION)
        end

        FriendsData.getInstance():sendCheckUserData(self.mUid)
        self.m_up_user_info_dialog:show(nil,self.mUid);
    end
end


require(VIEW_PATH .. "match_rank_dialog_item")

MatchRankDialogItem = class(Node)

MatchRankDialogItem.ctor = function( self, data)
	self:loadView()
	self:initControl()
	self:refresh(data)
    EventDispatcher.getInstance():register(Event.Call,self,self.onEvenCall)
end

MatchRankDialogItem.dtor = function( self )
	-- body
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onEvenCall)
    
    delete(self.m_up_user_info_dialog)
end

MatchRankDialogItem.loadView = function( self )
	self.root_view = SceneLoader.load(match_rank_dialog_item)
	self.root_view:setAlign(kAlignCenter)
	self:addChild(self.root_view)
	self:setSize(self.root_view:getSize())
end

MatchRankDialogItem.initControl = function( self )
    self.mRankView = self.root_view:getChildByName("rank_view")
    self.mHeadView = self.root_view:getChildByName("btn_head")
    self.mRankIcon = self.mHeadView:getChildByName("rank_icon")
    self.mRankIcon:setVisible(false)
    self.mMyBg = self.root_view:getChildByName("my_bg")
    self.mMyBg:setVisible(false)
    self.mHeadBg = self.mHeadView:getChildByName("head_bg")
    self.mLevelIcon   = self.mHeadBg:getChildByName("level")
    self.mLevelIcon:setLevel(3)
    self.mMask   = new(Mask,UserInfo.DEFAULT_ICON[1], "common/background/head_mask_bg_46.png")
    self.mHeadBg:addChild(self.mMask)
    self.mMask:setSize(70,70);
    self.mName = self.root_view:getChildByName("txt_name")
    self.mLife = self.root_view:getChildByName("txt_life")
    self.mHeadView:setEventTouch(self,self.onEventTouch)
end

function MatchRankDialogItem:refresh(data)
    self.mData = data
    self.mUid = tonumber(data.mid)
    self.mLife:setText(data.match_score or "...") 
    self.mRankView:removeAllChildren(true)
    local addView = nil
    if tonumber(data.rank) then
        if tonumber(data.rank) == 0 then
            addView = new(Text,"未上榜", width, height, align, fontName, 28, 80,80,80)
        else
            addView = new(Text,data.rank, width, height, align, fontName, 28, 80,80,80)
        end

        if tonumber(data.rank) <= 3 and tonumber(data.rank) >= 1 then
            self.mRankIcon:setFile( string.format("common/icon/rank_icon_%d.png",tonumber(data.rank)))
            self.mRankIcon:setVisible(true)
        else
            self.mRankIcon:setVisible(false)
        end
    else
        addView = new(Text,data.rank, width, height, align, fontName, 28, 80,80,80)
        self.mRankIcon:setVisible(false)
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
end

-- btn event ---------------------------------------
MatchRankDialogItem.onHeadClick = function( self )
	-- body
end

--[Comment]
--更新界面
function MatchRankDialogItem:setHeadIconSize(w,h)
    self.mMask:setSize(w,h)
    self.mHeadBg:setSize(w,h)
end

function MatchRankDialogItem:setUseBg(flag)
    self.mUserBg = flag
--    self.mMyBg:setVisible(self.mMyBg:getVisible() and self.mUserBg)
end

function MatchRankDialogItem:onEventTouch(finger_action,x,y,drawing_id_first,drawing_id_current)
    if not self.mUid then return end
    if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
     
        if self.m_up_user_info_dialog and self.m_up_user_info_dialog:isShowing() then 
            self.m_up_user_info_dialog:dismiss();
            return 
        end
        delete(self.m_up_user_info_dialog)
        self.m_up_user_info_dialog = new(UserInfoDialog2);

        if UserInfo.getInstance():getUid() == self.mUid then
            self.m_up_user_info_dialog:setShowType(UserInfoDialog2.SHOW_TYPE.OTHER)
        else
            self.m_up_user_info_dialog:setShowType(UserInfoDialog2.SHOW_TYPE.UNION)
        end

        FriendsData.getInstance():sendCheckUserData(self.mUid)
        self.m_up_user_info_dialog:show(nil,self.mUid);
    end
end