require("core/object")
require("core/drawing")
require("atomAnim/drawingEx")
require("atomAnim/anim/atomAnimSolid")
require("atomAnim/anim/atomAnimBase")

---------------------------------------AtomAnimFrame-----------------------------------------

AtomAnimFrame = class(AtomAnimBase)

AtomAnimFrame.ctor = function(self, node, sequence, animType, duration, delay, number, easeType, period)
    self.m_number = number
    self.m_easeType = easeType
    self.m_period = period

    self.m_typeName = "AtomAnimFrame";
end


AtomAnimFrame.addPropEase = function(self)
    local start = 0
    self.m_node:setImageIndex(start)
    local anim = new(AnimInt, self.m_animType, start, self.m_number - 1, self.m_duration, self.m_delay)
    anim:setDebugName("AtomAnimFrame")
    self.m_prop = new(PropImageIndex, anim)
    self.m_node:addProp(self.m_prop, self.m_sequence);
    return {anim};
end

AtomAnimFrame.stop = function(self)
    if self.m_anim then
        for i = 1, #self.m_anim do
            delete(self.m_anim[i]);
        end
        self.m_anim = nil;
    end
    if self.m_prop then
        self.m_node:removePropByID(self.m_prop.m_propID)
        delete(self.m_prop)
        self.m_prop = nil
    end
    if self.m_startCallBack ~= nil then
        self.m_startCallBack:dtor();
        self.m_startCallBack = nil;
    end
    self.m_isPlaying = false  
end


AtomAnimFrame.dtor = function(self)
end

---------------------------------------AtomAnimFrameSolid-----------------------------------------

AtomAnimFrameSolid = class(AtomAnimSolid)

AtomAnimFrameSolid.ctor = function(self, node, delay, iterator)
    self.m_iterator = iterator
end

AtomAnimFrameSolid.dtor = function(self)
end

AtomAnimFrameSolid.callBackHandler = function(self)
    self.m_node:setImageIndex(self.m_iterator)
end