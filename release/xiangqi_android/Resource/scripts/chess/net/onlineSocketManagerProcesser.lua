require("libs/json_wrap");
require(NET_PATH.."common/commonSocketCmd");
require("gameBase/socketProcesser");


OnlineSocketManagerProcesser = class(SocketProcesser,false);


OnlineSocketManagerProcesser.ctor = function(self)
    super(self,self)
    self.m_severCmdEventFuncMaps = {}
end 

function OnlineSocketManagerProcesser.getInstance()
    if not OnlineSocketManagerProcesser.s_instance then
        OnlineSocketManagerProcesser.s_instance = new(OnlineSocketManagerProcesser)
    end
    return OnlineSocketManagerProcesser.s_instance
end

function OnlineSocketManagerProcesser:register(cmd,obj,func)
    if not self.m_severCmdEventFuncMaps[cmd] then self.m_severCmdEventFuncMaps[cmd] = {} end
    local insertTab = {}
    insertTab.obj = obj
    insertTab.func = func
    table.insert(self.m_severCmdEventFuncMaps[cmd],insertTab)
end

function OnlineSocketManagerProcesser:unregister(cmd,obj,func)
    if not self.m_severCmdEventFuncMaps[cmd] then return end
    for i,v in pairs(self.m_severCmdEventFuncMaps[cmd]) do
        if v and v.func == func and v.obj == obj then
           self.m_severCmdEventFuncMaps[cmd][i] = nil
           break
        end
    end
end

--[Comment]
-- 重载socket 响应 做注册响应制度
OnlineSocketManagerProcesser.onReceivePacket = function(self,cmd,packetInfo)
    if not packetInfo then return end
    if type(self.m_severCmdEventFuncMaps[cmd]) == "table" and next(self.m_severCmdEventFuncMaps[cmd]) then
        for i,v in pairs(self.m_severCmdEventFuncMaps[cmd]) do
            if v and type(v.func) == "function" then
                v.func(v.obj,packetInfo)
            end
        end
    end
end