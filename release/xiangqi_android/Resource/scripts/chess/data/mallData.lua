MallData = class();

MallData.s_mallType = {
    shop = 0;
    prop = 1;
}

MallData.PID_PROP = 100; --道具pid
MallData.PID_COIN = 101; --金币购买pid
MallData.PID_VIP = 102; --vip pid
MallData.PID_SOUL = 103; --棋魂兑换pid
MallData.PID_BOARD = 104; --棋盘pid
MallData.PID_GIFT = 105; --礼物pid
MallData.PID_BOYAA = 106; --元宝商品
MallData.PID_BAG = 107; --大礼包
MallData.PID_FRAME = 108; --头像框
MallData.PID_TICKET_ONLINE = 109; --线上参赛券
MallData.PID_SOUL = 110; --棋魂
MallData.PID_TICKET_OFFLINE = 111; --线下参赛券

MallData.getInstance = function()
    if not MallData.instance then
        MallData.instance = new(MallData);
    end
    return MallData.instance;
end

MallData.setMallType = function(self,mallType)
    self.m_mallType = mallType;
end

MallData.getMallType = function(self)
    return self.m_mallType or MallData.s_mallType.shop;
end

MallData.setMallData = function(self,data)
    self.m_mallData = data;
end

MallData.getMallData = function(self)
    return self.m_mallData;
end

MallData.setMallPropData = function(self,data)
    self.m_propData = data;
end

MallData.getMallPropData = function(self)
    return self.m_propData;
end

function MallData.setGiftList(self,data)
    self.m_giftProp = data;
    local str = json.encode(self.m_giftProp)
    GameCacheData.getInstance():saveString(GameCacheData.GIFT_DATA,str)
end

function MallData.getGiftList(self)
    if not self.m_giftProp or next(self.m_giftProp) == nil then
        local data = GameCacheData.getInstance():getString(GameCacheData.GIFT_DATA)
        self.m_giftProp = {}
        if data then
            self.m_giftProp = json.decode(data)
        end
    end
    return self.m_giftProp;
end

function MallData.getGiftCost(self,giftIndex)
    if not giftIndex then return end
    local data = self.m_giftProp
    local cost = 0
    if not data or next(data) == nil then
        local tempdata = GameCacheData.getInstance():getString(GameCacheData.GIFT_DATA)
        if tempdata then
            data = json.decode(tempdata)
        end
    end
    for k,v in pairs(data) do
        if v and tonumber(v.cate_id) == giftIndex then
            cost = tonumber(v.exchange_num) or 0
            return cost
        end
    end
    return cost;
end

function MallData.getGiftReciveCharm(self,giftIndex)
    if not giftIndex then return end
    local data = self.m_giftProp
    local recv_charm = 0
    if not data or next(data) == nil then
        local tempdata = GameCacheData.getInstance():getString(GameCacheData.GIFT_DATA)
        if tempdata then
            data = json.decode(tempdata)
        end
    end
    for k,v in pairs(data) do
        if v and tonumber(v.cate_id) == giftIndex then
            if v.charm_value then
                recv_charm = tonumber(v.charm_value.receive) or 0
            end;
            return recv_charm
        end
    end
    return recv_charm;
end
------------------------- shop -------------------------
-- 弃用  因为商城数据 需要实时筛选
MallData.getShopData = function(self)
    if not self:getMallData() then
        self:sendGetShopInfo();
    end
--    local MallGoods_List = GameCacheData.MALL_GOODS_LIST;
--	if PhpConfig.getBid() then
--		MallGoods_List = MallGoods_List..PhpConfig.getBid();
--	end
--    local ret,errMessage = pcall(
--        function() -- 捕捉到异常后把数据清理
--	        local ret = GameCacheData.getInstance():getString(MallGoods_List,nil);
--            shopData = self:safeShopData(json.decode(ret));
--            self:setMallData(shopData);
--            return shopData;
--        end
--    );
--    if ret then
--        self:setMallData(errMessage);
--        return errMessage;
--    else
--        local MallShop_Version = GameCacheData.Mall_SHOP_VERSION;
--        if PhpConfig.getBid() then
--	        MallShop_Version = MallShop_Version..PhpConfig.getBid();
--        end
--        GameCacheData.getInstance():saveInt(MallShop_Version,0);
--        self:setMallData();
--        self:sendGetShopInfo();
--        return nil;
--    end
end

MallData.sendGetShopInfo = function(self,isNeedTips)
    isNeedTips = isNeedTips == nil or isNeedTips;
    local tips = "正在获取商品信息...";
	local post_data = {};

	local MallShop_Version = GameCacheData.Mall_SHOP_VERSION;
	if PhpConfig.getBid() then
		MallShop_Version = MallShop_Version..PhpConfig.getBid();
	end

	local version = GameCacheData.getInstance():getInt(MallShop_Version,0);
	post_data.version = 0--version;
	post_data.mid = UserInfo.getInstance():getUid();
    if isNeedTips then
        HttpModule.getInstance():execute(HttpModule.s_cmds.getShopInfo,post_data,tips);
    else
        HttpModule.getInstance():execute(HttpModule.s_cmds.getShopInfo,post_data);
    end
end

function MallData:getPayRecommendGoods()
    return self.mPayRecommendGoods
end
--[Comment]
-- 通过商品id获取商品
function MallData:getGoodsById(searchId)
    searchId = tonumber(searchId) or 0
    if self.m_mallData then
        for _,goods in pairs(self.m_mallData) do
            if tonumber(goods.goods_id) == searchId then
                return goods
            end
        end
    end
    return nil
end

--[Comment]
-- 通过商品id获取道具
function MallData:getPropById(searchId)
    searchId = tonumber(searchId) or 0
    if self.m_propData then
        for _,goods in pairs(self.m_propData) do
            if tonumber(goods.id) == searchId then
                return goods
            end
        end
    end
    return nil
end

--[Comment]
-- 通过商品 > money 的商品 或者最大的商品
function MallData:getGoodsByMoreMoney(money)
    money = tonumber(money) or 0
    local retGoods = nil
    -- 找> money 的商品
    if self.m_shopData then
        for _,goods in pairs(self.m_shopData) do
            if goods.pid == MallData.PID_COIN then
                if goods.money > money and (not retGoods or retGoods.money > goods.money ) then
                    retGoods = goods
                end
            end
        end
    end
    -- 找最大的商品
    if not retGoods then
        if self.m_shopData then
            for _,goods in pairs(self.m_shopData) do
                if goods.pid == MallData.PID_COIN then
                    if not retGoods or retGoods.money < goods.money then
                        retGoods = goods
                    end
                end
            end
        end
    end
    return retGoods
end


--[Comment]
-- 通过商品 > money 的商品 或者最大的商品 元宝
function MallData:getGoodsByMoreBccoin(money)
    money = tonumber(money) or 0
    local retGoods = nil
    -- 找> money 的商品
    if self.m_shopData then
        for _,goods in pairs(self.m_shopData) do
            if goods.pid == MallData.PID_BOYAA then
                if goods.money > money and (not retGoods or retGoods.money > goods.money ) then
                    retGoods = goods
                end
            end
        end
    end
    -- 找最大的商品
    if not retGoods then
        if self.m_shopData then
            for _,goods in pairs(self.m_shopData) do
                if goods.pid == MallData.PID_BOYAA then
                    if not retGoods or retGoods.money < goods.money then
                        retGoods = goods
                    end
                end
            end
        end
    end
    return retGoods
end

function MallData:getVipGoods()
    local retGoods = nil
    if kPlatform == kPlatformIOS then
        if self.m_propData then
            for _,goods in pairs(self.m_propData) do
                if goods.pid == MallData.PID_VIP then
                    if not retGoods then
                        retGoods = goods
                        break;
                    end
                end
            end
        end
        return retGoods
    end
    if self.m_shopData then
        for _,goods in pairs(self.m_shopData) do
            if goods.pid == MallData.PID_VIP then
                if not retGoods then
                    retGoods = goods
                    break;
                end
            end
        end
    end
    return retGoods
end

MallData.explainShopData = function(self,message)
    local data = message.data;
	local version = message.version:get_value();
    local status = message.status:get_value();
    local enable_goods = message.enable_goods;

    if not message.enable_goods:get_value() then
        enable_goods = {}
    end

    local showList = {};
    for _,value in pairs(enable_goods) do 
        local enableGoods = {};
        enableGoods.id = tonumber(value:get_value()) or 0;
        table.insert(showList,enableGoods);
    end

    if message.pay_recommend:get_value() then
        local payRecommend = json.analyzeJsonNode(message.pay_recommend)
        self.mPayRecommendGoods = {}
        self.mPayRecommendGoods.enterRoom = {}
        if type(payRecommend.enter_room) == "table" then
            for key,val in pairs(payRecommend.enter_room) do
                if kPlatform == kPlatformIOS then
                    self.mPayRecommendGoods.enterRoom[tonumber(key)] = val.ios or 0
                else
                    self.mPayRecommendGoods.enterRoom[tonumber(key)] = val.android or 0
                end
            end
        end
        self.mPayRecommendGoods.buyProp = 0
        if type(payRecommend.buy_prop) == "table" then
            if kPlatform == kPlatformIOS then
                self.mPayRecommendGoods.buyProp = payRecommend.buy_prop.ios or 0
            else
                self.mPayRecommendGoods.buyProp = payRecommend.buy_prop.android or 0
            end
        end
        self.mPayRecommendGoods.hall = 0
        if type(payRecommend.hall) == "table" then
            if kPlatform == kPlatformIOS then
                self.mPayRecommendGoods.hall = payRecommend.hall.ios or 0
            else
                self.mPayRecommendGoods.hall = payRecommend.hall.android or 0
            end
        end
    end

    if tonumber(status) == 0 then
        local MallGoods_List = GameCacheData.MALL_GOODS_LIST;
		if PhpConfig.getBid() then
			MallGoods_List = MallGoods_List..PhpConfig.getBid();
		end
		local ret = GameCacheData.getInstance():getString(MallGoods_List,nil);
        local list = self:safeShopData(json.decode(ret));
        local tempData = {};
        for _,v in pairs(list) do
            for _,m in pairs(showList) do
                if m.id == v.goods_id then
                     table.insert(tempData,v);
                end
            end
        end
        self.m_shopData = tempData
        self:setMallData(list);
        return tempData;
    end

	local MallShop_Version = GameCacheData.Mall_SHOP_VERSION;
	if PhpConfig.getBid() then
		MallShop_Version = MallShop_Version..PhpConfig.getBid();
	end

	GameCacheData.getInstance():saveInt(MallShop_Version,version);

	if not data then
		print_string("not data");
		return;
	end

	if #data <= 0 then
		print_string("not datas");
		return;
	end

    data = json.analyzeJsonNode(data)

	if data then
		local MallGoods_List = GameCacheData.MALL_GOODS_LIST;
		if PhpConfig.getBid() then
			MallGoods_List = MallGoods_List..PhpConfig.getBid();
		end
		GameCacheData.getInstance():saveString(MallGoods_List,json.encode(data));
	end

    local list = self:safeShopData(data)
    local tempData = {}; 
	for _,value in pairs(list) do 
        if value.isShow == 1 then
            for _,v in pairs(showList) do
                if value.goods_id == v.id then
		            table.insert(tempData,value);
                end
            end
		end
	end
    self.m_shopData = tempData
    self:setMallData(list);
    return tempData;
end

function MallData:safeShopData(datas)
    if type(datas) ~= "table" then return nil end

    local list  = {}
	for _,value in pairs(datas) do 
		local goods = {};
		goods.id       		= tonumber(value.id) or 0;
		goods.name     		= value.name;
		goods.pid    		= tonumber(value.pid) or 0;
		goods.money    		= tonumber(value.money) or 0;
		goods.paysid   		= tonumber(value.paysid) or 0;
		goods.appid    		= tonumber(value.appid) or 0;
		goods.pmode         = tonumber(value.pmode) or 0;
		goods.type     		= tonumber(value.type) or 0;
		goods.label    		= tonumber(value.label) or 0;
		goods.originmoney   = tonumber(value.originmoney) or 0;
		goods.imgurl        = value.imgurl or "";
		goods.desc          = value.desc or "";
		goods.price         = tonumber(value.price) or 0;
		goods.modelist 		= value.modelist or "";
		if kPlatform == kPlatformIOS then
		    goods.identifier    = value.ios_goods_id or "";
		else
		    goods.identifier    = value.identifier or "";
		end;
        goods.payType       = tonumber(value.paytype) or 1;-- 1 rwb 购买 (2 元宝兑换) 2 vip购买
        goods.isShow        = tonumber(value.is_show) or 0;
        goods.goods_id      = tonumber(value.goods_id) or 0;
        goods.cate_id       = tonumber(value.cate_id) or 0;
        goods.short_desc    = value.short_desc or ""
        goods.big_img       = value.big_img or ""
        goods.is_preference = tonumber(value.is_preference) or 0
        table.insert(list,goods);
	end
    return list
end
----------------------------- prop --------------------

MallData.getPropData = function(self)
    if not self.m_propData then
        self:sendGetPropList();
    end
    local Prop_List = GameCacheData.PROP_LIST;
	if PhpConfig.getBid() then
		Prop_List = Prop_List..PhpConfig.getBid();
	end
    local ret,errMessage = pcall(
        function() -- 捕捉到异常后把数据清理
	        local ret = GameCacheData.getInstance():getString(Prop_List,nil)
            propData = self:safePropData(json.decode(ret))
            self:setMallPropData(propData);
            return propData;
        end
    );
    if ret then
        self.m_propData = errMessage;
        return errMessage;
    else
        local Prop_Version = GameCacheData.PROP_LIST_VERSION;
	    if PhpConfig.getBid() then
		    Prop_Version = Prop_Version..PhpConfig.getBid();
	    end
	    GameCacheData.getInstance():saveInt(Prop_Version,0);
        self.m_propData = nil;
        self:sendGetPropList();
        return nil;
    end
end

MallData.sendGetPropList = function(self,isNeedTips)
    isNeedTips = isNeedTips == nil or isNeedTips;
    local tips = "正在获取道具...";

	local post_data = {};

	local Prop_Version = GameCacheData.PROP_LIST_VERSION;
	if PhpConfig.getBid() then
		Prop_Version = Prop_Version..PhpConfig.getBid();
	end

	local version = GameCacheData.getInstance():getInt(Prop_Version,0);
	post_data.version = version;
    if isNeedTips then
        HttpModule.getInstance():execute(HttpModule.s_cmds.getPropList,post_data,tips);
    else
        HttpModule.getInstance():execute(HttpModule.s_cmds.getPropList,post_data);
    end
end


MallData.explainPropData = function(self,message)
    local data = message.data;
	local version =message.version:get_value();
    
    local status = message.status:get_value();

    if status == 0 then
        local Prop_List = GameCacheData.PROP_LIST;
		if PhpConfig.getBid() then
			Prop_List = Prop_List..PhpConfig.getBid();
		end
		local ret = GameCacheData.getInstance():getString(Prop_List,nil);
        self.m_propData = self:safePropData(json.decode(ret))
        self:setMallPropData(self.m_propData);
        return self.m_propData;
    end

	local Prop_Version = GameCacheData.PROP_LIST_VERSION;
	if PhpConfig.getBid() then
		Prop_Version = Prop_Version..PhpConfig.getBid();
	end

	
	if not data then
		print_string("not data");
		return
	end

    
	if #data <= 0 then
		print_string("not data");
		return
	end
    
    data = json.analyzeJsonNode(data)

	GameCacheData.getInstance():saveInt(Prop_Version,version);
	local Prop_List = GameCacheData.PROP_LIST;
	if PhpConfig.getBid() then
		Prop_List = Prop_List..PhpConfig.getBid();
	end

	GameCacheData.getInstance():saveString(Prop_List,json.encode(data));

    self.m_propData = self:safePropData(data)
    self:setMallPropData(self.m_propData);
    return self.m_propData;
end

function MallData:safePropData(datas)
    if type(datas) ~= "table" then return nil end

    local list  = {}
    local giftList = {}
	for _,value in pairs(datas) do 
		local goods = {};
		goods.id       		= tonumber(value.id) or 0;
		goods.goods_type    = tonumber(value.goods_type) or 0;  --道具类型
        goods.goods_num     = tonumber(value.goods_num) or 0;
		goods.name     		= value.name or "";
        goods.exchange_type = tonumber(value.exchange_type) or 0;
        goods.exchange_num  = tonumber(value.exchange_num) or 0;
		goods.imgurl        = value.imgurl or "";
		goods.desc          = value.desc or "";
        goods.show          = tonumber(value.show) or 0;
        goods.cate_id       = tonumber(value.cate_id) or 0;
        goods.daylimit      = tonumber(value.daylimit) or 0;
        goods.short_desc    = value.short_desc or ""
        goods.stock_num     = tonumber(value.stock_num) or 0;
		goods.is_promote    = tonumber(value.is_promote) or 0;
		goods.is_hot    	= tonumber(value.is_hot) or 0;
        goods.pid           = tonumber(value.pid) or 0;
        goods.big_img       = value.big_img or ""
        if goods.goods_type ~= 1 and goods.goods_type ~= 5 then 
            table.insert(list,goods);
        end
        if goods.pid == 105 then
            goods.charm_value = value.charm_value or {};
            table.insert(giftList,goods);
        end
	end

    self:setGiftList(giftList);

    return list
end

function MallData.processShopData(datas)
    if not datas or type(datas) ~= "table" then 
        return nil
    end 
    local shops = {}
    for k,v in ipairs(datas) do 
        shops[k] = v
    end 
    for k1,v1 in ipairs(shops) do
        if v1.is_preference and v1.is_preference == 1 then 
            table.remove(shops,k1)
            table.insert(shops,1,v1)
        end 
    end 
    return shops
end 
--[Comment]
-- 商品 支付方式 支付场景
MallData.setNeedMorePayDialog = function(self,goods,payTypes,scene)
    self.mMorePayDialogGoods = goods
    self.mMorePayDialogPayTypes = payTypes
    self.mMorePayDialogScene = scene
end

MallData.getMorePayDialogData = function(self)
    return self.mMorePayDialogGoods,self.mMorePayDialogPayTypes,self.mMorePayDialogScene
end

require(DIALOG_PATH .. "pay_more_dialog")
MallData.showMorePayDialog = function(self,notFindPayType)
    local goods,payTypes,scene = MallData.getInstance():getMorePayDialogData()
    if goods and payTypes then 
        PayMoreDialog.getInstance():setData(goods,payTypes,scene)
        return PayMoreDialog.getInstance():showMorePayType(notFindPayType)
    end
    return false
end
