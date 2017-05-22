-- anim.lua
-- Author: Vicent Gong
-- Date: 2012-09-21
-- Last modification : 2013-05-29
-- Description: provide basic wrapper for anim variables

require("core/object");
require("core/constants");
require("core/global");

---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] AnimBase------------------------------------------
---------------------------------------------------------------------------------------------

AnimBase = class();

property(AnimBase,"m_animID","ID",true,false);

AnimBase.ctor = function(self)
	self.m_animID = anim_alloc_id();
	self.m_eventCallback = {};
end

AnimBase.dtor = function(self)
	anim_free_id(self.m_animID);
end

AnimBase.setDebugName = function(self, name)
	name = name or "";
	anim_set_debug_name(self.m_animID,name);
end

AnimBase.getCurValue = function(self, defaultValue)
	return anim_get_value(self.m_animID,defaultValue or 0);
end

AnimBase.setEvent = function(self, obj, func)
	anim_set_event(self.m_animID,kTrue,self,self.onEvent);
	self.m_eventCallback.obj = obj;
	self.m_eventCallback.func = func;
end

AnimBase.setPause = function(self,isPause)
    return anim_set_pause(self.m_animID,(isPause == false and 0) or 1)
end

--------------- private functions, don't use these functions in your code -----------------------

AnimBase.onEvent = function(self, anim_type, anim_id, repeat_or_loop_num)
	if self.m_eventCallback.func then
		self.m_eventCallback.func(self.m_eventCallback.obj,anim_type, anim_id, repeat_or_loop_num);
	end
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] AnimDouble----------------------------------------
---------------------------------------------------------------------------------------------

AnimDouble = class(AnimBase);

AnimDouble.ctor = function(self, animType, startValue, endValue, duration, delay)
	anim_create_double(0, self.m_animID, animType, startValue, endValue, duration,delay or 0);
end

AnimDouble.dtor = function(self)
	anim_delete(self.m_animID);
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] AnimInt-------------------------------------------
---------------------------------------------------------------------------------------------

AnimInt = class(AnimBase);

AnimInt.ctor = function(self, animType, startValue, endValue, duration, delay)
	anim_create_int(0, self.m_animID, animType, startValue, endValue, duration,delay or 0);
end

AnimInt.dtor = function(self)
	anim_delete(self.m_animID);
end


---------------------------------------------------------------------------------------------
-----------------------------------[CLASS] AnimIndex-----------------------------------------
---------------------------------------------------------------------------------------------

AnimIndex = class(AnimBase);

AnimIndex.ctor = function(self, animType, startValue, endValue, duration, res, delay)
	anim_create_index(0, self.m_animID, animType, startValue, endValue, duration, res.m_resID,delay or 0); 
end

AnimIndex.dtor = function(self)
	anim_delete(self.m_animID);
end

