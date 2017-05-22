--
-- UI2 Library, Version: 1.0 Alpha (0.99.2.2058-SNAPSHOT)
-- 
-- This file is a part of UI2 Library.
--
-- Author:
-- Xiaofeng Yang     2015
-- Vicent Gong       2012
--
--

--- 
--
-- @module textView2

require("core/constants");
require("core/object");
require("core/res");
require("core/drawing");
require("core/gameString");
require("ui2/compat/scrollableNode2");

TextView2 = class(ScrollableNode2,false);

TextView2.s_defaultScrollBarWidth = 8;

TextView2.setDefaultScrollBarWidth = function(width)
    TextView2.s_scrollBarWidth = width or TextView2.s_defaultScrollBarWidth;
end

TextView2.ctor = function(self, str, width, height, align, fontName, fontSize, r, g, b)
    super(self,kVertical,self.s_scrollBarWidth or self.s_defaultScrollBarWidth)

    self.m_str = TextView2.convert2SafeString(self,str);
    local platformstr = TextView2.convert2SafePlatformString(self,self.m_str);
    
    self.m_res = new(ResText,platformstr,width or 0, height or 0,align,fontName,fontSize,r,g,b,kTextMultiLines);
    self.m_drawing = new(DrawingImage,self.m_res);

    local drawingW,drawingH = self.m_drawing:getSize();
    TextView2.setSize(self,width or drawingW,(not height or height == 0) and drawingH or height);
    
    TextView2.addChild(self,self.m_drawing);
    
    TextView2.setEventTouch(self,self,self.onEventTouch);
    
    TextView2.update(self);
end

TextView2.setScrollBarWidth = function(self, width)
    width = width 
            or self.s_scrollBarWidth 
            or self.s_defaultScrollBarWidth;

    ScrollableNode2.setScrollBarWidth(self,width);
end

TextView2.setText = function(self, str, width, height, r, g, b)
    self.m_str = TextView2.convert2SafeString(self,str);
    local platformstr = TextView2.convert2SafePlatformString(self,self.m_str);
    local w,h = TextView2.getSize(self);

    width = width or w;
    height = height or h;

    self.m_res:setText(platformstr,width,height,r,g,b);
    self.m_drawing:setSize(self.m_res:getWidth(),self.m_res:getHeight());
    
    local drawingW,drawingH = self.m_drawing:getSize();
    TextView2.setSize(self,width,(height == 0) and drawingH or height);
    
    local x,y = TextView2.getUnalignPos(self);
    local w,h = TextView2.getSize(self);
    TextView2.setClip(self,x,y,w,h);
    
    TextView2.update(self);
end

TextView2.getText = function(self)
    return self.m_str;
end

TextView2.dtor = function(self)
    delete(self.m_res);
    self.m_res = nil;
end

-------------------------------private functions ----------------------------------------------------
--virtual

TextView2.getFrameLength = function(self)
    local w,h = TextView2.getSize(self);
    if self.m_direction == kVertical then
        return h;
    else
        return w;
    end
end

TextView2.getViewLength = function(self)
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

TextView2.needScroller = function(self)
    return true;
end

TextView2.getFrameOffset = function(self)
    return 0;
end

TextView2.onScroll = function(self, totalOffset)
    ScrollableNode2.onScroll(self,totalOffset);

    self.m_drawing:setPos(nil,totalOffset);
end


TextView2.onEventTouch =  function(self, finger_action, x, y, drawing_id_first, drawing_id_current, event_time)
    if not TextView2.hasScroller(self) then return end
    self.m_scroller:onEventTouch(finger_action,x,y,drawing_id_first,drawing_id_current, event_time);
end

TextView2.convert2SafeString = function(self, str)
    str = (str == "" or not str) and "" or str;
    return str;
end

TextView2.convert2SafePlatformString = function(self, str)
    str = (str == "" or not str) and "" or str;
    local platformStr = GameString.convert2Platform(str);
    platformStr = (platformStr == "" or not platformStr) and "" or platformStr;

    return platformStr;
end	
