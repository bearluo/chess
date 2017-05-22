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
-- `Frost`提供了冰冻效果的实现。通过调用 `frost.applyToDrawing()` 等函数，将冰冻效果应用到一个drawing对象上。
-- 
--
-- <p>
-- <table align="center" style="border-spacing: 20px 5px; border-collapse: separate">
-- <tr>
--     <td align="center" style="border-style: none;">应用效果前</td>
--     <td align="center" style="border-style: none;">应用效果后</td></tr>
-- <tr>
-- <td><img src="shaders/default.png"></td>
-- <td><img src="shaders/frost.png"></td>
-- </tr>
-- </table>
-- </p>
--
--
--
-- @module Frost 
-- @author Heng Li
--
-- @usage local Frost = require 'libEffect.shaders.frost'

local GC = require ("libEffect.util.gc")
local ShaderInfo = require("libEffect.shaders.internal.shaderInfo")
local Common = require("libEffect.shaders.common")

local screenWidth = sys_get_int("screen_width", -1)
local screenHeight = sys_get_int("screen_height", -1)

local frost = {}

local effectName = 'frost'



---
-- 返回 offset 属性的取值范围。
-- @return #number, #number 最小值, 最大值
frost.getOffsetRange = function ()
    return 0, 1
end



--- 
-- 对drawing应用冰冻效果。
--
-- @param core.drawing#DrawingImage drawing 要应用到的对象。若不是DrawingImage，则error()。
-- @param #number offset 决定冰冻效果噪点的大小。范围：0 <= offset <= 1.0, 随着0到1.0的增加冰冻的效果越明显。若offset == nil，则默认为1。若offset超出范围，则error()。
frost.applyToDrawing = function (drawing, offset) 

    if not typeof(drawing, DrawingImage) then 
        error("The type of `drawing' should be DrawingImage.")
    end 

    if offset == nil then 
        offset = 1
    end 

    if (offset < 0) or (offset > 1) then
        error("The value of `offset' should be in range 0..1")
    end

    Common.removeEffect(drawing)     

    
    
    local frostTexId = res_alloc_id()
    local offsetId = res_alloc_id()
    local screenSizeId = res_alloc_id()

    res_create_double_array(0, offsetId, {offset} )
    res_create_double_array(0,screenSizeId,{screenWidth,screenHeight})

    res_create_image(0, frostTexId, "libEffect/shaders/ice.jpg", 0,0)

    drawing_set_program(drawing.m_drawingID, "frostShader", 4)
    drawing_set_program_data( drawing.m_drawingID, "offset", offsetId)
    drawing_set_program_data( drawing.m_drawingID, "screenSize", screenSizeId)
    drawing_set_program_data( drawing.m_drawingID, "texture1", frostTexId)

    local shaderInfo = ShaderInfo.setShaderInfo(drawing, effectName, {offset = offset, offsetId = offsetId, screenSizeId = screenSizeId, screenSize = {screenWidth, screenHeight}})
    GC.setFinalizer(shaderInfo, function ()
        res_delete(offsetId)
        res_free_id(offsetId)
        res_delete(frostTexId)
        res_free_id(frostTexId)
        res_delete(screenSizeId)
        res_free_id(screenSizeId)
    end )
end

---
-- 设置冰冻效果的Offset属性。
--
-- @param core.drawing#DrawingImage drawing 应用了冰冻效果的drawing对象。如果`drawing'为nil，或者当前特效不是冰冻效果，则什么都不做。
-- @param #number offset 决定冰冻效果噪点的大小。范围：0 =< offset =< 1.0 。若offset超出范围，则error()。
frost.setOffset = function (drawing, offset)
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then
        if (offset < 0) or (offset > 1) then
            error("The value of `offset' should be in range 0..1")
        end

        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
     	res_set_double_array(shaderInfo.offsetId, {offset})
        drawing_set_program_data(drawing.m_drawingID, "offset", shaderInfo.offsetId)	
	end
end

---
-- 获得当前应用到drawing的冰冻效果的位置。
--
-- @param core.drawing#DrawingImage drawing 应用了frost效果的对象。
-- @return #number 决定冰冻效果噪点的大小。范围：0 =< offset =< 1 
-- @return #nil 如果drawing为nil，或者没有frost效果，则什么都不做，返回nil。
frost.getOffset = function (drawing)
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        return shaderInfo.offset
	else
	    return nil
	end
end
return frost