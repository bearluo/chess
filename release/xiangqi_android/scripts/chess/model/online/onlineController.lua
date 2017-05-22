
require("config/path_config");

require(BASE_PATH.."chessController");
OnlineController = class(ChessController);

OnlineController.s_cmds = 
{	
    back_action         = 1;
    entryRoom           = 2;
    watch_action        = 3;
    challenge           = 4;
    getPrivateRoomNum   = 5;
    private_action      = 6;
    checkBankruptReward = 11;
    getBankruptReward   = 7;
    jumpMall            = 8;
    toFriendScene       = 9; 
    jumpActivity        = 10;
};

OnlineController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
    OnlineSocketManager.getHallInstance():setShowConnectDialog(true);
end

OnlineController.resume = function(self)
    ChessController.resume(self);
    self:loadRoomPlayers();
    self:getPrivateRoomNum();
    self:getFriendGetPlayerInfo();
    self:getMonthCombat();--更新战绩
end;

OnlineController.pause = function(self)
    ChessController.pause(self);
end;

OnlineController.dtor = function(self)
    OnlineSocketManager.getHallInstance():setShowConnectDialog(false);
end;

OnlineController.onBack = function(self)
    if not self:updateView(OnlineScene.s_cmds.closeBankruptDialog) then
        StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);    
    end
end;

--------------------------------function------------------------------------

OnlineController.onEntryRoom = function(self, index, flag)
    UserInfo.getInstance():setGameType(index);
    StateMachine.getInstance():pushState(States.OnlineRoom,StateMachine.STYPE_CUSTOM_WAIT);
end

OnlineController.loadRoomPlayers = function(self)
    self:sendSocketMsg(HALL_MSG_GAMEPLAY,0, SUBCMD_LADDER ,2);
end

OnlineController.onHallMsgGamePlay = function(self, packageInfo)
    Log.i("OnlineController.onHallMsgLogin");
    self:updateView(OnlineScene.s_cmds.update_room_players, packageInfo);
    ProgressDialog.stop();
end

OnlineController.onWatchAction = function(self)
    StateMachine.getInstance():pushState(States.Watch,StateMachine.STYPE_CUSTOM_WAIT);
end

OnlineController.onPrivateAction = function(self)
    StateMachine.getInstance():pushState(States.PrivateHall,StateMachine.STYPE_CUSTOM_WAIT);
end

OnlineController.onChallenge = function(self, post_data)
    self:onCreateFriendRoom(post_data);
end

OnlineController.updateUserInfoView = function (self)
    self:updateView(OnlineScene.s_cmds.refresh_userinfo,true);
end

OnlineController.getPrivateRoomNum = function(self)
    local roomConfig = UserInfo.getInstance():getRoomConfigById(4); -- 私人房
    if roomConfig then
        local info = {};
        info.level = roomConfig.level;
        info.uid = UserInfo.getInstance():getUid();
        self:sendSocketMsg(CLIENT_ALLOC_PRIVATEROOMNUM,info);
    end
end

OnlineController.getMonthCombat = function(self) -- 更新战绩
    local info = {};
    info.mid = UserInfo.getInstance():getUid();
    HttpModule.getInstance():execute(HttpModule.s_cmds.getMonthCombat,info);
end

OnlineController.onHallPrivateRoomNum = function(self,info)
    if info and info.private_room_num then
        self:updateView(OnlineScene.s_cmds.update_private_room_num,info);
    end
end

OnlineController.getFriendGetPlayerInfo = function(self)
    self:sendSocketMsg(FRIEND_CMD_GET_PLAYER_INFO);
end

OnlineController.onHallFriendGetPlayerInfo = function(self,info)
    if info then
        self:updateView(OnlineScene.s_cmds.update_friends_info,info);
    end
end

OnlineController.onGetBankruptReward = function(self)
    local post_data = {};
	post_data.mid = UserInfo.getInstance():getUid();
	post_data.versions = PhpConfig.getVersions();
    local room_level = tonumber(UserInfo.getInstance():getRoomLevel());
    if room_level == 0 or room_level == 320 then
        room_level = 201
    end
    post_data.room_level = room_level;
    HttpModule.getInstance():execute(HttpModule.s_cmds.GetNewBankruptReward, post_data) --, tips);
end

OnlineController.onCheckBankruptReward = function(self)
    local post_data = {};
	post_data.mid = UserInfo.getInstance():getUid();
	post_data.versions = PhpConfig.getVersions();
    local room_level = tonumber(UserInfo.getInstance():getRoomLevel());
    if room_level == 0 or room_level == 320 then
        room_level = 201
    end
    post_data.room_level = room_level;
    HttpModule.getInstance():execute(HttpModule.s_cmds.CheckBankruptReward, post_data) --, tips);
end

function OnlineController:jumpMall(self)
     StateMachine.getInstance():pushState(States.Mall,StateMachine.STYPE_CUSTOM_WAIT);
end

function OnlineController:jumpActivity(self)
     StateMachine.getInstance():pushState(States.activity,StateMachine.STYPE_CUSTOM_WAIT);
end

function OnlineController:toFriendScene(self)
    StateMachine.getInstance():pushState(States.Friends,StateMachine.STYPE_CUSTOM_WAIT);
end
--------------------------------http----------------------------------------

OnlineController.onHttpGetCollapseRewardCallBack = function(self, flag, message)
--    Log.i("OnlineController.onHttpGetCollapseRewardCallBack");
--    if not flag then
--        return;

--    end;
--	if not HttpModule.explainPHPFlag(message) then
--		return;
--	end

--	message = message.data;

--	if not message then
--		print_string("not message");
--		return
--	end  

--	local flag = message.flag:get_value();  --0 不显示（当天已经拿过登陆奖）  1 显示（当天还没拿）
--	if flag == 1 then
--		local data = {};
--		data.remainderTimes = message.remainderTimes:get_value();
--		data.money = message.money:get_value();
--        self:updateView(OnlineScene.s_cmds.online_collapse, data);
--	elseif flag == -3 then
--        self:updateView(OnlineScene.s_cmds.prevent_addicted_collapse);
--	else
--		self:updateView(OnlineScene.s_cmds.online_collapse);
--	end

end;




OnlineController.onHttpGetUserInfoCallBack =  function(self, flag, message)
    if not flag then return; end

    if not flag then
        return;

    end;
    if not HttpModule.explainPHPFlag(message) then
		return;
	end

	message = message.data;

	if not message then
		print_string("not message");
		return
	end  

	local money = message.money:get_value() + 0;
	local bccoins = message.bccoins:get_value() + 0;
	local score = message.score:get_value() + 0;
	local wintimes = message.wintimes:get_value() + 0;
	local losetimes = message.losetimes:get_value() + 0;
	local drawtimes = message.drawtimes:get_value() + 0;
	local designation = message.designation:get_value();

	if money >=  0 then
		local user = UserInfo.getInstance();
		user:setMoney(money);
		user:setBccoin(bccoins);
		user:setScore(score);
		user:setWintimes(wintimes);
		user:setLosetimes(losetimes);
		user:setDrawtimes(drawtimes);
		user:setTitle(designation);

		user:setNeedUpdateInfo(false);
        self:updateView(OnlineScene.s_cmds.refresh_userinfo, true);
	else
   		EventDispatcher.getInstance():dispatch(Event.Call, ONLINE_UPDATE_USERINFO_EVENT);
	end    

end;

OnlineController.onHttpGetBankruptRewardCallBack = function(self, flag, message)
    Log.i("OnlineController.onHttpGetBankruptRewardCallBack");
    if HttpModule.explainPHPMessage(flag, message,"领取失败") then
		return;
	end

    self:updateView(OnlineScene.s_cmds.closeBankruptDialog);
end;

OnlineController.onHttpCheckBankruptRewardCallBack = function(self, flag, message)
    Log.i("OnlineController.onHttpCheckBankruptRewardCallBack");
    if not flag then return end
    
    if not HttpModule.explainPHPFlag(message) then
		return;
	end

    if not message.data then return end
	local messageData = message.data;

    if not messageData.remain_times:get_value() then return end
    if not messageData.add_money:get_value() then return end
    if not messageData.receive_times:get_value() then return end
    if not messageData.recommend_goods:get_value() then return end

    local remain_times = tonumber(messageData.remain_times:get_value()); --补助剩余次数
    local add_money = 0; --补助金币
    if messageData.add_money:get_value() then
        add_money = tonumber( messageData.add_money:get_value());
    end
    local receive_times = tonumber(messageData.receive_times:get_value()); --补助已领取次数
    local shopRecommend = MallData.getInstance():getMallData();
    if not shopRecommend then return end
    local recommend_goods_id = {}; --推荐商品
    for k,v in pairs(messageData.recommend_goods) do
        for i,j in pairs(shopRecommend) do
            if tonumber(v) == j.goods_id then
                table.insert(recommend_goods_id,j);
                break;
            end 
        end
    end

    local data = {};
    data.add_money = add_money;
    data.shopRecommend = recommend_goods_id;
    data.remain_times = remain_times;
    data.receive_times = receive_times;
    self:updateView(OnlineScene.s_cmds.online_collapse, data);
end;




--------------------------------config--------------------------------------

OnlineController.s_cmdConfig = 
{
	[OnlineController.s_cmds.back_action]		            = OnlineController.onBack;
    [OnlineController.s_cmds.entryRoom]		                = OnlineController.onEntryRoom;
    [OnlineController.s_cmds.watch_action]		            = OnlineController.onWatchAction;
    [OnlineController.s_cmds.challenge]		                = OnlineController.onChallenge;
    [OnlineController.s_cmds.private_action]		        = OnlineController.onPrivateAction;
    [OnlineController.s_cmds.getBankruptReward]		        = OnlineController.onGetBankruptReward;
    [OnlineController.s_cmds.checkBankruptReward]		    = OnlineController.onCheckBankruptReward;
    [OnlineController.s_cmds.jumpMall]		                = OnlineController.jumpMall;
    [OnlineController.s_cmds.jumpActivity]		            = OnlineController.jumpActivity;
    [OnlineController.s_cmds.toFriendScene]		            = OnlineController.toFriendScene;

}
OnlineController.s_socketCmdFuncMap = {

    [HALL_MSG_GAMEPLAY]             =  OnlineController.onHallMsgGamePlay;
    [CLIENT_ALLOC_PRIVATEROOMNUM]   =  OnlineController.onHallPrivateRoomNum;
    [FRIEND_CMD_GET_PLAYER_INFO]    =  OnlineController.onHallFriendGetPlayerInfo;
};

OnlineController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.getCollapseReward]    = OnlineController.onHttpGetCollapseRewardCallBack;
    [HttpModule.s_cmds.getUserInfo]          = OnlineController.onHttpGetUserInfoCallBack;
    [HttpModule.s_cmds.GetNewBankruptReward] = OnlineController.onHttpGetBankruptRewardCallBack;
    [HttpModule.s_cmds.CheckBankruptReward]  = OnlineController.onHttpCheckBankruptRewardCallBack;

};

OnlineController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	OnlineController.s_httpRequestsCallBackFuncMap or {});

OnlineController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	OnlineController.s_socketCmdFuncMap or {});