--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23
--modify : FordFan
--Date   : 2016/5/3

require(BASE_PATH.."chessScene");
require("dialog/loading_dialog");

SetScene = class(ChessScene);

SetScene.step = 0.1;   --每次加减声音的大小
SetScene.max  = 1.0;   --最大音量
SetScene.min  = 0.0;    -- 最小音量

SetScene.s_controls = 
{
    set_view                 = 1;
    back_btn                 = 2;
    title_icon               = 3;
    update_btn               = 4;
    about_btn                = 5;
    help_btn                 = 6;
    update_version_view      = 7;
    version_view             = 8;
}

SetScene.s_cmds = 
{
    update_version_view = 1;
    updataCacheSize     = 2;
}
SetScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = SetScene.s_controls;
    self:create();
end 

SetScene.resume = function(self)
    ChessScene.resume(self);
--    self:removeAnimProp();
--    self:resumeAnimStart();
end

SetScene.isShowBangdinDialog = false;

SetScene.pause = function(self)
	ChessScene.pause(self);
    self:removeAnimProp();
--    self:pauseAnimStart();
--	SettingInfo.getInstance():saveMusicVolume(self.m_music_progress);
--	SettingInfo.getInstance():saveSoundVolume(self.m_sound_progress);
end 

SetScene.dtor = function(self)
    delete(self.anim_start);
    delete(self.anim_end);
    delete(self.m_loading_dialog);
    self.m_loading_dialog = nil;
end 

SetScene.removeAnimProp = function(self)
    if self.m_anim_prop_need_remove then
--        self.m_set_view:removeProp(1);
        self.m_title_icon:removeProp(1);
        self.m_leaf_left:removeProp(1);
--        self.m_back_btn:removeProp(1);
    --    self.m_content_view:removeProp(1);
    --    self.m_more_btn:removeProp(1);
    --    self.m_version:removeProp(1);
        self.m_anim_prop_need_remove = false;
    end
end

SetScene.setAnimItemEnVisible = function(self,ret)
    self.m_leaf_left:setVisible(ret);
end

SetScene.resumeAnimStart = function(self,lastStateObj,timer)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;
    delete(self.anim_start);
    self.anim_start = new(AnimInt,kAnimNormal,0,1,delay,-1);
    if self.anim_start then
        self.anim_start:setEvent(self,function()
            self:setAnimItemEnVisible(true);
            delete(self.anim_start);
        end);
    end

--    self.m_set_view:addPropTransparency(1,kAnimNormal,waitTime,delay,0,1);
    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, delay, -lw, 0, -10, 0);
    local tw,th = self.m_title_icon:getSize();
    local anim = self.m_title_icon:addPropTranslate(1, kAnimNormal, waitTime, delay, 0, 0, -th, 0);
    if anim then
        anim:setEvent(self,function()
            self.m_anim_prop_need_remove = true;
            self:removeAnimProp();
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end  
        end);   
    end
end

SetScene.pauseAnimStart = function(self,newStateObj,timer)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;
    delete(self.anim_end);
    self.anim_end = new(AnimInt,kAnimNormal,0,1,delay,-1);
    if self.anim_end then
        self.anim_end:setEvent(self,function()
            self.m_anim_prop_need_remove = true;
            self:removeAnimProp();
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end  
            delete(self.anim_end);
        end);
    end

--    self.m_set_view:addPropTransparency(1,kAnimNormal,waitTime,-1,1,0);
    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, -lw, 0, -10);
    local w,h = self.m_title_icon:getSize();
    local anim = self.m_title_icon:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, 0, 0, -h);
    if anim then
        anim:setEvent(self,function()
            self:setAnimItemEnVisible(false);
        end);
    end
end

---------------------- func --------------------
SetScene.create = function(self)
	self.m_set_view = self:findViewById(self.m_ctrls.set_view);
	self.m_back_btn = self:findViewById(self.m_ctrls.back_btn);
	self.m_title_icon = self:findViewById(self.m_ctrls.title_icon);
    self.m_update_version_view = self:findViewById(self.m_ctrls.update_version_view)
    self.m_version_view = self:findViewById(self.m_ctrls.version_view);
    if kPlatform == kPlatformIOS then
        self.m_update_version_view:setVisible(false);
    end;
    self.m_leaf_left = self.m_root:getChildByName("bamboo_left");

	self.m_sound_seekbar = self.m_set_view:getChildByName("sound_seekbar_view"):getChildByName("seekbar");
	self.m_music_seekbar = self.m_set_view:getChildByName("music_seekbar_view"):getChildByName("seekbar");
    self.m_sound_seekbar.m_bg:setVisible(false);
    self.m_sound_seekbar.m_fg:setVisible(false);
    self.m_music_seekbar.m_bg:setVisible(false);
    self.m_music_seekbar.m_fg:setVisible(false);

    self.m_sound_seekbar_fbg = self.m_set_view:getChildByName("sound_seekbar_view"):getChildByName("seekbar_bbg"):getChildByName("seekbar_fbg");
    self.m_music_seekbar_fbg = self.m_set_view:getChildByName("music_seekbar_view"):getChildByName("seekbar_bbg"):getChildByName("seekbar_fbg");

	self.m_sound_add_btn = self.m_set_view:getChildByName("sound_seekbar_view"):getChildByName("add_btn");
	self.m_sound_sub_btn = self.m_set_view:getChildByName("sound_seekbar_view"):getChildByName("reduction_btn");

	self.m_music_add_btn = self.m_set_view:getChildByName("music_seekbar_view"):getChildByName("add_btn");
	self.m_music_sub_btn = self.m_set_view:getChildByName("music_seekbar_view"):getChildByName("reduction_btn");

	self.m_sound_add_btn:setOnClick(self,self.soundAdd);
	self.m_sound_sub_btn:setOnClick(self,self.soundSub);

	self.m_music_add_btn:setOnClick(self,self.musicAdd);
	self.m_music_sub_btn:setOnClick(self,self.musicSub);

	self.m_sound_seekbar:setOnChange(self,self.soundChange);
	self.m_music_seekbar:setOnChange(self,self.musicChange);

    self.m_cache_size = self.m_set_view:getChildByName("cache_data_text");
    self.m_clear_btn = self.m_set_view:getChildByName("clear_btn");
    self.m_common_issue_btn = self.m_set_view:getChildByName("common_issue_btn");
    self.m_clear_btn:setOnClick(self,self.clearCache);
	self.m_common_issue_btn:setOnClick(self,self.commonIssue);


--	self.m_sound_toggle = self.m_set_view:getChildByName("sound_toggle_view"):getChildByName("toggle_btn");
--	self.m_music_toggle = self.m_set_view:getChildByName("music_toggle_view"):getChildByName("toggle_btn");
	self.m_chat_toggle =  self.m_set_view:getChildByName("chat_toggle_view"):getChildByName("toggle_btn");
	self.m_vibrate_toggle =  self.m_set_view:getChildByName("vibrate_toggle_view"):getChildByName("toggle_btn");

--    self.m_sound_toggle_index = 1;
--	self.m_music_toggle_index = 2;
	self.m_chat_toggle_index = 3;
    self.m_vibrate_toggle_index = 4

--    self.m_sound_toggle:setOnClick(self,self.onSoundToggleClick);
--    self.m_music_toggle:setOnClick(self,self.onMusicToggleClick);
    self.m_chat_toggle:setOnClick(self,self.onChatToggleClick);
    self.m_vibrate_toggle:setOnClick(self,self.onVibrateToggleClick);

    self:initSetView();
end

SetScene.initSetView = function(self)
    self.m_sound_progress = SettingInfo.getInstance():getSoundVolume();
	self.m_music_progress = SettingInfo.getInstance():getMusicVolume();

	
	self.m_sound_seekbar:setProgress(self.m_sound_progress);
	self.m_music_seekbar:setProgress(self.m_music_progress);


	self.m_sound_bool = SettingInfo.getInstance():getSoundToggle();
	self.m_music_bool = SettingInfo.getInstance():getMusicToggle();
	self.m_chat_bool  = SettingInfo.getInstance():getChatToggle();
    self.m_vibrate_bool = SettingInfo.getInstance():getVibrateToggle();

--	SetScene.setChecked(self.m_sound_toggle,self.m_sound_bool);
--	SetScene.setChecked(self.m_music_toggle,self.m_music_bool);
	SetScene.setChecked(self.m_chat_toggle,self.m_chat_bool);
	SetScene.setChecked(self.m_vibrate_toggle,self.m_vibrate_bool);
end

--SetScene.onSoundToggleClick = function(self)
--	print_string("SetScene.onTouch");
--	SettingInfo.getInstance():setSoundToggle(not SettingInfo.getInstance():getSoundToggle());
--    SetScene.setChecked(self.m_sound_toggle,SettingInfo.getInstance():getSoundToggle());
--end

--SetScene.onMusicToggleClick = function(self)
--	print_string("SetScene.onTouch");
--	SettingInfo.getInstance():setMusicToggle(not SettingInfo.getInstance():getMusicToggle());
--    SetScene.setChecked(self.m_music_toggle,SettingInfo.getInstance():getMusicToggle());
--end

SetScene.onChatToggleClick = function(self)
	print_string("SetScene.onTouch");
	SettingInfo.getInstance():setChatToggle(not SettingInfo.getInstance():getChatToggle());
    SetScene.setChecked(self.m_chat_toggle,SettingInfo.getInstance():getChatToggle());
end

SetScene.onVibrateToggleClick = function(self)
	print_string("SetScene.onTouch");
	SettingInfo.getInstance():setVibrateToggle(not SettingInfo.getInstance():getVibrateToggle());
    SetScene.setChecked(self.m_vibrate_toggle,SettingInfo.getInstance():getVibrateToggle());
end

SetScene.setChecked = function(view,enable)
    if enable then
        view:getChildByName("open"):setVisible(true);
        view:getChildByName("close"):setVisible(false);
        view:getChildByName("toggle_icon"):setPos(55);
    else
        view:getChildByName("open"):setVisible(false);
        view:getChildByName("close"):setVisible(true);
        view:getChildByName("toggle_icon"):setPos(-55);
    end
end

SetScene.soundChange = function(self,progress)

	print_string("SetScene.soundChange  progress = "  .. progress);
	self.m_sound_progress = progress;
    self.m_sound_seekbar_fbg:setSize(progress*243);
	SettingInfo:getInstance():changeSoundVolume(self.m_sound_progress);
end

SetScene.musicChange = function(self,progress)
	print_string("SetScene.musicChange  progress = "  .. progress);
	self.m_music_progress = progress;
    self.m_music_seekbar_fbg:setSize(progress*243);
	SettingInfo.getInstance():changeMusicVolume(self.m_music_progress);
end

SetScene.soundAdd = function(self)
	self.m_sound_progress = self.m_sound_progress + SetScene.step;
	if self.m_sound_progress > SetScene.max then
		self.m_sound_progress = SetScene.max;
	end

	self.m_sound_seekbar:setProgress(self.m_sound_progress);
    self.m_sound_seekbar_fbg:setSize(self.m_sound_progress*243);
	SettingInfo:getInstance():changeSoundVolume(self.m_sound_progress);
end

SetScene.soundSub = function(self)
	self.m_sound_progress = self.m_sound_progress - SetScene.step;
	if self.m_sound_progress < SetScene.min then
		self.m_sound_progress = SetScene.min;
	end

	self.m_sound_seekbar:setProgress(self.m_sound_progress);
    self.m_sound_seekbar_fbg:setSize(self.m_sound_progress*243);
	SettingInfo:getInstance():changeSoundVolume(self.m_sound_progress);
end


SetScene.musicAdd = function(self)
	self.m_music_progress = self.m_music_progress + SetScene.step;
	if self.m_music_progress > SetScene.max then
		self.m_music_progress = SetScene.max;
	end

	self.m_music_seekbar:setProgress(self.m_music_progress);
    self.m_music_seekbar_fbg:setSize(self.m_music_progress*243);
	SettingInfo:getInstance():changeMusicVolume(self.m_music_progress);
end

SetScene.musicSub = function(self)
	self.m_music_progress = self.m_music_progress - SetScene.step;
	if self.m_music_progress < SetScene.min then
		self.m_music_progress = SetScene.min;
	end

	self.m_music_seekbar:setProgress(self.m_music_progress);
    self.m_music_seekbar_fbg:setSize(self.m_music_progress*243);
	SettingInfo:getInstance():changeMusicVolume(self.m_music_progress);
end

SetScene.onBackAction = function(self)
    self:requestCtrlCmd(SetController.s_cmds.onBack);
end

SetScene.updateVersionView = function(self,data)
    
    if kPlatform == kPlatformIOS then
        if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
            self.m_version_view:setVisible(true);
            self.m_version_view:getChildByName("version_text"):setText(kLuaVersion);
        else
            self.m_version_view:setVisible(false);
        end;
        self.m_update_version_view:setVisible(false);
        return ;
    end;    
    if data then
        self.m_version_view:setVisible(false);
        self.m_update_version_view:setVisible(true);
        self.m_update_version_view:getChildByName("now_version"):setText("目前版本："..kLuaVersion);
        self.m_update_version_view:getChildByName("new_version"):setText("最新版本："..data.package_version);
    else
        self.m_version_view:setVisible(true);
        self.m_update_version_view:setVisible(false);
        self.m_version_view:getChildByName("version_text"):setText(kLuaVersion);
    end
end

SetScene.onUpdateBtnClick = function(self)
    if OnlineUpdate.getInstance():getUpdateData() then
        OnlineUpdate.getInstance():onUpdate();
    end
end

SetScene.onAboutBtnClick = function(self)
    StateMachine.getInstance():pushState(States.aboutModel,StateMachine.STYPE_CUSTOM_WAIT);
end

SetScene.onHelpBtnClick = function(self)
    StateMachine.getInstance():pushState(States.helpModel,StateMachine.STYPE_CUSTOM_WAIT);
end

--[[
    清理内存
--]]
function SetScene:clearCache()
    if not self.m_loading_dialog then
		self.m_loading_dialog = new(LoadingDialog);
	end
    local time = 2;
    local message = "清理中";
	self.m_loading_dialog:setMessage(message);
	self.m_loading_dialog:show(time);
    self:requestCtrlCmd(SetController.s_cmds.cleanCache);
end

--[[
    常见问题
--]]
function SetScene:commonIssue()
    StateMachine.getInstance():pushState(States.commonIssue,StateMachine.STYPE_CUSTOM_WAIT);
end

--[[
    更新缓存大小
--]]
function SetScene:updateCacheSize(cacheSize)
    if cacheSize then
        self.m_cache_size:setText("(" .. cacheSize .. ")");
    else
        if self.m_loading_dialog and self.m_loading_dialog:isShowing() then
            self.m_loading_dialog:dismiss()
        end
        self.m_cache_size:setText("(0K)");
    end
end
---------------------- config ------------------
SetScene.s_controlConfig = {
    [SetScene.s_controls.set_view]                      = {"set_view"};
    [SetScene.s_controls.back_btn]                      = {"back_btn"};
    [SetScene.s_controls.title_icon]                    = {"title_icon"};
    [SetScene.s_controls.update_btn]                    = {"set_view","update_version_view","update_btn"};
    [SetScene.s_controls.about_btn]                     = {"set_view","about_btn"};
    [SetScene.s_controls.help_btn]                      = {"set_view","help_btn"};
    [SetScene.s_controls.update_version_view]           = {"set_view","update_version_view"};
    [SetScene.s_controls.version_view]                  = {"set_view","version_view"};
}

SetScene.s_controlFuncMap = {
    [SetScene.s_controls.back_btn]              = SetScene.onBackAction;
    [SetScene.s_controls.update_btn]            = SetScene.onUpdateBtnClick;
    [SetScene.s_controls.about_btn]             = SetScene.onAboutBtnClick;
    [SetScene.s_controls.help_btn]              = SetScene.onHelpBtnClick;
};

SetScene.s_cmdConfig =
{
    [SetScene.s_cmds.update_version_view]              = SetScene.updateVersionView;
    [SetScene.s_cmds.updataCacheSize]		           = SetScene.updateCacheSize;
}