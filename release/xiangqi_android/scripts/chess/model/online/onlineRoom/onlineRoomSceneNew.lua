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
require("dialog/watchlist_dialog");
require("dialog/watch_dialog");

require("animation/countDown");
require(DATA_PATH .. "userSetInfo");

OnlineRoomSceneNew = class(RoomScene);

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
    show_input_pwd_dialog   = 18;
    resume_from_homekey     = 19;
    show_net_state          = 20;
    set_time_info           = 21;
    handle_conn_fail        = 22;
    on_room_touch           = 23;
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
    updataUserIcon          = 34;
    client_msg_draw1        = 35;
    client_user_login_error = 36;
    client_user_other_error = 37;
    setTime                 = 38;
    setTimeShow             = 39;
    reSetGame               = 40;
    forceLeave              = 41;
    invitFail               = 42;
    updateUserInfoDialog    = 43;
    server_msg_forestall_new = 44;
    invitNotify             = 45;
    deleteInvitAnim         = 46;
    server_msg_tips         = 47;
    updateWatchUserList     = 48;--更新dialog列表
    updateWatchDialog       = 49; --更新观战按钮
    watchNumber             = 50; --观战人数
    callTelphoneResponse    = 51;
    callTelphoneBack        = 52;
    setDisconnect           = 53;
    save_mychess            = 54;
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
    self:initGame();
end;

OnlineRoomSceneNew.pause = function(self)
	RoomScene.pause(self);
    AnimKill.deleteAll();
    AnimTimeout.deleteAll();
    AnimJam.deleteAll();
    self:onDismissDialog();
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
    delete(self.m_loading_dialog);
    delete(self.m_handicap_dialog);
    delete(self.m_online_box_dialog);
    delete(self.m_timeAnim);
    delete(self.m_roomSetTimeDialog);
    delete(self.m_roomOtherSetTimeDialog);
    delete(self.m_friendChoiceDialog);
    delete(self.m_ready_time_anim);
    delete(self.m_invit_time_anim);
    delete(self.m_heartBeatAnim);
    delete(self.m_watchList_dialog);
    delete(self.m_watch_dialog);
    delete(self.m_account_save_dialog);
    OnlineConfig.deleteTimer(self);
    OnlineConfig.deleteOpenBoxTimer();
    delete(self.m_countdownAnim);
    delete(self.animTimer);
    self:onLineRoomDtor();
    self:onWatchRoomDtor();
    self:onCustomRoomDtor();
    self:onFriendRoomDtor();
    delete(self.anim_end);
    delete(self.anim_start);
    delete(self.m_show_tip_dialog);
    TestAnim.deleteTestAnim();
    delete(self.m_match_dialog);
    delete(self.m_rematch_dialog);
    self:clearRoomInfo();
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

	---弹出框
	self.m_account_dialog = nil;

    --房间数据
    local roomtype = UserInfo.getInstance():getMoneyType() or 0;
    if roomtype == UserInfo.getInstance():getRoomConfigById(4).money then
        self.m_roominfo = UserInfo.getInstance():getRoomConfigById(4);--4为私人房
    else
	    self.m_roominfo = UserInfo.getInstance():getRoomConfigById(roomtype);
    end
end;

OnlineRoomSceneNew.initView = function(self)
--初始化界面（只初始化一次,不要delete每个view）
    self.m_root_view = self.m_root;
    --切换到聊天dialog背景
    self.room_bg_temp = self.m_root_view:getChildByName("room_bg_temp");

    self.m_room_time_text = self.m_root_view:getChildByName("room_time_bg"):getChildByName("room_time");
    self.m_back_btn = self.m_root_view:getChildByName("back_btn");
    self.m_back_btn:setTransparency(0.8);
    self.m_back_btn:setOnClick(self,self.back_action);
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
    if pw > w and UserInfo.getInstance():getGameType() ~= GAME_TYPE_WATCH then
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
	self.m_multiple_text:setText("倍数 1");

	--上部玩家信息模块
	self.m_up_view = self.m_root_view:getChildByName("up_model");   --上部玩家及一些信息模块
	self.m_up_user_icon_bg = self.m_up_view:getChildByName("up_user_icon_bg");
	self.m_up_user_icon_frame_mask = self.m_up_user_icon_bg:getChildByName("up_user_icon_frame_mask");
    self.m_up_user_level_icon = self.m_up_user_icon_bg:getChildByName("up_user_level_icon");
    self.m_up_user_disconnect = self.m_up_user_icon_bg:getChildByName("up_user_disconnect");
    self.m_up_user_icon = new(Mask,"online/room/head_mask.png","online/room/head_mask.png");
    self.m_up_user_icon:setSize(self.m_up_user_icon_frame_mask:getSize());
    self.m_up_vip_frame = self.m_up_user_icon_bg:getChildByName("vip_frame");
    self.m_up_vip_logo =self.m_up_view:getChildByName("vip_logo");
    self.m_up_user_icon_frame_mask:addChild(self.m_up_user_icon);
--    self.m_up_user_icon:addChild(self.m_up_user_level_icon); -- 切换 level
	self.m_up_turn = self.m_up_user_icon_bg:getChildByName("up_turn");
    --上部头像动画
    self.m_up_breath1 = self.m_up_user_icon_frame_mask:getChildByName("breath1");
    self.m_up_breath1:setLevel(2);
    self.m_up_breath2 = self.m_up_user_icon_frame_mask:getChildByName("breath2");
    self.m_up_breath2:setLevel(2);

	self.m_up_timeframe = self.m_up_view:getChildByName("up_timeframe_bg");
	self.m_up_timeout1_name = self.m_up_timeframe:getChildByName("up_timeout1_name");
	self.m_up_timeout1_text = self.m_up_timeframe:getChildByName("up_timeout1_text");
	self.m_up_timeout2_name = self.m_up_timeframe:getChildByName("up_timeout2_name");
	self.m_up_timeout2_text = self.m_up_timeframe:getChildByName("up_timeout2_text");
	self.m_up_name = self.m_up_view:getChildByName("up_user_name");
	self.m_up_user_icon:setEventTouch(self,self.showUpUserInfo);

	--上部玩家信息弹出框
	self.m_up_user_info_dialog_view = self.m_root_view:getChildByName("up_user_info_view");
	self.m_up_user_info_dialog = new(UserInfoDialog,self.m_up_user_info_dialog_view,"up_user_info_");
    self.m_up_user_info_dialog:setAddFunc(self,self.onAddBtnClick);
	self.m_up_chessframe = self.m_up_user_info_dialog_view:getChildByName("up_user_info_dialog"):getChildByName("up_chessframe_bg");
    self.m_up_chess_pc = {};
    self.m_up_chess_num = {};
	for i = 1 ,7 do
		self.m_up_chess_pc[i] = self.m_up_chessframe:getChildByName("up_chess" .. i .. "_pc" );
		self.m_up_chess_num[i] = self.m_up_chess_pc[i]:getChildByName("up_chess" .. i .. "_num");
		self.m_up_chess_pc[i]:setVisible(false);
		self.m_up_chess_num[i]:setVisible(false);
	end

    --下部玩家信息弹出框
	self.m_down_user_info_dialog_view = self.m_root_view:getChildByName("down_user_info_view");
	self.m_down_user_info_dialog = new(UserInfoDialog,self.m_down_user_info_dialog_view,"down_user_info_");
    self.m_down_user_info_dialog:setAddFunc(self,self.onAddBtnClick);
	self.m_down_chessframe = self.m_down_user_info_dialog_view:getChildByName("down_user_info_dialog"):getChildByName("down_chessframe_bg");
    self.m_down_chess_pc = {};
    self.m_down_chess_num = {};
	for i = 1 ,7 do
		self.m_down_chess_pc[i] = self.m_down_chessframe:getChildByName("down_chess" .. i .. "_pc" );
		self.m_down_chess_num[i] = self.m_down_chess_pc[i]:getChildByName("down_chess" .. i .. "_num");
		self.m_down_chess_pc[i]:setVisible(false);
		self.m_down_chess_num[i]:setVisible(false);
	end

	--下部信息
	self.m_down_view = self.m_root_view:getChildByName("down_model");   --上部玩家及一些信息模块
	self.m_down_user_icon_bg = self.m_down_view:getChildByName("down_user_icon_bg");
	self.m_down_user_icon_frame_mask = self.m_down_user_icon_bg:getChildByName("down_user_icon_frame_mask");
    self.m_down_user_level_icon = self.m_down_user_icon_bg:getChildByName("down_user_level_icon");
    self.m_down_user_disconnect = self.m_down_user_icon_bg:getChildByName("down_user_disconnect");
    self.m_down_vip_frame = self.m_down_user_icon_bg:getChildByName("vip_frame");
    self.m_down_vip_logo =self.m_down_view:getChildByName("vip_logo");
    self.m_down_user_icon = new(Mask,"online/room/head_mask.png","online/room/head_mask.png");
    self.m_down_user_icon:setSize(self.m_down_user_icon_frame_mask:getSize());
    self.m_down_user_icon_frame_mask:addChild(self.m_down_user_icon);
--    self.m_down_user_icon:addChild(self.m_down_user_level_icon); -- 切换 level

	self.m_down_turn = self.m_down_user_icon_bg:getChildByName("down_turn");
    --下部头像动画
    self.m_down_breath1 = self.m_down_user_icon_frame_mask:getChildByName("breath1");
    self.m_down_breath1:setLevel(2);
    self.m_down_breath2 = self.m_down_user_icon_frame_mask:getChildByName("breath2");
    self.m_down_breath2:setLevel(2);

	self.m_down_timeframe = self.m_down_view:getChildByName("down_timeframe_bg");
	self.m_down_timeout1_name = self.m_down_timeframe:getChildByName("down_timeout1_name");
	self.m_down_timeout1_text = self.m_down_timeframe:getChildByName("down_timeout1_text");
	self.m_down_timeout2_name = self.m_down_timeframe:getChildByName("down_timeout2_name");
	self.m_down_timeout2_text = self.m_down_timeframe:getChildByName("down_timeout2_text");
	self.m_down_name = self.m_down_view:getChildByName("down_user_name");
	self.m_down_title = self.m_down_view:getChildByName("down_user_title");
	self.m_down_user_icon:setEventTouch(self,self.showDownUserInfo);
        --下部网络信息
    self.m_sinal_icon_arr = {"drawable/net_sinal_state_level0.png","drawable/net_sinal_state_level1.png","drawable/net_sinal_state_level2.png","drawable/net_sinal_state_level3.png","drawable/net_sinal_state_level4.png","drawable/net_sinal_state_level_none.png"};
	self.m_net_state_view = self.m_down_view:getChildByName("net_state_view");
	self.m_net_state_view_bg = self.m_net_state_view:getChildByName("net_state_view_bg");

    self.m_toast_bg = self.m_root_view:getChildByName("toast_bg");
    self.m_toast_text = self.m_toast_bg:getChildByName("toast_text");

    self.m_board_bg = self.m_board_view:getChildByName("board_view"):getChildByName("board_bg");

	--准备开始模块
	self.m_up_user_ready_img = self.m_board_view:getChildByName("board_view"):getChildByName("board_bg"):getChildByName("up_user_ready_img");  --上准备图片
	self.m_down_user_ready_img = self.m_board_view:getChildByName("board_view"):getChildByName("board_bg"):getChildByName("down_user_ready_img"); -- 下准备图片
	self.m_down_user_start_btn = self.m_board_view:getChildByName("down_user_start_btn"); --下开始按钮
	self.m_down_user_start_btn:setLevel(BUTTON_VISIBLE_LEVEL);
	self.m_down_user_start_btn:setOnClick(self,self.ready_action);
    self.m_private_change_player_btn = self.m_board_view:getChildByName("private_change_player_btn"); --下开始按钮  
    self.m_private_change_player_btn:setLevel(BUTTON_VISIBLE_LEVEL);
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

    --下部菜单模块
	self.m_room_menu_view = self.m_root_view:getChildByName("room_menu");
	self.m_chat_btn = self.m_room_menu_view:getChildByName("chat_btn");     --聊天按钮
	self.m_menu_btn = self.m_room_menu_view:getChildByName("menu_btn");     --菜单按钮
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

--    if UserInfo.getInstance():getIsVip() == 1 then
--        self.m_board_bg:setFile("vip/vip_chess_board.png");
--    end
    require(MODEL_PATH.."online/onlineRoom/module/onlineRoomModule");
    require(MODEL_PATH.."online/onlineRoom/module/watchRoomModule");
    require(MODEL_PATH.."online/onlineRoom/module/customRoomModule");
    require(MODEL_PATH.."online/onlineRoom/module/friendRoomModule");
    self:onLineRoomInitView();
    self:onWatchRoomInitView();
    self:onCustomRoomInitView();
    self:onFriendRoomInitView();

    self:onResetGame();
   
end

--根据房间类型的初始化界面
OnlineRoomSceneNew.initGame = function(self)
    local game_type = UserInfo.getInstance():getGameType();
	print_string("OnlineRoomSceneNew.load game_type = " .. game_type);
    if game_type == GAME_TYPE_WATCH then            --观战
        OnlineRoomSceneNew.s_privateFunc = WatchRoomModule.s_privateFunc;
    elseif game_type == GAME_TYPE_CUSTOMROOM then   --私人战
        OnlineRoomSceneNew.s_privateFunc = CustomRoomModule.s_privateFunc;
	elseif game_type == GAME_TYPE_FRIEND then       --好友战   
        OnlineRoomSceneNew.s_privateFunc = FriendRoomModule.s_privateFunc;
    else
        OnlineRoomSceneNew.s_privateFunc = OnlineRoomModule.s_privateFunc;
    end

    OnlineRoomSceneNew.s_privateFunc.initGame(self);
end;

--房间下棋公共需要显示的
OnlineRoomSceneNew.onBaseRoomInitGame = function(self)

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
	self.m_menu_btn:setVisible(true);       --底部菜单栏【菜单按钮】
	self.m_down_name:setVisible(true);
	self.m_up_name:setVisible(true);
    self.m_net_state_view:setVisible(true);
	self.m_net_state_view_bg:setVisible(true);
    self:showNetSinalIcon(true);
end

--重置房间界面（切换房间类型的时候使用，重置数据、重置界面可见性、重置dialog可见性）
OnlineRoomSceneNew.onResetGame = function(self)
    --初始化数据
    self:initValues();
    --初始化可见性 
	self.m_up_user_ready_img:setVisible(false);     --隐藏上部准备图片
	self.m_down_user_ready_img:setVisible(false);   --隐藏下部准备图片
	self.m_up_user_icon:setVisible(false);          --隐藏上部玩家头像
	self.m_up_turn:setVisible(false);
    self.m_down_user_icon:setVisible(false);          --隐藏上部玩家头像
	self.m_down_turn:setVisible(false);
    self.m_up_user_info_dialog_view:setVisible(false);
    self.m_down_user_info_dialog_view:setVisible(false);
	self:setTimeFrameVisible(false);
    self.m_down_user_start_btn:setVisible(false);
    self.m_private_change_player_btn:setVisible(false);
    self.m_board:dismissChess();        --隐藏棋子
    self.m_up_vip_logo:setVisible(false);  --隐藏上部玩家vip图标
    self.m_up_vip_frame:setVisible(false);
    self.m_wait_tips:setVisible(false);

    self:onLineRoomResetGame();
    self:onCustomRoomResetGame();
    self:onFriendRoomResetGame();
    self:onWatchRoomResetGame();
    self:onDismissDialog();
end

--隐藏弹窗
OnlineRoomSceneNew.onDismissDialog = function(self)
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
	if self.m_setting_dialog and self.m_setting_dialog:isShowing() then
		print_string("self.m_setting_dialog is showing ");
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
    if self.m_loading_dialog and self.m_loading_dialog:isShowing() then
		self.m_loading_dialog:dismiss();
	end
    if self.m_roomSetTimeDialog and self.m_roomSetTimeDialog:isShowing() then
        self.m_roomSetTimeDialog:dismiss();
    end
    if self.m_roomOtherSetTimeDialog and self.m_roomOtherSetTimeDialog:isShowing() then
        self.m_roomOtherSetTimeDialog:dismiss();
    end
    if self.m_friendChoiceDialog and self.m_friendChoiceDialog:isShowing() then
        self.m_friendChoiceDialog:dismiss();
    end

    self:onLineRoomDismissDialog();
    self:onCustomRoomDismissDialog();
    self:onFriendRoomDismissDialog();
    self:onWatchRoomDismissDialog();
end

--清理房间数据（退出房间或者切换房间类型之前调用）
OnlineRoomSceneNew.clearRoomInfo = function(self)
    --重置房间配置
	UserInfo.getInstance():setTid(0);       --房间ID号
	UserInfo.getInstance():setSeatID(0);    --
    UserInfo.getInstance():setOBSvid(0);    --    
    UserInfo.getInstance():setMoneyType(0); --房间金币类型（--1初级、2中级、3大师、4私人、5好友）
    UserInfo.getInstance():setRoomLevel(0); --房间level，和Server统一(联网初级201，中级202，高级203，自定义300，好友房320)
	UserInfo.getInstance():setGameType(GAME_TYPE_UNKNOW); --房间类型
	UserInfo.getInstance():setStatus(STATUS_PLAYER_LOGOUT); --个人状态
	self:stopTimeout(); --停止游戏计时
    self:setStatus(STATUS_TABLE_STOP);  --房间状态重置
	ToolKit.removeAllTipsDialog(); 
    self.m_login_succ = false
    if self.m_upUser then
        self:userLeave(self.m_upUser:getUid(),false);
    end;
    self.m_up_user_disconnect:setVisible(false);
    self.m_down_user_disconnect:setVisible(false);
    self.m_board:dismissChess();
    self.m_multiple_text:setText("倍数 1");
end;

--更换房间，清理部分数据（在匹配成功后点击更换对手）
OnlineRoomSceneNew.clearChangeInfo = function(self)
    --重置房间配置
	UserInfo.getInstance():setTid(0);       --房间ID号
	UserInfo.getInstance():setSeatID(0);    --
    UserInfo.getInstance():setOBSvid(0);    --    
	UserInfo.getInstance():setGameType(GAME_TYPE_UNKNOW); --房间类型
    UserInfo.getInstance():setStatus(STATUS_PLAYER_LOGOUT); --个人状态
    self:stopTimeout(); --停止游戏计时
    self:setStatus(STATUS_TABLE_STOP);  --房间状态重置
    ToolKit.removeAllTipsDialog(); 
    self.m_board:dismissChess();
    self.m_multiple_text:setText("倍数 1");
    self.changeRoom = false;

    self.m_up_user_icon:setFile(User.MAN_ICON);
	HeadSmogAnim.play(self.m_up_user_icon);
    self.m_up_name:setText("");
    self.m_up_turn:setVisible(false);
	self.m_up_user_icon:setVisible(false);
	self.m_up_user_ready_img:setVisible(false);
    self.m_up_vip_frame:setVisible(false);
    self.m_up_vip_logo:setVisible(false);
    self.m_board:dismissChess();
    self.m_upUser = nil;
    if self.m_roomSetTimeDialog then
        self.m_roomSetTimeDialog:dismiss();
    end
    if self.m_roomOtherSetTimeDialog then
        self.m_roomOtherSetTimeDialog:dismiss();
    end
    self.m_up_user_disconnect:setVisible(false);
    self.m_down_user_disconnect:setVisible(false);

    if self.m_match_dialog then
        if not self.m_match_dialog:isShowing() then
            self.m_match_dialog:setVisible(true);
        end
        self.m_login_succ = false
--        self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_logout);
        self.m_matchIng = true;
        self.m_match_dialog:rematch();
    end

--    self:matchRoom(true);
end

--游戏是否结束
OnlineRoomSceneNew.isGameOver = function(self)
	return self.m_game_over;
end

--设置房间类型
OnlineRoomSceneNew.setGameType =function(self,gametype)
	self.m_gametype = gametype;
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
	end

	if self.m_upUser then
		self.m_up_user_ready_img:setVisible(self.m_upUser:getReadyVisible());
	end

	local game_type = UserInfo.getInstance():getGameType();

	if game_type == GAME_TYPE_WATCH then  --如果是观战状态  --不要显示开始按键
		self.m_down_user_start_btn:setVisible(false);
        self.m_private_change_player_btn:setVisible(false);
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
end;

--Socket连接失败
OnlineRoomSceneNew.onHandleConnSocketFail = function(self)
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

OnlineRoomSceneNew.showConnectFailedDialog = function(self,isSetting)
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

OnlineRoomSceneNew.openSocketConnecting = function(self)
	local tips = "正在重新与服务器连接..."
    ProgressDialog.show(tips , true, nil,nil);
    self.m_connecting = true;
    self.m_connectCount =0;
    UserInfo.getInstance():setRelogin(true) 
    self:openSocket()
end

OnlineRoomSceneNew.startWirelessSetting = function(self)
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

OnlineRoomSceneNew.closeSocket = function(self)
--    self:requestCtrlCmd(OnlineRoomController.s_cmds.close_room_socket);
end;

OnlineRoomSceneNew.openSocket = function(self)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.open_room_socket);
end;

OnlineRoomSceneNew.setBoradCode = function(self, code)
    self.m_boradcode = code;
end;

OnlineRoomSceneNew.stopHeartBeat = function(self)
	delete(self.m_heartBeatAnim);
	self.m_heartBeatAnim = nil;
end

OnlineRoomSceneNew.sharePicture = function(self)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.sharePicture);
end;
--------------------------------private function end-------------------------------

--------------------------------response function---------------------------------
--[[
    联网房流程：初始化房间->下(上)部玩家进入->匹配对手->登陆房间->准备->设置局时(抢先、让子)->Server通知游戏开始->下棋(悔棋、聊天、求和、认输)->棋局结束
    私人流程：初始化房间->下(上)部玩家进入->登陆房间->准备->Server通知游戏开始->开始下棋->棋局结束
    好友流程：初始化房间->下(上)部玩家进入->登陆房间->准备(同时发起挑战邀请)->设置局时(抢先、让子)->Server通知游戏开始->开始下棋->棋局结束
    观战流程：
    *注意断线重连部分
--]]
OnlineRoomSceneNew.onRoomTouch = function(self,finger_action, x, y)

end

--登陆房间成功
OnlineRoomSceneNew.onClientUserLoginSucc = function(self, data)
    self.m_login_succ = true;
    if data.user then
        if self.m_match_dialog and self.m_match_dialog:isShowing() then
	        self:onMatchSuccess(data);  
	    end
        self:upComeIn(data.user);
    end;
    if UserInfo.getInstance():getGameType() ~= GAME_TYPE_WATCH then
        self:downComeIn(UserInfo.getInstance());
    end
end;

--登陆房间失败
OnlineRoomSceneNew.onClientUserLoginError = function(self, data)
   
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

--准备
OnlineRoomSceneNew.ready_action = function(self)
	print_string("OnlineRoomSceneNew.ready_action");
    self:onEventStat(ROOM_MODEL_START_BTN);
    
	local gold_type = UserInfo.getInstance():getMoneyType();
	local ctype = UserInfo.getInstance():canAccessRoom(gold_type);
	print_string("AccountDialog.canContinue .. ctype" .. ctype);
	if ctype == 0 then
		--破产
		self:collapse();
		return;
	end

    if self.m_down_user_start_btn then              --不知道为什么会被释放了，友盟BUG跟踪修复
	    self.m_down_user_start_btn:setVisible(false);
    end
    self.m_private_change_player_btn:setVisible(false);

    self.m_ready_status = true;
    self:requestCtrlCmd(OnlineRoomController.s_cmds.send_ready_msg);
	self.m_board:dismissChess();
    self.m_board_menu_dialog:dismiss();
    self.m_multiple_text:setText("倍数 1");

	OnlineRoomSceneNew.s_privateFunc.ready_action(self);
end

--下部玩家进入
OnlineRoomSceneNew.downComeIn = function(self, user, need_ready)
    Log.i("OnlineRoomSceneNew.onDownUserComeIn");
    if not self.m_downUser and self.m_down_user_icon then
	    HeadSmogAnim.play(self.m_down_user_icon);
    end
	self.m_downUser = user;
    self.m_down_user_level_icon:setFile(string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevelByScore(user:getScore())));
    self.m_down_name:setText(user:getName());
	self.m_down_user_icon:setFile(UserInfo.DEFAULT_ICON[1]);
	self.m_down_user_icon:setVisible(true);
    self.m_down_user_disconnect:setVisible(false);
	local iconType = tonumber(self.m_downUser:getIconType());
        
    if iconType and iconType > 0 then
        self.m_down_user_icon:setFile(UserInfo.DEFAULT_ICON[iconType] or UserInfo.DEFAULT_ICON[1]);
    else
        if iconType == -1 then
            self.m_down_user_icon:setUrlImage(self.m_downUser:getIcon(),UserInfo.DEFAULT_ICON[1]);
        end
    end

	self.m_down_user_ready_img:setVisible(self.m_downUser:getReadyVisible());
	
	if need_ready then
		self.m_down_user_start_btn:setVisible(self.m_downUser:getStartVisible());
   	end

    local nx,nt = self.m_down_name:getPos();
    local vw,vh = self.m_down_vip_logo:getSize();
    local text = new(Text,self.m_down_name:getText(),nil,nil,nil,nil,32);
    local nw,nh = text:getSize();
    if self.m_downUser and self.m_downUser.m_is_vip and self.m_downUser.m_is_vip == 1 then
        if not WatchRoomModule.IS_NEW then
            self.m_down_vip_logo:setPos(nx - nw/2 - vw/2 - 3);
        end;
        self.m_down_vip_frame:setVisible(true);
        self.m_down_vip_logo:setVisible(true)
    elseif self.m_downUser and self.m_downUser.m_vip and self.m_downUser.m_vip == 1 then
        if not WatchRoomModule.IS_NEW then
            self.m_down_vip_logo:setPos(nx - nw/2 - vw/2 - 3);
        end;
        self.m_down_vip_frame:setVisible(true);
        self.m_down_vip_logo:setVisible(true);
    else
        if not WatchRoomModule.IS_NEW then
            self.m_down_vip_logo:setPos(nx - nw/2 - vw/2 - 3);
        end;
        self.m_down_vip_frame:setVisible(false);
        self.m_down_vip_logo:setVisible(false);
    end
end;

--上部玩家进入
OnlineRoomSceneNew.upComeIn = function(self, user, isSynDataComeIn)
    Log.i("OnlineRoomSceneNew.onUpUserComeIn");
    if not user then
        return;
    end
--    self:hideSelectPlayerDialog();--有玩家进来了，隐藏选择框

    if isSynDataComeIn and user:getUid()<=0 then
		self.m_up_user_icon:setVisible(false);
		self.m_up_user_ready_img:setVisible(false);

		self.m_up_name:setText("");
    else
        local game_type = UserInfo.getInstance():getGameType();
	    if game_type <= GAME_TYPE_TWENTY  then
            if user:getClient_version() > 0 and user:getClient_version() < 195 and not self.m_canSetTimeFlag then     --低于1.9.5版本不支持局时设置
                ChessToastManager.getInstance():show("对方版本不支持设置局时",2000);
                self.m_canSetTimeFlag = true;
            end
	    end
        if not self.m_upUser and self.m_up_user_icon then
		    HeadSmogAnim.play(self.m_up_user_icon);
        end
	    self.m_upUser = user;
        self.m_private_change_player_btn:setPickable(self.m_upUser ~= nil);
        self.m_private_change_player_btn:setGray(self.m_upUser == nil);

--        if self.m_upUser then
--            self.m_private_change_player_btn:setFile({"common/button/change_player_pre.png","common/button/change_player_nor.png"});
--        else
--            self.m_private_change_player_btn:setFile({"common/button/invite_friend_btn_pre.png","common/button/invite_friend_btn_nor.png"});
--        end

        self.m_up_user_level_icon:setFile(string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevelByScore(user:getScore())));
        --iconType有2类值，一种是头像url（对手头像是本地上传的）。一种是数字0（对手没有传过头像），1，2，3，4（系统自带的头像）
        self.m_up_user_icon:setFile(UserInfo.DEFAULT_ICON[1]);
        self.m_up_user_disconnect:setVisible(false);
        
        local iconType = tonumber(self.m_upUser:getIconType());
        
        if iconType and iconType > 0 then
            self.m_up_user_icon:setFile(UserInfo.DEFAULT_ICON[iconType] or UserInfo.DEFAULT_ICON[1]);
        else
            if iconType == -1 then
                self.m_up_user_icon:setUrlImage(self.m_upUser:getIcon(),UserInfo.DEFAULT_ICON[1]);
            end
        end
		self.m_up_user_icon:setVisible(true);
		self.m_up_user_ready_img:setVisible(self.m_upUser:getReadyVisible());
		self.m_up_name:setText(user:getName());

        local nx,nt = self.m_up_name:getPos();
        local vw,vh = self.m_up_vip_logo:getSize();
        local text = new(Text,self.m_up_name:getText(),nil,nil,nil,nil,32);
        local nw,nh = text:getSize();
        if self.m_upUser and self.m_upUser.m_vip and self.m_upUser.m_vip == 1 then
            if not WatchRoomModule.IS_NEW then
                self.m_up_vip_logo:setPos(nx - nw/2 - vw/2 - 3);
            end;
            self.m_up_vip_frame:setVisible(true);
            self.m_up_vip_logo:setVisible(true)
        else
            if not WatchRoomModule.IS_NEW then
                self.m_up_vip_logo:setPos(nx - nw/2 - vw/2 - 3);
            end;
            self.m_up_vip_frame:setVisible(false);
            self.m_up_vip_logo:setVisible(false);
        end
        print_string("Room.upComeIn name = " .. self.m_upUser:getName());
 
    end
end;

--服务器通知对手进入
OnlineRoomSceneNew.onClientOppUserLogin = function(self, data)
    if data.user then
        if self.m_match_dialog and self.m_match_dialog:isShowing() then
	        self:onMatchSuccess(data);  
	    end
        self:upComeIn(data.user);
    end;
end;

--服务器通知准备状态
OnlineRoomSceneNew.onServerMsgReady = function(self, data)
    if data.uid == UserInfo.getInstance():getUid() then
	    self.m_down_user_ready_img:setVisible(true);
    else
        self.m_up_user_ready_img:setVisible(true);
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
    self.m_multiple_text:setText("倍数 "..data.multiply);
    self:onDismissDialog();
    self:startGame(data.chess_map);
    self:setStatus(STATUS_TABLE_PLAYING,data.uid);
    self.m_game_start = true;
end;

--游戏开始
OnlineRoomSceneNew.startGame = function(self,chess_map)
    self.m_start_time = os.time();
    self.up_leave = false;
	self.m_game_over = false;
    self.m_first_move = false;
	self.m_had_syn_data = false;
    self.m_board_menu_dialog:dismiss();
    self:onDeleteInvitAnim();
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

    if self.m_countdownAnim then
        self.m_countdownAnim:stop();
        delete(self.m_countdownAnim);
        self.m_countdownAnim = nil;
    end
    self.upstartanim = false;
    self.downstartanim = false;
	self:stopTimeout();
	self:startTimeout();

    self.m_room_watcher_btn:setEnable(true);
    self.m_private_change_player_btn:setVisible(false);
    self.m_wait_tips:setVisible(false);
end

--开始游戏计时
OnlineRoomSceneNew.startTimeout = function(self)
	self:stopTimeout();
	if self.m_gametype <= GAME_TYPE_TWENTY or self.m_gametype == GAME_TYPE_CUSTOMROOM or self.m_gametype == GAME_TYPE_FRIEND then
		self:setTimeFrameVisible(true);
		self.m_timeoutAnim = new(AnimInt,kAnimRepeat,0,1,1000,-1);
        
		self.m_timeoutAnim:setDebugName("Room.startTimeout.m_timeoutAnim");
		self.m_timeoutAnim:setEvent(self,self.timeoutRun);
	end
end

OnlineRoomSceneNew.timeoutRun = function(self)
	if self.m_downUser and self.m_downUser:getFlag() == self.m_move_flag then
--        if not self.timeout_pause then
		    self.m_downUser:timeout1__();
		    self.m_downUser:timeout2__();
		    self.m_downUser:timeout3__();

            if UserInfo.getInstance():getGameType() ~= GAME_TYPE_WATCH then
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
        if not self.downstartanim then
            self:startAnim1(true,timeout_ten);
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
            if self.m_countdownAnim then
                self.m_countdownAnim:stop();
                delete(self.m_countdownAnim);
                self.m_countdownAnim = nil;
                self.m_down_breath1:setVisible(false);
                self.m_down_breath2:setVisible(false);
            end
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
        if not self.upstartanim then
            self:startAnim1(false,timeout_ten);
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

            if self.m_countdownAnim then
                self.m_countdownAnim:stop();
                delete(self.m_countdownAnim);
                self.m_countdownAnim = nil;
                self.m_up_breath1:setVisible(false);
                self.m_up_breath2:setVisible(false);
            end
            self.downstartanim = false;
            self.upstartanim = false;
        end
	end

	--步时还是读秒
	if self.m_upUser and  self.m_upUser:isTimeout() then
		if not self.m_up_setTimeoutFile then 
			self.m_up_timeout2_name:setText("读秒:");   --设置成读秒
			self.m_up_setTimeoutFile = true;
			self.m_up_setUnTimeoutFile = false;
		end
	else
		if not self.m_up_setUnTimeoutFile then
			self.m_up_timeout2_name:setText("步时:");   --设置成步时
			self.m_up_setUnTimeoutFile = true;
			self.m_up_setTimeoutFile = false;
		end
	end

	if self.m_downUser:isTimeout() then
		if not self.m_down_setTimeoutFile then 
			self.m_down_timeout2_name:setText("读秒:");    --设置成读秒
			self.m_down_setTimeoutFile = true;
			self.m_down_setUnTimeoutFile = false;
		end
	else
		if not self.m_down_setUnTimeoutFile then
			self.m_down_timeout2_name:setText("步时:");  --设置成步时
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
    if self.m_countdownAnim and self.m_upUser and self.m_upUser:getFlag() == self.m_move_flag then
        self.m_countdownAnim:pause();
    end
end

OnlineRoomSceneNew.runTimout = function(self)
    self.timeout_pause = false;
    if self.m_countdownAnim then
        self.m_countdownAnim:run();
    end
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
        self.m_up_user_disconnect:setVisible(isDisconnect);
    elseif self.m_downUser and self.m_downUser:getUid() == uid then
        self.m_down_user_disconnect:setVisible(isDisconnect);
    end
end


OnlineRoomSceneNew.onSaveMyChess = function(self,data)
    if not data then return end;
    if data.cost then
        if data.cost > 0 then 
            ChessToastManager.getInstance():showSingle("收藏成功！",2000);
            if self.m_account_dialog and self.m_account_dialog:isShowing() then
                self.m_account_dialog:setHasSaved();
            end;
            self:exitRoom();
        elseif data.cost == 0 then
            ChessToastManager.getInstance():showSingle("您已经收藏过了！",1000);
        elseif data.cost == -1 then
            -- -1是老版本本地棋谱上传成功
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
    self.m_down_breath1:setVisible(false);
    self.m_down_breath2:setVisible(false);
    self.m_up_breath1:setVisible(false);
    self.m_up_breath2:setVisible(false);
end

OnlineRoomSceneNew.onTimer = function(data)
    self = data.room
    if self.timeout_pause and self.m_upUser and self.m_upUser:getFlag() == self.m_move_flag then return end
    local ret = data.ret;
    local index = self.index;
    if ret then
        if index == 0 then
            self.m_down_breath1:setVisible(false);
            self.m_down_breath2:setVisible(false);
        elseif index == 1 then
            self.m_down_breath1:setVisible(true);
            self.m_down_breath2:setVisible(false);
        elseif index == 2 then
            self.m_down_breath1:setVisible(false);
            self.m_down_breath2:setVisible(true);
        elseif index == 3 then
            self.m_down_breath1:setVisible(true);
            self.m_down_breath2:setVisible(false);
            self.index = 0;
            return;
        end
        self.index = self.index + 1;
    else
        if index == 0 then
            self.m_up_breath1:setVisible(false);
            self.m_up_breath2:setVisible(false);
        elseif index == 1 then
            self.m_up_breath1:setVisible(true);
            self.m_up_breath2:setVisible(false);
        elseif index == 2 then
            self.m_up_breath1:setVisible(false);
            self.m_up_breath2:setVisible(true);
        elseif index == 3 then
            self.m_up_breath1:setVisible(true);
            self.m_up_breath2:setVisible(false);
            self.index = 0;
            return;
        end
        self.index = self.index + 1;
    end
end

--倒计时圆圈
OnlineRoomSceneNew.startAnim1 = function(self,ret,time)
    --false  上部计时动画  true 下部计时动画
    self.index = 0;
    if ret then
        delete(self.m_countdownAnim);
        self.m_countdownAnim = new(CountDown,self.m_down_turn,self,time);
        self.downstartanim = true;
    else
        delete(self.m_countdownAnim);
        self.m_countdownAnim = new(CountDown,self.m_up_turn,self,time);
        self.upstartanim = true;
    end
    self.m_countdownAnim:start();
    if self.timeout_pause and self.m_upUser and self.m_upUser:getFlag() == self.m_move_flag then
        self.m_countdownAnim:pause();
    end
end

OnlineRoomSceneNew.stopAnim1 = function(self)
    delete(self.m_countdownAnim);
    self.m_countdownAnim = nil;
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
	self.m_up_timeout1_name:setVisible(flag);
	self.m_up_timeout1_text:setVisible(flag);
	self.m_up_timeout2_name:setVisible(flag);
	self.m_up_timeout2_text:setVisible(flag);

	self.m_down_timeout1_name:setVisible(flag);
	self.m_down_timeout1_text:setVisible(flag);
	self.m_down_timeout2_name:setVisible(flag);
	self.m_down_timeout2_text:setVisible(flag);
end

--断线重连房间信息同步
OnlineRoomSceneNew.onServerMsgReconnect = function(self, data)
    if not data then
        return;
    end;
    self.m_login_succ = true;--断线重连进来设置为true,否则登出房间时不会发logout命令
	self:onClientMsgSyndata(data);
end;

--同步服务器
OnlineRoomSceneNew.onClientMsgSyndata = function(self, data)
    if not data then
        return;
    end;
	self.m_timeout1 = data.round_time;
	self.m_timeout2 = data.step_time;
	self.m_timeout3 = data.sec_time;
    self.m_down_user_start_btn:setVisible(false);
    self.m_private_change_player_btn:setVisible(false);
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
--        if data.opp_is_back then
--            if data.opp_is_back == 1 then
--                self:callTelphoneResponse(data.opp_wait_time);
--            else
--                self:callTelphoneBack();
--                Log.e("--------------------> 对手先返回棋局。。（断线重连后）");
--            end
--        end
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
        local game_type = UserInfo.getInstance():getGameType();
        if game_type == GAME_TYPE_WATCH then            --观战
        elseif game_type == GAME_TYPE_CUSTOMROOM then   --私人战
            self.m_private_change_player_btn:setVisible(true);
	    elseif game_type == GAME_TYPE_FRIEND then       --好友战   
        else
        end
        self.m_game_start = false;
        self.m_down_user_start_btn:setVisible(true);
    end;
    self:setStatus(data.status);
    self:hideSelectPlayerDialog();
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
	if multiply ~=nil then
		self.m_multiple_text:setText("倍数 "..multiply);
	else
		self.m_multiple_text:setText("倍数 1");
	end

	self:stopTimeout();
	self:startTimeout();
end

--显示相应场次金币消耗
OnlineRoomSceneNew.showMoneyRent = function(self)

	if self.m_gametype <= GAME_TYPE_TWENTY then
        local roomtype = UserInfo.getInstance():getMoneyType() or 0;
        if roomtype == UserInfo.getInstance():getRoomConfigById(4).money then
            self.m_roominfo = UserInfo.getInstance():getRoomConfigById(4);--4为私人房
        elseif UserInfo.getInstance():getGameType() == GAME_TYPE_FRIEND then
            self.m_roominfo = UserInfo.getInstance():getRoomConfigById(5);--5为好友房
        else
	        self.m_roominfo = UserInfo.getInstance():getRoomConfigById(roomtype);
        end
        if self.m_roominfo then
		    local money = self.m_roominfo.rent ;
		    local message = string.format("该场次每局消耗%d金币",money);
		    --ShowMessageAnim.play(self.m_root_view,message);
		    ChatMessageAnim.play(self.m_root_view,3,message);
    --        ChessToastManager.getInstance():showSingle(message);
        end
	end
end

--跳转到观战列表
OnlineRoomSceneNew.gotoWatchList = function(self)
    require(MODEL_PATH.."watchlist/watchlistScene");
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
--    StateMachine.getInstance():pushState(States.watchlist,StateMachine.STYPE_WAIT);
end

--获取在线宝箱
OnlineRoomSceneNew.chest_action = function(self)
	if OnlineConfig.isReward  then
        OnlineConfig.deleteOpenBoxTimer();
        self:requestCtrlCmd(OnlineRoomController.s_cmds.room_get_reward, OnlineConfig.getOpenboxid());
	end
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

--更新道具信息，单机游戏，不应该摆在这里
 OnlineRoomSceneNew.onUpdatePropInfo = function(self,data)

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
	self.m_net_state_view_bg:setFile(self.m_sinal_icon_arr[level]);
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

--显示下部玩家的详细信息弹窗
OnlineRoomSceneNew.showDownUserInfo = function(self,finger_action, x, y)
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
	if self:isEnableUndo() or self.isUndoAble then
        local message = "确认向对方支付一定金币请求悔棋"
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
		self:undo();
	else
		local message = "亲，现在还不能悔棋!"
		ChessToastManager.getInstance():showSingle(message);
	end
end

--发送悔棋请求
OnlineRoomSceneNew.undo = function(self)  
	self:onEventStat(ROOM_MODEL_MENU_UNDO_BTN);
	if UserInfo.getInstance():getGameType() == GAME_TYPE_COMPUTER then  --单机（残留）
		self.m_board:consoleUndoMove();
	else
        self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_undomove, 1);
	    self:setEnableUndo(false);
	    self.isUndoAble = false;
	end
end

--游戏设置弹窗
OnlineRoomSceneNew.setting = function(self)
	self:onEventStat(ROOM_MODEL_MENU_SET_BTN);

	self.m_board_menu_dialog:dismiss();

	if not self.m_setting_dialog then
		self.m_setting_dialog = new(SettingDialog);
	end

	self.m_setting_dialog:show();
end

--未知
OnlineRoomSceneNew.chess = function(self)
	local event_info = DOWN_MODEL_DAPU_BTN .. "," .. self.m_stat_place;
	on_event_stat(event_info); --事件统计
	self.m_board_menu_dialog:dismiss();
	if UserInfo.getInstance():getDapuEnable() == false then
		self:buyDapu(ONLINE_ROOM_MENU_DAPU);
		return;
	end

	ToolKit.removeAllTipsDialog(); 
	StateMachine.getInstance():pushState(States.dapu,StateMachine.STYPE_CUSTOM_WAIT);
end

--发起认输弹窗
OnlineRoomSceneNew.surrender = function(self)
	self:onEventStat(ROOM_MODEL_MENU_SURRENDER_BTN);
    self.m_start_time = self.m_start_time or os.time();  -- 防止 self.m_start_time 为空情况
    local time = os.time();
    if self.m_roominfo and self.m_roominfo.give_up_time and time - self.m_start_time >= 0 and time - self.m_start_time < self.m_roominfo.give_up_time then
        ChessToastManager.getInstance():showSingle(string.format("%d 秒后才能投降",math.ceil(self.m_roominfo.give_up_time - time + self.m_start_time)));
        return ;
    end
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

--发送认输请求
OnlineRoomSceneNew.surrender_sure = function(self)
	if UserInfo.getInstance():getGameType() == GAME_TYPE_COMPUTER then  --单机
		self:console_gameover(self.m_upUser:getFlag(),ENDTYPE_SURRENDER);
	else
        self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_surrender1);
	end
end

--发起求和弹窗
OnlineRoomSceneNew.draw = function(self)
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
	self.m_chioce_dialog:setMode();
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

			self.m_up_chess_pc[i]:getChildByName("texture"):setFile(file);
			self.m_up_chess_pc[i]:setVisible(true);
			self.m_up_chess_num[i]:setVisible(false);
		elseif dieChess[upflag +i ] > 1 and dieChess[upflag +i ] <= 5 then
			local fileStr = piece_resource_id[upflag +i] .. ".png";
 			local file = Board.boardres_map[fileStr];

			self.m_up_chess_pc[i]:getChildByName("texture"):setFile(file);
			self.m_up_chess_pc[i]:setVisible(true);
			self.m_up_chess_num[i]:getChildByName("text"):setText(dieChess[upflag +i ]);
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
			local fileStr = piece_resource_id[downflag +i] .. ".png";
 			local file = Board.boardres_map[fileStr];

			self.m_down_chess_pc[i]:getChildByName("texture"):setFile(file);
			self.m_down_chess_pc[i]:setVisible(true);
			self.m_down_chess_num[i]:setVisible(false);
		elseif dieChess[downflag +i ] > 1 and dieChess[downflag +i ] <= 5 then
			local fileStr = piece_resource_id[downflag +i] .. ".png";
 			local file = Board.boardres_map[fileStr];


			self.m_down_chess_pc[i]:getChildByName("texture"):setFile(file);
			self.m_down_chess_pc[i]:setVisible(true);
			self.m_down_chess_num[i]:getChildByName("text"):setText(dieChess[downflag +i ]);
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

--重置棋子位置
OnlineRoomSceneNew.resetChessPos = function(self)
	for i = 1,7 do
		UserInfoDialog.down_chess_pos[i].available = true;
        UserInfoDialog.up_chess_pos[i].available = true;
	end
end

--隐藏棋子
OnlineRoomSceneNew.clearDiechess = function(self)
	for i = 1,7 do
		self.m_down_chess_pc[i]:setVisible(false);
		self.m_down_chess_num[i]:setVisible(false);

		self.m_up_chess_pc[i]:setVisible(false);
		self.m_up_chess_num[i]:setVisible(false);
	end
end

--设置棋局状态
OnlineRoomSceneNew.setStatus =function(self,status,op_uid)
	
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
	local gametype = UserInfo.getInstance():getGameType();
	if gametype == GAME_TYPE_WATCH then
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

--设置局时弹窗
OnlineRoomSceneNew.onSetTime = function(self,time_out)
    if self.m_friendChoiceDialog and self.m_friendChoiceDialog:isShowing() then
        return;
    end
    if not self.m_roomSetTimeDialog then
        self.m_roomSetTimeDialog = new(RoomFriendSetTime,UserInfo.getInstance():getRoomLevel());
    end
    self.m_roomSetTimeDialog:onSureFunc(self,self.onSetTimeFinish);
    self.m_roomSetTimeDialog:show(time_out);
end

OnlineRoomSceneNew.onSetTimeFinish = function(self,timeData)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.set_time_finish, timeData);
end

--显示对方设置的局时弹窗
OnlineRoomSceneNew.onSetTimeShow = function(self,data)
    if not self.m_roomOtherSetTimeDialog then
        self.m_roomOtherSetTimeDialog = new(RoomFriendSetTimeShow,UserInfo.getInstance():getRoomLevel());
    end
    self.m_roomOtherSetTimeDialog:onSureFunc(self,self.onSetTimeAgree);
    self.m_roomOtherSetTimeDialog:onCancleFunc(self,self.onSetTimeDisagree);
    self.m_roomOtherSetTimeDialog:show(data);
end

--重置游戏
OnlineRoomSceneNew.onReSetGame = function(self,flag)
    self:onDismissDialog();
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
            self.m_ready_time_anim:setDebugName("OnlineRoomSceneNew.m_ready_time_anim");
            self.m_ready_time_anim:setEvent(self,self.onReadyTime);
        end
    end
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
    local ctype = UserInfo.getInstance():canAccessRoom(5);
    if ctype ~= 5 then
        local post_data = {};
        post_data.uid = UserInfo.getInstance():getUid();
        post_data.target_uid = packageInfo.uid;
        post_data.ret = 1;
--        self:sendSocketMsg(FRIEND_CMD_FRIEND_INVIT_RESPONSE,post_data,nil,1);
        self:sendSocketMsg(FRIEND_CMD_FRIEND_INVIT_RESPONSE2,post_data,nil,1);
        return;
    end

    local friendData = FriendsData.getInstance():getUserData(packageInfo.uid);

    require("dialog/friend_chioce_dialog");
    if not self.m_friendChoiceDialog then
        self.m_friendChoiceDialog = new(FriendChoiceDialog);
    end
    self.m_friendChoiceDialog:setMode(1,friendData,packageInfo.time_out);
    self.m_friendChoiceDialog:setPositiveListener(self,
        function()
            self:onResetGame();
            UserInfo.getInstance():setTid(packageInfo.tid);
            UserInfo.getInstance():setGameType(10); 
            UserInfo.getInstance():setMoneyType(5); 
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

OnlineRoomSceneNew.onSetTimeDisagree = function(self)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.set_time_response, false);
end

OnlineRoomSceneNew.onSetTimeAgree = function(self)
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

	if not self.m_account_dialog then
		self.m_account_dialog = new(AccountDialog,self);
	end
    self.m_account_dialog:setLevel(1);
	if UserInfo.getInstance():getGameType() == GAME_TYPE_WATCH then
		self.m_account_dialog:show(self,self.m_game_over_flag,nil,GAME_TYPE_ONLINE);
		return;
	end
	self.m_account_dialog:show(self,self.m_game_over_flag,self.m_again_btn_timeout-2,GAME_TYPE_ONLINE);
	
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
--		local message = "本地棋库已达到"..UserInfo.getInstance():getSaveChessLimit().."条上限，您可以覆盖原棋谱保存新的棋谱，请问是否要继续保存新棋谱？";
--        local gametype = UserInfo.getInstance():getGameType();
--	    if gametype == GAME_TYPE_CUSTOMROOM  then
--            message = message.."（继续保存会退出当前房间）";
--        end
--		self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE);
--        self.m_chioce_dialog:setLevel(1);
--		self.m_chioce_dialog:setMessage(message);
--		self.m_chioce_dialog:setNegativeListener(self,self.cancelSaveMVList);
--		self.m_chioce_dialog:setPositiveListener(self,self.toDapuPage);
--		self.m_chioce_dialog:show();
--        return false;
	end
end

--进入打谱
OnlineRoomSceneNew.toDapuPage = function(self)
	local gametype = UserInfo.getInstance():getGameType();
	if gametype == GAME_TYPE_CUSTOMROOM  then
        self.m_customRoomExit = true;
    end
    ToolKit.removeAllTipsDialog(); 
    self:onDismissDialog();
	StateMachine.getInstance():pushState(States.dapu,StateMachine.STYPE_CUSTOM_WAIT);
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
   
    mvData.red_level = (self.m_downUser:getFlag() == 1 and  UserInfo.getInstance():getDanGradingLevelByScore(self.m_downUser.m_score) or UserInfo.getInstance():getDanGradingLevelByScore(self.m_upUser.m_score));
    mvData.black_level = (self.m_downUser:getFlag() == 1 and  UserInfo.getInstance():getDanGradingLevelByScore(self.m_upUser.m_score) or UserInfo.getInstance():getDanGradingLevelByScore(self.m_downUser.m_score));
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

    mvData.manual_type = (UserInfo.getInstance():getGameType() == GAME_TYPE_WATCH and 6) or 1;
--    mvData.start_fen = GameCacheData.getInstance():getString(GameCacheData.DAPU_LAST_BORAD_FEN,GameCacheData.NULL);
--    mvData.chessString = GameCacheData.getInstance():getString(GameCacheData.DAPU_LAST_CHESS_STR,GameCacheData.NULL);
--    mvData.move_list = table.concat(self.m_board:to_mvList(),GameCacheData.chess_data_key_split);
    mvData.createrName = "";
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

--再来一局
OnlineRoomSceneNew.sendReadyMsg = function(self)
    local game_type = UserInfo.getInstance():getGameType();
    if game_type == GAME_TYPE_CUSTOMROOM then
        self.m_ready_status = true;
        self:requestCtrlCmd(OnlineRoomController.s_cmds.send_ready_msg);
    elseif not self.m_upuser_leave then
--        self.m_upuser_leave = false;
        self.m_ready_status = true;
        self:requestCtrlCmd(OnlineRoomController.s_cmds.send_ready_msg);
    else
        self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_offline);
        self:matchRoom();
--        self:showSelectPlayerDialog();
    end;
end;

--展示悔棋结果
OnlineRoomSceneNew.resPonseUndoMove = function(self,data)   
	print_string("对手悔棋");

--	self.m_board:severUndoMove(data);
    self:synchroRequest(); -- 本地可能没有走棋数据改成同步服务器数据
	if UserInfo.getInstance():getUid() == self.OpponentID then
		self.m_downUser:setTimeout2(self.m_timeout2);
		if self.m_timeout2 then
			self.m_down_timeout2_text:setText(self.m_downUser:getTimeout2());
		end
		local message = "由于对方使用强制悔棋你将获得"..self.GetCoin.."金币的补偿";
		ChatMessageAnim.play(self.m_root_view,3,message);
--        ChessToastManager.getInstance():showSingle(message);
		self:resPonseUndoMoveSure();
	else
		self.m_upUser:setTimeout2(self.m_timeout2);
		if self.m_timeout2 then
			self.m_up_timeout2_text:setText(self.m_upUser:getTimeout2());
		end
	end
end

--展示悔棋结果金币设置
OnlineRoomSceneNew.resPonseUndoMoveSure = function(self)   
	local money = UserInfo.getInstance():getMoney() + self.GetCoin;
	UserInfo.getInstance():setMoney(money) ;
end

--发送聊天
OnlineRoomSceneNew.sendChat = function(self,msgType,message)
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
		local message = "玩家还没来不能聊天。"
        ChessToastManager.getInstance():showSingle(message);
		return;
	end

	if 	game_type == GAME_TYPE_WATCH then
		print_string("Room.showDownChat but GAME_TYPE_WATCH");
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
       if self.m_chat_btn:getChildByName("notice") and UserInfo.getInstance():getGameType() == GAME_TYPE_WATCH then
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
       if self.m_chat_btn:getChildByName("notice") and UserInfo.getInstance():getGameType() == GAME_TYPE_WATCH then
        self.m_chat_btn:getChildByName("notice"):setVisible(true);
       end 
    end
end

--关闭所有窗口
OnlineRoomSceneNew.game_close_dismiss_dialogs = function(self)
	print_string("OnlineRoomSceneNew.game_close_dismiss_dialogs ");
	if self.m_chioce_dialog and self.m_chioce_dialog:isShowing() then
		print_string("self.m_chioce_dialog is showing ");
		self.m_chioce_dialog:dismiss();
	end

	if self.m_chat_dialog and self.m_chat_dialog:isShowing() then
		print_string("self.m_chat_dialog is showing ");
		self.m_chat_dialog:dismiss();
	end

	if self.m_setting_dialog and self.m_setting_dialog:isShowing() then
		print_string("self.m_setting_dialog is showing ");
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
end

--登陆房间失败
OnlineRoomSceneNew.loginFail = function(self,message)
	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end
	self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE,"确定","收藏棋谱");
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
    self.m_account_save_dialog:setMessage("是否花费"..(self.m_save_cost or 500) .."金币收藏当前棋谱？");
    self.m_account_save_dialog:setPositiveListener(self, self.saveChesstoMysave);
    self.m_account_save_dialog:setNegativeListener(self, self.exitRoom);
    self.m_account_save_dialog:show();
end;




-- 收藏到我的收藏
OnlineRoomSceneNew.saveChesstoMysave = function(self,item)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.save_mychess,self.m_chioce_dialog:getCheckState());
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
	OnlineRoomSceneNew.s_privateFunc.back_action(self);
end

--强制离开
OnlineRoomSceneNew.onForceLeave = function(self,message)
    if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end
    self:onDismissDialog();
    self.m_chioce_dialog:setMessage(message or "棋局结束，请退出房间!");
    self.m_chioce_dialog:setMode();
    self.m_chioce_dialog:setPositiveListener(self,self.exitRoom);
    self.m_chioce_dialog:show();
end

--更新用户信息弹窗
OnlineRoomSceneNew.onUpdateUserInfoDialog = function(self,info)
    if self.m_up_user_info_dialog and self.m_up_user_info_dialog:isShowing() then
        self.m_up_user_info_dialog:update(info)
    end
    if self.m_down_user_info_dialog and self.m_down_user_info_dialog:isShowing() then
        self.m_down_user_info_dialog:update(info)
    end
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
        self:cancelMatch();
        self.m_matchIng = false;
    end

	local gametype = UserInfo.getInstance():getGameType();
	if gametype ~= GAME_TYPE_WATCH then
        if self.m_login_succ then
            self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_logout);
            return;
        end
	elseif gametype == GAME_TYPE_WATCH then
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

	local gametype = UserInfo.getInstance():getGameType();
	if gametype ~= GAME_TYPE_WATCH then
        if self.m_login_succ then
            self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_logout);
            return;
        end
    end
--	elseif gametype == GAME_TYPE_WATCH then
--        self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_logout);
--	end
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
        self:clearRoomInfo();
        self:requestCtrlCmd(OnlineRoomController.s_cmds.back_action);
    end
end;

--服务器异常
OnlineRoomSceneNew.onClientUserOtherError = function(self, data)
    ChessToastManager.getInstance():showSingle("登录错误");
    self:exitRoom();
end;

--1.9.5版本之前的抢先逻辑
OnlineRoomSceneNew.forestallEvent = function(self,data)

    self:onDismissDialog();
	if not self.m_forestall_dialog then
		self.m_forestall_dialog = new(ForestallDialog);
		self.m_forestall_dialog:setPositiveListener(self,self.agreeForestall);
		self.m_forestall_dialog:setNegativeListener(self,self.refuseForestall);
	end
	
	if data.curr_uid == self.m_downUser:getUid() then    --由我抢先
		self.m_forestall_dialog:show(data.timeout);
        if data.pre_call_uid == self.m_downUser:getUid() then
            local message = "抢先成功 倍数为 " .. data.multiply;
            self.m_multiple_text:setText("倍数 "..data.multiply);
            self:showLoadingDialog(message,data.timeout);
		    ForestallAnim.play(nil,true,data.multiply);
        elseif data.pre_call_uid == self.m_upUser:getUid() then
            ForestallAnim.play(nil,true,data.multiply);
        elseif data.pre_call_uid == 0 then

        end;
	elseif data.curr_uid == self.m_upUser:getUid() then  --等待对手抢先
        if data.pre_call_uid == self.m_downUser:getUid() then
            local message = "抢先成功 倍数为 " .. data.multiply;
            self.m_multiple_text:setText("倍数 "..data.multiply);
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
        self.m_multiple_text:setText("倍数 "..data.multiply);
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
    self:onDismissDialog();
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
            self.m_multiple_text:setText("倍数 "..data.curr_beishu);
            self:showLoadingDialog(message,data.timeout);
		    ForestallAnim.play(self.m_root_view,true,data.curr_beishu);
        elseif data.pre_call_uid == self.m_upUser:getUid() then
            ForestallAnim.play(self.m_root_view,true,data.curr_beishu);
        elseif data.pre_call_uid == 0 then

        end;
	elseif data.curr_uid == self.m_upUser:getUid() then  --等待对手抢先
        if data.pre_call_uid == self.m_downUser:getUid() then
            local message = "抢先成功 倍数为 " .. data.curr_beishu;
            self.m_multiple_text:setText("倍数 "..data.curr_beishu);
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
        self.m_multiple_text:setText("倍数 "..data.curr_beishu);
    end
end

OnlineRoomSceneNew.btn1Forestall = function(self,opt_beishu)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.server_msg_forestall_new ,opt_beishu);
end

OnlineRoomSceneNew.btn2Forestall = function(self,opt_beishu)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.server_msg_forestall_new ,opt_beishu);
end

OnlineRoomSceneNew.noForestall = function(self)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.server_msg_forestall_new ,0);
end

OnlineRoomSceneNew.showLoadingDialog = function(self,message,time)
	if not self.m_loading_dialog then
		self.m_loading_dialog = new(LoadingDialog);
	end
	self.m_loading_dialog:setMessage(message);
	self.m_loading_dialog:show(time);
end

--断线重连
OnlineRoomSceneNew.onClientMsgRelogin = function(self, data)
    self:relogin(data.errorCode);
end;


OnlineRoomSceneNew.relogin = function(self,errorCode)
    require("chess/include/bottomMenu");
    local bottom = BottomMenu.getInstance();
    bottom:setVisible(false);
	print_string("Room.relogin");
	if(errorCode == 0) then

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

OnlineRoomSceneNew.onServerMsgHandicap = function(self, data)
    self:handicapEvent(data)
end;

OnlineRoomSceneNew.onServerMsgHandicapResult = function(self, data)
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

OnlineRoomSceneNew.userLeave = function(self,leaveUid,ret)
	self:stopTimeout();

	self:game_close_dismiss_dialogs();

	if self.m_downUser and self.m_downUser:getUid() == leaveUid then
		UserInfo.getInstance():setTid(0);
		self.m_down_user_ready_img:setVisible(self.m_downUser:getReadyVisible());
	    self.m_down_user_start_btn:setVisible(self.m_downUser:getStartVisible());

		self.m_up_user_ready_img:setVisible(false);
		self.m_up_user_icon:setVisible(false);  ---表现形式将对走离开

        self.m_downUser = nil;

	elseif self.m_upUser and self.m_upUser:getUid() == leaveUid then
        local gametype = UserInfo.getInstance():getGameType(); --用户的游戏模式
        if gametype == GAME_TYPE_CUSTOMROOM then -- 私人房重置房主
            UserInfo.getInstance():setSelfRoom(true);
            if self.m_private_change_player_btn then
                self.m_private_change_player_btn:setVisible(UserInfo.getInstance():isSelfRoom());
                self.m_private_change_player_btn:setPickable(false);
                self.m_private_change_player_btn:setGray(true);
--                self.m_private_change_player_btn:setFile({"common/button/invite_friend_btn_pre.png","common/button/invite_friend_btn_nor.png"});
            end
        end
        --上家离开，分为2种情况：
        --1，结算框离开，则自己还没有准备，self.m_ready_status==false,点击再来一局，弹选难度对话框。
        --2，点再来一局准备后，上家离开，此时self.m_ready_status == true,需强制自己退出server房间
        --（还在房间内，只是没有登陆server房间），弹选难度对话框。
        self.m_upuser_leave = true;
        --只要一个玩家离开，都要退出server房间
        if gametype ~= GAME_TYPE_CUSTOMROOM and gametype ~= GAME_TYPE_FRIEND then 
            self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_offline);
            if ret and self.m_login_succ then
                self.m_login_succ = false
                self:showRematchComfirmDialog();
--            else
--                self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_offline);
            end
--            if gametype == GAME_TYPE_UNKNOW and self.m_match_dialog then
--                if self.m_account_dialog and self.m_account_dialog:isShowing() then

--                else
--                    self:showRematchComfirmDialog();
--                end
--            end
        elseif gametype == GAME_TYPE_FRIEND then
            self:onForceLeave();
        end;
		self.m_up_user_icon:setFile(User.MAN_ICON);
		HeadSmogAnim.play(self.m_up_user_icon);
        self.m_up_name:setText("");
        self.m_up_turn:setVisible(false);
		self.m_up_user_icon:setVisible(false);
		self.m_up_user_ready_img:setVisible(false);
        self.m_up_vip_frame:setVisible(false);
        self.m_up_vip_logo:setVisible(false);
        self.m_board:dismissChess();
        if self.m_roomSetTimeDialog then
            self.m_roomSetTimeDialog:dismiss();
        end
        if self.m_roomOtherSetTimeDialog then
            self.m_roomOtherSetTimeDialog:dismiss();
        end

        self.m_upUser = nil;
	end
end

--Server通知对话
OnlineRoomSceneNew.onClientMsgChat = function(self, data)
    if not data then
        return;
    end;
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

    self:requestCtrlCmd(OnlineRoomController.s_cmds.client_get_openbox_time);
	ToolKit.addOnlineGameLogCount(self.m_root_view);
end;

--Server通知游戏结束
OnlineRoomSceneNew.onServerMsgGameclose = function(self, data)
    if not data then
        return;
    end;

	self:setStatus(data.table_status);
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
    self:requestCtrlCmd(OnlineRoomController.s_cmds.get_task_progress);
	
	OnlineConfig.deleteTimer(self); 
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
	if UserInfo.getInstance():getGameType() == GAME_TYPE_COMPUTER then  --单机
		self.m_board:drawResponse(true);
	else
        self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_draw2, 1);

	end
end

OnlineRoomSceneNew.refuseDraw = function(self)
	if UserInfo.getInstance():getGameType() == GAME_TYPE_COMPUTER then  --单机
		self.m_board:drawResponse(false);
	else
        self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_draw2, 2);
	end
end

OnlineRoomSceneNew.onServerMsgDraw = function(self, data)
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
	if UserInfo.getInstance():getGameType() ~= GAME_TYPE_CUSTOMROOM then
        self:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_watchlist);        
	end
end

OnlineRoomSceneNew.handicapEvent = function(self,data)
	print_string("Room.handicapEvent");
	self:onDismissDialog();
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

OnlineRoomSceneNew.clearDialog = function(self)

	if self.m_match_dialog and self.m_match_dialog:isShowing() then
		print_string("match room cant't cancel");
		self.m_match_dialog:dismiss();
	end

	if self.m_account_dialog and self.m_account_dialog:isShowing() then
		print_string("self.m_account_dialog is showing ");
		self.m_account_dialog:dismiss2();
	end

	if self.m_chioce_dialog and self.m_chioce_dialog:isShowing() then
		print_string("self.m_chioce_dialog is showing ");
		self.m_chioce_dialog:dismiss();
	end


	if self.m_chat_dialog and self.m_chat_dialog:isShowing() then
		print_string("self.m_chat_dialog is showing ");
		self.m_chat_dialog:dismiss();
	end

    if self.m_watch_dialog and self.m_watch_dialog:isShowing() then
		print_string("self.m_watch_dialog is showing ");
		self.m_watch_dialog:dismiss();
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

OnlineRoomSceneNew.onUpdataUserIcon = function(self,imageName,uid)
    if not imageName or not uid then return end;
    if self.m_upUser and self.m_upUser.m_uid == uid then
        self.m_up_user_icon:setFile(imageName..".png");
    end

    if self.m_downUser and self.m_downUser.m_uid == uid then
        self.m_down_user_icon:setFile(imageName..".png");
    end
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

--更新观战dialog列表
OnlineRoomSceneNew.onUpdateDialogView = function(self, data)
    if UserInfo.getInstance():getGameType() == GAME_TYPE_WATCH then
        if WatchRoomModule.IS_NEW then
            if self.m_watch_dialog then
                self.m_watch_dialog:setListView(data);
            end;
        else
            self.m_watchList_dialog:setListView(data);
        end;
    else
        self.m_watchList_dialog:setListView(data);
    end;
end

--更新观战弹窗和匹配动画里的弹窗
OnlineRoomSceneNew.updateWatchDialog = function(self,info)
    if self.m_watchList_dialog and self.m_watchList_dialog:isShowing() then
        self.m_watchList_dialog:updataBtnText(info);
    end
    if self.m_match_dialog and self.m_match_dialog:isShowing() then
        self.m_match_dialog:update(info);
    end
end
--更新观战数量
OnlineRoomSceneNew.watchRoomNumber = function(self,info)
    if self.m_watchList_dialog then
        self.m_watchList_dialog:updataWatchNum(info);
    end

    if self.m_watch_dialog and self.m_watch_dialog:isShowing() then
        self.m_watch_dialog:updataWatchNum(info);
    end;

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

function OnlineRoomSceneNew:getLoginStatus()
    return self.m_login_succ;
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
    [OnlineRoomSceneNew.s_cmds.server_msg_handicap]    = OnlineRoomSceneNew.onServerMsgHandicap;
    [OnlineRoomSceneNew.s_cmds.server_msg_handicap_result]  = OnlineRoomSceneNew.onServerMsgHandicapResult;
    [OnlineRoomSceneNew.s_cmds.server_msg_logout_succ] = OnlineRoomSceneNew.onServerMsgLogoutSucc;

    [OnlineRoomSceneNew.s_cmds.setTime] = OnlineRoomSceneNew.onSetTime;
    [OnlineRoomSceneNew.s_cmds.setTimeShow] = OnlineRoomSceneNew.onSetTimeShow;
    [OnlineRoomSceneNew.s_cmds.reSetGame] = OnlineRoomSceneNew.onReSetGame;
    [OnlineRoomSceneNew.s_cmds.invitNotify] = OnlineRoomSceneNew.onInvitNotify;
    [OnlineRoomSceneNew.s_cmds.deleteInvitAnim] = OnlineRoomSceneNew.onDeleteInvitAnim;

    [OnlineRoomSceneNew.s_cmds.client_msg_relogin]     = OnlineRoomSceneNew.onClientMsgRelogin;
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
    [OnlineRoomSceneNew.s_cmds.show_input_pwd_dialog]  = OnlineRoomSceneNew.onShowInputPwdDialog;
    
    [OnlineRoomSceneNew.s_cmds.resume_from_homekey]    = OnlineRoomSceneNew.onResumeFromHomekey;
    [OnlineRoomSceneNew.s_cmds.show_net_state]         = OnlineRoomSceneNew.onShowNetState;
    [OnlineRoomSceneNew.s_cmds.set_time_info]          = OnlineRoomSceneNew.onSetTimeInfo;
    [OnlineRoomSceneNew.s_cmds.handle_conn_fail]       = OnlineRoomSceneNew.onHandleConnSocketFail;
    [OnlineRoomSceneNew.s_cmds.on_room_touch]          = OnlineRoomSceneNew.onRoomTouch;
    [OnlineRoomSceneNew.s_cmds.update_prop_info]       = OnlineRoomSceneNew.onUpdatePropInfo;

    [OnlineRoomSceneNew.s_cmds.updataUserIcon]         = OnlineRoomSceneNew.onUpdataUserIcon;
    [OnlineRoomSceneNew.s_cmds.forceLeave]             = OnlineRoomSceneNew.onForceLeave;           --强制离场
    [OnlineRoomSceneNew.s_cmds.updateUserInfoDialog]   = OnlineRoomSceneNew.onUpdateUserInfoDialog;--关注/取消关注

    [OnlineRoomSceneNew.s_cmds.updateWatchUserList]    = OnlineRoomSceneNew.onUpdateDialogView;
    [OnlineRoomSceneNew.s_cmds.updateWatchDialog]      = OnlineRoomSceneNew.updateWatchDialog;
    [OnlineRoomSceneNew.s_cmds.watchNumber]            = OnlineRoomSceneNew.watchRoomNumber;
    [OnlineRoomSceneNew.s_cmds.callTelphoneResponse]   = OnlineRoomSceneNew.callTelphoneResponse; --已经去掉
    [OnlineRoomSceneNew.s_cmds.callTelphoneBack]       = OnlineRoomSceneNew.callTelphoneBack;  --已经去掉
    [OnlineRoomSceneNew.s_cmds.setDisconnect]          = OnlineRoomSceneNew.setDisconnect;  --已经去掉
    [OnlineRoomSceneNew.s_cmds.save_mychess]           = OnlineRoomSceneNew.onSaveMyChess;  
    
}
