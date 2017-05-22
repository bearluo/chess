
require(VIEW_PATH .. "dapu_create_endgate_dialog_view");
require(BASE_PATH.."chessDialogScene")
DapuCreateEndgateDialog = class(ChessDialogScene,false);

DapuCreateEndgateDialog.ctor = function(self)
    super(self,dapu_create_endgate_dialog_view);
	self.m_root_view = self.m_root;

	self.m_dialog_bg = self.m_root_view:getChildByName("bg");

	self.m_sure_btn = self.m_dialog_bg:getChildByName("chioce_sure_btn");
    self.m_cancel_btn = self.m_dialog_bg:getChildByName("chioce_cancel_btn");
    self.m_edit = self.m_dialog_bg:getChildByName("edit_bg"):getChildByName("edit");
    self.m_edit:setHintText("请输入残局名称不超过8个字",165,145,120);
	self.m_message = self.m_dialog_bg:getChildByName("title");

	self.m_dialog_bg:setEventTouch(self,self.onTouch);

	self.m_sure_btn:setOnClick(self,self.sure);
    self.m_cancel_btn:setOnClick(self,self.cancel);
end

DapuCreateEndgateDialog.dtor = function(self)
    delete(self.m_root_view);
	self.m_root_view = nil;
end

DapuCreateEndgateDialog.isShowing = function(self)
	return self:getVisible();
end

DapuCreateEndgateDialog.onTouch = function(self)
	print_string("DapuCreateEndgateDialog.onTouch");
end

DapuCreateEndgateDialog.show = function(self)
	print_string("DapuCreateEndgateDialog.show ... ");
	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
	self:setVisible(true);
    self.super.show(self);
end

DapuCreateEndgateDialog.cancel = function(self)
	print_string("DapuCreateEndgateDialog.cancel ");
	self:dismiss();
	if self.m_negObj and self.m_negFunc then
		self.m_negFunc(self.m_negObj);
	end
end

DapuCreateEndgateDialog.sure = function(self)
	print_string("DapuCreateEndgateDialog.sure ");
	self:dismiss();
	if self.m_posObj and self.m_posFunc then
		self.m_posFunc(self.m_posObj,self.m_edit:getText());
	end
end


DapuCreateEndgateDialog.setMessage = function(self,message)
 	self.m_message:setText(message);
end

DapuCreateEndgateDialog.setPositiveListener = function(self,obj,func) -- 增加arg参数，当点击确定的时候返回
	self.m_posObj = obj;
	self.m_posFunc = func;
end


DapuCreateEndgateDialog.setNegativeListener = function(self,obj,func)
	self.m_negObj = obj;
	self.m_negFunc = func;
end

--DapuCreateEndgateDialog.dismiss = function(self)
--	self.super.dismiss(self);
--end