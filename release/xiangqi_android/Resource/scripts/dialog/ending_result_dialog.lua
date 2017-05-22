require(VIEW_PATH .. "ending_result_dialog_view");
require(BASE_PATH .. "chessDialogScene")


EndingResultDialog = class(ChessDialogScene,false);

EndingResultDialog.win_texture  = "drawable/ending_win_texture.png";
EndingResultDialog.lose_texture  = "drawable/ending_lose_texture.png";



EndingResultDialog.ctor = function(self,roomController)
	super(self,ending_result_dialog_view);
	self.m_root_view = self.m_root;

	self.m_roomController = roomController;

	self.m_dialog_bg = self.m_root_view:getChildByName("ending_result_bg");

	self.m_content_view = self.m_root_view:getChildByName("ending_result_content_view");
	self.m_result_texture = self.m_content_view:getChildByName("ending_result_texture");


	self.m_cancel_btn = self.m_content_view:getChildByName("ending_result_cancel_btn");
	self.m_restart_btn = self.m_content_view:getChildByName("ending_result_restart_btn");
	self.m_reborn_btn = self.m_content_view:getChildByName("ending_result_reborn_btn");

	self.m_next_btn = self.m_content_view:getChildByName("ending_next_btn");

	self.m_ending_reward_bg = self.m_content_view:getChildByName("ending_reward_bg");
	self.m_ending_reward_texture = self.m_ending_reward_bg:getChildByName("ending_reward_texture");
	--self.m_ending_reward_num =  self.m_ending_reward_bg:getChildByName("ending_reward_num");
	self.m_ending_reward_win_tips = self.m_ending_reward_bg:getChildByName("ending_reward_win_tips");
	self.m_ending_reborn_tips = self.m_ending_reward_bg:getChildByName("ending_reborn_tips");

	self.m_dialog_bg:setEventTouch(self,self.onTouch);

	self.m_cancel_btn:setOnClick(self,self.cancel);
	self.m_restart_btn:setOnClick(self,self.restart);
	self.m_reborn_btn:setOnClick(self,self.reborn);
	self.m_next_btn:setOnClick(self,self.next);
    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)
end

EndingResultDialog.dtor = function(self)
    self.mDialogAnim.stopAnim()
end

EndingResultDialog.isShowing = function(self)
	return self:getVisible();
end

EndingResultDialog.onTouch = function(self)
	print_string("EndingResultDialog.onTouch");
end

EndingResultDialog.show = function(self)
	print_string("EndingResultDialog.show ... ");
	if kEndgateData:isLastGate() == true then
		self.m_next_btn:setVisible(false);
	end
	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
	self:setVisible(true);
    self.super.show(self,self.mDialogAnim.showAnim);
end


EndingResultDialog.cancel = function(self)
	print_string("EndingResultDialog.cancel ");
	self:dismiss();

end

EndingResultDialog.restart = function(self)
	print_string("EndingResultDialog.restart");

	self:dismiss();
	if self.m_roomController then
		self.m_roomController:restart();
	end
end

EndingResultDialog.reborn = function(self)
	print_string("EndingResultDialog.reborn ");

	self:dismiss();
	if self.m_roomController then
		self.m_roomController:revive();
	end
end


EndingResultDialog.next = function(self)
	print_string("EndingResultDialog.next ");

	self:dismiss();
	if self.m_roomController then
		self.m_roomController:loadNextGate();
	end
end


EndingResultDialog.setMode = function(self,isWin)

	if isWin then
		self.m_result_texture:setFile(EndingResultDialog.win_texture);
	else 
		self.m_result_texture:setFile(EndingResultDialog.lose_texture);
	end


	self.m_next_btn:setVisible(isWin);
	self.m_restart_btn:setVisible(not isWin);
	self.m_reborn_btn:setVisible(not isWin);

	--self.m_ending_reward_num:setVisible(not isWin);
	self.m_ending_reward_texture:setVisible(not isWin);
	self.m_ending_reborn_tips:setVisible(not isWin);
	self.m_ending_reward_win_tips:setVisible(isWin);





end


EndingResultDialog.dismiss = function(self)
	self.super.dismiss(self,self.mDialogAnim.dismissAnim)
end