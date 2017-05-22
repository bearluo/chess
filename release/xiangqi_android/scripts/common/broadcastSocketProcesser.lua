require("gameBase/socketProcesser");
require("libs/json");
require("core/global");
require("gameData/loginInfo");
require("gameData/userData");
require("onlineSocket/commonSocketCmd");
require("gameData/levelMedalConfig");
require("animation/alarmNoticeAnim");


BroadcastSocketProcesser = class(SocketProcesser)

BroadcastSocketProcesser.s_changeMoney = EventDispatcher.getInstance():getUserEvent();
BroadcastSocketProcesser.serverDispatch = EventDispatcher.getInstance():getUserEvent();

BroadcastSocketProcesser.onSingleBroadcastResponse = function(self,info)
	Log.i("BroadcastSocketProcesser.onSingleBroadcastResponse");
    if not info then
        return;
    end 
	Log.i("BroadcastSocketProcesser.onSingleBroadcastResponse："..json.encode(info));
	if info.msgtype == 2 then
		local msg = "你购买的"..info.buynum.."金币到帐！";
		local textView = UIFactory.createText(msg,30,200,50,kAlignLeft,245,245,245,"");
		ToastShade.getInstance():play(textView,550,200,false,nil,nil,3000);
        
	elseif info.msgtype == 3 then
		if info.msg and info.msg ~= "" then
            local msg = json.decode_node(info.msg or "");
            local money = msg.money:get_value();
            local hcard = msg.hcard:get_value();
            local msgString = msg.msg:get_value() or "";
            if kUserData:getCurState() == ROOM_STATE then
                if kUserData:getRemainCoin() < tonumber(money) or kUserData:getHcard(hcard) < tonumber(hcard)then
                    if msgString ~= nil then
                        AlarmNotice.play(msgString,nil,110,nil,-110,nil,nil,nil);
                    end
                end
                local matchType = RoomConfig.getRoomDataByLevel(RoomConfig.getCurRoomLevel()).matchType;
                if matchType == 1 then
                    kUserData:setRemainCoin(tonumber(money)-kUserData:getHealth());
                else
                    kUserData:setRemainCoin(tonumber(money));
                end
                
            else
                if kUserData:getTotalMoney() < tonumber(money) or kUserData:getHcard(hcard) < tonumber(hcard)then
                    if msgString ~= nil then
                        AlarmNotice.play(msgString,nil,110,nil,-110,nil,nil,nil);
                    end
                end
                kUserData:setTotalMoney(tonumber(money));
            end
            kUserData:setHcard(hcard);
	    end
	elseif info.msgtype == 4 then --有新的个人消息
        Log.i("BroadcastSocketProcesser.onSingleBroadcastResponse");
        local param_data = {};
        Log.i("BroadcastSocketProcesser.onSingleBroadcastResponse execute HttpModule.s_cmds.getMessage");
        HttpModule.getInstance():execute(HttpModule.s_cmds.getMessage, param_data, false, false);
    elseif info.msgtype == 5 then --有新的反馈客服回复
        if info.msg and info.msg ~= "" then
            local msg = json.decode_node(info.msg or "");
            local feedBackNum = msg.feedBackNum:get_value() or 0;
            kUserData:setFeedBackNum(feedBackNum);
            EventDispatcher.getInstance():dispatch(HallController.s_feedBackNumEvent);
        end
    elseif info.msgtype == 6 then       --开赛广播
        local msg = json.decode_node(info.msg or "");
        local loop = tonumber(msg.loop:get_value() or "0");
        local jump = json.decode_node(msg.jump:get_value() or "");
        local level = tonumber(jump.level:get_value());
        local roomData = RoomConfig.getRoomDataByLevel(level);
        --local startTime = os.date("%H:%M:%S",jump.start_time:get_value());
        local remainTime = tonumber(jump.remain_time:get_value());

        local timeString = "";
        if remainTime > 3600 then
            local hour = math.floor(remainTime / 3600);
            timeString = tostring(hour).."小时";
        elseif remainTime > 60 then
            local minute = math.floor(remainTime / 60);
            timeString = tostring(minute).."分钟";
        else
            timeString = tostring(remainTime).."秒";
        end
        
        local roomTemplate = string.gsub(roomData.template, "#begin#", timeString);
        AnimBroadcast.play(roomTemplate,loop,nil,nil);
        return;
    elseif info.msgtype == 7 then -- 断线重连 拉场
        if info.msg and info.msg ~= "" then
            local msg = json.decode_node(info.msg or "");
            local data = {};
            data.msgtype = info.msgtype;
            data.level = msg.level:get_value() or 0;
            data.time = msg.time:get_value() or 0;
            data.matchID = msg.match_id:get_value() or 0;
            EventDispatcher.getInstance():dispatch(BroadcastSocketProcesser.serverDispatch,data);
        end
    else
		local msg = info.msg or "";
		--local textView = UIFactory.createText(msg,30,200,50,kAlignLeft,245,245,245,"");
		--ToastShade.getInstance():play(textView,550,200,false,nil,nil,3000);
	end
	
	self.m_controller:handleSocketCmd(HALL_SINGLE_BROADCARD_CMD_MSG,info);

  	if self.m_socket and self.m_socket:isSocketOpen() then
  		local info = {};
  		info.uid = kUserData:getUid();
  		Log.i("===info.uid==="..info.uid);
  		self.m_socket:sendMsg(RESPONSE_SINGLE_BROADCAST_CMD,info);
  	end
end

BroadcastSocketProcesser.onAllBroadcastResponse = function(self,info)
	Log.i("BroadcastSocketProcesser.onAllBroadcastResponse");

	local msg = json.decode_node(info.msg or "");
    local msgType = tonumber(msg.type:get_value() or 0);
    local msgString = msg.msg:get_value();
    local loop = tonumber(msg.loop:get_value() or 1);
    local jump = msg.jump or "";

    if kUserData:getCurState() ~= HALL_STATE then     --在大厅内,字符串解析
        s = string.gsub("Lua is good [ 123 ]", "%[.%]", "bad")
    end

    if msgType == 1 then        --系统广播，不跳转
        AnimBroadcast.play(msgString,loop,nil,nil);
        return;
    elseif msgType == 2 then    --比赛广播，可跳转
        AnimBroadcast.play(msgString,loop,BroadcastSocketProcesser.onMatchClick,BroadcastSocketProcesser);
        kUserData:setBroadcastMatchLevel(jump.level:get_value() or 0);
        kUserData:setBroadcastMatchType(jump.matchType:get_value() or 0);
        return;
    elseif msgType == 3 then    --活动广播，可跳转
        AnimBroadcast.play(msgString,loop,BroadcastSocketProcesser.onActivityShowClick,BroadcastSocketProcesser);
        return;
    elseif msgType == 4 then    --获奖广播，不跳转
        AnimBroadcast.play(msgString,loop,nil,nil);
        return;
    elseif msgType == 5 then    --兑换广播，可跳转
        AnimBroadcast.play(msgString,loop,BroadcastSocketProcesser.onExchangeClick,BroadcastSocketProcesser);
        return;
    else
        return info;
    end
end

BroadcastSocketProcesser.onExchangeClick = function()
    if kUserData:getCurState() == HALL_STATE then     --在大厅内则跳转
        UBReport.getInstance():report(UBConfig.KHallExchangeMallBtnID);
	    StateMachine.getInstance():pushState(States.ExchangeMallState,StateMachine.STYPE_CUSTOM_WAIT);	
    end
end

BroadcastSocketProcesser.onMatchClick = function()
	if kUserData:getCurState() == HALL_STATE then
        EventDispatcher.getInstance():dispatch(HallController.s_broadcastMatchEvent);
    end
end

BroadcastSocketProcesser.onActivityShowClick = function()
	if kUserData:getCurState() == HALL_STATE then
        EventDispatcher.getInstance():dispatch(HallController.s_activityEvent);
    end
end
BroadcastSocketProcesser.s_severCmdEventFuncMap = {
	[HALL_SINGLE_BROADCARD_CMD_MSG] 			= BroadcastSocketProcesser.onSingleBroadcastResponse;
	[HALL_ALL_BROADCARD_CMD_MSG] 				= BroadcastSocketProcesser.onAllBroadcastResponse;
};


-- BroadcastSocketProcesser.s_commonCmdHandlerFuncMap = {
-- 	[HALL_SINGLE_BROADCARD_CMD_MSG] 			= BroadcastSocketReader.onSingleBroadcastResponse;
-- 	[HALL_ALL_BROADCARD_CMD_MSG] 			= BroadcastSocketReader.onAllBroadcastResponse;
-- };


-- BroadcastSocketProcesser.s_commonCmdHandlerFuncMap = CombineTables(BroadcastSocketProcesser.s_commonCmdHandlerFuncMap,
-- 	BroadcastSocketProcesser.s_commonCmdHandlerFuncMap or {});