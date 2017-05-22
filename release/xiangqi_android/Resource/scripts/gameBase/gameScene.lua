-- gameScene.lua
-- Author: Vicent Gong
-- Date: 2013-01-17
-- Last modification : 2013-06-27
-- Description: A base class of view in MVC 

require("core/object");
require("gameBase/gameLayer");

GameScene = class(GameLayer);

GameScene.ctor = function(self, viewConfig, controller)
	self.m_controller = controller;
	GameScene.addToRoot(self);
	GameScene.setFillParent(self,true,true);
end

GameScene.getController = function(self)
	return self.m_controller;
end

GameScene.requestCtrlCmd = function(self, cmd, ...)
	if not self.m_controller then
		return;
	end

	return self.m_controller:handleCmd(cmd, ...);
end

GameScene.pushStateStack = function(self, obj, func)
	if not self.m_controller then
		return;
	end

	self.m_controller:pushStateStack(obj,func);
end

GameScene.popStateStack = function(self)
	if not self.m_controller then
		return;
	end

	self.m_controller:popStateStack();
end

GameScene.pause = function(self)
	if not self.m_controller then
		return;
	end

	self.m_root:setPickable(false);
end

GameScene.resume = function(self)
	if not self.m_controller then
		return;
	end
	self.m_root:setPickable(true);
end

GameScene.stop = function(self)
	if not self.m_controller then
		return;
	end

	self.m_root:setVisible(false);
end

GameScene.run = function(self)
	if not self.m_controller then
		return;
	end
	
	self.m_root:setVisible(true);
	self.m_root:setPickable(false);
end

GameScene.dtor = function(self)
	self.m_controller = nil;
end
