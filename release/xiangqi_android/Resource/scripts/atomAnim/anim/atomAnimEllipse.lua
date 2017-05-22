require("core/object")
require("core/drawing")
require("atomAnim/drawingEx")
require("atomAnim/anim/atomAnimBase")


---------------------------------------AtomAnimEllipse-----------------------------------------

AtomAnimEllipse = class(AtomAnimBase)

AtomAnimEllipse.ctor = function(self, node, sequence, animType, duration, delay, centerX, centerY, axisX, axisY, startAngle, endAngle)
    self.m_centerX = centerX or 0;
    self.m_centerY = centerY or 0;
    self.m_axisX = axisX or 0;
    self.m_axisY = axisY or 0;
    self.m_startAngle = startAngle or 0;
    self.m_endAngle = endAngle or 0;

    self.m_typeName = "AtomAnimEllipse";
end

AtomAnimEllipse.dtor = function(self)
end

AtomAnimEllipse.addPropEase = function(self)
    local param = {
        self.m_sequence,
        self.m_animType, 
        self.m_duration,
        self.m_delay,
        self.m_centerX,
        self.m_centerY,
        self.m_axisX,
        self.m_axisY,
        self.m_startAngle,
        self.m_startAngle,
        self.m_endAngle,
        self.m_endAngle
    }
    local anim, anim2 = self.m_node:addAtomPropTranslateEllipse(unpack(param))
    anim:setDebugName("AtomAnimEllipse");
    return {anim, anim2};
end
---------------------------------------AtomAnimEllipseX-----------------------------------------

AtomAnimEllipseX = class(AtomAnimBase)

AtomAnimEllipseX.ctor = function(self, node, sequence, animType, duration, delay, center, axis, startAngle, endAngle)
    self.m_center = center or 0;
    self.m_axis = axis or 0;
    self.m_startAngle = startAngle or 0;
    self.m_endAngle = endAngle or 0;
end

AtomAnimEllipseX.dtor = function(self)
end

AtomAnimEllipseX.addPropEase = function(self)
    local param = {
        self.m_sequence,
        self.m_animType, 
        self.m_duration,
        self.m_delay,
        self.m_center,
        nil,
        self.m_axis,
        nil,
        self.m_startAngle,
        nil,
        self.m_endAngle
    }
    local anim = self.m_node:addAtomPropTranslateEllipse(unpack(param));
    anim:setDebugName("AtomAnimEllipseX");
    return anim;
end
---------------------------------------AtomAnimEllipseY-----------------------------------------

AtomAnimEllipseY = class(AtomAnimBase)

AtomAnimEllipseY.ctor = function(self, node, sequence, animType, duration, delay, center, axis, startAngle, endAngle)
    self.m_center = center or 0;
    self.m_axis = axis or 0;
    self.m_startAngle   = startAngle or 0;
    self.m_endAngle     = endAngle or 0;
end

AtomAnimEllipseY.dtor = function(self)
end

AtomAnimEllipseY.addPropEase = function(self)
    local param = {
        self.m_sequence,
        self.m_animType, 
        self.m_duration,
        self.m_delay,
        nil,
        self.m_center,
        nil,
        self.m_axis,
        nil,
        self.m_startAngle,
        nil,
        self.m_endAngle
    }
    local _,anim = self.m_node:addAtomPropTranslateEllipse(unpack(param));
    anim:setDebugName("AtomAnimEllipseY");
    return anim;
end