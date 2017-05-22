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
	[RoomFriendSetTimeShow.s_controls.gameTime] = {"bg","gametime_bg","game_time_text"};
    [RoomFriendSetTimeShow.s_controls.stepTime] = {"bg","steptime_bg","step_time_text"};
    [RoomFriendSetTimeShow.s_controls.secondTime] = {"bg","secondtime_bg","second_time_text"};
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

    self.sure_text = self:findViewById(self.m_ctrls.sure_text);
    self.sure_text_anim = self:findViewById(self.m_ctrls.sure_text_anim);
    self:setNeedBackEvent(false);
end

RoomFriendSetTimeShow.show = function(self,data)
    if not data then
        return;
    end
    self.m_data = data;
    self:setVisible(true);
    self.super.show(self);
	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
    if data then
        local game_appendString = "";
        local step_appendString = "";
        local second_appendString = "秒";
        if data.round_time < 60 then
            game_appendString = "秒";
        elseif data.round_time < 3600 then
            data.round_time = data.round_time/60;
            game_appendString = "分钟";
        else
            data.round_time = data.round_time/3600;
            game_appendString = "小时";
        end
        if data.step_time < 60 then
            step_appendString = "秒";
        elseif data.step_time < 3600 then
            data.step_time = data.step_time/60;
            step_appendString = "分钟";
        else
            data.step_time = data.step_time/3600;
            step_appendString = "小时";
        end
        self.m_gameTime:setText(data.round_time .. game_appendString);
        self.m_stepTime:setText(data.step_time .. step_appendString);
        self.m_secondTime:setText(data.sec_time .. second_appendString);

        if data.time_out and (data.time_out == 0 or data.time_out < 0 )then
            data.time_out = 30;
        end
        self.m_time_out = data.time_out;
        self.sure_text:setVisible(false);
        self.sure_text_anim:setText("同意("..self.m_time_out.."s)");
        self.sure_text_anim:setVisible(true);
--        self.m_gameTime:setText(data.round_time/60 .. "分钟");
--        self.m_stepTime:setText(data.step_time/60 .. "分钟");
--        self.m_secondTime:setText(data.sec_time/60 .. "秒");
    end
    self.timeOutAnim = new(AnimInt,kAnimRepeat,0,1,1000,-1);
    self.timeOutAnim:setEvent(self,self.onAnimTime);
end

RoomFriendSetTimeShow.onAnimTime = function(self)
    if self.m_time_out and self.m_time_out > 0 then
        self.m_time_out = self.m_time_out -1;
        self.sure_text_anim:setText("同意("..self.m_time_out.."s)");
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
--    self:setVisible(false);
    self.super.dismiss(self);
end

RoomFriendSetTimeShow.dtor = function(self)
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
        UserInfo.getInstance():setLastGameTime(self.m_data);
        self.m_sureFunc(self.m_sureObj,self.m_data);
    end
end

RoomFriendSetTimeShow.onCancleBtnClick = function(self)
    self:dismiss();
    if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
    if self.m_cancleFunc and self.m_cancleObj then
        self.m_cancleFunc(self.m_cancleObj);
    end
end

--endregion
