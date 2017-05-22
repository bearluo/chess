require(BASE_PATH .. "chessScene")
require(MODEL_PATH .. "compete/item/competeItem")

CompeteScene = class(ChessScene)

CompeteScene.s_controls = 
{
	txt_score 	= 1,
	txt_gold 	= 2,
	txt_winrate = 3,
	list_view 	= 4,
	btn_back 	= 5,
	btn_help 	= 6,
    empty_view  = 7,
    content_view = 8,
    top_view    = 9,
}

CompeteScene.s_cmds = 
{
	match_list = 1,
	join_match = 2,
	exit_match = 3,
	match_status = 4,
	open_watch = 5,
	watch_list = 6,
	user_status = 7,
    update_room_players = 8,
    show_match_dialog = 9,
    update_fastmatch_signup_info = 10,
}

CompeteScene.s_join_match_chat_room_id = nil
CompeteScene.s_join_match_rank_room_id = nil
CompeteScene.s_join_match_match_room_id = nil

CompeteScene.s_join_match_room_id = nil
CompeteScene.ctor = function( self, viewConfig, controller )
	self.m_ctrls = CompeteScene.s_controls
	self:initControl()
	self:updateUserInfo()
end

CompeteScene.resume = function( self )
	ChessScene.resume(self)
	self:updateUserInfo();
    if kPlatform == kPlatformIOS then
        if GameCacheData.getInstance():getBoolean(GameCacheData.GET_NOTICE_AUTHOR,true) then
            GameCacheData.getInstance():saveBoolean(GameCacheData.GET_NOTICE_AUTHOR,false);
            ChessToastManager.getInstance():showSingle("授权比赛通知，可避免错过比赛，损失金币",3000);
            ToolKit.schedule_once(self,function() 
                call_native(kGetIosNoticeAuthor);
            end,3000);
        end;
    end;
end

CompeteScene.pause = function( self )
	ChessScene.pause(self)
    if self.watchDlg then
        self.watchDlg:dismiss()
    end
    if self.helpDlg then
        self.helpDlg:dismiss()
    end
end

CompeteScene.dtor = function( self )
    delete(self.watchDlg)
    self.watchDlg = nil

    delete(self.helpDlg)
    self.helpDlg = nil
    delete(CompeteScene.s_competeItem)
end

CompeteScene.initControl = function( self )
	self.txt_score = self:findViewById(self.m_ctrls.txt_score)
	self.txt_gold = self:findViewById(self.m_ctrls.txt_gold)
	self.txt_winrate = self:findViewById(self.m_ctrls.txt_winrate)
	self.list_view = self:findViewById(self.m_ctrls.list_view)
	self.empty_view = self:findViewById(self.m_ctrls.empty_view)
	self.content_view = self:findViewById(self.m_ctrls.content_view)
    self.loading_view = AnimLoadingFactory.createChessLoadingAnimView()
    self.loading_view:setAlign(kAlignCenter)
    self.loading_view:setPos(nil,-20)
    self.content_view:addChild(self.loading_view)
    self.loading_view:start()
    self.empty_view:setVisible(false)

    self.m_top_view = self:findViewById(self.m_ctrls.top_view)
    self.m_left_leaf = self.m_top_view:getChildByName("bamboo_left");
    self.m_right_leaf = self.m_top_view:getChildByName("bamboo_right");
    self.m_left_leaf:setFile("common/decoration/left_leaf.png")
    self.m_right_leaf:setFile("common/decoration/right_leaf.png")
    
    local w,h = self.list_view:getSize();
    self.mDownRefreshView = new(DownRefreshView,0,0,w,h);
    self.mDownRefreshView:setRefreshListener(self,function(self)
        HttpModule.getInstance():execute(HttpModule.s_cmds.getMatchList)
        self.loading_view:start()
        self.loading_view:setVisible(true)
        self.empty_view:setVisible(false)
    end);
    self.list_view:addChild(self.mDownRefreshView);
end

CompeteScene.updateUserInfo = function( self )
	local strScore = UserInfo.getInstance():getScore()
	local strMoney = UserInfo.getInstance():getMoneyStr()
	local strRate = UserInfo.getInstance():getRate()

	self.txt_score:setText("积分:" .. strScore)
	self.txt_gold:setText(strMoney)
	self.txt_winrate:setText("胜率:" .. strRate)
end

-- 刷新整个列表
CompeteScene.refreshListData = function( self, datas )
	if not datas or #datas == 0 then
        self.empty_view:setVisible(true)
        self.mDownRefreshView:refreshEnd({},function(itemData)
            return new(CompeteItem,itemData)
        end)
        CompeteScene.s_join_match_chat_room_id = nil
        CompeteScene.s_join_match_room_id = nil
        CompeteScene.s_join_match_rank_room_id = nil
        CompeteScene.s_join_match_match_room_id = nil
		return
	end
    self.empty_view:setVisible(false)

	-- 把该类本身的引用填入数据中
	local dataArray = {}
	for _, data in ipairs(datas) do
		local unit = {}
		unit.parent = self
		unit.data = data
		table.insert(dataArray, unit)
	end

    if CompeteScene.s_join_match_room_id then 
        CompeteScene.s_join_match_chat_room_id = nil
        CompeteScene.s_join_match_rank_room_id = nil
        CompeteScene.s_join_match_match_room_id = nil
    end
    self.mDownRefreshView:refreshEnd(dataArray,function(itemData)
        return new(CompeteItem,itemData)
    end)
    
    if CompeteScene.s_join_match_chat_room_id then
        local dialog = self:onShowMatchDialog(CompeteScene.s_join_match_chat_room_id,dataArray)
        if dialog and dialog.showChatView then
            dialog:showChatView()
        end
        CompeteScene.s_join_match_chat_room_id = nil
    end

    if CompeteScene.s_join_match_rank_room_id then
        local dialog = self:onShowMatchDialog(CompeteScene.s_join_match_rank_room_id,dataArray)
        if dialog and dialog.showRankView then
            dialog:showRankView()
        end
        CompeteScene.s_join_match_rank_room_id = nil
    end

    if CompeteScene.s_join_match_match_room_id then
        local dialog = self:onShowMatchDialog(CompeteScene.s_join_match_match_room_id,dataArray)
        if dialog and dialog.showMatchView then
            dialog:showMatchView()
        end
        CompeteScene.s_join_match_match_room_id = nil
    end

    local roomConfig = RoomConfig.getInstance();
    local matchId = CompeteScene.s_join_match_room_id
    CompeteScene.s_join_match_room_id = nil
    local roomType = RoomProxy.getRoomTypeByMatchId(matchId)
    if roomType == RoomConfig.ROOM_TYPE_METIER_ROOM then
        RoomProxy.getInstance():gotoMetierRoom(matchId)
    end

end

CompeteScene.onShowMatchDialog = function(self,matchId,datas)
 -- 这里写的有些太搓了  暂时这样吧
    local dialog 
    for i, data in ipairs(datas or {}) do
		if data.data.match_id == matchId then
            delete(CompeteScene.s_competeItem)
            CompeteScene.s_competeItem = new(CompeteItem,data)
            dialog = CompeteScene.s_competeItem:showDialogs()
		end
	end
    if dialog then
	    local views = self.mDownRefreshView:getViewTab()
        for i, view in pairs(views) do
            view:dismissDialogs()
        end
    end
    return dialog
end

-- 报名后更新列表项的状态
CompeteScene.updateItemData = function( self, match_id, meStatus, joinNum )
	if not match_id then
		return
	end

	local datas = self.mDownRefreshView:getViewData()
	local views = self.mDownRefreshView:getViewTab()
	for i, data in ipairs(datas or {}) do
		if data.match_id == match_id then
			-- meStatus 1:未报名 2:已报名
			data.me_status = meStatus
			data.join_num = joinNum
			local itemView = views[i]
			if itemView then
				itemView:refresh(data)
			end
		end
	end
end

-- 打开观战界面
CompeteScene.openWatchDialog = function( self, itemData )
	if not itemData or not next(itemData) then
		return
	end

	if not self.watchDlg then
		self.watchDlg = new(CompeteWatchDialog, itemData)
	end
	self.watchDlg:setItemData(itemData)
	self.watchDlg:show()
end

-- btn event---------------------------------------------
-- 返回
CompeteScene.onBackClick = function( self )
	self:requestCtrlCmd(CompeteController.s_cmds.back_action)
end

-- 帮助
CompeteScene.onHelpClick = function( self )
	 if not self.helpDlg then
	 	self.helpDlg = new(CommonHelpDialog)
	 	self.helpDlg:setMode(CommonHelpDialog.MATCH_CONTEXT)
	 end
	 self.helpDlg:show();
end

-- callback ---------------------------------------------
CompeteScene.onHttpMatchList = function( self, isSuccess, message )
    self.loading_view:stop()
    self.loading_view:setVisible(false)
	if not isSuccess then
	    self:refreshListData({});
		-- tip
		return
	end
    local data = json.analyzeJsonNode(message.data);
    TimerHelper.setServerCurTime(message.time:get_value() or 0)
	self:refreshListData(data);
end

-- 报名php回调
CompeteScene.onHttpJoinMatch = function( self, isSuccess, message )
	Log.d("onHttpJoinMatch")
	Log.d(isSuccess)
	Log.d(message)

	if HttpModule.explainPHPMessage(isSuccess, message, "报名失败") then
		return
	end

	-- update list data
	local match_id = message.data.match_id
	local join_num = message.data.join_num
    UserInfo.getInstance():setMoney(message.data.money:get_value())
    self:updateUserInfo()
	self:updateItemData(match_id, 2, join_num)
end

-- 取消报名php回调
CompeteScene.onHttpExitMatch = function( self, isSuccess, message )
	Log.d("onHttpExitMatch")
	Log.d(isSuccess)
	Log.d(message)
	
	if HttpModule.explainPHPMessage(isSuccess, message, "取消报名失败") then
		return
	end

	-- update list data
	local match_id = message.data.match_id
	local join_num = message.data.join_num
    UserInfo.getInstance():setMoney(message.data.money:get_value())
    self:updateUserInfo()
	self:updateItemData(match_id, 1, join_num)
end

-- 定时更新比赛信息 人数/状态
CompeteScene.onHttpMatchStatus = function( self, isSuccess, message )
	Log.d("onHttpMatchStatus")
	Log.d(isSuccess)
	Log.d(message)
	
	if not isSuccess then
		return
	end

	local datas = json.analyzeJsonNode(message.data) or {}
    
	local itemDatas = self.mDownRefreshView:getViewData()
	local views = self.mDownRefreshView:getViewTab()
    for i, itemData in ipairs(itemDatas) do
        local matchId = itemData.data.match_id
        local isExistence = false
        for _, data in ipairs(datas) do
            if data.match_id == matchId then
                isExistence= true
				itemData.data.match_status = data.match_status;
				itemData.data.sign_status = data.sign_status;
				itemData.data.me_status = data.me_status;
				itemData.data.join_num = data.join_num;
                local view = views[i]
				if view then
					view:refresh(itemData.data)
				end
                break
            end
        end
        -- 比赛已不存在
        if not isExistence then
			itemData.data.match_status = 4;
			itemData.data.sign_status = 3;
			itemData.data.me_status = 3;
			itemData.data.join_num = 0;
            local view = views[i]
			if view then
				view:refresh(itemData.data)
			end
        end
    end
end

-- 报名人数
function CompeteScene:onServerUpdateRoomPlayers(datas)
    local itemDatas = self.mDownRefreshView:getViewData()
	local views = self.mDownRefreshView:getViewTab()
    for i, itemData in ipairs(itemDatas) do
        local level = itemData.data.level
        for key, v in pairs(datas) do
            if key == tonumber(level) then
				itemData.data.player_num = tonumber(v) or 0
                local view = views[i]
				if view then
					view:refreshCoinNum(itemData.data.player_num)
				end
                break
            end
        end
    end
end

-- 报名人数
function CompeteScene:onUpdateFastmatchSignupInfo(datas)
    local itemDatas = self.mDownRefreshView:getViewData()
	local views = self.mDownRefreshView:getViewTab()
    for i, itemData in ipairs(itemDatas) do
        local level = itemData.data.level
        if datas.level == tonumber(level) then
			itemData.data.join_num = tonumber(datas.num) or 0
            local view = views[i]
			if view then
				view:refreshCoinJoinNum(itemData.data.join_num)
			end
            break
        end
    end
end
-- 观战数据返回，刷新
CompeteScene.onServerWatchList = function( self, info )

	local datas = info.deskArray or {}
	if self.watchDlg then
		self.watchDlg:refreshList(datas)
	end
end

-- 刷新报名界面的排名状态
CompeteScene.onServerUserStatus = function( self, info )
	if not info or not next(info) then
		return
	end

	if not next(datas) then
		return
	end

	--do
end

CompeteScene.s_controlConfig = 
{
	[CompeteScene.s_controls.txt_score] = { "top_view", "user_info_view", "txt_score" },
	[CompeteScene.s_controls.txt_gold] = { "top_view", "user_info_view", "txt_gold" },
	[CompeteScene.s_controls.txt_winrate] = { "top_view", "user_info_view", "txt_winrate" },
	[CompeteScene.s_controls.content_view] = { "content_view" },
	[CompeteScene.s_controls.list_view] = { "content_view", "list_view" },
	[CompeteScene.s_controls.empty_view] = { "content_view", "empty_view" },
	[CompeteScene.s_controls.btn_back] = { "back_btn" },
	[CompeteScene.s_controls.btn_help] = { "top_view", "help_btn" },
	[CompeteScene.s_controls.top_view] = { "top_view" },

       
}

CompeteScene.s_controlFuncMap = 
{
	[CompeteScene.s_controls.btn_back] = CompeteScene.onBackClick,
	[CompeteScene.s_controls.btn_help] = CompeteScene.onHelpClick,
}

CompeteScene.s_cmdConfig = 
{
	[CompeteScene.s_cmds.match_list] = CompeteScene.onHttpMatchList,
	[CompeteScene.s_cmds.join_match] = CompeteScene.onHttpJoinMatch,
	[CompeteScene.s_cmds.exit_match] = CompeteScene.onHttpExitMatch,
	[CompeteScene.s_cmds.match_status] = CompeteScene.onHttpMatchStatus,
	[CompeteScene.s_cmds.open_watch] = CompeteScene.openWatchDialog,
	[CompeteScene.s_cmds.watch_list] = CompeteScene.onServerWatchList,
	[CompeteScene.s_cmds.user_status] = CompeteScene.onServerUserStatus,
    [CompeteScene.s_cmds.update_room_players] = CompeteScene.onServerUpdateRoomPlayers,
    [CompeteScene.s_cmds.update_fastmatch_signup_info] = CompeteScene.onUpdateFastmatchSignupInfo,
    [CompeteScene.s_cmds.show_match_dialog] = CompeteScene.onShowMatchDialog,
}


