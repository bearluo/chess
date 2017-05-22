
--require("view/Android_800_480/chioce_dialog_view");
require(VIEW_PATH .. "update_dialog_view");
require(BASE_PATH.."chessDialogScene");
require(UPDATE_PATH.."httpFileGrap");
require(DATA_PATH.."gameData");

UpdateDialog = class(ChessDialogScene,false);

UpdateDialog.MODE_NORMAL = 0;   --可选更新
UpdateDialog.MODE_FORCE  = 1;   --强制更新
UpdateDialog.MODE_BACK   = 2;   --静默更新

UpdateDialog.ctor = function(self)
    super(self,update_dialog_view);
    self:setLevel(ChessDialogScene.kHttpForceLevel);
	self.m_root_view = self.m_root;
	self.m_content_view = self.m_root_view:getChildByName("content_view");
    self.m_desc_view = self.m_content_view:getChildByName("desc_bg"):getChildByName("desc_view");
    self.m_desc_view_bg = self.m_content_view:getChildByName("desc_bg");
	self.m_cancel_btn = self.m_content_view:getChildByName("cancel_btn");
	self.m_sure_btn = self.m_content_view:getChildByName("sure_btn");
	self.m_sure_texture = self.m_sure_btn:getChildByName("sure_text");
	self.m_cancel_texture = self.m_cancel_btn:getChildByName("cancel_text");

    self.m_title = self.m_content_view:getChildByName("title");
    self.m_packgeSize = self.m_content_view:getChildByName("packgeSize");

    self.m_loading_view = self.m_content_view:getChildByName("loading_view");
    self.m_period_bar = self.m_loading_view:getChildByName("bar_bg"):getChildByName("period_bar");
    self.m_max_w = self.m_period_bar:getSize();
    self.m_period_text = self.m_loading_view:getChildByName("period_text");

	self.m_cancel_btn:setOnClick(self,self.cancel);
	self.m_sure_btn:setOnClick(self,self.sure);

    self.m_fail_text = self.m_content_view:getChildByName("fail_text");
    self.m_qq_text = self.m_fail_text:getChildByName("qq_text");
    self:reset();
    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)
end

UpdateDialog.reset = function(self) 
    self.m_cancel_btn:setVisible(false);
	self.m_sure_btn:setVisible(false);
    self.m_packgeSize:setVisible(false);
    self.m_loading_view:setVisible(false);
    self.m_fail_text:setVisible(false);
    self.m_desc_view_bg:setVisible(true);
end

UpdateDialog.dtor = function(self)
    self.mDialogAnim.stopAnim()
    delete(self.m_root_view);
	self.m_root_view = nil;
end

UpdateDialog.isShowing = function(self)
	return self:getVisible();
end

UpdateDialog.onTouch = function(self)
	print_string("UpdateDialog.onTouch");
end

UpdateDialog.show = function(self)
	print_string("UpdateDialog.show ... ");
	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
--    if self.m_mode == UpdateDialog.MODE_FORCE and TerminalInfo.getInstance():getNetWorkType() == 1 then
--        self:downLoadApk();
--    end
    self.super.show(self,self.mDialogAnim.showAnim);
end

function UpdateDialog.setVisible(self,flag)
    self.super.setVisible(self,flag)
end

UpdateDialog.dismiss = function(self)
    self.super.dismiss(self,self.mDialogAnim.dismissAnim)
end

UpdateDialog.cancel = function(self)
	print_string("UpdateDialog.cancel ");
	self:dismiss();
	if self.m_negObj and self.m_negFunc then
		self.m_negFunc(self.m_negObj);
	end
end

UpdateDialog.sure = function(self)
	print_string("UpdateDialog.sure ");

--	self:dismiss();
	if self.m_posObj and self.m_posFunc then
		self.m_posFunc(self.m_posObj);
	end
end

UpdateDialog.downLoadApk = function(self)
    --页面处理
    self.m_loading_view:setVisible(true);
    self.m_packgeSize:setVisible(false);
    self.m_fail_text:setVisible(false);
    self.m_desc_view_bg:setVisible(true);
--    local _,y = self.m_message:getPos();
--    self.m_message:setPos(0,y+40);
    self.m_message:setVisible(true);
    self.m_title:setText("正在下载更新包");

    self.m_cancel_btn:setVisible(false);
	self.m_sure_btn:setVisible(false);

    self:updatePeriod(0);

end

UpdateDialog.setData = function(self,data)
    self.m_data = data;
    local w,h = self.m_desc_view:getSize();
    delete(self.m_message);
    self.m_message = new(TextView,self.m_data.desc,w,nil,kAlignTopLeft,nil,28,80,80,80);
    self.m_desc_view:addChild(self.m_message);
    self.m_message:setAlign(kAlignTop);
--    self.m_message:setPos(0,95);
    local mw,mh = self.m_message:getSize();
    if mh >= h then
        self.m_message:setSize(nil,h);
        mh = 170;
    end
    self.m_package_version = self.m_data.pkgVersion;
    
    if self.m_data.pkgFile.size then
        local sizeText = "B";
        local size = self.m_data.pkgFile.size;
        if size > 1024 then
            sizeText = "KB";
            size = size / 1024;
        end
        if size > 1024 then
            sizeText = "MB";
            size = size / 1024;
        end
        if size > 1024 then
            sizeText = "GB";
            size = size / 1024;
        end
        self.m_packgeSize:setText("此次下载，预计需要".. size .. sizeText .. "流量");
        self.m_packgeSize:setVisible(true);
        self.m_packgeSize:setPos(0,105+h);
    end
end

UpdateDialog.setMode = function(self,mode,sure_str,cancel_str,isDownLoad)
    self:reset();
	self.m_mode = mode;
    local sure_text = "";
    local cancel_text = "";
	if self.m_mode == UpdateDialog.MODE_FORCE then
        self:setNeedBackEvent(false);
        if isDownLoad then
            sure_text = sure_str or "立即体验";
		    cancel_text = cancel_str or "退出游戏";
            self.m_title:setText("新版本已准备好("..self.m_data.pkgVersion..")");
            self.m_packgeSize:setVisible(false);
            self:setPositiveListener(OnlineUpdate.getInstance(),OnlineUpdate.onApkInstall);
        else
            sure_text = sure_str or "确定";
		    cancel_text = "退出游戏";
            self.m_title:setText("需要先更新游戏");
        end
    else
        self:setNeedBackEvent(true);
        if isDownLoad then
            sure_text = sure_str or "立即体验";
		    cancel_text = cancel_str or "以后再说";
            self.m_title:setText("新版本已准备好("..self.m_data.pkgVersion..")");
            self.m_packgeSize:setVisible(false);
            self:setPositiveListener(OnlineUpdate.getInstance(),OnlineUpdate.onApkInstall);
        else
            sure_text = sure_str or "下载体验";
		    cancel_text = cancel_str or "以后再说";
            self.m_title:setText(self.m_data.title.."("..self.m_data.pkgVersion..")");
        end
	end
    self.m_cancel_texture:setText(cancel_text);
    self.m_sure_texture:setText(sure_text);
    self.m_cancel_btn:setVisible(true);
	self.m_sure_btn:setVisible(true);
end

UpdateDialog.updatePeriod = function(self,period)
    local barSize = self.m_max_w*(period/100);
    self.m_period_bar:setSize(barSize);
    self.m_period_text:setText(period.."%");
end

UpdateDialog.onFail = function(self,resultReason)
    self:setMode(self.m_mode,"重新下载","取消");
    self.m_title:setText("下载失败");
    self.m_fail_text:setText("下载失败，请检查网络后重试("..resultReason..")");
    self.m_fail_text:setVisible(true);
    self.m_desc_view_bg:setVisible(false);
    self.m_qq_text:setText(UserInfo.getInstance():getQQGroupString());
    self.m_loading_view:setVisible(false);
    self.m_message:setVisible(false);
end

UpdateDialog.onSuccess = function(self,resultReason)
    self.m_loading_view:setVisible(false);
    self.m_packgeSize:setVisible(false);
    self:setMode(self.m_mode,nil,nil,true);
end

UpdateDialog.setPositiveListener = function(self,obj,func)
	self.m_posObj = obj;
	self.m_posFunc = func;
end


UpdateDialog.setNegativeListener = function(self,obj,func)
	self.m_negObj = obj;
	self.m_negFunc = func;
end