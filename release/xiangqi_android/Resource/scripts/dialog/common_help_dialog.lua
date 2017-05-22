--CommonHelpDialog.lua
--Date 2016.9.1
--帮助弹窗
--endregion

require(VIEW_PATH .. "common_help_view_dialog");
require(BASE_PATH .. "chessDialogScene");

CommonHelpDialog = class(ChessDialogScene,false);

CommonHelpDialog.online_mode = 1;
CommonHelpDialog.find_mode = 2;
CommonHelpDialog.replay_mode = 3;
CommonHelpDialog.sociaty_mode = 4;
CommonHelpDialog.online_money_mode = 5;
CommonHelpDialog.rank_mode = 6;
CommonHelpDialog.match_rule_mode = 7;
CommonHelpDialog.console_mode = 8;


CommonHelpDialog.SOCIATY_CONTEXT = {
    ' #l#s36#c87645F创建规则：#l#n',
    '每名棋友可以#c197328创建1个棋社#n，创建者#c197328需累计联网对局超过50局#n。#l',
    '棋社不可重名，重名会文字提示修改；#l',
    '棋社创建后名称不支持修改。#l',
    '#l#s36#c87645F加入规则：#l#n',
    '用户可以自由加入或退出棋社，#cC82828退出后24小#l时内不能加入其他棋社#n。#l',
    '部分棋社需申请被批准后才能加入。#l',
    '#l#s36#c87645F棋社规则：#l#n',
    '#c197328活跃度=棋社内所有棋友的牌局数#n,私人房及#l好友房的牌局数除外。#l',
    '每周活跃度最高的棋社会在排行榜上展示。#l',
}

CommonHelpDialog.FIND_CONTEXT = {
--    ' #l#s36#c87645F推荐：#l#n',
--    '热门活动均为有奖活动，人气活动会在推荐区滚动展示。#l',
--    '最近对手推荐会为您推荐最近7天的对战用户，有惺惺相惜的棋友就赶快关注吧。#l',
--    '热门棋谱是最受关注的热门街边残局的通关棋谱，适合棋友们推敲演练。棋友挑战高难度人气残局的通关棋谱都有机会获得官方推荐哦。#l',
    ' #l#s36#c87645F街边残局：#l#n',
    '街边残局采用累计奖池的方式，残局上传者的创建金、所有用户的挑战金都会累积至奖池中。残局的挑战者越多，难度越高，可获得的累计奖金和创建奖金越丰厚。#l',
    '所有挑战用户首次过关残局，都可以获得一定金币作为奖励；街边残局支持红黑互换，和棋算胜。#l',
    '残局被通过之后，创建者可一次性获得丰厚的金币奖励。#l',
    '残局上架后会有7天的展示时间，过期会自动下架。#l',
    '关注感兴趣的残局后，在残局下架前都可在【我关注的】中查看和挑战。#l',
}

CommonHelpDialog.ONLINE_CONTEXT = {
    '#l#s36#c87645F观战：#n#l可围观专业二级以上（积分超过2000）用户的对局以及所关注的棋友的对局。#l观战中，对局双方用户左边为黑方，右边为红方。#l点击棋盘可以切换为全屏模式显示。再次点击退出全屏模式。',
    '#l#s36#c87645F场次说明：#n',
    '新手场：底注#c197328%s#n金币，携带下限为#c197328%s#n金币，每局台费#c197328%s#n金币。',
    '中级场：底注#c197328%s#n金币，携带下限为#c197328%s#n金币，每局台费#c197328%s#n金币。',
    '大师场：底注#c197328%s#n金币，携带下限为#c197328%s#n金币，每局台费#c197328%s#n金币。',
    '私人房：底注#c197328%s#n金币，携带下限为#c197328%s#n金币，每局台费#c197328%s#n金币。',
    '挑战好友：底注#c197328%s#n金币，携带下限为#c197328%s#n金币，每局台费#c197328%s#n金币。',
    '竞技场：底注#c197328%s#n金币，携带下限为#c197328%s#n金币，每局台费#c197328%s#n金币；本场次局时，步时，读秒根据象棋升级赛规则统一设置',
    '对局双方均需要支付台费。',
    ' #l#s36#c87645F设置说明：#n',
    '局时：棋局中，以步时为走子时限的有效时间。',
    '步时：局时内开始的每步棋可用的走子时间。',
    '读秒：局时用完后每步棋可用的走子时间，若设置不读秒即一方局时结束后棋局结束。',
    '棋局中，首先进行“局时”与“步时”的计算。',
    '#l局时超时前，每步都必须在“步时”规定时间内完成走子，走下一步时，“步时”将重新计算。#l“局时”超时后，“局时”停止计算，每步都必须在“读秒”规定时间内完成走子。#l“步时”与“读秒”超时都会引起棋局结束，超时者判输。',
    '#l#s36#c87645F其他：#n',
    '联网游戏悔棋和求和均需要对方同意。联网对局或观战，可以在棋友信息中选择关注棋友或者屏蔽或取消屏蔽该棋友当局的聊天消息。',
    '私人房可以邀请身边好友一起对局，也可以直接在聊天室向棋友发起挑战。',
    '私人房对局和好友对局不产生积分变化。',
    '棋局中可通过设置修改走子的操作方式。棋盘和棋子的显示样式可在我的个人装扮中修改。',
}

CommonHelpDialog.REPLAY_CONTEXT = {
    ' #l#s36#c87645F最近对局：#l#n',
    '自动保存所有联网对局、单机对局、残局过关和观战的棋局，默认棋谱上限为%s盘。"#l',
    ' #l#s36#c87645F清空对局：#l#n',
    '使用清空可一次性清空最近对局中的所有棋谱。#l',
    ' #l#s36#c87645F我的收藏：#l#n',
    '所收藏的棋谱可一直保留，方便随时演练；#l',
    ' #l#s36#c87645F棋友推荐：#l#n',
    '可随时查看自己和好友收藏的棋谱，可以转收藏或评论喜欢的棋谱。#l',
    ' #l#s36#c87645F棋谱筛选：#l#n',
    "使用筛选功能，可以快速查看某一月份所收藏的棋谱。#l",
    ' #l#s36#c87645F评论：#l#n',
    "可随时评价自己和棋友公开收藏的棋谱，所有人可见。#l",
}

CommonHelpDialog.MATCH_CONTEXT = {
    '#l比赛场包含多种不同赛制的比赛,可供各位棋友相互切磋.#l',
    '#l#s36#c87645F比赛基本规则:#l#n',
    '点击任一比赛的图标可以查看该比赛的具体规则和奖励,各类比赛小雅都已备好了丰厚的奖励.#l',
    '比赛场包含多种不同赛制的比赛,可供各位棋友相互切磋.#l',
    '精彩赛事还支持观战,可以欣赏高手对决,提高棋艺.',
}

CommonHelpDialog.RANK_CONTEXT = {
    "#l#l#s36#c197328魅力榜#n",
    "#l结算规则：",
    "#l魅力按周结算，每周周一0点到本周周日24点为一个结算周期。每周日24点魅力清零，重新进入下一个结算周期。",
    "#l计算规则：",
    "#l收到或送出互动礼物，魅力都会改变。",
    "#l收礼 ---- 收到1朵鲜花，魅力加#c19732810#n；收到1个飞吻，魅力加#c19732850#n；",
    "收到1个金象，魅力加#c197328100#n；收到1个鸡蛋，魅力减#c1973285#n；#l",
    "送礼 ---- 送到1朵鲜花，魅力加#c1973281#n；送到1个飞吻，魅力加#c1973285#n；",
    "送到1个金象，魅力加#c19732810#n；送到1个鸡蛋，魅力不变；",
    "#l奖励规则：",
    "#l第1名：#c19732810000#n棋魂（价值#c197328100#n元）",
    "#l第2名：#c1973285000#n棋魂（价值#c19732850#n元）",
    "#l第3名：#c1973282000#n棋魂（价值#c19732820#n元）",
    "#l第4-10名：#c1973281000#n棋魂",
    "#l第11-20名：#c197328300#n棋魂",
    "#l魅力相同时按照积分多少决定排名；",
    "#l奖励将会在3个工作日内以邮件形式发放。",
    "#l#s36#c197328大师榜#n",
    "#l按照玩家积分排序。",
    "#l#s36#c197328棋社榜#n",
    "#l按照棋社活跃度排序。",
    "#l#s36#c197328好友榜#n",
    "#l按照好友积分排序。",
}

CommonHelpDialog.CONSOLE_CONTEXT = {
    "#l#l#s36#c197328闯关条件#n",
    "#l前三关可免费闯关，其他关卡需收集到指定数量的星星才能解锁，解锁后每次闯关需花费一定金币，该关卡1星过关后可免费闯关。",
    "#l#l#s36#c197328闯关任务#n",
    "#l每关有指定的吃子任务、留子任务:",
    "#l    战胜守关人可以获得1颗星；",
    "#l    战胜守关人并且完成任意1个指定任务可以获得2颗星；",
    "#l    战胜守关人并且完成全部2个指定任务可以获得3颗星；",
    "#l#l#s36#c197328道具#n",
    "#l火炮道具可以在开局前帮你随机消灭对方一颗棋子；",
    "#l锦囊道具可以让高级AI帮你走出最精确的一步棋，每局棋只能使用3次锦囊",
}

function CommonHelpDialog.ctor(self)
    super(self,common_help_view_dialog);
    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)

    self.bg = self.m_root:getChildByName("bg");
    self.closeBtn = self.bg:getChildByName("close_btn");
    self.closeBtn:setOnClick(self,self.dismiss);
    self.scrollView = self.bg:getChildByName("scroll_view");
    self.scrollView.m_autoPositionChildren = true;
    self.isFirst = true

    self.bg:setEventTouch(self,function() end);
    self:setShieldClick(self,self.dismiss);
end

function CommonHelpDialog.dtor(self)
    self.mDialogAnim.stopAnim()
end

function CommonHelpDialog.show(self)
    self.super.show(self,self.mDialogAnim.showAnim)
    if not self.isFirst then return end
    if self.mode and self.mode == CommonHelpDialog.online_money_mode then
        EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
        local param = {}
        param.param = {}
        param.param.help_key = "MoneyRoomListHelpDialog"
        HttpModule.getInstance():execute(HttpModule.s_cmds.IndexGameHelp,param)   
    elseif self.mode and self.mode == CommonHelpDialog.rank_mode then
        EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
        local param = {}
        param.param = {}
        param.param.help_key = "RankHelpDialog"
        HttpModule.getInstance():execute(HttpModule.s_cmds.IndexGameHelp,param)
    elseif self.mode and self.mode == CommonHelpDialog.match_rule_mode then
        EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
        local data = {};
        data.param = {};
        data.param.config_id = self.params.id;
        HttpModule.getInstance():execute(HttpModule.s_cmds.getMatchRule, data)
    end
end

function CommonHelpDialog.dismiss(self)
    self.super.dismiss(self,self.mDialogAnim.dismissAnim)
    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpRequestsCallBack);
end

function CommonHelpDialog.setMode(self,mode,params)
    self.mode = CommonHelpDialog.find_mode
    self.params = params
    if mode then
        self.mode = mode
    end
    self:initHelpView() 
end

function CommonHelpDialog.initHelpView(self)
    local w,h = self.scrollView:getSize();
    local str = ""
    if self.mode == CommonHelpDialog.online_mode then
        str = self:onOnlinInit()
    elseif self.mode == CommonHelpDialog.find_mode then
        str = table.concat(CommonHelpDialog.FIND_CONTEXT);
    elseif self.mode == CommonHelpDialog.sociaty_mode then
        str = table.concat(CommonHelpDialog.SOCIATY_CONTEXT);
    elseif self.mode == CommonHelpDialog.replay_mode then
        str = self:onReplayInit()
    elseif self.mode == CommonHelpDialog.MATCH_CONTEXT then
        str = table.concat(CommonHelpDialog.MATCH_CONTEXT);
    elseif self.mode == CommonHelpDialog.rank_mode then
--        str = table.concat(CommonHelpDialog.RANK_CONTEXT);
    elseif self.mode == CommonHelpDialog.match_rule_mode then
--        str = table.concat(CommonHelpDialog.RANK_CONTEXT);
    elseif self.mode == CommonHelpDialog.console_mode then
        str = table.concat(CommonHelpDialog.CONSOLE_CONTEXT);
    end
    
    self.richText = new(RichText,str, w, h, kAlignTopLeft, fontName, 28, 80, 80, 80, true,10);
    self.scrollView:addChild(self.richText);
end

function CommonHelpDialog.onOnlinInit(self)
    local roomConfig        = RoomConfig.getInstance();
    local noviceData        = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_NOVICE_ROOM);
    local intermediateData  = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_INTERMEDIATE_ROOM);
    local masterData        = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_MASTER_ROOM);
    local arenaData         = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_ARENA_ROOM);
    local privateData       = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_PRIVATE_ROOM);
    local friendData         = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_FRIEND_ROOM);
    if noviceData then--新手场;
        CommonHelpDialog.ONLINE_CONTEXT[3] = string.format(CommonHelpDialog.ONLINE_CONTEXT[3],noviceData.money,noviceData.minmoney,noviceData.rent);
    end
    if intermediateData then--中级场;
        CommonHelpDialog.ONLINE_CONTEXT[4] = string.format(CommonHelpDialog.ONLINE_CONTEXT[4],intermediateData.money,intermediateData.minmoney,intermediateData.rent);
    end
    if masterData  then--大师场;
        CommonHelpDialog.ONLINE_CONTEXT[5] = string.format(CommonHelpDialog.ONLINE_CONTEXT[5],masterData.money,masterData.minmoney,masterData.rent);
    end
    if arenaData then--竞技场;
        CommonHelpDialog.ONLINE_CONTEXT[8] = string.format(CommonHelpDialog.ONLINE_CONTEXT[8],arenaData.money,arenaData.minmoney,arenaData.rent);
    end
    if privateData then--私人房;
        CommonHelpDialog.ONLINE_CONTEXT[6] = string.format(CommonHelpDialog.ONLINE_CONTEXT[6],privateData.money,privateData.minmoney,privateData.rent);
    end
    if friendData then--好友房;
        CommonHelpDialog.ONLINE_CONTEXT[7] = string.format(CommonHelpDialog.ONLINE_CONTEXT[7],friendData.money,friendData.minmoney,friendData.rent);
    end

    local context = ""
    for i,str in ipairs(CommonHelpDialog.ONLINE_CONTEXT) do
        context = context .. "#l" .. str;
    end
    return context
end

function CommonHelpDialog.onReplayInit(self)
    local data = UserInfo.getInstance():getSaveChessManualLimit()
    if data then
        CommonHelpDialog.REPLAY_CONTEXT[2] = string.format(CommonHelpDialog.REPLAY_CONTEXT[2],data);
    end
    local context = ""
    for i,str in ipairs(CommonHelpDialog.REPLAY_CONTEXT) do
        context = context .. str;
    end
    return context
end

function CommonHelpDialog:onIndexGameHelpResponse(isSuccess,message)
    if not isSuccess then return end
    local help_text = message.data.help_text:get_value()
    if not help_text then return end
    self.scrollView:removeAllChildren()
    local w,h = self.scrollView:getSize()
    local richText = new(RichText,help_text, w, h, kAlignTopLeft, fontName, 28, 80, 80, 80, true,10)
    self.scrollView:addChild(richText)
    self.isFirst = false
end


CommonHelpDialog.onHttpGetMatchRule = function(self,isSuccess,message)
	if not isSuccess then
		return
	end
    local rule = message.data.rule_text:get_value();
    if not rule then return end
    self.scrollView:removeAllChildren()
    local w,h = self.scrollView:getSize()
    local richText = new(RichText,rule, w, h, kAlignTopLeft, fontName, 28, 80, 80, 80, true,10)
    self.scrollView:addChild(richText)
    self.isFirst = false
end;

function CommonHelpDialog.onHttpRequestsCallBack(self,command,...)
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self,...);
	end 
end

CommonHelpDialog.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.IndexGameHelp] = CommonHelpDialog.onIndexGameHelpResponse;
	[HttpModule.s_cmds.getMatchRule] = CommonHelpDialog.onHttpGetMatchRule,
};