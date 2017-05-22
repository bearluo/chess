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
-- @module libutils.math
--
-- @usage local Math = require 'libutils.math'
local M = {}

---
-- 其值是inf。
M.Infinity = 1/0

---
-- 其值是nan。
M.NaN = math.sqrt(-2)

---
-- 返回x是否是nan。
-- 
-- @param #number x 任意数值。
-- @return #boolean 若x是nan，则返回true。否则，返回false。
M.isNaN = function (x)
    return not rawequal(x,x)
end

---
-- 返回x是否是inf或-inf。
-- 
-- @param #number x 任意数值。
-- @return #boolean 若x是inf或-inf，则返回true。否则，返回false。
M.isInfinity = function (x)
    return rawequal(x + 1,x)
end

---
-- 把x限制在[r1,r2]或[r2,r1]中。
--
-- @param #number x 任意数值。
-- @param #number r1 任意数值。
-- @param #number r2 任意数值。
-- @return #number 返回最接近x的、范围在[r1,r2]或[r2,r1]中的数值。 
M.inRange = function (x, r1, r2)
    local bottom = math.min(r1, r2)
    local upper = math.max(r1, r2)
    
    if x < bottom then
        return bottom
    end
    
    if x > upper then
        return upper
    end
    
    return x    
end

return M