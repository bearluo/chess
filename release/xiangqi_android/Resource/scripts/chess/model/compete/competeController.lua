require(BASE_PATH .. "chessController")

CompeteController = class(ChessController)

CompeteController.s_cmds = 
{
	back_action = 1,
}

CompeteController.ctor = function( self, state, viewClass, viewConfig )
	self.m_state = state
	--

end

CompeteController.resume = function( self )
	ChessController.resume(self)
	--
	Log.d("send getMatchList")
	HttpModule.getInstance():execute(HttpModule.s_cmds.getMatchList)--t
	self:startTimer()
end

CompeteController.pause = function( self )
	ChessController.pause(self)
	self:stopTimer()
end

CompeteController.dtor = function( self )
	self:stopTimer()
    delete(self.m_chioce_dialog)
end

CompeteController.onBack = function( self )
	-- close other view
	StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT)
end

CompeteController.openWatchDialog = function( self, itemData )
	self:updateView(CompeteScene.s_cmds.open_watch, itemData)
end

CompeteController.startTimer = function( self )
	self:stopTimer()

	self.match_status_timer = new(AnimInt, kAnimRepeat, 0, 1, 5000, -1)
	self.match_status_timer:setDebugName("CompeteController|match_status_timer")
	self.match_status_timer:setEvent(self, self.requestMatchStatus)
end

CompeteController.stopTimer = function( self )
	delete(self.match_status_timer)
	self.match_status_timer = nil
end

-- 定时更新比赛状态
CompeteController.requestMatchStatus = function( self )
	local data = {};
	HttpModule.getInstance():execute(HttpModule.s_cmds.matchStatus, data)
end

-- php cmd ---------------------------------------------
-- 获取比赛列表
CompeteController.onHttpMatchList = function( self, isSuccess, message )
    ChessController.onIndexGetMatchConfig(self, isSuccess, message)
	self:updateView(CompeteScene.s_cmds.match_list, isSuccess, message)
end

-- 报名比赛
CompeteController.onHttpJoinMatch = function( self, isSuccess, message )
	self:updateView(CompeteScene.s_cmds.join_match, isSuccess, message)
    self:requestMatchStatus()
end

-- 取消报名
CompeteController.onHttpExitMatch = function( self, isSuccess, message )
	self:updateView(CompeteScene.s_cmds.exit_match, isSuccess, message)
    self:requestMatchStatus()
end

-- 定时更新比赛信息
CompeteController.onHttpMatchStatus = function( self, isSuccess, message )
	self:updateView(CompeteScene.s_cmds.match_status, isSuccess, message)
end

-- server cmd ------------------------------------------
-- 报名开始
CompeteController.onServerSignBegin = function( self, info )
	Log.d("onServerSignBegin")
	Log.d(info)
end

-- 延时报名结束
CompeteController.onServerDelaySignEnd = function( self, info )
	Log.d("onServerDelaySignEnd")
	Log.d(info)
end

-- 比赛开始
CompeteController.onServerMatchStart = function( self, info )
	Log.d("onServerMatchStart")
	Log.d(info)

	--RoomProxy.getInstance():gotoMetierRoom(id)
end

-- 迟到进入结束
CompeteController.onServerLateEnterEnd = function( self, info )
	Log.d("onServerLateEnterEnd")
	Log.d(info)
end

-- 进入比赛
CompeteController.onServerEnterMatch = function( self, info )
	Log.d("onServerEnterMatch")
	Log.d(info)
end

-- 获取比赛状态
CompeteController.onServerGetSelfStatus = function( self, info )
	Log.d("onServerGetSelfStatus")
	Log.d(info)
end

-- 获取观战列表
CompeteController.onServerWatchList = function( self, info )
	Log.d("onServerWatchList")
	Log.d(info)

	self:updateView(CompeteScene.s_cmds.watch_list, info)
end

CompeteController.onHallMsgGamePlay = function(self, packageInfo)
    Log.i("OnlineController.onHallMsgLogin");
    self:updateView(CompeteScene.s_cmds.update_room_players, packageInfo);
end

CompeteController.onFastmatchGetSignupInfo = function(self, packageInfo)
    Log.i("OnlineController.onHallMsgLogin");
    self:updateView(CompeteScene.s_cmds.update_fastmatch_signup_info, packageInfo);
end

CompeteController.onMatchStartReminder = function(self,packageInfo)
    local data = json.decode(packageInfo.jsonStr)
    if not data then return end

    if not self.mMatchNoticeView then
        self.mMatchNoticeView = new(MatchNoticeView)
        self.mMatchNoticeView:setAlign(kAlignBottom)
        self.mMatchNoticeView:setLevel(11)
        self.mMatchNoticeView:addToRoot()
    end
    local obj,func 
--跳转类型（0:不跳转，1:跳转聊天室，2:跳转比赛）
    local jumpType = tonumber(data.confirm_type) or 0
    if jumpType == 0 then
    elseif jumpType == 1 then
        obj = data
        func = function(params)
            local dialog = self:updateView(CompeteScene.s_cmds.show_match_dialog,params.match_id)
            if dialog and dialog.showChatView then
                dialog:showChatView()
            end
            self.mMatchNoticeView:dismiss()
        end
    elseif jumpType == 2 then
        obj = data
        func = function(params)
            local roomConfig = RoomConfig.getInstance();
            local matchId = params.match_id
            local roomType = RoomProxy.getRoomTypeByMatchId(matchId)
            if roomType == RoomConfig.ROOM_TYPE_METIER_ROOM then
                RoomProxy.getInstance():gotoMetierRoom(matchId)
            end
            self.mMatchNoticeView:dismiss()
        end
    end
    local roomConfig = RoomConfig.getInstance();
    local matchId = data.match_id
    local config = RoomConfig.getInstance():getMatchRoomConfig(matchId)
    if config then 
        self.mMatchNoticeView:setHeadUrl(config.img_url)
    end
    self.mMatchNoticeView:setConfirmType(data.confirm_type,obj,func)
    self.mMatchNoticeView:setText(data.notify_context)
    self.mMatchNoticeView:show(data.show_time)
end

CompeteController.onRecvServerCheckUserState = function(self, packetInfo)
    EventDispatcher.getInstance():dispatch(Event.Call,kStranger_isOnline,packetInfo);
end

CompeteController.onHallMsgCreateRoom = function(self, info)

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
        ChessDialogManager.dismissAllDialog(); 
        ToolKit.schedule_once(self,function() 
            RoomProxy.getInstance():setTid(info.tid);
            UserInfo.getInstance():setCustomRoomID(info.tid);
            RoomProxy.getInstance():gotoPrivateRoom(true)    
        end,170)
    elseif UserInfo.getInstance():getCustomRoomType() == 2 then
        RoomProxy.getInstance():setTid(info.tid);
        UserInfo.getInstance():setCustomRoomID(info.tid)
    end
end


CompeteController.onRecvServerIsActAvaliable = function(self, packetInfo)
    if packetInfo.status == 0 then
        EventDispatcher.getInstance():dispatch(Event.Call,kIsAvaliableChessMatch,packetInfo);
    elseif packetInfo.status == -1 then
        if packetInfo.check_uid == UserInfo.getInstance():getUid() then
            ChessToastManager.getInstance():showSingle("您已经有个约战了"); 
        else
            ChessToastManager.getInstance():showSingle("该玩家正在约战"); 
        end
    end
end


CompeteController.s_cmdConfig = 
{
	[CompeteController.s_cmds.back_action] = CompeteController.onBack,
}

CompeteController.s_socketCmdFuncMap = 
{
	[COMPETE_SIGN_BEGIN] = CompeteController.onServerSignBegin,
	[COMPETE_DELAY_SIGN_END] = CompeteController.onServerDelaySignEnd,
	[COMPETE_MATCH_START] = CompeteController.onServerMatchStart,
	[COMPETE_LATE_ENTER_END] = CompeteController.onServerLateEnterEnd,
	[LOGIN_MATCH_RESPONSE] = CompeteController.onServerEnterMatch,
	[SERVER_RETURNS_PLAYER_STATUS] = CompeteController.onServerGetSelfStatus,
	[COMPETE_WATCH_LIST_RESPONSE] = CompeteController.onServerWatchList,
    [HALL_MSG_GAMEPLAY]         =  CompeteController.onHallMsgGamePlay;
    [FASTMATCH_SIGN_UP_LIST] =  CompeteController.onFastmatchGetSignupInfo;
    [MATCH_START_REMINDER]              = CompeteController.onMatchStartReminder;
    
    --聊天室私人房邀请
    [FRIEND_CMD_GET_USER_STATUS]            = CompeteController.onRecvServerCheckUserState;   --发起挑战请求
    [CLIENT_HALL_CREATE_PRIVATEROOM]        = CompeteController.onHallMsgCreateRoom; -- 聊天室创建私人房回调
    -- 聊天室动作是否可行
    [CHATROOM_CMD_IS_ACT_AVALIABLE]         = CompeteController.onRecvServerIsActAvaliable;
}

CompeteController.s_httpRequestsCallBackFuncMap = 
{
	[HttpModule.s_cmds.getMatchList] = CompeteController.onHttpMatchList,
	[HttpModule.s_cmds.joinMatch] = CompeteController.onHttpJoinMatch,
	[HttpModule.s_cmds.exitMatch] = CompeteController.onHttpExitMatch,
	[HttpModule.s_cmds.matchStatus] = CompeteController.onHttpMatchStatus,
}

CompeteController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	CompeteController.s_socketCmdFuncMap or {})

CompeteController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	CompeteController.s_httpRequestsCallBackFuncMap or {})








