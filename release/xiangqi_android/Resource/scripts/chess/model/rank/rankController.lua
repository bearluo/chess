require("config/path_config");

require(BASE_PATH.."chessController");

RankController = class(ChessController);

RankController.s_cmds = 
{	
    onBack = 1;
    getScoreRank = 2;
    getMoneyRank = 3;
};

RankController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end


RankController.resume = function(self)
	ChessController.resume(self);
	Log.i("RankController.resume");
    self:getScoreRank();
    self:getMoneyRank();
end


RankController.pause = function(self)
	ChessController.pause(self);
	Log.i("RankController.pause");
end

RankController.dtor = function(self)

end

RankController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end

-------------------------------- function --------------------------
RankController.getScoreRank = function(self)
    local tips = "正在获取积分排行榜信息...";
	local post_data = {};
	post_data.mid = UserInfo.getInstance():getUid();
    
    HttpModule.getInstance():execute(HttpModule.s_cmds.getScoreRank,post_data,tips);
end

RankController.getMoneyRank = function(self)
	local tips = "正在获取金币排行榜信息...";
	local post_data = {};
	post_data.mid = UserInfo.getInstance():getUid();
    
    HttpModule.getInstance():execute(HttpModule.s_cmds.getMoneyRank,post_data,tips);
end

require("animation/broadcastMessageAnim");
RankController.downLoadImage = function(self , flag,json_data)
	if not json_data then
		return;
	end

	local imageName = json_data.ImageName:get_value();
	if imageName then
		if BroadcastMessageAnim.ICON_IMG ==  string.sub(imageName,1,5) then
			BroadcastMessageAnim.showBroadcastImage1(imageName); 
		else

			print_string("Rank.downLoadImage"  .. imageName);


			--排名的头像名字前缀只有五位
			local rank = string.sub(imageName,6,-1);
			rank = tonumber(rank);
			if not rank or rank < 1 or rank > 20 then
				print_string("not rank or rank < 1 or rank > 20");
				return
			end

            self:updateView(RankScene.s_cmds.updateAdapter,imageName,rank);

		end
	end
end

-------------------------------- http event ------------------------
RankController.getScoreRankCallBack = function(self,isSuccess,message)
    Log.i("RankController.getScoreRankCallBack");
    if not isSuccess then
        return ;
    end
    local data = message.data;

	if not data then
		print_string("not data");
		return
	end

	if #data <= 0 then
		print_string("not datas");
		return
	end


	local ranks  = {}

	for _,value in pairs(data) do 
		local user = {};
		user.rank     = tonumber(value.rank:get_value()) or 0;
		user.name     = ToolKit.subString(value.mnick:get_value(),16);
		user.bccoins  = tonumber(value.bccoins:get_value()) or 0;
		user.score    = tonumber(value.score:get_value()) or 0;
		user.wintimes = tonumber(value.wintimes:get_value()) or 0;
		user.losetimes= tonumber(value.losetimes:get_value()) or 0;
		user.drawtimes= tonumber(value.drawtimes:get_value()) or 0;
		user.icon     = value.icon:get_value();
		user.isweibo  = tonumber(value.isweibo:get_value()) or 0;
		user.usertype = tonumber(value.usertype:get_value()) or 0;

		--暂时用不上
		user.money    = tonumber(value.money:get_value()) or 0;
		user.level    = tonumber(value.level:get_value()) or 0;
		user.mid      = tonumber(value.mid:get_value()) or 0;
		user.sitemid  = value.sitemid:get_value();

		table.insert(ranks,user);

	end
    if #ranks > 0 then
        self:updateView(RankScene.s_cmds.showScoreRank,ranks);
    end
end

RankController.getMoneyRankCallBack = function(self,isSuccess,message)
    Log.i("RankController.getScoreRankCallBack");
    if not isSuccess then
        return ;
    end
    local data = message.data;

	if not data then
		print_string("not data");
		return
	end

	if #data <= 0 then
		print_string("not datas");
		return
	end


	local ranks  = {}

	for _,value in pairs(data) do 
		local user = {};
		user.rank     = tonumber(value.rank:get_value()) or 0;
		user.name     = ToolKit.subString(value.mnick:get_value(),16);
		user.money    = tonumber(value.money:get_value()) or 0;
		user.mid      = tonumber(value.mid:get_value()) or 0;
		user.sitemid  = value.sitemid:get_value() or "";
		user.icon     = value.icon:get_value() or "";
		user.isweibo  = tonumber(value.isweibo:get_value()) or 0;
		user.usertype = tonumber(value.usertype:get_value()) or 0;
		table.insert(ranks,user);

	end
    if #ranks > 0 then
        self:updateView(RankScene.s_cmds.showMoneyRank,ranks);
    end
end

-------------------------------- config ----------------------------

RankController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.getScoreRank] = RankController.getScoreRankCallBack;
    [HttpModule.s_cmds.getMoneyRank] = RankController.getMoneyRankCallBack;
};

RankController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	RankController.s_httpRequestsCallBackFuncMap or {});


--本地事件 包括lua dispatch call事件
RankController.s_nativeEventFuncMap = {
    [kDownLoadImage] = RankController.downLoadImage;
};


RankController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	RankController.s_nativeEventFuncMap or {});



RankController.s_socketCmdFuncMap = {
--	[HALL_SINGLE_BROADCARD_CMD_MSG]  = RankController.onSingleBroadcastCallback;
}

RankController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	RankController.s_socketCmdFuncMap or {});


------------------------------------- 命令响应函数配置 ------------------------
RankController.s_cmdConfig = 
{
    [RankController.s_cmds.onBack] = RankController.onBack;
    [RankController.s_cmds.getScoreRank] = RankController.getScoreRank;
    [RankController.s_cmds.getMoneyRank] = RankController.getMoneyRank;
    
    
}


