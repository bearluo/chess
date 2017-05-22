require(MODEL_PATH .. "room/roomController")

ConsoleRoomController = class(RoomController)



ConsoleRoomController.s_cmds = 
{	
    share_action        = 1;
    leave_action        = 2;
    switch_menu         = 3;
    start_game          = 4;
    retry_action        = 5;
    event_state         = 6;
    undo_action         = 7;
    get_soul            = 8;
    chess_move          = 9;
    upload_console2php  = 10;
    upload_progress     = 11;

};

ConsoleRoomController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
    self.m_room  = self.m_view;
end

ConsoleRoomController.resume = function(self)
    RoomController.resume(self);
end;

ConsoleRoomController.pause = function(self)
    RoomController.pause(self);
end;

ConsoleRoomController.dtor = function(self)
    
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
	share_img_msg("egame_share");
end;

ConsoleRoomController.onLeaveAction = function(self)

    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);

end;

ConsoleRoomController.onEventStat = function(self,event_id)
	local level = UserInfo.getInstance():getPlayingLevel();
	local event_info = event_id .. ","  ..  "level_" .. level;
	on_event_stat(event_info); --事件统计
end


--ConsoleRoomController.saveChess = function(self)

--	if UserInfo.getInstance():getDapuEnable() == false then
--		self:buyDapu();
--		return;
--	end
--    if not self.m_chioce_dialog then
--        require("dialog/chioce_dialog")
--        self.m_chioce_dialog = new(ChioceDialog);
--    end;
--	if self:saveChessData() == true then
--		local message = "棋局已自动保存到最近对战";
--		ShowMessageAnim.play(self.m_account_dialog,message);
--	else
----		local message = "本地棋库已达到"..UserInfo.getInstance():getSaveChessLimit().."条上限，您可以覆盖原棋谱保存新的棋谱，请问是否要继续保存新棋谱？";
----		self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE);
----		self.m_chioce_dialog:setMessage(message);
----		self.m_chioce_dialog:setNegativeListener(self,self.cancelSaveMVList);
----		self.m_chioce_dialog:setPositiveListener(self,self.toDapuPage);
----		self.m_chioce_dialog:show();
--	end

--end;

ConsoleRoomController.buyDapu = function(self)
	self.m_payInterface = PayUtil.getPayInstance(PayUtil.s_payType.Exchange);
	self.m_pay_dialog = self.m_payInterface:buy(nil,CONSOLE_ROOM_DAPU);
end



ConsoleRoomController.toDapuPage = function(self)
	ToolKit.removeAllTipsDialog(); 
	StateMachine.getInstance():pushState(States.dapu,StateMachine.STYPE_CUSTOM_WAIT);
end

ConsoleRoomController.cancelSaveMVList = function(self)
	UserInfo.getInstance():setDapuDataNeedToSave(nil);
end



--ConsoleRoomController.saveChessData = function(self)
--	local uid = UserInfo.getInstance():getUid();
--	local keys = GameCacheData.getInstance():getString(GameCacheData.DAPU_KEY .. uid,"");
--    print_string("ganshaya = "..keys);
--	local keys_table = lua_string_split(keys, GameCacheData.chess_data_key_split);

--	local index = 0;
--	if keys == "" or keys == GameCacheData.NULL then
--		index = 1;
--	else
--		while index <= UserInfo.getInstance():getSaveChessLimit() do
--			index = index + 1;
--			if keys_table[index] == nil or keys_table[index] == GameCacheData.NULL then
--				break;
--			end
--		end
--	end
--	local key = "myChessDataId_"..index;
--	if keys == "" or keys == GameCacheData.NULL then
--		keys_table = {};
--	end
--	keys_table[index] = key;

--	local relt;
--	if self.m_room.m_close_flag == (self.m_model+1) then
--		relt = "获胜";
--	else
--		relt = "败北";
--	end

--	local mvData = {};
--	mvData.fileName = GameString.convert2UTF8("我的棋谱")..index;
--	mvData.time = os.date("%Y", os.time()).."-"..os.date("%m", os.time()).."-"..os.date("%d", os.time());
--	mvData.result = GameString.convert2UTF8(relt);
--	mvData.rival = GameString.convert2UTF8("对手:")..GameString.convert2UTF8(self.m_room.m_console_title:getText());
--	mvData.flag = self.m_model + 1;
--	mvData.upSex = 1;
--	mvData.downSex = UserInfo.getInstance():getSex();
--	mvData.m_game_end_type = self.m_room.m_close_flag;
--	mvData.mvStr = table.concat(self.m_board:to_mvList(),GameCacheData.chess_data_key_split);
--	local mvData_str = json.encode(mvData);

--	if index > UserInfo.getInstance():getSaveChessLimit() then
--		UserInfo.getInstance():setDapuDataNeedToSave(mvData);
--		return false;	--提示覆盖
--	end

--	print_string("mvData_str = " .. mvData_str);
--	GameCacheData.getInstance():saveString(GameCacheData.DAPU_KEY .. uid,table.concat(keys_table,GameCacheData.chess_data_key_split));
--	GameCacheData.getInstance():saveString(key .. uid,mvData_str);

--	return true;	--保存成功
--end
-- 下一关
ConsoleRoomController.loadNextGate = function(self)
    self:onStartGame();
end;

ConsoleRoomController.onStartGame = function(self)
--    StatisticsUtil.Log (StatisticsUtil.TYPE_PLAY,"console");
    local level = UserInfo.getInstance():getPlayingLevel();
    local AI_LEVEL_MAP = UserInfo.getInstance():getAILevelMap();
    print_string("PlayingLevel is -------------->"..level)
	local ai_level = AI_LEVEL_MAP[level];     
--	local head_icon = ((ai_level == 6) and 5) or math.floor(ai_level%6);
--    if level == 1 or level == 2 then
--        self.head_icon = 1;
--    elseif level == 3 or level == 4 then
--        self.head_icon = 2;
--    elseif level == 5 or level == 6 then
--        self.head_icon = 3;
--    elseif level == 7 or level == 8 then
--        self.head_icon = 4;
--    elseif level == 9 or level == 10 then
--        self.head_icon = 5;
--    else
--        self.head_icon = 1;
--    end;     
    self.head_icon = level;
    self:updateView(ConsoleRoomScene.s_cmds.start_game, level, self.head_icon);
    self:setGameOver(false);
    self.m_model = User.AI_MODEL[level];
    self.m_board = self.m_room.m_board;
    self.m_startTime = os.time();--单机开始时间
    if self.m_model == Board.MODE_RED then
        self.m_room.m_my_flag = FLAG_RED;
        self.m_room.m_ai_flag = FLAG_BLACK;
    else
        self.m_room.m_my_flag = FLAG_BLACK;
        self.m_room.m_ai_flag = FLAG_RED;
    end
    --如果是来自中途单机棋局
	if UserInfo.getInstance():getJoinPlayedConsole() then
        --由于中途棋局是自己每走一步都会保存，所以下次加入都是电脑先走棋。
        --从中途棋局加入后，悔棋图标都是默认点亮的，但电脑先走棋，图标应设置为不可用。
        self:setMyTurn(false);
        self.m_board:console_synchrodata(self.m_model, ai_level, level); 
        UserInfo.getInstance():setJoinPlayedConsole(false);
    else --如果不存在中途棋局，则新开棋局。
--        local fenstr = "2bakab2/9/9/9/9/9/9/4B4/9/3AKAB2 w - - 0 1"; -- 测试双方没有进攻子力
--	    Board.resetFenPiece();
--        self.m_board:newgame(self.m_model,fenstr,self.m_board:fen2chessMap(fenstr));
        self.m_board:newgame(self.m_model);
        self:setAILevel(ai_level);
	    self:setPassLevel(level);

        self:setMyTurn(self.m_model == Board.MODE_RED);
        if  not self:isMyTurn() then
	        self:aiTurn();
        end
    end;
    local chess_map = self.m_board:to_chess_map();
    GameCacheData.getInstance():saveString(GameCacheData.DAPU_LAST_BORAD_FEN,Board.toFen(chess_map,true));
	GameCacheData.getInstance():saveString(GameCacheData.DAPU_LAST_CHESS_STR,table.concat(chess_map,MV_SPLIT));
    --新开局重置以下上报数据
    self.m_undoUseNum = 0;--悔棋使用数量
    self.m_moveSteps = 0;--移动步数

end;

ConsoleRoomController.onRetryAction = function(self)
    self:updateView(ConsoleRoomScene.s_cmds.retry_game);

end;


ConsoleRoomController.onEventState  = function(self, id)
  self:onEventStat(id);  
end;


ConsoleRoomController.onUndoAction = function(self)
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
		self:setMyTurn(false);
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
	return self.m_my_turn;
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
    self:updateView(ConsoleRoomScene.s_cmds.undo_btn_enable);

end;
ConsoleRoomController.onBoardAiUnChangeMove = function(self)
    self.m_board:console_gameover(0,ENDTYPE_UNCHANGE);
end;

ConsoleRoomController.onUploadConsole2Php = function(self,is_win)
    if not UserInfo.getInstance():isLogin() then--没有登录不上报
        return;
    end;
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

end;



ConsoleRoomController.onUploadProgress = function(self, data)
    local post_data = {};
    post_data.progress = {}
    post_data.progress["1"] = data or 1;
    self:sendHttpMsg(HttpModule.s_cmds.uploadConsoleProgress, post_data);
end;



--------------------------------board2Room Func------------------------------



ConsoleRoomController.setDieChess = function(self,dieChess)

end
--玩家走棋（触摸）
ConsoleRoomController.onChessMove = function(self,data)
	self:setMyTurn(false); --self.m_my_turn = false; --我下完棋之后轮到电脑走棋
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
    if not flag then
        return;
    end;

	if not HttpModule.explainPHPFlag(message) then
		return;
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




--------------------------------config--------------------------------------

ConsoleRoomController.s_cmdConfig = 
{
	[ConsoleRoomController.s_cmds.share_action]		    = ConsoleRoomController.onShareAction;
    [ConsoleRoomController.s_cmds.leave_action]	        = ConsoleRoomController.onLeaveAction;
--    [ConsoleRoomController.s_cmds.switch_menu]		= ConsoleRoomController.onSwitchMenu;
    [ConsoleRoomController.s_cmds.start_game]		    = ConsoleRoomController.onStartGame;
    [ConsoleRoomController.s_cmds.retry_action]		    = ConsoleRoomController.onRetryAction;
    [ConsoleRoomController.s_cmds.event_state]		    = ConsoleRoomController.onEventState;
    [ConsoleRoomController.s_cmds.undo_action]		    = ConsoleRoomController.onUndoAction;
    [ConsoleRoomController.s_cmds.get_soul]		        = ConsoleRoomController.onGetSoul;
    [ConsoleRoomController.s_cmds.chess_move]	        = ConsoleRoomController.onChessMove;
    [ConsoleRoomController.s_cmds.upload_console2php]	= ConsoleRoomController.onUploadConsole2Php;
    [ConsoleRoomController.s_cmds.upload_progress]	    = ConsoleRoomController.onUploadProgress;



}

ConsoleRoomController.s_nativeEventFuncMap = {
    [ENGINE_GUI]                            = ConsoleRoomController.engine2Gui;
    [CONSOLE_SAVE_CHESS_MOVE]               = ConsoleRoomController.onSaveConsoleProgress;
    [Board.UNLEGALMOVE]                     = ConsoleRoomController.onBoardUnlegalMove;
    [Board.AIUNLEGALMOVE]                   = ConsoleRoomController.onBoardAiUnlegalMove;
    [Board.AIMOVE]                          = ConsoleRoomController.onBoardAiMove;
    [Board.AI_UNCHANGE_MOVE]                = ConsoleRoomController.onBoardAiUnChangeMove;
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
};

ConsoleRoomController.s_httpRequestsCallBackFuncMap = CombineTables(RoomController.s_httpRequestsCallBackFuncMap,
	ConsoleRoomController.s_httpRequestsCallBackFuncMap or {});


