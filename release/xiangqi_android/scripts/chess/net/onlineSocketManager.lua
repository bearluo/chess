require("core/object");
require("core/socket");
require("gameBase/gameSocket");
require(NET_PATH.."common/commonSocketCmd")
require(NET_PATH.."common/commonSocketProcesser")
require(NET_PATH.."common/commonSocketWriter")
require(NET_PATH.."common/commonSocketReader")

OnlineSocketManager = class(GameSocket);

OnlineSocketManager.getHallInstance = function()
	if not OnlineSocketManager.s_hallInstance then 
		OnlineSocketManager.s_hallInstance = new(OnlineSocketManager,kSocketHall,kGameId,nil,kProtocalVersion);
		OnlineSocketManager.s_hallInstance:setHeartBeatCmd(HALL_MSG_HEART);
	end
	return OnlineSocketManager.s_hallInstance;
end


OnlineSocketManager.releaseHallInstance = function()
	delete(OnlineSocketManager.s_hallInstance);
	OnlineSocketManager.s_hallInstance = nil;
end


OnlineSocketManager.ctor = function(self,socketType, gameId, deviceType, ver, subVer)
    --System.setSocketHeaderSize(14);
    --System.setSocketHeaderExtSize(0);   
    
    self.m_reconnectTime = -1;
    self.m_commonProcesser = new(CommonSocketProcesser);
    self.m_commonWriter = new(CommonSocketWriter);
    self.m_commonReader = new(CommonSocketReader);

    self:addCommonSocketReader(self.m_commonReader);
    self:addCommonSocketWriter(self.m_commonWriter);
    self:addCommonSocketProcesser(self.m_commonProcesser);

    require("dialog/http_loading_dialog");
    self.m_loadingDialog = HttpLoadingDialogFactory.createLoadingDialog(HttpLoadingDialog.s_type.Normel,"网络异常,重连中...");
    require("dialog/chioce_dialog");
    self.m_chioce_dialog = new(ChioceDialog);
    self.m_chioce_dialog:setLevel(100);
    self.m_showConectDialogFlag = false;
    self.m_kickUser = false;
end

OnlineSocketManager.dtor = function(self)
	self:removeCommonSocketReader(self.m_commonReader);
	self:removeCommonSocketWriter(self.m_commonWriter);
	self:removeCommonSocketProcesser(self.m_commonProcesser);
	
	delete(self.m_commonProcesser);
	self.m_commonProcesser = nil;
    delete(self.m_commonWriter);
    self.m_commonWriter = nil;
    delete(self.m_commonReader);
    self.m_commonReader = nil;

    delele(self.m_loadingDialog);
    delete(self.m_chioce_dialog);
end

OnlineSocketManager.isSocketOpening = function(self)
	return self.m_isSocketOpening;
end

OnlineSocketManager.sendMsg = function(self, cmd, info, subcmd, writeType)
    if not self:isSocketOpen() then
	    self:openSocket();
        return
    end
	GameSocket.sendMsg(self, cmd, info, subcmd, writeType);
end

OnlineSocketManager.openSocket = function(self)
 	if self:isSocketOpen() or self:isSocketOpening() or self.m_kickUser or HttpModule.m_switchFlag then
		return;
	end
	local ip, port = ServerConfig.getInstance():getHallIpPort();

    if not ip or not port then
        return ;
    end
	Log.i("==ip==="..ip)
	Log.i("==port==="..port)

	self.m_isSocketOpening = true;
--    delete(self.m_opening_anim);
--    self.m_opening_anim = AnimFactory.createAnimInt(kAnimNormal, 0, 1, 2000, -1);
--    self.m_opening_anim:setDebugName("socket opening_anim");
--    self.m_opening_anim:setEvent(self,function(self)
--        self.m_isSocketOpening = false;
--    end);
	if ip and port then
        local evidentConTime, evidentConNum, obscureConTime, obscureConNum = ServerConfig.getInstance():getReconectParam();
        self.m_maxReconnectTime = obscureConNum;
        self.m_timeInterval = obscureConTime*1000;
		GameSocket.openSocket(self,ip,port);
	else
		GameSocket.openSocket(self,1,1);
	end
end

OnlineSocketManager.onKickUser = function(self)
    self:closeSocketSync();
    self.m_kickUser = true;
end

OnlineSocketManager.setKickUser = function(self,flag)
    self.m_kickUser = flag;
end

OnlineSocketManager.closeSocketSync = function(self)
--    self.m_closeType = 1;
    StatisticsUtil.Log (StatisticsUtil.TYPE_NETWORK_NORMAL_OFFLINE,"");
	GameSocket.closeSocketSync(self);
	self.m_isSocketOpening = false;
end

OnlineSocketManager.onSocketClosed = function(self)
	GameSocket.onSocketClosed(self);
	self.m_isSocketOpening = false;
--    if self.m_closeType ~= 1 then
        StatisticsUtil.Log (StatisticsUtil.TYPE_NETWORK_ERROR_OFFLINE,"");
        self:onTimeout();--server断了，重连
--    else
--        StatisticsUtil.Log (StatisticsUtil.TYPE_NETWORK_NORMAL_OFFLINE,"");
--    end
--    self.m_closeType = 0;
end

OnlineSocketManager.createSocket = function(self,socketType, gameId, deviceType, ver, subVer)
	return new(Socket,socketType,PROTOCOL_TYPE_BY14,1,gameId, deviceType, ver, subVer);
end

OnlineSocketManager.getPhpJsonTable = function(self)
	local info = {};
	info.appid = ServerConfig.getInstance():getAppId();
	info.timestamp = os.time();

	return info;
end

OnlineSocketManager.writeBegin = function(self, socket, cmd ,subcmd,writeType)
    local packetId = nil;
    if writeType == 1 then
        packetId = socket:writeBegin(cmd,MAIN_VER, SUB_VER,DEVICE_TYPE);
    elseif writeType == 2 then
        packetId = socket:writeBegin2(cmd,subcmd,MAIN_VER, SUB_VER,DEVICE_TYPE);
    else
        packetId = socket:writeBegin(cmd,MAIN_VER, SUB_VER,DEVICE_TYPE);
    end;
    return packetId;
end 

OnlineSocketManager.writePacket = function(self, socket, packetId, cmd, info)
	return GameSocket.writePacket(self,socket, packetId, cmd, info);
end

OnlineSocketManager.onReceivePacket = function(self, cmd, info)  
	for k,v in pairs(self.m_socketProcessers) do
		local localInfo =  v:onReceivePacket(cmd,info);
		if localInfo then
			return localInfo;
		end
	end

	for k,v in pairs(self.m_commonSocketProcessers) do
		local phpCmd,cmdInfo;
		if cmd == RESPONSE_PHP_REQUEST then
			phpCmd,cmdInfo = v:onReceivePacket(cmd,info);
			return self:onReceivePacket(phpCmd,cmdInfo);
		else
			cmdInfo = v:onReceivePacket(cmd,info);
		end

		if cmdInfo then
			for k,v in pairs(self.m_socketProcessers) do
				if v:onCommonCmd(cmd,unpack(cmdInfo)) then
					break;
				end
			end
			return;
		end
	end

	return false;
end


OnlineSocketManager.onTimeout = function(self)
	GameSocket.onTimeout(self);
    self:closeSocketSync();
    self:openSocket();
	self.m_reconnectTime = 0;
	--self:onReceivePacket(SERVER_OFFLINE_RECONNECT, {});
end 

OnlineSocketManager.onSocketReconnecting = function(self)
    ServerConfig.getInstance():setCurServerLogin(0);
end

OnlineSocketManager.onSocketConnected = function(self)
	self.m_isSocketOpening = false;	
	GameSocket.onSocketConnected(self);
    self.m_loadingDialog:dismiss();
    ServerConfig.getInstance():setCurServerLogin(1);
	self.m_reconnectTime = -1;

	--if ServerConfig.getInstance():isCurPhpLogin()==1 then	
		--handle special condition. when disconnected and engine auto reconnected later,
		-- if we were in room state, we must login hall first which is different from 
		-- normal process.
	Log.d("OnlineSocketManager.onSocketConnected");
	self:onReceivePacket(SERVER_OFFLINE_RECONNECTED,self.m_socket);
	--end 

end 

OnlineSocketManager.onSocketConnectFailed = function(self)	  	
    GameSocket.onSocketConnectFailed(self);
    if self.m_showConectDialogFlag then
        self.m_loadingDialog:show();
    end
    self:startReconnectTimer();
end

OnlineSocketManager.stopReconnectTimer = function(self)
    if self.m_socketRetryAnim then
        delete(self.m_socketRetryAnim);
        self.m_socketRetryAnim = nil;
    end
end
 
OnlineSocketManager.startReconnectTimer = function(self)
    self:stopReconnectTimer();
    self.m_socketRetryAnim = new(AnimInt,kAnimNormal,0,1,self.m_timeInterval,0);
    self.m_socketRetryAnim:setDebugName("GameSocket.m_socketRetryAnim timer");
	self.m_socketRetryAnim:setEvent(self,OnlineSocketManager.onSocketRetryTimer);
end

OnlineSocketManager.onSocketRetryTimer = function(self)
     if self.m_reconnectTime < self.m_maxReconnectTime then 
        Log.i("=======SERVER_OFFLINE_RECONNECT=======");
    	self.m_reconnectTime = self.m_reconnectTime + 1;
        self:closeSocketSync();
        self:openSocket(ServerConfig.getInstance():getHallIpPort());
        self:onReceivePacket(SERVER_OFFLINE_RECONNECT,{});
     else
        Log.i("=========SERVER_OFFLINE=======");
		self.m_reconnectTime = -1;
        self:stopReconnectTimer();
        self:closeSocketSync();
        if self.m_showConectDialogFlag then
            self:showChioceDialog();
        end
		self:onReceivePacket(SERVER_OFFLINE,{});
     end
end

OnlineSocketManager.setShowConnectDialog = function(self,isShow)
    if not isShow then
        self.m_loadingDialog:dismiss();
    end
    self.m_showConectDialogFlag = isShow;
end

OnlineSocketManager.showChioceDialog = function(self)
    self.m_loadingDialog:dismiss();
    local message = "网络异常,连接失败,是否重新连接？";
	self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE);
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:setPositiveListener(self,self.onSocketConnectFailed);
	self.m_chioce_dialog:setNegativeListener(nil,nil);
	self.m_chioce_dialog:show();
end