require(VIEW_PATH .. "money_room_list_dialog_view")
require(DIALOG_PATH .. "moneyRoomListHelpDialog")
--require(DIALOG_PATH .. "common_help_dialog");

MoneyRoomListDialog = class(ChessDialogScene,false)

function MoneyRoomListDialog:ctor()
    super(self,money_room_list_dialog_view)
    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)
    self.mHelpBtn = self.m_root:getChildByName("bg"):getChildByName("help_btn")
    self.mHelpBtn:setOnClick(self,self.showHelpDialog)
    self.mCloseBtn = self.m_root:getChildByName("bg"):getChildByName("close_btn")
    self.mCloseBtn:setOnClick(self,self.dismiss)
    self.mRoomList = self.m_root:getChildByName("bg"):getChildByName("room_list")
    self.mTipTxt = self.m_root:getChildByName("bg"):getChildByName("tip_txt")
    self.mShareBtn = self.m_root:getChildByName("bg"):getChildByName("share_btn")
    self.mShareBtn:setOnClick(self,self.onShareBtnClick)
    self.mPlayInfo = {}
    self.mTipTxt:setText("加载中...")
end

function MoneyRoomListDialog:dtor()
    self.mDialogAnim.stopAnim()
    delete(self.commonShareDialog)
end

function MoneyRoomListDialog:show()
    self.super.show(self,self.mDialogAnim.showAnim)
    if self.mInfo then
        OnlineSocketManager.getHallInstance():sendMsg(HALL_MSG_GAMEPLAY,self.mInfo, SUBCMD_LADDER ,2);
    end
end

function MoneyRoomListDialog:dismiss()
    self.super.dismiss(self,self.mDialogAnim.dismissAnim)
end

function MoneyRoomListDialog:showHelpDialog()
--    if not self.mHelpDialog then
--        self.mHelpDialog = new(CommonHelpDialog)
--        self.mHelpDialog:setMode(CommonHelpDialog.online_money_mode)
--    end 
--    self.mHelpDialog:show()

    if not self.mHelpDialog then
        self.mHelpDialog = new(MoneyRoomListHelpDialog)
    end
    self.mHelpDialog:show()
end

function MoneyRoomListDialog:setRoomList(data,isSuccess)
    if isSuccess then
        self.mTipTxt:setText("")
    else
        self.mTipTxt:setText("加载失败")
        return 
    end
    self.mRoomList:setAdapter()
    if not data then return end
    local viewData = {}
    for _,val in pairs(data) do
        table.insert(viewData,val)
    end
    if #viewData > 0 then
        self.mAdapter = new(MoneyRoomListDialogAdapter,MoneyRoomListDialogItem,viewData,self.mPlayInfo)
        local info = {}
        for index=1,#viewData do
            table.insert(info,viewData[index].level)
        end
        self.mInfo = info
        OnlineSocketManager.getHallInstance():sendMsg(HALL_MSG_GAMEPLAY,info, SUBCMD_LADDER ,2);
    else
        self.mInfo    = nil
        self.mAdapter = nil
        self.mTipTxt:setText("暂时没有比赛")
    end
    self.mRoomList:setAdapter(self.mAdapter)
end

function MoneyRoomListDialog:updatePlayerNum(info)
    if type(info) ~= "table" then return end
    for key,val in pairs(info) do
        self.mPlayInfo[key] = val
    end
    if self.mAdapter then
        self.mAdapter:updateViewPlayerNum(self.mPlayInfo)
    end
end



function MoneyRoomListDialog:onShareBtnClick()
    local schemesData = {};
    schemesData.method = "gotoMoneyRoom";
    local tab = {}
    tab.url = SchemesProxy.getWebSchemesUrl(schemesData)
    tab.title = "挑战赛邀请";
    tab.description = "博雅象棋增加比赛啦，报名玩快棋可以赢大额金币哦，快来和我一起参加吧~";
    if not self.commonShareDialog then
        self.commonShareDialog = new(CommonShareDialog);
    end
    self.commonShareDialog:setShareDate(tab,"arena_share");
    self.commonShareDialog:show();
    self:dismiss()
end

MoneyRoomListDialogAdapter = class(Adapter)
MoneyRoomListDialogAdapter.ctor = function(self, view, data,playNumInfo)
	self.m_view = view;
	self.m_data = data;
	self.m_playNumInfo = self:getPlayNumInfo(playNumInfo)
    self.m_views = {}
end

MoneyRoomListDialogAdapter.getView = function(self, index)
    if not self.m_data[index] then
        return nil;
    end
	self.m_views[index] =  new(self.m_view,self.m_data[index],self.m_playNumInfo[index]);
	return self.m_views[index];
end

MoneyRoomListDialogAdapter.releaseView = function(self, v)
    for index,view in pairs(self.m_views) do
        if view == v then
            self.m_views[index] = nil
        end
    end
	delete(v);
end

MoneyRoomListDialogAdapter.dtor = function(self)
	self.m_view = nil;
	self.m_data = nil;
    self.m_playNumInfo = nil
    self.m_views = {}
end

function MoneyRoomListDialogAdapter:updateViewPlayerNum(playNumInfo)
	self.m_playNumInfo = self:getPlayNumInfo(playNumInfo);
    for index,view in pairs(self.m_views) do
        view:updateViewPlayerNum(self.m_playNumInfo[index])
    end
end

function MoneyRoomListDialogAdapter:getPlayNumInfo(playNumInfo)
	local info = {}
    for index,data in ipairs(self.m_data) do
        info[index] = playNumInfo[data.level]
    end
    return info
end

require(VIEW_PATH .. "money_room_list_dialog_view_item")
MoneyRoomListDialogItem = class(Button,false)

function MoneyRoomListDialogItem:ctor(data,playNum)
    super(self,"drawable/blank.png")
    self.mScene = SceneLoader.load(money_room_list_dialog_view_item)
    self:addChild(self.mScene)
    local w,h = self.mScene:getSize()
    self:setSize(w,h)

    self.mGoldIcon = self.mScene:getChildByName("gold_icon")
    self.mJoinBtn = self.mScene:getChildByName("join_btn")
    self.mJoinBtn:setSrollOnClick()
    self.mJoinBtn:setPickable(false)
    self:setSrollOnClick()
    self.mMoneyTxt = self.mScene:getChildByName("money_txt")
    self.mOnlineNumText = self.mScene:getChildByName("online_num_text")
    self.mJoinMoneyTxt = self.mJoinBtn:getChildByName("join_money_txt")
    self.mTimeText = self.mScene:getChildByName("time")
    self.mNumberText = self.mScene:getChildByName("number")
    
    self.mData = data
    local golds = data.money or 0
    local join_money = data.join_money or 0
    local name = data.name or ""
    local round_time = tonumber(data.roundTime) or 0
    local least_num = tonumber(data.least_num) or 0
    local goldFile = data.img_url or "";
    playNum = playNum or 0

    self.mJoinMoneyTxt:setText(join_money .. "金币")
    self.mMoneyTxt:setText(name)
    self.mNumberText:setText( string.format("满%d人开赛",least_num))
    self.mTimeText:setText( string.format("%d分钟包干",round_time/60))
    self.mJoinBtn:setOnClick(self,self.joinMatchRoom)
    self:setOnClick(self,self.joinMatchRoom)
    self.mGoldIcon:setUrlImage(goldFile)
    self.mOnlineNumText:setText( string.format("在线:%d",playNum))
end

function MoneyRoomListDialogItem:joinMatchRoom()
    if UserInfo.getInstance():getScore() < self.mData.join_min_score then
        ChessToastManager.getInstance():showSingle( string.format("抱歉，仅%d积分以上用户可参加此比赛",self.mData.join_min_score) , 2000)
        return 
    end
    if self.mData.is_open == 0 then
        local time = json.decode(self.mData.match_time);
        local str = "比赛开放时间:"
        for i,t in pairs(time) do
            str = string.format("%s%s-%s",str,t["start"],t["end"])
            if i ~= #time then
                str = str .. ", "
            end
        end
        if not self.mStartTime then
            self.mStartTime = new(ChioceDialog)
            self.mStartTime:setMode(ChioceDialog.MODE_OTHER)
        end
        self.mStartTime:setMessage(str)
        self.mStartTime:show()
        return 
    end
    if self.sendMsgTime and os.time() - self.sendMsgTime < 2 then return end
    self.sendMsgTime = os.time()
    local join_money = self.mData.join_money or 0
    if UserInfo.getInstance():getMoney() < join_money then
        ChessToastManager.getInstance():showSingle("金币不足")
        return
    end
    local info = {}
    info.level = self.mData.level
    RoomProxy.getInstance():gotoMoneyMatchRoom(info)
end

function MoneyRoomListDialogItem:updateViewPlayerNum(playNum)
    playNum = playNum or 0
    self.mOnlineNumText:setText( string.format("在线:%d",playNum))
end

function MoneyRoomListDialogItem:dtor()
    print("")
    delete(self.mStartTime)
end