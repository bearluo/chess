--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require(VIEW_PATH .. "room_friend_wait_setTime_view");
require(BASE_PATH.."chessDialogScene")
require("ui/scrollViewEx");

RoomFriendWaitSetTime = class(ChessDialogScene,false)

RoomFriendWaitSetTime.ctor = function(self)
    super(self,room_friend_wait_setTime_view)
    self.mBg = self.m_root:getChildByName("bg")
    self.mTitleView = self.mBg:getChildByName("title_view")
    self.mShowUpUserInfoBtn = self.m_root:getChildByName("show_up_userinfo_btn")
    self.mShowUpUserInfoBtn:setEventTouch(self,self.onShowUpUserInfoBtnClick)
    self:updateTitleView()
    self:initTimeSetView()
    self:initChatView()
    self:setNeedBackEvent(false)
    self:setNeedMask(false)
    self:setLevel(-1)
    self.mDialogAnim = AnimDialogFactory.createMoveUpAnim(self)
end

function RoomFriendWaitSetTime:updateTitleView(second)
    second = tonumber(second) or 0
    self.mTitleView:removeAllChildren()
    local startPos = 0
    local txt1 = new(Text,"配对成功,您", width, height, align, fontName, 34, 80, 80, 80)
    txt1:setPos(startPos)
    startPos = txt1:getSize() + startPos
    self.mTitleView:addChild(txt1)
    local txt2 = new(Text,"执黑", width, height, align, fontName, 34, 200, 40, 40)
    txt2:setPos(startPos)
    startPos = txt2:getSize() + startPos
    self.mTitleView:addChild(txt2)
    local txt3 = new(Text,",请等待对方配置(", width, height, align, fontName, 34, 80, 80, 80)
    txt3:setPos(startPos)
    startPos = txt3:getSize() + startPos
    self.mTitleView:addChild(txt3)
    local txt4 = new(Text,second .. "s", width, height, align, fontName, 34, 25, 115, 45)
    txt4:setPos(startPos)
    startPos = txt4:getSize() + startPos
    self.mTitleView:addChild(txt4)
    local txt5 = new(Text,")", width, height, align, fontName, 34, 80, 80, 80)
    txt5:setPos(startPos)
    startPos = txt5:getSize() + startPos
    self.mTitleView:addChild(txt5)
    self.mTitleView:setSize(startPos)
end

function RoomFriendWaitSetTime:initTimeSetView()
    self.mTimeSetView = {}
    for i=1,3 do
        local index = i
        local message = nil
        if index == 1 then
            message = "快速局，谢谢！"
        elseif index == 2 then
            message = "普通局，谢谢！"
        elseif index == 3 then
            message = "慢速局，谢谢！"
        end
        self.mTimeSetView[i] = self.mBg:getChildByName("time_set_view_"..i)
        self.mTimeSetView[i]:getChildByName("txt_view"):setColor(135,100,95)
        self.mTimeSetView[i]:getChildByName("bg"):setFile("common/background/line_bg_3.png")
        self.mTimeSetView[i]:setEventTouch(self,function(finger_action,x,y,drawing_id_first,drawing_id_current)
            if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
                if message and self.mEdit then
                    self.mEdit:setText(message)
                    self:sendRoomChat()
                end
            end
        end)
    end
    self.mDecTxt = self.mBg:getChildByName("dec_txt")
end

function RoomFriendWaitSetTime:setRoomLevel(level)
    if not level then return end
    local dataInfo = UserInfo.getInstance():getGameTimeInfoByLevel(level)
    local config = RoomConfig.getInstance():getRoomLevelConfig(level)
    if not dataInfo or not config then return end
    self.mDataInfo = dataInfo
    for i=1,3 do
        self.mTimeSetView[i]:getChildByName("txt_view"):getChildByName("gameTime"):setText(self:checkTime(dataInfo.gameTime[i]))
        self.mTimeSetView[i]:getChildByName("txt_view"):getChildByName("stepTime"):setText(self:checkTime(dataInfo.stepTime[i]))
        self.mTimeSetView[i]:getChildByName("txt_view"):getChildByName("secondTime"):setText(self:checkTime(dataInfo.secondTime[i],"不读秒"))
    end

    self.mDecTxt:setText( string.format("底注%d金币,台费%d金币",config.money or 0,config.rent or 0))
end

function RoomFriendWaitSetTime:initChatView()
    
    self.mEditBg = self.mBg:getChildByName("chat_menu"):getChildByName("edit_bg")
    self.mEdit = self.mEditBg:getChildByName("edit")
    self.mEdit:setHintText("点击输入聊天内容",165,145,125)
    self.mEdit:setOnTextChange(self,self.sendRoomChat)
    self.mBookBg = self.mBg:getChildByName("chat_menu"):getChildByName("book_bg")
    self.mChatBookBtn = self.mBg:getChildByName("chat_menu"):getChildByName("chat_book_btn")
    self.mChatBookBtn:setOnClick(self,function()
        self.mBookBg:setVisible(not self.mBookBg:getVisible())
    end)
    self.mBookBg:getChildByName("dismiss_view"):setEventTouch(self,function()
        self.mBookBg:setVisible(false)
    end)
    self.mBookBg:setVisible(false)
    self.mChatBookView = self.mBookBg:getChildByName("book_group")
    self.mChatBookView.m_autoPositionChildren = true; -- 设置添加孩子的方式
    --房间内常用语
	self.m_phrases = {
        "快速局，谢谢！",
        "普通局，谢谢！",
        "慢速局，谢谢！",
        "随意吧！",
        "快点吧，我等得花儿都要谢了！",
       }
    self.mPhrasesBtns = {};
    for i,v in ipairs(self.m_phrases) do
        self.mPhrasesBtns[i] = new(RoomFriendWaitSetTimeChatPhrasesItem,v);
        self.mPhrasesBtns[i]:setClickEvent(self,self.onPhrasesItemClick);
        self.mChatBookView:addChild(self.mPhrasesBtns[i]);
    end
end

function RoomFriendWaitSetTime:setRoom(room)
    self.mRoom = room
end

RoomFriendWaitSetTime.onPhrasesItemClick = function(self,item)
    self.mBookBg:setVisible(false)
	local message = GameString.convert2UTF8(item:getText())
    self.mEdit:setText(message)
    self:sendRoomChat()
end

RoomFriendWaitSetTime.sendRoomChat = function(self)
	local message = GameString.convert2UTF8(self.mEdit:getText())

	if not message or message == "" or message == "" then
        ChessToastManager.getInstance():showSingle("消息不能为空！",800)
		return
	end
    
    local lens = string.lenutf8(GameString.convert2UTF8(message) or "")
    if lens > 60 then--限制60字
        ChessToastManager.getInstance():showSingle("消息不能超过60字！",800);
		return       
    end
    self.mEdit:setText()
    if self.mRoom and self.mRoom.sendChat then
	    self.mRoom:sendChat(1,message)
    end
end

RoomFriendWaitSetTime.show = function(self,level,time_out)
    self.super.show(self,self.mDialogAnim.showAnim)
    time_out = tonumber(time_out)
    if not time_out or (time_out == 0 or time_out < 0 )then
        time_out = 30;
    end
    self:setRoomLevel(level)
    self.m_time_out = time_out + os.time();
    self:updateTitleView(self.m_time_out - os.time())
    self.timeOutAnim = new(AnimInt,kAnimRepeat,0,1,1000,-1);
    self.timeOutAnim:setEvent(self,self.onAnimTime);
end

RoomFriendWaitSetTime.onAnimTime = function(self)
    if self.m_time_out and self.m_time_out > os.time() then
        self:updateTitleView(self.m_time_out - os.time())
    else
        self:dismiss()
        if self.timeOutAnim then
            delete(self.timeOutAnim);
            self.timeOutAnim = nil;
        end
    end
end

RoomFriendWaitSetTime.dismiss = function(self)
    if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
end

RoomFriendWaitSetTime.dtor = function(self)
    if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
    self.mDialogAnim.stopAnim()
end

RoomFriendWaitSetTime.onShowUpUserInfoFunc = function(self,obj,func)
    self.m_showUpUserInfoFunc = func;
    self.m_showUpUserInfoObj = obj;
end

RoomFriendWaitSetTime.onShowUpUserInfoBtnClick = function(self,finger_action, x, y)
    if self.m_showUpUserInfoFunc and self.m_showUpUserInfoObj then
        self.m_showUpUserInfoFunc(self.m_showUpUserInfoObj,finger_action, x, y);
    end
end

RoomFriendWaitSetTime.checkTime = function(self,time,text0)
    if time and time < 60 and time > 0 then
        return time .. "秒";
    elseif time and time >= 60 then
        return time/60 .. "分"
    elseif time and time <= 0 then
        return text0 or "不限时"
    end
end


RoomFriendWaitSetTimeChatPhrasesItem = class(Node);

RoomFriendWaitSetTimeChatPhrasesItem.ctor = function(self,str)
--	local text_x = 0;
--    super(self, "drawable/blank.png");
    local w,h = 615,65;
	print_string("RoomFriendWaitSetTimeChatPhrasesItem.ctor str = " .. str);

    self.m_bg_btn = new(Button,"drawable/blank.png","drawable/blank_press.png");
    self.m_bg_btn:setAlign(kAlignCenter);
    self.m_bg_btn:setSize(w,h);
    self:addChild(self.m_bg_btn);
	self.m_text = new(Text,str,nil,nil,nil,nil,32,255,250,215);
	self.m_text:setPos(10,0);
    self.m_text:setAlign(kAlignLeft);
	self.m_line = new(Image,"common/decoration/line_9.png");
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


RoomFriendWaitSetTimeChatPhrasesItem.getText = function(self)
	return self.m_text:getText();
end

RoomFriendWaitSetTimeChatPhrasesItem.onItemClick = function(self)
    if self.m_click_event and self.m_click_event.func then
        self.m_click_event.func(self.m_click_event.obj,self);
    end
end

RoomFriendWaitSetTimeChatPhrasesItem.setClickEvent = function(self,obj,func)
    self.m_click_event = {};
    self.m_click_event.obj = obj;
    self.m_click_event.func = func;
end

RoomFriendWaitSetTimeChatPhrasesItem.dtor = function(self)
	
end	