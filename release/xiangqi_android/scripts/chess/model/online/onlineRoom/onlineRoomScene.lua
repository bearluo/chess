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
require("dialog/loading_dialog")
require("dialog/online_box_reward_dialog");
require("dialog/handicap_dialog")
require("dialog/board_menu_dialog");
require("dialog/setting_dialog");
require("dialog/custom_input_pwd_dialog");
require("dialog/select_player_dialog");
require("dialog/room_friend_setTime_dialog"); 
require("dialog/room_friend_setTime_show_dialog");
OnlineRoomScene = class(RoomScene);

OnlineRoomScene.s_controls = 
{
    
}

OnlineRoomScene.s_cmds = 
{
    updateWatchRoom         = 1;
    updateWatchRoomUser     = 2; 
    watcherCountChange      = 3;
    watchRoomMove           = 4;
    watchRoomUserLeave      = 5;
    watchRoomReady          = 6;
    watchRoomStart          = 7;
    watchRoomClose          = 8;
    watcherChatMsg          = 9;
    watchRoomPlayerChatMsg  = 10;
    watchRoomDraw           = 11;
    watchRoomSurrender      = 12;
    watchRoomUndo           = 13;
    watchRoomWaring         = 14;
    exit_room               = 15;
    match_room_success      = 16;
    match_room_fail         = 17;
    client_user_comein      = 46;--后期删除
    client_user_login_succ  = 18;
    client_msg_start        = 19;
    client_msg_forestall    = 20;
    client_msg_relogin      = 21;
    client_msg_syndata      = 22;
    client_get_openbox_time = 23;
    client_msg_leave        = 24;
    client_msg_chat         = 25;
    client_msg_handicap     = 26;
    client_msg_login        = 27;
    server_msg_gamestart    = 28;
    server_msg_gameclose    = 29;
    server_msg_warning      = 30;
    client_msg_move         = 31;

    client_msg_draw2        = 32;
    server_msg_draw         = 33;

    client_msg_undomove     = 34;
    client_msg_surrender2   = 35;
    server_msg_surrender    = 36;

    show_input_pwd_dialog   = 37;
    enter_customroom_fail   = 38;
    custom_msg_login_room   = 39;
    resume_from_homekey     = 40;
    show_net_state          = 41;
    set_time_info           = 42;
    handle_conn_fail        = 43;
    on_room_touch           = 44;
    update_prop_info        = 45;



    client_opp_user_login   = 47;
    server_msg_ready        = 48;
    server_msg_timecount_start = 49;
    server_msg_reconnect    = 50;
    server_msg_user_leave   = 51;
    server_msg_forestall    = 52;
    server_msg_logout_succ  = 53;
    server_msg_handicap     = 54;
    server_msg_handicap_result = 55;

    updataUserIcon = 56;
    watchRoomAllready       = 57;
    watchRoomError          = 58;
    client_msg_draw1        = 59;
    client_user_login_error = 60;
    client_user_other_error = 61;

    createFriendRoom        = 62;
    setTime                 = 63;
    setTimeShow             = 64;
    reSetGame               = 65;

    matchSuccess            = 66;
    watchRoomUserEnter      = 67;
    watchRoomNumber         = 68;
    watchRoomMsg            = 69;
    watchRoomUpdateTable    = 70;

    forceLeave              = 71;
    invitFail               = 72;
    updateUserInfoDialog    = 73;
    server_msg_forestall_new = 74;
    invitNotify             = 75;
    deleteInvitAnim         = 76;
}

OnlineRoomScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = OnlineRoomScene.s_controls;
    self:initValues();
    self:initView();
    self:startTime();
end 
OnlineRoomScene.resume = function(self)
    RoomScene.resume(self);
    self:initGame();
end;


OnlineRoomScene.pause = function(self)
	RoomScene.pause(self);
	AnimKill.deleteAll();
    AnimTimeout.deleteAll();
    AnimJam.deleteAll();
end 


OnlineRoomScene.dtor = function(self)
    HeadSmogAnim.deleteAll();
    ChatMessageAnim.deleteAll();
    ShowMessageAnim.deleteAll();
    ForestallAnim.deleteAll();
    RoomHomeScroll.deleteAll();
    BroadcastMessageAnim.deleteAll();
    AnimKill.deleteAll();
    AnimTimeout.deleteAll();
    AnimJam.deleteAll();
    delete(self.m_watch_chat_log_dialog);
    delete(self.m_up_user_info_dialog);
    delete(self.m_down_user_info_dialog);
    delete(self.m_board_menu_dialog);
    delete(self.m_timeset_dialog);
    delete(self.m_chat_dialog);
    delete(self.m_match_dialog);
    delete(self.m_chioce_dialog);
    delete(self.m_setting_dialog);
    delete(self.m_timeoutAnim);
    delete(self.m_account_dialog);
    delete(self.m_forestall_dialog);
    delete(self.m_forestall_dialog_new);
    delete(self.m_loading_dialog);
    delete(self.m_inputPwdDialog);
    delete(self.m_handicap_dialog);
    delete(self.m_online_box_dialog);
    delete(self.m_room_select_player_dialog);
    delete(self.m_timeAnim);
    delete(self.m_roomFriend);
    delete(self.m_roomFriendShow);
    delete(self.m_friendChoiceDialog);
    OnlineConfig.deleteTimer(self); 
    if self.m_ready_time_anim then
        delete(self.m_ready_time_anim);
        self.m_ready_time_anim = nil;
    end
    UserInfo.getInstance():setRoomLevel(0);
    self:onDeleteInvitAnim();
    OnlineConfig.deleteOpenBoxTimer();
end 



--------------------------------function--------------------------------
OnlineRoomScene.initValues = function(self)

    self.m_anim_img = nil;
	
	self.m_upUser = nil;
	self.m_downUser = nil;
	self.m_tid = 0;
	self.m_t_statuss = 0;
	self.m_gametype = 0;  -- 棋局类型  1 普通场	2 十分钟场 3 二十分钟场

	self.m_connectCount=0;

	self.m_timeout1 = 0;
	self.m_timeout2 = 0;
	self.m_timeout3 = 0;


	self.m_root_view = nil;
	self.m_up_view = nil;   --上部玩家及一些信息模块
	self.m_board_view = nil;   --棋盘模块
	self.m_down_view = nil;     --下部玩家信息模块

	self.m_up_user_icon_bg = nil;
	self.m_up_timeframe = nil;
	self.m_up_timeout1_img = nil;
	self.m_up_timeout1_text = nil;
	self.m_up_timeout2_img = nil;
	self.m_up_timeout2_text = nil;
	self.m_up_chessframe = nil;
	self.m_up_chess_pc = {};  --被吃棋子
	self.m_up_chess_num = {}; --被吃棋子滴数量
	self.m_up_turn = nil


	self.m_down_user_icon_bg = nil;
	self.m_down_timeframe = nil;
	self.m_down_timeout1_img = nil;
	self.m_down_timeout1_text = nil;
	self.m_down_timeout2_img = nil;
	self.m_down_timeout2_text = nil;
	self.m_down_chessframe = nil;
	self.m_down_chess_pc = {};  --被吃棋子
	self.m_down_chess_num = {}; --被吃棋子滴数量
	self.m_down_turn = nil;
	-- self.m_down_chat_bg = nil;
	-- self.m_down_chat_content = nil;


	self.m_board = nil;    --棋盘类
	self.m_up_user_icon = nil; --上部玩家头像
	self.m_down_user_icon = nil;  --下部玩家头像

	self.m_up_user_ready_img = nil;  --上准备图片
	self.m_down_user_ready_img = nil; -- 下准备图片
	self.m_down_user_start_btn = nil;  --下开始按钮

	---下部菜单模块
	self.m_room_menu_chat_btn = nil

	---弹出框
	self.m_account_dialog = nil;

	self.m_net_state_view = nil;
	self.m_net_state_view_bg = nil;
	self.ForceUndoMove = 0;
	self.Undomovenum = 0;--此盘棋局被强制悔棋的次数
	self.m_stat_place = "联网房间"; --统计使用

	self.OpponentID = 0;
	self.GetCoin = 0;
	self.undoTb  = nil;
	self.isNormalUndo = false;
	self.isNormalUndoTips = false;
	self.isUndoAble = false;
	self.isUseLeftUndo = false;
	self.m_leftUndo = 0;

	self.usedUndoBccoin = 0;

    self.m_upPlayer_level = 2;--默认对手难度，1：稍逊一筹，2：不分伯仲，3：棋高一着

end;
OnlineRoomScene.initView = function(self)
    
    self.m_root_view = self.m_root;
    self.m_room_time_bg = self.m_root_view:getChildByName("room_time_bg");
	self.m_room_time_text = self.m_room_time_bg:getChildByName("room_time");


    self.m_room_watcher_bg_btn = self.m_root_view:getChildByName("room_watcher_bg_btn");
    self.m_room_watcher_bg_btn:setOnClick(self,self.gotoWatchList);
    self.m_room_watcher = self.m_room_watcher_bg_btn:getChildByName("room_watcher_count_text");
	-- self.m_room_watcher_count_tips = self.m_root_view:getChildByName("room_watcher_count_tips");

	self.m_roomid_text = self.m_root_view:getChildByName("roomid_text");
	self.m_roomid_label_text = self.m_root_view:getChildByName("roomid_label_text");



	--棋盘部分
	self.m_board_view = self.m_root_view:getChildByName("board");
	local boardBg = self.m_board_view:getChildByName("board_bg");
	local w,h = boardBg:getSize();
	self.m_board = new(Board,w,h,self);
	self.m_board_view:addChild(self.m_board);

	local watch_chat_log = self.m_board_view:getChildByName("watch_chat_log");
	self.m_watch_chat_log_dialog = new(WatchChatDialog,self,watch_chat_log);

	--上部玩家信息模块
	self.m_up_view = self.m_root_view:getChildByName("up_model");   --上部玩家及一些信息模块
	self.m_up_user_icon_bg = self.m_up_view:getChildByName("up_user_icon_bg");
	self.m_up_user_icon = self.m_up_user_icon_bg:getChildByName("up_user_icon");
    self.m_up_user_level_icon = self.m_up_user_icon_bg:getChildByName("up_user_level_icon");
	self.m_up_timeframe = self.m_up_view:getChildByName("up_timeframe_bg");
	self.m_up_timeout1_img = self.m_up_timeframe:getChildByName("up_timeout1_img");
	self.m_up_timeout1_text = self.m_up_timeframe:getChildByName("up_timeout1_text");
	self.m_up_timeout2_img = self.m_up_timeframe:getChildByName("up_timeout2_img");
	self.m_up_timeout2_text = self.m_up_timeframe:getChildByName("up_timeout2_text");


	self.m_up_name = self.m_up_view:getChildByName("up_user_name");
	self.m_up_title = self.m_up_view:getChildByName("up_user_title");


	self.m_up_turn = self.m_up_view:getChildByName("up_turn");
	self.m_up_user_icon:setEventTouch(self,self.showUpUserInfo);



	--上部玩家信息弹出框
	self.m_up_user_info_dialog_view = self.m_root_view:getChildByName("up_user_info_view");
	self.m_up_user_info_dialog = new(UserInfoDialog,self.m_up_user_info_dialog_view,"up_user_info_");
    self.m_up_user_info_dialog:setAddFunc(self,self.onAddBtnClick);
	self.m_up_chessframe = self.m_up_user_info_dialog_view:getChildByName("up_user_info_dialog"):getChildByName("up_chessframe_bg");
	for i = 1 ,7 do
		self.m_up_chess_pc[i] = self.m_up_chessframe:getChildByName("up_chess" .. i .. "_pc" );
		self.m_up_chess_num[i] = self.m_up_chess_pc[i]:getChildByName("up_chess" .. i .. "_num");
		self.m_up_chess_pc[i]:setVisible(false);
		self.m_up_chess_num[i]:setVisible(false);
	end

	self.m_down_user_info_dialog_view = self.m_root_view:getChildByName("down_user_info_view");
	self.m_down_user_info_dialog = new(UserInfoDialog,self.m_down_user_info_dialog_view,"down_user_info_");
    self.m_down_user_info_dialog:setAddFunc(self,self.onAddBtnClick);
	self.m_down_chessframe = self.m_down_user_info_dialog_view:getChildByName("down_user_info_dialog"):getChildByName("down_chessframe_bg");
	for i = 1 ,7 do
		self.m_down_chess_pc[i] = self.m_down_chessframe:getChildByName("down_chess" .. i .. "_pc" );
		self.m_down_chess_num[i] = self.m_down_chess_pc[i]:getChildByName("down_chess" .. i .. "_num");
		self.m_down_chess_pc[i]:setVisible(false);
		self.m_down_chess_num[i]:setVisible(false);
	end

	--下部信息
	self.m_down_view = self.m_root_view:getChildByName("down_model");   --上部玩家及一些信息模块
	self.m_down_user_icon_bg = self.m_down_view:getChildByName("down_user_icon_bg");
	self.m_down_user_icon = self.m_down_user_icon_bg:getChildByName("down_user_icon");
    self.m_down_user_level_icon = self.m_down_user_icon_bg:getChildByName("down_user_level_icon");
	self.m_down_timeframe = self.m_down_view:getChildByName("down_timeframe_bg");
	self.m_down_timeout1_img = self.m_down_timeframe:getChildByName("down_timeout1_img");
	self.m_down_timeout1_text = self.m_down_timeframe:getChildByName("down_timeout1_text");
	self.m_down_timeout2_img = self.m_down_timeframe:getChildByName("down_timeout2_img");
	self.m_down_timeout2_text = self.m_down_timeframe:getChildByName("down_timeout2_text");



	self.m_down_name = self.m_down_view:getChildByName("down_user_name");
	self.m_down_title = self.m_down_view:getChildByName("down_user_title");


	self.m_down_turn = self.m_down_view:getChildByName("down_turn");
	self.m_down_user_icon:setEventTouch(self,self.showDownUserInfo);

	-- self.m_down_chat_bg = self.m_down_view:getChildByName("down_chat_bg");
	-- self.m_down_chat_content = self.m_down_chat_bg:getChildByName("down_chat_text");
	-- self.m_down_chat_bg:setVisible(false);

    self.m_toast_bg = self.m_root_view:getChildByName("toast_bg");
    self.m_toast_text = self.m_toast_bg:getChildByName("toast_text");

	--准备开始模块
	self.m_up_user_ready_img = self.m_board_view:getChildByName("board_bg"):getChildByName("up_user_ready_img");  --上准备图片
	self.m_down_user_ready_img = self.m_board_view:getChildByName("board_bg"):getChildByName("down_user_ready_img"); -- 下准备图片
	self.m_down_user_start_btn = self.m_board_view:getChildByName("down_user_start_btn"); --下开始按钮
	self.m_down_user_start_btn:setLevel(BUTTON_VISIBLE_LEVEL);
	self.m_down_user_start_btn:setOnClick(self,self.start_action);

	self.m_room_menu_view = self.m_root_view:getChildByName("room_menu");


	self.m_chest_btn = self.m_room_menu_view:getChildByName("chest_btn");
	self.m_chat_btn = self.m_room_menu_view:getChildByName("chat_btn");
    self.m_chest_icon = self.m_room_menu_view:getChildByName("chest_btn"):getChildByName("chest_icon");
	self.m_menu_btn = self.m_room_menu_view:getChildByName("menu_btn");
    self.m_menu_image = self.m_menu_btn:getChildByName("menu_image");
    
	self.m_online_time_text = self.m_chest_btn:getChildByName("online_time_text");
    self.m_chest_btn:setEnable(false);
	
	self.m_chest_btn:setOnClick(self,self.chest_action);
	self.m_chat_btn:setOnClick(self,self.chat_action);
	self.m_menu_btn:setOnClick(self,self.menuToggle);


	self.m_room_menu_chat_btn = self.m_room_menu_view:getChildByName("room_menu_chat");
	self.m_room_menu_chat_btn:setOnClick(self,self.chat_action);

	self.m_room_menu_chat_text = self.m_room_menu_chat_btn:getChildByName("room_menu_chat_text");
    self.m_room_menu_chat_text:setTouchEvent(false);
	self.m_room_watch_chat_log_toggle = self.m_room_menu_view:getChildByName("room_watch_chat_btn");
	self.m_room_watch_chat_log_toggle:setOnClick(self,self.watchChatLogToggle);

	--dialog
    self.m_board_menu_dialog = new(BoardMenuDialog,self);

	self.m_timeset_dialog_view = self.m_root_view:getChildByName("time_set_dialog");
	self.m_timeset_dialog = new(TimeSetDialog,self);



	--初始化可见性 
	self.m_up_user_ready_img:setVisible(false);
	self.m_down_user_ready_img:setVisible(false);
	-- self.m_down_user_start_btn:setVisible(false);
	-- self.m_down_user_icon:setVisible(false);
	self.m_up_user_icon:setVisible(false);


	self.m_up_turn:setVisible(false);
	self.m_down_turn:setVisible(false);

	self:setTimeFrameVisible(false);

	self.m_chat_dialog = new(ChatDialog,self);

	self.m_watcher_count = 0;  --观战者人数

    self.m_sinal_icon_arr = {"drawable/net_sinal_state_level0.png","drawable/net_sinal_state_level1.png","drawable/net_sinal_state_level2.png","drawable/net_sinal_state_level3.png","drawable/net_sinal_state_level4.png","drawable/net_sinal_state_level_none.png"};
	self.m_net_state_view = self.m_down_view:getChildByName("net_state_view");
	self.m_net_state_view_bg = self.m_net_state_view:getChildByName("net_state_view_bg");

	self.m_multiple_img_bg =  self.m_up_view:getChildByName("multiple_img_bg");
	self.m_multiple_text =  self.m_multiple_img_bg:getChildByName("multiple_text");
	self.m_multiple_text:setText("1");

	self.m_net_state_view:setVisible(true);
	self.m_net_state_view_bg:setVisible(true);
    
    local roomtype = UserInfo.getInstance():getMoneyType() or 0;
    if roomtype == UserInfo.getInstance():getRoomConfigById(4).money then
        self.m_roominfo = UserInfo.getInstance():getRoomConfigById(4);--4为私人房
    else
	    self.m_roominfo = UserInfo.getInstance():getRoomConfigById(roomtype);
    end

    self.m_roomFriend = new(RoomFriendSetTime,UserInfo.getInstance():getRoomLevel());
    self.m_roomFriendShow = new(RoomFriendSetTimeShow,UserInfo.getInstance():getRoomLevel());

    self.m_room_select_player_dialog = new(SelectPlayerDialog,self);


--    self:registerSinalReceiver();
    self:showNetSinalIcon(true);
    self:getNetStateLevel();    
     
end;

OnlineRoomScene.gotoWatchList = function(self)
    require(MODEL_PATH.."watchlist/watchlistScene");
    if self.m_upUser then
        if self.m_upUser.m_flag == FLAG_RED then
            WatchlistScene.setRedData(self.m_upUser);
        elseif self.m_upUser.m_flag == FLAG_BLACK then
            WatchlistScene.setBlackData(self.m_upUser);
        end
    end

    if self.m_downUser then
        if self.m_downUser.m_flag == FLAG_RED then
            WatchlistScene.setRedData(self.m_downUser);
        elseif self.m_downUser.m_flag == FLAG_BLACK then
            WatchlistScene.setBlackData(self.m_downUser);
        end
    end

    StateMachine.getInstance():pushState(States.watchlist,StateMachine.STYPE_LEFT_IN);
end


OnlineRoomScene.initGame = function(self)

    local game_type = UserInfo.getInstance():getGameType();
	print_string("Room.load game_type = " .. game_type);
--	self:setGameType(game_type);
	if game_type == GAME_TYPE_WATCH then  --如果是观战

		self.m_chest_btn:setVisible(false);
		self.m_chat_btn:setVisible(false);
		self.m_menu_btn:setVisible(false);
		self.m_room_menu_chat_btn:setVisible(true);


		self.m_multiple_img_bg:setVisible(false);
		self.m_room_watcher_bg_btn:setVisible(true);

        self.m_net_state_view_bg:setVisible(false);
		self.m_down_name:setVisible(true);
		self.m_down_title:setVisible(false);

		self.m_up_name:setVisible(true);
		self.m_up_title:setVisible(false);

		self.m_room_watch_chat_log_toggle:setVisible(true);

		self.m_down_user_start_btn:setVisible(false);

		self:start_watch();

    elseif game_type == GAME_TYPE_CUSTOMROOM then
        if self.m_customRoomExit then
            self.m_customRoomExit = false;
            StateMachine.getInstance():popState(StateMachine.STYPE_REGHT_OUT);
            return;
        end
    	self.m_multiple_img_bg:setVisible(false);
        self.m_room_watcher_bg_btn:setVisible(false);
		self.m_down_name:setVisible(false);
		self.m_down_title:setVisible(false);

		self.m_up_name:setVisible(true);
		self.m_up_title:setVisible(false);

		self.m_room_watch_chat_log_toggle:setVisible(false);

        self.m_room_menu_chat_btn:setVisible(false);
        self.m_down_user_start_btn:setVisible(false);
		self:start_customroom();
        self.m_down_user_start_btn:setVisible(true);
        self:downComeIn(UserInfo.getInstance());
	else       
        self.m_chest_btn:setVisible(true);
		self.m_chat_btn:setVisible(true);
		self.m_menu_btn:setVisible(true);
		self.m_multiple_img_bg:setVisible(true);
        self.m_room_watcher_bg_btn:setVisible(false);
		self.m_down_name:setVisible(true);
		self.m_down_title:setVisible(false);

		self.m_up_name:setVisible(true);
		self.m_up_title:setVisible(false);
        if self.m_watch_chat_log_dialog then
            self.m_watch_chat_log_dialog:dismiss();
        end

		self.m_room_watch_chat_log_toggle:setVisible(false);

        self.m_room_menu_chat_btn:setVisible(false);
        self:downComeIn(UserInfo.getInstance());

        if game_type == GAME_TYPE_FRIEND then
            if not self.m_login_friend then
                self.m_login_friend = true;
                self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_login);
            end
            if UserInfo.getInstance():getRelogin() then
                self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_login); 
		    end
            self.m_down_user_start_btn:setVisible(true);
            if UserInfo.getInstance():getChallenger() == true then
                ChessToastManager.getInstance():show("点击开始按钮向对方发起挑战",2000);
            end
            if UserInfo.getInstance():getChallenger() == false then
                ChessToastManager.getInstance():show("对方正在设置棋局，请稍等");
            end
        else
            --1.9.0加入选择对手对话框
            self.m_room_select_player_dialog:show();
            self.m_down_user_start_btn:setVisible(false);

	        if UserInfo.getInstance():getRelogin() then
                self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_login); 
		    end
        end
	end    

end;

OnlineRoomScene.sendReadyMsg = function(self)
    local game_type = UserInfo.getInstance():getGameType();
    if game_type == GAME_TYPE_CUSTOMROOM then
        self.m_ready_status = true;
        self:requestCtrlCmd(OnlineRoomController.s_cmds.send_ready_msg);
    elseif not self.m_upuser_leave then
        self.m_ready_status = true;
        self:requestCtrlCmd(OnlineRoomController.s_cmds.send_ready_msg);
    else
        self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_offline);
        self:showSelectPlayerDialog();
    end;
end;

OnlineRoomScene.start_action = function(self)
	print_string("Room.start_action");
    self:onEventStat(ROOM_MODEL_START_BTN);
    if self.m_ready_time and self.m_ready_time > 0 then
        ChessToastManager.getInstance():show("请等待"..self.m_ready_time.."s再次准备挑战");
        return;
    end
    if UserInfo.getInstance():getChallenger() == false then
        if self.m_upUser == nil then
            self:onForceLeave("对方已经离开，请退出房间");
        end
    end

	local gold_type = UserInfo.getInstance():getMoneyType();
	local ctype = UserInfo.getInstance():canAccessRoom(gold_type);
	print_string("AccountDialog.canContinue .. ctype" .. ctype);
	if ctype == 0 then
		--破产
		self:collapse();
		return;
	end

	--在房间直接准备
    if self.m_down_user_start_btn then              --不知道为什么会被释放了，友盟BUG跟踪修复
	    self.m_down_user_start_btn:setVisible(false);
    end

    self.m_ready_status = true;
    self:requestCtrlCmd(OnlineRoomController.s_cmds.send_ready_msg);
	self.m_board:dismissChess();
    self.m_board_menu_dialog:dismiss();
    self.m_multiple_text:setText("1");

	if UserInfo.getInstance():getGameType() == GAME_TYPE_CUSTOMROOM then --自定议房间
		if UserInfo.getInstance():getStatus() > STATUS_PLAYER_LOGIN then  --网络游戏
            self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_start);
		else

	  		 -- self.m_room_watcher_count_tips:setVisible(false)
             self.m_room_watcher:setVisible(false);
			 self.m_roomid_label_text:setVisible(true);
			 self.m_roomid_text:setVisible(true);
	  		 self.m_roomid_text:setText(UserInfo.getInstance():getCustomRoomID());
			 
		end
	elseif UserInfo.getInstance():getGameType() == GAME_TYPE_COMPUTER then --单机
		self:console_game();
--	elseif UserInfo.getInstance():getStatus() > STATUS_PLAYER_LOGIN then  --网络游戏
--        self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_start);
	elseif UserInfo.getInstance():getGameType() == GAME_TYPE_FRIEND then --好友房
        if UserInfo.getInstance():getChallenger() then
            local post_data = {};
            post_data.uid = tonumber(UserInfo.getInstance():getUid());
            post_data.target_uid = tonumber(UserInfo.getInstance():getTargetUid());--1265;   --测试使用
            post_data.tid = UserInfo.getInstance():getTid();
            UserInfo.getInstance():setChallenger(nil);
            self:requestCtrlCmd(OnlineRoomController.s_cmds.invit_request,post_data);
            self:showMoneyRent();
        end
    else
        self:requestCtrlCmd(OnlineRoomController.s_cmds.send_ready_msg);
		
	end

end

OnlineRoomScene.matchRoom = function(self)
	
--	if not self.m_match_dialog then
--		self.m_match_dialog = new(MatchDialog);
--	end
	self:showMoneyRent();
	self.m_match_dialog:show(self,UserInfo.getInstance():getMatchTime());

--	--没有游戏类型   --快速匹配
--	if not UserInfo.getInstance():getGameType() or  UserInfo.getInstance():getGameType() <= GAME_TYPE_UNKNOW then
--		if UserInfo.getInstance():getTid() ~= 0 then     --有未完成棋局
--			UserInfo.getInstance():setGameType(GAME_TYPE_UNKNOW);
--            self:requestCtrlCmd(OnlineRoomController.s_cmds.hall_game_info); 
--		else
--           self:requestCtrlCmd(OnlineRoomController.s_cmds.hall_quick_start);
--		end
--	else   --进入相应的场 
    local data = {};
    local roomType = UserInfo.getInstance():getMoneyType();
    if 1 == roomType then
        data.roomType = UserInfo.getInstance():getRoomConfigById(1).level;
    elseif 2 == roomType then
        data.roomType = UserInfo.getInstance():getRoomConfigById(2).level;
    elseif 3 == roomType then
        data.roomType = UserInfo.getInstance():getRoomConfigById(3).level;
    else
        return ;
    end;
    data.playerLevel = self.m_upPlayer_level;
    self:requestCtrlCmd(OnlineRoomController.s_cmds.hall_game_info, data); 
--	end


end


OnlineRoomScene.chest_action = function(self)
	if OnlineConfig.isReward  then
        OnlineConfig.deleteOpenBoxTimer();
        self:requestCtrlCmd(OnlineRoomController.s_cmds.room_get_reward, OnlineConfig.getOpenboxid());
	end
end

OnlineRoomScene.onRoomTouch = function(self,finger_action, x, y)

	local drawing_id = drawing_pick ( 0,x,y);

	if finger_action ~= kFingerDown then
		return
	end
	
	if drawing_id ~= self.m_up_user_icon.m_drawingID then
		-- print_string("drawing_id ~= self.m_up_user_icon.m_drawingID");
        if drawing_id ~= self.m_up_user_info_dialog.m_add_btn.m_drawingID or drawing_id ~= self.m_up_user_info_dialog.m_cancle_btn.m_drawingID then
		    --self.m_up_user_info_dialog:dismiss();
        end
	end

	if drawing_id ~= self.m_down_user_icon.m_drawingID then
		-- print_string("drawing_id ~= self.m_down_user_icon.m_drawingID ");
        if drawing_id ~= self.m_down_user_info_dialog.m_add_btn.m_drawingID or drawing_id ~= self.m_down_user_info_dialog.m_cancle_btn.m_drawingID then
		    --self.m_down_user_info_dialog:dismiss();
        end
	end

end



 OnlineRoomScene.onUpdatePropInfo = function(self,data)

	local undo = UserInfo:getInstance():getUndoNum()
 	local tips = UserInfo:getInstance():getTipsNum()
	local revi = UserInfo:getInstance():getReviveNum()
		
	if data then
		if data.type == 3 then
			BroadcastMessageAnim.play(self.m_root_view,data);				
		else
			PayUtil.addPayBudanLog(data,self.m_controller);
		end
	end	    

	local undo = UserInfo:getInstance():getUndoNum()
 	local tips = UserInfo:getInstance():getTipsNum()
	local revi = UserInfo:getInstance():getReviveNum()

 end;



OnlineRoomScene.getNetStateLevel = function(self)
    local post_data = {};
	local dataStr = json.encode(post_data);
	dict_set_string(kGetNetStateLevel,kGetNetStateLevel..kparmPostfix,dataStr);
	call_native(kGetNetStateLevel);
end

OnlineRoomScene.registerSinalReceiver = function(self)
    local post_data = {};
	local dataStr = json.encode(post_data);
	dict_set_string(kRegisterSinalReceiver,kRegisterSinalReceiver..kparmPostfix,dataStr);
	call_native(kRegisterSinalReceiver);
end

OnlineRoomScene.unregisterSinalReceiver = function(self)
    local post_data = {};
	local dataStr = json.encode(post_data);
	dict_set_string(kUnregisterSinalReceiver,kUnregisterSinalReceiver..kparmPostfix,dataStr);
	call_native(kUnregisterSinalReceiver);
end 

OnlineRoomScene.showNetSinalIcon = function(self,isInit, netState)
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

	self.m_net_state_view_bg:setFile(self.m_sinal_icon_arr[level]);

	if level == 6 then
--		self:requestCtrlCmd(OnlineRoomController.s_cmds.close_room_socket);
		self.stop_time=true;
		self:stopTimeout();
		local message = "亲，您的网络有点不稳定哦！";
		ChatMessageAnim.play(self.m_root_view,3,message);
	end
end




OnlineRoomScene.showUpUserInfo = function(self,finger_action, x, y)
	print_string("showUpUserInfo ");
	if finger_action ~= kFingerUp then
		return
	end
	if self.m_up_user_info_dialog:isShowing() then
		self.m_up_user_info_dialog:dismiss();
	else
		self:onEventStat(ROOM_MODEL_UPUSER_ICON);
		self.m_up_user_info_dialog:show(self.m_upUser);
	end
end

OnlineRoomScene.showDownUserInfo = function(self,finger_action, x, y)
	if finger_action ~= kFingerUp then
		return
	end
    if self.m_down_user_info_dialog:isShowing() then
		self.m_down_user_info_dialog:dismiss();
	else
	    self:onEventStat(ROOM_MODEL_DOWNUSER_ICON);
	    self.m_down_user_info_dialog:show(self.m_downUser);
    end;
end


OnlineRoomScene.menuToggle = function(self)
	self:onEventStat(ROOM_MODEL_MENU_BTN);

	local showing = self.m_board_menu_dialog:isShowing();
	if not showing then
		self.m_board_menu_dialog:show();
	else
		self.m_board_menu_dialog:dismiss();
	end
end


OnlineRoomScene.undoAction = function(self)
	if self:isEnableUndo() or self.isUndoAble then
        local message = "确认向对方支付一定金币请求悔棋"
--        if self.m_upUser:getClient_version() >= 1 then  --对手getClient_version=>1为1.7.5之后的版本（包括）
        if not self.m_roominfo then
            local roomtype = UserInfo.getInstance():getMoneyType() or 0;
            if roomtype == UserInfo.getInstance():getRoomConfigById(4).money then
                self.m_roominfo = UserInfo.getInstance():getRoomConfigById(4);--4为私人房
            else
	            self.m_roominfo = UserInfo.getInstance():getRoomConfigById(roomtype);
            end
        end
            
	    if self.m_roominfo and self.m_roominfo.undomoney and self.m_roominfo.undomoney > 0 then
	        message = "确认向对方支付"..tostring(self.m_roominfo.undomoney).."金币请求悔棋吗？" ;
        end
--        else
--            message = "对方版本过低，只支持普通悔棋"
--        end
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
--		ShowMessageAnim.play(self.m_root_view,message);
        ChessToastManager.getInstance():showSingle(message); 
	end
end

OnlineRoomScene.undoAction_sure = function(self)
    if self:isEnableUndo() or self.isUndoAble then
		self:undo();
	else
		local message = "亲，现在还不能悔棋!"
        ChessToastManager.getInstance():showSingle(message); 
	end
end

OnlineRoomScene.undo = function(self)   --发送悔棋请求
	self:onEventStat(ROOM_MODEL_MENU_UNDO_BTN);
	if UserInfo.getInstance():getGameType() == GAME_TYPE_COMPUTER then  --单机
		self.m_board:consoleUndoMove();
	else
        self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_undomove, 1);
	    self:setEnableUndo(false);
	    self.isUndoAble = false;
	end
end

OnlineRoomScene.setEnableChess = function(self,enableChess)
	self.m_enableChess = enableChess;
end

OnlineRoomScene.isEnableChess = function(self)
	return self.m_enableChess;
end

--悔棋
OnlineRoomScene.setEnableUndo =function(self,enableUndo)
	self.m_enableUndo = enableUndo;
end		

OnlineRoomScene.isEnableUndo = function(self)

	if not self.m_first_move then
		return false;
	end
	
	--单机游戏没有可悔棋限制
	if UserInfo.getInstance():getGameType() == GAME_TYPE_COMPUTER then
		if (self.m_t_statuss == STATUS_TABLE_ACTIVE_BLACK  or self.m_t_statuss == STATUS_TABLE_ACTIVE_RED) and self.m_first_move then
			return true;
		else
			return false;
		end
	end
	return self.m_enableUndo or false;
end

OnlineRoomScene.setEnableSurrender =function(self,enableSurrender)
	self.m_enableSurrender = enableSurrender;
end		
OnlineRoomScene.isEnableSurrender = function(self)
    return self.m_enableSurrender;
--	--单机游戏没有可投降限制
--	if UserInfo.getInstance():getGameType() == GAME_TYPE_COMPUTER then
--		return self.m_enableSurrender;
--	end

--	--超过棋局三分钟才可以投降
--	if self.m_enableSurrender and (self.m_timeout1*2 - self.m_upUser.m_timeout1 - self.m_downUser.m_timeout1) > 60*3 then
--		return true;
--	else
--		return false;
--	end
end


OnlineRoomScene.setting = function(self)
	self:onEventStat(ROOM_MODEL_MENU_SET_BTN);

	self.m_board_menu_dialog:dismiss();

	if not self.m_setting_dialog then
		self.m_setting_dialog = new(SettingDialog);
	end

	self.m_setting_dialog:show();
end

OnlineRoomScene.chess = function(self)
	local event_info = DOWN_MODEL_DAPU_BTN .. "," .. self.m_stat_place;
	on_event_stat(event_info); --事件统计
	self.m_board_menu_dialog:dismiss();
	if UserInfo.getInstance():getDapuEnable() == false then
		self:buyDapu(ONLINE_ROOM_MENU_DAPU);
		return;
	end

	ToolKit.removeAllTipsDialog(); 

	StateMachine.getInstance():pushState(States.dapu,StateMachine.STYPE_LEFT_IN);
end

OnlineRoomScene.buyDapu = function(self,pos)
	self.m_payInterface = PayUtil.getPayInstance(PayUtil.s_payType.Exchange);
	self.m_payInterface:buy(nil,pos);
end


OnlineRoomScene.surrender = function(self)
	self:onEventStat(ROOM_MODEL_MENU_SURRENDER_BTN);

	local message = "您是否要认输？"

	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end

	self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE);
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:setPositiveListener(self,self.surrender_sure);
	self.m_chioce_dialog:setNegativeListener();
	self.m_chioce_dialog:show();
end

OnlineRoomScene.surrender_sure = function(self)
	if UserInfo.getInstance():getGameType() == GAME_TYPE_COMPUTER then  --单机
		self:console_gameover(self.m_upUser:getFlag(),ENDTYPE_SURRENDER);
	else
        self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_surrender1);
	end
end


OnlineRoomScene.draw = function(self)
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


OnlineRoomScene.draw_sure = function(self)
	print_string("Room.draw");
	self:setEnableDraw(false);
	local gametype = UserInfo.getInstance():getGameType();
	if gametype == GAME_TYPE_COMPUTER then  --单机
		self.m_board:drawRequest();
	elseif gametype <= GAME_TYPE_TWENTY or gametype == GAME_TYPE_CUSTOMROOM or gametype == GAME_TYPE_FRIEND then  --网络游戏

        self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_draw1);

	end
end



OnlineRoomScene.cancelMatch = function(self)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.hall_cancel_match,UserInfo.getInstance():getMoneyType()); 
end;

OnlineRoomScene.showMoneyRent = function(self)

	if self.m_gametype <= GAME_TYPE_TWENTY then
        local roomtype = UserInfo.getInstance():getMoneyType() or 0;
        if roomtype == UserInfo.getInstance():getRoomConfigById(4).money then
            self.m_roominfo = UserInfo.getInstance():getRoomConfigById(4);--4为私人房
        elseif UserInfo.getInstance():getGameType() == GAME_TYPE_FRIEND then
            self.m_roominfo = UserInfo.getInstance():getRoomConfigById(5);--5为好友房
        else
	        self.m_roominfo = UserInfo.getInstance():getRoomConfigById(roomtype);
        end
		local money = self.m_roominfo.rent ;
		local message = string.format("该场次每局消耗%d金币",money);
		--ShowMessageAnim.play(self.m_root_view,message);
		ChatMessageAnim.play(self.m_root_view,3,message);
	end
end



OnlineRoomScene.changeRoomType = function(self)
	self.m_need_change_room_type = true;
	self.m_account_dialog:dismiss();
	self:stopTimeout();
--	self.m_controller:stopHeartBeat();

	if self.m_gametype <= GAME_TYPE_TWENTY and self.m_gametype >= GAME_TYPE_FREE then

		if self.m_downUser and self.m_downUser:getStatus() >= STATUS_PLAYER_LOGIN then
            self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_leave);
		end
	end

end



--破产
OnlineRoomScene.collapse = function(self)
	print_string("Room.collapse .. ");
	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end

	local message = "您的金币不足以继续游戏,需要购买金币吗？";
	self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE);
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:setPositiveListener(self,self.collapseBuyCoin);
	self.m_chioce_dialog:setNegativeListener(self,self.exitRoom)
	self.m_chioce_dialog:show();
end

OnlineRoomScene.collapseBuyCoin = function(self)
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

OnlineRoomScene.start_watch = function(self)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.start_watch);
end;

OnlineRoomScene.start_customroom = function(self)
	print_string("Room.start_customroom ... ");
--    if UserInfo.getInstance():getRelogin() then

--	else
  		 -- self.m_room_watcher_count_tips:setVisible(false)
         self.m_room_watcher:setVisible(false);
		 self.m_roomid_label_text:setVisible(true);
		 self.m_roomid_text:setVisible(true);
  		 self.m_roomid_text:setText(UserInfo.getInstance():getCustomRoomID());
         self:requestCtrlCmd(OnlineRoomController.s_cmds.start_customroom);
--	end
end;
OnlineRoomScene.onUpdateWatchRoom = function(self, data, message)
    if not data then
        self:loginFail(message)
        return;
    end;
    local player1 = data.player1;
    local player2 = data.player2;
    if player1 then
        if player1:getFlag() == 1 then
            self:downComeIn(player1);
        else
            self:upComeIn(player1);
        end
    end
    if player2 then
        if player2:getFlag() == 1 then
            self:downComeIn(player2);
        else
            self:upComeIn(player2);
        end
    end
    if not player1 and not player2 then
        self:watchUserLeave();
        return;
    end
    self.m_timeout1 = data.round_time;
	self.m_timeout2 = data.step_time;
	self.m_timeout3 = data.sec_time;
    if player1 and data.curr_move_flag == player1:getUid() then
        self.m_move_flag = player1:getFlag();
    elseif player2 and data.curr_move_flag == player2:getUid() then
        self.m_move_flag = player2:getFlag();
    end
    if self.m_move_flag == FLAG_RED then
        self.m_red_turn = true;
    else
        self.m_red_turn = false;
    end;
    self:setGameType(1);
    if data.status == 2 then--只有在状态2（playing）才有下面信息
        self:setStatus(data.status);
        local last_move = {}
	    last_move.moveChess = data.chessMan;
	    last_move.moveFrom = 91 -data.position1;
	    last_move.moveTo = 91 - data.position2;
	    self:synchroData(data.chess_map,last_move);
    else
        self:setStatus(data.status);
--        ShowMessageAnim.play(self.m_root_view,"等待开局");
        local message =  "等待开局"; 
        ChessToastManager.getInstance():showSingle(message); 
    end;
end;

OnlineRoomScene.onUpdateWatchRoomUser = function(self, data)

    self:setWathcerCount(data);

end;

OnlineRoomScene.setWathcerCount = function(self,count)
	if self.m_room_watcher_bg_btn:getVisible() then
        if count and count >= 0 then
		    self.m_watcher_count = count;
		    local str = string.format("%d",count);
		    self.m_room_watcher:setText(str);
            self.m_room_watcher_bg_btn:setPickable(true);
	    else
            self.m_room_watcher_bg_btn:setPickable(false);
		    self.m_room_watcher:setText("0");
	    end
    end;
end

OnlineRoomScene.synchroData = function(self,chess_map,last_move)
	self.m_needSyn = false;
    self.m_had_syn_data = false;

	local model = Board.MODE_BLACK;
	local redTurn = false;
	if(self.m_downUser:getFlag() == FLAG_RED) then
		model = Board.MODE_RED;
	end
    

	self.m_board:synchroBoard(chess_map,model,self.m_red_turn);

	self.m_board:setMovePath(last_move.moveFrom,last_move.moveTo);
	local multiply = UserInfo.getInstance():getMultiply();
	if multiply ~=nil then
		self.m_multiple_text:setText(multiply);
	else
		self.m_multiple_text:setText("1");
	end

	self:stopTimeout();
	self:startTimeout();
end

OnlineRoomScene.startTimeout = function(self)
	self:stopTimeout();
	if self.m_gametype <= GAME_TYPE_TWENTY or self.m_gametype == GAME_TYPE_CUSTOMROOM or self.m_gametype == GAME_TYPE_FRIEND then
		self:setTimeFrameVisible(true);
		self.m_timeoutAnim = new(AnimInt,kAnimLoop,0,1,1000,-1);
		self.m_timeoutAnim:setDebugName("Room.startTimeout.m_timeoutAnim");
		self.m_timeoutAnim:setEvent(self,self.timeoutRun);
	end
end

OnlineRoomScene.timeoutRun = function(self)

	if self.m_downUser and self.m_downUser:getFlag() == self.m_move_flag then
		self.m_downUser:timeout1__();
		self.m_downUser:timeout2__();
		self.m_downUser:timeout3__();

        if UserInfo.getInstance():getGameType() ~= GAME_TYPE_WATCH then
            local _,timeout_num = self.m_downUser:getTimeout2();
            local timeout_temp = tonumber(timeout_num or 0);
            if timeout_temp == 10 then
                call_native("DeviceShake");
            end
            if timeout_temp < 10 and timeout_temp > 0 then
                if SettingInfo.getInstance():getSoundToggle() then
                    kEffectPlayer:playEffect(Effects.AUDIO_SECOND_TIP);
                end
            end
        end
	end

	if self.m_upUser and self.m_upUser:getFlag() == self.m_move_flag then
		self.m_upUser:timeout1__();
		self.m_upUser:timeout2__();
		self.m_upUser:timeout3__();
	end


	--步时还是读秒
	if self.m_upUser and  self.m_upUser:isTimeout() then
		if not self.m_up_setTimeoutFile then 
			self.m_up_timeout2_img:setFile(TIMEOUT3_IMG_FILE);   --设置成读秒
			self.m_up_setTimeoutFile = true;
			self.m_up_setUnTimeoutFile = false;
		end
	else
		if not self.m_up_setUnTimeoutFile then
			self.m_up_timeout2_img:setFile(TIMEOUT2_IMG_FILE);   --设置成步时
			self.m_up_setUnTimeoutFile = true;
			self.m_up_setTimeoutFile = false;
		end
	end


	if self.m_downUser:isTimeout() then
		if not self.m_down_setTimeoutFile then 
			self.m_down_timeout2_img:setFile(TIMEOUT3_IMG_FILE);   --设置成读秒
			self.m_down_setTimeoutFile = true;
			self.m_down_setUnTimeoutFile = false;
		end
	else
		if not self.m_down_setUnTimeoutFile then
			self.m_down_timeout2_img:setFile(TIMEOUT2_IMG_FILE);   --设置成步时
			self.m_down_setUnTimeoutFile = true;
			self.m_down_setTimeoutFile = false;
		end
	end

	--时间
	if self.m_upUser then 
		self.m_up_timeout1_text:setText(self.m_upUser:getTimeout1());
		self.m_up_timeout2_text:setText(self.m_upUser:getTimeout2());
		self.m_down_timeout1_text:setText(self.m_downUser:getTimeout1());
		self.m_down_timeout2_text:setText(self.m_downUser:getTimeout2());
	end 
end

OnlineRoomScene.stopTimeout = function(self)
	if self.m_timeoutAnim then
		delete(self.m_timeoutAnim);
		self.m_timeoutAnim = nil;
	end
end

OnlineRoomScene.chat_action = function(self)
	self:onEventStat(ROOM_MODEL_CHAT_BTN);

	if not self.m_chat_dialog then
		self.m_chat_dialog = new(ChatDialog,self);
	end
	self.m_chat_dialog:show();
end

OnlineRoomScene.sendWatchChat = function(self, message)

    self:requestCtrlCmd(OnlineRoomController.s_cmds.send_watch_chat, message);

end;

OnlineRoomScene.watchChatLogToggle = function(self)
	local showing = self.m_watch_chat_log_dialog:isShowing();
	if not showing then
		self.m_watch_chat_log_dialog:show();
	else
		self.m_watch_chat_log_dialog:dismiss();
	end
end

OnlineRoomScene.setTimeFrameVisible = function(self,flag)
	self.m_up_timeout1_img:setVisible(flag);
	self.m_up_timeout1_text:setVisible(flag);
	self.m_up_timeout2_img:setVisible(flag);
	self.m_up_timeout2_text:setVisible(flag);

	self.m_down_timeout1_img:setVisible(flag);
	self.m_down_timeout1_text:setVisible(flag);
	self.m_down_timeout2_img:setVisible(flag);
	self.m_down_timeout2_text:setVisible(flag);
end

OnlineRoomScene.downComeIn = function(self, user, need_ready)
Log.i("OnlineRoomScene.onDownUserComeIn");
	self.m_downUser = user;
    self.m_down_user_level_icon:setFile(string.format("userinfo/%s.png",UserInfo.getInstance():getDanGradingLevelByScore(user:getScore())));
    self.m_down_name:setText(user:getName());
	self.m_down_user_icon:setFile(self.m_downUser:getIconFile());
	HeadSmogAnim.play(self.m_down_user_icon);
	self.m_down_user_icon:setVisible(true);
	-- self.m_ingot_text:setText(user:getBccoin());

	local game_type = UserInfo.getInstance():getGameType();
	if game_type == GAME_TYPE_WATCH then  --如果是观战
--		local imageName = self.m_downUser:loadIcon1(self.m_downUser:getUid(),self.m_downUser:getIcon());
--        if imageName then
--            self.m_down_user_icon:setFile(imageName);
--        end
        local iconType = tonumber(self.m_downUser:getIconType());
        
        if iconType then
            if 0 ~= iconType then
                if iconType == -1 then -- server 传的数据不会出现 用户头像 iconType 为 -1的情况 只可能是自己的头像
                    self.m_down_user_icon:setFile(UserInfo.getInstance():getIconFile());
                else
                    self.m_down_user_icon:setFile(UserInfo.DEFAULT_ICON[iconType]  or UserInfo.DEFAULT_ICON[1]);
                end
            end;
        else
            if "" ~= self.m_downUser:getIcon() then --兼容1.7.5之前的版本的头像为""时显示默认头像。
		        local imageName = self.m_downUser:loadIcon1(self.m_downUser:getUid(),self.m_downUser:getIcon());
                if imageName then
                    self.m_down_user_icon:setFile(imageName);
                end
            end;
        end;
	elseif game_type == GAME_TYPE_COMPUTER then


	elseif game_type <= GAME_TYPE_TWENTY  then
--		if self.m_downUser:getStartVisible() and need_ready then
--			self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_start);
--		end
	end
	self.m_down_user_ready_img:setVisible(self.m_downUser:getReadyVisible());
	
	if need_ready then
		self.m_down_user_start_btn:setVisible(self.m_downUser:getStartVisible());
   	end

	print_string("Room.downComeIn name = " .. self.m_downUser:getName());    

end;

OnlineRoomScene.upComeIn = function(self, user, isSynDataComeIn)
    Log.i("OnlineRoomScene.onUpUserComeIn");
    if not user then
        return;
    end
    self:hideSelectPlayerDialog();--有玩家进来了，隐藏选择框
	if self.m_upUser then
		delete(self.m_upUser);
		self.m_upUser = nil;
	end
    -- local  userGameType  = UserInfo.getInstance():getGameType();
    if isSynDataComeIn and user:getUid()<=0 then
		self.m_up_user_icon:setVisible(false);
		self.m_up_user_ready_img:setVisible(false);

		self.m_up_name:setText("");
		self.m_up_title:setText("");
    else
        local game_type = UserInfo.getInstance():getGameType();
	    if game_type <= GAME_TYPE_TWENTY  then
            if user:getClient_version() > 0 and user:getClient_version() < 195 and not self.m_canSetTimeFlag then     --低于1.9.5版本不支持局时设置
                ChessToastManager.getInstance():show("对方版本不支持设置局时",2000);
                self.m_canSetTimeFlag = true;
            end
	    end
	    self.m_upUser = user;
        self.m_up_user_level_icon:setFile(string.format("userinfo/%s.png",UserInfo.getInstance():getDanGradingLevelByScore(user:getScore())));
        --iconType有2类值，一种是头像url（对手头像是本地上传的）。一种是数字0（对手没有传过头像），1，2，3，4（系统自带的头像）
        self.m_up_user_icon:setFile(user:getIconFile());
		HeadSmogAnim.play(self.m_up_user_icon);
        
        local iconType = tonumber(self.m_upUser:getIconType());
        
        if  iconType then
            if 0 ~= iconType then
                self.m_up_user_icon:setFile(UserInfo.DEFAULT_ICON[iconType] or UserInfo.DEFAULT_ICON[1]);
            end;
        else
            if "" ~= self.m_upUser:getIcon() then --兼容1.7.5之前的版本的头像为""时显示默认头像。
		        local imageName = self.m_upUser:loadIcon1(self.m_upUser:getUid(),self.m_upUser:getIcon());
                if imageName then
                    self.m_up_user_icon:setFile(imageName);
                end
            end;
        end;
		self.m_up_user_icon:setVisible(true);
		self.m_up_user_ready_img:setVisible(self.m_upUser:getReadyVisible());
		self.m_up_name:setText(user:getName());
        print_string("Room.upComeIn name = " .. self.m_upUser:getName());
    end
end;


OnlineRoomScene.setDieChess = function(self,dieChess)
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
			local fileStr = piece_resource_id[upflag +i] .. "_dead.png";
 			local file = roomres_map[fileStr];

			self.m_up_chess_pc[i]:setFile(file);
			self.m_up_chess_pc[i]:setVisible(true);
			self.m_up_chess_num[i]:setVisible(false);
		elseif dieChess[upflag +i ] > 1 and dieChess[upflag +i ] <= 5 then
			local fileStr = piece_resource_id[upflag +i] .. "_dead.png";
 			local file = roomres_map[fileStr];

			self.m_up_chess_pc[i]:setFile(file);
			self.m_up_chess_pc[i]:setVisible(true);
			self.m_up_chess_num[i]:setFile("drawable/num_" .. dieChess[upflag +i ] .. ".png");
			self.m_up_chess_num[i]:setVisible(true);
		else
			self.m_up_chess_pc[i]:setVisible(false);
			self.m_up_chess_num[i]:setVisible(false);
		end

		if not dieChess[downflag +i ] then
			sys_set_int("win32_console_color",10);
			print_string("Room.setDieChess but not dieChess[downflag +i ] " .. i);
			sys_set_int("win32_console_color",9);
		elseif dieChess[downflag +i ] == 1 then
			local fileStr = piece_resource_id[downflag +i] .. "_dead.png";
 			local file = roomres_map[fileStr];

			self.m_down_chess_pc[i]:setFile(file);
			self.m_down_chess_pc[i]:setVisible(true);
			self.m_down_chess_num[i]:setVisible(false);
		elseif dieChess[downflag +i ] > 1 and dieChess[downflag +i ] <= 5 then
			local fileStr = piece_resource_id[downflag +i] .. "_dead.png";
 			local file = roomres_map[fileStr];


			self.m_down_chess_pc[i]:setFile(file);
			self.m_down_chess_pc[i]:setVisible(true);
			self.m_down_chess_num[i]:setFile("drawable/num_" .. dieChess[downflag +i ] .. ".png");
			self.m_down_chess_num[i]:setVisible(true);
		else
			self.m_down_chess_pc[i]:setVisible(false);
			self.m_down_chess_num[i]:setVisible(false);
		end
	end

    self:resetChessPos();
    for i = 1 ,7 do
        if self.m_up_chess_pc[i]:getVisible() then
            for j = 1, 7 do
               if UserInfoDialog.up_chess_pos[j].available then
                   self.m_up_chess_pc[i]:setPos(UserInfoDialog.up_chess_pos[j].pos);
                   UserInfoDialog.up_chess_pos[j].available = false;
                   break;
               end
            end
        end
    end
    for i = 1 ,7 do
        if self.m_down_chess_pc[i]:getVisible() then
            for j = 1, 7 do
               if UserInfoDialog.down_chess_pos[j].available then
                   self.m_down_chess_pc[i]:setPos(UserInfoDialog.down_chess_pos[j].pos);
                   UserInfoDialog.down_chess_pos[j].available = false;
                   break;
               end
            end
        end
    end
end

OnlineRoomScene.resetChessPos = function(self)
	for i = 1,7 do
		UserInfoDialog.down_chess_pos[i].available = true;
        UserInfoDialog.up_chess_pos[i].available = true;
	end
end

OnlineRoomScene.clearDiechess = function(self)
	for i = 1,7 do
		self.m_down_chess_pc[i]:setVisible(false);
		self.m_down_chess_num[i]:setVisible(false);

		self.m_up_chess_pc[i]:setVisible(false);
		self.m_up_chess_num[i]:setVisible(false);
	end
end

OnlineRoomScene.setStatus =function(self,status,op_uid)
	
	self.m_t_statuss = status;
	if self.m_t_statuss == STATUS_TABLE_PLAYING then   --走棋状态
		self.m_up_turn:setVisible(self.m_upUser:getFlag() == self.m_move_flag);
		self.m_down_turn:setVisible(self.m_downUser:getFlag() == self.m_move_flag);
		if self.m_first_move then
			self:setEnableUndo(self.m_downUser:getFlag() ~= self.m_move_flag);
		else
			self:setEnableUndo(false);
			self.m_first_move = true;
		end
		self:setEnableDraw(true);
		self:setEnableSurrender(true);
        self.m_toast_bg:setVisible(false);
	elseif self.m_t_statuss == STATUS_TABLE_FORESTALL then  -- 抢先状态
        if UserInfo.getInstance():getGameType() == GAME_TYPE_WATCH then
            if op_uid then
                if self.m_downUser and self.m_downUser:getUid() == op_uid then
                    self.m_toast_text:setText(self.m_downUser:getName() .. "抢先中...");
                end
                if self.m_upUser and self.m_upUser:getUid() == op_uid then
                    self.m_toast_text:setText(self.m_upUser:getName() .. "抢先中...");
                end
            else
                self.m_toast_text:setText("抢先中...");
            end
            self.m_toast_bg:setVisible(true);
            ShowMessageAnim.reset();
        end
	elseif self.m_t_statuss == STATUS_TABLE_HANDICAP then  -- 让子状态
        if UserInfo.getInstance():getGameType() == GAME_TYPE_WATCH then
            if op_uid then
                if self.m_downUser and self.m_downUser:getUid() == op_uid then
                    self.m_toast_text:setText(self.m_downUser:getName() .. "让子中...");
                end
                if self.m_upUser and self.m_upUser:getUid() == op_uid then
                    self.m_toast_text:setText(self.m_upUser:getName() .. "让子中...");
                end
            else
                self.m_toast_text:setText("双方让子中...");
            end
            self.m_toast_bg:setVisible(true);
            ShowMessageAnim.reset();
        end
	elseif self.m_t_statuss == STATUS_TABLE_SETTIME then -- 设置局时状态
        if UserInfo.getInstance():getGameType() == GAME_TYPE_WATCH then
            if op_uid then
                if self.m_downUser and self.m_downUser:getUid() == op_uid then
                    self.m_toast_text:setText(self.m_downUser:getName() .. "设置棋局中...");
                end
                if self.m_upUser and self.m_upUser:getUid() == op_uid then
                    self.m_toast_text:setText(self.m_upUser:getName() .. "设置棋局中...");
                end
            else
                self.m_toast_text:setText("设置棋局中...");
            end
            self.m_toast_bg:setVisible(true);
            ShowMessageAnim.reset();
        end
    elseif self.m_t_statuss == STATUS_TABLE_SETTIMERESPONE then
        if UserInfo.getInstance():getGameType() == GAME_TYPE_WATCH then
            if op_uid then
                if self.m_downUser and self.m_downUser:getUid() == op_uid then
                    self.m_toast_text:setText("等待" ..self.m_downUser:getName() .. "同意棋局设置...");
                end
                if self.m_upUser and self.m_upUser:getUid() == op_uid then
                    self.m_toast_text:setText("等待" ..self.m_upUser:getName() .. "同意棋局设置...");
                end
            else
                self.m_toast_text:setText("设置棋局中...");
            end
            self.m_toast_bg:setVisible(true);
            ShowMessageAnim.reset();
        end
    else
        self.m_toast_bg:setVisible(false);
    end
end	

OnlineRoomScene.setGameType =function(self,gametype)
	self.m_gametype = gametype;
end		

--悔棋
OnlineRoomScene.setEnableUndo =function(self,enableUndo)
	self.m_enableUndo = enableUndo;
end		

OnlineRoomScene.setEnableDraw =function(self,enableDraw)
	self.m_enableDraw = enableDraw;
end		

OnlineRoomScene.isEnableDraw = function(self)
	return self.m_enableDraw or false;
end

OnlineRoomScene.setStartReadyVisible = function(self)

	if self.m_downUser then
		self.m_down_user_ready_img:setVisible(self.m_downUser:getReadyVisible());
		self.m_down_user_start_btn:setVisible(false);
	end

	if self.m_upUser then
		self.m_up_user_ready_img:setVisible(self.m_upUser:getReadyVisible());
	end


	local game_type = UserInfo.getInstance():getGameType();

	if game_type == GAME_TYPE_WATCH then  --如果是观战状态  --不要显示开始按键
		self.m_down_user_start_btn:setVisible(false);
	end
end

OnlineRoomScene.onWatcherCountChange = function(self,num)
	self.m_watcher_count = self.m_watcher_count + num;
	local str = string.format("%d",self.m_watcher_count);
	self.m_room_watcher:setText(str.." 人");

end

OnlineRoomScene.onWatchRoomMove = function(self, data)

    if not data then
        return 
    end;
    
    if not self.m_downUser or not self.m_upUser then
        return;
    end
    if data.last_move_uid == self.m_downUser:getUid() then
        if self.m_downUser:getFlag() == FLAG_RED then
		    self.m_downUser:setTimeout1((self.m_timeout1 - data.red_timeout));
            self.m_upUser:setTimeout1(self.m_timeout1 - data.black_timeout);
            self.m_move_flag = FLAG_BLACK;--此函数内接收的是已经走完的棋，所以将要走的棋标志置反。
        else
            self.m_downUser:setTimeout1((self.m_timeout1 - data.black_timeout));
            self.m_upUser:setTimeout1(self.m_timeout1 - data.red_timeout);
            self.m_move_flag = FLAG_RED;
        end;
		self.m_downUser:setTimeout2(self.m_timeout2);
		self.m_downUser:setTimeout3(self.m_timeout3);
    elseif data.last_move_uid == self.m_upUser:getUid() then
        if self.m_upUser:getFlag() == FLAG_RED then
		    self.m_upUser:setTimeout1((self.m_timeout1 - data.red_timeout));
            self.m_downUser:setTimeout1(self.m_timeout1 - data.black_timeout);
            self.m_move_flag = FLAG_BLACK;
        else
            self.m_upUser:setTimeout1((self.m_timeout1 - data.black_timeout));
            self.m_downUser:setTimeout1(self.m_timeout1 - data.red_timeout);
            self.m_move_flag = FLAG_RED;
        end;
		self.m_upUser:setTimeout2(self.m_timeout2);
		self.m_upUser:setTimeout3(self.m_timeout3);
    end;
    self:setStatus(data.status);
    if data.ob_num then
     	local str = string.format("%d",data.ob_num);
	    self.m_room_watcher:setText(str);   
    end;

    local mv = {}
	mv.moveChess = data.chessMan;
	mv.moveFrom = data.position1;
	mv.moveTo = data.position2;
	self:resPonseMove(mv);



end;

OnlineRoomScene.onWatchRoomUserLeave = function(self, data)
    if not data then
        return 
    end;
--	if self.m_downUser:getUid() == data.player1ID then
--		self.m_downUser:setStatus(data.player1Status);
--		if self.m_upUser then
--			self.m_upUser:setStatus(data.player2Status);
--		end
--	else
--		self.m_downUser:setStatus(data.player2Status);
--		if self.m_upUser then
--			self.m_upUser:setStatus(data.player1Status);
--		end
--	end
--    self:setStartReadyVisible();

    self:watchUserLeave(data.leave_uid);
end;

OnlineRoomScene.onWatchRoomReady = function(self, data)
    if not data then
        return 
    end;
    self:setStatus(data.tableStatus);
	if self.m_downUser:getUid() == data.player1ID then
		self.m_downUser:setStatus(data.player1Status);
		if self.m_upUser then
			self.m_upUser:setStatus(data.player2Status);
		end
	else
		self.m_downUser:setStatus(data.player2Status);
		if self.m_upUser then
			self.m_upUser:setStatus(data.player1Status);
		end
	end
    self:setStartReadyVisible();
end; 

OnlineRoomScene.onWatchRoomStart = function(self, data)
    if not data then
        return 
    end;
    self.m_timeout1 = data.round_time;
	self.m_timeout2 = data.step_time;
	self.m_timeout3 = data.sec_time;
	

--	if  self.m_downUser:getUid() == data.player1ID then
--		self.m_downUser:setStatus(data.player1Status);
--		if self.m_upUser then
--			self.m_upUser:setStatus(data.player2Status);
--		end
--	else
--		self.m_downUser:setStatus(data.player2Status);
--		if self.m_upUser then
--			self.m_upUser:setStatus(data.player1Status);
--		end
--	end
	self.m_downUser:setTimeout1(data.round_time);
	self.m_downUser:setTimeout2(data.step_time);
	self.m_downUser:setTimeout3(data.sec_time);

	self.m_upUser:setTimeout1(data.round_time);
	self.m_upUser:setTimeout2(data.step_time);
	self.m_upUser:setTimeout3(data.sec_time);

	if  self.m_downUser:getUid() == data.red_uid then
		self.m_downUser:setFlag(FLAG_RED);
		if self.m_upUser then
			self.m_upUser:setFlag(FLAG_BLACK);
		end
	else
		self.m_downUser:setFlag(FLAG_BLACK);
		if self.m_upUser then
			self.m_upUser:setFlag(FLAG_RED);
		end
	end
    self.m_move_flag = FLAG_RED;
    self.m_red_turn = true;
    self:setStatus(data.status);
--	self:setStartReadyVisible();
	self:startGame(data.chess_map);

end;


OnlineRoomScene.startGame = function(self,chess_map)
	self.m_game_over = false;
    self.m_first_move = false;
	self.m_had_syn_data = false;
    self.m_board_menu_dialog:dismiss();
    self:onDeleteInvitAnim();
--	self:dismissLoadingDialog();
	if chess_map then
		self:startBoard(chess_map);
	elseif self.m_needSyn then
--		self:synchroRequest();
	elseif(self.m_downUser:getFlag() == FLAG_RED) then
		self.m_board:newgame(Board.MODE_RED);--board:newGame(red_down_game);
	else
		self.m_board:newgame(Board.MODE_BLACK);
	end
	self:setEnableChess(false);


	self:stopTimeout();
	self:startTimeout();
	--self:showMoneyRent();

end

--有让子之后，棋局开始会发送棋盘信息
OnlineRoomScene.startBoard = function(self,chess_map)
	print_string("Room.startBoard ");
	local model = Board.MODE_BLACK;
	if(self.m_downUser:getFlag() == FLAG_RED) then
		model = Board.MODE_RED;
    end
	self.m_board:synchroBoard(chess_map,model,self.m_red_turn);

	GameCacheData.getInstance():saveString(GameCacheData.DAPU_LAST_BORAD_FEN,Board.toFen(chess_map,self.m_red_turn));
	GameCacheData.getInstance():saveString(GameCacheData.DAPU_LAST_CHESS_STR,table.concat(chess_map,MV_SPLIT));
end

OnlineRoomScene.synchroRequest = function(self)

	local gametype = UserInfo.getInstance():getGameType();
	if gametype == GAME_TYPE_WATCH then
        self:requestCtrlCmd(OnlineRoomController.s_cmds.syn_watch_data);
	else
        self:requestCtrlCmd(OnlineRoomController.s_cmds.syn_room_data);
	end
	self.m_had_syn_data = true;
end

OnlineRoomScene.setEnableChess = function(self,enableChess)
	self.m_enableChess = enableChess;
end

OnlineRoomScene.dismissLoadingDialog = function(self)
	if self.m_loading_dialog and self.m_loading_dialog:isShowing() then
		self.m_loading_dialog:dismiss();
	end
end

OnlineRoomScene.onWatchRoomClose = function(self, data)

	self:setStatus(data.status);

--	if  self.m_downUser:getUid() == data.player1ID then
--		self.m_downUser:setStatus(data.player1Status);
--		if self.m_upUser then
--			self.m_upUser:setStatus(data.player2Status);
--		end
--	else
--		self.m_downUser:setStatus(data.player2Status);
--		if self.m_upUser then
--			self.m_upUser:setStatus(data.player1Status);
--		end
--	end

--	if  self.m_downUser:getFlag() == FLAG_RED then
--		self.m_downUser:setScore(data.totalscoreRed);
--		self.m_downUser:setPoint(data.scoreRed);
--		self.m_downUser:setLevel(data.levelRed);
--		self.m_downUser:setTitle(data.titleRed);
--		self.m_downUser:setRank(data.redRank);
--		self.m_downUser:setCoin(data.redCoin);
--		self.m_downUser:setMoney(data.redTotalCoin);
--		self.m_downUser:setTaxes(data.redTaxes);
--		if self.m_upUser then
--			self.m_upUser:setScore(data.totalscoreBlack);
--			self.m_upUser:setPoint(data.scoreBlack);
--			self.m_upUser:setLevel(data.levelBlack);
--			self.m_upUser:setTitle(data.titleBlack);
--			self.m_upUser:setRank(data.blackRank);
--			self.m_upUser:setCoin(data.blackCoin);
--			self.m_upUser:setMoney(data.blackTotalCoin);
--			self.m_upUser:setTaxes(data.blackTaxes);
--		end
--	else
--		self.m_downUser:setScore(data.totalscoreBlack);
--		self.m_downUser:setPoint(data.scoreBlack);
--		self.m_downUser:setLevel(data.levelBlack);
--		self.m_downUser:setTitle(data.titleBlack);
--		self.m_downUser:setRank(data.blackRank);
--		self.m_downUser:setCoin(data.blackCoin);
--		self.m_downUser:setMoney(data.blackTotalCoin);
--		self.m_downUser:setTaxes(data.blackTaxes);
--		if self.m_upUser then
--			self.m_upUser:setScore(data.totalscoreRed);
--			self.m_upUser:setPoint(data.scoreRed);
--			self.m_upUser:setLevel(data.levelRed);
--			self.m_upUser:setTitle(data.titleRed);
--			self.m_upUser:setRank(data.redRank);
--			self.m_upUser:setCoin(data.redCoin);
--			self.m_upUser:setMoney(data.redTotalCoin);
--			self.m_upUser:setTaxes(data.redTaxes);
--		end
--	end

	self:gameClose(data.win_flag,data.end_type);    

end;

OnlineRoomScene.onWatchRoomAllReady = function(self, data)
    if not data then
        return;
    end;
    if data.tid then
--        ShowMessageAnim.play(self.m_root_view,"双方已准备(等待开局)");
        local message =  "双方已准备(等待开局)"; 
        ChessToastManager.getInstance():showSingle(message); 
    end;
end;

OnlineRoomScene.onWatchRoomError = function(self)
--    ShowMessageAnim.play(self.m_root_view,"亲，服务器貌似出问题了");
    local message =  "观战房间错误，请重新进入"; 
    ChessToastManager.getInstance():showSingle(message); 
    self:exitRoom();
end;

OnlineRoomScene.onCreateFriendRoom = function(self)
    self.m_down_user_start_btn:setVisible(true);
end

OnlineRoomScene.onSetTime = function(self,time_out)
    if self.m_friendChoiceDialog and self.m_friendChoiceDialog:isShowing() then
        return;
    end
    if not self.m_roomFriend then
        self.m_roomFriend = new(RoomFriendSetTime,UserInfo.getInstance():getRoomLevel());
    end
    self.m_roomFriend:onSureFunc(self,self.onSetTimeFinish);
    self.m_roomFriend:show(time_out);
end

OnlineRoomScene.onSetTimeFinish = function(self,timeData)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.set_time_finish, timeData);
end

OnlineRoomScene.onSetTimeShow = function(self,data)
    if not self.m_roomFriendShow then
        self.m_roomFriendShow = new(RoomFriendSetTimeShow,UserInfo.getInstance():getRoomLevel());
    end
    self.m_roomFriendShow:onSureFunc(self,self.onSetTimeAgree);
    self.m_roomFriendShow:onCancleFunc(self,self.onSetTimeDisagree);
    self.m_roomFriendShow:show(data);
end

OnlineRoomScene.onReSetGame = function(self,flag)
    self:clearDialog();
    self.m_down_user_ready_img:setVisible(false);
    self.m_down_user_start_btn:setVisible(true);
    UserInfo.getInstance():setChallenger(true);
    if flag then
        if self.m_ready_time_anim then
            delete(self.m_ready_time_anim);
            self.m_ready_time_anim = nil;
        end
        local roomInfo = UserInfo.getInstance():getRoomInfo();
        if roomInfo then
            self.m_ready_time = roomInfo.again_time or 15;
            self.m_ready_time_anim = new(AnimInt,kAnimRepeat, 0, 1, 1000, -1);
            self.m_ready_time_anim:setDebugName("OnlineRoomScene.m_ready_time_anim");
            self.m_ready_time_anim:setEvent(self,self.onReadyTime);
        end
    end
end

OnlineRoomScene.onInvitNotify = function(self,packageInfo)
    local ctype = UserInfo.getInstance():canAccessRoom(5);
    if ctype ~= 5 then
        local post_data = {};
        post_data.uid = packageInfo.uid;
        post_data.ret = 1;
        self:sendSocketMsg(FRIEND_CMD_FRIEND_INVIT_RESPONSE,post_data,nil,1);
        return;
    end

    local friendData = FriendsData.getInstance():getUserData(packageInfo.uid);

    --根据uid获取用户名和头像
    require("dialog/friend_chioce_dialog");
    if not self.m_friendChoiceDialog then
        self.m_friendChoiceDialog = new(FriendChoiceDialog);
    end
    self.m_friendChoiceDialog:setMode(1,friendData,packageInfo.time_out);
    self.m_friendChoiceDialog:setPositiveListener(self,
        function()
            UserInfo.getInstance():setTid(packageInfo.tid);
            UserInfo.getInstance():setGameType(10);       --测试跳转到好友房
            UserInfo.getInstance():setMoneyType(5); 
            local post_data = {};
            post_data.uid = packageInfo.uid;
            post_data.ret = 0;
            UserInfo.getInstance():setChallenger(false);
            ChessDialogManager.dismissAllDialog();
            self:requestCtrlCmd(OnlineRoomController.s_cmds.invit_response, post_data);
            self:clearDialog();                          
            self:resume(); end);
    self.m_friendChoiceDialog:setNegativeListener(self,
        function()
            local post_data = {};
            post_data.uid = packageInfo.uid;
            post_data.ret = 1;
            self:requestCtrlCmd(OnlineRoomController.s_cmds.invit_response, post_data);    
            end);
    self.m_friendChoiceDialog:show();
end

OnlineRoomScene.onReadyTime = function(self)
    if self.m_ready_time and self.m_ready_time > 0 then
        self.m_ready_time = self.m_ready_time - 1;
    else
        if self.m_ready_time_anim then
            delete(self.m_ready_time_anim);
            self.m_ready_time_anim = nil;
        end
    end
end

OnlineRoomScene.onSetTimeDisagree = function(self)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.set_time_response, false);
end

OnlineRoomScene.onSetTimeAgree = function(self)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.set_time_response, true);
end

OnlineRoomScene.onMatchSuccess = function(self)
    self.m_down_user_start_btn:setVisible(true);
end

OnlineRoomScene.gameClose = function(self,flag,endType)

	self.m_game_over = true;
    self.m_game_start = false;
	print_string("结束类型动画 。。" .. endType);
	RoomHomeScroll.close();

	self.m_showAccount = true;    --显示结束动画的时候，不能显示开始按钮 
	--[[
	ENDTYPE_KILL = 1;   --1 将死
	ENDTYPE_DRAW = 2;   --2 和棋
	ENDTYPE_SURRENDER = 3;--3认输
	ENDTYPE_TIMEOUT = 4;  --4超时
	ENDTYPE_LEAVE = 5;  --5逃跑
	ENDTYPE_JAM = 6;    --6困毙]]
	self:game_close_dismiss_dialogs();  -- 游戏结束，关闭弹出框 
	
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
		self:showAccount();
	elseif endType == ENDTYPE_UNLEGAL then
		local message = "长打作负!!!";
		ChatMessageAnim.play(self.m_root_view,3,message);
		self:showAccount();
	elseif endType == ENDTYPE_UNCHANGE then
		local message = "双方不变作和!!!";
		ChatMessageAnim.play(self.m_root_view,3,message);
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

OnlineRoomScene.showAccount = function(self)
    self:setEnableUndo(false);
    self.isUndoAble = false;
	local gametype = UserInfo.getInstance():getGameType();
	if gametype == GAME_TYPE_WATCH then
		self:showWatchClose();
		return;
	end

	if not self.m_account_dialog then
		self.m_account_dialog = new(AccountDialog,self);
	end
    if not self.m_again_btn_timeout then
        self.m_again_btn_timeout = 9;
    end
	self.m_account_dialog:show(self,self.m_game_over_flag,self.m_again_btn_timeout-2);
	
	self.m_showAccount = false;
end


OnlineRoomScene.saveChess = function(self)
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
		local message = "保存成功！";
--		ShowMessageAnim.play(self.m_account_dialog,message);
        ChessToastManager.getInstance():showSingle(message); 
        return true;
	else
		local message = "本地棋库已达到"..UserInfo.getInstance():getSaveChessLimit().."条上限，您可以覆盖原棋谱保存新的棋谱，请问是否要继续保存新棋谱？";
        local gametype = UserInfo.getInstance():getGameType();
	    if gametype == GAME_TYPE_CUSTOMROOM  then
            message = message.."（继续保存会退出当前房间）";
        end
		self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE);
        self.m_chioce_dialog:setLevel(1);
		self.m_chioce_dialog:setMessage(message);
		self.m_chioce_dialog:setNegativeListener(self,self.cancelSaveMVList);
		self.m_chioce_dialog:setPositiveListener(self,self.toDapuPage);
		self.m_chioce_dialog:show();
        return false;
	end

end


OnlineRoomScene.toDapuPage = function(self)
	local gametype = UserInfo.getInstance():getGameType();
	if gametype == GAME_TYPE_CUSTOMROOM  then
        self.m_customRoomExit = true;
    end
    ToolKit.removeAllTipsDialog(); 
    self:clearDialog();
	StateMachine.getInstance():pushState(States.dapu,StateMachine.STYPE_LEFT_IN);
end

OnlineRoomScene.cancelSaveMVList = function(self)
	UserInfo.getInstance():setDapuDataNeedToSave(nil);
end



OnlineRoomScene.buyDapu = function(self,pos)
	self.m_payInterface = PayUtil.getPayInstance(PayUtil.s_payType.Exchange);
	self.m_payInterface:buy(nil,pos);
end


OnlineRoomScene.saveChessData = function(self)
	local uid = UserInfo.getInstance():getUid();
	local keys = GameCacheData.getInstance():getString(GameCacheData.DAPU_KEY .. uid,"");
	local keys_table = lua_string_split(keys, GameCacheData.chess_data_key_split);
	
	local index = 0;
	if keys == "" or keys == GameCacheData.NULL then
		index = 1;
	else
		while index <= UserInfo.getInstance():getSaveChessLimit() do
			index = index + 1;
			if keys_table[index] == nil or keys_table[index] == GameCacheData.NULL then
				break;
			end
		end
	end
	local key = "myChessDataId_"..index;
	if keys == "" or keys == GameCacheData.NULL then
		keys_table = {};
	end
	keys_table[index] = key;
	
	local relt;
	if self.m_game_over_flag == 0 then
		relt = "和棋";
	elseif self.m_game_over_flag == self.m_downUser:getFlag() then
		relt = "获胜";
	else
		relt = "败北";
	end

	local mvData = {};
	mvData.fileName = "我的棋谱"..index;
	mvData.time = os.date("%Y", os.time()).."-"..os.date("%m", os.time()).."-"..os.date("%d", os.time());
	mvData.result = relt;
	mvData.rival = GameString.convert2UTF8("对手:")..GameString.convert2UTF8(self.m_upUser:getName());
	mvData.flag = self.m_downUser:getFlag();
	mvData.upSex = self.m_upUser:getSex();
	mvData.downSex = self.m_downUser:getSex();
	mvData.m_game_end_type = self.m_game_end_type;
	mvData.mvStr = table.concat(self.m_board:to_mvList(),GameCacheData.chess_data_key_split);
	mvData.fenStr = GameCacheData.getInstance():getString(GameCacheData.DAPU_LAST_BORAD_FEN,GameCacheData.NULL);
	mvData.chessString = GameCacheData.getInstance():getString(GameCacheData.DAPU_LAST_CHESS_STR,GameCacheData.NULL);
	
	local mvData_str = json.encode(mvData);

	if index > UserInfo.getInstance():getSaveChessLimit() then
		UserInfo.getInstance():setDapuDataNeedToSave(mvData);
		return false;	--提示覆盖
	end

	print_string("mvData_str = " .. mvData_str);
	GameCacheData.getInstance():saveString(GameCacheData.DAPU_KEY .. uid,table.concat(keys_table,GameCacheData.chess_data_key_split));
	GameCacheData.getInstance():saveString(key .. uid,mvData_str);
	
	GameCacheData.getInstance():saveString(GameCacheData.DAPU_LAST_BORAD_FEN,GameCacheData.NULL);
	GameCacheData.getInstance():saveString(GameCacheData.DAPU_LAST_CHESS_STR,GameCacheData.NULL);
	return true;	--保存成功
end

OnlineRoomScene.showWatchClose = function(self)
	--0 和棋 1 红方胜利  2 黑方胜利

	local reson_pre = "";
	local result = "双方和棋";
	if self.m_game_over_flag == 1 then
		result = "红方胜利";
		reson_pre = "黑方"
	elseif self.m_game_over_flag == 2 then
		result = "黑方胜利";
		reson_pre = "红方"
	end


	--[[
	ENDTYPE_KILL = 1;   --1 将死
	ENDTYPE_DRAW = 2;   --2 和棋
	ENDTYPE_SURRENDER = 3;--3认输
	ENDTYPE_TIMEOUT = 4;  --4超时
	ENDTYPE_LEAVE = 5;  --5逃跑
	ENDTYPE_JAM = 6;    --6困毙]]
	local endType =	self.m_game_end_type;
	local reason  = "";
	if endType == ENDTYPE_KILL then
		reason  = string.format("(绝杀%s)",reson_pre);
	elseif  endType == ENDTYPE_TIMEOUT and ENDTYPE_OFFLINE_TIMEOUT == endType then
		reason  = string.format("(%s超时)",reson_pre);
	elseif endType == ENDTYPE_JAM then
		reason  = string.format("(%s困毙)",reson_pre);
	elseif endType == ENDTYPE_SURRENDER then
		reason  = string.format("(%s认输)",reson_pre);
	elseif endType == ENDTYPE_LEAVE then
		reason  = string.format("(%s逃跑)",reson_pre);
	end

	local message = result .. reason;
--	ShowMessageAnim.play(self.m_root_view,message);
    ChessToastManager.getInstance():showSingle(message); 

end



OnlineRoomScene.onWatcherChatMsg = function(self, data)
    if data.uid ~= UserInfo.getInstance():getUid() then
        self:showWatchChat(data.name,data.msgType,data.message);
    end;
end;

OnlineRoomScene.onWatchRoomPlayerChatMsg = function(self, data)
	if self.m_upUser and data.uid == self.m_upUser:getUid() then
		self:showUpChat(data.msgType,data.message);
	elseif self.m_downUser and data.uid == self.m_downUser:getUid() then
		self:showDownChat(data.msgType,data.message);
	end

end;

OnlineRoomScene.onWatchRoomDraw = function(self, data)
	if  self.m_downUser and self.m_downUser:getUid() == data.uid then
        ChatMessageAnim.play(self.m_root_view,3,self.m_downUser:getName().." 和棋申请成功");
	elseif self.m_upUser and self.m_upUser:getUid() == data.uid then
        ChatMessageAnim.play(self.m_root_view,3,self.m_upUser:getName().." 和棋申请成功");
	end
end;


OnlineRoomScene.onWatchRoomSurrender = function(self, data)
	if  self.m_downUser and self.m_downUser:getUid() == data.uid then
        ChatMessageAnim.play(self.m_root_view,3,self.m_downUser:getName().." 认输");
	elseif self.m_upUser and self.m_upUser:getUid() == data.uid then
        ChatMessageAnim.play(self.m_root_view,3,self.m_upUser:getName().." 认输");
	end

end;

OnlineRoomScene.onWatchRoomUndo = function(self, data)
	self:setStatus(data.status);
	if  self.m_downUser and self.m_downUser:getUid() == data.undo_uid then
        ChatMessageAnim.play(self.m_root_view,3,self.m_downUser:getName().." 悔棋一步");
	elseif self.m_upUser and self.m_upUser:getUid() == data.undo_uid then
        ChatMessageAnim.play(self.m_root_view,3,self.m_upUser:getName().." 悔棋一步");
	end
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

end;
OnlineRoomScene.resPonseUndoMove = function(self,data)   --展示悔棋结果
	print_string("对手悔棋");

	self.m_board:severUndoMove(data);

	if UserInfo.getInstance():getUid() == self.OpponentID then
		self.m_downUser:setTimeout2(self.m_timeout2);
		if self.m_timeout2 then
			self.m_down_timeout2_text:setText(self.m_downUser:getTimeout2());
		end
		local message = "由于对方使用强制悔棋你将获得"..self.GetCoin.."金币的补偿";
		ChatMessageAnim.play(self.m_root_view,3,message);
		self:resPonseUndoMoveSure();
	else
		self.m_upUser:setTimeout2(self.m_timeout2);
		if self.m_timeout2 then
			self.m_up_timeout2_text:setText(self.m_upUser:getTimeout2());
		end
	end

end

OnlineRoomScene.resPonseUndoMoveSure = function(self)   --展示悔棋结果
	local money = UserInfo.getInstance():getMoney() + self.GetCoin;
	UserInfo.getInstance():setMoney(money) ;
end

OnlineRoomScene.onWatchRoomWaring = function(self,data)
	if data and data.type then

		if data.type == -1 then
			local message = "观战服务器关闭所有观战人员离开";
			print_string("观战服务器关闭所有观战人员离开");
			self:loginFail(message);
	
		end
	else
		print_string("Room.watchTipsEvent = function(self,data) but bad args !");
	end
end

OnlineRoomScene.onWatchRoomUpdateTable = function(self,data)
	if data and data.status then
        self:setStatus(data.status,data.curr_op_uid);
    end
end

OnlineRoomScene.sendChat = function(self,msgType,message)
    if lua_multi_click(3) then
		local message = "亲，请喝口水休息一会再说吧。"
		ChatMessageAnim.play(self.m_root_view,3,message);
		return;
	end
	local game_type = UserInfo.getInstance():getGameType();
	if game_type == GAME_TYPE_COMPUTER then
		print_string("Room.showDownChat but self:getGameType() == GAME_TYPE_COMPUTER");
		return
	end

	if not self.m_downUser then
		print_string("Room.showDownChat but not self.m_downUser");
		return;
	end

	if not self.m_upUser or not self.m_up_user_icon:getVisible() then  -- 没有对手不让发聊天信息
		print_string("Room.showDownChat but not self.m_upUser");
		return;
	end

	if 	game_type == GAME_TYPE_WATCH then
		print_string("Room.showDownChat but GAME_TYPE_WATCH");
		return
	end

    self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_chat, message);
end

OnlineRoomScene.showDownChat = function(self,msgType,message)
	ChatMessageAnim.play(self.m_root_view,1,message);
	kEffectPlayer:playChat(self.m_downUser:getSex(),EffectsPhrases[message]);
	self.m_chat_dialog:addChatLog(self.m_downUser:getName(),message);
end

OnlineRoomScene.showUpChat = function(self,msgType,message)

	if not self.m_upUser then
		print_string("Room.showUpChat but not self.m_upUser");
		return;
	end

	if not message or message == "" then
		return;
	end

	ChatMessageAnim.play(self.m_root_view,2,message);

	kEffectPlayer:playChat(self.m_upUser:getSex(),EffectsPhrases[message]);

	self.m_chat_dialog:addChatLog(self.m_upUser:getName(),message);

end


OnlineRoomScene.showWatchChat = function(self,name,msgType,message)

	if not message or message == "" then
		return;
	end
	local msg = string.format("%s:%s",name,message);
	self.m_room_menu_chat_text:setText(msg);
	self.m_watch_chat_log_dialog:addChatLog(name,message);
	self.m_chat_dialog:addChatLog(name,message);

end

OnlineRoomScene.watchUserLeave = function(self,leaveUid)
	self:stopTimeout();

	self:game_close_dismiss_dialogs();
    if self.m_downUser then
	    if  self.m_downUser:getUid() == leaveUid then
		    self.m_down_user_ready_img:setVisible(false);
		    self.m_down_user_icon:setVisible(false);  ---表现形式将对走离开
	    else
		    self.m_up_user_ready_img:setVisible(false);
		    self.m_up_user_icon:setVisible(false);  ---表现形式将对走离开
	    end
    end;
	local message = "棋手离开，所有观战人员离场";
	self:loginFail(message);
end

OnlineRoomScene.game_close_dismiss_dialogs = function(self)

	print_string("OnlineRoomScene.game_close_dismiss_dialogs ");


	if self.m_chioce_dialog and self.m_chioce_dialog:isShowing() then
		print_string("self.m_chioce_dialog is showing ");
		self.m_chioce_dialog:dismiss();
	end


	if self.m_chat_dialog and self.m_chat_dialog:isShowing() then
		print_string("self.m_chat_dialog is showing ");
		self.m_chat_dialog:dismiss();
	end


	if self.m_timeset_dialog and self.m_timeset_dialog:isShowing() then
		print_string("self.m_timeset_dialog is showing ");
		self.m_timeset_dialog:dismiss();
	end

	if self.m_setting_dialog and self.m_setting_dialog:isShowing() then
		print_string("self.m_timeset_dialog is showing ");
		self.m_setting_dialog:dismiss();

	end

	if self.m_board_menu_dialog and self.m_board_menu_dialog:isShowing() then
		print_string("self.m_board_menu_dialog is showing ");
		self.m_board_menu_dialog:dismiss();
	end


	if self.m_handicap_dialog and self.m_handicap_dialog:isShowing() then
		print_string("self.m_handicap_dialog is showing ");
		self.m_handicap_dialog:dismiss();	
	end

	if self.m_forestall_dialog and self.m_forestall_dialog:isShowing() then
		print_string("self.m_handicap_dialog is showing ");
		self.m_forestall_dialog:dismiss();	
	end

    if self.m_forestall_dialog_new and self.m_forestall_dialog_new:isShowing() then
		print_string("self.m_handicap_dialog is showing ");
		self.m_forestall_dialog_new:dismiss();	
	end
--	self:dismissLoadingDialog();



	-- if self.m_account_dialog and self.m_account_dialog:isShowing() then
	-- 	print_string("self.m_account_dialog is showing ");
	-- 	self.m_account_dialog:dismiss();
	-- end


end


OnlineRoomScene.loginFail = function(self,message)

	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end

	self.m_chioce_dialog:setMode(ChioceDialog.MODE_OK);
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:setPositiveListener(self,self.exitRoom);
	self.m_chioce_dialog:show();

end
OnlineRoomScene.onExitRoom = function(self)
    self:back_action();
end;



OnlineRoomScene.back_action = function(self)
	print_string("Room.back_action gametype = " .. self.m_gametype);

--	if not self:dissmissDialogs() then
--		print_string("some dialog can't dismiss");
--		return;
--	end

	local gametype = UserInfo.getInstance():getGameType(); --用户的游戏模式
	if gametype <= GAME_TYPE_TWENTY  then
		self:onLineBack();
	elseif gametype == GAME_TYPE_WATCH then
		self:onWatchBack();
	elseif gametype == GAME_TYPE_CUSTOMROOM then
		self:onCustomBack();
	elseif gametype == GAME_TYPE_FRIEND then
        self:onFriendBack();
    else
		self:onLineBack();
	end
end


OnlineRoomScene.onWatchBack = function(self)
	print_string("Room.onWatchBack");
	self:exitRoom();
end

OnlineRoomScene.onForceLeave = function(self,message)
    if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end
    self:clearDialog();
    self.m_chioce_dialog:setMessage(message or "棋局结束，请退出房间!");
    self.m_chioce_dialog:setMode();
    self.m_chioce_dialog:setPositiveListener(self,self.exitRoom);
    self.m_chioce_dialog:show();
end

OnlineRoomScene.onInvitFail = function(self,data)
    require("dialog/friend_chioce_dialog");
    if data and data.ret == 0 then
        if self.m_invit_time_anim then
            delete(self.m_invit_time_anim);
            self.m_invit_time_anim = nil;
        end
        self.m_invit_time_anim_time = (data.time_out or 20)*1000;
        self.m_invit_time_anim = new(AnimInt,kAnimRepeat, 0, 1, self.m_invit_time_anim_time, -1);
        self.m_invit_time_anim:setDebugName("OnlineRoomScene.m_invit_time_anim");
        self.m_invit_time_anim:setEvent(self,self.onInvitFailBack);
    elseif data and data.ret == 1 then
        self:clearDialog();
        local friendData = FriendsData.getInstance():getUserData(data.target_uid);
        self.m_friendChoiceDialog = new(FriendChoiceDialog);
        if data and data.target_tid ~= 0 and data.target_hallid ~= 0 then
            self.m_friendChoiceDialog:setMode(2,friendData);
            self.m_friendChoiceDialog:setPositiveListener(self,
                function()         
                    UserInfo.getInstance():setTid(data.target_tid);  --转到好友观战
                    UserInfo.getInstance():setGameType(GAME_TYPE_WATCH);                    
                    self:resume(); end);
            self.m_friendChoiceDialog:setNegativeListener(self,
                function()
                    self:exitRoom();
                    end);
        else
            self.m_friendChoiceDialog:setMode(4,friendData);
            self.m_friendChoiceDialog:setPositiveListener(self,
                function()         
                    self:exitRoom();
                    end);
            self.m_friendChoiceDialog:setNegativeListener(self,
                function()
                    self:exitRoom();
                    end);
        end
        self.m_friendChoiceDialog:show();
    end
end

OnlineRoomScene.onUpdateUserInfoDialog = function(self,info)
    if self.m_up_user_info_dialog and self.m_up_user_info_dialog:isShowing() then
        self.m_up_user_info_dialog:update(info)
    end
    if self.m_down_user_info_dialog and self.m_down_user_info_dialog:isShowing() then
        self.m_down_user_info_dialog:update(info)
    end
end


OnlineRoomScene.onFriendBack = function(self)
	print_string("Room.onFriendBack");
	local message = "亲，中途离开则会输掉棋局哦！"
	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end
    if self.m_downUser and not self.m_game_start then
        message = "您确定离开吗？"
        self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE,"退出","取消");
        self.m_chioce_dialog:setPositiveListener(self,self.exitRoom);
    elseif self.m_downUser then
        self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE,"认输退出","取消");
        self.m_chioce_dialog:setPositiveListener(self,self.surrender_sure);
    else
        self.m_chioce_dialog:setPositiveListener(self,self.exitRoom);
    end
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:setNegativeListener(nil,nil);
	self.m_chioce_dialog:show();
end

OnlineRoomScene.onLineBack = function(self)
	local message = "亲，中途离开则会输掉棋局哦！"
	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end
    if self.m_downUser and not self.m_game_start then
        message = "您确定离开吗？"
        self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE,"退出","取消");
        self.m_chioce_dialog:setPositiveListener(self,self.exitRoom);
    elseif self.m_downUser then
        self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE,"认输退出","取消");
        self.m_chioce_dialog:setPositiveListener(self,self.surrender_sure);
    else
        self.m_chioce_dialog:setPositiveListener(self,self.exitRoom);
    end
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:setNegativeListener(nil,nil);
	self.m_chioce_dialog:show();
end

OnlineRoomScene.onCustomBack = function(self)
    local message = "亲，中途离开则会输掉棋局哦！"
    if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end
    if self.m_downUser and not self.m_game_start then
        message = "您确定离开吗？"
        self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE,"退出","取消");
        self.m_chioce_dialog:setPositiveListener(self,self.exitRoom);
    elseif self.m_downUser then
        self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE,"认输退出","取消");
        self.m_chioce_dialog:setPositiveListener(self,self.surrender_sure);
    else
        self.m_chioce_dialog:setPositiveListener(self,self.exitRoom);
    end
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:setNegativeListener(nil,nil);
	self.m_chioce_dialog:show();
end

OnlineRoomScene.onInvitFailBack = function(self)
    self:onDeleteInvitAnim();
    local message = "对方无响应，即将离开房间！"
    if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end
    self.m_chioce_dialog:setMode();
    self.m_chioce_dialog:setPositiveListener(self,self.exitRoom);
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:setNegativeListener(self,self.exitRoom);
	self.m_chioce_dialog:show();
end

OnlineRoomScene.onDeleteInvitAnim = function(self)
    if self.m_invit_time_anim then
        delete(self.m_invit_time_anim);
        self.m_invit_time_anim = nil;
    end
end

OnlineRoomScene.showSelectPlayerDialog = function(self)
    if self.m_room_select_player_dialog and not self.m_room_select_player_dialog:isShowing() then
        self.m_room_select_player_dialog:show();
    end;
end;

OnlineRoomScene.hideSelectPlayerDialog = function(self)
    if self.m_room_select_player_dialog and self.m_room_select_player_dialog:isShowing() then
        self.m_room_select_player_dialog:dismiss(false);
    end;

end;

OnlineRoomScene.exitRoom = function(self)
	--print_string("self.m_downUser:getStatus() = " .. self.m_downUser:getStatus());
	print_string("Room.exitRoom gametype = " .. self.m_gametype);
    UserInfo.getInstance():setChallenger(nil);
	OnlineConfig.deleteTimer(self); 
    self.m_board_menu_dialog:dismiss();
    self.m_connectCount = 0;
--    self:unregisterSinalReceiver();
	UserInfo.getInstance():setRelogin(false) 

	if self.m_inputPwdDialog~= nil then
	   self.m_inputPwdDialog:dismiss();
	   self.m_inputPwdDialog = nil;
    end

	local gametype = UserInfo.getInstance():getGameType();
	if gametype == GAME_TYPE_COMPUTER then

		self.m_board:stopThink();

	elseif gametype <= GAME_TYPE_TWENTY  then
        if self.m_login_succ then
            self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_logout);
            return;
        end;
	elseif gametype == GAME_TYPE_CUSTOMROOM then
		if self.m_login_succ then
            self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_logout);
            return;
		end
    elseif gametype == GAME_TYPE_FRIEND then
		if self.m_login_succ then
            self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_logout);
            return;
		end
	elseif gametype == GAME_TYPE_WATCH then
        self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_logout);
	end
    self:clearRoomInfo();

end;

OnlineRoomScene.onServerMsgLogoutSucc = function(self)
    self:clearRoomInfo();
end;

OnlineRoomScene.clearRoomInfo = function(self)
    delete(self.m_watch_chat_log_dialog);
    delete(self.m_up_user_info_dialog);
    delete(self.m_down_user_info_dialog);
    delete(self.m_board_menu_dialog);
    delete(self.m_timeset_dialog);
    delete(self.m_chat_dialog);
    delete(self.m_match_dialog);
    delete(self.m_chioce_dialog);
    delete(self.m_setting_dialog);
    delete(self.m_timeoutAnim);
    delete(self.m_account_dialog);
    delete(self.m_forestall_dialog);
    delete(self.m_forestall_dialog_new);
    delete(self.m_loading_dialog);
    delete(self.m_inputPwdDialog);
    delete(self.m_handicap_dialog);
    delete(self.m_online_box_dialog);
    delete(self.m_room_select_player_dialog);
    delete(self.m_timeAnim);
    delete(self.m_roomFriend);
    delete(self.m_roomFriendShow);
    delete(self.m_friendChoiceDialog);
	UserInfo.getInstance():setTid(0);
	UserInfo.getInstance():setSeatID(0);
	UserInfo.getInstance():setGameType(GAME_TYPE_UNKNOW);
	UserInfo.getInstance():setStatus(STATUS_PLAYER_LOGOUT);
	self:stopTimeout();
	self:stopTime();
	ToolKit.removeAllTipsDialog(); 
	self:clearDialog(); 
    if self.m_upUser then
        self:userLeave(self.m_upUser:getUid());  
    end;
    self.m_board:dismissChess();
    self.m_multiple_text:setText("1");
    self:requestCtrlCmd(OnlineRoomController.s_cmds.back_action);

end;
OnlineRoomScene.clearDialog = function(self)

	if self.m_match_dialog and self.m_match_dialog:isShowing() then
		print_string("match room cant't cancel");
		self.m_match_dialog:dismiss();
	end

--	if self.m_account_dialog and self.m_account_dialog:isShowing() then
--		print_string("self.m_account_dialog is showing ");
--		self.m_account_dialog:onCancel();
--	end

	if self.m_chioce_dialog and self.m_chioce_dialog:isShowing() then
		print_string("self.m_chioce_dialog is showing ");
		self.m_chioce_dialog:dismiss();
	end


	if self.m_chat_dialog and self.m_chat_dialog:isShowing() then
		print_string("self.m_chat_dialog is showing ");
		self.m_chat_dialog:dismiss();
	end


	if self.m_timeset_dialog and self.m_timeset_dialog:isShowing() then
		print_string("self.m_timeset_dialog is showing ");
		self.m_chioce_dialog:dismiss();
	end

	if self.m_setting_dialog and self.m_setting_dialog:isShowing() then
		print_string("self.m_timeset_dialog is showing ");
		self.m_setting_dialog:dismiss();
	end

	if self.m_board_menu_dialog and self.m_board_menu_dialog:isShowing() then
		print_string("self.m_board_menu_dialog is showing ");
		self.m_board_menu_dialog:dismiss();
	end

	if self.m_handicap_dialog and self.m_timeset_dialog:isShowing() then
		print_string("self.m_handicap_dialog is showing ");
		self.m_handicap_dialog:dismiss();
	end

	if self.m_forestall_dialog and self.m_forestall_dialog:isShowing() then
		print_string("self.m_handicap_dialog is showing ");
		self.m_forestall_dialog:dismiss();
	end

    if self.m_forestall_dialog_new and self.m_forestall_dialog_new:isShowing() then
		print_string("self.m_handicap_dialog is showing ");
		self.m_forestall_dialog_new:dismiss();
	end

    if self.m_loading_dialog and self.m_loading_dialog:isShowing() then
		self.m_loading_dialog:dismiss();
	end

    if self.m_roomFriend and self.m_roomFriend:isShowing() then
        self.m_roomFriend:dismiss();
    end

    if self.m_roomFriendShow and self.m_roomFriendShow:isShowing() then
        self.m_roomFriendShow:dismiss();
    end

    if self.m_friendChoiceDialog and self.m_friendChoiceDialog:isShowing() then
        self.m_friendChoiceDialog:dismiss();
    end
end


OnlineRoomScene.onMatchRoomSucc = function(self)

    self:matchSuccess();

end;

OnlineRoomScene.onMatchRoomFail = function(self)
    
    self:matchFail();

end;
OnlineRoomScene.matchSuccess = function(self)
	print_string("匹配成功");
	if self.m_match_dialog then
	    self.m_match_dialog:dismiss();
	end
end


OnlineRoomScene.matchFail = function(self,message)
	print_string("匹配失败");
	-- self:setStartReadyVisible();
	self.m_down_user_start_btn:setVisible(true);

	local message = "匹配失败,请您稍候再试!!!"
	if self.m_match_dialog then
		self.m_match_dialog:dismiss();
	end

	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end

	self.m_chioce_dialog:setMode(ChioceDialog.MODE_OK);
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:setPositiveListener();
	self.m_chioce_dialog:show();

end
OnlineRoomScene.onClientUserLoginSucc = function(self, data)
    self.m_login_succ = true;
    if data.user then
        self:upComeIn(data.user);
    end;
    self:downComeIn(UserInfo.getInstance());
end;
OnlineRoomScene.onClientUserLoginError = function(self, data)
   
    if data.errorCode == 5 then
        ChessToastManager.getInstance():showSingle("棋桌不存在"); 
    elseif data.errorCode == 7 then
        ChessToastManager.getInstance():showSingle("棋桌已满"); 
    elseif data.errorCode == 9 then
        ChessToastManager.getInstance():showSingle("金币不足"); 
    elseif data.errorCode == 10 then
        ChessToastManager.getInstance():showSingle("金币超出上限"); 
    else
        ChessToastManager.getInstance():showSingle("请重新匹配"); 
    end;
    self:exitRoom();

end;

OnlineRoomScene.onClientUserOtherError = function(self, data)
    ChessToastManager.getInstance():showSingle("登录错误");
    self:exitRoom();
end;


OnlineRoomScene.onClientOppUserLogin = function(self, data)
    if data.user then
        self:upComeIn(data.user);
    end;
end;





OnlineRoomScene.onServerMsgReady = function(self, data)
    if data.uid == UserInfo.getInstance():getUid() then
	    self.m_down_user_ready_img:setVisible(true);
    else
        self.m_up_user_ready_img:setVisible(true);
    end;
end;

OnlineRoomScene.onServerMsgTimecountStart = function(self, data)
    
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
    self.m_multiple_text:setText(data.multiply);
    self:clearDialog();
    self:startGame(data.chess_map);
    self.m_game_start = true;
end;


OnlineRoomScene.onServerMsgReconnect = function(self, data)
    if not data then
        return;
    end;
    self.m_login_succ = true;--断线重连进来设置为true,否则登出房间时不会发logout命令
--    self.ForceUndoMove = ForceUndoMove;
--	self.Undomovenum = Undomovenum;
	self.m_timeout1 = data.round_time;
	self.m_timeout2 = data.step_time;
	self.m_timeout3 = data.sec_time;
    if data.status == 2 then--2代表正在游戏
        self.m_game_start = true;
        self.m_move_flag = data.first_flag;
        if self.m_move_flag == FLAG_RED then
            self.m_red_turn = true;
        else
            self.m_red_turn = false;
        end;
	    UserInfo.getInstance():setFlag(data.flag) ;
	    UserInfo.getInstance():setTimeout1((self.m_timeout1 - data.round_timeout));
	    UserInfo.getInstance():setTimeout2(data.step_timeout);
	    UserInfo.getInstance():setTimeout3(data.sec_timeout);
	    UserInfo.getInstance():setMoney(data.coin);
        UserInfo.getInstance():setMultiply(data.multiply);

        self:downComeIn(UserInfo.getInstance());
        --Client_msg_syn同步数据没有同步client_version字段，兼容加上，以后server重构修改
        if self.m_upUser then
            data.user:setClient_version(self.m_upUser:getClient_version());
        end;
        self:upComeIn(data.user,true);  

	    local last_move = {}
	    last_move.moveChess = data.chessMan;
	    last_move.moveFrom = 91 -data.position1;
	    last_move.moveTo = 91 - data.position2;
	    self:synchroData(data.chess_map,last_move);
    elseif data.status == 3 or data.status == 4 then
        UserInfo.getInstance():setTimeout1(self.m_timeout1);
	    UserInfo.getInstance():setTimeout2(self.m_timeout2);
	    UserInfo.getInstance():setTimeout3(self.m_timeout3);
        self:downComeIn(UserInfo.getInstance());
        --Client_msg_syn同步数据没有同步client_version字段，兼容加上，以后server重构修改
        if self.m_upUser then
            data.user:setClient_version(self.m_upUser:getClient_version());
        end;
        self:upComeIn(data.user,true);  
    else
        self.m_game_start = false;
    end;
    self:setStatus(data.status);
    self:hideSelectPlayerDialog();


    --同步完棋盘后获取观战人数
--    self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_watchlist);
--	print_string("======服务器回应房间CLIENT_MSG_SYNCHRODATA处理成功======");
	
    self:requestCtrlCmd(OnlineRoomController.s_cmds.client_get_openbox_time);
    



end;




OnlineRoomScene.onClientUserComein = function(self, data)
--    if data.user then
--        self:upComeIn(data.user);
--    end;
--    self:setGameType(data.gameType);
--	self.m_tid = data.tableID;
--	self:setStatus(data.tableStatus) ;
--	self:downComeIn(UserInfo.getInstance(),true);
--	self:setStartReadyVisible();

end;

OnlineRoomScene.onClientMsgStart = function(self, data)

--    if(data.errorCode == 0) then
--		if self.m_tid == data.tableID then
--			self:setStatus(data.tableStatus);			
--			if  self.m_downUser:getUid() == data.player1ID then
--				self.m_downUser:setStatus(data.player1Status);
--				if self.m_upUser then
--					self.m_upUser:setStatus(data.player2Status);
--				end
--			else
--				self.m_downUser:setStatus(data.player2Status);
--				if self.m_upUser then
--					self.m_upUser:setStatus(data.player1Status);
--				end
--			end

--			self:setStartReadyVisible();
--		else
--			print_string("返回棋桌与当前棋桌不相符");
--		end
--	else
--		print_string("CLIENT_MSG_START errorCode ~= 0");
--	end
-- 	print_string("errorCode:" .. data.errorCode );
--	print_string("errorMsg:" .. data.errorMsg );
--	print_string("tableID:" .. data.tableID);
--	print_string("tableStatus:" .. data.tableStatus);
--	print_string("m_downUser.status = "..self.m_downUser:getStatus());
--	print_string("======服务器回应房间CLIENT_MSG_START处理成功======");
--	self.Undomovenum = 0;
--	self.isUseLeftUndo = false;   
end;


OnlineRoomScene.onClientMsgForestall = function(self, data)

--    self:forestallEvent(data)

end;

OnlineRoomScene.forestallEvent = function(self,data)

    self:clearDialog();
	if not self.m_forestall_dialog then
		self.m_forestall_dialog = new(ForestallDialog);
		self.m_forestall_dialog:setPositiveListener(self,self.agreeForestall);
		self.m_forestall_dialog:setNegativeListener(self,self.refuseForestall);
	end
	
	if data.curr_uid == self.m_downUser:getUid() then    --由我抢先
		self.m_forestall_dialog:show(data.timeout);
        if data.pre_call_uid == self.m_downUser:getUid() then
            local message = "抢先成功 倍数为  " .. data.multiply;
            self.m_multiple_text:setText(data.multiply);
            self:showLoadingDialog(message,data.timeout);
		    ForestallAnim.play(nil,true,data.multiply);
        elseif data.pre_call_uid == self.m_upUser:getUid() then
            ForestallAnim.play(nil,true,data.multiply);
            
        elseif data.pre_call_uid == 0 then

            
        end;
	elseif data.curr_uid == self.m_upUser:getUid() then  --等待对手抢先
        if data.pre_call_uid == self.m_downUser:getUid() then
            local message = "抢先成功 倍数为  " .. data.multiply;
            self.m_multiple_text:setText(data.multiply);
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
        self.m_multiple_text:setText(data.multiply);
    end
end

OnlineRoomScene.agreeForestall = function(self)
--    self.m_forestall = true;
    self:requestCtrlCmd(OnlineRoomController.s_cmds.server_msg_forestall ,1);
end

OnlineRoomScene.refuseForestall = function(self)
--    self.m_forestall = false;
    self:requestCtrlCmd(OnlineRoomController.s_cmds.server_msg_forestall ,0);
end

OnlineRoomScene.forestallEventNew = function(self,data)
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
            local message = "抢先成功 倍数为  " .. data.curr_beishu;
            self.m_multiple_text:setText(data.curr_beishu);
            self:showLoadingDialog(message,data.timeout);
		    ForestallAnim.play(self.m_root_view,true,data.curr_beishu);
        elseif data.pre_call_uid == self.m_upUser:getUid() then
            ForestallAnim.play(self.m_root_view,true,data.curr_beishu);
        elseif data.pre_call_uid == 0 then

        end;
	elseif data.curr_uid == self.m_upUser:getUid() then  --等待对手抢先
        if data.pre_call_uid == self.m_downUser:getUid() then
            local message = "抢先成功 倍数为  " .. data.curr_beishu;
            self.m_multiple_text:setText(data.curr_beishu);
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
        self.m_multiple_text:setText(data.curr_beishu);
    end
end

OnlineRoomScene.btn1Forestall = function(self,opt_beishu)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.server_msg_forestall_new ,opt_beishu);
end

OnlineRoomScene.btn2Forestall = function(self,opt_beishu)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.server_msg_forestall_new ,opt_beishu);
end

OnlineRoomScene.noForestall = function(self)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.server_msg_forestall_new ,0);
end

OnlineRoomScene.showLoadingDialog = function(self,message,time)
	if not self.m_loading_dialog then
		self.m_loading_dialog = new(LoadingDialog);
	end
	self.m_loading_dialog:setMessage(message);
	self.m_loading_dialog:show(time);
end


OnlineRoomScene.onClientMsgRelogin = function(self, data)
    
    self:relogin(data.errorCode);


end;
OnlineRoomScene.relogin = function(self,errorCode)
	print_string("Room.relogin");
	if(errorCode == 0) then
--		self:synchroRequest();
	elseif errorCode == -2 then
		local message = "棋局已经结束,进入棋桌失败！"

		self:loginFail(message);
		return;

	else
		local message = "进入棋桌失败！请检查网络后稍候再试!!!"
		self:loginFail(message);
		return;
	end

end


OnlineRoomScene.onClientMsgSyndata = function(self, data)
--    if not data then
--        return;
--    end;
--    self.ForceUndoMove = ForceUndoMove;
--	self.Undomovenum = Undomovenum;
--	self.m_timeout1 = data.timeOut1;
--	self.m_timeout2 = data.timeOut2;
--	self.m_timeout3 = data.timeOut3;

--	if data.mUserID  == UserInfo.getInstance():getUid() then  --本人ID是否相同？（有必要？）
--		UserInfo.getInstance():setTid(data.tableID) ;
--		UserInfo.getInstance():setSeatID(data.mSeatID) ;
--		UserInfo.getInstance():setStatus(data.mUserStatus);
--		UserInfo.getInstance():setFlag(data.mFlag) ;

--		UserInfo.getInstance():setTimeout1((self.m_timeout1 - data.timeOut11));
--		UserInfo.getInstance():setTimeout2(data.timeOut12);
--		UserInfo.getInstance():setTimeout3(data.timeOut13);
--		UserInfo.getInstance():setRank(data.rank1);

--		UserInfo.getInstance():setMoneyType(data.ctype);
--		UserInfo.getInstance():setMoney(data.coin1);
--        UserInfo.getInstance():setMultiply(data.multiply);
--	else
--		print_string(string.format("mUserID != userInfo.uid mUserID = %d,userInfo.uid = %d",data.mUserID,UserInfo.getInstance():getUid()));
--		return;
--	end
--	self:downComeIn(UserInfo.getInstance());
--	self.m_tid = data.tableID;
--    --Client_msg_syn同步数据没有同步client_version字段，兼容加上，以后server重构修改
--    if self.m_upUser then
--        data.user:setClient_version(self.m_upUser:getClient_version());
--    end;
--    self:upComeIn(data.user,true);  
--	self:setGameType(data.gameType);
--	self:setStatus(data.tableStatus) ;	
----	self:setStartReadyVisible();

--    local  userGameType  = UserInfo.getInstance():getGameType();
--	if userGameType ~= GAME_TYPE_CUSTOMROOM or (data.tableStatus ==2 or data.tableStatus ==3)  then
--		local last_move = {}
--		last_move.moveChess = data.chessMan;
--		last_move.moveFrom = 91 -data.position1;
--		last_move.moveTo = 91 - data.position2;
--		self:synchroData(data.chess_map,last_move);
--	end
--    --同步完棋盘后获取观战人数
----    self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_watchlist);
--	print_string("======服务器回应房间CLIENT_MSG_SYNCHRODATA处理成功======");

--    self:requestCtrlCmd(OnlineRoomController.s_cmds.client_get_openbox_time);




    if not data then
        return;
    end;
--    self.ForceUndoMove = ForceUndoMove;
--	self.Undomovenum = Undomovenum;
	self.m_timeout1 = data.round_time;
	self.m_timeout2 = data.step_time;
	self.m_timeout3 = data.sec_time;
    if data.status == 2 then--2代表正在游戏
        self.m_game_start = true;
        self.m_move_flag = data.first_flag;
        if self.m_move_flag == FLAG_RED then
            self.m_red_turn = true;
        else
            self.m_red_turn = false;
        end;
	    UserInfo.getInstance():setFlag(data.flag) ;
	    UserInfo.getInstance():setTimeout1((self.m_timeout1 - data.round_timeout));
	    UserInfo.getInstance():setTimeout2(data.step_timeout);
	    UserInfo.getInstance():setTimeout3(data.sec_timeout);
	    UserInfo.getInstance():setMoney(data.coin);
        UserInfo.getInstance():setMultiply(data.multiply);

        self:downComeIn(UserInfo.getInstance());
        --Client_msg_syn同步数据没有同步client_version字段，兼容加上，以后server重构修改
        if self.m_upUser then
            data.user:setClient_version(self.m_upUser:getClient_version());
        end;
        self:upComeIn(data.user,true);  

	    local last_move = {}
	    last_move.moveChess = data.chessMan;
	    last_move.moveFrom = 91 -data.position1;
	    last_move.moveTo = 91 - data.position2;
	    self:synchroData(data.chess_map,last_move);
    elseif data.status == 3 or data.status == 4 then
        UserInfo.getInstance():setTimeout1(self.m_timeout1);
	    UserInfo.getInstance():setTimeout2(self.m_timeout2);
	    UserInfo.getInstance():setTimeout3(self.m_timeout3);
        self:downComeIn(UserInfo.getInstance());
        --Client_msg_syn同步数据没有同步client_version字段，兼容加上，以后server重构修改
        if self.m_upUser then
            data.user:setClient_version(self.m_upUser:getClient_version());
        end;
        self:upComeIn(data.user,true);  
    else
        self.m_game_start = false;
    end;
    self:setStatus(data.status);
    self:hideSelectPlayerDialog();

    --同步完棋盘后获取观战人数
--    self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_watchlist);
--	print_string("======服务器回应房间CLIENT_MSG_SYNCHRODATA处理成功======");
	
    self:requestCtrlCmd(OnlineRoomController.s_cmds.client_get_openbox_time);

end;



OnlineRoomScene.onClientGetOpenboxTime = function(self, data)
    if data and data.flag == 1 then
	    self:show_reward_dlg("恭喜你获得："..data.msg) ;
	    local money = UserInfo:getInstance():getMoney();		
        self:requestCtrlCmd(OnlineRoomController.s_cmds.client_get_openbox_time,1, data.changeMoney);
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


OnlineRoomScene.onServerMsgUserLeave = function(self, data)
    self:userLeave(data.leave_uid);
    OnlineConfig.deleteTimer(); 

end;

OnlineRoomScene.onServerMsgForestall = function(self, data)
    self:forestallEvent(data)
end;

OnlineRoomScene.onServerMsgForestallNew = function(self, data)
    self:forestallEventNew(data)
end;

OnlineRoomScene.onServerMsgHandicap = function(self, data)
    self:handicapEvent(data)
end;
OnlineRoomScene.onServerMsgHandicapResult = function(self, data)
    self:dismissLoadingDialog();
    if data.result == 0 then--成功
		if data.chessId == R_ROOK1 or data.chessId == R_ROOK2 then
			kEffectPlayer:playEffect(Effects.AUDIO_HANDICAP_ROOK);
		elseif data.chessId == R_HORSE1 or data.chessId == R_HORSE2 then
			kEffectPlayer:playEffect(Effects.AUDIO_HANDICAP_HORSE);
		elseif data.chessId == R_CANNON1 or data.chessId == R_CANNON2 then
			kEffectPlayer:playEffect(Effects.AUDIO_HANDICAP_CANNON);
		end
    elseif data.result == 1 then--失败

    end;
end;

OnlineRoomScene.onClientMsgLeave = function(self, data)
--    if not data then
--        return;
--    end;
--    if(data.errorCode == 0) then
--		if self.m_tid == data.tableID then
--			self:setStatus(data.tableStatus);
--			if  self.m_downUser:getUid() == data.player1ID then
--				self.m_downUser:setStatus(data.player1Status);
--				if self.m_upUser then
--					self.m_upUser:setStatus(data.player2Status);
--				end
--			else
--				self.m_downUser:setStatus(data.player2Status);
--				if self.m_upUser then
--					self.m_upUser:setStatus(data.player1Status);
--				end
--			end
--			-- self:setStartReadyVisible();
--			self:userLeave(data.leaveUid);
--		else
--			print_string("返回棋桌与当前棋桌不相符");
--		end
--	else
--		print_string("CLIENT_MSG_LEAVE errorCode ~= 0");
--	end
-- 	print_string("errorCode:" .. data.errorCode );
--	print_string("errorMsg:" .. data.errorMsg );
--	print_string("tableID:" .. data.tableID);
--	print_string("tableStatus:" .. data.tableStatus);
--	print_string("======服务器回应房间CLIENT_MSG_LEAVE处理成功======");

--	OnlineConfig.deleteTimer();     


end;

OnlineRoomScene.userLeave = function(self,leaveUid)
	self:stopTimeout();

	self:game_close_dismiss_dialogs();

	if  self.m_downUser:getUid() == leaveUid then
		-- self.m_down_user_icon:setVisible(false);
		-- UserInfo.getInstance():setGameType(GAME_TYPE_UNKNOW);
		UserInfo.getInstance():setTid(0);
		self.m_down_user_ready_img:setVisible(self.m_downUser:getReadyVisible());
	    self.m_down_user_start_btn:setVisible(self.m_downUser:getStartVisible());

		self.m_up_user_ready_img:setVisible(false);
		self.m_up_user_icon:setVisible(false);  ---表现形式将对走离开

--		self.m_controller:stopHeartBeat();
--	    self:requestCtrlCmd(OnlineRoomController.s_cmds.close_room_socket);
	elseif self.m_upUser and self.m_upUser:getUid() == leaveUid then
        --上家离开，分为2种情况：
        --1，结算框离开，则自己还没有准备，self.m_ready_status==false,点击再来一局，弹选难度对话框。
        --2，点再来一局准备后，上家离开，此时self.m_ready_status == true,需强制自己退出server房间
        --（还在房间内，只是没有登陆server房间），弹选难度对话框。
        self.m_upuser_leave = true;
        --只要一个玩家离开，都要退出server房间
--        self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_offline);
        local gametype = UserInfo.getInstance():getGameType(); --用户的游戏模式
        if gametype ~= GAME_TYPE_CUSTOMROOM and gametype ~= GAME_TYPE_FRIEND then
            self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_offline);
            self:showSelectPlayerDialog();
        elseif gametype == GAME_TYPE_FRIEND then
            self:onForceLeave();
        end;
		self.m_up_user_icon:setFile(User.MAN_ICON);
		HeadSmogAnim.play(self.m_up_user_icon);
        self.m_up_turn:setVisible(false);
		self.m_up_user_icon:setVisible(false);
		self.m_up_user_ready_img:setVisible(false);
        if self.m_roomFriend then
            self.m_roomFriend:dismiss();
        end
        if self.m_roomFriendShow then
            self.m_roomFriendShow:dismiss();
        end
	end

end


OnlineRoomScene.onClientMsgChat = function(self, data)
    if not data then
        return;
    end;
    if self.m_downUser:getUid() == data.uid then
        self:showDownChat(1,data.message);
    else
        self:showUpChat(data.msgType,data.message);
    end
end;



OnlineRoomScene.onClientMsgHandicap = function(self, data)
    if not data then
        return;
    end;
    self:handicapEvent(data);

end;

OnlineRoomScene.onClientMsgLogin = function(self, data)
    if not data then
        return;
    end;
--	UserInfo.getInstance():setBycoin(data.bycoin);
--	-- 对手被强制悔棋获得金币数 
--	UserInfo.getInstance():setOpponentgetCoin(data.opponentgetCoin);
--	UserInfo.getInstance():setMaxOnlineUndoCount(data.Count)--一局棋最多悔棋次数 
--	--当前悔棋次数要用到的元宝数
--	UserInfo.getInstance():setUseBYCoinTb(data.useBYCoinTb);

--	if(data.errorCode == 0) then
--		UserInfo.getInstance():setStatus(data.status);
--        self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_comein);
--	elseif data.errorCode == 1 then
--        self:requestCtrlCmd(OnlineRoomController.s_cmds.syn_room_data);
--	elseif data.errorCode == -2 then
--		local message = "棋局已经结束,进入棋桌失败！"
--		self:loginFail(message);
--		return;
--	else
--		local message = "进入棋桌失败！请检查网络后稍候再试!!!"
--		self:loginFail(message);
--		return;
--	end    
end;



OnlineRoomScene.onServerMsgGamestart = function(self, data)
    if not data then
        return;
    end;
    self:onDeleteInvitAnim();
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

--		self:setStatus(data.tableStatus);

--		if  self.m_downUser:getUid() == data.player1ID then
--			self.m_downUser:setStatus(data.player1Status);
--			if self.m_upUser then
--				self.m_upUser:setStatus(data.player2Status);
--			end
--		else
--			self.m_downUser:setStatus(data.player2Status);
--			if self.m_upUser then
--				self.m_upUser:setStatus(data.player1Status);
--			end
--		end
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
--		self:startGame(data.chess_map);
--		self:refreshWatcher();



-- 	print_string("errorCode:" .. data.errorCode );
--	print_string("errorMsg:" .. data.errorMsg );
--	print_string("tableID:" .. data.tableID);
--	print_string("tableStatus:" .. data.tableStatus);
--	print_string("======服务器回应房间SERVER_MSG_GAME_START处理成功======");
    self:requestCtrlCmd(OnlineRoomController.s_cmds.client_get_openbox_time);
	ToolKit.addOnlineGameLogCount(self.m_root_view);
--    self:requestCtrlCmd(OnlineRoomController.s_cmds.syn_room_data);
end;


OnlineRoomScene.onServerMsgGameclose = function(self, data)
    if not data then
        return;
    end;

	self:setStatus(data.table_status);

--	if  self.m_downUser:getUid() == data.uid1 then
----		self.m_downUser:setStatus(data.player1Status);
--		if self.m_upUser then
--			self.m_upUser:setStatus(data.player2Status);
--		end
--	else
--		self.m_downUser:setStatus(data.player2Status);
--		if self.m_upUser then
--			self.m_upUser:setStatus(data.player1Status);
--		end
--	end


	if  self.m_downUser:getUid() == data.uid1 then
		self.m_downUser:setScore(data.score1);
        self.m_downUser:setPoint(data.tscore1);
        self.m_downUser:setCoin(data.tmoney1);
		self.m_downUser:setMoney(data.money1);
		self.m_downUser:setTaxes(data.rent);
		if self.m_upUser then
			self.m_upUser:setScore(data.score2);
			self.m_upUser:setPoint(data.tscore2);
			self.m_upUser:setCoin(data.tmoney2);
			self.m_upUser:setMoney(data.money2);
			self.m_upUser:setTaxes(data.rent);
		end
	else
		self.m_downUser:setScore(data.score2);
        self.m_downUser:setPoint(data.tscore2);
        self.m_downUser:setCoin(data.tmoney2);
		self.m_downUser:setMoney(data.money2);
		self.m_downUser:setTaxes(data.rent);
		if self.m_upUser then
			self.m_upUser:setScore(data.score1);
			self.m_upUser:setPoint(data.tscore1);
			self.m_upUser:setCoin(data.tmoney1);
			self.m_upUser:setMoney(data.money1);
			self.m_upUser:setTaxes(data.rent);
		end
	end


    self.m_again_btn_timeout = data.ready_time or 9;--再来一局倒计时显示时间
    Log.i("OnlineRoomScene.onServerMsgGameclose"..self.m_again_btn_timeout);
	self:gameClose(data.win_flag,data.end_type);
    self:requestCtrlCmd(OnlineRoomController.s_cmds.get_task_progress);



--	local userFlag = UserInfo.getInstance():getFlag();--本人红黑标志 1红方、2黑方

--	if userFlag == 1 then
--		self:verify(data.redOnlineTime,data.redIsVerify);
--	elseif userFlag == 2 then
--		self:verify(data.blackOnlineTime,data.blackIsVerify);
--	end
	
	OnlineConfig.deleteTimer(self); 

	print_string("======服务器回应房间SERVER_MSG_GAME_CLOSE处理成功======");

end

OnlineRoomScene.verify = function(self,onlineTime,isVerify)
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

OnlineRoomScene.onServerMsgWarning = function(self, data)
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




OnlineRoomScene.onServerMsgMove = function(self, data)
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

OnlineRoomScene.onClientMsgDraw1 = function(self, data)
    if not data then
        return;
    end;
--    ShowMessageAnim.play(self.m_root_view,data);
    ChessToastManager.getInstance():showSingle(data);
end;


OnlineRoomScene.onClientMsgDraw2 = function(self, data)
    if not data then
        return;
    end;
	if self.m_upUser:getUid() == data.uid then
		self:responseDraw();
	end    

end;


OnlineRoomScene.onClientMsgSurrender2 = function(self, data)
    if not data then
        return;
    end;
	if self.m_upUser:getUid() == data.uid then
        
		self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_surrender2, 1);  -- 直接同意
	end      

end;

OnlineRoomScene.onServerMsgSurrender = function(self, data)
    if not data then
        return;
    end;
    self.m_tid = UserInfo.getInstance():getTid();
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


OnlineRoomScene.onShowInputPwdDialog = function(self, isAnother)

	self.m_inputPwdDialog = new(InputPwdDialog,50,260,370,286,self);
	self.m_inputPwdDialog:setPositiveListener(self,self.loginStartCustomRoom);
	self.m_inputPwdDialog:setNegativeListener(self,self.exitRoom)
    self.m_inputPwdDialog:show(isAnother,self.m_root_view);

end;



OnlineRoomScene.onEnterCustomRoomFail = function(self, data)

	if data~=nil then
		if data == 2 then
			self:onShowInputPwdDialog(true);
			return;
		else
	        local message = "登陆失败";
			if data == -3 then
		        message = "你的金币不足以进入房间";
		    elseif data == -5 then
				message = "棋桌已满";
			elseif data == -8 then
		        message = "用户不合法";
		    elseif data == -2 then
		        message = "房间已不存在";
			end
			self:loginFail(message);
		end
	end

end;

OnlineRoomScene.onCustomMsgLoginRoom = function(self, data)
    if not data then

        return 
    end;
    if data.retCode ~= 0 then

        self.Undomovenum = 0;
        self:upComeIn(data.user);
    end;
    self:setGameType(data.gameType);
	self.m_tid = data.tableID;
	self:setStatus(data.tableStatus) ;
	self:downComeIn(UserInfo.getInstance());
	self:setStartReadyVisible();
end;



OnlineRoomScene.onResumeFromHomekey = function(self)

	--同步棋盘信息
	if self:isGameOver() then
		print_string("Room.onHomeResume but gameover");
		return;
	end

	self:synchroRequest();    
end;


OnlineRoomScene.onShowNetState = function(self, netState)
    self:showNetSinalIcon(false, netState);
end;



OnlineRoomScene.onSetTimeInfo = function(self, data)
    if data.subcmd == 1 then
        if UserInfo.getInstance():getUid() == data.uid then
            if self.m_timeset_dialog then
			    self.m_timeset_dialog:show(true);
            end
		else
			local message = "等待对手设置时间...";
			self:showLoadingDialog(message);
		end
    elseif data.subcmd == 3 then
--        self:dismissLoadingDialog();
        if self.m_timeset_dialog then
		    self.m_timeset_dialog:setTime(data.timeOut1,data.timeOut2,data.timeOut3);
		    self.m_timeset_dialog:show(false);
        end

    end;

end;



OnlineRoomScene.onHandleConnSocketFail = function(self)
	self.m_connectCount = self.m_connectCount + 1;

	if self.m_connectCount~=nil and self.m_connectCount==3 then
		self.m_connecting = false;
		self.m_connectCount = 0;
		if self.m_sureconnect == nil then
			self.m_sureconnect =1;
		else
			self.m_sureconnect = self.m_sureconnect + 1;
		end

		if self.m_sureconnect~=nil and self.m_sureconnect==3 then
			self.m_sureconnect = 0;
			self:showConnectFailedDialog(true);
		else
			self:showConnectFailedDialog(false);
	    end
	else
        self:closeSocket();
		self:openSocket();
	end
end


OnlineRoomScene.showConnectFailedDialog = function(self,isSetting)
	local message =  "亲，貌似与服务器失去连接了...继续重连？(一段时间没连上就会判输哦)";

	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end

	self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE);
	self.m_chioce_dialog:setMessage(message);
	if isSetting then
		self.m_chioce_dialog:setPositiveListener(self,self.startWirelessSetting);
	else
		self.m_chioce_dialog:setPositiveListener(self,self.openSocketConnecting);
	end

	self.m_chioce_dialog:setNegativeListener(self,self.exitRoom);
	self.m_chioce_dialog:show();
end

OnlineRoomScene.openSocketConnecting = function(self)
	local tips = "正在重新与服务器连接..."
    ProgressDialog.show(tips , true, nil,nil);
    self.m_connecting = true;
    self.m_connectCount =0;
    UserInfo.getInstance():setRelogin(true) 
    self:openSocket()
end

OnlineRoomScene.startWirelessSetting = function(self)
    self.m_connectCount = 0;

    local post_data = {};
	local dataStr = json.encode(post_data);
    dict_set_string(kStartWirelessSetting,kStartWirelessSetting..kparmPostfix,dataStr);
	call_native(kStartWirelessSetting);


	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	else
		 self.m_chioce_dialog:dismiss();
	end

	local message =  "亲，貌似与服务器失去连接了...继续重连？(一段时间没连上就会判输哦)";
	self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE);
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:setPositiveListener(self,self.openSocket);
	self.m_chioce_dialog:setNegativeListener(self,self.exitRoom);
	self.m_chioce_dialog:show();

end


OnlineRoomScene.closeSocket = function(self)
--    self:requestCtrlCmd(OnlineRoomController.s_cmds.close_room_socket);
end;

OnlineRoomScene.openSocket = function(self)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.open_room_socket);
end;

--游戏是否结束
OnlineRoomScene.isGameOver = function(self)
	return self.m_game_over;
end



OnlineRoomScene.loginStartCustomRoom = function(self,pwdStr)
    UserInfo.getInstance():setCustomRoomPwd(pwdStr);
--    self:requestCtrlCmd(OnlineRoomController.s_cmds.close_room_socket);
    self:requestCtrlCmd(OnlineRoomController.s_cmds.start_customroom);
end

OnlineRoomScene.onServerMsgDraw = function(self, data)
    if not data then
        return;
    end;
    self.m_tid = UserInfo.getInstance():getTid();
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


OnlineRoomScene.responseDraw = function(self)
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



OnlineRoomScene.agreeDraw = function(self)
	if UserInfo.getInstance():getGameType() == GAME_TYPE_COMPUTER then  --单机
		self.m_board:drawResponse(true);
	else
        self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_draw2, 1);

	end
end

OnlineRoomScene.refuseDraw = function(self)
	if UserInfo.getInstance():getGameType() == GAME_TYPE_COMPUTER then  --单机
		self.m_board:drawResponse(false);
	else
        self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_draw2, 2);
	end
end



OnlineRoomScene.onClientMsgUndomove = function(self, data)
    if not data then
        return;
    end;    

    if data.subcmd == 1 then
        if data.errorCode < 0 then
			self:undoRequestCallBack(data.errorCode,data.errorMsg);
		end
    elseif data.subcmd == 2 then
        if self.m_upUser:getUid() == data.uid then
			self:undoResponse();
		end   
    
    elseif data.subcmd == 3 then
        self.OpponentID = data.OpponentID;
		self.GetCoin = data.GetCoin;
		self.Undomovenum = data.Undomovenum;
--		self:synchroRequest();

		if UserInfo.getInstance():getUid() ~= data.OpponentID then
			self:undoSuccessCallBack();
		end
        self.m_tid = UserInfo.getInstance():getTid();
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

OnlineRoomScene.undoMoneyResult = function(self,uid_1,changeMoney_1,uid_2,changeMoney_2,isOK)
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
end

OnlineRoomScene.undoSuccessCallBack= function(self)
	self.isUseLeftUndo = false;
end


OnlineRoomScene.undoMoneyRequestCallBack = function(self,status)
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

OnlineRoomScene.undoMoneyRequestAnswer = function(self,money)
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

OnlineRoomScene.agreeMoneyUndo = function(self)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_undomove, 12,1);
end

OnlineRoomScene.refuseMoneyUndo = function(self)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_undomove, 12,2);
end




OnlineRoomScene.undoResponse = function(self)
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

OnlineRoomScene.agreeUndo = function(self)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_undomove, 2,1);
end

OnlineRoomScene.refuseUndo = function(self)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_undomove, 2,2);

end



OnlineRoomScene.undoRequestCallBack = function(self,status,msg)
	self.isUndoAble = true;

	if status == -11  then
--		if PayUtil.isGetMallGoods() then
--			self.m_payInterface = PayUtil.getPayTypeObj(PayInterface.INGOT_GOODS,self,true);
--			local mGoods, tGoods,rGoods = PayUtil.getIngotsGoods();
--			local pos = ONLINE_ROOM_INGOT;
--			PayUtil.showBuyInogtDlg(self,pos,self.m_payInterface,mGoods,tGoods,rGoods);
--		else
--			PHPInterface.getMallShopInfo(1);
--		end	
	else
		self:showTipsDlg(msg,ChioceDialog.MODE_SURE);
	end
end


OnlineRoomScene.chessMove = function(self,data)

    self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_move,data);

 end


--更新观战人数
OnlineRoomScene.refreshWatcher = function(self)
	if UserInfo.getInstance():getGameType() ~= GAME_TYPE_CUSTOMROOM then
        self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_watchlist);        
	end

end
OnlineRoomScene.handicapEvent = function(self,data)
	print_string("Room.handicapEvent");
	self:clearDialog();

--   info.red_uid = self.m_socket:readInt(packetId,ERROR_NUMBER);
--   info.multiply = self.m_socket:readInt(packetId,ERROR_NUMBER);
--   info.timeout = self.m_socket:readInt(packetId,ERROR_NUMBER);
--   info.handicap_count = self.m_socket:readInt(packetId,ERROR_NUMBER);
--   info.chessId = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 让子id
--   info.times = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 让子倍数



		if data.red_uid == self.m_downUser:getUid() then    --由我让子

			if not self.m_handicap_dialog then
				self.m_handicap_dialog = new(HandicapDialog,self);
			end
			self.m_handicap_dialog:setData(data);
			self.m_handicap_dialog:show();

		elseif data.red_uid == self.m_upUser:getUid() then  --等待对手让子
			local message = "等待对手让子！"

			self:showLoadingDialog(message,data.timeout);

		elseif data.red_uid == 0 then

            
        end


end

OnlineRoomScene.sendHandicapMsg = function(self,info)
    
    self:requestCtrlCmd(OnlineRoomController.s_cmds.server_msg_handicap, info);

end;
OnlineRoomScene.show_reward_dlg = function(self,msg)
	if not self.m_online_box_dialog then
		self.m_online_box_dialog = new(OnlineBoxRewardDialog,msg);
	end
	self.m_online_box_dialog:show(msg);
end


OnlineRoomScene.setBoradCode = function(self, code)
    self.m_boradcode = code;

end;



OnlineRoomScene.stopHeartBeat = function(self)
	delete(self.m_heartBeatAnim);
	self.m_heartBeatAnim = nil;
end


OnlineRoomScene.startTime = function(self)
	self:stopTime();
	self.m_timeAnim = new(AnimInt,kAnimLoop,0,1,1000,-1);
	self.m_timeAnim:setDebugName("Room.startTime.m_timeAnim");
	self.m_timeAnim:setEvent(self,self.timeRun);

end

OnlineRoomScene.stopTime = function(self)
	if self.m_timeAnim then
		delete(self.m_timeAnim);
		self.m_timeAnim = nil;
	end
end

OnlineRoomScene.timeRun = function(self)
	local t = os.date("*t");

	local time = string.format("%02d:%02d",t.hour,t.min);
	if t.sec%2 == 1 then
		time = string.format("%02d %02d",t.hour,t.min);
	end

	self.m_room_time_text:setText(time);
end



--服务器回应走棋
OnlineRoomScene.resPonseMove = function(self,data)
	print_string("对手走棋");
	self.m_board:severMove(data);
end
OnlineRoomScene.resPonseUnLegalMove = function(self,code)
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
OnlineRoomScene.onEventStat = function(self,event_id)
	local type_name = {

		[GAME_TYPE_UNKNOW] = "game_type_unknow";   --未类型
		[GAME_TYPE_FREE] = "game_type_free";     --自由场
		[GAME_TYPE_TEN] = "game_type_ten";      --十分钟场
		[GAME_TYPE_TWENTY] = "game_type_twenty";   --二十分钟场
		[GAME_TYPE_ASYN] = "game_type_asyn";     --异步场
		[GAME_TYPE_COMPUTER] = "game_type_computer"; --单机游戏
		[GAME_TYPE_WATCH] = "game_type_watch";   --观战模式
		[GAME_TYPE_CUSTOMROOM] = "game_type_customroom"; --自定义房间游戏
        [GAME_TYPE_FRIEND] = "game_type_friendroom"; --好友房
	}

	local game_type = UserInfo.getInstance():getGameType();

	local event_info = event_id .. ","  ..  type_name[game_type];
	on_event_stat(event_info); --事件统计

end

OnlineRoomScene.onUpdataUserIcon = function(self,imageName,uid)
--    if not imageName or not uid then return end; -- 用新版图片下载
--    if self.m_upUser and self.m_upUser.m_uid == uid then
--        self.m_up_user_icon:setFile(imageName);
--    end

--    if self.m_downUser and self.m_downUser.m_uid == uid then
--        self.m_down_user_icon:setFile(imageName);
--    end
end

OnlineRoomScene.onWatchRoomUserEnter = function(self,packetInfo)
    if self.m_downUser then
        self:upComeIn(packetInfo.player);
    else
        self:downComeIn(packetInfo.player);
    end
end

OnlineRoomScene.onWatchRoomNumber = function(self,packetInfo)
    self:setWathcerCount(packetInfo.ob_num);
end

OnlineRoomScene.onWatchRoomMsg = function(self,packetInfo)
    if not packetInfo or not packetInfo.chat_msg or packetInfo.chat_msg == ""  or not packetInfo.name or packetInfo.name == "" then
		return;
	end
	local msg = string.format("%s:%s",packetInfo.name,packetInfo.chat_msg);
	self.m_room_menu_chat_text:setText(msg);
	self.m_watch_chat_log_dialog:addChatLog(packetInfo.name,packetInfo.chat_msg);
	self.m_chat_dialog:addChatLog(packetInfo.name,packetInfo.chat_msg);
end

OnlineRoomScene.onAddBtnClick = function(self,data)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.client_add,data);
end

----------------------------------- config ------------------------------
OnlineRoomScene.s_controlConfig = 
{
};

OnlineRoomScene.s_controlFuncMap =
{
};


OnlineRoomScene.s_cmdConfig =
{
    [OnlineRoomScene.s_cmds.updateWatchRoom]        = OnlineRoomScene.onUpdateWatchRoom;
    [OnlineRoomScene.s_cmds.updateWatchRoomUser]    = OnlineRoomScene.onUpdateWatchRoomUser;
    [OnlineRoomScene.s_cmds.watcherCountChange]     = OnlineRoomScene.onWatcherCountChange;
    [OnlineRoomScene.s_cmds.watchRoomMove]          = OnlineRoomScene.onWatchRoomMove;
    [OnlineRoomScene.s_cmds.watchRoomUserLeave]     = OnlineRoomScene.onWatchRoomUserLeave;
    [OnlineRoomScene.s_cmds.watchRoomReady]         = OnlineRoomScene.onWatchRoomReady;
    [OnlineRoomScene.s_cmds.watchRoomStart]         = OnlineRoomScene.onWatchRoomStart;
    [OnlineRoomScene.s_cmds.watchRoomClose]         = OnlineRoomScene.onWatchRoomClose;
    [OnlineRoomScene.s_cmds.watchRoomAllready]      = OnlineRoomScene.onWatchRoomAllReady;
    [OnlineRoomScene.s_cmds.watchRoomError]         = OnlineRoomScene.onWatchRoomError;


    [OnlineRoomScene.s_cmds.watcherChatMsg]         = OnlineRoomScene.onWatcherChatMsg;
    [OnlineRoomScene.s_cmds.watchRoomPlayerChatMsg] = OnlineRoomScene.onWatchRoomPlayerChatMsg;
    [OnlineRoomScene.s_cmds.watchRoomDraw]          = OnlineRoomScene.onWatchRoomDraw;
    [OnlineRoomScene.s_cmds.watchRoomSurrender]     = OnlineRoomScene.onWatchRoomSurrender;
    [OnlineRoomScene.s_cmds.watchRoomUndo]          = OnlineRoomScene.onWatchRoomUndo;
    [OnlineRoomScene.s_cmds.watchRoomWaring]        = OnlineRoomScene.onWatchRoomWaring;
    [OnlineRoomScene.s_cmds.watchRoomUpdateTable]   = OnlineRoomScene.onWatchRoomUpdateTable;
    
    [OnlineRoomScene.s_cmds.exit_room]              = OnlineRoomScene.onExitRoom;
    [OnlineRoomScene.s_cmds.match_room_success]     = OnlineRoomScene.onMatchRoomSucc;
    [OnlineRoomScene.s_cmds.match_room_fail]        = OnlineRoomScene.onMatchRoomFail;
    [OnlineRoomScene.s_cmds.client_user_comein]     = OnlineRoomScene.onClientUserComein;
    [OnlineRoomScene.s_cmds.client_user_login_succ] = OnlineRoomScene.onClientUserLoginSucc;
    [OnlineRoomScene.s_cmds.client_user_login_error] = OnlineRoomScene.onClientUserLoginError;
    [OnlineRoomScene.s_cmds.client_user_other_error] = OnlineRoomScene.onClientUserOtherError;
    [OnlineRoomScene.s_cmds.client_opp_user_login]  = OnlineRoomScene.onClientOppUserLogin;
    [OnlineRoomScene.s_cmds.server_msg_ready]       = OnlineRoomScene.onServerMsgReady;
    [OnlineRoomScene.s_cmds.server_msg_timecount_start] = OnlineRoomScene.onServerMsgTimecountStart;
    [OnlineRoomScene.s_cmds.server_msg_reconnect]   = OnlineRoomScene.onServerMsgReconnect;
    [OnlineRoomScene.s_cmds.server_msg_user_leave]  = OnlineRoomScene.onServerMsgUserLeave;
    [OnlineRoomScene.s_cmds.server_msg_forestall]   = OnlineRoomScene.onServerMsgForestall;
    [OnlineRoomScene.s_cmds.server_msg_forestall_new]   = OnlineRoomScene.onServerMsgForestallNew;
    [OnlineRoomScene.s_cmds.server_msg_handicap]    = OnlineRoomScene.onServerMsgHandicap;
    [OnlineRoomScene.s_cmds.server_msg_handicap_result]  = OnlineRoomScene.onServerMsgHandicapResult;
    [OnlineRoomScene.s_cmds.server_msg_logout_succ] = OnlineRoomScene.onServerMsgLogoutSucc;


    [OnlineRoomScene.s_cmds.createFriendRoom] = OnlineRoomScene.onCreateFriendRoom;
    [OnlineRoomScene.s_cmds.setTime] = OnlineRoomScene.onSetTime;
    [OnlineRoomScene.s_cmds.setTimeShow] = OnlineRoomScene.onSetTimeShow;
    [OnlineRoomScene.s_cmds.reSetGame] = OnlineRoomScene.onReSetGame;
    [OnlineRoomScene.s_cmds.invitNotify] = OnlineRoomScene.onInvitNotify;
    [OnlineRoomScene.s_cmds.deleteInvitAnim] = OnlineRoomScene.onDeleteInvitAnim;
    
    [OnlineRoomScene.s_cmds.matchSuccess] = OnlineRoomScene.onMatchSuccess;

    [OnlineRoomScene.s_cmds.client_msg_start]       = OnlineRoomScene.onClientMsgStart;
    [OnlineRoomScene.s_cmds.client_msg_forestall]   = OnlineRoomScene.onClientMsgForestall;
    [OnlineRoomScene.s_cmds.client_msg_relogin]     = OnlineRoomScene.onClientMsgRelogin;
    [OnlineRoomScene.s_cmds.client_msg_syndata]     = OnlineRoomScene.onClientMsgSyndata;
    [OnlineRoomScene.s_cmds.client_get_openbox_time]= OnlineRoomScene.onClientGetOpenboxTime;
    [OnlineRoomScene.s_cmds.client_msg_leave]       = OnlineRoomScene.onClientMsgLeave;
    [OnlineRoomScene.s_cmds.client_msg_chat]        = OnlineRoomScene.onClientMsgChat;
    [OnlineRoomScene.s_cmds.client_msg_handicap]    = OnlineRoomScene.onClientMsgHandicap;
    [OnlineRoomScene.s_cmds.client_msg_login]       = OnlineRoomScene.onClientMsgLogin;
    [OnlineRoomScene.s_cmds.server_msg_gamestart]   = OnlineRoomScene.onServerMsgGamestart;
    [OnlineRoomScene.s_cmds.server_msg_gameclose]   = OnlineRoomScene.onServerMsgGameclose;
    [OnlineRoomScene.s_cmds.server_msg_warning]     = OnlineRoomScene.onServerMsgWarning;
    [OnlineRoomScene.s_cmds.client_msg_move]        = OnlineRoomScene.onServerMsgMove;


    [OnlineRoomScene.s_cmds.client_msg_draw1]       = OnlineRoomScene.onClientMsgDraw1;
    [OnlineRoomScene.s_cmds.client_msg_draw2]       = OnlineRoomScene.onClientMsgDraw2;
    [OnlineRoomScene.s_cmds.server_msg_draw]        = OnlineRoomScene.onServerMsgDraw;
    [OnlineRoomScene.s_cmds.client_msg_undomove]    = OnlineRoomScene.onClientMsgUndomove;
    [OnlineRoomScene.s_cmds.client_msg_surrender2]  = OnlineRoomScene.onClientMsgSurrender2;
    [OnlineRoomScene.s_cmds.server_msg_surrender]   = OnlineRoomScene.onServerMsgSurrender;
    [OnlineRoomScene.s_cmds.show_input_pwd_dialog]  = OnlineRoomScene.onShowInputPwdDialog;
    [OnlineRoomScene.s_cmds.enter_customroom_fail]  = OnlineRoomScene.onEnterCustomRoomFail;
    [OnlineRoomScene.s_cmds.custom_msg_login_room]  = OnlineRoomScene.onCustomMsgLoginRoom;
    [OnlineRoomScene.s_cmds.resume_from_homekey]    = OnlineRoomScene.onResumeFromHomekey;
    [OnlineRoomScene.s_cmds.show_net_state]         = OnlineRoomScene.onShowNetState;
    [OnlineRoomScene.s_cmds.set_time_info]          = OnlineRoomScene.onSetTimeInfo;
    [OnlineRoomScene.s_cmds.handle_conn_fail]       = OnlineRoomScene.onHandleConnSocketFail;
    [OnlineRoomScene.s_cmds.on_room_touch]          = OnlineRoomScene.onRoomTouch;
    [OnlineRoomScene.s_cmds.update_prop_info]       = OnlineRoomScene.onUpdatePropInfo;

    [OnlineRoomScene.s_cmds.updataUserIcon]         = OnlineRoomScene.onUpdataUserIcon;

    [OnlineRoomScene.s_cmds.watchRoomUserEnter]     = OnlineRoomScene.onWatchRoomUserEnter;
    [OnlineRoomScene.s_cmds.watchRoomNumber]        = OnlineRoomScene.onWatchRoomNumber;
    [OnlineRoomScene.s_cmds.watchRoomMsg]           = OnlineRoomScene.onWatchRoomMsg;

    [OnlineRoomScene.s_cmds.forceLeave]             = OnlineRoomScene.onForceLeave;           --强制离场
    [OnlineRoomScene.s_cmds.invitFail]              = OnlineRoomScene.onInvitFail;           --邀请失败
    [OnlineRoomScene.s_cmds.updateUserInfoDialog]   = OnlineRoomScene.onUpdateUserInfoDialog;           --关注/取消关注
}

