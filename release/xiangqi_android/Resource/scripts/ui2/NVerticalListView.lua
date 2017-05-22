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
-- @module NVerticalListView

local OO = require('ui2.util.oo')
local NScrollView = require('ui2.NScrollView')
local DSM2 = require('ui2.compat.internal.DoubleScrollingModel2')
local Task = require('ui2.util.task')
local Misc = require('ui2.util.misc')
local UniqId = require('ui2.util.uniqId')

local genNewPropId = function (drawing)
    local newId = UniqId.get()

    if drawing.m_props[newId] then 
        return #(drawing.m_props) + 1
    else
        return newId 
    end 
end 




local addClipAnimation = function (drawing, duration, beginWidth, endWidth, beginHeight, endHeight) 
    if duration <= 0 then 
        return 
    end 

    if (beginHeight == endHeight) and (beginWidth == endWidth) then 
        return 
    end 

    local newSeqId = genNewPropId(drawing)
    
    local updateClip = function (newWidth, newHeight)
        local x, y = drawing:getUnalignPos()
        drawing:setClip(x, y, newWidth, newHeight)
    end 

    local terminated = false 

    drawing.m_props[newSeqId] = {
        prop = {
            -- TODO
            dtor = function ()
                drawing.m_props[newSeqId] = nil    
                terminated = true 
            end
        },
        anim = {}
    }

    updateClip(beginWidth, endWidth)

    local startTime = sys_get_int("tick_time", 0)

    Task.runEveryFrames( function(stop)
        if terminated then 
            drawing:setClip(- 65536,- 65536, - 65536, - 65536)  -- release clip effect
            stop()
            return 
        end 

        local currentTime = sys_get_int("tick_time", 0)
        
        if currentTime - startTime >= duration then 
            terminated = true -- for some reason
            drawing:setClip(- 65536,- 65536, - 65536, - 65536)  -- release clip effect
            stop()
            return 
        end 

        local newWidth = beginWidth + (endWidth - beginWidth) / duration * (currentTime - startTime)
        local newHeight = beginHeight + (endHeight - beginHeight) / duration * (currentTime - startTime)

        updateClip(newWidth, newHeight)
    end )
end 



local M = OO.defineClass({
    extend = NScrollView,

    ctor = function (self)
        -- default handlers
        __private__.onScrollHandler = function () end
        __private__.onStopHandler = function () end
        __private__.onBeginBouncing = function () end

        -- events
        self:setEventTouch(nil,function () end);
        self:setEventDrag(self,__protected__.onEventDrag);

        local contentNode = __protected__.getContentNode(self)
        contentNode:setSize(nil, 1)

        -- init scrolling model
        __private__.createScrollingModel(self)


	    local left, top = contentNode:getUnalignPos()
	    local width, height = contentNode:getSize()

        -- __private__.currentMostLeft = left 
        -- __private__.currentMostRight = left + width
        -- __private__.currentMostTop = top
        -- __private__.currentMostBottom = top + height
        -- __private__.currentMostBottom

        local w, h = self:getSize()
        __private__.minimumContentSize = h + 1
        __private__.currentMostBottom = 0

        -- data/child
        __private__.items = {}
        
        __private__.invokeOnStop = {}

        -- bouncing state
        __private__.isBouncing = false
        __private__.isBouncingPaused = false
        __private__.isTopBannerLocked = false

        -- top banner
        __private__.topBannerMinSize = nil

        -- mouse action
        __private__.hasFingerAction = false
        __private__.isFingerActionEnabled = true 
    end,

    __private__ = {

        -- methods 
        createScrollingModel = function (self)
            local viewLength = __protected__.getViewLength(self)
            local contentSize = __protected__.getContentSize(self)

            if contentSize <= viewLength then 
                contentSize = viewLength + 1
            end 

            __private__.scrollingModel = DSM2.create(contentSize, viewLength, function (offset) 
                local fn = function ()
                    -- content
                    local contentNode = __protected__.getContentNode(self)
                    contentNode:setPos(0, offset)

                    ------------------------------- default scheme ---------------------------------------

                    __private__.scrollingModel.setScrollingScheme('s1', 'r3')

                    --------------------------------------------------------------------------------------


                    -- top banner
                    if __private__.topBannerNode then 
                        -- size
                        local newSize = math.max( __private__.topBannerMinSize, offset )
                        __private__.topBannerNode:setSize(nil, newSize)

                        -- position
                        local newPosition = math.min(offset - __private__.topBannerMinSize, 0)
                        __private__.topBannerNode:setPos(nil, newPosition)

                        -- visibility
                        __private__.topBannerNode:setVisible(offset > 0)
                    end 

                    -- scrollbar
                    __protected__.updateScrollBarScrollPos(self, offset)

                    -- subclass handler
                    __protected__.handleOnScroll(self, offset)

                    -- event handler
                    __private__.onScrollHandler(offset)
                end 

--                if __private__.isBouncing then 
--                    if __private__.onCheckNeedPauseBouncing(offset) then 
--                        self:pauseBouncing()
--                        __private__.resumeCallback = fn 
--                    else 
--                        fn()
--                    end 
--                else 
                    fn()
--                end

            end)

            __private__.scrollingModel.setOnStop(function ()
                __private__.isBouncing = false
                __private__.isBouncingPaused = false

                -- handlers
                __protected__.handleStop(self)
                __private__.onStopHandler()

                -- invoke callbacks 
                local origCallbacks = __private__.invokeOnStop
                __private__.invokeOnStop = {}
                for k, v in ipairs(origCallbacks) do 
                    v.fn(v.obj)                    
                end                 
            end)

            __private__.scrollingModel.setOnBeginBouncing(function ()
                __private__.isBouncing = true 
                __private__.isBouncingPaused = false

                if __private__.topBannerMinSize then 
                    __private__.scrollingModel.setBounceToTopNeedPauseAt(__private__.topBannerMinSize)
                end 

                __protected__.handleBeginBouncing(self)
                __private__.onBeginBouncing()
            end)

            __private__.scrollingModel.setContentPosition(0)
        end,

        stopScrollingModelSilently = function (self)
            __private__.isBouncing = false
            __private__.isBouncingPaused = false
            
            if __private__.scrollingModel then 
                __private__.scrollingModel.forceStop()
            end 
        end,

        lockTopBanner = function (self)
            if not __private__.isBouncing then 
                error('Invalid operation.')
            end

            __private__.isTopBannerLocked = true 

            -- TODO might something need to process
        end,

        unlockTopBanner = function (self)
            __private__.isTopBannerLocked = false

            -- TODO might something need to process
        end,

        touchHistory = {},

        replayTouchHistory = function ()
            local n = #(__private__.touchHistory)
            for i = 1, n do 
                local args = __private__.touchHistory[i]
                Misc.apply(__private__.processTouch, args)
            end 

            __private__.touchHistory = {}
        end,
        
        processTouch = (function ()
            local touchInfo = nil
            return function (self, finger_action, x, y, drawing_id_first, drawing_id_current, event_time)
                        local curPos = y

                        if finger_action == kFingerDown then 
                            __private__.hasFingerAction = true 

                            touchInfo = {
                                beginCursor = curPos,
                                beginContentPosition = __protected__.getContentPosition(self),
                                beginMinimumContentSize = __private__.topBannerMinSize
                            }

                            __private__.scrollingModel.handlePressLogic(curPos, event_time)

                            if __private__.isTopBannerLocked then 
                                -- 这种情况，一开始已经拉扯到上边缘了。
                                local stretchFunctions = __private__.scrollingModel.getStretchFunction()
                                local beginFingerOffset = stretchFunctions.inverseFn(touchInfo.beginContentPosition)
                                local limitFingerOffset = stretchFunctions.inverseFn(__private__.topBannerMinSize)

                                touchInfo.minFingerOffset = math.min(curPos + (limitFingerOffset - beginFingerOffset), curPos)

                                -- print_string(Debug.getVarsString()) -- TODO remove this line
                            else 
                                touchInfo = nil
                                __private__.scrollingModel.handlePressLogic(curPos, event_time)
                            end 

                    
                        elseif finger_action == kFingerMove then 

                            if __private__.isTopBannerLocked then 

                                if curPos < touchInfo.minFingerOffset then 
                                    curPos = touchInfo.minFingerOffset    
                                end 

                            end 

                            __private__.scrollingModel.handleMoveLogic(curPos, event_time)
                        elseif (finger_action == kFingerUp) or (finger_action == kFingerCancel) then 

                            __private__.hasFingerAction = false

                            if __private__.isTopBannerLocked then 

                                if curPos < touchInfo.minFingerOffset then 
                                    curPos = touchInfo.minFingerOffset    
                                end 

                            end 

                            __private__.scrollingModel.handleReleaseLogic(curPos, event_time)
                        end 
                   end 
        end)()

    },

    __protected__ = {
        getItem = function (self, index)        
            return __private__.items[index]
        end,

        --------------------------------------------------------------------------------




        getContentSize = function (self)
            local w, h = __protected__.getContentNode(self):getSize()
            return h
        end,

        getViewLength = function (self)
            local w, h = self:getSize()
            return h
        end, 
        
        getDirection = function (self)
            return NScrollView.Direction.VERTICAL
        end,

        getContentPosition = function (self)
            local contentNode = __protected__.getContentNode(self)
            local x, y = contentNode:getPos()
            return y
        end,

        -- handlers
        onEventDrag =(function ()
            local touchHistory = {}
            return function (self, finger_action, x, y, drawing_id_first, drawing_id_current, event_time)
                -- local Debug = require('ui2.util.debug')

                if __private__.scrollingModel == nil then 
                    return
                end 

                if (finger_action == kFingerDown) or (finger_action == kFingerCancel) or (finger_action == kFingerUp) then 
                    __private__.touchHistory = {}
                end 

                if not __private__.isFingerActionEnabled then 
                    -- recording 
                    table.insert(__private__.touchHistory, {
                        self, finger_action, x, y, drawing_id_first, drawing_id_current, event_time
                    })

                    return 
                end 

                __private__.processTouch(self, finger_action, x, y, drawing_id_first, drawing_id_current, event_time)

            end
        end)(),

        -- preserve for subclasses
        handleStop = function (self)
            -- do nothing            
        end,

        handleOnScroll = function (self, offset)
            -- do nothing
        end,

        handleBeginBouncing = function (self)
            -- do nothing
        end
    },


    setOnCreateView = function (self, fn, obj)
        if fn then 
            __private__.onCreateView = function (...)
                fn(obj, ...)
            end
        else 
            __private__.onCreateView = function () end
        end 
    end,

    setOnScroll = function (self, fn, obj)        
        if fn then 
            __private__.onScrollHandler = function (...) 
                fn(obj, ...)
            end
        else 
            -- nil 
            __private__.onScrollHandler = function () end
        end 
    end,

    setOnStop = function (self, fn, obj)
        if fn then 
            __private__.onStopHandler = function ()
                fn(obj)
            end        
        else 
            __private__.onStopHandler = function () end 
        end  
    end,

    setOnBeginBouncing = function (self, fn, obj)
        if fn then 
            __private__.onBeginBouncing = function () 
                fn(obj)
            end
        else 
            -- nil 
            __private__.onBeginBouncing = function () end
        end 
    end,

    -- 在下一次静止状态时执行fn(obj)。若当前处于静止状态，则立即执行。
    addInvokeOnStop = function (self, fn, obj)
        if self:isCurrentlyNoScrolling() then 
            fn(obj)
        else
            table.insert(__private__.invokeOnStop, { fn = fn, obj = obj })
        end 
    end,

    removeInvokeOnStop = function (self, fnToRemove)
        -- could not do this during invoking

        local index 

        for k, v in ipairs(__private__.invokeOnStop) do
            if __private__.invokeOnStop[i].fn == fnToRemove then 
                index = k 
                break                               
            end 
        end 

        if index then 
            table.remove(__private__.invokeOnStop, index) 
        end 
    end,

    -----------------------------------------------------------------

    -- 当前是否处于静止状态
    isCurrentlyNoScrolling = function (self)
        return (__private__.scrollingModel.isStopState()) and (__private__.isBouncing == false) -- 第二个条件可能不需要。
    end,

    addItem = function (self, item, index, ...)
        if not self:isCurrentlyNoScrolling() then 
            error('Invalid operation.')
        end

        if index == #(__private__.items) + 1 then 
            index = nil 
        end 

        if index then 
            if (index < 1) or (index > #(__private__.items) + 1) then 
                error('Index out of range.')
            end 
        end 

        -- add item
        super.addChild(self, item)

        local contentNode = __protected__.getContentNode(self)

        local needAnimation 


        if arg.n > 0 then 
            durationOfAnimation = arg[1]

            if durationOfAnimation == nil then 
                durationOfAnimation = 300
            end 

            if durationOfAnimation > 0 then 
                needAnimation = true 
            else 
                needAnimation = false
            end 
        end 
        
        local worthToAddTranslateAnimation = (function ()
            local selfX, selfY = self:getAbsolutePos()
            local selfW, selfH = self:getSize()
            local top = selfY
            local bottom = selfH + top
            local inRange = function (pos)
                return (top <= pos) and (pos <= bottom)
            end             
            return function (beginPosition, endPosition)
                return inRange(beginPosition) or inRange(endPosition)                
            end 
        end)()

        local newContentSize 

        if index then
            -- insert 

            local origItem = __protected__.getItem(self, index)
            local origX, origY = origItem:getPos()

            local left = 0
            local top = origY
        
            item:setAlign(kAlignTopLeft)
            item:setPos(left, top)
	        
	        local width, height = item:getSize()


            -- for animation

            local origItemCount = #(__private__.items)
            for i = origItemCount, index, -1 do 
                local it = __private__.items[i] 
                __private__.items[i+1] = it 

                local x, y = it:getPos()


                it:setPos(nil, height + y)

                if needAnimation then 
                    local absX, absY = it:getAbsolutePos()
                    local itWidth, itHeight = it:getSize()
                    if worthToAddTranslateAnimation(absY - height, absY + itHeight ) then 
                        local newSeq = genNewPropId(it)
                        local prop = it:addPropTranslate(newSeq, kAnimNormal, durationOfAnimation, -1, 0, 0, -height, 0)
                        prop:setEvent(nil, (function ()
                            local currentSeq = newSeq
                            return function ()
                                it:removeProp(currentSeq)
                            end 
                        end)())
                    end 
                end


            end 

            __private__.items[index] = item
            

            do 
                local it = __protected__.getItem(self, #(__private__.items))
                local x, y = it:getPos()
                local w, h = it:getSize()
                __private__.currentMostBottom = y + h
            end 
            newContentSize = math.max(__private__.currentMostBottom, __private__.minimumContentSize)


            -- add animation of the inserted item    
            if needAnimation then                 
                addClipAnimation(item, durationOfAnimation, width, width, 0, height)

                local newSeq = genNewPropId(item)
                local prop = item:addPropTransparency(newSeq, kAnimNormal, durationOfAnimation, -1, 0, 1)
                prop:setEvent(nil, (function ()
                    local currentSeq = newSeq
                    return function ()
                        item:removeProp(currentSeq)
                    end 
                end)())
            end 


        else 
            -- append

            local left = 0
            local top = __private__.currentMostBottom
        
            item:setAlign(kAlignTopLeft)
            item:setPos(left, top)
	        
	        local width, height = item:getSize()

            local right = left + width
            local bottom = top + height

            table.insert(__private__.items, item)

            __private__.currentMostBottom = bottom
            newContentSize = math.max(__private__.currentMostBottom, __private__.minimumContentSize)

            -- add animation of the inserted item    
            if needAnimation then                 
                local newSeq = genNewPropId(item)
                local prop = item:addPropTransparency(newSeq, kAnimNormal, durationOfAnimation, -1, 0, 1)

                prop:setEvent(nil, (function ()
                    local currentSeq = newSeq
                    return function ()
                        item:removeProp(currentSeq)
                    end 
                end)())

            end 


        end 

        contentNode:setSize(nil, newContentSize)                            

        -- update scrolling model

        __private__.stopScrollingModelSilently()

        if __private__.currentMostBottom > __protected__.getViewLength(self) then 
            __private__.scrollingModel.setContentSize(newContentSize)      
        end 

        __protected__.update(self)

    end,

    appendItem = function (self, newItem)
        return self:addItem(newItem)
    end,

--    notifyItemChanged = function (self, index)
--        -- TODO 当item大小改变的时候调用这个。下一个版本再加入吧。
--    end,

--    changeItem = function (self, index, newItem)
--        -- TODO
--    end,

--    getTopIndex = function (self)
--        -- TODO
--    end, 

--    getBottomIndex = function (self)
--        -- TODO
--    end, 

--    setTopIndex = function (self, index)
--        -- TODO
--    end,

--    setBottomIndex = function (self, index)
--        -- TODO
--    end,


    removeItem = function (self, index, doCleanup, ...)        
        if not self:isCurrentlyNoScrolling() then 
            error('Invalid operation.')
        end

        local item = __protected__.getItem(self, index)
        if item == nil then 
            return 
        end 

        if #(__private__.items) == 1 then 
            self:removeAllChildren()
            return
        end 

        local needAnimation 
        if arg.n > 0 then 
            durationOfAnimation = arg[1]

            if durationOfAnimation == nil then 
                durationOfAnimation = 300
            end 

            if durationOfAnimation > 0 then 
                needAnimation = true 
            else 
                needAnimation = false
            end 
        end 
        
        local contentNode = __protected__.getContentNode(self)        

        local worthToAddTranslateAnimation = (function ()
            local selfX, selfY = self:getAbsolutePos()
            local selfW, selfH = self:getSize()
            local top = selfY
            local bottom = selfH + top
            local inRange = function (pos)
                return (top <= pos) and (pos <= bottom)
            end             
            return function (beginPosition, endPosition)
                return inRange(beginPosition) or inRange(endPosition)                
            end 
        end)()



        if index == #(__private__.items) then 
            -- remove last item, no animation
            if needAnimation then                 
                local newSeq = genNewPropId(item)
                local prop = item:addPropTransparency(newSeq, kAnimNormal, durationOfAnimation, -1, 1, 0)
                prop:setEvent(nil, function ()
                    contentNode:removeChild(item, doCleanup)
                end)
            else 
                contentNode:removeChild(item, doCleanup)
            end 
            __private__.items[index] = nil
        else 
            -- item in the middle

            local deltaWidth, deltaHeight = item:getSize()

            for i = index, #(__private__.items) - 1 do
                local it = __private__.items[i + 1]
                __private__.items[i] = it
                
                local x, y = it:getPos()
                it:setPos(nil, y - deltaHeight)

                if needAnimation then 
                    local absX, absY = it:getAbsolutePos()
                    local itWidth, itHeight = it:getSize()
                    if worthToAddTranslateAnimation(absY, absY + deltaHeight + itHeight) then 
                        local newSeq = genNewPropId(it)
                        local prop = it:addPropTranslate(newSeq, kAnimNormal, durationOfAnimation, -1, 0, 0, deltaHeight, 0)

                        prop:setEvent(nil, (function ()
                            local currentSeq = newSeq
                            return function ()
                                it:removeProp(currentSeq)                        
                            end 
                        end)())

                    end 
                end
            end 

            __private__.items[ #(__private__.items) ] = nil

            -- add animation of the inserted item    
            if needAnimation then                 
                addClipAnimation(item, durationOfAnimation, deltaWidth, deltaWidth, deltaHeight, 0)

                local newSeq = genNewPropId(item)
                local prop = item:addPropTransparency(newSeq, kAnimNormal, durationOfAnimation, -1, 1, 0)
                Misc.addGlobalReference(prop)
                prop:setEvent(nil, function ()
                    Misc.removeGlobalReference(prop)
                    contentNode:removeChild(item, doCleanup)
                end)
            else 
                contentNode:removeChild(item, doCleanup)
            end 
        end 

        
        do 
            local lastItem = __private__.items[ #(__private__.items) ]
            local left, top = lastItem:getPos()
            local w, h = lastItem:getSize()
            __private__.currentMostBottom = top + h
        end 
        
        newContentSize = math.max(__private__.currentMostBottom, __private__.minimumContentSize)

        -- update scrolling model

        __private__.stopScrollingModelSilently()

        __private__.scrollingModel.setContentSize(newContentSize)      

        __protected__.update(self)

    end,

    getItem = function (self, index)
        return __protected__.getItem(self, index)        
    end,

    getIndexOfItem = function (self, item)
        for k, v in ipairs(__private__.items) do 
            if v == item then 
                return k 
            end 
        end 
        return nil
    end,

    getItemCount = function (self)
        return #(__private__.items)
    end,

    -----------------------------------------------------------------

    addChild = function(self, child)
        self:appendItem(child)
    end,

    removeChild = function(self, child, doCleanup)        
        local index = self:getIndexOfItem(child)
        return self:removeItem(index, doCleanup)
    end,

    setSize = function(self, w, h)
        if not self:isCurrentlyNoScrolling() then 
            error('Invalid operation.')
        end

	    super.setSize(self,w,h)

        if __private__.scrollingModel then 
            __private__.stopScrollingModelSilently()

            __private__.minimumContentSize = h + 1

            local contentSize = __protected__.getContentSize(self)
            if contentSize <= __private__.minimumContentSize then 
                __private__.scrollingModel.setContentSize(__private__.minimumContentSize)
            end 
            
            __private__.scrollingModel.setViewLength(h)
        end 
    end,

    removeAllChildren = function(self, doCleanup)
        if not self:isCurrentlyNoScrolling() then 
            error('Invalid operation.')
        end

        local contentNode = __protected__.getContentNode(self)
        contentNode:removeAllChildren(doCleanup)
        
        contentNode:setSize(nil, 1)
        __private__.stopScrollingModelSilently(self)
        __private__.scrollingModel.setContentSize(__protected__.getViewLength(self) + 1)      

        local w, h = self:getSize()
        __private__.minimumContentSize = h + 1
        __private__.currentMostBottom = 0

        __private__.items = {}

        __protected__.update(self)
    end,

    setTopBanner = function (self, bannerNode)
        if not self:isCurrentlyNoScrolling() then 
            error('Invalid operation.')
        end

        if __private__.topBannerNode == bannerNode then 
            return 
        end 

        if __private__.topBannerNode then 
            __protected__.removeChild(self, __private__.topBannerNode)
            __private__.topBannerNode = nil 
            __private__.topBannerMinSize = nil
        end 

        if bannerNode then 
            local contentPosition = __protected__.getContentPosition(self)

            local w, h = bannerNode:getSize()
            bannerNode:setAlign(kAlignTopLeft)
            bannerNode:setPos(nil, contentPosition - h)

            __protected__.addChild(self, bannerNode)

            if contentPosition <= 0 then 
                bannerNode:setVisible(false)
            end 

            __private__.topBannerNode = bannerNode 

            if __private__.topBannerMinSize == nil then 
                __private__.topBannerMinSize = h            
            end 
        end 
            
    end, 

    getTopBanner = function (self)
        return __private__.topBannerNode
    end,
    
    getTopBannerMinSize = function (self)
        return __private__.topBannerMinSize
    end,

    setTopBannerMinSize = function (self, value)
        if __private__.topBannerNode then 
            if value then 
                __private__.topBannerMinSize = value 
            else 
                local w, h = __private__.topBannerNode:getSize()
                __private__.topBannerMinSize = h
            end 
        else 
            __private__.topBannerNode = value 
        end 
    end,

    isBouncing = function (self)
        return __private__.isBouncing
    end,

    isBouncingPaused = function (self)
        return __private__.isBouncingPaused
    end,

    pauseBouncing = function (self)
        if not __private__.isBouncing then 
            error('Invalid operation.')
        end

        __private__.isBouncingPaused = true

        __private__.lockTopBanner(self)

        __private__.scrollingModel.pauseBouncing()    
    end,

    resumeBouncing = function (self)
        if not __private__.isBouncing then 
            error('Invalid operation.')
        end

        if not __private__.isBouncingPaused then 
            error('Invalid operation.')
        end 

        __private__.isBouncingPaused = false

        __private__.unlockTopBanner(self)

        __private__.scrollingModel.resumeBouncing()
    end,

    dtor = function (self)
        if __private__.topBannerNode then 
            delete(__private__.topBannerNode)
        end 

        local contentNode = __protected__.getContentNode(self)
        contentNode:removeAllChildren(true)

        __private__.scrollingModel.setOnStop(function () end);
        __private__.scrollingModel.forceStop();
    end,

    isFingerActionEnabled = function (self)
        return __private__.isFingerActionEnabled
    end,

    setFingerActionEnabled = function (self, value, processRecordedFingerAction)
        if __private__.hasFingerAction and (value == false) and (__private__.isFingerActionEnabled == true) then 
            error('Invalid operation.')    
        end 

        __private__.isFingerActionEnabled = value 

        if processRecordedFingerAction and (value == true) then 
            __private__.replayTouchHistory()
        end 

        __private__.touchHistory = {}
    end,
    
    hasFingerAction = function (self)
        return __private__.hasFingerAction
    end
    



})

return M