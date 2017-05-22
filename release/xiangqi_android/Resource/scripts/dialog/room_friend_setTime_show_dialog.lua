--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require(VIEW_PATH .. "room_friend_setTime_show_view");
require(BASE_PATH.."chessDialogScene")
require("ui/scrollViewEx");

RoomFriendSetTimeShow = class(ChessDialogScene,false)

RoomFriendSetTimeShow.s_controls = 
{
    suceBtn = 1;
    cancleBtn = 2;
    gameTime = 3;
    stepTime = 4;
    secondTime = 5;
    sure_text = 6;
    sure_text_anim = 7;
};

RoomFriendSetTimeShow.s_controlConfig = 
{
	[RoomFriendSetTimeShow.s_controls.suceBtn] = {"bg","sure_btn"};
	[RoomFriendSetTimeShow.s_controls.cancleBtn] = {"bg","cancle_btn"};
	[RoomFriendSetTimeShow.s_controls.gameTime] = {"bg","time_set_view_1","txt_view","gameTime"};
    [RoomFriendSetTimeShow.s_controls.stepTime] = {"bg","time_set_view_1","txt_view","stepTime"};
    [RoomFriendSetTimeShow.s_controls.secondTime] = {"bg","time_set_view_1","txt_view","secondTime"};
    [RoomFriendSetTimeShow.s_controls.sure_text] = {"bg","sure_btn","sure_text"};
    [RoomFriendSetTimeShow.s_controls.sure_text_anim] = {"bg","sure_btn","sure_text_anim"};
};

RoomFriendSetTimeShow.ctor = function(self)
    super(self,room_friend_setTime_show_view);
    self.m_ctrls = RoomFriendSetTimeShow.s_controls;
    self.m_suceBtn = self:findViewById(self.m_ctrls.suceBtn);
    self.m_suceBtn:setOnClick(self,self.onSureBtnClick);
    self.m_cancleBtn = self:findViewById(self.m_ctrls.cancleBtn);
    self.m_cancleBtn:setOnClick(self,self.onCancleBtnClick);

    self.m_gameTime = self:findViewById(self.m_ctrls.gameTime);
    self.m_stepTime = self:findViewById(self.m_ctrls.stepTime);
    self.m_secondTime = self:findViewById(self.m_ctrls.secondTime);
    self.m_timeSetName = self.m_root:getChildByName("bg"):getChildByName("time_set_view_1"):getChildByName("txt_view"):getChildByName("name")

    self.m_root:getChildByName("bg"):getChildByName("time_set_view_1"):getChildByName("txt_view"):setColor(215,75,45)
    self.m_root:getChildByName("bg"):getChildByName("time_set_view_1"):getChildByName("bg"):setFile("common/background/line_bg_1.png")

    self.sure_text = self:findViewById(self.m_ctrls.sure_text);
    self.sure_text_anim = self:findViewById(self.m_ctrls.sure_text_anim);

    self.mShowUpUserInfoBtn = self.m_root:getChildByName("show_up_userinfo_btn")
    self.mShowUpUserInfoBtn:setEventTouch(self,self.onShowUpUserInfoBtnClick)
    self:setLevel(-1)

    self:setNeedBackEvent(false);
    self:setNeedMask(false)
    self.mDialogAnim = AnimDialogFactory.createMoveUpAnim(self)
end

RoomFriendSetTimeShow.show = function(self,data,roomLevel)
    if not data then
        return;
    end
    self.super.show(self,self.mDialogAnim.showAnim);
    self.mData = data
    if data then
        
        self.m_gameTime:setText(self:checkTime(data.round_time));
        self.m_stepTime:setText(self:checkTime(data.step_time));
        self.m_secondTime:setText(self:checkTime(data.sec_time,"不读秒"));

        local dataInfo = UserInfo.getInstance():getGameTimeInfoByLevel(roomLevel)
        local selectIndex = nil
        if dataInfo then
            for i=1,3 do
                if dataInfo.gameTime[i] == data.round_time and 
                    dataInfo.stepTime[i] == data.step_time and
                    dataInfo.secondTime[i] == data.sec_time then
                    selectIndex = i
                    break
                end
            end
        end
        if selectIndex == 1 then
            self.m_timeSetName:setText("快速局")
        elseif selectIndex == 2 then
            self.m_timeSetName:setText("普通局")
        elseif selectIndex == 3 then
            self.m_timeSetName:setText("慢速局")
        else
            self.m_timeSetName:setText("无")
        end
        if not data.time_out or (data.time_out == 0 or data.time_out < 0 )then
            data.time_out = 30;
        end
        self.m_time_out = data.time_out + os.time();
        self.sure_text:setVisible(false);
        self.sure_text_anim:setText("开始("..(self.m_time_out - os.time()).."s)");
        self.sure_text_anim:setVisible(true);
    end
    self.timeOutAnim = new(AnimInt,kAnimRepeat,0,1,1000,-1);
    self.timeOutAnim:setEvent(self,self.onAnimTime);
end

RoomFriendSetTimeShow.checkTime = function(self,time,text0)
    if time and time < 60 and time > 0 then
        return time .. "秒";
    elseif time and time >= 60 then
        return time/60 .. "分"
    elseif time and time <= 0 then
        return text0 or "不限时"
    end
end

RoomFriendSetTimeShow.onAnimTime = function(self)
    if self.m_time_out and self.m_time_out > os.time() then
        self.sure_text_anim:setText("开始("..(self.m_time_out - os.time()).."s)");
    else
        if self.timeOutAnim then
            delete(self.timeOutAnim);
            self.timeOutAnim = nil;
            self:onSureBtnClick();
        end
    end
end

RoomFriendSetTimeShow.dismiss = function(self,flag)
    if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
end

RoomFriendSetTimeShow.dtor = function(self)
    self.mDialogAnim.stopAnim()
	if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
end

RoomFriendSetTimeShow.onSureFunc = function(self,obj,func)
    self.m_sureFunc = func;
    self.m_sureObj = obj;
end

RoomFriendSetTimeShow.onCancleFunc = function(self,obj,func)
    self.m_cancleFunc = func;
    self.m_cancleObj = obj;
end

RoomFriendSetTimeShow.onSureBtnClick = function(self)
    self:dismiss();
    if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
    if self.m_sureFunc and self.m_sureObj then
        self.m_sureFunc(self.m_sureObj,self.mData);
    end
end

RoomFriendSetTimeShow.onCancleBtnClick = function(self)
    self:dismiss();
    if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
    if self.m_cancleFunc and self.m_cancleObj then
        self.m_cancleFunc(self.m_cancleObj,self.mData);
    end
end

RoomFriendSetTimeShow.onShowUpUserInfoFunc = function(self,obj,func)
    self.m_showUpUserInfoFunc = func;
    self.m_showUpUserInfoObj = obj;
end
RoomFriendSetTimeShow.onShowUpUserInfoBtnClick = function(self,finger_action, x, y)
    if self.m_showUpUserInfoFunc and self.m_showUpUserInfoObj then
        self.m_showUpUserInfoFunc(self.m_showUpUserInfoObj,finger_action, x, y);
    end
end

--endregion
