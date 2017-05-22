require(MODEL_PATH .. "online/onlineRoom/module/baseModule");

MoneyMatchModule = class(BaseModule);

function MoneyMatchModule.ctor(self,scene)
    BaseModule.ctor(self,scene);
    self.mShowWatchDialogBtn = new(Button,"common/button/start_nor.png", "common/button/start_press.png")
    local img = new(Image,"online/room/go_watch.png")
    img:setPos(0,-10)
    img:setAlign(kAlignCenter)
    self.mShowWatchDialogBtn:addChild(img)
    self.mShowWatchDialogBtn:setOnClick(self,self.showWaitDialog)
    self.mShowWatchDialogBtn:setAlign(kAlignCenter)
    self.mShowWatchDialogBtn:setVisible(false)
    self.mScene.m_board_view:addChild(self.mShowWatchDialogBtn)
    self.mMatchRoundBg = new(Image,"online/room/roundBg.png")
    self.mMatchRoundTxt = new(Image,"online/room/round_1.png")
    self.mMatchRoundTxt:setAlign(kAlignCenter)
    self.mMatchRoundBg:setAlign(kAlignCenter)
    self.mMatchRoundBg:addChild(self.mMatchRoundTxt)
    self.mScene.m_multiple_img_bg:addChild(self.mMatchRoundBg)
    self.mScene.m_room_watcher_btn:setVisible(false)
    self.mScene.m_multiple_text:setVisible(false)
    self.mScene.m_root_view:setVisible(false)
    if RoomProxy.getInstance():getTid() == 0 then
        self:showWaitPlayerDialog()
    end
	self.mScene.m_multiple_text:setText("金币赛");
end

function MoneyMatchModule.dtor(self)
	self.mScene.m_multiple_text:setText("");
    delete(self.mWaitPlayDialog)
    delete(self.mMoneyRoomAccountsDialog)
    delete(self.mMoneyRoomGameEndDialog)
    delete(self.mShowWatchDialogBtn)
    delete(self.mMatchRoundTxt)
    delete(self.mMatchRoundBg)
    delete(self.mFriendChoiceDialog)
    self.mScene.m_multiple_text:setVisible(true)
    self.mScene.m_room_watcher_btn:setVisible(true)
    self:dismissWaitPlayerDialog()
    self:stopCountDownTimer()
end

function MoneyMatchModule:onEventResume()
    if self.mScene:isGameOver() then
		print_string("Room.onHomeResume but gameover");
		return;
	end
    -- home 后异步同步数据
    self:setPlayerStatus(self.mPlayerStatus)
end

function MoneyMatchModule.onServerMsgGamestart(self)
    if self.mMoneyRoomGameEndDialog then
        self.mMoneyRoomGameEndDialog:dismiss()
    end
    if self.mMoneyRoomAccountsDialog then
        self.mMoneyRoomAccountsDialog:dismiss()
    end
    if self.mWaitPlayDialog then
        self.mWaitPlayDialog:dismiss()
    end
    if self.mFriendChoiceDialog then
        self.mFriendChoiceDialog:dismiss()
    end

	self.mScene:setEnableDraw(false);
	self.mScene:setEnableSurrender(false);
    self.mScene:setEnableUndo(false);
    self.mScene.isUndoAble = false
    self:stopCountDownTimer()
end

function MoneyMatchModule.setStatus(self,status)
    self.mScene.m_down_user_start_btn:setVisible(false);
	self.mScene:setEnableDraw(false);
	self.mScene:setEnableSurrender(false);
    self.mScene:setEnableUndo(false);
    self.mScene.isUndoAble = false
    if self.mScene.m_t_statuss == STATUS_TABLE_STOP then    
    elseif self.mScene.m_t_statuss == STATUS_TABLE_PLAYING then    --走棋状态
        if self.mMoneyRoomGameEndDialog then
            self.mMoneyRoomGameEndDialog:dismiss()
        end
        if self.mMoneyRoomAccountsDialog then
            self.mMoneyRoomAccountsDialog:dismiss()
        end
        if self.mWaitPlayDialog then
            self.mWaitPlayDialog:dismiss()
        end
        if self.mFriendChoiceDialog then
            self.mFriendChoiceDialog:dismiss()
        end
	elseif self.mScene.m_t_statuss == STATUS_TABLE_FORESTALL then  -- 抢先状态
	elseif self.mScene.m_t_statuss == STATUS_TABLE_HANDICAP then   -- 让子状态
	elseif self.mScene.m_t_statuss == STATUS_TABLE_RANGZI_CONFIRM then   -- 让子确认状态
	elseif self.mScene.m_t_statuss == STATUS_TABLE_SETTIME then    -- 设置局时状态
    elseif self.mScene.m_t_statuss == STATUS_TABLE_SETTIMERESPONE then
    end
end

MoneyMatchModule.s_playerStatus = {
    unknow      = 1;
    watch       = 2;
    play        = 3;
    wait        = 4;
    sign        = 5;
    gameOver    = 6;
    error       = 7;
    login       = 8;
    watchLogin  = 9;
}
function MoneyMatchModule.initGame(self)
    self.mScene.m_roomid:setVisible(false);
    self.mScene.m_multiple_img_bg:setVisible(true);--倍数
    self.mScene:downComeIn(UserInfo.getInstance());
    
    self.mMoneyRoomGameEndDialog = new(MoneyRoomGameEndDialog)
    if not self.mWaitPlayDialog then
        self.mWaitPlayDialog = new(MoneyRoomWaitDialog)
        self.mWaitPlayDialog:setSureBtnClick(self,self.signupMoneyMatchRoom);
	    self.mWaitPlayDialog:setCancelBtnClick(self,self.backAction);
        -- 这里先这样  太搓了 o(︶︿︶)o 唉
        self.mWaitPlayDialog:setLevel(100)
        self.mScene.m_root:addChild(self.mWaitPlayDialog)
    end
    if RoomProxy.getInstance():getTid() ~= 0 then
        self:setPlayerStatus(MoneyMatchModule.s_playerStatus.login)
    else
        self:signupMoneyMatchRoom()
    end

	UserInfo.getInstance():setRelogin(false)
end

function MoneyMatchModule.resetGame(self)
    self.mScene.m_chest_btn:setVisible(false);
end

function MoneyMatchModule.dismissDialog(self)
--    if self.mWaitPlayDialog then
--        self.mWaitPlayDialog:dismiss()
--    end
    
    if self.mFriendChoiceDialog then
        self.mFriendChoiceDialog:dismiss()
    end
--    self:dismissWaitPlayerDialog()
end

function MoneyMatchModule.readyAction(self)
    self.mScene.m_upuser_leave = false;
end

function MoneyMatchModule.backAction(self)
    local message = "亲，中途离开则会放弃比赛哦！"
	if not self.mScene.m_chioce_dialog then
		self.mScene.m_chioce_dialog = new(ChioceDialog);
	end
    if self.mPlayerStatus == MoneyMatchModule.s_playerStatus.sign then
        message = "退出后将取消报名,是否继续？"
        self.mScene.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE,"退出","取消");
        self.mScene.m_chioce_dialog:setPositiveListener(self,self.unSignupMoneyMatchRoom);
	    self.mScene.m_chioce_dialog:setMessage(message);
        self.mScene.m_chioce_dialog:setNegativeListener(self,function(self)
            OnlineRoomController.s_switch_func = nil
        end)
    elseif self.mPlayerStatus == MoneyMatchModule.s_playerStatus.watch then
        OnlineSocketManager.getHallInstance():sendMsg(MATCH_LEAVE_OB) 
        OnlineRoomController.s_switch_func = nil
        return 
    elseif self.mPlayerStatus == MoneyMatchModule.s_playerStatus.play or self.mPlayerStatus == MoneyMatchModule.s_playerStatus.wait then
        message = "比赛中途不能退出比赛!"
        self.mScene.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE,"确定","取消");
--        self.mScene.m_chioce_dialog:setPositiveListener(self,self.giveUpMoneyMatchRoom);
        OnlineRoomController.s_switch_func = nil
        self.mScene.m_chioce_dialog:setPositiveListener(nil,nil);
	    self.mScene.m_chioce_dialog:setMessage(message);
	    self.mScene.m_chioce_dialog:setNegativeListener(nil,nil);
    elseif self.mPlayerStatus == MoneyMatchModule.s_playerStatus.gameOver then
        self.mScene:exitRoom()
        return 
    elseif self.mPlayerStatus == MoneyMatchModule.s_playerStatus.unknow 
        or self.mPlayerStatus == MoneyMatchModule.s_playerStatus.login
        or self.mPlayerStatus == MoneyMatchModule.s_playerStatus.watchLogin then
        OnlineRoomController.s_switch_func = nil
        return
    elseif self.mPlayerStatus == MoneyMatchModule.s_playerStatus.error then
        self.mScene:exitRoom()
        return 
    end
	self.mScene.m_chioce_dialog:show();
end
require(DIALOG_PATH .. "moneyRoomWaitDialog")
function MoneyMatchModule:showWaitPlayerDialog(isJoinSuccess)
    local config = RoomProxy.getInstance():getCurRoomConfig()
    
    if not self.mWaitPlayDialog then
        self.mWaitPlayDialog = new(MoneyRoomWaitDialog)
        self.mWaitPlayDialog:setSureBtnClick(self,self.signupMoneyMatchRoom);
	    self.mWaitPlayDialog:setCancelBtnClick(self,self.backAction);
        self.mWaitPlayDialog:setLevel(100)
        self.mScene.m_root:addChild(self.mWaitPlayDialog)
    end
    
    local info = RoomProxy.getInstance():getMoneyMatchRoomInfo()

    if info then
        self.mWaitPlayDialog:setMatchLevel(info.level)
    end

    if isJoinSuccess then
        self.mWaitPlayDialog:joinChatRoom()
    end

    if config and config.sign_time then
        self.mWaitPlayDialog:countDown(config.sign_time*1000)
    end

    if self.mNeedWaitNum and self.mWaitNum then
        self.mWaitPlayDialog:setWaitNum(self.mWaitNum,self.mNeedWaitNum)
    end
    if not self.mWaitPlayDialog:isShowing() then
        self.mWaitPlayDialog:show()
    end
end

function MoneyMatchModule:dismissWaitPlayerDialog()
    if self.mWaitPlayDialog then
        self.mWaitPlayDialog:dismiss()
    end
end

function MoneyMatchModule:updateWaitNum(need,wait)
    self.mNeedWaitNum   = need or 0
    self.mWaitNum       = wait or 0
    if self.mWaitPlayDialog then
        self.mWaitPlayDialog:setWaitNum(self.mWaitNum,self.mNeedWaitNum)
    end
end

function MoneyMatchModule:unSignupMoneyMatchRoom()
    local info = RoomProxy.getInstance():getMoneyMatchRoomInfo()
    if not info then 
        if self.mWaitPlayDialog then self.mWaitPlayDialog:dismiss() end
        self.mScene:exitRoom()
        return 
    end
    OnlineSocketManager.getHallInstance():sendMsg(FASTMATCH_CANCLESIGNUP_REQUEST,info)
end

function MoneyMatchModule:giveUpMoneyMatchRoom()
    local info = {}
    OnlineSocketManager.getHallInstance():sendMsg(FASTMATCH_GIVE_UP,info)
end

function MoneyMatchModule:signupMoneyMatchRoom()
    local info = RoomProxy.getInstance():getMoneyMatchRoomInfo()
    if not info then 
        if self.mWaitPlayDialog then self.mWaitPlayDialog:dismiss() end
        self.mScene:exitRoom()
        return 
    end
    OnlineSocketManager.getHallInstance():sendMsg(FASTMATCH_SIGNUP_REQUEST,info)
    self:setPlayerStatus(MoneyMatchModule.s_playerStatus.unknow)
end


function MoneyMatchModule:onFastmatchSignupRequest(info)
    if info.result == 0 and info.error ~= 5 then
        local msg = "报名失败"
        if info.error == 1 then
            msg = "报名费用不足"
        elseif info.error == 2 then
            msg = "该比赛报名已关闭，比赛未开启"
        elseif info.error == 3 then
            msg = "玩家在其他场次有未结束棋局"
        elseif info.error == 4 then
            msg = "已经在比赛中"
        elseif info.error == 5 then
            msg = "已经报名过"
        end
        ChessToastManager.getInstance():showSingle(msg)
        self.mScene:exitRoom()
    else
        self:setPlayerStatus(MoneyMatchModule.s_playerStatus.sign)
        self:updateWaitNum(info.need,info.wait)
        self:showWaitPlayerDialog(true)
    end
end

function MoneyMatchModule:onFastmatchCanclesignupRequest(info)
    if info.result == 0 then
        local msg = "取消报名失败"
        if info.error == 1 then
            msg = "比赛已经开始"
        elseif info.error == 2 then
            msg = "玩家没有报名比赛"
            self.mScene:exitRoom()
            return
        end
        ChessToastManager.getInstance():showSingle(msg)
        return 
    end
    if self.mGotoFriendChallengerPackageInfo then
        RoomProxy.getInstance():setTid(self.mGotoFriendChallengerPackageInfo.tid);
        UserInfo.getInstance():setChallenger(false);
        self.mScene:changeRoomType(RoomConfig.ROOM_TYPE_FRIEND_ROOM)
        local post_data = {};
        post_data.uid = UserInfo.getInstance():getUid();
        post_data.target_uid = self.mGotoFriendChallengerPackageInfo.uid;
        post_data.ret = 0;
        OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_FRIEND_INVIT_RESPONSE2,post_data,nil,1);
    else
        self.mScene:exitRoom()
    end
end

function MoneyMatchModule:onFastmatchGiveUp(info)
    if info.flag == 1 then
        self:setPlayerStatus(MoneyMatchModule.s_playerStatus.gameOver)
        if not self.mScene.m_upUser then
            self.mScene:exitRoom()
        end
    else
        ChessToastManager.getInstance():showSingle("放弃比赛失败")
    end
end


function MoneyMatchModule:onFastmatchSignupCountNotify(info)
    self:updateWaitNum(info.need,info.wait)
end

function MoneyMatchModule:onFastmatchDropoutNotify(info)
    self:updateWaitNum(info.need,info.wait)
    self.mWaitPlayDialog:setBtnVisible(true)
end

function MoneyMatchModule:onFastmatchEnterroomNotify(info)
--    ChessToastManager.getInstance():showSingle("比赛即将开始请做好准备",5000)
    RoomProxy.getInstance():setMatchId(info.matchId)
    RoomProxy.getInstance():setTid(info.tid)
    self:setPlayerStatus(MoneyMatchModule.s_playerStatus.login)
    self:dismissWaitPlayerDialog()
    if self.mFriendChoiceDialog then
        self.mFriendChoiceDialog:dismiss()
    end
    self:startCountDownTimer(info.time)
end

function MoneyMatchModule:onFastmatchEnterNextroomNotify(info)
    RoomProxy.getInstance():setMatchId(info.matchId)
    RoomProxy.getInstance():setTid(info.tid)
    self:setPlayerStatus(MoneyMatchModule.s_playerStatus.play)
    self:dismissWaitPlayerDialog()
    if self.mFriendChoiceDialog then
        self.mFriendChoiceDialog:dismiss()
    end
    if self.mMoneyRoomGameEndDialog:isShowing() then
--        ChessToastManager.getInstance():showSingle("比赛已开始请做好准备",5000)
        self.mMoneyRoomGameEndDialog:setOnSureClick(self,function()end)
        self.mMoneyRoomGameEndDialog:dismiss()
    end
    self:startCountDownTimer(info.time)
end

require(DIALOG_PATH .. "moneyRoomAccountsDialog")
require(DIALOG_PATH .. "moneyRoomGameEndDialog")

function MoneyMatchModule:onFastmatchRoundover(info)
    self.mScene:saveChess();
    if self.mScene.m_upUser then
        local time = (info.winnerID == self.mScene.m_upUser:getUid() and info.winnerUseTime) or info.loserUseTime
        self.mMoneyRoomGameEndDialog:setUpUser(self.mScene.m_upUser,time,info.winnerID)
    end
    
    if self.mScene.m_downUser then
        local time = (info.loserID == self.mScene.m_downUser:getUid() and info.loserUseTime) or info.winnerUseTime
        self.mMoneyRoomGameEndDialog:setDownUser(self.mScene.m_downUser,time,info.winnerID)
    end

    if self.mScene.m_board then
        local chess_map = self.mScene.m_board:to_chess_map()
	    local model = Board.MODE_BLACK;
	    if self.mScene.m_downUser and (self.mScene.m_downUser:getFlag() == FLAG_RED) then
		    model = Board.MODE_RED;
        end
        self.mMoneyRoomGameEndDialog:setContentView(chess_map,model)
    end

    self.mPrize = false
    local gameOver = false
    local wintimes = UserInfo.getInstance():getWintimes()
    local losetimes = UserInfo.getInstance():getLosetimes()
    if info.finals == 1 then
        gameOver = true
        self.mPrize = true
        if not self.mMoneyRoomAccountsDialog then
            self.mMoneyRoomAccountsDialog = new(MoneyRoomAccountsDialog)
        end
        local roomLevel = RoomProxy.getInstance():getCurRoomLevel()
        local config    = RoomConfig.getInstance():getRoomLevelConfig(roomLevel)
        local prize     
        if config then
            prize = RoomConfig.analysisPrize(config.prize)
        end
        local msg = ""
        if info.winnerID == UserInfo.getInstance():getUid() then
            UserInfo.getInstance():setWintimes(wintimes + 1)
            self.mMoneyRoomAccountsDialog:setRank(1)
            if type(prize) == "table" and type(prize[1]) == "table" then
                if tonumber(prize[1].money) then
                    msg = msg .. string.format("+ %s 金币",ToolKit.skipMoney(tonumber(prize[1].money)))
                end
                if tonumber(prize[1].soul) then
                    msg = msg .. string.format("#l+ %s 棋魂",ToolKit.skipMoney(tonumber(prize[1].soul)))
                end
            end
            self.mMoneyRoomGameEndDialog:setWinView()
        elseif info.loserID == UserInfo.getInstance():getUid() then
            UserInfo.getInstance():setLosetimes(losetimes + 1)
            self.mMoneyRoomAccountsDialog:setRank(2)
            if type(prize) == "table" and type(prize[2]) == "table" then
                if tonumber(prize[2].money) then
                    msg = msg .. string.format("+ %s 金币",ToolKit.skipMoney(tonumber(prize[2].money)))
                end
                if tonumber(prize[2].soul) then
                    msg = msg .. string.format("#l+ %s 棋魂",ToolKit.skipMoney(tonumber(prize[2].soul)))
                end
            end
            self.mMoneyRoomGameEndDialog:setLoseView()
        end
        self.mMoneyRoomAccountsDialog:setReward(msg)
    elseif info.finals == 0 then
        if info.winnerID == UserInfo.getInstance():getUid() then
            ChessToastManager.getInstance():showSingle("恭喜获得本轮比赛胜利,请等待下轮比赛开始")
            UserInfo.getInstance():setWintimes(wintimes + 1)
            self.mMoneyRoomGameEndDialog:setWinView()
        elseif info.loserID == UserInfo.getInstance():getUid() then
            ChessToastManager.getInstance():showSingle("很遗憾你在本轮比赛中失利,快去参加下一场比赛吧")
            UserInfo.getInstance():setLosetimes(losetimes + 1)
            gameOver = true
            self.mMoneyRoomGameEndDialog:setLoseView()
        end
    else
        gameOver = true
    end
    
    self.mFinals = info.finals
    self.mPlayEndAnim = true
    if gameOver then
        self:setPlayerStatus(MoneyMatchModule.s_playerStatus.gameOver)
        self.mMoneyRoomGameEndDialog:setOnSureClick(self,self.backAction)
    else
        self.mMoneyRoomGameEndDialog:setOnSureClick(self,self.showWaitDialog)
        self:setPlayerStatus(MoneyMatchModule.s_playerStatus.wait)
    end

    self.mScene:gameClose(info.win_flag,info.endtype);
	OnlineConfig.deleteTimer(self); 
    
    if type(OnlineRoomController.s_switch_func) == "function" then
        self:giveUpMoneyMatchRoom()
        return 
    end
end

--显示棋局结算窗口
MoneyMatchModule.showAccount = function(self)
    if self.mPlayerStatus == MoneyMatchModule.s_playerStatus.gameOver or
        self.mPlayerStatus == MoneyMatchModule.s_playerStatus.wait then
        self.mMoneyRoomGameEndDialog:show()
        if self.mFinals == 1 then
            self.mMoneyRoomAccountsDialog:show()
        end
    end

    if self.mPlayerStatus == MoneyMatchModule.s_playerStatus.gameOver then
        self.mScene:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_logout)
    end

    self.mPlayEndAnim = false
    self:setPlayerStatus(self.mPlayerStatus,true)
end

require(DIALOG_PATH .. "moneyRoomRankDialog")
function MoneyMatchModule:showWaitDialog()
    if not self.mWaitDialog then 
        self.mWaitDialog = new(MoneyRoomRankDialog)
        self.mWaitDialog:setGotoWatchRoomFunc(self,self.gotoWatchRoom)
    end
    self.mWaitDialog:show()
end

function MoneyMatchModule:gotoWatchRoom(tid)
    if tid and tid > 0 then
        RoomProxy.getInstance():setTid(tid)
        self:setPlayerStatus(MoneyMatchModule.s_playerStatus.watchLogin)
    else
        ChessToastManager.getInstance():showSingle("观战id错误")
    end
end

function MoneyMatchModule:onMatchEnterObserveTable(info)
    RoomProxy.getInstance():setTid(info.tid)
    local status = info.status
    if status == 1 then
        self:setPlayerStatus(MoneyMatchModule.s_playerStatus.play)
    elseif status == 2 then
        self:setPlayerStatus(MoneyMatchModule.s_playerStatus.wait)
    elseif status == 3 then
        self:setPlayerStatus(MoneyMatchModule.s_playerStatus.watch)
    else
        self:setPlayerStatus(MoneyMatchModule.s_playerStatus.error)
    end
end

function MoneyMatchModule:onHallMsgLogin(info)
    self:dismissWaitPlayerDialog()
    RoomProxy.getInstance():setTid(info.tid)
    if info.tid == 0 then
        if info.matchLevel > 0 then
            local params = {}
            params.level = info.matchLevel
            -- 这里步会跳转界面  因为是同样的state
            RoomProxy.getInstance():gotoMoneyMatchRoom(params)
            OnlineSocketManager.getHallInstance():sendMsg(FASTMATCH_SIGNUP_REQUEST,params)
            self:setPlayerStatus(MoneyMatchModule.s_playerStatus.unknow)
        else
            if self.mPlayerStatus == MoneyMatchModule.s_playerStatus.sign then
                if not self.mWaitPlayDialog then
                    self.mWaitPlayDialog = new(MoneyRoomWaitDialog)
                    self.mWaitPlayDialog:setSureBtnClick(self,self.signupMoneyMatchRoom);
	                self.mWaitPlayDialog:setCancelBtnClick(self,self.backAction);
                    self.mWaitPlayDialog:setLevel(100)
                    self.mScene.m_root:addChild(self.mWaitPlayDialog)
                end
                
                local info = RoomProxy.getInstance():getMoneyMatchRoomInfo()

                if info then
                    self.mWaitPlayDialog:setMatchLevel(info.level)
                end

                self.mWaitPlayDialog:setBtnVisible(true)
                if not self.mWaitPlayDialog:isShowing() then
                    self.mWaitPlayDialog:show()
                end
            else
                ChessToastManager.getInstance():showSingle("你的比赛已结束")
                self:setPlayerStatus(MoneyMatchModule.s_playerStatus.gameOver)
                self:stopCountDownTimer()
                self:backAction()
            end
        end
    else
        self:setPlayerStatus(MoneyMatchModule.s_playerStatus.login)
        self:dismissWaitPlayerDialog()
    end
end

function MoneyMatchModule:onServerMsgLogoutSucc()
    self.mScene:clearRoomInfo();
    self:setPlayerStatus(MoneyMatchModule.s_playerStatus.gameOver)
end

--更新关注的弹窗
function MoneyMatchModule.sendFllowCallback(self,info)
end

function MoneyMatchModule:onMatchGetmatchinfo(info)
    if self.mWaitDialog then
        self.mWaitDialog:updateView(info)
    end
end

function MoneyMatchModule:onMatchGetRoundIndex(info)
    self.mMatchRoundNum = info.round_index
    if self.mMatchRoundNum then
        self.mMatchRoundTxt:setFile( string.format("online/room/round_%d.png",self.mMatchRoundNum))
    end
end

function MoneyMatchModule:onMatchPlayerChangeState(info)
    RoomProxy.getInstance():setTid(info.tid)
    local status = info.status
    if status == 1 then
        self:setPlayerStatus(MoneyMatchModule.s_playerStatus.play)
    elseif status == 2 then
        self:setPlayerStatus(MoneyMatchModule.s_playerStatus.wait)
    elseif status == 3 then
        self:setPlayerStatus(MoneyMatchModule.s_playerStatus.watchLogin)
    else
        self:setPlayerStatus(MoneyMatchModule.s_playerStatus.error)
    end
end

function MoneyMatchModule:onMatchLeaveOb(info)
    RoomProxy.getInstance():setTid(info.tid)
    local status = info.status
    if status == 1 then
        self:setPlayerStatus(MoneyMatchModule.s_playerStatus.play)
    elseif status == 2 then
        self:setPlayerStatus(MoneyMatchModule.s_playerStatus.wait)
    elseif status == 3 then
        self:setPlayerStatus(MoneyMatchModule.s_playerStatus.watchLogin)
    else
        self:setPlayerStatus(MoneyMatchModule.s_playerStatus.error)
    end
end

function MoneyMatchModule:getPlayerStatus()
    return self.mPlayerStatus
end

function MoneyMatchModule:setPlayerStatus(status,clear)
    -- clear
	self.mScene:stopTimeout(); --停止游戏计时
    local needClear = false
    if status ~= self.mPlayerStatus then
        if status == MoneyMatchModule.s_playerStatus.play
            or status == MoneyMatchModule.s_playerStatus.watch 
            or status == MoneyMatchModule.s_playerStatus.wait then
            needClear = true
        end
    end

    if self.mPlayEndAnim then
        self.mPlayerStatus = status
        return 
    end

    if needClear or clear then
        self.mScene:onResetGame()
    end

    -- change
    self.mShowWatchDialogBtn:setVisible(false)
    OnlineSocketManager.getHallInstance():sendMsg(MATCH_GET_ROUND_INDEX,{})
    if status == MoneyMatchModule.s_playerStatus.watch then
        self.mScene.m_board:setPickable(false)
        OnlineSocketManager.getHallInstance():sendMsg(MATCH_GETOBTABLEINFO) -- 选手
        if self.mWaitDialog then
            self.mWaitDialog:dismiss()
        end
    elseif status == MoneyMatchModule.s_playerStatus.watchLogin then
        OnlineSocketManager.getHallInstance():sendMsg(MATCH_ENTER_OBSERVE_TABLE_REQUEST) -- 选手
    elseif status == MoneyMatchModule.s_playerStatus.login then
        OnlineSocketManager.getHallInstance():sendMsg(FASTMATCH_LOGINROOM_REQUEST,0) -- 选手
        self.mScene:downComeIn(UserInfo.getInstance())
    elseif status == MoneyMatchModule.s_playerStatus.play then
        OnlineSocketManager.getHallInstance():sendMsg(MATCH_GETTABLEINFO) -- 选手
        if self.mWaitDialog then
            self.mWaitDialog:dismiss()
        end
        self.mScene:downComeIn(UserInfo.getInstance())
        self.mScene.m_board:setPickable(true)
    elseif status == MoneyMatchModule.s_playerStatus.wait then
        OnlineSocketManager.getHallInstance():sendMsg(MATCH_GETTABLEINFO) -- 选手
        self.mScene:downComeIn(UserInfo.getInstance())
        self.mShowWatchDialogBtn:setVisible(true)
    elseif status == MoneyMatchModule.s_playerStatus.sign then
        self.mScene:downComeIn(UserInfo.getInstance())
    elseif status == MoneyMatchModule.s_playerStatus.gameOver then
        self.mScene:downComeIn(UserInfo.getInstance())
    elseif status == MoneyMatchModule.s_playerStatus.error then
        self.mScene:downComeIn(UserInfo.getInstance())
    elseif status == MoneyMatchModule.s_playerStatus.unknow then
    
    end
    self.mPlayerStatus = status
end

--[Comment]
--int matchId   //比赛ID
--int status  //状态
--//status =1：代表比赛对战中   
--//status =2：代表比赛等待中
--//status =3: 代表比赛观战中
function MoneyMatchModule:onMatchLoginSuc(info)
    RoomProxy.getInstance():setMatchId(info.matchId)
    RoomProxy.getInstance():setTid(info.tid)
    local status = info.status
    if status == 1 then
        self:setPlayerStatus(MoneyMatchModule.s_playerStatus.play)
    elseif status == 2 then
        self:setPlayerStatus(MoneyMatchModule.s_playerStatus.wait)
    elseif status == 3 then
        self:setPlayerStatus(MoneyMatchModule.s_playerStatus.watchLogin)
    else
        self:setPlayerStatus(MoneyMatchModule.s_playerStatus.error)
    end
end

-- 观战模式
function MoneyMatchModule.onWatchRoomMove(self, data)
    if self.mPlayerStatus ~= MoneyMatchModule.s_playerStatus.watch or not data then return end;
    if self.mScene.m_downUser and data.last_move_uid == self.mScene.m_downUser:getUid() then
        if self.mScene.m_downUser:getFlag() == FLAG_RED then
		    self.mScene.m_downUser:setTimeout1((self.mScene.m_timeout1 - data.red_timeout));
            self.mScene.m_upUser:setTimeout1(self.mScene.m_timeout1 - data.black_timeout);
            self.mScene.m_move_flag = FLAG_BLACK;--此函数内接收的是已经走完的棋，所以将要走的棋标志置反。
        else
            self.mScene.m_downUser:setTimeout1((self.mScene.m_timeout1 - data.black_timeout));
            self.mScene.m_upUser:setTimeout1(self.mScene.m_timeout1 - data.red_timeout);
            self.mScene.m_move_flag = FLAG_RED;
        end;
		self.mScene.m_downUser:setTimeout2(self.mScene.m_timeout2);
		self.mScene.m_downUser:setTimeout3(self.mScene.m_timeout3);
    elseif self.mScene.m_upUser and data.last_move_uid == self.mScene.m_upUser:getUid() then
        if self.mScene.m_upUser:getFlag() == FLAG_RED then
		    self.mScene.m_upUser:setTimeout1((self.mScene.m_timeout1 - data.red_timeout));
            self.mScene.m_downUser:setTimeout1(self.mScene.m_timeout1 - data.black_timeout);
            self.mScene.m_move_flag = FLAG_BLACK;
        else
            self.mScene.m_upUser:setTimeout1((self.mScene.m_timeout1 - data.black_timeout));
            self.mScene.m_downUser:setTimeout1(self.mScene.m_timeout1 - data.red_timeout);
            self.mScene.m_move_flag = FLAG_RED;
        end;
		self.mScene.m_upUser:setTimeout2(self.mScene.m_timeout2);
		self.mScene.m_upUser:setTimeout3(self.mScene.m_timeout3);
    end;
    self.mScene:setStatus(data.status);
    if data.ob_num then
     	local str = string.format("%d",data.ob_num);
--	    self.m_room_watcher:setText(str);   
    end;

    local mv = {}
	mv.moveChess = data.chessMan;
	mv.moveFrom = data.position1;
	mv.moveTo = data.position2;
	self.mScene:resPonseMove(mv);
end


function MoneyMatchModule.onUpdateWatchRoom(self, data, message)
    if self.mPlayerStatus ~= MoneyMatchModule.s_playerStatus.watch or not data then return end;
    local player1 = data.player1;
    local player2 = data.player2;
    if player1 then
        if player1:getFlag() == 1 then
            self.mScene:downComeIn(player1);
        else
            self.mScene:upComeIn(player1);
        end
    end
    if player2 then
        if player2:getFlag() == 1 then
            self.mScene:downComeIn(player2);
        else
            self.mScene:upComeIn(player2);
        end
    end
    if not player1 and not player2 then
        self:onWatchRoomUserLeave();
        return;
    end
    self.mScene.m_timeout1 = data.round_time;
	self.mScene.m_timeout2 = data.step_time;
	self.mScene.m_timeout3 = data.sec_time;
    if player1 and data.curr_move_flag == player1:getUid() then
        self.mScene.m_move_flag = player1:getFlag();
    elseif player2 and data.curr_move_flag == player2:getUid() then
        self.mScene.m_move_flag = player2:getFlag();
    end
    if self.mScene.m_move_flag == FLAG_RED then
        self.mScene.m_red_turn = true;
    else
        self.mScene.m_red_turn = false;
    end;
    if data.status == 2 then--只有在状态2（playing）才有下面信息
        self.mScene:setStatus(data.status);
        local last_move = {}
	    last_move.moveChess = data.chessMan;
	    last_move.moveFrom = 91 -data.position1;
	    last_move.moveTo = 91 - data.position2;
	    self.mScene:synchroData(data.chess_map,last_move);
    else
        self.mScene:setStatus(data.status);
--        ShowMessageAnim.play(self.m_root_view,"等待开局");
        local message =  "等待开局"; 
        ChessToastManager.getInstance():showSingle(message);   
    end
end

function MoneyMatchModule.onWatchRoomUserLeave(self, data)
    if self.mPlayerStatus ~= MoneyMatchModule.s_playerStatus.watch or not data then return end
    local leaveUid = data.leave_uid;
    self.mScene:stopTimeout();

	self.mScene:clearDialog();
    if self.mScene.m_downUser then
	    if self.mScene.m_downUser:getUid() == leaveUid then
            self.mScene:downGetOut();
	    else
            self.mScene:upGetOut();
	    end
    end
end

function MoneyMatchModule.onWatchRoomStart(self, data)
    if self.mPlayerStatus ~= MoneyMatchModule.s_playerStatus.watch or not data then return end
    self.mScene.m_timeout1 = data.round_time;
	self.mScene.m_timeout2 = data.step_time;
	self.mScene.m_timeout3 = data.sec_time;
	
	self.mScene.m_downUser:setTimeout1(data.round_time);
	self.mScene.m_downUser:setTimeout2(data.step_time);
	self.mScene.m_downUser:setTimeout3(data.sec_time);

	self.mScene.m_upUser:setTimeout1(data.round_time);
	self.mScene.m_upUser:setTimeout2(data.step_time);
	self.mScene.m_upUser:setTimeout3(data.sec_time);

	if self.mScene.m_downUser:getUid() == data.red_uid then
		self.mScene.m_downUser:setFlag(FLAG_RED);
		if self.mScene.m_upUser then
			self.mScene.m_upUser:setFlag(FLAG_BLACK);
		end
	else
		self.mScene.m_downUser:setFlag(FLAG_BLACK);
		if self.mScene.m_upUser then
			self.mScene.m_upUser:setFlag(FLAG_RED);
		end
	end

    local player1 = self.mScene.m_downUser;
    local player2 = self.mScene.m_upUser;

    if player1 then
        if player1:getFlag() == 1 then
            self.mScene:downComeIn(player1);
        else
            self.mScene:upComeIn(player1);
        end
    end

    if player2 then
        if player2:getFlag() == 1 then
            self.mScene:downComeIn(player2);
        else
            self.mScene:upComeIn(player2);
        end
    end

    self.mScene.m_move_flag = FLAG_RED;
    self.mScene.m_red_turn = true;
    self.mScene:setStatus(data.status);
	self.mScene:startGame(data.chess_map);
end

function MoneyMatchModule.onWatchRoomClose(self, data)
    if self.mPlayerStatus ~= MoneyMatchModule.s_playerStatus.watch or not data then return end;
	self:setWatchUsersInfo(data);
    self.mScene:setStatus(data.status);
	self.mScene:gameClose(data.win_flag,data.end_type);   
	OnlineConfig.deleteTimer(self);  
end


function MoneyMatchModule:startCountDownTimer(time)
    if not self.mCountDownTimerDialog then
		self.mCountDownTimerDialog = new(LoadingDialog);
    end
	self.mCountDownTimerDialog:setMessage("比赛即将开始");
	self.mCountDownTimerDialog:show(time);
end

function MoneyMatchModule:stopCountDownTimer()
    if self.mCountDownTimerDialog then
	    self.mCountDownTimerDialog:dismiss()
    end
end

--挑战邀请通知
function MoneyMatchModule:onInvitNotify(packageInfo)
    if self.mPlayerStatus ~= MoneyMatchModule.s_playerStatus.sign then return end

    local money = UserInfo.getInstance():getMoney();
    local isCanAccess = RoomProxy.getInstance():canAccessRoom(RoomConfig.ROOM_TYPE_FRIEND_ROOM,money);
    if not isCanAccess then
        ChessToastManager.getInstance():showSingle( string.format("用户ID:%d向你发起挑战,由于你的金币不足,无法接受挑战!",packageInfo.uid),3000);
        return;
    end

    local friendData = FriendsData.getInstance():getUserData(packageInfo.uid);

    if not self.mFriendChoiceDialog then
        self.mFriendChoiceDialog = new(FriendChoiceDialog);
    end
    self.mFriendChoiceDialog:setMode(1,friendData,packageInfo);
    self.mFriendChoiceDialog:setPositiveListener(self,
        function()
            self.mGotoFriendChallengerPackageInfo = packageInfo
            self:unSignupMoneyMatchRoom()
        end);
    self.mFriendChoiceDialog:setNegativeListener(self,
        function()
            local post_data = {};
            post_data.uid = UserInfo.getInstance():getUid();
            post_data.target_uid = packageInfo.uid;
            post_data.ret = 1;
            OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_FRIEND_INVIT_RESPONSE2,post_data,nil,1);   
        end);
    self.mFriendChoiceDialog:show();
end