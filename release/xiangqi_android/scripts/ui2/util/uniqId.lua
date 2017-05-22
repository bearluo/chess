--
-- UI2 Library, Version: 1.0 Alpha (0.99.2.2058-SNAPSHOT)
-- 
-- This file is a part of UI2 Library.
--
-- Author:
-- Xiaofeng Yang     2015
--
--

local M = {}

M.get = (function ()
    local id = 0
    return function ()
        id = id + 1
        return id 
    end
end)()

return M