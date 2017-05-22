--功能和SelectButton一致,但是没有设置背景

SelectButtonNoBg = class(Images,false);

SelectButtonNoBg.ctor = function(self,fileNameArray,mode,fmt,filter,leftWidth,rightWidth,bottomWidth,topWidth)
    super(self,fileNameArray,fmt,filter,leftWidth,rightWidth,bottomWidth,topWidth);
	self:setEventTouch(self,self.onEventTouch);
	
	self.m_enable = true;
	self.m_checked = false;
end


SelectButtonNoBg.addChild = function(self,child)
	Images.addChild(self,child);
	child:setEventTouch(self,self.onEventTouch);
end

SelectButtonNoBg.setOnChange  = function(self,obj,func)
	self.m_obj = obj;
	self.m_func = func;
end

SelectButtonNoBg.setState = function(self,checked)
	if checked == self.m_checked then
		return;
	end
	
	self.m_checked = checked;
	self:setImageIndex(self.m_checked and 1 or 0);
	self:setImageIndex(self.m_checked and 1 or 0);

	if self.m_obj and self.m_func then
		self.m_func(self.m_obj,self.m_checked);
	end
end

SelectButtonNoBg.getState = function(self)
	return self.m_checked;
end

SelectButtonNoBg.dtor = function(self)
end


----------------------------------------------------------------------------------------------------
-------------------------------private functions, don't use these functions ------------------------
----------------------------------------------------------------------------------------------------

SelectButtonNoBg.setEnable = function(self,enable)
	self.m_enable = enable;
end

SelectButtonNoBg.onEventTouch = function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
	if not self.m_enable then return end;

	if self.m_checked then
		print_string("aready checked !!!");
		return
	end
	
    if finger_action == kFingerUp then 
       	kEffectPlayer:playEffect(Effects.AUDIO_BUTTON_CLICK);
        self:setState(not self.m_checked);
    end
end