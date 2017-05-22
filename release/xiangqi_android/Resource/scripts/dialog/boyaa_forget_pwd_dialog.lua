require("view/Android_800_480/boyaa_forget_pwd_dialog_view");
require(BASE_PATH.."chessDialogScene")
BoyaaForGetPwdDialog = class(ChessDialogScene,false);

BoyaaForGetPwdDialog.ctor = function(self)
    super(self,boyaa_forget_pwd_dialog_view);
	self.m_root_view = self.m_root;
    self.m_back_btn = self.m_root:getChildByName("bg"):getChildByName("back_btn");
    self.m_by_phone_btn = self.m_root:getChildByName("bg"):getChildByName("by_phone_btn");
    self.m_by_email_btn = self.m_root:getChildByName("bg"):getChildByName("by_email_btn");

    self.m_back_btn:setOnClick(self,self.onBackBtnClick);
    self.m_by_phone_btn:setOnClick(self,self.onByPhoneBtnClick);
    self.m_by_email_btn:setOnClick(self,self.onByEmailBtnClick);
    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)
end

BoyaaForGetPwdDialog.dtor = function(self)
    self.mDialogAnim.stopAnim()
	self.m_root_view = nil;
    delete(self.m_phone_dialog);
end

BoyaaForGetPwdDialog.setParentDialog = function(self,dialog)
    self.m_parent_dialog = dialog;
end

BoyaaForGetPwdDialog.onCancelBtnClick = function(self)
    self:dismiss();
end

BoyaaForGetPwdDialog.onBackBtnClick = function(self)
    self:dismiss();
    if self.m_parent_dialog then
        self.m_parent_dialog:show(2);
    end
end
require("dialog/by_email_retrieve_dialog");
require("dialog/by_phone_retrieve_dialog");

BoyaaForGetPwdDialog.onByPhoneBtnClick = function(self)
    delete(self.m_phone_dialog);
    self.m_phone_dialog = new(ByPhoneRetrieveDialog);
    self.m_phone_dialog:setParentDialog(self);
    self.m_phone_dialog:show();
    self:dismiss();
end

BoyaaForGetPwdDialog.onByEmailBtnClick = function(self)
    delete(self.m_email_dialog);
    self.m_email_dialog = new(ByEmailRetrieveDialog);
    self.m_email_dialog:setParentDialog(self);
    self.m_email_dialog:show();
    self:dismiss();
end

BoyaaForGetPwdDialog.isShowing = function(self)
	return self:getVisible();
end

BoyaaForGetPwdDialog.show = function(self)
	print_string("BoyaaForGetPwdDialog.show ... ");
	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
--    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
--    EventDispatcher.getInstance():register(Event.Call,self,self.onEventResponse);
	self:setVisible(true);
    self.super.show(self,self.mDialogAnim.showAnim);
end


BoyaaForGetPwdDialog.onHttpRequestsCallBack = function(self,command,...)
	Log.i("BoyaaForGetPwdDialog.onHttpRequestsCallBack");
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self,...);
	end 
end

BoyaaForGetPwdDialog.dismiss = function(self)
--    EventDispatcher.getInstance():unregister(Event.Call,self,self.onEventResponse);
--    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpRequestsCallBack);

    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
--	self:setVisible(false);
end

BoyaaForGetPwdDialog.dissmissDialogs = function(self)
	return true;
end


BoyaaForGetPwdDialog.onEventResponse = function(self,cmd,flag,json_data)
    if not json_data then return end;
    
end



BoyaaForGetPwdDialog.s_httpRequestsCallBackFuncMap  = {
};