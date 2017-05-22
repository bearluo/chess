--[[

 JSON Encoder and Parser for Lua 5.1
 
 Copyright � 2007 Shaun Brown (http://www.chipmunkav.com).
 All Rights Reserved.
 
 Permission is hereby granted, free of charge, to any person 
 obtaining a copy of this software to deal in the Software without 
 restriction, including without limitation the rights to use, 
 copy, modify, merge, publish, distribute, sublicense, and/or 
 sell copies of the Software, and to permit persons to whom the 
 Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be 
 included in all copies or substantial portions of the Software.
 If you find this software useful please give www.chipmunkav.com a mention.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR 
 ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
 CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 Usage:

 -- Lua script:
 local t = { 
	["name1"] = "value1",
	["name2"] = {1, false, true, 23.54, "a \021 string"},
	name3 = Json.Null() 
 }

 local json = Json.Encode (t)
 print (json) 
 --> {"name1":"value1","name3":null,"name2":[1,false,true,23.54,"a \u0015 string"]}

 local t = Json.Decode(json)
 print(t.name2[4])
 --> 23.54
 
 Notes:
 1) Encodable Lua types: string, number, boolean, table, nil
 2) Use Json.Null() to insert a null value into a Json object
 3) All control chars are encoded to \uXXXX format eg "\021" encodes to "\u0015"
 4) All Json \uXXXX chars are decoded to chars (0-255 byte range only)
 5) Json single line // and /* */ block comments are discarded during decoding
 6) Numerically indexed Lua arrays are encoded to Json Lists eg [1,2,3]
 7) Lua dictionary tables are converted to Json objects eg {"one":1,"two":2}
 8) Json nulls are decoded to Lua nil and treated by Lua in the normal way

--]]

local string = string
local math = math
local table = table
local error = error
local tonumber = tonumber
local tostring = tostring
local type = type
local setmetatable = setmetatable
local pairs = pairs
local ipairs = ipairs
local assert = assert
local Chipmunk = Chipmunk

require("libs/bit")

module("Json",package.seeall)

local StringBuilder = {
	buffer = {}
}

function StringBuilder:New()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.buffer = {}
	return o
end

function StringBuilder:Append(s)
	self.buffer[#self.buffer+1] = s
end

function StringBuilder:ToString()
	return table.concat(self.buffer)
end

local JsonWriter = {
	backslashes = {
		['\b'] = "\\b",
		['\t'] = "\\t",	
		['\n'] = "\\n", 
		['\f'] = "\\f",
		['\r'] = "\\r", 
		['"']  = "\\\"", 
		['\\'] = "\\\\", 
		['/']  = "\\/"
	}
}

function JsonWriter:New()
	local o = {}
	o.writer = StringBuilder:New()
	setmetatable(o, self)
	self.__index = self
	return o
end

function JsonWriter:Append(s)
	self.writer:Append(s)
end

function JsonWriter:ToString()
	return self.writer:ToString()
end

function JsonWriter:Write(o)
	local t = type(o)
	if t == "nil" then
		self:WriteNil()
	elseif t == "boolean" then
		self:WriteString(o)
	elseif t == "number" then
		self:WriteString(o)
	elseif t == "string" then
		self:ParseString(o)
	elseif t == "table" then
		self:WriteTable(o)
	elseif t == "function" then
		self:WriteFunction(o)
	elseif t == "thread" then
		self:WriteError(o)
	elseif t == "userdata" then
		self:WriteError(o)
	end
end

function JsonWriter:WriteNil()
	self:Append("null")
end

function JsonWriter:WriteString(o)
	self:Append(tostring(o))
end

function JsonWriter:ParseString(s)
	self:Append('"')
	-- self:Append(string.gsub(s, "[%z%c\\\"/]", function(n)
	-- 	local c = self.backslashes[n]
	-- 	if c then return c end
	-- 	return string.format("\\u%.4X", string.byte(n))
	-- end))
	self:Append(string.gsub(s,"[\"]","\\\""));
	self:Append('"')
end

function JsonWriter:IsArray(t)
	local count = 0
	local isindex = function(k) 
		if type(k) == "number" and k > 0 then
			if math.floor(k) == k then
				return true
			end
		end
		return false
	end
	for k,v in pairs(t) do
		if not isindex(k) then
			return false, '{', '}'
		else
			count = math.max(count, k)
		end
	end
	return true, '[', ']', count
end

function JsonWriter:WriteTable(t)
	local ba, st, et, n = self:IsArray(t)
	self:Append(st)	
	if ba then		
		for i = 1, n do
			self:Write(t[i])
			if i < n then
				self:Append(',')
			end
		end
	else
		local first = true;
		for k, v in pairs(t) do
			if not first then
				self:Append(',')
			end
			first = false;			
			self:ParseString(k)
			self:Append(':')
			self:Write(v)			
		end
	end
	self:Append(et)
end

function JsonWriter:WriteError(o)
	return -1 , "Encoding of " .. tostring(o) .." unsupported"
end

function JsonWriter:WriteFunction(o)
	if o == Null then 
		self:WriteNil()
	else
		self:WriteError(o)
	end
end

local StringReader = {
	s = "",
	i = 0
}

function StringReader:New(s)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.s = s or o.s
	return o	
end

function StringReader:Peek()
	local i = self.i + 1
	if i <= #self.s then
		return string.sub(self.s, i, i)
	end
	return nil
end

function StringReader:Next()
	self.i = self.i+1
	if self.i <= #self.s then
		return string.sub(self.s, self.i, self.i)
	end
	return nil
end

function StringReader:All()
	return self.s
end

local JsonReader = {
	escapes = {
		['t'] = '\t',
		['n'] = '\n',
		['f'] = '\f',
		['r'] = '\r',
		['b'] = '\b',
	}
}

function JsonReader:New(s)
	local o = {}
	o.reader = StringReader:New(s)
	setmetatable(o, self)
	self.__index = self
	return o;
end

function JsonReader:Read()
	self:SkipWhiteSpace()
	local peek = self:Peek()
	if peek == nil then
		return -1 , 
			"Nil string: " .. self:All()
	elseif peek == '{' then
		return self:ReadObject()
	elseif peek == '[' then
		return self:ReadArray()
	elseif peek == '"' then
		return self:ReadString()
	elseif string.find(peek, "[%+%-%d]") then
		return self:ReadNumber()
	elseif peek == 't' then
		return self:ReadTrue()
	elseif peek == 'f' then
		return self:ReadFalse()
	elseif peek == 'n' then
		return self:ReadNull()
	elseif peek == '/' then
		self:ReadComment()
		return self:Read()
	else
		return -1 , 
			"Invalid input: " ..  self:All()
	end
end
		
function JsonReader:ReadTrue()
	self:TestReservedWord{'t','r','u','e'}
	return true
end

function JsonReader:ReadFalse()
	self:TestReservedWord{'f','a','l','s','e'}
	return false
end

function JsonReader:ReadNull()
	self:TestReservedWord{'n','u','l','l'}
	return nil
end

function JsonReader:TestReservedWord(t)
	for i, v in ipairs(t) do
		if self:Next() ~= v then
			 return -1 , 
				"Error reading ".. table.concat(t) ..": ".. self:All()
		end
	end
end

function JsonReader:ReadNumber()
        local result = self:Next()
        local peek = self:Peek()
        while peek ~= nil and string.find(
		peek, 
		"[%+%-%d%.eE]") do
            result = result .. self:Next()
            peek = self:Peek()
	end
	result = tonumber(result)
	if result == nil then
	        return -1 , "result is nil"
	else
		return result
	end
end

function JsonReader:ReadString()
	local result = ""
	local isunicode = false;
	assert(self:Next() == '"')
        while self:Peek() ~= '"' do
		local ch = self:Next()
		local uch = "";
		if ch == '\\' then
			ch = self:Next()
			if self.escapes[ch] then
				ch = self.escapes[ch]
			elseif ch == 'u' then
				local code = self:parseUnicodeEscape();
				ch = self:utf8_enc(code);
				isunicode = true;
			end
		end
        if ch ~= "\0" then
           result = result .. ch;
        end
	end
        assert(self:Next() == '"')

	return result;
end

function JsonReader:ReadComment()
        assert(self:Next() == '/')
        local second = self:Next()
        if second == '/' then
            self:ReadSingleLineComment()
        elseif second == '*' then
            self:ReadBlockComment()
        else
            return -1 , "Invalid comment: " .. self:All()
	end
end

function JsonReader:ReadBlockComment()
	local done = false
	while not done do
		local ch = self:Next()		
		if ch == '*' and self:Peek() == '/' then
			done = true
                end
		if not done and 
			ch == '/' and 
			self:Peek() == "*" then
                 return -1 , "Invalid comment: ".. self:All() .. ", '/*' illegal." 
			
		end
	end
	self:Next()
end

function JsonReader:ReadSingleLineComment()
	local ch = self:Next()
	while ch ~= '\r' and ch ~= '\n' do
		ch = self:Next()
	end
end

function JsonReader:ReadArray()
	local result = {}
	assert(self:Next() == '[')
	local done = false
	if self:Peek() == ']' then
		done = true;
	end
	while not done do
		local item = self:Read()
		result[#result+1] = item
		self:SkipWhiteSpace()
		if self:Peek() == ']' then
			done = true
		end
		if not done then
			local ch = self:Next()
			if ch ~= ',' then
				return -1 , "Invalid array: ".. self:All() .. " due to: " .. ch
			end
		end
	end
	assert(']' == self:Next())
	return result
end

function JsonReader:ReadObject()
	local result = {}
	assert(self:Next() == '{')
	local done = false
	if self:Peek() == '}' then
		done = true
	end
	while not done do
		local key = self:Read()
		if type(key) ~= "string" then
			return -1 , 
				"Invalid comment: " .. self:All() 
		end
		self:SkipWhiteSpace()
		local ch = self:Next()
		if ch ~= ':' then
		     return -1 , "Invalid array: ".. self:All() .. " due to: " .. ch
		end
		self:SkipWhiteSpace()
		local val = self:Read()
		result[key] = val
		self:SkipWhiteSpace()
		if self:Peek() == '}' then
			done = true
		end
		if not done then
			ch = self:Next()
      if ch ~= ',' then
			   return -1 , "Invalid array: ".. self:All() .. " due to: " .. ch
					
			end
		end
	end
	assert(self:Next() == "}")
	return result
end

-- Decode a Unicode escape, assuming that self.pos starts just after the
-- initial \u. May consume an additional escape in the case of a UTF-16
-- surrogate pair. See RFC 2781 for UTF-16.
function JsonReader:parseUnicodeEscape()
	local n, cp
	local hex, lowhex
	local s, e

	s, e, hex = self.reader.s:find("^(....)", self.reader.i+1)
	if not hex then
		self:syntaxerror(("EOF in Unicode escape \\u%s"):format(self.input:sub(self.reader.i+1)))
		return
	end
	n = tonumber(hex, 16)
	if not n then
		self:syntaxerror(("Bad unicode escape \\u%s"):format(hex))
		return
	end
	cp = n
	self.reader.i = e
	if n < 0xD800 or n > 0xDFFF then
		return cp
	end
	if n >= 0xDC00 and n <= 0xDFFF then
		self:syntaxerror(("Not a Unicode character: U+%04X"):format(cp))
		return
	end

	-- Beginning of a UTF-16 surrogate.
	s, e, lowhex = self.reader.s:find("^\\u(....)", self.reader.i + 1)
	if not lowhex then
		self:syntaxerror(("Bad unicode escape \\u%s (missing low surrogate)"):format(hex))
		return
	end
	n = tonumber(lowhex, 16)
	if not n or not (n >= 0xDC00 and n <= 0xDFFF) then
		self:syntaxerror(("Bad unicode escape \\u%s\\u%s (bad low surrogate)"):format(hex, lowhex))
		return
	end
	self.reader.i = e
	cp = 0x10000 + bit.band(cp, 0x3FF) * 0x400 + bit.band(n, 0x3FF)
	-- also remove last "
	return cp
end

function JsonReader:code_string(code)
	local n = 2;
	local bytes = {};
	while n > 0 do
		bytes[n] = string.char(bit.band(code, 0xFF))
		code = bit.brshift(code, 8)
		n = n - 1
	end
	return table.concat(bytes)
end

-- Encode a Unicode code point to UTF-8. See RFC 3629.
-- Does not check that cp is a real charaacter; that is, doesn't exclude the
-- surrogate range U+D800 - U+DFFF and a handful of others.
function JsonReader:utf8_enc(cp)
	local bytes = {}
	local n, mask

	if cp % 1.0 ~= 0.0 or cp < 0 then
		-- Only defined for nonnegative integers.
		return nil
	elseif cp <= 0x7F then
		-- Special case of one-byte encoding.
		return string.char(cp)
	elseif cp <= 0x7FF then
		n = 2
		mask = 0xC0
	elseif cp <= 0xFFFF then
		n = 3
		mask = 0xE0
	elseif cp <= 0x10FFFF then
		n = 4
		mask = 0xF0
	else
		return nil
	end

	while n > 1 do
		bytes[n] = string.char(0x80 + bit.band(cp, 0x3F))
		cp = bit.brshift(cp, 6)
		n = n - 1
	end
	bytes[1] = string.char(mask + cp)

	return table.concat(bytes)
end

function JsonReader:SkipWhiteSpace()
	local p = self:Peek()
	while p ~= nil and string.find(p, "[%s/]") do
		if p == '/' then
			self:ReadComment()
		else
			self:Next()
		end
		p = self:Peek()
	end
end

function JsonReader:Peek()
	return self.reader:Peek()
end

function JsonReader:Next()
	return self.reader:Next()
end

function JsonReader:All()
	return self.reader:All()
end

function Encode(o)
	local writer = JsonWriter:New()
	writer:Write(o)
	return writer:ToString()
end

function Decode(s)
	local reader = JsonReader:New(s)
	return reader:Read()
end

function Null()
	return Null
end
