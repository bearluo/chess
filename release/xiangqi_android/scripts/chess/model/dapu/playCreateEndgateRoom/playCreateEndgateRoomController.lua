require("config/path_config");

require(MODEL_PATH.."/room/roomController");

PlayCreateEndgateRoomController = class(RoomController);

PlayCreateEndgateRoomController.s_cmds = 
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
    start_action        = 14;
    buy_ending          = 15;
    report_ending       = 16;
    save_mychess        = 17;
    changeFlag          = 18;
};

PlayCreateEndgateRoomController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
    require("dialog/http_loading_dialog");
    self.m_load_socket_dialog = HttpLoadingDialogFactory.createLoadingDialog(HttpLoadingDialog.s_type.Simple);
    self.m_load_socket_dialog:setNeedBackEvent(false);
--    if "win32"==System.getPlatform() then
--        if not kEndgateData:getPlayCreateEndingData() then
--            local data =  '{"booth_id": "5","mid": "1138","booth_fen": "4k4/3ca4/9/2R6/6R2/9/9/4B4/9/4K4/ w","booth_title": "test12/23/15 15:36:10","movelist": "","add_time": "1450856170","collect_num": "0","pass_num": "46","play_num": "49","prize_pool": 4440,"is_pass": "0","expose_num": "2","icon_url": "","mnick": "1223 1","icon_type": 3,"is_vip": 0,"is_buy": 0}';
--            kEndgateData:setPlayCreateEndingData(json.decode(data));
--        end
--    end
    self.flag = Board.MODE_RED;
end


PlayCreateEndgateRoomController.resume = function(self)
	RoomController.resume(self);
	Log.i("PlayCreateEndgateRoomController.resume");
    self:start_action();
end

PlayCreateEndgateRoomController.pause = function(self)
	RoomController.pause(self);
	Log.i("PlayCreateEndgateRoomController.pause");
end

PlayCreateEndgateRoomController.dtor = function(self)
    delete(self.m_load_socket_dialog);
    delete(self.m_chiose_dialog);
    self:stopTimeout();
end
--------------------------- father func ----------------------
PlayCreateEndgateRoomController.updateUserInfoView = function(self)
    self:updateView(PlayCreateEndgateRoomScene.s_cmds.updateView);
end


-------------------------------- func ------------------------------

PlayCreateEndgateRoomController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end

PlayCreateEndgateRoomController.start_action = function(self)
	self:onLoadEndingBoard();
end

PlayCreateEndgateRoomController.buyEnding = function(self)
    local data = kEndgateData:getPlayCreateEndingData();
    if data then 
        local params = {};
        params.method = "WulinBooth.buyBooth";
        params.mid = UserInfo.getInstance():getUid();
        params.booth_id = data.booth_id;
        HttpModule.getInstance():execute(HttpModule.s_cmds.WulinBoothBuyBooth,params,"购买中...");
    end
end

PlayCreateEndgateRoomController.reportEnding = function(self)
    local data = kEndgateData:getPlayCreateEndingData();
    if data then 
        local params = {};
        params.method = "WulinBooth.expose";
        params.mid = UserInfo.getInstance():getUid();
        params.booth_id = data.booth_id;
        HttpModule.getInstance():execute(HttpModule.s_cmds.WulinBoothExpose,params);
    end
end

-- isSelf,是否个人收藏
PlayCreateEndgateRoomController.onSaveMychess = function(self,isSelf, chessData)
    local post_data = {};
    post_data.mid = UserInfo.getInstance():getUid();
    post_data.down_user = chessData.down_user;
    post_data.red_mid = chessData.red_mid;
    post_data.black_mid = chessData.black_mid;
    post_data.red_mnick = chessData.red_mnick;
    post_data.black_mnick = chessData.black_mnick;
    post_data.win_flag = chessData.win_flag;
    post_data.end_type = chessData.end_type;
    post_data.manual_type = chessData.manual_type;
    post_data.start_fen = chessData.start_fen;
    post_data.move_list = chessData.move_list;
    post_data.end_fen = chessData.end_fen;
    post_data.collect_type = (isSelf and 2) or 1; -- 收藏类型, 1公共收藏，2人个收藏 
    self:sendHttpMsg(HttpModule.s_cmds.saveMychess,post_data,"收藏中...");
end;

PlayCreateEndgateRoomController.restart = function(self)
    if self.m_game_over == false then
        self:upPhpInfo(2);
    end
    self:onLoadEndingBoard();
end

PlayCreateEndgateRoomController.changeFlag = function(self)
    self.flag = 1-self.flag;
    self:onLoadEndingBoard()
end

--拉取出棋盘
PlayCreateEndgateRoomController.onLoadEndingBoard = function(self)
    kEndgateData:setStartTime(os.time());
    Log.i("aaa onLoadEndingBoard");
    self.m_used_undoMove_num = 0;
    self.m_used_tip_num = 0;
    self.m_used_revive_num = 0;
    self.m_step = 0;
    self:setGameOver2(false);
    
    local data = kEndgateData:getPlayCreateEndingData();
    if data and data.is_buy == 1 then
        self:updateView(PlayCreateEndgateRoomScene.s_cmds.set_start_btn_visible,false);
    --    self.m_boradCode = CHESS_MOVE_OVER_RED_WIN;
    --    self:showResultDialog();
    else
        self:updateView(PlayCreateEndgateRoomScene.s_cmds.set_start_btn_visible,true);
    end
    self:onLoadEndingBoardByData(data);
--    self:showTips();
end

PlayCreateEndgateRoomController.showResultDialog = function(self)
	if self.m_boradCode == self.flag + 1 then
        self:upPhpInfo(1);
        self:uploadMoveList();
	else
        self:upPhpInfo(2);
        self:updateView(PlayCreateEndgateRoomScene.s_cmds.show_result_dialog,false);
        self:updateView(PlayCreateEndgateRoomScene.s_cmds.showEndingResultDialog,self.m_boradCode);
	end
    self:updateView(PlayCreateEndgateRoomScene.s_cmds.save_chess,self.m_boradCode);
    self:setGameOver2(true);
end

PlayCreateEndgateRoomController.uploadMoveList = function(self)
    local params = {};
    local data = kEndgateData:getPlayCreateEndingData() or {};
    local moves = self.m_view.m_board:to_mvList();
--    local move = {};
--    move.movelist = {};
--    local first_move = {};
--    first_move.src = 0;
--    first_move.dst = 0;
--    for i,mv in ipairs(moves) do
--        move.movelist[i] = Board.Mv2endMove(mv);
--    end
--    table.insert(move.movelist,1,first_move);
    params.method = "WulinBooth.uploadMoveList";
    params.mid = UserInfo.getInstance():getUid();
    params.booth_id = data.booth_id;
    params.movelist = table.concat(moves,',');
    params.user_side = self.flag + 1;
    params.end_fen = self.m_board.pos:toFen();
    HttpModule.getInstance():execute(HttpModule.s_cmds.WulinBoothUploadMoveList,params,"上传数据中...");
end


-- 1：胜，2：负，3和
PlayCreateEndgateRoomController.upPhpInfo = function(self,win_flag)
    local data = kEndgateData:getPlayCreateEndingData() or {};
    local post_data = {};
    post_data.method = "WulinBooth.uploadLog";
    post_data.mid = UserInfo.getInstance():getUid();
    post_data.booth_id = data.booth_id;
    post_data.start_time = kEndgateData:getStartTime();
    post_data.end_time = os.time();
    post_data.move_step = self.m_step or 0;
    post_data.win_flag = win_flag;
    post_data.user_side = self.flag + 1;
    HttpModule.getInstance():execute(HttpModule.s_cmds.WulinBoothUploadLog,post_data);
end


PlayCreateEndgateRoomController.setGameOver2 = function(self,flag)
	print_string("PlayCreateEndgateRoomController.setGameOver");
	self.m_game_over = flag;
    self:updateView(PlayCreateEndgateRoomScene.s_cmds.setGameOver,flag,self.m_boradCode);
end


PlayCreateEndgateRoomController.loadNextGate = function(self)
--    self:onEventStat(ENDGIN_ROOM_MODEL_NEXTGATE_BTN);

--	local gate_sort = kEndgateData:getGateSort();
--	gate_sort = gate_sort +1;
--    Log.i("gate_sort:"..gate_sort);
--	local gate = kEndgateData:getGate();
--	local uid = UserInfo.getInstance():getUid();
--	local curNum = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_GATE_NUM..uid,1);

--	kEndgateData:setGateSort(gate_sort);
----    StateMachine.getInstance():popState(StateMachine.STYPE_WAIT);  -- 播放过关动画
--	self:onLoadEndingBoard();
end

PlayCreateEndgateRoomController.shareInfo = function(self)
    self:onEventStat(ENDGIN_ROOM_MODEL_SHARE_BTN);
--	share_img_msg("egame_share");
--    self:shareUrl();
end

PlayCreateEndgateRoomController.shareUrl = function(self)
--	local id = kEndgateData:getBoardTableId();
----    local url = "http://h5.oa.com/chess/?type=1&id="..id;--测试服
--    local url = "http://cnchess.17c.cn/h5/?type=1&id="..id;--正式服
--    local data = {};
--    data.booth_id = id;
--    HttpModule.getInstance():execute(HttpModule.s_cmds.boothShare,data);
--    data.url = url;
--    data.title = kEndgateData:getBoardTableSubTitle();
--    share_text_msg(json.encode(data));
    local params = {};
    local data = kEndgateData:getPlayCreateEndingData() or {};
    params.user_id = 888;
    local title = data.booth_title or ""
    if ToolKit.utfstrlen(title) > 7 then
        title = ToolKit.GetShortName(title,7);
    end
    if ToolKit.utfstrlen(title) < 3 then
        title = title .. "   "
    end
    params.booth_title = title;
    params.booth_fen = string.sub(data.booth_fen,0,-4);
    HttpModule.getInstance():execute(HttpModule.s_cmds.WxBoothCreateBooth,params,"加载中...");
end

PlayCreateEndgateRoomController.onEventStat = function(self,event_id)
    local data = kEndgateData:getPlayCreateEndingData();
	local event_info = event_id .. ","  ..  "booth_id_" .. data.booth_id;
	on_event_stat(event_info); --事件统计
end

PlayCreateEndgateRoomController.aiTurn = function(self)
	self.m_board:response(ENGINE_MOVE);
end

PlayCreateEndgateRoomController.onLoadEndingBoardByData = function(self,data)
    if data then
        UserInfo.getInstance():setFlag(self.flag + 1); -- model 0 1 红黑  flag  1 2 红黑
        local board_table = data;
        local move = json.decode(board_table.movelist);
        local cb = self.buildChessbookFromTable(move);

        local fen = board_table.booth_fen;
--        self.m_board:ending_game(fen);
	    Board.resetFenPiece();
        local chessMap = self.m_board:fen2chessMap(fen);
        self.m_board:newgame(self.flag,fen,chessMap)
        self.m_board:setEngineBegin(fen);
        self.m_cb = cb;
        GameCacheData.getInstance():saveString(GameCacheData.DAPU_LAST_BORAD_FEN,fen);
        GameCacheData.getInstance():saveString(GameCacheData.DAPU_LAST_CHESS_STR,table.concat(chessMap,MV_SPLIT));

        self:setMyTurn(self.flag == Board.MODE_RED);
        if  not self:isMyTurn() then
	        self:aiTurn();
        end
--        if move and move.movelist then
--            self:updateView(PlayCreateEndgateRoomScene.s_cmds.startGame,move.movelist);
--        else
            self:updateView(PlayCreateEndgateRoomScene.s_cmds.startGame);
--        end
    else
        ChessToastManager.getInstance():showSingle("数据错误");
    end
end

-- 从json字符串创建一个chessbook
PlayCreateEndgateRoomController.buildChessbookFromTable = function(moveDict)
    print("PlayCreateEndgateRoomController.buildChessbookFromJsonString Start parsing")
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
        local move = PlayCreateEndgateRoomController.extractMoveFromDict(v)
        ChessBook_PushBackMaster(cb, move)
    end

    if subMoveList then
	    for i,v in pairs(subMoveList) do
	        for _,moves in pairs(v) do
	            subMove = PlayCreateEndgateRoomController.extractMoveFromDict(moves)
	            ChessBook_PushBackBranch(cb, tonumber(i), subMove)
	        end
	    end
    else
        print("[buildChessbookFromJsonString]Error: Can't find token 'submovelist'")
        --return nil
    end

    print("PlayCreateEndgateRoomController.buildChessbookFromJsonString Parse End")

    return cb
end

-- 从一个table中解析着法节点
PlayCreateEndgateRoomController.extractMoveFromDict = function(dict)
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
PlayCreateEndgateRoomController.aiUnlegalMove = function(self,flag,data)
    self:updateView(PlayCreateEndgateRoomScene.s_cmds.console_gameover,UserInfo.getInstance():getFlag(),ENDTYPE_UNLEGAL);
end

PlayCreateEndgateRoomController.aiUnchangeMove = function(self,flag,data)
    -- 电脑认输
    self:updateView(PlayCreateEndgateRoomScene.s_cmds.console_gameover,UserInfo.getInstance():getFlag(),ENDTYPE_SURRENDER);--ENDTYPE_UNCHANGE);
end

--走棋不合法
PlayCreateEndgateRoomController.unlegalMove = function(self,code)
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
PlayCreateEndgateRoomController.aiMove = function(self,mv)

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

PlayCreateEndgateRoomController.engine_gui = function(self,flag,data)
	self.m_board:onReceive(data.Engine2Gui:get_value());
end

PlayCreateEndgateRoomController.onShareSuccessCallBack = function(self,flag,data)
    local data = kEndgateData:getPlayCreateEndingData() or {};
    local params = {};
    params.booth_id = data.booth_id;
    HttpModule.getInstance():execute(HttpModule.s_cmds.WulinBoothReportShare,params);
end

PlayCreateEndgateRoomController.chessMove = function(self,data)
    print_string("PlayCreateEndgateRoomController.chessMove");
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
    self.m_step = self.m_step + 1;
    self:updateView(PlayCreateEndgateRoomScene.s_cmds.update_step_text,self.m_step);
	self:updateView(PlayCreateEndgateRoomScene.s_cmds.dismissTipsNote);
	self:cbMove(move);


	if self:isGameOver() then
		print_string("PlayCreateEndgateRoomController.chessMove gamve over ");
		return;
	end

	if self.m_cb == nil or ChessBook_IsOffBook(self.m_cb) then --是否脱谱
		self.m_board:response(ENGINE_MOVE);
	else
		--让电脑暂停一下再下棋
		self:deleteThinkAnim();
		self.m_aithink_anim = new(AnimInt,kAnimNormal,0,1,1500,-1); --
		self.m_aithink_anim:setDebugName("PlayCreateEndgateRoomController.chessMove.m_aithink_anim");
		self.m_aithink_anim:setEvent(self,self.nextStep);
	end
end

--删除Anim
PlayCreateEndgateRoomController.deleteThinkAnim = function(self)
	if self.m_aithink_anim then
		delete(self.m_aithink_anim);
		self.m_aithink_anim = nil;
	end
end

--下一步
PlayCreateEndgateRoomController.nextStep = function(self)
	-- local move = self.m_chess_book:getCurrentMove();
	local move = ChessBook_GetNextMove(self.m_cb);
	if not move then 
		print_string("EndingRoom.nextStep not move");
		return
	end

	self:makeMove(move);
	self:setMyTurn(true); --self.m_my_turn = true;

end

PlayCreateEndgateRoomController.makeMove = function(self,move)
	print_string("PlayCreateEndgateRoomController.makeMove");
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
PlayCreateEndgateRoomController.cbMove = function(self,move,showTips)

	self:updateView(PlayCreateEndgateRoomScene.s_cmds.dismissTips);
	
	print_string("PlayCreateEndgateRoomController.cbMove src = " .. move.src .. ",dst = " .. move.dst);

	ChessBook_MakeMove(self.m_cb,move.src,move.dst);
	if self.m_cb == nil or ChessBook_IsOffBook(self.m_cb) then --是否脱谱
        print_string("脱谱");
	else
		if showTips then
--			self:showTips();
		end
	end

end

--提醒用户是否有 注释或变招
PlayCreateEndgateRoomController.showTips = function(self)


	self:updateView(PlayCreateEndgateRoomScene.s_cmds.dismissTipsNote);

	if self.m_cb == nil or ChessBook_IsOffBook(self.m_cb) then
		print_string("EndingRoom.showTips but off book");
		return
	end

	local move = ChessBook_GetNextMove(self.m_cb);
	if not move then 
		print_string("EndingRoom.showTips not next move");
		return
	elseif move.sub then
		self:updateView(PlayCreateEndgateRoomScene.s_cmds.show_submove_text);
	elseif move.comment then
		self:updateView(PlayCreateEndgateRoomScene.s_cmds.show_tips_text);
	end
end


--设置是否是我走
PlayCreateEndgateRoomController.setMyTurn = function(self,is_my_trun)
	self.m_my_turn = is_my_trun or false;
	self:updateView(PlayCreateEndgateRoomScene.s_cmds.setMyTurn,self.m_my_turn,self:isGameOver());
end

--是否轮到我走
PlayCreateEndgateRoomController.isMyTurn = function(self)
	return self.m_my_turn;
end

PlayCreateEndgateRoomController.isGameOver = function(self)
	return self.m_game_over or false;
end


PlayCreateEndgateRoomController.tip_action = function(self)
    if self:isLogined() and not self.user_prop_func then
        self.m_load_socket_dialog:show();
        self:startTimeout();
        self.user_prop_func = PlayCreateEndgateRoomController.use_tip;
        self:sendSocketMsg(PROP_CMD_QUERY_USERDATA);
    end
end

PlayCreateEndgateRoomController.startTimeout = function(self)
	self:stopTimeout();
	self.m_timeoutAnim = new(AnimInt,kAnimNormal,0,1,10000,-1);
	self.m_timeoutAnim:setDebugName("LoadingDialog.startTimeout.m_timeoutAnim");
	
	self.m_timeoutAnim:setEvent(self,self.timeoutRun);
end

PlayCreateEndgateRoomController.timeoutRun = function(self)
    self.user_prop_func = nil;
    self.m_load_socket_dialog:dismiss();
    ChessToastManager.getInstance():showSingle("请求超时!");
end

PlayCreateEndgateRoomController.stopTimeout = function(self)
	if self.m_timeoutAnim then
		delete(self.m_timeoutAnim);
		self.m_timeoutAnim = nil;
	end
end

PlayCreateEndgateRoomController.use_tip = function(self)
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
	if not move or self.m_cb == nil or ChessBook_IsOffBook(self.m_cb) then 
		print_string("PlayCreateEndgateRoomScene.showTips not next move");
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
		    self:updateView(PlayCreateEndgateRoomScene.s_cmds.setSubNum,#move.sub + 1);
	    elseif move.comment then
		    local message = move.comment;
		    self:updateView(PlayCreateEndgateRoomScene.s_cmds.showTipsNote,message)
		    self.m_board:book_tips(move);
	    else
		    self.m_board:book_tips(move);
	    end
        if tips_num > 0 then
	        tips_num = tips_num - 1;
	        UserInfo.getInstance():setTipsNum(tips_num);
        end

        self.m_used_tip_num = (self.m_used_tip_num or 0) + 1;
        self:updateView(PlayCreateEndgateRoomScene.s_cmds.use_tip);
        
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

PlayCreateEndgateRoomController.revive = function(self)
    if not ChessBook_IsOffBook(self.m_cb) then 
		print_string("PlayCreateEndgateRoomScene.revive not off book");
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
        self.user_prop_func = PlayCreateEndgateRoomController.use_revive;
        self:sendSocketMsg(PROP_CMD_QUERY_USERDATA);
    end
end

PlayCreateEndgateRoomController.use_revive = function(self)
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
			print_string("PlayCreateEndgateRoomScene.revive but not preStep");
			break;
		end
	end
    self.m_used_revive_num = (self.m_used_revive_num or 0) + 1;
	self:setMyTurn(true);
    self:updateView(PlayCreateEndgateRoomScene.s_cmds.updateView);
    self:updateView(PlayCreateEndgateRoomScene.s_cmds.use_revive);
end

--上一步 .. 悔棋
PlayCreateEndgateRoomController.preStep = function(self)

	if ChessBook_UndoMove(self.m_cb) and ChessBook_UndoMove(self.m_cb) then
		self.m_board:endingUndoMove();
	else
		local message = "无棋可悔啦！";
        if ChessToastManager.getInstance():isEmpty()  then
            ChessToastManager.getInstance():show(message);
        end
		return false;
	end

    self:updateView(PlayCreateEndgateRoomScene.s_cmds.preStep);
--	self:showTips();
	return true;
end

PlayCreateEndgateRoomController.subMove1 = function(self)
    local move = ChessBook_GetNextMove(self.m_cb);
    return move;
end

PlayCreateEndgateRoomController.subMove2 = function(self)
    local move = ChessBook_GetNextMove(self.m_cb);
    if not move or not move.sub then
		print_string("PlayCreateEndgateRoomController.subMove2 but not move or sub");
		return ;
	end
	local tag = move.sub[1];
	local branch = ChessBook_FindBranch(self.m_cb, tag);
	move = branch.movelist;
    return move;
end

PlayCreateEndgateRoomController.subMove3 = function(self)
    local move = ChessBook_GetNextMove(self.m_cb);
    
	if not move or not move.sub then
		print_string("PlayCreateEndgateRoomController.subMove1 but not move or sub");
		return
	end
	local tag = move.sub[2];
	local branch = ChessBook_FindBranch(self.m_cb, tag);
	move = branch.movelist;

    return move;
end

PlayCreateEndgateRoomController.undoMove = function(self)
    if not self:isMyTurn() then
		print_string("PlayCreateEndgateRoomScene.preStep but not your turn");
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
            self.user_prop_func = PlayCreateEndgateRoomController.use_undoMove;
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

PlayCreateEndgateRoomController.use_undoMove = function(self)
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
        self:updateView(PlayCreateEndgateRoomScene.s_cmds.use_undoMove);
	end
end

-------------------------------- http event ------------------------

--------------------------------- socket -----------------------

PlayCreateEndgateRoomController.onPropCmdUpdateUserData = function(self,info)
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

PlayCreateEndgateRoomController.onPropCmdQueryUserData = function(self,info)
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


PlayCreateEndgateRoomController.onUploadGateInfoCallBack = function(self, flag, message)
    if not flag then
        return;
    end;

	if not HttpModule.explainPHPFlag(message) then
		return;
	end    
    local progress = message.data.progress["1"]:get_value();
    local proportion = message.data.proportion:get_value();
    local leading_number = message.data.leading_number:get_value();
    self:updateView(PlayCreateEndgateRoomScene.s_cmds.update_account_rank,proportion,leading_number);
end


PlayCreateEndgateRoomController.onGetRewardCallBack = function(self, flag, message)
    if not flag then
        return;
    end;

	if not HttpModule.explainPHPFlag(message) then
		return;
	end    
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
    self:updateView(PlayCreateEndgateRoomScene.s_cmds.show_reward,result);

end;

PlayCreateEndgateRoomController.onWulinBoothBuyBoothCallBack = function(self,success, message)
    if not success then 
        if type(message) == 'table' and message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value() or "购买失败");
        else
            ChessToastManager.getInstance():showSingle("购买失败");
        end
        return;
    end
    local data = kEndgateData:getPlayCreateEndingData();
    data.is_buy = 1;
    kEndgateData:setPlayCreateEndingData(data);
    self:updateView(PlayCreateEndgateRoomScene.s_cmds.set_start_btn_visible,false);
    self:start_action();
end

PlayCreateEndgateRoomController.onWulinBoothUploadMoveListCallBack = function(self,success,message)
    if not success then 
        delete(self.m_chiose_dialog);
        require(DIALOG_PATH.."chioce_dialog");
        self.m_chiose_dialog = new(ChioceDialog);
        self.m_chiose_dialog:setMode(ChioceDialog.MODE_COMMON,"重试","取消");
        self.m_chiose_dialog:setNegativeListener(nil,nil);
        self.m_chiose_dialog:setPositiveListener(self,self.uploadMoveList);
        if type(message) == 'table' and message.error then
            self.m_chiose_dialog:setMessage(message.error:get_value() or "上传数据失败");
        else
            self.m_chiose_dialog:setMessage("上传数据失败");
        end
        self.m_chiose_dialog:show();
        return
    end
    local prize_pool = tonumber(message.data.prize_pool:get_value()) or 0;
    local pass_num = tonumber(message.data.pass_num:get_value()) or 0;
    local moves = self.m_view.m_board:to_mvList();
    if moves and type(moves) == "table" and #moves > 1 then
        self:updateView(PlayCreateEndgateRoomScene.s_cmds.update_min_step_text,#moves - 1);
    end
    self:updateView(PlayCreateEndgateRoomScene.s_cmds.show_result_dialog,true,prize_pool,pass_num);
end

PlayCreateEndgateRoomController.onWxBoothCreateBoothCallBack = function(self,success,message)
    if not success then 
        if type(message) == 'table' and message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value() or "加载失败");
        else
            ChessToastManager.getInstance():showSingle("加载失败");
        end
        return;
    end
    if not message.data then return end;
    local data = {};
    data.url = message.data.share_url:get_value();
    data.title = message.data.booth_title:get_value();
    data.flag = UserInfo.getInstance():getOpenWeixinShare();
    share_text_msg(json.encode(data));
end

-- 收藏到我的收藏回调
PlayCreateEndgateRoomController.onSaveChessCallBack = function(self, flag, message)
    if not flag then
        if type(message) == "number" then
            return; 
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value() or "收藏失败",2000);
            return;
        end
    end
    ChessToastManager.getInstance():showSingle("收藏成功");
    local data = kEndgateData:getPlayCreateEndingData() or {};
    local params = {};
    params.mid = UserInfo.getInstance():getUid();
    params.booth_id = data.booth_id;
    self:sendHttpMsg(HttpModule.s_cmds.WulinBoothReportCollect,params);
end

PlayCreateEndgateRoomController.onWulinBoothExpose = function(self, flag, message)
    if not flag then
        if type(message) == "number" then
            return; 
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value() or "操作失败",2000);
            return;
        end
    end
    ChessToastManager.getInstance():showSingle("举报成功");
end

-------------------------------- config ----------------------------

PlayCreateEndgateRoomController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.uploadGateInfo]     = PlayCreateEndgateRoomController.onUploadGateInfoCallBack;
    [HttpModule.s_cmds.getReward]          = PlayCreateEndgateRoomController.onGetRewardCallBack;
    [HttpModule.s_cmds.WulinBoothBuyBooth] = PlayCreateEndgateRoomController.onWulinBoothBuyBoothCallBack;
    [HttpModule.s_cmds.WulinBoothUploadMoveList]    = PlayCreateEndgateRoomController.onWulinBoothUploadMoveListCallBack;
    [HttpModule.s_cmds.WxBoothCreateBooth]          = PlayCreateEndgateRoomController.onWxBoothCreateBoothCallBack;
    [HttpModule.s_cmds.saveMychess]                 = PlayCreateEndgateRoomController.onSaveChessCallBack;
    [HttpModule.s_cmds.WulinBoothExpose]            = PlayCreateEndgateRoomController.onWulinBoothExpose;    
};

PlayCreateEndgateRoomController.s_httpRequestsCallBackFuncMap = CombineTables(PlayCreateEndgateRoomController.s_httpRequestsCallBackFuncMap,
	ChessController.s_httpRequestsCallBackFuncMap or {});

require(MODEL_PATH.."room/board");
--本地事件 包括lua dispatch call事件
PlayCreateEndgateRoomController.s_nativeEventFuncMap = {
    [Board.AIUNLEGALMOVE] = PlayCreateEndgateRoomController.aiUnlegalMove;
    [Board.AI_UNCHANGE_MOVE] = PlayCreateEndgateRoomController.aiUnchangeMove;
    [Board.UNLEGALMOVE] = PlayCreateEndgateRoomController.unlegalMove;
    [Board.AIMOVE] = PlayCreateEndgateRoomController.aiMove;
    [ENGINE_GUI] = PlayCreateEndgateRoomController.engine_gui;
    [kShareSuccessCallBack] = PlayCreateEndgateRoomController.onShareSuccessCallBack;
};

PlayCreateEndgateRoomController.s_nativeEventFuncMap = CombineTables(PlayCreateEndgateRoomController.s_nativeEventFuncMap,
	ChessController.s_nativeEventFuncMap or {});



PlayCreateEndgateRoomController.s_socketCmdFuncMap = {
	[PROP_CMD_UPDATE_USERDATA]  = PlayCreateEndgateRoomController.onPropCmdUpdateUserData;
    [PROP_CMD_QUERY_USERDATA]   = PlayCreateEndgateRoomController.onPropCmdQueryUserData;--查询道具
}

PlayCreateEndgateRoomController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	PlayCreateEndgateRoomController.s_socketCmdFuncMap or {});


------------------------------------- 命令响应函数配置 ------------------------
PlayCreateEndgateRoomController.s_cmdConfig = 
{
    [PlayCreateEndgateRoomController.s_cmds.onBack] = PlayCreateEndgateRoomController.onBack;
    [PlayCreateEndgateRoomController.s_cmds.loadEndingBoard] = PlayCreateEndgateRoomController.onLoadEndingBoard;
    [PlayCreateEndgateRoomController.s_cmds.restart] = PlayCreateEndgateRoomController.restart;
    [PlayCreateEndgateRoomController.s_cmds.loadNextGate] = PlayCreateEndgateRoomController.loadNextGate;
    [PlayCreateEndgateRoomController.s_cmds.shareInfo] = PlayCreateEndgateRoomController.shareInfo;
    [PlayCreateEndgateRoomController.s_cmds.onEventStat] = PlayCreateEndgateRoomController.onEventStat;
    [PlayCreateEndgateRoomController.s_cmds.tip_action] = PlayCreateEndgateRoomController.tip_action;
    [PlayCreateEndgateRoomController.s_cmds.revive] = PlayCreateEndgateRoomController.revive;
    [PlayCreateEndgateRoomController.s_cmds.subMove1] = PlayCreateEndgateRoomController.subMove1;
    [PlayCreateEndgateRoomController.s_cmds.subMove2] = PlayCreateEndgateRoomController.subMove2;
    [PlayCreateEndgateRoomController.s_cmds.subMove3] = PlayCreateEndgateRoomController.subMove3;
    [PlayCreateEndgateRoomController.s_cmds.undoMove] = PlayCreateEndgateRoomController.undoMove;
    [PlayCreateEndgateRoomController.s_cmds.shareUrl] = PlayCreateEndgateRoomController.shareUrl;
    [PlayCreateEndgateRoomController.s_cmds.start_action] = PlayCreateEndgateRoomController.start_action;
    [PlayCreateEndgateRoomController.s_cmds.buy_ending] = PlayCreateEndgateRoomController.buyEnding;
    [PlayCreateEndgateRoomController.s_cmds.report_ending] = PlayCreateEndgateRoomController.reportEnding;
    [PlayCreateEndgateRoomController.s_cmds.save_mychess] = PlayCreateEndgateRoomController.onSaveMychess;
    [PlayCreateEndgateRoomController.s_cmds.changeFlag] = PlayCreateEndgateRoomController.changeFlag;
    
}

