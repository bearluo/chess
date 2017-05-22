--统一支付
require(PAY_PATH.."payInterface");

UnityPay = class(PayInterface);

UnityPay.getInstance = function()
    if not UnityPay.instance then
        UnityPay.instance = new(UnityPay);
    end
    return UnityPay.instance;
end



UnityPay.setPayCnHost= function(payCnHost)
	UnityPay.s_payCnHost= payCnHost;
end

UnityPay.getPayCnHost= function()
	return UnityPay.s_payCnHost or "https://paycnapi.boyaa.com/";
end

UnityPay.buy = function(self,goods,pos)
    print_string("=========UnityPay.buy==========");
	self.m_pos =pos;
	self.m_goods = goods;
	if self.m_goods then
		self.m_goods.position = pos;

		if self.m_goodsType == PayInterface.COINS_GOODS then
			if  not self.m_goods.coinName  then
				self.m_goods.coinName = self.m_goods.money..self.m_goods.name;
			end
			self.m_goods.name  = self.m_goods.coinName;
		end
        self:pay(self.m_goods);
    end
end

UnityPay.pay = function(self,goods)
    local price = goods.price;
	local sid = goods.paysid;
	local appid = goods.appid;
	local ptype = goods.type;
	local sitemid = UserInfo.getInstance():getSitemid();
	local desc = goods.name;


	local flow = 0; --大厅内购买：”0”,  房间内购买：”1”

	local gameVersion = VERSIONS_CODE;--游戏版本（字符串整数，如3）
	local mid = UserInfo.getInstance():getUid();--用户游戏id标识(用户在业务游戏里的标识)
	
	local telServer = "400-663-1888";--一键支付上面展示的客服电话
	local payCnHost = UnityPay.getPayCnHost();--统一支付接口地址(建议配置在服务端)  默认：https://paycnapi.boyaa.com/
	local orientation = "1"; --“0”:横屏; “1”:竖屏     默认横屏

 	local channelid = 0;-- 渠道号（天翼，联通沃等支付需要的渠道号）


 	local objJson = {};
 	objJson.amt = price;
 	objJson.sid = sid;
 	objJson.appid = appid;
 	objJson.ptype = ptype;
 	objJson.sitemid = sitemid;
 	objJson.desc = desc;

 	objJson.flow = flow;
 	objJson.gameVersion = gameVersion;
 	objJson.mid = mid;

 	objJson.telServer = telServer;
 	objJson.payCnHost = payCnHost;
 	objJson.orientation = orientation;
 	objJson.channelid = channelid;
 	objJson.pos = goods.position;


 	if UserInfo.getInstance():getCardType() ==  0 then
 		objJson.paytype = 2; --1: 短信 2： 网页
 	else
 		objJson.paytype = 1; --1: 短信 2： 网页
 	end

	local line = json.encode(objJson)

	print_string("PayUtil.CallUnityPayMode = " .. line);
	dict_set_string(PAY , PAY .. kparmPostfix , line);
	call_native(PAY);
end


