--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--破产补助弹窗
--endregion
require(VIEW_PATH .. "bankrupt_reward_dialog_view");
require("gameBase/gameLayer");

BankruptSubsidyDialog = class(GameLayer,false);

BankruptSubsidyDialog.ANIM_TIME = 320; -- 单位毫秒
BankruptSubsidyDialog.USE_UP_TIMES = 0; --领取剩余次数0
BankruptSubsidyDialog.ONETIMES = 1; --领取剩余次数1
BankruptSubsidyDialog.s_dialogLayer = nil;

function BankruptSubsidyDialog.getInstance()
    if not BankruptSubsidyDialog.s_instance then
        BankruptSubsidyDialog.s_instance = new(BankruptSubsidyDialog);
    end
    return BankruptSubsidyDialog.s_instance;
end

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
    self.m_draw_reward_btn = self.m_bg:getChildByName("draw_reward");
    self.m_reward_title = self.m_bg:getChildByName("Image2"):getChildByName("text");
--    self.m_content_list = new(ListView,0,552,720,300);
--    self.m_bg:addChild(self.m_content_list);
    self.m_content_list = self.m_bg:getChildByName("content_list");
    --推荐dialog
    self.m_small_bg = self.m_dialog_view:getChildByName("small_bg");
--    self.m_recommend_list = new(ListView,0,164,645,466);
--    self.m_small_bg:addChild(self.m_recommend_list);
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
    Log.i("BankruptSubsidyDialog.setShieldClick");
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
    local room_level = tonumber(UserInfo.getInstance():getRoomLevel());
    if room_level == 0 or room_level == 320 then
        room_level = 201
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


BankruptSubsidyItem = class(Node);
BankruptSubsidyItem.ICON_PRE = "mall/";

function BankruptSubsidyItem:ctor(data)
    if not data then return end
    self.item_data = data;
    self.handle = self.item_data.handle;
    require(VIEW_PATH .. "mall_item_node");
    self.m_root_view = SceneLoader.load(mall_item_node);
    self.m_root_view:setAlign(kAlignCenter);
    self:addChild(self.m_root_view);
    local w,h = self.m_root_view:getSize();
    self:setSize(w,h);
    self.m_bg_btn = new(Button,"drawable/blank.png");
    self.m_bg_btn:setSize(w,h);
    self.m_root_view:addChild(self.m_bg_btn);
    self.m_bg_btn:setOnClick(self.handle,self.handle.jumpMallScene);

    self.m_item_node = self.m_root_view:getChildByName("item_node");
    self.m_item_img = self.m_item_node:getChildByName("item_img");
    self.m_money_text = self.m_item_node:getChildByName("money_text");
    self.m_originmoney_text = self.m_item_node:getChildByName("originmoney_text");
    self.m_price_text = self.m_item_node:getChildByName("price_text");
    self.m_discount_line = self.m_item_node:getChildByName("discount_line");
    
    self:initViewData();
end

function BankruptSubsidyItem:dtor()

end

function BankruptSubsidyItem:initViewData()
    --商品图片
    self.m_item_img:setFile(BankruptSubsidyItem.ICON_PRE .. self.item_data.imgurl .. ".png");

    --商品名称.打折前金币
    local originmoney = self.item_data.originmoney;
    if self.item_data.cate_id and self.item_data.cate_id == 11 then
        originmoney = "";
        name = "有效期:30天";
        self.m_money_text:setText(self.item_data.name);
        self.m_originmoney_text:setText(originmoney .. name);
    else
        self.m_money_text:setText(self.item_data.money .. self.item_data.name);
        self.m_originmoney_text:setText(originmoney);
    end
    --价格
    local price = string.format("%d元",self.item_data.price);
    self.m_price_text:setText(price);
    
end