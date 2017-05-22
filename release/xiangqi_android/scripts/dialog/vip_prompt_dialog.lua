--region NewFile_1.lua
--Author : ford
--Date   : 2016/2/21
--endregion

require(VIEW_PATH .. "vip_prompt_dialog_view");
require(BASE_PATH.."chessDialogScene")

VipPromptDialog = class(ChessDialogScene,false);

VipPromptDialog.ctor = function(self)
    super(self,vip_prompt_dialog_view);
    self.m_root_view = self.m_root;

    self.m_content_view = self.m_root_view:getChildByName("content_view");
    self.m_message = self.m_content_view:getChildByName("Image2"):getChildByName("message");

    self.m_cancel_btn = self.m_content_view:getChildByName("cancel_btn");
	self.m_sure_btn = self.m_content_view:getChildByName("sure_btn");

    self.m_cancel_btn:setOnClick(self,self.cancel);
	self.m_sure_btn:setOnClick(self,self.sure);

    self:setVisible(false);

end

VipPromptDialog.dtor = function(self)
    delete(self.m_root_view);
	self.m_root_view = nil;
end

VipPromptDialog.isShowing = function(self)
    return self:getVisible();
end

VipPromptDialog.show = function(self)
  	print_string("VipPromptDialog.show ... ");
	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
	self:setVisible(true);
    self.super.show(self);

    local msg = "1.每日登陆可领2000金币 \n2.会员去广告 \n3.特殊头像框显示  \n4.特殊棋盘 \n5.特殊勋章标识"
    self:setMessage(msg);
end

VipPromptDialog.dismiss = function(self)
    self.super.dismiss(self);
end


VipPromptDialog.cancel = function(self)
	print_string("ChioceDialog.cancel ");
	self:dismiss();
--    self.m_check_btn:setVisible(false);
	if self.m_negObj and self.m_negFunc then
		self.m_negFunc(self.m_negObj);
	end
end

VipPromptDialog.sure = function(self)
	print_string("ChioceDialog.sure ");
	self:dismiss();
	if self.m_posObj and self.m_posFunc then
		self.m_posFunc(self.m_posObj,self.m_posArg);
	end
end

VipPromptDialog.setPositiveListener = function(self,obj,func,arg) -- 增加arg参数，当点击确定的时候返回
	self.m_posObj = obj;
	self.m_posFunc = func;
    self.m_posArg = arg;
end

VipPromptDialog.onTouch = function(self)
	print_string("VipPromptDialog.onTouch");
end

VipPromptDialog.setNegativeListener = function(self,obj,func)
	self.m_negObj = obj;
	self.m_negFunc = func;
end

VipPromptDialog.setMessage = function(self,message)
 	self.m_message:setText(message);
end
