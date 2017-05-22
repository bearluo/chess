require(VIEW_PATH .. "pay_dialog_view");
require(BASE_PATH.."chessDialogScene");
require("ui/scrollViewEx");

PayDialog = class(ChessDialogScene,false)

if kPlatform == "ios" then
    PayDialog.pay_mode_appstore = 99;   --苹果支付;
    PayDialog.pay_mode_weixin = 463; -- ios微信
    PayDialog.pay_mode_ali = 265;    --支付宝
else
    PayDialog.pay_mode_mo9 = 29 ;    --mo9;
    PayDialog.pay_mode_union = 198;   --银联;
    PayDialog.pay_mode_weixin = 431; -- 微信
    PayDialog.pay_mode_card = 35;    --话付宝;
    PayDialog.pay_mode_sms = 15 ;    -- 千尺
    PayDialog.pay_mode_yee = 14;     --易宝;
    PayDialog.pay_mode_tenpay = 33;  --财付通;
    PayDialog.pay_mode_huawei = 110; --华为;
    PayDialog.pay_mode_ali = 265;    --支付宝
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
        {mode = PayDialog.pay_mode_appstore,       	icon = "", 		                                title = "AppStore"},
	    {mode = PayDialog.pay_mode_weixin,    		icon = "common/icon/pay_weixin_texture.png", 	title = "微信支付"},
	    {mode = PayDialog.pay_mode_ali, 		    icon = "common/icon/pay_ali_texture.png", 		title = "支付宝"},
    };
else
    PayDialog.ITEMS = {
	    {mode = PayDialog.pay_mode_union, 		    icon = "common/icon/pay_unionpay_texture.png", 	title = "银联支付"},
	    {mode = PayDialog.pay_mode_mo9, 		    icon = "drawable/pay_mo9_texture.png", 			title = "先玩后付"},
	    {mode = PayDialog.pay_mode_yee,			    icon = "drawable/pay_yee_texture.png", 			title = "易宝"},
	    {mode = PayDialog.pay_mode_tenpay, 		    icon = "drawable/pay_tenpay_texture.png", 		title = "财付通"},
    	{mode = PayDialog.pay_mode_weixin, 		    icon = "common/icon/pay_weixin_texture.png", 	title = "微信支付"},
	    {mode = PayDialog.pay_mode_ali, 		    icon = "common/icon/pay_ali_texture.png", 		title = "支付宝"},
    };
end;	

PayDialog.getInstance = function(goods)
    if PayDialog.s_instance then
        if goods == PayDialog.s_instance.m_goods then
            return PayDialog.s_instance;
        else
            delete(PayDialog.s_instance);
        end
    end
    PayDialog.s_instance = new(PayDialog, goods);
    return PayDialog.s_instance;
end

PayDialog.releaseInstance = function()
    if PayDialog.s_instance then
		delete(PayDialog.s_instance);
		PayDialog.s_instance = nil;
	end
end

PayDialog.ctor = function(self, goods)
    super(self,pay_dialog_view);
    self.m_ctrls = PayDialog.s_controls;
    self.m_goods = goods;
    self.m_pmodesItem = {};--支付渠道列表
    self:create();
end

PayDialog.create = function(self)
    self.title = self:findViewById(self.m_ctrls.title)
    if self.m_goods.cate_id and self.m_goods.cate_id == 11 then
        self.title:setText(self.m_goods.name);
    else
        self.title:setText("购买金币");
    end
    self.m_goods_view = new(PayDialogMallShopItem,self.m_goods);
    self.m_goods_view:setAlign(kAlignCenter);
    self.m_goods_view_handle = self:findViewById(self.m_ctrls.goods_view_handle);
--    self.m_goods_view_handle:setPickable(false);
    self.m_goods_view_handle:addChild(self.m_goods_view);
	self.m_money = self.m_goods_view:getMoneyView();
	self.m_price = self.m_goods_view:getPriceView();
    self.m_pay_content_view = self:findViewById(self.m_ctrls.pay_content_view);
    self:setShieldClick(self,self.dismiss);
    self.m_pay_content_view:setEventTouch(self.m_pay_content_view,function() end);


    self.m_pay_pmode_group = self:findViewById(self.m_ctrls.pay_pmode_group);
    self.m_close_btn = self:findViewById(self.m_ctrls.close_btn);
    self.m_close_btn:setOnClick(self,self.dismiss);
--    self:setMoney(self.m_goods.money);
--    self:setPrice(self.m_goods.price);
    self:initItems();
    kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
    self:setVisible(false);
end

PayDialog.show = function(self)
    self:setVisible(true);
    self.super.show(self);
    if #self.m_items == 0 then
        local message = "该商品没有合适的支付方式"
		ChessToastManager.getInstance():show(message);
        self:cancel();
    end

--    if #self.m_items == 1 then
--        self:payOrder(self.m_items[1].mode);
--        self:cancel();
--        return;
--    end
end

PayDialog.dismiss = function(self)
--    self:setVisible(false);
    self.super.dismiss(self);
    PayDialog.releaseInstance();
end

PayDialog.dtor = function(self)
	
end

PayDialog.getPmodes = function (self)
    local operator_mode = 0;
    local operator;
    if "ios" == System.getPlatform() then
        operator = "";
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
    local signSMS = 0;
    for _, v in pairs(PayUtil.pmodes) do
        if (v == PayUtil.mm_mode or v == PayUtil.wo_shop_mode or v == PayUtil.dianxin_aiyouxi_mode or v == PayUtil.huafubao_mode) and signSMS == 0 and operator_mode ~= 0 then
            table.insert(self.m_pmodesItem,{mode = operator_mode, 		icon = "drawable/pay_sms_texture.png", 			title = "快捷支付"})
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
    local w,h = self.m_pay_pmode_group:getSize();
    self.m_itemView = new(ScrollView,0,0,w,h,true);
	if not self.m_goods.modelist then
		local message = "获取商品信息失败！"
		ChessToastManager.getInstance():show(message);

		local Prop_Version = GameCacheData.PROP_LIST_VERSION;
		if PhpInfo.getBid() then
			Prop_Version = Prop_Version..PhpInfo.getBid();
		end
		
		GameCacheData.getInstance():saveInt(Prop_Version,0);
		PHPInterface.getPropList();
		return;
	end

	print_string("modelist: "..self.m_goods.modelist);

	self.itemsKV = ToolKit.getModelistItemKV(self.m_goods.modelist,self.m_root_view);

    --local allItems = PayDialog.ITEMS;
    self:getPmodes();

    local allItems = self.m_pmodesItem;
	self.m_items = {};
    for i=1,#allItems do
        if self:checkItem(allItems[i].mode) ~= nil then
    		table.insert(self.m_items,allItems[i]);
    	end
    end


	local y_pos = 0;
	local x_pos = 0;

	self.m_btn = {}; 

	for index = 1,#self.m_items do 
		if self.m_items[index] then
			self.m_btn[index] = new(PayDialogItem,self.m_items[index]);
            local w,h = self.m_btn[index]:getSize();
			y_pos = (index-1) * h;
			self.m_btn[index]:setOnClick(self,self.payOrder);
			self.m_btn[index]:setPos(x_pos, y_pos);
			self.m_btn[index]:setVisible(true);
			self.m_itemView:addChild(self.m_btn[index]);
		end
	end
    self.m_cancel_btn = new(PayDialogCancelItem);
    local w,h = self.m_cancel_btn:getSize();
	y_pos = #self.m_items * h;
	self.m_cancel_btn:setOnClick(self,self.dismiss);
	self.m_cancel_btn:setPos(x_pos, y_pos);
	self.m_cancel_btn:setVisible(true);
	self.m_itemView:addChild(self.m_cancel_btn);

    self.m_pay_pmode_group:addChild(self.m_itemView);
end

PayDialog.checkItem = function(self,mode)
	for i,v in pairs(self.itemsKV) do
		if v.mode == mode then
			return v.goodId;
		end
    end
    return nil;
end

PayDialog.payOrder = function(self,mode)
	print_string("PayDialog.payOrder in" .. mode);

	local tempMode = mode;
	if mode == PayDialog.pay_mode_sms then
		if self:checkItem(PayDialog.pay_mode_card) then
			tempMode = PayDialog.pay_mode_card;
		end
	end

	local id = self:checkItem(tempMode);
	local goods = self.m_goods;

	if goods then
		goods.goodId = id;
		PayUtil.getPayInstance(PayUtil.s_useType):createOrder(goods, tempMode);
	end
    self:cancel();
end

PayDialog.cancel = function(self)
	print_string("PayDialog.cancel ");
	self:dismiss();
end

PayDialog.setGoods = function(self,goods)
	self.m_goods = goods; 
end

PayDialog.setMoney = function(self,money)
 	self.m_money:setText(string.format("%d金币",money));
end

PayDialog.setPrice = function(self,price)
	price = string.format("%.2f",price);
	self.m_pay_price = tonumber(price);
 	self.m_price:setText(string.format("%.2f",self.m_pay_price));
end

PayDialog.showPayTips = function(self,msg)
	self.m_chioce_dialog:setMode(ChioceDialog.MODE_OK);
	local message=msg;
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:setPositiveListener(nil,nil);
	self.m_chioce_dialog:show(self.m_root_view);
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

	self.m_icon = new(Image,data.icon);
    self.m_icon:setAlign(kAlignLeft);
	self.m_node:addChild(self.m_icon);

	self.m_title = new(Text, data.title, nil, nil, kAlignLeft,nil,40,240,230,210);
    self.m_title:setAlign(kAlignRight);
--    self.m_title:setPos(80);
	self.m_node:addChild(self.m_title);

    self.m_node:setSize(select(1,self.m_icon:getSize())+select(1,self.m_title:getSize()) + 10,
                        select(2,self.m_icon:getSize())+select(2,self.m_title:getSize()));

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

PayDialogMallShopItem.ctor = function(self,goods)
	
	print_string("PayDialogMallShopItem.ctor" .. goods.id);
	self.m_data = {};
	for key ,value  in pairs(goods) do
		self.m_data[key] = value;
	end

	local icon_x,icon_y = 50,0;
	local mall_money_fontsize = 36  --金币字体大小
	local mall_originmoney_fontsize = 28  --金币字体大小
	local mall_name_fontsize = 28;  --名字大小
	local mall_price_fontsize = 40;  --价钱的大小
	local mall_discount_fontsize = 22;
	local money_x,money_y = 240,45;
	local originmoney_x,originmoney_y = 240,90;
	local originline_x,originline_y = 235,105;
	local name_x,name_y = 290,45;
	local bg_x ,bg_y = 35 , 0;
	local price_x,price_y = 110,60;
    
    self:setPos(0,0);     --位置
    self:setSize(720,220);    --大


	--背景图标fmt, filter, leftWidth, rightWidth, topWidth, bottomWidth
	self.m_img_bg = new(Image,"common/background/line_bg.png",nil,nil, 64, 64, 64, 64);
    self.m_img_bg:setAlign(kAlignCenter);
    self.m_img_bg:setSize(660,166);
	self:addChild(self.m_img_bg);




	--商品图片
	self.m_goods_icon = new(Image,PayDialogMallShopItem.ICON_PRE .. goods.imgurl .. ".png");
	local icon_w,icon_h = self.m_goods_icon:getSize();

	self.m_goods_icon:setPos(icon_x,icon_y);
    self.m_goods_icon:setAlign(kAlignLeft);
	self.m_img_bg:addChild(self.m_goods_icon);


	--用户金钱
    local goodsMoney = goods.money
    if goods.cate_id and goods.cate_id == 11 then
        goodsMoney = "";
    end
	self.m_money_text = new(Text, goodsMoney..goods.name, 0, 0, nil,nil,mall_money_fontsize,80, 80, 80)
	self.m_money_text:setPos(money_x,money_y);
	self.m_img_bg:addChild(self.m_money_text);

	local money_w,money_h = self.m_money_text:getSize();
	--名称
--	self.m_goods_name = new(Text, goods.name, 0, 0, nil,nil,mall_name_fontsize,250, 230, 180);
--	self.m_goods_name:setPos(money_x+money_w,name_y);
--	self.m_img_bg:addChild(self.m_goods_name);
    if goods.payType and goods.payType == 2 then
	    self.m_goods_price = new(Text, goods.price.."元宝", 0, 0, kAlignLeft,nil,mall_price_fontsize,125, 80, 65);
        self.m_data.msg = string.format("是否用%d元宝兑换%d%s?",goods.price,goods.money,goods.name);--兑换dialog要用的参数
    else
	    self.m_goods_price = new(Text, string.format("%d元",goods.price), 0, 0, kAlignLeft,nil,mall_price_fontsize,125, 80, 65);
    end
	self.m_goods_price:setPos(price_x+430,price_y);
    self.m_goods_price:setAlign(kAlignTopLeft);
	self.m_img_bg:addChild(self.m_goods_price);
    
    local w,h = self.m_goods_price:getSize();

    self.m_goods_price_icon = new(Image,"common/icon/sale_icon.png");
	self.m_goods_price_icon:setPos(price_x+380,price_y);
    self.m_goods_price_icon:setAlign(kAlignTopLeft);
	self.m_img_bg:addChild(self.m_goods_price_icon);

	if goods.label then
		if goods.label == 1 then --打折
			self.m_label = 	 new(Image,"common/icon/discount_icon.png");
			self.m_label:setPos(bg_x ,bg_y);
			self.m_img_bg:addChild(self.m_label);

			self.m_originmoney_text = new(Text, goods.originmoney .. goods.name, 0, 0, nil,nil,mall_originmoney_fontsize,120,120,120)
			self.m_originmoney_text:setPos(originmoney_x,originmoney_y);
			self.m_img_bg:addChild(self.m_originmoney_text);

			local w,h = self.m_originmoney_text:getSize();

			self.m_oringin_line = 	new(Image,PayDialogMallShopItem.ICON_PRE .. "mall_discount_line.png");
			local line_w,line_h = self.m_oringin_line:getSize();
			line_w = w + 10;
			self.m_oringin_line:setSize(line_w,line_h);
			self.m_oringin_line:setPos(originline_x,originline_y);
			self.m_img_bg:addChild(self.m_oringin_line);
		elseif goods.label == 2 then
			self.m_label = 	 new(Image,"common/icon/hot_icon.png");
			self.m_label:setPos(bg_x ,bg_y);
			self.m_img_bg:addChild(self.m_label);
		end
	end

    if goods.cate_id and goods.cate_id == 11 then
        self.m_money_text:setVisible(false);
        self.m_img_bg:setSize(660,300);
        self.m_goods_icon:setPos(icon_x,icon_y-50);
        self.m_money_text_scroll_view = new(ScrollView,0,0, 380, 200, true)
        self.m_money_text_vip = new(RichText, goods.desc, 380, 200, kAlignTopLeft,nil,28,80, 80, 80,true,10)
	    self.m_money_text_scroll_view:setPos(money_x,money_y);
	    self.m_money_text_scroll_view:addChild(self.m_money_text_vip);
	    self.m_img_bg:addChild(self.m_money_text_scroll_view);
        self.m_money_text_scroll_view:setEventDrag(self.m_money_text_scroll_view,self.m_money_text_scroll_view.onEventDrag);

        self.m_goods_price:setPos(icon_x+20,icon_y+200);
	    self.m_goods_price_icon:setPos(icon_x+100,icon_y+200);
    end
end

PayDialogMallShopItem.buyGoods = function(self)
	print_string("PayDialogMallShopItem.buyGoods goods = " .. self.m_data.money);

	if self.m_data then
        if self.m_data.payType and self.m_data.payType == 2 then 
            Mall.m_PayInterface = PayUtil.getPayTypeObj(PayInterface.PROP_GOODS,Mall.obj);
		    self.m_data.position = MALL_COINS_GOODS
		    Mall.m_pay_dialog = Mall.m_PayInterface:buy(self.m_data,MALL_COINS_GOODS);
        else
            Mall.m_PayInterface = PayUtil.getPayTypeObj(PayInterface.COINS_GOODS,Mall.obj,true);
		    self.m_data.position = MALL_COINS_GOODS
		    Mall.m_pay_dialog = Mall.m_PayInterface:buy(self.m_data,MALL_COINS_GOODS);
        end
	end
end

PayDialogMallShopItem.getData = function(self)

	return self.m_data;
end

PayDialogMallShopItem.getMoneyView = function(self)
    return self.m_money_text;
end

PayDialogMallShopItem.getPriceView = function(self)
    return self.m_goods_price;
end


PayDialogMallShopItem.dtor = function(self)
	
end	