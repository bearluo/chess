require("view/Android_800_480/by_email_retrieve_dialog_view");
require(BASE_PATH.."chessDialogScene")
ByEmailRetrieveDialog = class(ChessDialogScene,false);

ByEmailRetrieveDialog.ctor = function(self)
    super(self,by_email_retrieve_dialog_view);
	self.m_root_view = self.m_root;
    self.m_back_btn = self.m_root:getChildByName("bg"):getChildByName("back_btn");
    self.m_confirm_btn = self.m_root:getChildByName("bg"):getChildByName("confirm_btn");

    
    self.m_edit_email_num = self.m_root:getChildByName("bg"):getChildByName("edit_bg"):getChildByName("email");
    self.m_edit_email_num:setHintText("输入e-mail",165,145,120);


    self.m_back_btn:setOnClick(self,self.onBackBtnClick);
    self.m_confirm_btn:setOnClick(self,self.onConfirmBtnClick);
    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)
end

ByEmailRetrieveDialog.dtor = function(self)
	self.mDialogAnim.stopAnim()
    self.m_root_view = nil;
    delete(self.m_animTimer);
end

ByEmailRetrieveDialog.reset = function(self)
end

ByEmailRetrieveDialog.setParentDialog = function(self,dialog)
    self.m_parent_dialog = dialog;
end

ByEmailRetrieveDialog.onCancelBtnClick = function(self)
    self:dismiss();
end

ByEmailRetrieveDialog.onBackBtnClick = function(self)
    self:dismiss();
    if self.m_parent_dialog then
        self.m_parent_dialog:show();
    end
end

ByEmailRetrieveDialog.onConfirmBtnClick = function(self)
    local email = self.m_edit_email_num:getText();

   	if email and email ~= "" then
        local post_data = {};
        post_data.email = email;
        HttpModule.getInstance():execute(HttpModule.s_cmds.findPasswordByEmail,post_data,"发送中...");
	else
		local message = "e-mail输入有误！(检测是否存在空格)"
        ChessToastManager.getInstance():showSingle(message);
	end
end

ByEmailRetrieveDialog.onFindPasswordByEmailResponse = function(self,isSuccess,message)
    if HttpModule.explainPHPMessage(isSuccess,message,"发送失败!") then
        return ;
    end
    ChessToastManager.getInstance():show("邮件已发送!");
    self:dismiss();
end

ByEmailRetrieveDialog.isShowing = function(self)
	return self:getVisible();
end

ByEmailRetrieveDialog.show = function(self)
	print_string("ByEmailRetrieveDialog.show ... ");
	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
--    EventDispatcher.getInstance():register(Event.Call,self,self.onEventResponse);
    self:reset();
	self:setVisible(true);
    self.super.show(self,self.mDialogAnim.showAnim);
end


ByEmailRetrieveDialog.onHttpRequestsCallBack = function(self,command,...)
	Log.i("ByEmailRetrieveDialog.onHttpRequestsCallBack");
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self,...);
	end 
end

ByEmailRetrieveDialog.dismiss = function(self)
--    EventDispatcher.getInstance():unregister(Event.Call,self,self.onEventResponse);
    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpRequestsCallBack);

    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
--	self:setVisible(false);
end

ByEmailRetrieveDialog.dissmissDialogs = function(self)
	return true;
end


ByEmailRetrieveDialog.onEventResponse = function(self,cmd,flag,json_data)
    if not json_data then return end;
    
end



ByEmailRetrieveDialog.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.findPasswordByEmail] = ByEmailRetrieveDialog.onFindPasswordByEmailResponse;
};