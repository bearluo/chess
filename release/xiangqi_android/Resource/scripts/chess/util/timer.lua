Timer = {}

TimerHelper = {}
TimerHelper.s_listeners = {}

function TimerHelper.registerSecondEvent(obj,func)
    if type(func) ~= "function" then return end
    local params = {}
    params.obj = obj
    params.func = func
    TimerHelper.unregisterSecondEvent(obj,func)
    table.insert(TimerHelper.s_listeners,params)
end

function TimerHelper.unregisterSecondEvent(obj,func)
    for i,params in pairs(TimerHelper.s_listeners) do
        if params.obj == obj and params.func == func then
            table.remove(TimerHelper.s_listeners,i)
            return
        end
    end
end

function TimerHelper.init()
    delete(TimerHelper.s_secondEventAnim)
    TimerHelper.s_secondEventAnim = AnimFactory.createAnimInt(kAnimLoop, 0, 1, 1000, -1)
    TimerHelper.s_secondEventAnim:setEvent(nil,function()
        for _,params in pairs(TimerHelper.s_listeners) do
            params.func(params.obj)
        end
--        print_string("TimerHelper drawing :" .. (DrawingBase.s_ref_count or 0) )
    end)
end

TimerHelper.mServerTime = 0
TimerHelper.mOffsetTime = 0
function TimerHelper.setServerCurTime(time)
    TimerHelper.mServerTime = tonumber(time) or os.time()
    TimerHelper.mOffsetTime = TimerHelper.mServerTime - os.time()
end
--[Comment]
-- 首先要调用setServerCurTime 设置server 时间
function TimerHelper.getServerCurTime()
    return TimerHelper.mOffsetTime + os.time()
end

TimerHelper.init()