-- Scene界面涉及逻辑比较多，后续时间充裕
-- 再把逻辑迁移到Controller内
require(BASE_PATH.."chessScene");


CustomBoardScene = class(ChessScene);
CustomBoardScene.BOTTOM_ANIM_TIME = 300;
CustomBoardScene.s_controls = 
{
    back_btn                = 1;
    clear_putall_btn        = 2;
    restore_btn             = 3;
    start_btn               = 4;
    recreate_btn            = 5;
    recreate_btn2           = 6;
    share_btn               = 7;
    back_step_btn           = 8;
    forward_step_btn        = 9;    
    recreate_onestep_btn    = 10;
    restore_onestep_btn     = 11;
    share_btn2              = 12;
    undo_btn                = 13;
    tips_btn                = 14;
    share_btn3              = 15;
}

CustomBoardScene.s_cmds = 
{
    engine2Gui              = 1;
    board_ai_move           = 2;
    updateView              = 3;
    use_tip                 = 4;
    use_undoMove            = 5;
    tip_enable              = 6;
}

CustomBoardScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = CustomBoardScene.s_controls;
    self.m_chess_box = {};
    self.m_boxChesses = {};
    self.m_chessSize = 50.7;
    self.m_clear_btn_press = true;
    self:initViews();
    
end 
CustomBoardScene.resume = function(self)
    ChessScene.resume(self);
    
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
    self:requestCtrlCmd(CustomBoardController.s_cmds.onBack);
end;




CustomBoardScene.initViews = function(self)
    -- title
    self.m_title_view = self.m_root:getChildByName("title_view");
    self.m_title_txt =  self.m_title_view:getChildByName("title_bg"):getChildByName("title"); 
    self.m_title_txt2 =  self.m_title_view:getChildByName("title_bg"):getChildByName("title2"); 
    self.m_title_txt3 =  self.m_title_view:getChildByName("title_bg"):getChildByName("title3"); 
    self.m_room_time_bg = self.m_title_view:getChildByName("room_time_bg");
    self.m_room_time_text = self.m_room_time_bg:getChildByName("room_time");
    -- board
    self.m_content_view = self.m_root:getChildByName("content_view");
    self.m_board_view = self.m_content_view:getChildByName("chess_board");
    local w, h = self.m_content_view:getSize();
    self.m_board = new(Board,w,h,self,nil,BOARD_TYPE_CUSTOM);
    self.m_content_view:addChild(self.m_board);
    self.m_board:newgame(Board.MODE_RED);
    -- 棋子移动List
    self.mvList = {};
    -- mv数量
    self.mvNum = 0;
    self.m_rootW, self.m_rootH = self:getSize();
    -- bottom_view1
    self.m_bottom_view = self.m_root:getChildByName("bottom_view");
    self.m_bottom_view:setSize(nil, self.m_rootH - 65 - 530);
    local bottomW, bottomH = self.m_bottom_view:getSize();
    self.m_chess_box_view = self.m_bottom_view:getChildByName("chess_box_view");
    self.m_chess_box_view:setPos(nil,(bottomH - 65 - 130)/2);
    self.m_share_btn = self.m_bottom_view:getChildByName("share_btn");
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
    -- buttons
    -- 清空(摆满)
    self.m_clear_putall_btn = self.m_bottom_view:getChildByName("clear_putall_btn");
    self.m_clear_putall_txt = self.m_clear_putall_btn:getChildByName("clear_putall_txt");
    self.m_clear_img = self.m_clear_putall_btn:getChildByName("clear_img");
    self.m_full_img = self.m_clear_putall_btn:getChildByName("full_img");
    -- 撤销
    self.m_restore_btn = self.m_bottom_view:getChildByName("restore_btn");
    self.m_restore_btn:setEnable(false);
    self.m_restore_txt = self.m_restore_btn:getChildByName("restore_txt");
    -- 开局
    self.m_start_btn = self.m_bottom_view:getChildByName("chess_box_view"):getChildByName("chess_start");
    self.m_start_txt = self.m_start_btn:getChildByName("start");
    -- bottom_view2
    self.m_bottom_view2 = self.m_root:getChildByName("bottom_view2");
    self.m_bottom_view2:setSize(nil, self.m_rootH - 65 - 530);
    self.m_share_btn2 = self.m_bottom_view2:getChildByName("share_btn2");
    self.m_move_slider = new(Slider, 400, 4,"common/slider_progress_bg.png","common/slider_progress.png","common/slider_normal.png",2,2,2,2);
    self.m_bottom_view2_control_view = self.m_bottom_view2:getChildByName("control_board_view");
    self.m_bottom_view2_control_view:setPos(nil,(bottomH - 65 - 130)/2);
    self.m_bottom_view2_control_view:addChild(self.m_move_slider);
    self.m_move_slider:setAlign(kAlignBottom);
    self.m_move_slider:setPos(nil,10);
    self.m_move_slider:setOnChange(self, self.onSliderMove);
    self.m_bottom_view2:setPos(self.m_rootW,nil);

    -- bottom_view3
    self.m_bottom_view3 = self.m_root:getChildByName("bottom_view3");
    self.m_bottom_view3:setSize(nil, self.m_rootH - 65 - 530);
    self.m_bottom_view3_control_view = self.m_bottom_view3:getChildByName("control_board_view");
    self.m_bottom_view3_control_view:setPos(nil,(bottomH - 65 - 130)/2);
    self.m_share_btn3 = self.m_bottom_view3:getChildByName("share_btn3");
    self.m_undo_btn = self:findViewById(self.m_ctrls.undo_btn)
    self.m_undo_txt = self.m_undo_btn:getChildByName("undo_num_bg"):getChildByName("undo_num_text");
    self.m_undo_txt:setText(UserInfo.getInstance():getUndoNum());
    self.m_tips_btn = self:findViewById(self.m_ctrls.tips_btn)
    self.m_tips_txt = self.m_tips_btn:getChildByName("tips_num_bg"):getChildByName("tips_num_text");
    self.m_tips_txt:setText(UserInfo.getInstance():getTipsNum());
    self.m_default_progress = 1;
    self.m_bottom_view3:setPos(self.m_rootW,nil);
    -- 重做此步
    self.m_recreate_onestep_btn = self.m_bottom_view2:getChildByName("recreate_onestep_btn");
    self.m_recreate_onestep_btn:setEnable(false);
    -- 撤销
    self.m_restore_onestep_btn = self.m_bottom_view2:getChildByName("restore_onestep_btn");
    self.m_restore_onestep_btn:setEnable(false);
    
    if UserInfo.getInstance():getCustomDapuType() == 0 then--打谱
        self.m_share_btn:setEnable(false);
        self.m_share_btn2:setEnable(false);
    elseif UserInfo.getInstance():getCustomDapuType() == 1 then--自定义残局
        self.m_title_txt:setVisible(false);
        self.m_title_txt2:setVisible(false);
        self.m_title_txt3:setVisible(true);
        self.m_share_btn:setEnable(true);
        self.m_share_btn3:setEnable(true);
    end;
    self:onClearPutAllBtnClick();
    self:startTime();
end;


CustomBoardScene.startTime = function(self)
	self:stopTime();
	self.m_timeAnim = new(AnimInt,kAnimLoop,0,1,1000,0);
	self.m_timeAnim:setDebugName("Room.startTime.m_timeAnim");
	self.m_timeAnim:setEvent(self,self.timeRun);

end

CustomBoardScene.stopTime = function(self)
	if self.m_timeAnim then
		delete(self.m_timeAnim);
		self.m_timeAnim = nil;
	end
end

CustomBoardScene.timeRun = function(self)
	local t = os.date("*t");

	local time = string.format("%02d:%02d",t.hour,t.min);
	if t.sec%2 == 1 then
		time = string.format("%02d %02d",t.hour,t.min);
	end

	self.m_room_time_text:setText(time);
end



CustomBoardScene.initBoardSetting = function(self)
    
end;




CustomBoardScene.initChessBox = function(self)
--    for i = 1, 12 do
--        if i == 1 then
--            for j = 1, 5 do
--                local chess = new(Chess, chess_string2const["R_PAWN"..j], self.m_chessSize);
--                self.m_chess_box[i]:addChild(chess);
--            end;
--        elseif i == 2 then
--            for j = 1, 2 do
--                local chess = new(Chess, chess_string2const["R_CANNON"..j], self.m_chessSize);
--                self.m_chess_box[i]:addChild(chess);
--            end;            
--        elseif i == 3 then
--            for j = 1, 2 do
--                local chess = new(Chess, chess_string2const["R_ROOK"..j], self.m_chessSize);
--                self.m_chess_box[i]:addChild(chess);
--            end;     
--        elseif i == 4 then
--            for j = 1, 2 do
--                local chess = new(Chess, chess_string2const["R_HORSE"..j], self.m_chessSize);
--                self.m_chess_box[i]:addChild(chess);
--            end;  
--        elseif i == 5 then
--            for j = 1, 2 do
--                local chess = new(Chess, chess_string2const["R_ELEPHANT"..j], self.m_chessSize);
--                self.m_chess_box[i]:addChild(chess);
--            end;  
--        elseif i == 6 then
--            for j = 1, 2 do
--                local chess = new(Chess, chess_string2const["R_BISHOP"..j], self.m_chessSize);
--                self.m_chess_box[i]:addChild(chess);
--            end;          
--        elseif i == 7 then
--            for j = 1, 5 do
--                local chess = new(Chess, chess_string2const["B_PAWN"..j], self.m_chessSize);
--                self.m_chess_box[i]:addChild(chess);
--            end;
--        elseif i == 8 then
--            for j = 1, 2 do
--                local chess = new(Chess, chess_string2const["B_CANNON"..j], self.m_chessSize);
--                self.m_chess_box[i]:addChild(chess);
--            end;            
--        elseif i == 9 then
--            for j = 1, 2 do
--                local chess = new(Chess, chess_string2const["B_ROOK"..j], self.m_chessSize);
--                self.m_chess_box[i]:addChild(chess);
--            end;     
--        elseif i == 10 then
--            for j = 1, 2 do
--                local chess = new(Chess, chess_string2const["B_HORSE"..j], self.m_chessSize);
--                self.m_chess_box[i]:addChild(chess);
--            end;  
--        elseif i == 11 then
--            for j = 1, 2 do
--                local chess = new(Chess, chess_string2const["B_ELEPHANT"..j], self.m_chessSize);
--                self.m_chess_box[i]:addChild(chess);
--            end;  
--        elseif i == 12 then
--            for j = 1, 2 do
--                local chess = new(Chess, chess_string2const["B_BISHOP"..j], self.m_chessSize);
--                self.m_chess_box[i]:addChild(chess);
--            end;
--        end;  
--    end;
end;

CustomBoardScene.refreshChessNum = function(self, chess_view,refreshType)
    local chess_num = chess_view:getChildByName("num");
    if refreshType == 1 then
        chess_num.int_num = (chess_num.int_num or 0) + 1;
    elseif refreshType == 2 then
        chess_num.int_num = (chess_num.int_num or 0) - 1;
    end;
    if chess_num.int_num > 1 and chess_num.int_num <= 5 then 
        chess_num:setFile("drawable/num_"..chess_num.int_num..".png");
    else
        chess_num:setFile("drawable/blank.png");
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
    chess_view:addChild(pc);
    self:refreshChessNum(chess_view,1)
    table.insert(self.m_boxChesses,pc);
end;

-- 棋盒棋子回到棋盘
CustomBoardScene.chessInBox2Board = function(self, chess)
--    chess:setEventTouch(nil, nil);
--    self.m_chess_box[drawable_resource_id[chess.m_pc]]:removeChild(chess);
    for i = 1, #self.m_boxChesses do
        if chess == self.m_boxChesses[i] then
            self.m_boxChesses[i]:setEventTouch(nil, nil);
            local chess_view = self.m_chess_box[drawable_resource_id[chess.m_pc]]
            chess_view:removeChild(self.m_boxChesses[i]);
            self:refreshChessNum(chess_view,2)
            table.remove(self.m_boxChesses,i);
        end;
    end;
--    chess.m_defaultSq = nil;
--    chess.m_defaultPc = nil;

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
    ChatMessageAnim.play(self,3,"双击棋盘棋子会回到棋盒中哦");
    ChatMessageAnim.root:setAlign(kAlignTop);
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
end;


CustomBoardScene.onClearPutAllBtnClick = function(self)
    Log.i("CustomBoardScene.onClearBtn");
    if self.m_clear_btn_press then
        self:board2ChessBox();
        self:setPutAllType();
    else
        self:chessBox2Board();
        self:setClearType();
    end;
end;


CustomBoardScene.setPutAllType = function(self)
--    self.m_clear_putall_txt:setText("摆满");
    self.m_clear_img:setVisible(false)
    self.m_full_img:setVisible(true);
    self.m_clear_btn_press = false;
    self.m_clear_put_btn_type = 1;
    self.m_restore_btn:setEnable(true);    
end;



CustomBoardScene.setClearType = function(self)
--    self.m_clear_putall_txt:setText("清空");
    self.m_clear_img:setVisible(true)
    self.m_full_img:setVisible(false);
    self.m_clear_btn_press = true;
    self.m_clear_put_btn_type = 2;
    self.m_restore_btn:setEnable(true);    
end;


CustomBoardScene.setRestoreBtn = function(self, enable)
    self.m_restore_btn:setEnable(enable); 
end;




-- 撤销,会使棋盘和清空(摆满)按钮回到上一次状态
CustomBoardScene.onRestoreBtnClick = function(self)
    Log.i("CustomBoardScene.onRestoreBtn");
    self.m_board.pos.squares = ToolKit.copyTable(self.m_back_boardSquares);
    -- 按钮是摆满
    if self.m_clear_put_btn_type == 1 then
        self.m_board.m_chesses = ToolKit.copyTable(self.m_back_boardChesses);
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
        self:setClearType();
    -- 按钮是清空
    elseif self.m_clear_put_btn_type == 2 then
        self.m_board.m_chesses = ToolKit.copyTable(self.m_back_boardChesses);
        for i = 1, 90 do
            if self.m_board.m_chesses[i] ~= 0 then
                self.m_board:addChild(self.m_board.m_chesses[i]);
                self.m_board.m_chesses[i]:setPos(self.m_board:getXYFromSquare90(i));
            end;
        end;
        for i = 1, #self.m_backBoxChesses do
            self:pc2ChessBox(self.m_backBoxChesses[i]);
        end;
        self:setPutAllType();
    end;
    self.m_restore_btn:setEnable(false);
end;

-- 能否开局
CustomBoardScene.isCanStartGame = function(self)
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
                return true;
            end;
        end; 
    else
        return true;
    end;
    ChatMessageAnim.play(self,3,"摆法导致将军，请重新摆子");
end;


-- 开局(试玩)按钮
CustomBoardScene.onStartBtnClick = function(self)
    -- 能否开局
    if not self:isCanStartGame() then return end; 
    -- 是否开局
    self.m_isStartGame = true;
    self.m_title_txt:setVisible(true);
    self.m_title_txt2:setVisible(true);
    self.m_title_txt3:setVisible(false);
    self.m_fen_str = self:initEndgateFenstr();
    -- 打谱
    if UserInfo.getInstance():getCustomDapuType() == 0 then
        self.m_board:setBoardType(BOARD_TYPE_START);
    -- 残局试玩
    elseif UserInfo.getInstance():getCustomDapuType() == 1 then
        -- boardType == nil，正常Board类
        self.m_board:setBoardType(nil);
        -- 初始化残局试玩相关.
        self:initEngateEngine(self.m_fen_str);
    end;
    self.m_chess_box_view:setPickable(false);
    self:setChessStep(nil, nil);
    if UserInfo.getInstance():getCustomDapuType() == 0 then
        self:leftInTranslateAnim(self.m_bottom_view, self.m_bottom_view2);
    elseif UserInfo.getInstance():getCustomDapuType() == 1 then
        self:leftInTranslateAnim(self.m_bottom_view, self.m_bottom_view3);
    end;
    

end;


CustomBoardScene.initEndgateFenstr = function(self)
    local chess_map = self.m_board:to_chess_map();
    local fen_str = self.m_board.toFen(chess_map,true);
    return fen_str;
    -- local pos = ToolKit.copyTable(self.m_board.pos);
    -- local pos1 = self.m_board.pos:fromFen(fen_str);
    --Board.runEngine--line position fen 3ak4/4a4/9/7N1/9/9/9/9/9/5K3 r moves h6f5(马到成功)
end;



CustomBoardScene.initEngateEngine = function(self, fen_str)
    self.m_board:setEngineBegin(fen_str);
end;




-- 重摆按钮
CustomBoardScene.onRecreateBtnClick = function(self)
    -- 是否开局
    self.m_isStartGame = false;
    -- 打谱
    if UserInfo.getInstance():getCustomDapuType() == 0 then
        self.m_title_txt:setVisible(true);
        self.m_title_txt2:setVisible(true);
        self.m_title_txt3:setVisible(false);
        self.m_title_txt:setText("打谱");
        self.m_title_txt2:setText("（摆子）");
    -- 残局试玩
    elseif UserInfo.getInstance():getCustomDapuType() == 1 then
        self.m_title_txt:setVisible(false);
        self.m_title_txt2:setVisible(false);
        self.m_title_txt3:setVisible(true);
        self.m_title_txt3:setText("创建残局");
    end;
    self.m_board:setBoardType(BOARD_TYPE_CUSTOM);
    self.m_chess_box_view:setPickable(true);
    self.m_board:closeTouchEvent(false);
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
    self.mvList = {};
    self.mvNum = 0;
    if UserInfo.getInstance():getCustomDapuType() == 0 then
        self:rightOutTranslateAnim(self.m_bottom_view, self.m_bottom_view2); 
    elseif UserInfo.getInstance():getCustomDapuType() == 1 then
        self:rightOutTranslateAnim(self.m_bottom_view, self.m_bottom_view3); 
    end;
end;


-- 分享
CustomBoardScene.onShareBtnClick = function(self)
    Log.i("CustomBoardScene.onShareBtnClick");
    require(BASE_PATH.."chessShareManager");
    -- 没有开局，生成当前局面的fen串.
    if not self.m_isStartGame then
        self.m_fen_str = self:initEndgateFenstr();
    end;

    local manualData = {};

    -- 打谱分享
    if UserInfo.getInstance():getCustomDapuType() == 0 then
        manualData.red_mid = UserInfo.getInstance():getUid();
        -- 黑方uid
        manualData.black_mid = UserInfo.getInstance():getUid();                     
        -- 胜利方（1红胜，2黑胜，3平局）
        manualData.win_flag = self.m_end_flag or "0";          
        -- 棋谱类型，1联网游戏，2残局，3单机游戏，4用户打谱，5自定义残局
        manualData.manual_type = "4";                   
        -- 棋盘开局(fen串)
        manualData.start_fen = self.m_fen_str or "";      
        -- 走法，json字符串
        manualData.move_list = table.concat(self.m_board:to_mvList(),GameCacheData.chess_data_key_split);                      
        -- 结束类型
        manualData.end_type = self.m_end_type or "0";    
    
    -- 自定义残局分享
    elseif UserInfo.getInstance():getCustomDapuType() == 1 then
        manualData.red_mid = UserInfo.getInstance():getUid();
        -- 黑方uid
        manualData.black_mid = "0";                     
        -- 胜利方（1红胜，2黑胜，3平局）
        manualData.win_flag = self.m_end_flag or "0";          
        -- 棋谱类型，1联网游戏，2残局，3单机游戏，4用户打谱，5自定义残局
        manualData.manual_type = "5";                   
        -- 棋盘开局(fen串)
        manualData.start_fen = self.m_fen_str or "";      
        -- 走法，json字符串
        manualData.move_list = "";                      
        -- 结束类型
        manualData.end_type = self.m_end_type or "0";          
    end;
    ChessShareManager.getInstance():onShare(manualData);
end;


CustomBoardScene.onUndoBtnClick = function(self)
    if self.m_board.pos.sdPlayer == 0 then
        if self.m_board.pos.moveNum > 1 then
            self:requestCtrlCmd(CustomBoardController.s_cmds.undoMove);
        else
            local message = "无棋可悔啦";
            if ChessToastManager.getInstance():isEmpty() then
                ChessToastManager.getInstance():show(message);
            end                
        end;
    end;
end;

CustomBoardScene.use_undoMove  = function(self)
    local undo_num = UserInfo.getInstance():getUndoNum();
    if self.m_board.pos.moveNum > 1 then
        self.m_board:endingUndoMove();
	    undo_num = undo_num - 1;
	    UserInfo.getInstance():setUndoNum(undo_num);
        self.m_undo_txt:setText(UserInfo.getInstance():getUndoNum());
    end
end



CustomBoardScene.onTipsBtnClick = function(self)
    if self.m_board.pos.sdPlayer == 0 then
        self:requestCtrlCmd(CustomBoardController.s_cmds.tip_action);
        self.m_tips_btn:setEnable(false);
    end;
end;

CustomBoardScene.tipEnable = function(self)
    self.m_tips_btn:setEnable(true);
end;

CustomBoardScene.use_tip = function(self)
    self.m_board:response(ENGINE_HINT);
	local tips_num = UserInfo.getInstance():getTipsNum();
    tips_num = tips_num - 1;
	UserInfo.getInstance():setTipsNum(tips_num);
    self.m_tips_txt:setText(UserInfo.getInstance():getTipsNum());
end


CustomBoardScene.leftInTranslateAnim = function(self, v1, v2)
    v2:setVisible(true);
    v1:addPropTranslate(1,kAnimNormal,CustomBoardScene.BOTTOM_ANIM_TIME,-1,0, -self.m_rootW,nil,nil);
    local anim = v2:addPropTranslate(1,kAnimNormal,CustomBoardScene.BOTTOM_ANIM_TIME,-1,0, -self.m_rootW,nil,nil);   
    if anim then
        anim:setEvent(self, function() 
            v1:setPos(-self.m_rootW,nil);
            v1:setVisible(false);
            v2:setPos(0,nil);
            v1:removeProp(1);
            v2:removeProp(1);
        end)         
    end;
end;



CustomBoardScene.rightOutTranslateAnim = function(self, v1, v2)
    v1:setVisible(true);
    local anim = v1:addPropTranslate(2,kAnimNormal,CustomBoardScene.BOTTOM_ANIM_TIME,-1,0, self.m_rootW,nil,nil);
    v2:addPropTranslate(2,kAnimNormal,CustomBoardScene.BOTTOM_ANIM_TIME,-1,0, self.m_rootW,nil,nil);   
    if anim then
        anim:setEvent(self, function() 
            v1:setPos(0,nil);
            v2:setPos(self.m_rootW,nil);
            v2:setVisible(false);
            v1:removeProp(2);
            v2:removeProp(2);
        end)         
    end;
end;


CustomBoardScene.onSliderMove = function(self, progress)
    self.m_curNum = math.floor((#self.mvList - 1) * progress);
--    print_string("CustomBoardScene.onSliderMove--------------->"..self.m_curNum);
--    print_string("CustomBoardScene.onSliderMove---->"..(self.mvNum-1));
    while(self.m_curNum ~= self.mvNum -1) do
        if self.m_curNum == 0 then return end;
        if self.m_curNum < self.mvNum -1 then
            self:onPreStepBtnClick(-1);
        elseif self.m_curNum > self.mvNum-1 then        
            self:onNextStepBtnClick(-1);
        end;
    end;
end;



--上一步
CustomBoardScene.onPreStepBtnClick = function(self,finger_action)
	if self.mvNum > 1 then
        self.m_board:undoMove();
        self.mvNum = self.m_board.pos.moveNum;
        self.m_board:hiddenMovePath();
        -- 重置移动轨迹
        if self.mvList[self.mvNum - 1] then
            local mv = tonumber(self.mvList[self.mvNum - 1]);
            if mv then
                local sqSrc = Postion.SRC(mv);
                local sqDst = Postion.DST(mv);
                local sqSrc90 = Board.To90(sqSrc);
                local sqDst90 = Board.To90(sqDst);
                self.m_board:setMovePath(sqSrc90,sqDst90);
            end;
        end;
		self:setChessStep(self.mvNum - 1,#self.mvList - 1);
        -- finger_action ~= -1说明来自点击后退按钮,更新Slider
        if finger_action ~= -1 then
            local pp = (self.mvNum - 1)/(#self.mvList - 1);
            self.m_move_slider:setProgress(pp);
        end;
        self.m_recreate_onestep_btn:setEnable(true);
        self.m_restore_onestep_btn:setEnable(false);
	end

end


--下一步
CustomBoardScene.onNextStepBtnClick = function(self,finger_action)
	if self.mvNum > #self.mvList - 1 then--结束判断
	else
		local mv = tonumber(self.mvList[self.mvNum -1 + 1]);
		if mv then
	        if self.m_board.pos:makeMove(mv) then
                self.m_board:chessMove(mv,true)
                self.mvNum = self.m_board.pos.moveNum;
                self:setChessStep(self.mvNum-1,#self.mvList - 1);
	        end
            -- finger_action ~= -1说明来自点击前进按钮,更新Slider
            if finger_action ~= -1 then
                local pp = (self.mvNum - 1)/(#self.mvList - 1);
                self.m_move_slider:setProgress(pp);
            end
		else
			return;
		end
	end
end


CustomBoardScene.setChessStep = function(self,curNum,maxNum)
    if UserInfo.getInstance():getCustomDapuType() == 0 then
        self.m_title_txt:setVisible(true);
        self.m_title_txt2:setVisible(true);
        self.m_title_txt3:setVisible(false);
        self.m_title_txt:setText("打谱");
	    self.m_title_txt2:setText("（"..(curNum or 0).."/"..(maxNum or 0).."）");
    elseif UserInfo.getInstance():getCustomDapuType() == 1 then
        self.m_title_txt:setVisible(false);
        self.m_title_txt2:setVisible(false);
        self.m_title_txt3:setVisible(true);
        self.m_title_txt3:setText("试玩");
    end;
end



-- 重做一步
CustomBoardScene.recreateOneStep = function(self,mv)
    if not self.m_choice_dialog then
        self.m_choice_dialog = new(ChioceDialog);
    end;
    self.m_choice_dialog:setMode(ChioceDialog.MODE_SURE);
    self.m_choice_dialog:setMessage("重走此步，后续步骤会丢失，确定重走吗？");
    self.m_choice_dialog:setPositiveListener(self,self.onRecreateOneStep,mv);
    self.m_choice_dialog:setNegativeListener(self,self.onRestoreOneStep);
    self.m_choice_dialog:show();
end;

-- 重做
CustomBoardScene.onRecreateOneStep = function(self, mv)
    self.mvNum = self.m_board.pos.moveNum;
    local mvListCount = #self.mvList;
    for i = self.mvNum, mvListCount-1 do
        table.remove(self.mvList,self.mvNum);
    end;
    if self.mvList[self.mvNum - 1] then
        self.mvList[self.mvNum - 1] = mv;
    end;
    self.m_board.pos.mvList = ToolKit.copyTable(self.mvList);
    self.m_move_slider:setProgress(1);
    self:setChessStep(self.mvNum-1,#self.mvList - 1);
    
    self.m_board:chessMove(mv)
    self.m_board:clearSelect();
    self.m_board:closeTouchEvent(false);
    self.m_recreate_onestep_btn:setEnable(false);
    self.m_restore_onestep_btn:setEnable(true);
end;


---- 重做
--CustomBoardScene.onRecreateOneStep = function(self)
--    -- 备份mvList,撤销时候使用
--    self.m_back_mvList = ToolKit.copyTable(self.mvList);

--    self.m_board:undoMove();
--    self.mvNum = self.m_board.pos.moveNum;
--    local mvListCount = #self.mvList;
--    for i = self.mvNum, mvListCount-1 do
--        table.remove(self.mvList,self.mvNum);
--    end;
--    self.m_board.pos.mvList = ToolKit.copyTable(self.mvList);
--    self.m_move_slider:setProgress(1);

--    self:setChessStep(self.mvNum-1,#self.mvList - 1);
--    self.m_board:closeTouchEvent(false);
--    self.m_recreate_onestep_btn:setEnable(false);
--    self.m_restore_onestep_btn:setEnable(true);
--end;


-- 撤销
CustomBoardScene.onRestoreOneStepBtnClick = function(self)
    if not self.m_choice_dialog then
        self.m_choice_dialog = new(ChioceDialog);
    end;
    self.m_choice_dialog:setMode(ChioceDialog.MODE_SURE);
    self.m_choice_dialog:setMessage("撤销此操作吗？");
    self.m_choice_dialog:setPositiveListener(self,self.onRestoreOneStep);
    self.m_choice_dialog:show();    
end;


-- 取消走棋
CustomBoardScene.onRestoreOneStep = function(self) 
    self.m_board:clearSelect();   
    self.m_board:hiddenHints(); 
    self.m_board.pos:undoMakeMove();
end;


---- 撤销刚才的重做此步
--CustomBoardScene.onRestoreOneStep = function(self) 
--    self.m_board.pos.mvList = ToolKit.copyTable(self.m_back_mvList);
--    self.mvList = ToolKit.copyTable(self.m_back_mvList);
--    self.m_board:move(self.mvList[self.mvNum]);
--    self.m_move_slider:setProgress((self.mvNum - 1)/(#self.mvList-1));
--    self.m_recreate_onestep_btn:setEnable(true);
--    self.m_restore_onestep_btn:setEnable(false);    
--end;



CustomBoardScene.setDieChess = function(self,dieChess)
--    self:pc2ChessBox();
end


CustomBoardScene.chessMove = function(self,data)
    if UserInfo.getInstance():getCustomDapuType() == 0 then
        local mv = self.m_board:data2mv(data);
        -- 只有mvNum和mvList数量相等时,说明有新的棋开始走,保存到mvList中.
        if self.mvNum == #self.mvList then
            self.mvList = ToolKit.copyTable(self.m_board.pos.mvList); 
            -- 走了一步新棋，撤销一步不可用
            self.m_recreate_onestep_btn:setEnable(true); 
            self.m_restore_onestep_btn:setEnable(false); 
            self.m_board:chessMove(mv)
            self.m_board:clearSelect();
            self.mvNum = self.m_board.pos.moveNum;
            self:setChessStep(self.mvNum-1,#self.mvList - 1);
        -- 观看之前的局面
        elseif self.mvNum < #self.mvList then
            if mv and self.mvList[self.mvNum] then
                if mv == self.mvList[self.mvNum] then
                    self.m_board:chessMove(mv)
                    self.m_board:clearSelect();
                    self.mvNum = self.m_board.pos.moveNum;
                    self:setChessStep(self.mvNum-1,#self.mvList - 1);
                else
                    self:recreateOneStep(mv);
                end;
            end;
        end;
    -- 如果是残局试玩,则AI走棋
    elseif UserInfo.getInstance():getCustomDapuType() == 1 then
        self.m_board:response(ENGINE_MOVE);
    end;
end;

CustomBoardScene.setBoradCode = function(self,code, endType)
    self.m_end_flag = code;
    self.m_end_type = endType;
    self.m_share_btn2:setEnable(true);
end



CustomBoardScene.onEngine2Gui = function(self, data)
    self.m_board:onReceive(data);

end;


CustomBoardScene.onBoardAiMove = function(self)
    -- 只有mvNum和mvList数量相等时,说明有新的棋开始走,保存到mvList中.
    Log.i("CustomBoardScene.onEngine2Gui--"..self.mvNum.." #self.mvList "..#self.mvList);
    if self.mvNum == #self.mvList then
        self.mvList = ToolKit.copyTable(self.m_board.pos.mvList); 
    end;
    self.mvNum = self.m_board.pos.moveNum;
    self:setChessStep(self.mvNum-1,#self.mvList - 1);    
end;


CustomBoardScene.onUpdateView = function(self)
  self.m_undo_txt:setText(UserInfo.getInstance():getUndoNum());
  self.m_tips_txt:setText(UserInfo.getInstance():getTipsNum());

end;


-- 棋盒棋子滑动到棋盘上(onChessViewTouch)
CustomBoardScene.onChessViewTouch = function(self,pc,finger_action,x,y,drawing_id_first,drawing_id_current)
   local chess_view = self.m_chess_box[drawable_resource_id[pc.m_pc]];
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
        if (x > 0 and x <= 480) and (y > 80 and y <624) then  -- 624 = 80 + 544(棋盘高)··
            x ,y = self.m_board:convertSurfacePointToView(x,y);
            local upC,upR = self.m_board:getCRfromXY(x,y);
            local sq_,sq90_ = self.m_board:getSqfromCR(upC,upR);
            self.m_board:setChess2Board(upC, upR, sq_, sq90_);
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



------------------------------- config ---------------------------------
CustomBoardScene.s_controlConfig = 
{
    [CustomBoardScene.s_controls.back_btn]              = {"title_view","back_btn"};
    [CustomBoardScene.s_controls.clear_putall_btn]      = {"bottom_view","clear_putall_btn"};
    [CustomBoardScene.s_controls.restore_btn]           = {"bottom_view","restore_btn"};
    [CustomBoardScene.s_controls.start_btn]             = {"bottom_view","chess_box_view","chess_start"};
    [CustomBoardScene.s_controls.share_btn]             = {"bottom_view","share_btn"};
    [CustomBoardScene.s_controls.recreate_btn]          = {"bottom_view2","recreate_btn"};
    [CustomBoardScene.s_controls.share_btn2]            = {"bottom_view2","share_btn2"};
    [CustomBoardScene.s_controls.back_step_btn]         = {"bottom_view2","control_board_view","back_step"};
    [CustomBoardScene.s_controls.forward_step_btn]      = {"bottom_view2","control_board_view","forward_step"};
    [CustomBoardScene.s_controls.recreate_onestep_btn]  = {"bottom_view2","recreate_onestep_btn"};
    [CustomBoardScene.s_controls.restore_onestep_btn]   = {"bottom_view2","restore_onestep_btn"};
    [CustomBoardScene.s_controls.recreate_btn2]         = {"bottom_view3","recreate_btn"};
    [CustomBoardScene.s_controls.undo_btn]              = {"bottom_view3","control_board_view","room_menu_bg","undo_btn"};
    [CustomBoardScene.s_controls.tips_btn]              = {"bottom_view3","control_board_view","room_menu_bg","tips_btn"};
    [CustomBoardScene.s_controls.share_btn3]            = {"bottom_view3","share_btn3"};

};

CustomBoardScene.s_controlFuncMap =
{
    [CustomBoardScene.s_controls.back_btn]              = CustomBoardScene.onBack;
    [CustomBoardScene.s_controls.clear_putall_btn]      = CustomBoardScene.onClearPutAllBtnClick;
    [CustomBoardScene.s_controls.restore_btn]           = CustomBoardScene.onRestoreBtnClick;
    [CustomBoardScene.s_controls.share_btn]             = CustomBoardScene.onShareBtnClick;
    [CustomBoardScene.s_controls.start_btn]             = CustomBoardScene.onStartBtnClick;
    [CustomBoardScene.s_controls.recreate_btn]          = CustomBoardScene.onRecreateBtnClick;
    [CustomBoardScene.s_controls.recreate_btn2]         = CustomBoardScene.onRecreateBtnClick;
    [CustomBoardScene.s_controls.back_step_btn]         = CustomBoardScene.onPreStepBtnClick;
    [CustomBoardScene.s_controls.forward_step_btn]      = CustomBoardScene.onNextStepBtnClick;
    [CustomBoardScene.s_controls.recreate_onestep_btn]  = CustomBoardScene.onRecreateOneStepBtnClick;
    [CustomBoardScene.s_controls.restore_onestep_btn]   = CustomBoardScene.onRestoreOneStepBtnClick;
    [CustomBoardScene.s_controls.share_btn2]            = CustomBoardScene.onShareBtnClick;
    [CustomBoardScene.s_controls.undo_btn]              = CustomBoardScene.onUndoBtnClick;
    [CustomBoardScene.s_controls.tips_btn]              = CustomBoardScene.onTipsBtnClick;
    [CustomBoardScene.s_controls.share_btn3]            = CustomBoardScene.onShareBtnClick;

};


CustomBoardScene.s_cmdConfig =
{
    [CustomBoardScene.s_cmds.engine2Gui]                = CustomBoardScene.onEngine2Gui;
    [CustomBoardScene.s_cmds.board_ai_move]             = CustomBoardScene.onBoardAiMove;
    [CustomBoardScene.s_cmds.updateView]                = CustomBoardScene.onUpdateView;
    [CustomBoardScene.s_cmds.use_tip]                   = CustomBoardScene.use_tip;
    [CustomBoardScene.s_cmds.use_undoMove]              = CustomBoardScene.use_undoMove;
    [CustomBoardScene.s_cmds.tip_enable]                = CustomBoardScene.tipEnable;
}


