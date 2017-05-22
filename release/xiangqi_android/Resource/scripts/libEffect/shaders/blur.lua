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
-- `Blur`提供了模糊效果的实现。通过调用`Blur.applyToDrawing()`，将模糊效果应用到一个drawing对象上。
-- 
--
-- <p>
-- <table align="center" style="border-spacing: 20px 5px; border-collapse: separate">
-- <tr>
--     <td align="center" style="border-style: none;">应用效果前</td>
--     <td align="center" style="border-style: none;">应用效果后</td></tr>
-- <tr>
-- <td><img src="shaders/default.png"></td>
-- <td><img src="shaders/blur.png"></td>
-- </tr>
-- </table>
-- </p>
--
--
-- @module Blur
-- @author Heng Li
--
-- @usage local Blur = require 'libEffect.shaders.blur'

require('core/object')
require('core/drawing')

local GC = require("libEffect.util.gc")
local ShaderInfo = require("libEffect.shaders.internal.shaderInfo")
local Common = require("libEffect.shaders.common")
local blur = {}
local screenWidth = sys_get_int("screen_width", -1)
local screenHeight = sys_get_int("screen_height", -1)
local effectName = 'blur'
 
---
-- 返回 intensity 属性的取值范围。
-- @return #number, #number 最小值, 最大值
blur.getIntensityRange = function ()
    return 0, 12
end

 
 
---
-- 第一个渲染阶段，垂直模糊，将当前的Drawing生成位图资源，并传入shader进行像素运算。
--
-- @param #number drawingId Drawing对象的ID。
-- @param #number rexTexId 将当前屏幕渲染的Drawing对象生成位图资源的ID。
-- @param #number ratioId 对于单个像素的周围像素采样时，采样范围的缩放值的ID
-- @param #number heightId 当前渲染屏幕的高度，影响了采样的距离。
local bindVerticalPassParameters = function (drawing, resTexId, ratioId, heightId)
    
    res_create_dynamic_image(0, resTexId, 256, 256, 1)
    res_set_image_from_drawing(resTexId, drawing.m_drawingID, 1)

    local imageHeight = res_get_image_height(drawing.m_resID)
    local imageWidth = res_get_image_width(drawing.m_resID)
    drawing_set_image_res_rect(drawing.m_drawingID, 0, 0, 0, imageWidth, imageHeight)
    drawing_set_program(drawing.m_drawingID,'',0) 
    drawing_set_program(drawing.m_drawingID, "blurShaderVertical", 4)
    drawing_set_program_data(drawing.m_drawingID, "ratio", ratioId)
    drawing_set_program_data(drawing.m_drawingID, "height", heightId)
    drawing_set_program_data(drawing.m_drawingID, "texture2", resTexId)

end

---
-- 第二个渲染阶段，水平模糊，将当前的Drawing生成位图资源，并传入shader进行像素运算
--
-- @param #number drawingId Drawing对象的ID。
-- @param #number rexTexId 将当前屏幕渲染的Drawing对象生成位图资源的ID。
-- @param #number ratioId 对于每个像素的周围像素采样时，采样范围的缩放值的ID
-- @param #number widthId 当前渲染屏幕的宽度，影响了采样的距离。
local bindHorizontalPassParameters = function (drawing, resTexId, ratioId, widthId)
     
    res_create_dynamic_image(0, resTexId, 256, 256, 1)
    res_set_image_from_drawing(resTexId, drawing.m_drawingID, 1)

    local imageHeight = res_get_image_height(drawing.m_resID)
    local imageWidth = res_get_image_width(drawing.m_resID)
    drawing_set_image_res_rect(drawing.m_drawingID, 0, 0, 0, imageWidth, imageHeight)
    drawing_set_program(drawing.m_drawingID,'',0)
    drawing_set_program(drawing.m_drawingID, "blurShaderHorizontal", 4)
    drawing_set_program_data(drawing.m_drawingID, "ratio", ratioId)
    drawing_set_program_data(drawing.m_drawingID, "width", widthId)
    drawing_set_program_data(drawing.m_drawingID, "texture1", resTexId)
end

local renderAsImage = function (drawing)  
    local resResultId = res_alloc_id()
    
    res_create_dynamic_image(0, resResultId, 256, 256, 1)
    res_set_image_from_drawing(resResultId, drawing.m_drawingID, 1)  
	drawing_set_program(drawing.m_drawingID,'',0)
    drawing_set_program(drawing.m_drawingID, "image2dX", 4)
    drawing_set_program_data(drawing.m_drawingID, "texture3", resResultId)
    
    return function ()    
        res_delete(resResultId)
        res_free_id(resResultId)
    end 
end

local doApplyToDrawing = function (drawing, sampleRatio)
    local widthId = res_alloc_id()
    local heightId = res_alloc_id()
    local sampleRatioId = res_alloc_id()
    local dynamicResId1 = res_alloc_id()
    local dynamicResId2 = res_alloc_id()

    local width = drawing_get_width(drawing.m_drawingID)
    local height = drawing_get_height(drawing.m_drawingID)

    res_create_double_array(0, widthId, {width})
    res_create_double_array(0, heightId, {height})
    res_create_double_array(0, sampleRatioId, {sampleRatio})

    bindVerticalPassParameters(drawing, dynamicResId1, sampleRatioId, heightId)
    bindHorizontalPassParameters(drawing, dynamicResId2, sampleRatioId, widthId)
    
    return function ()
        res_delete(widthId)
        res_delete(heightId)
        res_delete(sampleRatioId)
        res_delete(dynamicResId1)
        res_delete(dynamicResId2)

        res_free_id(dynamicResId2)
        res_free_id(dynamicResId1)
        res_free_id(sampleRatioId)
        res_free_id(heightId)
        res_free_id(widthId)
    end 
end 

---
-- 将模糊特效应用到drawing对象上。
--
-- @param core.drawing#DrawingImage drawing 要应用到的对象。若不是DrawingImage，则error。
-- @param #number intensity 模糊程度。范围: 0 <= intensity <= 12，越大则越模糊（且越耗时）。若intensity为nil，则默认为2。若intensity超出取值范围，则error。
blur.applyToDrawing = function (drawing, intensity) 

    if not typeof(drawing, DrawingImage) then 
        error("The type of `drawing' should be DrawingImage.")
    end 

    
        
    if intensity == nil then
        intensity = 2.0
    end 
    
    
    
    if (intensity < 0) or (intensity > 12) then 
        error("The value of `intensity' should be in range 0..12.")
    end 

            
    
    Common.removeEffect(drawing) 
            
            
    
    local finalizers = {}
    
    if intensity > 0 then  
        local x = intensity

        while true do 
            if x > 4 then 
                local fn = doApplyToDrawing(drawing, 4)
                table.insert(finalizers, fn)

                x = x - 4
            elseif x > 0 then 
                -- 0 - 4
                local fn = doApplyToDrawing(drawing, x)
                table.insert(finalizers, fn)          
                break
            else 
                -- do nothing
                break 
            end 
        end    
        
        local fn = renderAsImage(drawing)
        table.insert(finalizers, fn)
    end

    -- whether the finalizers are called
    
    
    local doFree = (function ()
        local freed = false
        return function ()
            if not freed then                 
                for _, fn in ipairs(finalizers) do 
                    fn()
                end 
                
                freed = true 
            end 
        end 
    end)()
    
    local shaderInfo = ShaderInfo.setShaderInfo(drawing, effectName, { 
        intensity = intensity,
        __cleanup = (function ()
            if intensity > 0 then 
                return function ()
                    doFree()

                    if drawing.m_res.m_subTexY and drawing.m_res.m_subTexX and drawing.m_res.m_subTexH and drawing.m_res.m_subTexW then
                        drawing_set_image_res_rect(drawing.m_drawingID, 0, drawing.m_res.m_subTexX, drawing.m_res.m_subTexY, drawing.m_res.m_subTexW, drawing.m_res.m_subTexH)
                    end
                end
            else
                return function () end -- dummy 
            end 
        end)()
    })    
    
    GC.setFinalizer(shaderInfo, function ()        
        doFree()
    end)
end

---
-- 获得当前应用到drawing的模糊效果的模糊程度。
--
-- @param core.drawing#DrawingImage drawing 应用了模糊效果的对象。
-- @return #number 模糊程度。
-- @return #nil 如果drawing为nil，或者没有应用模糊效果，则什么都不做，返回nil。
blur.getIntensity = function(drawing)
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        return shaderInfo.ratio
    else
        return nil
    end
end

return blur
