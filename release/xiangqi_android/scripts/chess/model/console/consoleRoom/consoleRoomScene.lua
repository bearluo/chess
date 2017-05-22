require(MODEL_PATH.."room/roomScene");
require("config/anim_config");
require("dialog/console_win_dialog")
require("dialog/console_lose_dialog");
require("dialog/setting_dialog");
require("dialog/user_info_dialog");
require(DATA_PATH.."userSetInfo");
ConsoleRoomScene = class(RoomScene);

ConsoleRoomScene.s_controls = 
{
    title_view              = 1;
    board_view              = 2;
    console_room_menu_view  = 3;
    share_btn               = 4;
    console_title_leave_btn = 5;
    switch_menu_btn         = 6;
    console_undo_btn        = 7;
    console_retry_btn       = 8;
    console_setting_btn     = 9;
--    console_user_level      = 10;
    console_undo_num        = 11;
--    console_user_icon_frame = 12;
    up_user_info_view       = 13;
    down_user_info_view     = 14;
    console_user_name       = 15;
}

ConsoleRoomScene.s_cmds = 
{
    start_game              = 1;
    game_close              = 2;
    show_daily_task_dialog  = 3;
    exit_room               = 4;
    update_undo_num         = 5;
    retry_game              = 6;
    undo_btn_enable         = 7;
    update_account_rank     = 8;
    show_reward             = 9;
}           

ConsoleRoomScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = ConsoleRoomScene.s_controls;
    self:initConsoleRoom()
    call_native("BanDeviceSleep");
end 
ConsoleRoomScene.resume = function(self)
    RoomScene.resume(self);
    self:startGame();
end;


ConsoleRoomScene.pause = function(self)
	RoomScene.pause(self);
	AnimKill.deleteAll();
    AnimTimeout.deleteAll();
    AnimJam.deleteAll();
end 


ConsoleRoomScene.dtor = function(self)
    call_native("OpenDeviceSleep");
--    delete(self.animTipsTimer);
    delete(self.m_chioce_dialog);
    delete(self.m_setting_dialog);
    delete(self.m_delay_anim);
    delete(self.m_console_win_dialog);
    delete(self.m_console_result_dialog);
    delete(self.m_anim_start);
    delete(self.m_anim_end);
end 

----------------------------function---------------------------
ConsoleRoomScene.setAnimItemEnVisible = function(self,ret)
end

ConsoleRoomScene.resumeAnimStart = function(self,lastStateObj,timer)
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;
    delete(self.m_anim_start);
    self.m_anim_start = new(AnimInt,kAnimNormal,0,1,delay,-1);
    if self.m_anim_start then
        self.m_anim_start:setEvent(self,function()
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end
            delete(self.m_anim_start);
        end);
    end
end

ConsoleRoomScene.pauseAnimStart = function(self,newStateObj,timer)
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;
    delete(self.m_anim_end);
    self.m_anim_end = new(AnimInt,kAnimNormal,0,1,delay,-1)
    if self.m_anim_end then
        self.m_anim_end:setEvent(self,function()
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end
            delete(self.m_anim_end);
        end);
    end
end


ConsoleRoomScene.initConsoleRoom = function(self)
    self:initView();
    self:initBoard();
    self.m_downUser = UserInfo.getInstance();
    self:downComeIn(UserInfo.getInstance());
end;

ConsoleRoomScene.initView = function(self)
    self.m_root_view = self.m_root;
    --title
    self.m_console_title_view         = self:findViewById(self.m_ctrls.title_view);
    self.m_console_title              = self.m_console_title_view:getChildByName("console_title");
    self.m_console_room_title_tip     = self.m_console_title_view:getChildByName("console_room_title_tip"); 
--    self:setTipsAnim();
    self.m_console_npc_icon_frame     = self.m_console_title_view:getChildByName("console_npc_icon_bg");
    self.m_console_title_leave_btn    = self:findViewById(self.m_ctrls.console_title_leave_btn);
    --board
    self.m_board_view = self:findViewById(self.m_ctrls.board_view);
    self.m_boardBg = self.m_board_view:getChildByName("console_board_bg");
    -- 棋盘适配
    local w,h = self.m_board_view:getSize();
    self.m_room_menu_view = self:findViewById(self.m_ctrls.console_room_menu_view);--确定底边
    local bx,by = self.m_room_menu_view:getUnalignPos();
    local x,y = self.m_board_view:getUnalignPos();
    local pw = self.m_root_view:getSize();
    local ph = by - y;
    if pw > w then
        local diffh = ph - h; -- 增加的高
        local diffw = pw - w; -- 增加的宽
        local add = math.min(diffw,diffh);
        local scale = (w+add)/w;
        local w,h = self.m_board_view:getSize();
	    self.m_board_view:setSize(w*scale,h*scale);
        local w,h = self.m_boardBg:getSize();
	    self.m_boardBg:setSize(w*scale,h*scale);
    end
    -- 棋盘适配 end
--    local w,h = self.m_boardBg:getSize();
--    self.m_board = new(Board,w,h,self);
--    self.m_board_view:addChild(self.m_board);

    self.m_up_chess_pc = {};  --被吃棋子
	self.m_up_chess_num = {}; --被吃棋子滴数量
    self.m_up_user_info_dialog_view = self:findViewById(self.m_ctrls.up_user_info_view);
	self.m_up_user_info_dialog = new(UserInfoDialog,self.m_up_user_info_dialog_view,"up_user_info_",true);
    self.m_up_user_info_dialog:setAddFunc(self,self.onAddBtnClick);
	self.m_up_chessframe = self.m_up_user_info_dialog_view:getChildByName("up_user_info_dialog"):getChildByName("up_chessframe_bg");
	for i = 1 ,7 do
		self.m_up_chess_pc[i] = self.m_up_chessframe:getChildByName("up_chess" .. i .. "_pc" );
		self.m_up_chess_num[i] = self.m_up_chess_pc[i]:getChildByName("up_chess" .. i .. "_num");
		self.m_up_chess_pc[i]:setVisible(false);
		self.m_up_chess_num[i]:setVisible(false);
	end
    self.m_down_chess_pc = {};  --被吃棋子
	self.m_down_chess_num = {}; --被吃棋子滴数量
    self.m_down_user_info_dialog_view = self:findViewById(self.m_ctrls.down_user_info_view);
	self.m_down_user_info_dialog = new(UserInfoDialog,self.m_down_user_info_dialog_view,"down_user_info_",true);
    self.m_down_user_info_dialog:setAddFunc(self,self.onAddBtnClick);
	self.m_down_chessframe = self.m_down_user_info_dialog_view:getChildByName("down_user_info_dialog"):getChildByName("down_chessframe_bg");
	for i = 1 ,7 do
		self.m_down_chess_pc[i] = self.m_down_chessframe:getChildByName("down_chess" .. i .. "_pc" );
		self.m_down_chess_num[i] = self.m_down_chess_pc[i]:getChildByName("down_chess" .. i .. "_num");
		self.m_down_chess_pc[i]:setVisible(false);
		self.m_down_chess_num[i]:setVisible(false);
	end

    --roomMenu
    self.m_room_menu_view = self:findViewById(self.m_ctrls.console_room_menu_view);
--    self.m_room_user_level = self:findViewById(self.m_ctrls.console_user_level);
--    self.m_room_user_name = self:findViewById(self.m_ctrls.console_user_name);
    self.m_console_undo_btn = self:findViewById(self.m_ctrls.console_undo_btn);
    self.m_console_undo_num = self:findViewById(self.m_ctrls.console_undo_num);
    self.m_console_share_btn = self:findViewById(self.m_ctrls.share_btn);
    if kPlatform == kPlatformIOS then
        if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then 
            self.m_console_share_btn:setVisible(true);
        else
            self.m_console_share_btn:setVisible(false);
        end;
    else
        self.m_console_share_btn:setVisible(true);
    end;
    local func =  function(view,enable)
        local tip = view:getChildByName("tip_bg");
        if tip then
            if not enable then
                tip:setVisible(true);
                tip:addPropTransparency(1, kAnimNormal, 100, 1000, 0, 1);
            else
                tip:setVisible(false);
                tip:removeProp(1);
            end
        end
    end
    self.m_console_undo_btn:setOnTuchProcess(self.m_console_undo_btn,func);

    self.m_console_undo_num = self:findViewById(self.m_ctrls.console_undo_num);
--    self.m_console_user_icon_frame = self:findViewById(self.m_ctrls.console_user_icon_frame);
--    self.m_vip_logo = self.m_room_menu_view:getChildByName("console_user_info"):getChildByName("vip_logo");
--    self.m_vip_frame = self.m_room_menu_view:getChildByName("console_user_info"):getChildByName("console_user_icon_bg"):getChildByName("vip_frame");
    self.m_boardBg:setFile(UserSetInfo.getInstance():getBoardRes());

--    if UserInfo.getInstance():getIsVip() == 1 then
--        self.m_boardBg:setFile("vip/vip_chess_board.png");
--    end

end;

ConsoleRoomScene.setTipsAnim = function(self)
--  self.animTipsTimer = new(AnimInt,kAnimRepeat,0,1,20000,-1);
--	self.animTipsTimer:setEvent(self,self.onTimer);	
end;
ConsoleRoomScene.onTimer = function(self)
--  self.m_console_room_title_tip:setText(User.AI_TIPS[math.random(10)]);

end;

ConsoleRoomScene.initBoard = function(self)
	local w,h = self.m_board_view:getSize();
	self.m_board = new(Board,w,h,self);
	self.m_board_view:addChild(self.m_board);
end;


ConsoleRoomScene.startGame = function(self,isRetry)
    self:findViewById(self.m_ctrls.console_undo_btn):setPickable(true); 
    self:findViewById(self.m_ctrls.console_undo_btn):setGray(false); 
    if isRetry then
        self:requestCtrlCmd(ConsoleRoomController.s_cmds.upload_console2php, 0);
        self:saveAIResult(true);
    end
    self:requestCtrlCmd(ConsoleRoomController.s_cmds.start_game)
end;


ConsoleRoomScene.downComeIn = function(self, user)
--    self.m_room_user_level:setFile(string.format("common/icon/level_%d.png",10-user:getDanGradingLevel()));
--    self.m_room_user_name:setText(user:getName() or "博雅象棋");
    self.m_console_undo_num:setText(user:getUndoNum());
--    if not self.m_console_user_icon then
--        self.m_console_user_icon = new(Mask,UserInfo.DEFAULT_ICON[1],"userinfo/icon_8484_mask.png");
--        if user:getIconType() == -1 then
--            self.m_console_user_icon:setUrlImage(user:getIcon());
--        else
--            self.m_console_user_icon:setFile(UserInfo.DEFAULT_ICON[user:getIconType()] or UserInfo.DEFAULT_ICON[1]);
--        end
--        self.m_console_user_icon:setSize(84,84);
--        self.m_console_user_icon:setAlign(kAlignCenter);
--        self.m_console_user_icon_frame:addChild(self.m_console_user_icon)
--    else
--        if user:getIconType() == -1 then
--            self.m_console_user_icon:setUrlImage(user:getIcon());
--        else
--            self.m_console_user_icon:setFile(UserInfo.DEFAULT_ICON[user:getIconType()] or UserInfo.DEFAULT_ICON[1]);
--        end
--    end
--    self.m_console_user_icon:setEventTouch(self,self.showDownUserInfo);

--    local vw,vh = self.m_vip_logo:getSize();
--    if user and user.m_is_vip and user.m_is_vip == 1 then
--        self.m_room_user_name:setPos(vw + 23,10);
----        self.m_vip_frame:setVisible(true);
--        self.m_vip_logo:setVisible(true);
--    else
--        self.m_room_user_name:setPos(20,10);
----        self.m_vip_frame:setVisible(false);
--        self.m_vip_logo:setVisible(false);
--    end
--    local frameRes = UserSetInfo.getInstance():getFrameRes();
--    self.m_vip_frame:setVisible(frameRes.visible);
--    local fw,fh = self.m_vip_frame:getSize();
--    if frameRes.frame_res then
--        self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
--    end

end;



ConsoleRoomScene.onConsoleRoomShareBtnClick = function(self)
    self:requestCtrlCmd(ConsoleRoomController.s_cmds.share_action);
end;

ConsoleRoomScene.onConsoleTitleLeaveBtnClick = function(self)
    
    self:onExitRoom();

end;

ConsoleRoomScene.setDieChess = function(self,dieChess)
	if not dieChess then
		sys_set_int("win32_console_color",10);
		print_string("Room.setDieChess but not dieChess" );
		sys_set_int("win32_console_color",9);
		return;
	end

	if not self.m_downUser or not self.m_upUser or not self.m_my_flag or not self.m_ai_flag then

		print_string("Room.setDieChess but not self.m_downUser or not self.m_upUser" );
		return
	end

	local upflag = tonumber(self.m_my_flag) * 8 - 1;
	local downflag = tonumber(self.m_ai_flag) * 8 - 1;
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
			self.m_down_chess_num[i]:getChildByName("text"):setText(dieChess[upflag +i ]);
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

ConsoleRoomScene.resetChessPos = function(self)
	for i = 1,7 do
		UserInfoDialog.down_chess_pos[i].available = true;
        UserInfoDialog.up_chess_pos[i].available = true;
	end
end

ConsoleRoomScene.onConsoleSwitchMenuBtnClick = function(self)
    

end;

ConsoleRoomScene.showUndoNum = function(self)
    
	local num = UserInfo.getInstance():getUndoNum();
	self.m_console_undo_num:setText(num);

end;

ConsoleRoomScene.showUpUserInfo = function(self,finger_action, x, y)
	print_string("showUpUserInfo ");
	if finger_action ~= kFingerUp then
		return
	end
	if self.m_up_user_info_dialog and self.m_up_user_info_dialog:isShowing() then
		self.m_up_user_info_dialog:dismiss();
	else
		self.m_up_user_info_dialog:show(self.m_upUser);
	end
end

ConsoleRoomScene.showDownUserInfo = function(self,finger_action, x, y)
	if finger_action ~= kFingerUp then
		return
	end
    if self.m_down_user_info_dialog:isShowing() then
		self.m_down_user_info_dialog:dismiss();
	else
	    self.m_down_user_info_dialog:show(self.m_downUser);
    end;
end


ConsoleRoomScene.onConsoleUndoBtnClick  = function(self)
    Log.i("ConsoleRoomScene.onConsoleUndoBtnClick");
    self:requestCtrlCmd(ConsoleRoomController.s_cmds.undo_action)

end;


ConsoleRoomScene.restart_action = function(self)
    self:startGame(false);
end;

ConsoleRoomScene.sharePicture = function(self)
    self:requestCtrlCmd(ConsoleRoomController.s_cmds.share_action);
end;

ConsoleRoomScene.onConsoleRetryBtnClick = function(self)

    Log.i("ConsoleRoomScene.onConsoleRetryBtnClick");
    local message = "重来会判当前棋局为负，是否继续？";
    delete(self.m_chioce_dialog);
    self.m_chioce_dialog = new(ChioceDialog);
	self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE);
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:setPositiveListener(self,self.startGame,true);
	self.m_chioce_dialog:setNegativeListener(nil,nil);
	self.m_chioce_dialog:show();
end;

ConsoleRoomScene.onConsoleSettingBtnClick = function(self)
    Log.i("ConsoleRoomScene.onConsoleSettingBtnClick");
	self:requestCtrlCmd(ConsoleRoomController.s_cmds.event_state, ROOM_MODEL_MENU_SET_BTN);

	if not self.m_setting_dialog then
		self.m_setting_dialog = new(SettingDialog);
	end

	self.m_setting_dialog:show();
--    self.m_board:setLevel(7);
--    self.m_board:response(ENGINE_MOVE);
--    local level = UserInfo.getInstance():getPlayingLevel();
--    local AI_LEVEL_MAP = UserInfo.getInstance():getAILevelMap();
--    local AI_LEVEL_MAP = {
--            1,2,1,2,3,
--            4,3,4,5,8,
--    };
--	local ai_level = AI_LEVEL_MAP[level]; 
--    print_string("onConsoleSettingBtnClick is -------------->"..ai_level)
--    self.m_board:setLevel(ai_level);
--    self.m_board:response(ENGINE_MOVE);

end;

----------------------------Controller2Scene_OnFunc------------

ConsoleRoomScene.onStartGame = function(self, level, head_icon)
    self:findViewById(self.m_ctrls.console_undo_btn):setPickable(true); 
    self:findViewById(self.m_ctrls.console_undo_btn):setGray(false); 
    self.m_console_title:setText(User.AI_TITLE[level]);
    self.m_upUser = new(User);
    self.m_upUser:setName(User.AI_NAME[level]);
    self.m_upUser:setAIIcon(string.format("console/console_head_%d.png",head_icon),0);
    self.m_upUser:setTitle(User.CONSOLE_TITLE[level]);
    local currentPlayingLevel = UserInfo.getInstance():getPlayingLevel();
    local jsonString = GameCacheData.getInstance():getString(GameCacheData.CONSOLE_RESULT_RECORD..currentPlayingLevel,"");
    local resultData = {};
    if jsonString and jsonString ~= "" then
        resultData = json.decode(jsonString);
    else
        resultData.wintimes = 0;
        resultData.losetimes = 0;
        resultData.drawtimes = 0;
    end
    self.m_upUser:setLosetimes(resultData.losetimes);
    self.m_upUser:setWintimes(resultData.wintimes);
    self.m_upUser:setDrawtimes(resultData.drawtimes);
    if User.AI_MODEL[level] == Board.MODE_RED then
        self.m_downUser:setFlag(FLAG_RED);
        self.m_upUser:setFlag(FLAG_BLACK);
    elseif User.AI_MODEL[level] == Board.MODE_BLACK then
        self.m_downUser:setFlag(FLAG_BLACK);
        self.m_upUser:setFlag(FLAG_RED);    
    end;
    self.m_console_room_title_tip:setText(User.AI_TIPS[level]);

    if not self.m_console_npc_icon then
        self.m_console_npc_icon = new(Mask,string.format("console/console_head_%d.png",head_icon),"common/background/head_mask_bg_110.png");-- userinfo/icon_mask.png");
        self.m_console_npc_icon:setSize(110,110);
        self.m_console_npc_icon:setAlign(kAlignCenter);
        self.m_console_npc_icon_frame:addChild(self.m_console_npc_icon)
    else
        self.m_console_npc_icon:setFile(string.format("console/console_head_%d.png",head_icon));
    end
    self.m_console_npc_icon:setEventTouch(self,self.showUpUserInfo);
    -- 默认开局悔棋不可用
    self.m_console_undo_btn:setPickable(false); 
    self.m_console_undo_btn:setGray(true);  
    self.m_console_title_leave_btn:setTransparency(0.6);
end;
ConsoleRoomScene.setBoradCode = function(self, flag, endType)
    self.m_close_flag = flag;
    self.m_game_end_type = endType;
end;


ConsoleRoomScene.onGameClose = function(self, flag, endType)

    

--	if endType == ENDTYPE_KILL then
--		AnimKill.play(self,self,self.showResultDialog);
--	elseif endType == ENDTYPE_TIMEOUT then
--		AnimTimeout.play(self,self,self.showResultDialog);
--	elseif endType == ENDTYPE_JAM then
--		AnimJam.play(self,self,self.showResultDialog);
--	elseif endType == ENDTYPE_SURRENDER then
--		local message = "认输!!!";
--		ChatMessageAnim.play(self,3,message);
--		self:showResultDialog();
--	elseif endType == ENDTYPE_UNLEGAL then
--		local message = "长打作负!!!";
--		ChatMessageAnim.play(self,3,message);
--		self:showResultDialog();
--	elseif endType == ENDTYPE_UNCHANGE then
--		local message = "双方不变作和!!!";
--		ChatMessageAnim.play(self,3,message);
--		self:showResultDialog();
--	else
--		self:showResultDialog();
--	end


end;

ConsoleRoomScene.clearDiechess = function(self,dieChess)

end;

ConsoleRoomScene.exitRoom = function(self)
    self:onExitRoom();
end;

ConsoleRoomScene.onExitRoom = function(self)

    if self:dismissDialog() then
        return ;
    end


	ToolKit.removeAllTipsDialog(); 
	self:removeTimer();
    self:requestCtrlCmd(ConsoleRoomController.s_cmds.event_state, NEW_CONSOLEROOM_MODEL_EXIT_BTN);
	self:requestCtrlCmd(ConsoleRoomController.s_cmds.leave_action);


end;
ConsoleRoomScene.chessMove = function(self,data)
    self:findViewById(self.m_ctrls.console_undo_btn):setPickable(false); 
    self:findViewById(self.m_ctrls.console_undo_btn):setGray(true); 
    self:requestCtrlCmd(ConsoleRoomController.s_cmds.chess_move,data);

end;

ConsoleRoomScene.onUpdateUndoNum = function(self, num)

    self.m_console_undo_num:setText(num);   

end;

ConsoleRoomScene.onRetryGame = function(self)
    self:startGame();

end;


ConsoleRoomScene.onUndoBtnEnable = function(self)
    self.m_console_undo_btn:setPickable(true);  
    self.m_console_undo_btn:setGray(false);  

end;

-- 更新结算框“您已领先xxx人”
ConsoleRoomScene.onUpdateAccountRank = function(self, proportion,leading_number,progress)
    if self.m_account_dialog and self.m_account_dialog:getVisible() then
        self.m_account_dialog:setAccountRank(proportion,leading_number);
        self.m_account_dialog:unlockConsoleHead(progress or 3);
    end;
end;

-- 回结算框显示奖励
ConsoleRoomScene.onShowReward = function(self, result)
    if not result then
        if self.m_account_dialog and self.m_account_dialog:getVisible() then
            self.m_account_dialog:resetChessRandom();
        end;       
        return;
    end;
    if self.m_account_dialog and self.m_account_dialog:getVisible() then
        self.m_account_dialog:showReward(result);
    end;
end;





ConsoleRoomScene.removeTimer = function(self)
	if self.animTimer then
		delete(self.animTimer);
		self.animTimer = nil;
	end
end


ConsoleRoomScene.dismissDialog = function (self)

	if self.m_chioce_dialog and self.m_chioce_dialog:isShowing() then
		self.m_chioce_dialog:dismiss();
        return true;
	end

	if self.m_ending_result_dialog and self.m_ending_result_dialog:isShowing() then
		self.m_ending_result_dialog:dismiss();
        return true;
	end

	if self.m_setting_dialog and self.m_setting_dialog:isShowing() then
		self.m_setting_dialog:dismiss();
        return true;
	end

	if self.m_share_chioce_dialog and self.m_share_chioce_dialog:isShowing() then
		self.m_share_chioce_dialog:dismiss();
        return true;
	end

	-- if self.m_buy_prop_dialog and  self.m_buy_prop_dialog:isShowing() then
	-- 	self.m_buy_prop_dialog:cancel();
	-- 	return;
	-- end
    return false;
end


ConsoleRoomScene.showResultDialog = function(self)
    --下完棋局，不论输赢，设置是否存在中途棋局为false
    GameCacheData.getInstance():saveBoolean(GameCacheData.CONSOLE_IS_EXISTED_CHESS, false);
    --下完棋局，不论输赢，设置是否来自中途棋局为false
    UserInfo.getInstance():setJoinPlayedConsole(false);
    self:findViewById(self.m_ctrls.console_undo_btn):setPickable(false); 
    self:findViewById(self.m_ctrls.console_undo_btn):setGray(true); 
	self:deleDelayAnim();
	self.m_delay_anim = new(AnimInt,kAnimNormal,0,1,1*1000,-1); --
	self.m_delay_anim:setDebugName("ConsoleRoomScene.showResultDialog m_delay_anim");
	self.m_delay_anim:setEvent(self,self.showResultDialogDelay);
    Log.i("ConsoleRoomScene.showResultDialog");

end
ConsoleRoomScene.showResultDialogDelay = function(self)
	print_string("ConsoleRoomScene.showResultDialog");
	self:deleDelayAnim();
	self.m_controller:setGameOver(true);
    Log.i("ConsoleRoomScene.showResultDialogDelay"..self.m_close_flag.."");
    if self.m_close_flag == (self.m_controller.m_model + 1) then
        --umeng统计数据
        self:requestCtrlCmd(ConsoleRoomController.s_cmds.event_state, NEW_CONSOLEROOM_MODEL_WIN_EVT);
        --php统计数据
        self:requestCtrlCmd(ConsoleRoomController.s_cmds.upload_console2php, 1);	
        local currentPlayingLevel = UserInfo.getInstance():getPlayingLevel();
        local openMaxLevel = GameCacheData.getInstance():getInt(GameCacheData.CONSOLE_MAX_OPENLEVEL..UserInfo.getInstance():getUid(), 3);
        -- 闯的是新关
        if currentPlayingLevel == openMaxLevel then
            -- 上传单机进度
            self:requestCtrlCmd(ConsoleRoomController.s_cmds.upload_progress, currentPlayingLevel);
            if openMaxLevel + 1 <= COSOLE_MODEL_GATE_NUM then
                GameCacheData.getInstance():saveInt(GameCacheData.CONSOLE_MAX_OPENLEVEL..UserInfo.getInstance():getUid(), openMaxLevel + 1);
            else
                GameCacheData.getInstance():saveInt(GameCacheData.CONSOLE_MAX_OPENLEVEL..UserInfo.getInstance():getUid(), openMaxLevel);
            end;
        -- 不是新关
        else
            -- 上传单机进度
            self:requestCtrlCmd(ConsoleRoomController.s_cmds.upload_progress, openMaxLevel - 1);
        end;

	    GameCacheData.getInstance():saveInt(GameCacheData.CONSOLE_HASPASS_LEVEL, currentPlayingLevel);
        self:saveAIResult(false);
    else
		self:requestCtrlCmd(ConsoleRoomController.s_cmds.event_state, NEW_CONSOLEROOM_MODEL_LOSE_EVT);
        --php统计数据
        self:requestCtrlCmd(ConsoleRoomController.s_cmds.upload_console2php, 0);
		if UserInfo.getInstance():getConnectHall() then
			self:requestCtrlCmd(ConsoleRoomController.s_cmds.get_soul, 5);
		end
        self:saveAIResult(true);
	end
    self:showAccountDialog();
end


ConsoleRoomScene.saveConsoleZhanji = function(self, isWin)
--    local currentPlayingLevel = UserInfo.getInstance():getPlayingLevel();
--    local openMaxLevel = GameCacheData.getInstance():getInt(GameCacheData.CONSOLE_MAX_OPENLEVEL..UserInfo.getInstance():getUid(), 3);
--    local consoleZhanji = GameCacheData.getInstance():getString(GameCacheData.CONSOLE_ZHANJI..UserInfo.getInstance():getUid(), {});
--    if consoleZhanji[currentPlayingLevel] then
--        if isWin then

--        else

--        end;      
--    end; 
end;


ConsoleRoomScene.showAccountDialog = function(self)
    require("dialog/account_dialog");
    if not self.m_account_dialog then
        self.m_account_dialog = new(AccountDialog, self);
    end;
    local var = {[1] = true, [2] = 1};
    self.m_account_dialog:show(self,self.m_close_flag,var,GAME_TYPE_OFFLINE);
end;



ConsoleRoomScene.saveAIResult = function(self,isWin)
    local currentPlayingLevel = UserInfo.getInstance():getPlayingLevel();
    local jsonString = GameCacheData.getInstance():getString(GameCacheData.CONSOLE_RESULT_RECORD..currentPlayingLevel,"");
    local resultData = {};
    if jsonString and jsonString ~= "" then
        resultData = json.decode(jsonString);
        if isWin then
            resultData.wintimes = resultData.wintimes + 1;
        else
            resultData.losetimes = resultData.losetimes + 1;
        end
    else
        if isWin then
            resultData.wintimes = 1;
            resultData.losetimes = 0;
        else
            resultData.wintimes = 0;
            resultData.losetimes = 1;
        end
        resultData.drawtimes = 0;
    end
    local json_order = json.encode(resultData);
    GameCacheData.getInstance():saveString(GameCacheData.CONSOLE_RESULT_RECORD..currentPlayingLevel, json_order);
end

ConsoleRoomScene.deleDelayAnim = function(self)
	if self.m_delay_anim then
		delete(self.m_delay_anim);
		self.m_delay_anim = nil;
	end
end



ConsoleRoomScene.saveChess = function(self)
    return self:saveChessData();
--	if self:saveChessData() == true then
--		local message = "棋局已自动保存到最近对战";
--		ShowMessageAnim.play(self.m_account_dialog,message);
--	else
--		local message = "本地棋库已达到"..UserInfo.getInstance():getSaveChessLimit().."条上限，您可以覆盖原棋谱保存新的棋谱，请问是否要继续保存新棋谱？";
--		self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE);
--		self.m_chioce_dialog:setMessage(message);
--		self.m_chioce_dialog:setNegativeListener(self,self.cancelSaveMVList);
--		self.m_chioce_dialog:setPositiveListener(self,self.toDapuPage);
--		self.m_chioce_dialog:show();
--	end
end;


ConsoleRoomScene.saveChessData = function(self)
    local uid = UserInfo.getInstance():getUid();
	local keys = GameCacheData.getInstance():getString(GameCacheData.RECENT_DAPU_KEY .. uid,"");
	local keys_table = lua_string_split(keys, GameCacheData.chess_data_key_split);
	local key;
    local time = os.time();
    key = "myRecentChessDataId_"..time;
    if #keys_table < UserInfo.getInstance():getSaveChessManualLimit() then
        table.insert(keys_table,1, key);
    elseif #keys_table == UserInfo.getInstance():getSaveChessManualLimit() then
        table.remove(keys_table,#keys_table);
        table.insert(keys_table,1, key);
    else
        while #keys_table > UserInfo.getInstance():getSaveChessManualLimit() do
            table.remove(keys_table,#keys_table);    
        end;
    end
    local mvData = {};
    mvData.id = time;
    mvData.mid = uid;
    mvData.mnick = UserInfo.getInstance():getName();
    mvData.icon_type = UserInfo.getInstance():getIconType();
    mvData.icon_url = UserInfo.getInstance():getIcon();
    mvData.fileName = "单机回放";
    -- 以前单机或残局mid=0;现mid=-1,为了解决断网玩单机和残局,在复盘最近对局内玩家本身mid=0和AI的mid相同，名字和棋盘不对的bug.
    -- 当连接网络之后，此时用户已经登录，收藏到我的收藏，php保存mid（-1）保存为0，所以不影响线上。
    mvData.red_mid = ((self.m_controller.m_model == 0) and self.m_downUser:getUid()) or -1;
    mvData.black_mid = ((self.m_controller.m_model == 0) and -1) or self.m_downUser:getUid();
    mvData.down_user = self.m_downUser:getUid();
    mvData.red_mnick = ((self.m_controller.m_model == 0) and self.m_downUser:getName()) or User.AI_TITLE[UserInfo.getInstance():getPlayingLevel()];
    mvData.black_mnick = ((self.m_controller.m_model == 0) and User.AI_TITLE[UserInfo.getInstance():getPlayingLevel()]) or self.m_downUser:getName();
    mvData.red_icon_url = (self.m_controller.m_model == 0 and  self.m_downUser:getIcon()) or (nil);
    mvData.black_icon_url = (self.m_controller.m_model == 0 and  nil) or (self.m_downUser:getIcon());
    mvData.red_icon_type = (self.m_controller.m_model == 0 and  self.m_downUser:getIconType()) or (1);
    mvData.black_icon_type = (self.m_controller.m_model == 0 and  1) or (self.m_downUser:getIconType());
    mvData.red_level = (self.m_controller.m_model == 0 and  self.m_downUser:getDanGradingLevel()) or 0;
    mvData.black_level = (self.m_controller.m_model == 0 and  0) or (self.m_downUser:getDanGradingLevel());
    
    mvData.red_score = (self.m_controller.m_model == 0 and  self.m_downUser:getScore()) or 0;
    mvData.black_score = (self.m_controller.m_model == 0 and  0) or (self.m_downUser:getScore());
    
    mvData.win_flag = self.m_close_flag;
    mvData.end_type = self.m_game_end_type;
    mvData.flag = self.m_controller.m_model + 1;
    
    mvData.manual_type = "3";
    --mvData.start_fen = GameCacheData.getInstance():getString(GameCacheData.DAPU_LAST_BORAD_FEN,GameCacheData.NULL);
    mvData.start_fen = Postion.STARTUP_FEN[1];
    mvData.chessString = GameCacheData.getInstance():getString(GameCacheData.DAPU_LAST_CHESS_STR,GameCacheData.NULL);
    mvData.end_fen = self.m_board.toFen(self.m_board:to_chess_map(),((self.m_close_flag == 1) and false) or true);
    mvData.move_list = table.concat(self.m_controller.m_board:to_mvList(),GameCacheData.chess_data_key_split);
    mvData.createrName = "";
--	mvData.time = os.date("%Y", os.time()).."-"..os.date("%m", os.time()).."-"..os.date("%d", os.time());
    mvData.time = os.date("%Y/%m/%d",time)
    -- 结算收藏需要棋谱参数
    self.m_mvData = mvData;
    local mvData_str = json.encode(mvData);
    print_string("mvData_str = " .. mvData_str);
	GameCacheData.getInstance():saveString(GameCacheData.RECENT_DAPU_KEY .. uid,table.concat(keys_table,GameCacheData.chess_data_key_split));
	GameCacheData.getInstance():saveString(key .. uid,mvData_str);
	
	GameCacheData.getInstance():saveString(GameCacheData.DAPU_LAST_BORAD_FEN,GameCacheData.NULL);
	GameCacheData.getInstance():saveString(GameCacheData.DAPU_LAST_CHESS_STR,GameCacheData.NULL);
	return true;	--保存成功
end


ConsoleRoomScene.onConsolePassNum = function(self, data)
    if not data then return end;
    self.m_pass_num = data;
end;

---------------------------- config -----------------------------

ConsoleRoomScene.s_controlConfig = 
{
    [ConsoleRoomScene.s_controls.title_view]                    = {"console_title_view"};
    [ConsoleRoomScene.s_controls.board_view]                    = {"console_board"};
    [ConsoleRoomScene.s_controls.console_room_menu_view]        = {"console_room_menu"};
    [ConsoleRoomScene.s_controls.share_btn]                     = {"console_share_btn"};
    [ConsoleRoomScene.s_controls.console_title_leave_btn]       = {"console_leave_btn"};
    [ConsoleRoomScene.s_controls.console_undo_btn]              = {"console_room_menu","console_undo_btn"};
    [ConsoleRoomScene.s_controls.console_undo_num]              = {"console_room_menu","console_undo_btn","console_undo_num_bg","console_undo_num_text"};
--    [ConsoleRoomScene.s_controls.console_user_icon_frame]       = {"console_room_menu","console_user_info","console_user_icon_bg","icon_frame"};
    [ConsoleRoomScene.s_controls.console_retry_btn]             = {"console_room_menu","console_retry_btn"};
    [ConsoleRoomScene.s_controls.console_setting_btn]           = {"console_room_menu","console_setting_btn"};
--    [ConsoleRoomScene.s_controls.console_user_level]            = {"console_room_menu","console_user_info","console_user_level"};
--    [ConsoleRoomScene.s_controls.console_user_name]             = {"console_room_menu","console_user_info","console_user_name"};
    [ConsoleRoomScene.s_controls.up_user_info_view]             = {"up_user_info_view"};
    [ConsoleRoomScene.s_controls.down_user_info_view]           = {"down_user_info_view"};

};
--定义控件的触摸响应函数
ConsoleRoomScene.s_controlFuncMap =
{
	[ConsoleRoomScene.s_controls.share_btn]                     = ConsoleRoomScene.onConsoleRoomShareBtnClick;
    [ConsoleRoomScene.s_controls.console_title_leave_btn]       = ConsoleRoomScene.onConsoleTitleLeaveBtnClick;
    [ConsoleRoomScene.s_controls.switch_menu_btn]               = ConsoleRoomScene.onConsoleSwitchMenuBtnClick;
    [ConsoleRoomScene.s_controls.console_undo_btn]              = ConsoleRoomScene.onConsoleUndoBtnClick;
    [ConsoleRoomScene.s_controls.console_retry_btn]             = ConsoleRoomScene.onConsoleRetryBtnClick;
    [ConsoleRoomScene.s_controls.console_setting_btn]           = ConsoleRoomScene.onConsoleSettingBtnClick;

--    [ConsoleRoomScene.s_controls.reset_btn]         = ConsoleRoomScene.onConsoleBackActionBtnClick;
--    [ConsoleRoomScene.s_controls.setting_btn]       = ConsoleRoomScene.onConsoleResetBtnClick;
--    [ConsoleRoomScene.s_controls.exit_room_btn]     = ConsoleRoomScene.onConsoleAddCoinBtnClick;


};

ConsoleRoomScene.s_cmdConfig = 
{

    [ConsoleRoomScene.s_cmds.start_game]                        = ConsoleRoomScene.onStartGame;

    [ConsoleRoomScene.s_cmds.game_close]                        = ConsoleRoomScene.onGameClose;

    [ConsoleRoomScene.s_cmds.exit_room]                         = ConsoleRoomScene.onExitRoom;

    [ConsoleRoomScene.s_cmds.update_undo_num]                   = ConsoleRoomScene.onUpdateUndoNum;

    [ConsoleRoomScene.s_cmds.retry_game]                        = ConsoleRoomScene.onRetryGame;
    
    [ConsoleRoomScene.s_cmds.undo_btn_enable]                   = ConsoleRoomScene.onUndoBtnEnable;

    [ConsoleRoomScene.s_cmds.update_account_rank]               = ConsoleRoomScene.onUpdateAccountRank;

    [ConsoleRoomScene.s_cmds.show_reward]                       = ConsoleRoomScene.onShowReward;
}