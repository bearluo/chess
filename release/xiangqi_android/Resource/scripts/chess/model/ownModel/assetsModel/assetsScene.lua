--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23

require(BASE_PATH.."chessScene");


AssetsScene = class(ChessScene);

AssetsScene.s_controls = 
{
    back_btn                    = 1;
    assets_view                 = 3;
}

AssetsScene.s_cmds = 
{
    updata_ticket_num = 1;
    onLoadExchangeHistory = 2;
}

AssetsScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = AssetsScene.s_controls;
    self:create();
end 

AssetsScene.resume = function(self)
    ChessScene.resume(self);
    self:assetsUpdateView();
--    self:removeAnimProp();
--    self:resumeAnimStart();
    if not self.isInit then
        self.isInit = true
        self:selectBtn(1)
    end
end

AssetsScene.isShowBangdinDialog = false;

AssetsScene.pause = function(self)
	ChessScene.pause(self);
    self:removeAnimProp();
--    self:pauseAnimStart();
end 

AssetsScene.dtor = function(self)
    delete(self.anim_start);
    delete(self.anim_end);
end 

AssetsScene.removeAnimProp = function(self)

    if self.m_anim_prop_need_remove then
        self.m_assets_view:removeProp(1);

--        self.m_back_btn:removeProp(1);
    --    self.m_top_view:removeProp(1);
    --    self.m_more_btn:removeProp(1);
    --    self.m_bottom_view:removeProp(1);
        self.m_anim_prop_need_remove = false;
    end
end

AssetsScene.setAnimItemEnVisible = function(self,ret)
end


AssetsScene.resumeAnimStart = function(self,lastStateObj,timer)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;
    delete(self.anim_start);
    self.anim_start = new(AnimInt,kAnimNormal,0,1,delay,-1);
    if self.anim_start then
        self.anim_start:setEvent(self,function()
            self:setAnimItemEnVisible(true);
               delete(self.anim_start);
        end);
    end

    local anim = self.m_assets_view:addPropTransparency(1,kAnimNormal,waitTime,delay,0,1);
    if anim then
        anim:setEvent(self,function()
            self.m_anim_prop_need_remove = true;
            self:removeAnimProp();
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end  
        end);   
    end

--   local w,h = self.m_scroll_view:getSize();
--   local x,y = self.m_scroll_view:getPos();
--   self.m_scroll_view:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, -h-y, 0);

   -- 下部动画
--   local w,h = self.m_bottom_menu:getSize();
--   self.m_bottom_menu:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, h, 0);
   -- 
   
--   self.m_back_btn:addPropTransparency(1,kAnimNormal,duration,delay,0,1);
--   self.m_bottom_view:addPropTransparency(1,kAnimNormal,duration,delay,0,1);
--   self.m_top_view:addPropTransparency(1,kAnimNormal,duration,delay,0,1);
end

AssetsScene.pauseAnimStart = function(self,newStateObj,timer)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;
    delete(self.anim_end);
    self.anim_end = new(AnimInt,kAnimNormal,0,1,delay,-1);
    if self.anim_end then
        self.anim_end:setEvent(self,function()
            self.m_anim_prop_need_remove = true;
            self:removeAnimProp();
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end  
            delete(self.anim_end);
        end);
    end

    local anim = self.m_assets_view:addPropTransparency(1,kAnimNormal,waitTime,-1,1,0);
    if anim then
        anim:setEvent(self,function()
            self:setAnimItemEnVisible(false);
        end);
    end
--   local w,h = self.m_scroll_view:getSize();
--   local x,y = self.m_scroll_view:getPos();
--   self.m_scroll_view:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, 0, -h-y);
   -- 下部动画
--   local w,h = self.m_bottom_menu:getSize();
--   self.m_bottom_menu:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, 0, h);
   -- 

--   self.m_back_btn:addPropTransparency(1,kAnimNormal,duration,delay,1,0);
--   self.m_bottom_view:addPropTransparency(1,kAnimNormal,duration,delay,1,0);
--   self.m_top_view:addPropTransparency(1,kAnimNormal,duration,delay,1,0);
end

---------------------- func --------------------
AssetsScene.create = function(self)

	self.m_back_btn = self:findViewById(self.m_ctrls.back_btn);

    self.m_assets_view = self:findViewById(self.m_ctrls.assets_view);
    self.m_exchange_history_view = self.m_root:getChildByName("exchange_history_view")
    self.m_assets_btn = self.m_root:getChildByName("assets_btn")
    self.m_assets_btn:setOnClick(self,function()
        self:selectBtn(1)
    end)
    self.m_exchange_history_btn = self.m_root:getChildByName("exchange_history_btn")
    self.m_exchange_history_btn:setOnClick(self,function()
        self:selectBtn(2)
    end)
    local w,h = self.m_exchange_history_view:getSize()
    self.mExchangeHistoryScrollView = new(SlidingLoadView,0,0,w,h)
    self.mExchangeHistoryScrollView:setOnLoad(self,self.loadExchangeHistory)
    self.mExchangeHistoryScrollView:setNoDataTip("没有更多数据");
    self.m_exchange_history_view:addChild(self.mExchangeHistoryScrollView)

    self.m_assets_content_view = self.m_assets_view:getChildByName("assets_content_view");
    --ios审核关闭元宝相关
    self.m_yuanbao_item = self.m_assets_content_view:getChildByName("yuanbao_item");
    self.m_assets_bccoin_text = self.m_assets_content_view:getChildByName("yuanbao_item"):getChildByName("item_text");
    self.m_soul_item = self.m_assets_content_view:getChildByName("soul_item");
    if kPlatform == kPlatformIOS then
        if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
            self.m_yuanbao_item:setVisible(true);
        else
            self.m_yuanbao_item:setVisible(false);
        end;
    else
        self.m_yuanbao_item:setVisible(true);       
    end;
    self.m_assets_gold_text = self.m_assets_view:getChildByName("money");
    self.m_assets_vip_text  = self.m_assets_view:getChildByName("time");
    self.m_assets_soul_text = self.m_assets_content_view:getChildByName("soul_item"):getChildByName("item_text");
    self.m_assets_tips_text = self.m_assets_content_view:getChildByName("tips_item"):getChildByName("item_text");
    self.m_assets_undo_text = self.m_assets_content_view:getChildByName("undo_item"):getChildByName("item_text");
    self.m_assets_relive_text = self.m_assets_content_view:getChildByName("relive_item"):getChildByName("item_text");
    self.m_assets_ticket_text = self.m_assets_content_view:getChildByName("ticket_item"):getChildByName("item_text");

--    self.m_assets_ticket_btn = new(Button,"drawable/blank.png")
--    self.m_assets_ticket_btn:setSize(232,232)
--    self.m_assets_ticket_btn:setAlign(kAlignCenter)
--    self.m_assets_ticket_btn:setPos(0,0)
--    self.ticket_item = self.m_assets_content_view:getChildByName("ticket_item")
--    self.ticket_item:addChild(self.m_assets_ticket_btn)

    self.m_assets_ticket_btn = self.m_assets_content_view:getChildByName("ticket_item"):getChildByName("btn");
    self.m_assets_ticket_btn:setOnClick(self,self.checkTicket)

    self.ticket_data = {}

end

AssetsScene.assetsUpdateView = function(self)
    self.m_assets_gold_text:setText(UserInfo.getInstance():getMoneyStr());
    self.m_assets_vip_text:setText(UserInfo.getInstance():getVipTimeText());
    self.m_assets_bccoin_text:setText(UserInfo.getInstance():getBccoin());
    self.m_assets_soul_text:setText(UserInfo.getInstance():getSoulCount());
    self.m_assets_tips_text:setText(UserInfo.getInstance():getTipsNum());
    self.m_assets_undo_text:setText(UserInfo.getInstance():getUndoNum());
    self.m_assets_relive_text:setText(UserInfo.getInstance():getReviveNum());
--    self.m_assets_ticket_text:setText("剩:"..UserInfo.getInstance():getTicketNum());
end

AssetsScene.onBackAction = function(self)
    self:requestCtrlCmd(AssetsController.s_cmds.onBack);
end

AssetsScene.onUpdataTicket = function(self)
    local data = UserInfo.getInstance():getTicketData()
    self.ticket_data = data
    local ticketNum = 0
    if not data or next(data) == nil then
        
    else
        for k,v  in pairs(data) do
            if v then
                local num = tonumber(v.prop_num) or 0
                ticketNum = num + ticketNum
            end
        end
    end
    self.m_assets_ticket_text:setText(ticketNum .. "张");
end

AssetsScene.checkTicket = function(self)
    StateMachine.getInstance():pushState(States.ticketModel,StateMachine.STYPE_CUSTOM_WAIT)
end


function AssetsScene:selectBtn(index)
    self.setCheckStatus(self.m_assets_btn,false)
    self.setCheckStatus(self.m_exchange_history_btn,false)
    self.m_assets_view:setVisible(false)
    self.m_exchange_history_view:setVisible(false)
    if index == 1 then
        self.setCheckStatus(self.m_assets_btn,true)
        self.m_assets_view:setVisible(true)
    else
        self.setCheckStatus(self.m_exchange_history_btn,true)
        self.m_exchange_history_view:setVisible(true)
        if not self.m_exchange_history_view_isInit then
            self.m_exchange_history_view_isInit = true
            self:startLoadExchangeHistory()
        end
    end
end

function AssetsScene.setCheckStatus(view,flag)
    if not view then return end
    local txt = view:getChildByName("txt")
    if flag then
        view:setFile("common/button/table_chose_5.png")
        txt:setColor(95,15,15)
    else
        view:setFile("common/button/table_nor_5.png")
        txt:setColor(230,185,140)
    end
end

function AssetsScene:startLoadExchangeHistory()
    self.requestExchangeHistoryIndex = 0
    self.sendExchangeHistoryIng = false
    self.sendExchangeHistoryNoMore = false
    self.mExchangeHistoryScrollView:setVisible(false)
    self.mExchangeHistoryScrollView:reset()
    self.mExchangeHistoryScrollView:loadView()
end

function AssetsScene:loadExchangeHistory()
    if self.sendExchangeHistoryIng or self.sendExchangeHistoryNoMore then return end;
    self.sendExchangeHistoryIng = true;
    self.requestExchangeHistoryIndex = self.requestExchangeHistoryIndex or 0;
    local params = {};
    params.mid = UserInfo.getInstance():getUid();
	params.offset = self.requestExchangeHistoryIndex;
	params.limit = 10;
    HttpModule.getInstance():execute(HttpModule.s_cmds.UserExchangeHistory,params);
end

function AssetsScene:onLoadExchangeHistory(isSuccess,message)
    if not self.sendExchangeHistoryIng then return end
    self.sendExchangeHistoryIng = false
    if not isSuccess or (type(message) == "table" and message.data:get_value() == nil ) then
        if type(message) == "table" then
            self:addExchangeHistoryItem({},true);
            self.sendExchangeHistoryNoMore = true;
            return ;
        end
        return ;
    end
    
    local tab = json.analyzeJsonNode(message.data);
    local list = tab.list;
    if type(list) ~= "table" or #list == 0 then
        if tab.total ~= 0 then
            self:addExchangeHistoryItem({},true);
        end
        self.sendExchangeHistoryNoMore = true;
        return ;
    end
    
    self.requestExchangeHistoryIndex = self.requestExchangeHistoryIndex + #list;

    self:addExchangeHistoryItem(list,false);
end


AssetsScene.addExchangeHistoryItem = function(self,datas,isNoData)
--    for i=1,3 do 
    for i,v in ipairs(datas) do
        if type(v) == "table"  then
            local item = new(ExchangeHistoryItem,v)
            self.mExchangeHistoryScrollView:addChild(item);
        end
    end
--    end
    self.mExchangeHistoryScrollView:loadEnd(isNoData);
    if next(self.mExchangeHistoryScrollView:getChildren()) then
        self.mExchangeHistoryScrollView:setVisible(true)
        self.m_exchange_history_view:getChildByName("tips"):setVisible(false)
    else
        self.mExchangeHistoryScrollView:setVisible(false)
        self.m_exchange_history_view:getChildByName("tips"):setVisible(true)
    end
end
---------------------- config ------------------
AssetsScene.s_controlConfig = {
    [AssetsScene.s_controls.back_btn]                          = {"back_btn"};
    [AssetsScene.s_controls.assets_view]                       = {"assets_view"};
}

AssetsScene.s_controlFuncMap = {
    [AssetsScene.s_controls.back_btn]                        = AssetsScene.onBackAction;
};

AssetsScene.s_cmdConfig =
{   
    [AssetsScene.s_cmds.updata_ticket_num]                   = AssetsScene.onUpdataTicket;
    [AssetsScene.s_cmds.onLoadExchangeHistory]               = AssetsScene.onLoadExchangeHistory;
}
require(VIEW_PATH .. "exchange_history_item_view")
ExchangeHistoryItem = class(Node)

function ExchangeHistoryItem:ctor(data)
    self.mRoot = SceneLoader.load(exchange_history_item_view)
    local w,h = self.mRoot:getSize()
    self:setSize(w,h)
    self:addChild(self.mRoot)
    self.mIcon = new(Image,"mall/" .. (data.good_img or "") .. ".png")
    self.mIcon:setAlign(kAlignCenter)

    self.mRoot:getChildByName("icon_view"):addChild(self.mIcon)

    self.mName = self.mRoot:getChildByName("name")
    self.mName:setText(data.good_name)
    self.mValue = self.mRoot:getChildByName("value")
    self.mValue:setText(data.cost_soul)
    self.mTime = self.mRoot:getChildByName("time")
    self.mTime:setText( os.date("%Y/%m/%d %H:%M", tonumber(data.time) or 0) )
    local status = tonumber(data.status)
    local str = "未知"
    self.mStatus = self.mRoot:getChildByName("status")
    if status == 0 then
        str = "下单失败"
        self.mStatus:setColor(55,145,55)
    elseif status == 1 then
        str = "下单成功"
        self.mStatus:setColor(150,150,150)
    elseif status == 2 then
        str = "充值失败"
        self.mStatus:setColor(55,145,55)
    elseif status == 3 then
        str = "充值成功"
        self.mStatus:setColor(55,145,55)
    end
    self.mStatus:setText(str)
end