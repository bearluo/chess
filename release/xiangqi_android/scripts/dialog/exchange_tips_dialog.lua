require(VIEW_PATH .. "exchange_tips_dialog");
require(BASE_PATH.."chessDialogScene");
ExchangeTipsDialog = class(ChessDialogScene,false);

ExchangeTipsDialog.ctor = function(self,title,tips)
    super(self,exchange_tips_dialog);
	self.m_root_view = self.m_root;
	self.m_dialog_bg = self.m_root_view:getChildByName("view_bg");

	self.m_dialog_view = self.m_root_view:getChildByName("dialog_view");
	self.m_dialog_view_bg = self.m_dialog_view:getChildByName("dialog_view_bg");
	self.m_tips_content = self.m_dialog_view_bg:getChildByName("tips_content_text");

	self.m_dialog_title_text = self.m_dialog_view:getChildByName("title_text");

	self.m_dialog_title_text:setText(title);
	self.m_tips_content:setText(tips);

	self.m_ok_btn = self.m_dialog_view:getChildByName("ok_btn");


	self.m_ok_btn:setOnClick(self,self.ok_action);
	self.m_dialog_bg:setEventTouch(self,self.onTouch);

    self:setVisible(false);
end

ExchangeTipsDialog.dtor = function(self)
	self.m_root_view = nil;
end

ExchangeTipsDialog.isShowing = function(self)
	return self:getVisible();
end

ExchangeTipsDialog.onTouch = function(self)
	print_string("ExchangeTipsDialog.onTouch");
end

ExchangeTipsDialog.show = function(self,title,tips)
	print_string("ExchangeTipsDialog.show ... ");
	self.m_dialog_title_text:setText(title);
	self.m_tips_content:setText(tips);

	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
	self:setVisible(true);
    self.super.show(self);
end

ExchangeTipsDialog.cancel = function(self)
	print_string("ExchangeTipsDialog.cancel");
	self:dismiss();
end

ExchangeTipsDialog.dismiss = function(self)
	self:setVisible(false);
    self.super.dismiss(self);
end

ExchangeTipsDialog.ok_action = function(self)
	self:cancel();
end

ExchangeTipsDialog.islegal = function(self,str)
	local date = "%D"
	if not string.find(str, date) then --非数字
		return true;
	else
		return false;
	end
end