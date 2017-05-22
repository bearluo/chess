-- stateMachine.lua
-- Author: Vicent Gong
-- Date: 2012-11-21
-- Last modification : 2013-05-30
-- Description: Implement base state

State = class();

State.ctor = function(self)
	self.m_status = StateStatus.Unloaded;
end

State.load = function(self)
	self.m_status = StateStatus.Loading;
end

State.run = function(self)
	self.m_status = StateStatus.Started;
end

State.resume = function(self)
	self.m_status = StateStatus.Resumed;
end

State.pause = function(self)
	self.m_status = StateStatus.Paused;
end

State.stop = function(self)
	self.m_status = StateStatus.Stoped;
end

State.unload = function(self)
	self.m_status = StateStatus.Unloaded;
end

State.dtor = function(self)
	self.m_status = StateStatus.Droped;
end

State.getCurStatus = function(self)
	return self.m_status;
end

State.setStatus = function(self, state)
	self.m_status = state;
end

StateStatus = 
{
	Unloaded  	= 1;
	Loading	  	= 2;
	Loaded		= 3;
	Started		= 4;
	Resumed		= 5;
	Paused		= 6;
	Stoped		= 7;
	Droped		= 8;
};

State.s_releaseFuncMap = 
{
	[StateStatus.Unloaded] 	= {};
	[StateStatus.Loading] 	= {"unload"};
	[StateStatus.Loaded] 	= {"unload"};
	[StateStatus.Started] 	= {"stop","unload"};
	[StateStatus.Resumed] 	= {"pause","stop","unload"};
	[StateStatus.Paused] 	= {"stop","unload"};
	[StateStatus.Stoped] 	= {"unload"};
	[StateStatus.Droped] 	= {};
};
