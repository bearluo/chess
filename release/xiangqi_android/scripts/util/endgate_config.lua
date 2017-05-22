require("dialog/leave_tips_dialog");

EndGateConfig = {};

EndGateConfig.ctor = function (self,obj)
	print_string("EndGateConfig.ctor");
	self.m_obj = obj;
end

EndGateConfig.dtor = function(self)
	print_string("EndGateConfig.dtor");
end

EndGateConfig.getInstance = function ()
	if not EndGateConfig.s_instance then
		EndGateConfig.s_instance = new(EndGateConfig);
	end
	return EndGateConfig.s_instance;
end

EndGateConfig.setChallengReward = function(self,reward)
	self.m_reward = reward;
end

EndGateConfig.getChallengReward = function(self)
	return self.m_reward;
end

EndGateConfig.setEngateDailyWork = function(self,num)
	self.m_engate_num = num;
end

EndGateConfig.getEngateDailyWork = function(self)
	return self.m_engate_num or 0;
end

EndGateConfig.getEngateDailyWorkProgress = function(self)
    local  uid = UserInfo.getInstance():getUid();
    local engate_progress = GameCacheData.getInstance():getInt(GameCacheData.ENDGATE_PLAY_COUNT..uid,0);
	return engate_progress or 0;
end

EndGateConfig.leaveTipsDialog = nil;
EndGateConfig.retentionTips = function(self,model,exitCallback)
	if EndGateConfig.leaveTipsDialog then
		EndGateConfig.leaveTipsDialog:dismiss();
		EndGateConfig.leaveTipsDialog = nil;
	end

	local  uid = UserInfo.getInstance():getUid();
    local is_reward =  GameCacheData.getInstance():getBoolean(GameCacheData.IS_ENDGATE_PLAY_REWARD..uid,true);

	if not is_reward then --还没领取奖励
		local num = self:getEngateDailyWorkProgress();
		local engate_num = self:getEngateDailyWork();
		local leftnum = engate_num - num;

		if	leftnum>0 then

			local msg = "再挑战"..leftnum.."局，就可获得任务奖励，确定要退出吗？";
			local isLeaveGame = false;
			EndGateConfig.leaveTipsDialog = new(LeaveTipsDialog,isLeaveGame);

			EndGateConfig.leaveTipsDialog:setMessage(msg);
			EndGateConfig.leaveTipsDialog:setExitListener(model,exitCallback)
			EndGateConfig.leaveTipsDialog:setCancelListener(model,EndGateConfig.cancel)
			EndGateConfig.leaveTipsDialog:show(model.m_root_view);
			return;
		end
	end

	local msg = "玩残局有机会获得棋魂并兑换实物，确定要退出吗？";
	local isLeaveGame = false;
	EndGateConfig.leaveTipsDialog = new(LeaveTipsDialog,isLeaveGame);
	EndGateConfig.leaveTipsDialog:setMessage(msg);

	EndGateConfig.leaveTipsDialog:setExitListener(model,exitCallback)
	EndGateConfig.leaveTipsDialog:setCancelListener(model,EndGateConfig.cancel)
	EndGateConfig.leaveTipsDialog:show(model.m_root_view);
	return;
end

EndGateConfig.cancel = function(model)
	EndGateConfig.leaveTipsDialog = nil;
end

EndGateConfig.callsCallBack = function(model)
	EndGateConfig.leaveTipsDialog = nil;
	StateMachine.getInstance():pushState(States.ExchangeMall,StateMachine.STYPE_CUSTOM_WAIT);
end

EndGateConfig.coinsCallBack = function(model)
	EndGateConfig.leaveTipsDialog = nil;	
	UserInfo.getInstance():setIsShowDaliy(true)
end
