require(VIEW_PATH .. "compete_item_view")
require(DIALOG_PATH .. "compete_info_dialog")
require(DIALOG_PATH .. "compete_watch_dialog")
require(DIALOG_PATH .. "compete_coin_dialog")

CompeteItem = class(Node)

CompeteItem.JOIN     = 1;
CompeteItem.HAS_JOIN = 2;
CompeteItem.ENTRY    = 3;
CompeteItem.WATCH    = 4;
CompeteItem.WAITING  = 5;
CompeteItem.OVER     = 6;
CompeteItem.ERROR    = 7;

CompeteItem.ctor = function( self, data )
    self.mCoinJoinNum = 0
	self:loadView()
	self:initControl()
	self.parent = data.parent
	self:refresh(data.data)
end

CompeteItem.dtor = function( self )
	-- body
    delete(self.m_join_dlg)
    delete(self.m_coin_dlg)
    self:stopAnimDown()
end

CompeteItem.loadView = function( self )
	self.root_view = SceneLoader.load(compete_item_view)
	self.root_view:setAlign(kAlignCenter)
	self:addChild(self.root_view)
	self:setSize(self.root_view:getSize())
end

CompeteItem.initControl = function( self )
	local left_view = self.root_view:getChildByName("left_view")
	local middle_view = self.root_view:getChildByName("middle_view")
	local right_view = self.root_view:getChildByName("right_view")
	
	self.btn_icon = left_view:getChildByName("btn_icon")
    self.m_icon_frame =  left_view:getChildByName("icon_frame");
	self.txt_name = middle_view:getChildByName("txt_name")
	self.txt_desc = middle_view:getChildByName("txt_desc")
	self.txt_num = middle_view:getChildByName("txt_num")
	self.txt_limit = middle_view:getChildByName("txt_limit")

    -- join(报名)
    self.m_join = right_view:getChildByName("join");
    self.m_join_btn = self.m_join:getChildByName("btn");
    self.m_join_btn:setSrollOnClick();
    self.m_join_btn:setOnClick(self, self.onJoinBtnClick);
    self.m_join_txt = self.m_join:getChildByName("txt_coin");

    -- has_join(已报名)
    self.m_has_join = right_view:getChildByName("has_join");
    self.m_has_join_btn = self.m_has_join:getChildByName("btn");
    self.m_has_join_btn:setSrollOnClick();
    self.m_has_join_btn:setOnClick(self, self.onHasJoinBtnClick);

    -- entry(入场)
    self.m_entry = right_view:getChildByName("entry");
    self.m_entry_btn = self.m_entry:getChildByName("btn");
    self.m_entry_btn:setSrollOnClick();
    self.m_entry_btn:setOnClick(self, self.onEntryBtnClick);

    -- watch(观战)
    self.m_watch = right_view:getChildByName("watch");
    self.m_watch_btn = self.m_watch:getChildByName("btn");
    self.m_watch_btn:setSrollOnClick();
    self.m_watch_btn:setOnClick(self, self.onWatchBtnClick);

    -- waiting(即将开始)
    self.m_waiting = right_view:getChildByName("waiting");
    self.m_waiting_btn = self.m_waiting:getChildByName("btn");
    self.m_waiting_btn:setSrollOnClick();
    self.m_waiting_btn:setOnClick(self, self.onWaitingBtnClick);
    self.m_waiting_txt = self.m_waiting:getChildByName("txt_coin");

    -- over(已结束)
    self.m_over = right_view:getChildByName("over");
    self.m_over_btn = self.m_over:getChildByName("btn");
    self.m_over_btn:setSrollOnClick();
    self.m_over_btn:setOnClick(self, self.onOverBtnClick);

    -- item左半部分按钮（弹窗）
    self.m_left_btn = self.root_view:getChildByName("left_btn");
    self.m_left_btn:setSrollOnClick();
    self.m_left_btn:setOnClick(self,self.onLeftBtnClick);
    self.m_left_btn:setSrollOnClick(nil,function() end)
end

CompeteItem.onLeftBtnClick = function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
    self.data.itemStatus = self.m_item_status;
    self:showDialogs();
end;

CompeteItem.refresh = function( self, data )
	Log.d("zzc")
	Log.d(data)

	if not data or not next(data) then
		return
	end
	self.data = data

	-- 图标
    local iconUrl = data.img_url;
    if tonumber(data.type) == 12 then -- 金币赛
        self.btn_icon:setVisible(true);
        self.m_icon_frame:setVisible(false);
        self.btn_icon:setUrlImage(iconUrl or "")
        -- 开赛人数/时间
	    local limit = data.least_num or "-"
	    local strLimit = string.format("最低%s人开赛", limit)
	    self.txt_limit:setText(strLimit)
    elseif tonumber(data.type) == 13 then -- 职业赛
        self.btn_icon:setVisible(false);
        self.m_icon_frame:setVisible(true);
        if not self.m_icon then 
        self.m_icon = new(Mask,UserInfo.DEFAULT_ICON[1], "common/background/head_mask_bg_110.png")
        self.m_icon:setAlign(kAlignCenter);
        self.m_icon:setSize(100,100);
        self.m_icon:setUrlImage(iconUrl or "");
        self.m_icon_frame:addChild(self.m_icon);
        end
        local matchStartTime =  tonumber(data.match_start_time) or 0
        local matchEndTime =  tonumber(data.match_end_time) or 0
        local prefix = ToolKit.get_match_time_str_prefix(matchStartTime)
        local startTime = ToolKit.getDate(matchStartTime)
        local endTime = ToolKit.getDate(matchEndTime)
        local timeString = string.format("%s %02d:%02d 开赛",prefix,startTime.hour,startTime.min)
	    self.txt_limit:setText(timeString)
        self:startAnimDown(matchStartTime)
    elseif tonumber(data.type) == 14 then -- 名人赛
        self.btn_icon:setVisible(true);
        self.m_icon_frame:setVisible(false);
        self.btn_icon:setUrlImage(iconUrl or "")
        local matchStartTime =  tonumber(data.match_start_time) or 0
        local matchEndTime =  tonumber(data.match_end_time) or 0
        local prefix = ToolKit.get_match_time_str_prefix(matchStartTime)
        local startTime = ToolKit.getDate(matchStartTime)
        local endTime = ToolKit.getDate(matchEndTime)
        local timeString = string.format("%s %02d:%02d 开赛",prefix,startTime.hour,startTime.min)
	    self.txt_limit:setText(timeString)
        self:startAnimDown(matchStartTime)
    end;

    -- 名字
	self.txt_name:setText(data.name or "-")

	-- 赛制
	local round_time = data.round_time or 0
	round_time = math.ceil(tonumber(round_time) / 60)
	local strDesc = string.format("%d分钟赛制", round_time)
	self.txt_desc:setText(strDesc)

	-- 人数
    
    if tonumber(data.type) ~= 12 then -- 金币赛
	    local strNum = data.join_num or "0"
	    self.txt_num:setText(strNum)
    else
	    local strNum = data.player_num or "0"
	    self.txt_num:setText(strNum)
    end

	-- 右侧，比赛报名状态
	local match_status = data.match_status or -1
	local sign_status = data.sign_status or -1
	local me_status = data.me_status or -1
	self:updateRightViewStatus(match_status, sign_status, me_status)
    self:updateDialogBtnStatus(self.m_item_status);
    self:updateDialogMatchStatus(match_status, sign_status, me_status)
    
    if tonumber(self.data.type) == 12 then 
        if self.m_coin_dlg then
            data.join_num = self.mCoinJoinNum
            self.m_coin_dlg:refresh(data);
        end;    
    elseif  tonumber(self.data.type) == 13 then 
        if self.m_join_dlg then
            self.m_join_dlg:refresh(data);
        end;    
    elseif tonumber(self.data.type) == 14 then 
        if self.m_join_dlg then
            self.m_join_dlg:refresh(data);
        end        
    end
    
    if tonumber(self.data.type) == 12 and self.data.level then 
        local info = {}
        table.insert(info,self.data.level)
        OnlineSocketManager.getHallInstance():sendMsg(HALL_MSG_GAMEPLAY,info, SUBCMD_LADDER ,2);
        local info = {}
        info.level = self.data.level
        OnlineSocketManager.getHallInstance():sendMsg(FASTMATCH_SIGN_UP_LIST,info);
    end
end

function CompeteItem:startAnimDown(matchStartTime)
    self.mMatchStartTime = tonumber(matchStartTime)
    if not self.mMatchStartTime then return end
    self:stopAnimDown()
    self:onCountDownEvent()
    TimerHelper.registerSecondEvent(self,self.onCountDownEvent)
end

function CompeteItem:stopAnimDown()
    TimerHelper.unregisterSecondEvent(self,self.onCountDownEvent)
end

function CompeteItem:onCountDownEvent()
    if not self.mMatchStartTime then return end
    local time = self.mMatchStartTime - TimerHelper.getServerCurTime()
    if time <= 0 then 
        self.txt_limit:setText("")
        self:stopAnimDown()
        return
    end
    if time <= 1800 then
        self.txt_limit:setText( string.format("%02d:%02d 后开赛",select( 1, math.modf(time/60),time%60)))
    end
end

function CompeteItem:refreshCoinNum(num)
    if tonumber(self.data.type) == 12 then 
	    local strNum = num or "0"
	    self.txt_num:setText(strNum)
    end
end

function CompeteItem:refreshCoinJoinNum(num)
    self.mCoinJoinNum = tonumber(num) or 0
    self.data.join_num = self.mCoinJoinNum
end

CompeteItem.updateRightViewStatus = function( self, match_status, sign_status, me_status )
	if match_status==-1 or sign_status==-1 or me_status==-1 then
		return
	end
	--match_status	比赛状态	1=未开始，2=比赛开始可进入，3=比赛开始不可进入，4=结束
    --sign_status	报名状态	1=未开始，2=报名进行中，    3=报名结束
	--me_status	    我的状态	1=未报名，2=已结报名，      3=被淘汰
    if match_status == 1 then
        if sign_status == 1 then
            if me_status == 1 then
            elseif me_status == 2 then
            elseif me_status == 3 then
            end;
            self:setItemRightBtnStatus(CompeteItem.WAITING);
        elseif sign_status == 2 then
            if me_status == 1 then
                self:setItemRightBtnStatus(CompeteItem.JOIN);
            elseif me_status == 2 then
                self:setItemRightBtnStatus(CompeteItem.HAS_JOIN);
            elseif me_status == 3 then
                self:setItemRightBtnStatus(CompeteItem.ERROR);
            end;
        elseif sign_status == 3 then
            if me_status == 1 then
                self:setItemRightBtnStatus(CompeteItem.JOIN);
                -- 提示报名结束
                -- ...
            elseif me_status == 2 then
                self:setItemRightBtnStatus(CompeteItem.HAS_JOIN);
            elseif me_status == 3 then
                self:setItemRightBtnStatus(CompeteItem.ERROR);
            end;
        end;
    elseif match_status == 2 then
        if tonumber(self.data.type) == 12 then
            self:setItemRightBtnStatus(CompeteItem.JOIN);
        else
            if sign_status == 1 then
                if me_status == 1 then
                elseif me_status == 2 then
                elseif me_status == 3 then
                end;
                self:setItemRightBtnStatus(CompeteItem.ERROR);
            elseif sign_status == 2 then
                if me_status == 1 then
                    self:setItemRightBtnStatus(CompeteItem.JOIN);
                elseif me_status == 2 then
                    self:setItemRightBtnStatus(CompeteItem.ENTRY);
                elseif me_status == 3 then
                    self:setItemRightBtnStatus(CompeteItem.WATCH);
                end;
            elseif sign_status == 3 then
                if me_status == 1 then
                    self:setItemRightBtnStatus(CompeteItem.WATCH);
                elseif me_status == 2 then
                    self:setItemRightBtnStatus(CompeteItem.ENTRY);
                elseif me_status == 3 then
                    self:setItemRightBtnStatus(CompeteItem.WATCH);
                end;
            end;
        end;
    elseif match_status == 3 then
        if tonumber(self.data.type) == 12 then
            self:setItemRightBtnStatus(CompeteItem.OVER);
        else
            if sign_status == 1 then
                if me_status == 1 then
                elseif me_status == 2 then
                elseif me_status == 3 then
                end;
                self:setItemRightBtnStatus(CompeteItem.ERROR);
            elseif sign_status == 2 then
                if me_status == 1 then
                elseif me_status == 2 then
                elseif me_status == 3 then
                end;
                self:setItemRightBtnStatus(CompeteItem.ERROR);
            elseif sign_status == 3 then
                if me_status == 1 then
                    self:setItemRightBtnStatus(CompeteItem.WATCH);
                elseif me_status == 2 then
                    self:setItemRightBtnStatus(CompeteItem.WATCH);
                elseif me_status == 3 then
                    self:setItemRightBtnStatus(CompeteItem.WATCH);
                end;
            end;
        end;
    elseif match_status == 4 then
        if sign_status == 1 then
            if me_status == 1 then
            elseif me_status == 2 then
            elseif me_status == 3 then
            end;
        elseif sign_status == 2 then
            if me_status == 1 then
            elseif me_status == 2 then
            elseif me_status == 3 then
            end;
        elseif sign_status == 3 then
            if me_status == 1 then
            elseif me_status == 2 then
            elseif me_status == 3 then
            end;
        end;
        self:setItemRightBtnStatus(CompeteItem.OVER)
    else
        self:setItemRightBtnStatus(CompeteItem.ERROR)
    end
end


CompeteItem.setItemRightBtnStatus = function(self, status)
    if status == CompeteItem.JOIN then
        self.m_join:setVisible(true);
        self.m_has_join:setVisible(false);
        self.m_entry:setVisible(false);
        self.m_watch:setVisible(false);
        self.m_waiting:setVisible(false);
        self.m_over:setVisible(false);
        if self.data.join_money and tonumber(self.data.join_money)~=0 then
            self:setJoinMoney(self.data.join_money);
        elseif self.data.join_ticket and tonumber(self.data.join_ticket)~=0 then
            self:setJoinTicket(self.data.join_ticket);
        end;
    elseif status == CompeteItem.HAS_JOIN then
        self.m_join:setVisible(false);
        self.m_has_join:setVisible(true);
        self.m_entry:setVisible(false);
        self.m_watch:setVisible(false);
        self.m_waiting:setVisible(false);
        self.m_over:setVisible(false);
    elseif status == CompeteItem.ENTRY then
        self.m_join:setVisible(false);
        self.m_has_join:setVisible(false);
        self.m_entry:setVisible(true);
        self.m_watch:setVisible(false);
        self.m_waiting:setVisible(false);
        self.m_over:setVisible(false);
    elseif status == CompeteItem.WATCH then
        self.m_join:setVisible(false);
        self.m_has_join:setVisible(false);
        self.m_entry:setVisible(false);
        self.m_watch:setVisible(true);
        self.m_waiting:setVisible(false);
        self.m_over:setVisible(false);
    elseif status == CompeteItem.WAITING then
        self.m_join:setVisible(false);
        self.m_has_join:setVisible(false);
        self.m_entry:setVisible(false);
        self.m_watch:setVisible(false);
        self.m_waiting:setVisible(true);
        self.m_over:setVisible(false);
        self:setWaitingTime(self.data.start_sign_time);
    elseif status == CompeteItem.OVER then
        self.m_join:setVisible(false);
        self.m_has_join:setVisible(false);
        self.m_entry:setVisible(false);
        self.m_watch:setVisible(false);
        self.m_waiting:setVisible(false);
        self.m_over:setVisible(true);
    elseif status == CompeteItem.ERROR then
        self.m_join:setVisible(false);
        self.m_has_join:setVisible(false);
        self.m_entry:setVisible(false);
        self.m_watch:setVisible(false);
        self.m_waiting:setVisible(false);
        self.m_over:setVisible(false);        
    end
    self.m_item_status = status;
end;

CompeteItem.updateDialogBtnStatus = function(self, status)
    if tonumber(self.data.type) == 12 then 
        if self.m_coin_dlg then
            self.m_coin_dlg:updateBtnStatus(status);
        end;    
    elseif  tonumber(self.data.type) == 13 then 
        if self.m_join_dlg then
            self.m_join_dlg:updateBtnStatus(status);
        end;    
    elseif tonumber(self.data.type) == 14 then 
        if self.m_join_dlg then
            self.m_join_dlg:updateBtnStatus(status);
        end;         
    end;    
end;    

function CompeteItem:updateDialogMatchStatus(match_status, sign_status, me_status)
    if tonumber(self.data.type) == 12 then 
--        if self.m_coin_dlg then
--            self.m_coin_dlg:updateBtnStatus(status);
--        end    
    elseif  tonumber(self.data.type) == 13 then 
        if self.m_join_dlg then
            self.m_join_dlg:updateMatchStatus(match_status, sign_status, me_status);
        end    
    elseif tonumber(self.data.type) == 14 then 
        if self.m_join_dlg then
            self.m_join_dlg:updateMatchStatus(match_status, sign_status, me_status);
        end         
    end
end

CompeteItem.setJoinMoney = function(self, money)
    if not money then return end;
    self.m_join_txt:setText(money.."金币");    
end;

CompeteItem.setJoinTicket = function(self, ticket)
    if not ticket then return end;
    self.m_join_txt:setText(ticket.."参赛券");    
end;

CompeteItem.setWaitingTime = function(self, time)
    if not time or not tonumber(time) then return end;
    self.m_waiting_txt:setText(os.date("%m-%d %H:%M",time));
end;

--CompeteItem.sendJoinRequest = function(self, password)
--    local data = {};
--    data.config_id = self.data.id;
--    data.match_id = self.data.match_id;
--    data.password = password;
--    HttpModule.getInstance():execute(HttpModule.s_cmds.joinMatch, data) 
--end;

-- btn event ------------------------------------------
CompeteItem.onIconClick = function( self )
	-- body
end

CompeteItem.showDialogs = function(self)
    if self.m_item_status == CompeteItem.ERROR then 
        ChessToastManager.getInstance():showSingle("比赛状态错误，请刷新后再试")
        return 
    end
    local ret = nil
    if tonumber(self.data.type) == 12 then 
        delete(self.m_coin_dlg);
        self.m_coin_dlg = nil;
        self.m_coin_dlg = new(CompeteCoinDialog,self.data);
        self.m_coin_dlg:show();
        ret = self.m_coin_dlg
    elseif  tonumber(self.data.type) == 13 then 
        delete(self.m_join_dlg)
        self.m_join_dlg = new(CompeteInfoDialog,self.data,self.parent);
        self.m_join_dlg:updateBtnStatus(self.m_item_status)
        self.m_join_dlg:updateMatchStatus(self.data.match_status, self.data.sign_status, self.data.me_status);
        self.m_join_dlg:show();
        ret = self.m_join_dlg
    elseif tonumber(self.data.type) == 14 then 
        delete(self.m_join_dlg)
        self.m_join_dlg = new(CompeteInfoDialog,self.data);
        self.m_join_dlg:updateBtnStatus(self.m_item_status)
        self.m_join_dlg:updateMatchStatus(self.data.match_status, self.data.sign_status, self.data.me_status);
        self.m_join_dlg:show();
        ret = self.m_join_dlg        
    end
    return ret
end;

function CompeteItem.dismissDialogs(self)
    if tonumber(self.data.type) == 12 then 
        if self.m_coin_dlg then self.m_coin_dlg:dismiss() end
    elseif  tonumber(self.data.type) == 13 then 
        if self.m_join_dlg then self.m_join_dlg:dismiss() end
    elseif tonumber(self.data.type) == 14 then      
        if self.m_join_dlg then self.m_join_dlg:dismiss() end
    end
end
-- 参赛
CompeteItem.onJoinBtnClick = function(self)
    self:showDialogs()
end;

-- 已报名
CompeteItem.onHasJoinBtnClick = function(self)
    self:showDialogs()
end;

-- 入场
CompeteItem.onEntryBtnClick = function(self)
    RoomProxy.getInstance():gotoMetierRoom(self.data.match_id)
end

-- 观战
CompeteItem.onWatchBtnClick = function(self)
	if self.parent and self.parent.openWatchDialog then
		self.parent:openWatchDialog(self.data)
	end
end;

-- 即将开始
CompeteItem.onWaitingBtnClick = function(self)

end;

-- 已结束
CompeteItem.onOverBtnClick = function(self)

end;

