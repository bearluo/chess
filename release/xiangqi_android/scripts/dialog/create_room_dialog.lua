
require(VIEW_PATH .. "create_room_dialog_view");
require("dialog/time_picker_dialog");
require(BASE_PATH.."chessDialogScene")
CreateRoomDialog = class(ChessDialogScene,false);

CreateRoomDialog.baseTime = 200;--值越小，滑动速度越快

CreateRoomDialog.gameTimePos = {
    {gameTime = 600; pos = -50;},
    {gameTime = 1200; pos = 123;},
    {gameTime = 1800; pos = 295;},
    {gameTime = 3600; pos = 457;},
};

CreateRoomDialog.stepTimePos = {
    {stepTime = 30; pos = -50;};
    {stepTime = 60; pos = 123;};
    {stepTime = 120; pos = 295;};
    {stepTime = 180; pos = 457;};
};

CreateRoomDialog.secondTimePos = {
    {secondTime = 0; pos = -50;};
    {secondTime = 30; pos = 203;};
    {secondTime = 60; pos = 457;};
};

CreateRoomDialog.s_controls = 
{
    suceBtn                 = 1;
    cancleBtn               = 2;
    gameSliderTime1         = 3;
    gameSliderTime2         = 4;
    gameSliderTime3         = 5;
    gameSliderTime4         = 6;
    gameChoiceIcon          = 7;
    stepSliderTime1         = 8;
    stepSliderTime2         = 9;
    stepSliderTime3         = 10;
    stepSliderTime4         = 11;
    stepChoiceIcon          = 12;
    secondSliderTime1       = 13;
    secondSliderTime2       = 14;
    secondSliderTime3       = 15;
    secondChoiceIcon        = 16;

    gameTimeText1           = 17;
    gameTimeText2           = 18;
    gameTimeText3           = 19;
    gameTimeText4           = 20;
    stepTimeText1           = 21;
    stepTimeText2           = 22;
    stepTimeText3           = 23;
    stepTimeText4           = 24;
    secondTimeText1         = 25;
    secondTimeText2         = 26;
    secondTimeText3         = 27;

    room_name_error_icon    = 28;
    pwd_error_icon          = 29;

    input_room_name_text_label      = 30;
    input_pwd_text_label            = 31;
    input_name_edit                 = 32;
    input_pwd_edit                    = 33;
    create_room_view_bg             = 34;
    close_btn               = 35;
};

CreateRoomDialog.s_controlConfig = 
{
	[CreateRoomDialog.s_controls.suceBtn] = {"create_room_view_bg","create_room_ok_btn"};
	[CreateRoomDialog.s_controls.cancleBtn] = {"create_room_view_bg","cancle_btn"};
	[CreateRoomDialog.s_controls.gameSliderTime1] = {"create_room_view_bg","game_time_view","slider_view","View1","btn_1"};
    [CreateRoomDialog.s_controls.gameSliderTime2] = {"create_room_view_bg","game_time_view","slider_view","View2","btn_2"};
    [CreateRoomDialog.s_controls.gameSliderTime3] = {"create_room_view_bg","game_time_view","slider_view","View3","btn_3"};
    [CreateRoomDialog.s_controls.gameSliderTime4] = {"create_room_view_bg","game_time_view","slider_view","View4","btn_4"};
    [CreateRoomDialog.s_controls.gameChoiceIcon] = {"create_room_view_bg","game_time_view","slider_view","choiceIcon"};
    [CreateRoomDialog.s_controls.stepSliderTime1] = {"create_room_view_bg","step_time_view","slider_view","View1","btn_1"};
    [CreateRoomDialog.s_controls.stepSliderTime2] = {"create_room_view_bg","step_time_view","slider_view","View2","btn_2"};
    [CreateRoomDialog.s_controls.stepSliderTime3] = {"create_room_view_bg","step_time_view","slider_view","View3","btn_3"};
    [CreateRoomDialog.s_controls.stepSliderTime4] = {"create_room_view_bg","step_time_view","slider_view","View4","btn_4"};
    [CreateRoomDialog.s_controls.stepChoiceIcon] = {"create_room_view_bg","step_time_view","slider_view","choiceIcon"};
    [CreateRoomDialog.s_controls.secondSliderTime1] = {"create_room_view_bg","second_time_view","slider_view","View1","btn_1"};
    [CreateRoomDialog.s_controls.secondSliderTime2] = {"create_room_view_bg","second_time_view","slider_view","View2","btn_2"};
    [CreateRoomDialog.s_controls.secondSliderTime3] = {"create_room_view_bg","second_time_view","slider_view","View3","btn_3"};
    [CreateRoomDialog.s_controls.secondChoiceIcon] = {"create_room_view_bg","second_time_view","slider_view","choiceIcon"};

    [CreateRoomDialog.s_controls.gameTimeText1] = {"create_room_view_bg","game_time_view","slider_view","View1","time_text1"};
    [CreateRoomDialog.s_controls.gameTimeText2] = {"create_room_view_bg","game_time_view","slider_view","View2","time_text2"};
    [CreateRoomDialog.s_controls.gameTimeText3] = {"create_room_view_bg","game_time_view","slider_view","View3","time_text3"};
    [CreateRoomDialog.s_controls.gameTimeText4] = {"create_room_view_bg","game_time_view","slider_view","View4","time_text4"};

    [CreateRoomDialog.s_controls.stepTimeText1] = {"create_room_view_bg","step_time_view","slider_view","View1","time_text1"};
    [CreateRoomDialog.s_controls.stepTimeText2] = {"create_room_view_bg","step_time_view","slider_view","View2","time_text2"};
    [CreateRoomDialog.s_controls.stepTimeText3] = {"create_room_view_bg","step_time_view","slider_view","View3","time_text3"};
    [CreateRoomDialog.s_controls.stepTimeText4] = {"create_room_view_bg","step_time_view","slider_view","View4","time_text4"};

    [CreateRoomDialog.s_controls.secondTimeText1] = {"create_room_view_bg","second_time_view","slider_view","View1","time_text1"};
    [CreateRoomDialog.s_controls.secondTimeText2] = {"create_room_view_bg","second_time_view","slider_view","View2","time_text2"};
    [CreateRoomDialog.s_controls.secondTimeText3] = {"create_room_view_bg","second_time_view","slider_view","View3","time_text3"};

	[CreateRoomDialog.s_controls.room_name_error_icon]      = {"create_room_view_bg","room_name_error_icon"};
	[CreateRoomDialog.s_controls.pwd_error_icon]            = {"create_room_view_bg","pwd_error_icon"};
	[CreateRoomDialog.s_controls.input_room_name_text_label]      = {"create_room_view_bg","input_room_name_text_label"};
	[CreateRoomDialog.s_controls.input_pwd_text_label]            = {"create_room_view_bg","input_pwd_text_label"};
	[CreateRoomDialog.s_controls.input_name_edit]           = {"create_room_view_bg","input_name_bg","edit"};
	[CreateRoomDialog.s_controls.input_pwd_edit]            = {"create_room_view_bg","input_pwd_bg","edit"};
	[CreateRoomDialog.s_controls.create_room_view_bg]            = {"create_room_view_bg"};
	[CreateRoomDialog.s_controls.close_btn]            = {"create_room_view_bg","close_btn"};
    
};

CreateRoomDialog.MODE_SURE = 1;
CreateRoomDialog.MODE_AGREE = 2;
CreateRoomDialog.MODE_OK = 3;
CreateRoomDialog.max_sec = 59;
CreateRoomDialog.timout1_min_min = 5;
CreateRoomDialog.timout1_max_min = 120;

CreateRoomDialog.ctor = function(self,x,y,w,h,room)
	super(self,create_room_dialog_view);
    self.m_ctrls = CreateRoomDialog.s_controls;
    self.m_parent_view = parent_view;
    self.m_room = room;
    self.m_dataInfo = UserInfo.getInstance():getGameTimeInfoByLevel(UserInfo.getInstance():getRoomConfigById(4).level or 0)
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
    

    self.m_pwd_error_icon = self:findViewById(self.m_ctrls.pwd_error_icon);
    self.m_room_name_error_icon = self:findViewById(self.m_ctrls.room_name_error_icon);
    self.m_input_room_name_text_label = self:findViewById(self.m_ctrls.input_room_name_text_label);
    self.m_input_pwd_text_label = self:findViewById(self.m_ctrls.input_pwd_text_label);
    self.m_nameInputEdit = self:findViewById(self.m_ctrls.input_name_edit);
    self.m_nameInputEdit:setHintText("点击输入房间名",165,145,120);
    self.m_pwdInputEdit = self:findViewById(self.m_ctrls.input_pwd_edit);
    self.m_pwdInputEdit:setHintText("点击输入密码",165,145,120);
    

    self.m_defaultRoomName = UserInfo.getInstance():getName().."的房间";
    self.m_nameInputEdit:setText(self.m_defaultRoomName);

    self.m_sure_btn = self:findViewById(self.m_ctrls.suceBtn);
    self.m_sure_btn:setOnClick(self,self.sure);
    self.m_create_room_view_bg = self:findViewById(self.m_ctrls.create_room_view_bg); 

    self:setShieldClick(self,self.dismiss);
    self.m_create_room_view_bg:setEventTouch(self,function()end);

    self.m_create_room_view_bg:getChildByName("input_dizhu_bg"):getChildByName("edit"):setPickable(false);
    self:initData();

    self.m_close_btn = self:findViewById(self.m_ctrls.close_btn); 
    self.m_close_btn:setOnClick(self,self.dismiss);
end


CreateRoomDialog.initData = function(self)
    if self.m_dataInfo then
        self.m_gameTimeText1:setText(self:checkTime(self.m_dataInfo.gameTime[1]));
        CreateRoomDialog.gameTimePos[1].gameTime = self.m_dataInfo.gameTime[1];
        self.m_gameTimeText2:setText(self:checkTime(self.m_dataInfo.gameTime[2]));
        CreateRoomDialog.gameTimePos[2].gameTime = self.m_dataInfo.gameTime[2];
        self.m_gameTimeText3:setText(self:checkTime(self.m_dataInfo.gameTime[3]));
        CreateRoomDialog.gameTimePos[3].gameTime = self.m_dataInfo.gameTime[3];
        self.m_gameTimeText4:setText(self:checkTime(self.m_dataInfo.gameTime[4]));
        CreateRoomDialog.gameTimePos[4].gameTime = self.m_dataInfo.gameTime[4];
        self.m_stepTimeText1:setText(self:checkTime(self.m_dataInfo.stepTime[1]));
        CreateRoomDialog.stepTimePos[1].stepTime = self.m_dataInfo.stepTime[1];
        self.m_stepTimeText2:setText(self:checkTime(self.m_dataInfo.stepTime[2]));
        CreateRoomDialog.stepTimePos[2].stepTime = self.m_dataInfo.stepTime[2];
        self.m_stepTimeText3:setText(self:checkTime(self.m_dataInfo.stepTime[3]));
        CreateRoomDialog.stepTimePos[3].stepTime = self.m_dataInfo.stepTime[3];
        self.m_stepTimeText4:setText(self:checkTime(self.m_dataInfo.stepTime[4]));
        CreateRoomDialog.stepTimePos[4].stepTime = self.m_dataInfo.stepTime[4];
        self.m_secondTimeText1:setText(self:checkTime(self.m_dataInfo.secondTime[1],"不读秒"));
        CreateRoomDialog.secondTimePos[1].secondTime = self.m_dataInfo.secondTime[1];
        self.m_secondTimeText2:setText(self:checkTime(self.m_dataInfo.secondTime[2],"不读秒"));
        CreateRoomDialog.secondTimePos[2].secondTime = self.m_dataInfo.secondTime[2];
        self.m_secondTimeText3:setText(self:checkTime(self.m_dataInfo.secondTime[3],"不读秒"));
        CreateRoomDialog.secondTimePos[3].secondTime = self.m_dataInfo.secondTime[3];
    end
end

CreateRoomDialog.checkTime = function(self,time,text0)
    if time and time < 60 and time > 0 then
        return time .. "秒";
    elseif time and time >= 60 then
        return time/60 .. "分"
    elseif time and time <= 0 then
        return text0 or "不限时"
    end
end

CreateRoomDialog.reset = function(self)
    self.m_pwd_error_icon:setVisible(false);
    self.m_room_name_error_icon:setVisible(false);
    if self.m_data then
    else
        self.m_data = {};
        self.m_data.gameTime = CreateRoomDialog.gameTimePos[1].gameTime;
        self.m_data.stepTime = CreateRoomDialog.stepTimePos[1].stepTime;
        self.m_data.secondTime = CreateRoomDialog.secondTimePos[1].secondTime;
    end
    if self.m_data.gameTime then        --局时
        for i=1,4 do
            if self.m_data.gameTime == CreateRoomDialog.gameTimePos[i].gameTime then
                self.m_gameChoiceIcon:setAlign(kAlignLeft);
                self.m_gameChoiceIcon:setPos(CreateRoomDialog.gameTimePos[i].pos);
                self.m_gameChoice_x = CreateRoomDialog.gameTimePos[i].pos;
                break;
            end
        end
    end
    if self.m_data.stepTime then        --步时
        for i=1,4 do
            if self.m_data.stepTime == CreateRoomDialog.stepTimePos[i].stepTime then
                self.m_stepChoiceIcon:setAlign(kAlignLeft);
                self.m_stepChoiceIcon:setPos(CreateRoomDialog.stepTimePos[i].pos);
                self.m_stepChoice_x = CreateRoomDialog.stepTimePos[i].pos;
                break;
            end
        end
    end
    if self.m_data.secondTime then
        for i=1,3 do
            if self.m_data.secondTime == CreateRoomDialog.secondTimePos[i].secondTime then
                self.m_secondChoiceIcon:setAlign(kAlignLeft);
                self.m_secondChoiceIcon:setPos(CreateRoomDialog.secondTimePos[i].pos);
                self.m_secondChoice_x = CreateRoomDialog.secondTimePos[i].pos;
                break;
            end
        end
    end
    self:setVisible(false);
end

CreateRoomDialog.onGameTime1Click = function(self)
    if self.m_data and self.m_data.gameTime ~= CreateRoomDialog.gameTimePos[1].gameTime then 
        self.m_data.gameTime = CreateRoomDialog.gameTimePos[1].gameTime;
        self:onGameChoiceIconMove(CreateRoomDialog.gameTimePos[1].pos);
    end
end

CreateRoomDialog.onGameTime2Click = function(self)
    if self.m_data and self.m_data.gameTime ~= CreateRoomDialog.gameTimePos[2].gameTime then 
        self.m_data.gameTime = CreateRoomDialog.gameTimePos[2].gameTime;
        self:onGameChoiceIconMove(CreateRoomDialog.gameTimePos[2].pos);
    end
end

CreateRoomDialog.onGameTime3Click = function(self)
    if self.m_data and self.m_data.gameTime ~= CreateRoomDialog.gameTimePos[3].gameTime then 
        self.m_data.gameTime = CreateRoomDialog.gameTimePos[3].gameTime;
        self:onGameChoiceIconMove(CreateRoomDialog.gameTimePos[3].pos);
    end
end

CreateRoomDialog.onGameTime4Click = function(self)
    if self.m_data and self.m_data.gameTime ~= CreateRoomDialog.gameTimePos[4].gameTime then 
        self.m_data.gameTime = CreateRoomDialog.gameTimePos[4].gameTime;
        self:onGameChoiceIconMove(CreateRoomDialog.gameTimePos[4].pos);
    end
end

CreateRoomDialog.onStepTime1Click = function(self)
    if self.m_data and self.m_data.stepTime ~= CreateRoomDialog.stepTimePos[1].stepTime then 
        self.m_data.stepTime = CreateRoomDialog.stepTimePos[1].stepTime;
        self:onStepChoiceIconMove(CreateRoomDialog.stepTimePos[1].pos);
    end
end

CreateRoomDialog.onStepTime2Click = function(self)
    if self.m_data and self.m_data.stepTime ~= CreateRoomDialog.stepTimePos[2].stepTime then 
        self.m_data.stepTime = CreateRoomDialog.stepTimePos[2].stepTime;
        self:onStepChoiceIconMove(CreateRoomDialog.stepTimePos[2].pos);
    end
end

CreateRoomDialog.onStepTime3Click = function(self)
    if self.m_data and self.m_data.stepTime ~= CreateRoomDialog.stepTimePos[3].stepTime then 
        self.m_data.stepTime = CreateRoomDialog.stepTimePos[3].stepTime;
        self:onStepChoiceIconMove(CreateRoomDialog.stepTimePos[3].pos);
    end
end

CreateRoomDialog.onStepTime4Click = function(self)
    if self.m_data and self.m_data.stepTime ~= CreateRoomDialog.stepTimePos[4].stepTime then 
        self.m_data.stepTime = CreateRoomDialog.stepTimePos[4].stepTime;
        self:onStepChoiceIconMove(CreateRoomDialog.stepTimePos[4].pos);
    end
end

CreateRoomDialog.onSecondTime1Click = function(self)
    if self.m_data and self.m_data.secondTime ~= CreateRoomDialog.secondTimePos[1].secondTime then 
        self.m_data.secondTime = CreateRoomDialog.secondTimePos[1].secondTime;
        self:onSecondChoiceIconMove(CreateRoomDialog.secondTimePos[1].pos);
    end
end

CreateRoomDialog.onSecondTime2Click = function(self)
    if self.m_data and self.m_data.secondTime ~= CreateRoomDialog.secondTimePos[2].secondTime then 
        self.m_data.secondTime = CreateRoomDialog.secondTimePos[2].secondTime;
        self:onSecondChoiceIconMove(CreateRoomDialog.secondTimePos[2].pos);
    end
end

CreateRoomDialog.onSecondTime3Click = function(self)
    if self.m_data and self.m_data.secondTime ~= CreateRoomDialog.secondTimePos[3].secondTime then 
        self.m_data.secondTime = CreateRoomDialog.secondTimePos[3].secondTime;
        self:onSecondChoiceIconMove(CreateRoomDialog.secondTimePos[3].pos);
    end
end

CreateRoomDialog.onGameChoiceIconMove = function(self,pos)
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
        self.m_animGameTranslate = self.m_gameChoiceIcon:addPropTranslate(1,kAnimNormal,(math.abs(change_x)/400+1)*CreateRoomDialog.baseTime,-1,0,change_x);
        self.m_animGameTranslate:setEvent(self,self.onGameTranslateFinish);
        self.m_animGameTranslate:setDebugName("AnimInt|CreateRoomDialog.animTranslate");
    end
end

CreateRoomDialog.onStepChoiceIconMove = function(self,pos)
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
        self.m_animStepTranslate = self.m_stepChoiceIcon:addPropTranslate(1,kAnimNormal,(math.abs(change_x)/400+1)*CreateRoomDialog.baseTime,-1,0,change_x);
        self.m_animStepTranslate:setEvent(self,self.onStepTranslateFinish);
        self.m_animStepTranslate:setDebugName("AnimInt|CreateRoomDialog.animStepTranslate");
    end
end

CreateRoomDialog.onSecondChoiceIconMove = function(self,pos)
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
        self.m_animSecondTranslate = self.m_secondChoiceIcon:addPropTranslate(1,kAnimNormal,(math.abs(change_x)/400+1)*CreateRoomDialog.baseTime,-1,0,change_x);
        self.m_animSecondTranslate:setEvent(self,self.onSecondTranslateFinish);
        self.m_animSecondTranslate:setDebugName("AnimInt|CreateRoomDialog.animSecondTranslate");
    end
end


CreateRoomDialog.onGameTranslateFinish = function(self)
    if not self.m_gameChoiceIcon:checkAddProp(1) then 
		self.m_gameChoiceIcon:removeProp(1);
        self.m_animGameTranslate = nil;
	end
    self.m_gameChoiceIcon:setPos(self.m_gameChoice_x);
end

CreateRoomDialog.onStepTranslateFinish = function(self)
    if not self.m_stepChoiceIcon:checkAddProp(1) then 
		self.m_stepChoiceIcon:removeProp(1);
        self.m_animStepTranslate = nil;
	end
    self.m_stepChoiceIcon:setPos(self.m_stepChoice_x);
end

CreateRoomDialog.onSecondTranslateFinish = function(self)
    if not self.m_secondChoiceIcon:checkAddProp(1) then 
		self.m_secondChoiceIcon:removeProp(1);
        self.m_animSecondTranslate = nil;
	end
    self.m_secondChoiceIcon:setPos(self.m_secondChoice_x);
end

CreateRoomDialog.roomNameTextChange = function(self,text)
	local content = self.m_nameInputEdit:getText();
	local lenutf8 = string.lenutf8(content);

	if lenutf8 > 8 then
		content = string.subutf8(content,1,8);  --英文
	end

	self.m_nameInputEdit:setText(content);
end

CreateRoomDialog.roomPwdTextChange = function(self,text)
	local content = self.m_pwdInputEdit:getText();
	local len = string.len(content);
	if len  > 10  then
		content = string.sub(content, 1, 10);
		self.m_pwdInputEdit:setText(content);
	end
end


CreateRoomDialog.checkPwdInputStr = function(self,inputStr)

	local len = string.len(inputStr);
	local lenutf8 = string.lenutf8(inputStr);
    
    if len>lenutf8 then
    	return false;
    end

	 if string.find(inputStr,"%W") then
	 	return false
	 end

	  if len>10 or len<4 then
	  	return false
	  end
	 return true;
end

CreateRoomDialog.checkNameInputStr = function(self,inputStr)
	if string.find(inputStr,"%W") then
	 	--可能是包含中文或者特殊字符，所以进步-[判断]
	 	if ToolKit.isContainSpecialChar(inputStr) then
	 		return false;
	 	else--没有包含特殊字符，只包含中文
	        return true;
	 	end
	else
	    return true;
	end
end

CreateRoomDialog.dtor = function(self)
	self.m_root_view = nil;
end

CreateRoomDialog.isShowing = function(self)
	return self:getVisible();
end

CreateRoomDialog.onTouch = function(self)
	print_string("CreateRoomDialog.onTouch");
end

CreateRoomDialog.show = function(self)
	print_string("CreateRoomDialog.show ... ");
    self:reset();
    for i = 1,4 do 
        if not self.m_create_room_view_bg:checkAddProp(i) then
            self.m_create_room_view_bg:removeProp(i);
        end 
    end

    local w,h = self.m_create_room_view_bg:getSize();
--    local anim = self.m_create_room_view_bg:addPropTranslateWithEasing(1,kAnimNormal, 600, -1,function (...) return 0 end,"easeOutBack",0,0, h, -h);
    local anim = self.m_create_room_view_bg:addPropTranslate(1,kAnimNormal,400,-1,0,0,h,0);
    anim:setEvent(self,function()
        self.m_create_room_view_bg:addPropTranslate(4,kAnimNormal,200,-1,0,0,0,-25);
        delete(anim);
        anim = nil;
--        self.m_create_room_view_bg:removeProp(1);
    end);

    local anim_end = new(AnimInt,kAnimNormal,0,1,600,-1);
    if anim_end then
        anim_end:setEvent(self,function()
            for i = 1,4 do 
                if not self.m_create_room_view_bg:checkAddProp(i) then
                    self.m_create_room_view_bg:removeProp(i);
                end 
            end
            delete(anim_end);
        end);
    end
	self:setVisible(true);
    self.super.show(self,false);
end


CreateRoomDialog.cancel = function(self)
	print_string("CreateRoomDialog.cancel ");
	if self.m_timeout_picker~= nil then
		self.m_timeout_picker:cancel();
	end

	self:dismiss();
	-- if self.m_negObj and self.m_negFunc then
	-- 	self.m_negFunc(self.m_negObj);
	-- end
end

CreateRoomDialog.getDefaultRoomName = function(self)
    local  defaultRoomName = UserInfo.getInstance():getName();
    if string.lenutf8(defaultRoomName)<=5 then
    	defaultRoomName= defaultRoomName.."的房间"
    end
    return defaultRoomName;
end

CreateRoomDialog.sure = function(self)
	print_string("CreateRoomDialog.sure ");

	local roomnameStr= self.m_nameInputEdit:getText();
	local roompwdStr= self.m_pwdInputEdit:getText();

	 if roomnameStr==nil or roomnameStr==" " or roomnameStr == "" then
	 	roomnameStr = self.m_defaultRoomName;
	 else
		 if self.m_defaultRoomName ~= roomnameStr and self:checkNameInputStr(roomnameStr) ==false  then
			self.m_room_name_error_icon:setVisible(true);
			self.m_nameInputEdit:setText(self.m_defaultRoomName);
			return;
		end
	 end

    if roompwdStr==nil or roompwdStr == " " or roompwdStr == "" then
    	roompwdStr = "";
    	UserInfo.getInstance():setIsCustomRoomPwd(0);
    else
	 	if self:checkPwdInputStr(roompwdStr) ==false  then
			self.m_pwd_error_icon:setVisible(true);
--			self.m_pwdInputEdit:setText("请输入4到10位密码");
			self.m_pwdInputEdit:setText("");
			UserInfo.getInstance():setIsCustomRoomPwd(1);
			return;
		end   	
    end

    UserInfo.getInstance():setCustomRoomPwd(roompwdStr);

	self.m_room_name_error_icon:setVisible(false);
	self.m_pwd_error_icon:setVisible(false);

    local leftTimeout1 = self.m_data.gameTime;
    local leftTimeout2 = self.m_data.stepTime;
    local leftTimeout3 = self.m_data.secondTime;
	

	if leftTimeout3 > leftTimeout2 or leftTimeout2 > leftTimeout1 then
		if not self.m_chioce_dialog then
			self.m_chioce_dialog = new(ChioceDialog);
		end

		local message = "你的读秒大于步时，或者步时大于局时，请重新设置！！！";
		self.m_chioce_dialog:setMode(ChioceDialog.MODE_OK);
		self.m_chioce_dialog:setMessage(message);
		self.m_chioce_dialog:setPositiveListener(nil,nil);
		self.m_chioce_dialog:show();

		return false;
	end
    local roomData = UserInfo.getInstance():getRoomConfigById(4);
    local info = {};
    info.level = roomData.level;
    info.uid = UserInfo.getInstance():getUid();
    info.name = roomnameStr;
    info.password  = roompwdStr;
    info.basechip  = roomData.money;
    info.round_time= leftTimeout1;
    info.step_time= leftTimeout2;
    info.sec_time= leftTimeout3;
    self.m_room:customCreateRoom(info);

	
	self:dismiss();
end

CreateRoomDialog.dismiss = function(self)
--	self:setVisible(false);
    for i = 1,4 do 
        if not self.m_create_room_view_bg:checkAddProp(i) then
            self.m_create_room_view_bg:removeProp(i);
        end 
    end
    local w,h = self.m_create_room_view_bg:getSize();
    local anim = self.m_create_room_view_bg:addPropTranslate(3, kAnimNormal, 300, -1, 0, 0, 0, h);
    self.m_create_room_view_bg:addPropTransparency(2,kAnimNormal,200,-1,1,0);
    anim:setEvent(self,function()
        self:setVisible(false);
        self.m_create_room_view_bg:removeProp(2);
        self.m_create_room_view_bg:removeProp(3);
        delete(anim)
        anim = nil;
    end);
    self.super.dismiss(self,false);
	if self.m_chioce_dialog then
		self.m_chioce_dialog:dismiss();
	end
end