-- listView.lua
-- Author: Vicent.Gong
-- Date: 2012-09-27
-- Last modification : 2013-06-25
-- Description: Implemented listview 

require("core/object");
require("ui/tableView");

ListView = class(TableView);

ListView.setDefaultScrollBarWidth = function(width)
	ListView.s_scrollBarWidth = width or TableView.s_defaultScrollBarWidth;
end

ListView.setDefaultMaxClickOffset = function(maxClickOffset)
	ListView.s_maxClickOffset = maxClickOffset or TableView.s_defaultMaxClickOffset;
end

ListView.ctor = function(self, x, y, w, h)
    self.m_scrollCallback = {};
end

ListView.setOnScroll = function(self, obj, func)
	self.m_scrollCallback.obj = obj;
	self.m_scrollCallback.func = func;
end

ListView.onScroll = function(self, scroll_status, diff, totalOffset)
	TableView.onScroll(self, scroll_status, diff, totalOffset);

	TableView.requireAndShowViews(self,totalOffset);

	if self.m_scrollCallback.func then
		self.m_scrollCallback.func(self.m_scrollCallback.obj,scroll_status,diff, totalOffset);
	end
end
