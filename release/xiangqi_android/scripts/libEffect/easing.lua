--
-- libEffect Version: @@Version@@
-- 
-- This file is a part of libEffect Library.
--
-- Authors:
-- Xiaofeng Yang     
-- Heng Li           
--

local M = { }


-- 如果是16，那么理论上一帧至少会有一个数值。
-- 如果是8，那么理论上一帧至少会有2个数值。
-- 要平滑，必须确保 1 <= fillStep <= 16。8可能是比较完美的值，待确定。
local fillStep = 16 
M.getFillStep = function ()
    return fillStep
end
M.setFillStep = function (value)
    fillStep = value 
end
M.getEaseArray = function (easeFunction, duration, b, c, ...)
    local fn = easeFunction
    if type(easeFunction) == "string" then 
        fn = M.fns[easeFunction]
    end 

    -- fill the array
    local arr = {}
    local i = 1
    local t = 0
    while t < duration do   
        arr[i] = fn(t, b, c, duration, ...)
        i = i + 1
        t = t + fillStep
    end 

    arr[i] = fn(duration, b, c, duration, ...)
    return arr
end

-- 把t里的缓动函数变成更易用的版本（b,c可以任意取值，若c<0则函数图像是上下翻转的）
local getConvenienceVersion = function (t)
    local newT = {}
    for name, fn in pairs(t) do
        local newFn = (function ()
            local origFn = fn
            return function (t, b, c, ...)
                if c >= 0 then 
                    return origFn(t, 0, c, ...) + b
                else 
                    -- c < 0
                    return b - origFn(t, 0, - c, ...)
                end                 
            end
        end)()        
        newT[name] = newFn
    end 
    
    return newT
end

--- 
M.fns = getConvenienceVersion({
    --- 
    -- 计算从b变化到b+c的值。
    -- @param t #number current time (t>=0)
    -- @param b #number beginning value (b>=0)
    -- @param c #number change in value (c>=0)
    -- @param d #number duration (d>0)
    -- @return #number the calculated result
    swing = function(t, b, c, d)
        return M.fns.easeOutQuad(t, b, c, d)
    end,

    linear = function (t, b, c, d)
        local k = c / d
        local r = b
        return k * t + r
    end,

    easeInQuad = function(t, b, c, d)
        t = t / d
        return c * t * t + b
    end,

    easeOutQuad = function(t, b, c, d)
        t = t / d
        return - c * t *(t - 2) + b
    end,

    easeInOutQuad = function(t, b, c, d)
        t = t /(d / 2)

        if (t < 1) then
            return c / 2 * t * t + b
        end

        t = t - 1

        return - c / 2 *(t *(t - 2) -1) + b
    end,

    easeInCubic = function(t, b, c, d)
        t = t / d
        return c * t * t * t + b
    end,

    easeOutCubic = function(t, b, c, d)
        t = t / d - 1
        return c *(t * t * t + 1) + b
    end,

    easeInOutCubic = function(t, b, c, d)
        t = t /(d / 2)
        if (t < 1) then
            return c / 2 * t * t * t + b
        end

        t = t - 2
        return c / 2 *(t * t * t + 2) + b
    end,

    easeInQuart = function(t, b, c, d)
        t = t / d
        return c * t * t * t * t + b
    end,

    easeOutQuart = function(t, b, c, d)
        t = t / d - 1
        return - c *(t * t * t * t - 1) + b
    end,

    easeInOutQuart = function(t, b, c, d)
        t = t /(d / 2)
        if (t < 1) then
            return c / 2 * t * t * t * t + b
        end

        t = t - 2
        return - c / 2 *(t * t * t * t - 2) + b
    end,

    easeInQuint = function(t, b, c, d)
        t = t / d
        return c * t * t * t * t * t + b
    end,

    easeOutQuint = function(t, b, c, d)
        t = t / d - 1
        return c *(t * t * t * t * t + 1) + b
    end,

    easeInOutQuint = function(t, b, c, d)
        t = t /(d / 2)
        if (t < 1) then
            return c / 2 * t * t * t * t * t + b
        end
        t = t - 2
        return c / 2 *(t * t * t * t * t + 2) + b
    end,


    easeInSine = function(t, b, c, d)
        return - c * math.cos(t / d *(math.pi / 2)) + c + b
    end,

    easeOutSine = function(t, b, c, d)
        return c * math.sin(t / d *(math.pi / 2)) + b
    end,

    easeInOutSine = function(t, b, c, d)
        return - c / 2 *(math.cos(math.pi * t / d) -1) + b
    end,

    easeInExpo = function(t, b, c, d)
        if t == 0 then
            return b
        else
            return c * math.pow(2, 10 *(t / d - 1)) + b
        end
    end,

    easeOutExpo = function(t, b, c, d)
        if t == d then
            return b + c
        else
            return c *(- math.pow(2, -10 * t / d) + 1) + b
        end
    end,

    easeInOutExpo = function(t, b, c, d)
        if (t == 0) then
            return b
        end

        if (t == d) then
            return b + c
        end

        t = t /(d / 2)

        if (t < 1) then
            return c / 2 * math.pow(2, 10 *(t - 1)) + b
        end

        t = t - 1
        return c / 2 *(- math.pow(2, -10 * t) + 2) + b
    end,

    easeInCirc = function(t, b, c, d)
        t = t / d
        return - c *(math.sqrt(1 - t * t) -1) + b
    end,

    easeOutCirc = function(t, b, c, d)
        t = t / d - 1
        return c * math.sqrt(1 - t * t) + b
    end,

    easeInOutCirc = function(t, b, c, d)
        t = t /(d / 2)
        if (t < 1) then
            return - c / 2 *(math.sqrt(1 - t * t) -1) + b
        end
        t = t - 2
        return c / 2 *(math.sqrt(1 - t * t) + 1) + b
    end,

    easeInElastic = function(t, b, c, d)
        if (t == 0) then
            return b
        end

        if t == d then
            return b + c
        end

        t = t / d
        
        local p = d * .3
        local s = p / 4

        t = t - 1
        return -(c * math.pow(2, 10 * t) * math.sin((t * d - s) *(2 * math.pi) / p)) + b
    end,

    easeOutElastic = function(t, b, c, d)
        if t == 0 then
            return b
        end

        if t == d then
            return b + c
        end

        t = t / d

        local p = d * .3        
        local s = p / 4

        return c * math.pow(2, -10 * t) * math.sin((t * d - s) *(2 * math.pi) / p) + c + b
    end,

    easeInOutElastic = function(t, b, c, d)
        if t == 0 then
            return b
        end

        if t == d then
            return b + c
        end
        
        t = t / (d / 2)

        local p = d * (.3 * 1.5)
        local s = p / 4

        if (t < 1) then
            t = t - 1
            return -.5 *(c * math.pow(2, 10 *(t)) * math.sin((t * d - s) *(2 * math.pi) / p)) + b
        end

        t = t - 1
        return c * math.pow(2, -10 *t) * math.sin((t * d - s) *(2 * math.pi) / p) * .5 + c + b
    end,

    easeInBack = function(t, b, c, d, s)
        if (s == nil) then
            s = 1.70158
        end
        t = t / d
        return c *(t) * t *((s + 1) * t - s) + b
    end,

    easeOutBack = function(t, b, c, d, s)
        if (s == nil) then
            s = 1.70158
        end
        t = t / d - 1
        return c *(t * t *((s + 1) * t + s) + 1) + b
    end,

    easeInOutBack = function(t, b, c, d, s)
        if (s == nil) then
            s = 1.70158
        end
        t = t /(d / 2)

        if (t < 1) then
            s = s *(1.525)
            return c / 2 *(t * t *((s + 1) * t - s)) + b
        end
        s = s *(1.525)
        t = t - 2
        return c / 2 *(t * t *((s + 1) * t + s) + 2) + b
    end,

    easeInBounce = function(t, b, c, d)
        return c - M.fns.easeOutBounce(d - t, 0, c, d) + b
    end,

    easeOutBounce = function(t, b, c, d)
        t = t / d
        if (t <(1 / 2.75)) then
            return c *(7.5625 * t * t) + b
        elseif (t <(2 / 2.75)) then
            t = t -(1.5 / 2.75)
            return c *(7.5625 * t * t + .75) + b
        elseif (t <(2.5 / 2.75)) then
            t = t -(2.25 / 2.75)
            return c *(7.5625 * t * t + .9375) + b
        else

            t = t -(2.625 / 2.75)
            return c *(7.5625 * t * t + .984375) + b
        end
    end,

    easeInOutBounce = function(t, b, c, d)
        if (t < d / 2) then
            return M.fns.easeInBounce(t * 2, 0, c, d) * .5 + b
        end
        return M.fns.easeOutBounce(t * 2 - d, 0, c, d) * .5 + c * .5 + b
    end
})

return M
