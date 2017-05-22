package com.boyaa.until;

import java.io.Serializable;

public class Position implements Cloneable, Serializable {
	private static final long serialVersionUID = 1L;

	public static final int MAX_MOVE_NUM = 1024;
	public static final int MAX_GEN_MOVES = 128;

	public static final int PIECE_KING = 0;
	public static final int PIECE_ADVISOR = 1;
	public static final int PIECE_BISHOP = 2;
	public static final int PIECE_KNIGHT = 3;
	public static final int PIECE_ROOK = 4;
	public static final int PIECE_CANNON = 5;
	public static final int PIECE_PAWN = 6;

	public static final int RANK_TOP = 3;
	public static final int RANK_BOTTOM = 12;
	public static final int FILE_LEFT = 3;
	public static final int FILE_RIGHT = 11;

	private static final byte[] IN_BOARD = {
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
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

	private static final byte[] IN_FORT = {
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
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

	private static final byte[] LEGAL_SPAN = {
							 0, 0, 0, 0, 0, 0, 0, 0, 0,
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

	private static final byte[] KNIGHT_PIN = {
									0,  0,  0,  0,  0,  0,  0,  0,  0,
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

	private static final int[] KING_DELTA = {-16, -1, 1, 16};
	private static final int[] ADVISOR_DELTA = {-17, -15, 15, 17};
	private static final int[][] KNIGHT_DELTA = {{-33, -31}, {-18, 14}, {-14, 18}, {31, 33}};
	private static final int[][] KNIGHT_CHECK_DELTA = {{-33, -18}, {-31, -14}, {14, 31}, {18, 33}};

	public static final String[] STARTUP_FEN = {
		"rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1",
		"rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/R1BAKABNR w - - 0 1",
		"rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/R1BAKAB1R w - - 0 1",
		"rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/9/1C5C1/9/RN2K2NR w - - 0 1",
	};

	/**
	 * 棋子是否在棋盘里
	 * @param sq
	 * @return
	 */
	public static boolean IN_BOARD(int sq) {
		return IN_BOARD[sq] != 0;
	}

	public static boolean IN_FORT(int sq) {
		return IN_FORT[sq] != 0;
	}

	public static int RANK_Y(int sq) {
		return sq >> 4;
	}

	
	/**
	 * 获取纵坐标
	 * @param sq
	 * @return
	 */
	public static int FILE_X(int sq) {
		return sq & 15;
	}

	public static int COORD_XY(int x, int y) {
		return x + (y << 4);
	}

	
	/**
	 * 行列倒置
	 * @param sq
	 * @return
	 */
	public static int SQUARE_FLIP(int sq) {
		return 254 - sq;
	}

	public static int FILE_FLIP(int x) {
		return 14 - x;
	}

	public static int RANK_FLIP(int y) {
		return 15 - y;
	}

	public static int MIRROR_SQUARE(int sq) {
		return COORD_XY(FILE_FLIP(FILE_X(sq)), RANK_Y(sq));
	}

	public static int SQUARE_FORWARD(int sq, int sd) {
		return sq - 16 + (sd << 5);
	}

	public static boolean KING_SPAN(int sqSrc, int sqDst) {
		return LEGAL_SPAN[sqDst - sqSrc + 256] == 1;
	}

	public static boolean ADVISOR_SPAN(int sqSrc, int sqDst) {
		return LEGAL_SPAN[sqDst - sqSrc + 256] == 2;
	}

	public static boolean BISHOP_SPAN(int sqSrc, int sqDst) {
		return LEGAL_SPAN[sqDst - sqSrc + 256] == 3;
	}

	public static int BISHOP_PIN(int sqSrc, int sqDst) {
		return (sqSrc + sqDst) >> 1;
	}

	public static int KNIGHT_PIN(int sqSrc, int sqDst) {
		return sqSrc + KNIGHT_PIN[sqDst - sqSrc + 256];
	}

	public static boolean HOME_HALF(int sq, int sd) {
		return (sq & 0x80) != (sd << 7);
	}

	public static boolean AWAY_HALF(int sq, int sd) {
		return (sq & 0x80) == (sd << 7);
	}

	public static boolean SAME_HALF(int sqSrc, int sqDst) {
		return ((sqSrc ^ sqDst) & 0x80) == 0;
	}

	public static boolean SAME_RANK(int sqSrc, int sqDst) {
		return ((sqSrc ^ sqDst) & 0xf0) == 0;
	}

	public static boolean SAME_FILE(int sqSrc, int sqDst) {
		return ((sqSrc ^ sqDst) & 0x0f) == 0;
	}

	public static int SIDE_TAG(int sd) {
		return 8 + (sd << 3);
	}

	public static int OPP_SIDE_TAG(int sd) {
		return 16 - (sd << 3);
	}

	public static int SRC(int mv) {
		return mv & 255;
	}

	public static int DST(int mv) {
		return mv >> 8;
	}

	public static int MOVE(int sqSrc, int sqDst) {
		return sqSrc + (sqDst << 8);
	}

	public static int MIRROR_MOVE(int mv) {
		return MOVE(MIRROR_SQUARE(SRC(mv)), MIRROR_SQUARE(DST(mv)));
	}

	private static int PreGen_zobristKeyPlayer;
	private static int[][] PreGen_zobristKeyTable = new int[14][256];

	public static class RC4 {
		private int[] state = new int[256];
		private int x, y;

		private void swap(int i, int j) {
			int t = state[i];
			state[i] = state[j];
			state[j] = t;
		}

		public RC4(byte[] key) {
			x = 0;
			y = 0;
			for (int i = 0; i < 256; i ++) {
				state[i] = i;
			}
			int j = 0;
			for (int i = 0; i < 256; i ++) {
				j = (j + state[i] + key[i % key.length]) & 0xff;
				swap(i, j);
			}
		}

		public int nextByte() {
			x = (x + 1) & 0xff;
			y = (y + state[x]) & 0xff;
			swap(x, y);
			int t = (state[x] + state[y]) & 0xff;
			return state[t];
		}

		public int nextLong() {
			int n0, n1, n2, n3;
			n0 = nextByte();
			n1 = nextByte();
			n2 = nextByte();
			n3 = nextByte();
			return n0 + (n1 << 8) + (n2 << 16) + (n3 << 24);
		}
	}

	static {
		RC4 rc4 = new RC4(new byte[] {0});
		PreGen_zobristKeyPlayer = rc4.nextLong();
		rc4.nextLong();
		rc4.nextLong();
		for (int i = 0; i < 14; i ++) {
			for (int j = 0; j < 256; j ++) {
				PreGen_zobristKeyTable[i][j] = rc4.nextLong();
				rc4.nextLong();
				rc4.nextLong();
			}
		}
	}

	public int sdPlayer, zobristKey, moveNum;
	public byte[] squares = new byte[256];
	public int[] mvList = new int[MAX_MOVE_NUM];
	public int[] pcList = new int[MAX_MOVE_NUM];
	public int[] keyList = new int[MAX_MOVE_NUM];
	public boolean[] chkList = new boolean[MAX_MOVE_NUM];

	public void clearBoard() {
		sdPlayer = 0;
		for (int sq = 0; sq < 256; sq ++) {
			squares[sq] = 0;
		}
		zobristKey = 0;
	}

	public void setIrrev() {
		mvList[0] = pcList[0] = 0;
		chkList[0] = checked();
		moveNum = 1;
	}

	public void addPiece(int sq, int pc, boolean del) {
		int pcAdjust;
		squares[sq] = (byte) (del ? 0 : pc);
		if (pc < 16) {
			pcAdjust = pc - 8;
		} else {
			pcAdjust = pc - 16;
			pcAdjust += 7;
		}
		zobristKey ^= PreGen_zobristKeyTable[pcAdjust][sq];
	}

	public void addPiece(int sq, int pc) {
		addPiece(sq, pc, false);
	}

	public void delPiece(int sq, int pc) {
		addPiece(sq, pc, true);
	}

	public void movePiece() {
		int sqSrc = SRC(mvList[moveNum]);
		int sqDst = DST(mvList[moveNum]);
		pcList[moveNum] = squares[sqDst];
		if (pcList[moveNum] > 0) {
			delPiece(sqDst, pcList[moveNum]);
		}
		int pc = squares[sqSrc];
		delPiece(sqSrc, pc);
		addPiece(sqDst, pc);
	}

	public void undoMovePiece() {
		int sqSrc = SRC(mvList[moveNum]);
		int sqDst = DST(mvList[moveNum]);
		int pc = squares[sqDst];
		delPiece(sqDst, pc);
		addPiece(sqSrc, pc);
		if (pcList[moveNum] > 0) {
			addPiece(sqDst, pcList[moveNum]);
		}
	}

	public void changeSide() {
		sdPlayer = 1 - sdPlayer;
		zobristKey ^= PreGen_zobristKeyPlayer;
	}

	public boolean makeMove(int mv) {
		if (moveNum == MAX_MOVE_NUM) {
			return false;
		}
		keyList[moveNum] = zobristKey;
		mvList[moveNum] = mv;
		movePiece();
		if (checked()) {
			undoMovePiece();
			return false;
		}
		changeSide();
		chkList[moveNum] = checked();
		moveNum ++;
		return true;
	}

	public void undoMakeMove() {
		moveNum --;
		changeSide();
		undoMovePiece();
	}

	public void nullMove() {
		keyList[moveNum] = zobristKey;
		changeSide();
		mvList[moveNum] = pcList[moveNum] = 0;
		chkList[moveNum] = false;
		moveNum ++;
	}

	public void undoNullMove() {
		moveNum --;
		changeSide();
	}

	public int fenPiece(char c) {
		switch (c) {
		case 'K':
			return PIECE_KING;
		case 'A':
			return PIECE_ADVISOR;
		case 'B':
		case 'E':
			return PIECE_BISHOP;
		case 'H':
		case 'N':
			return PIECE_KNIGHT;
		case 'R':
			return PIECE_ROOK;
		case 'C':
			return PIECE_CANNON;
		case 'P':
			return PIECE_PAWN;
		default:
			return -1;
		}
	}

	public void fromFen(String fen) {
		clearBoard();
		int y = RANK_TOP;
		int x = FILE_LEFT;
		int index = 0;
		if (index == fen.length()) {
			setIrrev();
			return;
		}
		char c = fen.charAt(index);
		while (c != ' ') {
			if (c == '/') {
				x = FILE_LEFT;
				y ++;
				if (y > RANK_BOTTOM) {
					break;
				}
			} else if (c >= '1' && c <= '9') {
				for (int k = 0; k < (c - '0'); k ++) {
					if (x >= FILE_RIGHT) {
						break;
					}
					x ++;
				}
			} else if (c >= 'A' && c <= 'Z') {
				if (x <= FILE_RIGHT) {
					int pt = fenPiece(c);
					if (pt >= 0) {
						addPiece(COORD_XY(x, y), pt + 8);
					}
					x ++;
				}
			} else if (c >= 'a' && c <= 'z') {
				if (x <= FILE_RIGHT) {
					int pt = fenPiece((char) (c + 'A' - 'a'));
					if (pt >= 0) {
						addPiece(COORD_XY(x, y), pt + 16);
					}
					x ++;
				}
			}
			index ++;
			if (index == fen.length()) {
				setIrrev();
				return;
			}
			c = fen.charAt(index);
		}
		index ++;
		if (index == fen.length()) {
			setIrrev();
			return;
		}
		if (sdPlayer == (fen.charAt(index) == 'b' ? 0 : 1)) {
			changeSide();
		}
		setIrrev();
	}

	private static final String FEN_PIECE = "        KABNRCP kabnrcp ";

	public String toFen() {
		StringBuffer fen = new StringBuffer();
		for (int y = RANK_TOP; y <= RANK_BOTTOM; y ++) {
			int k = 0;
			for (int x = FILE_LEFT; x <= FILE_RIGHT; x ++) {
				int pc = squares[COORD_XY(x, y)];
				if (pc > 0) {
					if (k > 0) {
						fen.append((char) ('0' + k));
						k = 0;
					}
					fen.append(FEN_PIECE.charAt(pc));
				} else {
					k ++;
				}
			}
			if (k > 0) {
				fen.append((char) ('0' + k));
			}
			fen.append('/');
		}
		fen.setCharAt(fen.length() - 1, ' ');
		fen.append(sdPlayer == 0 ? 'w' : 'b');
		return fen.toString();
	}

	public int generateMoves(int[] mvs) {
		int moves = 0;
		int pcSelfSide = SIDE_TAG(sdPlayer);
		int pcOppSide = OPP_SIDE_TAG(sdPlayer);
		for (int sqSrc = 0; sqSrc < 256; sqSrc ++) {
			int pcSrc = squares[sqSrc];
			if ((pcSrc & pcSelfSide) == 0) {
				continue;
			}
			switch (pcSrc - pcSelfSide) {
			case PIECE_KING:
				for (int i = 0; i < 4; i ++) {
					int sqDst = sqSrc + KING_DELTA[i];
					if (!IN_FORT(sqDst)) {
						continue;
					}
					int pcDst = squares[sqDst];
					if ((pcDst & pcSelfSide) == 0) {
						mvs[moves] = MOVE(sqSrc, sqDst);
						moves ++;
					}
				}
				break;
			case PIECE_ADVISOR:
				for (int i = 0; i < 4; i ++) {
					int sqDst = sqSrc + ADVISOR_DELTA[i];
					if (!IN_FORT(sqDst)) {
						continue;
					}
					int pcDst = squares[sqDst];
					if ((pcDst & pcSelfSide) == 0) {
						mvs[moves] = MOVE(sqSrc, sqDst);
						moves ++;
					}
				}
				break;
			case PIECE_BISHOP:
				for (int i = 0; i < 4; i ++) {
					int sqDst = sqSrc + ADVISOR_DELTA[i];
					if (!(IN_BOARD(sqDst) && HOME_HALF(sqDst, sdPlayer) && squares[sqDst] == 0)) {
						continue;
					}
					sqDst += ADVISOR_DELTA[i];
					int pcDst = squares[sqDst];
					if ((pcDst & pcSelfSide) == 0) {
						mvs[moves] = MOVE(sqSrc, sqDst);
						moves ++;
					}
				}
				break;
			case PIECE_KNIGHT:
				for (int i = 0; i < 4; i ++) {
					int sqDst = sqSrc + KING_DELTA[i];
					if (squares[sqDst] > 0) {
						continue;
					}
					for (int j = 0; j < 2; j ++) {
						sqDst = sqSrc + KNIGHT_DELTA[i][j];
						if (!IN_BOARD(sqDst)) {
							continue;
						}
						int pcDst = squares[sqDst];
						if ((pcDst & pcSelfSide) == 0) {
							mvs[moves] = MOVE(sqSrc, sqDst);
							moves ++;
						}
					}
				}
				break;
			case PIECE_ROOK:
				for (int i = 0; i < 4; i ++) {
					int delta = KING_DELTA[i];
					int sqDst = sqSrc + delta;
					while (IN_BOARD(sqDst)) {
						int pcDst = squares[sqDst];
						if (pcDst > 0) {
							if ((pcDst & pcOppSide) != 0) {
								mvs[moves] = MOVE(sqSrc, sqDst);
								moves ++;
							}
							break;
						}
						mvs[moves] = MOVE(sqSrc, sqDst);
						moves ++;
						sqDst += delta;
					}
				}
				break;
			case PIECE_CANNON:
				for (int i = 0; i < 4; i ++) {
					int delta = KING_DELTA[i];
					int sqDst = sqSrc + delta;
					while (IN_BOARD(sqDst)) {
						int pcDst = squares[sqDst];
						if (pcDst > 0) {
							break;
						}
						mvs[moves] = MOVE(sqSrc, sqDst);
						moves ++;
						sqDst += delta;
					}
					sqDst += delta;
					while (IN_BOARD(sqDst)) {
						int pcDst = squares[sqDst];
						if (pcDst > 0) {
							if ((pcDst & pcOppSide) != 0) {
								mvs[moves] = MOVE(sqSrc, sqDst);
								moves ++;
							}
							break;
						}
						sqDst += delta;
					}
				}
				break;
			case PIECE_PAWN:
				int sqDst = SQUARE_FORWARD(sqSrc, sdPlayer);
				if (IN_BOARD(sqDst)) {
					int pcDst = squares[sqDst];
					if ((pcDst & pcSelfSide) == 0) {
						mvs[moves] = MOVE(sqSrc, sqDst);
						moves ++;
					}
				}
				if (AWAY_HALF(sqSrc, sdPlayer)) {
					for (int delta = -1; delta <= 1; delta += 2) {
						sqDst = sqSrc + delta;
						if (IN_BOARD(sqDst)) {
							int pcDst = squares[sqDst];
							if ((pcDst & pcSelfSide) == 0) {
								mvs[moves] = MOVE(sqSrc, sqDst);
								moves ++;
							}
						}
					}
				}
				break;
			}
		}
		return moves;
	}

	/**
	 * 走法是否合法
	 * @param mv
	 * @return
	 */
	public boolean legalMove(int mv) {
		int sqSrc = SRC(mv);
		int pcSrc = squares[sqSrc];
		int pcSelfSide = SIDE_TAG(sdPlayer);
		if ((pcSrc & pcSelfSide) == 0) {
			return false;
		}

		int sqDst = DST(mv);
		int pcDst = squares[sqDst];
		if ((pcDst & pcSelfSide) != 0) {
			return false;
		}

		switch (pcSrc - pcSelfSide) {
		case PIECE_KING:
			return IN_FORT(sqDst) && KING_SPAN(sqSrc, sqDst);
		case PIECE_ADVISOR:
			return IN_FORT(sqDst) && ADVISOR_SPAN(sqSrc, sqDst);
		case PIECE_BISHOP:
			return SAME_HALF(sqSrc, sqDst) && BISHOP_SPAN(sqSrc, sqDst) &&
					squares[BISHOP_PIN(sqSrc, sqDst)] == 0;
		case PIECE_KNIGHT:
			int sqPin = KNIGHT_PIN(sqSrc, sqDst);
			return sqPin != sqSrc && squares[sqPin] == 0;
		case PIECE_ROOK:
		case PIECE_CANNON:
			int delta;
			if (SAME_RANK(sqSrc, sqDst)) {
				delta = (sqDst < sqSrc ? -1 : 1);
			} else if (SAME_FILE(sqSrc, sqDst)) {
				delta = (sqDst < sqSrc ? -16 : 16);
			} else {
				return false;
			}
			sqPin = sqSrc + delta;
			while (sqPin != sqDst && squares[sqPin] == 0) {
				sqPin += delta;
			}
			if (sqPin == sqDst) {
				return pcDst == 0 || pcSrc - pcSelfSide == PIECE_ROOK;
			} else if (pcDst > 0 && pcSrc - pcSelfSide == PIECE_CANNON) {
				sqPin += delta;
				while (sqPin != sqDst && squares[sqPin] == 0) {
					sqPin += delta;
				}
				return sqPin == sqDst;
			} else {
				return false;
			}
		case PIECE_PAWN:
			if (AWAY_HALF(sqDst, sdPlayer) && (sqDst == sqSrc - 1 || sqDst == sqSrc + 1)) {
				return true;
			}
			return sqDst == SQUARE_FORWARD(sqSrc, sdPlayer);
		default:
			return false;
		}
	}

	public boolean checked() {
		int pcSelfSide = SIDE_TAG(sdPlayer);
		int pcOppSide = OPP_SIDE_TAG(sdPlayer);
		for (int sqSrc = 0; sqSrc < 256; sqSrc ++) {
			if (squares[sqSrc] != pcSelfSide + PIECE_KING) {
				continue;
			}
			if (squares[SQUARE_FORWARD(sqSrc, sdPlayer)] == pcOppSide + PIECE_PAWN) {
				return true;
			}
			for (int delta = -1; delta <= 1; delta += 2) {
				if (squares[sqSrc + delta] == pcOppSide + PIECE_PAWN) {
					return true;
				}
			}
			for (int i = 0; i < 4; i ++) {
				if (squares[sqSrc + ADVISOR_DELTA[i]] > 0) {
					continue;
				}
				for (int j = 0; j < 2; j ++) {
					int pcDst = squares[sqSrc + KNIGHT_CHECK_DELTA[i][j]];
					if (pcDst == pcOppSide + PIECE_KNIGHT) {
						return true;
					}
				}
			}
			for (int i = 0; i < 4; i ++) {
				int delta = KING_DELTA[i];
				int sqDst = sqSrc + delta;
				while (IN_BOARD(sqDst)) {
					int pcDst = squares[sqDst];
					if (pcDst > 0) {
						if (pcDst == pcOppSide + PIECE_ROOK || pcDst == pcOppSide + PIECE_KING) {
							return true;
						}
						break;
					}
					sqDst += delta;
				}
				sqDst += delta;
				while (IN_BOARD(sqDst)) {
					int pcDst = squares[sqDst];
					if (pcDst > 0) {
						if (pcDst == pcOppSide + PIECE_CANNON) {
							return true;
						}
						break;
					}
					sqDst += delta;
				}
			}
			return false;
		}
		return false;
	}

	/**
	 * 是否被将死
	 * @return
	 */
	public boolean isMate() {
		int[] mvs = new int[MAX_GEN_MOVES];
		int moves = generateMoves(mvs);  //生成所有走法
		for (int i = 0; i < moves; i ++) {
			if (makeMove(mvs[i])) {   //有一步可走的棋
				undoMakeMove();
				return false;     //没被将死
			}
		}
		return true;    //被将死
	}

	public boolean inCheck() {
		return chkList[moveNum - 1];
	}

	/**
	 * 此步走棋是否有吃子情况
	 * @return
	 */
	public boolean captured() {
		return pcList[moveNum - 1] > 0;
	}

	public int repValue(int vlRep) {
		return ((vlRep & 2) == 0 ? 0 : -1) + ((vlRep & 4) == 0 ? 0 : 1);
	}

	public int repStatus() {
		return repStatus(1);
	}

	public int repStatus(int recur_) {
		int recur = recur_;
		boolean selfSide = false;
		boolean perpCheck = true;
		boolean oppPerpCheck = true;
		int index = moveNum - 1;
		while (mvList[index] > 0 && pcList[index] == 0) {
			if (selfSide) {
				perpCheck = perpCheck && chkList[index];
				if (keyList[index] == zobristKey) {
					recur --;
					if (recur == 0) {
						return 1 + (perpCheck ? 2 : 0) + (oppPerpCheck ? 4 : 0);
					}
				}
			} else {
				oppPerpCheck = oppPerpCheck && chkList[index];
			}
			selfSide = !selfSide;
			index --;
		}
		return 0;
	}

	public Position mirror() {
		Position pos = new Position();
		pos.clearBoard();
		for (int sq = 0; sq < 256; sq ++) {
			int pc = squares[sq];
			if (pc > 0) {
				pos.addPiece(MIRROR_SQUARE(sq), pc);
			}
		}
		if (sdPlayer == 1) {
			pos.changeSide();
		}
		return pos;
	}

	@Override
	public Position clone() {
		Position pos = new Position();
		pos.clearBoard();
		for (int sq = 0; sq < 256; sq ++) {
			if (IN_BOARD(sq)) {
				int pc = squares[sq];
				if (pc > 0) {
					pos.addPiece(sq, pc);
				}
			}
		}
		if (sdPlayer == 1) {
			pos.changeSide();
		}
		pos.setIrrev();
		return pos;
	}
}