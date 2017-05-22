
require("uiex/richText");
require("dialog/report_dialog");
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
        end
	self.m_root_view:setVisible(false);
    self.m_root_view:setLevel(1);
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
end

UserInfoDialog.isShowing = function(self)
	return self.m_root_view:getVisible();
end

UserInfoDialog.show = function(self,user)
    self.m_user = user;
	if not user then
		print_string("UserInfoDialog.show but not user");
		return
	end

	print_string("UserInfoDialog.show" .. user:getName());

	if self.m_root_view:getVisible() then 
		print_string("aready show");
		return;
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
            if user:getIconType() == -1 then
                self.m_icon:setUrlImage(user:getIcon());
            else
                self.m_icon:setFile(UserInfo.DEFAULT_ICON[user:getIconType()] or UserInfo.DEFAULT_ICON[1]);
            end
            local iconType = tonumber(user:getIconType());
            if iconType and iconType > 0 then
                self.m_icon:setFile(UserInfo.DEFAULT_ICON[iconType] or UserInfo.DEFAULT_ICON[1]);
            else
                if iconType == -1 then
                    self.m_icon:setUrlImage(user:getIcon());
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
        self.m_root_view:setEventTouch(self,self.s_shieldTouchClick);

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
--        local frameRes = UserSetInfo.getInstance():getFrameRes();
--        self.m_vip_frame:setVisible(frameRes.visible);
--        local fw,fh = self.m_vip_frame:getSize();
--        if frameRes.frame_res then
--            self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
--        end

	else
		print_string("user is nil or user not in the talbe");
	end
end

UserInfoDialog.dismiss = function(self)
	print_string("UserInfoDialog dismiss");
	self.m_root_view:setVisible(false);
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
	self:dismiss();
end

UserInfoDialog.showReportDialog = function(self)
    if not self.m_report_dialog then
        self.m_report_dialog = new(ReportDialog);
    end;
    self.m_report_dialog:show(self.m_uid);
end;