-- scrollViewEx.lua
-- Author: Vicent.Gong
-- Date: 2013-02-22
-- Last modification : 2013-02-22
-- Description: Implemented ScrollViewEx 

require("ui/scrollBar")
require("ui/scroller");
require("core/eventDispatcher");
require("ui/scrollView")

ScrollViewEx = class(ScrollView,false);

ScrollViewEx.ctor = function(self,x,y,with,hight)
    super(self,x,y,with,hight);
end

ScrollViewEx.dtor = function(self)

end

ScrollViewEx.addChild = function(self,child)
	self.m_mainNode:addChild(child);

	local w,h = child:getSize();
	local x,y = child:getPos();
	self.m_nodeH = (self.m_nodeH > y + h) and self.m_nodeH or (y + h);
	self.m_nodeW = (self.m_nodeW > x + w) and self.m_nodeW or (x + w);
	
	if self.m_nodeW > self.m_width then
		self:setSize(nil,self.m_nodeW);
	end
	
	if self.m_nodeH > self.m_height then
		if not self.m_scrollBar then 
			self.m_scrollBar = new(ScrollBar,self.m_width-(ScrollView.s_scrollBarWidth or 8),0,(self.m_scrollBarWidth or 8),self.m_height,self.m_nodeH);
			DrawingBase.addChild(self,self.m_scrollBar);
			self.m_scrollBar:setLevel(1);
			self.m_scrollBar:setVisibleImmediately(false);
		end
		
		self.m_scrollBar:setScrollHeight(self.m_nodeH);
		self.m_scroller:setViewLength(self.m_nodeH);
	end
end

