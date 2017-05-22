--region onlineRoomModule.lua
--Date
--此文件由[BabeLua]插件自动生成
--[[
        普通联网游戏模块
     模块结构分：初始化界面和数据(onLineRoomInit)、
--]]

WatchRoomModule = class(Node);
WatchRoomModule.IS_NEW = true; -- 观战新旧版本开关

WatchRoomModule.s_cmds = 
{
    updateWatchRoom         = 301;
    updateWatchRoomUser     = 302; 
    watcherCountChange      = 303;
    watchRoomMove           = 304;
    watchRoomUserLeave      = 305;
    watchRoomReady          = 306;
    watchRoomStart          = 307;
    watchRoomClose          = 308;
    watcherChatMsg          = 309;
    watchRoomPlayerChatMsg  = 310;
    watchRoomDraw           = 311;
    watchRoomSurrender      = 312;
    watchRoomUndo           = 313;
    watchRoomWaring         = 314;
    watchRoomAllready       = 315;
    watchRoomError          = 316;
    watchRoomUserEnter      = 317;
    watchRoomNumber         = 318;
    watchRoomMsg            = 319;
    watchRoomUpdateTable    = 320;
}

-------------------------------private function----------------------------
OnlineRoomSceneNew.onWatchRoomDtor = function(self)
    
end

OnlineRoomSceneNew.onWatchRoomInitView = function(self)
    --value
    self.m_watcher_count = 0;  --观战者人数
    --view
    self.m_room_watcher_btn = self.m_root_view:getChildByName("watch_list_btn");
    self.m_room_watcher_btn:setEnable(false);  --觀戰按鈕
    self.m_room_watcher_btn:setOnClick(self,self.gotoWatchList);
    self.m_room_watcher = self.m_room_watcher_btn:getChildByName("room_watcher_count_text");
    local game_type = UserInfo.getInstance():getGameType();
    if game_type == GAME_TYPE_WATCH then
        if WatchRoomModule.IS_NEW then
            -- 隐藏时间
            self.m_root_view:getChildByName("room_time_bg"):setVisible(false);
            -- 隐藏信号
            self.m_net_state_view:setVisible(false);
            -- 隐藏聊天按钮和功能按钮
            self.m_chat_btn:setVisible(false);
            self.m_menu_btn:setVisible(false);
            -- 隐藏观战人数
            self.m_room_watcher_btn:setVisible(false);
            -- up_user
            self:showWatchUpUser();
            -- down_user
            self:showWatchDownUser();   
            -- 显示对局
            self.m_root_view:getChildByName("vs_img"):setVisible(true);
            -- 棋盘上移留出聊天空间
            self.m_board_view:setPos(0,116);
            -- 显示新版watch_view
            self:showNewWatchView();
            -- 隐藏宝箱
            self.m_chest_btn:setVisible(false);
       end;
    end;
end

OnlineRoomSceneNew.showWatchUpUser = function(self)
    -- 隐藏局时
	self.m_up_timeframe:setVisible(false);
    -- 显示黑方flag
    self.m_up_view:getChildByName("up_user_flag"):setVisible(true);
    -- 头像信息背景
    self.m_up_user_bg = self.m_up_view:getChildByName("up_user_bg");
    self.m_up_user_bg:setVisible(true);
    self.m_up_user_bg:setPos(70,0);
    -- 头像左对齐
    self.m_up_user_icon_bg:setAlign(kAlignTop);
    self.m_up_user_icon_bg:setPos(-195,0);
    self.m_up_user_icon_bg:setSize(74,74);
    -- 头像框
    self.m_up_user_icon_bg:getChildByName("up_turn1"):setSize(85,85);
    -- 红黑方
    self.m_up_user_chess_flag = self.m_up_user_icon_bg:getChildByName("up_user_flag2");
    self.m_up_user_chess_flag:setVisible(true);
    -- 倒计时
    self.m_up_turn:setSize(80,80);
    self.m_up_turn:setAlign(kAlignCenter);
    -- icon_frame_mast
	self.m_up_user_icon_frame_mask:setFile("userinfo/icon_8484_mask.png");
    self.m_up_user_icon_frame_mask:setSize(74,74);
    self.m_up_breath1:setSize(74,74);
    self.m_up_breath2:setSize(74,74);
    -- icon
    self.m_up_user_icon:setFile("userinfo/icon_8484_mask.png");
    self.m_up_user_icon:setSize(74,74);
    -- vip_frame
    self.m_up_vip_frame:setSize(76,76);
    -- vip_logo
    self.m_up_vip_logo:setAlign(kAlignTopLeft);
    self.m_up_vip_logo:setPos(230,35);
    -- user_level
    self.m_up_user_level_icon:setPos(75,5);
    -- user_name
    delete(self.m_up_name);
    self.m_up_name = nil;
    self.m_up_name = new(Text,"博雅象棋",0,0,kAlignLeft,nil,24,245,235,210);
    self.m_up_name:setAlign(kAlignTopLeft);
    self.m_up_name:setPos(155,5);
    self.m_up_view:addChild(self.m_up_name);

end;


OnlineRoomSceneNew.showWatchDownUser = function(self)
    self.m_down_view:setAlign(kAlignTop);
    self.m_down_view:setPos(0,24);
    -- 隐藏局时
	self.m_down_timeframe:setVisible(false);
    -- 显示红方flag
    self.m_down_view:getChildByName("down_user_flag"):setVisible(true);
    -- 头像信息背景
    self.m_down_user_bg = self.m_down_view:getChildByName("down_user_bg");
    self.m_down_user_bg:setVisible(true);
    self.m_down_user_bg:setAlign(kAlignTopRight);
    -- 头像左对齐
    self.m_down_user_icon_bg:setAlign(kAlignTop);
    self.m_down_user_icon_bg:setPos(270,0);
    self.m_down_user_icon_bg:setSize(74,74);
    -- 头像框
    self.m_down_user_icon_bg:getChildByName("down_turn1"):setSize(85,85);
    -- 红黑方
    self.m_down_user_chess_flag = self.m_down_user_icon_bg:getChildByName("down_user_flag2");
    self.m_down_user_chess_flag:setVisible(true);
    -- 倒计时
    self.m_down_turn:setSize(80,80);
    self.m_down_turn:setAlign(kAlignCenter);
    -- icon_frame_mast
	self.m_down_user_icon_frame_mask:setFile("userinfo/icon_8484_mask.png");
    self.m_down_user_icon_frame_mask:setSize(74,74);
    self.m_down_breath1:setSize(74,74);
    self.m_down_breath2:setSize(74,74);
    -- icon
    self.m_down_user_icon:setFile("userinfo/icon_8484_mask.png");
    self.m_down_user_icon:setSize(74,74);
    -- vip_frame
    self.m_down_vip_frame:setSize(76,76);
    -- vip_logo
    self.m_down_vip_logo:setAlign(kAlignTopRight);
    self.m_down_vip_logo:setPos(157,35);
    -- user_level
    self.m_down_user_level_icon:setPos(-75,5);
    -- user_name
    delete(self.m_down_name);
    self.m_down_name = nil;
    self.m_down_name = new(Text,"博雅象棋",0,0,kAlignRight,nil,24,245,235,210);
    self.m_down_name:setAlign(kAlignTopRight);
    self.m_down_name:setPos(86,5);
    self.m_down_view:addChild(self.m_down_name);

end;

OnlineRoomSceneNew.showNewWatchView = function(self)
    if not self.m_watch_dialog then
        self.m_watch_dialog = new(WatchDialog, self);
    end;
    self.m_watch_dialog:show();
end;

OnlineRoomSceneNew.showFullScreen = function(self)
    if self.m_watch_dialog and self.m_watch_dialog:isShowing() then
        self.m_watch_dialog:fullScreen();
    end;
end;



OnlineRoomSceneNew.onWatchRoomResetGame = function(self)
    --value
    self.m_watcher_count = 0;
    --view
--	self.m_room_watcher_bg_btn:setVisible(false);
	self.m_down_name:setVisible(false);
	self.m_up_name:setVisible(false);
end

OnlineRoomSceneNew.onWatchRoomInitGame = function(self)
--	self.m_room_watcher_bg_btn:setVisible(false);
    self.m_room_watcher_btn:setEnable(true);
	self.m_down_name:setVisible(true);
	self.m_up_name:setVisible(true);
	self:start_watch();
end

OnlineRoomSceneNew.onWatchRoomDismissDialog = function(self)
end

OnlineRoomSceneNew.onWatchRoomUserLoginSucc = function(self, data)
    self.m_login_succ = true;
    if data.user then
        self:upComeIn(data.user);
    end;
end;

OnlineRoomSceneNew.start_watch = function(self)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.start_watch);
end;

OnlineRoomSceneNew.onUpdateWatchRoom = function(self, data, message)
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


OnlineRoomSceneNew.onUpdateWatchRoomUser = function(self, data)
    self:setWathcerCount(data);
end;

OnlineRoomSceneNew.setWathcerCount = function(self,count)
--	if self.m_room_watcher_bg_btn:getVisible() then
--        if count and count >= 0 then
--		    self.m_watcher_count = count;
--		    local str = string.format("%d",count);
--		    self.m_room_watcher:setText(str);
--            self.m_room_watcher_bg_btn:setPickable(true);
--	    else
--            self.m_room_watcher_bg_btn:setPickable(false);
--		    self.m_room_watcher:setText("0");
--	    end
--    end;
end

OnlineRoomSceneNew.sendWatchChat = function(self, message)
    self:requestCtrlCmd(OnlineRoomController.s_cmds.send_watch_chat, message);
end

OnlineRoomSceneNew.onWatcherCountChange = function(self,num)
	self.m_watcher_count = self.m_watcher_count + num;
	local str = string.format("%d",self.m_watcher_count);
--	self.m_room_watcher:setText(str.." 人");
end

OnlineRoomSceneNew.onWatchRoomMove = function(self, data)
    if not data then return end;
    if self.m_downUser and data.last_move_uid == self.m_downUser:getUid() then
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
    elseif self.m_upUser and data.last_move_uid == self.m_upUser:getUid() then
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
--	    self.m_room_watcher:setText(str);   
    end;

    local mv = {}
	mv.moveChess = data.chessMan;
	mv.moveFrom = data.position1;
	mv.moveTo = data.position2;
	self:resPonseMove(mv);
end

OnlineRoomSceneNew.onWatchRoomUserLeave = function(self, data)
    if not data then
        return 
    end
    self:watchUserLeave(data.leave_uid);
end

OnlineRoomSceneNew.onWatchRoomReady = function(self, data)
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

OnlineRoomSceneNew.onWatchRoomStart = function(self, data)
    if not data then
        return 
    end;
    self.m_timeout1 = data.round_time;
	self.m_timeout2 = data.step_time;
	self.m_timeout3 = data.sec_time;
	
	self.m_downUser:setTimeout1(data.round_time);
	self.m_downUser:setTimeout2(data.step_time);
	self.m_downUser:setTimeout3(data.sec_time);

	self.m_upUser:setTimeout1(data.round_time);
	self.m_upUser:setTimeout2(data.step_time);
	self.m_upUser:setTimeout3(data.sec_time);

	if self.m_downUser:getUid() == data.red_uid then
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

    local player1 = self.m_downUser;
    local player2 = self.m_upUser;

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

    self.m_move_flag = FLAG_RED;
    self.m_red_turn = true;
    self:setStatus(data.status);
	self:startGame(data.chess_map);
--    self:resetPlayerFlag();
end;

OnlineRoomSceneNew.onWatchRoomClose = function(self, data)
	self:setWatchUsersInfo(data);
    self:setStatus(data.status);
	self:gameClose(data.win_flag,data.end_type);    
end

OnlineRoomSceneNew.setWatchUsersInfo = function(self, data)
    if not self.m_upUser or not self.m_downUser then return end;
    if  self.m_downUser:getFlag() == 1 then
		self.m_downUser:setScore(data.red_total_score or 0);
        self.m_downUser:setPoint(data.red_turn_score);
        self.m_downUser:setCoin(data.red_turn_money);
		self.m_downUser:setMoney(data.red_total_money or 0);

		self.m_upUser:setScore(data.black_total_score or 0);
		self.m_upUser:setPoint(data.black_turn_score);
		self.m_upUser:setCoin(data.black_turn_money);
		self.m_upUser:setMoney(data.black_total_money or 0);
	else
		self.m_upUser:setScore(data.red_total_score or 0);
        self.m_upUser:setPoint(data.red_turn_score);
        self.m_upUser:setCoin(data.red_turn_money);
		self.m_upUser:setMoney(data.red_total_money or 0);

		self.m_downUser:setScore(data.black_total_score or 0);
		self.m_downUser:setPoint(data.black_turn_score);
		self.m_downUser:setCoin(data.black_turn_money);
		self.m_downUser:setMoney(data.black_total_money or 0);
	end
end;

OnlineRoomSceneNew.onWatchRoomAllReady = function(self, data)
    if not data then
        return;
    end;
    if data.tid then
--        ShowMessageAnim.play(self.m_root_view,"双方已准备(等待开局)");
        local message =  "双方已准备(等待开局)"; 
        ChessToastManager.getInstance():showSingle(message); 
    end;
end;

OnlineRoomSceneNew.onWatchRoomError = function(self)
--    ShowMessageAnim.play(self.m_root_view,"亲，服务器貌似出问题了");
    local message =  "观战房间出现问题,请重新进入"; 
    ChessToastManager.getInstance():showSingle(message); 
    self:exitRoom();
end

OnlineRoomSceneNew.onWatchRoomUpdateTable = function(self,data)
	if data and data.status then
        self:setStatus(data.status,data.curr_op_uid);
    end
end

OnlineRoomSceneNew.onWatcherChatMsg = function(self, data)
    if data.uid ~= UserInfo.getInstance():getUid() then
        self:showWatchChat(data.name,data.msgType,data.message,data.uid);
    end
end

OnlineRoomSceneNew.showWatchChat = function(self,name,msgType,message,uid)
	if not message or message == "" then
		return;
	end
	local msg = string.format("%s:%s",name,message);
    if WatchRoomModule.IS_NEW and self.m_watch_dialog then -- 是自己发的观战消息显示在
        self.m_watch_dialog:addChatLog(name,message,uid);
    else
	    self.m_chat_dialog:addChatLog(name,message,uid);
        if self.m_chat_btn and not self.m_chat_dialog:isShowing() then 
           if self.m_chat_btn:getChildByName("notice") then
            self.m_chat_btn:getChildByName("notice"):setVisible(true);
           end 
        end
    end;

end

OnlineRoomSceneNew.onWatchRoomPlayerChatMsg = function(self, data)
	if self.m_upUser and data.uid == self.m_upUser:getUid() then
		self:showUpChat(data.msgType,data.message);
	elseif self.m_downUser and data.uid == self.m_downUser:getUid() then
		self:showDownChat(data.msgType,data.message);
	end
end

OnlineRoomSceneNew.onWatchRoomDraw = function(self, data)
	if  self.m_downUser and self.m_downUser:getUid() == data.uid then
        ChatMessageAnim.play(self.m_root_view,3,self.m_downUser:getName().." 和棋申请成功");
	elseif self.m_upUser and self.m_upUser:getUid() == data.uid then
        ChatMessageAnim.play(self.m_root_view,3,self.m_upUser:getName().." 和棋申请成功");
	end
end


OnlineRoomSceneNew.onWatchRoomSurrender = function(self, data)
	if  self.m_downUser and self.m_downUser:getUid() == data.uid then
        ChatMessageAnim.play(self.m_root_view,3,self.m_downUser:getName().." 认输");
	elseif self.m_upUser and self.m_upUser:getUid() == data.uid then
        ChatMessageAnim.play(self.m_root_view,3,self.m_upUser:getName().." 认输");
	end

end;

OnlineRoomSceneNew.onWatchRoomUndo = function(self, data)
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
end

OnlineRoomSceneNew.showWatchClose = function(self)
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

OnlineRoomSceneNew.onWatchRoomWaring = function(self,data)
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

OnlineRoomSceneNew.watchUserLeave = function(self,leaveUid)
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

OnlineRoomSceneNew.onWatchBack = function(self)
	print_string("Room.onWatchBack");
	self:exitRoom();
end

OnlineRoomSceneNew.onWatchRoomUserEnter = function(self,packetInfo)
    if self.m_downUser then
        self:upComeIn(packetInfo.player);
    else
        self:downComeIn(packetInfo.player);
    end
end

OnlineRoomSceneNew.onWatchRoomNumber = function(self,packetInfo)
    self:setWathcerCount(packetInfo.ob_num);
end

OnlineRoomSceneNew.onWatchRoomMsg = function(self,packetInfo)
    if not packetInfo or not packetInfo.chat_msg or packetInfo.chat_msg == ""  or not packetInfo.name or packetInfo.name == "" then
		return;
	end
    if packetInfo and packetInfo.uid == UserInfo.getInstance():getUid() then
        if packetInfo.forbid_time == -1 then 
            ChessToastManager.getInstance():showSingle("亲，消息不能为空或频繁发送哦",1500);
            return;
        end;
    end;

	local msg = string.format("%s:%s",packetInfo.name,packetInfo.chat_msg);
    if WatchRoomModule.IS_NEW and self.m_watch_dialog then
        self.m_watch_dialog:addChatLog(packetInfo.name,packetInfo.chat_msg,packetInfo.uid);
    else
	    self.m_chat_dialog:addChatLog(packetInfo.name,packetInfo.chat_msg,packetInfo.uid);
        if self.m_chat_btn and not self.m_chat_dialog:isShowing() then 
           if self.m_chat_btn:getChildByName("notice") then
            self.m_chat_btn:getChildByName("notice"):setVisible(true);
           end 
        end
    end;
end


------------------------------------config--------------------------
--不同房间类型不同的处理函数
WatchRoomModule.s_privateFunc = {
    initGame = OnlineRoomSceneNew.onWatchRoomInitGame;
    back_action      = OnlineRoomSceneNew.onWatchBack;
}

WatchRoomModule.s_cmdConfig =
{
    [WatchRoomModule.s_cmds.updateWatchRoom]        = OnlineRoomSceneNew.onUpdateWatchRoom;
    [WatchRoomModule.s_cmds.updateWatchRoomUser]    = OnlineRoomSceneNew.onUpdateWatchRoomUser;
    [WatchRoomModule.s_cmds.watchRoomUserEnter]     = OnlineRoomSceneNew.onWatchRoomUserEnter;
    [WatchRoomModule.s_cmds.watchRoomNumber]        = OnlineRoomSceneNew.onWatchRoomNumber;
    [WatchRoomModule.s_cmds.watchRoomMsg]           = OnlineRoomSceneNew.onWatchRoomMsg;

    [WatchRoomModule.s_cmds.watcherCountChange]     = OnlineRoomSceneNew.onWatcherCountChange;
    [WatchRoomModule.s_cmds.watchRoomMove]          = OnlineRoomSceneNew.onWatchRoomMove;
    [WatchRoomModule.s_cmds.watchRoomUserLeave]     = OnlineRoomSceneNew.onWatchRoomUserLeave;
    [WatchRoomModule.s_cmds.watchRoomReady]         = OnlineRoomSceneNew.onWatchRoomReady;
    [WatchRoomModule.s_cmds.watchRoomStart]         = OnlineRoomSceneNew.onWatchRoomStart;
    [WatchRoomModule.s_cmds.watchRoomClose]         = OnlineRoomSceneNew.onWatchRoomClose;
    [WatchRoomModule.s_cmds.watchRoomAllready]      = OnlineRoomSceneNew.onWatchRoomAllReady;
    [WatchRoomModule.s_cmds.watchRoomError]         = OnlineRoomSceneNew.onWatchRoomError;


    [WatchRoomModule.s_cmds.watcherChatMsg]         = OnlineRoomSceneNew.onWatcherChatMsg;
    [WatchRoomModule.s_cmds.watchRoomPlayerChatMsg] = OnlineRoomSceneNew.onWatchRoomPlayerChatMsg;
    [WatchRoomModule.s_cmds.watchRoomDraw]          = OnlineRoomSceneNew.onWatchRoomDraw;
    [WatchRoomModule.s_cmds.watchRoomSurrender]     = OnlineRoomSceneNew.onWatchRoomSurrender;
    [WatchRoomModule.s_cmds.watchRoomUndo]          = OnlineRoomSceneNew.onWatchRoomUndo;
    [WatchRoomModule.s_cmds.watchRoomWaring]        = OnlineRoomSceneNew.onWatchRoomWaring;
    [WatchRoomModule.s_cmds.watchRoomUpdateTable]   = OnlineRoomSceneNew.onWatchRoomUpdateTable;
}

OnlineRoomSceneNew.s_cmdConfig =CombineTables(OnlineRoomSceneNew.s_cmdConfig,
	WatchRoomModule.s_cmdConfig or {});

OnlineRoomSceneNew.s_cmds =CombineTables(OnlineRoomSceneNew.s_cmds,
	WatchRoomModule.s_cmds or {});
--endregion





