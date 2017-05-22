--
-- @@LIB_NAME@@, Version: @@Version@@
--
-- This file is a part of @@LIB_NAME@@.
--
-- Author:
-- Xiaofeng Yang     2015
--
--

require("core.object")

local Misc = require('libutils.misc')
local funcutils = require 'libutils.funcutils'

local M = {}

--- 根据config的设置，往对象object里增加属性。<br/>
-- config是一个table，其具有的属性和作用如下。<br/>
-- <il>
--  <li>config.name:
--  <p>属性的名字，字符串。属性不会直接在对象里面增加字段，但是会增加“getXXX”和“setXXX”两个函数，“getXXX”为getter，“setXXX”为setter，“XXX”为名字。
--  “getXXX”不带参数，返回当前属性值。“setXXX”带一个参数，将当前属性值设置成参数所指定的值。
--  若config.name为nil，那么对应的会增加名为“get”和“set”的两个函数，一个getter一个setter。</p>
--  </li>
--  <li>config.initValue
--  <p>属性的初始值。</p>
--  </li>
--  <li>config.getter
--  <p>自定义getter函数。其值是一个类型为 function (object, value) => any() 的函数。
--  该函数接受两个参数，第一个参数的值为object，第二个参数为当前的属性值。
--  当调用“getXXX”的时候，自动调用该函数，并返回该函数的返回值。
--  若该字段为nil，则“getXXX”返回属性值。</p>
--  </li>
--  <li>config.setter
--  <p>自定义setter函数。其值是一个类型为 function (object, newValue, rawSetter : function( newValue ) => any() )的函数。
--  该函数接收3个参数，第一个参数的值为object，第二个参数的值为传给“setXXX”的值，第三个rawSetter为一个函数，调用rawSetter(newValue)可以将属性值修改成newValue。
--  当调用“setXXX”的时候，自动调用该函数，并返回该函数的返回值。
--  若该字段为nil，则“setXXX”直接设置属性值为newValue，且不返回值。</p>
--  </li>
--  <li>config.mode
--  <p>字符串，其值为"rw"或"r"或"w"。若该字段为nil，则默认为"rw"。
--  若为"r"，则只向object添加getter；若为"w"，则只向object添加setter；若为"rw"，则同时向object添加getter和setter。
--  </p>
--  </li>
-- </il>
-- @param #table object 要增加的对象。
-- @param #table config 配置。
-- @return #function raw getter function。调用该函数，返回当前的属性值。
-- @return #function raw setter function。调用该函数，传一个参数，将当前属性值设置成参数对应的值。不返回。
M.addProperty = function (object, config)
    local name
    local getterName
    local setterName
    local theValue = config.initValue
    local mode
    local getter = config.getter
    local setter = config.setter

    if config.name == nil then
        name = ""
    else
        name = config.name
    end

    getterName = "get" .. name
    setterName = "set" .. name

    local rawGetter = function ()
        return theValue
    end

    local rawSetter = function ( newValue )
        theValue = newValue
    end

    if config.mode == nil then
        mode = "rw"
    else
        mode = config.mode
    end

    -- install getter
    if (mode == "rw") or (mode == "r") then
        if getter then
            object[getterName] = function ()
                return getter(object, theValue)
            end
        else
            object[getterName] = rawGetter
        end
    end

    -- install setter
    if (mode == "rw") or (mode == "w") then
        if setter then
            object[setterName] = function (newValue)
                return setter(object, newValue, rawSetter)
            end
        else
            object[setterName] = rawSetter
        end
    end

    -- return raw getter, raw setter
    return rawGetter, rawSetter
end



------------------------------------------------------------------------------------------

--[[
    This is what we should do:

        * 要兼容原有类系统，可以从原有类系统继承。
        * 要有浓厚的cpp风格。
        * 保留原来正确的调用方式。
        * 不可以在调试时进入无关代码。
        * TODO more...


    TODO remove __private__, __protected__ 

    TODO new class system
]]

local toStringTable = function (t)
    local n = #t
    local result = {}
    for i = 1, n do
        result[ t[i] ] = t[i]
    end
    return result
end


local classPreserved = toStringTable({
    'extendFromOldStyleClass',
    'extend',
    'autoConstructSuper',
    'ctor',
    'dtor',
    '__protected__',
    '__private__'
})


local createClassObject = function (config)
    if config.autoConstructSuper == nil then
        config.autoConstructSuper = true
    end

    local getProtected = function (instance)
        local mt1 = getmetatable(instance)
        local mt2 = getmetatable(mt1.__index)
        return mt2.__protected__
    end


    local classObj = {}

    local mt
    mt = {
        classInfo = {
            init = {
                doCreate = function ()
                    local obj = mt.classInfo.init.initLayoutBase(nil)
                    mt.classInfo.init.initProtected(obj)
                    return obj
                end,

                initLayoutBase = function (instance)

                    -- init layout
                    local obj = {}
                    local objMT = { }
                    setmetatable(obj, objMT)

                    -- ensure protected things
                    local protected = {}
                    objMT.__protected__ = protected

                    -- protect
                    local result = setmetatable({}, {
                        __index = obj,
                        __newindex = function(t, key, value)
                            if type(t[key]) == 'function' then
                                error("Methods cannot be changed.")
                            else
                                rawset(t, key, value)
                            end
                        end
                    })

                    -- ensure instance
                    if instance == nil then
                        instance = result
                    end

                    -- init parent
                    local baseLayout = nil
                    if config.extend then
                        local mt = getmetatable(config.extend)
                        baseLayout = mt.classInfo.init.initLayoutBase(instance)
                    end
                    objMT.__index = baseLayout


                    -- private things
                    local private = {}


                    -- call `super(...)' is calling constructor
                    local superTable = {}

                    if config.extendFromOldStyleClass then
                        local superMT = {}

                        local superFn = Misc.makeOnce(function (...)
                            local superObj = new(config.extendFromOldStyleClass, ...)
                            objMT.__index = superObj
                            superMT.__index = superObj
                        end)

                        superMT.__call = function (_, ...)
                            superFn(...)
                        end

                        setmetatable(superTable, superMT)
                    else
                        local superMT = {}

                        if baseLayout then
                            superMT.__index = baseLayout

                            superMT.__call = function (_, ...)
                                baseLayout.ctor(...)
                            end
                        else
                            -- for which no parent
                            superMT.__call = function (...)
                                -- do nothing
                            end

                        end

                        setmetatable(superTable, superMT)
                    end

                    -- init things
                    local makeEnv = (function ()
                        -- create environment

                        -- TODO 到底是所有方法share one environment好，还是单个方法单个environment好？
                        local env = setmetatable({
                            __private__ = private,
                            __protected__ = getProtected(instance),
                            super = superTable,
                        }, {
                            -- TODO 考虑要不要换成函数原本的环境。
                            __index = _G
                        })

                        return function (fn)
                            setfenv(fn, env)
                            return fn 
                        end
                    end)()

                    for k, v in pairs(config) do
                        if classPreserved[k] == nil then
                            if type(v) == 'function' then
                                obj[k] = makeEnv(funcutils.copyFunction(v))                                
                            else
                                obj[k] = v
                            end
                        end
                    end

                    -- constructor
                    do
                        local newFn = config.ctor or function () end

                        if config.autoConstructSuper then
                            local fn = newFn
                            newFn = function (...)
                                local env = getfenv()
                                super(...)

                                setfenv(fn, env)
                                fn(...)
                            end
                        end

                        newFn = Misc.makeOnce(makeEnv(funcutils.copyFunction(newFn)))                                

                        obj['ctor'] = newFn
                    end

                    -- destructor
                    do
                        local newFn = makeEnv(funcutils.copyFunction(config.dtor or function () end) )                                

                        newFn = Misc.makeOnce(newFn)

                        obj['dtor'] = newFn
                    end


                    -- init private things
                    if config.__private__ then
                        for k, v in pairs(config.__private__) do
                            if type(v) == 'function' then
                                private[k] = makeEnv(funcutils.copyFunction(v))
                            else
                                private[k] = v
                            end
                        end
                    end

                    -- init protected things
                    if config.__protected__ then
                        for k, v in pairs(config.__protected__) do
                            if type(v) == 'function' then
                                protected[k] = makeEnv(funcutils.copyFunction(v))
                            else
                                protected[k] = v
                            end
                        end
                    end


                    return result
                end,

                initProtected = function (instance)
                    local mt1 = getmetatable(instance)

                    if mt1 == nil then
                        return nil
                    end

                    local mt2 = getmetatable(mt1.__index)

                    if (mt2 == nil) or (mt2.__protected__ == nil)then
                        return nil
                    end

                    local parentNode = mt.classInfo.init.initProtected(mt2.__index)

                    setmetatable(mt2.__protected__, {
                        __index = parentNode
                    })

                    return mt2.__protected__

                end
            }
        }
    }

    setmetatable(classObj, mt)

    classObj.create = function (...)
        local obj = mt.classInfo.init.doCreate()
        obj:ctor(...)
        return obj
    end

    return classObj
end

M.defineClass = function (config)
    return createClassObject(config)
end







return M