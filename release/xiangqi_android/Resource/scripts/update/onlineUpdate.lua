require(UPDATE_PATH.."httpFileGrap");
require("util/game_cache_data")
require(DIALOG_PATH.."update_dialog");
--require("gameData/terminalInfo");

OnlineUpdate = class();

OnlineUpdate.UPDATE_MODE_ALL    =  1; 
OnlineUpdate.UPDATE_MODE_PATCH  =  2; 

OnlineUpdate.PKG_TYPE_ERROR     = 0;
OnlineUpdate.PKG_TYPE_APK       = 1;
OnlineUpdate.PKG_TYPE_LUA       = 2;

OnlineUpdate.UPDATE_TYPE_NORMAL = 0;   --可选更新
OnlineUpdate.UPDATE_TYPE_FORCE  = 1;   --强制更新
OnlineUpdate.UPDATE_TYPE_BACK   = 2;   --静默更新

OnlineUpdate.getInstance = function()
	if not OnlineUpdate.s_instance then
		OnlineUpdate.s_instance = new(OnlineUpdate);
	end
	return OnlineUpdate.s_instance;
end

OnlineUpdate.releaseInstance = function(self)
	delete(OnlineUpdate.s_instance);
	OnlineUpdate.s_instance = nil;
end

OnlineUpdate.ctor = function(self)
    self.m_update_chioce_dialog = new(UpdateDialog);
    self.m_update_chioce_dialog:setLevel(1);
    self.m_suffix = "";
end

OnlineUpdate.dtor = function(self)
    delete(self.m_update_chioce_dialog);
end

--标记是否需要提醒用户安装
OnlineUpdate.setInstallUpdate = function(self,flag)
    self.m_installUpdate = flag;
end

OnlineUpdate.getInstallUpdate = function(self)
    return self.m_installUpdate;
end

OnlineUpdate.setUpdateData = function(self,updateData)
    self.mUpdateData = updateData;
end

OnlineUpdate.getUpdateData = function(self)
    if not self.isOnBackDownload then
        return self.mUpdateData;
    end
end

OnlineUpdate.showUpdateDialog = function(self)
    if self.m_update_chioce_dialog and not self.m_update_chioce_dialog:isShowing() then
        self.m_update_chioce_dialog:show();
    end
end

OnlineUpdate.dismissUpdateDialog = function(self)
    if self.m_update_chioce_dialog and self.m_update_chioce_dialog:isShowing() then
        self.m_update_chioce_dialog:dismiss();
    end
end

OnlineUpdate.setMode = function(self,mode,isDownLoad)
    self.mUpdataType = mode or self.mUpdataType or OnlineUpdate.UPDATE_TYPE_NORMAL;
    if not self.m_update_chioce_dialog then return end;
    if self.mUpdataType == OnlineUpdate.UPDATE_TYPE_FORCE then
        self.m_update_chioce_dialog:setNeedBackEvent(false);
        self.m_update_chioce_dialog:setNegativeListener(self,self.onSysExit);
    else
        self.m_update_chioce_dialog:setNeedBackEvent(true);
        self.m_update_chioce_dialog:setNegativeListener(self.m_update_chioce_dialog,self.m_update_chioce_dialog.dismiss);
    end
    self.m_update_chioce_dialog:setPositiveListener(self,function()
            HttpFileGrap.getInstance():reset();
            self:startDownloadApk(false);
        end);
	self.m_update_chioce_dialog:setData(self.mUpdateData);

    if self.mUpdataType == OnlineUpdate.UPDATE_TYPE_FORCE then
        self.m_update_chioce_dialog:setMode(UpdateDialog.MODE_FORCE,nil,nil,isDownLoad);
    elseif self.mUpdataType == OnlineUpdate.UPDATE_TYPE_BACK then
        self.m_update_chioce_dialog:setMode(UpdateDialog.MODE_BACK,nil,nil,isDownLoad);
    else
        self.m_update_chioce_dialog:setMode(UpdateDialog.MODE_NORMAL,nil,nil,isDownLoad);
    end
end

OnlineUpdate.startDownloadApk = function(self,needPause)
    needPause = needPause or false;
    if self.mUpdateData and self.mUpdateData.pkgFile then
        local url = self.mUpdateData.pkgFile.url;
        local hash = self.mUpdateData.pkgFile.hash;
        self.m_update_chioce_dialog:downLoadApk();
        HttpFileGrap.getInstance():grapApkFile(
	    	        url,
			        self.mDownloadFile,
			        3000,
			        self,
			        self.onGrapResponse,
                    self.updatePeriod,
                    needPause,
                    20,
                    hash);
    end
end

function OnlineUpdate.errorDate(self)
    GameCacheData.getInstance():saveString(GameCacheData.FORCEUPDATE,"");
end

--[Comment]
-- params:
--         pkgType     包类型
--         updateMode  更新类型
-- return:
--        .zip|.apk|.patch
function OnlineUpdate.getFileSuffix(pkgType,updateMode)
    if pkgType == OnlineUpdate.PKG_TYPE_LUA then
        return ".zip";
    elseif pkgType == OnlineUpdate.PKG_TYPE_APK then
        if updateMode == OnlineUpdate.UPDATE_MODE_ALL then
            return ".apk";
        elseif updateMode == OnlineUpdate.UPDATE_MODE_PATCH then
            return ".patch";
        end
    end
    return "";
end

--[Comment]
--return true is background update
OnlineUpdate.onCheckUpdate = function(self,message)
    local data = message.data;
    if not data then return true end

    local json_order = json.encode(json.analyzeJsonNode(data));
    GameCacheData.getInstance():saveString(GameCacheData.FORCEUPDATE,json_order);

	local updataType       = tonumber(data.update_type:get_value()) or 0;
    local updateMode       = tonumber(data.update_mode:get_value()) or 0;
    local pkgType          = tonumber(data.pkg_type:get_value())or 0;
    local desc              = data.desc:get_value() or "";
    local title             = data.title:get_value() or "";
    local pkgVersion       = data.pkg_version:get_value() or "";
    local pkgFile          = {};
    pkgFile.hash           = data.pkg_file.hash:get_value() or "";
    pkgFile.size           = tonumber(data.pkg_file.size:get_value()) or 0;
    pkgFile.url            = data.pkg_file.url:get_value() or "";
    pkgFile.time           = data.pkg_file.time:get_value() or 0;

    if pkgType == OnlineUpdate.PKG_TYPE_ERROR  then 
        self:errorDate();
        return true;
    end -- 数据错误

    self.mUpdateData = {};
	self.mUpdateData.updataType         = updataType
    self.mUpdateData.updateMode         = updateMode
    self.mUpdateData.pkgType            = pkgType
    self.mUpdateData.desc               = desc
    self.mUpdateData.title              = title
    self.mUpdateData.pkgVersion         = pkgVersion
    self.mUpdateData.pkgFile            = pkgFile;
    self.mUpdateData.downloadFileName   = md5_string(pkgFile.url);
    
    local ret = true;
	if tonumber(updataType) == 1 then
		self.mUpdataType = OnlineUpdate.UPDATE_TYPE_FORCE;
        ret = false;
	elseif tonumber(updataType) == 2 then
        self.mUpdataType = OnlineUpdate.UPDATE_TYPE_BACK;
        ret = true;
    else
		self.mUpdataType = OnlineUpdate.UPDATE_TYPE_NORMAL;
        ret = true;
	end
    self.m_suffix = OnlineUpdate.getFileSuffix(pkgType,updateMode);
    if self.m_suffix == "" then 
        self:errorDate();
        return true;
    end

    self.mDownloadFile = GameData.getInstance():getSaveFileUrl()..self.mUpdateData.downloadFileName..self.m_suffix;
    --判断是否已经将包下载完毕
    if HttpFileGrap.getInstance():exitApkFile(self.mDownloadFile) then
        self:setMode(self.mUpdataType,true);
        self:showUpdateDialog();
        return ret;
    end
    self:setMode(self.mUpdataType,false);

    --静默更新
    if self.mUpdataType == OnlineUpdate.UPDATE_TYPE_BACK then
        OnlineUpdate.getInstance():setUpdateData(self.mUpdateData);
        self:startDownloadApk(true);
        self.isOnBackDownload = true;
        return true;
    end

    --其他情况
    self:showUpdateDialog();

    return ret;
end

OnlineUpdate.onUpdate = function(self)
    if self.mUpdateData then
        self:showUpdateDialog();
    end
end


OnlineUpdate.updatePeriod = function(self,period)
    self.m_update_chioce_dialog:updatePeriod(period);
end

OnlineUpdate.onGrapResponse = function(self,isSuccess,resultReason)
    self.isOnBackDownload = false;
    if not isSuccess then
        self.m_update_chioce_dialog:onFail(resultReason);
        self.m_update_chioce_dialog:setPositiveListener(self,function()
            HttpFileGrap.getInstance():reset();
            self:startDownloadApk(false);
        end);
        return ;
    end

    self.m_update_chioce_dialog:onSuccess(resultReason);
    if self.m_update_chioce_dialog:isShowing() or self.m_suffix == ".zip" then
        self:onApkInstall(true);
    else
        OnlineUpdate.getInstance():setInstallUpdate(true);
    end
end

OnlineUpdate.onSysExit = function(self)
    local line = "quit";
	dict_set_string(GUI_ENGINE , GUI_ENGINE .. kparmPostfix , line);
	call_native(GUI_ENGINE);
    sys_exit();
end

OnlineUpdate.onApkInstall = function(self,isDownSuccessCallBack)
    if self.m_suffix == "" then 
        return ;
    elseif self.m_suffix == ".zip" then
        if isDownSuccessCallBack then
            StatisticsManager.getInstance():onCountToUM("hotupdate","zip");
            dict_set_string("patchUpdate","newLuaPath",self.mDownloadFile);
	        if System.getPlatform() == kPlatformAndroid then
		        Log.i("UpdateDialog.installUpdate luacall! patch");
		        call_native("LuaInstall");
	        end
        else
            to_lua("main.lua")
        end
    elseif self.m_suffix == ".apk" then
        StatisticsManager.getInstance():onCountToUM("hotupdate","apk");
        dict_set_string("patchUpdate","newApkPath",self.mDownloadFile);
	    if System.getPlatform() == kPlatformAndroid then
		    Log.i("UpdateDialog.installUpdate luacall! apk");
		    call_native("ApkInstall");
	    end
    elseif self.m_suffix == ".patch" then
        StatisticsManager.getInstance():onCountToUM("hotupdate","patch");
        dict_set_string("patchUpdate","newPatchPath",self.mDownloadFile);
	    if System.getPlatform() == kPlatformAndroid then
		    Log.i("UpdateDialog.installUpdate luacall! patch");
		    call_native("PatchInstall");
	    end
    end
end

OnlineUpdate.eventInstallApk = function(self,result)
    Log.i("OnlineUpdate.install_apk callback!!" .. result);
    if self.m_suffix == "" then 
        return ;
    elseif self.m_suffix == ".zip" then
        if result == -1 then
            local resultReason = "更新文件解压失败";
            self.m_update_chioce_dialog:onFail(resultReason);
            self.m_update_chioce_dialog:setPositiveListener(self,function()
                HttpFileGrap.getInstance():reset();
                self:startDownloadApk(false);
            end);
            StatisticsManager.getInstance():onCountToUM("hotupdate_fail","zip");
        elseif result == 1 then
            StatisticsManager.getInstance():onCountToUM("hotupdate_success","zip");
            if self.mUpdataType ~= OnlineUpdate.UPDATE_TYPE_BACK then
                to_lua("main.lua");
            end
        end
    elseif self.m_suffix == ".apk" then
        if result == -1 then
            StatisticsManager.getInstance():onCountToUM("hotupdate_fail","apk");
        elseif result == 1 then
            StatisticsManager.getInstance():onCountToUM("hotupdate_success","apk");
        end
    elseif self.m_suffix == ".patch" then
        if result == -1 then
            StatisticsManager.getInstance():onCountToUM("hotupdate_fail","patch");
        elseif result == 1 then
            StatisticsManager.getInstance():onCountToUM("hotupdate_success","patch");
        end
    end
end

function event_install_apk()
	local result = dict_get_int("patchUpdate","result", -1);
    OnlineUpdate.getInstance():eventInstallApk(result);
end
