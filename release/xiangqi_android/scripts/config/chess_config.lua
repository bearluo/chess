-----棋子的编号*/
 NOCHESS    =  0;   --没有棋子

 B_ROOK1   =     201 ;  --黑车
 B_HORSE1 =      202;  --黑马
 B_ELEPHANT1 =   203;  --黑象
 B_BISHOP1=      204;  --黑士
 B_KING  =       205;  --黑帅
 B_BISHOP2 =     206;  --黑士
 B_ELEPHANT2 =   207;  --黑象
 B_HORSE2 =      208;  --黑马
 B_ROOK2   =     209 ;  --黑车
 B_CANNON1 =     210;  --黑炮
 B_CANNON2 =     211;  --黑炮

 B_PAWN1     =   212;  --黑卒
 B_PAWN2     =   213;  --黑卒
 B_PAWN3     =   214;  --黑卒
 B_PAWN4     =   215;  --黑卒
 B_PAWN5     =   216;  --黑卒
 B_BEGIN   =   B_ROOK1;
 B_END    =    B_PAWN5;

 R_ROOK1   =     101 ;  --红车
 R_HORSE1 =      102;  --红马
 R_ELEPHANT1 =   103;  --红象
 R_BISHOP1=      104;  --红士
 R_KING  =       105;  --红帅
 R_BISHOP2 =     106;  --红士
 R_ELEPHANT2 =   107;  --红象
 R_HORSE2 =      108;  --红马
 R_ROOK2   =     109 ;  --红车
 R_CANNON1 =     110;  --红炮
 R_CANNON2 =     111;  --红炮

 R_PAWN1     =   112;  --红卒
 R_PAWN2     =   113;  --红卒
 R_PAWN3     =   114;  --红卒
 R_PAWN4     =   115;  --红卒
 R_PAWN5     =   116;  --红卒
 R_BEGIN   =   R_ROOK1;
 R_END    =    R_PAWN5;

 CB_ROOK1   =     401 ;  --黑车
 CB_HORSE1 =      402;  --黑马
 CB_ELEPHANT1 =   403;  --黑象
 CB_BISHOP1=      404;  --黑士
 CB_KING  =       405;  --黑帅
 CB_BISHOP2 =     406;  --黑士
 CB_ELEPHANT2 =   407;  --黑象
 CB_HORSE2 =      408;  --黑马
 CB_ROOK2   =     409 ;  --黑车
 CB_CANNON1 =     410;  --黑炮
 CB_CANNON2 =     411;  --黑炮

 CB_PAWN1     =   412;  --黑卒
 CB_PAWN2     =   413;  --黑卒
 CB_PAWN3     =   414;  --黑卒
 CB_PAWN4     =   415;  --黑卒
 CB_PAWN5     =   416;  --黑卒

 CR_ROOK1   =     301 ;  --红车
 CR_HORSE1 =      302;  --红马
 CR_ELEPHANT1 =   303;  --红象
 CR_BISHOP1=      304;  --红士
 CR_KING  =       305;  --红帅
 CR_BISHOP2 =     306;  --红士
 CR_ELEPHANT2 =   307;  --红象
 CR_HORSE2 =      308;  --红马
 CR_ROOK2   =     309 ;  --红车
 CR_CANNON1 =     310;  --红炮
 CR_CANNON2 =     311;  --红炮

 CR_PAWN1     =   312;  --红卒
 CR_PAWN2     =   313;  --红卒
 CR_PAWN3     =   314;  --红卒
 CR_PAWN4     =   315;  --红卒
 CR_PAWN5     =   316;  --红卒

 chess_string2const = {

 ["B_ROOK1"]        =   B_ROOK1 ;  --黑车
 ["B_HORSE1"]       =   B_HORSE1;  --黑马
 ["B_ELEPHANT1"]    =   B_ELEPHANT1;  --黑象
 ["B_BISHOP1"]      =   B_BISHOP1;  --黑士
 ["B_KING"]         =   B_KING;  --黑帅
 ["B_BISHOP2"]      =   B_BISHOP2;  --黑士
 ["B_ELEPHANT2"]    =   B_ELEPHANT2;  --黑象
 ["B_HORSE2"]       =   B_HORSE2;  --黑马
 ["B_ROOK2"]        =   B_ROOK2 ;  --黑车
 ["B_CANNON1"]      =   B_CANNON1;  --黑炮
 ["B_CANNON2"]      =   B_CANNON2;  --黑炮

 ["B_PAWN1"]        =   B_PAWN1;  --黑卒
 ["B_PAWN2"]        =   B_PAWN2;  --黑卒
 ["B_PAWN3"]        =   B_PAWN3;  --黑卒
 ["B_PAWN4"]        =   B_PAWN4;  --黑卒
 ["B_PAWN5"]        =   B_PAWN5;  --黑卒

 ["R_ROOK1"]        =   R_ROOK1 ;  --红车
 ["R_HORSE1"]       =   R_HORSE1;  --红马
 ["R_ELEPHANT1"]    =   R_ELEPHANT1;  --红象
 ["R_BISHOP1"]      =   R_BISHOP1;  --红士
 ["R_KING"]         =   R_KING;  --红帅
 ["R_BISHOP2"]      =   R_BISHOP2;  --红士
 ["R_ELEPHANT2"]    =   R_ELEPHANT2;  --红象
 ["R_HORSE2"]       =   R_HORSE2;  --红马
 ["R_ROOK2"]        =   R_ROOK2 ;  --红车
 ["R_CANNON1"]      =   R_CANNON1;  --红炮
 ["R_CANNON2"]      =   R_CANNON2;  --红炮

 ["R_PAWN1"]        =   R_PAWN1;  --红卒
 ["R_PAWN2"]        =   R_PAWN2;  --红卒
 ["R_PAWN3"]        =   R_PAWN3;  --红卒
 ["R_PAWN4"]        =   R_PAWN4;  --红卒
 ["R_PAWN5"]        =   R_PAWN5;  --红卒

 }

 drawable_resource_id = {

 [B_ROOK1]  =      "brook" ;  --黑车
 [B_HORSE1] =      "bhorse";  --黑马
 [B_ELEPHANT1] =   "belephant";  --黑象
 [B_BISHOP1]=      "bbishop";  --黑士
 [B_KING]  =       "bking";  --黑帅
 [B_BISHOP2] =     "bbishop";  --黑士
 [B_ELEPHANT2] =   "belephant";  --黑象
 [B_HORSE2] =      "bhorse";  --黑马
 [B_ROOK2]   =     "brook" ;  --黑车
 [B_CANNON1] =     "bcannon";  --黑炮
 [B_CANNON2] =     "bcannon";  --黑炮

 [B_PAWN1]     =   "bpawn";  --黑卒
 [B_PAWN2]     =   "bpawn";  --黑卒
 [B_PAWN3]     =   "bpawn";  --黑卒
 [B_PAWN4]     =   "bpawn";  --黑卒
 [B_PAWN5]     =   "bpawn";  --黑卒


 [R_ROOK1]   =     "rrook";  --红车
 [R_HORSE1] =      "rhorse";  --红马
 [R_ELEPHANT1] =   "relephant";  --红象
 [R_BISHOP1]=      "rbishop";  --红士
 [R_KING] =        "rking";  --红帅
 [R_BISHOP2] =     "rbishop";  --红士
 [R_ELEPHANT2] =   "relephant";  --红象
 [R_HORSE2] =      "rhorse";  --红马
 [R_ROOK2]   =     "rrook";  --红车
 [R_CANNON1] =     "rcannon";  --红炮
 [R_CANNON2] =     "rcannon";  --红炮

 [R_PAWN1]     =   "rpawn";  --红卒
 [R_PAWN2]    =    "rpawn";  --红卒
 [R_PAWN3]     =   "rpawn";  --红卒
 [R_PAWN4]     =   "rpawn";  --红卒
 [R_PAWN5]     =   "rpawn";  --红卒

}

drawable_choose_resource_id = 
{
 [CB_ROOK1]  =      "cbrook" ;  --黑车
 [CB_HORSE1] =      "cbhorse";  --黑马
 [CB_ELEPHANT1] =   "cbelephant";  --黑象
 [CB_BISHOP1]=      "cbbishop";  --黑士
 [CB_KING]  =       "cbking";  --黑帅
 [CB_BISHOP2] =     "cbbishop";  --黑士
 [CB_ELEPHANT2] =   "cbelephant";  --黑象
 [CB_HORSE2] =      "cbhorse";  --黑马
 [CB_ROOK2]   =     "cbrook" ;  --黑车
 [CB_CANNON1] =     "cbcannon";  --黑炮
 [CB_CANNON2] =     "cbcannon";  --黑炮

 [CB_PAWN1]     =   "cbpawn";  --黑卒
 [CB_PAWN2]     =   "cbpawn";  --黑卒
 [CB_PAWN3]     =   "cbpawn";  --黑卒
 [CB_PAWN4]     =   "cbpawn";  --黑卒
 [CB_PAWN5]     =   "cbpawn";  --黑卒


 [CR_ROOK1]   =     "crrook";  --红车
 [CR_HORSE1] =      "crhorse";  --红马
 [CR_ELEPHANT1] =   "crelephant";  --红象
 [CR_BISHOP1]=      "crbishop";  --红士
 [CR_KING] =        "crking";  --红帅
 [CR_BISHOP2] =     "crbishop";  --红士
 [CR_ELEPHANT2] =   "crelephant";  --红象
 [CR_HORSE2] =      "crhorse";  --红马
 [CR_ROOK2]   =     "crrook";  --红车
 [CR_CANNON1] =     "crcannon";  --红炮
 [CR_CANNON2] =     "crcannon";  --红炮

 [CR_PAWN1]     =   "crpawn";  --红卒
 [CR_PAWN2]    =    "crpawn";  --红卒
 [CR_PAWN3]     =   "crpawn";  --红卒
 [CR_PAWN4]     =   "crpawn";  --红卒
 [CR_PAWN5]     =   "crpawn";  --红卒 
}


red_down_game = {
					{B_ROOK1,  B_HORSE1,  B_ELEPHANT1, B_BISHOP1, B_KING,   B_BISHOP2, B_ELEPHANT2, B_HORSE2,  B_ROOK2},
					{NOCHESS,  NOCHESS,   NOCHESS,     NOCHESS,   NOCHESS,  NOCHESS,   NOCHESS,     NOCHESS,   NOCHESS},
					{NOCHESS,  B_CANNON1, NOCHESS,     NOCHESS,   NOCHESS,  NOCHESS,   NOCHESS,     B_CANNON2, NOCHESS},
					{B_PAWN1,  NOCHESS,   B_PAWN2,     NOCHESS,   B_PAWN3,  NOCHESS,   B_PAWN4,     NOCHESS,   B_PAWN5},
					{NOCHESS,  NOCHESS,   NOCHESS,     NOCHESS,   NOCHESS,  NOCHESS,   NOCHESS,     NOCHESS,   NOCHESS},
					
					{NOCHESS,  NOCHESS,   NOCHESS,     NOCHESS,   NOCHESS,  NOCHESS,   NOCHESS,     NOCHESS,   NOCHESS},
					{R_PAWN1,  NOCHESS,   R_PAWN2,     NOCHESS,   R_PAWN3,  NOCHESS,   R_PAWN4,     NOCHESS,   R_PAWN5},
					{NOCHESS,  R_CANNON1, NOCHESS,     NOCHESS,   NOCHESS,  NOCHESS,   NOCHESS,     R_CANNON2, NOCHESS},
					{NOCHESS,  NOCHESS,   NOCHESS,     NOCHESS,   NOCHESS,  NOCHESS,   NOCHESS,     NOCHESS,   NOCHESS},
					{R_ROOK1,  R_HORSE1,  R_ELEPHANT1, R_BISHOP1, R_KING,   R_BISHOP2, R_ELEPHANT2, R_HORSE2,  R_ROOK2}
				};


red_down_game90 = {
					B_ROOK2,  B_HORSE2,  B_ELEPHANT2, B_BISHOP2, B_KING,   B_BISHOP1, B_ELEPHANT1, B_HORSE1,  B_ROOK1,
					NOCHESS,  NOCHESS,   NOCHESS,     NOCHESS,   NOCHESS,  NOCHESS,   NOCHESS,     NOCHESS,   NOCHESS,
					NOCHESS,  B_CANNON2, NOCHESS,     NOCHESS,   NOCHESS,  NOCHESS,   NOCHESS,     B_CANNON1, NOCHESS,
					B_PAWN5,  NOCHESS,   B_PAWN4,     NOCHESS,   B_PAWN3,  NOCHESS,   B_PAWN2,     NOCHESS,   B_PAWN1,
					NOCHESS,  NOCHESS,   NOCHESS,     NOCHESS,   NOCHESS,  NOCHESS,   NOCHESS,     NOCHESS,   NOCHESS,
					
					NOCHESS,  NOCHESS,   NOCHESS,     NOCHESS,   NOCHESS,  NOCHESS,   NOCHESS,     NOCHESS,   NOCHESS,
					R_PAWN5,  NOCHESS,   R_PAWN4,     NOCHESS,   R_PAWN3,  NOCHESS,   R_PAWN2,     NOCHESS,   R_PAWN1,
					NOCHESS,  R_CANNON2, NOCHESS,     NOCHESS,   NOCHESS,  NOCHESS,   NOCHESS,     R_CANNON1, NOCHESS,
					NOCHESS,  NOCHESS,   NOCHESS,     NOCHESS,   NOCHESS,  NOCHESS,   NOCHESS,     NOCHESS,   NOCHESS,
					R_ROOK2,  R_HORSE2,  R_ELEPHANT2, R_BISHOP2, R_KING,   R_BISHOP1, R_ELEPHANT1, R_HORSE1,  R_ROOK1
				};

piece_resource_id = {
	[8] = "rking";  --红帅
	[9] = "rbishop";  --红士
	[10] = "relephant";  --红象
	[11] = "rhorse";  --红马
	[12] = "rrook";  --红车
	[13] = "rcannon";  --红炮
	[14] = "rpawn";  --红卒

    [16] = "bking";  --黑帅
	[17] = "bbishop";  --黑士
	[18] = "belephant";  --黑象
	[19] = "bhorse";  --黑马
	[20] = "brook";  --黑车
	[21] = "bcannon";  --黑炮
	[22] = "bpawn";  --黑卒
}



piece_id_num = {
	[8] = 1;  --红帅
	[9] = 2;  --红士
	[10] = 2;  --红象
	[11] = 2;  --红马
	[12] = 2;  --红车
	[13] = 2;  --红炮
	[14] = 5;  --红卒

    [16] = 1;  --黑帅
	[17] = 2;  --黑士
	[18] = 2;  --黑象
	[19] = 2;  --黑马
	[20] = 2;  --黑车
	[21] = 2;  --黑炮
	[22] = 5;  --黑卒
}


fen_piece = {
		
	["K"] = {R_KING,["index"] = 0};
	["A"] = {R_BISHOP1,R_BISHOP2,["index"] = 0};
	["B"] = {R_ELEPHANT1,R_ELEPHANT2,["index"] = 0};
	["E"] = {R_ELEPHANT1,R_ELEPHANT2,["index"] = 0};
	["H"] = {R_HORSE1,R_HORSE2,["index"] = 0};
	["N"] = {R_HORSE1,R_HORSE2,["index"] = 0};
	["R"] = {R_ROOK1,R_ROOK2,["index"] = 0};
	["C"] = {R_CANNON1,R_CANNON2,["index"] = 0};
	["P"] = {R_PAWN1,R_PAWN2,R_PAWN3,R_PAWN4,R_PAWN5,["index"] = 0};

	["k"] = {B_KING,["index"] = 0};
	["a"] = {B_BISHOP1,B_BISHOP2,["index"] = 0};
	["b"] = {B_ELEPHANT1,B_ELEPHANT2,["index"] = 0};
	["e"] = {B_ELEPHANT1,B_ELEPHANT2,["index"] = 0};
	["h"] = {B_HORSE1,B_HORSE2,["index"] = 0};
	["n"] = {B_HORSE1,B_HORSE2,["index"] = 0};
	["r"] = {B_ROOK1,B_ROOK2,["index"] = 0};
	["c"] = {B_CANNON1,B_CANNON2,["index"] = 0};
	["p"] = {B_PAWN1,B_PAWN2,B_PAWN3,B_PAWN4,B_PAWN5,["index"] = 0};
}