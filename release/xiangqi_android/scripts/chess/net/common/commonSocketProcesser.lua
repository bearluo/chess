require("libs/json_wrap");
require(NET_PATH.."common/commonSocketCmd");
require("gameBase/socketProcesser");


CommonSocketProcesser = class(SocketProcesser);

CommonSocketProcesser.onCommonMsgLogin = function(self,packetInfo)

end
--CommonSocketProcesser.onClientMsgHeart = function(self)

--    Log.i("CommonSocketProcesser.onClientMsgHeart");

--end;
CommonSocketProcesser.s_severCmdEventFuncMap = {
--	[CLIENT_MSG_HEART]		= CommonSocketProcesser.onClientMsgHeart;
};

	
CommonSocketProcesser.s_severCmdEventFuncMap = CombineTables(CommonSocketProcesser.s_severCmdEventFuncMap,
	{});
