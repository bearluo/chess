-- NativeEvent.lua
-- 本地事件方法

require("core/constants");
require("core/object");
require("core/system");
require("coreex/systemex");
require("core/dict");
require("core/sound");
require("libs/json_wrap");
require("common/globalConstant");


NativeEvent = class();
NativeEvent.s_luaCallNavite = "OnLuaCall";
NativeEvent.s_luaCallEvent = "LuaCallEvent";
NativeEvent.s_platform = System.getPlatform();

NativeEvent.getInstance = function()
	if not NativeEvent.s_instance then 
		NativeEvent.s_instance = new(NativeEvent);
	end
	return NativeEvent.s_instance;
end

NativeEvent.onEventCall = function()
	EventDispatcher.getInstance():dispatch(Event.Call,NativeEvent.getInstance():getNativeCallResult());
end

NativeEvent.onWinKeyDown = function(key)
	if key == 81 then
		event_backpressed();
	else
		EventDispatcher.getInstance():dispatch(Event.KeyDown,key);
	end
end

-- 解析 call_native 返回值
NativeEvent.getNativeCallResult = function(self)
	local callParam = dict_get_string(kcallEvent,kcallEvent);
	local callResult = dict_get_int(callParam, kCallResult,-1);

    if callResult == 1 then -- 获取数值失败
        return callParam , false;
    end
    local result = dict_get_string(callParam , callParam .. kResultPostfix);
    dict_delete(callParam);
    local json_data = json.decode_node(result);
    Log.d("NativeEvent.getNativeCallResult callParam = "..callParam.." =========");
    Log.d("NativeEvent.getNativeCallResult result = "..result.." =========");
    --返回错误json格式.
    if json_data then
        Log.d("NativeEvent.getNativeCallResult callParam = "..callParam);
        return callParam ,true, json_data;
    else
        return callParam , true;
    end
end

--/////////////////////////////// android //////////////////////////////////

if NativeEvent.s_platform == kPlatformAndroid or NativeEvent.s_platform == kPlatformIOS then
	-- 公共call_native 方法
	NativeEvent.callNativeEvent = function(self , keyParm , data)
		if data then
			dict_set_string(keyParm,keyParm..kparmPostfix,data);
		end

		dict_set_string(NativeEvent.s_luaCallEvent,NativeEvent.s_luaCallEvent,keyParm);
		call_native(NativeEvent.s_luaCallNavite);
	end
	
    NativeEvent.closeStartDialog = function(self)
        Log.i("CloseStartScreen");
        call_native("CloseStartScreen");
    end

    NativeEvent.showNativeWebView = function(self,x,y,width,height,method)
        Log.i("NativeEvent.showNativeWebView");
        local info = {
            ["x"] = x or 0,
            ["y"] = y or 0,
            ["width"] = width or System.getScreenWidth(),
            ["height"] = height,
            ["url"] = GameData.getInstance():getH5Url() or "null",
            ["uid"] = UserInfo.getInstance():getUid() or "",
            ["method"] = "PlayerCircle.myShare",
        };
        local json_data = json.encode(info);
        dict_set_string(kNativeWebView, kNativeWebView .. kparmPostfix , json_data);
	    call_native(kNativeWebView);
    end

    NativeEvent.showShareWebView = function(self,x,y,width,height)
        Log.i("NativeEvent.showShareWebView");
        local info = {
            ["x"] = x or 0,
            ["y"] = y or 0,
            ["width"] = width or 480,
            ["height"] = height,
            ["url"] = GameData.getInstance():getH5Url() or "null",
            ["uid"] = UserInfo.getInstance():getUid() or "",
            ["method"] = "PlayerCircle.shareCircle",
        };
        local json_data = json.encode(info);
        dict_set_string(kShareWebView, kShareWebView .. kparmPostfix , json_data);
	    call_native(kShareWebView);
    end

    NativeEvent.showCollectWebView = function(self,x,y,width,height)
        Log.i("NativeEvent.showCollectWebView");
        local info = {
            ["x"] = x or 0,
            ["y"] = y or 0,
            ["width"] = width or 480,
            ["height"] = height,
            ["url"] = GameData.getInstance():getH5Url() or "null",
            ["uid"] = UserInfo.getInstance():getUid() or "",
            ["method"] = "PlayerCircle.myCollection",
        };
        local json_data = json.encode(info);
        dict_set_string(kCollectWebView, kCollectWebView .. kparmPostfix , json_data);
	    call_native(kCollectWebView);
    end

    NativeEvent.hideEditTextView = function(self)
        self:callNativeEvent("hideEditTextView");
    end
    NativeEvent.showActivityWebView = function(self,x,y,width,height,url)
        Log.i("NativeEvent.showActivityWebView");
        local info = {
            ["x"] = x or 0,
            ["y"] = y or 0,
            ["width"] = width or 480,
            ["height"] = height,
            ["url"] = url or "null",
            ["uid"] = UserInfo.getInstance():getUid() or "",
            ["method"] = "",
        };
        local json_data = json.encode(info);
        dict_set_string(kActivityWebView, kActivityWebView .. kparmPostfix , json_data);
	    call_native(kActivityWebView);
    end
    
end

--///////////////////////////////// Win32 ////////////////////////////////
if NativeEvent.s_platform ~= kPlatformAndroid and NativeEvent.s_platform ~= kPlatformIOS  then

	NativeEvent.callNativeEvent = function(self , keyParm , data)
		
	end 

    NativeEvent.closeStartDialog = function(self)
        Log.i("CloseStartScreen");
    end
	
    NativeEvent.showShareWebView = function(self,x,y,width,height,method)
        Log.i("showShareWebView");
    end

    NativeEvent.showNativeWebView = function(self,x,y,width,height,method)
        Log.i("showNativeWebView");
    end

    NativeEvent.showCollectWebView = function(self,x,y,width,height,method)
        Log.i("showCollectWebView");
    end

    NativeEvent.showActivityWebView = function(self)
        Log.i("showActivityWebView");
    end
end

