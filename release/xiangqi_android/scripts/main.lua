
function event_load(width,height)
	init();
    PhpConfig.setPlatform(kAppid,kAppkey,kBid,kSid,kTypePar);
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
    require("config");
    require("util/game_cache_data");
    require("common/nativeEvent");
    require("common/music");
    require("UploadDumpFile");
    require(DATA_PATH.."dataPath");
    require(BASE_PATH.."chessDialogScene");
    require(PAY_PATH.."payUtil");
    require("chess/util/statisticsUtil");
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
    ResText.setDefaultFontNameAndSize("AdobeKaitiStd-Regular.otf",24);
    print_string("exitGameFunc------------------------------");
    --System.setSocketConnectTimeout(5000);
	GameString.load("string","zh");
    System.setFrameRate(40);

--    local upload = new(UploadDumpFile, appid); --appid为应用id
--    upload:setEvent(obj,func); --如果想有自己的回调函数，可以设置，没有则不用管，类似core/http
--    upload:execute(iswifi); --请在wifi网络的情况下调用上传
end


function exitGameFunc()
	print_string("exitGameFunc------------------------------");
	sys_exit();
end
