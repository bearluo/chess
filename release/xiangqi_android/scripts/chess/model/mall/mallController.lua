require("config/path_config");

require(BASE_PATH.."chessController");

MallController = class(ChessController);

MallController.s_cmds = 
{	
    onBack = 1;
    getPropList = 2;
    getShopInfo = 3;
};

MallController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end


MallController.resume = function(self)
	ChessController.resume(self);
	Log.i("MallController.resume");
    self:getPropList();
    self:getShopInfo();      
    if kPlatform == kPlatformIOS then  
        -- 第三方支付开关，单独控制
        HttpModule.getInstance():execute(HttpModule.s_cmds.appStoreCheckSwitch);
    end;
end


MallController.pause = function(self)
	ChessController.pause(self);
	Log.i("MallController.pause");
end

MallController.dtor = function(self)

end

MallController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end

-------------------------------- father func -----------------------
MallController.updateUserInfoView = function(self)
    self:updateView(MallScene.s_cmds.updateView);
end

-------------------------------- function --------------------------

MallController.getPropList = function(self)
    MallData.getInstance():sendGetPropList();
end

MallController.getShopInfo = function(self)
    MallData.getInstance():sendGetShopInfo();
end

MallController.showTipsDlg = function(self,title,msg)
    ChessDialogManager.dismissDialog();
	self:updateView(MallScene.s_cmds.showTipsDlg,title,msg);	
end
if kPlatform == kPlatformIOS then
    -- ios支付有延迟，加dialog
    MallController.iosIAPLoading = function(self, flag ,json_data)
        if not flag then return end;
        require("dialog/http_loading_dialog");
        local msg = json_data.msg:get_value() or "";
        local cancel = json_data.cancel:get_value();
        if msg and msg ~= "" then
            HttpLoadingDialog.getInstance():dismiss();
            if cancel and tonumber(cancel) ~= 0 then
                ChessToastManager.getInstance():showSingle(msg,3000);
            else
                HttpLoadingDialog.getInstance():setType(1,msg,false);
                HttpLoadingDialog.getInstance():show();
            end
        else
            HttpLoadingDialog.getInstance():dismiss();
        end
    end;

    -- 发货
    MallController.deliverIOSProduct = function(self, flag ,json_data)
        ChessToastManager.getInstance():showSingle("正在为您发货...");
        local data = {};
        data.param = {};
        data.param.pid = json_data.pid:get_value();
        data.param.pdealno = json_data.pdealno:get_value();
        data.param.receipt = json_data.receipt:get_value();
        HttpModule.getInstance():execute(HttpModule.s_cmds.appStorePayOrder, data);
    end;


    MallController.payIOSAppStoreFailed = function(self, data)
        Log.i("MallController.payIOSAppStoreFailed");
        HttpLoadingDialog.getInstance():dismiss();
    end; 
end;
-------------------------------- http event ------------------------

MallController.getPropListCallBack = function(self,isSuccess,message)
    Log.i("MallController.getPropListCallBack");
    local list = ChessController.getPropListCallBack(self,isSuccess,message);
    self:updateView(MallScene.s_cmds.updatePropList,list);
end

MallController.getShopInfoCallBack = function(self,isSuccess,message)
    Log.i("MallController.getShopInfoCallBack");
    local list = ChessController.getShopInfoCallBack(self,isSuccess,message);
    self:updateView(MallScene.s_cmds.updateShopList,list);
end
if kPlatform == kPlatformIOS then
    MallController.onAppStoreCheckSwitchCallBack = function(self, flag, message)
        if not flag then
            if type(message) == "number" then
                return; 
            elseif message.error then
                ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
                return;
            end;        
        end;
        local data = json.analyzeJsonNode(message.data);
        -- -- 微信分享
        -- if data.weixin_share then
        --     UserInfo.getInstance():setThirdShareDapuUrl(data.weixin_share);
        -- end;
        -- -- 活动中心
        -- if data.active_center then
        --     UserInfo.getInstance():setActivityCenter(data.weixin_share);
        -- end;
        -- -- 第三方登录
        -- if data.platform_login then
        --     UserInfo.getInstance():setThirdPartLogin(data.weixin_share);
        -- end;
        -- 第三方支付
        if data.platform_payment then
            UserInfo.getInstance():setThirdPartPay(data.platform_payment);
        end;
        -- -- 游戏链接分享
        -- if data.game_share then
        --     UserInfo.getInstance():setThirdShareGameUrl(data.weixin_share);
        -- end;
        -- -- ios总开关（后续会合并上面的开关）
        -- if data.ios_audit_status then
        --     UserInfo.getInstance():setIosAuditStatus(data.ios_audit_status);
        -- end;   
    end
end;
-------------------------------- config ----------------------------

MallController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.getPropList]            = MallController.getPropListCallBack;
    [HttpModule.s_cmds.getShopInfo]            = MallController.getShopInfoCallBack;
    [HttpModule.s_cmds.appStoreCheckSwitch]    = MallController.onAppStoreCheckSwitchCallBack;
};

MallController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	MallController.s_httpRequestsCallBackFuncMap or {});


--本地事件 包括lua dispatch call事件
MallController.s_nativeEventFuncMap = {
    [SOUL_NOT_ENOUGH_FOR_COST] = MallController.showTipsDlg;
    [kIOSLoading]              = MallController.iosIAPLoading;
    [kDeliverIOSProduct]       = MallController.deliverIOSProduct;
    [kPayIOSAppStoreFail]      = MallController.payIOSAppStoreFailed;
};


MallController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	MallController.s_nativeEventFuncMap or {});



MallController.s_socketCmdFuncMap = {
--	[HALL_SINGLE_BROADCARD_CMD_MSG]  = MallController.onSingleBroadcastCallback;
}

MallController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	MallController.s_socketCmdFuncMap or {});


------------------------------------- 命令响应函数配置 ------------------------
MallController.s_cmdConfig = 
{
    [MallController.s_cmds.onBack] = MallController.onBack;
    [MallController.s_cmds.getPropList] = MallController.getPropList;
    [MallController.s_cmds.getShopInfo] = MallController.getShopInfo;
}


