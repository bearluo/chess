--region godPay.lua
--Author : HrnryChen
--Date   : 2015/5/27

--GodSDK支付
require(PAY_PATH.."payInterface");
require(DIALOG_PATH.."pay_dialog");

GodPay = class(PayInterface);

GodPay.getInstance = function()
    if not GodPay.instance then
        GodPay.instance = new(GodPay);
    end
    return GodPay.instance;
end

GodPay.buy = function (self, goods,dataTab)--scene)
    local payDialog = PayDialog.getInstance() 
    payDialog:setData(goods)
--    payDialog:setScene(scene)
    payDialog:setPhpData(dataTab)
    payDialog:show()
end

GodPay.createOrder = function (self, goods, pmode, paydata)
    local network_type = ""
    if "ios" == System.getPlatform() then
        network_type = "IOS";
    else
    	network_type = TerminalInfo.getInstance():getOperator();
    end
    print_string("GodPay.createOrder goods_name = " .. goods.money..goods.name);
    local phpData = {}
    if paydata then
        phpData = paydata
    end

	local post_data = {};
    post_data.param = {};
	post_data.param.pmode               = pmode                     --支付渠道 218移动MM弱网 109联通wo商店
	post_data.param.goods_id            = goods.goods_id            --商品ID
    post_data.param.network_type        = network_type
    post_data.param.pay_scene           = phpData.pay_scene or PayUtil.s_pay_scene.default_recommend
    post_data.param.gameparty_subname   = phpData.gameparty_subname or PayUtil.s_pay_room.other
    post_data.param.gameparty_anto      = phpData.gameparty_anto or 0
    post_data.param.sale_token          = phpData.saleToken or "" -- 打折token
	HttpModule.getInstance():execute(HttpModule.s_cmds.createOrder,post_data,"下单中，请稍后……")
end

GodPay.onCreateOrderCallBack = function (self, isSuccess, message)
    if HttpModule.explainPHPMessage(isSuccess,message,"下单失败，请稍后再试！") then
        return;
    end

    data = message.data;
	local order = {};
	order.status = data.status:get_value();

	if order.status ~= 1 then
        local message = "下单失败，请稍后再试！";
        ChessToastManager.getInstance():show(message);
        return;
    end

    local pmode = data.pmode:get_value();
    order.goods_id  = data.goods_id:get_value()                  --商品id
    order.scene     = data.scene:get_value()                     --当前下单场景
    local goods     = MallData.getInstance():getGoodsById(order.goods_id)
    if not goods then 
        local message = "下单失败，请去商城购买！";
         ChessToastManager.getInstance():show(message);
        return 
    end
    local enable_pmode_list = {}
    if data.enable_pmode_list:get_value() then
        for key,val in pairs(data.enable_pmode_list) do
            local tab = {}
            tab.pmode = val.pmode:get_value()
            enable_pmode_list[key] = tab
        end
    end

    MallData.getInstance():setNeedMorePayDialog(goods,enable_pmode_list,order.scene)
    local notFindPayType = false
    if kPlatform == kPlatformIOS then
        if pmode == PayUtil.pay_mode_appstore then                      -- AppStore
            order.pid = data.pid:get_value();
            order.desc = data.name:get_value();
            order.pmode = data.pmode:get_value();
            order.status = data.status:get_value();
            if goods then
                order.identifier = goods.identifier;
            end
            order.uid = tostring(UserInfo.getInstance():getUid());
            order.sitemid = tostring(UserInfo.getInstance():getSitemid());
        elseif pmode == PayUtil.aliPay_mode then                        -- 支付宝
            order.pid = data.pid:get_value();
            order.desc = data.name:get_value();
            order.pmode = PayUtil.aliPay_mode;
            order.price = data.amount:get_value();
            order.notify_url = data.notify_url:get_value();
            order.sign = data.ali_sign:get_value();
        elseif pmode == PayUtil.pay_mode_weixin then                    -- 微信
            order.pid = data.pid:get_value();
            order.desc = data.name:get_value();
            order.pmode = PayUtil.pay_mode_weixin;
            order.price = data.amount:get_value();
            order.noncestr = data.noncestr:get_value();
            order.sign = data.sign:get_value();
            order.prepayid = data.prepayid:get_value();
            order.package = data.package:get_value();
            order.timeStamp = data.timestamp:get_value();
        else
            notFindPayType = true
        end
    else
--        if pmode == PayUtil.mm_mode then                            --移动mm弱网  
--            order.pid = data.pid:get_value();
--            order.paycode = data.code:get_value();
--            order.appid = data.appid:get_value();
--            order.appkey = data.appkey:get_value();
--            order.pmode = PayUtil.mm_mode;
--        else
--        if pmode == PayUtil.wo_shop_mode then                       --联通wo商店
--            order.pid = data.pid:get_value();
--            order.vacCode = data.code.vacCode:get_value();
--            order.customCode = data.code.customCode:get_value();
--            order.callBackUrl = data.notify_url:get_value();
--            order.name = data.name:get_value();
--            order.price = data.amount:get_value();
--            order.uid = UserInfo.getInstance():getUid();
--            order.pmode = PayUtil.wo_shop_mode;
--        elseif pmode == PayUtil.dianxin_aiyouxi_mode then               --电信爱游戏
--            order.pid = data.pid:get_value();
--            order.desc = data.name:get_value();
--            order.pmode = PayUtil.dianxin_aiyouxi_mode;
--            order.price = data.amount:get_value();
--        else
        if pmode == PayUtil.aliPay_mode then                        -- 支付宝
            order.pid = data.pid:get_value();
            order.desc = data.name:get_value();
            order.pmode = PayUtil.aliPay_mode;
            order.price = data.amount:get_value();
        elseif pmode == PayUtil.pay_mode_weixin then                        -- 微信
            order.pid = data.pid:get_value();
            order.desc = data.name:get_value();
            order.pmode = PayUtil.pay_mode_weixin;
            order.price = data.amount:get_value();
            order.noncestr = data.noncestr:get_value();
            order.sign = data.sign:get_value();
            order.prepayid = data.prepayid:get_value();
            order.package = data.package:get_value();
            order.timeStamp = data.timestamp:get_value();
        elseif pmode == PayUtil.pay_mode_union then                        -- 银联
            order.pid = data.pid:get_value();
            order.desc = data.name:get_value();
            order.pmode = PayUtil.pay_mode_union;
            order.price = data.amount:get_value();    
            order.tn = data.tn:get_value();
        elseif pmode == PayUtil.pay_mode_vivo then                        -- 步步高
            order.pmode = data.pmode:get_value();
            order.transNo = data.vivoOrder:get_value()
            order.vivoSignature = data.vivoSignature:get_value()
            order.productName = goods.name or ""
            order.productDes = goods.short_desc or order.productName
            order.price = data.orderAmount:get_value()
            order.uid = UserInfo.getInstance():getUid();
        else
            notFindPayType = true
        end
    end
    
    if notFindPayType then
        if not MallData.getInstance():showMorePayDialog(notFindPayType) then 
            local message = "当前支付不可用！";
            ChessToastManager.getInstance():show(message);
        end
        return 
    end

    local json_order = json.encode(order);

	print_string("GodPay.onCreateOrder call_native and json_order is " .. json_order);
	dict_set_string(PAY , PAY .. kparmPostfix , json_order);
	call_native(PAY);
end

--endregion
