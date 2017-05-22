require("dialog/leave_tips_dialog");

OnlineConfig = {};

OnlineConfig.ctor = function (self,obj)
	print_string("OnlineConfig.ctor");
	self.m_obj = obj;
end

OnlineConfig.dtor = function(self)
	print_string("OnlineConfig.dtor");
end

OnlineConfig.getInstance = function ()
	if not OnlineConfig.s_instance then
		OnlineConfig.s_instance = new(OnlineConfig);
	end
	return OnlineConfig.s_instance;
end

OnlineConfig.setChallengReward= function(self,reward)
	self.m_reward = reward;
end

OnlineConfig.getChallengReward = function(self)
	return self.m_reward;
end

OnlineConfig.setOnlineGameDailyWork = function(self,num)
	self.m_online_game_num = num;
end

OnlineConfig.getOnlineGameDailyWork = function(self)
	return self.m_online_game_num or 0;
end

OnlineConfig.getOnlineGameDailyWorkProgress = function(self)
    local  uid = UserInfo.getInstance():getUid();
    local online_progress = GameCacheData.getInstance():getInt(GameCacheData.ONLINE_GAME_PLAY_COUNT..uid,0);
	return online_progress or 0;
end

OnlineConfig.leaveTipsDialog = nil;

OnlineConfig.retentionTips = function(self,model,exitCallback)
	if OnlineConfig.leaveTipsDialog then
		OnlineConfig.leaveTipsDialog:dismiss();
		OnlineConfig.leaveTipsDialog = nil;
	end

	local  uid = UserInfo.getInstance():getUid();

	local is_reward =  GameCacheData.getInstance():getBoolean(GameCacheData.IS_ONLINE_GAME_PLAY_REWARD..uid,true);

	if not is_reward then --还没领取奖励
		local num = self:getOnlineGameDailyWorkProgress();
		local online_num = self:getOnlineGameDailyWork();
		local leftnum = online_num - num;

		if	leftnum>0 then

			local msg = "再进行"..leftnum.."局，就可获得任务奖励，确定要退出吗？";
			local isLeaveGame = false;
			OnlineConfig.leaveTipsDialog = new(LeaveTipsDialog,isLeaveGame);

			OnlineConfig.leaveTipsDialog:setMessage(msg);
			OnlineConfig.leaveTipsDialog:setExitListener(model,exitCallback)
			OnlineConfig.leaveTipsDialog:setCancelListener(model,OnlineConfig.cancel)
			OnlineConfig.leaveTipsDialog:show(model.m_root_view);
			return;
		end
	end

	local lefttime = OnlineConfig.getOpenboxtime()  -  OnlineConfig.getPlaytime();
	if OnlineConfig.getOpenboxtime()  > 0 and lefttime > 0 and lefttime < 1800 then
		local time;
		if lefttime >= 60 then
			time = os.date("%M分%S秒", lefttime);
		else
			time = os.date("%S秒", lefttime);
		end
	
		local msg = "再玩"..time.."，你可以获得在线奖励，确定要退出吗？";
		local isLeaveGame = false;
		OnlineConfig.leaveTipsDialog = new(LeaveTipsDialog,isLeaveGame);

		OnlineConfig.leaveTipsDialog:setMessage(msg);
		OnlineConfig.leaveTipsDialog:setExitListener(model,exitCallback)
		OnlineConfig.leaveTipsDialog:setCancelListener(model,OnlineConfig.cancel)
		OnlineConfig.leaveTipsDialog:show(model.m_root_view);
		return;
	end

	exitCallback();
end

OnlineConfig.cancel = function(model)
	OnlineConfig.leaveTipsDialog = nil;
end

OnlineConfig.callsCallBack = function(model)
	OnlineConfig.leaveTipsDialog = nil;
	StateMachine.getInstance():pushState(States.ExchangeMall,StateMachine.STYPE_CUSTOM_WAIT);
end

OnlineConfig.coinsCallBack = function(model)
	OnlineConfig.leaveTipsDialog = nil;
	UserInfo.getInstance():setIsShowDaliy(true)
	OnlineConfig.exitCallback();
end

OnlineConfig.setPlaytime = function(playtime)
	OnlineConfig.m_playtime = playtime;
end

OnlineConfig.getPlaytime = function()
	return OnlineConfig.m_playtime or 0;
end

OnlineConfig.setOpenboxtime = function(openbox_time)
	OnlineConfig.openbox_time = openbox_time;
end

OnlineConfig.getOpenboxtime = function()
	return OnlineConfig.openbox_time or 0;
end


OnlineConfig.setOpenboxid = function(openbox_id)

	OnlineConfig.openbox_id = openbox_id;
end

OnlineConfig.getOpenboxid= function()
	return OnlineConfig.openbox_id or 0;
end

OnlineConfig.startOnlineBoxtimer = function(model)
	local openbox_time = OnlineConfig.getOpenboxtime();
	local playtime = OnlineConfig.getPlaytime();

	local lefttime = openbox_time - playtime;
	if lefttime > 0 then
		OnlineConfig.isReward = false;
		OnlineConfig.showLeftText(model);
		model.m_online_time_text_bg:setVisible(true);
		--model.m_chest_btn:setFile("drawable/chest_btn_on.png");
        model.m_chest_icon:setVisible(false); -- 宝箱锁住
        model.m_chest_btn:setEnable(false);
		if OnlineConfig.animTimer == nil then
			OnlineConfig.animTimer = new(AnimInt,kAnimRepeat,0,1,1000,-1);
			OnlineConfig.animTimer:setEvent(model,OnlineConfig.onTimer);
		end
        OnlineConfig.deleteOpenBoxTimer();
	else
		if OnlineConfig.getOpenboxtime() > 0 then
			if model.m_chest_btn then
				--model.m_chest_btn:setFile("drawable/chest_btn_ok.png");
                OnlineConfig.openBoxImage = 1;
                model.m_chest_icon:setVisible(true);  -- 宝箱打开
                OnlineConfig.openBoxTimer(model);
                model.m_chest_btn:setEnable(true);
			end
			if model.m_online_time_text_bg then
				model.m_online_time_text_bg:setVisible(false);
			end
		end

		if OnlineConfig.getOpenboxtime() > 0 then
			OnlineConfig.isReward = true;
		else
			OnlineConfig.isReward = false;
		end
		OnlineConfig.deleteTimer(model); 
	end
end

OnlineConfig.onTimer = function(model)
	OnlineConfig.m_playtime =  OnlineConfig.getPlaytime() + 1;
	OnlineConfig.showLeftText(model);
end

OnlineConfig.showLeftText = function(model)

	local openbox_time = OnlineConfig.getOpenboxtime();
	local playtime = OnlineConfig.getPlaytime();

	local lefttime = openbox_time - playtime;

	if lefttime> 0 then
		local min = math.floor(lefttime/60);
        if string.len(min) < 2 then
            min = "0" .. min;
        end
		local second = lefttime%60;
        if string.len(second) < 2 then
            second = "0" .. second;
        end
		if model.m_online_time_text then
			model.m_online_time_text:setText(min..":"..second);
		end
        OnlineConfig.deleteOpenBoxTimer();
	else
		OnlineConfig.isReward = true;
		if model.m_chest_btn then
			--model.m_chest_btn:setFile("drawable/chest_btn_ok.png");
            OnlineConfig.openBoxImage = 1;
            model.m_chest_icon:setVisible(true);
            OnlineConfig.openBoxTimer(model);
            model.m_chest_btn:setEnable(true);
		end
		if model.m_online_time_text_bg then
			model.m_online_time_text_bg:setVisible(false);
		end
		OnlineConfig.deleteTimer(model) 
	end

end

OnlineConfig.deleteTimer = function()
	if OnlineConfig.animTimer then
		delete(OnlineConfig.animTimer);
		OnlineConfig.animTimer = nil;
	end
	OnlineConfig.exitCallback = nil;
end

OnlineConfig.openBoxTimer = function(model)
	if OnlineConfig.openBoxTimerAnim == nil then
        OnlineConfig.s_propAnimIndex = 0;
        OnlineConfig.startPropAnim(model);
	end
end

OnlineConfig.s_propAnimIndex = 0;

OnlineConfig.startPropAnim = function(model)
    OnlineConfig.s_propAnimIndex = OnlineConfig.s_propAnimIndex + 1;
    if OnlineConfig.onPropAnimTab[OnlineConfig.s_propAnimIndex] then
        local propAnim = OnlineConfig.onPropAnimTab[OnlineConfig.s_propAnimIndex];
        if not model.m_chest_icon:checkAddProp(propAnim.params[1]) then
            model.m_chest_icon:removeProp(propAnim.params[1]);
        end
        OnlineConfig.openBoxTimerAnimView = model.m_chest_icon;
        OnlineConfig.openBoxTimerAnimViewPropId = propAnim.params[1];
        OnlineConfig.openBoxTimerAnim = propAnim.func(model.m_chest_icon,unpack(propAnim.params));
        OnlineConfig.openBoxTimerAnim:setEvent(model,OnlineConfig.startPropAnim)
    else
--        if OnlineConfig.onPropAnimTab[OnlineConfig.s_propAnimIndex-1] then
--            local propAnim = OnlineConfig.onPropAnimTab[OnlineConfig.s_propAnimIndex-1];
--            if not model.m_chest_icon:checkAddProp(propAnim.params[1]) then
--                model.m_chest_icon:removeProp(propAnim.params[1]);
--            end
--        end
        
--		OnlineConfig.openBoxTimerAnim = new(AnimInt,kAnimRepeat,0,1,500,-1);
--		OnlineConfig.openBoxTimerAnim:setEvent(model,OnlineConfig.onOpenBoxTimer);
        
    end
end


OnlineConfig.s_scalePropAnim = {
    func = DrawingBase.addPropScale;
    params = {
        1, kAnimNormal, 200, -1, 0.7, 1, 0.7, 1, kCenterDrawing,
    };
}

OnlineConfig.s_translatePropAnim1 = {
    func = DrawingBase.addPropTranslate;
    params = { 
        1, kAnimNormal, 100, 50, 0, 0, 0, -5, 
    };
}
OnlineConfig.s_translatePropAnim2 = {
    func = DrawingBase.addPropTranslate;
    params = { 
        1, kAnimNormal, 100, 50, 0, 0, -5, 2, 
    };
}

OnlineConfig.s_translatePropAnim3 = {
    func = DrawingBase.addPropTranslate;
    params = { 
        1, kAnimNormal, 500, -1, 0, 0, 0, 0, 
    };
}

OnlineConfig.s_rotatePropAnim = {
    func = DrawingBase.addPropRotate;
    params = { 
        1, kAnimLoop, 120, -1, 5, -5, kCenterDrawing,
    };
}

OnlineConfig.onPropAnimTab = {
    OnlineConfig.s_scalePropAnim,
    OnlineConfig.s_translatePropAnim1,
    OnlineConfig.s_translatePropAnim2,
    OnlineConfig.s_translatePropAnim3,
    OnlineConfig.s_rotatePropAnim,
}


OnlineConfig.onOpenBoxTimer = function(model)
	if OnlineConfig.openBoxImage == 1 then
        model.m_chest_icon:setFile(string.format("online/room/chest_%d.png",OnlineConfig.openBoxImage));
        OnlineConfig.openBoxImage = OnlineConfig.openBoxImage + 1;
        return;
    end

    if OnlineConfig.openBoxImage == 2 then
        model.m_chest_icon:setFile(string.format("online/room/chest_%d.png",OnlineConfig.openBoxImage));
        OnlineConfig.openBoxImage = OnlineConfig.openBoxImage - 1;
    end
end

OnlineConfig.deleteOpenBoxTimer = function()
	if OnlineConfig.openBoxTimerAnim then
		delete(OnlineConfig.openBoxTimerAnim);
		OnlineConfig.openBoxTimerAnim = nil;
	end

    if OnlineConfig.openBoxTimerAnimView then
        if not OnlineConfig.openBoxTimerAnimView:checkAddProp(OnlineConfig.openBoxTimerAnimViewPropId) then
            OnlineConfig.openBoxTimerAnimView:removeProp(OnlineConfig.openBoxTimerAnimViewPropId);
        end
        OnlineConfig.openBoxTimerAnimView = nil;
    end
end

TestAnim = {};
TestAnim.startStarAnim = function(root_view,params,callback_event,msg,rotate_view)
    if TestAnim.run then return end;
    TestAnim.run = true;
    TestAnim.star_tab = {};
    TestAnim.params = params or {};
    TestAnim.star_num = TestAnim.params.star_num or 10;
    TestAnim.runAnim = AnimFactory.createAnimInt(kAnimNormal, 0, 1, 1000, -1);
    TestAnim.runAnim:setEvent(callback_event,TestAnim.endStarAnim);
    TestAnim.msg = msg;
    TestAnim.rotate_view = rotate_view;
    if TestAnim.msg then
        TestAnim.msgTextView = new(Text,TestAnim.msg, 0, 0, kAlignCenter, nil, 28, 255, 255, 0);
        TestAnim.msgTextView:setAlign(kAlignTop);
        TestAnim.msgTextView:setVisible(false);
        root_view:addChild(TestAnim.msgTextView);
    end
    for i=1,TestAnim.star_num do
        local scale = math.random(5,10)/10;
        local step_length = math.random(1,1.5);
        TestAnim.star_tab[i] = new(Image,"animation/chest/anim_star.png");
        TestAnim.star_tab[i]:setAlign(kAlignCenter);
        root_view:addChild(TestAnim.star_tab[i]);

        TestAnim.star_tab[i]:addPropRotate(1, kAnimLoop, 3000, -1, 30*i, 360+30*i, kCenterDrawing);
        TestAnim.star_tab[i]:addPropTransparency(2, kAnimNormal, 1000, 500, 1, 0);
        local w,h = TestAnim.star_tab[i]:getSize();
        TestAnim.star_tab[i]:setSize(w*scale,h*scale);
    end

    TestAnim.startMoveAnim();
end

TestAnim.moveIndex = {
    0.5,
    0.8,
    0.9,
}

TestAnim.startMoveAnim = function()
    TestAnim.moveAnim = AnimFactory.createAnimInt(kAnimLoop, 0, 1, 30, -1);
    TestAnim.moveAnimIndex = 0;
    local moveLength = {};
    local angle = 360/TestAnim.star_num;
    for i=1,TestAnim.star_num do
        moveLength[i] = {};
        local length = math.random(50,100);
        local move_x,move_y = math.cos(angle*i*180/math.pi)*length,math.sin(angle*i*180/math.pi)*length;
        moveLength[i].x = move_x;
        moveLength[i].y = move_y;
    end
    TestAnim.moveAnim:setEvent(moveLength,TestAnim.moveAnimEvent);
end

TestAnim.moveAnimEvent = function(moveLength)
    TestAnim.moveAnimIndex = TestAnim.moveAnimIndex + 1;
    for i=1,TestAnim.star_num do
        if TestAnim.star_tab[i] then
            local x = moveLength[i].x*(TestAnim.moveAnimIndex-#TestAnim.moveIndex)/100+moveLength[i].x;
            local y = moveLength[i].y*(TestAnim.moveAnimIndex-#TestAnim.moveIndex)/100+moveLength[i].y;
            if TestAnim.moveIndex[TestAnim.moveAnimIndex] then
                x = moveLength[i].x*TestAnim.moveIndex[TestAnim.moveAnimIndex];
                y = moveLength[i].y*TestAnim.moveIndex[TestAnim.moveAnimIndex];
            end
            TestAnim.star_tab[i]:setPos(x,y);
        end
    end
end

TestAnim.endStarAnim = function(callback_event)
    delete(TestAnim.runAnim);
    delete(TestAnim.moveAnim);
    if TestAnim.msg and TestAnim.msgTextView then
        for i=1,TestAnim.star_num do
            if TestAnim.star_tab[i] then
                TestAnim.star_tab[i]:removeProp(1);
                TestAnim.star_tab[i]:addPropTransparency (1, kAnimNormal, 200, -1, 1, 0);
            end
        end
        
        TestAnim.rotate_view:removeProp(100);
        local anim = TestAnim.rotate_view:addPropTransparency (100, kAnimNormal, 200, -1, 1, 0);
        anim:setEvent(TestAnim,function()
            if TestAnim.star_num and type(TestAnim.star_num) == 'table' then
                for i=1,TestAnim.star_num do
                    if TestAnim.star_tab[i] then
                        delete(TestAnim.star_tab[i]);
                        TestAnim.star_tab[i] = nil;
                    end
                end
            end
            if TestAnim.rotate_view then
                TestAnim.rotate_view:removeProp(100);
                TestAnim.rotate_view:setVisible(false);
            end
        end);

        TestAnim.msgTextView:setVisible(true);
        local w,h = TestAnim.msgTextView:getSize();
        TestAnim.msgTextView:removeProp(1);
        TestAnim.msgTextView:removeProp(2);
        TestAnim.msgTextView:removeProp(3);
        local anim = TestAnim.msgTextView:addPropTranslate(1, kAnimNormal, 2000, -1, 0, 0, 0, -2*h);
        TestAnim.msgTextView:addPropTransparency (2, kAnimNormal, 200, -1, 0, 1);
        TestAnim.msgTextView:addPropTransparency (3, kAnimNormal, 800, 600, 1, 0);
        anim:setEvent(callback_event,function(callback_event)
            TestAnim.deleteTestAnim();
            if callback_event then
                if callback_event.func then
                    callback_event.func(callback_event.obj);
                end
            end
            TestAnim.run = false;
        end);
    else
        for i=1,TestAnim.star_num do
            if TestAnim.star_tab[i] then
                delete(TestAnim.star_tab[i]);
                TestAnim.star_tab[i] = nil;
            end
        end
        if callback_event then
            if callback_event.func then
                callback_event.func(callback_event.obj);
            end
        end
        TestAnim.run = false;
    end
end

TestAnim.deleteTestAnim = function()
    delete(TestAnim.runAnim);
    delete(TestAnim.moveAnim);
    if TestAnim.star_num and type(TestAnim.star_num) == 'table' then
        for i=1,TestAnim.star_num do
            if TestAnim.star_tab[i] then
                delete(TestAnim.star_tab[i]);
                TestAnim.star_tab[i] = nil;
            end
        end
    end
    delete(TestAnim.msgTextView);
    TestAnim.msgTextView = nil;
    TestAnim.msg = nil;

    if TestAnim.rotate_view then
        TestAnim.rotate_view:removeProp(100);
        TestAnim.rotate_view:setVisible(false);
    end

    TestAnim.run = false;
end