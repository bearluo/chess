require("gameBase/gameLayer");
require("common/uiFactory");
require(ViewPath .. "update_message_box")


UpdateMessageBox = class(GameLayer,false);

UpdateMessageBox.s_width = 670;
UpdateMessageBox.s_height = 253;
UpdateMessageBox.s_level = 15;

UpdateMessageBox.s_controls = 
{
	Title = 1;
	TwoButtonView = 2;
	SingleButtonView = 3;

	SingleButton = 4;

	ButtonOK = 5;
	ButtonCancle = 6;

	CloseButton = 7;

	MainView = 8;

	SingleButtonText = 9;
	ButtonOkText = 10;
	ButtonCancleText = 11;
	content_text = 12;
	buy_ctx_text = 13;
};

UpdateMessageBox.s_controlConfig = 
{
	[UpdateMessageBox.s_controls.Title] = {"centerView" ,  "title"};
	[UpdateMessageBox.s_controls.TwoButtonView] = {"centerView" ,  "twoBtnsView"};
	[UpdateMessageBox.s_controls.SingleButtonView] = {"centerView" ,  "singleBtnView"};

	[UpdateMessageBox.s_controls.SingleButton] = {"centerView" ,  "singleBtnView","btn1"};

	[UpdateMessageBox.s_controls.ButtonOK] = {"centerView" ,  "twoBtnsView","btn2"};
	[UpdateMessageBox.s_controls.ButtonCancle] = {"centerView" ,  "twoBtnsView","btn1"};

	[UpdateMessageBox.s_controls.CloseButton] = {"centerView" ,  "closeBtn"};

	[UpdateMessageBox.s_controls.MainView] = {"centerView" ,  "mainView"};
	[UpdateMessageBox.s_controls.content_text] = {"centerView" ,  "mainView","content_text"};
	[UpdateMessageBox.s_controls.buy_ctx_text] = {"centerView" ,  "mainView","buy_ctx_text"};
	[UpdateMessageBox.s_controls.SingleButtonText] = {"centerView" ,  "singleBtnView","btn1","btn1Text"};
	[UpdateMessageBox.s_controls.ButtonOkText] = {"centerView" ,  "twoBtnsView","btn1","btn1Text"};
	[UpdateMessageBox.s_controls.ButtonCancleText] = {"centerView" ,  "twoBtnsView","btn2","btn2Text"};
	[UpdateMessageBox.s_controls.ButtonCancleText] = {"centerView" ,  "twoBtnsView","btn2","btn2Text"};
};

UpdateMessageBox.showUpdate = function(title, button1Text, button2Text, content, doNeedCloseBtn, okObj, okFunc,doNotNeedDelete)
	UpdateMessageBox.hide();
	UpdateMessageBox.s_instance = new(UpdateMessageBox,title, button1Text, button2Text,doNeedCloseBtn,content,doNotNeedDelete);
	UpdateMessageBox.s_instance:setCallbackFunc(okObj, okFunc, nil, nil, nil, nil);
	UpdateMessageBox.s_instance:addToRoot();
	UpdateMessageBox.s_instance:setFillParent(true,true);

	UpdateMessageBox.s_instance.doNotNeedDelete = doNotNeedDelete;
end

UpdateMessageBox.hide = function()
	delete(UpdateMessageBox.s_instance);
	UpdateMessageBox.s_instance = nil;
end

UpdateMessageBox.ctor = function(self, title, button1Text, button2Text, doNeedCloseBtn, content)
	super(self,update_message_box);
	self.m_root:setAlign(kAlignCenter);
	self:setLevel(UpdateMessageBox.s_level);
	
	self.m_ctrls = UpdateMessageBox.s_controls;

	self:getControl(self.m_ctrls.CloseButton):setVisible(doNeedCloseBtn);

	if button2Text then
		self:initTwoButtonsView(title, button1Text, button2Text);
	else
		self:initSingleButtonsView(title, button1Text);
	end

	if content  then
		self:getControl(self.m_ctrls.content_text):setVisible(true);
		self:getControl(self.m_ctrls.buy_ctx_text):setVisible(false);			
		self:getControl(self.m_ctrls.content_text):setText(content);

	end


	self:setEventTouch(self,UpdateMessageBox.onShadeBgClick);
	self:setEventDrag(self,UpdateMessageBox.onShadeBgClick);
end



UpdateMessageBox.setCallbackFunc = function(self,okObj,okFunc,cancleObj,cancleFunc,closeObj,closeFunc)
	self.m_okFunc = okFunc;
	self.m_okObj = okObj;
	self.m_cancleFunc = cancleFunc;
	self.m_cancleObj = cancleObj;
	self.m_closeFunc = closeFunc;
	self.m_closeObj = closeObj;
end


UpdateMessageBox.onShadeBgClick = function(self)
	--屏蔽作用
	-- Log.d("UpdateMessageBox.onShadeBgClick");
end

UpdateMessageBox.onSingleButtonClicked = function(self)
	if  not UpdateMessageBox.s_instance or  not UpdateMessageBox.s_instance.doNotNeedDelete then
		UpdateMessageBox.hide();
	end

	if self.m_okFunc then
		self.m_okFunc(self.m_okObj);
	end
end

UpdateMessageBox.onOkButtonClicked = function(self)
	Log.i("UpdateMessageBox.onOkButtonClicked ");

	UpdateMessageBox.hide();
	if self.m_okFunc then
		self.m_okFunc(self.m_okObj);
	end
end

UpdateMessageBox.onCancleButtonClicked = function(self)

	UpdateMessageBox.hide();
	if self.m_cancleFunc then
		self.m_cancleFunc(self.m_cancleObj);
	end
end

UpdateMessageBox.onCloseButtonClicked = function(self)
	UpdateMessageBox.hide();
	if self.m_closeFunc then
		self.m_closeFunc(self.m_closeObj);
	end
end

UpdateMessageBox.initTwoButtonsView = function(self, title, button1Text, button2Text)
	self:getControl(self.m_ctrls.SingleButtonView):setVisible(false);
	self:getControl(self.m_ctrls.TwoButtonView):setVisible(true);

	local textCtrls = {
		self.m_ctrls.Title,
		self.m_ctrls.ButtonOkText,
		self.m_ctrls.ButtonCancleText,
	};

	local texts = {
		title,
		button1Text,
		button2Text
	};

	self:setTexts(textCtrls,texts);
end

UpdateMessageBox.initSingleButtonsView = function(self,title, button1Text)
	self:getControl(self.m_ctrls.SingleButtonView):setVisible(true);
	self:getControl(self.m_ctrls.TwoButtonView):setVisible(false);

	local textCtrls = {
		self.m_ctrls.Title,
		self.m_ctrls.SingleButtonText,
	};

	local texts = {
		title,
		button1Text,
	};

	self:setTexts(textCtrls,texts);
end

UpdateMessageBox.setTexts = function(self,ctrls,texts)
	for k,v in ipairs(ctrls) do
		self:getControl(v):setVisible(true);
		self:getControl(v):setText(texts[k]);
	end
end

UpdateMessageBox.s_controlFuncMap = 
{
	[UpdateMessageBox.s_controls.SingleButton] = UpdateMessageBox.onSingleButtonClicked;
	[UpdateMessageBox.s_controls.ButtonOK] = UpdateMessageBox.onOkButtonClicked;
	[UpdateMessageBox.s_controls.ButtonCancle] = UpdateMessageBox.onCancleButtonClicked;
	[UpdateMessageBox.s_controls.CloseButton]= UpdateMessageBox.onCloseButtonClicked;
};