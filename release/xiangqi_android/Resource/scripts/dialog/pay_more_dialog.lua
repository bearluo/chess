require(VIEW_PATH .. "pay_more_dialog_view");
require(BASE_PATH.."chessDialogScene");
require("ui/scrollViewEx");

PayMoreDialog = class(ChessDialogScene,false)

PayMoreDialog.s_controls = 
{
    pay_content_view    = 1;
    pay_pmode_group     = 2;
    close_btn           = 3;
    title               = 4;
}

PayMoreDialog.s_controlConfig = 
{
    [PayMoreDialog.s_controls.pay_content_view] = {"pay_content_view"};
    [PayMoreDialog.s_controls.pay_pmode_group]  = {"pay_content_view","pay_pmode_group"};
    [PayMoreDialog.s_controls.close_btn]        = {"pay_content_view","close_btn"},
    [PayMoreDialog.s_controls.title]            = {"pay_content_view","title"},
};

PayMoreDialog.s_controlFuncMap = 
{
}

PayMoreDialog.getInstance = function()
    if not PayMoreDialog.s_instance then
        PayMoreDialog.s_instance = new(PayMoreDialog)
    end
    return PayMoreDialog.s_instance
end

PayMoreDialog.releaseInstance = function()
    if PayMoreDialog.s_instance then
		delete(PayMoreDialog.s_instance);
		PayMoreDialog.s_instance = nil;
	end
end

PayMoreDialog.ctor = function(self)
    super(self,pay_more_dialog_view);
    self.m_ctrls = PayMoreDialog.s_controls;

    
    self.title = self:findViewById(self.m_ctrls.title)
    self.m_pay_content_view = self:findViewById(self.m_ctrls.pay_content_view);
    self.m_pay_content_view:setEventTouch(self.m_pay_content_view,function() end);
    self.m_pay_pmode_group = self:findViewById(self.m_ctrls.pay_pmode_group);
    self.m_close_btn = self:findViewById(self.m_ctrls.close_btn);

    self.m_close_btn:setOnClick(self,self.dismiss);
    self:setShieldClick(self,self.dismiss);
    self:setLevel(11)

    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)
end

function PayMoreDialog:setData(goods,payTypes,scene)
    self.m_goods = goods;
    self.m_scene = scene;
    self:initItems(payTypes)
end

function PayMoreDialog:showMorePayType(notFindPayType)
    if notFindPayType then
        -- 推荐支付不可用 且没有其他支付方式
        if #self.m_pmodesItem < 1 then
            return false
        end
    else
        -- 1个证明只有推荐支付
        if #self.m_pmodesItem < 2 then
            return false
        end
    end
    self:show()
    return true
end

PayMoreDialog.show = function(self)
    self:setVisible(true);
    self.super.show(self,self.mDialogAnim.showAnim);
    MallData.getInstance():setNeedMorePayDialog()
end

PayMoreDialog.dismiss = function(self)
--    self:setVisible(false);
    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
end

PayMoreDialog.dtor = function(self)
	self.mDialogAnim.stopAnim()
end

PayMoreDialog.initItems = function(self,payTypes)
    self.m_pmodesItem = {};--支付渠道列表
    delete(self.m_itemView)
    local w,h = self.m_pay_pmode_group:getSize();
    self.m_itemView = new(ScrollView,0,0,w,h,true);
    if not payTypes then return end

    for _,pmode in ipairs(PayUtil.pmodes) do
        if payTypes[tostring(pmode)] then
             for i,k in ipairs(PayDialog.ITEMS) do 
                if pmode == k.mode then
                    table.insert(self.m_pmodesItem,PayDialog.ITEMS[i]);
                    break
                end
            end
        end
    end


	local y_pos = 0;
	local x_pos = 0;
    self.m_btn = {}
    for index,item in ipairs(self.m_pmodesItem) do
	    self.m_btn[index] = new(PayMoreDialogItem,item);
        local w,h = self.m_btn[index]:getSize();
        self.m_btn[index]:setOnClick(self,self.payOrder);
        self.m_btn[index]:setPos(x_pos, y_pos)
        y_pos = y_pos + h
        self.m_itemView:addChild(self.m_btn[index]);
    end

--    self.m_cancel_btn = new(PayMoreDialogCancelItem);
--    local w,h = self.m_cancel_btn:getSize();
--	self.m_cancel_btn:setOnClick(self,self.dismiss);
--	self.m_cancel_btn:setPos(x_pos, y_pos);
--    y_pos = y_pos + h
--	self.m_cancel_btn:setVisible(true);
--	self.m_itemView:addChild(self.m_cancel_btn);

    self.m_pay_pmode_group:addChild(self.m_itemView);
    -- 增加空白
    y_pos = y_pos + 50
    
    local addH = 200
    local maxH = 704
    local h = math.min(maxH,addH+y_pos)
    self.m_pay_content_view:setSize(nil,h)
    self.m_itemView:setSize(nil,h-addH)
    self.m_pay_pmode_group:setSize(nil,h-addH)
end

PayMoreDialog.payOrder = function(self,mode)
	print_string("PayMoreDialog.payOrder in" .. mode);

	local goods = self.m_goods;

	if goods then
		PayUtil.getPayInstance(PayUtil.s_useType):createOrder(goods, mode,self.m_scene);
	end
    self:cancel();
end

PayMoreDialog.cancel = function(self)
	print_string("PayMoreDialog.cancel ");
	self:dismiss();
end

-----------------------------------------------------------------------------------------------------------------------------------------------
PayMoreDialogItem = class(Node);

PayMoreDialogItem.s_maxClickOffset = 10;

PayMoreDialogItem.ctor = function(self,data)
	self.m_data = data;

	local title_x,title_y = 93,30;
	local icon_x,icon_y = 21,12;

	if data.mode == PayDialog.pay_mode_union or data.mode == PayDialog.pay_mode_mo9 or data.mode == PayDialog.pay_mode_tenpay then
		icon_y = 20;
	end

	self.m_bg_btn = new(Button,"common/button/dialog_btn_2_normal.png","common/button/dialog_btn_2_press.png");
	self.m_bg_btn:setOnClick(self,self.onItemClick);
    self.m_bg_btn:setAlign(kAlignCenter);
    self.m_bg_btn:setSrollOnClick();

    self.m_node = new(Node);
    self.m_node:setAlign(kAlignCenter);
	self.m_bg_btn:addChild(self.m_node);

	self.m_icon = new(Image,data.icon);
    self.m_icon:setAlign(kAlignLeft);
	self.m_node:addChild(self.m_icon);

	self.m_title = new(Text, data.title, nil, nil, kAlignLeft,nil,40,240,230,210);
    self.m_title:setAlign(kAlignRight);
--    self.m_title:setPos(80);
	self.m_node:addChild(self.m_title);

    self.m_node:setSize(select(1,self.m_icon:getSize())+select(1,self.m_title:getSize()) + 10,
                        select(2,self.m_icon:getSize())+select(2,self.m_title:getSize()));

	self:addChild(self.m_bg_btn);
    local w,h = self.m_bg_btn:getSize();
	self:setSize(w,h+20);
    self:setFillParent(true,false);
end

PayMoreDialogItem.setOnClick = function(self, obj,func)
    self.m_onClickFunc = func;
	self.m_onClickObj = obj;
end

PayMoreDialogItem.onItemClick = function(self)
	if self.m_onClickFunc ~= nil then
        self.m_onClickFunc(self.m_onClickObj,self.m_data.mode);
    end	
end

-- 取消按钮

PayMoreDialogCancelItem = class(Node);

PayMoreDialogCancelItem.s_maxClickOffset = 10;

PayMoreDialogCancelItem.ctor = function(self)

	local title_x,title_y = 93,30;
	local icon_x,icon_y = 21,12;

	self.m_bg_btn = new(Button,"common/button/dialog_btn_6_normal.png","common/button/dialog_btn_6_press.png");
	self.m_bg_btn:setOnClick(self,self.onItemClick);
    self.m_bg_btn:setAlign(kAlignCenter);
    self.m_bg_btn:setSrollOnClick();

    self.m_node = new(Node);
    self.m_node:setAlign(kAlignCenter);
	self.m_bg_btn:addChild(self.m_node);


	self.m_title = new(Text,"取消", nil, nil, kTextAlignCenter,nil,40,240,230,210);
    self.m_title:setAlign(kAlignRight);
	self.m_node:addChild(self.m_title);

    self.m_node:setSize(select(1,self.m_title:getSize()),
                        select(2,self.m_title:getSize()));

	self:addChild(self.m_bg_btn);
    local w,h = self.m_bg_btn:getSize();
	self:setSize(w,h+20);
    self:setFillParent(true,false);
end

PayMoreDialogCancelItem.setOnClick = function(self, obj,func)
    self.m_onClickFunc = func;
	self.m_onClickObj = obj;
end

PayMoreDialogCancelItem.onItemClick = function(self)
	if self.m_onClickFunc ~= nil then
        self.m_onClickFunc(self.m_onClickObj);
    end	
end