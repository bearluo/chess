require("core/constants");
require("core/object");
require("libs/bit");

Postion = class();

Postion.MAX_MOVE_NUM = 1024;
Postion.MAX_GEN_MOVES = 128;

Postion.PIECE_KING = 0;
Postion.PIECE_ADVISOR = 1;
Postion.PIECE_BISHOP = 2;
Postion.PIECE_KNIGHT = 3;
Postion.PIECE_ROOK = 4;
Postion.PIECE_CANNON = 5;
Postion.PIECE_PAWN = 6;

Postion.RANK_TOP = 3;
Postion.RANK_BOTTOM = 12;
Postion.FILE_LEFT = 3;
Postion.FILE_RIGHT = 11;

Postion.IN_BOARD_BYTE = {
	[0]=0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
		0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
		0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
		0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
		0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
		0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
		0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
		0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
		0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
		0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	};

Postion.IN_FORT_BYTE = {
	[0]=0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	};

-- 士可移动位置
Postion.PIECE_ADVISOR_IN_FORT_BYTE = {
	[0]=0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	};


-- 象可移动位置
Postion.PIECE_BISHOP_IN_FORT_BYTE = {
	[0]=0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	};

-- 兵在自己半场可移动范围
Postion.PIECE_PAWN_SELFHALF_IN_FORT_BYTE = {
	[0]=0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0,
		0, 0, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 0, 0, 0,
		0, 0, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 0, 0, 0,
		0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
}



Postion.LEGAL_SPAN = {
						[0]= 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 2, 1, 2, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 2, 1, 2, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0,
	};

Postion.KNIGHT_PIN_BYTE = {
								[0]=0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,-16,  0,-16,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0, -1,  0,  0,  0,  1,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0, -1,  0,  0,  0,  1,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0, 16,  0, 16,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
		0,  0,  0,  0,  0,  0,  0
	};


Postion.KING_DELTA = {-16, -1, 1, 16};
Postion.ADVISOR_DELTA = {-17, -15, 15, 17};
Postion.KNIGHT_DELTA = {{-33, -31}, {-18, 14}, {-14, 18}, {31, 33}};
Postion.KNIGHT_CHECK_DELTA = {{-33, -18}, {-31, -14}, {14, 31}, {18, 33}};

Postion.STARTUP_FEN = {
		"rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1",
		"rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/R1BAKABNR w - - 0 1",
		"rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/R1BAKAB1R w - - 0 1",
		"rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/9/1C5C1/9/RN2K2NR w - - 0 1",
	};

Postion.IN_BOARD = function (sq) 
	return Postion.IN_BOARD_BYTE[sq] ~= 0;
end	

Postion.IN_FORT = function (sq)
	return Postion.IN_FORT_BYTE[sq] ~= 0;
end
--获得格子的横坐标	
Postion.RANK_Y = function (sq) 
	return bit.brshift(sq ,4);
end

--获得格子的纵坐标
Postion.FILE_X = function(sq) 
	return bit.band(sq,15) --sq & 15;
end
--根据纵坐标和横坐标获得格子
Postion.COORD_XY = function (x, y) 
	return x + bit.blshift(y,4); --return x + (y << 4);
end





--行列倒置
Postion.SQUARE_FLIP  = function (sq)
	return 254 - sq;
end

Postion.FILE_FLIP   = function (x) 
	return 14 - x;
end

Postion.RANK_FLIP  = function (y) 
	return 15 - y;
end

Postion.MIRROR_SQUARE = function(sq) 
	return Postion.COORD_XY(FILE_FLIP(FILE_X(sq)), RANK_Y(sq));
end

Postion.SQUARE_FORWARD  = function (sq, sd) 
	return sq - 16 + bit.blshift(sd ,5);--sq - 16 + (sd << 5);
end

Postion.KING_SPAN  = function(sqSrc, sqDst) 
	return Postion.LEGAL_SPAN[sqDst - sqSrc + 256] == 1;
end

Postion.ADVISOR_SPAN = function(sqSrc, sqDst) 
	return Postion.LEGAL_SPAN[sqDst - sqSrc + 256] == 2;
end

Postion.BISHOP_SPAN = function(sqSrc, sqDst) 
	return Postion.LEGAL_SPAN[sqDst - sqSrc + 256] == 3;
end

Postion.BISHOP_PIN = function(sqSrc, sqDst) 
	return bit.brshift((sqSrc + sqDst) , 1) --(sqSrc + sqDst) >> 1;
end

Postion.KNIGHT_PIN = function(sqSrc, sqDst) 
	return sqSrc + Postion.KNIGHT_PIN_BYTE[sqDst - sqSrc + 256];
end

Postion.HOME_HALF = function(sq, sd) 
	return bit.band(sq,16*8) ~= bit.blshift(sd,7) ; --(sq & 0x80) != (sd << 7);
end
-- 是否离开自己半场
Postion.AWAY_HALF = function(sq, sd) 
	return bit.band(sq,16*8) == bit.blshift(sd,7) ; --(sq & 0x80) == (sd << 7);
end
-- 是否是同一半场
Postion.SAME_HALF =function(sqSrc, sqDst)
	return bit.band(bit.bxor(sqSrc,sqDst),16*8) == 0; --((sqSrc ^ sqDst) & 0x80) == 0;
end

-- 是否同一行
Postion.SAME_RANK = function(sqSrc, sqDst) 
	return bit.band(bit.bxor(sqSrc , sqDst) , 15*16) == 0;--return ((sqSrc ^ sqDst) & 0xf0) == 0;
end
-- 是否同一列
Postion.SAME_FILE = function(sqSrc, sqDst) 
	return bit.band(bit.bxor(sqSrc , sqDst) , 15) == 0;--((sqSrc ^ sqDst) & 0x0f) == 0;
end

Postion.SIDE_TAG = function(sd)
	return 8+ bit.blshift(sd,3);  --8 + (sd << 3);
end

Postion.OPP_SIDE_TAG = function(sd) 
	return 16 - bit.blshift(sd,3);--16 - (sd << 3);
end


Postion.SRC = function(mv) 
	return bit.band(mv,255);--mv & 255;
end

Postion.DST  = function( mv) 
	return bit.brshift(mv,8);--mv >> 8;
end

Postion.MOVE = function(sqSrc, sqDst) 
	return sqSrc + bit.blshift(sqDst,8);--sqSrc + (sqDst << 8);
end

Postion.MIRROR_MOVE  = function(mv) 
	return Postion.MOVE(Postion.MIRROR_SQUARE(Postion.SRC(mv)), Postion.MIRROR_SQUARE(Postion.DST(mv)));
end

Postion.PreGen_zobristKeyPlayer = 0;
Postion.PreGen_zobristKeyTable = {};    -- new int[14][256];


RC4 = class();

RC4.ctor = function (self,key) --public RC4(byte[] key)
	self.x = 0;
	self.y = 0;

	self.state = {};  --new int[256];
	for i = 0,255 do
		self.state[i] = i;
	end

	local j = 0;
	local k = 1;
	for i = 0,255 do
		k = i % #key + 1;
		j = bit.band((j + self.state[i] + key[k]) , 255);  --0xff
		self:swap(i,j);
	end
end

RC4.swap = function(self,i,j)
	local t = self.state[i];
	self.state[i] = self.state[j];
	self.state[j] = t;
end


RC4.nextByte  = function(self) 
	self.x = bit.band((self.x + 1) , 255);
	self.y = bit.band((self.y + self.state[self.x]) ,255);
	self.x, self.y = self.y,self.x;
	local t = bit.band((self.state[self.x] + self.state[self.y]) ,255);
	return self.state[t];
end

RC4.nextLong = function(self) 
	return 1;
	--local n0, n1, n2, n3;
	--n0 = self:nextByte();
	--n1 = self:nextByte();
	--n2 = self:nextByte();
	--n3 = self:nextByte();
	--return n0 + bit.blshift(n1 , 8) + bit.blshift(n2 , 16) + bit.blshift(n3 , 24);
end


----static----
rc4 = new(RC4,{0})   --new RC4(new byte[] {0});
Postion.PreGen_zobristKeyPlayer = rc4:nextLong();
rc4:nextLong();
rc4:nextLong();

local time1 = os.clock();
for i= 0,13 do
	Postion.PreGen_zobristKeyTable[i] = {};
	for j = 0,255 do
		Postion.PreGen_zobristKeyTable[i][j]= rc4:nextLong();
		rc4:nextLong();
		rc4:nextLong();
	end
end
local time2 = os.clock();


Postion.ctor = function (self)
	self.sdPlayer, self.zobristKey, self.moveNum = 0,0,0;
	self.squares = {}; --new byte[256];
	self.mvList = {};  --new int[MAX_MOVE_NUM];
	self.pcList = {};  --new int[MAX_MOVE_NUM];
	self.keyList = {}; --new int[MAX_MOVE_NUM];
	self.chkList = {}; --new boolean[MAX_MOVE_NUM];
end


Postion.clearBoard = function(self)
	self.sdPlayer = 0;
	for sq = 0,255 do
		self.squares[sq] = 0;
	end
	self.zobristKey = 0;
end


Postion.setIrrev = function(self)
	-- self.mvList[0] ,self.pcList[0] = 0,0;
	self.chkList[0] = self:checked();
	self.moveNum = 1;
end



Postion.addChess  = function(self,sq, pc,del)    --addPiece(int sq, int pc, boolean del)
	local pcAdjust;
	self.squares[sq] = del and 0 or pc;--(del ? 0 : pc);
	if (pc < 16) then
		pcAdjust = pc - 8;
	else 
		pcAdjust = pc - 16;
		pcAdjust = pcAdjust + 7;
	end
	self.zobristKey = bit.bxor(self.zobristKey,self.PreGen_zobristKeyTable[pcAdjust][sq]);
end

Postion.addPiece  = function(self,sq, pc)---(int sq, int pc) {
	self:addChess(sq, pc, false);
end

Postion.delPiece  = function(self,sq, pc)---(int sq, int pc) {
	self:addChess(sq, pc, true);
end

Postion.movePiece = function(self) 
	local sqSrc = Postion.SRC(self.mvList[self.moveNum]);
	local sqDst = Postion.DST(self.mvList[self.moveNum]);
	self.pcList[self.moveNum] = self.squares[sqDst];
	if (self.pcList[self.moveNum] > 0) then
		self:delPiece(sqDst, self.pcList[self.moveNum]);
	end
	local pc = self.squares[sqSrc];
    if pc > 0 then
	    self:delPiece(sqSrc, pc);
	    self:addPiece(sqDst, pc);
    end;
end

Postion.undoMovePiece = function(self) 
	local sqSrc = Postion.SRC(self.mvList[self.moveNum]);
	local sqDst = Postion.DST(self.mvList[self.moveNum]);
	local pc = self.squares[sqDst];
    if pc > 0 then
	    self:delPiece(sqDst, pc);
	    self:addPiece(sqSrc, pc);
    end;
	if (self.pcList[self.moveNum] > 0) then
		self:addPiece(sqDst, self.pcList[self.moveNum]);
	end

end

Postion.changeSide = function(self) 
	self.sdPlayer = 1 - self.sdPlayer;
	self.zobristKey = bit.bxor(self.zobristKey,self.PreGen_zobristKeyPlayer);
end

Postion.makeMove = function(self,mv)
	if (self.moveNum == Postion.MAX_MOVE_NUM) then
		return false;
	end
	self.keyList[self.moveNum] = self.zobristKey;
	self.mvList[self.moveNum] = mv;
	self:movePiece();
	if (self:checked()) then
		self:undoMovePiece();
		return false;
	end
	
	self:changeSide();
	self.chkList[self.moveNum] = self:checked();
	self.moveNum = self.moveNum + 1;
	return self.pcList[self.moveNum - 1] , self.chkList[self.moveNum -1];  --return true;
end

Postion.undoMakeMove = function(self) 
	self.moveNum = self.moveNum -1;
	self:changeSide();
	self:undoMovePiece();
	return self.mvList[self.moveNum],self.pcList[self.moveNum];
end

Postion.nullMove = function(self) 
	self.keyList[moveNum] = self.zobristKey;
	self:changeSide();
	self.mvList[moveNum] ,self.pcList[moveNum] = 0,0;
	self.chkList[moveNum] = false;
	self.moveNum = self.moveNum + 1;
end

Postion.undoNullMove = function(self) 
	self.moveNum = self.moveNum - 1;
	self:changeSide();
end

Postion.fenPiece = function(self,c) 
	if c == 'K' then
		return Postion.PIECE_KING;
	elseif c == 'A'then
		return Postion.PIECE_ADVISOR;
	elseif c == 'B' or c == 'E' then
		return Postion.PIECE_BISHOP;
	elseif c =='H' or c =='N' then
		return Postion.PIECE_KNIGHT;
	elseif c =='R' then
		return Postion.PIECE_ROOK;
	elseif c =='C' then
		return Postion.PIECE_CANNON;
	elseif c =='P' then
		return Postion.PIECE_PAWN;
	else
		return -1;
	end
end




Postion.fromFen = function(self,fen) 
	self:clearBoard();
	local y = Postion.RANK_TOP;
	local x = Postion.FILE_LEFT;
	local index = 1;
	if (fen == nil or 0 == #fen) then
		self:setIrrev();
		return;
	end
	local c = fen:sub(index,index);
	while (c ~= ' ') do 
		if (c == '/') then
			x = Postion.FILE_LEFT;
			y = y+1;
			if (y > Postion.RANK_BOTTOM) then
				break;
			end
		elseif (c >= '1' and c <= '9') then
			for k = 1,c do
				if (x >= Postion.FILE_RIGHT) then
					break;
				end
				x = x+1;
			end
		elseif (c >= 'A' and c <= 'Z') then
			if (x <= Postion.FILE_RIGHT) then
				local pt = self:fenPiece(c);
				if (pt >= 0) then
					self:addPiece(Postion.COORD_XY(x, y), pt + 8);
				end
			x = x+1;
			end
		elseif (c >= 'a' and c <= 'z') then
			if (x <= Postion.FILE_RIGHT) then
				local pt = self:fenPiece(string.upper(c));
					if (pt >= 0) then
						self:addPiece(Postion.COORD_XY(x, y), pt + 16);
					end
				x = x + 1;
			end
		end
		index = index + 1;
		if (index == #fen+1) then
			self:setIrrev();
			return;
		end
		c = fen:sub(index,index);
	end
	index = index + 1;
	if (index == #fen+1) then
		self:setIrrev();
		return;
	end
	-- if (self.sdPlayer == (fen:sub(index,index) == 'b' and 0 or 1)) then
	-- 	changeSide();
	-- end
	-- local length = #fen;
	local flag = fen:sub(index,index);
	while flag == ' ' do
		index = index + 1;
		flag = fen:sub(index,index);
	end
	self.sdPlayer = (flag == 'b' and 1 or 0);
	self:setIrrev();
end

Postion.FEN_PIECE = "       KABNRCP kabnrcp";

Postion.toFen = function(self) 
	local fen = {};
	for y = Postion.RANK_TOP,Postion.RANK_BOTTOM do
		local k = 0;
		for x = Postion.FILE_LEFT,Postion.FILE_RIGHT do
			local pc = self.squares[Postion.COORD_XY(x, y)];
			if (pc > 0) then
				if (k > 0) then
					fen[#fen +1] = k .. "";
					k = 0;
				end
				fen[#fen +1] = Postion.FEN_PIECE:sub(pc,pc);
			else
				k  = k+1;
			end
		end
		if (k > 0) then
			fen[#fen +1] = k .. "";
		end
		fen[#fen +1] = "/";
	end
	fen[#fen +1] = " ";
	fen[#fen +1] = (self.sdPlayer == 0 and 'w' or 'b');
	return table.concat(fen);
end

Postion.toMoves = function(self)
	print_string("Postion.toMoves self.mvList = " .. #self.mvList);
	local moves = {};
	-- for index,mv in pairs(self.mvList) do
	for index = 1,self.moveNum-1 do
		local mv = self.mvList[index]
		moves[#moves + 1] = " ";
		local sq = Postion.SRC(mv);
		local col_ascii = Postion.FILE_X(sq) - Postion.FILE_LEFT + string.byte("a");
		moves[#moves + 1] = string.char(col_ascii);
		local row = 9 - Postion.RANK_Y(sq) + Postion.RANK_TOP;
		moves[#moves + 1] = row;

		sq = Postion.DST(mv);
		col_ascii = Postion.FILE_X(sq) - Postion.FILE_LEFT + string.byte("a");
		moves[#moves + 1] = string.char(col_ascii);
		row = 9 - Postion.RANK_Y(sq) + Postion.RANK_TOP;
		moves[#moves + 1] = row;

		print_string(string.format("index = %d,mv = %X",index,mv));
	end

	local str = table.concat(moves);
	-- print_string("Postion.toMoves = " .. str);
	return str;
end

Postion.generateMoves = function(self,mvs) --public int generateMoves(int[] mvs) 
	local moves = 1;
	local pcSelfSide = Postion.SIDE_TAG(self.sdPlayer);
	local pcOppSide = Postion.OPP_SIDE_TAG(self.sdPlayer);
	for sqSrc = 0,255 do 
		local pcSrc = self.squares[sqSrc];
		if (bit.band(pcSrc , pcSelfSide) ~= 0) then
			local pc = pcSrc - pcSelfSide
			if pc == Postion.PIECE_KING then
				for i = 1 , 4 do
					local sqDst = sqSrc + Postion.KING_DELTA[i];
					if Postion.IN_FORT(sqDst) then
						local pcDst = self.squares[sqDst];
						if bit.band(pcDst , pcSelfSide) == 0 then
							mvs[moves] = Postion.MOVE(sqSrc, sqDst);
							moves = moves + 1;
						end
					end
				end
			elseif pc ==  Postion.PIECE_ADVISOR then
				for i = 1,4 do
					local sqDst = sqSrc + Postion.ADVISOR_DELTA[i];
					if Postion.IN_FORT(sqDst) then
						local pcDst = self.squares[sqDst];
						if bit.band(pcDst , pcSelfSide) == 0 then
							mvs[moves] = Postion.MOVE(sqSrc, sqDst);
							moves = moves + 1;
						end
					end
				end
			elseif pc ==  Postion.PIECE_BISHOP then
				for i = 1,4 do
					local sqDst = sqSrc + Postion.ADVISOR_DELTA[i];
					if ((Postion.IN_BOARD(sqDst) and Postion.HOME_HALF(sqDst, self.sdPlayer) and self.squares[sqDst] == 0)) then
						sqDst = sqDst + Postion.ADVISOR_DELTA[i];
						local pcDst = self.squares[sqDst];
						if (bit.band(pcDst , pcSelfSide) == 0) then
							mvs[moves] = Postion.MOVE(sqSrc, sqDst);
							moves = moves + 1;
						end
					end
	
				end
			elseif pc ==  Postion.PIECE_KNIGHT then
				for i = 1, 4 do
					local sqDst = sqSrc + Postion.KING_DELTA[i];
					if (self.squares[sqDst] <= 0) then
						for j = 1,2 do
							sqDst = sqSrc + Postion.KNIGHT_DELTA[i][j];
							if (Postion.IN_BOARD(sqDst)) then
								local pcDst = self.squares[sqDst];
								if (bit.band(pcDst , pcSelfSide) == 0) then
									mvs[moves] = Postion.MOVE(sqSrc, sqDst);
									moves = moves + 1;
								end
							end
						end
					end
				end
			elseif pc ==  Postion.PIECE_ROOK then
				for i = 1,4 do
					local delta = Postion.KING_DELTA[i];
					local sqDst = sqSrc + delta;
					while (Postion.IN_BOARD(sqDst)) do
						local pcDst = self.squares[sqDst];
						if (pcDst > 0) then
							if (bit.band(pcDst , pcOppSide)  ~= 0) then
								mvs[moves] = Postion.MOVE(sqSrc, sqDst);
								moves = moves + 1;
							end
							break;
						end
						mvs[moves] = Postion.MOVE(sqSrc, sqDst);
						moves  = moves + 1;
						sqDst = sqDst + delta;
					end
				end
			elseif pc ==  Postion.PIECE_CANNON then
				for i = 1, 4 do
					local delta = Postion.KING_DELTA[i];
					local sqDst = sqSrc + delta;
					while (Postion.IN_BOARD(sqDst)) do
						local pcDst = self.squares[sqDst];
						if (pcDst > 0) then
							break;
						end
						mvs[moves] = Postion.MOVE(sqSrc, sqDst);
						moves  = moves + 1;
						sqDst = sqDst + delta;
					end
					sqDst = sqDst + delta;
					while (Postion.IN_BOARD(sqDst)) do 
						local pcDst = self.squares[sqDst];
						if (pcDst > 0) then
							if (bit.band(pcDst , pcOppSide) ~= 0) then
								mvs[moves] = Postion.MOVE(sqSrc, sqDst);
								moves = moves + 1;
							end
							break;
						end
						sqDst = sqDst + delta;
					end
				end
			elseif pc ==  Postion.PIECE_PAWN then
				local sqDst = Postion.SQUARE_FORWARD(sqSrc, self.sdPlayer);
				if (Postion.IN_BOARD(sqDst)) then
					local pcDst = self.squares[sqDst];
					if (bit.band(pcDst , pcSelfSide) == 0) then
						mvs[moves] = Postion.MOVE(sqSrc, sqDst);
						moves = moves +1;
					end
				end
				if (Postion.AWAY_HALF(sqSrc, self.sdPlayer)) then
					for delta = -1,1,2 do 
						sqDst = sqSrc + delta;
						if (Postion.IN_BOARD(sqDst)) then
							local pcDst = self.squares[sqDst];
							if (bit.band(pcDst , pcSelfSide) == 0) then
								mvs[moves] = Postion.MOVE(sqSrc, sqDst);
								moves = moves + 1;
							end
						end
					end
				end
			end
		end
	end
	return moves-1;
end








-- 摆棋走法是否合法
Postion.isLegalPutChessMove = function(self, mv, _pcSrc, _pcDst)
    -- _pcSrc为nil,说明摆棋来自board
    if not _pcSrc then 
        self.m_moveFromBoard = true;
    else 
        self.m_moveFromBoard = false; 
    end;
    local sqSrc = Postion.SRC(mv);
	local pcSrc = _pcSrc or self.squares[sqSrc];
    local pcSelfSide = 0;
    if pcSrc >= 16 then 
        pcSelfSide = Postion.SIDE_TAG(1);
    else
        pcSelfSide = Postion.SIDE_TAG(0);
    end;
    
	local sqDst = Postion.DST(mv);
    -- 是自己的位置，不能摆
    if sqSrc == sqDst and self.m_moveFromBoard then
        return false;
    end;
	local pcDst = _pcDst or self.squares[sqDst];
    -- 要摆的位置有棋子，返回false
    if pcDst ~= 0 then
        return false;
    end;
    local pc = pcSrc - pcSelfSide;
	if pc == Postion.PIECE_KING then 
        -- 将（帅）大本营内都可以摆
        if Postion.IN_FORT(sqDst) and Postion.SAME_HALF(sqSrc, sqDst) then
		    return true;
        end;
	elseif pc == Postion.PIECE_ADVISOR then
        -- 士在活动范围内可以摆
        if Postion.IN_FORT(sqDst) then
            if Postion.SAME_HALF(sqSrc, sqDst) and Postion.PIECE_ADVISOR_IN_FORT_BYTE[sqDst] == 1 then
                return true;
            end;
        end;
        return false;
	elseif pc == Postion.PIECE_BISHOP then
        -- 象活动范围
	    if Postion.SAME_HALF(sqSrc, sqDst) and Postion.PIECE_BISHOP_IN_FORT_BYTE[sqDst] == 1 then
            return true;
        end;
        return false;
	elseif pc == Postion.PIECE_KNIGHT then
        -- 马摆任意位置
        return true;
	elseif pc == Postion.PIECE_ROOK or pc == Postion.PIECE_CANNON then
        -- 车和炮任意位置都可以摆
        return true;
	elseif pc == Postion.PIECE_PAWN then
        local isAwayHalf = false;
        if pcSrc >= 16 then 
            isAwayHalf = Postion.AWAY_HALF(sqDst, 1);
        else
            isAwayHalf = Postion.AWAY_HALF(sqDst, 0);  
        end;
        -- 离开自己半场，位置任意放.
		if isAwayHalf then
			return true;
		else
            if Postion.PIECE_PAWN_SELFHALF_IN_FORT_BYTE[sqDst] == 1 then
                if Postion.PIECE_PAWN_SELFHALF_IN_FORT_BYTE[sqSrc] == 2 then
                    if self.squares[sqDst] == 0 then
                        if Postion.SAME_FILE(sqSrc,sqDst) then
                            return true;
                        else
                            if self.squares[sqDst] == 0 then
                                if pcSrc >= 16 then
                                    if self.squares[sqDst + 16] ~= pcSrc then
                                        return true;
                                    end;
                                else
                                    if self.squares[sqDst - 16] ~= pcSrc then
                                        return true;
                                    end;
                                end;
                            end;  
                        end;
                    end;
                else
                    if self.squares[sqDst] == 0 then
                        if pcSrc >= 16 then
                            if self.squares[sqDst + 16] ~= pcSrc then
                                return true;
                            end;
                        else
                            if self.squares[sqDst - 16] ~= pcSrc then
                                return true;
                            end;
                        end;
                    end;                      
                end;
            elseif Postion.PIECE_PAWN_SELFHALF_IN_FORT_BYTE[sqDst] == 2 then
                -- 自己半场摆兵
                if Postion.PIECE_PAWN_SELFHALF_IN_FORT_BYTE[sqSrc] == 1 then
                    if self.squares[sqDst] == 0 then
                        if Postion.SAME_FILE(sqSrc,sqDst) then
                            return true;
                        else
                            if pcSrc >= 16 then
                                if self.squares[sqDst - 16] ~= pcSrc then
                                    return true;
                                end;
                            else
                                if self.squares[sqDst + 16] ~= pcSrc then
                                    return true;
                                end;
                            end;
                        end
                    end;
                else-- 对家半场往回摆兵
                    if self.squares[sqDst] == 0 then
                        if pcSrc >= 16 then
                            if self.squares[sqDst - 16] ~= pcSrc then
                                return true;
                            end;
                        else
                            if self.squares[sqDst + 16] ~= pcSrc then
                                return true;
                            end;
                        end;
                    end; 
                end;                
            end;
        end
	else
		return false;
	end    
end;









---走法是否合法
Postion.legalMove = function(self, mv)
	local sqSrc = Postion.SRC(mv);
	local pcSrc = self.squares[sqSrc];
	local pcSelfSide = Postion.SIDE_TAG(self.sdPlayer);
	if (bit.band(pcSrc , pcSelfSide) == 0) then
		return false;
	end

	local sqDst = Postion.DST(mv);
	local pcDst = self.squares[sqDst];
	if (bit.band(pcDst , pcSelfSide) ~= 0) then
		return false;
	end
	local pc = pcSrc - pcSelfSide;
	if pc == Postion.PIECE_KING then 
		return Postion.IN_FORT(sqDst) and Postion.KING_SPAN(sqSrc, sqDst);
	elseif pc == Postion.PIECE_ADVISOR then
		return Postion.IN_FORT(sqDst) and Postion.ADVISOR_SPAN(sqSrc, sqDst);
	elseif pc == Postion.PIECE_BISHOP then
		return Postion.SAME_HALF(sqSrc, sqDst) and Postion.BISHOP_SPAN(sqSrc, sqDst) and
					self.squares[Postion.BISHOP_PIN(sqSrc, sqDst)] == 0;
	elseif pc == Postion.PIECE_KNIGHT then
		local sqPin = Postion.KNIGHT_PIN(sqSrc, sqDst);
		return sqPin ~= sqSrc and self.squares[sqPin] == 0;
	elseif pc == Postion.PIECE_ROOK or pc == Postion.PIECE_CANNON then
		local delta;
		if (Postion.SAME_RANK(sqSrc, sqDst)) then
				delta = (sqDst < sqSrc and -1 or 1);
		elseif (Postion.SAME_FILE(sqSrc, sqDst)) then
				delta = (sqDst < sqSrc and -16  or 16);
		else 
			return false;
		end
		sqPin = sqSrc + delta;
		while (sqPin ~= sqDst and self.squares[sqPin] == 0) do
			sqPin = sqPin + delta;
		end
		if (sqPin == sqDst) then
			return pcDst == 0 or pcSrc - pcSelfSide == Postion.PIECE_ROOK;
		elseif (pcDst > 0 and pcSrc - pcSelfSide == Postion.PIECE_CANNON) then
			sqPin  = sqPin + delta;
			while (sqPin ~= sqDst and self.squares[sqPin] == 0) do
				sqPin = sqPin +  delta;
			end 
			return sqPin == sqDst;
		else 
			return false;
		end
	elseif pc == Postion.PIECE_PAWN then
		if Postion.AWAY_HALF(sqDst, self.sdPlayer)and (sqDst == sqSrc - 1 or sqDst == sqSrc + 1) then
			return true;
		end
		return sqDst == Postion.SQUARE_FORWARD(sqSrc, self.sdPlayer);
	else
		return false;
	end
end


Postion.checked = function(self) 
	local pcSelfSide = Postion.SIDE_TAG(self.sdPlayer);
	local pcOppSide = Postion.OPP_SIDE_TAG(self.sdPlayer);
	for sqSrc = 0,255 do
		if (self.squares[sqSrc] == pcSelfSide + Postion.PIECE_KING) then
			if (self.squares[Postion.SQUARE_FORWARD(sqSrc, self.sdPlayer)] == pcOppSide + Postion.PIECE_PAWN) then
				return true;
			end
			for delta = -1,1, 2 do
				if (self.squares[sqSrc + delta] == pcOppSide + Postion.PIECE_PAWN) then
					return true;
				end
			end
			for i = 1,4 do
				if (self.squares[sqSrc + Postion.ADVISOR_DELTA[i]] <= 0) then
					for j = 1,2 do
						local pcDst = self.squares[sqSrc + Postion.KNIGHT_CHECK_DELTA[i][j]];
						if (pcDst == pcOppSide + Postion.PIECE_KNIGHT) then
							return true;
						end
					end	
				end
			end
			for i = 1, 4 do
				local delta = Postion.KING_DELTA[i];
				local sqDst = sqSrc + delta;
				while (Postion.IN_BOARD(sqDst)) do
					local pcDst = self.squares[sqDst];
					if (pcDst > 0) then
						if (pcDst == pcOppSide + Postion.PIECE_ROOK or pcDst == pcOppSide + Postion.PIECE_KING) then
							return true;
						end
						break;
					end
					sqDst = sqDst + delta;
				end
				sqDst = sqDst + delta;
				while (Postion.IN_BOARD(sqDst)) do
					local pcDst = self.squares[sqDst];
					if (pcDst > 0) then
						if (pcDst == pcOppSide + Postion.PIECE_CANNON) then
							return true;
						end
						break;
					end
					sqDst = sqDst + delta;
				end
			end
			return false;
		end
		
	end
	return false;
end







Postion.isMate = function(self) 
	local mvs = {} --nt[] mvs = new int[MAX_GEN_MOVES];
	local moves = self:generateMoves(mvs);  --生成所有走法
	print_string("Postion.isMate moves = " .. moves);
	for key,mv in pairs(mvs) do
		print_string(string.format("key = %d,mv = %d",key,mv));
		if self:makeMove(mv) then  --有一步可走的棋
			self:undoMakeMove();
			return false;     --没被将死
		end

	end
	return true;    --被将死
end

Postion.inCheck = function(self) 
	return self.chkList[self.moveNum - 1];
end





Postion.captured = function(self)
	return self.pcList[self.moveNum - 1] > 0;
end

Postion.repValue = function(self,vlRep) 
	return (bit.band(vlRep , 2) == 0 and 0 or -1) + (bit.band(vlRep , 4) == 0 and 0 or 1);
end

Postion.repStatus = function(self) 
	return self:repStatus(1);
end

Postion.repStatus= function(self,recur_) 
	local recur = recur_;
	local selfSide = false;
	local perpCheck = true;
	local oppPerpCheck = true;
	local index = moveNum - 1;
	while (self.mvList[index] > 0 and self.pcList[index] == 0) do
		if (selfSide) then
			perpCheck = perpCheck and self.chkList[index];
			if (self.keyList[index] == self.zobristKey) then
				recur = recur - 1;
				if (recur == 0) then
					return 1 + (perpCheck and 2 or 0) + (oppPerpCheck and 4 or 0);
				end
			end
		else 
			oppPerpCheck = oppPerpCheck and self.chkList[index];
		end
		selfSide = not selfSide;
		index = index -1;
	end
	return 0;
end

--长将判断
Postion.checkLoopKill = function(self)
    if self.moveNum < 8 then return false;end  -- 步数小于8不可能产生2次循环
	local index = self.moveNum - 1;
    if self.chkList[index] and not self.chkList[index-1] and self.pcList[index] <= 0 then
        local preIndex = index;
        for i=index-2,1,-2 do
            if self.chkList[i] and self.pcList[i] <= 0 then -- 将军切未吃子
                if self.mvList[i] == self.mvList[index] then
                    preIndex = i;
                    local loop = function()
                        for j=1,index-preIndex do
                            if preIndex-j <= 0 or self.mvList[preIndex-j] ~= self.mvList[index-j] then
                                return false;
                            end
                        end
                        return true;
                    end
                    if loop() then return true; end
                end
            else
                break;
            end
        end
    end
    return false;
end

--长捉判断
Postion.checkLoopCatch = function(self)
    if self.moveNum < 8 then return false;end  -- 步数小于8不可能产生2次循环
    local ret = false;
    local index = self.moveNum - 1;
    if not self.chkList[index] and not self.chkList[index-1] and self.pcList[index] <= 0 then
        local mine_mv = self.mvList[index];
        local opp_mv = self.mvList[index-1];
        local mine_src = Postion.SRC(mine_mv);
        local mine_dst = Postion.DST(mine_mv);
        local opp_src = Postion.SRC(opp_mv);
        local opp_dst = Postion.DST(opp_mv);
        local legal_move = Postion.MOVE(mine_dst,opp_dst);

        local loop = function(mineSrc,oppSrc,func)
            if self.moveNum < 4 then return ;end
            local ret = self.moveNum;
            self:undoMovePiece();
            self.moveNum = self.moveNum - 1;
            self:undoMovePiece();
            self.moveNum = self.moveNum - 1;
            Log.i("self.moveNum:"..self.moveNum);
            local mine_mv = self.mvList[self.moveNum];
            local opp_mv = self.mvList[self.moveNum-1];
            local mine_src = Postion.SRC(mine_mv);
            local mine_dst = Postion.DST(mine_mv);
            local opp_src = Postion.SRC(opp_mv);
            local opp_dst = Postion.DST(opp_mv);
            local legal_move = Postion.MOVE(mine_dst,opp_dst);
            if mineSrc == mine_dst and oppSrc == opp_dst and not self.chkList[self.moveNum-1] and not self.chkList[self.moveNum] and self:canMove(legal_move) then --表示一直在操作同一个子
               ret = func(mine_src,opp_src,func) or ret;
            end
            self.moveNum = self.moveNum + 1;
            self:movePiece();
            self.moveNum = self.moveNum + 1;
            self:movePiece();
            return ret;
        end
        if self:canMove(legal_move) and not self.chkList[index-1] and  not self.chkList[index] then
            self.moveNum = self.moveNum - 1;
            local startIndex = loop(mine_src,opp_src,loop);
            self.moveNum = self.moveNum + 1;
            if startIndex then
                local preIndex = index;
                for i=index-2,startIndex,-2 do
                    if not self.chkList[i] and self.pcList[i] <= 0 then -- 未将军切未吃子
                        if self.mvList[i] == self.mvList[index] then
                            preIndex = i;
                            local loop1 = function()
                                for j=1,index-preIndex do
                                    if preIndex-j < startIndex or self.mvList[preIndex-j] ~= self.mvList[index-j] then
                                        return false;
                                    end
                                end
                                return true;
                            end
                            if loop1() then return true; end
                        end
                    else
                        break;
                    end
                end
            end
        end
    end
    return ret;
end

--是否长捉长将
Postion.checkLoop = function(self)
	print_string("Postion.checkLoop = function(self)");
    
    if self:checkLoopKill() or self:checkLoopCatch() then 
        self:undoMakeMove();
        return true;
    end
    return false;

--	if self.moveNum < 10 then 
--		return false;
--	end

--	local index = self.moveNum - 1;

--	local mv = self.mvList[index];
--	local mv_src = Postion.SRC(mv);
--	local mv_dst = Postion.DST(mv);

--	local mv1 = self.mvList[index - 1];
--	local mv_src1 = Postion.SRC(mv1);
--	local mv_dst1 = Postion.DST(mv1);



--	local mv4 = self.mvList[index - 4];
--	local mv_src4 = Postion.SRC(mv4);
--	local mv_dst4 = Postion.DST(mv4);


--	local mv5 = self.mvList[index - 5];
--	local mv_src5 = Postion.SRC(mv5);
--	local mv_dst5 = Postion.DST(mv5);

--	local mv8 = self.mvList[index - 8];
--	local mv_src8 = Postion.SRC(mv8);
--	local mv_dst8 = Postion.DST(mv8);


--	if mv_dst == mv_dst4 and mv_dst == mv_dst8  
--		and mv_dst1 == mv_dst5   then

--		sys_set_int("win32_console_color",10);
--		print_string("mv == self.mvList[index - 4] and mv == self.mvList[index - 8]");
--		sys_set_int("win32_console_color",9);
--		local enemy_mv = self.mvList[index -1];
--		local enemy_dst = Postion.DST(enemy_mv)
--		local mine_dst = Postion.DST(mv)

--		local legal_move = Postion.MOVE(mine_dst,enemy_dst); --

--        --如果能够捉前一个棋子  则说明长捉
--		if self:canMove(legal_move) and not self.chkList[index-1] then 
--			print_string(" checkLoop " .. mv);
--			self:undoMakeMove();
--			return true;
--		else
--			return false;
--		end

--	else
--		return false;
--	end
end



Postion.canMove = function(self, mv)
	local sqSrc = Postion.SRC(mv);
	local pcSrc = self.squares[sqSrc];
	local pcSelfSide = Postion.SIDE_TAG(1-self.sdPlayer);
	if (bit.band(pcSrc , pcSelfSide) == 0) then
		return false;
	end

	local sqDst = Postion.DST(mv);
	local pcDst = self.squares[sqDst];
	if (bit.band(pcDst , pcSelfSide) ~= 0) then
		return false;
	end
	local pc = pcSrc - pcSelfSide;
	if pc == Postion.PIECE_KING then 
		return Postion.IN_FORT(sqDst) and Postion.KING_SPAN(sqSrc, sqDst);
	elseif pc == Postion.PIECE_ADVISOR then
		return Postion.IN_FORT(sqDst) and Postion.ADVISOR_SPAN(sqSrc, sqDst);
	elseif pc == Postion.PIECE_BISHOP then
		return Postion.SAME_HALF(sqSrc, sqDst) and Postion.BISHOP_SPAN(sqSrc, sqDst) and
					self.squares[Postion.BISHOP_PIN(sqSrc, sqDst)] == 0;
	elseif pc == Postion.PIECE_KNIGHT then
		local sqPin = Postion.KNIGHT_PIN(sqSrc, sqDst);
		return sqPin ~= sqSrc and self.squares[sqPin] == 0;
	elseif pc == Postion.PIECE_ROOK or pc == Postion.PIECE_CANNON then
		local delta;
		if (Postion.SAME_RANK(sqSrc, sqDst)) then
				delta = (sqDst < sqSrc and -1 or 1);
		elseif (Postion.SAME_FILE(sqSrc, sqDst)) then
				delta = (sqDst < sqSrc and -16  or 16);
		else 
			return false;
		end
		sqPin = sqSrc + delta;
		while (sqPin ~= sqDst and self.squares[sqPin] == 0) do
			sqPin = sqPin + delta;
		end
		if (sqPin == sqDst) then
			return pcDst == 0 or pcSrc - pcSelfSide == Postion.PIECE_ROOK;
		elseif (pcDst > 0 and pcSrc - pcSelfSide == Postion.PIECE_CANNON) then
			sqPin  = sqPin + delta;
			while (sqPin ~= sqDst and self.squares[sqPin] == 0) do
				sqPin = sqPin +  delta;
			end 
			return sqPin == sqDst;
		else 
			return false;
		end
	elseif pc == Postion.PIECE_PAWN then
		if Postion.AWAY_HALF(sqDst, self.sdPlayer)and (sqDst == sqSrc - 1 or sqDst == sqSrc + 1) then
			return true;
		end
		return sqDst == Postion.SQUARE_FORWARD(sqSrc, self.sdPlayer);
	else
		return false;
	end
end


Postion.generateChessMoves = function(self,sqSrc) --public int generateMoves(int[] mvs) 
	local moves = 1;
	local mvs = {};
	local pcSelfSide = Postion.SIDE_TAG(self.sdPlayer);
	local pcOppSide = Postion.OPP_SIDE_TAG(self.sdPlayer);
		local pcSrc = self.squares[sqSrc];
		if (bit.band(pcSrc , pcSelfSide) ~= 0) then
			local pc = pcSrc - pcSelfSide
			if pc == Postion.PIECE_KING then
				for i = 1 , 4 do
					local sqDst = sqSrc + Postion.KING_DELTA[i];
					if Postion.IN_FORT(sqDst) then
						local pcDst = self.squares[sqDst];
						if bit.band(pcDst , pcSelfSide) == 0 then
							mvs[moves] = Postion.MOVE(sqSrc, sqDst);
							moves = moves + 1;
						end
					end
				end
			elseif pc ==  Postion.PIECE_ADVISOR then
				for i = 1,4 do
					local sqDst = sqSrc + Postion.ADVISOR_DELTA[i];
					if Postion.IN_FORT(sqDst) then
						local pcDst = self.squares[sqDst];
						if bit.band(pcDst , pcSelfSide) == 0 then
							mvs[moves] = Postion.MOVE(sqSrc, sqDst);
							moves = moves + 1;
						end
					end
				end
			elseif pc ==  Postion.PIECE_BISHOP then
				for i = 1,4 do
					local sqDst = sqSrc + Postion.ADVISOR_DELTA[i];
					if ((Postion.IN_BOARD(sqDst) and Postion.HOME_HALF(sqDst, self.sdPlayer) and self.squares[sqDst] == 0)) then
						sqDst = sqDst + Postion.ADVISOR_DELTA[i];
						local pcDst = self.squares[sqDst];
						if (bit.band(pcDst , pcSelfSide) == 0) then
							mvs[moves] = Postion.MOVE(sqSrc, sqDst);
							moves = moves + 1;
						end
					end
	
				end
			elseif pc ==  Postion.PIECE_KNIGHT then
				for i = 1, 4 do
					local sqDst = sqSrc + Postion.KING_DELTA[i];
					if (self.squares[sqDst] <= 0) then
						for j = 1,2 do
							sqDst = sqSrc + Postion.KNIGHT_DELTA[i][j];
							if (Postion.IN_BOARD(sqDst)) then
								local pcDst = self.squares[sqDst];
								if (bit.band(pcDst , pcSelfSide) == 0) then
									mvs[moves] = Postion.MOVE(sqSrc, sqDst);
									moves = moves + 1;
								end
							end
						end
					end
				end
			elseif pc ==  Postion.PIECE_ROOK then
				for i = 1,4 do
					local delta = Postion.KING_DELTA[i];
					local sqDst = sqSrc + delta;
					while (Postion.IN_BOARD(sqDst)) do
						local pcDst = self.squares[sqDst];
						if (pcDst > 0) then
							if (bit.band(pcDst , pcOppSide)  ~= 0) then
								mvs[moves] = Postion.MOVE(sqSrc, sqDst);
								moves = moves + 1;
							end
							break;
						end
						mvs[moves] = Postion.MOVE(sqSrc, sqDst);
						moves  = moves + 1;
						sqDst = sqDst + delta;
					end
				end
			elseif pc ==  Postion.PIECE_CANNON then
				for i = 1, 4 do
					local delta = Postion.KING_DELTA[i];
					local sqDst = sqSrc + delta;
					while (Postion.IN_BOARD(sqDst)) do
						local pcDst = self.squares[sqDst];
						if (pcDst > 0) then
							break;
						end
						mvs[moves] = Postion.MOVE(sqSrc, sqDst);
						moves  = moves + 1;
						sqDst = sqDst + delta;
					end
					sqDst = sqDst + delta;
					while (Postion.IN_BOARD(sqDst)) do 
						local pcDst = self.squares[sqDst];
						if (pcDst > 0) then
							if (bit.band(pcDst , pcOppSide) ~= 0) then
								mvs[moves] = Postion.MOVE(sqSrc, sqDst);
								moves = moves + 1;
							end
							break;
						end
						sqDst = sqDst + delta;
					end
				end
			elseif pc ==  Postion.PIECE_PAWN then
				local sqDst = Postion.SQUARE_FORWARD(sqSrc, self.sdPlayer);
				if (Postion.IN_BOARD(sqDst)) then
					local pcDst = self.squares[sqDst];
					if (bit.band(pcDst , pcSelfSide) == 0) then
						mvs[moves] = Postion.MOVE(sqSrc, sqDst);
						moves = moves +1;
					end
				end
				if (Postion.AWAY_HALF(sqSrc, self.sdPlayer)) then
					for delta = -1,1,2 do 
						sqDst = sqSrc + delta;
						if (Postion.IN_BOARD(sqDst)) then
							local pcDst = self.squares[sqDst];
							if (bit.band(pcDst , pcSelfSide) == 0) then
								mvs[moves] = Postion.MOVE(sqSrc, sqDst);
								moves = moves + 1;
							end
						end
					end
				end
			end
        -- 对家可走的棋
        else
			local pc = pcSrc - pcOppSide
			if pc == Postion.PIECE_KING then
				for i = 1 , 4 do
					local sqDst = sqSrc + Postion.KING_DELTA[i];
					if Postion.IN_FORT(sqDst) then
						local pcDst = self.squares[sqDst];
						if bit.band(pcDst , pcSelfSide) == 0 then
							mvs[moves] = Postion.MOVE(sqSrc, sqDst);
							moves = moves + 1;
						end
					end
				end
			elseif pc ==  Postion.PIECE_ADVISOR then
				for i = 1,4 do
					local sqDst = sqSrc + Postion.ADVISOR_DELTA[i];
					if Postion.IN_FORT(sqDst) then
						local pcDst = self.squares[sqDst];
						if bit.band(pcDst , pcSelfSide) == 0 then
							mvs[moves] = Postion.MOVE(sqSrc, sqDst);
							moves = moves + 1;
						end
					end
				end
			elseif pc ==  Postion.PIECE_BISHOP then
				for i = 1,4 do
					local sqDst = sqSrc + Postion.ADVISOR_DELTA[i];
					if ((Postion.IN_BOARD(sqDst) and Postion.HOME_HALF(sqDst,1 - self.sdPlayer) and self.squares[sqDst] == 0)) then
						sqDst = sqDst + Postion.ADVISOR_DELTA[i];
						local pcDst = self.squares[sqDst];
						if (bit.band(pcDst , pcSelfSide) == 0) then
							mvs[moves] = Postion.MOVE(sqSrc, sqDst);
							moves = moves + 1;
						end
					end
	
				end
			elseif pc ==  Postion.PIECE_KNIGHT then
				for i = 1, 4 do
					local sqDst = sqSrc + Postion.KING_DELTA[i];
					if (self.squares[sqDst] <= 0) then
						for j = 1,2 do
							sqDst = sqSrc + Postion.KNIGHT_DELTA[i][j];
							if (Postion.IN_BOARD(sqDst)) then
								local pcDst = self.squares[sqDst];
								if (bit.band(pcDst , pcSelfSide) == 0) then
									mvs[moves] = Postion.MOVE(sqSrc, sqDst);
									moves = moves + 1;
								end
							end
						end
					end
				end
			elseif pc ==  Postion.PIECE_ROOK then
				for i = 1,4 do
					local delta = Postion.KING_DELTA[i];
					local sqDst = sqSrc + delta;
					while (Postion.IN_BOARD(sqDst)) do
						local pcDst = self.squares[sqDst];
						if (pcDst > 0) then
							if (bit.band(pcDst , pcOppSide)  ~= 0) then
								mvs[moves] = Postion.MOVE(sqSrc, sqDst);
								moves = moves + 1;
							end
							break;
						end
						mvs[moves] = Postion.MOVE(sqSrc, sqDst);
						moves  = moves + 1;
						sqDst = sqDst + delta;
					end
				end
			elseif pc ==  Postion.PIECE_CANNON then
				for i = 1, 4 do
					local delta = Postion.KING_DELTA[i];
					local sqDst = sqSrc + delta;
					while (Postion.IN_BOARD(sqDst)) do
						local pcDst = self.squares[sqDst];
						if (pcDst > 0) then
							break;
						end
						mvs[moves] = Postion.MOVE(sqSrc, sqDst);
						moves  = moves + 1;
						sqDst = sqDst + delta;
					end
					sqDst = sqDst + delta;
					while (Postion.IN_BOARD(sqDst)) do 
						local pcDst = self.squares[sqDst];
						if (pcDst > 0) then
							if (bit.band(pcDst , pcOppSide) ~= 0) then
								mvs[moves] = Postion.MOVE(sqSrc, sqDst);
								moves = moves + 1;
							end
							break;
						end
						sqDst = sqDst + delta;
					end
				end
			elseif pc ==  Postion.PIECE_PAWN then
				local sqDst = Postion.SQUARE_FORWARD(sqSrc, 1 - self.sdPlayer);
				if (Postion.IN_BOARD(sqDst)) then
					local pcDst = self.squares[sqDst];
					if (bit.band(pcDst , pcSelfSide) == 0) then
						mvs[moves] = Postion.MOVE(sqSrc, sqDst);
						moves = moves +1;
					end
				end
				if (Postion.AWAY_HALF(sqSrc, 1 - self.sdPlayer)) then
					for delta = -1,1,2 do 
						sqDst = sqSrc + delta;
						if (Postion.IN_BOARD(sqDst)) then
							local pcDst = self.squares[sqDst];
							if (bit.band(pcDst , pcSelfSide) == 0) then
								mvs[moves] = Postion.MOVE(sqSrc, sqDst);
								moves = moves + 1;
							end
						end
					end
				end
			end            

		end
	return mvs;
end