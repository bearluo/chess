require(BASE_PATH.."chessScene");
require("dialog/chioce_dialog");
require("dialog/more_setting_dialog");
require("dialog/hall_chat_dialog");
require("dialog/report_dialog");
require("dialog/union_dialog");
require("dialog/daily_sign_dialog");
require("chess/include/bottomMenu");
require(DATA_PATH.."settingInfo");
require("chess/util/statisticsManager");
require("animation/activityAnim");
require("chess/prefabs/watch_view_prefabs")
require(DIALOG_PATH .. "aboutDialog")
require(DIALOG_PATH .. "setting_dialog_2")
require(DIALOG_PATH .. "relationshipDialog")
require(DIALOG_PATH .. "noticeMailDialog")
require(DIALOG_PATH .. "replay_dialog")
require("chess/prefabs/roomDoubleProp")
require(UTIL_PATH .. "noviceBootProxy")
require("dialog/comeback_reward_dialog")
HallScene = class(ChessScene);

HallScene.s_controls = 
{
	name                    = 1;
    level_img               = 2;
    money_view              = 3;
    online_btn              = 5;
    offline_btn             = 7;
    dapu_btn                = 8;
    bottom_menu             = 9;
    hall_switch_server      = 10;
    hall_version            = 11;
    icon_frame_mask         = 12;
    userinfo_view           = 13;
    logo                    = 14;
    content_view            = 15;
    hall_chat_btn           = 16;
--    hall_union_btn          = 18;
    add_money_btn           = 19;
    more_btn_bg             = 22;
    rank_btn_bg             = 23;
    console_num_tx = 24;            --单机目前在线总人数
    online_num_tx = 25;             --联网目前在线总人数
    match_num_tx = 26;              --比赛目前在线总人数
}

HallScene.s_cmds = 
{
    update_user_money       = 1;
    show_daily_task_dialog  = 2;
    show_exit_dlg           = 3;
    has_playing_game        = 4;
    --update_online_num       = 5;
    update_unread_msg       = 6;
    --账号完善引导
    show_account_dialog     = 8;
    entry_chat_room         = 9;
    --每日首次登陆领取奖励
    dailyTask               = 10;
    --更新每日任务
    updateDailyTaskDialog   = 11;
    show_start_dialog       = 12;
    
--    updata_union_dialog     = 13;
--    updata_union_member     = 14;
    ios_audit_status        = 15;
    --更新后引导
    show_update_guide       = 16;
    --聊天室是否有未读消息
    load_unread_msg         = 17;
    show_mail_tips          = 18;

    show_hall_chat          = 19;
    startRefreshPush        = 20; -- 开始更新推送
    

    show_comebackreward_dialog = 21; -- 回归奖励弹窗
    update_promotion_sale_goods = 22;
    --更新在线人数
    update_console_num = 23;
    update_online_num = 24;
    update_match_num = 25;
}
--第一次领取任务的新手引导词
HallScene.TASK_GUIDE_TIP = "有#c4bff4b任务奖励#n#l可领了！"

HallScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = HallScene.s_controls;
    self:init();
    ChatRoomData.getInstance():delete();
    DailyTaskManager.getInstance():register(self,self.refreshTaskPos)
end 

HallScene.resume = function(self)
    ChessScene.resume(self);
    self:reset();
    if GameData.getInstance():getGetDailyTask() then
        self:showDailyTask();
    end
--    self:resumeAnimStart();

    DailyTaskManager.getInstance():register(self,self.onShowDailyTask)
    --test
--    local a = new(MatchResultDialog)
--    a:setMatchId(1)
--    a:setWinView()
--    a:show()function MetierMatchModule:getMatchEndDialog()
    self.mWatchView:resume()
    self:startRefreshPush()

    if self.m_replay_dialog and self.m_replay_dialog_is_showing then
        self.m_replay_dialog_is_showing = false;
        self.m_replay_dialog:show();
    end;

    if self.mNoticeMailDialog and self.mNoticeMailDialogIsShowing then
        self.mNoticeMailDialogIsShowing = false
        self.mNoticeMailDialog:show()
    end
    if self.mRelationshipDialog and self.mRelationshipDialogIsShowing then
        self.mRelationshipDialogIsShowing = false
        self.mRelationshipDialog:show()
    end
    --测试
    --NoviceBootProxy.getInstance():clearGuideTipViewShowTime(NoviceBootProxy.s_constant.RECEIVE_REWARD)
    self:refreshTaskPos()
    self:checkGuiTip()
    self:getNumData()
    self:updatePromotionSaleGoods()
end


HallScene.pause = function(self)
	ChessScene.pause(self);
    self:removeAnimProp();
--    self:pauseAnimStart();
    DailyTaskManager.getInstance():unregister(self,self.onShowDailyTask);
    MoreSettingDialog.getInstance():dismiss();
    self.mWatchView:pause()
    self:setMenuVisible(false)
    if self.mNoticeMailDialog and self.mNoticeMailDialog:isShowing() then
        self.mNoticeMailDialogIsShowing = true
        self.mNoticeMailDialog:dismiss()
    end
    if self.mRelationshipDialog and self.mRelationshipDialog:isShowing()  then
        self.mRelationshipDialogIsShowing = true
        self.mRelationshipDialog:dismiss()
    end
    if self.mAboutDialog and self.mAboutDialog:isShowing()  then
        self.mAboutDialog:dismiss()
    end

    if self.m_replay_dialog and self.m_replay_dialog:isShowing() then
        self.m_replay_dialog_is_showing = true;
        self.m_replay_dialog:dismiss();
    end;
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.CHESS_MANUAL)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.HALL_CHAT)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.RECEIVE_REWARD)
    self:stopShowHallChatTipAnim()
end 

HallScene.dtor = function(self)
    delete(self.leaveTipsDialog);
    delete(self.m_moreSettingDialog);
    delete(self.chioce_dialog);
    delete(self.notice_dialog);
    delete(self.m_union_dialog);
    delete(self.gradConfigDialog);
    DailyTaskManager.getInstance():unregister(self,self.refreshTaskPos)
end 

----------------------------------- function ----------------------------
HallScene.init = function(self)
    Log.d("HallScene.init");
    self.m_version = self:findViewById(self.m_ctrls.hall_version);
    self.m_version:setText("v"..kLuaVersion);

    self.m_bottom_menu = self:findViewById(self.m_ctrls.bottom_menu);
    self.m_userinfo_view = self:findViewById(self.m_ctrls.userinfo_view);
    self.m_content_view = self:findViewById(self.m_ctrls.content_view);
    self:ininUserInfo();
    self:initSwitchServer();
--    self.m_hall_union_btn = self:findViewById(self.m_ctrls.hall_union_btn);
    -- animation part
    self.m_root_view = self.m_root;
    self.m_root:getChildByName("hall_bg"):setEventTouch(self,function()
        NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.CHESS_MANUAL)
        NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.HALL_CHAT)
        NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.RECEIVE_REWARD)
    end)
    self.m_userinfo_view_bg = self.m_userinfo_view:getChildByName("userinfo_view_bg");   -- user bg
    self.m_icon_frame_stroke = self.m_userinfo_view:getChildByName("icon_frame_stroke"); -- icon bg
    self.m_vip_icon = self.m_userinfo_view:getChildByName("vip_icon")
    self.m_vip_frame = self.m_icon_frame_stroke:getChildByName("vip_frame");
    self.m_online_btn = self:findViewById(self.m_ctrls.online_btn);
    self.m_offline_btn = self:findViewById(self.m_ctrls.offline_btn);
    self.m_dapu_btn = self:findViewById(self.m_ctrls.dapu_btn);
    self.m_hall_activity_btn = self.m_root:getChildByName("activity_btn");
    self.m_hall_activity_btn:setOnClick(self,self.onActivityBtnClick)
    --当前在线人数
    self.console_num_tx = self:findViewById(self.m_ctrls.console_num_tx)
    self.online_num_tx = self:findViewById(self.m_ctrls.online_num_tx)
    self.match_num_tx = self:findViewById(self.m_ctrls.match_num_tx)
    
    self.m_menu_btn      = self.m_bottom_menu:getChildByName("menu_btn");
    self.m_menu_view     = self.m_bottom_menu:getChildByName("menu_view");
    local w,h = self.m_menu_view:getSize()
    local x,y = self.m_menu_view:getPos()
    self.m_menu_view:setClip(x,y,w,h)
    self:setMenuVisible(false)
    self.m_menu_view:setEventTouch(self,function()end)
    self.m_friends_btn  = self.m_bottom_menu:getChildByName("friends_btn");
    self.m_mail_btn     = self.m_bottom_menu:getChildByName("mail_btn");
    self.m_qipu_btn     = self.m_bottom_menu:getChildByName("qipu_btn");
    self.m_qipu_btn_handler     = self.m_bottom_menu:getChildByName("qipu_btn_handler");
    self.m_chat_btn     = self.m_bottom_menu:getChildByName("chat_btn");
    self.m_chat_btn_handler     = self.m_bottom_menu:getChildByName("chat_btn_handler");
    self.m_chat_btn_pos = self.m_chat_btn:getChildByName("pos");
    self.m_friends_btn:setOnClick(self,function()
        NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.CHESS_MANUAL)
        NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.HALL_CHAT)
        NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.RECEIVE_REWARD)
        if not self.m_controller:isLogined() then return ;end
        StatisticsManager.getInstance():onCountToUM(HALL_MODEL_FRIENDS_BTN)
        if not self.mRelationshipDialog then
            self.mRelationshipDialog = new(RelationshipDialog)
        end
        self.mRelationshipDialog:showFollowView()
        self.mRelationshipDialog:show()
        self:startShowHallChatTipAnim()
--        StateMachine.getInstance():pushState(States.Friends,StateMachine.STYPE_CUSTOM_WAIT);
    end)
    
    self.m_mail_btn:setOnClick(self,function()
        NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.CHESS_MANUAL)
        NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.HALL_CHAT)
        NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.RECEIVE_REWARD)
        if not self.m_controller:isLogined() then return ;end
        StatisticsManager.getInstance():onCountToUM(HALL_MODEL_MAIL_BTN)
        delete(self.mNoticeMailDialog)
        self.mNoticeMailDialog = new(NoticeMailDialog)
        self.mNoticeMailDialog:showMailView()
        self.mNoticeMailDialog:show()
        self.m_mail_btn:getChildByName("pos"):setVisible(false)
        self:startShowHallChatTipAnim()
    end)

    self.m_qipu_btn:setOnClick(self,function()
        NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.CHESS_MANUAL)
        NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.HALL_CHAT)
        NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.RECEIVE_REWARD)
        if not self.m_controller:isLogined() then return ;end
        StatisticsManager.getInstance():onCountToUM(HALL_MODEL_QIPU_BTN)
        delete(self.m_replay_dialog);
        self.m_replay_dialog = new(ReplayDialog);
        self.m_replay_dialog:show();
        self:startShowHallChatTipAnim()
    end)

    self.m_chat_btn:setOnClick(self,self.onHallChatBtnClick)
    
    self.m_task_btn = self.m_root:getChildByName("task_btn");
    self.m_task_btn_handler = self.m_root:getChildByName("task_btn_handler")
    self.m_hall_task_icon = self.m_task_btn:getChildByName("Image31")
    self.m_task_btn:setOnClick(self,self.onDailyTaskBtnClick)
    
    self.m_attire_btn = self.m_root:getChildByName("attire_btn");
    self.m_attire_btn:setOnClick(self,function()
        NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.CHESS_MANUAL)
        NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.HALL_CHAT)
        NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.RECEIVE_REWARD)
        if not self.m_controller:isLogined() then return ;end
        StatisticsManager.getInstance():onCountToUM(HALL_MODEL_MALL_BTN)
        StateMachine.getInstance():pushState(States.Mall,StateMachine.STYPE_CUSTOM_WAIT);  --跳转到商场
    end)
    
    self.mWatchView = new(WatchViewPrefabs)
    self.m_root:getChildByName("watch_view_handler"):addChild(self.mWatchView)
    self.isShowMenu = false
    self.m_menu_btn:setOnClick(self,function()
        if not kFeedbackGameid or not kFeedbackSiteid then
            self.m_controller:loadFeedbackInfo()
        end
        StatisticsManager.getInstance():onCountToUM(HALL_MODEL_MORE_BTN)
        self.m_menu_view:setVisible(true)
        self:setMenuVisible(not self.isShowMenu)
        NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.CHESS_MANUAL)
        NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.HALL_CHAT)
        NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.RECEIVE_REWARD)
        self:startShowHallChatTipAnim()
    end)
    
    self.m_push_btn     = self.m_root:getChildByName("push_btn");
    self.m_push_icon    = self.m_push_btn:getChildByName("icon");
    self.m_push_txt     = self.m_push_btn:getChildByName("txt");
    self.m_push_icon:setFile("common/decoration/board_dec.png")
    self.m_push_txt:setFile("hall/txt_1.png")
    self.m_push_btn:setOnClick(self,self.onHallQuickPlayBtnClick)
    
    self.m_evaluation_btn = self.m_root:getChildByName("evaluation_btn");
    self.m_evaluation_btn:setVisible(false)
    self.m_evaluation_btn:setOnClick(self,function()
	    StateMachine.getInstance():pushState(States.evaluationGame,StateMachine.STYPE_CUSTOM_WAIT);
        NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.CHESS_MANUAL)
        NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.HALL_CHAT)
        NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.RECEIVE_REWARD)
        self:startShowHallChatTipAnim()
    end)

    self.m_menu_view:getChildByName("bg"):getChildByName("rank_btn"):setOnClick(self,function() 
            self:setMenuVisible(false) 
            self:onHallRandBtnClick() 
            self:startShowHallChatTipAnim()
        end)
    self.m_menu_view:getChildByName("bg"):getChildByName("feedback_btn"):setOnClick(self,function() 
            self:setMenuVisible(false) 
            self:onHallFeedbackBtnClick() 
            self:startShowHallChatTipAnim()
        end)
    self.m_menu_view:getChildByName("bg"):getChildByName("set_btn"):setOnClick(self,function() 
            self:setMenuVisible(false) 
            self:onHallSetBtnClick() 
            self:startShowHallChatTipAnim()
        end)
    self.m_menu_view:getChildByName("bg"):getChildByName("about_btn"):setOnClick(self,function() 
            self:setMenuVisible(false) 
            self:onHallAboutBtnClick() 
            self:startShowHallChatTipAnim()
        end)
        
    if kPlatform == kPlatformIOS then
        self:iosAuditStatus()
    end
    
    self.mPromotionBtn = self.m_root:getChildByName("promotion_btn")
    self.mPromotionBtn:setVisible(false)
    self.mPromotionBtn:setOnClick(self,self.showBuyPromotionSaleGoodsDialog)
    self.mRoomDoubleProp = new(RoomDoubleProp)
    self.mRoomDoubleProp:setAlign(kAlignTopRight)
    self.mRoomDoubleProp:setPos(0,15)
    self.mRoomDoubleProp:setVisible(false)
    self.m_online_btn:addChild(self.mRoomDoubleProp)
    self.m_online_btn:setOnTuchProcess(self.mRoomDoubleProp,function(view,enable)
        if enable then
            view:setPos(0,15)
        else
            view:setPos(0,10)
        end
    end)
    self:removeInitAnimProp();
    self:initAnim()
    ThirdGuideDialog.getInstance():setHandler(self);
end

HallScene.removeInitAnimProp = function(self)
    self.m_icon_frame_stroke:removeProp(1);
    self.m_icon_frame_stroke:removeProp(2);
--        self.m_hall_union_btn:removeProp(1);
    self.m_bottom_menu:removeProp(1);
    self.m_online_btn:removeProp(1);
    self.m_online_btn:removeProp(2);
    self.m_offline_btn:removeProp(1);
    self.m_offline_btn:removeProp(2);
    self.m_dapu_btn:removeProp(1);
    self.m_dapu_btn:removeProp(2);
end

HallScene.initAnim = function(self)
   --竹叶动画
   local duration = 900;
   local delay = -1;
   --延时1s播放动画，防止进游戏卡
   if is_open and is_open == 1 then
        delay = 1000;
   end

   --顶部动画
   self.m_icon_frame_stroke:addPropTransparency(2,kAnimNormal,240,delay,0.5,1);
   local top_anim3 = self.m_icon_frame_stroke:addPropScale(1,kAnimNormal,240,-1,0.8,1.1,0.8,1.1,kCenterDrawing);
   top_anim3:setEvent(self,function()
        self.m_icon_frame_stroke:removeProp(1);
        self.m_icon_frame_stroke:removeProp(2);
        delete(top_anim3);
   end);


--   local ubtn_w,ubtn_h = self.m_hall_union_btn:getSize();
--   self.m_hall_union_btn:addPropTranslate(1,kAnimNormal,200,300 + delay,-ubtn_w,0,0,0);

   --下部动画
   local bw,bh = self.m_bottom_menu:getSize();
   self.m_bottom_menu:addPropTranslate(1, kAnimNormal, 420, 200 + delay, 0, 0, bh, 0);

   --中间动画
   local cw,ch = self.m_online_btn:getSize();
   self.m_online_btn:addPropTransparency(2,kAnimNormal,410,390 + delay,0,1);
   self.m_online_btn:addPropScale(1,kAnimNormal,400,400 + delay,0.8,1,0.7,1,kCenterXY,0,140);

   self.m_dapu_btn:addPropTransparency(2,kAnimNormal,410,490 + delay,0,1);
   self.m_dapu_btn:addPropScale(1,kAnimNormal,400,500 + delay,0.8,1,0.7,1,kCenterXY,0,140);

   local anim_end = self.m_offline_btn:addPropTransparency(2,kAnimNormal,410,590 + delay,0,1);
   self.m_offline_btn:addPropScale(1,kAnimNormal,400,600 + delay,0.8,1,0.7,1,kCenterXY,0,140);

   anim_end:setEvent(self,function()
        self:removeInitAnimProp();
        delete(anim_end);
   end);
end

HallScene.removeAnimProp = function(self)
    delete(self.anim_start);
end

HallScene.setAnimItemEnVisible = function(self,ret)
end

HallScene.resumeAnimStart = function(self,lastStateObj,timer,changeStyle)
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;
    if anim then
        anim:setEvent(self,function()
            self:removeAnimProp();
        end);
    end
    delete(self.anim_start);
    self.anim_start = new(AnimInt,kAnimNormal,0,1,0,waitTime);
    if self.anim_start then
        self.anim_start:setEvent(self,function()
            self:setAnimItemEnVisible(true);
            delete(self.anim_start);
            if kPlatform == kPlatformIOS then
                if tonumber(UserInfo.getInstance():getIosAuditStatus()) == 0 then return end;
                if tonumber(UserInfo.getInstance():getCanShowIOSAppstoreReview()) == 0 then return end;
            -- 判断是不是刚进入这个界面
                if self.firstLoaded == nil then 
                    self.firstLoaded = true;
                    return;
                end;
                
                local currentRate = UserInfo.getInstance():getRateNum();
                local lastRateNum = self.lastRate;
                local currentRateNum = currentRate;
                if currentRateNum <= lastRateNum then
                    return;
                end

                require(DIALOG_PATH .. "ios_review_dialog_view");
                if not self.reviewDialog then
                    self.reviewDialog = new(ReviewDialogView);
                end
                self.reviewDialog:show();
                UserInfo.getInstance():setCanShowIOSAppstoreReview(0);
            end
        end);
    end
end

HallScene.pauseAnimStart = function(self,newStateObj,timer,changeStyle)
--    self.m_root:removeProp(1);
    self:removeAnimProp();
    local w,h = self:getSize();
    
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;
    if anim then
        anim:setEvent(self,function()
            self:setAnimItemEnVisible(false);
            self:removeAnimProp();
        end);
    end
end

HallScene.reset = function(self)
    self:resetUserInfo();
end


HallScene.showDailyTask = function(self)
    GameData.getInstance():setGetDailyTask(false);
--    MoreSettingDialog.getInstance():showDailyTask();
end

HallScene.changeUnreadMsgNum = function(self, flag)
    Log.d("HallScene.changeUnreadMsgNum");
    self.m_chat_btn_pos:setVisible(flag);
end;

HallScene.initSwitchServer = function(self)
    Log.d("HallScene.initSwitchServer");
    self.m_switchServer = self:findViewById(self.m_ctrls.hall_switch_server)
    self.m_switchText = self.m_switchServer:getChildByName("switch_text");
    self.m_switchServer:setVisible(kDebug or false);
    self.m_switchServer:setOnClick(self, self.hallSwitchServer);
    self.m_switchText:setText("当前测试服");
end

--require("dialog/task_complete_dialog");
HallScene.hallSwitchServer = function(self)
--    if true then
--        TaskCompleteDialog.getInsance():show();
--        return 
--    end
    local isDebug = UserInfo.getDebugMode();
    if isDebug then
       
        self.m_switchText:setText("当前测试服");
        UserInfo.setDebugMode(false);
        PhpConfig.new_developUrl = PhpConfig.new_developTest;
        PhpConfig.h5_developUrl = PhpConfig.h5_developTest;
        PhpConfig.setDevelopUrl(PhpConfig.developTest);
        PhpConfig.setMid(0);
        PhpConfig.setMtkey();
        PhpConfig.setUid(0);
        UserInfo.getInstance():setLogin(false);
    else
        self.m_switchText:setText("当前正式服");
        UserInfo.setDebugMode(true);
        PhpConfig.new_developUrl = PhpConfig.new_developMainUrl;
        PhpConfig.h5_developUrl = PhpConfig.h5_developMainUrl;
        PhpConfig.setDevelopUrl(PhpConfig.developMainUrl);
        PhpConfig.setMid(0);
        PhpConfig.setMtkey();
        PhpConfig.setUid(0);
        UserInfo.getInstance():setLogin(false);
    end;

    HttpModule.getInstance():releaseInstance();
    HttpModule.s_config = nil;
    HttpModule.initConfig();
--    require("common/httpModule");
    HttpModule.getInstance();
--    HttpManager.setConfigMap(HttpModule.s_config);

    self:requestCtrlCmd(HallController.s_cmds.switch_server);


end;

function HallScene.getNumData(self)
    self:requestCtrlCmd(HallController.s_cmds.updateNumData);
end


HallScene.ininUserInfo = function(self)
    Log.d("HallScene.initHeadIcon");
    self.m_name = self:findViewById(self.m_ctrls.name);
    self.m_level_img = self:findViewById(self.m_ctrls.level_img);
    self.m_rank_icon_bg = self.m_userinfo_view:getChildByName("score_bg"):getChildByName("rank_icon");
    self.m_money_view = self:findViewById(self.m_ctrls.money_view);
    self.m_icon_frame_mask = self:findViewById(self.m_ctrls.icon_frame_mask);
    self.m_icon_frame_btn = self.m_userinfo_view:getChildByName("icon_frame_stroke"):getChildByName("icon_frame_btn");
    self.m_icon_frame_btn:setOnClick(self,self.onHeadIconClick);
    self.m_score_view = self.m_userinfo_view:getChildByName("score_bg"):getChildByName("score_view");
    self.m_userinfo_view:getChildByName("score_bg"):getChildByName("add_btn"):setOnClick(self,function()
        StatisticsManager.getInstance():onCountToUM(HALL_MODEL_SCORE_BTN)
--        HallScene.showReviewDialog(self);
        HallScene.showGradConfigDialog(self);
    end)
end

require(DATA_PATH.."userInfo");

HallScene.resetUserInfo = function(self)
    if self.m_money_view then
        self.m_money_view:removeAllChildren(true);
        local str = UserInfo.getInstance():getMoneyStr();
        local addstr = new(Text,str,nil, nil, kAlignLeft, nil, 30, 80, 80, 80);
        addstr:setAlign(kAlignLeft);
        self.m_money_view:addChild(addstr);
    end
    if self.m_score_view then
        self.m_score_view:removeAllChildren(true);
        local str = UserInfo.getInstance():getScore();
        local addstr = new(Text,str,nil, nil, kAlignLeft, nil, 30, 80, 80, 80);
        addstr:setAlign(kAlignLeft);
        self.m_score_view:addChild(addstr);
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
        local level = 10-UserInfo.getInstance():getDanGradingLevel()
        -- self.m_rank_icon_bg:setFile("common/decoration/rank_icon_1.png")
        -- self.m_level_img:setFile(string.format("rank/num_1/%d.png",level));
        self.m_rank_icon_bg:setVisible(false);
        self.m_level_img:setFile(string.format("common/icon/new_level_%d.png",level));
    end
    local is_vip = UserInfo.getInstance():getIsVip();
    if is_vip == 1 then
        self.m_vip_icon:setVisible(true)
        self.m_name:setPos(119)
    else
        self.m_vip_icon:setVisible(false)
        self.m_name:setPos(80)
    end
    local frameRes = UserSetInfo.getInstance():getFrameRes();
    if not frameRes then return end
    self.m_vip_frame:setVisible(frameRes.visible);
    local fw,fh = self.m_vip_frame:getSize();
    if frameRes.frame_res then
        self.m_vip_frame:setFile(string.format(frameRes.frame_res,90));
    end
    if not UserInfo.getInstance():isHasDoubleProp() then
        self.mRoomDoubleProp:setVisible(false)
    else
        self.mRoomDoubleProp:setVisible(true)
    end
    self:checkGuiTip()
    self.m_evaluation_btn:setVisible(not UserInfo.getInstance():isHasEvaluation())
end

--更新单机在线总人数
function HallScene.updateConsoleNum(self,num)
    local num =tonumber(num) or 0
    if num < 0 then num = 0 end
    self.console_num_tx:setText(num)
end
--更新联网在线总人数
function HallScene.updateOnlineNum(self,num)
    local num =tonumber(num) or 0
    if num < 0 then num = 0 end
    self.online_num_tx:setText(num)
end
--更新比赛在线总人数
function HallScene.updateMatchNum(self,num)
    local num =tonumber(num) or 0
    if num < 0 then num = 0 end
    self.match_num_tx:setText(num)
end

function HallScene:refreshTaskPos()
    local dailyTaskIsClear = DailyTaskData.getInstance():getCompleteStatus();
    local growTaskIsClear = DailyTaskData.getInstance():getGrowTaskCompleteStatus();
    if dailyTaskIsClear or growTaskIsClear then
        self.m_task_btn:getChildByName("pos"):setVisible(true);
        self:showTaskGuideTip()
    else
        self.m_task_btn:getChildByName("pos"):setVisible(false);
    end
    --测试
    --self:showTaskGuideTip()
end

require("dialog/third_guide_dialog");
require("dialog/first_login_guide_dialog");
HallScene.showGuideDialog = function(self)
    if not self.firstLogGuideDialog then
        self.firstLogGuideDialog = new(FirstLogGuideDialog);
--        self.m_secondLogGuideDialog = new(SecondLogGuideDialog);
        self.firstLogGuideDialog:show();
    end
end

require("dialog/modify_info_dialog");
require("dialog/binding_tip_dialog");
HallScene.showAccountDialog = function(self,dialogType)
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

require("dialog/leave_tips_dialog");
HallScene.showExitDlg = function(self)
    if kPlatform == kPlatformIOS then
    	return;
    end;
    local msg = "亲～明天再来会送您金币，记得来领呦～";
	local isLeaveGame = true;

    local newData = DailyTaskData.getInstance():getDailySignData()
    if newData then
        local list = newData.list or {}
        local reward = nil
        for k,v in pairs(list) do
            if v then
                if v.status == 0 then
                    local temp = v.reward or {}
                    if temp.money then
                        local multiple = 1
                        if UserInfo.getInstance():getIsVip() == 1 then
                            multiple = newData.multiple or 1
                        end
                        reward = temp.money * multiple
                        msg = "不要说珍重，不要说再见!\n 明日" .. reward  .. "金币等你回归领取!"
                    end
                    break
                end
            end
        end
        isLeaveGame = not reward
    end
	if not self.leaveTipsDialog  then
		self.leaveTipsDialog = new(LeaveTipsDialog,isLeaveGame);
	end
	
	self.leaveTipsDialog:setMessage(msg);
	self.leaveTipsDialog:setExitListener(self,self.exitHall)
	self.leaveTipsDialog:setCallsListener(self,self.callsCallBack)
	self.leaveTipsDialog:setCoinsListener(self,self.onDailyTaskBtnClick)
	self.leaveTipsDialog:setCancelListener(nil,nil)
	self.leaveTipsDialog:show();
end

require("dialog/grade_config_dialog");
HallScene.showGradConfigDialog = function(self)
    if not self.gradConfigDialog then
        self.gradConfigDialog = new(GradeConfigDialog);
    end
    self.gradConfigDialog:show();
end

require(DIALOG_PATH .. "ios_review_dialog_view");
HallScene.showReviewDialog = function (self)
    if not self.reviewDialog then
        self.reviewDialog = new(ReviewDialogView);
    end
    self.reviewDialog:show();
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
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.CHESS_MANUAL)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.HALL_CHAT)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.RECEIVE_REWARD)
	StateMachine.getInstance():pushState(States.Mall,StateMachine.STYPE_CUSTOM_WAIT);
end

function HallScene:onHallAddMoneyBtnClick()
--    local data = MallData.getInstance():getPayRecommendGoods()
--    if data and data.hall then
--        local goods = MallData.getInstance():getGoodsById(data.hall)
--        if goods then
--            local payData = {}
--            payData.pay_scene = PayUtil.s_pay_scene.hall_recommend
--            local payInterface = PayUtil.getPayInstance(PayUtil.s_defaultType);
--		    payInterface:buy(goods,payData);	
--            return 
--        end
--    end
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.CHESS_MANUAL)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.HALL_CHAT)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.RECEIVE_REWARD)
    if not self:requestCtrlCmd(HallController.s_cmds.isLogined) then return end
    StatisticsManager.getInstance():onCountToUM(HALL_MODEL_GOLD_BTN)
	StateMachine.getInstance():pushState(States.Mall,StateMachine.STYPE_CUSTOM_WAIT);
end

function HallScene:onHallRandBtnClick()
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.CHESS_MANUAL)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.HALL_CHAT)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.RECEIVE_REWARD)
    if not self:requestCtrlCmd(HallController.s_cmds.isLogined) then return end
    StatisticsManager.getInstance():onCountToUM(HALL_MODEL_MORE_RANK_BTN);
	StateMachine.getInstance():pushState(States.Rank,StateMachine.STYPE_CUSTOM_WAIT,nil,2);
end

function HallScene:onHallSetBtnClick()
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.CHESS_MANUAL)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.HALL_CHAT)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.RECEIVE_REWARD)
    if not self:requestCtrlCmd(HallController.s_cmds.isLogined) then return end
    StatisticsManager.getInstance():onCountToUM(HALL_MODEL_MORE_SET_BTN);
    if not self.mSetDialog then
        self.mSetDialog = new(SettingDialog2)
    end
    self.mSetDialog:show()
--	StateMachine.getInstance():pushState(States.setModel,StateMachine.STYPE_CUSTOM_WAIT);
end

function HallScene:onHallFeedbackBtnClick()
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.CHESS_MANUAL)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.HALL_CHAT)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.RECEIVE_REWARD)
    if not self:requestCtrlCmd(HallController.s_cmds.isLogined) then return end
    StatisticsManager.getInstance():onCountToUM(HALL_MODEL_MORE_FEEDBACK_BTN);
	if kPlatform == kPlatformIOS then
        StateMachine.getInstance():pushState(States.Feedback,StateMachine.STYPE_CUSTOM_WAIT);
    else
        if not kFeedbackGameid or not kFeedbackSiteid then
            self.m_controller:loadFeedbackInfo()
            ChessToastManager.getInstance():showSingle("反馈参数出错了:(");
            return;
        end;
        local postData = {};
        postData.game_id = kFeedbackGameid;
        postData.site_id = kFeedbackSiteid;
        postData.uid = UserInfo.getInstance():getUid();
        postData.user_name = UserInfo.getInstance():getName();
        postData.user_icon_url = UserInfo.getInstance():getIcon();
        postData.is_kefu_vip = (tonumber(kIsFeedbackVip) == 1 and "3") or "2"; 
        postData.kefu_vip_level = (tonumber(kIsFeedbackVip) == 1 and kFeedbackVipLevel) or "normal";
        postData.account_type = UserInfo.getInstance():getAccountTypeName();
        postData.client = kIsFeedbackClient;
        dict_set_string(kLoadFeedbackSdk, kLoadFeedbackSdk .. kparmPostfix,json.encode(postData));
        call_native(kLoadFeedbackSdk);
    end
end

function HallScene:onHallAboutBtnClick()
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.CHESS_MANUAL)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.HALL_CHAT)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.RECEIVE_REWARD)
    if not self:requestCtrlCmd(HallController.s_cmds.isLogined) then return end
    StatisticsManager.getInstance():onCountToUM(HALL_MODEL_MORE_ABOUT_BTN);
    if not self.mAboutDialog then
        self.mAboutDialog = new(AboutDialog)
    end
    self.mAboutDialog:show()
end


function HallScene:onHallQuickPlayBtnClick()
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.CHESS_MANUAL)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.HALL_CHAT)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.RECEIVE_REWARD)
    if UserInfo.getInstance():isFreezeUser() then return end
    self:requestCtrlCmd(HallController.s_cmds.quickPlay);

    -- 拿到用户进入游戏时候的胜率
    if kPlatform == kPlatformIOS then
        if tonumber(UserInfo.getInstance():getIosAuditStatus()) == 0 then return end;
        if tonumber(UserInfo.getInstance():getCanShowIOSAppstoreReview()) == 0 then return end;
        self.lastRate = UserInfo.getInstance():getRateNum();
    end
end

function HallScene:onGuideCallBack(stateType)
	if not stateType then return end
    StatisticsManager.getInstance():onCountNewUserSkip(stateType);
    
    if tonumber(stateType) == States.Friends then
        TaskScene.s_showRelationshipDialog()
        return
    elseif tonumber(stateType) == States.Replay then
        TaskScene.s_showReplayDialog()
        return
    end
    StateMachine.getInstance():pushState(stateType,StateMachine.STYPE_CUSTOM_WAIT);
end

function HallScene:onActivityBtnClick(status)
    if UserInfo.getInstance():isFreezeUser() then return end;
    StatisticsManager.getInstance():onCountToUM(HALL_MODEL_ACTIVITY_BTN);
    ActivityAnim.getInstance().deleteBtnAnim()
	StateMachine.getInstance():pushState(States.activity,StateMachine.STYPE_CUSTOM_WAIT,nil,status);
end

function HallScene:onFeedBackBtnClick()
    self:requestCtrlCmd(HallController.s_cmds.feedBack);
end

require("dialog/second_login_guide_dialog");
function HallScene:showUpdateGuideDialog()
    -- 弹出指引弹窗2
    if not self.m_secondLogGuideDialog then
        self.m_secondLogGuideDialog = new(SecondLogGuideDialog);
    end
    self.m_secondLogGuideDialog:show();
end
----------------------------------- onClick ---------------------------------

HallScene.onHeadIconClick = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
--    require("dialog/notice_dialog");
--    require("dialog/union_dialog");
    if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
        Log.d("HallScene.onHeadIconClick");
--        call_native(qq_login);
        if not self.m_controller:isLogined() then return ;end
        StatisticsManager.getInstance():onCountToUM(HALL_MODEL_HEAD_BTN)
        StateMachine.getInstance():pushState(States.ownModel,StateMachine.STYPE_CUSTOM_WAIT);
    end
end

-- 联网 -> 经典对战
HallScene.onHallOnlineBtnClick = function(self)
    Log.d("HallScene.onHallOnlineBtnClick");
    StatisticsManager.getInstance():onCountToUM(HALL_MODEL_ONLINE_BTN);
    self:requestCtrlCmd(HallController.s_cmds.onlineChess);
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.CHESS_MANUAL)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.HALL_CHAT)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.RECEIVE_REWARD)
end

-- 单机
HallScene.onHallOfflineBtnClick = function(self)
    Log.d("HallScene.onHallOfflineBtnClick");
    StatisticsManager.getInstance():onCountToUM(HALL_MODEL_OFFLINE_BTN);
    self:requestCtrlCmd(HallController.s_cmds.offlineChess);
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.CHESS_MANUAL)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.HALL_CHAT)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.RECEIVE_REWARD)
end


-- 比赛争霸
HallScene.onHallCompeteBtnClick = function( self )
    Log.d("HallScene.onHallCompeteBtnClick");
    StatisticsManager.getInstance():onCountToUM(HALL_MODEL_COMPETE_BTN);
    self:requestCtrlCmd(HallController.s_cmds.competeChess);
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.CHESS_MANUAL)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.HALL_CHAT)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.RECEIVE_REWARD)
end

HallScene.onHallUserMoneyBtnClick = function(self)
    Log.d("HallScene.onHallUserMoneyBtnClick");
    self:requestCtrlCmd(HallController.s_cmds.mall);
end
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.CHESS_MANUAL)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.HALL_CHAT)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.RECEIVE_REWARD)

HallScene.onHallFriendMsgBtnClick = function(self)
	Log.d("HallScene.onHallFriendMsgBtnClick");
	self:requestCtrlCmd(HallController.s_cmds.friendMsg);   
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.CHESS_MANUAL)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.HALL_CHAT)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.RECEIVE_REWARD)

end;

HallScene.onHallUserFriendsBtnClick = function(self)
    Log.d("HallScene.onHallUserFeedbackBtnClick");
    self:requestCtrlCmd(HallController.s_cmds.friends);
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.CHESS_MANUAL)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.HALL_CHAT)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.RECEIVE_REWARD)
end
-- 大厅聊天界面
HallScene.onHallChatBtnClick = function(self)
   Log.d("HallScene.onHallChatBtnClick");
   if UserInfo.getInstance():isFreezeUser() then return end
   if not self:requestCtrlCmd(HallController.s_cmds.isLogined) then return end
        StatisticsManager.getInstance():onCountToUM(HALL_MODEL_CHAT_BTN)
   if not self.m_hall_chat_dialog then
       self.m_hall_chat_dialog = new(HallChatDialog, self);
   end;
   self:setHallChatBtnVisible(false);
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.CHESS_MANUAL)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.HALL_CHAT)
   self:startShowHallChatTipAnim()
--    local data = {['speed']=6,["horn_type"]="2",['horn_msg']="恭喜hghv在初级场场实力战胜对手，一次性获得积分#c008000168#n！"};
--    BroadCastHorn.getInstance():play(data);
end;

-- 大厅联盟界面
HallScene.onHallUnionBtnClick = function(self)
    Log.d("HallScene.onHallUnionBtnClick");
    if not self:requestCtrlCmd(HallController.s_cmds.isLogined) then return end
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.CHESS_MANUAL)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.HALL_CHAT)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.RECEIVE_REWARD)
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
        self.m_hall_chat_dialog:show();
    else
    end
end

--1 大厅聊天按钮 2 大厅联盟按钮
--HallScene.setHallUnionBtnVisible = function(self,visible)
--    if not visible then
--         收起动画
--        local anim = self.m_hall_union_btn:addPropTranslateWithEasing(1, kAnimNormal, 300, -1, "easeInBack", function (...) return 0 end, 0, -25, 0, 0)
--        anim:setEvent(nil, function ()
--            self.m_hall_union_btn:removeProp(1)
--            self.m_hall_union_btn:setVisible(visible)
--            self.m_union_dialog:show();
--        end)
--    else
--        self.m_hall_union_btn:setVisible(visible);
--         伸展动画
--        local anim = self.m_hall_union_btn:addPropTranslateWithEasing(2, kAnimNormal, 300, -1, "easeOutBack", function (...) return 0 end, -25, 25, 0, 0)
--        anim:setEvent(nil, function ()
--            self.m_hall_union_btn:removeProp(2)

--        end)   
--    end; 
--end

HallScene.loadLocalUnreadMsgs = function(self)
    local chatRoomList = UserInfo.getInstance():getChatRoomList();
    if chatRoomList then
        for i = 1, #chatRoomList do
            local id;
            if chatRoomList[i].id == "1001" then
                id = UserInfo.getInstance():getProvinceCode();
            else
                id = chatRoomList[i].id;
            end;
            if self:chatIsHasUnreadMsgs(id) then return end;
        end;
    end;
    local friendChatList = FriendsData.getInstance():getChatList();
    if friendChatList then
        for i = 1, #friendChatList do
            if friendChatList[i] then
                local id = friendChatList[i].uid;
                if self:chatIsHasUnreadMsgs(id) then return end;
            end;
        end;
    end;
    self:changeUnreadMsgNum(false);
end;

HallScene.chatIsHasUnreadMsgs = function(self, id)
    local unReadMsg = GameCacheData.getInstance():getBoolean(GameCacheData.CHAT_IS_HAS_UNREAD_MSG..UserInfo.getInstance():getUid().."_"..(id or "default"),false);
    if unReadMsg then
        self:changeUnreadMsgNum(true);
        return true;
    end;
end;


-- room_id:大师场传php的1000
-- 同城聊天室传city_code
HallScene.entryChatRoom = function(self,room_id)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.CHESS_MANUAL)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.HALL_CHAT)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.RECEIVE_REWARD)
    self:requestCtrlCmd(HallController.s_cmds.entryChatRoom, room_id);
end;

HallScene.onEntryChatRoom = function(self ,data)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.CHESS_MANUAL)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.HALL_CHAT)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.RECEIVE_REWARD)
    self.m_hall_chat_dialog:setEntryChatRoom(data);
end;

HallScene.onShareClick = function(self)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.CHESS_MANUAL)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.HALL_CHAT)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.RECEIVE_REWARD)
    self:requestCtrlCmd(HallController.s_cmds.share);
end

HallScene.onDailyTaskBtnClick = function(self)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.CHESS_MANUAL)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.HALL_CHAT)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.RECEIVE_REWARD)
    
    if not self.m_controller:isLogined() then return ;end
    StatisticsManager.getInstance():onCountToUM(HALL_MODEL_TASK_BTN)
    StateMachine.getInstance():pushState(States.task,StateMachine.STYPE_CUSTOM_WAIT);
end

HallScene.onShowDailyTask = function(self)
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

HallScene.getSignReward = function(self)
    local tips = "领取中...";
    local post_data = {};
    post_data.mid = UserInfo.getInstance():getUid();
    HttpModule.getInstance():execute(HttpModule.s_cmds.getSignReward,post_data,tips);
end

require("dialog/start_dialog");
HallScene.showStartDialog = function(self)
    
    local start_config_json = GameCacheData.getInstance():getString(GameCacheData.START_CONFIG,"");
    if start_config_json == "" then
        return
    end
    local start_config = json.decode(start_config_json);
    if not start_config.is_open or start_config.is_open == 0 then
        return;
    end

    if not self.startDialog then
        self.startDialog = new(StartDialog,start_config);
    end
    self.startDialog:show();
end
if kPlatform == kPlatformIOS then
    HallScene.iosAuditStatus = function (self)
        -- ios 审核关闭大厅聊天和更多，版本号
        if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
--            self.m_version:setVisible(true);
            self.m_hall_activity_btn:setVisible(true);
            self.m_task_btn:setVisible(true)
            self.m_task_btn_handler:setVisible(true)
            self.m_attire_btn:setVisible(true)
            self.m_bottom_menu:setVisible(true)
            self.m_root:getChildByName("bottom_menu_bg"):setVisible(true)
            self.mWatchView:setVisible(true)
        else
--            self.m_version:setVisible(false);
            self.m_hall_activity_btn:setVisible(false);
            self.m_task_btn:setVisible(false)
            self.m_task_btn_handler:setVisible(false)
            self.m_attire_btn:setVisible(false)
            self.m_bottom_menu:setVisible(false)
            self.m_root:getChildByName("bottom_menu_bg"):setVisible(false)
            self.mWatchView:setVisible(false)
        end; 
    end
end;

function HallScene.showMailTips(self)
    self.m_mail_btn:getChildByName("pos"):setVisible(true);
end

function HallScene.showHallChatDialog(self)
    if not self.m_hall_chat_dialog then
        self.m_hall_chat_dialog = new(HallChatDialog, self)
    end
    self.m_hall_chat_dialog:entrySysNoticeRoom()
    self.m_hall_chat_dialog:show()
end

function HallScene:startRefreshPush()
    if UserInfo.getInstance():isLogin() then
        TimerHelper.registerSecondEvent(self,self.refreshPush)
        self:refreshPush(true)
    end
end

function HallScene.showComeBackRewardDialog(self,reward) 
    if reward  then 
        self.comeback_reward_dialog = new (ComeBackRewardDialog);
        self.comeback_reward_dialog:setGoldenNumTex(reward);
        self.comeback_reward_dialog:show();
    end  
end

function HallScene:refreshPush(isForce)
    if isForce or not self.mRefreshPushTime or os.time() - self.mRefreshPushTime > 600 then
        self.mRefreshPushTime = os.time()
        HttpModule.getInstance():execute2(HttpModule.s_cmds.MatchHallRecommend,{},function(isSuccess,resultStr)
            if isSuccess then
                local data = json.decode(resultStr)
                if not data or data.error then 
                    return
                end
                local params = data.data
                local func = nil
                if params and params.type == 1 then
                    local matchid = params.match_id
                    if matchid then
                        local roomType = RoomProxy.getRoomTypeByMatchId(matchid)
                        func = function()
                            if UserInfo.getInstance():isFreezeUser() then return end
                            -- 断线重连也是要获取当前胜率
                            if kPlatform == kPlatformIOS then
                                if tonumber(UserInfo.getInstance():getIosAuditStatus()) == 0 then return end;
                                if tonumber(UserInfo.getInstance():getCanShowIOSAppstoreReview()) == 0 then return end;
                                self.lastRate = UserInfo.getInstance():getRateNum();
                            end
                            CompeteScene.s_join_match_match_room_id = matchid
                            StateMachine.getInstance():pushState(States.Compete,StateMachine.STYPE_CUSTOM_WAIT);
                        end
                        if roomType == RoomConfig.ROOM_TYPE_METIER_ROOM then
                            self.m_push_icon:setFile("common/decoration/match_dec.png")
                            self.m_push_icon:setSize(self.m_push_icon.m_res:getWidth(),self.m_push_icon.m_res:getHeight());
                            self.m_push_txt:setFile("hall/txt_3.png")
                        elseif roomType == RoomConfig.ROOM_TYPE_MONEY_MATCH_ROOM then
                            self.m_push_icon:setFile("common/decoration/money_match_dec.png")
                            self.m_push_icon:setSize(self.m_push_icon.m_res:getWidth(),self.m_push_icon.m_res:getHeight());
                            self.m_push_txt:setFile("hall/txt_2.png")
                        else
                            func = nil
                        end
                    end
                end

                if func then
                    self.m_push_btn:setOnClick(self,func)
                else
                    self.m_push_icon:setFile("common/decoration/board_dec.png")
                    self.m_push_icon:setSize(self.m_push_icon.m_res:getWidth(),self.m_push_icon.m_res:getHeight());
                    self.m_push_btn:setOnClick(self,self.onHallQuickPlayBtnClick)
                end

            else
                self.m_push_icon:setFile("common/decoration/board_dec.png")
                self.m_push_icon:setSize(self.m_push_icon.m_res:getWidth(),self.m_push_icon.m_res:getHeight());
                self.m_push_btn:setOnClick(self,self.onHallQuickPlayBtnClick)
            end
        end)
    end
end

function HallScene:setMenuVisible(visible)
    if self.isShowMenu == visible then return end
    if visible then
        self.m_menu_btn:setFile("common/button/down_btn.png")
        self:showMenuUpAnim()
    else
        self.m_menu_btn:setFile("common/button/up_btn.png")
        self:showMenuDownAnim()
    end
    self.isShowMenu = visible
--    self.m_menu_view:setVisible(visible)
end

function HallScene:showMenuUpAnim()
    self.m_menu_view:getChildByName("bg"):removeProp(1)
    local w,h = self.m_menu_view:getSize()
    self.m_menu_view:getChildByName("bg"):addPropTranslate(1,kAnimNormal,200,-1,0,0,h,0)
end

function HallScene:showMenuDownAnim()
    self.m_menu_view:getChildByName("bg"):removeProp(1)
    local w,h = self.m_menu_view:getSize()
    self.m_menu_view:getChildByName("bg"):addPropTranslate(1,kAnimNormal,200,-1,0,0,0,h)
end

function HallScene:checkGuiTip()
    if not UserInfo.getInstance():isLogin() then return end
	local keys = GameCacheData.getInstance():getString(GameCacheData.RECENT_DAPU_KEY .. UserInfo.getInstance():getUid(),"")
    if keys ~= "" and NoviceBootProxy.getInstance():isFirstShow(NoviceBootProxy.s_constant.CHESS_MANUAL) then
        local guideTip = NoviceBootProxy.getInstance():getGuideTipView(NoviceBootProxy.s_constant.CHESS_MANUAL)
        guideTip:setAlign(kAlignCenter)
        local w,h = self.m_qipu_btn:getSize()
        guideTip:setTipSize(w,h)
        guideTip:startAnim()
        guideTip:setTopTipText("#c4bff4b点击这里#n,去回顾下精彩对局吧!",-80,110,250,50,80)
        self.m_qipu_btn_handler:addChild(guideTip)
        NoviceBootProxy.getInstance():setGuideTipViewShowTime(NoviceBootProxy.s_constant.CHESS_MANUAL)
    end

    self:startShowHallChatTipAnim()
end

function HallScene:startShowHallChatTipAnim()
    if NoviceBootProxy.getInstance():isGuideTipViewNil(NoviceBootProxy.s_constant.CHESS_MANUAL) then
        if NoviceBootProxy.getInstance():isFirstShow(NoviceBootProxy.s_constant.HALL_CHAT) then
            self:stopShowHallChatTipAnim()
            self.mShowHallChatTipAnim = AnimFactory.createAnimInt(kAnimNormal,0,1,1,7000)
            self.mShowHallChatTipAnim:setEvent(self,self.showHallChatTip)
        end
    end
end

function HallScene:stopShowHallChatTipAnim()
    if self.mShowHallChatTipAnim then
        delete(self.mShowHallChatTipAnim)
        self.mShowHallChatTipAnim = nil
    end
end

function HallScene:showHallChatTip()
    self:stopShowHallChatTipAnim()
    local guideTip = NoviceBootProxy.getInstance():getGuideTipView(NoviceBootProxy.s_constant.HALL_CHAT)
    guideTip:setAlign(kAlignCenter)
    local w,h = self.m_chat_btn:getSize()
    guideTip:setTipSize(w+25,h+10)
    guideTip:startAnim()
    guideTip:setTopTipText("#c4bff4b同城好友#n和#c4bff4b棋社好友#n都在这里等你噢!",-80,110,250,50,80)
    self.m_chat_btn_handler:addChild(guideTip)
    NoviceBootProxy.getInstance():setGuideTipViewShowTime(NoviceBootProxy.s_constant.HALL_CHAT)
end

function HallScene:updatePromotionSaleGoods()
    local data = UserInfo.getInstance():getPromotionSaleGoodsData()
    if not data then self:dismissPromotionSaleGoods() return end

    if data.status == 1 then
        self:showPromotionSaleGoods()
    else
        self:dismissPromotionSaleGoods()
    end
end

function HallScene:showPromotionSaleGoods()
--    if kPlatform == kPlatformIOS and tonumber(UserInfo.getInstance():getIosAuditStatus()) == 0 then return end
    self.mPromotionBtn:setVisible(true)
    self:promotionSaleGoodsCountDown()
    TimerHelper.registerSecondEvent(self,self.promotionSaleGoodsCountDown)
end

function HallScene:promotionSaleGoodsCountDown()
    local data = UserInfo.getInstance():getPromotionSaleGoodsData()
    if data and tonumber(data.endTime) then
        local text = self.mPromotionBtn:getChildByName("time_bg"):getChildByName("time_txt")
        local countDownTime = tonumber(data.endTime) - os.time()
        if countDownTime > 0 then
            text:setText( ToolKit.skipTime(countDownTime) )
        else
            self:dismissPromotionSaleGoods()
        end
    end
end

function HallScene:dismissPromotionSaleGoods()
    self.mPromotionBtn:setVisible(false)
    TimerHelper.unregisterSecondEvent(self,self.promotionSaleGoodsCountDown)
end
require(DIALOG_PATH .. "promotionSaleGoodsDialog")
function HallScene:showBuyPromotionSaleGoodsDialog()
    local data = UserInfo.getInstance():getPromotionSaleGoodsData()
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.CHESS_MANUAL)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.HALL_CHAT)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.RECEIVE_REWARD)
    if not data or data.status ~= 1 then return end
    if not self.mPromotionSaleGoodsDialog then
        self.mPromotionSaleGoodsDialog = new(PromotionSaleGoodsDialog)
        self.mPromotionSaleGoodsDialog:setPaySuccessCallBack(self,self.updatePromotionSaleGoods)
    end
    self.mPromotionSaleGoodsDialog:setData(data)
    self.mPromotionSaleGoodsDialog:show()
end

--首次领取任务的新手引导
function HallScene.showTaskGuideTip(self)
    if NoviceBootProxy.getInstance():isFirstShow(NoviceBootProxy.s_constant.RECEIVE_REWARD) then 
        local guideTip = NoviceBootProxy.getInstance():getGuideTipView(NoviceBootProxy.s_constant.RECEIVE_REWARD)
        guideTip:setAlign(kAlignCenter)    
        local w,h = self.m_task_btn:getSize()
        guideTip:setTipSize(w,h)
        guideTip:startAnim()
        guideTip:setBottomTipText(HallScene.TASK_GUIDE_TIP,-25,110,150,50,20)
        self.m_task_btn_handler:addChild(guideTip)
        NoviceBootProxy.getInstance():setGuideTipViewShowTime(NoviceBootProxy.s_constant.RECEIVE_REWARD)
    end 
end 
----------------------------------- config ------------------------------
HallScene.s_controlConfig = 
{
    [HallScene.s_controls.name]                     = {"userinfo_view","name"};
    [HallScene.s_controls.level_img]                = {"userinfo_view","score_bg","level_img"};
    [HallScene.s_controls.money_view]               = {"userinfo_view","userinfo_view_bg","money_view"};
    [HallScene.s_controls.add_money_btn]            = {"userinfo_view","userinfo_view_bg","add_money_btn"};
    [HallScene.s_controls.online_btn]               = {"content_view","online_btn"};
    [HallScene.s_controls.offline_btn]              = {"content_view","offline_btn"};
    [HallScene.s_controls.dapu_btn]                 = {"content_view","dapu_btn"};
    [HallScene.s_controls.hall_switch_server]       = {"hall_switch_server"};
    [HallScene.s_controls.hall_version]             = {"hall_version"};
    [HallScene.s_controls.icon_frame_mask]          = {"userinfo_view","icon_frame_stroke","icon_frame_mask"};
    [HallScene.s_controls.bottom_menu]              = {"bottom_menu"};
    [HallScene.s_controls.userinfo_view]            = {"userinfo_view"};
    [HallScene.s_controls.logo]                     = {"logo"};
    [HallScene.s_controls.content_view]             = {"content_view"};
    [HallScene.s_controls.hall_chat_btn]            = {"hall_chat_btn"};
--    [HallScene.s_controls.hall_union_btn]           = {"hall_union_btn"};
    [HallScene.s_controls.console_num_tx] = {"content_view","offline_btn","offline_num_img","offline_num_tx"};
    [HallScene.s_controls.online_num_tx] = {"content_view","online_btn","online_num_img","online_num_tx"};
    [HallScene.s_controls.match_num_tx] = {"content_view","dapu_btn","match_num_img","match_num_tx"};
};

HallScene.s_controlFuncMap =
{
	[HallScene.s_controls.online_btn]               = HallScene.onHallOnlineBtnClick;
	[HallScene.s_controls.offline_btn]              = HallScene.onHallOfflineBtnClick;
    [HallScene.s_controls.dapu_btn]                 = HallScene.onHallCompeteBtnClick;
    [HallScene.s_controls.hall_chat_btn]            = HallScene.onHallChatBtnClick;
--    [HallScene.s_controls.hall_union_btn]           = HallScene.onHallUnionBtnClick;
    [HallScene.s_controls.add_money_btn]            = HallScene.onHallAddMoneyBtnClick;
--    [HallScene.s_controls.activity_btn]             = HallScene.onActivityBtnClick;
};


HallScene.s_cmdConfig =
{
    [HallScene.s_cmds.update_user_money]            = HallScene.resetUserInfo;
    [HallScene.s_cmds.show_exit_dlg]                = HallScene.showExitDlg;
    [HallScene.s_cmds.has_playing_game]             = HallScene.hasPlayingGame;
    [HallScene.s_cmds.update_unread_msg]            = HallScene.changeUnreadMsgNum;
    [HallScene.s_cmds.show_update_guide]            = HallScene.showUpdateGuideDialog;
    [HallScene.s_cmds.show_account_dialog]          = HallScene.showAccountDialog;
    [HallScene.s_cmds.entry_chat_room]              = HallScene.onEntryChatRoom;
    [HallScene.s_cmds.show_start_dialog]            = HallScene.showStartDialog;
    [HallScene.s_cmds.ios_audit_status]             = HallScene.iosAuditStatus;
--    [HallScene.s_cmds.updata_union_dialog]          = HallScene.updataUnionDialog;
--    [HallScene.s_cmds.updata_union_member]          = HallScene.updataUnionMember;
    [HallScene.s_cmds.load_unread_msg]              = HallScene.loadLocalUnreadMsgs;
    [HallScene.s_cmds.show_mail_tips]               = HallScene.showMailTips;
    [HallScene.s_cmds.show_hall_chat]               = HallScene.showHallChatDialog;
    [HallScene.s_cmds.startRefreshPush]               = HallScene.startRefreshPush;
    [HallScene.s_cmds.show_comebackreward_dialog]     = HallScene.showComeBackRewardDialog;
    [HallScene.s_cmds.update_console_num]               = HallScene.updateConsoleNum;
    [HallScene.s_cmds.update_online_num]               = HallScene.updateOnlineNum;
    [HallScene.s_cmds.update_match_num]               = HallScene.updateMatchNum;
    [HallScene.s_cmds.update_promotion_sale_goods]     = HallScene.updatePromotionSaleGoods;
    
}