-- system.lua
-- Author: Vicent Gong
-- Date: 2012-09-30
-- Last modification : 2013-05-30
-- Description: provide basic wrapper for system functions

require("core/constants")
require("core/object")
require("core/res")
--require("core/gameString")

System = class();

System.getResolution = function()
	System.s_resolution = System.s_resolution or sys_get_string("resolution");
	return System.s_resolution;
end

System.getScreenWidth = function()
	System.s_screenWidth = System.s_screenWidth or sys_get_int("screen_width",0);
	return System.s_screenWidth;
end

System.getScreenHeight = function()
	System.s_screenHeight = System.s_screenHeight or sys_get_int("screen_height",0);
	return System.s_screenHeight;
end

System.setLayoutWidth = function(width)
	System.s_layoutWidth = width;
end

System.setLayoutHeight = function(height)
	System.s_layoutHeight = height;
end

System.getLayoutWidth = function(width)
	return System.s_layoutWidth or System.getScreenWidth();
end

System.getLayoutHeight = function(height)
	return System.s_layoutHeight or System.getScreenHeight();
end

System.getLayoutScale = function()
	if not System.s_layoutScale then
		local xScale = System.getScreenWidth() / System.getLayoutWidth();
		local yScale = System.getScreenHeight() / System.getLayoutHeight();
		System.s_layoutScale = xScale>yScale and yScale or xScale;
	end
	return System.s_layoutScale;
end

System.getScreenScaleWidth = function(self)
	if not System.s_screenScaleWidth then
		System.s_screenScaleWidth = System.getScreenWidth() / 
			System.getLayoutScale();
	end

	return System.s_screenScaleWidth;
end

System.getScreenScaleHeight = function(self)
	if not System.s_screenScaleHeight then
		System.s_screenScaleHeight = System.getScreenHeight() / 
			System.getLayoutScale();
	end

	return System.s_screenScaleHeight;
end


System.getPlatform = function()
	System.s_platform = System.s_platform or sys_get_string("platform");
	return System.s_platform;
end

System.getLanguage = function()
	System.s_language = System.s_language or sys_get_string("language");
	return System.s_language;
end

System.getCountry = function()
	System.s_country = System.s_country or sys_get_string("country");
	return System.s_country;
end


System.getFrameRate = function()
	return sys_get_int("frame_rate",0);
end

System.setFrameRate = function(fps)
	return sys_set_double("anim_interval",1.0/(fps or 60.0));
end


System.getResNum = function()
	return sys_get_int("res_num",0);
end

System.getAnimNum = function()
	return sys_get_int("anim_num",0);
end

System.getPropNum = function()
	return sys_get_int("prop_num",0);
end

System.getDrawingNum = function()
	return sys_get_int("drawing_num",0);
end

System.getTextureMemory = function()
	return sys_get_int("texture_alloc",0);
end

System.getTextureSwitchTimes = function()
	return sys_get_int("texture_switch",0);
end

System.getGuid = function()
	return sys_get_string("uuid");
end

System.getAndroidAudioFullFile = function()
	return sys_get_string("android_audio_full_file");
end

System.setAndroidAudioFullFile = function(file)
	return sys_set_string("android_audio_file", file);
end

System.setAndroidLogEnable = function(boolValue)
	return sys_set_int("android_log",boolValue and kTrue or kFalse);
end

System.setSocketLogEnable = function(boolValue)
	return sys_set_int("socket_log_file",boolValue and kTrue or kFalse);
end

System.setAlertErrorEnable = function(boolValue)
	return sys_set_int("alert_error",boolValue and kTrue or kFalse);
end

System.setAndroidLogLuaErrorEnable = function(boolValue)
	return sys_set_int("android_log_lua_error",boolValue and kTrue or kFalse);
end


System.setLuaError = function(strValue)
	return sys_set_string("last_lua_error",strValue);
end

System.getLuaError = function()
	return sys_get_string("last_lua_error");
end

System.setToErrorLuaInWin32Enable = function(boolValue)
	return sys_set_int("to_error_lua_in_win32",boolValue and kTrue or kFalse);
end


System.setClearBackgroundEnable = function(boolValue)
	return sys_set_int("clear_background",boolValue and kTrue or kFalse);
end

System.setDrawImmediatelyAfterTouchdownEnable = function(boolValue)
	return sys_set_int("draw_immediately_after_touchdown",boolValue and kTrue or kFalse);
end

System.setShowImageRectEnable = function(boolValue)
	return sys_set_int("show_image_rect",boolValue and kTrue or kFalse);
end


System.setEventTouchRawEnable = function(boolValue)
	return sys_set_int("event_touch_raw",boolValue and kTrue or kFalse);
end

System.setEventResumeEnable = function(boolValue)
	return sys_set_int("event_resume",boolValue and kTrue or kFalse);
end

System.setEventPauseEnable = function(boolValue)
	return sys_set_int("event_pause",boolValue and kTrue or kFalse);
end

System.setBackpressExitEnable = function(boolValue)
	return sys_set_int("backpress_exit",boolValue and kTrue or kFalse);
end

System.setIgnoreLuaEventReleaseEnable = function(boolValue)
	return sys_set_int("ignore_lua_event_release",boolValue and kTrue or kFalse);
end

System.getTickTime = function()
	return sys_get_int("tick_time",0);
end


System.getWindowsGuid = function()
	return sys_get_string("windows_guid");
end

System.getGuid = function()
	if System.getPlatform() == kPlatformWin32 then
		return sys_get_string("windows_guid");
	else
		return sys_get_string("uuid");
	end
end 


System.setSocketHeaderSize = function(intValue)
	--return sys_set_int("socket_header",intValue or 9);
	--return socket_sys_set_int("socket_header",intValue or 9);
end

System.setSocketHeaderExtSize = function(intValue)
	--return sys_set_int("socket_header_extend",intValue or 0);
end


System.setWin32ConsoleColor = function(color)
	return sys_set_int("win32_console_color",color);
end


System.setWin32TextCode = function(code)
	GameString.setWin32Code(code);
end

System.setDefaultFontNameAndSize = function(fontName, fontSize)
	ResText.setDefaultFontNameAndSize(fontName,fontSize);
end

System.setDefaultTextColor = function(r, g, b)
	ResText.setDefaultColor(r,g,b);
end

System.setDefaultTextAlign = function(align)
	ResText.setDefaultTextAlign(align);
end

System.setImagePathPicker = function(func)
	ResImage.setPathPicker(func);
end

System.setImageFormatPicker = function(func)
	ResImage.setFormatPicker(func);
end

System.setImageFilterPicker = function(func)
	ResImage.setFilterPicker(func);
end

System.setGrayscaleFunc = function(value)
	sys_set_int("grayscale_func", value or 0)
end

-------------------------------------------------
System.getStorageScriptPath = function()
	return sys_get_string("storage_scripts") or "";
end

System.getStorageImagePath = function()
	return sys_get_string("storage_images") or "";
end

System.getStorageAudioPath = function()
	return sys_get_string("storage_audio") or "";
end

System.getStorageFontPath = function()
	return sys_get_string("storage_fonts") or "";
end

System.getStorageXmlPath = function()
	return sys_get_string("storage_xml") or "";
end

System.getStorageUpdatePath = function()
	return sys_get_string("storage_update") or "";
end

System.getStorageDictPath = function()
	return sys_get_string("storage_dic") or "";
end

System.getStorageLogPath = function()
	return sys_get_string("storage_log") or "";
end

System.getStorageUserPath = function()
	return sys_get_string("storage_user") or "";
end

System.getStorageTempPath = function()
	return sys_get_string("storage_temp") or "";
end

System.removeFile = function(filePath)
	dict_set_string("file_op","src_file",filePath);
	return sys_get_int("file_delete",-1) == 0;
end

System.moveFile = function(srcFilePath,destFilePath)
	dict_set_string("file_op","src_file",srcFilePath);
	dict_set_string("file_op","dest_file",destFilePath);
	return sys_get_int("file_copy",-1) == 0;
end

System.getFileSize = function(filePath)
	dict_set_string("file_op","src_file",filePath);
	return sys_get_int("file_size",-1);
end

System.pushFrontImageSearchPath = function(path)
	sys_set_string("push_front_images_path", path);
end

System.pushFrontAudioSearchPath = function(path)
	sys_set_string("push_front_audio_path", path);
end

System.pushFrontFontSearchPath = function(path)
	sys_set_string("push_front_fonts_path", path);
end

System.setUseRomToStorage = function()
	sys_set_int("android_dict_use_external_storage",0);
end
-- by bearluo
System.getStorageUserPath = function()
    return sys_get_string("android_storage_user") or "";
end