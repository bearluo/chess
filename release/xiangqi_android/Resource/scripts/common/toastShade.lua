require("core/object");
require("common/uiFactory");
require("common/animFactory");
require("util/toolKit");

ToastShade = class();

ToastShade.s_defaultShadeBg = "common/shade.png";
ToastShade.s_defaultLoadingBg = "common/loading.png";
-- ToastShade.s_defaultBoxBg = "common/loadingBg.png";
ToastShade.s_defaultBoxBg = "dialog/dialog_transparent_bg_2.png";
ToastShade.s_defaultCloseBtn = "dialog/btn_close_bg.png"

ToastShade.s_defaultBoxWidth = 400;
ToastShade.s_defaultBoxHeight = 100;

ToastShade.s_defaultLoadingWidth = 72;
ToastShade.s_defaultLoadingHeight = 72;

ToastShade.s_level = 50;
ToastShade.s_timer = 1500;
 
ToastShade.getInstance = function()
	if not ToastShade.s_instance then 
		ToastShade.s_instance = new(ToastShade);
	end
	return ToastShade.s_instance;
end

ToastShade.isVisible = function(self)
	return self.m_isPlayLoading;
end

ToastShade.ctor = function(self)
	self.m_boxWidth = ToastShade.s_defaultBoxWidth;
	self.m_boxHeight = ToastShade.s_defaultBoxHeight;
	self.m_level = ToastShade.s_level;
	self.m_shadeBgImg = ToastShade.s_defaultShadeBg;
	self.m_loadingBgImg = ToastShade.s_defaultLoadingBg;
	self.m_boxBgImg = ToastShade.s_defaultBoxBg;
end

ToastShade.dtor = function(self)
	self:stopTimer();
end

--------------------------------------------------------------------
ToastShade.setLevel = function(self , level)
	self.m_level = level or ToastShade.s_level;
end

ToastShade.setAllBg = function(self , shadeBgImg , loadingBgImg , boxBgImg)
	self.m_shadeBgImg = shadeBgImg or ToastShade.s_defaultShadeBg;
	self.m_loadingBgImg = loadingBgImg or ToastShade.s_defaultLoadingBg;
	self.m_boxBgImg = boxBgImg or ToastShade.s_defaultBoxBg;
end
ToastShade.setDefaultAllBg = function(self)
    self.m_shadeBgImg = ToastShade.s_defaultShadeBg;
    self.m_loadingBgImg = ToastShade.s_defaultLoadingBg;
    self.m_boxBgImg = ToastShade.s_defaultBoxBg;
end;
--subViewPos 和 loadingPos 是{x = 1 , y = 2}此种形式
--以位置为主,如果传入nil值 则会采用默认计算
ToastShade.setPosAndAlign = function(self , subViewPos , subViewAlign , loadingPos , loadingAlign)
	self.m_subViewPos = subViewPos;
	self.m_subViewAlign = subViewAlign or kAlignTopLeft;
	self.m_loadingPos = loadingPos;
	self.m_loadingAlign = loadingAlign or kAlignTopLeft;
end

ToastShade.play = function(self , subView , boxWidth , boxHeight , isPlayLoading , loadingWidth , loadingHeight , timer , needClose)
	self:releaseResourse();

    local w,h = subView:getSize();

	self.m_boxWidth = boxWidth or self.m_boxWidth or  ToastShade.s_defaultBoxWidth;
	self.m_boxHeight = boxHeight or self.m_boxHeight or  ToastShade.s_defaultBoxHeight;
    if self.m_boxWidth < w then 
        self.m_boxWidth = w + 100;
    end

    if self.m_boxHeight < h then 
        self.m_boxHeight = h + 50;
    end


	self.m_loadingWidth = loadingWidth  or ToastShade.s_defaultLoadingWidth;
	self.m_loadingHeight = loadingHeight or ToastShade.s_defaultLoadingHeight;

	self.m_isPlayLoading = isPlayLoading or (isPlayLoading == nil);
	self:createView(subView, needClose);
	

	--ToastShade.s_timer = timer or ToastShade.s_timer;
	self:startTimer(timer or ToastShade.s_timer);
end

-------------use only for login create account---------------
ToastShade.playAccount = function(self,account,boxWidth,boxHeight,timer)
	self:stopTimer();
	self.m_boxWidth = boxWidth or ToastShade.s_defaultBoxWidth;
	self.m_boxHeight = boxHeight or ToastShade.s_defaultBoxHeight;
	self.m_isPlayLoading = isPlayLoading or (isPlayLoading == nil);
	local text1 = UIFactory.createText("帐号",24,0,50,kAlignLeft,240,240,240,"");
	local text2 = UIFactory.createText(account,30,0,50,kAlignLeft,240,240,0,"");	
	local text3 = UIFactory.createText("已创建成功!",24,0,50,kAlignLeft,240,240,240,"");
	local text4 = UIFactory.createText("密码已通过短信发送给你!",24,0,50,kAlignLeft,240,240,0,"")
	local text5 = UIFactory.createText("正在登录...",30,200,50,kAlignLeft,240,240,240,"");
	self:createAccount(text1,text2,text3,text4,text5);
	self:startTimer(timer or ToastShade.s_timer);
end

ToastShade.createAccount = function(self,text1,text2,text3,text4,text5)
	self:load();
	self.m_boxBg:setSize(self.m_boxWidth , self.m_boxHeight);
	local node = new(Node);
	node:setAlign(kAlignTop);
	node:setSize(380,70);
	node:addChild(text1);
	text1:setAlign(kAlignLeft);
	node:addChild(text2);
	text2:setAlign(kAlignLeft);
	text2:setPos(55,nil);
	node:addChild(text3);
	text3:setAlign(kAlignRight);
	self.m_boxBg:addChild(node);
	text4:setAlign(kAlignCenter);
	self.m_boxBg:addChild(text4);
	text5:setAlign(kAlignBottom);
	text5:setPos(nil,20);
	self.m_boxBg:addChild(text5);
	self:createLoadingBg();
	self.m_loadingBg:setPos(50 ,20);
	self.m_loadingBg:setAlign(kAlignBottomLeft);
	self.m_loadingBg:setVisible(true);
end
-------------------------------------------------------------------------
ToastShade.stopTimer = function(self)
	self:resetData();
	self:releaseResourse();
end
------------------------------------------------------------------------------
ToastShade.load = function(self)
	local screenWidth = System.getScreenScaleWidth();
	local screenHeight = System.getScreenScaleHeight();
	self.m_root = new(Node);
	self.m_root:addToRoot();
	self.m_root:setLevel(self.m_level);
	self.m_root:setSize(screenWidth , screenHeight);

	self.m_shadeBg = new(Image , self.m_shadeBgImg);
	self.m_root:addChild(self.m_shadeBg);
	self.m_shadeBg:setFillParent(true , true);
	self.m_shadeBg:setEventTouch(self , self.onShadeBgTouch);
	self.m_shadeBg:setEventDrag(self,  self.onShadeBgTouch );

	self.m_boxBg = new(Image , self.m_boxBgImg , nil , nil , 50 , 50 , 0 , 0);
	self.m_boxBg:setSize(self.m_boxWidth , self.m_boxHeight);
	self.m_root:addChild(self.m_boxBg);
	self.m_boxBg:setAlign(kAlignCenter);
end

ToastShade.resetData = function(self)
	self.m_isPlayLoading = false;

	self.m_level = ToastShade.s_level;

	self.m_loadingPos = nil;
	self.m_subViewPos = nil;

	self.m_shadeBgImg = ToastShade.s_defaultShadeBg;
	self.m_loadingBgImg = ToastShade.s_defaultLoadingBg;
	self.m_boxBgImg = ToastShade.s_defaultBoxBg;
end

ToastShade.releaseResourse = function(self)
	delete(self.m_timer);
	self.m_timer = nil;

	delete(self.m_root);
	self.m_root = nil;

    self.m_isPlayLoading = false;
end

----------------------
ToastShade.createView = function(self , subView, needClose)
	self:load();
	if(subView) and (self.m_isPlayLoading) then
		self:createLoadingBg(needClose);
		self:createSubView(subView);

		self.m_subView:setAlign(kAlignLeft);
		self.m_subView:setPos( self.m_boxWidth/3 , nil);

		self.m_loadingBg:setAlign(kAlignLeft);
		local loadingW , _ = self.m_loadingBg:getSize();
		self.m_loadingBg:setPos( self.m_boxWidth/3 - loadingW - 15, nil);
		self.m_loadingBg:setVisible(true);

		self:setSubViewWithUserPos();
		self:setLoadingWithUserPos();

	elseif(subView) then
		self:createSubView(subView);
		self.m_subView:setAlign(kAlignCenter);
		self:setSubViewWithUserPos();
	elseif(self.m_isPlayLoading) then
		self:createLoadingBg(needClose);
		self.m_loadingBg:setAlign(kAlignCenter);
		self:setLoadingWithUserPos();
		self.m_loadingBg:setVisible(true);
	end
end

ToastShade.setSubViewWithUserPos = function(self)
	if(self.m_subViewPos) then
		self.m_subView:setAlign(self.m_subViewAlign);
		self.m_subView:setPos(self.m_subViewPos.x , self.m_subViewPos.y);
	end
end

ToastShade.setLoadingWithUserPos = function(self)
	if(self.m_loadingPos) then
		self.m_loadingBg:setAlign(self.m_loadingAlign);
		self.m_loadingBg:setPos(self.m_loadingPos.x , self.m_loadingPos.y);
	end
end

ToastShade.createLoadingBg = function(self, needClose)
	self.m_loadingBg = new(Image , self.m_loadingBgImg);
	self.m_loadingBg:setSize(self.m_loadingWidth , self.m_loadingHeight);
	self.m_boxBg:addChild(self.m_loadingBg);

    self.m_closeBtn = new(Button,ToastShade.s_defaultCloseBtn)
    self.m_closeBtn:setAlign(kAlignTopRight);
    self.m_closeBtn:setPos(3,3);
    self.m_boxBg:addChild(self.m_closeBtn);
    self.m_closeBtn:setOnClick(self,self.onHide);

	self.m_loadingBg:setVisible(false);
end

ToastShade.createSubView = function(self , subView)
	self.m_subView = subView;
	self.m_boxBg:addChild(subView);
end

ToastShade.startTimer = function(self,time)
    time = time or ToastShade.s_timer
	self.m_root:setVisible(true);
	if(self.m_isPlayLoading) then
		self.m_loadingBg:addPropRotate(0,kAnimRepeat,1000,0,0,-360,kCenterDrawing);
	end

	if self.m_timer then
		delete(self.m_timer);
		self.m_timer = nil;
	end
	self.m_timer = AnimFactory.createAnimInt(kAnimNormal,0,1,time);
	ToolKit.setDebugName(self.m_timer,"AnimInt|ToastShade.startTimer|m_timer");
	self.m_timer:setEvent(self,self.onTimer);
end

ToastShade.onTimer = function(self)
	self:stopTimer();
end

ToastShade.onHide = function(self)
    self.m_root:setVisible(false);
end

ToastShade.onShadeBgTouch = function(self , finger_action,x,y,drawing_id_first,drawing_id_current)
	--屏蔽后面的操作
end
