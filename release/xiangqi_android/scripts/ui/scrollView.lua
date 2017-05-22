-- scrollView.lua
-- Author: Vicent.Gong
-- Date: 2012-10-08
-- Last modification : 2013-07-05
-- Description: Implemented ScrollView 

require("core/constants");
require("core/object");
require("core/global");
require("ui/scrollableNode");

ScrollView = class(ScrollableNode,false);

ScrollView.s_defaultScrollBarWidth = 8;

ScrollView.setDefaultScrollBarWidth = function(width)
	ScrollView.s_scrollBarWidth = width or ScrollView.s_defaultScrollBarWidth;
end

ScrollView.ctor = function(self, x, y, w, h, autoPositionChildren)
	self.m_nodeW = 0;
	self.m_nodeH = 0;
    self.scrollEnable = true;
	super(self,kVertical,ScrollView.s_scrollBarWidth or ScrollView.s_defaultScrollBarWidth);

	ScrollableNode.setPos(self,x,y);
	ScrollableNode.setSize(self,w or 1,h or 1);
    local x,y = ScrollView.getUnalignPos(self);
    local w,h = ScrollView.getSize(self);
	ScrollView.setClip(self,x,y,w,h);
	
	ScrollView.setEventTouch(self,self,self.onEventTouch);
	ScrollView.setEventDrag(self,self,self.onEventDrag);
	
	self.m_autoPositionChildren = autoPositionChildren;

	self.m_mainNode = new(Node);
    self.m_mainNode:setSize(ScrollView.getSize(self));
	ScrollableNode.addChild(self,self.m_mainNode);

	ScrollView.update(self);
end

ScrollView.setScrollBarWidth = function(self, width)
	width = width 
		or ScrollView.s_scrollBarWidth 
		or ScrollView.s_defaultScrollBarWidth;

	ScrollableNode.setScrollBarWidth(self,width);
end

ScrollView.setDirection = function(self, direction)
	if (not direction) or self.m_direction == direction then
		return;
	end

	ScrollableNode.setDirection(self,direction);
end

ScrollView.setSize = function(self, w, h)
    ScrollableNode.setSize(self,w,h);
    self.m_mainNode:setSize(ScrollView.getSize(self));
end

ScrollView.getChildByName = function(self, name)
	return self.m_mainNode:getChildByName(name);
end

ScrollView.getChildren = function(self)
	return self.m_mainNode:getChildren();
end

ScrollView.addChild = function(self, child)
	self.m_mainNode:addChild(child);

	if self.m_autoPositionChildren then
		child:setAlign(kAlignTopLeft);
		child:setPos(self.m_nodeW,self.m_nodeH);
		local w,h = child:getSize();
		if self.m_direction == kVertical then
			self.m_nodeH = self.m_nodeH + h;
		else
			self.m_nodeW = self.m_nodeW + w;
		end
	else
		local x,y = child:getUnalignPos();
		local w,h = child:getSize();
		
		if self.m_direction == kVertical then
			self.m_nodeH = (self.m_nodeH > y + h) and self.m_nodeH or (y + h);
		else
			self.m_nodeW = (self.m_nodeW > x + w) and self.m_nodeW or (x + w);
		end
	end
	
	ScrollView.update(self);
end

ScrollView.removeChild = function(self, child, doCleanup)
	return self.m_mainNode:removeChild(child,doCleanup);
end

ScrollView.removeAllChildren = function(self, doCleanup)
	if self.m_autoPositionChildren then
		self.m_nodeW = 0;
		self.m_nodeH = 0;
	end
	if ScrollView.hasScroller(self) then
        Scroller.setOffset(self.m_scroller,0);
    end
	return self.m_mainNode:removeAllChildren(doCleanup);
end
-- by bearluo --孩子发生变化后更新个个孩子的位置 或者滚动的区域
ScrollView.updateScrollView = function(self)
	local totalOffset = 0;
    if self.m_direction == kVertical then
		_,totalOffset = self.m_mainNode:getPos();
	else
		totalOffset = self.m_mainNode:getPos();
	end
    -- totalOffset 为负数
    totalOffset = self:getFrameLength() - totalOffset;

    self.m_nodeW = 0;
	self.m_nodeH = 0;
    local childrens = self.m_mainNode:getChildren();
    for _,child in pairs(childrens) do
        if child then
            ScrollView.updateChildPos(self,child);
        end
    end
	ScrollView.update(self);
    if totalOffset > self:getViewLength() then
        local totalOffset = self:getFrameLength() - self:getViewLength();
        if totalOffset > 0 then totalOffset = 0; end
        if self.m_direction == kVertical then
		    self.m_mainNode:setPos(nil,totalOffset);
	    else
		    self.m_mainNode:setPos(totalOffset,nil);
	    end
    end
end

ScrollView.updateChildPos = function(self,child)
	if self.m_autoPositionChildren then
		child:setAlign(kAlignTopLeft);
		child:setPos(self.m_nodeW,self.m_nodeH);
		local w,h = child:getSize();
		if self.m_direction == kVertical then
			self.m_nodeH = self.m_nodeH + h;
		else
			self.m_nodeW = self.m_nodeW + w;
		end
	else
		local x,y = child:getUnalignPos();
		local w,h = child:getSize();
		
		if self.m_direction == kVertical then
			self.m_nodeH = (self.m_nodeH > y + h) and self.m_nodeH or (y + h);
		else
			self.m_nodeW = (self.m_nodeW > x + w) and self.m_nodeW or (x + w);
		end
	end
end

ScrollView.dtor = function(self)
	
end

--移除部分孩子节点
ScrollView.removeChildByPos = function(self,start_index,end_index,view_tab)
    local startIndex,endIndex;
    startIndex = (start_index < end_index) and start_index or end_index;
    endIndex = (start_index > end_index) and start_index or end_index;

    local child = self:getChildren();

    if #child == 0 then
        return;
    end
    local temp_tab = view_tab;

    for i = endIndex, startIndex, -1 do
        local view = table.remove(temp_tab,i);
        delete(view);
    end

    self:updateScrollView();
end
---------------------------------private functions-----------------------------------------

ScrollView.getFrameLength = function(self)
    local w,h = ScrollView.getSize(self);
	if self.m_direction == kVertical then
		return h;
	else
		return w;
	end
end

ScrollView.getViewLength = function(self)
	if self.m_direction == kVertical then
		return self.m_nodeH;
	else
		return self.m_nodeW;
	end
end

ScrollView.getUnitLength = function(self)
	return 1;
end

ScrollView.needScroller = function(self)
	return true;
end

ScrollView.getFrameOffset = function(self)
	return 0;
end

ScrollView.onEventTouch =  function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
	
end

ScrollView.onEventDrag =  function(self, finger_action, x, y,drawing_id_first, drawing_id_current)
	if not ScrollView.hasScroller(self) or not self.scrollEnable then return end
	self.m_scroller:onEventTouch(finger_action,x,y,drawing_id_first,drawing_id_current);
end

ScrollView.setScrollEnable = function(self,enable)
    self.scrollEnable = enable;
end

ScrollView.setOnScrollEvent = function(self,obj,func)
    self.m_onScrollEvent = {};
    self.m_onScrollEvent.obj = obj;
    self.m_onScrollEvent.func = func;
end

ScrollView.onScroll = function(self, scroll_status, diffY, totalOffset,isMarginRebounding)
	--isMarginRebounding,useless in ScrollView
	ScrollableNode.onScroll(self,scroll_status,diffY,totalOffset,true);
	if self.m_direction == kVertical then
		self.m_mainNode:setPos(nil,totalOffset);
	else
		self.m_mainNode:setPos(totalOffset,nil);
	end

    if self.m_onScrollEvent and self.m_onScrollEvent.func then
        self.m_onScrollEvent.func(self.m_onScrollEvent.obj,scroll_status, diffY, totalOffset,isMarginRebounding);
    end
end

ScrollView.getScrollViewPos = function(self)
    return self.m_mainNode:getPos();
end
