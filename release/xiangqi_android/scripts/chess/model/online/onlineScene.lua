
require(BASE_PATH.."chessScene");
require("view/selectButton");
require("dialog/progress_dialog");
require("dialog/create_room_dialog");
require("dialog/bankrupt_subsidy_dialog");

OnlineScene = class(ChessScene);

OnlineScene.BANKRUPT_MESSAGE = "您的金币今天不足以继续游戏，请明天再接再励!";
OnlineScene.LACK_MESSAGE = "该场次最低需携带%d金币，请移步到其他场次进行游戏。";
OnlineScene.OVER_MESSAGE = "世界那么大，您那么富有，是时候去高级场看看了";

OnlineScene.PLAYING_FILED = 1;
OnlineScene.ROOMS = 2

OnlineScene.LSIT_NORMAL = 0;
OnlineScene.LSIT_REFRESH = 1;
OnlineScene.LIST_NEXT_PAGE = 2;


OnlineScene.s_controls = 
{
    back_btn                = 1;
    novice_room_btn         = 2;
    middle_room_btn         = 3;
    master_room_btn         = 4;
    private_room_btn        = 5;
    watch_btn               = 7;
    challenge_btn           = 8;    
    user_info_view          = 9;
    bg                      = 10;
    top_board               = 11;
    top_title_bg            = 12;
    teapot_dec              = 13;
    stone_dec               = 14;
    bottom_view             = 15;
    top_view                = 16;
    content_view            = 17;
    helpBtn                 = 18;
}

OnlineScene.s_cmds = 
{
    update_room_players = 1;
    update_private_room_num = 2;
    update_friends_info = 3;--更新好友观战和挑战数据
    online_collapse = 4;
    closeBankruptDialog = 5;--关闭破产弹窗
    refresh_userinfo = 6; --更新界面信息
}

OnlineScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = OnlineScene.s_controls;
    self:initView();
end 

OnlineScene.resume = function(self)
    ChessScene.resume(self);
--    self:refreshUserInfo();
--    self:removeAnimProp();
--    self:resumeAnimStart();
    if OnlineScene.changeFriends then
        OnlineScene.changeFriends= false;
        self:onChallengeBtnClick();
    end
end;
OnlineScene.pause = function(self)
	ChessScene.pause(self);
    self:removeAnimProp();
--    self:pauseAnimStart();
end 


OnlineScene.dtor = function(self)
    UserInfo.getInstance():setRoomInfo(nil);    --清理房间信息
    self:removeAnimProp();
    delete(self.m_chioce_dialog);
    delete(self.m_createroom_dialog);
    delete(self.m_challenge_dialog);
    delete(self.anim_end);
    delete(self.anim_timer);
    delete(self.m_bankrupt_subsidy_dialog);
    delete(self.helpDialog);
end 

------------------------------anim----------------------------------
OnlineScene.removeAnimProp = function(self)
    if self.m_anim_prop_need_remove then
        self.m_title:removeProp(1);
        self.m_title:removeProp(2);
        self.m_leaf_right:removeProp(1);
        self.m_leaf_left:removeProp(1);
        self.m_novice_room_btn:removeProp(1);
        self.m_novice_room_btn:removeProp(2);
        self.m_middle_room_btn:removeProp(1);
        self.m_middle_room_btn:removeProp(2);
        self.m_master_room_btn:removeProp(1);
        self.m_master_room_btn:removeProp(2);
        self.m_private_room_btn:removeProp(1);
        self.m_private_room_btn:removeProp(2);
        self.m_anim_prop_need_remove = false;
    end
end

OnlineScene.setAnimItemEnVisible = function(self,ret)
    self.m_leaf_right:setVisible(ret);
    self.m_leaf_left:setVisible(ret);
end


OnlineScene.resumeAnimStart = function(self,lastStateObj,timer,func)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    local duration = timer.waitTime;
    local delay = timer.duration + duration;
    delete(self.anim_timer);
    self.anim_timer = new(AnimInt,kAnimNormal,0,1,delay,-1);
    if self.anim_timer then
        self.anim_timer:setEvent(self,function()
            self:setAnimItemEnVisible(true);
            delete(self.anim_timer);
        end);
    end

    -- 上部动画
    self.m_title:addPropTransparency(2,kAnimNormal,duration,delay,0,1);
    self.m_title:addPropScale(1,kAnimNormal,duration,delay,0.8,1,0.6,1,kCenterDrawing);
    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1, kAnimNormal, duration, delay, -lw, 0, -10, 0);
    local rw,rh = self.m_leaf_right:getSize();
    self.m_leaf_right:addPropTranslate(1, kAnimNormal, duration, delay, rw, 0, -10, 0);

    self.m_novice_room_btn:addPropTransparency(2,kAnimNormal,duration,delay + 100,0,1);
    self.m_novice_room_btn:addPropScale(1,kAnimNormal,duration,delay + 100,0.8,1,0.8,1,kCenterXY,200,220);

    self.m_middle_room_btn:addPropTransparency(2,kAnimNormal,duration,delay + 200,0,1);
    self.m_middle_room_btn:addPropScale(1,kAnimNormal,duration,delay + 200,0.8,1,0.8,1,kCenterXY,60,220);

    self.m_master_room_btn:addPropTransparency(2,kAnimNormal,duration,delay + 300,0,1);
    self.m_master_room_btn:addPropScale(1,kAnimNormal,duration,delay + 300,0.8,1,0.8,1,kCenterXY,200,40);

    self.m_private_room_btn:addPropTransparency(2,kAnimNormal,duration,delay + 400,0,1);
    local anim = self.m_private_room_btn:addPropScale(1,kAnimNormal,duration,delay + 400,0.8,1,0.8,1,kCenterXY,60,40);
    if anim then
        anim:setEvent(self,function()
            self.m_anim_prop_need_remove = true;
            self:removeAnimProp();
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end
            delete(anim);
        end);
    end
end

OnlineScene.pauseAnimStart = function(self,newStateObj,timer)
   self.m_anim_prop_need_remove = true;
   self:removeAnimProp();
   local duration = timer.duration;
   local waitTime = timer.waitTime
   local delay = waitTime+duration;

    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, -lw, 0, -10);
    local rw,rh = self.m_leaf_right:getSize();
    local anim = self.m_leaf_right:addPropTranslate(1, kAnimNormal, waitTime, -1 , 0, rw, 0, -10);
    if anim then
        anim:setEvent(self,function()
            self:setAnimItemEnVisible(false);
            delete(anim);
        end);
    end
    delete(self.anim_end);
    self.anim_end = new(AnimInt,kAnimNormal,0,1,delay,-1);
    if self.anim_end then
        self.anim_end:setEvent(self,function()
            self.m_anim_prop_need_remove = true;
            self:removeAnimProp();
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end
            delete(self.anim_end);
        end);
    end
   -- 上部动画
--   local w,h = self.m_top_view:getSize();
--   local anim = self.m_top_view:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, 0, -h);
--   anim:setEvent(self,self.removeAnimProp);
--   -- 下部动画
--   local w,h = self.m_bottom_view:getSize();
--   self.m_bottom_view:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, 0, h);

--   -- 茶壶 石子 后退按钮动画
--   local w,h = self.m_stone_dec:getSize();
--   self.m_stone_dec:addPropTranslate(1, kAnimNormal, duration, delay, 0, w, 0, 0);

--   local w,h = self.m_teapot_dec:getSize();
--   self.m_teapot_dec:addPropTranslate(1, kAnimNormal, duration, delay, 0, -w, 0, 0);

--   self.m_back_btn:addPropTransparency(1,kAnimNormal,duration,delay,1,0);

--   -- 
--   self.m_content_view:addPropTransparency(1,kAnimNormal,duration,delay,1,0);
end

------------------------------function------------------------------

OnlineScene.initView = function(self)
    self.m_top_view = self:findViewById(self.m_ctrls.top_view);
    self.m_title = self.m_top_view:getChildByName("top_title_bg"):getChildByName("top_title");
    self.m_leaf_right = self.m_top_view:getChildByName("leaf_right");
    self.m_leaf_left = self.m_top_view:getChildByName("leaf_left");
--    self.m_bottom_view = self:findViewById(self.m_ctrls.bottom_view);
--    self.m_stone_dec = self:findViewById(self.m_ctrls.stone_dec);
--    self.m_teapot_dec = self:findViewById(self.m_ctrls.teapot_dec);
--    self.m_back_btn = self:findViewById(self.m_ctrls.back_btn);
    self.m_content_view = self:findViewById(self.m_ctrls.content_view);

    local func = function(view,enable)
        Log.i(enable);
        local title = view:getChildByName("content"):getChildByName("room_name");
        if title then
            if enable then
                title:removeProp(1);
            else
                title:addPropScaleSolid(1,1.1,1.1,1);
            end
        end
    end
    
    self.m_novice_room_btn = self:findViewById(self.m_ctrls.novice_room_btn);
    self.m_novice_room_btn:setOnTuchProcess(self.m_novice_room_btn,func);
    self.m_middle_room_btn = self:findViewById(self.m_ctrls.middle_room_btn);
    self.m_middle_room_btn:setOnTuchProcess(self.m_middle_room_btn,func);
    self.m_master_room_btn = self:findViewById(self.m_ctrls.master_room_btn);
    self.m_master_room_btn:setOnTuchProcess(self.m_master_room_btn,func);
    self.m_private_room_btn = self:findViewById(self.m_ctrls.private_room_btn);
    self.m_private_room_btn:setOnTuchProcess(self.m_private_room_btn,func);

    local func = function(view,enable)
        Log.i(enable);
        local title = view:getChildByName("title");
        if title then
            if enable then
                title:removeProp(1);
            else
                title:addPropScaleSolid(1,1.1,1.1,1);
            end
        end
    end

    self.m_watch_btn = self:findViewById(self.m_ctrls.watch_btn);
    self.m_watch_btn:setOnTuchProcess(self.m_watch_btn,func);
    self.m_challenge_btn = self:findViewById(self.m_ctrls.challenge_btn);
    self.m_challenge_btn:setOnTuchProcess(self.m_challenge_btn,func);


    self.m_user_info_view = self:findViewById(self.m_ctrls.user_info_view);

    local data = UserInfo.getInstance():getRoomDataList();
    
    if data then
        self.m_novice_room_btn:getChildByName("content"):getChildByName("score_bg"):getChildByName("introduction"):setText((data[1].money or 0).."底注");
        self.m_middle_room_btn:getChildByName("content"):getChildByName("score_bg"):getChildByName("introduction"):setText((data[2].money or 0).."底注");
        self.m_master_room_btn:getChildByName("content"):getChildByName("score_bg"):getChildByName("introduction"):setText((data[3].money or 0).."底注");
        local func = function(self)
            OnlineScene.onOnlineListItemClick(self,data[1]);
        end
        self.m_novice_room_btn:setOnClick(self,func);
        local func = function(self)
            OnlineScene.onOnlineListItemClick(self,data[2]);
        end
        self.m_middle_room_btn:setOnClick(self,func);
        local func = function(self)
            OnlineScene.onOnlineListItemClick(self,data[3]);
        end
        self.m_master_room_btn:setOnClick(self,func);
    end

    local private_data = UserInfo.getInstance():getRoomConfigById(4);
    if private_data then
        self.m_private_room_btn:getChildByName("content"):getChildByName("score_bg"):getChildByName("introduction"):setText((private_data.money or 0).."底注");
    end
end

OnlineScene.refreshUserInfo = function(self)
    self.m_user_info_view:getChildByName('score'):setText("积分:"..UserInfo.getInstance():getScore());
    self.m_user_info_view:getChildByName('gold'):setText(UserInfo.getInstance():getMoneyStr());
    self.m_user_info_view:getChildByName('winrate'):setText("胜率:"..UserInfo.getInstance():getRate());
	self:getCollapseReward();
end;

OnlineScene.showIosEvaluateDlg = function(self)
    local isShow = GameCacheData.getInstance():getBoolean(GameCacheData.IS_SHOW_IOS_EVALUATE_DIALOG, false); -- 是否连胜显示
    local hasEvaluated = GameCacheData.getInstance():getBoolean(GameCacheData.HAS_EVALAUTED,false);-- 已经评价了
    local lastShowDlgTime = GameCacheData.getInstance():getInt(GameCacheData.LAST_SHOWEVADLG_TIME,0);-- 上次显示的时间
    local isSecondDay = ToolKit.isSecondDay(lastShowDlgTime);
    if (isShow and not hasEvaluated and isSecondDay) or kDebug then
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
OnlineScene.getCollapseReward = function(self)
	print_string("Online.getCollapseReward ...");
	if UserInfo.getInstance():canCollapseReward() and UserInfo.getInstance():getShowBankruptStatus() then
--    	local tips = "正在领取金币补助...";
--	    local post_data = {};
--	    post_data.mid = UserInfo.getInstance():getUid();
--	    post_data.versions = PhpConfig.getVersions();
--        HttpModule.getInstance():execute(HttpModule.s_cmds.getCollapseReward, post_data) --, tips);
        self:requestCtrlCmd(OnlineController.s_cmds.checkBankruptReward);
	end
    
end

OnlineScene.onOnlineListItemClick = function(self,room)
	if not self:isConnectGameServer() then
		print_string("you must connect GameServer !");
		return;
	end
    UserInfo.getInstance():setMoneyType(tonumber(room.room_type));--room_type:1,2,3
    UserInfo.getInstance():setRoomLevel(tonumber(room.level));
	self:entryOnlineGame(tonumber(room.type));
end

OnlineScene.entryOnlineGame = function(self,index)
	
    local money = UserInfo.getInstance():getMoney();

	if tonumber(money) <=0  then
        if UserInfo.getInstance():getShowBankruptStatus() then
            self:getCollapseReward();
        else
            self:coinQuickBuyDlg();
        end
		return;
	end

    local gold_type = UserInfo.getInstance():getMoneyType();
	local ctype = UserInfo.getInstance():canAccessRoom(gold_type);

	if ctype == gold_type then
		ToolKit.removeAllTipsDialog(); 
		self:requestCtrlCmd(OnlineController.s_cmds.entryRoom, index);
		return;
	end

	local message = nil;
	local room = UserInfo.getInstance():getRoomConfigById(gold_type);
	if ctype == 0 then
		-- message = Online.BANKRUPT_MESSAGE;
        if UserInfo.getInstance():getShowBankruptStatus() then
            self:getCollapseReward();
        else
            self:coinQuickBuyDlg();
        end
		return;
	elseif ctype < gold_type then
		message = string.format(OnlineScene.LACK_MESSAGE,room.minmoney);
	elseif ctype > gold_type then
		message = string.format(OnlineScene.OVER_MESSAGE,room.maxmoney);
	end

	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end

	self.m_chioce_dialog:setMode(ChioceDialog.MODE_OK);
	self.m_chioce_dialog:setPositiveListener(nil);
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:show(self.m_root_view);
end;

OnlineScene.coinQuickBuyDlg = function(self,data)
	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end

--	local message = "您金币不足！购买金币继续游戏，或明日来领取破产补助。";
	local message = "您携带的金币不足，建议您暂移步至单机或残局进行游戏，或明日再来挑战";
	self.m_chioce_dialog:setMode(ChioceDialog.MODE_OK);
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:show();
end

OnlineScene.isConnectGameServer = function(self)
	--PHP未登录上
	if not UserInfo.getInstance():isLogin() then
		if not self.m_chioce_dialog then
			self.m_chioce_dialog = new(ChioceDialog);
		end

		local message = "请先登录...";
		self.m_chioce_dialog:setMode(ChioceDialog.MODE_OK);
		self.m_chioce_dialog:setMessage(message);
		self.m_chioce_dialog:setPositiveListener(self,self.exit);
		self.m_chioce_dialog:setNegativeListener(nil,nil);
		self.m_chioce_dialog:show(self.m_root_view);
		return false;
	end

	--Socket未登录上
	if not UserInfo.getInstance():getConnectHall() then

		if not self.m_chioce_dialog then
			self.m_chioce_dialog = new(ChioceDialog);
		end

		local message = "请先连接游戏大厅...";
		self.m_chioce_dialog:setMode(ChioceDialog.MODE_OK);
		self.m_chioce_dialog:setMessage(message);
		self.m_chioce_dialog:setPositiveListener(self,self.exit);
		self.m_chioce_dialog:show(self.m_root_view);
		return false;
	end

	return true;
end

OnlineScene.onOnlineBackActionBtnClick = function(self)
    self:requestCtrlCmd(OnlineController.s_cmds.back_action);
end;

OnlineScene.onUpdateRoomPlayers = function(self, room_player)
    self.m_room_players = room_player;
    if room_player then
        self.m_novice_room_btn:getChildByName("online_num_bg"):getChildByName("online_num"):setText("当前在线:"..(room_player[1] or 0));
        self.m_middle_room_btn:getChildByName("online_num_bg"):getChildByName("online_num"):setText("当前在线:"..(room_player[2] or 0));
        self.m_master_room_btn:getChildByName("online_num_bg"):getChildByName("online_num"):setText("当前在线:"..(room_player[3] or 0));
        UserInfo.getInstance():setRoomPlayerNum(room_player);
        self.m_watch_btn:getChildByName("info"):setText("观战人数:"..(room_player[4] or 0).."人");
    else
        Log.i("房间人数获取失败");
        local playerNum = UserInfo.getInstance():getRoomPlayerNum();
        if not playerNum then
            playerNum = {};
            playerNum[1] =  math.random(1500,2500);
            playerNum[2] = math.random(1500,2000);
            playerNum[3] = math.random(100,300);
        end
        self.m_novice_room_btn:getChildByName("online_num_bg"):getChildByName("online_num"):setText("当前在线:"..(playerNum[1] or 0));
        self.m_middle_room_btn:getChildByName("online_num_bg"):getChildByName("online_num"):setText("当前在线:"..(playerNum[2] or 0));
        self.m_master_room_btn:getChildByName("online_num_bg"):getChildByName("online_num"):setText("当前在线:"..(playerNum[3] or 0));
    end
end;

OnlineScene.onUpdatePrivateRoomNum = function(self,info)
    self.m_private_room_btn:getChildByName("online_num_bg"):getChildByName("online_num"):setText((info.private_room_num or 0).."个房间")
end

OnlineScene.onUpdateFriendsInfo = function(self,info)
    self.m_challenge_btn:getChildByName("info"):setText("空闲好友:"..(info.spare_num or 0).."人");
end

OnlineScene.onOnlineCollapse = function(self, data)
    self:collapseResult(data);
end;

OnlineScene.closeBankruptDialog = function(self)
    if self.m_bankrupt_subsidy_dialog and not self.m_bankrupt_subsidy_dialog.is_dismissing and self.m_bankrupt_subsidy_dialog:isShowing() then
        self.m_bankrupt_subsidy_dialog:dismiss();
        return true;
    end
    return false;
end

OnlineScene.collapseResult = function(self,data)

--	if not self.m_chioce_dialog then
--		self.m_chioce_dialog = new(ChioceDialog);
--	end
    if not self.m_bankrupt_subsidy_dialog then
		self.m_bankrupt_subsidy_dialog = new(BankruptSubsidyDialog);
	end
    self.m_bankrupt_subsidy_dialog:setData(data,self);

--	local message = "您今天的免费金币补助次数已领取完！购买金币继续游戏。";
--	if data then
--		message = string.format("您的金币不足！免费获得了%d的金币系统补助(今天还可领取%d次)。",data.money,data.remainderTimes);
--		local money = UserInfo.getInstance():getMoney() + data.money;
--		UserInfo.getInstance():setMoney(money);
--        self:refreshUserInfo();
--		self.m_chioce_dialog:setMode(ChioceDialog.MODE_OK);
--	else
--		self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE);
--	end

--	self.m_bankrupt_subsidy_dialog:setMessage(message);
    self.m_bankrupt_subsidy_dialog:setMallCallBack(self,function()
        self:requestCtrlCmd(OnlineController.s_cmds.jumpMall);
    end);
    self.m_bankrupt_subsidy_dialog:setGetDailyTaskCallBack(self,function()
        self:requestCtrlCmd(OnlineController.s_cmds.jumpActivity);
    end);
--    self.m_bankrupt_subsidy_dialog:setDismissCallBack(self,self.refreshUserInfo);
	self.m_bankrupt_subsidy_dialog:show();
end

OnlineScene.watch_action = function(self)
    Log.i("OnlineScene.watch_action");
    self:requestCtrlCmd(OnlineController.s_cmds.watch_action);
end;

OnlineScene.onChallengeBtnClick = function(self)
    Log.i("OnlineScene.onChallengeBtnClick");
    if not self.m_challenge_dialog then
        require("dialog/friends_pop_dialog");
        self.m_challenge_dialog = new(FriendPopDialog,self);
    end
    self.m_challenge_dialog:setMode(FriendPopDialog.MODE_FIGHT);
    self.m_challenge_dialog:setJumpFriendsCallBack(self,self.gotoFriendsScene);
    self.m_challenge_dialog:setPositiveListener(self, self.onPopDialogSureBtnClick);
    self.m_challenge_dialog:show();
end;

function OnlineScene:gotoFriendsScene()
    self:requestCtrlCmd(OnlineController.s_cmds.toFriendScene);
end

OnlineScene.onPopDialogSureBtnClick = function(self,adapter, view, index)
    Log.i("OnlineScene.onPopDialogSureBtnClick");
    if adapter and index and adapter:isHasView(index) then
        local friend = adapter:getTmpView(index);
        if friend and friend.datas then
            UserInfo.getInstance():setTargetUid(friend.datas.mid);
            local post_data = {};
            post_data.uid = tonumber(UserInfo.getInstance():getUid());
            post_data.level = 320;
            self:requestCtrlCmd(OnlineController.s_cmds.challenge,post_data); 
        end;    
    end;
end;

OnlineScene.onPrivateRoomBtnClick = function(self)
    self:requestCtrlCmd(OnlineController.s_cmds.private_action);
end

OnlineScene.showHelpDialog = function(self)
    require(DIALOG_PATH.."online_scene_help_dialog");
    if not self.helpDialog then
        self.helpDialog = new(OnlineSceneHelpDialog);
    end
    self.helpDialog:show();
end

---------------------------------config-------------------------------
OnlineScene.s_controlConfig = 
{
	[OnlineScene.s_controls.back_btn]               = {"back_btn"};
    [OnlineScene.s_controls.novice_room_btn]        = {"content_view","novice_room_btn"};
    [OnlineScene.s_controls.middle_room_btn]        = {"content_view","middle_room_btn"};
    [OnlineScene.s_controls.master_room_btn]        = {"content_view","master_room_btn"};
    [OnlineScene.s_controls.private_room_btn]       = {"content_view","private_room_btn"};
    [OnlineScene.s_controls.watch_btn]              = {"bottom_view","watch_btn"};
    [OnlineScene.s_controls.challenge_btn]          = {"bottom_view","challenge_btn"};
    [OnlineScene.s_controls.user_info_view]         = {"top_view","user_info_view"};
    [OnlineScene.s_controls.bg]                     = {"bg"};
    [OnlineScene.s_controls.top_view]               = {"top_view"};
    [OnlineScene.s_controls.teapot_dec]             = {"teapot_dec"};
    [OnlineScene.s_controls.stone_dec]              = {"stone_dec"};
    [OnlineScene.s_controls.bottom_view]            = {"bottom_view"};
    [OnlineScene.s_controls.content_view]           = {"content_view"};
    [OnlineScene.s_controls.helpBtn]                = {"top_view","help_btn"};
    
};
--定义控件的触摸响应函数
OnlineScene.s_controlFuncMap =
{
	[OnlineScene.s_controls.back_btn]               = OnlineScene.onOnlineBackActionBtnClick;
	[OnlineScene.s_controls.watch_btn]              = OnlineScene.watch_action;
    [OnlineScene.s_controls.private_room_btn]       = OnlineScene.onPrivateRoomBtnClick;
    [OnlineScene.s_controls.challenge_btn]          = OnlineScene.onChallengeBtnClick;
    [OnlineScene.s_controls.helpBtn]                = OnlineScene.showHelpDialog;
};

OnlineScene.s_cmdConfig = 
{
    [OnlineScene.s_cmds.update_room_players]        = OnlineScene.onUpdateRoomPlayers;
    [OnlineScene.s_cmds.update_private_room_num]    = OnlineScene.onUpdatePrivateRoomNum;
    [OnlineScene.s_cmds.update_friends_info]        = OnlineScene.onUpdateFriendsInfo;
    [OnlineScene.s_cmds.online_collapse]            = OnlineScene.onOnlineCollapse;
    [OnlineScene.s_cmds.closeBankruptDialog]        = OnlineScene.closeBankruptDialog;
    [OnlineScene.s_cmds.refresh_userinfo]           = OnlineScene.refreshUserInfo;

}