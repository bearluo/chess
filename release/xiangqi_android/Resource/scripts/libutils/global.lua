
---
-- Export global names.
--
---
-- @module libutils.global



local annotation = require 'libutils.annotation'
local _Export = {} 
_Export.annotation = annotation.annotation

for k, v in pairs(_Export) do
    _G[k] = v 
end