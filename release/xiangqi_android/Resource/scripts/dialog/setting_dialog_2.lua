require(VIEW_PATH .. "setting_dialog_view_2");
require(BASE_PATH.."chessDialogScene");
require(DATA_PATH.."settingInfo");
SettingDialog2 = class(ChessDialogScene,false);

SettingDialog2.step = 0.1;   --每次加减声音的大小
SettingDialog2.max  = 1.0;   --最大音量
SettingDialog2.min  = 0.0;    -- 最小音量



SettingDialog2.ctor = function(self)
    super(self,setting_dialog_view_2);
    self:setShieldClick(self,self.dismiss)
	self.mBg = self.m_root:getChildByName("bg");
    self.mBg:setEventTouch(self,function()end);

    local slider = self.mBg:getChildByName("effect_view"):getChildByName("slider")
    local width, height = slider:getSize()
    self.mEffectSlider = new(Slider,width, height, "ui/sliderBg3.png", "ui/sliderFg3.png", "ui/sliderBtn3.png",21, 21)
    self.mEffectSlider.m_button:setSize(60,60)
    slider:addChild(self.mEffectSlider)

    
    local slider = self.mBg:getChildByName("music_view"):getChildByName("slider")
    local width, height = slider:getSize()
    self.mMusicSlider = new(Slider,width, height, "ui/sliderBg3.png", "ui/sliderFg3.png", "ui/sliderBtn3.png",21, 21)
    self.mMusicSlider.m_button:setSize(60,60)
    slider:addChild(self.mMusicSlider)

	self.mEffectSlider:setOnChange(self,self.soundChange);
	self.mMusicSlider:setOnChange(self,self.musicChange);

    self.mChatToggle = self.mBg:getChildByName("chat_toggle_view"):getChildByName("toggle_view"):getChildByName("toggle_btn")
    self.mVibrateToggle = self.mBg:getChildByName("vibrate_toggle_view"):getChildByName("toggle_view"):getChildByName("toggle_btn")
    self.mDarkToggle = self.mBg:getChildByName("dark_toggle_view"):getChildByName("toggle_view"):getChildByName("toggle_btn")

    self.mChatToggle:setOnClick(self,self.onChatToggleClick);
    self.mVibrateToggle:setOnClick(self,self.onVibrateToggleClick);
    self.mDarkToggle:setOnClick(self, self.onDarkToggleClick);

    local clear_cache_view = self.mBg:getChildByName("clear_cache_view")
    clear_cache_view:getChildByName("clear_cache_btn"):setOnClick(self,function()
        if not self.m_loading_dialog then
		    self.m_loading_dialog = new(LoadingDialog)
            self.m_loading_dialog:setMaskDialog(true)
	    end
        local time = 2
        local message = "清理中"
	    self.m_loading_dialog:setMessage(message)
	    self.m_loading_dialog:show(time)
        CacheImageManager.clearCache()
    end)

    self.mClearCacheTxt = clear_cache_view:getChildByName("clear_cache_txt")
    
    local update_version_view = self.mBg:getChildByName("update_version_view")
    update_version_view:getChildByName("update_version_btn"):setOnClick(self,function()
        OnlineUpdate.getInstance():onUpdate();
    end)

    self.mUpdateVersionTxt = update_version_view:getChildByName("update_version_txt")

    if kPlatform == kPlatformIOS then
        update_version_view:getChildByName("update_version_btn"):setVisible(false);
        self:setVersionName(kLuaVersion)
    else
        local data = OnlineUpdate.getInstance():getUpdateData();    
        if data then
            update_version_view:getChildByName("update_version_btn"):setVisible(true);
            self:setVersionName(kLuaVersion,data.pkgVersion)
        else
            update_version_view:getChildByName("update_version_btn"):setVisible(false);
            self:setVersionName(kLuaVersion)
        end
    end

    self.mBg:getChildByName("about_btn"):setOnClick(self,function()
        self:dismiss()
        StateMachine.getInstance():pushState(States.aboutModel,StateMachine.STYPE_CUSTOM_WAIT)
    end)
    
    self.mBg:getChildByName("help_btn"):setOnClick(self,function()
        self:dismiss()
        StateMachine.getInstance():pushState(States.helpModel,StateMachine.STYPE_CUSTOM_WAIT)
    end)
    
    self.mBg:getChildByName("qa_btn"):setOnClick(self,function()
        self:dismiss()
        StateMachine.getInstance():pushState(States.commonIssue,StateMachine.STYPE_CUSTOM_WAIT)
    end)
    
    EventDispatcher.getInstance():register(Event.Call,self,self.onNativeEvent)
    self:setCacheSize("查询寻中")
end

SettingDialog2.dtor = function(self)
	self.m_root_view = nil;
    delete(self.m_loading_dialog)
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeEvent)
end


function SettingDialog2:onNativeEvent(cmd,flag,data)
    if not flag then return end
    if cmd == kGetAppCacheSize then
        if data.CacheSize:get_value() then
		    cacheSize = data.CacheSize:get_value();
            self:setCacheSize(cacheSize)
        end
    elseif cmd == kCleanAppCache then
        if self.m_loading_dialog and self.m_loading_dialog:isShowing()  then self.m_loading_dialog:dismiss() end
        self:setCacheSize("0K")
    end
end

function SettingDialog2:setCacheSize(numTxt)
    self.mClearCacheTxt:removeAllChildren()
    numTxt = numTxt or ""
    local richText = new(RichText, string.format("清空缓存 ( #s24#c7d5041%s#n )",numTxt), width, height, kAlignBottomLeft, fontName, 28, 85, 70, 40, false)
    self.mClearCacheTxt:addChild(richText)
end

function SettingDialog2:setVersionName(curVersion,updateVersion)
    self.mUpdateVersionTxt:removeAllChildren()
    curVersion = curVersion or ""
    local str = ""
    if not updateVersion then
        str = string.format("目前版本:%s",curVersion)
    else
        str = string.format("目前版本:%s(最新#s24#cf53732%s#n)",curVersion,updateVersion)
    end
    local richText = new(RichText, str, width, height, kAlignBottomLeft, fontName, 28, 85, 70, 40, false)
    self.mUpdateVersionTxt:addChild(richText)
end

SettingDialog2.onChatToggleClick = function(self)
	print_string("SettingDialog2.onTouch");
	SettingInfo.getInstance():setChatToggle(not SettingInfo.getInstance():getChatToggle());
    SettingDialog2.setChecked(self.mChatToggle,SettingInfo.getInstance():getChatToggle());
end

SettingDialog2.onVibrateToggleClick = function(self)
	print_string("SettingDialog2.onTouch");
	SettingInfo.getInstance():setVibrateToggle(not SettingInfo.getInstance():getVibrateToggle());
    SettingDialog2.setChecked(self.mVibrateToggle,SettingInfo.getInstance():getVibrateToggle());
end

SettingDialog2.onDarkToggleClick = function(self)
	print_string("SettingDialog2.onTouch");
	SettingInfo.getInstance():setDarkToggle(not SettingInfo.getInstance():getDarkToggle());
    SettingDialog2.setChecked(self.mDarkToggle,SettingInfo.getInstance():getDarkToggle());
    if SettingInfo.getInstance():getDarkToggle() then
        DarkModeLayer.getInstance():show();
    else
        DarkModeLayer.getInstance():hide();
    end;
end

SettingDialog2.show = function(self)
    self.super.show(self)
--	print_string("SettingDialog2.show");

	self.m_sound_progress = SettingInfo.getInstance():getSoundVolume();
	self.m_music_progress = SettingInfo.getInstance():getMusicVolume();


	self.mEffectSlider:setProgress(self.m_sound_progress);
	self.mMusicSlider:setProgress(self.m_music_progress);

	self.m_chat_bool  = SettingInfo.getInstance():getChatToggle();
    self.m_vibrate_bool = SettingInfo.getInstance():getVibrateToggle();
    self.m_dark_bool = SettingInfo.getInstance():getDarkToggle();

	SettingDialog2.setChecked(self.mChatToggle,self.m_chat_bool);
	SettingDialog2.setChecked(self.mVibrateToggle,self.m_vibrate_bool);
    SettingDialog2.setChecked(self.mDarkToggle,self.m_dark_bool);
    call_native(kGetAppCacheSize)
end

SettingDialog2.setChecked = function(view,enable)
    if enable then
        view:getChildByName("open"):setVisible(true);
        view:getChildByName("close"):setVisible(false);
        view:getChildByName("toggle_icon"):setPos(53);
    else
        view:getChildByName("open"):setVisible(false);
        view:getChildByName("close"):setVisible(true);
        view:getChildByName("toggle_icon"):setPos(-12);
    end
end


SettingDialog2.soundChange = function(self,progress)
	self.m_sound_progress = progress;
	SettingInfo:getInstance():changeSoundVolume(self.m_sound_progress);
end

SettingDialog2.musicChange = function(self,progress)
	self.m_music_progress = progress;
	SettingInfo.getInstance():changeMusicVolume(self.m_music_progress);
end


SettingDialog2.dismiss = function(self)
    self.super.dismiss(self)
	SettingInfo.getInstance():saveMusicVolume(self.m_music_progress);
	SettingInfo.getInstance():saveSoundVolume(self.m_sound_progress);
end
