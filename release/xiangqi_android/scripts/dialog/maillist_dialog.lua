
require(VIEW_PATH .. "maillist_dialog_view");
require(BASE_PATH.."chessDialogScene")

--exitguanzhu_dialog
MailListDialog = class(ChessDialogScene,false);

MailListDialog.MODE_SURE = 1;
MailListDialog.MODE_AGREE = 2;
MailListDialog.MODE_OK = 3;
MailListDialog.MODE_OTHER = 4;

MailListDialog.ctor = function(self)
    super(self,maillist_dialog_view);
	self.m_root_view = self.m_root;
    self.m_content_view = self.m_root_view:getChildByName("bg");

	self.m_cancel_btn = self.m_content_view:getChildByName("cancel_btn");
	self.m_sure_btn = self.m_content_view:getChildByName("sure_btn");

	self.m_cancel_btn:setOnClick(self,self.cancel);
	self.m_sure_btn:setOnClick(self,self.sure);

    local func =  function(view,enable)
        local tip = view:getChildByName("text");
        if tip then
            if not enable then
                tip:setColor(255,255,255);
                tip:addPropScaleSolid(1,1.1,1.1,1);
            else
                tip:setColor(240,230,210);
                tip:removeProp(1);
            end
        end
    end

    self.m_cancel_btn:setOnTuchProcess(self.m_cancel_btn,func);
    self.m_sure_btn:setOnTuchProcess(self.m_sure_btn,func);
end

MailListDialog.dtor = function(self)
    delete(self.m_root_view);
	self.m_root_view = nil;
end

MailListDialog.isShowing = function(self)
	return self:getVisible();
end

MailListDialog.onTouch = function(self)
	print_string("MailListDialog.onTouch");
end

MailListDialog.show = function(self)
	print_string("MailListDialog.show ... ");
	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
	self:setVisible(true);
end

MailListDialog.cancel = function(self)
	print_string("MailListDialog.cancel ");
	self:dismiss();
	if self.m_negObj and self.m_negFunc then
		self.m_negFunc(self.m_negObj);
	end
end

MailListDialog.sure = function(self)
	print_string("MailListDialog.sure ");

	self:dismiss();
	if self.m_posObj and self.m_posFunc then
		self.m_posFunc(self.m_posObj);
	end
end


--MailListDialog.setMessage = function(self,message)
-- 	self.m_message:setText(message);
--end

--MailListDialog.setMode = function(self,mode,sure_str,cancel_str)
--	self.m_mode = mode;	
--	if self.m_mode == MailListDialog.MODE_SURE then
--		self.m_close_btn:setVisible(false);
--		local sure_text = sure_str or "确定";
--		self.m_sure_texture:setText(sure_text);

--		local cancel_text = cancel_str or "取消";
--		self.m_cancel_texture:setText(cancel_text);

--		self.m_cancel_btn:setVisible(true);
--		self.m_sure_btn:setVisible(true);

--		self.m_ok_btn:setVisible(false);
--	elseif self.m_mode == MailListDialog.MODE_AGREE then

--		self.m_close_btn:setVisible(false);
--		local sure_text = sure_str or "同意";
--		self.m_sure_texture:setText(sure_text);

--		local cancel_text = cancel_str or "拒绝";
--		self.m_cancel_texture:setText(cancel_text);

--		self.m_cancel_btn:setVisible(true);
--		self.m_sure_btn:setVisible(true);

--		self.m_ok_btn:setVisible(false);
--	elseif self.m_mode == MailListDialog.MODE_OTHER then
--		self.m_close_btn:setVisible(true);
--		self.m_cancel_btn:setVisible(false);
--		self.m_sure_btn:setVisible(false);

--		local sure_text = sure_str or "确定";
--		self.m_ok_texture:setText(sure_text);
--		self.m_ok_btn:setVisible(true);
--	else
--		self.m_cancel_btn:setVisible(false);
--		self.m_sure_btn:setVisible(false);
--		self.m_close_btn:setVisible(false);

--		local sure_text = sure_str or "确定";
--		self.m_ok_texture:setText(sure_text);
--		self.m_ok_btn:setVisible(true);
--	end

--end

MailListDialog.setPositiveListener = function(self,obj,func)
	self.m_posObj = obj;
	self.m_posFunc = func;
end


MailListDialog.setNegativeListener = function(self,obj,func)
	self.m_negObj = obj;
	self.m_negFunc = func;
end


MailListDialog.dismiss = function(self)
	self:setVisible(false);
end