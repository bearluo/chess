--
-- @@LIB_NAME@@, Version: @@Version@@
--
-- This file is a part of @@LIB_NAME@@.
--
-- Author:
-- Xiaofeng Yang     2015
--
--

---
--
-- 模拟枚举类型.
-- 
-- 构建一个枚举，不能对其中的值进行修改，修改时会报错。如果访问其没有的枚举值，也会报错。
--
-- @module libutils.enum
--
--
--
-- @usage local Enum = require 'libutils.enum'
-- 
-- local WeekEnum = Enum {
--     Monday    = 1,
--     Tuesday   = 2,
--     Wednesday = 3,
--     Thursday  = 4,
--     Friday    = 5,
--     Saturday  = 6,
--     Sunday    = 7
-- }
-- 
-- print(WeekEnum.Monday)
-- 
-- output：1

return function(table)
    if type(table) ~= "table" then
       return nil
    end
   
    return setmetatable( {}, {
        __index = function (t, k)
            local value = table[k]
            if value == nil then
                error("Unknown enum value: " .. tostring(k))
            end
            return value
        end,
        __newindex = function(t, key, value)
            error("Attempt to change a enumeration.")
        end,
        __metatable = false
    } )
end

