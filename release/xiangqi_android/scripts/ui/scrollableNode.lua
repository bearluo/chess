-- scrollableNode.lua
-- Author: Vicent Gong
-- Date: 2013-06-17
-- Last modification : 2013-07-05
-- Description: Implement a base class for all scrollable views

require("core/constants");
require("core/object");
require("ui/node");
require("ui/scroller");
require("ui/scrollBar");

ScrollableNode = class(Node);

ScrollableNode.ctor = function(self, direction, scrollBarWidth)
	ScrollableNode.setDirection(self,direction);
	self.m_scrollBarWidth = scrollBarWidth;	
	
	self.m_margrinReboudingCallback = {};
end

ScrollableNode.setOnMarginRebounding = function(self, obj, func)
	self.m_margrinReboudingCallback.obj = obj;
	self.m_margrinReboudingCallback.func = func;
end

--virtual functions
ScrollableNode.getFrameLength = function(self)
	error("Derived class must implement this function");
end

ScrollableNode.getViewLength = function(self)
	error("Derived class must implement this function");
end

ScrollableNode.getUnitLength = function(self)
	error("Derived class must implement this function");
end

ScrollableNode.getFrameOffset = function(self)
	error("Derived class must implement this function");
end

ScrollableNode.needScroller = function(self)
	error("Derived class must implement this function");
end

ScrollableNode.needScrollBar = function(self)
	return self.m_scrollBarWidth and self.m_scrollBarWidth >= 1;
end

ScrollableNode.setDirection = function(self, direction)
	self.m_direction = direction;

	ScrollableNode.recreate(self);
end

ScrollableNode.setScrollBarWidth = function(self, width)
	self.m_scrollBarWidth = width;
	ScrollableNode.updateScrollBar(self);
	ScrollableNode.updateScrollBarPosAndSize(self);
end

ScrollableNode.getScroller = function(self)
	return self.m_scroller;
end

-- 设置回弹调用
ScrollableNode.setUpReboundCallback = function(self, func, obj)
	if self.m_scroller then
		self.m_scroller:setUpReboundCallback(func, obj);
	end
end

-- 设置回弹调用
ScrollableNode.setDownReboundCallback = function(self, func, obj)
	if self.m_scroller then
		self.m_scroller:setDownReboundCallback(func, obj);
	end
end

ScrollableNode.getScrollBar = function(self)
	return self.m_scrollBar;
end	

ScrollableNode.update = function(self)
	ScrollableNode.updateScroller(self);
	ScrollableNode.updateScrollBar(self);
end

ScrollableNode.stop = function(self)
	ScrollableNode.stopScroller(self);
end	

ScrollableNode.recreate = function(self)
	ScrollableNode.releaseScroller(self);
	ScrollableNode.releaseScrollBar(self);

	ScrollableNode.updateScroller(self);
	ScrollableNode.updateScrollBar(self);
end

ScrollableNode.setVisible = function(self, visible)
	ScrollableNode.stopScroller(self);
	Node.setVisible(self,visible);
	ScrollableNode.setScrollbarInvisible(self);
end

ScrollableNode.setPos = function(self, x, y)
	Node.setPos(self,x,y);
	local x,y = ScrollableNode.getUnalignPos(self);
	local w,h = ScrollableNode.getSize(self);
	ScrollableNode.setClip(self,x,y,w,h);
end

ScrollableNode.setSize = function(self, w, h)
	Node.setSize(self,w,h);
	local x,y = ScrollableNode.getUnalignPos(self);
	local w,h = ScrollableNode.getSize(self);
	ScrollableNode.setClip(self,x,y,w,h);
	ScrollableNode.update(self);
end

ScrollableNode.setAlign = function(self, align)
	Node.setAlign(self,align);
	local x,y = ScrollableNode.getUnalignPos(self);
	local w,h = ScrollableNode.getSize(self);
	ScrollableNode.setClip(self,x,y,w,h);
end

ScrollableNode.setFillRegion = function(self, doFill, topLeftX, topLeftY, bottomRightX, bottomRightY)
	Node.setFillRegion(self,doFill,topLeftX,topLeftY,bottomRightX,bottomRightY);
	local x,y = ScrollableNode.getUnalignPos(self);
	local w,h = ScrollableNode.getSize(self);
	ScrollableNode.setClip(self,x,y,w,h);
	ScrollableNode.update(self);
end

ScrollableNode.setFillParent = function(self, doFillParentWidth, doFillParentHeight)
	Node.setFillParent(self,doFillParentWidth,doFillParentHeight);
	local x,y = ScrollableNode.getUnalignPos(self);
	local w,h = ScrollableNode.getSize(self);
	ScrollableNode.setClip(self,x,y,w,h);
	ScrollableNode.update(self);
end

ScrollableNode.gotoTop = function(self)
	if self:hasScroller() then
		self.m_scroller:scrollToTop();
	end
end

ScrollableNode.gotoBottom = function(self)
	if self:hasScroller() then
		self.m_scroller:scrollToBottom();
	end
end

ScrollableNode.scrollToPos = function(self,pos)
    if self:hasScroller() then
		self.m_scroller:scrollToPos(pos);
	end
end

ScrollableNode.dtor = function(self)
	ScrollableNode.releaseScroller(self);
end

------------------------------------------------------------------------------------------------

ScrollableNode.reviseSize = function(self)
	Node.reviseSize(self);
	local x,y = ScrollableNode.getUnalignPos(self);
	local w,h = ScrollableNode.getSize(self);
	ScrollableNode.setClip(self,x,y,w,h);
	ScrollableNode.update(self);
end

ScrollableNode.revisePos = function(self)
	Node.revisePos(self);
	local x,y = ScrollableNode.getUnalignPos(self);
	local w,h = ScrollableNode.getSize(self);
	ScrollableNode.setClip(self,x,y,w,h);
	ScrollableNode.update(self);
end

---------------------------------private functions-----------------------------------------

--scroller
ScrollableNode.hasScroller = function(self)
	return self.m_scroller ~= nil;
end

ScrollableNode.createScroller = function(self)
	local frameLength = self:getFrameLength();
	local viewLength = self:getViewLength();
	local unitLength = self:getUnitLength();

	self.m_scroller = new(Scroller,self.m_direction,frameLength,viewLength,unitLength);
	self.m_scroller:setScrollCallback(self,self.onScroll);
end

ScrollableNode.releaseScroller = function(self)
	delete(self.m_scroller);
	self.m_scroller = nil;
end

ScrollableNode.stopScroller = function(self)
	if ScrollableNode.hasScroller(self) then
		self.m_scroller:stop();
	end
end

ScrollableNode.updateScroller = function(self)
	if not (self:needScroller() 
		and ScrollableNode.isAllLengthVaild(self) 
		and ScrollableNode.isViewBiggerThanFrame(self)) then

		ScrollableNode.releaseScroller(self);
		return;
	end

	if ScrollableNode.hasScroller(self) then
		local frameLength = self:getFrameLength();
		local viewLength = self:getViewLength();
		local unitLength = self:getUnitLength();
		self.m_scroller:setFrameLength(frameLength);
		self.m_scroller:setViewLength(viewLength);
		self.m_scroller:setUnitLength(unitLength);
		self.m_scroller:stopMarginRebounding();
	else
		ScrollableNode.createScroller(self);
	end
end

ScrollableNode.setFlippingOverFactor = function(self,factor)
    if ScrollableNode.hasScroller(self) then
		self.m_scroller:setFlippingOverFactor(factor);
	end
end

ScrollableNode.setReboundMargin = function(self,forwardMargin, backwardMargin)
    if ScrollableNode.hasScroller(self) then
		self.m_scroller:setReboundMargin(forwardMargin, backwardMargin);
	end
end


--scrollbar
ScrollableNode.hasScrollBar = function(self)
	return self.m_scrollBar ~= nil;
end

ScrollableNode.createScrollBar = function(self)
	local frameLength = self:getFrameLength();
	local viewLength = self:getViewLength();

	self.m_scrollBar = new(ScrollBar,self.m_direction,frameLength,viewLength);
    ScrollableNode.addChild(self,self.m_scrollBar);
    self.m_scrollBar:setStartPos(self:getFrameOffset());
    ScrollableNode.updateScrollBarPosAndSize(self);
    self.m_scrollBar:setLevel(1);
    self.m_scrollBar:setVisibleImmediately(false);
end

ScrollableNode.releaseScrollBar = function(self)
	if ScrollableNode.hasScrollBar(self) then
		ScrollableNode.removeChild(self,self.m_scrollBar);
		delete(self.m_scrollBar);
		self.m_scrollBar = nil;
	end
end

ScrollableNode.updateScrollBar = function(self)
	if not (self:needScrollBar() 
		and ScrollableNode.isAllLengthVaild(self)
		and ScrollableNode.isViewBiggerThanFrame(self)) then

		ScrollableNode.releaseScrollBar(self);
		return;
	end

	if ScrollableNode.hasScrollBar(self) then
		self.m_scrollBar:setFrameLength(self:getFrameLength());
   		self.m_scrollBar:setViewLength(self:getViewLength());
   		self.m_scrollBar:setStartPos(self:getFrameOffset());
   	else
   		ScrollableNode.createScrollBar(self);
   	end
end

ScrollableNode.setScrollbarInvisible = function(self)
	if ScrollableNode.hasScrollBar(self) then
		self.m_scrollBar:setVisibleImmediately(false);
	end
end

ScrollableNode.updateScrollBarPosAndSize = function(self)
    if not ScrollableNode.needScrollBar(self) then
        ScrollableNode.releaseScrollBar(self);
        return;
    end
    
	if not ScrollableNode.hasScrollBar(self) then
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
ScrollableNode.isAllLengthVaild = function(self)
	local frameLength = self:getFrameLength();
	local viewLength = self:getViewLength();
	local unitLength = self:getUnitLength();

	return frameLength and viewLength and unitLength and 
		frameLength > 0 and viewLength > 0 and unitLength > 0;
end

ScrollableNode.isViewBiggerThanFrame = function(self)
	local frameLength = self:getFrameLength();
	local viewLength = self:getViewLength();
	return viewLength > frameLength;
end

ScrollableNode.onScroll = function(self, scroll_status, diff, totalOffset, isMarginRebounding)
	if ScrollableNode.hasScrollBar(self) and (not isMarginRebounding) then 
		self.m_scrollBar:setScrollPos(totalOffset);
	end

	if kScrollerStatusStop == scroll_status then
		if ScrollableNode.hasScrollBar(self) then 
			self.m_scrollBar:setVisible(false);
		end
	end
	
	--ugly , refactor later
	if isMarginRebounding then
	    local align;
        if totalOffset >= 0 then
            if self.m_direction == kVertical then
                align = kAlignTop;
            else
                align = kAlignLeft;
            end
        else
            if self.m_direction == kVertical then
                align = kAlignBottom;
            else
                align = kAlignRight;
            end
        end
	    if kScrollerStatusMoving == scroll_status and (not self.m_lastIsMarginRebouding) then
	        if self.m_margrinReboudingCallback.func then
	            self.m_margrinReboudingCallback.func(self.m_margrinReboudingCallback.obj,kScrollerStatusStart,align);
	        end
	    elseif kScrollerStatusStop == scroll_status then
	        if self.m_margrinReboudingCallback.func then
	            self.m_margrinReboudingCallback.func(self.m_margrinReboudingCallback.obj,kScrollerStatusStop,align);
	        end
	    end
	end
	self.m_lastIsMarginRebouding = isMarginRebounding;
end
