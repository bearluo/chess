require(BASE_PATH.."chessDialogScene");
require(VIEW_PATH.."bangdin_dialog_view");

BangDinDialog = class(ChessDialogScene,false)


BangDinDialog.ctor = function(self)
    super(self,bangdin_dialog_view);
    self.m_ctrls = BangDinDialog.s_controls;
    self:create();
end

BangDinDialog.dtor = function(self)
    delete(self.m_animTimer);
    self.m_animTimer = nil;
end

BangDinDialog.isShowing = function(self)
	return self:getVisible();
end

BangDinDialog.onHttpRequestsCallBack = function(self,command,...)
	Log.i("BangDinDialog.onHttpRequestsCallBack");
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self,...);
	end 
end

BangDinDialog.setHandler = function(self,handler)
    self.m_handler = handler;
end


BangDinDialog.show = function(self)
	print_string("BangDinDialog.show ... ");
	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
	self:setVisible(true);
    self.super.show(self);
end


BangDinDialog.dismiss = function(self)
    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpRequestsCallBack);
--	self:setVisible(false);
    self.super.dismiss(self);
end

BangDinDialog.create = function(self)
    self.m_bg_view = self.m_root:getChildByName("bg");
    self.m_phone_view = self.m_bg_view:getChildByName("phone_view");
    -- phone view
    self.m_phone_num_edit = self.m_phone_view:getChildByName("content_view"):getChildByName("edit_1_bg"):getChildByName("edit_1");
    self.m_phone_num_edit:setHintText("输入手机号码",165,145,120);
    self.m_phone_sms = self.m_phone_view:getChildByName("content_view"):getChildByName("edit_2_bg"):getChildByName("edit_2");
    self.m_phone_sms:setHintText("输入验证码",165,145,120);
    self.m_get_sms_btn = self.m_phone_view:getChildByName("content_view"):getChildByName("get_sms_btn");
    self.m_get_sms_btn_name = self.m_get_sms_btn:getChildByName("name");
    self.m_get_sms_btn_name:setVisible(true);
    self.m_get_sms_btn_time = self.m_get_sms_btn:getChildByName("time");
    self.m_get_sms_btn_time:setVisible(false);
    self.m_get_sms_btn:setOnClick(self,self.onGetSmsBtnClick);
    self.m_phone_confirm_btn = self.m_bg_view:getChildByName("confirm_btn");
    self.m_phone_confirm_btn:setOnClick(self,self.onPhoneConfirmBtnClick);
    self.m_phone_cancel_btn = self.m_bg_view:getChildByName("cancel_btn");
    self.m_phone_cancel_btn:setOnClick(self,self.onPhoneCancelBtnClick);
end

BangDinDialog.onPhoneCancelBtnClick = function(self)
    self:dismiss();
end

BangDinDialog.resetPhoneView = function(self)
    self.m_phone_num_edit:setText();
    self.m_phone_sms:setText();
    self.m_get_sms_btn:setEnable(true);
    self.m_get_sms_btn_time:setVisible(false);
    self.m_get_sms_btn_name:setVisible(true);
    delete(self.m_animTimer);
    self.m_animTimer = nil;
end

BangDinDialog.onGetSmsBtnClick = function(self)
    local phoneNo = self.m_phone_num_edit:getText();
    if phoneNo and phoneNo ~= " " and  self:islegal(phoneNo) then
        local post_data = {};
        post_data.bind_uuid = phoneNo;
        post_data.method = "BindAccount.sendCode";
        post_data.is_register = 1;
        HttpModule.getInstance():execute(HttpModule.s_cmds.sendCode,post_data,"发送请求中...");
    else
		local message = "电话号码输入有误！"
        ChessToastManager.getInstance():showSingle(message);
    end
end

BangDinDialog.onPhoneConfirmBtnClick = function(self)
    local phoneNo = self.m_phone_num_edit:getText();
    local sms = self.m_phone_sms:getText();
   	if phoneNo and phoneNo ~= " " and  self:islegal(phoneNo) then
        if sms and sms ~= " " then
            local post_data = {};
            post_data.bind_uuid = phoneNo;
            post_data.method = "BindAccount.bind";
            post_data.code = sms;
            post_data.sid = BangDinDialog.s_sid.phone;
            HttpModule.getInstance():execute(HttpModule.s_cmds.bindUid,post_data,"绑定请求中...");
        else
		    local message = "验证码输入有误！"
            ChessToastManager.getInstance():showSingle(message);
        end
	else
		local message = "电话号码输入有误！"
        ChessToastManager.getInstance():showSingle(message);
	end
end

BangDinDialog.islegal = function(self,str)
	local date = "%D"
	if not string.find(str, date) then --非数字
		return true;
	else
		return false;
	end
end

BangDinDialog.explainPHPFlag = function(flag)
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

BangDinDialog.onSendCodeResponse = function(self,isSuccess,message)
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

BangDinDialog.onBindUidResponse = function(self,isSuccess,message)
    if not isSuccess then
        if type(message) == "number" then
            return; 
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
            return;
        end;   
    end
    ChessToastManager.getInstance():showSingle("绑定成功!");
    local bind_uuid = message.data.bind_uuid:get_value();
    local sid = message.data.sid:get_value();
    if bind_uuid and sid then
        UserInfo.getInstance():updateBindAccountBySid(sid,bind_uuid);
    end
    if self.m_handler and self.m_handler.updateUserInfoView then 
        self.m_handler:updateUserInfoView();
    end
    self:dismiss();
end

BangDinDialog.startDownSecond = function(self,time)
    self.m_get_sms_btn_time:setVisible(true);
    self.m_get_sms_btn_name:setVisible(false);
    self.m_get_sms_btn_time:setText(time..'s');
    self.m_get_sms_btn:setEnable(false);
    require("common/animFactory");
    self.m_animTimer = AnimFactory.createAnimInt(kAnimLoop, 0, 1, 1000, -1)
    self.m_animTimer:setDebugName("BangDinDialog.startDownSecond");
    self.m_animTimer:setEvent(self,self.onTime);
end

BangDinDialog.onTime = function(self)
    local time = tonumber(string.sub(self.m_get_sms_btn_time:getText(),1,-2));
    time = time - 1;
    if time <= 0 then 
        self.m_get_sms_btn:setEnable(true);
        self.m_get_sms_btn_time:setVisible(false);
        self.m_get_sms_btn_name:setVisible(true);
        delete(self.m_animTimer);
        self.m_animTimer = nil;
        return ;
    end
    self.m_get_sms_btn_time:setText(time..'s');
end


BangDinDialog.s_controls = 
{
};

BangDinDialog.s_controlConfig = 
{
};

BangDinDialog.s_controlFuncMap = 
{
};

BangDinDialog.s_cmds = 
{

};

BangDinDialog.s_cmdConfig = 
{
};

BangDinDialog.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.sendCode] = BangDinDialog.onSendCodeResponse;
    [HttpModule.s_cmds.bindUid]  = BangDinDialog.onBindUidResponse;
};



BangDinDialog.s_sid = {
    phone = 1;
    email = 2;
    weichat = 3;
    xinlang = 10;
    boyaa = 40;
}
