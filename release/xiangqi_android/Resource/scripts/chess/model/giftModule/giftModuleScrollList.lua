--giftModuleScrollList.lua
--Date 2016.8.6
--礼物滑动列表
--endregion

require(DATA_PATH .. "mallData");
require(UTIL_PATH .. "progressBar")

GiftModuleScrollList = class(Node);
GiftModuleScrollList.tip_bg = nil
GiftModuleScrollList.handler = nil

--[Comment]
--创建礼物列表
--w:宽  h:高  label:模式  handler:应用
function GiftModuleScrollList.ctor(self,scroSize,itemSize,bgSize,label,tipBg)
    self.scrollSize = scroSize or {}
    self.itemSize = itemSize or {}
    self.bgSize = bgSize or {}
    local sw = self.scrollSize.w or 390
    local sh = self.scrollSize.h or 100

--    GiftModuleScrollList.tip_bg = new(Node)
--    GiftModuleScrollList.tip_bg:setSize(200,50);
--    GiftModuleScrollList.tip_bg:setLevel(99)
--    GiftModuleScrollList.tip_bg:setVisible(false);
--    GiftModuleScrollList.tip_bg:setAlign(kAlignTop)
--    self:addChild(GiftModuleScrollList.tip_bg);

    self:setSize(sw,sh);
    self.mode = label
--    GiftModuleScrollList.handler = handler
    if tipBg then
        GiftModuleScrollList.tip_bg = tipBg
    end
    GiftModuleScrollList.progressBg = new(Image,"drawable/blank.png")
    GiftModuleScrollList.progressBg:setAlign(kAlignLeft)
    GiftModuleScrollList.progressBg:setVisible(false)
    GiftModuleScrollList.tip_bg:addChild(GiftModuleScrollList.progressBg)

    GiftModuleScrollList.progressIcon = new(Image,"drawable/blank.png",nil,nil,9,9,9,9)
    GiftModuleScrollList.progressIcon:setAlign(kAlignLeft)
    GiftModuleScrollList.progressIcon:setSize(20,50)
    GiftModuleScrollList.progressBg:addChild( GiftModuleScrollList.progressIcon)

    GiftModuleScrollList.imglist = {}
    GiftModuleScrollList.imglist[1] = new(Image, "watchRoomIcon/num_1.png")
    GiftModuleScrollList.imglist[2] = new(Image, "watchRoomIcon/num_0.png")
    GiftModuleScrollList.imglist[3] = new(Image, "watchRoomIcon/num_0.png")
    GiftModuleScrollList.imglist[4] = new(Image, "watchRoomIcon/watch_x.png")
    for i = 1,4 do
        GiftModuleScrollList.imglist[i]:setSize(34,42)
        GiftModuleScrollList.imglist[i]:setAlign(kAlignRight)
        GiftModuleScrollList.imglist[i]:setVisible(false)
        if GiftModuleScrollList.tip_bg then
            GiftModuleScrollList.tip_bg:addChild(GiftModuleScrollList.imglist[i])
        end
    end

--    self.handler = handler
    self.m_giftScrllView = new(ScrollView,0,0,sw,sh,true);
    self.m_giftScrllView:setDirection(kHorizontal);
    self.m_giftScrllView:setAlign(kAlignCenter);
    self:addChild(self.m_giftScrllView);
    self:initScrollView()


end

function GiftModuleScrollList.dtor(self)
    self.m_giftScrllView:removeAllChildren(true);
    delete(self.m_giftScrllView);
    self.m_giftScrllView = nil;
--    GiftModuleScrollList.handler = nil
--    delete(GiftModuleScrollList.tip_bg)
    delete(GiftModuleScrollList.imglist)
    GiftModuleScrollList.imglist = {}
    GiftModuleScrollList.tip_bg = nil
end

--[Comment]
--初始化滑动列表
--sizeMode: 礼物item大小模式
function GiftModuleScrollList.initScrollView(self)
    local iw = self.itemSize.w or 100
    local ih = self.itemSize.h or 100
    local giftList = MallData.getInstance():getGiftList();
--    giftList[5] = giftList[1];
    if not giftList or next(giftList) == nil then return end

    for k,v in pairs(giftList) do
        local item = new(GiftModuleItem,v,self.mode,self.itemSize,self.bgSize,self.m_giftScrllView)
        if item then
            item:setAlign(kAlignTop);
            self.m_giftScrllView:addChild(item);
        end
    end
end

--[Comment]
--更新item 
function GiftModuleScrollList.onUpdateItem(self,data)
    if not data then return end
    if self.m_giftScrllView then
        local tab = self.m_giftScrllView:getChildren()
        for k,v in pairs(tab) do 
            if v and v.gift_id then
                local id = v.gift_id
                local num = data[id .. ""]
                if num then
                    v:onUpdate(num)
                end
            end
        end
    end
end

--[Comment]
--重置item
function GiftModuleScrollList.clearItemNum(self)
    if self.m_giftScrllView then
        local tab = self.m_giftScrllView:getChildren()
        for k,v in pairs(tab) do 
            if v then 
                v:onUpdate(0)
            end
        end
    end
end
-----------------------------------------------------------------------------

GiftModuleItem = class(Node);

GiftModuleItem.gridDiff = 40;
GiftModuleItem.bottom_gridDiff = 12;
GiftModuleItem.m_PayInterface = nil;
GiftModuleItem.m_pay_dialog = nil;

--GiftModuleItem.s_style = 
--{
--    {
--        w = 100, bg_w = 80,btn_h = 26,item_w = 60,
--    },
--    {
--        w = 160, bg_w = 120,btm_h = 40,item_w = 90,
--    }

--}

GiftModuleItem.s_mode_user = 1;
GiftModuleItem.s_mode_gift = 2;  -- 发送礼物
GiftModuleItem.s_mode_other = 3; -- 展示礼物
GiftModuleItem.s_mode_user2 = 4; -- 展示礼物
--[Comment]
--礼物item
--data:礼物数据  mode:礼物模式  sizeMode:礼物item大小  handler:引用
function GiftModuleItem.ctor(self,data,mode,itemSize,bgSize,scrollview)
    local w = itemSize.w or 100
    local h = itemSize.h or 100
    local bgW = bgSize.w or 80
    local bgH = bgSize.h or 26

    self.m_data = data;
    self.gift_id = data.goods_type
    self.mode = mode
    self.gift_num = 1
    self.scrollview = scrollview;
--    self.handler = handler;
--    local sizeStyle = GiftModuleItem.s_style[sizeMode]
    if not data then return  end
    self:setSize(w,h);

    local gridDiff = GiftModuleItem.gridDiff;
    self.m_bg = new(Image,"common/background/prop_lbg.png",nil,nil,gridDiff,gridDiff,gridDiff,gridDiff);
    self.m_bg:setSize(bgW ,bgW);
    self.m_bg:setAlign(kAlignCenter);
    self:addChild(self.m_bg);

    local lr_gridDiff = GiftModuleItem.gridDiff;
    local tb_gridDiff = GiftModuleItem.bottom_gridDiff;
    self.m_bottom_bg = new(Image,"common/background/prop_sbg.png",nil,nil,lr_gridDiff,lr_gridDiff,tb_gridDiff,tb_gridDiff);
    self.m_bottom_bg:setSize(bgW,bgH);
    self.m_bottom_bg:setAlign(kAlignBottom);
    self.m_bg:addChild(self.m_bottom_bg)

    --根据类型选择图片
    local connect_str = "_l.png"
    if self.mode == GiftModuleItem.s_mode_user or self.mode == GiftModuleItem.s_mode_user2 then
        connect_str = ".png"
    end

    local imgSrc = data.imgurl or "mall/flower"
    self.m_item_img = new(Image,imgSrc .. connect_str);
    self.m_item_img:setAlign(kAlignCenter);
    self.m_item_img:setPos(0,-15);
    self:addChild(self.m_item_img)
 
    local vipImg = new(Image,"vip/vip_icon.png")
    vipImg:setSize(46,38);
    vipImg:setAlign(kAlignTopLeft);
    vipImg:setPos(-18,0)
    if data.cate_id == 19 and self.mode == 2 then
        self.m_item_img:addChild(vipImg);
    end

    --数量
    local numText = "0";
--    local num = UserInfo.getInstance():getGiftNum(data.cate_id);
--    numText = num or "0";
    local fontSize = 24
    if self.mode == GiftModuleItem.s_mode_user2 then
        fontSize = 30
    end

    self.m_num_text = new(Text,numText,nil,nil,kAlignBottom,nil,fontSize,255,255,255);
    if self.mode == GiftModuleItem.s_mode_other then
    
    elseif self.mode == GiftModuleItem.s_mode_user then
        self.m_bg:setFile("common/background/prop_lbg.png")
        self.m_bottom_bg:setFile("common/background/prop_sbg.png")
        self.m_num_text:setColor(255,255,255)
        self.m_num_text:setAlign(kAlignBottom);
        self.m_num_text:setPos(0,8);
        self.m_bottom_bg:addChild(self.m_num_text)
        self.m_item_img:setSize(bgW-20,bgW-20);
        vipImg:setVisible(false)
    elseif self.mode == GiftModuleItem.s_mode_user2 then
        self.m_bg:setFile("drawable/blank.png")
        self.m_bottom_bg:setFile("drawable/blank.png")
        self.m_num_text:setColor(130,100,55)
        self.m_num_text:setAlign(kAlignBottom);
        self.m_num_text:setPos(0,-9);
        self.m_num_text:setText("X0")
        self.m_bottom_bg:addChild(self.m_num_text)
        self.m_item_img:setSize(bgW,bgW);
        vipImg:setVisible(false)
    elseif self.mode == GiftModuleItem.s_mode_gift then
        
--        self.m_recv_text = new(Text,"收到:" .. numText,nil,nil,kAlignCenter,nil,20,135,100,95)
--        self.m_recv_text:setAlign(kAlignBottom);
--        self.m_recv_text:setPos(0,5);
--        self:addChild(self.m_recv_text)
        self.m_bg:setVisible(false)
        self.exchange_price = data.exchange_num or 0
        numText = self.exchange_price .. "金币"
        self.m_num_text:setText(numText)
        self.m_num_text:setColor(120,120,120)
        self.m_num_text:setAlign(kAlignBottom);
        self.m_num_text:setPos(0,10)
        self:addChild(self.m_num_text)
    end
--    self.m_num_text = new(Text,numText,nil,nil,kAlignCenter,nil,22,240,200,160);
--    self.m_num_text:setAlign(kAlignCenter);
--    self.m_bottom_bg:addChild(self.m_num_text)
    
    --透明按钮
    if self.mode == GiftModuleItem.s_mode_gift then
        self.m_button = new(Button,"drawable/blank.png","drawable/blank_press.png");
        self.m_button:setSize(w,h);
        self.m_button:setAlign(kAlignCenter);
        self:addChild(self.m_button)
        self.m_button:setOnClick(self,function()
            self:onSendGift()
            self.gift_num = 1
        end);
        self.m_button:setOnTuchProcess(self,self.onTuchProcess)
        self.m_button:setSrollOnClick()
    end
    
    self.switch = {
        ["1"] = function(typeId)
            local x,y = self.scrollview:getScrollViewPos();
            GiftModuleScrollList.imglist[4]:setVisible(true)
            GiftModuleScrollList.imglist[1]:setVisible(true)
            GiftModuleScrollList.imglist[2]:setVisible(false)
            GiftModuleScrollList.imglist[3]:setVisible(false)
            GiftModuleScrollList.imglist[4]:setPos(34-x,0)
            GiftModuleScrollList.imglist[1]:setPos(0-x,0)
            GiftModuleScrollList.progressIcon:setSize(20,50)
        end,
        ["10"] = function(typeId)
            local x,y = self.scrollview:getScrollViewPos();
            GiftModuleScrollList.imglist[4]:setVisible(true)
            GiftModuleScrollList.imglist[1]:setVisible(true)
            GiftModuleScrollList.imglist[2]:setVisible(true)
            GiftModuleScrollList.imglist[3]:setVisible(false)
            GiftModuleScrollList.imglist[4]:setPos(68-x,0)
            GiftModuleScrollList.imglist[1]:setPos(34-x,0)
            GiftModuleScrollList.imglist[2]:setPos(0-x,0)
            GiftModuleScrollList.progressIcon:setSize(240,50)
        end,
        ["100"] = function(typeId)
            local x,y = self.scrollview:getScrollViewPos(); 
            GiftModuleScrollList.imglist[4]:setVisible(true)
            GiftModuleScrollList.imglist[1]:setVisible(true)
            GiftModuleScrollList.imglist[2]:setVisible(true)
            GiftModuleScrollList.imglist[3]:setVisible(true)
            GiftModuleScrollList.imglist[4]:setPos(102-x,0)
            GiftModuleScrollList.imglist[1]:setPos(68-x,0)
            GiftModuleScrollList.imglist[2]:setPos(34-x,0)
            GiftModuleScrollList.imglist[3]:setPos(0-x,0)
            GiftModuleScrollList.progressIcon:setSize(420,50)
        end,
    }

end

function GiftModuleItem.dtor(self)
    GiftModuleController.releaseInstance()
    delete(self.selectAnim)
    self.selectAnim = nil
end

function GiftModuleItem.onTuchProcess(self,enable)
    if not enable then
        local f = self.switch[self.gift_num .. ""]
        if f then
            f(self.m_data.cate_id)
        end
        local x,y = self:getPos();
        if GiftModuleScrollList.tip_bg then
            GiftModuleScrollList.tip_bg:setPos(x-60,-20); 
        end
        if not self.selectAnim then
            self.selectAnim = new(AnimInt,kAnimLoop,0,1,800,-1)
            self.gift_num = 100
            local func = function(self)       
                Log.i("time" .. os.clock() .. " + " .. self.gift_num)
                if self.gift_num == 1 then
                    self.gift_num = 10
                elseif self.gift_num == 10 then
                    self.gift_num = 100
                elseif self.gift_num == 100 then
                    self.gift_num = 1
                end

                local f = self.switch[self.gift_num .. ""]
                if f then
                    f(self.m_data.cate_id)
                end

                if GiftModuleScrollList.tip_bg then
                    GiftModuleScrollList.tip_bg:setVisible(true)
                    GiftModuleScrollList.progressBg:setVisible(true)
                end
            end
            self.selectAnim:setEvent(self,func);
            func(self)
        end
    else
--        self.gift_num = 1
        self:resetNumView()
    end
end

function GiftModuleItem.resetNumView(self)
    delete(self.selectAnim)
    self.selectAnim = nil
    GiftModuleScrollList.progressBg:setVisible(false)
    if GiftModuleScrollList.tip_bg then
        GiftModuleScrollList.tip_bg:setVisible(false);
    end
--    local f = self.switch["1"]
--    if f then
--        f()
--    end
end

--[Comment]
--发送礼物
function GiftModuleItem.onSendGift(self)
    self:resetNumView()
    local num = self.gift_num or 1;
--    local times = nil
--    if GiftModuleScrollList.handler then
--        times = GiftModuleScrollList.handler:getTimes();
--    end
--    if not times then
--        num = 1
--    elseif times == 1 then
--        num = 10
--    elseif times == 2 then
--        num = 100
--    end

    local payData = {}
    payData = ToolKit.getBuyCoinsPhpConfig()

    if self.m_data.cate_id == 19 and not (UserInfo.getInstance():getIsVip() == 1) then
        ChessToastManager.getInstance():showSingle("成为会员即可使用该礼物！");
--        local vip_id = 2321
--        local goods_id = ((kPlatform == kPlatformIOS) and 2324 or 2321)
--        local goods = MallData.getInstance():getGoodsById(vip_id)
--        if not goods then return end
--        GiftModuleItem.m_PayInterface = PayUtil.getPayInstance(PayUtil.s_defaultType);
--		goods.position = MALL_COINS_GOODS;
--		GiftModuleItem.m_pay_dialog = GiftModuleItem.m_PayInterface:buy(goods,payData);
        self:buyVip()
        return
    end

    local giftMoney = num * tonumber(self.exchange_price)
    local ret,buyMoney = self:canSendgift(giftMoney)
    if not ret then 
        local goods = MallData.getInstance():getGoodsByMoreMoney(buyMoney)
        if not goods then return end
        GiftModuleItem.m_PayInterface = PayUtil.getPayInstance(PayUtil.s_defaultType);
		goods.position = MALL_COINS_GOODS;
		GiftModuleItem.m_pay_dialog = GiftModuleItem.m_PayInterface:buy(goods,payData);
        return
    end

    local params = {};
    params.gift_type  = self.m_data.cate_id;
    params.gift_count = num;
    GiftModuleController.getInstance():onSendGift(params);
end


function GiftModuleItem.buyVip(self)
    local data = {};
    data = MallData.getInstance():getVipGoods()
    if not data or type(data) ~= "table" then  return end
    if next(data) ~= nil then
        if kPlatform == kPlatformIOS then
            VipModifyScene.m_PayInterface = PayUtil.getPayInstance(PayUtil.s_payType.Exchange);
		    data.position = data.id;
		    VipModifyScene.m_pay_dialog = VipModifyScene.m_PayInterface:buy(data,data.position);
        else
            local payData = {}
            payData.pay_scene = PayUtil.s_pay_scene.default_recommend
            VipModifyScene.m_PayInterface = PayUtil.getPayInstance(PayUtil.s_defaultType);
		    data.position = MALL_COINS_GOODS;
		    VipModifyScene.m_pay_dialog = VipModifyScene.m_PayInterface:buy(data,payData);
        end
    end

end

--[Comment]
--更新礼物数量
function GiftModuleItem.onUpdate(self,data)
    if self.mode == GiftModuleItem.s_mode_other or self.mode == GiftModuleItem.s_mode_user then
        self.m_num_text:setText(data or 0)
    elseif self.mode == GiftModuleItem.s_mode_user2 then
        self.m_num_text:setText("X" .. (data or 0))
    elseif self.mode == GiftModuleItem.s_mode_gift then
--        if self.m_recv_text then
--            local num = data or 0
--            self.m_recv_text:setText("收到:" .. num)
--        end
    end
end

--[Comment]
--判断是否可以发送礼物
--giftMoney: 发送礼物消耗的金币
--返回： true可以发送礼物 false不能发送礼物
function GiftModuleItem.canSendgift(self,giftMoney)
    -- 是否可以发送礼物道具
    local miniMoney = 0
    local buyMoney = 0
    local userMoney = UserInfo.getInstance():getMoney()
    local roomType = RoomProxy.getInstance():getCurRoomType();
    
    if not RoomProxy.getInstance():getUserWatchMode() then
        local money = 200 --底注
        local rent = 100 --台费
        local roomConfig = RoomProxy.getInstance():getCurRoomConfig();
        local multiple =  RoomProxy.getInstance():getCurRoomMultiple();
        if roomConfig and roomConfig.money then
            money = tonumber(roomConfig.money) --底注
        end
        if roomConfig and roomConfig.rent then
            rent = tonumber(roomConfig.rent) --台费
        end
        miniMoney = multiple * money + rent
        buyMoney = miniMoney - userMoney
    end

    miniMoney = userMoney - miniMoney
    if miniMoney - giftMoney <= 0 then
        ChessToastManager.getInstance():showSingle("金币过低，无法发送互动礼物")
        buyMoney = buyMoney + giftMoney
        return false,buyMoney
    end
    return true
end
