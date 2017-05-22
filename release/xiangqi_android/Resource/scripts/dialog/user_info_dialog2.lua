-- UserInfoDialog2.lua
-- By LeoLi 
-- Date 2016/4/12

require(VIEW_PATH .. "user_info_dialog");
require("dialog/friend_chat_dialog");
require(BASE_PATH.."chessDialogScene");
require("dialog/report_dialog");
require(MODEL_PATH .. "giftModule/giftModuleScrollList")

UserInfoDialog2 = class(ChessDialogScene,false);
UserInfoDialog2.s_forbid_id_list = {};
UserInfoDialog2.tip_bg = nil

UserInfoDialog2.SHOW_TYPE = {
    ONLINE_ME       = 1,
    ONLINE_OTHER    = 2,
    WATCH_ROOM      = 3,
    CHAT_ROOM       = 4,
    SOCIATY         = 5,
    UNION           = 6,
    MATCHGAME       = 7,
    WATCH_PLAYER    = 8,
    OTHER           = 9,
}

UserInfoDialog2.ctor = function(self)
    super(self,user_info_dialog);
    self.m_root_view = self.m_root;
    self:setShieldClick(self, self.dismiss);
    self:setNeedMask(false)
    self:setMaskDialog(true)
    self:init();
end

UserInfoDialog2.dtor = function(self)
    delete(self.m_root_view);
	self.m_root_view = nil;
    UserInfoDialog2.s_forbid_id_list = {};
    delete(self.mChioceDialog)
    delete(self.m_friend_chat_dialog)
    delete(self.m_report_dialog)
    delete(self.m_createroom_dialog)
    delete(self.m_chioce_dialog)
end

UserInfoDialog2.setShowType = function(self,showtype)
    if self.showType and showtype and self.showType == showtype then return end
    self.showType = showtype or UserInfoDialog2.SHOW_TYPE.ONLINE_ME
    self:switchViewStatus()
end

UserInfoDialog2.init = function(self)
    self.my_sociaty_data = UserInfo.getInstance():getUserSociatyData()
    self.my_sociaty_role = tonumber(self.my_sociaty_data.guild_role) or 3

    self.m_userinfo_dlg = self.m_root_view:getChildByName("user_info_dialog");
    self.m_userinfo_dlg:setEventTouch(self,function() end);
    self.m_userinfo_dlg_bg = self.m_userinfo_dlg:getChildByName("user_info_dialog_bg");
    -- title
    self.m_title_view = self.m_userinfo_dlg:getChildByName("user_info_icon_bg");
    -- icon_mask
    self.m_icon_mask = self.m_title_view:getChildByName("user_info_icon_mask");
    self.m_icon = new(Mask,"online/room/head_mask.png","online/room/head_mask.png");
    local maskW,maskH = self.m_icon_mask:getSize();
    self.m_icon:setSize(maskW,maskH);
    self.m_icon_mask:addChild(self.m_icon);
    -- vip_frame
    self.m_vip_frame = self.m_title_view:getChildByName("user_info_vip_frame");
    -- name
    self.m_name = self.m_userinfo_dlg:getChildByName("user_info_name");
    -- uid
    self.m_uid = self.m_userinfo_dlg:getChildByName("user_info_id");
    -- vip_logo
    self.m_vip_logo = self.m_userinfo_dlg:getChildByName("user_info_vip_logo");
    -- level
    self.m_grade = self.m_userinfo_dlg:getChildByName("level_icon");
    -- pos
    self.m_pos = self.m_userinfo_dlg:getChildByName("user_pos");
    --score
    self.m_score = self.m_userinfo_dlg:getChildByName("level_view"):getChildByName("user_info_level");
    -- rate
    self.m_rate = self.m_userinfo_dlg:getChildByName("rate_view"):getChildByName("user_info_rate");
    -- money
    self.m_money = self.m_userinfo_dlg:getChildByName("money_view"):getChildByName("user_info_money");
    -- charm
    self.m_charm = self.m_userinfo_dlg:getChildByName("charm_view"):getChildByName("user_info_charm");
    -- sex
    self.m_sex = self.m_userinfo_dlg:getChildByName("sex_icon");
    -- gift
    self.m_menu_bg = self.m_userinfo_dlg:getChildByName("menu_bg");
    self.m_menu_bg:setVisible(false)
    self.m_gift_view = self.m_userinfo_dlg:getChildByName("gift_view");
    self.m_gift_num = self.m_gift_view:getChildByName("gift_num");
    self.m_gift_item = self.m_gift_view:getChildByName("item_view");
    self.m_gift_num_view = self.m_gift_view:getChildByName("num_view");

    -- 关注按钮
    self.m_btn_view = self.m_userinfo_dlg:getChildByName("btn_view");
    self.m_add_btn = self.m_userinfo_dlg:getChildByName("user_info_add_btn");
    self.m_add_btn:setOnClick(self,self.toAddFriend);
    self.m_add_btn_txt = self.m_add_btn:getChildByName("add_text");
    self.m_add_btn_img = self.m_add_btn:getChildByName("Image3");

    -- 举报按钮
    self.mor_btn_view = self.m_userinfo_dlg:getChildByName("more_btn_view");
    self.mor_btn_view:setVisible(false)
    self.is_show_more_view = false 
    self.more_btn = self.m_userinfo_dlg:getChildByName("more_btn");
    self.more_btn:setOnClick(self,function()
        if not self.is_show_more_view then
            self.mor_btn_view:setVisible(true)
        else
            self.mor_btn_view:setVisible(false)
        end
        self.is_show_more_view = not self.is_show_more_view
    end)
    self.add_blacklist_btn = self.mor_btn_view:getChildByName("add_blacklist_btn");
    self.add_blacklist_btn:setOnClick(self, self.addBlackList);
    self.m_report_btn = self.mor_btn_view:getChildByName("user_info_report_btn");
    self.m_report_btn:setOnClick(self, self.showReportDialog);

    --弹窗底部按钮
    self.m_btn_view = self.m_userinfo_dlg:getChildByName("btn_view")
    self.user_chat1 = self.m_btn_view:getChildByName("user_chat")
    self.user_chat1:setOnClick(self,self.onSendMsg)
    self.user_challenge1 = self.m_btn_view:getChildByName("user_challenge")
    self.user_challenge1:setOnClick(self, self.checkUserOnlineState)
    --棋社相关按钮
    self.sociaty_btn_view = self.m_userinfo_dlg:getChildByName("sociaty_btn_view")
    self.user_chat2 = self.sociaty_btn_view:getChildByName("user_chat")
    self.user_chat2:setOnClick(self,self.onSendMsg)
    self.forbid_msg = self.sociaty_btn_view:getChildByName("user_challenge")
    self.forbid_msg:setOnClick(self, self.forbidChat)
    self.user_role = self.sociaty_btn_view:getChildByName("user_role")
    self.user_role:setOnClick(self,function()
        local op = self:getOpType()
        self:managerMember(op)
    end)
    self.kick_out_btn = self.sociaty_btn_view:getChildByName("kick_out_btn")
    self.kick_out_btn:setOnClick(self,function()
        self:managerMember(ChesssociatyModuleConstant.s_manager_active["OP_DEL_MEMBER"])
    end)



--    self.m_fight_btn = self.m_btn_view:getChildByName("user_info_fight_btn");
--    self.m_fight_btn:setOnClick(self, self.checkUserOnlineState);
--    self.m_forbid_btn = self.m_userinfo_dlg:getChildByName("user_info_forbid_btn");
--    self.m_forbid_btn:setOnClick(self, self.forbidUserChatMsg);
--    self.m_forbid_txt = self.m_forbid_btn:getChildByName("forbid_txt")

    --棋社相关
    self.m_sociaty_view = self.m_userinfo_dlg:getChildByName("sociaty_view")
    self.sociaty_name = self.m_sociaty_view:getChildByName("sociaty_name")
    self.sociaty_pos = self.m_sociaty_view:getChildByName("sociaty_pos")
    self.sociaty_icon = self.m_sociaty_view:getChildByName("sociaty_icon")
    self.no_sociaty_tips = self.m_sociaty_view:getChildByName("no_sociaty_tips")

    --签名
    self.m_sign_text = self.m_userinfo_dlg:getChildByName("sign_bg"):getChildByName("text")
    self.switch = {
        [1] = function()
            --房间内自己
            self.m_gift_view:setVisible(false)
            self.m_btn_view:setVisible(false)
            self.sociaty_btn_view:setVisible(false)
            self.m_menu_bg:setVisible(false)
            self.m_add_btn:setVisible(false)
--            self.m_report_btn:setVisible(false)
--            self.m_forbid_btn:setVisible(false)
            self.more_btn:setVisible(false)
            self.m_userinfo_dlg_bg:setSize(664,842)
        end,
        [2] = function()
            --房间内对手
            self.m_gift_view:setVisible(true)
            self.m_btn_view:setVisible(false)
            self.sociaty_btn_view:setVisible(false)
            self.m_menu_bg:setVisible(true)
            self.m_add_btn:setVisible(true)
--            self.m_report_btn:setVisible(true)
--            self.m_forbid_btn:setVisible(true)
            self.more_btn:setVisible(true)
            self.m_userinfo_dlg_bg:setSize(664,842)
            self:initGiftScroll()
        end,
        [3] = function()
            --观战玩家
            self.m_gift_view:setVisible(false)
            self.m_btn_view:setVisible(false)
            self.sociaty_btn_view:setVisible(false)
            self.m_menu_bg:setVisible(false)
            self.m_add_btn:setVisible(true)
--            self.m_report_btn:setVisible(true)
--            self.m_forbid_btn:setVisible(true)
            self.more_btn:setVisible(true)
            self.m_userinfo_dlg_bg:setSize(664,842)
            self:initBtnView()
        end,
        [4] = function()
            --聊天室
            self.m_gift_view:setVisible(false)
            self.m_btn_view:setVisible(true)
            self.sociaty_btn_view:setVisible(false)
            self.m_menu_bg:setVisible(true)
            self.m_add_btn:setVisible(true)
--            self.m_report_btn:setVisible(true)
--            self.m_forbid_btn:setVisible(false)
            self.more_btn:setVisible(true)
            self.m_userinfo_dlg_bg:setSize(664,842)
            self:initBtnView()
        end,
        [5] = function()
            --棋社
            self.m_gift_view:setVisible(false)
            if self.my_sociaty_role == 3 then
                self.m_btn_view:setVisible(true)
                self.sociaty_btn_view:setVisible(false)
            else
                self.m_btn_view:setVisible(false)
                self.sociaty_btn_view:setVisible(true)
            end
            self.m_menu_bg:setVisible(true)
            self.m_add_btn:setVisible(true)
--            self.m_report_btn:setVisible(true)
--            self.m_forbid_btn:setVisible(false)
            self.more_btn:setVisible(true)
            self.m_userinfo_dlg_bg:setSize(664,842)
            self:initBtnView()
        end,
        [6] = function()
            --同城
            self.m_gift_view:setVisible(false)
            self.m_btn_view:setVisible(false)
            self.sociaty_btn_view:setVisible(false)
            self.m_menu_bg:setVisible(false)
            self.m_add_btn:setVisible(true)
--            self.m_report_btn:setVisible(true)
--            self.m_forbid_btn:setVisible(false)
            self.more_btn:setVisible(true)
            self.m_userinfo_dlg_bg:setSize(664,842)
        end,
        [7] = function()
            --pipei 
            self.m_gift_view:setVisible(false)
            self.m_btn_view:setVisible(false)
            self.sociaty_btn_view:setVisible(false)
            self.m_menu_bg:setVisible(false)
            self.m_add_btn:setVisible(false)
--            self.m_report_btn:setVisible(false)
--            self.m_forbid_btn:setVisible(false)
            self.more_btn:setVisible(true)
            self.m_userinfo_dlg_bg:setSize(664,616)
        end,
        [8] = function()
            --对局玩家观战
            self.m_gift_view:setVisible(true)
            self.m_btn_view:setVisible(false)
            self.sociaty_btn_view:setVisible(false)
            self.m_menu_bg:setVisible(true)
            self.m_add_btn:setVisible(true)
--            self.m_report_btn:setVisible(true)
--            self.m_forbid_btn:setVisible(false)
            self.more_btn:setVisible(true)
            self.m_userinfo_dlg_bg:setSize(664,842)
            self:initGiftScroll()
        end,
        [9] = function()
            --其他
            self.m_gift_view:setVisible(false)
            self.m_btn_view:setVisible(false)
            self.sociaty_btn_view:setVisible(false)
            self.m_menu_bg:setVisible(false)
            self.m_add_btn:setVisible(false)
--            self.m_report_btn:setVisible(false)
--            self.m_forbid_btn:setVisible(false)
            self.more_btn:setVisible(true)
            self.m_userinfo_dlg_bg:setSize(664,842)
        end
    }
    

    
end;

UserInfoDialog2.onEventResponse = function(self, cmd, status, data)
    if cmd == kFriend_FollowCallBack then
        if status.ret and status.ret == 0 and self.m_mid then
            -- 发起关注/取消关注，server返回会先更新FriendData的isYourFollow
            if FriendsData.getInstance():isYourFollow(self.m_mid) == -1 then
                if FriendsData.getInstance():isYourFriend(self.m_mid) == -1 then
                    if self:isShowing() and self.m_add_btn_txt then
                        ChessToastManager.getInstance():showSingle("已取消关注");
                        self.m_add_btn_txt:setText("关注");
                        self.m_add_btn_img:setFile("chessfriends/add_follow.png")
                    end;
                else
                    if self:isShowing() and self.m_add_btn_txt then
                        ChessToastManager.getInstance():showSingle("关注成功！");
                        self.m_add_btn_txt:setText("已关注");
                        self.m_add_btn_img:setFile("chessfriends/is_follow.png")
                    end;                   
                end;
            else
                if self:isShowing() and self.m_add_btn_txt then
                    ChessToastManager.getInstance():showSingle("关注成功！");
                    self.m_add_btn_txt:setText("已关注");
                    self.m_add_btn_img:setFile("chessfriends/is_follow.png")
                end;
            end;
        end
    elseif cmd == kStranger_isOnline then
        if status and next(status) then
            if tonumber(status.hallId) ~= 0 and tonumber(status.tid) == 0 and status.version >= "2.7.0" then
                local msgdata = {};
                msgdata.send_uid = UserInfo.getInstance():getUid();
                msgdata.check_uid = self.m_data.mid;
                OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_IS_ACT_AVALIABLE,msgdata);
            elseif tonumber(status.hallId) == 0 then
                ChessToastManager.getInstance():showSingle("对方不在线");
            elseif tonumber(status.tid) ~= 0 then
                ChessToastManager.getInstance():showSingle("对方正在对局中,无法挑战");
            elseif status.version and status.version < "2.7.0" then
                ChessToastManager.getInstance():showSingle("对方版本过低("..status.version..")，还不支持此功能",2500);
            end;
        end
    elseif cmd == kIsAvaliableChessMatch then
        if status and next(status) then
            if status.status == 0 then
                self:showCreatePrivateRoomDialog();
            end;
        end;
    elseif cmd == kFriend_UpdateUserData then
        if not status then return end
        local userData = status[1]
        local id = tonumber(userData.mid)
        if self.id and id and self.id == id then
            self:setUserData(userData)
        end
    end;
end;


--http获取荣誉信息的回调接口
function UserInfoDialog2.onHonorDataCallBack(self, datas)
    if not self.id then return end
    for _,data in ipairs(datas) do
        if tonumber(data.mid) == self.id then
            self:setHonorData(data)
        end
    end
end

UserInfoDialog2.switchViewStatus = function(self)
    local f = self.switch[self.showType]
    if f then
        f()
    end
end

UserInfoDialog2.initBtnView = function(self)
    if self.showType == UserInfoDialog2.SHOW_TYPE.WATCH_ROOM then
--        self.m_fight_btn:setVisible(false)
--        self.m_forbid_btn:setVisible(true)
    elseif self.showType == UserInfoDialog2.SHOW_TYPE.CHAT_ROOM then
--        self.m_fight_btn:setVisible(true)
--        self.m_forbid_btn:setVisible(false)
    elseif self.showType == UserInfoDialog2.SHOW_TYPE.SOCIATY then
--        self.m_fight_btn:setVisible(true)
--        self.m_forbid_btn:setVisible(false)
    end
end

UserInfoDialog2.initGiftScroll = function(self)
--    if self.showType == UserInfoDialog2.SHOW_TYPE.ONLINE_OTHER then
        local scrSize = {w = 560,h = 150}
        local itemSize = {w = 140,h = 140}
        local bgSize = {w = 120,h = 40}

--        if not UserInfoDialog2.tip_bg then
--            UserInfoDialog2.tip_bg = new(Node)
--        end
--        UserInfoDialog2.tip_bg:setSize(200,50);
--        UserInfoDialog2.tip_bg:setLevel(99)
--        UserInfoDialog2.tip_bg:setVisible(false);
--        UserInfoDialog2.tip_bg:setAlign(kAlignTop)
--        self:addChild(UserInfoDialog2.tip_bg);
        if not self.giftScroller then
            self.giftScroller = new(GiftModuleScrollList,scrSize,itemSize,bgSize,GiftModuleItem.s_mode_gift,self.m_gift_num_view)
        end
--        self.giftScroller:setBgTips(UserInfoDialog2.tip_bg)
        self.giftScroller:setAlign(kAlignLeft);
        self.m_gift_item:addChild(self.giftScroller);
--    elseif self.showType == UserInfoDialog2.SHOW_TYPE.CHAT_ROOM then

--    elseif self.showType == UserInfoDialog2.SHOW_TYPE.SOCIATY then

--    end
end

--UserInfoDialog2.isShowing = function(self)
--	return self:getVisible();
--end

UserInfoDialog2.show = function(self,data,uid)
    self.super.show(self)
    EventDispatcher.getInstance():register(Event.Call,self,self.onEventResponse);
    EventDispatcher:getInstance():register(FriendsData.event.HONOR, self, self.onHonorDataCallBack )  
    self.mor_btn_view:setVisible(false)
    self.is_show_more_view = false 
    self:setVisible(true);
    FriendsData.getInstance():sendCheckUserData(uid)
    FriendsData.getInstance():sendCheckUserHonorData(uid)
    self:setUserData(data)
    self.id = uid
end;

UserInfoDialog2.dismiss = function(self)
    self.super.dismiss(self)
--    self:unregisterCall()
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onEventResponse);
    EventDispatcher:getInstance():unregister(FriendsData.event.HONOR, self, self.onHonorDataCallBack )  
    self:setVisible(false);
--    self:resetFightBtn()

end;

--function UserInfoDialog2.resetFightBtn(self)
--    self.m_fight_btn:getChildByName("report_txt"):setText("挑战")
--    self.m_fight_btn:setOnClick(self,self.checkUserOnlineState)
--end

UserInfoDialog2.showUserInfo = function(self)
    if not self.m_data then return end
    -- icon
    self:setIcon();
    -- name
    self:setName();
    -- vip
    self:setVip();
    -- id
    self:setID();
    -- rank
    self:setCharm();
    -- level
    self:setLevel();
    -- rate
    self:setRate();
    -- follow
    self:setFollow();
    -- forbid
    self:setForbid();
    -- gift
    if self.giftScroller then
        local data = GiftLog.getInstance():getUserGiftNum(self.m_data.mid)
        self:setGift(data);
    end
--    self:setGift();
    -- money
    self:setMoney();
    -- guild
    self:setSociatyData()
    -- sign
    self:setSignInfo()
    -- geo
    self:setAreaPos()
    -- sex
    self:setSex();
end;

UserInfoDialog2.setIcon = function(self)
    if self.m_data.iconType and self.m_data.iconType > 0 then
        self.m_icon:setFile(UserInfo.DEFAULT_ICON[self.m_data.iconType] or UserInfo.DEFAULT_ICON[1]);
    elseif self.m_data.iconType and self.m_data.iconType == 0 then
        self.m_icon:setFile(UserInfo.DEFAULT_ICON[1]);
    else
        if self.m_data.iconType == -1 and self.m_data.icon_url then --兼容1.7.5之前的版本的头像为""时显示默认头像。
            self.m_icon:setUrlImage(self.m_data.icon_url,UserInfo.DEFAULT_ICON[1]);
        end
    end

    local my_set = self.m_data.my_set
    if my_set then
        local frameRes = UserSetInfo.getInstance():getFrameRes(my_set.picture_frame);
        self.m_vip_frame:setVisible(frameRes.visible);
        local fw,fh = self.m_vip_frame:getSize();
        if frameRes.frame_res then
            self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
        end
    end
end;

UserInfoDialog2.setName = function(self)
    if self.m_data.mnick then
        if self.m_data.mnick == "" or self.m_data.mnick == "" then
            self.m_name:setText("博雅象棋");
        else
            self.m_name:setText(self.m_data.mnick);
        end;
    else
        self.m_name:setText("博雅象棋");
    end;
end;

UserInfoDialog2.setVip = function(self)
    if self.m_data.is_vip and self.m_data.is_vip == 1 then
        self.m_vip_logo:setVisible(true);
        local w,h = self.m_name:getSize()
        local x = 50 + w /2
        self.m_vip_logo:setPos(-x,356)
    else
        self.m_vip_logo:setVisible(false);
    end;
end;

UserInfoDialog2.setID = function(self)
    self.m_mid = self.m_data.mid;
    self.m_uid:setText("(ID："..(self.m_data.mid or "...") .. ")");
end;

UserInfoDialog2.setSex = function(self)
    if self.m_sex then
        local w,h = self.m_pos:getSize()
        local x = 40 + w/2
        self.m_sex:setPos(-x)
        if self.m_data.sex == 0 then
            self.m_sex:setFile("common/icon/private.png")
        elseif self.m_data.sex == 1 then
            self.m_sex:setFile("common/icon/man.png")
        elseif self.m_data.sex == 2 then
            self.m_sex:setFile("common/icon/woman.png")
        end
    end
end;

UserInfoDialog2.setMoney = function(self)
    if self.m_money then
        local money = ToolKit.getMoneyStr(self.m_data.money) or 0;
        self.m_money:setText(money);
    end 
end

UserInfoDialog2.setCharm = function(self)
    if self.m_honorData then
        self.m_charm:setText(self.m_honorData.charm_value or "0");
    end
end

UserInfoDialog2.setLevel = function(self)
    self.m_score:setText(tonumber(self.m_data.score or 0))
    self.m_grade:setFile("common/icon/big_level_" .. 10 - UserInfo.getInstance():getDanGradingLevelByScore(self.m_data.score) .. ".png")
end

UserInfoDialog2.setRate = function(self)
    local win = self.m_data.wintimes or 0;
    local lose = self.m_data.losetimes or 0;
    local draw = self.m_data.drawtimes or 0;
	local total = win + lose + draw;
	local rate = total <= 0 and 0 or win*100/total;
    local str = string.format("%.2f",rate) .. "%(" .. string.format("%d",total) .. "局)"
    self.m_rate:setText(str);
end;

UserInfoDialog2.setSociatyData = function(self)
    if not self.m_data then 
        self.no_sociaty_tips:setVisible(true)
        self.sociaty_icon:setVisible(false)
        self.sociaty_name:setText("");
        self.sociaty_pos:setText("");
        return 
    end
    self.no_sociaty_tips:setVisible(false)
    self.sociaty_icon:setVisible(true)
    local guild = self.m_data.guild or {}
    if not guild or type(guild) ~= "table" or next(guild) == nil then
        self.no_sociaty_tips:setVisible(true)
        self.sociaty_icon:setVisible(false)
        self.sociaty_name:setText("");
        self.sociaty_pos:setText("");
        return  
    end
    local name = guild.guild_name or ""
    self.sociaty_name:setText(name);
    --社团职位
    local role = tonumber(guild.guild_role) or 0
    self.sociaty_pos:setText(ChesssociatyModuleConstant.role[role] or "");
    --社团图标
    local guild_icon = tonumber(guild.mark)
    if guild_icon then
        self.sociaty_icon:setFile(ChesssociatyModuleConstant.sociaty_icon[guild_icon] or "sociaty_about/r_scholar.png")
    end
end

UserInfoDialog2.setSignInfo = function(self)
    local str = self.m_data.signature
    if not str or str == "" then
        str = "这个家伙很懒，什么都没有留下"
    end
    self.m_sign_text:setText(str)
end

UserInfoDialog2.setAreaPos = function(self)
    local str = self.m_data.geo or "地区位置"
    self.m_pos:setText(str)
end

UserInfoDialog2.setFollow = function(self)
    if FriendsData.getInstance():isYourFollow(self.m_mid) == -1 then
        if FriendsData.getInstance():isYourFriend(self.m_mid) == -1 then
            self.m_add_btn_txt:setText("关注");
            self.m_add_btn_img:setFile("chessfriends/add_follow.png")
        else
            self.m_add_btn_txt:setText("已关注");
            self.m_add_btn_img:setFile("chessfriends/is_follow.png")
        end;
    else
        self.m_add_btn_txt:setText("已关注");
        self.m_add_btn_img:setFile("chessfriends/is_follow.png")
    end
end;

UserInfoDialog2.setForbid = function(self)
--    if self.m_mid and type(self.m_mid) == "number" then
--        if UserInfoDialog2.s_forbid_id_list[self.m_mid] then
--            self.m_forbid_txt:setText("取消屏蔽");
--        else
--            self.m_forbid_txt:setText("屏蔽消息");
--        end;
--    end;
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
    if not gz_uid then return end
    local info = {};
    info.uid = UserInfo.getInstance():getUid();
    info.target_uid = gz_uid;
    info.op = 1;
    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_ADD_FLLOW,info);
end;

--取消关注
UserInfoDialog2.unFollow = function(self,gz_uid)
    if not gz_uid then return end
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
    self.m_report_dialog:show(self.m_mid,self.reportInfo);
    local data = FriendsData.getInstance():getUserData(self.m_mid)
    self.m_report_dialog:setUserData(data)
end;

UserInfoDialog2.checkUserOnlineState = function(self)
    local data = {};
    data[1] = UserInfo.getInstance():getUid();
    data[2] = self.m_mid or 0;
    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_GET_USER_STATUS,data);
end;

require(DIALOG_PATH.."create_room_dialog");
UserInfoDialog2.showCreatePrivateRoomDialog = function(self)
    self:dismiss();
    local money = UserInfo.getInstance():getMoney();
    local config = RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_PRIVATE_ROOM)
    local minmoney = config.minmoney or 500
 	if  money < minmoney then
 		self:show_tips_action( string.format("您携带的金币不足%d，无法创建房间，请移步新手场或其他版块游戏。",minmoney));
 		return;
 	end

--    delete(self.m_createroom_dialog);
--    self.m_createroom_dialog = nil;
    if not self.m_createroom_dialog then
        self.m_createroom_dialog = new(CreateRoomDialog,50,260,370,286,self);
    end;
    self.m_createroom_dialog:show();    
end;

require(DIALOG_PATH.."chioce_dialog");
UserInfoDialog2.show_tips_action  = function(self,msg)
	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end
   	self.m_chioce_dialog:setMode(ChioceDialog.MODE_OK,"知道了");
	self.m_chioce_dialog:setMessage(msg);
	self.m_chioce_dialog:setPositiveListener(nil,nil);
	self.m_chioce_dialog:show();
end

UserInfoDialog2.customCreateRoom = function(self, data)
    self:schedule_once(function() 
        --{round_time=600 target_uid=10000043 sec_time=0 step_time=30 uid=10000092 name="6666的房间" level=300 password="smart" basechip=800 }
        data.target_uid = self.m_mid;
        -- 挑战邀请加默认密码，防止等待过程其他玩家进入
        math.randomseed(os.time());
        if data.password and data.password == "" then data.password = "boyaa_chess" end;
        UserInfo.getInstance():setCustomRoomData(data);
        if self.showType == UserInfoDialog2.SHOW_TYPE.SOCIATY then
            UserInfo.getInstance():setCustomRoomType(3)
        else
            UserInfo.getInstance():setCustomRoomType(1)
        end
        OnlineSocketManager.getHallInstance():sendMsg(CLIENT_HALL_CREATE_PRIVATEROOM,data);
    end,200)
end;

-- 定时器一次
UserInfoDialog2.schedule_once = function(self,func,time,a,b,c)
    local anim = new(AnimInt, kAnimNormal, 0,1,time,0);
    if anim then
        anim:setEvent(self, function() 
            func(self,a,b,c);
            delete(anim);
            anim = nil;
        end);
    end;    
end;

UserInfoDialog2.forbidUserChatMsg = function(self)
    if self.m_mid and type(self.m_mid) == "number" then
        local info = {};
        info.opp_id = self.m_mid;
        if not UserInfoDialog2.s_forbid_id_list[self.m_mid] then
--            self.m_forbid_txt:setText("取消屏蔽");
            ChessToastManager.getInstance():showSingle("您屏蔽了"..self.m_name:getText().."的消息,再次点击取消",3000);
            UserInfoDialog2.s_forbid_id_list[self.m_mid] = self.m_mid;
            info.forbid_status = 0;
            if self.showType == UserInfoDialog2.SHOW_TYPE.ONLINE_ME or 
                self.showType == UserInfoDialog2.SHOW_TYPE.ONLINE_OTHER then
                OnlineSocketManager.getHallInstance():sendMsg(CLIENT_CMD_FORBID_USER_MSG, info);-- 0 屏蔽
            end
        else
--            self.m_forbid_txt:setText("屏蔽消息");
            ChessToastManager.getInstance():showSingle("取消屏蔽"..self.m_name:getText().."的消息",3000);
            UserInfoDialog2.s_forbid_id_list[self.m_mid] = nil;
            info.forbid_status = 1;
            if self.showType == UserInfoDialog2.SHOW_TYPE.ONLINE_ME or 
                self.showType == UserInfoDialog2.SHOW_TYPE.ONLINE_OTHER then
                OnlineSocketManager.getHallInstance():sendMsg(CLIENT_CMD_FORBID_USER_MSG, info);-- 1 取消屏蔽
            end
        end;
    end;
--     local info = {};
--    info.opp_id = self.m_uid;
--    if self.m_is_forbid == 0 and info.opp_id and info.opp_id ~= 0 then
--        info.forbid_status = 0;
--        OnlineSocketManager.getHallInstance():sendMsg(CLIENT_CMD_FORBID_USER_MSG, info);-- 0 屏蔽
--    else
--        info.forbid_status = 1;
--        OnlineSocketManager.getHallInstance():sendMsg(CLIENT_CMD_FORBID_USER_MSG, info);-- 1 取消屏蔽
--    end;
    self:dismiss();
end;

function UserInfoDialog2:setUserData(data)
    if not data then return end

    if self.m_report_dialog then
        self.m_report_dialog:setUserData(data)
    end

    if self.showType == UserInfoDialog2.SHOW_TYPE.ONLINE_OTHER or self.showType == UserInfoDialog2.SHOW_TYPE.WATCH_PLAYER then
        GiftModuleController.getInstance():setUserData(data);
    end
    self.m_data = data;

    if self.showType == UserInfoDialog2.SHOW_TYPE.SOCIATY then 
        self.user_guild_role = tonumber(self.m_data.guild.guild_role) or 3
        if self.user_guild_role == 2 and self.my_sociaty_role == 1 then
            self.user_role:setFile("chessfriends/demotion.png")
            self.user_role:getChildByName("text"):setText("降职")
            self.user_role:setPickable(true)
            self.user_role:setGray(false)
        elseif  self.user_guild_role == 3 and self.my_sociaty_role == 1 then
            self.user_role:setFile("chessfriends/promotion.png")
            self.user_role:getChildByName("text"):setText("升职")
            self.user_role:setPickable(true)
            self.user_role:setGray(false)
        else
            self.user_role:setFile("chessfriends/promotion.png")
            self.user_role:getChildByName("text"):setText("升职")
            self.user_role:setPickable(false)
            self.user_role:setGray(true)
        end

        if self.my_sociaty_role == ChesssociatyModuleConstant.ROLE_MEMBER then
            self.m_btn_view:setVisible(true)
            self.sociaty_btn_view:setVisible(false)
        elseif self.my_sociaty_role == ChesssociatyModuleConstant.ROLE_VP and (self.user_guild_role == ChesssociatyModuleConstant.ROLE_GM or self.user_guild_role == ChesssociatyModuleConstant.ROLE_VP) then
            self.m_btn_view:setVisible(true)
            self.sociaty_btn_view:setVisible(false)
        else
            self.m_btn_view:setVisible(false)
            self.sociaty_btn_view:setVisible(true)
            if self.m_data then
                self:checkSociatyStatus(tonumber(self.m_data.mid),tonumber(self.my_sociaty_data.guild_id) or 0)
            end
        end
    end


    self:showUserInfo();
    return true;
end

function UserInfoDialog2:setHonorData(data)
    self.m_honorData = data;
    self:showUserInfo();
end

function UserInfoDialog2:checkSociatyStatus(mid,guild_id)
    local params = {}
    params.target_mid = tonumber(mid)
    params.guild_id = tonumber(guild_id) or 0 
    HttpModule.getInstance():execute2(HttpModule.s_cmds.GuildCheckGuildExpose,params,function(isSuccess,resultStr)
        if not isSuccess then 
            return 
        end
        if self.forbid_msg then
            local params = json.decode(resultStr)
            if params.data and params.data.expose_status == 1 then
                self.forbid_msg:getChildByName("text"):setText("取消禁言")
                self.forbid_msg:setOnClick(self, self.unforbidChat)
            else
                self.forbid_msg:getChildByName("text"):setText("禁言")
                self.forbid_msg:setOnClick(self, self.forbidChat)
            end
        end
    end)
end

--[Comment]
--更新弹窗礼物
function UserInfoDialog2.setGift(self,data)
    if not data then return end
    self.m_gift_num:setText(data)
--    if self.giftScroller then
--        self.giftScroller:clearItemNum()
--        self.giftScroller:onUpdateItem(data)
--    end
end

function UserInfoDialog2.resetForbidStatus(self,uid)
    if not self.data then 
        self.m_is_forbid = 0;
--        self.m_forbid_txt:setText("屏蔽消息"); 
        return
    end
    local id = tonumber(self.m_data.mid)
    if id and id ~= 0 then
        if id ~= uid then -- 上面玩家换了，需要重置屏蔽状态
            self.m_is_forbid = 0;
--            self.m_forbid_txt:setText("屏蔽消息");            
        end;
    end;
end;

function UserInfoDialog2.setForbidStatus(self,data)
    if data.is_success == 0 then
        if data.forbid_status == 0 then
            self.m_is_forbid = 1;
--            self.m_forbid_txt:setText("取消屏蔽");
            ChessToastManager.getInstance():showSingle("您已屏蔽对手消息 ，再次点击取消屏蔽",3000);
        else
            self.m_is_forbid = 0;
--            self.m_forbid_txt:setText("屏蔽消息");
            ChessToastManager.getInstance():showSingle("取消屏蔽对手消息",1000);
        end;
    else
        ChessToastManager.getInstance():showSingle("系统繁忙",1000);
    end;
end;

function UserInfoDialog2.setBgPos(self,x,y)
    if not x or not y then return end
    self.m_userinfo_dlg:setPos(x,y)
end

function UserInfoDialog2.setReportInfo(self,reportData)
    self.reportInfo = reportData
end

--聊天，留言
function UserInfoDialog2.onSendMsg(self) 
    local status = FriendsData.getInstance():getUserStatus(self.m_mid);
    local datas = FriendsData.getInstance():getUserData(self.m_mid);
    if UserInfo.getInstance():getUid() == self.m_mid then
        --ChessToastManager.getInstance():show("不能和自己聊天！",500);
    else
        if datas~= nil then
            delete(self.m_friend_chat_dialog)
            self.m_friend_chat_dialog = new(FriendChatDialog,datas);
            self.m_friend_chat_dialog:show();
        end
    end
end

--管理棋社
function UserInfoDialog2.managerMember(self,op)
    if self.my_sociaty_role >= self.user_guild_role or not op then 
        return
    end
    if op == ChesssociatyModuleConstant.s_manager_active["OP_DEL_MEMBER"] then
        local temp = {}
        temp.guild_id = tonumber(self.my_sociaty_data.guild_id) or 0
        temp.target_mid = self.m_mid
        temp.op = ChesssociatyModuleConstant.s_manager_active["OP_DEL_MEMBER"];
        ChessSociatyModuleController.getInstance():onManagerSociaty(temp)
        SociatyModuleData.getInstance():updataMemberData(-1)
        SociatyModuleData.getInstance():deleteSociatyMember(self.m_mid)
        self:dismiss()
    elseif op == ChesssociatyModuleConstant.s_manager_active["OP_DEL_VP"] then
        local temp = {}
        temp.guild_id = tonumber(self.my_sociaty_data.guild_id) or 0
        temp.target_mid = self.m_mid
        temp.op = ChesssociatyModuleConstant.s_manager_active["OP_DEL_VP"];
        ChessSociatyModuleController.getInstance():onManagerSociaty(temp)
    elseif op == ChesssociatyModuleConstant.s_manager_active["OP_ADD_VP"] then
        local temp = {}
        temp.guild_id = tonumber(self.my_sociaty_data.guild_id) or 0
        temp.target_mid = self.m_mid
        temp.op = ChesssociatyModuleConstant.s_manager_active["OP_ADD_VP"];
        ChessSociatyModuleController.getInstance():onManagerSociaty(temp)
    end
end

--获得棋社操作类型
function UserInfoDialog2.getOpType(self)
    local op = nil
    if self.user_guild_role == 2 and self.my_sociaty_role == 1 then
        op = ChesssociatyModuleConstant.s_manager_active["OP_DEL_VP"]
    elseif  self.user_guild_role == 3 and self.my_sociaty_role == 1 then
        op = ChesssociatyModuleConstant.s_manager_active["OP_ADD_VP"]
    end
    return op
end

--棋社禁言
function UserInfoDialog2.forbidChat(self)
    if not tonumber(self.my_sociaty_role) or not tonumber(self.user_guild_role) then return end
    if tonumber(self.my_sociaty_role) >= tonumber(self.user_guild_role) then 
        ChessToastManager.getInstance():showSingle("权限不足！")
        return
    end
    local temp = {}
    temp.mid = UserInfo.getInstance():getUid()
    temp.guild_id = tonumber(self.my_sociaty_data.guild_id) or 0
    temp.target_mid = self.m_mid
    ChessSociatyModuleController.getInstance():onForbidUserChat(temp,function()
        if self.forbid_msg then
            self.forbid_msg:getChildByName("text"):setText("取消禁言")
            self.forbid_msg:setOnClick(self, self.unforbidChat)
        end
    end)
end

--棋社解除禁言
function UserInfoDialog2.unforbidChat(self)
    if not tonumber(self.my_sociaty_role) or not tonumber(self.user_guild_role) then return end
    if tonumber(self.my_sociaty_role) >= tonumber(self.user_guild_role) then 
        ChessToastManager.getInstance():showSingle("权限不足！")
        return
    end
    local temp = {}
    temp.mid = UserInfo.getInstance():getUid()
    temp.guild_id = tonumber(self.my_sociaty_data.guild_id) or 0
    temp.target_mid = self.m_mid
    ChessSociatyModuleController.getInstance():onUnforbidUserChat(temp,function()
        if self.forbid_msg then
            self.forbid_msg:getChildByName("text"):setText("禁言")
            self.forbid_msg:setOnClick(self, self.forbidChat)
        end
    end)
end

--加入黑名单
function UserInfoDialog2.addBlackList(self)
    local func =  function()
        local tab = {}
        local param = {}
        param.target_mid = self.m_mid
        tab.param = param
        HttpModule.getInstance():execute(HttpModule.s_cmds.addBlackList,tab)
        self.is_show_more_view = false 
        self.mor_btn_view:setVisible(false)
    end
    if not self.mChioceDialog then
        self.mChioceDialog = new(ChioceDialog)
        self.mChioceDialog:setMode(ChioceDialog.MODE_SURE)
        self.mChioceDialog:setMessage("是否确定把对方拉黑？可在好友黑名单管理中取消拉黑")
    end
    self.mChioceDialog:setPositiveListener(self,func);
    self.mChioceDialog:setNegativeListener()
    self.mChioceDialog:show()
end