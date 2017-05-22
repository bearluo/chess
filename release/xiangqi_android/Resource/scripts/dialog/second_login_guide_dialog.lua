--region NewFile_1.lua
--Author : FordFan
--Date   : 2015/8/24
--指引界面2
--endregion

require(VIEW_PATH .. "first_login_guide2_dialog");
require(BASE_PATH .. "chessDialogScene");
require("dialog/third_guide_dialog");

SecondLogGuideDialog = class(ChessDialogScene,false);

SecondLogGuideDialog.DEFAULT = "userinfo/women_head01.png";
SecondLogGuideDialog.DEFAULT_ANIM_TIME = 300; --单位毫秒 

SecondLogGuideDialog.ctor = function(self)
    super(self,first_login_guide2_dialog);

    --棋力部分
    self.m_bg = self.m_root:getChildByName("bg");
    self.icon_mask = self.m_bg:getChildByName("icon_bg"):getChildByName("icon_mask");
    self.m_close_btn = self.m_bg:getChildByName("close_btn");
    self.m_close_btn:setOnClick(self,self.dismiss)
    local score_txt_handler = self.m_bg:getChildByName("score_txt_handler");
    local user = UserInfo.getInstance()
    self.m_score_txt = new(RichText,string.format("积分:#c554628%d",user:getScore()), width, height, align, fontName, 36, 130, 100, 55, false)
    self.m_score_txt:setAlign(kAlignTop)
    score_txt_handler:addChild(self.m_score_txt)
    self.icon = new(Mask,UserInfo.DEFAULT_ICON[user:getIconType()] or SecondLogGuideDialog.DEFAULT,"common/background/head_mask_bg_150.png");
    self.icon:setAlign(kAlignCenter);
    self.icon:setSize(self.icon_mask:getSize());
    self.icon_mask:addChild(self.icon);
    self.level = self.m_bg:getChildByName("level");
    self.level:setFile( string.format("common/icon/big_level_%d.png",10-UserInfo.getInstance():getDanGradingLevel()))
    local tips_txt_handler = self.m_bg:getChildByName("tips_txt_handler");
    local tips_txt = new(RichText,"7天内前往#c64F532任务完成评测#n即可获得#c64F532双倍积分卡", width, height, align, fontName, 28, 245, 55, 50, false)
    tips_txt:setAlign(kAlignTop)
    tips_txt_handler:addChild(tips_txt)
    self:setNeedBackEvent(false)
end

SecondLogGuideDialog.dtor = function(self)
end

SecondLogGuideDialog.show = function(self)
    self.super.show(self,false);
    StatisticsManager.getInstance():onNewUserCountToPHP(StatisticsManager.NEW_USER_COUNT_LEVEL,UserInfo.getInstance():getIsFirstLogin())
end

SecondLogGuideDialog.dismiss = function(self)
    self:setVisible(false);
    self.super.dismiss(self,false);
end