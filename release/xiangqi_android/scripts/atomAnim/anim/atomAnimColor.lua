require("core/object")
require("core/drawing")
require("atomAnim/drawingEx")
require("atomAnim/anim/atomAnimSolid")
require("atomAnim/anim/atomAnimBase")

---------------------------------------AtomAnimRed-----------------------------------------

AtomAnimColor = class(AtomAnimBase)

AtomAnimColor.ctor = function(self, node, sequence, animType, duration, delay, startValueRed, endValueRed, startValueGreen, endValueGreen, startValueBlue, endValueBlue, easeType, period)
    self.m_startValueRed    = (startValueRed or 255) * 1.0 / 255;
    self.m_startValueGreen  = (startValueGreen or 255) * 1.0 / 255;
    self.m_startValueBlue   = (startValueBlue or 255) * 1.0 / 255;
    
    self.m_endValueRed      = (endValueRed or 255) * 1.0 / 255;
    self.m_endValueGreen = (endValueGreen or 255) * 1.0 / 255;
    self.m_endValueBlue     = (endValueBlue or 255) * 1.0 / 255;

    self.m_easeType         = easeType;
    self.m_period           = period;

    self.m_typeName = "AtomAnimColor";
    if self.m_node ~= nil then
        --self.m_node.tmp_atom_color = AtomAnimBase.createTimeMap(self, delay,duration,self.m_node.tmp_atom_color);
    end
end

AtomAnimColor.dtor = function(self)
end

AtomAnimColor.addPropEase = function(self)
    local param = {
            self.m_sequence,
            self.m_animType,
            self.m_easeType, 
            self.m_duration,
            self.m_delay,
            self.m_startValueRed,
            self.m_endValueRed,
            self.m_startValueGreen,
            self.m_endValueGreen,
            self.m_startValueBlue,
            self.m_endValueBlue,
            self.m_period
        }
    local anim,anim2,anim3 = self.m_node:addAtomPropColorEase(unpack(param));
    anim:setDebugName("AtomAnimColor");
    return {anim,anim2,anim3};
end

AtomAnimColor.startCallBack = function(self)
    AtomAnimBase.startCallBack(self);
   if self.m_node ~= nil then
        --AtomAnimBase.stopAnimByTimeMap(self, self.m_node.tmp_atom_color);
    end
end

---------------------------------------AtomAnimRed-----------------------------------------

AtomAnimRed = class(AtomAnimBase)

AtomAnimRed.ctor = function(self, node, sequence, animType, duration, delay, startValue, endValue, easeType, period)
    self.m_startValue = (startValue or 255) * 1.0 / 255;
    self.m_endValue = (endValue or 255) * 1.0 / 255;
    self.m_easeType = easeType;
    self.m_period = period;
end

AtomAnimRed.dtor = function(self)
end

AtomAnimRed.addPropEase = function(self)
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
        nil,
        nil,
        self.m_period
    }

    local anim,_,_ = self.m_node:addAtomPropColorEase(unpack(param));
    anim:setDebugName("AtomAnimRed");
    return {anim};
end

---------------------------------------AtomAnimGreen-----------------------------------------

AtomAnimGreen = class(AtomAnimBase)

AtomAnimGreen.ctor = function(self, node, sequence, animType, duration, delay, startValue, endValue, easeType, period)
    self.m_startValue = startValue * 1.0 / 255;
    self.m_endValue = endValue * 1.0 / 255;
    self.m_easeType = easeType;
    self.m_period = period;
end

AtomAnimGreen.dtor = function(self)
end

AtomAnimGreen.addPropEase = function(self)
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
        nil,
        nil,
        self.m_period
    }
    local _, anim ,_= self.m_node:addAtomPropColorEase(unpack(param));
    anim:setDebugName("AtomAnimGreen");
    return {anim};
end

---------------------------------------AtomAnimBlue-----------------------------------------

AtomAnimBlue = class(AtomAnimBase)

AtomAnimBlue.ctor = function(self, node, sequence, animType, duration, delay, startValue, endValue, easeType, period)
    self.m_startValue = startValue * 1.0 / 255;
    self.m_endValue = endValue * 1.0 / 255;
    self.m_easeType = easeType;
    self.m_period = period;
end

AtomAnimBlue.dtor = function(self)
end

AtomAnimBlue.addPropEase = function(self)
    local param = {
        self.m_sequence,
        self.m_animType,
        self.m_easeType, 
        self.m_duration,
        self.m_delay,
        nil,
        nil,
        nil,
        nil,
        self.m_startValue,
        self.m_endValue,
        nil,
        nil,
        self.m_period
    }
    local _,_,anim = self.m_node:addAtomPropColorEase(unpack(param));
    anim:setDebugName("AtomAnimBlue");
    return {anim};
end

---------------------------------------AtomAnimColorSolid-----------------------------------------

AtomAnimColorSolid = class(AtomAnimSolid)

AtomAnimColorSolid.ctor = function(self, node, delay, r, g, b) 
    self.m_r = r;
    self.m_g = g;
    self.m_b = b;
end

AtomAnimColorSolid.dtor = function(self)
end

AtomAnimColorSolid.callBackHandler = function(self)
    self.m_node:setColor(self.m_r, self.m_g, self.m_b) 
end