
MenuButton = class(Images,false);

MenuButton.s_maxClickOffset = 10;

MenuButton.s_imageName = "drawable/menu%d.png";
MenuButton.s_imageNameUser = "drawable/menu%d.png";

MenuButton.changeDefaultImages = function(image)
	MenuButton.s_imageNameUser = image or MenuButton.s_imageName;
end

MenuButton.ctor = function(self, file, fmt, filter,leftWidth,rightWidth,bottomWidth,topWidth)
	local array = file;
	if not array then
		array = {};
        for i=1,2 do 
            array[i] = string.format(MenuButton.s_imageNameUser,i);
        end
    end
	contructSuper(self,array,fmt,filter,leftWidth,rightWidth,bottomWidth,topWidth);
	self:setEventTouch(self,self.onEventTouch);
	self.m_enable = true;
	self.m_checked = false;
end

MenuButton.addChild = function(self,child)
	self.addChild(self,child);
	child:setEventTouch(self,self.onEventTouch);
end

MenuButton.setOnChange  = function(self,obj,func) 
	self.m_obj = obj;
	self.m_func = func;
end

MenuButton.setPickView = function(self,view)
	self.pickView = view;
end

MenuButton.setState = function(self,checked)
	if checked == self.m_checked then
		return;
	end
	self.m_checked = checked;
	self:setImageIndex(self.m_checked and 1 or 0);

	if self.m_obj and self.m_func then
		self.m_func(self.m_obj,self.m_checked);
	end
end

MenuButton.getState = function(self)
	return self.m_checked;
end

MenuButton.dtor = function(self)
end


----------------------------------------------------------------------------------------------------
-------------------------------private functions, don't use these functions ------------------------
----------------------------------------------------------------------------------------------------

MenuButton.setEnable = function(self,enable)
	self.m_enable = enable;
end

MenuButton.onEventTouch = function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
	if not self.m_enable then return end;

    local color = 255;
	
	if finger_action==kFingerDown then
		if self.pickView then
			self.pickView:setPickable(false);
		end
	    color = 128;
	    self.m_startX = x;
		self.m_startY = y;
	elseif finger_action==kFingerMove then
		if drawing_id_first==drawing_id_current then
			color = 128;
		end
	end
	
	self:setColor(color,color,color);
	
	if finger_action==kFingerUp then
		if math.abs(y-self.m_startY) < MenuButton.s_maxClickOffset then
			if drawing_id_first==drawing_id_current then
		        SoundManager.getInstance():play_effect(SoundManager.AUDIO_BUTTON_CLICK);
        		self:setState(not self.m_checked);		
			end
		end
		if self.pickView then
			self.pickView:setPickable(true);
		end
	elseif finger_action==kFingerCancel then
		if self.pickView then
			self.pickView:setPickable(true);
		end
	end
end