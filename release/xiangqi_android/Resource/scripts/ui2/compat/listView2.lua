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
-- @module listView2

require("core/object");
require("ui2/compat/tableView2");

ListView2 = class(TableView2);

ListView2.setDefaultScrollBarWidth = function(width)
	ListView2.s_scrollBarWidth = width or TableView2.s_defaultScrollBarWidth;
end

ListView2.setDefaultMaxClickOffset = function(maxClickOffset)
	ListView2.s_maxClickOffset = maxClickOffset or TableView2.s_defaultMaxClickOffset;
end

ListView2.ctor = function(self, x, y, w, h)

end
