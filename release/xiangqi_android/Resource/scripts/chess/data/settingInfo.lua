SettingInfo = class();

SettingInfo.getInstance = function()
    if not SettingInfo.instance then
        SettingInfo.instance = new(SettingInfo);
	    SettingInfo.instance:changeSoundVolume(SettingInfo.instance:getSoundVolume());
	    SettingInfo.instance:changeMusicVolume(SettingInfo.instance:getMusicVolume());
    end
    return SettingInfo.instance;
end

SettingInfo.setSoundToggle = function(self,soundToggle)
	self.m_soundToggle = soundToggle;
	GameCacheData.getInstance():saveBoolean(GameCacheData.SOUNDTOGGLE,soundToggle);
end

SettingInfo.getSoundToggle = function(self)
	self.m_soundToggle = GameCacheData.getInstance():getBoolean(GameCacheData.SOUNDTOGGLE,true);
--	return self.m_soundToggle;
    return true;
end



SettingInfo.setMusicToggle = function(self,musicToggle)
	self.m_musicToggle = musicToggle;
	GameCacheData.getInstance():saveBoolean(GameCacheData.MUSICTOGGLE,musicToggle);
	if musicToggle then 
		GameMusic.resume(kMusicPlayer);
	else
		GameMusic.pause(kMusicPlayer);
	end
end

SettingInfo.getMusicToggle = function(self)
	self.m_musicToggle = GameCacheData.getInstance():getBoolean(GameCacheData.MUSICTOGGLE,true);
----	return self.m_musicToggle;
    return true;
end


SettingInfo.setChatToggle = function(self,chatToggle)
	self.m_chatToggle = chatToggle;
	GameCacheData.getInstance():saveBoolean(GameCacheData.CHATTOGGLE,chatToggle);
end

SettingInfo.getChatToggle = function(self)
	self.m_chatToggle = GameCacheData.getInstance():getBoolean(GameCacheData.CHATTOGGLE,true);
	return self.m_chatToggle;
end

SettingInfo.setVibrateToggle = function(self,vibrateToggle)
	self.m_vibrateToggle = vibrateToggle;
	GameCacheData.getInstance():saveBoolean(GameCacheData.VIBRATETOGGLE,vibrateToggle);
end

SettingInfo.getVibrateToggle = function(self)
	self.m_vibrateToggle = GameCacheData.getInstance():getBoolean(GameCacheData.VIBRATETOGGLE,false);
	return self.m_vibrateToggle;
end

SettingInfo.setDarkToggle = function(self,darkToggle)
	self.m_darkToggle = darkToggle;
	GameCacheData.getInstance():saveBoolean(GameCacheData.DARKTOGGLE,darkToggle);
end

SettingInfo.getDarkToggle = function(self)
	self.m_darkToggle = GameCacheData.getInstance():getBoolean(GameCacheData.DARKTOGGLE,true);
	return self.m_darkToggle;
end

SettingInfo.changeSoundVolume = function(self,soundVolume)
	self.m_soundVolume = soundVolume;
    GameCacheData.getInstance():saveDouble(GameCacheData.SOUNDVOLUME,soundVolume);
	local volume = kEffectPlayer:getMaxVolume()*soundVolume;
	kEffectPlayer:setVolume(soundVolume);
end

SettingInfo.saveSoundVolume = function(self,soundVolume)
	self.m_soundVolume = soundVolume;
	GameCacheData.getInstance():saveDouble(GameCacheData.SOUNDVOLUME,soundVolume);
	local volume = kEffectPlayer:getMaxVolume()*soundVolume;
	kEffectPlayer:setVolume(soundVolume);
end



SettingInfo.changeMusicVolume = function(self,musicVolume)
	self.m_musicVolume = musicVolume;
    GameCacheData.getInstance():saveDouble(GameCacheData.MUSICVOLUME,musicVolume);
	-- local volume = Sound.getMusicMaxVolume()*musicVolume;

	print_string("SoundManager.saveMusicVolume  " .. musicVolume);
	kMusicPlayer:setVolume(musicVolume);
end

SettingInfo.saveMusicVolume = function(self,musicVolume)
	self.m_musicVolume = musicVolume;
	GameCacheData.getInstance():saveDouble(GameCacheData.MUSICVOLUME,musicVolume);
	-- local volume = Sound.getMusicMaxVolume()*musicVolume;

	print_string("SoundManager.saveMusicVolume  " .. musicVolume);
	kMusicPlayer:setVolume(musicVolume);
end

SettingInfo.getSoundVolume = function(self)
	self.m_soundVolume = GameCacheData.getInstance():getDouble(GameCacheData.SOUNDVOLUME,1.0);
	return self.m_soundVolume;

end

SettingInfo.getMusicVolume = function(self)
	self.m_musicVolume = GameCacheData.getInstance():getDouble(GameCacheData.MUSICVOLUME,1.0);
	return self.m_musicVolume;
end

SettingInfo.getInstance();