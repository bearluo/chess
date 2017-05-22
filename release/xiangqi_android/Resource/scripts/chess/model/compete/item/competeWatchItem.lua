require(VIEW_PATH .. "compete_watch_item")

CompeteWatchItem = class(Node)

CompeteWatchItem.ctor = function( self, data )
	self:loadView()
	self:initControl()
	self:refresh(data)
end

CompeteWatchItem.dtor = function( self )
	self:stopTimer()
end

CompeteWatchItem.loadView = function( self )
	self.root_view = SceneLoader.load(compete_watch_item)
	self.root_view:setAlign(kAlignCenter)
	self:addChild(self.root_view)
	self:setSize(self.root_view:getSize())
end

CompeteWatchItem.initControl = function( self )
	local root = self.root_view
	self.btn_item = root:getChildByName("btn_item")
	local left_view = self.btn_item:getChildByName("left_view")
	local right_view = self.btn_item:getChildByName("right_view")
	local bottom_view = root:getChildByName("bottom_view")

	-- left
	self.txt_name_left = left_view:getChildByName("txt_name")
	self.txt_life_left = left_view:getChildByName("txt_life")
	self.btn_head_left = left_view:getChildByName("btn_head")
	self.img_level_left = left_view:getChildByName("img_level")

	-- right
	self.txt_name_right = right_view:getChildByName("txt_name")
	self.txt_life_right = right_view:getChildByName("txt_life")
	self.btn_head_right = right_view:getChildByName("btn_head")
	self.img_level_right = right_view:getChildByName("img_level")

	-- bottom
	self.txt_watch = bottom_view:getChildByName("txt_watch")
	self.txt_time = bottom_view:getChildByName("txt_time")

	-- set click
	--self.btn_head_left:setOnClick(self, self.onHeadClick)
	--self.btn_head_right:setOnClick(self, self.onHeadClick)
	self.btn_item:setOnClick(self, self.onItemClick)
    self.btn_item:setSrollOnClick()
end

CompeteWatchItem.refresh = function( self, data )
	if not data or not next(data) then
		return
	end
	self.data = data

	-- red as left
	self.txt_life_left:setText("生命:" .. data.redLife)
	-- black as right
	self.txt_life_right:setText("生命:" .. data.blackLife)

	-- bottom
	self.txt_watch:setText("观战人数:" .. data.num)

	self:startLastTimer()
    
	local param = { mid_arr = {} }
    param.mid_arr["mid1"] = data.redId;
    param.mid_arr["mid2"] = data.blackId;
	HttpModule.getInstance():execute2(HttpModule.s_cmds.getFriendUserInfo, param, 
		function( isSuccess, resultStr )
			if not isSuccess then
				-- tip
				return
			end

			local jsonData = json.decode(resultStr)
			local infos = jsonData.data or {}
			Log.d("getFriendUserInfo-infos")
			Log.d(infos)--?
			self:refreshRedInfo(infos[tostring(data.redId)])
			self:refreshBlackInfo(infos[tostring(data.blackId)])
		end)
    local redData = FriendsData.getInstance():getUserData(data.redId)
    local blackData = FriendsData.getInstance():getUserData(data.blackId)
    if redData then
		self:refreshRedInfo(redData)
    end
    if blackData then
		self:refreshBlackInfo(blackData)
    end
end

-- 刷新红方信息
CompeteWatchItem.refreshRedInfo = function( self, info )
	if not info or not next(info) then
		return
	end

	self.txt_name_left:setText(info.mnick or "博雅象棋")
    if not self.redfriendsinfo_icon then
	    self.redfriendsinfo_icon = new(Mask,UserInfo.DEFAULT_ICON[1],"common/background/head_mask_bg_150.png");
        self.redfriendsinfo_icon:setAlign(kAlignCenter);
        self.redfriendsinfo_icon:setSize(self.btn_head_left:getSize());
        self.btn_head_left:addChild(self.redfriendsinfo_icon);
    end
    if tonumber(info.iconType) == -1 then
        self.redfriendsinfo_icon:setUrlImage(info.icon_url)
    else
        local icon = tonumber(info.iconType) or 1
        self.redfriendsinfo_icon:setFile(UserInfo.DEFAULT_ICON[icon] or UserInfo.DEFAULT_ICON[1])
    end

	local level = UserInfo.getInstance():getDanGradingLevelByScore(info.score)
	local path = string.format("common/icon/level_%d.png", 10 - level)
	self.img_level_left:setFile(path)
end

-- 刷新黑方信息
CompeteWatchItem.refreshBlackInfo = function( self, info )
	if not info or not next(info) then
		return
	end

	self.txt_name_right:setText(info.mnick or "博雅象棋")
    if not self.blackfriendsinfo_icon then
	    self.blackfriendsinfo_icon = new(Mask,UserInfo.DEFAULT_ICON[1],"common/background/head_mask_bg_150.png");
        self.blackfriendsinfo_icon:setAlign(kAlignCenter);
        self.blackfriendsinfo_icon:setSize(self.btn_head_right:getSize());
        self.btn_head_right:addChild(self.blackfriendsinfo_icon);
    end
    if tonumber(info.iconType) == -1 then
        self.blackfriendsinfo_icon:setUrlImage(info.icon_url)
    else
        local icon = tonumber(info.iconType) or 1
        self.blackfriendsinfo_icon:setFile(UserInfo.DEFAULT_ICON[icon] or UserInfo.DEFAULT_ICON[1])
    end

	local level = UserInfo.getInstance():getDanGradingLevelByScore(info.score)
	local path = string.format("common/icon/level_%d.png", 10 - level)
	self.img_level_right:setFile(path)
end

CompeteWatchItem.startLastTimer = function( self )
	self.lastTime = self.data.lastTime
	self:updateLastTime()

	self:stopTimer()
	self.timer = new(AnimInt, kAnimRepeat, 0, 1, 1000, -1)
	self.timer:setDebugName("CompeteWatchItem|timer")
	self.timer:setEvent(self, self.updateLastTime)
end

CompeteWatchItem.updateLastTime = function( self )
	local str = ToolKit.skipTime(self.lastTime)
	self.txt_time:setText("已进行:" .. str)
	self.lastTime = self.lastTime + 1
end

CompeteWatchItem.stopTimer = function( self )
	delete(self.timer)
	self.timer = nil
end

-- btn event -------------------------------------------
CompeteWatchItem.onItemClick = function( self )
	-- table id
	-- 根据桌子id进入房间
    RoomProxy.getInstance():gotoMetierRoomByWatch(self.data.matchId,self.data.tid)
end

CompeteWatchItem.onHeadClick = function( self )
	--
end




