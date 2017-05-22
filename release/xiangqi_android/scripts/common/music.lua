require("gameBase/gameSound");
Music = {
    audio_room_back = 1;
    audio_game_back = 2;
};

MusicFileMap = {
    [Music.audio_room_back] = "audio_room_back";
    [Music.audio_game_back] = "audio_game_back";
}
----Effects[""]
Effects = {
    AUDIO_BUTTON_CLICK = 1;   --点击菜单 
    AUDIO_CHESS_SELECT = 2;   --选择棋子
    AUDIO_DIALOG_SHOW = 3;     --弹出对话框
    AUDIO_EVENT_FAIL = 4;       --求和无效认输弹出离开操作音
    AUDIO_GAME_START = 5;       --游戏开始
    AUDIO_MOVE_CHECK = 6;       --将军
    AUDIO_MVOE_CHESS = 7;       --落子
    AUDIO_MOVE_EAT = 8;           --吃子     
    AUDIO_OVER_DRAW = 9;         --棋局结束 和棋
    AUDIO_OVER_LOSE = 10;         --棋局结束 输
    AUDIO_OVER_WIN = 11;           --棋局结束 赢
    AUDIO_PAGE_CHANGE = 12;     --切换页面
    AUDIO_MOVE_JAM = 13;           --困毙 
    AUDIO_MOVE_KILL = 14;         --绝杀 
    AUDIO_MOVE_TIMEOUT = 15;   --超时; 

    AUDIO_FORESTALL    = 16;   --让子; 
    AUDIO_UNFORESTALL = 17;   --不让; 
    AUDIO_HANDICAP_CANNON = 18;   --让炮; 
    AUDIO_HANDICAP_HORSE = 19;   --让马; 
    AUDIO_HANDICAP_ROOK = 20;   --让车; 

    AUDIO_CONSOLE_ANIM = 21; --单机特效
    --聊天语音

    AUDIO_READ_MAN_CHI = 22; --（男）吃
    AUDIO_READ_MAN_JJ = 23; --（男）将军
    AUDIO_READ_MAN_DYSJZ = 24; --（男）大意失荆州!
    AUDIO_READ_MAN_DJZMPGZQ = 25; --（男）当局者迷旁观者清
    AUDIO_READ_MAN_GQBYZJZLZWHDZH = 26; --（男）观棋不语真君子落子无悔大丈夫.mp3
    AUDIO_READ_MAN_QSRWZSLSL = 27; --（男）急甚 容我再思量思量.mp3
    AUDIO_READ_MAN_LZXZYZS = 28; --（男）两军相争勇者胜.mp3
    AUDIO_READ_MAN_DJGPXHL = 29; --（男）你这是单車寡炮瞎胡闹.mp3
    AUDIO_READ_MAN_QJSSX = 30; --（男）请君神速些吧.mp3
    AUDIO_READ_MAN_XZGHSDJ = 31; --（男）小卒过河赛大車.mp3
    AUDIO_READ_MAN_YZBSMPJS = 32; --（男）一着不慎满盘皆输.mp3
    AUDIO_READ_MAN_YNDJZNXS = 33; --（男）与你对局此乃幸事.mp3
    AUDIO_READ_MAN_ZYWDYYJ = 34; --（男）再与我对弈一局.mp3


    AUDIO_READ_WOMAN_CHI = 35; --（女）吃
    AUDIO_READ_WOMAN_JJ = 36; --（女）将军
    AUDIO_READ_WOMAN_DYSJZ = 37; --（女）大意失荆州!
    AUDIO_READ_WOMAN_DJZMPGZQ = 38; --（女）当局者迷旁观者清
    AUDIO_READ_WOMAN_GQBYZJZLZWHDZH = 39; --（女）观棋不语真君子落子无悔大丈夫.mp3
    AUDIO_READ_WOMAN_QSRWZSLSL = 40; --（女）急甚 容我再思量思量.mp3
    AUDIO_READ_WOMAN_LZXZYZS = 41; --（女）两军相争勇者胜.mp3
    AUDIO_READ_WOMAN_DJGPXHL = 42; --（女）你这是单車寡炮瞎胡闹.mp3
    AUDIO_READ_WOMAN_QJSSX = 43; --（女）请君神速些吧.mp3
    AUDIO_READ_WOMAN_XZGHSDJ = 44; --（女）小卒过河赛大車.mp3
    AUDIO_READ_WOMAN_YZBSMPJS = 45; --（女）一着不慎满盘皆输.mp3
    AUDIO_READ_WOMAN_YNDJZNXS = 46; --（女）与你对局此乃幸事.mp3
    AUDIO_READ_WOMAN_ZYWDYYJ = 47; --（女）再与我对弈一局.mp3

    AUDIO_SECOND_TIP = 48;  ----倒计时提醒，木鱼声
}

EffectsFileMap = {
    [Effects.AUDIO_BUTTON_CLICK] = "audio_button_click";
    [Effects.AUDIO_CHESS_SELECT] = "audio_chess_select";
    [Effects.AUDIO_DIALOG_SHOW] = "audio_dialog_show";
    [Effects.AUDIO_EVENT_FAIL] = "audio_event_fail";
    [Effects.AUDIO_GAME_START] = "audio_game_start";
    [Effects.AUDIO_MOVE_CHECK] = "audio_move_check";
    [Effects.AUDIO_MVOE_CHESS] = "audio_move_chess";
    [Effects.AUDIO_MOVE_EAT] = "audio_move_eat";
    [Effects.AUDIO_OVER_DRAW] = "audio_over_draw";
    [Effects.AUDIO_OVER_LOSE] = "audio_over_lose";
    [Effects.AUDIO_OVER_WIN] = "audio_over_win";
    [Effects.AUDIO_PAGE_CHANGE] = "audio_page_change";
    [Effects.AUDIO_MOVE_JAM] = "audio_move_jam";
    [Effects.AUDIO_MOVE_KILL] = "audio_move_kill";
    [Effects.AUDIO_MOVE_TIMEOUT] = "audio_move_timeout";

    [Effects.AUDIO_FORESTALL] = "audio_forestall";
    [Effects.AUDIO_UNFORESTALL] = "audio_unforestall";
    [Effects.AUDIO_HANDICAP_CANNON] = "audio_handicap_cannon";
    [Effects.AUDIO_HANDICAP_HORSE] = "audio_handicap_horse";
    [Effects.AUDIO_HANDICAP_ROOK] = "audio_handicap_rook";

    [Effects.AUDIO_CONSOLE_ANIM] = "audio_console_anim";

    --聊天语音
    [Effects.AUDIO_READ_MAN_CHI] = "audio_read_man_chi";
    [Effects.AUDIO_READ_MAN_JJ] = "audio_read_man_jj";
    [Effects.AUDIO_READ_MAN_DYSJZ] = "audio_read_man_dysjz";
    [Effects.AUDIO_READ_MAN_DJZMPGZQ] = "audio_read_man_djzmpgzq";
    [Effects.AUDIO_READ_MAN_GQBYZJZLZWHDZH] = "audio_read_man_gqbyzjzlzwhdzh";
    [Effects.AUDIO_READ_MAN_QSRWZSLSL] = "audio_read_man_qsrwzslsl";
    [Effects.AUDIO_READ_MAN_LZXZYZS] = "audio_read_man_lzxzyzs";
    [Effects.AUDIO_READ_MAN_DJGPXHL] = "audio_read_man_djgpxhl";
    [Effects.AUDIO_READ_MAN_QJSSX] = "audio_read_man_qjssx";
    [Effects.AUDIO_READ_MAN_XZGHSDJ] = "audio_read_man_xzghsdj";
    [Effects.AUDIO_READ_MAN_YZBSMPJS] = "audio_read_man_yzbsmpjs";
    [Effects.AUDIO_READ_MAN_YNDJZNXS] = "audio_read_man_yndjznxs";
    [Effects.AUDIO_READ_MAN_ZYWDYYJ] = "audio_read_man_zywdyyj";

    [Effects.AUDIO_READ_WOMAN_CHI] = "audio_read_woman_chi";
    [Effects.AUDIO_READ_WOMAN_JJ] = "audio_read_woman_jj";
    [Effects.AUDIO_READ_WOMAN_DYSJZ] = "audio_read_woman_dysjz";
    [Effects.AUDIO_READ_WOMAN_DJZMPGZQ] = "audio_read_woman_djzmpgzq";
    [Effects.AUDIO_READ_WOMAN_GQBYZJZLZWHDZH] = "audio_read_woman_gqbyzjzlzwhdzh";
    [Effects.AUDIO_READ_WOMAN_QSRWZSLSL] = "audio_read_woman_qsrwzslsl";
    [Effects.AUDIO_READ_WOMAN_LZXZYZS] = "audio_read_woman_lzxzyzs";
    [Effects.AUDIO_READ_WOMAN_DJGPXHL] = "audio_read_woman_djgpxhl";
    [Effects.AUDIO_READ_WOMAN_QJSSX] = "audio_read_woman_qjssx";
    [Effects.AUDIO_READ_WOMAN_XZGHSDJ] = "audio_read_woman_xzghsdj";
    [Effects.AUDIO_READ_WOMAN_YZBSMPJS] = "audio_read_woman_yzbsmpjs";
    [Effects.AUDIO_READ_WOMAN_YNDJZNXS] = "audio_read_woman_yndjznxs";
    [Effects.AUDIO_READ_WOMAN_ZYWDYYJ] = "audio_read_woman_zywdyyj";

    [Effects.AUDIO_SECOND_TIP] = "audio_second_tip"
}
EffectsPhrases = {
	["吃"] = 1,
    ["将军"] = 2,
    ["呀！大意失荆州啊！"] = 3,
    ["当局者迷,旁观者清。"] = 4,
    ["观棋不语真君子，落子无悔大丈夫！"] = 5,
    ["急甚，容我--再思量思量."] = 6,
    ["两军相争勇者胜！"] = 7,
    ["你这是, 单车寡炮瞎胡闹啊。"] = 8,
    ["请君，神速些吧！"] = 9,
    ["呵呵!小卒过河赛大车！"] = 10,
    ["一着不慎，满盘皆输！"] = 11,
    ["与你对局，此乃幸事！"] = 12,
    ["再与我对弈一局？"] = 13
}

EffectsSex = {
    AUDIO_READ_CHI = 1;
    AUDIO_READ_JJ = 2;
    AUDIO_READ_DYSJZ = 3;
    AUDIO_READ_DJZMPGZQ = 4;
    AUDIO_READ_GQBYZJZLZWHDZH = 5;
    AUDIO_READ_QSRWZSLSL = 6;
    AUDIO_READ_LZXZYZS = 7;
    AUDIO_READ_DJGPXHL = 8;
    AUDIO_READ_QJSSX = 9;
    AUDIO_READ_XZGHSDJ = 10;
    AUDIO_READ_YZBSMPJS = 11;
    AUDIO_READ_YNDJZNXS = 12;
    AUDIO_READ_ZYWDYYJ = 13;
}

EffectsMan = {

    [EffectsSex.AUDIO_READ_CHI]=  Effects.AUDIO_READ_MAN_CHI; --（男）吃
    [EffectsSex.AUDIO_READ_JJ] = Effects.AUDIO_READ_MAN_JJ; --（男）将军
    [EffectsSex.AUDIO_READ_DYSJZ] = Effects.AUDIO_READ_MAN_DYSJZ; --（男）大意失荆州!
    [EffectsSex.AUDIO_READ_DJZMPGZQ] = Effects.AUDIO_READ_MAN_DJZMPGZQ; --（男）当局者迷旁观者清
    [EffectsSex.AUDIO_READ_GQBYZJZLZWHDZH] = Effects.AUDIO_READ_MAN_GQBYZJZLZWHDZH; --（男）观棋不语真君子落子无悔大丈夫.mp3
    [EffectsSex.AUDIO_READ_QSRWZSLSL] = Effects.AUDIO_READ_MAN_QSRWZSLSL; --（男）急甚 容我再思量思量.mp3
    [EffectsSex.AUDIO_READ_LZXZYZS] = Effects.AUDIO_READ_MAN_LZXZYZS; --（男）两军相争勇者胜.mp3
    [EffectsSex.AUDIO_READ_DJGPXHL] = Effects.AUDIO_READ_MAN_DJGPXHL; --（男）你这是单車寡炮瞎胡闹.mp3
    [EffectsSex.AUDIO_READ_QJSSX] = Effects.AUDIO_READ_MAN_QJSSX; --（男）请君神速些吧.mp3
    [EffectsSex.AUDIO_READ_XZGHSDJ] = Effects.AUDIO_READ_MAN_XZGHSDJ; --（男）小卒过河赛大車.mp3
    [EffectsSex.AUDIO_READ_YZBSMPJS] = Effects.AUDIO_READ_MAN_YZBSMPJS; --（男）一着不慎满盘皆输.mp3
    [EffectsSex.AUDIO_READ_YNDJZNXS] = Effects.AUDIO_READ_MAN_YNDJZNXS; --（男）与你对局此乃幸事.mp3
    [EffectsSex.AUDIO_READ_ZYWDYYJ] = Effects.AUDIO_READ_MAN_ZYWDYYJ; --（男）再与我对弈一局.mp3
};

EffectsWoman = {
    [EffectsSex.AUDIO_READ_CHI] = Effects.AUDIO_READ_WOMAN_CHI; --（女）吃
    [EffectsSex.AUDIO_READ_JJ] = Effects.AUDIO_READ_WOMAN_JJ; --（女）将军
    [EffectsSex.AUDIO_READ_DYSJZ] = Effects.AUDIO_READ_WOMAN_DYSJZ; --（女）大意失荆州!
    [EffectsSex.AUDIO_READ_DJZMPGZQ] = Effects.AUDIO_READ_WOMAN_DJZMPGZQ; --（女）当局者迷旁观者清
    [EffectsSex.AUDIO_READ_GQBYZJZLZWHDZH] = Effects.AUDIO_READ_WOMAN_GQBYZJZLZWHDZH; --（女）观棋不语真君子落子无悔大丈夫.mp3
    [EffectsSex.AUDIO_READ_QSRWZSLSL] = Effects.AUDIO_READ_WOMAN_QSRWZSLSL; --（女）急甚 容我再思量思量.mp3
    [EffectsSex.AUDIO_READ_LZXZYZS] = Effects.AUDIO_READ_WOMAN_LZXZYZS; --（女）两军相争勇者胜.mp3
    [EffectsSex.AUDIO_READ_DJGPXHL] = Effects.AUDIO_READ_WOMAN_DJGPXHL; --（女）你这是单車寡炮瞎胡闹.mp3
    [EffectsSex.AUDIO_READ_QJSSX] = Effects.AUDIO_READ_WOMAN_QJSSX; --（女）请君神速些吧.mp3
    [EffectsSex.AUDIO_READ_XZGHSDJ] = Effects.AUDIO_READ_WOMAN_XZGHSDJ; --（女）小卒过河赛大車.mp3
    [EffectsSex.AUDIO_READ_YZBSMPJS] = Effects.AUDIO_READ_WOMAN_YZBSMPJS; --（女）一着不慎满盘皆输.mp3
    [EffectsSex.AUDIO_READ_YNDJZNXS] = Effects.AUDIO_READ_WOMAN_YNDJZNXS; --（女）与你对局此乃幸事.mp3
    [EffectsSex.AUDIO_READ_ZYWDYYJ] = Effects.AUDIO_READ_WOMAN_ZYWDYYJ; --（女）再与我对弈一局.mp3
};

require("gameBase/gameMusic");
require("gameBase/gameEffect");

kMusicPlayer  = GameMusic.getInstance();
kEffectPlayer = GameEffect.getInstance();

local prefix,extName = "","";
if System.getPlatform() == kPlatformAndroid then
	prefix = "";
	extName = ".ogg";
else
	prefix = "mp3/";
	extName = ".mp3";
end 

Music.getMusicPath = function (  )
	local musicPath = {};
	local filePath = dict_get_string("android_app_info","files_path") or "";
    for i,v in pairs(MusicFileMap) do
     	System.setAndroidAudioFullFile(kMusicPlayer:getPath(i));
       	musicPath[i] = System.getAndroidAudioFullFile();
    end
    return musicPath;
end

Effects.getEffectPath = function (  )
	local effectPath = {};
	local filePath = dict_get_string("android_app_info","files_path") or "";
    for i,v in pairs(EffectsFileMap) do
    	System.setAndroidAudioFullFile(kEffectPlayer:getPath(i));
       	effectPath[i] = System.getAndroidAudioFullFile();
    end
    return effectPath;
end

Effects.setPreloadSoundState = function (hasFinished)
	Effects.PreloadSoundState = hasFinished;
end

Effects.getPreloadSoundState = function()
	return Effects.PreloadSoundState or false;
end

kMusicPlayer:setPathPrefixAndExtName(prefix,extName);
kMusicPlayer:setSoundFileMap(MusicFileMap);
kEffectPlayer:setPathPrefixAndExtName(prefix,extName);
kEffectPlayer:setSoundFileMap(EffectsFileMap);

kMusicPlayer.playHallBg = function()
    kMusicPlayer:preload(Music.audio_game_back);
    kMusicPlayer:play(Music.audio_game_back,true);
end

kMusicPlayer.playRoomBg = function()
    kMusicPlayer:preload(Music.audio_room_back);
    kMusicPlayer:play(Music.audio_room_back,true);
end

kMusicPlayer.play = function(self, index, loop)
    GameMusic.play(self, index, loop);       
    if not SettingInfo.getInstance():getMusicToggle() then
        GameMusic.pause(self);
    end
end

kMusicPlayer.resume = function(self)
    if SettingInfo.getInstance():getMusicToggle() then         
        GameMusic.resume(self); 
    end
end

kEffectPlayer.playEffect = function(self, index, loop)
    if SettingInfo.getInstance():getSoundToggle() then
        GameMusic.play(self, index, loop);
    end	
end

kEffectPlayer.playChat = function(self,sex, index,loop)
    local tmp;
    if sex == SEX_MAN then
       tmp = EffectsMan;
    else
       tmp = EffectsWoman;
    end
    if SettingInfo.getInstance():getChatToggle() then
        GameMusic.play(self, tmp[index], loop);
    end

end