-- global.lua
-- Author: Vicent Gong
-- Date: 2012-09-30
-- Last modification : 2013-05-30
-- Description: provide some global functions

FwLog = function(logStr)
	print_string(logStr);
end

Copy = function(t)
	if type(t) ~= "table" then
		return t;
	end

	local ret = {};
	for k,v in pairs(t) do 
		ret[Copy(k)] =Copy(v);
	end

    local mt = getmetatable(t);
    setmetatable(ret,Copy(mt));
	return ret;
end

MegerTables = function(...)
    local ret = {};
    local count = select("#",...);
    for i=1,count do
        local t = select(i,...);
        if type(t) == "table" then
            for _,v in pairs(t) do
                ret[#ret+1] = v;
            end
        end
    end
    return ret;
end

CombineTables = function(...)
    local ret = {};
    local count = select("#",...);
    for i=1,count do
        local t = select(i,...);
        if type(t) == "table" then
            for k,v in pairs(t) do
                ret[k] = v;
            end
        end
    end
    return ret;
end

CreateTable = function(weakOption)
    if not weakOption or (weakOption ~= "k" and weakOption ~= "v" and weakOption ~= "kv") then
        return {};
    end

    local ret = {};
    setmetatable(ret,{__mode = weakOption});
    return ret;
end

SubtractArray = function(arr1,arr2)
    local ret = {};

    kvRevertArr2 = {};
    for k,v in ipairs(arr2) do 
        kvRevertArr2[v] = kvRevertArr2[v] or 0;
        kvRevertArr2[v] = kvRevertArr2[v] + 1;
    end

    for k,v in ipairs(arr1) do 
        if not kvRevertArr2[v] then
            ret[#ret+1] = v;
        else
            kvRevertArr2[v] = kvRevertArr2[v] - 1;
            kvRevertArr2[v] = kvRevertArr2[v] > 0 and kvRevertArr2[v] or nil;
        end
    end
    return ret;
end

GetNumFromJsonTable = function(tb, key, default)
    local ret = default;
    if tb[key] ~= nil then
        if tb[key]:get_value() ~= nil then
            ret = tonumber(tb[key]:get_value());
            if ret == nil then
                ret = default;
            end
        end
    end
    return ret;
end

GetStrFromJsonTable = function(tb, key, default)
    local ret = default;
    if tb[key] ~= nil then
        if tb[key]:get_value() ~= nil then
            ret = tb[key]:get_value();
            if string.len(ret)  == 0 then
                ret = default;
            end
        end
    end
    return ret;
end

GetBlooeanFromJsonTable = function(tb, key, default)
    local ret = default;
    if tb and tb[key] ~= nil then
        if tb[key]:get_value() ~= nil then
            ret = tb[key]:get_value();
        end
    end
    return ret;
end

GetTableFromJsonTable = function(tb, key, default)
    local ret = default;
    if tb and tb[key] ~= nil then
        if tb[key]:get_value() ~= nil then
            ret = tb[key]:get_value();
            if type(ret) ~= "table" then
                ret = default;
            end
        end
    end
    return ret;
end

orderedPairs = function(t)
	local cmpMultitype = function(op1, op2)
		local type1, type2 = type(op1), type(op2)
		if type1 ~= type2 then --cmp by type
			return type1 < type2
		elseif type1 == "number" and type2 == "number"
			or type1 == "string" and type2 == "string" then
			return op1 < op2 --comp by default
		elseif type1 == "boolean" and type2 == "boolean" then
			return op1 == true
		else
			return tostring(op1) < tostring(op2) --cmp by address
		end
	end

	local genOrderedIndex = function(t)
		local orderedIndex = {}
		for key in pairs(t) do
			table.insert( orderedIndex, key )
		end
		table.sort( orderedIndex, cmpMultitype ) --### CANGE ###
		return orderedIndex
	end

    local orderedIndex = genOrderedIndex( t );
    local i = 0;
    return function(t)
        i = i + 1;
        if orderedIndex[i] then
            return orderedIndex[i],t[orderedIndex[i]];
        end
    end,t, nil;
end


--Joins = function(t, mtkey)
--    local str = "K";
--    if t == nil or type(t) == "boolean"  or type(t) == "byte" then
--        return str;
--    elseif type(t) == "number" or type(t) == "string" then
--        str = string.format("%sT%s%s", str.."", mtkey, string.gsub(t, "[^a-zA-Z0-9]",""));
--    elseif type(t) == "table" then
--        for k,v in orderedPairs(t) do
--            str = string.format("%s%s=%s", str, tostring(k), Joins(v, mtkey));
--        end
--    end
--    return str;
--end

require("libs/util")

function Joins(t, mtkey)
    local str = "M";
    if t == nil or type(t) == "boolean"  or type(t) == "byte" then
        return str;
    -- elseif type(t) == "number" or type(t) == "string"then
    --     str = string.format("%sT%s%d", str, mtkey, t);
    elseif type(t) == "number" or type(t) == "string" then
        str = string.format("%sT%s%s", str.."", mtkey, string.gsub(t, "[^a-zA-Z0-9]",""));
    elseif type(t) == "table" then
        for k,v in orderedPairs(t) do
            str = string.format("%s%s=%s", str, tostring(k), Joins(v, mtkey));
        end
    end
    return str;
end