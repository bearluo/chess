-- customBoardScene.lua
-- Author LeoLi 
-- Date   2015/10
-- Update 2016/7/28
require(MODEL_PATH.."room/roomScene");
require("chess/util/statisticsManager");

CustomBoardScene = class(RoomScene);
CustomBoardScene.FULL = 1;
CustomBoardScene.CUSTOM = 2;
CustomBoardScene.BOTTOM_ANIM_TIME  = 300;
CustomBoardScene.SHOW_ANIM_TIME    = 400;
CustomBoardScene.HIDE_ANIM_TIME    = 200;
CustomBoardScene.LIRO_ANIM_TIME    = 300;
CustomBoardScene.LORI_ANIM_TIME    = 400;
CustomBoardScene.FADEIN_ANIM_TIME  = 400;
CustomBoardScene.FADEOUT_ANIM_TIME = 400;

CustomBoardScene.s_controls = 
{
    back_btn                = 1;
    start_btn               = 2;
}

CustomBoardScene.s_cmds = 
{

}

CustomBoardScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = CustomBoardScene.s_controls;
    self.m_chess_box = {};
    self.m_boxChesses = {};
    self.m_chessSize = 50.7;
    self.m_clear_btn_press = true;
    self.m_history_chesses = {};
    self:initViews();
    self.m_upUser = UserInfo.getInstance();
    self.m_downUser = UserInfo.getInstance();
    self.m_downUser:setFlag(FLAG_RED);
end 

CustomBoardScene.resume = function(self)
    ChessScene.resume(self)
end;

CustomBoardScene.pause = function(self)
	ChessScene.pause(self);
end 

CustomBoardScene.dtor = function(self)
    self.m_board:setBoardType(nil);
    ChatMessageAnim.deleteAll();
end 

------------------------------- function -------------------------------
CustomBoardScene.onBack = function(self)
    if not self.m_isStartGame then 
        self:requestCtrlCmd(CustomBoardController.s_cmds.onBack);
    else
        if not self.m_choice_dialog then
            self.m_choice_dialog = new(ChioceDialog);
        end;
        self.m_choice_dialog:setMode(ChioceDialog.MODE_SURE,"确定","取消");
        self.m_choice_dialog:setMessage("退出后棋局进度不会保存，确定退出吗？");
        self.m_choice_dialog:setPositiveListener(self,function() 
                self:requestCtrlCmd(CustomBoardController.s_cmds.onBack);
            end
        );
        self.m_choice_dialog:show();        
    end;
end;

CustomBoardScene.frontviewbackBtnClick = function(self)
    if not self.m_isStartGame then 
        self:requestCtrlCmd(CustomBoardController.s_cmds.onBack);
    end
end

CustomBoardScene.initViews = function(self)
    -- title
    self.m_title_view = self.m_root:getChildByName("title_view");
        -- back_btn
        self.m_back_btn = self.m_title_view:getChildByName("back_btn");
        self.m_back_btn:setTransparency(0.6);
        -- room_time
        self.m_room_time_text = self.m_title_view:getChildByName("room_time_bg"):getChildByName("room_time");
        -- action_view(撤销/菜单/开始)
        self.m_title_action_view = self.m_title_view:getChildByName("action_view");
        -- 撤销btn
        self.m_restore_btn = self.m_title_action_view:getChildByName("restore_btn");
        self.m_restore_btn:setOnClick(self,self.restoreBtnClick);
        self:setBtnEnable(self.m_restore_btn,false);
        -- 菜单
        self.m_menu_btn = self.m_title_action_view:getChildByName("menu_btn");
        self.m_menu_btn:setOnClick(self,self.switchMenu);
        self.m_menu_content = self.m_title_action_view:getChildByName("menu_bg");
        self.m_menu_content:setLevel(999);
        self.m_menu_content:setEventTouch(self,function()end);
            -- 铺满
            self.m_put_all_btn = self.m_menu_content:getChildByName("full_btn");
            self.m_put_all_btn:setOnClick(self,self.pullAllBtnClick);
            -- 清空
            self.m_clear_all_btn = self.m_menu_content:getChildByName("clear_all_btn");
            self.m_clear_all_btn:setOnClick(self,self.clearAllBtnClick);
        -- 开始
        self.m_start_btn = self.m_title_action_view:getChildByName("start_btn");
        self.m_start_btn:setOnClick(self,self.startBtnClick);
    -- font_view
    self.m_front_view = self.m_root:getChildByName("front_view");
    self.m_front_view:setVisible(true);
        self.m_front_bg = self.m_front_view:getChildByName("front_bg");
        self.m_front_bg:setEventTouch(self, function()end);
        self.m_front_bg:setTransparency(0.6);
        -- 满子开始btn
        self.m_full_start_btn = self.m_front_view:getChildByName("full_start_btn");
        self.m_full_start_btn:setOnClick(self,self.fullBtnClick);
        -- 自定义棋局btn
        self.m_custom_btn = self.m_front_view:getChildByName("custom_btn");
        self.m_custom_btn:setOnClick(self,self.customBtnClick);
     self.m_frontviewback_btn = self.m_front_view:getChildByName("frontviewback_btn");
     self.m_frontviewback_btn:setOnClick(self,self.frontviewbackBtnClick);
     self.m_frontviewback_btn:setTransparency(0.8);

    -- board
    self.m_content_view = self.m_root:getChildByName("content_view");
    self.m_board_view = self.m_content_view:getChildByName("chess_board_view");
    local w, h = self.m_board_view:getSize();
    self.m_board = new(Board,w,h,self,nil,BOARD_TYPE_CUSTOM);
    self.m_board_view:addChild(self.m_board);
    self.m_board:newgame(Board.MODE_RED);
    -- bottom_view
    self.m_bottom_view = self.m_root:getChildByName("bottom_view");
    self.m_chess_box_view = self.m_bottom_view:getChildByName("chess_box_view");
    --红棋
    self.m_chess_box["rpawn"] = self.m_chess_box_view:getChildByName("chess_rpawn");
    self.m_chess_box["rcannon"] = self.m_chess_box_view:getChildByName("chess_rcannon");
    self.m_chess_box["rrook"] = self.m_chess_box_view:getChildByName("chess_rrook");
    self.m_chess_box["rhorse"] = self.m_chess_box_view:getChildByName("chess_rhorse");
    self.m_chess_box["relephant"] = self.m_chess_box_view:getChildByName("chess_relephant");
    self.m_chess_box["rbishop"] = self.m_chess_box_view:getChildByName("chess_rbishop");
    --黑棋
    self.m_chess_box["bpawn"] = self.m_chess_box_view:getChildByName("chess_bpawn");
    self.m_chess_box["bcannon"] = self.m_chess_box_view:getChildByName("chess_bcannon");
    self.m_chess_box["brook"] = self.m_chess_box_view:getChildByName("chess_brook");
    self.m_chess_box["bhorse"] = self.m_chess_box_view:getChildByName("chess_bhorse");
    self.m_chess_box["belephant"] = self.m_chess_box_view:getChildByName("chess_belephant");
    self.m_chess_box["bbishop"] = self.m_chess_box_view:getChildByName("chess_bbishop");

    -- bottom_action_view
    self.m_bottom_action_view = self.m_bottom_view:getChildByName("action_view");
    -- 重来
    self.m_reStart_btn = self.m_bottom_action_view:getChildByName("restart_btn");
    self.m_reStart_btn:setOnClick(self,self.restartBtnClick);
    -- 悔棋
    self.m_undo_btn = self.m_bottom_action_view:getChildByName("undo_btn");
    self.m_undo_btn:setOnClick(self,self.undoBtnClick);
    self:board2ChessBox();
    self:startTime();
end;

-- 定时器
CustomBoardScene.startTime = function(self)
	self:stopTime();
	self.m_timeAnim = new(AnimInt,kAnimLoop,0,1,1000,0);
	self.m_timeAnim:setDebugName("Room.startTime.m_timeAnim");
	self.m_timeAnim:setEvent(self,self.timeRun);
end

-- 定时器
CustomBoardScene.stopTime = function(self)
	if self.m_timeAnim then
		delete(self.m_timeAnim);
		self.m_timeAnim = nil;
	end
end

-- 定时器
CustomBoardScene.timeRun = function(self)
	local t = os.date("*t");
	local time = string.format("%02d:%02d",t.hour,t.min);
	if t.sec%2 == 1 then
		time = string.format("%02d %02d",t.hour,t.min);
	end
	self.m_room_time_text:setText(time);
end

-- 满子按钮
CustomBoardScene.fullBtnClick = function(self)
    self:chessBox2Board();
    self:startBtnClick();
    self.m_dapu_type = CustomBoardScene.FULL;
    self.m_front_view:setVisible(false);
    local way = "all"
    StatisticsManager.getInstance():onCountCustomBoard(way);
end;

-- 自定义按钮
CustomBoardScene.customBtnClick = function(self)
    self:board2ChessBox();
    self.m_dapu_type = CustomBoardScene.CUSTOM;
    self.m_front_view:setVisible(false);
    self.m_board:setBoardType(BOARD_TYPE_CUSTOM);
    local way = "user"
    StatisticsManager.getInstance():onCountCustomBoard(way);
end;

CustomBoardScene.beforeStartChess = function(self)
    self:leftInRightOut(self.m_chess_box_view,self.m_bottom_action_view);
    self:setBtnEnable(self.m_start_btn,true);
    self:setBtnEnable(self.m_menu_btn,true);
    self:setBtnEnable(self.m_restore_btn,true);    
end;

CustomBoardScene.restoreBtnClick = function(self)
    self:backByHistory();
end;

-- 菜单切换
CustomBoardScene.switchMenu = function(self)
    self.m_menu_content:setVisible(not self.m_menu_content:getVisible());
end;

-- 铺满
CustomBoardScene.pullAllBtnClick = function(self)
    self:chessBox2Board();
    self:switchMenu();
    ChatMessageAnim.play(self,3,"双击棋盘棋子会回到棋盒中哦");
end;

-- 清空
CustomBoardScene.clearAllBtnClick = function(self)
    self:board2ChessBox();
    self:switchMenu();    
end;

-- 开始
CustomBoardScene.startBtnClick = function(self)
    if self:onStartBtnClick() then
        self:leftOutRightIn(self.m_chess_box_view,self.m_bottom_action_view);
        self:setBtnEnable(self.m_start_btn,false);
        self:setBtnEnable(self.m_menu_btn,false);
        self:setBtnEnable(self.m_restore_btn,false);
        self.m_dapu_start_time = os.time();
    end;
end;

-- 重来
CustomBoardScene.restartBtnClick = function(self)
    -- 重置棋盘
    self:resetChessBoard();
    -- 棋子都回棋盒
    self:board2ChessBox();
    -- 加载最初的棋局
    self.m_board.m_chesses = ToolKit.copyTable(self.m_back_initChesses);
    for i = 1, 90 do
        if self.m_board.m_chesses[i] ~= 0 then
            if self.m_board.m_chesses[i].m_pc ~= 205 and self.m_board.m_chesses[i].m_pc ~= 105 then
                local sq = self.m_board.m_chesses[i].m_defaultSq;
                local x, y = self.m_board:getXYFromSquare(sq);
                self.m_board.m_chesses[i]:setPos(x, y);
                self:chessInBox2Board(self.m_board.m_chesses[i]);
                self.m_board:addChild(self.m_board.m_chesses[i]);
            end;
        end;
    end;
    self.m_board.pos:fromFen(self.m_fen_str);
    self.m_board:ready(self.m_chess_map);
end;

CustomBoardScene.undoBtnClick = function(self)
    if self.m_board.pos.moveNum > 1 then
        self.m_board:undoMove();
    else
        ChessToastManager.getInstance():showSingle("无棋可悔啦");           
    end;
end;

CustomBoardScene.initBoardSetting = function(self)
    
end;

CustomBoardScene.refreshChessNum = function(self, chess_view,refreshType)
    local chess_num = chess_view:getChildByName("num"):getChildByName("num_txt");
    if refreshType == 1 then -- 棋子回棋盒
        chess_num.int_num = (chess_num.int_num or 0) + 1;
    elseif refreshType == 2 then -- 棋子回棋盘
        chess_num.int_num = (chess_num.int_num or 0) - 1;
    end;
    if chess_num.int_num >= 1 and chess_num.int_num <= 5 then 
        chess_num:setText(chess_num.int_num);
    else
        chess_num:setText(0);
    end;    
end;

-- 选中的棋子放回到棋盒
CustomBoardScene.pc2ChessBox = function(self, pc)
    if not pc then return end;
    pc:setPos(0,0);
    pc:setEventTouch(pc, function(...) 
        self:onChessViewTouch(...)
        pc.onTouch(...);
        self.m_board:clearSelect();
    end);
    local chess_view = self.m_chess_box[drawable_resource_id[pc.m_pc]];
    if chess_view then
        chess_view:addChild(pc);
        self:refreshChessNum(chess_view,1)
        table.insert(self.m_boxChesses,pc);
    end;
end;

-- 棋盒棋子回到棋盘
CustomBoardScene.chessInBox2Board = function(self, chess)
    for i = 1, #self.m_boxChesses do
        if chess == self.m_boxChesses[i] then
            self.m_boxChesses[i]:setEventTouch(nil, nil);
            local chess_view = self.m_chess_box[drawable_resource_id[chess.m_pc]]
            chess_view:removeChild(self.m_boxChesses[i]);
            self:refreshChessNum(chess_view,2)
            table.remove(self.m_boxChesses,i);
        end;
    end;
end;

-- 摆满（所有棋盒棋子回到棋盘）
CustomBoardScene.chessBox2Board = function(self)
    self.m_back_boardSquares = ToolKit.copyTable(self.m_board.pos.squares);
    self.m_back_boardChesses = ToolKit.copyTable(self.m_board.m_chesses);
    self.m_backBoxChesses = ToolKit.copyTable(self.m_boxChesses);
	for sq = 1 ,90 do
		local pc = red_down_game90[sq] + 0;
		self.m_board.m_chesses[sq] = pc;
		if pc ~= nil and pc > 0 then
			local sq_ = self.m_board:flip90(sq);
			local chess = self.m_board:getChess(pc);
            self:chessInBox2Board(chess);
			local x = self.m_board:getX90(sq_);
			local y = self.m_board:getY90(sq_);
			self.m_board.m_chesses[sq] = chess;
            self.m_board:addChild(chess);
            chess:setPos(x,y);
        end;
	end    
    self.m_board.pos:fromFen(Postion.STARTUP_FEN[1]);
    if not self.m_isStartGame then
        self:chessesChange(ToolKit.copyTable(self.m_board.m_chesses));
    end;
end;

-- 清空（所有棋盘棋子回到棋盒）
CustomBoardScene.board2ChessBox = function(self)
    self.m_back_boardSquares = ToolKit.copyTable(self.m_board.pos.squares);
    self.m_back_boardChesses = ToolKit.copyTable(self.m_board.m_chesses);
    for i = 1, 90 do
        if self.m_board.m_chesses[i] ~= 0 then
            if self.m_board.m_chesses[i].m_pc ~= 205 and self.m_board.m_chesses[i].m_pc ~= 105 then
                local x, y = self.m_board.m_chesses[i]:getPos();
                local sq = self.m_board:getSquareFromXY(x, y);
                self.m_board.m_chesses[i].m_defaultSq = sq;
                self.m_board.m_chesses[i].m_defaultPc = self.m_board.pos.squares[sq];
                self:pc2ChessBox(self.m_board.m_chesses[i]);   
                self.m_board:clearChess(i, sq);
            end;
        end;
    end;
    if not self.m_isStartGame then
        self:chessesChange(ToolKit.copyTable(self.m_board.m_chesses));
    end;
end;

-- 能否开局
CustomBoardScene.isCanStartGame = function(self)
    local message = "";
    -- 如果将帅对脸则不能开局
    if self:isFace() then 
        message = "将帅对脸，不符合规则";
        ChessToastManager.getInstance():showSingle(message);
        return false;
    end
    -- 红方困毙 不能开局
    if self.m_board:isDeath(Board.MODE_RED) then 
        message = "红方困毙，不符合规则";
        ChessToastManager.getInstance():showSingle(message);
        return false;
    end

    -- 红方方处于被将军 不能开局
    if self.m_board:isChecked(Board.MODE_RED) then 
        message = "红方处于被将军，不符合规则";
        ChessToastManager.getInstance():showSingle(message);
        return false;
    end

    -- 黑方处于被将军 不能开局
    if self.m_board:isChecked(Board.MODE_BLACK) then 
        message = "黑方处于被将军，不符合规则";
        ChessToastManager.getInstance():showSingle(message);
        return false;
    end

    -- 判断红方是否只有老帅
    if self:isRedOnlyKing() then 
        message = "红方不能只有帅，不符合规则";
        ChessToastManager.getInstance():showSingle(message);
        return false;
    end
    return true;
end;

-- 判断红方是否只有老将
CustomBoardScene.isRedOnlyKing = function(self)
    local cnt = 0;
    -- 判断红方棋子数
    for i = 1, 90 do
        if self.m_board.m_chesses[i] and self.m_board.m_chesses[i] ~= 0 
            and type(self.m_board.m_chesses[i]) == "table" and self.m_board.m_chesses[i].m_pc 
            and self.m_board.m_chesses[i].m_pc >= R_BEGIN and self.m_board.m_chesses[i].m_pc <= R_END then
            cnt = cnt + 1;
        end
    end
    if cnt > 1 then 
        return false;
    else
        return true;
    end
end

-- 将帅对脸
CustomBoardScene.isFace = function(self)
    -- 如果将帅对脸则不能开局
    local bKing = nil;
    local rKing = nil;
    for i = 1, 90 do
        if self.m_board.m_chesses[i] ~= 0 then
            if self.m_board.m_chesses[i].m_pc == 205 then
                bKing = self.m_board.m_chesses[i];
            elseif self.m_board.m_chesses[i].m_pc == 105 then
                rKing = self.m_board.m_chesses[i];
            end;
        end;
    end;
    local bC, bR = self.m_board:getCRfromXY(bKing:getPos());
    local rC, rR = self.m_board:getCRfromXY(rKing:getPos());
    local bSq,bSq90 = self.m_board:getSqfromCR(bC,bR);
    local rSq,rSq90 = self.m_board:getSqfromCR(rC,rR);
    -- 将帅同列
    if bC == rC then
        for i = bR + 1, rR - 1 do
            local index = 9 * i + bC + 1;
            if self.m_board.m_chesses[index] ~= 0 then
                return false;
            end;
        end; 
        return true;
    else
        return false;
    end;
end;

-- 开局按钮
CustomBoardScene.onStartBtnClick = function(self)
    -- 能否开局
    if not self:isCanStartGame() then return end; 
    -- 是否开局
    self.m_isStartGame = true;
    self.m_fen_str = self:initEndgateFenstr();
    -- 重置棋盘
    self:resetChessBoard();
    -- 保存棋局初始局面
    self.m_back_initChesses = ToolKit.copyTable(self.m_board.m_chesses);
    -- 打谱
    self.m_board:setBoardType(BOARD_TYPE_START);
    return true;
end;

CustomBoardScene.initEndgateFenstr = function(self)
    self.m_chess_map = self.m_board:to_chess_map();
    local fen_str = self.m_board.toFen(self.m_chess_map,true);
    return fen_str;
    -- local pos = ToolKit.copyTable(self.m_board.pos);
    -- local pos1 = self.m_board.pos:fromFen(fen_str);
    --Board.runEngine--line position fen 3ak4/4a4/9/7N1/9/9/9/9/9/5K3 r moves h6f5(马到成功)
end;

CustomBoardScene.resetChessBoard = function(self)
    self.m_board:hiddenHints();
	self.m_board:hiddenMovePath();
	self.m_board:hiddenHintPath();
    self.m_board:clearSelect();
    self.m_board:gameStart();
    -- mvList和moveNum都比正常多一步
    -- moveNum是#mvList
    -- =1是由于重摆没有调Postion.setIrrev方法;
    -- 归结到底是Postion.isMate走了一步棋，又悔了一步棋导致;
    -- 后续优化...
    self.m_board.pos.mvList = {};
    self.m_board.pos.moveNum = 1;
    self.m_board.pos.sdPlayer = 0;    
end;

CustomBoardScene.initEngateEngine = function(self, fen_str)
    self.m_board:setEngineBegin(fen_str);
end;

CustomBoardScene.setDieChess = function(self,dieChess)

end

CustomBoardScene.chessMove = function(self,data)
    local mv = self.m_board:data2mv(data);
    self.m_board:chessMove(mv)
    self.m_board:clearSelect();
end;

CustomBoardScene.setBoradCode = function(self,code, endType)
    self.m_end_flag = code;
    self.m_end_type = endType;
end

CustomBoardScene.showResultDialog = function(self)
    self:schedule_once(self.showResultDialogDelay,500);
end;

CustomBoardScene.showResultDialogDelay = function(self)
    Log.i("CustomBoardScene.showResultDialogDelay");
    self.m_dapu_end_time = os.time();
    self.m_dapu_use_time = self:formatTime(self.m_dapu_end_time - self.m_dapu_start_time);
    self.m_dapu_use_step = (self.m_board.pos.moveNum > 1 and (self.m_board.pos.moveNum - 1) or 0).."步";
    self:showAccountDialog();
end;

CustomBoardScene.formatTime = function(self, time)
    if not time or not tonumber(time) then return end;
    if time >= 0 and time < 60 then
        return (time > 0 and (time.."秒") or "");
    elseif time >= 60 and time < 3600  then
        local minute = math.floor(time / 60); 
        local second = time % 60;
        return (minute > 0 and (minute.."分钟") or "")..self:formatTime(second);
    elseif time >= 3600 and time < 24 * 3600  then
        local hour = math.floor(time / 3600);
        local minute = time % 3600;
        return (hour > 0 and (hour.."小时") or "") ..self:formatTime(minute);
    elseif time >= 24 * 3600 and time < 24 * 3600 * 365 then
        local day = math.floor(time / (24 * 3600));
        local hour = time % (24 * 3600);
        return (day > 0 and (day.."天") or "") ..self:formatTime(hour);
    end;
end;

require("dialog/account_dialog");
CustomBoardScene.showAccountDialog = function(self)
    if not self.m_account_dialog then
        self.m_account_dialog = new(AccountDialog, self);
    end;
    local var = {[1] = false, [2] = 3,[3]={[1] = self.m_dapu_use_time,[2]= self.m_dapu_use_step}};
    self.m_account_dialog:show(self,self.m_end_flag,var,RoomConfig.ROOM_TYPE_DAPU_ROOM);
end;

CustomBoardScene.saveChess = function(self)
    return self:saveChessData();
end

CustomBoardScene.saveChessData = function(self)
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
    mvData.fileName = "单机打谱";
    -- 以前单机或残局mid=0;现mid=-1,为了解决断网玩单机和残局,在复盘最近对局内玩家本身mid=0和AI的mid相同，名字和棋盘不对的bug.
    -- 当连接网络之后，此时用户已经登录，收藏到我的收藏，php保存mid（-1）保存为0，所以不影响线上。
    mvData.red_mid = self.m_downUser:getUid();
    mvData.black_mid = self.m_downUser:getUid();
    mvData.down_user = self.m_downUser:getUid();
    mvData.red_mnick = self.m_downUser:getName();
    mvData.black_mnick = self.m_downUser:getName()
    mvData.red_icon_url = self.m_downUser:getIcon();
    mvData.black_icon_url = self.m_downUser:getIcon();
    mvData.red_icon_type = self.m_downUser:getIconType();
    mvData.black_icon_type = self.m_downUser:getIconType();
    mvData.red_level = 10 - self.m_downUser:getDanGradingLevel();
    mvData.black_level = 10 - self.m_downUser:getDanGradingLevel();
    mvData.red_score = self.m_downUser:getScore();
    mvData.black_score = self.m_downUser:getScore();
    mvData.win_flag = self.m_end_flag;
    mvData.end_type = self.m_end_type;
    mvData.flag = FLAG_RED;
    mvData.manual_type = "4";
    mvData.start_fen = self.m_fen_str;
    mvData.chessString = GameCacheData.getInstance():getString(GameCacheData.DAPU_LAST_CHESS_STR,GameCacheData.NULL);
    mvData.end_fen = self.m_board.toFen(self.m_board:to_chess_map(),true);
    mvData.move_list = table.concat(self.m_board:to_mvList(),GameCacheData.chess_data_key_split);
    mvData.createrName = "";
    mvData.is_collect = 0;-- 是否收藏
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

CustomBoardScene.restart_action = function(self)
    if self.m_dapu_type == CustomBoardScene.FULL then
        self:fullBtnClick();
    elseif self.m_dapu_type == CustomBoardScene.CUSTOM then
        self.m_board:setBoardType(BOARD_TYPE_CUSTOM);
        self:beforeStartChess();
        self:restartBtnClick();
    end;
end;

CustomBoardScene.reSelect = function(self)
    self:board2ChessBox();
    self:resetChessBoard();
    self:leftInRightOut(self.m_front_view);
    self:leftInRightOut(self.m_chess_box_view,self.m_bottom_action_view);
    self:setBtnEnable(self.m_start_btn,true);
    self:setBtnEnable(self.m_menu_btn,true);
    self:setBtnEnable(self.m_restore_btn,true);
end;

CustomBoardScene.exitRoom = function(self)
    self:requestCtrlCmd(CustomBoardController.s_cmds.onBack);
end;

-- 棋盒棋子滑动到棋盘上(onChessViewTouch)
CustomBoardScene.onChessViewTouch = function(self,pc,finger_action,x,y,drawing_id_first,drawing_id_current)
   local chess_view = self.m_chess_box[drawable_resource_id[pc.m_pc]];
   if not chess_view then return end;
   if finger_action == kFingerDown then
        chess_view:setLevel(1);
        self.m_downX = x;
		self.m_downY = y;
        self.m_orignX = x;
        self.m_orignY = y;
   elseif finger_action == kFingerUp then
        chess_view:setLevel(0);
        x, y = self:convertSurfacePointToView(x,y);
        -- 进入board地界
        local left,top = self.m_content_view:getUnalignPos();
        local w,h = self.m_content_view:getSize();
        if ( x > left and x <= left+w ) and (y > top and y < top + h ) then  -- 624 = 80 + 544(棋盘高)··
            x ,y = self.m_board:convertSurfacePointToView(x,y);
            local upC,upR = self.m_board:getCRfromXY(x,y);
            local sq_,sq90_ = self.m_board:getSqfromCR(upC,upR);
            self.m_board:setChess2Board(upC, upR, sq_, sq90_);
            -- 添加摆棋历史记录
            local chesses = {};
            for i,v in pairs(self.m_board:getChesses()) do
                chesses[i] = v;
            end
            self:chessesChange(chesses);
        else
            pc:setPos(0,0);
        end;
        
   elseif finger_action == kFingerMove then
        if not pc:isPopState() then return end;
		local diffX = x - self.m_downX;
		local diffY = y - self.m_downY;
        local origX, origY = pc:getPos();
		pc:setPos(origX + diffX,origY + diffY);
		print_string("pc move x =  " .. origX + diffX .. "y = " .. origX + diffY);
        self.m_downX,self.m_downY = x,y;    
   end;
end;

CustomBoardScene.chessesChange = function(self,chesses)
    if type(chesses) == 'table' then
        local pre_chesses = self.m_history_chesses[#self.m_history_chesses];
        if pre_chesses then
            for pc,chess in pairs(chesses) do
                if pre_chesses[pc] ~= chess then
                    table.insert(self.m_history_chesses,chesses);
                    break;
                end
            end
        else
            table.insert(self.m_history_chesses,chesses);
        end
    end
    if self.m_history_chesses and #self.m_history_chesses > 1 then
        self:setBtnEnable(self.m_restore_btn, true);
    end;
end

CustomBoardScene.backByHistory = function(self)
    if self.m_history_chesses and #self.m_history_chesses > 1 then
        local now_chesses = table.remove(self.m_history_chesses);
        local pre_chesses = self.m_history_chesses[#self.m_history_chesses];
        self.m_board:setChesses(pre_chesses);
        for i = 1, #self.m_boxChesses do
            self.m_boxChesses[i]:normal();
        end
        if self.m_history_chesses and #self.m_history_chesses == 1 then
            self:setBtnEnable(self.m_restore_btn, false);
        end;
    end
end

------------------------------------ common --------------------------------------
CustomBoardScene.setBtnEnable = function(self, btn, flag)
    btn:setPickable(flag);
    btn:setGray(not flag);
end;

-- 定时器一次
CustomBoardScene.schedule_once = function(self,func,time,a,b,c)
    local anim = new(AnimInt, kAnimNormal, 0,1,time,0);
    if anim then
        anim:setEvent(self, function() 
                func(self,a,b,c);
                delete(anim);
                anim = nil;
            end
        );
    end;    
end;

-- 左出右进动画
CustomBoardScene.leftOutRightIn = function(self,leftView, rightView,callBackFun)
    leftView:setVisible(true);
    local leftW,leftH = leftView:getSize();
    -- leftSlide
    local leftAnim = leftView:addPropTranslate(0,kAnimNormal,CustomBoardScene.LORI_ANIM_TIME,-1,0,-leftW,nil,nil);
    if not leftAnim then return end;
    leftAnim:setEvent(nil, function() 
        leftView:removeProp(0);
    end);
    -- leftTransparency
    local leftTransparency = leftView:addPropTransparency(1,kAnimNormal,CustomBoardScene.LORI_ANIM_TIME,0,1,0);
    if not leftTransparency then return end;
    leftTransparency:setEvent(nil, function() 
        leftView:setVisible(false);
        leftView:removeProp(1);
    end);
    -- rightSlide
    rightView:setVisible(true);
    local rightW,rightH = rightView:getSize();
    local rightAnim = rightView:addPropTranslate(0,kAnimNormal,CustomBoardScene.LORI_ANIM_TIME,0,rightW,0,nil,nil);
    if not rightAnim then return end;
    rightAnim:setEvent(nil, function() 
        rightView:removeProp(0);
        if callBackFun then
            callBackFun(self);
        end;
    end);
    -- rightTransparency
    local rightTransparency = rightView:addPropTransparency(1,kAnimNormal,CustomBoardScene.LORI_ANIM_TIME,0,0,1);
    if not rightTransparency then return end;
    rightTransparency:setEvent(nil, function() 
        rightView:removeProp(1);
    end);
end;

-- 左进右出动画
CustomBoardScene.leftInRightOut = function(self,leftView, rightView,callBackFun)
    -- leftSlide
    if leftView then 
        leftView:setVisible(true);
        local leftW,leftH = leftView:getSize();
        local leftAnim = leftView:addPropTranslate(1,kAnimNormal,CustomBoardScene.LIRO_ANIM_TIME,0,-leftW,0,nil,nil);
        if not leftAnim then return end;
        leftAnim:setEvent(nil, function() 
             leftView:removeProp(1);  
             if callBackFun then
                callBackFun(self);
             end;     
        end)
        -- leftTransparency
        local leftTransparency = leftView:addPropTransparency(2,kAnimNormal,CustomBoardScene.LORI_ANIM_TIME,0,0,1);
        if not leftTransparency then return end;
        leftTransparency:setEvent(nil, function() 
            leftView:removeProp(2);
        end);
    end;
    -- rightSlide
    if rightView then 
        rightView:setVisible(true);
        local rightW,rightH = rightView:getSize();
        local rightAnim = rightView:addPropTranslate(1,kAnimNormal,CustomBoardScene.LIRO_ANIM_TIME,0,0,rightW,nil,nil);
        if not rightAnim then return end;
        rightAnim:setEvent(nil, function() 
            rightView:removeProp(1);      
        end);
        -- rightTransparency
        local rightTransparency = rightView:addPropTransparency(2,kAnimNormal,CustomBoardScene.LORI_ANIM_TIME,0,0.05,0);
        if not rightTransparency then return end;
        rightTransparency:setEvent(nil, function() 
            rightView:setVisible(false);
            rightView:removeProp(2);
        end);
    end;
end;

-- 淡入淡出动画
CustomBoardScene.fadeInAndOut = function(self, fadeInView, fadeOutView)
    if fadeInView then
        fadeInView:setVisible(true); 
        local fadeInViewW,fadeInViewH = fadeInView:getSize();
        local up_anim = fadeInView:addPropTranslate(1,kAnimNormal,CustomBoardScene.FADEIN_ANIM_TIME,0,0,0,fadeInViewH,0);
        if not up_anim then return end;
        up_anim:setEvent(nil, function() 
            fadeInView:removeProp(1);      
        end);
        local up_fade_anim = fadeInView:addPropTransparency(2,kAnimNormal,CustomBoardScene.FADEIN_ANIM_TIME,0,0,1);
        if not up_fade_anim then return end;
        up_fade_anim:setEvent(nil, function() 
            fadeInView:removeProp(2);      
        end);
    end;

    if fadeOutView then
        fadeOutView:setVisible(true);
        local fadeOutViewW,fadeOutViewH = fadeOutView:getSize();
        local down_anim = fadeOutView:addPropTranslate(1,kAnimNormal,CustomBoardScene.FADEOUT_ANIM_TIME,0,0,0,0,fadeOutViewH);
        if not down_anim then return end;
        down_anim:setEvent(nil, function()
            fadeOutView:removeProp(1);      
        end);
        local down_fade_anim = fadeOutView:addPropTransparency(2,kAnimNormal,CustomBoardScene.FADEOUT_ANIM_TIME,0,1,0);
        if not down_fade_anim then return end;
        down_fade_anim:setEvent(nil, function() 
            fadeOutView:removeProp(2);  
            fadeOutView:setVisible(false);    
        end);
    end;
end;

------------------------------- config ---------------------------------
CustomBoardScene.s_controlConfig = 
{
    [CustomBoardScene.s_controls.back_btn]              = {"title_view","back_btn"};
    [CustomBoardScene.s_controls.start_btn]             = {"bottom_view","chess_box_view","chess_start"};
};

CustomBoardScene.s_controlFuncMap =
{
    [CustomBoardScene.s_controls.back_btn]              = CustomBoardScene.onBack;
    [CustomBoardScene.s_controls.start_btn]             = CustomBoardScene.onStartBtnClick;
};


CustomBoardScene.s_cmdConfig =
{
}