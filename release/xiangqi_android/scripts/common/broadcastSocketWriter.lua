require("gameBase/socketWriter");
require("onlineSocket/commonSocketCmd");
require("util/log");
require("gameData/roomConfig"); 


BroadcastSocketWriter = class(SocketWriter);


BroadcastSocketWriter.onSendBroadcastResponse = function(self,packetId,info)
	Log.i("BroadcastSocketWriter.onSendBroadcastResponse");
	self.m_socket:writeInt(packetId,info.uid);
end

BroadcastSocketWriter.s_clientCmdFunMap = {
	[RESPONSE_SINGLE_BROADCAST_CMD] = BroadcastSocketWriter.onSendBroadcastResponse;

};
