-- textView.lua
-- Author: Vicent Gong
-- Date: 2012-09-24
-- Last modification : 2013-07-05
-- Description: Implement a multi-line text,if needed it will scroll

require("core/constants");
require("core/object");
require("core/res");
require("core/drawing");
require("core/gameString");
require("ui/scrollableNode");

TextView = class(ScrollableNode,false);

TextView.s_defaultScrollBarWidth = 8;

TextView.setDefaultScrollBarWidth = function(width)
	TextView.s_scrollBarWidth = width or TextView.s_defaultScrollBarWidth;
end

TextView.ctor = function(self, str, width, height, align, fontName, fontSize, r, g, b, isTouch)
	super(self,kVertical,self.s_scrollBarWidth or self.s_defaultScrollBarWidth)

	self.m_str = TextView.convert2SafeString(self,str);
	local platformstr = TextView.convert2SafePlatformString(self,self.m_str);
	
    self.m_res = new(ResText,platformstr,width or 0, height or 0,align,fontName,fontSize,r,g,b,kTextMultiLines);
	self.m_drawing = new(DrawingImage,self.m_res);

	local drawingW,drawingH = self.m_drawing:getSize();
	TextView.setSize(self,width or drawingW,(not height or height == 0) and drawingH or height);
	
	TextView.addChild(self,self.m_drawing);
	
    self:setTouchEvent(not isTouch);

	
	TextView.update(self);
end
--by Leoli,设置textView是否拦截点击事件，默认是设置.
TextView.setTouchEvent = function(self, isTouch)
    if isTouch then
	   TextView.setEventTouch(self,self,self.onEventTouch);
    else
       TextView.setEventTouch(self,nil,nil);
    end;
    
end;
TextView.setScrollBarWidth = function(self, width)
	width = width 
			or self.s_scrollBarWidth 
			or self.s_defaultScrollBarWidth;

	ScrollableNode.setScrollBarWidth(self,width);
end

TextView.setText = function(self, str, width, height, r, g, b)
	self.m_str = TextView.convert2SafeString(self,str);
	local platformstr = TextView.convert2SafePlatformString(self,self.m_str);
	local w,h = TextView.getSize(self);

	width = width or w;
	height = height or h;

	self.m_res:setText(platformstr,width,height,r,g,b);
	self.m_drawing:setSize(self.m_res:getWidth(),self.m_res:getHeight());
	
	local drawingW,drawingH = self.m_drawing:getSize();
    
    if TextView.getScroller(self) then
	    TextView.getScroller(self):scrollToTop();
    end

	TextView.setSize(self,width,(height == 0) and drawingH or height);
	
	local x,y = TextView.getUnalignPos(self);
	local w,h = TextView.getSize(self);
	TextView.setClip(self,x,y,w,h);
	TextView.update(self);
end

TextView.getText = function(self)
	return self.m_str;
end

TextView.dtor = function(self)
    delete(self.m_res);
    self.m_res = nil;
end

-------------------------------private functions ----------------------------------------------------
--virtual

TextView.getFrameLength = function(self)
	local w,h = TextView.getSize(self);
	if self.m_direction == kVertical then
		return h;
	else
		return w;
	end
end

TextView.getViewLength = function(self)
    if not self.m_drawing then
        return 0;
    end
    
	local dw,dh = self.m_drawing:getSize();

	if self.m_direction == kVertical then
		return dh;
	else
		return dw;
	end
end

TextView.getUnitLength = function(self)
	return 1;
end

TextView.needScroller = function(self)
	return true;
end

TextView.getFrameOffset = function(self)
	return 0;
end

TextView.onScroll = function(self, scroll_status, diffY, totalOffset)
	ScrollableNode.onScroll(self,scroll_status,diffY,totalOffset);

	self.m_drawing:setPos(nil,totalOffset);
end

TextView.onEventTouch =  function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
	if not TextView.hasScroller(self) then return end
	self.m_scroller:onEventTouch(finger_action,x,y,drawing_id_first,drawing_id_current);
end

TextView.convert2SafeString = function(self, str)
	str = (str == "" or not str) and " " or str;
	return str;
end

TextView.convert2SafePlatformString = function(self, str)
	str = (str == "" or not str) and " " or str;
	local platformStr = GameString.convert2Platform(str);
	platformStr = (platformStr == "" or not platformStr) and " " or platformStr;

	return platformStr;
end	
