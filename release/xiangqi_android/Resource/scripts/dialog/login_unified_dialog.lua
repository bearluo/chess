
--require("view/Android_800_480/chioce_dialog_view");
require(VIEW_PATH .. "login_phone_and_boyaa_dialog");
require(BASE_PATH.."chessDialogScene");

LoginUnifiedDialog = class(ChessDialogScene,false);

LoginUnifiedDialog.ctor = function(self,isPhone)
    super(self,login_phone_and_boyaa_dialog);
    self.m_bg = self.m_root:getChildByName("bg");
    self.m_phone_btn = self.m_bg:getChildByName("phone_btn");
    self.m_phone_btn:setOnClick(self,self.onPhoneBtnClick);
    local func = function(view,enable)
        local text = view:getChildByName("text");
        if text then
            local str = text:getText();
            if enable then
                text:setText(str,nil,nil,240,230,210);
            else
                text:setText(str,nil,nil,80,80,80);
            end
        end
    end
    self.m_phone_btn:setOnTuchProcess(self.m_phone_btn,func);
    self.m_title = self.m_bg:getChildByName("title");
    self.m_boyaa_btn = self.m_bg:getChildByName("boyaa_btn");
    self.m_boyaa_btn:setOnClick(self,self.onBoyaaBtnClick);
    self.m_boyaa_btn:setOnTuchProcess(self.m_boyaa_btn,func);


    self.m_phone_view = self.m_bg:getChildByName("phone_view");
    self.m_boyaa_view = self.m_bg:getChildByName("boyaa_view");

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
    self.m_phone_confirm_btn = self.m_phone_view:getChildByName("confirm_btn");
    self.m_phone_confirm_btn:setOnClick(self,self.onPhoneConfirmBtnClick);
    self.m_phone_cancel_btn = self.m_phone_view:getChildByName("cancel_btn");
    self.m_phone_cancel_btn:setOnClick(self,self.onPhoneCancelBtnClick);

    -- boyaa view
    self.m_boyaa_name_edit = self.m_boyaa_view:getChildByName("content_view"):getChildByName("edit_1_bg"):getChildByName("edit_1");
    self.m_boyaa_name_edit:setHintText("输入手机/邮箱/博雅号",165,145,120);
    self.m_boyaa_pwd = self.m_boyaa_view:getChildByName("content_view"):getChildByName("edit_2_bg"):getChildByName("edit_2");
    self.m_boyaa_pwd:setHintText("输入密码",165,145,120);
    self.m_forget_pwd_btn = self.m_boyaa_view:getChildByName("content_view"):getChildByName("forget_pwd_btn");
    self.m_forget_pwd_btn:setOnClick(self,self.onForgetPwdBtnClick);
    self.m_boyaa_confirm_btn = self.m_boyaa_view:getChildByName("confirm_btn");
    self.m_boyaa_confirm_btn:setOnClick(self,self.onBoyaaConfirmBtnClick);
    self.m_boyaa_cancel_btn = self.m_boyaa_view:getChildByName("cancel_btn");
    self.m_boyaa_cancel_btn:setOnClick(self,self.onBoyaaCancelBtnClick);

    if isPhone then
        self.m_title:setText("手机登录");
        self:onPhoneBtnClick();
    else
        self.m_title:setText("博雅通行证登录");
        self:onBoyaaBtnClick();
    end

    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)
end

LoginUnifiedDialog.dtor = function(self)
	self.m_root_view = nil;
    delete(self.m_animTimer);
    delete(self.m_forget_pwd_dialog);
    delete(self.m_chioce_dialog);
    self.mDialogAnim.stopAnim()
end

LoginUnifiedDialog.isShowing = function(self)
	return self:getVisible();
end

LoginUnifiedDialog.resetPhoneView = function(self)
    self.m_phone_num_edit:setText();
    self.m_phone_sms:setText();
    self.m_get_sms_btn:setEnable(true);
    self.m_get_sms_btn_time:setVisible(false);
    self.m_get_sms_btn_name:setVisible(true);
    delete(self.m_animTimer);
    self.m_animTimer = nil;
end

LoginUnifiedDialog.resetBoyaaView = function(self)
    self.m_boyaa_name_edit:setText();
    self.m_boyaa_pwd:setText();
end

require("dialog/boyaa_forget_pwd_dialog");
LoginUnifiedDialog.onForgetPwdBtnClick = function(self)
--    delete(self.m_forget_pwd_dialog);
--    self.m_forget_pwd_dialog = new(BoyaaForGetPwdDialog);
--    self.m_forget_pwd_dialog:setParentDialog(self);
--    self.m_forget_pwd_dialog:show();
--    self:dismiss();
	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog)
	end
	self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE,"立刻前往","取消")
	self.m_chioce_dialog:setPositiveListener(self,self.feedback)
	self.m_chioce_dialog:setNegativeListener(nil)
	self.m_chioce_dialog:setMessage("联系客服可帮您快速找回账号")
	self.m_chioce_dialog:show()
end

function LoginUnifiedDialog:feedback()
    if kPlatform == kPlatformIOS then
        StateMachine.getInstance():pushState(States.Feedback,StateMachine.STYPE_CUSTOM_WAIT);
    else
        if not kFeedbackGameid or not kFeedbackSiteid then
            HttpModule.getInstance():execute(HttpModule.s_cmds.getFeedbackInfo);
            ChessToastManager.getInstance():showSingle("反馈参数出错了:(");
            return;
        end;
        local postData = {};
        postData.game_id = kFeedbackGameid;
        postData.site_id = kFeedbackSiteid;
        postData.uid = UserInfo.getInstance():getUid();
        postData.user_name = UserInfo.getInstance():getName();
        postData.user_icon_url = UserInfo.getInstance():getIcon();
        postData.is_kefu_vip = (tonumber(kIsFeedbackVip) == 1 and "3") or "2"; 
        postData.kefu_vip_level = (tonumber(kIsFeedbackVip) == 1 and kFeedbackVipLevel) or "normal";
        postData.account_type = UserInfo.getInstance():getAccountTypeName();
        postData.client = kIsFeedbackClient;
        dict_set_string(kLoadFeedbackSdk, kLoadFeedbackSdk .. kparmPostfix,json.encode(postData));
        call_native(kLoadFeedbackSdk);
    end
end
LoginUnifiedDialog.onBoyaaConfirmBtnClick = function(self)
    local name = self.m_boyaa_name_edit:getText();
    local pwd = self.m_boyaa_pwd:getText();
   	if name and name ~= "" then
        if pwd and pwd ~= "" then
            UserInfo.getInstance():setAcountLoginType(UserInfo.s_acountType.boyaa);
            local post_data = {};
            post_data.bind_uuid = nil;
            post_data.boyaa_account = {};
            post_data.boyaa_account.username = name;
            post_data.boyaa_account.password = pwd;
            post_data.mid = mid;
            post_data.sid = ThirdPartyLoginProxy.s_sid.boyaa;
            post_data.uid = md5_string(PhpConfig.getImei());
            HttpModule.getInstance():execute(HttpModule.s_cmds.loginThirdLogin,post_data,"查询中...");
        else
		    local message = "密码输入有误！(检测是否存在空格)"
            ChessToastManager.getInstance():showSingle(message);
        end
	else
		local message = "帐号输入有误！(检测是否存在空格)"
        ChessToastManager.getInstance():showSingle(message);
	end
end

LoginUnifiedDialog.onBoyaaCancelBtnClick = function(self)
    self:dismiss();
end


LoginUnifiedDialog.onGetSmsBtnClick = function(self)
    local phoneNo = self.m_phone_num_edit:getText();
    if phoneNo and phoneNo ~= "" and  self:islegal(phoneNo) then
        local post_data = {};
        post_data.bind_uuid = phoneNo;
        post_data.method = "BindAccount.sendCode";
        HttpModule.getInstance():execute(HttpModule.s_cmds.sendCode,post_data,"发送请求中...");
    else
		local message = "电话号码输入有误！"
        ChessToastManager.getInstance():showSingle(message);
    end
end

LoginUnifiedDialog.onPhoneConfirmBtnClick = function(self)
    local phoneNo = self.m_phone_num_edit:getText();
    local sms = self.m_phone_sms:getText();
   	if phoneNo and phoneNo ~= "" and  self:islegal(phoneNo) then
        if sms and sms ~= "" then
            UserInfo.getInstance():setAcountLoginType(UserInfo.s_acountType.phone);
            local post_data = {};
            post_data.bind_uuid = phoneNo;
            post_data.code = sms;
            post_data.sid = ThirdPartyLoginProxy.s_sid.phone;
            post_data.uid = md5_string(PhpConfig.getImei());
            HttpModule.getInstance():execute(HttpModule.s_cmds.loginThirdLogin,post_data,"登录请求中...");
        else
		    local message = "验证码输入有误！"
            ChessToastManager.getInstance():showSingle(message);
        end
	else
		local message = "电话号码输入有误！"
        ChessToastManager.getInstance():showSingle(message);
	end
end

LoginUnifiedDialog.onPhoneCancelBtnClick = function(self)
    self:dismiss();
end

LoginUnifiedDialog.onPhoneBtnClick = function(self)
    self:resetPhoneView();
    self.m_phone_view:setVisible(true);
    self.m_boyaa_btn:setEnable(true);
    self.m_boyaa_view:setVisible(false);
    self.m_phone_btn:setEnable(false);
end

LoginUnifiedDialog.onBoyaaBtnClick = function(self)
    self:resetBoyaaView();
    self.m_phone_view:setVisible(false);
    self.m_boyaa_btn:setEnable(false);
    self.m_boyaa_view:setVisible(true);
    self.m_phone_btn:setEnable(true);
end

LoginUnifiedDialog.cancel = function(self)
	print_string("LoginUnifiedDialog.cancel ");
	self:dismiss();
end

LoginUnifiedDialog.show = function(self,showType)
	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
    if showType == 2 then 
        self:onBoyaaBtnClick();
    else
        self:onPhoneBtnClick();
    end
    self.super.show(self,self.mDialogAnim.showAnim);
end

LoginUnifiedDialog.dismiss = function(self)
    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpRequestsCallBack);
	self.super.dismiss(self,self.mDialogAnim.dismissAnim);
end

LoginUnifiedDialog.islegal = function(self,str)
	local date = "%D"
	if not string.find(str, date) then --非数字
		return true;
	else
		return false;
	end
end


LoginUnifiedDialog.onHttpRequestsCallBack = function(self,command,...)
	Log.i("LoginUnifiedDialog.onHttpRequestsCallBack");
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self,...);
	end 
end

LoginUnifiedDialog.onSendCodeResponse = function(self,isSuccess,message)
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

require("common/animFactory");
LoginUnifiedDialog.startDownSecond = function(self,time)
    self.m_get_sms_btn_time:setVisible(true);
    self.m_get_sms_btn_name:setVisible(false);
    self.m_get_sms_btn_time:setText(time..'s');
    self.m_get_sms_btn:setEnable(false);
    self.m_animTimer = AnimFactory.createAnimInt(kAnimLoop, 0, 1, 1000, -1)
    self.m_animTimer:setDebugName("LoginUnifiedDialog.startDownSecond");
    self.m_animTimer:setEvent(self,self.onTime);
end

LoginUnifiedDialog.onTime = function(self)
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

LoginUnifiedDialog.explainPHPFlag = function(flag)
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
        msg = "发送失败";
    elseif flag == 17 then
        msg = "缺少参数"
    end
    return msg;
end

LoginUnifiedDialog.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.sendCode] = LoginUnifiedDialog.onSendCodeResponse;
};