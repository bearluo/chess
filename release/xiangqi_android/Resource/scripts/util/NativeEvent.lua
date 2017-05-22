-- NativeEvent.lua
-- 本地事件方法
require("core/constants");
require("config");
require("core/object");
require("core/system");
require("core/dict");
require("core/sound");
require("libs/json_wrap");

NativeEvent = {}

NativeEvent.platform = sys_get_string("platform");


--main 初始化信息
NativeEvent.initGame = function()
	GameString.load("string");
    System.setAnimInterval(1.0/40.0);
	show_fps(kDebug);
	System.setEventResume(true);
	System.setEventPause(true);
	System.setToErrorLuaInWin32(true);
	System.setAndroidLog(true);
	System.setAlertError(false);
    System.setSocketLog(true);

    System.setWin32ConsoleColor(10);
    System.setClearBackground(true);
    sys_set_int("socket_header",14);

	sys_set_int("fps_log_file",kTrue);   --关闭fps日志
end

NativeEvent.onEventCall = function()
 	local callParam = dict_get_string(kcallEvent,kcallEvent);
 	print_string("event_call callParam = " .. callParam);
	EventDispatcher.getInstance():dispatch(Event.Call,callParam);

	if callParam == kOSTimeoutCallback then
		NativeEvent.OSTimeoutCallback();
	end
end

NativeEvent.onWinKeyDown = function(key)

	print_string("NativeEvent.onWinKeyDown:" .. key);
	if key == 81 then -- q 返回键
		NativeEvent.onBackPressed();
	elseif key == 32 then -- 空格键
    	EventDispatcher.getInstance():dispatch(Event.Call,SPACE_KEY);      
	else
		EventDispatcher.getInstance():dispatch(Event.KeyDown,key);
	end

end

NativeEvent.onEventResume = function()
    local str = sys_get_string("platform");
    if "android"==str then
    	local musicToggle = SoundManager.getInstance():getMusicToggle();
		if musicToggle then 
			Sound.resumeMusic();
		else
			Sound.pauseMusic();
		end
    end
    NativeEvent.EventPause = false;
    EventDispatcher.getInstance():dispatch(Event.Resume); 
    NativeEvent.ClearOSTimeout();
end

NativeEvent.onEventPause = function()
    if "android"== NativeEvent.platform then
       	Sound.pauseMusic();
    end 

    NativeEvent.EventPause = true;
    EventDispatcher.getInstance():dispatch(Event.Pause);
    NativeEvent.OSTimeout();
end


NativeEvent.onBackPressed = function()

	sys_set_int("win32_console_color",10);
    print_string("xxxxxxxxxxxxxxxxxxxxxxxxxxxevent_backpressed");
	sys_set_int("win32_console_color",9);

    if lua_multi_click(1) then
    	print_string("xxxxxxxxxxxxxxxxxxxxxxxxxxxevent_backpressed but multi click！！！！");
    	return
    end

    EventDispatcher.getInstance():dispatch(Event.Back);      
end


NativeEvent.eventCall = function(self,callParam , data)
	EventDispatcher.getInstance():dispatch(Event.Call,callParam ,data);
end


-- 设置一个timeout,当其到达时关闭 程序
NativeEvent.TIMEOUT_ID = 1100;
NativeEvent.TIMEOUT_MS = 1000*60*10;
NativeEvent.OSTimeout = function(self)
	print_string("设置 timeout .... id = " .. NativeEvent.TIMEOUT_ID);
	dict_set_int(kOSTimeout,kOSTimeoutId,NativeEvent.TIMEOUT_ID);
	dict_set_int(kOSTimeout,kOSTimeoutMs,NativeEvent.TIMEOUT_MS);
	call_native(kSetOSTimeout);
end

-- 无论timeout是否处理过，都清除
NativeEvent.ClearOSTimeout = function(self)
	print_string("无论timeout是否处理过，都清除...");
	dict_set_int(kOSTimeout,kOSTimeoutId,NativeEvent.TIMEOUT_ID);
	call_native(kClearOSTimeout);
end

-- OSTimeoutCallback 
NativeEvent.OSTimeoutCallback = function()
	print_string("NativeEvent.OSTimeoutCallback");
	local id = dict_get_string(kOSTimeoutCallback, kOSTimeoutCallback .. kResultPostfix);
	id = tonumber(id);
	--print_string("OSTimeoutCallback id:" .. id );当id为nil时会报错
    if id == NativeEvent.TIMEOUT_ID then 
		sys_exit();
    end
    
end
