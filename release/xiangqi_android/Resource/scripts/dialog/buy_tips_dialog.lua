
require(VIEW_PATH .. "buy_tips_dialog_view");
require(BASE_PATH.."chessDialogScene");
BuyTipsDialog = class(ChessDialogScene,false);

BuyTipsDialog.MODE_SURE = 1;
BuyTipsDialog.MODE_AGREE = 2;
BuyTipsDialog.MODE_OK = 3;
BuyTipsDialog.MODE_OTHER = 4;

BuyTipsDialog.ctor = function(self)
    super(self,buy_tips_dialog_view);
	self.m_root_view = self.m_root;

	self.m_dialog_bg = self.m_root_view:getChildByName("chioce_bg");

	self.m_content_view = self.m_root_view:getChildByName("chioce_content_view");


	self.m_cancel_btn = self.m_content_view:getChildByName("chioce_cancel_btn");
	self.m_sure_btn = self.m_content_view:getChildByName("chioce_sure_btn");
	self.m_sure_texture = self.m_sure_btn:getChildByName("chioce_sure_text");
	self.m_cancel_texture = self.m_cancel_btn:getChildByName("chioce_cancel_text");
	self.m_close_btn = self.m_content_view:getChildByName("chioce_close_btn");

	self.m_ok_btn = self.m_content_view:getChildByName("chioce_ok_btn");
	self.m_ok_texture = self.m_ok_btn:getChildByName("chioce_ok_text");

	self.m_other_pay_btn = self.m_content_view:getChildByName("other_pay_btn");

	self.m_other_pay_btn:setOnClick(self,self.select_other_pay);

	self.m_message = self.m_content_view:getChildByName("chioce_message_handler");

	self.m_dialog_bg:setEventTouch(self,self.onTouch);

	self.m_cancel_btn:setOnClick(self,self.cancel);
	self.m_sure_btn:setOnClick(self,self.sure);
	self.m_close_btn:setOnClick(self,self.cancel);
	self.m_ok_btn:setOnClick(self,self.sure);
    self:setNeedMask(false)
	self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)
end

BuyTipsDialog.dtor = function(self)
	self.m_root_view = nil;
    self.mDialogAnim.stopAnim()
end

BuyTipsDialog.isShowing = function(self)
	return self:getVisible();
end

BuyTipsDialog.onTouch = function(self)
	print_string("BuyTipsDialog.onTouch");
end

BuyTipsDialog.show = function(self)
	print_string("BuyTipsDialog.show ... ");
	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
	self:setVisible(true);
    self.super.show(self,self.mDialogAnim.showAnim);
end

BuyTipsDialog.cancel = function(self)
	print_string("BuyTipsDialog.cancel ");
	self:dismiss();
	if self.m_negObj and self.m_negFunc then
		self.m_negFunc(self.m_negObj);
	end
end

BuyTipsDialog.sure = function(self)
	print_string("BuyTipsDialog.sure ");

	self:dismiss();
	if self.m_posObj and self.m_posFunc then
		self.m_posFunc(self.m_posObj);
	end
end

BuyTipsDialog.sure = function(self)
	print_string("BuyTipsDialog.sure ");

	self:dismiss();
	if self.m_posObj and self.m_posFunc then
		self.m_posFunc(self.m_posObj);
	end
end

BuyTipsDialog.select_other_pay = function(self)
	print_string("BuyTipsDialog.select_other_pay ");

	self:dismiss();
	if self.m_posObj and self.m_posFunc then
		self.m_posFunc(self.m_posObj);
	end
end

BuyTipsDialog.setMessage = function(self,message,align)
    self.m_message:removeAllChildren(true);
    local msg = new(RichText,message, 511, 0, align or kAlignCenter, nil, 32, 255, 255, 255, true,5)
 	self.m_message:addChild(msg);
end

BuyTipsDialog.setMode = function(self,mode,sure_str,cancel_str)
	self.m_mode = mode;	
	if self.m_mode == BuyTipsDialog.MODE_SURE then
		self.m_close_btn:setVisible(false);
		local sure_text = sure_str or "确定";
		self.m_sure_texture:setText(sure_text);

		local cancel_text = cancel_str or "取消";
		self.m_cancel_texture:setText(cancel_text);

		self.m_cancel_btn:setVisible(true);
		self.m_sure_btn:setVisible(true);

		self.m_ok_btn:setVisible(false);
	elseif self.m_mode == BuyTipsDialog.MODE_AGREE then

		self.m_close_btn:setVisible(false);
		local sure_text = sure_str or "同意";
		self.m_sure_texture:setText(sure_text);

		local cancel_text = cancel_str or "拒绝";
		self.m_cancel_texture:setText(cancel_text);

		self.m_cancel_btn:setVisible(true);
		self.m_sure_btn:setVisible(true);

		self.m_ok_btn:setVisible(false);
	elseif self.m_mode == BuyTipsDialog.MODE_OTHER then
		self.m_close_btn:setVisible(false);
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

BuyTipsDialog.setPositiveListener = function(self,obj,func)
	self.m_posObj = obj;
	self.m_posFunc = func;
end


BuyTipsDialog.setNegativeListener = function(self,obj,func)
	self.m_negObj = obj;
	self.m_negFunc = func;
end


BuyTipsDialog.dismiss = function(self)
	self.super.dismiss(self,self.mDialogAnim.dismissAnim)
end