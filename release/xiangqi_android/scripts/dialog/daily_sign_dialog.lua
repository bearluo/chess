require(VIEW_PATH .. "daily_sign_dialog");
require(BASE_PATH.."chessDialogScene");

DailySignDialog = class(ChessDialogScene,false);

DailySignDialog.MODE_VIP = 1;
DailySignDialog.MODE_NORMAL = 2;

DailySignDialog.ctor = function(self)
    super(self,daily_sign_dialog);

    self.m_root_view = self.m_root;
    self.m_item_view = self.m_root:getChildByName("item_view");

    self.m_title = self.m_root_view:getChildByName("sign_title");
    self.m_vip_time_view = self.m_root_view:getChildByName("vip_time");
    self.m_vip_time = self.m_vip_time_view:getChildByName("time");
    self.m_vip_time_view:setVisible(false);
    self.m_btn = self.m_root_view:getChildByName("btn1");
    self.m_btn:setOnClick(self,self.sure);

    self:setVisible(false);
end

DailySignDialog.dtor = function(self)
    self.m_root_view = nil;
end

DailySignDialog.isShowing = function(self)
    return self:getVisible();
end

DailySignDialog.show = function(self)
    self:setVisible(true);
    self.super.show(self,true,nil,2);

    for k,v in pairs(self.item_tab) do
        if v then
            v:startShineAnim();
        end
    end
end

DailySignDialog.dismiss = function(self)
    self:setVisible(false);
    self.super.dismiss(self);

    for k,v in pairs(self.item_tab) do
        if v then
            v:stopShineAnim();
        end
    end
end

DailySignDialog.setPositiveListener = function(self,obj,func,arg) -- 增加arg参数，当点击确定的时候返回
	self.m_posObj = obj;
	self.m_posFunc = func;
    self.m_posArg = arg;
end

DailySignDialog.sure = function(self)
	print_string("DailySignDialog.sure ");
	self:dismiss();
	if self.m_posObj and self.m_posFunc then
		self.m_posFunc(self.m_posObj,self.m_posArg);
	end
end

DailySignDialog.showVipTime = function(self)
    local nowTime = os.time();
    local endTime = UserInfo.getInstance():getVipTime();

    if not endTime or endTime == 0 then
        return
    end

    local diffTime = endTime - nowTime;
    local time_h = math.floor(diffTime/3600);
    local time_str = 0;
    if time_h > 0 then
        time_str = math.ceil(time_h/24);
    elseif time_h < 0 then
        return
    end

    self.m_vip_time:setText(time_str .. "天");
    self.m_vip_time_view:setVisible(true);
end

function DailySignDialog:setData(data)
    if not data then return end
    self:initItemView(data);
end

function DailySignDialog:initItemView(data)
    local mode = data.mode;
    local item = data.item;
    local normal_gold = data.normal_gold;
    local vip_gold = data.vip_gold;
    self.item_tab = {};
    self.m_item_view:setSize(DailySignItem.DEFAULT_WIDTH,DailySignItem.DEFAULT_HEIGHT);

    if mode == DailySignDialog.MODE_VIP then
        self:showVipTime();
        self.vip_item = new(DailySignItem,vip_gold,DailySignDialog.MODE_VIP);
        self.vip_item:setAlign(kAlignRight);
        self.m_item_view:addChild(self.vip_item);
        table.insert(self.item_tab,self.vip_item);
        if item == 2 then
            self.normal_item = new(DailySignItem,normal_gold);
            self.normal_item:setAlign(kAlignLeft);
            self.m_item_view:addChild(self.normal_item);
            self.m_item_view:setSize(DailySignItem.DEFAULT_WIDTH * 2,DailySignItem.DEFAULT_HEIGHT);
            table.insert(self.item_tab,self.normal_item);
            return
        end
    else
        self.normal_item = new(DailySignItem,normal_gold);
        self.normal_item:setAlign(kAlignLeft);
        self.m_item_view:addChild(self.normal_item);
        self.m_vip_time_view:setVisible(false);
        table.insert(self.item_tab,self.normal_item);
        return
    end
end

DailySignItem = class(Node);
DailySignItem.DEFAULT_WIDTH  = 349;
DailySignItem.DEFAULT_HEIGHT = 320;

function DailySignItem:ctor(gold,mode)
    
    self:setSize(DailySignItem.DEFAULT_WIDTH,DailySignItem.DEFAULT_HEIGHT);

    self.m_shine = new(Image,"dailytask/shine.png");
    self.m_shine:setSize(360,360);
    self.m_shine:setAlign(kAlignCenter);
    self.m_shine:setPos(0,-12);
    self:addChild(self.m_shine);
    
    local imgStr = "dailytask/normal_bg.png";
    if mode then
        imgStr = "dailytask/vip_bg.png";
    end

    self.m_bg = new(Image,imgStr);
    self.m_bg:setAlign(kAlignCenter);
    self.m_bg:setPos(0,0);
    self:addChild(self.m_bg);

    self.m_gold_img = new(Image,"mall/mall_list_gold2.png");
    self.m_gold_img:setSize(200,188);
    self.m_gold_img:setAlign(kAlignCenter);
    self.m_gold_img:setPos(5,-20);
    self.m_bg:addChild(self.m_gold_img);

    local goldStr = "600金币";
    if gold then
        goldStr = gold;
    end
    self.m_gold_text = new(Text,goldStr,nil, nil, nil, nil, 40, 240, 230, 210);
    self.m_gold_text:setAlign(kAlignBottom);
    self.m_gold_text:setPos(0,16);
    self.m_bg:addChild(self.m_gold_text);

end 

function DailySignItem:dtor()
    if not self.m_shine:checkAddProp(1) then
        self.m_shine:removeProp(1);
    end
end 

function DailySignItem:startShineAnim()
    if not self.m_shine:checkAddProp(1) then
        self.m_shine:removeProp(1);
    end
    self.m_shine:addPropRotate(1,kAnimRepeat,7000,-1,0,360,kCenterDrawing);
end 

function DailySignItem:stopShineAnim()
    if not self.m_shine:checkAddProp(1) then
        self.m_shine:removeProp(1);
    end
end 
