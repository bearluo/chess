
require(BASE_PATH.."chessScene");
require("view/selectButton");
require("dialog/progress_dialog");
require("dialog/create_room_dialog");
require("dialog/bankrupt_subsidy_dialog");
require("chess/util/statisticsManager");
require(DIALOG_PATH.."arenaRankDialog");
require(DIALOG_PATH.."common_help_dialog");
require(DIALOG_PATH.."moneyRoomListDialog")


OnlineScene = class(ChessScene);

OnlineScene.BANKRUPT_MESSAGE = "您的金币今天不足以继续游戏，请明天再接再励!";
OnlineScene.LACK_MESSAGE = "该场次最低需携带%d金币，请移步到其他场次进行游戏。";
OnlineScene.OVER_MESSAGE = "世界那么大，您那么富有，是时候去更高级的场次看看了~";

OnlineScene.remindSetNicknameDialogValue = 
{ 
    CHANGE = "立刻修改";
    NO= "以后再说";
    MESSAGE = "为自己取一个独一无二的昵称能让其他人更容易记住您" ;
}
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
    arena_room_btn          = 5;
    arena_room_tip          = 6;
    watch_btn               = 7;
    private_btn             = 8;    
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
    rank_btn                = 19;
    rank_bg                 = 20;
    content_match_view      = 21;
    money_match_room_btn    = 22;
    scroll_view             = 23;

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
    if self.mArenaRankDialog and self.mArenaRankDialogResume then
        self.mArenaRankDialog:show(true)
        self.mArenaRankDialogResume = false
    end
    if not GameCacheData.getInstance():getBoolean(GameCacheData.ONLINE_SCENE_TIPS_ .. UserInfo.getInstance():getUid() .. kLuaVersionCode ,false) then
        GameCacheData.getInstance():saveBoolean(GameCacheData.ONLINE_SCENE_TIPS_ .. UserInfo.getInstance():getUid() .. kLuaVersionCode ,true)
        self.mHelpTipsImg = new(Image,ChessDialogScene.s_mask_bg)
        self.mHelpTipsImg:setTransparency(0.8)
        self.mHelpTipsImg:setFillParent(true,true)
        self:addChild(self.mHelpTipsImg)
        local x,y = self:findViewById(self.m_ctrls.helpBtn):getAbsolutePos()
        local img = new(Image,"online/tip_2.png")
        img:setPos(x+22,y+85)
        self.mHelpTipsImg:addChild(img)
        
        local x,y = self:findViewById(self.m_ctrls.arena_room_btn):getAbsolutePos()
        local img = new(Image,"online/tip_3.png")
        img:setPos(x+8,y+180)
        self.mHelpTipsImg:addChild(img)

        local x,y = self:findViewById(self.m_ctrls.rank_btn):getAbsolutePos()
        local img = new(Image,"online/tip_1.png")
        img:setPos(x-48,y+100)
        self.mHelpTipsImg:addChild(img)
        
        local x,y = self:findViewById(self.m_ctrls.private_btn):getAbsolutePos()
        local img = new(Image,"online/tip_4.png")
        img:setPos(x+95,y-140)
        self.mHelpTipsImg:addChild(img)

        self.mHelpTipsImg:setEventTouch(self,function(self)
            self.mHelpTipsImg:setVisible(false)
        end)
    end
    self:refreshUserInfo()

    self:showRemindSetNicknameDialog()
end

OnlineScene.pause = function(self)
	ChessScene.pause(self);
    self:removeAnimProp();
--    self:pauseAnimStart();
    if self.mArenaRankDialog and self.mArenaRankDialog:isShowing() then
        self.mArenaRankDialog:dismiss()
        self.mArenaRankDialogResume = true
    end
end 


OnlineScene.dtor = function(self)
    self:removeAnimProp();
    delete(self.m_chioce_dialog);
    delete(self.m_createroom_dialog);
    delete(self.anim_end);
    delete(self.anim_timer);
    delete(self.m_bankrupt_subsidy_dialog);
    delete(self.helpDialog);
    delete(self.mArenaRankDialog);
    --销毁弹窗
    if self.remindSetNicknameDialog then 
        delete(self.remindSetNicknameDialog)
    end
end 

------------------------------anim----------------------------------
OnlineScene.removeAnimProp = function(self)
    if self.m_anim_prop_need_remove then
        self.m_leaf_right:removeProp(1);
        self.m_leaf_left:removeProp(1);
        self.m_novice_room_btn:removeProp(1);
        self.m_novice_room_btn:removeProp(2);
        self.m_middle_room_btn:removeProp(1);
        self.m_middle_room_btn:removeProp(2);
        self.m_master_room_btn:removeProp(1);
        self.m_master_room_btn:removeProp(2);
        self.m_arena_room_btn:removeProp(1);
        self.m_arena_room_btn:removeProp(2);
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
    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1, kAnimNormal, duration, delay, -lw, 0, -10, 0);
    local rw,rh = self.m_leaf_right:getSize();
    self.m_leaf_right:addPropTranslate(1, kAnimNormal, duration, delay, rw, 0, -10, 0);

    
    self.m_arena_room_btn:addPropTransparency(2,kAnimNormal,duration,delay + 100,0,1);
    self.m_arena_room_btn:addPropScale(1,kAnimNormal,duration,delay + 100,0.8,1,0.8,1,kCenterXY,100,250);

    self.m_novice_room_btn:addPropTransparency(2,kAnimNormal,duration,delay + 200,0,1);
    self.m_novice_room_btn:addPropScale(1,kAnimNormal,duration,delay + 200,0.8,1,0.8,1,kCenterXY,100,250);

    self.m_middle_room_btn:addPropTransparency(2,kAnimNormal,duration,delay + 300,0,1);
    self.m_middle_room_btn:addPropScale(1,kAnimNormal,duration,delay + 300,0.8,1,0.8,1,kCenterXY,100,250);

    self.m_master_room_btn:addPropTransparency(2,kAnimNormal,duration,delay + 400,0,1);
    local anim = self.m_master_room_btn:addPropScale(1,kAnimNormal,duration,delay + 400,0.8,1,0.8,1,kCenterXY,100,250);
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
    self.m_leaf_right = self.m_top_view:getChildByName("leaf_right");
    self.m_leaf_left = self.m_top_view:getChildByName("leaf_left");

    self.m_leaf_left:setFile("common/decoration/left_leaf.png")
    self.m_leaf_right:setFile("common/decoration/right_leaf.png")

--    self.m_bottom_view = self:findViewById(self.m_ctrls.bottom_view);
--    self.m_stone_dec = self:findViewById(self.m_ctrls.stone_dec);
--    self.m_teapot_dec = self:findViewById(self.m_ctrls.teapot_dec);
--    self.m_back_btn = self:findViewById(self.m_ctrls.back_btn);
    self.m_content_view = self:findViewById(self.m_ctrls.content_view);
    self.m_scroll_view = self:findViewById(self.m_ctrls.scroll_view);
    self.m_content_view:setVisible(true)
    local w,h = self:getSize()
    self.m_scroll_view:setClip(0,0,w,h);
    local func = function(view,enable)
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
    self.m_arena_room_btn = self:findViewById(self.m_ctrls.arena_room_btn);
    self.m_arena_room_btn:setOnTuchProcess(self.m_arena_room_btn,func);

    self.m_arena_tips = self:findViewById(self.m_ctrls.arena_room_tip);
    self.m_rank_bg = self:findViewById(self.m_ctrls.rank_bg);
    if kPlatform == kPlatformIOS then
        if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
            self.m_arena_tips:setText("对弈赢话费");
            self.m_rank_bg:setVisible(true);
        else
            self.m_arena_tips:setText("400底注");
            self.m_rank_bg:setVisible(false);
        end;
    else
        self.m_arena_tips:setText("对弈赢话费");
        self.m_rank_bg:setVisible(true);
    end
    local func = function(view,enable)
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
    self.m_private_btn = self:findViewById(self.m_ctrls.private_btn);
    self.m_private_btn:setOnTuchProcess(self.m_private_btn,func);


    self.m_user_info_view = self:findViewById(self.m_ctrls.user_info_view);

    local roomConfig        = RoomConfig.getInstance();
    local noviceData        = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_NOVICE_ROOM);
    local intermediateData  = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_INTERMEDIATE_ROOM);
    local masterData        = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_MASTER_ROOM);
    local arenaData         = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_ARENA_ROOM);
    -- 新手房
    if noviceData then
        self.m_novice_room_btn:getChildByName("content"):getChildByName("score_bg"):getChildByName("introduction"):setText((noviceData.money or 0).."底注");
        local func = function(self)
            StatisticsManager.getInstance():onCountToUM(ONLINE_MODEL_NEWFISH_BTN);
            OnlineScene.onOnlineListItemClick(self,noviceData);
        end
        self.m_novice_room_btn:setOnClick(self,func);
    end

    -- 中级房
    if intermediateData then
        self.m_middle_room_btn:getChildByName("content"):getChildByName("score_bg"):getChildByName("introduction"):setText((intermediateData.money or 0).."底注");
        local func = function(self)
            StatisticsManager.getInstance():onCountToUM(ONLINE_MODEL_MIDDLE_BTN);
            OnlineScene.onOnlineListItemClick(self,intermediateData);
        end
        self.m_middle_room_btn:setOnClick(self,func);
    end

    -- 大师房
    if masterData then
        self.m_master_room_btn:getChildByName("content"):getChildByName("score_bg"):getChildByName("introduction"):setText((masterData.money or 0).."底注");
        local func = function(self)
            StatisticsManager.getInstance():onCountToUM(ONLINE_MODEL_MASTER_BTN);
            OnlineScene.onOnlineListItemClick(self,masterData);
        end
        self.m_master_room_btn:setOnClick(self,func);
    end

    -- 积分场
    if arenaData then
--        self.m_arena_room_btn:getChildByName("content"):getChildByName("score_bg"):getChildByName("introduction"):setText((arenaData.money or 0).."底注");
        local func = function(self)
            StatisticsManager.getInstance():onCountToUM(ONLINE_MODEL_SPORTS_BTN);
            if not arenaData.isShow or tonumber(arenaData.isShow) == 0 then
                local msg = "竞技场暂未开放!";
                ChessToastManager.getInstance():showSingle(msg);
                return
            end
            OnlineScene.onOnlineListItemClick(self,arenaData);
        end
        self.m_arena_room_btn:setOnClick(self,func);
    end

    self.m_user_info_view:getChildByName('score'):setText("积分:"..UserInfo.getInstance():getScore());
    self.m_user_info_view:getChildByName('gold'):setText(UserInfo.getInstance():getMoneyStr());
    self.m_user_info_view:getChildByName('winrate'):setText("胜率:"..UserInfo.getInstance():getRate());
end

OnlineScene.refreshUserInfo = function(self)
    self.m_user_info_view:getChildByName('score'):setText("积分:"..UserInfo.getInstance():getScore());
    self.m_user_info_view:getChildByName('gold'):setText(UserInfo.getInstance():getMoneyStr());
    self.m_user_info_view:getChildByName('winrate'):setText("胜率:"..UserInfo.getInstance():getRate());
	self:getCollapseReward();
end;

OnlineScene.showIosEvaluateDlg = function(self)
--    local isShow = GameCacheData.getInstance():getBoolean(GameCacheData.IS_SHOW_IOS_EVALUATE_DIALOG, false); -- 是否连胜显示
--    local hasEvaluated = GameCacheData.getInstance():getBoolean(GameCacheData.HAS_EVALAUTED,false);-- 已经评价了
--    local lastShowDlgTime = GameCacheData.getInstance():getInt(GameCacheData.LAST_SHOWEVADLG_TIME,0);-- 上次显示的时间
--    local isSecondDay = ToolKit.isSecondDay(lastShowDlgTime);
--    if (isShow and not hasEvaluated and isSecondDay) or kDebug then
--        self.m_eva_chioce_dialog = new(ChioceDialog);
--        self.m_eva_chioce_dialog:setMode(ChioceDialog.MODE_SURE,"去评价","残忍拒绝");
--        self.m_eva_chioce_dialog:setMessage("大侠，你辣么厉害，不如给我们评个分吧！");
--        self.m_eva_chioce_dialog:setPositiveListener(self, function()
--            call_native(kIosAppStoreEvaluate);
--            GameCacheData.getInstance():saveBoolean(GameCacheData.HAS_EVALAUTED,true);
--        end);
--        self.m_eva_chioce_dialog:setNegativeListener(self, function()
--            GameCacheData.getInstance():saveBoolean(GameCacheData.HAS_EVALAUTED,false);
--        end); 
--        self.m_eva_chioce_dialog:show();
--        GameCacheData.getInstance():saveInt(GameCacheData.LAST_SHOWEVADLG_TIME,os.time());
--    end;
end;
OnlineScene.getCollapseReward = function(self)
	print_string("Online.getCollapseReward ...");
    local money = UserInfo.getInstance():getMoney();
	if RoomProxy.getInstance():canCollapseReward(money) and UserInfo.getInstance():getShowBankruptStatus() then
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
	self:entryOnlineGame(tonumber(room.room_type));
end

OnlineScene.entryOnlineGame = function(self,room_type)
	
    local money = UserInfo.getInstance():getMoney();

	if tonumber(money) <=0  then
        if UserInfo.getInstance():getShowBankruptStatus() then
            self:getCollapseReward();
        else
            self:coinQuickBuyDlg();
        end
		return;
	end

	local isCanEntry = RoomProxy.getInstance():canAccessRoom(room_type,money);
    
    local noviceData        = RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_NOVICE_ROOM);
    local intermediateData  = RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_INTERMEDIATE_ROOM);
    local masterData        = RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_MASTER_ROOM);
    local arenaData         = RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_ARENA_ROOM);
	if isCanEntry then
		ToolKit.removeAllTipsDialog(); 
        if room_type == RoomConfig.ROOM_TYPE_NOVICE_ROOM then
		    RoomProxy.getInstance():gotoNoviceRoom()
        elseif room_type == RoomConfig.ROOM_TYPE_INTERMEDIATE_ROOM then
		    RoomProxy.getInstance():gotoIntermediateRoom()
        elseif room_type == RoomConfig.ROOM_TYPE_MASTER_ROOM then
		    RoomProxy.getInstance():gotoMasterRoom()
        elseif room_type == RoomConfig.ROOM_TYPE_ARENA_ROOM then
		    RoomProxy.getInstance():gotoArenaRoom()
        end
		return;
	end

	local message = "";
	local room = RoomConfig.getInstance():getRoomTypeConfig(room_type);
    local canCollapseReward = RoomProxy.getInstance():canCollapseReward(money)
	if canCollapseReward then
		-- message = Online.BANKRUPT_MESSAGE;
        if UserInfo.getInstance():getShowBankruptStatus() then
            self:getCollapseReward();
        else
            self:coinQuickBuyDlg();
        end
		return;
	elseif money < room.minmoney then
		message = string.format(OnlineScene.LACK_MESSAGE,room.minmoney);
	elseif money > room.maxmoney then
		message = string.format(OnlineScene.OVER_MESSAGE,room.maxmoney);
	end

	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end

	self.m_chioce_dialog:setMode(ChioceDialog.MODE_OK,"知道了");
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
	self.m_chioce_dialog:setMode(ChioceDialog.MODE_OK,"知道了");
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
    
    local roomConfig        = RoomConfig.getInstance();
    local noviceData        = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_NOVICE_ROOM);
    local intermediateData  = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_INTERMEDIATE_ROOM);
    local masterData        = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_MASTER_ROOM);
    local arenaData         = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_ARENA_ROOM);

    if room_player then
        
        local roomPlayer = UserInfo.getInstance():getRoomPlayerNum()
        for key,val in pairs(room_player) do
            roomPlayer[key] = val
        end

        self.m_novice_room_btn:getChildByName("online_num_bg"):getChildByName("online_num"):setText((roomPlayer[noviceData.level] or 0).."人");
        self.m_middle_room_btn:getChildByName("online_num_bg"):getChildByName("online_num"):setText((roomPlayer[intermediateData.level] or 0).."人");
        self.m_master_room_btn:getChildByName("online_num_bg"):getChildByName("online_num"):setText((roomPlayer[masterData.level] or 0).."人");
        self.m_arena_room_btn:getChildByName("online_num_bg"):getChildByName("online_num"):setText((roomPlayer[arenaData.level] or 0).."人");
        self.m_watch_btn:getChildByName("info"):setText((room_player["watch"] or 0).."人");

        UserInfo.getInstance():setRoomPlayerNum(roomPlayer)
    end
end

OnlineScene.onUpdatePrivateRoomNum = function(self,info)
    self.m_private_btn:getChildByName("info"):setText((info.private_room_num or 0).."间");
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
    StatisticsManager.getInstance():onCountToUM(ONLINE_MODEL_WATCH_BTN);
    self:requestCtrlCmd(OnlineController.s_cmds.watch_action);
end

OnlineScene.onPrivateRoomBtnClick = function(self)
    StatisticsManager.getInstance():onCountToUM(ONLINE_MODEL_PRIVATE_BTN);
    self:requestCtrlCmd(OnlineController.s_cmds.private_action);
end

OnlineScene.showHelpDialog = function(self)
    if not self.helpDialog then
        self.helpDialog = new(CommonHelpDialog)
        self.helpDialog:setMode(CommonHelpDialog.online_mode)
    end 
    self.helpDialog:show()
end

function OnlineScene.showRankDialog(self)
    if not self.mArenaRankDialog then
        self.mArenaRankDialog = new(ArenaRankDialog)
    end
    self.mArenaRankDialog:show();
end

require("dialog/chioce_dialog")
--提醒用户设置修改自己的昵称
function OnlineScene.showRemindSetNicknameDialog(self)
    local isShowed = GameCacheData.getInstance():getInt(GameCacheData.SHOW_REMIND_SET_NICKNAME_DIALOG_ .. UserInfo.getInstance():getUid(),0);
    if isShowed == 1 or UserInfo:getInstance():getIsModifyUserMnick() == 0 or not UserInfo:getInstance():isNeedRemindSetNickname() then 
        return 
    end
    GameCacheData.getInstance():saveInt(GameCacheData.SHOW_REMIND_SET_NICKNAME_DIALOG_ .. UserInfo.getInstance():getUid(),1);
    if not self.remindSetNicknameDialog then 
        self.remindSetNicknameDialog = new (ChioceDialog)
    end
    self.remindSetNicknameDialog:setMode(1,OnlineScene.remindSetNicknameDialogValue.CHANGE,OnlineScene.remindSetNicknameDialogValue.NO)
    self.remindSetNicknameDialog:setMessage(OnlineScene.remindSetNicknameDialogValue.MESSAGE)
    self.remindSetNicknameDialog:setPositiveListener( self.remindSetNicknameDialog, function()
            self.remindSetNicknameDialog:dismiss()
            self:requestCtrlCmd(OnlineController.s_cmds.jumpToOwnScene)
        end )
    self.remindSetNicknameDialog:setNegativeListener(self.remindSetNicknameDialog , function ()
            self.remindSetNicknameDialog:dismiss()
        end)
    self.remindSetNicknameDialog:show()
end
---------------------------------config-------------------------------
OnlineScene.s_controlConfig = 
{
	[OnlineScene.s_controls.back_btn]               = {"back_btn"};
    [OnlineScene.s_controls.novice_room_btn]        = {"scroll_view","content_view","novice_room_btn"};
    [OnlineScene.s_controls.middle_room_btn]        = {"scroll_view","content_view","middle_room_btn"};
    [OnlineScene.s_controls.master_room_btn]        = {"scroll_view","content_view","master_room_btn"};
    [OnlineScene.s_controls.arena_room_btn]         = {"scroll_view","content_view","arena_room_btn"};
    [OnlineScene.s_controls.arena_room_tip]         = {"scroll_view","content_view","arena_room_btn","content","score_bg","introduction"};
    [OnlineScene.s_controls.watch_btn]              = {"bottom_view","watch_btn"};
    [OnlineScene.s_controls.private_btn]            = {"bottom_view","private_btn"};
    [OnlineScene.s_controls.user_info_view]         = {"top_view","user_info_view"};
    [OnlineScene.s_controls.bg]                     = {"bg"};
    [OnlineScene.s_controls.top_view]               = {"top_view"};
    [OnlineScene.s_controls.teapot_dec]             = {"teapot_dec"};
    [OnlineScene.s_controls.stone_dec]              = {"stone_dec"};
    [OnlineScene.s_controls.bottom_view]            = {"bottom_view"};
    [OnlineScene.s_controls.scroll_view]           = {"scroll_view"};
    [OnlineScene.s_controls.content_view]           = {"scroll_view","content_view"};
    [OnlineScene.s_controls.helpBtn]                = {"top_view","help_btn"};
    [OnlineScene.s_controls.rank_btn]               = {"top_view","rank_bg","rank_btn"};
    [OnlineScene.s_controls.rank_bg]                = {"top_view","rank_bg"};
    [OnlineScene.s_controls.rank_btn]               = {"top_view","rank_bg","rank_btn"};
};

--定义控件的触摸响应函数
OnlineScene.s_controlFuncMap =
{
	[OnlineScene.s_controls.back_btn]               = OnlineScene.onOnlineBackActionBtnClick;
	[OnlineScene.s_controls.watch_btn]              = OnlineScene.watch_action;
    [OnlineScene.s_controls.private_btn]            = OnlineScene.onPrivateRoomBtnClick;
    [OnlineScene.s_controls.helpBtn]                = OnlineScene.showHelpDialog;
    [OnlineScene.s_controls.rank_btn]               = OnlineScene.showRankDialog;
};

OnlineScene.s_cmdConfig = 
{
    [OnlineScene.s_cmds.update_room_players]        = OnlineScene.onUpdateRoomPlayers;
    [OnlineScene.s_cmds.update_private_room_num]    = OnlineScene.onUpdatePrivateRoomNum;
    [OnlineScene.s_cmds.online_collapse]            = OnlineScene.onOnlineCollapse;
    [OnlineScene.s_cmds.closeBankruptDialog]        = OnlineScene.closeBankruptDialog;
    [OnlineScene.s_cmds.refresh_userinfo]           = OnlineScene.refreshUserInfo;
    
}