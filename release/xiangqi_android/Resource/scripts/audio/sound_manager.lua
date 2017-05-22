
require("core/sound");
require("util/game_cache_data");



SoundManager = class()


SoundManager.AUDIO_BUTTON_CLICK = "audio_button_click"   --点击菜单 
SoundManager.AUDIO_CHESS_SELECT = "audio_chess_select"   --选择棋子
SoundManager.AUDIO_DIALOG_SHOW = "audio_dialog_show"     --弹出对话框
SoundManager.AUDIO_EVENT_FAIL = "audio_event_fail"       --求和无效认输弹出离开操作音
SoundManager.AUDIO_GAME_START = "audio_game_start"       --游戏开始
SoundManager.AUDIO_MOVE_CHECK = "audio_move_check"       --将军
SoundManager.AUDIO_MVOE_CHESS = "audio_move_chess"       --落子
SoundManager.AUDIO_MOVE_EAT = "audio_move_eat"           --吃子     
SoundManager.AUDIO_OVER_DRAW = "audio_over_draw"         --棋局结束 和棋
SoundManager.AUDIO_OVER_LOSE = "audio_over_lose"         --棋局结束 输
SoundManager.AUDIO_OVER_WIN = "audio_over_win"           --棋局结束 赢
SoundManager.AUDIO_PAGE_CHANGE = "audio_page_change"     --切换页面
SoundManager.AUDIO_MOVE_JAM = "audio_move_jam"           --困毙 
SoundManager.AUDIO_MOVE_KILL = "audio_move_kill"         --绝杀 
SoundManager.AUDIO_MOVE_TIMEOUT = "audio_move_timeout"   --超时; 

SoundManager.AUDIO_FORESTALL    = "audio_forestall"   --让子; 
SoundManager.AUDIO_UNFORESTALL = "audio_unforestall"   --不让; 
SoundManager.AUDIO_HANDICAP_CANNON = "audio_handicap_cannon"   --让炮; 
SoundManager.AUDIO_HANDICAP_HORSE = "audio_handicap_horse"   --让马; 
SoundManager.AUDIO_HANDICAP_ROOK = "audio_handicap_rook"   --让车; 

SoundManager.AUDIO_CONSOLE_ANIM = "audio_console_anim" --单机特效

SoundManager.AUDIO_SECOND_TIP = "audio_second_tip" --倒计时提醒，木鱼声



--聊天语音
SoundManager.AUDIO_READ_EAT = "吃";
SoundManager.AUDIO_READ_CHECK = "将军";

SoundManager.AUDIO_READ_MAN_CHI = "audio_read_man_chi" --（男）吃
SoundManager.AUDIO_READ_MAN_JJ = "audio_read_man_jj" --（男）将军
SoundManager.AUDIO_READ_MAN_DYSJZ = "audio_read_man_dysjz" --（男）大意失荆州!
SoundManager.AUDIO_READ_MAN_DJZMPGZQ = "audio_read_man_djzmpgzq" --（男）当局者迷旁观者清
SoundManager.AUDIO_READ_MAN_GQBYZJZLZWHDZH = "audio_read_man_gqbyzjzlzwhdzh" --（男）观棋不语真君子落子无悔大丈夫.mp3
SoundManager.AUDIO_READ_MAN_QSRWZSLSL = "audio_read_man_qsrwzslsl" --（男）急甚 容我再思量思量.mp3
SoundManager.AUDIO_READ_MAN_LZXZYZS = "audio_read_man_lzxzyzs" --（男）两军相争勇者胜.mp3
SoundManager.AUDIO_READ_MAN_DJGPXHL = "audio_read_man_djgpxhl" --（男）你这是单車寡炮瞎胡闹.mp3
SoundManager.AUDIO_READ_MAN_QJSSX = "audio_read_man_qjssx" --（男）请君神速些吧.mp3
SoundManager.AUDIO_READ_MAN_XZGHSDJ = "audio_read_man_xzghsdj" --（男）小卒过河赛大車.mp3
SoundManager.AUDIO_READ_MAN_YZBSMPJS = "audio_read_man_yzbsmpjs" --（男）一着不慎满盘皆输.mp3
SoundManager.AUDIO_READ_MAN_YNDJZNXS = "audio_read_man_yndjznxs" --（男）与你对局此乃幸事.mp3
SoundManager.AUDIO_READ_MAN_ZYWDYYJ = "audio_read_man_zywdyyj" --（男）再与我对弈一局.mp3


SoundManager.AUDIO_READ_WOMAN_CHI = "audio_read_woman_chi" --（女）吃
SoundManager.AUDIO_READ_WOMAN_JJ = "audio_read_woman_jj" --（女）将军
SoundManager.AUDIO_READ_WOMAN_DYSJZ = "audio_read_woman_dysjz" --（女）大意失荆州!
SoundManager.AUDIO_READ_WOMAN_DJZMPGZQ = "audio_read_woman_djzmpgzq" --（女）当局者迷旁观者清
SoundManager.AUDIO_READ_WOMAN_GQBYZJZLZWHDZH = "audio_read_woman_gqbyzjzlzwhdzh" --（女）观棋不语真君子落子无悔大丈夫.mp3
SoundManager.AUDIO_READ_WOMAN_QSRWZSLSL = "audio_read_woman_qsrwzslsl" --（女）急甚 容我再思量思量.mp3
SoundManager.AUDIO_READ_WOMAN_LZXZYZS = "audio_read_woman_lzxzyzs" --（女）两军相争勇者胜.mp3
SoundManager.AUDIO_READ_WOMAN_DJGPXHL = "audio_read_woman_djgpxhl" --（女）你这是单車寡炮瞎胡闹.mp3
SoundManager.AUDIO_READ_WOMAN_QJSSX = "audio_read_woman_qjssx" --（女）请君神速些吧.mp3
SoundManager.AUDIO_READ_WOMAN_XZGHSDJ = "audio_read_woman_xzghsdj" --（女）小卒过河赛大車.mp3
SoundManager.AUDIO_READ_WOMAN_YZBSMPJS = "audio_read_woman_yzbsmpjs" --（女）一着不慎满盘皆输.mp3
SoundManager.AUDIO_READ_WOMAN_YNDJZNXS = "audio_read_woman_yndjznxs" --（女）与你对局此乃幸事.mp3
SoundManager.AUDIO_READ_WOMAN_ZYWDYYJ = "audio_read_woman_zywdyyj" --（女）再与我对弈一局.mp3

SoundManager.AUDIO_ROOM_BACK = "audio_room_back"         --房间背景音乐
SoundManager.AUDIO_GAME_BACK = "audio_game_back"         --游戏背景音乐(房间外)





SoundManager.ctor = function(self)
	local time_start = os.clock();

	self.m_platform = System.getPlatform ();

	if self.m_platform == kPlatformWin32 then
		self.m_prefix = "mp3/";
		self.m_suffix = ".mp3";
	else
		self.m_prefix = "";
		self.m_suffix = ".ogg";
	end


	self.m_soundVolume = self:getSoundVolume();
	-- local volume = Sound.getEffectMaxVolume() * self.m_soundVolume;
	Sound.setEffectVolume(self.m_soundVolume);

	self.m_musicVolume = self:getMusicVolume();
	-- volume = Sound.getMusicMaxVolume()*self.m_musicVolume;
	Sound.setMusicVolume(self.m_musicVolume);

	self.m_soundToggle = self:getSoundToggle();
	self.m_musicToggle = self:getMusicToggle();
	self.m_chatToggle  = self:getChatToggle();

	self:loadEffect();

	local time_end = os.clock();

	local message = string.format("SoundManager.ctor time start = %f, end = %f, total = %f",time_start,time_end,time_end-time_start );

	sys_set_int("win32_console_color",10);
	print_string(message);
	sys_set_int("win32_console_color",9);
end

SoundManager.dtor = function(self)

end

SoundManager.loadEffect = function(self)
	self.m_phrases = {
		GameString.convert2UTF8("吃"),
		GameString.convert2UTF8("将军"),
        GameString.convert2UTF8("呀！大意失荆州啊！"),
        GameString.convert2UTF8("当局者迷,旁观者清。"),
        GameString.convert2UTF8("观棋不语真君子，落子无悔大丈夫！"),
        GameString.convert2UTF8("急甚，容我--再思量思量."),
        GameString.convert2UTF8("两军相争勇者胜！"),
        GameString.convert2UTF8("你这是, 单车寡炮瞎胡闹啊。"),
        GameString.convert2UTF8("请君，神速些吧！"),
        GameString.convert2UTF8("呵呵!小卒过河赛大车！"),
        GameString.convert2UTF8("一着不慎，满盘皆输！"),
        GameString.convert2UTF8("与你对局，此乃幸事！"),
        GameString.convert2UTF8("再与我对弈一局？")
       }

	self.m_chat_man_map    = {}
	self.m_chat_man_map[self.m_phrases[1]]  = self.m_prefix .. SoundManager.AUDIO_READ_MAN_CHI .. self.m_suffix; --（男）吃
	self.m_chat_man_map[self.m_phrases[2]]  = self.m_prefix .. SoundManager.AUDIO_READ_MAN_JJ  .. self.m_suffix; --（男）将军
	self.m_chat_man_map[self.m_phrases[3]]  = self.m_prefix .. SoundManager.AUDIO_READ_MAN_DYSJZ  .. self.m_suffix; --（男）大意失荆州!
	self.m_chat_man_map[self.m_phrases[4]]  = self.m_prefix .. SoundManager.AUDIO_READ_MAN_DJZMPGZQ  .. self.m_suffix; --（男）当局者迷旁观者清
	self.m_chat_man_map[self.m_phrases[5]]  = self.m_prefix .. SoundManager.AUDIO_READ_MAN_GQBYZJZLZWHDZH  .. self.m_suffix; --（男）观棋不语真君子落子无悔大丈夫.mp3
	self.m_chat_man_map[self.m_phrases[6]]  = self.m_prefix .. SoundManager.AUDIO_READ_MAN_QSRWZSLSL  .. self.m_suffix; --（男）急甚 容我再思量思量.mp3
	self.m_chat_man_map[self.m_phrases[7]]  = self.m_prefix .. SoundManager.AUDIO_READ_MAN_LZXZYZS  .. self.m_suffix; --（男）两军相争勇者胜.mp3
	self.m_chat_man_map[self.m_phrases[8]]  = self.m_prefix .. SoundManager.AUDIO_READ_MAN_DJGPXHL  .. self.m_suffix; --（男）你这是单車寡炮瞎胡闹.mp3
	self.m_chat_man_map[self.m_phrases[9]]  = self.m_prefix .. SoundManager.AUDIO_READ_MAN_QJSSX  .. self.m_suffix; --（男）请君神速些吧.mp3
	self.m_chat_man_map[self.m_phrases[10]] = self.m_prefix .. SoundManager.AUDIO_READ_MAN_XZGHSDJ  .. self.m_suffix; --（男）小卒过河赛大車.mp3
	self.m_chat_man_map[self.m_phrases[11]] = self.m_prefix .. SoundManager.AUDIO_READ_MAN_YZBSMPJS  .. self.m_suffix; --（男）一着不慎满盘皆输.mp3
	self.m_chat_man_map[self.m_phrases[12]] = self.m_prefix .. SoundManager.AUDIO_READ_MAN_YNDJZNXS  .. self.m_suffix; --（男）与你对局此乃幸事.mp3
	self.m_chat_man_map[self.m_phrases[13]] = self.m_prefix .. SoundManager.AUDIO_READ_MAN_ZYWDYYJ  .. self.m_suffix; --（男）再与我对弈一局.mp3
	
	--去掉预加载声音（）
	-- for k,v in pairs(self.m_chat_man_map) do 
	-- 	Sound.preloadEffect(v);
	-- end

	self.m_chat_woman_map  = {}
	self.m_chat_woman_map[self.m_phrases[1]]  = self.m_prefix .. SoundManager.AUDIO_READ_WOMAN_CHI .. self.m_suffix; --（女）吃
	self.m_chat_woman_map[self.m_phrases[2]]  = self.m_prefix .. SoundManager.AUDIO_READ_WOMAN_JJ  .. self.m_suffix; --（女）将军
	self.m_chat_woman_map[self.m_phrases[3]]  = self.m_prefix .. SoundManager.AUDIO_READ_WOMAN_DYSJZ  .. self.m_suffix; --（女）大意失荆州!
	self.m_chat_woman_map[self.m_phrases[4]]  = self.m_prefix .. SoundManager.AUDIO_READ_WOMAN_DJZMPGZQ  .. self.m_suffix; --（女）当局者迷旁观者清
	self.m_chat_woman_map[self.m_phrases[5]]  = self.m_prefix .. SoundManager.AUDIO_READ_WOMAN_GQBYZJZLZWHDZH  .. self.m_suffix; --（女）观棋不语真君子落子无悔大丈夫.mp3
	self.m_chat_woman_map[self.m_phrases[6]]  = self.m_prefix .. SoundManager.AUDIO_READ_WOMAN_QSRWZSLSL  .. self.m_suffix; --（女）急甚 容我再思量思量.mp3
	self.m_chat_woman_map[self.m_phrases[7]]  = self.m_prefix .. SoundManager.AUDIO_READ_WOMAN_LZXZYZS  .. self.m_suffix; --（女）两军相争勇者胜.mp3
	self.m_chat_woman_map[self.m_phrases[8]]  = self.m_prefix .. SoundManager.AUDIO_READ_WOMAN_DJGPXHL  .. self.m_suffix; --（女）你这是单車寡炮瞎胡闹.mp3
	self.m_chat_woman_map[self.m_phrases[9]]  = self.m_prefix .. SoundManager.AUDIO_READ_WOMAN_QJSSX  .. self.m_suffix; --（女）请君神速些吧.mp3
	self.m_chat_woman_map[self.m_phrases[10]] = self.m_prefix .. SoundManager.AUDIO_READ_WOMAN_XZGHSDJ  .. self.m_suffix; --（女）小卒过河赛大車.mp3
	self.m_chat_woman_map[self.m_phrases[11]] = self.m_prefix .. SoundManager.AUDIO_READ_WOMAN_YZBSMPJS  .. self.m_suffix; --（女）一着不慎满盘皆输.mp3
	self.m_chat_woman_map[self.m_phrases[12]] = self.m_prefix .. SoundManager.AUDIO_READ_WOMAN_YNDJZNXS  .. self.m_suffix; --（女）与你对局此乃幸事.mp3
	self.m_chat_woman_map[self.m_phrases[13]] = self.m_prefix .. SoundManager.AUDIO_READ_WOMAN_ZYWDYYJ  .. self.m_suffix; --（女）再与我对弈一局.mp3


	-- for k,v in pairs(self.m_chat_woman_map) do 
	-- 	Sound.preloadEffect(v);
	-- end

	self.m_effect_map = {	}
	self.m_effect_map[SoundManager.AUDIO_BUTTON_CLICK] = self.m_prefix .. SoundManager.AUDIO_BUTTON_CLICK .. self.m_suffix;  --点击菜单 
	self.m_effect_map[SoundManager.AUDIO_CHESS_SELECT] = self.m_prefix .. SoundManager.AUDIO_CHESS_SELECT .. self.m_suffix;   --选择棋子
	self.m_effect_map[SoundManager.AUDIO_DIALOG_SHOW] = self.m_prefix .. SoundManager.AUDIO_DIALOG_SHOW .. self.m_suffix;    --弹出对话框
	self.m_effect_map[SoundManager.AUDIO_EVENT_FAIL] = self.m_prefix .. SoundManager.AUDIO_EVENT_FAIL .. self.m_suffix;     --求和无效认输弹出离开操作音
	self.m_effect_map[SoundManager.AUDIO_GAME_START] = self.m_prefix .. SoundManager.AUDIO_GAME_START .. self.m_suffix;     --游戏开始
	self.m_effect_map[SoundManager.AUDIO_MOVE_CHECK] = self.m_prefix .. SoundManager.AUDIO_MOVE_CHECK .. self.m_suffix;      --将军
	self.m_effect_map[SoundManager.AUDIO_MVOE_CHESS] = self.m_prefix .. SoundManager.AUDIO_MVOE_CHESS .. self.m_suffix;       --落子
	self.m_effect_map[SoundManager.AUDIO_MOVE_EAT] = self.m_prefix .. SoundManager.AUDIO_MOVE_EAT .. self.m_suffix;           --吃子     
	self.m_effect_map[SoundManager.AUDIO_OVER_DRAW] = self.m_prefix .. SoundManager.AUDIO_OVER_DRAW .. self.m_suffix;        --棋局结束 和棋
	self.m_effect_map[SoundManager.AUDIO_OVER_LOSE] = self.m_prefix .. SoundManager.AUDIO_OVER_LOSE .. self.m_suffix;         --棋局结束 输
	self.m_effect_map[SoundManager.AUDIO_OVER_WIN] = self.m_prefix .. SoundManager.AUDIO_OVER_WIN .. self.m_suffix;          --棋局结束 赢
	self.m_effect_map[SoundManager.AUDIO_PAGE_CHANGE] = self.m_prefix .. SoundManager.AUDIO_PAGE_CHANGE .. self.m_suffix;     --切换页面

	self.m_effect_map[SoundManager.AUDIO_MOVE_JAM] = self.m_prefix .. SoundManager.AUDIO_MOVE_JAM .. self.m_suffix;     ----困毙 
	self.m_effect_map[SoundManager.AUDIO_MOVE_KILL] = self.m_prefix .. SoundManager.AUDIO_MOVE_KILL .. self.m_suffix;     --绝杀 
	self.m_effect_map[SoundManager.AUDIO_MOVE_TIMEOUT] = self.m_prefix .. SoundManager.AUDIO_MOVE_TIMEOUT .. self.m_suffix;    --超时; 
	 
	self.m_effect_map[SoundManager.AUDIO_FORESTALL] = self.m_prefix .. SoundManager.AUDIO_FORESTALL .. self.m_suffix;    --让子; 
	self.m_effect_map[SoundManager.AUDIO_UNFORESTALL] = self.m_prefix .. SoundManager.AUDIO_UNFORESTALL .. self.m_suffix;    --不让; 
	self.m_effect_map[SoundManager.AUDIO_HANDICAP_CANNON] = self.m_prefix .. SoundManager.AUDIO_HANDICAP_CANNON .. self.m_suffix;    --让炮; 
	self.m_effect_map[SoundManager.AUDIO_HANDICAP_HORSE] = self.m_prefix .. SoundManager.AUDIO_HANDICAP_HORSE .. self.m_suffix;    --让马; 
	self.m_effect_map[SoundManager.AUDIO_HANDICAP_ROOK] = self.m_prefix .. SoundManager.AUDIO_HANDICAP_ROOK .. self.m_suffix;   --让车;
	 
	self.m_effect_map[SoundManager.AUDIO_CONSOLE_ANIM] = self.m_prefix .. SoundManager.AUDIO_CONSOLE_ANIM .. self.m_suffix;   --单机特效;


	-- for k,v in pairs(self.m_effect_map) do 
	-- 	Sound.preloadEffect(v);
	-- end

end

SoundManager.getInstance = function()
	if not SoundManager.s_instance then
		SoundManager.s_instance = new(SoundManager);
	end

	return SoundManager.s_instance;
end





SoundManager.play_chat = function(self,sex,msg)

	if not self.m_chatToggle then
		print_string("SoundManager.play_chat but not self.m_chatToggle");
		return;
	end
	
	print_string("SoundManager.play_chat " .. msg);

	msg = GameString.convert2UTF8(msg);

	if sex == SEX_MAN then
		if self.m_chat_man_map[msg]  then
			Sound.playEffect(self.m_chat_man_map[msg],false);
		end
	else
		if self.m_chat_woman_map[msg]  then
			Sound.playEffect(self.m_chat_woman_map[msg],false);
		end
	end

end

SoundManager.play_effect = function(self,msg)
	if not self.m_soundToggle then
		print_string("SoundManager.play_effect but not self.m_soundToggle");
		return;
	end

	print_string("SoundManager.play_effect = " .. msg);
	if self.m_effect_map[msg]  then
		print_string("effect  = " .. self.m_effect_map[msg]);
		Sound.playEffect(self.m_effect_map[msg],false);
	end
end
	
SoundManager.playGameBack = function(self)
	-- if Sound.isMusicPlaying() then
	-- 	return;
	-- end
	print_string("SoundManager.playGameBack" );

	if not self.m_game_back then
		self.m_game_back = self.m_prefix .. SoundManager.AUDIO_GAME_BACK .. self.m_suffix;
		Sound.preloadMusic(self.m_game_back);
	end
	Sound.playMusic(self.m_game_back,true);
	--print_string("volume = " .. Sound.getMusicVolume());


	if not self.m_musicToggle or NativeEvent.EventPause then
		print_string("SoundManager.playGameBack but not self.m_musicToggle");
		Sound.pauseMusic();
		return;
	end

end
	
SoundManager.playChessBack = function(self)


	print_string("SoundManager.playChessBack" );

	if not self.m_room_back then
		self.m_room_back = self.m_prefix .. SoundManager.AUDIO_ROOM_BACK .. self.m_suffix;
		Sound.preloadMusic(self.m_room_back);
		print_string("self.m_room_back ==  " .. self.m_room_back);
	end
	Sound.playMusic(self.m_room_back,true);

	if not self.m_musicToggle or NativeEvent.EventPause then
		print_string("SoundManager.playChessBack but not self.m_musicToggle");
		Sound.pauseMusic();
	end
end


SoundManager.setSoundToggle = function(self,soundToggle)
	self.m_soundToggle = soundToggle;
	GameCacheData.getInstance():saveBoolean(GameCacheData.SOUNDTOGGLE,soundToggle);
end

SoundManager.getSoundToggle = function(self)
	self.m_soundToggle = GameCacheData.getInstance():getBoolean(GameCacheData.SOUNDTOGGLE,true);
	return self.m_soundToggle;
end



SoundManager.setMusicToggle = function(self,musicToggle)
	self.m_musicToggle = musicToggle;
	GameCacheData.getInstance():saveBoolean(GameCacheData.MUSICTOGGLE,musicToggle);

	if musicToggle then 
		Sound.resumeMusic();
	else
		Sound.pauseMusic();
	end

end

SoundManager.getMusicToggle = function(self)
	self.m_musicToggle = GameCacheData.getInstance():getBoolean(GameCacheData.MUSICTOGGLE,true);
	return self.m_musicToggle;
end


SoundManager.setChatToggle = function(self,chatToggle)
	self.m_chatToggle = chatToggle;
	GameCacheData.getInstance():saveBoolean(GameCacheData.CHATTOGGLE,chatToggle);
end

SoundManager.getChatToggle = function(self)
	self.m_chatToggle = GameCacheData.getInstance():getBoolean(GameCacheData.CHATTOGGLE,true);
	return self.m_chatToggle;
end



SoundManager.changeSoundVolume = function(self,soundVolume)
	self.m_soundVolume = soundVolume;
	local volume = Sound.getEffectMaxVolume()*soundVolume;
	Sound.setEffectVolume(soundVolume);
end

SoundManager.saveSoundVolume = function(self,soundVolume)
	self.m_soundVolume = soundVolume;
	GameCacheData.getInstance():saveDouble(GameCacheData.SOUNDVOLUME,soundVolume);
	local volume = Sound.getEffectMaxVolume()*soundVolume;
	Sound.setEffectVolume(soundVolume);
end



SoundManager.changeMusicVolume = function(self,musicVolume)
	self.m_musicVolume = musicVolume;
	-- local volume = Sound.getMusicMaxVolume()*musicVolume;

	print_string("SoundManager.saveMusicVolume  " .. musicVolume);
	Sound.setMusicVolume(musicVolume);
end

SoundManager.saveMusicVolume = function(self,musicVolume)
	self.m_musicVolume = musicVolume;
	GameCacheData.getInstance():saveDouble(GameCacheData.MUSICVOLUME,musicVolume);
	-- local volume = Sound.getMusicMaxVolume()*musicVolume;

	print_string("SoundManager.saveMusicVolume  " .. musicVolume);
	Sound.setMusicVolume(musicVolume);
end

SoundManager.getSoundVolume = function(self)
	self.m_soundVolume = GameCacheData.getInstance():getDouble(GameCacheData.SOUNDVOLUME,1.0);
	return self.m_soundVolume;

end


SoundManager.getMusicVolume = function(self)
	self.m_musicVolume = GameCacheData.getInstance():getDouble(GameCacheData.MUSICVOLUME,1.0);
	return self.m_musicVolume;
end
