-- UserInfoDialog2.lua
-- By LeoLi 
-- Date 2016/4/12

require(VIEW_PATH .. "user_info_dialog");
require(BASE_PATH.."chessDialogScene");
require("dialog/report_dialog");
UserInfoDialog2 = class(ChessDialogScene,false);

UserInfoDialog2.ctor = function(self)
    super(self,user_info_dialog);
    self.m_root_view = self.m_root;
    self:setShieldClick(self, self.dismiss);
    self:init();
    EventDispatcher.getInstance():register(Event.Call,self,self.onEventResponse);
end

UserInfoDialog2.dtor = function(self)
    delete(self.m_root_view);
	self.m_root_view = nil;
    EventDispatcher.getInstance():register(Event.Call,self,self.onEventResponse);
end

UserInfoDialog2.init = function(self)
    self.m_userinfo_dlg = self.m_root_view:getChildByName("user_info_dialog");
    self.m_userinfo_dlg:setEventTouch(self,function() end);

    -- title
    self.m_title_view = self.m_userinfo_dlg:getChildByName("user_info_icon_bg");
        -- name
        self.m_name = self.m_title_view:getChildByName("user_info_name");
        -- uid
        self.m_uid = self.m_title_view:getChildByName("user_info_id");
        -- icon_mask
        self.m_icon_mask = self.m_title_view:getChildByName("user_info_icon_mask");
        self.m_icon = new(Mask,"online/room/head_mask.png","online/room/head_mask.png");
        local maskW,maskH = self.m_icon_mask:getSize();
        self.m_icon:setSize(maskW,maskH);
        self.m_icon_mask:addChild(self.m_icon);

        -- vip_frame
        self.m_vip_frame = self.m_title_view:getChildByName("user_info_vip_frame");
        -- vip_logo
        self.m_vip_logo = self.m_title_view:getChildByName("user_info_vip_logo");


    -- content
    self.m_content_view = self.m_userinfo_dlg:getChildByName("user_content_bg");
        -- sex
        self.m_sex = self.m_content_view:getChildByName("user_info_sex");
        -- rank
        self.m_rank = self.m_content_view:getChildByName("user_info_rank");
        -- title
        self.m_title = self.m_content_view:getChildByName("user_info_title");
        -- rate
        self.m_rate = self.m_content_view:getChildByName("user_info_rate");


    -- btns
    self.m_add_btn = self.m_userinfo_dlg:getChildByName("user_info_add_btn");
    self.m_add_btn:setOnClick(self,self.toAddFriend);
    self.m_add_btn_txt = self.m_add_btn:getChildByName("add_text");
    self.m_report_btn = self.m_userinfo_dlg:getChildByName("user_info_report_btn");
    self.m_report_btn:setOnClick(self, self.showReportDialog);
end;

UserInfoDialog2.onEventResponse = function(self, cmd, status, data)
    if cmd == kFriend_FollowCallBack then
        if status.ret and status.ret == 0 and self.m_mid then
            -- 发起关注/取消关注，server返回会先更新FriendData的isYourFollow
            if FriendsData.getInstance():isYourFollow(self.m_mid) == -1 then
                if FriendsData.getInstance():isYourFriend(self.m_mid) == -1 then
                    if self:isShowing() and self.m_add_btn_txt then
                        ChessToastManager.getInstance():showSingle("已取消关注");
                        self.m_add_btn_txt:setText("加关注");
                    end;
                else
                    if self:isShowing() and self.m_add_btn_txt then
                        ChessToastManager.getInstance():showSingle("关注成功！");
                        self.m_add_btn_txt:setText("已关注");
                    end;                   
                end;
            else
                if self:isShowing() and self.m_add_btn_txt then
                    ChessToastManager.getInstance():showSingle("关注成功！");
                    self.m_add_btn_txt:setText("已关注");
                end;
            end;
        end
    end;
end;

UserInfoDialog2.isShowing = function(self)
	return self:getVisible();
end

UserInfoDialog2.show = function(self,data)
    self:setVisible(true);
    self.m_data = data;
    self:showUserInfo();
end;

UserInfoDialog2.dismiss = function(self)
    self:setVisible(false);
end;

UserInfoDialog2.showUserInfo = function(self)
    -- icon
    self:setIcon();
    -- name
    self:setName();
    -- vip
    self:setVip();
    -- id
    self:setID();
    -- sex
    self:setSex();
    -- rank
    self:setRank();
    -- title
    self:setTitle();
    -- rate
    self:setRate();
    -- follow
    self:setFollow();
end;


UserInfoDialog2.setIcon = function(self)
    if self.m_data.icon_url == "" or not self.m_data.icon_url then
        self.m_icon:setFile(UserInfo.DEFAULT_ICON[1]);
    else
        self.m_icon:setUrlImage(self.m_data.icon_url,UserInfo.DEFAULT_ICON[1]);
    end;
end;

UserInfoDialog2.setName = function(self)
    self.m_name:setText(self.m_data.mnick or "...");
end;

UserInfoDialog2.setVip = function(self)
    if self.m_data.is_vip and self.m_data.is_vip == 1 then
        self.m_vip_logo:setVisible(true);
        self.m_vip_frame:setVisible(true);
    else
        self.m_vip_logo:setVisible(false);
        self.m_vip_frame:setVisible(false);
    end;
end;

UserInfoDialog2.setID = function(self)
    self.m_mid = self.m_data.mid;
    self.m_uid:setText("ID："..(self.m_data.mid or "..."));

end;

UserInfoDialog2.setSex = function(self)
    local sex = (self.m_data.sex == 1 and "男") or (self.m_data.sex == 2 and "女") or "保密";
    self.m_sex:setText(sex);

end;

UserInfoDialog2.setRank = function(self)
    self.m_rank:setText(self.m_data.rank or "...");

end;

UserInfoDialog2.setTitle = function(self)
    local gradingName = UserInfo.getInstance():getDanGradingNameByScore(self.m_data.score or "0");
    local title = gradingName .. "(" ..(self.m_data.score or "0") .. "积分)";
    self.m_title:setText(title);
end;

UserInfoDialog2.setRate = function(self)
    local win = self.m_data.wintimes or 0;
    local lose = self.m_data.losetimes or 0;
    local draw = self.m_data.drawtimes or 0;
	local total = win + lose + draw;
	local rate = total <= 0 and 0 or win*100/total;
    self.m_rate:setText(string.format("%.2f",rate).."% "..("(胜"..win.."/".."败"..lose.."/".."和"..draw..")"));

end;

UserInfoDialog2.setFollow = function(self)
    if FriendsData.getInstance():isYourFollow(self.m_mid) == -1 then
        if FriendsData.getInstance():isYourFriend(self.m_mid) == -1 then
            self.m_add_btn_txt:setText("加关注");
        else
            self.m_add_btn_txt:setText("已关注");
        end;
    else
        self.m_add_btn_txt:setText("已关注");
    end
end;



UserInfoDialog2.toAddFriend = function(self)
    if FriendsData.getInstance():isYourFollow(self.m_mid) == -1 then
        if FriendsData.getInstance():isYourFriend(self.m_mid) == -1 then
            self:follow(self.m_mid);
        else
            self:unFollow(self.m_mid);
        end;
    else
        self:unFollow(self.m_mid);
    end
end;

-- 关注
UserInfoDialog2.follow = function(self,gz_uid)
    local info = {};
    info.uid = UserInfo.getInstance():getUid();
    info.target_uid = gz_uid;
    info.op = 1;
    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_ADD_FLLOW,info);
end;


--取消关注
UserInfoDialog2.unFollow = function(self,gz_uid)
    local info = {};
    info.uid = UserInfo.getInstance():getUid();
    info.target_uid = gz_uid;
    info.op = 0;
    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_ADD_FLLOW,info);
end


UserInfoDialog2.showReportDialog = function(self)
    self:dismiss();
    if not self.m_report_dialog then
        self.m_report_dialog = new(ReportDialog);
    end;
    self.m_report_dialog:show(self.m_mid);
end;