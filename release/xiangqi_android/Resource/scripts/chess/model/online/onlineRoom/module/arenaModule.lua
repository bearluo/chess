require(MODEL_PATH .. "online/onlineRoom/module/baseModule");
require("chess/prefabs/roomDoubleProp")

ArenaModule = class(BaseModule);

function ArenaModule.ctor(self,scene)
    BaseModule.ctor(self,scene);
	self.mScene.m_multiple_text:setText("竞技场");
    self.mRoomDoubleProp = new(RoomDoubleProp)
    self.mRoomDoubleProp:setAlign(kAlignBottomRight)
    self.mRoomDoubleProp:setPos(-70,-60)
    self.mScene.m_down_view:addChild(self.mRoomDoubleProp)
    self:updateUserInfoView()
end

function ArenaModule.dtor(self)
    delete(self.mScene.m_match_dialog);
    delete(self.mArenaTipsDialog);
    delete(self.mRoomDoubleProp);
	self.mScene.m_multiple_text:setText("");
end

function ArenaModule.initGame(self)
    self.mScene.m_roomid:setVisible(false);
    self.mScene.m_multiple_img_bg:setVisible(true);--倍数
    self.mScene:downComeIn(UserInfo.getInstance());
    if UserInfo.getInstance():getRelogin() then
        self.mScene:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_login); 
	end
    --初始化时弹出选择玩家弹窗
    if not UserInfo.getInstance():getRelogin() then
        self:matchRoom();
    end
end

function ArenaModule:updateUserInfoView()
    if not UserInfo.getInstance():isHasDoubleProp() then
        self.mRoomDoubleProp:setVisible(false)
    else
        self.mRoomDoubleProp:setVisible(true)
    end
end
function ArenaModule.resetGame(self)
    self.mScene.m_chest_btn:setVisible(false);
	self.mScene.m_multiple_img_bg:setVisible(false);
	self.mScene.m_down_view1.user_name:setVisible(false);
	self.mScene.m_up_view1.user_name:setVisible(false);
end

function ArenaModule.dismissDialog(self)
    if self.mScene.m_match_dialog and self.mScene.m_match_dialog:isShowing() then
		self.mScene.m_match_dialog:dismiss();
	end
end

function ArenaModule.readyAction(self)
    if self.mScene.m_match_dialog then
        self.mScene.m_match_dialog:dismiss();
    end
    self.mScene.m_upuser_leave = false;
end

function ArenaModule.backAction(self)
    local message = "亲，中途离开则会输掉棋局哦！"
	if not self.mScene.m_chioce_dialog then
		self.mScene.m_chioce_dialog = new(ChioceDialog);
	end
	self.mScene.m_chioce_dialog:setNegativeListener(nil,nil);
    if self.mScene.m_downUser and not self.mScene.m_game_start then
        message = "您确定离开吗？"
        self.mScene.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE,"退出","取消");
        self.mScene.m_chioce_dialog:setPositiveListener(self.mScene,self.mScene.exitRoom);
        self.mScene.m_chioce_dialog:setNegativeListener(self,function(self)
            OnlineRoomController.s_switch_func = nil
        end)
    elseif self.mScene.m_downUser then
        if not self.mScene:checkCanSurrender() then OnlineRoomController.s_switch_func = nil return end
--        local step = self.mScene.m_board:getMoveStepNum();
--	    local roominfo = RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_ARENA_ROOM);
--        local minStep = roominfo.least_step
--        if minStep > 0 and step > 0 and step < minStep+1 then
--            ChessToastManager.getInstance():showSingle( string.format("双方还需走 %d 步才能投降",minStep+1-step));
--            return
--        end
        self.mScene.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE,"认输退出","取消");
        self.mScene.m_chioce_dialog:setPositiveListener(self.mScene,self.mScene.surrender_sure);
        self.mScene.m_chioce_dialog:setNegativeListener(self,function(self)
            OnlineRoomController.s_switch_func = nil
        end)
    else
        self.mScene.m_chioce_dialog:setPositiveListener(self.mScene,self.mScene.exitRoom);
        self.mScene.m_chioce_dialog:setNegativeListener(self,function(self)
            OnlineRoomController.s_switch_func = nil
        end)
    end
	self.mScene.m_chioce_dialog:setMessage(message);
	self.mScene.m_chioce_dialog:show();
end

-- 对方退出房间后弹出确认重新匹配对话框
function ArenaModule.showRematchComfirmDialog(self)
    if self.mScene.m_match_dialog and self.mScene.m_match_dialog:isShowing() then
        self.mScene.m_match_dialog:setVisible(false);
    end
    if self.mScene.m_account_dialog and self.mScene.m_account_dialog:isShowing() then
        return;
    end
    local message = "对方退出房间，请重新匹配对手！"
    if not self.mScene.m_rematch_dialog then
		self.mScene.m_rematch_dialog = new(ChioceDialog);
	end
    self.mScene.m_rematch_dialog:setMode(ChioceDialog.MODE_SURE,"确定","退出房间");
    self.mScene.m_rematch_dialog:setPositiveListener(self,self.changeChessRoom);
    self.mScene.m_rematch_dialog:setMessage(message);
	self.mScene.m_rematch_dialog:setNegativeListener(self.mScene,self.mScene.exitRoom);
	self.mScene.m_rematch_dialog:show();
end

function ArenaModule.changeChessRoom(self)
    self.mScene.changeRoom = true;
    UserInfo.getInstance():setChallenger(nil);
	OnlineConfig.deleteTimer(self.mScene); 
    self.mScene.m_board_menu_dialog:dismiss();
    self.mScene.m_connectCount = 0;
	UserInfo.getInstance():setRelogin(false) 

    if self.mScene.m_login_succ then
        self.mScene:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_logout);
    else
        self:matchRoom();
    end
end

--匹配对手
function ArenaModule.matchRoom(self,isRematch)
    if not isRematch then
        self.mScene.m_matchIng = true;
	    if not self.mScene.m_match_dialog then
		    self.mScene.m_match_dialog = new(MatchDialog);
	    end
	    self.mScene:showMoneyRent();

	    self.mScene.m_match_dialog:show(self.mScene,UserInfo.getInstance():getMatchTime());
    end
    local data = {};
    local config = RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_ARENA_ROOM);
    if config then
        data.roomType = config.level;
    else
        return ;
    end
    data.playerLevel = self.mScene.m_upPlayer_level;
    self.mScene:requestCtrlCmd(OnlineRoomController.s_cmds.hall_game_info, data); 
end

function ArenaModule.cancelMatch(self)
    self.mScene:requestCtrlCmd(OnlineRoomController.s_cmds.hall_cancel_match); 
end

require(DIALOG_PATH .. "arenaTipsDialog");
function ArenaModule.onMatchSuccess(self,data)
    if self.mScene.m_match_dialog then
        self.mScene.m_matchIng = false;
	    self.mScene.m_match_dialog:dismiss();
        self.mScene:ready_action();
	end
    self.mScene:updateRestartView(false)

    local uid = UserInfo.getInstance():getUid() or 0;
    local isTrue = GameCacheData.getInstance():getBoolean(GameCacheData.ARENA_TIPS_ .. uid,false);
    if isTrue or self.mIsShowed then return end
    self.mIsShowed = true;
    if not self.mArenaTipsDialog then
        self.mArenaTipsDialog = new(ArenaTipsDialog);
    end
    local config = RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_ARENA_ROOM);
    if type(config) ~= "table" then return end
    local params = {};
    params.time1 = config.roundTime or 0;
    params.time2 = config.stepTime or 0;
    params.time3 = config.secTime or 0;
    params.money = config.rent or 0;
    self.mArenaTipsDialog:show(params);
end

function ArenaModule.onMatchRoomFail(self,data)
	print_string("匹配失败");
--	self.m_down_user_start_btn:setVisible(true);
    
	local message = "匹配失败，请重新匹配。"
	if self.mScene.m_match_dialog then
		self.mScene.m_match_dialog:dismiss();
	end

	if not self.mScene.m_chioce_dialog then
		self.mScene.m_chioce_dialog = new(ChioceDialog);
	end


    if data and data.errCode == 0 and data.size > 0 then
        local time = data.times[1];
        message = string.format("竞技场对弈时间为%02d点%02d分-%02d点%02d分",time.start_hour,time.start_minute,time.end_hour,time.end_minute)
        self.mScene.m_chioce_dialog:setMode(ChioceDialog.MODE_OK);
	    self.mScene.m_chioce_dialog:setMessage(message);
	    self.mScene.m_chioce_dialog:setPositiveListener(self.mScene,self.mScene.exitRoom);
	    self.mScene.m_chioce_dialog:show();
        return 
    end
    
    self.mScene.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE,"确定","退出房间");
	self.mScene.m_chioce_dialog:setMessage(message);
	self.mScene.m_chioce_dialog:setPositiveListener(self,self.changeChessRoom);
	self.mScene.m_chioce_dialog:setNegativeListener(self.mScene,self.mScene.exitRoom);
	self.mScene.m_chioce_dialog:show();
end

--更新匹配动画里的弹窗
function ArenaModule.sendFllowCallback(self,info)
--    if self.mScene.m_match_dialog and self.mScene.m_match_dialog:isShowing() then
--        self.mScene.m_match_dialog:update(info);
--    end  
end