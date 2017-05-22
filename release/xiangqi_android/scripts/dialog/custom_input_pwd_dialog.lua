require(VIEW_PATH .. "custom_input_pwd_dialog_view");
--require("view/Android_800_480/create_room_dialog_view");
require("dialog/time_picker_dialog");
require(BASE_PATH.."chessDialogScene")
InputPwdDialog = class(ChessDialogScene,false);

InputPwdDialog.MODE_SURE = 1;
InputPwdDialog.MODE_AGREE = 2;
InputPwdDialog.MODE_OK = 3;

InputPwdDialog.ctor = function(self,x,y,w,h,room)
    super(self,custom_input_pwd_dialog_view)

	self.m_root_view = self.m_root;

	self.m_custom_input_pwd_dialog_view_bg= self.m_root_view:getChildByName("custom_input_pwd_dialog_view_bg");
	self.m_input_pwd_edit_text= self.m_custom_input_pwd_dialog_view_bg:getChildByName("input_pwd_edit_text");
	self.m_input_pwd_edit= self.m_input_pwd_edit_text:getChildByName("input_pwd_edit");
    self.m_input_pwd_edit:setHintText("请输入4到10位密码",165,145,120);
    self.m_input_pwd_edit:setOnTextChange(self,self.onEditPwdChange)
	self.m_intput_ok_btn= self.m_custom_input_pwd_dialog_view_bg:getChildByName("input_ok_btn");
    self.m_intput_ok_btn:setOnClick(self,self.sure);
	self.m_pwd_error_icon= self.m_custom_input_pwd_dialog_view_bg:getChildByName("pwd_error_icon");

	self.m_input_pwd_cancel_btn= self.m_custom_input_pwd_dialog_view_bg:getChildByName("input_pwd_cancel_btn");
    self.m_input_pwd_cancel_btn:setOnClick(self,self.cancel);
	self.m_pwd_error_icon:setVisible(false);

	self.m_room = room;
end

InputPwdDialog.checkPwdInputStr = function(self,inputStr)

	local len = string.len(inputStr);
	local lenutf8 = string.lenutf8(inputStr);
    
    if len>lenutf8 then
    	return false;
    end

	 if string.find(inputStr,"%W") then
	 	return false
	 end

	  if len>10 or len<4 then
	  	return false
	  end
	 return true;
end

InputPwdDialog.dtor = function(self)
	self.m_root_view = nil;
end

InputPwdDialog.isShowing = function(self)
	return self:getVisible();
end

InputPwdDialog.onTouch = function(self)
	print_string("InputPwdDialog.onTouch");
end

InputPwdDialog.onEditPwdChange = function(self)
	self.m_pwd_error_icon:setVisible(false);
end

InputPwdDialog.show = function(self,isAnother)
	print_string("InputPwdDialog.show ... ");
    local titleStr;
    if isAnother ==true then 
    	self.m_pwd_error_icon:setVisible(true);
		titleStr = "请输入正确的密码"
	else
		self.m_pwd_error_icon:setVisible(false);
		titleStr = "请输入4到10位密码"
    end
    
    self.m_input_pwd_edit:setHintText(titleStr,165,145,120);
	self:setVisible(true);
    self.super.show(self);
end

InputPwdDialog.setPositiveListener = function(self,obj,func)
	self.m_posObj = obj;
	self.m_posFunc = func;
end

InputPwdDialog.setNegativeListener = function(self,obj,func)
	self.m_negObj = obj;
	self.m_negFunc = func;
end



InputPwdDialog.cancel = function(self)
	print_string("sure.cancel ");
	self:dismiss();

	if self.m_negObj and self.m_negFunc then
		self.m_negFunc(self.m_negObj);
	end
end


InputPwdDialog.sure = function(self)
	local pwdStr = self.m_input_pwd_edit:getText();

	if self:checkPwdInputStr(pwdStr)==false then
		self.m_pwd_error_icon:setVisible(true);
		self.m_input_pwd_edit:setText("请输入4到10位密码");
        ChessToastManager.getInstance():showSingle("密码错误");
		return;
	end

	print_string("InputPwdDialog.sure");
	self:dismiss();

	if self.m_posObj and self.m_posFunc then
		self.m_posFunc(self.m_posObj,pwdStr);
	end
end

--InputPwdDialog.dismiss = function(self)
--	self:setVisible(false);
--end