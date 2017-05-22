require(VIEW_PATH .. "daily_sign_dialog");
require(BASE_PATH.."chessDialogScene");

DailySignDialog = class(ChessDialogScene,false);

DailySignDialog.MODE_VIP = 1;
DailySignDialog.MODE_NORMAL = 2;

DailySignDialog.handler = nil

DailySignDialog.displayValue = 
{
    REWARD_BN = "关闭";
}
DailySignDialog.Daily_plist = {
    [1] = 1,    [2] = 1,    [3] = 1,    [4] = 2,    [5] = 2,
    [6] = 2,    [7] = 2,
}

DailySignDialog.Title_plist = {
    [1] = "第1天",    [2] = "第2天",    [3] = "第3天",    [4] = "第4天",    [5] = "第5天",
    [6] = "第6天",    [7] = "第7天",
}
DailySignDialog.BtnPic = {GET_REWARD_BTN_PRESS = "common/button/long_grey_btn.png"}

DailySignDialog.ctor = function(self)
    super(self,daily_sign_dialog);

    self.m_root_view = self.m_root;
    self.m_item_view1 = self.m_root_view:getChildByName("view");
    self.item_view1 = self.m_item_view1:getChildByName("item_view1")
    self.item_view2 = self.m_item_view1:getChildByName("item_view2")
    self.activity_view = self.m_item_view1:getChildByName("activity_view")
    self.default_btn = self.activity_view:getChildByName("default_btn")
    self.title = self.m_root_view:getChildByName("title");
    self.default_btn:setOnClick(self,self.showBuyVipDialog)
    self.nodeList = {}
    --初始化每日签到列表
    self.scroll_tab = {}
    self.scroll_tab[1] = new(ScrollView2,nil,nil,DailySignItem1.DEFAULT_WIDTH*3,DailySignItem1.DEFAULT_HEIGHT,true)
    self.scroll_tab[1]:setAlign(kAlignLeft)
    self.scroll_tab[1]:setDirection(kHorizontal)
    self.item_view1:addChild(self.scroll_tab[1])

    self.scroll_tab[2] = new(ScrollView2,nil,nil,DailySignItem1.DEFAULT_WIDTH*4,DailySignItem1.DEFAULT_HEIGHT,true)
    self.scroll_tab[2]:setAlign(kAlignLeft)
    self.scroll_tab[2]:setDirection(kHorizontal)
    self.item_view2:addChild(self.scroll_tab[2])
    --end
    self.getRewardBtn = self.m_root_view:getChildByName("get_btn")
    self.vip_tip = self.m_root_view:getChildByName("vip_tips")
    self.getRewardBtn:setOnClick(self,self.getSignReward)

--    if UserInfo.getInstance():getIsVip() == 1 then
--        self.vip_tip:setVisible(true)
--    else
--        self.vip_tip:setVisible(false)
--    end
    self:setVisible(false);
    self:setShieldClick(self,self.dismiss)
    self.m_item_view1:setEventTouch(nil,function() end);
    DailySignDialog.handler = self
    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)

    self:getActionList()
    self:updataTitleView()
    self.has_sign = false
end

DailySignDialog.dtor = function(self)
    self.m_root_view = nil;
    self.mDialogAnim.stopAnim()
end

DailySignDialog.isShowing = function(self)
    return self:getVisible();
end

DailySignDialog.show = function(self)
    self.super.show(self,self.mDialogAnim.showAnim);
    DailyTaskData.getInstance():setSignShowStatus(false);
    DailyTaskManager.getInstance():register(DailySignDialog.handler,DailySignDialog.handler.updataSignStatus);
    StatisticsManager.getInstance():onNewUserCountToPHP(StatisticsManager.NEW_USER_COUNT_DAILY_SIGN,UserInfo.getInstance():getIsFirstLogin())
end
require(DIALOG_PATH .. "startEvaluationGameDialog")
require("dialog/third_guide_dialog");
DailySignDialog.dismiss = function(self)
    DailyTaskManager.getInstance():unregister(DailySignDialog.handler,DailySignDialog.handler.updataSignStatus);
    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
    if UserInfo.getInstance():getIsFirstLogin() == 1 then
--        if not self.mStartEvaluationGameDialog then
--            self.mStartEvaluationGameDialog = new(StartEvaluationGameDialog)
--        end
--        self.mStartEvaluationGameDialog:show()
        ThirdGuideDialog.getInstance():show()
    end
end

--DailySignDialog.setPositiveListener = function(self,obj,func,arg) -- 增加arg参数，当点击确定的时候返回
--	self.m_posObj = obj;
--	self.m_posFunc = func;
--    self.m_posArg = arg;
--end

function DailySignDialog.updataTitleView(self)
    local temp = os.date("*t", os.time())
    local h = temp.hour
    if  h >= 0 and h < 11 then
        self.title:setText("早上好")
    elseif h >= 11 and h < 13 then
        self.title:setText("中午好")
    elseif h >= 13 and h < 18 then
        self.title:setText("下午好")
    elseif h >= 18 and h < 24 then
        self.title:setText("晚上好")
    end
end 

function DailySignDialog.getActionList(self)
    local params = {}
    params.bid = PhpConfig.getSidPlatform();
    params.versions = kLuaVersion;
    HttpModule.getInstance():execute2(HttpModule.s_cmds.IndexGetActionList,params,function(isSuccess,resultStr)
        if isSuccess then
            local data = json.decode(resultStr)
            if not data or data.error then 
                self:showActivity()
                return
            end
            local tab = data.data
            if not tab or type(tab) ~= "table" or #tab == 0 then 
                --没有活动
                self:showActivity()
                return
            end
            local data = tab[1]
            self:showActivity(data)
        else
            self:showActivity()
        end
    end)
end

function DailySignDialog.showActivity(self,data)
    if not data then
        self.default_btn:setVisible(true)
        return
    end
    self.default_btn:setVisible(false)
    if self.act then
        self.activity_view:removeChild(self.act)
    end
    delete(self.act)
    self.act = new(DailySignActivityItem,data)
    self.activity_view:addChild(self.act)
end

function DailySignDialog:showBuyVipDialog()
    local data = {};
    data = MallData.getInstance():getVipGoods()
    if next(data) ~= nil then
        if kPlatform == kPlatformIOS then
            DailySignDialog.m_PayInterface = PayUtil.getPayInstance(PayUtil.s_payType.Exchange);
		    data.position = data.id;
		    DailySignDialog.m_pay_dialog = DailySignDialog.m_PayInterface:buy(data,data.position);
        else
            local payData = {}
            payData.pay_scene = PayUtil.s_pay_scene.default_recommend
            DailySignDialog.m_PayInterface = PayUtil.getPayInstance(PayUtil.s_defaultType);
		    data.position = MALL_COINS_GOODS;
		    DailySignDialog.m_pay_dialog = DailySignDialog.m_PayInterface:buy(data,payData);
        end
    else
        StateMachine.getInstance():pushState(States.Mall,StateMachine.STYPE_CUSTOM_WAIT)
    end
end

--DailySignDialog.showVipTime = function(self)
--    local nowTime = os.time();
--    local endTime = UserInfo.getInstance():getVipTime();

--    if not endTime or endTime == 0 then
--        return
--    end

--    local diffTime = endTime - nowTime;
--    local time_h = math.floor(diffTime/3600);
--    local time_str = 0;
--    if time_h > 0 then
--        time_str = math.ceil(time_h/24);
--    elseif time_h < 0 then
--        return
--    end

--    self.m_vip_time:setText(time_str .. "天");
--    self.m_vip_time_view:setVisible(true);
--end

--function DailySignDialog:setData(data)
--    if not data then return end
--    self:initItemView(data);
--end

function DailySignDialog.updataSignScrollView(self,data)
    if not data then return end
    self.signData = data
    self.listData = self.signData.list
    if UserInfo.getInstance():getIsVip() == 1 then
        self.multiple = self.signData.multiple or 1
    else
        self.multiple = 1
    end
    if not self.listData then return end
    local i = 1
    local n = 1
    for k,v in pairs(self.listData) do
        if v then
            --设置当前可以领取的金币数
            if  v.status and v.status == 1 then 
                if v.reward and v.reward.money then 
                    --当前可以领取的金币数
                    self.mGetMoney = tonumber(v.reward.money) or 0
                end 
            end 
            
            i = DailySignDialog.Daily_plist[n]
            n = n + 1
            if not i then break end
            local node = new(DailySignItem1,v,self.multiple)
            table.insert(self.nodeList,node)
            if self.scroll_tab[i] and node then
                self.scroll_tab[i]:addChild(node)
            end
        end
    end
end

function DailySignDialog.updataSignStatus(self)
    if not DailyTaskData.getInstance():getUpdataDailySignStatus() then return end
    DailyTaskData.getInstance():setUpdataDailySignStatus(false)
    DailyTaskManager.getInstance():unregister(DailySignDialog.handler,DailySignDialog.handler.updataSignStatus);
    self.has_sign  = true
    self.getRewardBtn:getChildByName("text"):setText(DailySignDialog.displayValue.REWARD_BN)
    --self.getRewardBtn:setGray(true)
    self.getRewardBtn:setFile(DailySignDialog.BtnPic.GET_REWARD_BTN_PRESS)
    --self.getRewardBtn:setSize(370,nil)
    --播放金币掉落动画
    DiceAccountDropMoney.play(50);
    --显示tip：获得多少金币
    ChessToastManager.getInstance():showSingle("获得"..self.mGetMoney or 0 .."金币",1500);
    for k,v in pairs(self.nodeList) do 
        if v then 
            if v.get_status and v.get_status == 1 then
                v:updataItemStatus()
            end
        end
    end
    --self:dismiss()
end

function DailySignDialog.getSignReward(self)
    if self.has_sign then 
        --ChessToastManager.getInstance():showSingle(DailySignDialog.displayValue.REWARD_BN,1500);
        self:dismiss()
        return 
    end

    local tips = "领取中...";
    local post_data = {};
    post_data.mid = UserInfo.getInstance():getUid();
    HttpModule.getInstance():execute(HttpModule.s_cmds.getSignReward,post_data,tips);

--    if self.get_status then
--        if self.get_status == 0 then
--            ChessToastManager.getInstance():showSingle("不能领取！",1500);
--        elseif self.get_status == 1 then
--            DailyTaskManager.getInstance():unregister(DailySignDialog.handler,DailySignDialog.handler.updataSignStatus);
--            DailyTaskManager.getInstance():register(DailySignDialog.handler,DailySignDialog.handler.updataSignStatus);
--            DailySignDialog.handler:getSignReward()
--        elseif self.get_status == 2 then
--            ChessToastManager.getInstance():showSingle("已领取！",1500);
--        end
--    end
end

--function DailySignDialog:initItemView(data)
--    local mode = data.mode;
--    local item = data.item;
--    local normal_gold = data.normal_gold;
--    local vip_gold = data.vip_gold;
--    self.item_tab = {};
--    self.m_item_view:setSize(DailySignItem.DEFAULT_WIDTH,DailySignItem.DEFAULT_HEIGHT);

--    if mode == DailySignDialog.MODE_VIP then
--        self:showVipTime();
--        self.vip_item = new(DailySignItem,vip_gold,DailySignDialog.MODE_VIP);
--        self.vip_item:setAlign(kAlignRight);
--        self.m_item_view:addChild(self.vip_item);
--        table.insert(self.item_tab,self.vip_item);
--        if item == 2 then
--            self.normal_item = new(DailySignItem,normal_gold);
--            self.normal_item:setAlign(kAlignLeft);
--            self.m_item_view:addChild(self.normal_item);
--            self.m_item_view:setSize(DailySignItem.DEFAULT_WIDTH * 2,DailySignItem.DEFAULT_HEIGHT);
--            table.insert(self.item_tab,self.normal_item);
--            return
--        end
--    else
--        self.normal_item = new(DailySignItem,normal_gold);
--        self.normal_item:setAlign(kAlignLeft);
--        self.m_item_view:addChild(self.normal_item);
--        self.m_vip_time_view:setVisible(false);
--        table.insert(self.item_tab,self.normal_item);
--        return
--    end
--end

--DailySignItem = class(Node);
--DailySignItem.DEFAULT_WIDTH  = 349;
--DailySignItem.DEFAULT_HEIGHT = 320;

--function DailySignItem:ctor(gold,mode)

--    self:setSize(DailySignItem.DEFAULT_WIDTH,DailySignItem.DEFAULT_HEIGHT);

--    self.m_shine = new(Image,"dailytask/shine.png");
--    self.m_shine:setSize(360,360);
--    self.m_shine:setAlign(kAlignCenter);
--    self.m_shine:setPos(0,-12);
--    self:addChild(self.m_shine);

--    local imgStr = "dailytask/normal_bg.png";
--    if mode then
--        imgStr = "dailytask/vip_bg.png";
--    end

--    self.m_bg = new(Image,imgStr);
--    self.m_bg:setAlign(kAlignCenter);
--    self.m_bg:setPos(0,0);
--    self:addChild(self.m_bg);

--    self.m_gold_img = new(Image,"mall/mall_list_gold2.png");
--    self.m_gold_img:setSize(200,188);
--    self.m_gold_img:setAlign(kAlignCenter);
--    self.m_gold_img:setPos(5,-20);
--    self.m_bg:addChild(self.m_gold_img);

--    local goldStr = "600金币";
--    if gold then
--        goldStr = gold;
--    end

--    self.m_gold_text = new(Text,goldStr,nil, 76, kAlignCenter, nil, 40, 240, 230, 210);
--    self.m_gold_text:setAlign(kAlignBottom);
----    self.m_gold_text:setPos(0,0);
--    self.m_bg:addChild(self.m_gold_text);

--end 

--function DailySignItem:dtor()
--    if not self.m_shine:checkAddProp(1) then
--        self.m_shine:removeProp(1);
--    end
--end 

--function DailySignItem:startShineAnim()
--    if not self.m_shine:checkAddProp(1) then
--        self.m_shine:removeProp(1);
--    end
--    self.m_shine:addPropRotate(1,kAnimRepeat,7000,-1,0,360,kCenterDrawing);
--end 

--function DailySignItem:stopShineAnim()
--    if not self.m_shine:checkAddProp(1) then
--        self.m_shine:removeProp(1);
--    end
--end 


DailySignActivityItem = class(Node)

function DailySignActivityItem.ctor(self,data)
    self:setPos(0,0);
    self:setSize(600,300);
    self:setAlign(kAlignCenter)
    self.m_data = data;
--    self.mBg = new(Image,"common/background/activity_bg_2.png")
--    self.mBg:setAlign(kAlignCenter);
    self.m_btn = new(Button,"common/background/activity_bg.png");
    self.m_btn:setAlign(kAlignCenter);
    self.m_btn:setSize(600,300);
    self.m_btn:setSrollOnClick();
    self.m_btn:setOnClick(self,self.gotoActivity);

    self.m_icon = new(Mask,"common/background/activity_bg.png","common/background/activity_bg.png");
    self.m_icon:setAlign(kAlignCenter);
    self.m_icon:setSize(600,300);
    local str=self.m_data.img_url;
    self.m_icon:setUrlImage(str);

--    self:addChild(self.mBg);
    self:addChild(self.m_btn);
    self:addChild(self.m_icon);
end

function DailySignActivityItem.gotoActivity(self)
    self:showNativeListWebView(self.m_data.info_url);
end

function DailySignActivityItem.showNativeListWebView(self,url)
    local absoluteX,absoluteY = 0,0;
    local x = absoluteX*System.getLayoutScale();
    local y = absoluteY*System.getLayoutScale();
    local width = System.getScreenWidth();
    local height = System.getScreenHeight();
    NativeEvent.getInstance():showActivityWebView(x,y,width,height,url);
end

--// vip 提示item
DialyVipTips = class(Node)

function DialyVipTips.ctor(self,data)
    self:setPos(0,0)
    self:setAlign(kAlignCenter)
    self:setSize(160,180)

    self.bg = new(Image,"common/background/info_bg_10.png")
    self.bg:setAlign(kAlignCenter)
    self.bg:setPos(0,0)
    self:addChild(self.bg)

    self.vip_tips = new(Text,"VIP",nil,nil,nil,nil,32,255,255,255)
    self.vip_tips:setAlign(kAlignBottom)
    self.vip_tips:setPos(0,90)
    self:addChild(self.vip_tips)

    local times = data or 2
    local str = "奖励 X " .. times
    self.vip_times = new(Text,str,nil,nil,nil,nil,32,255,255,255)
    self.vip_times:setAlign(kAlignBottom)
    self.vip_times:setPos(0,50)
    self:addChild(self.vip_times)

    self.vip_tips:addPropRotateSolid(20, -10, kCenterDrawing)
    self.vip_times:addPropRotateSolid(20, -10, kCenterDrawing)

end

function DialyVipTips.dtor(self)
    self.vip_tips:removeProp(20)
    self.vip_times:removeProp(20)
end

--////////////


--// 每日见到item 
DailySignItem1 = class(Node);
DailySignItem1.DEFAULT_WIDTH  = 150;
DailySignItem1.DEFAULT_HEIGHT = 226;
require(VIEW_PATH .. "daily_sign_item")
function DailySignItem1.ctor(self,data,multiple)
    if not data then return end
    self.nodeData = data
    self.multiple = multiple or 1
    self.item_node = SceneLoader.load(daily_sign_item)
    self:addChild(self.item_node)
    self:setPos(0,0)
    self.item_node:setAlign(kAlignCenter)
    self:setSize(DailySignItem1.DEFAULT_WIDTH,DailySignItem1.DEFAULT_HEIGHT)
    
    self.item_bg = self.item_node:getChildByName("item_bg")
    self.item_status = self.item_node:getChildByName("get_status")
    self.item_img = self.item_node:getChildByName("reward_img")
    self.item_title = self.item_node:getChildByName("title")
    self.item_desc = self.item_node:getChildByName("desc")
    self.item_btn = self.item_node:getChildByName("Button1")
    self.item_btn:setSrollOnClick(nil,nil)
    self.item_btn:setOnClick(self,self.getDailySign)

    self:updataView()
    self:updataStatus()
end 

function DailySignItem1.dtor(self)
    delete(self.item_node)
    self.item_node = nil 
end 

function DailySignItem1.updataView(self)
    if not self.nodeData then return end
    local reward = self.nodeData.reward
    local item_img = "mall/mall_list_gold1.png"
    local money = 0
    if reward then
        money = tonumber(reward.money) or 0
    end
    self.item_img:setFile(item_img)

    local progress = tonumber(self.nodeData.day) or 0
    local title = DailySignDialog.Title_plist[progress]
    self.item_title:setText(title)

    local desc_text = string.format("%d金币",money * self.multiple)
    self.item_desc:setText(desc_text)
end 

function DailySignItem1.updataStatus(self)
    self.get_status = self.nodeData.status or 0
    local ret = (self.get_status == 2) and true or false
    self.item_status:setVisible(ret)
    if self.get_status == 1 then
        self.item_bg:setFile("common/background/enable_sign_bg.png")
        self.item_bg:setTransparency(1)
    else
        self.item_bg:setFile("common/background/unable_sign_bg.png")
        self.item_bg:setTransparency(0.7)
    end
end 

function DailySignItem1.getDailySign(self)
    if self.get_status then
        if self.get_status == 0 then
            ChessToastManager.getInstance():showSingle("不能领取！",1500);
        elseif self.get_status == 1 then
--            DailyTaskManager.getInstance():unregister(DailySignDialog.handler,DailySignDialog.handler.updataSignStatus);
--            DailyTaskManager.getInstance():register(DailySignDialog.handler,DailySignDialog.handler.updataSignStatus);
            DailySignDialog.handler:getSignReward()
        elseif self.get_status == 2 then
            ChessToastManager.getInstance():showSingle(DailySignDialog.displayValue.REWARD_BN,1500);
        end
    end
end

function DailySignItem1.updataItemStatus(self)
--    DailyTaskManager.getInstance():unregister(DailySignDialog.handler,DailySignDialog.handler.updataSignStatus);
    if not self.nodeData or not self.nodeData.status then return end
    self.nodeData.status = 2
    self:updataStatus()
end
--///////////////////