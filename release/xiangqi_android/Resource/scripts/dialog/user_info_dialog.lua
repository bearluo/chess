
require("uiex/richText");
require("dialog/report_dialog");
require(MODEL_PATH .. "giftModule/giftModuleScrollList")
require(MODEL_PATH .. "giftModule/giftModuleController")
require("ui/radioCheckButton");

UserInfoDialog = class();

UserInfoDialog.up_chess_pos = {
    [1] = {pos = 90, available = true};
    [2] = {pos = 162, available = true};
    [3] = {pos = 237, available = true};
    [4] = {pos = 308, available = true};
    [5] = {pos = 382, available = true};
    [6] = {pos = 453, available = true};
    [7] = {pos = 524, available = true};
};

UserInfoDialog.down_chess_pos = {
    [1] = {pos = 90, available = true};
    [2] = {pos = 162, available = true};
    [3] = {pos = 237, available = true};
    [4] = {pos = 308, available = true};
    [5] = {pos = 382, available = true};
    [6] = {pos = 453, available = true};
    [7] = {pos = 524, available = true};
};
-- up_user_info_
UserInfoDialog.ctor = function(self,root_view,prefix,isConsole)--isConsole是否单机
	self.m_root_view = root_view;
	self.m_prefix = prefix;
    self.m_isConsole = isConsole;
    self.m_root_dialog = self.m_root_view:getChildByName(self.m_prefix .. "dialog");
	self.m_icon_bg = self.m_root_dialog:getChildByName(self.m_prefix .. "icon_bg");
	self.m_icon_mask = self.m_icon_bg:getChildByName(self.m_prefix .. "icon_mask");
    self.m_icon = new(Mask,"online/room/head_mask.png","online/room/head_mask.png");
    self.m_icon:setSize(self.m_icon_mask:getSize());
    self.m_icon_mask:addChild(self.m_icon);
	self.m_name = self.m_root_dialog:getChildByName(self.m_prefix.."name");
    self.m_id = self.m_root_dialog:getChildByName(self.m_prefix.."id");
	self.m_sex = self.m_root_dialog:getChildByName(self.m_prefix.."sex");
	self.m_rank = self.m_root_dialog:getChildByName(self.m_prefix.."rank");
	self.m_title = self.m_root_dialog:getChildByName(self.m_prefix.."title");
	self.m_rate = self.m_root_dialog:getChildByName(self.m_prefix.."rate");

    self.m_root_dialog:setEventTouch(self,function() end);
    self.m_root_view:setEventTouch(self,self.dismiss);
--    self.m_money = self.m_root_dialog:getChildByName(self.m_prefix.."money_view"):getChildByName(self.m_prefix.."money");
--    self.m_send_gift_btn = self.m_root_dialog:getChildByName("gift_interact_btn");
--    self.m_send_gift_btn:setOnClick(self,function()
--        self.m_send_gift_view:setVisible(true);
--    end)

--    self.m_user_gift_view = self.m_root_dialog:getChildByName("gift_view");
--    self.m_scroll_list = new(GiftModuleScrollList,390,100,false);
--    self.m_scroll_list:initScrollView(1)
--    self.m_scroll_list:setPos(146,0)
--    self.m_scroll_list:setAlign(kAlignLeft)
--    self.m_user_gift_view:addChild(self.m_scroll_list);

--    self.m_send_gift_view = self.m_root_dialog:getChildByName("send_gift_view");

--    ------创建自定义选择按钮
--    self.m_radioButtonGroup = new(RadioCheckGroup);
--    self.m_radioButtonGroup:setSize(500,85);
--    self.m_radioButtonGroup:setAlign(kAlignTop);
--    self.m_radioButtonGroup:setPos(0,236);
--    self.m_user_gift_view:addChild(self.m_radioButtonGroup)

--    local nodeTen = new(RadioCheckButton);
--    nodeTen:setPos(40,0);
--    nodeTen:setAlign(kAlignLeft);
--    self.m_radioButtonGroup:addChild(nodeTen)
--    local textTen = new(Text,"10连送",nil,nil,30,80,80,80)
--    textTen:setPos(66,0)
--    nodeTen:addChild(textTen)

--    local nodeHundred = new(RadioCheckButton);
--    nodeHundred:setPos(290,0);
--    nodeHundred:setAlign(kAlignLeft);
--    local textHundred = new(Text,"100连送",nil,nil,30,80,80,80)
--    textHundred:setPos(66,0)
--    nodeHundred:addChild(textHundred)
--    self.m_radioButtonGroup:addChild(nodeHundred)
--    --------------


----    self.m_select_radio_btn = self.m_send_gift_view:getChildByName("select_send_num");
----    self.m_select_radio_btn:setOnChange(self,function()
----        local index = self.m_select_radio_btn:getResult()
----        GiftModuleController.getInstance():setSendGiftNum(index);
----    end);
--    self.m_item_view = self.m_send_gift_view:getChildByName("item_view");
--    self.m_gift_scroll_list = new(GiftModuleScrollList,560,154,true);
--    self.m_gift_scroll_list:initScrollView(2)
--    self.m_gift_scroll_list:setAlign(kAlignLeft)
--    self.m_item_view:addChild(self.m_gift_scroll_list);

    self.m_vip_logo = self.m_root_dialog:getChildByName(self.m_prefix .. "vip_logo");
    self.m_vip_frame = self.m_icon_bg:getChildByName(self.m_prefix .. "vip_frame");

        self.m_add_btn = self.m_root_dialog:getChildByName(self.m_prefix.."add_btn");
        self.m_add_btn:setOnClick(self,self.onAddBtnClick);
        self.m_cancle_btn = self.m_root_dialog:getChildByName(self.m_prefix.."cancle_btn");
        self.m_cancle_btn:setOnClick(self,self.onCancleBtnClick);
        -- report_btn add by Leoli 2016/4/12
        if not isConsole then
            self.m_report_btn = self.m_root_dialog:getChildByName(self.m_prefix.."report_btn");
            self.m_report_btn:setOnClick(self,self.showReportDialog);
            self.m_forbid_upuser_msg_btn = self.m_root_dialog:getChildByName(self.m_prefix.."forbid_btn");
            self.m_forbid_upuser_msg_btn:setOnClick(self,self.forbidUpUserMsg);
            self.m_forbid_text = self.m_forbid_upuser_msg_btn:getChildByName("forbid_txt");
            self.m_is_forbid = 0;

            --礼物相关部分
            self.m_send_gift_view = self.m_root_dialog:getChildByName("send_gift_view");
--            self.m_send_gift_bg = self.m_send_gift_view:getChildByName("view")
--            self.m_send_gift_bg:setEventTouch(self,function() 
--                    self.m_send_gift_view:setVisible(false);
--            end);
--            self.m_temp_view = self.m_send_gift_view:getChildByName("temp")
--            self.m_temp_view:setEventTouch(self,function() end);
            self.m_money = self.m_root_dialog:getChildByName(self.m_prefix.."money_view"):getChildByName(self.m_prefix.."money");
--            self.m_send_gift_btn = self.m_root_dialog:getChildByName("gift_interact_btn");
--            self.m_send_gift_btn:setOnClick(self,function()
--                self.m_send_gift_view:setVisible(true);
--            end)

--            self.m_user_gift_view = self.m_root_dialog:getChildByName("gift_view");
--            self.m_scroll_list = new(GiftModuleScrollList,390,100,GiftModuleItem.s_mode_user);
--            self.m_scroll_list:initScrollView(GiftModuleScrollList.s_ssize)
--            self.m_scroll_list:setPos(146,0)
--            self.m_scroll_list:setAlign(kAlignLeft)
--            self.m_user_gift_view:addChild(self.m_scroll_list);

            ------创建自定义选择按钮
--            self.m_radioButtonGroup = new(RadioCheckGroup);
--            self.m_radioButtonGroup:setSize(500,85);
--            self.m_radioButtonGroup:setAlign(kAlignBottom);
--            self.m_radioButtonGroup:setPos(0,-10);
--            self.m_send_gift_view:addChild(self.m_radioButtonGroup)
--            self.m_radioButtonGroup:removeAllChildren(true)

--            local nodeTen = new(RadioCheckButton);
--            nodeTen:setPos(40,0);
--            nodeTen:setAlign(kAlignLeft);
--            self.m_radioButtonGroup:addChild(nodeTen)
--            local textTen = new(Text,"10连送",nil,nil,nil,nil,30,80,80,80)
--            textTen:setPos(66,0)
--            textTen:setAlign(kAlignLeft);
--            nodeTen:addChild(textTen)

--            local nodeHundred = new(RadioCheckButton);
--            nodeHundred:setPos(290,0);
--            nodeHundred:setAlign(kAlignLeft);
--            local textHundred = new(Text,"100连送",nil,nil,nil,nil,30,80,80,80)
--            textHundred:setPos(66,0)
--            textHundred:setAlign(kAlignLeft);
--            nodeHundred:addChild(textHundred)
--            self.m_radioButtonGroup:addChild(nodeHundred)

            self.m_item_view = self.m_send_gift_view:getChildByName("item_view");
--            self.m_gift_scroll_list = new(GiftModuleScrollList,560,175,GiftModuleItem.s_mode_gift,self);
--            self.m_gift_scroll_list:initScrollView(GiftModuleScrollList.s_lsize)
--            self.m_gift_scroll_list:setAlign(kAlignLeft)
--            self.m_item_view:addChild(self.m_gift_scroll_list);
--            self.m_radioButtonGroup:setVisible(false);
            ----end
        end
	self.m_root_view:setVisible(false);
    self.m_root_view:setLevel(101);
end

UserInfoDialog.dtor = function(self)
	self.m_root_view = nil;
	self.m_prefix = nil;
    self.m_root_dialog = nil;
	self.m_name = nil
	self.m_sex = nil
	self.m_rank = nil
	self.m_title = nil
	self.m_rate = nil
    self.m_add_btn = nil;
    self.m_richText = nil;
    self.m_money = nil;
    self.m_send_gift_btn = nil;
--    self.m_user_gift_view = nil;
--    self.m_scroll_list = nil;
    self.m_send_gift_view = nil;
    self.m_select_radio_btn = nil;

end

UserInfoDialog.isShowing = function(self)
	return self.m_root_view:getVisible();
end

UserInfoDialog.show = function(self,user)
    self.m_user = user;
    EventDispatcher.getInstance():register(Event.Call,self,self.onNativeCallDone);
	if not user then
		print_string("UserInfoDialog.show but not user");
		return
	end

	print_string("UserInfoDialog.show" .. user:getName());

	if self.m_root_view:getVisible() then 
		print_string("aready show");
		return;
	end
	
    if not self.m_isConsole then
        if RoomProxy.getInstance():getCurRoomModeIsWatch() then
            self.m_forbid_upuser_msg_btn:setVisible(false);
            self.m_report_btn:setPos(-130);
            self.m_add_btn:setPos(110);
            self.m_cancle_btn:setPos(110);
        else
            self.m_report_btn:setPos(0);
            self.m_add_btn:setPos(40);
            self.m_cancle_btn:setPos(40);
        end
    end

	if user then
        local userName = user:getName() or "博雅象棋";
        local userSource = user:getSourceString() or "";
        local len = string.len(userName);
		if len > 8  then
            if userSource == "(Andriod)" then
                userSource = "(A.)"
            end
        end
        if self.m_richText then
            if self.m_root_dialog then
                self.m_root_dialog:removeChild(self.m_richText);
            end
            delete(self.m_richText);
        end
        self.m_name:setVisible(false);
		--self.m_name:setText(user:getName() .. user:getSourceString());
		self.m_sex:setText(user:getSexString());
		self.m_rank:setText(user:getRank());
        if user:getRank() == "..." and user:getUid() and user:getUid() > 0 then
            local userData = FriendsData.getInstance():getUserData(user:getUid());
            if userData then
                self.m_rank:setText(userData.rank);
            end
        end
        if not self.m_isConsole then
            self.m_uid = user:getUid() or 0;
            self.m_id:setText("ID:"..self.m_uid);
            self.m_richText = new(RichText,"#c505050"..userName.."#s20" .. userSource,200,36,kAlignLeft,nil,28,80,80,80,true);
		    self.m_title:setText(UserInfo.getInstance():getDanGradingNameByScore(user:getScore()) .. "(" ..user:getScore() .. "积分)" );
            local iconType = tonumber(user:getIconType());
--            if iconType == -1 then
--                self.m_icon:setUrlImage(user:getIcon());
--            else
--                self.m_icon:setFile(UserInfo.DEFAULT_ICON[iconType] or UserInfo.DEFAULT_ICON[1]);
--            end
            if iconType and iconType >= 0 then
                self.m_icon:setFile(UserInfo.DEFAULT_ICON[iconType] or UserInfo.DEFAULT_ICON[1]);
            else
                if iconType == -1 then
                    self.m_icon:setUrlImage(user:getIcon());
                elseif iconType == 0 then
                    self.m_icon:setFile(UserInfo.DEFAULT_ICON[1]);
                end
            end
            if user:getUid() == UserInfo.getInstance():getUid() then
                self.m_add_btn:setVisible(false);
                self.m_cancle_btn:setVisible(false);
            else
                if FriendsData.getInstance():isYourFollow(user:getUid()) ~= -1 or FriendsData.getInstance():isYourFriend(user:getUid()) ~= -1 then
                    self.m_add_btn:setVisible(false);
                    self.m_cancle_btn:setVisible(true);
                else
                    self.m_add_btn:setVisible(true);
                    self.m_cancle_btn:setVisible(false);
                end
            end
            self.m_money:setText(user:getMoney() .. "");
            GiftModuleController.getInstance():setUserData(user);
            self.userData = FriendsData.getInstance():getUserData(user:getUid());
            self:onUpdateUserData(self.userData)
        else
            self.m_richText = new(RichText,"#c505050"..userName,200,28,kAlignLeft,nil,36,80,80,80,true);
            self.m_title:setText(user:getTitle());
            self.m_icon:setFile(user:getAIIcon());
            self.m_add_btn:setVisible(false);
            self.m_cancle_btn:setVisible(false);
        end
        self.m_richText:setAlign(self.m_name:getAlign());
        self.m_richText:setPos(self.m_name:getPos());
		self.m_rate:setText(user:getRate() .. "(" .. user:getGrade()..")");

		kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
        self.m_root_dialog:addChild(self.m_richText);
		self.m_root_view:setVisible(true);
        self.m_root_view:setFillParent(true,true);
        self.m_root_view:setEventTouch(self,self.dismiss);

        local text = new(Text,userName..userSource,nil,nil,nil,nil,36);
        local tw,th = text:getSize();
        local nx,ny = self.m_richText:getPos();
        local vw,vh = self.m_vip_logo:getSize();

        self.m_vip_logo:setPos(nx - tw/2,ny -10);
        if user.m_vip and tonumber(user.m_vip) == 1 then
            self.m_vip_frame:setVisible(true);
            self.m_vip_logo:setVisible(true);
        else
            self.m_vip_frame:setVisible(false);
            self.m_vip_logo:setVisible(false);
        end

        if self.m_send_gift_btn then
            if user:getUid() == UserInfo.getInstance():getUid() then
                self.m_send_gift_btn:setVisible(false);
            else
                self.m_send_gift_btn:setVisible(true);
            end
        end
--        self.m_money:setText(user:getMoney() .. "");
--        GiftModuleController.getInstance():setUserData(user);
	else
		print_string("user is nil or user not in the talbe");
	end
end

UserInfoDialog.dismiss = function(self)
	print_string("UserInfoDialog dismiss");
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeCallDone);
	self.m_root_view:setVisible(false);
--    if self.m_send_gift_view then
--        self.m_send_gift_view:setVisible(false);
--    end
    GiftModuleController.releaseInstance()
end

UserInfoDialog.update = function(self,info)
	if info then
        if info.relation >= 2 then
            self.m_add_btn:setVisible(false);
            self.m_cancle_btn:setVisible(true);
        else
            self.m_add_btn:setVisible(true);
            self.m_cancle_btn:setVisible(false);
        end
    end
end

UserInfoDialog.onAddBtnClick = function(self)
    print_string("UserInfoDialog onAddBtnClick");
    if self.m_addObj and self.m_addFunc then
        local data = {};
        data.op = 1;
        data.uid = UserInfo.getInstance():getUid();
        data.target_uid = self.m_user:getUid();
        self.m_addFunc(self.m_addObj,data);
    end
end

UserInfoDialog.onCancleBtnClick = function(self)
    print_string("UserInfoDialog onCancleBtnClick");
    if self.m_addObj and self.m_addFunc then
        local data = {};
        data.op = 0;
        data.uid = UserInfo.getInstance():getUid();
        data.target_uid = self.m_user:getUid();
        self.m_addFunc(self.m_addObj,data);
    end
end

UserInfoDialog.setAddFunc = function(self,obj,func)
    print_string("UserInfoDialog setAddFunc");
    self.m_addFunc = func;
    self.m_addObj = obj;
end

UserInfoDialog.s_shieldTouchClick = function(self)
--    if self.m_send_gift_view and self.m_send_gift_view:getVisible() then
--        self.m_send_gift_view:setVisible(false);
--        return
--    end
	self:dismiss();
end

UserInfoDialog.showReportDialog = function(self)
    if not self.m_report_dialog then
        self.m_report_dialog = new(ReportDialog);
    end;
    self.m_report_dialog:show(self.m_uid);
end;


UserInfoDialog.forbidUpUserMsg = function(self)
    local info = {};
    info.opp_id = self.m_uid;
    if self.m_is_forbid == 0 and info.opp_id and info.opp_id ~= 0 then
        info.forbid_status = 0;
        OnlineSocketManager.getHallInstance():sendMsg(CLIENT_CMD_FORBID_USER_MSG, info);-- 0 屏蔽
    else
        info.forbid_status = 1;
        OnlineSocketManager.getHallInstance():sendMsg(CLIENT_CMD_FORBID_USER_MSG, info);-- 1 取消屏蔽
    end;
end;

UserInfoDialog.setForbidStatus = function(self,data)
    if data.is_success == 0 then
        if data.forbid_status == 0 then
            self.m_is_forbid = 1;
            self.m_forbid_text:setText("取消屏蔽");
            ChessToastManager.getInstance():showSingle("您已屏蔽对手消息 ，再次点击取消屏蔽",3000);
        else
            self.m_is_forbid = 0;
            self.m_forbid_text:setText("屏蔽消息");
            ChessToastManager.getInstance():showSingle("取消屏蔽对手消息",1000);
        end;
    else
        ChessToastManager.getInstance():showSingle("系统繁忙",1000);
    end;
end;

UserInfoDialog.resetForbidStatus = function(self,uid)
    if self.m_uid and self.m_uid ~= 0 then
        if self.m_uid ~= uid then -- 上面玩家换了，需要重置屏蔽状态
            self.m_is_forbid = 0;
            self.m_forbid_text:setText("屏蔽消息");            
        end;
    end;
end;

function UserInfoDialog.getTimes(self)
    local times = self.m_radioButtonGroup:getResult()
    return times
end

function UserInfoDialog.onUpdateUserData(self,data)
    if not data or type(data) ~= "table" then return end

    local user = data

    for k,v in pairs(data) do
        if not v then break end
        if type(v) ~= "table" then
            break
        else
            if self.m_user and v.mid == self.m_user.m_uid then
                user = v
                break
            end
        end
    end
    if self.m_gift_scroll_list then
        self.m_gift_scroll_list:clearItemNum()
        if UserInfo.getInstance():getUid() == tonumber(user.mid) then
            local usrGift = UserInfo.getInstance():getGift()
            self.m_gift_scroll_list:onUpdateItem(usrGift)
        else
            self.m_gift_scroll_list:onUpdateItem(user)
        end
    end

    if data.my_set then
        local frameRes = UserSetInfo.getInstance():getFrameRes(data.my_set.picture_frame);
        self.m_vip_frame:setVisible(frameRes.visible);
        local fw,fh = self.m_vip_frame:getSize();
        if frameRes.frame_res then
            self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
        end
    end
end

function UserInfoDialog.onNativeCallDone(self ,param , ...)
	if self.s_nativeEventFuncMap[param] then
		self.s_nativeEventFuncMap[param](self,...);
	end
end

function UserInfoDialog.setListMode(self,mode)
    self.mode = mode or GiftModuleItem.s_mode_gift
    local roomType = RoomProxy.getInstance():getCurRoomType()
    if not roomType or roomType == 6 then
        self.mode = GiftModuleItem.s_mode_gift
    end

    if self.mode == GiftModuleItem.s_mode_gift then
        self:deleteListView()
        self.m_radioButtonGroup = new(RadioCheckGroup);
        self.m_radioButtonGroup:setSize(500,85);
        self.m_radioButtonGroup:setAlign(kAlignBottom);
        self.m_radioButtonGroup:setPos(0,-10);
        self.m_send_gift_view:addChild(self.m_radioButtonGroup)
        self.m_radioButtonGroup:removeAllChildren(true)

        local nodeTen = new(RadioCheckButton);
        nodeTen:setPos(40,0);
        nodeTen:setAlign(kAlignLeft);
        self.m_radioButtonGroup:addChild(nodeTen)
        local textTen = new(Text,"10连送",nil,nil,nil,nil,30,80,80,80)
        textTen:setPos(66,0)
        textTen:setAlign(kAlignLeft);
        nodeTen:addChild(textTen)

        local nodeHundred = new(RadioCheckButton);
        nodeHundred:setPos(290,0);
        nodeHundred:setAlign(kAlignLeft);
        local textHundred = new(Text,"100连送",nil,nil,nil,nil,30,80,80,80)
        textHundred:setPos(66,0)
        textHundred:setAlign(kAlignLeft);
        nodeHundred:addChild(textHundred)
        self.m_radioButtonGroup:addChild(nodeHundred)

        self.m_gift_scroll_list = new(GiftModuleScrollList,560,175,GiftModuleItem.s_mode_gift,self);
        self.m_gift_scroll_list:setAlign(kAlignLeft)
    else
        self:deleteListView()
        self.m_gift_scroll_list = new(GiftModuleScrollList,560,175,GiftModuleItem.s_mode_other,self);
        self.m_gift_scroll_list:setAlign(kAlignLeft)
        self.m_gift_scroll_list:setPos(0,40)
        local title = self.m_root_dialog:getChildByName("Image21"):getChildByName("text");
        title:setText("我的礼物");
    end
    self.m_gift_scroll_list:initScrollView(GiftModuleScrollList.s_lsize)
    self.m_item_view:addChild(self.m_gift_scroll_list);
end

function UserInfoDialog.deleteListView(self)
    if self.m_radioButtonGroup then
        self.m_radioButtonGroup:removeAllChildren(true);
        delete(self.m_radioButtonGroup)
        self.m_radioButtonGroup = nil
    end
    if self.m_gift_scroll_list then
        self.m_gift_scroll_list:removeAllChildren(true);
        delete(self.m_gift_scroll_list)
        self.m_gift_scroll_list = nil
    end
end

UserInfoDialog.s_nativeEventFuncMap = {
    [kFriend_UpdateUserData]         = UserInfoDialog.onUpdateUserData;
}