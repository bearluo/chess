require("config/path_config");

require(BASE_PATH.."chessController");
require(DATA_PATH .. "dailyTaskData");
require("chess/util/statisticsManager");

require(DIALOG_PATH .. "pushActionDialog");
require("animation/broadcastMessageAnim");
require("dialog/toggle_account_dialog");
require("dialog/chioce_dialog");
require("dialog/compete_invite_ad_dialog");

HallController = class(ChessController);

HallController.s_cmds = 
{	
    login                 = 1;
    onlineChess           = 2;
    offlineChess          = 3;
    --replayChess           = 5;
    userInfo              = 6;
    share                 = 7;
    switch_server         = 8;
    toPointWall           = 9;
    toAdSdk               = 10;
	friendMsg             = 11;
    friends               = 12;
    moreSetting           = 13;
    loadNewMsgs           = 14; -- hall_chat_dialog need --
    entryChatRoom         = 15; -- 进入聊天室
    isLogined             = 16;
    getDailyReward        = 17;
    quickPlay             = 20; -- 快速开始
    feedBack              = 21;
    competeChess          = 22; -- 比赛争霸
    updateNumData = 23;         --更新当前在线人数的数据
};

HallController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
    kMusicPlayer.playHallBg();
    if kPlatform == kPlatformIOS then
        -- ios appStore评价开关
        HttpModule.getInstance():execute(HttpModule.s_cmds.appStoreEvaluate);
    else
        HttpModule.getInstance():execute(HttpModule.s_cmds.getAndroidEvaluateConfig);
    end   
    --打开socket接口
    --OnlineSocketManager:getHallInstance():openSocket()
end


HallController.resume = function(self)
	ChessController.resume(self);
	Log.i("HallController.resume");
    if not HallController.isFirstStart then
        HallController.isFirstStart = 0;
        NativeEvent.getInstance():closeStartDialog();
        if kPlatform == kPlatformWin32 then
            self:checkVersion();
        end;
        --self:login();
    end
    if UserInfo.getInstance():isLogin() then
--        OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_ONLINE_NUM);
        self:showAccountModify();
        if UserInfo.getInstance():isLockCompete() and UserInfo.getInstance():canUnlockCompete() then
            UserInfo.getInstance():unlockCompete()
            local msg = "比赛模式已解锁，各类精彩比赛等您来战"
            if not self.mUnlockCompeteDialog then
                self.mUnlockCompeteDialog = new(ChioceDialog)
                self.mUnlockCompeteDialog:setMode(ChioceDialog.MODE_SURE,"前往","关闭");
                self.mUnlockCompeteDialog:setMessage(msg);
                self.mUnlockCompeteDialog:setPositiveListener(self,function()
                    self:competeChess()
                end)
            end
            self.mUnlockCompeteDialog:show()
        end
        UserInfo.getInstance():isFreezeUser()
    end
    -- 获取uuid
    call_native(kGetOldUUID);
    local _,ads_btn_status = UserInfo.getInstance():getAdsStatus();
    if ads_btn_status and ads_btn_status == 2 then
        dict_set_string(kAdMananger,kAdMananger..kparmPostfix,AD_SHOW_BANNER_AD_DIALOG);
        call_native(kAdMananger);
    else
        dict_set_string(kAdMananger,kAdMananger..kparmPostfix,AD_REMOVE_RECOMMEND_BAR);
        call_native(kAdMananger);
    end
end

HallController.toCheckVersion  = function(self)
    self:checkVersion();
end;

HallController.exit_action = function(self)
	sys_exit();
end

HallController.pause = function(self)
	ChessController.pause(self);
	Log.i("HallController.pause");
    dict_set_string(kAdMananger,kAdMananger..kparmPostfix,AD_REMOVE_RECOMMEND_BAR);
    call_native(kAdMananger);
    if self.m_match_ad_dialog then
        self.m_match_ad_dialog:dismiss()
    end
    if self.chioce_dialog then
        self.chioce_dialog:dismiss()
    end
    if self.m_eva_chioce_dialog then
        self.m_eva_chioce_dialog:dismiss()
    end
    if self.m_sociaty_dialog then
        self.m_sociaty_dialog:dismiss()
    end
    if self.m_pushActionDialog then
        self.m_pushActionDialog:dismiss()
    end
end

HallController.dtor = function(self)
    delete(self.chioce_dialog);
    delete(self.m_sociaty_dialog)
    delete(self.m_forbid_chioce_dialog)
end

HallController.onBack = function(self)
    if OnlineUpdate.getInstance():getInstallUpdate() then   --判断是否有更新包需要提示安装
        OnlineUpdate.getInstance():setInstallUpdate(false);
        OnlineUpdate.getInstance():showUpdateDialog();
    else
        self.mobileAdsButton,self.mobileAdsScreen = UserInfo.getInstance():getAdsStatus();
        if self.mobileAdsScreen and self.mobileAdsScreen == 1 and "win32" ~= System.getPlatform() then
            dict_set_string(kAdMananger,kAdMananger..kparmPostfix,AD_CANCEL);
            call_native(kAdMananger);
        else
            self:updateView(HallScene.s_cmds.show_exit_dlg);
        end
    end
end

-------------------------------- father func -----------------------
HallController.onHallMsgLogin =function (self,...)
    ChessController.onHallMsgLogin(self,...)
     self:updateNumData()
end

HallController.onLoginSuccess = function(self,data)
	Log.i("HallController.onLoginSuccess");
    self.mNeedShowAd = true

    self:updateView(HallScene.s_cmds.update_user_money); 
--    UserSetInfo.getInstance():updataSelectData();
    if kPlatform == kPlatformIOS then
        self:updateView(HallScene.s_cmds.ios_audit_status)
    end;
    self:updateView(HallScene.s_cmds.load_unread_msg);
    self:postGetStartViewConfig();
    
    -------拉取城市列表信息--------
    local params = {};
    params.file_version = GameCacheData.getInstance():getInt(GameCacheData.GET_CITY_DATA,0);
    HttpModule.getInstance():execute(HttpModule.s_cmds.getCityConfig,params);
    -------------------------------
    if UserInfo.getInstance():isFreezeUser() then return end;
    
    if UserInfo.getInstance():getTodayFirstLogin() == 1 then
        local msg = "大侠，你的会员特权还有%s天到期哦";
        local vip_time = UserInfo.getInstance():getVipTime();
        local mactivetime = UserInfo.getInstance():getMactivetime();
        local temp = os.difftime(vip_time,mactivetime);
        local temp = math.ceil(temp / 86400)
        if temp and temp <= 3 and temp > 0 then
            msg = string.format(msg,temp)
            if not self.chioce_dialog then
                self.chioce_dialog = new(ChioceDialog);
            end
            self.chioce_dialog:setMode(ChioceDialog.MODE_SURE,"会员续费","取消");
            self.chioce_dialog:setMessage(msg);
            self.chioce_dialog:setPositiveListener(self,function()
                local goods = MallData.getInstance():getVipGoods()
                if not goods or next(goods) == nil then 
                    StateMachine.getInstance():pushState(States.Mall,StateMachine.STYPE_CUSTOM_WAIT);
                    return 
                end
                if kPlatform == kPlatformIOS then
                    HallController.m_PayInterface = PayUtil.getPayInstance(PayUtil.s_payType.Exchange);
		            goods.position = goods.id;
		            HallController.m_pay_dialog = HallController.m_PayInterface:buy(goods,goods.position);
                else
                    local payData = {}
                    payData.pay_scene = PayUtil.s_pay_scene.hall_recommend
                    HallController.m_PayInterface = PayUtil.getPayInstance(PayUtil.s_defaultType);
		            goods.position = MALL_COINS_GOODS;
		            HallController.m_pay_dialog = HallController.m_PayInterface:buy(goods,payData);
                end
            end)
	        self.chioce_dialog:setNegativeListener(nil,nil);
	        self.chioce_dialog:show();
        end
    end

    if kPlatform ~= kPlatformIOS or tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
        --修改 1-第一次注册 0-已经登陆过
        if UserInfo.getInstance():getIsFirstLogin() ~= 1 then
            self.hasShowGetDaily = false;
            MallData.getInstance():sendGetShopInfo();
            MallData.getInstance():getPropData();
            self:showAccountModify();
            DailyTaskManager.getInstance():sendGetDailyTaskData();
            DailyTaskManager.getInstance():sendGetNewDailyTaskList();
            DailyTaskManager.getInstance():sendGetGrowTaskList();
            local ret = UserInfo.getInstance():getUpdateFirstLogin();
            if ret and ret == 1 then
                self:updateView(HallScene.s_cmds.show_update_guide);
            end
        else
            MallData.getInstance():sendGetShopInfo();
            MallData.getInstance():getPropData();
            DailyTaskManager.getInstance():sendGetDailyTaskData();
            DailyTaskManager.getInstance():sendGetNewDailyTaskList();
            DailyTaskManager.getInstance():sendGetGrowTaskList();
        end
    end;
    if UserInfo.getInstance():getIsReflowUser()== 1 and UserInfo.getInstance():getComeBackRewardNum() then
        local rewardNum = UserInfo.getInstance():getComeBackRewardNum(); 
        self:updateView(HallScene.s_cmds.show_comebackreward_dialog,rewardNum);
    end
    -- 登录成功后重置界面
    self:updateView(HallScene.s_cmds.startRefreshPush)
   
end

HallController.onLoginFail = function(self,data)
	Log.i("HallController.onLoginFail");
--    ChessToastManager.getInstance():show("登录失败，请检查网络，稍后再试！");
end

-------------------------------- function --------------------------
--登陆后发送start页面配置
HallController.postGetStartViewConfig = function(self)
    local startView_data = {}
    startView_data.versions = PhpConfig.getVersions() or kLuaVersion;
    startView_data.bid = PhpConfig.getBid();
    startView_data.mid = UserInfo.getInstance():getUid();
    HttpModule.getInstance():execute(HttpModule.s_cmds.IndexStartConfig,startView_data);
end

HallController.onlineChess = function(self)
    Log.i("HallController.onlineChess");
    -- 封号状态
    if UserInfo.getInstance():isFreezeUser() then return end;
    -- 判断是否联网
    if not self:isLogined() then return ;end
    StateMachine.getInstance():pushState(States.Online,StateMachine.STYPE_CUSTOM_WAIT);
end;

HallController.offlineChess = function(self)
    Log.i("HallController.offlineChess");
    StateMachine.getInstance():pushState(States.Offline,StateMachine.STYPE_CUSTOM_WAIT);
end

-- 比赛争霸
HallController.competeChess = function( self )
    Log.i("HallController.competeChess");
    -- 封号状态
    if UserInfo.getInstance():isFreezeUser() then return end;
    -- 判断是否联网
    if not self:isLogined() then return ;end

    StateMachine.getInstance():pushState(States.Compete,StateMachine.STYPE_CUSTOM_WAIT);
end

HallController.userInfo = function(self)
    Log.i("HallController.userInfo");
    if not self:isLogined() then return ;end
    local id = UserInfo.getInstance():getUid()
    StateMachine.getInstance():pushState(States.FriendsInfo,StateMachine.STYPE_CUSTOM_WAIT,nil,id);
end;


HallController.tofriends = function(self) --跳转好友界面 ZY
    Log.i("HallController.feekback");
    --if not self:isLogined() then return ;end
    StateMachine.getInstance():pushState(States.Rank,StateMachine.STYPE_CUSTOM_WAIT,nil,2);
end

HallController.onFriendMsg = function(self)
    Log.i("HallController.onFriendMsg");
    if not self:isLogined() then return ;end
    StateMachine.getInstance():pushState(States.FriendMsg,StateMachine.STYPE_CUSTOM_WAIT);    
end;

HallController.onLoadNewMsgs = function(self)
    self:sendSocketMsg(FRIEND_CMD_GET_UNREAD_MSG);
end;

HallController.onEntryChatRoom = function(self,room_id)
    local packetInfo = {};
    packetInfo.room_id = room_id;
    self:sendSocketMsg(CHATROOM_CMD_ENTER_ROOM,packetInfo);
end;

HallController.share = function(self)
    Log.i("HallController.share");
    if not self:isLogined() then return ;end
    StateMachine.getInstance():pushState(States.shareModel,StateMachine.STYPE_CUSTOM_WAIT);
end

HallController.switchServer = function(self)
    self.m_hallSocket:closeSocketSync();
    self.m_hallSocket:openSocket();
    self:login();
end;

HallController.toPointWall = function(self)
    print_string("to pointWall");
--    if not self:isLogined() then return ;end
--    self.mobileAdsButton,self.mobileAdsScreen = UserInfo.getInstance():getAdsStatus();
--    if self.mobileAdsButton == 0 then--0表示关闭"更多游戏"，直接进入联网房间
--        UserInfo.getInstance():setIsFromHall(true)
--    elseif self.mobileAdsButton == 1 then--1进入积分墙
--        local uid = UserInfo.getInstance():getUid();
--        local mtkey = PhpConfig.getMtkey();
--        local data = {};
--        data.uid = uid;
--        data.mtkey = mtkey;
--        data.developUrl = PhpConfig.develop;
--        dict_set_string(kShowPointWall,kShowPointWall..kparmPostfix, json.encode(data));
--        call_native(kShowPointWall);        
--    elseif self.mobileAdsButton == 2 then --2进入广告sdk
--        self:toAdSdk();
--    end

end;

HallController.toAdSdk = function(self)
    print_string("to toAdSdk");
    if not self:isLogined() then return ;end

--    self.mobileAdsButton,self.mobileAdsScreen = UserInfo.getInstance():getAdsStatus();

--    if self.mobileAdsButton == 2 then
--        dict_set_string(kAdMananger,kAdMananger..kparmPostfix,AD_SHOW_SUDOKU_DIALOG);
--        call_native(kAdMananger);
--    end
end

-- 显示账号引导界面
HallController.showAccountModify = function(self)
    -- local isBind = UserInfo.getInstance():getBindAccount()[0];
    local sevenTimes = 604800;
    local onlineGameTimes = GameCacheData.getInstance():getInt(GameCacheData.ONLINE_PLAY_TIMES, 0); -- 联网游戏次数
    local popModifyTipTimes = GameCacheData.getInstance():getInt(GameCacheData.SHOW_MODIFY_TIP_TIMES, 0);
    local popBindingTipTimes = GameCacheData.getInstance():getInt(GameCacheData.SHOW_BINDING_TIP_TIMES, 0);
    

    --GameCacheData.getInstance():saveInt(GameCacheData.SHOW_BINDING_TIP_TIMES,0);

    -- 满足条件，弹出完善信息界面  
    if popModifyTipTimes == 0 and onlineGameTimes >= 3 then
        if UserInfo.getInstance():getIconType() == -1 then
            --GameCacheData.getInstance():saveInt(GameCacheData.SHOW_MODIFY_TIP_TIMES,1);
        else
            self:updateView(HallScene.s_cmds.show_account_dialog,1);
        end
        GameCacheData.getInstance():saveInt(GameCacheData.SHOW_MODIFY_TIP_TIMES,1);
    end

    -- 满足条件，弹出绑定界面
    if not next(UserInfo.getInstance():getBindAccount()) and onlineGameTimes >= 20 then
        local totalTime = 0;
        local lastShowTime = GameCacheData.getInstance():getDouble(GameCacheData.TIP_START_TIME,0); -- 上一次显示时间
        if lastShowTime ~= 0 then
            local endShowtime = os.time();
            totalTime = endShowtime - lastShowTime;
            GameCacheData.getInstance():saveDouble(GameCacheData.TIP_START_TIME,endShowtime);
        end
        if popBindingTipTimes == 0 then
            self:updateView(HallScene.s_cmds.show_account_dialog,0);
            local startTime = os.time();
            GameCacheData.getInstance():saveDouble(GameCacheData.TIP_START_TIME,startTime);
        elseif totalTime >= sevenTimes then
            self:updateView(HallScene.s_cmds.show_account_dialog,0);
        end
    end
   
end


HallController.updateUserInfoView = function(self)
    self:updateView(HallScene.s_cmds.update_user_money);
end

HallController.getUserInfo = function(self,flag ,json_data)
	local tips = "正在获取玩家信息...";
	local post_data = {};
	post_data.mid = UserInfo.getInstance():getUid();
    HttpModule.getInstance():execute(HttpModule.s_cmds.getUserInfo,post_data,tips);
end


HallController.adSDKStatus = function(self, flag, json_data)
	
    if not flag or not json_data  then
		return;
	end

	local status = "";
    local key = "";
	if json_data.status:get_value() then
		status = json_data.status:get_value();
	end	
    if json_data.key:get_value() then
		key = json_data.key:get_value();
	end
    if key == AD_CANCEL and status == 0 then
        self:updateView(HallScene.s_cmds.show_exit_dlg);
    elseif key == AD_SHOW_SUDOKU_DIALOG and status == 0 then--广告sdk弹出失败，就进积分墙
        local uid = UserInfo.getInstance():getUid();
        local mtkey = PhpConfig.getMtkey();
        local data = {};
        data.uid = uid;
        data.mtkey = mtkey;
        data.developUrl = PhpConfig.develop;
        dict_set_string(kShowPointWall,kShowPointWall..kparmPostfix, json.encode(data));
        call_native(kShowPointWall);   
        
    end;

end;

HallController.onFriendCmdOnlineNum = function(self,info)
    if not info then return end;
--    self:updateView(HallScene.s_cmds.update_online_num,info.online_num);
end

HallController.onFriendCmdGetUnreadMsg = function(self,info)
    self.super.onFriendCmdGetUnreadMsg(self,info)
--    FriendsData.getInstance():onGetFriendsMsg(info);
end

HallController.onRecvServerEntryChatRoom  = function(self,packetInfo)
    self:updateView(HallScene.s_cmds.entry_chat_room,packetInfo);
end

HallController.onRecvServerUnreadMsg = function(self,packetInfo)
    if self.m_view:getChatDialog() then
        self.m_view:getChatDialog():onRecvServerUnreadMsg(packetInfo);
    end
end

HallController.onRecvServerUnreadMsgNew = function(self,packetInfo)
    if self.m_view:getChatDialog() then
        self.m_view:getChatDialog():onRecvServerUnreadMsgNew(packetInfo);
    end
end

HallController.onRecvServerChessMatchMsg = function(self,packetInfo)
    if self.m_view:getChatDialog() then
        self.m_view:getChatDialog():onRecvServerChessMatchMsg(packetInfo);
    end
end

HallController.onRecvServerChessMatchMsgNum = function(self,packetInfo)
    if self.m_view:getChatDialog() then
        self.m_view:getChatDialog():onRecvServerChessMatchMsgNum(packetInfo);
    end
end
--0：代表成功； 
-->0：代表被禁言的解禁时间； 
-- -1：代表重复发言或者内容为空； 
-- -2：不可以应战自己创建的约战； 
-- -3：其他人已应战过； 
-- -4：不可以取消已对局的约战； 
-- -5：不可以取消别人创建的约战； 
-- -6： 约战操作类型未知；
-- -7：聊天室不存在； 
-- -8：约战已过期；
-- -9：发消息者不是约战玩家; 
-- -10：不可进入状态；
HallController.onRecvUserSendMsg = function(self, packetInfo)
    if packetInfo.status ~= 0 then
        if packetInfo.status > 0 then
            if self:isForbidSendMsg(packetInfo.status) then
                return;           
            else
                ChessToastManager.getInstance():showSingle("消息发送失败了",2000);
            end;
        elseif packetInfo.status == -1 then 
            ChessToastManager.getInstance():showSingle("亲，消息不能为空或频繁发送哦",1500);
        elseif packetInfo.status == -2 then 
            ChessToastManager.getInstance():showSingle("亲，不可以应战自己创建的约战",1500);
        elseif packetInfo.status == -3 then 
            ChessToastManager.getInstance():showSingle("亲，其他人已应战",1500);
        elseif packetInfo.status == -4 then 
            ChessToastManager.getInstance():showSingle("亲，不可以取消已对局的约战",1500);
        elseif packetInfo.status == -5 then
            ChessToastManager.getInstance():showSingle("亲，不可以取消别人创建的约战",1500);
        elseif packetInfo.status == -6 then
            ChessToastManager.getInstance():showSingle("亲，约战操作类型未知",1500);
        elseif packetInfo.status == -7 then
            ChessToastManager.getInstance():showSingle("亲，聊天室不存在",1500);
        elseif packetInfo.status == -8 then 
            ChessToastManager.getInstance():showSingle("亲，约战不存在",1500);
            self:hideChatRoomMask();
        elseif packetInfo.status == -9 then 
            ChessToastManager.getInstance():showSingle("亲，发消息者不是约战玩家",1500);
        elseif packetInfo.status == -10 then 
            ChessToastManager.getInstance():showSingle("亲，不可进入状态",1500);
        elseif packetInfo.status == -11 then 
            ChessToastManager.getInstance():showSingle("亲，有一个未结束的约战",1500);
        elseif packetInfo.status == -12 then 
            ChessToastManager.getInstance():showSingle("亲，不可以加入他人的约战",1500);
        elseif packetInfo.status == -13 then 
            ChessToastManager.getInstance():showSingle("当前应战玩家过多，应战失败",1500);
        end;
    end
end;

HallController.hideChatRoomMask = function(self)
    if self.m_view:getChatDialog() then
        self.m_view:getChatDialog():hideChatRoomMask();
    end
end;

HallController.onRecvServerUserChatMsg = function(self, packetInfo)
    if self.m_view:getChatDialog() then
        self.m_view:getChatDialog():onRecvServerBroadCastMsg(packetInfo);
    end
end;


HallController.onRecvServerUnreadMsgNum = function(self, packetInfo)
    if self.m_view:getChatDialog() then
        self.m_view:getChatDialog():onRecvServerUnreadMsgNum(packetInfo);
    end
end;


HallController.isForbidSendMsg = function(self,forbid_time)
    if forbid_time and forbid_time > 0 then
        local tip_msg = "很抱歉，您的账号被多次举报，经核实已被禁言，将于"..os.date("%Y-%m-%d %H:%M",forbid_time) .."解禁，感谢您的配合和理解。"
        if not self.m_forbid_chioce_dialog then
            self.m_forbid_chioce_dialog = new(ChioceDialog);
        end;
        self.m_forbid_chioce_dialog:setMode(ChioceDialog.MODE_SURE);
        self.m_forbid_chioce_dialog:setMessage(tip_msg);
        self.m_forbid_chioce_dialog:show();
        return true;
    end; 
    return false;
end;

HallController.onRecvCommonChatMsg = function(self, packetInfo)
--    if self.m_view:getChatDialog() then
--        self:isForbidSendMsg(packetInfo.forbid_time);
--        self.m_view:getChatDialog():onRecvCommonChatMsg(packetInfo);
--    end
end;

HallController.onRecvCommonChatMsg2 = function(self, packetInfo)
    if self.m_view:getChatDialog() then
        self:isForbidSendMsg(packetInfo.forbid_time)
        self.m_view:getChatDialog():onRecvCommonChatMsg2(packetInfo);
    end
end

HallController.onRecvServerGetMemberList = function(self, packetInfo)
    if self.m_view:getChatDialog() then
        self.m_view:getChatDialog():onRecvServerGetMemberList(packetInfo);
    end
end;

HallController.onRecvServerIsActAvaliable = function(self, packetInfo)
    if self.m_view:getChatDialog() then
        self.m_view:getChatDialog():onRecvServerIsActAvaliable(packetInfo);
    end
end;

HallController.onRecvServerUpdateCRItem = function(self, packetInfo)
    if self.m_view:getChatDialog() then
        self.m_view:getChatDialog():onRecvServerUpdateCRItem(packetInfo);
    end
end;

HallController.onRecvServerCheckUserState = function(self, packetInfo)
    if self.m_view:getChatDialog() then
        self.m_view:getChatDialog():onRecvServerCheckUserState(packetInfo);
    end
end;

HallController.onHallMsgCreateRoom = function(self, info)

    if not info or info.ret ~= 0 then
		if not self.m_chioce_dialog then
			self.m_chioce_dialog = new(ChioceDialog);
		end

		self.m_chioce_dialog:setMode(ChioceDialog.MODE_OK);
		local message="创建自定义房间失败";
		self.m_chioce_dialog:setMessage(message);
	    self.m_chioce_dialog:setPositiveListener(nil,nil);
		self.m_chioce_dialog:show();
        return;
    end;
    if UserInfo.getInstance():getCustomRoomType() == 1 then
        RoomProxy.getInstance():setTid(info.tid);
        UserInfo.getInstance():setCustomRoomID(info.tid);
        if self.m_view:getChatDialog() then
            self.m_view:getChatDialog():send1v1Chess();
        end;  
    elseif UserInfo.getInstance():getCustomRoomType() == 2 then
        RoomProxy.getInstance():setTid(info.tid);
        UserInfo.getInstance():setCustomRoomID(info.tid);
        if self.m_view:getChatDialog() then
            self.m_view:getChatDialog():sendInviteChess();
        end;
    elseif UserInfo.getInstance():getCustomRoomType() == 3 then
        RoomProxy.getInstance():setTid(info.tid);
        UserInfo.getInstance():setCustomRoomID(info.tid);
        UserInfo.getInstance():setCustomRoomType(3);
        RoomProxy.getInstance():gotoPrivateRoom(true)    
    end
end

HallController.onRecvServerAddFllow = function(self,info)
    if not info then return end
    local chatdialog = self.m_view:getChatDialog();
    local uniondialog = self.m_view:getUnionDialog();

    if chatdialog and chatdialog:isShowing() then
        chatdialog:onRecvServerAddFllow(info);
        return;
    end
    -- 同城
--    if uniondialog and uniondialog:isShowing() then
--        uniondialog:onRecvServerAddFllow(info);
--        return;
--    end

end

HallController.onSaveUserInfoCityCode = function(self,isSuccess,message)
    if self.m_view:getChatDialog() then
        self.m_view:getChatDialog():onSaveUserInfoCityCode(isSuccess,message);
    end
end;

HallController.onRecvUnreadMsg = function(self, data)
    self:updateView(HallScene.s_cmds.update_unread_msg, true);
end;

HallController.onRecvSociatyNotice = function(self, packetInfo)
    if self.m_view:getChatDialog() then
        self.m_view:getChatDialog():onRecvSociatyNoticeMsg(packetInfo);
    end
end;

--收到除私人房的在线人数后的回调函数
--HallController.onRecvOnlineAndMatchNum = function (self, packetInfo)

--    local roomConfig        = RoomConfig.getInstance();
--    local noviceData        = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_NOVICE_ROOM);
--    local intermediateData  = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_INTERMEDIATE_ROOM);
--    local masterData        = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_MASTER_ROOM);
--    local arenaData         = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_ARENA_ROOM);

--    if packetInfo then       
--        local roomPlayer = {}
--        for key,val in pairs(packetInfo) do
--            roomPlayer[key] = val
--        end
--        if roomPlayer[noviceData.level] then 
--            self.onlineNumLock = false    --解锁
--            self.onlineNum = (roomPlayer[noviceData.level] or 0) + (roomPlayer[intermediateData.level] or 0) + (roomPlayer[masterData.level] or 0) + 
--                             (roomPlayer[arenaData.level] or 0) + (packetInfo["watch"] or 0)     
--            UserInfo.getInstance():setRoomPlayerNum(roomPlayer)           
--            self:isShowOnlineNumView()   
--        else
--            self.matchGoldNum = 0
--            for _,v in pairs(self.match_level) do 
--                local v1 =tonumber(v) or 0
--                self.matchGoldNum = self.matchGoldNum + (roomPlayer[v1] or 0)
--                self.matchGoldNumLock=false
--            end 
--            self:isShowMatchNumView()
--        end
--    end

--end

--收到私人房的在线人数后的回调函数
--HallController.onRecvOnlinePrivateNum = function (self, packageInfo)   
--    if packageInfo then 
--        self.onlinePrivateNumLock = false
--        self.onlinePrivateNum = tonumber(packageInfo.num) or 0
--        self:isShowOnlineNumView()
--    end
--end

--收到当前在线总人数后的回调函数
HallController.onRecvAllPlayNum = function (self, packageInfo)
    local consoleNum = packageInfo.consoleNum
    local onlineNum = packageInfo.onlineNum
    local matchNum = packageInfo.matchNum
    self:updateView(HallScene.s_cmds.update_console_num,consoleNum)
    self:updateView(HallScene.s_cmds.update_online_num,onlineNum)
    self:updateView(HallScene.s_cmds.update_match_num,matchNum)
--    if packageInfo then 
--        self.consoleAllNumLock = false
--        self.AllNum = data
--        self:isShowConsoleNumView()
--    end 
end
----------------------------------------------------------------------
----------------------------- 辅助逻辑函数 ---------------------------
----------------------------------------------------------------------
--function HallController.isShowOnlineNumView(self)
--    if not self.onlineNumLock and not self.onlinePrivateNumLock then 
--        self.consoleOnlineNumLock = false
--        self.onlineAllNum = self.onlineNum + self.onlinePrivateNum
--        local num = self.onlineAllNum
--        self:updateView(HallScene.s_cmds.update_online_num,num)
--        self:isShowConsoleNumView()
--    end
--end

--function HallController.isShowMatchNumView(self)
--    if not self.matchNumLock and not self.matchGoldNumLock then 
--        self.consoleMatchNumLock = false 
--        self.matchAllNum = self.matchNum + self.matchGoldNum
--        local num = self.matchAllNum
--        self:updateView(HallScene.s_cmds.update_match_num,num)
--        self:isShowConsoleNumView()
--    end
--end

--function HallController.isShowConsoleNumView(self)
--    if not self.consoleAllNumLock and not self.consoleMatchNumLock and not self.consoleOnlineNumLock then
--        local num = self.AllNum - self.onlineAllNum - self.matchAllNum
--        self:updateView(HallScene.s_cmds.update_console_num,num)
--    end 
--end
----------------------------------------------------------------------
----------------------------- 辅助逻辑函数 ---------------------------
----------------------------------end---------------------------------


-------------------------------- http event ------------------------

HallController.onGetConsoleProgressResponse = function(self,isSuccess,message)
    Log.i("onGetConsoleProgressResponse");
    if not isSuccess then
        return ;
    end
end

HallController.onGetUserInfoResponse = function(self,isSuccess,message)
    Log.i("onGetUserInfoResponse");
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
	end
    self:updateUserInfoView();
end

if kPlatform == kPlatformIOS then
    HallController.onGetIosAppStoreEvaluate = function(self,flag, message)
        if not flag then
            if type(message) == "number" then
                return; 
            elseif message.error then
                ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
                return;
            end;        
        end;
        local data = json.analyzeJsonNode(message.data);
        UserInfo.getInstance():setIosAuditStatus(data.ios_audit_status);
    end
end

HallController.onGetAndroidEvaluateConfig = function(self,flag, message)
    if not flag then
        if type(message) == "number" then
            return; 
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
            return;
        end;        
    end;
    local data = json.analyzeJsonNode(message.data);
    UserInfo.getInstance():setAuditStatus(data.android_audit_status);
end

HallController.getNoticeMsgCallBack = function(self,isSuccess,message)
    Log.i("getNoticeMsgCallBack");
    if not isSuccess or message.data:get_value() == nil then
        return ;
    end

    local data = message.data;

	if not data then
		print_string("not data");
		return
	end
    local cnt = 0;
	for _,value in pairs(data) do 
        cnt = cnt + 1;
	end
    
    local num = GameCacheData.getInstance():getInt(GameCacheData.NOTICE_NUM,0);

    if cnt > num then
    end
end

function HallController:quickPlay()
    -- 封号状态
    if UserInfo.getInstance():isFreezeUser() then return end;
    -- 判断是否联网
    if not self:isLogined() then return ;end
    local roomConfig = RoomConfig.getInstance();
    local money = UserInfo.getInstance():getMoney();
    local gotoRoom = RoomProxy.getInstance():getMatchRoomByMoney(money);
    
    if not gotoRoom then 
        ChessToastManager.getInstance():showSingle("没有合适的场次");
    else
        StatisticsManager.getInstance():onCountQuickPlay(gotoRoom);
        RoomProxy.getInstance():gotoLevelRoom(gotoRoom.level);
    end
end

HallController.onIndexGetPushActionList = function(self,isSuccess,message)
    if not isSuccess or message.data:get_value() == nil then
        return ;
    end
    local data = json.analyzeJsonNode(message.data);
    if data then
        
        delete(self.m_pushActionDialog);
        self.m_pushActionDialog = new(PushActionDialog,data);
        self.m_pushActionDialog:show();
    end
end

HallController.onShowMatchAdDialog = function(self,isSuccess,message)
    if not isSuccess then
        if type(message) == "number" then
            return; 
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
            return;
        end;        
    end;
    local data = json.analyzeJsonNode(message.data);
    if data.is_open and tonumber(data.is_open) == 1 then
        if kPlatform == kPlatformIOS then
            if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then 
                if not self.m_match_ad_dialog then
                    self.m_match_ad_dialog = new(CompeteInviteAdDialog,data);
                end;
                self.m_match_ad_dialog:setLevel(1)
                self.m_match_ad_dialog:show();
            end;
        else
            if not self.m_match_ad_dialog then
                self.m_match_ad_dialog = new(CompeteInviteAdDialog,data);
            end;
            self.m_match_ad_dialog:setLevel(1)
            self.m_match_ad_dialog:show();            
        end;
    end;
    if ChessController.m_notice_dialog then
        ChessController.m_notice_dialog:show();
    end
end;

function HallController:feedBack()
    Log.i("HallController.feedBack");
    if not self:isLogined() then return ;end
    if kPlatform == kPlatformIOS then
        StateMachine.getInstance():pushState(States.Feedback,StateMachine.STYPE_CUSTOM_WAIT);
    else
        if not kFeedbackGameid or not kFeedbackSiteid then
            self:loadFeedbackInfo()
            ChessToastManager.getInstance():showSingle("反馈参数出错了:(");
            return;
        end;
        local postData = {};
        postData.game_id = kFeedbackGameid;
        postData.site_id = kFeedbackSiteid;
        postData.uid = UserInfo.getInstance():getUid();
        postData.user_name = UserInfo.getInstance():getName();
        postData.user_icon_url = UserInfo.getInstance():getIcon();
        postData.is_kefu_vip = (tonumber(kIsFeedbackVip) == 1 and "3") or "2"; 
        postData.kefu_vip_level = (tonumber(kIsFeedbackVip) == 1 and kFeedbackVipLevel) or "normal";
        postData.account_type = UserInfo.getInstance():getAccountTypeName();
        postData.client = kIsFeedbackClient;
        dict_set_string(kLoadFeedbackSdk, kLoadFeedbackSdk .. kparmPostfix,json.encode(postData));
        call_native(kLoadFeedbackSdk);
    end;
end
--发送服务器请求更新数据
HallController.updateNumData = function (self)
    --因为联网数据的统计是用两个接口来获取的，所以这里会存在一个数据异步到达同步显示的问题，解决方法是加入数据显示锁，数据都到达后解锁显示
    --true为数据锁住当前不显示，false为解锁
    if not UserInfo.getInstance():isLogin() then return end
--    self.onlineNumLock = true      --联网人数锁
--    self.onlinePrivateNumLock = true     --私人房锁

--    self.matchNumLock = true   --赏金赛的锁
--    self.matchGoldNumLock = true   --金币赛的锁

--    self.consoleOnlineNumLock = true   --获取到联网在线总人数的锁
--    self.consoleMatchNumLock = true    --获取到比赛在线总人数的锁
--    self.consoleAllNumLock = true      --获取到所有在线总人数的锁

--    self:updateOnlineNumData()

--    self:updateMatchNumData()
    self:updateTotalNumData()
end

--require("config/roomConfig")
----发送服务器请求,请求联网除了私人房的其他在线人数
--HallController.updateOnlineNumData = function (self)
--    local roomConfig        = RoomConfig.getInstance()
--    local noviceData        = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_NOVICE_ROOM);
--    local intermediateData  = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_INTERMEDIATE_ROOM);
--    local masterData        = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_MASTER_ROOM);
--    local arenaData         = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_ARENA_ROOM);
--    local info = {}
--    if noviceData then
--        table.insert(info,noviceData.level)
--    end
--    if intermediateData then
--        table.insert(info,intermediateData.level)
--    end
--    if masterData then
--        table.insert(info,masterData.level)
--    end
--    if arenaData then
--        table.insert(info,arenaData.level)
--    end
--    self:sendSocketMsg(HALL_MSG_GAMEPLAY,info, SUBCMD_LADDER ,2);
--end

--发送sever请求，获取私人房当前在线人数
--HallController.updateOnlinePrivateNumData = function (self,level )
--    if level then 
--        self:sendSocketMsg(HALL_MSG_PRIVATE_ROOM_PLAY_NUM,level);
--    end
--end

--获取比赛在线人数
--function HallController.updateMatchNumData(self)
--    HttpModule.getInstance():execute2(HttpModule.s_cmds.getMatchList,data,function(isSuccess,resultStr)
--                    self:onGetMatchListHttpCallBack(isSuccess,resultStr)
--                end);
--end

--发送sever请求，获取联网 单机 比赛人数
HallController.updateTotalNumData = function (self)
    local info ={}
    self:sendSocketMsg(HALL_MSG_ALL_PLAY_NUM,info);
end

function HallController.onGetSociatyInfoCall(self,data)
    if not data then
--        ChessToastManager.getInstance():showSingle("")
        return
    end
    if not self.m_sociaty_dialog then
        self.m_sociaty_dialog = new(CreateAndCheckSociatyDialog);
    end
    self.m_sociaty_dialog:setSociatyData(data)
    self.m_sociaty_dialog:setDialogStatus(CreateAndCheckSociatyDialog.s_check_mode);
    self.m_sociaty_dialog:show();
end

function HallController.getUserMailGetNewMailNumber(self,isSuccess,message)
    ChessController.getUserMailGetNewMailNumber(self,isSuccess,message)
    local num = GameCacheData.getInstance():getInt(GameCacheData.NOTICE_NUM..UserInfo.getInstance():getUid(),0);
    if num > 0 then
        self:updateView(HallScene.s_cmds.show_mail_tips);
    end
end

function HallController.showHallChatNotice(self)
    self:updateView(HallScene.s_cmds.show_hall_chat);
end

HallController.getChatMatchConfig = function(self,isSuccess,message)
    if not isSuccess then
        if type(message) == "number" then
            return; 
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
            return;
        end;        
    end;
    local data = json.analyzeJsonNode(message.data);
    UserInfo.getInstance():setChatRoomMatchConfig(data);
end;

--http请求获取比赛列表的数据回调接口
--function HallController.onGetMatchListHttpCallBack(self,isSuccess,resultStr)
--    if not isSuccess then return end
--    message = json.decode(resultStr);
--    local data = message.data;
--    if type(data) ~= "table" then return end
--    self.match_level = {}
--    self.matchNum = 0      --赏金赛的人数
--    for _,v in pairs(data) do
--        local type = tonumber(v.type) or 0
--        --金币赛人数要用level去sever请求数据
--        if type == 12 then 
--            table.insert(self.match_level, v.level)
--        end
--        --赏金赛人数直接在比赛列表里获取
--        if type == 13 then 
--            self.matchNum = self.matchNum + (v.join_num or 0)            
--        end
--        self.matchNumLock=false
--    end
--    --通过socket请求level对应的num值
--    if self.match_level then 
--        self:sendSocketMsg(HALL_MSG_GAMEPLAY,self.match_level, SUBCMD_LADDER ,2);
--    end
--    --ChessController.onIndexGetMatchConfig(self, isSuccess, message)  --保存配置
--    local roomConfig = RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_PRIVATE_ROOM); -- 私人房
--    if roomConfig then
--        local level = roomConfig.level;
--        self:updateOnlinePrivateNumData(level)
--    end
--end

HallController.onGetChessSociatyRecommendCallBack = function(self,isSuccess,message)
    if not isSuccess then
        if type(message) == "number" then
            return; 
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
            return;
        end;        
    end;
    if not message or type(message) ~= "table" then return end
    if not message.data then return end
    local data = {};
    data = json.analyzeJsonNode(message.data)
    EventDispatcher.getInstance():dispatch(ChessSociatyModuleView.s_event.Refresh,krecommendCallBack,data);
end;

HallController.onGoodsGetPromotionSaleGoods = function(self,isSuccess,message)
    ChessController.onGoodsGetPromotionSaleGoods(self,isSuccess,message)
    self:updateView(HallScene.s_cmds.update_promotion_sale_goods)
end

HallController.ongetUserFreezeType = function (self,isSuccess,message)
    if not isSuccess then return end
    local time = message.time:get_value();
    local dataText = message.data.text:get_value();
    local dataType = message.data["type"]:get_value();

    local user = UserInfo.getInstance();
	user:setUserFreezeType(dataType);
    user:setFreezeTypeText(dataText);
    user:showFreezeDialog();
end

-------------------------------- config ----------------------------

HallController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.GetConsoleProgress]          = HallController.onGetConsoleProgressResponse;
    [HttpModule.s_cmds.getUserInfo]                 = HallController.onGetUserInfoResponse;
    [HttpModule.s_cmds.appStoreEvaluate]            = HallController.onGetIosAppStoreEvaluate;
    [HttpModule.s_cmds.getAndroidEvaluateConfig]    = HallController.onGetAndroidEvaluateConfig;
    [HttpModule.s_cmds.IndexGetPushActionList]      = HallController.onIndexGetPushActionList;
    [HttpModule.s_cmds.matchAdDialog]               = HallController.onShowMatchAdDialog;
    [HttpModule.s_cmds.UserMailGetNewMailNumber]    = HallController.getUserMailGetNewMailNumber;
    [HttpModule.s_cmds.getChatMatchConfig]          = HallController.getChatMatchConfig;
    [HttpModule.s_cmds.getRecommendSociaty]         = HallController.onGetChessSociatyRecommendCallBack;
    [HttpModule.s_cmds.GoodsGetPromotionSaleGoods]  = HallController.onGoodsGetPromotionSaleGoods;
    [HttpModule.s_cmds.getUserFreezeType]           = HallController.ongetUserFreezeType;
};

HallController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	HallController.s_httpRequestsCallBackFuncMap or {});


--本地事件 包括lua dispatch call事件
HallController.s_nativeEventFuncMap = {
    [kUpdateUserInfo]               = HallController.getUserInfo;
    [kAdSDKStatus]                  = HallController.adSDKStatus;
    [kFriend_UpdateChatMsg]         = HallController.onRecvUnreadMsg;
    [kFriend_FollowCallBack]        = HallController.onRecvServerAddFllow;
    [kCheckVersion]                 = HallController.toCheckVersion;
    [kSociaty_updataSociatyData2]    = HallController.onGetSociatyInfoCall;
    [kShowHallChatDialog]           = HallController.showHallChatNotice;

    
};


HallController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	HallController.s_nativeEventFuncMap or {});



HallController.s_socketCmdFuncMap = {

    [HALL_MSG_LOGIN]                        = HallController.onHallMsgLogin;
    [FRIEND_CMD_ONLINE_NUM]                 = HallController.onFriendCmdOnlineNum;
    [FRIEND_CMD_GET_UNREAD_MSG]             = HallController.onFriendCmdGetUnreadMsg;
    -- 进入聊天室（大师/同城）
    [CHATROOM_CMD_ENTER_ROOM]               = HallController.onRecvServerEntryChatRoom;
    -- 获取历史消息
    [CHATROOM_CMD_GET_HISTORY_MSG]          = HallController.onRecvServerUnreadMsg;
    -- 获取历史消息
    [CHATROOM_CMD_GET_HISTORY_MSG_NEW]      = HallController.onRecvServerUnreadMsgNew;
    -- 获取约战消息
    [CHATROOM_CMD_GET_CHESS_MATCH_MSG]      = HallController.onRecvServerChessMatchMsg;
    -- 获取约战消息条数
    [CHATROOM_CMD_GET_CHESS_MATCH_MSG_NUM]  = HallController.onRecvServerChessMatchMsgNum;
    -- 发送聊天室消息
    [CHATROOM_CMD_USER_CHAT_MSG]            = HallController.onRecvUserSendMsg;
    -- 聊天室消息发送成功后，接收到server的广播，列表加载消息
    [CHATROOM_CMD_BROAdCAST_CHAT_MSG]       = HallController.onRecvServerUserChatMsg;
    -- 接收聊天室未读消息数量
    [CHATROOM_CMD_GET_UNREAD_MSG2]          = HallController.onRecvServerUnreadMsgNum;
    -- 接收普通聊天消息
    [FRIEND_CMD_CHAT_MSG]                   = HallController.onRecvCommonChatMsg;
    -- 接收普通聊天消息（2.0.5）
    [FRIEND_CMD_CHAT_MSG2]                  = HallController.onRecvCommonChatMsg2;
    -- 聊天室成员列表
    [CHATROOM_CMD_GET_MEMBER_LIST]          = HallController.onRecvServerGetMemberList;
    -- 聊天室动作是否可行
    [CHATROOM_CMD_IS_ACT_AVALIABLE]         = HallController.onRecvServerIsActAvaliable;
    -- 更新聊天室item状态
    [CHATROOM_CMD_UPDATE_CHATROOM_ITEM]     = HallController.onRecvServerUpdateCRItem;
    -- 聊天室内成员列表关注
--    [FRIEND_CMD_ADD_FLLOW]                  = HallController.onRecvServerAddFllow;                --添加或取消关注


    --聊天室私人房邀请
    [FRIEND_CMD_GET_USER_STATUS]            = HallController.onRecvServerCheckUserState;   --发起挑战请求
    [CLIENT_HALL_CREATE_PRIVATEROOM]        = HallController.onHallMsgCreateRoom; -- 聊天室创建私人房回调

    [BROADCAST_SOCIATY_NOTICE]              = HallController.onRecvSociatyNotice;
    --联网当前在线人数(不包括私人房)
--    [HALL_MSG_GAMEPLAY] =  HallController.onRecvOnlineAndMatchNum; 
--    [HALL_MSG_PRIVATE_ROOM_PLAY_NUM] = HallController.onRecvOnlinePrivateNum;
    [HALL_MSG_ALL_PLAY_NUM] = HallController.onRecvAllPlayNum;
}

HallController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	HallController.s_socketCmdFuncMap or {});


------------------------------------- 命令响应函数配置 ------------------------
HallController.s_cmdConfig = 
{
	[HallController.s_cmds.login]		        = ChessController.login;
    [HallController.s_cmds.onlineChess]		    = HallController.onlineChess;
    [HallController.s_cmds.offlineChess]		= HallController.offlineChess;
    [HallController.s_cmds.competeChess]		= HallController.competeChess;

    [HallController.s_cmds.userInfo]            = HallController.userInfo;
    [HallController.s_cmds.share]               = HallController.share;
    [HallController.s_cmds.switch_server]       = HallController.switchServer;
    [HallController.s_cmds.toPointWall]         = HallController.toPointWall;
    [HallController.s_cmds.toAdSdk]             = HallController.toAdSdk;
    [HallController.s_cmds.friendMsg]           = HallController.onFriendMsg;
    [HallController.s_cmds.friends]             = HallController.tofriends; -- 好友界面 ZY
    [HallController.s_cmds.loadNewMsgs]         = HallController.onLoadNewMsgs; -- loadNewMsg;
    [HallController.s_cmds.entryChatRoom]       = HallController.onEntryChatRoom; -- 进入ChatRoom;
    [HallController.s_cmds.isLogined]           = ChessController.isLogined;
    [HallController.s_cmds.getDailyReward]      = ChessController.getDailyReward;
    [HallController.s_cmds.quickPlay]           = HallController.quickPlay;
    [HallController.s_cmds.feedBack]            = HallController.feedBack;
    [HallController.s_cmds.updateNumData]            = HallController.updateNumData;
}