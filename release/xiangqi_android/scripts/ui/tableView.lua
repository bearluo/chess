-- listView.lua
-- Author: Vicent.Gong
-- Date: 2012-09-27
-- Last modification : 2013-08-01
-- Description: Implemented tableView 

require("core/constants");
require("core/object");
require("core/global");
require("ui/scrollableNode");

TableView = class(ScrollableNode,false);

TableView.s_defaultScrollBarWidth = 8;
TableView.s_defaultMaxClickOffset = 5;

TableView.setDefaultScrollBarWidth = function(width)
	TableView.s_scrollBarWidth = width or TableView.s_defaultScrollBarWidth;
end

TableView.setDefaultMaxClickOffset = function(maxClickOffset)
	TableView.s_maxClickOffset = maxClickOffset or TableView.s_defaultMaxClickOffset;
end

TableView.ctor = function(self, x, y, w, h, autoAlignToItemEdge, isMultiItems)
	super(self,kVertical,self.s_scrollBarWidth or self.s_defaultScrollBarWidth);
	self.m_autoAlignToItemEdge = autoAlignToItemEdge;
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

	ScrollableNode.setPos(self,x,y);
	ScrollableNode.setSize(self,w or 1,h or 1);
	TableView.setClip(self);

	TableView.setEventDrag(self,self,self.onEventDrag);
	TableView.setEventTouch(self,self,self.onEventTouch);

	self.m_itemEventCallback = {};
	self.m_scrollCallback = {};
end

TableView.setMaxClickOffset = function(self, offset)
	self.m_maxClickOffset = offset 
						or self.s_maxClickOffset 
						or self.s_defaultMaxClickOffset;
end

TableView.setScrollBarWidth = function(self, width)
	width = width 
			or self.s_scrollBarWidth 
			or self.s_defaultScrollBarWidth;

	ScrollableNode.setScrollBarWidth(self,width);
end

TableView.setDirection = function(self, direction)
	if (not direction) or self.m_direction == direction then
		return;
	end

	self.m_direction = direction;

    TableView.updateItemLength(self);
    TableView.updateLineInfo(self);
	TableView.setClip(self);
	ScrollableNode.setDirection(self,self.m_direction);
	TableView.releaseAllViews(self);
	TableView.initViews(self);
end

TableView.setPos = function(self, x, y)
	ScrollableNode.setPos(self,x,y);
	TableView.setClip(self);
end

TableView.setSize = function(self, w, h)
	ScrollableNode.setSize(self,w,h);
	TableView.setClip(self);
	TableView.updateLineInfo(self);
	TableView.requireAndShowViews(self,self.m_diff);
end

TableView.setAlign = function(self, align)
	ScrollableNode.setAlign(self,align);
	TableView.setClip(self);
end

TableView.setFillRegion = function(self, doFill, topLeftX, topLeftY, bottomRightX, bottomRightY)
	ScrollableNode.setFillRegion(self, doFill, topLeftX, topLeftY, bottomRightX, bottomRightY);
	TableView.setClip(self);
end

TableView.setFillParent = function(self, doFillParentWidth, doFillParentHeight)
	ScrollableNode.setFillParent(self,doFillParentWidth,doFillParentHeight);
	TableView.setClip(self);
end

TableView.setClip = function(self)
	local clipX,clipY,clipW,clipH;
	local x,y = TableView.getUnalignPos(self);
	local width,height = TableView.getSize(self);
	if TableView.hasAdapter(self) then 
		if self.m_direction == kVertical then	
			if self.m_autoAlignToItemEdge then
				clipH = TableView.getFrameLength(self);
				clipY = y + (height - clipH)/2;
			else
				clipH = height;
				clipY = y;
			end

			if self.m_isMultiItem then 
				clipW = width - width % self.m_itemEdgeLength;
				clipX = x + (width - clipW)/2;
			else
				clipW = width;
				clipX = x;
			end
		else
			if self.m_autoAlignToItemEdge then
				clipW = TableView.getFrameLength(self);
				clipX = x + (width - clipW)/2;
			else
				clipW = width;
				clipX = x;
			end

			if self.m_isMultiItem then 
				clipH = height - height % self.m_itemEdgeLength;
				clipY = y + (height - clipH)/2;
			else
				clipH = height;
				clipY = y;
			end
		end
	else
		clipX = x;
		clipY = y;
		clipW = width;
		clipH = height;
	end

	ScrollableNode.setClip(self,clipX,clipY,clipW,clipH);
end

TableView.setAdapter = function(self, adapter)
    TableView.releaseAllViews(self);

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
    TableView.updateItemLength(self);
    TableView.updateLineInfo(self);
    TableView.setClip(self);
   	ScrollableNode.recreate(self);
    TableView.initViews(self);
end

TableView.onAppendData = function(self)
	TableView.updateLineInfo(self);
	TableView.update(self);
	TableView.requireAndShowViews(self,self.m_diff);
end

TableView.onChangeData = function(self)
	TableView.releaseAllViews(self);
	TableView.updateItemLength(self);
	TableView.updateLineInfo(self);
    TableView.setClip(self);
   	ScrollableNode.recreate(self);
    TableView.initViews(self);
end

TableView.onUpdateData = function(self, index)
	local i = index - self.m_beginIndex;
	if not self.m_views[i] then
		return;
	end
	
	local x,y = self.m_views[i]:getPos();
	TableView.removeChild(self,self.m_views[i]);
    self.m_adapter:releaseView(self.m_views[i]);
	
	self.m_views[i] = self.m_adapter:getView(index);
	self.m_views[i]:setPos(x,y);
	TableView.addChild(self,self.m_views[i]);
end

TableView.setOnItemClick = function(self, obj, func)
	self.m_itemEventCallback.obj = obj;
	self.m_itemEventCallback.func = func;
end

TableView.setOnScroll = function(self, obj, func)
	self.m_scrollCallback.obj = obj;
	self.m_scrollCallback.func = func;
end

TableView.setShowingIndex = function(self, index)
	local frameOffsetX,frameOffsetY = self:getFrameOffset();
	local lineIndex = math.ceil(index/self.m_nItemsPerLine) - 1;

	self:getScroller():setReboundFrames(0);
	if self.m_direction == kVertical then
		local destDiff = lineIndex * self.m_itemLength + frameOffsetY;
		self:onEventDrag(kFingerDown, 0, self.m_diff, 0, 0);
		self:onEventDrag(KfingerUp, 0, -destDiff, 0, 0);
	else
		local destDiff = lineIndex * self.m_itemLength + frameOffsetX;
		self:onEventDrag(kFingerDown,self.m_diff, 0, 0, 0);
		self:onEventDrag(KfingerUp,-destDiff, 0, 0, 0);
	end
	self:getScroller():setReboundFrames();
end

TableView.dtor = function(self)
	TableView.releaseAllViews(self);
	
    delete(self.m_adapter);
    self.m_adapter = nil;
end

---------------------------------private functions-----------------------------------------

--virtual

TableView.reviseSize = function(self)
	ScrollableNode.reviseSize(self);
	TableView.setClip(self);
end

TableView.revisePos = function(self)
	ScrollableNode.revisePos(self);
	TableView.setClip(self);
end

TableView.getFrameLength = function(self)
	local unitLength = TableView.getUnitLength(self);
	local width,height = TableView.getSize(self);

	if self.m_direction == kVertical then
		return height - height % unitLength;
	else
		return width - width % unitLength;
	end
end

TableView.getViewLength = function(self)
	return self.m_nTotalLines * self.m_itemLength;
end

TableView.getUnitLength = function(self)
	return self.m_autoAlignToItemEdge and self.m_itemLength or 1;
end

TableView.getFrameOffset = function(self)
	local width,height = TableView.getSize(self);
	if self.m_direction == kVertical then
		return (width - self.m_nItemsPerLine*self.m_itemEdgeLength)/2,
			(height - TableView.getFrameLength(self))/2;
	else
		return (width - TableView.getFrameLength(self))/2,
			(height - self.m_nItemsPerLine*self.m_itemEdgeLength)/2;
	end
end

TableView.needScroller = function(self)
	return TableView.hasAdapter(self);
end

TableView.updateItemLength = function(self)
	if not TableView.hasAdapter(self) then
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

TableView.hasAdapter = function(self)
	return self.m_adapter ~= nil;
end

TableView.initViews = function(self)
	self.m_views = {};
	self.m_beginIndex = 0;
	self.m_offset = 0;
	
	TableView.requireAndShowViews(self,0);
end

TableView.releaseAllViews = function(self)
	for _,v in ipairs(self.m_views) do 
		TableView.removeChild(self,v);
		self.m_adapter:releaseView(v);
	end

	self.m_views = {};
end

TableView.updateLineInfo = function(self)
	if not TableView.hasAdapter(self) then
		self.m_nShowLines = 0;
		self.m_nItemsPerLine = 1;
		return;
	end

	local width,height = TableView.getSize(self);
	self.m_nShowLines = math.ceil(TableView.getFrameLength(self) / self.m_itemLength);

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

TableView.requireAndShowViews = function(self, diff)
    if not TableView.hasAdapter(self) then 
        return;
    end
    
	TableView.requestViews(self,diff);
	TableView.show(self);
end

TableView.getCurTouchViewAndIndex = function(self, x, y)
	local frameLength = self:getFrameLength();
	local frameOffsetX,frameOffsetY = self:getFrameOffset();
	local width,height = TableView.getSize(self);

	if x < frameOffsetX or y < frameOffsetY or x > width or y > height then
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

TableView.requestViews = function(self, diff)
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
			TableView.addChild(self,self.m_views[i]);
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
			TableView.addChild(self,self.m_views[i]);
        end
        for i=#self.m_views+1,nShowItems do
            self.m_views[i] = self.m_adapter:getView(i+beginItemIndex);
            if not self.m_views[i] then
                break;
            end
			TableView.addChild(self,self.m_views[i]);
        end
    end
    for _,v in pairs(temp) do  
		TableView.removeChild(self,v);
        self.m_adapter:releaseView(v);
    end
end

TableView.show = function(self)	
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

TableView.onEventTouch = function()

end

TableView.onEventDrag =  function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
	if TableView.hasScroller(self) then 
		self.m_scroller:onEventTouch(finger_action,x,y,drawing_id_first,drawing_id_current);
	end

	if finger_action == kFingerDown then
		self.m_startX = x;
		self.m_startY = y;
	elseif finger_action ~= kFingerMove then
		if 	math.abs(y-self.m_startY) < self.m_maxClickOffset 
			and math.abs(x-self.m_startX) < self.m_maxClickOffset then

			if self.m_itemEventCallback.func and TableView.hasAdapter(self) then
			    local localX,localY = TableView.convertSurfacePointToView(self,x,y);
				local view,index = TableView.getCurTouchViewAndIndex(self,localX,localY);

				if view then 
					local viewX,viewY = view:convertSurfacePointToView(x,y);
					self.m_itemEventCallback.func(self.m_itemEventCallback.obj,self.m_adapter,view,index,viewX,viewY);
				end
			end
		end
	end
end

TableView.onScroll = function(self, scroll_status, diff, totalOffset)
	ScrollableNode.onScroll(self, scroll_status, diff, totalOffset);

	TableView.requireAndShowViews(self,totalOffset);

	if self.m_scrollCallback.func then
	    local itemIndex = self.m_beginIndex*self.m_nItemsPerLine + 1;
		self.m_scrollCallback.func(self.m_scrollCallback.obj,scroll_status,itemIndex,#self.m_views);
	end
end
