require(VIEW_PATH .. "pay_dialog_view");
require(BASE_PATH.."chessDialogScene");
require("ui/scrollViewEx");

PayDialog = class(ChessDialogScene,false)

if kPlatform == "ios" then
    PayDialog.pay_mode_recommend = -1; -- 推荐支付
    PayDialog.pay_mode_appstore = 99;  -- 苹果支付;
    PayDialog.pay_mode_weixin = 463;   -- ios微信
    PayDialog.pay_mode_ali = 620;      -- 支付宝
else
    PayDialog.pay_mode_recommend = -1; -- 推荐支付
    PayDialog.pay_mode_mo9 = 29 ;    --mo9;
    PayDialog.pay_mode_union = 198;   --银联;
    PayDialog.pay_mode_weixin = 431; -- 微信
    PayDialog.pay_mode_card = 35;    --话付宝;
    PayDialog.pay_mode_sms = 15 ;    -- 千尺
    PayDialog.pay_mode_yee = 14;     --易宝;
    PayDialog.pay_mode_tenpay = 33;  --财付通;
    PayDialog.pay_mode_huawei = 110; --华为;
    PayDialog.pay_mode_ali = 265;    --支付宝
    PayDialog.mm_mode = 218;                 --移动MM弱网
    PayDialog.wo_shop_mode = 109;            --联通wo商店
    PayDialog.dianxin_aiyouxi_mode = 34      --电信爱游戏
end;

PayDialog.s_controls = 
{
    pay_content_view    = 1;
    goods_view_handle   = 2;
    pay_pmode_group     = 3;
    close_btn           = 4;
    title               = 5;
};

PayDialog.s_controlConfig = 
{
    [PayDialog.s_controls.pay_content_view] = {"pay_content_view"};
    [PayDialog.s_controls.goods_view_handle]= {"pay_content_view","goods_view_handle"};
    [PayDialog.s_controls.pay_pmode_group]  = {"pay_content_view","pay_pmode_group"};
    [PayDialog.s_controls.close_btn]        = {"pay_content_view","close_btn"},
    [PayDialog.s_controls.title]            = {"pay_content_view","title"},
};

PayDialog.s_controlFuncMap = 
{
};

if kPlatform == "ios" then
    PayDialog.ITEMS = {
	    {mode = PayDialog.pay_mode_recommend, 		icon = "", 	                                    title = "确认"},
        {mode = PayDialog.pay_mode_appstore,       	icon = "", 		                                title = "AppStore"},
	    {mode = PayDialog.pay_mode_weixin,    		icon = "common/icon/pay_weixin_texture.png", 	title = "微信支付"},
	    {mode = PayDialog.pay_mode_ali, 		    icon = "common/icon/pay_ali_texture.png", 		title = "支付宝"},
    }
else
    PayDialog.ITEMS = {
--        {mode = PayDialog.mm_mode, 		            icon = "drawable/pay_sms_texture.png", 			title = "短信支付"},
--        {mode = PayDialog.wo_shop_mode, 		    icon = "drawable/pay_sms_texture.png", 			title = "短信支付"},
--        {mode = PayDialog.dianxin_aiyouxi_mode, 	icon = "drawable/pay_sms_texture.png", 			title = "短信支付"},
	    {mode = PayDialog.pay_mode_recommend, 		icon = "", 	                                    title = "确认"},
	    {mode = PayDialog.pay_mode_union, 		    icon = "common/icon/pay_unionpay_texture.png", 	title = "银联支付"},
	    {mode = PayDialog.pay_mode_mo9, 		    icon = "drawable/pay_mo9_texture.png", 			title = "先玩后付"},
	    {mode = PayDialog.pay_mode_yee,			    icon = "drawable/pay_yee_texture.png", 			title = "易宝"},
	    {mode = PayDialog.pay_mode_tenpay, 		    icon = "drawable/pay_tenpay_texture.png", 		title = "财付通"},
    	{mode = PayDialog.pay_mode_weixin, 		    icon = "common/icon/pay_weixin_texture.png", 	title = "微信支付"},
	    {mode = PayDialog.pay_mode_ali, 		    icon = "common/icon/pay_ali_texture.png", 		title = "支付宝"},
    }
end	

PayDialog.getInstance = function()
    if not PayDialog.s_instance then
        PayDialog.s_instance = new(PayDialog)
    end
    return PayDialog.s_instance
end

PayDialog.releaseInstance = function()
    if PayDialog.s_instance then
		delete(PayDialog.s_instance);
		PayDialog.s_instance = nil;
	end
end

PayDialog.ctor = function(self)
    super(self,pay_dialog_view);
    self.m_ctrls = PayDialog.s_controls;

    
    self.title = self:findViewById(self.m_ctrls.title)
    self.m_goods_view_handle = self:findViewById(self.m_ctrls.goods_view_handle);
    self.m_pay_content_view = self:findViewById(self.m_ctrls.pay_content_view);
    self.m_pay_content_view:setEventTouch(self.m_pay_content_view,function() end);
    self.m_pay_pmode_group = self:findViewById(self.m_ctrls.pay_pmode_group);
    self.m_close_btn = self:findViewById(self.m_ctrls.close_btn);

    self.m_close_btn:setOnClick(self,self.dismiss);
    self:setShieldClick(self,self.dismiss);
    self:setLevel(11)
    self.mDialogAnim = AnimDialogFactory.createMoveUpAnim(self)
end

function PayDialog:setData(goods)
    self.m_goods = goods;

    delete(self.m_goods_view)
    if self.m_goods.cate_id and self.m_goods.cate_id == 11 then
        self.title:setText(self.m_goods.name);
        self.m_goods_view = new(PayDialogMallVipShopItem,self.m_goods);
    else
        self.title:setText("购买金币");
        self.m_goods_view = new(PayDialogMallShopItem,self.m_goods);
    end

    self.m_goods_view:setAlign(kAlignCenter);
    local gh = 190
    local ph = 645
    local w,h = self.m_goods_view:getSize();
    self.m_goods_view_handle:setSize(nil,h);
    self.m_goods_view_handle:addChild(self.m_goods_view);
    self.m_pay_content_view:setSize(nil,ph+h-gh);
    self:initItems();
end

--function PayDialog:setScene(payScene)
--    self.mPayScene = payScene
--end

function PayDialog:setPhpData(payData)
    self.mPayData = payData
end

PayDialog.show = function(self)
    self:setVisible(true);
    self.super.show(self,self.mDialogAnim.showAnim);
end

PayDialog.dismiss = function(self)
--    self:setVisible(false);
    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
end

PayDialog.dtor = function(self)
	self.mDialogAnim.stopAnim()
end

PayDialog.getPmodes = function (self)
    local operator_mode = 0;
    local operator;
    if "ios" == System.getPlatform() then
        operator = "IOS";
    else
    	operator = TerminalInfo.getInstance():getOperator();
    end;
    if operator == "CHINA_MOBILE" then
        operator_mode = 218;
    elseif operator == "CHINA_UNICOM" then
        operator_mode = 109;
    elseif operator == "CHINA_TELECOM" then
        operator_mode = 34;
    end
    local signSMS = 1; -- 屏蔽短代支付
    for _, v in pairs(PayUtil.pmodes) do
        if (v == PayUtil.mm_mode or v == PayUtil.wo_shop_mode or v == PayUtil.dianxin_aiyouxi_mode or v == PayUtil.huafubao_mode) and signSMS == 0 and operator_mode ~= 0 then
            table.insert(self.m_pmodesItem,{mode = operator_mode, 		icon = "drawable/pay_sms_texture.png", 			title = "短信支付"})
            signSMS = 1;
        else
            local signSame = -1;
            for i,k in ipairs(PayDialog.ITEMS) do 
                if v == k.mode then
		    if "ios" == kPlatform then
			    if tonumber(UserInfo.getInstance():getIosAuditStatus()) == 0 and v ~= PayUtil.pay_mode_appstore then--AppStore审核,只有AppStore支付
			        signSame = -1;
			    elseif tonumber(UserInfo.getInstance():getThirdPartPay()) == 0 and v ~= PayUtil.pay_mode_appstore then--第三方支付关闭,只有AppStore支付
			        signSame = -1;
			    else
			        signSame = i;
			    end;
		    else
		    	signSame = i;
		    end;
                end
            end
            if signSame ~= -1 then
                table.insert(self.m_pmodesItem,PayDialog.ITEMS[signSame]);
            end
        end
    end
end

PayDialog.initItems = function(self)
    delete(self.m_itemView)
    local w,h = self.m_pay_pmode_group:getSize();
    self.m_itemView = new(ScrollView,0,0,w,h,true);
    
    local payItem = nil
    local checkPmode = PayDialog.pay_mode_recommend
    -- 审核 开关
    if "ios" == kPlatform and (tonumber(UserInfo.getInstance():getIosAuditStatus()) == 0 or tonumber(UserInfo.getInstance():getThirdPartPay()) == 0) then
        checkPmode =  PayUtil.pay_mode_appstore
    end
    for i,k in ipairs(PayDialog.ITEMS) do 
        if checkPmode == k.mode then
            payItem = k
        end
    end
	local y_pos = 0;
	local x_pos = 0;
    delete(self.m_btn)
    self.m_btn = nil
    if payItem then
	    self.m_btn = new(PayDialogItem,payItem);
        local w,h = self.m_btn:getSize();
        self.m_btn:setOnClick(self,self.payOrder);
        self.m_btn:setPos(x_pos, y_pos)
        y_pos = y_pos + h
        self.m_itemView:addChild(self.m_btn);
    end
    self.m_cancel_btn = new(PayDialogCancelItem);
    local w,h = self.m_cancel_btn:getSize();
	self.m_cancel_btn:setOnClick(self,self.dismiss);
	self.m_cancel_btn:setPos(x_pos, y_pos);
	self.m_cancel_btn:setVisible(true);
	self.m_itemView:addChild(self.m_cancel_btn);

    self.m_pay_pmode_group:addChild(self.m_itemView);
end

PayDialog.payOrder = function(self,mode)
	print_string("PayDialog.payOrder in" .. mode)
	local goods = self.m_goods;
	if goods then
		PayUtil.getPayInstance(PayUtil.s_useType):createOrder(goods, mode,self.mPayData);
	end
    self:cancel();
end

PayDialog.payOrderFirst = function(self)
    if self.m_btn then
        self.m_btn:onItemClick()
        self:setVisible(false)
    end
end

PayDialog.cancel = function(self)
	print_string("PayDialog.cancel ");
	self:dismiss();
end

PayDialog.showMorePayDialog = function(self)
    self:cancel()
    MallData.getInstance():showMorePayDialog()
end

-----------------------------------------------------------------------------------------------------------------------------------------------
PayDialogItem = class(Node);

PayDialogItem.s_maxClickOffset = 10;

PayDialogItem.ctor = function(self,data)
	self.m_data = data;
	local title_x,title_y = 93,30;
	local icon_x,icon_y = 21,12;

	if data.mode == PayDialog.pay_mode_union or data.mode == PayDialog.pay_mode_mo9 or data.mode == PayDialog.pay_mode_tenpay then
		icon_y = 20;
	end

	self.m_bg_btn = new(Button,"common/button/dialog_btn_2_normal.png","common/button/dialog_btn_2_press.png");
	self.m_bg_btn:setOnClick(self,self.onItemClick);
    self.m_bg_btn:setAlign(kAlignCenter);
    self.m_bg_btn:setSrollOnClick();

    self.m_node = new(Node);
    self.m_node:setAlign(kAlignCenter);
	self.m_bg_btn:addChild(self.m_node);

--	self.m_icon = new(Image,data.icon);
--    self.m_icon:setAlign(kAlignLeft);
--	self.m_node:addChild(self.m_icon);

	self.m_title = new(Text, "购买", nil, nil, kAlignLeft,nil,40,240,230,210);
    self.m_title:setAlign(kAlignRight);
--    self.m_title:setPos(80);
	self.m_node:addChild(self.m_title);

--    self.m_node:setSize(select(1,self.m_icon:getSize())+select(1,self.m_title:getSize()) + 10,
--                        select(2,self.m_icon:getSize())+select(2,self.m_title:getSize()))

    local tw,th = self.m_title:getSize()
    self.m_node:setSize(tw,th)

	self:addChild(self.m_bg_btn);
    local w,h = self.m_bg_btn:getSize();
	self:setSize(w,h+20);
    self:setFillParent(true,false);
end

PayDialogItem.setOnClick = function(self, obj,func)
    self.m_onClickFunc = func;
	self.m_onClickObj = obj;
end

PayDialogItem.onItemClick = function(self)
	if self.m_onClickFunc ~= nil then
        self.m_onClickFunc(self.m_onClickObj,self.m_data.mode);
    end	
end

-- 取消按钮

PayDialogCancelItem = class(Node);

PayDialogCancelItem.s_maxClickOffset = 10;

PayDialogCancelItem.ctor = function(self)

	local title_x,title_y = 93,30;
	local icon_x,icon_y = 21,12;

	self.m_bg_btn = new(Button,"common/button/dialog_btn_6_normal.png","common/button/dialog_btn_6_press.png");
	self.m_bg_btn:setOnClick(self,self.onItemClick);
    self.m_bg_btn:setAlign(kAlignCenter);
    self.m_bg_btn:setSrollOnClick();

    self.m_node = new(Node);
    self.m_node:setAlign(kAlignCenter);
	self.m_bg_btn:addChild(self.m_node);


	self.m_title = new(Text,"取消", nil, nil, kTextAlignCenter,nil,40,240,230,210);
    self.m_title:setAlign(kAlignRight);
	self.m_node:addChild(self.m_title);

    self.m_node:setSize(select(1,self.m_title:getSize()),
                        select(2,self.m_title:getSize()));

	self:addChild(self.m_bg_btn);
    local w,h = self.m_bg_btn:getSize();
	self:setSize(w,h+20);
    self:setFillParent(true,false);
end

PayDialogCancelItem.setOnClick = function(self, obj,func)
    self.m_onClickFunc = func;
	self.m_onClickObj = obj;
end

PayDialogCancelItem.onItemClick = function(self)
	if self.m_onClickFunc ~= nil then
        self.m_onClickFunc(self.m_onClickObj);
    end	
end


--商品信息的Item
PayDialogMallShopItem = class(Node);
PayDialogMallShopItem.ICON_PRE = "mall/";
require(VIEW_PATH.."mall_pay_shop_item")

PayDialogMallShopItem.ctor = function(self,goods)
	print_string("MallShopItem.ctor" .. goods.id);
	self.m_data = {};
	for key ,value  in pairs(goods) do
		self.m_data[key] = value;
	end

	self.mScene = SceneLoader.load(mall_pay_shop_item)
    self.mScene:setAlign(kAlignTop)
    self:addChild(self.mScene)
    self:setPos(0,0)
    self:setSize(720,190)
    self.mPromotionIcon = self.mScene:getChildByName("promotion_icon")
    self.mHotIcon = self.mScene:getChildByName("hot_icon")
    self.mNameView = self.mScene:getChildByName("name_view")
    self.mPriceView = self.mScene:getChildByName("price_view")
    self.mIconView = self.mScene:getChildByName("icon_view")
    self.mDecsView = self.mScene:getChildByName("desc_view")
    self.m_isPay = true
    
    
	self.mNameText = new(Text, goods.name, 0, 0, nil,nil,36,80, 80, 80)
    self.mNameText:setAlign(kAlignLeft)
    self.mNameView:addChild(self.mNameText)

    
    --商品图片
	self.mGoodsIcon = new(Image,MallShopItem.ICON_PRE .. goods.imgurl .. ".png")
    self.mGoodsIcon:setAlign(kAlignCenter)
    self.mIconView:addChild(self.mGoodsIcon)

    
    self.mGoodsPriceIcon = new(Image,"common/icon/sale_icon.png");
	self.mGoodsPrice = new(Text, string.format("%d元",goods.price), 0, 0, kAlignLeft,nil,40,125, 80, 65)
    self.mGoodsPriceIcon:setAlign(kAlignRight)
    self.mGoodsPrice:setAlign(kAlignRight)

    local padingRigth = self.mGoodsPrice:getSize()
    self.mGoodsPriceIcon:setPos(padingRigth+5)
    
    self.mPriceView:addChild(self.mGoodsPriceIcon)
    self.mPriceView:addChild(self.mGoodsPrice)

    local w,h = self.mDecsView:getSize()
    self.mDecsText = new(TextView, goods.short_desc, w, 0, nil,nil,28,120,120,120)
    self.mDecsText:setPickable(false)
    self.mDecsView:addChild(self.mDecsText)
    
    self.mPromotionIcon:setVisible(false)
    self.mHotIcon:setVisible(false)
    if goods.label then
		if goods.label == 1 then --打折
            self.mPromotionIcon:setVisible(true)
		elseif goods.label == 2 then
            self.mHotIcon:setVisible(true)
		end
	end
end

PayDialogMallShopItem.getData = function(self)

	return self.m_data;
end

PayDialogMallShopItem.dtor = function(self)
	
end	


--商品信息的Item
PayDialogMallVipShopItem = class(Node);
PayDialogMallVipShopItem.ICON_PRE = "mall/";
require(VIEW_PATH.."mall_pay_vip_shop_item")

PayDialogMallVipShopItem.ctor = function(self,goods)
	print_string("MallShopItem.ctor" .. goods.id);
	self.m_data = {};
	for key ,value  in pairs(goods) do
		self.m_data[key] = value;
	end

	self.mScene = SceneLoader.load(mall_pay_vip_shop_item)
    self.mScene:setAlign(kAlignTop)
    self:addChild(self.mScene)
    self:setPos(0,0)
    self:setSize(720,320)
    self.mPromotionIcon = self.mScene:getChildByName("promotion_icon")
    self.mHotIcon = self.mScene:getChildByName("hot_icon")
    self.mNameView = self.mScene:getChildByName("name_view")
    self.mPriceView = self.mScene:getChildByName("price_view")
    self.mIconView = self.mScene:getChildByName("icon_view")
    self.mShortDecsView = self.mScene:getChildByName("short_desc_view")
    self.mDecsView = self.mScene:getChildByName("desc_view")
    self.m_isPay = true
    
    
	self.mNameText = new(Text, goods.name, 0, 0, nil,nil,36,80, 80, 80)
    self.mNameText:setAlign(kAlignLeft)
    self.mNameView:addChild(self.mNameText)

    
    --商品图片
	self.mGoodsIcon = new(Image,MallShopItem.ICON_PRE .. goods.imgurl .. ".png")
    self.mGoodsIcon:setAlign(kAlignCenter)
    self.mIconView:addChild(self.mGoodsIcon)

    
    self.mGoodsPriceIcon = new(Image,"common/icon/sale_icon.png");
	self.mGoodsPrice = new(Text, string.format("%d元",goods.price), 0, 0, kAlignLeft,nil,36,125, 80, 65)
    self.mGoodsPriceIcon:setAlign(kAlignRight)
    self.mGoodsPrice:setAlign(kAlignRight)

    local padingRigth = self.mGoodsPrice:getSize()
    self.mGoodsPriceIcon:setPos(padingRigth+10)
    
    self.mPriceView:addChild(self.mGoodsPriceIcon)
    self.mPriceView:addChild(self.mGoodsPrice)

    local w,h = self.mShortDecsView:getSize()
    self.mShortDecsText = new(TextView, goods.short_desc, w, 0, nil,nil,30,160,110,90)
    self.mShortDecsText:setPickable(false)
    self.mShortDecsView:addChild(self.mShortDecsText)
    
    local w,h = self.mDecsView:getSize()
    self.mDecsText = new(RichText,goods.desc, w, h, kAlignTopLeft, nil, 28, 100, 100, 100, true,2)
    self.mDecsView:addChild(self.mDecsText)


    self.mPromotionIcon:setVisible(false)
    self.mHotIcon:setVisible(false)
    if goods.label then
		if goods.label == 1 then --打折
            self.mPromotionIcon:setVisible(true)
		elseif goods.label == 2 then
            self.mHotIcon:setVisible(true)
		end
	end
end

PayDialogMallVipShopItem.getData = function(self)

	return self.m_data;
end

PayDialogMallVipShopItem.dtor = function(self)
	
end	