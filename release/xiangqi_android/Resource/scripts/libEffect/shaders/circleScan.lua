--
-- libEffect Version: @@Version@@
-- 
-- This file is a part of libEffect Library.
--
-- Authors:
-- Xiaofeng Yang     
-- Heng Li           

-- @module libEffect.shaders.circleMask
-- @author Heng Li
--
-- @usage local circleMask = require 'libEffect.shaders.circleMask'

---
-- `libEffect.shaders.circleScan`提供了圆形扫描裁剪效果的实现。通过调用`libEffect.shaders.circleScan.applyToDrawing()`，将圆形扫描裁剪效果应用到一个drawing对象上。
-- 
--
-- <p>
-- <table align="center" style="border-spacing: 20px 5px; border-collapse: separate">
-- <tr>
--     <td align="center" style="border-style: none;">应用效果前</td>
--     <td align="center" style="border-style: none;">应用效果后</td></tr>
-- <tr>
-- <td><img src="http://engine.by.com:8080/hosting/data/1447896707490_9178475097060390538.png"></td>
-- <td><img src="http://engine.by.com:8080/hosting/data/1447922566028_8701810160593022827.png"></td>
-- </tr>
-- </table>
-- </p>
-- @module libEffect.shaders.circleScan
-- @author LucyWang
--
-- @usage local CircleScan = require 'libEffect.shaders.circleScan'

local GC = require ("libutils.gc");
local ShaderInfo = require("libEffect.shaders.internal.shaderInfo")
local Common = require("libEffect.shaders.common")
local drawingTracer = require 'libEffect.shaders.internal.drawingTracer'
local circleScan = {}

local effectName = 'circleScan'

---
-- @type configType

---
-- 起始角度.
-- 
-- 单位：度。如图所示：点O为drawing对象的中心点，直线AC为中心线，∠α即为起始角，其对应的角度值即为起始角度。
-- 
-- ![](http://engine.by.com:8080/hosting/data/1448269035196_5229480293137900794.png)
-- 
-- @field [parent = #configType] #number startAngle 

---
-- 结束角度.
-- 单位：度。如图所示：点O为drawing对象的中心点，直线AC为中心线，∠α即为结束角，其对应的角度值即为结束角度。
-- 
-- ![](http://engine.by.com:8080/hosting/data/1448269035196_5229480293137900794.png)
-- @field [parent = #configType] #number endAngle 。


---
-- 渲染的区域.
-- 
-- 用于指定需要渲染的区域。如图所示：直线CD为drawing对象的中心线，点O为drawing对象的中心点，假定∠α为起始角，∠β为结束角，以点O为中心，∠α的终边OA顺时针旋转到∠β的终边OB，所扫过的区域为”区域Ⅰ“（如图中OAGHFB所构成的区域），drawing中剩余的区域为”区域Ⅱ“（如图中OAEB所构成的区域）。
-- 若displayClickWiseArea为true，则只渲染区域Ⅰ；否则，只渲染区域Ⅱ。
-- 
-- ![](http://engine.by.com:8080/hosting/data/1448270556017_4630032618474190324.png)
--
-- @field [parent = #configType] #boolean displayClickWiseArea 

---
-- 将圆形扫描效果应用到drawing对象上.
-- 
-- @param core.drawing#DrawingImage drawing 要应用到的对象。若不是DrawingImage，则error().
-- @param #configType config 圆形扫描效果的配置信息。详见@{#configType}
circleScan.applyToDrawing = function (drawing, config)

    if not typeof(drawing, DrawingImage) then 
        error("The type of `drawing' should be DrawingImage.")
    end 

    local offsetMatrix = {
                        math.cos(config.startAngle*3.14/180.0),
                        math.sin(config.startAngle*3.14/180.0),
                        -math.sin(config.startAngle*3.14/180.0),
                        math.cos(config.startAngle*3.14/180.0)
                        }

    local progress = config.endAngle - config.startAngle > 360 and math.fmod(config.endAngle-config.startAngle,360.0) or (config.endAngle-config.startAngle)/360.0
   
    if not ShaderInfo.getShaderInfo(drawing) or ShaderInfo.getShaderName(drawing) ~= effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        if shaderInfo == nil then
            Common.removeEffect(drawing)
            local displayClickWiseAreaId = res_alloc_id()
            local offsetMatrixId = res_alloc_id()
            local progressId = res_alloc_id()
           
            res_create_double_array(0,displayClickWiseAreaId,{config.displayClickWiseArea})
            res_create_double_array(0,progressId,{progress})
            res_create_double_array(0,offsetMatrixId,offsetMatrix)

            drawing_set_program(drawing.m_drawingID,"circleScan",4)   
           
            ShaderInfo.setShaderInfo(drawing, effectName, {displayClickWiseAreaId = displayClickWiseAreaId, offsetMatrixId = offsetMatrixId , progressId = progressId, startAngle = config.startAngle  , endAngle = config.endAngle, displayClickWiseArea = config.displayClickWiseArea})
        end
    end
    
    
    local shaderInfo = ShaderInfo.getShaderInfo(drawing)
    res_set_double_array(shaderInfo.offsetMatrixId, offsetMatrix)
    res_set_double_array(shaderInfo.progressId, {progress})
    res_set_double_array(shaderInfo.displayClickWiseAreaId, {config.displayClickWiseArea})

    drawing_set_program_data(drawing.m_drawingID,"displayClickWiseArea",shaderInfo.displayClickWiseAreaId)
    drawing_set_program_data(drawing.m_drawingID,"progress",shaderInfo.progressId)
    drawing_set_program_data(drawing.m_drawingID,"offsetMatrix",shaderInfo.offsetMatrixId)

    GC.setFinalizer(shaderInfo, function ()
        local isDrawingExists =  drawingTracer.isDrawingExists(drawing.m_drawingID)
        if isDrawingExists ~= nil and  ShaderInfo.getShaderInfo(drawing)~= nil then
           drawing_set_program(drawing.m_drawingID,'',0)
        end

        res_delete(shaderInfo.displayClickWiseAreaId)
        res_delete(shaderInfo.offsetMatrixId)
        res_delete(shaderInfo.progressId)

        res_free_id(shaderInfo.displayClickWiseAreaId)
        res_free_id(shaderInfo.offsetMatrixId)
        res_free_id(shaderInfo.progressId)
       
    end)  
end



---
-- 返回起始角度.
--
-- @param  core.drawing#DrawingBase drawing 应用到圆形扫描效果的对象。
-- @return #number 起始角度。详见@{#configType.startAngle}。 
-- @return #nil 如果drawing为nil，或者没有应用圆形扫描效果，则什么都不做，返回nil。
circleScan.getStartAngle = function (drawing)
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        return shaderInfo.startAngle
	else
	    return nil
	end
end


---
-- 返回结束角度。
--
-- @param  core.drawing#DrawingBase drawing 应用到圆形扫描裁剪效果的对象。
-- @return #number 结束角度。详见@{#configType.endAngle}。
-- @return #nil 如果drawing为nil，或者没有应用圆形扫描裁剪效果，则什么都不做，返回nil。
circleScan.getEndAngle = function (drawing)
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        return shaderInfo.endAngle
	else
	    return nil
	end
end

---
-- 返回渲染的区域.
--
-- @param  core.drawing#DrawingBase drawing 应用到圆形扫描裁剪效果的对象。
-- @return #boolean 渲染的区域。详见@{#configType.displayClickWiseArea}。
-- @return #nil 如果drawing为nil，或者没有应用圆形扫描裁剪效果，则什么都不做，返回nil。
circleScan.getDisplayClickWiseArea = function (drawing)
    if ShaderInfo.getShaderInfo(drawing) and ShaderInfo.getShaderName(drawing) == effectName then
        local shaderInfo = ShaderInfo.getShaderInfo(drawing)
        return shaderInfo.displayClickWiseArea
	else
	    return nil
	end
end

return circleScan
