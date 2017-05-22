
require("core/system")
require("core/constants");
require("core/object");
require("view/chess")
require("config/chess_config")
require("util/postion");
require("util/lua_util_function");
require("animation/animCapture");
require("animation/shockAnim");
require("animation/animCheck");
--require("config/roomres")
require("config/boardres")
--require("config/boardres1");
--require("config/boardres2");
require(DATA_PATH.."userSetInfo");


Board = class(DrawingEmpty);


Board.CHESS_MOVE = "board.chess_move";
Board.UNDO_MOVE = "board.undo_move";
Board.UNLEGALMOVE = "Board.UNLEGALMOVE";
Board.AIUNLEGALMOVE = "Board.AIUNLEGALMOVE";
Board.AIMOVE = "Board.AIMOVE";  --电脑走棋(主要用于残局);
Board.AI_UNCHANGE_MOVE = "Board.AI_UNCHANGE_MOVE"; --AI没的好的棋走，原因，不停的走相同的棋，但不是长捉长将

--Result Constants
Board.RESULT_UNKNOWN = 0;
Board.RESULT_WIN = 1;
Board.RESULT_DRAW = 2;
Board.RESULT_LOSS = 3;

-- Modes
Board.MODE_RED = 0;
Board.MODE_BLACK = 1;
Board.MODE_BOOTH = 2;
Board.MODE_EDIT = 3;
Board.ENGINE_SIDE = {[0] =1, [1] = 0, [2] = 1, [3] = -1};

Board.boardres_map = boardres_map;

--Board.setBoardresMap = function(map)
--    Board.boardres_map = map;
--end

Board.ctor = function (self ,boardW,boardH,room,flag, boardtype)
	self.m_room = room;
    self.m_room.m_board = self;
    -- boardtype == nil是默认board，BOARD_TYPE_CUSTOM 摆棋(创建残局)board，BOARD_TYPE_START 打谱board
    self.m_boardtype = boardtype;
	self.m_engine = ENGINE_IDLE;

    Board.boardres_map = UserSetInfo.getInstance():getChessRes();

	self.pos = new(Postion);
	self.m_chess_map = {}; --所有new好滴棋子
	self.m_chesses = {}    --这一盘棋中的棋子
	self.m_dieChess = {};  
	self.m_squares  = {};
	self.m_pcList = {};  --死亡棋子的ID;
	self.m_sqSelected = 0; --选择的棋子位置
	self.m_sqSelected90 = 0; --选择的棋子90坐标位置
	self.m_sqSrc = 0;    --棋子移动的起始位置
	self.m_sqX = 0;
	self.m_sqY = 0;


	self.m_boardW = boardW;
	self.m_boardH = boardH;
	self:setSize(boardW,boardH);
    self.m_chessSize = 80 * math.min(boardW/9,boardH/10) / 80; --83
    self.m_xFrom = (boardW - self.m_chessSize*9)/2;
    self.m_yFrom = (boardH - self.m_chessSize*10)/2; 

    self.m_hints = {};
    self.m_hintSize = Board.boardres_map["can_move_icon.png"].width;
    self.m_xHint = (self.m_chessSize - self.m_hintSize)/2;
    self.m_yHint = (self.m_chessSize - self.m_hintSize)/2;
    local file;
    for i = 1,18 do
    	file = Board.boardres_map["can_move_icon.png"];
   		self.m_hints[i]	= new(Image,file);
   		self.m_hints[i]:setSize(self.m_hintSize,self.m_hintSize);
   		self.m_hints[i]:setVisible(false);
   		self.m_hints[i]:setLevel(CHESS_HINT_LEVEL);
   		self:addChild(self.m_hints[i]);
   	end

   	self.m_pathFromSize = self.m_chessSize*2/3;
   	self.m_pathToSize = self.m_chessSize;
   	self.m_pathFromDiffX = ( self.m_chessSize - self.m_pathFromSize ) /2 ---相对于同一棋盘位置的坐标差值

	file = Board.boardres_map["pre_postion.png"];
   	self.m_movePathFromImg = new(Image,file);
   	self.m_movePathFromImg:setSize(self.m_pathFromSize,self.m_pathFromSize);
   	self.m_movePathFromImg:setLevel(CHESS_PATH_LEVEL);
   	self.m_movePathFromImg:setVisible(false);
   	self:addChild(self.m_movePathFromImg);

	file = Board.boardres_map["new_postion.png"];
   	self.m_movePathToImg = new(Image,file);
   	self.m_movePathToImg:setSize(self.m_pathToSize+4,self.m_pathToSize+4);
   	self.m_movePathToImg:setLevel(CHESS_PATH_LEVEL);
   	self.m_movePathToImg:setVisible(false);
   	self:addChild(self.m_movePathToImg);


    self.m_hintPathFromImgSize = self.m_chessSize+self.m_chessSize/4;
    self.m_hintPathFromImgDiffX = ( self.m_chessSize - self.m_hintPathFromImgSize ) /2

	file = Board.boardres_map["tip_move_from.png"];
   	self.m_hintPathFromImg = new(Node)
    local img = new(Image,file);
    img:setAlign(kAlignCenter);
    self.m_hintPathFromImg:addChild(img);
   	self.m_hintPathFromImg:setSize(self.m_hintPathFromImgSize,self.m_hintPathFromImgSize);
   	self.m_hintPathFromImg:setLevel(CHESS_HINT_LEVEL);
   	self.m_hintPathFromImg:setVisible(false);
   	self:addChild(self.m_hintPathFromImg);

    
	file = Board.boardres_map["tip_move_to.png"];
   	self.m_hintPathToImg = new(Image,file);
   	self.m_hintPathToImg:setSize(self.m_pathFromSize,self.m_pathFromSize);
   	self.m_hintPathToImg:setLevel(CHESS_HINT_LEVEL);
   	self.m_hintPathToImg:setVisible(false);
   	self:addChild(self.m_hintPathToImg);

	self.m_mark_x,self.m_mark_y = -311,-314;
   	self.m_pos_mark = new(Image,"drawable/chess_mark.png");
   	self.m_pos_mark:setPos(self.m_mark_x,self.m_mark_y);
    self.m_pos_mark:setSize(700,700);
   	self.m_pos_mark:setVisible(false);
   	self:addChild(self.m_pos_mark);

    self:closeTouchEvent(flag);


--    EventDispatcher.getInstance():register(Event.Call , self.m_room ,self.m_room.EventRespone);
end

function Board:setBoardresMap(res)
    if type(res) ~= "table" then return end
    Board.boardres_map = res
end

Board.closeTouchEvent = function(self, isCloseTouchEvent)
    if isCloseTouchEvent then
        self:setEventTouch(nil,nil);
    else
        self:setEventTouch(self,self.onTouch);
    end;
end;

Board.clearAnimPlay = function(self)
	AnimKill.deleteAll();
    AnimTimeout.deleteAll();
    AnimJam.deleteAll();
end

Board.newgame = function(self,model,fenStr,chessMap)

	kEffectPlayer:playEffect(Effects.AUDIO_GAME_START);
    self:clearAnimPlay();
	self.m_model = model;
	--使用指定fen串
	Board.resetFenPiece();
	if fenStr and fenStr ~= GameCacheData.NULL then
		self.pos:fromFen(fenStr);
        self.m_fen = fenStr
	else
		self.pos:fromFen(Postion.STARTUP_FEN[1]);
        self.m_fen = Postion.STARTUP_FEN[1];
	end
	self:hiddenHints();
	self:hiddenMovePath();
	self:hiddenHintPath();
	self:ready(chessMap);
end



Board.ready = function(self,chess_map)
    Log.e("Board.ready " .. self.m_engine);
	self:stopThink();

	self.result = Board.RESULT_UNKNOWN;
	self.m_moveDraw = false;
    self:clearSelect();
	self.m_flipped = (self.m_model == Board.MODE_BLACK);
	self:setDieChess();   --设置被吃棋子
	self:dismissChess();
	self:copyChess90(chess_map);
	self.m_gameStart = true;
end

--传入残局棋谱
Board.ending_game = function(self,fen_str)
    kEffectPlayer:playEffect(Effects.AUDIO_GAME_START);

	self:dismissChess();
	self.m_model = Board.MODE_RED;


	self.pos:fromFen(fen_str);
	self:setEngineBegin(fen_str);  --与AI引擎交互的数据;
	Board.resetFenPiece();
	local chessMap = self:fen2chessMap(fen_str);
    GameCacheData.getInstance():saveString(GameCacheData.DAPU_LAST_BORAD_FEN,fen_str);
	GameCacheData.getInstance():saveString(GameCacheData.DAPU_LAST_CHESS_STR,table.concat(chessMap,MV_SPLIT));
	self:hiddenHints();
	self:hiddenMovePath();
	self:hiddenHintPath();
	self:ready(chessMap);

	self:clearSelect();
end

Board.clearSelect = function(self)
	if(self.m_selectChess ~= nil and self.m_selectChess ~= 0) then
        self.m_sqSelected = 0;
        self.m_sqSelected90 = 0;
		self.m_selectChess:normal();
		self.m_selectChess = nil;
	end
end


Board.fen2chessMap = function(self,fen)
	local RANK_TOP,FILE_LEFT = 1,1;
	local RANK_BOTTOM,FILE_RIGHT= 10,9;

	--置空棋盘
	local chessMap = {};
	for index = 1,90 do
		chessMap[index] = NOCHESS;
	end

	local y = RANK_TOP;
	local x = FILE_LEFT;
	local index = 1;
	if (fen == nil or 0 == #fen) then
		print_string("fen is nil");
		return;
	end
	local c = fen:sub(index,index);
	while (c ~= ' ') do 
		if (c == '/') then
			x = FILE_LEFT;
			y = y+1;
			if (y > RANK_BOTTOM) then
				break;
			end
		elseif (c >= '1' and c <= '9') then
			for k = 1,c do
				if (x >= FILE_RIGHT) then
					break;
				end
				x = x+1;
			end
		elseif (c >= 'A' and c <= 'Z') then
			if (x <= FILE_RIGHT) then
				local pt = self:fenPiece(c);
				chessMap[(y-1)*9+x] = pt;
				x = x+1;
			end
		elseif (c >= 'a' and c <= 'z') then
			if (x <= FILE_RIGHT) then
				local pt = self:fenPiece(c);
				chessMap[(y-1)*9+x] = pt;
				x = x + 1;
			end
		end
		index = index + 1;
		if (index >= #fen+1) then
			return chessMap;
		end
		c = fen:sub(index,index);
	end
	index = index + 1;
	if (index >= #fen+1) then
		return chessMap;
	end

	local flag = fen:sub(index,index);
	while flag == ' ' do
		index = index + 1;
		flag = fen:sub(index,index);
	end
	--self.sdPlayer = (flag == 'b' and 1 or 0);

	return chessMap;

end

Board.resetFenPiece = function()
	for key,value in pairs(fen_piece) do
		value.index = 0;
	end
end

Board.fenPiece = function(self,c) 

	local piece_table = fen_piece[c];
	piece_table.index = piece_table.index + 1;
	local index = piece_table.index;
	return piece_table[index] or NOCHESS;
	-- if c == 'K' then
	-- 	return R_KING;
	-- elseif c == 'A'then
	-- 	return R_BISHOP1;
	-- elseif c == 'B' or c == 'E' then
	-- 	return R_ELEPHANT1;
	-- elseif c =='H' or c =='N' then
	-- 	return R_HORSE1;
	-- elseif c =='R' then
	-- 	return R_ROOK1;
	-- elseif c =='C' then
	-- 	return R_CANNON1;
	-- elseif c =='P' then
	-- 	return R_PAWN1;
	-- elseif c == 'k' then
	-- 	return B_KING;
	-- elseif c == 'a'then
	-- 	return B_BISHOP1;
	-- elseif c == 'b' or c == 'e' then
	-- 	return B_ELEPHANT1;
	-- elseif c =='h' or c =='n' then
	-- 	return B_HORSE1;
	-- elseif c =='r' then
	-- 	return B_ROOK1;
	-- elseif c =='c' then
	-- 	return B_CANNON1;
	-- elseif c =='p' then
	-- 	return B_PAWN1;
	-- else
	-- 	return NOCHESS;
	-- end
end

Board.gameStart = function(self)
	self.m_gameStart = true;
end


Board.gameClose = function(self)
	self.m_gameStart = false;
end

Board.setDieChess = function(self)
	for i = 8, 22 do
		self.m_dieChess[i] = piece_id_num[i];
	end

	for sq = 0,255 do
		local pc = self.pos.squares[sq];
		if  pc > 0 then
			self.m_dieChess[pc] = self.m_dieChess[pc] - 1;
		end
	end
    if self.m_room and self.m_room.setDieChess then
	    self.m_room:setDieChess(self.m_dieChess);
    end
end

Board.getDieChess = function(self)
    return self.m_dieChess
end

Board.copyChess90 = function(self,chess_map)
	if chess_map == nil or chess_map == GameCacheData.NULL then
		chess_map = red_down_game90;
	end
	
	for sq = 1 ,90 do
		local pc = chess_map[sq] or 0;
        pc = pc + 0
		self.m_chesses[sq] = pc;
		if pc ~= nil and pc > 0 then
			local sq_ = self:flip90(sq);
			local chess = self:getChess(pc);
			local x = self:getX90(sq_);
			local y = self:getY90(sq_);
			self.m_chesses[sq] = chess;
			chess:setPos(x,y);
		end
	end
end

Board.getChess90xy = function(self,sq)
	local sq_ = self:flip90(sq)
    return self:getX90(sq_),self:getY90(sq_)
end

Board.getChessSize = function(self)
    return self.m_chessSize
end

Board.dismissChess = function(self)

	for sq = 1,90 do
		chess = self.m_chesses[sq] ;
		if chess and chess ~= 0 then
			chess:setVisible(false)
		end

	end
    if self.m_room and self.m_room.clearDiechess then
	    self.m_room:clearDiechess();
    end
	self:hiddenHints();
	self:hiddenMovePath();
	self:hiddenHintPath();
	self.m_gameStart = false;
end

Board.getChess = function(self,pc)

	if not pc or pc <= 0 then
		return 0;
	end
	
	local chess = self.m_chess_map[pc];
	if(chess == nil or chess == 0) then
		print_string("Board.getChess self.m_chess_map[pc] = nil ,pc = " .. pc);
		chess = new(Chess,pc,self.m_chessSize,self.m_flipped);
		chess:setSize(self.m_chessSize,self.m_chessSize);
		self:addChild(chess);
		self.m_chess_map[pc] = chess;
	end
	chess:setVisible(true);
	return chess;
end






Board.flip90 = function(self,sq)
	return (self.m_flipped and 91-sq) or sq;
end

Board.getX90 = function(self,sq) 
	return self.m_xFrom +  ((sq-1)%9) * self.m_chessSize;
end

Board.getY90 = function(self,sq) 
	return self.m_yFrom + math.floor((sq-1)/9) * self.m_chessSize;
end

Board.getMarkPos = function(self,col,row)
	local x = self.m_mark_x + col*self.m_chessSize;
	local y = self.m_mark_y + row*self.m_chessSize;
	return x,y;
end


Board.onTouch = function (self,finger_action,x,y,drawing_id_first,drawing_id_current)
	if not self.m_gameStart then
		print_string("game not start");
		return;
	end
    
    if RoomProxy.getInstance():getCurRoomType() == RoomConfig.ROOM_TYPE_WATCH_ROOM then
        if OnlineRoomSceneNew.IS_NEW  then
            if self.m_room.mModule.showFullScreen then
                self.m_room.mModule:showFullScreen();
            end;
        end;

		return;
	end

    if not self.m_boardtype then
        if self.m_model ~= self.pos.sdPlayer then
		    print_string(string.format(" not  you turn!,self.m_model = %d,self.pos.sdPlayer = %d",self.m_model,self.pos.sdPlayer));
		    return;
        end;
    end;



    x ,y = self:convertSurfacePointToView(x,y);
    if x < 0 then
    	x = 0;
    end
    if x > self.m_boardW then
    	x = self.m_boardW;
    end
    if y < 0 then
    	y = 0;
    end
    if y > self.m_boardH then
    	y = self.m_boardH;
    end    

	if finger_action == kFingerDown then
		self.m_down = true;
		self.m_downX = x;
		self.m_downY = y;



		local downC = math.floor((x - self.m_xFrom) / self.m_chessSize);
		local downR = math.floor((y - self.m_yFrom) / self.m_chessSize);
        -- 可根据self.m_boardtype区分onTouchDown和onPutChessTouchDown
        local pos_x,pos_y = self:getMarkPos(downC,downR);
        self.m_pos_mark:setPos(pos_x,pos_y);
        self.m_pos_mark:setVisible(true);

		self:onTouchDown(downC,downR);
	
		print_string("down in " .. downC .. "," .. downR);


	elseif finger_action == kFingerMove then
		
		local moveC = math.floor((x - self.m_xFrom) / self.m_chessSize);
		local moveR = math.floor((y - self.m_yFrom) / self.m_chessSize);
		local pos_x,pos_y = self:getMarkPos(moveC,moveR);
		self.m_pos_mark:setPos(pos_x,pos_y);

		if(not self.isChessCanMove ) then
			return
		end

		if self.m_selectChess ~= nil and  self.m_selectChess ~= 0 then
			local diffX = x - self.m_downX;
			local diffY = y - self.m_downY;
			local orgX,orgY = self.m_selectChess:getPos();
			self.m_selectChess:setPos(orgX + diffX,orgY + diffY);
			self.m_downX = x;
			self.m_downY = y;

			print_string("move x =  " .. x .. "y = " .. y);
		end
	elseif finger_action == kFingerUp then 
    	self.isChessCanMove = false;
		self.m_pos_mark:setVisible(false);

	    self.m_upX = x;
		self.m_upY = y;

		local upC = math.floor((x - self.m_xFrom) / self.m_chessSize);
		local upR = math.floor((y - self.m_yFrom) / self.m_chessSize);

		if upC < 0 then
	    	upC= 0;
	    end
	    if upC > 8 then
	    	upC = 8;
	    end
	    if upR < 0 then
	    	upR = 0;
	    end
	    if upR > 9 then
	    	upR = 9;
	    end
		print_string("up in " .. upC .. upR);

		self:onTouchUp(upC,upR);


	else

	end


end

-- 根据棋盘x,y坐标，获取格子
Board.getSquareFromXY = function(self, x, y)
	local C = math.floor((x - self.m_xFrom) / self.m_chessSize + 0.5); -- 四舍五入
	local R = math.floor((y - self.m_yFrom) / self.m_chessSize + 0.5);    
    local sq = Postion.COORD_XY(C + Postion.FILE_LEFT,R + Postion.RANK_TOP);
	local sq_ = (self.m_flipped and Postion.SQUARE_FLIP(sq)) or sq;
    return sq_;
end;

-- 根据格子，获取棋盘上x,y坐标
Board.getXYFromSquare = function(self, sq)
    local C, R = Postion.RANK_Y(sq), Postion.FILE_X(sq);
    C = C - Postion.RANK_TOP;
    R = R - Postion.FILE_LEFT;
    local sq90 = Board.COORD_XY(C, R);
    return self:getX90(sq90), self:getY90(sq90);
end;

-- 根据90棋盘，获取棋盘上x,y坐标
Board.getXYFromSquare90 = function(self, sq90)
    return self:getX90(sq90), self:getY90(sq90);
end;

Board.selectedChess = function(self, sq_, sq90_, downC, downR)
	self:clearSelect();
    if self.m_chesses[sq90_] == 0 then return end
    self.m_sqSelected = sq_;
    self.m_sqSelected90 = sq90_;
    self.m_selectChess = self.m_chesses[sq90_];
    self.m_selectChess:selected();
    self.m_downR = downR;
    self.m_downC = downC;    
end

Board.clearChess = function(self,sq90_, sq_)
    self:clearSelect();
    self.m_chesses[sq90_] = 0;
    self.pos.squares[sq_] = 0;
end

function Board:isSelectedChess()
    return self.m_selectChess ~= nil;
end


-- 摆子和正常下棋合在一起了，后期可考虑在onTouch方法里根据self.m_boardtype区分比较好
Board.onTouchDown = function(self,downC,downR)

	local sq = Postion.COORD_XY(downC + Postion.FILE_LEFT,downR + Postion.RANK_TOP);
	local sq_ = (self.m_flipped and Postion.SQUARE_FLIP(sq)) or sq;

	local sq90 = Board.COORD_XY(downR,downC);
	local sq90_ = self:flip90(sq90);

	local pc  = self.pos.squares[sq_];   --self.m_squares[sq_];  --self.m_chesses[downR][downC];
    
    -- 如果有棋子
	if pc ~= nil and pc ~= 0 then
        -- 是否是同一边的棋子
        local isCurPlayerChess = bit.band(pc,Postion.SIDE_TAG(self.pos.sdPlayer)) ~= 0;
        -- 棋盘是摆子阶段，点击的是同一个棋子，就放回到棋盒当中
        if self.m_boardtype == BOARD_TYPE_CUSTOM  then
            self:onCustomDown(downC,downR,sq_,sq90_)
        else
            local isNewMoveType = GameCacheData.getInstance():getInt(GameCacheData.MOVE_MODE,1) == 2;
            if isCurPlayerChess and not isNewMoveType then
                self:selectedChess(sq_, sq90_, downC, downR);
                self:moveHint();
--                self:hiddenMovePath();
            end
        end
        -- 摆子是点下选择 下棋是抬起选中
        -- 点中的是同一个棋子 可以移动
        if self.m_sqSelected == sq_ then
            self.isChessCanMove = true;
        end
	else

	end
end

-- 摆子 按下事件
function Board:onCustomDown(downC, downR, sq_, sq90_)
    local pc  = self.pos.squares[sq_];
    kEffectPlayer:playEffect(Effects.AUDIO_CHESS_SELECT);
    if self.m_sqSelected90 == sq90_ then
        if self.m_chesses[sq90_].m_isPop then
            if self.m_chesses[sq90_].m_pc == R_KING or self.m_chesses[sq90_].m_pc == B_KING then
                return;
            end;
            -- 红帅黑将,则返回
            self.m_chesses[sq90_].m_defaultPc = pc;
            self.m_chesses[sq90_].m_defaultSq = sq_;
            self.m_room:pc2ChessBox(self.m_chesses[sq90_]);
            self:clearChess(sq90_, sq_);
            -- 添加摆棋历史记录
            if self.m_room and self.m_room.chessesChange then
                self.m_room:chessesChange(ToolKit.copyTable(self.m_chesses));
            end
        else
            self:selectedChess(sq_, sq90_, downC, downR);
        end;
    else
        self:selectedChess(sq_, sq90_, downC, downR);
    end;
end

-- 摆子和正常下棋合在一起了，后期可考虑在onTouch方法里根据self.m_boardtype区分比较好
Board.onTouchUp = function(self,upC,upR)
--    if kDebug then
--        self:console_gameover(self.m_model + 1,ENDTYPE_KILL);--单机测试,测试完毕注释掉
--        return;
--    end;

	local sq = Postion.COORD_XY(upC + Postion.FILE_LEFT,upR + Postion.RANK_TOP);
	local sq_ = (self.m_flipped and Postion.SQUARE_FLIP(sq)) or sq;

	local sq90 = Board.COORD_XY(upR,upC);
	local sq90_ = self:flip90(sq90);

	local pc  = self.pos.squares[sq_] ;  --self.m_squares[sq_];  --self.m_chesses[downR][downC];
    if self:isSelectedChess() then
        if pc ~= nil and pc ~= 0 and bit.band(pc,Postion.SIDE_TAG(self.pos.sdPlayer))~= 0 then -- ~=0 是同一边的
            self:chessToSrc();
            if self.m_boardtype == BOARD_TYPE_CUSTOM then

            else
                -- 交换选择棋子
                local isNewMoveType = GameCacheData.getInstance():getInt(GameCacheData.MOVE_MODE,1) == 2;
                if isNewMoveType then
                    self:selectedChess(sq_, sq90_, upC, upR);
                    self:moveHint();
                end
            end
	    else
		    self.m_upC = upC;
		    self.m_upR = upR;
		    local mv = Postion.MOVE(self.m_sqSelected,sq_);
            -- 如果是摆棋
            if self.m_boardtype == BOARD_TYPE_CUSTOM then
                local isPut, message = self:putChess(mv);
                if isPut then
                    self:chessToDst(upC,upR);
                    -- 棋子格子互换[0~255];
                    self.pos.squares[sq_] = self.pos.squares[self.m_sqSelected];
                    self.pos.squares[self.m_sqSelected] = 0;   
                    -- 90棋盘的棋子res互换
                    self.m_chesses[sq90_] = self.m_chesses[self.m_sqSelected90];   
                    self.m_chesses[self.m_sqSelected90] = 0;  
                    self:clearSelect();
                    self.m_sqSelected90 = 0;  
                    -- 摆完子后，撤销按钮不可用
                    -- 添加摆棋历史记录
                    if self.m_room and self.m_room.chessesChange then
                        local chesses = {};
                        for i,v in pairs(self.m_chesses) do
                            chesses[i] = v;
                        end
                        self.m_room:chessesChange(chesses);
                    end            
                else
                    self:chessToSrc();
                    -- ugly,后续干掉重写
                    if self.m_sqSelected ~= sq_ then
                        self:clearSelect();
                        ChatMessageAnim.play(self.m_room,3,message);
                    end
                end
            elseif self.m_boardtype == BOARD_TYPE_START then
                if self:addMove(mv) then
				    self.m_room:chessMove(self:mv2ChessMove(mv)); 
                end
            else
                local code = self:addMove(mv);
                if code then
				    local data =  self:mv2ChessMove(mv);
				    self:chessMove(mv);
				    EventDispatcher.getInstance():dispatch(Event.Call, CONSOLE_SAVE_CHESS_MOVE,data);

				    self.m_room:chessMove(data);


	                self:clearSelect();  
                end
            end
	    end
	else-- 棋盒棋子回到棋盘
        if self.m_boardtype == BOARD_TYPE_CUSTOM then
            local selected =  Chess.s_selected; -- 因为下面方法清理了状态  这里保存下
            self:setChess2Board(upC, upR,sq_,sq90_);
            -- 添加摆棋历史记录
            if selected and self.m_room and self.m_room.chessesChange then
                self.m_room:chessesChange(ToolKit.copyTable(self.m_chesses));
            end
        else
            if pc ~= nil and pc ~= 0 and bit.band(pc,Postion.SIDE_TAG(self.pos.sdPlayer))~= 0 then
                self:selectedChess(sq_, sq90_, upC, upR);
                self:moveHint();
--                self:hiddenMovePath();
            end
        end
    end
end

-- 由坐标获得行列
Board.getCRfromXY= function(self, x, y)
 	local upC = math.floor((x - self.m_xFrom) / self.m_chessSize);
	local upR = math.floor((y - self.m_yFrom) / self.m_chessSize);   
    return upC, upR;
end;


-- 由行列获得sq
Board.getSqfromCR = function(self,upC, upR)
	local sq = Postion.COORD_XY(upC + Postion.FILE_LEFT,upR + Postion.RANK_TOP);
	local sq_ = (self.m_flipped and Postion.SQUARE_FLIP(sq)) or sq;
	local sq90 = Board.COORD_XY(upR,upC);
	local sq90_ = self:flip90(sq90);    
    return sq_, sq90_;
end;



Board.setChess2Board = function(self,upC, upR,sq_,sq90_)
    -- Chess.s_selected.m_defaultPc，在chessBox传回到棋盘时的棋子
    -- 棋盒有棋子选中     
    if Chess.s_selected and Chess.s_selected.m_defaultSq then
        local mv = Postion.MOVE(Chess.s_selected.m_defaultSq,sq_);
        local isPut, message = self:putChess(mv, Chess.s_selected.m_defaultPc, self.pos.squares[sq_]);
        if isPut then
            if Chess.s_selected.m_defaultPc then
                self.pos.squares[sq_] = Chess.s_selected.m_defaultPc;
                self.m_chesses[sq90_] = Chess.s_selected;
                self.m_room:chessInBox2Board(Chess.s_selected);
                self:addChild(Chess.s_selected);
                local cx = self.m_xFrom + self.m_chessSize * (upC);
		        local cy = self.m_yFrom + self.m_chessSize * (upR);
                Chess.s_selected:setPos(cx, cy);
                Chess.s_selected:normal();
            end
        else-- 放不了棋子就返回棋盒
            Chess.s_selected:setPos(0,0);
            Chess.s_selected:normal();
            ChatMessageAnim.play(self.m_room,3,message);
        end
    end
end

Board.setChesses = function(self,chesses)
--    for now_sq90_,now_chess in pairs(self.m_chesses) do
--        if now_chess ~= 0 then
--            local isExist = false
--            for pre_sq90_,pre_chess in pairs(chesses) do
--                if pre_chess ~= 0 then
--                    if now_chess == pre_chess then
--                        isExist = true;
--                        local x,y = self:getXYFromSquare90(pre_sq90_);
--                        pre_chess:setPos(x,y);
--                        break;
--                    end
--                end
--            end
--            if not isExist then
--                if self.m_room and self.m_room.pc2ChessBox then

--                end
--            end
--            now_chess:normal();
--        end
--    end
    for sq90_,chess in pairs(self.m_chesses) do
        if chess ~= 0 then
            local sq_ = Board.Tosq(sq90_);
            if chess:getPC() ~= 105 and chess:getPC() ~= 205 then
                self.m_room:pc2ChessBox(chess);
                self:clearChess(sq90_,sq_);
            end;
        end
    end
    for sq90_,chess in pairs(chesses) do
        self.m_chesses[sq90_] = chess;
        if chess ~= 0 then
            if chess:getPC() ~= 105 and chess:getPC() ~= 205 then
                local sq_ = Board.Tosq(sq90_);
                self.pos.squares[sq_] = self:pcToPos_Pc(Board.charAt(chess:getPC()));
                self.m_room:chessInBox2Board(chess);
                self:addChild(chess);
                local x,y = self:getXYFromSquare90(sq90_);
                chess:setPos(x,y);
                chess:normal();
            end;
        end
    end
    Chess.s_selected = nil;
end
-- 将chess 的 pc 转换为 positon里面的 pc
Board.pcToPos_Pc = function(self,c)
    if (c >= 'A' and c <= 'Z') then
		local pt = self.pos:fenPiece(c);
		if (pt >= 0) then
			return (pt + 8);
		end
	elseif (c >= 'a' and c <= 'z') then
		local pt = self.pos:fenPiece(string.upper(c));
		if (pt >= 0) then
			return (pt + 16);
		end
	end
end

Board.moveHint = function(self)
	if self.m_sqSelected ~= nil and  self.m_sqSelected ~= 0 then
		mvs = self.pos:generateChessMoves(self.m_sqSelected)
		for i = 1,#mvs do
			local mv = mvs[i];
			local sq = Postion.DST(mv);
			local sq90 = Board.To90(sq);
			local sq90_ = self:flip90(sq90);
			-- local cx = self.m_xHint - self.m_xFrom  + self:getX90(sq90_);
			-- local cy = self.m_yHint + self.m_yFrom + self:getY90(sq90_);

			local cx = self.m_xHint + self:getX90(sq90_);
			local cy = self.m_yHint + self:getY90(sq90_);

			self.m_hints[i]:setVisible(true)
			self.m_hints[i]:setPos(cx,cy);
		end

		for i = #mvs+1 ,18 do
			self.m_hints[i]:setVisible(false);
		end
	end
end

-- 能否点掉棋盘棋子，如果点掉被将军返回false
Board.isDelPiece = function(self, sq_, pc)
    self.pos:delPiece(sq_, pc);
    self.pos.sdPlayer = 1;
    if self.pos:checked() then
        self.pos:addPiece(sq_, pc);
        self.pos.sdPlayer = 0;
        return false;
    else
        self.pos:addPiece(sq_, pc);
        self.pos.sdPlayer = 0;
        return true;
    end;
end





-- 摆法是否导致黑子被将军
Board.isChecked = function(self,mv, _pcSrc, _pcDst)
    -- _pcSrc为nil,说明摆棋来自board
    if not _pcSrc then 
        self.m_moveFromBoard = true;
    else 
        self.m_moveFromBoard = false; 
    end;
    local sqSrc = Postion.SRC(mv);
	local pcSrc = _pcSrc or self.pos.squares[sqSrc];
	local sqDst = Postion.DST(mv);

    -- 置黑方先走
    self.pos.sdPlayer = 1
    if self.m_moveFromBoard then
        self.pos:delPiece(sqSrc, pcSrc);
    end;
    self.pos:addPiece(sqDst, pcSrc);

    if self.pos:checked() then
        self.pos.sdPlayer = 0
        self.pos:delPiece(sqDst, pcSrc);
        if self.m_moveFromBoard then
            self.pos:addPiece(sqSrc, pcSrc);
        end;
        return true; 
    else
        self.pos.sdPlayer = 0
        self.pos:delPiece(sqDst, pcSrc);
        if self.m_moveFromBoard then
            self.pos:addPiece(sqSrc, pcSrc);
        end;
        return false;
    end;    
end;



-- 检查摆子是否符合规则
Board.putChess = function(self, mv, pcSrc, pcDst)
	if self.pos:isLegalPutChessMove(mv, pcSrc, pcDst) then
--        if self:isChecked(mv,pcSrc, pcDst) then
--            return false,"摆法导致将军，请重新摆子";
--        else
            return true,"";
--        end;
    else    
        return false,"摆法不合规则，请重新摆子";
    end;
end;




Board.addMove = function(self,mv)
	local code = CHESS_MOVE_NOTHING;
	if(not self.pos:legalMove(mv)) then
		code = -1;
		self:chessToSrc();
		EventDispatcher.getInstance():dispatch(Event.Call,Board.UNLEGALMOVE,code);      
		print_string("not legalmove " .. mv);
		return false;
	end

	local pc,check = self.pos:makeMove(mv);

	if(not pc) then
		code = -9;
		self:chessToSrc();
		EventDispatcher.getInstance():dispatch(Event.Call,Board.UNLEGALMOVE,code);   
		print_string("checked !!! " .. mv);
		return false;
	end

	if not self.m_severMove and self.pos:checkLoop() then
		code = -11;
		self:chessToSrc();
        self.pos:undoMakeMove() -- 取消上一次走棋
		EventDispatcher.getInstance():dispatch(Event.Call,Board.UNLEGALMOVE,code);   
		print_string("checkLoop " .. mv);
		return false;
	end

--    if not self.m_severMove and self.pos:checkLoopStatus() then
--		code = CHESS_MOVE_LOOG_PLAY;
--		self:chessToSrc();
--        self.pos:undoMakeMove() -- 取消上一次走棋
--		EventDispatcher.getInstance():dispatch(Event.Call,Board.UNLEGALMOVE,code);   
--		return false;
--	end

	self.m_severMove = false;  --走完棋后初始化值，当服务器走棋时，变成true;
 
	if pc and pc > 0 then   --有吃子  

		self.m_dieChess[pc] = (self.m_dieChess[pc] and (self.m_dieChess[pc] + 1)) or 1;
        if self.m_room and self.m_room.setDieChess then
	        self.m_room:setDieChess(self.m_dieChess);
        end

		code = CHESS_MOVE_EAT;
	end

	if check then
		code = CHESS_MOVE_CHECK;
	end

	local turn = (self.m_model ~= self.pos.sdPlayer);  --是否是（下面滴玩家）（自己）	
	
    -- 是否将死
	if self.pos:isMate() then
		local endType = ENDTYPE_KILL;
		if code ~= CHESS_MOVE_CHECK then  --困毙
			endType = ENDTYPE_JAM;
		end

		if self.pos.sdPlayer == 1 then
			code = CHESS_MOVE_OVER_RED_WIN;
		else
			code = CHESS_MOVE_OVER_BLACK_WIN;
		end
		self:console_gameover(code,endType);
		print_string("Board.addMove gameover code =  " .. code);
	end

--	self.m_room:playMoveSound(code,turn);
    self:playMoveSound(code, turn);
	EventDispatcher.getInstance():dispatch(Event.Call,Board.CHESS_MOVE); 

	return code;
end

Board.isDeath = function(self,play)
    local pre_play = self.pos.sdPlayer;
    self.pos.sdPlayer = play;
    local ret = self.pos:isMate();
    self.pos.sdPlayer = pre_play;
    return ret;
end

Board.isChecked = function(self,play)
    local pre_play = self.pos.sdPlayer;
    self.pos.sdPlayer = play;
    local ret = self.pos:checked();
    self.pos.sdPlayer = pre_play;
    return ret;
end

Board.console_gameover = function(self,code,endType)
    self.m_room:setBoradCode(code, endType);
	if endType == ENDTYPE_KILL then
		AnimKill.play(self:getAnimHandlerView(),self.m_room,self.m_room.showResultDialog);
	elseif  endType == ENDTYPE_TIMEOUT then
		AnimTimeout.play(self:getAnimHandlerView(),self.m_room,self.m_room.showResultDialog);
	elseif endType == ENDTYPE_JAM then
		AnimJam.play(self:getAnimHandlerView(),self.m_room,self.m_room.showResultDialog);
	elseif endType == ENDTYPE_SURRENDER then
		local message = "认输!!!";
        ChessToastManager.getInstance():show(message);
		self.m_room:showResultDialog();
	elseif endType == ENDTYPE_UNLEGAL then
		local message = "长打作负!!!";
        ChessToastManager.getInstance():show(message);
		self.m_room:showResultDialog();
	elseif endType == ENDTYPE_UNCHANGE then
		local message = "双方不变作和!";
        ChessToastManager.getInstance():show(message);
		self.m_room:showResultDialog();
    else
		self.m_room:showResultDialog();
	end
    
    self:gameClose();
end





--每次走棋的时候会调
Board.playMoveSound = function(self,code,isDown)
	local sex = UserInfo.getInstance():getSex();
	if code == CHESS_MOVE_NOTHING then
		kEffectPlayer:playEffect(Effects.AUDIO_MVOE_CHESS);
	elseif code == CHESS_MOVE_EAT then
		ShockAnim.play(self:getAnimHandlerView());
		if isDown then
            kEffectPlayer:playChat(sex, EffectsSex.AUDIO_READ_CHI);
		else
            kEffectPlayer:playChat(sex, EffectsSex.AUDIO_READ_CHI);
		end
	elseif code == CHESS_MOVE_CHECK then
		AnimCheck.play(self:getAnimHandlerView());
		if isDown then
            kEffectPlayer:playChat(sex, EffectsSex.AUDIO_READ_JJ);
		else
            kEffectPlayer:playChat(sex, EffectsSex.AUDIO_READ_JJ);
		end
	end
end

Board.chessMove = function(self,mv,noMoveAnim)
	local sqSrc = Postion.SRC(mv);
	local sqDst = Postion.DST(mv);

	local sqSrc90 = Board.To90(sqSrc);
	local sqDst90 = Board.To90(sqDst);

	local sqSrc90_ = self:flip90(sqSrc90);
	local sqDst90_ = self:flip90(sqDst90);
	self.m_moveChess = self.m_chesses[sqSrc90];

	if self.m_moveChess == nil or self.m_moveChess == 0 then
		print_string("self.m_moveChess error !!!");
		return false;
	end

    if self.m_preMoveChess then
        self.m_preMoveChess:moveEnd();
        self.m_preMoveChess = nil;
    end

	self.m_move_end_sqSrc90 = sqSrc90;   --移动动画结束后的提示位置
	self.m_move_end_sqDst90 = sqDst90;

	local cx = self:getX90(sqDst90_);
	local cy = self:getY90(sqDst90_);
	local ox,oy = self.m_moveChess:getPos();


	self.m_moveChess:setPos(cx,cy);

    if not noMoveAnim then
        self.m_moveChess:setMove(ox,oy,self,self.setMoveEnd);
    end;
	self.m_preMoveChess = self.m_moveChess;

	print_string(" chessMove sqSrc90_ =  " .. sqSrc90.. "  sqDst90_ = " .. sqDst90);
	local dieChess = self.m_chesses[sqDst90]; --self.m_chesses[upR][upC];
	if dieChess ~= nil and dieChess ~= 0 then
		print_string(" dieChess =  " .. dieChess:getPC());
		self.m_pcList[self.pos.moveNum-1] = dieChess:getPC();
		dieChess:setVisible(false);
        if self.m_boardtype == BOARD_TYPE_START then
            if dieChess:getPC() ~= 105 and dieChess:getPC() ~= 205 then
--                dieChess.m_defaultPc = self.pos.squares[sqDst];
--                dieChess.m_defaultSq = sqDst;
                self.m_room:pc2ChessBox(dieChess);
                dieChess:setVisible(true);
            end;
        end;
		-- dieChess:getParent():removeChild(dieChess);
		-- delete(dieChess);
	else
		self.m_pcList[self.pos.moveNum-1] = 0;
	end
	self.m_chesses[sqDst90] = self.m_chesses[sqSrc90];   
	self.m_chesses[sqSrc90] = 0;			

	self:setMovePath(sqSrc90,sqDst90,false);  --加了动画之后放在setMoveEnd处理
	-----将走法提示隐藏
	self:hiddenHints();
	self:hiddenHintPath();
	print_string("Board.chessMove over ");
end

--棋子移动后再显示路径
Board.setMoveEnd = function(self)

	if self.m_pcList[self.pos.moveNum-1] and self.m_pcList[self.pos.moveNum-1] ~= 0 then

		local sqDst90_ = self:flip90(self.m_move_end_sqDst90);
		AnimCapture.play(self,self:getX90(sqDst90_),self:getY90(sqDst90_),self.m_chessSize,self,self.setCaptureEnd);
	else
		self:setMovePath(self.m_move_end_sqSrc90,self.m_move_end_sqDst90,true);
	end

    if self.m_roomMoveEndObj and self.m_roomMoveEndFunc then --移动后房间反映
        self.m_roomMoveEndFunc(self.m_roomMoveEndObj);
    end
end

Board.setRoomMoveEndClick = function(self,obj,func)
    self.m_roomMoveEndObj = obj;
    self.m_roomMoveEndFunc = func;
end


Board.setCaptureEnd = function(self)
	self:setMovePath(self.m_move_end_sqSrc90,self.m_move_end_sqDst90);
end

Board.undoMove = function(self)
	if self.pos.moveNum <= 1 then
		print_string("Board.undoMove but self.pos.moveNum <= 1 moveNum = " .. self.pos.moveNum);
		return;
	end

    if self.m_preMoveChess then
        self.m_preMoveChess:moveEnd();
        self.m_preMoveChess = nil;
    end

	self:clearSelect();

	local mv , pc = self.pos:undoMakeMove();
	if pc and pc > 0 then   --有吃子  

		self.m_dieChess[pc] = self.m_dieChess[pc] - 1;
        if self.m_room and self.m_room.setDieChess then
	        self.m_room:setDieChess(self.m_dieChess);
        end

		self.m_die_pc = self.m_pcList[self.pos.moveNum];


	end

	local turn = (self.m_model ~= self.pos.sdPlayer);  --是否是（下面滴玩家）（自己）

	EventDispatcher.getInstance():dispatch(Event.Call,Board.UNDO_MOVE,turn); 

	self:undoChessMove(mv);
end


Board.undoChessMove = function(self,mv)

	local sqSrc = Postion.SRC(mv);
	local sqDst = Postion.DST(mv);

	local sqSrc90 = Board.To90(sqSrc);
	local sqDst90 = Board.To90(sqDst);

	local sqSrc90_ = self:flip90(sqSrc90);
	local sqDst90_ = self:flip90(sqDst90);
	print_string(" chessUndoMove sqSrc90=  " .. sqSrc90 .. "  sqDst90 = " .. sqDst90);
	self.m_undo_moveChess = self.m_chesses[sqDst90];
	if not self.m_undo_moveChess or self.m_undo_moveChess == 0 then
		print_string("self.m_undo_moveChess error !!!");
		return false;
	end
	local cx = self:getX90(sqSrc90_);
	local cy = self:getY90(sqSrc90_);
	self.m_undo_moveChess:setPos(cx,cy);


	local dieChess = self:getChess(self.m_die_pc);
	self.m_pcList[self.pos.moveNum] = 0;
	self.m_die_pc = 0;
	if dieChess ~= nil and dieChess ~= 0 then
		print_string(" dieChess =  " .. dieChess:getPC());
        if self.m_boardtype == BOARD_TYPE_START then
            if dieChess:getPC() ~= 105 and dieChess:getPC() ~= 205 then
                self.m_room:chessInBox2Board(dieChess);
                self:addChild(dieChess);
                dieChess:setVisible(true);
            end;
        end;
		local x = self:getX90(sqDst90_);
		local y = self:getY90(sqDst90_);
		dieChess:setPos(x,y);
	end
	-- self.m_chesses[sqDst90] = dieChess;  
	-- self.m_chesses[sqSrc90] = m_undo_moveChess;			
	self.m_chesses[sqSrc90] = self.m_chesses[sqDst90];
	self.m_chesses[sqDst90] = dieChess;

	self:setMovePath(sqDst90,sqSrc90,true);
	-----将走法提示隐藏
	self:hiddenHints();
	self:hiddenHintPath();



	print_string("Board.undoChessMove sqSrc90_ =  " .. sqSrc90 .. "  sqDst90_ = " .. sqDst90);
end

-----将走法提示隐藏
Board.hiddenHints = function(self)
	for i = 1 ,18 do
		self.m_hints[i]:setVisible(false);
	end
end

Board.setMovePath = function(self,sqSrc90,sqDst90,isAnimEnd)
	if not self.m_gameStart then
		print_string("Board.setMovePath but  not self.m_gameStart");
		return;
	end

	if not Board.legalPos90(sqSrc90) or not Board.legalPos90(sqSrc90) then
		print_string("Board.setMovePath but  not legalpos" .. string.format("setMovePath , sqSrc = %d , sqDst = %d",sqSrc90,sqDst90));
		return;
	end

	local sqSrc90_ = self:flip90(sqSrc90);
	local sqDst90_ = self:flip90(sqDst90);

	self.m_movePathFromImg:setPos(self:getX90(sqSrc90_)+self.m_pathFromDiffX,self:getY90(sqSrc90_)+self.m_pathFromDiffX);
	self.m_movePathToImg:setPos(self:getX90(sqDst90_)-2,self:getY90(sqDst90_)-4);

	self.m_movePathFromImg:setVisible(true);
	self.m_movePathToImg:setVisible(isAnimEnd or false);
   

	print_string(string.format("setMovePath , sqSrc = %d , sqDst = %d",sqSrc90,sqDst90));
end

Board.legalPos90 = function(pos)
	if pos >90 or pos < 1 then
		return false
	end
	return true; 
end

Board.hiddenMovePath = function(self)
	self.m_movePathFromImg:setVisible(false);
	self.m_movePathToImg:setVisible(false);
end

Board.chessToSrc = function(self)
	if(self.m_selectChess ~= nil) then
		local cx = self.m_xFrom + self.m_chessSize * (self.m_downC) ;
		local cy = self.m_yFrom + self.m_chessSize * (self.m_downR) ;
		self.m_selectChess:setPos(cx,cy);
	end
end

Board.chessToDst = function(self, C, R)
	if(self.m_selectChess ~= nil) then
		local cx = self.m_xFrom + self.m_chessSize * (C) ;
		local cy = self.m_yFrom + self.m_chessSize * (R) ;
		self.m_selectChess:setPos(cx,cy);
	end
end

Board.COORD_XY = function(row,col)
	return row*9 + col + 1;
end


--将象棋小巫师的棋盘位置搬到90棋盘上来
Board.To90 = function(sq)
	local col = Postion.FILE_X(sq) - Postion.FILE_LEFT;
	local row = Postion.RANK_Y(sq) - Postion.RANK_TOP;
	local sq90 = Board.COORD_XY(row,col);
	return sq90;
end

Board.Tosq = function(sq90)
	local row = math.floor((sq90-1) /9);
	local col = (sq90 - 1) % 9;
	local sq = Postion.COORD_XY(col + Postion.FILE_LEFT,row + Postion.RANK_TOP);
	return sq;
end

Board.mv2ChessMove = function(self,mv)
	local sqSrc = Postion.SRC(mv);
	local sqDst = Postion.DST(mv);

	local sqSrc90 = Board.To90(sqSrc);
	local sqDst90 = Board.To90(sqDst);
	local moveChess = self.m_chesses[sqSrc90];

	local data = {};
	data.moveChess = moveChess:getPC();
	data.moveFrom = 91 - sqSrc90;
	data.moveTo = 91 - sqDst90;
	return data;
end


Board.data2mv = function(self,data)
	local moveChess = data.moveChess;
	local moveFrom = 91 -data.moveFrom;
	local moveTo = 91 - data.moveTo;

	local sqSrc = Board.Tosq(moveFrom);
	local sqDst = Board.Tosq(moveTo);
	local mv = Postion.MOVE(sqSrc,sqDst);
	return mv;
end


Board.BoardEventRespone = function (self , eventName , data)
 	if(not eventName) then
 		print_string("Board eventName is nil");
 		return;
 	end

 	if eventName == CHESS_MOVE then

 		local mv = self:data2mv(data);
		if self:addMove(mv) then
			self:chessMove(mv);
		end
 	end

end

--电脑提示走法
Board.hintMove = function(self,mv)

	if(not self.pos:legalMove(mv)) then
		print_string("Board.hintMove not legalmove " .. mv);
        EventDispatcher.getInstance():dispatch(Event.Call,CUSTOMENGATE_TIPS_ENABLE,false);  
		return false;
	end

	--local pc,check = self.pos:makeMove(mv);

	if self.pos:makeMove(mv) then  --有一步可走的棋
		self.pos:undoMakeMove();
	else
		print_string("checked !!! " .. mv);
        EventDispatcher.getInstance():dispatch(Event.Call,CUSTOMENGATE_TIPS_ENABLE,false);  
		return false;
	end

	


	local sqSrc = Postion.SRC(mv);
	local sqDst = Postion.DST(mv);

	local sqSrc90 = Board.To90(sqSrc);
	local sqDst90 = Board.To90(sqDst);

	self.m_hintMoveChess = self.m_chesses[sqSrc90];
	if self.m_hintMoveChess == nil or self.m_hintMoveChess == 0 then
		print_string("self.m_hintMoveChess error !!!");
        EventDispatcher.getInstance():dispatch(Event.Call,CUSTOMENGATE_TIPS_ENABLE,false);  
		return false;
	end

	self:setHintMovePath(sqSrc90,sqDst90);
    -- 创建残局提示按钮可用了
    EventDispatcher.getInstance():dispatch(Event.Call,CUSTOMENGATE_TIPS_ENABLE,true);  
end

Board.setHintMovePath = function(self,sqSrc90,sqDst90)


	local sqSrc90_ = self:flip90(sqSrc90);
	local sqDst90_ = self:flip90(sqDst90);

	self.m_hintPathFromImg:setPos(self:getX90(sqSrc90_) + self.m_hintPathFromImgDiffX,self:getY90(sqSrc90_) + self.m_hintPathFromImgDiffX);


--	local cx = self.m_xHint + self:getX90(sqDst90_);
--	local cy = self.m_yHint + self:getY90(sqDst90_);
	self.m_hintPathToImg:setPos(self:getX90(sqDst90_)+self.m_pathFromDiffX,self:getY90(sqDst90_)+self.m_pathFromDiffX);

	self.m_hintPathFromImg:setVisible(true);
	self.m_hintPathToImg:setVisible(true);

	print_string(string.format("setHintMovePath , sqSrc = %d , sqDst = %d",sqSrc90,sqDst90));
end

Board.hiddenHintPath = function(self)
	self.m_hintPathFromImg:setVisible(false);
	self.m_hintPathToImg:setVisible(false);
end

--电脑走棋
Board.aiMove = function(self)
	print_string("Board.aiMovegggggggggggggggggg");
	if self.m_aithink_anim then
		delete(self.m_aithink_anim);
		self.m_aithink_anim = nil;
	end

	if self:addMove(self.m_ai_mv) then
		print_string("Board.aiMovegggggggggggggggggg after self:addMove");
		self:chessMove(self.m_ai_mv);
		EventDispatcher.getInstance():dispatch(Event.Call,Board.AIMOVE,self.m_ai_mv); 
	else
		EventDispatcher.getInstance():dispatch(Event.Call,Board.AIUNLEGALMOVE);  
	end
--    self:setLevel(9);
--    self:response(ENGINE_MOVE);
end

Board.severMove = function(self,data)
	local mv = self:data2mv(data);
	self.m_severMove = true;   --[[服务器走棋，关键（Iphone和服务器 、 
	android 判断长将长捉的方法不一样，当Iphone、Server认为不是长捉长将，
	而Android认为是长捉长将的时候，就会出现棋走不了的情况,故服务器过来的走棋方法不判断长捉长将]]--
	if self:addMove(mv) then
		self:chessMove(mv);
	end
end

Board.severUndoMove = function(self,data)
	--考虑数据同步时本地数据没有走棋记录

	self:undoMove();

end

Board.synchroBoard = function(self,chess_map,model,redTurn)

 	self:dismissChess();
	self.m_model = model;

	local boardFen = Board.toFen(chess_map,redTurn);
	print_string("boardFen = " .. boardFen);
    self.m_fen = boardFen
	self.pos:fromFen(boardFen);
	self.m_movePathFromImg:setVisible(false);
	self.m_movePathToImg:setVisible(false);
	self:hiddenHints();
	self:hiddenMovePath();
	self:ready(chess_map);
end


Board.dtor = function(self)
    AnimTimeout.deleteAll();
    AnimKill.deleteAll();
    AnimCapture.deleteAll();--棋盘动画释放
    AnimJam.deleteAll();
    AnimCheck.deleteAll();
    ShockAnim.deleteAll();
    delete(self.m_aithink_anim);
    self.m_aithink_anim = nil;
--	EventDispatcher.getInstance():unregister(Event.Call , self.m_room ,self.m_room.EventRespone);
end

	--将棋盘信息转换成Fen字符串 
Board.toFen = function(chess_map,redTurn)       --将棋盘转换成fen格式
	local fen = {};
	local k = 0;
	for  index = 1, 90 do
		local pc = chess_map[index];
		if pc and pc ~= NOCHESS then
			if (k > 0) then
				table.insert(fen,k);
				k = 0;
			end
			table.insert(fen,Board.charAt(pc));
		else 
			k = k+1;
		end
		if index%9 == 0 then
			if (k > 0) then
				table.insert(fen,k);
				k = 0;
			end
			table.insert(fen,'/');
		end
	end
	table.insert(fen, ' ');
	table.insert(fen,(redTurn and 'w') or 'b');
	return table.concat(fen);
end

Board.charAt = function(pc) 

	if pc == B_KING	then
		return 'k';
	elseif pc == B_ROOK1 or pc == B_ROOK2 then
		return 'r';
	elseif pc == B_HORSE1 or pc == B_HORSE2 then
		return 'n';
	elseif pc == B_CANNON1 or pc == B_CANNON2 then
		return 'c';
	elseif pc == B_BISHOP1 or pc == B_BISHOP2 then
		return 'a';
	elseif pc == B_ELEPHANT1 or pc == B_ELEPHANT2 then
		return 'b';
	elseif pc == B_PAWN1 or pc == B_PAWN2 or pc == B_PAWN3 or pc == B_PAWN4 or pc == B_PAWN5 then
		return 'p';
			
	elseif pc == R_KING then
		return 'K';
	elseif pc == R_ROOK1 or pc == R_ROOK2 then
		return 'R';
	elseif pc == R_HORSE1 or pc == R_HORSE2 then
		return 'N';
	elseif pc == R_CANNON1 or pc == R_CANNON2 then
		return 'C';
	elseif pc == R_BISHOP1 or pc == R_BISHOP2 then
		return 'A';
	elseif pc == R_ELEPHANT1 or pc == R_ELEPHANT2 then
		return 'B';
	elseif pc == R_PAWN1 or pc == R_PAWN2 or pc == R_PAWN3 or pc == R_PAWN4 or pc == R_PAWN5 then
		return 'P';
	else    --默认处理
		return 0;
	end
			
end


Board.send = function(self,line)
	print_string("Board.send chess_ai send = [" .. line.."]");
	dict_set_string(GUI_ENGINE , GUI_ENGINE .. kparmPostfix , line);
	call_native(GUI_ENGINE);

end

Board.onReceive = function(self,line)
	if not line then
		print_string("Board.onReceive but line is nil");
		return
	end
	print_string("Board.onReceive chess_ai Receive = [" .. line.."]");

	if self.m_engine == ENGINE_EXIT then
		print_string("self.m_engine == ENGINE_EXIT");
		return;
	end

	local first_index,last_index = string.find(line , "nobestmove");
	if first_index then
        if self.mSendStop then
            self.mSendStop = false;
            -- 吸收发送 stop 后的输出命令
            return 
        end
		print_string("nobestmove");
--		ProgressDialog.stop();
        delete(self.m_engine_max_think_time)
		if self.m_gameStart then
			EventDispatcher.getInstance():dispatch(Event.Call,Board.AI_UNCHANGE_MOVE);  
		end 
		self.m_engine = ENGINE_IDLE;
		return;
	end

	first_index,last_index = string.find(line , "bestmove");
	if not first_index then
		print_string("not has bestmove");
		return;
	end
    if self.mSendStop then
        self.mSendStop = false;
        -- 吸收发送 stop 后的输出命令
        return 
    end
    delete(self.m_engine_max_think_time)

--	ProgressDialog.stop();

	if string.len(line) < 13 or engine == ENGINE_STOP then
		print_string("string.len(line) < 13 or engine == ENGINE_STOP");
		self.m_engine = ENGINE_IDLE;
		return;
	end
    if not self.m_gameStart then self.m_engine = ENGINE_IDLE return end
	local mv_string = string.sub(line,10,13);
	local ascii_src_col,ascii_src_row,ascii_dst_col,ascii_dst_row = string.byte(mv_string,1,4);
	local col = ascii_src_col - string.byte("a") + Postion.FILE_LEFT;
	local row = string.byte("9") - ascii_src_row +Postion.RANK_TOP;
	local sqSrc = Postion.COORD_XY(col,row);

	col = ascii_dst_col - string.byte("a") + Postion.FILE_LEFT;
	row = string.byte("9") - ascii_dst_row +Postion.RANK_TOP;
	local sqDst = Postion.COORD_XY(col,row);

	if not Postion.IN_BOARD(sqSrc) or not Postion.IN_BOARD(sqDst) then
		print_string("not Postion.IN_BOARD(sqSrc) or not Postion.IN_BOARD(sqDst)");
		self.m_engine = ENGINE_IDLE;
		return;
	end

	--认输
	-- first_index,last_index = string.find(line , " resign");
	-- if first_index and not self.m_booth_type then
	-- 	print_string("电脑认输，祝贺你取得胜利");  --测试说不要啊
	-- 	self.m_engine = ENGINE_IDLE;
	-- 	local code = UserInfo.getInstance():getFlag();
	-- 	self.m_room:console_gameover(code,ENDTYPE_SURRENDER);
	-- 	return;
	-- end

	--求和
	-- first_index,last_index = string.find(line , " draw");
	-- if first_index then
	-- 	if self.m_moveDraw then
	-- 		self.m_engine = ENGINE_IDLE;
	-- 		self.m_room:console_gameover(CHESS_MOVE_OVER_DRAW,ENDTYPE_DRAW);
	-- 		return;
	-- 	else
	-- 		print_string("电脑求和");
	-- 		self.m_room:responseDraw();
	-- 		-- self.m_moveDraw = true;
	-- 	end
	-- else
	-- 	self.m_moveDraw = false;
	-- end

	self.m_ai_mv = Postion.MOVE(sqSrc,sqDst);
	if self.m_engine == ENGINE_MOVE then
		self.m_engine = ENGINE_IDLE;
		local wait = self.m_engine_time + CONSOLE_LEAST_THINK_TIME - os.time();
		if wait > 0 then
			print_string("Board.onReceive wait111 = " .. wait);
			self.m_aithink_anim = new(AnimInt,kAnimNormal,0,1,wait*1000,-1); --
			self.m_aithink_anim:setDebugName("Board.onReceive.m_aithink_anim");
			self.m_aithink_anim:setEvent(self,self.aiMove);
		else
			print_string("Board.onReceive wait222 = " .. wait);
			self:aiMove();
		end
	elseif self.m_engine == ENGINE_HINT then
		self.m_engine = ENGINE_IDLE;
		self:hintMove(self.m_ai_mv);
	end

end

-- 设置ai难度
Board.setLevel = function(self,ailevel)
--[[
    1.9.10这个版本主要使用 go depth;
    经过测试(针对最高等级深度9)：
    单核CPU, AI思考一步最多45s，越往后棋子越少思考越快，平均30s左右；
    双核CPU, AI思考一步最多20s，平均15s;
    四核CPU, AI思考一步最多8s，平均7s;
    市场目前主流CPU都是2~4核，所以选择了深度9；
    后续市场主流CPU增强，可继续优化深度
    ps:也可使用 go nodes（AI深度9 > 结点6^9 == 结点6^8 > 结点6^7 ）
                        （AI深度8 == 结点6^8 > 结点6^7 >）
                         结点6^10，四核CPU会卡近60s,所以可先不考虑
--]]
	self.m_booth_type = false;
	print_string("Console.Board.setLevel----->AI level is "..ailevel);
--    self.m_ai_level = ailevel;
    if ailevel == 1 then    --难度：huge < large < medium < small < tiny < none.
        self.m_aiRandomness = "huge";
        self.m_aiRisky = "risky";
        self.m_aiDepth = 1;
    elseif ailevel == 2 then
        self.m_aiRandomness = "large";
        self.m_aiRisky = "risky";
        self.m_aiDepth = 1;
    elseif ailevel == 3 then
        self.m_aiRandomness = "medium";
        self.m_aiRisky = "normal";
        self.m_aiDepth = 3;
    elseif ailevel == 4 then
        self.m_aiRandomness = "small";  
        self.m_aiRisky = "normal";
        self.m_aiDepth = 5;
    elseif ailevel == 5 then
        self.m_aiRandomness = "tiny";
        self.m_aiRisky = "solid"; 
        self.m_aiDepth = 7; 
    elseif ailevel == 6 then
        self.m_aiRandomness = "none";  
        self.m_aiRisky = "solid"; 
        self.m_aiDepth = 9;  
    elseif ailevel == 7 then
        self.m_aiRandomness = "none";  
        self.m_aiRisky = "solid"; 
        self.m_aiDepth = 10;  
    end;

	self.m_run_engine_begin = "setoption randomness " .. self.m_aiRandomness;

	if ailevel < 4 then
		self:setUseBook(false);
	else
		self:setUseBook(true);
	end
end

Board.setPassLevel = function(self,level)
	self.m_pass_level = level;
end;

Board.setEngineBegin = function(self,fen)
	self.m_booth_type = true;  --残局模式不可认输
	self.m_run_engine_begin = "setoption randomness none" ;
    self:setLevel(6);
	self.m_fen = fen;
	self.m_level = 3;
	self:setUseBook(true);
end

Board.setUseBook = function(self,flag)
	
	if flag then
		self.m_usebook_str = "setoption usebook true";
	else
		self.m_usebook_str = "setoption usebook false";
	end
end


Board.response = function(self,engine_status)
	if self.m_resopnse_anim then
		delete(self.m_resopnse_anim);
		self.m_resopnse_anim = nil;
	end


	sys_set_int("win32_console_color",10);
	print_string("Console.board.response self.m_engine = " .. self.m_engine);
	print_string("Console.board.response engine_status = " .. engine_status);
	sys_set_int("win32_console_color",9);
	if self.m_engine == ENGINE_IDLE or self.m_engine == ENGINE_STOP then
		self.m_engine = engine_status or ENGINE_MOVE;
		print_string("Console.board.response self.m_engine2 = " .. self.m_engine);
		self:runEngine();
	else 
		print_string("Console.Board.response but self.m_engine ~= ENGINE_IDLE " .. self.m_engine);
		return;
	end
end
--[Comment]
-- 获得ai 当前状态
function Board:getEngineStatus()
    return self.m_engine or ENGINE_IDLE
end

Board.runEngine = function(self)
	print_string("Board.runEngine  .. ");
	--self:onReceive("bestmove h4g4 resign");
	self:send(self.m_run_engine_begin);
	self:send(self.m_usebook_str);
    ----------------加载残局----------------
	local line = "position fen " .. self.m_fen;--Postion.STARTUP_FEN[1]; 
	if self.pos.moveNum > 1 then
		line = line .. " moves" .. self.pos:toMoves();
	end
	self:send(line);
    ----------------加载残局----------------
    self:send("setoption style "..self.m_aiRisky);
    self:send("go depth "..self.m_aiDepth);

--    测试ai强度(go nodes VS go depth)
--    if self.m_sssai_level == 7 then
--        self.m_sssai_level = 10;
--        local nodes = 1;
--	    for i=1,7 do
--		    nodes = nodes*6;
--	    end
--        print_string("Board.runEngine Nodes7 .. "..nodes);
--        self:send("go nodes "..nodes);
--    else
--        self.m_sssai_level = 7;
--        print_string("Board.runEngine Depth4 .. "..self.m_aiDepth);
--        self:send("go depth "..self.m_aiDepth);
--    end;
	self.m_engine_time = os.time();  --程序使用CPU的时间
    delete(self.m_engine_max_think_time)
    self.m_engine_max_think_time = AnimFactory.createAnimInt(kAnimNormal, 0, 1, 1, 10000)
    self.m_engine_max_think_time:setEvent(self,self.stopThink2)
end
-- 用于超时输出走子
Board.stopThink2 = function(self)
	--停止引擎思考
	if self.m_engine > ENGINE_STOP then
		self:send("stop");
	end
    delete(self.m_engine_max_think_time)
end

Board.stopThink = function(self)
	--停止引擎思考
	if self.m_engine > ENGINE_STOP then
		print_string("Board.stopThink  self.m_engine = " .. self.m_engine );
		self.m_engine = ENGINE_STOP;
		self:send("stop");
        self.mSendStop = true;
        -- 发出该指令并不意味着引擎将立即回到空闲状态，而是要等到引擎反馈bestmove或nobestmove后才表示回到空闲状态，引擎应尽可能快地作出这样的反馈
	end
    delete(self.m_engine_max_think_time)
    if self.m_aithink_anim then
		delete(self.m_aithink_anim);
		self.m_aithink_anim = nil;
	end
end

Board.consoleUndoMove = function(self)
	if self.pos.moveNum > 1 then
		self:undoMove();
		if self.pos.moveNum > 1 and self.pos.sdPlayer == Board.ENGINE_SIDE[self.m_model] then
			self:undoMove();
		end
	else
		return false;
	end
	self:stopThink();

	if self.pos.sdPlayer == Board.ENGINE_SIDE[self.m_model] then
		-- self.m_resopnse_anim = new(AnimInt,kAnimNormal,0,1,wait,-1); --
		-- self.m_resopnse_anim:setDebugName("Board.consoleUndoMove.m_resopnse_anim");
		
		-- self.m_resopnse_anim:setEvent(self,self.response);
		self:response(ENGINE_MOVE);
	end

	return true;

end

--向电脑求和
Board.drawRequest = function(self)
	self:console_gameover(CHESS_MOVE_OVER_DRAW,ENDTYPE_DRAW);  --直接同意
	-- self.m_moveDraw = true;
end

--回应电脑求和
Board.drawResponse = function(self,agree)
	if agree then
		self:console_gameover(CHESS_MOVE_OVER_DRAW,ENDTYPE_DRAW);
	else
		self.m_moveDraw = false;
	end
end


--保存单机数据
Board.console_save = function(self)

	if not self.m_gameStart or self.pos.moveNum <= 1 then
		print_string("the game not start");
		return;
	end
	print_string("Console.Board.console_save  保存红黑方 "..self.m_model)
	print_string("Console.Board.console_save  保存等级 "..self.m_pass_level)
	GameCacheData.getInstance():saveInt(GameCacheData.CONSOLE_MODE,self.m_model);
	GameCacheData.getInstance():saveInt(GameCacheData.CONSOLE_PASS_LEVEL,self.m_pass_level);
    
	GameCacheData.getInstance():saveString(GameCacheData.CONSOLE_FEN,self.m_fen);
	--保存走棋步骤
	local mvList = self:to_mvList();
	local mvString = table.concat(mvList,MV_SPLIT)
	GameCacheData.getInstance():saveString(GameCacheData.CONSOLE_MVLIST,mvString);
	print_string("Board.console_save mvString = " .. mvString);

	local chess_map = self:to_chess_map();
	local chessString = table.concat(chess_map,MV_SPLIT);
	GameCacheData.getInstance():saveString(GameCacheData.CONSOLE_CHESSMAP,chessString);
    print_string("Board.console_save chessString = " .. chessString);

	local pcString = table.concat(self.m_pcList,MV_SPLIT);
	GameCacheData.getInstance():saveString(GameCacheData.CONSOLE_PCLIST,pcString);
    print_string("Board.console_save pcString = " .. pcString);

    --是否存在单机中途棋局
    GameCacheData.getInstance():saveBoolean(GameCacheData.CONSOLE_IS_EXISTED_CHESS, true);
end

--同步单机数据
Board.console_synchrodata = function(self, model, ai_level, level)
	print_string("Console.Board.console_synchrodata  保存红黑方 "..model)
	print_string("Console.Board.console_synchrodata  保存等级 "..level)
    local fen = GameCacheData.getInstance():getString(GameCacheData.CONSOLE_FEN,Postion.STARTUP_FEN[1]);
	local mvString = GameCacheData.getInstance():getString(GameCacheData.CONSOLE_MVLIST,nil);
	local mvList = lua_string_split(mvString,MV_SPLIT);
	print_string("Console.Board.console_synchrodata mvString = " .. mvString);

	local chessString = GameCacheData.getInstance():getString(GameCacheData.CONSOLE_CHESSMAP,nil);
	local chess_map = lua_string_split(chessString,MV_SPLIT);
    print_string("Console.Board.console_synchrodata chessString = " .. chessString);
	local pcString = GameCacheData.getInstance():getString(GameCacheData.CONSOLE_PCLIST,nil);
    print_string("Console.Board.console_synchrodata pcString = " .. pcString);
	local pcList = lua_string_split(pcString,MV_SPLIT);
	for index,pc in pairs(pcList) do
		self.m_pcList[index] = pc+0;
	end


	self.m_model = model;
	self:setLevel(ai_level);
    self:setPassLevel(level);
    self.m_fen = fen
	self.pos:fromFen(fen);
	self:posMoves(mvList);

	self:hiddenHints();
	-- self:hiddenMovePath();
	self:hiddenHintPath();

	self:ready(chess_map);

	local turn = (self.m_model ~= self.pos.sdPlayer);  --是否是（下面滴玩家）（自己）	
	--self.m_room:turnStatus(turn);
	print_string("Console.Board.console_synchrodata in self.m_model == "..self.m_model);
	print_string("Console.Board.console_synchrodata in self.pos.sdPlayer == "..self.pos.sdPlayer);
	if self.pos.sdPlayer == Board.ENGINE_SIDE[self.m_model] then
		-- self.m_resopnse_anim = new(AnimInt,kAnimNormal,0,1,wait,-1); --
		-- self.m_resopnse_anim:setDebugName("Board.consoleUndoMove.m_resopnse_anim");
		
		-- self.m_resopnse_anim:setEvent(self,self.response);
		print_string("Console.Board.console_synchrodata in self.pos.sdPlayer == "..self.pos.sdPlayer);
		self:response(ENGINE_MOVE);
	end


end

--将本局的棋子信息变成整型的table
Board.to_chess_map = function(self)
	local chess_map = {};
	for sq = 1 ,90 do
		local chess = self.m_chesses[sq];
		chess_map[sq] = chess;
		if chess ~= nil and chess ~=0 then
			local pc = chess:getPC();
			chess_map[sq] = pc;
		end
	end
	return chess_map;
end

Board.posMoves = function(self,mvList)
	if not mvList or #mvList < 1 then
		print_string("Board.posMoves not mvList or #mvList < 1 ");
		return;
	end

	
	for key,mv in pairs(mvList) do
		mv = mv + 0;
		if self.pos:legalMove(mv) then
			self.pos:makeMove(mv);
			print_string("Board.posMoves legalMove " .. mv);
		else
			print_string("Board.posMoves not legalMove " .. mv);
		end
	end

	local mv = self.pos.mvList[self.pos.moveNum - 1]
	if mv then
		local sqSrc = Postion.SRC(mv);
		local sqDst = Postion.DST(mv);

		local sqSrc90 = Board.To90(sqSrc);
		local sqDst90 = Board.To90(sqDst);

		self:setMovePath(sqSrc90,sqDst90);
	end
end

Board.to_mvList = function(self)
	local moves = {};
	for index = 1,self.pos.moveNum-1 do
		moves[#moves + 1] = self.pos.mvList[index];		
		print_string(string.format("index = %d,mv = %X",index,moves[index]));
	end
	return moves;
end

Board.move = function(self,mv)
	local code = self:addMove(mv);
	if  code then
		local data =  self:mv2ChessMove(mv);
		self:chessMove(mv);
		self.m_room:chessMove(data);
	end
	return code;
end

Board.moveNotCheck = function(self,mv)  -- 为了需求加的 不要乱用 会导致数据错误  因为没有验证数据的正确性
    local pc,check = self.pos:makeMove(mv);
    if pc and pc > 0 then   --有吃子  
		self.m_dieChess[pc] = (self.m_dieChess[pc] and (self.m_dieChess[pc] + 1)) or 1;
        if self.m_room and self.m_room.setDieChess then
	        self.m_room:setDieChess(self.m_dieChess);
        end
	end
    local data =  self:mv2ChessMove(mv);
	self:chessMove(mv);
	self.m_room:chessMove(data);
end



--残局悔棋
Board.endingUndoMove = function(self)

	self.m_gameStart = true;

	self:stopThink();

	if self.pos.moveNum > 1 then
		self:undoMove();
		if self.pos.moveNum > 1 and self.pos.sdPlayer == Board.ENGINE_SIDE[self.m_model] then
			self:undoMove();
		end
	end

	if self.pos.sdPlayer == Board.ENGINE_SIDE[self.m_model] then
		self:response(ENGINE_MOVE);
	end

end

--按残局棋谱走棋
Board.endingMove = function(self,move)
	
	local mv = 	Board.endMove2Mv(move);

	self.m_severMove = true;   --[[服务器走棋，关键（Iphone和服务器 、 
	android 判断长将长捉的方法不一样，当Iphone、Server认为不是长捉长将，
	而Android认为是长捉长将的时候，就会出现棋走不了的情况,故服务器过来的走棋方法不判断长捉长将]]--
	local code = self:addMove(mv);
	if code then
		self:chessMove(mv);
	end

	return code;
end

--残局棋谱提示下一步
Board.book_tips = function(self,move)
	print_string("Board.book_tips ");
	local mv = 	Board.endMove2Mv(move);
	self:hintMove(mv);
end

--将东萍格式的走法转换成mv
Board.endMove2Mv = function(move)

	local src_row = move.src%10;
	local src_col = math.floor(move.src/10);

	local dst_row = move.dst%10;
	local dst_col = math.floor(move.dst/10);

	-- local moveFrom = (src_row*9+src_col);
	-- local moveTo = (dst_row*9+dst_col);
	print_string(string.format("src_row = %d,src_col = %d ,dst_row = %d,dst_col = %d",src_row,src_col,dst_row,dst_col));


	local sqSrc = Postion.COORD_XY(src_col + Postion.FILE_LEFT,src_row + Postion.RANK_TOP);
	local sqDst = Postion.COORD_XY(dst_col + Postion.FILE_LEFT,dst_row + Postion.RANK_TOP);
	local mv = Postion.MOVE(sqSrc,sqDst);

	return mv;

end

--将mv的走法转换成东萍格式
Board.Mv2endMove = function(mv)
    local move = {};

    local sqSrc = Postion.SRC(mv);
	local sqDst = Postion.DST(mv);

	local src_row = Postion.RANK_Y(sqSrc) - Postion.RANK_TOP;
	local src_col = Postion.FILE_X(sqSrc) - Postion.FILE_LEFT;
    
	local dst_row = Postion.RANK_Y(sqDst) - Postion.RANK_TOP;
	local dst_col = Postion.FILE_X(sqDst) - Postion.FILE_LEFT;

    move.src = src_col*10 + src_row;
    move.dst = dst_col*10 + dst_row;

	return move;
end

Board.setBoardType = function(self, boardType)
    self.m_boardtype = boardType;
end;


Board.getChesses = function(self)
    return self.m_chesses or {};
end

Board.isDraw = function(self)
    local dieChess = {};
    for i = 8, 22 do
		dieChess[i] = piece_id_num[i];
	end

	for sq = 0,255 do
		local pc = self.pos.squares[sq];
		if  pc > 0 then
			dieChess[pc] = dieChess[pc] - 1;
		end
	end
    local num = 0;
    
--    [11] = 2;  --红马
--	[12] = 2;  --红车
--	[13] = 2;  --红炮
--	[14] = 5;  --红卒
--	[19] = 2;  --黑马
--	[20] = 2;  --黑车
--	[21] = 2;  --黑炮
--	[22] = 5;  --黑卒
    for i=11,14 do
        num = num + piece_id_num[i];
        num = num - dieChess[i];
    end
    for i=19,22 do
        num = num + piece_id_num[i];
        num = num - dieChess[i];
    end
    return num == 0;
end

--[Comment]
-- 获取步数
function Board.getMoveStepNum(self)
    if self.pos then return self.pos.moveNum end
    return 0;
end

--[Comment]
-- 是否是自己走棋
function Board.isYouTurn(self)
    return self.m_model == self.pos.sdPlayer
end

--[Comment]
-- 棋子旋转
function Board.ratateChess(self,ret)
    if not ret then
        for k,v in pairs(self.m_chesses) do 
            if v and type(v) == "table" then
                if not v:checkAddProp(19) then
                    v:removeProp(19)
                end
            end
        end
    else
        for k,v in pairs(self.m_chesses) do
            if v and type(v) == "table" then
                if v:checkAddProp(19) then
                    v:addPropRotateSolid(19,180,kCenterDrawing)
                end
            end
        end
    end
--    return self.m_model ~= self.pos.sdPlayer
end

--[Comment]
-- 结算旋转
function Board.ratateAnim(self,ret)
    local view = self:getAnimHandlerView()
    if not ret then
        if not view:checkAddProp(19) then
            view:removeProp(19)
        end
    else
        if view:checkAddProp(19) then
            view:addPropRotateSolid(19,180,kCenterDrawing)
        end
    end
end

function Board:getAnimHandlerView()
    if not self.mAnimView then
        self.mAnimView = new(Node)
        self.mAnimView:setFillParent(true,true)
        self.mAnimView:setLevel(10)
        self:addChild(self.mAnimView)
    end
    return self.mAnimView
end
