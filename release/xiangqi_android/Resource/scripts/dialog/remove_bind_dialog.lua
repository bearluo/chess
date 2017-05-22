require(VIEW_PATH .. "remove_bind_dialog");
require("gameBase/gameLayer");

RemoveBindDialog = class(GameLayer,false);

RemoveBindDialog.s_dialogLayer = nil;

function RemoveBindDialog:ctor()
    super(self,remove_bind_dialog);
    if not RemoveBindDialog.s_dialogLayer then
        RemoveBindDialog.s_dialogLayer = new(Node);
        RemoveBindDialog.s_dialogLayer:addToRoot();
        RemoveBindDialog.s_dialogLayer:setLevel(1);     
        RemoveBindDialog.s_dialogLayer:setFillParent(true,true);
    end
    RemoveBindDialog.s_dialogLayer:addChild(self);
    self:setFillParent(true,true);
    self.m_root:setLevel(1);
    self.m_root_view = self.m_root;
    self.m_needBackEvent = true;          --是否需要监听回退事件
    self.is_dismissing = false;
    self:initView();
    self:setVisible(false);
end

function RemoveBindDialog:dtor()
    
end

function RemoveBindDialog:isShowing()
    return self:getVisible();
end

function RemoveBindDialog:show()
    self.is_dismissing = false;
    self:setVisible(true);
    if not self.m_dialog_bg:checkAddProp(1) then
        self.m_dialog_bg:removeProp(1);
    end
    if not self.m_root:checkAddProp(0) then
        self.m_root:removeProp(0);
    end
    local anim = self.m_dialog_bg:addPropScaleWithEasing(1,kAnimNormal,200,0,"easeInSine","easeInSine",0.9,0.2,kCenterDrawing);
    if anim then
	    anim:setEvent(nil,function()
            if not self.m_dialog_bg:checkAddProp(1) then
                self.m_dialog_bg:removeProp(1);
            end
	    end);
    end
end

function RemoveBindDialog:dismiss()
    --防止多次点击显示多次动画
    if self.is_dismissing then
        return;
    end
    if not self.m_dialog_bg:checkAddProp(1) then
        self.m_dialog_bg:removeProp(1);
    end
    if not self.m_root:checkAddProp(0) then
        self.m_root:removeProp(0);
    end
    local anim = self.m_dialog_bg:addPropScaleWithEasing(1,kAnimNormal,100,0,"easeOutSine","easeOutSine",1.1,-0.2,kCenterDrawing);
    self.m_root:addPropTransparency(0, kAnimNormal, 100, 1, 1, 0.5);
    if anim then
	    anim:setEvent(nil,function()
            if not self.m_dialog_bg:checkAddProp(1) then
                self.m_dialog_bg:removeProp(1);
            end
            if not self.m_root:checkAddProp(0) then
                self.m_root:removeProp(0);
            end
            self:setVisible(false);
	    end);
    end
end

function RemoveBindDialog:initView()
    --半透明背景
    self.m_black_bg = self.m_root_view:getChildByName("blank_bg");
    self:setEventTouch(self,self.setShieldClick);

    self.m_dialog_bg = self.m_root_view:getChildByName("dialog_bg");
    self.m_dialog_bg:setEventTouch(self.m_dialog_bg,function() end);
    --提示
    self.m_tips = self.m_dialog_bg:getChildByName("bind_tips");
    --更换绑定按钮
    self.m_rebind_btn = self.m_dialog_bg:getChildByName("Button1");
    self.m_rebind_btn:setOnClick(self,self.rebind);
    --确定按钮
    self.m_confirm_btn = self.m_dialog_bg:getChildByName("Button2");  
    self.m_confirm_btn:setOnClick(self,self.confirm);
    --小提示
    self.m_small_tips = self.m_dialog_bg:getChildByName("text");

    self.m_cancel_btn = self.m_dialog_bg:getChildByName("Button3"); 
    self.m_cancel_btn:setOnClick(self,self.confirm);
end

function RemoveBindDialog:rebind()
    self:dismiss();
    --重新绑定
    if self.m_callBackFunc and self.m_callBackObj then
        self.m_callBackFunc(self.m_callBackObj);
    end
end

function RemoveBindDialog:confirm()
     self:dismiss();
end

function RemoveBindDialog:setHandler(handler)
    self.m_handler = handler;
end

function RemoveBindDialog:setRebindCallBack(obj,func,...)
    self.m_callBackObj = obj;
    self.m_callBackFunc = func;
end

function RemoveBindDialog:setAccountType(accountType)
    if not accountType then return end
    self.m_accountType = accountType;
    self:refreshTips();
end

function RemoveBindDialog:refreshTips()
    local msgType = "手机";
    if self.m_accountType == 1 or self.m_accountType == 201 then
        self.m_small_tips:setVisible(true);
        msgType = "手机";
        self:resetBtnVisible(true);
    elseif self.m_accountType == 3 then
        self.m_small_tips:setVisible(false);
        msgType = "微信";
        self:resetBtnVisible(false);
    elseif self.m_accountType == 10 then
        self.m_small_tips:setVisible(false);
        msgType = "微博";
        self:resetBtnVisible(false);
    end
    local tips = "本账号已经成功绑定" .. msgType .. ",无需重新绑定";
    self.m_tips:setText(tips);
end

function RemoveBindDialog:resetBtnVisible(ret)
    self.m_rebind_btn:setVisible(ret);
    self.m_confirm_btn:setVisible(ret);
    self.m_cancel_btn:setVisible(not ret);
end

function RemoveBindDialog:setShieldClick(finger_action, x, y, drawing_id_first, drawing_id_current)
    Log.i("RemoveBindDialog.setShieldClick");
    if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
        if self:getVisible() then
            self:dismiss();
        end
    end
end