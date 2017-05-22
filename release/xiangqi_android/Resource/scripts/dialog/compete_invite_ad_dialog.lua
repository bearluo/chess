require(VIEW_PATH .. "compete_invite_ad_dialog")

CompeteInviteAdDialog = class(ChessDialogScene, false)

CompeteInviteAdDialog.ctor = function( self, datas)
	super(self, compete_invite_ad_dialog)
	self.anim_dlg = AnimDialogFactory.createNormalAnim(self)
	self.datas = datas
	self:initView()
    self:init();
end

CompeteInviteAdDialog.dtor = function( self )
	self.anim_dlg:stopAnim()
end

CompeteInviteAdDialog.initView = function(self)
    self.m_root_view = self.m_root;
    self.m_dialog_bg_img = self.m_root_view:getChildByName("bg");
    -- ad_bg
    self.m_ad_bg = new(Mask,"common/background/default_match_ad.png","common/background/default_match_ad_mask.png");
    self.m_ad_bg:setFillParent(true,true);
    self.m_ad_bg:setAlign(kAlignCenter);
    self.m_dialog_bg_img:addChild(self.m_ad_bg);
    -- match_info
    self.m_match_info = self.m_dialog_bg_img:getChildByName("match_info");
    self.m_match_info:setLevel(1);
    self.m_title = self.m_match_info:getChildByName("title");
    self.m_match_time = self.m_match_info:getChildByName("time");
    -- go_btn
    self.m_go_btn = self.m_dialog_bg_img:getChildByName("go");
    self.m_go_btn:setLevel(1);
    self.m_go_btn:setOnClick(self, self.onGoBtnClick);

    -- close
    self.m_close_btn = self.m_dialog_bg_img:getChildByName("close");
    self.m_close_btn:setLevel(1);
    self.m_close_btn:setOnClick(self, self.dismiss);
end;

CompeteInviteAdDialog.init = function(self)
    if self.datas then
        self.m_title:setText(self.datas.name or "");
        self.m_ad_bg:setUrlImage(self.datas.img_url or "","common/background/default_match_ad.png");
        local isSecondDay = ToolKit.isSecondDay(self.datas.match_start_time or "0",self.datas.match_end_time or "0");
        local time = "";
        local start_time = os.date("%Y/%m/%d %H:%M",self.datas.match_start_time or "0");
        local end_time = "";
        if isSecondDay then
            end_time = os.date("%Y/%m/%d %H:%M",self.datas.match_end_time or "0");
        else
            end_time = os.date("%H:%M",self.datas.match_end_time or "0");
        end; 
        time = start_time .. "~" .. end_time;
        self.m_match_time:setText(time);
    end;
end;

CompeteInviteAdDialog.onGoBtnClick = function(self)
    if UserInfo.getInstance():isFreezeUser() then return end;
    StateMachine.getInstance():pushState(States.Compete,StateMachine.STYPE_CUSTOM_WAIT);
    self:dismiss();
end;

CompeteInviteAdDialog.show = function( self )
	self.super.show(self, self.anim_dlg.showAnim)
end

CompeteInviteAdDialog.dismiss = function( self )
	self.super.dismiss(self, self.anim_dlg.dismissAnim)
end