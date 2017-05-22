--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23

require(BASE_PATH.."chessScene");

OwnScene = class(ChessScene);

OwnScene.s_controls = 
{
    scroll_view             = 1;
    top_cloth               = 2;
    head_icon_btn            = 3;
    user_name               = 4;
    login_type              = 5;
    rank_view               = 6;
    friends_rank            = 7;
    fans_rank               = 8;
    master_rank             = 9;
    userinfo_view           = 10;
    my_level                = 11;
    my_assets               = 12;
    my_notice               = 13;
    my_chess_friends        = 14;
    menu                    = 15;
    set_btn                 = 16;
    feedback_btn            = 17;
    share_btn               = 18;
    my_uid                  = 19;
    bottom_menu             = 20;
    switch_account          = 21;
    friends_rank_bg         = 22;
    fans_rank_bg            = 23;
    master_rank_bg          = 24;
}

OwnScene.s_cmds = 
{
    updateUserInfoView = 1;
    updateFriendsRank = 2;
    updateMasterAndFansRank = 3;
}
OwnScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = OwnScene.s_controls;
    self:create();
end 

OwnScene.resume = function(self)
    ChessScene.resume(self);
    self:updateUserInfoView();
--    self:resumeAnimStart();
    require("chess/include/bottomMenu");
    BottomMenu.getInstance():onResume(self.m_bottom_menu,self.bottomMove);
    BottomMenu.getInstance():setHandler(self,3);
    BottomMenu.getInstance():setMyOwnStatus();
end

OwnScene.isShowBangdinDialog = false;

OwnScene.pause = function(self)
	ChessScene.pause(self);
    self:removeAnimProp();
--    self:pauseAnimStart();
    BottomMenu.getInstance():onPause();
end 

OwnScene.dtor = function(self)
    delete(self.m_toggleAccountDialog);
    delete(self.anim_start);
    delete(self.anim_end);         
end 

OwnScene.removeAnimProp = function(self)
    if self.m_anim_prop_need_remove then
        self.m_top_cloth:removeProp(1);
        self.left_leaf:removeProp(1);
        self.right_leaf:removeProp(1);
        self.m_friends_rank_btn:removeProp(1);
        self.m_friends_rank_btn:removeProp(2);
        self.m_fans_rank_btn:removeProp(1);
        self.m_fans_rank_btn:removeProp(2);
        self.m_master_rank_btn:removeProp(1);
        self.m_master_rank_btn:removeProp(2);
        self.m_my_uid:removeProp(1);
        self.m_my_uid:removeProp(2);
        self.m_my_level:removeProp(1);
        self.m_my_level:removeProp(2);
        self.m_my_assets:removeProp(1);
        self.m_my_assets:removeProp(2);
        self.m_my_notice:removeProp(1);
        self.m_my_notice:removeProp(2);
        self.m_my_chess_friends:removeProp(1);
        self.m_my_chess_friends:removeProp(2);
        self.m_anim_prop_need_remove = false;
    end
end

OwnScene.setAnimItemEnVisible = function(self,ret)
--    self.m_friends_rank_btn:setVisible(ret);
--    self.m_fans_rank_btn:setVisible(ret);
--    self.m_master_rank_btn:setVisible(ret);
--    self.m_my_uid:setVisible(ret);
--    self.m_my_level:setVisible(ret);
--    self.m_my_assets:setVisible(ret);
--    self.m_my_notice:setVisible(ret);
--    self.m_my_chess_friends:setVisible(ret);
    self.left_leaf:setVisible(ret);
    self.right_leaf:setVisible(ret);
--    self.m_top_cloth:setVisible(ret);
end

OwnScene.resumeAnimStart = function(self,lastStateObj,timer)
   self.m_anim_prop_need_remove = true;
   self:removeAnimProp();
   local duration = timer.duration;
   local waitTime = timer.waitTime
   local delay = waitTime+duration;

   --背景移动
   local w,h = self:getSize();
    if typeof(lastStateObj,HallState) then
        self.bottomMove = false;
    elseif typeof(lastStateObj,FindState) then
        self.bottomMove = false;
        self.m_root:removeProp(1);
        self.m_root:addPropTranslate(1,kAnimNormal,duration,waitTime,w,0,nil,nil);
    else
        self.bottomMove = true;
        BottomMenu.getInstance():hideView(true);
        BottomMenu.getInstance():removeOutWindow(0,timer);
    end
    delete(self.anim_start);
   self.anim_start = new(AnimInt,kAnimNormal,0,1,duration,waitTime);
   if self.anim_start then
        self.anim_start:setEvent(self,function()
            self:setAnimItemEnVisible(true);
            delete(self.anim_start);
        end);
   end

    local lw,lh = self.left_leaf:getSize();
    self.left_leaf:addPropTranslate(1,kAnimNormal,waitTime,delay,- lw,0,-30,0);
    local rw,rh = self.right_leaf:getSize();
    self.right_leaf:addPropTranslate(1,kAnimNormal,waitTime,delay,rw,0,-30,0);
    -- 上部动画
    local tw,th = self.m_top_cloth:getSize();
    self.m_top_cloth:addPropTranslate(1, kAnimNormal, waitTime, delay, 0, 0, -th, 0);

    --按钮动画
    self.m_friends_rank_btn:addPropTransparency(2,kAnimNormal,waitTime-150,delay,0,1);
    self.m_friends_rank_btn:addPropScale(1,kAnimNormal,waitTime-150,delay,0.8,1,0.8,1,kCenterXY,98,110);

    self.m_fans_rank_btn:addPropTransparency(2,kAnimNormal,waitTime-150,delay+100,0,1);
    self.m_fans_rank_btn:addPropScale(1,kAnimNormal,waitTime-150,delay + 100,0.8,1,0.8,1,kCenterXY,98,110);

    self.m_master_rank_btn:addPropTransparency(2,kAnimNormal,waitTime-150,delay+200,0,1);
    self.m_master_rank_btn:addPropScale(1,kAnimNormal,waitTime-150,delay + 200,0.8,1,0.8,1,kCenterXY,98,110);

    self.m_my_uid:addPropTransparency(2,kAnimNormal,waitTime-150,delay+300,0,1);
    self.m_my_uid:addPropScale(1,kAnimNormal,waitTime-150,delay+300,0.8,1,0.8,1,kCenterXY,98,110);

    self.m_my_level:addPropTransparency(2,kAnimNormal,waitTime-150,delay+400,0,1);
    self.m_my_level:addPropScale(1,kAnimNormal,waitTime-150,delay+400,0.8,1,0.8,1,kCenterXY,98,110);

    self.m_my_assets:addPropTransparency(2,kAnimNormal,waitTime-150,delay+500,0,1);
    self.m_my_assets:addPropScale(1,kAnimNormal,waitTime-150,delay+500,0.8,1,0.8,1,kCenterXY,98,110);

    self.m_my_notice:addPropTransparency(2,kAnimNormal,waitTime-150,delay+600,0,1);
    self.m_my_notice:addPropScale(1,kAnimNormal,waitTime-150,delay+600,0.8,1,0.8,1,kCenterXY,98,110);

    self.m_my_chess_friends:addPropTransparency(2,kAnimNormal,waitTime-150,delay+700,0,1);
    local anim = self.m_my_chess_friends:addPropScale(1,kAnimNormal,waitTime-150,delay+700,0.8,1,0.8,1,kCenterXY,98,110);
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

OwnScene.pauseAnimStart = function(self,newStateObj,timer)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;

    local w,h = self:getSize();
    if not typeof(newStateObj,HallState) and not typeof(newStateObj,FindState) then
        self.bottomMove = true
        BottomMenu.getInstance():removeOutWindow(1,timer);
    elseif typeof(newStateObj,FindState) then
        self.bottomMove = false;
        self.m_root:removeProp(1);
        self.m_root:addPropTranslate(1,kAnimNormal,duration,waitTime,0,w,nil,nil);
    end
   local lw,lh = self.left_leaf:getSize();
   self.left_leaf:addPropTranslate(1,kAnimNormal,waitTime,-1,0,- lw,0,-30);
   local rw,rh = self.right_leaf:getSize();
   self.right_leaf:addPropTranslate(1,kAnimNormal,waitTime,-1,0,rw,0,-30);
   -- 上部动画
   local tw,th = self.m_top_cloth:getSize();
   local anim = self.m_top_cloth:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, 0, 0, -th);
   if anim then
       anim:setEvent(self,function()
            self:setAnimItemEnVisible(false);
       end);
    end
    delete(self.anim_end);         
   self.anim_end = new(AnimInt,kAnimNormal,0,1,delay,-1);
   if self.anim_end then
        self.anim_end:setEvent(self,function()
            self.m_anim_prop_need_remove = true;
            self:removeAnimProp();  
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end 
            if self.bottomMove == true then
                BottomMenu.getInstance():hideView();
            end
            delete(self.anim_end);         
        end);
   end
end

---------------------- func --------------------
OwnScene.create = function(self)

    self.m_root_view = self.m_root;
    self.bottomMove = false;
    self.m_scroll_view = self:findViewById(self.m_ctrls.scroll_view);
    local mw,mh = self.m_scroll_view:getSize();
    local w,h = self.m_root:getSize();
    self.m_scroll_view:setSize(mw,mh+h-System.getLayoutHeight());

    self.m_top_cloth = self:findViewById(self.m_ctrls.top_cloth);
    self.m_head_icon = new(Mask,"common/background/head_mask_bg_122.png","common/background/head_mask_bg_122.png");
    self.m_head_icon_bg = self:findViewById(self.m_ctrls.head_icon_btn);
    self.m_vip_frame = self.m_head_icon_bg:getChildByName("vip_frame");
    self.m_head_icon_bg:addChild(self.m_head_icon);
    self.m_head_icon:setAlign(kAlignCenter);
    self.m_user_name = self:findViewById(self.m_ctrls.user_name);
    self.m_friends_rank = self:findViewById(self.m_ctrls.friends_rank);
    self.m_fans_rank = self:findViewById(self.m_ctrls.fans_rank);
    self.m_master_rank = self:findViewById(self.m_ctrls.master_rank);
    self.m_my_uid = self:findViewById(self.m_ctrls.my_uid);
    self.m_my_level = self:findViewById(self.m_ctrls.my_level);
    self.m_my_assets = self:findViewById(self.m_ctrls.my_assets);
    self.m_my_notice = self:findViewById(self.m_ctrls.my_notice);
    self.m_my_chess_friends = self:findViewById(self.m_ctrls.my_chess_friends);

    
    self.m_my_uid:setSrollOnClick();
    self.m_my_level:setSrollOnClick();
    self.m_my_assets:setSrollOnClick();
    self.m_my_notice:setSrollOnClick();
    self.m_my_chess_friends:setSrollOnClick();

    self.m_feedback_btn = self:findViewById(self.m_ctrls.feedback_btn);
    self.m_set_btn = self:findViewById(self.m_ctrls.set_btn);
    self.m_share_btn = self:findViewById(self.m_ctrls.share_btn);
	if UserInfo.getInstance():getOpenWeixinShare() == 0 then
		self.m_share_btn:setVisible(false);
	else
		self.m_share_btn:setVisible(true);
	end
    if kPlatform == kPlatformIOS then	
        if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then 
            self.m_share_btn:setVisible(true);
            self.m_feedback_btn:setVisible(true);
        else
            self.m_share_btn:setVisible(false);
            self.m_feedback_btn:setVisible(false);
        end;
    end;
    self.m_feedback_btn:setSrollOnClick();
    self.m_set_btn:setSrollOnClick();
    self.m_share_btn:setSrollOnClick();

    self.m_switch_account_btn = self:findViewById(self.m_ctrls.switch_account);
    self.m_switch_account_btn:setSrollOnClick();
    if kPlatform == kPlatformIOS then
        self.m_rank_view = self.m_scroll_view:getChildByName("rank_view");
        if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
            self.m_rank_view:setVisible(true);
        else
            self.m_rank_view:setVisible(false);
        end;    
    end;
    self.m_friends_rank_btn = self:findViewById(self.m_ctrls.friends_rank_bg);
    self.m_fans_rank_btn = self:findViewById(self.m_ctrls.fans_rank_bg);
    self.m_master_rank_btn = self:findViewById(self.m_ctrls.master_rank_bg);

    self.m_friends_rank_btn:setSrollOnClick();
    self.m_fans_rank_btn:setSrollOnClick();
    self.m_master_rank_btn:setSrollOnClick();

    self.m_bottom_menu = self:findViewById(self.m_ctrls.bottom_menu);

    self.left_leaf = self.m_root_view:getChildByName("bamboo_left");
    self.right_leaf = self.m_root_view:getChildByName("bamboo_right");

end

OwnScene.s_headIconFile = UserInfo.DEFAULT_ICON;

OwnScene.updateUserHeadIcon = function(self)
    local iconType = UserInfo.getInstance():getIconType();
    if iconType == -1 then
        local file = UserInfo.getInstance():getIcon() or "";
        self.m_head_icon:setUrlImage(file);
    elseif iconType > 0 and OwnScene.s_headIconFile[iconType] then
        self.m_head_icon:setFile(OwnScene.s_headIconFile[iconType]);
    else
        self.m_head_icon:setFile(OwnScene.s_headIconFile[1]);
    end
end

OwnScene.updateUserInfoView = function(self)
    -- 昵称
    self.m_user_name:setText(UserInfo.getInstance():getName());
    -- 头像
    self:updateUserHeadIcon();
    local data = FriendsData.getInstance():getUserData(UserInfo.getInstance():getUid());
    if data then
        FriendsData.getInstance():sendCheckUserData(UserInfo.getInstance():getUid());
        -- 大师排行榜
        local str = "";
        if data.rank == 1 then
            str = "第一";
        elseif data.rank == 2 then
            str = "第二";
        elseif data.rank == 3 then
            str = "第三";
        else
            str = data.rank or "";
        end
        if data.rank == 0 then
            self.m_master_rank:setText("未入榜");
        else
            self.m_master_rank:setText(str.."名");
        end
        if tonumber(data.rank) and tonumber(data.rank) > 100000 then
            self.m_master_rank:setText("100000+");
        end
        -- 粉丝排行榜
        local str = "";
        if data.fans_rank == 1 then
            str = "第一";
        elseif data.fans_rank == 2 then
            str = "第二";
        elseif data.fans_rank == 3 then
            str = "第三";
        else
            str = data.fans_rank or "";
        end
        if data.fans_rank == 0 then
            self.m_fans_rank:setText("未入榜");
        else
            self.m_fans_rank:setText(str.."名");
        end
        if tonumber(data.fans_rank) and tonumber(data.fans_rank) > 100000 then
            self.m_fans_rank:setText("100000+");
        end
    end
    -- 登录方式
    self.m_login_type = self:findViewById(self.m_ctrls.login_type);
    self.m_login_type:setText(UserInfo.getInstance():getAccountTypeName());
    if kPlatform == kPlatformIOS then
       -- ios 审核关闭游客显示
        if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
            self.m_login_type:setVisible(true);
        else
            self.m_login_type:setVisible(false);
        end;
    end;
    -- 游戏id
    self.m_my_uid:getChildByName("content"):setText(UserInfo.getInstance():getUid());
    self.m_my_uid:setPickable(false);
    -- 好友排行榜
    self:getFriendsRank();
    -- 我的等级
    self.m_my_level:getChildByName("content"):setText(UserInfo.getInstance():getDanGradingName());
    -- 我的资产
    self.m_my_assets:getChildByName("content"):setText(UserInfo.getInstance():getMoneyStr().."金币");
    -- 我的消息
    local num = GameCacheData.getInstance():getInt(GameCacheData.NOTICE_NUM..UserInfo.getInstance():getUid(),0);
    local notice_str = "";
    if num > 0 then
        notice_str = string.format("+%d条",num);
    end
    self.m_my_notice:getChildByName("content"):setText(notice_str);
    -- 我的棋友
    local friendsNum = 0;
    local fansNum = 0;

    local friendsList = FriendsData.getInstance():getFrendsListData();
    local fansList = FriendsData.getInstance():getFansListData();

    if friendsList~= nil then
        for i,uid in pairs(friendsList) do
                if FriendsData.getInstance():isNewFriends(uid) == 1 then
                    friendsNum = friendsNum + 1;
                end
        end
    end
    if fansList~= nil then
        for i,uid in pairs(fansList) do
                if FriendsData.getInstance():isNewFans(uid) == 1 then
                    fansNum = fansNum + 1;
                end
        end
    end

    local chess_friends_str = "";
    if friendsNum > 0 then
        chess_friends_str = string.format("+%d好友",friendsNum);
    end

    if fansNum > 0 then
        chess_friends_str = string.format("%s +%d粉丝",chess_friends_str,fansNum);
    end
    self.m_my_chess_friends:getChildByName("content"):setText(chess_friends_str);
    --vip头像框
--    local is_vip = nil;
--    is_vip = UserInfo.getInstance():getIsVip();
--    if is_vip and is_vip == 1 then
--        self.m_vip_frame:setVisible(true);
--    else
--        self.m_vip_frame:setVisible(false);
--    end
    local frameRes = UserSetInfo.getInstance():getFrameRes();
    self.m_vip_frame:setVisible(frameRes.visible);
    local fw,fh = self.m_vip_frame:getSize();
    if frameRes.frame_res then
        self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
    end
end

-- 拉取好友排行
OwnScene.getFriendsRank = function(self)
    self:requestCtrlCmd(OwnController.s_cmds.getFriendsRank);
end

-- 个人信息好友榜
OwnScene.updateFriendsRankCall = function(self,info)
    if not info then return end     
    local str = "";
    if info.rank == 1 then
        str = "第一";
    elseif info.rank == 2 then
        str = "第二";
    elseif info.rank == 3 then
        str = "第三";
    else
        str = info.rank or "";
    end
    if info.rank == 0 then
        self.m_friends_rank:setText("未入榜");
    else
        self.m_friends_rank:setText(str.."名");
    end
    if tonumber(info.rank) and tonumber(info.rank) > 100000 then
        self.m_friends_rank:setText("100000+");
    end
end
--大师排行榜 粉丝排行榜
OwnScene.updateMasterAndFansRank = function(self,data)
    if data then
        -- 大师排行榜
        local str = "";
        if data.rank == 1 then
            str = "第一";
        elseif data.rank == 2 then
            str = "第二";
        elseif data.rank == 3 then
            str = "第三";      
        else
            str = data.rank or "";
        end
        if data.rank == 0 then
            self.m_master_rank:setText("未入榜");
        else
            self.m_master_rank:setText(str.."名");
        end
        if tonumber(data.rank) and tonumber(data.rank) > 100000 then
            self.m_master_rank:setText("100000+");
        end
        -- 粉丝排行榜
        local str = "";
        if data.fans_rank == 1 then
            str = "第一";
        elseif data.fans_rank == 2 then
            str = "第二";
        elseif data.fans_rank == 3 then
            str = "第三";   
        else
            str = data.fans_rank or "";
        end
        if data.fans_rank == 0 then
            self.m_fans_rank:setText("未入榜");
        else
            self.m_fans_rank:setText(str.."名");
        end
        
        if tonumber(data.fans_rank) and tonumber(data.fans_rank) > 100000 then
            self.m_fans_rank:setText("100000+");
        end
    end
end

--------------------- click ------------------
OwnScene.onBackBtnClick = function(self)
    Log.i("OwnScene.onBackBtnClick");
    self:requestCtrlCmd(OwnController.s_cmds.onBack);
end

OwnScene.onMallBtnClick = function(self)
    self:requestCtrlCmd(OwnController.s_cmds.goToMall);
end

OwnScene.onSetBtnClick = function(self)
    StateMachine.getInstance():pushState(States.setModel,StateMachine.STYPE_CUSTOM_WAIT);
end

OwnScene.onFeedbackBtnClick = function(self)
    StateMachine.getInstance():pushState(States.Feedback,StateMachine.STYPE_CUSTOM_WAIT);
end

OwnScene.onShareBtnClick = function(self)
    StateMachine.getInstance():pushState(States.shareModel,StateMachine.STYPE_CUSTOM_WAIT);
    
end

OwnScene.onMyLevelBtnClick = function(self)
    StateMachine.getInstance():pushState(States.gradeModel,StateMachine.STYPE_CUSTOM_WAIT);
end

OwnScene.onMyAssetsBtnClick = function(self)
    StateMachine.getInstance():pushState(States.assetsModel,StateMachine.STYPE_CUSTOM_WAIT);
end

OwnScene.onMyNoticeBtnClick = function(self)
    GameCacheData.getInstance():saveInt(GameCacheData.NOTICE_NUM..UserInfo.getInstance():getUid(),0);
    StateMachine.getInstance():pushState(States.noticeModel,StateMachine.STYPE_CUSTOM_WAIT);
end

OwnScene.onMyChessFriendsBtnClick = function(self)
    self:requestCtrlCmd(OwnController.s_cmds.goToChessFriends);
end

OwnScene.onSwitchAccountBtnClick = function(self)
    require("dialog/toggle_account_dialog");
    delete(self.m_toggleAccountDialog);
    self.m_toggleAccountDialog = nil;
    self.m_toggleAccountDialog = new(ToggleAccountDialog);
    self.m_toggleAccountDialog:setCtrl(self.m_controller);
	self.m_toggleAccountDialog:show();
end

OwnScene.onUserinfoBtnClick = function(self)
    StateMachine.getInstance():pushState(States.UserInfo,StateMachine.STYPE_CUSTOM_WAIT);
end
-- 1 好友排行榜 2 粉丝排行榜 3 大师排行榜
OwnScene.onFriendsRankBtnClick = function(self)
    StateMachine.getInstance():pushState(States.Rank,StateMachine.STYPE_CUSTOM_WAIT,nil,1);
end

OwnScene.onFansRankBtnClick = function(self)
    StateMachine.getInstance():pushState(States.Rank,StateMachine.STYPE_CUSTOM_WAIT,nil,2);
end

OwnScene.onMasterRankBtnClick = function(self)
    StateMachine.getInstance():pushState(States.Rank,StateMachine.STYPE_CUSTOM_WAIT,nil,3);
end
---------------------- config ------------------
OwnScene.s_controlConfig = 
{

    [OwnScene.s_controls.scroll_view]              = {"scroll_view"};
    [OwnScene.s_controls.top_cloth]                = {"top_cloth"};
    [OwnScene.s_controls.head_icon_btn]            = {"top_cloth","head_icon_btn"};
    [OwnScene.s_controls.user_name]                = {"top_cloth","user_name"};
    [OwnScene.s_controls.login_type]               = {"top_cloth","login_type"};
    [OwnScene.s_controls.rank_view]                = {"scroll_view","rank_view"};
    [OwnScene.s_controls.friends_rank]             = {"scroll_view","rank_view","friends_rank_bg","rank"};
    [OwnScene.s_controls.fans_rank]                = {"scroll_view","rank_view","fans_rank_bg","rank"};
    [OwnScene.s_controls.master_rank]              = {"scroll_view","rank_view","master_rank_bg","rank"};
    [OwnScene.s_controls.friends_rank_bg]             = {"scroll_view","rank_view","friends_rank_bg"};
    [OwnScene.s_controls.fans_rank_bg]                = {"scroll_view","rank_view","fans_rank_bg"};
    [OwnScene.s_controls.master_rank_bg]              = {"scroll_view","rank_view","master_rank_bg"};
    [OwnScene.s_controls.userinfo_view]            = {"scroll_view","userinfo_view"};
    [OwnScene.s_controls.my_uid]                   = {"scroll_view","userinfo_view","my_uid"};
    [OwnScene.s_controls.my_level]                 = {"scroll_view","userinfo_view","my_level"};
    [OwnScene.s_controls.my_assets]                = {"scroll_view","userinfo_view","my_assets"};
    [OwnScene.s_controls.my_notice]                = {"scroll_view","userinfo_view","my_notice"};
    [OwnScene.s_controls.my_chess_friends]         = {"scroll_view","userinfo_view","my_chess_friends"};
    [OwnScene.s_controls.menu]                     = {"scroll_view","menu"};
    [OwnScene.s_controls.set_btn]                  = {"scroll_view","menu","set_btn"};
    [OwnScene.s_controls.feedback_btn]             = {"scroll_view","menu","feedback_btn"};
    [OwnScene.s_controls.share_btn]                = {"scroll_view","menu","share_btn"};
    [OwnScene.s_controls.bottom_menu]              = {"bottom_menu"};
    [OwnScene.s_controls.switch_account]           = {"scroll_view","switch_account"};
}

OwnScene.s_controlFuncMap = {
    
    [OwnScene.s_controls.set_btn]                      = OwnScene.onSetBtnClick;
    [OwnScene.s_controls.feedback_btn]                 = OwnScene.onFeedbackBtnClick;
    [OwnScene.s_controls.share_btn]                    = OwnScene.onShareBtnClick;
    [OwnScene.s_controls.my_level]                     = OwnScene.onMyLevelBtnClick;
    [OwnScene.s_controls.my_assets]                    = OwnScene.onMyAssetsBtnClick;
    [OwnScene.s_controls.my_notice]                    = OwnScene.onMyNoticeBtnClick;
    [OwnScene.s_controls.my_chess_friends]             = OwnScene.onMyChessFriendsBtnClick;
    [OwnScene.s_controls.switch_account]               = OwnScene.onSwitchAccountBtnClick;
    [OwnScene.s_controls.head_icon_btn]                = OwnScene.onUserinfoBtnClick;
    [OwnScene.s_controls.friends_rank_bg]              = OwnScene.onFriendsRankBtnClick;
    [OwnScene.s_controls.fans_rank_bg]                 = OwnScene.onFansRankBtnClick;
    [OwnScene.s_controls.master_rank_bg]               = OwnScene.onMasterRankBtnClick;
};

OwnScene.s_cmdConfig =
{
    [OwnScene.s_cmds.updateUserInfoView]                = OwnScene.updateUserInfoView;
    [OwnScene.s_cmds.updateFriendsRank]                 = OwnScene.updateFriendsRankCall;
    [OwnScene.s_cmds.updateMasterAndFansRank]           = OwnScene.updateMasterAndFansRank;
}