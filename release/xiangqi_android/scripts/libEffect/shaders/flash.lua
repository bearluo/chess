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
-- `Flash`提供了高亮效果的实现。通过调用 `flash.applyToDrawing()` 函数，将高亮效果应用到一个drawing对象上。
--
-- 高亮效果用于在一个drawing上增加一个白色的条状物（下文简称“白条”），并通过 position 属性来指定“白条”的位置。
-- 
--
-- <p>
-- <table align="center" style="border-spacing: 20px 5px; border-collapse: separate">
-- <tr>
--     <td align="center" style="border-style: none;">应用效果前</td>
--     <td align="center" style="border-style: none;">应用效果后</td></tr>
-- <tr>
-- <td><img src="shaders/default.png"></td>
-- <td><img src="shaders/flash.png"></td>
-- </tr>
-- </table>
-- </p>
--
--
--
-- @module Flash
-- @author Heng Li
--
-- @usage local Flash = require 'libEffect.shaders.flash'

local GC = require ("libEffect.util.gc");
local ShaderInfo = require("libEffect.shaders.internal.shaderInfo")
local Common = require("libEffect.shaders.common")
local screenWidth = sys_get_int("screen_width", -1)
local screenHeight = sys_get_int("screen_height", -1)
local flash = {}

local effectName = 'flash'

---
-- 返回 position 属性的取值范围。
-- @return #number, #number 最小值, 最大值
flash.getPositionRange = function ()
    return 0, 1
end

---
-- 返回 scale 属性的取值范围。
-- @return #number, #number 最小值, 最大值
flash.getScaleRange = function ()
    return 1, 2
end


--- 
-- 对drawing应用高亮效果。
--
-- @param core.drawing#DrawingImage drawing 要应用到的对象。若不是DrawingImage，则error()。
--
-- @param #table config 一个table，用于指定所应用的特效的各种属性。若为nil，则默认为{}。
--
-- config必须具有以下几个字段。
-- 
-- config.position
-- ---------------
-- 
-- 类型：#number
--
-- 高亮效果的 **position** 属性，该属性决定了“白条”的位置。
-- 
-- 取值范围：0 <= config.position <= 1 。
--
-- _注：_
--
-- * 若 config.position == 0，则白条处于 drawing 左下端（恰好位于不可见区域），若 config.position == 1 则白条处于 drawing 右上端（恰好位于不可见区域）。
-- * 若 config.position 为 nil，则默认为 0.5。
-- * 若 config.position 超出取值范围，则 error() 。
--
--
-- config.color
-- ------------
--
-- 类型：#table 
-- 
-- 高亮效果的 **color** 属性，该属性决定了高亮的颜色。
--
-- `config.color'是一个形式为{R,G,B,A}的table，满足范围 :0 <= R，G，B，A <= 255。用于指定一个RGBA颜色值。
--
-- _注：_
--
-- * 若config.color 为 nil ，则默认为{255,255,255,255}，即白色。
-- * 若config.color 超出取值范围，则 error() 。
--
--
-- config.scale 
-- ------------
-- 
-- 类型：#number
--
-- 高亮效果的 **scale** 属性，决定光柱粗细。
--
-- 范围：1 <= scale <= 2。
-- 
-- _注：_
--
-- * 若 config.scale 为1时是标准大小，光柱粗细随着该值的增大而增大，最大为2。
-- * 若 config.scale 为 nil ，则默认为1。
-- * 若 config.scale 超出取值范围，则 error() 。
--
flash.applyToDrawing = function (drawing, config) 
    if config == nil then 
        config = {}
    end 

    local position = config.position
    local color = config.color
    local scale = config.scale

    if not typeof(drawing, DrawingImage) then 
        error("The type of `drawing' should be DrawingImage.")
    end     
        

    if color == nil then 
        color = {255,255,255,255}
    end

    if not (type(color) == 'table') then 
        error("The type of `config.color' should be a table.")
    end 
    
    if 4 ~= #color then 
        error("The length of `config.color' should be 4.")
    end 

    for _,v in ipairs(color) do
        if (v < 0 or v > 255) then
            error("The element of `config.color' should be in range 0 .. 255.")
        end     
    end


    
    if scale == nil then
        scale = 1.0
    end

    if scale < 1.0 or scale > 2.0 then
        error("The value of `config.scale' should be in range 1 .. 2")
    end



    if position == nil then 
        position = 0.5
    end 

    if (position < 0) or (position > 1) then
        error("The value of `position' should be in range 0 .. 1")
    end

    
    
    local colorScale = {color[1] / 255, color[2] / 255, color[3] / 255,color[4] / 255}
    local scaleInvert = {1.0 / scale}
    local offsetScale = position * 2 - 1
    
    
    Common.removeEffect(drawing)     
    
    local flashTexId = res_alloc_id()
	local offsetId = res_alloc_id()
	local directionId = res_alloc_id()
    local colorId = res_alloc_id()
    local scaleId = res_alloc_id()
    local posId = res_alloc_id();
    
    local ratioH
    local ratioW
    local w = res_get_image_width(drawing.m_resID)
    local h = res_get_image_height(drawing.m_resID)
    local rectXScale,rectYScale

    if typeof(drawing.m_res, ResImage) then 
        local rectX, rectY, sizeX, sizeY = drawing.m_res:getSubTextureCoord()
        if rectY and sizeY and rectX and sizeX  then
            rectXScale = rectX/w  
            rectYScale = rectY/h
            ratioW = sizeX/w
            ratioH = sizeY/h 
        else
            rectXScale = 0.0  
            rectYScale = 0.0
            ratioH = 1.0
            ratioW = 1.0 
        end
    else 
        rectXScale = 0.0  
        rectYScale = 0.0
        ratioH = 1.0
        ratioW = 1.0   
    end     

	res_create_double_array(0, offsetId, {offsetScale})
    res_create_double_array(0, directionId, {ratioW, ratioH, 0.0})
    res_create_double_array(0, posId, {rectXScale, rectYScale})
    res_create_double_array(0,colorId,colorScale)
    res_create_double_array(0,scaleId,scaleInvert)
	res_create_image(0, flashTexId, "libEffect/shaders/whiteSampler.png", 0,1)
	
	drawing_set_program(drawing.m_drawingID, "flashShader", 4)
    drawing_set_program_data( drawing.m_drawingID, "offset", offsetId)
    drawing_set_program_data( drawing.m_drawingID, "texture1", flashTexId)
    drawing_set_program_data( drawing.m_drawingID, "direction", directionId)
    drawing_set_program_data( drawing.m_drawingID, "color", colorId)
    drawing_set_program_data( drawing.m_drawingID, "scale", scaleId)
    drawing_set_program_data( drawing.m_drawingID, "pos", posId)

    local shaderInfo = ShaderInfo.setShaderInfo(drawing, effectName, {position = position, offsetId = offsetId , scale = scale, scaleId = scaleId , colorId = colorId, color = color})
    GC.setFinalizer(shaderInfo, function ()
        res_delete(offsetId)
        res_free_id(offsetId)
		res_delete(flashTexId)
        res_free_id(flashTexId)
        res_delete(scaleId)
        res_free_id(scaleId)
		res_delete(colorId)
        res_free_id(colorId)
    end)
end

---
-- 设置高亮效果的 position 属性。
--
-- @param core.drawing#DrawingImage drawing 应用了高亮效果的drawing对象。如果drawing为nil，或者当前特效不是高亮效果，则什么都不做。
-- @param #number position 高亮效果的 position 属性。详见 @{#Flash.applyToDrawing} 的说明。
flash.setPosition = function (drawing, position)
    if (position < 0) or (position > 1) then
        error("The value of `position' should be in range 0 .. 1.")
    end        

    local offsetScale = position * 2 - 1
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then                
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        shaderInfo.position = position;
     	res_set_double_array(shaderInfo.offsetId, {offsetScale})
        drawing_set_program_data(drawing.m_drawingID, "offset", shaderInfo.offsetId)		
	end
end

--- 
-- 获得当前应用到drawing的高亮效果的 position 属性。
--
-- @param core.drawing#DrawingImage drawing 应用了高亮效果的drawing对象。
-- @return #number 高亮效果的 position 属性。详见 @{#Flash.applyToDrawing} 的说明。
-- @return #nil 如果drawing为nil，或者没有应用高亮效果，则返回nil。
flash.getPosition = function (drawing)
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        return shaderInfo.position
	else
	    return nil
	end
end

---
-- 设置高亮效果的 scale 属性。
--
-- @param core.drawing#DrawingImage drawing 应用了高亮效果的drawing对象。如果drawing为nil，或者当前特效不是高亮效果，则什么都不做。
-- @param #number scale 高亮效果的 scale 属性。详见 @{#Flash.applyToDrawing} 的说明。
flash.setScale = function (drawing, scale)
    if (scale < 1) or (scale > 2) then
        error("The value of `scale' should be in range 1 .. 2.")
    end        

    local scaleInvert = {1.0/scale}
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then        
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        shaderInfo.scale = scale;
     	res_set_double_array(shaderInfo.scaleId, scaleInvert)
        drawing_set_program_data(drawing.m_drawingID, "scale", shaderInfo.scaleId)		
	end
end

--- 
-- 获得当前应用到 drawing 的高亮效果的 scale 属性。
--
-- @param core.drawing#DrawingImage drawing 应用了高亮效果的drawing对象。
-- @return #number 高亮效果的 scale 属性。详见 @{#Flash.applyToDrawing} 的说明。
-- @return #nil 如果drawing为nil，或者没有应用高亮效果，则返回nil。
flash.getScale = function (drawing)    
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        return shaderInfo.scale
	else
	    return nil
	end
end

---
-- 设置高亮效果的 color 属性。
--
-- @param core.drawing#DrawingImage drawing 应用了高亮效果的drawing对象。如果drawing为nil，或者当前特效不是高亮效果，则什么都不做。
-- @param #table color 高亮效果的color属性。详见 @{#Flash.applyToDrawing} 的说明。
flash.setColor = function (drawing, color)
    if not (type(color) == 'table') then 
        error("The type of `color' should be a table.")
    end 
    
    if 4 ~= #color then 
        error("The length of `color' should be 4.")
    end 

    for _,v in ipairs(color) do
        if (v < 0 or v > 255) then
            error("The element of `color' should be in range 0 .. 255.")
        end     
    end


    local colorScale = {color[1]/255, color[2]/255, color[3]/255,color[4]/255}
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then        
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        shaderInfo.color = color;
     	res_set_double_array(shaderInfo.colorId, colorScale)
        drawing_set_program_data(drawing.m_drawingID, "color", shaderInfo.colorId)		
	end
end

--- 
-- 获得当前应用到drawing的高亮效果的color属性。
--
-- @param core.drawing#DrawingImage drawing 应用了高亮效果的drawing对象。
-- @return #table 高亮效果的color属性。详见 @{#Flash.applyToDrawing} 的说明。
-- @return #nil 如果drawing为nil，或者没有应用高亮效果，则返回nil。
flash.getColor = function (drawing)
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        return shaderInfo.color
	else
	    return nil
	end
end

return flash
