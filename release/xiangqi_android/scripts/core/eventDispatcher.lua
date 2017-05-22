-- evnetDispatcher.lua
-- Author: Vicent.Gong
-- Date: 2012-07-11
-- Last modification : 2013-05-29
-- Description: Implemented a evnet dispatcher to handle default event.

require("core/global");

Event = {
    RawTouch    = 1,
	Call    	= 2,
	KeyDown    	= 3, -- 监听按键
	Pause 		= 4, -- 点击home键 暂停活动 程序运行在后台调用
	Resume 		= 5, -- 点击游戏   重新开始活动 程序运行在前台调用
	Set 		= 6, -- 暂时未用
	Network 	= 7, -- 暂时未用
	Back		= 8, -- 返回键
	Timeout		= 9, -- 系统定时器到达
	End 		= 10,-- 无用，结束标识
};

EventState = 
{
	RemoveMarked = 1,
};

EventDispatcher = class();

EventDispatcher.getInstance = function()
	if not EventDispatcher.s_instance then 
		EventDispatcher.s_instance = new(EventDispatcher);
	end
	return EventDispatcher.s_instance;
end

EventDispatcher.releaseInstance = function()
	delete(EventDispatcher.s_instance);
	EventDispatcher.s_instance = nil;
end

EventDispatcher.ctor = function(self)
	self.m_listener = {};
	self.m_tmpListener = {};
	self.m_userKey = Event.End;
end

EventDispatcher.getUserEvent = function(self)
	self.m_userKey = self.m_userKey + 1;
	return self.m_userKey;
end

EventDispatcher.register = function(self, event, obj, func)
	local arr;
	if self.m_dispatching then
		self.m_tmpListener[event] = self.m_tmpListener[event] or {};
		arr = self.m_tmpListener[event];
	else
		self.m_listener[event] = self.m_listener[event] or {};
		arr = self.m_listener[event];
	end
	
	arr[#arr+1] = {["obj"] = obj,["func"] = func,};
end

EventDispatcher.unregister = function(self, event, obj, func)
	if not self.m_listener[event] then return end; 

	local arr = self.m_listener[event] or {};
	--for k,v in pairs(arr) do 
	for i=1,table.maxn(arr) do 
		local listerner = arr[i];
		if listerner then
			if (listerner["func"] == func) and (listerner["obj"] == obj) then 
				arr[i].mark = EventState.RemoveMarked;
				if not self.m_dispatching then
					arr[i] = nil;
				end

				--don't break so fast now,take care of the dump event listener
				--return;
			end
		end
	end
end

EventDispatcher.dispatch = function(self, event, ...)
	if not self.m_listener[event] then return end;

	self.m_dispatching = true;

	local ret = false;
	local listeners = self.m_listener[event] or {};
	--for _,v in pairs(listeners) do 
	for i=1,table.maxn(listeners) do 
		local listener = listeners[i]
		if listener then
			if listener["func"] and  listener["mark"] ~= EventState.RemoveMarked then 
				ret = ret or listener["func"](listener["obj"],...);
			end
		end
	end

	self.m_dispatching = false;

	EventDispatcher.cleanup(self);

	return ret;
end

EventDispatcher.cleanup = function(self)
	for event,listeners in pairs(self.m_tmpListener) do 
		self.m_listener[event] = self.m_listener[event] or {};
		local arr = self.m_listener[event];
		--for k,v in pairs(listeners) do 
		for i=1,table.maxn(listeners) do 
			local listener = listeners[i];
			if listener then
				arr[#arr+1] = listener;
			end
		end
	end

	self.m_tmpListener = {};

	for _,listeners in pairs(self.m_listener) do
		--for k,v in pairs(listeners) do 
		for i=1,table.maxn(listeners) do 
			local listener = listeners[i];
			if listener and (listener.mark == EventState.RemoveMarked or listener.func == nil) then 
				listeners[i] = nil;
			end
		end
	end
end

EventDispatcher.dtor = function(self)
	self.m_listener = nil;
end

require("core/systemEvent");