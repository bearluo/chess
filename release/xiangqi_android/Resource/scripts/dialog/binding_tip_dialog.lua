--region NewFile_1.lua
--Author : FordFan
--Date   : 2015/8/26
--绑定账号提示弹窗
--endregion

require(VIEW_PATH .. "binding_tip_dialog");
require(BASE_PATH .. "chessDialogScene");

BindingTipDialog = class(ChessDialogScene,false);

BindingTipDialog.ctor = function(self)
    super(self,binding_tip_dialog);

    self.m_bg_view = self.m_root:getChildByName("bg");
    self.m_later_remind_btn = self.m_bg_view:getChildByName("later_remind_btn");
    self.m_bind_btn = self.m_bg_view:getChildByName("bind_btn");
    self.m_close_btn = self.m_bg_view:getChildByName("close_btn");

    self.m_later_remind_btn:setOnClick(self,self.toClose);
    self.m_close_btn:setOnClick(self,self.toClose);
    self.m_bind_btn:setOnClick(self,self.toBind);

	self:setVisible(false);
    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)
end

BindingTipDialog.dtor = function(self)
    self.mDialogAnim.stopAnim()
end

BindingTipDialog.show = function(self)
    print_string("BindingTipDialog.show ... ");

    kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
    local showTimes = GameCacheData.getInstance():getInt(GameCacheData.SHOW_BINDING_TIP_TIMES,0);

    if showTimes == 0 then
        GameCacheData.getInstance():saveInt(GameCacheData.SHOW_BINDING_TIP_TIMES,1);
    end

    self:setVisible(true);
    self.super.show(self,self.mDialogAnim.showAnim);
end

BindingTipDialog.isShowing = function(self)
	return self:getVisible();
end

BindingTipDialog.dismiss = function(self)
    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
end

BindingTipDialog.toClose = function(self)
    self:dismiss();
end

require("dialog/bangdin_dialog");
BindingTipDialog.toBind = function(self)
    self:dismiss();
    self.bangdin = new(BangDinDialog);
    self.bangdin:show();
end