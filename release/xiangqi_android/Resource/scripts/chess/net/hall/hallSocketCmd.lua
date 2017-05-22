
------------------------------------- hall cmd -----------------------------------

SERVER_OFFLINE = -1;				--断线 
SERVER_OFFLINE_RECONNECT = -2;		--断线重连
SERVER_OFFLINE_RECONNECTED = -3;	--断线重连成功

HALL_MSG_HEART           =    0x6FFF;     --心跳包

HALL_MSG_LOGIN           =    0x2001;     --用户登陆(游戏大厅)
HALL_MSG_GAMEINFO        =    0x2004;     --获取游戏信息（IP 和 端口）
HALL_MSG_GAMEPLAY        =    0x2003;     --获取各游戏场人数
HALL_MSG_PRIVATE_ROOM_PLAY_NUM = 0x2514;  --获取私人房的当前在线总人数
HALL_MSG_ALL_PLAY_NUM    =    0x3000;     --获取联网 单机 比赛人数
HALL_MSG_KICKUSER        =    0x2002;     --服务端踢出用户

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
--CUSTOMROOM_MSG_LOGIN_ENTER  =  0x0133;    --登陆并进入自定义房间

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
SERVER_MSG_FORESTALL_320 =    0x0560        -- 3.2.0 抢先
SERVER_MSG_HANDICAP      =    0x0555        --游戏让子开始
SERVER_MSG_HANDICAP_RESULT =  0x0557        --游戏让子结果推送
SERVER_MSG_HANDICAP_AGREE_RESULT  = 0x563        -- 让子同意结果推送
SERVER_MSG_TIMECOUNT_START =  0x0556        --游戏正式计时开始
SERVER_MSG_HANDICAP_CONFIRM = 0x0561        -- read 广播让子信息 write  客户端回复用户是否同意让子
SERVER_MSG_GAME_START_INFO  = 0x562        -- 广播开局信息


CLIENT_MSG_LOGOUT        =    0x0502        --玩家请求退出
CLIENT_MSG_READY         =    0x0503;       --房间内再来一局，客户端主动发送准备请求，会收到SERVER_MSG_USER_READY消息。
CLIENT_MSG_OFFLINE       =    0x0504;       --玩家强制掉线

CLIENT_CMD_GETTABLESTEP  =    0x0506        --拉取棋局走法
CLIENT_GET_CUR_TID_START_TIME =  0x050C     --获取当前棋局开始时间

--观战
CLIENT_WATCH_LIST        =    0x3703;       --获取观战信息列表
CLIENT_WATCH_JOIN        =    0x3704;       --客户端登录观战房间
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

SERVER_MSG_GAME_CLOSE    =    0x0105;		--游戏关闭通知
CLIENT_MSG_MOVE		     =	  0x0106;		--走棋

CLIENT_MSG_CHAT          =    0x0108;		--聊天

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
CLIENT_MSG_WATCH_CHAT    =    0x011C;     --观战人员的聊天信息推送
CLIENT_MSG_WATCH_LOGIN   =    0x011D;     --观战人员登录信息推送
CLIENT_MSG_WATCH_LEAVE   =    0x011E;     --观战人员登录信息推送

CLIENT_MSG_WATCHLIST     =    0x0120      --获取当前观战用户信息列表
SERVER_MSG_TIPS          =    0x0124      --服务器推送消息
CLIENT_MSG_FORESTALL     =    0x0125      --_1：抢先提醒（服务器推送） 0x0125_2：抢先应答
CLIENT_MSG_HANDICAP      =    0x0126      --_1：抢先提醒（服务器推送） 0x0125_2：抢先应答

CLIENT_WATCH_BET         =    0x0309 ;    --观战者押注
CLIENT_WATCH_HEART       =    0x0310 ;    --服务器推关棋局战况
CLIENT_GET_OPENBOX_TIME  = 	  0x0127;	--获取在线时长宝箱

SERVER_CMD_KICK_PLAYER              = 0x0507;            --私人房踢人
SERVER_CMD_ROOM_KICK_OUT_USER       = 0x0527;            --私人房被踢
SERVER_CMD_ROOM_KICK_OUT_ERROR      = 0x0528;            --私人房踢人失败返回
CLIENT_ALLOC_GET_PRIVATEROOM_INFO   = 0x200C;            --私人房向服务器请求房间tid和pwd

CLIENT_CMD_FORBID_USER_MSG          = 0x050B;           -- 联网对战屏蔽玩家聊天信息

SERVER_BROADCAST_USER_DISCONNECT    = 0x055C;           -- server返回，广播玩家断线信息，给其他玩家
SERVER_BROADCAST_USER_RECONNECT     = 0x055D;           -- server返回，广播玩家重连信息，给其他玩家
------------------- friends cmd -----------------

FRIEND_CMD_ONLINE_NUM               = 0x3803; -- 查下在线好友数目
FRIEND_CMD_CHECK_USER_STATUS        = 0x3810; -- 查询好友状态
FRIEND_CMD_CHECK_USER_DATA          = 0x3806; -- 查询用户数据

FRIEND_CMD_GET_FRIENDS_NUM          = 0x3807; -- 获取好友数目
FRIEND_CMD_GET_FOLLOW_NUM           = 0x3809; -- 获取关注数目
FRIEND_CMD_GET_FANS_NUM             = 0x380B; -- 获取粉丝数目

FRIEND_CMD_GET_FRIENDS_LIST         = 0x3808; -- 获取好友列表
FRIEND_CMD_GET_FOLLOW_LIST          = 0x380A; -- 获取关注列表
FRIEND_CMD_GET_FANS_LIST            = 0x380C; -- 获取粉丝列表
FRIEND_CMD_GET_FRIEND_FOLLOW_LIST   = 0x3812; -- 同时拉取好友和关注列表

FRIEND_CMD_GET_UNREAD_MSG           = 0x3820; -- 主动拉取未接收消息
FRIEND_CMD_RECV_MSG_CHECK           = 0x3821; -- 确认未接受消息
FRIEND_CMD_CHAT_MSG                 = 0x3822; -- 发送好友消息
FRIEND_CMD_CHAT_MSG2                = 0x3823; -- 发送好友消息(2.0.5之后使用)

FRIEND_CMD_ADD_FLLOW                = 0x380D; --关注好友
FRIEND_CMD_SCORE_RANK               = 0x3830; --好友排行榜
FRIEND_CMD_CHECK_PLAYER_RANK        = 0x3832; --查询单个用户的好友榜排名


--好友挑战
CLIENT_HALL_CREATE_FRIENDROOM       = 0x200A; --创建挑战房（读写）
FRIEND_CMD_FRIEND_INVITE_REQUEST    = 0x3845; --发起挑战请求（读写）
FRIEND_CMD_FRIEND_INVIT_NOTIFY      = 0x3841; --挑战邀请通知（读）
FRIEND_CMD_FRIEND_INVIT_RESPONSE    = 0x3842; --挑战邀请回复（读写）
FRIEND_CMD_FRIEND_INVIT_RESPONSE2   = 0x3844; --挑战邀请回复（读写）(2.0.5)
CLIIENT_CMD_RESET_TABLE             = 0x505;  --重置房间状态(读写)    

--聊天室私人房挑战邀请
FRIEND_CMD_GET_USER_STATUS          = 0x380F; --聊天室用户是否在线
STRANGER_CMD_INVITE_REQUEST         = 0x3846; --聊天室用户发起挑战 
STRANGER_CMD_INVIT_RESPONSE         = 0x3847; --被挑战者发送挑战状态(是否同意)，挑战者接收挑战状态
STRANGER_CMD_INVIT_NOTIFY           = 0x3848; --被挑战者接收server的通知

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
OB_CMD_GET_HISTORY_MSGS = 0x57F;            --观战历史聊天（读写）

FRIEND_CMD_GET_FRIEND_OB_LIST = 0x3843;     --获得我的关注观战列表（读写）
OB_CMD_GET_CHARM_OB_LIST = 0x3849;     --获得魅力榜观战列表（读写）

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
BROADCAST_MSGS           =    0x1008    --小喇叭消息
BROADCAST_SOCIATYMSG     =    0x1009    --棋社消息推送
BROADCAST_TASK_COMPLETE  =    0x1010    --任务完成推送
BROADCAST_SOCIATY_NOTICE =    0x39E0    --棋社聊天室广播
------------------- chatroom cmd --------------------
CHATROOM_CMD_ENTER_ROOM               =     0x3903         -- 进入聊天室请求（读写）
CHATROOM_CMD_LEAVE_ROOM               =     0x3904         -- 离开聊天室请求（读写）
CHATROOM_CMD_GET_UNREAD_MSG           =     0x3905         -- 获得聊天室未读消息数量1（读写）
CHATROOM_CMD_USER_CHAT_MSG            =     0x3906         -- 用户发送聊天信息（读写）
CHATROOM_CMD_BROAdCAST_CHAT_MSG       =     0x3907         -- 广播用户聊天消息（读写）
CHATROOM_CMD_GET_HISTORY_MSG          =     0x3908         -- 历史消息记录（读写）
CHATROOM_CMD_GET_UNREAD_MSG2          =     0x3909         -- 获得聊天室未读消息数量2（读写）  
CHATROOM_CMD_GET_MEMBER_LIST          =     0x390A         -- 获得聊天室成员列表
CHATROOM_CMD_IS_ACT_AVALIABLE         =     0x3930         -- 聊天室动作是否可行
CHATROOM_CMD_UPDATE_CHATROOM_ITEM     =     0x390B         -- 更新聊天室item
CHATROOM_CMD_GET_HISTORY_MSG_NEW      =     0x390C         -- 历史消息记录新（3.0.0及以上）
CHATROOM_CMD_GET_CHESS_MATCH_MSG      =     0x3931         -- 获取约战消息
CHATROOM_CMD_GET_CHESS_MATCH_MSG_NUM  =     0x3932         -- 获取约战消息总数


------------------ network type --------------------

CLIENT_HALL_NET_DATA_REPORT           =     0x2FFE         -- 上传网络类型

------------------ gift cmd -------------------

CLIIENT_CMD_GIVEGIFT = 0x508 -- 玩家送礼物（读写）
--OB_CMD_GIVE_GIFT     = 0x57E -- 广播发送礼物结果给其他观战玩家，以及礼物接收者 -- 3.2.0 以前版本
OB_CMD_GIVE_GIFT     = 0x580 -- 广播发送礼物结果给其他观战玩家，以及礼物接收者 -- 3.2.0 版本

--- match money -----


FASTMATCH_LOGINROOM_REQUEST     = 0x601 -- 速赛，登陆房间请求 和 返回
FASTMATCH_GIVE_UP               = 0x602 -- 速赛，放弃比赛
FASTMATCH_ROUNDOVER             = 0x603 -- 棋局结束通知
FASTMATCH_ENTERNEXTROOM_NOTIFY  = 0x604 -- 进入下一个场次通知
MATCH_GETTABLEINFO              = 0x605 -- 获取比赛桌子信息
MATCH_GETMATCHINFO              = 0x606 -- 获取比赛战况
MATCH_GETOBTABLEINFO            = 0x607 -- 获取观战的比赛桌子信息
MATCH_LOGIN_SUC                 = 0x608 -- 比赛房间登录成功
MATCH_PLAYER_CHANGE_STATE       = 0x609 -- 玩家在比赛中的状态改变
MATCH_LEAVE_OB                  = 0x60A -- 退出观战
MATCH_GET_ROUND_INDEX           = 0x60B -- 获取场次索引
MATCH_ENTER_OBSERVE_TABLE_REQUEST   = 0x60C -- 比赛进去观战桌子
MATCH_BROADCAST_TABLESTEP           = 0x60D -- 比赛结束时，广播棋谱
            
FASTMATCH_SIGNUP_REQUEST        = 0x2101 -- 参赛报名请求
FASTMATCH_CANCLESIGNUP_REQUEST  = 0x2102 -- 取消报名请求
FASTMATCH_GET_SIGNUP_INFO       = 0x2103 -- 请求比赛房间信息
FASTMATCH_SIGNUP_COUNT_NOTIFY   = 0x2113 -- 报名人数变动通知 
FASTMATCH_DROPOUT_NOTIFY        = 0x2112 -- server主动通知退出报名
FASTMATCH_ENTERROOM_NOTIFY      = 0x2111 -- 比赛进入通知
FASTMATCH_SIGN_UP_LIST          = 0x2103 -- 速战赛报名列表

-- 比赛争霸相关
COMPETE_SIGN_BEGIN 				= 0x2601 -- 通知报名开始
COMPETE_DELAY_SIGN_END 			= 0x2602 -- 通知延时报名结束
COMPETE_MATCH_START 			= 0x2603 -- 通知比赛开始
COMPETE_LATE_ENTER_END 			= 0x2604 -- 通知迟到进入结束
COMPETE_WATCH_LIST				= 0x260C -- 获取观战列表
COMPETE_WATCH_LIST_RESPONSE		= 0x260C -- 观战列表数据返回


-- 职业赛 --

LOGIN_MATCH                     = 0x2605 -- 登录比赛
LOGIN_MATCH_RESPONSE            = 0x2605 -- 登录比赛结果返回
QUERY_GAME_PLAYER_STATUS        = 0x2606 -- 玩家获取自己在争霸赛中的状态
SERVER_RETURNS_PLAYER_STATUS    = 0x2607 -- 服务器返回玩家状态

USER_REQUEST_MATCHING           = 0x2608 -- 用户请求匹配
USER_REQUEST_MATCHING_RESULT    = 0x2608 -- 用户请求匹配结果
METIER_RESULT_MSG               = 0x60E  -- 职业赛结算消息
GET_MATCH_PLAYER_INFO           = 0x610 -- 获得比赛桌子2玩家信息
GET_MATCH_PLAYER_INFO_RESULT    = 0x610 -- 获得比赛桌子2玩家信息返回
GIVE_UP_THE_RESURRECTION        = 0x260A -- 放弃复活
GIVE_UP_THE_MATCH               = 0x260E -- 放弃比赛
CHECK_OUT_STATUS                = 0x260D --查比赛淘汰状态
CHECK_OUT_STATUS_RESULT         = 0x260D --查比赛淘汰状态返回
CHECK_MATCH_USER_GIFT_INFO      = 0x611 -- 服务器返回比赛礼物赠送统计信息
CHECK_MATCH_USER_GIFT_INFO_RESULT = 0x611 --用户获取比赛礼物赠送统计信息
CHECK_MATCH_USER_MAX_SCORE          = 0x260B --用户批量查询历史最高分
CHECK_MATCH_USER_MAX_SCORE_RESULT   = 0x260B --服务器返回历史最高分
MATCH_END_MATCH_RESULT                = 0x260F --比赛停止匹配
MATCH_END_RESULT                = 0x2610 --比赛结束
MATCH_START_REMINDER            = 0x2611 --开赛提醒
MATCH_BROADCAST_OUTS            = 0x2612 --赛况播报
MATCH_BROADCAST_EVENT           = 0x2613 --比赛事件播报
MATCH_GET_WATCH_TID             = 0x2614 --获取新的观战桌子
MATCH_GET_MATCH_SCORE           = 0x2615 --获取比赛积分
MATCH_CHECK_USER_RANK           = 0x2616 --查询用户排名
-----
VIP_LOGIN_WATCHROOM             = 0x55E  -- VIP用户登录

CHECK_ROOM_TYPE                 = 0x200D --查询桌子类型
CHECK_WIN_COMBO                 = 0x3811 --查询用户连胜

NOTICE_FREEZE_USER              = 0x330E --封号

----比大小小游戏------
THAN_SIZE_START                  = 0x4000 --比大小游戏开始c2s
THAN_SIZE_RESULT                 = 0x4002 --比大小游戏结果s2c

