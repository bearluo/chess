--require("php/phpSocketWriter");
require(NET_PATH.."common/commonSocketCmd");
require("gameBase/socketWriter");

CommonSocketWriter = class(SocketWriter);

CommonSocketWriter.onSendBankruptConfig = function(self,packetId)
end 

CommonSocketWriter.onSendBankruptCount = function(self,packetId,userId)
	self.m_socket:writeInt(packetId,userId);
end

CommonSocketWriter.onSendBankruptMoney = function(self,packetId,userId)
	self.m_socket:writeInt(packetId,userId);
end

CommonSocketWriter.onSendLoginCommon = function(self,packetId,info)
	self.m_socket:writeInt(packetId,info.userId); --UserID	用户ID	Int	4
	self.m_socket:writeShort(packetId,info.isOnline);--isOnline		short	2
	self.m_socket:writeShort(packetId,info.pid);--terminalType	设备号	short	2
	self.m_socket:writeInt(packetId,info.versioncode);--version	版本号	int	
	self.m_socket:writeShort(packetId,info.sid);--sid	short	2
	self.m_socket:writeShort(packetId,info.bid);--bid	short	2

end

CommonSocketWriter.onSendStatisInfo = function(self,packetId,info)
	self.m_socket:writeString(packetId,json.encode(info)); --UserID	用户ID	Int	4
end

CommonSocketWriter.s_clientCmdFunMap = {
--	[SEND_BANKRUPT_CONFIG]			= CommonSocketWriter.onSendBankruptConfig;
--	[SEND_BANKRUPT_COUNT]			= CommonSocketWriter.onSendBankruptCount;
--	[SEND_BANKRUPT_MONEY]			= CommonSocketWriter.onSendBankruptMoney;
--	[HALL_LOGIN_CMD_MSG] 				= CommonSocketWriter.onSendLoginCommon;
--	[HALL_STATIS_DEVICE_INFO] 				= CommonSocketWriter.onSendStatisInfo;
};

--[[
CommonSocketWriter.s_clientCmdFunMap = CombineTables(CommonSocketWriter.s_clientCmdFunMap,
	PhpSocketWriter.s_clientCmdFunMap or {});
		--]]
				CommonSocketWriter.s_clientCmdFunMap = CombineTables(CommonSocketWriter.s_clientCmdFunMap,
	{});

	