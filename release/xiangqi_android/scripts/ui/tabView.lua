-- tabView.lua
-- Author: Vicent.Gong
-- Date: 2013-08-01
-- Last modification : 2013-08-05
-- Description: Implemented tabView

require("core/constants");
require("core/object");
require("core/global");
require("ui/node");
require("ui/scrollableNode");

TabView = class(ScrollableNode);

TabView.ctor = function(self, x, y, w, h)
	super(self,kVertical,0);

	TabView.setPos(self,x,y);

	self.m_mainNode = new(Node);
	ScrollableNode.addChild(self,self.m_mainNode);
	
	TabView.setPos(self,x,y);
	TabView.setSize(self,w,h);

	TabView.setEventDrag(self,self,self.onEventDrag);
	TabView.setEventTouch(self,self,self.onEventTouch);

	self.m_tabs = {};
	self.m_curIndex = 1;
	self.m_tabChangedCallback = {};
end

TabView.dtor = function(self)
	self.m_tabs = nil;
	self.m_mainNode = nil;
	self.m_tabChangedCallback = nil;
end

TabView.addTab = function(self, node)
	TabView.addChild(self,node);
end

TabView.removeTab = function(self, node)
	TabView.removeChild(self,node);
end

TabView.removeTabByName = function(self, name)
	local node = TabView.getTabByName(self,name);
	if not node then
		return;
	end
	TabView.removeTab(node);
end

TabView.getTabByName = function(self, name)
	return TabView.getChildByName(self,name);
end

TabView.getTab = function(self, index)
	return self.m_tabs[index];
end

TabView.setTabChangedCallback = function(self, obj, func)
	self.m_tabChangedCallback.func = func;
	self.m_tabChangedCallback.obj = obj;
end

TabView.getCurIndex = function(self)
	return self.m_curIndex;
end

--overwrite functions  
TabView.setDirection = function(self, direction)
	if self.m_direction == direction then
		return;
	end

	local frameLength = self:getFrameLength();
	if direction == kVertical then
		for i,v in ipairs(self.m_tabs) do
			v:setPos(0,(i-1)*frameLength);
		end
	else
		for i,v in ipairs(self.m_tabs) do
			v:setPos((i-1)*frameLength,0);
		end
	end

	ScrollableNode.setDirection(self,direction);
end

TabView.addChild = function(self, child)
	if not child then
		return;
	end

	if self.m_direction == kVertical then
		child:setPos(0,self:getViewLength());
	else
		child:setPos(self:getViewLength(),0);
	end

	self.m_mainNode:addChild(child);
	local nTabs = #self.m_tabs;
	self.m_tabs[nTabs+1] = child;
	
	ScrollableNode.update(self);
	return nTabs + 1;
end

TabView.removeChild = function(self, child)
	if not node then
		return;
	end

	local index = TabView.getTabIndex(self,node);

	if not index then
		return;
	end

	self.m_mainNode:removeChild(node);
	table.remove(self.m_tabs,index);

	if self.m_direction == kVertical then
		for i=index,#self.m_tabs do
			self.m_tabs[i]:setPos(0,(i-1)*self:getFrameLength());
		end
	else
		for i=index,#self.m_tabs do
			self.m_tabs[i]:setPos((i-1)*self:getFrameLength(),0);
		end
	end

	ScrollableNode.update(self);
end

TabView.getChildByName = function(self, child)
	return self.m_mainNode:getChildByName(child);
end

TabView.removeAllChildren = function(self, doCleanup)
	self.m_tabs = {};
	return self.m_mainNode:removeAllChildren(doCleanup);
end

TabView.getChildren = function(self)
	return self.m_mainNode:getChildren();
end

--override functions
TabView.getFrameLength = function(self)
	if self.m_direction == kVertical then
		return self.m_height;
	else
		return self.m_width;
	end
end

TabView.getViewLength = function(self)
    if self.m_tabs then
	    return #self.m_tabs * self:getFrameLength();
	else
	    return 0;
	end
end

TabView.getUnitLength = function(self)
	return self:getFrameLength();
end

TabView.getFrameOffset = function(self)
	return 0;
end

TabView.needScroller = function(self)
	return true;
end

TabView.needScrollBar = function(self)
	return false;
end

---------------------------------private functions-----------------------------------------

TabView.getTabIndex = function(self, node)
	local index;
	for k,v in pairs(self.m_tabs) do
		if v == node then
			index = k;
			break;
		end
	end

	return index;
end

TabView.getTabIndexByName = function(self, name)
	local node = TabView.getChildByName(name);
	if not node then
		return nil;
	end

	return TabView.getTabIndex(self,node);
end

TabView.onEventTouch = function()

end

TabView.onEventDrag =  function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
	if TableView.hasScroller(self) then 
		self.m_scroller:onEventTouch(finger_action,x,y,drawing_id_first,drawing_id_current);
	end
end

TabView.onScroll = function(self, scroll_status, diff, totalOffset)
	ScrollableNode.onScroll(self, scroll_status, diff, totalOffset);

	if self.m_direction == kVertical then
		self.m_mainNode:setPos(0,totalOffset);
	else
		self.m_mainNode:setPos(totalOffset,0);
	end

	if scroll_status == kScrollerStatusStop then
		local lastIndex = self.m_curIndex;
		self.m_curIndex = math.floor(totalOffset/self:getFrameLength()) + 1;
		if self.m_tabChangedCallback.func then
			self.m_tabChangedCallback.func(self.m_tabChangedCallback.obj,
										self.m_curIndex,lastIndex);
		end
	end
end
