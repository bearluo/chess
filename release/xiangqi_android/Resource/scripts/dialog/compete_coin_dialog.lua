require(VIEW_PATH .. "compete_coin_dialog")
require(DIALOG_PATH .. "compete_invitecode_dialog");

CompeteCoinDialog = class(ChessDialogScene, false)

CompeteCoinDialog.ctor = function( self, datas)
	super(self, compete_coin_dialog)
	self.anim_dlg = AnimDialogFactory.createNormalAnim(self)
	self.datas = datas
	self:initView()
    self:init();
    EventDispatcher.getInstance():register(HttpModule.s_event, self, self.onHttpRequestsCallBack)
end

CompeteCoinDialog.dtor = function( self )
	self.anim_dlg:stopAnim()
    delete(self.m_goto_mall_dialog)
    delete(self.m_invitcode_dialog)
	EventDispatcher.getInstance():unregister(HttpModule.s_event, self, self.onHttpRequestsCallBack)
end

CompeteCoinDialog.initView = function(self)
    self.m_root_view = self.m_root;
    self.m_dialog_bg = self.m_root_view:getChildByName("bg");
    -- title
    self.m_title_view = self.m_dialog_bg:getChildByName("title");
    self.m_name = self.m_title_view:getChildByName("name");
    self.m_close_btn = self.m_title_view:getChildByName("close");
    self.m_close_btn:setOnClick(self,self.dismiss);
    self.m_share_btn = self.m_title_view:getChildByName("share");
    self.m_share_btn:setOnClick(self,self.shareMatch);
	if kPlatform == kPlatformIOS then
        -- AppStore审核开关，关闭分享和评论
        if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then 
            self.m_share_btn:setVisible(true);
        else
            self.m_share_btn:setVisible(false);
        end;
	else
        self.m_share_btn:setVisible(true);            
    end;

    -- content
    self.m_content_view = self.m_dialog_bg:getChildByName("content");
    self.m_left_btn = self.m_content_view:getChildByName("left");
    self.m_left_btn:setOnClick(self,self.onLeftBtnClick);
    self.m_left_btn_txt = self.m_left_btn:getChildByName("txt");
    self.m_left_line = self.m_content_view:getChildByName("left_line");
    self.m_left_view = self.m_content_view:getChildByName("left_view");

    self.m_right_btn = self.m_content_view:getChildByName("right");
    self.m_right_btn:setOnClick(self,self.onRightBtnClick);
    self.m_right_btn_txt = self.m_right_btn:getChildByName("txt");
    self.m_right_line = self.m_content_view:getChildByName("right_line");
    self.m_right_view = self.m_content_view:getChildByName("right_view");
    self.m_chamption_view = self.m_right_view:getChildByName("champion_view");
    self.m_second_view = self.m_right_view:getChildByName("second_view");
    -- bottom
    self.m_bottom_view = self.m_dialog_bg:getChildByName("bottom");
    self.m_join_btn = self.m_bottom_view:getChildByName("join");
    self.m_join_btn:setOnClick(self,self.onJoinBtnClick);
    self.m_join_txt = self.m_join_btn:getChildByName("txt");
    self.m_join_num = self.m_bottom_view:getChildByName("join_num");
    self.m_start_time = self.m_bottom_view:getChildByName("start_time");
    self.m_need_join_num = self.m_bottom_view:getChildByName("need_join_num")
end;

CompeteCoinDialog.init = function(self)
    self:setBtnsStatus(1);
    self:initContent();
    self.m_name:setText(self.datas.name);
    self.m_join_num:setText(self.datas.join_num or "0");
    self.m_need_join_num:setText( 8 - (tonumber(self.datas.join_num) or 0))
    self.m_start_time:setText(os.date("%m-%d %H:%M",self.datas.match_start_time));
    self:updateBtnStatus(self.datas.itemStatus);
end;

CompeteCoinDialog.updateBtnStatus = function(self, itemStatus)
    if itemStatus then
        local status = tonumber(itemStatus) or -1;
        --CompeteItem.JOIN     = 1;
        --CompeteItem.HAS_JOIN = 2;
        --CompeteItem.ENTRY    = 3;
        --CompeteItem.WATCH    = 4;
        --CompeteItem.WAITING  = 5;
        --CompeteItem.OVER     = 6;
        --CompeteItem.ERROR    = 7;
        if status == 1 then
            self.m_join_txt:setText("报名参赛");
            self.m_join_btn:setVisible(true);
            self.m_join_btn:setGray(false);
            self.m_join_btn:setPickable(true);
        elseif status == 2 then
            self.m_join_btn:setVisible(false);
        elseif status == 3 then
            self.m_join_btn:setVisible(false);
        elseif status == 4 then
            self.m_join_btn:setVisible(false);
        elseif status == 5 then
            self.m_join_txt:setText("即将开启");
            self.m_join_btn:setVisible(true);
            self.m_join_btn:setGray(true);
            self.m_join_btn:setPickable(false);
        elseif status == 6 then
            self.m_join_txt:setText("已结束");
            self.m_join_btn:setVisible(true);
            self.m_join_btn:setGray(true);
            self.m_join_btn:setPickable(false);          
        elseif status == 7 then
            self.m_join_btn:setVisible(false);
        end;
    else
        self.m_join_txt:setText(self.datas.join_money.."金币参赛");
        self.m_join_btn:setVisible(true);
        self.m_join_btn:setGray(false);
        self.m_join_btn:setPickable(true);
    end; 

end;

function CompeteCoinDialog:requestMatchRule()
    if self.mMatchRuleRequest then return end
    if self.mMatchRuleRequesting then return end
    self.mMatchRuleRequesting = true
    -- 拉取比赛规则
    local data = {};
    data.param = {};
    data.param.config_id = self.datas.id;
    HttpModule.getInstance():execute(HttpModule.s_cmds.getMatchRule, data)
end

CompeteCoinDialog.initContent = function(self)
    self.mMatchRuleRequest = false
    self:requestMatchRule()
    -- 显示奖励
    for i = 1,2 do
        if self.datas.prize and self.datas.prize[i] then
            local money = self.datas.prize[i].money or "";
            local soul = self.datas.prize[i].soul or "";
            local prize = "";
            if money ~= "" and tonumber(money) ~= 0 then
                prize = money .. "金币"
            end;
            if soul ~= "" and tonumber(soul) ~= 0 then
                prize = prize..","..soul .. "棋魂"
            end;       
            local prizeText = new(RichText,prize,250,0,kAlignTopLeft, nil, 32, 25, 115, 45, true,5); 
            prizeText:setAlign(kAlignTop); 
            if i == 1 then
                self.m_chamption_view:addChild(prizeText); 
            elseif i == 2 then
                self.m_second_view:addChild(prizeText); 
            end;
        end;
    end;
end;

CompeteCoinDialog.onHttpGetMatchRule = function(self,isSuccess,message)
    self.mMatchRuleRequesting = false
	if not isSuccess then
		return
	end
    self.mMatchRuleRequest = true
    local rule = message.data.rule_text:get_value();
    local richText = new(RichText,rule,645,0,kAlignTopLeft, nil, 32, 80, 80, 80, true,16);
    local w,h = richText:getSize();
    self.m_left_view:addChild(richText);
end;


CompeteCoinDialog.show = function( self )
	self.super.show(self, self.anim_dlg.showAnim)
end

CompeteCoinDialog.dismiss = function( self )
	self.super.dismiss(self, self.anim_dlg.dismissAnim)
end

CompeteCoinDialog.shareMatch = function(self)
    local schemesData = {};
    schemesData.method = "gotoMoneyRoom";
    local tab = {}
    tab.url = SchemesProxy.getWebSchemesUrl(schemesData)
    tab.title = "挑战赛邀请";
    tab.description = "博雅象棋增加比赛啦，报名玩快棋可以赢大额金币哦，快来和我一起参加吧~";
    if not self.commonShareDialog then
        self.commonShareDialog = new(CommonShareDialog);
    end
    self.commonShareDialog:setShareDate(tab,"arena_share");
    self.commonShareDialog:show();
    self:dismiss()  
end;

CompeteCoinDialog.setBtnsStatus = function(self, status)
    if status == 1 then
        self.m_left_btn_txt:setColor(215,75,45);
        self.m_left_line:setVisible(true);
        self.m_left_view:setVisible(true);
        self.m_right_btn_txt:setColor(135,100,95);
        self.m_right_line:setVisible(false);
        self.m_right_view:setVisible(false);
    elseif status == 2 then
        self.m_left_btn_txt:setColor(135,100,95);
        self.m_left_line:setVisible(false);
        self.m_left_view:setVisible(false);
        self.m_right_btn_txt:setColor(215,75,45);
        self.m_right_line:setVisible(true);
        self.m_right_view:setVisible(true);
    end;
end;


CompeteCoinDialog.onLeftBtnClick = function(self)
    self:setBtnsStatus(1);
    self:requestMatchRule()
end;

CompeteCoinDialog.onRightBtnClick = function(self)
    self:setBtnsStatus(2);
end;

CompeteCoinDialog.onJoinBtnClick = function(self)
    if self.datas then
        local money = UserInfo.getInstance():getMoney()
        local score = UserInfo.getInstance():getScore()
        if tonumber(self.datas.join_min_score) and tonumber(self.datas.join_min_score) > score then
            ChessToastManager.getInstance():showSingle( string.format("您的积分低于%d,赶紧去提升棋力吧!",tonumber(self.datas.join_min_score)))
            return ;
        elseif tonumber(self.datas.join_max_score) and tonumber(self.datas.join_max_score) < score then
            ChessToastManager.getInstance():showSingle( string.format("您的积分超过%d,请移步高级场次吧!",tonumber(self.datas.join_max_score)))
            return ;
        elseif tonumber(self.datas.join_min_money) and tonumber(self.datas.join_min_money) > money then
--            ChessToastManager.getInstance():showSingle( string.format("您的金币低于%d,赶紧去商城购买吧!",tonumber(self.datas.join_min_money)))
            if not self.m_goto_mall_dialog then
                self.m_goto_mall_dialog = new(ChioceDialog)
            end
            self.m_goto_mall_dialog:setMode(ChioceDialog.MODE_COMMON,"去商城","取消");
            self.m_goto_mall_dialog:setMessage( string.format("您的金币低于%d,赶紧去商城购买吧!",tonumber(self.datas.join_min_money)));
            self.m_goto_mall_dialog:setNegativeListener(nil,nil);
            self.m_goto_mall_dialog:setPositiveListener(self,function()
                StateMachine.getInstance():pushState(States.Mall,StateMachine.STYPE_CUSTOM_WAIT);
                self:dismiss()
            end);
            self.m_goto_mall_dialog:show();
            return ;
        elseif tonumber(self.datas.join_max_money) and tonumber(self.datas.join_max_money) < money then
            ChessToastManager.getInstance():showSingle( string.format("您的金币超过%d,请移步高级场次吧!",tonumber(self.datas.join_max_money)))
            return ;
        elseif UserInfo.getInstance():isLockCompete() then
            ChessToastManager.getInstance():showSingle( string.format("联网牌局到达%d局后自动解锁",UserInfo.getInstance():getLockCompete()))
            return 
        end
        if tonumber(self.datas.has_password) ~= 0 then
            delete(self.m_invitcode_dialog);
            self.m_invitcode_dialog = nil;
            self.m_invitcode_dialog = new(CompeteInviteCodeDialog,self.datas);
            self.m_invitcode_dialog:show();
        else
            self:joinCoinMatch();
        end;
    end

    self:dismiss();
end;

CompeteCoinDialog.joinCoinMatch = function(self)  
    local join_money = tonumber(self.datas.join_money) or 0
    if UserInfo.getInstance():getMoney() < join_money then
        ChessToastManager.getInstance():showSingle("金币不足")
        return
    end
    local info = {}
    info.level = self.datas.level
    RoomProxy.getInstance():gotoMoneyMatchRoom(info)
    self:dismiss();
end;

CompeteCoinDialog.refresh = function(self,datas)
    local join_num = tonumber(datas.join_num) or 0
	self.m_join_num:setText(join_num)
    self.m_need_join_num:setText( 8 - join_num )
end

CompeteCoinDialog.onHttpRequestsCallBack = function(self, command, ...)
	Log.i("CompeteCoinDialog.onHttpRequestsCallBack")
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self, ...)
	end 
end

CompeteCoinDialog.s_httpRequestsCallBackFuncMap = 
{
	[HttpModule.s_cmds.getMatchRule] = CompeteCoinDialog.onHttpGetMatchRule,
}