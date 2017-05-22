require(VIEW_PATH .. "online_box_reward_dialog");
require(BASE_PATH.."chessDialogScene")
OnlineBoxRewardDialog = class(ChessDialogScene,false);

OnlineBoxRewardDialog.ctor = function(self,msg)
	super(self,online_box_reward_dialog);
	self.m_root_view = self.m_root;
	self.m_pop_image_bg = self.m_root_view:getChildByName("pop_image_bg");
	self.m_msg_tips_text = self.m_pop_image_bg:getChildByName("msg_tips_text");
	self.m_msg_tips_text:setText(msg);
    self:setFillParent(true,false);
    self:setAlign(kAlignBottom);
	self:setVisible(false);
    self:setNeedMask(false)
end

OnlineBoxRewardDialog.dtor = function(self)
	self.m_root_view = nil;

end
-- 
OnlineBoxRewardDialog.isShowing = function(self)
	return self:getVisible();
end

OnlineBoxRewardDialog.onTouch = function(self)
	print_string("SettingDialog.onTouch");
	self:dismiss();
end

OnlineBoxRewardDialog.show = function(self,msg)
	self:setVisible(true);
    self.super.show(self,false);
	if msg then
		self.m_msg_tips_text:setText(msg);
	end

	self.animTimer = new(AnimInt,kAnimNormal,0,1,2500,-1);
	self.animTimer:setEvent(self,self.dismiss);
end

OnlineBoxRewardDialog.dismiss = function(self)
	if self.animTimer then
		delete(self.animTimer);
		self.animTimer = nil;
	end
    self.super.dismiss(self,false);
	self:setVisible(false);
end