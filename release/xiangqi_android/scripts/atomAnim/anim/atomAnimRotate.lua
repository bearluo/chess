require("core/object")
require("core/drawing")
require("atomAnim/drawingEx")
require("atomAnim/anim/atomAnimSolid")
require("atomAnim/anim/atomAnimBase")

---------------------------------------AtomAnimRotate-----------------------------------------

AtomAnimRotate = class(AtomAnimBase);

AtomAnimRotate.ctor = function(self, node, sequence, animType, duration, delay, startValue, endValue, centerType, centerX, centerY, easeType, period)
    self.m_startValue = startValue;
    self.m_endValue = endValue;
    self.m_easeType = easeType;
    self.m_period = period;
    self.m_centerType = centerType;
    self.m_centerX = centerX;
    self.m_centerY = centerY;

    self.m_typeName = "AtomAnimRotate";
end

AtomAnimRotate.dtor = function(self)
end

AtomAnimRotate.addPropEase = function(self)
    local param = {
        self.m_sequence,
        self.m_animType,
        self.m_easeType,
        self.m_duration,
        self.m_delay,
        self.m_startValue,
        self.m_endValue,
        self.m_centerType,
        self.m_centerX,
        self.m_centerY,
        self.m_period
    }
    local anim, anim2 = self.m_node:addAtomPropRotateEase(unpack(param));
    anim:setDebugName("AtomAnimRotate");
    return {anim, anim2};
end



---------------------------------------AtomAnimRotateSolid-----------------------------------------

AtomAnimRotateSolid = class(AtomAnimIncSolid)

AtomAnimRotateSolid.ctor = function(self, node, delay, sequence, angle, centerType, centerX, centerY)
    self.m_angle = angle;
    self.m_centerType = centerType;
    self.m_centerX = centerX;
    self.m_centerY = centerY;
end

AtomAnimRotateSolid.dtor = function(self)
end

AtomAnimRotateSolid.callBackHandler = function(self)
    self.m_node:addPropRotateSolid(self.m_sequence, self.m_angle, self.m_centerType, self.m_centerX, self.m_centerY)
end