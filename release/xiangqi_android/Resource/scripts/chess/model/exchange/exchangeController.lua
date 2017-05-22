require("config/path_config");

require(BASE_PATH.."chessController");
require("animation/broadcastMessageAnim");

ExchangeController = class(ChessController);

ExchangeController.s_cmds = 
{	
    onBack = 1;
};

ExchangeController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end


ExchangeController.resume = function(self)
	ChessController.resume(self);
    self:getSoulList();
end


ExchangeController.exit_action = function(self)
end

ExchangeController.pause = function(self)
	ChessController.pause(self);
	Log.i("ExchangeController.pause");
end

ExchangeController.dtor = function(self)

end

ExchangeController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end

-------------------------------- function --------------------------

ExchangeController.getSoulList = function(self)
    local Soul_Version = 0;
	local post_data = {};
	post_data.method = PhpConfig.METHOD_GETSOULLIST;
	post_data.version = Soul_Version;

	HttpModule.getInstance():execute(HttpModule.s_cmds.getSoulList,post_data);
end

ExchangeController.showTipsDlg = function(self,title,msg)
    ChessDialogManager.dismissDialog();
	self:updateView(ExchangeScene.s_cmds.showTipsDlg,title,msg);	
end

ExchangeController.showInputDlg = function(self,goods)
    ChessDialogManager.dismissDialog();
	self:updateView(ExchangeScene.s_cmds.showInputDlg,goods);	
end

-------------------------------- http event ------------------------

ExchangeController.onGetSoulListResponse = function(self,isSuccess,message)
    Log.i("onGetConsoleProgressResponse");
    if not isSuccess then
        return ;
    end
    local data = message.data;

	if not data then
		return;
	end

	local datalist = {};
	local index = 1;
	for _,value in pairs(data) do 
		local goods = {};
		goods.id =  tonumber(value.id:get_value());
		goods.amount =  tonumber(value.amount:get_value());
		goods.name 	=  value.name:get_value() or "";
		goods.img 	=  value.img:get_value() or "";
		goods.cost 	=  tonumber(value.cost:get_value());
		goods.type 	=  value.type:get_value();
		goods.isExchange = false;
		goods.index = index;
		index = index+1;

		-- print_string("===============goods.id======"..goods.id);
		-- print_string("===============goods.amount======"..goods.amount);
		-- print_string("===============goods.name======"..goods.name);
		-- print_string("===============goods.img======"..goods.img);
		-- print_string("===============goods.cost======"..goods.cost);

		table.insert(datalist,goods);
	end
    self.m_datalist = datalist;
    self:updateView(ExchangeScene.s_cmds.showSoulListView,datalist);
end

ExchangeController.onExchangeSoulResponse = function(self,isSuccess,message)
    print_string("=============onExchangeSoulResponse==========");
	if not isSuccess then
        return ;
    end

	local data = message.data;
	local status =  tonumber(message.status:get_value())
	if not data then
		return;
	end
	
	local retdata = {};
	retdata.status =  status; --: -2库存不足，-1棋魂不足，0兑换失败，1成功 
	retdata.soul =  tonumber(data.soul:get_value());
	retdata.orderno =  data.orderno:get_value() or "";
	retdata.id =  tonumber(data.id:get_value());
	retdata.amount =  tonumber(data.amount:get_value());

	UserInfo.getInstance():setSoulCount(retdata.soul);
    ChessDialogManager.dismissDialog();
    if retdata.status == 1 then --: -2库存不足，-1棋魂不足，0兑换失败，1成功 
		self:updateUserInfoView();
				
		local msg = nil;

		if self.m_datalist  and #self.m_datalist > 0 then
			local len = #self.m_datalist;
			for i=1,len do
				if self.m_datalist[i].id == retdata.id  and self.m_datalist[i].name then
					msg = "恭喜你成功兑换"..self.m_datalist[i].name.."，奖品将于7个工作日内到帐，请耐心等待，如有问题请联系客服。";
					break;
				end
			end
		end
		if not msg then
			msg = "恭喜你成功兑换奖品，奖品将于7个工作日内到帐，请耐心等待，如有问题请联系客服。";
		end

		self:showTipsDlg("兑换成功",msg);
	elseif retdata.status == -2 then
		local msg = "很抱歉，由于库存不足，此次兑换失败，本次操作不扣除棋魂，请下次兑换！";
		self:showTipsDlg("兑换失败",msg);
	elseif retdata.status == -1  then		
		local msg = "很抱歉，您的棋魂不足，以兑换该奖品，玩游戏有几率获得棋魂，赶紧去赚取吧！";
		self:showTipsDlg("兑换失败",msg);		
	elseif retdata.status ==  0  then	
		local msg = "很抱歉，由于网络不稳定，此次兑换失败，本次操作不扣除棋魂，请检查网络异常后重新！";
		self:showTipsDlg("兑换失败",msg);
	end
end
ExchangeController.GOODS_IMG = "GOODS";
-- 下载图片
ExchangeController.downLoadImage = function(self,flag,json_data)
    if not json_data then return end
	local imageName = json_data.ImageName:get_value();
	if imageName then
		if BroadcastMessageAnim.ICON_IMG ==  string.sub(imageName,1,5) then
			BroadcastMessageAnim.showBroadcastImage1(imageName); 
		else
			print_string("ExchangeController.downLoadImage"  .. imageName);

			--排名的头像名字前缀只有五位
			local indexStr = string.sub(imageName,6,-1);
			index = tonumber(indexStr);

			if ExchangeController.GOODS_IMG ==  string.sub(imageName,1,5) then
                self:updateView(ExchangeScene.s_cmds.updateListAdapter,index,imageName);
			end
		end
	end
end


ExchangeController.updateUserInfoView = function(self)
    self:updateView(ExchangeScene.s_cmds.updateUserInfoView);
end
-------------------------------- config ----------------------------

ExchangeController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.getSoulList] = ExchangeController.onGetSoulListResponse;
    [HttpModule.s_cmds.exchangeSoul] = ExchangeController.onExchangeSoulResponse;
};

ExchangeController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	ExchangeController.s_httpRequestsCallBackFuncMap or {});


--本地事件 包括lua dispatch call事件
ExchangeController.s_nativeEventFuncMap = {
    [SOUL_NOT_ENOUGH_FOR_COST] = ExchangeController.showTipsDlg;
    [SHOW_INPUT_TEL_NO] = ExchangeController.showInputDlg;
    [kDownLoadImage] = ExchangeController.downLoadImage;
};


ExchangeController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	ExchangeController.s_nativeEventFuncMap or {});



ExchangeController.s_socketCmdFuncMap = {
--	[HALL_SINGLE_BROADCARD_CMD_MSG]  = ExchangeController.onSingleBroadcastCallback;
}

ExchangeController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	ExchangeController.s_socketCmdFuncMap or {});


------------------------------------- 命令响应函数配置 ------------------------
ExchangeController.s_cmdConfig = 
{
    [ExchangeController.s_cmds.onBack] = ExchangeController.onBack;
}