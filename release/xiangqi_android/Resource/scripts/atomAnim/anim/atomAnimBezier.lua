require("core/object")
require("core/drawing")
require("atomAnim/drawingEx")
---------------------------------------AtomAnimBezier -----------------------------------------

AtomAnimBezier = class(AtomAnimBase)

AtomAnimBezier.ctor = function(self, node, sequence, animType, duration, delay, startValueX, endValueX, startValueY, endValueY, controlValueX, controlValueY)
    self.m_startValueX    = startValueX or 0;
    self.m_endValueX      = endValueX or 0;
    self.m_startValueY    = startValueY or 0;
    self.m_endValueY      = endValueY or 0;
    self.m_controlValueX  = controlValueX or 0;
    self.m_controlValueY  = controlValueY or 0;
    self.m_typeName = "AtomAnimBezier";
end

AtomAnimBezier.dtor = function(self)
end

AtomAnimBezier.addPropEase = function(self)
    local param = {
        self.m_sequence,
        self.m_animType, 
        self.m_duration,
        self.m_delay,
        self.m_startValueX,
        self.m_endValueX,
        self.m_startValueY,
        self.m_endValueY,
        self.m_controlValueX,
        self.m_controlValueY
    }
    local anim, anim2= self.m_node:addAtomPropTranslateCurve(unpack(param));
    anim:setDebugName("AtomAnimBezier");
    return {anim, anim2};
end

---------------------------------------AtomAnimBezierX-----------------------------------------

AtomAnimBezierX = class(AtomAnimBase)

AtomAnimBezierX.ctor = function(self, node, sequence, animType, duration, delay, startValue, endValue, controlValue)
    self.m_startValue = startValue
    self.m_endValue = endValue
    self.m_controlValue = controlValue
end

AtomAnimBezierX.dtor = function(self)
end

AtomAnimBezierX.addPropEase = function(self)
    local param = {
        self.m_sequence,
        self.m_animType, 
        self.m_duration,
        self.m_delay,
        self.m_startValue,
        self.m_endValue,
        nil,
        nil,
        self.m_controlValue
    }
    local anim = self.m_node:addAtomPropTranslateCurve(unpack(param));
    anim:setDebugName("AtomAnimBezierX");
    return {anim};
end
---------------------------------------AtomAnimBezierY-----------------------------------------

AtomAnimBezierY = class(AtomAnimBase)

AtomAnimBezierY.ctor = function(self, node, sequence, animType, duration, delay, startValue, endValue, controlValue)
    self.m_startValue = startValue
    self.m_endValue = endValue
    self.m_flag = flag
    self.m_controlValue = controlValue
end

AtomAnimBezierY.dtor = function(self)
end

AtomAnimBezierY.addPropEase = function(self)
    local param = {
        self.m_sequence,
        self.m_animType, 
        self.m_duration,
        self.m_delay,
        nil,
        nil,
        self.m_startValue,
        self.m_endValue,
        nil,
        self.m_controlValue
    }
    local _,anim = self.m_node:addAtomPropTranslateCurve(unpack(param));
    anim:setDebugName("AtomAnimBezierY");
    return {anim};
end

