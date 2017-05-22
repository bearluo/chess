-- Author: AlwynLai
-- Date: 2014-01-26 10:48:04
-- Desc: 日志输出

local type, table, string, _tostring, tonumber = type, table, string, tostring, tonumber
local select = select
local error = error
local format = string.format
local pairs = pairs
local ipairs = ipairs
local print = print_string or print
local setTextColor = System and System.setWin32ConsoleColor or function() end

-- 日志级别
local LEVEL = {
	INFO = 1,
	DEBUG = 2,
	WARN = 3,
	ERROR = 4,
	FATAL = 5,
}

-- 日志类型及颜色
local LOG_TYPE = {
	[LEVEL.INFO] = { color = 0x00ff00, name = "i", }, -- 绿色
	[LEVEL.DEBUG] = { color = 0xffffff, name = "d", }, -- 白色
	[LEVEL.WARN] = { color = 0xffff00, name = "w", }, -- 黄色
	[LEVEL.ERROR] = { color = 0xff8024, name = "e", }, -- 橙色
	[LEVEL.FATAL] = { color = 0xff8080, name = "f", }, -- 粉红
}

-- 把表转换成字符串
local function tostring(value)
	local str = ''

	if (type(value) ~= 'table') then
		if (type(value) == 'string') then
			str = string.format("%q", value)
		else
			str = _tostring(value)
		end
	else
		local auxTable = {}
		for key in pairs(value) do
			if (tonumber(key) ~= key) then
				table.insert(auxTable, key)
			else
				table.insert(auxTable, tostring(key))
			end
		end
		table.sort(auxTable)

		str = str .. '{'
		local separator = ""
		local entry = ""
		for _, fieldName in ipairs(auxTable) do
			if ((tonumber(fieldName)) and (tonumber(fieldName) > 0)) then
				entry = tostring(value[tonumber(fieldName)])
			else
				entry = fieldName .. " = " .. tostring(value[fieldName])
			end
			str = str .. separator .. entry
			separator = ", "
		end
		str = str .. '}'
	end
	return str
end

-- 输出日志
local function outputMsg(level, fmt, ...)
	local f_type = type(fmt);
	local msg = ""
	if f_type == 'string' then
		if select('#', ...) > 0 then
			msg = format(fmt, ...)
		else
			-- single string
			msg = fmt
		end
	elseif f_type == 'function' then
		-- fmt should be a callable function return a string
		msg = fmt(...);
	else
		msg = tostring(fmt)
	end

	-- 输出到控制台
	setTextColor(LOG_TYPE[level].color);
    if kDebug then
        pcall( function() 
                    local file = io.open(System.getStorageUserPath().."log.txt", "a+");
                    assert(file);
                    file:write( os.date() .. "  :  " .. msg ..'\n');
                    file:close();
               end
        );
    end
	print(msg);
	setTextColor(0xffffff); --默认颜色
end

-- 创建一个日志
local function createLogger()
	local logger = {}

	-- 生成日志函数
	function logger.genLogFunc(level)
		assert(LOG_TYPE[level], "undefined level `%s'", _tostring(level));
		return function(fmt, ...)
			outputMsg(level, fmt, ...)
		end
	end

	-- 设置日志级别
	function logger.setLevel(level)
		assert(LOG_TYPE[level], "undefined level `%s'", _tostring(level))
		-- enable/disable levels
		logger.level = level;
		for i = 1, #LOG_TYPE do
			local name = LOG_TYPE[i].name;
			if i >= level then
				logger[name] = logger.genLogFunc(i);
			else
				logger[name] = function() end
			end
		end
	end

	-- 初始化日志级别
	logger.setLevel(LEVEL.INFO);
	return logger
end

DDZLog = createLogger();

-- 常用日志输出
function DebugLog(...)
	DDZLog.d(...);
end

Log = class();

Log.setLevel = function(level)  --设置日志级别
    DDZLog.setLevel(level);
end

Log.i = function(...)
	 DDZLog.i(...);
end

Log.d = function(...)
	 DDZLog.d(...);
end

Log.w = function(...)
	 DDZLog.w(...);
end

Log.e = function(...)
	 DDZLog.e(...);
end

Log.f = function(...)
	 DDZLog.f(...);
end 