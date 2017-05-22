require(VIEW_PATH .. "forestall_dialog_view");
require(BASE_PATH.."chessDialogScene")
ForestallDialog = class(ChessDialogScene,false);




ForestallDialog.ctor = function(self)
	super(self,forestall_dialog_view);
	self.m_root_view = self.m_root;

	self.m_dialog_bg = self.m_root_view:getChildByName("forestall_full_screen_bg");

	self.m_content_view = self.m_root_view:getChildByName("forestall_content_view");


	self.m_cancel_btn = self.m_content_view:getChildByName("forestall_cancel_btn");
	self.m_sure_btn = self.m_content_view:getChildByName("forestall_sure_btn");
	

	self.m_timeout_text = self.m_sure_btn:getChildByName("forestall_sure_text");


	self.m_dialog_bg:setEventTouch(self,self.onTouch);

	self.m_cancel_btn:setOnClick(self,self.cancel);
	self.m_sure_btn:setOnClick(self,self.sure);

    self:setNeedBackEvent(false);
	self:setVisible(false);
    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)
end

ForestallDialog.dtor = function(self)
	self.m_root_view = nil;
    self.mDialogAnim.stopAnim()
end

ForestallDialog.isShowing = function(self)
	return self:getVisible();
end

ForestallDialog.onTouch = function(self)
	print_string("ForestallDialog.onTouch");
end

ForestallDialog.show = function(self,time)
	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
	self.m_timeout = time or 15;
	--print_string("ForestallDialog.show .. time = " .. time );
	self:startTimeout();
	self:setVisible(true);
    self.super.show(self,self.mDialogAnim.showAnim);

end



ForestallDialog.startTimeout = function(self)
	self:stopTimeout();
	self.m_timeout_text:setText("抢先行(" .. self.m_timeout..'s)');
	self.m_timeoutAnim = new(AnimInt,kAnimLoop,0,1,1000,-1);
	self.m_timeoutAnim:setDebugName("ForestallDialog.startTimeout.m_timeoutAnim");
	
	self.m_timeoutAnim:setEvent(self,self.timeoutRun);
end

ForestallDialog.stopTimeout = function(self)
	if self.m_timeoutAnim then
		delete(self.m_timeoutAnim);
		self.m_timeoutAnim = nil;
	end
end

ForestallDialog.timeoutRun = function(self)
	self.m_timeout =  self.m_timeout - 1;
	if self.m_timeout  < 0 then
		self:dismiss();
		return;
	end
	self.m_timeout_text:setText("抢先行(" .. self.m_timeout..'s)');

end


ForestallDialog.cancel = function(self)
	print_string("ForestallDialog.cancel ");
	if self.m_negObj and self.m_negFunc then
		self.m_negFunc(self.m_negObj);
	end
	self:dismiss();


end

ForestallDialog.sure = function(self)
	print_string("ForestallDialog.sure ");

	self:dismiss();
	if self.m_posObj and self.m_posFunc then
		self.m_posFunc(self.m_posObj);
	end

end

ForestallDialog.setPositiveListener = function(self,obj,func)
	self.m_posObj = obj;
	self.m_posFunc = func;
end


ForestallDialog.setNegativeListener = function(self,obj,func)
	self.m_negObj = obj;
	self.m_negFunc = func;
end


ForestallDialog.dismiss = function(self)
	self:stopTimeout();
--	self:setVisible(false);
    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
end