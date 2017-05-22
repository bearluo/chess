--region BottomMenu.lua
--Author : BearLuo
--Date   : 2015/4/20

require(VIEW_PATH.."bottom_menu")

BottomMenu = class(GameLayer,false);

BottomMenu.HALLTYPE = 1;
BottomMenu.FINDTYPE = 2;
BottomMenu.OWNTYPE  = 3;

BottomMenu.ctor = function(self)
    super(self,bottom_menu);
    self:setLevel(1);
    self.m_ctrls =  BottomMenu.s_controls;
    self.m_bottom_menu = self:findViewById(self.m_ctrls.bottom_menu);
    self.m_game_model_btn = self:findViewById(self.m_ctrls.game_model_btn);
    self.m_find_model_btn = self:findViewById(self.m_ctrls.find_model_btn);
    self.m_find_model_choose_btn = self.m_find_model_btn:getChildByName("choose_img");
    self.m_own_model_btn = self:findViewById(self.m_ctrls.own_model_btn);
    self.m_bottom_menu:setEventTouch(self,BottomMenu.s_shieldClick);
    self.m_bottom_menu:setEventDrag(self,BottomMenu.s_shieldClick);
    self.m_btn_bg = self:findViewById(self.m_ctrls.btn_bg);
    self.m_game_btn_choose = self.m_game_model_btn:getChildByName("choose_img");
    self.m_find_btn_choose = self.m_find_model_btn:getChildByName("choose_img");
    self.m_own_btn_choose = self.m_own_model_btn:getChildByName("choose_img");
    self.m_own_btn_tip = self.m_own_model_btn:getChildByName("tip");
    self.m_own_btn_tip:setVisible(false);
    self:setFillParent(true,true);
end

BottomMenu.removeAnimProp = function(self)
--    if self.m_anim_prop_need_remove then
--        self.m_bottom_menu:removeProp(1);
--        self.m_anim_prop_need_remove = false;
--    end
end

BottomMenu.resumeAnimStart = function(self)
--    BottomMenu.removeAnimProp(self);
    local duration = 400;
    local delay = -1;
    if self.m_anim_prop_need_remove then return end
    self.m_anim_prop_need_remove = true;


    -- 下部动画
--    local w,h = self.m_bottom_menu:getSize();
--    local anim = self.m_bottom_menu:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, h, 0);
--    anim:setEvent(self,self.removeAnimProp);

end

BottomMenu.pauseAnimStart = function(self)
--    BottomMenu.removeAnimProp(self);
    local duration = 400;
    local delay = -1;
    if self.m_anim_prop_need_remove then return end
    self.m_anim_prop_need_remove = true;  

--    local w,h = self.m_bottom_menu:getSize();
--    local anim = self.m_bottom_menu:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, 0, h);
--    anim:setEvent(self,self.removeAnimProp);
end

BottomMenu.s_shieldClick = function(self)
--    Log.i("ChessDialogScene.s_shieldClick");
end

BottomMenu.getInstance = function()
    if BottomMenu.s_instance == nil then
        BottomMenu.s_instance = new(BottomMenu);
    end
    return BottomMenu.s_instance;
end
--ret 当前界面类型 1:大厅 2;发现 3:我的
BottomMenu.setHandler = function(self,handler,ret)
--    if not ret or ret == 1 then
--        self.m_btn_bg:setAlign(kAlignBottomLeft);
--    elseif ret == 2 then
--        self.m_btn_bg:setAlign(kAlignBottom);
--    elseif ret == 3 then
--        self.m_btn_bg:setAlign(kAlignBottomRight);
--    end
    self.m_handler = handler;
    self.bottomType = ret;
    if self.bottomType == BottomMenu.OWNTYPE then
        self.m_own_btn_tip:setVisible(false);
    end
end

BottomMenu.setOwnBtnTipVisible = function(self)
    if self.bottomType ~= BottomMenu.OWNTYPE then
        if kPlatform == kPlatformIOS then
            if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
                self.m_own_btn_tip:setVisible(true);
            else
                self.m_own_btn_tip:setVisible(false);
            end
        else
    	    self.m_own_btn_tip:setVisible(true);
        end;
    end
end

BottomMenu.reset = function(self)
    local w,h = self:getSize();
    self.m_game_model_btn:setSize(w/3);
    self.m_find_model_btn:setSize(w/3);
    self.m_own_model_btn:setSize(w/3);
    self.m_btn_bg:setSize(w/3,h);
    self:setVisible(true);
    if kPlatform == kPlatformIOS then    
        if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
            self.m_find_model_btn:setVisible(true);
            self.m_find_model_btn:setFile("hall/find_normal.png");
            self.m_find_model_choose_btn:setFile("hall/find_btn_choose.png");
        else
            self.m_find_model_btn:setVisible(true);
            if UserInfo.getInstance():isLogin() then
                self.m_find_model_btn:setFile("hall/mall_normal.png");
                self.m_find_model_choose_btn:setFile("hall/mall_btn_choose.png");
            else
                self.m_find_model_btn:setFile("");
                self.m_find_model_choose_btn:setFile("");
            end;

        end;
    end;
end

BottomMenu.onResume = function(self,parent_root,needMove)
    if parent_root then
        self.m_parent_root = parent_root;
        self.m_parent_root:addChild(self);
    end
    self:setPickable(true);
    self:reset();
    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
--    self:removeAnimProp();
    self:resumeAnimStart();
end

BottomMenu.onPause = function(self)
    if self.m_parent then
        self.m_parent:removeChild(self);
    end
    self:setPickable(false);

    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpRequestsCallBack);
    self.m_quickBtnClickObj = nil;
    self.m_quickBtnClickFunc = nil;
--    self:removeAnimProp();
    self:pauseAnimStart();
end

BottomMenu.dtor = function(self)
    Log.e("BottomMenu.dtor");
end

BottomMenu.s_controls = 
{
    bottom_menu             = 1;
    game_model_btn          = 2;
    find_model_btn          = 3;
    own_model_btn           = 4;
    btn_bg                  = 5;
};

BottomMenu.onMyGameBtnClick = function(self)
    Log.d("HallScene.onMyGameBtnClick");
    if not self:isLogined() then return end
    
    local w,h = self.m_btn_bg:getSize();
    local anim = nil;
    if not self.m_btn_bg:checkAddProp(1) then
        self.m_btn_bg:removeProp(1);
    end
    if self.bottomType ~= BottomMenu.HALLTYPE then
        self.m_btn_bg:setVisible(true);
    end
    local sw,sh = self:getSize();
    local scale = sw*System.getLayoutScale()/System.getLayoutWidth();
    if self.bottomType == BottomMenu.OWNTYPE then
        self.m_own_btn_choose:setVisible(false);
        anim = self.m_btn_bg:addPropTranslateWithEasing(1,kAnimNormal,800,-1,"easeInOutBack","easeInOutBack",2*w*scale,-2*w*scale,0,0);
--        self.m_game_btn_choose:addPropTransparency(1,kAnimNormal,100,750,0,1);
    elseif self.bottomType == BottomMenu.FINDTYPE then
        self.m_find_btn_choose:setVisible(false);
        anim = self.m_btn_bg:addPropTranslateWithEasing(1,kAnimNormal,800,-1,"easeInOutBack","easeInOutBack",w*scale,-w*scale,0,0);
--        self.m_game_btn_choose:addPropTransparency(1,kAnimNormal,100,750,0,1);
    end

    if anim then
        anim:setEvent(self,function()
            self.m_game_btn_choose:setVisible(true);
            self.m_btn_bg:setVisible(false);
            if not self.m_btn_bg:checkAddProp(1) then
                self.m_btn_bg:removeProp(1);
            end
            delete(anim);
        end);
    end
    self.isFindClick = false;
    StateMachine.getInstance():changeState(States.Hall,StateMachine.STYPE_CUSTOM_WAIT);
end

BottomMenu.onMyFindBtnClick = function(self)
    Log.d("HallScene.onFindBtnClick");
    if not self:isLogined() then return end
    
    local w,h = self.m_btn_bg:getSize();
    local anim = nil;
    if not self.m_btn_bg:checkAddProp(1) then
        self.m_btn_bg:removeProp(1);
    end
    local sw,sh = self:getSize();
    local scale = sw*System.getLayoutScale()/System.getLayoutWidth();
    if self.bottomType ~= BottomMenu.FINDTYPE then
        self.m_btn_bg:setVisible(true);
    end   
    if self.bottomType == BottomMenu.OWNTYPE then
        self.m_own_btn_choose:setVisible(false);
        anim = self.m_btn_bg:addPropTranslateWithEasing(1,kAnimNormal,800,-1,"easeInOutBack",nil,2*w*scale,-w*scale,0,0);
--        self.m_find_btn_choose:addPropTransparency(1,kAnimNormal,100,750,0,1);
    elseif self.bottomType == BottomMenu.HALLTYPE then
        self.m_game_btn_choose:setVisible(false);
        anim = self.m_btn_bg:addPropTranslateWithEasing(1,kAnimNormal,800,-1,"easeInOutBack",nil,0,w*scale,0,0);
--        self.m_find_btn_choose:addPropTransparency(1,kAnimNormal,100,750,0,1);
    end

    if anim then
        anim:setEvent(self,function()
            self.m_btn_bg:setVisible(false);
            self.m_btn_bg:removeProp(1);
            self.m_find_btn_choose:setVisible(true);
            if not self.m_btn_bg:checkAddProp(1) then
                self.m_btn_bg:removeProp(1);
            end
            delete(anim);
        end);
    end
    self.isFindClick = true;
    if kPlatform == kPlatformIOS then
        --ios审核跳发现模块跳商城
        if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
            StateMachine.getInstance():pushState(States.findModel,StateMachine.STYPE_CUSTOM_WAIT);  
        else
            StateMachine.getInstance():pushState(States.Mall,StateMachine.STYPE_CUSTOM_WAIT);  
        end;
    else
        StateMachine.getInstance():pushState(States.findModel,StateMachine.STYPE_CUSTOM_WAIT);  
    end;
end

BottomMenu.onMyOwnBtnClick = function(self)
    Log.d("HallScene.onMyOwnBtnClick");
    if not self:isLogined() then return end
    self.m_own_btn_tip:setVisible(false);
    local w,h = self.m_btn_bg:getSize();
    local anim = nil;
    if not self.m_btn_bg:checkAddProp(1) then
        self.m_btn_bg:removeProp(1);
    end
    local sw,sh = self:getSize();
    local scale = sw*System.getLayoutScale()/System.getLayoutWidth();
    if self.bottomType ~= BottomMenu.OWNTYPE then
        self.m_btn_bg:setVisible(true);
    end 
    if self.bottomType == BottomMenu.FINDTYPE then
        self.m_find_btn_choose:setVisible(false);
        anim = self.m_btn_bg:addPropTranslateWithEasing(1,kAnimNormal,800,-1,"easeInOutBack",nil,w*scale,w*scale,0,0);
--        self.m_own_btn_choose:addPropTransparency(1,kAnimNormal,100,750,0,1);
    elseif self.bottomType == BottomMenu.HALLTYPE then
        self.m_game_btn_choose:setVisible(false);
        anim = self.m_btn_bg:addPropTranslateWithEasing(1,kAnimNormal,800,-1,"easeInOutBack",nil,0,2*w*scale,0,0);
--        self.m_own_btn_choose:addPropTransparency(1,kAnimNormal,100,750,0,1);
    end

    if anim then
        anim:setEvent(self,function()
            self.m_own_btn_choose:setVisible(true);
            self.m_btn_bg:setVisible(false);
            self.m_btn_bg:removeProp(1);
            if not self.m_btn_bg:checkAddProp(1) then
                self.m_btn_bg:removeProp(1);
            end
            delete(anim);
        end);
    end
    self.isFindClick = false;
    StateMachine.getInstance():pushState(States.ownModel,StateMachine.STYPE_CUSTOM_WAIT);
end

BottomMenu.setMyGameStatus = function(self)
    Log.d("HallScene.onMyGameBtnClick");
    self.m_game_btn_choose:setVisible(true);
    self.m_find_btn_choose:setVisible(false);
    self.m_own_btn_choose:setVisible(false);
    self.m_btn_bg:setVisible(false);
--    self.m_game_model_btn:getChildByName("choose_img"):setVisible(true);
--    self.m_find_model_btn:getChildByName("choose_img"):setVisible(false);
--    self.m_own_model_btn:getChildByName("choose_img"):setVisible(false);
end

BottomMenu.setMyFindStatus = function(self)
    Log.d("HallScene.onFindStatus");
    self.m_game_btn_choose:setVisible(false);
    self.m_find_btn_choose:setVisible(true);
    self.m_own_btn_choose:setVisible(false);
    self.m_btn_bg:setVisible(false);
--    self.m_game_model_btn:getChildByName("choose_img"):setVisible(false);
--    self.m_find_model_btn:getChildByName("choose_img"):setVisible(true);
--    self.m_own_model_btn:getChildByName("choose_img"):setVisible(false);
end

BottomMenu.setMyOwnStatus = function(self)
    Log.d("HallScene.onMyOwnBtnClick");
    self.m_game_btn_choose:setVisible(false);
    self.m_find_btn_choose:setVisible(false);
    self.m_own_btn_choose:setVisible(true);
    self.m_btn_bg:setVisible(false);
--    self.m_game_model_btn:getChildByName("choose_img"):setVisible(false);
--    self.m_find_model_btn:getChildByName("choose_img"):setVisible(false);
--    self.m_own_model_btn:getChildByName("choose_img"):setVisible(true);
end

BottomMenu.isLogined = function(self)
    if not self.m_handler then return false end

    if not BottomMenu.m_chioce_dialog then
        require("dialog/chioce_dialog");
        BottomMenu.m_chioce_dialog = new(ChioceDialog);
        BottomMenu.m_chioce_dialog:setLevel(1);
    end
    if not UserInfo.getInstance():isLogin() then
		local message = "请先登录...";
		BottomMenu.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE);
		BottomMenu.m_chioce_dialog:setMessage(message);
		BottomMenu.m_chioce_dialog:setPositiveListener(self.m_handler.m_controller,self.m_handler.m_controller.login);
		BottomMenu.m_chioce_dialog:setNegativeListener(nil,nil);
		BottomMenu.m_chioce_dialog:show();
		return false;
	end

	--Socket未登录上
	if not UserInfo.getInstance():getConnectHall() then
		local message = "请先连接游戏大厅...";
		BottomMenu.m_chioce_dialog:setMode(ChioceDialog.MODE_OK);
		BottomMenu.m_chioce_dialog:setMessage(message);
		BottomMenu.m_chioce_dialog:setPositiveListener(self.m_handler.m_controller,self.m_handler.m_controller.openHallSocket);
		BottomMenu.m_chioce_dialog:show();
		return false;
	end

	return true;
end

BottomMenu.removeOutWindow = function(self,typeMove,timer)
    if not self.m_root:checkAddProp(1) then
        self.m_root:removeProp(1);
    end
    local w,h = self:getSize();
    local anim = nil;
    local duration = timer.duration;
    local delay = timer.waitTime;
    if typeMove == 1 then
        anim = self.m_root:addPropTranslate(1,kAnimNormal,duration,delay,0,-w,nil,nil);
    elseif typeMove == 0 then
        self.m_root:setVisible(true);
        anim = self.m_root:addPropTranslate(1,kAnimNormal,duration,delay,-w,0,nil,nil);
    end

    if anim then
        anim:setEvent(self,function()
            if not self.m_root:checkAddProp(1) then
                self.m_root:removeProp(1);
            end
            if typeMove == 1 then
                self.m_root:setVisible(false);
            end
            delete(anim);
        end);
    end
end

BottomMenu.hideView = function(self,ret)
    self:setVisible(ret);
end

----------------------------------- config ------------------------------
BottomMenu.s_controlConfig = 
{
    [BottomMenu.s_controls.bottom_menu]              = {"bottom_menu"};
    [BottomMenu.s_controls.game_model_btn]           = {"bottom_menu","game_model_btn"};
    [BottomMenu.s_controls.find_model_btn]           = {"bottom_menu","find_model_btn"};
    [BottomMenu.s_controls.own_model_btn]            = {"bottom_menu","own_model_btn"};
    [BottomMenu.s_controls.game_model_btn]           = {"bottom_menu","game_model_btn"};
    [BottomMenu.s_controls.btn_bg]                   = {"bottom_menu","btn_bg"};
};

BottomMenu.s_controlFuncMap =
{
    [BottomMenu.s_controls.game_model_btn]               = BottomMenu.onMyGameBtnClick;
    [BottomMenu.s_controls.own_model_btn]                = BottomMenu.onMyOwnBtnClick;
    [BottomMenu.s_controls.find_model_btn]               = BottomMenu.onMyFindBtnClick;
};

BottomMenu.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.GetDailyList] = BottomMenu.onGetDailyListResponse;
    [HttpModule.s_cmds.GetNewDailyList] = BottomMenu.onGetNewDailyListResponse;
};

BottomMenu.onHttpRequestsCallBack = function(self,command,...)
	Log.i("BottomMenu.onHttpRequestsCallBack");
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self,...);
	end 
end