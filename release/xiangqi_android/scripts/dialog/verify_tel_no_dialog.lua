require("view/Android_800_480/verify_dialog");

VerifyTelNoDialog = class();
VerifyTelNoDialog.ctor = function(self)

	self.m_scene = new(Scene,verify_dialog);
	self.m_root_view = self.m_scene:getRoot();
	
	self.m_verify_dialog_bg = self.m_root_view:getChildByName("verify_dialog_bg");
	self.m_verify_dialog_bg:setEventTouch(self,self.onTouch);

	self.m_dialog_view = self.m_root_view:getChildByName("dialog_view");
	self.m_verify_dialog_view_bg = self.m_dialog_view:getChildByName("verify_dialog_view_bg");
	self.m_num_input_edittext = self.m_verify_dialog_view_bg:getChildByName("num_input_edittext");
	self.m_cancel_btn = self.m_verify_dialog_view_bg:getChildByName("cancel_btn");
	self.m_cancel_btn:setOnClick(self,self.cancel);

	self.m_verfy_lable1_image = self.m_verify_dialog_view_bg:getChildByName("verfy_lable1_image");
	self.m_verify_label1_text = self.m_verfy_lable1_image:getChildByName("verify_label1_text");
	self.m_verify_label1_text:setText("验证手机号",120,54,254,223,158);
	self.m_verify_label1_text:setPos(0,0);

	self.m_verfy_lable2_image = self.m_verify_dialog_view_bg:getChildByName("verfy_lable2_image");
	self.m_verify_label2_text = self.m_verfy_lable2_image:getChildByName("verify_label2_text");
	self.m_verify_label2_text:setText("输入验证码",120,54,161,117,54);
	self.m_verify_label2_text:setPos(0,0);

	self.m_num_input_text_lable_bg = self.m_verify_dialog_view_bg:getChildByName("num_input_text_lable_bg");
	self.m_num_label_text = self.m_num_input_text_lable_bg:getChildByName("num_label_text");

	self.m_num_input_text_bg = self.m_verify_dialog_view_bg:getChildByName("num_input_text_bg");
	self.m_num_input_edittext = self.m_num_input_text_bg:getChildByName("num_input_edittext");

	self.m_verify_code_label = self.m_verify_dialog_view_bg:getChildByName("verify_code_label");
	self.m_next_btn = self.m_verify_dialog_view_bg:getChildByName("next_btn");
	self.m_next_btn:setOnClick(self,self.verify_action);
	self.m_next_btn_label = self.m_next_btn:getChildByName("next_btn_label");


	self.isVerifyCode = 0;

end

VerifyTelNoDialog.dtor = function(self)
	self.m_root_view = nil;
end

VerifyTelNoDialog.onTouch = function(self)
end

VerifyTelNoDialog.showInputTelNoView = function(self)
	self.isVerifyCode = 0;
	self.m_verify_label2_text:setText("输入验证码",120,54,161,117,54);
	self.m_verify_label2_text:setPos(0,0);

	self.m_num_label_text:setText("手机号码")
	local verifyCode = "您的资料将会被加密，保证您的帐号安全。验证通过后，会自动领取奖励。"
	self.m_verify_code_label:setText(verifyCode)
	self.m_num_input_edittext:setText("");
end

VerifyTelNoDialog.showReceiveAwardsView = function(self,obj,func)

	self.isVerifyCode = 1;
	self.m_verify_label2_text:setText("输入验证码",120,54,254,223,158);
	self.m_verify_label2_text:setPos(0,0);
	self.m_num_label_text:setText("验证码")
	self.receiveAwardsCallBack = func;
	self.m_obj = obj;
	local verifyCode = "我们向您发送了一条信息，请收到后输入短信中的验证码。验证通过后，会自动领取奖励。";
	self.m_verify_code_label:setText(verifyCode)
	self.m_num_input_edittext:setText("");
	self.m_next_btn_label:setText("马上领取");
end

VerifyTelNoDialog.receiveAwardsView = function(self)
	local tipsNum = UserInfo.getInstance():getTipsNum();
	local promptNum = UserInfo.getInstance():getPromptNum();

	tipsNum = tipsNum + promptNum; 
	UserInfo:getInstance():setTipsNum(tipsNum);

	self:cancel();

	if self.receiveAwardsCallBack and self.m_obj then
		self.receiveAwardsCallBack(self.m_obj,promptNum);
	end
end

VerifyTelNoDialog.verify_action = function(self)
	if 	self.isVerifyCode == 1 then
		local code = self.m_num_input_edittext:getText();
		if code and code ~= "" then
			PHPInterface.checkVerifyCode(code);
		else
			local message = "请输入验证码！"
            ChessToastManager.getInstance():showSingle(message);
		end
	elseif self.isVerifyCode == 0 then
   		local phoneNo = self.m_num_input_edittext:getText();
   		if phoneNo and phoneNo ~= "" then
   			if  self:islegal(phoneNo) then
   				PHPInterface.verifyTelNo(phoneNo);
   			else
   				self.isVerifyCode = 0;
				local message = "请输入纯数字的电话号码！"
                ChessToastManager.getInstance():showSingle(message);
   			end
   		else
   			self.isVerifyCode = 0;
   			local message = "请输入纯数字的电话号码！"
            ChessToastManager.getInstance():showSingle(message);
   		end
	end
end

VerifyTelNoDialog.islegal = function(self,str)
	local date = "%D"
	if not string.find(str, date) then --非数字
		return true;
	else
		return false;
	end
end


VerifyTelNoDialog.isShowing = function(self)
	if not self.m_root_view:getVisible() then
		if self.m_pay_dialog then
			return self.m_pay_dialog:isShowing();
		end
	end

	return self.m_root_view:getVisible();
end

VerifyTelNoDialog.show = function(self,parent_view)
	print_string("VerifyTelNoDialog.show ... ");
	self.m_parent_view  = parent_view;
    if self.m_parent_view then
    	self.m_parent_view:setPickable(false);
    end

	SoundManager.getInstance():play_effect(SoundManager.AUDIO_DIALOG_SHOW);
	self.m_root_view:setVisible(true);
end

VerifyTelNoDialog.cancel = function(self)
	print_string("VerifyTelNoDialog.cancel ");
	ShowMessageAnim.deleteAll();
	self:showInputTelNoView();
	if self.m_pay_dialog and self.m_pay_dialog:isShowing() then
		self.m_pay_dialog:cancel();
		return;
	end

	self:dismiss();
	if self.m_negObj and self.m_negFunc then
		self.m_negFunc(self.m_negObj);
	end
end

VerifyTelNoDialog.sure = function(self)
	print_string("VerifyTelNoDialog.sure ");

	self:dismiss();
	if self.m_posObj and self.m_posFunc then
		self.m_posFunc(self.m_posObj);
	end
end

VerifyTelNoDialog.setPositiveListener = function(self,obj,func)
	self.m_posObj = obj;
	self.m_posFunc = func;
end

VerifyTelNoDialog.setNegativeListener = function(self,obj,func)
	self.m_negObj = obj;
	self.m_negFunc = func;
end

VerifyTelNoDialog.dismiss = function(self)
    if self.m_parent_view then
    	self.m_parent_view:setPickable(true);
    	self.m_parent_view = nil;
    end
	self.m_root_view:setVisible(false);
end

VerifyTelNoDialog.getDialogView = function(self)
	return self.m_root_view;
end

VerifyTelNoDialog.GetPhoneContacts = function(self)
    local post_data = {};
	local dataStr = json.encode(post_data);
	dict_set_string(kGetPhoneContacts,kGetPhoneContacts..kparmPostfix,dataStr);
	call_native(kGetPhoneContacts);
end

VerifyTelNoDialog.getAddressBook = function(self)
	local phoneContacts = dict_get_string(kGetPhoneContacts, kGetPhoneContacts .. kResultPostfix);

    if phoneContacts then
        self.m_resultTb = ToolKit.split(phoneContacts,",");

		if self.m_resultTb then
			local len = #self.m_resultTb;
			local post_data = {};
			for i=1,len do
				local result = self.m_resultTb[i];
				local resultdata = ToolKit.split(result,"="); 
				local data = {};
				data.phoneNo  = resultdata[1];
				data.name  = resultdata[2];

				table.insert(post_data,data);
			end

			print("=========AddressBook=post_data=="..json.encode(post_data).."\n");
			return json.encode(post_data);
		end   
    end
end

VerifyTelNoDialog.uploadAddressBook = function(self)
	local addrBook = self:getAddressBook();

	if addrBook then
		PHPInterface.uploadAddressBook(addrBook);
	end
end