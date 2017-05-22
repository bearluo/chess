-- gridView.lua
-- Author: Vicent.Gong
-- Date: 2013-08-01
-- Last modification : 2013-08-01
-- Description: Implemented gridView

require("core/object");
require("ui/tableView");

GridView = class(TableView,false);

GridView.setDefaultScrollBarWidth = function(width)
	GridView.s_scrollBarWidth = width or TableView.s_defaultScrollBarWidth;
end

GridView.setDefaultMaxClickOffset = function(maxClickOffset)
	GridView.s_maxClickOffset = maxClickOffset or TableView.s_defaultMaxClickOffset;
end

GridView.ctor = function(self, x, y, w, h)
	super(self,x,y,w,h,false,true);
end 
