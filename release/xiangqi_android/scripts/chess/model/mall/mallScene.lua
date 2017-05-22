require(BASE_PATH.."chessScene");

MallScene = class(ChessScene);
if kPlatform == kPlatformIOS then
    MallScene.s_controls = 
    {
        mall_back_btn = 1;
        mall_type_toggle_view = 2;
        mall_shop_placehold = 3;
        mall_prop_placehold = 4;
        -- ios走元宝
        mall_userinfo_bccoin_text = 5;
        mall_userinfo_money_text = 6;
        mall_content_view = 7;
        mall_title_view   = 8;
        mall_userinfo_score_view = 9;
    }
else
    MallScene.s_controls = 
    {
        mall_back_btn = 1;
        mall_type_toggle_view = 2;
        mall_shop_placehold = 3;
        mall_prop_placehold = 4;
        mall_userinfo_score_text = 5;
        mall_userinfo_money_text = 6;
        mall_content_view = 7;
    }
end;

MallScene.s_cmds = 
{
    updateView = 1;
    updateShopList = 2;
    updatePropList = 3;
    showTipsDlg = 4;
}

MallScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = MallScene.s_controls;
    self:create();
end 
MallScene.resume = function(self)
    ChessScene.resume(self);
    self:updateView();
end;


MallScene.pause = function(self)
	ChessScene.pause(self);
end 


MallScene.dtor = function(self)
    delete(self.m_anim_start);
    delete(self.m_anim_end);
end 

----------------------------------- function ----------------------------
MallScene.create = function(self)  
    
    self.m_mall_content_view = self:findViewById(self.m_ctrls.mall_content_view);
    self.m_left_leaf = self.m_root:getChildByName("Image6");
     self.m_right_leaf = self.m_root:getChildByName("Image7");
    
    local w,h = self:getSize();
    local cw,ch = self.m_mall_content_view:getSize();
    self.m_mall_content_view:setSize(nil,ch+h-System.getLayoutHeight());

    self.m_mall_shop_placehold = self:findViewById(self.m_ctrls.mall_shop_placehold);
    self.m_mall_prop_placehold = self:findViewById(self.m_ctrls.mall_prop_placehold);
    if kPlatform == kPlatformIOS then
        --ios审核关闭元宝相关
        self.m_mall_userinfo_score_view = self:findViewById(self.m_ctrls.mall_userinfo_score_view);
        if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
            self.m_mall_userinfo_score_view:setVisible(true);
            PayDialog.ITEMS[1].title = "AppStore";
        else
            self.m_mall_userinfo_score_view:setVisible(false);
            PayDialog.ITEMS[1].title = "确定";
        end;
        self.m_score_tips = self.m_mall_userinfo_score_view:getChildByName("mall_userinfo_score_tips");
        self.m_score_tips:setText("元宝:");
    	self.m_mall_userinfo_money = self:findViewById(self.m_ctrls.mall_userinfo_money_text);
    	self.m_mall_userinfo_bccoin = self:findViewById(self.m_ctrls.mall_userinfo_bccoin_text);
    else
    	self.m_mall_userinfo_money = self:findViewById(self.m_ctrls.mall_userinfo_money_text);
    	self.m_mall_userinfo_score = self:findViewById(self.m_ctrls.mall_userinfo_score_text);    
    end;


    self.m_mall_back_btn = self:findViewById(self.m_ctrls.mall_back_btn);
    self.m_mall_type_toggle_view = self:findViewById(self.m_ctrls.mall_type_toggle_view);

    self.m_shop_select_btn = new(RadioButton,{"mall/money.png","mall/money_chose.png"});
	self.m_prop_select_btn = new(RadioButton,{"mall/prop.png","mall/prop_chose.png"});
    self.m_shop_select_btn:setAlign(kAlignLeft);
    self.m_prop_select_btn:setAlign(kAlignRight);
--    self.m_shop_select_btn_icon = new(Images,{"mall/coin_toggle_off.png","mall/coin_toggle_on.png",});
--    self.m_prop_select_btn_icon = new(Images,{"mall/prop_toggle_off.png","mall/prop_toggle_on.png",});
--    self.m_shop_select_btn:addChild(self.m_shop_select_btn_icon);
--    self.m_prop_select_btn:addChild(self.m_prop_select_btn_icon);

    self.m_mall_type_toggle_view:addChild(self.m_prop_select_btn);
    self.m_mall_type_toggle_view:addChild(self.m_shop_select_btn);


    self.m_mall_type_toggle_view:setOnChange(self,self.updataSelectState);

    if MallData.getInstance():getMallType() == MallData.s_mallType.prop then
        self.m_prop_select_btn:setChecked(true);
    else
        self.m_shop_select_btn:setChecked(true);
    end
    self:updataSelectState();

    MallScene.tip_bg = new(Image, "common/background/tips_bg_2.png", nil, nil, 80, 48, 30, 60);
    MallScene.tip_bg:setSize(400,200);
    MallScene.tip_bg:setAlign(kAlignTop);
    MallScene.tip_bg:setVisible(false);
    self.m_mall_content_view:addChild(MallScene.tip_bg);
end

MallScene.setAnimItemEnVisible = function(self,ret)
    self.m_left_leaf:setVisible(ret);
    self.m_right_leaf:setVisible(ret);
end

MallScene.removeAnimProp = function(self)
    self.m_left_leaf:removeProp(1);
    self.m_right_leaf:removeProp(1);
    self.m_mall_type_toggle_view:removeProp(1);
    self.m_mall_type_toggle_view:removeProp(2);
end

MallScene.resumeAnimStart = function(self,lastStateObj,timer)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    self:setAnimItemEnVisible(false);
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;

--    local w,h = self:getSize();
--    self.m_root:addPropTranslate(1,kAnimNormal,duration,waitTime,w,0,nil,nil);
    delete(self.m_anim_start);
    self.m_anim_start = new(AnimInt,kAnimNormal,0,1,delay,-1);
    if self.m_anim_start then
        self.m_anim_start:setEvent(self,function()
            self:setAnimItemEnVisible(true);
            delete(self.m_anim_start);
        end);
    end

    self.m_mall_type_toggle_view:addPropTransparency(2,kAnimNormal,waitTime,delay,0,1);
    self.m_mall_type_toggle_view:addPropScale(1,kAnimNormal,waitTime,delay,0.8,1,0.6,1,kCenterXY,150,40);
    local lw,lh = self.m_left_leaf:getSize();
    self.m_left_leaf:addPropTranslate(1,kAnimNormal,waitTime,delay,-lw,0,-10,0);
    local rw,rh = self.m_right_leaf:getSize();
    local anim = self.m_right_leaf:addPropTranslate(1,kAnimNormal,waitTime,delay,rw,0,-10,0);
    if anim then
        anim:setEvent(self,function()
            self.m_anim_prop_need_remove = true;
            self:removeAnimProp();
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end
        end);
    end
end

MallScene.pauseAnimStart = function(self,newStateObj,timer)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;

--    local w,h = self:getSize();
--    local anim_end = self.m_root:addPropTranslate(1,kAnimNormal,duration,waitTime,0,w,nil,nil);
    delete(self.m_anim_end);
    self.m_anim_end = new(AnimInt,kAnimNormal,0,1,delay,-1);
    if self.m_anim_end then
        self.m_anim_end:setEvent(self,function()
            self.m_anim_prop_need_remove = true;
            self:removeAnimProp();
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end
            delete(self.m_anim_end);
        end);
    end

    local lw,lh = self.m_left_leaf:getSize();
    self.m_left_leaf:addPropTranslate(1,kAnimNormal,waitTime,-1,0,-lw,0,-10);
    local rw,rh = self.m_right_leaf:getSize();
    local anim = self.m_right_leaf:addPropTranslate(1,kAnimNormal,waitTime,-1,0,rw,0,-10);
    if anim then
        anim:setEvent(self,function()
            self:setAnimItemEnVisible(false);
        end);
    end
end

MallScene.onBack = function(self)
    self:requestCtrlCmd(MallController.s_cmds.onBack);
end


MallScene.updataSelectState = function(self)
    if self.m_shop_select_btn:isChecked() then
--        self.m_shop_select_btn_icon:setImageIndex(1);
        self.m_mall_shop_placehold:setVisible(true);
        if not self.m_shop_mall_adapter then
            self:requestCtrlCmd(MallController.s_cmds.getShopInfo);
        end
    else
--        self.m_shop_select_btn_icon:setImageIndex(0);
        self.m_mall_shop_placehold:setVisible(false);
    end
    
    if self.m_prop_select_btn:isChecked() then
--        self.m_prop_select_btn_icon:setImageIndex(1);
        self.m_mall_prop_placehold:setVisible(true);
        if not self.m_prop_Mall_adapter then
            self:requestCtrlCmd(MallController.s_cmds.getPropList);
        end
    else
--        self.m_prop_select_btn_icon:setImageIndex(0);
        self.m_mall_prop_placehold:setVisible(false);
    end
end

MallScene.updateView = function(self)
	self.m_mall_userinfo_money:setText(UserInfo.getInstance():getMoneyStr());
	if kPlatform == kPlatformIOS then
	    self.m_mall_userinfo_bccoin:setText(UserInfo.getInstance():getBccoin());
	else
	    self.m_mall_userinfo_score:setText(UserInfo.getInstance():getScore());
	end;
end

MallScene.updateShopList = function(self,data)    
    if not data or (type(data) == "table" and #data == 0) then 
        return ;
    end

    if self.m_shop_mall_adapter then
        self.m_mall_shop_placehold:removeChild(self.m_shop_mall_list,true);
        delete(self.m_shop_mall_adapter);
        delete(self.m_shop_mall_list);
        self.m_shop_mall_adapter = nil;
        self.m_shop_mall_list = nil;
    end

	self.m_shop_mall_adapter = new(CacheAdapter,MallShopItem,data);
	local w,h = self.m_mall_shop_placehold:getSize();
	self.m_shop_mall_list = new(ListView,0,0,w,h);
    self.m_shop_mall_list:setAdapter(self.m_shop_mall_adapter);
	self.m_mall_shop_placehold:addChild(self.m_shop_mall_list);
	self.m_shop_mall_list:setOnItemClick(self,self.mallOnShopListItemClick);
end

MallScene.mallOnShopListItemClick = function(self,adapter,view,index)
	print_string("Online.setMallOnListItemClick index = " .. index);
 	local data  = view:getData();

 	if data==nil or ( view.isPay and not view:isPay() )then
 		return;
 	end

 	if data then
        if data.payType and data.payType == 2 then 
            MallScene.m_PayInterface = PayUtil.getPayInstance(PayUtil.s_payType.Exchange);
		    data.position = MALL_COINS_GOODS;
		    MallScene.m_pay_dialog = MallScene.m_PayInterface:buy(data,MALL_COINS_GOODS);
        else
            MallScene.m_PayInterface = PayUtil.getPayInstance(PayUtil.s_defaultType);
		    data.position = MALL_COINS_GOODS;
		    MallScene.m_pay_dialog = MallScene.m_PayInterface:buy(data,MALL_COINS_GOODS);
        end
	end
end


MallScene.updatePropList = function(self,data)
    if not data then 
        return ;
    end

    local pdata = {};
    for i,v in pairs(data) do
        if v.show == 1 then
            pdata[#pdata+1] = v;
        end
    end

    if #pdata == 0 then return end ;

	self.m_prop_Mall_adapter = new(CacheAdapter,MallPropItem,pdata);
	local w,h = self.m_mall_prop_placehold:getSize();

	self.m_prop_mall_list = new(ListView,0,0,w,h);
    self.m_prop_mall_list:setAdapter(self.m_prop_Mall_adapter);
	self.m_mall_prop_placehold:addChild(self.m_prop_mall_list);

	self.m_prop_mall_list:setOnItemClick(self,self.mallOnPropListItemClick);
end

MallScene.mallOnPropListItemClick = function(self,adapter,view,index)
    local data  = view:getData();
    
 	if data==nil or ( view.isPay and not view:isPay() )then
 		return;
 	end

 	if data then
        if data.goods_type == 12 then
            local soulcount = UserInfo.getInstance():getSoulCount();
            if data.exchange_num and data.exchange_num > soulcount then --data.exchangeNum > soulcount
                local msg = "很抱歉，您的棋魂不足以兑换该奖品，玩游戏有几率获得棋魂，赶紧去赚取吧！";
                local title = "兑换失败";	
                EventDispatcher.getInstance():dispatch(Event.Call, SOUL_NOT_ENOUGH_FOR_COST,title,msg);
                return;
            end
        end
        MallScene.m_PayInterface = PayUtil.getPayInstance(PayUtil.s_payType.Exchange);
		data.position = data.id;
		MallScene.m_pay_dialog = MallScene.m_PayInterface:buy(data,data.position);
	end
end

MallScene.showTipsDlg = function(self,title,tips)
	if not self.m_exchange_tips_dialog then
        require("dialog/exchange_tips_dialog");
		self.m_exchange_tips_dialog = new(ExchangeTipsDialog,title,tips);
	end
	self.m_exchange_tips_dialog:show(title,tips);
end



----------------------------------- onClick ---------------------------------





----------------------------------- config ------------------------------
if kPlatform == kPlatformIOS then
    MallScene.s_controlConfig = 
    {
    	[MallScene.s_controls.mall_back_btn] = {"mall_back_btn"};
        [MallScene.s_controls.mall_title_view] = {"mall_title_view"};
        [MallScene.s_controls.mall_type_toggle_view] = {"mall_title_view","mall_type_toggle_view"};
        [MallScene.s_controls.mall_content_view] = {"mall_content_view"};
        [MallScene.s_controls.mall_shop_placehold] = {"mall_content_view","mall_shop_placehold"};
        [MallScene.s_controls.mall_prop_placehold] = {"mall_content_view","mall_prop_placehold"};
        [MallScene.s_controls.mall_userinfo_score_view] = {"mall_userinfo_view","mall_score_info_view"};
        [MallScene.s_controls.mall_userinfo_bccoin_text] = {"mall_userinfo_view","mall_score_info_view","mall_userinfo_score_text"};
        [MallScene.s_controls.mall_userinfo_money_text] = {"mall_userinfo_view","mall_money_info_view","mall_userinfo_money_text"};
    };
else
    MallScene.s_controlConfig = 
    {
    	[MallScene.s_controls.mall_back_btn] = {"mall_back_btn"};
        [MallScene.s_controls.mall_type_toggle_view] = {"mall_title_view","mall_type_toggle_view"};
        [MallScene.s_controls.mall_content_view] = {"mall_content_view"};
        [MallScene.s_controls.mall_shop_placehold] = {"mall_content_view","mall_shop_placehold"};
        [MallScene.s_controls.mall_prop_placehold] = {"mall_content_view","mall_prop_placehold"};
        [MallScene.s_controls.mall_userinfo_score_text] = {"mall_userinfo_view","mall_score_info_view","mall_userinfo_score_text"};
        [MallScene.s_controls.mall_userinfo_money_text] = {"mall_userinfo_view","mall_money_info_view","mall_userinfo_money_text"};
    };
end;

MallScene.s_controlFuncMap =
{
    [MallScene.s_controls.mall_back_btn] = MallScene.onBack;

};


MallScene.s_cmdConfig =
{
    [MallScene.s_cmds.updateView] = MallScene.updateView;
    [MallScene.s_cmds.updateShopList] = MallScene.updateShopList;
    [MallScene.s_cmds.updatePropList] = MallScene.updatePropList;
    [MallScene.s_cmds.showTipsDlg] = MallScene.showTipsDlg;
}




------------------------------------ private node -----------------------------

--商品信息的Item
MallShopItem = class(Node);
MallShopItem.ICON_PRE = "mall/";

MallShopItem.ctor = function(self,goods)
	
	print_string("MallShopItem.ctor" .. goods.id);
	self.m_data = {};
	for key ,value  in pairs(goods) do
		self.m_data[key] = value;
	end

	local icon_x,icon_y = 50,-20;
	local mall_money_fontsize = 36  --金币字体大小
	local mall_originmoney_fontsize = 28  --金币字体大小
	local mall_name_fontsize = 28;  --名字大小
	local mall_price_fontsize = 40;  --价钱的大小
	local mall_discount_fontsize = 22;
	local money_x,money_y = 240,45;
	local originmoney_x,originmoney_y = 240,90;
	local originline_x,originline_y = 235,105;
	local name_x,name_y = 290,45;
	local bg_x ,bg_y = 35 , 15;
	local price_x,price_y = 80,70;
    
    self:setPos(0,0);     --位置
    self:setSize(720,220);    --大
    self.m_isPay = true;

	--背景图标
	self.m_img_bg = new(Button,"common/background/item_bg.png");
    self.m_img_bg:setOnTuchProcess(self,self.onTuchProcess);
    self.m_img_bg:setAlign(kAlignCenter);
	self:addChild(self.m_img_bg);

    local originmoney = goods.originmoney;
    local name = goods.name;


	--用户金钱
    if goods.cate_id and goods.cate_id == 11 then
	    self.m_money_text = new(Text, goods.name, 0, 0, nil,nil,mall_money_fontsize,80, 80, 80)
    else
	    self.m_money_text = new(Text, goods.money..goods.name, 0, 0, nil,nil,mall_money_fontsize,80, 80, 80)
	end
	self.m_money_text:setPos(money_x,money_y);
	self.m_img_bg:addChild(self.m_money_text);

	local money_w,money_h = self.m_money_text:getSize();

    --商品图片
	self.m_goods_icon = new(Image,MallShopItem.ICON_PRE .. goods.imgurl .. ".png");
	local icon_w,icon_h = self.m_goods_icon:getSize();

	self.m_goods_icon:setPos(icon_x,icon_y);
    self.m_goods_icon:setAlign(kAlignLeft);
	self.m_img_bg:addChild(self.m_goods_icon);
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

    local icon = new(Image,"common/icon/sale_icon.png");
	icon:setPos(price_x+380,price_y+1);
    icon:setAlign(kAlignTopLeft);
	self.m_img_bg:addChild(icon);

    if goods.cate_id and goods.cate_id == 11 then
        originmoney = "";
        name = "有效期:30天";
        self.m_originmoney_text = new(Text, originmoney .. name, 0, 0, nil,nil,mall_originmoney_fontsize,120,85,60);
        self.m_originmoney_text:setPickable(false)
    else
        self.m_originmoney_text = new(Text, originmoney .. name, 0, 0, nil,nil,mall_originmoney_fontsize,120,120,120);
    end
    self.m_originmoney_text:setPos(originmoney_x,originmoney_y);
    self.m_img_bg:addChild(self.m_originmoney_text);
	if goods.label then
		if goods.label == 1 then --打折
			self.m_label = 	 new(Image,"common/icon/discount_icon.png");
			self.m_label:setPos(bg_x ,bg_y);
			self.m_img_bg:addChild(self.m_label);
            self.m_oringin_line = 	new(Image,MallShopItem.ICON_PRE .. "mall_discount_line.png");
--            self.m_originmoney_text = new(Text, originmoney .. name, 0, 0, nil,nil,mall_originmoney_fontsize,120,120,120);          
            local w,h = self.m_originmoney_text:getSize();
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
end

MallShopItem.buyGoods = function(self)
	print_string("MallShopItem.buyGoods goods = " .. self.m_data.money);

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

MallShopItem.isPay = function(self)
    return self.m_isPay;
end

MallShopItem.onTuchProcess = function(self,enable)
    if self.m_data and self.m_data.desc and self.m_data.desc ~= "" then
        if not enable then
            local x,y = self:getAbsolutePos();
            MallScene.tip_bg:setPos(0,y-400); -- 220 的 自身高  220 的父类节点高
            MallScene.tip_bg:setVisible(true);
            Log.i("1111111111111");
            local anim = MallScene.tip_bg:addPropTransparency(1, kAnimNormal, 0, 1000, 0, 1);
            if anim then
                self.m_isPay = true;
                anim:setEvent(self,function(self)
                        Log.i("22222222222222");
                        self.m_isPay = false;
                        MallScene.tip_bg:removeAllChildren(true);
                        local w,h = MallScene.tip_bg:getSize();
                        node = new(Node);
                        node:setSize(w-40,h-50);
                        node:setPos(20,20);
                        node:setClip(20,20,w-40,h-50);
                        text = new(RichText, self.m_data.desc, w-40, h-50, kAlignTopLeft, nil, 32, 80, 80, 80, true,10);
                        node:addChild(text);
                        MallScene.tip_bg:addChild(node);
                        local tw,th = text:getSize();
                        if th > h then
                            local diff = th - h;
                            local anim = text:addPropTranslate(1, kAnimNormal, diff*30+1500, 1500, 0, 0, 0, -diff-h/2);
            --                anim:setEvent(text,function(self)
            --                    text:addPropTranslate(1, kAnimNormal, diff*1000/32, 4000, 0, 0, 0, -diff);
            --                end);
                        end
                    end);
            end
        else
            Log.i("333333333333");
            MallScene.tip_bg:removeAllChildren(true);
            MallScene.tip_bg:setVisible(false);
            MallScene.tip_bg:removeProp(1);
        end
    end
end

MallShopItem.getData = function(self)
	return self.m_data;
end

MallShopItem.getMoneyView = function(self)
    return self.m_money_text;
end

MallShopItem.getPriceView = function(self)
    return self.m_goods_price;
end


MallShopItem.dtor = function(self)
	
end	

------道具商品Item
MallPropItem = class(Node);
MallPropItem.ctor = function(self,prop)
	self.data = prop;

	self.line_h = 151;

    self:setPos(0,0);     --位置
    self:setSize(720,220);    --大
    self.m_isPay = true;
    local itemBgImgStr = "common/background/item_bg.png";
	local itemBgImg = new(Button,itemBgImgStr);				
	itemBgImg:setAlign(kAlignCenter); 								
	itemBgImg:setVisible(true);	
    itemBgImg:setOnTuchProcess(self,self.onTuchProcess)
	self:addChild(itemBgImg);
    local statusImgStr;
	if self.data.label then
		if self.data.label == 1 then --打折
      		statusImgStr = "common/icon/discount_icon.png";
		elseif self.data.label == 2 then	
     		statusImgStr = "common/icon/hot_icon.png";
		end
	end

	if statusImgStr then
		local sellStatusImg = new(Image,statusImgStr);
		sellStatusImg:setSize(104,102);								
		sellStatusImg:setPos(35,15); 								
		sellStatusImg:setVisible(true);	
		itemBgImg:addChild(sellStatusImg);		
	end

	self:addNomalMallPropItem(itemBgImg,self.data);
end

MallPropItem.onTuchProcess = function(self,enable)
    if self.data and self.data.desc and self.data.desc ~= "" then
        if not enable then
            local x,y = self:getAbsolutePos();
            MallScene.tip_bg:setPos(0,y-400); -- 220 的 自身高  220 的父类节点高
            MallScene.tip_bg:setVisible(true);
            Log.i("1111111111111");
            local anim = MallScene.tip_bg:addPropTransparency(1, kAnimNormal, 0, 1000, 0, 1);
            if anim then
                self.m_isPay = true;
                anim:setEvent(self,function(self)
                        Log.i("22222222222222");
                        self.m_isPay = false;
                        MallScene.tip_bg:removeAllChildren(true);
                        local w,h = MallScene.tip_bg:getSize();
                        node = new(Node);
                        node:setSize(w-40,h-50);
                        node:setPos(20,20);
                        node:setClip(20,20,w-40,h-50);
                        text = new(RichText, self.data.desc, w-40, h-50, kAlignTopLeft, nil, 32, 80, 80, 80, true,10);
                        node:addChild(text);
                        MallScene.tip_bg:addChild(node);
                        local tw,th = text:getSize();
                        if th > h then
                            local diff = th - h;
                            local anim = text:addPropTranslate(1, kAnimNormal, diff*30+1500, 1500, 0, 0, 0, -diff-h/2);
            --                anim:setEvent(text,function(self)
            --                    text:addPropTranslate(1, kAnimNormal, diff*1000/32, 4000, 0, 0, 0, -diff);
            --                end);
                        end
                    end);
            end
        else
            Log.i("333333333333");
            MallScene.tip_bg:removeAllChildren(true);
            MallScene.tip_bg:setVisible(false);
            MallScene.tip_bg:removeProp(1);
        end
    end
end

MallPropItem.addCoinGoodsItem = function(self,bgImg,data)
	self.data  = data;

	local leftImgStr = "mall/mall_list_gold3.png";
	local leftImg = new(Image,leftImgStr);
	leftImg:setPos(25,25); 								
	leftImg:setVisible(true);	
	bgImg:addChild(leftImg);

    local money = "66,000金币"
	local money_x,money_y = 180,40;
	local money_fontsize = 30;

	local moneyText = new(Text, money, 0, 0, nil,nil,money_fontsize,255, 255, 206);
	moneyText:setPos(money_x,money_y);
	bgImg:addChild(moneyText);

    local oldmoney = "60,000金币"
	local oldmoney_x,oldmoney_y = 180,70;
	local oldmoney_fontsize = 20;

	oldmoneyText = new(Text, oldmoney, 0, 0, nil,nil,oldmoney_fontsize,69,157,79);
	oldmoneyText:setPos(oldmoney_x,oldmoney_y);
	bgImg:addChild(oldmoneyText);
end


MallPropItem.addNomalMallPropItem = function(self,bgImg,data)

		local leftImgStr=nil;
		local propdescStr = nil;
        if data.imgurl and data.imgurl ~= "" then
            leftImgStr = "mall/"..data.imgurl..".png";
        else
    		local startNum = data.goods_type;
            if startNum == 1 then--生命回复
--			    leftImgStr = "drawable/ending_buy_life_full_texture.png";
			    self.data.position = MALL_LIFERECOVER;
			    propdescStr = "使用加满生命值（仅限残局挑战、单机游戏使用）。";
		    elseif startNum == 2 then --悔棋
			    leftImgStr = "common/icon/undo_icon.png";
			    self.data.position = MALL_UNDO;
			    propdescStr = "返回上一步（仅限残局挑战、单机游戏使用）。";
		    elseif startNum == 3 then --提示
			    leftImgStr = "common/icon/tips_icon.png";
			    self.data.position = MALL_TIPS;
			    propdescStr = "当前最准确走棋方式（仅限残局挑战使用）。";
		    elseif startNum == 4 then --起死回生
			    leftImgStr = "common/icon/relive_icon.png";
			    self.data.position = MALL_SAVELIFE;
			    propdescStr = "返回至出错的前一步，不消耗生命。（仅限残局挑战使用）。";
		    elseif startNum == 5 then --增加生命上限
--			    leftImgStr = "drawable/maximum_life_level_add3_icon.png";
			    self.data.position = MALL_LIFELEVEL;
			    propdescStr = "可以帮你增加生命值上限（仅限残局挑战、单机游戏使用）。";
		    elseif startNum == 12 then
                leftImgStr = "mall/tel_fare_5.png";
            end
        end 

        if data.goods_type == 12 then
            leftImgStr = "mall/tel_fare_5.png";
        end
--        if data.desc then
--            propdescStr = data.desc;
--        end
	
		if leftImgStr then
			local leftImg = new(Image,leftImgStr);
			leftImg:setPos(60,-5); 								
			leftImg:setVisible(true);	
            leftImg:setAlign(kAlignLeft);
			bgImg:addChild(leftImg);
		end
        local propdesc_x,propdesc_y = 195,85;
		if propdescStr then
			local propdesc_fontsize = 24;
			local propdescText = new(TextView, propdescStr, 400, 0, nil,nil,propdesc_fontsize,160, 110, 95);
            propdescText:setPickable(false);
			propdescText:setPos(propdesc_x,propdesc_y);
			bgImg:addChild(propdescText);
		end

        

	    local propNameStr = data.name
		local propName_x,propName_y = 195,35;
		local propName_fontsize = 36;

		local propNameText = new(Text, propNameStr, 0, 0, nil,nil,propName_fontsize,80, 80, 80);
		propNameText:setPos(propName_x,propName_y);
		bgImg:addChild(propNameText);

        local leftText = new(Text,"剩余：",nil,nil,nil,nil,30,80,80,80);
        local leftNum = new(Text,"",nil,nil,nil,nil,30,25,115,40);
        leftText:setPos(propdesc_x,propdesc_y+20);
        leftNum:setPos(propdesc_x + 80,propdesc_y+20);
        if data.goods_type == 12 then
            propNameText:setPos(nil,propName_y+18);
            leftNum:setText("" .. data.stock_num);
            leftNum:setVisible(true);
            leftText:setVisible(true);     
        else            
            leftNum:setVisible(false);
            leftText:setVisible(false);
        end
        bgImg:addChild(leftText);
        bgImg:addChild(leftNum);

   		local priceStr = ""
		if data.exchange_num then
            if data.exchange_num > 10000 then
                priceStr = string.format("%.1fW",data.exchange_num/10000);
            else
			    priceStr = data.exchange_num;
            end
		end

        local price_x,price_y = 90,30;
        if data.exchange_type == 1 then
            priceStr = priceStr.."元宝";
        elseif data.exchange_type == 4 then
            priceStr = priceStr.."棋魂";
            price_x = 80;
            price_y = 70;
        else
            priceStr = priceStr.."金币";
        end
        data.msg = string.format("是否用%s兑换%s?",priceStr,data.name);--兑换dialog要用的参数

		
		local price_fontsize = 40;

		local priceText = new(Text, priceStr, 0, 0, kAlignLeft,nil,price_fontsize,125, 80, 65);
		priceText:setPos(price_x + 350,price_y+2);
        priceText:setAlign(kAlignTopLeft);
		bgImg:addChild(priceText);

        local w,h = priceText:getSize();

        local icon = new(Image,"mall/rechange.png");
		icon:setPos(price_x+300,price_y+3);
        icon:setAlign(kAlignTopLeft);
		bgImg:addChild(icon);
end

MallPropItem.getData = function(self)
    return self.data;
end

MallPropItem.isPay = function(self)
    return self.m_isPay;
end

MallPropItem.dtor = function(self)
	
end