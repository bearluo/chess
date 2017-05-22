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
-- @module scrollView2

require("core/constants");
require("core/object");
require("core/global");
require("ui2/compat/scrollableNode2");

ScrollView2 = class(ScrollableNode2,false);

ScrollView2.s_defaultScrollBarWidth = 8;

ScrollView2.setDefaultScrollBarWidth = function(width)
    ScrollView2.s_scrollBarWidth = width or ScrollView2.s_defaultScrollBarWidth;
end

ScrollView2.ctor = function(self, x, y, w, h, autoPositionChildren)
    super(self,kVertical,ScrollView2.s_scrollBarWidth or ScrollView2.s_defaultScrollBarWidth);

    ScrollableNode2.setPos(self,x,y);
    ScrollableNode2.setSize(self,w or 1,h or 1);
    local x,y = ScrollView2.getUnalignPos(self);
    local w,h = ScrollView2.getSize(self);
    ScrollView2.setClip(self,x,y,w,h);
    
    ScrollView2.setEventTouch(self,self,self.onEventTouch);
    ScrollView2.setEventDrag(self,self,self.onEventDrag);
    
    self.m_autoPositionChildren = autoPositionChildren;

    self.m_mainNode = new(Node);
    self.m_mainNode:setSize(ScrollView2.getSize(self));
    ScrollableNode2.addChild(self,self.m_mainNode);
    self.m_nodeW = 0;
    self.m_nodeH = 0;

    ScrollView2.update(self);
end

ScrollView2.setScrollBarWidth = function(self, width)
    width = width 
        or ScrollView2.s_scrollBarWidth 
        or ScrollView2.s_defaultScrollBarWidth;

    ScrollableNode2.setScrollBarWidth(self,width);
end

ScrollView2.setDirection = function(self, direction)
    if (not direction) or self.m_direction == direction then
        return;
    end

    ScrollableNode2.setDirection(self,direction);
end

ScrollView2.setSize = function(self, w, h)
    ScrollableNode2.setSize(self,w,h);
    self.m_mainNode:setSize(ScrollView2.getSize(self));
end

ScrollView2.getChildByName = function(self, name)
    return self.m_mainNode:getChildByName(name);
end

ScrollView2.getChildren = function(self)
    return self.m_mainNode:getChildren();
end

ScrollView2.addChild = function(self, child)
    self.m_mainNode:addChild(child);

    local optimize
    optimize = function (obj)
        drawing_set_bounding_circle_visible_test( obj.m_drawingID, 1 );
        local children = DrawingBase.getChildren(obj);
        for k, v in pairs(children) do
            optimize(v);                                   
        end 
    end 
    optimize(child);

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
    
    ScrollView2.update(self);
end

ScrollView2.removeChild = function(self, child, doCleanup)
    return self.m_mainNode:removeChild(child,doCleanup);
end

ScrollView2.removeAllChildren = function(self, doCleanup)
    if self.m_autoPositionChildren then
        self.m_nodeW = 0;
        self.m_nodeH = 0;
    end
    self.m_mainNode:setPos(0,0);
    return self.m_mainNode:removeAllChildren(doCleanup);
end

ScrollView2.updateScrollView = function(self)
	self.m_nodeW = 0;
	self.m_nodeH = 0;
    local childrens = self.m_mainNode:getChildren();
    for _,child in pairs(childrens) do
        if child then
            ScrollView2.updateChildPos(self,child);
        end
    end
end
ScrollView2.updateChildPos = function(self,child)
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
	ScrollView2.update(self);
end

ScrollView2.dtor = function(self)
    
end

--移除部分孩子节点
ScrollView2.removeChildByPos = function(self,start_index,end_index,view_tab)
    local startIndex,endIndex;
    startIndex = (start_index < end_index) and start_index or end_index;
    endIndex = (start_index > end_index) and start_index or end_index;

    local child = self:getChildren();

    if #child == 0 then
        return;
    end
    local temp_tab = view_tab;
    if temp_tab and type(temp_tab) == "table" then
        for i = endIndex, startIndex, -1 do
            local view = table.remove(temp_tab,i);
            delete(view);
        end
    end;
    self:updateScrollView();
end
---------------------------------private functions-----------------------------------------
--virtual
ScrollView2.setParent = function(self, parent)
	ScrollableNode2.setParent(self,parent);
	local x,y = ScrollView2.getUnalignPos(self);
    local w,h = ScrollView2.getSize(self);
	ScrollView2.setClip(self,x,y,w,h);
end

ScrollView2.getFrameLength = function(self)
    local w,h = ScrollView2.getSize(self);
    if self.m_direction == kVertical then
        return h;
    else
        return w;
    end
end

ScrollView2.getViewLength = function(self)
    if self.m_direction == kVertical then
        return self.m_nodeH;
    else
        return self.m_nodeW;
    end
end

ScrollView2.needScroller = function(self)
    return true;
end

ScrollView2.getFrameOffset = function(self)
    return 0;
end

ScrollView2.onEventTouch =  function(self, finger_action, x, y, drawing_id_first, drawing_id_current, event_time)
    
end

ScrollView2.onEventDrag =  function(self, finger_action, x, y,drawing_id_first, drawing_id_current, event_time)
    if not ScrollView2.hasScroller(self) then return end

    self.m_scroller:onEventTouch(finger_action,x,y,drawing_id_first,drawing_id_current, event_time);
end

ScrollView2.setOnScroll = function (self, obj, fn)
    if fn == nil then 
        self.m_onScrollFn = nil 
    else 
        self.m_onScrollFn = function (totalOffset)
            fn(obj, totalOffset)
        end
    end 
end
-- @Override from ScrollableNode2
ScrollView2.onScroll = function(self, totalOffset)
    ScrollableNode2.onScroll(self,totalOffset);

    if self.m_direction == kVertical then
        self.m_mainNode:setPos(nil,totalOffset);
    else
        self.m_mainNode:setPos(totalOffset,nil);
    end
    if self.m_onScrollFn then 
        self.m_onScrollFn(totalOffset)        
    end 
end
