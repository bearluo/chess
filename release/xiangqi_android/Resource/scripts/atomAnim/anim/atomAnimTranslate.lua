require("core/object")
require("core/drawing")
require("atomAnim/drawingEx")
require("atomAnim/anim/atomAnimSolid")
require("atomAnim/anim/atomAnimBase")

---------------------------------------AtomAnimTranslate-----------------------------------------

AtomAnimTranslate = class(AtomAnimBase)

AtomAnimTranslate.ctor = function(self, node, sequence, animType, duration, delay, startValueX, endValueX, startValueY, endValueY, easeType, period)
    self.m_startValueX  = startValueX   or 0;
    self.m_endValueX    = endValueX     or 0;
    self.m_startValueY  = startValueY   or 0;
    self.m_endValueY    = endValueY     or 0;
    self.m_easeType     = easeType;
    self.m_period       = period; 

    self.m_typeName = "AtomAnimTranslate";
end

AtomAnimTranslate.addPropEase = function(self)
    local param = {
        self.m_sequence,
        self.m_animType,
        self.m_easeType, 
        self.m_duration,
        self.m_delay,
        self.m_startValueX,
        self.m_endValueX,
        self.m_startValueY,
        self.m_endValueY,
        self.m_period
    }
    local anim, anim2 = self.m_node:addAtomPropTranslateEase(unpack(param));
    anim:setDebugName("AtomAnimTranslate");
    return {anim, anim2};
end


---------------------------------------AtomAnimTranslateX-----------------------------------------

AtomAnimTranslateX = class(AtomAnimBase)

AtomAnimTranslateX.ctor = function(self, node, sequence, animType, duration, delay, startValue, endValue, easeType, period)
    self.m_startValue = startValue;
    self.m_endValue = endValue;
    self.m_easeType = easeType;
    self.m_period = period;
end

AtomAnimTranslateX.addPropEase = function(self)
    local param = {
        self.m_sequence,
        self.m_animType,
        self.m_easeType, 
        self.m_duration,
        self.m_delay,
        self.m_startValue,
        self.m_endValue,
        nil,
        nil,
        self.m_period
    }
    local anim = self.m_node:addAtomPropTranslateEase(unpack(param));
    anim:setDebugName("AtomAnimTranslateX");
    return {anim};
end

---------------------------------------AtomAnimTranslateY-----------------------------------------

AtomAnimTranslateY = class(AtomAnimBase)

AtomAnimTranslateY.ctor = function(self, node, sequence, animType, duration, delay, startValue, endValue, easeType, period)
    self.m_startValue = startValue;
    self.m_endValue = endValue;
    self.m_easeType = easeType;
    self.m_period = period;
end

AtomAnimTranslateY.addPropEase = function(self)
    local param = {
        self.m_sequence,
        self.m_animType,
        self.m_easeType, 
        self.m_duration,
        self.m_delay,
        nil,
        nil,
        self.m_startValue,
        self.m_endValue,
        nil,
        self.m_period
    }
    local _,anim = self.m_node:addAtomPropTranslateEase(unpack(param));
    anim:setDebugName("AtomAnimTranslateY");
    return {anim};
end


---------------------------------------AtomAnimTranslateSolid-----------------------------------------

AtomAnimTranslateSolid = class(AtomAnimIncSolid)    --不会改变起始值

AtomAnimTranslateSolid.ctor = function(self, node, delay, sequence, x, y)
    self.m_x = x
    self.m_y = y
end

AtomAnimTranslateSolid.dtor = function(self)
end

AtomAnimTranslateSolid.callBackHandler = function(self)
    self.m_node:addPropTranslateSolid(self.m_sequence, self.m_x, self.m_y);
end