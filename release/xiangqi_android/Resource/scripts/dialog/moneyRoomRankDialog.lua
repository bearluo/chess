require(VIEW_PATH .. "money_room_rank_dialog_view")

MoneyRoomRankDialog = class(ChessDialogScene,false)

function MoneyRoomRankDialog:ctor()
    super(self,money_room_rank_dialog_view)
    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)

    self.mGotoWaitRoomBtn = self.m_root:getChildByName("content_view"):getChildByName("goto_wait_room_btn")
    self.mGotoWaitRoomBtn:setOnClick(self,self.dismiss)
    self.mViews = {}
    self.mItems = {}
    for i=1,7 do
        self.mViews[i] = self.m_root:getChildByName("content_view"):getChildByName( string.format("View%d",i))
        self.mItems[i] = new(MoneyRoomRankDialogItem)
        self.mItems[i]:setAlign(kAlignCenter)
        self.mViews[i]:addChild(self.mItems[i])
    end
end

function MoneyRoomRankDialog:dtor()
    self.mDialogAnim.stopAnim()
end

function MoneyRoomRankDialog:show()
    self.super.show(self,self.mDialogAnim.showAnim)
    for i=1,7 do
        self.mItems[i]:setRoomBtnClick()
    end
    OnlineSocketManager.getHallInstance():sendMsg(MATCH_GETMATCHINFO,{})
end

function MoneyRoomRankDialog:setGotoWatchRoomFunc(obj,func)
    self.mGotoWatchRoomObj = obj
    self.mGotoWatchRoomFunc = func
end

function MoneyRoomRankDialog:gotoWatchRoom(tid)
    if type(self.mGotoWatchRoomFunc) == "function" then
        self.mGotoWatchRoomFunc(self.mGotoWatchRoomObj,tid)
    end
end

function MoneyRoomRankDialog:updateView(info)
    if type(info) ~= "table" then return end
    for _,room in ipairs(info) do
        if self.mItems[room.index] then
            local tid = room.tid
            self.mItems[room.index]:setPlayer(room.userId1,room.userId2)
            local status = room.status
            --//state =1,  //空，该场次还没开始
            --//state =2, //已经开始，正在比赛中
            --//state =3,   //结束room.winnerId,room.loserId
            if status == 1 then
                self.mItems[room.index]:setStatus(MoneyRoomRankDialogItem.s_status.wait)
            elseif status == 2 then
                self.mItems[room.index]:setStatus(MoneyRoomRankDialogItem.s_status.running)
            elseif status == 3 then
                if room.userId1 == room.winnerId then
                    self.mItems[room.index]:setStatus(MoneyRoomRankDialogItem.s_status.redWin)
                else
                    self.mItems[room.index]:setStatus(MoneyRoomRankDialogItem.s_status.blackWin)
                end
            end
            self.mItems[room.index]:setRoomBtnClick(self,function()
                self:gotoWatchRoom(tid)
            end)
        end
    end
end

function MoneyRoomRankDialog:dismiss()
    self.super.dismiss(self,self.mDialogAnim.dismissAnim)
end



require(VIEW_PATH .. "money_room_rank_dialog_view_item")
MoneyRoomRankDialogItem = class(Node)
MoneyRoomRankDialogItem.s_status = {
    wait        = 1;
    running     = 2;
    redWin      = 3;
    blackWin    = 4;
}

function MoneyRoomRankDialogItem:ctor()
    super(self,money_room_rank_dialog_view)
    self.m_root = SceneLoader.load(money_room_rank_dialog_view_item)
    self:addChild(self.m_root)
    local w,h = self.m_root:getSize()
    self:setSize(w,h)
    self.mStatus        = MoneyRoomRankDialogItem.s_status.wait
    self.mRoomBtn       = self.m_root:getChildByName("room_btn")
    self.mRoomBtn:setOnClick(self,self.onRoomBtnClick)
    self.mRoomStatusImg = self.mRoomBtn:getChildByName("room_status")
    self.mBlackName     = self.mRoomBtn:getChildByName("black_name")
    self.mBlackNameBg   = self.mRoomBtn:getChildByName("black_name_bg")
    self.mRedName       = self.mRoomBtn:getChildByName("red_name")
    self.mRedNameBg     = self.mRoomBtn:getChildByName("red_name_bg")


    
    self:setStatus(self.mStatus)
    EventDispatcher.getInstance():register(Event.Call,self,self.updateUserInfo);
end

function MoneyRoomRankDialogItem:dtor()
    EventDispatcher.getInstance():unregister(Event.Call,self,self.updateUserInfo);
end

function MoneyRoomRankDialogItem:setPlayer(redId,blackId)
    self.mRedId     = redId
    self.mBlackId   = blackId
    local redInfo   = FriendsData.getInstance():getUserData(self.mRedId)
    local blackInfo = FriendsData.getInstance():getUserData(self.mBlackId)
    if redInfo then
        self:setRedName(redInfo.mnick)
    else
        self:setRedName("")
    end
    
    if blackInfo then
        self:setBlackName(blackInfo.mnick)
    else
        self:setBlackName("")
    end
end

--[Comment]
--更新界面
function MoneyRoomRankDialogItem.updateUserInfo(self,cmd,userInfoTab)
    if cmd == kFriend_UpdateUserData then
        for _,userInfo in ipairs(userInfoTab) do
            if userInfo.mid == self.mRedId then
                self:setRedName(userInfo.mnick)
            elseif userInfo.mid == self.mBlackId then
                self:setBlackName(userInfo.mnick)
            end
        end
    end
end

function MoneyRoomRankDialogItem:setRedName(name)
    self.mRedName:setText(name)
    self.mRedNameBg:setText(name)
end

function MoneyRoomRankDialogItem:setBlackName(name)
    self.mBlackName:setText(name)
    self.mBlackNameBg:setText(name)
end

function MoneyRoomRankDialogItem:setRoomBtnClick(obj,func)
    self.mRoomBtnClickFunc  = func
    self.mRoomBtnClickObj   = obj
end

function MoneyRoomRankDialogItem:onRoomBtnClick()
    if self.mStatus == MoneyRoomRankDialogItem.s_status.running then
        if type(self.mRoomBtnClickFunc) == "function" then
            self.mRoomBtnClickFunc(self.mRoomBtnClickObj)
        else
            ChessToastManager.getInstance():showSingle("连接准备中,请稍后再试")
        end
    end

    if self.mStatus == MoneyRoomRankDialogItem.s_status.wait then
        ChessToastManager.getInstance():showSingle("该棋局未开始")
    end

    if self.mStatus == MoneyRoomRankDialogItem.s_status.redWin or self.mStatus == MoneyRoomRankDialogItem.s_status.blackWin then
        ChessToastManager.getInstance():showSingle("该棋局已结束")
    end
end

function MoneyRoomRankDialogItem:setStatus(status)
    self.mRedNameBg:setColor(250,220,190)
    self.mRedNameBg:setColor(250,220,190)
    if status == MoneyRoomRankDialogItem.s_status.wait then
        self.mRoomStatusImg:setFile("common/decoration/room_btn_wait.png")
        self.mRedName:setColor(125,80,65)
        self.mBlackName:setColor(125,80,65)
    elseif status == MoneyRoomRankDialogItem.s_status.running then
        self.mRoomStatusImg:setFile("common/decoration/room_btn_playing.png")
        self.mRedName:setColor(170,30,0)
        self.mBlackName:setColor(80,80,80)

    elseif status == MoneyRoomRankDialogItem.s_status.redWin then
        self.mRoomStatusImg:setFile("common/decoration/room_btn_red_win.png")
        self.mRedName:setColor(170,30,0)
        self.mBlackName:setColor(80,80,80)

    elseif status == MoneyRoomRankDialogItem.s_status.blackWin then
        self.mRoomStatusImg:setFile("common/decoration/room_btn_black_win.png")
        self.mRedName:setColor(170,30,0)
        self.mBlackName:setColor(80,80,80)
    
    else
        return    
    end
    
    self.mStatus = status
end