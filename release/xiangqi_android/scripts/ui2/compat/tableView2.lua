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
-- @module tableView2

require("core/constants");
require("core/object");
require("core/global");
require("ui2/compat/scrollableNode2");

TableView2 = class(ScrollableNode2,false);

TableView2.s_defaultScrollBarWidth = 8;
TableView2.s_defaultMaxClickOffset = 5;

TableView2.setDefaultScrollBarWidth = function(width)
	TableView2.s_scrollBarWidth = width or TableView2.s_defaultScrollBarWidth;
end

TableView2.setDefaultMaxClickOffset = function(maxClickOffset)
	TableView2.s_maxClickOffset = maxClickOffset or TableView2.s_defaultMaxClickOffset;
end

TableView2.ctor = function(self, x, y, w, h, isMultiItems)
	super(self,kVertical,self.s_scrollBarWidth or self.s_defaultScrollBarWidth);	
	self.m_isMultiItem = isMultiItems;

	self.m_diff = 0;
	self.m_views = {};
	self.m_adapter = nil;
	self.m_itemLength = 0;
	self.m_itemEdgeLength = 0;
	self.m_nShowLines = 0;
	self.m_nTotalLines = 0;
	self.m_nItemsPerLine = 1;

	self.m_maxClickOffset = self.s_maxClickOffset or self.s_defaultMaxClickOffset;

	ScrollableNode2.setPos(self,x,y);
	ScrollableNode2.setSize(self,w or 1,h or 1);
	TableView2.setClip(self);

	TableView2.setEventDrag(self,self,self.onEventDrag);
	TableView2.setEventTouch(self,self,self.onEventTouch);

	self.m_itemEventCallback = {};
	self.m_scrollCallback = {};
end

TableView2.setMaxClickOffset = function(self, offset)
	self.m_maxClickOffset = offset 
						or self.s_maxClickOffset 
						or self.s_defaultMaxClickOffset;
end

TableView2.setScrollBarWidth = function(self, width)
	width = width 
			or self.s_scrollBarWidth 
			or self.s_defaultScrollBarWidth;

	ScrollableNode2.setScrollBarWidth(self,width);
end

TableView2.setDirection = function(self, direction)
	if (not direction) or self.m_direction == direction then
		return;
	end

	self.m_direction = direction;

    TableView2.updateItemLength(self);
    TableView2.updateLineInfo(self);
	TableView2.setClip(self);
	ScrollableNode2.setDirection(self,self.m_direction);
	TableView2.releaseAllViews(self);
	TableView2.initViews(self);
end

TableView2.setPos = function(self, x, y)
	ScrollableNode2.setPos(self,x,y);
	TableView2.setClip(self);
end

TableView2.setSize = function(self, w, h)
	ScrollableNode2.setSize(self,w,h);
	TableView2.setClip(self);
	TableView2.updateLineInfo(self);
	TableView2.requireAndShowViews(self,self.m_diff);
end

TableView2.setAlign = function(self, align)
	ScrollableNode2.setAlign(self,align);
	TableView2.setClip(self);
end

TableView2.setFillRegion = function(self, doFill, topLeftX, topLeftY, bottomRightX, bottomRightY)
	ScrollableNode2.setFillRegion(self, doFill, topLeftX, topLeftY, bottomRightX, bottomRightY);
	TableView2.setClip(self);
end

TableView2.setFillParent = function(self, doFillParentWidth, doFillParentHeight)
	ScrollableNode2.setFillParent(self,doFillParentWidth,doFillParentHeight);
	TableView2.setClip(self);
end

TableView2.setClip = function(self)
	local x,y = TableView2.getUnalignPos(self);
	local width,height = TableView2.getSize(self);

    ScrollableNode2.setClip(self,x,y,width,height);
end

TableView2.setAdapter = function(self, adapter)
    TableView2.releaseAllViews(self);

    if self.m_adapter ~= adapter then
		delete(self.m_adapter);
    	self.m_adapter = adapter;
    end

    if not adapter then 
    	return;
    end

    if not typeof(adapter,Adapter) then
    	FwLog("The param must be an Adapter in setAdapter");
    	return;
    end

    adapter:setEventListener(self);

    --The following calls must be in order 
    TableView2.updateItemLength(self);
    TableView2.updateLineInfo(self);
    TableView2.setClip(self);
   	ScrollableNode2.recreate(self);
    TableView2.initViews(self);
end

TableView2.getAdapter = function(self)
	return self.m_adapter;
end

TableView2.onAppendData = function(self)
	TableView2.updateLineInfo(self);
	TableView2.update(self);
	TableView2.requireAndShowViews(self,self.m_diff);
end

TableView2.onChangeData = function(self)
	TableView2.releaseAllViews(self);
	TableView2.updateItemLength(self);
	TableView2.updateLineInfo(self);
    TableView2.setClip(self);
   	ScrollableNode2.recreate(self);
    TableView2.initViews(self);
end

TableView2.onUpdateData = function(self, index)
	local i = index - self.m_beginIndex;
	if not self.m_views[i] then
		return;
	end
	
	local x,y = self.m_views[i]:getPos();
	TableView2.removeChild(self,self.m_views[i]);
    self.m_adapter:releaseView(self.m_views[i]);
	
	self.m_views[i] = self.m_adapter:getView(index);
	self.m_views[i]:setPos(x,y);
	TableView2.addChild(self,self.m_views[i]);
end

TableView2.setOnItemClick = function(self, obj, func)
	self.m_itemEventCallback.obj = obj;
	self.m_itemEventCallback.func = func;
end

TableView2.setOnScroll = function(self, obj, func)
	self.m_scrollCallback.obj = obj;
	self.m_scrollCallback.func = func;
end

TableView2.setShowingIndex = function(self, index)
	local frameOffsetX,frameOffsetY = self:getFrameOffset();
	local lineIndex = math.ceil(index/self.m_nItemsPerLine) - 1;

    if self:hasScroller() then
        local destDiff

	    if self.m_direction == kVertical then
		    destDiff = lineIndex * self.m_itemLength + frameOffsetY;
	    else
		    destDiff = lineIndex * self.m_itemLength + frameOffsetX;
	    end
        
        self:getScroller():setOffset(- destDiff);
    end 
end

TableView2.dtor = function(self)
	TableView2.releaseAllViews(self);
	
    delete(self.m_adapter);
    self.m_adapter = nil;
end

---------------------------------private functions-----------------------------------------

--virtual

TableView2.reviseSize = function(self)
	ScrollableNode2.reviseSize(self);
	TableView2.setClip(self);
	TableView2.requireAndShowViews(self,0);
end

TableView2.revisePos = function(self)
	ScrollableNode2.revisePos(self);
	TableView2.setClip(self);
end

TableView2.getFrameLength = function(self)
	local width,height = TableView2.getSize(self);

	if self.m_direction == kVertical then
		return height;
	else
		return width;
	end
end

TableView2.getViewLength = function(self)
	return self.m_nTotalLines * self.m_itemLength;
end

TableView2.getFrameOffset = function(self)
	local width,height = TableView2.getSize(self);
	if self.m_direction == kVertical then
		return (width - self.m_nItemsPerLine*self.m_itemEdgeLength)/2,
			(height - TableView2.getFrameLength(self))/2;
	else
		return (width - TableView2.getFrameLength(self))/2,
			(height - self.m_nItemsPerLine*self.m_itemEdgeLength)/2;
	end
end

TableView2.needScroller = function(self)
	return TableView2.hasAdapter(self);
end

TableView2.updateItemLength = function(self)
	if not TableView2.hasAdapter(self) then
		self.m_itemLength = 0;
		self.m_itemEdgeLength = 0;
		return;
	end

	local view = self.m_adapter:getView(1);
	local itemWidth ,itemHeight = view:getSize();
	self.m_adapter:releaseView(view);

	if self.m_direction == kVertical then
		self.m_itemLength = itemHeight;
		self.m_itemEdgeLength = itemWidth;
	else
		self.m_itemLength = itemWidth;
		self.m_itemEdgeLength = itemHeight;
	end
end

TableView2.hasAdapter = function(self)
	return self.m_adapter ~= nil;
end

TableView2.initViews = function(self)
	self.m_views = {};
	self.m_beginIndex = 0;
	self.m_offset = 0;
	
	TableView2.requireAndShowViews(self,0);
end

TableView2.releaseAllViews = function(self)
	for _,v in ipairs(self.m_views) do 
		TableView2.removeChild(self,v);
		self.m_adapter:releaseView(v);
	end

	self.m_views = {};
end

TableView2.updateLineInfo = function(self)
	if not TableView2.hasAdapter(self) then
		self.m_nShowLines = 0;
		self.m_nItemsPerLine = 1;
		return;
	end

	local width,height = TableView2.getSize(self);
	self.m_nShowLines = math.ceil(TableView2.getFrameLength(self) / self.m_itemLength);

	if self.m_isMultiItem then
		if self.m_direction == kVertical then
			self.m_nItemsPerLine = math.floor(width / self.m_itemEdgeLength);
		else
			self.m_nItemsPerLine = math.floor(height / self.m_itemEdgeLength);
		end
	else
		self.m_nItemsPerLine = 1;
	end

	local count = self.m_adapter:getCount();
	self.m_nTotalLines = math.ceil(count / self.m_nItemsPerLine);
	self.m_nShowLines = self.m_nTotalLines > self.m_nShowLines and self.m_nShowLines or self.m_nTotalLines;
end

TableView2.requireAndShowViews = function(self, diff)
    if not TableView2.hasAdapter(self) then 
        return;
    end
    
	TableView2.requestViews(self,diff);
	TableView2.show(self);
end

TableView2.getCurTouchViewAndIndex = function(self, x, y)
	local frameLength = self:getFrameLength();
	local frameOffsetX,frameOffsetY = self:getFrameOffset();
	local width,height = TableView2.getSize(self);

	if x < frameOffsetX or y < frameOffsetY or x > width - frameOffsetX or y > height - frameOffsetY then
		return;
	end

	local curPos = (self.m_direction == kVertical) and y or x;
	local frameOffset = (self.m_direction == kVertical) and frameOffsetY or frameOffsetX;
	local itemOffset = (self.m_direction == kVertical) and x or y;

	local diff = curPos - frameOffset - self.m_diff;
	if curPos < 0 or curPos > frameLength then
		return;
	end

	local lineIndex = math.ceil(diff / self.m_itemLength);
    local itemIndex = math.ceil( (itemOffset - (frameOffsetX + frameOffsetY - frameOffset)) / self.m_itemEdgeLength);
	local index = (lineIndex-1)*self.m_nItemsPerLine + itemIndex;
	local view = self.m_views[index-self.m_beginIndex*self.m_nItemsPerLine];
	return view,index;
end

TableView2.requestViews = function(self, diff)
	if self.m_nShowLines == 0 then
		return;
	end

	local frameLength = self:getFrameLength();
	local viewLength = self:getViewLength();
	local itemLength = self.m_itemLength;

    self.m_diff = diff;
    
    local nShowLines = self.m_nShowLines;
    
    local index;
    if diff >= 0 then
        index = 0;
        self.m_offset = diff;
    elseif diff < frameLength - viewLength then
        index = self.m_nTotalLines - nShowLines;
        self.m_offset = diff + (self.m_nTotalLines- nShowLines)*itemLength;
    else
        index = math.floor(-diff/itemLength);
        self.m_offset = diff + index * itemLength;
        if index + nShowLines < self.m_nTotalLines then 
            nShowLines = nShowLines +1;
        end
    end
   
    if index == self.m_beginIndex and math.ceil(#self.m_views/self.m_nItemsPerLine) == nShowLines then 
        return;
    end
    
    local itemDiff = (index - self.m_beginIndex) * self.m_nItemsPerLine;
    self.m_beginIndex = index;
    local beginItemIndex = index * self.m_nItemsPerLine;
    local nShowItems = nShowLines*self.m_nItemsPerLine;
    local temp = self.m_views;
    self.m_views = {};
    if itemDiff >= 0 then
        for i=itemDiff+1,#temp do
            self.m_views[i-itemDiff] = temp[i];
            temp[i] = nil;
        end
        for i=#self.m_views+1,nShowItems do
            self.m_views[i] = self.m_adapter:getView(i+beginItemIndex);
            if not self.m_views[i] then
                break;
            end
			TableView2.addChild(self,self.m_views[i]);
        end
    else
        for i=1,nShowItems+itemDiff >= #temp and #temp or nShowItems+itemDiff do 
            self.m_views[i-itemDiff] = temp[i];
            temp[i] = nil;
        end
        for i=1,-itemDiff do
            self.m_views[i] = self.m_adapter:getView(i+beginItemIndex);
            if not self.m_views[i] then
                break;
            end
			TableView2.addChild(self,self.m_views[i]);
        end
        for i=#self.m_views+1,nShowItems do
            self.m_views[i] = self.m_adapter:getView(i+beginItemIndex);
            if not self.m_views[i] then
                break;
            end
			TableView2.addChild(self,self.m_views[i]);
        end
    end
    for _,v in pairs(temp) do  
		TableView2.removeChild(self,v);
        self.m_adapter:releaseView(v);
    end
end

TableView2.show = function(self)	
	local frameOffsetX,frameOffsetY = self:getFrameOffset();

	local getScrollDirectionPos = function(i)
		return self.m_offset + self.m_itemLength*math.floor((i-1)/self.m_nItemsPerLine)
	end 

	local getFixDirectionPos = function(i)
		return (i-1)%self.m_nItemsPerLine*self.m_itemEdgeLength;
	end

	if self.m_direction == kVertical then
		for i,view in ipairs(self.m_views) do
			view:setPos(frameOffsetX + getFixDirectionPos(i),
				frameOffsetY + getScrollDirectionPos(i));
		end
	else
		for i,view in ipairs(self.m_views) do
			view:setPos(frameOffsetX + getScrollDirectionPos(i),
				frameOffsetY + getFixDirectionPos(i));
		end
	end
end

TableView2.onEventTouch = function()

end

TableView2.onEventDrag =  function(self, finger_action, x, y, drawing_id_first, drawing_id_current, event_time)
	if TableView2.hasScroller(self) then 
		self.m_scroller:onEventTouch(finger_action,x,y,drawing_id_first,drawing_id_current, event_time);
	end

	if finger_action == kFingerDown then
		self.m_startX = x;
		self.m_startY = y;
	elseif finger_action ~= kFingerMove then
		if 	math.abs(y-self.m_startY) < self.m_maxClickOffset 
			and math.abs(x-self.m_startX) < self.m_maxClickOffset then

			if self.m_itemEventCallback.func and TableView2.hasAdapter(self) then
			    local localX,localY = TableView2.convertSurfacePointToView(self,x,y);
				local view,index = TableView2.getCurTouchViewAndIndex(self,localX,localY);

				if view then 
					local viewX,viewY = view:convertSurfacePointToView(x,y);
					self.m_itemEventCallback.func(self.m_itemEventCallback.obj,self.m_adapter,view,index,viewX,viewY);
				end
			end
		end
	end
end

TableView2.onScroll = function(self, totalOffset)
	ScrollableNode2.onScroll(self,totalOffset);

	TableView2.requireAndShowViews(self,totalOffset);

	if self.m_scrollCallback.func then
	    local itemIndex = self.m_beginIndex*self.m_nItemsPerLine + 1;
		self.m_scrollCallback.func(self.m_scrollCallback.obj,itemIndex,#self.m_views,totalOffset);
	end
end
