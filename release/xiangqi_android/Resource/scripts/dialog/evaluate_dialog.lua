require(VIEW_PATH .. "evaluate_dialog")

-- 评价弹窗
EvaluateDialog = class(ChessDialogScene, false)

EvaluateDialog.ctor = function( self, datas)
	super(self, evaluate_dialog)
	self.anim_dlg = AnimDialogFactory.createNormalAnim(self)
	self.datas = datas
	self:initView()
end

EvaluateDialog.dtor = function( self )
	self.anim_dlg:stopAnim()
end

EvaluateDialog.initView = function(self)
    self.m_root_view = self.m_root;
    self.m_dialog_bg = self.m_root_view:getChildByName("bg");
    -- btns
    self.m_suggest_btn = self.m_dialog_bg:getChildByName("sug_btn");
    self.m_suggest_btn:setOnClick(self, self.onSuggestBtnClick);
    self.m_evaluate_btn = self.m_dialog_bg:getChildByName("eva_btn");
    self.m_evaluate_btn:setOnClick(self, self.onEvaluateBtnClick);
    self.m_close_btn = self.m_dialog_bg:getChildByName("cls_btn");
    self.m_close_btn:setOnClick(self, self.dismiss);
end;

EvaluateDialog.show = function( self )
	self.super.show(self, self.anim_dlg.showAnim)
end

EvaluateDialog.dismiss = function( self )
	self.super.dismiss(self, self.anim_dlg.dismissAnim)
end

EvaluateDialog.onSuggestBtnClick = function( self )
    self:dismiss();
	StateMachine.getInstance():pushState(States.Feedback,StateMachine.STYPE_CUSTOM_WAIT);
end

EvaluateDialog.onEvaluateBtnClick = function( self )
    self:dismiss();
    call_native(kIosAppStoreEvaluate);
end