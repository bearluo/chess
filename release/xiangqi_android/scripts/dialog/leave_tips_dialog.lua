require("view/view_config");
require(VIEW_PATH .. "leave_tips_dialog_view");
require(BASE_PATH.."chessDialogScene")
LeaveTipsDialog = class(ChessDialogScene,false);


LeaveTipsDialog.MS = 1000;

LeaveTipsDialog.ctor = function(self,isLeaveGame)
    super(self,leave_tips_dialog_view);
	self.m_root_view = self.m_root;

    self.m_dialog_view = self.m_root_view:getChildByName("dialog_view");
    self.m_dialog_view:setEventTouch(self.m_dialog_view,function() end);
	self.m_cancel_btn = self.m_dialog_view:getChildByName("cancel_btn");
	self.m_exit_btn = self.m_dialog_view:getChildByName("exit_btn");
	self.m_calls_btn = self.m_dialog_view:getChildByName("calls_btn");
	self.m_coins_btn = self.m_dialog_view:getChildByName("coins_btn");

	self.m_challenge_on_btn = self.m_dialog_view:getChildByName("challenge_on_btn");
	self.m_leave_btn = self.m_dialog_view:getChildByName("leave_btn");

	self.m_tips_content_text = self.m_dialog_view:getChildByName("tips_content_text");

	self.m_cancel_btn:setOnClick(self,self.cancel);
	self.m_exit_btn:setOnClick(self,self.exit);
	self.m_calls_btn:setOnClick(self,self.calls);
	self.m_coins_btn:setOnClick(self,self.coins);
	self.m_challenge_on_btn:setOnClick(self,self.cancel);
	self.m_leave_btn:setOnClick(self,self.exit);

    self:setShieldClick(self,self.cancel);

	if isLeaveGame then
		self.m_exit_btn:setVisible(true);
		self.m_calls_btn:setVisible(true);
		self.m_coins_btn:setVisible(true);

		self.m_challenge_on_btn:setVisible(false);
		self.m_leave_btn:setVisible(false);
		self.m_cancel_btn:setVisible(false);
	else
		self.m_exit_btn:setVisible(false);
		self.m_calls_btn:setVisible(false);
		self.m_coins_btn:setVisible(false);
		self.m_cancel_btn:setVisible(false);

		self.m_challenge_on_btn:setVisible(true);
		self.m_leave_btn:setVisible(true);
	end



end

LeaveTipsDialog.dtor = function(self)
	self.m_root_view = nil;
end

LeaveTipsDialog.isShowing = function(self)
	return self:getVisible();
end

LeaveTipsDialog.onTouch = function(self)
	print_string("==LeaveTipsDialog.onTouch===");
end

LeaveTipsDialog.show = function(self)
	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
	self:setVisible(true);
    self.super.show(self);
end

LeaveTipsDialog.setCancelListener = function(self,obj,func)
	self.cObj = obj;
	self.cFunc = func;
end

LeaveTipsDialog.cancel = function(self)
	print_string("LeaveTipsDialog.cancel ");
	if self.cObj and self.cFunc then
		self.cFunc(self.cObj);
	end
	self:dismiss();
end

LeaveTipsDialog.setMessage = function(self,message)
 	self.m_tips_content_text:setText(message);
end

LeaveTipsDialog.setExitListener = function(self,obj,func)
	self.m_exitObj = obj;
	self.m_exitFunc = func;
end

LeaveTipsDialog.exit = function(self)
	print_string("LeaveTipsDialog.exit");

	if self.m_exitObj and self.m_exitFunc then
		self.m_exitFunc(self.m_exitObj);
	end

	self:dismiss();
end

LeaveTipsDialog.setCallsListener = function(self,obj,func)
	self.m_callsObj = obj;
	self.m_callsFunc = func;
end

LeaveTipsDialog.calls = function(self)
	print_string("LeaveTipsDialog.calls");

	if self.m_callsObj and self.m_callsFunc then
		self.m_callsFunc(self.m_callsObj);
	end

	self:dismiss();
end

LeaveTipsDialog.setCoinsListener = function(self,obj,func)
	self.m_coinsObj = obj;
	self.m_coinsFunc = func;
end

LeaveTipsDialog.coins = function(self)
	print_string("LeaveTipsDialog.coins");

	if self.m_coinsObj and self.m_coinsFunc then
		self.m_coinsFunc(self.m_coinsObj);
	end

	self:dismiss();
end

--LeaveTipsDialog.dismiss = function(self)
--	self:setVisible(false);
--end
