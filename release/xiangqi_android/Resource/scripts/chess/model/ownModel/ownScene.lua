--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23

require(BASE_PATH.."chessScene");
require("chess/include/bottomMenu");
require("dialog/toggle_account_dialog");
require("dialog/select_sex_dialog");
require("dialog/city_locate_pop_dialog");
require("dialog/change_head_icon_dialog");
require(DIALOG_PATH.."bangdin_dialog");
require("dialog/chioce_dialog");
require("dialog/remove_bind_dialog");
require(DIALOG_PATH .. "gift_dialog");
require(DIALOG_PATH .. "setting_dialog_2")
require(DIALOG_PATH .. "aboutDialog")
OwnScene = class(ChessScene);

OwnScene.s_controls = 
{
    scroll_view             = 1;
    --top_cloth               = 2;
    head_icon_btn           = 3;
    --user_name               = 4;
    login_type              = 5;
    info_view               = 6;
    my_sexual               = 7;
    my_region               = 8;
    bind_view               = 9;
    userinfo_view           = 10;
    my_level                = 11;
    my_name                 = 12;
    --my_notice               = 13;
    my_setting              = 14;
    menu                    = 15;
    set_btn                 = 16;
    feedback_btn            = 17;
    share_btn               = 18;
    my_uid                  = 19;
    --bottom_menu             = 20;
    my_gift                 = 21;
    my_real_name            = 22;
    switch_account          = 23;
    --btn_fupan               = 23;
    sign_btn                = 24;
    back_btn = 25;
    content_view = 26;
}

OwnScene.s_cmds = 
{
    updateUserInfoView      = 1;
    upLoadImage             = 2;
    updateUserHead          = 3;
    updateRealName          = 4;
    registerShowDailyTask   = 5;
}

OwnScene.nameModify = 1;
OwnScene.signModify = 2;

OwnScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = OwnScene.s_controls;
    self:create();
end 

OwnScene.resume = function(self)
    ChessScene.resume(self);
    self:updateUserInfoView();
    self:showModifyUserMnick();
    EventDispatcher.getInstance():register(Event.Call,self,self.onEventResponse)
end

OwnScene.isShowBangdinDialog = false;

OwnScene.pause = function(self)
	ChessScene.pause(self);
    self:removeAnimProp();
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onEventResponse);
    DailyTaskManager.getInstance():unregister(self,self.onShowDailyTask)
--    self:pauseAnimStart();
    if self.mAboutDialog and self.mAboutDialog:isShowing()  then
        self.mAboutDialog:dismiss()
    end
end 

OwnScene.dtor = function(self)
    delete(self.m_chioce_dialog);
    delete(self.m_changeHeadDialog);
    delete(self.m_locate_city_dialog);
    delete(self.m_select_sex_dialog);
    delete(self.m_gift_dialog);
    delete(self.anim_start);
    delete(self.m_real_name_dialog)
    if self.m_toggleAccountDialog then
        self.m_toggleAccountDialog:dismiss()
    end
    delete(self.mChangeNameDialog)
end 

OwnScene.removeAnimProp = function(self)
    --self.m_top_cloth:removeProp(1);
    --self.left_leaf:removeProp(1);
    --self.right_leaf:removeProp(1);
    self.m_my_uid:removeProp(1);
    self.m_my_uid:removeProp(2);
    self.m_my_level:removeProp(1);
    self.m_my_level:removeProp(2);
    self.m_my_name:removeProp(1);
    self.m_my_name:removeProp(2);
--    self.m_my_notice:removeProp(1);
--    self.m_my_notice:removeProp(2);
    self.m_my_setting:removeProp(1);
    self.m_my_setting:removeProp(2);
    self.m_my_sexual:removeProp(1);
    self.m_my_sexual:removeProp(2);        
    self.m_my_region:removeProp(1);
    self.m_my_region:removeProp(2);  
    self.m_my_real_name:removeProp(1);
    self.m_my_real_name:removeProp(2);
    self.m_my_gift:removeProp(1);
    self.m_my_gift:removeProp(2);
    --self.m_my_fupan:removeProp(1);
    --self.m_my_fupan:removeProp(2);
    self.m_my_sign:removeProp(1);
    self.m_my_sign:removeProp(2);

    if self.bindTabitem and #self.bindTabitem > 0 then
        for i =1, #self.bindTabitem do 
            self.bindTabitem[i]:removeProp(1);
            self.bindTabitem[i]:removeProp(2);
        end
    end
    delete(self.anim_start);
    delete(self.timerAnim);
    self.timerAnim = nil;
    delete(self.anim_end);
end

OwnScene.setAnimItemEnVisible = function(self,ret)
    --self.left_leaf:setVisible(ret);
    --self.right_leaf:setVisible(ret);
end

OwnScene.resumeAnimStart = function(self,lastStateObj,timer,changeStyle)
    --背景移动
    --self:setAnimItemEnVisible(false);
    self:removeAnimProp();
    local w,h = self:getSize();

    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;

    delete(self.anim_start);
    self.anim_start = new(AnimInt,kAnimNormal,0,1,0,duration);
    if self.anim_start then
        self.anim_start:setEvent(self,function()
            --self:setAnimItemEnVisible(true);
            delete(self.anim_start);
        end);
    end


    --local lw,lh = self.left_leaf:getSize();
    --self.left_leaf:addPropTranslate(1,kAnimNormal,waitTime,delay,- lw,0,-30,0);
    --local rw,rh = self.right_leaf:getSize();
    --local anim = 
    --self.right_leaf:addPropTranslate(1,kAnimNormal,waitTime,delay,rw,0,-30,0);
--    if anim then
--        anim:setEvent(self,function()
--            self:removeAnimProp();
--        end);
--    end
    -- 上部动画
    --local tw,th = self.m_top_cloth:getSize();
    --self.m_top_cloth:addPropTranslate(1, kAnimNormal, waitTime, delay, 0, 0, -th, 0);

    self.m_my_uid:addPropTransparency(2,kAnimNormal,waitTime-150,delay,0,1);
    self.m_my_uid:addPropScale(1,kAnimNormal,waitTime-150,delay,0.8,1,0.8,1,kCenterXY,98,110);

    self.m_my_level:addPropTransparency(2,kAnimNormal,waitTime-150,delay+100,0,1);
    self.m_my_level:addPropScale(1,kAnimNormal,waitTime-150,delay+100,0.8,1,0.8,1,kCenterXY,98,110);

    self.m_my_name:addPropTransparency(2,kAnimNormal,waitTime-150,delay+200,0,1);
    self.m_my_name:addPropScale(1,kAnimNormal,waitTime-150,delay+200,0.8,1,0.8,1,kCenterXY,98,110);

--    self.m_my_notice:addPropTransparency(2,kAnimNormal,waitTime-150,delay+300,0,1);
--    self.m_my_notice:addPropScale(1,kAnimNormal,waitTime-150,delay+300,0.8,1,0.8,1,kCenterXY,98,110);

    self.m_my_setting:addPropTransparency(2,kAnimNormal,waitTime-150,delay+300,0,1);
    self.m_my_setting:addPropScale(1,kAnimNormal,waitTime-150,delay+300,0.8,1,0.8,1,kCenterXY,98,110);

    --self.m_my_fupan:addPropTransparency(2,kAnimNormal,waitTime-150,delay+400,0,1);
    --self.m_my_fupan:addPropScale(1,kAnimNormal,waitTime-150,delay+400,0.8,1,0.8,1,kCenterXY,98,110);

    self.m_my_gift:addPropTransparency(2,kAnimNormal,waitTime-150,delay+500,0,1);
    self.m_my_gift:addPropScale(1,kAnimNormal,waitTime-150,delay+500,0.8,1,0.8,1,kCenterXY,98,110);

    self.m_my_sexual:addPropTransparency(2,kAnimNormal,waitTime-150,delay+600,0,1);
    self.m_my_sexual:addPropScale(1,kAnimNormal,waitTime-150,delay+600,0.8,1,0.8,1,kCenterXY,98,110);

    self.m_my_region:addPropTransparency(2,kAnimNormal,waitTime-150,delay+700,0,1);
    self.m_my_region:addPropScale(1,kAnimNormal,waitTime-150,delay+700,0.8,1,0.8,1,kCenterXY,98,110);

    self.m_my_sign:addPropTransparency(2,kAnimNormal,waitTime-150,delay+800,0,1);
    self.m_my_sign:addPropScale(1,kAnimNormal,waitTime-150,delay+800,0.8,1,0.8,1,kCenterXY,98,110);

    self.m_my_real_name:addPropTransparency(2,kAnimNormal,waitTime-150,delay+900,0,1);
    self.m_my_real_name:addPropScale(1,kAnimNormal,waitTime-150,delay+900,0.8,1,0.8,1,kCenterXY,98,110);

    local startAnimIntDelay = 0
    if self.bindTabitem and #self.bindTabitem > 0 then
        startAnimIntDelay = #self.bindTabitem * 100;
        for i = 1,#self.bindTabitem do
            self.bindTabitem[i]:addPropTransparency(2,kAnimNormal,waitTime-150,(delay + 900 + i * 100) ,0,1);
            self.bindTabitem[i]:addPropScale(1,kAnimNormal,waitTime-150,(delay + 900 + i * 100),0.8,1,0.8,1,kCenterXY,98,110);
        end
    end
    --需要所有动画播完后再调用
    self.timerAnim = new(AnimInt,kAnimNormal,0,1,waitTime-120,delay + 900 + startAnimIntDelay);
    if self.timerAnim then
        self.timerAnim:setEvent(self,function()
            self:removeAnimProp();
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end
            delete(self.timerAnim);
            self.timerAnim = nil;
        end);
    end

end

OwnScene.pauseAnimStart = function(self,newStateObj,timer,changeStyle)
    self:removeAnimProp();
    local w,h = self:getSize();

    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;
    --local lw,lh = self.left_leaf:getSize();
    --self.left_leaf:addPropTranslate(1,kAnimNormal,waitTime,-1,0,- lw,0,-30);
    --local rw,rh = self.right_leaf:getSize();
    --self.right_leaf:addPropTranslate(1,kAnimNormal,waitTime,-1,0,rw,0,-30);
    -- 上部动画
    --local tw,th = self.m_top_cloth:getSize();
    --local anim = self.m_top_cloth:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, 0, 0, -th);
    if anim then
        anim:setEvent(self,function()
            --self:setAnimItemEnVisible(false);
--            self:removeAnimProp();
        end);
    end
    delete(self.anim_end);         
    self.anim_end = new(AnimInt,kAnimNormal,0,1,delay,-1);
    if self.anim_end then
        self.anim_end:setEvent(self,function()
            self:removeAnimProp();  
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end 
            delete(self.anim_end); 
            self.anim_end = nil;        
        end);
    end
end

---------------------- func --------------------
OwnScene.create = function(self)

    self.m_root_view = self.m_root;
    self.bottomMove = false;
    self.m_content_view = self:findViewById(self.m_ctrls.content_view)
    self.m_scroll_view = self:findViewById(self.m_ctrls.scroll_view)
    local mw,mh = self.m_content_view:getSize();
    --local mw,mh = self.m_scroll_view:getSize();
    local w,h = self.m_root:getSize();
    --self.m_scroll_view:setSize(mw,mh+h-System.getLayoutHeight());
    self.m_content_view:setSize(mw,mh+h-System.getLayoutHeight());
    local sw,sh = self.m_content_view:getSize()
    self.m_scroll_view:setSize(sw,nil);
    --self.m_top_cloth = self:findViewById(self.m_ctrls.top_cloth);
    self.m_head_icon = new(Mask,"common/background/head_mask_bg_122.png","common/background/head_mask_bg_122.png");
    self.m_head_icon_bg = self:findViewById(self.m_ctrls.head_icon_btn);
    self.m_vip_frame = self.m_head_icon_bg:getChildByName("vip_frame");
    self.m_icon_mask = self.m_head_icon_bg:getChildByName("user_info_icon_mask");
    self.m_icon_mask:addChild(self.m_head_icon);
    self.m_head_icon:setAlign(kAlignCenter);
    --self.m_user_name = self:findViewById(self.m_ctrls.user_name);
--    self.m_friends_rank = self:findViewById(self.m_ctrls.friends_rank);
--    self.m_fans_rank = self:findViewById(self.m_ctrls.fans_rank);
--    self.m_master_rank = self:findViewById(self.m_ctrls.master_rank);
    self.m_my_uid = self:findViewById(self.m_ctrls.my_uid);
    self.m_my_level = self:findViewById(self.m_ctrls.my_level);
    self.m_my_name = self:findViewById(self.m_ctrls.my_name);
--    self.m_my_notice = self:findViewById(self.m_ctrls.my_notice);
    self.m_my_setting = self:findViewById(self.m_ctrls.my_setting);
    self.m_my_sexual = self:findViewById(self.m_ctrls.my_sexual);
    self.m_my_region = self:findViewById(self.m_ctrls.my_region);
    self.m_my_real_name = self:findViewById(self.m_ctrls.my_real_name);
    self.m_my_real_name:getChildByName("content"):setText("查询中...");
    self.m_real_name_status = -1
    self.m_my_gift = self:findViewById(self.m_ctrls.my_gift);

    -- 复盘
    --self.m_my_fupan = self:findViewById(self.m_ctrls.btn_fupan);
    --个性签名
    self.m_my_sign = self:findViewById(self.m_ctrls.sign_btn);
    self.m_my_sign:setOnClick(self,function()
        self.inputType = OwnScene.signModify
        EditTextGlobal = self;
	    ime_open_edit(UserInfo.getInstance():getSignAture(),
		    "",
		    kEditBoxInputModeSingleLine,
		    kEditBoxInputFlagInitialCapsSentence,
		    kKeyboardReturnTypeDone,
		    -1,"global");
    end)
    --切换账号
    self.m_switch_account = self:findViewById(self.m_ctrls.switch_account)
    self.m_switch_account:setOnClick(self,function()
        self:requestCtrlCmd(OwnController.s_cmds.userInfo);
    end)

    self.m_my_uid:setSrollOnClick();
    self.m_my_level:setSrollOnClick();
    self.m_my_name:setSrollOnClick();
--    self.m_my_notice:setSrollOnClick();
    self.m_my_setting:setSrollOnClick();
    self.m_my_sexual:setSrollOnClick();
    self.m_my_region:setSrollOnClick();
    self.m_my_real_name:setSrollOnClick();
    self.m_my_gift:setSrollOnClick();
    --self.m_my_fupan:setSrollOnClick();
    self.m_my_sign:setSrollOnClick();

    self.m_feedback_btn = self:findViewById(self.m_ctrls.feedback_btn);
    self.m_set_btn = self:findViewById(self.m_ctrls.set_btn);
    self.m_share_btn = self:findViewById(self.m_ctrls.share_btn);
	if UserInfo.getInstance():getOpenWeixinShare() == 0 then
		self.m_share_btn:setVisible(false);
	else
		self.m_share_btn:setVisible(true);
	end

    ToolKit.iosAuditStatus(function() 
        self.m_switch_account:setVisible(true);
        self.m_share_btn:setVisible(true);
        self.m_feedback_btn:setVisible(true);
    end,function() 
        self.m_switch_account:setVisible(false);
        self.m_share_btn:setVisible(false);
        self.m_feedback_btn:setVisible(false);
    end);

    self.m_feedback_btn:setSrollOnClick();
    self.m_set_btn:setSrollOnClick();
    self.m_share_btn:setSrollOnClick();

    --self.m_bottom_menu = self:findViewById(self.m_ctrls.bottom_menu);
    self.m_scroll_menu = self:findViewById(self.m_ctrls.menu);
    self.m_info_view = self:findViewById(self.m_ctrls.info_view); --性别和地区选择信息

    --self.left_leaf = self.m_root_view:getChildByName("bamboo_left");
    --self.right_leaf = self.m_root_view:getChildByName("bamboo_right");
    --self.left_leaf:setFile("common/decoration/left_leaf.png")
    --self.right_leaf:setFile("common/decoration/right_leaf.png")

    self.m_bind_view = self:findViewById(self.m_ctrls.bind_view);
    self.m_line_bg = new(Image,"common/background/line_bg.png",nil,nil,64,64,64,64);
    self.m_line_bg:setAlign(kAlignTop);
    self.m_line_bg:setSize(590,72);
    self.m_bind_view:addChild(self.m_line_bg);

    self.mBackBtn = self:findViewById(self.m_ctrls.back_btn)
--    self.m_bind_list_view = new(ListView,0,0,OwnSceneBindItem.ITEM_WIDTH,OwnSceneBindItem.ITEM_HEIGHT);
--    self.m_bind_list_view:setAlign(kAlignTop);
--    self.m_bind_list_view:setDirection(kVertical);
--    self.m_bind_view:addChild(self.m_bind_list_view);
     -- 更新绑定界面
    self:updateBindView();

end


OwnScene.updateRealName = function(self,status)
    self.m_real_name_status = status
    if self.m_real_name_status == 1 then
        self.m_my_real_name:getChildByName("content"):setText("已认证");
    elseif self.m_real_name_status == 0 then
        self.m_my_real_name:getChildByName("content"):setText("未认证");
    else
        self.m_my_real_name:getChildByName("content"):setText("认证查询失败");
    end
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

OwnScene.updateUserInfoView = function(self,isLoginSuccess)
    -- 昵称
    --self.m_user_name:setText(UserInfo.getInstance():getName());
    -- 头像
    self:updateUserHeadIcon();
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
--    self:getFriendsRank();
    -- 我的等级
    local s1 = UserInfo.getInstance():getDanGradingName()
    local s2 = UserInfo.getInstance():getScore()
    self.m_my_level:getChildByName("content"):setText(s1 .. "(" .. s2 .. ")");
    -- 我的名字
    self.m_my_name:getChildByName("content"):setText(UserInfo.getInstance():getName(),0,0);
    self.m_name_icon = self.m_my_name:getChildByName("my_name_icon");
    if tonumber(UserInfo.getInstance():getIsModifyUserMnick()) == 0 then
--        self.m_my_name:getChildByName("modify_txt"):setText("(不可修改)");
        self.m_name_icon:setVisible(false)
    else
--        self.m_my_name:getChildByName("modify_txt"):setText("(只能修改一次)");
        self.m_name_icon:setVisible(true)
    end;
    self.m_my_name:getChildByName("modify_txt"):setText("");
    -- 我的消息
--    local num = GameCacheData.getInstance():getInt(GameCacheData.NOTICE_NUM..UserInfo.getInstance():getUid(),0);
--    local notice_str = "";
--    if num > 0 then
--        notice_str = string.format("+%d新消息",num);
--    end
--    self.m_my_notice:getChildByName("content"):setText(notice_str);

    -- 个性装扮
    --self.m_my_setting:getChildByName("content"):setText();
    -- 我的性别
    self.m_my_sexual:getChildByName("content"):setText(UserInfo.getInstance():getSexString());
    self.m_sexType = UserInfo.getInstance():getSex() or 0;
    -- 我的地区
    self.m_my_region:getChildByName("content"):setText(UserInfo.getInstance():getProvinceName());
    -- 我的签名
    local str = UserInfo.getInstance():getSignAture()
    if not str or str == "" then
        str = "这个家伙很懒，什么都没有留下"
    end
    local len = ToolKit.utfstrlen(str)
    if len > 7 then
        str = ToolKit.utf8_sub(str,1,7) .. "..."
    end
    self.m_my_sign:getChildByName("content"):setText(str)
    -- 礼物数量
    local tab = UserInfo.getInstance():getGift() or {}
    local num = 0
    for k,v in pairs(tab) do
        if v then
            num = num + tonumber(v)
        end
    end
    self.m_my_gift:getChildByName("content"):setText(num)

    local frameRes = UserSetInfo.getInstance():getFrameRes();
    self.m_vip_frame:setVisible(frameRes.visible);
    local fw,fh = self.m_vip_frame:getSize();
    if frameRes.frame_res then
        self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
    end

    --更新绑定按钮状态
    if isLoginSuccess then
        self:updateBindView();
    else
        self:updateBindItemStatus();
    end

--    self:setBtnClick();
--    local offset = self.m_scroll_view:getRegularOffsetRange();
--    print_string("--------------------------->" .. offset);
end

---- 拉取好友排行
--OwnScene.getFriendsRank = function(self)
--    self:requestCtrlCmd(OwnController.s_cmds.getFriendsRank);
--end

--function OwnScene:setBtnClick()


--end

-- 是否来自邮件修改用户昵称 
OwnScene.showModifyUserMnick = function(self)
    if UserInfo.getInstance():getModifyMnick() then
        UserInfo.getInstance():setModifyMnick(false);
        ToolKit.schedule_once(self,function() 
            self:showEditTextGlobal();
        end,1000);
    end;
end;

--------------------- click ------------------
OwnScene.onBackBtnClick = function(self)
    Log.i("OwnScene.onBackBtnClick");
    self:requestCtrlCmd(OwnController.s_cmds.onBack);
end

--OwnScene.onMallBtnClick = function(self)
--    self:requestCtrlCmd(OwnController.s_cmds.goToMall);
--end

OwnScene.onSetBtnClick = function(self)
    --StateMachine.getInstance():pushState(States.setModel,StateMachine.STYPE_CUSTOM_WAIT);
    if not self.mSetDialog then
        self.mSetDialog = new(SettingDialog2)
    end
    self.mSetDialog:show()
end

OwnScene.onFeedbackBtnClick = function(self)
    if kPlatform == kPlatformIOS then
        StateMachine.getInstance():pushState(States.Feedback,StateMachine.STYPE_CUSTOM_WAIT);
    else
        self:requestCtrlCmd(OwnController.s_cmds.goToFeedback);
    end;
    
end

OwnScene.onShareBtnClick = function(self)
    --StateMachine.getInstance():pushState(States.shareModel,StateMachine.STYPE_CUSTOM_WAIT);
    if not self.mAboutDialog then
        self.mAboutDialog = new(AboutDialog)
    end
    self.mAboutDialog:show()
end

OwnScene.onMyLevelBtnClick = function(self)
    StateMachine.getInstance():pushState(States.gradeModel,StateMachine.STYPE_CUSTOM_WAIT);
end

--OwnScene.onMyNameBtnClick = function(self)
----    StateMachine.getInstance():pushState(States.assetsModel,StateMachine.STYPE_CUSTOM_WAIT);
--end

OwnScene.onMyNoticeBtnClick = function(self)
    GameCacheData.getInstance():saveInt(GameCacheData.NOTICE_NUM..UserInfo.getInstance():getUid(),0);
    StateMachine.getInstance():pushState(States.noticeModel,StateMachine.STYPE_CUSTOM_WAIT);
end

OwnScene.onMyVipSetBtnClick = function(self)
--    self:requestCtrlCmd(OwnController.s_cmds.goToChessFriends);
    StateMachine.getInstance():pushState(States.vipModel,StateMachine.STYPE_CUSTOM_WAIT);
end

--OwnScene.onUserinfoBtnClick = function(self)
--    StateMachine.getInstance():pushState(States.UserInfo,StateMachine.STYPE_CUSTOM_WAIT);
--end
-- 1 好友排行榜 2 粉丝排行榜 3 大师排行榜
--OwnScene.onFriendsRankBtnClick = function(self)
--    StateMachine.getInstance():pushState(States.Rank,StateMachine.STYPE_CUSTOM_WAIT,nil,1);
--end

--OwnScene.onFansRankBtnClick = function(self)
--    StateMachine.getInstance():pushState(States.Rank,StateMachine.STYPE_CUSTOM_WAIT,nil,2);
--end

--OwnScene.onMasterRankBtnClick = function(self)
--    StateMachine.getInstance():pushState(States.Rank,StateMachine.STYPE_CUSTOM_WAIT,nil,3);
--end

function OwnScene:onMyRegionBtnClick()
    if UserInfo.getInstance():getProvinceName() == "" then
        ChessToastManager.getInstance():showSingle("正在获取位置",3000);
        call_native(kGetLocationInfo);
        return;
    end;
    self:showLoacteDialog();
end

function OwnScene:showLoacteDialog()
    if not self.m_locate_city_dialog then
        self.m_locate_city_dialog = new(CityLocatePopDialog);
        self.m_locate_city_dialog:setDismissCallBack(self,self.updateUserInfoView);
    end
    self.m_locate_city_dialog:show();    
end;

require(DIALOG_PATH .. "realNameDialog")
function OwnScene:onMyRealNameBtnClick()
    if self.m_real_name_status == 1 then
        ChessToastManager.getInstance():showSingle("你已成功认证，不需重新绑定证件")
        return 
    elseif self.m_real_name_status == -1 then
        ChessToastManager.getInstance():showSingle("认证状态查询中，请稍后再试")
        return 
    end
    if not self.m_real_name_dialog then
        self.m_real_name_dialog = new(RealNameDialog)
    end
    self.m_real_name_dialog:show()
end

function OwnScene:onMySexualBtnClick()
    if not self.m_select_sex_dialog then
        self.m_select_sex_dialog = new(SelectSexDialog);
    end
    self.m_select_sex_dialog:show();
end

function OwnScene:onMyGiftBtnClick()
    if not self.m_gift_dialog then
        self.m_gift_dialog = new(GiftDialog); 
    end
    self.m_gift_dialog:show();
end

-- 复盘
function OwnScene:onFuPanBtnClick()
    Log.d("OwnScene.onFuPanBtnClick");
    StatisticsManager.getInstance():onCountToUM(HALL_MODEL_REPLAY_BTN);
    TaskScene.s_showReplayDialog()
--    StateMachine.getInstance():pushState(States.Replay,StateMachine.STYPE_CUSTOM_WAIT);
end

function OwnScene:showChangeHeadDialog()
    if not self.m_changeHeadDialog then
        self.m_changeHeadDialog = new(ChangeHeadIconDialog);
        self.m_changeHeadDialog:setConfirmClick(self,self.changeUserIcon);
    end
    self.m_changeHeadDialog:show();
end

function OwnScene:changeUserIcon(iconType,iconName)
    self.m_iconType = iconType;
    self.m_iconName = iconName;
    self:saveUserInfo(true);
end

function OwnScene:saveUserInfo(sysIcon)
    local data = {};
    data.iconType = self.m_iconType or UserInfo.getInstance():getIconType();
    if sysIcon then
        data.icon_url = self.m_iconName or "women_head01.png";
    end;
    self:requestCtrlCmd(OwnController.s_cmds.modifyUserInfo,data);
end
require(DIALOG_PATH .. "changeNameDialog")
function OwnScene:showEditTextGlobal()
    self.inputType = OwnScene.nameModify
--    if tonumber(UserInfo.getInstance():getIsModifyUserMnick()) == 0 then
--        ChessToastManager.getInstance():showSingle("您已不能修改昵称，昵称仅能修改一次",2200);
--        self.m_my_name:getChildByName("modify_txt"):setText("(不可修改)");
--    else
--        EditTextGlobal = self;
--	    ime_open_edit(self.m_my_name:getChildByName("content"):getText(),
--		    "",
--		    kEditBoxInputModeSingleLine,
--		    kEditBoxInputFlagInitialCapsSentence,
--		    kKeyboardReturnTypeDone,
--		    -1,"global");
--    end
    if not self.mChangeNameDialog then
        self.mChangeNameDialog = new(ChangeNameDialog)
    end
    if tonumber(UserInfo.getInstance():getIsModifyUserMnick()) == 0 then
        self.mChangeNameDialog:setTipsNum(UserInfo.getInstance():getModifyUserMnickCost(),true)
        self.mChangeNameDialog:setConfirmCallBack(self,self.contentTextChangeByMoney)
    else
        self.mChangeNameDialog:setTipsNum(UserInfo.getInstance():getModifyUserMnickCost(),false)
        self.mChangeNameDialog:setConfirmCallBack(self,self.contentTextChange)
    end
    self.mChangeNameDialog:show()
end

function OwnScene:contentTextChange(text)
    if type(text) ~= "string" or text == "" or text == UserInfo.getInstance():getName() then return end
    local data = {}
    data.mnick = text
    self:requestCtrlCmd(OwnController.s_cmds.modifyUserInfo,data);
end

function OwnScene:contentTextChangeByMoney(text)
    
    if UserInfo.getInstance():getModifyUserMnickCost() > (tonumber(UserInfo.getInstance():getBccoin()) or 0) then
        local goods = MallData.getInstance():getGoodsByMoreBccoin(UserInfo.getInstance():getModifyUserMnickCost())
        ChessToastManager.getInstance():show("元宝不足")
        if not goods then return end
        local payInterface = PayUtil.getPayInstance(PayUtil.s_defaultType);
	    payInterface:buy(goods);
        return
    end

    if type(text) ~= "string" or text == "" or text == UserInfo.getInstance():getName() then return end
    local data = {}
    data.mnick = text
    self:requestCtrlCmd(OwnController.s_cmds.modifyUserNameByMoney,data)
end

function OwnScene:setText(str, width, height, r, g, b)
    if self.inputType == OwnScene.nameModify then
        self.m_my_name:getChildByName("content"):setText(str,0,0);
    elseif self.inputType == OwnScene.signModify then
        if not str then return end
        local s = str
        local len = ToolKit.utfstrlen(str)
        if len > 15 then
            ChessToastManager.getInstance():showSingle("签名最多15个字！")
            local signstr = UserInfo.getInstance():getSignAture() or ""
            self.m_my_sign:getChildByName("content"):setText(signstr,0,0);
            return
        end
        self.signature = str
        if len > 7 then
            s = ToolKit.utf8_sub(str,1,7) .. "..."
        end
        self.m_my_sign:getChildByName("content"):setText(s,0,0);
    end
end

function OwnScene:onTextChange()
    if self.inputType == OwnScene.nameModify then
        self:contentTextChange(self.m_my_name:getChildByName("content"):getText());
    elseif self.inputType == OwnScene.signModify then
        self:signContentTextChange(self.m_my_sign:getChildByName("content"):getText())
    end
end

function OwnScene.signContentTextChange(self,text)
--    if not text then text = "" end
--    local len = ToolKit.utfstrlen(text)
--    if len > 15 then
--        ChessToastManager.getInstance():showSingle("签名最多15个字！")
--        local str = UserInfo.getInstance():getSignAture() or ""
--        self.m_my_sign:getChildByName("content"):setText(str,0,0);
--        return
--    end
--    self.m_my_sign:getChildByName("content"):setText(text,0,0);
    local data = {}
    data.signature = self.signature
    self:requestCtrlCmd(OwnController.s_cmds.modifyUserInfo,data);
end

function OwnScene:upLoadImage(iconType)
    self.m_iconType = -1;
    self:saveUserInfo();
end

    -- 更新绑定界面
function OwnScene:updateBindView()
--    self.m_bind_list_view:releaseAllViews();
--    delete(self.m_adapter);

    local bindtab = self:updateBindType();
    local num = 0;
    if bindtab and #bindtab ~= 0 then
        num = #bindtab;
    end
    if num == 0 then
        self.m_my_real_name:getChildByName("line_img"):setVisible(false)
    end
    self.m_line_bg:setSize(OwnSceneBindItem.ITEM_WIDTH,(num+1) * OwnSceneBindItem.ITEM_HEIGHT);

    if type(self.bindTabitem) == "table" then
        for k,v in pairs(self.bindTabitem) do
            delete(v)
        end
    end
    self.bindTabitem = {};

    for i = 1,num do 
        if bindtab[i].accountType then
            self.bindTabitem[i] = new(OwnSceneBindItem,"drawable/blank.png","drawable/blank_press.png",bindtab[i]);
            self.bindTabitem[i]:setAlign(kAlignTop);
            self.bindTabitem[i]:setPos(0, i * OwnSceneBindItem.ITEM_HEIGHT);
            self.bindTabitem[i]:setSize(OwnSceneBindItem.ITEM_WIDTH,OwnSceneBindItem.ITEM_HEIGHT);
            self.bindTabitem[i]:setOnClick(self,function()
                self:onItemClick(bindtab[i].accountType);
            end);
--            self.bindTabitem[i]:setSrollOnClick();
            self.m_bind_view:addChild(self.bindTabitem[i]);
        end
    end
--    self.m_adapter = new(CacheAdapter,OwnSceneBindItem,bindtab);
--    self.m_bind_list_view:setAdapter(self.m_adapter);
--    self.m_bind_list_view:setSize(OwnSceneBindItem.ITEM_WIDTH,num * OwnSceneBindItem.ITEM_HEIGHT);
    --self.m_bind_view:setSize(720,(num+1) * OwnSceneBindItem.ITEM_HEIGHT);
    self.m_bind_view:setSize(OwnSceneBindItem.ITEM_WIDTH,(num+1) * OwnSceneBindItem.ITEM_HEIGHT);
    local x,y = self.m_bind_view:getPos();
    self.m_scroll_menu:setPos(x,y + 10 + (num+1) * OwnSceneBindItem.ITEM_HEIGHT);
     if kPlatform == kPlatformIOS then
        local newMenuX, newMenuY = self.m_scroll_menu:getPos();
        local bindW, bindH = self.m_bind_view:getSize();
         if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
             self.m_scroll_menu:setPos(nil,newMenuY);
             self.m_bind_view:setVisible(true);
         else
            self.m_scroll_menu:setPos(nil,newMenuY - bindH);
            self.m_bind_view:setVisible(false);
         end;
     end;
    self.m_scroll_view:updateScrollView();

--    local a = self.m_scroll_view:getFrameLength();
--    local b = self.m_scroll_view:getViewLength();
--    print_string("a---------------------> " .. a .. "   b---------------------->" .. b);

end

function OwnScene:updateBindType()
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

--    for k,v in pairs(bindTab) do
--        v.handler = self;
--    end

    return bindTab;
end


function OwnScene:showBindPhoneDialog()
    delete(self.m_bind_phone_dialog);
    self.m_bind_phone_dialog = new(BangDinDialog);
    self.m_bind_phone_dialog:setHandler(self)
    self.m_bind_phone_dialog:show();
end

function OwnScene:bindWeibo()
    dict_set_string(kLoginMode,kLoginMode..kparmPostfix,0);
	call_native(kLoginWithWeibo);
    if System.getPlatform() == kPlatformWin32 then
        local post_data = {};
        post_data.bind_uuid = "win32Test";
        post_data.mid = UserInfo.getInstance():getUid();
        post_data.sid = ThirdPartyLoginProxy.s_sid.xinlang;
        HttpModule.getInstance():execute(HttpModule.s_cmds.bindUid,post_data,"绑定中...");
    end
end

function OwnScene:bindWeChat()
    call_native(kLoginWeChat);
    if System.getPlatform() == kPlatformWin32 then
        local post_data = {};
        post_data.bind_uuid = "win32Test";
        post_data.mid = UserInfo.getInstance():getUid();
        post_data.sid = ThirdPartyLoginProxy.s_sid.weichat;
        HttpModule.getInstance():execute(HttpModule.s_cmds.bindUid,post_data,"绑定中...");
    end
end
--[[
    重新绑定dialog
--]]
function OwnScene:removeBind(accounttype)
    if not self.m_remove_bind_dialog then
        self.m_remove_bind_dialog = new(RemoveBindDialog);
    end
    self.m_remove_bind_dialog:setAccountType(accounttype);
    self.m_remove_bind_dialog:setRebindCallBack(self,self.showBindPhoneDialog);
    self.m_remove_bind_dialog:show();
end

function OwnScene:onItemClick(accountType)
    if UserInfo.getInstance():findBindAccountBySid(accountType) then
        --解除绑定
        self:removeBind(accountType);
    else
        --绑定
        if accountType == 201 or accountType == 1 then
            self:showBindPhoneDialog();
        elseif accountType == 3 then
            self:bindWeChat();
        elseif accountType == 10 then
            self:bindWeibo();
        end
    end
end

function OwnScene.updateBindItemStatus(self,data)
    if self.bindTabitem and next(self.bindTabitem) == nil then return end 
    for k,v in pairs(self.bindTabitem) do
        if v then
            v:onUpdateBindStatus()
        end
    end
end

OwnScene.onEventResponse = function(self, cmd, data)
    if cmd == kGetProvinceCode then -- 定位
        self:onGetLocationInfo(data);
    end;
end;

function OwnScene:onGetLocationInfo(data)
    if data and next(data) and data.province and data.city then
        local province = data.province:get_value();
        local city = data.city:get_value();
        local provinceCode = 0;
        local provinceName = "";
        local provinceData = CityData.getInstance():getProvinceData();
        if provinceData and #provinceData > 0 then
            for i = 1,#provinceData do
                if string.find(province,provinceData[i].name) then
                    provinceCode = provinceData[i].code;
                    provinceName = provinceData[i].name;
                    break;
                elseif i == #provinceData then
                    provinceCode = provinceData[i].code;
                    provinceName = provinceData[i].name;
                    break;
                end;
            end;
            UserInfo.getInstance():setProvinceCode(provinceCode);
            UserInfo.getInstance():setProvinceName(provinceName);
        end;
        -- 定位成功
        ChessToastManager.getInstance():showSingle("定位成功:"..province..city);
        self.m_my_region:getChildByName("content"):setText(UserInfo.getInstance():getProvinceName());
    else
        self:showLoacteDialog();
    end;
end


OwnScene.onShowDailyTask = function(self)
    local newData = DailyTaskData.getInstance():getDailySignData()
    if newData then
        DailyTaskManager.getInstance():unregister(self,self.onShowDailyTask);
    end
    if DailyTaskData.getInstance():getSignShowStatus() then
        delete(self.m_dailyTask);
        self.m_dailyTask = nil;
        self.m_dailyTask =new(DailySignDialog);
        self.m_dailyTask:updataSignScrollView(newData)
        self.m_dailyTask:getActionList()
        self.m_dailyTask:show();
    end
end

function OwnScene:registerShowDailyTask()
 -- 避免重复注册
    DailyTaskManager.getInstance():unregister(self,self.onShowDailyTask)
    DailyTaskManager.getInstance():register(self,self.onShowDailyTask)
end
---------------------- config ------------------
OwnScene.s_controlConfig = 
{

    [OwnScene.s_controls.scroll_view]              = {"new_style_view","content_view","scroll_view"};
    --[OwnScene.s_controls.top_cloth]                = {"top_cloth"};
    [OwnScene.s_controls.head_icon_btn]            = {"new_style_view","content_view","head_icon_btn"};
    --[OwnScene.s_controls.user_name]                = {"top_cloth","user_name"};
    [OwnScene.s_controls.login_type]               = {"new_style_view","content_view","login_type_bg","login_type"};
    [OwnScene.s_controls.userinfo_view]            = {"new_style_view","content_view","scroll_view","userinfo_view"};
    [OwnScene.s_controls.my_uid]                   = {"new_style_view","content_view","scroll_view","userinfo_view","my_uid"};
    [OwnScene.s_controls.my_level]                 = {"new_style_view","content_view","scroll_view","userinfo_view","my_level"};
    [OwnScene.s_controls.my_name]                  = {"new_style_view","content_view","scroll_view","userinfo_view","my_name"};
--    [OwnScene.s_controls.my_notice]                = {"scroll_view","userinfo_view","my_notice"};
    [OwnScene.s_controls.my_setting]               = {"new_style_view","content_view","scroll_view","userinfo_view","my_setting"};
    
    --[OwnScene.s_controls.btn_fupan]                = {"scroll_view","info_view","btn_fupan"};
    [OwnScene.s_controls.menu]                     = {"new_style_view","content_view","scroll_view","menu"};
    [OwnScene.s_controls.set_btn]                  = {"new_style_view","content_view","scroll_view","menu","set_btn"};
    [OwnScene.s_controls.feedback_btn]             = {"new_style_view","content_view","scroll_view","menu","feedback_btn"};
    [OwnScene.s_controls.share_btn]                = {"new_style_view","content_view","scroll_view","menu","share_btn"};
    --[OwnScene.s_controls.bottom_menu]              = {"bottom_menu"};
    [OwnScene.s_controls.switch_account]           = {"new_style_view","switch_account"};
    [OwnScene.s_controls.info_view]                = {"new_style_view","content_view","scroll_view","info_view"};
    [OwnScene.s_controls.my_gift]                  = {"new_style_view","content_view","scroll_view","info_view","my_gift"};
    [OwnScene.s_controls.my_sexual]                = {"new_style_view","content_view","scroll_view","info_view","my_sexual"};
    [OwnScene.s_controls.my_region]                = {"new_style_view","content_view","scroll_view","info_view","my_region"};
    [OwnScene.s_controls.sign_btn]                 = {"new_style_view","content_view","scroll_view","info_view","my_sign"};

    [OwnScene.s_controls.bind_view]                = {"new_style_view","content_view","scroll_view","bind_view"};
    [OwnScene.s_controls.my_real_name]             = {"new_style_view","content_view","scroll_view","bind_view","my_real_name"};
    [OwnScene.s_controls.back_btn] = {"new_style_view","back_btn"};
    [OwnScene.s_controls.content_view] = {"new_style_view","content_view"};
}

OwnScene.s_controlFuncMap = {
    
    [OwnScene.s_controls.set_btn]                      = OwnScene.onSetBtnClick;
    [OwnScene.s_controls.feedback_btn]                 = OwnScene.onFeedbackBtnClick;
    [OwnScene.s_controls.share_btn]                    = OwnScene.onShareBtnClick;
    [OwnScene.s_controls.my_level]                     = OwnScene.onMyLevelBtnClick;
--    [OwnScene.s_controls.my_name]                      = OwnScene.onMyNameBtnClick;
    [OwnScene.s_controls.my_name]                      = OwnScene.showEditTextGlobal;
--    [OwnScene.s_controls.my_notice]                    = OwnScene.onMyNoticeBtnClick;
    [OwnScene.s_controls.my_setting]                   = OwnScene.onMyVipSetBtnClick;
--    [OwnScene.s_controls.head_icon_btn]                = OwnScene.onUserinfoBtnClick;
    [OwnScene.s_controls.head_icon_btn]                = OwnScene.showChangeHeadDialog;
    [OwnScene.s_controls.my_region]                    = OwnScene.onMyRegionBtnClick;
    [OwnScene.s_controls.my_real_name]                 = OwnScene.onMyRealNameBtnClick;
    [OwnScene.s_controls.my_sexual]                    = OwnScene.onMySexualBtnClick;
    [OwnScene.s_controls.my_gift]                      = OwnScene.onMyGiftBtnClick;
    --[OwnScene.s_controls.btn_fupan]                    = OwnScene.onFuPanBtnClick;
    [OwnScene.s_controls.back_btn] = OwnScene.onBackBtnClick;
};

OwnScene.s_cmdConfig =
{
    [OwnScene.s_cmds.updateUserInfoView]                = OwnScene.updateUserInfoView;
    [OwnScene.s_cmds.upLoadImage]                       = OwnScene.upLoadImage;
    [OwnScene.s_cmds.updateUserHead]                    = OwnScene.updateUserHeadIcon;
    [OwnScene.s_cmds.updateRealName]                    = OwnScene.updateRealName;
    [OwnScene.s_cmds.registerShowDailyTask]             = OwnScene.registerShowDailyTask
}

OwnSceneBindItem = class(Button,false);

OwnSceneBindItem.DEFAULT_ICON = 
{
    [1]  = "common/icon/phone.png", 
    [3]  = "common/icon/wechat.png", 
    [10] = "common/icon/weibo.png",
}

OwnSceneBindItem.DEFAULT_TYPE = 
{
    [1]  = "手机", 
    [3]  = "微信", 
    [10] = "微博",
}

OwnSceneBindItem.ITEM_WIDTH = 588;
OwnSceneBindItem.ITEM_HEIGHT = 80;

OwnSceneBindItem.ctor = function(self,normalFile, disableFile,data)
    super(self,normalFile, disableFile);
--    if not data then return end
--    self.m_handler = data.handler;
    self.accountType = data.accountType;
--    if not self.accountType then return end
--    self:setSize(OwnSceneBindItem.ITEM_WIDTH,OwnSceneBindItem.ITEM_HEIGHT);

    --item点击按钮
--    self.m_button = new(Button,"drawable/blank.png","drawable/blank_press.png");
--    self.m_button:setSize(590,70);
--    self.m_button:setAlign(kAlignCenter);
--    self.m_button:setOnClick(self,self.onItemClick);
--    self.m_button:setSrollOnClick();
    --图标
    local imgStr = "common/icon/phone.png";
    imgStr = OwnSceneBindItem.DEFAULT_ICON[self.accountType];
    self.m_iconType = new(Image,imgStr);
    self.m_iconType:setSize(52,52);
    self.m_iconType:setAlign(kAlignLeft);
    self.m_iconType:setPos(29,0);
    --bottom line
    self.m_bottom_line = new(Image,"common/decoration/line_2.png");
    self.m_bottom_line:setSize(590,2);
    self.m_bottom_line:setAlign(kAlignBottom);
    --绑定类型text
    local msg = "手机";
    msg = OwnSceneBindItem.DEFAULT_TYPE[self.accountType];
    self.m_bing_type = new(Text,msg,72,36,nil,nil,36,135,100,95);
    self.m_bing_type:setAlign(kAlignLeft);
    self.m_bing_type:setPos(100,2);
    --箭头图标
    self.m_arrow = new(Image,"common/icon/arrow_r.png");
    self.m_arrow:setSize(14,25);
    self.m_arrow:setAlign(kAlignRight);
    self.m_arrow:setPos(21,0);
    --绑定状态
--    self.bindStatus = false;
    local bindStatusText = "未绑定";
    local num = UserInfo.getInstance():findBindAccountBySid(self.accountType);
    if num then
--        self.bindStatus = true;
        bindStatusText = "已绑定";
    else
--        self.bindStatus = false;
        bindStatusText = "未绑定";
    end
        self.title = new(Text,bindStatusText,64,30,kAlignRight,nil,32,80,80,80);
        self.title:setAlign(kAlignRight);
        self.title:setPos(68,0);

    self:setSrollOnClick(function()
        print_string("setSrollOnClick");
    end);

    self:addChild(self.title);
    self:addChild(self.m_bing_type);
    self:addChild(self.m_bottom_line);
    self:addChild(self.m_iconType);
--    self:addChild(self.m_button);
    self:addChild(self.m_arrow);
end

OwnSceneBindItem.dtor = function(self)

end

function OwnSceneBindItem.onUpdateBindStatus(self)
    local bindStatusText = "未绑定";
    local num = UserInfo.getInstance():findBindAccountBySid(self.accountType);
    if num then
--        self.bindStatus = true;
        bindStatusText = "已绑定";
    else
--        self.bindStatus = false;
        bindStatusText = "未绑定";
    end
    self.title:setText(bindStatusText)
end

--OwnSceneBindItem.onItemClick = function(self)
--    if self.bindStatus then
--        --解除绑定
--        self.m_handler:removeBind(self.accountType);
--    else
--        --绑定
--        if self.accountType == 201 or self.accountType == 1 then
--            self.m_handler:showBindPhoneDialog();
--        elseif self.accountType == 3 then
--            self.m_handler:bindWeChat();
--        elseif self.accountType == 10 then
--            self.m_handler:bindWeibo();
--        end
--    end
--end