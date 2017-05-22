require("core/object")
require("core/drawing")
require("atomAnim/drawingEx")
require("atomAnim/anim/atomAnimSolid")
require("atomAnim/anim/atomAnimBase")
---------------------------------------AtomAnimScale-----------------------------------------

AtomAnimScale = class(AtomAnimBase)

AtomAnimScale.ctor = function(self, node, sequence, animType, duration, delay, startValueX, endValueX, startValueY, endValueY,centerType, centerX, centerY, easeType, period)
    self.m_startValueX      = startValueX;
    self.m_endValueX        = endValueX;
    self.m_startValueY      = startValueY;
    self.m_endValueY        = endValueY;
    self.m_easeType         = easeType;
    self.m_period           = period;
    self.m_flag             = flag;
    self.m_centerType       = centerType;
    self.m_centerX          = centerX;
    self.m_centerY          = centerY;

    self.m_typeName = "AtomAnimScale";
    if self.m_node ~= nil then
        --self.m_node.tmp_atom_scale = AtomAnimBase.createTimeMap(self, delay, duration, self.m_node.tmp_atom_scale);
    end
end


AtomAnimScale.dtor = function(self)
end


AtomAnimScale.addPropEase = function(self)
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
            self.m_centerType,
            self.m_centerX,
            self.m_centerY,
            self.m_period,
            self.m_period,
    }
    local anim, anim2 = self.m_node:addAtomPropScaleEase(unpack(param));
    anim:setDebugName("AtomAnimScale");
    return {anim, anim2};
end

AtomAnimScale.startCallBack = function(self)
    AtomAnimBase.startCallBack(self);
    if self.m_node ~= nil then
        --AtomAnimBase.stopAnimByTimeMap(self, self.m_node.tmp_atom_scale);
    end
end

---------------------------------------AtomAnimScaleX-----------------------------------------

AtomAnimScaleX = class(AtomAnimBase)

AtomAnimScaleX.ctor = function(self, node, sequence, animType, duration, delay, startValue, endValue, centerType, centerX, centerY, easeType, period)
    self.m_startValue = startValue
    self.m_endValue = endValue
    self.m_easeType = easeType
    self.m_period = period
    self.m_flag = flag
    self.m_centerType = centerType
    self.m_centerX = centerX
end

AtomAnimScaleX.dtor = function(self)
end

AtomAnimScaleX.addPropEase = function(self)
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
         self.m_centerType,
         self.m_centerX,
         nil ,
         self.m_period,
         nil
    }
    local anim = self.m_node:addAtomPropScaleEase(unpack(param));
    anim:setDebugName("AtomAnimScaleX");
    return {anim};
end

---------------------------------------AtomAnimScaleY-----------------------------------------

AtomAnimScaleY = class(AtomAnimBase)

AtomAnimScaleY.ctor = function(self, node, sequence, animType, duration, delay, startValue, endValue, centerType, centerX, centerY, easeType, period)
    self.m_startValue = startValue
    self.m_endValue = endValue
    self.m_easeType = easeType
    self.m_period = period
    self.m_flag = flag
    self.m_centerType = centerType
    self.m_centerY = centerY
end

AtomAnimScaleY.dtor = function(self)
end

AtomAnimScaleY.addPropEase = function(self)
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
        self.m_centerType,
        nil,
        self.m_centerY,
        nil,
        self.m_period
    }
    local _,anim = self.m_node:addAtomPropScaleEase(unpack(param));
    anim:setDebugName("AtomAnimScaleY");
    return {anim};
end

---------------------------------------AtomAnimScaleSolid-----------------------------------------

AtomAnimScaleSolid = class(AtomAnimIncSolid)

AtomAnimScaleSolid.ctor = function(self, node, delay, sequence, scaleX, scaleY, centerType, centerX, centerY)
    self.m_scaleX = scaleX
    self.m_scaleY = scaleY
    self.m_centerType = centerType
    self.m_centerX = centerX
    self.m_centerY = centerY
end

AtomAnimScaleSolid.dtor = function(self)
end


AtomAnimScaleSolid.callBackHandler = function(self)
    local param = {
        self.m_sequence,
        self.m_scaleX,
        self.m_scaleY,
        self.m_centerType,
        self.m_centerX,
        self.m_centerY
    };
    self.m_node:addPropScaleSolid(unpack(param));
end