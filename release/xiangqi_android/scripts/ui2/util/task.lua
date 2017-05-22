--
-- UI2 Library, Version: 1.0 Alpha (0.99.2.2058-SNAPSHOT)
-- 
-- This file is a part of UI2 Library.
--
-- Author:
-- Xiaofeng Yang     2015
--
--

require("core/constants")
require("core/object")
require("core/global")
require("core/anim")

local UniqId = require('ui2.util.uniqId')

local M = {}

--- execute fn() after `delay' ms
M.runAfter = (function ()
    local allAnims = {}
    return function (delay, fn)
        local anim = new(AnimDouble,kAnimNormal,0,0,delay,0);
        allAnims[anim:getID()] = anim;   -- keep reference
        
        local stop = function ()
            if allAnims[anim:getID()] then 
                allAnims[anim:getID()] = nil
                delete(anim)
            end
        end

        anim:setEvent(nil, function ()
            stop()

            if fn then 
                fn()
            end
        end)

        return stop
    end
end)()


local everyFramesWorkRunning = true

M.pauseEveryFramesWork = function ()
    everyFramesWorkRunning = false
end

M.ensureEveryFramesWork = function ()
    everyFramesWorkRunning = true
end


--- execute `fn(stop)' in every frames (except current frame)
--- it starts immediately on the next frame (maybe).
--- if stop() is called, then the animation will be stopped
--- and the associated resource will be released.
M.runEveryFrames = (function ()
    local anim = nil
    local tasks = {}
    
    local canAddToTasks = true
    local tasksToAdd = {}

    local runTasksSafety = function ()
        canAddToTasks = false
        tasksToAdd = {}

        -- run existing tasks, some tasks might be removed
        local n = 0 
        for k, v in pairs(tasks) do
            local fn = v[1]
            local stopFn = v[2]
            -- pcall(fn, stopFn)                        
            fn(stopFn)                        
            n = n + 1
        end

        -- add tasks
        for k, v in pairs(tasksToAdd) do
            tasks[k] = v                        
            n = n + 1
        end 

        if n == 0 then 
            -- remove anim
            delete(anim)
            anim = nil
        end        

        tasksToAdd = {}
        canAddToTasks = true
    end

    local ensureAnim = function ()
        if anim == nil then 
            anim = new(AnimDouble,kAnimRepeat,0,0,0,0) -- TODO verify how it works
            anim:setEvent(nil, function ()       
                if everyFramesWorkRunning then 
                    runTasksSafety()
                end
            end)
        end
    end

    local addTask = function (fn)
        local id = UniqId.get()
        local stopFn = function ()
            tasks[id] = nil
        end        
        local v = { fn, stopFn }

        if canAddToTasks then 
            tasks[id] = v 
        else 
            tasksToAdd[id] = v
        end

        ensureAnim()

        return stopFn
    end

    return addTask
end)()


return M