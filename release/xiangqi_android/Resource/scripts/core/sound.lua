-- sound.lua
-- Author: Vicent Gong
-- Date: 2012-09-30
-- Last modification : 2013-05-30
-- Description: provide basic wrapper for sound functions

require("core/constants")
require("core/object")

Sound = class();

Sound.preloadMusic = function(fileName)
	audio_music_preload(fileName);
end

Sound.playMusic = function(fileName, loop)
	audio_music_play(fileName,loop and kTrue or kFalse);
end

Sound.stopMusic = function(doUnload)
	audio_music_stop(doUnload and kTrue or kFalse);
end

Sound.pauseMusic = function()
	audio_music_pause();
end

Sound.resumeMusic = function()
	audio_music_resume();
end

Sound.isMusicPlaying = function()
	return audio_music_is_playing();
end

Sound.getMusicVolume = function()
	return audio_music_get_volume();
end

Sound.getMusicMaxVolume = function()
	return audio_music_get_max_volume();
end

Sound.setMusicVolume = function(volume)
	return audio_music_set_volume(volume);
end


Sound.preloadEffect = function(fileName)
	audio_effect_preload(fileName);
end

Sound.unloadEffect = function(fileName)
	audio_effect_unload(fileName);
end

Sound.playEffect = function(fileName, loop)
	return audio_effect_play(fileName,loop and kTrue or kFalse);
end

Sound.stopEffect = function(id)
	audio_effect_stop(id or 0);
end

Sound.getEffectVolume = function()
	return audio_effect_get_volume();
end

Sound.getEffectMaxVolume = function()
	return audio_effect_get_max_volume();
end

Sound.setEffectVolume = function(volume)
	return audio_effect_set_volume(volume);
end