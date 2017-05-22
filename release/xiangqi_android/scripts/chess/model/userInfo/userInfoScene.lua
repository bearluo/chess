--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23

require(BASE_PATH.."chessScene");

UserInfoScene = class(ChessScene);

UserInfoScene.s_controls = 
{
    back_btn            = 1;
    title_icon          = 2;
    userinfo_view       = 3;
    head_btn            = 4;
    head_icon_bg        = 5;
    name_btn            = 6;
    user_uid            = 7;
    login_type          = 8;
    bind_view           = 9;
    info_view           = 10;
    sex_btn             = 12;
    area_btn            = 13;
    deck_btn            = 14;
}

UserInfoScene.s_cmds = 
{
    updateUserInfoView = 1;
    updateUserHead = 2;
    upLoadImage = 3;
    updateFriendsRank = 4;
    updateRank = 5;
    dismissSelectSexDialog = 6;
    dismissBindPhoneDialog = 7;
    closeDialog         = 8;
}
UserInfoScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = UserInfoScene.s_controls;
    self:create();
end 

UserInfoScene.resume = function(self)
    ChessScene.resume(self);
    self:updateUserInfoView();
--    self:removeAnimProp();
--    self:resumeAnimStart();
end;

UserInfoScene.isShowBangdinDialog = false;

UserInfoScene.pause = function(self)
	ChessScene.pause(self);
    self:removeAnimProp();
--    self:pauseAnimStart();
end 

UserInfoScene.dtor = function(self)
    delete(self.m_chioce_dialog);
    delete(self.m_changeHeadDialog);
    delete(self.m_locate_city_dialog);
    delete(self.m_select_sex_dialog);
    delete(self.m_bind_phone_dialog);
    delete(self.anim_start);
    delete(self.anim_end);
end 

UserInfoScene.removeAnimProp = function(self)
    if self.m_anim_prop_need_remove then
--        self.m_userinfo_view:removeProp(1);
        self.m_title_icon:removeProp(1);
        self.m_back_btn:removeProp(1);
        self.m_leaf_left:removeProp(1);
        self.m_anim_prop_need_remove = false;
    end
--    self.m_top_view:removeProp(1);
--    self.m_more_btn:removeProp(1);
--    self.m_bottom_view:removeProp(1);
end

UserInfoScene.setAnimItemEnVisible = function(self,ret)
    self.m_leaf_left:setVisible(ret);
--    self.right_leaf:setVisible(ret);
end

UserInfoScene.resumeAnimStart = function(self,lastStateObj,timer)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;
    delete(self.anim_start);
    self.anim_start = new(AnimInt,kAnimNormal,0,1,delay,-1);
    if self.anim_start then
        self.anim_start:setEvent(self,function()
            self:setAnimItemEnVisible(true);
            delete(self.anim_start);
        end);
    end
--    self.m_assets_view:addPropTransparency(1,kAnimNormal,waitTime,delay,0,1);
    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, delay, -lw, 0, -10, 0);
    local tw,th = self.m_title_icon:getSize();
    local anim = self.m_title_icon:addPropTranslate(1, kAnimNormal, waitTime, delay, 0, 0, -th, 0);
    anim:setEvent(self,function()
        self.m_anim_prop_need_remove = true;
        self:removeAnimProp();
        if not self.m_root:checkAddProp(1) then 
		    self.m_root:removeProp(1);
	    end  
    end);   
end

UserInfoScene.pauseAnimStart = function(self,newStateObj,timer)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;
    delete(self.anim_end);
    self.anim_end = new(AnimInt,kAnimNormal,0,1,delay,-1);
    if self.anim_end then
        self.anim_end:setEvent(self,function()
            self.m_anim_prop_need_remove = true;
            self:removeAnimProp();
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end  
            delete(self.anim_end);
        end);
    end
--    self.m_assets_view:addPropTransparency(1,kAnimNormal,waitTime,-1,1,0);
    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, -lw, 0, -10);
    local w,h = self.m_title_icon:getSize();
    local anim = self.m_title_icon:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, 0, 0, -h);
    anim:setEvent(self,function()
        self:setAnimItemEnVisible(false);
    end);
end

---------------------- func --------------------
UserInfoScene.create = function(self)

    self.m_back_btn = self:findViewById(self.m_ctrls.back_btn);
    self.m_title_icon = self:findViewById(self.m_ctrls.title_icon);
    self.m_userinfo_view = self:findViewById(self.m_ctrls.userinfo_view);
    self.m_head_btn = self:findViewById(self.m_ctrls.head_btn);
    self.m_head_icon_bg = self:findViewById(self.m_ctrls.head_icon_bg);
    self.m_vip_frame = self.m_head_icon_bg:getChildByName("vip_frame");
    self.m_leaf_left = self.m_root:getChildByName("bamboo_left");
    -- 头像
    self.m_head_icon = new(Mask,"common/background/head_mask_bg_122.png","common/background/head_mask_bg_122.png");
    self.m_head_icon:setAlign(kAlignCenter);
    self.m_head_icon_bg:addChild(self.m_head_icon);
    self.m_name_btn = self:findViewById(self.m_ctrls.name_btn);
    self.m_user_uid = self:findViewById(self.m_ctrls.user_uid);
    self.m_login_type = self:findViewById(self.m_ctrls.login_type);
    self.m_select_deck = self:findViewById(self.m_ctrls.deck_btn);

    self.m_bind_view = self:findViewById(self.m_ctrls.bind_view);
    self.m_line_bg = new(Image,"common/background/line_bg.png",nil,nil,64,64,64,64);
    self.m_line_bg:setAlign(kAlignTop);
    self.m_line_bg:setSize(590,290);
    self.m_bind_view:addChild(self.m_line_bg);

    self.m_bind_list_view = new(ListView,0,0,UserInfoSceneBindItem.ITEM_WIDTH,UserInfoSceneBindItem.ITEM_HEIGHT);
    self.m_bind_list_view:setAlign(kAlignTop);
    self.m_bind_list_view:setDirection(kVertical);
    self.m_bind_view:addChild(self.m_bind_list_view);

    self.m_info_view = self:findViewById(self.m_ctrls.info_view);
    self.m_sex_btn = self:findViewById(self.m_ctrls.sex_btn);
    self.m_area_btn = self:findViewById(self.m_ctrls.area_btn);

    self.m_sexType = UserInfo.getInstance():getSex() or 0;
    if kPlatform == kPlatformIOS then
        self.m_login_type_view = self.m_userinfo_view:getChildByName("top_view"):getChildByName("login_type_view");
        self.m_personal_deck_view = self.m_userinfo_view:getChildByName("top_view"):getChildByName("personality_deck");
        
        if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
            self.m_bind_view:setVisible(true);
            self.m_info_view:setPos(nil,985);
            self.m_login_type_view:setVisible(true);
            self.m_personal_deck_view:setVisible(true);
        else
            self.m_bind_view:setVisible(false);
            self.m_info_view:setPos(nil,670);
            self.m_login_type_view:setVisible(false);
            self.m_personal_deck_view:setVisible(false);
        end;
    end;
    self:updateUserInfoView();
end

UserInfoScene.s_headIconFile = UserInfo.DEFAULT_ICON;

UserInfoScene.updateUserHeadIcon = function(self)
    local iconType = UserInfo.getInstance():getIconType();
    if iconType == -1 then
        local file = UserInfo.getInstance():getIcon();
        self.m_head_icon:setUrlImage(file);
    elseif iconType > 0 and UserInfoScene.s_headIconFile[iconType] then
        self.m_head_icon:setFile(UserInfoScene.s_headIconFile[iconType] or UserInfoScene.s_headIconFile[1]);
    else
        self.m_head_icon:setFile(UserInfoScene.s_headIconFile[1]);
    end
end

UserInfoScene.updateUserInfoView = function(self)
    --更新头像
    self:updateUserHeadIcon();
    --更新姓名
    self.m_name_btn:getChildByName("title"):setText(UserInfo.getInstance():getName(),0,0);
    --更新uid
    self.m_user_uid:setText(UserInfo.getInstance():getUid(),0,0);
    --更新登录方式
    self.m_login_type:setText(UserInfo.getInstance():getAccountTypeName(),0,0);
    --更新性别
    self.m_sex_btn:getChildByName("title"):setText(UserInfo.getInstance():getSexString(),0,0);
    --更新地区
    local name = UserInfo.getInstance():getCityName();
    if name then
        self.m_area_btn:getChildByName("title"):setText(name,0,0);
    end
    local is_vip = UserInfo.getInstance():getIsVip();
    local frameRes = UserSetInfo.getInstance():getFrameRes();
    self.m_vip_frame:setVisible(frameRes.visible);
    local fw,fh = self.m_vip_frame:getSize();
    if frameRes.frame_res then
        self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
    end

    -- 更新绑定界面
    self:updateBindView();
end

UserInfoScene.dismissSelectSexDialog = function(self)
    if self.m_select_sex_dialog then
        self.m_select_sex_dialog:dismiss();
    end
end

UserInfoScene.closeDialog = function(self)
    if self.m_remove_bind_dialog and self.m_remove_bind_dialog:isShowing() then
        self.m_remove_bind_dialog:dismiss();
        return true;
    end
    return false;
end


UserInfoScene.dismissBindPhoneDialog = function(self)
    if self.m_bind_phone_dialog then
        self.m_bind_phone_dialog:dismiss();
    end
end

UserInfoScene.updateBindType = function(self)
    local accountType = UserInfo.getInstance():getAccountType();
    local bindTab = {{accountType = 1}};
    if (accountType == 201) or (accountType == 1) or (accountType == 101) then
        table.insert(bindTab,{accountType = 3});
        table.insert(bindTab,{accountType = 10});
    elseif accountType == 10 then
        table.insert(bindTab,{accountType = 10});
    elseif accountType == 3 then
        table.insert(bindTab,{accountType = 3});
    else
        
    end

    for k,v in pairs(bindTab) do
        v.handler = self;
    end

    return bindTab;
end

UserInfoScene.updateBindView = function(self)
    self.m_bind_list_view:releaseAllViews();
    delete(self.m_adapter);

    local bindtab = self:updateBindType();
    local num = 1;
    if bindtab and #bindtab ~= 0 then
        num = #bindtab;
    end
    self.m_line_bg:setSize(UserInfoSceneBindItem.ITEM_WIDTH,num * UserInfoSceneBindItem.ITEM_HEIGHT);
    self.m_adapter = new(CacheAdapter,UserInfoSceneBindItem,bindtab);
    self.m_bind_list_view:setAdapter(self.m_adapter);
    self.m_bind_list_view:setSize(UserInfoSceneBindItem.ITEM_WIDTH,num * UserInfoSceneBindItem.ITEM_HEIGHT);
    local x,y = self.m_bind_view:getPos();
    self.m_info_view:setPos(x,y + 30 + num * UserInfoSceneBindItem.ITEM_HEIGHT);
    if kPlatform == kPlatformIOS then
        if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
            self.m_info_view:setPos(nil,985);
        else
            self.m_info_view:setPos(nil,670);
        end;
    end;
end

UserInfoScene.contentTextChange = function(self,text)
    if not text then text = "" end
	local content = text;
    local utf8_length = string.len("我") - 1;
    if utf8_length == 0 then utf8_length = 1; end
    local index = (string.len(content) + ( utf8_length - 1 ) * ToolKit.utfstrlen(content)) / utf8_length;
	if index > 8  then
		local message = "亲，您的名字有点长哦!(英文8个字符，中文4个字符)";
		if not self.m_chioce_dialog then
			require("dialog/chioce_dialog");
            self.m_chioce_dialog = new(ChioceDialog);
		end
		self.m_chioce_dialog:setMode(ChioceDialog.MODE_OK);
		self.m_chioce_dialog:setMessage(message);
		self.m_chioce_dialog:setPositiveListener();
		self.m_chioce_dialog:show();
        self.m_name_btn:getChildByName("title"):setText(UserInfo.getInstance():getName(),0,0);
        return ;
	end
    self.m_name_btn:getChildByName("title"):setText(text,0,0);
    self:saveUserInfo();
end

UserInfoScene.saveUserInfo = function(self, sysIcon)
    local data = {};
    data.sex = self.m_sexType;
    data.name = self.m_name_btn:getChildByName("title"):getText();
    data.iconType = self.m_iconType or UserInfo.getInstance():getIconType();
    if sysIcon then
        data.icon_url = self.m_iconName or "women_head01.png";
    end;
    self:requestCtrlCmd(UserInfoController.s_cmds.saveUserInfo,data);
end

UserInfoScene.upLoadImage = function(self,iconType)
    self.m_iconType = -1;
    self:saveUserInfo();
end

UserInfoScene.showChangeHeadDialog = function(self)
    if not self.m_changeHeadDialog then
        require("dialog/change_head_icon_dialog");
        self.m_changeHeadDialog = new(ChangeHeadIconDialog);
        self.m_changeHeadDialog:setConfirmClick(self,self.changeUserIcon);
    end
    self.m_changeHeadDialog:show();
end

UserInfoScene.changeUserIcon = function(self,iconType,iconName)
    self.m_iconType = iconType;
    self.m_iconName = iconName;
    self:saveUserInfo(true);
end
--------------------- click ------------------
UserInfoScene.onBackBtnClick = function(self)
    Log.i("UserInfoScene.onBackBtnClick");
    self:requestCtrlCmd(UserInfoController.s_cmds.onBack);
end

UserInfoScene.showEditTextGlobal = function(self)
    EditTextGlobal = self;
	ime_open_edit(self.m_name_btn:getChildByName("title"):getText(),
		"",
		kEditBoxInputModeSingleLine,
		kEditBoxInputFlagInitialCapsSentence,
		kKeyboardReturnTypeDone,
		-1,"global");
end

UserInfoScene.setText = function(self, str, width, height, r, g, b)
    self.m_name_btn:getChildByName("title"):setText(str,0,0);
--    self:contentTextChange(str);
end

UserInfoScene.onTextChange = function(self)
    self:contentTextChange(self.m_name_btn:getChildByName("title"):getText());
end

UserInfoScene.showLocateCityDialog = function(self)
    if not self.m_locate_city_dialog then
        require("dialog/city_locate_pop_dialog");
        self.m_locate_city_dialog = new(CityLocatePopDialog);
        self.m_locate_city_dialog:setDismissCallBack(self,self.updateUserInfoView);
    end
    self.m_locate_city_dialog:show();
end

UserInfoScene.setPersonDeck = function(self)
    self:requestCtrlCmd(UserInfoController.s_cmds.gotoDeck);
end

UserInfoScene.showSelectSexDialog = function(self)
    if not self.m_select_sex_dialog then
        require("dialog/select_sex_dialog");
        self.m_select_sex_dialog = new(SelectSexDialog);
    end
    self.m_select_sex_dialog:show();
end

UserInfoScene.showBindPhoneDialog = function(self)
    delete(self.m_bind_phone_dialog);
    require(DIALOG_PATH.."bangdin_dialog");
    self.m_bind_phone_dialog = new(BangDinDialog);
    self.m_bind_phone_dialog:setHandler(self)
    self.m_bind_phone_dialog:show();
end

UserInfoScene.bindWeibo = function(self)
    dict_set_string(kLoginMode,kLoginMode..kparmPostfix,0);
	call_native(kLoginWithWeibo);
    if System.getPlatform() == kPlatformWin32 then
        local post_data = {};
        post_data.bind_uuid = "win32Test";
        post_data.mid = UserInfo.getInstance():getUid();
        post_data.sid = UserInfoController.s_sid.xinlang;
        HttpModule.getInstance():execute(HttpModule.s_cmds.bindUid,post_data,"绑定中...");
    end
end

UserInfoScene.bindWeChat = function(self)
    call_native(kLoginWeChat);
    if System.getPlatform() == kPlatformWin32 then
        local post_data = {};
        post_data.bind_uuid = "win32Test";
        post_data.mid = UserInfo.getInstance():getUid();
        post_data.sid = UserInfoController.s_sid.weichat;
        HttpModule.getInstance():execute(HttpModule.s_cmds.bindUid,post_data,"绑定中...");
    end
end
--[[
    重新绑定dialog
--]]
UserInfoScene.removeBind = function(self,accounttype)
    require("dialog/remove_bind_dialog");
    if not self.m_remove_bind_dialog then
        self.m_remove_bind_dialog = new(RemoveBindDialog);
    end
    self.m_remove_bind_dialog:setAccountType(accounttype);
--    self.m_remove_bind_dialog:setHandler(self);
    self.m_remove_bind_dialog:setRebindCallBack(self,self.showBindPhoneDialog);
    self.m_remove_bind_dialog:show();
end


---------------------- config ------------------
UserInfoScene.s_controlConfig = 
{
    [UserInfoScene.s_controls.back_btn]             = {"back_btn"};
    [UserInfoScene.s_controls.title_icon]           = {"title_icon"};
    [UserInfoScene.s_controls.userinfo_view]        = {"userinfo_view"};
    [UserInfoScene.s_controls.head_btn]             = {"userinfo_view","top_view","head_btn"};
    [UserInfoScene.s_controls.head_icon_bg]         = {"userinfo_view","top_view","head_btn","head_icon_bg"};
    [UserInfoScene.s_controls.name_btn]             = {"userinfo_view","top_view","name_btn"};
    [UserInfoScene.s_controls.user_uid]             = {"userinfo_view","top_view","uid_view","title"};
    [UserInfoScene.s_controls.login_type]           = {"userinfo_view","top_view","login_type_view","title"};
    [UserInfoScene.s_controls.bind_view]            = {"userinfo_view","bind_view"};
    [UserInfoScene.s_controls.info_view]            = {"userinfo_view","info_view"};
    [UserInfoScene.s_controls.sex_btn]              = {"userinfo_view","info_view","sex_btn"};
    [UserInfoScene.s_controls.area_btn]             = {"userinfo_view","info_view","area_btn"};
    [UserInfoScene.s_controls.deck_btn]             = {"userinfo_view","top_view","personality_deck"};
};

UserInfoScene.s_controlFuncMap =
{
	[UserInfoScene.s_controls.back_btn]             = UserInfoScene.onBackBtnClick;
    [UserInfoScene.s_controls.head_btn]             = UserInfoScene.showChangeHeadDialog;
    [UserInfoScene.s_controls.name_btn]             = UserInfoScene.showEditTextGlobal;
    [UserInfoScene.s_controls.area_btn]             = UserInfoScene.showLocateCityDialog;
    [UserInfoScene.s_controls.sex_btn]              = UserInfoScene.showSelectSexDialog;
    [UserInfoScene.s_controls.deck_btn]             = UserInfoScene.setPersonDeck;
};

UserInfoScene.s_cmdConfig =
{
    [UserInfoScene.s_cmds.updateUserInfoView] = UserInfoScene.updateUserInfoView;
    [UserInfoScene.s_cmds.updateUserHead] = UserInfoScene.updateUserHeadIcon;
    [UserInfoScene.s_cmds.upLoadImage] = UserInfoScene.upLoadImage;
    [UserInfoScene.s_cmds.updateFriendsRank] = UserInfoScene.updateFriendsRankCall;
    [UserInfoScene.s_cmds.updateRank] = UserInfoScene.updateRank;
    [UserInfoScene.s_cmds.dismissBindPhoneDialog] = UserInfoScene.dismissBindPhoneDialog;
    [UserInfoScene.s_cmds.dismissSelectSexDialog] = UserInfoScene.dismissSelectSexDialog;
    [UserInfoScene.s_cmds.closeDialog] = UserInfoScene.closeDialog;
}



UserInfoSceneBindItem = class(Node);

UserInfoSceneBindItem.DEFAULT_ICON = 
{
    [1]  = "common/icon/phone.png", 
    [3]  = "common/icon/wechat.png", 
    [10] = "common/icon/weibo.png",
}

UserInfoSceneBindItem.DEFAULT_TYPE = 
{
    [1]  = "手机", 
    [3]  = "微信", 
    [10] = "微博",
}

UserInfoSceneBindItem.ITEM_WIDTH = 590;
UserInfoSceneBindItem.ITEM_HEIGHT = 92;

UserInfoSceneBindItem.ctor = function(self,data)
    if not data then return end
    self.m_handler = data.handler;
    self.accountType = data.accountType;
    if not self.accountType then return end
    self:setSize(UserInfoSceneBindItem.ITEM_WIDTH,UserInfoSceneBindItem.ITEM_HEIGHT);

    --item点击按钮
    self.m_button = new(Button,"drawable/blank.png","drawable/blank_press.png");
    self.m_button:setSize(590,92);
    self.m_button:setAlign(kAlignCenter);
    self.m_button:setOnClick(self,self.onItemClick);
    --图标
    local imgStr = "common/icon/phone.png";
    imgStr = UserInfoSceneBindItem.DEFAULT_ICON[self.accountType];
    self.m_iconType = new(Image,imgStr);
    self.m_iconType:setSize(52,52);
    self.m_iconType:setAlign(kAlignLeft);
    self.m_iconType:setPos(29,0);
    --bottom line
    self.m_bottom_line = new(Image,"decoration/line_2.png");
    self.m_bottom_line:setSize(590,2);
    self.m_bottom_line:setAlign(kAlignBottom);
    --绑定类型text
    local msg = "手机";
    msg = UserInfoSceneBindItem.DEFAULT_TYPE[self.accountType];
    self.m_bing_type = new(Text,msg,72,36,nil,nil,36,135,100,95);
    self.m_bing_type:setAlign(kAlignLeft);
    self.m_bing_type:setPos(100,0);
    --箭头图标
    self.m_arrow = new(Image,"common/icon/arrow_r.png");
    self.m_arrow:setSize(14,25);
    self.m_arrow:setAlign(kAlignRight);
    self.m_arrow:setPos(21,0);
    --绑定状态
    self.bindStatus = false;
    local bindStatusText = "未绑定";
    local num = UserInfo.getInstance():findBindAccountBySid(self.accountType);
    if num then
        self.bindStatus = true;
        bindStatusText = "已绑定";
    else
        self.bindStatus = false;
        bindStatusText = "未绑定";
    end
    self.title = new(Text,bindStatusText,64,36,nil,nil,32,80,80,80);
    self.title:setAlign(kAlignRight);
    self.title:setPos(68,0);

    self:addChild(self.title);
    self:addChild(self.m_bing_type);
    self:addChild(self.m_bottom_line);
    self:addChild(self.m_iconType);
    self:addChild(self.m_button);
    self:addChild(self.m_arrow);
end

UserInfoSceneBindItem.dtor = function(self)

end

UserInfoSceneBindItem.onItemClick = function(self)
    if self.bindStatus then
        --解除绑定
        self.m_handler:removeBind(self.accountType);
    else
        --绑定
        if self.accountType == 201 or self.accountType == 1 then
            self.m_handler:showBindPhoneDialog();
        elseif self.accountType == 3 then
            self.m_handler:bindWeChat();
        elseif self.accountType == 10 then
            self.m_handler:bindWeibo();
        end
    end
end