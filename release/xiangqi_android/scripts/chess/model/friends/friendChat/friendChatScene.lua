--region FriendChatScene.lua.lua
--Author : LeoLi
--Date   : 2015/7/16

require(BASE_PATH.."chessScene");
require("dialog/friends_pop_dialog");
require("animation/loading");

FriendChatScene = class(ChessScene);

FriendChatScene.s_controls = 
{
    back_btn       = 1;
    check_friend   = 2;
    content_view   = 3;
    load_view      = 4;
    chat_msg       = 5;
    send_msg       = 6;
    friend_name    = 7;
}

FriendChatScene.s_cmds = 
{
    recv_friend_msg     = 1;
    recv_chat_msg_state = 2;
    change_friend_icon  = 3;
    resend_chat_msg     = 4;
}

FriendChatScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = FriendChatScene.s_controls;
    self.m_friend_data = controller.m_state.m_friend_data;
    self:init();
end 

FriendChatScene.resume = function(self)
    ChessScene.resume(self);
    --self:testHugeMsgs();-- 测试巨量消息
end;


FriendChatScene.pause = function(self)
	ChessScene.pause(self);
end 


FriendChatScene.dtor = function(self)
    ChatMessageAnim.deleteAll();
    Loading.deleteAll();
    ShowMessageAnim.deleteAll();
end 

----------------------------------- function ----------------------------


FriendChatScene.testHugeMsgs = function(self)
    local anim = new(AnimInt, kAnimLoop, 0, 1, 500, -1);
    anim:setEvent(self, self.sendMsg)
end;


--初始化部分状态
FriendChatScene.init = function(self)

    self.m_friend_name = self:findViewById(self.s_controls.friend_name);
    
    self.m_content_view = self:findViewById(self.s_controls.content_view);
    local contentW, contentH = self:getSize();
    self.m_content_view:setSize(contentW, contentH - 100 - 63);--100是bottom的高，70是tittle的高
    self.m_load_view = self:findViewById(self.s_controls.load_view); 
	local w,h = self.m_content_view:getSize();
	self.m_msg_list = new(ScrollView,0,0,w,h,true);

    if self.m_friend_data then
        self.m_friend_name:setText(self.m_friend_data.mnick or "");
        self.m_chat_data = FriendsData.getInstance():getChatData(tonumber(self.m_friend_data.mid))
        self:onGetHistroyMsg(self.m_chat_data);
    end

    
    self.m_msg_list:gotoBottom();
	self.m_content_view:addChild(self.m_msg_list);
    self.m_edit_text = self:findViewById(self.s_controls.chat_msg);
    self.m_edit_text:setHintText(GameString.convert2UTF8("点击此处输入聊天信息"),165,145,120);
    self.m_edit_text:setOnTextChange(self, self.onEditTextChange);
    self.m_send_btn = self:findViewById(self.s_controls.send_msg);
    self.m_send_text = self.m_send_btn:getChildByName("send_text");
    self.m_send_btn:setEnable(false);
    self.m_send_text:setColor(120,120,120);
    --清除未读消息
    self:resetUnreadMsgNum();

end

FriendChatScene.onGetHistroyMsg = function(self,data)
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

        local child = new(FriendChatMsgItem, self.m_chat_data[i],w,h);
        self.m_msg_list:addChild(child); 
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
end

FriendChatScene.onEditTextChange = function(self, str)
    if str == "" or str == nil then
        self:setSendBtnStatus(false);
    else
        self:setSendBtnStatus(true);
    end;

end;

FriendChatScene.setSendBtnStatus = function(self, enable)
    
    if enable then
        self.m_send_btn:setEnable(true);
        self.m_send_text:setColor(250,230,180);
        --发送按钮呼吸动画
--        self.m_send_btn:addPropColor(1,kAnimLoop,100000,-1,255,nil,0,83);
        self.m_send_btn:addPropTransparency(1,kAnimLoop,600,-1,1,0.7);
    else
        self.m_send_btn:setEnable(false);
        self.m_send_text:setColor(120,120,120);
        self.m_send_btn:removeProp(1);
    end

end;

FriendChatScene.onRefreshList = function(self)
     ChatMessageAnim.play(self.m_root, 3, "刷回来了");

end;

FriendChatScene.loadAnim = function(self,status,diff,offset,isMarginRebounding)

end;
FriendChatScene.onMsgListItemClick = function(self,adapter,view,index)
    Log.i("FriendChatScene.onMsgListItemClick");
end

----------------------------------- onClick ---------------------------------

FriendChatScene.onBack = function(self)
    self:requestCtrlCmd(FriendChatController.s_cmds.onBack);
end



FriendChatScene.onCheckFriend = function(self)
    StateMachine.getInstance():pushState(States.FriendsInfo, StateMachine.STYPE_CUSTOM_WAIT, nil,tonumber(self.m_friend_data.mid));
end;

FriendChatScene.onSendMsg = function(self)
    if not self.m_isSendingMsg then
        if FriendsData.getInstance():isYourFriend(tonumber(self.m_friend_data.mid))  ~= -1 then
            self:sendMsg(); 
        else
            if self.m_isReceiveMsg or ToolKit.isSecondDay(self.m_msg_time) then
                self:sendMsg(); 
                self.m_isReceiveMsg = false;
            else
--                ShowMessageAnim.fontSize = 24;
--                ShowMessageAnim.play(self.m_root,"对方回复后，才可以继续留言");
                ChessToastManager.getInstance():showSingle("对方回复后，才可以继续留言",1500);
            end;
        end;
    else
--        ShowMessageAnim.play(self.m_root,"正在发送消息...");
        ChessToastManager.getInstance():showSingle("正在发送消息...",1500);
    end;
end;


FriendChatScene.sendMsg = function(self)
    self.m_isSendingMsg = true;
    
    self.m_chat_msg = self.m_edit_text:getText() or "";
    self.m_chat_msg = GameString.convert2UTF8(self.m_chat_msg);
--    local r,g,b = self.m_edit_text:getColor();m_textColorB
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
    local w,h = self.m_content_view:getSize();
    local child = new(FriendChatMsgItem, data,w, h);
    self.m_msg_list:addChild(child);
    local lens = string.lenutf8(GameString.convert2UTF8(self.m_chat_msg) or ""); 
    if lens > 140 then
--        ShowMessageAnim.fontSize = 24;
--        ShowMessageAnim.play(self.m_root,GameString.convert2UTF8("字数超过140，已截取显示"));  
        local message =  "字数超过140，已截取显示"; 
        ChessToastManager.getInstance():showSingle(message);               
    end;
    --LoadingAnim
    self.m_send_msg_bg = child.m_msg_bg;
    local msgW, msgH = self.m_send_msg_bg:getSize();
    Loading.play(self.m_send_msg_bg, msgW-30, 0, kAlignTopRight, true);
    Loading.setResendBtnCallBack(self, self.reSendMsg);

    --发送完毕，edit置空，send按钮不可用
    self.m_edit_text:setText(nil);
    self:setSendBtnStatus(false);
    self.m_msg_list:gotoBottom();
    ------ 发送服务器item --------
    local data = {};
    data.msg = self.m_chat_msg;
    data.target_uid = tonumber(self.m_friend_data.mid);
    self:requestCtrlCmd(FriendChatController.s_cmds.send_msg, data);    

end;

FriendChatScene.reSendMsg = function(self)
    Log.i("FriendChatScene.reSendMsg");
    local msgW, msgH = self.m_send_msg_bg:getSize();
    Loading.play(self.m_send_msg_bg, msgW-30, 0, kAlignTopRight, true);
    self.m_isResendMsg = true;
    ------ 发送服务器item --------
    local data = {};
    data.msg = self.m_chat_msg;
    data.target_uid = tonumber(self.m_friend_data.mid);
    self:requestCtrlCmd(FriendChatController.s_cmds.send_msg, data);
end;




FriendChatScene.onReceiveFriendMsg = function(self, data)
    if not data then
        return;
    end;
    --只有上方好友发的消息才接收
    if data.send_uid == tonumber(self.m_friend_data.mid) then
        self.m_isReceiveMsg = true;
        local w,h = self.m_content_view:getSize();
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
        local child = new(FriendChatMsgItem, data,w, h);
        self.m_msg_list:addChild(child);
        self.m_msg_list:gotoBottom();
        self:resetUnreadMsgNum();
    end;
end;


FriendChatScene.resetUnreadMsgNum = function(self)
    FriendsData.getInstance():updateUnreadChatByUid(tonumber(self.m_friend_data.mid));
end;

FriendChatScene.onReceChatMsgState = function(self, data)
    if data.ret == 0 then
        Log.i("消息发送成功");
        self.m_isSendingMsg = false;
        FriendsData.getInstance():addChatDataByUid(tonumber(self.m_friend_data.mid), self.m_chat_msg);
        Loading.deleteAll();
    end;
end;


FriendChatScene.onChangeFriendIcon = function(self, data)
    if self.m_msg_list and data then
        local child = self.m_msg_list:getChildren();
        for i = 1, #child do
            local chatItem = child[i];
            if chatItem.m_up_uid == tonumber(data.what) then
                chatItem:updateUserIcon(data.ImageName);
            end
        end;
    end;  
end;


FriendChatScene.onResendChatMsg = function(self)
--    if self.m_isSendingMsg then
--        self:reSendMsg();
--    end;
end;

----------------------------------- config ------------------------------
FriendChatScene.s_controlConfig = 
{
	[FriendChatScene.s_controls.back_btn] = {"tittle_view","tittle_bg","back"};
	[FriendChatScene.s_controls.check_friend] = {"tittle_view","tittle_bg","check"};
    [FriendChatScene.s_controls.friend_name] = {"tittle_view","tittle_bg","tittle","friendName"};
    [FriendChatScene.s_controls.content_view] = {"content_view"};
    [FriendChatScene.s_controls.load_view] = {"load_view"};
    [FriendChatScene.s_controls.chat_msg] = {"bottom_view","chat_bg","chat_msg"};
    [FriendChatScene.s_controls.send_msg] = {"bottom_view","chat_bg","send"};


};

FriendChatScene.s_controlFuncMap =
{
    [FriendChatScene.s_controls.back_btn] = FriendChatScene.onBack;
    [FriendChatScene.s_controls.check_friend] = FriendChatScene.onCheckFriend;
    [FriendChatScene.s_controls.send_msg] = FriendChatScene.onSendMsg;


};


FriendChatScene.s_cmdConfig =
{
    [FriendChatScene.s_cmds.recv_friend_msg]        = FriendChatScene.onReceiveFriendMsg;
    [FriendChatScene.s_cmds.recv_chat_msg_state]    = FriendChatScene.onReceChatMsgState;
    [FriendChatScene.s_cmds.change_friend_icon]     = FriendChatScene.onChangeFriendIcon;
    [FriendChatScene.s_cmds.resend_chat_msg]        = FriendChatScene.onResendChatMsg;
}


-------------------------------- private node ----------------
FriendChatScene.default_icon = UserInfo.DEFAULT_ICON[1];
FriendChatMsgItem = class(Node);

FriendChatMsgItem.ctor = function(self,data, viewW, viewH, itemType, otherUserInfo)
    if not data then
        return;
    end;
    
	self.data = data;
	local icon_x,icon_y = 10,30;
    local icon_w,icon_h = 56,56;
	local fontsize = 25;
	local friendName_x,friendName_y = 80,10;
    local friendQipao_x, friendQipao_y = 70, 40;
	local time_x ,time_y = 70,65;
	local msg_x,msg_y = 15,-5;
    local containerW,containerH = 0,0; 
    local timebgW, timebgH = 0,0;
    local friendIconW, friendIconH = 0,0;
    local friendQipaoW, friendQipaoH = 0,0;
	self.container = new(Node);
	

    --时间
    self.m_time_bg = new(Image,"friends/friend_chat_time_bg.png",nil,nil,10,10,10,10);
    self.m_time_bg:setAlign(kAlignTop);
    self.m_time = new(Text, self:getTime(data.time), 0, 0, nil,nil,18,70, 145, 105);
    local timeW,timeH = self.m_time:getSize();
    self.m_time_bg:setSize(timeW + 30,nil);
    self.m_time:setAlign(kAlignCenter);
    self.m_time_bg:addChild(self.m_time);
	self.container:addChild(self.m_time_bg);
    if not self.data.isShowTime then
        self.m_time_bg:setVisible(false);
    else
        self.m_time_bg:setVisible(true);
    end;

    if data.send_uid == UserInfo.getInstance():getUid() or data.uid == UserInfo.getInstance():getUid()then
        --头像
        self.m_friend_icon_frame = new(Image, "friends/friend_chat_icon_frame.png");
	    self.m_file_icon = new(Image,UserInfo.DEFAULT_ICON[1]);
        if UserInfo.getInstance():getIconType() == -1 then
            self.m_file_icon:setUrlImage(UserInfo.getInstance():getIcon());
        else
            self.m_file_icon:setFile(UserInfo.DEFAULT_ICON[UserInfo.getInstance():getIconType()] or UserInfo.DEFAULT_ICON[1]);
        end
        self.m_friend_icon_frame:addChild(self.m_file_icon);
        self.m_file_icon:setSize(icon_w, icon_h);
        self.m_file_icon:setAlign(kAlignCenter);
        self.m_friend_icon_frame:setAlign(kAlignTopRight);
        self.m_friend_icon_frame:setPos(icon_x,icon_y);

        --玩家名字
	    self.m_friend_name = new(Text,UserInfo.getInstance():getName() or "博雅象棋", 0, 0, nil,nil,22,70, 145, 105);
        self.m_friend_name:setAlign(kAlignTopRight);
	    self.m_friend_name:setPos(friendName_x,friendName_y);
	    self.m_friend_icon_frame:addChild(self.m_friend_name);

        --聊天气泡
        self.m_msg_bg = new(Image,"friends/friend_chat_msg_bg2.png",nil,nil, 20,20,20,20);
        self.m_msg_bg:setAlign(kAlignTopRight);
        self.m_msg_bg:setPos(friendQipao_x, friendQipao_y);

        self.m_last_msg = data.msg;
        local w,h = self:returnStringWH(self.m_last_msg);
        self.m_msg = new(TextView, GameString.convert2UTF8(self.m_last_msg), w, 0, kAlignLeft,nil,24,45, 45, 45, true);
        local textW, textH = self.m_msg:getSize();
        self.m_msg_bg:setSize(textW + 23,((textH <= 24) and 52) or (textH + 28));
        self.m_msg_bg:addChild(self.m_msg);
        self.m_msg:setPos(8,10);
	    self.m_friend_icon_frame:addChild(self.m_msg_bg);

    else
       local userInfo = nil;
       if itemType then
            userInfo = otherUserInfo;
            self.m_up_uid  = data.uid;    
       else
           userInfo = FriendsData.getInstance():getUserData(data.send_uid);
           self.m_up_uid = data.send_uid;
       end
        --头像
       self.m_friend_icon_frame = new(Image, "friends/friend_chat_icon_frame.png");
       if not userInfo then
            self.m_file_icon = new(Image,FriendChatScene.default_icon);
       else
            if userInfo.iconType > 0 then
                self.m_file_icon = new(Image,UserInfo.DEFAULT_ICON[userInfo.iconType] or UserInfo.DEFAULT_ICON[1]);
            elseif userInfo.iconType == 0 then
                self.m_file_icon = new(Image,FriendChatScene.default_icon);
            elseif userInfo.iconType == -1 then
                self.m_file_icon = new(Image,UserInfo.DEFAULT_ICON[1]); 
                self.m_file_icon:setUrlImage(userInfo.icon_url);     
            end;
        end;
        self.m_friend_icon_frame:addChild(self.m_file_icon);
        self.m_file_icon:setSize(icon_w, icon_h);
        self.m_file_icon:setAlign(kAlignCenter);
        self.m_friend_icon_frame:setAlign(kAlignTopLeft);
        self.m_friend_icon_frame:setPos(icon_x,icon_y);

        --玩家名字
        if userInfo then
	        self.m_friend_name = new(Text,userInfo.mnick or "中国象棋", 0, 0, nil,nil,22,70, 145, 105);
        else
            self.m_friend_name = new(Text,data.name or "中国象棋", 0, 0, nil,nil,22,70, 145, 105);
        end;
        self.m_friend_name:setAlign(kAlignTopLeft);
	    self.m_friend_name:setPos(friendName_x,friendName_y);
	    self.m_friend_icon_frame:addChild(self.m_friend_name);

        --聊天气泡
        self.m_msg_bg = new(Image,"friends/friend_chat_msg_bg.png",nil,nil, 20,20,20,20);
        self.m_msg_bg:setAlign(kAlignTopLeft);
        self.m_msg_bg:setPos(friendQipao_x, friendQipao_y);

        self.m_last_msg = data.msg;
        local w,h = self:returnStringWH(self.m_last_msg);
        self.m_msg = new(TextView, GameString.convert2UTF8(self.m_last_msg), w, 0, kAlignLeft,nil,24,45, 45, 45,true);
        local textW, textH = self.m_msg:getSize();
        self.m_msg_bg:setSize(textW + 23,((textH <= 24) and 52) or (textH + 28));
        self.m_msg_bg:addChild(self.m_msg);
        self.m_msg:setPos(15,10);
	    self.m_friend_icon_frame:addChild(self.m_msg_bg);

    end;
    self.container:addChild(self.m_friend_icon_frame);
    _, timebgH = self.m_time_bg:getSize();
    _, friendIconH = self.m_friend_icon_frame:getSize();
    _, friendQipaoH = self.m_msg_bg:getSize();
    containerH = timebgH + friendIconH + friendQipaoH;
    print_string("FriendChatMsgItem.ctor--->>"..containerH);
    self.container:setSize(viewW, containerH);
    self:addChild(self.container);
end

FriendChatMsgItem.updateUserIcon = function(self,icon)
    self.m_file_icon:setFile(icon or "userinfo/userHead.png");
end;



FriendChatMsgItem.returnStringWH = function(self, msg)
    local strW, strH = 55,52;
    local lens = string.lenutf8(GameString.convert2UTF8(msg) or "");    

    if lens > 140 then--限制140字
        lens = 140;
        self.m_last_msg = GameString.convert2UTF8(string.subutf8(msg,1,140));
    end;

    local tempMsg = new(Text,msg,0, 0, kAlignLeft,nil,24,45, 45, 45);
    local tempMsgW, tempMsgH = tempMsg:getSize();
    if tempMsgW ~= 0 and tempMsgH ~= 0 then
        if tempMsgW >= 312 then
            tempMsgW = 312;
        elseif tempMsgW <= 55 then
            tempMsgW = 55;
        end;
        return tempMsgW, tempMsgH;
    end;
    return strW, strH;
--    local strW, strH = 55,52;
--    local lens = string.lenutf8(GameString.convert2UTF8(msg) or "");

--    if lens == 0 then
--        return strW, strH;--默认气泡宽高
--    end;
--    if lens > 140 then--限制140字
--        lens = 140;
--        self.m_last_msg = GameString.convert2UTF8(string.subutf8(msg,1,140));
--    end;
--    local w, h = 0,0;
--    local lens_byte = string.len(GameString.convert2UTF8(self.m_last_msg));
--    for i = 1, lens_byte do
--        local codes = string.byte(GameString.convert2UTF8(msg),i);
--        if codes >= 0 and codes <= 127 then--1字节字母，数字，特殊字符
--            w = w + 12;
--        elseif codes >= 128 and codes < 192 then--utf-8字节内，不计宽度
--            --utf-8字节内，不计宽度
--        elseif codes >= 192 and codes < 224 then--2个字节的字符，希伯来文，希腊字母，可参考Unicode编码表
--            w = w + 15;
--        elseif codes >= 224 and codes < 240 then--3个字节的字符，汉字
--            w = w + 24;
--        elseif codes >= 240 and codes < 248 then--4个字节的字符，楔形文字，线性文字
--            w = w + 30;
--        elseif codes >= 248 and codes < 252 then--5个字节的字符
--            w = w + 30;
--        elseif codes >= 252 and codes < 254 then--6个字节的字符
--            w = w + 30;
--        end;
--    end;
--    if w >= strW then
--        strW = w;
--    end;

--    if strW >= 312 then --气泡一行最长312,13个字。

--        strH = 24 * (math.ceil(strW / 312)) + 52 - 24;--字体高24,加上文字和气泡上下的空隙.

--        strW = 312;

--    end;

--    return strW, strH;

end;

FriendChatMsgItem.getTime = function(self,time)
    if ToolKit.isSecondDay(time) then
        return os.date("%m-%d %H:%M",time);
    else
        return os.date("%H:%M",time);--%Y/%m/%d %X
    end;
end;




FriendChatMsgItem.getSize = function(self)
    local w, h = self.container:getSize();
    return w,h;
end

FriendChatMsgItem.getData = function(self)
	return self.data;
end

FriendChatMsgItem.setCheckVisible = function(self,isVisible)
	self.m_checkBox:setVisible(isVisible);
	if isVisible == true then
		self.container:setPos(40,0);
	else
		self.container:setPos(0,0);
	end
end

FriendChatMsgItem.setBgVisible = function(self,isVisible)
	self.m_focus_bg:setVisible(isVisible);
end

FriendChatMsgItem.setCheckState = function(self)
	if self.m_checkBox:isChecked() == true then
		self.m_checkBox:setChecked(false);
	else
		self.m_checkBox:setChecked(true);
	end
end

FriendChatMsgItem.getCheckState = function(self)
	return self.m_checkBox:isChecked();
end

FriendChatMsgItem.dtor = function(self)
	
end
