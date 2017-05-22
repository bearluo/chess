require(VIEW_PATH .. "change_name_dialog_view");
require(BASE_PATH.."chessDialogScene")

ChangeNameDialog = class(ChessDialogScene,false)

function ChangeNameDialog:ctor()
    super(self,change_name_dialog_view)
    self.mBg   = self.m_root:getChildByName("bg")
    self.mEdit = self.mBg:getChildByName("content_view"):getChildByName("edit_bg"):getChildByName("edit")
    self.mEdit:setHintText("点击输入1-8个字符的昵称",130,95,55)
    self.mTipsView = self.mBg:getChildByName("tips_view")
    self.mTipsView:setVisible(false)
    self:setNeedMask(false)
    self.mBg:setEventTouch(self,function()end)
    self:setShieldClick(self,self.dismiss)
    self.mBg:getChildByName("cancel_btn"):setOnClick(self,self.dismiss)
    self.mBg:getChildByName("confirm_btn"):setOnClick(self,self.onConfirmClick)
end

function ChangeNameDialog:setTipsNum(num,visible)
    num = tonumber(num) or 0
    self.mTipsView:setVisible(visible or false)
    self.mTipsView:getChildByName("bccoin"):setText(num)
end


function ChangeNameDialog:setConfirmCallBack(obj,func)
    self.mConfirmListener = {}
    self.mConfirmListener.obj = obj
    self.mConfirmListener.func = func
end

function ChangeNameDialog:onConfirmClick()
    local str = self.mEdit:getText()
    if type(str) ~= "string" or str == "" or str == UserInfo.getInstance():getName() then 
        ChessToastManager.getInstance():show("输入不合法")
        return 
    end

    if type(self.mConfirmListener.func) == "function" then
        self.mConfirmListener.func(self.mConfirmListener.obj,str)
    end
    self:dismiss()
end