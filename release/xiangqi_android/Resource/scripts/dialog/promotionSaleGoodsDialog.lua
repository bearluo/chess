
require(VIEW_PATH .. "promotion_sale_goods_dialog_view");
require(BASE_PATH.."chessDialogScene");
PromotionSaleGoodsDialog = class(ChessDialogScene,false);

PromotionSaleGoodsDialog.ctor = function(self)
    super(self,promotion_sale_goods_dialog_view);

    self.m_root:getChildByName("mask"):setTransparency(0.95)
    self.mBg = self.m_root:getChildByName("bg")
    self.mBg:setEventTouch(self,function()end)
    self.mConfirmBtn = self.mBg:getChildByName("confirm_btn")
    self.mConfirmBtn:setOnClick(self,self.sure)
    self.mTime = self.mBg:getChildByName("time")
    self.mGoods1 = self.mBg:getChildByName("goods_1")
    self.mGoods1Txt = self.mBg:getChildByName("goods_1_txt")
    self.mGoods2 = self.mBg:getChildByName("goods_2")
    self.mGoods2Txt = self.mBg:getChildByName("goods_2_txt")
    self:setShieldClick(self,self.dismiss)
    self:setNeedMask(false)
end

PromotionSaleGoodsDialog.dtor = function(self)
end

PromotionSaleGoodsDialog.show = function(self)
    self.super.show(self)
    self:startTimer()
	EventDispatcher.getInstance():register(Event.Call,self,self.onNativeCallDone);
end

PromotionSaleGoodsDialog.dismiss = function(self)
    self.super.dismiss(self)
    self:stopTimer()
	EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeCallDone);
end

function PromotionSaleGoodsDialog:setData(data)
    if type(data) ~= "table" then return end
    self.mData = data
    self.mConfirmBtn:getChildByName("txt"):setText(data.text)
    -- 安全处理
    if type(data.gift_pack) ~= "table" then data.gift_pack = {} end
    local gift_pack = data.gift_pack[1] or {}
    local data1,data2
    local goods1 = MallData.getInstance():getGoodsById(self.mData.good_id)
    if goods1 then
        data1 = {}
        data1.name = goods1.name or ""
        data1.iconFile = MallShopItem.ICON_PRE .. (goods1.imgurl or "") .. ".png"
    end

    -- 因为数据不一致 这里对 数据做提取
    if gift_pack then
        data2 = {}
        data2.name = gift_pack.goods_name or ""
        data2.iconFile = MallShopItem.ICON_PRE .. (gift_pack.goods_img or "") .. ".png"
    end
    local needRefreshMallData = false
    if data1 then
        self.mGoods1:removeAllChildren()
        local icon = new(Image,data1.iconFile)
        icon:setAlign(kAlignCenter)
        self.mGoods1:addChild(icon)
        self.mGoods1Txt:setText(data1.name )
    else
        needRefreshMallData = true
    end

    if data2 then
        self.mGoods2:removeAllChildren()
        local icon = new(Image,data2.iconFile)
        icon:setAlign(kAlignCenter)
        self.mGoods2:addChild(icon)
        self.mGoods2Txt:setText(data2.name)
    end
    if needRefreshMallData then
        MallData.getInstance():sendGetPropList()
        MallData.getInstance():sendGetShopInfo()
    end
    self:promotionSaleGoodsCountDown()
end

function PromotionSaleGoodsDialog:startTimer()
    TimerHelper.registerSecondEvent(self,self.promotionSaleGoodsCountDown)
end

function PromotionSaleGoodsDialog:promotionSaleGoodsCountDown()
    if not self.mData then return end
    local data = self.mData
    if data and tonumber(data.endTime) then
        local text = self.mTime
        local countDownTime = tonumber(data.endTime) - os.time()
        if countDownTime > 0 then
            text:setText( string.format("活动剩余时间:%s",ToolKit.skipTime(countDownTime)))
        else
            self:stopTimer()
        end
    end
end

function PromotionSaleGoodsDialog:stopTimer()
    TimerHelper.unregisterSecondEvent(self,self.promotionSaleGoodsCountDown)
end

PromotionSaleGoodsDialog.sure = function(self)
    if not self.mData then return end
    if self.mSureTime and os.time() - self.mSureTime < 1 then return end

    self.mSureTime = os.time()
    local goods = MallData.getInstance():getGoodsById(self.mData.good_id)
    if goods then
        local payInterface = PayUtil.getPayInstance(PayUtil.s_defaultType)
        local pay_dialog = payInterface:buy(goods);
        PayDialog.getInstance():payOrderFirst()
    end
    local params = {}
    params.type = 3 -- 上报下单
	HttpModule.getInstance():execute(HttpModule.s_cmds.IndexStatisticGiftInfo,params)
--    self:onPaySuccess()
end

function PromotionSaleGoodsDialog.onPaySuccess(self)
    self.mData.status = 0
    if self.mPaySuccessCallBack and type(self.mPaySuccessCallBack.func) == "function" then
        self.mPaySuccessCallBack.func(self.mPaySuccessCallBack.obj)
    end
    self:dismiss()
end

function PromotionSaleGoodsDialog:setPaySuccessCallBack(obj,func)
    self.mPaySuccessCallBack = {}
    self.mPaySuccessCallBack.obj = obj
    self.mPaySuccessCallBack.func = func
end

PromotionSaleGoodsDialog.onNativeCallDone = function(self ,param , ...)
	if self.s_nativeEventFuncMap[param] then
		self.s_nativeEventFuncMap[param](self,...);
	end
end


PromotionSaleGoodsDialog.s_nativeEventFuncMap = {
    [kPaySuccess]                   = PromotionSaleGoodsDialog.onPaySuccess;
    [kPayFailed]                    = PromotionSaleGoodsDialog.onPayFailed;
    [kDeliverIOSProduct]            = PromotionSaleGoodsDialog.onPaySuccess;
};