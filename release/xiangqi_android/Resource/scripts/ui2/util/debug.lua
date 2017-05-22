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

M.currentFunction = function ()
    return debug.getinfo(level, 'f').func
end 

local getVars = function (upLevel)
	if upLevel == nil then
		upLevel = 1
	end
	
	local level = upLevel + 1

	local func = debug.getinfo(level, 'f').func
	
	local upvalues = {}
	local locals = {}

	-- upvalues
	local index = 1
	while true do
		local name, value = debug.getupvalue(func, index)
		if name then 
			upvalues[ name ] = value	
		else 
			break
		end
		
		index = index + 1
	end 
	
	-- local variables
	index = 1
	while true do
		local name, value = debug.getlocal(level, index)
		if name then 
			locals[ name ] = value	
		else 
			break
		end
		 
		index = index + 1
	end 
	
	return locals, upvalues 	
end 

M.getVarsStringDefaultSeperator = ', '

M.getVarsString = function (upLevel, skipFunction, seperator)
	if upLevel == nil then 
		upLevel = 1
	end
	
	if skipFunction == nil then 
		skipFunction = true
	end
	
	if seperator == nil then 
		seperator = M.getVarsStringDefaultSeperator
	end
	
	local locals, upvalues = getVars(upLevel + 1) 
	
	local result = ''
	for k,v in pairs(locals) do 
		if type(v) == 'function' then 
			if not skipFunction then
				result = result .. k .. ': ' .. tostring(v) .. seperator
			end		
		else
			result = result .. k .. ': ' .. tostring(v) .. seperator
		end		
	end	

	for k,v in pairs(upvalues) do 
		if type(v) == 'function' then 
			if not skipFunction then
				result = result .. '[UP]' .. k .. ': ' .. tostring(v) .. seperator
			end		
		else
			result = result .. '[UP]' .. k .. ': ' .. tostring(v) .. seperator
		end		
	end	

	return result
end

M.currentLine = function ()    
    return debug.getinfo(2,'l').currentline
end 



M.inspectTable = (function ()
    local do_print 
    do_print = function (t, level)
        if t == nil then 
            return
        end 

        local whitespaces = ''
        for i = 1, (level * 4) do 
            whitespaces = whitespaces .. ' '
        end 

        print_string( whitespaces .. '{' )

        local do_write_data = function (k_str, v)
            if v == _G then 
                local s = whitespaces .. '    ' .. k_str .. ' : _G'
                print_string(s)
            else 
                local s = whitespaces .. '    ' .. k_str .. ' : ' .. tostring(v) 
                print_string(s)
                if type(v) == 'table' then 
                    do_print(v, level + 1)
                end            
            end 
        end 

        for k, v in pairs(t) do 
            do_write_data(tostring(k), v)
        end 

        local mt = getmetatable(t) 
        do_write_data('(metatable)', mt)

        print_string( whitespaces .. '}' )
    end

    return function (t)
        print_string('root : ' .. tostring(t))
        do_print(t, 0)
    end

end)()



return M


