--region NewFile_1.lua
--Author : FordFan
--Date   : 2015/11/13
--添加好友弹窗
--endregion

require(VIEW_PATH .. "sociaty_invite_dialog_view");
require(MODEL_PATH .. "chessSociatyModule/chessSociatyModuleNode")
require(BASE_PATH .. "chessDialogScene");
require("chess/include/downLoadingScrollView");

SociatyInviteDialog = class(ChessDialogScene,false);

SociatyInviteDialog.APPLY_STATUS = 1
SociatyInviteDialog.INVITE_STATUS = 2

function SociatyInviteDialog.ctor(self)
    super(self,sociaty_invite_dialog_view);

    self.select_status = SociatyInviteDialog.APPLY_STATUS
    self.applyMsg = {}
    self.isFirstSend = true 
    self.applyListNum = 0

    self:setShieldClick(self,self.dismiss)
    self.mBg            = self.m_root:getChildByName("bg")
    self.mBg:setEventTouch(self,function()end)
    self.mCloseBtn      = self.mBg:getChildByName("close_btn")
    self.mCloseBtn:setOnClick(self,self.dismiss)
--    self.mSendItemsList = self.mBg:getChildByName("sendItemsList")
    self.btn_view = self.mBg:getChildByName("btn_view")
    self.apply_btn = self.btn_view:getChildByName("left_btn")
    self.btn_line = self.btn_view:getChildByName("line")
    self.apply_view = self.mBg:getChildByName("apply_view")
    self.apply_btn_text = self.apply_btn:getChildByName("text")
    self.apply_btn:setOnClick(self,function()
        self.select_status = SociatyInviteDialog.APPLY_STATUS
        self:switchBtnStatus()
        self:switchListView()
        self:updataListView()
    end)
    self.invite_btn = self.btn_view:getChildByName("right_btn")
    self.invite_btn_text = self.invite_btn:getChildByName("text")
    self.invite_btn:setOnClick(self,function()
        self.select_status = SociatyInviteDialog.INVITE_STATUS
        self:switchBtnStatus()
        self:switchListView()
        self:updataListView()
    end)
    local sociatyData = UserInfo.getInstance():getUserSociatyData();
    if next(sociatyData) and sociatyData.guild_role then
        if tonumber(sociatyData.guild_role) == 3 then
            self.select_status = SociatyInviteDialog.INVITE_STATUS
            self.apply_btn:setVisible(false);
            self.btn_line:setVisible(false);
            self.invite_btn:setVisible(true);
            self.invite_btn:setSize(636);
        else
            self.select_status = SociatyInviteDialog.APPLY_STATUS
            self.apply_btn:setVisible(true);
            self.btn_line:setVisible(true);
            self.invite_btn:setVisible(true);
            self.invite_btn:setSize(315);
        end;
    end;
    self.apply_list = new(DownLoadingScrollView, 0, 0, 638,648)
    self.apply_list:setAlign(kAlignTop)
    self.apply_list:setOnLoadEvent(self,self.getApplyMsg)
    self.apply_view:addChild(self.apply_list)
    self.invite_list = self.mBg:getChildByName("invite_list_view")
    self.invite_list:setVisible(false)

    self:switchListView()
    self:switchBtnStatus()
    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)
end

function SociatyInviteDialog.dtor(self)
    self.mDialogAnim:stopAnim()
end

function SociatyInviteDialog:show()
    self.super.show(self,self.mDialogAnim.showAnim)
	EventDispatcher.getInstance():register(Event.Call,self,self.onNativeCallDone);
    self:resetSendItems()
    self:updataListView()
end

function SociatyInviteDialog:dismiss()
    self.super.dismiss(self,self.mDialogAnim.dismissAnim)
	EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeCallDone);
end

function SociatyInviteDialog:setData(data)
    self.mSociatyData = data
end

function SociatyInviteDialog:setCallBackFunc(obj,func)
    self.cb_obj = obj
    self.cb_func = func
end

function SociatyInviteDialog:resetMemberList()
--    if self.cb_obj and type(self.cb_func) == "function" then
--        self.cb_func(self.cb_obj)
--    end
    local ret = {};
    ret.guild_id = self.mSociatyData.id  or 0;
    ret.limit = 10;
    ret.offset = index or 0;
    ChessSociatyModuleController.getInstance():onGetSociatyMemberInfo(ret)
end

function SociatyInviteDialog:resetSendItems()
    local data = {}
    local chatRoomConfig = UserInfo.getInstance():getChatRoomList(true);
    local score = UserInfo.getInstance():getScore()
    if chatRoomConfig then
        for _,room in ipairs(chatRoomConfig) do
            local minScore = tonumber(room.min_score) or 0
            if score >= minScore then
                local item = {}
                item.viewType = 1
                item.roomData = room
                item.sociatyData = self.mSociatyData
                item.handler = self
                table.insert(data,item)
            end
        end
    end
    local firendsDatas = FriendsData.getInstance():getFrendsListData()
    if firendsDatas then
        for _,firendsData in ipairs(firendsDatas) do
            local item = {}
            item.viewType = 2
            item.firendsData = firendsData
            item.sociatyData = self.mSociatyData
            item.handler = self
            table.insert(data,item)
        end
    end
    delete(self.mAdapter)

    if #data < 1 then return end
    if not self.mSociatyData then return end

    self.mAdapter = new(CacheAdapter,SociatyInviteItem,data)
    self.invite_list:setAdapter(self.mAdapter)
end

function SociatyInviteDialog:onUpdateUserData(data)
    if self.mAdapter and self.mAdapter.m_views then
        for _,view in pairs(self.mAdapter.m_views) do
            if view.mData and view.mData.viewType == 2 then
                for _,info in ipairs(data) do
                    if view.mData.firendsData == info.mid then
                        view:updateFriendsView(info)
                        break
                    end
                end
            end
        end
    end
end

function SociatyInviteDialog.onHttpRequestsCallBack(self,cmd, ...)
    Log.i("SociatyInviteDialog.onHttpRequestsCallBack");
	if self.s_httpRequestsCallBackFuncMap[cmd] then
     	self.s_httpRequestsCallBackFuncMap[cmd](self,...);
	end 
end

function SociatyInviteDialog.onNativeCallDone(self ,param , ...)
	if self.s_nativeEventFuncMap[param] then
		self.s_nativeEventFuncMap[param](self,...);
	end
end

function SociatyInviteDialog.switchBtnStatus(self)
    if self.select_status == SociatyInviteDialog.APPLY_STATUS then
        self.apply_btn:setEnable(false)
        self.invite_btn:setEnable(true)
        self.apply_btn_text:setColor(255,240,165)
        self.invite_btn_text:setColor(190,155,135)
    elseif self.select_status == SociatyInviteDialog.INVITE_STATUS then
        self.apply_btn:setEnable(true)
        self.invite_btn:setEnable(false)
        self.invite_btn_text:setColor(255,240,165)
        self.apply_btn_text:setColor(190,155,135)
    end
end

function SociatyInviteDialog.switchListView(self)
    local ret = (self.select_status == SociatyInviteDialog.APPLY_STATUS) and true or false
    self.apply_list:setVisible(ret)
    self.invite_list:setVisible(not ret)
end

function SociatyInviteDialog.updataListView(self)
    if self.select_status == SociatyInviteDialog.APPLY_STATUS then
        self:getApplyMsg()
    elseif self.select_status == SociatyInviteDialog.INVITE_STATUS then

    end
end

--data = {mid = "10000112",score = "400",mnick = "223",apply_time="1486605516" ,iconType=0, icon_url-- =""};

function SociatyInviteDialog.getApplyMsg(self)
    if not self.mSociatyData then return end
    local tab = {}
    tab.guild_id = self.mSociatyData.id 
    tab.limit = 10
    tab.offset = self.applyListNum;
    local post = {}
    post.param = tab
    HttpModule.getInstance():execute2(HttpModule.s_cmds.getSociatyApplyMsg,post,function(isSuccess,resultStr)--,httpRequest)
        if isSuccess then
            local jsonData = json.decode(resultStr)
            local data = jsonData.data
            if type(data) ~= "table" or next(data) == nil then 

                return 
            end
            if self.isFirstSend then
                self.applyMsg = {}
                self.applyListNum = 0
                self.apply_list:removeAllChildren(false)
                self.isFirstSend = false
            end
            for k,v in pairs(data) do
                if v then
                    self.applyListNum = self.applyListNum + 1
                    v.guild_id = self.mSociatyData.id  or 0;
                    table.insert(self.applyMsg,v)
                    local node = new(ChessSociatyModuleNode,v,ChessSociatyModuleNode.s_apply_mode,self)
                    self.apply_list:addChild(node)
                end
            end
        else

        end
    end);
end

--[Comment]
--踢出成员/管理申请
function SociatyInviteDialog.delMemberTab(self,nodeType,nodeHandler,id)
    if not nodeType or not nodeHandler then return end
    if nodeType == ChessSociatyModuleNode.s_member_mode or nodeType == ChessSociatyModuleNode.s_vice_mode then
--        self.m_member_lit:removeChild(nodeHandler,true)
--        self.m_member_lit:updateScrollView()
--        if self.memberListNum > 0 then
--            self.memberListNum = self.memberListNum - 1
--        end
--        SociatyModuleData.getInstance():deleteSociatyMember(id)
    elseif nodeType == ChessSociatyModuleNode.s_apply_mode then
        self.apply_list:removeChild(nodeHandler,true)
        self.apply_list:updateScrollView()
        for k,v in pairs(self.applyMsg) do
            if v then
                if tonumber(v.mid) == id then
                    table.remove(self.applyMsg,k);
                    if self.applyListNum > 0 then
                        self.applyListNum = self.applyListNum - 1
                    end
                    return
                end
            end 
        end
    end
end

SociatyInviteDialog.s_httpRequestsCallBackFuncMap  = {
};

SociatyInviteDialog.s_nativeEventFuncMap = {
    [kFriend_UpdateUserData]        = SociatyInviteDialog.onUpdateUserData;
}


require(VIEW_PATH .. "sociaty_invite_dialog_list_item1")
require(VIEW_PATH .. "sociaty_invite_dialog_list_item2")
SociatyInviteItem = class(GameLayer,false)

function SociatyInviteItem:ctor(data)
    self.mData = data
    if self.mData.viewType == 1 then
        self:initChatRoomView()
    elseif self.mData.viewType == 2 then
        self:initFriendsView()
    else
        super(self,"")
    end
end

function SociatyInviteItem:initChatRoomView()
    super(self,sociaty_invite_dialog_list_item1)
    local w,h = self.m_root:getSize()
    self:setSize(w,h)
    self.mIcon = self.m_root:getChildByName("icon")
    self.mName = self.m_root:getChildByName("name")
    self.mShareBtn = self.m_root:getChildByName("share_btn")
    
    local data = self.mData.roomData
    local file = ""
    if tonumber(data.id) and tonumber(data.id) == 1000 then
        file = "common/icon/dashi.png"
    elseif tonumber(data.id) and tonumber(data.id) == 1001 then
        file = "common/icon/tongcheng.png"
    else
        file = "common/icon/world.png"
    end

    self.mIcon:setFile(file)
    self.mName:setText(data.name)
    self.mShareBtn:setOnClick(self,self.onRoomShareBtnClick)
    self.mShareBtn:setSrollOnClick()
end

function SociatyInviteItem:onRoomShareBtnClick()
    -- 同城聊天要特殊处理
    local data = self.mData.roomData
    if tonumber(data.id) and tonumber(data.id) == 1001 then 
        if UserInfo.getInstance():getProvinceCode() == 0 then
            if self.mData.handler then
                self.mData.handler:dismiss()
            end
            ChessToastManager.getInstance():showSingle("请先设置所在地区");
            if not self.m_locate_city_dialog then
                self.m_locate_city_dialog = new(CityLocatePopDialog);
            end
            self.m_locate_city_dialog:show();
            return
        end
        self:sendChatRoomMsg(UserInfo.getInstance():getProvinceCode());
    else
--        ToolKit.schedule_repeat_time(self,function(self,a,b,c,num) 
--            ChessToastManager.getInstance():showSingle(num.."");
            self:sendChatRoomMsg(data.id);
--        end,1000,100);
    end
    ChessToastManager.getInstance():showSingle("发送成功");
end

function SociatyInviteItem:sendChatRoomMsg(roomId)
    StatisticsManager.getInstance():onCountInvitePlayChess(StatisticsManager.SHARE_WAY_CHAT);
    local params = {};
    params.method = "showSociatyInfoDialog";
    params.time   = os.time()
    params.sociaty_id    = self.mData.sociatyData.id;
--    params.name          = self.mData.sociatyData.name;
    params.mark          = self.mData.sociatyData.mark
    local msgdata = {};
	msgdata.room_id = roomId;
	msgdata.msg = SchemesProxy.getMySchemesUrl(params);
	msgdata.name = UserInfo.getInstance():getName();
	msgdata.uid = UserInfo.getInstance():getUid();
	OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_USER_CHAT_MSG,msgdata);
    -- 发送完消息需要离开房间
	local info = {};
	info.room_id = roomId;
	info.uid = UserInfo.getInstance():getUid();
    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_LEAVE_ROOM,info);
    if self.mData.handler then
        self.mData.handler:dismiss()
    end
end

function SociatyInviteItem:initFriendsView()
    super(self,sociaty_invite_dialog_list_item2)
    local w,h = self.m_root:getSize()
    self:setSize(w,h)
    self.mHeadBg    = self.m_root:getChildByName("head_bg")
    self.mName      = self.m_root:getChildByName("name")
    self.mLevelIcon = self.m_root:getChildByName("level_icon")
    self.mScoreTxt  = self.m_root:getChildByName("score_txt")
    self.mVipFrame  = self.m_root:getChildByName("vip_frame")
    self.mHeadMask  = new(Mask,UserInfo.DEFAULT_ICON[1],"common/background/head_bg_92.png")
    self.mHeadMask:setSize(90,90)
    self.mHeadMask:setAlign(kAlignCenter)
    self.mHeadBg:addChild(self.mHeadMask)

    local uid = self.mData.firendsData
    local info = FriendsData.getInstance():getUserData(uid)
    if not info then
        self.mName:setText(uid)
    else
        self:updateFriendsView(info)
    end

    self.mShareBtn  = self.m_root:getChildByName("share_btn")
    self.mShareBtn:setOnClick(self,self.onFriendsShareBtnClick)
    self.mShareBtn:setSrollOnClick()
end

function SociatyInviteItem:onFriendsShareBtnClick()
    ChessToastManager.getInstance():showSingle("发送成功");
    StatisticsManager.getInstance():onCountInvitePlayChess(StatisticsManager.SHARE_WAY_CHAT);
    local params = {};
    params.method = "showSociatyInfoDialog";
    params.time   = os.time()
    params.sociaty_id    = self.mData.sociatyData.id;
--    params.name          = self.mData.sociatyData.name;
    params.mark          = self.mData.sociatyData.mark
    local msgdata = {};
    msgdata.msg = SchemesProxy.getMySchemesUrl(params);
    msgdata.target_uid = self.mData.firendsData
    msgdata.isNew = 1;
    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_CHAT_MSG2,msgdata);
    --[Comment]
    -- 因为自己发送的聊天数据响应发送成功在hallchatdialog里面  不会响应 这边先提前存   有一定bug
    FriendsData.getInstance():addChatDataByUid(tonumber(self.mData.firendsData), msgdata.msg);
    if self.mData.handler then
        self.mData.handler:dismiss()
    end
end



function SociatyInviteItem:updateFriendsView(data)
    if self.mData.viewType ~= 2 or self.mData.firendsData ~= data.mid then return end
    
    self.mName:setText(data.mnick or "博雅象棋")
    self.mScoreTxt:setText(data.score)
    self.mLevelIcon:setFile( string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevelByScore(data.score)))

    if data.iconType == -1 then
        self.mHeadMask:setUrlImage(data.icon_url);
    else
        self.mHeadMask:setFile(UserInfo.DEFAULT_ICON[data.iconTyp] or UserInfo.DEFAULT_ICON[1]);
    end
    local frameRes = UserSetInfo.getInstance():getFrameRes(data.my_set.picture_frame);
    if frameRes and frameRes.frame_res then
        self.mVipFrame:setVisible(true)
        self.mVipFrame:setFile( string.format(frameRes.frame_res,110));
    else
        self.mVipFrame:setVisible(false)
    end
end