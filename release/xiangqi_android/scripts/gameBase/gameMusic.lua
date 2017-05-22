-- gameMusic.lua
-- Author: Vicent Gong
-- Date: 2013-02-20
-- Last modification : 2013-07-12
-- Description: A base wrapper for game background music player

require("core/object");
require("gameBase/gameSound");

GameMusic = class(GameSound,false);

GameMusic.getInstance = function()
	if not GameMusic.s_instance then
		GameMusic.s_instance = new(GameMusic);
	end

	return GameMusic.s_instance;
end

GameMusic.releaseInstance = function()
	delete(GameMusic.s_instance);
	GameMusic.s_instance = nil;
end

GameMusic.ctor = function(self)
	super(self,GameSound.s_music);
end

GameMusic.unload = function(self,index)
	error("Music can not unload manually now");
end

GameMusic.stop = function(self,doUnload)
	GameMusic.callFunc(self,"stop",doUnload);
end

GameMusic.pause = function(self)
	GameMusic.callFunc(self,"pause");
end

GameMusic.resume = function(self)
	GameMusic.callFunc(self,"resume");
end

GameMusic.isPlaying = function(self)
	return Sound.isMusicPlaying();
end

GameMusic.dtor = function(self)
	GameMusic.stop(self,true);
end
