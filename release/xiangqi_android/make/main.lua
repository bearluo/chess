
function event_load(width,height)
	init();
    PhpConfig.setPlatform(APPID,APPKEY,BID,SID,LOGINGTYPE);
    PhpConfig.initURL();
    StateMachine.getInstance():changeState(States.Hall);
end

function event_updated(_,isSucessed)

end

function event_force_updating()

end

function event_ingame_updating()

end

function event_checking()

end

function init()
	require("core/object");
	require("coreex/coreex");
	require("uiex/uiex")
	require("ui/uiConfig");
	require("core/object");
	require("core/system");
	require("core/gameString");
	require("core/stateMachine");
    require("core/eventDispatcher");
	require("core/res");
	require("core/systemEvent");
	require("statesConfig");
	require("ui/toast");
	require("framerate");
    require("util/log4lua");
    require("util/game_cache_data");
    require("config");
    require("common/nativeEvent");
    require("common/music");
    require("UploadDumpFile");
    require(DATA_PATH.."dataPath");
    require(BASE_PATH.."chessDialogScene");
    require(PAY_PATH.."payUtil");
    require("chess/util/statisticsUtil");
    require("chess/util/schemesProxy");
	show_fps(kDebug);--need false
	System.setEventResumeEnable(true);
	System.setEventPauseEnable(true);
	System.setToErrorLuaInWin32Enable(kDebug);--need false
	System.setAndroidLogEnable(kDebug);--need false
	System.setAlertErrorEnable(kDebug);--need false
    System.setSocketLogEnable(kDebug);--need false
   	System.setWin32ConsoleColor(0xffffff);
    System.setClearBackgroundEnable(true);
    System.setLayoutWidth(720);
    System.setLayoutHeight(1280);
    dict_set_int("log","socket",kDebug and 1 or 0);
    ResText.setDefaultFontNameAndSize("AdobeKaitiStd-Regular.otf",24);
    print_string("exitGameFunc------------------------------");
    --System.setSocketConnectTimeout(5000);	
    GameString.load("string","zh");
    System.setFrameRate(40);
end


function exitGameFunc()
	print_string("exitGameFunc------------------------------");
	sys_exit();
end
