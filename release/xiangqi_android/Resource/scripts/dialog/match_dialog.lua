require("core/anim")
require("core/prop")
require("dialog/chioce_dialog");
--require("view/Android_800_480/match_dialog_view");
require(VIEW_PATH .. "match_dialog_view");
require(BASE_PATH.."chessDialogScene")
MatchDialog = class(ChessDialogScene,false);

MatchDialog.match_time = 10;

MatchDialog.ctor = function(self) 
    super(self,match_dialog_view);
	self.m_root_view = self.m_root;

    self.m_anim_view = {};
    for i=1,3 do
        self.m_anim_view[i] = self.m_root_view:getChildByName("anim_view"):getChildByName("anim_"..i);
    end
    self.m_anim_img_view = self.m_root_view:getChildByName("anim_view");

    self.m_bg_blank = self.m_root_view:getChildByName("bg_blank");
    self.m_bg_blank:setTransparency(0.4);

    self.m_head_bg = self.m_root_view:getChildByName("head_bg");
    self.m_head_btn = self.m_head_bg:getChildByName("head_btn");
    self.m_head_btn:setOnClick(self,self.showOppUserInfo);
    self.m_head_mask = self.m_root_view:getChildByName("head_bg"):getChildByName("head_mask");
    self.m_head_level = self.m_root_view:getChildByName("head_bg"):getChildByName("level");
    self.m_head_level:setVisible(false);

    self.m_icon = new(Mask,UserInfo.DEFAULT_ICON[1],"online/room/dialog/head_mask_bg_144.png");
    self.m_icon:setSize(self.m_head_mask:getSize());
    self.m_icon:setAlign(kAlignCenter);
    self.m_head_mask:addChild(self.m_icon);

    self.m_match_fail_img = self.m_root_view:getChildByName("search_fail");
    self.m_match_suc_img = self.m_root_view:getChildByName("search_success");
    self.m_match_img = self.m_root_view:getChildByName("search_img");

	self.m_change_quit_btn = self.m_root_view:getChildByName("btn1");
	self.m_ready_restart_btn = self.m_root_view:getChildByName("btn2");
	self.m_change_quit_btn:setOnClick(self,self.btn1Click);
	self.m_ready_restart_btn:setOnClick(self,self.btn2Click);

    self.m_tip = self.m_root_view:getChildByName("tip_bg");
    self.m_tip:setVisible(false);
    
    self.m_opp_userInfo_view2 = self.m_root_view:getChildByName("info_view_2");
    self.m_opp_user_name2 = self.m_opp_userInfo_view2:getChildByName("opp_user_name");
    self.m_opp_user_money2 = self.m_opp_userInfo_view2:getChildByName("money_view"):getChildByName("opp_user_money");
    self.m_opp_user_rate2 = self.m_opp_userInfo_view2:getChildByName("winrate_view"):getChildByName("opp_user_rate");

    self.m_opp_userInfo_view = self.m_root_view:getChildByName("info_view");
    self.m_opp_userInfo_view:setVisible(false);
    self.m_opp_head_mask = self.m_opp_userInfo_view:getChildByName("opp_user_icon_bg"):getChildByName("opp_user_icon_mask");
    self.m_opp_icon = new(Mask,UserInfo.DEFAULT_ICON[1],"common/background/head_mask_bg_150.png");
    self.m_opp_icon:setSize(self.m_opp_head_mask:getSize());
    self.m_opp_icon:setAlign(kAlignCenter);
    self.m_opp_head_mask:addChild(self.m_opp_icon);

    self.m_vip_frame = self.m_opp_userInfo_view:getChildByName("opp_user_icon_bg"):getChildByName("icon_frame");
    self.m_opp_user_level = self.m_opp_userInfo_view:getChildByName("opp_user_icon_bg"):getChildByName("level");
    self.vip_logo = self.m_opp_userInfo_view:getChildByName("vip_logo")
    self.opp_user_geo = self.m_opp_userInfo_view:getChildByName("geo")
    self.m_opp_user_name = self.m_opp_userInfo_view:getChildByName("opp_user_name");
    self.m_opp_user_sex = self.m_opp_userInfo_view:getChildByName("opp_user_sex");
--    self.m_opp_user_rank = self.m_opp_userInfo_view:getChildByName("opp_user_rank");
    self.m_opp_user_title = self.m_opp_userInfo_view:getChildByName("score_view"):getChildByName("opp_user_title");
    self.m_opp_user_rate = self.m_opp_userInfo_view:getChildByName("winrate_view"):getChildByName("opp_user_rate");
    self.m_opp_user_id = self.m_opp_userInfo_view:getChildByName("opp_user_id");
    self.m_opp_user_money = self.m_opp_userInfo_view:getChildByName("money_view"):getChildByName("opp_user_money");
    self.m_opp_user_charm = self.m_opp_userInfo_view:getChildByName("charm_view"):getChildByName("opp_user_charm");
    self.m_sociaty_icon = self.m_opp_userInfo_view:getChildByName("sociaty_view"):getChildByName("sociaty_icon");
    self.m_sociaty_name = self.m_opp_userInfo_view:getChildByName("sociaty_view"):getChildByName("sociaty_name");
    self.m_sociaty_pos = self.m_opp_userInfo_view:getChildByName("sociaty_view"):getChildByName("sociaty_pos");
    self.no_sociaty_tips = self.m_opp_userInfo_view:getChildByName("sociaty_view"):getChildByName("no_sociaty_tips");

    self.sign_text = self.m_opp_userInfo_view:getChildByName("Image4"):getChildByName("textview");
    self.back_btn = self.m_root:getChildByName("back_btn")
    self.back_btn:setVisible(false)
    self.back_btn:setOnClick(self,self.back_action)
--    self.m_follow_btn = self.m_opp_userInfo_view:getChildByName("follow_btn");
--    self.m_follow_btn:setOnClick(self,self.onMatchFollow);
--    self.m_btn_text = self.m_follow_btn:getChildByName("text");
    -- 匹配状态 -1匹配失败 0正在匹配 1匹配成功
    self.matchStatus = 0;
    self:setShieldClick(self,self.dismissOppInfo);
    self.m_opp_userInfo_view:setEventTouch(self,function() end);
--    self.add_op = 1;

    self:setNeedBackEvent(false);
	self:setVisible(false);
end

MatchDialog.dtor = function(self)
	self.m_root_view = nil;
    self:stopChangePlayerCountDown()
    delete(self.timer);
    delete(self.animMatchSuc);
    delete(self.m_time_out_anim);
end

MatchDialog.onTouch = function(self)
	print_string("MatchDialog.onTouch");
end

MatchDialog.show = function(self,room,animTime)
	self.m_room = room;
    EventDispatcher.getInstance():register(Event.Call,self,self.onEventResponse);
	if not animTime then
		self.animTime = MatchDialog.match_time;
	else
        self.animTime = animTime;
    end

    self:changeImgStatus(1);
    self:changeBtnStatus(1);
    self.m_tip:setVisible(false);
    self.m_opp_userInfo_view:setVisible(false);
    self.m_head_level:setVisible(false);
    self.m_anim_img_view:setVisible(true);
    self:stopReadyAnim();
    self:startMatchAnim(self.animTime);

	self:setVisible(true);
    self.super.show(self,false);
end

MatchDialog.cancel = function(self)
	print_string("MatchDialog.cancel ");
    self.m_room.mModule:cancelMatch();
	self.m_room.m_down_user_ready_img:setVisible(self.m_room.m_downUser:getReadyVisible());
	self.m_room.m_downUser:setStatus(STATUS_PLAYER_LOGIN);
	self:dismiss();
end

MatchDialog.matchFail = function(self)
	if self:isShowing() then
        self.matchStatus = -1;
        self.m_room.mModule:cancelMatch();
	    self.m_room.m_down_user_ready_img:setVisible(self.m_room.m_downUser:getReadyVisible());
	    self.m_room.m_downUser:setStatus(STATUS_PLAYER_LOGIN);

        -- -1 匹配失败 0 匹配成功
        self:changeImgStatus(-1);
        self:changeBtnStatus(-1);
        self:stopMatchAnim();
        self:stopHeadIconAnim();
--		self:cancel();

--		local message = "匹配棋局失败，稍候再试！";
-- 		if not self.m_chioce_dialog then
-- 			self.m_chioce_dialog = new(ChioceDialog);
-- 		end
--		self.m_chioce_dialog:setMode(ChioceDialog.MODE_OK);
--		self.m_chioce_dialog:setMessage(message);
--		self.m_chioce_dialog:setPositiveListener();
--		self.m_chioce_dialog:show();
	end
end

MatchDialog.onMatchSuc = function(self,data)
    if not data or not data.user then return end
    
    if self:isShowing() then
        self.m_uid = data.user.m_uid or 0
        local user = FriendsData.getInstance():getUserData(self.m_uid)
        FriendsData.getInstance():sendCheckUserData(self.m_uid)
        --设置为用户头像和等级
        self:stopHeadIconAnim();
        if not data.user.m_score or data.user.m_score == "" then
            self.m_head_level:setFile("common/icon/level_9.png");
        else
            self.m_head_level:setFile(string.format("common/icon/big_level_%d.png",10 - UserInfo.getInstance():getDanGradingLevelByScore(data.user.m_score)));
        end

        if not data.user.m_icon or data.user.m_icon == "" then
            if not data.user.m_iconType then
                self:updataAnim();
            else
--                self:updataAnim(UserInfo.DEFAULT_ICON[data.user.m_iconType]);
                self:updataAnim(data.user.m_iconType);

            end
        else
            self:updataAnim(data.user.m_icon);
        end

        self:setOppUserInfo(user); --设置用户信息
        
        delete(self.animMatchSuc);
        self.animMatchSuc = new(AnimInt,kAnimNormal,0,1,800,-1);
        self.m_head_level:addPropTransparency(1,kAnimNormal,200,600,0,1);
        self.animMatchSuc:setEvent(self,function()
            self.m_head_level:setVisible(true);
            self.matchStatus = 1;
            self:resetOppInfoView(true); -- 设置重新匹配后状态
            self:changeImgStatus(0);
            self:changeBtnStatus(0);
            self:stopMatchAnim();
            self:stopHeadIconAnim();
            self.m_head_level:removeProp(1);
            delete(self.animMatchSuc);
            self.animMatchSuc = nil;
            local roomType = RoomProxy.getInstance():getCurRoomType()
            if roomType == RoomConfig.ROOM_TYPE_ARENA_ROOM or
                roomType == RoomConfig.ROOM_TYPE_NOVICE_ROOM or 
                roomType == RoomConfig.ROOM_TYPE_INTERMEDIATE_ROOM or 
                roomType == RoomConfig.ROOM_TYPE_MASTER_ROOM then
                self:changeBtnStatus(2);
                self:btn2Click()
            else
                self:startChangePlayerCountdown()
            end
        end);
    end
end

MatchDialog.dismiss = function(self)
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onEventResponse);
    self.super.dismiss(self,false);
    self:setVisible(false);
    self:stopMatchAnim();
    self:stopHeadIconAnim();
    self:stopReadyAnim();
    self:stopChangePlayerCountDown()
--    for i=1,3 do
--        self.m_anim_view[i]:removeProp(1);
--        self.m_anim_view[i]:removeProp(2);
--    end
--    delete(self.m_time_out_anim);
end

        -- -1 匹配失败 0 匹配成功
MatchDialog.changeImgStatus = function(self,ret)
    if not ret then return end
    if ret == -1 then
        self.m_match_fail_img:setVisible(true);
        self.m_match_suc_img:setVisible(false);
        self.m_match_img:setVisible(false);
        self.m_opp_userInfo_view2:setVisible(false)
    elseif ret == 0 then
        self.m_match_fail_img:setVisible(false);
        self.m_match_suc_img:setVisible(true);
        self.m_match_img:setVisible(false);
        self.m_opp_userInfo_view2:setVisible(true)
    else
        self.m_match_fail_img:setVisible(false);
        self.m_match_suc_img:setVisible(false);
        self.m_match_img:setVisible(true);
        self.m_opp_userInfo_view2:setVisible(false)
    end
    self.m_tip:setVisible(false)
end
        
function MatchDialog:oppReady()
-- 自己准备了就不提示了
    if not self.m_anim_img_view:getVisible() then return end
    self.m_tip:setVisible(true)
end
        -- -1 匹配失败 0 匹配成功 
MatchDialog.changeBtnStatus = function(self,ret)
    if not ret then return end
    local text1 = self.m_change_quit_btn:getChildByName("Text1");
    local text2 = self.m_ready_restart_btn:getChildByName("Text1");
    if not text1 or not text2 then
        return
    end

    if ret == -1 then
        text1:setText("退出房间");
	    text2:setText("重新匹配");
        self.m_ready_restart_btn:setVisible(true);
        self.m_change_quit_btn:setVisible(true)
    elseif ret == 0 then
        text1:setText("更换对手");
	    text2:setText("准备开局");
        self.m_ready_restart_btn:setVisible(true);
        self.m_change_quit_btn:setVisible(true)
    elseif ret == 1 then
        text1:setText("退出房间");
        self.m_ready_restart_btn:setVisible(false);
        self.m_change_quit_btn:setVisible(true)
    elseif ret == 2 then
        self.m_ready_restart_btn:setVisible(false)
        self.m_change_quit_btn:setVisible(false)
    else
        text1:setText("退出房间");
        self.m_change_quit_btn:setVisible(true)
        self.m_ready_restart_btn:setVisible(false);
    end
end

--更换对手、退出房间点击事件
MatchDialog.btn1Click = function(self)
    if not self.matchStatus then return end
    if -1 == self.matchStatus then
        self.m_room:back_action();
    elseif 0 ==  self.matchStatus then
        self.m_room:back_action();
    elseif 1 == self.matchStatus then
        self:rematch(); 
        print_string("-----------------> 匹配成功！！！");
    end
    self:stopChangePlayerCountDown()
end

--准备开局、重新匹配点击事件
MatchDialog.btn2Click = function(self)
    if not self.matchStatus then return end
    if -1 == self.matchStatus then
        self:rematch(); 
    elseif 1 == self.matchStatus then
        self:readyAnim();
        self.matchStatus = 0;
        self:resetOppInfoView(false);
        print_string("-----------------> 匹配成功！！！");
    end
    self:stopChangePlayerCountDown()
end

function MatchDialog:back_action()
    self.m_room:back_action()
end

MatchDialog.rematch = function(self)
    delete(self.animMatchSuc);
    self.matchStatus = 0;
    self:resetOppInfoView(false);
    self:changeImgStatus(1);
    self:changeBtnStatus(1);
    self:startMatchAnim(self.animTime);
    self.m_head_level:setVisible(false); 
    if self.m_room:getLoginStatus() then
        self.m_room.mModule:changeChessRoom();
    else
        self.m_room.mModule:matchRoom(true); --参数 true重新匹配 false第一次匹配 
    end
end

MatchDialog.stopMatchAnim = function(self)
    for i=1,3 do
        self.m_anim_view[i]:removeProp(1);
        self.m_anim_view[i]:removeProp(2);
    end
    delete(self.m_time_out_anim);
end

MatchDialog.startMatchAnim = function(self,animTime)
--    self.add_op = 0;
--    self:changeFollowBtnStatus();
    self:startHeadIconAnim();
    self.m_anim_img_view:setVisible(true);
    for i=1,3 do
        self.m_anim_view[i]:removeProp(1);
        self.m_anim_view[i]:removeProp(2);
        local delay = i*1000;
        local duration = 3000;
        self.m_anim_view[i]:addPropScale(1, kAnimRepeat, duration, delay, 1, 3, 1, 3, kCenterDrawing);
        self.m_anim_view[i]:addPropTransparency(2, kAnimRepeat, duration, delay, 1, 0);
    end
    delete(self.m_time_out_anim);
    self.m_time_out_anim = AnimFactory.createAnimInt(kAnimNormal, 0, 1, animTime*1000, -1);
    self.m_time_out_anim:setDebugName("MatchDialog.show|m_time_out_anim");
    self.m_time_out_anim:setEvent(self,self.matchFail);
end


MatchDialog.startHeadIconAnim = function(self)
    self:stopHeadIconAnim();
    self.timer = new(AnimInt,kAnimRepeat,0,1,2500,-1);
    self.timer:setEvent(self,self.updataAnim);
end

MatchDialog.updataAnim = function(self,imgurl)
    local n = math.random(18);
    local imgName = UserInfo.DEFAULT_ICON[n];
    if not imgName then
        imgName = UserInfo.DEFAULT_ICON[1];
    end
    local t = type(imgurl);
    if t == "string" then
        imgName = imgurl;
    end

    for i = 1,3 do
        if not self.m_head_bg:checkAddProp(i) then
            self.m_head_bg:removeProp(i);
        end
    end

    local anim_narrow = self.m_head_bg:addPropScale(3,kAnimNormal,400,-1,1,0.9,1,0.9,kCenterDrawing);
    if anim_narrow then
        anim_narrow:setEvent(self,function()
            if t == "string" then
                a1 = string.find(imgName,"http") 
                if a1 then 
                    self.m_icon:setUrlImage(imgName or UserInfo.DEFAULT_ICON[n]);
                else
                    self.m_icon:setFile(imgName);
--                    self.m_icon:setFile(UserInfo.DEFAULT_ICON[n]);
                end
            else
                self.m_icon:setFile(UserInfo.DEFAULT_ICON[n]);
            end
            self.m_head_bg:addPropTransparency(2,kAnimNormal,200,-1,0.8,1);
            self.m_head_bg:removeProp(3);
            delete(anim_narrow);
        end);
    end

    local anim_enlarge = self.m_head_bg:addPropScale(1,kAnimLoop,400,400,1,1.1,1,1.1,kCenterDrawing);
    if anim_enlarge then
        anim_enlarge:setEvent(self,function()
            self.m_head_bg:removeProp(1);
            self.m_head_bg:removeProp(2);
            delete(anim_enlarge);
        end);
    end
end

MatchDialog.readyAnim = function(self)
    self:stopReadyAnim()
    self.m_anim_img_view:setVisible(false);
    self.m_head_bg:addPropTranslate(5,kAnimNormal,700,-1,0,0,0,-320); 
    self.m_head_bg:addPropTransparency(7,kAnimNormal,700,-1,1,0.8);
    self.m_head_bg:addPropScale(6,kAnimNormal,600,-1,1,0.7,1,0.7,kCenterDrawing);
    self.mReadyAnim = new(AnimInt,kAnimNormal,0,1,1500,-1);
    if self.mReadyAnim then
        self.mReadyAnim:setEvent(self,function()
            self.m_room:ready_action();
            self:stopReadyAnim()
        end)
    end
end

MatchDialog.stopReadyAnim = function(self)
    for i = 5,7 do
        if not self.m_head_bg:checkAddProp(i) then
            self.m_head_bg:removeProp(i);
        end
    end
    delete(self.mReadyAnim);
end

MatchDialog.stopHeadIconAnim = function(self)
    for i = 1,3 do
        if not self.m_head_bg:checkAddProp(i) then
            self.m_head_bg:removeProp(i);
        end
    end
    delete(self.timer);
--    self.timer = nil;
end

--设置对手信息
function MatchDialog:setOppUserInfo(data)
    if not data then return end

    self.opp_userInfo = data;
    local userName = data.mnick or "博雅象棋";
    self.m_opp_user_name:setText(userName);
    self.m_opp_user_name2:setText(userName)
    local sex = tonumber(data.sex) or 0
    if sex == 0 then
        self.m_opp_user_sex:setFile("common/icon/private.png")
    elseif sex == 1 then
        self.m_opp_user_sex:setFile("common/icon/man.png")
    elseif sex == 2 then
        self.m_opp_user_sex:setFile("common/icon/woman.png")
    end 
    local id = data.mid
    self.m_opp_user_id:setText("(ID:" .. id .. ")");

    local is_vip = data.is_vip or 0
    if is_vip == 1 then
        self.vip_logo:setVisible(true);
        local w,h = self.m_opp_user_name:getSize()
        local x = 50 + w/2
        self.vip_logo:setPos(-x,306)
    else
        self.vip_logo:setVisible(false);
    end

--    self.m_opp_user_rank:setText(data:getRank());
--    if data:getRank() == "..." then
--        self.m_opp_user_rank:setText("未上榜");
--    end
    local score = data.score or 0
    self.m_opp_user_title:setText(score .. "" );
    self.m_opp_user_level:setFile("common/icon/big_level_" .. 10 - UserInfo.getInstance():getDanGradingLevelByScore(score) .. ".png")

    local drawtimes = data.drawtimes or 0 
    local losetimes = data.losetimes or 0 
    local wintimes = data.wintimes or 0
	local total = drawtimes + losetimes + wintimes;
	local rate = total <= 0 and 0 or wintimes*100/total;
    local str = string.format("%.1f%%",rate)
    self.m_opp_user_rate:setText(str);
    self.m_opp_user_rate2:setText(str);

    local money = ToolKit.getMoneyStr(data.money) or 0;
    self.m_opp_user_money:setText(money);
    self.m_opp_user_money2:setText(money);

    self.m_opp_user_charm:setText(data.charm_value or "0");

    self:setIcon(data)

    self:setSociatyData(data)

    local str = data.geo or "地区位置"
    self.opp_user_geo:setText(str)

    local w,_ = self.opp_user_geo:getSize()
    local x = 30 + w/2
    self.m_opp_user_sex:setPos(-x,410)

    local str = data.signature
    if not str or str == "" then
        str = "这个家伙很懒，什么都没有留下"
    end
    self.sign_text:setText(str .. "")
--    if data:getIconType() == -1 then
--        self.m_opp_icon:setUrlImage(data:getIcon());
--    else
--        self.m_opp_icon:setFile(UserInfo.DEFAULT_ICON[data:getIconType()] or UserInfo.DEFAULT_ICON[1]);
--    end
end

function MatchDialog.setIcon(self,data)
    if data.iconType and data.iconType > 0 then
        self.m_icon:setFile(UserInfo.DEFAULT_ICON[data.iconType] or UserInfo.DEFAULT_ICON[1]);
    elseif data.iconType and data.iconType == 0 then
        self.m_icon:setFile(UserInfo.DEFAULT_ICON[1]);
    else
        if data.iconType == -1 and data.icon_url then --兼容1.7.5之前的版本的头像为""时显示默认头像。
            self.m_icon:setUrlImage(data.icon_url,UserInfo.DEFAULT_ICON[1]);
        end
    end

    local my_set = data.my_set
    if my_set then
        local frameRes = UserSetInfo.getInstance():getFrameRes(my_set.picture_frame);
        self.m_vip_frame:setVisible(frameRes.visible);
        local fw,fh = self.m_vip_frame:getSize();
        if frameRes.frame_res then
            self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
        end
    end
end

function MatchDialog.setSociatyData(self,data)
    if not data then 
        self.no_sociaty_tips:setVisible(true)
        self.sociaty_icon:setVisible(false)
        return 
    end
    local guild = data.guild or {}
    if not guild or type(guild) ~= "table" or next(guild) == nil then
        self.no_sociaty_tips:setVisible(true)
        self.m_sociaty_icon:setVisible(false)
        return 
    else
        self.no_sociaty_tips:setVisible(false)  
    end
    local name = guild.guild_name or ""
    self.m_sociaty_name:setText(name);
    --社团职位
    local role = tonumber(guild.guild_role) or 0
    self.m_sociaty_pos:setText(ChesssociatyModuleConstant.role[role] or "");
    --社团图标
    local guild_icon = tonumber(guild.mark)
    if guild_icon then
        self.m_sociaty_icon:setVisible(true)
        self.m_sociaty_icon:setFile(ChesssociatyModuleConstant.sociaty_icon[guild_icon] or "sociaty_about/r_scholar.png")
    else
        self.m_sociaty_icon:setVisible(false)
    end
end

--显示对手信息
function MatchDialog:showOppUserInfo()
--    self:changeFollowBtnStatus();
    self:resetOppInfoView(false);
--    if not self.m_userinfo_dialog then
--        self.m_userinfo_dialog = new(UserInfoDialog2);
--    end;
--    if self.m_userinfo_dialog:isShowing() then return end
--    self.m_userinfo_dialog:setShowType(UserInfoDialog2.SHOW_TYPE.MATCHGAME)
--    local user = FriendsData.getInstance():getUserData(tonumber(self.user_data:getUid() or 0));
--    self.m_userinfo_dialog:show(user);

end

--设置对手信息弹窗和提示状态
function MatchDialog:resetOppInfoView(ret)
    local state = ret;
--    self.m_tip:setVisible(state);
    if self.matchStatus == 1 then
        state = not state;
    end
    self.m_opp_userInfo_view:setVisible(state);
end

--关闭个人显示信息
function MatchDialog:dismissOppInfo()
    if self.m_opp_userInfo_view:getVisible() then
        self:resetOppInfoView(true);
    end
end

function MatchDialog.onEventResponse(self, cmd, status, data)
    if cmd == kFriend_UpdateUserData then
        if not status then return end
        for _,userData in ipairs(status) do
            if self.m_uid == userData.mid then
                self:setOppUserInfo(userData)
            end
        end
    end
end

function MatchDialog:startChangePlayerCountdown()
    self:stopChangePlayerCountDown()
    self.mChangePlayerCountdown = 10
    self.mChangePlayerCountdownAnim = AnimFactory.createAnimInt(kAnimLoop, 0, 1, 1000, -1)
    self.mChangePlayerCountdownAnim:setEvent(self,self.updateChangePlayerCountdown)
    self:updateChangePlayerCountdown()
end

function MatchDialog:updateChangePlayerCountdown()
    if not self.mChangePlayerCountdown then return end
    local text1 = self.m_change_quit_btn:getChildByName("Text1");
    if not text1 then return end
    text1:setText( string.format("更换对手(%d)",self.mChangePlayerCountdown))
    self.mChangePlayerCountdown = self.mChangePlayerCountdown - 1
    if self.mChangePlayerCountdown <= 0 then
        self:rematch(); 
        self:stopChangePlayerCountDown()
    end
end

function MatchDialog:stopChangePlayerCountDown()
    if self.mChangePlayerCountdownAnim then
        delete(self.mChangePlayerCountdownAnim)
        self.mChangePlayerCountdownAnim = nil
    end
end
--function MatchDialog:setMatchAddFunc(obj,func)
--    self.m_addFunc = func;
--    self.m_addObj = obj;
--end

--function MatchDialog:onMatchFollow()
--    if not self.opp_userInfo then return end

--    local data = {};
--    data.op = self.add_op or 1;
--    data.uid = UserInfo.getInstance():getUid();
--    data.target_uid = self.opp_userInfo:getUid();
----    if self.m_addFunc and self.m_addObj then
----        self.m_addFunc(self.m_addObj,data);
----    end
--    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_ADD_FLLOW,data);
--end

--function MatchDialog:update(info)
--	self:changeFollowBtnStatus(info);
--end

--更新关注按钮状态
--function MatchDialog:changeFollowBtnStatus(info)
--    if not self.opp_userInfo then return end
--    if not info then
--        if FriendsData.getInstance():isYourFollow(self.opp_userInfo:getUid()) == -1 and FriendsData.getInstance():isYourFriend(self.opp_userInfo:getUid()) == -1 then
--            self.m_btn_text:setText("关注");
--            self.m_follow_btn:setFile({"common/button/dialog_btn_1_normal.png","common/button/dialog_btn_1_press.png"});
--            self.add_op = 1;
--        else
--            self.m_btn_text:setText("取消关注");
--            self.m_follow_btn:setFile({"common/button/dialog_btn_5_normal.png","common/button/dialog_btn_5_press.png"});
--            self.add_op = 0;
--        end
--    else
--        if info.relation >= 2 then
--            self.m_btn_text:setText("取消关注");
--            self.m_follow_btn:setFile({"common/button/dialog_btn_5_normal.png","common/button/dialog_btn_5_press.png"});
--            self.add_op = 0;
--        else
--            self.m_btn_text:setText("关注");
--            self.m_follow_btn:setFile({"common/button/dialog_btn_1_normal.png","common/button/dialog_btn_1_press.png"});
--            self.add_op = 1;
--        end
--    end
--end
