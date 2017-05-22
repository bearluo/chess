local lunajson = require 'libutils.internal.libs.lunajson'
local Task = require 'libutils.task'

---
-- @module libutils.json
--
-- @usage local Json = require 'libutils.json'
local M = {}

---
-- 开始解析json字符串，在若干帧以后，给出结果。
--
-- @param #string json 要解析的json字符串。
-- @param #table config 配置信息。
-- 
-- * config.onSuccess :: object -> unit  - 当解析完成的时候调用这个函数。object为json转换而成的lua字符串。
-- * config.onError   :: msg -> unit     - 当解析过程中出错的时候，调用这个函数。msg为出错字符串。
-- * step             :: int             - 每帧处理几个字符。默认：4。
-- * null             :: any             - 把json字符串中的null值翻译成这个值。默认：nil。
M.parseJsonAsync = function (json, config)
    local step = 4 
    local null = nil
    local onSuccess = function () end
    local onError = function () end
    
    if config.step then
        step = config.step
    end
    
    if config.onSuccess then
        onSuccess = config.onSuccess
    end
    
    if config.onError then
        onError = config.onError
    end
    
    if config.null then
        null = config.null
    end

    -- 以下，正文开始。
    
    local saxtbl = {}
    local current = {} 
    local nullv
    
    do
        local stack = {}
        local top = 1
    
        local key = 1
        local isobj
    
        local function add(v)
            if v == nil then
                v = nullv
            end
            current[key] = v
            if type(key) == 'number' then
                key = key+1
            end
        end
        local function push()
            stack[top] = current
            stack[top+1] = key
            top = top+2
        end
        local function pop()
            top = top-2
            key = stack[top+1]
            current = stack[top]
        end
    
        function saxtbl.startobject()
            push()
            current = {}
            key = nil
        end
        function saxtbl.key(s)
            key = s
        end
        function saxtbl.endobject()
            local obj = current
            pop()
            add(obj)
        end
        function saxtbl.startarray()
            push()
            current = {}
            key = 1
        end
        function saxtbl.endarray()
            local ary = current
            pop()
            add(ary)
        end
        saxtbl.string = add
        saxtbl.number = function(n)
            current[key] = n-0.0
            if type(key) == 'number' then
                key = key+1
            end
        end
        saxtbl.boolean = add
        saxtbl.null = add
    end
    
    local function decode(json, nv)
        nullv = nv
        local i = 1
        local j = 0
        local finished = false
        local function gen()
            coroutine.yield()        
            local s = string.sub(json, i, i + step - 1)
            i = i + step
    
            if string.len(s) == 0 then
                s = nil
            end
            return s
        end
        
        local co = coroutine.create(function ()
            lunajson.newparser(gen, saxtbl).run()
            finished = true
        end)
        
        Task.runEveryFrames(function (stop)
            if not finished then
                local success, msg = coroutine.resume(co)
                if not success then
                    stop()
                    onError(msg)
                end
            else
                stop()
                onSuccess(current[1])
            end
        end)
    end
    
    decode(json,null)
end


return M