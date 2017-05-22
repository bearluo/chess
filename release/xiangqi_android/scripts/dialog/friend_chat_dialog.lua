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

        local child = new(FriendChatDialogItem, self.m_chat_data[i],self.m_is_vip);--,w,h);
        self.m_chat_list:addChild(child); 
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
    if self.m_chat_msg == " " or  self.m_chat_msg == "" then
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
        local child = new(FriendChatDialogItem, data,self.m_is_vip);
        self.m_chat_list:addChild(child);
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
        local child = new(FriendChatDialogItem, data,self.m_is_vip);
        self.m_chat_list:addChild(child);
        self.m_chat_list:gotoBottom();
    end;
end

FriendChatDialog.onNativeCallDone = function(self ,param , ...)
	if self.s_nativeEventFuncMap[param] then
		self.s_nativeEventFuncMap[param](self,...);
	end
end

FriendChatDialog.s_nativeEventFuncMap = {
    [kFriend_UpdateChatMsg] = FriendChatDialog.onReceiveFriendMsg;
}

----------------private ndoe------------------

FriendChatDialogItem = class(Node);

FriendChatDialogItem.default_icon = "userinfo/women_head02.png";
FriendChatDialogItem.DEFAULT_w = 658;
FriendChatDialogItem.DEFAULT_h = 100;

FriendChatDialogItem.s_h = 40;
--add = 20;

FriendChatDialogItem.ctor = function(self,data,vip_data) --viewW, viewH, itemType, otherUserInfo)
    if not data then
        return;
    end;
    
	self.data = data;
    self.m_is_vip = vip_data;
    self.item_h = 0;

    self.isMe = false;

    if self.data.mid == UserInfo.getInstance():getUid() or self.data.send_uid == UserInfo.getInstance():getUid() then
        self.isMe = not self.isMe;
        self.name = UserInfo.getInstance():getName();
        self.m_name = new(Text,self.name or "中国象棋" ,nil,nil,nil,nil,30,65,120,190);
    else
        self.userData = FriendsData.getInstance():getUserData(data.send_uid);
        self.m_name = new(Text,self.userData.mnick or "中国象棋" ,nil,nil,nil,nil,30,65,120,190);
    end
    self.m_vip_logo = new(Image,"vip/vip_logo.png");
    --名字
    self:addChild(self.m_name);
    self:addChild(self.m_vip_logo);
    --头像
    self.m_icon_bg = new(Image,"common/background/head_bg_92.png");
    self.m_vip_frame = new(Image,"vip/vip_90.png");
    self.m_vip_frame:setAlign(kAlignCenter);
    self.m_icon_mask = new(Image,"common/background/head_mask_bg_86.png");
    self.m_icon_mask:setAlign(kAlignCenter);
    self:addChild(self.m_icon_bg);
    self.m_icon_bg:addChild(self.m_icon_mask);
    self.m_icon_bg:addChild(self.m_vip_frame);
    self.head = new(Mask,"common/background/head_mask_bg_86.png","common/background/head_mask_bg_86.png");
    self.head:setAlign(kAlignCenter);
    self.head:setFile(UserInfo.DEFAULT_ICON[1]);
    self.m_icon_mask:addChild(self.head);
    --聊天内容
    self.m_last_msg = data.msg;

    local text_w,text_h = self:returnStringWH(self.m_last_msg);
    local temp = text_h + 10; 
    self.m_msg = new(TextView,self.m_last_msg,text_w,nil,kAlignLeft,nil,32,80,80,80); --,GameString.convert2UTF8(self.m_last_msg)
    self.m_msg:setAlign(kAlignCenter);
    
    local w,h = self.m_msg:getSize();
    h = h + temp;
    w = w + temp;


    if self.isMe then
        --聊天气泡
        self.m_msg_bg = new(Image,"common/background/message_bg_2.png",nil,nil,24,24,24,24);
        self.m_msg_bg:setSize(w,h);
        self.m_msg_bg:setAlign(kAlignTopRight);
        self.m_msg_bg:addChild(self.m_msg);
        self.m_msg:setPos(-6,0);
        self:addChild(self.m_msg_bg);
        self.m_name:setAlign(kAlignTopRight);
        self.m_icon_bg:setAlign(kAlignTopRight);

    else
        self.m_msg_bg = new(Image,"common/background/message_bg_1.png",nil,nil,24,24,24,24);
        self.m_msg_bg:setSize(w,h);
        self.m_msg_bg:setAlign(kAlignTopLeft);
        self.m_msg_bg:addChild(self.m_msg);
        self.m_msg:setPos(6,0);
        self:addChild(self.m_msg_bg);
        self.m_name:setAlign(kAlignTopLeft);
        self.m_icon_bg:setAlign(kAlignTopLeft);
    end

    --是否显示时间
    if self.data.isShowTime then
        self.m_time_bg = new(Image,"common/background/chat_time_bg.png");
        self.m_time_bg:setSize(150,32);
        self.m_time_bg:setAlign(kAlignTop);
        self.time_text = new(Text,self:getTime(self.data.time),nil,nil,kAlignCenter,nil,24,120,120,120);
        self.time_text:setAlign(kAlignCenter);
        self.m_time_bg:addChild(self.time_text);

        self:addChild(self.m_time_bg);
        local _,time_h = self.m_time_bg:getSize();
        self.m_time_bg:setPos(0,time_h/2);
        self.item_h = time_h + self.item_h;
        self.m_icon_bg:setPos(0,3*time_h/2);
    else
        self.m_icon_bg:setPos(0,0); 
    end

    local _,icon_y = self.m_icon_bg:getPos();
    local _,icon_h = self.m_icon_bg:getSize();
    local name_w,name_h = self.m_name:getSize();
    local vw,vh = self.m_vip_logo:getSize();


    local is_vip = UserInfo.getInstance():getIsVip();
    if self.isMe then
        self.m_name:setPos(icon_h + 10 * System.getLayoutScale() ,icon_h/2 - name_h/2 + icon_y);
        self.m_vip_logo:setAlign(kAlignTopRight);
        if is_vip and is_vip == 1 then
            self.m_vip_logo:setPos(icon_h + 10 * System.getLayoutScale() + name_w,icon_h/2 - name_h/2 + icon_y - 5);
--            self.m_vip_frame:setVisible(true);
            self.m_vip_logo:setVisible(true);
        else
--            self.m_vip_frame:setVisible(false);
            self.m_vip_logo:setVisible(false);
        end
        local frameRes = UserSetInfo.getInstance():getFrameRes();
        self.m_vip_frame:setVisible(frameRes.visible);
        local fw,fh = self.m_vip_frame:getSize();
        if frameRes.frame_res then
            self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
        end
    else
        self.m_vip_logo:setPos(icon_h + 10 * System.getLayoutScale() ,icon_h/2 - name_h/2 + icon_y - 5);
        self.m_vip_logo:setAlign(kAlignTopLeft);
        if self.m_is_vip and self.m_is_vip == 1 then
            self.m_name:setPos(icon_h + 10 * System.getLayoutScale() + vw ,icon_h/2 - name_h/2 + icon_y);
            self.m_vip_frame:setVisible(true);
            self.m_vip_logo:setVisible(true);
        else
            self.m_name:setPos(icon_h + 10 * System.getLayoutScale() ,icon_h/2 - name_h/2 + icon_y);
            self.m_vip_frame:setVisible(false);
            self.m_vip_logo:setVisible(false);
        end
    end
   

   
    self.m_msg_bg:setPos(icon_h/2 + 20,icon_y + icon_h);

    self.item_h = self.item_h + icon_h + h + 25;

    self:setSize(FriendChatDialogItem.DEFAULT_w,self.item_h);

    if self.isMe then
        local icontype = UserInfo.getInstance():getIconType();
        if icontype ==  -1 then
            self.head:setUrlImage(UserInfo.getInstance():getIcon(),UserInfo.DEFAULT_ICON[1]);
        else
            local file = UserInfo.DEFAULT_ICON[icontype] or UserInfo.DEFAULT_ICON[1];
            self.head:setFile(file);
        end
    end
  
    if self.userData then
        if self.userData.iconType == -1 then
            self.head:setUrlImage(self.userData.icon_url,UserInfo.DEFAULT_ICON[1]);
        else
            local file = UserInfo.DEFAULT_ICON[self.userData.iconType] or UserInfo.DEFAULT_ICON[1];
            self.head:setFile(file);
        end
    else
--            if not ChatLogItem.s_update_head_icon[self.m_uid] then 
--                ChatLogItem.s_update_head_icon[self.m_uid] = {};
--            end
--            table.insert(ChatLogItem.s_update_head_icon[self.m_uid],self);
    end
end

--FriendChatDialogItem.s_updateHeadIcon = function(uid,data)
--    if FriendChatDialogItem.s_update_head_icon[uid] then
--        for key,value in pairs(FriendChatDialogItem.s_update_head_icon[uid]) do
--            value.data = data;
--            if value and value.updateHeadIcon then
--                value.updateHeadIcon(value);
--            end
--        end
--        FriendChatDialogItem.s_update_head_icon[uid] = nil;
--    end
--end

FriendChatDialogItem.updateHeadIcon = function(self)
    if self.userData then
        if self.userData.iconType == -1 then
            self.head:setUrlImage(self.userData.icon_url);
        else
            local file = UserInfo.DEFAULT_ICON[self.userData.iconType] or UserInfo.DEFAULT_ICON[1];
            self.head:setFile(file);
        end
    end
end

--获得字符串长度
FriendChatDialogItem.returnStringWH = function(self, msg)
    local strW, strH = 64,64;

    --截取字符串
    local lens = string.lenutf8(GameString.convert2UTF8(msg) or "");    
    if lens > 140 then--限制140字
        lens = 140;
        self.m_last_msg = GameString.convert2UTF8(string.subutf8(msg,1,140));
    end;

    local tempMsg = new(Text,msg,0, 0, kAlignLeft,nil,32,255, 255, 255);
    local tempMsgW, tempMsgH = tempMsg:getSize();
    delete(tempMsg);
    if tempMsgW ~= 0 and tempMsgH ~= 0 then
        if tempMsgW >= 482 then
            tempMsgW = 482;
        elseif tempMsgW <= 64 then
            tempMsgW = 64;
        end;
        return tempMsgW, tempMsgH;
    end;
    return strW, strH;
end;

---------------
FriendChatDialogItem.getTime = function(self,time)
    if ToolKit.isSecondDay(time) then
        return os.date("%m-%d %H:%M",time);
    else
        return os.date("%H:%M",time);--%Y/%m/%d %X
    end;
end;

FriendChatDialogItem.getData = function(self)
	return self.data;
end

FriendChatDialogItem.setCheckVisible = function(self,isVisible)
	self.m_checkBox:setVisible(isVisible);
	if isVisible == true then
		self.container:setPos(40,0);
	else
		self.container:setPos(0,0);
	end
end

FriendChatDialogItem.setBgVisible = function(self,isVisible)
	self.m_focus_bg:setVisible(isVisible);
end

FriendChatDialogItem.setCheckState = function(self)
	if self.m_checkBox:isChecked() == true then
		self.m_checkBox:setChecked(false);
	else
		self.m_checkBox:setChecked(true);
	end
end

FriendChatDialogItem.getCheckState = function(self)
	return self.m_checkBox:isChecked();
end

FriendChatDialogItem.dtor = function(self)
	
end