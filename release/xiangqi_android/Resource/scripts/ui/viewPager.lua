-- ViewPager.lua
-- Author: Vicent.Gong
-- Date: 2012-09-27
-- Last modification : 2013-07-01
-- Description: Implemented ViewPager

require("core/constants");
require("core/object");
require("ui/tableView");

ViewPager = class(TableView,false);

ViewPager.setDefaultScrollBarWidth = function(width)
	ViewPager.s_scrollBarWidth = width or TableView.s_defaultScrollBarWidth;
end

ViewPager.setDefaultMaxClickOffset = function(maxClickOffset)
	ViewPager.s_maxClickOffset = maxClickOffset or TableView.s_defaultMaxClickOffset;
end

ViewPager.ctor = function(self, x, y, w, h)
	ViewPager.setDefaultScrollBarWidth(0);
	super(self,x,y,w,h,true);
	ViewPager.setDirection(self,kHorizontal);

    self.m_curPage = 0;
    TableView.setOnScroll(self,self,self.onViewScroll);

    self.m_pageChangedCallback = {};
end

ViewPager.setPage = function(self, pageIndex)
    if not pageIndex or pageIndex < 0 or self.m_curPage == pageIndex then
        return;
    end
    local pageLength = self:getUnitLength(self);
    local scroller = ViewPager.getScroller(self);
    if not scroller then
        return;
    end
    scroller:setOffset(-pageLength * (pageIndex-1));
end

ViewPager.getCurPage = function(self)
    return self.m_curPage;
end

ViewPager.setOnPageChanged = function(self,obj,func)
    self.m_pageChangedCallback.obj = obj;
    self.m_pageChangedCallback.func = func;
end

ViewPager.setOnScroll = function(self)
    
end

---------------------------------private functions-----------------------------------------

ViewPager.onViewScroll = function(self, scroll_status, beginIndex, nViews, nFrameViews)
    if scroll_status ~= kScrollerStatusStop then
        return;
    end

    if beginIndex == self.m_curPage then
        return;
    end
    
    local lastPage = self.m_curPage;
    self.m_curPage = beginIndex;
    
    if self.m_pageChangedCallback.func then
        self.m_pageChangedCallback.func(self.m_pageChangedCallback.obj,self.m_curPage,lastPage);
    end
end
