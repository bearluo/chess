require("core/object");

SocketProcesser = class();

SocketProcesser.ctor = function(self,controller)
	self.m_controller = controller;
end 

SocketProcesser.setSocketManager = function(self, socketManager)
	self.m_socket = socketManager;
end

SocketProcesser.onReceivePacket = function(self,cmd,packetInfo)
    if self.s_severCmdEventFuncMap[cmd] then
        local info = self.s_severCmdEventFuncMap[cmd](self,packetInfo);
        return info or {};
    end
    return nil;
end

SocketProcesser.onCommonCmd = function(self,cmd,...)
	if self.s_commonCmdHandlerFuncMap[cmd] then
        local info = self.s_commonCmdHandlerFuncMap[cmd](self,...);
        return true;
    end
    return false;
end

SocketProcesser.s_severCmdEventFuncMap = {    
	
};

SocketProcesser.s_commonCmdHandlerFuncMap = {
	
};


