require("core/object")
require("core/drawing")
require("atomAnim/drawingEx")
require("atomAnim/anim/atomAnimSolid")
require("atomAnim/anim/atomAnimBase")
--region atomAnimPos.lua
--Author : KimWang
--Date   : 2015/3/16
--此文件由[BabeLua]插件自动生成
AtomAnimPosSolid = class(AtomAnimSolid)    --会改变起始值

AtomAnimPosSolid.ctor = function(self, node, delay, x, y)
    self.m_x = x
    self.m_y = y
end

AtomAnimPosSolid.dtor = function(self)
end

AtomAnimPosSolid.callBackHandler = function(self)
    self.m_node:setPos(self.m_sequence, self.m_x, self.m_y);
end
--endregion
