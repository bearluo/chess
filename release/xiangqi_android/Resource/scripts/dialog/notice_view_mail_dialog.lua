require(VIEW_PATH .. "notice_view_mail_dialog_view");
require(BASE_PATH.."chessDialogScene")
NoticeViewMailDialog = class(ChessDialogScene,false);

function NoticeViewMailDialog:ctor()
    super(self,notice_view_mail_dialog_view);
    self.anim_dlg = AnimDialogFactory.createNormalAnim(self)
    self.bg = self.m_root:getChildByName("bg");
    self.title = self.bg:getChildByName("title");
    self.contentView = self.bg:getChildByName("content_view");
    self.btn1 = self.bg:getChildByName("btn_1");
    self.btn2 = self.bg:getChildByName("btn_2");
    self.btn3 = self.bg:getChildByName("btn_3");
    self.close_btn = self.bg:getChildByName("close_btn");
    
    self.btn1:setOnClick(self,self.dismiss);
    self.btn2:setOnClick(self,self.onClick);
    self.btn3:setOnClick(self,self.dismiss);
    self.close_btn:setOnClick(self,self.dismiss);
end

function NoticeViewMailDialog:dtor()
    
end

function NoticeViewMailDialog:show(params)
    if not params or type(params) ~= "table" then return end
    self.params = params;
    self:createRichText(params.mail_text);
    self:initByModelType(params);
    self.title:setText(params.mail_title);
    self.super.show(self, self.anim_dlg.showAnim)
    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
end

function NoticeViewMailDialog:dismiss()
    self.super.dismiss(self, self.anim_dlg.dismissAnim)
    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpRequestsCallBack);
end

function NoticeViewMailDialog:onClick()
    local modelType = self.params.tpl_type or kMailTplDefault;
    if modelType == kMailTplDefault then
        self:dismiss();
    elseif modelType == kMailTplAction then
        self:action(self.params.id)
    elseif modelType == kMailTplJump then
        self:jump(self.params.jump_scene)
        self:dismiss();
    elseif modelType == kMailTpModifyMnick then -- 修改用户昵称特殊处理
        self:jump(self.params.jump_scene)
        self:dismiss();
    end
end


function NoticeViewMailDialog:createRichText(str)
    delete(self.richText);
    local w,h = self.contentView:getSize();
    self.richText = new(RichText,str, w, h, kAlignTopLeft, "", 28, 80, 80, 80, true,5);
    self.contentView:addChild(self.richText);
end
--kMailTplDefault = '1'; --消息模板。只有关闭
--kMailTplAction = '2'; --有动作。动作按钮的文本由action_text指定
--kMailTplJump = '3'; --指定跳转
function NoticeViewMailDialog:initByModelType(params)
    local modelType = params.tpl_type or kMailTplDefault;
    local isOperate = tonumber(params.is_operate) or 0;
    self.btn1:setVisible(false);
    self.btn2:setVisible(false);
    self.btn2:setPickable(true);
    self.btn2:setGray(false);
    self.btn3:setVisible(false);

    if modelType == kMailTplDefault then
        self.btn3:setVisible(true);
    elseif modelType == kMailTplAction then
--        self.btn1:setVisible(true);
        self.btn2:setVisible(true);
        self.btn2:getChildByName("btn_text"):setText(params.button_text or "知道了");
        if isOperate == 1 then
            self.btn2:setPickable(false);
            self.btn2:setGray(true);
        end
    elseif modelType == kMailTplJump then
--        self.btn1:setVisible(true);
        self.btn2:setVisible(true);
        self.btn2:getChildByName("btn_text"):setText(params.button_text or "知道了"); 
    elseif modelType == kMailTpModifyMnick then -- 修改用户昵称邮件跳转
        self.btn2:setVisible(true);
        self.btn2:getChildByName("btn_text"):setText(params.button_text or "知道了");
    end
end



function NoticeViewMailDialog:jump(scene)
    scene = tonumber(scene);
    if StatesMap[scene] then
        if tonumber(scene) == States.Friends then
            TaskScene.s_showRelationshipDialog()
            return
        elseif tonumber(scene) == States.Replay then
            TaskScene.s_showReplayDialog()
            return
        end
        StateMachine.getInstance():pushState(scene,StateMachine.STYPE_CUSTOM_WAIT);
    end
end

function NoticeViewMailDialog:action(mailId)
    local params = {};
    params.mail_id = mailId;
    HttpModule.getInstance():execute(HttpModule.s_cmds.UserMailAction,params);
end


function NoticeViewMailDialog:onHttpRequestsCallBack(command,...)
	Log.i("NoticeViewMailDialog.onHttpRequestsCallBack");
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self,...);
	end 
end


function NoticeViewMailDialog:onUserMailAction(isSuccess,message)
    if HttpModule.explainPHPMessage(isSuccess,message,"操作失败") then
        return ;
    end

    if message.data.mail_id:get_value() == self.params.id then
        self:dismiss();
        self.params.is_operate = 1;
    end
end


NoticeViewMailDialog.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.UserMailAction] = NoticeViewMailDialog.onUserMailAction;
};

