
function event_load(width,height)
	init();
    PhpConfig.setPlatform(kAppid,kAppkey,kBid,kSid,kTypePar);
    PhpConfig.initURL();
    StateMachine.getInstance():changeState(States.Hall);
    for _,status in pairs(StatesMap) do
        require(status[1]);
    end
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
    -- 注销所有
    socket_close_all();
	res_delete_group(-1);
	anim_delete_group(-1);
	prop_delete_group(-1);
	drawing_delete_all();
    -- end
	require("core/object");
	require("coreex/coreex");
	require("core/object");
	require("core/system");
	require("core/gameString");
	require("core/stateMachine");
    require("core/eventDispatcher");
	require("core/res");
	require("core/systemEvent");
	require("statesConfig");
	require("framerate");
    require("util/log4lua");
    require("util/game_cache_data");
    require("config");
    require("ui/uiConfig");
    require("uiex/uiex")
    require("ui/toast");
    require("common/nativeEvent");
    require("common/httpModule");
    require("common/music");
    require("UploadDumpFile");
    require(DATA_PATH.."dataPath");
    require(BASE_PATH.."chessDialogScene");
    require(PAY_PATH.."payUtil");
    require("chess/util/statisticsUtil");
    require("chess/util/schemesProxy");
    require("chess/util/timer");
	show_fps(kDebug);--need false
	System.setEventResumeEnable(true);
	System.setEventPauseEnable(true);
	System.setToErrorLuaInWin32Enable(kDebug);--need false
	System.setAndroidLogEnable(kDebug);--need false
	System.setAlertErrorEnable(kDebug);--need false
--    System.setSocketLogEnable(kDebug);--need false
   	System.setWin32ConsoleColor(0xffffff);
    System.setClearBackgroundEnable(true);
    System.setLayoutWidth(720);
    System.setLayoutHeight(1280);
    -- 新socket库日志开关
    dict_set_int("log","socket",kDebug and 1 or 0); 
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
