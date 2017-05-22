-- dict.lua
-- Author: Vicent Gong
-- Date: 2012-09-30
-- Last modification : 2013-05-29
-- Description: provide basic wrapper for dict functions

require("core/object");
require("core/constants");

Dict = class();

Dict.ctor = function(self, dictName)
	self.m_name = dictName;
end

Dict.dtor = function(self, dictName)
	self.m_name = nil;
end

Dict.load = function(self)
	return dict_load(self.m_name);
end

Dict.save = function(self)
	return dict_save(self.m_name);
end

Dict.delete = function(self)
	return dict_delete(self.m_name);
end

Dict.setBoolean = function(self, key, value)
	return dict_set_int(self.m_name,key,value and kTrue or kFalse);
end

Dict.getBoolean = function(self, key, defaultValue)
	local ret =  dict_get_int(self.m_name,key,defaultValue and kTrue or kFalse);
	return (ret == kTrue);
end

Dict.setInt = function(self, key, value)
    if value == "" then
        value = 0;
    end
	return dict_set_int(self.m_name,key,value);
end

Dict.getInt = function(self, key, defaultValue)
	return dict_get_int(self.m_name,key,defaultValue or 0);
end

Dict.setDouble = function(self, key, value)
	return dict_set_double(self.m_name,key,value);
end

Dict.getDouble = function(self, key, defaultValue)
	return dict_get_double(self.m_name,key,defaultValue or 0.0);
end

Dict.setString = function(self, key, value)
    if value == "" then
        value = "null"
    end
	return dict_set_string(self.m_name,key,value);
end

Dict.getString = function(self, key)
	return dict_get_string(self.m_name,key);
end