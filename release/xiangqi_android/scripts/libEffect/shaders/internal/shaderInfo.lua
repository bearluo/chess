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
-- 内部模块，对特效的信息进行设定和获得，包括特效的名字以及参数的信息等。
--
-- @module ShaderInfo
-- @author Xiaofeng Yang

local M = {}

local fieldName = '__shaderInfo'

---
-- 获得field的名字。
--
-- @return 返回field的名字。
M.getFieldName = function ()
    return fieldName
end

---
-- 设定Drawing对象的特效信息，如果info和name不为空则返回储存特效信息的table，否则table为空，返回nil。
--
-- @param #Drawing drawing Drawing对象。
-- @param #string name 特效的名字。
-- @param #table 特效的相关参数和ID。
-- @return #table drawing[fieldName] 如果info和name不为空则返回储存特效信息的table，否则table为空，返回nil。
M.setShaderInfo = function ( drawing, name, info )
    if name then
        if info then
            drawing[fieldName] = info
        else
            drawing[fieldName] = {}
        end
        drawing[fieldName].name = name

        return drawing[fieldName]
    else
        drawing[fieldName] = nil

        return nil
    end
end

---
-- 获得存放该Drawing使用的特效信息的table，如果Drawing对象不为空且类型是table，则返回储存特效信息的table，否则返回nil。
--
-- @param #table drawing Drawing对象。
-- @return #table drawing[fieldName] 如果Drawing对象不为空且类型是table，则返回储存特效信息的table，否则返回nil。
M.getShaderInfo = function ( drawing )
    if drawing and ( type(drawing) == 'table' ) then
        if drawing[fieldName] then
            return drawing[fieldName]
        else
            return nil
        end
    else
        return nil
    end
end

---
-- 获得当前Drawing对象的特效名字。
--
-- @param #table drawing Drawing对象。
-- @return #table shaderInfo.name 如果特效信息存在则返回特效名字，否则返回nil。
M.getShaderName = function ( drawing )
    local shaderInfo = M.getShaderInfo(drawing)

    if shaderInfo then
        return shaderInfo.name
    else
        return nil
    end
end


return M