require("core/object");

SocketWriter = class();

SocketWriter.ctor = function(self)
	self.m_socket = nil;	-- 操作的套接字
end

SocketWriter.writePacket = function(self, socket, packetId, cmd, info)
	self.m_socket = socket;

	if self.s_clientCmdFunMap[cmd] then
		self.s_clientCmdFunMap[cmd](self,packetId,info);
		return true;
	end

	return false;
end

SocketWriter.s_clientCmdFunMap = {
};