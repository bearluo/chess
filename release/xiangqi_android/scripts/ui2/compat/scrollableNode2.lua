--
-- UI2 Library, Version: 1.0 Alpha (0.99.2.2058-SNAPSHOT)
-- 
-- This file is a part of UI2 Library.
--
-- Author:
-- Xiaofeng Yang     2015
-- Vicent Gong       2013
--
--

--- 
--
-- @module scrollableNode2

require("core/constants");
require("core/object");
require("ui/node");
require("ui2/compat/scrollBar2");
require("ui2/compat/scroller2");



ScrollableNode2 = class(Node);

ScrollableNode2.ctor = function(self, direction, scrollBarWidth)
    ScrollableNode2.setDirection(self,direction);
    self.m_scrollBarWidth = scrollBarWidth;    
    
    self.m_onScrollEnd = function () end 
    self.m_onScrollBouncing = function () end
end

--virtual functions
ScrollableNode2.getFrameLength = function(self)
    error("Derived class must implement this function");
end

ScrollableNode2.getViewLength = function(self)
    error("Derived class must implement this function");
end

ScrollableNode2.getFrameOffset = function(self)
    error("Derived class must implement this function");
end

ScrollableNode2.needScroller = function(self)
    error("Derived class must implement this function");
end

ScrollableNode2.needScrollBar = function(self)
    return self.m_scrollBarWidth and self.m_scrollBarWidth >= 1;
end

ScrollableNode2.setDirection = function(self, direction)
    self.m_direction = direction;

    ScrollableNode2.recreate(self);
end

ScrollableNode2.setScrollBarWidth = function(self, width)
    self.m_scrollBarWidth = width;
    ScrollableNode2.updateScrollBar(self);
    ScrollableNode2.updateScrollBarPosAndSize(self);
end

ScrollableNode2.getScroller = function(self)
    return self.m_scroller;
end

ScrollableNode2.getScrollBar = function(self)
    return self.m_scrollBar;
end    

ScrollableNode2.update = function(self)
    ScrollableNode2.releaseScroller(self);
    ScrollableNode2.updateScroller(self);
    ScrollableNode2.updateScrollBar(self);
end

ScrollableNode2.stop = function(self)
    ScrollableNode2.stopScroller(self);
end    

ScrollableNode2.recreate = function(self)
    ScrollableNode2.releaseScroller(self);
    ScrollableNode2.releaseScrollBar(self);

    ScrollableNode2.updateScroller(self);
    ScrollableNode2.updateScrollBar(self);
end

ScrollableNode2.setVisible = function(self, visible)
    ScrollableNode2.stopScroller(self);
    Node.setVisible(self,visible);
    ScrollableNode2.setScrollbarInvisible(self);
end

ScrollableNode2.setPos = function(self, x, y)
    Node.setPos(self,x,y);
    local x,y = ScrollableNode2.getUnalignPos(self);
    local w,h = ScrollableNode2.getSize(self);
    ScrollableNode2.setClip(self,x,y,w,h);
end

ScrollableNode2.setSize = function(self, w, h)
    Node.setSize(self,w,h);
    local x,y = ScrollableNode2.getUnalignPos(self);
    local w,h = ScrollableNode2.getSize(self);
    ScrollableNode2.setClip(self,x,y,w,h);
    ScrollableNode2.update(self);
end

ScrollableNode2.setAlign = function(self, align)
    Node.setAlign(self,align);
    local x,y = ScrollableNode2.getUnalignPos(self);
    local w,h = ScrollableNode2.getSize(self);
    ScrollableNode2.setClip(self,x,y,w,h);
end

ScrollableNode2.setFillRegion = function(self, doFill, topLeftX, topLeftY, bottomRightX, bottomRightY)
    Node.setFillRegion(self,doFill,topLeftX,topLeftY,bottomRightX,bottomRightY);
    local x,y = ScrollableNode2.getUnalignPos(self);
    local w,h = ScrollableNode2.getSize(self);
    ScrollableNode2.setClip(self,x,y,w,h);
    ScrollableNode2.update(self);
end

ScrollableNode2.setFillParent = function(self, doFillParentWidth, doFillParentHeight)
    Node.setFillParent(self,doFillParentWidth,doFillParentHeight);
    local x,y = ScrollableNode2.getUnalignPos(self);
    local w,h = ScrollableNode2.getSize(self);
    ScrollableNode2.setClip(self,x,y,w,h);
    ScrollableNode2.update(self);
end

ScrollableNode2.gotoTop = function(self)
    if self:hasScroller() then
        self.m_scroller:scrollToTop();
    end
end

ScrollableNode2.gotoBottom = function(self)
    if self:hasScroller() then
        self.m_scroller:scrollToBottom();
    end
end

ScrollableNode2.dtor = function(self)
    ScrollableNode2.releaseScroller(self);
end

------------------------------------------------------------------------------------------------

ScrollableNode2.reviseSize = function(self)
    Node.reviseSize(self);
    local x,y = ScrollableNode2.getUnalignPos(self);
    local w,h = ScrollableNode2.getSize(self);
    ScrollableNode2.setClip(self,x,y,w,h);
    ScrollableNode2.update(self);
end

ScrollableNode2.revisePos = function(self)
    Node.revisePos(self);
    local x,y = ScrollableNode2.getUnalignPos(self);
    local w,h = ScrollableNode2.getSize(self);
    ScrollableNode2.setClip(self,x,y,w,h);
    ScrollableNode2.update(self);
end

---------------------------------private functions-----------------------------------------

--scroller
ScrollableNode2.hasScroller = function(self)
    return self.m_scroller ~= nil;
end

ScrollableNode2.createScroller = function(self)
    local frameLength = self:getFrameLength();
    local viewLength = self:getViewLength();

    self.m_scroller = new(Scroller2,self.m_direction,frameLength,viewLength);

    self.m_scroller:setScrollCallback(self,self.onScroll);
    self.m_scroller:setOnScrollEnd(nil, function () 
        self.m_onScrollEnd();
    end)
    self.m_scroller:setOnScrollBouncing(nil, function (obj,direction) 
        self.m_onScrollBouncing(direction);
    end)
end

ScrollableNode2.releaseScroller = function(self)
    delete(self.m_scroller);
    self.m_scroller = nil;
end

ScrollableNode2.stopScroller = function(self)
    if ScrollableNode2.hasScroller(self) then
        self.m_scroller:stop();
    end
end

ScrollableNode2.updateScroller = function(self)
    if not (self:needScroller() 
        and ScrollableNode2.isAllLengthVaild(self) 
        and ScrollableNode2.isViewBiggerThanFrame(self)) then

        ScrollableNode2.releaseScroller(self);
        return;
    end

    if ScrollableNode2.hasScroller(self) then
        self.m_scroller:stop();

        local frameLength = self:getFrameLength();
        local viewLength = self:getViewLength();
        self.m_scroller:setFrameLength(frameLength);
        self.m_scroller:setViewLength(viewLength);
    else
        ScrollableNode2.createScroller(self);
    end
end

--scrollbar
ScrollableNode2.hasScrollBar = function(self)
    return self.m_scrollBar ~= nil;
end

ScrollableNode2.createScrollBar = function(self)
    local frameLength = self:getFrameLength();
    local viewLength = self:getViewLength();

    self.m_scrollBar = new(ScrollBar2,self.m_direction,frameLength,viewLength);
    ScrollableNode2.addChild(self,self.m_scrollBar);
    self.m_scrollBar:setStartPos(self:getFrameOffset());
    ScrollableNode2.updateScrollBarPosAndSize(self);
    self.m_scrollBar:setLevel(1);
    self.m_scrollBar:setVisibleImmediately(false);
end

ScrollableNode2.releaseScrollBar = function(self)
    if ScrollableNode2.hasScrollBar(self) then
        ScrollableNode2.removeChild(self,self.m_scrollBar);
        delete(self.m_scrollBar);
        self.m_scrollBar = nil;
    end
end

ScrollableNode2.updateScrollBar = function(self)
    if not (self:needScrollBar() 
        and ScrollableNode2.isAllLengthVaild(self)
        and ScrollableNode2.isViewBiggerThanFrame(self)) then

        ScrollableNode2.releaseScrollBar(self);
        return;
    end

    if ScrollableNode2.hasScrollBar(self) then
        self.m_scrollBar:setFrameLength(self:getFrameLength());
        self.m_scrollBar:setViewLength(self:getViewLength());
        self.m_scrollBar:setStartPos(self:getFrameOffset());
    else
        ScrollableNode2.createScrollBar(self);
    end
end

ScrollableNode2.setScrollbarInvisible = function(self)
    if ScrollableNode2.hasScrollBar(self) then
        self.m_scrollBar:setVisibleImmediately(false);
    end
end

ScrollableNode2.updateScrollBarPosAndSize = function(self)
    if not ScrollableNode2.needScrollBar(self) then
        ScrollableNode2.releaseScrollBar(self);
        return;
    end
    
    if not ScrollableNode2.hasScrollBar(self) then
        return;
    end

    if self.m_direction == kVertical then
        self.m_scrollBar:setAlign(kAlignTopRight);
        self.m_scrollBar:setPos(0,0);
        self.m_scrollBar:setSize(self.m_scrollBarWidth,nil);
    else
        self.m_scrollBar:setAlign(kAlignBottomLeft);
        self.m_scrollBar:setPos(0,0);
        self.m_scrollBar:setSize(nil,self.m_scrollBarWidth);
    end
end

--others
ScrollableNode2.isAllLengthVaild = function(self)
    local frameLength = self:getFrameLength();
    local viewLength = self:getViewLength();

    return frameLength and viewLength and 
        frameLength > 0 and viewLength > 0;
end

ScrollableNode2.isViewBiggerThanFrame = function(self)
    local frameLength = self:getFrameLength();
    local viewLength = self:getViewLength();
    return viewLength > frameLength;
end

ScrollableNode2.onScroll = function(self, totalOffset)
    if ScrollableNode2.hasScrollBar(self) then 
        self.m_scrollBar:setScrollPos(totalOffset);
    end
end

ScrollableNode2.setOnScrollEnd = function (self, obj, fn)
    if fn then 
        self.m_onScrollEnd = function ()
            fn(obj);
        end 
    else 
        self.m_onScrollEnd = function () end
    end     
end 

ScrollableNode2.setOnScrollBouncing = function (self ,obj, fn)
    if fn then 
        self.m_onScrollBouncing = function (direction) 
            fn(obj,direction);
        end
    else
        self.m_onScrollBouncing = function () end
    end 
end
