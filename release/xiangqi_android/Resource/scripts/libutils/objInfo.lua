
---
-- @module libutils.objInfo
--
-- @usage local ObjInfo = require 'libutils.objInfo'

local M = {} 

local obj_assoc = setmetatable({},{ __mode = 'k' })


---
-- 将 object 和 data 关联在一起。
-- 
-- @param object 任意类型.
-- @param data  任意类型的数据。
M.setObjData = function (object, data)
    obj_assoc[object] = data
end

---
-- 返回和object相关联的data.
-- @param object 任意类型。
-- @return 和object相关联的data。此data可能是任意类型。
M.getObjData = function (object)
    return obj_assoc[object]
end

 
return M 