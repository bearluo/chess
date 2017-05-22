require("core/object");

SocketReader = class();

SocketReader.ctor = function(self)
	self.m_socket = nil;	-- 操作的套接字
end

SocketReader.readPacket = function(self, socket, packetId, cmd)
	self.m_socket = socket;

	local packetInfo = nil;
	
	if self.s_severCmdFunMap[cmd] then
		packetInfo = self.s_severCmdFunMap[cmd](self,packetId);
	end 
	
	return packetInfo;
end

SocketReader.s_severCmdFunMap = {

};