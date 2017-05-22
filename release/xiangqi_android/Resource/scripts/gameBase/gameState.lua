-- gameState.lua
-- Author: Vicent Gong
-- Date: 2013-01-17
-- Last modification : 2013-07-12
-- Description: A base class of state

require("core/object");
require("core/state");
require("core/global");
-- require("core/stateMachine")
require("core/eventDispatcher");
require("gameBase/gameController");

--All functions are virtual
GameState = class(State);

GameState.ctor = function(self)
	self.m_stateStack = {};
end

GameState.getController = function(self)
	error("Sub class must define this function,return the controller");
end

GameState.gobackLastState = function(self)
	error("Sub class must define this function");
end

GameState.run = function(self)
	State.run(self);
	local controller = self:getController();
	if typeof(controller,GameController) then
		controller:run();
	end
end

GameState.resume = function(self)
	State.resume(self);
    EventDispatcher.getInstance():register(Event.Back,self,self.onBack);
    
	local controller = self:getController();
	if typeof(controller,GameController) then
		controller:resume();
	end
end

GameState.pause = function(self)
	local controller = self:getController();
	if typeof(controller,GameController) then
		controller:pause();
	end
	
	EventDispatcher.getInstance():unregister(Event.Back,self,self.onBack);

	State.pause(self);
end

GameState.stop = function(self)
	local controller = self:getController();
	if typeof(controller,GameController) then
		controller:stop();
	end

	State.stop(self);
end

GameState.pushStateStack = function(self, obj, func)
	if not self.m_stateStack then
		return;
	end
	
	local t = {};
	t["obj"] = obj;
	t["func"] = func;
	self.m_stateStack[#self.m_stateStack+1] = t;
end

GameState.popStateStack = function(self)
	if not self.m_stateStack then
		return;
	end
	
	if #self.m_stateStack > 0 then
		return table.remove(self.m_stateStack,#self.m_stateStack);
	else
		return nil;
	end
end

GameState.changeState = function(self, state, style, ...)
	StateMachine.getInstance():changeState(state,style,...);
end

GameState.pushState = function(self, state, style, isPopupState, ...)
	StateMachine.getInstance():pushState(state,style,isPopupState,...);
end

GameState.popState = function(self, style, ...)
	local lastStateCallback = self:popStateStack();
	local lastStateCbFunc = lastStateCallback and lastStateCallback["func"];
	if lastStateCbFunc then
		lastStateCbFunc(lastStateCallback["obj"],...);
	else
		return self:gobackLastState(...);
	end
end

GameState.dtor = function(self)
	self.m_stateStack = nil;
end

---------------------------------private functions-----------------------------------------

GameState.onBack = function(self)
    self:popState();
end
