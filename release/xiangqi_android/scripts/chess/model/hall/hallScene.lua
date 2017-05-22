require(BASE_PATH.."chessScene");
require("dialog/chioce_dialog");
require("dialog/more_setting_dialog");
require("dialog/hall_chat_dialog");
require("dialog/report_dialog");
require("dialog/union_dialog");
require("dialog/daily_sign_dialog");
require("chess/include/bottomMenu");
require(DATA_PATH.."settingInfo");
HallScene = class(ChessScene);

HallScene.s_controls = 
{
	name                    = 1;
    level_img               = 2;
    money_view              = 3;
    more_btn                = 4;
    online_btn              = 5;
    endgate_btn             = 6;
    console_btn             = 7;
    dapu_btn                = 8;
    bottom_menu             = 9;
    hall_switch_server      = 10;
    hall_version            = 11;
    icon_frame_mask         = 12;
    userinfo_view           = 13;
    logo                    = 14;
    content_view            = 15;
    hall_chat_btn           = 16;
    activity_btn            = 17;
    hall_union_btn          = 18;
    add_money_btn           = 19;
    quick_play_btn          = 20;
    friends_btn             = 21;
    more_btn_bg             = 22;
}

HallScene.s_cmds = 
{
    update_user_money       = 1;
    show_daily_task_dialog  = 2;
    show_exit_dlg           = 3;
    has_playing_game        = 4;
    update_online_num       = 5;
    update_unread_msg       = 6;
    --第一次登陆弹出引导界面
    show_guide_dialog       = 7;
    --账号完善引导
    show_account_dialog     = 8;
    entry_chat_room         = 9;
    --每日首次登陆领取奖励
    dailyTask               = 10;
    --更新每日任务
    updateDailyTaskDialog   = 11;
    show_start_dialog     = 12;
    
    updata_union_dialog     = 13;
    updata_union_member     = 14;
    ios_audit_status        = 15;
}

HallScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = HallScene.s_controls;
    self:init();
end 

HallScene.resume = function(self)
    ChessScene.resume(self);
    self:reset();
    if GameData.getInstance():getGetDailyTask() then
        self:showDailyTask();
    end
--    self:resumeAnimStart();
    DailyTaskManager.getInstance():register(self,self.onShowDailyTask);
    BottomMenu.getInstance():onResume(self.m_bottom_menu,self.bottomMove);
    BottomMenu.getInstance():setHandler(self,1);
    BottomMenu.getInstance():setMyGameStatus();

end


HallScene.pause = function(self)
	ChessScene.pause(self);
    self:removeAnimProp();
--    self:pauseAnimStart();
    DailyTaskManager.getInstance():unregister(self,self.onShowDailyTask);
    BottomMenu.getInstance():onPause();
    MoreSettingDialog.getInstance():dismiss();

end 


HallScene.dtor = function(self)
    delete(self.leaveTipsDialog);
    delete(self.m_moreSettingDialog);
    delete(self.chioce_dialog);
    delete(self.notice_dialog);
    delete(self.newYearDialog);
    delete(self.m_union_dialog);
end 

----------------------------------- function ----------------------------
HallScene.init = function(self)
    Log.d("HallScene.init");
    self.bottomMove = false;

    self:ininUserInfo();
    self:initSwitchServer();
    self.m_version = self:findViewById(self.m_ctrls.hall_version);
    self.m_version:setText("v"..kLuaVersion);

    self.m_bottom_menu = self:findViewById(self.m_ctrls.bottom_menu);
    self.m_userinfo_view = self:findViewById(self.m_ctrls.userinfo_view);
    self.m_quickPlayBtn = self:findViewById(self.m_ctrls.quick_play_btn);
    self.m_content_view = self:findViewById(self.m_ctrls.content_view);
    self.m_more_btn_bg = self:findViewById(self.m_ctrls.more_btn_bg);
    self.m_more_btn = self:findViewById(self.m_ctrls.more_btn);
    -- hall_chat_btn
    self.m_hall_chat_btn = self:findViewById(self.m_ctrls.hall_chat_btn);
    self.m_hall_unread_msg = self.m_hall_chat_btn:getChildByName("hall_chat_unread_msg");
    self.m_hall_union_btn = self:findViewById(self.m_ctrls.hall_union_btn);
    -- animation part
    self.m_root_view = self.m_root;
    self.m_leaf_left = self.m_root_view:getChildByName("leaf_left");    -- left leaf
    self.m_leaf_right = self.m_root_view:getChildByName("leaf_right");  -- right leaf
    self.m_userinfo_view_bg = self.m_userinfo_view:getChildByName("userinfo_view_bg");   -- user bg
    self.m_icon_frame_stroke = self.m_userinfo_view:getChildByName("icon_frame_stroke"); -- icon bg
    self.m_vip_frame = self.m_icon_frame_stroke:getChildByName("vip_frame");
    self.m_switch_user_img = self.m_icon_frame_stroke:getChildByName("Image1");
    self.m_online_btn = self:findViewById(self.m_ctrls.online_btn);
    self.m_endgate_btn = self:findViewById(self.m_ctrls.endgate_btn);
    self.m_console_btn = self:findViewById(self.m_ctrls.console_btn);
    self.m_dapu_btn = self:findViewById(self.m_ctrls.dapu_btn);
    if kPlatform == kPlatformIOS then
        self.m_hall_activity_btn = self:findViewById(self.m_ctrls.activity_btn);
        -- ios 审核关闭大厅聊天和更多，版本号
        if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
            self.m_version:setVisible(true);
            self.m_hall_chat_btn:setVisible(true);
            self.m_more_btn_bg:setVisible(true);
            self.m_hall_union_btn:setVisible(true);
            self.m_hall_activity_btn:setVisible(true);
            self.m_switch_user_img:setVisible(true);
        else
            self.m_version:setVisible(false);
            self.m_hall_chat_btn:setVisible(false);
            self.m_more_btn_bg:setVisible(false);
            self.m_hall_union_btn:setVisible(false);
            self.m_hall_activity_btn:setVisible(false);
            self.m_switch_user_img:setVisible(false);
        end;
    end;


    self:removeInitAnimProp();
    self:initAnim();
end

HallScene.removeInitAnimProp = function(self)
    if self.m_anim_prop_need_remove then
        self.m_anim_prop_need_remove = false;
        self.m_leaf_left:removeProp(1);
--        self.m_leaf_left:removeProp(2);
        self.m_leaf_right:removeProp(1);
--        self.m_leaf_right:removeProp(2);
        self.m_userinfo_view_bg:removeProp(1);
        self.m_icon_frame_stroke:removeProp(1);
        self.m_icon_frame_stroke:removeProp(2);
        self.m_more_btn:removeProp(1);
        self.m_more_btn:removeProp(2);
        self.m_quickPlayBtn:removeProp(1);
        self.m_hall_chat_btn:removeProp(1);
        self.m_hall_union_btn:removeProp(1);

        self.m_bottom_menu:removeProp(1);
        self.m_online_btn:removeProp(1);
        self.m_online_btn:removeProp(2);
        self.m_endgate_btn:removeProp(1);
        self.m_endgate_btn:removeProp(2);
        self.m_console_btn:removeProp(1);
        self.m_console_btn:removeProp(2);
        self.m_dapu_btn:removeProp(1);
        self.m_dapu_btn:removeProp(2);
    end
end

HallScene.initAnim = function(self)

   --竹叶动画
   local duration = 900;
   local delay = -1;
   --延时1s播放动画，防止进游戏卡
   if is_open and is_open == 1 then
        delay = 1000;
   end
   local lw,lh = self.m_leaf_left:getSize();
   self.m_leaf_left:addPropTranslate(1,kAnimNormal,duration,delay,- lw,0,-30,0);
--   self.m_leaf_left:addPropTransparency(2,kAnimNormal,duration,delay,0,1);

   local rw,rh = self.m_leaf_right:getSize();
   self.m_leaf_right:addPropTranslate(1,kAnimNormal,duration,delay,rw,0,-30,0);
--   self.m_leaf_right:addPropTransparency(2,kAnimNormal,duration,delay,0,1);

   --顶部动画
   self.m_userinfo_view_bg:addPropScale(1,kAnimNormal,280,delay,0,1,1,1,kCenterDrawing);
   self.m_icon_frame_stroke:addPropTransparency(2,kAnimNormal,240,delay,0.5,1);
   local top_anim3 = self.m_icon_frame_stroke:addPropScale(1,kAnimNormal,240,-1,0.8,1.1,0.8,1.1,kCenterDrawing);
   top_anim3:setEvent(self,function()
        self.m_icon_frame_stroke:removeProp(1);
        self.m_icon_frame_stroke:removeProp(2);
        delete(top_anim3);
   end);

   local tw,th = self.m_more_btn:getSize();
   self.m_more_btn:addPropScale(2,kAnimNormal,10,delay,1,1,0.9,1.1,kCenterDrawing);
   local top_anim4 = self.m_more_btn:addPropTranslate(1, kAnimNormal, 240, delay, 0, 0, -th, 0);
   top_anim4:setEvent(self,function()
        self.m_more_btn:removeProp(2);
        self.m_more_btn:removeProp(1);
        delete(top_anim4);
   end);

   --m_quickPlayBtn动画
   local btn_w,btn_h = self.m_hall_chat_btn:getSize();
   self.m_hall_chat_btn:addPropTranslate(1,kAnimNormal,200,300 + delay,-btn_w,0,0,0);

   local ubtn_w,ubtn_h = self.m_hall_union_btn:getSize();
   self.m_hall_union_btn:addPropTranslate(1,kAnimNormal,200,300 + delay,-ubtn_w,0,0,0);

   local quickPlayBtn_anim1 = self.m_quickPlayBtn:addPropScale(1,kAnimNormal,200,300 + delay,0,1.1,0,1.2,kCenterDrawing);
   quickPlayBtn_anim1:setEvent(self,function()
        self.m_quickPlayBtn:removeProp(1);
        delete(quickPlayBtn_anim1);
   end);

   --下部动画
   local bw,bh = self.m_bottom_menu:getSize();
   self.m_bottom_menu:addPropTranslate(1, kAnimNormal, 420, 200 + delay, 0, 0, bh, 0);

   --中间动画
   local cw,ch = self.m_online_btn:getSize();
   self.m_online_btn:addPropTransparency(2,kAnimNormal,410,390 + delay,0,1);
    self.m_online_btn:addPropScale(1,kAnimNormal,400,400 + delay,0.8,1,0.7,1,kCenterXY,220,330);

   self.m_endgate_btn:addPropTransparency(2,kAnimNormal,410,500 + delay,0,1);
   self.m_endgate_btn:addPropScale(1,kAnimNormal,400,510 + delay,0.8,1,0.7,1,kCenterXY,20,330);

   self.m_console_btn:addPropTransparency(2,kAnimNormal,410,590 + delay,0,1);
   self.m_console_btn:addPropScale(1,kAnimNormal,400,600 + delay,0.8,1,0.7,1,kCenterXY,220,330);

   local anim_end = self.m_dapu_btn:addPropTransparency(2,kAnimNormal,410,680 + delay,0,1);
   self.m_dapu_btn:addPropScale(1,kAnimNormal,400,690 + delay,0.8,1,0.7,1,kCenterXY,20,300);

    self.m_anim_prop_need_remove = true;
   anim_end:setEvent(self,function()
        self:removeInitAnimProp();
        delete(anim_end);
   end);
end

HallScene.removeAnimProp = function(self)
    if self.m_anim_prop_need_remove then
        self.m_leaf_left:removeProp(1);
        self.m_leaf_right:removeProp(1);
        self.m_anim_prop_need_remove = false
    end
end

HallScene.setAnimItemEnVisible = function(self,ret)
    self.m_leaf_left:setVisible(ret);
    self.m_leaf_right:setVisible(ret);
end

HallScene.resumeAnimStart = function(self,lastStateObj,timer)
--     self.m_root:removeProp(1);
     if typeof(lastStateObj,FindState) or typeof(lastStateObj,OwnState) then
        self.bottomMove = false;
     else
        self.bottomMove = true;
        BottomMenu.getInstance():hideView(true);
        BottomMenu.getInstance():removeOutWindow(0,timer);
     end
     self.m_anim_prop_need_remove = true;
     self:removeAnimProp();
    local duration = timer.waitTime;
    local delay = timer.duration + duration;

--    local w,h = self:getSize();
--    self.m_root:addPropTranslate(1,kAnimNormal,timer.duration,duration,-w,0,nil,nil);
    delete(self.m_anim_start);
    self.m_anim_start = new(AnimInt,kAnimNormal,0,1,delay);
    if self.m_anim_start then
        self.m_anim_start:setEvent(self,function()
            self:setAnimItemEnVisible(true);
            delete(self.m_anim_start);
        end);
    end

    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1,kAnimNormal,duration,delay,- lw,0,-30,0);
    local rw,rh = self.m_leaf_right:getSize();
    local right_anim1 = self.m_leaf_right:addPropTranslate(1,kAnimNormal,duration,delay,rw,0,-30,0);
    if right_anim1 then
        right_anim1:setEvent(self,function()
            self.m_anim_prop_need_remove = true;
            self:removeAnimProp();
--            if not self.m_root:checkAddProp(1) then 
--		        self.m_root:removeProp(1);
--	        end
            delete(right_anim1);
        end);
    end
end

HallScene.pauseAnimStart = function(self,newStateObj,timer)
--    self.m_root:removeProp(1);
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    if typeof(newStateObj,OwnState) or typeof(newStateObj,FindState) then
        
    else
        self.bottomMove = true;
        BottomMenu.getInstance():removeOutWindow(1,timer);
    end

    local duration = timer.waitTime;
    local delay = timer.duration + duration;
--    local w,h = self:getSize();
--    self.m_root:addPropTranslate(1,kAnimNormal,timer.duration,duration,0,-w,nil,nil);
    delete(self.m_anim_end);
    self.m_anim_end = new(AnimInt,kAnimNormal,0,1,delay);
    if self.m_anim_end then
        self.m_anim_end:setEvent(self,function()
            self.m_anim_prop_need_remove = true;
            self:removeAnimProp();
--            if not self.m_root:checkAddProp(1) then 
--		        self.m_root:removeProp(1);
--	        end
            if self.bottomMove == true then
                BottomMenu.getInstance():hideView();
            end
        end);
    end

    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1,kAnimNormal,duration,-1,0,-lw,0,-30);
    local rw,rh = self.m_leaf_right:getSize();
    local anim = self.m_leaf_right:addPropTranslate(1,kAnimNormal,duration,-1,0,rw,0,-30);
    if anim then
        anim:setEvent(self,function()
            self:setAnimItemEnVisible(false);
            delete(anim);
        end);
    end
end

HallScene.reset = function(self)
    self:resetUserInfo();
end


HallScene.showDailyTask = function(self)
    GameData.getInstance():setGetDailyTask(false);
    MoreSettingDialog.getInstance():showDailyTask();
end

HallScene.changeUnreadMsgNum = function(self, flag)
    Log.d("HallScene.changeUnreadMsgNum");
    self.m_hall_unread_msg:setVisible(flag);
end;

HallScene.initSwitchServer = function(self)
    Log.d("HallScene.initSwitchServer");
    self.m_switchServer = self:findViewById(self.m_ctrls.hall_switch_server)
    self.m_switchText = self.m_switchServer:getChildByName("switch_text");
    self.m_switchServer:setVisible(kDebug or false);
    self.m_switchServer:setOnClick(self, self.hallSwitchServer);
    self.m_switchText:setText("当前测试服");
end

HallScene.hallSwitchServer = function(self)
--    if true then
--        return 
--    end
    local isDebug = UserInfo.getInstance():getDebugMode();
    if isDebug then
       
        self.m_switchText:setText("当前测试服");
        UserInfo.getInstance():setDebugMode(false);
        PhpConfig.new_developUrl = PhpConfig.new_developTest;
        PhpConfig.h5_developUrl = PhpConfig.h5_developTest;
        PhpConfig.setDevelopUrl(PhpConfig.developTest);
        PhpConfig.setMid(0);
        PhpConfig.setMtkey();
        PhpConfig.setUid(0);
        HttpModule.m_switchFlag = true;
    else
        self.m_switchText:setText("当前正式服");
        UserInfo.getInstance():setDebugMode(true);
        PhpConfig.new_developUrl = PhpConfig.new_developMainUrl;
        PhpConfig.h5_developUrl = PhpConfig.h5_developMainUrl;
        PhpConfig.setDevelopUrl(PhpConfig.developMainUrl);
        PhpConfig.setMid(0);
        PhpConfig.setMtkey();
        PhpConfig.setUid(0);
        HttpModule.m_switchFlag = true;
    end;

    HttpModule.getInstance():releaseInstance();
    HttpModule.s_config = nil;
    HttpModule.initConfig();
--    require("common/httpModule");
    HttpModule.getInstance();
--    HttpManager.setConfigMap(HttpModule.s_config);

    self:requestCtrlCmd(HallController.s_cmds.switch_server);


end;


HallScene.ininUserInfo = function(self)
    Log.d("HallScene.initHeadIcon");
    self.m_name = self:findViewById(self.m_ctrls.name);
    self.m_level_img = self:findViewById(self.m_ctrls.level_img);
    self.m_money_view = self:findViewById(self.m_ctrls.money_view);
    self.m_icon_frame_mask = self:findViewById(self.m_ctrls.icon_frame_mask);
    self.m_icon_frame_mask:setOnClick(self,self.onHeadIconClick);
end


HallScene.resetUserInfo = function(self)
    require(DATA_PATH.."userInfo");
    if self.m_money_view then
        self.m_money_view:removeAllChildren(true);
        local str = UserInfo.getInstance():getMoneyStr();
        local addstr = new(Text,"金币:",nil, nil, kAlignLeft, nil, 30, 80, 80, 80);
        addstr:setAlign(kAlignLeft);
        self.m_money_view:addChild(addstr);
        local x = addstr:getPos();
        local w = addstr:getSize();
        if string.find(str,'W') then
            local addstr = new(Text,string.sub(str,1,-2),nil, nil, kAlignLeft, nil, 28, 175, 55, 55);
            self.m_money_view:addChild(addstr);
            addstr:setAlign(kAlignLeft);
            addstr:setPos(x+w);
            local x = addstr:getPos();
            local w = addstr:getSize();
            local addstr = new(Text,'万',nil, nil, kAlignLeft, nil, 30, 80, 80, 80);
            self.m_money_view:addChild(addstr);
            addstr:setAlign(kAlignLeft);
            addstr:setPos(x+w);
        else
            local addstr = new(Text,str,nil, nil, kAlignLeft, nil, 28, 175, 55, 55);
            self.m_money_view:addChild(addstr);
            addstr:setAlign(kAlignLeft);
            addstr:setPos(x+w);
        end
    end
    if self.m_icon_frame_mask then
        if not self.m_user_head_icon then
            self.m_user_head_icon = new(Mask,UserInfo.DEFAULT_ICON[1],"hall/icon_frame_mask.png");
            self.m_user_head_icon:setSize(self.m_icon_frame_mask:getSize());
            self.m_icon_frame_mask:addChild(self.m_user_head_icon)
            if UserInfo.getInstance():getIconType() == -1 then
                self.m_user_head_icon:setUrlImage(UserInfo.getInstance():getIcon());
            else
                self.m_user_head_icon:setFile(UserInfo.DEFAULT_ICON[UserInfo.getInstance():getIconType()] or UserInfo.DEFAULT_ICON[1]);
            end
        else
            if UserInfo.getInstance():getIconType() == -1 then
                self.m_user_head_icon:setUrlImage(UserInfo.getInstance():getIcon());
            else
                self.m_user_head_icon:setFile(UserInfo.DEFAULT_ICON[UserInfo.getInstance():getIconType()] or UserInfo.DEFAULT_ICON[1]);
            end
        end
--        self.m_root:addChild(icon);
    end
    if self.m_name then
        self.m_name:setText(UserInfo.getInstance():getName());
    end
    if self.m_level_img then
        self.m_level_img:setFile(string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevel()));
    end
--    local is_vip = UserInfo.getInstance():getIsVip();
    local frameRes = UserSetInfo.getInstance():getFrameRes();
    self.m_vip_frame:setVisible(frameRes.visible);
    local fw,fh = self.m_vip_frame:getSize();
    if frameRes.frame_res then
        self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
    end

--    if frameRes.frame_res then
--        if is_vip and is_vip == 1 then
--            self.m_vip_frame:setVisible(true);
--        else
--            self.m_vip_frame:setVisible(false);
--        end
--    end
end

HallScene.showGuideDialog = function(self)
    require("dialog/third_guide_dialog");
    ThirdGuideDialog.getInstance():setHandler(self);
    require("dialog/first_login_guide_dialog");
    if not self.firstLogGuideDialog then
        self.firstLogGuideDialog = new(FirstLogGuideDialog);
--        self.m_secondLogGuideDialog = new(SecondLogGuideDialog);
        self.firstLogGuideDialog:show();
    end
end

HallScene.showAccountDialog = function(self,dialogType)
    require("dialog/modify_info_dialog");
    require("dialog/binding_tip_dialog");
    if kPlatform == kPlatformIOS then
        if tonumber(UserInfo.getInstance():getIosAuditStatus()) == 0 then
            return;
        end;
    end;
    if dialogType == 1 then
        self.modifyInfoDialog = new(ModifyInfoDialog);
        self.modifyInfoDialog:show();
    else
        self.bindTipDialog = new(BindingTipDialog);
        self.bindTipDialog:show();
    end
end

HallScene.showExitDlg = function(self)
    if kPlatform == kPlatformIOS then
    	return;
    end;
    local msg = "亲～明天再来会送您金币，记得来领呦～";
	local isLeaveGame = true;

	if not self.leaveTipsDialog  then
        require("dialog/leave_tips_dialog");
		self.leaveTipsDialog = new(LeaveTipsDialog,isLeaveGame);
	end
	
	self.leaveTipsDialog:setMessage(msg);
	self.leaveTipsDialog:setExitListener(self,self.exitHall)
	self.leaveTipsDialog:setCallsListener(self,self.callsCallBack)
	self.leaveTipsDialog:setCoinsListener(self,self.coinsCallBack)
	self.leaveTipsDialog:setCancelListener(nil,nil)
	self.leaveTipsDialog:show();
end

HallScene.toPointWall = function(self)
    self:requestCtrlCmd(HallController.s_cmds.toPointWall);
end;

HallScene.toAdSdk = function(self)
    self:requestCtrlCmd(HallController.s_cmds.toAdSdk);
end

HallScene.exitHall = function(self)
	print_string("Hall.exitHall");
	local line = "quit";
	dict_set_string(GUI_ENGINE , GUI_ENGINE .. kparmPostfix , line);
	call_native(GUI_ENGINE);
	sys_exit();
end

HallScene.callsCallBack = function(self)
	StateMachine.getInstance():pushState(States.Mall,StateMachine.STYPE_CUSTOM_WAIT);
end

HallScene.coinsCallBack = function(self)
    self:onHallMoreBtnClick();
    MoreSettingDialog.getInstance():showDailyTask();
end

function HallScene:onHallAddMoneyBtnClick()
	StateMachine.getInstance():pushState(States.Mall,StateMachine.STYPE_CUSTOM_WAIT);
end

function HallScene:onHallFriendsBtnClick()
	StateMachine.getInstance():pushState(States.Friends,StateMachine.STYPE_CUSTOM_WAIT);
end

function HallScene:onHallQuickPlayBtnClick()
    self:requestCtrlCmd(HallController.s_cmds.quickPlay);
end

function HallScene:onGuideCallBack(stateType)
	if not stateType then return end
    StateMachine.getInstance():pushState(stateType,StateMachine.STYPE_CUSTOM_WAIT);
end

function HallScene:onActivityBtnClick(status)
	StateMachine.getInstance():pushState(States.activity,StateMachine.STYPE_CUSTOM_WAIT,nil,status);
end

----------------------------------- onClick ---------------------------------

HallScene.onHeadIconClick = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
    require("dialog/notice_dialog");
    require("dialog/union_dialog");
    if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
        Log.d("HallScene.onHeadIconClick");
        self:requestCtrlCmd(HallController.s_cmds.userInfo);
--        if not self.m_union_dialog then
--            self.m_union_dialog = new(UnionDialog,self);
--        end
--        self.m_union_dialog:show();
    end

    


end

HallScene.onHallOnlineBtnClick = function(self)
    Log.d("HallScene.onHallOnlineBtnClick");
    self:requestCtrlCmd(HallController.s_cmds.onlineChess);
end

HallScene.onHallConsoleBtnClick = function(self)
    Log.d("HallScene.onHallConsoleBtnClick");
    self:requestCtrlCmd(HallController.s_cmds.consoleChess);
end

HallScene.onHallEndingBtnClick = function(self)
    Log.d("HallScene.onHallEndingBtnClick");
    self:requestCtrlCmd(HallController.s_cmds.endgateChess);
end

HallScene.onHallReplayBtnClick = function(self)
    Log.d("HallScene.onHallReplayBtnClick");
    self:requestCtrlCmd(HallController.s_cmds.replayChess);
end;



HallScene.onHallUserMoneyBtnClick = function(self)
    Log.d("HallScene.onHallUserMoneyBtnClick");
    self:requestCtrlCmd(HallController.s_cmds.mall);
end

HallScene.onHallFriendMsgBtnClick = function(self)
	Log.d("HallScene.onHallFriendMsgBtnClick");
	self:requestCtrlCmd(HallController.s_cmds.friendMsg);   

end;

HallScene.onHallUserFriendsBtnClick = function(self)
    Log.d("HallScene.onHallUserFeedbackBtnClick");
    self:requestCtrlCmd(HallController.s_cmds.friends);
end
-- 大厅聊天界面
HallScene.onHallChatBtnClick = function(self)
   Log.d("HallScene.onHallChatBtnClick");
   if not self:requestCtrlCmd(HallController.s_cmds.isLogined) then return end
   if not self.m_hall_chat_dialog then
       self.m_hall_chat_dialog = new(HallChatDialog, self);
   end;
   self:setHallChatBtnVisible(false);

end;

-- 大厅联盟界面
HallScene.onHallUnionBtnClick = function(self)
   Log.d("HallScene.onHallUnionBtnClick");
   if not self:requestCtrlCmd(HallController.s_cmds.isLogined) then return end
   if not self.m_union_dialog then
       self.m_union_dialog = new(UnionDialog, self);
   end;
   self:setHallUnionBtnVisible(false);
end;


HallScene.getChatDialog = function(self)
    return self.m_hall_chat_dialog;
end;

HallScene.getUnionDialog = function(self)
    return self.m_union_dialog;
end;

--1 大厅聊天按钮 2 大厅联盟按钮
HallScene.setHallChatBtnVisible = function(self,visible)
    if not visible then
        -- 收起动画
        local anim = self.m_hall_chat_btn:addPropTranslateWithEasing(1, kAnimNormal, 300, -1, "easeInBack", function (...) return 0 end, 0, -25, 0, 0)
        anim:setEvent(nil, function ()
            self.m_hall_chat_btn:removeProp(1)
            self.m_hall_chat_btn:setVisible(visible)
            self.m_hall_chat_dialog:show();
        end)
    else
        self.m_hall_chat_btn:setVisible(visible);
        -- 伸展动画
        local anim = self.m_hall_chat_btn:addPropTranslateWithEasing(2, kAnimNormal, 300, -1, "easeOutBack", function (...) return 0 end, -25, 25, 0, 0)
        anim:setEvent(nil, function ()
            self.m_hall_chat_btn:removeProp(2)
            
        end)   
    end; 
end

--1 大厅聊天按钮 2 大厅联盟按钮
HallScene.setHallUnionBtnVisible = function(self,visible)
    if not visible then
        -- 收起动画
        local anim = self.m_hall_union_btn:addPropTranslateWithEasing(1, kAnimNormal, 300, -1, "easeInBack", function (...) return 0 end, 0, -25, 0, 0)
        anim:setEvent(nil, function ()
            self.m_hall_union_btn:removeProp(1)
            self.m_hall_union_btn:setVisible(visible)
            self.m_union_dialog:show();
        end)
    else
        self.m_hall_union_btn:setVisible(visible);
        -- 伸展动画
        local anim = self.m_hall_union_btn:addPropTranslateWithEasing(2, kAnimNormal, 300, -1, "easeOutBack", function (...) return 0 end, -25, 25, 0, 0)
        anim:setEvent(nil, function ()
            self.m_hall_union_btn:removeProp(2)
            
        end)   
    end; 
end

HallScene.loadNewMsgs = function(self)
    self:requestCtrlCmd(HallController.s_cmds.loadNewMsgs);
end;

-- room_id:大师场传php的1000
-- 同城聊天室传city_code
HallScene.entryChatRoom = function(self,room_id)
    self:requestCtrlCmd(HallController.s_cmds.entryChatRoom, room_id);
end;

HallScene.onEntryChatRoom = function(self ,data)
    self.m_hall_chat_dialog:setEntryChatRoom(data);
end;

HallScene.onHallMoreBtnClick = function(self)
    MoreSettingDialog.getInstance():setHandler(self);
    MoreSettingDialog.getInstance():show();
    self.m_more_btn:getChildByName("pos"):setVisible(false);
end

HallScene.onMallBtnClick = function(self)
    self:requestCtrlCmd(HallController.s_cmds.mall);
end

HallScene.onDailyTaskBtnClick = function(self)
    self:requestCtrlCmd(HallController.s_cmds.activity);
end

HallScene.onShowDailyTask = function(self)
    delete(self.m_dailyTask);
    self.m_dailyTask = nil;

    local item = 0;
    local normal_gold = "600金币";
    local vip_gold = "2000金币";
    local mode = DailySignDialog.MODE_NORMAL;
    local daily_task_data = DailyTaskData.getInstance():getDailyTaskData();
    for i,v in pairs(daily_task_data) do
        if v.id == 3 then
            if v.status == 1 then
                item = item + 1;
                normal_gold = v.tip_text;
            end
        elseif v.id == 17 then
            if v.status == 1 then
                mode = DailySignDialog.MODE_VIP;
                item = item + 1;
                vip_gold = v.tip_text;
            end
        end
    end

    local data = {};
    data.item = item;
    data.mode = mode;
    data.normal_gold = normal_gold;
    data.vip_gold = vip_gold;
    self.m_dailyTask =new(DailySignDialog);
    self.m_dailyTask:setData(data);
    self.m_dailyTask:setPositiveListener(self,self.getSignReward);
    if DailyTaskData.getInstance():getSignShowStatus() then
        self.m_dailyTask:show();
    end
end

HallScene.updateDailyTaskDialog = function(self,isSuccess,message)
    MoreSettingDialog.getInstance():onGetNewDailyListResponse(isSuccess,message);
end

HallScene.getSignReward = function(self)
    local tips = "领取中...";
    local post_data = {};
    post_data.mid = UserInfo.getInstance():getUid();
    HttpModule.getInstance():execute(HttpModule.s_cmds.getSignReward,post_data,tips);
end

HallScene.showStartDialog = function(self)
    
    local start_config_json = GameCacheData.getInstance():getString(GameCacheData.START_CONFIG,"");
    if start_config_json == "" then
        return
    end
    local start_config = json.decode(start_config_json);
    if not start_config.is_open or start_config.is_open == 0 then
        return;
    end

    require("dialog/start_dialog");
    if not self.startDialog then
        self.startDialog = new(StartDialog,start_config);
    end
    self.startDialog:show();
end
if kPlatform == kPlatformIOS then
    HallScene.iosAuditStatus = function (self)
        -- ios 审核关闭大厅聊天和更多，版本号
        if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
            self.m_version:setVisible(true);
            self.m_hall_chat_btn:setVisible(true);
            self.m_more_btn_bg:setVisible(true);
            self.m_hall_union_btn:setVisible(true);
            self.m_hall_activity_btn:setVisible(true);
            self.m_switch_user_img:setVisible(true);
        else
            self.m_version:setVisible(false);
            self.m_hall_chat_btn:setVisible(false);
            self.m_more_btn_bg:setVisible(false);
            self.m_hall_union_btn:setVisible(false);
            self.m_hall_activity_btn:setVisible(false);
            self.m_switch_user_img:setVisible(false);
        end; 
        BottomMenu.getInstance():reset();
    end
end;
HallScene.updataUnionDialog = function(self,data,errorMsg)
    if not self.m_union_dialog then
        self.m_union_dialog = new(UnionDialog,self);
    end
    if not self.m_union_dialog:isShowing() then
        self.m_union_dialog:show();
    end
    if errorMsg then
        --显示错误提示弹窗
    end

    self.m_union_dialog:updataRecommend(data);
end 

HallScene.updataUnionMember = function(self,data,errorMsg)
    if not self.m_union_dialog then
        self.m_union_dialog = new(UnionDialog,self);
    end
    if not self.m_union_dialog:isShowing() then
        self.m_union_dialog:show();
    end
    if errorMsg then
        --显示错误提示弹窗
    end

    self.m_union_dialog:updataMember(data);
end

HallScene.getUnionRecommend = function(self)
	self:requestCtrlCmd(HallController.s_cmds.getUnionRecommend);   
end

HallScene.getAllUnionMember = function(self)
	self:requestCtrlCmd(HallController.s_cmds.getUnionMember);   
end
----------------------------------- config ------------------------------
HallScene.s_controlConfig = 
{
    [HallScene.s_controls.name]                     = {"userinfo_view","name"};
    [HallScene.s_controls.level_img]                = {"userinfo_view","level_img"};
    [HallScene.s_controls.money_view]               = {"userinfo_view","userinfo_view_bg","money_view"};
    [HallScene.s_controls.add_money_btn]            = {"userinfo_view","userinfo_view_bg","add_money_btn"};
    [HallScene.s_controls.more_btn_bg]              = {"more_btn_bg"};
    [HallScene.s_controls.more_btn]                 = {"more_btn_bg","more_btn"};
    [HallScene.s_controls.friends_btn]              = {"friends_btn_bg","friends_btn"};
    [HallScene.s_controls.online_btn]               = {"content_view","online_btn"};
    [HallScene.s_controls.endgate_btn]              = {"content_view","endgate_btn"};
    [HallScene.s_controls.console_btn]              = {"content_view","console_btn"};
    [HallScene.s_controls.dapu_btn]                 = {"content_view","dapu_btn"};
    [HallScene.s_controls.hall_switch_server]       = {"hall_switch_server"};
    [HallScene.s_controls.hall_version]             = {"hall_version"};
    [HallScene.s_controls.icon_frame_mask]          = {"userinfo_view","icon_frame_stroke","icon_frame_mask"};
    [HallScene.s_controls.bottom_menu]              = {"bottom_menu"};
    [HallScene.s_controls.userinfo_view]            = {"userinfo_view"};
    [HallScene.s_controls.logo]                     = {"logo"};
    [HallScene.s_controls.content_view]             = {"content_view"};
    [HallScene.s_controls.hall_chat_btn]            = {"hall_chat_btn"};
    [HallScene.s_controls.activity_btn]             = {"activity_btn"};
    [HallScene.s_controls.hall_union_btn]           = {"hall_union_btn"};
    [HallScene.s_controls.quick_play_btn]           = {"quick_play_btn"};
};

HallScene.s_controlFuncMap =
{
	[HallScene.s_controls.online_btn]               = HallScene.onHallOnlineBtnClick;
	[HallScene.s_controls.console_btn]              = HallScene.onHallConsoleBtnClick;
	[HallScene.s_controls.endgate_btn]              = HallScene.onHallEndingBtnClick;
    [HallScene.s_controls.dapu_btn]                 = HallScene.onHallReplayBtnClick;
    [HallScene.s_controls.hall_chat_btn]            = HallScene.onHallChatBtnClick;
    [HallScene.s_controls.hall_union_btn]           = HallScene.onHallUnionBtnClick;
    [HallScene.s_controls.more_btn]                 = HallScene.onHallMoreBtnClick;
    [HallScene.s_controls.friends_btn]              = HallScene.onHallFriendsBtnClick;
    [HallScene.s_controls.quick_play_btn]           = HallScene.onHallQuickPlayBtnClick;
    [HallScene.s_controls.add_money_btn]            = HallScene.onHallAddMoneyBtnClick;
    [HallScene.s_controls.activity_btn]             = HallScene.onActivityBtnClick;
};


HallScene.s_cmdConfig =
{
    [HallScene.s_cmds.update_user_money]            = HallScene.resetUserInfo;
    [HallScene.s_cmds.show_exit_dlg]                = HallScene.showExitDlg;
    [HallScene.s_cmds.has_playing_game]             = HallScene.hasPlayingGame;
    [HallScene.s_cmds.update_unread_msg]            = HallScene.changeUnreadMsgNum;
    [HallScene.s_cmds.show_guide_dialog]            = HallScene.showGuideDialog;
    [HallScene.s_cmds.show_account_dialog]          = HallScene.showAccountDialog;
    [HallScene.s_cmds.entry_chat_room]              = HallScene.onEntryChatRoom;
    [HallScene.s_cmds.dailyTask]                    = HallScene.onShowDailyTask;
    [HallScene.s_cmds.updateDailyTaskDialog]        = HallScene.updateDailyTaskDialog;
    [HallScene.s_cmds.show_start_dialog]            = HallScene.showStartDialog;
    [HallScene.s_cmds.ios_audit_status]             = HallScene.iosAuditStatus;
    [HallScene.s_cmds.updata_union_dialog]          = HallScene.updataUnionDialog;
    [HallScene.s_cmds.updata_union_member]          = HallScene.updataUnionMember;
}