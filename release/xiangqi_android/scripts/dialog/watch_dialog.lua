
require("audio/sound_manager");
require("ui/node");
require("ui/adapter");
require("ui/listView");
require("dialog/user_info_dialog2")
require(VIEW_PATH .."watcher_node");
require(VIEW_PATH .. "watch_dialog_view");
require(BASE_PATH.."chessDialogScene")
WatchDialog = class(ChessDialogScene,false);
WatchDialog.s_data = {};
WatchDialog.ctor = function(self,room)
    super(self,watch_dialog_view);
    self.m_room = room;
	self.m_root_view = self.m_root;
    self.m_new_watch_chat_view = self.m_root_view:getChildByName("chat_view");
    -- 聊天view
    self.m_chat_info_view = self.m_new_watch_chat_view:getChildByName("chat_info_view");
        -- 聊天bg
        self.m_chat_info_bg = self.m_chat_info_view:getChildByName("chat_bg");
        self.m_chat_info_bg:setFillParent(false,true);
            -- 聊天info
            local svW, svH = self.m_chat_info_bg:getSize();
            self.m_chat_info = new(ScrollView2,0,0,svW,svH,true);
            self.m_chat_info:setFillParent(true,true);
            self.m_chat_info_bg:addChild(self.m_chat_info);
            -- 聊天people
            self.m_chat_people = new(ScrollView2,0,0,svW,svH,true);
            self.m_chat_people:setFillParent(true,true);
            self.m_chat_people:setOnScrollBouncing(self, self.onScrollViewBouncingUpdate);
            self.m_chat_info_bg:addChild(self.m_chat_people);
        -- 聊天info_btn
        self.m_chat_info_btn = self.m_chat_info_view:getChildByName("chat_info_btn");
        self.m_chat_info_btn:setOnClick(self,self.chatInfoSelect);
            -- “聊”
            self.m_chat_info_txt1 = self.m_chat_info_btn:getChildByName("chat_txt1");
            self.m_chat_info_txt1:setColor(80,80,80);
            -- “天”
            self.m_chat_info_txt2 = self.m_chat_info_btn:getChildByName("chat_txt2");
            self.m_chat_info_txt2:setColor(80,80,80);
        -- 聊天people_btn
        self.m_chat_people_btn = self.m_chat_info_view:getChildByName("watch_people_btn");
        self.m_chat_people_btn:setOnClick(self,self.chatPeopleSelect);
            -- “观”
            self.m_chat_people_txt1 = self.m_chat_people_btn:getChildByName("chat_txt1");
            self.m_chat_people_txt1:setColor(235,230,200);
            -- “战”
            self.m_chat_people_txt2 = self.m_chat_people_btn:getChildByName("chat_txt2");
            self.m_chat_people_txt2:setColor(235,230,200);
        -- 屏幕适配
        local boardX, boardY = self.m_room.m_board_view:getPos();
        local boardW, boardH = self.m_room.m_board_bg:getSize(); 
        local rootW, rootH = self.m_room.m_root_view:getSize();
        local chat_viewH = rootH - (boardY + boardH + 60 - 20);-- 60(发送view的高)，20(棋盘真实大小与资源大小的差值)
        self.m_chat_info_view:setSize(nil,chat_viewH);
        self.m_chat_info_btnH = (chat_viewH - 2 * 10) / 2;--10(btn的Y坐标)
        self.m_chat_info_btn:setSize(nil, self.m_chat_info_btnH);
        self.m_chat_people_btn:setSize(nil, self.m_chat_info_btnH);
    -- 发送view
    self.m_send_chat_view = self.m_new_watch_chat_view:getChildByName("send_chat_view");
        -- inputView
        self.m_input_view = self.m_send_chat_view:getChildByName("input_view");
            -- 常用语btn
            self.m_chat_book_btn = self.m_input_view:getChildByName("chat_book");
            self.m_chat_book_btn:setOnClick(self, self.showChatBook);
            -- 发送btn
            self.m_send_btn = self.m_input_view:getChildByName("send_btn");
            self.m_send_btn:setOnClick(self,self.sendChat);
            -- edit_bg
            self.m_edit_bg = self.m_input_view:getChildByName("edit_bg");
                -- input_edit
                self.m_edit_txt = self.m_edit_bg:getChildByName("input_edit");
                self.m_edit_txt:setHintText("点击输入聊天内容",165,145,125);
            -- 常用语
            self.m_chat_book_bg = self.m_input_view:getChildByName("chat_book_bg");
            local svcbW, svcbH = self.m_chat_book_bg:getSize();
            self.m_chat_book_view = new(ScrollView2,0,0,svcbW,svcbH,true);
            self.m_chat_book_view:setAlign(kAlignBottom);
            self.m_input_view:addChild(self.m_chat_book_view);
    

    -- 全屏view
    self.m_full_screen_view = self.m_root_view:getChildByName("full_screen_view");
        -- bg
        self.m_full_screen_bg = self.m_full_screen_view:getChildByName("bg");
        self.m_full_screen_bg:setTransparency(0.8);
        -- front_bg
        self.m_full_screen_front_bg = self.m_full_screen_view:getChildByName("front_bg");
        self.m_full_screen_front_bg:setEventTouch(self, self.hideFullScreen);
        -- 棋盘
        self.m_full_screen_board = self.m_full_screen_view:getChildByName("chess_board");

        -- tips
        self.m_tip_hide_screen = self.m_full_screen_view:getChildByName("hidescreen");

        -- 聊天历史
        self.m_full_screen_chat = new(ScrollView2,0,0,617,220,true);-- 225显示5行
        self.m_full_screen_chat:setAlign(kAlignBottom);
        self.m_full_screen_chat:setPos(0,80);
        self.m_full_screen_chat:setLevel(1);
        self.m_full_screen_view:addChild(self.m_full_screen_chat);
    --房间内常用语
	self.m_phrases = {
        "呀！大意失荆州啊！",
        "当局者迷,旁观者清。",
        "观棋不语真君子，落子无悔大丈夫！",
        "急甚，容我--再思量思量.",
        "两军相争勇者胜！",
        "你这是, 单车寡炮瞎胡闹啊。",
        "请君，神速些吧！",
        "呵呵!小卒过河赛大车！",
        "一着不慎，满盘皆输！",
        "与你对局，此乃幸事！",
        "再与我对弈一局？"
    }
    self.m_phrases_btns = {};
    for i,v in ipairs(self.m_phrases) do
        self.m_phrases_btns[i] = new(ChatPhrasesItem,v);
        self.m_phrases_btns[i]:setClickEvent(self,self.onPhrasesItemClick);
        self.m_chat_book_view:addChild(self.m_phrases_btns[i]);
    end
    -------
    local data = {};
	data.name = "博雅中国象棋";
	data.str = "欢迎来到博雅中国象棋！";
    data.uid = 0;
    self:addChatLog(data.name,data.str,data.uid);
    self:initWatcher();
    self:setShieldClick(self,self.goBackAnim);
    self:setNeedBackEvent(false);
    self:setBgOnTouchClick(nil);
    self.m_all_chat_people = {};
    EventDispatcher.getInstance():register(Event.Call,self,self.onEventResponse);
end

WatchDialog.dtor = function(self)
    WatchDialog.s_data = {};
    EventDispatcher.getInstance():register(Event.Call,self,self.onEventResponse);
end


WatchDialog.chatInfoSelect = function(self)
    self.m_chat_info_btn:setFile("common/button/table_chose_3_press.png");
    self.m_chat_info_btn:setSize(71,self.m_chat_info_btnH);
    self.m_chat_info_btn:setPos(-302,10);
    self.m_chat_people_btn:setFile("common/button/table_chose_3_nor.png");
    self.m_chat_people_btn:setSize(62,self.m_chat_info_btnH);
    self.m_chat_people_btn:setPos(-307,10);
    self.m_chat_info_txt1:setColor(80,80,80);
    self.m_chat_info_txt1:setPos(0,23);
    self.m_chat_info_txt2:setColor(80,80,80);
    self.m_chat_info_txt2:setPos(0,23);
    self.m_chat_people_txt1:setColor(235,230,200);
    self.m_chat_people_txt1:setPos(4,23);
    self.m_chat_people_txt2:setColor(235,230,200);
    self.m_chat_people_txt2:setPos(4,23);

    self.m_chat_info:setVisible(true);
    self.m_chat_people:setVisible(false);
end;


WatchDialog.chatPeopleSelect = function(self)
    self.m_chat_people_btn:setFile("common/button/table_chose_3_press.png");
    self.m_chat_people_btn:setSize(71,self.m_chat_info_btnH);
    self.m_chat_people_btn:setPos(-302,10);
    self.m_chat_info_btn:setFile("common/button/table_chose_3_nor.png");
    self.m_chat_info_btn:setSize(62,self.m_chat_info_btnH);
    self.m_chat_info_btn:setPos(-307,10);
    self.m_chat_people_txt1:setColor(80,80,80);
    self.m_chat_people_txt1:setPos(0,23);
    self.m_chat_people_txt2:setColor(80,80,80);
    self.m_chat_people_txt2:setPos(0,23);
    self.m_chat_info_txt1:setColor(235,230,200);
    self.m_chat_info_txt1:setPos(4,23);
    self.m_chat_info_txt2:setColor(235,230,200);
    self.m_chat_info_txt2:setPos(4,23);

    self.m_chat_people:setVisible(true);
    self.m_chat_info:setVisible(false);
    
    -- 获取观战者列表
    self:getWatcherList();
end;

WatchDialog.getWatcherList = function(self)
    if not next(WatchDialog.s_data) then
        -- 获取观战列表
        local info = {};
        info.tid = UserInfo.getInstance():getTid();
        OnlineSocketManager.getHallInstance():sendMsg(OB_CMD_GET_OB_LIST,info);
        -- 获取观战人数
        OnlineSocketManager.getHallInstance():sendMsg(OB_CMD_GET_NUM,info);
    end;
end;


WatchDialog.setListView = function(self, data)
    if not data or not next(data) then return end;

    local index = 0;
    for i = 1,#data do
        if (i-1)%8 == 0 then
            index = index + 1;
            WatchDialog.s_data[index] = {};
        end;
        WatchDialog.s_data[index][((i-1)%8)+1] = data[i];
    end;
    self.m_data_index = 1;
    if self:isShowing() and WatchDialog.s_data[self.m_data_index] then
        self:updataListView(WatchDialog.s_data[self.m_data_index]);
    end    

end;

-- direction:ScrollView回弹方向,1(底部向下回弹);-1(顶部向上回弹)
WatchDialog.onScrollViewBouncingUpdate = function(self, direction)
    self.m_scroll_bouncing_direction = direction;
    if self.m_scroll_bouncing_direction and self.m_scroll_bouncing_direction == 1 then
        self.m_data_index = self.m_data_index + 1;
        if self.m_data_index <= #WatchDialog.s_data then
            self:updataListView(WatchDialog.s_data[self.m_data_index]);
            self.m_chat_people:gotoBottom();
        end;
    end;
end;


WatchDialog.updataListView = function(self,data)
    if not data or #data == 0 then return end
    local node;
    for k,v in pairs(data) do
        v.room = self;
        if ((k - 1) % 4) == 0 then
            node = new(Node)
            local sW,sH = self.m_chat_people:getSize();
            node:setSize(sW,sH);
            node:setAlign(kAlignTopLeft);
            self.m_chat_people:addChild(node);
        end;
        table.insert(self.m_all_chat_people,new(WatcherItem,k,v,node));
    end
end



WatchDialog.showChatBook = function(self)
    self.m_chat_book_btn:setVisible(false);
    self.m_edit_bg:setSize(520,nil);
    self.m_edit_txt:setSize(500,nil);
    local w,h = self.m_edit_txt:getSize();
    local x,y = self.m_edit_txt:getPos();
    self.m_edit_txt:setClip(x,y,w,h);
    local text = self.m_edit_txt:getText();
    if text == "" or text == " " then 
        self.m_edit_txt:setText();
    else
        self.m_edit_txt:setText(text);
    end;
    local w,h = self.m_chat_book_view:getSize();
    self.m_send_chat_view:removeProp(2);
    --常用语上滑动画
    self.m_send_chat_view:addPropTranslate(1, kAnimNormal, 100, -1, 0, 0, 0, -h);
    self:setBgOnTouchClick(self.s_shieldTouchClick);
    self.m_is_show_chat_book = true;
end;


WatchDialog.dismiss = function(self)
    self:setVisible(false);
    self.super.dismiss(self,false);
end


WatchDialog.goBackAnim = function(self)
    self.m_chat_book_btn:setVisible(true);
    self.m_edit_bg:setSize(402,nil);
    self.m_edit_txt:setSize(375,nil);
    local w,h = self.m_edit_txt:getSize();
    local x,y = self.m_edit_txt:getPos();
    self.m_edit_txt:setClip(x,y,w,h);
    local text = self.m_edit_txt:getText();
    if text == "" or text == " " then 
        self.m_edit_txt:setText();
    else
        self.m_edit_txt:setText(text);
    end;
    self.m_edit_txt:setText(text);
    local w,h = self.m_chat_book_view:getSize();
    self.m_send_chat_view:removeProp(1);
    --常用语下滑动画
    self.m_send_chat_view:addPropTranslate(2, kAnimNormal, 100, -1, 0, 0, -h, 0);
    self:setBgOnTouchClick(nil);
    self.m_is_show_chat_book = false;
end;

WatchDialog.onPhrasesItemClick = function(self,item)
	local message = GameString.convert2UTF8(item:getText());
	self.m_edit_txt:setText(message);
	kEffectPlayer:playEffect(Effects.AUDIO_BUTTON_CLICK);
end


WatchDialog.isShowing = function(self)
	return self:getVisible();
end


WatchDialog.onLogItemClick = function ( self,adapter,item,postion)
	local message = self.m_input_edit:getText() .. item:getText();
	self.m_input_edit:setText(message);
	kEffectPlayer:playEffect(Effects.AUDIO_BUTTON_CLICK);
end

WatchDialog.onTouch = function(self)
	print_string("WatchDialog.onTouch");
end

WatchDialog.showPhrases = function(self)

	print_string("WatchDialog.showPhrases");
end
--房间内聊天 item
WatchDialog.addChatLog = function(self,name,message,uid)
	if not message or message == "" then
		return
	end
	local data = {};
	data.name = GameString.convert2UTF8(name);
	data.str = GameString.convert2UTF8(message);
    data.uid = uid;

	local item = new(ChatLogItem,data);
    local item1 = new(ChatHistoryItem,data);
    self.m_chat_info:addChild(item);
    self.m_full_screen_chat:addChild(item1);
    self.m_chat_info:gotoBottom();
    self.m_full_screen_chat:gotoBottom();
end


WatchDialog.initWatcher = function(self)
    self.m_chat_people:setVisible(false);
    local cur_watch_node = new(Node);
    cur_watch_node:setAlign(kAlignTop);
    cur_watch_node:setFillParent(true,false);
    cur_watch_node:setSize(nil, 90);
    -- 在线                  str, width, height, align, fontName, fontSize, r, g, b)
    local cur_txt = new(Text,"当前共有        人在观战",0,0,kAlignCenter,nil,32,80,80,80);
    cur_txt:setAlign(kAlignTop);
    cur_txt:setPos(0,20);
    -- 在线人数
    self.m_cur_txt_num = new(Text,"0",0,0,kAlignCenter,nil,38,0,255,0);
    self.m_cur_txt_num:setAlign(kAlignCenter);
    cur_txt:addChild(self.m_cur_txt_num);
    cur_watch_node:addChild(cur_txt);
    -- line
    local cur_line = new(Image,"common/decoration/line.png");
    cur_line:setAlign(kAlignCenter);
    cur_line:setSize(570,19);
    cur_line:setPos(0,25);
    cur_watch_node:addChild(cur_line);
    self.m_chat_people:addChild(cur_watch_node);

end;



--发送消息
WatchDialog.sendChat = function(self)
    self:sendRoomChat();
end

--房间聊天
WatchDialog.sendRoomChat = function(self)
	local message = GameString.convert2UTF8(self.m_edit_txt:getText());
	if not message or message == " " or message == "" then
        ChessToastManager.getInstance():showSingle("消息不能为空！",800); 
		return
	end
     
    self.m_edit_txt:setText(nil);
    self.m_room:sendWatchChat(message);
--	self.m_room:showWatchChat(UserInfo.getInstance():getName(),1,message,UserInfo.getInstance():getUid());   
    if self.m_is_show_chat_book then
        self:goBackAnim();
    end;

end

WatchDialog.chat_len = 32;
WatchDialog.contentTextChange = function(self,text)
	local content = self.m_input_edit:getText();
	if string.len(content)  > WatchDialog.chat_len  then
		content = string.subutf8(content,1,WatchDialog.chat_len/2);
		self.m_input_edit:setText(content);
	end
end

WatchDialog.show = function(self)
    self:setVisible(true);
    self.super.show(self,false,false);
end



WatchDialog.updataWatchNum = function(self, info)
    if not info or not info.ob_num then return end
    local text = info.ob_num;
    local num = tonumber(info.ob_num);
    -- 根据界面宽度写出
    if num and num >= 1000 then
        text = '999+'
    end
    self.m_cur_txt_num:setText(text);
end;

WatchDialog.fullScreen = function(self)
    self.m_full_screen_front_bg:setLevel(1);
    self.m_full_screen_view:setVisible(true);
    self.m_board = self.m_room.m_board_view;
    local oldBoardW,oldBoardH = self.m_room.m_board_bg:getSize();
    local w , h = self:getSize();
    local fullChatInfoW,fullChatInfoH = self.m_full_screen_chat:getSize();
    local fullChatInfoX,fullChatInfoY = self.m_full_screen_chat:getPos();
    local leftH = h - fullChatInfoH - fullChatInfoY;
    local scale = oldBoardH / oldBoardW;
    local newBoardH = w * scale;
    if newBoardH > leftH then 
        newBoardH = leftH;
    end;
    local boardScale = newBoardH / oldBoardH;
    self.m_board:addPropScale(1, kAnimNormal, 100, -1, 1,boardScale,1,boardScale,kCenterDrawing);
   
    self.m_full_screen_board:addChild(self.m_board);
end;


WatchDialog.hideFullScreen = function(self)
    self.m_full_screen_front_bg:setLevel(0);
    self.m_full_screen_view:setVisible(false);
    self.m_board:removeProp(1);
    self.m_room.m_root_view:addChild(self.m_board);
end;    


WatchDialog.updateChatPeople = function(self, data)
    for i = 1, #self.m_all_chat_people do
        if self.m_all_chat_people[i]:getUid() == data.target_uid then
            self.m_all_chat_people[i]:updateItem(data);
        end;
    end;
end;



WatchDialog.onEventResponse = function(self, cmd, status, data)
    if cmd == kFriend_FollowCallBack then
        if status.ret and status.ret == 0 then
            self:updateChatPeople(status);
        end
    end;
end;


-------------------------------------------------------------------------------------------------------------

WatcherItem = class(Node);

WatcherItem.ctor = function(self, index,data, node)
    local data = json.decode(data.userInfo);
    if data then
        self.m_index = index;
        self.m_uid = data.uid;
        self.m_root_view = SceneLoader.load(watcher_node);
        self.m_watcher_node = self.m_root_view:getChildByName("watcher_node");
        -- icon
        self.m_watcher_icon_view = self.m_watcher_node:getChildByName("icon");
        self.m_watcher_icon_frame = self.m_watcher_icon_view:getChildByName("icon_frame");
        self.m_watcher_icon = new(Mask,"userinfo/icon_8484_mask.png","userinfo/icon_8484_mask.png");
        self.m_watcher_icon:setUrlImage(data.icon,UserInfo.DEFAULT_ICON[1]);
        self.m_watcher_icon:setAlign(kAlignCenter);
        self.m_watcher_icon_frame:addChild(self.m_watcher_icon);

        -- level
        self.m_watcher_level = self.m_watcher_icon_view:getChildByName("level");
        self.m_watcher_level:setFile("common/icon/level_"..10 - UserInfo.getInstance():getDanGradingLevelByScore(tonumber(data.score))..".png");

        -- name
        self.m_watcher_name_score_view = self.m_watcher_node:getChildByName("name_score");
        self.m_watcher_name = self.m_watcher_name_score_view:getChildByName("name");
        self.m_watcher_name:setText(data.user_name);
        -- score
        self.m_watcher_score = self.m_watcher_name_score_view:getChildByName("score");
        self.m_watcher_score:setText("积分："..data.score);

        -- add_btn
        self.m_add_btn = self.m_watcher_node:getChildByName("add_btn");
        self.m_add_btn:setOnClick(self,self.toAddFriend);
        self.m_add_btn_txt = self.m_add_btn:getChildByName("add_txt");
        if FriendsData.getInstance():isYourFollow(self.m_uid) == -1 then
            if FriendsData.getInstance():isYourFriend(self.m_uid) == -1 then
                self.m_add_btn_txt:setText("加关注");
            else
                self.m_add_btn_txt:setText("已关注");
            end;
        else
            self.m_add_btn_txt:setText("已关注");
        end;
        if self.m_uid == UserInfo.getInstance():getUid() then
            self.m_add_btn:setVisible(false); 
        end;
        node:addChild(self.m_root_view);
        self.m_root_view:setPos(((index - 1)%4) * 155,0);
        self.m_root_view:setSize(155,250);
    else

        Log.i("ssss");
    end;
 
end;

WatcherItem.toAddFriend = function(self)
    if FriendsData.getInstance():isYourFollow(self.m_uid) == -1 then
        if FriendsData.getInstance():isYourFriend(self.m_uid) == -1 then
            self:follow(self.m_uid);
        else
            self:unFollow(self.m_uid);
        end;
    else
        self:unFollow(self.m_uid);
    end
end;

-- 关注
WatcherItem.follow = function(self,gz_uid)
    local info = {};
    info.uid = UserInfo.getInstance():getUid();
    info.target_uid = gz_uid;
    info.op = 1;
    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_ADD_FLLOW,info);
end;


--取消关注
WatcherItem.unFollow = function(self,gz_uid)
    local info = {};
    info.uid = UserInfo.getInstance():getUid();
    info.target_uid = gz_uid;
    info.op = 0;
    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_ADD_FLLOW,info);
end

WatcherItem.dtor = function(self)
	
end	

WatcherItem.getUid = function(self)
    return self.m_uid or 0;
end;

WatcherItem.updateItem = function(self, data)
    -- 发起关注/取消关注，server返回会先更新FriendData的isYourFollow
    if FriendsData.getInstance():isYourFollow(self.m_uid) == -1 then
        if FriendsData.getInstance():isYourFriend(self.m_uid) == -1 then
            ChessToastManager.getInstance():showSingle("已取消关注");
            self.m_add_btn_txt:setText("加关注");
        else
            ChessToastManager.getInstance():showSingle("关注成功！");
            self.m_add_btn_txt:setText("已关注");                 
        end;
    else
        ChessToastManager.getInstance():showSingle("关注成功！");
        self.m_add_btn_txt:setText("已关注");
    end;

end;






-------------------------------------------------------------------------------------------------------------

ChatPhrasesItem = class(Node);

ChatPhrasesItem.ctor = function(self,str)
--	local text_x = 0;
--    super(self, "drawable/blank.png");
    local w,h = 670,73;
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

ChatLogItem.DEFAULT_w = 660;
ChatLogItem.DEFAULT_h = 62;

ChatLogItem.ctor = function(self,data)

	self.m_name = data.name;
	self.m_str = data.str;
    self.m_uid = data.uid;
    FriendsData.getInstance():getUserData(self.m_uid);
    local nameStr = "#c507DBE" .. self.m_name .. "：";
    local chatStr = "#c505050"..self.m_str;
    self.item_text = new(RichText,nameStr .. chatStr,606,nil,kAlignLeft,nil,30,80,80,80,true,5);
    self.item_text:setAlign(kAlignTopLeft);
    self.item_text:setPos(18,0);
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
    self.item_line:setSize(620,1);
--    self.item_line:setPos(0,-15);
    self:addChild(self.item_line);
    local _,h = self.item_text:getSize();
    self:setSize(ChatLogItem.DEFAULT_w,h);
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
        self.m_extra_msg = FriendsData.getInstance():getUserData(self.m_uid);
        if self.m_extra_msg and  next(self.m_extra_msg) then
            self.m_userinfo_dialog:show(self.m_extra_msg);
        end
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
end	


-----------------------

ChatHistoryItem = class(Node);

ChatHistoryItem.DEFAULT_w = 660;
ChatHistoryItem.DEFAULT_h = 62;

ChatHistoryItem.ctor = function(self,data)

	self.m_name = data.name;
	self.m_str = data.str;
    self.m_uid = data.uid;
    local nameStr = self.m_name .. "：";
    local chatStr = self.m_str;
    self.item_text = new(RichText,nameStr .. chatStr,606,nil,kAlignLeft,nil,28,255,255,255,true,5);
    self.item_text:setAlign(kAlignLeft);
    self.item_text:setPos(10,0);
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