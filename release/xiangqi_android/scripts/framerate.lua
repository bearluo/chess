-- framerate.lua
-- Description: require this lua file to show fps in left-top screen.

require("core/constants");
require("core/system")

local thisGroup=1;
local anim_id_fps = 10;

Framerate = class();

function show_fps(_DEBUG)
	if not _DEBUG then
		return;
	end
	dict_delete("framerate");
	fr = new(Framerate);
	fr:show_fps();
end

Framerate.show_fps = function(self)
	local cc = dict_get_int("framerate","create_anim",-1);
	if cc == -1 then
		dict_set_int("framerate","create_anim",1);
		anim_create_int(thisGroup,anim_id_fps,1,0,1,20,-1);
		anim_set_event2(anim_id_fps,kTrue, self,self.event_anim_framerate);
	end
end

Framerate.event_anim_framerate = function(self,anim_type, anim_id, repeat_or_loop_num )
	local res_id_fps = 10;
	local drawing_id_fps = 10;

	local fr = System.getFrameRate();
	local ta = System.getTextureMemory();
	local ts = System.getTextureSwitchTimes();
	local anim = System.getAnimNum();
	
	local tm = ta/(1024*1024) + 1;
	local strVal = string.format("%dfps %dts %dM %dAnim",fr,ts,tm,anim);
	local cc = dict_get_int("framerate","create_res",-1);
	if cc == -1 then
		dict_set_int("framerate","create_res",res_id_fps);
	else
		res_delete(res_id_fps);
	end
	res_create_text_image(thisGroup,res_id_fps,strVal,240,30,0,0,0,7,"",24,0);
	
	cc = dict_get_int("framerate","create_drawing",-1);
	if cc == -1 then
		dict_set_int("framerate","create_drawing",drawing_id_fps);
        local scale = System:getLayoutScale();
		drawing_create_image2(thisGroup,drawing_id_fps,res_id_fps,0,0,240,30,0,0,0,0,0,0,0,0,0,199);
		drawing_set_parent(drawing_id_fps,0);
	end
	
end


