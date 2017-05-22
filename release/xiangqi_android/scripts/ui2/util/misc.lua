--
-- UI2 Library, Version: 1.0 Alpha (0.99.2.2058-SNAPSHOT)
-- 
-- This file is a part of UI2 Library.
--
-- Author:
-- Xiaofeng Yang     2015
--
--

local M = {}

-- callback: function or { obj: ..., fn: ... }
-- default: default value, leave it empty to make it return a function which do nothing
M.unpackCallbackArgument = function (callback, ...)
    local default = nil
    
    if #arg == 0 then 
        default = function () end
    else 
        default = arg[1]
    end 

    if type(callback) == 'function' then 
        return callback

    elseif type(callback) == 'table' then 
        local fn = callback.fn
        local obj = callback.obj

        return function ()
            fn(obj)
        end
    else 
        return default 
    end 
        
end


-- run `fn(...)' once, do nothing if it is called the second time
M.makeOnce = function (fn)
    local did = false 
    return function (...)
        if did then 
            return 
        end 

        fn(...)        

        did = true
    end
end


-- returns a new table, which cannot be modified but all table[key] can be access.
M.makeTableReadOnly = function(table)
    return setmetatable( {}, {
        __index = table,
        __newindex = function(t, key, value)
            error("Attempt to modify read-only table.")
        end,
        __metatable = false
    } )
end


do 
    local ref = {}

    M.addGlobalReference = function (obj)
        ref[obj] = true
        return obj
    end 

    M.removeGlobalReference = function (obj)    
        ref[obj] = nil
        return obj
    end
end 



M.funcall = function (fn, ...)
    fn(...)
end 

-- last parameter should be a table
M.apply = function (fn, ...)
    local arguments = {}
    for i = 1, arg.n - 1 do 
        arguments[i] = arg[i]
    end 

    for i = 1, #(arg[arg.n]) do 
        arguments[arg.n - 1 + i] = arg[arg.n][i]
    end 

    fn(unpack(arguments))
end 

return M