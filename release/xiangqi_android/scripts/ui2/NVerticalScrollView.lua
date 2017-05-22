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
-- @module NVerticalScrollView

local OO = require('ui2.util.oo')
local NScrollView = require('ui2.NScrollView')
local DSM2 = require("ui2.compat.internal.DoubleScrollingModel2")

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

        local contentNode = __protected__.getContentNode()
        contentNode:setSize(nil, 1)

        -- init scrolling model
        __private__.createScrollingModel(self)


	    local left, top = contentNode:getUnalignPos()
	    local width, height = contentNode:getSize()

        __private__.currentMostLeft = left 
        __private__.currentMostRight = left + width
        __private__.currentMostTop = top
        __private__.currentMostBottom = top + height

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
                -- content
                local contentNode = __protected__.getContentNode(self)
                contentNode:setPos(0, offset)

                -- top banner
                if __private__.topBannerNode then 
                    local w, h = __private__.topBannerNode:getSize()
                    __private__.topBannerNode:setPos(nil, offset - h)
                    __private__.topBannerNode:setVisible(offset > 0)
                end 

                -- scrollbar
                __protected__.updateScrollBarScrollPos(self, offset)

                -- subclass handler
                __protected__.handleOnScroll(self, offset)

                -- event handler
                __private__.onScrollHandler(offset)
            end)

            __private__.scrollingModel.setOnStop(function ()
                __protected__.handleStop(self)
                __private__.onStopHandler()
            end)

            __private__.scrollingModel.setOnBeginBouncing(function ()
                __protected__.handleBeginBouncing(self)
                __private__.onBeginBouncing()
            end)

            __private__.scrollingModel.setContentPosition(0)
        end,

        stopScrollingModelSilently = function (self)
            -- TODO 不知道这样子行不行

            if __private__.scrollingModel then 
--                local origOnStop = __private__.scrollingModel.getOnStop()

--                __private__.scrollingModel.setOnStop(function () 
--                    __private__.scrollingModel.setOnStop(origOnStop)
--                end)

                __private__.scrollingModel.forceStop()
            end 

        end

    },

    __protected__ = {
        getContentSize = function (self)
            local w, h = __protected__.getContentNode():getSize()
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
            local contentNode = __protected__.getContentNode()
            local x, y = contentNode:getPos()
            return y
        end,

        -- handlers
        onEventDrag = function (self, finger_action, x, y, drawing_id_first, drawing_id_current, event_time)
            if __private__.scrollingModel == nil then 
                return
            end 

            local curPos = y

            if finger_action == kFingerDown then 
                __private__.scrollingModel.handlePressLogic(curPos, event_time)
            elseif finger_action == kFingerMove then 
                __private__.scrollingModel.handleMoveLogic(curPos, event_time)
            elseif (finger_action == kFingerUp) or (finger_action == kFingerCancel) then 
                __private__.scrollingModel.handleReleaseLogic(curPos, event_time)
            end 
        end,

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

    addChild = function(self, child)
        super.addChild(self, child)

        local contentNode = __protected__.getContentNode()

	    local left, top = child:getPos()
	    local width, height = child:getSize()
        local right = left + width
        local bottom = top + height

        __private__.currentMostLeft = math.min(left, __private__.currentMostLeft)
        __private__.currentMostRight = math.max(right, __private__.currentMostRight)
        __private__.currentMostTop = math.min(top, __private__.currentMostTop)
        __private__.currentMostBottom = math.max(bottom, __private__.currentMostBottom)

        -- adjust size of content node 

--         local newX = __private__.currentMostLeft
--         local newY = __private__.currentMostTop
--         local newWidth = __private__.currentMostRight - __private__.currentMostLeft

--         contentNode:setPos(0, newY)
        contentNode:setSize(__private__.currentMostRight, __private__.currentMostBottom)        

--        if __private__.scrollingModel then 
            __private__.stopScrollingModelSilently()

            if __private__.currentMostBottom > __protected__.getViewLength(self) then 
                __private__.scrollingModel.setContentSize(__private__.currentMostBottom)      
            end 

            
--        else 
--            -- create scrolling model when necessary
--            do 
--                local w, h = self:getSize()


--                if __protected__.getContentSize(self) > h then 
--                    __private__.createScrollingModel(self)
--                end 
--            end 

--        end 

        
        __protected__.update(self)

    end,

    removeChild = function(self, child, doCleanup)        
        local contentNode = __protected__.getContentNode()
        contentNode:removeChild(child, doCleanup)

        if #(super.getChildren(self)) == 0 then 
            self:removeAllChildren()
        end 
    end,

    setSize = function(self, w, h)
	    super.setSize(self,w,h)

        if __private__.scrollingModel then 
            __private__.stopScrollingModelSilently()

            local contentSize = __protected__.getContentSize(self)
            if contentSize <= h then 
                __private__.scrollingModel.setContentSize(h + 1)
            end 
            
            __private__.scrollingModel.setViewLength(h)
        end 
    end,

    removeAllChildren = function(self, doCleanup)
        local contentNode = __protected__.getContentNode(self)
        contentNode:removeAllChildren()
        
        contentNode:setSize(nil, 1)
        __private__.stopScrollingModelSilently(self)
        __private__.scrollingModel.setContentSize(__protected__.getViewLength(self) + 1)      

        __private__.currentMostLeft = 0
        __private__.currentMostRight = 0
        __private__.currentMostTop = 0
        __private__.currentMostBottom = 0

        __protected__.update(self)
    end,

    setTopBanner = function (self, bannerNode)

        if __private__.topBannerNode == bannerNode then 
            return 
        end 

        if __private__.topBannerNode then 
            __protected__.removeChild(self, __private__.topBannerNode)
            __private__.topBannerNode = nil 
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
        end 
            
    end, 

    getTopBanner = function (self)
        return __private__.topBannerNode
    end, 

    -- TODO 合法性检查：
    -- * 当前是否在回弹状态！
    -- * 是否已经调用了forceStop
    pauseBouncing = function (self)
        __private__.scrollingModel.pauseBouncing()    
    end,

    -- TODO 合法性检查：
    -- * 当前是否在回弹状态！
    -- * 是否已经调用了forceStop
    resumeBouncing = function (self)
        __private__.scrollingModel.resumeBouncing()
    end



})

return M