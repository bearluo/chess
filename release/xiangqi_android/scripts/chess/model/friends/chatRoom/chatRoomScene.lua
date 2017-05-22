require(BASE_PATH .. "chessScene");
require(MODEL_PATH .. "friends/friendChat/friendChatScene");

ChatRoomScene = class(FriendChatScene);

ChatRoomScene.s_controls = 
{
    back_btn       = 1;
    check_friend   = 2;
    content_view   = 3;
    load_view      = 4;
    chat_msg       = 5;
    send_msg       = 6;
    friend_name    = 7;
}

ChatRoomScene.s_cmds = 
{
	get_history_msg     = 1;
    send_msg_status     = 2;
    recv_chat_msg       = 3;
    change_other_icon   = 4;
    init_msg            = 5;
    change_icon         = 6;
}

ChatRoomScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = ChatRoomScene.s_controls;
    self.m_room_data = controller.m_state.m_room_data; --m_state.m_room_data;
    self.m_other_user_info = ChatRoomData.getInstance():getChatUserInfo();
    self.m_view = {};
	self:initChat();
end

ChatRoomScene.resume = function(self)
    self.super.resume(self);
end

ChatRoomScene.pause = function(self)
    self.super.pause(self);
end

ChatRoomScene.dtor = function(self)
	ShowMessageAnim.deleteAll();
end

-------------------------- func ---------------------------

ChatRoomScene.initChat = function(self)
    self.super.init(self);
	self:getControl(self.m_ctrls.check_friend):setVisible(false);
	self.m_friend_name:setText(self.m_room_data.name or "同城棋友聊天室");
end

ChatRoomScene.resetUnreadMsgNum = function(self)
end

ChatRoomScene.initHistoryMsg = function(self, historyMsg)
	local msgData = {};
    if not historyMsg then
        return;
    end

    msgData = historyMsg;
    local w,h = self.m_content_view:getSize();
    for i = 1, #msgData do
        ------------------------ item time -------------------------------------------------------
        -- 根据已有的时间确定itemtime的显示规则
        if i == 1 then
            msgData[i].isShowTime = true;
        elseif ToolKit.isSecondDay(msgData[i].time) then
            if ToolKit.isInTenMinute(msgData[i].time,msgData[i-1].time) then
                msgData[i].isShowTime = false;   
            else
                msgData[i].isShowTime = true;
            end;
        elseif ToolKit.isInTenMinute(msgData[i].time,msgData[i-1].time) then
            msgData[i].isShowTime = false;
        else
            msgData[i].isShowTime = true;
        end;
        local otherUserInfo = self:getOtherUserInfo(msgData[i]);
        local child = new(ChatRoomMsgItem, msgData[i], w, h, 0, otherUserInfo);
        self.m_view[i] = child;
        self.m_msg_list:addChild(child);
    end  
    self.m_msg_list:gotoBottom();
end

ChatRoomScene.getOtherUserInfo = function(self,msgData)
    if self.m_other_user_info then
        for i,v in pairs(self.m_other_user_info) do
            if v.uid == msgData.uid then  -- or msgData.send_uid == v.uid 
                return v;
            end
        end
    end
    return nil;
end

------------继承 friendChatScene 方法--------------
ChatRoomScene.onEditTextChange = function(self,str)
    self.super.onEditTextChange(self,str);
end

ChatRoomScene.setSendBtnStatus = function(self,enable)
    self.super.setSendBtnStatus(self,enable);
end
---------------------------------------------------

ChatRoomScene.onBack = function(self)
	self:requestCtrlCmd(ChatRoomController.s_cmds.onBack);
end

ChatRoomScene.onSendMsg = function(self)
	self.m_chat_msg = self.m_edit_text:getText() or "";
	self.m_chat_msg = GameString.convert2UTF8(self.m_chat_msg);
    string.lenutf8(GameString.convert2UTF8(self.m_chat_msg) or "");
	local msgdata = {};
	msgdata.room_id = self.m_room_data.id;
	msgdata.msg = self.m_chat_msg;
	msgdata.name = UserInfo.getInstance():getName();
	msgdata.uid = UserInfo.getInstance():getUid();
	self:requestCtrlCmd(ChatRoomController.s_cmds.send_msg, msgdata);
end

ChatRoomScene.onGetHistroyMsg = function(self, msgUnread, total_num, curr_page)
	local msgData = {};
    if not msgUnread then
        return;
    end

    local temp = self.m_msg_list:getChildren();
    msgData = msgUnread;
    local w,h = self.m_content_view:getSize();

    if #temp ~= 0 then
        msgData[0] = {};
        msgData[0].time = temp[#temp].data.time;
    end
    local view_index = #self.m_view;
    for i = 1, #msgData do --#msgData - 1
        ------------------------ item time -------------------------------------------------------
        -- 根据已有的时间确定itemtime的显示规则
        if i == 1 and #temp == 0 then
            msgData[i].isShowTime = true;
        elseif ToolKit.isSecondDay(msgData[i].time) then
            if ToolKit.isInTenMinute(msgData[i].time,msgData[i-1].time) then
                msgData[i].isShowTime = false;   
            else
                msgData[i].isShowTime = true;
            end;
        elseif ToolKit.isInTenMinute(msgData[i].time,msgData[i-1].time) then
            msgData[i].isShowTime = false;
        else
            msgData[i].isShowTime = true;
        end;
        ------------------------ item time -------------------------------------------------------
        local otherUserInfo = self:getOtherUserInfo(msgData[i]);
        local child = new(ChatRoomMsgItem, msgData[i], w, h, 0, otherUserInfo)
        self.m_view[view_index + i] = child;
        self.m_msg_list:addChild(child);
    end
    --删除多于50条的信息 #msgData
    if #self.m_msg_list:getChildren() > 15 then
        self.m_msg_list:removeChildByPos(2, 4, self.m_view);
    end
    self.m_msg_list:gotoBottom();
end

ChatRoomScene.msgSendStatus = function(self, data)
	if data.status ~= 0 then
--        ShowMessageAnim.play(self.m_root,"消息发送失败");
        local message =  "消息发送失败"; 
        ChessToastManager.getInstance():showSingle(message); 
    end
end

ChatRoomScene.recvChatRoomMsg = function(self, chatRoomMsg, userInfo, label)
	local w,h = self.m_content_view:getSize();
    local data = {};
    data = chatRoomMsg;
--    data.msg = chatRoomMsg.msg;
--    data.msg_id = chatRoomMsg.msg_id;
--    data.time = chatRoomMsg.time;
--    data.uid = chatRoomMsg.uid;
    local num = #(self.m_msg_list:getChildren());
    if num == 0 then
        data.isShowTime = true;
    else
        local item = self.m_msg_list:getChildren()[num]; 
        if ToolKit.isSecondDay(data.time) then
            data.isShowTime = true;
        else
            if ToolKit.isInTenMinute(item.data.time, data.time) then
                data.isShowTime = false;
            else
                data.isShowTime = true;
            end;
        end;
    end
    local child = new(ChatRoomMsgItem, data,w, h, 0, userInfo);
    self.m_view[#self.m_view + 1] = child;
    self.m_msg_list:addChild(child);

    if label then
        self.m_edit_text:setText(nil);
        self:setSendBtnStatus(false);
        self.m_msg_list:gotoBottom();
    end
    --判断是否在最底部，否，不进行下滑
    if #self.m_msg_list:getChildren() > 15 then
        self.m_msg_list:removeChildByPos(2, 4, self.m_view);
    end
    self.m_msg_list:gotoBottom();
end

ChatRoomScene.onChangeUserIcon = function(self, data)
	if #data == 0 then
        return;
    end 
    local child = self.m_msg_list:getChildren();

    for i = 1, #data do
        local chatItem = child[i]; 
        if data[i].icon_url then
            for j = #child, 1, -1 do
                if child[j].m_up_uid == data[i].uid then
                    chatItem.m_file_icon:setUrlImage(data[i].icon_url);
                end
            end
        elseif data[i].iconType == 0 then
        	self:updateChatUserIcon(child,data[i],true);  
        elseif data[i].iconType > 0 then
        	self:updateChatUserIcon(child,data[i],false);
        end
    end
end

ChatRoomScene.updateChatUserIcon = function(self, child, data, label)
	for j = 1, #child do
		local chatItem = child[j]; 
		if chatItem.m_up_uid == data.uid then
			if label then
				chatItem.m_file_icon:setFile(ChatRoomScene.default_icon);
			else
				chatItem.m_file_icon:setFile(UserInfo.DEFAULT_ICON[data.iconType] or UserInfo.DEFAULT_ICON[1]);
			end
		end
	end;  
end

ChatRoomScene.onGetDownloadIcon = function(self, data)
    if self.m_msg_list and data then
        local child = self.m_msg_list:getChildren();
        for i = #child, 1, -1 do
            local chatItem = child[i]; 
            if chatItem.m_up_uid == tonumber(data[i].what) then
                chatItem:updateUserIcon(data.ImageName);
            end
        end;
    end;  
end
------------------------------- config ------------------------------------
ChatRoomScene.s_controlConfig = 
{
	[ChatRoomScene.s_controls.back_btn] = {"tittle_view","tittle_bg","back"};
	[ChatRoomScene.s_controls.content_view] = {"content_view"};
	[ChatRoomScene.s_controls.load_view] = {"load_view"};
	[ChatRoomScene.s_controls.chat_msg] = {"bottom_view","chat_bg","chat_msg"};
	[ChatRoomScene.s_controls.send_msg] = {"bottom_view","chat_bg","send"};
	[ChatRoomScene.s_controls.friend_name] = {"tittle_view","tittle_bg","tittle","friendName"};
	[ChatRoomScene.s_controls.check_friend] = {"tittle_view","tittle_bg","check"};
}

ChatRoomScene.s_controlFuncMap = 
{
	[ChatRoomScene.s_controls.back_btn] = ChatRoomScene.onBack;
	[ChatRoomScene.s_controls.send_msg] = ChatRoomScene.onSendMsg;
}

ChatRoomScene.s_cmdConfig = 
{
	[ChatRoomScene.s_cmds.get_history_msg]        = ChatRoomScene.onGetHistroyMsg;
    [ChatRoomScene.s_cmds.send_msg_status]        = ChatRoomScene.msgSendStatus;
    [ChatRoomScene.s_cmds.recv_chat_msg]          = ChatRoomScene.recvChatRoomMsg;
    [ChatRoomScene.s_cmds.change_other_icon]      = ChatRoomScene.onChangeUserIcon;
    [ChatRoomScene.s_cmds.init_msg]               = ChatRoomScene.initHistoryMsg;
    [ChatRoomScene.s_cmds.change_icon]            = ChatRoomScene.onGetDownloadIcon;   
}

----------------------------------------------------------------------------------
ChatRoomScene.default_icon = "userinfo/women_head02.png";
ChatRoomMsgItem = class(FriendChatMsgItem);

ChatRoomMsgItem.ctor = function(self,data,viewW,viewH,itemType, otherUserInfo)
    self.m_friend_icon_frame:setEventTouch(self,self.onEventTouch);
end

ChatRoomMsgItem.onEventTouch = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
    print_string("点击头像。。。");
    local user_id = 0;
    user_id = self.data.uid;
    if finger_action == kFingerUp then
        StateMachine.getInstance():pushState(States.FriendsInfo,StateMachine.STYPE_CUSTOM_WAIT,nil,user_id);
    end
end

ChatRoomMsgItem.dtor = function(self)

end