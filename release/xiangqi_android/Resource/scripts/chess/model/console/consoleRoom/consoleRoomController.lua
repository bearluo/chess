require(MODEL_PATH .. "room/roomController")
require("chess/util/statisticsManager");

ConsoleRoomController = class(RoomController)



ConsoleRoomController.s_cmds = 
{	
    share_action        = 1;
    leave_action        = 2;
    switch_menu         = 3;
    start_game          = 4;
    event_state         = 6;
    undo_action         = 7;
    get_soul            = 8;
    chess_move          = 9;
    upload_console2php  = 10;
    upload_progress     = 11;
    restart_game        = 12;
    save_AI_result      = 13;
    give_up_restart_game = 14;
    is_can_exchange_tips = 15;
    exchange_tips_prop   = 16;
    use_tips             = 17;
    is_my_turn           = 18;
};

ConsoleRoomController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
    self.m_room  = self.m_view;
end

ConsoleRoomController.resume = function(self)
    RoomController.resume(self);
    if not self.mIsInitGame then
        self.mIsInitGame = true
        self:initGame()
    elseif self.m_board then
        if not self:isGameOver() then
            if self.mEngineStatue == ENGINE_HINT or  self.mEngineStatue == ENGINE_MOVE then
                self.m_board:response(self.mEngineStatue);
            end
        end
    end
end

ConsoleRoomController.pause = function(self)
    RoomController.pause(self);
    if self.m_board then
        self.mEngineStatue = self.m_board:getEngineStatus()
        self.m_board:stopThink()
    end
end;

ConsoleRoomController.dtor = function(self)
    delete(self.mExchangePropDialog)
end;

ConsoleRoomController.onBack = function(self)
    self:updateView(ConsoleRoomScene.s_cmds.exit_room);
end;

ConsoleRoomController.updateUserInfoView = function(self)

    self:updateView(ConsoleRoomScene.s_cmds.update_undo_num, UserInfo.getInstance():getUndoNum());
end;
--------------------------------function------------------------------------


ConsoleRoomController.onShareAction = function(self)
    Log.i("ConsoleRoomController.onShareAction");
	self:onEventStat(NEW_CONSOLEROOM_MODEL_SHARE_BTN);
    dict_set_string(kTakeScreenShot , kTakeScreenShot .. kparmPostfix , "egame_share");
    call_native(kTakeScreenShot);
end;

ConsoleRoomController.onLeaveAction = function(self)

    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);

end;

ConsoleRoomController.onEventStat = function(self,event_id)
    local level = UserInfo.getInstance():getPlayingLevel();
    local param = "level_" .. level;
--  local event_info = event_id .. ","  ..  "level_" .. level;
--  on_event_stat(event_info); --事件统计
    StatisticsManager.getInstance():onCountToUM(event_id,param);
end

ConsoleRoomController.buyDapu = function(self)
	self.m_payInterface = PayUtil.getPayInstance(PayUtil.s_payType.Exchange);
	self.m_pay_dialog = self.m_payInterface:buy(nil,CONSOLE_ROOM_DAPU);
end

ConsoleRoomController.cancelSaveMVList = function(self)
	UserInfo.getInstance():setDapuDataNeedToSave(nil);
end

function ConsoleRoomController:initGame()
    local level = UserInfo.getInstance():getPlayingLevel();
    local AI_LEVEL_MAP = UserInfo.getInstance():getAILevelMap();
    print_string("PlayingLevel is -------------->"..level)
	self.mAiLevel = AI_LEVEL_MAP[level]
    self:updateView(ConsoleRoomScene.s_cmds.start_game, level, level)
    self.m_model = User.AI_MODEL[level];
    if self.m_model == Board.MODE_RED then
        self.m_room.m_my_flag = FLAG_RED;
        self.m_room.m_ai_flag = FLAG_BLACK;
    else
        self.m_room.m_my_flag = FLAG_BLACK;
        self.m_room.m_ai_flag = FLAG_RED;
    end
    self.m_board = self.m_room.m_board;
    self:setGameOver(false);
    
    --如果是来自中途单机棋局
	if UserInfo.getInstance():getJoinPlayedConsole() then
        --由于中途棋局是自己每走一步都会保存，所以下次加入都是电脑先走棋。
        --从中途棋局加入后，悔棋图标都是默认点亮的，但电脑先走棋，图标应设置为不可用。
--        self:setMyTurn(false);
        self.m_board:console_synchrodata(self.m_model, self.mAiLevel, level);
        UserInfo.getInstance():setJoinPlayedConsole(false)
        self.mCanExchangeTips = GameCacheData.getInstance():getBoolean(GameCacheData.CONSOLE_CAN_EXCHANGE_TIPS, false)
        self.mTipsNum = GameCacheData.getInstance():getInt(GameCacheData.CONSOLE_TIPS_NUM, 0)
        self:onStartGame()
    else --如果不存在中途棋局，则新开棋局。
        --  提前展示棋盘
        self:onRestartGame()
    end
end

-- 下一关
-- 这里是再来一局
ConsoleRoomController.loadNextGate = function(self)
    self:onRestartGame()
end

ConsoleRoomController.onStartGame = function(self,fenSet)
    if fenSet then self:userGuns(fenSet) end
    self.m_startTime = os.time();--单机开始时间
    local chess_map = self.m_board:to_chess_map();
    -- 用于后期存储复盘
    GameCacheData.getInstance():saveString(GameCacheData.DAPU_LAST_BORAD_FEN,Board.toFen(chess_map,true));
	GameCacheData.getInstance():saveString(GameCacheData.DAPU_LAST_CHESS_STR,table.concat(chess_map,MV_SPLIT));
    --新开局重置以下上报数据
    self.m_undoUseNum = 0;--悔棋使用数量
    self.m_moveSteps = 0;--移动步数
    local level = UserInfo.getInstance():getPlayingLevel();
    self:updateView(ConsoleRoomScene.s_cmds.start_game, level, level)
    self:updateView(ConsoleRoomScene.s_cmds.set_tips_num,self.mTipsNum)
    if  not self:isMyTurn() then
	    self:aiTurn();
    end
    if self.mAiThinking then
        self:onTipsEnd()
    end
end

function ConsoleRoomController:userGuns(fenSet)
    if not fenSet then return end
    local fenStr = fenSet[1]
    local index90 = fenSet[2]
    Board.resetFenPiece()
    local chess_map = self.m_board:fen2chessMap(fenStr);
    self:setAILevel(self.mAiLevel)
    self.m_board:newgame(self.m_model,fenStr,chess_map)
end

function ConsoleRoomController:onRestartGame()
    local level = UserInfo.getInstance():getPlayingLevel();
    local AI_LEVEL_MAP = UserInfo.getInstance():getAILevelMap();
    print_string("PlayingLevel is -------------->"..level)
	self.mAiLevel = AI_LEVEL_MAP[level]
    self.m_board:newgame(self.m_model)
    self:setAILevel(self.mAiLevel)
	self:setPassLevel(level)
--    self:setMyTurn(self.m_model == Board.MODE_RED)
    self:setGameOver(false);
    self.mCanExchangeTips = true
    self.mTipsNum = 0
    self:updateView(ConsoleRoomScene.s_cmds.show_ready_dialog)
    if self.mAiThinking then
        self:onTipsEnd()
    end
    -- 保存单机存档数据
    GameCacheData.getInstance():saveBoolean(GameCacheData.CONSOLE_IS_EXISTED_CHESS, false)
    GameCacheData.getInstance():saveBoolean(GameCacheData.CONSOLE_CAN_EXCHANGE_TIPS, self.mCanExchangeTips)
    GameCacheData.getInstance():saveInt(GameCacheData.CONSOLE_TIPS_NUM, self.mTipsNum)
end

function ConsoleRoomController:buyChallenge()
    local level = UserInfo.getInstance():getPlayingLevel();
    local config = ConsoleData.getInstance():getConfigByLevel(level)
    if level > ConsoleData.DEFAULT_OPEN_LEVEL then
        local zhanji = ConsoleData.getInstance():getZhanJiByLevel(level)
        local costMoney = tonumber(config.money) or 0
        local star = zhanji.star
        if costMoney ~= 0 then
            if not star or #star == 0 then
                if not self.mBuyChallengeDialog then
                    self.mBuyChallengeDialog = new(ChioceDialog);
                    self.mBuyChallengeDialog:setMode(ChioceDialog.MODE_COMMON);
                    self.mBuyChallengeDialog:setNeedMask(false)
                end
                self.mBuyChallengeDialog:setMessage( string.format("是否花费%d金币闯关",costMoney));
                self.mBuyChallengeDialog:setNegativeListener(nil,nil);
                self.mBuyChallengeDialog:setPositiveListener(self,function()
                    local params = {}
                    params.console_level = level
                    HttpModule.getInstance():execute(HttpModule.s_cmds.UserBuyLevel,params,"请求中...")
                end);
                self.mBuyChallengeDialog:show();
                return 
            end
        end
    end
    self:onRestartGame()
end

function ConsoleRoomController:isCanExchangeTips()
    return self.mCanExchangeTips
end

function ConsoleRoomController:exchangeTipsProp()
    if self:isGameOver() then return end
    local level = UserInfo.getInstance():getPlayingLevel();
    local config = ConsoleData.getInstance():getConfigByLevel(level)
    local tips = string.format("是否花费%d金币兑换%d个锦囊",config.jn_cost or 0,config.jn_num or 3)
    if not self.mExchangePropDialog then
        self.mExchangePropDialog = new(ChioceDialog);
        self.mExchangePropDialog:setMode(ChioceDialog.MODE_COMMON);
    end
    self.mExchangePropDialog:setMessage(tips);
    self.mExchangePropDialog:setNegativeListener(nil,nil);
    self.mExchangePropDialog:setPositiveListener(self,function()
        local level = UserInfo.getInstance():getPlayingLevel();
        local params = {}
        params.console_level = level
        HttpModule.getInstance():execute(HttpModule.s_cmds.UserBuyJn,params,"兑换中")
    end);
    self.mExchangePropDialog:show();
end

function ConsoleRoomController:exchangeTipsPropCallBack(isSuccess,message)
    if HttpModule.explainPHPMessage(isSuccess,message,"兑换失败！") then
        return 
    end
    if message.data.ret:get_value() == 1 then
        local level = UserInfo.getInstance():getPlayingLevel();
        local config = ConsoleData.getInstance():getConfigByLevel(level)
        self.mTipsNum = config.jn_num or 3
        self.mCanExchangeTips = false
        GameCacheData.getInstance():saveBoolean(GameCacheData.CONSOLE_CAN_EXCHANGE_TIPS, self.mCanExchangeTips)
        GameCacheData.getInstance():saveInt(GameCacheData.CONSOLE_TIPS_NUM, self.mTipsNum)
        self:updateView(ConsoleRoomScene.s_cmds.set_tips_num,self.mTipsNum)
    else
        ChessToastManager.getInstance():showSingle("扣钱失败")
    end
end

function ConsoleRoomController:useTips()
    if not self.mTipsNum or self.mTipsNum <= 0 then 
        ChessToastManager.getInstance():showSingle("提示不足")
        return false
    end
    self.mTipsNum = self.mTipsNum - 1
    GameCacheData.getInstance():saveInt(GameCacheData.CONSOLE_TIPS_NUM, self.mTipsNum)
    self:updateView(ConsoleRoomScene.s_cmds.set_tips_num,self.mTipsNum)
    self:setAILevel(6)
    self.m_board:response(ENGINE_HINT);
    self:setAILevel(self.mAiLevel)
    self.mAiThinking = true
    return true
end

function ConsoleRoomController:onAiThinkCallBack(isSuccess)
    if not isSuccess then
        self.mTipsNum = self.mTipsNum + 1
        GameCacheData.getInstance():saveInt(GameCacheData.CONSOLE_TIPS_NUM, self.mTipsNum)
        self:updateView(ConsoleRoomScene.s_cmds.set_tips_num,self.mTipsNum)
        ChessToastManager.getInstance():showSingle("电脑想不出怎么走了")
    end
    self:onTipsEnd()
end

function ConsoleRoomController:onTipsEnd()
    self:updateView(ConsoleRoomScene.s_cmds.end_ai_think)
    self.mAiThinking = false
end

function ConsoleRoomController:onGiveUpRestartGame()
    self:saveAIResult(true)
    self:uploadConsole2Php(0)
    self:buyChallenge()
end

ConsoleRoomController.onEventState  = function(self, id)
  self:onEventStat(id);  
end;


ConsoleRoomController.onUndoAction = function(self)
    -- ai 想棋 阶段不准悔棋
    if self.mAiThinking then
        ChessToastManager.getInstance():showSingle("电脑正在思考中,请耐心等待")
        return 
    end
    self:onEventStat(NEW_CONSOLEROOM_MODEL_UNDO_BTN);

    local undo_num = UserInfo.getInstance():getUndoNum();
	if undo_num < 1 then
        
        self.m_payInterface = PayUtil.getPayInstance(PayUtil.s_payType.Exchange); 
		self.m_pay_dialog = self.m_payInterface:buy(nil,CONSOLE_ROOM_UNDO);	
		return
	end

	--成功悔棋次数减一
	if 	self.m_board:consoleUndoMove() then 
        self.m_undoUseNum = self.m_undoUseNum + 1;
		undo_num = undo_num - 1;
		UserInfo.getInstance():setUndoNum(undo_num);
		self:showUndoNum();
--		self:setMyTurn(true);
        --单机特殊 只上报
        local sendData = {};
        local item = {};
        item.op = 2; -- =1相加，=2相减，=3覆盖
        item.op_id = 11; -- 11 => '单机中使用道具', 12 => '残局中使用道具',
        item.num = 1;--修改数量
        item.prop_id = kUndoNum; --道具id
        table.insert(sendData,item);
        self:sendSocketMsg(PROP_CMD_UPDATE_USERDATA,sendData);
	else
		local message = "无棋可悔啦！";
--		ShowMessageAnim.play(self.m_room,message);
        ChessToastManager.getInstance():showSingle(message);
	end


end;



ConsoleRoomController.onGetSoul = function(self, scene)
    local post_data = {};
    post_data.method = PhpConfig.METHOD_GET_SOUL;
    post_data.sence = scene;
    self:sendHttpMsg(HttpModule.s_cmds.getSoul, post_data);
end;


--展示悔棋次数
ConsoleRoomController.showUndoNum = function(self)
	local num = UserInfo.getInstance():getUndoNum();
	self:updateView(ConsoleRoomScene.s_cmds.update_undo_num, num);
end


--是否轮到我走
ConsoleRoomController.isMyTurn = function(self)
    if not self.m_board then return false end
	return self.m_board:isYouTurn();
end
ConsoleRoomController.setMyTurn = function(self,is_my_trun)
	self.m_my_turn = is_my_trun or false
end
--------------------------------Android2Lua----------------------------------

ConsoleRoomController.engine2Gui = function(self, flag, data)
    Log.i("data.Engine2Gui:get_value()--->"..data.Engine2Gui:get_value());
    self.m_board:onReceive(data.Engine2Gui:get_value());
end;


ConsoleRoomController.onSaveConsoleProgress = function(self)
    self.m_board:console_save();
end;


ConsoleRoomController.onBoardUnlegalMove = function(self, code)
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

end;


ConsoleRoomController.onBoardAiUnlegalMove = function(self)  
    self.m_board:console_gameover(UserInfo.getInstance():getFlag(),ENDTYPE_UNLEGAL);
end;

ConsoleRoomController.onBoardAiMove = function(self)
--    self:setMyTurn(true)
    self:updateView(ConsoleRoomScene.s_cmds.undo_btn_enable);
end
ConsoleRoomController.onBoardAiUnChangeMove = function(self)
    self.m_board:console_gameover(CHESS_MOVE_OVER_DRAW,ENDTYPE_UNCHANGE);
end;

ConsoleRoomController.onRecvShareDialogHide = function(self)
    self:updateView(ConsoleRoomScene.s_cmds.shareDialogHide);
end

ConsoleRoomController.uploadConsole2Php = function(self,is_win)
    local post_data = {};
    post_data.game_type = "10";--单机10，残局20
    post_data.start_time = self.m_startTime;
    post_data.end_time = os.time();
    post_data.is_win = is_win;
    post_data.game_tid = 1;--大关卡id，单机写1
    post_data.game_pos = UserInfo.getInstance():getPlayingLevel();
    post_data.user_prop = {["21"] = self.m_undoUseNum, ["22"] = 0};
    post_data.move_step = self.m_moveSteps;
    self:sendHttpMsg(HttpModule.s_cmds.uploadConsole2Php,post_data);

end



ConsoleRoomController.onUploadProgress = function(self,finishTask)
    local post_data = {};
    post_data.progress = {}
    post_data.progress["1"] = ConsoleData.getInstance():getMaxStarOpenLevel()
    post_data.star = {}
    local currentPlayingLevel = UserInfo.getInstance():getPlayingLevel();
    post_data.star[currentPlayingLevel..""] = finishTask or {}
    self:sendHttpMsg(HttpModule.s_cmds.uploadConsoleProgress, post_data);
end;



--------------------------------board2Room Func------------------------------



ConsoleRoomController.setDieChess = function(self,dieChess)

end
--玩家走棋（触摸）
ConsoleRoomController.onChessMove = function(self,data)
--	self:setMyTurn(false); --self.m_my_turn = false; --我下完棋之后轮到电脑走棋
    self.m_moveSteps = self.m_moveSteps + 1;--用户走的步数
    if not self:isGameOver() and self.m_board:isDraw() then
		local message = "双方均无进攻子力!";
        ChessToastManager.getInstance():show(message);
        self.m_board:console_gameover(CHESS_MOVE_OVER_DRAW,ENDTYPE_DRAW);
        return ;
    end
	if self:isGameOver() then
		print_string("ConsoleRoom.chessMove gamve over ");
		return;
	end
	self:aiTurn();
end


ConsoleRoomController.setGameOver = function(self,flag)
	print_string("ConsoleRoom.setGameOver");
	self.m_game_over = flag;
end

ConsoleRoomController.console_gameover = function(self,flag,endType)
	
--    self:updateView(ConsoleRoomScene.s_cmds.game_close, flag,endType);
    
    
end

ConsoleRoomController.gameClose = function(self,flag,endType)


	self.m_board:gameClose();

	--self.m_game_over = true;

end




ConsoleRoomController.isGameOver = function(self)
	return self.m_game_over or false;
end



ConsoleRoomController.aiTurn = function(self)
	self.m_board:response(ENGINE_MOVE);
end


ConsoleRoomController.setAILevel = function(self,level)

--	self.m_ai_level = level or 3;
	self.m_board:setLevel(level);
end

ConsoleRoomController.setPassLevel = function(self,level)
	self.m_board:setPassLevel(level);
end

ConsoleRoomController.onHttpStatRewardPerLevelCallBack = function(self, flag, message)
    if not flag then
        return;
    end;
    if not message then
        return;
    end;
	local status = message.status;
	if not status then
		return;
	end
	
	status = status:get_value();
	if tonumber(status) ==  1 then
		print_string("=============statRewardPerLevelCallBack==========");
		UserInfo.getInstance():clearPlayConsoleReward();
	end    

end;


ConsoleRoomController.onHttpGetSoulCallBack = function(self, flag, message)
    
    if not flag then
        return;
    end;

	if not HttpModule.explainPHPFlag(message) then
		return;
	end

	local status = tonumber(message.status:get_value());
	if status == 1 then
		local data = message.data;
		if not data then
			return;
		end

		local retdata = {};
		retdata.reward_soul =  tonumber(data.reward_soul:get_value()); --: -2库存不足，-1棋魂不足，0兑换失败，1成功 
		retdata.current_soul =  tonumber(data.current_soul:get_value());
		UserInfo.getInstance():setSoulCount(retdata.current_soul);
        local message = "恭喜你！获得"..retdata.reward_soul.."个棋魂。";
		ChatMessageAnim.play(self.m_view,3,message);
	end

end;

ConsoleRoomController.onUploadConsoleProgressCallBack = function(self, flag, message)
	if HttpModule.explainPHPMessage(flag,message,"数据上报失败") then 
        return 
    end    
    local progress = message.data.progress["1"]:get_value();
    local proportion = message.data.proportion:get_value();
    local leading_number = message.data.leading_number:get_value();
    self:updateView(ConsoleRoomScene.s_cmds.update_account_rank,proportion,leading_number,progress);
end;

ConsoleRoomController.onGetRewardCallBack = function(self, flag, message) 
    if not flag then
        if type(message) == "number" then
            if tonumber(message) == 2 then
                ChessToastManager.getInstance():showSingle("请求超时");
            elseif tonumber(message) == 3 then
                ChessToastManager.getInstance():showSingle("网络异常");
                self:updateView(ConsoleRoomScene.s_cmds.show_reward);
            end;
            return; 
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
            return;
        end;        
    end;

--    "time": 1444353843,
--    "flag": 10000,
--    "data": [
--        {
--            "type": "prop",
--            "prop_id": 3,
--            "is_reward": 1,
--            "num": 1
--        },
--        {
--            "type": "coin",
--            "is_reward": 0,
--            "num": 153
--        },
--        {
--            "type": "prop",
--            "prop_id": 2,
--            "is_reward": 0,
--            "num": 2
--        }
--    ]
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
    self:updateView(ConsoleRoomScene.s_cmds.show_reward,result);
end;


ConsoleRoomController.exchangePropCallBack = function(self,isSuccess,message)
    if not isSuccess then
        ChessToastManager.getInstance():show("兑换失败！");
        return ;
    end
    ChessController.exchangePropCallBack(self,isSuccess,message)
	local status = message.status:get_value();
    -- status	int -2金币不足	-1元宝不足，0兑换失败，1成功 -2 金币不足
    local payRecommend = MallData.getInstance():getPayRecommendGoods()
	if status == -2 then
        if payRecommend and payRecommend.buyProp then
            local goods = MallData.getInstance():getGoodsById(payRecommend.buyProp)
            if goods then
                local payData = {}
                payData.pay_scene = PayUtil.s_pay_scene.alone_prop
                payData.gameparty_subname = PayUtil.s_pay_room.console
		        local payInterface = PayUtil.getPayInstance(PayUtil.s_defaultType);
		        payInterface:buy(goods,payData);	
            end
        end 
    end
end

function ConsoleRoomController:exchangePropUserGuns(isSuccess,message)
    if HttpModule.explainPHPMessage(isSuccess,message,"兑换失败！") then 
        self:updateView(ConsoleRoomScene.s_cmds.update_user_guns,false)
        return 
    end
    local pc = tonumber(message.data.prob:get_value()) or Postion.PIECE_PAWN
    local gunStatus = message.gunStatus:get_value()
    ConsoleData.getInstance():setFreeGunStatus(gunStatus)
    self:updateView(ConsoleRoomScene.s_cmds.update_user_guns,true,pc)
end

ConsoleRoomController.saveAIResult = function(self,isWin)
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

function ConsoleRoomController.onUserBuyLevelCallBack(self, flag, message)
    if HttpModule.explainPHPMessage(flag, message,"购买失败") then return end
    local level = message.data.level:get_value()
    if level > 0 then
        self:onRestartGame()
    else
        ChessToastManager.getInstance():showSingle("扣钱失败")
    end
end
--------------------------------config--------------------------------------

ConsoleRoomController.s_cmdConfig = 
{
	[ConsoleRoomController.s_cmds.share_action]		    = ConsoleRoomController.onShareAction;
    [ConsoleRoomController.s_cmds.leave_action]	        = ConsoleRoomController.onLeaveAction;
--    [ConsoleRoomController.s_cmds.switch_menu]		= ConsoleRoomController.onSwitchMenu;
    [ConsoleRoomController.s_cmds.start_game]		    = ConsoleRoomController.onStartGame;
    [ConsoleRoomController.s_cmds.restart_game]		    = ConsoleRoomController.buyChallenge;
    [ConsoleRoomController.s_cmds.event_state]		    = ConsoleRoomController.onEventState;
    [ConsoleRoomController.s_cmds.undo_action]		    = ConsoleRoomController.onUndoAction;
    [ConsoleRoomController.s_cmds.get_soul]		        = ConsoleRoomController.onGetSoul;
    [ConsoleRoomController.s_cmds.chess_move]	        = ConsoleRoomController.onChessMove;
    [ConsoleRoomController.s_cmds.upload_console2php]	= ConsoleRoomController.uploadConsole2Php;
    [ConsoleRoomController.s_cmds.upload_progress]	    = ConsoleRoomController.onUploadProgress;
    [ConsoleRoomController.s_cmds.save_AI_result]	    = ConsoleRoomController.saveAIResult;
    [ConsoleRoomController.s_cmds.give_up_restart_game]	    = ConsoleRoomController.onGiveUpRestartGame;
    [ConsoleRoomController.s_cmds.is_can_exchange_tips]	    = ConsoleRoomController.isCanExchangeTips;
    [ConsoleRoomController.s_cmds.exchange_tips_prop]	    = ConsoleRoomController.exchangeTipsProp;
    [ConsoleRoomController.s_cmds.use_tips]	                = ConsoleRoomController.useTips;
    [ConsoleRoomController.s_cmds.is_my_turn]	            = ConsoleRoomController.isMyTurn;
    
}

ConsoleRoomController.s_nativeEventFuncMap = {
    [ENGINE_GUI]                            = ConsoleRoomController.engine2Gui;
    [CUSTOMENGATE_TIPS_ENABLE]              = ConsoleRoomController.onTipsEnd;
    [CONSOLE_SAVE_CHESS_MOVE]               = ConsoleRoomController.onSaveConsoleProgress;
    [Board.UNLEGALMOVE]                     = ConsoleRoomController.onBoardUnlegalMove;
    [Board.AIUNLEGALMOVE]                   = ConsoleRoomController.onBoardAiUnlegalMove;
    [Board.AIMOVE]                          = ConsoleRoomController.onBoardAiMove;
    [Board.AI_UNCHANGE_MOVE]                = ConsoleRoomController.onBoardAiUnChangeMove;
    [kShareDialogHide]                      = ConsoleRoomController.onRecvShareDialogHide;
};
--HallController.s_nativeEventFuncMap = CombineTables(HallController.s_nativeEventFuncMap,
--	ChessController.s_nativeEventFuncMap or {});

ConsoleRoomController.s_nativeEventFuncMap = CombineTables(RoomController.s_nativeEventFuncMap,
	ConsoleRoomController.s_nativeEventFuncMap or {});


ConsoleRoomController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.statRewardPerLevel]               = ConsoleRoomController.onHttpStatRewardPerLevelCallBack;
    [HttpModule.s_cmds.getSoul]                          = ConsoleRoomController.onHttpGetSoulCallBack;
    [HttpModule.s_cmds.uploadConsoleProgress]            = ConsoleRoomController.onUploadConsoleProgressCallBack;
    [HttpModule.s_cmds.getReward]                        = ConsoleRoomController.onGetRewardCallBack;
    [HttpModule.s_cmds.exchangeProp]                     = ConsoleRoomController.exchangePropCallBack;
    [HttpModule.s_cmds.UserGuns]                         = ConsoleRoomController.exchangePropUserGuns;
    [HttpModule.s_cmds.UserBuyJn]                         = ConsoleRoomController.exchangeTipsPropCallBack;
    [HttpModule.s_cmds.UserBuyLevel]                    = ConsoleRoomController.onUserBuyLevelCallBack;
};

ConsoleRoomController.s_httpRequestsCallBackFuncMap = CombineTables(RoomController.s_httpRequestsCallBackFuncMap,
	ConsoleRoomController.s_httpRequestsCallBackFuncMap or {});


    
-- 开枪配置fen串
ConsoleRoomController.GUNS_FEN = {};
ConsoleRoomController.GUNS_FEN[Board.MODE_RED] = {}
ConsoleRoomController.GUNS_FEN[Board.MODE_BLACK] = {}
local RED_FEN = ConsoleRoomController.GUNS_FEN[Board.MODE_RED]
local BLACK_FEN = ConsoleRoomController.GUNS_FEN[Board.MODE_BLACK]
BLACK_FEN[Postion.PIECE_KING] = {
	{"rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1"},
}
BLACK_FEN[Postion.PIECE_ADVISOR] = {
	{"rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNB1KABNR w - - 0 1",85},
	{"rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAK1BNR w - - 0 1",87},
}
BLACK_FEN[Postion.PIECE_BISHOP] = {
	{"rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RN1AKABNR w - - 0 1",84},
	{"rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKA1NR w - - 0 1",88},
}
BLACK_FEN[Postion.PIECE_KNIGHT] = {
	{"rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/R1BAKABNR w - - 0 1",83},
	{"rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKAB1R w - - 0 1",89},
}
BLACK_FEN[Postion.PIECE_ROOK] = {
	{"rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/1NBAKABNR w - - 0 1",82},
	{"rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABN1 w - - 0 1",90},
}
BLACK_FEN[Postion.PIECE_CANNON] = {
	{"rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/7C1/9/RNBAKABNR w - - 0 1",65},
	{"rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C7/9/RNBAKABNR w - - 0 1",71},
}
BLACK_FEN[Postion.PIECE_PAWN] = {
	{"rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/2P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1",55},
	{"rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P3P1P1P/1C5C1/9/RNBAKABNR w - - 0 1",57},
	{"rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P3P1P/1C5C1/9/RNBAKABNR w - - 0 1",59},
	{"rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P3P/1C5C1/9/RNBAKABNR w - - 0 1",61},
	{"rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P2/1C5C1/9/RNBAKABNR w - - 0 1",63},
}
-----------------------
RED_FEN[Postion.PIECE_KING] = {
	{"rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1"},
}
RED_FEN[Postion.PIECE_ADVISOR] = {
	{"rnb1kabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1",4},
	{"rnbak1bnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1",6},
}
RED_FEN[Postion.PIECE_BISHOP] = {
	{"rn1akabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1",3},
	{"rnbaka1nr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1",7},
}
RED_FEN[Postion.PIECE_KNIGHT] = {
	{"r1bakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1",2},
	{"rnbakab1r/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1",8},
}
RED_FEN[Postion.PIECE_ROOK] = {
	{"1nbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1",1},
	{"rnbakabn1/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1",9},
}
RED_FEN[Postion.PIECE_CANNON] = {
	{"rnbakabnr/9/7c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1",20},
	{"rnbakabnr/9/1c7/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1",26},
}
RED_FEN[Postion.PIECE_PAWN] = {
	{"rnbakabnr/9/1c5c1/2p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1",28},
	{"rnbakabnr/9/1c5c1/p3p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1",30},
	{"rnbakabnr/9/1c5c1/p1p3p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1",32},
	{"rnbakabnr/9/1c5c1/p1p1p3p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1",34},
	{"rnbakabnr/9/1c5c1/p1p1p1p2/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1",36},
}