require(MODEL_PATH .. "online/onlineRoom/module/baseModule");
require("chess/prefabs/roomDoubleProp")
OnlineModule = class(BaseModule);

function OnlineModule.ctor(self,scene)
    BaseModule.ctor(self,scene);
    local roomType = RoomProxy.getInstance():getCurRoomType();
    if roomType == RoomConfig.ROOM_TYPE_NOVICE_ROOM then
	    self.mScene.m_multiple_text:setText("初级场");
    elseif roomType == RoomConfig.ROOM_TYPE_INTERMEDIATE_ROOM then
	    self.mScene.m_multiple_text:setText("中级场");
    elseif roomType == RoomConfig.ROOM_TYPE_MASTER_ROOM then
	    self.mScene.m_multiple_text:setText("高级场");
    end
    self.mRoomDoubleProp = new(RoomDoubleProp)
    self.mRoomDoubleProp:setAlign(kAlignBottomRight)
    self.mRoomDoubleProp:setPos(-70,-60)
    self.mScene.m_down_view:addChild(self.mRoomDoubleProp)
    self:updateUserInfoView()
end

function OnlineModule.dtor(self)
	self.mScene.m_multiple_text:setText("");
    delete(self.mScene.m_match_dialog);
    delete(self.mRoomDoubleProp);
--    delete(self.mChangeAnim)
end

function OnlineModule.initGame(self)
    self.mScene.m_roomid:setVisible(false);
    self.mScene.m_multiple_img_bg:setVisible(true);--倍数
    self.mScene:downComeIn(UserInfo.getInstance());
    if UserInfo.getInstance():getRelogin() then
        self.mScene:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_login); 
	end
    --初始化时弹出选择玩家弹窗
    self.mCountNum = 0
    if not UserInfo.getInstance():getRelogin() then
        self:matchRoom();
    end
end

function OnlineModule:updateUserInfoView()
    if not UserInfo.getInstance():isHasDoubleProp() then
        self.mRoomDoubleProp:setVisible(false)
    else
        self.mRoomDoubleProp:setVisible(true)
    end
end

function OnlineModule.resetGame(self)
    self.mScene.m_chest_btn:setVisible(false);
	self.mScene.m_multiple_img_bg:setVisible(false);
end

function OnlineModule.dismissDialog(self)
    if self.mScene.m_match_dialog and self.mScene.m_match_dialog:isShowing() then
		self.mScene.m_match_dialog:dismiss();
	end
end

function OnlineModule.startGame(self,status)
    self.mScene.m_down_user_start_btn:setVisible(false)
    if self.mScene.m_upUser:getUid() ~= self.mPreUid then
        self.mCountNum = 1
        self.mPreUid = self.mScene.m_upUser:getUid()
    else
        self.mCountNum = (self.mCountNum or 0) + 1
    end
end

function OnlineModule.readyAction(self)
    if self.mScene.m_match_dialog then
        self.mScene.m_match_dialog:dismiss();
    end
    self.mScene.m_upuser_leave = false;
end

function OnlineModule.canSendReadyAction(self)
    if self.mCountNum and self.mCountNum >= 5 then
        ChessToastManager.getInstance():showSingle("为保证游戏的公平性，需更换您的对手",2000)
--        delete(self.mChangeAnim)
--        self.mChangeAnim = AnimFactory.createAnimInt(kAnimNormal, 0, 1, 1500, -1)
--        self.mChangeAnim:setEvent(self,function()
            self.mCountNum = 0
            self:changeChessRoom()
--        end)
        return false
    end
    return true
end

function OnlineModule.backAction(self)
    local message = "亲，中途离开则会输掉棋局哦！"
	if not self.mScene.m_chioce_dialog then
		self.mScene.m_chioce_dialog = new(ChioceDialog);
	end
	self.mScene.m_chioce_dialog:setNegativeListener(nil,nil);
    if self.mScene.m_downUser and not self.mScene.m_game_start then
        message = "您确定离开吗？"
        self.mScene:exitRoom()
        return
--        self.mScene.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE,"退出","取消");
--        self.mScene.m_chioce_dialog:setPositiveListener(self.mScene,self.mScene.exitRoom);
--        self.mScene.m_chioce_dialog:setNegativeListener(self,function(self)
--            OnlineRoomController.s_switch_func = nil
--        end)
    elseif self.mScene.m_downUser then
        if not self.mScene:checkCanSurrender() then OnlineRoomController.s_switch_func = nil return end
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
function OnlineModule.showRematchComfirmDialog(self)
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

function OnlineModule.changeChessRoom(self)
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
function OnlineModule.matchRoom(self,isRematch)
    self.mCountNum = 0
    if not isRematch then
        self.mScene.m_matchIng = true;
	    if not self.mScene.m_match_dialog then
		    self.mScene.m_match_dialog = new(MatchDialog);
	    end
	    self.mScene:showMoneyRent();

	    self.mScene.m_match_dialog:show(self.mScene,UserInfo.getInstance():getMatchTime());
    end
    local data = {};
    local roomType = RoomProxy.getInstance():getCurRoomType();
    if RoomConfig.ROOM_TYPE_NOVICE_ROOM == roomType and RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_NOVICE_ROOM) then
        data.roomType = RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_NOVICE_ROOM).level;
    elseif RoomConfig.ROOM_TYPE_INTERMEDIATE_ROOM == roomType and RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_INTERMEDIATE_ROOM) then
        data.roomType = RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_INTERMEDIATE_ROOM).level;
    elseif RoomConfig.ROOM_TYPE_MASTER_ROOM == roomType and RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_MASTER_ROOM) then
        data.roomType = RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_MASTER_ROOM).level;
    else
        return ;
    end;
    data.playerLevel = self.mScene.m_upPlayer_level;
    self.mScene:requestCtrlCmd(OnlineRoomController.s_cmds.hall_game_info, data); 
end

function OnlineModule.cancelMatch(self)
    self.mScene:requestCtrlCmd(OnlineRoomController.s_cmds.hall_cancel_match); 
end

function OnlineModule.onMatchSuccess(self,data)
    if self.mScene.m_match_dialog then
        self.mScene.m_matchIng = false;
	    self.mScene.m_match_dialog:onMatchSuc(data);
	end
    self.mScene:updateRestartView(false)
end

function OnlineModule.onMatchRoomFail(self)
	print_string("匹配失败");
--	self.m_down_user_start_btn:setVisible(true);

	local message = "大侠，对手已闻风而逃，请重新匹配。"
	if self.mScene.m_match_dialog then
		self.mScene.m_match_dialog:dismiss();
	end

	if not self.mScene.m_chioce_dialog then
		self.mScene.m_chioce_dialog = new(ChioceDialog);
	end

	self.mScene.m_chioce_dialog:setMode(ChioceDialog.MODE_OK);
	self.mScene.m_chioce_dialog:setMessage(message);
	self.mScene.m_chioce_dialog:setPositiveListener(self,self.changeChessRoom);
	self.mScene.m_chioce_dialog:show();
end

--更新匹配动画里的弹窗
function OnlineModule.sendFllowCallback(self,info)
--    if self.mScene.m_match_dialog and self.mScene.m_match_dialog:isShowing() then
--        self.mScene.m_match_dialog:update(info);
--    end    
end