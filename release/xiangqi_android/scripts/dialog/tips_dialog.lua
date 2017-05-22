require(VIEW_PATH .. "tips_dialog_view");


TipsDialog = class();



TipsDialog.ctor = function(self)

	self.m_scene = new(Scene,tips_dialog_view);
	self.m_root_view = self.m_scene:getRoot();

	self.m_dialog_bg = self.m_root_view:getChildByName("tips_dialog_full_screen_bg");

	self.m_message = self.m_root_view:getChildByName("tips_text");

	self.m_dialog_bg:setEventTouch(self,self.onTouch);

	self.m_root_view:setVisible(false);
end

TipsDialog.dtor = function(self)
	self.m_root_view = nil;

end

TipsDialog.isShowing = function(self)
	return self.m_root_view:getVisible();
end

TipsDialog.onTouch = function(self)
	print_string("TipsDialog.onTouch");
	self:dismiss();
end

TipsDialog.show = function(self,message,parent_view)
	print_string("TipsDialog.show ... ");
	self.m_parent_view  = parent_view;
    if self.m_parent_view then
    	self.m_parent_view:setPickable(false);
    end

    self:setMessage(message);
	SoundManager.getInstance():play_effect(SoundManager.AUDIO_DIALOG_SHOW);
	self.m_root_view:setVisible(true);
end

TipsDialog.setMessage = function(self,message)
 	self.m_message:setText(GameString.convert(message));
end



TipsDialog.dismiss = function(self)
    if self.m_parent_view then
    	self.m_parent_view:setPickable(true);
    	self.m_parent_view = nil;
    end
	self.m_root_view:setVisible(false);
end