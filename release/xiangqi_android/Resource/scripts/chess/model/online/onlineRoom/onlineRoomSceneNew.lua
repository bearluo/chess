require(MODEL_PATH.."room/roomScene");
require("dialog/watch_chat_log_dialog");
require("dialog/user_info_dialog");
require("dialog/chioce_dialog");
require("dialog/chat_dialog");
require("dialog/account_dialog");
require("dialog/time_set_dialog")
require("dialog/time_picker_dialog");
require("dialog/match_dialog")
require("dialog/forestall_dialog");
require("dialog/forestall_dialog_new");
require("dialog/forestall_dialog_320");
require("dialog/forestall_wait_dialog_320");
require("dialog/loading_dialog")
require("dialog/online_box_reward_dialog");
require("dialog/handicap_dialog")
require("dialog/handicap_confirm_dialog")
require("dialog/startGameDialog")
require("dialog/loading_dialog2")
require("dialog/board_menu_dialog");
require("dialog/setting_dialog");
require("dialog/custom_input_pwd_dialog");
require("dialog/room_friend_setTime_dialog"); 
require("dialog/room_friend_setTime_show_dialog");
require("dialog/room_friend_wait_setTime_dialog"); 
require("dialog/room_friend_wait_settime_show_dialog");
require("dialog/watchlist_dialog");
require("dialog/watch_dialog");
require("dialog/chioce_dialog_with_icon");
require("dialog/thansize_dialog");
require("chess/util/onlineUserInfoCommonView")

--require("animation/countDown");
require(DATA_PATH .. "userSetInfo");
require("chess/util/statisticsManager");


require(MODEL_PATH .. "online/onlineRoom/module/onlineModule");
require(MODEL_PATH .. "online/onlineRoom/module/arenaModule");
require(MODEL_PATH .. "online/onlineRoom/module/watchModule");
require(MODEL_PATH .. "online/onlineRoom/module/customModule");  
require(MODEL_PATH .. "online/onlineRoom/module/friendModule");
require(MODEL_PATH .. "online/onlineRoom/module/moneyMatchModule");
require(MODEL_PATH .. "online/onlineRoom/module/metierMatchModule");


require(MODEL_PATH.."watchlist/watchlistScene");
require("chess/include/bottomMenu");
require("dialog/friend_chioce_dialog");
require(MODEL_PATH .. "giftModule/giftModuleAnimManager");


OnlineRoomSceneNew = class(RoomScene);

OnlineRoomSceneNew.IS_NEW = true; -- 观战新旧版本开关
OnlineRoomSceneNew.s_controls = 
{
    
}

OnlineRoomSceneNew.s_cmds = 
{
    exit_room               = 1;
    client_user_login_succ  = 2;
    client_msg_forestall    = 3;
    client_msg_relogin      = 4;
    client_msg_syndata      = 5;
    client_get_openbox_time = 6;
    client_msg_chat         = 7;
    client_msg_handicap     = 8;
    server_msg_gamestart    = 9;
    server_msg_gameclose    = 10;
    server_msg_warning      = 11;
    client_msg_move         = 12;
    client_msg_draw2        = 13;
    server_msg_draw         = 14;
    client_msg_undomove     = 15;
    client_msg_surrender2   = 16;
    server_msg_surrender    = 17;
    resume_from_homekey     = 19;
    show_net_state          = 20;
    set_time_info           = 21;
    update_prop_info        = 24;
    client_opp_user_login   = 25;
    server_msg_ready        = 26;
    server_msg_timecount_start = 27;
    server_msg_reconnect    = 28;
    server_msg_user_leave   = 29;
    server_msg_forestall    = 30;
    server_msg_logout_succ  = 31;
    server_msg_handicap     = 32;
    server_msg_handicap_result = 33;
    client_msg_draw1        = 35;
    client_user_login_error = 36;
    client_user_other_error = 37;
    setTime                 = 38;
    setTimeShow             = 39;
    forceLeave              = 41;
    invitFail               = 42;
    updateUserInfoDialog    = 43;
    server_msg_forestall_new = 44;
    server_msg_tips         = 47;
    updateWatchUserList     = 48;--更新dialog列表
    watchNumber             = 50; --观战人数
    callTelphoneResponse    = 51;
    callTelphoneBack        = 52;
    setDisconnect           = 53;
    save_mychess            = 54;
    forbid_user_msg         = 55;
    shareDialogHide         = 56;
    send_gift_return        = 57; --发送礼物结果返回
    ob_gift_msg             = 58; --观战礼物消息
    refresh_userinfo        = 59; --金币到账
    saveChessData           = 60; -- 获取复盘数据
    take_picture_complete   = 61; -- 截图完成
    save_chess_and_share    = 62; --  收藏分享
    get_watch_history_msg   = 63; -- 观战历史聊天消息
    setTimeResponse         = 67; -- 局时设置返回
    waitSetTime             = 68; -- 设置局时等待
    waitSetTimeShow         = 69; -- 等待对方同意局时设置
    server_msg_forestall_320 = 70;
    server_msg_handicap_confirm = 71;
    server_msg_game_start_info = 72;
    thanSizeGameReturn         =73;--小游戏回包
}

--------------------------------base function--------------------------------
OnlineRoomSceneNew.ctor = function(self,viewConfig,controller)
	self.m_ctrls = OnlineRoomSceneNew.s_controls;
    self:initView();
    call_native("BanDeviceSleep");
    self:startTime();
end 

OnlineRoomSceneNew.resume = function(self)
    RoomScene.resume(self);
    if not self.isFirst then
        self:initGame();
        self.isFirst = true;
    end
end

OnlineRoomSceneNew.pause = function(self)
	RoomScene.pause(self);
    AnimKill.deleteAll();
    AnimTimeout.deleteAll();
    AnimJam.deleteAll();
    self:clearDialog();
end 

OnlineRoomSceneNew.dtor = function(self)
    call_native("OpenDeviceSleep");
    HeadSmogAnim.deleteAll();
    ChatMessageAnim.deleteAll();
    ShowMessageAnim.deleteAll();
    ForestallAnim.deleteAll();
    RoomHomeScroll.deleteAll();
    BroadcastMessageAnim.deleteAll();
    AnimKill.deleteAll();
    AnimTimeout.deleteAll();
    AnimJam.deleteAll();
    delete(self.m_up_user_info_dialog);
    delete(self.m_down_user_info_dialog);
    delete(self.m_board_menu_dialog);
    delete(self.m_chat_dialog);
    delete(self.m_chioce_dialog);
    delete(self.m_setting_dialog);
    delete(self.m_timeoutAnim);
    delete(self.m_account_dialog);
    delete(self.m_forestall_dialog);
    delete(self.m_forestall_dialog_new);
    delete(self.m_forestall_dialog_320);
    delete(self.m_forestall_wait_dialog_320);
    
    delete(self.m_loading_dialog);
    delete(self.m_loading_dialog2);
    delete(self.m_handicap_dialog);
    delete(self.m_handicap_confirm_dialog);
    delete(self.mGameStartInfoDialog);
    delete(self.m_online_box_dialog);
    delete(self.m_timeAnim);
    delete(self.m_roomSetTimeDialog);
    delete(self.mRoomWaitSetTimeDialog)
    delete(self.m_roomOtherSetTimeDialog);
    delete(self.mRoomWaitOtherSetTimeDialog);
    delete(self.m_friendChoiceDialog);
    delete(self.m_ready_time_anim);
    delete(self.m_invit_time_anim);
    delete(self.m_heartBeatAnim);
    delete(self.m_watchList_dialog);
    delete(self.m_account_save_dialog);
    OnlineConfig.deleteTimer(self);
    OnlineConfig.deleteOpenBoxTimer();
--    delete(self.m_countdownAnim);
    delete(self.animTimer);
    delete(self.anim_end);
    delete(self.anim_start);
    delete(self.m_show_tip_dialog);
    TestAnim.deleteTestAnim();
    delete(self.m_match_dialog);
    delete(self.mModule);
    delete(self.m_rematch_dialog);
    delete(self.commonShareDialog)
    delete(self.m_up_view1)
    delete(self.m_up_user_tip_dialog);
    delete(self.m_thansize_dialog);
    self:clearRoomInfo();
    delete(OnlineRoomSceneNew.schedule_repeat_time)
    OnlineRoomSceneNew.schedule_repeat_time = nil
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.ONLINE_TREASURE_BOX)
end 

--------------------------------base function end--------------------------------

--注意初始化和重置部分

--------------------------------private function---------------------------------
--
OnlineRoomSceneNew.setAnimItemEnVisible = function(self,ret)
end

OnlineRoomSceneNew.resumeAnimStart = function(self,lastStateObj,timer)
    local duration = timer.duration;
    local delay = timer.waitTime + duration;
    local w,h = self:getSize();
    delete(self.anim_start)
    self.anim_start = new(AnimInt,kAnimNormal,0,1,delay);
    if self.anim_start then
        self.anim_start:setEvent(self,function()
            self.m_root:removeProp(1);
            delete(self.anim_start)
        end);
    end
    local roomType = RoomProxy.getInstance():getCurRoomType();
	if roomType == RoomConfig.ROOM_TYPE_WATCH_ROOM then
        if self.mModule and self.mModule.resumeAnimStart then
            self.mModule:resumeAnimStart(lastStateObj,timer);
        end
    end
end

OnlineRoomSceneNew.pauseAnimStart = function(self,newStateObj,timer)
    local duration = timer.duration;
    local delay = timer.waitTime + duration;
    local w,h = self:getSize();
    delete(self.anim_end);
    self.anim_end = new(AnimInt,kAnimNormal,0,1,duration,delay)
    if self.anim_end then
        self.anim_end:setEvent(self,function()
            self.m_root:removeProp(1);
            delete(self.anim_end);
        end);
    end
    local roomType = RoomProxy.getInstance():getCurRoomType();
	if roomType == RoomConfig.ROOM_TYPE_WATCH_ROOM then
        if self.mModule and self.mModule.pauseAnimStart then
            self.mModule:pauseAnimStart(newStateObj,timer);
        end
    end
end

--初始化数据（进入房间或切换房间类型时）
OnlineRoomSceneNew.initValues = function(self)
	self.m_upUser = nil;        --上部玩家对象（User）
	self.m_downUser = nil;      --下部玩家对象（User）
	self.m_tid = 0;             --房间tid号（Int）
	self.m_t_statuss = 0;       --房间状态标志（Int）
	self.m_gametype = 0;        --棋局类型  1 普通场	2 十分钟场 3 二十分钟场（Int）
    self.Undomovenum = 0;           --此盘棋局被强制悔棋的次数
	self.OpponentID = 0;            --将要被加金币的用户ID
	self.GetCoin = 0;               --因为对方悔棋，自己增加的金币
	self.isUndoAble = false;        --标记是否可悔棋
    self.m_stat_place = "联网房间"; --统计使用
	self.m_connectCount=0;          --Socket断线重连机制
    self.m_upPlayer_level = 2;--默认对手难度，1：稍逊一筹，2：不分伯仲，3：棋高一着

	self.m_timeout1 = 0;        --局时
	self.m_timeout2 = 0;        --步时
	self.m_timeout3 = 0;        --读秒
    -- 新的对手
    self.mNewPlayer = true
	---弹出框
    delete(self.m_account_dialog);
	self.m_account_dialog = nil;

end

OnlineRoomSceneNew.initView = function(self)
--初始化界面（只初始化一次,不要delete每个view）
    self.m_root_view = self.m_root;
    self.rotateBoard = false

    self.m_left_danmu_view = self.m_root_view:getChildByName("gift_danmu_view")
    self.m_room_bg= self.m_root_view:getChildByName("room_bg");
    local bg = UserSetInfo.getInstance():getBgImgRes();
    self.m_room_bg:setFile(bg or "common/background/room_bg.png");
    self.m_watch_gift_start_view = self.m_root_view:getChildByName("watch_gift_start_view");
    self.m_watch_gift_start_view:setLevel(99)
    self.m_left_gift_start_view = self.m_root_view:getChildByName("left_gift_start_view");
    self.m_right_gift_start_view = self.m_root_view:getChildByName("right_gift_start_view");
    self.m_down_right_gift_start_view = self.m_root_view:getChildByName("right_down_gift_start_view"); 
    self.m_top_gift_anim_view = self.m_root_view:getChildByName("top_gift_view");
    self.m_top_gift_anim_view:setLevel(99)

    --切换到聊天dialog背景
    self.room_bg_temp = self.m_root_view:getChildByName("room_bg_temp");

    self.m_room_time_text = self.m_root_view:getChildByName("room_time_bg"):getChildByName("room_time");
    self.m_room_time_text2 = self.m_root_view:getChildByName("watch_list_btn"):getChildByName("time_bg"):getChildByName("time_txt");
    self.m_back_btn = self.m_root_view:getChildByName("back_btn");
    self.m_back_btn:setTransparency(0.8);
    self.m_back_btn:setOnClick(self,self.back_action);
--    self.m_back_btn:setOnClick(self,function()
--        self.rotateBoard = not self.rotateBoard
--        if self.mModule.switchSide then
--            self.mModule:switchSide()
--        end
--        self:rotateChessBoard(self.rotateBoard)
--    end);
    
	--棋盘部分
	self.m_board_view = self.m_root_view:getChildByName("board");
	local boardBg = self.m_board_view:getChildByName("board_view");
    -- 棋盘适配
    local w,h = self.m_board_view:getSize();
    self.m_down_view = self.m_root_view:getChildByName("down_model");--确定底边
    local bx,by = self.m_down_view:getUnalignPos();
    local x,y = self.m_board_view:getUnalignPos();
    local pw = self.m_root_view:getSize();
    local ph = by - y;
    if pw > w and RoomProxy.getInstance():getCurRoomType() ~= RoomConfig.ROOM_TYPE_WATCH_ROOM then
        local diffh = ph - h; -- 增加的高
        local diffw = pw - w; -- 增加的高
        local add = math.min(diffw,diffh);
        local scale = (w+add)/w;
	    self.m_board_view:setSize(w*scale,h*scale);
        local w,h = boardBg:getSize();
	    boardBg:setSize(w*scale,h*scale);
        self.m_board_bg = self.m_board_view:getChildByName("board_view"):getChildByName("board_bg");
        local w,h = self.m_board_bg:getSize();
	    self.m_board_bg:setSize(w*scale,h*scale);
    end
    -- 棋盘适配 end
	local w,h = boardBg:getSize();
	self.m_board = new(Board,w,h,self);
	self.m_board_view:addChild(self.m_board);
        --倍数
    self.m_multiple_img_bg =  boardBg:getChildByName("multiple_img_bg");
	self.m_multiple_text =  self.m_multiple_img_bg:getChildByName("multiple_text");
	self.m_multiple_text:setText("");

	--上部玩家信息模块
    self.m_up_view1 = new(OnlineUserInfoCommonView,OnlineUserInfoCommonView.ONLINE_UP)
    self.up_turn,self.up_breath1,self.up_breath2,self.m_up_gift_anim_view = self.m_up_view1:getAnimView()
    self.m_up_view1:setIconTouch(self,self.showUpUserInfo);
    self.m_root_view:addChild(self.m_up_view1)

	--上部玩家信息弹出框
    if not self.m_up_user_info_dialog then
        self.m_up_user_info_dialog = new(UserInfoDialog2);
    end
    self.m_up_user_info_dialog:setShowType(UserInfoDialog2.SHOW_TYPE.ONLINE_OTHER)
   
    --下部玩家信息弹出框
    if not self.m_down_user_info_dialog then
        self.m_down_user_info_dialog = new(UserInfoDialog2);
    end
    self.m_down_user_info_dialog:setShowType(UserInfoDialog2.SHOW_TYPE.ONLINE_ME)
	--下部信息
    self.m_down_view1 = new(OnlineUserInfoCommonView,OnlineUserInfoCommonView.ONLINE_DOWN)
    self.down_turn,self.down_breath1,self.down_breath2,self.m_down_gift_anim_view = self.m_down_view1:getAnimView()
    self.m_down_view1:setIconTouch(self,self.showDownUserInfo);
    self.m_root_view:addChild(self.m_down_view1)

    self.m_toast_bg = self.m_root_view:getChildByName("toast_bg");
    self.m_toast_text = self.m_toast_bg:getChildByName("toast_text");

    self.m_board_bg = self.m_board_view:getChildByName("board_view"):getChildByName("board_bg");

	--准备开始模块
	self.m_up_user_ready_img = self.m_board_view:getChildByName("board_view"):getChildByName("board_bg"):getChildByName("up_user_ready_img");  --上准备图片
	self.m_down_user_ready_img = self.m_board_view:getChildByName("board_view"):getChildByName("board_bg"):getChildByName("down_user_ready_img"); -- 下准备图片
	self.m_down_user_start_btn = self.m_board_view:getChildByName("down_user_start_btn"); --下开始按钮
	self.m_down_user_start_btn:setLevel(BUTTON_VISIBLE_LEVEL);
	self.m_down_user_start_btn:setOnClick(self,self.ready_action);
    self.m_private_change_player_btn = self.m_board_view:getChildByName("private_change_player_btn"); --私人房踢人按钮  
    self.m_private_change_player_btn:setLevel(BUTTON_VISIBLE_LEVEL);
    self.m_private_invite_friends_btn = self.m_board_view:getChildByName("private_invite_friends_btn"); --私人房邀请好友按钮  
    self.m_private_invite_friends_btn:setLevel(BUTTON_VISIBLE_LEVEL);

    --在线宝箱
	self.m_chest_btn = self.m_root_view:getChildByName("chest_btn");   
    self.m_chest_icon = self.m_chest_btn:getChildByName("chest");
    self.m_chest_anim_bg = self.m_chest_btn:getChildByName("chest_anim_bg");
    self.m_chest_btn:setEnable(false);
    self.m_chest_icon:setVisible(false);
    self.m_chest_anim_bg:setVisible(false);
	self.m_chest_btn:setOnClick(self,self.chest_action);
    self.m_online_time_text_bg = self.m_chest_btn:getChildByName("chest_open_time_bg")
    self.m_online_time_text = self.m_online_time_text_bg:getChildByName("online_time_text");

    --比大小小游戏
    self.m_thansize_btn = self.m_root_view:getChildByName("thansize_btn");
    self.m_thansize_btn:setOnClick(self,self.thansize_btnClick);

    --下部菜单模块
	self.m_room_menu_view = self.m_root_view:getChildByName("room_menu");
	self.m_chat_btn = self.m_room_menu_view:getChildByName("chat_btn");     --聊天按钮
	self.m_menu_btn = self.m_root_view:getChildByName("menu_btn");     --菜单按钮
    self.m_menu_image = self.m_menu_btn:getChildByName("menu_image");   
    self.m_chat_btn:getChildByName("notice"):setVisible(false);
	self.m_chat_btn:setOnClick(self,self.chat_action);
	self.m_menu_btn:setOnClick(self,self.menuToggle);
    if kPlatform == kPlatformIOS then	
        --ios审核关闭聊天和在线宝箱
        if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
            self.m_chat_btn:setVisible(true);
            self.m_chest_btn:setVisible(true);
        else
            self.m_chat_btn:setVisible(false);
            self.m_chest_btn:setVisible(false);
        end;
    end;
    -- restart_view
    self.m_restart_view = self.m_root_view:getChildByName("restart_view"); --重新开始  
    self.m_restart_view:setLevel(101)
    local sw,sh = self.m_board_view:getSize();
    local px,py = self.m_board_view:getPos();
    local rw, rh = self.m_root_view:getSize();
    self.m_restart_view:setSize(nil,rh - (py + sh + 8));
    self.m_restart_view_bg = self.m_restart_view:getChildByName("bg");
    self.m_restart_view_bg:setTransparency(0.6);
    self.m_restart_view_bg:setEventTouch(self,function()end);
    self.m_restart_btn = self.m_restart_view:getChildByName("restart_btn"); --重新匹配  
    self.m_restart_btn:setOnClick(self,self.onReStartGame);
    self.m_back_btn2 = self.m_restart_view:getChildByName("back_btn"); --再来一局
    self.m_back_btn2:setOnClick(self,self.back_action);
    self.m_restart_btn1 = self.m_restart_view:getChildByName("restart_btn1"); --重新匹配  
    self.m_restart_btn1:setOnClick(self,self.reMatch);
    self.m_play_again_btn = self.m_restart_view:getChildByName("play_again_btn"); --再来一局
    self.m_play_again_btn:setOnClick(self,self.playAgain);
    self:updateRestartView(false)
	--dialog
    self.m_board_menu_dialog = new(BoardMenuDialog,self);
    self.m_chat_dialog = new(ChatDialog,self);
    self:getNetStateLevel();

    -- 等待提示

    self.m_wait_tips = self.m_root_view:getChildByName("wait_bg");
    self.m_wait_tips:setVisible(false);

    --初始化各个模块

    --设置棋盘图片
    self.m_board_bg:setFile(UserSetInfo.getInstance():getBoardRes());

    
    self.m_roomid_text = self.m_root_view:getChildByName("roomid"):getChildByName("roomid_text");    
    self.m_roomid = self.m_root_view:getChildByName("roomid");
    self.m_room_watcher_btn = self.m_root_view:getChildByName("watch_list_btn");
    self.m_room_watcher_btn:setEnable(false);  --觀戰按鈕
    self.m_room_watcher_btn:setOnClick(self,self.gotoWatchList);
    self.m_room_watcher = self.m_room_watcher_btn:getChildByName("room_watcher_count_text");
    -- 初始化礼物效果
    self:setIsWatchGiftAnim(false)

    local roomType = RoomProxy.getInstance():getCurRoomType();
    delete(self.mModule);
    if roomType == RoomConfig.ROOM_TYPE_WATCH_ROOM then            --观战
        self.mModule = new(WatchModule,self);
    elseif roomType == RoomConfig.ROOM_TYPE_PRIVATE_ROOM then   --私人战
        self.mModule = new(CustomModule,self);
	elseif roomType == RoomConfig.ROOM_TYPE_FRIEND_ROOM then       --好友战 
        self.mModule = new(FriendModule,self);
	elseif roomType == RoomConfig.ROOM_TYPE_ARENA_ROOM then       --竞技场   
        self.mModule = new(ArenaModule,self);
    elseif roomType == RoomConfig.ROOM_TYPE_MONEY_MATCH_ROOM then  -- 金币比赛场
        self.mModule = new(MoneyMatchModule,self);
    elseif roomType == RoomConfig.ROOM_TYPE_METIER_ROOM then  -- 职业赛
        self.mModule = new(MetierMatchModule,self);
    else -- 其他房间默认
        self.mModule = new(OnlineModule,self);
    end
    self:onResetGame();
end

function OnlineRoomSceneNew.changeRoomType(self,targetRoomType)

    local roomType = RoomProxy.getInstance():getCurRoomType();
    if targetRoomType == roomType then return end
    RoomProxy.getInstance():changeRoomType(targetRoomType);
    delete(self.mModule);
    if targetRoomType == RoomConfig.ROOM_TYPE_WATCH_ROOM then            --观战
        self.mModule = new(WatchModule,self);
    elseif targetRoomType == RoomConfig.ROOM_TYPE_PRIVATE_ROOM then   --私人战
        self.mModule = new(CustomModule,self);
	elseif targetRoomType == RoomConfig.ROOM_TYPE_FRIEND_ROOM then       --好友战   
        self.mModule = new(FriendModule,self);
	elseif roomType == RoomConfig.ROOM_TYPE_ARENA_ROOM then       --竞技场  
        self.mModule = new(ArenaModule,self);
    elseif roomType == RoomConfig.ROOM_TYPE_MONEY_MATCH_ROOM then  -- 金币比赛场
        self.mModule = new(MoneyMatchModule,self);
    elseif roomType == RoomConfig.ROOM_TYPE_METIER_ROOM then  -- 职业赛
        self.mModule = new(MetierMatchModule,self);
    else -- 其他房间默认
        self.mModule = new(OnlineModule,self);
    end
    self:onResetGame();
    self:initGame();
end

--根据房间类型的初始化界面
OnlineRoomSceneNew.initGame = function(self)
    if kPlatform == kPlatformIOS then
        --ios审核关闭聊天和在线宝箱
        if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
            self.m_chat_btn:setVisible(true);
            self.m_chest_btn:setVisible(true);
        else
            self.m_chat_btn:setVisible(false);
            self.m_chest_btn:setVisible(false);
        end;
    else
	    self.m_chest_btn:setVisible(true);      --底部菜单栏【宝箱按钮】
	    self.m_chat_btn:setVisible(true);       --底部菜单栏【聊天按钮】	
    end;
	-- self.m_menu_btn:setVisible(true);       --底部菜单栏【菜单按钮】
--	self.m_down_name:setVisible(true);
--	self.m_up_name:setVisible(true);
    self:showNetSinalIcon(true);

    self.mModule:initGame();
end

--重置房间界面（切换房间类型的时候使用，重置数据、重置界面可见性、重置dialog可见性）
OnlineRoomSceneNew.onResetGame = function(self)
    GiftModuleAnimManager.stopAllPropAnim()
    GiftLog.getInstance():deleteUserGift()
    --初始化数据
    self.m_animPool = {}
    self.m_isPlayingGiftAnim = false;
    self:initValues();
    --初始化可见性 
	self.m_up_user_ready_img:setVisible(false);     --隐藏上部准备图片
	self.m_down_user_ready_img:setVisible(false);   --隐藏下部准备图片
--	self.m_up_user_icon:setVisible(false);          --隐藏上部玩家头像
    self.m_up_view1:resetIconView()
	self.up_turn:setVisible(false);
    self.down_turn:setVisible(false);
--    self.m_down_user_icon:setVisible(false);          --隐藏上部玩家头像
--	self.m_down_turn:setVisible(false);
--    self.m_up_user_info_dialog_view:setVisible(false);
--    self.m_down_user_info_dialog_view:setVisible(false);
	self:setTimeFrameVisible(false);
    self.m_down_user_start_btn:setVisible(false);
    self.m_private_change_player_btn:setVisible(false);
    self.m_private_invite_friends_btn:setVisible(false);
    
    self.m_board:dismissChess();        --隐藏棋子
--    self.m_up_vip_logo:setVisible(false);  --隐藏上部玩家vip图标
--    self.m_up_vip_frame:setVisible(false);
    self.m_wait_tips:setVisible(false);

    self.m_board:removeProp(20)
    self:rotateChessBoard(false)


    self.mModule:resetGame();
    self:clearDialog();
end

--清理房间数据（退出房间或者切换房间类型之前调用）
OnlineRoomSceneNew.clearRoomInfo = function(self)
    --重置房间配置
	RoomProxy.getInstance():setTid(0);       --房间ID号
	RoomProxy.getInstance():setMatchId(0);  --比赛ID号
	UserInfo.getInstance():setSeatID(0);    --
    RoomProxy.getInstance():setOBSvid(0);    --    
	UserInfo.getInstance():setStatus(STATUS_PLAYER_LOGOUT); --个人状态
	self:stopTimeout(); --停止游戏计时
    self:setStatus(STATUS_TABLE_STOP);  --房间状态重置
	ToolKit.removeAllTipsDialog(); 
    self.m_login_succ = false
    if self.m_upUser then
        self:userLeave(self.m_upUser:getUid(),false);
    end;
    if self.m_up_view1 and self.m_up_view1.user_disconnect then
        self.m_up_view1.user_disconnect:setVisible(false);
    end
    if self.m_down_view1 and self.m_down_view1.user_disconnect then
        self.m_down_view1.user_disconnect:setVisible(false);
    end
--    self.m_up_user_disconnect:setVisible(false);
--    self.m_down_user_disconnect:setVisible(false);
    self.m_up_user_ready_img:setVisible(false);
    self.m_down_user_ready_img:setVisible(false);
--    self.m_board:dismissChess();
    self.m_private_change_player_btn:setVisible(false);
    self.m_private_invite_friends_btn:setVisible(false);
end;

--更换房间，清理部分数据（在匹配成功后点击更换对手）
OnlineRoomSceneNew.clearChangeInfo = function(self)
    --重置房间配置
	RoomProxy.getInstance():setTid(0);       --房间ID号
	UserInfo.getInstance():setSeatID(0);    --
    RoomProxy.getInstance():setOBSvid(0);    --    
    UserInfo.getInstance():setStatus(STATUS_PLAYER_LOGOUT); --个人状态
    self:stopTimeout(); --停止游戏计时
    self:setStatus(STATUS_TABLE_STOP);  --房间状态重置
    ToolKit.removeAllTipsDialog(); 
    self.m_board:dismissChess();
    self.changeRoom = false;
    self.mNewPlayer = true
    self.m_up_view1:resetIconView()
--    self.m_up_user_icon:setFile(User.MAN_ICON);
--	HeadSmogAnim.play(self.m_up_user_icon);
--    self.m_up_name:setText("");
    self.up_turn:setVisible(false);
--	self.m_up_user_icon:setVisible(false);
	self.m_up_user_ready_img:setVisible(false);
--    self.m_up_vip_frame:setVisible(false);
--    self.m_up_vip_logo:setVisible(false);
    self.m_board:dismissChess();
    self.m_upUser = nil;
    if self.m_roomSetTimeDialog then
        self.m_roomSetTimeDialog:dismiss();
    end
    if self.mRoomWaitSetTimeDialog then
        self.mRoomWaitSetTimeDialog:dismiss();
    end
    if self.m_roomOtherSetTimeDialog then
        self.m_roomOtherSetTimeDialog:dismiss();
    end
    if self.mRoomWaitOtherSetTimeDialog then
        self.mRoomWaitOtherSetTimeDialog:dismiss();
    end
    if self.m_up_view1 and self.m_up_view1.user_disconnect then
        self.m_up_view1.user_disconnect:setVisible(false);
    end
    if self.m_down_view1 and self.m_down_view1.user_disconnect then
        self.m_down_view1.user_disconnect:setVisible(false);
    end
--    self.m_up_user_disconnect:setVisible(false);
--    self.m_down_user_disconnect:setVisible(false);

    if self.m_match_dialog then
        self:reMatch()
--        if not self.m_match_dialog:isShowing() then
--            self.m_match_dialog:show(self,UserInfo.getInstance():getMatchTime());
--        end
--        self.m_login_succ = false
----        self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_logout);
--        self.m_matchIng = true;
--        self.m_match_dialog:rematch();
    end

end

--游戏是否结束
OnlineRoomSceneNew.isGameOver = function(self)
	return self.m_game_over ~= false;
end	

--设置是否可求和
OnlineRoomSceneNew.setEnableDraw =function(self,enableDraw)
	self.m_enableDraw = enableDraw;
end		

OnlineRoomSceneNew.isEnableDraw = function(self)
	return self.m_enableDraw or false;
end

--设置在线宝箱领取状态
OnlineRoomSceneNew.setEnableChess = function(self,enableChess)
	self.m_enableChess = enableChess;
end

OnlineRoomSceneNew.isEnableChess = function(self)
	return self.m_enableChess;
end

--设置是否可悔棋
OnlineRoomSceneNew.setEnableUndo =function(self,enableUndo)
	self.m_enableUndo = enableUndo;
end		

OnlineRoomSceneNew.isEnableUndo = function(self)

	if not self.m_first_move then
		return false;
	end
	return self.m_enableUndo or false;
end

--设置是否可认输
OnlineRoomSceneNew.setEnableSurrender =function(self,enableSurrender)
	self.m_enableSurrender = enableSurrender;
end		

OnlineRoomSceneNew.isEnableSurrender = function(self)
    return self.m_enableSurrender;
end

--判断是否准备状态
OnlineRoomSceneNew.setStartReadyVisible = function(self)
	if self.m_downUser then
		self.m_down_user_ready_img:setVisible(self.m_downUser:getReadyVisible());
		self.m_down_user_start_btn:setVisible(false);
        self.m_private_change_player_btn:setVisible(false);
        self.m_private_invite_friends_btn:setVisible(false);
	end

	if self.m_upUser then
		self.m_up_user_ready_img:setVisible(self.m_upUser:getReadyVisible());
	end

	local roomType = RoomProxy.getInstance():getCurRoomType();

	if roomType == RoomConfig.ROOM_TYPE_WATCH_ROOM then  --如果是观战房间  --不要显示开始按键
		self.m_down_user_start_btn:setVisible(false);
        self.m_private_change_player_btn:setVisible(false);
        self.m_private_invite_friends_btn:setVisible(false);
	end
end

--Home键返回
OnlineRoomSceneNew.onResumeFromHomekey = function(self)
	--同步棋盘信息
	if self:isGameOver() then
		print_string("Room.onHomeResume but gameover");
		return;
	end
	self:synchroRequest();    
end

OnlineRoomSceneNew.setBoradCode = function(self, code)
    self.m_boradcode = code;
end;

OnlineRoomSceneNew.stopHeartBeat = function(self)
	delete(self.m_heartBeatAnim);
	self.m_heartBeatAnim = nil;
end

OnlineRoomSceneNew.sharePicture = function(self)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.sharePicture);
end
--------------------------------private function end-------------------------------

--------------------------------response function---------------------------------
--[[
    联网房流程：初始化房间->下(上)部玩家进入->匹配对手->登陆房间->准备->设置局时(抢先、让子)->Server通知游戏开始->下棋(悔棋、聊天、求和、认输)->棋局结束
    私人流程：初始化房间->下(上)部玩家进入->登陆房间->准备->Server通知游戏开始->开始下棋->棋局结束
    好友流程：初始化房间->下(上)部玩家进入->登陆房间->准备(同时发起挑战邀请)->设置局时(抢先、让子)->Server通知游戏开始->开始下棋->棋局结束
    观战流程：
    *注意断线重连部分
--]]

--登陆房间成功
OnlineRoomSceneNew.onClientUserLoginSucc = function(self, data)
    self.m_login_succ = true;
    if data.user then
        if self.m_match_dialog and self.m_match_dialog:isShowing() then
	        self.mModule:onMatchSuccess(data);  
	    end
        self:upComeIn(data.user);
    end
    if RoomProxy.getInstance():getCurRoomType() ~= RoomConfig.ROOM_TYPE_WATCH_ROOM then
        self:downComeIn(UserInfo.getInstance());
    end

    if RoomProxy.getInstance():getCurRoomType() == RoomConfig.ROOM_TYPE_FRIEND_ROOM then
        self:ready_action()
    end

    if RoomProxy.getInstance():getCurRoomType() == RoomConfig.ROOM_TYPE_PRIVATE_ROOM then
        -- argly!argly!argly!：聊天室约战自动准备
        if UserInfo.getInstance():getCustomRoomType() == 2 then
            self:ready_action()
            -- 上家没有入场
            if not self.m_upUser then
                ToolKit.schedule_union_once(self,function() 
                    ChessToastManager.getInstance():showSingle("玩家没有入场，约战结束了",2000);
                end,10000);
            end;
        end;
    end
end

--登陆房间失败
OnlineRoomSceneNew.onClientUserLoginError = function(self, data)
   
    if data.errorCode == 5 then
        ChessToastManager.getInstance():showSingle("棋桌不存在");
    elseif data.errorCode == 7 then
        ChessToastManager.getInstance():showSingle("棋桌已满");
    elseif data.errorCode == 8 then
        local message = "竞技场未开放"
        if data.size > 0 then
            local time = data.times[1];
            message = string.format("竞技场对弈时间为%02d点%02d分-%02d点%02d分",time.start_hour,time.start_minute,time.end_hour,time.end_minute)
        end
        ChessToastManager.getInstance():showSingle(message);
    elseif data.errorCode == 9 then
        ChessToastManager.getInstance():showSingle("金币不足");
    elseif data.errorCode == 10 then
        ChessToastManager.getInstance():showSingle("金币超出上限");
    elseif data.errorCode == 11 then
        ChessToastManager.getInstance():showSingle("比赛场未开放");
        if data.size > 0 then
            local time = data.times[1];
            message = string.format("竞技场对弈时间为%02d点%02d分-%02d点%02d分",time.start_hour,time.start_minute,time.end_hour,time.end_minute)
        end
    elseif data.errorCode == 12 then
        ChessToastManager.getInstance():showSingle("比赛房间不存在");
    elseif data.errorCode == 13 then
        ChessToastManager.getInstance():showSingle("没有报名该场比赛");
    else
        ChessToastManager.getInstance():showSingle("请重新匹配");
    end
    self:exitRoom();
end;

OnlineRoomSceneNew.onReStartGame = function(self)
    self:updateRestartView(false);
    local roomType = RoomProxy.getInstance():getCurRoomType();
    if self.m_upUser then
        if roomType == RoomConfig.ROOM_TYPE_NOVICE_ROOM or 
           roomType == RoomConfig.ROOM_TYPE_INTERMEDIATE_ROOM or
           roomType == RoomConfig.ROOM_TYPE_MASTER_ROOM or
           roomType == RoomConfig.ROOM_TYPE_FRIEND_ROOM or 
           roomType == RoomConfig.ROOM_TYPE_PRIVATE_ROOM then
           self:sendReadyMsg();
        elseif roomType == RoomConfig.ROOM_TYPE_ARENA_ROOM then
            self:userLeave(self.m_upUser:getUid(),false);
            self.mModule:matchRoom();
        end;
        if self.m_account_dialog then
            self.m_account_dialog:stopTimer();
        end;
    else
        if roomType ~= RoomConfig.ROOM_TYPE_PRIVATE_ROOM and roomType ~= RoomConfig.ROOM_TYPE_FRIEND_ROOM then
            if self.mModule and self.mModule.matchRoom then
                self.mModule:matchRoom();
            end;
        end
    end;
end;

function OnlineRoomSceneNew:playAgain()
    self:updateRestartView(false);
    self:sendReadyMsg();
    if self.m_account_dialog then
        self.m_account_dialog:stopTimer();
    end;
end

function OnlineRoomSceneNew:updateRestartView(isVisible,isUpUserLeave)
    self.m_restart_view:setVisible(isVisible);
    if not self.m_upUser then isUpUserLeave = true end
    local roomType = RoomProxy.getInstance():getCurRoomType()
    if roomType == RoomConfig.ROOM_TYPE_ARENA_ROOM then
        -- 竞技场每一局换对手
        isUpUserLeave = true
    end
--    self.m_back_btn2:setVisible(isUpUserLeave or false)
    self.m_restart_btn:setVisible(isUpUserLeave or false)
    self.m_restart_btn1:setVisible(not isUpUserLeave)
    self.m_play_again_btn:setVisible(not isUpUserLeave)
end


--准备
OnlineRoomSceneNew.ready_action = function(self)
	print_string("OnlineRoomSceneNew.ready_action");
    self:onEventStat(ROOM_MODEL_START_BTN);
    
    local roomType = RoomProxy.getInstance():getCurRoomType()
	if self.mModule.canSendReadyAction and not self.mModule:canSendReadyAction() then
        return false
    end


    local money = UserInfo.getInstance():getMoney();
    local roomType = RoomProxy.getInstance():getCurRoomType();
	local isCanAccess = RoomProxy.getInstance():checkCanJoinRoom(roomType,money);
	if not isCanAccess then
		--破产
		self:collapse();
		return false
	end

    if self.m_down_user_start_btn then              --不知道为什么会被释放了，友盟BUG跟踪修复
	    self.m_down_user_start_btn:setVisible(false);
    end
    
    self.m_private_change_player_btn:setVisible(false);
    self.m_private_invite_friends_btn:setVisible(false);

    self.m_ready_status = true;
    self:requestCtrlCmd(OnlineRoomController.s_cmds.send_ready_msg);
	self.m_board:dismissChess();
    self.m_board_menu_dialog:dismiss();

	self.mModule:readyAction();
    return true
end

--下部玩家进入
OnlineRoomSceneNew.downComeIn = function(self, user, need_ready)
    Log.i("OnlineRoomSceneNew.onDownUserComeIn");
    if not user then
        return;
    end
    if self.mModule.downComeIn then
        self.mModule:downComeIn(user)
    end
    FriendsData.getInstance():getUserData(user:getUid());
--    if not self.m_downUser and self.m_down_user_icon then
--	    HeadSmogAnim.play(self.m_down_user_icon);
--    end
	self.m_downUser = user;
    self.m_down_view1:updateViewData(self.m_downUser)
    self.m_down_view1:updateVipData()
--    self.m_down_user_level_icon:setFile(string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevelByScore(user:getScore())));
--    self.m_down_name:setText(user:getName());
--	self.m_down_user_icon:setFile(UserInfo.DEFAULT_ICON[1]);
--	self.m_down_user_icon:setVisible(true);
--    self.m_down_user_disconnect:setVisible(false);
--	local iconType = tonumber(self.m_downUser:getIconType());

--    if iconType and iconType > 0 then
--        self.m_down_user_icon:setFile(UserInfo.DEFAULT_ICON[iconType] or UserInfo.DEFAULT_ICON[1]);
--    else
--        if iconType == -1 then
--            self.m_down_user_icon:setUrlImage(self.m_downUser:getIcon(),UserInfo.DEFAULT_ICON[1]);
--        end
--    end

	self.m_down_user_ready_img:setVisible(self.m_downUser:getReadyVisible());
	
	if need_ready then
		self.m_down_user_start_btn:setVisible(self.m_downUser:getStartVisible());
   	end
    self.m_down_view1:updataMoneyData(self.m_downUser:getMoneyStr())

end;

--上部玩家进入
OnlineRoomSceneNew.upComeIn = function(self, user, isSynDataComeIn)
    Log.i("OnlineRoomSceneNew.onUpUserComeIn");
    if not user then
        return;
    end
    if self.mModule.upComeIn then
        self.mModule:upComeIn(user)
    end

    FriendsData.getInstance():getUserData(user:getUid());
    if isSynDataComeIn and user:getUid()<=0 then
--		self.m_up_user_icon:setVisible(false);
		self.m_up_user_ready_img:setVisible(false);

--		self.m_up_name:setText("");
    else
        local roomType = RoomProxy.getInstance():getCurRoomType();
        -- 版本兼容
	    if roomType == RoomConfig.ROOM_TYPE_NOVICE_ROOM or 
            roomType == RoomConfig.ROOM_TYPE_INTERMEDIATE_ROOM or 
            roomType == RoomConfig.ROOM_TYPE_MASTER_ROOM
            then
            if user:getClient_version() > 0 and user:getClient_version() < 195 then     --低于1.9.5版本不支持局时设置
                ChessToastManager.getInstance():show("对方版本不支持设置局时",2000);
            end
	    end
--        if not self.m_upUser and self.m_up_user_icon then
--		    HeadSmogAnim.play(self.m_up_user_icon);
--        end
	    self.m_upUser = user;
        if roomType == RoomConfig.ROOM_TYPE_PRIVATE_ROOM then
            self.m_private_change_player_btn:setVisible(RoomProxy.getInstance():isSelfRoom() and self.m_upUser ~= nil and UserInfo.getInstance():getCustomRoomType()==0);
            self.m_private_invite_friends_btn:setVisible(RoomProxy.getInstance():isSelfRoom() and self.m_upUser == nil and UserInfo.getInstance():getCustomRoomType()==0);
        else
            self.m_private_change_player_btn:setVisible(false);
            self.m_private_invite_friends_btn:setVisible(false);
        end

        self.m_up_view1:updateViewData(self.m_upUser)
        self.m_up_view1:updateVipData()
--        self.m_up_user_level_icon:setFile(string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevelByScore(user:getScore())));
        --iconType有2类值，一种是头像url（对手头像是本地上传的）。一种是数字0（对手没有传过头像），1，2，3，4（系统自带的头像）
--        self.m_up_user_icon:setFile(UserInfo.DEFAULT_ICON[1]);
--        self.m_up_user_disconnect:setVisible(false);
        -- 重置屏蔽消息状态
        self.m_up_user_info_dialog:resetForbidStatus(self.m_upUser:getUid());
        
--        local iconType = tonumber(self.m_upUser:getIconType());

--        if iconType and iconType > 0 then
--            self.m_up_user_icon:setFile(UserInfo.DEFAULT_ICON[iconType] or UserInfo.DEFAULT_ICON[1]);
--        else
--            if iconType == -1 then
--                self.m_up_user_icon:setUrlImage(self.m_upUser:getIcon(),UserInfo.DEFAULT_ICON[1]);
--            end
--        end
--		self.m_up_user_icon:setVisible(true);
		self.m_up_user_ready_img:setVisible(self.m_upUser:getReadyVisible());
--		self.m_up_name:setText(user:getName());

--        local nx,nt = self.m_up_name:getPos();
--        local vw,vh = self.m_up_vip_logo:getSize();
--        local text = new(Text,self.m_up_name:getText(),nil,nil,nil,nil,32);
--        local nw,nh = text:getSize();
--        if self.m_upUser and self.m_upUser.m_vip and self.m_upUser.m_vip == 1 then
--            if not OnlineRoomSceneNew.IS_NEW then
--                self.m_up_vip_logo:setPos(nx - nw/2 - vw/2 - 3);
--            end;
--            self.m_up_vip_frame:setVisible(true);
--            self.m_up_vip_logo:setVisible(true)
--        else
--            if not OnlineRoomSceneNew.IS_NEW then
--                self.m_up_vip_logo:setPos(nx - nw/2 - vw/2 - 3);
--            end;
--            self.m_up_vip_frame:setVisible(false);
--            self.m_up_vip_logo:setVisible(false);
--        end
        print_string("Room.upComeIn name = " .. self.m_upUser:getName());
    end
end

OnlineRoomSceneNew.downGetOut = function(self)
    self.m_down_view1:resetIconView()
--    self.m_down_user_level_icon:setFile("");
--    self.m_down_name:setText("虚位以待");
--	self.m_down_user_icon:setFile("");
--	self.m_down_user_icon:setVisible(false);
--    self.m_down_user_disconnect:setVisible(false);
    self.m_down_user_ready_img:setVisible(false);
    self.m_down_user_start_btn:setVisible(false);
--    self.m_down_vip_frame:setVisible(false);
--    self.m_down_vip_logo:setVisible(false);
    self.down_turn:setVisible(false);
end

OnlineRoomSceneNew.upGetOut = function(self)
    self.m_up_view1:resetIconView()
--    self.m_up_user_level_icon:setFile("");
--    self.m_up_name:setText("虚位以待");
--	self.m_up_user_icon:setFile("");
--	self.m_up_user_icon:setVisible(false);
--    self.m_up_user_disconnect:setVisible(false);
    self.m_up_user_ready_img:setVisible(false);
--    self.m_up_vip_frame:setVisible(false);
--    self.m_up_vip_logo:setVisible(false);
    self.up_turn:setVisible(false);
end

--服务器通知对手进入
OnlineRoomSceneNew.onClientOppUserLogin = function(self, data)
    if data.user then
        if self.m_match_dialog and self.m_match_dialog:isShowing() then
	        self.mModule:onMatchSuccess(data);  
	    end
        self:upComeIn(data.user);
    end
end

--服务器通知准备状态
OnlineRoomSceneNew.onServerMsgReady = function(self, data)
    if data.uid == UserInfo.getInstance():getUid() then
	    self.m_down_user_ready_img:setVisible(true);
    else
        self.m_up_user_ready_img:setVisible(true);
        
        if self.m_match_dialog and self.m_match_dialog.oppReady and self.m_match_dialog:isShowing() then
            self.m_match_dialog:oppReady()
        end
        if not self.mNewPlayer then -- 非空,说明是再来一局
            if self.m_account_dialog:isShowing() then
                self.m_account_dialog:showUpuserReadyTip();
            else
                if self.m_down_user_ready_img:getVisible() then return end;
                if not self.m_upUser then return end;
                if not self.m_up_user_tip_dialog then
                    self.m_up_user_tip_dialog = new(ChioceDialogWithIcon);
                end;
	            local message = self.m_upUser:getName() .. " 想与你再战一局，是否接受？"
	            self.m_up_user_tip_dialog:setMode(ChioceDialogWithIcon.MODE_AGREE,"接受","拒绝");
	            self.m_up_user_tip_dialog:setMessage(message);
                self.m_up_user_tip_dialog:setIcon(self.m_upUser);
                self.m_up_user_tip_dialog:setLevel(self.m_upUser);
	            self.m_up_user_tip_dialog:setPositiveListener(self,function()
                    self:onReStartGame();
                    delete(OnlineRoomSceneNew.schedule_repeat_time)
                    OnlineRoomSceneNew.schedule_repeat_time = nil
                end);
	            self.m_up_user_tip_dialog:setNegativeListener(self,function()
                    self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_logout);
                    delete(OnlineRoomSceneNew.schedule_repeat_time)
                    OnlineRoomSceneNew.schedule_repeat_time = nil
                end);
	            self.m_up_user_tip_dialog:show();
                OnlineRoomSceneNew.schedule_repeat_time = ToolKit.schedule_repeat_time(self,function(self,a,b,c,cur_loopnum)
                    if cur_loopnum and cur_loopnum >= 0 and cur_loopnum < 10 then
                        self.m_up_user_tip_dialog:setCancelText("拒绝("..(10 - cur_loopnum)..")");
                    else
                        self.m_up_user_tip_dialog:cancel();
                    end;
                end,1000,10);
            end;
        end;
    end;
end;

--Server通知棋局正式开始，计时开始
OnlineRoomSceneNew.onServerMsgTimecountStart = function(self, data)
    if self.m_downUser:getUid() == data.uid then--uid，先走的uid，必定是红棋
        self.m_downUser:setFlag(FLAG_RED);
        self.m_upUser:setFlag(FLAG_BLACK);
        if self.m_downUser:getFlag() == FLAG_RED then
            self.m_red_turn = true;
            self.m_move_flag = FLAG_RED;
        else
            self.m_red_turn = false;
            self.m_move_flag = FLAG_BLACK; 
        end;
    else
        if self.m_upUser then
            self.m_upUser:setFlag(FLAG_RED);
            self.m_downUser:setFlag(FLAG_BLACK);
            if self.m_upUser:getFlag() == FLAG_RED then
                self.m_red_turn = true;
                self.m_move_flag = FLAG_RED;
            else
                self.m_red_turn = false;
                self.m_move_flag = FLAG_BLACK; 
            end;
        end;
    end;
    self:clearDialog();
    if self.m_account_dialog and self.m_account_dialog:isShowing() then
		self.m_account_dialog:dismiss2();
	end
    RoomProxy.getInstance():setCurRoomMultiple(tonumber(data.multiply));
    self:startGame(data.chess_map);
    self:setStatus(STATUS_TABLE_PLAYING,data.uid);
    self.m_game_start = true;
end;

--游戏开始
OnlineRoomSceneNew.startGame = function(self,chess_map)
    if self.mModule.startGame then
        self.mModule:startGame()
    end
    self.m_start_time = os.time();
    self.up_leave = false;
	self.m_game_over = false;
    self.m_first_move = false;
	self.m_had_syn_data = false;
    self.m_board_menu_dialog:dismiss();
    if self.mModule and self.mModule.onDeleteInvitAnim then
        self.mModule:onDeleteInvitAnim();
    end
	if chess_map then
		self:startBoard(chess_map);
	elseif self.m_needSyn then
	elseif(self.m_downUser:getFlag() == FLAG_RED) then
		self.m_board:newgame(Board.MODE_RED);--board:newGame(red_down_game);
	else
		self.m_board:newgame(Board.MODE_BLACK);
	end
	self:setEnableChess(false);
    --倒计时动画
    if self.animTimer then
		delete(self.animTimer);
		self.animTimer = nil;
	end

--    if self.m_countdownAnim then
--        self.m_countdownAnim:stop();
--        delete(self.m_countdownAnim);
--        self.m_countdownAnim = nil;
--    end
    self.upstartanim = false;
    self.downstartanim = false;
	self:stopTimeout();
	self:startTimeout();

    self.m_room_watcher_btn:setEnable(true);
    self.m_private_change_player_btn:setVisible(false);
    self.m_private_invite_friends_btn:setVisible(false);
    self.m_wait_tips:setVisible(false);
end

--开始游戏计时
OnlineRoomSceneNew.startTimeout = function(self)
	self:stopTimeout();
	self:setTimeFrameVisible(true);
	self.m_timeoutAnim = new(AnimInt,kAnimRepeat,0,1,1000,-1);
	self.m_timeoutAnim:setDebugName("Room.startTimeout.m_timeoutAnim");
	self.m_timeoutAnim:setEvent(self,self.timeoutRun);
end

OnlineRoomSceneNew.timeoutRun = function(self)
	if self.m_downUser and self.m_downUser:getFlag() == self.m_move_flag then
--        if not self.timeout_pause then
		    self.m_downUser:timeout1__();
		    self.m_downUser:timeout2__();
		    self.m_downUser:timeout3__();

            if RoomProxy.getInstance():getCurRoomType() ~= RoomConfig.ROOM_TYPE_WATCH_ROOM then
                local _,timeout_num = self.m_downUser:getTimeout2();
                local timeout_temp = tonumber(timeout_num or 0);
                if timeout_temp == 10 then
                    if SettingInfo.getInstance():getVibrateToggle() then
                        call_native("DeviceShake");
                    end
                end
                if timeout_temp < 10 and timeout_temp > 0 then
                    if SettingInfo.getInstance():getSoundToggle() then
                        kEffectPlayer:playEffect(Effects.AUDIO_SECOND_TIP);
                    end
                end
            end
--        end
        --开始倒计时动画
        local _,timeout_num_anim = self.m_downUser:getTimeout2();
        local timeout_ten = tonumber(timeout_num_anim or 0)*1000;
        local timedown = timeout_ten;
        if self.m_downUser:isTimeout() then
            timedown = self.m_timeout3 * 1000 
        else
            timedown = self.m_timeout2 * 1000
        end

        if not self.downstartanim then
            self:startAnim1(true,timeout_ten,timedown);
        end

        if timeout_ten == 10000 then
            self:startAnim2(true);
        end
    else
        if self.downstartanim then
            if self.animTimer then
		        delete(self.animTimer);
		        self.animTimer = nil;
	        end
--            if self.m_countdownAnim then
--                self.m_countdownAnim:stop();
--                delete(self.m_countdownAnim);
--                self.m_countdownAnim = nil;
            CountDownAnim.stop(self.down_turn);
            self.down_breath1:setVisible(false);
            self.down_breath2:setVisible(false);
--            end
            self.upstartanim = false;
            self.downstartanim = false;
        end
	end

	if self.m_upUser and self.m_upUser:getFlag() == self.m_move_flag then
--        if not self.timeout_pause then
		    self.m_upUser:timeout1__();
		    self.m_upUser:timeout2__();
		    self.m_upUser:timeout3__();
--        end
        --开始倒计时动画
        local _,timeout_num_anim = self.m_upUser:getTimeout2();
        local timeout_ten = tonumber(timeout_num_anim or 0)*1000;
        local timedown = timeout_ten;
        if self.m_upUser:isTimeout() then
            timedown = self.m_timeout3 * 1000 
        else
            timedown = self.m_timeout2 * 1000
        end
        if not self.upstartanim then
            self:startAnim1(false,timeout_ten,timedown);
        end

        if timeout_ten == 10000 then
            self:startAnim2(false);
        end
    else
        if self.upstartanim then
            if self.animTimer then
		        delete(self.animTimer);
		        self.animTimer = nil;
	        end

--            if self.m_countdownAnim then
--                self.m_countdownAnim:stop();
--                delete(self.m_countdownAnim);
--                self.m_countdownAnim = nil;
                CountDownAnim.stop(self.up_turn);
                self.up_breath1:setVisible(false);
                self.up_breath2:setVisible(false);
--            end
            self.downstartanim = false;
            self.upstartanim = false;
        end
	end

	--步时还是读秒
	if self.m_upUser and self.m_upUser:isTimeout() then
		if not self.m_up_setTimeoutFile then 
--			self.m_up_timeout2_name:setText("读秒:");   --设置成读秒
            self.m_up_view1:setTimeout2Name("读秒:")
			self.m_up_setTimeoutFile = true;
			self.m_up_setUnTimeoutFile = false;
		end
	else
		if not self.m_up_setUnTimeoutFile then
--			self.m_up_timeout2_name:setText("步时:");   --设置成步时
            self.m_up_view1:setTimeout2Name("步时:")
			self.m_up_setUnTimeoutFile = true;
			self.m_up_setTimeoutFile = false;
		end
	end

	if self.m_downUser and self.m_downUser:isTimeout() then
		if not self.m_down_setTimeoutFile then 
--			self.m_down_timeout2_name:setText("读秒:");    --设置成读秒
            self.m_down_view1:setTimeout2Name("读秒:")
			self.m_down_setTimeoutFile = true;
			self.m_down_setUnTimeoutFile = false;
		end
	else
		if not self.m_down_setUnTimeoutFile then
--			self.m_down_timeout2_name:setText();  --设置成步时
            self.m_down_view1:setTimeout2Name("步时:")
			self.m_down_setUnTimeoutFile = true;
			self.m_down_setTimeoutFile = false;
		end
	end
	--时间
	if self.m_upUser then 
        self.m_up_view1:updataTimeOut(self.m_upUser)
        self.m_down_view1:updataTimeOut(self.m_downUser)
--		self.m_up_timeout1_text:setText(self.m_upUser:getTimeout1());
--		self.m_up_timeout2_text:setText(self.m_upUser:getTimeout2());
--		self.m_down_timeout1_text:setText(self.m_downUser:getTimeout1());
--		self.m_down_timeout2_text:setText(self.m_downUser:getTimeout2());
	end 

--    if tonumber(self.m_wait_time) and  tonumber(self.m_wait_time) > 0 then 
--        self.m_wait_time =  tonumber(self.m_wait_time) - 1;
--        local content = self.m_wait_tips:getChildByName("text_content");
--        content:removeAllChildren(true);
--        local w,h = content:getSize();
----        local text = new(RichText,"对手暂时离开，请稍候（#c00ff00"..self.m_wait_time.."s#n）", w, h, kAlignLeft, "", 24, 255, 0, 0, false,0);
--        local text = new(RichText,"对手暂时离开，请稍候（" .. self.m_wait_time .. "s）", w, h, kAlignLeft, "", 24, 255, 0, 0, false,0);

--        content:addChild(text);
--    end

end

OnlineRoomSceneNew.stopTimeout = function(self)
	if self.m_timeoutAnim then
		delete(self.m_timeoutAnim);
		self.m_timeoutAnim = nil;
	end
    
    self:stopAnim1();
    self:stopAnim2();
end

OnlineRoomSceneNew.pauseTimout = function(self)
    self.timeout_pause = true;
    if self.m_upUser and self.m_upUser:getFlag() == self.m_move_flag then --self.m_countdownAnim and self.m_upUser and self.m_upUser:getFlag() == self.m_move_flag then
--        self.m_countdownAnim:pause();
        CountDownAnim.pause();
    end
end

OnlineRoomSceneNew.runTimout = function(self)
    self.timeout_pause = false;
--    if self.m_countdownAnim then
--        self.m_countdownAnim:run();
--    end
end

OnlineRoomSceneNew.callTelphoneResponse = function(self,time)
    self.up_leave = true;
    self:pauseTimout();
    self.m_wait_tips:setVisible(true);
    self:startWaitTime(time);
    ChessToastManager.getInstance():show("对手暂时离开了");
end

OnlineRoomSceneNew.callTelphoneBack = function(self)
    if self.up_leave then
        self:runTimout();
        self.up_leave = false;
        self.m_wait_tips:setVisible(false);
        ChessToastManager.getInstance():show("对手回来了");
        self.m_wait_time = 0;
    end
end

OnlineRoomSceneNew.setDisconnect = function(self,uid,isDisconnect)
    if self.m_upUser and self.m_upUser:getUid() == uid then
--        self.m_up_user_disconnect:setVisible(isDisconnect);   --todo
    elseif self.m_downUser and self.m_downUser:getUid() == uid then
--        self.m_down_user_disconnect:setVisible(isDisconnect);  --todo
    end
end


OnlineRoomSceneNew.onSaveMyChess = function(self,data)
    if not data then return end;
    if data.cost then
        if data.cost >= 0 then 
            ChessToastManager.getInstance():showSingle("收藏成功！",2000);
            if self.m_account_dialog and self.m_account_dialog:isShowing() then
                self.m_account_dialog:setHasSaved();
            end;
        elseif data.cost == -1 then
            -- -1是老版本本地棋谱上传成功
        end;
    end;    
end;

OnlineRoomSceneNew.onSaveMyChessAndShare = function(self,data)
    if not data then return end;
    if data.manual_id and self.m_mvData then
        local win_flag = self.m_mvData.win_flag or 1
        local redName = self.m_mvData.red_mnick or "..."
        local red_level = self.m_mvData.red_level or 1
        local blackName = self.m_mvData.red_mnick or "..."
        local black_level = self.m_mvData.red_level or 1
        local manualData = {};
        manualData.red_mid = self.m_mvData.red_mid or "0";       --红方uid
        manualData.black_mid = self.m_mvData.black_mid or "0";    --黑方uid
        manualData.win_flag = self.m_game_over_flag or "1";        --胜利方（1红胜，2黑胜，3平局）
        manualData.manual_type = 1     --棋谱类型，1联网游戏，2残局，3单机游戏，4用户打谱
        manualData.end_type = self.m_game_end_type or 1;    --棋盘开局
        manualData.start_fen = self.m_mvData.fenStr or self.m_mvData.start_fen;    -- 棋盘开局
        manualData.move_list = self.m_mvData.mvStr or self.m_mvData.move_list;     -- 走法，json字符串
        manualData.manual_id = data.manual_id;       -- 保存的棋谱id
        manualData.mid = self.m_mvData.mid;                   -- mid     
        manualData.h5_developUrl = PhpConfig.h5_developUrl;     
        manualData.title = CommonShareDialog.getShareTitle(win_flag,redName,red_level,blackName,black_level) or "复盘演练（博雅中国象棋）";
        manualData.description = CommonShareDialog.getShareTime(os.time()) or "复盘让您回顾精彩对局"; 
        local url = require("libs/url");
        local u = url.parse(manualData.h5_developUrl);
        local params = {}
        params.manual_id = manualData.manual_id
        u:addQuery(params);
        manualData.url =  u:build()

        if not self.commonShareDialog then
            self.commonShareDialog = new(CommonShareDialog);
        end
        self.commonShareDialog:setShareDate(manualData,"manual_share");
        self.commonShareDialog:show();
    end  
end


OnlineRoomSceneNew.onForbidUpUserMsg = function(self ,data)
    if data.forbid_status and data.is_success then
        if self.m_up_user_info_dialog then
            self.m_up_user_info_dialog:setForbidStatus(data);
        end;
    end;
end;

OnlineRoomSceneNew.startWaitTime = function(self,time)
    if not tonumber(time) then return end
    self.m_wait_time = tonumber(time); -- 有前面已有的定时器来更新数值
end

--呼吸动画
OnlineRoomSceneNew.startAnim2 = function(self,ret)
    local data = {};
    data.room = self;
    data.ret = ret;
    self:stopAnim2(); 
    self.animTimer = new(AnimInt,kAnimRepeat,0,1,200,50);
    self.animTimer:setEvent(data,self.onTimer);
end

OnlineRoomSceneNew.stopAnim2 = function(self)
    if self.animTimer then 
        delete(self.animTimer);
	    self.animTimer = nil;
    end
    self.down_breath1:setVisible(false);
    self.down_breath2:setVisible(false);
    self.up_breath1:setVisible(false);
    self.up_breath2:setVisible(false);
end

OnlineRoomSceneNew.onTimer = function(data)
    self = data.room
    if self.timeout_pause and self.m_upUser and self.m_upUser:getFlag() == self.m_move_flag then return end
    local ret = data.ret;
    local index = self.index;
    if ret then
        if index == 0 then
            self.down_breath1:setVisible(false);
            self.down_breath2:setVisible(false);
        elseif index == 1 then
            self.down_breath1:setVisible(true);
            self.down_breath2:setVisible(false);
        elseif index == 2 then
            self.down_breath1:setVisible(false);
            self.down_breath2:setVisible(true);
        elseif index == 3 then
            self.down_breath1:setVisible(true);
            self.down_breath2:setVisible(false);
            self.index = 0;
            return;
        end
        self.index = self.index + 1;
    else
        if index == 0 then
            self.up_breath1:setVisible(false);
            self.up_breath2:setVisible(false);
        elseif index == 1 then
            self.up_breath1:setVisible(true);
            self.up_breath2:setVisible(false);
        elseif index == 2 then
            self.up_breath1:setVisible(false);
            self.up_breath2:setVisible(true);
        elseif index == 3 then
            self.up_breath1:setVisible(true);
            self.up_breath2:setVisible(false);
            self.index = 0;
            return;
        end
        self.index = self.index + 1;
    end
end

--倒计时圆圈
OnlineRoomSceneNew.startAnim1 = function(self,ret,time,statrTime)
    -- statrTime 总时间
    --false  上部计时动画  true 下部计时动画
    curTime = tonumber(time) or 0
    statrTime = tonumber(statrTime) or curTime
    self.index = 0;
    if ret then
        CountDownAnim.play(self.down_turn,time,statrTime);
        self.downstartanim = true;
        if self.m_thansize_dialog then 
            self.m_thansize_dialog:turnToOwnPlayChess();
        end 
    else
        CountDownAnim.play(self.up_turn,time,statrTime);
        self.upstartanim = true;
    end
    if self.timeout_pause and self.m_upUser and self.m_upUser:getFlag() == self.m_move_flag then
        CountDownAnim.pause()
    end
end

OnlineRoomSceneNew.stopAnim1 = function(self)
--    delete(self.m_countdownAnim);
--    self.m_countdownAnim = nil;
    CountDownAnim.stop()
    self.downstartanim = false;
    self.upstartanim = false;
end


OnlineRoomSceneNew.chat_action = function(self)
	self:onEventStat(ROOM_MODEL_CHAT_BTN);
	if not self.m_chat_dialog then
		self.m_chat_dialog = new(ChatDialog,self);
	end
    self.m_chat_btn:getChildByName("notice"):setVisible(false);
	self.m_chat_dialog:show();
end

--设置局时是否可见
OnlineRoomSceneNew.setTimeFrameVisible = function(self,flag)
--	self.m_up_timeout1_name:setVisible(flag);
--	self.m_up_timeout1_text:setVisible(flag);
--	self.m_up_timeout2_name:setVisible(flag);
--	self.m_up_timeout2_text:setVisible(flag);

--	self.m_down_timeout1_name:setVisible(flag);
--	self.m_down_timeout1_text:setVisible(flag);
--	self.m_down_timeout2_name:setVisible(flag);
--	self.m_down_timeout2_text:setVisible(flag);
end

--断线重连房间信息同步
OnlineRoomSceneNew.onServerMsgReconnect = function(self, data)
    if not data then
        return;
    end;
    if self.m_match_dialog and self.m_match_dialog:isShowing() then
		self.m_match_dialog:dismiss();
	end
    self.m_login_succ = true;--断线重连进来设置为true,否则登出房间时不会发logout命令
	self:onClientMsgSyndata(data);
end;

--同步服务器
--[Comment]
--设置棋局状态 1停止 2正在下棋 3抢先 4让子 5设置局时 6等待局时回复
--    STATUS_TABLE_STOP = 1;
--    STATUS_TABLE_PLAYING = 2;
--    STATUS_TABLE_FORESTALL = 3;
--    STATUS_TABLE_HANDICAP = 4;
--    STATUS_TABLE_SETTIME = 5;
--    STATUS_TABLE_SETTIMERESPONE = 6;
OnlineRoomSceneNew.onClientMsgSyndata = function(self, data)
    if not data then
        return;
    end;
	self.m_timeout1 = data.round_time;
	self.m_timeout2 = data.step_time;
	self.m_timeout3 = data.sec_time;
    self.m_down_user_start_btn:setVisible(false);
    self.m_private_change_player_btn:setVisible(false);
    self.m_private_invite_friends_btn:setVisible(false);
    if data.status == STATUS_TABLE_PLAYING then--2代表正在游戏
        self.m_game_start = true;
        self.m_move_flag = data.first_flag;
        if self.m_move_flag == FLAG_RED then
            self.m_red_turn = true;
        else
            self.m_red_turn = false;
        end;
	    UserInfo.getInstance():setFlag(data.flag) ;
	    UserInfo.getInstance():setTimeout1((self.m_timeout1 - (data.round_timeout or 0)));
	    UserInfo.getInstance():setTimeout2(data.step_timeout);
	    UserInfo.getInstance():setTimeout3(data.sec_timeout);
	    UserInfo.getInstance():setMoney(data.coin);
        UserInfo.getInstance():setMultiply(data.multiply);

        self:downComeIn(UserInfo.getInstance());
        self:upComeIn(data.user,true);  

	    local last_move = {}
	    last_move.moveChess = data.chessMan;
	    last_move.moveFrom = 91 -data.position1;
	    last_move.moveTo = 91 - data.position2;
	    self:synchroData(data.chess_map,last_move);
--        if data.opp_is_back then
--            if data.opp_is_back == 1 then
--                self:callTelphoneResponse(data.opp_wait_time);
--            else
--                self:callTelphoneBack();
--                Log.e("--------------------> 对手先返回棋局。。（断线重连后）");
--            end
--        end
    elseif data.status == STATUS_TABLE_FORESTALL or data.status == STATUS_TABLE_HANDICAP or data.status == STATUS_TABLE_RANGZI_CONFIRM then
        UserInfo.getInstance():setTimeout1(self.m_timeout1);
	    UserInfo.getInstance():setTimeout2(self.m_timeout2);
	    UserInfo.getInstance():setTimeout3(self.m_timeout3);
        self:downComeIn(UserInfo.getInstance());
        self:upComeIn(data.user,true);  
    elseif data.status == STATUS_TABLE_STOP then
        local roomType = RoomProxy.getInstance():getCurRoomType();
        if roomType == RoomConfig.ROOM_TYPE_PRIVATE_ROOM then   --私人战
            self.m_private_change_player_btn:setVisible(RoomProxy.getInstance():isSelfRoom() and self.m_upUser ~= nil and UserInfo.getInstance():getCustomRoomType()==0);
            self.m_private_invite_friends_btn:setVisible(RoomProxy.getInstance():isSelfRoom() and self.m_upUser == nil and UserInfo.getInstance():getCustomRoomType()==0);
        end
        self.m_game_start = false;
        self:downComeIn(UserInfo.getInstance());
        self:upComeIn(data.user,true);
        self.m_down_user_start_btn:setVisible(true);
    else
        self:downComeIn(UserInfo.getInstance());
        self:upComeIn(data.user,true);
    end;
    self:updateUserInfoView()
    self:setStatus(data.status);
    self:requestCtrlCmd(OnlineRoomController.s_cmds.client_get_openbox_time);
end;

--同步棋盘数据
OnlineRoomSceneNew.synchroData = function(self,chess_map,last_move)
	self.m_needSyn = false;
    self.m_had_syn_data = false;

	local model = Board.MODE_BLACK;
	local redTurn = false;
	if(self.m_downUser:getFlag() == FLAG_RED) then
		model = Board.MODE_RED;
	end
    
	self.m_board:synchroBoard(chess_map,model,self.m_red_turn);

	self.m_board:setMovePath(last_move.moveFrom,last_move.moveTo,true);
    -- 保存观战棋局
    GameCacheData.getInstance():saveString(GameCacheData.DAPU_LAST_BORAD_FEN,Board.toFen(chess_map,self.m_red_turn));
	GameCacheData.getInstance():saveString(GameCacheData.DAPU_LAST_CHESS_STR,table.concat(chess_map,MV_SPLIT));
	local multiply = UserInfo.getInstance():getMultiply();

	self:stopTimeout();
	self:startTimeout();
end

--显示相应场次金币消耗
OnlineRoomSceneNew.showMoneyRent = function(self)
    local roomConfig = RoomProxy.getInstance():getCurRoomConfig();
    
    if roomConfig then
		local money = roomConfig.rent or 0;
        if money == 0 then return end
		local message = string.format("该场次每局消耗%d金币",money);
		ChatMessageAnim.play(self.m_root_view,3,message);
    end
end

--获取在线宝箱
OnlineRoomSceneNew.chest_action = function(self)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.ONLINE_TREASURE_BOX)
	if OnlineConfig.isReward then
        self.m_chest_btn:setEnable(false);
        OnlineConfig.deleteOpenBoxTimer();
        self:requestCtrlCmd(OnlineRoomController.s_cmds.room_get_reward, OnlineConfig.getOpenboxid());
	end
end

--点击比大小游戏按钮创建比大小游戏dialog
OnlineRoomSceneNew.thansize_btnClick = function(self)
    if not self.m_thansize_dialog then 
        self.m_thansize_dialog = new (ThanSizeDialog,self);
        self.m_thansize_dialog:setNeedMask(false);
    end 
    StatisticsManager.getInstance():onCountToUM(THANSIZEDIALOG_BTN_CLICK);
    self.m_thansize_dialog:show();
end

OnlineRoomSceneNew.endOpenChest = function(self)
    self.m_chest_btn:setEnable(false);
    self.m_chest_icon:setVisible(false)
    self.m_chest_anim_bg:setVisible(false);
    self.m_chest_icon:setFile("common/decoration/chest_1.png");
    OnlineConfig.deleteOpenBoxTimer();
    TestAnim.endStarAnim();
end

OnlineRoomSceneNew.startOpenChestAnim = function(self,rotate_view,star_view,callbackEvent,addMoney)
    local params = {rotate_view,star_view,callbackEvent}
    OnlineConfig.deleteOpenBoxTimer();
    if not rotate_view:checkAddProp(1) then
        rotate_view:removeProp(1);
    end
    rotate_view:addPropRotate(1, kAnimLoop, 3000, -1, 0, 360, kCenterDrawing);
    local data = {
        star_num = 10;
    };
    TestAnim.startStarAnim(star_view,data,callbackEvent,addMoney,rotate_view);
end

--获取信号等级
OnlineRoomSceneNew.getNetStateLevel = function(self)
    local post_data = {};
	local dataStr = json.encode(post_data);
	dict_set_string(kGetNetStateLevel,kGetNetStateLevel..kparmPostfix,dataStr);
	call_native(kGetNetStateLevel);
end

OnlineRoomSceneNew.registerSinalReceiver = function(self)
    local post_data = {};
	local dataStr = json.encode(post_data);
	dict_set_string(kRegisterSinalReceiver,kRegisterSinalReceiver..kparmPostfix,dataStr);
	call_native(kRegisterSinalReceiver);
end

OnlineRoomSceneNew.unregisterSinalReceiver = function(self)
    local post_data = {};
	local dataStr = json.encode(post_data);
	dict_set_string(kUnregisterSinalReceiver,kUnregisterSinalReceiver..kparmPostfix,dataStr);
	call_native(kUnregisterSinalReceiver);
end 

OnlineRoomSceneNew.onShowNetState = function(self, netState)
    self:showNetSinalIcon(false, netState);
end;

OnlineRoomSceneNew.showNetSinalIcon = function(self,isInit, netState)
	local levelStr = netState;
    local level = 1;
	if isInit then
		levelStr = 3;
	end
	if levelStr~= nil and levelStr ~= "" then
		level = tonumber(levelStr)+1;
	else
	    level = 1;
	end
    if self.m_down_view1 then
        self.m_down_view1:showNetSinalIcon(level)
    end
	if level == 6 then
		self.stop_time=true;
		self:stopTimeout();
		local message = "亲，您的网络有点不稳定哦！";
		ChatMessageAnim.play(self.m_root_view,3,message);
--        ChessToastManager.getInstance():showSingle(message);
	end
end

--显示上部玩家的详细信息弹窗
OnlineRoomSceneNew.showUpUserInfo = function(self,finger_action, x, y)
	if finger_action ~= kFingerUp then
		return
	end
    if not self.m_upUser then return end
    if not self.m_up_user_info_dialog then
        self.m_up_user_info_dialog = new(UserInfoDialog2);
    end;
    if self.m_up_user_info_dialog:isShowing() then 
        self.m_up_user_info_dialog:dismiss();
        return 
    end
    self:onEventStat(ROOM_MODEL_UPUSER_ICON)
    if self.m_upUser:getUid() == UserInfo.getInstance():getUid() then
        self.m_up_user_info_dialog:setShowType(UserInfoDialog2.SHOW_TYPE.ONLINE_ME)
    else
        self.m_up_user_info_dialog:setBgPos(0,180)
        showDialog = self:setShowType(self.m_up_user_info_dialog)
    end
    if not showDialog then return end
    local id = self.m_upUser:getUid()
    FriendsData.getInstance():sendCheckUserData(id)
    self.m_up_user_info_dialog:show(nil,id);
    self.m_target_user = self.m_upUser
end

--显示下部玩家的详细信息弹窗
OnlineRoomSceneNew.showDownUserInfo = function(self,finger_action, x, y)
--    local roomType = RoomProxy.getInstance():getCurRoomType();
	if finger_action ~= kFingerUp then
		return
	end
    if not self.m_downUser then return end
    local showDialog = true
    if not self.m_down_user_info_dialog then
        self.m_down_user_info_dialog = new(UserInfoDialog2);
    end;
    if self.m_down_user_info_dialog:isShowing() then 
        self.m_down_user_info_dialog:dismiss();
        return 
    end
    self:onEventStat(ROOM_MODEL_DOWNUSER_ICON)
    if self.m_downUser:getUid() == UserInfo.getInstance():getUid() then
        self.m_down_user_info_dialog:setShowType(UserInfoDialog2.SHOW_TYPE.ONLINE_ME)
    else
        self.m_down_user_info_dialog:setBgPos(0,180)
        showDialog = self:setShowType(self.m_down_user_info_dialog)
    end
    if not showDialog then return end
    local id = self.m_downUser:getUid()
    FriendsData.getInstance():sendCheckUserData(id)
    self.m_down_user_info_dialog:show(nil,id);
    self.m_target_user = self.m_downUser
end

function OnlineRoomSceneNew.setShowType(self,dialog)
    if not dialog then return false end
    local id = UserInfo.getInstance():getUid()
    if self.m_upUser and self.m_downUser then
        if self.m_upUser:getUid() ~= id and self.m_downUser:getUid() ~= id then
            dialog:setShowType(UserInfoDialog2.SHOW_TYPE.WATCH_PLAYER)
        else
            dialog:setShowType(UserInfoDialog2.SHOW_TYPE.ONLINE_OTHER)
        end
        return true
    end
    return false
end

--菜单栏弹窗
OnlineRoomSceneNew.menuToggle = function(self)
	self:onEventStat(ROOM_MODEL_MENU_BTN);

	local showing = self.m_board_menu_dialog:isShowing();
	if not showing then
		self.m_board_menu_dialog:show();
	else
		self.m_board_menu_dialog:dismiss();
	end
end

--发起悔棋请求弹窗
OnlineRoomSceneNew.undoAction = function(self)
    local roomType = RoomProxy.getInstance():getCurRoomType()
	if self:isEnableUndo() or self.isUndoAble then
        local message = "确认向对方支付一定金币请求悔棋"
        local roomLevel = RoomProxy.getInstance():getCurRoomLevel();
        local roomConfig = RoomConfig.getInstance():getRoomLevelConfig(roomLevel);
	    if roomConfig and roomConfig.undomoney and roomConfig.undomoney > 0 then
	        message = "确认向对方支付"..tostring(roomConfig.undomoney).."金币请求悔棋吗？" ;
        end
        if not self.m_chioce_dialog then
		    self.m_chioce_dialog = new(ChioceDialog);
	    end

	    self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE);
	    self.m_chioce_dialog:setMessage(message);
	    self.m_chioce_dialog:setPositiveListener(self,self.undoAction_sure);
	    self.m_chioce_dialog:setNegativeListener(nil,nil);
	    self.m_chioce_dialog:show();
	else
		message = "亲，现在还不能悔棋!"
        ChessToastManager.getInstance():showSingle(message);
	end
end

OnlineRoomSceneNew.undoAction_sure = function(self)
    if self:isEnableUndo() or self.isUndoAble then
	    self:onEventStat(ROOM_MODEL_MENU_UNDO_BTN);
        self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_undomove, 1);
	    self:setEnableUndo(false);
	    self.isUndoAble = false;
	else
		local message = "亲，现在还不能悔棋!"
		ChessToastManager.getInstance():showSingle(message);
	end
end

--游戏设置弹窗
OnlineRoomSceneNew.setting = function(self)
	self:onEventStat(ROOM_MODEL_MENU_SET_BTN);
	if not self.m_setting_dialog then
		self.m_setting_dialog = new(SettingDialog);
	end
	self.m_setting_dialog:show();
end

--发起认输弹窗
OnlineRoomSceneNew.surrender = function(self)
    if not self:checkCanSurrender() then OnlineRoomController.s_switch_func = nil return end
	self:onEventStat(ROOM_MODEL_MENU_SURRENDER_BTN);
	local message = "您是否要认输？"

	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end

	self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE);
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:setPositiveListener(self,self.surrender_sure);
	self.m_chioce_dialog:setNegativeListener(self,function()
        OnlineRoomController.s_switch_func = nil
    end);
	self.m_chioce_dialog:show();
end

--发送认输请求
OnlineRoomSceneNew.surrender_sure = function(self)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_surrender1);
end

--发起求和弹窗
OnlineRoomSceneNew.draw = function(self)
    local roomType = RoomProxy.getInstance():getCurRoomType()
    if roomType == RoomConfig.ROOM_TYPE_MONEY_MATCH_ROOM then
		message = "该房间不支持求和哦!"
        ChessToastManager.getInstance():showSingle(message);
        return 
    end
	self:onEventStat(ROOM_MODEL_MENU_DRAW_BTN);
	local message = "您是否要求和？"

	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end

	self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE);
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:setPositiveListener(self,self.draw_sure);
	self.m_chioce_dialog:setNegativeListener();
	self.m_chioce_dialog:show();
end

--发送求和请求
OnlineRoomSceneNew.draw_sure = function(self)
	print_string("Room.draw");
	self:setEnableDraw(false);
    self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_draw1);
end

--破产弹窗
OnlineRoomSceneNew.collapse = function(self)
	print_string("Room.collapse .. ");
	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end

	local message = "您的金币不足以继续游戏,即将返回大厅";
	self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE,"知道了");
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:setPositiveListener(self,self.exitRoom);
	self.m_chioce_dialog:setNegativeListener(self,self.exitRoom)
	self.m_chioce_dialog:show();
end

--设置被吃的妻子
OnlineRoomSceneNew.setDieChess = function(self,dieChess)
	if not dieChess then
		sys_set_int("win32_console_color",10);
		print_string("Room.setDieChess but not dieChess" );
		sys_set_int("win32_console_color",9);
		return;
	end

	if not self.m_downUser or not self.m_upUser then

		print_string("Room.setDieChess but not self.m_downUser or not self.m_upUser" );
		return
	end

	local upflag = tonumber(self.m_downUser:getFlag()) * 8 - 1;
	local downflag = tonumber(self.m_upUser:getFlag()) * 8 - 1;
	for i = 1 ,7 do
		if not dieChess[upflag +i ] then
			sys_set_int("win32_console_color",10);
			print_string("Room.setDieChess but not dieChess[upflag +i ] " .. i);
			sys_set_int("win32_console_color",9);
		elseif dieChess[upflag +i ] == 1 then
			local fileStr = piece_resource_id[upflag +i] .. ".png";
 			local file = Board.boardres_map[fileStr];

--			self.m_up_chess_pc[i]:getChildByName("texture"):setFile(file);
--			self.m_up_chess_pc[i]:setVisible(true);
--			self.m_up_chess_num[i]:setVisible(false);
		elseif dieChess[upflag +i ] > 1 and dieChess[upflag +i ] <= 5 then
			local fileStr = piece_resource_id[upflag +i] .. ".png";
 			local file = Board.boardres_map[fileStr];

--			self.m_up_chess_pc[i]:getChildByName("texture"):setFile(file);
--			self.m_up_chess_pc[i]:setVisible(true);
--			self.m_up_chess_num[i]:getChildByName("text"):setText(dieChess[upflag +i ]);
--			self.m_up_chess_num[i]:setVisible(true);
		else
--			self.m_up_chess_pc[i]:setVisible(false);
--			self.m_up_chess_num[i]:setVisible(false);
		end

		if not dieChess[downflag +i ] then
			sys_set_int("win32_console_color",10);
			print_string("Room.setDieChess but not dieChess[downflag +i ] " .. i);
			sys_set_int("win32_console_color",9);
		elseif dieChess[downflag +i ] == 1 then
			local fileStr = piece_resource_id[downflag +i] .. ".png";
 			local file = Board.boardres_map[fileStr];

--			self.m_down_chess_pc[i]:getChildByName("texture"):setFile(file);
--			self.m_down_chess_pc[i]:setVisible(true);
--			self.m_down_chess_num[i]:setVisible(false);
		elseif dieChess[downflag +i ] > 1 and dieChess[downflag +i ] <= 5 then
			local fileStr = piece_resource_id[downflag +i] .. ".png";
 			local file = Board.boardres_map[fileStr];


--			self.m_down_chess_pc[i]:getChildByName("texture"):setFile(file);
--			self.m_down_chess_pc[i]:setVisible(true);
--			self.m_down_chess_num[i]:getChildByName("text"):setText(dieChess[downflag +i ]);
--			self.m_down_chess_num[i]:setVisible(true);
		else
--			self.m_down_chess_pc[i]:setVisible(false);
--			self.m_down_chess_num[i]:setVisible(false);
		end
	end

--    self:resetChessPos();
--    for i = 1 ,7 do
--        if self.m_up_chess_pc[i]:getVisible() then
--            for j = 1, 7 do
--               if UserInfoDialog.up_chess_pos[j].available then
--                   self.m_up_chess_pc[i]:setPos(UserInfoDialog.up_chess_pos[j].pos);
--                   UserInfoDialog.up_chess_pos[j].available = false;
--                   break;
--               end
--            end
--        end
--    end
--    for i = 1 ,7 do
--        if self.m_down_chess_pc[i]:getVisible() then
--            for j = 1, 7 do
--               if UserInfoDialog.down_chess_pos[j].available then
--                   self.m_down_chess_pc[i]:setPos(UserInfoDialog.down_chess_pos[j].pos);
--                   UserInfoDialog.down_chess_pos[j].available = false;
--                   break;
--               end
--            end
--        end
--    end
end

--重置棋子位置
OnlineRoomSceneNew.resetChessPos = function(self)
	for i = 1,7 do
		UserInfoDialog.down_chess_pos[i].available = true;
        UserInfoDialog.up_chess_pos[i].available = true;
	end
end

--隐藏棋子
OnlineRoomSceneNew.clearDiechess = function(self)
--	for i = 1,7 do
--		self.m_down_chess_pc[i]:setVisible(false);
--		self.m_down_chess_num[i]:setVisible(false);

--		self.m_up_chess_pc[i]:setVisible(false);
--		self.m_up_chess_num[i]:setVisible(false);
--	end
end
--[Comment]
--设置棋局状态 1停止 2正在下棋 3抢先 4让子 5设置局时 6等待局时回复
--    STATUS_TABLE_STOP = 1;
--    STATUS_TABLE_PLAYING = 2;
--    STATUS_TABLE_FORESTALL = 3;
--    STATUS_TABLE_HANDICAP = 4;
--    STATUS_TABLE_SETTIME = 5;
--    STATUS_TABLE_SETTIMERESPONE = 6;
OnlineRoomSceneNew.setStatus =function(self,status,params)
	self.m_t_statuss = status;
    self.m_room_watcher_btn:setEnable(false);
	if self.m_t_statuss == STATUS_TABLE_STOP then    
    elseif self.m_t_statuss == STATUS_TABLE_PLAYING then   --走棋状态
		self.up_turn:setVisible(self.m_upUser and self.m_upUser:getFlag() == self.m_move_flag);
		self.down_turn:setVisible(self.m_downUser and self.m_downUser:getFlag() == self.m_move_flag);
		if self.m_first_move then
			self:setEnableUndo(self.m_downUser and self.m_downUser:getFlag() ~= self.m_move_flag);
		else
			self:setEnableUndo(false);
			self.m_first_move = true;
		end
		self:setEnableDraw(true);
		self:setEnableSurrender(true);
        self.m_toast_bg:setVisible(false);
        self.m_room_watcher_btn:setEnable(true);
        self.m_down_user_start_btn:setVisible(false);
	elseif self.m_t_statuss == STATUS_TABLE_FORESTALL then  -- 抢先状态
        self.m_down_user_start_btn:setVisible(false);
        
	elseif self.m_t_statuss == STATUS_TABLE_HANDICAP then  -- 让子状态
        self.m_down_user_start_btn:setVisible(false);
    elseif self.m_t_statuss == STATUS_TABLE_RANGZI_CONFIRM then -- 让子确认状态
        self.m_down_user_start_btn:setVisible(false);
	elseif self.m_t_statuss == STATUS_TABLE_SETTIME then -- 设置局时状态
        self.m_down_user_start_btn:setVisible(false);
        
    elseif self.m_t_statuss == STATUS_TABLE_SETTIMERESPONE then
        self.m_down_user_start_btn:setVisible(false);
        
    else
        self.m_toast_bg:setVisible(false);
    end

    self.mModule:setStatus(status,params);
end

--有让子之后，棋局开始会发送棋盘信息
OnlineRoomSceneNew.startBoard = function(self,chess_map)
	print_string("Room.startBoard ");
	local model = Board.MODE_BLACK;
	if(self.m_downUser:getFlag() == FLAG_RED) then
		model = Board.MODE_RED;
    end
	self.m_board:synchroBoard(chess_map,model,self.m_red_turn);

	GameCacheData.getInstance():saveString(GameCacheData.DAPU_LAST_BORAD_FEN,Board.toFen(chess_map,self.m_red_turn));
	GameCacheData.getInstance():saveString(GameCacheData.DAPU_LAST_CHESS_STR,table.concat(chess_map,MV_SPLIT));
end

--请求同步
OnlineRoomSceneNew.synchroRequest = function(self)
	local roomType = RoomProxy.getInstance():getCurRoomType();
	if roomType == RoomConfig.ROOM_TYPE_WATCH_ROOM then
        self:requestCtrlCmd(OnlineRoomController.s_cmds.syn_watch_data);
	else
        self:requestCtrlCmd(OnlineRoomController.s_cmds.syn_room_data);
	end
	self.m_had_syn_data = true;
end

OnlineRoomSceneNew.dismissLoadingDialog = function(self)
	if self.m_loading_dialog and self.m_loading_dialog:isShowing() then
		self.m_loading_dialog:dismiss();
	end
end

OnlineRoomSceneNew.dismissLoadingDialog2 = function(self)
	if self.m_loading_dialog2 and self.m_loading_dialog2:isShowing() then
		self.m_loading_dialog2:dismiss();
	end
end


--设置局时弹窗
OnlineRoomSceneNew.onSetTime = function(self,time_out)
    if self.m_friendChoiceDialog and self.m_friendChoiceDialog:isShowing() then
        return;
    end
    local roomLevel = RoomProxy.getInstance():getCurRoomLevel() or 0;
    if not self.m_roomSetTimeDialog then
        self.m_roomSetTimeDialog = new(RoomFriendSetTime);
    end
    self.m_roomSetTimeDialog:onSureFunc(self,self.onSetTimeFinish);
    self.m_roomSetTimeDialog:onCancleFunc(self,function()
        StatisticsManager.getInstance():onCountToUM(ONLINE_READY_PROCESS_GIVEUP_TIMESET)
        local roomType = RoomProxy.getInstance():getCurRoomType()
        if roomType == RoomConfig.ROOM_TYPE_NOVICE_ROOM or 
            roomType == RoomConfig.ROOM_TYPE_INTERMEDIATE_ROOM or 
            roomType == RoomConfig.ROOM_TYPE_MASTER_ROOM then
            self:reMatch()
        else
			self:exitRoom()
        end
    end)
    self.m_roomSetTimeDialog:onShowUpUserInfoFunc(self,self.showUpUserInfo)
    self.m_roomSetTimeDialog:show(roomLevel,time_out);
end

OnlineRoomSceneNew.onWaitSetTime = function(self,time_out)
    local roomLevel = RoomProxy.getInstance():getCurRoomLevel() or 0
    if not self.mRoomWaitSetTimeDialog then
        self.mRoomWaitSetTimeDialog = new(RoomFriendWaitSetTime)
    end
    self.mRoomWaitSetTimeDialog:onShowUpUserInfoFunc(self,self.showUpUserInfo)
    self.mRoomWaitSetTimeDialog:setRoom(self)
    self.mRoomWaitSetTimeDialog:show(roomLevel,time_out)
end

OnlineRoomSceneNew.onSetTimeFinish = function(self,timeData)
    StatisticsManager.getInstance():onCountToUM(ONLINE_READY_PROCESS_SURE_TIMESET,json.encode(timeData))
    self:requestCtrlCmd(OnlineRoomController.s_cmds.set_time_finish, timeData);
    -- 占时后续 写到设置状态里面去
    if UserInfo.getInstance():getChallenger() then
        local post_data = {};
        post_data.uid = tonumber(UserInfo.getInstance():getUid());
        post_data.target_uid = tonumber(UserInfo.getInstance():getTargetUid());
        post_data.tid = RoomProxy.getInstance():getTid();
        post_data.gameTime = timeData.gameTime;
        post_data.stepTime = timeData.stepTime;
        post_data.secondTime = timeData.secondTime;
        UserInfo.getInstance():setChallenger(nil);
        self:requestCtrlCmd(OnlineRoomController.s_cmds.invit_request,post_data);
        self:showMoneyRent();
    end
end

--显示对方设置的局时弹窗
OnlineRoomSceneNew.onSetTimeShow = function(self,data)
    if self.mRoomWaitSetTimeDialog then
        self.mRoomWaitSetTimeDialog:dismiss()
    end
    if RoomProxy.getInstance():getCurRoomType() == RoomConfig.ROOM_TYPE_FRIEND_ROOM then
        if RoomProxy.getInstance():getFriendsAutoSure() then -- 2.6.0 在房间外面同意时间设置
            RoomProxy.getInstance():setFriendsAutoSure(false)
            self:onSetTimeAgree(data)
            return 
        end
    end
    local roomLevel = RoomProxy.getInstance():getCurRoomLevel() or 0;
    if not self.m_roomOtherSetTimeDialog then
        self.m_roomOtherSetTimeDialog = new(RoomFriendSetTimeShow);
    end
    self.m_roomOtherSetTimeDialog:onShowUpUserInfoFunc(self,self.showUpUserInfo)
    self.m_roomOtherSetTimeDialog:onSureFunc(self,self.onSetTimeAgree);
    self.m_roomOtherSetTimeDialog:onCancleFunc(self,self.onSetTimeDisagree);
    self.m_roomOtherSetTimeDialog:show(data,roomLevel);
end

function OnlineRoomSceneNew:onWaitSetTimeShow(data)
    if not data then return end
    local roomLevel = RoomProxy.getInstance():getCurRoomLevel() or 0
    if not self.mRoomWaitOtherSetTimeDialog then
        self.mRoomWaitOtherSetTimeDialog = new(RoomFriendWaitSetTimeShow)
    end
    self.mRoomWaitOtherSetTimeDialog:onShowUpUserInfoFunc(self,self.showUpUserInfo)
    self.mRoomWaitOtherSetTimeDialog:setRoom(self)
    self.mRoomWaitOtherSetTimeDialog:show(roomLevel,data.time_out)
end

OnlineRoomSceneNew.onReadyTime = function(self)
    if self.m_ready_time and self.m_ready_time > 0 then
        self.m_ready_time = self.m_ready_time - 1;
    else
        if self.m_ready_time_anim then
            delete(self.m_ready_time_anim);
            self.m_ready_time_anim = nil;
        end
    end
end

--挑战邀请通知
OnlineRoomSceneNew.onInvitNotify = function(self,packageInfo)
    local money = UserInfo,getInstance():getMoney();
    local isCanAccess = RoomProxy.getInstance():canAccessRoom(RoomConfig.ROOM_TYPE_FRIEND_ROOM,money);
    if not isCanAccess then
        local post_data = {};
        post_data.uid = UserInfo.getInstance():getUid();
        post_data.target_uid = packageInfo.uid;
        post_data.ret = 1;
--        self:sendSocketMsg(FRIEND_CMD_FRIEND_INVIT_RESPONSE,post_data,nil,1);
        self:sendSocketMsg(FRIEND_CMD_FRIEND_INVIT_RESPONSE2,post_data,nil,1);
        return;
    end

    local friendData = FriendsData.getInstance():getUserData(packageInfo.uid);

    if not self.m_friendChoiceDialog then
        self.m_friendChoiceDialog = new(FriendChoiceDialog);
    end
    self.m_friendChoiceDialog:setMode(1,friendData,packageInfo.time_out);
    self.m_friendChoiceDialog:setPositiveListener(self,
        function()
            self:onResetGame();
            RoomProxy.getInstance():setTid(packageInfo.tid);
            local post_data = {};
            post_data.uid = UserInfo.getInstance():getUid();
            post_data.target_uid = packageInfo.uid;
            post_data.ret = 1;
            UserInfo.getInstance():setChallenger(false);
            ChessDialogManager.dismissAllDialog();
            self:requestCtrlCmd(OnlineRoomController.s_cmds.invit_response, post_data);                      
            self:resume(); end);
    self.m_friendChoiceDialog:setNegativeListener(self,
        function()
            local post_data = {};
            post_data.uid = UserInfo.getInstance():getUid();
            post_data.target_uid = packageInfo.uid;
            post_data.ret = 1;
            self:requestCtrlCmd(OnlineRoomController.s_cmds.invit_response, post_data);    
            end);
    self.m_friendChoiceDialog:show();
end

OnlineRoomSceneNew.onSetTimeDisagree = function(self,data)
    StatisticsManager.getInstance():onCountToUM(ONLINE_READY_PROCESS_GIVEUP_TIMESET_INFO,json.encode(data))
    self:requestCtrlCmd(OnlineRoomController.s_cmds.set_time_response, false);
    self:reMatch()
end

OnlineRoomSceneNew.onSetTimeAgree = function(self,data)
    StatisticsManager.getInstance():onCountToUM(ONLINE_READY_PROCESS_SURE_TIMESET_INFO,json.encode(data))
    self:requestCtrlCmd(OnlineRoomController.s_cmds.set_time_response, true);
end

--棋局结束
OnlineRoomSceneNew.gameClose = function(self,flag,endType)
	self.m_game_over = true;
    self.m_game_start = false;
	print_string("结束类型动画 。。" .. endType);
	RoomHomeScroll.close();
    
	self.m_showAccount = true;    --显示结束动画的时候，不能显示开始按钮 
	--[[
	ENDTYPE_KILL = 1;           --1 将死
	ENDTYPE_DRAW = 2;           --2 和棋
	ENDTYPE_SURRENDER = 3;      --3认输
	ENDTYPE_TIMEOUT = 4;        --4超时
	ENDTYPE_LEAVE = 5;          --5逃跑
	ENDTYPE_JAM = 6;            --6困毙
    ENDTYPE_OFFLINE_TIMEOUT = 7;--掉线超时
    ENDTYPE_ROUND_NUM = 8;      --回合数超过60步没有吃子
    ]]
	self:clearDialog();  -- 游戏结束，关闭弹出框 
    GiftLog.getInstance():deleteUserGift() --清空本局礼物信息
	
	self.m_game_over_flag = flag;
	self.m_game_end_type = endType;

	if endType == ENDTYPE_KILL then
		AnimKill.play(self.m_root_view,self,self.showAccount);
	elseif  endType == ENDTYPE_TIMEOUT or endType == ENDTYPE_OFFLINE_TIMEOUT then
		AnimTimeout.play(self.m_root_view,self,self.showAccount);
	elseif endType == ENDTYPE_JAM then
		AnimJam.play(self.m_root_view,self,self.showAccount);
	elseif endType == ENDTYPE_SURRENDER then
		local message = "认输!!!";
		ChatMessageAnim.play(self.m_root_view,3,message);
--        ChessToastManager.getInstance():showSingle(message);
		self:showAccount();
	elseif endType == ENDTYPE_ROUND_NUM then
		local message = "流局结束";
		ChatMessageAnim.play(self.m_root_view,3,message);
--        ChessToastManager.getInstance():showSingle(message);
        self:showAccount();
	elseif endType == ENDTYPE_UNLEGAL then
		local message = "长打作负!!!";
		ChatMessageAnim.play(self.m_root_view,3,message);
--        ChessToastManager.getInstance():showSingle(message);
		self:showAccount();
	elseif endType == ENDTYPE_UNCHANGE then
		local message = "双方不变作和!!!";
		ChatMessageAnim.play(self.m_root_view,3,message);
--        ChessToastManager.getInstance():showSingle(message);
		self:showAccount();
	else
		self:showAccount();
	end
    
    self.m_first_move = false;
	self:setEnableChess(true);
	self:setEnableDraw(false);
	self:setEnableSurrender(false);
	self.m_board:gameClose();
	self:stopTimeout();
end

--显示棋局结算窗口
OnlineRoomSceneNew.showAccount = function(self)
    --关闭倒计时动画
    if self.animTimer then
		delete(self.animTimer);
		self.animTimer = nil;
	end

    if self.m_countdownAnim then
        self.m_countdownAnim:stop();
        delete(self.m_countdownAnim);
        self.m_countdownAnim = nil;
    end
    self.upstartanim = false;
    self.downstartanim = false;
    ----------
    self.m_room_watcher_btn:setEnable(false);
    self:setEnableUndo(false);
    self.isUndoAble = false;

    self.m_board_view:removeProp(1);
    self.m_board_view:removeProp(2);

    -------棋局介绍关闭小游戏
    if self.m_thansize_dialog then 
        self.m_thansize_dialog:dismiss();
    end 

    if RoomProxy.getInstance():getCurRoomType() == RoomConfig.ROOM_TYPE_MONEY_MATCH_ROOM or 
        RoomProxy.getInstance():getCurRoomType() == RoomConfig.ROOM_TYPE_METIER_ROOM then
        -- 比赛房间不走这边
        self.mModule:showAccount()
        return 
    end
    delete(self.m_account_dialog);
    self.m_account_dialog = nil;
    self.m_account_dialog = new(AccountDialog,self);
    self.mNewPlayer = false
--    self.m_account_dialog:setLevel(1);
	if RoomProxy.getInstance():getCurRoomType() == RoomConfig.ROOM_TYPE_WATCH_ROOM then
		self.m_account_dialog:show(self,self.m_game_over_flag,nil,RoomProxy.getInstance():getCurRoomType());
		return;
	end
	self.m_account_dialog:show(self,self.m_game_over_flag,self.m_again_btn_timeout-2,RoomProxy.getInstance():getCurRoomType());
	
	self.m_showAccount = false;
end

--保存棋谱
OnlineRoomSceneNew.saveChess = function(self)
	if UserInfo.getInstance():getDapuEnable() == false then
		self:buyDapu(ONLINE_ROOM_DAPU);
		return false;
	end

	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end

	if self.m_had_syn_data  then
		local message = "由于网络原因，保存棋谱失败！";
        ChessToastManager.getInstance():showSingle(message);
        return false;
	elseif self:saveChessData() == true then
--		local message = "棋局已自动保存到最近对战";
--		ShowMessageAnim.play(self.m_account_dialog,message);
        return true;
	else
	end
end

OnlineRoomSceneNew.cancelSaveMVList = function(self)
	UserInfo.getInstance():setDapuDataNeedToSave(nil);
end

--购买棋谱
OnlineRoomSceneNew.buyDapu = function(self,pos)
	self.m_payInterface = PayUtil.getPayInstance(PayUtil.s_payType.Exchange);
	self.m_payInterface:buy(nil,pos);
end

OnlineRoomSceneNew.saveChessData = function(self)
    if not self.m_downUser or not self.m_upUser then return end 
    local mvData = {};
    mvData.mid = uid;
--    mvData.fileName = "棋局回放"..index;
    mvData.red_mid = (self.m_downUser:getFlag() == 1 and  self.m_downUser:getUid()) or (self.m_upUser:getUid());
    mvData.black_mid = (self.m_downUser:getFlag() == 1 and  self.m_upUser:getUid()) or (self.m_downUser:getUid());
    mvData.down_user = ((self.m_downUser:getUid() == mvData.red_mid and  mvData.red_mid) or mvData.black_mid);
   
    mvData.red_mnick = (self.m_downUser:getFlag() == 1 and  self.m_downUser:getName()) or (self.m_upUser:getName());
    mvData.black_mnick = (self.m_downUser:getFlag() == 1 and  self.m_upUser:getName()) or (self.m_downUser:getName());

    mvData.red_icon_type = (self.m_downUser:getFlag() == 1 and  self.m_downUser:getIconType()) or (self.m_upUser:getIconType());
    mvData.black_icon_type = (self.m_downUser:getFlag() == 1 and  self.m_upUser:getIconType()) or (self.m_downUser:getIconType());
        
    mvData.red_icon_url = (self.m_downUser:getFlag() == 1 and  self.m_downUser:getIcon()) or (self.m_upUser:getIcon());
    mvData.black_icon_url = (self.m_downUser:getFlag() == 1 and  self.m_upUser:getIcon()) or (self.m_downUser:getIcon());
   
    mvData.red_level = (self.m_downUser:getFlag() == 1 and  10 - UserInfo.getInstance():getDanGradingLevelByScore(self.m_downUser.m_score) or 10 - UserInfo.getInstance():getDanGradingLevelByScore(self.m_upUser.m_score));
    mvData.black_level = (self.m_downUser:getFlag() == 1 and 10 - UserInfo.getInstance():getDanGradingLevelByScore(self.m_upUser.m_score) or 10 - UserInfo.getInstance():getDanGradingLevelByScore(self.m_downUser.m_score));
    mvData.red_score = (self.m_downUser:getFlag() == 1 and  self.m_downUser:getScore() or self.m_upUser:getScore());
    mvData.black_score = (self.m_downUser:getFlag() == 1 and  self.m_upUser:getScore() or self.m_downUser:getScore());
    mvData.win_flag = self.m_game_over_flag;
    mvData.end_type = self.m_game_end_type;
    -- 棋谱作者
    mvData.mid = UserInfo.getInstance():getUid();
    mvData.mnick = UserInfo.getInstance():getName();
    mvData.icon_type = UserInfo.getInstance():getIconType();
    mvData.icon_url = UserInfo.getInstance():getIcon();
    -- 棋局结束局面,红方胜利，那么该走棋应该是黑方
    mvData.end_fen = self.m_board.toFen(self.m_board:to_chess_map(),((self.m_game_over_flag == 1) and false) or true);

    mvData.manual_type = (RoomProxy.getInstance():getCurRoomType() == RoomConfig.ROOM_TYPE_WATCH_ROOM and 6) or 1;
--    mvData.start_fen = GameCacheData.getInstance():getString(GameCacheData.DAPU_LAST_BORAD_FEN,GameCacheData.NULL);
--    mvData.chessString = GameCacheData.getInstance():getString(GameCacheData.DAPU_LAST_CHESS_STR,GameCacheData.NULL);
--    mvData.move_list = table.concat(self.m_board:to_mvList(),GameCacheData.chess_data_key_split);
    mvData.createrName = "";
    mvData.is_collect = 0;-- 是否收藏
	mvData.time = os.date("%Y/%m/%d",os.time())
--    local mvData_str = json.encode(mvData);
--    print_string("mvData_str = " .. mvData_str);
--	GameCacheData.getInstance():saveString(GameCacheData.RECENT_DAPU_KEY .. uid,table.concat(keys_table,GameCacheData.chess_data_key_split));
--	GameCacheData.getInstance():saveString(key .. uid,mvData_str);

	GameCacheData.getInstance():saveString(GameCacheData.DAPU_LAST_BORAD_FEN,GameCacheData.NULL);
	GameCacheData.getInstance():saveString(GameCacheData.DAPU_LAST_CHESS_STR,GameCacheData.NULL);

    -- 从服务器拉取整个棋盘

    self:requestCtrlCmd(OnlineRoomController.s_cmds.save_recent_chess_data,mvData);


	return true;	--保存成功
end

OnlineRoomSceneNew.takePictureComplete = function(self)
    if self.m_account_dialog then
        self.m_account_dialog:shareDialogHide();
    end;
end

function OnlineRoomSceneNew:setTimeResponse(isAgree)
    if not isAgree then
        self:reMatch()
    end
end
-- 重新匹配
function OnlineRoomSceneNew:reMatch()
    if roomType ~= RoomConfig.ROOM_TYPE_PRIVATE_ROOM and 
        roomType ~= RoomConfig.ROOM_TYPE_FRIEND_ROOM and 
        roomType ~= RoomConfig.ROOM_TYPE_MONEY_MATCH_ROOM and 
        roomType ~= RoomConfig.ROOM_TYPE_METIER_ROOM then 
        if self.m_match_dialog then
            self:updateRestartView(false)
            self.m_match_dialog:show(self,UserInfo.getInstance():getMatchTime());
            self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_logout);
            self.m_login_succ = false
            self.m_matchIng = true;
            self.m_match_dialog:rematch();
        end
    end
end

--再来一局
OnlineRoomSceneNew.sendReadyMsg = function(self)
    local roomType = RoomProxy.getInstance():getCurRoomType();
    if roomType == RoomConfig.ROOM_TYPE_PRIVATE_ROOM then
        self:ready_action()
    elseif not self.m_upuser_leave then
        self:ready_action()
    else
        self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_offline);
        if self.mModule and self.mModule.matchRoom then
            self.mModule:matchRoom();
        end
    end
end

--展示悔棋结果
OnlineRoomSceneNew.resPonseUndoMove = function(self,data)   
	print_string("对手悔棋");

--	self.m_board:severUndoMove(data);
    self:synchroRequest(); -- 本地可能没有走棋数据改成同步服务器数据
	if UserInfo.getInstance():getUid() == self.OpponentID then
		self.m_downUser:setTimeout2(self.m_timeout2);
		if self.m_timeout2 then
--			self.m_down_timeout2_text:setText(self.m_downUser:getTimeout2());
		end
		local message = "由于对方使用强制悔棋你将获得"..self.GetCoin.."金币的补偿";
		ChatMessageAnim.play(self.m_root_view,3,message);
--        ChessToastManager.getInstance():showSingle(message);
		self:resPonseUndoMoveSure();
	else
		self.m_upUser:setTimeout2(self.m_timeout2);
		if self.m_timeout2 then
--			self.m_up_timeout2_text:setText(self.m_upUser:getTimeout2());
		end
	end
end

--展示悔棋结果金币设置
OnlineRoomSceneNew.resPonseUndoMoveSure = function(self)   
	local money = UserInfo.getInstance():getMoney() + self.GetCoin;
	UserInfo.getInstance():setMoney(money) ;
    self:updateUserInfoView()
end

--发送聊天
OnlineRoomSceneNew.sendChat = function(self,msgType,message)
	local roomType = RoomProxy.getInstance():getCurRoomType();

	if not self.m_downUser then
		print_string("Room.showDownChat but not self.m_downUser");
		return;
	end

--	if not self.m_upUser or not self.m_up_user_icon:getVisible() then  -- 没有对手不让发聊天信息
--		print_string("Room.showDownChat but not self.m_upUser");
--		local message = "玩家还没来不能聊天。"
--        ChessToastManager.getInstance():showSingle(message);
--		return;
--	end

	if roomType == RoomConfig.ROOM_TYPE_WATCH_ROOM then
		print_string("Room.showDownChat but ROOM_TYPE_WATCH_ROOM");
		return
	end

    if lua_multi_click(3) then
		local message = "亲，请喝口水休息一会再说吧。"
		ChatMessageAnim.play(self.m_root_view,3,message);
--        ChessToastManager.getInstance():showSingle(message);
		return;
	end

    self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_chat, message);
end

--下部玩家聊天动画
OnlineRoomSceneNew.showDownChat = function(self,msgType,message)
	ChatMessageAnim.play(self.m_root_view,1,message);
	kEffectPlayer:playChat(self.m_downUser:getSex(),EffectsPhrases[message]);
	self.m_chat_dialog:addChatLog(self.m_downUser:getName(),message,self.m_downUser:getUid());
    if self.m_chat_btn and not self.m_chat_dialog:isShowing()  then 
       if self.m_chat_btn:getChildByName("notice") and RoomProxy.getInstance():getCurRoomType() == RoomConfig.ROOM_TYPE_WATCH_ROOM then
        self.m_chat_btn:getChildByName("notice"):setVisible(true);
       end 
    end
end

--上部玩家聊天动画
OnlineRoomSceneNew.showUpChat = function(self,msgType,message)
	if not self.m_upUser then
		print_string("Room.showUpChat but not self.m_upUser");
		return;
	end
	if not message or message == "" then
		return;
	end

	ChatMessageAnim.play(self.m_root_view,2,message);
	kEffectPlayer:playChat(self.m_upUser:getSex(),EffectsPhrases[message]);
	self.m_chat_dialog:addChatLog(self.m_upUser:getName(),message,self.m_upUser:getUid());
    if self.m_chat_btn and not self.m_chat_dialog:isShowing() then 
       if self.m_chat_btn:getChildByName("notice") and RoomProxy.getInstance():getCurRoomType() == RoomConfig.ROOM_TYPE_WATCH_ROOM then
        self.m_chat_btn:getChildByName("notice"):setVisible(true);
       end 
    end
end

--登陆房间失败
OnlineRoomSceneNew.loginFail = function(self,message)
	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end
	self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE,"知道了","收藏棋谱");
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:setPositiveListener(self,self.exitRoom);
    self.m_chioce_dialog:setNegativeListener(self,self.savetoLocal);
	self.m_chioce_dialog:show();
end


-- 收藏棋谱
OnlineRoomSceneNew.savetoLocal = function(self)
    -- 收藏弹窗
    if not self.m_account_save_dialog then
        self.m_account_save_dialog = new(ChioceDialog)
    end;
    self.m_account_save_dialog:setMode(ChioceDialog.MODE_SHOUCANG);  
    self.m_save_cost = UserInfo.getInstance():getFPcostMoney().save_manual;  
    if tonumber(self.m_save_cost) == 0 then
--        self.m_account_save_dialog:setMessage("收藏棋谱免费，确认收藏？");
        self:saveChesstoMysave();
    else
        self.m_account_save_dialog:setMessage("是否花费"..(self.m_save_cost or 500) .."金币收藏当前棋谱？");
        self.m_account_save_dialog:setPositiveListener(self, self.saveChesstoMysave);
        self.m_account_save_dialog:setNegativeListener(self, self.exitRoom);
        self.m_account_save_dialog:show();
    end;

end;

-- 收藏棋谱
OnlineRoomSceneNew.savetoLocal2 = function(self)
    -- 收藏弹窗
    if not self.m_account_save_dialog then
        self.m_account_save_dialog = new(ChioceDialog)
    end;
    self.m_account_save_dialog:setMode(ChioceDialog.MODE_SHOUCANG);  
    self.m_save_cost = UserInfo.getInstance():getFPcostMoney().save_manual;  
    if tonumber(self.m_save_cost) == 0 then
--        self.m_account_save_dialog:setMessage("收藏棋谱免费，确认收藏？");
        self:saveChesstoMysave();
    else
        self.m_account_save_dialog:setMessage("是否花费"..(self.m_save_cost or 500) .."金币收藏当前棋谱？");
        self.m_account_save_dialog:setPositiveListener(self, self.saveChesstoMysave);
        self.m_account_save_dialog:setNegativeListener(nil, nil);
        self.m_account_save_dialog:show();
    end;
end;



-- 收藏到我的收藏
OnlineRoomSceneNew.saveChesstoMysave = function(self,item)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.save_mychess,self.m_account_save_dialog:getCheckState());
end;



--退出房间（回退事件）
OnlineRoomSceneNew.onExitRoom = function(self)
    if self.m_up_user_info_dialog and self.m_up_user_info_dialog:isShowing() then
        self.m_up_user_info_dialog:dismiss()
        return false
    end
    if self.m_down_user_info_dialog and self.m_down_user_info_dialog:isShowing() then
        self.m_down_user_info_dialog:dismiss()
        return false
    end
    self:back_action();
    return true
end

--返回监听事件
OnlineRoomSceneNew.back_action = function(self)
	print_string("Room.back_action gametype = " .. self.m_gametype);
    self.mModule:backAction();
--    self.mModule:showanim()
end

--强制离开
OnlineRoomSceneNew.onForceLeave = function(self,message)
    if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end
    self:clearDialog();
    -- 在私人房好友挑战的时候 实现弹出结算窗口 之后在弹出这个  然后就会导致后面背景虚化 
    if self.m_account_dialog and self.m_account_dialog:isShowing() then
		self.m_account_dialog:dismiss2();
	end
    self.m_chioce_dialog:setMessage(message or "棋局结束，请退出房间!");
    self.m_chioce_dialog:setMode();
    self.m_chioce_dialog:setPositiveListener(self,self.exitRoom);
    self.m_chioce_dialog:show();
end

--更新用户信息弹窗
OnlineRoomSceneNew.onUpdateUserInfoDialog = function(self,info)
--    if self.m_up_user_info_dialog and self.m_up_user_info_dialog:isShowing() then
--        self.m_up_user_info_dialog:update(info)
--    end
--    if self.m_down_user_info_dialog and self.m_down_user_info_dialog:isShowing() then
--        self.m_down_user_info_dialog:update(info)
--    end
end

--直接退出房间
OnlineRoomSceneNew.exitRoom = function(self)
	--print_string("self.m_downUser:getStatus() = " .. self.m_downUser:getStatus());
	print_string("Room.exitRoom gametype = " .. self.m_gametype);
    UserInfo.getInstance():setChallenger(nil);
	OnlineConfig.deleteTimer(self); 
    self.m_board_menu_dialog:dismiss();
    self.m_connectCount = 0;
	UserInfo.getInstance():setRelogin(false) 

    if self.m_matchIng then
        self.mModule:cancelMatch();
        self.m_matchIng = false;
    end

	local roomType = RoomProxy.getInstance():getCurRoomType();
	if roomType ~= RoomConfig.ROOM_TYPE_WATCH_ROOM then
        if self.m_login_succ then
            self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_logout);
--            return;
        end
	elseif roomType == RoomConfig.ROOM_TYPE_WATCH_ROOM then
        self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_logout);
	end
    self:clearRoomInfo();
    self:clearDialog();
    self:requestCtrlCmd(OnlineRoomController.s_cmds.back_action);
end

--不发送消息给server ，直接退出房间
OnlineRoomSceneNew.exitRoom2 = function(self)
	--print_string("self.m_downUser:getStatus() = " .. self.m_downUser:getStatus());
	print_string("Room.exitRoom gametype = " .. self.m_gametype);
    UserInfo.getInstance():setChallenger(nil);
	OnlineConfig.deleteTimer(self); 
    self.m_board_menu_dialog:dismiss();
    self.m_connectCount = 0;
	UserInfo.getInstance():setRelogin(false) 

	local roomType = RoomProxy.getInstance():getCurRoomType();
	if roomType ~= RoomConfig.ROOM_TYPE_WATCH_ROOM then
        if self.m_login_succ then
            self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_logout);
            return;
        end
    end
    self:clearRoomInfo();
    self:clearDialog();
    self:requestCtrlCmd(OnlineRoomController.s_cmds.back_action);
end

OnlineRoomSceneNew.onServerMsgLogoutSucc = function(self)
    if self.changeRoom then
        print_string("logout success ------------------> ");
        self:clearChangeInfo();
--        self:clearRoomInfo();
    else
        if self.mModule and self.mModule.onServerMsgLogoutSucc then
            self.mModule:onServerMsgLogoutSucc()
        else
            self:clearRoomInfo();
--            self:requestCtrlCmd(OnlineRoomController.s_cmds.back_action);
        end
    end
end;

--服务器异常
OnlineRoomSceneNew.onClientUserOtherError = function(self, data)
    ChessToastManager.getInstance():showSingle("登录错误");
    self:exitRoom();
end;

--1.9.5版本之前的抢先逻辑
OnlineRoomSceneNew.forestallEvent = function(self,data)

    self:clearDialog();
	if not self.m_forestall_dialog then
		self.m_forestall_dialog = new(ForestallDialog);
		self.m_forestall_dialog:setPositiveListener(self,self.agreeForestall);
		self.m_forestall_dialog:setNegativeListener(self,self.refuseForestall);
	end
	
	if data.curr_uid == self.m_downUser:getUid() then    --由我抢先
		self.m_forestall_dialog:show(data.timeout);
        if data.pre_call_uid == self.m_downUser:getUid() then
            local message = "抢先成功 倍数为 " .. data.multiply;
            self:showLoadingDialog(message,data.timeout);
		    ForestallAnim.play(nil,true,data.multiply);
        elseif data.pre_call_uid == self.m_upUser:getUid() then
            ForestallAnim.play(nil,true,data.multiply);
        elseif data.pre_call_uid == 0 then

        end;
	elseif data.curr_uid == self.m_upUser:getUid() then  --等待对手抢先
        if data.pre_call_uid == self.m_downUser:getUid() then
            local message = "抢先成功 倍数为 " .. data.multiply;
            self:showLoadingDialog(message,data.timeout);
	        ForestallAnim.play(nil,true,data.multiply);
        elseif data.pre_call_uid == self.m_upUser:getUid() then
            
        elseif data.pre_call_uid == 0 then
          	local message = "等待对手抢先！"
		    self:showLoadingDialog(message,data.timeout);  
        end;
	elseif data.curr_uid == 0 then--抢先结束
        if data.pre_call_uid == self.m_downUser:getUid() then
            ForestallAnim.play(nil,true,data.multiply);
        elseif data.pre_call_uid == self.m_upUser:getUid() then
            ForestallAnim.play(nil,true,data.multiply);     
        elseif data.pre_call_uid == 0 then
            --取消抢先返回        
            ForestallAnim.play(nil,false,data.multiply);  
        end;
    end
end

OnlineRoomSceneNew.agreeForestall = function(self)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.server_msg_forestall ,1);
end

OnlineRoomSceneNew.refuseForestall = function(self)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.server_msg_forestall ,0);
end

--1.9.5版本新的抢先
OnlineRoomSceneNew.forestallEventNew = function(self,data)
    self:clearDialog();
	if not self.m_forestall_dialog_new then
		self.m_forestall_dialog_new = new(ForestallDialogNew);
		self.m_forestall_dialog_new:setBtn1Func(self,self.btn1Forestall);
		self.m_forestall_dialog_new:setBtn2Func(self,self.btn2Forestall);
        self.m_forestall_dialog_new:setNoForeBtnFunc(self,self.noForestall);
	end
	
	if data.curr_uid == self.m_downUser:getUid() then    --由我抢先
		self.m_forestall_dialog_new:show(data);
        if data.pre_call_uid == self.m_downUser:getUid() then
            local message = "抢先成功 倍数为 " .. data.curr_beishu;
            self:showLoadingDialog(message,data.timeout);
		    ForestallAnim.play(self.m_root_view,true,data.curr_beishu);
        elseif data.pre_call_uid == self.m_upUser:getUid() then
            ForestallAnim.play(self.m_root_view,true,data.curr_beishu);
        elseif data.pre_call_uid == 0 then

        end;
	elseif data.curr_uid == self.m_upUser:getUid() then  --等待对手抢先
        if data.pre_call_uid == self.m_downUser:getUid() then
            local message = "抢先成功 倍数为 " .. data.curr_beishu;
            self:showLoadingDialog(message,data.timeout);
	        ForestallAnim.play(self.m_root_view,true,data.curr_beishu);
        elseif data.pre_call_uid == self.m_upUser:getUid() then
            
        elseif data.pre_call_uid == 0 then
          	local message = "等待对手抢先！"
		    self:showLoadingDialog(message,data.timeout);  
        end;
	elseif data.curr_uid == 0 then--抢先结束
        if data.pre_call_uid == self.m_downUser:getUid() then
            if data.pre_call_uid_act == 0 then
                ForestallAnim.play(self.m_root_view,false,data.curr_beishu);
            else
                ForestallAnim.play(self.m_root_view,true,data.curr_beishu);
            end
        elseif data.pre_call_uid == self.m_upUser:getUid() then
            if data.pre_call_uid_act == 0 then
                ForestallAnim.play(self.m_root_view,false,data.curr_beishu);
            else
                ForestallAnim.play(self.m_root_view,true,data.curr_beishu);
            end    
        elseif data.pre_call_uid == 0 then
            --取消抢先返回        
            ForestallAnim.play(self.m_root_view,false,data.curr_beishu);  
        end;
    end
end

OnlineRoomSceneNew.btn1Forestall = function(self,opt_beishu)
    StatisticsManager.getInstance():onCountToUM(ROOM_READYING_FORESTALL_TRUE,opt_beishu)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.server_msg_forestall_new ,opt_beishu);
end

OnlineRoomSceneNew.btn2Forestall = function(self,opt_beishu)
    StatisticsManager.getInstance():onCountToUM(ROOM_READYING_FORESTALL_TRUE,opt_beishu)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.server_msg_forestall_new ,opt_beishu);
end

OnlineRoomSceneNew.noForestall = function(self)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.server_msg_forestall_new ,0);
end


--3.2.0版本新的抢先
OnlineRoomSceneNew.forestallEvent320 = function(self,data)
    self:clearDialog()
	if not self.m_forestall_dialog_320 then
		self.m_forestall_dialog_320 = new(ForestallDialog320);
		self.m_forestall_dialog_320:setBtn1Func(self,self.btn1Forestall320);
		self.m_forestall_dialog_320:setBtn2Func(self,self.btn1Forestall320);
        self.m_forestall_dialog_320:setNoForeBtnFunc(self,self.noForestall320);
	end
	if not self.m_forestall_wait_dialog_320 then
		self.m_forestall_wait_dialog_320 = new(ForestallWaitDialog320)
	end
	
	if data.curr_uid == self.m_downUser:getUid() then    --由我抢先
		self.m_forestall_dialog_320:show(data);
        if data.pre_call_uid == self.m_downUser:getUid() then
        elseif data.pre_call_uid == self.m_upUser:getUid() then
            if data.pre_call_uid_add_money > 0 then
                self.m_forestall_dialog_320:startAddMoneyAnim(data.pre_call_uid,data.pre_call_uid_add_money)
            end
        elseif data.pre_call_uid == 0 then

        end;
	elseif data.curr_uid == self.m_upUser:getUid() then  --等待对手抢先
		self.m_forestall_wait_dialog_320:show(data)
        if data.pre_call_uid == self.m_downUser:getUid() then
        elseif data.pre_call_uid == self.m_upUser:getUid() then
            if data.pre_call_uid_add_money > 0 then
                self.m_forestall_wait_dialog_320:startAddMoneyAnim(data.pre_call_uid,data.pre_call_uid_add_money)
            end
        elseif data.pre_call_uid == 0 then
        end
	elseif data.curr_uid == 0 then--抢先结束
        if data.pre_call_uid == self.m_downUser:getUid() then
            if data.pre_call_uid_add_money == 0 then
                -- 自己放弃抢先
            else
                -- 自己抢先成功
            end
        elseif data.pre_call_uid == self.m_upUser:getUid() then
            if data.pre_call_uid_add_money == 0 then
                -- 对手放弃抢先
            else
                -- 对手抢先成功
                if data.pre_call_uid_add_money > 0 then
                    self.m_forestall_wait_dialog_320:startAddMoneyAnim(data.pre_call_uid,data.pre_call_uid_add_money)
                end
            end    
        elseif data.pre_call_uid == 0 then
            --无人抢先        
        end
    end
end

OnlineRoomSceneNew.btn1Forestall320 = function(self,opt_add_money)
    StatisticsManager.getInstance():onCountToUM(ONLINE_READY_PROCESS_SURE_FORESTALL,opt_add_money)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.server_msg_forestall_320 ,opt_add_money);
end

OnlineRoomSceneNew.btn2Forestall320 = function(self,opt_add_money)
    StatisticsManager.getInstance():onCountToUM(ONLINE_READY_PROCESS_SURE_FORESTALL,opt_add_money)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.server_msg_forestall_320 ,opt_add_money);
end

OnlineRoomSceneNew.noForestall320 = function(self)
    StatisticsManager.getInstance():onCountToUM(ONLINE_READY_PROCESS_GIVEUP_FORESTALL)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.server_msg_forestall_320 ,0);
end

OnlineRoomSceneNew.showLoadingDialog = function(self,message,time)
	if not self.m_loading_dialog then
		self.m_loading_dialog = new(LoadingDialog);
	end
	self.m_loading_dialog:setMessage(message);
	self.m_loading_dialog:show(time);
end

OnlineRoomSceneNew.showLoadingDialog2 = function(self,message,time,phrases)
	if not self.m_loading_dialog2 then
		self.m_loading_dialog2 = new(LoadingDialog2);
        self.m_loading_dialog2:setRoom(self)
	end
    if phrases then
        self.m_loading_dialog2:setPhrases(phrases)
    end
	self.m_loading_dialog2:setMessage(message);
	self.m_loading_dialog2:show(time);
end

--领取宝箱回调
OnlineRoomSceneNew.onClientGetOpenboxTime = function(self, data)
    if data and data.flag == 1 then
--	    self:show_reward_dlg("恭喜你获得："..data.msg) ;
--	    local money = UserInfo:getInstance():getMoney();		
        self.m_chest_anim_bg:setVisible(true);
        self.m_chest_icon:setFile("common/decoration/chest_2.png");
        local callbackEvent = {};
        callbackEvent.func = function(self)
            OnlineRoomSceneNew.endOpenChest(self);
            self:requestCtrlCmd(OnlineRoomController.s_cmds.client_get_openbox_time,1, data.changeMoney);
            OnlineConfig.startOnlineBoxtimer(self);    
        end
        callbackEvent.obj = self;
        OnlineRoomSceneNew.startOpenChestAnim(self,self.m_chest_anim_bg,self.m_chest_icon,callbackEvent,data.msg);
        return;
    elseif data and data.flag == 2 then
	    local message = "请稍候重试！"
        ChessToastManager.getInstance():showSingle(message);
	    return;
    elseif data and data.flag == -2 then
        local message = "重复领取，请稍候重试！"
	    ChessToastManager.getInstance():showSingle(message);
        return;
    end

    OnlineConfig.startOnlineBoxtimer(self);    
end;


OnlineRoomSceneNew.onServerMsgUserLeave = function(self, data)
    local ret = true
    -- 结算页和结算页中的选择页是否正在显示
    if self.m_account_dialog then
        if self.m_account_dialog:isShowing() or self.m_account_dialog:getChoiceDialogStatus() then
            ret = false
        end
    end
    self:userLeave(data.leave_uid,ret);
    OnlineConfig.deleteTimer(); 
end;

OnlineRoomSceneNew.onServerMsgForestall = function(self, data)
    self:forestallEvent(data)
end;

OnlineRoomSceneNew.onServerMsgForestallNew = function(self, data)
    self:forestallEventNew(data)
end;

OnlineRoomSceneNew.onServerMsgForestall320 = function(self, data)
    self:forestallEvent320(data)
end;

OnlineRoomSceneNew.onServerMsgHandicap = function(self, data)
    self:handicapEvent(data)
end;

OnlineRoomSceneNew.onServerMsgHandicapResult = function(self, data)
    self:dismissLoadingDialog();
    self:dismissLoadingDialog2();
    if data.result == 0 then--成功
		if data.chessId == R_ROOK1 or data.chessId == R_ROOK2 then
			kEffectPlayer:playEffect(Effects.AUDIO_HANDICAP_ROOK);
		elseif data.chessId == R_HORSE1 or data.chessId == R_HORSE2 then
			kEffectPlayer:playEffect(Effects.AUDIO_HANDICAP_HORSE);
		elseif data.chessId == R_CANNON1 or data.chessId == R_CANNON2 then
			kEffectPlayer:playEffect(Effects.AUDIO_HANDICAP_CANNON);
		end
    elseif data.result == 1 then--失败
        
    end
end

OnlineRoomSceneNew.onServerMsgHandicapConfirm = function(self, data)
    self:dismissLoadingDialog();
    self:dismissLoadingDialog2();
    if data.black_uid == UserInfo.getInstance():getUid() then
		if not self.m_handicap_confirm_dialog then
			self.m_handicap_confirm_dialog = new(HandicapConfirmDialog);
            self.m_handicap_confirm_dialog:onSureFunc(self,self.onHandicapAgree);
            self.m_handicap_confirm_dialog:onCancleFunc(self,self.onHandicapDisagree);
		end
		self.m_handicap_confirm_dialog:show(data);
    else
        local message = "等待对方同意让子"
        local phrases = {
            "快点吧，我等得花儿都要谢了！",
            "同意吧，谢谢！",
            "接受我的挑战吧！",
            "多倍收入等着你！",
            "让你车马炮又如何！",
        }
		self:showLoadingDialog2(message,data.timeout,phrases);
    end
end

function OnlineRoomSceneNew:onServerMsgGameStartInfo(data)
    local roomType = RoomProxy.getInstance():getCurRoomType()
    if roomType == RoomConfig.ROOM_TYPE_NOVICE_ROOM or
        roomType == RoomConfig.ROOM_TYPE_INTERMEDIATE_ROOM or 
        roomType == RoomConfig.ROOM_TYPE_MASTER_ROOM then 
        if not self.mGameStartInfoDialog then
            self.mGameStartInfoDialog = new(StartGameDialog)
        end
        self.mGameStartInfoDialog:setData(data)
        self.mGameStartInfoDialog:show(data.timeout)
    end
end

function OnlineRoomSceneNew:onHandicapAgree(mulpity)
    local info = mulpity or 1
    StatisticsManager.getInstance():onCountToUM(ONLINE_READY_PROCESS_SURE_HANDICAP,info)
    OnlineSocketManager.getHallInstance():sendMsg(SERVER_MSG_HANDICAP_CONFIRM,info)
end

function OnlineRoomSceneNew:onHandicapDisagree()
    StatisticsManager.getInstance():onCountToUM(ONLINE_READY_PROCESS_GIVEUP_HANDICAP)
    OnlineSocketManager.getHallInstance():sendMsg(SERVER_MSG_HANDICAP_CONFIRM,1)
end

OnlineRoomSceneNew.userLeave = function(self,leaveUid,ret)
    local isMatchIng = false
	self:stopTimeout();
	if self.m_match_dialog and self.m_match_dialog:isShowing() then
        isMatchIng = true
    end
    local isWaiting = false
    if self.mRoomWaitSetTimeDialog and self.mRoomWaitSetTimeDialog:isShowing() then
        isWaiting = true
    end
    if self.m_roomSetTimeDialog and self.m_roomSetTimeDialog:isShowing() then
        isWaiting = true
    end
    if self.m_roomOtherSetTimeDialog and self.m_roomOtherSetTimeDialog:isShowing() then
        isWaiting = true
    end
    if self.mRoomWaitOtherSetTimeDialog and self.mRoomWaitOtherSetTimeDialog:isShowing() then
        isWaiting = true
    end
    
	self:clearDialog();
	if self.m_downUser and self.m_downUser:getUid() == leaveUid then
--		RoomProxy.getInstance():setTid(0);
		self.m_down_user_ready_img:setVisible(self.m_downUser:getReadyVisible());
	    self.m_down_user_start_btn:setVisible(self.m_downUser:getStartVisible());

		self.m_up_user_ready_img:setVisible(false);
--		self.m_up_user_icon:setVisible(false);  ---表现形式将对走离开
        if self.m_down_view1 and self.m_down_view1.user_icon then
            self.m_down_view1.user_icon:setVisible(false)
        end
        self.m_downUser = nil;

	elseif self.m_upUser and self.m_upUser:getUid() == leaveUid then
        local roomType = RoomProxy.getInstance():getCurRoomType(); --用户的游戏模式
        if roomType == RoomConfig.ROOM_TYPE_PRIVATE_ROOM then -- 私人房重置房主
            if UserInfo.getInstance():getCustomRoomType() == 0 then
                RoomProxy.getInstance():setSelfRoom(true);
                if self.m_private_change_player_btn and self.m_private_invite_friends_btn then
                    self.m_private_change_player_btn:setVisible(RoomProxy.getInstance():isSelfRoom() and false);
                    self.m_private_invite_friends_btn:setVisible(RoomProxy.getInstance():isSelfRoom() and true);
                end
            else
                if self.m_private_change_player_btn and self.m_private_invite_friends_btn then
                    self.m_private_change_player_btn:setVisible(false);
                    self.m_private_invite_friends_btn:setVisible(false);
                end
                UserInfo.getInstance():setCustomRoomType(0);
            end;
        end
        --上家离开，分为2种情况：
        --1，结算框离开，则自己还没有准备，self.m_ready_status==false,点击再来一局，弹选难度对话框。
        --2，点再来一局准备后，上家离开，此时self.m_ready_status == true,需强制自己退出server房间
        --（还在房间内，只是没有登陆server房间），弹选难度对话框。
        self.m_upuser_leave = true;
        --只要一个玩家离开，都要退出server房间
        if roomType ~= RoomConfig.ROOM_TYPE_PRIVATE_ROOM and 
            roomType ~= RoomConfig.ROOM_TYPE_FRIEND_ROOM and 
            roomType ~= RoomConfig.ROOM_TYPE_MONEY_MATCH_ROOM and 
            roomType ~= RoomConfig.ROOM_TYPE_METIER_ROOM then 
            self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_logout);
            if ret and self.m_login_succ then
                self.m_login_succ = false
                ChessToastManager.getInstance():showSingle("对方退出房间");
--                if self.mModule.showRematchComfirmDialog then
--                    self.mModule:showRematchComfirmDialog();
--                end
            end
            if roomType ~= RoomConfig.ROOM_TYPE_WATCH_ROOM then
                self:updateRestartView(true,true)
                if isMatchIng and self.m_match_dialog then
                    self:reMatch()
                end
                if isWaiting then
                    self:reMatch()
                end
            end
        elseif roomType == RoomConfig.ROOM_TYPE_FRIEND_ROOM then
            self:onForceLeave();
        end

        self.m_up_view1:resetIconView()

--		self.m_up_user_icon:setFile(User.MAN_ICON);
--		HeadSmogAnim.play(self.m_up_user_icon);
--        self.m_up_name:setText("");
        self.up_turn:setVisible(false);
--		self.m_up_user_icon:setVisible(false);
		self.m_up_user_ready_img:setVisible(false);
--        self.m_up_vip_frame:setVisible(false);
--        self.m_up_vip_logo:setVisible(false);
        if roomType ~= RoomConfig.ROOM_TYPE_MONEY_MATCH_ROOM and
            roomType ~= RoomConfig.ROOM_TYPE_METIER_ROOM then
--            self.m_board:dismissChess();
        end
        if self.m_roomSetTimeDialog then
            self.m_roomSetTimeDialog:dismiss();
        end
        if self.mRoomWaitSetTimeDialog then
            self.mRoomWaitSetTimeDialog:dismiss();
        end
        if self.m_roomOtherSetTimeDialog then
            self.m_roomOtherSetTimeDialog:dismiss();
        end
        if self.mRoomWaitOtherSetTimeDialog then
            self.mRoomWaitOtherSetTimeDialog:dismiss();
        end
        
--        if self.m_account_dialog then
--            self.m_account_dialog:dismiss();
--            delete(self.m_account_dialog);
--            self.m_account_dialog = nil;
--        end;
        self.mNewPlayer = true
        self.m_upUser = nil;
	end
end

--Server通知对话
OnlineRoomSceneNew.onClientMsgChat = function(self, data)
    if not data then
        return
    end
    if FriendsData.getInstance():isInBlacklist(data.uid) then return end
    if self.m_downUser:getUid() == data.uid then
        self:showDownChat(1,data.message);
    else
        self:showUpChat(data.msgType,data.message);
    end
end;

--Server通知让子
OnlineRoomSceneNew.onClientMsgHandicap = function(self, data)
    if not data then
        return;
    end;
    self:handicapEvent(data);
end;

--Server通知游戏开始
OnlineRoomSceneNew.onServerMsgGamestart = function(self, data)
    if not data or not self.m_downUser or not self.m_upUser then
        return;
    end;
    if self.mModule and self.mModule.onDeleteInvitAnim then
        self.mModule:onDeleteInvitAnim();
    end

    if self.mModule and self.mModule.onServerMsgGamestart then
        self.mModule:onServerMsgGamestart();
    end

	self.m_timeout1 = data.round_time;
	self.m_timeout2 = data.step_time;
	self.m_timeout3 = data.sec_time;

	if self.m_downUser:getUid() == data.uid1 then
		if FLAG_RED == data.flag1 then
            self.m_downUser:setFlag(FLAG_RED);
			if self.m_upUser then
				self.m_upUser:setFlag(FLAG_BLACK);
			end
        else
            self.m_downUser:setFlag(FLAG_BLACK);
			if self.m_upUser then
				self.m_upUser:setFlag(FLAG_RED);
			end
        end;
        self.m_upUser:setMoney(data.uid2_money);
        self.m_downUser:setMoney(data.uid1_money);
	else
        if FLAG_RED == data.flag2 then
			self.m_downUser:setFlag(FLAG_RED);
			if self.m_upUser then
				self.m_upUser:setFlag(FLAG_BLACK);
			end
        else
            self.m_downUser:setFlag(FLAG_BLACK);
			if self.m_upUser then
				self.m_upUser:setFlag(FLAG_RED);
			end
        end;
        
        self.m_upUser:setMoney(data.uid1_money);
        self.m_downUser:setMoney(data.uid2_money);
	end
		self.m_downUser:setTimeout1(data.round_time);
		self.m_downUser:setTimeout2(data.step_time);
		self.m_downUser:setTimeout3(data.sec_time);

		self.m_upUser:setTimeout1(data.round_time);
		self.m_upUser:setTimeout2(data.step_time);
		self.m_upUser:setTimeout3(data.sec_time);
	    if self.m_downUser then
		    self.m_down_user_ready_img:setVisible(false);
	    end
	    if self.m_upUser then
		    self.m_up_user_ready_img:setVisible(false);
	    end
    self:updateUserInfoView()
    self:requestCtrlCmd(OnlineRoomController.s_cmds.client_get_openbox_time);
	ToolKit.addOnlineGameLogCount(self.m_root_view);
end;


function OnlineRoomSceneNew:updateUserInfoView()
    self.m_down_view1:updataMoneyData(self.m_downUser:getMoneyStr())
    if self.mModule and self.mModule.updateUserInfoView then
        self.mModule:updateUserInfoView()
    end
end

--Server通知游戏结束
OnlineRoomSceneNew.onServerMsgGameclose = function(self, data)
    if not data then
        return;
    end
	self:setStatus(data.table_status);
	if  self.m_downUser:getUid() == data.uid1 then
		self.m_downUser:setScore(data.score1);
        self.m_downUser:setPoint(data.tscore1);
        self.m_downUser:setCoin(data.tmoney1);
		self.m_downUser:setMoney(data.money1);
		self.m_downUser:setTaxes(data.rent);
		self.m_downUser:setCup(data.cups1);
        self.m_downUser:setTabCoin(data.tabMoney1);
		if self.m_upUser then
			self.m_upUser:setScore(data.score2);
			self.m_upUser:setPoint(data.tscore2);
			self.m_upUser:setCoin(data.tmoney2);
			self.m_upUser:setMoney(data.money2);
			self.m_upUser:setTaxes(data.rent);
		    self.m_upUser:setCup(data.cups2);
            self.m_upUser:setTabCoin(data.tabMoney2);
		end
	else
		self.m_downUser:setScore(data.score2);
        self.m_downUser:setPoint(data.tscore2);
        self.m_downUser:setCoin(data.tmoney2);
		self.m_downUser:setMoney(data.money2);
		self.m_downUser:setTaxes(data.rent);
		self.m_downUser:setCup(data.cups2);
        self.m_downUser:setTabCoin(data.tabMoney2);
		if self.m_upUser then
			self.m_upUser:setScore(data.score1);
			self.m_upUser:setPoint(data.tscore1);
			self.m_upUser:setCoin(data.tmoney1);
			self.m_upUser:setMoney(data.money1);
			self.m_upUser:setTaxes(data.rent);
		    self.m_upUser:setCup(data.cups1);
            self.m_upUser:setTabCoin(data.tabMoney1);
		end

	end
    self:updateUserInfoView()
    if self.m_downUser:getFlag() == FLAG_RED then
        self.m_downUser:setContinueWintimes(data.red_wintimes or 0);
        self.m_upUser:setContinueWintimes(data.black_wintimes or 0);
    else
        self.m_downUser:setContinueWintimes(data.black_wintimes or 0);
        self.m_upUser:setContinueWintimes(data.red_wintimes or 0);
    end;
    self.m_again_btn_timeout = data.ready_time or 9;--再来一局倒计时显示时间
    Log.i("OnlineRoomSceneNew.onServerMsgGameclose"..self.m_again_btn_timeout);
	self:gameClose(data.win_flag,data.end_type);
	
	OnlineConfig.deleteTimer(self); 

    if type(OnlineRoomController.s_switch_func) == "function" then
        self:exitRoom()
        return 
    end
	print_string("======服务器回应房间SERVER_MSG_GAME_CLOSE处理成功======");
end



OnlineRoomSceneNew.verify = function(self,onlineTime,isVerify)
	if isVerify == 0 then --0 未验证 
		local hour = onlineTime/60;
		local minute = onlineTime%60;

		UserInfo.getInstance():setOnLineTime(hour);

		if hour>=5 or (hour<5 and hour>=4 and minute>=30) then
			UserInfo.getInstance():setPreventAddictedTipsFlag(1);
		else
			UserInfo.getInstance():setPreventAddictedTipsFlag(0);
		end
	elseif isVerify == 2 then --2-未成年人 
		local hour = onlineTime/60;
		local minute = onlineTime%60;

		UserInfo.getInstance():setOnLineTime(hour);

		if hour>=5 or (hour<5 and hour>=4 and minute>=30) then
			UserInfo.getInstance():setPreventAddictedTipsFlag(2);
		else
			UserInfo.getInstance():setPreventAddictedTipsFlag(0);			
		end
	else
		UserInfo.getInstance():setPreventAddictedTipsFlag(0);
	end
end    

OnlineRoomSceneNew.onServerMsgWarning = function(self, data)
	--[[1 进入棋桌长时间不开始超时
		2 局时已经到
		3 步时已经到
		4 读秒时间到
		5  用户掉线提醒给对方
		6  SetTime的时候用户状态和所需的用户状态不符
		7用户重上线提醒给对方
		8 长时间不发起时间设置
		9长时间不应答时间设置
		10此帐号在别处登录
		11按了home键超时踢出房间踢出房间提醒消息
		12 用户重连成功，但是对手处于掉线状态
		13 用户掉线超时时间限制踢出房间提醒消息
		-1 SetTime的时候当前棋桌为空
		-2 SetTime的时候自己为空
		-10 SetTime的时候自己已经不在当前棋桌
	
		5，12 Msg表示时间
	]]--
    if not data then
        return;
    end;
	if data and data.type and data.msg then
		print_string(string.format("Room.tipsEvent type = %d,msg = %s",data.type,data.msg));
		if data.type == 5  or data.type == 12 then
	        data.msg = tonumber(data.msg);
	        local msg = "对手网络不佳，请稍候..."
	        RoomHomeScroll.play(self.m_root_view,msg,data.msg);
		elseif data.type == 7 then
			RoomHomeScroll.close();
		elseif data.type == 1 then
			local message = "长时间不准备踢出房间!"
			ChessToastManager.getInstance():showSingle(message);
			self:exitRoom();
		end
	else
		print_string("Room.tipsEvent = function(self,data) but bad args !");
	end
end;


OnlineRoomSceneNew.onServerMsgTips = function(self, data)
	--[[
        1 10步内未吃子将流局结束
        2 30秒内若不走棋将判输
        3 您今天输赢金币超过400 0000
        4 这局悔棋次数达上限
        5 元宝不足，无法悔棋
        6 对手强制悔棋，您得到金币
        7 支付失败，无法使用
        8 当前订单已经使用过
        9 30步内未吃子将流局结束
	]]--
    if not data then
        return;
    end;
	if data and data.type and data.msg then
		print_string(string.format("Room.tipsEvent type = %d,msg = %s",data.type,data.msg));
		if data.type == 1  or data.type == 9 then
	        ChatMessageAnim.play(self.m_root_view,3,data.msg);
--            ChessToastManager.getInstance():showSingle(data.msg);
        end;
	else
		print_string("Room.tipsEvent = function(self,data) but bad args !");
	end    
end;





--走棋
OnlineRoomSceneNew.onServerMsgMove = function(self, data)
    if not data then
        return;
    end;
    if data.errorCode < 0 then
        self:resPonseUnLegalMove(data.errorCode);
        return;
    end;
    
	if(data.errorCode >= 0) then
		--走棋成功
		if data.uid == self.m_downUser:getUid() then
            if self.m_downUser:getFlag() == FLAG_RED then
                self.m_move_flag = FLAG_BLACK;--此函数内接收的是已经走完的棋，所以将要走的棋标志置反。
            else
                self.m_move_flag = FLAG_RED;
            end;
			self.isUndoAble = true;
			self.m_downUser:setTimeout1((self.m_timeout1 - data.timeout));
			self.m_downUser:setTimeout2(self.m_timeout2);
			self.m_downUser:setTimeout3(self.m_timeout3);
		elseif data.uid == self.m_upUser:getUid() then
            if self.m_upUser:getFlag() == FLAG_RED then
                self.m_move_flag = FLAG_BLACK;
            else
                self.m_move_flag = FLAG_RED;
            end;
			self.m_upUser:setTimeout1(self.m_timeout1 - data.timeout);
			self.m_upUser:setTimeout2(self.m_timeout2);
			self.m_upUser:setTimeout3(self.m_timeout3);

			local mv = {}
			mv.moveChess = data.chessman;
			mv.moveFrom = data.position1;
			mv.moveTo = data.position2;
			self:resPonseMove(mv);
		else

		end
        self:setStatus(data.tableStatus);
		if data.errorCode == 9 then
			print_string("将军!!!!")
		end
	else
		print_string("CLIENT_MSG_MOVE errorCode ~= 0");
	end
end;

--和棋申请
OnlineRoomSceneNew.onClientMsgDraw1 = function(self, data)
    if not data then
        return;
    end;
    ChessToastManager.getInstance():showSingle(data);
end;

--和棋通知
OnlineRoomSceneNew.onClientMsgDraw2 = function(self, data)
    if not data then
        return;
    end;
	if self.m_upUser:getUid() == data.uid then
		self:responseDraw();
	end    
end;

OnlineRoomSceneNew.responseDraw = function(self)
	local message = self.m_upUser:getName() .. "请求和棋，您是否同意？"

	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end	
	self.m_chioce_dialog:setMode(ChioceDialog.MODE_AGREE);
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:setPositiveListener(self,self.agreeDraw);
	self.m_chioce_dialog:setNegativeListener(self,self.refuseDraw);
	self.m_chioce_dialog:show();
end

OnlineRoomSceneNew.agreeDraw = function(self)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_draw2, 1);
end

OnlineRoomSceneNew.refuseDraw = function(self)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_draw2, 2);
end

OnlineRoomSceneNew.onServerMsgDraw = function(self, data)
    if not data then
        return;
    end;
    self.m_tid = RoomProxy.getInstance():getTid();
    if self.m_tid == data.tableID then
		if  self.m_downUser:getUid() == data.drawID then
		    if data.isOK  == 2 then
			    if not self.m_chioce_dialog then
				    self.m_chioce_dialog = new(ChioceDialog);
			    end
			    local message = "对方拒绝了您的求和申请"
                ChessToastManager.getInstance():showSingle(message);
		    end
		end
	else
		print_string("返回棋桌与当前棋桌不相符");
	end
end;

--认输申请
OnlineRoomSceneNew.onClientMsgSurrender2 = function(self, data)
    if not data then
        return;
    end;
	if self.m_upUser:getUid() == data.uid then
        
		self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_surrender2, 1);  -- 直接同意
	end      
end;

--认输通知
OnlineRoomSceneNew.onServerMsgSurrender = function(self, data)
    if not data then
        return;
    end;
    self.m_tid = RoomProxy.getInstance():getTid();
	if self.m_tid == data.tableID then
		if  self.m_downUser:getUid() == data.faultID then
			if data.isOK  == 2 then
                local message = "申请认输失败！"
                ChessToastManager.getInstance():showSingle(message);
			end
		end
	else
		print_string("返回棋桌与当前棋桌不相符");
	end
end;

--悔棋模块
OnlineRoomSceneNew.onClientMsgUndomove = function(self, data)
    if not data then
        return;
    end;    

    if data.subcmd == 1 then
        if data.errorCode < 0 then
            if data.errorCode == -3 then
			    self:undoRequestCallBack(data.errorCode,"对手离场!");
            elseif data.errorCode == -4 then
			    self:undoRequestCallBack(data.errorCode,"超出悔棋步数!");
            else
			    self:undoRequestCallBack(data.errorCode,data.errorMsg);
            end
		end
    elseif data.subcmd == 2 then
        if self.m_upUser:getUid() == data.uid then
			self:undoResponse();
		end   
    
    elseif data.subcmd == 3 then
    --errCode
--= -3  对手不存在
--= -4  棋局已结束
--= -5  超出悔棋步数
--= -6  超出悔棋步数

--= 0    悔棋成功
        if data.errorCode == 0 then
            self.OpponentID = data.OpponentID;
		    self.GetCoin = data.GetCoin;
		    self.Undomovenum = data.Undomovenum;
		    if UserInfo.getInstance():getUid() ~= data.OpponentID then
			    self.isUseLeftUndo = false;
		    end
            self.m_tid = RoomProxy.getInstance():getTid();
		    if self.m_tid == data.tableID then
			    if data.isOK == 2 then
                    if data.undoID == self.m_downUser:getUid() then
		                local message = "对方拒绝了您的悔棋请求"
                        ChessToastManager.getInstance():showSingle(message);
				        return;
                    else
				        return;
                    end
			    end
                local undo_uid = data.undoID;
                if undo_uid == UserInfo.getInstance():getUid() then
                    if UserInfo.getInstance():getFlag() == FLAG_RED then
                        self.m_move_flag = FLAG_RED;
                    else
                        self.m_move_flag = FLAG_BLACK;
                    end;
                else
                    if self.m_upUser then
                        if self.m_upUser:getFlag() == FLAG_RED then
                            self.m_move_flag = FLAG_RED;
                        else
                            self.m_move_flag = FLAG_BLACK;
                        end; 
                    end;
                end;
			    self:setStatus(data.tableStatus);
			    if  data.chessID1 ~= 0 then
				    local mv = {}
				    mv.moveChess = data.chessID1;
				    mv.moveFrom = data.position1_1;
				    mv.moveTo = data.position1_2;
				    mv.dieChess = data.eatChessID1;
				    self:resPonseUndoMove(mv);
			    end
			    if  data.chessID2 ~= 0 then
				    local mv = {}
				    mv.moveChess = data.chessID2;
				    mv.moveFrom = data.position2_1;
				    mv.moveTo = data.position2_2;
				    mv.dieChess = data.eatChessID2;
				    self:resPonseUndoMove(mv);
			    end
		    else
			    print_string("返回棋桌与当前棋桌不相符");
		    end   
        else
        --= -3  对手不存在
--= -4  棋局已结束
--= -5  超出悔棋步数
--= -6  超出悔棋步数
            local msg = "悔棋失败";
            if data.errorCode == -3 then
                msg = '对手不存在,悔棋失败'
            elseif data.errorCode == -4 then
                msg = '棋局已结束,悔棋失败'
            elseif data.errorCode == -5 then
                msg = '超出悔棋步数,悔棋失败'
            elseif data.errorCode == -6 then
                msg = '超出悔棋步数,悔棋失败'
            end
            self:undoRequestCallBack(data.errorCode,msg);
        end
    elseif data.subcmd == 10 then
    	self:undoMoneyRequestCallBack(data.errorCode);
    elseif data.subcmd == 11 then
        if data.money < 0 then
            return;
        end;
        self:undoMoneyRequestAnswer(data.money);
    elseif data.subcmd == 13 then
        self:undoMoneyResult(data.uid_1,data.changeMoney_1,data.uid_2,data.changeMoney_2,data.isOK);
    end; 
end;

OnlineRoomSceneNew.undoMoneyResult = function(self,uid_1,changeMoney_1,uid_2,changeMoney_2,isOK)
    local upUserMoney = self.m_upUser:getMoney();
    local downUserMoney = UserInfo:getInstance():getMoney();
    if self.m_upUser:getUid() == uid_1 then
        self.m_upUser:setMoney(upUserMoney + changeMoney_1);
    elseif self.m_upUser:getUid() == uid_2 then
        self.m_upUser:setMoney(upUserMoney + changeMoney_2);
    end
    if UserInfo:getInstance():getUid() == uid_1 then
        UserInfo:getInstance():setMoney(downUserMoney + changeMoney_1);
    elseif UserInfo:getInstance():getUid() == uid_2 then
        UserInfo:getInstance():setMoney(downUserMoney + changeMoney_2);
    end
    self:updateUserInfoView()
end

OnlineRoomSceneNew.undoMoneyRequestCallBack = function(self,status)
    local message = ""
	if status == 0  then    --成功
        message = "请求已发送";
        --self.isUndoAble = true;
	elseif status == 1  then
        message = "金币不足";
    elseif status == 2 then
        message = "悔棋太频繁";
    elseif status == 3 then
        message = "状态错误";
    else
		message = "请求发送失败";
	end
    ChessToastManager.getInstance():showSingle(message);
end

OnlineRoomSceneNew.undoMoneyRequestAnswer = function(self,money)
    if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end
	local message = "对方向您支付"..tostring(money).."金币请求悔棋，是否同意？";
	self.m_chioce_dialog:setMode(ChioceDialog.MODE_AGREE);
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:setPositiveListener(self,self.agreeMoneyUndo);
	self.m_chioce_dialog:setNegativeListener(self,self.refuseMoneyUndo)
	self.m_chioce_dialog:show();
end

OnlineRoomSceneNew.agreeMoneyUndo = function(self)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_undomove, 12,1);
end

OnlineRoomSceneNew.refuseMoneyUndo = function(self)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_undomove, 12,2);
end

OnlineRoomSceneNew.undoResponse = function(self)
	--弹出选择框
	local message = self.m_upUser:getName() .. "请求悔棋，您是否同意？";

	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end

	self.m_chioce_dialog:setMode(ChioceDialog.MODE_AGREE);
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:setPositiveListener(self,self.agreeUndo);
	self.m_chioce_dialog:setNegativeListener(self,self.refuseUndo);
	self.m_chioce_dialog:show();
end

OnlineRoomSceneNew.agreeUndo = function(self)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_undomove, 2,1);
end

OnlineRoomSceneNew.refuseUndo = function(self)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_undomove, 2,2);

end

OnlineRoomSceneNew.undoRequestCallBack = function(self,status,msg)
	self.isUndoAble = true;

	if status == -11  then

	else
		self:showTipsDlg(msg,ChioceDialog.MODE_SURE);
	end
end

OnlineRoomSceneNew.showTipsDlg = function(self,msg,mode_type)
    if not self.m_show_tip_dialog then
        self.m_show_tip_dialog = new(ChioceDialog);
    end
    self.m_show_tip_dialog:setMode(mode_type);
    self.m_show_tip_dialog:setMessage(msg);
    self.m_show_tip_dialog:show();
end

OnlineRoomSceneNew.chessMove = function(self,data)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_move,data);
 end

--更新观战人数
OnlineRoomSceneNew.refreshWatcher = function(self)
	if RoomProxy.getInstance():getCurRoomType() ~= RoomConfig.ROOM_TYPE_PRIVATE_ROOM then
        self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_watchlist);        
	end
end

OnlineRoomSceneNew.handicapEvent = function(self,data)
	print_string("Room.handicapEvent");
	self:clearDialog();
	if data.red_uid == self.m_downUser:getUid() then    --由我让子
		if not self.m_handicap_dialog then
			self.m_handicap_dialog = new(HandicapDialog,self);
		end
		self.m_handicap_dialog:setData(data);
		self.m_handicap_dialog:show();
        ChessToastManager.getInstance():showSingle("加注结束,您先下棋")
	elseif data.red_uid == self.m_upUser:getUid() then  --等待对手让子
        local message = "等待对方让子"
        local phrases = {
            "快点吧，我等得花儿都要谢了！",
            "不用让了，谢谢！",
            "让一让，比一比！",
            "让不让，都可以！",
            "车马炮，随意！",
        }
		self:showLoadingDialog2(message,data.timeout,phrases);
        ChessToastManager.getInstance():showSingle("加注结束,对手先下棋")
	elseif data.red_uid == 0 then
     
    end
end

OnlineRoomSceneNew.sendHandicapMsg = function(self,info)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.server_msg_handicap, info);
end;

OnlineRoomSceneNew.show_reward_dlg = function(self,msg)
	if not self.m_online_box_dialog then
		self.m_online_box_dialog = new(OnlineBoxRewardDialog,msg);
	end
	self.m_online_box_dialog:show(msg);
end

OnlineRoomSceneNew.startTime = function(self)
	self:stopTime();
	self.m_timeAnim = new(AnimInt,kAnimLoop,0,1,1000,-1);
	self.m_timeAnim:setDebugName("Room.startTime.m_timeAnim");
	self.m_timeAnim:setEvent(self,self.timeRun);
end

OnlineRoomSceneNew.stopTime = function(self)
	if self.m_timeAnim then
		delete(self.m_timeAnim);
		self.m_timeAnim = nil;
	end
end

OnlineRoomSceneNew.timeRun = function(self)
	local t = os.date("*t");

	local time = string.format("%02d:%02d",t.hour,t.min);
    self.m_room_time_text2:setText(time)
	if t.sec%2 == 1 then
		time = string.format("%02d %02d",t.hour,t.min);
	end

	self.m_room_time_text:setText(time);
end

--服务器回应走棋
OnlineRoomSceneNew.resPonseMove = function(self,data)
	print_string("对手走棋");
	self.m_board:severMove(data);
end

OnlineRoomSceneNew.resPonseUnLegalMove = function(self,code)
	--[[//错误码 -1 走法不合规则 -2 相同方不可互吃 -3 找不到当前棋桌  -4 对手为空 -5 对方尚未走棋，请等待
        //  -6 客户端状态与服务端状态不一致，需要同步   -8 UID 不合法，找不到用户 -10 自己已经不在当前棋桌
        -9 此走法会导致自己被将军 -11 红方长捉黑方  -12 黑方长捉红方

        //0 成功   1红方胜利  2黑方胜利  9将军]]

	local message = nil;
	local obj = nil;
	local func = nil;
	local mode = nil;
	if code == -6 then
		message = "网络不佳，重新获取数据...";
		mode = ChioceDialog.MODE_OK;
		obj = self;
		func = obj.synchroRequest;
	elseif code == -9 then
		message = "走法会导致自己被将军,请重新走棋!" 
		mode = ChioceDialog.MODE_OK;
		obj = self.m_board;
		func = obj.undoMove;
	elseif code == -11 or code == -12 then
		message = "走法长捉长将，请重新走棋！" 
		mode = ChioceDialog.MODE_OK;
		obj = self.m_board;
		func = obj.undoMove;
	else
		message = "走法不合规则，请重新走棋！" 
		mode = ChioceDialog.MODE_OK;
		obj = self.m_board;
		func = obj.synchroRequest;    --当服务器提示走棋不合规则时，改成同步棋盘
	 	self:synchroRequest();
	end

	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end

	self.m_chioce_dialog:setMode(mode);
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:setPositiveListener(obj,func);
	self.m_chioce_dialog:show();
end

--房间统计事件
OnlineRoomSceneNew.onEventStat = function(self,event_id)
	
	local roomType = RoomProxy.getInstance():getCurRoomType();
    local typeName = RoomConfig.getTypeName(roomType);
    StatisticsManager.getInstance():onCountToUM(event_id,typeName);
end

OnlineRoomSceneNew.clearDialog = function(self)

	if self.m_match_dialog and self.m_match_dialog:isShowing() then
		self.m_match_dialog:dismiss();
	end
    if self.m_up_user_info_dialog and self.m_up_user_info_dialog:isShowing() then
    	self.m_up_user_info_dialog:dismiss();
	end
    if self.m_down_user_info_dialog and self.m_down_user_info_dialog:isShowing() then
    	self.m_down_user_info_dialog:dismiss();
	end
--	if self.m_account_dialog and self.m_account_dialog:isShowing() then
--		self.m_account_dialog:dismiss2();
--	end

	if self.m_chioce_dialog and self.m_chioce_dialog:isShowing() then
		self.m_chioce_dialog:dismiss();
	end

	if self.m_chat_dialog and self.m_chat_dialog:isShowing() then
		self.m_chat_dialog:dismiss();
	end

	if self.m_timeset_dialog and self.m_timeset_dialog:isShowing() then
		self.m_timeset_dialog:dismiss();
	end

	if self.m_setting_dialog and self.m_setting_dialog:isShowing() then
		self.m_setting_dialog:dismiss();
	end

	if self.m_board_menu_dialog and self.m_board_menu_dialog:isShowing() then
		self.m_board_menu_dialog:dismiss();
	end

	if self.m_handicap_dialog and self.m_handicap_dialog:isShowing() then
		self.m_handicap_dialog:dismiss();
	end
	if self.m_handicap_confirm_dialog and self.m_handicap_confirm_dialog:isShowing() then
		self.m_handicap_confirm_dialog:dismiss();
	end
    
	if self.m_forestall_dialog and self.m_forestall_dialog:isShowing() then
		self.m_forestall_dialog:dismiss();
	end

    if self.m_forestall_dialog_new and self.m_forestall_dialog_new:isShowing() then
		self.m_forestall_dialog_new:dismiss();
	end
    if self.m_forestall_dialog_320 and self.m_forestall_dialog_320:isShowing() then
		self.m_forestall_dialog_320:dismiss();
	end
    if self.m_forestall_wait_dialog_320 and self.m_forestall_wait_dialog_320:isShowing() then
		self.m_forestall_wait_dialog_320:dismiss();
	end
    
    if self.m_loading_dialog and self.m_loading_dialog:isShowing() then
		self.m_loading_dialog:dismiss();
	end

    if self.m_loading_dialog2 and self.m_loading_dialog2:isShowing() then
		self.m_loading_dialog2:dismiss();
	end

--    if self.mGameStartInfoDialog and self.mGameStartInfoDialog:isShowing() then
--		self.mGameStartInfoDialog:dismiss();
--	end

    if self.m_roomFriend and self.m_roomFriend:isShowing() then
        self.m_roomFriend:dismiss();
    end

    if self.m_roomFriendShow and self.m_roomFriendShow:isShowing() then
        self.m_roomFriendShow:dismiss();
    end

    if self.m_friendChoiceDialog and self.m_friendChoiceDialog:isShowing() then
        self.m_friendChoiceDialog:dismiss();
    end

    if self.m_roomSetTimeDialog and self.m_roomSetTimeDialog:isShowing() then
        self.m_roomSetTimeDialog:dismiss();
    end
    
    if self.mRoomWaitSetTimeDialog and self.mRoomWaitSetTimeDialog:isShowing() then
        self.mRoomWaitSetTimeDialog:dismiss();
    end

    if self.m_roomOtherSetTimeDialog and self.m_roomOtherSetTimeDialog:isShowing() then
        self.m_roomOtherSetTimeDialog:dismiss();
    end

    if self.mRoomWaitOtherSetTimeDialog and self.mRoomWaitOtherSetTimeDialog:isShowing() then
        self.mRoomWaitOtherSetTimeDialog:dismiss();
    end

    
    if self.m_up_user_tip_dialog and self.m_up_user_tip_dialog:isShowing() then
        delete(OnlineRoomSceneNew.schedule_repeat_time)
        OnlineRoomSceneNew.schedule_repeat_time = nil
        self.m_up_user_tip_dialog:dismiss();
    end;

    if self.m_thansize_dialog and self.m_thansize_dialog:isShowing() then 
        self.m_thansize_dialog:dismiss();
    end 

    self.mModule:dismissDialog();
end

OnlineRoomSceneNew.onAddBtnClick = function(self,data)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.client_add,data);
end


OnlineRoomSceneNew.collapseBuyCoin = function(self)
--	if not PayUtil.isGetMallGoods() then
--		PHPInterface.getMallShopInfo();
--	else
--		local MallGoods_Version = GameCacheData.MALL_GOODS_LIST;
--		if PhpInfo.getBid() then
--			MallGoods_Version = MallGoods_Version..PhpInfo.getBid();
--		end	

--		local goodsData = json.decode(GameCacheData.getInstance():getString(MallGoods_Version,""));
--		self:showBuyRewardGoodsDlg(goodsData.money);
--	end
end

--跳转到观战列表
function OnlineRoomSceneNew.gotoWatchList(self)
    if self.m_upUser then
        if self.m_upUser.m_flag == FLAG_RED then
            WatchListDialog.setRedData(self.m_upUser);
        elseif self.m_upUser.m_flag == FLAG_BLACK then
            WatchListDialog.setBlackData(self.m_upUser);
        else
            return ;
        end
    end

    if self.m_downUser then
        if self.m_downUser.m_flag == FLAG_RED then
            WatchListDialog.setRedData(self.m_downUser,true);
        elseif self.m_downUser.m_flag == FLAG_BLACK then
            WatchListDialog.setBlackData(self.m_downUser,true);
        else
            return ;
        end
    end

    if self.m_upUser and self.m_downUser and self.m_upUser.m_uid and self.m_downUser.m_uid then
        if not self.m_watchList_dialog then
            self.m_watchList_dialog = new(WatchListDialog,UserInfo.getInstance():getUid());--,uid);
        end
        self.m_watchList_dialog:show();
    end
end

--更新观战数量
OnlineRoomSceneNew.watchRoomNumber = function(self,info)
    if self.m_watchList_dialog then
        self.m_watchList_dialog:updataWatchNum(info);
    end
    if self.mModule and self.mModule.updataWatchNum then
--        self.mModule:updataWatchNum(info);
    end
    if self.m_room_watcher and info then
        local text = info.ob_num;
        local num = tonumber(info.ob_num);
        -- 根据界面宽度写出
        if num and num >= 1000 then
            text = '999+'
        end
        self.m_room_watcher:setText(text);
    end
end

OnlineRoomSceneNew.onGetWatchHistoryMsgs = function(self ,info)
    if self.mModule and self.mModule.updataWatchHistoryMsgs then
        self.mModule:updataWatchHistoryMsgs(info);
    end    
end;

function OnlineRoomSceneNew:getLoginStatus()
    return self.m_login_succ;
end

function OnlineRoomSceneNew.checkCanSurrender(self)
    if type(OnlineRoomController.s_switch_func) == "function" then
        return true
    end
    self.m_start_time = self.m_start_time or os.time();  -- 防止 self.m_start_time 为空情况
    local time = os.time();
    local roomtype = RoomProxy.getInstance():getCurRoomType();
	local roominfo = RoomProxy.getInstance():getCurRoomConfig();
    if roominfo and roominfo.give_up_time and time - self.m_start_time >= 0 and time - self.m_start_time < roominfo.give_up_time then
        ChessToastManager.getInstance():showSingle(string.format("%d 秒后才能投降",math.ceil(roominfo.give_up_time - time + self.m_start_time)));
        return false;
    end
    local step = self.m_board:getMoveStepNum();
    local minStep = roominfo.least_step
    if minStep > 0 and step > 0 and step < minStep+1 and roomtype == RoomConfig.ROOM_TYPE_ARENA_ROOM then
        ChessToastManager.getInstance():showSingle( string.format("双方还需走 %d 步才能投降",minStep+1-step));
        return
    end
    return true;
end
OnlineRoomSceneNew.onShareDialogHide = function(self)
    if self.m_account_dialog and self.m_account_dialog:isShowing() then
        self.m_account_dialog:shareDialogHide();
    end;
end

function OnlineRoomSceneNew:setIsWatchGiftAnim(flag)
    self.isWatchGiftAnim = flag
    RoomProxy.getInstance():setUserWatchMode(flag);
end

function OnlineRoomSceneNew.onThanSizeGameReturn(self,temleftMoney)
     --更新界面金币
    if temleftMoney == -1 then return end
    UserInfo.getInstance():setMoney(temleftMoney);
    self.m_down_view1:updataMoneyData(UserInfo.getInstance():getMoneyStr())
end 
--[Comment]
--发送礼物回调
function OnlineRoomSceneNew.onSendGiftReturn(self,data)
    --更新界面金币
    self.m_down_view1:updataMoneyData(UserInfo.getInstance():getMoneyStr())

    if self.m_down_user_info_dialog:isShowing() then
        self.m_down_user_info_dialog:dismiss()
    end
    if self.m_up_user_info_dialog:isShowing() then
        self.m_up_user_info_dialog:dismiss()
    end
    --如果是观战模式
    local num = 1     
    num = data.gift_num or 1

    GiftModuleAnimManager.stopAllPropAnim()
    local roomType = RoomProxy.getInstance():getCurRoomType();
    if roomType == RoomConfig.ROOM_TYPE_WATCH_ROOM or self.isWatchGiftAnim then
        local upUid = tonumber(self.m_upUser.m_uid);
        local downUid = tonumber(self.m_downUser.m_uid)
        local gift_target_id = tonumber(self.m_target_user.m_uid);
        local angle,user_icon = self:getAnimScale(gift_target_id,upUid,downUid,true)
        if self.mModule and user_icon then
            if data.gift_type == 17 then
                angle = angle - 270
            end
            GiftModuleAnimManager.playAnim(self,data.gift_type,self.m_watch_gift_start_view,user_icon,angle,nil,num)
            ToolKit.schedule_once(self,function() 
                self:playCharmAnim(user_icon,gift_target_id,upUid,downUid,data.gift_type,num);
            end,3000);
        end
        return
    end

    if self:isMoneyRoomWatchStatus() then
        local gift_start_view = self.m_left_gift_start_view
        local gift_end_view = self.m_up_gift_anim_view
        local angle = 0
        local halfMode = true
        angle,gift_end_view,gift_start_view = self:getMoneyRoomWatchRotate(tonumber(self.m_target_user.m_uid))
        if self.mModule then
--            if data.gift_type == 17 then
--                angle = angle - 270
--            end
            GiftModuleAnimManager.playAnim(self,data.gift_type,gift_start_view,gift_end_view,angle,halfMode,num)
        end
        return
    end

    --播放动画
    --由于资源不统一，鲜花动画单独做旋转调整
    local angle = 270
    if data.gift_type == 17 then
        angle = 0
    end
    GiftModuleAnimManager.playAnim(self,data.gift_type,self.m_down_gift_anim_view,self.m_top_gift_anim_view,angle,nil,num)
end

--[Comment]
--接收推送的礼物消息
function OnlineRoomSceneNew.onRecvGiftMsg(self,data)
    if not data then return end
    if not self.m_upUser or not self.m_downUser then return end
    local roomType = RoomProxy.getInstance():getCurRoomType();
    if self.mModule and self.mModule.receiveGiftMsg then
        self.mModule:receiveGiftMsg(data)
    end
    
    local num = data.gift_count or 1
--    local roomType = RoomProxy.getInstance():getCurRoomType();
    local gift_send_id = tonumber(data.send_id)
    local gift_target_id = tonumber(data.target_id);
    local upUid = tonumber(self.m_upUser.m_uid);
    local downUid = tonumber(self.m_downUser.m_uid)
    local gift_type = tonumber(data.gift_type)
    GiftLog.getInstance():saveUserGift(num,gift_target_id,gift_type)
    
    if self.m_watchList_dialog and self.m_watchList_dialog:isShowing() then
        self.m_watchList_dialog:updateUserGiftNum(gift_target_id,gift_type,num)
    end

    if UserInfo.getInstance():getUid() == tonumber(data.send_id) then 
        return
    end
    if gift_target_id == UserInfo.getInstance():getUid() then
        UserInfo.getInstance():updataGiftNum(gift_type,num)
    end

    if roomType == RoomConfig.ROOM_TYPE_WATCH_ROOM or self.isWatchGiftAnim then
        if gift_send_id == upUid or gift_send_id == downUid then
            return
        elseif gift_target_id ~= upUid and gift_target_id ~= downUid then
            return
        else
            --比赛房观战模式
            if self:isMoneyRoomWatchStatus() then
                local gift_start_view = self.m_left_gift_start_view
                local gift_end_view = self.m_up_gift_anim_view
                local angle = 0
                local halfMode = true
                angle,gift_end_view,gift_start_view = self:getMoneyRoomWatchRotate(gift_target_id)
                if self.mModule then
        --            if data.gift_type == 17 then
        --                angle = angle - 270
        --            end
                    GiftModuleAnimManager.playAnim(self,gift_type,gift_start_view,gift_end_view,angle,halfMode,num)
                end
                return
            end

            --播放礼物动画,观战模式
            --判断下棋者位置
            local angle,user_icon = self:getAnimScale(gift_target_id,upUid,downUid)
            local start_gift_view = self.m_watch_gift_start_view
            local halfMode = false
            local animList = GiftModuleAnimManager.getAnimList()
            if angle == 0 then
                start_gift_view = self.m_left_gift_start_view
                halfMode = true
            elseif angle == 180 then
                start_gift_view = self.m_right_gift_start_view
                halfMode = true
            else

            end
            if animList and animList == 0 and user_icon then
                if self.mModule then
                    GiftModuleAnimManager.playAnim(self,gift_type,start_gift_view,user_icon,angle,halfMode,num)
                    ToolKit.schedule_once(self,function() 
                        self:playCharmAnim(user_icon,gift_target_id,upUid,downUid,gift_type,num);
                    end,3000);
                end
            end
        end
    else
        if gift_send_id == upUid and gift_target_id == UserInfo.getInstance():getUid() then
            --播放礼物动画
            local animList = GiftModuleAnimManager.getAnimList()
            if animList and animList == 0 then
                local angle = 90
                if gift_type == 17 then
                    angle = 180
                end
                GiftModuleAnimManager.playAnim(self,gift_type,self.m_top_gift_anim_view,self.m_down_gift_anim_view,angle,nil,num)
            end
        end
    end
end

function OnlineRoomSceneNew.playCharmAnim(self,user_icon,gift_target_id,upUid,downUid,id,num)
    if not id then return end
    local charm = MallData.getInstance():getGiftReciveCharm(id);
    local charm_txt = nil;
    if charm == 0 then
        return;
    elseif charm > 0 then
        charm_txt = new(Text,string.format("魅力:+%d",charm * num),150,50,kAlignCenter,nil,32,40,255,45);
    elseif charm < 0 then
        charm_txt = new(Text,string.format("魅力:%d",charm * num),150,50,kAlignCenter,nil,32,255,40,40);
    end;
    charm_txt:setAlign(kAlignBottom);
    charm_txt:setLevel(1);
    local w, h = user_icon:getSize();
    h = h * System.getLayoutScale();
    local tranStartY,tranEndY,tranStartY1,tranEndY1;
    if charm>0 then 
        tranStartY = 10;
        tranEndY = -h/2;
        tranStartY1 = 0;
        tranEndY1 =  -h/4;
    elseif charm<0 then 
        tranStartY = -h/2;
        tranEndY = 10;
        tranStartY1 = 0;
        tranEndY1 = h/4;
    end 
    local anim = charm_txt:addPropTranslateWithEasing(10, kAnimNormal, 450, -1, function (...) return 0 end, "easeOutExpo", 0, 0, tranStartY, tranEndY)
    if anim then
        anim:setEvent(self, function()
            ToolKit.schedule_once(self,function() 
                local anim2 = charm_txt:addPropTranslateWithEasing(11, kAnimNormal, 400, -1, function (...) return 0 end, "easeOutCubic", 0, 0, tranStartY1, tranEndY1)
                local anim3 = charm_txt:addPropTransparency(12,kAnimNormal,400,0,1,0);   
                if anim3 then
                    anim:setEvent(self, function() 
                        delete(charm_txt)
                        charm_txt = nil;
                    end);
                end;             
            end,300);
        end);
    end;
    local target_view = user_icon;
    if gift_target_id == upUid then
        charm_txt:setPos(130,nil);
    elseif gift_target_id == downUid then
        charm_txt:setPos(-130,nil);
    end;
    if not target_view then return end;
    target_view:addChild(charm_txt);
end

--[Comment]
--获得动画旋转角度
function OnlineRoomSceneNew.getAnimScale(self,id,upUid,downUid,isMySelf)
    if not id or not self.mModule then return end
    local scale = 0
    local x,y = 0,0
    local userIcon = nil
    if id == upUid then
        userIcon = self.m_up_gift_anim_view
    elseif id == downUid then
        userIcon = self.m_down_gift_anim_view
    end
    x,y = userIcon:getAbsolutePos()
    if isMySelf then  
        if x < System.getScreenWidth()/2    then
            scale = 280
        else
            scale = 310
        end
    else
        if x < System.getScreenWidth()/2    then
            scale = 0
        else
            scale = 180
        end
    end

    return scale,userIcon
end

--[Comment]
--判断是否是是比赛房模式
function OnlineRoomSceneNew.isMoneyRoomWatchStatus(self)
    if not self.mModule then return end
    local roomType = RoomProxy.getInstance():getCurRoomType();
    if roomType == RoomConfig.ROOM_TYPE_MONEY_MATCH_ROOM then
        --比赛观战房间
        local status = self.mModule:getPlayerStatus()
        if status == MoneyMatchModule.s_playerStatus.watch then
            return true
        end
    end
    return false
end

--[Comment]
--比赛房间旋转角度
function OnlineRoomSceneNew.getMoneyRoomWatchRotate(self,target_id)
    local upUid = tonumber(self.m_upUser.m_uid);
    local downUid = tonumber(self.m_downUser.m_uid)
    local gift_target_id = target_id
    local rotate = 0
    local userIcon = self.m_up_gift_anim_view
    local target_view = self.m_left_gift_start_view
    if gift_target_id == upUid then
        rotate = 0
        userIcon = self.m_up_gift_anim_view
        target_view = self.m_left_gift_start_view
    end
    if gift_target_id == downUid then
        rotate = 180
        userIcon = self.m_down_gift_anim_view
        target_view = self.m_down_right_gift_start_view
    end
    return rotate,userIcon,target_view
end

--[Comment]
-- 分享复盘
function OnlineRoomSceneNew:shareFuPan()
    if not self.m_mvData then 
        ChessToastManager.getInstance():showSingle("复盘数据不存在")
        return 
    end
    self:requestCtrlCmd(OnlineRoomController.s_cmds.save_chess_and_share,false);
end

function OnlineRoomSceneNew:rotateChessBoard(ret)
    if self.m_board then
--        self.m_board:ratateChess(ret)
        if ret then
            if self.m_board:checkAddProp(20) then
                self.m_board:addPropRotateSolid(20,180,kCenterDrawing)
            end
        else
            if not self.m_board:checkAddProp(20) then
                self.m_board:removeProp(20)
            end
        end
        self.m_board:ratateChess(ret)
        self.m_board:ratateAnim(ret)
    end
end

function OnlineRoomSceneNew:switchSide()
    self.rotateBoard = not self.rotateBoard
    if self.mModule.switchSide then
        self.mModule:switchSide()
    end
    self:rotateChessBoard(self.rotateBoard)
end

function OnlineRoomSceneNew:showChestBtnTipView()
    if NoviceBootProxy.getInstance():isFirstShow(NoviceBootProxy.s_constant.ONLINE_TREASURE_BOX) then
        local guideTip = NoviceBootProxy.getInstance():getGuideTipView(NoviceBootProxy.s_constant.ONLINE_TREASURE_BOX)
        guideTip:setAlign(kAlignCenter)
        local w,h = self.m_chest_btn:getSize()
        guideTip:setTipSize(w+10,h+10)
        guideTip:startAnim()
--        guideTip:setTopTipText("#c4bff4b点击这里#n,去回顾下精彩对局吧!",-80,110,250,50,80)
        self.m_chest_btn:addChild(guideTip)
        NoviceBootProxy.getInstance():setGuideTipViewShowTime(NoviceBootProxy.s_constant.ONLINE_TREASURE_BOX)
    end
end


----------------------------------- config ------------------------------
OnlineRoomSceneNew.s_controlConfig = 
{
};

OnlineRoomSceneNew.s_controlFuncMap =
{
};


OnlineRoomSceneNew.s_cmdConfig =
{
    [OnlineRoomSceneNew.s_cmds.exit_room]              = OnlineRoomSceneNew.onExitRoom;
    [OnlineRoomSceneNew.s_cmds.client_user_login_succ] = OnlineRoomSceneNew.onClientUserLoginSucc;
    [OnlineRoomSceneNew.s_cmds.client_user_login_error] = OnlineRoomSceneNew.onClientUserLoginError;
    [OnlineRoomSceneNew.s_cmds.client_user_other_error] = OnlineRoomSceneNew.onClientUserOtherError;
    [OnlineRoomSceneNew.s_cmds.client_opp_user_login]  = OnlineRoomSceneNew.onClientOppUserLogin;
    [OnlineRoomSceneNew.s_cmds.server_msg_ready]       = OnlineRoomSceneNew.onServerMsgReady;
    [OnlineRoomSceneNew.s_cmds.server_msg_timecount_start] = OnlineRoomSceneNew.onServerMsgTimecountStart;
    [OnlineRoomSceneNew.s_cmds.server_msg_reconnect]   = OnlineRoomSceneNew.onServerMsgReconnect;
    [OnlineRoomSceneNew.s_cmds.server_msg_user_leave]  = OnlineRoomSceneNew.onServerMsgUserLeave;
    [OnlineRoomSceneNew.s_cmds.server_msg_forestall]   = OnlineRoomSceneNew.onServerMsgForestall;
    [OnlineRoomSceneNew.s_cmds.server_msg_forestall_new]   = OnlineRoomSceneNew.onServerMsgForestallNew;
    [OnlineRoomSceneNew.s_cmds.server_msg_forestall_320]   = OnlineRoomSceneNew.onServerMsgForestall320;
    [OnlineRoomSceneNew.s_cmds.server_msg_handicap]    = OnlineRoomSceneNew.onServerMsgHandicap;
    [OnlineRoomSceneNew.s_cmds.server_msg_handicap_result]  = OnlineRoomSceneNew.onServerMsgHandicapResult;
    [OnlineRoomSceneNew.s_cmds.server_msg_handicap_confirm] = OnlineRoomSceneNew.onServerMsgHandicapConfirm;
    [OnlineRoomSceneNew.s_cmds.server_msg_game_start_info] = OnlineRoomSceneNew.onServerMsgGameStartInfo;
    
    [OnlineRoomSceneNew.s_cmds.server_msg_logout_succ] = OnlineRoomSceneNew.onServerMsgLogoutSucc;

    [OnlineRoomSceneNew.s_cmds.setTime] = OnlineRoomSceneNew.onSetTime;
    [OnlineRoomSceneNew.s_cmds.waitSetTime] = OnlineRoomSceneNew.onWaitSetTime;
    [OnlineRoomSceneNew.s_cmds.setTimeShow] = OnlineRoomSceneNew.onSetTimeShow;
    [OnlineRoomSceneNew.s_cmds.waitSetTimeShow] = OnlineRoomSceneNew.onWaitSetTimeShow;
    
    [OnlineRoomSceneNew.s_cmds.client_msg_syndata]     = OnlineRoomSceneNew.onClientMsgSyndata;
    [OnlineRoomSceneNew.s_cmds.client_get_openbox_time]= OnlineRoomSceneNew.onClientGetOpenboxTime;
    [OnlineRoomSceneNew.s_cmds.client_msg_chat]        = OnlineRoomSceneNew.onClientMsgChat;
    [OnlineRoomSceneNew.s_cmds.client_msg_handicap]    = OnlineRoomSceneNew.onClientMsgHandicap;
    [OnlineRoomSceneNew.s_cmds.server_msg_gamestart]   = OnlineRoomSceneNew.onServerMsgGamestart;
    [OnlineRoomSceneNew.s_cmds.server_msg_gameclose]   = OnlineRoomSceneNew.onServerMsgGameclose;
    [OnlineRoomSceneNew.s_cmds.server_msg_warning]     = OnlineRoomSceneNew.onServerMsgWarning;
    [OnlineRoomSceneNew.s_cmds.server_msg_tips]        = OnlineRoomSceneNew.onServerMsgTips;
    [OnlineRoomSceneNew.s_cmds.client_msg_move]        = OnlineRoomSceneNew.onServerMsgMove;

    [OnlineRoomSceneNew.s_cmds.client_msg_draw1]       = OnlineRoomSceneNew.onClientMsgDraw1;
    [OnlineRoomSceneNew.s_cmds.client_msg_draw2]       = OnlineRoomSceneNew.onClientMsgDraw2;
    [OnlineRoomSceneNew.s_cmds.server_msg_draw]        = OnlineRoomSceneNew.onServerMsgDraw;
    [OnlineRoomSceneNew.s_cmds.client_msg_undomove]    = OnlineRoomSceneNew.onClientMsgUndomove;
    [OnlineRoomSceneNew.s_cmds.client_msg_surrender2]  = OnlineRoomSceneNew.onClientMsgSurrender2;
    [OnlineRoomSceneNew.s_cmds.server_msg_surrender]   = OnlineRoomSceneNew.onServerMsgSurrender;
    
    [OnlineRoomSceneNew.s_cmds.resume_from_homekey]    = OnlineRoomSceneNew.onResumeFromHomekey;
    [OnlineRoomSceneNew.s_cmds.show_net_state]         = OnlineRoomSceneNew.onShowNetState;
    [OnlineRoomSceneNew.s_cmds.set_time_info]          = OnlineRoomSceneNew.onSetTimeInfo;

    [OnlineRoomSceneNew.s_cmds.forceLeave]             = OnlineRoomSceneNew.onForceLeave;           --强制离场
    [OnlineRoomSceneNew.s_cmds.updateUserInfoDialog]   = OnlineRoomSceneNew.onUpdateUserInfoDialog;--关注/取消关注

    [OnlineRoomSceneNew.s_cmds.watchNumber]            = OnlineRoomSceneNew.watchRoomNumber;
    [OnlineRoomSceneNew.s_cmds.get_watch_history_msg]  = OnlineRoomSceneNew.onGetWatchHistoryMsgs;

    [OnlineRoomSceneNew.s_cmds.callTelphoneResponse]   = OnlineRoomSceneNew.callTelphoneResponse; --已经去掉
    [OnlineRoomSceneNew.s_cmds.callTelphoneBack]       = OnlineRoomSceneNew.callTelphoneBack;  --已经去掉
    [OnlineRoomSceneNew.s_cmds.setDisconnect]          = OnlineRoomSceneNew.setDisconnect;  --已经去掉
    [OnlineRoomSceneNew.s_cmds.save_mychess]           = OnlineRoomSceneNew.onSaveMyChess;  
    [OnlineRoomSceneNew.s_cmds.save_chess_and_share]   = OnlineRoomSceneNew.onSaveMyChessAndShare;  
    
    [OnlineRoomSceneNew.s_cmds.forbid_user_msg]        = OnlineRoomSceneNew.onForbidUpUserMsg; 

    [OnlineRoomSceneNew.s_cmds.shareDialogHide]        = OnlineRoomSceneNew.onShareDialogHide; 
    [OnlineRoomSceneNew.s_cmds.send_gift_return]       = OnlineRoomSceneNew.onSendGiftReturn; 

    [OnlineRoomSceneNew.s_cmds.ob_gift_msg]            = OnlineRoomSceneNew.onRecvGiftMsg; 
    [OnlineRoomSceneNew.s_cmds.refresh_userinfo]       = OnlineRoomSceneNew.updateUserInfoView; 
    [OnlineRoomSceneNew.s_cmds.saveChessData]          = OnlineRoomSceneNew.saveChessData; 
    [OnlineRoomSceneNew.s_cmds.take_picture_complete]  = OnlineRoomSceneNew.takePictureComplete;
    [OnlineRoomSceneNew.s_cmds.setTimeResponse]        = OnlineRoomSceneNew.setTimeResponse;
    [OnlineRoomSceneNew.s_cmds.thanSizeGameReturn]     = OnlineRoomSceneNew.onThanSizeGameReturn;
}
