--如果解析成功,则返回一个table.否则返回nil
--返回nil时的错误信息是json.ErrorString
--返回的table的各个字段是否符合游戏逻辑,是否为空,请应用层自行判断,建议如下判断
--[[
	local json_data = json.decode(str);
	--先判断json.decode的返回值是否为nil
	if nil==json_data then
		return;
	end
	--判断ret是否存在
	if nil==json_data.ret then
		return;
	end
	--判断json_data.ret.aUser是否存在
	if nil==json_data.ret.aUser then
		return;
	end

]]--

require("libs/json")

json = {};
json.decode = function(s)
	
	if not s then
		json.ErrorString = "A nil string";
		return nil;
	end
	
	if type(s) ~= "string" then
		json.ErrorString = "The parameter is not a string";
		return nil;
	end
	
	local data,errorString = Json.Decode(s);
	if type(data) ~= "table" then 
		json.ErrorString = errorString or "No error message generated";
		return nil;
	end
	return data;
end

json.encode = function(v)
	return Json.Encode(v);
end

----------------------------- class json.json_node ---------------------------------------

json.json_node = class();
json.nil_node = new(json.json_node);

json.json_node.ctor = function(self, value)
	self.__value = value;
end;

json.json_node.get_value = function(self)
	return self.__value;
end;

json.nil_node.get_value = function(self)
	return nil;
end;

setmetatable(json.json_node, {
	__index = function(self, key)
		if key == "super" then
			return nil;
		end;
		return json.nil_node;
	end;
});

--------------------- functon decode_node ----------------------------------------------
--Parameters: 	s -- string
-- 				
--Return 	:   return an json_node
--
--	区别于json.decode，json.decode_node不仅将json字符串解码为带有层级结构的table，更
--	为了方便使用，避免出现内容结构错误导致lua异常崩溃，对节点内容访问进行了封装
--	节点存在时返回正确的json.json_node节点，调用get_value()可以获取节点的内容
--	如果节点不存在则返回json.nil_node，此时调用get_value()将直接返回nil
--	以下使用皆为合法，不会出现运行异常
--	str = {"a":{"b":"c"}};
--	node = json.decode_node(str)
--	v = node.a.b:get_value()	-- v = "c"
--	v = node.a.c:get_value()	-- v = nil
--	v = node.b.a:get_value()	-- v = nil
--	v = node.a.b.c:get_value()	-- v = nil
--	v = node.a:get_value()		-- v = nil
-----------------------------------------------------------------------------------------
json.decode_node = function(s)
	local jret = json.decode(s);

	function parse_json(node, t)
		for key, value in pairs(t) do
			if type(value) == "table" then
				local newnode = new(json.json_node);
				parse_json(newnode, value);
				node[key] = newnode;
			else
				node[key] = new(json.json_node, value);
			end;
		end;
	end;
	
	if jret then
		local ret = new(json.json_node);
		parse_json(ret, jret);
		return ret;
	end;
	
	return json.nil_node;
end;
------ 用来解析上面参数
json.analyzeJsonNode = function(data)
    local ret = {};
    if type(data) == "table" then
        function analyze(node,t)
            for i,k in pairs(t) do
                local a = k:get_value();
                if type(a) == "table" then
                    node[i] = {};
                    analyze(node[i],k);
                else
                    node[i] = k:get_value();
                end
            end
        end
        analyze(ret,data);
    end
    return ret;
end