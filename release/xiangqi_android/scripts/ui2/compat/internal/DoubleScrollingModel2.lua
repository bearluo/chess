--
-- UI2 Library, Version: 1.0 Alpha (0.99.2.2058-SNAPSHOT)
-- 
-- This file is a part of UI2 Library.
--
-- Author:
-- Xiaofeng Yang     2015
--
--


--- 
--
-- @module DoubleScrollingModel2

local Task = require('ui2.util.task')
local OO = require('ui2.util.oo')

local M = { }

local sign = function (x)
    if x > 0 then 
        return 1
    elseif x < 0 then 
        return - 1
    else 
        return 0
    end 
end

local sqr = function (x)
    return x * x
end


M.create = function(contentSize, viewLength, onScrollingFn)
    -- 假设内容的初始位置为0。

    local obj = { }

    local _onStopFn = function () end
    local _onBeginBouncingFn = function () end 

    -- array of { .time, .position }
    local touchPath = { }

    -- state: overview
    local contentPosition = 0
    local isAutoScrolling = false                       -- 是否正在inertial scrolling
    local isBouncing = false                            -- 是否正在回弹
    local isRecording = false                           -- 是否需要记录手指动作
    local hasAnimation = false                          -- 是否有动画
    local contentPositionBeforeStageStart = 0           -- 某一段状态开始前的内容位置
    
    -- state: animation
    local movingDirection = 0                           -- 移动方向。-1,0,1
    local animationStartTime = 0                        -- 动画开始时间
    local bouncingFunction = nil                        -- 回弹函数。s = bouncingFunction(t), t >= 0, s >= 0.
    local scrollingFunction = nil                       -- inertial scrolling函数。   

    -- infomation about bouncing paused
    local bouncingPauseTime = 0                         -- 回弹的过程中，总共暂停了多久。
    local isPausedOnBouncing = false                    -- 回弹的过程中，当前是否处于暂停状态。
    local bouncingPauseBeginTime = nil                  -- 回弹的过程中，开始暂停的时间。

    -- 拉伸和展厅
    local bounceToTopNeedPauseAt = nil                  -- 往上回弹的过程中，必须经过的一个点。使用一次后这个值会被重置成nil。

    -------------------------------------------------------------------------

    -- some functions, forwarded
    local startAnimation


    local resetState = function()
        isAutoScrolling = false
        isBouncing = false
        isRecording = false
        hasAnimation = false
        contentPositionBeforeStageStart = 0

        movingDirection = 0
        animationStartTime = 0

        bouncingFunction = nil 
        scrollingFunction = nil 
    end

    local createTouchPathPoint = function(position, eventTime)
        return { time = eventTime, position = position }
    end

    local addToTouchPath = function(position, eventTime)
        table.insert(touchPath, createTouchPathPoint(position, eventTime))
    end

    local resetTouchPath = function()
        touchPath = { }
    end

    local getFirstPoint = function()
        if #touchPath > 0 then
            return touchPath[1]
        else
            return nil
        end
    end

    local getLastPoint = function()
        if #touchPath > 0 then
            return touchPath[#touchPath]
        else
            return nil
        end
    end

    local startRecording = function()
        resetTouchPath()
        isRecording = true
    end

    local stopRecording = function()
        isRecording = false
    end

    local StretchEdge = {
        TOP = 'top stretch',
        BOTTOM = 'bottom stretch'
    }

    -- 返回StretchEdge.TOP表示拉伸上边缘，返回StretchEdge.BOTTOM表示拉伸下边缘，返回nil表示没有拉伸。
    local checkStretch = function(newContentPosition)
        if newContentPosition > 0 then
            return StretchEdge.TOP
        elseif newContentPosition + contentSize < viewLength then
            return StretchEdge.BOTTOM
        else
            return nil
        end
    end

    local invokeScrollingFn = function(newContentPosition)
        contentPosition = newContentPosition

        if onScrollingFn then
            onScrollingFn(newContentPosition)
        end
    end

    local getCurrentFrameTime = function ()
        return sys_get_int("frame_time", 0)
    end

    local checkIfNeedReturnAndDoIt = function ()
        local checkStretchResult = checkStretch(contentPosition)                

        if checkStretchResult then 
            -- 处于被拉伸的状态。需要回弹。
            local makeReturnFunction = obj.getReturnFunctionMaker()

            if checkStretchResult == StretchEdge.TOP then 
                movingDirection = -1
                bouncingFunction = makeReturnFunction(contentPosition)
            else
                movingDirection = 1 
                bouncingFunction = makeReturnFunction(viewLength - (contentPosition + contentSize))
            end 

            contentPositionBeforeStageStart = contentPosition

            animationStartTime = getCurrentFrameTime()
            
            isAutoScrolling = false 
            isBouncing = true 
            
            -- callback
            _onBeginBouncingFn(movingDirection)

            -- reset pause info
            bouncingPauseTime = 0
            isPausedOnBouncing = false
            bouncingPauseBeginTime = nil

            stopRecording()
            startAnimation()    

            return true 
        end

        return false 
    end 


    local updateBouncing = function ()
        -- 回弹

        if isPausedOnBouncing then 
            return
        end 


        local currentTime = System.getTickTime()
        local timeDelta = currentTime - animationStartTime - bouncingPauseTime

        local s_t, maxTime = bouncingFunction( timeDelta )

        if timeDelta <= maxTime then 
            local newContentPosition = movingDirection * s_t + contentPositionBeforeStageStart

            if movingDirection < 0 then 
                if bounceToTopNeedPauseAt and (contentPositionBeforeStageStart > bounceToTopNeedPauseAt) and (newContentPosition < bounceToTopNeedPauseAt) then 
                    newContentPosition = bounceToTopNeedPauseAt
                    bounceToTopNeedPauseAt = nil
                    invokeScrollingFn(newContentPosition)            
                else 
                    invokeScrollingFn(newContentPosition)            
                end 
            else 
                -- TODO 也许同样的功能也要加上。
                invokeScrollingFn(newContentPosition)            
            end 
        else 
            -- STOP
            hasAnimation = false 

            if movingDirection < 0 then 
                invokeScrollingFn(0)
            else 
                invokeScrollingFn(viewLength - contentSize)
            end

            resetState()
            resetTouchPath()
        end 
    end 

    local updateAutoScrolling = function ()
        local currentTime = System.getTickTime()
        
        local distance = (function ()
            if movingDirection > 0 then 
                return 0 - contentPositionBeforeStageStart
            else
                return contentPositionBeforeStageStart + contentSize - viewLength
            end 
        end)()

        local timeDelta = currentTime - animationStartTime

        local s, maxTime = scrollingFunction(timeDelta, distance)

        local newContentPosition = contentPositionBeforeStageStart + movingDirection * s 

        if timeDelta <= maxTime then 
            invokeScrollingFn(newContentPosition)
        else 
            invokeScrollingFn(newContentPosition)

            if not checkIfNeedReturnAndDoIt() then 
                hasAnimation = false 
                resetState()
                resetTouchPath()                
            end 
        end 
    end

    startAnimation = function ()
        if not hasAnimation then 
            hasAnimation = true

            Task.runEveryFrames( function(stop)
                if not hasAnimation then
                    stop()

                    local firstPoint = getFirstPoint()
                    if firstPoint == nil then 
                        -- 当前没有手指动作。
                    _onStopFn()
                    end 

                    return
                end

                if isBouncing then 
                    updateBouncing()
                elseif isAutoScrolling then 
                    updateAutoScrolling()
                end 

            end )
        end 
    end

    -------------------------------------------------------------------------
    -- properties defaults
    -------------------------------------------------------------------------

    local defaultStretchFunction = {
        --- 返回x(deltaFinger)。
        --- 若x(deltaFinger) < 0，则返回0。
        fn = function(deltaFinger)

            local hView = viewLength
            local result = -0.834916 * hView + 0.287103 * hView * math.log(18.3213 + 49.7845 * deltaFinger / hView)

            if result < 0 then
                return 0
            else
                return result
            end

        end,

        --- fn的反函数。根据内容长度x，返回对应的手指位移deltaFinger。
        inverseFn = function(x)

            local hView = viewLength
            local result = 0.368013 * hView *(math.exp(3.48307 * x / hView) -1)

            if result < 0 then
                -- impossible, unless x < 0
                return 0
            else
                return result
            end

        end
    }

    obj.defaultScrollingFunctionMaker = function(theTouchPath)
        local initialSpeed = (function ()
            if #theTouchPath < 2 then 
                return 0
            end 

            local timeDiffThresold = 16      -- 间隔16毫秒才算哦！

            local lastPointPosition = theTouchPath[ #theTouchPath ].position
            local lastPointTime = theTouchPath[ #theTouchPath ].time

            if lastPointTime == nil then 
                -- 如果是模拟的，那么收到的全是nil。
                return 0
            end 

            local index = #theTouchPath - 1
            while index >= 1 do
                local time = theTouchPath[index].time 
                local timeDiff = lastPointTime - time

                if timeDiff >= timeDiffThresold then 
                    local position = theTouchPath[index].position
                    return (lastPointPosition - position) / timeDiff
                end 

                index = index - 1
            end 

            return 0 
        end)()

        if initialSpeed == 0 then 
            return 0, nil 
        end 


        -- 请满足 0 < tStart < a
        local tStart = 100
        -- 见文档
        local a = 2000
        -- 多少毫秒完成滚动
        local v0 = math.abs(initialSpeed)

        local b =( function()
            if (tStart == 10) and(a == 2000) then
                -- 在tStart = 10, a = 2000的情况下，式子可以这么简化。
                return 200.754 * v0
            else
                return a * v0 * math.sqrt((2 * a - tStart) * tStart) /(a - tStart)
            end
        end )()


        local stStart = b * math.sqrt((2 * a - tStart) * tStart) / a

        return sign(initialSpeed), function(t, distance)
            -- 分成二阶段计算

            local time1 = a - tStart
            local time2 = 500

            local stage1Fn = function (theTime)
                return b * math.sqrt((2 * a -(theTime + tStart)) *(theTime + tStart)) / a - stStart
            end

            local stage1InverseFn = function (s)
                local s0 = stStart
                local c = sqr( a * ( s + s0 ) / b )
                local x = a - math.sqrt( sqr(a) - c )
                return x - tStart
            end

            -- stage 1: inertial scrolling
            if t <= time1 then 
                local s = stage1Fn(t)

                if s <= distance then 
                    return s, time1 
                end 
            end 

            -- stage 2 and final: virtual stretch
            local stage1_S = b - stStart

            if stage1_S <= distance then 
                return stage1_S, time1
            else                 
                local totalRestS = b - distance
                local ratio = (viewLength/3) / totalRestS
                if ratio > 1 then 
                    ratio = 1
                end 

                local stage1TimeSpent = stage1InverseFn(distance)

                local s1 = stage1Fn( stage1TimeSpent + math.min( math.max(0, (t - stage1TimeSpent)) / ratio, time1 ) )

                local s1_t = (s1 - distance) * ratio + distance

                return s1_t, (time1 - stage1TimeSpent) * ratio + stage1TimeSpent -- 这个时间不知道对不对
            end 

        end
    end




    -- 同default，稍微改几个参数。
    obj.scrollingFunctionMaker1 = function(theTouchPath)

        local initialSpeed = (function ()
            if #theTouchPath < 2 then 
                return 0
            end 

            local timeDiffThresold = 16      -- 间隔16毫秒才算哦！

            local lastPointPosition = theTouchPath[ #theTouchPath ].position
            local lastPointTime = theTouchPath[ #theTouchPath ].time

            if lastPointTime == nil then 
                -- 如果是模拟的，那么收到的全是nil。
                return 0
            end 

            local index = #theTouchPath - 1
            while index >= 1 do
                local time = theTouchPath[index].time 
                local timeDiff = lastPointTime - time

                if timeDiff >= timeDiffThresold then 
                    local position = theTouchPath[index].position
                    return (lastPointPosition - position) / timeDiff
                end 

                index = index - 1
            end 

            return 0 
        end)()

        if initialSpeed == 0 then 
            return 0, nil 
        end 


        -- 请满足 0 < tStart < a
        local tStart = 100
        -- 见文档
        local a = 2000
        -- 多少毫秒完成滚动
        local v0 = math.abs(initialSpeed)

        local b =( function()
            if (tStart == 10) and(a == 2000) then
                -- 在tStart = 10, a = 2000的情况下，式子可以这么简化。
                return 200.754 * v0
            else
                return a * v0 * math.sqrt((2 * a - tStart) * tStart) /(a - tStart)
            end
        end )()


        local stStart = b * math.sqrt((2 * a - tStart) * tStart) / a

        return sign(initialSpeed), function(t, distance)
            -- 分成二阶段计算

            local time1 = a - tStart
            local time2 = 500

            local stage1Fn = function (theTime)
                return b * math.sqrt((2 * a -(theTime + tStart)) *(theTime + tStart)) / a - stStart
            end

            local stage1InverseFn = function (s)
                local s0 = stStart
                local c = sqr( a * ( s + s0 ) / b )
                local x = a - math.sqrt( sqr(a) - c )
                return x - tStart
            end

            -- stage 1: inertial scrolling
            if t <= time1 then 
                local s = stage1Fn(t)

                if s <= distance then 
                    return s, time1 
                end 
            end 

            -- stage 2 and final: virtual stretch
            local stage1_S = b - stStart

            if stage1_S <= distance then 
                return stage1_S, time1
            else                 
                local totalRestS = b - distance

                local ratio = 1 / 20

                local stage1TimeSpent = stage1InverseFn(distance)

                local s1 = stage1Fn( stage1TimeSpent + math.min( math.max(0, (t - stage1TimeSpent)) / ratio, time1 ) )

                local s1_t = (s1 - distance) * ratio + distance


                return s1_t, (time1 - stage1TimeSpent) * ratio + stage1TimeSpent -- 这个时间不知道对不对
            end 

        end
    end






    obj.scrollingFunctionMaker2 = function(theTouchPath)

        local initialSpeed = (function ()
            if #theTouchPath < 2 then 
                return 0
            end 

            local timeDiffThresold = 16      -- 间隔16毫秒才算哦！

            local lastPointPosition = theTouchPath[ #theTouchPath ].position
            local lastPointTime = theTouchPath[ #theTouchPath ].time

            if lastPointTime == nil then 
                -- 如果是模拟的，那么收到的全是nil。
                return 0
            end 

            local index = #theTouchPath - 1
            while index >= 1 do
                local time = theTouchPath[index].time 
                local timeDiff = lastPointTime - time

                if timeDiff >= timeDiffThresold then 
                    local position = theTouchPath[index].position
                    return (lastPointPosition - position) / timeDiff
                end 

                index = index - 1
            end 

            return 0 
        end)()

        if initialSpeed == 0 then 
            return 0, nil 
        end 


        local a = 0.00539685
        local v0 = math.abs(initialSpeed)
        local timeToEndOrig = v0/a
        local timeToEndOrigDistance = v0*v0 / (2*a)

        return sign(initialSpeed), function(t, distance)
            -- 分成二阶段计算

            local time1 = (function ()
                if distance >= timeToEndOrigDistance then 
                    return timeToEndOrig
                else 
                    local d = -2 * a * distance + v0*v0
                    return (v0 - math.sqrt(d)) / a        
                end
            end)()
            
            
            local time2 = 400

            local stage1Fn = function (theTime)
                local t = theTime
                return v0*t - a*t*t/2
            end

            -- stage 1: inertial scrolling
            if t <= time1 then 
                local s = stage1Fn(t)

                if s <= distance then 
                    return s, time1 
                end 
            end 

            -- stage 2 and final: virtual stretch

            if timeToEndOrigDistance <= distance then 
                return timeToEndOrigDistance, time1
            else                 
                local vEntry = - math.max(0, v0 - a*time1)

                local y0 = (function ()
                    return math.log( (timeToEndOrigDistance - distance) / viewLength ) * viewLength * 0.3
                end)()

                local x1 = 9 * y0 / ( 2 * vEntry )
                time2 = x1 / 2




                local stage2_SFn = function (x)
                    return 2 * y0 / math.pow(x1,3) * math.pow(x,3) - 3 * y0 / math.pow(x1,2) * math.pow(x,2) + y0
                end

                local stage2_S = - stage2_SFn(t - time1 - x1/2)

                return distance + stage2_S, time1 + time2                
            end 

        end
    end

    obj.scrollingFunctionMaker3 = function(theTouchPath)
        local initialSpeed = (function ()
            if #theTouchPath < 2 then 
                return 0
            end 

            local timeDiffThresold = 16      -- 间隔16毫秒才算哦！

            local lastPointPosition = theTouchPath[ #theTouchPath ].position
            local lastPointTime = theTouchPath[ #theTouchPath ].time

            if lastPointTime == nil then 
                -- 如果是模拟的，那么收到的全是nil。
                return 0
            end 

            local index = #theTouchPath - 1
            while index >= 1 do
                local time = theTouchPath[index].time 
                local timeDiff = lastPointTime - time

                if timeDiff >= timeDiffThresold then 
                    local position = theTouchPath[index].position
                    return (lastPointPosition - position) / timeDiff
                end 

                index = index - 1
            end 

            return 0 
        end)()

        if initialSpeed == 0 then 
            return 0, nil 
        end 


        -- 请满足 0 < tStart < a
        local tStart = 100
        -- 见文档
        local a = 2000
        -- 多少毫秒完成滚动
        local v0 = math.abs(initialSpeed)

        local b =( function()
            if (tStart == 10) and(a == 2000) then
                -- 在tStart = 10, a = 2000的情况下，式子可以这么简化。
                return 200.754 * v0
            else
                return a * v0 * math.sqrt((2 * a - tStart) * tStart) /(a - tStart)
            end
        end )()


        local stStart = b * math.sqrt((2 * a - tStart) * tStart) / a

        return sign(initialSpeed), function(t, distance)
            -- 分成二阶段计算

            local time1 = a - tStart
            local time2 = 500

            local stage1Fn = function (theTime)
                return b * math.sqrt((2 * a -(theTime + tStart)) *(theTime + tStart)) / a - stStart
            end

            local stage1InverseFn = function (s)
                local s0 = stStart
                local c = sqr( a * ( s + s0 ) / b )
                local x = a - math.sqrt( sqr(a) - c )
                return x - tStart
            end

            -- stage 1: inertial scrolling
            if t <= time1 then 
                local s = stage1Fn(t)

                if s <= distance then 
                    return s, time1 
                end 
            end 

            -- stage 2 and final: virtual stretch
            local stage1_S = b - stStart

            if stage1_S <= distance then 
                return stage1_S, time1
            else                 
                local totalRestS = b - distance

                local ratio = math.log(totalRestS / viewLength + 1) * (viewLength / 3 * (1/2) ) / totalRestS


                local stage1TimeSpent = stage1InverseFn(distance)

                local s1 = stage1Fn( stage1TimeSpent + math.min( math.max(0, (t - stage1TimeSpent)) / ratio, time1 ) )

                local s1_t = (s1 - distance) * ratio + distance

                return s1_t, (time1 - stage1TimeSpent) * ratio + stage1TimeSpent 
            end 

        end
    end
















    obj.returnFunctionMaker1 = function(totalDelta)
        local a = 500                    -- 多少毫秒完成回弹
        local b = totalDelta

        return function(t)
            -- 返回s(t)，最长scroll时间。确保s(t) >= 0。
            if t >= a then
                return totalDelta, a
            else
                local s = b * math.sqrt((2 * a - t) * t) / a
                return math.min(s, totalDelta), a
            end
        end
    end


    obj.returnFunctionMaker2 = function(totalDelta)
        local maxTime = 800                    -- 多少毫秒完成回弹

        local y0 = - math.abs(totalDelta)
        local x1 = maxTime

        local a = 2 * y0 / math.pow(x1, 3)
        local b = - 3 * y0 / math.pow(x1, 2)
        local d = y0

        return function(t)
            -- 返回s(t)，最长scroll时间。确保s(t) >= 0。
            local x = t
            
            if t >= maxTime then
                return totalDelta, maxTime
            else                
                local s = a * math.pow(x, 3) + b * math.pow(x, 2) + d + math.abs(totalDelta)
                return math.min(s, totalDelta), maxTime
            end
        end
    end



    -- 这个是拟合后拉长的效果。
    obj.defaultReturnFunctionMaker = function(totalDelta)
        local pFactor = {
            [6] = 103.243,
            [5] = -234.611,
            [4] = 208.175,
            [3] = -84.7031,
            [2] = 18.6066,
            [1] = -0.328803,
            [0] = 0.0565048
        }

        local reachEnd = false 

        local s = totalDelta

        return function(t)
            -- 返回s(t)，最长scroll时间。确保s(t) >= 0。

            local timeFactor = 683

            local x = t / timeFactor + 0.00942354

            local p = 0
            for i=0, 6 do 
                p = p + math.pow(x, i) * pFactor[i]                            
            end 

            local s_t = s / 1.89 * ( 1 + math.cos( 1 / ( p + 1/math.pi ) ) ) - 0.0556527 * s

            if reachEnd or (s_t >= s) then 
                reachEnd = true 
                return totalDelta, 0
            else 
                if s_t < 0 then 
                    return 0, t + 1000
                else 
                    return s_t, t + 1000
                end
            end 
        end
    end


    -------------------------------------------------------------------------
    -- properties
    -------------------------------------------------------------------------

    OO.addProperty(obj, {
        name = "ViewLength",
        getter = function(_obj, _value)
            return viewLength
        end,
        setter = function(_obj, newValue, _rawSetter)
            --- 修改可视框的大小。如果成功，返回true；否则，返回false。
            --- 只有在`STOP'状态下才能修改成功。
            --- 并且，必须满足 contentSize > viewLength。
            if obj.isStopState() and (contentSize > newValue) then                 
                viewLength = newValue 
                return true 
            else 
                return false 
            end    
        end
    } )


    OO.addProperty(obj, {
        name = "ContentSize",
        getter = function(_obj, _value)
            return contentSize
        end,
        setter = function(_obj, newValue, _rawSetter)
            --- 修改内容的大小。如果成功，返回true；否则，返回false。
            --- 只有在`STOP'状态下才能修改成功。
            --- 并且，必须满足 contentSize > viewLength。
            if obj.isStopState() and (newValue > viewLength) then                 
                contentSize = newValue
                checkIfNeedReturnAndDoIt()
                return true 
            else 
                return false 
            end    
        end
    } )

    OO.addProperty(obj, {
        name = "ContentPosition",
        getter = function(_obj, _value)
            return contentPosition
        end,
        setter = function(_obj, newValue, _rawSetter)
            --- 修改的位置。如果成功，返回true；否则，返回false。
            --- 只有在`STOP'状态下才能修改成功。
            --- 如果移动后处在stretch状态，那么会启动`Return'动作。
            if obj.isStopState() then                 
                
                invokeScrollingFn(newValue)
                
                checkIfNeedReturnAndDoIt()

                return true 
            else 
                return false 
            end    
        end
    } )

    -- onScrollingFn(delta, offset)
    OO.addProperty(obj, {
        name = "OnScrollingFunction",
        initValue = onScrollingFn,
        getter = function(_obj, _value)
            return onScrollingFn
        end,
        setter = function(_obj, newValue, _rawSetter)            
            onScrollingFn = newValue
        end
    } )


    OO.addProperty(obj, {
        name = "StretchFunction",
        initValue = defaultStretchFunction
    } )



    OO.addProperty(obj, {
        name = "ScrollingFunctionMaker",
        initValue = obj.defaultScrollingFunctionMaker
    } )



    OO.addProperty(obj, {
        name = "ReturnFunctionMaker",
        initValue = obj.defaultReturnFunctionMaker
    } )


    obj.setOnStop = function (fn)
        if fn then 
            _onStopFn = fn 
        else 
            _onStopFn = function () end 
        end 
    end

    obj.getOnStop = function ()
        return _onStopFn
    end

    obj.setOnBeginBouncing = function (fn)
        if fn then 
            _onBeginBouncingFn = fn 
        else 
            _onBeginBouncingFn = function () end 
        end 
    end 

    obj.getOnBeginBouncing = function ()
        return _onBeginBouncingFn
    end

    obj.setScrollingScheme = function (inertialScrolling, bounce)
        local sTable = {
            ['s.default'] = obj.defaultScrollingFunctionMaker,
            ['s1'] = obj.scrollingFunctionMaker1,
            ['s2'] = obj.scrollingFunctionMaker2,
            ['s3'] = obj.scrollingFunctionMaker3
        }

        local rTable = {
            ['r.default'] = obj.defaultReturnFunctionMaker,
            ['r1'] = obj.returnFunctionMaker1,
            ['r2'] = obj.returnFunctionMaker2
        }

        local sfn = sTable[inertialScrolling]
        if sfn == nil then 
            sfn = sTable['s.default']
        end 
        obj.setScrollingFunctionMaker(sfn)

        local rfn = rTable[bounce]
        if rfn == nil then 
            rfn = rTable['r.default']
        end 
        obj.setReturnFunctionMaker( rfn )
    end

    -- TODO 合法性检查：
    -- * 当前是否在回弹状态！
    -- * 是否已经调用了forceStop
    obj.pauseBouncing = function ()
        if isPausedOnBouncing then 
            return 
        end 

        isPausedOnBouncing = true 
        bouncingPauseBeginTime = System.getTickTime()
    end 

    -- TODO 合法性检查：
    -- * 当前是否在回弹状态！
    -- * 是否已经调用了forceStop
    obj.resumeBouncing = function ()
        if isPausedOnBouncing then 
            local currentTime = System.getTickTime()
            bouncingPauseTime = bouncingPauseTime + currentTime - bouncingPauseBeginTime
            bouncingPauseBeginTime = nil
            isPausedOnBouncing = false
        end 
    end

    obj.setBounceToTopNeedPauseAt = function (point)
        bounceToTopNeedPauseAt = point
    end

    -------------------------------------------------------------------------
    -- methods
    -------------------------------------------------------------------------

    --- 强制停止。
    obj.forceStop = function ()
        resetState()    
        resetTouchPath()
    end

    --- 返回当前是否是`STOP'状态。
    obj.isStopState = function ()
        return 
                (contentPosition <= 0)
            and (contentPosition + contentSize >= viewLength)
            and (hasAnimation == false)
            and (isAutoScrolling == false)
            and (isBouncing == false)
            and (isRecording == false)
    end    

    obj.handlePressLogic = function(currentFingerPosition, eventTime)
        resetState()
        startRecording()

        addToTouchPath(currentFingerPosition, eventTime)

        contentPositionBeforeStageStart = contentPosition
        hasAnimation = false
        isAutoScrolling = false
        isBouncing = false
        isRecording = true 
    end

    obj.handleMoveLogic = function(currentFingerPosition, eventTime)
        local firstPoint = getFirstPoint()
        if not firstPoint then return end;
        local fingerOffset = currentFingerPosition - firstPoint.position


        if isRecording then
            addToTouchPath(currentFingerPosition, eventTime)
        end

        local stretchBeforeStart = checkStretch(contentPositionBeforeStageStart)

        local stateChanged = false

        if stretchBeforeStart == StretchEdge.TOP then
            -- 在开头的时候，已经是拉伸上边缘
            local stretchFunctions = obj.getStretchFunction()
            local fingerOffsetBeforeStart = stretchFunctions.inverseFn(contentPositionBeforeStageStart)
            local newFingerOffset = fingerOffsetBeforeStart + fingerOffset

            if newFingerOffset > 0 then
                invokeScrollingFn(stretchFunctions.fn(newFingerOffset))
            else
                -- 转移到正常移动状态
                --
                -- 注意：这样是会有误差的。若ContentSize == ViewLength，那么会直接进入拉伸下边缘的状态。此时使用这种非拉伸状态的行为，会导致误差产生。不过误差非常微小，可以忽略。
                invokeScrollingFn(newFingerOffset)

                stateChanged = true
            end
        elseif stretchBeforeStart == StretchEdge.BOTTOM then
            -- 在开头的时候，已经是拉伸下边缘
            local stretchFunctions = obj.getStretchFunction()
            local fingerOffsetBeforeStart = stretchFunctions.inverseFn( viewLength - (contentPositionBeforeStageStart + contentSize) )
            local newFingerOffset = (viewLength - fingerOffsetBeforeStart) + fingerOffset

            if newFingerOffset < viewLength then
                invokeScrollingFn( viewLength - stretchFunctions.fn( viewLength - newFingerOffset ) - contentSize )
            else
                -- 转移到正常移动状态
                --
                -- 同样注意和上边一样的误差可能性。
                invokeScrollingFn( newFingerOffset - contentSize )

                stateChanged = true
            end
        else
            -- 通常情况
            local newContentPosition = contentPositionBeforeStageStart + fingerOffset

            local stretchCheckResult = checkStretch(newContentPosition)

            if stretchCheckResult == StretchEdge.TOP then
                -- 通常移动转入拉伸上边缘
                local stretchFn = obj.getStretchFunction().fn
                invokeScrollingFn(stretchFn(newContentPosition))

                stateChanged = true
            elseif stretchCheckResult == StretchEdge.BOTTOM then
                -- 通常移动转入拉伸下边缘
                local stretchFn = obj.getStretchFunction().fn
                invokeScrollingFn(viewLength - stretchFn(viewLength -(newContentPosition + contentSize)) - contentSize)

                stateChanged = true
            else
                -- 通常的移动
                invokeScrollingFn(newContentPosition)
            end
        end

        if stateChanged then
            local newStretchKind = checkStretch(contentPosition)

            if newStretchKind then
                contentPositionBeforeStageStart = contentPosition
                resetTouchPath()
                addToTouchPath(currentFingerPosition, eventTime)
            else
                -- 回到正常拉伸模式
                contentPositionBeforeStageStart = contentPosition
                resetTouchPath()
                addToTouchPath(currentFingerPosition, eventTime)
            end
        end
    end

    obj.handleReleaseLogic = function(currentFingerPosition, eventTime)
        -- currentFingerPosition总是和最后一个move点的相同。

        if not checkIfNeedReturnAndDoIt() then 
            -- 放手后滚动。

            local makeScrollingFunction = obj.getScrollingFunctionMaker()
            movingDirection, scrollingFunction = makeScrollingFunction(touchPath)

            if movingDirection == 0 then 
                -- no move, reset to `stop' state
                resetState()
                resetTouchPath()

                return
            end 

            movingDirection = sign(movingDirection)    

            contentPositionBeforeStageStart = contentPosition

            animationStartTime = getCurrentFrameTime()

            isAutoScrolling = true 
            isBouncing = false 
            
            stopRecording()
            startAnimation()    
        end 
    end


    -- initialization
    resetTouchPath()

    return obj
end





return M