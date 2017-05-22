require(BASE_PATH .. "chessDialogScene");
require(VIEW_PATH .. "invite_friends_dialog_view")
require("chess/util/statisticsManager");

InviteFriendsDialog = class(ChessDialogScene,false);

function InviteFriendsDialog.ctor(self)
    super(self,invite_friends_dialog_view);
    self.mBg = self.m_root:getChildByName("bg");
    self.mCloseBtn = self.mBg:getChildByName("close_btn");
    self.mCloseBtn:setOnClick(self,self.dismiss);
    self.mContentView = self.mBg:getChildByName("content_view");
    self.mChatRoomList = self.mBg:getChildByName("chat_room_list");
    self.mDialogAnim = AnimDialogFactory.createMoveUpAnim(self)
end

function InviteFriendsDialog.dtor(self)
    delete(self.m_locate_city_dialog)
    self.mDialogAnim.stopAnim()
end


function InviteFriendsDialog.show(self,data)
    self.mData = data;
    local params = {};
    params.method = "gotoPrivateRoom";
    params.tid = data.tid;
    params.pwd = data.pwd;
    params.uid = UserInfo.getInstance():getUid()
    self.mInviteMsg = params;
    self:resetContentView();
    self:resetChatRoomList();
    self.super.show(self,self.mDialogAnim.showAnim);
end

function InviteFriendsDialog.dismiss(self)
    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
end

function InviteFriendsDialog.resetContentView(self)
    self.mContentView:removeAllChildren();
    local items = {};
    local item  = {
        ["icon"]    = "common/icon/pyq.png";
        ["title"]   = "朋友圈";
        ["event"]   = InviteFriendsDialog.sendToPYQ;
    }
    table.insert(items,item);
    local item  = {
        ["icon"]    = "common/icon/wechat.png";
        ["title"]   = "微信";
        ["event"]   = InviteFriendsDialog.sendToWX;
    }
    table.insert(items,item);
    local item  = {
        ["icon"]    = "common/icon/lts.png";
        ["title"]   = "聊天室";
        ["event"]   = InviteFriendsDialog.sendToLTS;
    }
    table.insert(items,item);
    local item  = {
        ["icon"]    = "common/icon/qq_icon.png";
        ["title"]   = "QQ";
        ["event"]   = InviteFriendsDialog.sendToQQ;
    }
    table.insert(items,item);
    local item  = {
        ["icon"]    = "common/icon/sms.png";
        ["title"]   = "短信";
        ["event"]   = InviteFriendsDialog.sendToSMS;
    }
    table.insert(items,item);
    self.mContentView:setVisible(true);
    local x,y = 0,0;
    for i,param in ipairs(items) do
        local group = self:getContentItem(param);
        local w,h = group:getSize();
        group:setPos(x,y);
        x = x+w+5;
        if i%3 == 0 then
            x = 0;
            y = y+h;
        end
        self.mContentView:addChild(group);
    end
end

function InviteFriendsDialog.getContentItem(self,data)
    local group = new(Button,"drawable/blank.png");
    group:setSize(200,220);

    local icon = new(Image,data.icon);
    icon:setAlign(kAlignTop);
    icon:setPos(0,20);
    icon:setSize(130,130);
    group:addChild(icon);

    local title = new(Text,data.title, nil, nil, kAlignBottom, nil, 30, 80, 80, 80);
    title:setAlign(kAlignBottom);
    title:setPos(0,25);
    group:addChild(title);

    group:setOnClick(self,data.event);
    group:setSrollOnClick();
    return group;
end

function InviteFriendsDialog.resetChatRoomList(self)
    self.mChatRoomList:removeAllChildren();
    self.mChatRoomList:setVisible(false);
    local chatRoomConfig = UserInfo.getInstance():getChatRoomList(true);
    local x,y = 22,0;
    for i,param in ipairs(chatRoomConfig) do
        local group = self:getChatRoomItem(param);
        local w,h = group:getSize();
        group:setPos(x,y);
        y = y+h;
        self.mChatRoomList:addChild(group);
    end
end

function InviteFriendsDialog.getChatRoomItem(self,data)
    local group = new(Button,"drawable/blank.png");
    group:setSize(600,100);

    local icon = new(Image,"common/icon/lts_small.png");
    icon:setAlign(kAlignLeft);
    icon:setPos(17,0);
    group:addChild(icon);

    local dec = new(Image,"common/decoration/line_2.png");
    dec:setAlign(kAlignBottom);
    dec:setSize(600);
    group:addChild(dec);

    local title = new(Text,data.name, nil, nil, kAlignBottom, nil, 28, 125,80,65);
    title:setAlign(kAlignLeft);
    title:setPos(84,0);
    group:addChild(title);

    group:setOnClick(self,function()
            -- 同城聊天要特殊处理
            if tonumber(data.id) and tonumber(data.id) == 1001 then 
                if UserInfo.getInstance():getProvinceCode() == 0 then
                    self:dismiss();
                    ChessToastManager.getInstance():showSingle("请先设置所在地区");
                    if not self.m_locate_city_dialog then
                        self.m_locate_city_dialog = new(CityLocatePopDialog);
                    end
                    self.m_locate_city_dialog:show();
                    return
                end
                self:sendChatRoomMsg(UserInfo.getInstance():getProvinceCode());
            else
                self:sendChatRoomMsg(data.id);
            end
            ChessToastManager.getInstance():showSingle("发送成功");
        end
    );
    group:setSrollOnClick();
    return group;
end

function InviteFriendsDialog.sendChatRoomMsg(self,roomId)
    StatisticsManager.getInstance():onCountInvitePlayChess(StatisticsManager.SHARE_WAY_CHAT);
    local msgdata = {};
	msgdata.room_id = roomId;
    self.mInviteMsg.time   = os.time()
	msgdata.msg = SchemesProxy.getMySchemesUrl(self.mInviteMsg);
	msgdata.name = UserInfo.getInstance():getName();
	msgdata.uid = UserInfo.getInstance():getUid();
	OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_USER_CHAT_MSG,msgdata);
    -- 发送完消息需要离开房间
	local info = {};
	info.room_id = roomId;
	info.uid = UserInfo.getInstance():getUid();
    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_LEAVE_ROOM,info);
    self:dismiss();
end

InviteFriendsDialog.DEFAULT_TEXT = "“我已在博雅象棋私人房%s(%d),备下棋局，等你来战哦！";

function InviteFriendsDialog.sendToPYQ(self)
    self:dismiss()
    self:getShareWebData(function(data)
        StatisticsManager.getInstance():onCountInvitePlayChess(StatisticsManager.SHARE_WAY_PYQ);
        if data then
            if kPlatform == kPlatformIOS then 
                data.isToSession = false;
                dict_set_string(SHARE_TEXT_TO_PYQ_MSG , SHARE_TEXT_TO_PYQ_MSG .. kparmPostfix , json.encode(data));
            else
                dict_set_string(SHARE_TEXT_TO_PYQ_MSG , SHARE_TEXT_TO_PYQ_MSG .. kparmPostfix , json.encode(data));
            end;
            call_native(SHARE_TEXT_TO_PYQ_MSG);
        end
    end)
    
end

function InviteFriendsDialog.sendToWX(self)
    self:dismiss();
    self:getShareWebData(function(data)
        StatisticsManager.getInstance():onCountInvitePlayChess(StatisticsManager.SHARE_WAY_WECHAT);
        if data then
            if kPlatform == kPlatformIOS then 
                data.isToSession = true;
                dict_set_string(SHARE_TEXT_TO_WEICHAT_MSG , SHARE_TEXT_TO_WEICHAT_MSG .. kparmPostfix , json.encode(data));
            else
                dict_set_string(SHARE_TEXT_TO_WEICHAT_MSG , SHARE_TEXT_TO_WEICHAT_MSG .. kparmPostfix , json.encode(data));
            end;
            call_native(SHARE_TEXT_TO_WEICHAT_MSG);
        end
    end)
end

function InviteFriendsDialog.sendToLTS(self)
    self.mChatRoomList:setVisible(true);
    self.mContentView:setVisible(false);
end

function InviteFriendsDialog.sendToQQ(self)
    self:dismiss();
    self:getShareWebData(function(data)
        StatisticsManager.getInstance():onCountInvitePlayChess(StatisticsManager.SHARE_WAY_QQ);
        if data then
             if kPlatform == kPlatformIOS then 
                dict_set_string(SHARE_TEXT_TO_QQ_MSG , SHARE_TEXT_TO_QQ_MSG .. kparmPostfix , json.encode(data));
            else
                dict_set_string(SHARE_TEXT_TO_QQ_MSG , SHARE_TEXT_TO_QQ_MSG .. kparmPostfix , json.encode(data));
            end;       
            call_native(SHARE_TEXT_TO_QQ_MSG);
        end
    end)
end

function InviteFriendsDialog.sendToSMS(self)
    self:dismiss();
    self:getShareWebData(function(data)
        StatisticsManager.getInstance():onCountInvitePlayChess(StatisticsManager.SHARE_WAY_SMS);
        if data then
            if kPlatform == kPlatformIOS then 
                dict_set_string(SHARE_TEXT_TO_SMS_MSG , SHARE_TEXT_TO_SMS_MSG .. kparmPostfix , data.description .. data.url);
            else
                dict_set_string(SHARE_TEXT_TO_SMS_MSG , SHARE_TEXT_TO_SMS_MSG .. kparmPostfix , json.encode(data));
            end
            call_native(SHARE_TEXT_TO_SMS_MSG);
        end
    end)
end

function InviteFriendsDialog.getShareWebData(self,callbackFunc)
    
    self.mInviteMsg.time   = os.time()
    local url = SchemesProxy.getWebSchemesUrl(self.mInviteMsg);

    local params = {}
    params.long_url = SchemesProxy.ToBase64(url)
    HttpModule.getInstance():execute2(HttpModule.s_cmds.IndexCreateShortUrl,params,function(isSuccess,resultStr)
        if not isSuccess then
            ChessToastManager.getInstance():showSingle("分享链接生成失败")
            return 
        end

        local params = json.decode(resultStr)

        if not params or tonumber(params.flag) ~= 10000 or not params.data then
            ChessToastManager.getInstance():showSingle("分享链接生成失败")
            return 
        end
        local tab = {}
        tab.url = params.data.short_url;
        tab.title = "私人房邀请";
        local name = RoomProxy.getInstance():getSelfRoomNameStr()
        tab.description = string.format(InviteFriendsDialog.DEFAULT_TEXT,name,self.mData.tid);
        callbackFunc(tab)
    end)
end