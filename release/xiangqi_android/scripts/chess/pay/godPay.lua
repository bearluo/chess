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

GodPay.buy = function (self, goods)
    local payDialog = PayDialog.getInstance(goods);
    payDialog:show();
end

GodPay.createOrder = function (self, goods, pmode)
    self.m_curGoods = goods;
    print_string("GodPay.createOrder goods_name = " .. goods.money..goods.name);
    local goodsMoney = goods.money;
	local post_data = {};
    post_data.param = {};
	post_data.param.pmode = pmode;                     --支付渠道 218移动MM弱网 109联通wo商店
	post_data.param.goods_id = goods.goods_id ;        --商品ID
	HttpModule.getInstance():execute(HttpModule.s_cmds.createOrder,post_data,"下单中，请稍后……");
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
    if kPlatform == kPlatformIOS then
        if pmode == PayUtil.pay_mode_appstore then                      -- AppStore
            order.pid = data.pid:get_value();
            order.desc = data.name:get_value();
            order.pmode = data.pmode:get_value();
            order.status = data.status:get_value();
            if self.m_curGoods.identifier and self.m_curGoods.identifier ~= "" then
                order.identifier = self.m_curGoods.identifier;
            end;
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
        end
    else
        if pmode == PayUtil.mm_mode then                            --移动mm弱网  
            order.pid = data.pid:get_value();
            order.paycode = data.code:get_value();
            order.appid = data.appid:get_value();
            order.appkey = data.appkey:get_value();
            order.pmode = PayUtil.mm_mode;
        elseif pmode == PayUtil.wo_shop_mode then                       --联通wo商店
            order.pid = data.pid:get_value();
            order.vacCode = data.code.vacCode:get_value();
            order.customCode = data.code.customCode:get_value();
            order.callBackUrl = data.notify_url:get_value();
            order.name = data.name:get_value();
            order.price = data.amount:get_value();
            order.uid = UserInfo.getInstance():getUid();
            order.pmode = PayUtil.wo_shop_mode;
        elseif pmode == PayUtil.dianxin_aiyouxi_mode then               --电信爱游戏
            order.pid = data.pid:get_value();
            order.desc = data.name:get_value();
            order.pmode = PayUtil.dianxin_aiyouxi_mode;
            order.price = data.amount:get_value();
        elseif pmode == PayUtil.aliPay_mode then                        -- 支付宝
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
        end
    end;
    order.propid = UserInfo.getInstance():getPropid();              --订单号

    local json_order = json.encode(order);

	print_string("GodPay.onCreateOrder call_native and json_order is " .. json_order);
	dict_set_string(PAY , PAY .. kparmPostfix , json_order);
	call_native(PAY);
end
--endregion
