--region BottomMenu.lua
--Author : BearLuo
--Date   : 2015/4/20

require(VIEW_PATH.."bottom_menu")
require("chess/util/statisticsManager");
require("dialog/chioce_dialog");

BottomMenu = class(GameLayer,false);

BottomMenu.HALLTYPE         = 1;
BottomMenu.FINDTYPE         = 2;
BottomMenu.OWNTYPE          = 3;
BottomMenu.MALLTYPE         = 4;
BottomMenu.FRIENDSTYPE      = 5;
BottomMenu.SETTYPE          = 6;

BottomMenu.s_controls = 
{
    bottom_menu             = 1;
    btn_bg                  = 2;
};

BottomMenu.s_countEvent = 
{
    BOTTOM_MENU_HALL_CLICK;
    BOTTOM_MENU_FIND_CLICK;
    BOTTOM_MENU_OWN_CLICK;
    BOTTOM_MENU_MALL_CLICK;
    BOTTOM_MENU_FRIEND_CLICK;
}

BottomMenu.ctor = function(self)
    super(self,bottom_menu);
    self:setLevel(1);
    self:setFillParent(true,true);
    self.m_ctrls =  BottomMenu.s_controls;
    self.mBottomMenu = self:findViewById(self.m_ctrls.bottom_menu);
    self.mBtnBg = self:findViewById(self.m_ctrls.btn_bg);
    self.mBtnBg:setFile("common/button/tab_chose.png")
    self:createBtn();
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
function BottomMenu.setHandler(self,handler,bottomType)
    self.m_handler = handler;
    self.bottomType = bottomType;
    if self.bottomType == BottomMenu.OWNTYPE and self.mBtnTabMap[BottomMenu.OWNTYPE] then
        self.mBtnTabMap[BottomMenu.OWNTYPE]:setTipsVisible(false)
    end
    self:setBtnStatus(self.bottomType);
end

function BottomMenu.setOwnBtnTipVisible(self)
    if self.bottomType ~= BottomMenu.OWNTYPE and self.mBtnTabMap[BottomMenu.OWNTYPE] then
        if kPlatform == kPlatformIOS then
            if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
                self.mBtnTabMap[BottomMenu.OWNTYPE]:setTipsVisible(true)
            else
                self.mBtnTabMap[BottomMenu.OWNTYPE]:setTipsVisible(false)
            end
        else
            self.mBtnTabMap[BottomMenu.OWNTYPE]:setTipsVisible(true)
        end
    end
end

function BottomMenu.setFriendsBtnTipVisible(self)
    if self.bottomType ~= BottomMenu.FRIENDSTYPE and self.mBtnTabMap[BottomMenu.FRIENDSTYPE] then
        if kPlatform == kPlatformIOS then
            if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
                self.mBtnTabMap[BottomMenu.FRIENDSTYPE]:setTipsVisible(true)
            else
                self.mBtnTabMap[BottomMenu.FRIENDSTYPE]:setTipsVisible(false)
            end
        else
            self.mBtnTabMap[BottomMenu.FRIENDSTYPE]:setTipsVisible(true)
        end
    end
end

function BottomMenu.reset(self)
    local w,h = self:getSize();
    if kPlatform == kPlatformIOS then    
        if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
            BottomMenu.s_btn_sort = {
                BottomMenu.MALLTYPE,
                BottomMenu.FRIENDSTYPE,
                BottomMenu.HALLTYPE,
                BottomMenu.FINDTYPE,
                BottomMenu.OWNTYPE,
            }
        else
            BottomMenu.s_btn_sort = {
                BottomMenu.MALLTYPE,
                BottomMenu.FRIENDSTYPE,
                BottomMenu.HALLTYPE,
                BottomMenu.OWNTYPE,
            }
        end
    else
        BottomMenu.s_btn_sort = {
            BottomMenu.MALLTYPE,
            BottomMenu.FRIENDSTYPE,
            BottomMenu.HALLTYPE,
            BottomMenu.FINDTYPE,
            BottomMenu.OWNTYPE,
        }
    end
    self:createBtn();
end

BottomMenu.onResume = function(self,parent_root,needMove)
    if parent_root then
        self.m_parent_root = parent_root;
        self.m_parent_root:addChild(self);
    end
    self:setPickable(true);
    self:hideView(true);
    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
end

BottomMenu.onPause = function(self)
    if self.m_parent then
        self.m_parent:removeChild(self);
    end
    self:setPickable(false);

    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpRequestsCallBack);

end

BottomMenu.dtor = function(self)
    Log.e("BottomMenu.dtor");
end
function BottomMenu.createBtn(self,sort)
    self.mSelectedBtn = nil;
    self.mBtnBg:setVisible(false);
    if type(self.mBtnTab) == "table" then
        for _,btn in pairs(self.mBtnTab) do
            delete(btn);
        end
    end
    sort = sort or BottomMenu.s_btn_sort;
    self.mBtnTab = {};
    self.mBtnTabMap = {};
    for i,mType in ipairs(sort) do
        local config = BottomMenu.s_type_config[mType];
        if config then
            local btn = new(BottomMenuBtn,i,config,mType,self)
            self.mBottomMenu:addChild(btn);
            table.insert(self.mBtnTab,btn);
            self.mBtnTabMap[mType] = btn;
        end
    end
    local cnt = #self.mBtnTab;
    if cnt > 0 then
        local w,h = self.mBottomMenu:getSize();
        local btnW = w/cnt;
        self.mBtnBg:setSize(btnW);
        for i,btn in ipairs(self.mBtnTab) do
            local x = (i-1) * btnW;
            btn:setSize(btnW,h);
            btn:setPos(x,0);
        end
    end

end

function BottomMenu.setBtnStatus(self,btnType)
    Log.d("BottomMenu.setBtnStatus :" .. (btnType or "nil"));
    if self.mSelectedBtn and self.mSelectedBtn == self.mBtnTabMap[btnType] then return end
    self.mBtnBg:setVisible(false);
    self.mSelectedBtn = nil;
    if self.mBtnTab and #self.mBtnTab > 0 then
        for i,btn in ipairs(self.mBtnTab) do
            if btn:getBottomMenuBtnType() == btnType then
                btn:setChosed(true);
                local x,y = btn:getPos();
                self.mBtnBg:setVisible(true);
                self.mBtnBg:setPos(x);
                self.mSelectedBtn = btn;
                self.mBtnBg:removeProp(1);
            else
                btn:setChosed(false);
            end
        end
    end
end

BottomMenu.isLogined = function(self)
    if not self.m_handler then return false end

    if not BottomMenu.m_chioce_dialog then
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
        anim = self.m_root:addPropTranslate(1,kAnimNormal,duration,delay,w,0,nil,nil);
    end

    if anim then
        anim:setEvent(self,function()
            if not self.m_root:checkAddProp(1) then
                self.m_root:removeProp(1);
            end
            delete(anim);
        end);
    end
end

BottomMenu.removeInWindow = function(self,typeMove,timer)
    if not self.m_root:checkAddProp(1) then
        self.m_root:removeProp(1);
    end
    local w,h = self:getSize();
    local anim = nil;
    local duration = timer.duration;
    local delay = timer.waitTime;
    if typeMove == 1 then
        anim = self.m_root:addPropTranslate(1,kAnimNormal,duration,delay,0,w,nil,nil);
    elseif typeMove == 0 then
        anim = self.m_root:addPropTranslate(1,kAnimNormal,duration,delay,-w,0,nil,nil);
    end

    if anim then
        anim:setEvent(self,function()
            if not self.m_root:checkAddProp(1) then
                self.m_root:removeProp(1);
            end
            delete(anim);
        end);
    end
end

BottomMenu.hideView = function(self,ret)
    self:setVisible(ret);
end

function BottomMenu.checkStateSort(self,oldState,newState)
    if type(self.mBtnTab) ~= "table" or #self.mBtnTab == 0 then return end 
    local oldBtn = nil;
    local newBtn = nil;
    for i,btn in ipairs(self.mBtnTab) do
        if btn:getStates() == oldState then
            oldBtn = btn;
        end
        if btn:getStates() == newState then
            newBtn = btn;
        end
    end

    if not oldBtn or not newBtn then return false end
    return oldBtn:getBottomMenuBtnSort() > newBtn:getBottomMenuBtnSort();
end

function BottomMenu.checkState(self,newState)
    if type(self.mBtnTab) ~= "table" or #self.mBtnTab == 0 then return end 
    local newBtn = nil;
    for i,btn in ipairs(self.mBtnTab) do
        if btn:getStates() == newState then
            newBtn = btn;
        end
    end
    return newBtn ~= nil;
end

function BottomMenu.onBottomMenuBtnClick(self,bottomBtn)
    if not self:isLogined() then return end
    if bottomBtn and bottomBtn.mBottomMenuType then
        StatisticsManager.getInstance():onCountToUM(BottomMenu.s_countEvent[bottomBtn.mBottomMenuType]);
    end
    if self.mSelectedBtn == bottomBtn then return end
    if self.mSelectedBtn then
        local sw,sh             = self:getSize();
        local x,y               = self.mBtnBg:getPos();
        local scale             = sw*System.getLayoutScale()/System.getLayoutWidth();
        local startX,startY     = self.mSelectedBtn:getPos();
        local endX,endY         = bottomBtn:getPos();
        self.mBtnBg:setPos(startX);
        
        self.mSelectedBtn:setChosed(false);
        self.mSelectedBtn       = bottomBtn;

        self.mBtnBg:removeProp(1);
        self.mEaseInOutBackAnim = self.mBtnBg:addPropTranslateWithEasing(1,kAnimNormal,600,-1,"easeInOutBack","easeInOutBack",0,(endX-startX)*scale,0,0);
        self.mEaseInOutBackAnim:setEvent(self,function()
            self.mBtnBg:removeProp(1);
            self.mBtnBg:setPos(endX);
            bottomBtn:setChosed(true);
        end);
    else
        self:setBtnStatus(bottomBtn:getBottomMenuBtnType());
    end
    if StatesMap[bottomBtn:getStates()] then
        if bottomBtn:getStates() == States.Hall then
            StateMachine.getInstance():changeState(States.Hall,StateMachine.STYPE_CUSTOM_WAIT);
        else
            StateMachine.getInstance():pushState(bottomBtn:getStates(),StateMachine.STYPE_CUSTOM_WAIT);
        end
    end
end

----------------------------------- config ------------------------------
BottomMenu.s_controlConfig = 
{
    [BottomMenu.s_controls.bottom_menu]              = {"bottom_menu"};
    [BottomMenu.s_controls.btn_bg]                   = {"bottom_menu","btn_bg"};
};

BottomMenu.s_controlFuncMap =
{
};

BottomMenu.s_httpRequestsCallBackFuncMap  = {
};

BottomMenu.onHttpRequestsCallBack = function(self,command,...)
	Log.i("BottomMenu.onHttpRequestsCallBack");
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self,...);
	end 
end
BottomMenu.HALLTYPE         = 1;
BottomMenu.FINDTYPE         = 2;
BottomMenu.OWNTYPE          = 3;
BottomMenu.MALLTYPE         = 4;
BottomMenu.FRIENDSTYPE      = 5;
BottomMenu.SETTYPE          = 6;

BottomMenu.s_btn_sort = {
    BottomMenu.MALLTYPE,
    BottomMenu.FRIENDSTYPE,
    BottomMenu.HALLTYPE,
    BottomMenu.OWNTYPE,
}

BottomMenu.s_type_config = {};
BottomMenu.s_type_config[BottomMenu.HALLTYPE] = {
    ["chose_icon"]      = "hall/game_chose.png";
    ["normal_icon"]     = "hall/game_normal.png";
    ["click_event"]     = BottomMenu.onBottomMenuBtnClick;
    ["states"]          = States.Hall;
};
BottomMenu.s_type_config[BottomMenu.FINDTYPE] = {
    ["chose_icon"]      = "hall/find_chose.png";
    ["normal_icon"]     = "hall/find_normal.png";
    ["click_event"]     = BottomMenu.onBottomMenuBtnClick;
    ["states"]          = States.findModel;
};
BottomMenu.s_type_config[BottomMenu.OWNTYPE] = {
    ["chose_icon"]      = "hall/own_chose.png";
    ["normal_icon"]     = "hall/own_normal.png";
    ["click_event"]     = BottomMenu.onBottomMenuBtnClick;
    ["states"]          = States.ownModel;
};
BottomMenu.s_type_config[BottomMenu.MALLTYPE] = {
    ["chose_icon"]      = "hall/mall_chose.png";
    ["normal_icon"]     = "hall/mall_normal.png";
    ["click_event"]     = BottomMenu.onBottomMenuBtnClick;
    ["states"]          = States.Mall;
};
BottomMenu.s_type_config[BottomMenu.FRIENDSTYPE] = {
    ["chose_icon"]      = "hall/relation_chose.png";
    ["normal_icon"]     = "hall/relation_normal.png";
    ["click_event"]     = BottomMenu.onBottomMenuBtnClick;
    ["states"]          = States.Friends;
    
};

BottomMenuBtn = class(Button,false);

function BottomMenuBtn.ctor(self,sort,config,btnType,handler)
    super(self, "drawable/blank.png");
    self.mSort              = sort;
    self.mConfig            = config;
    self.mBottomMenuType    = btnType;
    self.mHandler           = handler;
    self.mNormalIcon        = new(Image,config.normal_icon);
    self.mChoseIcon        = new(Image,config.chose_icon);
    self.mTipsIcon          = new(Image,"dailytask/redPoint.png");
    self.mLeftLineIcon      = new(Image,"common/line_2.png");
    self.mRightLineIcon     = new(Image,"common/line_2.png");

    self.mNormalIcon:setAlign(kAlignBottom);
    self.mChoseIcon:setAlign(kAlignBottom);
    self.mTipsIcon:setAlign(kAlignTopRight);
    self.mLeftLineIcon:setAlign(kAlignBottomLeft);
    self.mRightLineIcon:setAlign(kAlignBottomRight);
    self.mTipsIcon:setPos(21,42);
    self.mLeftLineIcon:setPos(-1,0);
    self.mRightLineIcon:setPos(-1,0);
    self.mLeftLineIcon:setSize(2);
    self.mRightLineIcon:setSize(2);
    self.mNormalIcon:setVisible(true);
    self.mChoseIcon:setVisible(false);
    self.mTipsIcon:setVisible(false);
    self:addChild(self.mNormalIcon);
    self:addChild(self.mChoseIcon);
    self:addChild(self.mTipsIcon);
    self:addChild(self.mLeftLineIcon);
    self:addChild(self.mRightLineIcon);
    self:setOnClick(self,self.onBottomMenuBtnClick);
end

function BottomMenuBtn.setChosed(self,isChosed)
    self.mNormalIcon:setVisible(not isChosed);
    self.mChoseIcon:setVisible(isChosed);
end

function BottomMenuBtn.setTipsVisible(self,isVisible)
    self.mTipsIcon:setVisible(isVisible);
end

function BottomMenuBtn.getBottomMenuBtnType(self)
    return self.mBottomMenuType or 0;
end

function BottomMenuBtn.getStates(self)
    return self.mConfig and self.mConfig.states;
end
function BottomMenuBtn.getBottomMenuBtnSort(self)
    return self.mSort or 0;
end

function BottomMenuBtn.onBottomMenuBtnClick(self)
    local event = self.mConfig and self.mConfig.click_event;
    self:setTipsVisible(false);
    if type(event) == "function" then
        event(self.mHandler,self);
    end
end