-- adapter.lua
-- Author: jsonPeng
-- Date:   217,4,1
-- Last modification : 217,4,1
-- Description: 回归奖励弹窗
require(VIEW_PATH .. "comeback_reward_dialog");
require(BASE_PATH.."chessDialogScene");
require("animation/diceAccountDropMoney");
ComeBackRewardDialog = class(ChessDialogScene,false);

ComeBackRewardDialog.ctor = function(self)
    super(self,comeback_reward_dialog);
    self.m_root_view = self.m_root;
    self.m_close_btn = self.m_root_view : getChildByName("closeBtn");
    self.goldenNumText = self.m_close_btn : getChildByName("GoldenNum");
--    self.bgimage = self.m_close_btn : getChildByName("bg");
    self:setVisible(false);
--    self.bgimage:setFillParent(true,true);
    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self);
    self:setShieldClick(self,self.dismiss);
    self:setLevel(5);
end


ComeBackRewardDialog.dtor = function(self)
    self.m_root_view = nil;
    self.mDialogAnim.stopAnim();
end


ComeBackRewardDialog.setGoldenNumTex = function(self ,comebackrewardText)
    if self.goldenNumText then 
        self.mGetMoney = tonumber(comebackrewardText) or 0
        self.goldenNumText:setText(comebackrewardText.."金币");
    end
    
end

ComeBackRewardDialog.show = function(self)
    self:setVisible(true,self.mDialogAnim.showAnim);
    --播放金币掉落动画
    DiceAccountDropMoney.play(50);
    --显示tip：获得多少金币
    ChessToastManager.getInstance():showSingle("获得"..self.mGetMoney or 0 .."金币",1500);
end

ComeBackRewardDialog.dismiss = function(self)
    self.super.dismiss(self, self.mDialogAnim.dismissAnim);
end