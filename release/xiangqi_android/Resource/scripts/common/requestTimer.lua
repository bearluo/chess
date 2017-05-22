require("core/object");
require("common/uiFactory");
require("common/animFactory");
require("util/toolKit");


RquestTimer = class();
RquestTimer.s_timer = 1500;

RquestTimer.getInstance = function()
	if not RquestTimer.s_instance then 
		RquestTimer.s_instance = new(RquestTimer);
	end
	return RquestTimer.s_instance;
end

RquestTimer.ctor = function(self)

end

RquestTimer.dtor = function(self)
	self:stopTimer();
end

-------------------------------------------------------------------------
RquestTimer.stopTimer = function(self)

end

RquestTimer.startTimer = function(self,time,callback,obj)
	if self.m_timer then
		delete(self.m_timer);
		self.m_timer = nil;
	end

	if callback then
		self.callback = callback;
	end

	self.m_obj = obj;
	self.m_timer = AnimFactory.createAnimInt(kAnimNormal,0,1,time);
	ToolKit.setDebugName(self.m_timer,"AnimInt|RquestTimer.startTimer|m_timer");
	self.m_timer:setEvent(self,self.onTimer);
end

RquestTimer.onTimer = function(self)
	-- self:stopTimer();
	if self.callback then
		self.callback(self.m_obj); 
	end
end

RquestTimer.removeTimer = function(self)
	if self.m_timer then
		delete(self.m_timer);
		self.m_timer = nil;
	end
end


