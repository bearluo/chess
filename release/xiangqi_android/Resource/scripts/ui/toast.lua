-- toast.lua
-- Author: Vicent.Gong
-- Date: 2013-08-01
-- Last modification : 2013-08-01
-- Description: Implemented toast

require("core/object");
require("ui/text");
require("ui/textView");
require("core/anim");

Toast = class();

Toast.s_defaultDisplayTime = 1500; -- millsecond
Toast.s_defaultBgImage = "ui/toast_bg.png";
Toast.s_defaultSpaceW = 20;
Toast.s_defaultSpaceH = 10;

Toast.getInstance = function()
	if not Toast.s_instance then 
		Toast.s_instance = new(Toast);
	end
	return Toast.s_instance;
end

Toast.releaseInstance = function()
	delete(Toast.s_instance);
	Toast.s_instance = nil;
end

Toast.setDefaultDisplayTime = function(millsecond)
	Toast.s_displayTime = millsecond or Toast.s_defaultDisplayTime;
end

Toast.setDefaultFontNameAndSize = function(fontName, fontSize)
	Toast.s_fontName = fontName;
	Toast.s_fontSize = fontSize;
end

Toast.setDefaultColor = function(r, g, b)
	Toast.s_r = r;
	Toast.s_g = g;
	Toast.s_b = b;
end

Toast.setDefaultImage = function(bgImg)
	Toast.s_defaultBgImage = bgImg or Toast.s_defaultBgImage;
end 

Toast.ctor = function(self)
	self.m_typeMap = {};
end

Toast.showText = function(self, str, width, height, align, fontName, fontSize, r, g, b)
	local view = new(Text,str,width,height,align or kAlignLeft,
		fontName or Toast.s_fontName,fontSize or Toast.s_fontSize,
		r or Toast.s_r,g or Toast.s_g,b or Toast.s_b);

	local w,h = view:getSize();
	bg = self:loadTextBg(w,h);
	bg:addChild(view);
	view:setAlign(kAlignCenter);

	Toast.show(self,bg);
end

Toast.showTextView = function(self, str, width, height, align, fontName, fontSize, r, g, b)
	local view = new(TextView,str,width,height,align,fontName,fontSize,r,g,b);
	
	bg = self:loadTextBg(width, height);
	bg:addChild(view);
	view:setAlign(kAlignCenter);

	Toast.show(self,bg);
end 

Toast.showView = function(self, viewType, ...)
	if not (viewType and self.m_typeMap[viewType]) then
		Toast.hidden(self);
		return;
	end

	local view = self.m_typeMap[viewType](...);
	Toast.show(self,view);
end

Toast.registerView = function(self, viewType, viewFunc)
	if not (viewType and viewFunc) then
		return;
	end
	self.m_typeMap[viewType] = viewFunc;
end

Toast.hidden = function(self)
	Toast.stopTimer(self);

	delete(self.m_view);
	self.m_view = nil;
end

Toast.dtor = function(self)
	self.m_typeMap = nil;
end

-------------------------------private functions ----------------------------------------------------

Toast.show = function(self, view)
	Toast.hidden(self);

	if not view then
		return;
	end

	self.m_view = view;
	self.m_view:addToRoot();
	self.m_view:setAlign(kAlignCenter);
	Toast.startTimer(self);
end

Toast.startTimer = function(self)
	self.m_timer = new(AnimDouble,kAnimNormal,0,1,Toast.s_displayTime or Toast.s_defaultDisplayTime,-1);
    self.m_timer:setDebugName("Toast.startTimer");
	self.m_timer:setEvent(self,Toast.onTimer);
end

Toast.stopTimer = function(self)
	delete(self.m_timer);
	self.m_timer = nil;
end

Toast.onTimer = function(self)
	Toast.hidden(self);
end

Toast.loadTextBg = function(self,w,h)
	local bg = new(Image,Toast.s_defaultBgImage,nil,nil,25,25,0,0);
	local bg_w,bg_h = bg:getSize();
	local tempW,tempH = w+Toast.s_defaultSpaceW*2,h+Toast.s_defaultSpaceH*2;

	bg_w = tempW > bg_w and tempW or bg_w;
	bg_h = tempH > bg_h and tempH or bg_h;
	bg:setSize(bg_w,bg_h);

	return bg;
end
