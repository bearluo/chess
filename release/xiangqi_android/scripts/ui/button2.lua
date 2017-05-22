-- button2.lua
-- Author: Vicent Gong
-- Date: 2012-09-24
-- Last modification : 2012-10-12
-- Description: It is almost same as Button, but only when clicked it change to be another file but not getting gray


require("core/constants");
require("core/object");
require("ui/images");

Button2 = class(Images,false);

---------------------costruct function  -------------------------------------------------
--Parameters: 	file, fmt, filter	-- as same as Button
--				file_disable		-- when disabled , display this file
--Return 	:   no return
-----------------------------------------------------------------------------------------
Button2.ctor = function(self, file, file_disable, fmt, filter,leftWidth,rightWidth,bottomWidth,topWidth)
	contructSuper(self,{file,file_disable},fmt,filter,leftWidth,rightWidth,bottomWidth,topWidth);
	self:setEventTouch(self,self.onClick);
	self.m_enable = true;
end

---------------------function setEnable -------------------------------------------------
--Note		:	As same as Button
-----------------------------------------------------------------------------------------
Button2.setEnable = function(self,enable)
	self.m_enable=enable;
	if enable then
		self:setImageIndex(0);
	else
		self:setImageIndex(1);
	end
end

---------------------function setOnClick ------------------------------------------------
--Note		:	As same as Button
-----------------------------------------------------------------------------------------
Button2.setOnClick = function(self, obj,func)
    self.m_onClickFunc = func;
	self.m_onClickObj = obj;
end

---------------------destructor function  -------------------------------------------------
--Parameters: 	no Parameters
--Return 	:   no return
--------------------------------------------------------------------------------------------
Button2.dtor = function(self)
  
end

--------------------------------------------------------------------------------------------
---------------------------------private functions-----------------------------------------
--------------------------------------------------------------------------------------------

---------------------function onClick ---------------------------------------------------
--Note		:	As same as Button
-----------------------------------------------------------------------------------------
Button2.onClick = function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
	if not self.m_enable then
		return;
	end
	
	if finger_action==kFingerDown then
	    self:setImageIndex(1);
	elseif finger_action==kFingerMove then
		if drawing_id_first==drawing_id_current then
			self:setImageIndex(1);
		else
			self:setImageIndex(0);
		end
	elseif finger_action==kFingerUp then
		if drawing_id_first==drawing_id_current then
			self:setImageIndex(0);
            if self.m_onClickFunc ~= nil then
            	SoundManager.getInstance():play_effect(SoundManager.AUDIO_BUTTON_CLICK);
                self.m_onClickFunc(self.m_onClickObj,finger_action,x,y,drawing_id_first,drawing_id_current);
            end			
		else
			self:setImageIndex(0);
		end
	elseif finger_action==kFingerCancel then
		self:setImageIndex(0);
	end
end