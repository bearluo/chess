--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require(VIEW_PATH .. "room_friend_setTime_view");
require(BASE_PATH.."chessDialogScene")
require("ui/scrollViewEx");

RoomFriendSetTime = class(ChessDialogScene,false)

RoomFriendSetTime.ctor = function(self)
    super(self,room_friend_setTime_view)
    self.mBg = self.m_root:getChildByName("bg")
    self:initTitleView()
    self:initTimeSetView()
    self:initLeftSelectView()
    self.mSureBtn = self.mBg:getChildByName("sure_btn")
    self.mCancleBtn = self.mBg:getChildByName("cancle_btn")
    self.mShowUpUserInfoBtn = self.m_root:getChildByName("show_up_userinfo_btn")
    self.mSureBtn:setOnClick(self,self.onSureBtnClick)
    self.mCancleBtn:setOnClick(self,self.onCancleBtnClick)
    self.mShowUpUserInfoBtn:setEventTouch(self,self.onShowUpUserInfoBtnClick)
    self:setNeedBackEvent(false)
    self:setNeedMask(false)
    self:setLevel(-1)
    self.mDialogAnim = AnimDialogFactory.createMoveUpAnim(self)
end

function RoomFriendSetTime:initTitleView()
    self.mTitleView = self.mBg:getChildByName("title_view")
    local startPos = 0
    local txt1 = new(Text,"配对成功,您", width, height, align, fontName, 34, 80, 80, 80)
    txt1:setPos(startPos)
    startPos = txt1:getSize() + startPos
    self.mTitleView:addChild(txt1)
    local txt2 = new(Text,"执红", width, height, align, fontName, 34, 200, 40, 40)
    txt2:setPos(startPos)
    startPos = txt2:getSize() + startPos
    self.mTitleView:addChild(txt2)
    local txt3 = new(Text,",请确认棋局配置方案", width, height, align, fontName, 34, 80, 80, 80)
    txt3:setPos(startPos)
    startPos = txt3:getSize() + startPos
    self.mTitleView:addChild(txt3)
    self.mTitleView:setSize(startPos)
end

function RoomFriendSetTime:initTimeSetView()
    self.mTimeSetView = {}
    for i=1,3 do
        local index = i
        self.mTimeSetView[i] = self.mBg:getChildByName("time_set_view_"..i)
        self.mTimeSetView[i]:setEventTouch(self,function()
            self:selectTimeSetView(index)
        end)
    end
    self.mDecTxt = self.mBg:getChildByName("dec_txt")
end

function RoomFriendSetTime:initLeftSelectView()
    self.mSelectView = self.mBg:getChildByName("select_view")
    self.mSelectView:getChildByName("select_icon"):setEventDrag(self,self.onSelectIconDrag)
    for i=1,3 do
        local index = i
        self.mSelectView:getChildByName("select_btn_"..i):setOnClick(self,function()
            self:selectTimeSetView(index)
        end)
    end
end



function RoomFriendSetTime:selectTimeSetView(index)
    if index < 0 or index > 3 then return end
    self.mCurSelectIndex = index
    for i=1,3 do
        self.mTimeSetView[i]:getChildByName("txt_view"):setColor(135,100,95)
        self.mTimeSetView[i]:getChildByName("bg"):setFile("common/background/line_bg_3.png")
    end
    self.mTimeSetView[index]:getChildByName("txt_view"):setColor(215,75,45)
    self.mTimeSetView[index]:getChildByName("bg"):setFile("common/background/line_bg_1.png")
    if index == 1 then
        self.mSelectView:getChildByName("select_icon"):setPos(nil,0)
    elseif index == 2 then
        self.mSelectView:getChildByName("select_icon"):setPos(nil,125)
    elseif index == 3 then
        self.mSelectView:getChildByName("select_icon"):setPos(nil,250)
    end
end

function RoomFriendSetTime:setRoomLevel(level)
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
    -- 推荐选择
    local data = UserInfo.getInstance():getGameTimeByLevel(level)
    -- 历史选择
    data = UserInfo.getInstance():getLastGameTimeByLevel(level) or data
    local selectIndex = 2
    -- 兼容老版本局时设置配置
    if data then
        for i=1,3 do
            if dataInfo.gameTime[i] == data.gameTime and 
                dataInfo.stepTime[i] == data.stepTime and
                dataInfo.secondTime[i] == data.secondTime then
                selectIndex = i
                break
            end
        end
    end
    self:selectTimeSetView(selectIndex)
end

RoomFriendSetTime.show = function(self,level,time_out)
    self.super.show(self,self.mDialogAnim.showAnim)
    time_out = tonumber(time_out)
    if not time_out or (time_out == 0 or time_out < 0 )then
        time_out = 30;
    end
    self:setRoomLevel(level)
    self.m_time_out = time_out + os.time();
    self.mSureBtn:getChildByName("sure_text"):setVisible(false);
    self.mSureBtn:getChildByName("sure_text_anim"):setText("确认("..(self.m_time_out - os.time()).."s)");
    self.mSureBtn:getChildByName("sure_text_anim"):setVisible(true);
    self.timeOutAnim = new(AnimInt,kAnimRepeat,0,1,1000,-1);
    self.timeOutAnim:setEvent(self,self.onAnimTime);
end

RoomFriendSetTime.onAnimTime = function(self)
    if self.m_time_out and self.m_time_out > os.time() then
        self.mSureBtn:getChildByName("sure_text_anim"):setText("确认("..(self.m_time_out - os.time()).."s)");
    else
        if self.timeOutAnim then
            delete(self.timeOutAnim);
            self.timeOutAnim = nil;
            self:onSureBtnClick();
        end
    end
end

RoomFriendSetTime.dismiss = function(self)
    if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
end

RoomFriendSetTime.dtor = function(self)
    if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
    self.mDialogAnim.stopAnim()
end

RoomFriendSetTime.onSureFunc = function(self,obj,func)
    self.m_sureFunc = func;
    self.m_sureObj = obj;
end

RoomFriendSetTime.onCancleFunc = function(self,obj,func)
    self.m_cancleFunc = func;
    self.m_cancleObj = obj;
end

RoomFriendSetTime.onShowUpUserInfoFunc = function(self,obj,func)
    self.m_showUpUserInfoFunc = func;
    self.m_showUpUserInfoObj = obj;
end

RoomFriendSetTime.onSureBtnClick = function(self)
    self:dismiss();
    if self.m_sureFunc and self.m_sureObj then
        if not self.mCurSelectIndex then return end
        local data = {}
        data.gameTime = self.mDataInfo.gameTime[self.mCurSelectIndex]
        data.stepTime = self.mDataInfo.stepTime[self.mCurSelectIndex]
        data.secondTime = self.mDataInfo.secondTime[self.mCurSelectIndex]
        UserInfo.getInstance():setLastGameTime(data)
        self.m_sureFunc(self.m_sureObj,data)
    end
end

RoomFriendSetTime.onCancleBtnClick = function(self)
    self:dismiss();
    if self.m_cancleFunc and self.m_cancleObj then
        self.m_cancleFunc(self.m_cancleObj);
    end
end

RoomFriendSetTime.onShowUpUserInfoBtnClick = function(self,finger_action, x, y)
    if self.m_showUpUserInfoFunc and self.m_showUpUserInfoObj then
        self.m_showUpUserInfoFunc(self.m_showUpUserInfoObj,finger_action, x, y);
    end
end

RoomFriendSetTime.checkTime = function(self,time,text0)
    if time and time < 60 and time > 0 then
        return time .. "秒";
    elseif time and time >= 60 then
        return time/60 .. "分"
    elseif time and time <= 0 then
        return text0 or "不限时"
    end
end

function RoomFriendSetTime:onSelectIconDrag(finger_action, x, y, drawing_id_first, drawing_id_current, event_time)
    if finger_action == kFingerDown then
        self.mFingerDowning = true
        self.mMoveY = y
    elseif finger_action == kFingerMove then
        if self.mFingerDowning then
            local offset = y - self.mMoveY
            self.mMoveY = y
            local mx,my = self.mSelectView:getChildByName("select_icon"):getPos()
            local tmpY = my+offset
            if tmpY < 0 then tmpY = 0 end
            if tmpY > 250 then tmpY = 250 end
            if tmpY < 63 then
                self:selectTimeSetView(1)
            elseif tmpY < 188 then
                self:selectTimeSetView(2)
            else
                self:selectTimeSetView(3)
            end
            self.mSelectView:getChildByName("select_icon"):setPos(nil,tmpY)
        end
    else
        if self.mFingerDowning then
            self.mFingerDowning = false
            local offset = y - self.mMoveY
            self.mMoveY = y
            local mx,my = self.mSelectView:getChildByName("select_icon"):getPos()
            local tmpY = my+offset
            if tmpY < 0 then tmpY = 0 end
            if tmpY > 250 then tmpY = 250 end
            if tmpY < 63 then
                self:selectTimeSetView(1)
            elseif tmpY < 188 then
                self:selectTimeSetView(2)
            else
                self:selectTimeSetView(3)
            end
        end
    end
end