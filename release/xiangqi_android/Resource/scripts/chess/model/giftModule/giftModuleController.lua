--giftModuleSocketController.lua
--Date 2016.7.27
--礼物socket模块
--endregion

require("gameBase/gameController");

GiftModuleController = {};

function GiftModuleController.getInstance()
    if not GiftModuleController.s_manager then 
		GiftModuleController.s_manager = new(GiftModuleController);
	end
	return GiftModuleController.s_manager;
end

function GiftModuleController.releaseInstance()
    delete(GiftModuleController.s_manager);
	GiftModuleController.s_manager = nil;
end


function GiftModuleController.ctor(self)

end

function GiftModuleController.dtor(self)

end

--[Comment]
--发送礼物
function GiftModuleController.onSendGift(self,data)
    if not data or type(data) ~= "table" then return end
    if not self.userData then return end;
    local target_id = tonumber(self.userData.mid) or 0
    if target_id == tonumber(UserInfo.getInstance():getUid()) then
        ChessToastManager.getInstance():showSingle("不能给自己发礼物!")
        return
    end
    local params = {}
    params = data
    params.target_id = target_id
    OnlineSocketManager.getHallInstance():sendMsg(CLIIENT_CMD_GIVEGIFT,params)
end

--[Comment]
--接收发送礼物
function GiftModuleController.onRecvSendGift(self,data)
   local errorMsgTab = {
        "不可以给自己送礼物",
        "金币过低，无法发送互动礼物",
        "金币过低，无法发送互动礼物",
        "对手已经离开",
        "礼物发送失败",
--        "礼物类型不存在",
    };
    if data then  
        if data.result == 0 then 
            local msg = errorMsgTab[data.errorCode];
            ChessToastManager.getInstance():showSingle(msg);
            if data.errorCode  == 2 or data.errorCode  == 3 then
                local cost = MallData.getInstance():getGiftCost(data.gift_type)
                cost = cost * data.gift_num
                local goods = MallData.getInstance():getGoodsByMoreMoney(cost)
                if not goods then return end
                local payData = {}
                payData = ToolKit.getBuyCoinsPhpConfig()
                GiftModuleItem.m_PayInterface = PayUtil.getPayInstance(PayUtil.s_defaultType);
		        goods.position = MALL_COINS_GOODS;
		        GiftModuleItem.m_pay_dialog = GiftModuleItem.m_PayInterface:buy(goods,payData);
            end
            return false
        elseif data.result == 1 then
            local money = data.leftMoney;
            if money == -1 then return end
            UserInfo.getInstance():setMoney(money);
            return true
        end
    end
end

--[Comment]
--设置用户数据
function GiftModuleController.setUserData(self,userData)
    self.userData = userData
end