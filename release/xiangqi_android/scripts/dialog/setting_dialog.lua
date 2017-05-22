require(VIEW_PATH .. "setting_dialog_view");
require(BASE_PATH.."chessDialogScene");
require(DATA_PATH.."settingInfo");
SettingDialog = class(ChessDialogScene,false);

SettingDialog.step = 0.1;   --每次加减声音的大小
SettingDialog.max  = 1.0;   --最大音量
SettingDialog.min  = 0.0;    -- 最小音量



SettingDialog.ctor = function(self)
    super(self,setting_dialog_view);
	self.m_root_view = self.m_root;


	self.m_content_view = self.m_root_view:getChildByName("setting_content_view");
    self.m_content_view:setEventTouch(self,self.onTouch);
    self.m_close_btn = self.m_content_view:getChildByName("close_btn");
    self.m_close_btn:setOnClick(self,self.dismiss);

	self.m_sound_seekbar = self.m_content_view:getChildByName("sound_seekbar_view"):getChildByName("seekbar");
	self.m_music_seekbar = self.m_content_view:getChildByName("music_seekbar_view"):getChildByName("seekbar");
    self.m_sound_seekbar.m_bg:setVisible(false);
    self.m_sound_seekbar.m_fg:setVisible(false);
    self.m_music_seekbar.m_bg:setVisible(false);
    self.m_music_seekbar.m_fg:setVisible(false);

    self.m_sound_seekbar_fbg = self.m_content_view:getChildByName("sound_seekbar_view"):getChildByName("seekbar_bbg"):getChildByName("seekbar_fbg");
    self.m_music_seekbar_fbg = self.m_content_view:getChildByName("music_seekbar_view"):getChildByName("seekbar_bbg"):getChildByName("seekbar_fbg");

	self.m_sound_add_btn = self.m_content_view:getChildByName("sound_seekbar_view"):getChildByName("add_btn");
	self.m_sound_sub_btn = self.m_content_view:getChildByName("sound_seekbar_view"):getChildByName("reduction_btn");

	self.m_music_add_btn = self.m_content_view:getChildByName("music_seekbar_view"):getChildByName("add_btn");
	self.m_music_sub_btn = self.m_content_view:getChildByName("music_seekbar_view"):getChildByName("reduction_btn");

	self.m_sound_add_btn:setOnClick(self,self.soundAdd);
	self.m_sound_sub_btn:setOnClick(self,self.soundSub);

	self.m_music_add_btn:setOnClick(self,self.musicAdd);
	self.m_music_sub_btn:setOnClick(self,self.musicSub);

	self.m_sound_seekbar:setOnChange(self,self.soundChange);
	self.m_music_seekbar:setOnChange(self,self.musicChange);


--	self.m_sound_toggle = self.m_content_view:getChildByName("sound_toggle_view"):getChildByName("toggle_btn");
--	self.m_music_toggle = self.m_content_view:getChildByName("music_toggle_view"):getChildByName("toggle_btn");
	self.m_chat_toggle =  self.m_content_view:getChildByName("chat_toggle_view"):getChildByName("toggle_btn");
	self.m_vibrate_toggle =  self.m_content_view:getChildByName("vibrate_toggle_view"):getChildByName("toggle_btn");

    self.m_sound_toggle_index = 1;
	self.m_music_toggle_index = 2;
	self.m_chat_toggle_index = 3;
    self.m_vibrate_toggle_index = 4
    
--    self.m_sound_toggle:setOnClick(self,self.onSoundToggleClick);
--    self.m_music_toggle:setOnClick(self,self.onMusicToggleClick);
    self.m_chat_toggle:setOnClick(self,self.onChatToggleClick);
    self.m_vibrate_toggle:setOnClick(self,self.onVibrateToggleClick);


    self.m_switch_move_way_view = self.m_content_view:getChildByName("switch_move_way_view");
    self.m_move1_btn = self.m_switch_move_way_view:getChildByName("btn1");
    self.m_move2_btn = self.m_switch_move_way_view:getChildByName("btn2");
    self.m_move1_btn:setOnClick(self,self.onSelect1);
    self.m_move2_btn:setOnClick(self,self.onSelect2);
    self.m_select1 = self.m_move1_btn:getChildByName("select1");
    self.m_select2 = self.m_move2_btn:getChildByName("select2");
    
    local move_mode = GameCacheData.getInstance():getInt(GameCacheData.MOVE_MODE,1);
    if move_mode == 1 then
        self.m_select2:setVisible(false);
        self.m_select1:setVisible(true);
    elseif move_mode == 2 then
        self.m_select1:setVisible(false);
        self.m_select2:setVisible(true);
    end

--	self.m_cancel_btn = self.m_content_view:getChildByName("setting_cancel_btn");
    self:setShieldClick(self,self.cancel);

--	self.m_cancel_btn:setOnClick(self,self.cancel);

end

SettingDialog.dtor = function(self)
	self.m_root_view = nil;
end

SettingDialog.isShowing = function(self)
	return self:getVisible();
end

SettingDialog.onTouch = function(self)
	print_string("SettingDialog.onTouch");
end

--SettingDialog.checkChanged = function(self,index,checked)
--    if self.m_sound_toggle_index == index then
--	    SettingInfo.getInstance():setSoundToggle(checked);
--    elseif self.m_music_toggle_index == index then
--	    SettingInfo.getInstance():setMusicToggle(checked);
--    elseif self.m_chat_toggle_index == index then
--	    SettingInfo.getInstance():setChatToggle(checked);
--    elseif self.m_vibrate_toggle_index == index then
--        SettingInfo.getInstance():setVibrateToggle(checked);
--    end
--end

--SettingDialog.onSoundToggleClick = function(self)
--	print_string("SettingDialog.onTouch");
--	SettingInfo.getInstance():setSoundToggle(not SettingInfo.getInstance():getSoundToggle());
--    SettingDialog.setChecked(self.m_sound_toggle,SettingInfo.getInstance():getSoundToggle());
--end

--SettingDialog.onMusicToggleClick = function(self)
--	print_string("SettingDialog.onTouch");
--	SettingInfo.getInstance():setMusicToggle(not SettingInfo.getInstance():getMusicToggle());
--    SettingDialog.setChecked(self.m_music_toggle,SettingInfo.getInstance():getMusicToggle());
--end

SettingDialog.onChatToggleClick = function(self)
	print_string("SettingDialog.onTouch");
	SettingInfo.getInstance():setChatToggle(not SettingInfo.getInstance():getChatToggle());
    SettingDialog.setChecked(self.m_chat_toggle,SettingInfo.getInstance():getChatToggle());
end

SettingDialog.onVibrateToggleClick = function(self)
	print_string("SettingDialog.onTouch");
	SettingInfo.getInstance():setVibrateToggle(not SettingInfo.getInstance():getVibrateToggle());
    SettingDialog.setChecked(self.m_vibrate_toggle,SettingInfo.getInstance():getVibrateToggle());
end

SettingDialog.show = function(self)

	print_string("SettingDialog.show");

	self.m_sound_progress = SettingInfo.getInstance():getSoundVolume();
	self.m_music_progress = SettingInfo.getInstance():getMusicVolume();

	
	self.m_sound_seekbar:setProgress(self.m_sound_progress);
	self.m_music_seekbar:setProgress(self.m_music_progress);


--	self.m_sound_bool = SettingInfo.getInstance():getSoundToggle();
--	self.m_music_bool = SettingInfo.getInstance():getMusicToggle();
	self.m_chat_bool  = SettingInfo.getInstance():getChatToggle();
    self.m_vibrate_bool = SettingInfo.getInstance():getVibrateToggle();

--	SettingDialog.setChecked(self.m_sound_toggle,self.m_sound_bool);
--	SettingDialog.setChecked(self.m_music_toggle,self.m_music_bool);
	SettingDialog.setChecked(self.m_chat_toggle,self.m_chat_bool);
	SettingDialog.setChecked(self.m_vibrate_toggle,self.m_vibrate_bool);

    self.super.show(self,false);
	self:setVisible(true);

    for i = 1,4 do 
        if not self.m_content_view:checkAddProp(i) then
            self.m_content_view:removeProp(i);
        end 
    end
    local w,h = self.m_content_view:getSize();
--    local anim = self.m_content_view:addPropTranslateWithEasing(1,kAnimNormal, 400, -1, nil, "easeOutBounce", 0,0, h, -h);
    local anim = self.m_content_view:addPropTranslate(1,kAnimNormal,400,-1,0,0,h+25,0);
    if anim then
        anim:setEvent(self,function()
            self.m_content_view:addPropTranslate(4,kAnimNormal,200,-1,0,0,0,-25);
            delete(anim);
            anim = nil;
        end);
    end
    local anim_end = new(AnimInt,kAnimNormal,0,1,600,-1);
    if anim_end then
        anim_end:setEvent(self,function()
--            self.m_content_view:removeProp(1);
            for i = 1,4 do 
                if not self.m_content_view:checkAddProp(i) then
                    self.m_content_view:removeProp(i);
                end 
            end
            delete(anim_end);
        end);
    end
end

SettingDialog.setChecked = function(view,enable)
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


SettingDialog.soundChange = function(self,progress)

	print_string("SettingDialog.soundChange  progress = "  .. progress);
	self.m_sound_progress = progress;
    self.m_sound_seekbar_fbg:setSize(progress*243);
	SettingInfo:getInstance():changeSoundVolume(self.m_sound_progress);

end

SettingDialog.musicChange = function(self,progress)
	print_string("SettingDialog.musicChange  progress = "  .. progress);
	self.m_music_progress = progress;
    self.m_music_seekbar_fbg:setSize(progress*243);
	SettingInfo.getInstance():changeMusicVolume(self.m_music_progress);
end

SettingDialog.soundAdd = function(self)
	self.m_sound_progress = self.m_sound_progress + SettingDialog.step;
	if self.m_sound_progress > SettingDialog.max then
		self.m_sound_progress = SettingDialog.max;
	end

	self.m_sound_seekbar:setProgress(self.m_sound_progress);
    self.m_sound_seekbar_fbg:setSize(self.m_sound_progress*243);
	SettingInfo:getInstance():changeSoundVolume(self.m_sound_progress);
end

SettingDialog.soundSub = function(self)
	self.m_sound_progress = self.m_sound_progress - SettingDialog.step;
	if self.m_sound_progress < SettingDialog.min then
		self.m_sound_progress = SettingDialog.min;
	end

	self.m_sound_seekbar:setProgress(self.m_sound_progress);
    self.m_sound_seekbar_fbg:setSize(self.m_sound_progress*243);
	SettingInfo:getInstance():changeSoundVolume(self.m_sound_progress);
end


SettingDialog.musicAdd = function(self)
	self.m_music_progress = self.m_music_progress + SettingDialog.step;
	if self.m_music_progress > SettingDialog.max then
		self.m_music_progress = SettingDialog.max;
	end

	self.m_music_seekbar:setProgress(self.m_music_progress);
    self.m_music_seekbar_fbg:setSize(self.m_music_progress*243);
	SettingInfo:getInstance():changeMusicVolume(self.m_music_progress);
end

SettingDialog.musicSub = function(self)
	self.m_music_progress = self.m_music_progress - SettingDialog.step;
	if self.m_music_progress < SettingDialog.min then
		self.m_music_progress = SettingDialog.min;
	end

	self.m_music_seekbar:setProgress(self.m_music_progress);
    self.m_music_seekbar_fbg:setSize(self.m_music_progress*243);
	SettingInfo:getInstance():changeMusicVolume(self.m_music_progress);
end


SettingDialog.cancel = function(self)
	print_string("SettingDialog.cancel ");
	self:dismiss();
end





SettingDialog.dismiss = function(self)
	SettingInfo.getInstance():saveMusicVolume(self.m_music_progress);
	SettingInfo.getInstance():saveSoundVolume(self.m_sound_progress);
--	self:setVisible(false);
    self.super.dismiss(self,false);
    for i = 1,4 do 
        if not self.m_content_view:checkAddProp(i) then
            self.m_content_view:removeProp(i);
        end 
    end
    local w,h = self.m_content_view:getSize();
    local anim = self.m_content_view:addPropTranslate(2, kAnimNormal, 300, -1, 0, 0, 0, h);
    self.m_content_view:addPropTransparency(3,kAnimNormal,200,-1,1,0);
    if anim then
        anim:setEvent(self,function()
            self:setVisible(false);
            self.m_content_view:removeProp(2);
            self.m_content_view:removeProp(3);
            delete(anim);
        end);
    end
end

function SettingDialog:onSelect1()
    GameCacheData.getInstance():saveInt(GameCacheData.MOVE_MODE,1);
    self.m_select1:setVisible(true);
    self.m_select2:setVisible(false);
end

function SettingDialog:onSelect2()
    GameCacheData.getInstance():saveInt(GameCacheData.MOVE_MODE,2);
    self.m_select1:setVisible(false);
    self.m_select2:setVisible(true);
end
