--region NewFile_1.lua
--Author : FordFan
--Date   : 2015/8/24
--第一次登陆引导界面1
--endregion

require(VIEW_PATH .. "first_login_guide_dialog");
require(BASE_PATH .. "chessDialogScene");
require("core/drawing")
require("ui/viewPager");
require("ui/adapter");

FirstLogGuideDialog = class(ChessDialogScene,false);

FirstLogGuideDialog.DEFAULT = "userinfo/women_head01.png";

FirstLogGuideDialog.ctor = function(self)
    super(self,first_login_guide_dialog);

    self.m_back_view = self.m_root:getChildByName("back_view");

    self.m_icon_mask = self.m_back_view:getChildByName("icon_bg"):getChildByName("icon_mask");
    self.m_back_img = self.m_back_view:getChildByName("Image1");
    
    self.m_back_img:setTransparency(0.65);    
    --第一次登陆头像
    self.icon = new(Mask,FirstLogGuideDialog.DEFAULT,"common/background/head_mask_bg_150.png");
    self.icon:setAlign(kAlignCenter);
    self.icon:setSize(self.m_icon_mask:getSize());
    self.m_icon_mask:addChild(self.icon);

--    self.m_anim_img = self.m_back_view:getChildByName("anim_img");
--    self.m_anim_img:addPropRotate(1,kAnimRepeat,6000,0,0,180,kCenterDrawing);

    self.m_bg = self.m_back_view:getChildByName("bg");
    self.m_receive = self.m_back_view:getChildByName("close_btn");

    self.m_receive:setOnClick(self,self.toClose);
	self:setVisible(false);
    self:setLevel(1);

    self:initViewPaper();        
end

FirstLogGuideDialog.dtor = function(self)
    
end

FirstLogGuideDialog.show = function(self)
    print_string("FirstLogGuideDialog.show ... ");

    kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
    self:setVisible(true);
    self.super.show(self,false);
--    self.m_anim_img:addPropRotate(1,kAnimRepeat,2,0,0,360,kCenterDrawing);
end

FirstLogGuideDialog.isShowing = function(self)
	return self:getVisible();
end

FirstLogGuideDialog.dismiss = function(self)
--    self.m_anim_img:removeProp(1);
    self:setVisible(false);
    self.super.dismiss(self);
end

FirstLogGuideDialog.toClose = function(self)
    self:dismiss();
    require("dialog/second_login_guide_dialog");
    -- 弹出指引弹窗2
    if not self.m_secondLogGuideDialog then
        self.m_secondLogGuideDialog = new(SecondLogGuideDialog);
        self.m_secondLogGuideDialog:show();
    end
end

FirstLogGuideDialog.initViewPaper = function(self)
    local reward_tab = UserInfo.getInstance():getPropInfo();
    local tab = {}; --local tab = {{typeId = 2,num = 2}};
    if not reward_tab or #reward_tab == 0 then
        return;
    end

    for i,v in pairs(reward_tab) do
        local typeData = {};
        typeData.typeId = tonumber(v.propType);
        typeData.num = tonumber(v.propNum);     
        table.insert(tab,typeData);
    end
    --w 145 h 200
    local view_width = #tab * 145;
    self.m_reward_view = new(ListView,0,135,view_width,200);
    self.m_reward_view:setAlign(kAlignCenter);
    self.m_reward_view:setDirection(kHorizontal);
    self.m_back_view:addChild(self.m_reward_view);
    if #tab > 0 then
        self.m_adapter = new(CacheAdapter,RewardItem,tab);
        self.m_reward_view:setAdapter(self.m_adapter);
    end

end

--------------------private node --------------------
RewardItem = class(Node);
    
RewardItem.ctor = function(self,data)
    if data.typeId == 1 or data.typeId == 5 then 
        return;
    end
    
    self.data = data;
    self:setSize(145,200);
    self.item_bg = new(Image,"register_guide/item_bg.png");
    self.item_bg:setSize(0,-17);
    self.item_bg:setAlign(kAlignCenter);
    self:addChild(self.item_bg);

    local str = "";
    if data.typeId == 2 then   -- 2..悔棋
        self.m_reward_icon = new(Image,"common/icon/undo_icon.png");
        str = "悔棋";
    elseif data.typeId == 3 then   -- 3..提示
        self.m_reward_icon = new(Image,"common/icon/tips_icon.png");
        str = "提示";
--    elseif data.typeId == 9 then   -- 9..金币
--        self.m_reward_icon = new(Image,"register_guide/coin.png");
--        str = "金币";
--    elseif  data.typeId == 0 then  -- 0..积分
--        self.m_reward_icon = new(Image,"register_guide/integration.png");
--        str = "积分";
    elseif data.typeId == 4 then -- 4..起死回生
        self.m_reward_icon = new(Image,"common/icon/relive_icon.png");
        str = "重生";
    end

    self.m_reward_icon:setPos(-4,-1);
    self.m_reward_icon:setAlign(kAlignCenter);
    self.item_bg:addChild(self.m_reward_icon);
--    self.m_content_text = new(Text,"×",50,26,kAlignBottom,nil,20,250,230,180);
--    self.m_content_text:setPos(5,15);
--    self.m_content_text:setAlign(kAlignBottom);
    self.num_text = new(Text,str .."×" .. data.num,200,150,nil,nil,28,80,80,80);
    self.num_text:setPos(38,-48);
    self.num_text:setAlign(kAlignBottom);

--    self.m_bg:addChild(self.m_content_text);
    self:addChild(self.num_text);

end

RewardItem.dtor = function(self)
    
end