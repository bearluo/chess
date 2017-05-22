--region NewFile_1.lua
--Author : FordFan
--Date   : 2015/11/19
--入口: 好友信息界面
--好友聊天dialog
--endregion


require("view/view_config");
require(VIEW_PATH.."friend_chat_dialog");
require(BASE_PATH.."chessDialogScene");

FriendChatDialog = class(ChessDialogScene,false);

FriendChatDialog.ctor = function(self,data)
     super(self,friend_chat_dialog);

     EventDispatcher.getInstance():register(Event.Call,self,self.onNativeCallDone);

     self.m_root_view = self.m_root;
     self.data = data;
     self.m_is_vip = nil;
     if data then
        self.m_is_vip = data.is_vip;
     end

     self.m_bg = self.m_root_view:getChildByName("bg");
     self.m_bg:setEventTouch(self.m_bg,function() end);

     self.m_title = self.m_bg:getChildByName("title");
     self.bottom_view = self.m_bg:getChildByName("bottom_edit");
     self.m_msg_edit = self.bottom_view:getChildByName("input_bg"):getChildByName("msg_edit");
     self.m_msg_edit:setHintText(GameString.convert2UTF8("点击此处输入聊天信息"),165,145,120);
--     local w,h = self.m_msg_edit:getSize();
--     self.m_msg_edit:setClip(0,0,w,h);
     local edit_w,edit_h = self.m_msg_edit:getSize();
     local edit_x,edit_y = self.m_msg_edit:getPos();
     self.m_msg_edit:setClip(edit_x,edit_y,edit_w,edit_h);
     self.m_msg_edit:setOnTextChange(self, self.onEditTextChange);

     self.m_send_btn = self.bottom_view:getChildByName("send_btn");
--     self.m_send_btn:setEnable(false);
     self.m_send_btn:setOnClick(self,self.onSendMsg);

      local func =  function(view,enable)
        local tip = view:getChildByName("text");
        if tip then
            if not enable then
                tip:setColor(255,255,255);
                tip:addPropScaleSolid(1,1.1,1.1,1);
            else
                tip:setColor(240,230,210);
                tip:removeProp(1);
            end
        end
    end

     self.m_send_btn:setOnTuchProcess(self.m_send_btn,func);
     self.m_send_text = self.m_send_btn:getChildByName("text");

     self.m_content_view = self.m_bg:getChildByName("content_view");
     local w,h = self.m_content_view:getSize();
     self.m_chat_list = new(ScrollView,0,0,w,h,true);
     self.m_chat_list:setAlign(kAlignCenter);
     self.m_chat_list_items = {}
     self.m_content_view:addChild(self.m_chat_list);

     if self.data then
        self.m_title:setText(self.data.mnick);
        self.m_chat_data = FriendsData.getInstance():getChatData(tonumber(self.data.mid));
        self:initChatList(self.m_chat_data);
    end
    -- 0 第一次打开弹窗 1表示弹窗已经存在
    self.is_new = 0;

    self:setShieldClick(self,self.dismiss);
    self:setVisible(false);

    self.m_close_btn = self.m_bg:getChildByName("close_btn");
    self.m_close_btn:setOnClick(self,self.dismiss);
end

FriendChatDialog.dtor = function(self)
    self.m_root_view = nil;
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeCallDone);
    delete(self.m_forbid_dialog)
end

FriendChatDialog.isShowing = function(self)
    return self:getVisible();
end

FriendChatDialog.show = function(self)
    self.super.show(self,false);
	self:setVisible(true);
    for i = 1,4 do 
        if not self.m_bg:checkAddProp(i) then
            self.m_bg:removeProp(i);
        end 
    end
    local w,h = self.m_bg:getSize();
--    local anim = self.m_bg:addPropTranslateWithEasing(1,kAnimNormal, 600, -1, nil, "easeOutBounce", 0,0, h, -h);
    local anim = self.m_bg:addPropTranslate(1,kAnimNormal,400,-1,0,0,h+25,0);
    if anim then
        anim:setEvent(self,function()
            self.m_bg:addPropTranslate(4,kAnimNormal,200,-1,0,0,0,-25);
            delete(anim);
            anim = nil;
        end);
    end
    local anim_end = new(AnimInt,kAnimNormal,0,1,600,-1);
    if anim_end then
        anim_end:setEvent(self,function()
            for i = 1,4 do 
                if not self.m_bg:checkAddProp(i) then
                    self.m_bg:removeProp(i);
                end 
            end
            delete(anim_end);
            anim_end = nil;
        end);
    end
    if not self.mRegister then
        self.mRegister = true
        OnlineSocketManagerProcesser.getInstance():register(FRIEND_CMD_CHAT_MSG2,self,self.onReceChatMsgState2)
    end
end

FriendChatDialog.dismiss = function(self)
    self.super.dismiss(self,false);
    for i = 1,4 do 
        if not self.m_bg:checkAddProp(i) then
            self.m_bg:removeProp(i);
        end 
    end
    local w,h = self.m_bg:getSize();
    local anim = self.m_bg:addPropTranslate(2,kAnimNormal,300,-1,0,0,0,h);
    self.m_bg:addPropTransparency(3,kAnimNormal,200,-1,1,0);
    if anim then
        anim:setEvent(self,function()
            self:setVisible(false);
            self.m_bg:removeProp(2);
            self.m_bg:removeProp(3);
            delete(anim);
        end);
    end
    
    if self.mRegister then
        self.mRegister = false
        OnlineSocketManagerProcesser.getInstance():unregister(FRIEND_CMD_CHAT_MSG2,self,self.onReceChatMsgState2)
    end
end

FriendChatDialog.onReceChatMsgState2 = function(self,packetInfo)
    if self:isForbidSendMsg(packetInfo) then return end
    if packetInfo and packetInfo.ret and tonumber(packetInfo.ret) then
        self:updataStatus(packetInfo.ret);
    end
end

FriendChatDialog.isForbidSendMsg = function(self,packetInfo)
    if packetInfo.forbid_time and packetInfo.forbid_time > 0 then
        local tip_msg = "很抱歉，您的账号被多次举报，经核实已被禁言，将于"..os.date("%Y-%m-%d %H:%M",packetInfo.forbid_time) .."解禁，感谢您的配合和理解。"
        if not self.m_forbid_dialog then
            self.m_forbid_dialog = new(ChioceDialog);
        end;
        self.m_forbid_dialog:setMode(ChioceDialog.MODE_SURE);
        self.m_forbid_dialog:setMessage(tip_msg);
        self.m_forbid_dialog:show();
        return true;
    end; 
    return false;
end;


function FriendChatDialog:getChatItem(data)
    local event,msgData = SchemesProxy.analyzeSchemesStr(data.msg);
    if type(event) == "function" then
        local params = {
            title = "";
            content = "";
            icon_img = "";
        }
        if msgData.method == "gotoCustomEndgateRoom" then
            params.title = "这残局尔等能破否？";
            params.content = "听闻尔等棋艺甚是精湛，不知此等残局尔等能顺利破否？！";
            params.icon_img = "common/board_03.png";
        elseif msgData.method == "showSociatyInfoDialog" then
            params.title = string.format("邀您加入棋社%s",msgData.name or "");
            params.content = string.format("大侠，诚意邀请您加入象棋棋社%s，id:%s",msgData.name or "",msgData.sociaty_id or 0);
            params.icon_img = (ChesssociatyModuleConstant.sociaty_icon[msgData.mask] or ChesssociatyModuleConstant.sociaty_icon[1]).file;
        elseif msgData.method == "gotoPrivateRoom" then
            params.title = "呔!某家在私人房,尔等速速来战!";
            params.content = "听闻尔等棋艺甚是精湛,速速前来对弈,某家要与尔等大战三百回合!尔等敢应战否？！";
            params.icon_img = "common/board_03.png";
        else
	        local item = new(FriendChatDialogItem,data);
            return item;
        end
        params.msgData = msgData
	    local item = new(FriendChatRoomSchemesItem,self,data,event,params);
        return item;
    end
    return new(FriendChatDialogItem, data)
end

FriendChatDialog.initChatList = function(self,data)
    local w,h = self.m_content_view:getSize();
    for i = 1, #self.m_chat_data do 
        ------------------------ item time -------------------------------------------------------
        -- 根据已有的时间确定itemtime的显示规则
        if i == 1 then
            self.m_chat_data[i].isShowTime = true;
        elseif ToolKit.isSecondDay(self.m_chat_data[i].time) then
            if ToolKit.isInTenMinute(self.m_chat_data[i].time,self.m_chat_data[i-1].time) then
                self.m_chat_data[i].isShowTime = false;   
            else
                self.m_chat_data[i].isShowTime = true;
            end;
        elseif ToolKit.isInTenMinute(self.m_chat_data[i].time,self.m_chat_data[i-1].time) then
            self.m_chat_data[i].isShowTime = false;
        else
            self.m_chat_data[i].isShowTime = true;
        end;
        ------------------------ item time -------------------------------------------------------

        local child = self:getChatItem(self.m_chat_data[i]);--,w,h);
        self.m_chat_list:addChild(child);
        self.m_chat_list_items[#self.m_chat_list_items+1] = child
        --判断(非好友留言)最后一条发出的消息，是否有回复
        if i == #self.m_chat_data then
            if UserInfo.getInstance():getUid() == self.m_chat_data[i].send_uid then
                self.m_isReceiveMsg = false; 
                self.m_msg_time = self.m_chat_data[i].time;
            else
                self.m_isReceiveMsg = true; 
                self.m_msg_time = self.m_chat_data[i].time;                
            end;
        end;
    end;
    self.m_chat_list:gotoBottom();
end

FriendChatDialog.onEditTextChange = function(self,str)
    if str == "" or str == nil then
        self:setSendBtnStatus(false);
    else
        self:setSendBtnStatus(true);
    end;
end

FriendChatDialog.setSendBtnStatus = function(self, enable)
    if enable then
        self.m_send_btn:setEnable(true);
        self.m_send_text:setColor(240,230,210);
        --发送按钮呼吸动画
--        self.m_send_btn:addPropColor(1,kAnimLoop,100000,-1,255,nil,0,83);
--        self.m_send_btn:addPropTransparency(1,kAnimLoop,600,-1,1,0.5);
    else
        self.m_send_btn:setEnable(false);
        self.m_send_text:setColor(240,230,210);
    end
end


FriendChatDialog.onSendMsg = function(self)
    if not self.m_isSendingMsg then
        if FriendsData.getInstance():isYourFriend(tonumber(self.data.mid))  ~= -1 then
            self:sendMsg(); 
        else
            if self.m_isReceiveMsg or ToolKit.isSecondDay(self.m_msg_time) then
                self:sendMsg(); 
                self.m_isReceiveMsg = false;
            else
                ChessToastManager.getInstance():showSingle("对方回复后，才可以继续留言",1500);
            end;
        end;
    else
--        ShowMessageAnim.play(self.m_root,"正在发送消息...");
    end;
end;

FriendChatDialog.sendMsg = function(self)
    self.m_isSendingMsg = true;
    self:setSendBtnStatus(false);
    ------ 发送服务器item --------
    self.m_chat_msg = self.m_msg_edit:getText() or "";
    self.m_chat_msg = GameString.convert2UTF8(self.m_chat_msg);
    if self.m_chat_msg == "" or  self.m_chat_msg == "" then
        self.m_isSendingMsg = false;
        self:setSendBtnStatus(true);
        ChessToastManager.getInstance():showSingle("消息不能为空！",800); 
		return        
    end;
    local data = {};
    self.m_chat_msg = self.m_msg_edit:getText() or "";
    self.m_chat_msg = GameString.convert2UTF8(self.m_chat_msg);
    data.msg = self.m_chat_msg;
    data.target_uid = tonumber(self.data.mid);
    data.isNew = self.is_new;
    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_CHAT_MSG2,data);
    self.is_new = 1;
end

FriendChatDialog.updataStatus = function(self,ret)
    if ret == 0 then
        ------- 本人聊天item -------
        local data ={}
        data.send_uid = UserInfo.getInstance():getUid();
        data.time = os.time();
        if ToolKit.isSecondDay(self.m_msg_time) then
            data.isShowTime = true;
        else
            if ToolKit.isInTenMinute(self.m_msg_time, data.time) then
                data.isShowTime = false;
            else
                data.isShowTime = true;
            end;
        end;
        self.m_msg_time = data.time;
        data.mnick = UserInfo.getInstance():getName();
        data.msg = self.m_chat_msg;
    --    local w,h = self.m_content_view:getSize();
        local child = self:getChatItem(data);
        self.m_chat_list:addChild(child);
        self.m_chat_list_items[#self.m_chat_list_items+1] = child
        local lens = string.lenutf8(GameString.convert2UTF8(self.m_chat_msg) or ""); 
        if lens > 140 then
            ShowMessageAnim.fontSize = 24;
            ShowMessageAnim.play(self.m_root,GameString.convert2UTF8("字数超过140，已截取显示"));        
        end;

        self.m_msg_edit:setText(nil);
        self.m_chat_list:gotoBottom();
    elseif ret and ret == 1 then
        local show = new(Node);
        local nodebg = new(Image,"common/background/chat_time_bg.png",nil,nil,68,68,16,16);
        nodebg:setSize(590,40);
        nodebg:setAlign(kAlignCenter);
        local msg = "*对方当前版本过低，暂不支持聊天功能";
        local text = new(Text,msg,nil,nil,nil,nil,32,80,80,80);
        text:setAlign(kAlignCenter);
        show:setSize(600,100);
        show:addChild(nodebg);
        show:addChild(text);
        show:setAlign(kAlignCenter);
        self.m_chat_list:addChild(show);
        self.m_chat_list:gotoBottom();
        self.m_isSendingMsg = false;
        return
    elseif ret and ret == 2 then -- 禁言
        self:setSendBtnStatus(true);
    elseif ret and ret == 3 then -- 屏蔽频繁发言
        self.m_isSendingMsg = false; 
        ChessToastManager.getInstance():showSingle("亲，不要频繁重复发言哦~",1500);
    end
    self.m_isSendingMsg = false;
    self:setSendBtnStatus(true);
    FriendsData.getInstance():addChatDataByUid(tonumber(self.data.mid), self.m_chat_msg);
end

FriendChatDialog.onReceiveFriendMsg = function(self, data)
    if not data then
        return;
    end;
    --只有上方好友发的消息才接收
    if data.send_uid == tonumber(self.data.mid) then
        self.m_isReceiveMsg = true;
        if ToolKit.isSecondDay(self.m_msg_time) then
            data.isShowTime = true;
        else
            if ToolKit.isInTenMinute(self.m_msg_time, data.time) then
                data.isShowTime = false;
            else
                data.isShowTime = true;
            
            end;
        end;
        self.m_msg_time = data.time;
        local child = self:getChatItem(data);
        self.m_chat_list:addChild(child);
        self.m_chat_list_items[#self.m_chat_list_items+1] = child
        self.m_chat_list:gotoBottom();
    end;
end

function FriendChatDialog:onUpdateUserData(tab)--数据
    if self.m_chat_list_items then
        for index =1,#self.m_chat_list_items do
            local uid = self.m_chat_list_items[index]:getUid();
            for _,sdata in pairs(tab) do
                if uid and uid == tonumber(sdata.mid) then
                    self.m_chat_list_items[index]:updateUserData(sdata);
                    break
                end
            end
        end
    end
end

FriendChatDialog.onNativeCallDone = function(self ,param , ...)
	if self.s_nativeEventFuncMap[param] then
		self.s_nativeEventFuncMap[param](self,...);
	end
end

FriendChatDialog.s_nativeEventFuncMap = {
    [kFriend_UpdateChatMsg]     = FriendChatDialog.onReceiveFriendMsg;
    [kFriend_UpdateUserData]    = FriendChatDialog.onUpdateUserData;
}

----------------private ndoe------------------
FriendChatDialogItem = class(Node)

FriendChatDialogItem.ctor = function(self, data)
    --{msg_id=-1 recv_uid=1138 send_uid=1140 msg="啊啊啊" isShowTime=true time=1447930284 }
	if data.send_uid == UserInfo.getInstance():getUid() then
        self.m_name = UserInfo.getInstance():getName();
	    self.m_str = data.msg;
        self.m_uid = data.send_uid;
    else
        self.m_friend_info = FriendsData.getInstance():getUserData(data.send_uid);
        self.m_name = data.mnick;
	    self.m_str = data.msg;
        self.m_uid = data.send_uid;
    end
    --时间
    self.m_time_bg = new(Image,"common/background/chat_time_bg.png");
    self.m_time_bg:setAlign(kAlignTop);
    self.m_time = new(Text, self:getTime(data.time), 0, 0, nil,nil,20,120, 120, 120);
    self.m_time_str = data.time;
    local timeW,timeH = self.m_time:getSize();
    self.m_time_bg:setSize(timeW + 30);
    self.m_time:setAlign(kAlignCenter);
    self.m_time_bg:addChild(self.m_time);
	self:addChild(self.m_time_bg);
    if not data.isShowTime then
        self.m_time_bg:setVisible(false);
    else
        self.m_time_bg:setVisible(true);
    end;

    self.m_user_icon = new(Mask,"common/background/head_mask_bg_86.png","common/background/head_mask_bg_86.png")
    self.m_user_icon:setFile(UserInfo.DEFAULT_ICON[1]);
    self.m_user_icon:setAlign(kAlignCenter);
    
    self.m_user_icon_click_area = new(Button,"drawable/blank.png");
    self.m_user_icon_click_area:setSize(86,86);
    self.m_user_icon_click_area:setAlign(kAlignCenter);
    self.m_user_icon_click_area:setOnClick(self, self.onItemClick);

    self.m_icon_frame = new(Image,"common/background/head_bg_92.png");
    self.m_icon_frame:addChild(self.m_user_icon_click_area);
    self.m_icon_frame:addChild(self.m_user_icon);
    self.m_icon_frame:setPos(0);
    self:addChild(self.m_icon_frame);
    self.m_vip_frame = new(Image,"vip/vip_110.png");
    self.m_vip_frame:setAlign(kAlignCenter);
    self.m_vip_logo = new(Image,"vip/vip_logo.png");

    self.m_name_text = new(Text,self.m_name,nil,nil,nil,nil,24,100,100,100);
    local nw,nh = self.m_name_text:getSize();
    self:addChild(self.m_name_text);

    local itemX, itemY = 10, 30;
    if self.m_uid == UserInfo.getInstance():getUid() then
        self.m_message_bg = new(Image,"common/background/message_bg_7.png",nil, nil,46,46,50,16);
        self.m_message_bg:setPos(itemX + 100, itemY + 50);
        self.m_message_bg:setAlign(kAlignTopRight);
        self.m_icon_frame:setPos(itemX, itemY);
        self.m_icon_frame:setAlign(kAlignTopRight);
        self.m_name_text:setPos(itemX + 120, itemY + 10);
        self.m_name_text:setAlign(kAlignTopRight);
        self.m_vip_logo:setAlign(kAlignTopRight);
        self.m_vip_logo:setPos(itemX + 125 + nw,itemY + 5);
        if UserInfo.getInstance():getIsVip() == 1 then
            self.m_vip_logo:setVisible(true);
            self.m_name_text:setText(self.m_name,nil,nil,200,40,40)
--            self.m_vip_frame:setVisible(true);
        else
            self.m_vip_logo:setVisible(false);
            self.m_name_text:setText(self.m_name,nil,nil,100,100,100)
--            self.m_vip_frame:setVisible(false);
        end
        local frameRes = UserSetInfo.getInstance():getFrameRes();
        self.m_vip_frame:setVisible(frameRes.visible);
        local fw,fh = self.m_vip_frame:getSize();
        if frameRes.frame_res then
            self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
        end
        if UserInfo.getInstance():getIconType() == -1 then
            self.m_user_icon:setUrlImage(UserInfo.getInstance():getIcon());
        else
            local file = UserInfo.DEFAULT_ICON[UserInfo.getInstance():getIconType()] or UserInfo.DEFAULT_ICON[1];
            self.m_user_icon:setFile(file);
        end
    else
        self.m_message_bg = new(Image,"common/background/message_bg_5.png",nil, nil, 46,46,50,16);
        self.m_message_bg:setPos(itemX + 100, itemY + 50);
        self.m_message_bg:setAlign(kAlignTopLeft);
        self.m_icon_frame:setPos(itemX, itemY);
        self.m_icon_frame:setAlign(kAlignTopLeft);
        self.m_name_text:setPos(itemX + 120, itemY + 10);
        self.m_name_text:setAlign(kAlignTopLeft);
        self.m_vip_logo:setAlign(kAlignTopLeft);
        self.m_vip_logo:setPos(itemX + 120,itemY + 5);
        local vw,vh = self.m_vip_logo:getSize();
        if self.m_friend_info then
            if self.m_friend_info.is_vip == 1 then
                self.m_name_text:setPos(itemX + 125 + vw,itemY + 10);
                self.m_name_text:setText(self.m_name,nil,nil,200,40,40)
                self.m_vip_logo:setVisible(true);
                self.m_vip_frame:setVisible(true);
            else
                self.m_name_text:setPos(itemX + 120, itemY + 10);
                self.m_name_text:setText(self.m_name,nil,nil,100,100,100)
                self.m_vip_logo:setVisible(false);
                self.m_vip_frame:setVisible(false);
            end;
            if self.m_friend_info.iconType == -1 then
                self.m_user_icon:setUrlImage(self.m_friend_info.icon_url);
            else
                local file = UserInfo.DEFAULT_ICON[self.m_friend_info.iconType] or UserInfo.DEFAULT_ICON[1];
                self.m_user_icon:setFile(file);
            end
            self:setUserName(self.m_friend_info)
        else
            self.m_name_text:setPos(itemX + 120, itemY + 10);
            self.m_vip_logo:setVisible(false);
            self.m_vip_frame:setVisible(false);        
            local file = UserInfo.DEFAULT_ICON[1];
            self.m_user_icon:setFile(file);
        end
    end
    self.m_icon_frame:addChild(self.m_vip_frame);
    self:addChild(self.m_vip_logo);
    self:addChild(self.m_message_bg);

    local msgStr, msgW, msgH = self:returnStrAndWH(self.m_str);
	self.m_text = new(TextView,msgStr,msgW,0,nil,nil,28,80,80,80);
    local w,h = self.m_text:getSize();
    self.m_message_bg:setSize(w+50,h+40);

    self.m_text:setAlign(kAlignCenter);
    if self.m_uid == UserInfo.getInstance():getUid() then
        self.m_text:setPos(-5);
    else
        self.m_text:setPos(5);
    end
    self.m_message_bg:addChild(self.m_text);
    local w,h = self.m_message_bg:getSize();
    w = math.max(w,64);
    h = math.max(h,64);
    self.m_message_bg:setSize(w,h);

    local itemW = 610;
    local itemH = select(2,self.m_message_bg:getSize()) + select(2,self.m_icon_frame:getSize()) + select(2,self.m_time_bg:getSize());
	self:setSize(itemW,itemH);
end

FriendChatDialogItem.dtor = function(self)
    if self.m_userinfo_dialog then
        delete(self.m_userinfo_dialog);
        self.m_userinfo_dialog = nil;
    end;
end


FriendChatDialogItem.getUid = function(self)
    return self.m_uid or nil;
end

FriendChatDialogItem.getMsgTime = function(self)
    return self.m_time_str or "0";
end

FriendChatDialogItem.updateUserData = function(self, data)
    self:loadIcon(data);
    self:setVip(data);
    self:setUserName(data)
end

FriendChatDialogItem.setUserName = function(self,data)
    if data and data.mnick then
        self.m_name_text:setText(data.mnick or "博雅象棋");
    end
end

FriendChatDialogItem.returnStrAndWH = function(self, msg)
    local strW, strH = 64,64; -- 默认气泡宽高
    local lens = string.lenutf8(GameString.convert2UTF8(msg) or "");    
    local strMsg = msg;
    if lens > 140 then--限制140字
        lens = 140;
        strMsg = GameString.convert2UTF8(string.subutf8(msg,1,140));
    end;
    local tempMsg = new(Text,msg,0, 0, kAlignLeft,nil,28,80, 80, 80);
    local tempMsgW, tempMsgH = tempMsg:getSize();
    if tempMsgW ~= 0 and tempMsgH ~= 0 then
        if tempMsgW >= 448 then -- 448,32字符宽，14个字
            tempMsgW = 448;
        elseif tempMsgW <= 64 then
            tempMsgW = 64;
        end;
        return strMsg,tempMsgW, tempMsgH;
    end;
    delete(tempMsg)
    return strMsg, strW, strH;
end;

FriendChatDialogItem.loadIcon = function(self,data)
    local icon = data.icon_url;
    if not self.m_user_icon then
        if not icon then 
            if data.iconType > 0 then
                icon = UserInfo.DEFAULT_ICON[data.iconType] or UserInfo.DEFAULT_ICON[1];
            else
                icon = UserInfo.DEFAULT_ICON[1]
            end;
            self.m_user_icon = new(Mask,icon ,"common/background/head_mask_bg_46.png");
        else
            self.m_user_icon = new(Mask,"drawable/blank.png" ,"common/background/head_mask_bg_46.png");
            self.m_user_icon:setUrlImage(icon,UserInfo.DEFAULT_ICON[1]);            
        end;
        self.m_user_icon:setSize(46,46);
        self.m_user_icon:setAlign(kAlignCenter);
        self.m_icon_frame:addChild(self.m_user_icon)
    else
        if not icon then 
            if data.iconType > 0 then
                icon = UserInfo.DEFAULT_ICON[data.iconType] or UserInfo.DEFAULT_ICON[1];
            else
                icon = UserInfo.DEFAULT_ICON[1]
            end;
            self.m_user_icon:setFile(icon);
        else
            self.m_user_icon:setUrlImage(icon,UserInfo.DEFAULT_ICON[1]);            
        end;   
    end   
end;

FriendChatDialogItem.setVip = function(self, data)
    if data and data.is_vip == 1 then
        local itemX, itemY = 10, 30;
        local vw,vh = self.m_vip_logo:getSize();
        self.m_name_text:setPos(itemX + 125 + vw,itemY + 10);
        self.m_name_text:setText(self.m_name,nil,nil,200,40,40)
        self.m_vip_logo:setVisible(true);
        self.m_vip_frame:setVisible(true);
    else
        self.m_name_text:setText(self.m_name,nil,nil,100,100,100)
    end;    
end;

FriendChatDialogItem.getTime = function(self, time)
    if ToolKit.isSecondDay(time) then
        return os.date("%m-%d %H:%M",time);
    else
        return os.date("%H:%M",time);--%Y/%m/%d %X
    end;
end

FriendChatDialogItem.onItemClick = function(self)
    Log.i("FriendChatDialogItem.onItemClick--icon click!");
    if self.m_uid == UserInfo.getInstance():getUid() then
        Log.i("FriendChatDialogItem.onItemClick--icon click yourself!");
    else
        if not self.m_userinfo_dialog then
            -- TODO UserInfoDialog2 从场景中分离出来的dlg,后续会同步到联网对战
            self.m_userinfo_dialog = new(UserInfoDialog2);
        end;
        if self.m_userinfo_dialog:isShowing() then return end
        local retType = UserInfoDialog2.SHOW_TYPE.CHAT_ROOM
        local id = tonumber(self.m_uid) or 0
        if UserInfo.getInstance():getUid() == id then
            retType = UserInfoDialog2.SHOW_TYPE.ONLINE_ME
        end
        self.m_userinfo_dialog:setShowType(retType)
        local user = FriendsData.getInstance():getUserData(id)
        self.m_userinfo_dialog:show(user,id)

--        self.m_extra_msg = FriendsData.getInstance():getUserData(self.m_uid)
--        if self.m_extra_msg and  next(self.m_extra_msg) then
--            self.m_userinfo_dialog:show(self.m_extra_msg)
--        end
    end
end



FriendChatRoomSchemesItem = class(Node)

function FriendChatRoomSchemesItem.ctor(self,handler,data,event,params)
    self.mRoot = SceneLoader.load(hall_chat_room_schemes_item);
    self.mHandler = handler;
    local w,h = self.mRoot:getSize();
    self:setSize(w,h);
    self:addChild(self.mRoot);
    self.mOwnView = self.mRoot:getChildByName("own_view");
    self.mOtherView = self.mRoot:getChildByName("other_view");
    self.mClickBtn = self.mRoot:getChildByName("click_btn");
    self.mClickBtn:setOnClick(self,function()
            self.mHandler:dismiss();
            event();
        end
    );
    self.mClickBtn:setSrollOnClick();
    self.mData = data;
    if data.send_uid == UserInfo.getInstance():getUid() then
        self.mName = UserInfo.getInstance():getName();
	    self.mStr = data.msg;
        self.mUid = data.send_uid;
        self.mTimeStr = data.time;
        self.mOwnView:setVisible(true);
        self.mOtherView:setVisible(false);
        self.mView = self.mOwnView;
        self.mUserData = {};
        self.mUserData.iconType = UserInfo.getInstance():getIconType();
        self.mUserData.icon_url = UserInfo.getInstance():getIcon();
        self.mUserData.is_vip   = UserInfo.getInstance():getVip();
    else
        self.mUserData = FriendsData.getInstance():getUserData(data.send_uid);
        self.mName = data.mnick;
	    self.mStr = data.msg;
        self.mUid = data.send_uid;
        self.mTimeStr = data.time;
        self.mOwnView:setVisible(false);
        self.mOtherView:setVisible(true);
        self.mView = self.mOtherView;
    end

    self.mNameView = self.mView:getChildByName("name");
    self.mNameView:setText(self.mName,nil,nil,100,100,100);

    self.mIconFrame = self.mView:getChildByName("icon"):getChildByName("mask");
    self.mVipFrame  = self.mView:getChildByName("icon"):getChildByName("vip");
    
    self.mIconView = self.mView:getChildByName("bg"):getChildByName("icon_view");
    self.mBoardBg = new(Image,params.icon_img)
    self.mBoardBg:setAlign(kAlignCenter)
    self.mIconView:addChild(self.mBoardBg)

    self.mTitle = self.mView:getChildByName("bg"):getChildByName("title");
    self.mTitle:setText(params.title or "");
    self.mContent  = self.mView:getChildByName("bg"):getChildByName("content");
    local width,height = self.mContent:getSize();
    local richText = new(RichText,params.content or "", width, height, kAlignTopLeft, fontName, 24, 100, 100, 100, true,10);
    self.mContent:addChild(richText);
    self:updateUserData(self.mUserData);

    if self:checkOverdue() then
        self:setPickable(false);
        self.mTitle:setText("邀请已过期！");
    end

    local msgData = params.msgData
    if msgData.method == "gotoCustomEndgateRoom"  then
        local w,h = self.mIconView:getSize()
        self.mBoardBg:setSize(w,h)
        if not self:checkOverdue() and type(msgData) == "table" then
            local sendData = {}
            sendData.booth_id = msgData.booth_id;
            delete(self.mHttp)
            self.mHttp = HttpModule.getInstance():execute2(HttpModule.s_cmds.WulinBoothGetBoothInfo,sendData,function(isSuccess,resultStr,httpRequest)
                if isSuccess then
                    local jsonData = json.decode(resultStr)
                    local data = jsonData.data
                    if type(data) ~= "table" then return end
                    if type(data.booth_title) == "string" then 
                        self.mTitle:setText((data.booth_title or "") .. (params.title or ""))
                    end
                    if type(data.booth_fen) == "string" then
                        local w,h = self.mBoardBg:getSize()
                        self.mBoardBg:removeAllChildren()
                        local board = new(Board,w,h,self)
                        Board.resetFenPiece();
                        local chess_map = board:fen2chessMap(data.booth_fen);
                        board:copyChess90(chess_map);
                        board:setPickable(false);
                        self.mBoardBg:addChild(board)
                    end
                end
            end);
        end
    elseif msgData.method == "showSociatyInfoDialog"  then
    else
        local w,h = self.mIconView:getSize()
        self.mBoardBg:setSize(w,h)
    end
end

function FriendChatRoomSchemesItem.dtor(self)
    delete(self.mHttp)
end

function FriendChatRoomSchemesItem.checkOverdue(self)
    -- 过期隐藏
    if self.mData and tonumber(self.mData.time) then
        local time = tonumber(self.mData.time);
        if os.time() - time > 3*60 then
--            self:setTransparency(0.8);
            return true
        end
    end
end

function FriendChatRoomSchemesItem.updateUserData(self, data)
    self:loadIcon(data);
    self:setVip(data);
    self:setUserName(data);
end

function FriendChatRoomSchemesItem.loadIcon(self,data)
    if type(data) ~= "table" then return end
    local icon = data.icon_url;
    if not self.mUserIcon then
        if not icon then 
            if data.iconType > 0 then
                icon = UserInfo.DEFAULT_ICON[data.iconType] or UserInfo.DEFAULT_ICON[1];
            else
                icon = UserInfo.DEFAULT_ICON[1]
            end
            self.mUserIcon = new(Mask,icon ,"common/background/head_mask_bg_86.png");
        else
            self.mUserIcon = new(Mask,"drawable/blank.png" ,"common/background/head_mask_bg_86.png");
            self.mUserIcon:setUrlImage(icon,UserInfo.DEFAULT_ICON[1]);            
        end;
        self.mUserIcon:setSize(80,80);
        self.mUserIcon:setAlign(kAlignCenter);
        self.mIconFrame:addChild(self.mUserIcon)
    else
        if not icon then 
            if data.iconType > 0 then
                icon = UserInfo.DEFAULT_ICON[data.iconType] or UserInfo.DEFAULT_ICON[1];
            else
                icon = UserInfo.DEFAULT_ICON[1]
            end;
            self.mUserIcon:setFile(icon);
        else
            self.mUserIcon:setUrlImage(icon,UserInfo.DEFAULT_ICON[1]);            
        end
    end
end

function FriendChatRoomSchemesItem.setVip(self, data)
    if data and data.is_vip == 1 then
        self.mNameView:setText(self.mName,nil,nil,200,40,40)
        self.mVipFrame:setVisible(true);
    else
        self.mNameView:setText(self.mName,nil,nil,100,100,100);
        self.mVipFrame:setVisible(false);
    end  
end

function FriendChatRoomSchemesItem.setUserName(self,data)
    if data and data.mnick then
        self.mNameView:setText(data.mnick or "博雅象棋");
    end;
end;

function FriendChatRoomSchemesItem.getUid(self)
    return self.mUid or nil;
end

function FriendChatRoomSchemesItem.getMsgTime(self)
    return self.mTimeStr or "0";
end