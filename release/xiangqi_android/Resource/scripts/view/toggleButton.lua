ToggleButton = class(Images,false);

ToggleButton.s_imageName = "drawable/toggle%d.png";
ToggleButton.s_imageNameUser = "drawable/toggle%d.png";

ToggleButton.changeDefaultImages = function(image)
	ToggleButton.s_imageNameUser = image or ToggleButton.s_imageName;
end

ToggleButton.ctor = function(self,fileNameArray,fmt,filter,leftWidth,rightWidth,bottomWidth,topWidth)
	local array = fileNameArray;
	if not array then
		array = {};
        for i=1,2 do 
            array[i] = string.format(ToggleButton.s_imageNameUser,i);
        end
    end
	super(self,array,fmt,filter,leftWidth,rightWidth,bottomWidth,topWidth);
	
	self:setEventTouch(self,self.onEventTouch);
	
	self.m_enable = true;
	self.m_checked = false;
end


ToggleButton.addChild = function(self,child)
	Images.addChild(self,child);
	child:setEventTouch(self,self.onEventTouch);
end

ToggleButton.setOnChange  = function(self,obj,func)
	self.m_obj = obj;
	self.m_func = func;
end

ToggleButton.setState = function(self,checked)
	if checked == self.m_checked then
		return;
	end
	self.m_checked = checked;
	self:setImageIndex(self.m_checked and 1 or 0);

	if self.m_obj and self.m_func then
		self.m_func(self.m_obj,self.m_checked);
	end
end

ToggleButton.getState = function(self)
	return self.m_checked;
end

ToggleButton.dtor = function(self)
end


----------------------------------------------------------------------------------------------------
-------------------------------private functions, don't use these functions ------------------------
----------------------------------------------------------------------------------------------------

ToggleButton.setEnable = function(self,enable)
	self.m_enable = enable;
end

ToggleButton.onEventTouch = function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
	if not self.m_enable then return end;
	
    if finger_action == kFingerUp then 
--    	SoundManager.getInstance():play_effect(SoundManager.AUDIO_BUTTON_CLICK);
        self:setState(not self.m_checked);
    end
end