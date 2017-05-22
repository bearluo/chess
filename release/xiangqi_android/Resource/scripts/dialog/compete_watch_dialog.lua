require(VIEW_PATH .. "compete_watch_view")
require(MODEL_PATH .. "compete/item/competeWatchItem")

CompeteWatchDialog = class(ChessDialogScene, false)

CompeteWatchDialog.ctor = function( self, itemData )
	super(self, compete_watch_view)
	self.anim_dlg = AnimDialogFactory.createNormalAnim(self)
	self.itemData = itemData

	self:initControl()
	self:initView()
end

CompeteWatchDialog.dtor = function( self )
	self.anim_dlg:stopAnim()
	self:stopTimer()
end

CompeteWatchDialog.show = function( self )
	self.super.show(self, self.anim_dlg.showAnim)
	--self:initView()--t
	self:getWatchList()
end

CompeteWatchDialog.dismiss = function( self )
	self.super.dismiss(self, self.anim_dlg.dismissAnim)
end

CompeteWatchDialog.initControl = function( self )
	local top_view = self.m_root:getChildByName("top_view")
	self.btn_close = top_view:getChildByName("btn_close")
	self.txt_time = top_view:getChildByName("txt_time")
	self.scroll_view = self.m_root:getChildByName("scroll_view")
	self.empty_view = self.m_root:getChildByName("empty_view")
    self.empty_view:setVisible(false)
    local w,h = self.scroll_view:getSize();
    self.mLeftDownRefreshView = new(DownRefreshView,0,0,w,h);
    self.mLeftDownRefreshView:setRefreshListener(self,self.getWatchList);
    self.scroll_view:addChild(self.mLeftDownRefreshView);

	-- set click
	self.btn_close:setOnClick(self, self.onCloseClick)
end

CompeteWatchDialog.initView = function( self )
--	local datas = {}
--	for i=1, 6 do
--		local data = {}
--		data.redId = 10000438
--		data.redLife = 999
--		data.blackId = 10000439
--		data.blackLife = 999
--		data.num = 3
--		data.lastTime = "157"
--		table.insert(datas, data)
--	end

--	self:refreshList(datas)
	self:startEndTimer()
end

-- 获取观战列表
CompeteWatchDialog.getWatchList = function( self )
	local info = {}
	info.uid = UserInfo.getInstance():getUid()
	info.match_id = self.itemData.match_id
	info.level = tonumber(self.itemData.level)

	Log.d("getWatchList")
	OnlineSocketManager.getHallInstance():sendMsg(COMPETE_WATCH_LIST, info)
end

-- 刷新观战列表数据
CompeteWatchDialog.refreshList = function( self, datas )
	for i, data in ipairs(datas) do
        --- 这里需要拼一个比赛id 数据
        data.matchId = self.itemData.match_id
	end
    self.mLeftDownRefreshView:refreshEnd(datas,function(value)
		return new(CompeteWatchItem, value)
    end)
    if #datas > 0 then
        self.empty_view:setVisible(false)
    else
        self.empty_view:setVisible(true)
    end
end

-- 刷新结束时间
CompeteWatchDialog.startEndTimer = function( self )
	self.endTime = self.itemData.match_end_time
	self:updateEndTime()
	
	delete(self.timer)
	self.timer = new(AnimInt, kAnimRepeat, 0, 1, 1000, -1)
	self.timer:setDebugName("CompeteWatchDialog|timer")
	self.timer:setEvent(self, self.updateEndTime)
end

CompeteWatchDialog.updateEndTime = function( self )
	local curTime = TimerHelper.getServerCurTime()
	if curTime > self.endTime then
		self:stopTimer()
		-- end match
		return
	end

	local diff = self.endTime - curTime
	--local str = self:getTimeStr(diff)
	local str = ToolKit.skipTime(diff)
	self.txt_time:setText(str)
end

CompeteWatchDialog.stopTimer = function( self )
	delete(self.timer)
	self.timer = nil
end

CompeteWatchDialog.getTimeStr = function( self, t )
	local day = math.floor(t / (24*60*60))
	t = t % (24*60*60)
	local hour = math.floor(t / (60*60))
	t = t % (60*60)
	local min = math.floor(t / 60)
	local sec = t % 60

	local str = ""
	if day > 0 then
		str = string.format("%s%d天", str, day)
	end
	if hour > 0 then
		str = string.format("%s%02d时", str, hour)
	end
	str = string.format("%s%02d分", str, min)
	str = string.format("%s%02d秒", str, sec)
	return str
end

-- 请求指定的观战列表
CompeteWatchDialog.setItemData = function( self, itemData )
	self.itemData = itemData
end

CompeteWatchDialog.onCloseClick = function( self )
	self:dismiss()
end






