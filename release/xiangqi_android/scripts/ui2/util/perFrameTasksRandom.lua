--
-- UI2 Library, Version: 1.0 Alpha (0.99.2.2058-SNAPSHOT)
-- 
-- This file is a part of UI2 Library.
--
-- Author:
-- Xiaofeng Yang     2015
--
--

-- Run a task per frame, in randomly sequence.

local Task = require('ui2.util.task')
local UniqId = require('ui2.util.uniqId')

local M = {}

local paused = false

-- k: number(id)
-- v: { stopFn, kv of id => fn }
local taskSets = {}

local ensureTaskSetIsRunning = function (taskSetId)
    if paused then 
        return
    end 

    if (taskSets[taskSetId] == nil) or (taskSets[taskSetId].stopFn == nil)  then 
        local stopFn = Task.runEveryFrames(function (stop)
            if paused then 
                stop()
                taskSets[taskSetId].stopFn = nil

                return
            end 

            local v = taskSets[taskSetId]
            local fnId, fn = next(v.taskList)

            if fnId == nil then 
                stop()

                taskSets[taskSetId] = nil
            else 
                -- pcall(fn)
                fn()

                v.taskList[fnId] = nil    
            end 
        end)

        if taskSets[taskSetId] == nil then 
            local v = { stopFn = stopFn, taskList = {} }
            taskSets[taskSetId] = v
        else 
            taskSets[taskSetId].stopFn = stopFn
        end
    end
end

M.setPaused = function (value)
    if paused == value then 
        return
    end 

    paused = value 

    if not paused then 
        for k, v in pairs(taskSets) do 
            if v.stopFn == nil then 
                ensureTaskSetIsRunning(k)                
            end             
        end 
    end 

    -- paused == true, will be stopped in the next frame
end


M.addToPerFrameTaskSet = function (fn, taskSetId)  
    if taskSetId == nil then 
        taskSetId = 0
    end 

    ensureTaskSetIsRunning(taskSetId)        

    local taskId = UniqId.get()

    if taskSets[taskSetId] == nil then 
        taskSets[taskSetId] = { stopFn = nil, taskList = {} }
    end 

    taskSets[taskSetId].taskList[taskId] = fn

    return taskId
end

M.removeFromPerFrameTaskSet = function (taskId, taskSetId)   
    if taskSetId == nil then 
        taskSetId = 0
    end 

    if taskSets[taskSetId] then 
        taskSets[taskSetId].taskList[taskId] = nil   
    end
end

-- some common task sets
local _taskSetImageLoadId = UniqId.get()

M.getImageLoadTaskSetId = function () 
    return _taskSetImageLoadId
end


return M

