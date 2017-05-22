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
-- @module libutils.misc
--
-- @usage local Misc = require 'libutils.misc'
local M = {}


-- run `fn(...)' once, do nothing if it is called the second time

---
-- 只执行```fn(...)```一次，第二次以及之后调用什么都不做.
-- 
-- @param #function fn 只需要执行一次的函数。
-- @return #function  返回新的函数，此函数只能被执行一次。
M.makeOnce = function (fn)
    local did = false
    return function (...)
        if did then
            return
        end

        fn(...)

        did = true
    end
end


-- returns a new table, which cannot be modified but all table[key] can be access.

---
-- 使table只读，即它的值不允许修改，但是可以访问。
-- 
-- @param #table table 需要只读的lua表。
-- @return #table 返回新的lua表，这个lua表中的值不可以被修改，但是可以被访问。
M.makeTableReadOnly = function(table)
    return setmetatable( {}, {
        __index = table,
        __newindex = function(t, key, value)
            error("Attempt to modify read-only table.")
        end,
        __metatable = false
    } )
end


do
    local ref = {}
    
    ---
    -- 增加对```obj```的一次引用.
    -- 
    -- @param obj 任意类型。
    -- @return obj 返回obj对象。
    M.addGlobalReference = function (obj)
        ref[obj] = true
        return obj
    end
    
    ---
    -- 减少对```obj```的一次引用。
    -- 
    -- @param obj 任意类型。
    -- @return obj 返回obj对象。
    M.removeGlobalReference = function (obj)
        ref[obj] = nil
        return obj
    end
end




---
-- 返回一个新的userdata对象v，tostring(v) == s。作为一个标识，方便调试。
-- 
-- @param #string s 字符串标识。
-- @return #userdata 新的userdata对象。
M.labeledUserdata = function (s)
    local value = newproxy()
    debug.setmetatable(value, {
        __tostring = function ()
            return s
        end
    })
    return value
end


---
-- 返回可以表示x地址的一个字符串（应该是这样子吧）.
-- 
-- x必须是引用类型。
-- 
-- 在lua 5.1/jnlua 5.1上实测OK。
-- 
-- @param x 一个lua object。类型只能是```table, userdata, thread, function```。且从未设置过```__tostring```。
-- @return #string x的地址。
M.addressOf = function (x)
    local s = tostring(x)
    local startIndex = string.match(s,': ()')
    local address = string.sub(s,startIndex)
    return address
end 

return M