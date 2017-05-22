-- gameController.lua
-- Author: Vicent Gong
-- Date: 2013-01-17
-- Last modification : 2013-06-27
-- Description: A base class of controller in MVC 

require("gameBase/gameScene")

GameController = class();

GameController.s_cmds = 
{

};

GameController.s_cmdConfig = 
{
	
};

GameController.ctor = function(self, state, viewClass, viewConfig,...)
	if (not viewClass) or (not viewConfig) then
		error("No such view class or view config");
	end

	if not typeof(viewClass,GameScene) then
		error("View class is not a subclass of GameScene");
	end

	self.m_state = state;
	self.m_view = new(viewClass,viewConfig,self,...);
end

GameController.testCmd = function(self, cmd)
	return self.s_cmdConfig[cmd] and true or false;
end

GameController.handleCmd = function(self, cmd, ...)
	if not self.s_cmdConfig[cmd] then
		FwLog("Controller, no such cmd");
		return;
	end

	return self.s_cmdConfig[cmd](self,...)
end

GameController.updateView = function(self, cmd, ...)
	if not self.m_view then
		return;
	end

	return self.m_view:handleCmd(cmd,...);
end

GameController.getRootView = function(self)
    return self.m_view;
end;


GameController.pushStateStack = function(self, obj, func)
	self.m_state:pushStateStack(obj,func);
end

GameController.popStateStack = function(self)
	self.m_state:popStateStack();
end

GameController.run = function(self)
	if not self.m_view then
		return;
	end

	self.m_view:run();
end

GameController.resume = function(self)
	if not self.m_view then
		return;
	end

	self.m_view:resume();
end

GameController.pause = function(self)
	if not self.m_view then
		return;
	end

	self.m_view:pause();
end

GameController.stop = function(self)
	if not self.m_view then
		return;
	end
	
	self.m_view:stop();
end

GameController.dtor = function(self)
	delete(self.m_view);
	self.m_view = nil;
end
