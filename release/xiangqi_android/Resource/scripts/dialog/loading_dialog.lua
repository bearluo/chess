require(VIEW_PATH .. "loading_dialog_view");
require(BASE_PATH.."chessDialogScene")
LoadingDialog = class(ChessDialogScene,false);


LoadingDialog.MODE_SURE = 1;
LoadingDialog.MODE_AGREE = 2;
LoadingDialog.MODE_OK = 3;



LoadingDialog.ctor = function(self)

    super(self,loading_dialog_view);
	self.m_root_view = self.m_root;

	self.m_dialog_bg = self.m_root_view:getChildByName("loading_dialog_full_screen_bg");

	self.m_content_view = self.m_root_view:getChildByName("loading_content_view");

    self.m_loading_dialog_bg = self.m_content_view:getChildByName("loading_dialog_bg");

	self.m_cancel_btn = self.m_content_view:getChildByName("loading_cancel_btn");

	self.m_tips_view = self.m_content_view:getChildByName("tips_view");

	self.m_timeout_text = self.m_content_view:getChildByName("loading_time_text");


	self.m_dialog_bg:setEventTouch(self,self.onTouch);

	self.m_cancel_btn:setOnClick(self,self.cancel);

    self:setNeedBackEvent(false);
	self:setVisible(false);
end

LoadingDialog.dtor = function(self)
	self.m_root_view = nil;
    delete(self.m_timeoutAnim);
end

LoadingDialog.isShowing = function(self)
	return self:getVisible();
end

LoadingDialog.onTouch = function(self)
	print_string("LoadingDialog.onTouch");
end

LoadingDialog.show = function(self,time)
	self.m_timeout = time or 60;
    kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
	self:startTimeout();
	self:setVisible(true);
    self.super.show(self);

end



LoadingDialog.startTimeout = function(self)
	self:stopTimeout();
	self.m_timeout_text:setText("" .. self.m_timeout.."s");
	self.m_timeoutAnim = new(AnimInt,kAnimLoop,0,1,1000,-1);
	self.m_timeoutAnim:setDebugName("LoadingDialog.startTimeout.m_timeoutAnim");
	
	self.m_timeoutAnim:setEvent(self,self.timeoutRun);
end

LoadingDialog.stopTimeout = function(self)
	if self.m_timeoutAnim then
		delete(self.m_timeoutAnim);
		self.m_timeoutAnim = nil;
	end
end

LoadingDialog.timeoutRun = function(self)
	self.m_timeout =  self.m_timeout - 1;
	if self.m_timeout  < 0 then
		self:cancel();
		return;
	end
	self.m_timeout_text:setText("" .. self.m_timeout.."s");

end


LoadingDialog.cancel = function(self)
	print_string("LoadingDialog.cancel ");
	if self.m_negObj and self.m_negFunc then
		self.m_negFunc(self.m_negObj);
	end
	self:dismiss();


end




LoadingDialog.setMessage = function(self,message)
    self.m_tips_view:removeAllChildren(true);
    local w,h = self.m_tips_view:getSize();
    local text = new(TextView,GameString.convert2UTF8(message), w + 50, 0, kAlignCenter, nil, 36, 240, 230, 210);
    local tw,th = text:getSize();
    text:setAlign(kAlignLeft);
    self.m_tips_view:addChild(text);
    if th > h then 
        h = th+10;
    end
    self.m_loading_dialog_bg:setSize(nil,h);
end



LoadingDialog.setNegativeListener = function(self,obj,func)
	self.m_negObj = obj;
	self.m_negFunc = func;
end


LoadingDialog.dismiss = function(self)
	self:stopTimeout();
--	self:setVisible(false);
    self.super.dismiss(self);
end