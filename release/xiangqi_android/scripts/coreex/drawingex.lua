require("core/drawing");
DrawingBase.setDebugNameByPropAndAnim = function(self, sequence , name)
	name = name or "";
	if self.m_props[sequence] then
		local prop = self.m_props[sequence]["prop"];
		if prop then
			prop:setDebugName(name);
			for _,v in pairs(self.m_props[sequence]["anim"]) do 
				if v then
					v:setDebugName(name);
				end
			end
		end
	end
end

--[[
	获取控件的对齐方式
	@修改：王金鹏
	@时间：2014-11-5
]]
DrawingBase.getAlign = function(self)
	-- body
	return self.m_align or kAlignTopLeft;
end

-------------Blend---------------------------
DrawingBase.setBlend = function (self, blendSrc, blendDst)
	drawing_set_blend_mode (self.m_drawingID, blendSrc, blendDst);
end