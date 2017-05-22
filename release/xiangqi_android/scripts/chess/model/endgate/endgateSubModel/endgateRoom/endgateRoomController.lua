require("config/path_config");

require(MODEL_PATH.."/room/roomController");

EndgateRoomController = class(RoomController);

EndgateRoomController.s_cmds = 
{	
    onBack              = 1;
    loadEndingBoard     = 2;
    loadNextGate        = 3;
    shareInfo           = 4;
    onEventStat         = 5;
    tip_action          = 6;
    revive              = 7;
    subMove1            = 8;
    subMove2            = 9;
    subMove3            = 10;
    undoMove            = 11;
    shareUrl            = 12;
    restart             = 13;
    sharePicture        = 14;

};

EndgateRoomController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
    require("dialog/http_loading_dialog");
    self.m_load_socket_dialog = HttpLoadingDialogFactory.createLoadingDialog(HttpLoadingDialog.s_type.Simple);
    self.m_load_socket_dialog:setNeedBackEvent(false);
end


EndgateRoomController.resume = function(self)
	RoomController.resume(self);
	Log.i("EndgateRoomController.resume");
    self:start_action();
end

EndgateRoomController.pause = function(self)
	RoomController.pause(self);
	Log.i("EndgateRoomController.pause");
end

EndgateRoomController.dtor = function(self)
    delete(self.m_load_socket_dialog);
    self:stopTimeout();
end
--------------------------- father func ----------------------
EndgateRoomController.updateUserInfoView = function(self)
    self:updateView(EndgateRoomScene.s_cmds.updateView);
end


-------------------------------- func ------------------------------

EndgateRoomController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end

EndgateRoomController.start_action = function(self)
	self:onLoadEndingBoard();
    self:setGameOver2(false);
    self:showTips();
end

EndgateRoomController.restart = function(self)
    if self.m_game_over == false then
        self:upPhpInfo(0);
    end
    self:onLoadEndingBoard();
end

--拉取出棋盘
EndgateRoomController.onLoadEndingBoard = function(self)
    kEndgateData:setStartTime(os.time());
    Log.i("aaa onLoadEndingBoard");
    self.m_used_undoMove_num = 0;
    self.m_used_tip_num = 0;
    self.m_used_revive_num = 0;
	local gate = kEndgateData:getGate();  --获取哪一大关

	local gate_sort = kEndgateData:getGateSort(); ---获取哪一小关
    if gate_sort + 1 > gate.chessrecord_size then
        ChessToastManager.getInstance():showSingle("当前章节已经通关！");
        return ;
    end
    self:setGameOver2(false);
    if "win32"==System.getPlatform() then
        self:onLoadEndingBoardByWin32(gate.chessrecord[gate_sort+1]);
    elseif "android"==System.getPlatform() then
        local params = {};
        params.tid = gate.tid;
        params.sort = gate_sort;

        dict_set_string(kEndingUtilNewGetSubGateJsonStrByTidAndSort,
            kEndingUtilNewGetSubGateJsonStrByTidAndSort..kparmPostfix,
        json.encode(params));
        call_native(kEndingUtilNewGetSubGateJsonStrByTidAndSort);
        Log.i("aaa"..json.encode(params));
    elseif "ios"==System.getPlatform() then
        local params = {};
        params.tid = gate.tid;
        params.sort = gate_sort;

        dict_set_string(kEndingUtilNewGetSubGateJsonStrByTidAndSort,
            kEndingUtilNewGetSubGateJsonStrByTidAndSort..kparmPostfix,
        json.encode(params));
        call_native(kEndingUtilNewGetSubGateJsonStrByTidAndSort);
        Log.i("aaa"..json.encode(params));
    end
--    StatisticsUtil.Log (StatisticsUtil.TYPE_PLAY,"endgate");
--    self.m_boradCode = CHESS_MOVE_OVER_RED_WIN;
--    self:showResultDialog();
end

EndgateRoomController.showResultDialog = function(self)
	if self.m_boradCode == CHESS_MOVE_OVER_RED_WIN then
        self:upPhpInfo(1);
		if kEndgateData:isLatestGate() then--是否是最新关
            self:updateView(EndgateRoomScene.s_cmds.showWinDialog);
            EndgateScene.s_showPassAnim = true;
		else
            self:updateView(EndgateRoomScene.s_cmds.showEndingResultDialog,self.m_boradCode);
		end
	else
        self:upPhpInfo(0);
        self:updateView(EndgateRoomScene.s_cmds.showEndingResultDialog,self.m_boradCode);
	end
    self:setGameOver2(true);
end

EndgateRoomController.upPhpInfo = function(self,isWin)
    local post_data = {};
    post_data.game_type = 20;
    post_data.start_time = kEndgateData:getStartTime();
    post_data.end_time = os.time();
    post_data.is_win = isWin or 0;
    post_data.game_tid = kEndgateData:getGate().tid;
    post_data.game_pos = kEndgateData:getGateSort();
    post_data.move_step = self.m_board.pos.moveNum or 0;
    post_data.user_prop = {};
    post_data.user_prop["21"] = self.m_used_undoMove_num;
    post_data.user_prop["31"] = self.m_used_tip_num;
    post_data.user_prop["41"] = self.m_used_revive_num;
    HttpModule.getInstance():execute(HttpModule.s_cmds.uploadConsole2Php,post_data);
end


EndgateRoomController.setGameOver2 = function(self,flag)
	print_string("EndgateRoomController.setGameOver");
	self.m_game_over = flag;
    self:updateView(EndgateRoomScene.s_cmds.setGameOver,flag,self.m_boradCode);
end


EndgateRoomController.loadNextGate = function(self)
    self:onEventStat(ENDGIN_ROOM_MODEL_NEXTGATE_BTN);

	local gate_sort = kEndgateData:getGateSort();
	gate_sort = gate_sort +1;
    Log.i("gate_sort:"..gate_sort);
	local gate = kEndgateData:getGate();
	local uid = UserInfo.getInstance():getUid();
	local curNum = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_GATE_NUM..uid,1);

	kEndgateData:setGateSort(gate_sort);
--    StateMachine.getInstance():popState(StateMachine.STYPE_WAIT);  -- 播放过关动画
	self:onLoadEndingBoard();
end

EndgateRoomController.shareInfo = function(self)
    self:onEventStat(ENDGIN_ROOM_MODEL_SHARE_BTN);
--	share_img_msg("egame_share");
    self:shareUrl();
end

EndgateRoomController.shareUrl = function(self)
	local id = kEndgateData:getBoardTableId();
--    local url = "http://h5.oa.com/chess/?type=1&id="..id;--测试服
    local url = "http://cnchess.17c.cn/h5/?type=1&id="..id;--正式服
    local data = {};
    data.booth_id = id;
    HttpModule.getInstance():execute(HttpModule.s_cmds.boothShare,data);
    data.flag = UserInfo.getInstance():getOpenWeixinShare();
    data.url = url;
    if kPlatform == kPlatformIOS then
        data.title = "残局挑战";
        data.description = kEndgateData:getBoardTableSubTitle();
        share_text_msg(json.encode(data));
    else
        data.title = kEndgateData:getBoardTableSubTitle();
        share_text_msg(json.encode(data));
    end;
end

EndgateRoomController.sharePicture = function(self)
    Log.i("EndgateRoomController.onShareAction");
	self:onEventStat(ENDGIN_ROOM_MODEL_SHARE_BTN);
	share_img_msg("egame_share");
end;


EndgateRoomController.onEventStat = function(self,event_id)
	local tid = kEndgateData:getGateTid();
	local sort = kEndgateData:getGateSort();
	local event_info = event_id .. ","  ..  "level_" .. tid .. "_" .. sort;
	on_event_stat(event_info); --事件统计
end



EndgateRoomController.onLoadEndingBoardByWin32 = function(self,data)
    if data then
        local board_table = data;
        local cb = self.buildChessbookFromTable(board_table.move);
        kEndgateData:setBoardTable(board_table);

        local fen = board_table.fen;
        self.m_board:ending_game(fen);

        self.m_cb = cb;

        self:setMyTurn(true);
        self:updateView(EndgateRoomScene.s_cmds.startGame,board_table);
    end
end

EndgateRoomController.onLoadEndingBoardByAndroid = function(self,status,data)
    if not status then
        ChessToastManager.getInstance():showSingle("关卡数据损坏，请联系GM");
        return ;
    end
    data = json.analyzeJsonNode(data);
    if not data then
        ChessToastManager.getInstance():showSingle("关卡数据损坏，请联系GM");
        return ;
    end
    self:onLoadEndingBoardByWin32(data);
end

-- 从json字符串创建一个chessbook
EndgateRoomController.buildChessbookFromTable = function(moveDict)
    print("EndgateRoomController.buildChessbookFromJsonString Start parsing")
    require("util/chessbook");
    if moveDict == nil then
        print("[buildChessbookFromJsonString]Error: Invalid Json string")
        return nil
    end

    local masterMoveList = moveDict["movelist"]
    local subMoveList = moveDict["submovelist"]

    cb = ChessBook_Create()

    if masterMoveList == nil then
        print("[buildChessbookFromJsonString]Error: Can't find token 'movelist'")
        return nil
    end

    for i,v in pairs(masterMoveList) do
        local move = EndgateRoomController.extractMoveFromDict(v)
        ChessBook_PushBackMaster(cb, move)
    end

    if subMoveList then
	    for i,v in pairs(subMoveList) do
	        for _,moves in pairs(v) do
	            subMove = EndgateRoomController.extractMoveFromDict(moves)
	            ChessBook_PushBackBranch(cb, tonumber(i), subMove)
	        end
	    end
    else
        print("[buildChessbookFromJsonString]Error: Can't find token 'submovelist'")
        --return nil
    end

    print("EndgateRoomController.buildChessbookFromJsonString Parse End")

    return cb
end

-- 从一个table中解析着法节点
EndgateRoomController.extractMoveFromDict = function(dict)
   	node = {}

    if dict ~= nil then
        node.comment = dict["comment"]
        node.src = tonumber(dict["src"])
        node.dst = tonumber(dict["dst"])
        node.sub = dict["sub"]

        if node.sub ~= nil then
            local i = 1
            for i = 1, #node.sub do
                node.sub[i] = tonumber(node.sub[i])
            end
        end

        node.branch = 0
    end

    return node
end
EndgateRoomController.aiUnlegalMove = function(self,flag,data)
    self:updateView(EndgateRoomScene.s_cmds.console_gameover,UserInfo.getInstance():getFlag(),ENDTYPE_UNLEGAL);
end

EndgateRoomController.aiUnchangeMove = function(self,flag,data)
    self:updateView(EndgateRoomScene.s_cmds.console_gameover,1,ENDTYPE_UNCHANGE);
end

--走棋不合法
EndgateRoomController.unlegalMove = function(self,code)
	--[[//错误码 -1 走法不合规则 -2 相同方不可互吃 -3 找不到当前棋桌  -4 对手为空 -5 对方尚未走棋，请等待
        //  -6 客户端状态与服务端状态不一致，需要同步   -8 UID 不合法，找不到用户 -10 自己已经不在当前棋桌
        -9 此走法会导致自己被将军 -11 红方长捉黑方  -12 黑方长捉红方

        //0 成功   1红方胜利  2黑方胜利  9将军]]
	local message = nil;
    if code == -9 then
		message = "走法会导致自己被将军,请重新走棋!" 
	elseif code == -11 or code == -12 then
		message = "走法长捉长将，请重新走棋！" 
	else
		message = "走法不合规则，请重新走棋！" 
	end
    if ChessToastManager.getInstance():isEmpty()  then
        ChessToastManager.getInstance():show(message);
    end
end
require("util/postion");
EndgateRoomController.aiMove = function(self,mv)

	print_string("EndingRoom.aiMove = " .. mv);

	local sqSrc = Postion.SRC(mv);
	local sqDst = Postion.DST(mv);

	print_string("sqSrc =  " .. sqSrc .. ",sqDst = " .. sqDst);
	local src_row = Postion.RANK_Y(sqSrc) - Postion.RANK_TOP;
	local src_col = Postion.FILE_X(sqSrc) - Postion.FILE_LEFT;

	print_string("src_row =  " .. src_row .. ",src_col = " .. src_col);

	local dst_row = Postion.RANK_Y(sqDst) - Postion.RANK_TOP;
	local dst_col = Postion.FILE_X(sqDst) - Postion.FILE_LEFT;

	print_string("dst_row =  " .. dst_row .. ",dst_col = " .. dst_col);

	local move = {};
	move.src = src_col*10+src_row;
	move.dst = dst_col*10+dst_row;
	self:setMyTurn(true); --self.m_my_turn = true;  --
	self:cbMove(move,true);
end

EndgateRoomController.engine_gui = function(self,flag,data)
	self.m_board:onReceive(data.Engine2Gui:get_value());
end

EndgateRoomController.chessMove = function(self,data)
    print_string("EndgateRoomController.chessMove");
	local src = 90 - data.moveFrom;
	local dst = 90 - data.moveTo
	local src_row = math.floor(src/9);
	local src_col = src%9;

	local dst_row = math.floor(dst/9);
	local dst_col = dst%9;

	local move = {};
	move.src = src_col*10+src_row;
	move.dst = dst_col*10+dst_row;


	self:setMyTurn(false); --self.m_my_turn = false; --我下完棋之后轮到电脑走棋
	self:updateView(EndgateRoomScene.s_cmds.dismissTipsNote);
	self:cbMove(move);


	if self:isGameOver() then
		print_string("EndgateRoomController.chessMove gamve over ");
		return;
	end

	if ChessBook_IsOffBook(self.m_cb) then --是否脱谱
		self.m_board:response(ENGINE_MOVE);
	else
		--让电脑暂停一下再下棋
		self:deleteThinkAnim();
		self.m_aithink_anim = new(AnimInt,kAnimNormal,0,1,1500,-1); --
		self.m_aithink_anim:setDebugName("EndgateRoomController.chessMove.m_aithink_anim");
		self.m_aithink_anim:setEvent(self,self.nextStep);
	end
end

--删除Anim
EndgateRoomController.deleteThinkAnim = function(self)
	if self.m_aithink_anim then
		delete(self.m_aithink_anim);
		self.m_aithink_anim = nil;
	end
end

--下一步
EndgateRoomController.nextStep = function(self)
	-- local move = self.m_chess_book:getCurrentMove();
	local move = ChessBook_GetNextMove(self.m_cb);
	if not move then 
		print_string("EndingRoom.nextStep not move");
		return
	end

	self:makeMove(move);
	self:setMyTurn(true); --self.m_my_turn = true;

end

EndgateRoomController.makeMove = function(self,move)
	print_string("EndgateRoomController.makeMove");
	local code = self.m_board:endingMove(move);

	if code then
		self:cbMove(move,true);
	else
		local message = "走棋错误！！！";
        if ChessToastManager.getInstance():isEmpty()  then
            ChessToastManager.getInstance():show(message);
        end
	end
end


require("util/chessbook");
--在棋谱里面走一步棋
--move当前的走棋
--showTips 是否需要显示 提示或变招 
EndgateRoomController.cbMove = function(self,move,showTips)

	self:updateView(EndgateRoomScene.s_cmds.dismissTips);
	
	print_string("EndgateRoomController.cbMove src = " .. move.src .. ",dst = " .. move.dst);

	ChessBook_MakeMove(self.m_cb,move.src,move.dst);
	if ChessBook_IsOffBook(self.m_cb) then --是否脱谱
        print_string("脱谱");
	else
		if showTips then
			self:showTips();
		end
	end

end

--提醒用户是否有 注释或变招
EndgateRoomController.showTips = function(self)


	self:updateView(EndgateRoomScene.s_cmds.dismissTipsNote);

	if ChessBook_IsOffBook(self.m_cb) then
		print_string("EndingRoom.showTips but off book");
		return
	end

	local move = ChessBook_GetNextMove(self.m_cb);
	if not move then 
		print_string("EndingRoom.showTips not next move");
		return
	elseif move.sub then
		self:updateView(EndgateRoomScene.s_cmds.show_submove_text);
	elseif move.comment then
		self:updateView(EndgateRoomScene.s_cmds.show_tips_text);
	end
end


--设置是否是我走
EndgateRoomController.setMyTurn = function(self,is_my_trun)
	self.m_my_turn = is_my_trun or false;
	self:updateView(EndgateRoomScene.s_cmds.setMyTurn,self.m_my_turn,self:isGameOver());
end

--是否轮到我走
EndgateRoomController.isMyTurn = function(self)
	return self.m_my_turn;
end

EndgateRoomController.isGameOver = function(self)
	return self.m_game_over or false;
end


EndgateRoomController.tip_action = function(self)
    if self:isLogined() and not self.user_prop_func then
        self.m_load_socket_dialog:show();
        self:startTimeout();
        self.user_prop_func = EndgateRoomController.use_tip;
        self:sendSocketMsg(PROP_CMD_QUERY_USERDATA);
    end
end

EndgateRoomController.startTimeout = function(self)
	self:stopTimeout();
	self.m_timeoutAnim = new(AnimInt,kAnimNormal,0,1,10000,-1);
	self.m_timeoutAnim:setDebugName("LoadingDialog.startTimeout.m_timeoutAnim");
	
	self.m_timeoutAnim:setEvent(self,self.timeoutRun);
end

EndgateRoomController.timeoutRun = function(self)
    self.user_prop_func = nil;
    self.m_load_socket_dialog:dismiss();
    ChessToastManager.getInstance():showSingle("请求超时!");
end

EndgateRoomController.stopTimeout = function(self)
	if self.m_timeoutAnim then
		delete(self.m_timeoutAnim);
		self.m_timeoutAnim = nil;
	end
end

EndgateRoomController.use_tip = function(self)
	local tips_num = UserInfo.getInstance():getTipsNum();
	if tips_num < 1 then
		self.m_payInterface = PayUtil.getPayInstance(PayUtil.s_payType.Exchange);
		self.m_pay_dialog = self.m_payInterface:buy(nil,ENDING_ROOM_TIPS);	
        if ChessToastManager.getInstance():isEmpty()  then
            ChessToastManager.getInstance():show("提示不足！");
        end
		return false;
	end
    local move = ChessBook_GetNextMove(self.m_cb);
	if not move or ChessBook_IsOffBook(self.m_cb) then 
		print_string("EndgateRoomScene.showTips not next move");
		local message = "棋局已脱离解法，无法提示";
        if ChessToastManager.getInstance():isEmpty()  then
            ChessToastManager.getInstance():show(message);
        end
--		ShowMessageAnim.play(self.m_root_view,message);
		return false;
	else
        --先使用道具
        local tips_num = UserInfo.getInstance():getTipsNum();
        local move = ChessBook_GetNextMove(self.m_cb);
        if move.sub then
		    self:updateView(EndgateRoomScene.s_cmds.setSubNum,#move.sub + 1);
	    elseif move.comment then
		    local message = move.comment;
		    self:updateView(EndgateRoomScene.s_cmds.showTipsNote,message)
		    self.m_board:book_tips(move);
	    else
		    self.m_board:book_tips(move);
	    end
        if tips_num > 0 then
	        tips_num = tips_num - 1;
	        UserInfo.getInstance():setTipsNum(tips_num);
        end

        self.m_used_tip_num = (self.m_used_tip_num or 0) + 1;
        self:updateView(EndgateRoomScene.s_cmds.use_tip);
        
        local sendData = {};
        local item = {};
        item.op = 2; -- =1相加，=2相减，=3覆盖
        item.op_id = 12; -- 11 => '单机中使用道具', 12 => '残局中使用道具',
        item.num = 1;--修改数量
        item.prop_id = kTipsNum; --道具id
        table.insert(sendData,item);
        self:sendSocketMsg(PROP_CMD_UPDATE_USERDATA,sendData);
    end
end

EndgateRoomController.revive = function(self)
    if not ChessBook_IsOffBook(self.m_cb) then 
		print_string("EndgateRoomScene.revive not off book");
		local message = "未脱谱，无需起死回生";
        if ChessToastManager.getInstance():isEmpty()  then
            ChessToastManager.getInstance():show(message);
        end
		return
	end

    local revive_num = UserInfo.getInstance():getReviveNum();
	if revive_num < 1 then
		self.m_payInterface = PayUtil.getPayInstance(PayUtil.s_payType.Exchange);
		self.m_pay_dialog = self.m_payInterface:buy(nil,ENDING_ROOM_SAVELIFE);	
        if ChessToastManager.getInstance():isEmpty()  then
            ChessToastManager.getInstance():show("起死回生不足！");
        end
		return;
	end

    if self:isLogined() and not self.user_prop_func then
        self.m_load_socket_dialog:show();
        self:startTimeout();
        self.user_prop_func = EndgateRoomController.use_revive;
        self:sendSocketMsg(PROP_CMD_QUERY_USERDATA);
    end
end

EndgateRoomController.use_revive = function(self)
    local sendData = {};
    local item = {};
    item.op = 2; -- =1相加，=2相减，=3覆盖
    item.op_id = 12; -- 11 => '单机中使用道具', 12 => '残局中使用道具',
    item.num = 1;--修改数量
    item.prop_id = kReviveNum; --道具id
    table.insert(sendData,item);
    self:sendSocketMsg(PROP_CMD_UPDATE_USERDATA,sendData);

    --先使用
    local revive_num = UserInfo.getInstance():getReviveNum();
    self:setGameOver2(false);
	--数量够，则数量减一
	revive_num = revive_num - 1;
	UserInfo.getInstance():setReviveNum(revive_num);

	while ChessBook_IsOffBook(self.m_cb) do
		if not self:preStep() then
			print_string("EndgateRoomScene.revive but not preStep");
			break;
		end
	end
    self.m_used_revive_num = (self.m_used_revive_num or 0) + 1;
	self:setMyTurn(true);
    self:updateView(EndgateRoomScene.s_cmds.updateView);
    self:updateView(EndgateRoomScene.s_cmds.use_revive);
end

--上一步 .. 悔棋
EndgateRoomController.preStep = function(self)

	if ChessBook_UndoMove(self.m_cb) and ChessBook_UndoMove(self.m_cb) then
		self.m_board:endingUndoMove();
	else
		local message = "无棋可悔啦！";
        if ChessToastManager.getInstance():isEmpty()  then
            ChessToastManager.getInstance():show(message);
        end
		return false;
	end

    self:updateView(EndgateRoomScene.s_cmds.preStep);
	self:showTips();
	return true;
end

EndgateRoomController.subMove1 = function(self)
    local move = ChessBook_GetNextMove(self.m_cb);
    return move;
end

EndgateRoomController.subMove2 = function(self)
    local move = ChessBook_GetNextMove(self.m_cb);
    if not move or not move.sub then
		print_string("EndgateRoomController.subMove2 but not move or sub");
		return ;
	end
	local tag = move.sub[1];
	local branch = ChessBook_FindBranch(self.m_cb, tag);
	move = branch.movelist;
    return move;
end

EndgateRoomController.subMove3 = function(self)
    local move = ChessBook_GetNextMove(self.m_cb);
    
	if not move or not move.sub then
		print_string("EndgateRoomController.subMove1 but not move or sub");
		return
	end
	local tag = move.sub[2];
	local branch = ChessBook_FindBranch(self.m_cb, tag);
	move = branch.movelist;

    return move;
end

EndgateRoomController.undoMove = function(self)
    if not self:isMyTurn() then
		print_string("EndgateRoomScene.preStep but not your turn");
		return false;
	end


	local undo_num = UserInfo.getInstance():getUndoNum();
	if undo_num < 1 then
		 local message = "你的悔棋次数不足请购买！！！";
		-- ShowMessageAnim.play(self.m_root_view,message);
		self.m_payInterface = PayUtil.getPayInstance(PayUtil.s_payType.Exchange);
		self.m_pay_dialog = self.m_payInterface:buy(nil,ENDING_ROOM_UNDO);
        if ChessToastManager.getInstance():isEmpty()  then
            ChessToastManager.getInstance():show(message);
        end
		return false;
	end

    if ChessBook_CanUndoMove(self.m_cb) then
        if self:isLogined() and not self.user_prop_func then
            self.m_load_socket_dialog:show();
            self:startTimeout();
            self.user_prop_func = EndgateRoomController.use_undoMove;
            self:sendSocketMsg(PROP_CMD_QUERY_USERDATA);
        end
	else
		local message = "无棋可悔啦！";
        if ChessToastManager.getInstance():isEmpty()  then
            ChessToastManager.getInstance():show(message);
        end
		return false;
	end
    return false;
end

EndgateRoomController.use_undoMove = function(self)
	local sendData = {};
    local item = {};
    item.op = 2; -- =1相加，=2相减，=3覆盖
    item.op_id = 12; -- 11 => '单机中使用道具', 12 => '残局中使用道具',
    item.num = 1;--修改数量
    item.prop_id = kUndoNum; --道具id
    table.insert(sendData,item);
    self:sendSocketMsg(PROP_CMD_UPDATE_USERDATA,sendData);
	local undo_num = UserInfo.getInstance():getUndoNum();
    --先使用
    --成功悔棋次数减一
	if self:preStep() then
		undo_num = undo_num - 1;
		UserInfo.getInstance():setUndoNum(undo_num);
		self:setMyTurn(true);
        self.m_used_undoMove_num = (self.m_used_undoMove_num or 0) + 1;
        self:updateView(EndgateRoomScene.s_cmds.use_undoMove);
	end
end

-------------------------------- http event ------------------------

--------------------------------- socket -----------------------

EndgateRoomController.onPropCmdUpdateUserData = function(self,info)
    if info.ret == 0 then
        local prop = json.decode(info.data_json);
        if not prop then return end;
        for i,v in pairs(prop) do
            UserInfo.saveProp(i,v);
        end
        self:updateUserInfoView();
    else
       --ChessToastManager.getInstance():showSingle("使用失败,请稍后再试!");
       self:sendSocketMsg(PROP_CMD_QUERY_USERDATA);
    end
end

EndgateRoomController.onPropCmdQueryUserData = function(self,info)
    self:stopTimeout();
    self.super.onPropCmdQueryUserData(self,info);
    self.m_load_socket_dialog:dismiss();
    if info.ret == 0 then
        if self.user_prop_func then
            self.user_prop_func(self);
            self.user_prop_func = nil;
        end
    end
end


EndgateRoomController.onUploadGateInfoCallBack = function(self, flag, message)
    if not flag then
        return;
    end;

	if not HttpModule.explainPHPFlag(message) then
		return;
	end    
    local progress = message.data.progress["1"]:get_value();
    local proportion = message.data.proportion:get_value();
    local leading_number = message.data.leading_number:get_value();
    self:updateView(EndgateRoomScene.s_cmds.update_account_rank,proportion,leading_number);


end;


EndgateRoomController.onGetRewardCallBack = function(self, flag, message)
    if not flag then
        if type(message) == "number" then
            if tonumber(message) == 2 then
                ChessToastManager.getInstance():showSingle("请求超时");
            elseif tonumber(message) == 3 then
                ChessToastManager.getInstance():showSingle("网络异常");
                self:updateView(EndgateRoomScene.s_cmds.show_reward);
            end;
            return; 
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
            return;
        end;        
    end;  
    local result = {[1] =  {},[2] =  {},[3] =  {}};
    for i = 1, 3 do 
        local item = message.data[i];
        if item.type:get_value() == "prop" then
            result[i].rtype = "prop";
            result[i].propid = item.prop_id:get_value();
            result[i].num = item.num:get_value();
            result[i].is_reward = item.is_reward:get_value();
        elseif item.type:get_value() == "coin" then
            result[i].rtype = "coin";
            result[i].num = item.num:get_value();
            result[i].is_reward = item.is_reward:get_value();        
        elseif item.type:get_value() == "soul" then
            result[i].rtype = "soul";
            result[i].num = item.num:get_value();
            result[i].is_reward = item.is_reward:get_value();  
        --elseif item.type:get_value() == "xxx" then --后续扩展
        else
            return;
        end;
    end;
    self:updateView(EndgateRoomScene.s_cmds.show_reward,result);

end;

-------------------------------- config ----------------------------

EndgateRoomController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.uploadGateInfo]     = EndgateRoomController.onUploadGateInfoCallBack;
    [HttpModule.s_cmds.getReward]          = EndgateRoomController.onGetRewardCallBack;
};

EndgateRoomController.s_httpRequestsCallBackFuncMap = CombineTables(EndgateRoomController.s_httpRequestsCallBackFuncMap,
	ChessController.s_httpRequestsCallBackFuncMap or {});

require(MODEL_PATH.."room/board");
--本地事件 包括lua dispatch call事件
EndgateRoomController.s_nativeEventFuncMap = {
    [Board.AIUNLEGALMOVE] = EndgateRoomController.aiUnlegalMove;
    [Board.AI_UNCHANGE_MOVE] = EndgateRoomController.aiUnchangeMove;
    [Board.UNLEGALMOVE] = EndgateRoomController.unlegalMove;
    [Board.AIMOVE] = EndgateRoomController.aiMove;
    [ENGINE_GUI] = EndgateRoomController.engine_gui;
    [kEndingUtilNewGetSubGateJsonStrByTidAndSort] = EndgateRoomController.onLoadEndingBoardByAndroid;
};

EndgateRoomController.s_nativeEventFuncMap = CombineTables(EndgateRoomController.s_nativeEventFuncMap,
	ChessController.s_nativeEventFuncMap or {});



EndgateRoomController.s_socketCmdFuncMap = {
	[PROP_CMD_UPDATE_USERDATA]  = EndgateRoomController.onPropCmdUpdateUserData;
    [PROP_CMD_QUERY_USERDATA]   = EndgateRoomController.onPropCmdQueryUserData;--查询道具
}

EndgateRoomController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	EndgateRoomController.s_socketCmdFuncMap or {});


------------------------------------- 命令响应函数配置 ------------------------
EndgateRoomController.s_cmdConfig = 
{
    [EndgateRoomController.s_cmds.onBack] = EndgateRoomController.onBack;
    [EndgateRoomController.s_cmds.loadEndingBoard] = EndgateRoomController.onLoadEndingBoard;
    [EndgateRoomController.s_cmds.restart] = EndgateRoomController.restart;
    [EndgateRoomController.s_cmds.loadNextGate] = EndgateRoomController.loadNextGate;
    [EndgateRoomController.s_cmds.shareInfo] = EndgateRoomController.shareInfo;
    [EndgateRoomController.s_cmds.onEventStat] = EndgateRoomController.onEventStat;
    [EndgateRoomController.s_cmds.tip_action] = EndgateRoomController.tip_action;
    [EndgateRoomController.s_cmds.revive] = EndgateRoomController.revive;
    [EndgateRoomController.s_cmds.subMove1] = EndgateRoomController.subMove1;
    [EndgateRoomController.s_cmds.subMove2] = EndgateRoomController.subMove2;
    [EndgateRoomController.s_cmds.subMove3] = EndgateRoomController.subMove3;
    [EndgateRoomController.s_cmds.undoMove] = EndgateRoomController.undoMove;
    [EndgateRoomController.s_cmds.shareUrl] = EndgateRoomController.shareUrl;
    [EndgateRoomController.s_cmds.sharePicture] = EndgateRoomController.sharePicture;

    
    
}

