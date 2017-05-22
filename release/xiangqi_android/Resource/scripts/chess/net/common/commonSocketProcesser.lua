require("libs/json_wrap");
require(NET_PATH.."common/commonSocketCmd");
require("gameBase/socketProcesser");


CommonSocketProcesser = class(SocketProcesser);

CommonSocketProcesser.onCommonMsgLogin = function(self,packetInfo)

end

CommonSocketProcesser.s_severCmdEventFuncMap = {
};

	
CommonSocketProcesser.s_severCmdEventFuncMap = CombineTables(CommonSocketProcesser.s_severCmdEventFuncMap,
	{});
