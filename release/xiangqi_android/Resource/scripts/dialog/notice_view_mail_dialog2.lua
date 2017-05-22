require(VIEW_PATH .. "notice_view_mail_dialog_view2");
require(BASE_PATH.."chessDialogScene")
NoticeViewMailDialog2 = class(ChessDialogScene,false);

function NoticeViewMailDialog2:ctor()
    super(self,notice_view_mail_dialog_view2);
    self.anim_dlg = AnimDialogFactory.createNormalAnim(self)
    self.bg = self.m_root:getChildByName("bg");
    self.title = self.bg:getChildByName("title");
    self.contentView = self.bg:getChildByName("content_view");
    self.goods_icon = self.bg:getChildByName("goods_view"):getChildByName("goods_icon");
    
    self.btn1 = self.bg:getChildByName("btn_1");
    self.btn2 = self.bg:getChildByName("btn_2");
    self.btn3 = self.bg:getChildByName("btn_3");
    self.close_btn = self.bg:getChildByName("close_btn");
    self.btn1:setOnClick(self,self.dismiss);
    self.btn2:setOnClick(self,self.onClick);
    self.btn3:setOnClick(self,self.dismiss);
    self.close_btn:setOnClick(self,self.dismiss);
end

function NoticeViewMailDialog2:dtor()
    
end

function NoticeViewMailDialog2:show(params)
    if not params or type(params) ~= "table" then return end
    self.params = params;
    self:createRichText(params.mail_text);
    self:initByModelType(params);
    self.title:setText(params.mail_title);
    self.super.show(self, self.anim_dlg.showAnim)
    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
	EventDispatcher.getInstance():register(Event.Call,self,self.onNativeCallDone);
end

function NoticeViewMailDialog2:dismiss()
    self.super.dismiss(self, self.anim_dlg.dismissAnim)
    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpRequestsCallBack);
	EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeCallDone);
end

function NoticeViewMailDialog2:onClick()
    if self.mClickTime and os.time() - self.mClickTime < 1 then return end
    self.mClickTime = os.time()
    local modelType = self.params.tpl_type or kMailTplDefault;
    if modelType == kMailTplGoodPay then
        self:pay()
    elseif modelType == kMailTplGoodExchange then
        self:exchange()
    end
end

function NoticeViewMailDialog2:createRichText(str)
    delete(self.richText);
    local w,h = self.contentView:getSize();
    self.richText = new(RichText,str, w, h, kAlignTopLeft, "", 28, 80, 80, 80, true,5);
    self.contentView:addChild(self.richText);
end
--kMailTplDefault = '1'; --消息模板。只有关闭
--kMailTplAction = '2'; --有动作。动作按钮的文本由action_text指定
--kMailTplJump = '3'; --指定跳转
function NoticeViewMailDialog2:initByModelType(params)
    local modelType = params.tpl_type or kMailTplDefault;
    local isOperate = tonumber(params.is_operate) or 0;
    self.btn1:setVisible(false);
    self.btn2:setVisible(false);
    self.btn2:setPickable(true);
    self.btn2:setGray(false);
    self.btn3:setVisible(false);
    
    local other_data = self.params.other_data;
    local goods

    if modelType == kMailTplGoodPay then
        self.btn2:setVisible(true);
        self.btn2:getChildByName("btn_text"):setText(params.button_text or "知道了");
        if isOperate == 1 then
            self.btn2:setPickable(false);
            self.btn2:setGray(true);
        end
        if type(other_data) == "table" and other_data.goods_id then
            goods = MallData.getInstance():getGoodsById(other_data.goods_id)
        end
        if goods then
            self.goods_icon:setFile("mall/" .. goods.imgurl .. ".png")
            if self.goods_icon.m_res then
                local w,h = self.goods_icon.m_res:getWidth(),self.goods_icon.m_res:getHeight()
                self.goods_icon:setSize(w,h)
            end
        end
    elseif modelType == kMailTplGoodExchange then
        self.btn2:setVisible(true);
        self.btn2:getChildByName("btn_text"):setText(params.button_text or "知道了");
        if isOperate == 1 then
            self.btn2:setPickable(false);
            self.btn2:setGray(true);
        end
        if type(other_data) == "table" and other_data.goods_id then
            goods = MallData.getInstance():getPropById(other_data.goods_id)
        end
        if goods then
            self.goods_icon:setFile("mall/" .. goods.imgurl .. ".png")
            if self.goods_icon.m_res then
                local w,h = self.goods_icon.m_res:getWidth(),self.goods_icon.m_res:getHeight()
                self.goods_icon:setSize(w,h)
            end
        end
    end
end

function NoticeViewMailDialog2:pay()
    local payInterface = PayUtil.getPayInstance(PayUtil.s_defaultType);
    local other_data = self.params.other_data;
    if type(other_data) == "table" and other_data.goods_id then
        local goods = MallData.getInstance():getGoodsById(other_data.goods_id)
        if goods then
            local payData = {}
            payData.pay_scene = PayUtil.s_pay_scene.mail_recommend
            payData.saleToken = other_data.sale_token
		    payInterface:createOrder(goods, other_data.pmode, payData);
        else
            if kPlatform == kPlatformIOS then
                StateMachine.getInstance():pushState(States.Mall,StateMachine.STYPE_CUSTOM_WAIT)
            end
        end
    end
end

function NoticeViewMailDialog2:exchange()
    local payInterface = PayUtil.getPayInstance(PayUtil.s_payType.Exchange);
    local other_data = self.params.other_data;
    if type(other_data) == "table" and other_data.goods_id then
        local goods = MallData.getInstance():getPropById(other_data.goods_id)
        if goods then
		    payInterface.pay(goods,other_data.sale_token);
        end
    end
end


function NoticeViewMailDialog2:onHttpRequestsCallBack(command,...)
	Log.i("NoticeViewMailDialog2.onHttpRequestsCallBack");
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self,...);
	end 
end

function NoticeViewMailDialog2:onUserMailAction(isSuccess,message)
    if HttpModule.explainPHPMessage(isSuccess,message,"操作失败") then
        return ;
    end

    if message.data.mail_id:get_value() == self.params.id then
        self:dismiss();
        self.params.is_operate = 1;
    end
end

function NoticeViewMailDialog2:exchangePropCallBack(isSuccess,message)
    if not isSuccess then
        return ;
    end

    if message.data.mail_id:get_value() == tonumber(self.params.id) then
        self:dismiss();
        self.params.is_operate = 1;
    end
end


NoticeViewMailDialog2.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.UserMailAction]  = NoticeViewMailDialog2.onUserMailAction;
    [HttpModule.s_cmds.exchangeProp]    = NoticeViewMailDialog2.exchangePropCallBack;
}


function NoticeViewMailDialog2.onPaySuccess(self)
    self.params.is_operate = 1;
    self:dismiss()
end

function NoticeViewMailDialog2.onPayFailed(self)
    self.params.is_operate = 0;
    self:dismiss()
end

NoticeViewMailDialog2.onNativeCallDone = function(self ,param , ...)
	if self.s_nativeEventFuncMap[param] then
		self.s_nativeEventFuncMap[param](self,...);
	end
end


NoticeViewMailDialog2.s_nativeEventFuncMap = {
    [kPaySuccess]                   = NoticeViewMailDialog2.onPaySuccess;
    [kPayFailed]                    = NoticeViewMailDialog2.onPayFailed;
};