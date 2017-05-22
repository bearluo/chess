-- Data:2013-9-4
-- Description:程序入口 
-- Note:
require("core/system");
require("core/eventDispatcher");
require("config");
require("core/sceneLoader");
require("core/sound");
require(VIEW_PATH.."error_view");
require("chess/util/statisticsUtil");

function event_load(width,height)

--    socket_close("hall",-1);
--	socket_close("room",-1);
    socket_close_all();
	res_delete_group(-1);
	anim_delete_group(-1);
	prop_delete_group(-1);
	drawing_delete_all();
    System.setLayoutWidth(720);
    System.setLayoutHeight(1280);

	Sound.pauseMusic();
	local errorScene = SceneLoader.load(error_view);
	local errorContent = errorScene:getChildByName("errorContent");
	local str = System.getLuaError();
    sys_set_int("win32_console_color",0xff0000);
	print_string(" error str = "..str);
    if kDebug then
	    errorContent:setText(str);
    else
        report_lua_error(str);
    end

	local errorBtn = errorScene:getChildByName("error_repair_btn");
	errorBtn:setOnClick(nil,function()
		errorBtn:setVisible(false);

		local anim = new(AnimInt , kAnimNormal, 0, 1 ,1, -1);
		anim:setEvent(nil, function()
			delete(anim);
			delete(errorScene);

			to_lua("main.lua");
		end);
	end);
    StatisticsUtil.Log (StatisticsUtil.TYPE_LUA_ERROR,"");
end 

--上报lua错误
function report_lua_error(error)
	print_string("report_lua_error = " .. error);
	dict_set_string(REPORT_LUA_ERROR , REPORT_LUA_ERROR .. kparmPostfix , error);
	call_native(REPORT_LUA_ERROR);

end

function event_touch_raw ( finger_action, x, y, drawing_id)	  
 
end

function event_anim ( anim_type, anim_id, repeat_or_loop_num )
end

function event_pause()
end

function event_resume()
end

function event_backpressed()    
end

function dtor()
	delete(errorScene);
end