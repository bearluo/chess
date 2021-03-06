require("view/Android_800_480/toggle_account_dialog");
require(BASE_PATH.."chessDialogScene")
ToggleAccountDialog = class(ChessDialogScene,false);

ToggleAccountDialog.ctor = function(self)
    super(self,toggle_account_dialog);
	self.m_root_view = self.m_root;

	self.m_content_view = self.m_root_view:getChildByName("content_view");
	
	self.m_close_btn = self.m_content_view:getChildByName("close_btn");
	self.m_close_btn:setOnClick(self,self.dismiss);
    self.m_confirm_btn = self.m_content_view:getChildByName("confirm");
    self.m_confirm_btn:setVisible(false);
    self.m_confirm_btn:setOnClick(self,self.onConfirmClick);
    self.m_del_btn = self.m_content_view:getChildByName("del_btn");
    self.m_del_btn:setOnClick(self,self.onDelBtnClick);


    self.m_title = self.m_content_view:getChildByName("title");

	self.m_scroll_view_holder = self.m_content_view:getChildByName("scroll_view_holder");
    local w,h = self.m_scroll_view_holder:getSize();
    self.m_scroll_view = new(ScrollView,0,0,w,h,false);
    self.m_scroll_view_holder:addChild(self.m_scroll_view);
    self:initScrollView();
end

ToggleAccountDialog.onConfirmClick = function(self)
    self.m_confirm_btn:setVisible(false);
    self.m_del_btn:setVisible(true);
    self.m_title:setText("账号切换");
    for i,v in ipairs(self.m_account_view) do
        v:changeDelState(false);
    end
end

ToggleAccountDialog.onDelBtnClick = function(self)
    self.m_confirm_btn:setVisible(true);
    self.m_del_btn:setVisible(false);
    self.m_title:setText("账号删除");
    for i,v in ipairs(self.m_account_view) do
        v:changeDelState(true);
    end
end

ToggleAccountDialog.resetScrollView = function(self)
    if self.m_scroll_view then
        self.m_scroll_view:updateScrollView();
    end
end

ToggleAccountDialog.s_item_w = 201;
ToggleAccountDialog.s_item_h = 250;

ToggleAccountDialog.initScrollView = function(self)
    local datas = UserInfo.getInstance():getAcountList();
    if not datas or #datas == 0 then
        datas = ToggleAccountDialog.getDefaultLoginType(self);
        UserInfo.getInstance():saveAcountList(datas);
    end
    self.m_scroll_view_add_x = 0;
    self.m_scroll_view_add_y = 0;
    self.m_account_view = {};
    for i,v in ipairs(datas) do
        self.m_account_view[#self.m_account_view+1] = new(ToggleAccountDialogAcountItem,v,self);
        self.m_account_view[#self.m_account_view]:setPos((i-1)%3*ToggleAccountDialog.s_item_w,math.floor((i-1)/3)*ToggleAccountDialog.s_item_h);
        self:addDeleteFunc(self.m_account_view[#self.m_account_view],i);
        self.m_scroll_view:addChild(self.m_account_view[#self.m_account_view]);
    end
end

ToggleAccountDialog.addDeleteFunc = function(self,obj,index)
    local func = function()
        self.m_scroll_view:removeChild(obj,true);
        local x,y = self.m_account_view[index]:getPos();
        table.remove(self.m_account_view,index);
        self:updateAcountList(index,x,y);
    end
    obj:setDeletefunc(func);
end

ToggleAccountDialog.updateAcountList = function(self,index,x,y)
    local ret = {};
    for i,v in ipairs(self.m_account_view) do
        if i>=index then
            local fromx,fromy = v:getPos();
            v.moveTo(v,x,y);
            x = fromx;
            y = fromy;
        end
        self:addDeleteFunc(v,i);
        table.insert(ret,v:getData());
    end
    UserInfo.getInstance():saveAcountList(ret);
    self:resetScrollView();
end

ToggleAccountDialog.getDefaultLoginType = function(self)
    local datas = {};
    local data = {};
--    data = {};
--    data.new_uuid = 1
--    data.loginType = UserInfo.s_acountType.wechat;--微信
--    data.name = "11";
--    data.iconType = 1;
--    data.icon = "1";
--    table.insert(datas,data);

--    data = {};
--    data.new_uuid = 2
--    data.loginType = UserInfo.s_acountType.wechat;--微信
--    data.name = "11";
--    data.iconType = 1;
--    data.icon = "1";
--    table.insert(datas,data);

--    data = {};
--    data.new_uuid = 4
--    data.loginType = UserInfo.s_acountType.wechat;--微信
--    data.name = "11";
--    data.iconType = 1;
--    data.icon = "1";
--    table.insert(datas,data);

--    data = {};
--    data.new_uuid = 5
--    data.loginType = UserInfo.s_acountType.wechat;--微信
--    data.name = "11";
--    data.iconType = 1;
--    data.icon = "1";
--    table.insert(datas,data);

    data = {};
    data.loginType = UserInfo.s_acountType.youke;--游客
    table.insert(datas,data);
    data = {};
    data.loginType = UserInfo.s_acountType.phone;--手机
    table.insert(datas,data);
    data = {};
    data.loginType = UserInfo.s_acountType.weibo;--微博
    table.insert(datas,data);
    data = {};
    data.loginType = UserInfo.s_acountType.wechat;--微信
    table.insert(datas,data);
    data = {};
    data.loginType = UserInfo.s_acountType.boyaa;--博雅
    table.insert(datas,data);
    return datas;
end

ToggleAccountDialog.onWeiBoLogin = function(self)
	print_string("ToggleAccountDialog.onWeiBoLogin");
	dict_set_string(kLoginMode,kLoginMode..kparmPostfix,0);
	call_native(kLoginWithWeibo);
--	self:dismiss();
end

ToggleAccountDialog.onPhoneLogin = function(self)
    if not self.m_phoneLoginDialog then
        require("dialog/login_unified_dialog");
        self.m_phoneLoginDialog = new(LoginUnifiedDialog,true);
    end
    self.m_phoneLoginDialog:show(1);
end

ToggleAccountDialog.onBoyaaLogin = function(self)
    if not self.m_boyaaLoginDialog then
        require("dialog/login_unified_dialog");
        self.m_boyaaLoginDialog = new(LoginUnifiedDialog,false);
    end
    self.m_boyaaLoginDialog:show(2);
end

ToggleAccountDialog.onYoukeLogin = function(self)
	print_string("ToggleAccountDialog.onYoukeLogin");
	call_native(kGetOldUUID);
end

ToggleAccountDialog.onWechatLogin = function(self)
	print_string("ToggleAccountDialog.onWechatLogin");
	call_native(kLoginWeChat);
end



ToggleAccountDialog.dtor = function(self)
	self.m_root_view = nil;
end

ToggleAccountDialog.onTouch = function(self)
end

ToggleAccountDialog.isShowing = function(self)
	return self:getVisible();
end

ToggleAccountDialog.show = function(self)
	print_string("ToggleAccountDialog.show ... ");

	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
    EventDispatcher.getInstance():register(Event.Call,self,self.onEventResponse);
	self:setVisible(true);
    self.super.show(self);
end

ToggleAccountDialog.setCloseListener = function(self,obj,func)
	self.m_closeObj = obj;
	self.m_closeFunc = func;
end

ToggleAccountDialog.setCtrl = function(self,ctrl)
    self.m_ctrl = ctrl;
end

ToggleAccountDialog.onHttpRequestsCallBack = function(self,command,...)
	Log.i("ToggleAccountDialog.onHttpRequestsCallBack");
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self,...);
	end 
end

ToggleAccountDialog.dismiss = function(self)
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onEventResponse);
    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpRequestsCallBack);
    if self.m_closeObj and self.m_closeFunc then
		self.m_closeFunc(self.m_closeObj);
	end

    if not UserInfo.getInstance():isLogin() and self.m_ctrl then
        self.m_ctrl.m_hallSocket:closeSocketSync();
        self.m_ctrl:login();
    end

    self.super.dismiss(self);
--	self:setVisible(false);
end

ToggleAccountDialog.dissmissDialogs = function(self)
	return true;
end

ToggleAccountDialog.onLoginBindUidResponse = function(self,isSuccess,message)
    if HttpModule.explainPHPMessage(isSuccess,message,"查询失败!") then 
        return;
    end
    if not message.data then
        ChessToastManager.getInstance():show("查询失败!");
        return ;
    end
    UserInfo.getInstance():insertCacheAcountList(message.data.new_uuid:get_value(),tonumber(message.data.mid:get_value()));
    self:login(message.data.new_uuid:get_value(),message.data.mid:get_value());
end

ToggleAccountDialog.login = function(self,new_uuid)
    if not new_uuid then return end;
    if "win32"==System.getPlatform() then
        UserInfo.getInstance():setLogin(false);
        HttpModule.m_switchFlag = true;
        OnlineSocketManager.getHallInstance():closeSocketSync();
        PhpConfig.setImei(new_uuid);
        self:dismiss();
        if self.m_phoneLoginDialog then
            self.m_phoneLoginDialog:dismiss();
        end
        
        if self.m_boyaaLoginDialog then
            self.m_boyaaLoginDialog:dismiss();
        end
        return ;
    end
    dict_set_string(kSaveNewUUID,kSaveNewUUID..kparmPostfix,new_uuid);
	call_native(kSaveNewUUID);
end

ToggleAccountDialog.s_sid = {
    phone = 1;
    email = 2;
    weichat = 3;
    xinlang = 10;
    boyaa = 40;
}

ToggleAccountDialog.onEventResponse = function(self,cmd,flag,json_data)
    if not json_data then return end;
    if cmd == kLoginBoyaa then
        local bind_uuid = json_data.bid:get_value();
        local mid = UserInfo.getInstance():getUid();
        UserInfo.getInstance():setAcountLoginType(UserInfo.s_acountType.phone);
        local post_data = {};
        post_data.bind_uuid = bind_uuid;
        post_data.mid = mid;
        post_data.sid = ToggleAccountDialog.s_sid.boyaa;
            post_data.uid = md5_string(PhpConfig.getImei());
        HttpModule.getInstance():execute(HttpModule.s_cmds.loginBindUid,post_data,"查询中...");
    elseif cmd == kLoginWithWeibo then
        local bind_uuid = json_data.sitemid:get_value();
        local mid = UserInfo.getInstance():getUid();
        UserInfo.getInstance():setAcountLoginType(UserInfo.s_acountType.weibo);
        Log.i("kLoginWithWeibo sitemid:"..bind_uuid);
        local post_data = {};
        post_data.bind_uuid = bind_uuid;
        post_data.mid = mid;
        post_data.sid = ToggleAccountDialog.s_sid.xinlang;
        post_data.uid = md5_string(PhpConfig.getImei());
        HttpModule.getInstance():execute(HttpModule.s_cmds.loginBindUid,post_data,"查询中...");
    elseif cmd == kSaveNewUUID then
        UserInfo.getInstance():setLogin(false);
        HttpModule.m_switchFlag = true;
        OnlineSocketManager.getHallInstance():closeSocketSync();
        self:dismiss();
        if self.m_phoneLoginDialog then
            self.m_phoneLoginDialog:dismiss();
        end
        if self.m_boyaaLoginDialog then
            self.m_boyaaLoginDialog:dismiss();
        end
    elseif cmd == kGetOldUUID then
        Log.i("kGetOldUUID");
        local new_uuid = json_data.new_uuid:get_value();
        UserInfo.getInstance():setAcountLoginType(UserInfo.s_acountType.youke);
        if new_uuid then
            Log.i("kGetOldUUID :"..new_uuid);
            UserInfo.getInstance():insertCacheAcountList(new_uuid,0);
            dict_set_string(kSaveNewUUID,kSaveNewUUID..kparmPostfix,new_uuid);
	        call_native(kSaveNewUUID);
        end
    elseif cmd == kLoginWeChat then
        if not flag then
            Toast.getInstance():show("登录失败");
            return;
        end
        local bind_uuid = json_data.openid:get_value();
        local mid = UserInfo.getInstance():getUid();
        UserInfo.getInstance():setAcountLoginType(UserInfo.s_acountType.wechat);
        Log.i("kLoginWeChat openid:"..bind_uuid);
        local post_data = {};
        post_data.bind_uuid = bind_uuid;
        post_data.mid = mid;
        post_data.sid = ToggleAccountDialog.s_sid.weichat;
        post_data.uid = md5_string(PhpConfig.getImei());
        HttpModule.getInstance():execute(HttpModule.s_cmds.loginBindUid,post_data,"查询中...");
    elseif cmd == kCacheImageManager then
        if not flag then 
        --下载失败
        end
        local info = json.analyzeJsonNode(json_data);
--        if self.m_account_view then
--            for i,v in ipairs(self.m_account_view) do
--                v:updateHeadIcon(info);
--            end
--        end
    end
end

ToggleAccountDialog.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.loginBindUid] = ToggleAccountDialog.onLoginBindUidResponse;
};

ToggleAccountDialog.explainPHPFlag = function(flag)
    local msg;
    if flag == 11 then
        msg = "手机号或邮箱格式不正确";
    elseif flag == 13 then
        msg = "验证码错误";
    elseif flag == 14 then
        msg = "用户不存在";
    elseif flag == 15 then
        msg = "绑定失败";
    elseif flag == 16 then
        msg = "验证码发送失败";
    end
    return msg;
end

ToggleAccountDialogAcountItem = class(Node)

ToggleAccountDialogAcountItem.ctor = function(self,data,handler)
    self.m_data = data;
    self.m_handler = handler;
    
    self.m_root = new(Node);
    self.m_root:setFillParent(true,true);

    self.m_del_view = new(Node);
    self.m_del_view:setFillParent(true,true);
    --self.m_del_view:setEventDrag(self,function()end);
    self.m_del_view:setEventTouch(self,function()end);
    self.m_del_view:setVisible(false);

    self.m_del_btn = new(Button,"common/button/close_btn_normal.png","common/button/close_btn_press.png");
    self.m_del_btn:setOnClick(self,self.onDelClick);
    self.m_del_btn:setAlign(kAlignTop);
    self.m_del_btn:setPos(65,25);
    self.m_del_view:addChild(self.m_del_btn);
    self:addChild(self.m_root);
    self:addChild(self.m_del_view);

    self:setSize(ToggleAccountDialog.s_item_w,ToggleAccountDialog.s_item_h);
    self.m_headIconBg = new(Button,"common/background/head_mask_bg_122.png");
    self.m_headIconBg:setSrollOnClick();
    self.m_headIconBg:setAlign(kAlignTop);
    self.m_headIconBg:setPos(nil,30);
    self.m_root:addChild(self.m_headIconBg);
    self.m_headIcon = new(Mask,"common/background/head_mask_bg_122.png","common/background/head_mask_bg_122.png");
    self.m_headIcon:setAlign(kAlignCenter);
    self.m_headIconBg:addChild(self.m_headIcon);
    self.m_name = new(Text,"", nil, nil, kAlignCenter, nil, 28, 80, 80, 80);
    self.m_name:setAlign(kAlignTop);
    self.m_name:setPos(nil,165);
    self.m_root:addChild(self.m_name);

    if self.m_data then
        if self.m_data.loginType == UserInfo.s_acountType.youke then
            self.m_name:setText("游客登录");
            self.m_headIconBg:setOnClick(self.m_handler,ToggleAccountDialog.onYoukeLogin);
            self.m_headIcon:setFile("common/icon/youke.png");
            if self.m_data.new_uuid then
                self:updateView();
                self.m_loginTypeView = new(Node);
                self.m_loginTypeView:setAlign(kAlignTop);
                self.m_loginTypeView:setPos(nil,200);
                local img = new(Image,"common/icon/youke_mini.png");
                local iw,ih = img:getSize();
                img:setAlign(kAlignLeft);
                img:setPos(0,0);
                local text = new(Text,"游客登录", nil, nil, kAlignCenter, nil, 22, 80, 80, 80);
                local tw,th = text:getSize();
                text:setAlign(kAlignLeft);
                text:setPos(iw,(ih-th)/2);
                self.m_loginTypeView:setSize(tw+iw,math.max(ih,th));
                self.m_loginTypeView:addChild(img);
                self.m_loginTypeView:addChild(text);
                self.m_root:addChild(self.m_loginTypeView);
            end
            self.m_del_btn:setVisible(false);
            self.no_del = true;
        elseif self.m_data.loginType == UserInfo.s_acountType.phone then
            if self.m_data.new_uuid then
                self.m_headIconBg:setOnClick(self,self.onClick);
                self:updateView();
                self.m_loginTypeView = new(Node);
                self.m_loginTypeView:setAlign(kAlignTop);
                self.m_loginTypeView:setPos(nil,200);
                local img = new(Image,"common/icon/phone_mini.png");
                local iw,ih = img:getSize();
                img:setAlign(kAlignLeft);
                img:setPos(0,0);
                local text = new(Text,"手机登录", nil, nil, kAlignCenter, nil, 22, 80, 80, 80);
                local tw,th = text:getSize();
                text:setAlign(kAlignLeft);
                text:setPos(iw,(ih-th)/2);
                self.m_loginTypeView:setSize(tw+iw,math.max(ih,th));
                self.m_loginTypeView:addChild(img);
                self.m_loginTypeView:addChild(text);
                self.m_root:addChild(self.m_loginTypeView);
            else
                self.m_headIconBg:setOnClick(self.m_handler,ToggleAccountDialog.onPhoneLogin);
                self.m_name:setText("手机登录");
                self.m_headIcon:setFile("common/icon/phone.png");
                self.m_del_btn:setVisible(false);
                self.no_del = true;
            end
        elseif self.m_data.loginType == UserInfo.s_acountType.boyaa then
            if self.m_data.new_uuid then
                self.m_headIconBg:setOnClick(self,self.onClick);
                self:updateView();
                self.m_loginTypeView = new(Node);
                self.m_loginTypeView:setAlign(kAlignTop);
                self.m_loginTypeView:setPos(nil,200);
                local img = new(Image,"common/icon/boyaa_mini.png");
                local iw,ih = img:getSize();
                img:setAlign(kAlignLeft);
                img:setPos(0,0);
                local text = new(Text,"博雅棋友", nil, nil, kAlignCenter, nil, 22, 80, 80, 80);
                local tw,th = text:getSize();
                text:setAlign(kAlignLeft);
                text:setPos(iw,(ih-th)/2);
                self.m_loginTypeView:setSize(tw+iw,math.max(ih,th));
                self.m_loginTypeView:addChild(img);
                self.m_loginTypeView:addChild(text);
                self.m_root:addChild(self.m_loginTypeView);
            else
                self.m_headIconBg:setOnClick(self.m_handler,ToggleAccountDialog.onBoyaaLogin);
                self.m_name:setText("博雅棋友");
                self.m_headIcon:setFile("common/icon/boyaa.png");
                self.m_del_btn:setVisible(false);
                self.no_del = true;
            end
        elseif self.m_data.loginType == UserInfo.s_acountType.weibo then
            if self.m_data.new_uuid then
                self.m_headIconBg:setOnClick(self,self.onClick);
                self:updateView();
                self.m_loginTypeView = new(Node);
                self.m_loginTypeView:setAlign(kAlignTop);
                self.m_loginTypeView:setPos(nil,200);
                local img = new(Image,"common/icon/weibo_mini.png");
                local iw,ih = img:getSize();
                img:setAlign(kAlignLeft);
                img:setPos(0,0);
                local text = new(Text,"微博登录", nil, nil, kAlignCenter, nil, 22, 80, 80, 80);
                local tw,th = text:getSize();
                text:setAlign(kAlignLeft);
                text:setPos(iw,(ih-th)/2);
                self.m_loginTypeView:setSize(tw+iw,math.max(ih,th));
                self.m_loginTypeView:addChild(img);
                self.m_loginTypeView:addChild(text);
                self.m_root:addChild(self.m_loginTypeView);
            else
                self.m_headIconBg:setOnClick(self.m_handler,ToggleAccountDialog.onWeiBoLogin);
                self.m_name:setText("微博登录");
                self.m_headIcon:setFile("common/icon/weibo.png");
                self.m_del_btn:setVisible(false);
                self.no_del = true;
            end
        elseif self.m_data.loginType == UserInfo.s_acountType.wechat then
            if self.m_data.new_uuid then
                self.m_headIconBg:setOnClick(self,self.onClick);
                self:updateView();
                self.m_loginTypeView = new(Node);
                self.m_loginTypeView:setAlign(kAlignTop);
                self.m_loginTypeView:setPos(nil,200);
                local img = new(Image,"common/icon/wechat_mini.png");
                local iw,ih = img:getSize();
                img:setAlign(kAlignLeft);
                img:setPos(0,0);
                local text = new(Text,"微信登录", nil, nil, kAlignCenter, nil, 22, 80, 80, 80);
                local tw,th = text:getSize();
                text:setAlign(kAlignLeft);
                text:setPos(iw,(ih-th)/2);
                self.m_loginTypeView:setSize(tw+iw,math.max(ih,th));
                self.m_loginTypeView:addChild(img);
                self.m_loginTypeView:addChild(text);
                self.m_root:addChild(self.m_loginTypeView);
            else
                self.m_headIconBg:setOnClick(self.m_handler,ToggleAccountDialog.onWechatLogin);
                self.m_name:setText("微信登录");
                self.m_headIcon:setFile("common/icon/wechat.png");
                self.m_del_btn:setVisible(false);
                self.no_del = true;
            end
        end
    end
    
end

ToggleAccountDialogAcountItem.onClick = function(self)
    ToggleAccountDialog.login(self.m_handler,self.m_data.new_uuid);
end

ToggleAccountDialogAcountItem.updateView = function(self)
    if self.m_data.name then
        self.m_name:setText(self.m_data.name);
    end
    if self.m_data.iconType then
        local iconType = self.m_data.iconType;
        if iconType == -1 then
            self.m_headIcon:setUrlImage(self.m_data.icon);
        elseif iconType > 0 and UserInfo.DEFAULT_ICON[iconType] then
            self.m_headIcon:setFile(UserInfo.DEFAULT_ICON[iconType]);
        else
            self.m_headIcon:setFile("userinfo/default_head.png");
        end
    end
end

ToggleAccountDialogAcountItem.updateHeadIcon = function(self,info)
    if info.what and info.what == "acount"..self.m_data.new_uuid then
        self.m_headIcon:setFile(info.ImageName);
    end
end
ToggleAccountDialogAcountItem.onDelClick = function(self)
    if self.delFunc then
        self.delFunc();
    end
end
ToggleAccountDialogAcountItem.setDeletefunc = function(self,func)
    self.delFunc = func;
end

ToggleAccountDialogAcountItem.getData = function(self)
    return self.m_data;
end

ToggleAccountDialogAcountItem.moveTo = function(self,to_x,to_y)
    local from_x,from_y = self:getPos();
    if not self:checkAddProp(2) then
        self:removeProp(2);
    end
    self:addPropTranslate(2, kAnimNormal, 500, -1, 0, to_x-from_x, 0, to_y-from_y);
    self.m_moveAnim = AnimFactory.createAnimInt(kAnimNormal, 0, 1, 400, -1);
    self.m_moveAnim:setDebugName("ToggleAccountDialogAcountItem.moveTo");
    self.m_moveAnim:setEvent(self,
        function()
            if not self:checkAddProp(2) then
                self:removeProp(2);
            end
            self:setPos(to_x,to_y);
    Log.i("aaa   "..to_x.."   "..to_y)
        end
    );
end

ToggleAccountDialogAcountItem.changeDelState = function(self,flag)
    self.m_del_view:setVisible(flag);
    if self.no_del then 
        self:setVisible(not flag);
        return false; 
    end
    if flag then
        local x,y = self.m_del_btn:getUnalignPos();
        local w,h = self.m_del_btn:getSize();
        if not self:checkAddProp(1) then
            self:removeProp(1);
        end
        self:addPropRotate(1, kAnimLoop, 100, -1, -2, 2, kCenterDrawing);
    else
        if not self:checkAddProp(1) then
            self:removeProp(1);
        end
    end
    return true;
end  

ToggleAccountDialogAcountItem.dtor = function(self)
    delete(self.m_moveAnim);
end  