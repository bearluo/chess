-- Scene界面涉及逻辑比较多，后续时间充裕
-- 再把逻辑迁移到Controller内
require(BASE_PATH.."chessScene");

require(DIALOG_PATH.."dapu_create_endgate_dialog");

CreateEndgateScene = class(ChessScene);
CreateEndgateScene.BOTTOM_ANIM_TIME = 300;
CreateEndgateScene.s_controls = 
{
    back_btn                = 1;
    release_btn             = 2;
}

CreateEndgateScene.s_cmds = 
{
    engine2Gui              = 1;
    board_ai_move           = 2;
    updateView              = 3;
    use_tip                 = 4;
    use_undoMove            = 5;
    tip_enable              = 6;
}

CreateEndgateScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = CreateEndgateScene.s_controls;
    self.m_chess_box = {};
    self.m_boxChesses = {};
    self.m_chessSize = 50.7;
    self.m_clear_btn_press = true;
    self.m_history_chesses = {};
    self:initViews();
    
end 
CreateEndgateScene.resume = function(self)
    ChessScene.resume(self);
    
end;


CreateEndgateScene.pause = function(self)
	ChessScene.pause(self);
end 


CreateEndgateScene.dtor = function(self)
    self.m_board:setBoardType(nil);
    ChatMessageAnim.deleteAll();
    delete(self.m_create_dialog);
end 



------------------------------- function -------------------------------

CreateEndgateScene.onBack = function(self)
    self:requestCtrlCmd(CreateEndgateController.s_cmds.onBack);
end

CreateEndgateScene.onRelease = function(self)
    local flag,msg = self:isCanStartGame();
    if not flag then 
        ChessToastManager.getInstance():show(msg or "棋局不符合规则");
        return ;
    end
    delete(self.m_create_dialog);
    self.m_create_dialog = new(DapuCreateEndgateDialog);
    self.m_create_dialog:setPositiveListener(self,function(self,title)
        local fen = self:initEndgateFenstr();
        local title = title;
        self:requestCtrlCmd(CreateEndgateController.s_cmds.release,fen,title);
    end);
    local data = UserInfo.getInstance():getFPcostMoney();
    self.m_create_dialog:setMessage('是否花费'..(data.create_booth or 0)..'金币发布?');
    self.m_create_dialog:show();
end

CreateEndgateScene.initViews = function(self)
    -- title
    self.m_room_time_bg = self.m_root:getChildByName("room_time_bg");
    self.m_room_time_text = self.m_room_time_bg:getChildByName("room_time");
    -- board
    self.m_content_view = self.m_root:getChildByName("content_view");
    self.m_board_view = self.m_content_view:getChildByName("chess_board");
    -- 棋盘适配
    local w,h = self.m_content_view:getSize();
    self.m_chess_box_view = self.m_root:getChildByName("chess_box_view");--确定底边
    local bx,by = self.m_chess_box_view:getUnalignPos();
    local x,y = self.m_content_view:getUnalignPos();
    local pw = self.m_root:getSize();
    local ph = by - y;
    if pw > w then
        local diffh = ph - h; -- 增加的高
        local diffw = pw - w; -- 增加的高
        local add = math.min(diffw,diffh);
        local scale = (w+add)/w;
	    self.m_content_view:setSize(w*scale,h*scale);
        local w,h = self.m_board_view:getSize();
	    self.m_board_view:setSize(w*scale,h*scale);
    end
    -- 棋盘适配 end
    local w, h = self.m_content_view:getSize();
    self.m_board = new(Board,w,h,self,nil,BOARD_TYPE_CUSTOM);
    self.m_content_view:addChild(self.m_board);
    self.m_board:newgame(Board.MODE_RED);
    self.m_rootW, self.m_rootH = self:getSize();
    -- top_view1
    self.m_top_view = self.m_root:getChildByName("top_view");
    self.m_chess_box_view = self.m_root:getChildByName("chess_box_view");
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
    -- 清空
    self.m_clear_all_btn = self.m_top_view:getChildByName("menu_bg"):getChildByName("clear_all_btn");
    self.m_clear_all_btn:setOnClick(self,function(self)
            self.m_menu_bg:setVisible(false);
            self.m_menu_mask:setVisible(false);
            self:board2ChessBox() 
        end);
    -- 摆满
    self.m_full_btn = self.m_top_view:getChildByName("menu_bg"):getChildByName("full_btn");
    self.m_full_btn:setOnClick(self,function(self)
            self.m_menu_bg:setVisible(false);
            self.m_menu_mask:setVisible(false);
            self:chessBox2Board() 
        end);
    -- 撤销
    self.m_undo_btn = self.m_top_view:getChildByName("undo_btn");
    self.m_undo_btn:setOnClick(self,self.backByHistory);
    -- 菜单
    self.m_menu_mask = self.m_root:getChildByName("mask");
    self.m_menu_bg = self.m_top_view:getChildByName("menu_bg");
    self.m_menu_bg:setVisible(false);
    self.m_menu_mask:setVisible(false);
    self.m_menu_btn = self.m_top_view:getChildByName("menu_btn");
    self.m_menu_btn:setOnClick(self,function(self)
        self.m_menu_bg:setVisible(not self.m_menu_bg:getVisible());
        self.m_menu_mask:setVisible(self.m_menu_bg:getVisible());
    end);
    self.m_menu_bg:setEventDrag(self,function()end);
    self.m_menu_bg:setEventTouch(self,function()end);
    self.m_menu_mask:setEventDrag(self,function(self,finger_action, x, y,drawing_id_first, drawing_id_current)
        if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
            self.m_menu_bg:setVisible(false);
            self.m_menu_mask:setVisible(false);
        end
    end);
    self.m_menu_mask:setEventTouch(self,function()end);

    self:updateUndoBtn();
    self:updateClearBtn();
   
    self:board2ChessBox();
    self:startTime();
end;


CreateEndgateScene.startTime = function(self)
	self:stopTime();
	self.m_timeAnim = new(AnimInt,kAnimLoop,0,1,1000,0);
	self.m_timeAnim:setDebugName("Room.startTime.m_timeAnim");
	self.m_timeAnim:setEvent(self,self.timeRun);

end

CreateEndgateScene.stopTime = function(self)
	if self.m_timeAnim then
		delete(self.m_timeAnim);
		self.m_timeAnim = nil;
	end
end

CreateEndgateScene.timeRun = function(self)
	local t = os.date("*t");

	local time = string.format("%02d:%02d",t.hour,t.min);
	if t.sec%2 == 1 then
		time = string.format("%02d %02d",t.hour,t.min);
	end

	self.m_room_time_text:setText(time);
end



CreateEndgateScene.initBoardSetting = function(self)
    
end

CreateEndgateScene.initChessBox = function(self)
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
end

CreateEndgateScene.refreshChessNum = function(self, chess_view,refreshType)
    chess_view:getChildByName("num"):setLevel(1);
    local chess_num = chess_view:getChildByName("num"):getChildByName("Text1");
    if refreshType == 1 then
        chess_num.int_num = (chess_num.int_num or 0) + 1;
    elseif refreshType == 2 then
        chess_num.int_num = (chess_num.int_num or 0) - 1;
    end
    if chess_num.int_num >= 1 and chess_num.int_num <= 5 then 
        chess_num:setText(chess_num.int_num);
    else
        chess_num:setText(0);
    end
end

-- 选中的棋子放回到棋盒
CreateEndgateScene.pc2ChessBox = function(self, pc)
    local chess_view = self.m_chess_box[drawable_resource_id[pc.m_pc]];
    if not pc or not chess_view then return end;
    pc:setPos(0,0);
    pc:setEventTouch(pc, function(...) 
        self:onChessViewTouch(...)
        pc.onTouch(...);
        self.m_board:clearSelect();
    end);
    pc:addPropScaleSolid(10, 0.8, 0.8, kCenterXY,0,0);
    pc.selected = CreateEndgateScene.selected;
    pc.normal   = CreateEndgateScene.normal;
    pc:normal();
    chess_view:addChild(pc);
    self:refreshChessNum(chess_view,1)
    table.insert(self.m_boxChesses,pc);
end;

CreateEndgateScene.normal = function(self)
	Chess.normal(self);
    self:addPropScaleSolid(10, 0.8, 0.8, kCenterXY,0,0);
end

CreateEndgateScene.selected = function(self)
	Chess.selected(self);
    self:removeProp(10);
end

CreateEndgateScene.checkIsInBox = function(self,chess)
    for i = 1, #self.m_boxChesses do
        if chess == self.m_boxChesses[i] then
            return true;
        end
    end
    return false;
end

-- 棋盒棋子回到棋盘
CreateEndgateScene.chessInBox2Board = function(self, chess)
--    chess:setEventTouch(nil, nil);
--    self.m_chess_box[drawable_resource_id[chess.m_pc]]:removeChild(chess);
    for i = 1, #self.m_boxChesses do
        if chess == self.m_boxChesses[i] then
            self.m_boxChesses[i]:setEventTouch(nil, nil);
            self.m_boxChesses[i].selected = Chess.selected;
            self.m_boxChesses[i].normal   = Chess.normal;
            self.m_boxChesses[i]:removeProp(10);
            local chess_view = self.m_chess_box[drawable_resource_id[chess.m_pc]]
            chess_view:removeChild(self.m_boxChesses[i]);
            self:refreshChessNum(chess_view,2)
            table.remove(self.m_boxChesses,i);
        end
    end
end

-- 摆满（所有棋盒棋子回到棋盘）
CreateEndgateScene.chessBox2Board = function(self)
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
    self:chessesChange(ToolKit.copyTable(self.m_board:getChesses()));
end;

-- 清空（所有棋盘棋子回到棋盒）
CreateEndgateScene.board2ChessBox = function(self)
    self.m_back_boardSquares = ToolKit.copyTable(self.m_board.pos.squares);
    self.m_back_boardChesses = ToolKit.copyTable(self.m_board.m_chesses);
    for i = 1, 90 do
        if self.m_board.m_chesses[i] ~= 0 then
            if self.m_board.m_chesses[i].m_pc ~= B_KING and self.m_board.m_chesses[i].m_pc ~= R_KING then
                local x, y = self.m_board.m_chesses[i]:getPos();
                local sq = self.m_board:getSquareFromXY(x, y);
                self.m_board.m_chesses[i].m_defaultSq = sq;
                self.m_board.m_chesses[i].m_defaultPc = self.m_board.pos.squares[sq];
                self:pc2ChessBox(self.m_board.m_chesses[i]);   
                self.m_board:clearChess(i, sq);
            end
        end
    end
    self:chessesChange(ToolKit.copyTable(self.m_board:getChesses()));
end


CreateEndgateScene.onClearPutAllBtnClick = function(self)
    Log.i("CreateEndgateScene.onClearBtn");
    if self.m_clear_btn_press then
        self:board2ChessBox();
        self:setPutAllType();
    else
        self:chessBox2Board();
        self:setClearType();
    end;
end;


CreateEndgateScene.setPutAllType = function(self)
--    self.m_clear_putall_txt:setText("摆满");
    self.m_clear_btn_press = false;
    self.m_clear_put_btn_type = 1;  
end;



CreateEndgateScene.setClearType = function(self)
--    self.m_clear_putall_txt:setText("清空");
    self.m_clear_btn_press = true;
    self.m_clear_put_btn_type = 2;
end;

-- 撤销,会使棋盘和清空(摆满)按钮回到上一次状态
CreateEndgateScene.onRestoreBtnClick = function(self)
    Log.i("CreateEndgateScene.onRestoreBtn");
    self.m_board.pos.squares = ToolKit.copyTable(self.m_back_boardSquares);
    -- 按钮是摆满
    if self.m_clear_put_btn_type == 1 then
        self.m_board.m_chesses = ToolKit.copyTable(self.m_back_boardChesses);
        for i = 1, 90 do
            if self.m_board.m_chesses[i] ~= 0 then
                if self.m_board.m_chesses[i].m_pc ~= B_KING and self.m_board.m_chesses[i].m_pc ~= R_KING then
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
end;

-- 能否开局
CreateEndgateScene.isCanStartGame = function(self)
    local message = "";
    -- 如果将帅对脸则不能开局
    if self:isFace() then 
        message = "将帅对脸，不符合规则";
        return false,message;
    end
    -- 红方困毙 不能开局
    if self.m_board:isDeath(Board.MODE_RED) then 
        message = "红方困毙，不符合规则";
        return false,message;
    end

    -- 红方方处于被将军 不能开局
    if self.m_board:isChecked(Board.MODE_RED) then 
        message = "红方处于被将军，不符合规则";
        return false,message;
    end

    -- 黑方处于被将军 不能开局
    if self.m_board:isChecked(Board.MODE_BLACK) then 
        message = "黑方处于被将军，不符合规则";
        return false,message;
    end

    -- 判断红方是否只有老帅
    if self:isRedOnlyKing() then 
        message = "红方不能只有帅，不符合规则";
        return false,message;
    end

    return true,message;
end

-- 判断红方是否只有老将
CreateEndgateScene.isRedOnlyKing = function(self)
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

-- 判断黑方是否只有老将
CreateEndgateScene.isBlackOnlyKing = function(self)
    local cnt = 0;
    -- 判断红方棋子数
    for i = 1, 90 do
        if self.m_board.m_chesses[i] and self.m_board.m_chesses[i] ~= 0 
            and type(self.m_board.m_chesses[i]) == "table" and self.m_board.m_chesses[i].m_pc 
            and self.m_board.m_chesses[i].m_pc >= B_BEGIN and self.m_board.m_chesses[i].m_pc <= B_END then
            cnt = cnt + 1;
        end
    end
    if cnt > 1 then 
        return false;
    else
        return true;
    end
end

-- 如果将帅对脸则不能开局
CreateEndgateScene.isFace = function(self)
    local bKing = nil;
    local rKing = nil;
    for i = 1, 90 do
        if self.m_board.m_chesses[i] ~= 0 then
            if self.m_board.m_chesses[i].m_pc == B_KING then
                bKing = self.m_board.m_chesses[i];
            elseif self.m_board.m_chesses[i].m_pc == R_KING then
                rKing = self.m_board.m_chesses[i];
            end
        end
    end
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
            end
        end
    else
        return false;
    end
    return true;
end


-- 开局(试玩)按钮
--CreateEndgateScene.onStartBtnClick = function(self)
--    -- 能否开局
--    if not self:isCanStartGame() then 
--        ChatMessageAnim.play(self,3,"摆法导致将军，请重新摆子");
--        return 
--    end; 
--    -- 是否开局
--    self.m_isStartGame = true;
--    self.m_title_txt:setVisible(true);
--    self.m_title_txt2:setVisible(true);
--    self.m_title_txt3:setVisible(false);
--    self.m_fen_str = self:initEndgateFenstr();
--    -- 打谱
--    if UserInfo.getInstance():getCustomDapuType() == 0 then
--        self.m_board:setBoardType(BOARD_TYPE_START);
--    -- 残局试玩
--    elseif UserInfo.getInstance():getCustomDapuType() == 1 then
--        -- boardType == nil，正常Board类
--        self.m_board:setBoardType(nil);
--        -- 初始化残局试玩相关.
--        self:initEngateEngine(self.m_fen_str);
--    end;
--    self.m_chess_box_view:setPickable(false);
--    self:setChessStep(nil, nil);
--    if UserInfo.getInstance():getCustomDapuType() == 0 then
--        self:leftInTranslateAnim(self.m_top_view, self.m_top_view2);
--    elseif UserInfo.getInstance():getCustomDapuType() == 1 then
--        self:leftInTranslateAnim(self.m_top_view, self.m_top_view3);
--    end;


--end;


CreateEndgateScene.initEndgateFenstr = function(self)
    local chess_map = self.m_board:to_chess_map();
    local fen_str = self.m_board.toFen(chess_map,true);
    return fen_str;
    -- local pos = ToolKit.copyTable(self.m_board.pos);
    -- local pos1 = self.m_board.pos:fromFen(fen_str);
    --Board.runEngine--line position fen 3ak4/4a4/9/7N1/9/9/9/9/9/5K3 r moves h6f5(马到成功)
end;



CreateEndgateScene.initEngateEngine = function(self, fen_str)
    self.m_board:setEngineBegin(fen_str);
end;




-- 重摆按钮
--CreateEndgateScene.onRecreateBtnClick = function(self)
--    -- 是否开局
--    self.m_isStartGame = false;
--    -- 打谱
--    if UserInfo.getInstance():getCustomDapuType() == 0 then
--        self.m_title_txt:setVisible(true);
--        self.m_title_txt2:setVisible(true);
--        self.m_title_txt3:setVisible(false);
--        self.m_title_txt:setText("打谱");
--        self.m_title_txt2:setText("（摆子）");
--    -- 残局试玩
--    elseif UserInfo.getInstance():getCustomDapuType() == 1 then
--        self.m_title_txt:setVisible(false);
--        self.m_title_txt2:setVisible(false);
--        self.m_title_txt3:setVisible(true);
--        self.m_title_txt3:setText("创建残局");
--    end;
--    self.m_board:setBoardType(BOARD_TYPE_CUSTOM);
--    self.m_chess_box_view:setPickable(true);
--    self.m_board:closeTouchEvent(false);
--    self.m_board:hiddenHints();
--	self.m_board:hiddenMovePath();
--	self.m_board:hiddenHintPath();
--    self.m_board:clearSelect();
--    self.m_board:gameStart();
--    -- mvList和moveNum都比正常多一步
--    -- moveNum是#mvList
--    -- =1是由于重摆没有调Postion.setIrrev方法;
--    -- 归结到底是Postion.isMate走了一步棋，又悔了一步棋导致;
--    -- 后续优化...
--    self.m_board.pos.mvList = {};
--    self.m_board.pos.moveNum = 1;
--    self.m_board.pos.sdPlayer = 0;
--    self.mvList = {};
--    self.mvNum = 0;
--    if UserInfo.getInstance():getCustomDapuType() == 0 then
--        self:rightOutTranslateAnim(self.m_top_view, self.m_top_view2); 
--    elseif UserInfo.getInstance():getCustomDapuType() == 1 then
--        self:rightOutTranslateAnim(self.m_top_view, self.m_top_view3); 
--    end;
--end;


CreateEndgateScene.onUndoBtnClick = function(self)
    if self.m_board.pos.sdPlayer == 0 then
        if self.m_board.pos.moveNum > 1 then
            self:requestCtrlCmd(CreateEndgateController.s_cmds.undoMove);
        else
            local message = "无棋可悔啦";
            if ChessToastManager.getInstance():isEmpty() then
                ChessToastManager.getInstance():show(message);
            end                
        end;
    end;
end;

CreateEndgateScene.use_undoMove  = function(self)
    local undo_num = UserInfo.getInstance():getUndoNum();
    if self.m_board.pos.moveNum > 1 then
        self.m_board:endingUndoMove();
	    undo_num = undo_num - 1;
	    UserInfo.getInstance():setUndoNum(undo_num);
        self.m_undo_txt:setText(UserInfo.getInstance():getUndoNum());
    end
end



CreateEndgateScene.onTipsBtnClick = function(self)
    if self.m_board.pos.sdPlayer == 0 then
        self:requestCtrlCmd(CreateEndgateController.s_cmds.tip_action);
        self.m_tips_btn:setEnable(false);
    end;
end;

CreateEndgateScene.tipEnable = function(self)
    self.m_tips_btn:setEnable(true);
end;

CreateEndgateScene.use_tip = function(self)
    self.m_board:response(ENGINE_HINT);
	local tips_num = UserInfo.getInstance():getTipsNum();
    tips_num = tips_num - 1;
	UserInfo.getInstance():setTipsNum(tips_num);
    self.m_tips_txt:setText(UserInfo.getInstance():getTipsNum());
end


CreateEndgateScene.leftInTranslateAnim = function(self, v1, v2)
    v2:setVisible(true);
    v1:addPropTranslate(1,kAnimNormal,CreateEndgateScene.BOTTOM_ANIM_TIME,-1,0, -self.m_rootW,nil,nil);
    local anim = v2:addPropTranslate(1,kAnimNormal,CreateEndgateScene.BOTTOM_ANIM_TIME,-1,0, -self.m_rootW,nil,nil);   
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



CreateEndgateScene.rightOutTranslateAnim = function(self, v1, v2)
    v1:setVisible(true);
    local anim = v1:addPropTranslate(2,kAnimNormal,CreateEndgateScene.BOTTOM_ANIM_TIME,-1,0, self.m_rootW,nil,nil);
    v2:addPropTranslate(2,kAnimNormal,CreateEndgateScene.BOTTOM_ANIM_TIME,-1,0, self.m_rootW,nil,nil);   
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


CreateEndgateScene.onSliderMove = function(self, progress)
    self.m_curNum = math.floor((#self.mvList - 1) * progress);
--    print_string("CreateEndgateScene.onSliderMove--------------->"..self.m_curNum);
--    print_string("CreateEndgateScene.onSliderMove---->"..(self.mvNum-1));
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
CreateEndgateScene.onPreStepBtnClick = function(self,finger_action)
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
CreateEndgateScene.onNextStepBtnClick = function(self,finger_action)
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


CreateEndgateScene.setChessStep = function(self,curNum,maxNum)
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
CreateEndgateScene.recreateOneStep = function(self,mv)
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
CreateEndgateScene.onRecreateOneStep = function(self, mv)
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
--CreateEndgateScene.onRecreateOneStep = function(self)
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
CreateEndgateScene.onRestoreOneStepBtnClick = function(self)
    if not self.m_choice_dialog then
        self.m_choice_dialog = new(ChioceDialog);
    end;
    self.m_choice_dialog:setMode(ChioceDialog.MODE_SURE);
    self.m_choice_dialog:setMessage("撤销此操作吗？");
    self.m_choice_dialog:setPositiveListener(self,self.onRestoreOneStep);
    self.m_choice_dialog:show();    
end;


-- 取消走棋
CreateEndgateScene.onRestoreOneStep = function(self) 
    self.m_board:clearSelect();   
    self.m_board:hiddenHints(); 
    self.m_board.pos:undoMakeMove();
end;


---- 撤销刚才的重做此步
--CreateEndgateScene.onRestoreOneStep = function(self) 
--    self.m_board.pos.mvList = ToolKit.copyTable(self.m_back_mvList);
--    self.mvList = ToolKit.copyTable(self.m_back_mvList);
--    self.m_board:move(self.mvList[self.mvNum]);
--    self.m_move_slider:setProgress((self.mvNum - 1)/(#self.mvList-1));
--    self.m_recreate_onestep_btn:setEnable(true);
--    self.m_restore_onestep_btn:setEnable(false);    
--end;



CreateEndgateScene.setDieChess = function(self,dieChess)
--    self:pc2ChessBox();
end


CreateEndgateScene.chessMove = function(self,data)
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

CreateEndgateScene.setBoradCode = function(self,code, endType)
    self.m_end_flag = code;
    self.m_end_type = endType;
end



CreateEndgateScene.onEngine2Gui = function(self, data)
    self.m_board:onReceive(data);
end;


CreateEndgateScene.onBoardAiMove = function(self)
    -- 只有mvNum和mvList数量相等时,说明有新的棋开始走,保存到mvList中.
    Log.i("CreateEndgateScene.onEngine2Gui--"..self.mvNum.." #self.mvList "..#self.mvList);
    if self.mvNum == #self.mvList then
        self.mvList = ToolKit.copyTable(self.m_board.pos.mvList); 
    end;
    self.mvNum = self.m_board.pos.moveNum;
    self:setChessStep(self.mvNum-1,#self.mvList - 1);    
end


CreateEndgateScene.onUpdateView = function(self)
  self.m_undo_txt:setText(UserInfo.getInstance():getUndoNum());
  self.m_tips_txt:setText(UserInfo.getInstance():getTipsNum());
end


-- 棋盒棋子滑动到棋盘上(onChessViewTouch)
CreateEndgateScene.onChessViewTouch = function(self,pc,finger_action,x,y,drawing_id_first,drawing_id_current)
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

CreateEndgateScene.chessesChange = function(self,chesses)
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
    self:updateUndoBtn();
    self:updateClearBtn();
end

CreateEndgateScene.backByHistory = function(self)
    if self.m_history_chesses and #self.m_history_chesses > 1 then
        local now_chesses = table.remove(self.m_history_chesses);
        local pre_chesses = self.m_history_chesses[#self.m_history_chesses];
        self.m_board:setChesses(pre_chesses);
        for i = 1, #self.m_boxChesses do
            self.m_boxChesses[i]:normal();
        end
        self:updateUndoBtn();
        self:updateClearBtn();
    end
end

CreateEndgateScene.updateUndoBtn = function(self)
    if self.m_history_chesses and #self.m_history_chesses > 1 then
        self.m_undo_btn:setPickable(true);
        self.m_undo_btn:setGray(false);
    else
        self.m_undo_btn:setPickable(false);
        self.m_undo_btn:setGray(true);
    end
end

CreateEndgateScene.updateClearBtn = function(self)
    -- 只有老将的时候不需要清空操作
    if self:isRedOnlyKing() and self:isBlackOnlyKing() then
        self.m_clear_all_btn:setPickable(false);
        self.m_clear_all_btn:setGray(true);
    else
        self.m_clear_all_btn:setPickable(true);
        self.m_clear_all_btn:setGray(false);
    end
end

------------------------------- config ---------------------------------
CreateEndgateScene.s_controlConfig = 
{
    [CreateEndgateScene.s_controls.back_btn]              = {"back_btn"};
    [CreateEndgateScene.s_controls.release_btn]           = {"release_btn"};
};

CreateEndgateScene.s_controlFuncMap =
{
    [CreateEndgateScene.s_controls.back_btn]              = CreateEndgateScene.onBack;
    [CreateEndgateScene.s_controls.release_btn]           = CreateEndgateScene.onRelease;
};


CreateEndgateScene.s_cmdConfig =
{
--    [CreateEndgateScene.s_cmds.engine2Gui]                = CreateEndgateScene.onEngine2Gui;
--    [CreateEndgateScene.s_cmds.board_ai_move]             = CreateEndgateScene.onBoardAiMove;
--    [CreateEndgateScene.s_cmds.updateView]                = CreateEndgateScene.onUpdateView;
--    [CreateEndgateScene.s_cmds.use_tip]                   = CreateEndgateScene.use_tip;
--    [CreateEndgateScene.s_cmds.use_undoMove]              = CreateEndgateScene.use_undoMove;
--    [CreateEndgateScene.s_cmds.tip_enable]                = CreateEndgateScene.tipEnable;
}


