--
-- @@LIB_NAME@@, Version: @@Version@@
--
-- This file is a part of @@LIB_NAME@@.
--
-- Author:
-- Xiaofeng Yang     2015
--
--

---
-- @module libutils.debug
--
-- @usage local Debug = require 'libutils.debug'
-- 
local M = {}

---
-- 返回当前函数对象.使用上注意不要直接```return currentFunction()```，否则无法获取正确的值。
-- @return #function 当前函数对象。
M.currentFunction = function ()
    return debug.getinfo(2, 'f').func
end

---
-- 返回当前函数对象的名称.
-- @return #string 当前函数对象的名称。
M.currentFunctionName = function ()
    return debug.getinfo(2, 'n').name
end

---
-- 返回当前函数的调用者.对 ```return caller()``` ，或者用 ```return f()``` 方式调用的函数无效。若不存在调用者，则返回nil。
-- @return #function 当前函数的调用者。
M.caller = function ()
    -- TODO 若不存在调用者，会返回什么呢？   --答：nil
    return debug.getinfo(3, 'f').func
end

---
-- 返回当前函数的调用者的名称.对 ```return caller()``` ，或者用 ```return f()``` 方式调用的函数无效。若不存在调用者，则返回nil。
-- @return #string 当前函数的调用者的名称。
M.callerName = function ()
    -- TODO 若不存在调用者，会返回什么呢？
    return debug.getinfo(3, 'n').name
end


---
-- 返回函数调用堆栈中的某层的upvalue和local variables.
-- 
-- @param upLevel 函数调用堆栈的层级。
-- @return #table,#table 包含局部变量的table，包含非局部变量的table。
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


---
-- 字符串的形式返回函数（闭包）的所有local variables和upvalues 内容.
-- 
-- @param #number upLevel 函数调用堆栈的层级。
-- @param #function skipFunction 
-- @param #string seperator 分隔符。
-- @return #string 包含local variables和upvalues的字符串。
M.getVarsString = function (upLevel, skipFunction, seperator)
    if upLevel == nil then
        upLevel = 1
    end

    if skipFunction == nil then
        skipFunction = true
    end

    if seperator == nil then
        seperator = ', '
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

--- 返回当前函数所在的行.
-- @return #number 当前函数所在的行。
M.currentLine = function ()
    return debug.getinfo(2,'l').currentline
end


--- 打印table内以及其metatable内的所有键值对.
-- @param #table t 需要打印的table。
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
        if mt ~= nil then
          do_write_data('(metatable)', mt)
        end

        print_string( whitespaces .. '}' )
    end

    return function (t)
        print_string('root : ' .. tostring(t))
        do_print(t, 0)
    end

end)()

--- 返回package.loaded，即已经加载的模块.包含table，userdata function thread。
-- @return ... package.loaded表中的数据。
local unpackPackages = function ()
  local t = {}
  for k, v in pairs(package.loaded) do
    if (type(v) == 'table') or (type(v) == 'userdata') or (type(v) == 'function') or (type(v) == 'thread') then
      table.insert(t,v)
    end
  end

  return unpack(t)
end


---
-- 根据传入的lua value，调用microscope，生成一个GraphViz的.dot文件。
-- @param value dot文件描述的lua value。可以是任意lua value。
-- @param #string path 要生成的文件路径。
-- @param #string label 生成的.dot文件的标题。若为nil，则默认为''。
-- @param ... 传入给microscope的其它参数。这部分参数会原封不动的传给microscope。若调用时这部分有传参数进来，则不使用默认设置；否则，使用默认设置。
M.dumpValueToDotFile = function (value, path, label, ...)
  if label == nil then
    label = ''
  end

  if select('#',...) > 0 then
    require( 'libutils.internal.libs.microscope' )(path, value, label, ...)
  else
    if #label > 0 then
      require( 'libutils.internal.libs.microscope' )(path, value, 'environments', "sizes", label, _G, unpackPackages())
    else
      require( 'libutils.internal.libs.microscope' )(path, value, 'environments', "sizes", _G, unpackPackages())
    end
  end

  print_string('File ' .. path .. ' saved.')
end

---
-- 根据当前的调用堆栈，生成一个GraphViz的.dot文件。忽略对_G, package.loaded.*的引用。
-- @param #string path 要生成的文件路径。
-- @param #string label 生成的.dot文件的标题。若为nil，则默认为''。
M.dumpStackToDotFile = function (path, label)
  if label == nil then
    label = ''
  end
  require( 'libutils.internal.libs.microscope' )(path, nil, 'environments', "locals", "sizes", label,  _G, M.dumpStackToDotFile, unpackPackages())
end

return M


