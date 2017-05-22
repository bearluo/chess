require(UPDATE_PATH.."httpFileGrap");
require("util/game_cache_data")
--require("gameData/terminalInfo");

OnlineUpdate = class();

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
    require(DIALOG_PATH.."update_dialog");
    self.m_update_chioce_dialog = new(UpdateDialog);
    self.m_update_chioce_dialog:setLevel(1);
    self.isOnBackDownload = false; -- 是否是第一次启动wifi 情况 后台下载
end

OnlineUpdate.dtor = function(self)
    delete(self.m_update_chioce_dialog);
end

OnlineUpdate.getUpdateData = function(self)
    return self.m_updateData;
end

OnlineUpdate.getUpdateDialog = function(self)
    return self.m_update_chioce_dialog;
end

OnlineUpdate.showUpdateDialog = function(self)
    if self.m_update_chioce_dialog and not self.m_update_chioce_dialog:isShowing() then
        if self.isOnBackDownload then
            self:setMode(self.m_mode,false);
        end
        self.isOnBackDownload = false;
        self.m_update_chioce_dialog:show();
    end
end

OnlineUpdate.dimissUpdateDialog = function(self)
    if self.m_update_chioce_dialog and self.m_update_chioce_dialog:isShowing() then
        self.m_update_chioce_dialog:dismiss();
    end
end

OnlineUpdate.setMode = function(self,mode,isDownLoad)
    self.m_mode = mode or self.m_mode or UpdateDialog.MODE_NORMAL;
    if not self.m_update_chioce_dialog then return end;
    if self.m_mode == UpdateDialog.MODE_FORCE then
        self.m_update_chioce_dialog:setClickCallBack(false);
        self.m_update_chioce_dialog:setNegativeListener(self,self.onSysExit);
    else
        self.m_update_chioce_dialog:setClickCallBack(true);
        self.m_update_chioce_dialog:setNegativeListener(self.m_update_chioce_dialog,self.m_update_chioce_dialog.dismiss);
    end
    self.m_update_chioce_dialog:setPositiveListener(self,function()
            HttpFileGrap.getInstance():reset();
            self:startDownloadApk(false);
        end);
	self.m_update_chioce_dialog:setData(self.m_updateData);
    self.m_update_chioce_dialog:setMode(self.m_mode,nil,nil,isDownLoad);
end

OnlineUpdate.startDownloadApk = function(self,needPause)
    needPause = needPause or false;
    if GameData.getInstance():getUpdateUrl() and self.m_updateData then
        self.m_update_chioce_dialog:downLoadApk();
        HttpFileGrap.getInstance():grapApkFile(
	    	        GameData.getInstance():getUpdateUrl(),
			        self.m_apkFile,
			        3000,
			        self,
			        self.onGrapResponse,
                    self.updatePeriod,
                    needPause,
                    20,
                    self.m_updateData.md5_check);
    end
end


OnlineUpdate.onCheckUpdate = function(self,data)
    require("dialog/update_dialog");
    self.m_updateData = {};
	local updata_type = tonumber(data.type:get_value());
--    updata_type = 1;--测试强制升级
	local url = data.url:get_value();
    self.m_updateData.type = updata_type;
	self.m_updateData.desc = data.desc:get_value();
	self.m_updateData.content = data.content:get_value();
    self.m_updateData.package_size = data.package_size:get_value();
    self.m_updateData.title = data.title:get_value();
    self.m_updateData.package_version = data.package_version:get_value();
    self.m_updateData.md5_check = data.md5_check:get_value();
    self.m_updateData.url = data.url:get_value();

--	self.m_check_url = "http://jd.oa.com/apk/2015/08/chess-1.9.6-preview-main-188-20150820.apk";
    self.m_check_url = data.url:get_value();
	self.m_update_type = updata_type .. "";
    self.m_apkFile = "";
    GameData.getInstance():setUpdateUrl(self.m_check_url);

	self.m_mode = UpdateDialog.MODE_NORMAL;
	if updata_type and tonumber(updata_type) == 1 then
		self.m_mode = UpdateDialog.MODE_FORCE;
	else
		UserInfo.getInstance():setCheckVersion(true);
		if UserInfo.getInstance():getTid()~=0 then
			print_string("Hall.explainGetResult but tid ~= 0");
			return;
		end
	end
    local json_order = json.encode(self.m_updateData);
    GameCacheData.getInstance():saveString(GameCacheData.FORCEUPDATE,json_order);
    self.m_apkFile = GameData.getInstance():getSaveFileUrl()..self.m_updateData.package_version..".apk";
    --判断是否已经将包下载完毕
    if HttpFileGrap.getInstance():exitApkFile(self.m_apkFile) then
--        self:onShowUpdateDialog(true);
        self:setMode(self.m_mode,true);
        self:showUpdateDialog();
        return;
    else
        self:setMode(self.m_mode,false);
    end
    --可选更新（且WIFI环境下,后台下载）
    if self.m_mode == UpdateDialog.MODE_NORMAL and TerminalInfo.getInstance():getNetWorkType() == 1 then
        GameData.getInstance():setUpdateData(self.m_updateData);
        self:startDownloadApk(true);
        self.isOnBackDownload = true;
        return;
    end

    --其他情况
    self:showUpdateDialog();
end

OnlineUpdate.onUpdate = function(self)
    self:showUpdateDialog();
end


OnlineUpdate.updatePeriod = function(self,period)
    self.m_update_chioce_dialog:updatePeriod(period);
end

OnlineUpdate.onGrapResponse = function(self,isSuccess,resultReason)
    if not isSuccess then
        if self.isOnBackDownload then
            self.isOnBackDownload = false;
            self:setMode(self.m_mode,false);
            return ;
        end
    end
    self.isOnBackDownload = false;
    self.m_isSuccess = isSuccess;
    self.m_update_chioce_dialog:onGrapResponse(isSuccess,resultReason);
end

OnlineUpdate.onSysExit = function(self)
    local line = "quit";
	dict_set_string(GUI_ENGINE , GUI_ENGINE .. kparmPostfix , line);
	call_native(GUI_ENGINE);
    sys_exit();
end

function event_install_apk()
	local result = dict_get_int("patchUpdate","result", -1);
	Log.i("OnlineUpdate.install_apk callback!!" .. result);
end
