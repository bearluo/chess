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
-- 可以对任何table加上finalizer。仅适用于lua 5.1（引擎目前使用lua 5.1）。
--
-- finalizer是一个函数，table在GC前，会执行这个函数.
--
-- 例如：
--
--     -- test.lua
--
--     local GC = require 'libutils.gc'
--
--     local function collect(t)
--         print('collecting '..tostring(t)..'...')
--     end
--
--     (function ()
--         local t = {}
--         print(t)
--         GC.setFinalizer(t, collect)
--     end)();
--
--     -- 执行：
--     $ lua -e "dofile('test.lua')"
--     table: 0x600040b00
--     collecting table: 0x600041750...
--
--
-- 注：
--
-- * finalizer会在table（或者metatable）中增加一个字段，用于记录对应的信息。请保留此字段。
--
-- @module libutils.gc
--
-- @usage local GC = require 'libutils.gc'


local M = {}

local gcObjectField = function () end -- make it uniq and difficult to see by eye

local createProxy = function (finalizer)
    local proxy = newproxy(true)

    getmetatable(proxy).__gc = function ()
        finalizer()
    end

    return proxy
end


---
-- 若`t`已存在finalizer，则清除`t`的finalizer（包括metatable中的finalizer信息）。清除后，原有的finalizer不会因为GC而被执行。
-- @param #table t 一个table。
M.clearFinalizer = function (t)

    local clearT = function (aTable)
        local origProxy = rawget(aTable, gcObjectField)

        if origProxy then
            getmetatable(origProxy).__gc = function () end
        end

        rawset(aTable, gcObjectField, nil)
    end

    clearT(t)

    local mt = getmetatable(t)
    if mt then
        clearT(mt)
    end

end


---
-- 给`t`设置一个finalizer，信息记录在`t`的metatable中。若`t`的metatable不存在，则创建一个。若`t`或者`t`的metatable中已有finalizer，则先清除原有的finalizer。
-- @param #table t 一个`table`。
-- @param #function finalizer 一个函数，也就是“finalizer”。在GC前，`finalizer(t)`会被自动执行。
-- @return #table 参数`t`。
M.setFinalizerInMT = function (t, finalizer)

    M.clearFinalizer(t)

    local mt = getmetatable(t)

    if mt then
        M.setFinalizer(mt, function ()
            finalizer(t)
        end)

    else
        mt = {}

        M.setFinalizer(mt, function ()
            finalizer(t)
        end)

        setmetatable(t, mt)
    end

    return t
end


---
-- 给`t`设置一个finalizer，信息记录在`t`中。若`t`或者`t`的metatable中已有finalizer，则先清除原有的finalizer。
-- @param #table t 一个`table`。
-- @param #function finalizer 一个函数，也就是“finalizer”。在GC前，`finalizer(t)`会被自动执行。
-- @return #table 参数`t`。
M.setFinalizer = function (t, finalizer)

    M.clearFinalizer(t)

    local proxy = createProxy(function()
        finalizer(t)
    end)

    rawset(t, gcObjectField, proxy)

    return t
end


return M