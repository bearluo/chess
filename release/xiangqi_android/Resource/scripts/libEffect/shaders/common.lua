--
-- libEffect Version: @@Version@@
-- 
-- This file is a part of libEffect Library.
--
-- Authors:
-- Xiaofeng Yang     
-- Heng Li           
--

---
-- 提供了一组用于特效的通用函数。
--
-- @module Common
-- @author Xiaofeng Yang
--
-- @usage local Common = require 'libEffect.shaders.common'

local ShaderInfo = require('libEffect.shaders.internal.shaderInfo')


local common = {}

--- 判断drawing是否使用了特效，如果drawing使用了特效的话，返回ture，否则返回false。
-- @param core.drawing#DrawingImage drawing 应用了特效了drawing对象。
-- @return #boolean 如果drawing使用了特效的话，返回ture；否则，返回false。
common.hasEffect = function (drawing)
    if ShaderInfo.getShaderInfo(drawing) then
        return true
    else
        return false
    end
end


--- 移除drawing的特效。若无法获得特效信息，则什么都不做。
-- @param core.drawing#DrawingImage drawing 应用了特效了drawing对象。
common.removeEffect = function (drawing)
    if not common.hasEffect(drawing) then 
        return 
    end 
    
    local shaderInfo = ShaderInfo.getShaderInfo(drawing)

    if type(shaderInfo['__cleanup']) == 'function' then 
        shaderInfo['__cleanup']()
    end 
    
    ShaderInfo.setShaderInfo(drawing, nil)

    drawing_set_program(drawing.m_drawingID,'',0)
end

return common