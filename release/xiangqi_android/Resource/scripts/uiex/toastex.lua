require("ui/toast");

Toast.s_defaultSheildBgImage = "common/shade.png";


Toast.setDefaultImage = function(bgImg,sheildBgImg)
	Toast.s_defaultBgImage = bgImg or Toast.s_defaultBgImage;
	Toast.s_defaultSheildBgImage = sheildBgImg or Toast.s_defaultSheildBgImage;
end 

Toast.showText = function(self, str, width, height, align, fontName, fontSize, r, g, b , x, y)
	local view = new(Text,str,width,height,align or kAlignLeft,
		fontName or Toast.s_fontName,fontSize or Toast.s_fontSize,
		r or Toast.s_r,g or Toast.s_g,b or Toast.s_b);

	local w,h = view:getSize();
	bg = self:loadTextBg(w,h);
	bg:addChild(view);
	view:setAlign(kAlignCenter);

	bg:setPos(x , y);
	Toast.show(self,bg);
end
Toast.showTextView = function(self, str, width, height, align, fontName, fontSize, r, g, b,x, y)
	local view = new(TextView,str,width,height,align,fontName,fontSize,r,g,b);
	
	bg = self:loadTextBg(width, height);
	bg:addChild(view);
	view:setAlign(kAlignCenter);
	bg:setPos(x,y);
	
	Toast.show(self,bg);
end

Toast.showSheildText = function(self,str, width, height, align, fontName, fontSize, r, g, b)
	local view = self:loadText(str, width, height, align, fontName, fontSize, r, g, b);
	local sheildBg = self:loadSheild();

	sheildBg:addChild(view);
	view:setAlign(kAlignCenter);

	Toast.show(self,sheildBg);
end 

Toast.showSheildTextView = function(self, str, width, height, align, fontName, fontSize, r, g, b)
	local view = self:loadTextView(str,width,height,align,fontName,fontSize,r,g,b);

	local sheildBg = self:loadSheild();
	sheildBg:addChild(view);
	view:setAlign(kAlignCenter);

	Toast.show(self,sheildBg);
end 

Toast.showSheildView = function(self,viewType, ...)
	if not (viewType and self.m_typeMap[viewType]) then
		Toast.hidden(self);
		return;
	end

	local view = self.m_typeMap[viewType](...);
	local sheildBg = self:loadSheild();
	sheildBg:addChild(view);
	view:setAlign(kAlignCenter);
	Toast.show(self,sheildBg);
end 

------------------------ private ---------------------------------------------------------
Toast.show = function(self, view)
	Toast.hidden(self);

	if not view then
		return;
	end

	self.m_view = view;
	self.m_view:setLevel(199);
	self.m_view:addToRoot();
	self.m_view:setAlign(kAlignCenter);
	Toast.startTimer(self);
end

Toast.loadText = function(self, str, width, height, align, fontName, fontSize, r, g, b)
	local textStr = new(Text,str,width,height,align or kAlignLeft,
		fontName or Toast.s_fontName,fontSize or Toast.s_fontSize,
		r or Toast.s_r,g or Toast.s_g,b or Toast.s_b);

	local w,h = textStr:getSize();
	local view = self:loadTextBg(w,h);
	view:addChild(textStr);
	textStr:setAlign(kAlignCenter);

	return view;
end 

Toast.loadTextView = function(self, str, width, height, align, fontName, fontSize, r, g, b)
	local textStr = new(TextView,str,width,height,align,fontName,fontSize,r,g,b);
	local view = self:loadTextBg(width, height);
	view:addChild(textStr);
	textStr:setAlign(kAlignCenter);

	return view;
end 

Toast.loadSheild = function(self)
	local sheildBg = new(Image,Toast.s_defaultSheildBgImage);
	sheildBg:setSize(System.getScreenScaleWidth(),System.getScreenScaleHeight());
	sheildBg:setEventTouch(nil,function()
	end);

	return sheildBg;
end
