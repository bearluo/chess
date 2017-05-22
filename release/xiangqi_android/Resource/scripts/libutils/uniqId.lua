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
-- @module libutils.uniqId
--
-- @usage local UniqId = require 'libutils.uniqId'

local M = {}

---
-- 获取一个惟一的id.
-- id的生成规则，每次自加1。
--
-- @return #number 惟一的id。
M.get = (function ()
    local id = 0
    return function ()
        id = id + 1
        return id
    end
end)()

return M