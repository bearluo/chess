require("config/path_config");

require(BASE_PATH.."chessController");
require(DATA_PATH .. "dailyTaskData");

HallController = class(ChessController);

HallController.s_cmds = 
{	
    login = 1;
    onlineChess = 2;
    consoleChess = 3;
    endgateChess = 4;
    replayChess = 5;
    userInfo = 6;
    mall = 7;
    switch_server = 8;
    toPointWall = 9;
    toAdSdk = 10;
	friendMsg = 11;
    friends = 12;
    moreSetting = 13;
    loadNewMsgs = 14; -- hall_chat_dialog need --
    entryChatRoom = 15; -- 进入聊天室
    isLogined = 16;
    getDailyReward = 17;
    getUnionRecommend = 18; --同城用户推荐
    getUnionMember    = 19; --同城所有用户
    quickPlay           = 20; -- 快速开始
};

HallController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
    kMusicPlayer.playHallBg();
end


HallController.resume = function(self)
	ChessController.resume(self);
	Log.i("HallController.resume");
    if not HallController.isFirstStart then
        HallController.isFirstStart = 0;
        NativeEvent.getInstance():closeStartDialog();
        self:login();
    end
    if UserInfo.getInstance():isLogin() then
        OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_ONLINE_NUM);
        self:showAccountModify();
        DailyTaskManager.getInstance():sendGetNewDailyTaskList();
    end
    
    local _,ads_btn_status = UserInfo.getInstance():getAdsStatus();
    if ads_btn_status and ads_btn_status == 2 then
        dict_set_string(kAdMananger,kAdMananger..kparmPostfix,AD_SHOW_BANNER_AD_DIALOG);
        call_native(kAdMananger);
    else
        dict_set_string(kAdMananger,kAdMananger..kparmPostfix,AD_REMOVE_RECOMMEND_BAR);
        call_native(kAdMananger);
    end

end


HallController.exit_action = function(self)
	sys_exit();
end

HallController.pause = function(self)
	ChessController.pause(self);
	Log.i("HallController.pause");
    dict_set_string(kAdMananger,kAdMananger..kparmPostfix,AD_REMOVE_RECOMMEND_BAR);
    call_native(kAdMananger);
end

HallController.dtor = function(self)
    delete(self.chioce_dialog);
end

HallController.onBack = function(self)
    if GameData.getInstance():getInstallUpdate() then   --判断是否有更新包需要提示安装
        GameData.getInstance():setInstallUpdate(false);
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

HallController.onLoginSuccess = function(self,data)
	Log.i("HallController.onLoginSuccess");
    UserInfo.getInstance():setLogin(true);

    self:updateView(HallScene.s_cmds.update_user_money); 
--    UserSetInfo.getInstance():updataSelectData();
    if kPlatform == kPlatformIOS then
        self:updateView(HallScene.s_cmds.ios_audit_status)
    end;
--    if not self:isLogined() then return ;end
    
    self:postGetStartViewConfig();
    
    -------拉取城市列表信息--------
    local params = {};
    params.file_version = GameCacheData.getInstance():getInt(GameCacheData.GET_CITY_DATA,0);
    HttpModule.getInstance():execute(HttpModule.s_cmds.getCityConfig,params);
    HttpModule.getInstance():execute(HttpModule.s_cmds.getNoticeMsg,{});
    -------------------------------
    --- 拉取强推数据
    HttpModule.getInstance():execute(HttpModule.s_cmds.IndexGetPushActionList);

    require("dialog/chioce_dialog");
    if UserInfo.getInstance():getTodayFirstLogin() == 1 then
        local msg = "您的会员服务即将到期，亲可以提前到商店续费哦";
        local vip_time = UserInfo.getInstance():getVipTime();
        local mactivetime = UserInfo.getInstance():getMactivetime();
        local temp = os.difftime(vip_time,mactivetime);

        if temp and temp < 259200 and temp > 0 then
            if not self.chioce_dialog then
                self.chioce_dialog = new(ChioceDialog);
            end
            self.chioce_dialog:setMode(ChioceDialog.MODE_OTHER);
            self.chioce_dialog:setMessage(msg);
	        self.chioce_dialog:setNegativeListener(nil,nil);
	        self.chioce_dialog:show();
        end
    end
    if kPlatform == kPlatformIOS then
        -- ios appStore评价开关
        HttpModule.getInstance():execute(HttpModule.s_cmds.appStoreEvaluate);
        -- ios 审核关闭新手光环
        if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
    --修改 1-第一次注册 0-已经登陆过
            if UserInfo.getInstance():getIsFirstLogin() ~= 1 then
                self.hasShowGetDaily = false;
                MallData.getInstance():getShopData();
                MallData.getInstance():getPropData();
                self:showAccountModify();
                DailyTaskManager.getInstance():sendGetNewDailyTaskList();
            else
                self:updateView(HallScene.s_cmds.show_guide_dialog);
            end
        else
        end;
    else
        --修改 1-第一次注册 0-已经登陆过
        if UserInfo.getInstance():getIsFirstLogin() ~= 1 then
            self.hasShowGetDaily = false;
            MallData.getInstance():getShopData();
            MallData.getInstance():getPropData();
            self:showAccountModify();
            DailyTaskManager.getInstance():sendGetNewDailyTaskList();
        else
            self:updateView(HallScene.s_cmds.show_guide_dialog);
        end
    end;

    local lastMailtime = GameCacheData.getInstance():getString(GameCacheData.NOTICE_MAILS_TIME,"0");
    local params = {};
    params.last_mail_time = lastMailtime;
    HttpModule.getInstance():execute(HttpModule.s_cmds.UserMailGetNewMailNumber,params);
end

HallController.onLoginFail = function(self,data)
	Log.i("HallController.onLoginFail");
    ChessToastManager.getInstance():show("登录失败，请检查网络，稍后再试！");
    local updateData = GameData.getInstance():getForceFlag();
    if updateData then
        OnlineUpdate.getInstance():onCheckUpdate(updateData);
    end
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
    if self:isForbidPlayOnline() then return end;
    -- 判断是否联网
    if not self:isLogined() then return ;end
    UserInfo.getInstance():setIsFromHall(true)
    StateMachine.getInstance():pushState(States.Online,StateMachine.STYPE_CUSTOM_WAIT);
end;

HallController.consoleChess = function(self)
    Log.i("HallController.consoleChess");
    UserInfo.getInstance():setIsFromHall(true)
    StateMachine.getInstance():pushState(States.Console,StateMachine.STYPE_CUSTOM_WAIT);
end;


HallController.endgateChess = function(self)
    Log.i("HallController.endgateChess");
    StateMachine.getInstance():pushState(States.EndGate,StateMachine.STYPE_CUSTOM_WAIT);
end;

HallController.replayChess = function(self)
    Log.i("HallController.replayChess");
    StateMachine.getInstance():pushState(States.Replay,StateMachine.STYPE_CUSTOM_WAIT);

end;

HallController.userInfo = function(self)
    Log.i("HallController.userInfo");
    if not self:isLogined() then return ;end
    if kPlatform == kPlatformIOS then
        if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
            require("dialog/toggle_account_dialog");
            delete(self.m_toggleAccountDialog);
            self.m_toggleAccountDialog = nil;
            self.m_toggleAccountDialog = new(ToggleAccountDialog);
            self.m_toggleAccountDialog:setCtrl(self);
    	    self.m_toggleAccountDialog:show();
        else
            StateMachine.getInstance():pushState(States.UserInfo,StateMachine.STYPE_CUSTOM_WAIT);
        end
    else
        require("dialog/toggle_account_dialog");
        delete(self.m_toggleAccountDialog);
        self.m_toggleAccountDialog = nil;
        self.m_toggleAccountDialog = new(ToggleAccountDialog);
        self.m_toggleAccountDialog:setCtrl(self);
	    self.m_toggleAccountDialog:show();
    end;
end;


HallController.tofriends = function(self) --跳转好友界面 ZY
    Log.i("HallController.feekback");
    --if not self:isLogined() then return ;end
    StateMachine.getInstance():pushState(States.Rank,StateMachine.STYPE_CUSTOM_WAIT,nil,0);
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

HallController.mall = function(self)
    Log.i("HallController.mall");
    if not self:isLogined() then return ;end
    StateMachine.getInstance():pushState(States.Mall,StateMachine.STYPE_CUSTOM_WAIT);
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
--        StateMachine.getInstance():pushState(States.Online,StateMachine.STYPE_WAIT);
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
end;


HallController.downLoadImage=function(self ,flag ,json_data)
	if not json_data then
		return;
	end

	local imageName = "";
	if json_data.ImageName:get_value() then
		imageName = json_data.ImageName:get_value();
	end

	-- print_string("------------------------Hall.downLoadImage :" .. imageName);
    require("animation/broadcastMessageAnim");
	if BroadcastMessageAnim.ICON_IMG ==  string.sub(imageName,1,5) then
		BroadcastMessageAnim.showBroadcastImage1(imageName); 
--	elseif imageName and imageName == DaiyListDialog.activity_icon_name then
--		if self.daily_list_dialog then
--			self.daily_list_dialog:set_activity_img(imageName); 
--		end
	else
        print_string("eeeee回调downLoadImage is icon Url :"..UserInfo.getInstance():getIcon());

        if UserInfo.getInstance():getLoginType() == LOGIN_TYPE_BOYAA then
            print_string("eeeee回调 博雅 :"..UserInfo.getInstance():getIcon());
            UserInfo.getInstance():setIconFile(UserInfo.getInstance():getIcon(),UserInfo.ICON..PhpConfig.TYPE_BOYAA .. ".png")

        elseif UserInfo.getInstance():getLoginType() == LOGIN_TYPE_YOUKE then
            print_string("eeeee回调 游客 :"..UserInfo.getInstance():getIcon());
            UserInfo.getInstance():setIconFile(UserInfo.getInstance():getIcon(),UserInfo.ICON..PhpConfig.TYPE_YOUKE .. ".png")

        elseif UserInfo.getInstance():getLoginType() == LOGIN_TYPE_weibo then
            print_string("eeeee回调 微博 :"..UserInfo.getInstance():getIcon());
            UserInfo.getInstance():setIconFile(UserInfo.getInstance():getIcon(),UserInfo.ICON..PhpConfig.TYPE_WEIBO .. ".png")

        end;
		--UserInfo.getInstance():setIconFile(UserInfo.getInstance():getIcon(),UserInfo.ICON .. ".png")
        --self.m_userinfo_icon:reloadImage();
        --if UserInfo.getInstance():getLoginType() == LOGIN_TYPE_BOYAA then
            --self.m_userinfo_icon:setFile(User.WOMAN_ICON);
        --else

            --self.m_userinfo_icon:addImage();
--		    self.m_userinfo_icon:setFile(UserInfo.getInstance():getIconFile());
        self:updateUserInfoView();

        --end;
        --self.m_userinfo_icon:reloadImage();
        print_string("eeeee正式切测试，图片没拉下来~~加载"..UserInfo.getInstance():getIconFile());
	end
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
    if not UserInfo.getInstance():getBindAccount()[0] and onlineGameTimes >= 20 then
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
    self:updateView(HallScene.s_cmds.update_online_num,info.online_num);
end
HallController.onFriendCmdGetUnreadMsg = function(self,info)
    FriendsData.getInstance():onGetFriendsMsg(info);
end

HallController.onRecvServerEntryChatRoom  = function(self,packetInfo)
    self:updateView(HallScene.s_cmds.entry_chat_room,packetInfo);
end

HallController.onRecvServerUnreadMsg = function(self,packetInfo)
    if self.m_view:getChatDialog() then
        self.m_view:getChatDialog():onRecvServerUnreadMsg(packetInfo);
    end
end

HallController.onRecvUserSendMsg = function(self, packetInfo)
    if packetInfo.status ~= 0 then
        if packetInfo.status > 0 then
            if self:isForbidSendMsg(packetInfo.status) then
                return;           
            else
                ChessToastManager.getInstance():showSingle("消息发送失败了",2000);
            end;
        elseif packetInfo.status == -1 then -- 屏蔽频繁聊天
            ChessToastManager.getInstance():showSingle("亲，消息不能为空或频繁发送哦",1500);
        end;
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

HallController.isForbidPlayOnline = function(self)
    -- 封号状态
    if UserInfo.getInstance():getUserStatus() == 1 then
        local freeze_time = UserInfo.getInstance():getUserFreezEndTime();
        local tip_msg;
        if freeze_time ~= 0 then
            tip_msg = "很抱歉，您的账号被多次举报，经核实已被冻结，将于"..os.date("%Y-%m-%d %H:%M",freeze_time) .."解封，期间仅能进入单机和残局版块。"
        else        
            tip_msg = "很抱歉，您的账号被多次举报，经核实已被冻结，仅能进入单机和残局版块。"
        end;
        if not self.m_chioce_dialog then
            self.m_chioce_dialog = new(ChioceDialog);
        end;
        self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE);
        self.m_chioce_dialog:setMessage(tip_msg);
        self.m_chioce_dialog:show();
        return true;
    end;
    return false;
end;



HallController.isForbidSendMsg = function(self,forbid_time)
    if forbid_time and forbid_time > 0 then
        local tip_msg = "很抱歉，您的账号被多次举报，经核实已被禁言，将于"..os.date("%Y-%m-%d %H:%M",forbid_time) .."解禁，感谢您的配合和理解。"
        if not self.m_chioce_dialog then
            self.m_chioce_dialog = new(ChioceDialog);
        end;
        self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE);
        self.m_chioce_dialog:setMessage(tip_msg);
        self.m_chioce_dialog:show();
        return true;
    end; 
    return false;
end;

HallController.onRecvCommonChatMsg = function(self, packetInfo)
    
    if self.m_view:getChatDialog() then
        self:isForbidSendMsg(packetInfo.forbid_time);
        self.m_view:getChatDialog():onRecvCommonChatMsg(packetInfo);
    end
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

HallController.onRecvServerAddFllow = function(self,info)
    if not info then return end
    local chatdialog = self.m_view:getChatDialog();
    local uniondialog = self.m_view:getUnionDialog();

    if chatdialog and chatdialog:isShowing() then
        chatdialog:onRecvServerAddFllow(info);
        return;
    end
    if uniondialog and uniondialog:isShowing() then
        uniondialog:onRecvServerAddFllow(info);
        return;
    end
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
        UserInfo.getInstance():setIosAppStoreEvaluate(data);
        if data.total_login then
            local hasEvaluated = GameCacheData.getInstance():getBoolean(GameCacheData.HAS_EVALAUTED,false);-- 已经评价了
            local lastShowDlgTime = GameCacheData.getInstance():getInt(GameCacheData.LAST_SHOWEVADLG_TIME,0);-- 上次显示的时间
            local isSecondDay = ToolKit.isSecondDay(lastShowDlgTime);
            if (tonumber(data.total_login) == UserInfo.getInstance():getLoginTimes() and not hasEvaluated and isSecondDay) or kDebug then
                self.m_eva_chioce_dialog = new(ChioceDialog);
                self.m_eva_chioce_dialog:setMode(ChioceDialog.MODE_SURE,"去评价","残忍拒绝");
                self.m_eva_chioce_dialog:setMessage("大侠，你辣么厉害，不如给我们评个分吧！");
                self.m_eva_chioce_dialog:setPositiveListener(self, function()
                    call_native(kIosAppStoreEvaluate);
                    GameCacheData.getInstance():saveBoolean(GameCacheData.HAS_EVALAUTED,true);
                end);
                self.m_eva_chioce_dialog:setNegativeListener(self, function()
                    GameCacheData.getInstance():saveBoolean(GameCacheData.HAS_EVALAUTED,false);
                end);           
                self.m_eva_chioce_dialog:show();
                GameCacheData.getInstance():saveInt(GameCacheData.LAST_SHOWEVADLG_TIME,os.time());
            end;

        end;
    end
end;

HallController.getUnionRecommend = function(self)
    local post_data = {};
    post_data.method =  "Friends.getSameCityRecommend";
    post_data.mid = UserInfo.getInstance():getUid();
    post_data.recommend_num = 3;
    post_data.access_token = "chess";
    HttpModule.getInstance():execute(HttpModule.s_cmds.getSameCityRecommend,post_data);
end 

HallController.onGetUnionRecommendResponse = function(self,isSuccess,message)
    Log.i("onGetUnionRecommendResponse");
    if not isSuccess then return end

    local data = message.data;
	if not data then
		print_string("not data");
		return
	end

    local unionData = json.analyzeJsonNode(data);
    self:updateView(HallScene.s_cmds.updata_union_dialog,unionData,msg);

end

HallController.getUnionMember = function(self)
    local post_data = {};
    post_data.method =  "Friends.getSameCityMember";
    post_data.mid = UserInfo.getInstance():getUid();
    post_data.offset = 0;
    post_data.limit = 50;
    HttpModule.getInstance():execute(HttpModule.s_cmds.getSameCityMember,post_data);
end

HallController.onGetUnionMemberResponse = function(self,isSuccess,message)
    Log.i("onGetUnionMemberResponse");
    if not isSuccess then return end

    local data = message.data;
	if not data then
		print_string("not data");
		return
	end

    local memberData = json.analyzeJsonNode(data);
    self:updateView(HallScene.s_cmds.updata_union_member,memberData,msg);

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
        BottomMenu.getInstance():setOwnBtnTipVisible();
    end
end

HallController.onEntryRoom = function(self, index, flag)
    UserInfo.getInstance():setGameType(index);
    StateMachine.getInstance():pushState(States.OnlineRoom,StateMachine.STYPE_CUSTOM_WAIT);
end

function HallController:quickPlay()
    -- 封号状态
    if self:isForbidPlayOnline() then return end;
    -- 判断是否联网
    if not self:isLogined() then return ;end
    local data = UserInfo.getInstance():getRoomDataList();
    local money = UserInfo.getInstance():getMoney();
    local gotoRoom = nil;
    if not data then 
        ChessToastManager.getInstance():showSingle("没有房间数据，请重新登录");
        return 
    end
    for i,room in ipairs(data) do
        if money >= room.minmoney then
            gotoRoom = room;
        end
    end
    if not gotoRoom then 
        ChessToastManager.getInstance():showSingle("没有合适的场次");
    else
        UserInfo.getInstance():setMoneyType(tonumber(gotoRoom.room_type));--room_type:1,2,3
        UserInfo.getInstance():setRoomLevel(tonumber(gotoRoom.level));
	    self:onEntryRoom(tonumber(gotoRoom.type));
    end
end

HallController.onIndexGetPushActionList = function(self,isSuccess,message)
    if not isSuccess or message.data:get_value() == nil then
        return ;
    end
    local data = json.analyzeJsonNode(message.data);
    if data then
        require(DIALOG_PATH .. "pushActionDialog");
        delete(self.m_pushActionDialog);
        self.m_pushActionDialog = new(PushActionDialog,data);
        self.m_pushActionDialog:show();
    end
end
-------------------------------- config ----------------------------

HallController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.GetConsoleProgress] = HallController.onGetConsoleProgressResponse;
    [HttpModule.s_cmds.getUserInfo] = HallController.onGetUserInfoResponse;
--    [HttpModule.s_cmds.GetNewDailyReward] = HallController.onGetNewDailyRewardResponse;
    [HttpModule.s_cmds.getSameCityRecommend] = HallController.onGetUnionRecommendResponse;
    [HttpModule.s_cmds.getSameCityMember] = HallController.onGetUnionMemberResponse;
    
--    [HttpModule.s_cmds.getNoticeMsg] = HallController.getNoticeMsgCallBack;
    [HttpModule.s_cmds.appStoreEvaluate] = HallController.onGetIosAppStoreEvaluate;
--    [HttpModule.s_cmds.saveUserInfo] = HallController.onSaveUserInfoCityCode;
    [HttpModule.s_cmds.IndexGetPushActionList] = HallController.onIndexGetPushActionList;

};

HallController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	HallController.s_httpRequestsCallBackFuncMap or {});


--本地事件 包括lua dispatch call事件
HallController.s_nativeEventFuncMap = {
    [kDownLoadImage]                = HallController.downLoadImage;
    [kUpdateUserInfo]               = HallController.getUserInfo;
    [kAdSDKStatus]                  = HallController.adSDKStatus;
    [kFriend_UpdateChatMsg]         = HallController.onRecvUnreadMsg;
    [kFriend_FollowCallBack]        = HallController.onRecvServerAddFllow;
};


HallController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	HallController.s_nativeEventFuncMap or {});



HallController.s_socketCmdFuncMap = {
    [FRIEND_CMD_ONLINE_NUM]                 = HallController.onFriendCmdOnlineNum;
    [FRIEND_CMD_GET_UNREAD_MSG]             = HallController.onFriendCmdGetUnreadMsg;
    -- 进入聊天室（大师/同城）
    [CHATROOM_CMD_ENTER_ROOM]               = HallController.onRecvServerEntryChatRoom;
    -- 获取历史消息
    [CHATROOM_CMD_GET_HISTORY_MSG]          = HallController.onRecvServerUnreadMsg;
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
    -- 聊天室内成员列表关注
--    [FRIEND_CMD_ADD_FLLOW]                  = HallController.onRecvServerAddFllow;                --添加或取消关注
}

HallController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	HallController.s_socketCmdFuncMap or {});


------------------------------------- 命令响应函数配置 ------------------------
HallController.s_cmdConfig = 
{
	[HallController.s_cmds.login]		        = ChessController.login;
    [HallController.s_cmds.onlineChess]		    = HallController.onlineChess;
    [HallController.s_cmds.consoleChess]		= HallController.consoleChess;
    [HallController.s_cmds.endgateChess]		= HallController.endgateChess;
    [HallController.s_cmds.replayChess]		    = HallController.replayChess;

    [HallController.s_cmds.userInfo]            = HallController.userInfo;
    [HallController.s_cmds.mall]                = HallController.mall;
    [HallController.s_cmds.switch_server]       = HallController.switchServer;
    [HallController.s_cmds.toPointWall]         = HallController.toPointWall;
    [HallController.s_cmds.toAdSdk]             = HallController.toAdSdk;
    [HallController.s_cmds.friendMsg]           = HallController.onFriendMsg;
    [HallController.s_cmds.friends]             = HallController.tofriends; -- 好友界面 ZY
    [HallController.s_cmds.loadNewMsgs]         = HallController.onLoadNewMsgs; -- loadNewMsg;
    [HallController.s_cmds.entryChatRoom]       = HallController.onEntryChatRoom; -- 进入ChatRoom;
    [HallController.s_cmds.isLogined]           = ChessController.isLogined;
    [HallController.s_cmds.getDailyReward]      = ChessController.getDailyReward;
    [HallController.s_cmds.getUnionRecommend]   = HallController.getUnionRecommend;
    [HallController.s_cmds.getUnionMember]      = HallController.getUnionMember;
    [HallController.s_cmds.quickPlay]           = HallController.quickPlay;
}