require("libs/bit");
require("util/postion")

Cchess = class();

Cchess.MAX_DIGIT = 9;
Cchess.MAX_DIRECT = 3;
Cchess.DIRECT_TO_POS = 5;
Cchess.MAX_PIECE = 7;
Cchess.MAX_POS = 8;
Cchess.wPromote = "变";

Cchess.cwPiece2WordSimp = {
  [0] = {
    [0] = "帅", "仕", "相", "马", "车", "炮", "兵", "　"
  }, {
    [0] = "将", "士", "象", "马", "车", "炮", "卒", "　"
  }
};

Cchess.cwPos2WordSimp = {
  	[0] = "一", "二", "三", "四", "五",
  	"前", "中", "后", "　", "　"
};

Cchess.cwDigit2WordSimp = {
  [0] = {
    [0] = "一", "二", "三", "四", "五",
    "六", "七", "八", "九", "　"
  }, {
    [0] = "１", "２", "３", "４", "５",
    "６", "７", "８", "９", "　"
  }
};

Cchess.cwDirect2WordSimp = {
	[0] = "进", "平", "退", "　"
};

Cchess.cucSquare2FileSq = {
  [0]=0, 0, 0,    0,    0,    0,    0,    0,    0,    0,    0,    0, 0, 0, 0, 0,
  	  0, 0, 0,    0,    0,    0,    0,    0,    0,    0,    0,    0, 0, 0, 0, 0,
  	  0, 0, 0,    0,    0,    0,    0,    0,    0,    0,    0,    0, 0, 0, 0, 0,
  	  0, 0, 0, 0x80, 0x70, 0x60, 0x50, 0x40, 0x30, 0x20, 0x10, 0x00, 0, 0, 0, 0,
	  0, 0, 0, 0x81, 0x71, 0x61, 0x51, 0x41, 0x31, 0x21, 0x11, 0x01, 0, 0, 0, 0,
	  0, 0, 0, 0x82, 0x72, 0x62, 0x52, 0x42, 0x32, 0x22, 0x12, 0x02, 0, 0, 0, 0,
	  0, 0, 0, 0x83, 0x73, 0x63, 0x53, 0x43, 0x33, 0x23, 0x13, 0x03, 0, 0, 0, 0,
	  0, 0, 0, 0x84, 0x74, 0x64, 0x54, 0x44, 0x34, 0x24, 0x14, 0x04, 0, 0, 0, 0,
	  0, 0, 0, 0x85, 0x75, 0x65, 0x55, 0x45, 0x35, 0x25, 0x15, 0x05, 0, 0, 0, 0,
	  0, 0, 0, 0x86, 0x76, 0x66, 0x56, 0x46, 0x36, 0x26, 0x16, 0x06, 0, 0, 0, 0,
	  0, 0, 0, 0x87, 0x77, 0x67, 0x57, 0x47, 0x37, 0x27, 0x17, 0x07, 0, 0, 0, 0,
	  0, 0, 0, 0x88, 0x78, 0x68, 0x58, 0x48, 0x38, 0x28, 0x18, 0x08, 0, 0, 0, 0,
	  0, 0, 0, 0x89, 0x79, 0x69, 0x59, 0x49, 0x39, 0x29, 0x19, 0x09, 0, 0, 0, 0,
	  0, 0, 0,    0,    0,    0,    0,    0,    0,    0,    0,    0, 0, 0, 0, 0,
	  0, 0, 0,    0,    0,    0,    0,    0,    0,    0,    0,    0, 0, 0, 0, 0,
	  0, 0, 0,    0,    0,    0,    0,    0,    0,    0,    0,    0, 0, 0, 0, 0
};

Cchess.cnPieceTypes = {
	0,0,0,0,0,0,0,
	0,1,2,3,4,5,6,0,
	0,1,2,3,4,5,6
};

Cchess.ccPos2Byte = {
  [0] = 'a', 'b', 'c', 'd', 'e', '+', '.', '-', ' ', ' ', ' ', ' '
};

Cchess.cszPieceBytes = {[0] = 'K','A','B','N','R','C','P'};

Cchess.Byte2Direct = function(nArg)
 	if nArg == '+' then
  		return 0;
    elseif nArg == '.' or nArg == '=' then
  		return 1;
 	elseif nArg == '-' then
  		return 2;
  	else 
  		return 3;
  	end
end

Cchess.Byte2Pos = function(nArg)

	if nArg >= 'a' and nArg <= 'e' then
		return string.byte(nArg) - string.byte("a");
	else 
		return Cchess.Byte2Direct(nArg) + Cchess.DIRECT_TO_POS;
	end
end

Cchess.Byte2Digit = function(nArg)
	if nArg >= '1' and nArg <= '9' then
		return string.byte(nArg) - string.byte("1");
	else
		return Cchess.MAX_DIGIT;
	end
end

Cchess.FenPiece = function(c)
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
		return 7;
	end
end

Cchess.Byte2Piece = function(nArg)
	if nArg >= '1' and nArg <= '7' then
		return string.byte(nArg) - string.byte("1");
	elseif nArg >= 'A' and nArg <= 'Z' then
		return Cchess.FenPiece(nArg);
	elseif nArg >= 'a' and nArg <= 'z' then
		return Cchess.FenPiece(string.byte(nArg) - string.byte("a") + string.byte("A"))
	else 
		return Cchess.MAX_PIECE;
	end
end

Cchess.FILESQ_FILE_X = function(sq)
	return bit.brshift(sq,4);
end

Cchess.FILESQ_RANK_Y = function(sq)
	return bit.band(sq,15);
end

Cchess.FILESQ_COORD_XY = function(x,y)
  	return bit.blshift(x,4) + y;
end

Cchess.SQUARE_FILESQ = function(sq)
  	return Cchess.cucSquare2FileSq[sq];
end

Cchess.Digit2Byte = function(nArg)
  return string.char(nArg + string.byte("1"));
end

Cchess.FILESQ_SIDE_PIECE = function(pos,nPieceNum)
  local sq;
  sq = pos.squares[Postion.SIDE_TAG(pos.sdPlayer) + nPieceNum];
  if sq == 0 then
  	return -1;
  elseif pos.sdPlayer == 0 then
  	return Cchess.SQUARE_FILESQ(sq);
  else 
  	return Cchess.SQUARE_FILESQ(CChess.SQUARE_FLIP(sq));
  end
end

Cchess.PIECE_TYPE = function(pc)
  return Cchess.cnPieceTypes[pc];
end

Cchess.PIECE_BYTE = function(pt)
  return Cchess.cszPieceBytes[pt];
end

Cchess.SQUARE_FLIP = function(sq)
  return 254 - sq;
end

Cchess.FIRST_PIECE = function(pt,pc)
  return pt * 2 - 1 + pc;
end

Cchess.ABS = function(Arg)
  return Arg < 0 and -Arg or Arg;
end

-- 将着法转换为坐标格式
Cchess.move2Iccs = function(mv)
	local moves = {};
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

	local str = table.concat(moves);
	return str;
end

-- 将数字纵线格式转换为中文格式
Cchess.File2Chin = function(dwFileStr,sdplayer)
	local ret = {};
	local nPos;
	local lpArg = dwFileStr;
	nPos = Cchess.Byte2Direct(lpArg[1]);
	if nPos == Cchess.MAX_DIRECT then
		nPos = Cchess.Byte2Pos(lpArg[2]);
		if nPos == Cchess.MAX_POS then
			ret[1] = Cchess.cwPiece2WordSimp[sdplayer][Cchess.Byte2Piece(lpArg[1])];
			ret[2] = Cchess.cwDigit2WordSimp[sdplayer][Cchess.Byte2Digit(lpArg[2])];
		else
			ret[1] = Cchess.cwPos2WordSimp[nPos];
			ret[2] = Cchess.cwPiece2WordSimp[sdplayer][Cchess.Byte2Piece(lpArg[1])];
		end
	else
		ret[1] = Cchess.cwPos2WordSimp[nPos + Cchess.DIRECT_TO_POS];
		ret[2] = Cchess.cwPiece2WordSimp[sdplayer][Cchess.Byte2Piece(lpArg[2])];
	end
	if lpArg[3] == '=' and Cchess.Byte2Piece(lpArg[4] == 6) then
		ret[3] = Cchess.wPromote;
		ret[4] = Cchess.cwPiece2WordSimp[sdplayer][6];
	else
		ret[3] = Cchess.cwDirect2WordSimp[Cchess.Byte2Direct(lpArg[3])];
		ret[4] = Cchess.cwDigit2WordSimp[sdplayer][Cchess.Byte2Digit(lpArg[4])];
	end

	local str = table.concat(ret);
	return str;
end

-- 将着法转换为数字纵线格式
Cchess.move2File = function(pos,mv)
 	local i, j, sq, pc, pt, nPieceNum;
  	local xSrc, ySrc, xDst, yDst;
  	local nFileList = {};
  	local nPieceList = {};
  	local ret = {};
  	if Postion.SRC(mv) == 0 or Postion.DST(mv) == 0 then
  		return;
  	end
  	pc = pos.squares[Postion.SRC(mv)];
  	if pc == 0 then
  		return;
  	end
  	pt = Cchess.PIECE_TYPE(pc);
  	ret[1] = Cchess.PIECE_BYTE(pt);
  	if pos.sdPlayer == 0 then
	    xSrc = Cchess.FILESQ_FILE_X(Cchess.SQUARE_FILESQ(Postion.SRC(mv)));
	    ySrc = Cchess.FILESQ_RANK_Y(Cchess.SQUARE_FILESQ(Postion.SRC(mv)));
	    xDst = Cchess.FILESQ_FILE_X(Cchess.SQUARE_FILESQ(Postion.DST(mv)));
	    yDst = Cchess.FILESQ_RANK_Y(Cchess.SQUARE_FILESQ(Postion.DST(mv)));
	else
	    xSrc = Cchess.FILESQ_FILE_X(Cchess.SQUARE_FILESQ(Cchess.SQUARE_FLIP(Postion.SRC(mv))));
	    ySrc = Cchess.FILESQ_RANK_Y(Cchess.SQUARE_FILESQ(Cchess.SQUARE_FLIP(Postion.SRC(mv))));
	    xDst = Cchess.FILESQ_FILE_X(Cchess.SQUARE_FILESQ(Cchess.SQUARE_FLIP(Postion.DST(mv))));
	    yDst = Cchess.FILESQ_RANK_Y(Cchess.SQUARE_FILESQ(Cchess.SQUARE_FLIP(Postion.DST(mv))));
	end
	
	if pt >= Postion.PIECE_KING and pt <= Postion.PIECE_BISHOP then
		ret[2] = Cchess.Digit2Byte(xSrc);
	else
		for i=0,8 do
			nFileList[i] = 0;
		end
		if pt == Postion.PIECE_PAWN then
			j = 5;
		else
			j = 2;
		end
		for i=0,j-1 do
			sq = Cchess.FILESQ_SIDE_PIECE(pos, Cchess.FIRST_PIECE(pt, i));
      		if (sq ~= -1) then
      			nFileList[Cchess.FILESQ_FILE_X(sq)] = nFileList[Cchess.FILESQ_FILE_X(sq)] + 1;
      		end
		end
		if nFileList[xSrc] > 1 then
			nPieceNum = 0;
			for i=0,j-1 do
				 sq = Cchess.FILESQ_SIDE_PIECE(pos, Cchess.FIRST_PIECE(pt, i));
				 if sq ~= -1 then
				 	if nFileList[Cchess.FILESQ_FILE_X(sq)] > 1 then
				 		nPieceList[nPieceNum] = Cchess.FIRST_PIECE(pt, i);
           				nPieceNum = nPieceNum + 1;
				 	end
				 end
			end
			for i=0,nPieceNum - 2 do
				for j=nPieceNum-1,i+1,-1 do
					 if Cchess.FILESQ_SIDE_PIECE(pos, nPieceList[j - 1]) > Cchess.FILESQ_SIDE_PIECE(pos, nPieceList[j]) then
					 	local temp = nPieceList[j - 1];
					 	nPieceList[j - 1] = nPieceList[j];
					 	nPieceList[j] = temp;
		         	 end
				end
			end

			sq = Cchess.FILESQ_COORD_XY(xSrc, ySrc);
			for i=0,nPieceNum-1 do
				if Cchess.FILESQ_SIDE_PIECE(pos, nPieceList[i]) == sq then
					break;
				end
			end
			if nPieceNum == 2 and i == 1 then
				ret[2] = Cchess.ccPos2Byte[2 + Cchess.DIRECT_TO_POS];
			else 
				ret[2] = Cchess.ccPos2Byte[nPieceNum > 3 and i or (i + Cchess.DIRECT_TO_POS)];
			end
		else
			ret[2] = Cchess.Digit2Byte(xSrc);
		end
	end
	if pt >= Postion.PIECE_ADVISOR and pt <= Postion.PIECE_KNIGHT then
		if Postion.SRC(mv) == Postion.DST(mv) then
			ret[3] = '=';
      		ret[4] = 'P';
		else
			ret[3] = yDst > ySrc and '-' or '+';
      		ret[4] = Cchess.Digit2Byte(xDst);
		end
	else
 		ret[3] = yDst == ySrc and '.' or (yDst > ySrc and '-' or '+');
    	ret[4] = yDst == ySrc and Cchess.Digit2Byte(xDst) or Cchess.Digit2Byte(Cchess.ABS(ySrc - yDst) - 1);
	end
	return ret;
end
