require("view/Android_800_480/by_phone_retrieve_dialog_view");
require(BASE_PATH.."chessDialogScene")
ByPhoneRetrieveDialog = class(ChessDialogScene,false);

ByPhoneRetrieveDialog.ctor = function(self)
    super(self,by_phone_retrieve_dialog_view);
	self.m_root_view = self.m_root;
    self.m_back_btn = self.m_root:getChildByName("bg"):getChildByName("back_btn");
    self.m_confirm_btn = self.m_root:getChildByName("bg"):getChildByName("confirm_btn");

    
    self.m_edit_phone_num = self.m_root:getChildByName("bg"):getChildByName("edit_1_bg"):getChildByName("phone_num");
    self.m_edit_phone_num:setHintText("输入手机号码",165,145,120);
    self.m_edit_code_num = self.m_root:getChildByName("bg"):getChildByName("edit_2_bg"):getChildByName("code_num");
    self.m_edit_code_num:setHintText("输入验证码",165,145,120);
    self.m_edit_new_pwd = self.m_root:getChildByName("bg"):getChildByName("edit_3_bg"):getChildByName("first_pwd");
    self.m_edit_new_pwd:setHintText("输入新的密码",165,145,120);
    self.m_edit_new_pwd_check = self.m_root:getChildByName("bg"):getChildByName("edit_4_bg"):getChildByName("second_pwd");
    self.m_edit_new_pwd_check:setHintText("再次输入密码",165,145,120);

    self.m_get_sms_btn = self.m_root:getChildByName("bg"):getChildByName("edit_2_bg"):getChildByName("get_code_btn");
    self.m_edit_code_time = self.m_root:getChildByName("bg"):getChildByName("edit_2_bg"):getChildByName("get_code_btn"):getChildByName("time");
    self.m_edit_code_name = self.m_root:getChildByName("bg"):getChildByName("edit_2_bg"):getChildByName("get_code_btn"):getChildByName("name");
    self.m_edit_code_time:setVisible(false);
    self.m_edit_code_name:setVisible(true);
    self.m_back_btn:setOnClick(self,self.onBackBtnClick);
    self.m_confirm_btn:setOnClick(self,self.onConfirmBtnClick);
    self.m_get_sms_btn:setOnClick(self,self.onGetSmsBtnClick);

end

ByPhoneRetrieveDialog.dtor = function(self)
	self.m_root_view = nil;
    delete(self.m_animTimer);
end

ByPhoneRetrieveDialog.reset = function(self)
    delete(self.m_animTimer);
    self.m_edit_code_time:setVisible(false);
    self.m_edit_code_name:setVisible(true);
end

ByPhoneRetrieveDialog.setParentDialog = function(self,dialog)
    self.m_parent_dialog = dialog;
end

ByPhoneRetrieveDialog.onCancelBtnClick = function(self)
    self:dismiss();
end

ByPhoneRetrieveDialog.onBackBtnClick = function(self)
    self:dismiss();
    if self.m_parent_dialog then
        self.m_parent_dialog:show();
    end
end

ByPhoneRetrieveDialog.onConfirmBtnClick = function(self)
    local name = self.m_edit_phone_num:getText();
    local code = self.m_edit_code_num:getText();
    local pwd = self.m_edit_new_pwd:getText();
    local pwd2 = self.m_edit_new_pwd_check:getText();

    if pwd ~= pwd2 then
		local message = "密码输入不一致！(检测是否存在空格)"
        ChessToastManager.getInstance():showSingle(message);
        return ;
    end

   	if name and name ~= " " then
        if code and code ~= " " then
            local post_data = {};
            post_data.phone = name;
            post_data.code = code;
            post_data.password = pwd;
            HttpModule.getInstance():execute(HttpModule.s_cmds.findPasswordByPhone,post_data,"查询中...");
        else
		    local message = "验证码输入有误！(检测是否存在空格)"
            ChessToastManager.getInstance():showSingle(message);
        end
	else
		local message = "手机号输入有误！(检测是否存在空格)"
        ChessToastManager.getInstance():showSingle(message);
	end
end


ByPhoneRetrieveDialog.onGetSmsBtnClick = function(self)
    local phoneNo = self.m_edit_phone_num:getText();
    if phoneNo and phoneNo ~= " " and  self:islegal(phoneNo) then
        local post_data = {};
        post_data.phone = phoneNo;
        HttpModule.getInstance():execute(HttpModule.s_cmds.boyaaSendCode,post_data,"发送请求中...");
    else
		local message = "电话号码输入有误！"
        ChessToastManager.getInstance():showSingle(message);
    end
end
ByPhoneRetrieveDialog.onFindPasswordByPhoneResponse = function(self,isSuccess,message)
    self.m_get_sms_btn:setEnable(true);
    self.m_edit_code_time:setVisible(false);
    self.m_edit_code_name:setVisible(true);
    delete(self.m_animTimer);
    self.m_animTimer = nil;
    if not isSuccess then
        ChessToastManager.getInstance():show(message.data.errmsg:get_value() or "请求失败!");
        return ;
    end
    ChessToastManager.getInstance():show("修改成功!");
    self:dismiss();
end

ByPhoneRetrieveDialog.onSendCodeResponse = function(self,isSuccess,message)
    if not isSuccess then
        if type(message) == "number" then
            return; 
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
            return;
        end; 
    end
    
    local time = message.data.wait_time:get_value();
    if not time then
        ChessToastManager.getInstance():show("请求失败!");
        return ;
    end
    self:startDownSecond(time);
end

ByPhoneRetrieveDialog.startDownSecond = function(self,time)
    self.m_edit_code_time:setVisible(true);
    self.m_edit_code_name:setVisible(false);
    self.m_edit_code_time:setText(time.."s");
    self.m_get_sms_btn:setEnable(false);
    require("common/animFactory");
    self.m_animTimer = AnimFactory.createAnimInt(kAnimLoop, 0, 1, 1000, -1)
    self.m_animTimer:setDebugName("ByPhoneRetrieveDialog.startDownSecond");
    self.m_animTimer:setEvent(self,self.onTime);
end

ByPhoneRetrieveDialog.onTime = function(self)
    local time = tonumber(string.sub(self.m_edit_code_time:getText(),1,-2));
    time = time - 1;
    if time <= 0 then 
        self.m_get_sms_btn:setEnable(true);
        self.m_edit_code_time:setVisible(false);
        self.m_edit_code_name:setVisible(true);
        delete(self.m_animTimer);
        self.m_animTimer = nil;
        return ;
    end
    self.m_edit_code_time:setText(time.."s");
end


ByPhoneRetrieveDialog.isShowing = function(self)
	return self:getVisible();
end

ByPhoneRetrieveDialog.show = function(self)
	print_string("ByPhoneRetrieveDialog.show ... ");
	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
--    EventDispatcher.getInstance():register(Event.Call,self,self.onEventResponse);
    self:reset();
	self:setVisible(true);
    self.super.show(self);
end


ByPhoneRetrieveDialog.onHttpRequestsCallBack = function(self,command,...)
	Log.i("ByPhoneRetrieveDialog.onHttpRequestsCallBack");
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self,...);
	end 
end

ByPhoneRetrieveDialog.dismiss = function(self)
--    EventDispatcher.getInstance():unregister(Event.Call,self,self.onEventResponse);
    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpRequestsCallBack);

    self.super.dismiss(self);
--	self:setVisible(false);
end

ByPhoneRetrieveDialog.dissmissDialogs = function(self)
	return true;
end


ByPhoneRetrieveDialog.onEventResponse = function(self,cmd,flag,json_data)
    if not json_data then return end;
    
end



ByPhoneRetrieveDialog.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.boyaaSendCode] = ByPhoneRetrieveDialog.onSendCodeResponse;
    [HttpModule.s_cmds.findPasswordByPhone] = ByPhoneRetrieveDialog.onFindPasswordByPhoneResponse;
};

ByPhoneRetrieveDialog.islegal = function(self,str)
	local date = "%D"
	if not string.find(str, date) then --非数字
		return true;
	else
		return false;
	end
end

ByPhoneRetrieveDialog.explainPHPFlag = function(flag)
    local msg;
    if flag == 11 then
        msg = "手机号或邮箱格式不正确";
    elseif flag == 12 then
        msg = "账号已经绑定";
    elseif flag == 13 then
        msg = "验证码错误";
    elseif flag == 14 then
        msg = "用户不存在";
    elseif flag == 15 then
        msg = "绑定失败";
    elseif flag == 16 then
        msg = "验证码发送失败";
    elseif flag == 17 then
        msg = "缺少参数"
    end
    return msg;
end