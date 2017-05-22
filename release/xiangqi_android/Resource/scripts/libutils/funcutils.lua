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
-- @module  libutils.funcutils
--
-- @usage local Funcutils = require 'libutils.funcutils'
local M = {}

---
-- 返回一个新的函数，为原函数的拷贝.
-- 新的函数保持和原函数一致的upvalues，但是仅仅只是值保持一致，但并非是同一个。也就是说，若某个upvalue在本函数调用后被修改过，新的函数将无法获得新的值。
-- 新的函数保持和原函数相同的environment。
--
-- 无需担心跨级的upvalues，例如下面的代码：尽管，```function B```没有直接引用来自```function A```的```x```；然而，由于```function C```引用了```x```，于是```function B```也就有了upvalue ```x```，这个```x```
-- 指向```function A```的```x```，而```function C```的upvalue ```x```，实际上是引用的```function B```的upvalue ```x```，并且join到```function B```的upvalue ```x```，这个join的关系在复制的过程并不会被破坏，丢失的仅仅是```function B```的```x```到```function A```的```x```的join。
--
--      function () -- function A
--          local x
--          return function () -- function B
--              return function () -- function C
--                  return x
--              end
--          end
--      end
--
-- @param #function fn 原函数。
-- @return #function  原函数的拷贝。
M.copyFunction = function (fn)
    -- standard lua 5.1
    -- 调试信息会被复制。

    -- JNLua:
    -- 调试信息会被复制。
    -- upvalues的名称也被copied，然而所有值都是nil。

    local code = string.dump(fn)
    local newFn = loadstring(code)

    -- copy upvalues

    local index = 1
    while true do
        local name, value = debug.getupvalue(fn,index)

        if name == nil then
            break
        end

        debug.setupvalue(newFn,index,value)
        index = index + 1
    end

    -- copy environment
    local origEnv = getfenv(fn)
    setfenv(newFn,origEnv)

    -- registry和metatable是大家共享的，不用管。

    return newFn
end


return M