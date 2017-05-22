require(BASE_PATH.."chessScene");
require("ui/listView");

require(VIEW_PATH .. "exchange_view_node");
require("dialog/input_tel_no_dialog");
require("dialog/exchange_tips_dialog");

ExchangeScene = class(ChessScene);

ExchangeScene.s_controls = 
{
	back_btn = 1;
    moneyText = 2;
    soul_count_text = 3;
--    exchange_list_view = 4;
    title_view        = 5;
    tea_cup = 6;
    stone = 7;
    user_info_view = 8;
}

ExchangeScene.s_cmds = 
{
   showSoulListView = 1;
   showTipsDlg = 2;
   showInputDlg = 3;
   updateUserInfoView = 4;
   updateListAdapter = 5;
}

ExchangeScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = ExchangeScene.s_controls;
    self:create();
end 
ExchangeScene.resume = function(self)
    ChessScene.resume(self);
    self:updateUserInfoView();
    self:removeAnimProp();
    self:resumeAnimStart();
end;


ExchangeScene.pause = function(self)
	ChessScene.pause(self);
    self:removeAnimProp();
    self:pauseAnimStart();
end 


ExchangeScene.dtor = function(self)
    delete(self.m_exchange_tips_dialog);
    delete(self.m_input_telno_dialog);
end 

----------------------------------- function ----------------------------

ExchangeScene.create = function(self)
--动画
    self.tea_cup = self:findViewById(self.m_ctrls.tea_cup);
    self.stone = self:findViewById(self.m_ctrls.stone);
    self.top_title_view = self:findViewById(self.m_ctrls.title_view);
    self.back_btn = self:findViewById(self.m_ctrls.back_btn);
    self.userinfo_view = self:findViewById(self.m_ctrls.user_info_view);
--
    self.m_moneyText = self:findViewById(self.m_ctrls.moneyText);
    self.m_soul_count_text = self:findViewById(self.m_ctrls.soul_count_text);
    self.m_exchange_list_view = new(ListView,0,226,680,940);
    self.m_exchange_list_view:setAlign(kAlignTop);
--    self.m_exchange_list_view = self:findViewById(self.m_ctrls.exchange_list_view);
    self.m_exchange_list_view:setDirection(kVertical);
    self:addChild(self.m_exchange_list_view);
end


ExchangeScene.removeAnimProp = function(self)
    self.top_title_view:removeProp(1);
    self.stone:removeProp(1);
    self.tea_cup:removeProp(1);
    self.back_btn:removeProp(1);
    self.m_exchange_list_view:removeProp(1);
    self.userinfo_view:removeProp(1);
end

ExchangeScene.resumeAnimStart = function(self)
    local duration = 500;
    local delay = -1;

    local w,h = self.top_title_view:getSize();
    local anim = self.top_title_view:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, -h, 0);

    local w,h = self.stone:getSize();
    self.stone:addPropTranslate(1, kAnimNormal, duration, delay, w, 0, 0, 0);
   
    local w,h = self.tea_cup:getSize();
    self.tea_cup:addPropTranslate(1, kAnimNormal, duration, delay, -w, 0, 0, 0);

    self.back_btn:addPropTransparency(1,kAnimNormal,duration,delay,0,1);

    self.m_exchange_list_view:addPropTransparency(1,kAnimNormal,duration,delay,0,1);
    self.userinfo_view:addPropTransparency(1,kAnimNormal,duration,delay,0,1);
end

ExchangeScene.pauseAnimStart = function(self)
    local duration = 500;
    local delay = -1;

    local w,h = self.top_title_view:getSize();
    local anim = self.top_title_view:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, 0, -h);

    local w,h = self.stone:getSize();
    self.stone:addPropTranslate(1, kAnimNormal, duration, delay, 0, w, 0, 0);
   
    local w,h = self.tea_cup:getSize();
    self.tea_cup:addPropTranslate(1, kAnimNormal, duration, delay, 0, -w, 0, 0);

    self.back_btn:addPropTransparency(1,kAnimNormal,duration,delay,1,0);

    self.m_exchange_list_view:addPropTransparency(1,kAnimNormal,duration,delay,1,0);
    self.userinfo_view:addPropTransparency(1,kAnimNormal,duration,delay,1,0);
end

ExchangeScene.onBack = function(self)
    self:requestCtrlCmd(ExchangeController.s_cmds.onBack);
end

ExchangeScene.updateUserInfoView = function(self)
    self.m_moneyText:setText(UserInfo.getInstance():getMoneyStr());
    self.m_soul_count_text:setText(UserInfo.getInstance():getSoulCount());
end

ExchangeScene.showListView = function(self,datalist)
	self.datalist = datalist;
	self.m_exchangeItemAdapter = new(CacheAdapter,ExchangeItem,datalist);
--	local w,h = self.m_exchange_list_view:getSize();

--	self.m_exchnage_list = new(ListView,0,0,w,h);
    self.m_exchange_list_view:setAdapter(self.m_exchangeItemAdapter);
--	self.m_exchange_list_view:addChild(self.m_exchnage_list);

end

ExchangeScene.showTipsDlg = function(self,title,tips)
	if not self.m_exchange_tips_dialog then
		self.m_exchange_tips_dialog = new(ExchangeTipsDialog,title,tips);
	end
	self.m_exchange_tips_dialog:show(title,tips);
end

ExchangeScene.showInputDlg = function(self,data)
	if not self.m_input_telno_dialog then
		self.m_input_telno_dialog = new(InputTelNoDialog,data);
	end
	self.m_input_telno_dialog:show(data);
end

ExchangeScene.updateListAdapter = function(self,index,imageName)
    Log.i("ExchangeScene.updateListAdapter");
    if not self.m_exchangeItemAdapter then
		return
	end
	local data = self.m_exchangeItemAdapter:getData();
	local goods = ToolKit.copyTable(data[index]);

	if self.datalist then
		self.datalist[index] = goods;
	end
			
	goods.goodsImg = imageName .. ".png";
	print_string(" goods.goodsImg = " .. goods.goodsImg);
	self.m_exchangeItemAdapter:updateData(index,goods);
end
----------------------------------- onClick ---------------------------------


----------------------------------- config ------------------------------
ExchangeScene.s_controlConfig = 
{
	[ExchangeScene.s_controls.back_btn] = {"back_btn"};
    [ExchangeScene.s_controls.title_view] = {"title_view"};
    [ExchangeScene.s_controls.user_info_view] = {"userinfo_view"};
	[ExchangeScene.s_controls.moneyText] = {"userinfo_view","gold_num"};
	[ExchangeScene.s_controls.soul_count_text] = {"userinfo_view","soul_count_text"};
--	[ExchangeScene.s_controls.exchange_list_view] = {"exchange_list_view"};

    [ExchangeScene.s_controls.tea_cup] = {"teapot_dec"};
    [ExchangeScene.s_controls.stone] = {"stone_dec"};
    
};

ExchangeScene.s_controlFuncMap =
{
	[ExchangeScene.s_controls.back_btn] = ExchangeScene.onBack;

};


ExchangeScene.s_cmdConfig =
{
    [ExchangeScene.s_cmds.showSoulListView] = ExchangeScene.showListView;
    [ExchangeScene.s_cmds.showTipsDlg] = ExchangeScene.showTipsDlg;
    [ExchangeScene.s_cmds.showInputDlg] = ExchangeScene.showInputDlg;
    [ExchangeScene.s_cmds.updateUserInfoView] = ExchangeScene.updateUserInfoView;
    [ExchangeScene.s_cmds.updateListAdapter] = ExchangeScene.updateListAdapter;
    
}


--------------------- private node ---------

-- id 实物ID 
-- amount 实物当前库存 
-- name 名称（仅status=1时返回） 
-- img 图片（仅status=1时返回） 
-- cost 兑换价格（仅status=1时返回） 
--ExchangeScene.DEFAULT_GOODS_IMG = "drawable/exchange_goods_icon.png";
--ExchangeScene.GOODS_IMG = "GOODS";

------商品Item
ExchangeItem = class(Node);

ExchangeItem.s_width = 660;
ExchangeItem.s_height = 210;

ExchangeItem.ctor = function(self,goods)
	self.data = goods;

    self.m_root_view = SceneLoader.load(exchange_view_node);
    self:addChild(self.m_root_view);
    
    self:setSize(ExchangeItem.s_width,ExchangeItem.s_height);
    self.node_btn = self.m_root_view:getChildByName("item_btn");
--	self.line_h = 139;

--    self:setPos(0,0);     --位置
--    self:setSize(480,139);    --大
    self.goodName = self.node_btn:getChildByName("name");
    self.goodName:setText(goods.name);

    self.icon = self.node_btn:getChildByName("icon"); --商品图标

--	local goodsname = goods.name;
--    local goodsNameText = new(Text,goodsname,nil,nil,kTextAlignLeft,"",26,250,230,180);  
--    goodsNameText:setPos(145,25); 
--    goodsNameText:setVisible(true);
--	self:addChild(goodsNameText);	

--    local leftLabel = new(Text,"剩：",nil,nil,kTextAlignLeft,"",20,250,230,180);  
--    leftLabel:setPos(145,58); 
--    leftLabel:setVisible(true);
--	self:addChild(leftLabel);	
    
    self.goodNum = self.node_btn:getChildByName("num");
    self.goodNum:setText(goods.amount);
--    local leftText = new(Text,goods.amount,nil,nil,kTextAlignLeft,"",20,255,174,0);  
--    leftText:setPos(175,58); 
--    leftText:setVisible(true);
--	self:addChild(leftText);	

--    local needLabel = new(Text,"需：",nil,nil,kTextAlignLeft,"",20,250,230,180);  
--    needLabel:setPos(145,85); 
--    needLabel:setVisible(true);
--	self:addChild(needLabel);	

--    local needText = new(Text,goods.cost.."棋魂",nil,nil,kTextAlignLeft,"",20,255,174,0);  
--    needText:setPos(175,85); 
--    needText:setVisible(true);
--	self:addChild(needText);	

    self.soul_change = self.node_btn:getChildByName("soul_change");
    self.soul_change:setText(goods.cost .. "棋魂");

--	local soulIconStr = "drawable/chess_soul.png";
--	local soulIcon = new(Image,soulIconStr);
--	soulIcon:setSize(24,26);								
--	soulIcon:setPos(280,82); 								
--	soulIcon:setVisible(true);	
--	self:addChild(soulIcon);	

--	local leftImgBgStr = "drawable/goods_frame.png";
--	local leftImgBg = new(Image,leftImgBgStr);
--	leftImgBg:setSize(108,108);								
--	leftImgBg:setPos(20,13); 								
--	leftImgBg:setVisible(true);	
--	self:addChild(leftImgBg);		

		

--	goods.goodsImg = goods.goodsImg or ExchangeScene.DEFAULT_GOODS_IMG;
--	local leftImg = new(Image,goods.goodsImg);
--	leftImg:setSize(95,95);								
--	leftImg:setPos(25.5,19); 								
--	leftImg:setVisible(true);	
--	self:addChild(leftImg);	

	--拉取商品图标
--	if goods.goodsImg == ExchangeScene.DEFAULT_GOODS_IMG then
--		local icon_name = ExchangeScene.GOODS_IMG .. goods.index;
--	end

--    local dividerImgStr = "drawable/userinfo_line_texture.png";
--	local dividerImg = new(Image,dividerImgStr);
--	dividerImg:setSize(478,82);								
--	dividerImg:setPos(1,93); 								
--	dividerImg:setVisible(true);	
--	self:addChild(dividerImg);	

	if not goods.isExchange then
--	    local exchnageImgStr = "drawable/mall_pay_order_fail.png";
--	  	local exchange_btn = new(Button,exchnageImgStr);
--		exchange_btn:setSize(130,54);								
--		exchange_btn:setPos(338,40); 								
--		exchange_btn:setVisible(true);	  
--		self:addChild(exchange_btn);	

--		self.node_btn.onClick = function(selfBtn)	
--			local data = self:getData();
--			local id = data.id;
--			local soulcount = UserInfo.getInstance():getSoulCount();
--			if data.cost > soulcount then
--                local msg = "很抱歉，您的棋魂不足以兑换该奖品，玩游戏有几率获得棋魂，赶紧去赚取吧！";
--		        local title = "兑换失败";	
--				EventDispatcher.getInstance():dispatch(Event.Call, SOUL_NOT_ENOUGH_FOR_COST,title,msg);
--				return;
--			end

--			if goods.type == "card" and (goods.tel == nil  or  goods.tel  == "" )	then
--				EventDispatcher.getInstance():dispatch(Event.Call, SHOW_INPUT_TEL_NO,goods);
--				return;
--			end
--            local post_data = {};
--	        post_data.method =  PhpConfig.METHOD_EXCHANGE_SOUL;
--	        post_data.id = id;
--	        post_data.phone = goods.tel or 0;
--            HttpModule.getInstance():execute(HttpModule.s_cmds.exchangeSoul,post_data);
--		end

        local info = {};
        info.item = self;
        info.data = self.data;
		self.node_btn:setOnClick(info,self.onClick);        --点击回调接口

--	    local exchangeBtnLabel = new(Text,"兑换",nil,nil,kTextAlignLeft,"",25,0,0,0);  
--	    exchangeBtnLabel:setPos(40,12); 
--	    exchangeBtnLabel:setVisible(true);
--		exchange_btn:addChild(exchangeBtnLabel);	
	else
--	    local exchangedText = new(Text,"已兑换",nil,nil,kTextAlignCenter,"",27,80,190,130);  
--		exchangedText:setPos(362,40); 								
--	    exchangedText:setVisible(true);
--		self:addChild(exchangedText);	
	end
end

ExchangeItem.onClick = function(obj)
    self = obj.item
    local data = self.data;
    local id = data.id;
    local soulcount = UserInfo.getInstance():getSoulCount();
    if data.cost > soulcount then
        local msg = "很抱歉，您的棋魂不足以兑换该奖品，玩游戏有几率获得棋魂，赶紧去赚取吧！";
        local title = "兑换失败";	
        EventDispatcher.getInstance():dispatch(Event.Call, SOUL_NOT_ENOUGH_FOR_COST,title,msg);
        return;
    end

    if goods.type == "card" and (goods.tel == nil  or  goods.tel  == "" )	then
        EventDispatcher.getInstance():dispatch(Event.Call, SHOW_INPUT_TEL_NO,goods);
        return;
    end
    local post_data = {};
    post_data.method =  PhpConfig.METHOD_EXCHANGE_SOUL;
    post_data.id = id;
    post_data.phone = goods.tel or 0;
    HttpModule.getInstance():execute(HttpModule.s_cmds.exchangeSoul,post_data);
end

ExchangeItem.getSize = function(self)
	return 680,170;--self.line_h;
end

ExchangeItem.getData = function(self)
	return self.data ;
end

ExchangeItem.dtor = function(self)
	
end	