require("core/object")
require("core/drawing")
require("atomAnim/drawingEx")
require("atomAnim/anim/atomAnimSolid")
require("atomAnim/anim/atomAnimBase")

---------------------------------------AtomAnimAlpha-----------------------------------------

AtomAnimAlpha = class(AtomAnimBase)

AtomAnimAlpha.ctor = function(self, node, sequence, animType, duration, delay, startValue, endValue, easeType, period)
    self.m_startValue = startValue or 1;
    self.m_endValue = endValue or 1;
    self.m_easeType = easeType;
    self.m_period = period;
    
    self.m_typeName = "AtomAnimAlpha";
    self.m_keyStartTime = delay;
    if self.m_node ~= nil then
        --self.m_node.tmp_atom_alpha = AtomAnimBase.createTimeMap(self, delay,duration,self.m_node.tmp_atom_alpha);
    end
end


AtomAnimAlpha.dtor = function(self)
end

AtomAnimAlpha.addPropEase = function(self)
    local param = {
        self.m_sequence,
        self.m_animType,
        self.m_easeType, 
        self.m_duration,
        self.m_delay,
        self.m_startValue,
        self.m_endValue,
        self.m_period
    };
    local anim = self.m_node:addAtomPropTransparencyEase(unpack(param))
    anim:setDebugName("AtomAnimAlpha");
    return {anim};
end

AtomAnimAlpha.startCallBack = function(self)
    AtomAnimBase.startCallBack(self);
   if self.m_node ~= nil then
        --AtomAnimBase.stopAnimByTimeMap(self, self.m_node.tmp_atom_alpha);
    end
end
---------------------------------------AtomAnimAlphaSolid-----------------------------------------

AtomAnimAlphaSolid = class(AtomAnimSolid)

AtomAnimAlphaSolid.ctor = function(self, node, delay, transparency)
    self.m_transparency = transparency;
end

AtomAnimAlphaSolid.dtor = function(self)
end

AtomAnimAlphaSolid.callBackHandler = function(self)
   self.m_node:setTransparency(self.m_transparency)
end