
------------------------------------- hall cmd -----------------------------------

SERVER_OFFLINE = -1;				--断线 
SERVER_OFFLINE_RECONNECT = -2;		--断线重连
SERVER_OFFLINE_RECONNECTED = -3;	--断线重连成功

HALL_MSG_HEART           =    0x6FFF;     --心跳包

--HALL_MSG_LOGIN           =    0x0001;     --用户登陆(游戏大厅)
HALL_MSG_LOGIN           =    0x2001;     --用户登陆(游戏大厅)
HALL_MSG_LOGOUT          =    0x0002;     --用户注销（游戏大厅）
--HALL_MSG_GAMEINFO        =    0x0003;     --获取游戏信息（IP 和 端口）
HALL_MSG_GAMEINFO        =    0x2004;     --获取游戏信息（IP 和 端口）
HALL_MSG_USER            =    0x0004;     --获取用户信息（暂时没用）
--HALL_MSG_GAMEPLAY        =    0x0005;     --获取各游戏场人数
HALL_MSG_GAMEPLAY        =    0x2003;     --获取各游戏场人数
HALL_MSG_SETONLINE       =    0x0006;     --用户设置在线状态
HALL_MSG_QUICKSTART      =    0x0007;     --快速开始
HALL_MSG_CANCELMATCH     =    0x0008;     --取消匹配
--HALL_MSG_KICKUSER        =    0x0031;     --服务端踢出用户
HALL_MSG_KICKUSER        =    0x2002;     --服务端踢出用户
HALL_MSG_GETROOMS	     =    0x0021;     --获取自定义房间列表
HALL_MSG_CREATEROOM	     =    0x0501;     --创建自定义房间	
HALL_MSG_SEARCHROOM	     =    0x0023;     --查找自定义房间		

HALL_MSG_SERVER_PUSH 	 =    0x0075;     --购买成功推送给用户
HALL_MSG_RESPONSE_SERVER =    0x0076;     --发货成功通知sever


CLIENT_MSG_RELOGIN       =    0x011A;     --客户端断线重连接
CLIENT_MSG_GIVEUP        =    0x0109;	  --玩家重登陆，放弃已有棋局


------------------------------------ new hall cmd ----------------

CLIENT_HALL_PRIVATEROOM_LIST = 0x2005;
CLIENT_HALL_CREATE_PRIVATEROOM = 0x2006;
CLIENT_HALL_JOIN_PRIVATEROOM = 0x2007;
CLIENT_HALL_BROADCAST_MGS = 0x2008;
CLIENT_HALL_CANCEL_MATCH = 0x2009;
CLIENT_ALLOC_PRIVATEROOMNUM = 0x200B;
FRIEND_CMD_GET_PLAYER_INFO = 0x380E;

------------------------------------- room cmd -----------------------------------

--CUSTOMROOM_MSG_ENTER     =    0x0503;    --进入自定义房间
CUSTOMROOM_MSG_LOGIN_ENTER  =  0x0133;    --登陆并进入自定义房间

--CLIENT_MSG_LOGIN		 =	  0x0100; 	    --客户端登陆
CLIENT_MSG_LOGIN		 =	  0x0501; 	    --客户端登陆
SERVER_MSG_LOGIN_SUCCESS =    0x0520        --客户端登陆成功，先登录的玩家没有对家信息，需要从SERVER_MSG_OPP_USER_INFO命令获取。
SERVER_MSG_LOGIN_ERROR   =    0x0521        --登陆服务器错误
SERVER_MSG_OTHER_ERROR   =    0x0522        --其他登陆错误
SERVER_MSG_LOGOUT_SUCCESS=    0x0524        --退出房间成功
SERVER_MSG_LOGOUT_FAIL   =    0x0525        --退出房间失败
SERVER_MSG_RECONNECT     =    0x0526        --断线重连
SERVER_MSG_OPP_USER_INFO =    0x0550        --返回对手信息
SERVER_MSG_USER_LEAVE    =    0x0551        --广播玩家离开
SERVER_MSG_USER_READY    =    0x0552        --客户端准备
SERVER_MSG_GAME_START    =    0x0553        --游戏准备开始
SERVER_MSG_FORESTALL     =    0x0554        --游戏抢先开始
SERVER_MSG_FORESTALL_NEW =    0x055B        --游戏抢先（新）（读写）
SERVER_MSG_HANDICAP      =    0x0555        --游戏让子开始
SERVER_MSG_HANDICAP_RESULT =  0x0557        --游戏让子结果推送
SERVER_MSG_TIMECOUNT_START =  0x0556        --游戏正式计时开始

CLIENT_MSG_LOGOUT        =    0x0502        --玩家请求退出
CLIENT_MSG_READY         =    0x0503;       --房间内再来一局，客户端主动发送准备请求，会收到SERVER_MSG_USER_READY消息。
CLIENT_MSG_OFFLINE       =    0x0504;       --玩家强制掉线

CLIENT_CMD_GETTABLESTEP  =    0x0506        --拉取棋局走法


--观战
CLIENT_WATCH_LIST        =    0x3703;       --获取观战信息列表
CLIENT_WATCH_JOIN        =    0x3704;       --客户端登录观战房间
CLIENT_WATCH_LOGOUT      =    0x3705;       --客户端离开
CLIENT_WATCH_CHAT        =    0x3706;       --客户端聊天
SERVER_WATCH_ERROR       =    0x3707;       --server广播观战错误
SERVER_WATCH_ALLREADY    =    0x3520;       --所有玩家准备
SERVER_WATCH_START       =    0x3521;       --server广播观战开始
SERVER_WATCH_MOVE        =    0x3522;       --server广播走棋
SERVER_WATCH_DRAW        =    0x3524;       --server广播求和
SERVER_WATCH_SURRENDER   =    0x3525;       --server广播认输
SERVER_WATCH_UNDO        =    0x3526;       --server广播悔棋
SERVER_WATCH_USERLEAVE   =    0x3527;       --server广播棋手离开
SERVER_WATCH_GAMEOVER    =    0x3528;       --server广播观战结束





CLIENT_MSG_COMEIN		 =    0x0101; 	    --客户端进入棋桌
CLIENT_MSG_LEAVE		 =	  0x0102; 	    --客户端离开棋桌
CLIENT_MSG_START         =    0x0103;	    --申请开局
--SERVER_MSG_GAME_START    =    0x0104;		--游戏开始通知
SERVER_MSG_GAME_CLOSE    =    0x0105;		--游戏关闭通知
CLIENT_MSG_MOVE		     =	  0x0106;		--走棋

SERVER_MSG_GAME_RESTART  =    0x0107;		--游戏重新开局
CLIENT_MSG_CHAT          =    0x0108;		--聊天
CLIENT_MSG_GIVEUP        =    0x0109;	    --玩家重登陆，放弃已有棋局

CLIENT_MSG_DRAW1         =    0x0110;		--和棋申请
CLIENT_MSG_DRAW2         =    0x0111;	    --和棋通知
SERVER_MSG_DRAW          =    0x0112;	    --和棋结果推送

CLIENT_MSG_SURRENDER1    =    0x0113;		--投降申请
CLIENT_MSG_SURRENDER2    =    0x0114;		--投降通知
SERVER_MSG_SURRENDER     =    0x0115;		--投降结果推送

CLIENT_MSG_UNDOMOVE      =    0x0116;	    --悔棋
SET_TIME_INFO            =    0x0117;    --设置局时，步时，读秒
SERVER_MSG_WARING        =    0x0118 ;    --服务器提醒(超时)
CLIENT_MSG_SYNCHRODATA   =    0x0119;     --数据同步
CLIENT_MSG_RELOGIN       =    0x011A;     --客户端断线重连接
CLIENT_MSG_HOMEPRESS     =    0x011B;     --客户端发送主动home消息
CLIENT_MSG_WATCH_CHAT    =    0x011C;     --观战人员的聊天信息推送
CLIENT_MSG_WATCH_LOGIN   =    0x011D;     --观战人员登录信息推送
CLIENT_MSG_WATCH_LEAVE   =    0x011E;     --观战人员登录信息推送

CLIENT_MSG_WATCHLIST     =    0x0120      --获取当前观战用户信息列表
SERVER_MSG_TIPS          =    0x0124      --服务器推送消息
CLIENT_MSG_FORESTALL     =    0x0125      --_1：抢先提醒（服务器推送） 0x0125_2：抢先应答
CLIENT_MSG_HANDICAP      =    0x0126      --_1：抢先提醒（服务器推送） 0x0125_2：抢先应答

CLIENT_MSG_ROOMINFO	     =    0x0201;    --取房间信息
CLIENT_MSG_HEART	     =    0x0202;    --心跳

CLIENT_WATCH_LOGIN       =    0x0301 ;    --客户端观战登陆，进入游戏房间
CLIENT_WATCH_SYNCHRODATA =    0x0302 ;    --获取当前棋面信息
--CLIENT_WATCH_LOGOUT      =    0x0304 ;    --客户端离开
--CLIENT_WATCH_CHAT        =    0x0305 ;    --客户端聊天
CLIENT_WATCH_TRENDS      =    0x0306 ;    --服务器推关棋局战况
CLIENT_WATCH_USERLIST    =    0x0307 ;    --获取当前观战用户信息列表

--观战subcmd
WATCH_SUB_LOGIN		     =	  0x0100; 		--观战者登陆
WATCH_SUB_LEAVE		 	 =    0x0101; 		--观战者离开棋桌
WATCH_MSG_LEAVE		     =	  0x0102; 		--棋手离开棋桌
WATCH_MSG_READY          =    0x0103;	    --棋手准备开始通知
WATCH_MSG_GAME_START     =    0x0104;		-- 游戏开始通知
WATCH_MSG_GAME_CLOSE     =    0x0105;		-- 游戏关闭通知
WATCH_MSG_MOVE		     =	  0x0106;		-- 走棋
WATCH_SUB_CHAT           =    0x0107;		-- 观战者聊天信息
WATCH_MSG_CHAT           =    0x0108;		-- 棋手聊天信息
WATCH_MSG_DRAW           =    0x0112;	    --和棋结果推送
WATCH_MSG_SURRENDER      =    0x0115;	    --投降结果推送
WATCH_MSG_UNDOMOVE       =    0x0116;	   	--悔棋
WATCH_MSG_WARING         =    0x0118 ;      --服务器提醒(超时)



CLIENT_WATCH_BET         =    0x0309 ;    --观战者押注

CLIENT_WATCH_HEART       =    0x0310 ;    --服务器推关棋局战况

CLIENT_GET_OPENBOX_TIME  = 	  0x0127;	--获取在线时长宝箱

SEVER_MSG_BONUS_CHESS_SOUL =  0x0128;  --坊间内获得棋魂奖励 的推送

SERVER_CMD_KICK_PLAYER              = 0x0507;            --私人房踢人
SERVER_CMD_ROOM_KICK_OUT_USER       = 0x0527;            --私人房被踢
SERVER_CMD_ROOM_KICK_OUT_ERROR      = 0x0528;            --私人房踢人失败返回
CLIENT_CMD_CALLTELPHONE             = 0x0508;            --客户端通知打或者接电话中
CLIENT_CMD_CALLTELPHONERESPONSE     = 0x0509;            --server返回 对方打或接电话中
CLIENT_CMD_CALLTELPHONEBACK         = 0x050A;            --server返回 对方返回

SERVER_BROADCAST_USER_DISCONNECT    = 0x055C;           -- server返回，广播玩家断线信息，给其他玩家
SERVER_BROADCAST_USER_RECONNECT     = 0x055D;           -- server返回，广播玩家重连信息，给其他玩家
------------------- friends cmd -----------------

FRIEND_CMD_ONLINE_NUM               = 0x3803; -- 查下在线好友数目
FRIEND_CMD_CHECK_USER_STATUS        = 0x3805; -- 查询好友状态
FRIEND_CMD_CHECK_USER_DATA          = 0x3806; -- 查询用户数据

FRIEND_CMD_GET_FRIENDS_NUM          = 0x3807; -- 获取好友数目
FRIEND_CMD_GET_FOLLOW_NUM           = 0x3809; -- 获取关注数目
FRIEND_CMD_GET_FANS_NUM             = 0x380B; -- 获取粉丝数目

FRIEND_CMD_GET_FRIENDS_LIST         = 0x3808; -- 获取好友列表
FRIEND_CMD_GET_FOLLOW_LIST          = 0x380A; -- 获取关注列表
FRIEND_CMD_GET_FANS_LIST            = 0x380C; -- 获取粉丝列表

FRIEND_CMD_GET_UNREAD_MSG           = 0x3820; -- 主动拉取未接收消息
FRIEND_CMD_RECV_MSG_CHECK           = 0x3821; -- 确认未接受消息
FRIEND_CMD_CHAT_MSG                 = 0x3822; -- 发送好友消息
FRIEND_CMD_CHAT_MSG2                = 0x3823; -- 发送好友消息(2.0.5之后使用)

FRIEND_CMD_ADD_FLLOW                = 0x380D; --关注好友
FRIEND_CMD_SCORE_RANK               = 0x3830; --好友排行榜
FRIEND_CMD_CHECK_PLAYER_RANK        = 0x3832; --查询单个用户的好友榜排名


--好友挑战
CLIENT_HALL_CREATE_FRIENDROOM = 0x200A;     --创建挑战房（读写）
FRIEND_CMD_FRIEND_INVITE_REQUEST = 0x3840;  --发起挑战请求（读写）
FRIEND_CMD_FRIEND_INVIT_NOTIFY = 0x3841;    --挑战邀请通知（读）
FRIEND_CMD_FRIEND_INVIT_RESPONSE = 0x3842;    --挑战邀请回复（读写）
FRIEND_CMD_FRIEND_INVIT_RESPONSE2 = 0x3844;    --挑战邀请回复（读写）(2.0.5)
CLIIENT_CMD_RESET_TABLE = 0x505;            --重置房间状态(读写)    

--局时设置
SERVER_BROADCAST_SET_TIME = 0x558;          --设置时间（读写）
SERVER_BROADCAST_SET_TIME_NOTIFY = 0x559;   --服务器通知设置时间结果（读）
SERVER_BROADCAST_SET_TIME_RESPONSE = 0x55A; --是否同意设置时间结果（读写）

--好友观战
--TABLE_STATUS_STOP = 1,        桌子停止状态，即没有任何状态
--TABLE_STATUS_PLAYING = 2,     桌子在玩状态
--TABLE_STATUS_QIANGXIAN = 3,   抢先状态
--TABLE_STATUS_RANGZI = 4,      让子状态
--TABLE_STATUS_SET_TIME = 5,    设置局时状态
--TABLE_STATUS_SET_TIME_WAIT_RESPONSE = 6   等待回复局时状态
OB_CMD_LOGIN_SUCCESS = 0x570;               --观战登陆成功
OB_CMD_CHAT_MSG = 0x571;                    --观战聊天（读写）
OB_CMD_GET_TABLE_INFO = 0x572;              --获取桌子信息(读写)
OB_CMD_GET_OB_LIST = 0x573;                 --获取观战列表（读写）
OB_CMD_PLAYER_ENTER = 0x574;                --广播玩家进入（读）
OB_CMD_PLAYER_LEAVE = 0x575;                --广播玩家离开(读)
OB_CMD_UPDATE_TABLE_STATUS = 0x576;         --同步更新桌子状态（读）
OB_CMD_GAMESTART = 0x577;                   --游戏开始（读） 
OB_CMD_CHESS_MOVE = 0x578;                  --广播走棋（读）
OB_CMD_CHESS_UNDOMOVE = 0x579;              --悔棋（读）
OB_CMD_CHESS_DRAW = 0x57A;                  --求和（读）
OB_CMD_CHESS_SURRENDER = 0x57B;             --认输（读）
OB_CMD_GAMEOVER = 0x57C;                    --游戏结束（读）
OB_CMD_GET_NUM = 0x57D;                     --观战人数（读写）

FRIEND_CMD_GET_FRIEND_OB_LIST = 0x3843;     --获得棋友观战列表（读写）


------------------- prop -------------------
PROP_CMD_UPDATE_USERDATA = 0x3862;  -- 修改
PROP_CMD_QUERY_USERDATA  = 0x3861;  -- 查询
PROP_CMD_CREATE_USERDATA = 0x3860;  -- 增

------------------- broadcast cmd ---------------
BROADCAST_GOLD           =    0x1001    --金币到账
BROADCAST_PROP           =    0x1002    --道具到账
BROADCAST_NEWS           =    0x1003    --新的消息
BROADCAST_ADS            =    0x1004    --广告状态
BROADCAST_VIP            =    0x1005    --VIP到账
BROADCAST_NOTICE         =    0x1006    --公告
BROADCAST_USERINFO       =    0x1007    --用户数据到账
------------------- chatroom cmd --------------------
CHATROOM_CMD_ENTER_ROOM               =     0x3903         -- 进入聊天室请求（读写）
CHATROOM_CMD_LEAVE_ROOM               =     0x3904         -- 离开聊天室请求（读写）
CHATROOM_CMD_GET_UNREAD_MSG           =     0x3905         -- 获得聊天室未读消息数量1（读写）
CHATROOM_CMD_USER_CHAT_MSG            =     0x3906         -- 用户发送聊天信息（读写）
CHATROOM_CMD_BROAdCAST_CHAT_MSG       =     0x3907         -- 广播用户聊天消息（读写）
CHATROOM_CMD_GET_HISTORY_MSG          =     0x3908         -- 历史消息记录（读写）
CHATROOM_CMD_GET_UNREAD_MSG2          =     0x3909         -- 获得聊天室未读消息数量2（读写）  
CHATROOM_CMD_GET_MEMBER_LIST          =     0x390A         -- 获得聊天室成员列表


------------------ network type --------------------

CLIENT_HALL_NET_DATA_REPORT           =     0x2FFE         -- 上传网络类型