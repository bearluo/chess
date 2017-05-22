require(BASE_PATH.."chessScene");
require("dialog/chioce_dialog");
require("dialog/big_head_dialog");
require("dialog/friend_chat_dialog");

FriendsInfoScene = class(ChessScene);

FriendsInfoScene.default_icon = "userinfo/women_head02.png";

FriendsInfoScene.idToIcon = {
    [0] = "userinfo/userHead.png";
    [1] = "userinfo/women_head01.png";
    [2] = "userinfo/man_head02.png";
    [3] = "userinfo/man_head01.png";
    [4] = "userinfo/women_head02.png";
}

FriendsInfoScene.s_controls = 
{
	friendsinfo_back_btn    = 1; --返回
    friendsinfo_icon_mask   = 2; --头像背景
    name                    = 3; --名字
    gender                  = 4; --性别
    sex0                    = 5; --性别保密
    class                   = 6; --等级
    points                  = 7; --积分
    charm                   = 8; --好友榜
    master                  = 9; --大师榜
    winrate                 = 10;--胜率
    win                     = 11;
    ping                    = 12;
    lost                    = 13;
    friendsinfo_change_btn  = 14;--关注按钮
    mes_btn                 = 15;
    challenge_btn           = 16;--观战、挑战、不在线按钮
    challenge_tittle        = 17;
    reportBad_btn           = 18;--举报用户

    content                 = 19;
    left_leaf               = 20;
    right_leaf              = 21;
    stone                   = 22;
    tea_cup                 = 23;
    time                    = 24;
    money                   = 25;
    id                      = 26;
} 

FriendsInfoScene.s_cmds = 
{
    changeFriendTile    = 1;
    changePaiHang       = 2;
    changeFriendsRank   = 3;
    changeFriendstatus  = 4;
    changeFriendsData   = 5;
    change_userIcon     = 6;
    recv_chat_msg_state = 7;
}

FriendsInfoScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = FriendsInfoScene.s_controls;
    FriendsInfoController.friendsID = controller.m_state.m_uid;
    self.expose_emid = controller.m_state.m_uid;
    self:init();
end 

FriendsInfoScene.resume = function(self)
    ChessScene.resume(self);
--    self:reset();
--    self:removeAnimProp();
--    self:resumeAnimStart();
end;

FriendsInfoScene.pause = function(self)
	ChessScene.pause(self);
    self:removeAnimProp();
--    self:pauseAnimStart();
end 

FriendsInfoScene.dtor = function(self)
    if self.p_bigHeadDialog then
        delete(self.p_bigHeadDialog);
        self.p_bigHeadDialog = nil;
    end
    if self.m_friend_chat_dialog then
        delete(m_friend_chat_dialog);
        self.m_friend_chat_dialog = nil;
    end
    delete(self.m_anim_start);
    delete(self.m_anim_end);
end 

FriendsInfoScene.removeAnimProp = function(self)
    self.m_contentView:removeProp(1);
--    self.m_back_btn:removeProp(1);
--    self.m_book_mark:removeProp(1);
    self.m_leaf_left:removeProp(1);
    self.m_leaf_right:removeProp(1);
--    self.m_teapot_dec:removeProp(1);
--    self.m_stone:removeProp(1);
--    self.challenge_btn:removeProp(1);
--    self.mes_btn:removeProp(1);
--    self.challenge_btn:removeProp(1);
end

FriendsInfoScene.setAnimItemEnVisible = function(self,ret)
    self.m_leaf_left:setVisible(ret);
    self.m_leaf_right:setVisible(ret);
end

FriendsInfoScene.resumeAnimStart = function(self,lastStateObj,timer)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;
    delete(self.m_anim_start);
    self.m_anim_start = new(AnimInt,kAnimNormal,0,1,delay,-1);
    if self.m_anim_start then
        self.m_anim_start:setEvent(self,function()
            self:setAnimItemEnVisible(true);
            delete(self.m_anim_start);
        end);
    end

    self.m_contentView:addPropTransparency(1,kAnimNormal,waitTime,delay,0,1);
    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, delay, -lw, 0, -10, 0);
    local rw,rh = self.m_leaf_right:getSize();
    local anim = self.m_leaf_right:addPropTranslate(1, kAnimNormal, waitTime, delay, rw, 0, -10, 0);
    if anim then
        anim:setEvent(self,function()
            self.m_anim_prop_need_remove = true;
            self:removeAnimProp();
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end  
        end);   
    end
end

FriendsInfoScene.pauseAnimStart = function(self,newStateObj,timer)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;
    delete(self.m_anim_end);
    self.m_anim_end = new(AnimInt,kAnimNormal,0,1,delay,-1);
    if self.m_anim_end then
        self.m_anim_end:setEvent(self,function()
            self.m_anim_prop_need_remove = true;
            self:removeAnimProp();
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end  
            delete(self.m_anim_end);
        end);
    end

    self.m_contentView:addPropTransparency(1,kAnimNormal,waitTime,-1,1,0);
    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, -lw, 0, -10);
    local rw,rh = self.m_leaf_right:getSize();
    local anim = self.m_leaf_right:addPropTranslate(1, kAnimNormal, waitTime, -1,  0, rw, 0, -10);
    if anim then
        anim:setEvent(self,function()
            self:setAnimItemEnVisible(false);
        end);
    end

end


FriendsInfoScene.getTime = function(time)
--	if time < 0 then
--		return "一天前";
--	end
	return os.date("%Y/%m/%d %H:%M",time);--%Y/%m/%d %X
end

----------------------------------- function ----------------------------
FriendsInfoScene.init = function(self)

    local datas = FriendsData.getInstance():getUserData(FriendsInfoController.friendsID);
    local status = FriendsData.getInstance():getUserStatus(FriendsInfoController.friendsID);

    self.icon_mask = self:findViewById(self.m_ctrls.friendsinfo_icon_mask); -- 头像背景
    self.friendsinfo_icon = new(Mask,UserInfo.DEFAULT_ICON[1],"common/background/head_mask_bg_150.png");
    self.friendsinfo_icon:setAlign(kAlignCenter);
    self.friendsinfo_icon:setSize(self.icon_mask:getSize());
    self.icon_mask:addChild(self.friendsinfo_icon);

    self.name = self:findViewById(self.m_ctrls.name); -- 名字
    self.gender = self:findViewById(self.m_ctrls.gender);-- 性别 1男 2女 
    self.sex0 = self:findViewById(self.m_ctrls.sex0);--性别 保密
    self.time = self:findViewById(self.m_ctrls.time);-- 登陆时间
    self.money = self:findViewById(self.m_ctrls.money);--金币
    self.m_id = self:findViewById(self.m_ctrls.id);--ID
    --动画控件
    self.m_contentView = self:findViewById(self.m_ctrls.content);  -- 界面
    self.m_leaf_left = self:findViewById(self.m_ctrls.left_leaf);
    self.m_teapot_dec = self:findViewById(self.m_ctrls.tea_cup);
    self.m_leaf_right = self:findViewById(self.m_ctrls.right_leaf);
    self.m_back_btn = self:findViewById(self.m_ctrls.friendsinfo_back_btn);
    self.m_stone = self:findViewById(self.m_ctrls.stone);

--    self.uid = self:findViewById(self.m_ctrls.uid);--ID

--    self.time_tile = self:findViewById(self.m_ctrls.time_tile);-- 登陆时间

--    self.mark_btn = self:findViewById(self.m_ctrls.mark_btn);--关注按钮


--    self.levelIcon = self:findViewById(self.m_ctrls.levelIcon);--棋士等级图标
    self.class = self:findViewById(self.m_ctrls.class);-- 等级
    self.points = self:findViewById(self.m_ctrls.points);--积分
    self.charm_rank = self:findViewById(self.m_ctrls.charm);--魅力榜
    self.master_rank = self:findViewById(self.m_ctrls.master);--大师榜

--    self.friends_tile = self:findViewById(self.m_ctrls.friends_tile);--好友榜
--    self.master_tile = self:findViewById(self.m_ctrls.master_tile);--大师榜

    self.winrate = self:findViewById(self.m_ctrls.winrate);--胜率
    self.win = self:findViewById(self.m_ctrls.win);--胜
    self.ping = self:findViewById(self.m_ctrls.ping);--平
    self.lost = self:findViewById(self.m_ctrls.lost);--负
--    self.content = self:findViewById(self.m_ctrls.content);--胜率条

    self.friendsinfo_change_btn = self:findViewById(self.m_ctrls.friendsinfo_change_btn);--关注按钮
    self.friendsinfo_change_btn:setOnClick(self,self.onSelectChangeClick);
--    self.mark_img = self.friendsinfo_change_btn:getChildByName("image");
    self.mark_text = self.friendsinfo_change_btn:getChildByName("text");
--    self.friendsinfo_change_tile = self:findViewById(self.m_ctrls.friendsinfo_change_tile);--关注按钮标题

    self.challenge_btn = self:findViewById(self.m_ctrls.challenge_btn);--挑战，观战按钮
    self.challenge_tittle = self:findViewById(self.m_ctrls.challenge_tittle); -- 观战标题
    self.mes_btn = self:findViewById(self.m_ctrls.mes_btn);--消息按钮
    self.mes_btn_text = self.mes_btn:getChildByName("text");

    --vip
    self.m_vip_frame = self.m_contentView:getChildByName("icon_bg"):getChildByName("vip_frame");
--    self.challenge_gz = self:findViewById(self.m_ctrls.challenge_gz);
--    self.challenge_tz = self:findViewById(self.m_ctrls.challenge_tz);
--    self.challenge_noonline = self:findViewById(self.m_ctrls.challenge_noonline);
--    self.mes_sendmessage = self:findViewById(self.m_ctrls.mes_sendmessage);
--    self.mes_sendwords = self:findViewById(self.m_ctrls.mes_sendwords);


--    if FriendsData.getInstance():isYourFriend(FriendsInfoController.friendsID) == -1 then
--       self.charm_rank:setVisible(false);
--       self.friends_tile:setVisible(false);

--       pos_x,pos_y = self.master_tile:getPos();
--       pos_xx,pos_yy = self.master:getPos();
--       self.master_tile:setPos(pos_x,pos_y - 30);
--       self.master:setPos(pos_xx,pos_y - 30);
--    end

--    if UserInfo.getInstance():getUid() == FriendsInfoController.friendsID then
--        self.friendsinfo_change_btn:setEnable();
--    end
     
    --如果是新好友去掉新好友标签
    if FriendsData.getInstance():isNewFriends(FriendsInfoController.friendsID) == 1 then
        FriendsData.getInstance():setIsNewFriends(FriendsInfoController.friendsID,0);
    end

    if FriendsData.getInstance():isNewFans(FriendsInfoController.friendsID) == 1 then
        FriendsData.getInstance():setIsNewFans(FriendsInfoController.friendsID,0);
    end
    
    self:setBtnOntouch();

    --未关注/粉丝/已关注/好友  ,挑战，观战，不在线，留言，聊天判断
    self:friendsMarkCall(status);--状态
    self:friendsDataCall(datas);--数据

end
FriendsInfoScene.setBtnOntouch = function(self)
    local func =  function(view,enable)
        local tip = view:getChildByName("text");
        if tip then
            if not enable then
                tip:setColor(255,255,255);
                tip:addPropScaleSolid(1,1.1,1.1,1);
            else
                tip:setColor(240,230,210);
                tip:removeProp(1);
            end
        end
    end
    
    self.challenge_btn:setOnTuchProcess(self.challenge_btn,func);
    self.mes_btn:setOnTuchProcess(self.mes_btn,func);
end

    
FriendsInfoScene.friendsDataCall = function(self,datas) 

   if datas~= nil then
        if datas.mnick and #datas.mnick > 1 then
            local lenth = string.lenutf8(GameString.convert2UTF8(datas.mnick));
            if lenth > 10 then    
                 local str  = string.subutf8(datas.mnick,1,7).."...";
                 self.name.setText(self.name,str);
            else
                 self.name.setText(self.name,datas.mnick);
            end
        else
             self.name.setText(self.name,"未知");
        end

--        self.uid.setText(self.uid,datas.mid);
--        self.money.setText(self.money,datas.money);

        --性别
        if datas.sex == 0 then --性别保密
            self.gender:setVisible(false);
            self.sex0:setVisible(true);
        else
            self.gender:setVisible(true);
            self.sex0:setVisible(false);
            if datas.sex == 1 then
                self.gender:setFile("chessfriends/friend_man.png");
            elseif datas.sex == 2 then
                self.gender:setFile("chessfriends/friend_women.png");
            end
        end  

--        self.levelIcon:setFile("userinfo/level"..UserInfo.getInstance():getDanGradingLevelByScore(tonumber(datas.score))..".png");
        --等级
        self.class:setFile("common/icon/big_level_" .. 10 - UserInfo.getInstance():getDanGradingLevelByScore(tonumber(datas.score)) .. ".png" )
       
--        self.class.setText(self.class,UserInfo.getInstance():getDanGradingNameByScore(tonumber(datas.score)));
        -- ID
        self.m_id:setText(datas.mid or "0");
        --金币
         self.money.setText(self.money,datas.money);

        --积分
        self.points.setText(self.points,datas.score);
        --登陆时间
        self.time.setText(self.time,self.getTime(tonumber(datas.mactivetime)));

        --胜率
        self.winrate.setText(self.winrate,self:getRate(datas.losetimes,datas.wintimes));
        --胜率条
--        self.content:setSize(90*self:getRateNum(datas.losetimes,datas.wintimes));

        self.win.setText(self.win,datas.wintimes .. "局"); --胜
        self.ping.setText(self.ping,datas.drawtimes .. "局");--平
        self.lost.setText(self.lost,datas.losetimes .. "局");--负

        if datas.rank and datas.rank~= 0 then
            local rk = ""..0 .. "名";
           if datas.rank <= 999 then  -- <=
                rk = ""..datas.rank.."名";
           else
                rk = "999+名";
           end
           self.master_rank.setText(self.master_rank,rk);
        end

        if datas.fans_rank and datas.fans_rank ~= 0 then
            local rk = "" .. 0 .. "名";
            if datas.fans_rank <= 999 then -- <=
                rk = ""..datas.fans_rank .."名";
            else
                rk = "999+名";
            end

            self.charm_rank.setText(self.charm_rank,rk);
        end

        --头像
        self.p_iconFile = datas.icon_url;
        self.p_iconType = datas.iconType;
--        if datas.iconType == -1 then
--            local imageName = UserInfo.getCacheImageManager(datas.icon_url,FriendsInfoController.friendsID);
--            if imageName then
--                self.p_iconFile = imageName;
--                self.p_iconLoading = false;
--            else
--                self.p_iconLoading = true;
--            end
--        else
--            self.p_iconFile = UserInfo.DEFAULT_ICON[datas.iconType] or self.p_iconFile;
--        end

        if datas.mid and datas.mid == UserInfo.getInstance():getUid() then
            if UserInfo.getInstance():getIconType() == -1 then
                self.friendsinfo_icon:setUrlImage(UserInfo.getInstance():getIcon());
            else
                self.friendsinfo_icon:setFile(UserInfo.DEFAULT_ICON[UserInfo.getInstance():getIconType()] or UserInfo.DEFAULT_ICON[1]);
            end
            local frameRes = UserSetInfo.getInstance():getFrameRes();
            self.m_vip_frame:setVisible(frameRes.visible);
            local fw,fh = self.m_vip_frame:getSize();
            if frameRes.frame_res then
                self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
            end
        else
            if datas.iconType == -1 then
                self.friendsinfo_icon:setUrlImage(datas.icon_url);
            else
                self.friendsinfo_icon:setFile(UserInfo.DEFAULT_ICON[datas.iconType] or UserInfo.DEFAULT_ICON[1]);
            end
            if datas.is_vip and datas.is_vip == 1 then
            self.m_vip_frame:setVisible(true);
            else
                self.m_vip_frame:setVisible(false);
            end
        end
--        local time = FriendsInfoScene.getTime(tonumber(datas.mactivetime));
--        self.time.setText(self.time,time);  
   end

    if not datas then
        self.m_vip_frame:setVisible(false);
    end
end



FriendsInfoScene.updateUserIcon = function(self,data)
    Log.i("FriendsInfoScene.updateUserIcon: "..(data.ImageName or "null"));
--    if tonumber(data.what) == FriendsInfoController.friendsID and data.ImageName then
--        self.friendsinfo_icon:setFile(data.ImageName);
--        self.p_iconFile = data.ImageName;
--        self.p_iconLoading = false;
--        if self.p_bigHeadDialog then
--            self.p_bigHeadDialog:update(data.ImageName);
--        end
--    end
end

---------数据更新接口
FriendsInfoScene.changeDataCall = function(self,datas) 

    for _,sdata in pairs(datas) do
        if FriendsInfoController.friendsID == tonumber(sdata.mid) then
            self:friendsDataCall(sdata);--数据        
            break;
        end
    end

end


--------状态更新接口
FriendsInfoScene.changeStatusCall = function(self,status)
    for _,sdata in pairs(status) do
        if FriendsInfoController.friendsID == tonumber(sdata.uid) then
            self:friendsMarkCall(sdata);--状态       
            break;
        end
    end
end

--个人信息好友榜
--FriendsInfoScene.changeFriendsRankCall = function(self,info)
--    if not info then return end     
--    Log.d("ZY changeFriendsRankCall");
--    local rk = ""..info.rank.."名";

--    --冒号:对象调用自己的方法
--    self.friends_bang.setText(self.friends_bang,rk);

--end


FriendsInfoScene.changeFriendTileCall = function(self,info)

    if not info then return end   --0,陌生人,=1粉丝，=2关注，=3好友
    local followImg = "chessfriends/follow_normal.png";
    local isfollowImg = "chessfriends/follow_press.png";
    if info.ret == 0 then
        if info.relation >= 2 then
--            self.mark_img:setFile(isfollowImg);
            self.mark_text:setText("已关注");
            self.attention = 0;
        else
--            self.mark_img:setFile(followImg);
            self.mark_text:setText("关注");
            self.attention = 1;
        end
    end

end

FriendsInfoScene.onSelectChangeClick = function(self)
   local data = {};
   data.target_uid = FriendsInfoController.friendsID;
   data.op = self.attention;
   if UserInfo.getInstance():getUid() ~= FriendsInfoController.friendsID then
        self:requestCtrlCmd(FriendsInfoController.s_cmds.attentionTo,data);
   end

end

FriendsInfoScene.friendsMarkCall = function(self,status)

   local friend = FriendsData.getInstance():isYourFriend(FriendsInfoController.friendsID);
   local follow = FriendsData.getInstance():isYourFollow(FriendsInfoController.friendsID);
   local fans = FriendsData.getInstance():isYourFans(FriendsInfoController.friendsID);
   
    local followImg = "chessfriends/follow_normal.png";
    local isfollowImg = "chessfriends/follow_press.png";
   if friend ~= -1 then
--       self.mark_img:setFile(isfollowImg);
       self.mark_text:setText("已关注");
        self.attention = 0;
   elseif follow ~= -1 then
--        self.mark_img:setFile(isfollowImg);
        self.mark_text:setText("已关注");
        self.attention = 0;
   elseif fans ~= -1 then
--        self.mark_img:setFile(followImg);
        self.mark_text:setText("关注");
        self.attention = 1;
   else
--        self.mark_img:setFile(followImg);
        self.mark_text:setText("关注");
        self.attention = 1;
   end

   -----------------------------------------------------------------------
   if status ~= nil then
        if status.hallid <=0 then --离线
            --不在线        
            self.challenge_tittle:setText("不在线");
            self.challenge_btn:setPickable(false);
            self.challenge_btn:setFile("common/button/dialog_btn_9.png");
--            self.challenge_gz:setVisible(false);
--            self.challenge_noonline:setVisible(true); 
            self.mes_btn_text:setText("发送留言");

        else
            if status.tid > 0 then  --tid, >0标识用户在下棋 level, 下棋所在的场次
                --观战
--                local strname = FriendsInfoScene.onGetScreenings(status.level);
                self.challenge_tittle:setText("观战");
                self.challenge_btn:setPickable(true);
                self.challenge_btn:setFile("common/button/dialog_btn_2_normal.png");
--                self.time_tile:setText(strname);
--                self.challenge_gz:setVisible(true);
--                self.challenge_tz:setVisible(false);
--                self.challenge_noonline:setVisible(false);      
            else
                
--                self.time_tile:setText("在线");
                --挑战
--                self.challenge_gz:setVisible(false);
--                self.challenge_tz:setVisible(true);
--                self.challenge_noonline:setVisible(false);
                self.challenge_tittle:setText("挑战");
                self.challenge_btn:setPickable(true);
                self.challenge_btn:setFile("common/button/dialog_btn_2_normal.png");
    
                if FriendsData.getInstance():isYourFriend(FriendsInfoController.friendsID) == -1 then   
                    --self.challenge_btn:setFile("friends/noonline_btn.png");
                end
            end
            self.mes_btn_text:setText("发送消息");
--            self.time:setVisible(false);
        end

--        local datas = FriendsData.getInstance():getFrendsListData();
--        for _,id in pairs(datas) do
--            if id ~= FriendsInfoController.friendsID then
--               --留言
--               self.mes_sendmessage:setVisible(false);
--               self.mes_sendwords:setVisible(true);    
--            else
--                 --聊天 
--               self.mes_sendmessage:setVisible(true);
--               self.mes_sendwords:setVisible(false);
--               break;
--            end
--        end 
       --self.time.setText(self.time,"");    
   end
    
end

--FriendsInfoScene.onGetScreenings = function(level)
--    local room_list = UserInfo.getInstance():getRoomConfig();

--    for i,list in pairs(room_list) do
--       if level == list.level then
--           return list.name;
--       end
--    end

--    return nil;
--end

FriendsInfoScene.getRateNum = function(self,m_losetimes,m_wintimes)
	local total = m_losetimes + m_wintimes;
	local rate = total <= 0 and 0 or m_wintimes/total;
	return rate;
end

FriendsInfoScene.getRate = function(self,m_losetimes,m_wintimes) --胜率
	local total = m_losetimes + m_wintimes;
	local rate = total <= 0 and 0 or math.floor(m_wintimes*100/total);
	return rate .. "%"
end

--FriendsInfoScene.reset = function(self)
--    --查询单个用户的好友榜排名
--    local data = {};
--    data.id = UserInfo.getInstance():getUid();
--    data.target_uid = FriendsInfoController.friendsID;

--    if data.target_uid == nil or data.id == nil then --ZHENGYI
--        return;
--    end

--    self:requestCtrlCmd(FriendsInfoController.s_cmds.changeFriends,data);
--end


FriendsInfoScene.callsCallBack = function(self)
	StateMachine.getInstance():pushState(States.Exchange,StateMachine.STYPE_CUSTOM_WAIT);
end

----------------------------------- onClick -------------------------------------
FriendsInfoScene.onFriendsBackBtnClick = function(self) --返回
    self:requestCtrlCmd(FriendsInfoController.s_cmds.back_action);
end

FriendsInfoScene.onFriendsChallengeBtnClick = function(self) --挑战，观战,不在线
    Log.d("onFriendsChallengeBtnClick");
    if UserInfo.getInstance():getUserStatus() == 1 then
        local freeze_time = UserInfo.getInstance():getUserFreezEndTime();
        local tip_msg;
        if freeze_time ~= 0 then
            tip_msg = "很抱歉，您的账号被多次举报，经核实已被冻结，将于"..os.date("%Y-%m-%d %H:%M",freeze_time) .."解封，期间仅能进入单机和残局版块。"
        else        
            tip_msg = "很抱歉，您的账号被多次举报，经核实已被冻结，仅能进入单机和残局版块。"
        end;
        if not self.m_chioce_dialog then
            self.m_chioce_dialog = new(ChioceDialog);
        end;
        self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE);
        self.m_chioce_dialog:setMessage(tip_msg);
        self.m_chioce_dialog:show();
        return;
    end;
    local status = FriendsData.getInstance():getUserStatus(FriendsInfoController.friendsID);

    if status ~= nil then
        if status.hallid <=0 then --离线
        --不在线
 
        else
            if status.tid > 0 then  
            --观战
                UserInfo.getInstance():setTid(status.tid);
                UserInfo.getInstance():setGameType(GAME_TYPE_WATCH);
                StateMachine.getInstance():pushState(States.OnlineRoom,StateMachine.STYPE_CUSTOM_WAIT);
            else
            --挑战 
                if UserInfo.getInstance():getUid() == FriendsInfoController.friendsID then
                    --ChessToastManager.getInstance():show("不能挑战自己！",500);
                else
                    if FriendsData.getInstance():isYourFriend(FriendsInfoController.friendsID) ~= -1 then
                        UserInfo.getInstance():setTargetUid(FriendsInfoController.friendsID);
                        local post_data = {};
                        post_data.uid = tonumber(UserInfo.getInstance():getUid());
                        post_data.level = 320;
                        self:requestCtrlCmd(FriendsInfoController.s_cmds.challenge,post_data);
                    else    
                        ChessToastManager.getInstance():show("非好友不能挑战！",500);
                    end
                end
            end
        end

    end
    
end

FriendsInfoScene.onFriendsMesBtnClick = function(self) --聊天，留言
    Log.d("onFriendsMesBtnClick");
    local status = FriendsData.getInstance():getUserStatus(FriendsInfoController.friendsID);
    local datas = FriendsData.getInstance():getUserData(FriendsInfoController.friendsID);

    if status ~= nil then

        if status.hallid <=0 then --离线
            --留言

        else
            --聊天 

        end

    end

    if UserInfo.getInstance():getUid() == FriendsInfoController.friendsID then
        --ChessToastManager.getInstance():show("不能和自己聊天！",500);
    else
        if datas~= nil then
--            StateMachine.getInstance():pushState(States.FriendChat,StateMachine.STYPE_WAIT,nil,datas);

            if not self.m_friend_chat_dialog then
                self.m_friend_chat_dialog = new(FriendChatDialog,datas);
            end
            self.m_friend_chat_dialog:show();
        end
    end

end

FriendsInfoScene.onReportBadBtnClick = function(self) --举报用户
    Log.d("onReportBadBtnClick");
    if not self.m_report_dialog then
        self.m_report_dialog = new(ReportDialog);
    end;
    self.m_report_dialog:show(self.expose_emid);
end

FriendsInfoScene.onFriendsinfoiconClick = function(self,finger_action,x,y,drawing_id_first,drawing_id_last) --点击显示大头像
    if finger_action == kFingerUp and drawing_id_first == drawing_id_last then
        Log.d("onFriendsinfoiconClick");
        if not self.p_bigHeadDialog then
            self.p_bigHeadDialog = new(BigHeadDialog);
        end
        self.p_bigHeadDialog:show(self.p_iconFile,self.p_iconType,self.p_iconLoading);
    end
end

--更新friend_chat_dialog 聊天状态
FriendsInfoScene.onReceChatMsgState = function(self,data)
    if data.ret == 0 or data.ret == 1 or data.ret == 2 then
        if data.ret == 0 then
            Log.i("消息发送成功");
        end
        self.m_friend_chat_dialog:updataStatus(data.ret);
    end;
end
----------------------------------- config ------------------------------------------------------------
FriendsInfoScene.s_controlConfig = 
{
    [FriendsInfoScene.s_controls.content] = {"bg_line"};
	[FriendsInfoScene.s_controls.friendsinfo_back_btn] = {"back_btn"};--返回
    [FriendsInfoScene.s_controls.left_leaf] = {"left_leaf"};
    [FriendsInfoScene.s_controls.right_leaf] = {"right_leaf"};
    [FriendsInfoScene.s_controls.stone] = {"stone_dec"};
    [FriendsInfoScene.s_controls.tea_cup] = {"teapot_dec"};

    ----个人信息
    [FriendsInfoScene.s_controls.friendsinfo_icon_mask] = {"bg_line","icon_bg","icon_mask"};--头像背景
    [FriendsInfoScene.s_controls.name] = {"bg_line","name"};--名字
    [FriendsInfoScene.s_controls.gender] = {"bg_line","gender"};--性别男，女
    [FriendsInfoScene.s_controls.sex0] = {"bg_line","sex0"};--性别保密

--    [FriendsInfoScene.s_controls.mark_btn] = {"friendsinfo_top_view","rightView","first","mark_btn"};--关注图标
--    [FriendsInfoScene.s_controls.uid] = {"friendsinfo_top_view","rightView","second","uid"};--ID
    
--    [FriendsInfoScene.s_controls.time_tile] = {"friendsinfo_top_view","rightView","thrid","time_tile"};--登陆时间
--    [FriendsInfoScene.s_controls.time] = {"friendsinfo_top_view","rightView","thrid","time"};--登陆时间
--    [FriendsInfoScene.s_controls.money] = {"friendsinfo_top_view","rightView","four","money","moneyText"};--金币
    
--    [FriendsInfoScene.s_controls.levelIcon] = {"friendsinfo_center_view","left","levelIcon"};--棋士等级图标
    [FriendsInfoScene.s_controls.class] = {"bg_line","level"};--等级
    [FriendsInfoScene.s_controls.points] = {"bg_line","score"};--积分
    [FriendsInfoScene.s_controls.charm] = {"bg_line","charm_rank","num"};--魅力榜
    [FriendsInfoScene.s_controls.master] = {"bg_line","master_rank","num"};--大师榜

    [FriendsInfoScene.s_controls.winrate] = {"bg_line","winrate","num"};--胜率
--    [FriendsInfoScene.s_controls.content] = {"friendsinfo_center_view","right","winRateBg","process","content"};--胜率条
    [FriendsInfoScene.s_controls.win] = {"bg_line","win_num","num"};--胜
    [FriendsInfoScene.s_controls.ping] = {"bg_line","draw_num","num"};--平
    [FriendsInfoScene.s_controls.lost] = {"bg_line","lose_num","num"};--负
    
    [FriendsInfoScene.s_controls.friendsinfo_change_btn] = {"bg_line","follow_btn"};--关注按钮
--    [FriendsInfoScene.s_controls.friendsinfo_change_tile] = {"bg_line","text"};--关注按钮标题

    [FriendsInfoScene.s_controls.challenge_btn] = {"watch_btn"};--观战，挑战，不在线
    [FriendsInfoScene.s_controls.challenge_tittle] = {"watch_btn","text"};
    [FriendsInfoScene.s_controls.mes_btn] = {"send_message"};--消息，留言

--    [FriendsInfoScene.s_controls.challenge_gz] = {"friendsinfo_bottom_view","challenge_btn","gz"};
--    [FriendsInfoScene.s_controls.challenge_tz] = {"friendsinfo_bottom_view","challenge_btn","tz"};
--    [FriendsInfoScene.s_controls.challenge_noonline] = {"friendsinfo_bottom_view","challenge_btn","noonline"};

--    [FriendsInfoScene.s_controls.mes_sendmessage] = {"friendsinfo_bottom_view","mes_btn","sendmessage"};
--    [FriendsInfoScene.s_controls.mes_sendwords] = {"friendsinfo_bottom_view","mes_btn","sendwords"};


--    [FriendsInfoScene.s_controls.friends_tile] = {"friendsinfo_center_view","left","left3","friends_tile"};--好友榜
--    [FriendsInfoScene.s_controls.master_tile] = {"friendsinfo_center_view","left","left4","master_tile"};--大师榜
    
    [FriendsInfoScene.s_controls.reportBad_btn] = {"bg_line","report_btn"};--举报用户
    [FriendsInfoScene.s_controls.time] = {"bg_line","time"};
    [FriendsInfoScene.s_controls.money] = {"bg_line","gold_num"};

    [FriendsInfoScene.s_controls.id] = {"friend_id"};

};

FriendsInfoScene.s_controlFuncMap =
{
	[FriendsInfoScene.s_controls.friendsinfo_back_btn] = FriendsInfoScene.onFriendsBackBtnClick;
    [FriendsInfoScene.s_controls.challenge_btn] = FriendsInfoScene.onFriendsChallengeBtnClick;
    [FriendsInfoScene.s_controls.mes_btn] = FriendsInfoScene.onFriendsMesBtnClick;
    [FriendsInfoScene.s_controls.reportBad_btn] = FriendsInfoScene.onReportBadBtnClick;
    [FriendsInfoScene.s_controls.friendsinfo_icon_mask] = FriendsInfoScene.onFriendsinfoiconClick;

};


FriendsInfoScene.s_cmdConfig =
{
    [FriendsInfoScene.s_cmds.changeFriendTile] = FriendsInfoScene.changeFriendTileCall;
    --[FriendsInfoScene.s_cmds.changePaiHang] = FriendsInfoScene.changePaiHangCall;
--    [FriendsInfoScene.s_cmds.changeFriendsRank] = FriendsInfoScene.changeFriendsRankCall;

    [FriendsInfoScene.s_cmds.changeFriendsData] = FriendsInfoScene.changeDataCall;
    [FriendsInfoScene.s_cmds.changeFriendstatus] = FriendsInfoScene.changeStatusCall; 
    
    [FriendsInfoScene.s_cmds.change_userIcon] = FriendsInfoScene.updateUserIcon;
    [FriendsInfoScene.s_cmds.recv_chat_msg_state] = FriendsInfoScene.onReceChatMsgState;
    
}



