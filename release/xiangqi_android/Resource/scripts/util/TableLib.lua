--[[
	判断table是否为空
]]
function table.isEmpty(t)
	if t and type(t)=="table" then --FIXME 此句可以判空，为何还要循环表内元素？
		return next(t)==nil;  
	end
	return true;			
end

--[[
    判断table是否为nil
]]
function table.isNil(t)
    if t and type(t)=="table" then 
        return false;
    end
    return true;            
end


--[[
    判断table是否为table
]]
function table.isTable(t)
    if type(t)=="table" then 
        return true;
    end
    return false;            
end

--[[
    复制table，只复制数据，对table内的function无效
]]
function table.copyTab(st)
    local tab = {}
    for k, v in pairs(st or {}) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = table.copyTab(v)
        end
    end
    return tab
end

--[[
    table校验，返回自身或者{}
]]
function table.verify(t)   
    if t and type(t)=="table" then
        return t;
    end
    return {};
end

function table.getSize(t)   
    local size =0;
    if t and type(t)=="table" then
        for k,v in pairs(t) do
            size=size+1;
        end
    end
    return size;
end

--XXX 不符合格式时 是否需要直接返回？根据模块需求，自行修改是否放行，确认后请把此注释删除。

function table.size(t)
    if type(t) ~= "table" then 
        return 0;
    end 

    local count = 0;
    for _,v in pairs(t) do 
        count = count + 1;
    end 

    return count;
end 

--比较两个table的内容是否相同
function table.equal(t1,t2)
    if type(t1) ~= type(t2) then 
        return false;
    else 
        if type(t1) ~= "table" then 
            return t1 == t2;
        else 
            local len1 = table.size(t1);
            local len2 = table.size(t2);
            if len1 ~= len2 then
                return false;
            else 
                local isEqual = true;
                for k,v in pairs(t1) do 
                    if not t2[k] then
                        isEqual = false;
                        break;
                    else 
                        if type(t2[k]) ~= type(v) then
                            isEqual = false;
                            break;
                        else 
                            if type(v) ~= "table" then 
                                if t2[k] ~= v then 
                                    isEqual = false;
                                    break;
                                end 
                            else 
                                isEqual = table.equal(v,t2[k]);
                                if not isEqual then 
                                    break;
                                end 
                            end 
                        end  
                    end
                end 

                return isEqual;
            end  
        end 
    end 
end
