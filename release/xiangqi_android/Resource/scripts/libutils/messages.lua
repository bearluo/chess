---
-- 提供lua object消息发送、接收服务.
-- 
-- 通常是这样：第一帧发送消息，第二帧处理第一帧发送的所有消息。
--
-- @module libutils.messages
-- 
-- @usage local Messages = require 'libutils.messages'
local M = {}

local Task = require 'libutils.task'

-- TODO 消息队列中的消息，如果太多，则分成多帧来做。 

local receivers = setmetatable({},{__mode='k'})
local pendingMessages = {}

---
-- 注册消息接收对象和消息处理函数。可以注册后可以忘掉这个事情（对象为弱引用，handler为强引用），不影响GC.
-- 
-- 同一个对象两次注册，第二次会覆盖第一次。
-- 
-- @param receiver 接收消息的对象。必须是一个引用类型的lua object。
-- @param #function handler 处理所有消息的事件回调函数。类型：```message -> data -> message_result```。
-- message_result通常是nil。对于需要返回值的消息，才需要返回```message_result```。 
M.registerReceiver = function (receiver, handler)
    receivers[receiver] = handler
end

---
-- 移除receiver的注册信息。
-- @param receiver 消息接收对象。
M.unregisterReceiver = function (receiver)
    receivers[receiver] = nil
end

local function processMessageImmediately(receiver, message, param, handler)
    local receiverFn = receivers[receiver]    
    if receiverFn then    
        local result = receiverFn(message, param)    
        if handler then
            handler(result)
        end        
    end    
end

---
-- 立即发送消息给receiver，并让handler立即处理并返回.
-- 
-- 整个过程是同步的。
-- 
-- @param receiver 消息接收对象。若未注册，则不发送。
-- @param message 消息。
-- @param param 消息参数。
-- @param #function  handler 接收消息返回值的函数。如果消息有接收对象，并且成功返回，则调用```handler(message_result)```，其中，```message_result```为消息处理器返回的值。
M.sendMessage = function (receiver, message, param, handler)
    processMessageImmediately(receiver,message,param,handler)
end

---
-- 发送消息给receiver，并让handler处理并返回.
-- 
-- 整个过程是异步的。可能会持续好几帧。
-- 
-- 消息被处理以后会从消息队列中移除。如果消息处理的时找不到receiver，同样消息会被丢弃。
-- 
-- @param receiver 消息接收对象。若未注册，则不发送。
-- @param message 消息。
-- @param param 消息参数。
-- @param #function  handler 接收消息返回值的函数。如果消息有接收对象，并且成功返回，则调用```handler(message_result)```，其中，```message_result```为消息处理器返回的值。
M.postMessage = function (receiver, message, param, handler)
    table.insert(pendingMessages, {receiver, message, param, handler})   
end

local function processMessages()
    for _, v in ipairs(pendingMessages) do
        local receiver = v[1]
        local message = v[2]
        local param = v[3]
        local handler = v[4]
        
        processMessageImmediately(receiver,message,param,handler)                 
    end
     
    pendingMessages = {}
end

Task.runEveryFrames(function ()
    processMessages()
end)
---
-- 同步父节点背景色
M.SynchronizationParentBackgroundColor = 'libutils.messages$$SynchronizationParentBackgroundColor'
---
-- 
M.SettingTheParentNode = 'libutils.messages$$SettingTheParentNode'

return M