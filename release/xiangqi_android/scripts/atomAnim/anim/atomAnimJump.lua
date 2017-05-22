require("core/object")
require("core/drawing")
require("atomAnim/drawingEx")
require("atomAnim/anim/atomAnimSolid")
require("atomAnim/anim/atomAnimBase")

---------------------------------------AtomAnimJump-----------------------------------------

AtomAnimJump = class(AtomAnimBase)

AtomAnimJump.ctor = function(self, node, sequence, animType, duration, delay, startValueX, endValueX, startValueY, endValueY, timesX, timesY, jumpX, jumpY)
    self.m_startValueX = startValueX or 0;
    self.m_endValueX = endValueX or 0;
    self.m_startValueY = startValueY or 0;
    self.m_endValueY = endValueY or 0;
    self.m_timesX = timesX;
    self.m_timesY = timesY;
    self.m_jumpX = jumpX;
    self.m_jumpY = jumpY;

    self.m_typeName = "AtomAnimJump";
end

AtomAnimJump.dtor = function(self)
end

AtomAnimJump.addPropEase = function(self)
    local param = {
        self.m_sequence,
        self.m_animType, 
        self.m_duration,
        self.m_delay,
        self.m_startValueX,
        self.m_endValueX,
        self.m_startValueY,
        self.m_endValueY,
        self.m_timesX,
        self.m_timesY,
        self.m_jumpX,
        self.m_jumpY
    }
    local anim, anim2 = self.m_node:addAtomPropTranslateJump(unpack(param));
    anim:setDebugName("AtomAnimJump");
    return {anim, anim2};
end