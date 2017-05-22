require(VIEW_PATH .. "exchange_qrcode_view")

-- 兑换码界面
ExchangeQRCodeDialog = class(ChessDialogScene, false)

ExchangeQRCodeDialog.ctor = function( self )
	super(self, exchange_qrcode_view)
	self.anim_dlg = AnimDialogFactory.createNormalAnim(self)
    EventDispatcher.getInstance():register(HttpModule.s_event, self, self.onHttpRequestsCallBack)

	self:initControl()
	self:initView()
end

ExchangeQRCodeDialog.dtor = function( self )
	self.anim_dlg:stopAnim()
    delete(self.mChoiceDialog)
    EventDispatcher.getInstance():unregister(HttpModule.s_event, self, self.onHttpRequestsCallBack)
end

ExchangeQRCodeDialog.show = function( self )
	self.super.show(self, self.anim_dlg.showAnim)
    self.error_txt:setText("")
    self.edit_code:setText()
    self.btn_get:setPickable(false)
    self.btn_get:setGray(true)
    self.btn_get:getChildByName("title"):setText("立即兑换")
end

ExchangeQRCodeDialog.dismiss = function( self )
	self.super.dismiss(self, self.anim_dlg.dismissAnim)
end

ExchangeQRCodeDialog.initControl = function( self )
	self.img_bg = self.m_root:getChildByName("img_bg")
	self.btn_close = self.img_bg:getChildByName("btn_close")
	self.btn_get = self.img_bg:getChildByName("btn_get")
	self.error_txt = self.img_bg:getChildByName("error_txt")

	self.edit_code = self.img_bg:getChildByName("edit_code")
	self.edit_code:setHintText("输入兑换码",165,145,125)
    self.edit_code:setOnTextChange(self,self.onEditCodeChange)
	local x, y = self.edit_code:getPos()
	local w, h = self.edit_code:getSize()
	self.btn_close:setOnClick(self, self.onCloseClick)
	self.btn_get:setOnClick(self, self.onGetClick)
    if PhpConfig.SID_IPHONE == kSid or PhpConfig.SID_IPAD == kSid or PhpConfig.SID_GOOGLEPLAY == kSid then
        self.img_bg:getChildByName("Text1"):setVisible(true)
        self.img_bg:getChildByName("Text2"):setText("博雅象棋")
        self.img_bg:getChildByName("Text2"):setPos(nil,108)
        self.img_bg:getChildByName("Text4"):setVisible(true)
        self.img_bg:getChildByName("Text4"):setPos(nil,198)
    else
        self.img_bg:getChildByName("Text1"):setVisible(false)
        self.img_bg:getChildByName("Text2"):setText("礼包兑换")
        self.img_bg:getChildByName("Text2"):setPos(nil,66)
        self.img_bg:getChildByName("Text4"):setVisible(true)
        self.img_bg:getChildByName("Text4"):setPos(nil,170)
    end
end

ExchangeQRCodeDialog.initView = function( self )
	--
end

ExchangeQRCodeDialog.onCloseClick = function( self )
	self:dismiss()
end

function ExchangeQRCodeDialog:onEditCodeChange(str)
    if str == "" or str == "" then
        self.error_txt:setText("兑换码输入不能为空")
        self.btn_get:setPickable(false)
        self.btn_get:setGray(true)
        return 
    end
    self.error_txt:setText("")
    self.btn_get:setPickable(true)
    self.btn_get:setGray(false)
end


ExchangeQRCodeDialog.onGetClick = function( self )
	local strText = self.edit_code:getText()
	local data = {}
	data.param = { code = strText }
	HttpModule.getInstance():execute(HttpModule.s_cmds.qrcode, data)
    self.btn_get:setPickable(false)
    self.btn_get:setGray(true)
    self.btn_get:getChildByName("title"):setText("兑换中...")
end

-- callback ---------------------------------------------
ExchangeQRCodeDialog.onHttpRequestsCallBack = function(self, command, ...)
	Log.i("ExchangeQRCodeDialog.onHttpRequestsCallBack")
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self, ...)
	end 
end

-- 兑换返回
ExchangeQRCodeDialog.onHttpQRCode = function( self, isSuccess, message )
    self.btn_get:setPickable(true)
    self.btn_get:setGray(false)
    self.btn_get:getChildByName("title"):setText("立即兑换")
	if not isSuccess then 
        if type(message) == 'table' and message.error then
            self.error_txt:setText(message.error:get_value() or "兑换码错误")
        else
            self.error_txt:setText("兑换码错误")
        end
        self.btn_get:setPickable(false)
        self.btn_get:setGray(true)
        return 
    end
    self.error_txt:setText("")
    if not self.mChoiceDialog then
        self.mChoiceDialog = new(ChioceDialog)
        self.mChoiceDialog:setMode(ChioceDialog.MODE_OK,"确定")
    end
    self.mChoiceDialog:setMessage(message.data.prize_text:get_value())
    self.mChoiceDialog:show()
	-- exchanged ok
	self:dismiss()
end

ExchangeQRCodeDialog.s_httpRequestsCallBackFuncMap = 
{
	[HttpModule.s_cmds.qrcode] = ExchangeQRCodeDialog.onHttpQRCode,
}







