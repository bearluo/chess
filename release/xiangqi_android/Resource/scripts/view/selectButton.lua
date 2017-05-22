SelectButton = class(Images,false);

SelectButton.MODE_LEFT = 1;
SelectButton.MODE_RIGHT = 2;

SelectButton.s_left = {"common/left_normal.png","common/left_choose.png"};
SelectButton.s_right = {"common/right_normal.png","common/right_choose.png"};


SelectButton.changeDefaultImages = function(image)
	SelectButton.s_imageNameUser = image or SelectButton.s_imageName;
end

SelectButton.ctor = function(self,fileNameArray,mode,fmt,filter,leftWidth,rightWidth,bottomWidth,topWidth)

	
	

	-- local array = {};
 --    for i=1,2 do 
 --        array[i] = string.format(SelectButton.s_imageNameUser,i);
 --    end
 	local array = SelectButton.s_right;
 	if mode and mode == SelectButton.MODE_LEFT then
 		array = SelectButton.s_left;
 	end
    super(self,array,fmt,filter,leftWidth,rightWidth,bottomWidth,topWidth);

    self.m_texture = new(Images,fileNameArray);
    local w,h = self.m_texture:getSize();
    local sw,sh = self:getSize();
    local x,y = (sw-w)/2,(sh-h)/2;
    self.m_texture:setPos(x,y);
    self:addChild(self.m_texture);
	self:setEventTouch(self,self.onEventTouch);
	
	self.m_enable = true;
	self.m_checked = false;
end


SelectButton.addChild = function(self,child)
	Images.addChild(self,child);
	child:setEventTouch(self,self.onEventTouch);
end

SelectButton.setOnChange  = function(self,obj,func)
	self.m_obj = obj;
	self.m_func = func;
end

SelectButton.setState = function(self,checked)
	if checked == self.m_checked then
		return;
	end
	
	self.m_checked = checked;
	self:setImageIndex(self.m_checked and 1 or 0);
	self.m_texture:setImageIndex(self.m_checked and 1 or 0);

	if self.m_obj and self.m_func then
		self.m_func(self.m_obj,self.m_checked);
	end
end

SelectButton.getState = function(self)
	return self.m_checked;
end

SelectButton.dtor = function(self)
end


----------------------------------------------------------------------------------------------------
-------------------------------private functions, don't use these functions ------------------------
----------------------------------------------------------------------------------------------------

SelectButton.setEnable = function(self,enable)
	self.m_enable = enable;
end

SelectButton.onEventTouch = function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
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