--SystemNoticeLog.lua
--Date 16/12/26
--  系统小喇叭


SystemNotice = {}

function SystemNotice.getInstance()
    if not SystemNotice.instance then
        SystemNotice.instance = new(SystemNotice);
    end
    return SystemNotice.instance;
end

function SystemNotice.release()
    delete(SystemNotice.instance)
    SystemNotice.instance = nil
end

function SystemNotice.ctor(self)
    self.systemNoticeLog = {}

end

function SystemNotice.dtor(self)
    delete(self.systemNoticeLog)
    self.systemNoticeLog = nil
end

function SystemNotice.saveNotice(self,data)
    if not self.systemNoticeLog then
        self.systemNoticeLog = {}
    end
    if not data then return end
--    local msgid = data.msg_id or 0
--    self.systemNoticeLog[msgid .. ""] = data
    self:resortNotice(data)
    EventDispatcher.getInstance():dispatch(Event.Call,kGetSystemNoticeMsg,data)
end

--系统消息不超过300条
function SystemNotice.resortNotice(self,data)
    if #self.systemNoticeLog >= 300 then
        table.remove(self.systemNoticeLog,1)
        
    end
    table.insert(self.systemNoticeLog,data)
end

function SystemNotice.getHistoryNotice(self)
    return self.systemNoticeLog or {}
end

function SystemNotice.getNoticeById(self,id)
    if not id or not self.systemNoticeLog then return end
end

function SystemNotice.getHistoryMsgByTime(self,roomid,time)
    if not self.systemNoticeLog then return {} end
    local msgTab = {}
    if next(self.systemNoticeLog) then
        for i = #self.systemNoticeLog , 1, -1 do 
            if self.systemNoticeLog[i] and self.systemNoticeLog[i].time < time then
                table.insert(msgTab,self.systemNoticeLog[i])
            end;
            if #msgTab == 15 then
                return msgTab
            end
        end
        return msgTab
    end
end

function SystemNotice.getLastMsgByTime(self)
    if not self.systemNoticeLog then return {} end
    local tab = self.systemNoticeLog[#self.systemNoticeLog] or {}
    return tab
end

function SystemNotice.setMyLastMsgTime(self,time)
    self.sendMsgTime = time or 0
end

function SystemNotice.getMyLastMsgTime(self)
    return self.sendMsgTime or 0
end
