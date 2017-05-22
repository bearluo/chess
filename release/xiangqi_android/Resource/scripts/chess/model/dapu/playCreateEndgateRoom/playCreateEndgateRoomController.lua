require("config/path_config");
require("chess/util/statisticsManager");

require(MODEL_PATH.."/room/roomController");

PlayCreateEndgateRoomController = class(RoomController);

PlayCreateEndgateRoomController.s_cmds = 
{	
    onBack              = 1;
    loadEndingBoard     = 2;
    loadNextGate        = 3;
    shareInfo           = 4;
    onEventStat         = 5;
    undoMove            = 11;
    shareUrl            = 12;
    restart             = 13;
    start_action        = 14;
    buy_ending          = 15;
    report_ending       = 16;
    save_mychess        = 17;
    changeFlag          = 18;
    follow_endgate      = 19;
};

require("dialog/http_loading_dialog");
PlayCreateEndgateRoomController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
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
    self:getData();
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
PlayCreateEndgateRoomController.getData = function(self)
    local booth_id = kEndgateData:getPlayCreateEndingDataID();
    local params = {};
    params.booth_id = booth_id;
    HttpModule.getInstance():execute(HttpModule.s_cmds.WulinBoothGetBoothInfo,params,"初始化...");
end

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
--	self:onLoadEndingBoard();
end

PlayCreateEndgateRoomController.shareInfo = function(self)
    self:onEventStat(ENDGIN_ROOM_MODEL_SHARE_BTN);
end

PlayCreateEndgateRoomController.shareUrl = function(self)
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
    local param = "booth_id_" .. data.booth_id;
    StatisticsManager.getInstance():onCountToUM(event_id,param);
end

PlayCreateEndgateRoomController.aiTurn = function(self)
	self.m_board:response(ENGINE_MOVE);
end

PlayCreateEndgateRoomController.onLoadEndingBoardByData = function(self,data)
    if data then
        UserInfo.getInstance():setFlag(self.flag + 1); -- model 0 1 红黑  flag  1 2 红黑
        local board_table = data;
        local move = nil
        if string.len(data.movelist) > 1 then
            move = ToolKit.split(data.movelist,",");
        end
        local fen = board_table.booth_fen;
--        self.m_board:ending_game(fen);
	    Board.resetFenPiece();
        local chessMap = self.m_board:fen2chessMap(fen);
        self.m_board:newgame(self.flag,fen,chessMap)
        self.m_board:setEngineBegin(fen);
        GameCacheData.getInstance():saveString(GameCacheData.DAPU_LAST_BORAD_FEN,fen);
        GameCacheData.getInstance():saveString(GameCacheData.DAPU_LAST_CHESS_STR,table.concat(chessMap,MV_SPLIT));

        self:setMyTurn(self.flag == Board.MODE_RED);
        if  not self:isMyTurn() then
	        self:aiTurn();
        end
        if move then
            self:updateView(PlayCreateEndgateRoomScene.s_cmds.startGame,move);
        else
            self:updateView(PlayCreateEndgateRoomScene.s_cmds.startGame);
        end
    else
        ChessToastManager.getInstance():showSingle("数据错误");
    end
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
	self:setMyTurn(true);
end

PlayCreateEndgateRoomController.engine_gui = function(self,flag,data)
    if self.m_board then
	    self.m_board:onReceive(data.Engine2Gui:get_value());
    end
end

PlayCreateEndgateRoomController.onShareSuccessCallBack = function(self,flag,data)
    local data = kEndgateData:getPlayCreateEndingData() or {};
    local params = {};
    params.booth_id = data.booth_id;
    HttpModule.getInstance():execute(HttpModule.s_cmds.WulinBoothReportShare,params);
end

PlayCreateEndgateRoomController.chessMove = function(self,data)
	self:setMyTurn(false); --self.m_my_turn = false; --我下完棋之后轮到电脑走棋
    self.m_step = self.m_step + 1;
    self:updateView(PlayCreateEndgateRoomScene.s_cmds.update_step_text,self.m_step);
	self:updateView(PlayCreateEndgateRoomScene.s_cmds.dismissTipsNote);
	if self:isGameOver() then
		print_string("PlayCreateEndgateRoomController.chessMove gamve over ");
		return;
	end

	self.m_board:response(ENGINE_MOVE);
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

--上一步 .. 悔棋
PlayCreateEndgateRoomController.preStep = function(self)

	if not self.m_board:consoleUndoMove() then
		local message = "无棋可悔啦！";
        ChessToastManager.getInstance():showSingle(message);
		return false;
	end

	return true;
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

    if self:isLogined() and not self.user_prop_func then
        self.m_load_socket_dialog:show();
        self:startTimeout();
        self.user_prop_func = PlayCreateEndgateRoomController.use_undoMove;
        self:sendSocketMsg(PROP_CMD_QUERY_USERDATA);
    end
    return false;
end

PlayCreateEndgateRoomController.use_undoMove = function(self)
	local undo_num = UserInfo.getInstance():getUndoNum();
	if self:preStep() then
        --成功悔棋次数减一
        local sendData = {};
        local item = {};
        item.op = 2; -- =1相加，=2相减，=3覆盖
        item.op_id = 12; -- 11 => '单机中使用道具', 12 => '残局中使用道具',
        item.num = 1;--修改数量
        item.prop_id = kUndoNum; --道具id
        table.insert(sendData,item);
        self:sendSocketMsg(PROP_CMD_UPDATE_USERDATA,sendData);
        --先使用
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

function PlayCreateEndgateRoomController.followEndgate(self)
    local data = kEndgateData:getPlayCreateEndingData();
    if self.mSendFollowEndgate then return end
    self.mSendFollowEndgate = true
    if tonumber(data.is_mark) == 1 then
        local params = {};
        params.booth_id = data.booth_id;
        HttpModule.getInstance():execute(HttpModule.s_cmds.WulinBoothDelMark,params);
    else
        local params = {};
        params.booth_id = data.booth_id;
        HttpModule.getInstance():execute(HttpModule.s_cmds.WulinBoothMark,params);
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
            if message.flag:get_value() == 12 then
                local payRecommend = MallData.getInstance():getPayRecommendGoods()
                if payRecommend and payRecommend.buyProp then
                    local goods = MallData.getInstance():getGoodsById(payRecommend.buyProp)
                    if goods then
                        local payData = {}
                        payData.pay_scene = PayUtil.s_pay_scene.buy_booth
                        payData.gameparty_subname = PayUtil.s_pay_room.endgate
		                local payInterface = PayUtil.getPayInstance(PayUtil.s_defaultType);
		                payInterface:buy(goods,payData);	
                    end
                end 
            end
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

require(DIALOG_PATH.."chioce_dialog");
PlayCreateEndgateRoomController.onWulinBoothUploadMoveListCallBack = function(self,success,message)
    if not success then 
        delete(self.m_chiose_dialog);
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
    local title = "残局：" .. message.data.booth_title:get_value() .. "（博雅中国象棋）";
    data.title = title;
    data.description = title;
    data.flag = UserInfo.getInstance():getOpenWeixinShare();
    self:updateView(PlayCreateEndgateRoomScene.s_cmds.show_share_dialog,data);
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

PlayCreateEndgateRoomController.onWulinBoothMark = function(self, flag, message)
    self.mSendFollowEndgate = false
    if not flag then return end
    local data = kEndgateData:getPlayCreateEndingData();
    data.is_mark = 1;
    self:updateView(PlayCreateEndgateRoomScene.s_cmds.update_follow_icon,true);
end

PlayCreateEndgateRoomController.onWulinBoothDelMark = function(self, flag, message)
    self.mSendFollowEndgate = false
    if not flag then return end
    local data = kEndgateData:getPlayCreateEndingData();
    data.is_mark = 0;
    self:updateView(PlayCreateEndgateRoomScene.s_cmds.update_follow_icon,false);
end

PlayCreateEndgateRoomController.onWulinBoothGetBoothInfo = function(self, flag, message)
    if not flag then 
        ChessToastManager.getInstance():showSingle("初始化失败");
        return 
    end
    local data = json.analyzeJsonNode(message.data);
    if not data then 
        ChessToastManager.getInstance():showSingle("初始化失败");
        return 
    end
    kEndgateData:setPlayCreateEndingData(data);
    self:updateView(PlayCreateEndgateRoomScene.s_cmds.init);
    self:start_action();
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
    [HttpModule.s_cmds.WulinBoothMark]              = PlayCreateEndgateRoomController.onWulinBoothMark; 
    [HttpModule.s_cmds.WulinBoothDelMark]           = PlayCreateEndgateRoomController.onWulinBoothDelMark;    
    [HttpModule.s_cmds.WulinBoothGetBoothInfo]      = PlayCreateEndgateRoomController.onWulinBoothGetBoothInfo;
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
    [PlayCreateEndgateRoomController.s_cmds.undoMove] = PlayCreateEndgateRoomController.undoMove;
    [PlayCreateEndgateRoomController.s_cmds.shareUrl] = PlayCreateEndgateRoomController.shareUrl;
    [PlayCreateEndgateRoomController.s_cmds.start_action] = PlayCreateEndgateRoomController.start_action;
    [PlayCreateEndgateRoomController.s_cmds.buy_ending] = PlayCreateEndgateRoomController.buyEnding;
    [PlayCreateEndgateRoomController.s_cmds.report_ending] = PlayCreateEndgateRoomController.reportEnding;
    [PlayCreateEndgateRoomController.s_cmds.save_mychess] = PlayCreateEndgateRoomController.onSaveMychess;
    [PlayCreateEndgateRoomController.s_cmds.changeFlag] = PlayCreateEndgateRoomController.changeFlag;
    [PlayCreateEndgateRoomController.s_cmds.follow_endgate] = PlayCreateEndgateRoomController.followEndgate;
}

