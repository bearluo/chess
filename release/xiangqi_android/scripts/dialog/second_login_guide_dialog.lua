--region NewFile_1.lua
--Author : FordFan
--Date   : 2015/8/24
--指引界面2
--endregion

require(VIEW_PATH .. "first_login_guide2_dialog");
require(BASE_PATH .. "chessDialogScene");

SecondLogGuideDialog = class(ChessDialogScene,false);

SecondLogGuideDialog.DEFAULT = "userinfo/women_head01.png";
SecondLogGuideDialog.DEFAULT_ANIM_TIME = 300; --单位毫秒 

SecondLogGuideDialog.ctor = function(self)
    super(self,first_login_guide2_dialog);

    --棋力部分
    self.m_bg = self.m_root:getChildByName("bg");
    self.icon_mask = self.m_bg:getChildByName("icon_bg"):getChildByName("icon_mask");
    self.icon = new(Mask,SecondLogGuideDialog.DEFAULT,"common/background/head_mask_bg_150.png");
    self.icon:setAlign(kAlignCenter);
    self.icon:setSize(self.icon_mask:getSize());
    self.icon_mask:addChild(self.icon);
    self.m_close_btn = self.m_bg:getChildByName("close_btn");
    self.m_close_btn:setOnClick(self,self.showGuide);
    local str1 = "棋力等级评测对照国家象棋棋力评测系统，每次会匹配和你棋力相当的对手与你对局，";
    local str = str1.."在每个级别中净赢同等级别的对手会晋级。此等级评测系统评测出来的棋力等级，具有极高的权威性。";
    self.m_text_view = new(RichText,str,550,220,kAlignLeft,nil,27,80,80,80,true,15);
    self.m_text_view:setPos(0,120);
    self.m_text_view:setAlign(kAlignCenter);
    self.m_bg:addChild(self.m_text_view);

    --指引部分
    self.m_black_bg = self.m_root:getChildByName("black_bg");
    self.m_black_bg:setVisible(false);

    self:setShieldClick(self,self.onViewClick);
	self:setVisible(false);
end

SecondLogGuideDialog.dtor = function(self)
    self.m_thirdLogGuideDialog = nil;
end

SecondLogGuideDialog.show = function(self)
    print_string("SecondLogGuideDialog.show ... ");

    kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
    self:setVisible(true);
    self.super.show(self,false);
end

SecondLogGuideDialog.isShowing = function(self)
	return self:getVisible();
end

SecondLogGuideDialog.dismiss = function(self)
    self:setVisible(false);
    self.super.dismiss(self,false);
end

SecondLogGuideDialog.showGuide = function(self)
    
    self:removeViewProp();
    local anim_hide = self.m_bg:addPropTransparency(1,kAnimNormal,SecondLogGuideDialog.DEFAULT_ANIM_TIME,-1,1,0);
    anim_hide:setEvent(self,function()
        self.m_bg:setVisible(false);
        self.m_black_bg:setVisible(true);
        self.m_bg:removeProp(1);
    end);

    local anim_show = self.m_black_bg:addPropTransparency(1,kAnimNormal,SecondLogGuideDialog.DEFAULT_ANIM_TIME,(SecondLogGuideDialog.DEFAULT_ANIM_TIME-50),0,1);
    anim_show:setEvent(self,function()
        self.m_black_bg:removeProp(1);
    end);

    self.anim_time = new(AnimInt,kAnimNormal,0,1,4000,SecondLogGuideDialog.DEFAULT_ANIM_TIME); 
    if self.anim_time then
        self.anim_time:setEvent(self,function()
            self:showNextGuide();
        end);
    end
end

function SecondLogGuideDialog:removeViewProp()
    if not self.m_bg:checkAddProp(1) then
        self.m_bg:removeProp(1);
    end
    if not self.m_black_bg:checkAddProp(1) then
        self.m_black_bg:removeProp(1);
    end
end

function SecondLogGuideDialog:showNextGuide()
    self:dismiss();
    require("dialog/third_guide_dialog");
    -- 弹出指引弹窗3
    if not self.m_thirdLogGuideDialog then
        self.m_thirdLogGuideDialog = new(ThirdGuideDialog);
        self.m_thirdLogGuideDialog:show();
    end
end

function SecondLogGuideDialog:onViewClick()
    if self.anim_time then
        delete(self.anim_time);
        self.anim_time = nil;
    end
    self:showNextGuide();
end