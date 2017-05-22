require(MODEL_PATH .. "online/onlineRoom/module/baseModule");
require(DIALOG_PATH .. "matchVsDialog")
require(DIALOG_PATH .. "match_dialog_2")
require(DIALOG_PATH .. "matchRankDialog")
require(DIALOG_PATH .. "matchResultDialog")
require(DIALOG_PATH .. "resurrectionDialog")
require(VIEW_PATH .. "match_room_view_rank");
require(DIALOG_PATH .. "matchInteractionInfoDialog")
require(DIALOG_PATH .. "matchWatchResultDialog")
require(DIALOG_PATH .. "matchEndDialog")
require(DIALOG_PATH .. "matchEndRankDialog")
MetierMatchModule = class(BaseModule);

function MetierMatchModule.ctor(self,scene)
    BaseModule.ctor(self,scene);
    self.mRoomRank = SceneLoader.load(match_room_view_rank)
    self.mRoomRank:getChildByName("touch_btn"):setOnClick(self,self.showRankDialog)
    self.mRankText = self.mRoomRank:getChildByName("rank_num")
    self.mScene.m_root_view:addChild(self.mRoomRank)
    self.mRoomRank:setAlign(kAlignBottomLeft)
    self.mRoomRank:setPos(150,50)
    self.mMatchBtn = new(Button,"online/room/start_btn_press.png","online/room/start_btn_nor.png")
    self.mMatchBtn:setOnClick(self,function()
        if self.mPlayerStatus == MetierMatchModule.s_playerStatus.idle then
            self:setPlayerStatus(MetierMatchModule.s_playerStatus.idle)
        end
        self.mMatchBtn:setVisible(false)
    end)
    self.mMatchBtn:setAlign(kAlignCenter)
    self.mScene.m_board_view:addChild(self.mMatchBtn)
    self.mMatchTxt = new(Image,"online/room/dialog/match_text.png")
    self.mMatchTxt:setAlign(kAlignCenter)
    self.mMatchTxt:setPos(0,-50)
    self.mScene.m_board_view:addChild(self.mMatchTxt)
    self.mIsMatchOver = false
    self.mUpUserMatchScoreTxt = new(Text,"", width, height, kAlignCenter, fontName, 24, 60, 225, 100)
    self.mUpUserMatchScoreTxt:setAlign(kAlignTop)
    local w,h = self.mUpUserMatchScoreTxt:getSize()
    self.mUpUserMatchScoreTxt:setPos(0,-h+10)
    self.mScene.m_up_view1:addChild(self.mUpUserMatchScoreTxt)
    
    self.mDownUserMatchScoreTxt = new(Text,"", width, height, kAlignCenter, fontName, 24, 60, 225, 100)
    self.mDownUserMatchScoreTxt:setAlign(kAlignBottom)
    local w,h = self.mDownUserMatchScoreTxt:getSize()
    self.mDownUserMatchScoreTxt:setPos(0,-h-20)
    self.mScene.m_down_view1:addChild(self.mDownUserMatchScoreTxt)

    if RoomProxy.getInstance():isMatchWatcher() then
        self:changeWatchMode()
    else
        self:changePlayMode()
    end
    self.mScene.m_multiple_img_bg:setVisible(false)
    self.mScene.m_chest_btn:setVisible(false)
    self.mScene.m_down_view1.money_btn:setVisible(false)
    self.mScene.m_roomid:setVisible(false)
    self.mScene.m_thansize_btn:setVisible(false)
    self.mTableIsPlaying = false
	self.mScene.m_multiple_text:setText("赏金赛");
end

function MetierMatchModule.dtor(self)
	self.mScene.m_multiple_text:setText("");
    -- 回滚原始
    self:changePlayMode() 
    self.mScene.m_room_watcher_btn:setOnClick(self.mScene,self.mScene.gotoWatchList);
    self.mScene.m_multiple_img_bg:setVisible(true)
    self.mScene.m_chest_btn:setVisible(true)
    self.mScene.m_down_view1.money_btn:setVisible(true)
    self.mScene.m_roomid:setVisible(true)
    self.mScene.m_thansize_btn:setVisible(true)
    self:stopRefreshRank()
    self:stopCountDownTimer()
    delete(self.mResultDialog)
    delete(self.mMatchWatcherResultDialog)
    delete(self.mMatchDialog2)
    delete(self.mVsDialog)
    delete(self.mRoomRank)
    delete(self.mCountDownTimerDialog)
    delete(self.mFriendChoiceDialog)
    delete(self.mResurrectionDialog)
    delete(self.mRankDialog)
    delete(self.mMatchEndDialog)
    delete(self.mMatchBtn)
    delete(self.mMatchTxt)
    delete(self.mUpUserMatchScoreTxt)
    delete(self.mDownUserMatchScoreTxt)
    self.mScene:setIsWatchGiftAnim(false)
end

function MetierMatchModule:onEventResume()
    if self.mScene:isGameOver() then
		print_string("Room.onHomeResume but gameover");
		return;
	end
    -- home 后异步同步数据
    self:setPlayerStatus(self.mPlayerStatus)
end

function MetierMatchModule.onServerMsgGamestart(self)
end

function MetierMatchModule.setStatus(self,status)
    self.mScene.m_down_user_start_btn:setVisible(false);
	self.mScene:setEnableDraw(false);
--	self.mScene:setEnableSurrender(false);
    self.mScene:setEnableUndo(false);
    self.mScene.isUndoAble = false
    local dialog = self:getResultDialog()
    if self.mScene.m_t_statuss == STATUS_TABLE_STOP then    
	elseif self.mScene.m_t_statuss == STATUS_TABLE_PLAYING then  -- 正在下棋
        self:stopCountDownTimer()
        if self.mVsDialog and self.mVsDialog:isShowing() and self.mPlayIdentity ~= 2 then
            self.mVsDialog:dismiss()
        end
        self.mTableIsPlaying = true
	elseif self.mScene.m_t_statuss == STATUS_TABLE_FORESTALL then  -- 抢先状态
	elseif self.mScene.m_t_statuss == STATUS_TABLE_HANDICAP then   -- 让子状态
	elseif self.mScene.m_t_statuss == STATUS_TABLE_RANGZI_CONFIRM then   -- 让子确认状态
	elseif self.mScene.m_t_statuss == STATUS_TABLE_SETTIME then    -- 设置局时状态
    elseif self.mScene.m_t_statuss == STATUS_TABLE_SETTIMERESPONE then
    end
end

MetierMatchModule.s_playerMode = {
    play  = 0,
    watch = 1,
}

MetierMatchModule.s_playerStatus = {
    loginMatching   = -1,
    registered      = 1,
    -- 匹配
    matching        = 2,
    playing         = 3,
    eliminate       = 4,
    idle            = 5,
}
function MetierMatchModule.initGame(self)
    if RoomProxy.getInstance():isMatchWatcher() then
        self:changeWatchMode()
        self:setPlayerStatus(MetierMatchModule.s_playerStatus.playing)
    else
        self:changePlayMode()
        self:setPlayerStatus(MetierMatchModule.s_playerStatus.loginMatching)
    end
    self.mScene.m_multiple_img_bg:setVisible(false)
    self.mScene.m_chest_btn:setVisible(false)
    self.mScene.m_down_view1.money_btn:setVisible(false)
    self.mScene.m_roomid:setVisible(false)
    HttpModule.getInstance():execute(HttpModule.s_cmds.getMatchList)
end

function MetierMatchModule.resetGame(self)
end

function MetierMatchModule.dismissDialog(self)
    self:dismissRankDialog()
    self:getInteractionRankDialog():dismiss()
end

function MetierMatchModule.readyAction(self)
end

function MetierMatchModule.backAction(self)
    if self.mPlayerMode == MetierMatchModule.s_playerMode.watch or (self.mIsMatchOver and self.mPlayerStatus ~= MetierMatchModule.s_playerStatus.playing) then
        self:onServerMsgLogoutSucc()
        self.mScene:exitRoom()
        return
    end
    local message = "亲，中途离开则会放弃比赛哦！"
	if not self.mScene.m_chioce_dialog then
		self.mScene.m_chioce_dialog = new(ChioceDialog);
	end
    self.mScene.m_chioce_dialog:setMode(ChioceDialog.MODE_OTHER)
    self.mScene.m_chioce_dialog:setPositiveListener(nil,nil);
	self.mScene.m_chioce_dialog:setNegativeListener(nil,nil);

    if self.mPlayerStatus == MetierMatchModule.s_playerStatus.loginMatching then
        message = "正在登录比赛中"
        OnlineRoomController.s_switch_func = nil
    elseif self.mPlayerStatus == MetierMatchModule.s_playerStatus.matching then
        message = "匹配中,现在退出将直接放弃比赛并清空当前生命值，您将不会获得任何奖励，是否继续？"
        self.mScene.m_chioce_dialog:setMode(ChioceDialog.MODE_COMMON,"继续退出","关闭")
        self.mScene.m_chioce_dialog:setPositiveListener(self,function()
            OnlineSocketManager.getHallInstance():sendMsg(GIVE_UP_THE_MATCH,{})
            self.mScene:exitRoom()
        end);
        self.mScene.m_chioce_dialog:setNegativeListener(self,function(self)
            OnlineRoomController.s_switch_func = nil
        end)
    elseif self.mPlayerStatus == MetierMatchModule.s_playerStatus.registered then
        ChessToastManager.getInstance():showSingle("比赛房间状态错误，请稍后再试！")
        self.mScene:exitRoom()
        return
    elseif self.mPlayerStatus == MetierMatchModule.s_playerStatus.playing then
        message = "是否认输"
        self.mScene.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE,"认输","取消");
        self.mScene.m_chioce_dialog:setPositiveListener(self,function()
           if not self.mScene:checkCanSurrender() then OnlineRoomController.s_switch_func = nil return end
           self.mScene:surrender_sure()
        end);
        self.mScene.m_chioce_dialog:setNegativeListener(self,function(self)
            OnlineRoomController.s_switch_func = nil
        end)
    elseif self.mPlayerStatus == MetierMatchModule.s_playerStatus.eliminate then
        OnlineSocketManager.getHallInstance():sendMsg(GIVE_UP_THE_MATCH,{})
        self.mScene:exitRoom()
        return 
    elseif self.mPlayerStatus == MetierMatchModule.s_playerStatus.idle then
        message = "现在退出将直接放弃比赛并清空当前生命值，您将不会获得任何奖励，是否继续？"
        self.mScene.m_chioce_dialog:setMode(ChioceDialog.MODE_COMMON,"继续退出","关闭")
        self.mScene.m_chioce_dialog:setPositiveListener(self,function()
            OnlineSocketManager.getHallInstance():sendMsg(GIVE_UP_THE_MATCH,{})
            self.mScene:exitRoom()
        end);
        self.mScene.m_chioce_dialog:setNegativeListener(self,function(self)
            OnlineRoomController.s_switch_func = nil
        end)
    end
    
	self.mScene.m_chioce_dialog:setMessage(message);
	self.mScene.m_chioce_dialog:show();
end

--[Comment]
-- 棋局结束
function MetierMatchModule:onMetierResultMsg(info)
    self.mScene:saveChess();
    local resultDialog = self:getResultDialog()
    resultDialog:setMatchId(info.matchId)
    local myRank = 0
    -- flag == 0和棋，1红方胜利，2黑方胜利
    self.mTableIsPlaying = false
    if info.winflag == 0 then
        resultDialog:setDrawView()
        if info.redUid == UserInfo.getInstance():getUid() or self.mPlayIdentity == 2 then
            resultDialog:setMyResult(info.redUid,info.winflag,FLAG_RED)
            resultDialog:setMyScoreChange(info.redMatchScore,info.redMatchScoreChange)
            resultDialog:setMyRankChange(info.redMatchRank,info.redMatchRankChange)
            myRank = info.redMatchRank
            resultDialog:setOtherResult(info.blackUid,info.winflag,FLAG_BLACK)
            resultDialog:setOtherScoreChange(info.blackMatchScore,info.blackMatchScoreChange)
            resultDialog:setOtherRankChange(info.blackMatchRank,info.blackMatchRankChange)
        else
            resultDialog:setMyResult(info.blackUid,info.winflag,FLAG_BLACK)
            resultDialog:setMyScoreChange(info.blackMatchScore,info.blackMatchScoreChange)
            resultDialog:setMyRankChange(info.blackMatchRank,info.blackMatchRankChange)
            myRank = info.blackMatchRank
            resultDialog:setOtherResult(info.redUid,info.winflag,FLAG_RED)
            resultDialog:setOtherScoreChange(info.redMatchScore,info.redMatchScoreChange)
            resultDialog:setOtherRankChange(info.redMatchRank,info.redMatchRankChange)
        end
    elseif info.winflag == 1 then
        if info.redUid == UserInfo.getInstance():getUid() or self.mPlayIdentity == 2 then
            resultDialog:setWinView()
            resultDialog:setMyResult(info.redUid,info.winflag,FLAG_RED)
            resultDialog:setMyScoreChange(info.redMatchScore,info.redMatchScoreChange)
            resultDialog:setMyRankChange(info.redMatchRank,info.redMatchRankChange)
            myRank = info.redMatchRank
            resultDialog:setOtherResult(info.blackUid,info.winflag,FLAG_BLACK)
            resultDialog:setOtherScoreChange(info.blackMatchScore,info.blackMatchScoreChange)
            resultDialog:setOtherRankChange(info.blackMatchRank,info.blackMatchRankChange)
        else
            resultDialog:setLoseView()
            resultDialog:setMyResult(info.blackUid,info.winflag,FLAG_BLACK)
            resultDialog:setMyScoreChange(info.blackMatchScore,info.blackMatchScoreChange)
            resultDialog:setMyRankChange(info.blackMatchRank,info.blackMatchRankChange)
            myRank = info.blackMatchRank
            resultDialog:setOtherResult(info.redUid,info.winflag,FLAG_RED)
            resultDialog:setOtherScoreChange(info.redMatchScore,info.redMatchScoreChange)
            resultDialog:setOtherRankChange(info.redMatchRank,info.redMatchRankChange)
        end
    else
        if info.blackUid == UserInfo.getInstance():getUid() or self.mPlayIdentity == 2 then
            resultDialog:setWinView()
            resultDialog:setMyResult(info.blackUid,info.winflag,FLAG_BLACK)
            resultDialog:setMyScoreChange(info.blackMatchScore,info.blackMatchScoreChange)
            resultDialog:setMyRankChange(info.blackMatchRank,info.blackMatchRankChange)
            myRank = info.blackMatchRank
            resultDialog:setOtherResult(info.redUid,info.winflag,FLAG_RED)
            resultDialog:setOtherScoreChange(info.redMatchScore,info.redMatchScoreChange)
            resultDialog:setOtherRankChange(info.redMatchRank,info.redMatchRankChange)
        else
            resultDialog:setLoseView()
            resultDialog:setMyResult(info.redUid,info.winflag,FLAG_RED)
            resultDialog:setMyScoreChange(info.redMatchScore,info.redMatchScoreChange)
            resultDialog:setMyRankChange(info.redMatchRank,info.redMatchRankChange)
            myRank = info.redMatchRank
            resultDialog:setOtherResult(info.blackUid,info.winflag,FLAG_BLACK)
            resultDialog:setOtherScoreChange(info.blackMatchScore,info.blackMatchScoreChange)
            resultDialog:setOtherRankChange(info.blackMatchRank,info.blackMatchRankChange)
        end
    end

    if info.blackUid == self.mPreDownUid then
        self.mDownUserMatchScoreTxt:setText( string.format("生命值:%d",info.blackMatchScore))
    elseif info.blackUid == self.mPreUpUid then
        self.mUpUserMatchScoreTxt:setText( string.format("生命值:%d",info.blackMatchScore))
    end
    
    if info.redUid == self.mPreDownUid then
        self.mDownUserMatchScoreTxt:setText( string.format("生命值:%d",info.redMatchScore))
    elseif info.redUid == self.mPreUpUid then
        self.mUpUserMatchScoreTxt:setText( string.format("生命值:%d",info.redMatchScore))
    end

    if info.signUpSum == 1 then
        resultDialog:setRankRatio(100)
    elseif info.signUpSum-1 > 0 then 
        resultDialog:setRankRatio((info.signUpSum-myRank)/(info.signUpSum-1)*100)
    end

    if resultDialog.setWatchResultView then
        resultDialog:setWatchResultView(info.redUid,info.blackUid,info.winflag)
    end
    
    local data = json.decode(info.giftJsonStr)
    if data then
        local red = json.decode(data.red)
        local black = json.decode(data.black)
        local dialog = self:getInteractionRankDialog()
        dialog:setRedGiftData(red)
        dialog:setBlackGiftData(black)
        resultDialog:setRedGiftData(red)
        resultDialog:setBlackGiftData(black)
    end
    self.mPlayEndAnim = true
    self.mIsMatchOver = info.isMatchOver == 0
    if self.mIsMatchOver then
        self.mMatchBtn:setVisible(false)
    end
    resultDialog:setMatchOver(self.mIsMatchOver)

    self:setPlayerStatus(MetierMatchModule.s_playerStatus.idle)
    self.mScene:gameClose(info.winflag,info.endType);
	OnlineConfig.deleteTimer(self); 
    
    if type(OnlineRoomController.s_switch_func) == "function" then
        OnlineSocketManager.getHallInstance():sendMsg(GIVE_UP_THE_MATCH,{})
        self.mScene:exitRoom()
        return 
    end
end

--显示棋局结算窗口
function MetierMatchModule:showAccount()
    if self.mPlayerStatus == MetierMatchModule.s_playerStatus.eliminate or self:getResurrectionDialog():isShowing() then
        self:getResurrectionDialog():dismiss()
        self:getResultDialog():setReviveView()
    end
    self:getResultDialog():show()

    self.mPlayEndAnim = false
    self:setPlayerStatus(self.mPlayerStatus,true)
end

--[Comment]
-- 断线重连
function MetierMatchModule:onHallMsgLogin(info)
    local matchId = info.matchId
    local roomType = RoomProxy.getRoomTypeByMatchId(matchId)
    if roomType == RoomConfig.ROOM_TYPE_METIER_ROOM then
        self:setPlayerStatus(MetierMatchModule.s_playerStatus.loginMatching)
        self.mRoomReconnection = true
    else
        if self.mPlayerMode == MetierMatchModule.s_playerMode.watch then
            ChessToastManager.getInstance():showSingle("你的网络不稳定,请稍后再试")
        else
            ChessToastManager.getInstance():showSingle("你的比赛已结束")
        end
        self:onServerMsgLogoutSucc()
        self.mScene:exitRoom()
        return
    end
end

function MetierMatchModule:getPlayerStatus()
    return self.mPlayerStatus
end


function MetierMatchModule:setPlayerStatus(status,clear)
    Log.i("MetierMatchModule:setPlayerStatus" .. status)
    -- clear
	self.mScene:stopTimeout(); --停止游戏计时
    local needClear = false
    if status ~= self.mPlayerStatus or clear then
        if status == MetierMatchModule.s_playerStatus.playing
            or status == MetierMatchModule.s_playerStatus.matching then
            needClear = true
        end
    end

    if self.mPlayEndAnim then
        self.mPlayerStatus = status
        return 
    end

    if needClear then
        self.mScene:onResetGame()
    end

    if status == MetierMatchModule.s_playerStatus.loginMatching then
        OnlineSocketManager.getHallInstance():sendMsg(LOGIN_MATCH,{})
    elseif status == MetierMatchModule.s_playerStatus.matching then
        self:showMatchDialog()
        self.mMatchBtn:setVisible(false)
        OnlineSocketManager.getHallInstance():sendMsg(USER_REQUEST_MATCHING,{})
        self:getInteractionRankDialog():resetInteraction()
    elseif status == MetierMatchModule.s_playerStatus.registered then
        ChessToastManager.getInstance():showSingle("比赛房间状态错误，请稍后再试！")
        self.mScene:exitRoom()
        return
    elseif status == MetierMatchModule.s_playerStatus.playing then
        OnlineSocketManager.getHallInstance():sendMsg(FASTMATCH_LOGINROOM_REQUEST,self.mPlayerMode) -- 选手
    elseif status == MetierMatchModule.s_playerStatus.eliminate then
        -- 显示淘汰窗口
        self:getResultDialog():setReviveView()
        OnlineSocketManager.getHallInstance():sendMsg(CHECK_OUT_STATUS,{})
    elseif status == MetierMatchModule.s_playerStatus.idle then
        self:getResultDialog():setNormalView()
        if self:getResultDialog():isShowing() then
            self.mMatchBtn:setVisible(true and not self.mIsMatchOver and self.mPlayerMode == MetierMatchModule.s_playerMode.play)
        else
            self:showMatchDialog()
            self.mMatchBtn:setVisible(false)
            OnlineSocketManager.getHallInstance():sendMsg(USER_REQUEST_MATCHING,{})
            self:getInteractionRankDialog():resetInteraction()
        end
    end

    if self.mRoomReconnection then
        self.mRoomReconnection = false
        -- 房间内断线重连比赛成功 开始重连房间
        if status == MetierMatchModule.s_playerStatus.playing then
            self.mRoomReconnection = true
        end
    end

    self.mPlayerStatus = status
end

function MetierMatchModule:showMatchDialog()
    if not self.mMatchDialog2 then
        self.mMatchDialog2 = new(MatchDialog2)
        self.mMatchDialog2:setBackGroundRunBtnEvent(self,function(self)
            self.mMatchTxt:setVisible(true)
            self.mMatchDialog2:dismiss()
        end)
    end
    self.mMatchDialog2:show()
    self.mMatchTxt:setVisible(false)
end

function MetierMatchModule:dismissMatchDialog()
    self.mMatchTxt:setVisible(false)
    if self.mMatchDialog2 then
        self.mMatchDialog2:dismiss()
    end
end

function MetierMatchModule:isMatchDialogShowing()
    return (self.mMatchDialog2 and self.mMatchDialog2:isShowing()) or self.mMatchTxt:getVisible()
end
-- 新的观战桌子
function MetierMatchModule:onMatchGetWatchTid(info)
    self.mSendMatchGetWatchTidCmdIng = false
    if RoomProxy.getInstance():isMatchWatcher() then
        if info.matchTid == 0 then
            ChessToastManager.getInstance():showSingle("没有新的观战桌子,稍后再试!")
            return
        end
        RoomProxy.getInstance():setMatchId(info.matchID)
        RoomProxy.getInstance():setTid(info.matchTid)
        self:setPlayerStatus(MetierMatchModule.s_playerStatus.playing,true)
        self:getResultDialog():dismiss()
    end
end
-- 比赛结束
function MetierMatchModule:onMatchEndResult(info)
    if info.matchID == RoomProxy.getInstance():getMatchId() then
        self.mIsMatchOver = true
        self.mMatchBtn:setVisible(false)
        self:getResultDialog():setMatchOver(self.mIsMatchOver,"比赛已结束")
        self:getEndRankDialog():setMatchOver(self.mIsMatchOver,"比赛已结束")
        if self.mPlayEndAnim == true or self:getResultDialog():isShowing() then
            return 
        end
        if self.mPlayerStatus ~= MetierMatchModule.s_playerStatus.playing then
            ChessToastManager.getInstance():showSingle("比赛已结束",5000)
            self:showEndRankDialog()
        end
        self:getResurrectionDialog():dismiss()
        self:dismissMatchDialog()
        self:dismissRankDialog()
    end
end
-- 比赛匹配结束
function MetierMatchModule:onMatchEndMatchResult(info)
    if info.matchID == RoomProxy.getInstance():getMatchId() then
        self.mIsMatchOver = true
        self.mMatchBtn:setVisible(false)
        self:getResultDialog():setMatchOver(self.mIsMatchOver,"比赛即将结束，已停止开始新的对局")
        self:getEndRankDialog():setMatchOver(self.mIsMatchOver,"比赛即将结束")
        if self.mPlayEndAnim == true or self:getResultDialog():isShowing() then
            return 
        end
        if self.mPlayerStatus ~= MetierMatchModule.s_playerStatus.playing then
            ChessToastManager.getInstance():showSingle("比赛即将结束，已停止开始新的对局",5000)
            self:showEndRankDialog()
        end
        self:getResurrectionDialog():dismiss()
        self:dismissMatchDialog()
        self:dismissRankDialog()
    end
end

function MetierMatchModule:onCheckMatchUserMaxScoreResult(info)
    if info and info.result == 0 then
        local data = json.decode(info.userJsonStr)
        local total = info.totalPlayer
        local myData = data[UserInfo.getInstance():getUid()..""]
        if myData then
            local tab = ToolKit.split(myData,","); 
            local maxLife = tonumber(tab[1]) or 0
            local maxRank = tonumber(tab[2]) or 0
            local resultDialog = self:getMatchEndDialog()
            if total == 1 then
                resultDialog:setRankRatio(100)
            elseif total-1 > 0 then 
                resultDialog:setRankRatio((total-maxRank)/(total-1)*100)
            end
            resultDialog:setMaxLife(maxLife)
        end
    else
        -- 拉取失败
    end
end

-- 请求匹配返回
function MetierMatchModule:onUserRequestMatchingResult(info)
    local msg = "比赛错误"
    if info.result == 0 then
        self.mShowVsDialog = true
        return 
    elseif info.result == 1 then
        msg = "比赛不存在"
    elseif info.result == 2 then
        msg = "比赛已经结束"
    elseif info.result == 3 then
        msg = "用户状态不一致,正在重连比赛"
        self:setPlayerStatus(MetierMatchModule.s_playerStatus.loginMatching)
        ChessToastManager.getInstance():showSingle(msg)
        return
    end
    ChessToastManager.getInstance():showSingle(msg)
    self.mScene:exitRoom()
end

-- 登录比赛返回
function MetierMatchModule:onLoginMatchResponse(info)
    if info.result ~= 0 then
        local msg = "比赛不存在"
        if info.result == 1 then
            msg = "比赛不存在"
        elseif info.result == 2 then
            msg = "比赛进入时间已截至"
        elseif info.result == 3 then
            msg = "没有报名该比赛"
        end
        ChessToastManager.getInstance():showSingle(msg)
        self.mScene:exitRoom()
        return
    end
    self.mIsMatchOver = false
    self:startRefreshRank()
end

function MetierMatchModule:startRefreshRank()
    self:stopRefreshRank()
    self.mRefreshRankAnim = AnimFactory.createAnimInt(kAnimLoop, 0, 1, 10000, -1)
    self.mRefreshRankAnim:setEvent(self,function()
        local params = {}
        params.param = {}
        params.param.match_id= RoomProxy.getInstance():getMatchId()
        params.param.rank_num = 3
        HttpModule.getInstance():execute(HttpModule.s_cmds.MatchRank2,params);

        local params = {}
        params.check_uid = UserInfo.getInstance():getUid()
        OnlineSocketManager.getHallInstance():sendMsg(MATCH_CHECK_USER_RANK,params)
    end)
    local params = {}
    params.param = {}
    params.param.match_id= RoomProxy.getInstance():getMatchId()
    params.param.rank_num = 3
    HttpModule.getInstance():execute(HttpModule.s_cmds.MatchRank2,params);

    local params = {}
    params.check_uid = UserInfo.getInstance():getUid()
    OnlineSocketManager.getHallInstance():sendMsg(MATCH_CHECK_USER_RANK,params)
end

function MetierMatchModule:stopRefreshRank()
    delete(self.mRefreshRankAnim)
end

function MetierMatchModule:onRefreshRank(message)
    local msg = json.analyzeJsonNode(message)
    if msg.data and type(msg.data) == "table" then
        self:refreshRank(msg.data.list)
    end
end

function MetierMatchModule:onMatchCheckUserRank(info)
    if info and info.matchID == RoomProxy.getInstance():getMatchId() and info.uid == UserInfo.getInstance():getUid() then
        local total = tonumber(info.total_num) or 0
        local me_rank = tonumber(info.rank) or 0
        self.mRankText:setText( string.format("%d/%d",me_rank,total))
    end
end

function MetierMatchModule:onMatchRebuy(isSuccess,message)
    self.mMatchRebuySendMsg = false
    if isSuccess then
        local msg = json.analyzeJsonNode(message)
        if msg.data and type(msg.data) == "table" then
            self:getResultDialog():dismiss()
            self:getResurrectionDialog():dismiss()
            UserInfo.getInstance():setMoney(msg.data.money or 0)
            if self.mPlayerStatus == MetierMatchModule.s_playerStatus.eliminate then
                self:setPlayerStatus(MetierMatchModule.s_playerStatus.idle)
            end
        end
    elseif not isSuccess then
        if type(message) == "table" then
            local msg = json.analyzeJsonNode(message)
            if msg.flag == 22 then
                self:getResultDialog():dismiss()
                self:getResurrectionDialog():dismiss()
                if self.mPlayerStatus == MetierMatchModule.s_playerStatus.eliminate then
                    self:setPlayerStatus(MetierMatchModule.s_playerStatus.idle)
                end
            else
                HttpModule.explainPHPMessage(isSuccess,message,"复活失败")
                if msg.flag == 1000 then -- 金币不足
                    local goods = MallData.getInstance():getGoodsByMoreMoney(msg.data.rebuy_money or 0)
                    if goods then
                        local payData = {}
                        payData.pay_scene = PayUtil.s_pay_scene.default_recommend
                        local payInterface = PayUtil.getPayInstance(PayUtil.s_defaultType);
		                payInterface:buy(goods,payData);
                    end
                    return 
                end
            end
        end
    end
end
-- 桌子退出成功 不代表比赛结束
function MetierMatchModule:onServerMsgLogoutSucc()
    self.mScene.m_login_succ = false
end

-- 比赛玩家状态返回
function MetierMatchModule:refreshRank(data)
    self.mRefreshRankData = data
    local dialog = self:getResultDialog()
    if dialog and dialog.initList then
        dialog:initList(data)
    end
end

function MetierMatchModule:onMatchGetMatchScore(info)
    if self.mScene.m_upUser and self.mScene.m_upUser:getUid() == info.uid then
        self.mUpUserMatchScoreTxt:setText( string.format("生命值:%d",info.score))
    end
    if self.mScene.m_downUser and self.mScene.m_downUser:getUid() == info.uid then
        self.mDownUserMatchScoreTxt:setText( string.format("生命值:%d",info.score))
    end
end

function MetierMatchModule:downComeIn(user)
    if not user then return end
    local params = {}
    params.check_uid = user:getUid()
    OnlineSocketManager.getHallInstance():sendMsg(MATCH_GET_MATCH_SCORE,params)
    if self.mPreDownUid ~= params.check_uid then
        self.mDownUserMatchScoreTxt:setText( "生命值:-")
    end
    self.mPreDownUid = params.check_uid
end

function MetierMatchModule:upComeIn(user)
    if not user then return end
    local params = {}
    params.check_uid = user:getUid()
    OnlineSocketManager.getHallInstance():sendMsg(MATCH_GET_MATCH_SCORE,params)
    if self.mPreUpUid ~= params.check_uid then
        self.mUpUserMatchScoreTxt:setText( "生命值:-")
    end
    self.mPreUpUid = params.check_uid
end

-- 比赛玩家状态返回
function MetierMatchModule:onServerReturnsPlayerStatus(info)
    RoomProxy.getInstance():setMatchId(info.matchId)
    RoomProxy.getInstance():setTid(info.tid)
    RoomProxy.getInstance():setMatchRecordId(info.matchRecordId)
    self:setPlayerStatus(info.userStatus)
end

function MetierMatchModule:startCountDownTimer(time)
    if not self.mCountDownTimerDialog then
		self.mCountDownTimerDialog = new(LoadingDialog);
    end
	self.mCountDownTimerDialog:setMessage("棋局即将开始");
	self.mCountDownTimerDialog:show(time);
end

function MetierMatchModule:stopCountDownTimer()
    if self.mCountDownTimerDialog then
	    self.mCountDownTimerDialog:dismiss()
    end
end


-- 查询用户状态返回
function MetierMatchModule:onGetMatchPlayerInfoResult(info)
    if info.time > 0 or self.mPlayIdentity == 2 then
        if info.time > 0 then
            self:startCountDownTimer(info.time)
        end
        if self.mShowVsDialog then
            if not self.mVsDialog then
                self.mVsDialog = new(MatchVsDialog)
            end
            if self.mScene.m_downUser and info.mid1 == self.mScene.m_downUser:getUid() then
                self.mVsDialog:setTopUserView(info.mid2,info.life2,info.flag2)
                self.mVsDialog:setDownUserView(info.mid1,info.life1,info.flag1)
            else
                self.mVsDialog:setTopUserView(info.mid1,info.life1,info.flag1)
                self.mVsDialog:setDownUserView(info.mid2,info.life2,info.flag2)
            end
            self.mVsDialog:show()
            self.mShowVsDialog = false
        end
    end
end

-- 查下淘汰状态返回
function MetierMatchModule:onCheckOutStatusResult(info)
    self:getResurrectionDialog():setReviveViewData(info)
    self:getResultDialog():setReviveViewData(info)
    self:showResurrectionDialog()
end

function MetierMatchModule:showResurrectionDialog()
    if self:getResultDialog():isShowing() or self.mTableIsPlaying then

    else
        self:getResurrectionDialog():show()
    end
end

function MetierMatchModule:getResultDialog()
    if self.mPlayIdentity == 2 then
        return self:getMatchWatcherResultDialog()
    else
        return self:getMatchResultDialog()
    end
end

function MetierMatchModule:getMatchWatcherResultDialog()
    if not self.mMatchWatcherResultDialog then
        self.mMatchWatcherResultDialog = new(MatchWatchResultDialog)
        self.mMatchWatcherResultDialog:setShareBtnClick(self,function(self)
            self.mScene:shareFuPan()
        end)
        self.mMatchWatcherResultDialog:setCancelEvent(self,function(self)
            self.mMatchWatcherResultDialog:dismiss()
        end)
        self.mMatchWatcherResultDialog:setSaveChessEvent(self,function(self)
            self.mScene:savetoLocal2()
        end)
        self.mMatchWatcherResultDialog:setGotoWatchEvent(self,function(self,matchId,tid)
            RoomProxy.getInstance():setMatchId(matchId)
            RoomProxy.getInstance():setTid(tid)
            self:setPlayerStatus(MetierMatchModule.s_playerStatus.playing)
            self.mMatchWatcherResultDialog:dismiss()
        end)
        self.mMatchWatcherResultDialog:setContinueWatchBtnEvent(self,function()
--            if self.mSendMatchGetWatchTidCmdIng then return end
--            self.mSendMatchGetWatchTidCmdIng = true
--            OnlineSocketManager.getHallInstance():sendMsg(MATCH_GET_WATCH_TID,{})
            local matchId = RoomProxy.getInstance():getMatchId()
            OnlineRoomController.s_switch_func = function()
                if UserInfo.getInstance():isFreezeUser() then return end;
                CompeteScene.s_join_match_rank_room_id = matchId
                StateMachine.getInstance():replaceState(States.Compete,StateMachine.STYPE_CUSTOM_WAIT);
            end
            self:backAction()
        end)
    end
    return self.mMatchWatcherResultDialog
end

function MetierMatchModule:getMatchResultDialog()
    if not self.mResultDialog then
        self.mResultDialog = new(MatchResultDialog)
        self.mResultDialog:setNormalView()
        local config = RoomProxy.getInstance():getCurRoomConfig()
        self.mResultDialog:setOverTime(config.match_end_time)
        self.mResultDialog:setPlayAgainBtnEvent(self,function(self)
            if self.mPlayerStatus == MetierMatchModule.s_playerStatus.eliminate then
                self:setPlayerStatus(MetierMatchModule.s_playerStatus.eliminate)
                return 
            end
            self.mResultDialog:dismiss()
            self:setPlayerStatus(MetierMatchModule.s_playerStatus.idle)
        end)
        self.mResultDialog:setCancelEvent(self,function(self)
            if self.mPlayerStatus == MetierMatchModule.s_playerStatus.eliminate then
                self:getMatchEndDialog():show()
                self:getMatchEndDialog():setMyResult(UserInfo.getInstance():getUid())
                OnlineSocketManager.getHallInstance():sendMsg(GIVE_UP_THE_RESURRECTION,{})
                OnlineSocketManager.getHallInstance():sendMsg(CHECK_MATCH_USER_MAX_SCORE,{UserInfo.getInstance():getUid()}) -- 选手
            end
            self.mResultDialog:dismiss()
            self.mResultDialog:setNormalView()
            if self.mIsMatchOver then
                self.mScene:exitRoom()
            end
        end)
        self.mResultDialog:setCountDownBtnEvent(self,function(self)
            if self.mPlayerStatus == MetierMatchModule.s_playerStatus.eliminate then
                if self.mMatchRebuySendMsg then return end
                self.mMatchRebuySendMsg = true
                local params = {}
                params.param = {}
                params.param.match_id = RoomProxy.getInstance():getMatchId()
                HttpModule.getInstance():execute(HttpModule.s_cmds.MatchRebuy,params,"购买中...")
            else
                self.mResultDialog:setNormalView()
            end
        end)
        self.mResultDialog:setSaveChessEvent(self,function(self)
            self.mScene:savetoLocal2()
        end)
        self.mResultDialog:setShowRankEvent(self,function(self)
            self:showEndRankDialog()
            self.mResultDialog:dismiss()
        end)
    end
    return self.mResultDialog
end

function MetierMatchModule:getResurrectionDialog()
    if not self.mResurrectionDialog then
        self.mResurrectionDialog = new(ResurrectionDialog)
        self.mResurrectionDialog:setCancelEvent(self,function(self)
            -- 显示结算弹窗
            if self.mPlayerStatus == MetierMatchModule.s_playerStatus.eliminate then
                self:getMatchEndDialog():show()
                self:getMatchEndDialog():setMyResult(UserInfo.getInstance():getUid())
                OnlineSocketManager.getHallInstance():sendMsg(GIVE_UP_THE_RESURRECTION,{})
                OnlineSocketManager.getHallInstance():sendMsg(CHECK_MATCH_USER_MAX_SCORE,{UserInfo.getInstance():getUid()}) -- 选手
            end
            self.mResurrectionDialog:dismiss()
        end)
        self.mResurrectionDialog:setCountDownBtnEvent(self,function(self)
            if self.mPlayerStatus == MetierMatchModule.s_playerStatus.eliminate then
                if self.mMatchRebuySendMsg then return end
                self.mMatchRebuySendMsg = true
                local params = {}
                params.param = {}
                params.param.match_id = RoomProxy.getInstance():getMatchId()
                HttpModule.getInstance():execute(HttpModule.s_cmds.MatchRebuy,params,"购买中...")
            end
        end)
    end
    return self.mResurrectionDialog
end

function MetierMatchModule:getMatchEndDialog()
    if not self.mMatchEndDialog then
        self.mMatchEndDialog = new(MatchEndDialog)
        self.mMatchEndDialog:setShareBtnEvent(self,function()
                local path = System.getStorageImagePath().."egame_share";
                ToolKit.takeShot(self.mMatchEndDialog.mBg.m_drawingID,path);
                EventDispatcher.getInstance():dispatch(Event.Call,kTakeShotComplete);
            end)
        self.mMatchEndDialog:setWatchBtnEvent(self,function() 
                self.mMatchEndDialog:dismiss()
                self.mScene:exitRoom()
            end)
    end
    return self.mMatchEndDialog
end

function MetierMatchModule:showInteractionRank()
    local dialog = self:getInteractionRankDialog()
    
    local redUid,blackUid
    if self.mScene.m_downUser then
        if self.mScene.m_downUser:getFlag() == FLAG_RED then
            redUid = self.mScene.m_downUser:getUid()
        elseif self.mScene.m_downUser:getFlag() == FLAG_BLACK then
            blackUid = self.mScene.m_downUser:getUid()
        end
    end
    if self.mScene.m_upUser then
        if self.mScene.m_upUser:getFlag() == FLAG_RED then
            redUid = self.mScene.m_upUser:getUid()
        elseif self.mScene.m_upUser:getFlag() == FLAG_BLACK then
            blackUid = self.mScene.m_upUser:getUid()
        end
    end
    dialog:setRedUserView(redUid)
    dialog:setBlackUserView(blackUid)
    dialog:show()
    OnlineSocketManager.getHallInstance():sendMsg(CHECK_MATCH_USER_GIFT_INFO,{})
end

--[Comment]
-- info.result 0：获取成功； 1：桌子不存在
-- json 如："red":child_json1 "black":child_json2 child_json格式如下： "350":"100" （350类型礼物收到100个）
function MetierMatchModule:onCheckMatchUserGiftInfoResult(info)
    if info.result == 0 then
        local data = json.decode(info.giftJsonStr)
        if data then
            local red = json.decode(data.red)
            local black = json.decode(data.black)
            local dialog = self:getInteractionRankDialog()
            dialog:setRedGiftData(red)
            dialog:setBlackGiftData(black)
            self:getResultDialog():setRedGiftData(red)
            self:getResultDialog():setBlackGiftData(black)
        end
    end
end


function MetierMatchModule:getInteractionRankDialog()
    if not self.mInteractionRankDialog then
        self.mInteractionRankDialog = new(MatchInteractionInfoDialog)
    end
    return self.mInteractionRankDialog
end

function MetierMatchModule:onRecvServerGiftMsg(packetInfo)
    local dialog = self:getInteractionRankDialog()
    dialog:addInteractionLog(packetInfo)
end


function MetierMatchModule:showRankDialog()
--    if self.mIsMatchOver and self.mPlayerStatus ~= MetierMatchModule.s_playerStatus.playing then
--        self:showEndRankDialog()
--        return
--    end
    local matchId = RoomProxy.getInstance():getMatchId()
    local config = RoomConfig.getInstance():getMatchRoomConfig(matchId)
    if not config then return end
    delete(self.mRankDialog)
    self.mRankDialog = new(MatchRankDialog,config)
    self.mRankDialog:setCloseClickEvent(self,function()
        self.mRankDialog:dismiss()
    end)
    self.mRankDialog:show()
end

function MetierMatchModule:dismissRankDialog()
    if self.mRankDialog then
        self.mRankDialog:dismiss()
    end
end

function MetierMatchModule:getEndRankDialog()
    if not self.mEndRankDialog then
        self.mEndRankDialog = new(MatchEndRankDialog)
        self.mEndRankDialog:setTrackClickEvent(self,function(self,matchId,tid)
            local config = RoomConfig.getInstance():getMatchRoomConfig(matchId)
            if config and tid > 0 then
                self:changeWatchMode()
                RoomProxy.getInstance():gotoMetierRoomByWatch(matchId,tid)
                self:setPlayerStatus(MetierMatchModule.s_playerStatus.playing)
                self.mEndRankDialog:dismiss()
            end
        end)
        self.mEndRankDialog:setCancelEvent(self,function() 
                self.mEndRankDialog:dismiss()
                self.mScene:exitRoom()
            end)
    end
    return self.mEndRankDialog
end

function MetierMatchModule:showEndRankDialog()
    local dialog = self:getEndRankDialog()
    dialog:setMatchId(RoomProxy.getInstance():getMatchId())
    dialog:show()
end

function MetierMatchModule:dismissEndRankDialog()
    self:getEndRankDialog():dismiss()
end
--[Comment]
--int matchId   //比赛ID
--int status  //状态
--//status =1：代表比赛对战中   
--//status =2：代表比赛等待中
--//status =3: 代表比赛观战中
-- 登录桌子返回
function MetierMatchModule:onMatchLoginSuc(info)
    RoomProxy.getInstance():setMatchId(info.matchId)
    RoomProxy.getInstance():setTid(info.tid)
    self.mScene.m_login_succ = true
    local status = info.status
    self.mPlayIdentity = 0
    
    
    self:dismissMatchDialog()
    -- 房间内断线重连桌子 不改变vs dialog是否显示状态
    if not self.mRoomReconnection then
        self.mShowVsDialog = true
    end
    self.mRoomReconnection = false
    if status == 1 then
        self.mPlayIdentity = 1
        OnlineSocketManager.getHallInstance():sendMsg(MATCH_GETTABLEINFO) -- 选手
    elseif status == 2 then
--        self:setPlayerStatus(MetierMatchModule.s_playerStatus.idle)
    elseif status == 3 then
        self.mPlayIdentity = 2
        self.mWatchTableInit = false
        self:loadHistoryMsgs()
        OnlineSocketManager.getHallInstance():sendMsg(MATCH_GETOBTABLEINFO) -- 选手
    end
    OnlineSocketManager.getHallInstance():sendMsg(GET_MATCH_PLAYER_INFO,{})
end
-- 保存棋谱
function MetierMatchModule:onSaveChessCallBack( data)
    if data.cost then
        local resultDialog = self:getResultDialog()
        resultDialog:saveChessSuccess()
    end
end

--接收礼物广播
function MetierMatchModule.receiveGiftMsg(self, data)
--data {gift_type=16 send_id=1407 gift_count=1 target_id=10000441 }
    if not data then return end
    local gift_send_id = tonumber(data.send_id)
    local gift_target_id = tonumber(data.target_id);
    local send_info = json.decode(data.send_info) or {}
--    local flag = 1
    local name = "博雅象棋"
    if self.mScene.m_downUser then
        if self.mScene.m_downUser.m_uid == gift_target_id then
            name = self.mScene.m_downUser:getName()
        end
    end
    if self.mScene.m_upUser then
        if self.mScene.m_upUser.m_uid == gift_target_id then
            name = self.mScene.m_upUser:getName()
        end
    end

    local tab = {}
    tab.sendInfo = send_info or {}
    tab.targetName = name or "博雅象棋"
    tab.sendId = gift_send_id or 0
    tab.targetId = gift_target_id or 0
    tab.gift_type = tonumber(data.gift_type) or 16
    tab.score = tonumber(data.score) or 1000
    tab.giftNum = tonumber(data.gift_count) or 1
    tab.msgTime = os.time()
    tab.key = tostring(tab.sendId) .. tostring(tab.targetId) .. tostring(tab.gift_type)
    self:getInteractionRankDialog():addInteractionLog(tab)
    if self.m_watch_dialog and self.m_watch_dialog:getVisible() then
        self.m_watch_dialog:addChatTips(tab,1);
    end
end

-- 模式切换
function MetierMatchModule:changeWatchMode()
    if self.mPlayerMode == MetierMatchModule.s_playerMode.watch then return end
    self.mLoadHistoryLog = true
    RoomProxy.getInstance():setCurRoomModeIsWatch(true)
    self.mPlayerMode = MetierMatchModule.s_playerMode.watch
    self.mRoomRank:setVisible(false)
    self.mMatchBtn:setVisible(false)
    self.mMatchTxt:setVisible(false)

    self.mScene.m_room_watcher_btn:setOnClick(self.mScene,self.mScene.gotoWatchList);
    self.mScene.m_multiple_img_bg:setVisible(true)
    self.mScene.m_chest_btn:setVisible(true)
    self.mScene.m_down_view1.money_btn:setVisible(true)
    self.mScene.m_roomid:setVisible(true)
    self:stopRefreshRank()
    self:showWatchMode()
    self.mScene:setIsWatchGiftAnim(true)
    self.mUpUserMatchScoreTxt:setVisible(false)
    self.mDownUserMatchScoreTxt:setVisible(false)
end

function MetierMatchModule:changePlayMode()
    if self.mPlayerMode == MetierMatchModule.s_playerMode.play then return end
    RoomProxy.getInstance():setCurRoomModeIsWatch(false)
    self.mPlayerMode = MetierMatchModule.s_playerMode.play
    self:dismissWatchMode()
    self.mRoomRank:setVisible(true)
    self.mMatchBtn:setVisible(false)
    self.mMatchTxt:setVisible(false)
    self.mScene.m_room_watcher_btn:setOnClick(self,self.showInteractionRank);
    self.mScene.m_multiple_img_bg:setVisible(false)
    self.mScene.m_chest_btn:setVisible(false)
    self.mScene.m_down_view1.money_btn:setVisible(false)
    self.mScene.m_roomid:setVisible(false)
    -- 初始化rank  隐藏rank
    self.mShowVsDialog = true
    self:refreshRank({})
    self.mScene:setIsWatchGiftAnim(false)
    self.mUpUserMatchScoreTxt:setVisible(true)
    self.mDownUserMatchScoreTxt:setVisible(true)
end

function MetierMatchModule:showWatchMode()
    -- 隐藏时间
    self.mScene.m_root_view:getChildByName("room_time_bg"):setVisible(false);
    self.mScene.m_room_menu_view:setVisible(false);
    -- 隐藏聊天按钮和功能按钮
    self.mScene.m_chat_btn:setVisible(false);
    self.mScene.m_menu_btn:setVisible(false);
    -- 隐藏观战人数
    self.mScene.m_room_watcher_btn:setVisible(true);
    self.mScene.m_room_watcher_btn:setPos(5,0);
    -- up_user
    self:showWatchUpUser();
    -- down_user
    self:showWatchDownUser();   
    -- 显示对局
--    self.mScene.m_root_view:getChildByName("vs_img"):setVisible(true);
    -- 棋盘上移留出聊天空间
    self.mScene.m_board_view:setPos(0,116);
    self.mScene.m_board_view:setPickable(false)
    -- 显示新版watch_view
    self:showNewWatchView();
    -- 隐藏宝箱
    self.mScene.m_chest_btn:setVisible(false);
    local w,h = self.mScene.m_board_view:getSize()
    self.mScene.m_board_view:addPropScaleSolid(100,0.95, 0.95, kCenterXY, w/2, 0)
end

function MetierMatchModule.updataWatchHistoryMsgs(self,info)
    if self.m_watch_dialog then
        self.m_watch_dialog:updataWatchHistoryMsgs(info);
    end
end

function MetierMatchModule.loadHistoryMsgs(self)
    if self.mLoadHistoryLog then
        self.mLoadHistoryLog = false
        OnlineSocketManager.getHallInstance():sendMsg(OB_CMD_GET_HISTORY_MSGS);
    end
end

function MetierMatchModule:dismissWatchMode()
    self.mScene.m_root_view:getChildByName("room_time_bg"):setVisible(true);
    self.mScene.m_room_menu_view:setVisible(true);
    self.mScene.m_chat_btn:setVisible(true);
    self.mScene.m_menu_btn:setVisible(true);
    self.mScene.m_room_watcher_btn:setVisible(true);
    self.mScene.m_room_watcher_btn:setPos(47,-28);
    self:dismissWatchUpUser();
    self:dismissWatchDownUser();   
--    self.mScene.m_root_view:getChildByName("vs_img"):setVisible(false);
    self.mScene.m_board_view:setPos(0,197);
    self.mScene.m_board_view:setPickable(true)
    self:dismissNewWatchView();
    self.mScene.m_chest_btn:setVisible(true);
    self.mScene.m_board_view:removeProp(100)
end


function MetierMatchModule.showWatchUpUser(self)
    self.up_view_status = OnlineUserInfoCommonView.WATCH_LEFT
    self.mScene.m_up_view1:initWatchView(self.up_view_status)
end


function MetierMatchModule.showWatchDownUser(self)
    self.down_view_status = OnlineUserInfoCommonView.WATCH_RIGHT
    self.mScene.m_down_view1:initWatchView(self.down_view_status)
end

function MetierMatchModule.showNewWatchView(self)
    if not self.m_watch_dialog then
        self.m_watch_dialog = new(WatchDialog, self.mScene);
    end
    self.m_watch_dialog:setLevel(20)
    self.m_watch_dialog:show();
end

function MetierMatchModule.dismissWatchUpUser(self)
    self.up_view_status = OnlineUserInfoCommonView.ONLINE_UP
    self.mScene.m_up_view1:initWatchView(self.up_view_status)
end


function MetierMatchModule.dismissWatchDownUser(self)
    self.down_view_status = OnlineUserInfoCommonView.ONLINE_DOWN
    self.mScene.m_down_view1:initWatchView(self.down_view_status)
    self.mScene.m_down_view1.money_btn:setVisible(false)
end

function MetierMatchModule.switchSide(self)
    self.up_view_status = (self.up_view_status == OnlineUserInfoCommonView.WATCH_LEFT and OnlineUserInfoCommonView.WATCH_RIGHT) or OnlineUserInfoCommonView.WATCH_LEFT
    self.down_view_status = (self.down_view_status == OnlineUserInfoCommonView.WATCH_LEFT and OnlineUserInfoCommonView.WATCH_RIGHT) or OnlineUserInfoCommonView.WATCH_LEFT
    self.mScene.m_down_view1:switchView(self.down_view_status,true)
    self.mScene.m_up_view1:switchView(self.up_view_status,true)
end

function MetierMatchModule.dismissNewWatchView(self)
    delete(self.m_watch_dialog)
    self.m_watch_dialog = nil
end

function MetierMatchModule.onWatcherChatMsg(self, data)
    if data.uid ~= UserInfo.getInstance():getUid() then
        local name      = data.name;
        local msgType   = data.msgType;
        local message   = data.message;
        local uid       = data.uid;
        if not message or message == "" then
		    return;
	    end
	    local msg = string.format("%s:%s",name,message);
        if self.m_watch_dialog then -- 是自己发的观战消息显示在
            self.m_watch_dialog:addChatLog(name,message,uid);
        end
    end
end

function MetierMatchModule.onWatchRoomMsg(self,packetInfo)
    if not packetInfo or not packetInfo.chat_msg or packetInfo.chat_msg == ""  or not packetInfo.name or packetInfo.name == "" then
		return;
	end
    if packetInfo and packetInfo.uid == UserInfo.getInstance():getUid() then
        if packetInfo.forbid_time == -1 then 
            ChessToastManager.getInstance():showSingle("亲，消息不能为空或频繁发送哦",1500);
            return;
        end;
    end;
    local sendInfo = json.decode(packetInfo.send_info) or {}
	local msg = string.format("%s:%s",packetInfo.name,packetInfo.chat_msg);
    if self.m_watch_dialog then
        self.m_watch_dialog:addChatLog(packetInfo.name,packetInfo.chat_msg,packetInfo.uid,sendInfo)
    end
end

function MetierMatchModule.updataWatchNum(self,info)
    if self.m_watch_dialog then
        self.m_watch_dialog:updataWatchNum(info);
    end
end

function MetierMatchModule.sendWatchChat(self, message)
    self.mScene:requestCtrlCmd(OnlineRoomController.s_cmds.send_watch_chat, message);
end
-- 观战模式
function MetierMatchModule.onWatchRoomMove(self, data)
    if self.mPlayIdentity ~= 2 or not data or not self.mWatchTableInit then return end;
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


function MetierMatchModule.onUpdateWatchRoom(self, data, message)
    if self.mPlayIdentity ~= 2 or not data then return end;
    self.mWatchTableInit = true
    local player1 = data.player1;
    local player2 = data.player2;
    local userName = ""
    -- 观战棋桌未初始化
    -- 1.观战时显示对局中双方较贵的棋盘
            --a)优先级：会员棋盘＞竹林棋盘＞湖畔棋盘＞怀旧棋盘＞普通棋盘
    if self.m_board_bg_res == nil then
        if player1 then
            local userset = player1:getUserSet()
            if type(userset) == "table" and UserSetInfo.checkExistBoardRes(userset.board) then
                self.m_board_bg_res = userset
                userName = player1:getName()
            end
        end
        if player2 then
            local userset = player2:getUserSet()
            if type(userset) == "table" and UserSetInfo.checkExistBoardRes(userset.board) then
                local set = userset
                if not self.m_board_bg_res or UserSetInfo.comparisonResValue(set.board,self.m_board_bg_res.board) > 0 then
                    self.m_board_bg_res = set
                    userName = player1:getName()
                end
            end
        end
    end

    if type(self.m_board_bg_res) == "table" then
        local res = UserSetInfo.getChessBoardRes(self.m_board_bg_res.board)
        if res then 
            self.mScene.m_board_bg:setFile(res.board);
            self.mScene.m_room_bg:setFile(res.bg_img);
            local tabName = res.name or ""
            if tabName ~= "默认" then
                ChessToastManager.getInstance():showSingle( string.format("当前展示棋盘为%s的 %s",userName,tabName))
            end
        end
        local pieceRes = UserSetInfo.getChessMapRes(self.m_board_bg_res.piece)
        if pieceRes then 
            self.mScene.m_board:setBoardresMap(pieceRes.piece_res)
        end
    end
    -- 不再初始化
    self.m_board_bg_res = -1

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
        -- 观战中途加入 获取开局时间
        RoomProxy.getInstance():sendGetRoomStartTimeCmd()
    else
        self.mScene:setStatus(data.status);
--        ShowMessageAnim.play(self.m_root_view,"等待开局");
--        local message =  "等待开局"; 
--        ChessToastManager.getInstance():showSingle(message);   
    end
end

function MetierMatchModule.onWatchRoomUserLeave(self, data)
    if self.mPlayIdentity ~= 2 or not data or not self.mWatchTableInit then return end
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

function MetierMatchModule.onWatchRoomStart(self, data)
    if self.mPlayIdentity ~= 2 or not data or not self.mWatchTableInit then return end
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

function MetierMatchModule.onWatchRoomClose(self, data)
    if self.mPlayIdentity ~= 2 or not data or not self.mWatchTableInit then return end;
	self:setWatchUsersInfo(data);
    self.mScene:setStatus(data.status);
	self.mScene:gameClose(data.win_flag,data.end_type);   
	OnlineConfig.deleteTimer(self);  
end

--挑战邀请通知
function MetierMatchModule:onInvitNotify(packageInfo)
    if self.mPlayerStatus ~= MetierMatchModule.s_playerStatus.sign then return end

    local money = UserInfo.getInstance():getMoney();
    local isCanAccess = RoomProxy.getInstance():canAccessRoom(RoomConfig.ROOM_TYPE_FRIEND_ROOM,money);
    if not isCanAccess then
        ChessToastManager.getInstance():showSingle( string.format("用户ID:%d向你发起挑战,由于你的金币不足或超出上限,无法接受挑战!",packageInfo.uid),3000);
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

--更新关注的弹窗
function MetierMatchModule.sendFllowCallback(self,info)
end

function MetierMatchModule.onServerReturnsVipLogin(self,info)
    if self.m_watch_dialog then
        self.m_watch_dialog:addMsgVipLogin(info);
    end
end
