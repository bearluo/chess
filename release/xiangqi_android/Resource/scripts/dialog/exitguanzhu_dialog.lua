
--require("view/Android_800_480/chioce_dialog_view");
require(VIEW_PATH .. "exit_guanzhu_view");
require(BASE_PATH.."chessDialogScene")

ExitGuanzhuDialog = class(ChessDialogScene,false);

ExitGuanzhuDialog.MODE_SURE = 1;
ExitGuanzhuDialog.MODE_AGREE = 2;
ExitGuanzhuDialog.MODE_OK = 3;
ExitGuanzhuDialog.MODE_OTHER = 4;

ExitGuanzhuDialog.ctor = function(self)
    super(self,exit_guanzhu_view);
	self.m_root_view = self.m_root;
    self.m_content_view = self.m_root_view:getChildByName("chioce_content_view");

    self.chioce_dialog_bg = self.m_content_view:getChildByName("chioce_dialog_bg");

	self.m_cancel_btn = self.chioce_dialog_bg:getChildByName("cancel_btn");
	self.m_sure_btn = self.chioce_dialog_bg:getChildByName("sure_btn");

	self.m_cancel_btn:setOnClick(self,self.cancel);
	self.m_sure_btn:setOnClick(self,self.sure);

end

ExitGuanzhuDialog.dtor = function(self)
    delete(self.m_root_view);
	self.m_root_view = nil;
end

ExitGuanzhuDialog.isShowing = function(self)
	return self:getVisible();
end

ExitGuanzhuDialog.onTouch = function(self)
	print_string("ExitGuanzhuDialog.onTouch");
end

ExitGuanzhuDialog.show = function(self)
	print_string("ExitGuanzhuDialog.show ... ");
	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
	self:setVisible(true);
end

ExitGuanzhuDialog.cancel = function(self)
	print_string("ExitGuanzhuDialog.cancel ");
	self:dismiss();
	if self.m_negObj and self.m_negFunc then
		self.m_negFunc(self.m_negObj);
	end
end

ExitGuanzhuDialog.sure = function(self)
	print_string("ExitGuanzhuDialog.sure ");

	self:dismiss();
	if self.m_posObj and self.m_posFunc then
		self.m_posFunc(self.m_posObj);
	end
end


ExitGuanzhuDialog.setMessage = function(self,message)
 	self.m_message:setText(message);
end

ExitGuanzhuDialog.setMode = function(self,mode,sure_str,cancel_str)
	self.m_mode = mode;	
	if self.m_mode == ExitGuanzhuDialog.MODE_SURE then
		self.m_close_btn:setVisible(false);
		local sure_text = sure_str or "确定";
		self.m_sure_texture:setText(sure_text);

		local cancel_text = cancel_str or "取消";
		self.m_cancel_texture:setText(cancel_text);

		self.m_cancel_btn:setVisible(true);
		self.m_sure_btn:setVisible(true);

		self.m_ok_btn:setVisible(false);
	elseif self.m_mode == ExitGuanzhuDialog.MODE_AGREE then

		self.m_close_btn:setVisible(false);
		local sure_text = sure_str or "同意";
		self.m_sure_texture:setText(sure_text);

		local cancel_text = cancel_str or "拒绝";
		self.m_cancel_texture:setText(cancel_text);

		self.m_cancel_btn:setVisible(true);
		self.m_sure_btn:setVisible(true);

		self.m_ok_btn:setVisible(false);
	elseif self.m_mode == ExitGuanzhuDialog.MODE_OTHER then
		self.m_close_btn:setVisible(true);
		self.m_cancel_btn:setVisible(false);
		self.m_sure_btn:setVisible(false);

		local sure_text = sure_str or "确定";
		self.m_ok_texture:setText(sure_text);
		self.m_ok_btn:setVisible(true);
	else
		self.m_cancel_btn:setVisible(false);
		self.m_sure_btn:setVisible(false);
		self.m_close_btn:setVisible(false);

		local sure_text = sure_str or "确定";
		self.m_ok_texture:setText(sure_text);
		self.m_ok_btn:setVisible(true);
	end

end

ExitGuanzhuDialog.setPositiveListener = function(self,obj,func)
	self.m_posObj = obj;
	self.m_posFunc = func;
end


ExitGuanzhuDialog.setNegativeListener = function(self,obj,func)
	self.m_negObj = obj;
	self.m_negFunc = func;
end


ExitGuanzhuDialog.dismiss = function(self)
	self:setVisible(false);
end