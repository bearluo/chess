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
-- `Mirror`提供了水平镜像效果的实现。通过调用 `Mirror.applyToDrawing()` 等函数，将镜像效果应用到一个drawing对象上。
--
-- 
--
-- <p>
-- <table align="center" style="border-spacing: 20px 5px; border-collapse: separate">
-- <tr>
--     <td align="center" style="border-style: none;">应用效果前</td>
--     <td align="center" style="border-style: none;">应用效果后</td></tr>
-- <tr>
-- <td><img src="shaders/default.png"></td>
-- <td><img src="shaders/mirrorX.png"></td>
-- </tr>
-- </table>
-- </p>
--
--
-- @module MirrorHorizontal
-- @author Heng Li
--
-- @usage local MirrorHorizontal = require 'libEffect.shaders.mirrorHorizontal'

local GC = require ("libEffect.util.gc");
local ShaderInfo = require("libEffect.shaders.internal.shaderInfo")
local Common = require("libEffect.shaders.common")
local mirrorHorizontal = {}

local effectName = 'mirrorX'



--- 
-- 对drawing应用镜像效果（水平）。
--
-- @param core.drawing#DrawingImage drawing 要应用的对象。若不是DrawingImage，则error()。
mirrorHorizontal.applyToDrawing = function (drawing)
    
    if not typeof(drawing, DrawingImage) then 
        error("The type of `drawing' should be DrawingImage.")
    end 

    Common.removeEffect(drawing)     
    
    local sumId = res_alloc_id()
    local sum
        
    local rectX
    local rectY
    local sizeX
    local sizeY
    
    if typeof(drawing.m_res, ResImage) then 
        rectX, rectY, sizeX, sizeY = drawing.m_res:getSubTextureCoord()
    end

    if rectX and sizeX  then
        sum =(rectX * 2 + sizeX) / res_get_image_width(drawing.m_resID)
    else
        sum = 1.0
    end

    res_create_double_array(0, sumId, { sum })

    drawing_set_program(drawing.m_drawingID, "mirrorXAtlasShader", 4)
    drawing_set_program_data(drawing.m_drawingID, "sum", sumId)

    local shaderInfo = ShaderInfo.setShaderInfo(drawing, "mirrorX")
    GC.setFinalizer(shaderInfo, function ()
        res_delete(sumId)
        res_free_id(sumId)
    end)
end

return mirrorHorizontal
