require("ui/slider");

Slider.ctor = function(self, width, height, bgImage, fgImage, buttonImage,leftWidth, rightWidth, topWidth, bottomWidth)
	self.m_bgImage = bgImage or Slider.s_bgImage or Slider.s_defaultBgImage;
    self.m_fgImage = fgImage or Slider.s_fgImage or Slider.s_defaultFgImage;
    self.m_buttonImage = buttonImage or Slider.s_buttonImage or Slider.s_defaultButtonImage;

	self.m_bg = new(Image,self.m_bgImage,nil,nil,leftWidth or 8,rightWidth or 8,topWidth or 8,bottomWidth or 8);
	width = (width and width >= 1) and width or self.m_bg:getSize();
	height = (height and height >= 1) and height or select(2,self.m_bg:getSize());
	
	Slider.setSize(self,width,height);
	
	Slider.addChild(self,self.m_bg);
	self.m_bg:setFillParent(true,true);

	self.m_fg = new(Image,self.m_fgImage,nil,nil,leftWidth or 8,rightWidth or 8,topWidth or 8,bottomWidth or 8);

	Slider.addChild(self,self.m_fg);
	self.m_fg:setFillParent(true,true);
	
	self.m_button = new(Image,self.m_buttonImage);
	Slider.addChild(self,self.m_button);
	self.m_button:setAlign(kAlignLeft);
	self.m_button:setPos(0,0);
	self.m_button:setEventTouch(self,self.onEventTouch);
	
	self.m_width = width;
	self.m_changeCallback = {};
	Slider.setProgress(self,1.0);

end

