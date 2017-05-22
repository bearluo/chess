require("gameBase/socketReader");
require("onlineSocket/commonSocketCmd");
require("animation/animBroadcast");

BroadcastSocketReader = class(SocketReader);


BroadcastSocketReader.onSingleBroadcastResponse = function(self,packetId,info)
	Log.i("BroadcastSocketReader.onSingleBroadcastResponse");

	local info = {};

	info.type = self.m_socket:readShort(packetId,-1); --	广播类型 	short	2
	local msg = self.m_socket:readString(packetId); --广播信息 	String	

	local json_data = json.decode_node(msg);
	local msgtype = tonumber(json_data.msgtype:get_value()) or 0;
	info.msgtype = msgtype;

	if msgtype == 1 then --定时排名奖励
		info.rank = tonumber(json_data.rank:get_value()) or 0;-- money:当前金币
		info.reward = tonumber(json_data.reward:get_value()) or 0;-- hcard:当前haocard

		Log.i("====info.rank===="..info.rank);
		Log.i("====info.reward===="..info.reward);


	elseif msgtype == 2 then --msgtype：消息类型 1表示定时排名奖励推送信息，2表示购买金币推送信息，3...
		local pdealno = json_data.pdealno:get_value() or "";-- pdealno:订单编号
		local money = tonumber(json_data.money:get_value()) or 0;-- money:当前金币
		local buynum = tonumber(json_data.buynum:get_value()) or 0;-- buynum:购买金币数

		info.pdealno = pdealno;
		info.money = money;
		info.buynum = buynum;
		Log.i("====info.buynum===="..info.buynum);
		Log.i("====info.money===="..info.money);
		Log.i("====info.pdealno===="..info.pdealno);

		kUserData:setMoney(info.money);
	elseif msgtype == 3 then
		local msg = json_data.msg:get_value() or "";-- msg:
		local money = tonumber(json_data.money:get_value()) or 0;-- money:当前金币
		local hcard = tonumber(json_data.hcard:get_value()) or 0;-- hcard:当前haocard

		info.msg = msg;
		info.money = money;
		info.hcard = hcard;

		Log.i("====info.msg===="..info.msg);
		Log.i("====info.money===="..info.money);
		Log.i("====info.hcard===="..info.hcard);

		kUserData:setMoney(info.money);
		kUserData:setHcard(info.hcard);
    elseif msgtype == 4 then
        local param_data = {};
        HttpModule.getInstance():execute(HttpModule.s_cmds.getMessage, param_data, false);
	else
		info.msg = msg;
	 end

	return info;
end

BroadcastSocketReader.onAllBroadcastResponse = function(self,packetId,info)
	Log.i("BroadcastSocketReader::onAllBroadcastResponse");

	local info = {};
	info.type = self.m_socket:readShort(packetId,-1); --	广播类型 	short	2
	info.msg = self.m_socket:readString(packetId); --广播信息 	String	

    return info;
end

BroadcastSocketReader.s_severCmdFunMap = {
	--[HALL_SINGLE_BROADCARD_CMD_MSG] 			= BroadcastSocketReader.onSingleBroadcastResponse;
	[HALL_ALL_BROADCARD_CMD_MSG] 			= BroadcastSocketReader.onAllBroadcastResponse;
};


