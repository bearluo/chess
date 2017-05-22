VERSIONS = kLuaVersion;
VERSIONS_CODE = kLuaVersionCode;


UPDATEVERSION  = "updateVersion"; 
UPDATEVERSION_FORCE = "UPDATEVERSION_FORCE";


ERROR_NUMBER = -100;    --socket没读到数据时的默认值
ERROR_STRING = "";      --socket没读到数据时的默认值


SUBCMD_NULL = 0;        --  新版不需要子命令号了
SUBCMD_LADDER = 1;      --天梯
SUBCMD_MONEY = 2;       --金币场的子命令号
MAIN_VER = 1;           --socket主版本号
SUB_VER = 1;            --socket子版本号
DEVICE_TYPE = 3;        --设备类型

GAME_TYPE_UNKNOW = 0;   --未类型
GAME_TYPE_FREE = 1;     --自由场
GAME_TYPE_TEN = 2;      --十分钟场
GAME_TYPE_TWENTY = 3;   --二十分钟场
GAME_TYPE_ASYN = 4;     --异步场
GAME_TYPE_COMPUTER = 7; --单机游戏
GAME_TYPE_WATCH = 6;   --观战模式
GAME_TYPE_CUSTOMROOM = 5; --自定义房间游戏
GAME_TYPE_ONLINE   = 8;--联网
GAME_TYPE_ENDGATE  = 9;--残局
GAME_TYPE_FRIEND = 10;--好友场
GAME_TYPE_OFFLINE  = 11;--单机和残局


BOARD_TYPE_CUSTOM = 1;--棋盘摆子
BOARD_TYPE_START  = 2;--棋局开始


TIPS_VISIBLE_LEVEL = 200;   --提示信息的显示层级
DIALOG_VISIBLE_LEVEL = 100;
BUTTON_VISIBLE_LEVEL = 3;   --button 显示层级
CHESS_SELECTED_LEVEL = 4;   --选择棋子的层级
CHESS_HINT_LEVEL = 3;       --走法提示的显示层级
CHESS_LEVEL = 2;            --棋子的显示层级
CHESS_PATH_LEVEL = 1;       --走棋路径的显示层级


--游戏结束类型（原因）
ENDTYPE_KILL = 1;           --1 将死
ENDTYPE_DRAW = 2;           --2 和棋
ENDTYPE_SURRENDER = 3;      --3 认输
ENDTYPE_TIMEOUT = 4;        --4 超时
ENDTYPE_LEAVE = 5;          --5 逃跑
ENDTYPE_JAM = 6;            --6 困毙
ENDTYPE_OFFLINE_TIMEOUT = 7;--7 掉线超时
ENDTYPE_ROUND_NUM = 8;      --8 回合数超过60步没有吃子
ENDTYPE_UNLEGAL = 100;      --  电脑走棋不合法（长捉长将）
ENDTYPE_UNCHANGE = 101;

--玩家的红黑标志
FLAG_RED = 1;
FLAG_BLACK = 2;

--玩家的男女标志- -性别 性别 0 未知 1 男 2 女
SEX_UNKNOW = 0;
SEX_MAN = 1;
SEX_WOMAN = 2;


--玩家状态
STATUS_PLAYER_LOGOUT  = 0;  --登出
STATUS_PLAYER_LOGIN = 1;       --登录，未入座
STATUS_PLAYER_COMING = 2;   --入座
STATUS_PLAYER_RSTART  = 3;     --入座，准备开始
STATUS_PLAYER_ACTIVE  = 4;    --正在对弈
STATUS_PLAYER_OVER  = 5;      --对弈结束


--棋局状态   1停止 2正在下棋 3抢先 4让子 5设置局时 6等待局时回复
STATUS_TABLE_STOP = 1;
STATUS_TABLE_PLAYING = 2;
STATUS_TABLE_FORESTALL = 3;
STATUS_TABLE_HANDICAP = 4;
STATUS_TABLE_SETTIME = 5;
STATUS_TABLE_SETTIMERESPONE = 6;
--STATUS_TABLE_CLOSE	= -1; 
--STATUS_TABLE_EMPTY	 = 0;
--STATUS_TABLE_WAIT_FOR_PLAYER	 = 1; 
--STATUS_TABLE_ONE_PLAYER	 = 1; 
--STATUS_TABLE_WAIT_FOR_START	=  5;
--STATUS_TABLE_TWO_PLAYER	 = 5;
--STATUS_TABLE_WAIT_FOR_SETTIME  = 6;
--STATUS_TABLE_ACTIVE_RED	 = 2;
--STATUS_TABLE_ACTIVE_BLACK	 = 3;
--STATUS_TABLE_OVER	 = 4;


--棋盘和房间之间数据交换
CHESS_MOVE = "chess_move"


--下完棋之后的状态
CHESS_MOVE_OVER_DRAW = 0;  --和棋
CHESS_MOVE_OVER_RED_WIN = 1;  --红方胜
CHESS_MOVE_OVER_BLACK_WIN = 2;  --黑方胜

CHESS_MOVE_NOTHING = 3;  --普通落子
CHESS_MOVE_EAT = 4;      --吃子
CHESS_MOVE_CHECK = 9;   --将军


--聊天弹出框的显示时间
ROOM_CHAT_SHOW_TIME = 3000;  --单位：毫秒 

--名字和聊天的分隔符
NAME_CHAT_SEPARATOR = ":";

--步时图片
TIMEOUT2_IMG_FILE = "drawable/timeout2_texture.png";
--读秒图片
TIMEOUT3_IMG_FILE = "drawable/timeout3_texture.png"


--引擎传给GUI的数据
ENGINE_GUI = "Engine2Gui";
--
GUI_ENGINE = "Gui2Engine";

PAY = "Pay";

--上报lua错误
REPORT_LUA_ERROR = "ReportLuaError";

--Engine Status
ENGINE_EXIT = -1;
ENGINE_IDLE = 0;
ENGINE_STOP = 1;
ENGINE_HINT = 2;
ENGINE_MOVE = 3;

AI_MAX_LEVEL = 20;
AI_EVERY_GATE_NUM = 4;

MV_SPLIT = " ";   --保存走棋步骤时的
CONSOLE_LEAST_THINK_TIME = 2;  --电脑的最短思考时间（秒）
CONSOLE_GAME_TID = 0; --单机的tid
CONSOLE_GATE_NUM = 10;
COMPUTER_UID = -100;
COMPUTER_NAME = "我是达闻西"

CONSOLE_SAVE_CHESS_MOVE = "console_save_chess_move"--保存单机玩家走棋步骤的响应事件
CUSTOM_BOARD_CHESS_MOVE = "custom_board_chess_move"--自定义棋局走棋步骤响应事件
ENDING_LIFE_COOLING_TIME = 30;--残局每点生命冷却时间（分钟）


---------联网游戏---

HALL_NOTICE_EVENT = "HALL_NOTICE_EVENT"; --有通知
HALL_LOGIN_REWARD_EVENT = "HALL_LOGIN_REWARD_EVENT" --有登录奖励

ONLINE_PLAYER_NUM_QUERY_EVENT = "online_player_num_query_event";  --查找游戏场人数
ONLINE_MATCH_EVENT  = "online_match_event";   --匹配房间
ONLINE_GIVEUP_EVENT = "online_giveup_event";   --放弃重新游戏
ONLINE_RELOGIN_EVENT = "online_relogin_event";  --重登录
ONLINE_HALL_RELOGIN_EVENT = "online_hall_relogin_event";  --大厅重登录
ONLINE_TIPS_EVENT = "online_tips_event";   --服务器提醒消息
ONLINE_NEW_TIPS_EVENT = "online_new_tips_event";   --新的服务器提醒消息
ONLINE_HOME_EVENT = "online_home_event";   --用户按HOME键
ONLINE_FORESTALL_EVENT = "online_forestall_event" -- 抢先提醒	（服务器推送）
ONLINE_HANDICAP_EVENT = "online_handicap_event" -- 让子提醒	（服务器推送）

ONLINE_COLLAPSE_EVENT = "online_collapse_event";   --破产补助
ONLINE_UPDATE_USERINFO_EVENT = "online_update_userinfo_event";  --更新用户信息
ONLINE_HALL_GET_ROOMS_LIST ="online_hall_get_rooms_list"; --获取房间列表
ONLINE_HALL_SEARCH_ROOM ="online_hall_search_room"; --查找自定义房间
ONLINE_HALL_CREATE_CUSTOMROOM ="online_hall_create_customroom"; --创建自定义房间
ONLINE_HALL_SEARCH_ROOM_ENTER ="online_hall_search_room_enter"; --查找自定义房间信息用来进入房间
ONLINE_SEARCH_CUSTOMROOM_FAIL ="online_search_customroom_fail"; --查找自定义房间不成功
ONLINE_CREATE_CUSTOMROOM_FAIL ="online_create_customroom_fail"; --创建自定义房间不成功
ONLINE_ENTER_CUSTOMROOM_FAIL ="online_enter_customroom_fail"; --进入自定义房间不成功

END_GAME_INFO = "end_game_info"; --获取残局大关信息
END_GAME_SERVER = "end_gate_server"; --下载关卡信息
END_GATE_CHECK_UPDATE = "end_gate_check_update";

PREVENT_ADDICTED_INPUT_ERROR_EVENT ="prevent_addicted_input_error_event"; --防沉迷输入错误 
PREVENT_ADDICTED_VERIFY_SUCC_EVENT = "prevent_addicted_verify_succ_event";--防沉迷验证成功
PREVENT_ADDICTED_COLLAPSE_TIPS_EVENT = "prevent_addicted_collapse_tips_event";--防沉迷破产补助提示 

RANK_MONEY_EVENT = "rank_money_event";
RANK_SCORE_EVENT = "rank_score_event";

--象棋积分墙版本接入添加：2014/8/25
POINT_MALL_SHOP_EVENT = "point_mall_shop_event";  --积分商品列表
GET_POINTS_EVENT = "get_points_event";
POINT_MALL_EXCHANGE = "point_mall_exchange";
IS_POINTWALL_AVAILABLE = "is_pointwall_available";
--象棋积分墙版本接入添加：2014/8/25

MALL_SHOP_EVENT = "mall_shop_event";  --商品列表
MALL_RECORD_EVENT = "mall_record_event"; -- 购买记录
MALL_GOODS_ID_EVENT = "mall_goods_id_event" --获取商品ID
MALL_PLACE_ORDER_EVENT = "mall_place_order_event" --下订单
MALL_PAY_ORDER_EVENT = "mall_pay_order_event";   --请求发货
PROP_PAY_ORDER_EVENT = "prop_pay_order_event";   --请求发货

GET_OPENBOX_TIME_EVENT = "get_openbox_time_event";   --获取在线时长
GET_SOUL_LIST_EVENT = "get_soul_list_event";   --获取兑换列表
EXCHANGE_SOUL_EVENT = "exchange_soul_event";   --兑换
SHOW_INPUT_TEL_NO = "show_input_tel_no"
SOUL_NOT_ENOUGH_FOR_COST = "soul_not_enough_for_cost";   --兑换

GET_360ACCESS_TOKEN_EVENT = "get_360access_token";


PROP_SHOP_EVENT = "prop_shop_event" --获取残局道具商品列表
ADD_DELIVER_LOG_EVENT = "add_deliver_log_event" --客户端通知php已发货

GET_MSG_EVENT = "get_msg_event";   --拉取消息
GET_MSG_COUNT_EVENT = "get_msg_count_event";	--拉取消息数目
DEL_MSG_EVENT = "del_msg_event"; 	--删除消息


MALL_BUY_GOODS_EVENT = "mall_buy_goods_event"  --选中某一件商品准备购买
MALL_REPAY_ORDER_EVENT = "mall_repay_order_event";  --失败补单


WATCH_GAME_LIST_EVENT = "watch_game_list_event"; --获取观战列表
WATCH_TIPS_EVENT = "watch_tips_event";   --观战服务器提醒消息

KICK_USER_EVENT = "kick_user_event"; --踢出用户


USER_FRIEND_WATCH_EVENT = "user_friend_watch_event";--玩家好友点击观战


MSG_BUTTON_EVENT		= "msg_btn_event";--消息中心按钮事件
GET_FRIENDS_LIST_EVENT = "get_friends_list_event";--获取好友列表
ADD_FRIEND_EVENT ="add_friend_event";--关注好友
SEARCH_FRIEND_EVENT ="search_friend_event";--搜索好友

TASK_PROGRESS = "task_progress";

GETFPLAY_PROGRESS = "getFPlay_progress";

GET_CONSOLE_PROGRESS = "get_console_progress";

CONSOLE_UPDATE = "console_update";
UPLOAD_CONSOLE_PROGRESS = "upload_console_progress";

CHECK_BIND_BOYAA = "check_bind_boyaa";
BIND_BOYAA_ACCOUNT = "bind_boyaa_account";

OPEN_LEVEL = "open_level";
OPEN_TOLL_GATE = "openTollgate";
OPEN_TOLL_GATE_CONFIG = "openTollgateConfig";
--multi_resolution

CONSOLE_LEVEL_LEFT = 0;--貌似这个值没用


CONSOLE_LEVEL_TEXTRUE_LEFT = 139;
CONSOLE_LEVEL_TEXTRUE_TOP = 28;


LUA_MULTI_CLICK_TIME = 0;


SPACE_KEY  = "space_key";

LOGIN_TYPE_YOUKE = "type_youke";
LOGIN_TYPE_360 = "type_360";
LOGIN_TYPE_qq = "type_qq";
LOGIN_TYPE_weibo = "type_weibo";
LOGIN_TYPE_BOYAA = "type_boyaa";



----------------customroom status------------------------
-- RoomStatus 房间状态	 Short	2	-1 棋桌关闭 0 棋桌空 1 棋桌有一个人 5 棋桌有两个人 2红方走棋 3 黑方走棋 4 游戏结束 6 设置时间
CUSTOMROOM_TABLE_CLOSE=-1;
CUSTOMROOM_TABLE_NO_PERSON=0;
CUSTOMROOM_TABLE_ONE_PERSON=1;
CUSTOMROOM_TABLE_TWO_PERSON=5;
CUSTOMROOM_TABLE_RED_MOVE=2;
CUSTOMROOM_TABLE_BLACK_MOVE=3;
CUSTOMROOM_TABLE_GAME_OVER=4;
CUSTOMROOM_TABLE_TIME_SETTING=6;


----ending_game---

ENDING_LIFE_NUM = 5;  --生命的初始值
ENDING_TIPS_NUM = 0;  --提示的初始值
ENDING_UNDO_NUM = 5;	--悔棋的初始值
ENDING_REVIVE_NUM = 0; --起死回生的初始值


ENDING_LIFELIMIT_NUM = 5;  --生命的极限值1
ENDING_LIFELIMIT_NUM2 = 8;  --生命的极限值2
ENDING_LIFELIMIT_NUM3 = 11;  --生命的极限值3
ENDING_LIFELIMIT_NUM4 = 14;  --生命的极限值4

CHINA_MOBILE = 1; --移动
CHINA_UNICOM = 2;--联通 
CHINA_TELECOM = 3;--电信
CHINA_TIETONG= 4;--中国铁通



--事件统计
ON_EVENT_STAT = "OnEventStat";
--分享文本信息
SHARE_TEXT_MSG = "ShareTextMsg";
--分享图片信息
SHARE_IMG_MSG = "ShareImgMsg";
--指定分享微博文本信息
SHARE_TEXT_TO_WEIBO_MSG = "ShareWEIBOMsg";
--指定分享微信文本信息
SHARE_TEXT_TO_WEICHAT_MSG = "ShareWEICHATMsg";
--指定分享朋友圈文本信息
SHARE_TEXT_TO_PYQ_MSG = "SharePYQMsg";
--指定分享短信文本信息
SHARE_TEXT_TO_SMS_MSG = "ShareSMSMsg";
--指定分享QQ文本信息
SHARE_TEXT_TO_QQ_MSG = "ShareQQMsg";

IS_TIMELINECB = "IsTimelineCb" ; -- 分享到朋友圏
TAKE_SCREEN_SHOT = "TakeScreenShot" --截屏
TO_WEB_PAGE = "ToWebPage" --打开网页

--大厅按钮事件
HALL_MODEL_ENDING_BTN = "hall_model_ending_btn"  --大厅残局
HALL_MODEL_ONLINE_BTN = "hall_model_online_btn"  --大厅联网
HALL_MODEL_CONSOLE_BTN = "hall_model_console_btn" --大厅单机按钮
HALL_MODEL_MESSAGE_BTN = "hall_model_message_btn" --大厅消息按钮
HALL_MODEL_FEEDBACK_BTN = "hall_model_feedback_btn" --大厅反馈按钮
HALL_MODEL_HELP_BTN = "hall_model_help_btn"  --大厅帮助按钮
HALL_MODEL_SET_BTN = "hall_model_set_btn"  --大厅设置按钮
HALL_MODEL_ACTIVITY_BTN = "hall_model_activity_btn"  --大厅活动按钮
HALL_MODEL_USER_ICON_BTN = "hall_model_user_icon_btn"  --大厅设置用户头像按钮
HALL_MODEL_VERIFY_REWARD_BTN = "hall_model_verify_reward_btn"  --大厅验证领将
HALL_MODEL_MALL_BTN = "hall_model_mall_btn"  --大厅商城按钮

--下方模块按钮
DOWN_MODEL_RANK_BTN = "down_model_rank_btn";  --排行按钮
DOWN_MODEL_ACTIVITY_BTN = "down_model_activity_btn";  --活动按钮
DOWN_MODEL_MALL_BTN = "down_model_mall_btn";  --商场按钮
DOWN_MODEL_DAPU_BTN = "down_model_dapu_btn";  --棋谱按钮

--残局房间模块按钮
ENDGIN_ROOM_MODEL_SHARE_BTN = "endgin_room_model_share_btn"; --残局房间分享按钮
ENDGIN_ROOM_MODEL_UNDO_BTN = "endgin_room_model_undo_btn"; --残局房间悔棋按钮
ENDGIN_ROOM_MODEL_TIPS_BTN = "endgin_room_model_tips_btn"; --残局房间提示按钮
ENDGIN_ROOM_MODEL_REBORN_BTN = "endgin_room_model_reborn_btn"; --残局房间起死回生按钮
ENDGIN_ROOM_MODEL_SWITCH_BTN = "endgin_room_model_switch_btn"; --残局房间切换菜单按钮
ENDGIN_ROOM_MODEL_RESTART_BTN = "endgin_room_model_restart_btn"; --残局房间重新开始按钮
ENDGIN_ROOM_MODEL_SET_BTN = "endgin_room_model_set_btn"; --残局房间设置按钮
ENDGIN_ROOM_MODEL_EXIT_BTN = "endgin_room_model_exit_btn"; --残局房间离开按钮
ENDGIN_ROOM_MODEL_NEXTGATE_BTN = "endgin_room_model_nextgate_btn"; --残局房间下一关按钮

--武林残局房间模块按钮
WULING_ENDGIN_ROOM_MODEL_SHARE_BTN = "wuling_endgin_room_model_share_btn"; --残局房间分享按钮
WULING_ENDGIN_ROOM_MODEL_UNDO_BTN = "wuling_endgin_room_model_undo_btn"; --残局房间悔棋按钮
WULING_ENDGIN_ROOM_MODEL_TIPS_BTN = "wuling_endgin_room_model_tips_btn"; --残局房间提示按钮
WULING_ENDGIN_ROOM_MODEL_RESTART_BTN = "wuling_endgin_room_model_restart_btn"; --残局房间重新开始按钮
WULING_ENDGIN_ROOM_MODEL_SET_BTN = "wuling_endgin_room_model_set_btn"; --残局房间设置按钮
WULING_ENDGIN_ROOM_MODEL_EXIT_BTN = "wuling_endgin_room_model_exit_btn"; --残局房间离开按钮

--房间模块按钮
ROOM_MODEL_MENU_BTN = "room_model_menu_btn";  --房间菜单按钮
ROOM_MODEL_MENU_UNDO_BTN = "room_model_menu_undo_btn"  --房间悔棋
ROOM_MODEL_MENU_DRAW_BTN = "room_model_menu_draw_btn"  --房间求和
ROOM_MODEL_MENU_SURRENDER_BTN = "room_model_menu_surrender_btn"  --房间认输
ROOM_MODEL_MENU_SET_BTN = "room_model_menu_set_btn";  --房间设置按钮
ROOM_MODEL_START_BTN = "room_model_start_btn";  --房间开始按钮
ROOM_MODEL_CHAT_BTN = "room_model_chat_btn";  --房间聊天按钮
ROOM_MODEL_UPUSER_ICON = "room_model_upuser_icon";  --房间上部玩家头像
ROOM_MODEL_DOWNUSER_ICON = "room_model_downuser_icon";  --房间下部玩家头像

--单机
COSOLE_MODEL_COMPUTER = "cosole_model_computer_level";  --挑战电脑
COSOLE_MODEL_GATE_NUM = 14; -- 单机关卡数

NEW_CONSOLEROOM_MODEL_PLAY_BTN = "new_consoleroom_model_play_btn"; --加载单机某一关
NEW_CONSOLEROOM_MODEL_SHARE_BTN = "new_consoleroom_model_share_btn";--单机分享按钮
NEW_CONSOLEROOM_MODEL_RESTART_BTN = "new_consoleroom_model_restart_btn"; --单机房间重新开始按钮
NEW_CONSOLEROOM_MODEL_SET_BTN = "new_consoleroom_model_set_btn"; --单机房间设置按钮
NEW_CONSOLEROOM_MODEL_EXIT_BTN = "new_consoleroom_model_exit_btn"; --单机房间离开按钮
NEW_CONSOLEROOM_MODEL_UNDO_BTN = "new_consoleroom_model_undo_btn"; --单机房间悔棋按钮
NEW_CONSOLEROOM_MODEL_SWITCH_BTN = "new_consoleroom_model_switch_btn"; --单机房间切换菜单按钮
NEW_CONSOLEROOM_MODEL_WIN_EVT = "new_consoleroom_model_win_evt"; --单机闯关成功
NEW_CONSOLEROOM_MODEL_LOSE_EVT = "new_consoleroom_model_lose_evt"; --单机闯关失败
--邀请好友按钮
INVITE_FRIEND_BTN = "share_invite_friend_evt"; 

--场景
CONSOLE_MODEL = "console_model"  --在单机里
ONLINE_MODEL = "online_model"  --在联网场
ENDING_MODEL = "endgate_model"  --在残局场
HALL_MODEL = "hall_model"   --在大厅

INVITE_VERIFY_TELNO = "invite_verify_telno";
INVITE_CHECK_VERIFY_CODE = "invite_check_verify_code";
INVITE_VERIFY_RECEIVE_AWARDS = "invite_verify_receive_awards";
FRIENDS_GET_FRIENDLIST_EVENT = "friends_get_friendlist_event";
FRIENDS_UPLOAD_ADDRBOOK_EVENT = "friends_upload_addrbook _event";
PROP_BUDAN_EVENT = "prop_budan_event";  --道具补单
RST_PROP_LIST_EVENT = "rst_prop_list_event";  --剩下没有使用到的联网悔棋

GET_DAILY_LIST_EVENT = "get_daily_list_event";  --得到每日任务
GET_DAILY_REWARD_EVENT = "get_daily_reward_event";  --领取奖励

GET_SOUL_EVENT = "get_soul_event";  --残局单机获取棋魂


PROP_BUDAN_EVENT = "prop_budan_event";  --道具补单
GET_PROP_CONGIF_EVENT = "get_prop_congif_event";  --道具列表
EXCHANGE_PROP_EVENT = "exchange_prop_event";  --道具兑换


--------------------------prop-position-----------------------

--生命回复
MALL_LIFERECOVER = 10; --商城购买生命回复
ENDGATE_LIFERECOVER = 11;--残局大关卡购买生命回复
ENDGATESUB_LIFERECOVER = 12;--残局小关卡购买生命回复
CONSOLE_LIFERECOVER = 13;--单击大关卡购买生命回复
CONSOLE_ROOM_LIFERECOVER = 14;--单击房间购买生命回复
ENDING_ROOM_LIFERECOVER = 15;--残局房间购买生命回复

--悔棋
MALL_UNDO = 20;--商城购买悔棋
ENDING_ROOM_UNDO = 21;--残局房间购买悔棋
CONSOLE_ROOM_UNDO = 22;--单击房间购买悔棋

--提示
MALL_TIPS = 30;--商城购买提示
ENDING_ROOM_TIPS = 31;--残局房间购买提示
CONSOLE_ROOM_TIPS = 32;--单击房间购买提示

--起死回生
MALL_SAVELIFE = 40;--商城购买起死回生
ENDING_ROOM_SAVELIFE = 41;--残局房间购买起死回生
CONSOLE_ROOM_SAVELIFE = 42;--单击房间购买起死回生

--增加生命上限
MALL_LIFELEVEL = 50;--商城购买增加生命上限
ENDGATE_LIFELEVEL = 51;--残局大关卡购买增加生命上限
ENDGATESUB_LIFELEVEL = 52;--残局小关卡购买增加生命上限
CONSOLE_LIFELEVEL = 53;--单击大关卡购买增加生命上限
CONSOLE_ROOM_LIFELEVEL = 54;--单击房间购买增加生命上限
ENDING_ROOM_LIFELEVEL = 55;--残局房间购买增加生命上限

--残局关卡
MALL_GATE = 60;--商城购买残局关卡
ENDGATE_GATE= 61;--残局大关卡购买残局关卡
ENDGATESUB_GATE = 62;--残局小关卡购买残局关卡
ENDING_ROOM_GATE  = 63;--残局房间购买残局关卡

--保存棋谱
MALL_DAPU = 70;--商城购买保存棋谱
ONLINE_ROOM_DAPU = 71;--联网房间购买保存棋谱
CONSOLE_ROOM_DAPU = 72;--单击房间购买保存棋谱
ONLINE_HALL_DAPU = 73;--联网游戏大厅购买保存棋谱
CONSOLE_DAPU = 74;--单击大关卡购买保存棋谱
ENDGATE_DAPU = 75;--残局大关卡购买保存棋谱
ENDGATESUB_DAPU = 76;--残局小关卡购买保存棋谱
ONLINE_ROOM_MENU_DAPU = 77;--残局房间菜单购买保存棋谱

--单击关卡	
MALL_CONSOLE_GATE = 80;--商城购买单击关卡
CONSOLE_GATE = 81;--单击大关卡购买单击关卡
CONSOLE_ROOM_GATE = 82;--单击房间购买单击关卡

ONLINE_ROOM_UNDO1 = 91;--联网悔棋1
ONLINE_ROOM_UNDO2= 92;--联网悔棋2

CONSOLE_INGO = 93;--单击大关卡购买元宝
CONSOLE_ROOM_INGOT  = 94;--单击房间购买元宝
ENDING_ROOM_INGOT  = 95;--残局房间购买元宝

ONLINE_INGOT  = 96;--联网游戏大厅购买元宝
ONLINE_ROOM_INGOT = 97;--联网游戏房间购买元宝
ONLINE_ROOM_QUICK_BUY_INGOT = 98;--联网游戏房间购买元宝

--------------------------coin-goods-position-----------------------
MALL_COINS_GOODS = 02;--商城购买金币

COLLAPSE_ROOM_GATE = 101;--破产时候联网大厅购买金币
COLLAPSE_ROOM_BUY_COINS = 102;--破产时候联网房间购买金币



ENDGATE_NEWPASS_GATE_ACQUIRE_SOUL = 1;--通过没有通过的关卡宝箱中获得棋魂
ENDGATE_PASSED_GATE_ACQUIRE_SOUL = 2;--通过已通过的关卡宝箱中获得棋魂
CONSOLE_FIRSTPASS_LAYER_ACQUIRE_SOUL = 3;--单机首次成功通过每层最后一个关卡时得棋魂
CONSOLE_FIRSTPASS_GATE_ACQUIRE_SOUL = 4;--单机每次通过一个小关卡时获得棋魂
CONSOLE_CHALLENGE_FAIL_ACQUIRE_SOUL = 5;--单机每次挑战失败一个小关卡时获得棋魂


CUSTOMENGATE_TIPS_ENABLE = "customengate_tips_enable"--自定义残局提示可用