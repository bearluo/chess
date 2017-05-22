require("core/dict");

GameCacheData = class();

GameCacheData.SOUNDVOLUME = "soundvolume";  --音效的音量大小
GameCacheData.MUSICVOLUME = "musicvolume";  --音乐的音量大小
	
GameCacheData.CHATTOGGLE  = "chattoggle";   --音效开关
GameCacheData.SOUNDTOGGLE = "soundtoggle";  --音效开关
GameCacheData.MUSICTOGGLE = "musictoggle";  --音乐开关
GameCacheData.VIBRATETOGGLE = "vibratetoggle";  --振动开关

GameCacheData.CONSOLE_MAX_LEVEL = "console_level_max" --当前的开放的最高单机等级
GameCacheData.CONSOLE_MAX_OPENLEVEL = "new_console_openlevel_max"--当前的解锁的最高单机等级
GameCacheData.CONSOLE_MODE  = "console_mode";   --单机的模式
GameCacheData.CONSOLE_LEVEL  = "console_level";   --单机的AI级别
GameCacheData.CONSOLE_PASS_LEVEL  = "new_console_pass_level";   --单机正在闯关的关卡
GameCacheData.CONSOLE_HASPASS_LEVEL  = "console_haspass_level"; --单机通关的的关卡
GameCacheData.CONSOLE_MVLIST = "console_mvlist";  --单机的走棋历史
GameCacheData.CONSOLE_CHESSMAP = "console_chessmap";  --本地编码的棋子ID信息
GameCacheData.CONSOLE_PCLIST = "console_pclist"    ;  --死亡棋子信息;
GameCacheData.CONSOLE_RESULT_RECORD = "console_result_record"    ;  --各关单机胜负纪录;
GameCacheData.CONSOLE_ZHANJI = "console_zhanji";  --单机战绩;
GameCacheData.CONSOLE_PASS_GATE = "console_pass_gate";  --单机通关;

GameCacheData.ENDGAME_VERSION = "endgame_version_v2_";    --残局版本号
GameCacheData.ENDGAME_VERSION_NEW = "endgame_version_new_v2_";    --残局版本号
GameCacheData.ENDGAME_GATE_NUM = "endgame_gate_num_v2_";    --残局大关卡数
GameCacheData.ENDGAME_DATA = "endgame_data_v2_"             --残局关卡数据
GameCacheData.ENDGAME_DATA_PROGRESS = "endgame_data_progress_v2_"  --残局大关卡进度

--单机残局的数据
GameCacheData.ENDGAME_UID         = "endgame_uid";       --残局用户的UID，每个UID都有一套数据(储存最后一次登陆的UID)
GameCacheData.ENDGAME_LIFE_NUM    = "endgame_life_num";  --用户的生命数
GameCacheData.ENDGAME_LIFE_LIMIT  = "endgame_life_limit";  --用户的生命上限
GameCacheData.ENDGAME_TIPS_NUM    = "endgame_tips_num";  --用户的提示数量
GameCacheData.ENDGAME_UNDO_NUM    = "endgame_undo_num";  --用户的悔棋数
GameCacheData.ENDGAME_REVIVE_NUM  = "endgame_revive_num";  --用户的起死回生数
GameCacheData.ENDGAME_LATETST_GATE  = "endgame_latetst_tid_v1_";  --用户最新大关卡
GameCacheData.ENDGAME_LATETST_SORT  = "endgame_latetst_pos_v1_";  --用户最新小关卡
GameCacheData.ENDGAME_PROPORTION  = "endgame_proportion";  --用户残局领先率
GameCacheData.ENDGAME_WEBBOOTH_URL  = "endgame_webbooth_url";  --用户残局网页分享地址

GameCacheData.LAST_VERSION = "last_version"; --用于检测软件覆盖安装处理

GameCacheData.PHP_APPID = "php_appid";    --php统计用户来源相关
GameCacheData.PHP_APPKEY = "php_appkey";    --php统计用户来源相关
GameCacheData.PHP_BID = "php_bid";    --php统计用户来源相关

GameCacheData.GAME_TYPE = "game_type"; --联网金币场用于显示人数

GameCacheData.RANK_TYPE = "rank_type"; --联网金币场用于显示人数

GameCacheData.Mall_SHOP_VERSION = "Mall_SHOP_VERSION";
GameCacheData.MALL_GOODS_LIST = "MALL_GOODS_LIST"; --金币商品列表数据
GameCacheData.MALL_ORDER = "MALL_ORDER" ; --购买记录
--象棋积分墙版本接入添加，2014/8/25
GameCacheData.POINT_Mall_SHOP_VERSION = "POINT_Mall_SHOP_VERSION";
GameCacheData.POINT_MALL_GOODS_LIST = "POINT_MALL_GOODS_LIST"; --积分商品列表数据
GameCacheData.POINT_MALL_ORDER = "POINT_MALL_ORDER" ; --积分兑换记录



GameCacheData.LAST_LOGIN_TYPE	= "last_login_type"; --上次登录类型
GameCacheData.ACCESS_TOKEN  = "accessToken"; --

GameCacheData.NULL = "null";--空
GameCacheData.DAPU_LAST_BORAD_FEN = "dapu_last_board_fen";--保存当前的开始fen串
GameCacheData.DAPU_LAST_CHESS_STR = "dapu_last_chess_str";--保存当前的开始棋局
GameCacheData.DAPU_KEY	 = "dapu_key";				
GameCacheData.RECENT_DAPU_KEY  = "recent_dapu_key";		
GameCacheData.chess_data_key_split = ",";

GameCacheData.SYNDATA 	 = "syn_data";
GameCacheData.PROP_LIST_VERSION  = "prop_list_version";
GameCacheData.PROP_LIST = "prop_list";
GameCacheData.NEW_PROP_LIST_VERSION  = "new_prop_list_version";
GameCacheData.NEW_PROP_LIST = "new_prop_list";
GameCacheData.CONSOLE_PLAY_HISTORY = "console_play_history"; --玩新版本单机记录
GameCacheData.CONSOLE_PLAY_REWARD = "console_play_reward"; --玩新版本单机奖励

--------------账号完善相关------------
GameCacheData.ONLINE_PLAY_TIMES = "online_play_times";
GameCacheData.SHOW_MODIFY_TIP_TIMES = "show_modify_tip_times";
GameCacheData.SHOW_BINDING_TIP_TIMES = "show_binding_tip_times";
GameCacheData.TIP_START_TIME = "tip_start_time";
--------------------------------------
--聊天房间和最后信息记录
GameCacheData.ROOM_LAST_MSG_DATA = "room_last_msg";
GameCacheData.LAST_ENTRY_ROOM_ID = "last_entry_room_id";
GameCacheData.HISTORY_MSG = "history_msg";
GameCacheData.TMEP_MSG = "recv_temp_msg";
GameCacheData.QUIT_ROOM_TIME = "quit_room_time";
GameCacheData.CHAT_USER_INFO = "chat_room_user_info";


--单机残局的数据
GameCacheData.ENDGAME_UID         = "endgame_uid";       --残局用户的UID，每个UID都有一套数据(储存最后一次登陆的UID)
GameCacheData.ENDGAME_LIFE_NUM    = "endgame_life_num";  --用户的生命数
GameCacheData.ENDGAME_LIFE_LIMIT  = "endgame_life_limit";  --用户的生命上限
GameCacheData.ENDGAME_TIPS_NUM    = "endgame_tips_num";  --用户的提示数量
GameCacheData.ENDGAME_UNDO_NUM    = "endgame_undo_num";  --用户的悔棋数
GameCacheData.ENDGAME_REVIVE_NUM  = "endgame_revive_num";  --用户的起死回生数

GameCacheData.ENDING_UPDATE_LAST_SYS_TIME = "endgame_life_last_sys_time";--最后的系统时间
GameCacheData.ENDING_UPDATE_LAST_TIME = "endgame_life_last_update_time";
GameCacheData.ALREADY_LOGIN = "already_login";
GameCacheData.QQ_OPENID = "qq_openid";

GameCacheData.WEIBO_ACCESS_TOKEN  = "weibo_accessToken"; --
GameCacheData.WEIBO_USERID  = "weibo_userid"; --

GameCacheData.CONSOLE_HAS_DATA_RESET = "console_has_data_need_reset";
GameCacheData.CONSOLE_DATA_FROM_EXIST_CHESS = "console_data_from_exist_chess";--来自中途棋局数据。
GameCacheData.CONSOLE_IS_EXISTED_CHESS = "console_is_existed_chess";--是否存在中途棋局。


GameCacheData.DAPU_ENABLE = "dapu_enable";
GameCacheData.DAPU_LIMIT = "dapu_limit";
GameCacheData.DAPU_AUTOSAVE_LIMIT = "dapu_autosave_limit";

GameCacheData.PROP_BUDAN = "prop_budan";
GameCacheData.COIN_GOODS_BUDAN = "coins_goods_budan";
GameCacheData.PRE_NEED_UPADTE_BUDAN = "pre_need_update_budan";


GameCacheData.DOWN_LOAD_PROPS = "download_props";

GameCacheData.PLAY_CONSOLE_COUNT = "play_console_count";
GameCacheData.CONSOLE_AI_LEVEL = "console_ai_level";
GameCacheData.FIRST_CONSOLE_FLAG = "first_console_flag";
GameCacheData.ONLINE_UNDOSS_LIST = "online_undo_list";
GameCacheData.DAILY_WORK_LOG_DATE = "daily_work_log_date";
GameCacheData.ENDGATE_PLAY_COUNT = "endgate_play_count";
GameCacheData.ONLINE_GAME_PLAY_COUNT = "online_game_play_count";
GameCacheData.IS_ENDGATE_PLAY_REWARD= "is_endgate_play_reward";
GameCacheData.IS_ONLINE_GAME_PLAY_REWARD = "is_online_game_play_reward";

GameCacheData.NET_CONFIG = "net_config";
GameCacheData.WEB_REQUEST_URL = "web_request_url";
GameCacheData.NET_CONFIG_VERSION = "net_config_version"
GameCacheData.SOUL_LIST_VERSION = "soul_list_version"
GameCacheData.QI_HUN = "qi_hun"



GameCacheData.BOYAA_BID = "boyaa_bid";

GameCacheData.IS_BIND_BOYAA = "isBindBoyaa";
GameCacheData.IS_BIND_YOUKE = "isBindYouke";
GameCacheData.USER_MONEY = "user_money";
GameCacheData.USER_BCCIONS = "user_bccions";

GameCacheData.CONSOLELEVELCONFIG = "console_level_config";

GameCacheData.ENDGATECONFIG = "endgate_config";
GameCacheData.ENDGATECONFIGVERSION = "endgate_config_version";

GameCacheData.NOTICENUM = "notice_num";

-- friends data
GameCacheData.FRIEND_FRIENDS_PAGE_TAB = "friend_friends_page_tab_";
GameCacheData.FRIEND_FOLLOW_PAGE_TAB = "friend_follow_page_tab_";
GameCacheData.FRIEND_FANS_PAGE_TAB = "friend_fans_page_tab_";
GameCacheData.FRIEND_CHAT_LIST = "friend_chat_list_";
GameCacheData.FRIEND_CHAT_DATA = "friend_chat_data_";
GameCacheData.FRIEND_USER_DATA = "friend_user_data_";
-- friends data end
GameCacheData.TONG_XUN_LU = "tong_xun_lu"; -- 通讯录
GameCacheData.TONG_XUN_LUMD5 = "tong_xun_lumd5"; -- 通讯录数据
GameCacheData.TONG_XUN_LUDATA = "tong_xun_ludata"; -- 保存通讯录数据

-- 回放新手引导
GameCacheData.REPLAY_NOVICE_GUIDE = "replay_novice_guide_"
-- 帐号列表
GameCacheData.ACOUNT_LIST = "acount_list_2";

GameCacheData.FORCEUPDATE = "check_update";
GameCacheData.QQ_GROUP = "qq_group";
-- 城市地区列表
GameCacheData.ALL_CITY_DATA = "add_city_data";
GameCacheData.PROVINCE_DATA = "province_data";
GameCacheData.LOCATE_CITY_NAME  = "locate_city_name";
GameCacheData.LOCATE_CITY_CODE = "locate_city_code";
GameCacheData.LOCATE_CITY_INFO = "locate_city_info";
GameCacheData.GET_CITY_DATA = "is_get_city_data";  -- 版本号


-- 我的收藏
GameCacheData.MY_SAVE_CHESS_DATA = "my_save_chess_data";
GameCacheData.MY_SAVE_CHESS_KEYS = "my_save_chess_keys";

-- 个性装扮
GameCacheData.BOARDTYPE = "board_type" --棋盘类型
GameCacheData.CHESSPIECE = "chess_piece" --棋子类型
GameCacheData.HEADFRAME = "head_frame" --头像框类型

-- 消息个数
GameCacheData.NOTICE_NUM = "notice_num";
GameCacheData.NOTICE_MAILS_TIME = "notice_mails_time";

--启动页控制
--GameCacheData.START_CONFIG = "start_view_config" --启动页配置
GameCacheData.START_IS_OPEN = "start_is_open"; -- 是否打开启动页
GameCacheData.START_AD_SEC = "start_ad_sec";   -- 启动页时间
GameCacheData.START_AD_IMG_URL = "start_ad_url";   -- 启动页图片地址
GameCacheData.START_AD_JUMP = "start_ad_jump"; -- 启动页跳转地址
GameCacheData.START_AD_JUMP_URL = "start_ad_jump_url"; -- 启动页跳转链接

--走子方式设置
GameCacheData.MOVE_MODE = "move_mode"; -- 走子方式设置



-- ios 评价
GameCacheData.IS_SHOW_IOS_EVALUATE_DIALOG = "is_show_ios_evaluate_dialog";-- 是否显示ios评价弹窗
GameCacheData.HAS_EVALAUTED = "has_evalauted";-- 已经评价了
GameCacheData.LAST_SHOWEVADLG_TIME = "last_showevadlg_time"; -- 上次显示的时间

GameCacheData.ctor = function(self)
	self.m_dict = new(Dict,"chinesechess_cache_data");
	self.m_dict:load();
end

GameCacheData.getInstance = function()
	if not GameCacheData.s_instance then
		GameCacheData.s_instance = new(GameCacheData);
	end
	return GameCacheData.s_instance;
end

GameCacheData.deleteAll = function(self)
	self.m_dict:delete("chinesechess_cache_data");
end

GameCacheData.saveInt = function(self,key,value)
	self.m_dict:setInt(key,value);
	self.m_dict:save();
end

GameCacheData.saveDouble = function(self,key,value)
	self.m_dict:setDouble(key,value);
	self.m_dict:save();
end

GameCacheData.saveBoolean = function(self,key,value)
	self.m_dict:setBoolean(key,value);
	self.m_dict:save();
end

GameCacheData.saveString = function(self,key,value)
	self.m_dict:setString(key,value);
	self.m_dict:save();
end

GameCacheData.getInt = function(self,key,defaultValue)
	return self.m_dict:getInt(key,defaultValue);
end

GameCacheData.getDouble = function(self,key,defaultValue)
	local value = self.m_dict:getDouble(key,defaultValue);
	return value;
end

GameCacheData.getBoolean = function(self,key,defaultValue)
	return self.m_dict:getBoolean(key,defaultValue);
end	

GameCacheData.getString = function(self,key,defaultValue)
	return self.m_dict:getString(key) or defaultValue;
end

kGameCacheData = GameCacheData.getInstance();