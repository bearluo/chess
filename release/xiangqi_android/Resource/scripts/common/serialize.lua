require("core/object");
require("coreex/systemex");

Serialize = class();

--Serialize.s_cachePath = (sys_get_string("android_storage_root") or "").."/";
Serialize.s_cachePath = System.getStorageDictPath();
Serialize.s_tab = "";

Serialize.ctor = function(self, fileName, lastDays)
	self.m_name = fileName;
	self.m_lastDays = lastDays;
	self.m_cache = self:load(fileName,lastDays) or {};
end 

Serialize.dtor = function(self)
	self:save();
	self.m_cache = nil;
	self.m_lastDays = 7;
	self.m_name = nil;
end 

Serialize.get = function(self, url)
	local name = self.m_cache[url] or "";
	local path = kUserData:getAndroidImagesPath()..name;
	local fp = io.open(path, "r");
	if name~="" and fp then
		io.close(fp);
		return name;
	end
	self.m_cache[url] = nil;
	return nil; 
end

Serialize.set = function(self, url, fileName)
	self.m_cache[url] = fileName;
end

Serialize.load = function(self)
	local filePath = Serialize.s_cachePath..self.m_name;
	local file = io.open(filePath,"r");
	if not file then 
		return;
	else 
		local isSuccess,file = pcall(dofile,filePath);
		if isSuccess then 
			return self:clearCache(file, self.m_lastDays);
		else 
			return;
		end 
	end 
end

Serialize.save = function(self)
	local fileName = Serialize.s_cachePath..self.m_name;
	local file = io.open(fileName,"w");
	if not file then 
		return;
	end 

	file:write("return ");
	self:writeValue(file, self.m_cache);
	file:close();
end 

Serialize.clearAll = function(self)
	self.m_cache = {};
end

Serialize.clearFile = function(self, url)
	self.m_cache[url] = nil;
	self:save();
end

-------------------------------------------------------
--清除day天之前的数据
Serialize.clearCache = function(self, cache, day)
	local ret = {};
	local now = os.time();
	local lastTime = now-day*24*60*60;--seconds
	if cache and day then
		local time,pos,len;
		for k, v in pairs(cache) do
			pos,len = string.find(v,".png");
			time = tonumber(string.sub(v, 1, 10));
            if time and lastTime then 
			    if time>=lastTime then
				    ret[k] = v;
			    end 
            end
		end
		
		return ret;
	end
	return cache;
end

Serialize.writeTable = function(self,fileName,src)
	if type(src) ~= "table" then 
		return;
	end 

	local tab = Serialize.s_tab;
	Serialize.s_tab = Serialize.s_tab .. "	";

	fileName:write("{\n");
	for k,v in pairs(src) do 
		if type(k) == "string" or type(k) == "number" then
			fileName:write(Serialize.s_tab);
			self:writeKey(fileName,k);
			self:writeValue(fileName,v);			
		end 
	end 
	fileName:write(tab.."}");
	Serialize.s_tab = tab;
end

Serialize.writeString = function(self,fileName,value)
	fileName:write("\"");
	fileName:write(value);
	fileName:write("\"");
end 

Serialize.writeBoolean = function(self,fileName,value)
	fileName:write(tostring(value));
end

Serialize.writeNumber = function(self,fileName,value)
	fileName:write(value);
end

Serialize.writeKey = function(self,fileName,key)
	fileName:write("[");
	if type(key) == "string" then 
		self:writeString(fileName,key);
	else 
		self:writeNumber(fileName,key);
	end
	fileName:write("] = ");
end 

Serialize.writeValue = function(self,fileName,v)
	if type(v) == "table" then 
		self:writeTable(fileName,v);
	elseif type(v) == "string" then
		self:writeString(fileName,v);
	elseif type(v) == "boolean" then
		self:writeBoolean(fileName,v);	
	else 	
		fileName:write(v);
	end
	fileName:write(";\n");
end