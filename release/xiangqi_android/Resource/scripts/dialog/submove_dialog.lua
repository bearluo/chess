require(VIEW_PATH .. "submove_dialog_view");
SubMoveDialog = class();




SubMoveDialog.ctor = function(self)

	self.m_scene = new(Scene,submove_dialog_view);
	self.m_root_view = self.m_scene:getRoot();

	self.m_dialog_bg = self.m_root_view:getChildByName("submove_dialog_full_screen");

	self.m_content_view = self.m_root_view:getChildByName("submove_content_view");


	self.m_select1_btn = self.m_content_view:getChildByName("submove1_btn");
	self.m_select2_btn = self.m_content_view:getChildByName("submove2_btn");
	self.m_select3_btn = self.m_content_view:getChildByName("submove3_btn");

	self.m_select1_btn:setVisible(false);
    self.m_select2_btn:setVisible(false);
    self.m_select3_btn:setVisible(false);

	self.m_select1_btn:setOnClick(self,self.select1);
	self.m_select2_btn:setOnClick(self,self.select2);
	self.m_select3_btn:setOnClick(self,self.select3);




	self.m_root_view:setVisible(false);
end

SubMoveDialog.dtor = function(self)
	self.m_root_view = nil;

end

SubMoveDialog.isShowing = function(self)
	return self.m_root_view:getVisible();
end

SubMoveDialog.onTouch = function(self)
	print_string("SubMoveDialog.onTouch");
end

SubMoveDialog.show = function(self,parent_view)
	print_string("SubMoveDialog.show ... ");
	self.m_parent_view  = parent_view;
    if self.m_parent_view then
    	self.m_parent_view:setPickable(false);
    end

	SoundManager.getInstance():play_effect(SoundManager.AUDIO_DIALOG_SHOW);
	self.m_root_view:setVisible(true);
end



SubMoveDialog.select1 = function(self)
	print_string("SubMoveDialog.select1");

	self:dismiss();
	if self.m_select1Obj and self.m_select1Func then
		self.m_select1Func(self.m_select1Obj);
	end
end

SubMoveDialog.select2 = function(self)
	print_string("SubMoveDialog.select2");

	self:dismiss();
	if self.m_select2Obj and self.m_select2Func then
		self.m_select2Func(self.m_select2Obj);
	end
end

SubMoveDialog.select3 = function(self)
	print_string("SubMoveDialog.select3");

	self:dismiss();
	if self.m_select3Obj and self.m_select3Func then
		self.m_select3Func(self.m_select3Obj);
	end
end



SubMoveDialog.setSubNum = function(self,num)
	if num > 0 then
		self.m_select1_btn:setVisible(true);
	end

	if num > 1 then
		self.m_select2_btn:setVisible(true);
	end

	if num > 2 then
		self.m_select3_btn:setVisible(true);
	end
end

SubMoveDialog.setSelect1Listener = function(self,obj,func)
	self.m_select1Obj = obj;
	self.m_select1Func = func;
end

SubMoveDialog.setSelect2Listener = function(self,obj,func)
	self.m_select2Obj = obj;
	self.m_select2Func = func;
end

SubMoveDialog.setSelect3Listener = function(self,obj,func)
	self.m_select3Obj = obj;
	self.m_select3Func = func;
end



SubMoveDialog.dismiss = function(self)
    if self.m_parent_view then
    	self.m_parent_view:setPickable(true);
    	self.m_parent_view = nil;
    end
    self.m_select1_btn:setVisible(false);
    self.m_select2_btn:setVisible(false);
    self.m_select3_btn:setVisible(false);
	self.m_root_view:setVisible(false);
end