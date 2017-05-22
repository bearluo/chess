require("ui/image");
require("core/sound");
Setup = class(State);

Setup.ctor = function(self)
	self.m_bg = nil;
	self.m_anim = nil;
end

Setup.load = function(self)

	local w = System.getScreenWidth();
	local h = System.getScreenHeight();
	print_string("Setup.onTimerxxxxxxxxxev");
	-- self.m_anim = new(AnimInt,kAnimNormal,0,1,1,-1);
	-- self.m_anim:setEvent(self,self.onTimer);
	

	return 0;
end

Setup.run = function(self)
	StateMachine:getInstance():changeState(States.Hall);
end

Setup.stop = function(self)
	
end

Setup.onTimer = function(self)
	print_string("Setup.onTimerxxxxxxxxxe==============v");
	StateMachine:getInstance():changeState(States.Hall);
end

Setup.dtor = function(self)
	delete(self.m_bg);
	delete(self.m_anim);
end