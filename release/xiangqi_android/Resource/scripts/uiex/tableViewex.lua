require("ui/tableView")



TableView.setOnItemFingerAction = function(self ,obj, func)
	if not self.m_itemFingerActionEventCallback then
		self.m_itemFingerActionEventCallback = {};
	end
	self.m_itemFingerActionEventCallback.obj = obj;
	self.m_itemFingerActionEventCallback.func = func;
end

local tableViewDrag = TableView.onEventDrag;

TableView.onEventDrag =  function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
	tableViewDrag(self, finger_action, x, y, drawing_id_first, drawing_id_current);

		--添加down回调接口
       --- 记录当前纵向位置 kellyLiu
     self.m_currentY = y;
     self.m_currentX = x;
     --Log.d("TableView.diff",self:getCurrentIndex());
     if self:getCurrentIndex() < 0 then 
       self:onDownDragEvent();    
     end  
	if self.m_itemFingerActionEventCallback and self.m_itemFingerActionEventCallback.func and TableView.hasAdapter(self) then
		local localX,localY = TableView.convertSurfacePointToView(self,x,y);
		local view,index = TableView.getCurTouchViewAndIndex(self,localX,localY);

		self.m_itemFingerActionEventCallback.func(self.m_itemFingerActionEventCallback.obj,finger_action , self.m_adapter,view,index);
	end
end


TableView.setOnDownDragEvent = function(self,obj,fun)
	-- body
	self.downDragEventObj = obj;
	self.downDragEventFun = fun;
end
TableView.onDownDragEvent = function(self )
	-- body
   --Log.d("onDownDragLimit FriendsScene.onDownDragLimit");
	if self.downDragEventObj then 
		if self.downDragEventFun then 
			self.downDragEventFun(self.downDragEventObj);
			--Log.d("onDownDragLimit onDownDragEvent");
		end 
	end 
end
TableView.setShowingIndex = function(self, index)
	local frameOffsetX,frameOffsetY = self:getFrameOffset();
	local lineIndex = math.ceil(index/self.m_nItemsPerLine) - 1;

	--self:getScroller():setReboundFrames(0);
	self.m_scroller:setReboundFrames(0)
	if self.m_direction == kVertical then
		local destDiff = lineIndex * self.m_itemLength + frameOffsetY;
		self:onEventDrag(kFingerDown, 0, self.m_diff, 0, 0);
		self:onEventDrag(KfingerUp, 0, -destDiff, 0, 0);
	else
		local destDiff = lineIndex * self.m_itemLength + frameOffsetX;
		self:onEventDrag(kFingerDown,self.m_diff, 0, 0, 0);
		self:onEventDrag(KfingerUp,-destDiff, 0, 0, 0);
	end
	self.m_scroller:setReboundFrames()
	--self:getScroller():setReboundFrames();
end

TableView.getCurrentIndex = function(self)
	-- body
	if not  self.m_currentY then 
	  self.m_currentY = 0; 
	end 
	if not self.m_currentX then 
		self.m_currentX = 0;
	end 
    local frameOffsetX,frameOffsetY = self:getFrameOffset();
	local localX,localY = TableView.convertSurfacePointToView(self,self.m_currentX,self.m_currentY);
	local view,touchIndex = TableView.getCurTouchViewAndIndex(self,localX,localY);
	if not view then 
		return 1;
	end 
	local mw,wh = view:getSize();
	local diffY = self.m_currentY - frameOffsetY ;
	if diffY < 0 then
		diffY = 0 
	end 
	return touchIndex - math.floor(diffY/wh) + 1;
end 

TableView.getCurTouchViewAndIndex = function(self, x, y)
    if not self.m_beginIndex then 
    	return ;
    end 
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