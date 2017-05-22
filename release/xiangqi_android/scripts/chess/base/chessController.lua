--region ChessGameController.lua
--Author : BearLuo
--createDate   : 2015/4/1
--updateDate   : 2015/4/1
--
require("gameBase/gameController");
require("chess/data/terminalInfo");
require("common/httpModule");
require(NET_PATH.."hall/hallSocketCmd");
require(DATA_PATH.."friendsData");
require(UPDATE_PATH.."onlineUpdate");
require(DATA_PATH.."cacheImageManager");

ChessController = class(GameController);

ChessController.ctor = function(self,state,viewClass,viewConfig,...)
    require(NET_PATH.."onlineSocketManager");
    self.m_hallSocket = OnlineSocketManager.getHallInstance();
    self:registerSinalReceiver();
    
end 

ChessController.dtor = function(self)
    self:unregisterSinalReceiver();
    delete(self.m_loginFailDialog);
--    delete(self.m_notice_dialog);
    delete(self.m_toggleAccountDialog);
    delete(self.m_friendChoiceDialog);
end

ChessController.resume = function(self)
	Log.i("ChessController.resume");
    self:addSocketTools();
	EventDispatcher.getInstance():register(Event.Call,self,self.onNativeCallDone);
    EventDispatcher.getInstance():register(Event.RawTouch, self ,self.onRoomTouch);
    EventDispatcher.getInstance():register(Event.Resume,self,self.onEventResume);
    EventDispatcher.getInstance():register(Event.Pause,self,self.onEventPause); 
    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
	GameController.resume(self);
end

ChessController.pause = function(self)
	GameController.pause(self);
    self:removeSocketTools()
	EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeCallDone);
    EventDispatcher.getInstance():unregister(Event.RawTouch , self ,self.onRoomTouch);
    EventDispatcher.getInstance():unregister(Event.Resume,self,self.onEventResume);
    EventDispatcher.getInstance():unregister(Event.Pause,self,self.onEventPause);
    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpRequestsCallBack);
end

ChessController.onEventResume = function(self)
	kMusicPlayer:resume();
end

ChessController.onEventPause = function(self)
    kMusicPlayer:pause();  
end

ChessController.handleSocketCmd = function(self,cmd,...)
	if not self.s_socketCmdFuncMap[cmd] then
		Log.w("Not such socket cmd in current controller");
		return;
	end
	return self.s_socketCmdFuncMap[cmd](self,...);
end

ChessController.onHttpRequestsCallBack = function(self,command,...)
	Log.i("ChessController.onHttpRequestsCallBack");
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self,...);
	end 
end

ChessController.onNativeCallDone = function(self ,param , ...)
	if self.s_nativeEventFuncMap[param] then
		self.s_nativeEventFuncMap[param](self,...);
	end

    if ChessController.s_nativeEventCommonFuncMap[param] then
         ChessController.s_nativeEventCommonFuncMap[param](self,...);
    end
end

ChessController.addSocketTools = function(self)
	Log.i("ChessController.addSocketTools");

	if not self.m_socketProcesser then
        require(NET_PATH.."hall/hallSocketProcesser");
		self.m_socketProcesser = new(HallSocketProcesser,self);
	end
    self.m_hallSocket:addSocketProcesser(self.m_socketProcesser);

	if not self.m_socketWriter then 
        require(NET_PATH.."hall/hallSocketWriter");
		self.m_socketWriter = new(HallSocketWriter);
	end 	
	self.m_hallSocket:addSocketWriter(self.m_socketWriter);
	if not self.m_socketReader then
        require(NET_PATH.."hall/hallSocketReader");
		self.m_socketReader = new(HallSocketReader,self);
	end
    self.m_hallSocket:addSocketReader(self.m_socketReader);
end

ChessController.removeSocketTools = function(self)
	Log.i("ChessController.removeSocketTools");
	self.m_hallSocket:removeSocketProcesser(self.m_socketProcesser);
	delete(self.m_socketProcesser);
	self.m_socketProcesser = nil;


	self.m_hallSocket:removeSocketWriter(self.m_socketWriter);
	delete(self.m_socketWriter);
	self.m_socketWriter = nil;


    self.m_hallSocket:removeSocketReader(self.m_socketReader);
	delete(self.m_socketReader);
	self.m_socketReader = nil;


end 

ChessController.sendSocketMsg = function(self,cmd,info, subcmd, writeType)
    self.m_hallSocket:sendMsg(cmd,info, subcmd, writeType); 
end

ChessController.sendHttpMsg = function(self,cmd,paramData,tip,canCancel,level)
    HttpModule.getInstance():execute(cmd,paramData,tip,canCancel,level);
end

------------------- function -------------------------------------------------

ChessController.openHallSocket = function(self)
    self.m_hallSocket:openSocket(ServerConfig.getInstance():getHallIpPort());
end

ChessController.closeSocket = function(self,isSync)
    if isSync then
        self.m_hallSocket:closeSocketSync();
    else
        self.m_hallSocket:closeSocketAsync();
    end
end

ChessController.isLogined = function(self)
    if not ChessController.m_chioce_dialog then
        require("dialog/chioce_dialog");
        ChessController.m_chioce_dialog = new(ChioceDialog);
        ChessController.m_chioce_dialog:setLevel(1);
    end
    if not UserInfo.getInstance():isLogin() then
		local message = "请先登录...";
		ChessController.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE);
		ChessController.m_chioce_dialog:setMessage(message);
		ChessController.m_chioce_dialog:setPositiveListener(self,self.login);
		ChessController.m_chioce_dialog:setNegativeListener(nil,nil);
		ChessController.m_chioce_dialog:show();
		return false;
	end

	--Socket未登录上
	if not UserInfo.getInstance():getConnectHall() then
		local message = "正在连接游戏大厅...";
		ChessController.m_chioce_dialog:setMode(ChioceDialog.MODE_OK);
		ChessController.m_chioce_dialog:setMessage(message);
		ChessController.m_chioce_dialog:setPositiveListener(self,self.openHallSocket);
		ChessController.m_chioce_dialog:show();
		return false;
	end

	return true;
end


ChessController.dismissDialog = function(self)
    if ChessController.m_chessController_chioce_dialog and ChessController.m_chessController_chioce_dialog:isShowing() then
        ChessController.m_chessController_chioce_dialog:dismiss();
        return true;
    end
    return false;
end


ChessController.login = function(self)
    --积分墙php配置
--    call_native(kGetPhoneInfo);
    self.m_hallSocket:setKickUser(false);
    if "win32"==System.getPlatform() then
        Log.d("*************loginWin32************");
		self:loginWin32();
    elseif "android"==System.getPlatform() then
        Log.d("*************GuestZhLogin************");
        call_native(kGuestZhLogin);  
    elseif "ios" == System.getPlatform() then
        call_native(kIOSGuestZhLogin);
    end
end

ChessController.loginWin32 = function(self)
    Log.i("loginWin32");
    PhpConfig.setLoginType(PhpConfig.TYPE_YOUKE);
    local guid_str = sys_get_string("windows_guid");
	Log.i(guid_str);
	local str = "";
	if guid_str then
		if string.len(guid_str) > 4 then
			str = string.sub(guid_str, 2, 4);
		else
			str = guid_str;
		end
	else
		guid_str = "0";	
	end		
	print_string("guid_str=======================" .. md5_string(guid_str) );
	PhpConfig.setMnick("guest_" .. str);
    if PhpConfig.getImei() == "" then
	    PhpConfig.setImei(guid_str);
    end
	-- PhpConfig.setPlatform(PhpConfig.APPID_HIAPK, PhpConfig.APPKEY_HIAPK,PhpConfig.BID_HIAPK,PhpConfig.SID_91,PhpConfig.TYPE_YOUKE);

	local post_data = {};
    if PhpConfig.getImei() ~= guid_str then
	    post_data.uid = PhpConfig.getImei(); 
	    post_data.new_uuid = PhpConfig.getImei();
    else
	    post_data.uid = md5_string(PhpConfig.getImei());
	    post_data.new_uuid = md5_string(PhpConfig.getImei());
    end
	post_data.mnick = PhpConfig.getMnick();
	post_data.appid = PhpConfig.getAppid();
	post_data.appkey = PhpConfig.getAppKey();
    if isNetworkAvailable and isNetworkAvailable == 0 then
        local jsonString = GameCacheData.getInstance():getString(GameCacheData.FORCEUPDATE,"");
        local updateData = {};
        if jsonString and jsonString ~= "" then
            updateData=json.decode_node(jsonString);
            OnlineUpdate.getInstance():onCheckUpdate(updateData);
        end
    end
    self:sendHttpMsg(HttpModule.s_cmds.LoginWin32,post_data,"登录中...");
end

ChessController.loginGuestZh = function(self,status,json_data)
    Log.i("loginGuestZh");
   -- local json_data1 = {
   --             "imei"="864446029137379","imeiNum"="864446029137379","ip"="172.30.200.174","isNetworkAvailable"="1","mac"="a4:3d:78:1a:9a:3d",
   --             "model"="X9077","name"="X9077","netType"="WIFI","netTypeLevel"="1","new_uuid"="638a2aa5b723a128f0fc29fbb1a02fc0","operator"="","operatorType"="0",
   --             "osinfo"="设备类型:X9077系统版本:4.4.2联网方式:WIFI","pixel"="1440x2560","sdkVersion"="4.4.2","versions"=""
   --         };
    if not status or not json_data then
        return ;
    end
    PhpConfig.setLoginType(PhpConfig.TYPE_YOUKE);
    local new_uuid = json_data.new_uuid:get_value() or "";
	local sitemid = json_data.imei:get_value() or "";
	local mnick = json_data.name:get_value() or "";
	local versions = VERSIONS;
	local osinfo = json_data.osinfo:get_value();
	local pixel = json_data.pixel:get_value() or "";
	-- local imei = json_data.imei:get_value() or "";
	local operator = json_data.operator:get_value() or "";
    local operatorType = json_data.operatorType:get_value() or -1;
    -- 积分墙
    local phoneModel = json_data.model:get_value() or "";
    local phoneSdkVersion = json_data.sdkVersion:get_value() or "";
    local phoneMac = json_data.mac:get_value() or "";
    local phoneNetType = json_data.netType:get_value() or "";
    local phoneNetTypeLevel = json_data.netTypeLevel:get_value() or "-1";
    local phoneIp = json_data.ip:get_value() or "";
    local phoneImei = json_data.imeiNum:get_value() or "";
    local isNetworkAvailable = json_data.isNetworkAvailable:get_value() or 1;
    Log.i("=="..phoneModel.."=="..phoneSdkVersion.."=="..phoneMac.."=="..phoneNetType.."=="..phoneIp.."=="..phoneImei);
    Log.i("new_uuid="..new_uuid);

    PhpConfig.setPhoneType(phoneModel);
    PhpConfig.setOsVersion(phoneSdkVersion);
    PhpConfig.setMacAddr(phoneMac);
    PhpConfig.setNetType(phoneNetType);
    PhpConfig.setNetTypeLevel(phoneNetTypeLevel);
    if phoneNetType == "WIFI" then
        UploadDumpFile.getInstance():execute(true);--引擎报错上传
    end
    PhpConfig.setIpAddr(phoneIp);
    PhpConfig.setImeiNum(phoneImei);

    -- 积分墙 end

    PhpConfig.setMnick(mnick);
    PhpConfig.setImei(sitemid); 
    PhpConfig.setOsInfo(osinfo);


    local post_data = {};
    post_data.uid = md5_string(sitemid); 
    post_data.new_uuid = new_uuid;
    post_data.imei = sitemid;
    post_data.mnick = mnick;
    post_data.appid = PhpConfig.getAppid();
    post_data.appkey = PhpConfig.getAppKey();

    post_data.sdkVersion = json_data.sdkVersion:get_value() or "";
    post_data.netType = json_data.netType:get_value() or "";
    post_data.model = json_data.model:get_value() or "";

    post_data.pixel = pixel;
    post_data.operator = operator;
    if kPlatform == kPlatformIOS then
        post_data.old_param = {};
        post_data.old_param.macid = json_data.macid:get_value() or "";
        post_data.old_param.openudid = json_data.openudid:get_value() or "";
        post_data.old_param.advertisingID = json_data.advertisingID:get_value() or "";
        post_data.old_param.deviceToken = json_data.deviceToken:get_value() or "";
        post_data.old_param.vendorID = json_data.vendorID:get_value() or "";
        post_data.old_param._3gid = json_data._3gid:get_value() or "";
        post_data.old_param.device_no = json_data.device_no:get_value() or "";
    end;

    TerminalInfo.getInstance():setOperator(operator);
    TerminalInfo.getInstance():setOperatorType(operatorType);
    TerminalInfo.getInstance():setPhoneImei(phoneImei);

    if tonumber(isNetworkAvailable) == 0 then
        local jsonString = GameCacheData.getInstance():getString(GameCacheData.FORCEUPDATE,"");
        local updateData = {};
        if jsonString and jsonString ~= "" then
            updateData = json.decode_node(jsonString);
            local updateType = tonumber(updateData.type:get_value());
            if updateType == 1 then
                OnlineUpdate.getInstance():onCheckUpdate(updateData);
                GameData.getInstance():setForceFlag(updateData);
            end
        end
    end
    self:sendHttpMsg(HttpModule.s_cmds.GuestZhLogin,post_data,"登录中...");
end


ChessController.onNativeNetStateChange = function(self, flag, data)
    if not flag or not data then
        return;
    end;
    Log.i("ChessController.onNativeNetStateChange");
    local netlevel = data.netState:get_value();
    Log.i("ChessController.onNativeNetStateChange---->"..data.netState:get_value());
    local numNetLevel = tonumber(netlevel);
    if numNetLevel then
        if numNetLevel ~= 5 then
            if not self.m_hallSocket:isSocketOpen() then
                Log.i("need open socket --> "..netlevel);
                self.m_hallSocket:openSocket(ServerConfig.getInstance():getHallIpPort());
            end;
            EventDispatcher.getInstance():dispatch(Event.Call,kNetStateResume);         
        end;
    end;
end;

ChessController.onSysExit = function(self,flag,data)
    local line = "quit";
	dict_set_string(GUI_ENGINE , GUI_ENGINE .. kparmPostfix , line);
	call_native(GUI_ENGINE);
    sys_exit();
end


ChessController.onActivitySdkCallBack = function(self,flag,data)
    if not flag then return end;
    local info = json.analyzeJsonNode(data);
    if info.target == "lobby" then
        StateMachine.getInstance():changeState(States.Hall,StateMachine.STYPE_CUSTOM_WAIT);
    elseif info.target == "feedback" then
        StateMachine.getInstance():pushState(States.Feedback,StateMachine.STYPE_CUSTOM_WAIT);
    elseif info.target == "room" then
        StateMachine.getInstance():pushState(States.Online,StateMachine.STYPE_CUSTOM_WAIT);
    elseif info.target == "info" then
        StateMachine.getInstance():pushState(States.UserInfo,StateMachine.STYPE_CUSTOM_WAIT);
    elseif info.target == "store" then
        StateMachine.getInstance():pushState(States.Mall,StateMachine.STYPE_CUSTOM_WAIT);
    elseif info.target == "friend" then
        StateMachine.getInstance():pushState(States.Friends,StateMachine.STYPE_CUSTOM_WAIT);
    elseif info.target == "task" then
    elseif info.target == "rank" then
    end
end

ChessController.onChangeStates = function(self,flag,data)
    if not flag then return end;
    local info = json.analyzeJsonNode(data);
    if info.statesId and StatesMap[info.statesId] then
        if States.Rank == info.statesId then
            StateMachine.getInstance():pushState(info.statesId,StateMachine.STYPE_CUSTOM_WAIT,nil,info.rank_states);
            return;
        elseif States.playCreateEndgate == info.statesId then
            kEndgateData:setPlayCreateEndingData(info.data);
            StateMachine.getInstance():pushState(info.statesId,StateMachine.STYPE_CUSTOM_WAIT);
            return;
        end
        StateMachine.getInstance():pushState(info.statesId,StateMachine.STYPE_CUSTOM_WAIT);
    end
end

ChessController.onSaveChess = function(self,flag,data)
    Log.i("ChessController.onSaveChess");
    if not flag then return end;
    local uid = UserInfo.getInstance():getUid();
	local keys = GameCacheData.getInstance():getString(GameCacheData.DAPU_KEY .. uid,"");
	local keys_table = lua_string_split(keys, GameCacheData.chess_data_key_split);
	
	local index = 0;
	if keys == "" or keys == GameCacheData.NULL then
		index = 1;
	else
		while index <= UserInfo.getInstance():getSaveChessLimit() do
			index = index + 1;
			if keys_table[index] == nil or keys_table[index] == GameCacheData.NULL then
				break;
			end
		end
	end
	local key = "myChessDataId_"..index;
	if keys == "" or keys == GameCacheData.NULL then
		keys_table = {};
	end
	keys_table[index] = key;
	
	local mvData = {};
	mvData.fileName = "我的棋谱"..index;
	mvData.time = os.date("%Y", os.time()).."-"..os.date("%m", os.time()).."-"..os.date("%d", os.time());
	mvData.win_flag = data.win_flag:get_value();
	mvData.m_game_end_type = data.end_type:get_value();
	mvData.mvStr = data.move_list:get_value();
	mvData.fenStr = data.start_fen:get_value();
    mvData.start_fen = data.start_fen:get_value();
	mvData.black_mid = data.black_mid:get_value();
    mvData.red_mid = data.red_mid:get_value();
    mvData.manual_type = data.manual_type:get_value();
	local mvData_str = json.encode(mvData);

	if index > UserInfo.getInstance():getSaveChessLimit() then
		--UserInfo.getInstance():setDapuDataNeedToSave(mvData);
        dict_set_string("Toast" , "Toast" .. kparmPostfix , "本地棋牌已满!");
        call_native("Toast");
		return false;	--提示覆盖
	end

	print_string("mvData_str = " .. mvData_str);
	GameCacheData.getInstance():saveString(GameCacheData.DAPU_KEY .. uid,table.concat(keys_table,GameCacheData.chess_data_key_split));
	GameCacheData.getInstance():saveString(key .. uid,mvData_str);
	
	GameCacheData.getInstance():saveString(GameCacheData.DAPU_LAST_BORAD_FEN,GameCacheData.NULL);
	GameCacheData.getInstance():saveString(GameCacheData.DAPU_LAST_CHESS_STR,GameCacheData.NULL);
    
    dict_set_string("Toast" , "Toast" .. kparmPostfix , "保存成功!");
    call_native("Toast");
	return true;	--保存成功
end


ChessController.onPushGetuiMsg = function(self, flag, data)
    if not flag then return end;
    if data and data.clientid then
        local post_data = {};
        post_data.client_id = data.clientid:get_value();
        self:sendHttpMsg(HttpModule.s_cmds.uploadGetuiClientid,post_data);
    end;
end;

ChessController.onGetCityInfo = function(self, flag, data)
    if not flag then return end;
    if data and data.region_id and data.city_id then
        local post_data = {};
        post_data.province_code = data.region_id:get_value() or "";
	    post_data.city_code = data.city_id:get_value() or "";
        HttpModule.getInstance():execute(HttpModule.s_cmds.saveUserInfo,post_data);
        GameCacheData.getInstance():saveString(GameCacheData.LOCATE_CITY_INFO,json.encode(data));
    end;
end;


ChessController.onGetDownloadImage = function(self,flag,data)
    if not flag then 
        --下载失败
    end
    local info = json.analyzeJsonNode(data);
    for i,v in pairs(info) do
        Log.i(v);
    end

    if info.ImageName then
        UserInfo.saveCacheImageManager(info.ImageName);
    end

    if self.m_friendChoiceDialog then
        self.m_friendChoiceDialog:update(info);
    end
    BroadcastMessageAnim.showBroadcastImage2(info.ImageName,info.what);

    -- 网络图片下载管理器
    CacheImageManager.callBackEvent(info.ImageName,info.what);
end

ChessController.onGoodsUploadProp = function(self,status,json_data)
    if not status or not json_data then 
        return ;
    end
    if tonumber(json_data.flag:get_value()) == 10000 then
        local propinfo = json_data.data.prop_info;
        local user = UserInfo.getInstance();
        user:setLifeNum(propinfo["1"]:get_value() or 0);
        user:setUndoNum(propinfo["2"]:get_value() or 0);
        user:setTipsNum(propinfo["3"]:get_value() or 0);
        user:setReviveNum(propinfo["4"]:get_value() or 0);
        user:setLifeLimitNum(propinfo["5"]:get_value() or 0);
    end
end

ChessController.getPhoneInfo = function(self,status,json_data)
    Log.i("getPhoneInfo");

end

ChessController.getUserInfo = function(self)
    local tips = "正在获取玩家信息...";
	local post_data = {};
	post_data.mid = UserInfo.getInstance():getUid();
    HttpModule.getInstance():execute(HttpModule.s_cmds.getUserInfo,post_data,tips);
end

ChessController.onCreateFriendRoom = function(self,post_data)
    local ctype = UserInfo.getInstance():canAccessRoom(5);
    if ctype ~= 5 then
        ChessToastManager.getInstance():show("金币不足，发起挑战失败", 1000);
        return;
    end
    self:sendSocketMsg(CLIENT_HALL_CREATE_FRIENDROOM,post_data,nil,1);
end

----------------- virtual function ------------------------------------------

ChessController.onLoginSuccess = function(self,data)
    self:updateUserInfoView();
end

ChessController.onLoginFail = function(self,data)end

ChessController.updateUserInfoView = function(self)end

------------------ socket event ----------------------------------------------
--ChessController.onHallMsgKickUserClick = function(self,info)

--end


ChessController.hasPlayingGame = function(self)

    ChessDialogManager.dismissAllDialog();
    local message = "系统检测到你有未完成的棋局，是否继续?";
	if not ChessController.m_chessController_chioce_dialog then
        require("dialog/chioce_dialog");
		ChessController.m_chessController_chioce_dialog = new(ChioceDialog);
        ChessController.m_chessController_chioce_dialog:setLevel(1);
	end
	ChessController.m_chessController_chioce_dialog:setMode(ChioceDialog.MODE_SURE);
	ChessController.m_chessController_chioce_dialog:setMessage(message);
	ChessController.m_chessController_chioce_dialog:setPositiveListener(self,self.toRoom);
	ChessController.m_chessController_chioce_dialog:setNegativeListener(self,self.giveUP);
    ChessController.m_chessController_chioce_dialog:setClickCallBack(true);
	ChessController.m_chessController_chioce_dialog:show();
end;


ChessController.toRoom = function(self)
	print_string("HallLoginProc.reLogin");
	UserInfo.getInstance():setRelogin(true);
    ChessDialogManager.dismissAllDialog();
	StateMachine:getInstance():pushState(States.OnlineRoom,StateMachine.STYPE_CUSTOM_WAIT);
end

ChessController.giveUP = function(self)

	print_string("HallLoginProc.giveUP");
	UserInfo.getInstance():setGameType(GAME_TYPE_UNKNOW);
--    self:clientMsgGameInfo();
end

ChessController.clientMsgGameInfo = function(self)
    Log.i("ChessController.clientMsgGameInfo");  
    self:sendSocketMsg(HALL_MSG_GAMEINFO,nil,SUBCMD_MONEY,2, "hall");  
end;

ChessController.onHallMsgLogin = function(self, packageInfo)
    Log.i("ChessController.onHallMsgLogin");
    self:sendSocketMsg(FRIEND_CMD_GET_UNREAD_MSG);
    self:sendSocketMsg(FRIEND_CMD_ONLINE_NUM);
    UserInfo.getInstance():setTid(packageInfo.tid);
    if packageInfo.tid > 0 then 
        if packageInfo.level == UserInfo.getInstance():getRoomConfigById(4).level then--重连私人房
            UserInfo.getInstance():setGameType(GAME_TYPE_CUSTOMROOM);
            UserInfo.getInstance():setCustomRoomID(packageInfo.tid);
            UserInfo.getInstance():setMoneyType(UserInfo.getInstance():getRoomConfigById(4).money);
        elseif  packageInfo.level == UserInfo.getInstance():getRoomConfigById(1).level then--初级场
            UserInfo.getInstance():setGameType(GAME_TYPE_UNKNOW);
            UserInfo.getInstance():setMoneyType(UserInfo.getInstance():getRoomConfigById(1).room_type);            
        elseif  packageInfo.level == UserInfo.getInstance():getRoomConfigById(2).level then--中级场
            UserInfo.getInstance():setGameType(GAME_TYPE_UNKNOW);
            UserInfo.getInstance():setMoneyType(UserInfo.getInstance():getRoomConfigById(2).room_type);   
        elseif  packageInfo.level == UserInfo.getInstance():getRoomConfigById(3).level then--大师场
            UserInfo.getInstance():setGameType(GAME_TYPE_UNKNOW);
            UserInfo.getInstance():setMoneyType(UserInfo.getInstance():getRoomConfigById(3).room_type);
        elseif  packageInfo.level == UserInfo.getInstance():getRoomConfigById(5).level then--好友场
            UserInfo.getInstance():setGameType(GAME_TYPE_FRIEND);
            UserInfo.getInstance():setMoneyType(UserInfo.getInstance():getRoomConfigById(5).room_type);
        end
        self:toRoom();
	end
end;

ChessController.onHallMsgGameinfo = function(self, packetInfo)
    Log.i("ChessController.onHallMsgGameinfo");
    --断线重连GiveUp点击事件响应，大厅收到这个消息目的是获得room的ip和端口，
    --重新连接room，room收到连接响应，在大厅发送relogin命令，成功后在大厅处理
    --relogin响应--->roomSocket再发送giveUp命令--->成功放弃已有的room.绕了一大圈...
    --目前如果不这么处理，虽然能进入room，但是开始游戏room发送gameInfo命令，始终
    --拉取的已存在的room信息，不能开启新的棋局.
--	if not self.m_socketRoomProcesser then
--        require(NET_PATH.."hall/hallSocketProcesser");
--		self.m_socketRoomProcesser = new(HallSocketProcesser,self);
--	end
--    self.m_roomSocket:addSocketProcesser(self.m_socketRoomProcesser);
--	if not self.m_socketRoomWriter then 
--        require(NET_PATH.."hall/hallSocketWriter");
--		self.m_socketRoomWriter = new(HallSocketWriter);
--	end 	
--	self.m_roomSocket:addSocketWriter(self.m_socketRoomWriter);
--	if not self.m_socketRoomReader then
--        require(NET_PATH.."hall/hallSocketReader");
--		self.m_socketRoomReader = new(HallSocketReader,self);
--	end
--    self.m_roomSocket:addSocketReader(self.m_socketRoomReader);

--    self.m_roomSocket:openSocket(ServerConfig.getInstance():getRoomIpPort());

end;

ChessController.onServerOfflineReconnected = function(self, socket)
   
   if socket.m_socketName == "hall" then
        Log.i("连接上大厅了。。。");
        UserInfo.getInstance():setConnectHall(true);
        self:sendSocketMsg(HALL_MSG_LOGIN, nil, SUBCMD_LADDER ,2);
        self:sendSocketMsg(CLIENT_HALL_NET_DATA_REPORT);
    elseif socket.m_socketName == "room" then
	    if UserInfo.getInstance():getTid() and UserInfo.getInstance():getTid() ~= 0 then
            self.m_roomSocket:sendMsg(CLIENT_MSG_RELOGIN,nil, nil, 1);
	    else
		    print_string("Hall.onSocketEvent tid == 0");
	    end    
    end;
end;

ChessController.onClientMsgRelogin = function(self, packetInfo)

    if(packetInfo.errorCode == 0) then
        self.m_roomSocket:sendMsg(CLIENT_MSG_GIVEUP,nil, nil, 1);
	end
end;

ChessController.onClientMsgGiveup = function(self, packetInfo)

    if(packetInfo.errorCode == 0) then
		UserInfo.getInstance():setTid(0);
        self.m_roomSocket:closeSocketSync();
	else
        print_string("CLIENT_MSG_GIVEUP失败！！！");
    end;
end;

ChessController.onHallMsgServerPush = function(self,packageInfo)
    Log.i("ChessController.onHallMsgServerPush");
    if packageInfo then
		if packageInfo.type == 3 then
			-- ChatMessageAnim.play(self.m_root_view,3,data.msg);
			BroadcastMessageAnim.play(self.m_root_view,packageInfo);				
		else
			PayUtil.addPayBudanLog(packageInfo,self);	
		end
        self:updateUserInfoView();
	end
end

ChessController.onHallMsgKickUser = function(self,packageInfo)
    Log.i("ChessController.onHallMsgKickUser");
    print_string("======你的帐号在别处登录！！！======");
    UserInfo.getInstance():setLogin(false);
    self.m_hallSocket:onKickUser();
    StateMachine.getInstance():changeState(States.Hall,StateMachine.STYPE_CUSTOM_WAIT);
    ChessDialogManager.dismissAllDialog();
	if not ChessController.m_chessController_chioce_dialog then
        require("dialog/chioce_dialog");
		ChessController.m_chessController_chioce_dialog = new(ChioceDialog);
        ChessController.m_chessController_chioce_dialog:setLevel(1);
	end
	local message = "您的帐号在别处登录！！！";
    ChessController.m_chessController_chioce_dialog:setMode(ChioceDialog.MODE_SURE,"重连","切换帐号");
	ChessController.m_chessController_chioce_dialog:setMessage(message);
	ChessController.m_chessController_chioce_dialog:setPositiveListener(self,self.login);
	ChessController.m_chessController_chioce_dialog:setNegativeListener(self,self.onSwitchAccountBtnClick);
--    ChessController.m_chessController_chioce_dialog:setClickCallBack(false);
	ChessController.m_chessController_chioce_dialog:show();
end

ChessController.onSwitchAccountBtnClick = function(self)
    require("dialog/toggle_account_dialog");
    delete(self.m_toggleAccountDialog);
    self.m_toggleAccountDialog = nil;
    self.m_toggleAccountDialog = new(ToggleAccountDialog);
    self.m_toggleAccountDialog:setCtrl(self);
	self.m_toggleAccountDialog:show();
end

ChessController.exit_game = function(self)
	local line = "quit";
	dict_set_string(GUI_ENGINE , GUI_ENGINE .. kparmPostfix , line);
	call_native(GUI_ENGINE);
    sys_exit();
end

ChessController.checkVersion = function(self)
    if UserInfo.getInstance():getCheckVersion() then
--		self.m_check_version_fail = false;
		print_string("Hall.checkVersion in but UserInfo.getInstance():getCheckVersion()");
		return false;
	end
    local tips = "正在检测版本信息.....";
	local post_data = {};
	post_data.mid = "mid";
    HttpModule.getInstance():execute(HttpModule.s_cmds.checkVersion_new,post_data,tips);
    return true;
end

ChessController.getNotice = function(self)
    --local tips = "正在拉取公告.....";
	local post_data = {};
    HttpModule.getInstance():execute(HttpModule.s_cmds.IndexGetNotice,post_data);
end

ChessController.onFriendCmdOnlineNum = function(self,info)
--    FriendsData.getInstance():onCheckUserStatus(info);
end

ChessController.onFriendCmdCheckUserStatus = function(self,info)
    FriendsData.getInstance():onCheckUserStatus(info);
end

--ChessController.onFriendCmdCheckUserData = function(self,info)
--    FriendsData.getInstance():onCheckUserData(info);
--end

ChessController.onFriendCmdGetFriendsNum = function(self,info)
    FriendsData.getInstance():onGetFriendsNum(info.num);
end

ChessController.onFriendCmdGetFollowNum = function(self,info)
    FriendsData.getInstance():onGetFollowNum(info.num);
end

ChessController.onFriendCmdGetFansNum = function(self,info)
    FriendsData.getInstance():onGetFansNum(info.num);
end

ChessController.onFriendCmdGetFriendsList = function(self,info)
    FriendsData.getInstance():onGetFriendsList(info);
end

ChessController.onFriendCmdGetFollowList = function(self,info)
    FriendsData.getInstance():onGetFollowList(info);
end

ChessController.onFriendCmdGetFansList = function(self,info)
    FriendsData.getInstance():onGetFansList(info);
end

ChessController.onFriendCmdGetUnreadMsg = function(self,info)
    FriendsData.getInstance():onGetFriendsMsg(info);
end

ChessController.onRecvServerCreateFriendRoom = function(self, packetInfo)  --创建好友房回调
   if packetInfo.ret == 0 then
       UserInfo.getInstance():setChallenger(true);
       UserInfo.getInstance():setTid(packetInfo.tid);
       UserInfo.getInstance():setRoomInfo(packetInfo);
       UserInfo.getInstance():setGameType(GAME_TYPE_FRIEND);       --跳转到好友房
       UserInfo.getInstance():setMoneyType(5);
       UserInfo.getInstance():setRoomLevel(320);
       StateMachine.getInstance():pushState(States.OnlineRoom,StateMachine.STYPE_CUSTOM_WAIT);
   else
       ChessToastManager.getInstance():show("创建房间失败，请稍后再试！");
   end
end;

ChessController.onInvitNotify = function(self,packageInfo)
    --需要判断是否在下棋中
    if not packageInfo or not packageInfo.uid or not packageInfo.tid then
        return;
    end

    local ctype = UserInfo.getInstance():canAccessRoom(5);
    if ctype ~= 5 then
        local post_data = {};
        post_data.uid = UserInfo.getInstance():getUid();
        post_data.target_uid = packageInfo.uid;
        post_data.ret = 1;
--        self:sendSocketMsg(FRIEND_CMD_FRIEND_INVIT_RESPONSE,post_data,nil,1);
        self:sendSocketMsg(FRIEND_CMD_FRIEND_INVIT_RESPONSE2,post_data,nil,1);
        return;
    end

    local friendData = FriendsData.getInstance():getUserData(packageInfo.uid);

    --根据uid获取用户名和头像
    require("dialog/friend_chioce_dialog");
    if not self.m_friendChoiceDialog then
        self.m_friendChoiceDialog = new(FriendChoiceDialog);
    end
    self.m_friendChoiceDialog:setMode(1,friendData,packageInfo.time_out);
    self.m_friendChoiceDialog:setPositiveListener(self,
        function()
            UserInfo.getInstance():setTid(packageInfo.tid);
            UserInfo.getInstance():setGameType(10);       --测试跳转到好友房
            UserInfo.getInstance():setMoneyType(5);
            local post_data = {};
            post_data.uid = UserInfo.getInstance():getUid();
            post_data.target_uid = packageInfo.uid;
            post_data.ret = 0;
            ChessDialogManager.dismissAllDialog();
            UserInfo.getInstance():setChallenger(false);
--            self:sendSocketMsg(FRIEND_CMD_FRIEND_INVIT_RESPONSE,post_data,nil,1);  
            self:sendSocketMsg(FRIEND_CMD_FRIEND_INVIT_RESPONSE2,post_data,nil,1);                                                
            StateMachine.getInstance():pushState(States.OnlineRoom,StateMachine.STYPE_CUSTOM_WAIT); end);
    self.m_friendChoiceDialog:setNegativeListener(self,
        function()
            local post_data = {};
            post_data.uid = UserInfo.getInstance():getUid();
            post_data.target_uid = packageInfo.uid;
            post_data.ret = 1;
--            self:sendSocketMsg(FRIEND_CMD_FRIEND_INVIT_RESPONSE,post_data,nil,1);
            self:sendSocketMsg(FRIEND_CMD_FRIEND_INVIT_RESPONSE2,post_data,nil,1);
            end);
    self.m_friendChoiceDialog:show();
end

ChessController.onPropCmdQueryUserData = function(self,info)
    if info.ret == 0 then
        local prop = json.decode(info.data_json);
        if not prop then return end;
        for i,v in pairs(prop) do
            UserInfo.saveProp(i,v);
        end
        self:updateUserInfoView();
    end
end

ChessController.updateFriendsListData = function(self,info)
    if not info then return end   --0,陌生人,=1粉丝，=2关注，=3好友
    
    if info.ret == 2 then 
        ChessToastManager.getInstance():showSingle("超出上限！");
    elseif info.ret == 0 then
        FriendsData.getInstance():updateFriendsListData(info);
    else
        ChessToastManager.getInstance():showSingle("操作失败！");
    end
end

----------------- broadcast event ----------------------------
ChessController.onHallBroadcastMsg = function(self,msg)
    if not self.s_broadcastCmdFuncMap[msg.msg_id] then
        print("ChessController.onHallBroadcastMsg cmd func is nil");
        return ;
    end
    return self.s_broadcastCmdFuncMap[msg.msg_id](self,msg);
end

ChessController.onGetGold = function(self,msg)
    if not msg.content or not msg then return end 
    if msg.content.tip_text and msg.content.tip_text ~= "" then
        ChessToastManager.getInstance():show(msg.content.tip_text,1500);
    end
    UserInfo.getInstance():setMoney(tonumber(msg.content.money));
    if kPlatform == kPlatformIOS then
        if msg.content.bccoins and msg.content.bccoins ~= "" then
            UserInfo.getInstance():setBccoin(tonumber(msg.content.bccoins));
        end;
    end;
    self:updateUserInfoView();
end

ChessController.onGetProp = function(self,msg)
    if not msg.content or not msg then return end 
    require(PAY_PATH.."exchangePay");
    if msg.content.tip_text and msg.content.tip_text ~= "" then
        ChessToastManager.getInstance():show(msg.content.tip_text);
    end
    for i,v in pairs(msg.content.prop) do
        local startNum = ExchangePay.getStartNum(v.rid);
        local num = v.num;
        if startNum == 2 then --悔棋
		    local undoNum = UserInfo:getInstance():getUndoNum();
		    undoNum = undoNum + num; 
		    UserInfo:getInstance():setUndoNum(undoNum);
	    elseif startNum == 3 then --提示
		    local tipsNum = UserInfo:getInstance():getTipsNum();
		    tipsNum = tipsNum + num; 
		    UserInfo:getInstance():setTipsNum(tipsNum);
	    elseif startNum == 4 then --起死回生
		    local reviveNum = UserInfo:getInstance():getReviveNum();
		    reviveNum = reviveNum + num; 
		    UserInfo:getInstance():setReviveNum(reviveNum);
  	    elseif startNum == 7 then--dapu
  		    UserInfo.getInstance():setDapuEnable(1);
	    end
    end
    self:updateUserInfoView();
    --ExchangePay.uploadOrDownPropData(1)
end

ChessController.onGetNews = function(self,msg)
    if not msg.content or not msg then return end
    local showToast = nil; 
    if msg.content.alert == 1 then
       showToast = msg.content.tip_text;
    end
--    local num = GameCacheData.getInstance():getInt(GameCacheData.NOTICENUM..UserInfo.getInstance():getUid(),0);
--    GameCacheData.getInstance():saveInt(GameCacheData.NOTICENUM..UserInfo.getInstance():getUid(),num + msg.content.msg_num);
    local lastMailtime = GameCacheData.getInstance():getString(GameCacheData.NOTICE_MAILS_TIME,"0");
    local params = {};
    params.last_mail_time = lastMailtime;
    HttpModule.getInstance():execute(HttpModule.s_cmds.UserMailGetNewMailNumber,params);
end

ChessController.onGetAds = function(self, msg)
    if not msg.content or not msg then return end
    UserInfo.getInstance():setAdsStatus(msg.content.mobileAdsButton,msg.content.mobileAdsScreen);
end;

ChessController.onGetVip = function(self, msg)
    if not msg.content or not msg then return end
    UserInfo:getInstance():updateVipStatus(1);
    MallData.getInstance():sendGetShopInfo(); 
    if not msg.content.tip_text or msg.content.tip_text == "" then
        ChessToastManager.getInstance():showSingle("恭喜你获得VIP资格!");
    else
        ChessToastManager.getInstance():showSingle(msg.content.tip_text);
    end

end;

ChessController.onGetNottice = function(self)
    self:getNotice();
end

ChessController.changeLogin = function(self)
    require("dialog/toggle_account_dialog");
    delete(self.m_toggleAccountDialog);
    self.m_toggleAccountDialog = nil;
    self.m_toggleAccountDialog = new(ToggleAccountDialog);
--    self.m_toggleAccountDialog:setCloseListener(self,self.reLogin);
--    self.m_toggleAccountDialog:setCtrl(self);
	self.m_toggleAccountDialog:show();
end

------------------ http event ------------------------------------------------

ChessController.onLoginCallBack = function(self,isSuccess,message)
    Log.i("onLoginWin32CallBack");
    if not isSuccess then
        Log.e("onLoginWin32CallBack fail");
        --这里弹重新登录框
        self:onLoginFail(data);
        require("dialog/chioce_dialog");
        delete(self.m_loginFailDialog);
        self.m_loginFailDialog = new(ChioceDialog);
        if kPlatform == kPlatformIOS then
            if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
                local message = "帐号登录失常,请重试,或切换其他帐号登录";
                self.m_loginFailDialog:setMode(ChioceDialog.MODE_COMMON,"重新登录","切换帐号");
                self.m_loginFailDialog:setMessage(message);
                self.m_loginFailDialog:setPositiveListener(self,self.login);
                self.m_loginFailDialog:setNegativeListener(self,ChessController.changeLogin);
                self.m_loginFailDialog:show();
            else
                local message = "帐号登录失常,请重试";
    		    self.m_loginFailDialog:setMode(ChioceDialog.MODE_SURE);
    		    self.m_loginFailDialog:setMessage(message);
    		    self.m_loginFailDialog:setPositiveListener(self,self.login);
    		    -- self.m_loginFailDialog:setNegativeListener(self,ChessController.changeLogin);
    		    self.m_loginFailDialog:show();
            end;
        else
            local message = "帐号登录异常,请重试,或切换其他帐号登录";
		    self.m_loginFailDialog:setMode(ChioceDialog.MODE_COMMON,"重新登录","切换帐号");
		    self.m_loginFailDialog:setMessage(message);
		    self.m_loginFailDialog:setPositiveListener(self,self.login);
		    self.m_loginFailDialog:setNegativeListener(self,ChessController.changeLogin);
		    self.m_loginFailDialog:show();
        end;
        return ;
    end

    self.m_hallSocket:setKickUser(false);

    require(DATA_PATH.."userInfo");
    HttpModule.m_switchFlag = false;
  	GameCacheData.getInstance():saveString(GameCacheData.LAST_LOGIN_TYPE,UserInfo.getInstance():getLoginType());

	PhpConfig.saveWebUrl(PhpConfig.requestUrl);
    require("util/ToolKit");
	ToolKit.clearDailyWorkLog();

  	if(message.data ~= nil) then
  		UserInfo.getInstance():login(message.data);
        --活动中心初始化
        local data = {};
        data.activityDebug = kActivityDebug;
        data.mid = UserInfo.getInstance():getUid();
        data.version = kLuaVersion;
        data.usertype = PhpConfig.getSidPlatform();
        data.bid = PhpConfig.getBid_();
        data.sitemid = UserInfo.getInstance():getSitemid();
        local cost_list = UserInfo.getInstance():getFPcostMoney();
        if not cost_list then cost_list = {} end
        -- 复制收藏（h5） 
        data.collect_manual = cost_list.collect_manual or 0;
        -- 收藏棋谱(lua内)
        data.save_manual = cost_list.save_manual or 0;
        -- 评论
        data.comment_manual = cost_list.comment_manual or 0;
        -- php 校验码
        data.access_token = PhpConfig.getAccessToken();

	    dict_set_string(kInitActivitySdk,kInitActivitySdk..kparmPostfix,json.encode(data));
	    call_native(kInitActivitySdk);

        -- 登录成功后初始化个推sdk(修复上传php只有clientid，没有uid（uid==0)的情况)
        -- 原来初始化个推在Android层onCreate方法中，初始化完成返回clientid是异步的
        -- 如果此时还没有登录，则上传php只有个推的clientid，而uid==0
        call_native(kInitGetuiSdk);

        require(PAY_PATH.."payUtil");
  		PayUtil.init();
  	end
    require(DATA_PATH .. "friendsData");
    FriendsData.clear();
    FriendsData.getInstance():init();
    -- 上传日志
    local logs = StatisticsUtil.getUploadData();
    if logs then
        local params = {};
        params.log = {};
        for i,v in pairs(logs) do
            params.log["log"..i] = v;
        end
        HttpModule.getInstance():execute(HttpModule.s_cmds.IndexClientReportLog,params);
    end

    self:checkVersion();
    self:getNotice();
    self:openHallSocket();
    self:onLoginSuccess(message);
    self:getLocalCityInfo();
end
--启动页设置回调
ChessController.onIndexGetStartConfig = function(self,isSuccess,message)
    Log.i("ChessController.onIndexGetStartConfig");
    if not isSuccess then
        return
    end

	if not message then
		print_string("not message");
		return
	end 

    local data = message.data;
    local is_open = tonumber(data.is_open:get_value()) or 0;
    local ad_second = tonumber(data.ad_second:get_value()) or 5;
    local ad_img_url = data.ad_img:get_value();
    local ad_jump_url = data.ad_url:get_value();

--    local tab = {};
--    tab.is_open = is_open;
--    tab.ad_second = ad_second;
--    tab.ad_img_url = ad_img_url;
--    tab.ad_jump_url = ad_jump_url;

    local json_url = GameCacheData.getInstance():getString(GameCacheData.START_AD_IMG_URL,"");

    GameCacheData.getInstance():saveInt(GameCacheData.START_IS_OPEN,is_open);
    GameCacheData.getInstance():saveString(GameCacheData.START_AD_JUMP,ad_jump_url);
    GameCacheData.getInstance():saveInt(GameCacheData.START_AD_SEC,ad_second);
    GameCacheData.getInstance():saveString(GameCacheData.START_AD_IMG_URL,ad_img_url);

    local width = System.getScreenWidth();
    local height = System.getScreenHeight();
    local info = {
            ["x"] = 0,
            ["y"] = 0,
            ["width"] = width or 480,
            ["height"] = height,
            ["url"] = ad_jump_url or nil,
            ["uid"] = UserInfo.getInstance():getUid() or "",
            ["method"] = "",
        };
    local json_data = json.encode(info);
    GameCacheData.getInstance():saveString(GameCacheData.START_AD_JUMP_URL,json_data);

    if not (json_url == ad_img_url) then
        local post_data = {};
	    post_data.ImageName = "download_ad_start";
	    post_data.ImageUrl = ad_img_url;
	    local dataStr = json.encode(post_data);
	    dict_set_string(kDownLoadImage,kDownLoadImage..kparmPostfix,dataStr);
	    call_native(kDownLoadImage);
    end

--    ad图片是否修改，是否播放多个
--    local change_img
--    local show_all
    
end

ChessController.onIndexClientReportLog = function(self,isSuccess,message)
    if not isSuccess then
        StatisticsUtil.onUploadFail();
        return
    end
end

ChessController.onSaveUserInfo = function(self, isSuccess ,message)
    if not isSuccess then
        if type(message) == "number" then
            return; 
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
            return;
        end;        
    end;
    local data = json.analyzeJsonNode(message.data.aUser);
    if data.province_code and data.province_name then
        UserInfo.getInstance():setCityCode(data.province_code or 0);
        UserInfo.getInstance():setCityName(data.province_name or "");

        GameCacheData.getInstance():saveString(GameCacheData.LOCATE_CITY_NAME,data.province_name);
        GameCacheData.getInstance():saveInt(GameCacheData.LOCATE_CITY_CODE,data.province_code);
    end;
end;


ChessController.getPropListCallBack = function(self,isSuccess,message)
    Log.i("ChessController.getPropListCallBack");
    if not isSuccess then
        return ;
    end
    local list = MallData.getInstance():explainPropData(message);
    return list;
end

ChessController.getShopInfoCallBack = function(self,isSuccess,message)
    Log.i("ChessController.getShopInfoCallBack");
    if not isSuccess then
        return ;
    end
    local list = MallData.getInstance():explainShopData(message);
    return list;
end

ChessController.exchangePropCallBack = function(self,isSuccess,message)
    if not isSuccess then
        ChessToastManager.getInstance():show("兑换失败！");
        return ;
    end
    local data = message.data;
	local result = {};

	if data then
		if data.money and data.money:get_value() and data.money:get_value()~="" then
			local money = data.money:get_value() or 0;
			UserInfo.getInstance():setMoney(money);
			result.money = money;
		end
		
		if data.coin and data.coin:get_value() and data.coin:get_value()~="" then
			local coin = data.coin:get_value() or "";
			UserInfo.getInstance():setBccoin(coin);
			result.coin = coin;
		end

		if data.orderno and data.orderno:get_value() and data.orderno:get_value()~="" then
			local orderno = data.orderno:get_value() or "";
			result.orderno = orderno;
		end

		if data.goods_type and data.goods_type:get_value() and data.goods_type:get_value()~="" then
			local goods_type = data.goods_type:get_value();
			result.goods_type = tonumber(goods_type);
		end

		if data.goods_num and data.goods_num:get_value() and data.goods_num:get_value()~="" then
			local goods_num = data.goods_num:get_value();
			result.goods_num = tonumber(goods_num);
		end

		if data.position and data.position:get_value() and data.position:get_value()~="" then
			local position = data.position:get_value();
			result.position = tonumber(position);
		end

		if data.pid and data.pid:get_value() and data.pid:get_value()~="" then
			local pid = data.pid:get_value() or "";
			result.id = tonumber(pid);
		end

	end

	local status = message.status:get_value();
	result.status = status;
    require(PAY_PATH.."exchangePay");
    if ExchangePay.exchangePropResult(result) then
        self:getUserInfo();
    end
end

ChessController.getUserInfoCallBack  = function(self,isSuccess,message)
    if not isSuccess then
        return ;
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

    print_string(money);
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
        self:updateUserInfoView();
	else
	end
end
ChessController.registerSinalReceiver = function(self)
    local post_data = {};
	local dataStr = json.encode(post_data);
	dict_set_string(kRegisterSinalReceiver,kRegisterSinalReceiver..kparmPostfix,dataStr);
	call_native(kRegisterSinalReceiver);
end

ChessController.getLocalCityInfo = function(self)
    local localStr = GameCacheData.getInstance():getString(GameCacheData.LOCATE_CITY_INFO);
    if not localStr or localStr == "" then
        call_native(kGetCityInfo);
    end;
end;
ChessController.unregisterSinalReceiver = function(self)
    local post_data = {};
	local dataStr = json.encode(post_data);
	dict_set_string(kUnregisterSinalReceiver,kUnregisterSinalReceiver..kparmPostfix,dataStr);
	call_native(kUnregisterSinalReceiver);
end 

ChessController.onCheckVersion = function(self,isSuccess,message) 
    if not isSuccess then
        return ;
    end

    if tonumber(message.flag:get_value()) == 40000 then
	    UserInfo.getInstance():setCheckVersion(true);
  		return;
  	end

  	if(message.data ~= nil) then
  		self:explainCheckVersionResult(message.data);
  	end
end

ChessController.checkFinish = function(self)
	UserInfo.getInstance():setCheckVersion(true);
end

ChessController.uploadVersion = function(self)
	print_string("Hall.uploadVersion url = " .. self.m_check_url);

	dict_set_string(UPDATEVERSION , UPDATEVERSION .. kparmPostfix , self.m_check_url);
	dict_set_string(UPDATEVERSION_FORCE , UPDATEVERSION_FORCE .. kparmPostfix , self.m_update_type);

	call_native(UPDATEVERSION);
end

ChessController.explainCheckVersionResult = function(self,data)
    OnlineUpdate.getInstance():onCheckUpdate(data);
end

ChessController.onCreateOrder = function(self, isSuccess, message)
    PayUtil.getPayInstance(PayUtil.s_useType):onCreateOrderCallBack(isSuccess, message);
end

ChessController.onFriendCmdCheckUserData = function(self,isSuccess,message)
    if not isSuccess then return ;end
    local info = {};
    local data = message.data;
    for i,v in pairs(data) do
        local item = {};
        item.mid = tonumber(v.mid:get_value()) or 0;
        item.mnick = v.mnick:get_value() or "";
        item.mactivetime = v.mactivetime:get_value() or 0;
        item.iconType = v.iconType:get_value() or 0;
        item.score = tonumber(v.score:get_value()) or 0;
        item.money = tonumber(v.money:get_value()) or 0;
        item.drawtimes = tonumber(v.drawtimes:get_value()) or 0;
        item.wintimes = tonumber(v.wintimes:get_value()) or 0;
        item.losetimes = tonumber(v.losetimes:get_value()) or 0;
        item.icon_url = v.icon_url:get_value();
        item.rank = tonumber(v.rank:get_value()) or 0;
        item.sex = tonumber(v.sex:get_value()) or 0;
        item.fans_rank = tonumber(v.fans_rank:get_value()) or 0;
        item.is_vip = tonumber(v.is_vip:get_value());
        table.insert(info,item);
    end
    FriendsData.getInstance():onCheckUserData(info);
end

ChessController.onReportBad = function(self,isSuccess,message)
    if not isSuccess then return ;end
    if message.flag:get_value() == 10000 then
        ChessToastManager.getInstance():show("举报成功，我们会尽快核实处理",2000);
    end
end


ChessController.onUploadGetuiCID = function(self)
    

end;

ChessController.updateMonthCombat = function(self,isSuccess,message)
    if not isSuccess then return ;end
	UserInfo.getInstance():setWintimes(message.data.combat_gains.wintimes:get_value());
	UserInfo.getInstance():setLosetimes(message.data.combat_gains.losetimes:get_value());
	UserInfo.getInstance():setDrawtimes(message.data.combat_gains.drawtimes:get_value());

	UserInfo.getInstance():setPrevWintimes(message.data.prev_month_combat_gains.wintimes:get_value());
	UserInfo.getInstance():setPrevLosetimes(message.data.prev_month_combat_gains.losetimes:get_value());
	UserInfo.getInstance():setPrevDrawtimes(message.data.prev_month_combat_gains.drawtimes:get_value());

	UserInfo.getInstance():setCurrentWintimes(message.data.current_month_combat_gains.wintimes:get_value());
	UserInfo.getInstance():setCurrentLosetimes(message.data.current_month_combat_gains.losetimes:get_value());
	UserInfo.getInstance():setCurrentDrawtimes(message.data.current_month_combat_gains.drawtimes:get_value());
    self:updateUserInfoView();
end

ChessController.onGetCityData = function(self,isSuccess,message)
    Log.i("onGetCityData");
    if not isSuccess then
        return ;
    end

--    local info = json.analyzeJsonNode(message);

--    if not info.flag or info.flag ~= 10000 then
--        return
--    end

    if message.flag:get_value() ~= 10000 then return end;
    local version = message.file_version:get_value();
--    local version = message.file_version;
    GameCacheData.getInstance():saveInt(GameCacheData.GET_CITY_DATA,version);

    message = message.data;

    local cityData = {};
    for _,v in pairs(message) do
        local item = {};
        local cityItem = {};
        local cityitem = v.city;
        for _,m in pairs(cityitem) do
            local city = {};
            city.name = m.name:get_value();
            city.code = tonumber(m.code:get_value());
            table.insert(cityItem,city);
        end
        item.city = cityItem;
        item.name = v.name:get_value();
        item.code = tonumber(v.code:get_value());
        table.insert(cityData,item);
    end

    CityData.getInstance():saveData(cityData);
end

ChessController.onIndexGetNotice = function(self,isSuccess,message) 
    if not isSuccess then
        return ;
    end

    if message.flag:get_value() ~= 10000 then return end;

--    "data": {
--        "nid": "50",
--        "ntitle": "123234", //公告标题
--        "nlink": "", //公告跳转url,扩展字段
--        "ncontent": "sfbgdfbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb\r\nxbdsfgtsf", //公告内容
--        "nstart": "1452146820", //开始时间
--        "nend": "1452233400", //结束时间
--        "api": "101",
--        "jump_scene": "2", //跳转场景
--        "is_push": "1", //是否发起过全服推送
--        "notice_type": "1" //公告类型
--    }
    local data = message.data;
    delete(ChessController.m_notice_dialog);
    require(DIALOG_PATH..'notice_dialog');
    ChessController.m_notice_dialog = new(NoticeDialog);
    ChessController.m_notice_dialog:setTitle(data.ntitle:get_value());
    ChessController.m_notice_dialog:setContentText(data.ncontent:get_value());
    local jump_scene = tonumber(data.jump_scene:get_value());
    if jump_scene and jump_scene ~= 0 and StatesMap[jump_scene] and  typeof(self,HallController) then
        ChessController.m_notice_dialog:setBtnText("查看");
        ChessController.m_notice_dialog:setBtnClick(nil,function()
            StateMachine.getInstance():pushState(jump_scene,StateMachine.STYPE_CUSTOM_WAIT);
        end);
    else
--        ChessController.m_notice_dialog:setBtnText();
        ChessController.m_notice_dialog:setBtnClick();
    end
    ChessController.m_notice_dialog:show();
end

function ChessController:onUserMailAction(isSuccess,message) 
    if HttpModule.explainPHPMessage(isSuccess,message,"操作失败") then
        return ;
    end

    local data = message.data;
    
    ChessToastManager.getInstance():showSingle(data.tip_text:get_value() or "操作成功");
    if data.update_user_data:get_value() == 1 then
        local propInfo = json.decode(data.prop_info:get_value());
        if propInfo then
            for key,value in pairs(propInfo) do
                UserInfo.saveProp(key.."",value);
            end
        end

        local isVip = data.is_vip:get_value();
        if isVip then
            UserInfo:getInstance():updateVipStatus(isVip);
        end

        local money = data.money:get_value();
        if money then
            UserInfo:getInstance():setMoney(money);
        end

        local bccoins = data.bccoins:get_value();
        if bccoins then
            UserInfo:getInstance():setBccoin(bccoins);
        end

        local soul = data.soul:get_value();
        if soul then
            UserInfo:getInstance():setSoulCount(soul);
        end
    end
end


ChessController.onGetUserinfo = function(self,msg) 
    if not msg.content or not msg then return end
    if tonumber(msg.content.open_dialog) == 1 then 
        ChessToastManager.getInstance():showSingle(msg.content.tip_text or "操作成功");
    end
    if msg.content.user then
        local userInfo = msg.content.user;
        local propInfo = json.decode(userInfo.prop_info);
        if propInfo then
            for key,value in pairs(propInfo) do
                UserInfo.saveProp(key.."",value);
            end
        end

        local isVip = userInfo.is_vip;
        if isVip then
            UserInfo:getInstance():updateVipStatus(isVip);
        end

        local money = userInfo.money;
        if money then
            UserInfo:getInstance():setMoney(money);
        end

        local bccoins = userInfo.bccoins;
        if bccoins then
            UserInfo:getInstance():setBccoin(bccoins);
        end

        local soul = userInfo.soul;
        if soul then
            UserInfo:getInstance():setSoulCount(soul);
        end
    end
end

ChessController.onRecvServerInvitResponse = function(self, packetInfo)
	self:updateView(OnlineRoomSceneNew.s_cmds.deleteInvitAnim);
    if packetInfo.ret == 0 then
        --对方接受挑战
        ChessToastManager.getInstance():show("对方接受挑战");
    else
        --对方拒绝，请求重置状态
        local data = {};
        data.uid = UserInfo.getInstance():getUid();
        data.status = 1;
        self:sendSocketMsg(CLIIENT_CMD_RESET_TABLE,data,nil,1);
    end
end;

if kPlatform == kPlatformIOS then
    ChessController.appStorePayOrderCallBack = function(self,flag,message)
        Log.i("MallController.appStorePayOrderCallBack");
        if not flag then
            if type(message) == "number" then
                return; 
            elseif message.error then
                ChessToastManager.getInstance():showSingle(message.error:get_value());
                return;
            end;        
        end;
        local responseData = message.data;
        -- Log.i("MallController.appStorePayOrderCallBack---->"..json.encode(responseData));
        if responseData ~= nil then
            local order = {};
            order.uid = tostring(UserInfo.getInstance():getUid());
            order.sitemid = tostring(UserInfo.getInstance():getSitemid());
            local jsonData = json.encode(order);
            dict_set_string("payIOSAppStoreFinished", "payIOSAppStoreFinished" .. kparmPostfix, jsonData);
            call_native("payIOSAppStoreFinished");
        end
    end
end;

ChessController.getUserMailGetNewMailNumber = function(self,isSuccess,message)
    if not isSuccess or message.data:get_value() == nil then
        return ;
    end
    local data = message.data;

	if not data then
		print_string("not data");
		return
	end

    local num = tonumber(data.new_mail:get_value()) or 0;
    GameCacheData.getInstance():saveInt(GameCacheData.NOTICE_NUM..UserInfo.getInstance():getUid(),num);
    if num > 0 then
        BottomMenu.getInstance():setOwnBtnTipVisible();
    end
end

-------------------- config --------------------------------------------------
ChessController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.LoginWin32]             = ChessController.onLoginCallBack;
    [HttpModule.s_cmds.GuestZhLogin]           = ChessController.onLoginCallBack;
    [HttpModule.s_cmds.getPropList]            = ChessController.getPropListCallBack;
    [HttpModule.s_cmds.getShopInfo]            = ChessController.getShopInfoCallBack;
    [HttpModule.s_cmds.exchangeProp]           = ChessController.exchangePropCallBack;
    [HttpModule.s_cmds.getUserInfo]            = ChessController.getUserInfoCallBack;
    [HttpModule.s_cmds.checkVersion_new]       = ChessController.onCheckVersion;
    [HttpModule.s_cmds.createOrder]            = ChessController.onCreateOrder;
    [HttpModule.s_cmds.getFriendUserInfo]      = ChessController.onFriendCmdCheckUserData;
    [HttpModule.s_cmds.reportBad]              = ChessController.onReportBad;
    [HttpModule.s_cmds.uploadGetuiClientid]    = ChessController.onUploadGetuiCID;
    [HttpModule.s_cmds.getMonthCombat]         = ChessController.updateMonthCombat;
    [HttpModule.s_cmds.getCityConfig]          = ChessController.onGetCityData;
    [HttpModule.s_cmds.IndexGetNotice]         = ChessController.onIndexGetNotice;
    [HttpModule.s_cmds.appStorePayOrder]       = ChessController.appStorePayOrderCallBack;
    [HttpModule.s_cmds.IndexStartConfig]      = ChessController.onIndexGetStartConfig;
    [HttpModule.s_cmds.IndexClientReportLog]      = ChessController.onIndexClientReportLog;
    [HttpModule.s_cmds.saveUserInfo]            = ChessController.onSaveUserInfo;
    [HttpModule.s_cmds.UserMailAction]              = ChessController.onUserMailAction;
    [HttpModule.s_cmds.UserMailGetNewMailNumber]    = ChessController.getUserMailGetNewMailNumber;
};

ChessController.s_nativeEventFuncMap = {
    [kGuestZhLogin]                 = ChessController.loginGuestZh;
    [kNetStateChange]               = ChessController.onNativeNetStateChange;
    [kAdMananger]                   = ChessController.onSysExit;
    [kActivitySdkCallBack]          = ChessController.onActivitySdkCallBack;
    [kChangeStates]                 = ChessController.onChangeStates;
    [kShareToBoyaa]                 = ChessController.onShareToBoyaa;
    [kSaveChess]                    = ChessController.onSaveChess;
    [kPushGeTuiMsg]                 = ChessController.onPushGetuiMsg;
    [kGetCityInfo]                  = ChessController.onGetCityInfo;
};

ChessController.s_nativeEventCommonFuncMap = {
--    [kCacheImageManager]            = ChessController.onGetDownloadImage;
};


ChessController.s_socketCmdFuncMap = {



    [HALL_MSG_SERVER_PUSH]          =  ChessController.onHallMsgServerPush;


    [HALL_MSG_KICKUSER]             =  ChessController.onHallMsgKickUser;

--    [HALL_MSG_GAMEPLAY]             =  ChessController.onHallMsgGamePlay;
--    [HALL_MSG_GETROOMS]             =  ChessController.onHallMsgGetCustomList;

    [HALL_MSG_LOGIN]                =  ChessController.onHallMsgLogin;
    [HALL_MSG_GAMEINFO]             =  ChessController.onHallMsgGameinfo;
    --接收大厅roomSocket连接信息
    [SERVER_OFFLINE_RECONNECTED]    =  ChessController.onServerOfflineReconnected;
    [CLIENT_MSG_RELOGIN]            =  ChessController.onClientMsgRelogin;
    [CLIENT_MSG_GIVEUP]             =  ChessController.onClientMsgGiveup;
    [CLIENT_HALL_BROADCAST_MGS]     =  ChessController.onHallBroadcastMsg;

    -- friends  cmd 
    [FRIEND_CMD_ONLINE_NUM]         = ChessController.onFriendCmdOnlineNum;
    [FRIEND_CMD_CHECK_USER_STATUS]  = ChessController.onFriendCmdCheckUserStatus;
--    [FRIEND_CMD_CHECK_USER_DATA]    = ChessController.onFriendCmdCheckUserData;
    [FRIEND_CMD_GET_FRIENDS_NUM]    = ChessController.onFriendCmdGetFriendsNum;
    [FRIEND_CMD_GET_FOLLOW_NUM]     = ChessController.onFriendCmdGetFollowNum;
    [FRIEND_CMD_GET_FANS_NUM]       = ChessController.onFriendCmdGetFansNum;
    [FRIEND_CMD_GET_FRIENDS_LIST]   = ChessController.onFriendCmdGetFriendsList;
    [FRIEND_CMD_GET_FOLLOW_LIST]    = ChessController.onFriendCmdGetFollowList;
    [FRIEND_CMD_GET_FANS_LIST]      = ChessController.onFriendCmdGetFansList;
    [FRIEND_CMD_GET_UNREAD_MSG]     = ChessController.onFriendCmdGetUnreadMsg;
    
    [CLIENT_HALL_CREATE_FRIENDROOM] = ChessController.onRecvServerCreateFriendRoom;    --创建好友房
    [FRIEND_CMD_FRIEND_INVIT_NOTIFY]=  ChessController.onInvitNotify;   --好友挑战邀请通知

    [PROP_CMD_QUERY_USERDATA]   = ChessController.onPropCmdQueryUserData;--查询道具

    [FRIEND_CMD_ADD_FLLOW]      = ChessController.updateFriendsListData;
    [FRIEND_CMD_FRIEND_INVIT_RESPONSE2] = ChessController.onRecvServerInvitResponse; --好友挑战返回通知
};

ChessController.s_broadcastCmdFuncMap = {
    [BROADCAST_GOLD]                =  ChessController.onGetGold;
    [BROADCAST_PROP]                =  ChessController.onGetProp;
    [BROADCAST_NEWS]                =  ChessController.onGetNews;
    [BROADCAST_ADS]                 =  ChessController.onGetAds;
    [BROADCAST_VIP]                 =  ChessController.onGetVip;
    [BROADCAST_NOTICE]              =  ChessController.onGetNottice;
    [BROADCAST_USERINFO]            =  ChessController.onGetUserinfo;
}