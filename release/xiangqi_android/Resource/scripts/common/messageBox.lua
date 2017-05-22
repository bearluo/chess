require("gameBase/gameLayer");
require("common/uiFactory");
require(VIEW_PATH .. "messageBox")

MessageBox = class(GameLayer,false);

MessageBox.s_width = 670;
MessageBox.s_height = 253;
MessageBox.s_level = 15;

MessageBox.s_controls = 
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

MessageBox.s_controlConfig = 
{
	[MessageBox.s_controls.Title] = {"centerView" ,  "title"};
	[MessageBox.s_controls.TwoButtonView] = {"centerView" ,  "twoBtnsView"};
	[MessageBox.s_controls.SingleButtonView] = {"centerView" ,  "singleBtnView"};

	[MessageBox.s_controls.SingleButton] = {"centerView" ,  "singleBtnView","btn1"};

	[MessageBox.s_controls.ButtonOK] = {"centerView" ,  "twoBtnsView","btn2"};
	[MessageBox.s_controls.ButtonCancle] = {"centerView" ,  "twoBtnsView","btn1"};

	[MessageBox.s_controls.CloseButton] = {"centerView" ,  "closeBtn"};

	[MessageBox.s_controls.MainView] = {"centerView" ,  "mainView"};
	[MessageBox.s_controls.content_text] = {"centerView" ,  "mainView","content_text"};
	[MessageBox.s_controls.buy_ctx_text] = {"centerView" ,  "mainView","buy_ctx_text"};
	[MessageBox.s_controls.SingleButtonText] = {"centerView" ,  "singleBtnView","btn1","btn1Text"};
	[MessageBox.s_controls.ButtonOkText] = {"centerView" ,  "twoBtnsView","btn1","btn1Text"};
	[MessageBox.s_controls.ButtonCancleText] = {"centerView" ,  "twoBtnsView","btn2","btn2Text"};
	[MessageBox.s_controls.ButtonCancleText] = {"centerView" ,  "twoBtnsView","btn2","btn2Text"};
};

MessageBox.show = function(title, button1Text, button2Text, content, doNeedCloseBtn, okObj, okFunc, cancleObj, cancleFunc, closeObj, closeFunc)
	MessageBox.hide();
	MessageBox.s_instance = new(MessageBox,title, button1Text, button2Text,doNeedCloseBtn,content,false);
	MessageBox.s_instance:setCallbackFunc(okObj, okFunc, cancleObj, cancleFunc, closeObj, closeFunc);
	MessageBox.s_instance:addToRoot();
	MessageBox.s_instance:setFillParent(true,true);
end


MessageBox.showBuy = function(title, button1Text, button2Text, content, doNeedCloseBtn, okObj, okFunc, cancleObj, cancleFunc, closeObj, closeFun)
	MessageBox.hide();
	MessageBox.s_instance = new(MessageBox,title, button1Text, button2Text,doNeedCloseBtn,content,true);
	MessageBox.s_instance:setCallbackFunc(okObj, okFunc, cancleObj, cancleFunc, closeObj, closeFunc);
	MessageBox.s_instance:addToRoot();
	MessageBox.s_instance:setFillParent(true,true);
end

MessageBox.showUpdate = function(title, button1Text, button2Text, content, doNeedCloseBtn, okObj, okFunc,doNotNeedDelete)
	MessageBox.hide();
	MessageBox.s_instance = new(MessageBox,title, button1Text, button2Text,doNeedCloseBtn,content,false,doNotNeedDelete);
	MessageBox.s_instance:setCallbackFunc(okObj, okFunc, nil, nil, nil, nil);
	MessageBox.s_instance:addToRoot();
	MessageBox.s_instance:setFillParent(true,true);

	MessageBox.s_instance.doNotNeedDelete = doNotNeedDelete;
end

MessageBox.hide = function()
	delete(MessageBox.s_instance);
	MessageBox.s_instance = nil;
end

MessageBox.ctor = function(self, title, button1Text, button2Text, doNeedCloseBtn, content,isBuy)
	super(self,messageBox);
	self.m_root:setAlign(kAlignCenter);
	self:setLevel(MessageBox.s_level);
	
	self.m_ctrls = MessageBox.s_controls;

	self:getControl(self.m_ctrls.CloseButton):setVisible(doNeedCloseBtn);

	if button2Text then
		self:initTwoButtonsView(title, button1Text, button2Text);
	else
		self:initSingleButtonsView(title, button1Text);
	end

	if content  then
		if isBuy then
			self:getControl(self.m_ctrls.content_text):setVisible(false);
			self:getControl(self.m_ctrls.buy_ctx_text):setVisible(true);
			self:getControl(self.m_ctrls.buy_ctx_text):setText(content);
		else
			self:getControl(self.m_ctrls.content_text):setVisible(true);
			self:getControl(self.m_ctrls.buy_ctx_text):setVisible(false);			
			self:getControl(self.m_ctrls.content_text):setText(content);
		end

	end


	self:setEventTouch(self,MessageBox.onShadeBgClick);
	self:setEventDrag(self,MessageBox.onShadeBgClick);
end



MessageBox.setCallbackFunc = function(self,okObj,okFunc,cancleObj,cancleFunc,closeObj,closeFunc)
	self.m_okFunc = okFunc;
	self.m_okObj = okObj;
	self.m_cancleFunc = cancleFunc;
	self.m_cancleObj = cancleObj;
	self.m_closeFunc = closeFunc;
	self.m_closeObj = closeObj;
end


MessageBox.onShadeBgClick = function(self)
	--屏蔽作用
	-- Log.d("MessageBox.onShadeBgClick");
end

MessageBox.onSingleButtonClicked = function(self)
	if  not MessageBox.s_instance or  not MessageBox.s_instance.doNotNeedDelete then
		MessageBox.hide();
	end

	if self.m_okFunc then
		self.m_okFunc(self.m_okObj);
	end
end

MessageBox.onOkButtonClicked = function(self)
	Log.i("MessageBox.onOkButtonClicked ");

	MessageBox.hide();
	if self.m_okFunc then
		self.m_okFunc(self.m_okObj);
	end
end

MessageBox.onCancleButtonClicked = function(self)

	MessageBox.hide();
	if self.m_cancleFunc then
		self.m_cancleFunc(self.m_cancleObj);
	end
end

MessageBox.onCloseButtonClicked = function(self)
	MessageBox.hide();
	if self.m_closeFunc then
		self.m_closeFunc(self.m_closeObj);
	end
end

MessageBox.initTwoButtonsView = function(self, title, button1Text, button2Text)
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

MessageBox.initSingleButtonsView = function(self,title, button1Text)
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

MessageBox.setTexts = function(self,ctrls,texts)
	for k,v in ipairs(ctrls) do
		self:getControl(v):setVisible(true);
		self:getControl(v):setText(texts[k]);
	end
end

MessageBox.s_controlFuncMap = 
{
	[MessageBox.s_controls.SingleButton] = MessageBox.onSingleButtonClicked;
	[MessageBox.s_controls.ButtonOK] = MessageBox.onOkButtonClicked;
	[MessageBox.s_controls.ButtonCancle] = MessageBox.onCancleButtonClicked;
	[MessageBox.s_controls.CloseButton]= MessageBox.onCloseButtonClicked;
};