-- button.lua
-- Author: Vicent Gong
-- Date: 2012-09-24
-- Last modification : 2013-06-25
-- Description: Implement a button 

require("core/constants");
require("core/object");
require("core/global");
require("ui/images");

Button = class(Images,false);

Button.ctor = function(self, normalFile, disableFile, fmt, filter, leftWidth, rightWidth, topWidth, bottomWidth)
	super(self,{normalFile, disableFile},fmt,filter,leftWidth,rightWidth,topWidth,bottomWidth);

	self.m_showEnbaleFunc = disableFile 
						and self.showEnableWithDisableImage 
						or self.showEnableWithoutDisableImage;
	
	self.m_enable = true;
	Button.setEventTouch(self,self,self.onClick);

	self.m_eventCallback = {};

    self.m_responseType = kButtonUpInside;
end

Button.setEnable = function(self, enable)
	self.m_enable = enable;
	self.m_showEnbaleFunc(self,self.m_enable);
end

Button.setOnClick = function(self, obj, func, responseType)
    self.m_eventCallback.func = func;
	self.m_eventCallback.obj = obj;

	self.m_responseType = responseType or kButtonUpInside;
end

Button.dtor = function(self)
	delete(self.m_resDisable);
	self.m_resDisable = nil;

	self.m_eventCallback = nil;
end

---------------------------------private functions-----------------------------------------

Button.setOnTuchProcess = function(self,obj,func)
    self.m_process_event_obj = obj;
    self.m_process_event_func = func;
end


--virtual
Button.showEnableWithoutDisableImage = function(self, enable)

    if self.m_process_event_func then -- 保护模式执行
        if kDebug then
            self.m_process_event_func(self.m_process_event_obj,enable)
        else
            pcall(function ()self.m_process_event_func(self.m_process_event_obj,enable) end);
        end
    end

	if enable then
		Button.setColor(self,255,255,255);
	else
		Button.setColor(self,128,128,128);
	end
end	

--virtual
Button.showEnableWithDisableImage = function(self, enable)
    
    if self.m_process_event_func then -- 保护模式执行
        if kDebug then
            self.m_process_event_func(self.m_process_event_obj,enable)
        else
            pcall(function ()self.m_process_event_func(self.m_process_event_obj,enable) end);
        end
    end

	if enable then
		Button.setImageIndex(self,0);
	else
		Button.setImageIndex(self,1);
	end
end	

--virtual
Button.onClick = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
	if not self.m_enable then
		return;
	end
	
	if finger_action == kFingerDown then
	   self.m_showEnbaleFunc(self,false);
	elseif finger_action == kFingerMove then
		if not (self.m_responseType == kButtonUpInside and drawing_id_first ~= drawing_id_current) then
			self.m_showEnbaleFunc(self,false);
		else
			self.m_showEnbaleFunc(self,true);
		end
	elseif finger_action == kFingerUp then
		self.m_showEnbaleFunc(self,true);
		
		local responseCallback = function()
			if self.m_eventCallback.func then
                self.m_eventCallback.func(self.m_eventCallback.obj,finger_action,x,y,
                	drawing_id_first,drawing_id_current);
            end	
		end

		if self.m_responseType == kButtonUpInside then
			if drawing_id_first == drawing_id_current then
				responseCallback();
			end
	    elseif self.m_responseType == kButtonUpOutside then
	    	if drawing_id_first ~= drawing_id_current then
				responseCallback();
			end
		else
			responseCallback();
		end
	elseif finger_action==kFingerCancel then
		self.m_showEnbaleFunc(self,true);
	end
end
--virtual by BearLuo 滑动button
Button.setSrollOnClick = function(self)
	Button.setEventTouch(self,self,self.onClick2);
end

Button.onClick2 = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
	if not self.m_enable then
		return;
	end
	
	if finger_action == kFingerDown then
	   self.m_showEnbaleFunc(self,false);
       self.m_downX = x;
       self.m_downY = y;
	elseif finger_action == kFingerMove then
		if not (self.m_responseType == kButtonUpInside and drawing_id_first ~= drawing_id_current) then
			self.m_showEnbaleFunc(self,false);
		else
			self.m_showEnbaleFunc(self,true);
		end
	elseif finger_action == kFingerUp then
		self.m_showEnbaleFunc(self,true);
		
        local dw = math.abs(self.m_downX - x);
        local dh = math.abs(self.m_downY - y);
        if dw > 20 or dh > 20 then
            return ;
        end

		local responseCallback = function()
			if self.m_eventCallback.func then
                self.m_eventCallback.func(self.m_eventCallback.obj,finger_action,x,y,
                	drawing_id_first,drawing_id_current);
            end	
		end

		if self.m_responseType == kButtonUpInside then
			if drawing_id_first == drawing_id_current then
				responseCallback();
			end
	    elseif self.m_responseType == kButtonUpOutside then
	    	if drawing_id_first ~= drawing_id_current then
				responseCallback();
			end
		else
			responseCallback();
		end
	elseif finger_action==kFingerCancel then
		self.m_showEnbaleFunc(self,true);
	end
end
