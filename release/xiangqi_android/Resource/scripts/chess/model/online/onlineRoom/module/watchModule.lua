require(MODEL_PATH .. "online/onlineRoom/module/baseModule");
require(DATA_PATH .. "watchLog")

WatchModule = class(BaseModule);

function WatchModule.ctor(self,scene)
    BaseModule.ctor(self,scene);
    --value
    self.dataCache = {}
    self.cellList = {}
    self.indexList = {}
    self.posTab = {
        [1] = {x = 0,y = 0},
        [2] = {x = 0,y = 110},
        [3] = {x = 0,y = 220}
    }

    for i = 1,3 do 
        self.cellList[i] = {}
        self.cellList[i].state = 0
    end

    scene.m_watcher_count = 0;  --观战者人数
    local roomType = RoomProxy.getInstance():getCurRoomType();
    if roomType == RoomConfig.ROOM_TYPE_WATCH_ROOM then
        if OnlineRoomSceneNew.IS_NEW then
            -- 隐藏时间
            scene.m_root_view:getChildByName("room_time_bg"):setVisible(false);
            -- 隐藏聊天按钮和功能按钮
            scene.m_chat_btn:setVisible(false);
            scene.m_menu_btn:setVisible(false);
            scene.m_thansize_btn:setVisible(false);
            -- 隐藏观战人数
            scene.m_room_watcher_btn:setVisible(true);
            -- up_user
            self:showWatchUpUser();
            -- down_user
            self:showWatchDownUser();   
            -- 显示对局
            scene.m_root_view:getChildByName("changeButton"):setVisible(true);
            scene.m_root_view:getChildByName("changeButton"):setOnClick(scene,function()
                    if scene and scene.switchSide then
                            scene:switchSide();
                        end
                end);
            -- 棋盘上移留出聊天空间
            scene.m_board_view:setPos(0,116);
            -- 显示新版watch_view
            self:showNewWatchView();
            -- 隐藏宝箱
            scene.m_chest_btn:setVisible(false);
       end      
    end

    self.mScene:setIsWatchGiftAnim(true)
    RoomProxy.getInstance():setCurRoomModeIsWatch(true)
    self.m_board_bg_res = nil
--    self:startNodeTimer()
    local level = RoomProxy.getInstance():getRoomLevel()
    local config = RoomConfig.getInstance():getRoomLevelConfig(level)
    if config then
        local roomType = tonumber(config.room_type)
        local name = config.name
        if roomType == RoomConfig.ROOM_TYPE_NOVICE_ROOM then
	        self.mScene.m_multiple_text:setText( name or "初级场");
        elseif roomType == RoomConfig.ROOM_TYPE_INTERMEDIATE_ROOM then
	        self.mScene.m_multiple_text:setText( name or "中级场");
        elseif roomType == RoomConfig.ROOM_TYPE_MASTER_ROOM then
	        self.mScene.m_multiple_text:setText( name or "高级场");
        elseif roomType == RoomConfig.ROOM_TYPE_PRIVATE_ROOM then
	        self.mScene.m_multiple_text:setText( name or "私人房");
        elseif roomType == RoomConfig.ROOM_TYPE_FRIEND_ROOM then
	        self.mScene.m_multiple_text:setText( name or "好友房");
        elseif roomType == RoomConfig.ROOM_TYPE_ARENA_ROOM then
	        self.mScene.m_multiple_text:setText( name or "竞技场");
        elseif roomType == RoomConfig.ROOM_TYPE_MONEY_MATCH_ROOM then
	        self.mScene.m_multiple_text:setText("金币赛");
        elseif roomType == RoomConfig.ROOM_TYPE_METIER_ROOM then
	        self.mScene.m_multiple_text:setText("赏金赛");
        else
	        self.mScene.m_multiple_text:setText("观战房");
        end
    end
end

function WatchModule.dtor(self)
	self.mScene.m_multiple_text:setText("");
    delete(self.m_watch_dialog);
    self.mScene:setIsWatchGiftAnim(false)
    RoomProxy.getInstance():setCurRoomModeIsWatch(false)
    self.mScene.m_room_watcher_btn:setPos(47,-28);
end

function WatchModule.initGame(self)
    --	self.m_room_watcher_bg_btn:setVisible(false);
    self.mScene.m_room_watcher_btn:setEnable(true);
--	self.mScene.m_down_name:setVisible(true);
--	self.mScene.m_up_name:setVisible(true);
    self.mScene.m_roomid:setVisible(false);
    self.mScene.m_room_menu_view:setVisible(false);
    self.mScene.m_chest_btn:setVisible(false);
	self:startWatch();
    -- 加载历史聊天消息
    self:loadHistoryMsgs();
end

function WatchModule.resetGame(self)
    self.mScene.m_watcher_count = 0;
--	self.mScene.m_down_name:setVisible(false);
--	self.mScene.m_up_name:setVisible(false);
end

function WatchModule.dismissDialog(self)

end

function WatchModule.readyAction(self)
    self.mScene:stopTimeout();

	self.mScene:clearDialog();
    if self.mScene.m_downUser then
	    if  self.mScene.m_downUser:getUid() == leaveUid then
            self.mScene:downGetOut();
	    else
            self.mScene:upGetOut();
	    end
    end;
end

function WatchModule.backAction(self)
    print_string("Room.onWatchBack");
	self.mScene:exitRoom();
end

function WatchModule.setStatus(self,status,op_uid)
    if self.mScene.m_t_statuss == STATUS_TABLE_PLAYING then   --走棋状态
	elseif self.mScene.m_t_statuss == STATUS_TABLE_FORESTALL then  -- 抢先状态
        if op_uid then
            if self.mScene.m_downUser and self.mScene.m_downUser:getUid() == op_uid then
                self.mScene.m_toast_text:setText(self.mScene.m_downUser:getName() .. "抢先中...");
            end
            if self.mScene.m_upUser and self.mScene.m_upUser:getUid() == op_uid then
                self.mScene.m_toast_text:setText(self.mScene.m_upUser:getName() .. "抢先中...");
            end
        else
            self.mScene.m_toast_text:setText("抢先中...");
        end
        self.mScene.m_toast_bg:setVisible(true);
        ShowMessageAnim.reset();
	elseif self.mScene.m_t_statuss == STATUS_TABLE_HANDICAP then  -- 让子状态
        if op_uid then
            if self.mScene.m_downUser and self.mScene.m_downUser:getUid() == op_uid then
                self.mScene.m_toast_text:setText(self.mScene.m_downUser:getName() .. "让子中...");
            end
            if self.mScene.m_upUser and self.mScene.m_upUser:getUid() == op_uid then
                self.mScene.m_toast_text:setText(self.mScene.m_upUser:getName() .. "让子中...");
            end
        else
            self.mScene.m_toast_text:setText("双方让子中...");
        end
        self.mScene.m_toast_bg:setVisible(true);
        ShowMessageAnim.reset();
	elseif self.mScene.m_t_statuss == STATUS_TABLE_RANGZI_CONFIRM then   -- 让子确认状态
        if op_uid then
            if self.mScene.m_downUser and self.mScene.m_downUser:getUid() == op_uid then
                self.mScene.m_toast_text:setText(self.mScene.m_downUser:getName() .. "让子确认中...");
            end
            if self.mScene.m_upUser and self.mScene.m_upUser:getUid() == op_uid then
                self.mScene.m_toast_text:setText(self.mScene.m_upUser:getName() .. "让子确认中...");
            end
        else
            self.mScene.m_toast_text:setText("双方让子确认中...");
        end
        self.mScene.m_toast_bg:setVisible(true);
        ShowMessageAnim.reset();
	elseif self.mScene.m_t_statuss == STATUS_TABLE_SETTIME then -- 设置局时状态
        if op_uid then
            if self.mScene.m_downUser and self.mScene.m_downUser:getUid() == op_uid then
                self.mScene.m_toast_text:setText(self.mScene.m_downUser:getName() .. "设置棋局中...");
            end
            if self.mScene.m_upUser and self.mScene.m_upUser:getUid() == op_uid then
                self.mScene.m_toast_text:setText(self.mScene.m_upUser:getName() .. "设置棋局中...");
            end
        else
            self.mScene.m_toast_text:setText("设置棋局中...");
        end
        self.mScene.m_toast_bg:setVisible(true);
        ShowMessageAnim.reset();
    elseif self.mScene.m_t_statuss == STATUS_TABLE_SETTIMERESPONE then
        if op_uid then
            if self.mScene.m_downUser and self.mScene.m_downUser:getUid() == op_uid then
                self.mScene.m_toast_text:setText("等待" ..self.mScene.m_downUser:getName() .. "同意棋局设置...");
            end
            if self.mScene.m_upUser and self.mScene.m_upUser:getUid() == op_uid then
                self.mScene.m_toast_text:setText("等待" ..self.mScene.m_upUser:getName() .. "同意棋局设置...");
            end
        else
            self.mScene.m_toast_text:setText("设置棋局中...");
        end
        self.mScene.m_toast_bg:setVisible(true);
        ShowMessageAnim.reset();
    else
    end
end

function WatchModule.startWatch(self)
    self.mScene:requestCtrlCmd(OnlineRoomController.s_cmds.start_watch);
end

function WatchModule.showWatchUpUser(self)
    self.up_view_status = OnlineUserInfoCommonView.WATCH_LEFT
    self.mScene.m_up_view1:initWatchView(self.up_view_status)
end


function WatchModule.showWatchDownUser(self)
    self.down_view_status = OnlineUserInfoCommonView.WATCH_RIGHT
    self.mScene.m_down_view1:initWatchView(self.down_view_status)
    self.mScene.m_room_watcher_btn:setPos(5,0);
end

function WatchModule.showNewWatchView(self)
    if not self.m_watch_dialog then
        self.m_watch_dialog = new(WatchDialog, self.mScene);
    end
    self.m_watch_dialog:setLevel(20)
    self.m_watch_dialog:show();
end

function WatchModule.loadHistoryMsgs(self)
    OnlineSocketManager.getHallInstance():sendMsg(OB_CMD_GET_HISTORY_MSGS);
end

--更新关注的弹窗
function WatchModule.sendFllowCallback(self,info)
end
-- 更新玩家桌子
function WatchModule.onUpdateWatchRoom(self, data, message)
    if not data then
        self.mScene:loginFail(message)
        return;
    end;

    local player1 = data.player1;
    local player2 = data.player2;
    local userName = ""
    -- 观战棋桌未初始化
    -- 1.观战时显示对局中双方较贵的棋盘
            --a)优先级：会员棋盘＞竹林棋盘＞湖畔棋盘＞怀旧棋盘＞普通棋盘
    if self.m_board_bg_res == nil then
        if player1 then
            local userset = player1:getUserSet()
            if type(userset) == "table" and UserSetInfo.checkExistBoardRes(userset.board) then
                self.m_board_bg_res = userset
                userName = player1:getName()
            end
        end
        if player2 then
            local userset = player2:getUserSet()
            if type(userset) == "table" and UserSetInfo.checkExistBoardRes(userset.board) then
                local set = userset
                if not self.m_board_bg_res or UserSetInfo.comparisonResValue(set.board,self.m_board_bg_res.board) > 0 then
                    self.m_board_bg_res = set
                    userName = player1:getName()
                end
            end
        end
    end

    if type(self.m_board_bg_res) == "table" then
        local res = UserSetInfo.getChessBoardRes(self.m_board_bg_res.board)
        if res then 
            self.mScene.m_board_bg:setFile(res.board);
            self.mScene.m_room_bg:setFile(res.bg_img);
            local tabName = res.name or ""
            if tabName ~= "默认" then
                ChessToastManager.getInstance():showSingle( string.format("当前展示棋盘为%s的 %s",userName,tabName))
            end
        end
        local pieceRes = UserSetInfo.getChessMapRes(self.m_board_bg_res.piece)
        if pieceRes then 
            self.mScene.m_board:setBoardresMap(pieceRes.piece_res)
        end
    end
    -- 不再初始化
    self.m_board_bg_res = -1

    if player1 then
        if player1:getFlag() == 1 then
            self.mScene:downComeIn(player1);
        else
            self.mScene:upComeIn(player1);
        end
    end
    if player2 then
        if player2:getFlag() == 1 then
            self.mScene:downComeIn(player2);
        else
            self.mScene:upComeIn(player2);
        end
    end
    if not player1 and not player2 then
        self:onWatchRoomUserLeave();
        return;
    end
    self.mScene.m_timeout1 = data.round_time;
	self.mScene.m_timeout2 = data.step_time;
	self.mScene.m_timeout3 = data.sec_time;
    if player1 and data.curr_move_flag == player1:getUid() then
        self.mScene.m_move_flag = player1:getFlag();
    elseif player2 and data.curr_move_flag == player2:getUid() then
        self.mScene.m_move_flag = player2:getFlag();
    end
    if self.mScene.m_move_flag == FLAG_RED then
        self.mScene.m_red_turn = true;
    else
        self.mScene.m_red_turn = false;
    end;
    if data.status == 2 then--只有在状态2（playing）才有下面信息
        self.mScene:setStatus(data.status);
        local last_move = {}
	    last_move.moveChess = data.chessMan;
	    last_move.moveFrom = 91 -data.position1;
	    last_move.moveTo = 91 - data.position2;
	    self.mScene:synchroData(data.chess_map,last_move);
        -- 观战中途加入 获取开局时间
        RoomProxy.getInstance():sendGetRoomStartTimeCmd()
    else
        self.mScene:setStatus(data.status);
--        ShowMessageAnim.play(self.m_root_view,"等待开局");
        local message =  "等待开局"; 
        ChessToastManager.getInstance():showSingle(message);   
    end
end

function WatchModule.sendWatchChat(self, message)
    self.mScene:requestCtrlCmd(OnlineRoomController.s_cmds.send_watch_chat, message);
end

function WatchModule.onWatchRoomMove(self, data)
    if not data then return end;
    if self.mScene.m_downUser and data.last_move_uid == self.mScene.m_downUser:getUid() and self.mScene.m_upUser then
        if self.mScene.m_downUser:getFlag() == FLAG_RED then
		    self.mScene.m_downUser:setTimeout1((self.mScene.m_timeout1 - data.red_timeout));
            self.mScene.m_upUser:setTimeout1(self.mScene.m_timeout1 - data.black_timeout);
            self.mScene.m_move_flag = FLAG_BLACK;--此函数内接收的是已经走完的棋，所以将要走的棋标志置反。
        else
            self.mScene.m_downUser:setTimeout1((self.mScene.m_timeout1 - data.black_timeout));
            self.mScene.m_upUser:setTimeout1(self.mScene.m_timeout1 - data.red_timeout);
            self.mScene.m_move_flag = FLAG_RED;
        end;
		self.mScene.m_downUser:setTimeout2(self.mScene.m_timeout2);
		self.mScene.m_downUser:setTimeout3(self.mScene.m_timeout3);
    elseif self.mScene.m_upUser and data.last_move_uid == self.mScene.m_upUser:getUid() then
        if self.mScene.m_upUser:getFlag() == FLAG_RED then
		    self.mScene.m_upUser:setTimeout1((self.mScene.m_timeout1 - data.red_timeout));
            self.mScene.m_downUser:setTimeout1(self.mScene.m_timeout1 - data.black_timeout);
            self.mScene.m_move_flag = FLAG_BLACK;
        else
            self.mScene.m_upUser:setTimeout1((self.mScene.m_timeout1 - data.black_timeout));
            self.mScene.m_downUser:setTimeout1(self.mScene.m_timeout1 - data.red_timeout);
            self.mScene.m_move_flag = FLAG_RED;
        end;
		self.mScene.m_upUser:setTimeout2(self.mScene.m_timeout2);
		self.mScene.m_upUser:setTimeout3(self.mScene.m_timeout3);
    end;
    self.mScene:setStatus(data.status);
    if data.ob_num then
     	local str = string.format("%d",data.ob_num);
--	    self.m_room_watcher:setText(str);   
    end;

    local mv = {}
	mv.moveChess = data.chessMan;
	mv.moveFrom = data.position1;
	mv.moveTo = data.position2;
	self.mScene:resPonseMove(mv);
end

function WatchModule.onWatchRoomUserLeave(self, data)
    if not data then
        return 
    end
    local leaveUid = data.uid;
    self.mScene:stopTimeout();

	self.mScene:clearDialog();
    if self.mScene.m_downUser then
	    if self.mScene.m_downUser:getUid() == leaveUid then
            self.mScene:downGetOut();
	    else
            self.mScene:upGetOut();
	    end
    end;
    ChessToastManager.getInstance():showSingle("正在等待棋手入场",10000);
end


function WatchModule.onWatchRoomStart(self, data)
    if not data then
        return 
    end;
    self.mScene.m_timeout1 = data.round_time;
	self.mScene.m_timeout2 = data.step_time;
	self.mScene.m_timeout3 = data.sec_time;
	
    if self.mScene.m_downUser then
	    self.mScene.m_downUser:setTimeout1(data.round_time);
	    self.mScene.m_downUser:setTimeout2(data.step_time);
	    self.mScene.m_downUser:setTimeout3(data.sec_time);
    end

    if self.mScene.m_upUser then
	    self.mScene.m_upUser:setTimeout1(data.round_time);
	    self.mScene.m_upUser:setTimeout2(data.step_time);
	    self.mScene.m_upUser:setTimeout3(data.sec_time);
    end

    if self.mScene.m_downUser then
	    if self.mScene.m_downUser:getUid() == data.red_uid then
		    self.mScene.m_downUser:setFlag(FLAG_RED);
		    if self.mScene.m_upUser then
			    self.mScene.m_upUser:setFlag(FLAG_BLACK);
		    end
	    else
		    self.mScene.m_downUser:setFlag(FLAG_BLACK);
		    if self.mScene.m_upUser then
			    self.mScene.m_upUser:setFlag(FLAG_RED);
		    end
	    end
    end

    local player1 = self.mScene.m_downUser;
    local player2 = self.mScene.m_upUser;

    if player1 then
        if player1:getFlag() == 1 then
            self.mScene:downComeIn(player1);
        else
            self.mScene:upComeIn(player1);
        end
    end

    if player2 then
        if player2:getFlag() == 1 then
            self.mScene:downComeIn(player2);
        else
            self.mScene:upComeIn(player2);
        end
    end

    self.mScene.m_move_flag = FLAG_RED;
    self.mScene.m_red_turn = true;
    self.mScene:setStatus(data.status);
	self.mScene:startGame(data.chess_map);
end

function WatchModule.onWatchRoomClose(self, data)
	self:setWatchUsersInfo(data);
    self.mScene:setStatus(data.status);
	self.mScene:gameClose(data.win_flag,data.end_type);    
end

function WatchModule.setWatchUsersInfo(self, data)
    if not self.mScene.m_upUser or not self.mScene.m_downUser then return end;
    if  self.mScene.m_downUser:getFlag() == 1 then
		self.mScene.m_downUser:setScore(data.red_total_score or 0);
        self.mScene.m_downUser:setPoint(data.red_turn_score);
        self.mScene.m_downUser:setCoin(data.red_turn_money);
		self.mScene.m_downUser:setMoney(data.red_total_money or 0);
		self.mScene.m_downUser:setCup(data.red_turn_cup or 0);
        
		self.mScene.m_upUser:setScore(data.black_total_score or 0);
		self.mScene.m_upUser:setPoint(data.black_turn_score);
		self.mScene.m_upUser:setCoin(data.black_turn_money);
		self.mScene.m_upUser:setMoney(data.black_total_money or 0);
		self.mScene.m_upUser:setCup(data.black_turn_cup or 0);
	else
		self.mScene.m_upUser:setScore(data.red_total_score or 0);
        self.mScene.m_upUser:setPoint(data.red_turn_score);
        self.mScene.m_upUser:setCoin(data.red_turn_money);
		self.mScene.m_upUser:setMoney(data.red_total_money or 0);
		self.mScene.m_upUser:setCup(data.red_turn_cup or 0);

		self.mScene.m_downUser:setScore(data.black_total_score or 0);
		self.mScene.m_downUser:setPoint(data.black_turn_score);
		self.mScene.m_downUser:setCoin(data.black_turn_money);
		self.mScene.m_downUser:setMoney(data.black_total_money or 0);
		self.mScene.m_downUser:setCup(data.black_turn_cup or 0);
	end
end

function WatchModule.onWatchRoomAllReady(self, data)
    if not data then
        return;
    end
    if data.tid then
        local message =  "双方已准备(等待开局)"; 
        ChessToastManager.getInstance():showSingle(message); 
    end
end

function WatchModule.onWatchRoomError(self, data)
    local message =  "观战房间出现问题,请重新进入"; 
    ChessToastManager.getInstance():showSingle(message); 
    self.mScene:exitRoom();
end

function WatchModule.onWatchRoomUpdateTable(self,data)
	if data and data.status then
        self.mScene:setStatus(data.status,data.curr_op_uid);
    end
end

function WatchModule.onWatcherChatMsg(self, data)
    if data.uid ~= UserInfo.getInstance():getUid() then
        local name      = data.name;
        local msgType   = data.msgType;
        local message   = data.message;
        local uid       = data.uid;
        if not message or message == "" then
		    return;
	    end
	    local msg = string.format("%s:%s",name,message);
        if OnlineRoomSceneNew.IS_NEW and self.m_watch_dialog then -- 是自己发的观战消息显示在
            self.m_watch_dialog:addChatLog(name,message,uid);
        else
	        self.mScene.m_chat_dialog:addChatLog(name,message,uid);
            if self.mScene.m_chat_btn and not self.mScene.m_chat_dialog:isShowing() then 
               if self.mScene.m_chat_btn:getChildByName("notice") then
                    self.mScene.m_chat_btn:getChildByName("notice"):setVisible(true);
               end 
            end
        end
    end
end

function WatchModule.onWatchRoomDraw(self, data)
	if  self.mScene.m_downUser and self.mScene.m_downUser:getUid() == data.uid then
        ChatMessageAnim.play(self.mScene.m_root_view,3,self.mScene.m_downUser:getName().." 和棋申请成功");
	elseif self.mScene.m_upUser and self.mScene.m_upUser:getUid() == data.uid then
        ChatMessageAnim.play(self.mScene.m_root_view,3,self.mScene.m_upUser:getName().." 和棋申请成功");
	end
end


function WatchModule.onWatchRoomSurrender(self, data)
	if  self.mScene.m_downUser and self.mScene.m_downUser:getUid() == data.uid then
        ChatMessageAnim.play(self.mScene.m_root_view,3,self.mScene.m_downUser:getName().." 认输");
	elseif self.mScene.m_upUser and self.mScene.m_upUser:getUid() == data.uid then
        ChatMessageAnim.play(self.mScene.m_root_view,3,self.mScene.m_upUser:getName().." 认输");
	end

end;

function WatchModule.onWatchRoomUndo(self, data)
	self.mScene:setStatus(data.status);
	if  self.mScene.m_downUser and self.mScene.m_downUser:getUid() == data.undo_uid then
        ChatMessageAnim.play(self.mScene.m_root_view,3,self.mScene.m_downUser:getName().." 悔棋一步");
	elseif self.mScene.m_upUser and self.mScene.m_upUser:getUid() == data.undo_uid then
        ChatMessageAnim.play(self.mScene.m_root_view,3,self.mScene.m_upUser:getName().." 悔棋一步");
	end
	if  data.chessID1 ~= 0 then
		local mv = {}
		mv.moveChess = data.chessID1;
		mv.moveFrom = data.position1_1;
		mv.moveTo = data.position1_2;
		mv.dieChess = data.eatChessID1;
		self.mScene:resPonseUndoMove(mv);
	end


	if  data.chessID2 ~= 0 then
		local mv = {}
		mv.moveChess = data.chessID2;
		mv.moveFrom = data.position2_1;
		mv.moveTo = data.position2_2;
		mv.dieChess = data.eatChessID2;
		self.mScene:resPonseUndoMove(mv);
	end
end

function WatchModule.onWatchRoomUserEnter(self,packetInfo)
    if not packetInfo or not next(packetInfo) then return end;
    if packetInfo.play_count and tonumber(packetInfo.play_count) == 1 then
        if self.mScene.m_downUser then
            self.mScene:downComeIn(packetInfo.player);
        end
    else
        if self.mScene.m_upUser then
            self.mScene:upComeIn(packetInfo.player);
        end
    end;
end

function WatchModule.onWatchRoomMsg(self,packetInfo)
    if not packetInfo or not packetInfo.chat_msg or packetInfo.chat_msg == ""  or not packetInfo.name or packetInfo.name == "" then
		return;
	end
    if packetInfo and packetInfo.uid == UserInfo.getInstance():getUid() then
        if packetInfo.forbid_time == -1 then 
            ChessToastManager.getInstance():showSingle("亲，消息不能为空或频繁发送哦",1500);
            return;
        end;
    end;

    local sendInfo = json.decode(packetInfo.send_info) or {}
	local msg = string.format("%s:%s",packetInfo.name,packetInfo.chat_msg);
    if OnlineRoomSceneNew.IS_NEW and self.m_watch_dialog then
        self.m_watch_dialog:addChatLog(packetInfo.name,packetInfo.chat_msg,packetInfo.uid,sendInfo);
    else
	    self.mScene.m_chat_dialog:addChatLog(packetInfo.name,packetInfo.chat_msg,packetInfo.uid,sendInfo);
        if self.mScene.m_chat_btn and not self.mScene.m_chat_dialog:isShowing() then 
           if self.mScene.m_chat_btn:getChildByName("notice") then
            self.mScene.m_chat_btn:getChildByName("notice"):setVisible(true);
           end 
        end
    end
end

function WatchModule.showFullScreen(self)
    if self.m_watch_dialog then
        self.m_watch_dialog:fullScreen();
    end
end

function WatchModule.updataWatchNum(self,info)
    if self.m_watch_dialog then
        self.m_watch_dialog:updataWatchNum(info);
    end
end

function WatchModule.updataWatchHistoryMsgs(self,info)
    if self.m_watch_dialog then
        self.m_watch_dialog:updataWatchHistoryMsgs(info);
    end
end

--接收礼物广播
function WatchModule.receiveGiftMsg(self, data)
--data {gift_type=16 send_id=1407 gift_count=1 target_id=10000441 }
    if not data or not self.m_watch_dialog then return end
    local gift_send_id = tonumber(data.send_id)
    local gift_target_id = tonumber(data.target_id);
    local send_info = json.decode(data.send_info) or {}
    local name = "博雅象棋"
    if self.mScene.m_downUser then
        if self.mScene.m_downUser.m_uid == gift_target_id then
            name = self.mScene.m_downUser:getName()
        end
    end
    if self.mScene.m_upUser then
        if self.mScene.m_upUser.m_uid == gift_target_id then
            name = self.mScene.m_upUser:getName()
        end
    end
    local tab = {}
    tab.sendInfo = send_info or {}
    tab.targetName = name or "博雅象棋"
    tab.sendId = gift_send_id or 0
    tab.targetId = gift_target_id or 0
    tab.gift_type = tonumber(data.gift_type) or 16
    tab.score = tonumber(data.score) or 1000
    tab.giftNum = tonumber(data.gift_count) or 1
    tab.msgTime = os.time()
    tab.key = tostring(tab.sendId) .. tostring(tab.targetId) .. tostring(tab.gift_type)
    self.m_watch_dialog:addChatTips(tab,1);


    --下面是弹幕代码已经去掉
    --检测cell中是否有相同类型消息
--    local key = tostring(tab.sendId) .. tostring(tab.targetId) .. tostring(tab.gift_type)
--    for k,v in pairs(self.cellList) do
--        if v then
--            if v.state == 1 then
--                if v.node and v.node.key ==  key then
--                    local node = v.node
--                    if node:updateData(tab) then
--                        node:resumeNunAnim()
--                    end
--                    return
--                end
--            end
--        end
--    end
     
    --检测缓存中是否存在,并添加
--    local index = self.indexList[key]
--    local dataCacheLen =  #self.dataCache or 0
--    if index then
--        local cacheTime = self.dataCache[index].msgTime
--        local dataTime = tab.msgTime
--        if (dataTime - cacheTime) >= 2 then
--            --判断上一条消息和当前消息事件间隔 
--            self.indexList[key] = dataCacheLen + 1
--            table.insert(self.dataCache,tab)
--        else
--            --更新时间和礼物数量
--            local cacheGiftNum = self.dataCache[index].giftNum
--            tab.giftNum = tab.giftNum + cacheGiftNum
--            self.dataCache[index] = tab
--        end
--    else
--        self.indexList[key] = dataCacheLen + 1
--        table.insert(self.dataCache,tab)
--    end
    --end

end

--function WatchModule.createItemNode(self,index)
--    if next(self.dataCache) == nil then return end
--    local data = self.dataCache[1]
--    local node = WatchItemStyle.createLeftDanmuItem(data)
--    node:setEndCallBack(self,self.deleteNode)
--    table.remove(self.dataCache,1)
--    local listKey = data.key
--    self.indexList[listKey] = nil
--    node:setPos(self.posTab[index].x,self.posTab[index].y)
--    self.mScene.m_left_danmu_view:addChild(node)
--    self.cellList[index].node = node
--    self.cellList[index].state = 1
--    node:startAnim()
--end

--function WatchModule.deleteNode(self,node)
--    if not node then return end
--    for k,v in pairs(self.cellList) do
--        if v and v.node then
--            if v.node.key == node.key then
--                delete(node)
--                v.node = nil
--                v.state = 0
--            end
--        end
--    end

--end

--[Comment]
--检测cell状态
--function WatchModule.checkCellList(self)
--    for k,v in pairs(self.cellList) do
--        if v and v.state == 0 then
--            return k 
--        end
--    end
--end

--[Comment]
--重置cell状态
--function WatchModule.resetNodeStatus(self)
--    for k,v in pairs(self.cellList) do
--        if v and not v.node then
--            v.state = 0
--        end
--    end
--end


--function WatchModule.startNodeTimer(self)
--    self.animTimer = new(AnimInt,kAnimRepeat,0,1,1000/60, -1)
--    self.animTimer:setEvent(self,function()
--        self:resetNodeStatus()
--        local cellIndex = self:checkCellList()
--        if cellIndex then
--            self:createItemNode(cellIndex)
--        end
--    end)
--end

--[Comment]
--退出房间是需要调用一下！！
--function WatchModule.onDtor(self)
--    for k,v in pairs(self.cellList) do
--        if v and v.node then
--            delete(v.node)
--            v.node = nil
--        end
--    end 
--    delete(self.animTimer)
--    self.animTimer = nil
--    self.dataCache = {}
--    self.cellList = {}
--    self.indexList = {}
--end

function WatchModule.onServerReturnsVipLogin(self,info)
    if self.m_watch_dialog then
        self.m_watch_dialog:addMsgVipLogin(info);
    end
end

-- 保存棋谱
function WatchModule:onSaveChessCallBack( data)
    if data.cost then
        if self.mScene.m_account_dialog then
		    self.mScene.m_account_dialog:setHasSaved();
	    end
    end
end


function WatchModule.switchSide(self)
    self.up_view_status = (self.up_view_status == OnlineUserInfoCommonView.WATCH_LEFT and OnlineUserInfoCommonView.WATCH_RIGHT) or OnlineUserInfoCommonView.WATCH_LEFT
    self.down_view_status = (self.down_view_status == OnlineUserInfoCommonView.WATCH_LEFT and OnlineUserInfoCommonView.WATCH_RIGHT) or OnlineUserInfoCommonView.WATCH_LEFT
    self.mScene.m_down_view1:switchView(self.down_view_status,true)
    self.mScene.m_up_view1:switchView(self.up_view_status,true)
end
