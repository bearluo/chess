-- gameEffect.lua
-- Author: Vicent Gong
-- Date: 2013-02-20
-- Last modification : 2013-07-12
-- Description: A base wrapper for game effect player

require("core/object");
require("gameBase/gameSound");

GameEffect = class(GameSound,false);

GameEffect.getInstance = function()
	if not GameEffect.s_instance then
		GameEffect.s_instance = new(GameEffect);
	end

	return GameEffect.s_instance;
end

GameEffect.releaseInstance = function()
	delete(GameEffect.s_instance);
	GameEffect.s_instance = nil;
end

GameEffect.ctor = function(self)
	super(self,GameSound.s_effect);
end

GameEffect.unload = function(self, index)
	GameEffect.callFunc(self,"unload",index);
end

GameEffect.stop = function(self, id)
	GameEffect.callFunc(self,"stop",id);
end

GameEffect.preloadAll = function(self)
	for k,v in pairs(self.m_soundFileMap or {}) do
		GameEffect.preload(self,k);
	end
end

GameEffect.unloadAll = function(self)
	for k,v in pairs(self.m_loadedSounds) do
		GameEffect.unload(self,k);
	end
end

GameEffect.dtor = function(self)
	GameEffect.unloadAll(self);
end
