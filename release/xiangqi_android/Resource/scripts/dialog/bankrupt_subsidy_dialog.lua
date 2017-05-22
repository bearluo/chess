--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--破产补助弹窗
--endregion
require(VIEW_PATH .. "bankrupt_reward_dialog_view");
require("gameBase/gameLayer");
require(VIEW_PATH .. "mall_item_node");

BankruptSubsidyDialog = class(GameLayer,false);

BankruptSubsidyDialog.ANIM_TIME = 320; -- 单位毫秒
BankruptSubsidyDialog.USE_UP_TIMES = 0; --领取剩余次数0
BankruptSubsidyDialog.ONETIMES = 1; --领取剩余次数1
BankruptSubsidyDialog.s_dialogLayer = nil;


--function BankruptSubsidyDialog.getInstance()
--    if not BankruptSubsidyDialog.s_instance then
--        BankruptSubsidyDialog.s_instance = new(BankruptSubsidyDialog);
--    end
--    return BankruptSubsidyDialog.s_instance;
--end

function BankruptSubsidyDialog:ctor()
    super(self,bankrupt_reward_dialog_view);
    if not BankruptSubsidyDialog.s_dialogLayer then
        BankruptSubsidyDialog.s_dialogLayer = new(Node);
        BankruptSubsidyDialog.s_dialogLayer:addToRoot();
        BankruptSubsidyDialog.s_dialogLayer:setLevel(1);     
        BankruptSubsidyDialog.s_dialogLayer:setFillParent(true,true);
    end
    BankruptSubsidyDialog.s_dialogLayer:addChild(self);
    self:setFillParent(true,true);
    self.m_root:setLevel(1);
    self.m_root_view = self.m_root;
    self.is_dismissing = false;
    self:initView();
    self:setVisible(false);
end

function BankruptSubsidyDialog:dtor()
    delete(self.m_root_view);
    self.m_root_view = nil;
end

function BankruptSubsidyDialog:isShowing()
    return self:getVisible();
end

function BankruptSubsidyDialog:show()
    self.is_dismissing = false;
    self:removeViewProp();
    local w,h = self.m_dialog_view:getSize();
    
    local anim_start = self.m_dialog_view:addPropTranslate(1,kAnimNormal,BankruptSubsidyDialog.ANIM_TIME,-1,0,0,h,0);
    self:setVisible(true);
    if anim_start then
        anim_start:setEvent(self,function()
            self.m_dialog_view:removeProp(1);
        end);
    end
end

function BankruptSubsidyDialog:dismiss()
    --防止多次点击显示多次动画
    if self.is_dismissing then
        return;
    end
    self.is_dismissing = true;
    self:removeViewProp();
    local w,h = self.m_dialog_view:getSize();
    local anim_end = self.m_dialog_view:addPropTranslate(1,kAnimNormal,BankruptSubsidyDialog.ANIM_TIME,-1,0,0,0,h);
    self.m_root_view:addPropTransparency(1,kAnimNormal,BankruptSubsidyDialog.ANIM_TIME,-1,1,0);
    if anim_end then
        anim_end:setEvent(self,function()
            self:setVisible(false);
            self.m_dialog_view:removeProp(1);
            self.m_root_view:removeProp(1);
        end);
    end
--    if self.m_data.add_money and self.m_data.add_money ~= 0 then
--        self:onGetSubsidy();
--    end
end

function BankruptSubsidyDialog:setData(data,handler)
    self.m_handler = handler;
    self.m_data = data;
    if self.m_data.add_money and self.m_data.add_money ~= 0 then
        self.m_coin_num:setText(self.m_data.add_money .. "金币");
    end
    self:setShowStatus(self.m_data);
end

function BankruptSubsidyDialog:initView()
    -- 灰色背景
    self.m_bg_black = self.m_root_view:getChildByName("bg_black");
    self.m_bg_black:setEventTouch(self,self.setShieldClick);

    self.m_dialog_view = self.m_root_view:getChildByName("view");
    self.m_dialog_view:setEventTouch(nil,function() end);

    --领取dialog
    self.m_bg = self.m_dialog_view:getChildByName("bg");
    self.m_get_reward_view = self.m_bg:getChildByName("get_reward_view");
    self.m_coin_num = self.m_get_reward_view:getChildByName("coin_num");
    self.m_subsidy_dec = self.m_get_reward_view:getChildByName("dec");
    self.m_draw_reward_btn = self.m_get_reward_view:getChildByName("draw_reward");
    self.m_reward_title = self.m_bg:getChildByName("title");
    self.m_content_list = self.m_bg:getChildByName("content_list");
    --推荐dialog
    self.m_small_bg = self.m_dialog_view:getChildByName("small_bg");
    self.m_small_bg:addChild(self.m_recommend_list);
    self.m_recommend_list = self.m_small_bg:getChildByName("recommend_list_view");

    --每日任务
    self.m_daily_task_view = self.m_bg:getChildByName("daily_task_view");
    self.m_show_daily_task_btn = self.m_daily_task_view:getChildByName("Button1");

    self.m_show_daily_task_btn:setOnClick(self,self.getDailyTask);
    self.m_draw_reward_btn:setOnClick(self,self.getBankruptReward);--self.dismiss);
end

function BankruptSubsidyDialog:onGetSubsidy()
    print_string("BankruptSubsidyDialog.onGetSubsidy")
    if self.m_callBackObj and self.m_callBackFunc then
        self.m_callBackFunc(self.m_callBackObj);
    end
end

function BankruptSubsidyDialog:setDismissCallBack(obj, func, ...)
    self.m_callBackObj = obj;
	self.m_callBackFunc = func;
end

--移除控件属性
function BankruptSubsidyDialog:removeViewProp()

    if not self.m_dialog_view:checkAddProp(1) then
        self.m_dialog_view:removeProp(1);
    end

    if not self.m_root_view:checkAddProp(1) then
        self.m_root_view:removeProp(1);
    end
end

function BankruptSubsidyDialog:setShowStatus(data)
    if not data or not data.receive_times then return end
    if not data.remain_times or data.remain_times == 0 then
        self.m_bg:setVisible(false);
        self.m_small_bg:setVisible(true);
        UserInfo.getInstance():setShowBankruptStatus(false);
        self:refreshListView(self.m_recommend_list);
        return
    end
       
    if data.receive_times < 2 then
        self.m_bg:setVisible(true);
        self.m_small_bg:setVisible(false);
        self.m_content_list:setVisible(false);
        self.m_reward_title:setText("任务奖励");
        self.m_daily_task_view:setVisible(true);
    else
        self.m_bg:setVisible(true);
        self.m_small_bg:setVisible(false);
        self.m_reward_title:setText("超值特惠");
        self.m_content_list:setVisible(true);
        self.m_daily_task_view:setVisible(false);
        self:refreshListView(self.m_content_list);
    end
end

--[[  
        更新商品推荐列表
--]]  
function BankruptSubsidyDialog:refreshListView(listView)
    if not self.m_data or not listView or not self.m_data.shopRecommend or #self.m_data.shopRecommend == 0 then return end
    for k,v in pairs(self.m_data.shopRecommend) do
        v.handle = self;
    end
    listView:releaseAllViews();
    delete(self.m_adapter);
    if self.m_data.shopRecommend then
        self.m_adapter = new(CacheAdapter,BankruptSubsidyItem,self.m_data.shopRecommend);
        listView:setAdapter(self.m_adapter);
    end
end

function BankruptSubsidyDialog:setShieldClick(finger_action, x, y, drawing_id_first, drawing_id_current)
--    Log.i("BankruptSubsidyDialog.setShieldClick");
    if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
        if self:getVisible() then
            self:dismiss();
        end
    end
end

function BankruptSubsidyDialog:setMallCallBack(obj, func, ...)
    self.m_callBackObj2 = obj;
	self.m_callBackFunc2 = func;
end

function BankruptSubsidyDialog:setGetDailyTaskCallBack(obj, func, ...)
    self.m_callBackObj3 = obj;
	self.m_callBackFunc3 = func;
end


function BankruptSubsidyDialog:getDailyTask()
    self:dismiss();
--    GameData.getInstance():setGetDailyTask(true);
    local anim = new(AnimInt, kAnimNormal,0,1, 260, -1);
    if anim then
        anim:setEvent(self, function() 
	       if self.m_callBackObj3 and self.m_callBackFunc3 then
                self.m_callBackFunc3(self.m_callBackObj3);
            end
        end)
    end
end

function BankruptSubsidyDialog:getBankruptReward()
    local post_data = {};
	post_data.mid = UserInfo.getInstance():getUid();
	post_data.versions = PhpConfig.getVersions();
    local money = UserInfo.getInstance():getMoney();
    local room_config = RoomProxy.getInstance():getMatchRoomByMoney(money);
    local room_level = 201;
    if not room_config then

    else
        local room_level = tonumber(room_config.level);
        if not room_level or room_level == 0 or room_level == 320 then
            room_level = 201
        end
    end
    post_data.room_level = room_level;
    HttpModule.getInstance():execute(HttpModule.s_cmds.GetNewBankruptReward,post_data,"领取中");
--    self:dismiss();
end

function BankruptSubsidyDialog:jumpMallScene()
    print_string("BankruptSubsidyDialog.jumpMallScene")
    self:dismiss();
    local anim = new(AnimInt, kAnimNormal,0,1, 300, -1);
    if anim then
        anim:setEvent(self, function() 
	        if self.m_callBackObj2 and self.m_callBackFunc2 then
                self.m_callBackFunc2(self.m_callBackObj2);
            end
        end)
    end
end

--商品信息的Item
BankruptSubsidyItem = class(Node);
BankruptSubsidyItem.ICON_PRE = "mall/";
require(VIEW_PATH.."mall_pay_shop_item")

BankruptSubsidyItem.ctor = function(self,goods)
	print_string("MallShopItem.ctor" .. goods.id);
	self.m_data = {};
	for key ,value  in pairs(goods) do
		self.m_data[key] = value;
	end

    self:setPos(0,0)
    self:setAlign(kAlignTop);
    self:setSize(636,160)
    self.m_isPay = true   

    --商品背景
    self.mGoodsBg = new(Image,"common/background/bank_bg.png")
    self.mGoodsBg:setAlign(kAlignTopLeft)
    self:addChild(self.mGoodsBg);

    --商品图片
	self.mGoodsIcon = new(Image,MallShopItem.ICON_PRE .. goods.imgurl .. ".png")
    self.mGoodsIcon:setAlign(kAlignTopLeft)
    self.mGoodsIcon:setPos(28,-2)
    self:addChild(self.mGoodsIcon)

    self.mNameText = new(Text, goods.name, 0, 0, kAlignLeft,nil,40,80, 80, 80)
    self.mNameText:setAlign(kAlignTopLeft)
    self.mNameText:setPos(194,35)
    self:addChild(self.mNameText)
    
    self.mGoodsPriceIcon = new(Image,"common/icon/sale_icon.png");
    self.mGoodsPriceIcon:setAlign(kAlignTopLeft)
    self.mGoodsPriceIcon:setPos(457,56)
    self:addChild(self.mGoodsPriceIcon)

    --商品价格
    self.mGoodsPrice = new(Text, string.format("%d元",goods.price), 0, 0, kAlignLeft,nil,40,135, 100, 95)
    self.mGoodsPrice:setAlign(kAlignTopLeft)
    self.mGoodsPrice:setPos(514,57)
    self:addChild(self.mGoodsPrice)

    self.mDecsText = new(Text, goods.short_desc, 0, 0, kAlignLeft,nil,30,120,120,120)
    self.mDecsText:setPickable(false)
    self.mDecsText:setPos(194,80)
    self:addChild(self.mDecsText)
    
--    self.mPromotionIcon:setVisible(false)
--    self.mHotIcon:setVisible(false)
--    if goods.label then
--		if goods.label == 1 then --打折
--            self.mPromotionIcon:setVisible(true)
--		elseif goods.label == 2 then
--            self.mHotIcon:setVisible(true)
--		end
--	end

    self.m_button = new(Button,"drawable/blank.png")
    self.m_button:setAlign(kAlignCenter);
    self.m_button:setSize(636,160);
    self.m_button:setOnClick(self,self.buyGoods)
    self:addChild(self.m_button);

end

BankruptSubsidyItem.getData = function(self)

	return self.m_data;
end

BankruptSubsidyItem.buyGoods = function(self)
    if not self.m_data then return end
    if not self.m_data.goods_id then return end
    local payData = {}
    payData.pay_scene = PayUtil.s_pay_scene.bankruptcy
    local goods = MallData.getInstance():getGoodsById(self.m_data.goods_id)
    BankruptSubsidyDialog.m_PayInterface = PayUtil.getPayInstance(PayUtil.s_defaultType);
    goods.position = MALL_COINS_GOODS;
    BankruptSubsidyDialog.m_pay_dialog = BankruptSubsidyDialog.m_PayInterface:buy(goods,payData);
    PayDialog.getInstance():payOrderFirst()


--    BankruptSubsidyDialog.m_PayInterface = PayUtil.getPayInstance(PayUtil.s_defaultType);
--	goods.position = MALL_COINS_GOODS;
--	BankruptSubsidyDialog.m_pay_dialog = BankruptSubsidyDialog.m_PayInterface:buy(goods,MALL_COINS_GOODS);
end


BankruptSubsidyItem.dtor = function(self)
	
end	