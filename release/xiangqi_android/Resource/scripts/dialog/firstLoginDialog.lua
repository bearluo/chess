require("view/Android_800_480/first_login_dialog_view");
require(BASE_PATH.."chessDialogScene")
FirstLoginDialog = class(ChessDialogScene,false);

FirstLoginDialog.ctor = function(self)
    super(self,first_login_dialog_view);
	self.m_root_view = self.m_root;
    self.mBg = self.m_root_view:getChildByName("bg")
    -- phone view
    self.m_phone_num_edit = self.mBg:getChildByName("content_view"):getChildByName("edit_1_bg"):getChildByName("edit_1");
    self.m_phone_num_edit:setHintText("输入手机号码",165,145,120);
    self.m_phone_sms = self.mBg:getChildByName("content_view"):getChildByName("edit_2_bg"):getChildByName("edit_2");
    self.m_phone_sms:setHintText("输入验证码",165,145,120);
    self.m_get_sms_btn = self.mBg:getChildByName("content_view"):getChildByName("get_sms_btn");
    self.m_get_sms_btn_name = self.m_get_sms_btn:getChildByName("name");
    self.m_get_sms_btn_name:setVisible(true);
    self.m_get_sms_btn_time = self.m_get_sms_btn:getChildByName("time");
    self.m_get_sms_btn_time:setVisible(false);
    self.m_get_sms_btn:setOnClick(self,self.onGetSmsBtnClick);
    self.m_phone_confirm_btn = self.mBg:getChildByName("login_btn");
    self.m_phone_confirm_btn:setOnClick(self,self.onPhoneConfirmBtnClick);


    self:setNeedBackEvent(false)
    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)
    self:initScrollView()
end

FirstLoginDialog.getDefaultLoginType = function(self)
    local datas = {};
    local data = {};
    data = {};
    data.loginType = UserInfo.s_acountType.wechat;--微信
    table.insert(datas,data);
    data = {};
    data.loginType = UserInfo.s_acountType.weibo;--微博
    table.insert(datas,data);
    data = {};
    data.loginType = UserInfo.s_acountType.qq;--qq
    table.insert(datas,data);
    data = {};
    data.loginType = UserInfo.s_acountType.youke;--游客
    table.insert(datas,data);
    return datas;
end

FirstLoginDialog.initScrollView = function(self)
    self.mLoginTypeScrollView = self.mBg:getChildByName("other_login_view"):getChildByName("login_type_scroll_view")
    self.mLoginTypeScrollView:setDirection(kHorizontal)
    local datas = FirstLoginDialog.getDefaultLoginType(self);
    self.m_scroll_view_add_x = 0;
    self.m_scroll_view_add_y = 0;
    self.m_account_view = {};
    for i,v in ipairs(datas) do
        self.m_account_view[#self.m_account_view+1] = new(FirstLoginDialogAcountItem,v,self);
        self.m_account_view[#self.m_account_view]:setPos((i-1)*FirstLoginDialogAcountItem.s_item_w,0);
        self.mLoginTypeScrollView:addChild(self.m_account_view[#self.m_account_view]);
    end
end

FirstLoginDialog.onWeiBoLogin = function(self)
	print_string("FirstLoginDialog.onWeiBoLogin");
	dict_set_string(kLoginMode,kLoginMode..kparmPostfix,0);
	call_native(kLoginWithWeibo);
end

FirstLoginDialog.onYoukeLogin = function(self)
	print_string("FirstLoginDialog.onYoukeLogin");
    if "win32"==System.getPlatform() and type(self.mLoginFunc) == "function" then
        self.mLoginFunc(self.mLoginObj)
    end
	call_native(kGetOldUUID);
end

FirstLoginDialog.onWechatLogin = function(self)
	print_string("FirstLoginDialog.onWechatLogin");
	call_native(kLoginWeChat);
end

FirstLoginDialog.onQQLogin = function(self)
	print_string("FirstLoginDialog.onQQLogin");
	call_native(kQQConnectLogin);
end

FirstLoginDialog.onGetSmsBtnClick = function(self)
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

FirstLoginDialog.islegal = function(self,str)
	local date = "%D"
	if not string.find(str, date) then --非数字
		return true;
	else
		return false;
	end
end

FirstLoginDialog.onPhoneConfirmBtnClick = function(self)
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

FirstLoginDialog.onSendCodeResponse = function(self,isSuccess,message)
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

FirstLoginDialog.startDownSecond = function(self,time)
    self.m_get_sms_btn_time:setVisible(true);
    self.m_get_sms_btn_name:setVisible(false);
    self.m_get_sms_btn_time:setText(time..'s');
    self.m_get_sms_btn:setEnable(false);
    self.m_animTimer = AnimFactory.createAnimInt(kAnimLoop, 0, 1, 1000, -1)
    self.m_animTimer:setDebugName("LoginUnifiedDialog.startDownSecond");
    self.m_animTimer:setEvent(self,self.onTime);
end

FirstLoginDialog.onTime = function(self)
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

FirstLoginDialog.dtor = function(self)
	self.m_root_view = nil;
    self.mDialogAnim.stopAnim()
    delete(self.m_animTimer)
end

FirstLoginDialog.show = function(self)
    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
    EventDispatcher.getInstance():register(Event.Call,self,self.onEventResponse);
    self.super.show(self,self.mDialogAnim.showAnim);
end

FirstLoginDialog.onHttpRequestsCallBack = function(self,command,...)
	Log.i("FirstLoginDialog.onHttpRequestsCallBack");
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self,...);
	end 
end

FirstLoginDialog.dismiss = function(self)
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onEventResponse);
    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpRequestsCallBack);
    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
    delete(self.m_animTimer)
end

FirstLoginDialog.onLoginThirdLoginResponse = function(self,isSuccess,message)
    if not isSuccess then 
        return
    end

    -- 这里已经登录成功 实际上是存储下登录信息 方便下次自动登录
    self:login(message.data.aUser.new_uuid:get_value())
    self:dismiss()
end

FirstLoginDialog.login = function(self,new_uuid)
    if not new_uuid then return end;
    self.mLoginNewUUID = new_uuid
    if "win32"==System.getPlatform() then
        PhpConfig.setImei(new_uuid);
        self:onSaveNewUUIDCallBack()
    end
    dict_set_string(kSaveNewUUID,kSaveNewUUID..kparmPostfix,new_uuid);
	call_native(kSaveNewUUID);
end

function FirstLoginDialog:onSaveNewUUIDCallBack()
    if UserInfo.getInstance():getNewUUID() ~= self.mLoginNewUUID then
        if type(self.mLoginFunc) == "function" then
            self.mLoginFunc(self.mLoginObj)
        end
    end
    self:dismiss();
end

function FirstLoginDialog:setLoginFunction(obj,func)
    self.mLoginObj = obj;
    self.mLoginFunc = func;
end

FirstLoginDialog.onEventResponse = function(self,cmd,flag,json_data)
    if not flag or not json_data then return end;
    if cmd == kLoginWithWeibo then
        ThirdPartyLoginProxy.loginWeibo(json_data)
    elseif cmd == kSaveNewUUID then
        self:onSaveNewUUIDCallBack()
    elseif cmd == kGetOldUUID then
        Log.i("kGetOldUUID");
        local new_uuid = json_data.new_uuid:get_value();
        UserInfo.getInstance():setAcountLoginType(UserInfo.s_acountType.youke);
        self:login(new_uuid)
    elseif cmd == kLoginWeChat then
        ThirdPartyLoginProxy.loginWeixin(json_data)
    elseif cmd == kQQConnectLogin then
        ThirdPartyLoginProxy.loginQQ(json_data)
    end
end

FirstLoginDialog.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.loginThirdLogin] = FirstLoginDialog.onLoginThirdLoginResponse;
    [HttpModule.s_cmds.sendCode]        = FirstLoginDialog.onSendCodeResponse;
};

FirstLoginDialogAcountItem = class(Node)
FirstLoginDialogAcountItem.s_item_w = 150
FirstLoginDialogAcountItem.s_item_h = 175
FirstLoginDialogAcountItem.ctor = function(self,data,handler)
    self.m_data = data;
    self.m_handler = handler;
    
    self.m_root = new(Node);
    self.m_root:setFillParent(true,true);

    self:setSize(FirstLoginDialogAcountItem.s_item_w,FirstLoginDialogAcountItem.s_item_h);
    self:addChild(self.m_root)
    self.m_headIconBg = new(Button,"common/background/head_mask_bg_110.png");
    self.m_headIconBg:setSrollOnClick();
    self.m_headIconBg:setAlign(kAlignTop);
    self.m_headIconBg:setPos(nil,5);
    self.m_root:addChild(self.m_headIconBg);
    self.m_name = new(Text,"", nil, nil, kAlignCenter, nil, 24, 200, 165, 140);
    self.m_name:setAlign(kAlignTop);
    self.m_name:setPos(nil,130);
    self.m_root:addChild(self.m_name);

    if self.m_data then
        if self.m_data.loginType == UserInfo.s_acountType.youke then
            self.m_name:setText("游客");
            self.m_headIconBg:setOnClick(self.m_handler,FirstLoginDialog.onYoukeLogin);
            self.m_headIconBg:setFile("common/icon/youke_icon.png");
        elseif self.m_data.loginType == UserInfo.s_acountType.weibo then
            self.m_headIconBg:setOnClick(self.m_handler,FirstLoginDialog.onWeiBoLogin);
            self.m_name:setText("微博");
            self.m_headIconBg:setFile("common/icon/weibo_icon.png");
        elseif self.m_data.loginType == UserInfo.s_acountType.wechat then
            self.m_headIconBg:setOnClick(self.m_handler,FirstLoginDialog.onWechatLogin);
            self.m_name:setText("微信");
            self.m_headIconBg:setFile("common/icon/wechat_icon.png");
        elseif self.m_data.loginType == UserInfo.s_acountType.qq then
            self.m_headIconBg:setOnClick(self.m_handler,FirstLoginDialog.onQQLogin);
            self.m_name:setText("QQ");
            self.m_headIconBg:setFile("common/icon/qq_icon_1.png");
        end
    end
end

FirstLoginDialogAcountItem.getData = function(self)
    return self.m_data;
end

FirstLoginDialogAcountItem.dtor = function(self)
end  