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
-- @module NScrollView

require('ui2/compat/scrollBar2')

local OO = require('ui2.util.oo')
local NNode = require('ui2.NNode')
local Enum = require('ui2.util.enum')

local M

M = OO.defineClass({
    extend = NNode,
    
    -- methods
    ctor = function (self)            
        __private__.direction = __protected__.getDirection(self)
        __private__.scrollBarWidth = 8

        -- content node
        __private__.contentNode = NNode.create()
        -- __private__.contentNode:setDebugName('contentNode')

        __private__.contentNode:setAlign(kAlignTopLeft)
        __private__.contentNode:setPos(0, 0)
        __private__.contentNode:setSize(100, 100)
        super.addChild(self, __private__.contentNode)

        -- default size   
        super.setSize(self,100,100)   

        -- fix an old bug
        __private__.isDestroying = false
    end, 

    setScrollBarWidth = function (self, value)
        if value ~= __private__.scrollBarWidth then 
            __private__.scrollBarWidth = value
            __private__.updateScrollBarPosAndSize(self)
        end 
    end,

    getScrollBarWidth = function (self)
        return __private__.scrollBarWidth
    end,

    __private__ = {

        updateScrollBarPosAndSize = function (self)
            if not __protected__.isNeedScrollBar(self) then 
                __private__.releaseScrollBar(self)                
            end 

            if __private__.scrollBar == nil then 
                return
            end 

            local w, h = self:getPos()

            if __private__.direction == M.Direction.VERTICAL then 
		        __private__.scrollBar:setAlign(kAlignTopRight)
		        __private__.scrollBar:setPos(0,0)
		        __private__.scrollBar:setSize(__private__.scrollBarWidth, h)
	        else
		        __private__.scrollBar:setAlign(kAlignBottomLeft)
		        __private__.scrollBar:setPos(0,0)
		        __private__.scrollBar:setSize(w, __private__.scrollBarWidth)
            end 
        end,


        createScrollBar = function (self)
            if __private__.isDestroying then 
                return 
            end 

            local contentSize = __protected__.getContentSize(self)
            local viewLength = __protected__.getViewLength(self)
            
            __private__.scrollBar = new(ScrollBar2,__private__.direction,viewLength,contentSize)
            super.addChild(self, __private__.scrollBar)

            __private__.scrollBar:setStartPos(__protected__.getContentPosition())

            __private__.updateScrollBarPosAndSize(self)

            __private__.scrollBar:setLevel(1)
            __private__.scrollBar:setVisibleImmediately(false)
        end,

        releaseScrollBar = function (self)
            if __private__.scrollBar then 
                super.removeChild(self, __private__.scrollBar)
                delete(__private__.scrollBar)
                __private__.scrollBar = nil
            end 
        end,

        updateScrollBar = function(self)
            if not __protected__.isNeedScrollBar(self) then 
                __private__.releaseScrollBar(self)                
                return
            end 

            if __private__.scrollBar then 
--                __private__.scrollBar:setFrameLength(__protected__.getViewLength(self))
--                __private__.scrollBar:setViewLength(__protected__.getContentSize(self))
--                __private__.scrollBar:setStartPos(__protected__.getContentPosition(self))
                __private__.releaseScrollBar(self)                
                __private__.createScrollBar(self)
            else
                __private__.createScrollBar(self)
            end 
        end
    },

    __protected__ = {
        addChild = function(self, child)
            super.addChild(self, child)
        end,

        removeChild = function (self, child, cleanup)
            super.removeChild(self, child, cleanup)
        end,

        isNeedScrollBar = function (self)
            local contentSize = __protected__.getContentSize(self)
            local viewLength = __protected__.getViewLength(self)

            return contentSize > viewLength
        end,

        updateScrollBarScrollPos = function (self, newOffset)
            if __private__.scrollBar then 
                __private__.scrollBar:setScrollPos(newOffset)
            end             
        end,

        getContentNode = function (self)
            return __private__.contentNode
        end,

        update = function (self)
            __private__.updateScrollBar(self)
        end, 

        -- abstract
        getContentSize = function (self)
            error('Derived class should implement this method.')
        end,

        getViewLength = function (self)
            error('Derived class should implement this method.')
        end, 
        
        getDirection = function (self)
            error('Derived class should implement this method.')
        end,

        getContentPosition = function (self)
            error('Derived class should implement this method.')
        end
    },


    -- override DrawingEmpty, public interface
    addChild = function(self, child)
        __private__.contentNode:addChild(child)

        local optimize
        optimize = function (obj)
            drawing_set_bounding_circle_visible_test( obj.m_drawingID, 1 )
            local children = obj:getChildren()
            for k, v in pairs(children) do
                optimize(v)                                   
            end 
        end 
        optimize(child)
    
        __protected__.update(self)
    end,

    removeChild = function(self, child, doCleanup)
        __private__.contentNode:removeChild(child)
    end,

    -- override DrawingEmpty

    getChildren = function (self)
        return __private__.contentNode:getChildren()
    end,

    setPos = function(self, x, y)
	    super.setPos(self,x,y)

	    local x,y = self:getUnalignPos()
	    local w,h = self:getSize()

	    self:setClip(x,y,w,h)
    end,

    setSize = function(self, w, h)
	    super.setSize(self,w,h)

	    local x,y = self:getUnalignPos()
	    local w,h = self:getSize()

	    self:setClip(x,y,w,h)

        __protected__.update(self)
    end,

    setAlign = function(self, align)
	    super.setAlign(self,align)

	    local x,y = self:getUnalignPos()
	    local w,h = self:getSize()

	    self:setClip(x,y,w,h)
    end,

    setFillRegion = function(self, doFill, topLeftX, topLeftY, bottomRightX, bottomRightY)
	    super.setFillRegion(self,doFill,topLeftX,topLeftY,bottomRightX,bottomRightY)

	    local x,y = self:getUnalignPos()
	    local w,h = self:getSize()

	    self:setClip(x,y,w,h)

	    __protected__.update(self)
    end,

    setFillParent = function(self, doFillParentWidth, doFillParentHeight)
	    super.setFillParent(self,doFillParentWidth,doFillParentHeight)

	    local x,y = self:getUnalignPos()
	    local w,h = self:getSize()

	    self:setClip(x,y,w,h)
	    
        __protected__.update(self)
    end,

    reviseSize = function(self)
	    super.reviseSize(self)

	    local x,y = self:getUnalignPos()
	    local w,h = self:getSize()

	    self:setClip(x,y,w,h)

	    __protected__.update(self)
    end,

    revisePos = function(self)
	    super.revisePos(self)

	    local x,y = self:getUnalignPos()
	    local w,h = self:getSize()

	    self:setClip(x,y,w,h)

	    __protected__.update(self)
    end,

    setParent = function(self, parent)
	    super.setParent(self, parent)
	    local x,y = self:getUnalignPos()
        local w,h = self:getSize()
	    self:setClip(x,y,w,h)
    end,

    dtor = function (self)
        __private__.isDestroying = true 

        __private__.releaseScrollBar(self)
        delete(__private__.contentNode)
    end 



})


M.Direction = Enum({
    VERTICAL = 2, 
    HORIZONTAL = 1
})

return M