--region NewFile_1.lua
--Author : FordFan
--Date   : 2015/8/26
-- 添加头像账号引导弹窗
--endregion

require(VIEW_PATH .. "modify_info_dialog");
require(BASE_PATH .. "chessDialogScene");

ModifyInfoDialog = class(ChessDialogScene,false);

ModifyInfoDialog.ctor = function(self)
    super(self,modify_info_dialog);

    self.m_bg_view = self.m_root:getChildByName("bg");
    self.m_bg_view:setEventTouch(self.m_bg_view,function() end);

    self.m_cancel_append_btn = self.m_bg_view:getChildByName("later_append_btn");
    self.m_append_info_btn = self.m_bg_view:getChildByName("append_info_btn");
    self.m_close_btn = self.m_bg_view:getChildByName("close_btn");

    self.m_cancel_append_btn:setOnClick(self,self.toClose);
    self.m_append_info_btn:setOnClick(self,self.toRevise);
    self.m_close_btn:setOnClick(self,self.toClose);
    self:setShieldClick(self,self.toClose);

	self:setVisible(false);
    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)
end

ModifyInfoDialog.dtor = function(self)
    self.mDialogAnim.stopAnim()
end

ModifyInfoDialog.show = function(self)
    print_string("AddHeadIconDialog.show ... ");

    kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
    GameCacheData.getInstance():saveInt(GameCacheData.SHOW_MODIFY_TIP_TIMES,1);   
    self:setVisible(true);
    self.super.show(self,self.mDialogAnim.showAnim);
end

ModifyInfoDialog.isShowing = function(self)
	return self:getVisible();
end

ModifyInfoDialog.dismiss = function(self)
    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
end

ModifyInfoDialog.toClose = function(self)
    self:dismiss();
end

ModifyInfoDialog.toRevise = function(self)
    self:dismiss();
    StateMachine.getInstance():pushState(States.ownModel,StateMachine.STYPE_CUSTOM_WAIT);
end