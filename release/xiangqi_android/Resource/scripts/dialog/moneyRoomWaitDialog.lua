require(VIEW_PATH .. "money_room_wait_dialog_view")

MoneyRoomWaitDialog = class(ChessDialogScene,false)

function MoneyRoomWaitDialog:ctor()
    super(self,money_room_wait_dialog_view)
--    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)
    self.mSignUpInfoView = self.m_root:getChildByName("sign_up_info_view")
    self.mContentView = self.m_root:getChildByName("sign_up_info_view"):getChildByName("content_view")
    self.mInputView = self.m_root:getChildByName("chat_view"):getChildByName("input_view")
    self.mBookMsgBg = self.mInputView:getChildByName("msg_bg")
    self.mShowBookMsgBtn = self.mInputView:getChildByName("show_msg_dialog_btn")
    self.mShowBookMsgBtn:setOnClick(self,self.showAndDismissMsgDialog)
    self.mChatEdit = self.mInputView:getChildByName("edit_bg"):getChildByName("edit")
    self.mChatEdit:setHintText("请输入消息",140,140,140)
    self.mChatEdit:setOnTextChange(self,self.sendRoomChat);
    self.mSeatGroupView = self.m_root:getChildByName("seat_group_view")
    self.mChatContentView = self.m_root:getChildByName("chat_view"):getChildByName("chat_content_view")
    local contentW,contentH = self.mChatContentView:getSize()
    self.chat_content_sroll_view = new(ScrollView2,0,0,contentW,contentH,true);
    self.mChatContentView:addChild(self.chat_content_sroll_view)

    self.chat_show_msg_dialog_bg = self.mInputView:getChildByName("msg_bg")
    local w,h = self.chat_show_msg_dialog_bg:getSize()
    self.chat_book_view = new(ScrollView2,0,0,w,h,true);
    self.chat_book_view:setAlign(kAlignBottom);
    self.chat_show_msg_dialog_bg:addChild(self.chat_book_view);

    self.mReward1Txt = self.m_root:getChildByName("reward_view"):getChildByName("reward1_txt")
    self.mReward2Txt = self.m_root:getChildByName("reward_view"):getChildByName("reward2_txt")

    self.mSureBtn = self.m_root:getChildByName("bg"):getChildByName("sure_btn")
    self.mCancelBtn = self.m_root:getChildByName("cancel_btn")
    self.mWaitBtn = self.m_root:getChildByName("bg"):getChildByName("wait_btn")
    self.mSureBtn:setOnClick(self,self.onSureBtnClick)
    self.mCancelBtn:setOnClick(self,self.onCancelBtnClick)
    self:setWaitNum(0,0)
    self:setBtnVisible(false)
    self:setNeedBackEvent(false)
    self:initSignUpList()
    self:initChatView()

    local config = RoomProxy.getInstance():getCurRoomConfig()
    if config and type(config.prize) == "table" then
        local money1,money2 = 0,0
        if config.prize[1] then
            money1 = config.prize[1].money
        end
        if config.prize[2] then
            money2 = config.prize[2].money
        end
        self:setRewardTxt(money1,money2)
    else
        self:setRewardTxt('','')
    end

    if config then
        self.m_root:getChildByName("top_view"):getChildByName("top_title_bg"):getChildByName("title_txt"):setText(config.name)
    end
    self.m_root:getChildByName("top_view"):getChildByName("help_btn"):setOnClick(self,self.showHelpDialog)
end

function MoneyRoomWaitDialog:dtor()
--    self.mDialogAnim.stopAnim()
    self:removeProp(1)
    self:removeProp(2)
    delete(self.m_chioce_dialog)
    delete(self.mHelpDialog)
end
-- 重写
function MoneyRoomWaitDialog:isShowing()
    return self.mIsShowing
end

function MoneyRoomWaitDialog:show()
--    self.super.show(self,self.mDialogAnim.showAnim)
    if self.mIsShowing then return end
    self.mIsShowing = true
    self:setVisible(true)
    OnlineSocketManagerProcesser.getInstance():register(FASTMATCH_SIGN_UP_LIST,self,self.onFastSignUpList)

    OnlineSocketManagerProcesser.getInstance():register(CHATROOM_CMD_ENTER_ROOM,self,self.onJoinChatRoomCallBack)
    OnlineSocketManagerProcesser.getInstance():register(CHATROOM_CMD_LEAVE_ROOM,self,self.onLeaveChatRoomCallBack)
    OnlineSocketManagerProcesser.getInstance():register(CHATROOM_CMD_USER_CHAT_MSG,self,self.onUserChatMsgCallBack)
    OnlineSocketManagerProcesser.getInstance():register(CHATROOM_CMD_BROAdCAST_CHAT_MSG,self,self.onBroadcastChatCallBack)
    OnlineSocketManagerProcesser.getInstance():register(CHATROOM_CMD_GET_HISTORY_MSG_NEW,self,self.onGetHistoryMsgCallBack)
    EventDispatcher.getInstance():register(Event.Call,self,self.onEventResponse);
end

function MoneyRoomWaitDialog:dismiss()
--    self.super.dismiss(self,self.mDialogAnim.dismissAnim)
    if not self.mIsShowing then return end
    self.mIsShowing = false
    self:exitChatRoom()
    self:setVisible(false)
    OnlineSocketManagerProcesser.getInstance():unregister(FASTMATCH_SIGN_UP_LIST,self,self.onFastSignUpList)
    
    OnlineSocketManagerProcesser.getInstance():unregister(CHATROOM_CMD_ENTER_ROOM,self,self.onJoinChatRoomCallBack)
    OnlineSocketManagerProcesser.getInstance():unregister(CHATROOM_CMD_LEAVE_ROOM,self,self.onLeaveChatRoomCallBack)
    OnlineSocketManagerProcesser.getInstance():unregister(CHATROOM_CMD_USER_CHAT_MSG,self,self.onUserChatMsgCallBack)
    OnlineSocketManagerProcesser.getInstance():unregister(CHATROOM_CMD_BROAdCAST_CHAT_MSG,self,self.onBroadcastChatCallBack)
    OnlineSocketManagerProcesser.getInstance():unregister(CHATROOM_CMD_GET_HISTORY_MSG_NEW,self,self.onGetHistoryMsgCallBack)
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onEventResponse);
end

function MoneyRoomWaitDialog:joinChatRoom()
    self:sendUpdateSignUpViewMsg()
    self:joinChatRoom()
end

function MoneyRoomWaitDialog:setBtnVisible(flag)
--    self.mWaitBtn:setVisible(not flag)
--    self.mSureBtn:setVisible(flag)
    self.mWaitBtn:setVisible(false)
    self.mSureBtn:setVisible(false)
end

function MoneyRoomWaitDialog:onSureBtnClick()
    if type(self.mSureBtnClickFunc) == "function" and (not self.mSureBtnClickTime or os.time() - self.mSureBtnClickTime > 2 ) then
        self.mSureBtnClickFunc(self.mSureBtnClickObj)
        self.mSureBtnClickTime = os.time()
    end
end

function MoneyRoomWaitDialog:setSureBtnClick(obj ,func )
    self.mSureBtnClickFunc  = func
    self.mSureBtnClickObj   = obj
end

function MoneyRoomWaitDialog:onCancelBtnClick()
    if type(self.mCancelBtnClickFunc) == "function" and (not self.mCancelBtnClickTime or os.time() - self.mCancelBtnClickTime > 2 ) then
        self.mCancelBtnClickFunc(self.mCancelBtnClickObj)
        self.mCancelBtnClickTime = os.time()
    end
end

function MoneyRoomWaitDialog:setCancelBtnClick(obj ,func )
    self.mCancelBtnClickFunc  = func
    self.mCancelBtnClickObj   = obj
end

function MoneyRoomWaitDialog:countDown(time)
end

function MoneyRoomWaitDialog:setWaitNum(waitNum,needWaitNum)
    self.mContentView:removeAllChildren(true)
    local rich = new(RichText, string.format("已报名 #cC82828%d#n 人,还需 #cC82828%d#n 人即可开赛",waitNum,needWaitNum), 0, 0, kAlignTopLeft, fontName, 32, 120, 120, 120, false,0)
    local w,h = rich:getSize()
    self.mContentView:setSize(w,h)
    self.mContentView:addChild(rich)
    self.mSignUpInfoView:setSize(w+60)
    self:sendUpdateSignUpViewMsg()
end

function MoneyRoomWaitDialog:showHelpDialog()
    local config = RoomProxy.getInstance():getCurRoomConfig()
    if not config then return end
    if not self.mHelpDialog then
        self.mHelpDialog = new(CommonHelpDialog)
        self.mHelpDialog:setMode(CommonHelpDialog.match_rule_mode,config)
    end 
    self.mHelpDialog:show()
end

function MoneyRoomWaitDialog:setRewardTxt(reward1,reward2)
    self.mReward1Txt:setText(ToolKit.skipMoney(reward1) .. "金币")
    self.mReward2Txt:setText(ToolKit.skipMoney(reward2) .. "金币")
end
-- 规则
MoneyRoomWaitDialog.initChatView = function( self )
    self.m_chat_list_items = {}
    --房间内常用语
	self.phrases = {
        "大家好，很高兴见到各位！",
        "谁来与我对战一局？",
        "我已经迫不及待要开始战斗了！",
        "箭在弦上，比赛一触即发！",
        "这里真是高手如云呀！",
        "不要走，我们来大战三百回合！",
        "我接受你的挑战！",
        "关注我，我们交个朋友吧！",
        "各位高手，教教我下棋吧！",
        "再见了，我要离开一会！",
    }
    self.phrases_btns = {};
    for i,v in ipairs(self.phrases) do
        self.phrases_btns[i] = new(MoneyRoomWaitDialogChatPhrasesItem,v);
        self.phrases_btns[i]:setClickEvent(self,self.onPhrasesItemClick);
        self.chat_book_view:addChild(self.phrases_btns[i]);
    end
end

MoneyRoomWaitDialog.onPhrasesItemClick = function(self,item)
	local message = GameString.convert2UTF8(item:getText());
    self:sendRoomChatMsg(message);
end

--房间内聊天 item
MoneyRoomWaitDialog.addChatLog = function(self,name,message,uid)
	if not message or message == "" then
		return
	end
	local data = {}
	data.mnick = GameString.convert2UTF8(name)
	data.msg = GameString.convert2UTF8(message)
    data.send_uid = uid
    
    Log.i("addChatLog" .. message )
    if data.send_uid and type(data.send_uid) == "number" then
        if not UserInfoDialog2.s_forbid_id_list[data.send_uid] then
	        local item = new(MoneyRoomWaitDialogChatLogItem,data,1)
            if self.chat_content_sroll_view:isScrollToBottom() then
                self.chat_content_sroll_view:addChild(item)
                self.chat_content_sroll_view:gotoBottom()
            else
                self.chat_content_sroll_view:addChild(item)
                local _,h = self.chat_content_sroll_view:getMainNodeWH()
                self.chat_content_sroll_view:gotoOffset(h)
            end
            table.insert(self.m_chat_list_items,item)
        end
    end
end
MoneyRoomWaitDialog.addJoinChatLog = function(self,name,message,uid)
    if not self.isNotFirstInitSignUpList then return end
	local data = {}
	data.mnick = GameString.convert2UTF8(name)
	data.msg = GameString.convert2UTF8(message)
    data.send_uid = uid
    
    if data.send_uid and type(data.send_uid) == "number" then
        if not UserInfoDialog2.s_forbid_id_list[data.send_uid] then
	        local item = new(MoneyRoomWaitDialogChatLogItem,data,2)
            item:setPickable(false)
            if self.chat_content_sroll_view:isScrollToBottom() then
                self.chat_content_sroll_view:addChild(item)
                self.chat_content_sroll_view:gotoBottom()
            else
                self.chat_content_sroll_view:addChild(item)
                local _,h = self.chat_content_sroll_view:getMainNodeWH()
                self.chat_content_sroll_view:gotoOffset(h)
            end
            table.insert(self.m_chat_list_items,item)
        end
    end
end

function MoneyRoomWaitDialog:clearAllChatLog()
    self.chat_content_sroll_view:removeAllChildren(true)
    self.m_chat_list_items = {}
end

function MoneyRoomWaitDialog:showAndDismissMsgDialog()
    if self.mInputView:checkAddProp(1) then
        self:showMsgDialog()
    else
        self:dismissMsgDialog()
    end
end

function MoneyRoomWaitDialog:showMsgDialog()
    local w,h = self.mBookMsgBg:getSize()
    self.mInputView:removeProp(2);
    --常用语上滑动画
    self.mInputView:addPropTranslate(1, kAnimNormal, 100, -1, 0, 0, 0, -h);
end

function MoneyRoomWaitDialog:dismissMsgDialog()
    if self.mInputView:checkAddProp(1) then return end
    local w,h = self.mBookMsgBg:getSize()
    self.mInputView:removeProp(1);
    --常用语上滑动画
    self.mInputView:addPropTranslate(2, kAnimNormal, 100, -1, 0, 0, -h, 0);
end

function MoneyRoomWaitDialog:initSignUpList()
    self.mSignUpListId = {}
    self.mSignUpListView = {}
    self:updateSignUpView()
end

function MoneyRoomWaitDialog:updateSignUpView()
    for i=1,8 do
        if not self.mSignUpListView[i] then
            self.mSignUpListView[i] = new(MoneyRoomWaitPlayerItem)
            self.mSignUpListView[i]:setAddChatLog(self,self.addJoinChatLog)
            local w,h = self.mSignUpListView[i]:getSize()
            local index = 0
            if i <= 4 then 
                index = i-1 
                self.mSignUpListView[i]:setPos(w*index,0)
            else 
                index = i - 5 
                self.mSignUpListView[i]:setPos(w*index,h)
            end
            self.mSeatGroupView:addChild(self.mSignUpListView[i])
        end
        self.mSignUpListView[i]:setPlayer(self.mSignUpListId[i])
    end
end

function MoneyRoomWaitDialog:setMatchLevel(level)
    self.mLevel = tonumber(level)
    local LevelConfig = RoomConfig.getInstance():getRoomLevelConfig(self.mLevel)
    self.chat_id = LevelConfig.chat_id
end

function MoneyRoomWaitDialog:sendUpdateSignUpViewMsg()
    if not self.mLevel then return end
    local info = {}
    info.level = self.mLevel
    OnlineSocketManager.getHallInstance():sendMsg(FASTMATCH_SIGN_UP_LIST,info)
end

function MoneyRoomWaitDialog:onFastSignUpList(packetInfo)
    if not packetInfo then return end
    if packetInfo.level ~= self.mLevel then return end
    local num = packetInfo.num
    local list = packetInfo.list
    local notInsertTab = {}
    for i=1,8 do
        if self.mSignUpListId[i] then
            local isFind = false
            for j=1,num do
                if self.mSignUpListId[i] == list[j] then
                    isFind = true
                    notInsertTab[j] = true
                    break
                end
            end
            if not isFind then
                self.mSignUpListId[i] = nil
            end
        end
    end

    for i=1,num do
        if not notInsertTab[i] then
            for j=1,8 do
                if self.mSignUpListId[j] == nil then
                    self.mSignUpListId[j] = list[i]
                    break
                end
            end
        end
    end
    self:updateSignUpView()
    self.isNotFirstInitSignUpList = true
end

function MoneyRoomWaitDialog:joinChatRoom()
    if self.chat_id then
        local packetInfo = {};
        packetInfo.room_id = self.chat_id;
        OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_ENTER_ROOM,packetInfo);

    end
--    self:clearAllChatLog()
end

function MoneyRoomWaitDialog:exitChatRoom()
    if self.chat_id then
    	local info = {};
    	info.room_id = self.chat_id;
    	info.uid = UserInfo.getInstance():getUid();
        OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_LEAVE_ROOM,info);
    end
end


function MoneyRoomWaitDialog:sendRoomChat()
    local message = GameString.convert2UTF8(self.mChatEdit:getText())
	if not message or message == "" or message == "" then
        ChessToastManager.getInstance():showSingle("消息不能为空！",800)
		return
	end
    local lens = string.lenutf8(GameString.convert2UTF8(message) or "")   
    if lens > 60 then--限制60字
        ChessToastManager.getInstance():showSingle("消息不能超过60字！",800)
		return      
    end
    self:sendRoomChatMsg(message)
    self.mChatEdit:setText(nil)
end


function MoneyRoomWaitDialog:sendRoomChatMsg(message)
	local msgdata = {};
	msgdata.room_id = self.chat_id;
	msgdata.msg = message;
	msgdata.name = UserInfo.getInstance():getName();
	msgdata.uid = UserInfo.getInstance():getUid();
    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_USER_CHAT_MSG,msgdata);
    self:dismissMsgDialog()
end



function MoneyRoomWaitDialog:onJoinChatRoomCallBack(packetInfo)
    if packetInfo and packetInfo.status == 0 and packetInfo.room_id == self.chat_id then
        local info = {};
        info.uid = UserInfo.getInstance():getUid();
        info.room_id = self.chat_id;
        info.last_msg_time = TimerHelper.getServerCurTime()
        info.items = 15;
        info.version = kLuaVersionCode;
        OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_GET_HISTORY_MSG_NEW,info);
    end
end

function MoneyRoomWaitDialog:onLeaveChatRoomCallBack(packetInfo)

end

function MoneyRoomWaitDialog:onUserChatMsgCallBack(packetInfo)
    if not packetInfo then return end
    if self.chat_id ~= packetInfo.room_id then return end
    if packetInfo.status > 0 then
        if self:isForbidSendMsg(packetInfo.status) then
            return    
        else
            ChessToastManager.getInstance():showSingle("消息发送失败了",2000);
        end
    elseif packetInfo.status == -1 then -- 屏蔽频繁聊天
        ChessToastManager.getInstance():showSingle("亲，消息不能为空或频繁发送哦",1500);
    end
end

MoneyRoomWaitDialog.isForbidSendMsg = function(self,forbid_time)
    if forbid_time and forbid_time > 0 then
        local tip_msg = "很抱歉，您的账号被多次举报，经核实已被禁言，将于"..os.date("%Y-%m-%d %H:%M",forbid_time) .."解禁，感谢您的配合和理解。"
        if not self.m_chioce_dialog then
            self.m_chioce_dialog = new(ChioceDialog)
        end
        self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE)
        self.m_chioce_dialog:setMessage(tip_msg)
        self.m_chioce_dialog:show()
        return true
    end
    return false
end

function MoneyRoomWaitDialog:onBroadcastChatCallBack(packetInfo)
    if not packetInfo then return end
    if packetInfo.room_id ~= self.chat_id then return end
	local msgtab = json.decode(packetInfo.msg_json);
    local msgData = {};
    msgData.uid = msgtab.uid;
    msgData.name = msgtab.name;
    msgData.time = msgtab.time;
    msgData.msg = msgtab.msg;
    msgData.msg_id = msgtab.msg_id;
    
    if FriendsData.getInstance():isInBlacklist(tonumber(msgData.uid)) then return end
    Log.i("MoneyRoomWaitDialog:onBroadcastChatCallBack:" .. packetInfo.msg_json)
    self:addChatLog(msgData.name,msgData.msg,msgData.uid)


    local msginfo = {};
    msginfo.room_id = packetInfo.room_id;
    msginfo.uid = UserInfo.getInstance():getUid();
    msginfo.msg_time = msgtab.time;
    msginfo.msg_id = msgtab.msg_id;
    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_BROAdCAST_CHAT_MSG,msginfo);
end

function MoneyRoomWaitDialog:onGetHistoryMsgCallBack(packetInfo)
    if not packetInfo then return end
    local total_num = packetInfo.total_count;
    local roomId = packetInfo.room_id;
    local page_num = packetInfo.page_num;
    local curr_page = packetInfo.curr_page;
    local item_num = packetInfo.item_num;
    local msgItem = packetInfo.item;
    if packetInfo.room_id ~= self.chat_id then return end
    
    Log.i("MoneyRoomWaitDialog:onGetHistoryMsgCallBack:" .. (json.encode(msgItem) or "nil") )
    for i = 1,item_num do
        local data = msgItem[i]
        if not FriendsData.getInstance():isInBlacklist(tonumber(data.uid)) then 
            self:addChatLog(data.name,data.msg,data.uid)
        end
    end
end



MoneyRoomWaitPlayerItem = class(Node)

function MoneyRoomWaitPlayerItem:ctor()
    self:setSize(160,173)
    local head = new(Mask,"common/icon/default_head.png","common/background/head_mask_bg_110.png")
    head:setSize(110,110)
    head:setAlign(kAlignTop)
    local level = new(Image,"common/icon/level_1.png")
    level:setAlign(kAlignBottom)
    level:setPos(0,-12)
    level:setVisible(false)
    head:addChild(level)
    local name = new(Text,"", width, height, kAlignCenter, fontName, 26, 120, 120, 120)
    name:setAlign(kAlignBottom)
    name:setPos(0,20)
    self:addChild(head)
    self:addChild(name)
    self.mHead = head
    self.mLevel = level
    self.mName = name
    EventDispatcher.getInstance():register(Event.Call,self,self.onNativeEvent)
    self:setEventTouch(self,self.onEventTouch)
    self.mAddChatLog = {}
end

function MoneyRoomWaitPlayerItem:dtor()
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeEvent)
    delete(self.m_up_user_info_dialog)
end

function MoneyRoomWaitPlayerItem:onEventTouch(finger_action,x,y,drawing_id_first,drawing_id_current)
    if not self.mUid then return end
    if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
     
        if self.m_up_user_info_dialog and self.m_up_user_info_dialog:isShowing() then 
            self.m_up_user_info_dialog:dismiss();
            return 
        end
        delete(self.m_up_user_info_dialog)
        self.m_up_user_info_dialog = new(UserInfoDialog2);

        if UserInfo.getInstance():getUid() == self.mUid then
            self.m_up_user_info_dialog:setShowType(UserInfoDialog2.SHOW_TYPE.OTHER)
        else
            self.m_up_user_info_dialog:setShowType(UserInfoDialog2.SHOW_TYPE.UNION)
        end

        FriendsData.getInstance():sendCheckUserData(self.mUid)
        self.m_up_user_info_dialog:show(nil,self.mUid);
    end
end


function MoneyRoomWaitPlayerItem:onNativeEvent(cmd,...)
    if cmd == kFriend_UpdateUserData then
        local data = unpack({...})
        if not self.mUid then return end
        for _,userData in ipairs(data) do
            if self.mUid == userData.mid then
                self:setUserData(userData)
                if not self.isAddJoinMsg and type(self.mAddChatLog.func) == "function" then
                    self.mAddChatLog.func(self.mAddChatLog.obj,userData.mnick,"进来了",self.mUid)
                    self.isAddJoinMsg = true
                end
            end
        end
    end
end

function MoneyRoomWaitPlayerItem:setPlayer(uid)
    if self.mUid == tonumber(uid) then return end
    local preUid = self.mUid
    self.mUid = tonumber(uid)
    if not uid then
        self.mHead:setFile("common/icon/default_head.png")
        self.mName:setText("")
        self.mLevel:setVisible(false)
        if self.mUserData and type(self.mAddChatLog.func) == "function" then
            self.mAddChatLog.func(self.mAddChatLog.obj,self.mUserData.mnick,"离开了",preUid)
        end
        self.mUserData = nil
        return
    end
    self.isAddJoinMsg = false
    local data = FriendsData.getInstance():getUserData(self.mUid)
    self:setUserData(data)
    if data and type(self.mAddChatLog.func) == "function" then
        self.mAddChatLog.func(self.mAddChatLog.obj,data.mnick,"进来了",self.mUid)
        self.isAddJoinMsg = true
    end
end

function MoneyRoomWaitPlayerItem:setAddChatLog(obj,func)
    self.mAddChatLog.func = func
    self.mAddChatLog.obj = obj
end

function MoneyRoomWaitPlayerItem:setUserData(data)
    self.mUserData = data
    if data then
        self:setHead(data)
        local length = string.lenutf8(data.mnick)
        if length <= 4 then
            self.mName:setText(data.mnick)
        else
            local prefix = string.subutf8(data.mnick,1,3)
            self.mName:setText(prefix .. "...")
        end
    else
        self.mHead:setFile("common/icon/default_head.png")
        self.mName:setText("")
        self.mLevel:setVisible(false)
    end
end

function MoneyRoomWaitPlayerItem:setHead(data)
    if type(data) ~= "table" then return end
    if tonumber(data.iconType) == -1 then
        self.mHead:setUrlImage(data.icon_url,"common/icon/default_head.png")
    else
        local icon = tonumber(data.iconType) or 1
        self.mHead:setFile(UserInfo.DEFAULT_ICON[icon] or UserInfo.DEFAULT_ICON[1])
    end
--    local frameRes = UserSetInfo.getInstance():getFrameRes(data.my_set);
--    vip:setVisible(false)
--    if not frameRes then return end
--    vip:setVisible(frameRes.visible);
--    if frameRes.frame_res then
--        vip:setFile(string.format(frameRes.frame_res,110));
--    end
    self.mLevel:setFile( string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevelByScore(data.score)))
    self.mLevel:setVisible(true)
end



MoneyRoomWaitDialogChatPhrasesItem = class(Node);

MoneyRoomWaitDialogChatPhrasesItem.ctor = function(self,str)
--	local text_x = 0;
--    super(self, "drawable/blank.png");
    local w,h = 700,73;
	print_string("MoneyRoomWaitDialogChatPhrasesItem.ctor str = " .. str);

    self.m_bg_btn = new(Button,"drawable/blank.png","drawable/blank_press.png");
    self.m_bg_btn:setAlign(kAlignCenter);
    self.m_bg_btn:setSize(w,h);
    self:addChild(self.m_bg_btn);
	self.m_text = new(Text,str,nil,nil,nil,nil,32,80,80,80);
	self.m_text:setPos(10,0);
    self.m_text:setAlign(kAlignLeft);
	self.m_line = new(Image,"common/decoration/cutline.png");
	self.m_line:setPos(0,h);
    self.m_line:setSize(w,2);
    self.m_line:setAlign(kAlignBottom);
	self:addChild(self.m_text);
	self:addChild(self.m_line);
    self:setSize(w,h);
    self:setAlign(kAlignCenter);
    self.m_bg_btn:setOnClick(self,self.onItemClick);
    self.m_bg_btn:setSrollOnClick();
end


MoneyRoomWaitDialogChatPhrasesItem.getText = function(self)
	return self.m_text:getText();
end

MoneyRoomWaitDialogChatPhrasesItem.onItemClick = function(self)
    if self.m_click_event and self.m_click_event.func then
        self.m_click_event.func(self.m_click_event.obj,self);
    end
end

MoneyRoomWaitDialogChatPhrasesItem.setClickEvent = function(self,obj,func)
    self.m_click_event = {};
    self.m_click_event.obj = obj;
    self.m_click_event.func = func;
end

MoneyRoomWaitDialogChatPhrasesItem.dtor = function(self)
	
end	

MoneyRoomWaitDialogChatLogItem = class(Node)

MoneyRoomWaitDialogChatLogItem.DEFAULT_w = 690;
MoneyRoomWaitDialogChatLogItem.DEFAULT_h = 62;

MoneyRoomWaitDialogChatLogItem.ctor = function(self, data , UItype)
	self.m_name = data.mnick or "";
	self.m_str = data.msg or "";
    self.m_uid = data.send_uid or 0;
    local userInfo = FriendsData.getInstance():getUserData(self.m_uid) or {};
    local score = tonumber(userInfo.score) or 1000
    local is_vip = tonumber(userInfo.is_vip) or 0
    self.reportData = self.m_str or ""

    local colorStr = "#c507DBE"
    if is_vip == 1 then
        colorStr = "#cFF4500"
    end
    local nameStr = colorStr .. self.m_name .. "：";
    local chatStr = "#c505050"..self.m_str;
    local offset = 0
    if UItype == 2 then
        nameStr = colorStr .. self.m_name;
        chatStr = "#c505050"..self.m_str;
    end

    self.level_img = new(Image,"common/icon/level_"..(10 - UserInfo.getInstance():getDanGradingLevelByScore(score))..".png")
    self.level_img:setAlign(kAlignTopLeft)
    self.level_img:setPos(18+offset,8)
    self:addChild(self.level_img)
    
    local richTextW = 606 - offset
    if next(userInfo) ~= nil then
        richTextW = richTextW - select(1,self.level_img:getSize())
    end

    self.item_text = new(RichText,nameStr .. chatStr,richTextW,nil,kAlignLeft,nil,30,80,80,80,true,5);
    self.item_text:setAlign(kAlignTopLeft);
    self.item_text:setPos(75+offset,0);
    self:addChild(self.item_text);
    if self.m_uid ~= 0 then 
        self.m_name_touch_area = new(Button,"drawable/blank.png");
        self.m_name_touch_area:setOnClick(self, self.showUserInfo);
        local tempMsg = new(Text,(self.m_name or "博雅象棋"),0, 0, kAlignLeft,nil,30,80, 80,80);
        local tempMsgW, tempMsgH = tempMsg:getSize();
        self.m_name_touch_area:setSize(tempMsgW,30);
        self.item_text:addChild(self.m_name_touch_area);
    end;
    self.item_line = new(Image,"common/decoration/cutline.png");
    self.item_line:setAlign(kAlignBottom);
    self.item_line:setSize(660,1);
--    self.item_line:setPos(0,-15);
    self:addChild(self.item_line);
    local _,h = self.item_text:getSize();
    self:setSize(MoneyRoomWaitDialogChatLogItem.DEFAULT_w,h+5);
    self:setAlign(kAlignLeft);
    if next(userInfo) == nil then
        self.level_img:setVisible(false)
        self.item_text:setPos(18+offset,0)
    end

	self:setEventTouch(self,MoneyRoomWaitDialogChatLogItem.onTouch);
end

MoneyRoomWaitDialogChatLogItem.showUserInfo = function(self)
    if self.m_uid == UserInfo.getInstance():getUid() then
        Log.i("ChatLogItem.showUserInfo--name click yourself!");
    else
        if not self.m_userinfo_dialog then
            -- TODO UserInfoDialog2 从场景中分离出来的dlg,后续会同步到联网对战
            self.m_userinfo_dialog = new(UserInfoDialog2);
        end;
        if self.m_userinfo_dialog:isShowing() then return end
        self.m_userinfo_dialog:setShowType(UserInfoDialog2.SHOW_TYPE.WATCH_ROOM)
        self.m_userinfo_dialog:setReportInfo(self.reportData)
        local user = FriendsData.getInstance():getUserData(self.m_uid);
        self.m_userinfo_dialog:show(user,self.m_uid);
    end;
end;

MoneyRoomWaitDialogChatLogItem.getText = function(self)
	return self.m_str;
end

MoneyRoomWaitDialogChatLogItem.getName = function(self)
	return self.m_name;
end

MoneyRoomWaitDialogChatLogItem.dtor = function(self)
	self.m_root_view = nil;
    if self.m_userinfo_dialog then
        delete(self.m_userinfo_dialog);
        self.m_userinfo_dialog = nil;
    end;
end	