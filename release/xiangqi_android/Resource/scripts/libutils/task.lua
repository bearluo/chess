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
-- @module libutils.task
--
-- @usage local Task = require 'libutils.task'

local UniqId = require 'libutils.uniqId' 
local Misc = require 'libutils.misc'

local M = {}

local createAnimDouble = function (animType, duration)
    local animId = anim_alloc_id()
    anim_create_double(0, animId, animType, 0, 0, duration, 0)
    return animId
end

local deleteAnim = function (animId)
    anim_delete(animId)
    anim_free_id(animId)
end

--- 
-- execute ```fn()``` after ```delay``` ms.
-- @function 
-- @param #number delay 延迟时间。
-- @param #function fn 要被调用的函数。
-- @return #function 返回一个函数。如果在 ```fn``` 被调用之前，就调用返回的这个函数（此函数无参数），则```fn```不会被执行。
M.runAfter = (function ()
    local allAnims = {}
    return function (delay, fn)
        local animId = createAnimDouble(0,delay)

        local stop = function ()
            if allAnims[animId] then
                allAnims[animId] = nil
                deleteAnim(animId)
            end
        end

        allAnims[animId] = function ()
            stop()

            if fn then
                fn()
            end
        end;   -- keep reference
        
        anim_set_event(animId,1,M,allAnims[animId])

        return stop
    end
end)()

--- 
-- execute ```fn(stop)``` in every frames (except current frame)
-- it starts immediately on the next frame (maybe).
-- if stop() is called, then the animation will be stopped
-- and the associated resource will be released.
-- @param #function fn 要每帧执行的函数。
-- @return #function 返回一个函数。调用该函数，则不会再执行```fn```。  
M.runEveryFrames = function (fn)
    local ev
    local stop = function ()
        ev:cancel()
    end
    
    ev = Clock.instance():schedule(function()
        fn(stop)         
    end)
    
    return stop
end


return M