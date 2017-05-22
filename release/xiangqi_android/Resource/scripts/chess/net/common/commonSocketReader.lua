require(NET_PATH.."common/commonSocketCmd");
require("gameBase/socketReader");

CommonSocketReader = class(SocketReader);

--大厅登录接口
CommonSocketReader.onCommonMsgLogin = function(self,packetId)
    local info = {};
	Log.i("==========CommonSocketReader.onSignUpRespone============");
    
    info.errorCode = self.m_socket:readShort(packetId, -1);
    info.errorMsg = self.m_socket:readString(packetId );
 	info.uid = self.m_socket:readInt(packetId,-1);
 	info.isShow = self.m_socket:readByte(packetId,-1);
 	info.time = self.m_socket:readShort(packetId,-1);

 	--UserInfo.getInstance():setMatchTime(time);
 -- 	print_string("errorCode:" .. errorCode);
	-- print_string("errorMsg:" .. errorMsg );
	-- print_string("uid:" .. uid);
	-- print_string("isShow:" .. isShow);
	-- print_string("time:" .. time);
	print_string("======服务器回应登陆成功======");


	return info;

end

CommonSocketReader.s_severCmdFunMap = {
--	[HALL_MSG_LOGIN]		= CommonSocketReader.onCommonMsgLogin;
};


CommonSocketReader.s_severCmdFunMap = CombineTables(CommonSocketReader.s_severCmdFunMap,
{});
