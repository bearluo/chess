-- gameSound.lua
-- Author: Vicent Gong
-- Date: 2013-02-20
-- Last modification : 2013-06-27
-- Description: A base wrapper for game sound player

require("core/object");
require("core/sound");

GameSound = class();

GameSound.s_music = "Music";
GameSound.s_effect = "Effect";

GameSound.ctor = function(self, str)
	if str ~= GameSound.s_music and str ~= GameSound.s_effect then
		error("Wrong game sound type");
	end

	self.m_typeStr = str;
	self.m_loadedSounds = {}; 

	self.m_prefix = "";
	self.m_extName = "";
end

GameSound.setSoundFileMap = function(self, soundFileMap)
	self.m_soundFileMap = soundFileMap;
end

GameSound.setPathPrefixAndExtName = function(self, prefix, extName)
	self.m_prefix = prefix;
	self.m_extName = extName;
end

GameSound.getPath = function(self, index)
	if not (self.m_soundFileMap and self.m_soundFileMap[index]) then
		return nil;
	end

	local path = self.m_prefix .. self.m_soundFileMap[index] .. self.m_extName;
	return path;
end

GameSound.preload = function(self, index)
	local path = GameSound.getPath(self,index);
	if not path then
		return;
	end

	self.m_loadedSounds[index] = true;
	GameSound.callFunc(self,"preload",path);
end

GameSound.unload = function(self, index)
	error("Derived class must define this function");
end

GameSound.play = function(self, index, loop)
	local path = GameSound.getPath(self,index);
	if not path then
		return;
	end

	self.m_loadedSounds[index] = true;
	return GameSound.callFunc(self,"play",path,loop);
end

GameSound.stop = function(self)
	error("Derived Class must define this function");
end

GameSound.setVolume = function(self,volume)
	Sound[string.format("%s%s%s","set",self.m_typeStr,"Volume")](volume);
end

GameSound.getVolume = function(self)
	return Sound[string.format("%s%s%s","get",self.m_typeStr,"Volume")]();
end

GameSound.getMaxVolume = function(self)
	return Sound[string.format("%s%s%s","get",self.m_typeStr,"MaxVolume")]();
end

---------------------------------private functions-----------------------------------------

GameSound.callFunc = function(self, commandStr, ...)
	Sound[string.format("%s%s",commandStr,self.m_typeStr)](...);
end
