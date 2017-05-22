require("core/system");

System.getAndroidAudioFullFile = function()
	return sys_get_string("audio_search");
end

System.setAndroidAudioFullFile = function(file)
	return sys_set_string("search_name", file);
end

System.getAudioFullPath = function(self,file)
	sys_set_string("search_name", file);
	return sys_get_string("audio_search");
end

System.setSocketLogEnable = function(boolValue)
	--engine had remove it 
	return sys_set_int("socket_log_file",boolValue and kTrue or kFalse);
end

System.setSocketConnectTimeout = function(millsecond)
	socket_sys_set_int("socket_conn_timeout", millsecond);
end

System.setAndroidLogEnable = function(boolValue)
	return sys_set_int("log",boolValue and kTrue or kFalse);
end

System.setAlertErrorEnable = function(boolValue)
	--engine had remove it 
	--return sys_set_int("alert_error",boolValue and kTrue or kFalse);
end

System.setLuaError = function(strValue)
	--engine had remove it 
	--return sys_set_string("last_lua_error",strValue);
end

System.setToErrorLuaInWin32Enable = function(boolValue)
	--engine had remove it 
	--return sys_set_int("to_error_lua_in_win32",boolValue and kTrue or kFalse);
end

System.setBackpressExitEnable = function(boolValue)
	--engine had remove it 
	--return sys_set_int("backpress_exit",boolValue and kTrue or kFalse);
end

System.setSocketHeaderSize = function(intValue)
	return socket_sys_set_int("socket_header",intValue or 9);
end

System.setSocketHeaderExtSize = function(intValue)
	return socket_sys_set_int("socket_header_extend",intValue or 0);
end

-----------------------------------------------
System.getStorageScriptPath = function()
	return sys_get_string("storage_scripts") .. "/" or "";
end

System.getStorageImagePath = function()
	return sys_get_string("storage_images") .. "/" or "";
end

System.getStorageAudioPath = function()
	return sys_get_string("storage_audio") .. "/" or "";
end

System.getStorageFontPath = function()
	return sys_get_string("storage_fonts") .. "/" or "";
end

System.getStorageXmlPath = function()
	return sys_get_string("storage_xml") .. "/" or "";
end

System.getStorageUpdatePath = function()
	return sys_get_string("storage_update") .. "/" or "";
end

System.getStorageDictPath = function()
	return sys_get_string("storage_dic") .. "/" or "";
end

System.getStorageLogPath = function()
	return sys_get_string("storage_log") .. "/" or "";
end

System.getStorageUserPath = function()
	return sys_get_string("storage_user") .. "/" or "";
end

System.getStorageTempPath = function()
	return sys_get_string("storage_temp") .. "/" or "";
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
System.getStorageRoot = function()
	return "";
end

System.setAndroidLogLuaErrorEnable = function(boolValue)
	return "";
end

System.reLoadFile = function( filename )
	package.loaded[filename] = nil;
	require(filename);
end

System.setIgnoreLuaEventReleaseEnable = function(boolValue)
	return sys_set_int("ignore_lua_event_release",boolValue and kTrue or kFalse);
end
System.getAndroidVersionCode = function()
	return dict_get_int("android_app_info","version_code",0) or 0;
end

System.getAndroidVersionName = function()
	return dict_get_string("android_app_info","version_name") or "";
end

System.getAndroidPackages = function()
	return dict_get_string("android_app_info","packages") or "";
end

System.getAndroidApkPath = function()
	return dict_get_string("android_app_info","apk_path") or "";
end

System.getAndroidLibPath = function()
	return dict_get_string("android_app_info","lib_path") or "";
end

System.getAndroidFilesPath = function()
	return dict_get_string("android_app_info","files_path") or "";
end

System.getAndroidSdPath = function()
	return dict_get_string("android_app_info","sd_path") or "";
end

System.getAndroidLang = function()
	return dict_get_string("android_app_info","lang") or "";
end

System.getAndroidCountry = function()
	return dict_get_string("android_app_info","country") or "";	
end

System.getAndroidDeviceId = function()
	return dict_get_string("android_app_info","device_id") or "";
end

System.getAndroidCache = function()
	return dict_get_string("android_app_info","cache") or "";
end

System.getAndroidRootPath = function()
	return dict_get_string("android_app_info","rootPath") or "";
end

System.getAndroidImsi = function()
	return dict_get_string("android_app_info","imsi") or "";
end

System.getAndroidImei = function()
	return dict_get_string("android_app_info","imei") or "";
end

System.getAndroidIccid = function()
	return dict_get_string("android_app_info","iccid") or "";
end

System.getAndroidPhoneNumber = function()
	return dict_get_string("android_app_info","phoneNumber") or "";
end

System.getAndroidId = function()
	return dict_get_string("android_app_info","androidId") or "";
end

System.getPhoneModel = function()
	return dict_get_string("android_app_info","phoneModel") or "0";
end