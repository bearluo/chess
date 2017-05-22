--
-- @@LIB_NAME@@, Version: @@Version@@
--
-- This file is a part of @@LIB_NAME@@.
--
-- Author:
-- Xiaofeng Yang     2015
--
-- Provide simple annotation support for Lua.


---
-- @module libutils.annotation
--
-- @usage local Annotation = require 'libutils.annotation'
local M = {}

-- annotationChain[generated function] == { ... }
local annotationChain = setmetatable({},{ __mode = 'k' })

local create = function (fn)
    local obj1 = newproxy()

    debug.setmetatable(obj1, {
        -- support for the quoted part: #"annot()" .. fn
        __call = function (_, ...)
            local arguments = arg
            local Narg = arg.n

            local obj2 = newproxy()
            debug.setmetatable(obj2, {
                __metatable = false,
                -- support for the quoted part: "#annot()" .. fn
                __len = function (op)
                    return setmetatable({}, {
                        -- support for the quoted part: "#annot() .. fn"
                        __concat = function (op1, op2)
                            local origFn = op2
                            local generatedFn = fn(op2, unpack(arguments, 1, Narg))

                            -- recording
                            annotationChain[generatedFn] = {
                              annot = obj1,
                              orig = origFn
                            }
                            return generatedFn
                        end
                    })
                end,
            })

            return obj2
        end,
        __metatable = false,

        -- support for the quoted part: "#annot" .. fn
        __len = function (op)
            return setmetatable({}, {
                __metatable = false,
                -- support for the quoted part: "#annot .. fn"
                __concat = function (op1, op2)
                    local origFn = op2
                    local generatedFn = fn(op2)

                    -- recording
                    annotationChain[generatedFn] = {
                      annot = obj1,
                      orig = origFn
                    }
                    return generatedFn
                end
            })
        end
    })

    return obj1
end

---
-- 返回一个annotation对象，该对象使用```fn```对输入的函数进行处理.
--
-- 使用时注意：
--
-- * fn(x)和x之间不要形成循环引用，否则都不会被gc。
-- * 一个fn(x)只能对应一个x。
-- * 除非所有的fn(x)都被gc，否则fn不会被gc。
--
-- @usage 
-- local Annotation = require 'libutils.annotation'
-- local annotatedObject = #Annotation.annotation .. fn
--
M.annotation = create(create)

---
--
-- 对已注解的对象，在注解过程中每次返回的对象，应用函数```fn```.
--
-- 具体如下。
--
-- 若已知
--
--     a1 == #Annotation.annot1 .. a2 -- 每个annot可能带参数也可能不带参数
--     a2 == #Annotation.annot2 .. a3
--     a3 == #Annotation.annot3 .. a4
--     ...
--     an == #Annotation.annotN .. orig
--
-- 则
--
--     applyOnAnnotated(a1, fn) ==
--     
--       fn(a2, annot1)  --以下函数会依次执行。
--       fn(a3, annot2)
--       fn(a4, annot3)
--       ...
--       fn(orig, annotN)
--
-- @param annotated 要处理的对象（通常是函数）。
-- @param #function fn 用于处理的函数。
--
-- @usage
--
--  -- 这个小例子展示了函数的用法。
--
--  local t = {}
--
--  local annot1 =
--    #Annotation.annotation ..
--    function (fn)
--      local result = function (...)
--        fn(...)
--      end
--      t[result] = '(by annot1)'
--      return result
--    end
--
--
--  local annot2 =
--    #Annotation.annotation ..
--    function (fn)
--      local result = function (...)
--        fn(...)
--      end
--      t[result] = '(by annot2)'
--      return result
--    end
--
--
--  local annot3 =
--    #Annotation.annotation ..
--    function (fn)
--      local result = function (...)
--        fn(...)
--      end
--      t[result] = '(by annot3)'
--      return result
--    end
--
--  local f = function () end
--  local anf =
--    #annot1 ..
--    #annot2 ..
--    #annot3 ..
--    f
--
--  local alist = { [ annot1 ] = 'annot1' , [annot2] = 'annot2', [annot3] = 'annot3' }
--
--  t[f] = 'orig'
--
--  Annotation.applyOnAnnotated(anf,function (fn, annotfn)
--    print(t[fn], alist[annotfn])
--  end)
--
--  --  Output:
--  --
--  --  (by annot2) annot1
--  --  (by annot3) annot2
--  --  orig  annot3
M.applyOnAnnotated = function (annotated, fn)
  -- TODO 也许需要更好的版本，提供annotation时的参数。
  local ax = annotationChain[annotated]
  if ax then
    fn(ax.orig, ax.annot)
    return M.applyOnAnnotated(ax.orig, fn)
  end
end

---
-- 对已注解的对象，在注解过程中第一个应用注解的对象（原始对象），应用函数fn.
--
-- 若已知
--
--     a1 == #annot1 .. a2 -- 每个annot可能带参数也可能不带参数
--     a2 == #annot2 .. a3
--     a3 == #annot3 .. a4
--     ...
--     an == #annotN .. orig
--
-- 则
--
--     applyOnAnnotated(a1, fn) ==
--       fn(orig)
--
-- @param annotated 要处理的对象（通常是函数）。
-- @param #function fn 用于处理的函数。
--
-- @usage
--
--  -- 这个小例子展示了函数的用法。
--
--  local t = {}
--
--  local annot1 =
--    #Annotation.annotation ..
--    function (fn)
--      local result = function (...)
--        fn(...)
--      end
--      t[result] = '(by annot2)'
--      return result
--    end
--
--
--  local annot2 =
--    #Annotation.annotation ..
--    function (fn)
--      local result = function (...)
--        fn(...)
--      end
--      t[result] = '(by annot2)'
--      return result
--    end
--
--
--  local annot3 =
--    #Annotation.annotation ..
--    function (fn)
--      local result = function (...)
--        fn(...)
--      end
--      t[result] = '(by annot3)'
--      return result
--    end
--
--  local f = function () end
--  local anf =
--    #annot1 ..
--    #annot2 ..
--    #annot3 ..
--    f
--
--  local alist = { [ annot1 ] = 'annot1' , [annot2] = 'annot2', [annot3] = 'annot3' }
--
--  t[f] = 'orig'
--
--  Annotation.applyOnUnAnnotated(anf,function (fn)
--    print(t[fn])
--  end)
--
--  --  Output:
--  --
--  --  orig
M.applyOnUnAnnotated = function (annotated, fn)
  local t = {}
  M.applyOnAnnotated(annotated,function (x)
    table.insert(t,x)
  end)

  if #t > 0 then
    local orig = t[#t]
    fn(orig)
  end
end

return M