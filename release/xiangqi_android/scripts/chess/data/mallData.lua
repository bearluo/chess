MallData = class();

MallData.s_mallType = {
    shop = 0;
    prop = 1;
}


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

------------------------- shop -------------------------

MallData.getShopData = function(self)
    if not self.m_shopData then
        self:sendGetShopInfo();
    end
    local MallGoods_List = GameCacheData.MALL_GOODS_LIST;
	if PhpConfig.getBid() then
		MallGoods_List = MallGoods_List..PhpConfig.getBid();
	end
    local ret,errMessage = pcall(
        function() -- 捕捉到异常后把数据清理
	        local ret = GameCacheData.getInstance():getString(MallGoods_List,nil);
            shopData = json.decode(ret)
            self:setMallData(shopData);
            return shopData;
        end
    );
    if ret then
        self.m_shopData = errMessage;
        return errMessage;
    else
        local MallShop_Version = GameCacheData.Mall_SHOP_VERSION;
        if PhpConfig.getBid() then
	        MallShop_Version = MallShop_Version..PhpConfig.getBid();
        end
        GameCacheData.getInstance():saveInt(MallShop_Version,0);
        self.m_shopData = nil;
        self:sendGetShopInfo();
        return nil;
    end
end

MallData.sendGetShopInfo = function(self)
    local tips = "正在获取商品信息...";
	local post_data = {};

	local MallShop_Version = GameCacheData.Mall_SHOP_VERSION;
	if PhpConfig.getBid() then
		MallShop_Version = MallShop_Version..PhpConfig.getBid();
	end

	local version = GameCacheData.getInstance():getInt(MallShop_Version,0);
	post_data.version = version;
	post_data.mid = UserInfo.getInstance():getUid();
    
    HttpModule.getInstance():execute(HttpModule.s_cmds.getShopInfo,post_data,tips);
end

MallData.explainShopData = function(self,message)
    local data = message.data;
	local version = message.version:get_value();
    local status = message.status:get_value();
    local enable_goods = nil;
    if message.enable_goods then
        enable_goods = message.enable_goods;
    end

    local showList = {};
    if enable_goods then
        for _,value in pairs(enable_goods) do 
            local enableGoods = {};
            enableGoods.id = tonumber(value:get_value()) or 0;
            table.insert(showList,enableGoods);
        end
    end

    if tonumber(status) == 0 then
        local MallGoods_List = GameCacheData.MALL_GOODS_LIST;
		if PhpConfig.getBid() then
			MallGoods_List = MallGoods_List..PhpConfig.getBid();
		end
		local ret = GameCacheData.getInstance():getString(MallGoods_List,nil);
        self.m_shopData = json.decode(ret);
        local tempData = {};
        for _,v in pairs(self.m_shopData) do
            for _,m in pairs(showList) do
                if m.id == v.goods_id then
                     table.insert(tempData,v);
                end
            end
        end
        self:setMallData(tempData);
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


	local list  = {}
    local tempData = {}; 
	for _,value in pairs(data) do 


		local goods = {};
		goods.id       		= tonumber(value.id:get_value()) or 0;
		goods.name     		= value.name:get_value();
		goods.money    		= tonumber(value.money:get_value()) or 0;
		goods.paysid   		= tonumber(value.paysid:get_value()) or 0;
		goods.appid    		= tonumber(value.appid:get_value()) or 0;
		goods.pmode         = tonumber(value.pmode:get_value()) or 0;
		goods.type     		= tonumber(value.type:get_value()) or 0;
		goods.label    		= tonumber(value.label:get_value()) or 0;
		goods.originmoney   = tonumber(value.originmoney:get_value()) or 0;
		goods.imgurl        = value.imgurl:get_value() or "";
		goods.desc          = value.desc:get_value() or "";
		goods.price         = tonumber(value.price:get_value()) or 0;
		goods.modelist 		= value.modelist:get_value() or "";
		if kPlatform == kPlatformIOS then
		    goods.identifier    = value.ios_goods_id:get_value() or "";
		else
		    goods.identifier    = value.identifier:get_value() or "";
		end;
        goods.payType       = tonumber(value.paytype:get_value()) or 1;-- 1 rwb 购买 (2 元宝兑换) 2 vip购买
        goods.isShow        = tonumber(value.is_show:get_value()) or 0;
        goods.goods_id      = tonumber(value.goods_id:get_value()) or 0;
        goods.cate_id       = tonumber(value.cate_id:get_value()) or 0;

--		 print_string("==============goods.name========="..goods.name);
--		 print_string("==============goods.paysid========="..goods.paysid);
--		 print_string("==============goods.appid========="..goods.appid);
--		 print_string("==============goods.type========="..goods.type);
--		 print_string("==============goods.price========="..goods.price);

--		if goods.name == "元宝" or goods.name == "金币" then
        table.insert(list,goods);
        if goods.isShow == 1 and enable_goods then
            for _,v in pairs(showList) do
                if goods.goods_id == v.id then
		            table.insert(tempData,goods);
                end
            end
		end
	end


	if #list > 0 then
		local MallGoods_List = GameCacheData.MALL_GOODS_LIST;
		if PhpConfig.getBid() then
			MallGoods_List = MallGoods_List..PhpConfig.getBid();
		end
		print_string("===========json.encode(list)======"..json.encode(list));
		GameCacheData.getInstance():saveString(MallGoods_List,json.encode(list));
	end
    if enable_goods then
        self.m_shopData = tempData;
    else
        self.m_shopData = list;
    end
    self:setMallData(self.m_shopData);
    return self.m_shopData;
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
            propData = json.decode(ret)
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

MallData.sendGetPropList = function(self)
    local tips = "正在获取道具...";

	local post_data = {};

	local Prop_Version = GameCacheData.PROP_LIST_VERSION;
	if PhpConfig.getBid() then
		Prop_Version = Prop_Version..PhpConfig.getBid();
	end

	local version = GameCacheData.getInstance():getInt(Prop_Version,0);
	post_data.version = version;

    HttpModule.getInstance():execute(HttpModule.s_cmds.getPropList,post_data,tips);
end


MallData.explainPropData = function(self,message)
    local data1 = message.data;
	local version =message.version:get_value();
    
    local status = message.status:get_value();

    if status == 0 then
        local Prop_List = GameCacheData.PROP_LIST;
		if PhpConfig.getBid() then
			Prop_List = Prop_List..PhpConfig.getBid();
		end
		local ret = GameCacheData.getInstance():getString(Prop_List,nil);
        self.m_propData = json.decode(ret);
        return self.m_propData;
    end

	local Prop_Version = GameCacheData.PROP_LIST_VERSION;
	if PhpConfig.getBid() then
		Prop_Version = Prop_Version..PhpConfig.getBid();
	end

	GameCacheData.getInstance():saveInt(Prop_Version,version);
	
	if not data1 then
		print_string("not data");
		return
	end

	local data2;
	local list  = {}

	local maxlifelevellist  = {};

	data2 = data1;
	if not data2 then
		print_string("not data");
		return
	end

	if #data2 <= 0 then
		print_string("not data2");
		return
	end
	for _,value in pairs(data2) do 
		local goods = {};
		goods.id       		= tonumber(value.id:get_value()) or 0;
		goods.goods_type    = tonumber(value.goods_type:get_value()) or 0;  --道具类型
        goods.goods_num     = tonumber(value.goods_num:get_value()) or 0;
		goods.name     		= value.name:get_value() or "";
        goods.exchange_type = tonumber(value.exchange_type:get_value()) or 0;
        goods.exchange_num  = tonumber(value.exchange_num:get_value()) or 0;
		goods.imgurl        = value.imgurl:get_value() or "";
		goods.desc          = value.desc:get_value() or "";
        goods.show          = tonumber(value.show:get_value()) or 0;
        goods.cate_id       = tonumber(value.cate_id:get_value()) or 0;

        if goods.goods_type == 12 then
            goods.stock_num  = tonumber(value.stock_num:get_value()) or 0;
        end
        if goods.goods_type ~= 1 and goods.goods_type ~= 5 then 
            table.insert(list,goods);
        end
	end

	local Prop_List = GameCacheData.PROP_LIST;
	if PhpConfig.getBid() then
		Prop_List = Prop_List..PhpConfig.getBid();
	end

	GameCacheData.getInstance():saveString(Prop_List,json.encode(list));

    self.m_propData = list;
    return self.m_propData;
end
