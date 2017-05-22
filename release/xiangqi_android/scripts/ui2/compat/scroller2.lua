--
-- UI2 Library, Version: 1.0 Alpha (0.99.2.2058-SNAPSHOT)
-- 
-- This file is a part of UI2 Library.
--
-- Author:
-- Xiaofeng Yang     2015
-- Vicent Gong       2012
--
--

--- 
--
-- @module scroller2

require("core/constants");
require("core/object");
require("core/global");
require("core/anim");

local DSM2 = require("ui2.compat.internal.DoubleScrollingModel2")

Scroller2 = class();

local stopModelSilently = function (self)
    if self.scrollingModel then 
        self.scrollingModel.setOnStop(function () end);
        self.scrollingModel.forceStop();
    end
end

local resetModel = function (self)

    -- stop origin model
    stopModelSilently(self);

    -- recreate a new model
    self.scrollingModel = DSM2.create(self.m_viewLength, self.m_frameLength, function (offset) 
        self.m_offset = offset;
        self.m_eventCallback(offset);
    end)

    self.scrollingModel.setOnStop(function ()
        self.m_onScrollEnd();           
    end)

    self.scrollingModel.setOnBeginBouncing(function (direction)
        self.m_onScrollBouncing(direction);           
    end)

    self.scrollingModel.setContentPosition(self.m_offset);
end

Scroller2.ctor = function(self, direction, frameLength, viewLength)
    -- viewLength: 内容长度
    -- frameLength: 框的长度

    self.m_frameLength = frameLength or 1;
    self.m_viewLength = viewLength or 1;
    self.m_direction = direction or kVertical;

    self.m_offset = 0;

    self.m_onScrollEnd = function () end
    self.m_onScrollBouncing = function () end
    self.m_eventCallback = function () end 

    resetModel(self);
end

-- 原来的是只能在初始化的时候调用，现在的是只能在静止的时候调用。
-- 注：会调用scrollCallback，还可能会触发回弹。
Scroller2.setOffset = function(self, offset)
    if self.scrollingModel.setContentPosition(offset) then 
        self.m_offset = offset;
    end    
end

-- 原来的是只能在初始化的时候调用，现在的是只能在静止的时候调用。
Scroller2.setFrameLength = function(self, frameLength)
    self.m_frameLength = frameLength;
    resetModel(self);
end

-- 只能在初始化的时候调用。
Scroller2.setViewLength = function(self, viewLength)
    self.m_viewLength = viewLength;
    self.scrollingModel.setContentSize(viewLength)
end

Scroller2.setScrollCallback = function(self, obj, func)
    if func then 
        self.m_eventCallback = function (offset)
            func(obj, offset)
        end    
    else 
        self.m_eventCallback = function () end 
    end 
end

Scroller2.stop = function(self)
    self.scrollingModel.forceStop();
end

-- 注意事项同Scroller2.setOffset。
Scroller2.scrollToTop = function(self)
    self:setOffset(0);
end

-- 注意事项同Scroller2.setOffset。
Scroller2.scrollToBottom = function(self)
    local offset = self.m_frameLength - self.m_viewLength;
    self:setOffset(offset);
end

Scroller2.dtor = function(self)
    stopModelSilently(self)
end


Scroller2.onEventTouch = function(self, finger_action, x, y, drawing_id_first, drawing_id_current, event_time)
    local curPos = (self.m_direction == kVertical) and y or x;

    if finger_action == kFingerDown then 
        self.scrollingModel.handlePressLogic(curPos, event_time)
    elseif finger_action == kFingerMove then 
        self.scrollingModel.handleMoveLogic(curPos, event_time)
    elseif (finger_action == kFingerUp) or (finger_action == kFingerCancel) then 
        self.scrollingModel.handleReleaseLogic(curPos, event_time)
    end 

end

Scroller2.setOnScrollEnd = function (self, obj, fn)
    if fn then 
        self.m_onScrollEnd = function () 
            fn(obj);
        end
    else
        self.m_onScrollEnd = function () end
    end 
end

Scroller2.setOnScrollBouncing = function (self ,obj, fn)
    if fn then 
        self.m_onScrollBouncing = function (direction) 
            fn(obj,direction);
        end
    else
        self.m_onScrollBouncing = function () end
    end 
end
