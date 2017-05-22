--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require(VIEW_PATH .. "room_friend_setTime_view");
require(BASE_PATH.."chessDialogScene")
require("ui/scrollViewEx");

RoomFriendSetTime = class(ChessDialogScene,false)
--局时：（-25L，95L，195L，300L）
--步时：（-25L，95L，195L，300L）
--读秒：（-25L，140，300L）
RoomFriendSetTime.baseTime = 200;--值越小，滑动速度越快

RoomFriendSetTime.gameTimePos = {
    {gameTime = 600; pos = -50;},
    {gameTime = 1200; pos = 123;},
    {gameTime = 1800; pos = 295;},
    {gameTime = 3600; pos = 457;},
};

RoomFriendSetTime.stepTimePos = {
    {stepTime = 30; pos = -50;};
    {stepTime = 60; pos = 123;};
    {stepTime = 120; pos = 295;};
    {stepTime = 180; pos = 457;};
};

RoomFriendSetTime.secondTimePos = {
    {secondTime = 0; pos = -50;};
    {secondTime = 30; pos = 203;};
    {secondTime = 60; pos = 457;};
};

RoomFriendSetTime.s_controls = 
{
    suceBtn = 1;
    cancleBtn = 2;
    gameSliderTime1 = 3;
    gameSliderTime2 = 4;
    gameSliderTime3 = 5;
    gameSliderTime4 = 6;
    gameChoiceIcon = 7;
    stepSliderTime1 = 8;
    stepSliderTime2 = 9;
    stepSliderTime3 = 10;
    stepSliderTime4 = 11;
    stepChoiceIcon = 12;
    secondSliderTime1 = 13;
    secondSliderTime2 = 14;
    secondSliderTime3 = 15;
    secondChoiceIcon = 16;

    sure_text = 17;
    sure_text_anim = 18;

    gameTimeText1 = 19;
    gameTimeText2 = 20;
    gameTimeText3 = 21;
    gameTimeText4 = 22;
    stepTimeText1 = 23;
    stepTimeText2 = 24;
    stepTimeText3 = 25;
    stepTimeText4 = 26;
    secondTimeText1 = 27;
    secondTimeText2 = 28;
    secondTimeText3 = 29;
};

RoomFriendSetTime.s_controlConfig = 
{
	[RoomFriendSetTime.s_controls.suceBtn] = {"bg","sure_btn"};
	[RoomFriendSetTime.s_controls.cancleBtn] = {"bg","cancle_btn"};
	[RoomFriendSetTime.s_controls.gameSliderTime1] = {"bg","game_time_view","slider_view","View1","btn_1"};
    [RoomFriendSetTime.s_controls.gameSliderTime2] = {"bg","game_time_view","slider_view","View2","btn_2"};
    [RoomFriendSetTime.s_controls.gameSliderTime3] = {"bg","game_time_view","slider_view","View3","btn_3"};
    [RoomFriendSetTime.s_controls.gameSliderTime4] = {"bg","game_time_view","slider_view","View4","btn_4"};
    [RoomFriendSetTime.s_controls.gameChoiceIcon] = {"bg","game_time_view","slider_view","choiceIcon"};
    [RoomFriendSetTime.s_controls.stepSliderTime1] = {"bg","step_time_view","slider_view","View1","btn_1"};
    [RoomFriendSetTime.s_controls.stepSliderTime2] = {"bg","step_time_view","slider_view","View2","btn_2"};
    [RoomFriendSetTime.s_controls.stepSliderTime3] = {"bg","step_time_view","slider_view","View3","btn_3"};
    [RoomFriendSetTime.s_controls.stepSliderTime4] = {"bg","step_time_view","slider_view","View4","btn_4"};
    [RoomFriendSetTime.s_controls.stepChoiceIcon] = {"bg","step_time_view","slider_view","choiceIcon"};
    [RoomFriendSetTime.s_controls.secondSliderTime1] = {"bg","second_time_view","slider_view","View1","btn_1"};
    [RoomFriendSetTime.s_controls.secondSliderTime2] = {"bg","second_time_view","slider_view","View2","btn_2"};
    [RoomFriendSetTime.s_controls.secondSliderTime3] = {"bg","second_time_view","slider_view","View3","btn_3"};
    [RoomFriendSetTime.s_controls.secondChoiceIcon] = {"bg","second_time_view","slider_view","choiceIcon"};
    [RoomFriendSetTime.s_controls.sure_text] = {"bg","sure_btn","sure_text"};
    [RoomFriendSetTime.s_controls.sure_text_anim] = {"bg","sure_btn","sure_text_anim"};

    [RoomFriendSetTime.s_controls.gameTimeText1] = {"bg","game_time_view","slider_view","View1","time_text1"};
    [RoomFriendSetTime.s_controls.gameTimeText2] = {"bg","game_time_view","slider_view","View2","time_text2"};
    [RoomFriendSetTime.s_controls.gameTimeText3] = {"bg","game_time_view","slider_view","View3","time_text3"};
    [RoomFriendSetTime.s_controls.gameTimeText4] = {"bg","game_time_view","slider_view","View4","time_text4"};

    [RoomFriendSetTime.s_controls.stepTimeText1] = {"bg","step_time_view","slider_view","View1","time_text1"};
    [RoomFriendSetTime.s_controls.stepTimeText2] = {"bg","step_time_view","slider_view","View2","time_text2"};
    [RoomFriendSetTime.s_controls.stepTimeText3] = {"bg","step_time_view","slider_view","View3","time_text3"};
    [RoomFriendSetTime.s_controls.stepTimeText4] = {"bg","step_time_view","slider_view","View4","time_text4"};

    [RoomFriendSetTime.s_controls.secondTimeText1] = {"bg","second_time_view","slider_view","View1","time_text1"};
    [RoomFriendSetTime.s_controls.secondTimeText2] = {"bg","second_time_view","slider_view","View2","time_text2"};
    [RoomFriendSetTime.s_controls.secondTimeText3] = {"bg","second_time_view","slider_view","View3","time_text3"};
};

RoomFriendSetTime.ctor = function(self,level)
    super(self,room_friend_setTime_view);
    self.m_ctrls = RoomFriendSetTime.s_controls;
    self.m_dataInfo = UserInfo.getInstance():getGameTimeInfoByLevel(level or 0);
    self.m_level = level;
    self.m_suceBtn = self:findViewById(self.m_ctrls.suceBtn);
    self.m_suceBtn:setOnClick(self,self.onSureBtnClick);
    self.m_cancleBtn = self:findViewById(self.m_ctrls.cancleBtn);
    self.m_cancleBtn:setOnClick(self,self.onCancleBtnClick);

    self.m_gameSliderTime1 = self:findViewById(self.m_ctrls.gameSliderTime1);
    self.m_gameSliderTime2 = self:findViewById(self.m_ctrls.gameSliderTime2);
    self.m_gameSliderTime3 = self:findViewById(self.m_ctrls.gameSliderTime3);
    self.m_gameSliderTime4 = self:findViewById(self.m_ctrls.gameSliderTime4);
    self.m_gameChoiceIcon = self:findViewById(self.m_ctrls.gameChoiceIcon);
    self.m_gameSliderTime1:setOnClick(self,self.onGameTime1Click);
    self.m_gameSliderTime2:setOnClick(self,self.onGameTime2Click);
    self.m_gameSliderTime3:setOnClick(self,self.onGameTime3Click);
    self.m_gameSliderTime4:setOnClick(self,self.onGameTime4Click);

    self.m_stepSliderTime1 = self:findViewById(self.m_ctrls.stepSliderTime1);
    self.m_stepSliderTime2 = self:findViewById(self.m_ctrls.stepSliderTime2);
    self.m_stepSliderTime3 = self:findViewById(self.m_ctrls.stepSliderTime3);
    self.m_stepSliderTime4 = self:findViewById(self.m_ctrls.stepSliderTime4);
    self.m_stepChoiceIcon = self:findViewById(self.m_ctrls.stepChoiceIcon);
    self.m_stepSliderTime1:setOnClick(self,self.onStepTime1Click);
    self.m_stepSliderTime2:setOnClick(self,self.onStepTime2Click);
    self.m_stepSliderTime3:setOnClick(self,self.onStepTime3Click);
    self.m_stepSliderTime4:setOnClick(self,self.onStepTime4Click);

    self.m_secondSliderTime1 = self:findViewById(self.m_ctrls.secondSliderTime1);
    self.m_secondSliderTime2 = self:findViewById(self.m_ctrls.secondSliderTime2);
    self.m_secondSliderTime3 = self:findViewById(self.m_ctrls.secondSliderTime3);
    self.m_secondChoiceIcon = self:findViewById(self.m_ctrls.secondChoiceIcon);
    self.m_secondSliderTime1:setOnClick(self,self.onSecondTime1Click);
    self.m_secondSliderTime2:setOnClick(self,self.onSecondTime2Click);
    self.m_secondSliderTime3:setOnClick(self,self.onSecondTime3Click);

    self.m_gameTimeText1 = self:findViewById(self.m_ctrls.gameTimeText1);
    self.m_gameTimeText2 = self:findViewById(self.m_ctrls.gameTimeText2);
    self.m_gameTimeText3 = self:findViewById(self.m_ctrls.gameTimeText3);
    self.m_gameTimeText4 = self:findViewById(self.m_ctrls.gameTimeText4);
    self.m_stepTimeText1 = self:findViewById(self.m_ctrls.stepTimeText1);
    self.m_stepTimeText2 = self:findViewById(self.m_ctrls.stepTimeText2);
    self.m_stepTimeText3 = self:findViewById(self.m_ctrls.stepTimeText3);
    self.m_stepTimeText4 = self:findViewById(self.m_ctrls.stepTimeText4);
    self.m_secondTimeText1 = self:findViewById(self.m_ctrls.secondTimeText1);
    self.m_secondTimeText2 = self:findViewById(self.m_ctrls.secondTimeText2);
    self.m_secondTimeText3 = self:findViewById(self.m_ctrls.secondTimeText3);

    self.sure_text = self:findViewById(self.m_ctrls.sure_text);
    self.sure_text_anim = self:findViewById(self.m_ctrls.sure_text_anim);
    self:setNeedBackEvent(false);
    self:initData();
end

RoomFriendSetTime.initData = function(self)
    if self.m_dataInfo then
        self.m_gameTimeText1:setText(self:checkTime(self.m_dataInfo.gameTime[1]));
        RoomFriendSetTime.gameTimePos[1].gameTime = self.m_dataInfo.gameTime[1];
        self.m_gameTimeText2:setText(self:checkTime(self.m_dataInfo.gameTime[2]));
        RoomFriendSetTime.gameTimePos[2].gameTime = self.m_dataInfo.gameTime[2];
        self.m_gameTimeText3:setText(self:checkTime(self.m_dataInfo.gameTime[3]));
        RoomFriendSetTime.gameTimePos[3].gameTime = self.m_dataInfo.gameTime[3];
        self.m_gameTimeText4:setText(self:checkTime(self.m_dataInfo.gameTime[4]));
        RoomFriendSetTime.gameTimePos[4].gameTime = self.m_dataInfo.gameTime[4];
        self.m_stepTimeText1:setText(self:checkTime(self.m_dataInfo.stepTime[1]));
        RoomFriendSetTime.stepTimePos[1].stepTime = self.m_dataInfo.stepTime[1];
        self.m_stepTimeText2:setText(self:checkTime(self.m_dataInfo.stepTime[2]));
        RoomFriendSetTime.stepTimePos[2].stepTime = self.m_dataInfo.stepTime[2];
        self.m_stepTimeText3:setText(self:checkTime(self.m_dataInfo.stepTime[3]));
        RoomFriendSetTime.stepTimePos[3].stepTime = self.m_dataInfo.stepTime[3];
        self.m_stepTimeText4:setText(self:checkTime(self.m_dataInfo.stepTime[4]));
        RoomFriendSetTime.stepTimePos[4].stepTime = self.m_dataInfo.stepTime[4];

        self.m_secondTimeText1:setText(self:checkTime(self.m_dataInfo.secondTime[1],"不读秒"));
        RoomFriendSetTime.secondTimePos[1].secondTime = self.m_dataInfo.secondTime[1];
        self.m_secondTimeText2:setText(self:checkTime(self.m_dataInfo.secondTime[2],"不读秒"));
        RoomFriendSetTime.secondTimePos[2].secondTime = self.m_dataInfo.secondTime[2];
        self.m_secondTimeText3:setText(self:checkTime(self.m_dataInfo.secondTime[3],"不读秒"));
        RoomFriendSetTime.secondTimePos[3].secondTime = self.m_dataInfo.secondTime[3];
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

RoomFriendSetTime.create = function(self)
    self.m_data = UserInfo.getInstance():getLastGameTimeByLevel(self.m_level or 0);
    if not self.m_data then
        self.m_data = UserInfo.getInstance():getGameTimeByLevel(self.m_level or 0);
    end
    if self.m_data then
        if self.m_data.gameTime then        --局时
            for i=1,4 do
                if self.m_data.gameTime == RoomFriendSetTime.gameTimePos[i].gameTime then
                    self.m_gameChoiceIcon:setAlign(kAlignLeft);
                    self.m_gameChoiceIcon:setPos(RoomFriendSetTime.gameTimePos[i].pos);
                    self.m_gameChoice_x = RoomFriendSetTime.gameTimePos[i].pos;
                    break;
                end
            end
        end
        if self.m_data.stepTime then        --步时
            for i=1,4 do
                if self.m_data.stepTime == RoomFriendSetTime.stepTimePos[i].stepTime then
                    self.m_stepChoiceIcon:setAlign(kAlignLeft);
                    self.m_stepChoiceIcon:setPos(RoomFriendSetTime.stepTimePos[i].pos);
                    self.m_stepChoice_x = RoomFriendSetTime.stepTimePos[i].pos;
                    break;
                end
            end
        end
        if self.m_data.secondTime then
            for i=1,3 do
                if self.m_data.secondTime == RoomFriendSetTime.secondTimePos[i].secondTime then
                    self.m_secondChoiceIcon:setAlign(kAlignLeft);
                    self.m_secondChoiceIcon:setPos(RoomFriendSetTime.secondTimePos[i].pos);
                    self.m_secondChoice_x = RoomFriendSetTime.secondTimePos[i].pos;
                    break;
                end
            end
        end
    else
        self.m_data = {};
        self.m_data.gameTime = RoomFriendSetTime.gameTimePos[1].gameTime;
        self.m_data.stepTime = RoomFriendSetTime.stepTimePos[1].stepTime;
        self.m_data.secondTime = RoomFriendSetTime.secondTimePos[1].secondTime;
    end
    self:setVisible(false);
end

RoomFriendSetTime.show = function(self,time_out)
    self:create();
    self:setVisible(true);
    self.super.show(self);
	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
    if time_out and (time_out == 0 or time_out < 0 )then
        time_out = 30;
    end
  
    self.m_time_out = time_out;
    self.sure_text:setVisible(false);
    self.sure_text_anim:setText("确认("..self.m_time_out.."s)");
    self.sure_text_anim:setVisible(true);
    self.timeOutAnim = new(AnimInt,kAnimRepeat,0,1,1000,-1);
    self.timeOutAnim:setEvent(self,self.onAnimTime);
end

RoomFriendSetTime.onAnimTime = function(self)
    if self.m_time_out and self.m_time_out > 0 then
        self.m_time_out = self.m_time_out -1;
        self.sure_text_anim:setText("确认("..self.m_time_out.."s)");
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
--    self:setVisible(false);
    self.super.dismiss(self);
end

RoomFriendSetTime.dtor = function(self)
	if not self.m_gameChoiceIcon:checkAddProp(1) then 
		self.m_gameChoiceIcon:removeProp(1);
	end
    if not self.m_secondChoiceIcon:checkAddProp(1) then 
		self.m_secondChoiceIcon:removeProp(1);
	end
    if not self.m_stepChoiceIcon:checkAddProp(1) then 
		self.m_stepChoiceIcon:removeProp(1);
	end
    if self.timeOutAnim then
        delete(self.timeOutAnim);
        self.timeOutAnim = nil;
    end
end

RoomFriendSetTime.onSureFunc = function(self,obj,func)
    self.m_sureFunc = func;
    self.m_sureObj = obj;
end

RoomFriendSetTime.onCancleFunc = function(self,obj,func)
    self.m_cancleFunc = func;
    self.m_cancleObj = obj;
end

RoomFriendSetTime.onSureBtnClick = function(self)
    self:dismiss();
    if self.m_sureFunc and self.m_sureObj then
        UserInfo.getInstance():setLastGameTime(self.m_data);
        self.m_sureFunc(self.m_sureObj,self.m_data);
    end
end

RoomFriendSetTime.onCancleBtnClick = function(self)
    self:dismiss();
    if self.m_cancleFunc and self.m_cancleObj then
        self.m_cancleFunc(self.m_cancleObj);
    end
end

RoomFriendSetTime.onGameTime1Click = function(self)
    if self.m_data and self.m_data.gameTime ~= RoomFriendSetTime.gameTimePos[1].gameTime then 
        self.m_data.gameTime = RoomFriendSetTime.gameTimePos[1].gameTime;
        self:onGameChoiceIconMove(RoomFriendSetTime.gameTimePos[1].pos);
    end
end

RoomFriendSetTime.onGameTime2Click = function(self)
    if self.m_data and self.m_data.gameTime ~= RoomFriendSetTime.gameTimePos[2].gameTime then 
        self.m_data.gameTime = RoomFriendSetTime.gameTimePos[2].gameTime;
        self:onGameChoiceIconMove(RoomFriendSetTime.gameTimePos[2].pos);
    end
end

RoomFriendSetTime.onGameTime3Click = function(self)
    if self.m_data and self.m_data.gameTime ~= RoomFriendSetTime.gameTimePos[3].gameTime then 
        self.m_data.gameTime = RoomFriendSetTime.gameTimePos[3].gameTime;
        self:onGameChoiceIconMove(RoomFriendSetTime.gameTimePos[3].pos);
    end
end

RoomFriendSetTime.onGameTime4Click = function(self)
    if self.m_data and self.m_data.gameTime ~= RoomFriendSetTime.gameTimePos[4].gameTime then 
        self.m_data.gameTime = RoomFriendSetTime.gameTimePos[4].gameTime;
        self:onGameChoiceIconMove(RoomFriendSetTime.gameTimePos[4].pos);
    end
end

RoomFriendSetTime.onStepTime1Click = function(self)
    if self.m_data and self.m_data.stepTime ~= RoomFriendSetTime.stepTimePos[1].stepTime then 
        self.m_data.stepTime = RoomFriendSetTime.stepTimePos[1].stepTime;
        self:onStepChoiceIconMove(RoomFriendSetTime.stepTimePos[1].pos);
    end
end

RoomFriendSetTime.onStepTime2Click = function(self)
    if self.m_data and self.m_data.stepTime ~= RoomFriendSetTime.stepTimePos[2].stepTime then 
        self.m_data.stepTime = RoomFriendSetTime.stepTimePos[2].stepTime;
        self:onStepChoiceIconMove(RoomFriendSetTime.stepTimePos[2].pos);
    end
end

RoomFriendSetTime.onStepTime3Click = function(self)
    if self.m_data and self.m_data.stepTime ~= RoomFriendSetTime.stepTimePos[3].stepTime then 
        self.m_data.stepTime = RoomFriendSetTime.stepTimePos[3].stepTime;
        self:onStepChoiceIconMove(RoomFriendSetTime.stepTimePos[3].pos);
    end
end

RoomFriendSetTime.onStepTime4Click = function(self)
    if self.m_data and self.m_data.stepTime ~= RoomFriendSetTime.stepTimePos[4].stepTime then 
        self.m_data.stepTime = RoomFriendSetTime.stepTimePos[4].stepTime;
        self:onStepChoiceIconMove(RoomFriendSetTime.stepTimePos[4].pos);
    end
end

RoomFriendSetTime.onSecondTime1Click = function(self)
    if self.m_data and self.m_data.secondTime ~= RoomFriendSetTime.secondTimePos[1].secondTime then 
        self.m_data.secondTime = RoomFriendSetTime.secondTimePos[1].secondTime;
        self:onSecondChoiceIconMove(RoomFriendSetTime.secondTimePos[1].pos);
    end
end

RoomFriendSetTime.onSecondTime2Click = function(self)
    if self.m_data and self.m_data.secondTime ~= RoomFriendSetTime.secondTimePos[2].secondTime then 
        self.m_data.secondTime = RoomFriendSetTime.secondTimePos[2].secondTime;
        self:onSecondChoiceIconMove(RoomFriendSetTime.secondTimePos[2].pos);
    end
end

RoomFriendSetTime.onSecondTime3Click = function(self)
    if self.m_data and self.m_data.secondTime ~= RoomFriendSetTime.secondTimePos[3].secondTime then 
        self.m_data.secondTime = RoomFriendSetTime.secondTimePos[3].secondTime;
        self:onSecondChoiceIconMove(RoomFriendSetTime.secondTimePos[3].pos);
    end
end

RoomFriendSetTime.onGameChoiceIconMove = function(self,pos)
    if not self.m_gameChoiceIcon:checkAddProp(1) then 
		self.m_gameChoiceIcon:removeProp(1);
	end
    if self.m_gameChoice_x then
        self.m_gameChoiceIcon:setPos(self.m_gameChoice_x);
    end
    local x,y = self.m_gameChoiceIcon:getPos();
    if pos ~= x then
        local change_x = pos-x;
        self.m_gameChoice_x = pos;
        self.m_animGameTranslate = self.m_gameChoiceIcon:addPropTranslate(1,kAnimNormal,(math.abs(change_x)/400+1)*RoomFriendSetTime.baseTime,-1,0,change_x);
        self.m_animGameTranslate:setEvent(self,self.onGameTranslateFinish);
        self.m_animGameTranslate:setDebugName("AnimInt|RoomFriendSetTime.animTranslate");
    end
end

RoomFriendSetTime.onStepChoiceIconMove = function(self,pos)
    if not self.m_stepChoiceIcon:checkAddProp(1) then 
		self.m_stepChoiceIcon:removeProp(1);
	end
    if self.m_stepChoice_x then
        self.m_stepChoiceIcon:setPos(self.m_stepChoice_x);
    end
    local x,y = self.m_stepChoiceIcon:getPos();
    if pos ~= x then
        local change_x = pos-x;
        self.m_stepChoice_x = pos;
        self.m_animStepTranslate = self.m_stepChoiceIcon:addPropTranslate(1,kAnimNormal,(math.abs(change_x)/400+1)*RoomFriendSetTime.baseTime,-1,0,change_x);
        self.m_animStepTranslate:setEvent(self,self.onStepTranslateFinish);
        self.m_animStepTranslate:setDebugName("AnimInt|RoomFriendSetTime.animStepTranslate");
    end
end

RoomFriendSetTime.onSecondChoiceIconMove = function(self,pos)
    if not self.m_secondChoiceIcon:checkAddProp(1) then 
		self.m_secondChoiceIcon:removeProp(1);
	end
    if self.m_secondChoice_x then
        self.m_secondChoiceIcon:setPos(self.m_secondChoice_x);
    end
    local x,y = self.m_secondChoiceIcon:getPos();
    if pos ~= x then
        local change_x = pos-x;
        self.m_secondChoice_x = pos;
        self.m_animSecondTranslate = self.m_secondChoiceIcon:addPropTranslate(1,kAnimNormal,(math.abs(change_x)/400+1)*RoomFriendSetTime.baseTime,-1,0,change_x);
        self.m_animSecondTranslate:setEvent(self,self.onSecondTranslateFinish);
        self.m_animSecondTranslate:setDebugName("AnimInt|RoomFriendSetTime.animSecondTranslate");
    end
end

RoomFriendSetTime.onGameTranslateFinish = function(self)
    if not self.m_gameChoiceIcon:checkAddProp(1) then 
		self.m_gameChoiceIcon:removeProp(1);
        self.m_animGameTranslate = nil;
	end
    self.m_gameChoiceIcon:setPos(self.m_gameChoice_x);
end

RoomFriendSetTime.onStepTranslateFinish = function(self)
    if not self.m_stepChoiceIcon:checkAddProp(1) then 
		self.m_stepChoiceIcon:removeProp(1);
        self.m_animStepTranslate = nil;
	end
    self.m_stepChoiceIcon:setPos(self.m_stepChoice_x);
end

RoomFriendSetTime.onSecondTranslateFinish = function(self)
    if not self.m_secondChoiceIcon:checkAddProp(1) then 
		self.m_secondChoiceIcon:removeProp(1);
        self.m_animSecondTranslate = nil;
	end
    self.m_secondChoiceIcon:setPos(self.m_secondChoice_x);
end

--endregion
