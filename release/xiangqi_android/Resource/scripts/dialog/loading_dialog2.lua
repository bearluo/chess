--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require(VIEW_PATH .. "room_friend_wait_setTime_show_view");
require(BASE_PATH.."chessDialogScene")
require("ui/scrollViewEx");

LoadingDialog2 = class(ChessDialogScene,false)

LoadingDialog2.ctor = function(self)
    super(self,room_friend_wait_setTime_show_view)
    self.mBg = self.m_root:getChildByName("bg")
    self.mTitleView = self.mBg:getChildByName("title_view")
    self.mMessage = ""
    self:updateTitleView()
    self:initChatView()
    self:setNeedBackEvent(false)
    self:setNeedMask(false)
    self.mDialogAnim = AnimDialogFactory.createMoveUpAnim(self)
end

function LoadingDialog2:updateTitleView(second)
    second = tonumber(second) or 0
    self.mTitleView:removeAllChildren()
    local startPos = 0
    local txt1 = new(Text,self.mMessage .. "(", width, height, align, fontName, 36, 240, 230, 210)
    txt1:setPos(startPos)
    startPos = txt1:getSize() + startPos
    self.mTitleView:addChild(txt1)
    local txt2 = new(Text,second .. "s", width, height, align, fontName, 36, 40, 200, 65)
    txt2:setPos(startPos)
    startPos = txt2:getSize() + startPos
    self.mTitleView:addChild(txt2)
    local txt3 = new(Text,")", width, height, align, fontName, 36, 240, 230, 210)
    txt3:setPos(startPos)
    startPos = txt3:getSize() + startPos
    self.mTitleView:addChild(txt3)
    self.mTitleView:setSize(startPos)
end

function LoadingDialog2:initChatView()
    
    self.mEditBg = self.mBg:getChildByName("edit_bg")
    self.mEdit = self.mEditBg:getChildByName("edit")
    self.mEdit:setHintText("点击输入聊天内容",165,145,125)
    self.mEdit:setOnTextChange(self,self.sendRoomChat)
    self.mBookBg = self.mBg:getChildByName("book_bg")
    self.mChatBookBtn = self.mBg:getChildByName("chat_book_btn")
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
	local phrases = {
        "快速局，谢谢！",
        "普通局，谢谢！",
        "慢速局，谢谢！",
        "随意吧！",
        "快点吧，我等得花儿都要谢了！",
       }
    self:setPhrases(phrases)
end

function LoadingDialog2:setPhrases(phrases)
    self.mChatBookView:removeAllChildren()
    self.mPhrasesBtns = {};
    for i,v in ipairs(phrases) do
        self.mPhrasesBtns[i] = new(LoadingDialog2ChatPhrasesItem,v);
        self.mPhrasesBtns[i]:setClickEvent(self,self.onPhrasesItemClick);
        self.mChatBookView:addChild(self.mPhrasesBtns[i]);
    end
end

function LoadingDialog2:setRoom(room)
    self.mRoom = room
end

LoadingDialog2.onPhrasesItemClick = function(self,item)
    self.mBookBg:setVisible(false)
	local message = GameString.convert2UTF8(item:getText())
    self.mEdit:setText(message)
    self:sendRoomChat()
end

LoadingDialog2.sendRoomChat = function(self)
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

LoadingDialog2.show = function(self,time_out)
    self.super.show(self,self.mDialogAnim.showAnim)
    time_out = tonumber(time_out)
    if not time_out or (time_out == 0 or time_out < 0 )then
        time_out = 30;
    end
    self.m_time_out = time_out + os.time();
    self:updateTitleView(self.m_time_out - os.time())
    self.timeOutAnim = new(AnimInt,kAnimRepeat,0,1,1000,-1);
    self.timeOutAnim:setEvent(self,self.onAnimTime);
end

LoadingDialog2.setMessage = function(self,message)
    self.mMessage = message or ""
    if self.m_time_out then
        self:updateTitleView(self.m_time_out - os.time())
    end
end

LoadingDialog2.onAnimTime = function(self)
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

LoadingDialog2.dismiss = function(self)
    if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
end

LoadingDialog2.dtor = function(self)
    if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
    self.mDialogAnim.stopAnim()
end

LoadingDialog2.checkTime = function(self,time,text0)
    if time and time < 60 and time > 0 then
        return time .. "秒";
    elseif time and time >= 60 then
        return time/60 .. "分"
    elseif time and time <= 0 then
        return text0 or "不限时"
    end
end


LoadingDialog2ChatPhrasesItem = class(Node);

LoadingDialog2ChatPhrasesItem.ctor = function(self,str)
--	local text_x = 0;
--    super(self, "drawable/blank.png");
    local w,h = 615,65;
	print_string("LoadingDialog2ChatPhrasesItem.ctor str = " .. str);

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


LoadingDialog2ChatPhrasesItem.getText = function(self)
	return self.m_text:getText();
end

LoadingDialog2ChatPhrasesItem.onItemClick = function(self)
    if self.m_click_event and self.m_click_event.func then
        self.m_click_event.func(self.m_click_event.obj,self);
    end
end

LoadingDialog2ChatPhrasesItem.setClickEvent = function(self,obj,func)
    self.m_click_event = {};
    self.m_click_event.obj = obj;
    self.m_click_event.func = func;
end

LoadingDialog2ChatPhrasesItem.dtor = function(self)
	
end	