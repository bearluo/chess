
require("audio/sound_manager");
require("ui/node");
require("ui/adapter");
require("ui/listView");
require("dialog/user_info_dialog2")
--require("view/Android_800_480/chat_dialog_view");
require(VIEW_PATH .. "chat_dialog_view");
require(BASE_PATH.."chessDialogScene")
ChatDialog = class(ChessDialogScene,false);
--ChatDialog.edit_len = 10;

--ChatDialog.log_width = 500;

--ChatDialog.s_status = {
--    ROOM = 1;
----    FRIEND = 2;
----    CHATROOM = 3;
--}

ChatDialog.ctor = function(self,room)

    super(self,chat_dialog_view);

    self.m_room = room;

	self.m_root_view = self.m_root;
    
    self.m_close_btn = self.m_root_view:getChildByName("close_btn");
    self.m_close_btn:setTransparency(0.8);
    self.m_close_btn:setOnClick(self,self.dismiss);
    self.m_close_btn:setVisible(false);
    self:setShieldClick(self,self.dismiss);

    self.m_chat_bg = self.m_root_view:getChildByName("chat_bg");

    self.m_input_edit_bg = self.m_chat_bg:getChildByName("input_view"):getChildByName("edit_bg");
    self.m_input_edit = self.m_input_edit_bg:getChildByName("input_edit");
    self.m_input_edit:setHintText("点击输入聊天内容",165,145,125);
    self.m_input_edit:setOnTextChange(self,self.sendRoomChat);
    -- 常用语
    self.m_chat_book_view = self.m_chat_bg:getChildByName("input_view"):getChildByName("chat_book_view"); 
    self.m_chat_book_view.m_autoPositionChildren = true; -- 设置添加孩子的方式
    --上部聊天内容     -- 房间聊天
    self.m_chat_view_handler = self.m_chat_bg:getChildByName("chat_view_handler");
    self.m_room_chat_view = self.m_chat_view_handler:getChildByName("room_chat_view");
    self.m_room_chat_view.m_autoPositionChildren = true; -- 设置添加孩子的方式
    self.m_chat_view_handler:setVisible(true);

    self.m_is_show_chat_book = false;  --判断常用语是否弹出
    
    self.m_chat_book_btn = self.m_chat_bg:getChildByName("chat_book_btn")
    self.m_chat_book_btn:setOnClick(self,function()
        self:selectBtn(1)
    end)
    self.m_chat_history_btn = self.m_chat_bg:getChildByName("chat_history_btn")
    self.m_chat_history_btn:setOnClick(self,function()
        self:selectBtn(2)
    end)

    --房间内常用语
	self.m_phrases = {
        "快点吧，我等到花儿都谢了！",
        "你好，很高兴见到你！",
        "糟糕，这一步走坏了！",
        "好棋！",
        "和你下棋真是太愉快了!",
        "我们交个朋友吧！",
        "不要急，这一步让我好好想想。",
        "不要走，我们来大战三百回合！",
        "我要离开一会，下次再玩吧！",
       }
    self.m_phrases_btns = {};
    for i,v in ipairs(self.m_phrases) do
        self.m_phrases_btns[i] = new(ChatPhrasesItem,v);
        self.m_phrases_btns[i]:setClickEvent(self,self.onPhrasesItemClick);
        self.m_chat_book_view:addChild(self.m_phrases_btns[i]);
    end
    -------
--    local data = {};
--	data.name = "博雅中国象棋";
--	data.str = "欢迎来到博雅中国象棋！";
--    data.uid = 0;
--    self:addChatLog(data.name,data.str,data.uid);

--	self.m_log = {data};
    self:setNeedMask(false)
    self:selectBtn(1)
end

ChatDialog.dtor = function(self)
	self.m_root_view = nil;
    self.m_chat_view_handler:removeProp(1);
    delete(self.m_timer);
    if not self.m_room.m_board_view:checkAddProp(1) then 
		self.m_room.m_board_view:removeProp(1);
	end
    if not self.m_room.m_board_view:checkAddProp(2) then 
		self.m_room.m_board_view:removeProp(2);
	end
    if not self.m_room.room_bg_temp:checkAddProp(1) then 
		self.m_room.room_bg_temp:removeProp(1);
	end
    
    self.m_room.room_bg_temp:removeProp(1);
    self.m_room.m_board_view:removeProp(2);

    if self.m_room_chat_view then
        delete(self.m_room_chat_view);
        self.m_room_chat_view = nil;
    end
end

function ChatDialog.setCheckStatus(view,flag)
    if not view then return end
    local txt = view:getChildByName("title")
    if flag then
        view:setFile("common/button/table_chose_5.png")
        txt:setColor(95,15,15)
    else
        view:setFile("common/button/table_nor_5.png")
        txt:setColor(230,185,140)
    end
end

function ChatDialog:selectBtn(index)
    self.setCheckStatus(self.m_chat_book_btn,false)
    self.setCheckStatus(self.m_chat_history_btn,false)
    self.m_chat_book_view:setVisible(false)
    self.m_room_chat_view:setVisible(false)
    if index == 1 then
        self.setCheckStatus(self.m_chat_book_btn,true)
        self.m_chat_book_view:setVisible(true)
    else
        self.setCheckStatus(self.m_chat_history_btn,true)
        self.m_room_chat_view:setVisible(true)
    end
end

-- 联网对战聊天直接显示常用语
ChatDialog.showChatBook = function(self)
    local w,h = self.m_chat_bg:getSize();
    self.m_chat_bg:removeProp(1);
    --常用语上滑动画
    self.m_chat_bg:setVisible(true);
    self.m_chat_bg:addPropTranslate(1, kAnimNormal, 100, -1, 0, 0, h, 0);  --h,0
end;


ChatDialog.isShowing = function(self)
	return self:getVisible();
end

ChatDialog.onPhrasesItemClick = function(self,item)
	local message = GameString.convert2UTF8(item:getText());
    self.m_input_edit:setText(message);
    self:sendRoomChat();
	kEffectPlayer:playEffect(Effects.AUDIO_BUTTON_CLICK);
end

ChatDialog.onLogItemClick = function ( self,adapter,item,postion)
	local message = self.m_input_edit:getText() .. item:getText();
	self.m_input_edit:setText(message);
	kEffectPlayer:playEffect(Effects.AUDIO_BUTTON_CLICK);
end

ChatDialog.onTouch = function(self)
	print_string("ChatDialog.onTouch");
end

ChatDialog.showPhrases = function(self)

	print_string("ChatDialog.showPhrases");
end
--房间内聊天 item
ChatDialog.addChatLog = function(self,name,message,uid)
	if not message or message == "" then
		return
	end
    if FriendsData.getInstance():isInBlacklist(tonumber(uid)) then return end
	local data = {};
	data.name = GameString.convert2UTF8(name);
	data.str = GameString.convert2UTF8(message);
    data.uid = uid;
    
	local item = new(ChatLogItem,data);
    local item1 = new(ChatHistoryItem,data);
    if data.uid and type(data.uid) == "number" then
        if not UserInfoDialog2.s_forbid_id_list[data.uid] then
            self.m_room_chat_view:addChild(item);
            self.m_room_chat_view:gotoBottom();     
        end;
    end;
end

--房间聊天
ChatDialog.sendRoomChat = function(self)
	local message = GameString.convert2UTF8(self.m_input_edit:getText());
--	print_string("ChatDialog.sendChat message = " .. message);

	if not message or message == "" or message == "" then
        ChessToastManager.getInstance():showSingle("消息不能为空！",800); 
		return
	end
    
    local lens = string.lenutf8(GameString.convert2UTF8(message) or "");    
    if lens > 60 then--限制60字
        ChessToastManager.getInstance():showSingle("消息不能超过60字！",800); 
		return       
    end;

    self.m_input_edit:setText();
--	self:dismiss();

	local roomType = RoomProxy.getInstance():getCurRoomType();

	if roomType == RoomConfig.ROOM_TYPE_WATCH_ROOM then  --如果是观战
        self.m_room.mModule:sendWatchChat(message);
	else
		self.m_room:sendChat(1,message);    
        self:dismiss();
	end
end

ChatDialog.chat_len = 32;
ChatDialog.contentTextChange = function(self,text)
	local content = self.m_input_edit:getText();
	if string.len(content)  > ChatDialog.chat_len  then
		content = string.subutf8(content,1,ChatDialog.chat_len/2);
		self.m_input_edit:setText(content);
	end
end

ChatDialog.show = function(self)

	print_string("ChatDialog.show");
    self:showChatBook();
    self.m_input_edit:setText();
    self:setVisible(true);
    self.super.show(self,false);
end

ChatDialog.reset = function(self)
    self.m_chat_view_handler:setVisible(true);
end
-------弹出dialog 动画效果--------------
ChatDialog.startAnim = function(self)
	print_string("ChatDialog.startAnim");
    if not self.m_chat_bg:checkAddProp(1) then 
		self.m_chat_bg:removeProp(1);
	end
    delete(self.m_timer);

    local w,h = self.m_root_view:getSize();
    local bw,bh = self.m_room.m_board_view:getSize();
    self.pos_h = (h - bh)/2;
    self.m_timer = new(AnimInt,kAnimNormal,0,1,130,-1);
    self.m_timer:setEvent(self,function()
        delete(self.m_timer);
        self:startBoardAnim();
    end);
    local _,temp_h = self.m_chat_bg:getSize();
    self.m_animGameTranslate = self.m_chat_bg:addPropTranslate(1,kAnimNormal,300,-1,0,0,temp_h,0);
    self.m_animGameTranslate:setEvent(self,self.onGameTranslateFinish);
    self.m_animGameTranslate:setDebugName("AnimInt|ChatDialog.startAnim");
end

ChatDialog.startBoardAnim = function(self)
--    delete(self.m_timer);
    self.m_room.room_bg_temp:setVisible(true);
    if not self.m_room.m_board_view:checkAddProp(1) then 
		self.m_room.m_board_view:removeProp(1);
	end
    if not self.m_room.m_board_view:checkAddProp(2) then 
		self.m_room.m_board_view:removeProp(2);
	end
    if not self.m_room.room_bg_temp:checkAddProp(1) then 
		self.m_room.room_bg_temp:removeProp(1);
	end

    local w,h = self.m_root_view:getSize();
    local x,y = self.m_room.m_board_view:getPos();
    local bw,bh = self.m_room.m_board_view:getSize();
    local parAnim = self.m_room.m_board_view:addPropTranslate(1,kAnimNormal,170,-1,0,0,0,bh/2 - h/2);
    local parAnim1 = self.m_room.m_board_view:addPropScale(2,kAnimNormal,170,-1,1,0.8,1,0.8,kCenterDrawing);
    self.m_room.room_bg_temp:addPropTransparency(1,kAnimNormal,100,-1,0,1);
    parAnim:setEvent(self,function()
        delete(anim);
        delete(parAnim);
        delete(releaseAnim);
    end)
    
end

ChatDialog.onGameTranslateFinish = function(self)
	if not self.m_chat_bg:checkAddProp(1) then 
		self.m_chat_bg:removeProp(1);
	end
end
--------结束-----------------

ChatDialog.dismiss = function(self)
    self.super.dismiss(self,false);
    self:goBackAnim();
end

-- 联网对战聊天没有棋盘操作，所以只有下滑动画
ChatDialog.goBackAnim = function(self)
    local w,h = self.m_chat_book_view:getSize();
    self.m_chat_bg:removeProp(1);
    --常用语下滑动画
    local chat_bg_anim = self.m_chat_bg:addPropTranslate(1, kAnimNormal, 100, -1, 0, 0, -h, 0);  --h,0
    if chat_bg_anim then
        chat_bg_anim:setEvent(self, function() 
            self:setVisible(false);
        end);
    end;
end;


-------------------------------------------------------------------------------------------------------------

ChatPhrasesItem = class(Node);

ChatPhrasesItem.ctor = function(self,str)
--	local text_x = 0;
--    super(self, "drawable/blank.png");
    local w,h = 620,73;
	print_string("ChatPhrasesItem.ctor str = " .. str);

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


ChatPhrasesItem.getText = function(self)
	return self.m_text:getText();
end

ChatPhrasesItem.onItemClick = function(self)
    if self.m_click_event and self.m_click_event.func then
        self.m_click_event.func(self.m_click_event.obj,self);
    end
end

ChatPhrasesItem.setClickEvent = function(self,obj,func)
    self.m_click_event = {};
    self.m_click_event.obj = obj;
    self.m_click_event.func = func;
end

ChatPhrasesItem.dtor = function(self)
	
end	


-------------------------------------------------------------------------------------------------------------

ChatLogItem = class(Node);

ChatLogItem.DEFAULT_w = 620;
ChatLogItem.DEFAULT_h = 70;

ChatLogItem.ctor = function(self,data)

	self.m_name = data.name;
	self.m_str = data.str;
    self.m_uid = data.uid;
    FriendsData.getInstance():getUserData(self.m_uid);
    local nameStr = "#c507DBE" .. self.m_name .. "：";
    local chatStr = "#n"..self.m_str;
    self.item_text = new(RichText,nameStr .. chatStr,ChatLogItem.DEFAULT_w,nil,kAlignLeft,nil,30,80,80,80,true,5);
    self.item_text:setAlign(kAlignTopLeft);
    self.item_text:setPos(0,10);
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
    self.item_line:setSize(ChatLogItem.DEFAULT_w,1);
--    self.item_line:setPos(0,-15);
    self:addChild(self.item_line);
    local _,h = self.item_text:getSize();
    self:setSize(ChatLogItem.DEFAULT_w,h+10);
    self:setAlign(kAlignLeft);
	self:setEventTouch(self,ChatLogItem.onTouch);
end

ChatLogItem.showUserInfo = function(self)
    if self.m_uid == UserInfo.getInstance():getUid() then
        Log.i("ChatLogItem.showUserInfo--name click yourself!");
    else
        if not self.m_userinfo_dialog then
            -- TODO UserInfoDialog2 从场景中分离出来的dlg,后续会同步到联网对战
            self.m_userinfo_dialog = new(UserInfoDialog2);
        end;
        if self.m_userinfo_dialog:isShowing() then return end
        self.m_userinfo_dialog:setShowType(UserInfoDialog2.SHOW_TYPE.WATCH_ROOM)
        local user = FriendsData.getInstance():getUserData(self.m_uid)
        self.m_userinfo_dialog:show(user,self.m_uid)

--        self.m_userinfo_dialog:setForbidVisible(true);
--        self.m_extra_msg = FriendsData.getInstance():getUserData(self.m_uid);
--        if self.m_extra_msg and  next(self.m_extra_msg) then
--            self.m_userinfo_dialog:show(self.m_extra_msg);
--        end
    end;
end;

ChatLogItem.getText = function(self)
	return self.m_str;
end

ChatLogItem.getName = function(self)
	return self.m_name;
end

ChatLogItem.dtor = function(self)
	self.m_root_view = nil;
    if self.m_userinfo_dialog then
        delete(self.m_userinfo_dialog);
        self.m_userinfo_dialog = nil;
    end;
end	


-----------------------

ChatHistoryItem = class(Node);

ChatHistoryItem.DEFAULT_w = 620;
ChatHistoryItem.DEFAULT_h = 70;

ChatHistoryItem.ctor = function(self,data)

	self.m_name = data.name;
	self.m_str = data.str;
    self.m_uid = data.uid;
--    local nameStr = "#c507DBE" .. self.m_name .. "：";
--    local chatStr = "#n"..self.m_str;
    local nameStr = self.m_name .."：";
    local chatStr = self.m_str;
    self.item_text = new(RichText,nameStr .. chatStr,ChatLogItem.DEFAULT_w,nil,kAlignLeft,nil,30,255,255,255,true,5);
    self.item_text:setAlign(kAlignLeft);
    self.item_text:setPos(0,10);
    self:addChild(self.item_text);
    local h = self.item_text:getTotalHeight();
    self:setSize(ChatHistoryItem.DEFAULT_w,h+10);
	self:setEventTouch(self,ChatHistoryItem.onTouch);
end

ChatHistoryItem.getText = function(self)
	return self.m_str;
end

ChatHistoryItem.getName = function(self)
	return self.m_name;
end

ChatHistoryItem.dtor = function(self)
	
end	