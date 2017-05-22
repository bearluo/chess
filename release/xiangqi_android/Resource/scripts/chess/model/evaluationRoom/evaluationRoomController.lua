require(MODEL_PATH .. "room/roomController")
require("chess/util/statisticsManager");

EvaluationRoomController = class(RoomController)



EvaluationRoomController.s_cmds = 
{	
    start_game = 1;
    chess_move = 2;
    gameClose = 3;
    back_action = 4;
};

EvaluationRoomController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
    self.m_room  = self.m_view;
    self.m_board = self.m_room.m_board
end

EvaluationRoomController.resume = function(self)
    RoomController.resume(self);
end;

EvaluationRoomController.pause = function(self)
    RoomController.pause(self);
end;

EvaluationRoomController.dtor = function(self)
    self:releaseTimer()
end;

EvaluationRoomController.onBack = function(self)
    if self:isGameOver() then
        StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT)
    else
        local message = "是否认输退出评测"
	    if not self.m_chioce_dialog then
		    self.m_chioce_dialog = new(ChioceDialog);
	    end
        self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE,"认输","取消")
	    self.m_chioce_dialog:setPositiveListener(self,function()
            self:userLose(ENDTYPE_SURRENDER)
        end)
        self.m_chioce_dialog:setNegativeListener(nil,nil)
	    self.m_chioce_dialog:setMessage(message)
	    self.m_chioce_dialog:show()
    end
end

EvaluationRoomController.updateUserInfoView = function(self)
end

EvaluationRoomController.s_timeset = {
    ["time1"] = 15*60;
    ["time2"] = 90;
    ["time3"] = 60;
}

EvaluationRoomController.onStartGame = function(self)
    self:setGameOver(false);
    self.m_mode = Board.MODE_RED
    self.m_board:newgame(self.m_mode)
    self:setAILevel(1)
    self:setTurn(Board.MODE_RED)
    self.m_timeset = {}
    self.m_timeset[Board.MODE_RED] = Copy(EvaluationRoomController.s_timeset)
    self.m_timeset[Board.MODE_BLACK] = Copy(EvaluationRoomController.s_timeset)
    self:startTimer()
    self.m_moveStep = {}
    self.m_moveStep[Board.MODE_RED] = 0
    self.m_moveStep[Board.MODE_BLACK] = 0
    self.m_useTime = {}
    self.m_useTime[Board.MODE_RED] = 0
    self.m_useTime[Board.MODE_BLACK] = 0
end

--是否轮到我走
EvaluationRoomController.isMyTurn = function(self)
	return self.m_cur_mode == self.m_mode;
end

EvaluationRoomController.setTurn = function(self,mode)
	self.m_cur_mode = mode
    if not self:isMyTurn() then
	    self:aiTurn()
    end
end

function EvaluationRoomController:startTimer()
    self:releaseTimer()
    self.m_timer = AnimFactory.createAnimInt(kAnimLoop,0,1,1000,-1)
    self.m_timer:setEvent(self,self.onCountDown)
    self:updateView(EvaluationRoomScene.s_cmds.updateCountDownView,self.m_cur_mode,self.m_timeset[Board.MODE_RED],self.m_timeset[Board.MODE_BLACK])
    self:startCountDownViewAnim(self.m_cur_mode,self.m_timeset[self.m_cur_mode])
end

function EvaluationRoomController:onCountDown()
    local timeset = self.m_timeset[self.m_cur_mode]
    self.m_useTime[self.m_cur_mode] = self.m_useTime[self.m_cur_mode] + 1
    if not timeset then return end
    if timeset.time1 <= 0 then
        timeset.time1 = 0
        timeset.time3 = timeset.time3 - 1
    else
        timeset.time1 = timeset.time1 - 1
        timeset.time2 = timeset.time2 - 1
    end
    self:updateView(EvaluationRoomScene.s_cmds.updateCountDownView,self.m_cur_mode,self.m_timeset[Board.MODE_RED],self.m_timeset[Board.MODE_BLACK])
    if (timeset.time1 <= 0 and timeset.time3 <= 0) or timeset.time2 <= 0 then
        self:losePlayer(self.m_cur_mode,ENDTYPE_TIMEOUT)
    end
end

function EvaluationRoomController:changeMove()
    self:releaseTimer()
    local timeset = self.m_timeset[self.m_cur_mode]
    timeset.time2 = self.s_timeset.time2
    timeset.time3 = self.s_timeset.time3
    if self.m_cur_mode == Board.MODE_RED then
        self:setTurn(Board.MODE_BLACK)
    else
        self:setTurn(Board.MODE_RED)
    end
    self:startTimer()
    -- 测试
--    self:onBoardAiUnChangeMove();
end

function EvaluationRoomController:startCountDownViewAnim(mode,timeset)
    local time = 0
    if timeset.time1 <= 0 then
        time = timeset.time3 * 1000
    else
        time = timeset.time2 * 1000
    end
    self:updateView(EvaluationRoomScene.s_cmds.startCountDownViewAnim,mode,time,time)
end

function EvaluationRoomController:releaseTimer()
    if self.m_timer then
        delete(self.m_timer)
        self.m_timer = nil
    end
end

function EvaluationRoomController:losePlayer(mode,loseType)
    if mode == self.m_mode then
        self:userLose(loseType)
    else
        self:aiLose(loseType)
    end
end

function EvaluationRoomController:aiLose(loseType)
    self:gameOver(CHESS_MOVE_OVER_RED_WIN,loseType);
end

function EvaluationRoomController:userLose(loseType)
    self:gameOver(CHESS_MOVE_OVER_BLACK_WIN,loseType);
end

function EvaluationRoomController:gameOver(code,endType)
    self.m_board:console_gameover(code,endType);
    self:releaseTimer()
    self:updateView(EvaluationRoomScene.s_cmds.stopCountDownViewAnim)
end
--------------------------------Android2Lua----------------------------------

EvaluationRoomController.engine2Gui = function(self, flag, data)
    Log.i("data.Engine2Gui:get_value()--->"..data.Engine2Gui:get_value());
    self.m_board:onReceive(data.Engine2Gui:get_value());
end

EvaluationRoomController.onBoardUnlegalMove = function(self, code)
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
	ChatMessageAnim.play(self.m_view,3,message);
end


EvaluationRoomController.onBoardAiUnlegalMove = function(self)  
    self:aiLose(ENDTYPE_UNLEGAL)
end

EvaluationRoomController.onBoardAiUnChangeMove = function(self)
    self:gameOver(CHESS_MOVE_OVER_DRAW,ENDTYPE_UNCHANGE);
end

--玩家走棋（触摸）
EvaluationRoomController.onChessMove = function(self,data)
    self.m_moveStep[Board.MODE_RED] = self.m_moveStep[Board.MODE_RED] + 1
    if not self:isGameOver() and self.m_board:isDraw() then
		local message = "双方均无进攻子力!";
        ChessToastManager.getInstance():show(message);
        self:gameOver(CHESS_MOVE_OVER_DRAW,ENDTYPE_DRAW);
        return ;
    end
	if self:isGameOver() then
		print_string("EvaluationRoom.chessMove gamve over ");
		return;
	end
    self:changeMove()
end


EvaluationRoomController.setGameOver = function(self,flag)
	print_string("EvaluationRoom.setGameOver");
	self.m_game_over = flag;
end

EvaluationRoomController.gameClose = function(self,flag,endType)
    if self:isGameOver() then return end
    local winFlag = 3
    if flag == CHESS_MOVE_OVER_RED_WIN then
        winFlag = 1
    elseif flag == CHESS_MOVE_OVER_BLACK_WIN then
        winFlag = 3
    else
        winFlag = 2
    end
    self:setGameOver(true);
    self:releaseTimer()
    self:reportDataEvaluationResult(winFlag,self.m_moveStep[Board.MODE_RED],self.m_moveStep[Board.MODE_BLACK],self.m_useTime[Board.MODE_RED],self.m_useTime[Board.MODE_BLACK])
end

EvaluationRoomController.isGameOver = function(self)
	return self.m_game_over or false;
end

EvaluationRoomController.aiTurn = function(self)
	self.m_board:response(ENGINE_MOVE);
end

EvaluationRoomController.setAILevel = function(self,level)
	self.m_board:setLevel(level);
end

EvaluationRoomController.onBoardAiMove = function(self)
    self.m_moveStep[Board.MODE_BLACK] = self.m_moveStep[Board.MODE_BLACK] + 1
    self:changeMove()
end

function EvaluationRoomController:reportDataEvaluationResult(flag,play_steps,AI_steps,play_spent,AI_spent)
    local params = {}
    params.result = {}
    params.result.winFlag = flag
    params.result.play_steps = play_steps
    params.result.AI_steps = AI_steps
    params.result.play_spent = play_spent
    params.result.AI_spent = AI_spent
    GameCacheData.getInstance():saveString(GameCacheData.EVALUATION_DATA_..UserInfo.getInstance():getUid(),json.encode(params));
    HttpModule.getInstance():execute(HttpModule.s_cmds.UserNewUserEvaluating,params,"上传测评数据中...")
end

function EvaluationRoomController:onUserNewUserEvaluating(isSuccess,message)
    if not isSuccess then
        self:updateView(EvaluationRoomScene.s_cmds.showEvaluationRoomAccountsDialog,false);
        return
    end
    message = json.analyzeJsonNode(message)
    if type(message) ~= "table" or message.flag ~= 10000 or type(message.data) ~= "table" then return self:updateView(EvaluationRoomScene.s_cmds.showEvaluationRoomAccountsDialog,false); end
    local data = message.data
    local double_card = data.double_card or {}
    UserInfo.getInstance():setDoubleProp(double_card.num,double_card.valid_time)
    UserInfo.getInstance():setHasEvaluation()
    GameCacheData.getInstance():saveString(GameCacheData.EVALUATION_DATA_..UserInfo.getInstance():getUid(),"")

    self:updateView(EvaluationRoomScene.s_cmds.showEvaluationRoomAccountsDialog,true,data.score);
end

--------------------------------config--------------------------------------

EvaluationRoomController.s_cmdConfig = 
{
    [EvaluationRoomController.s_cmds.start_game]		            = EvaluationRoomController.onStartGame;
    [EvaluationRoomController.s_cmds.chess_move]	                = EvaluationRoomController.onChessMove;
    [EvaluationRoomController.s_cmds.gameClose]                     = EvaluationRoomController.gameClose;
    [EvaluationRoomController.s_cmds.back_action]                   = EvaluationRoomController.onBack;
}

EvaluationRoomController.s_nativeEventFuncMap = {
    [ENGINE_GUI]                            = EvaluationRoomController.engine2Gui;
    [Board.UNLEGALMOVE]                     = EvaluationRoomController.onBoardUnlegalMove;
    [Board.AIUNLEGALMOVE]                   = EvaluationRoomController.onBoardAiUnlegalMove;
    [Board.AIMOVE]                          = EvaluationRoomController.onBoardAiMove;
    [Board.AI_UNCHANGE_MOVE]                = EvaluationRoomController.onBoardAiUnChangeMove;
}

EvaluationRoomController.s_nativeEventFuncMap = CombineTables(RoomController.s_nativeEventFuncMap,
	EvaluationRoomController.s_nativeEventFuncMap or {})

EvaluationRoomController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.UserNewUserEvaluating] = EvaluationRoomController.onUserNewUserEvaluating;
}

EvaluationRoomController.s_httpRequestsCallBackFuncMap = CombineTables(RoomController.s_httpRequestsCallBackFuncMap,
	EvaluationRoomController.s_httpRequestsCallBackFuncMap or {});


