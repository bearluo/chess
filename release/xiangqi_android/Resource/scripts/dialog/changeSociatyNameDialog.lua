require(VIEW_PATH .. "change_sociaty_name_dialog_view");
require(BASE_PATH.."chessDialogScene")

ChangeSociatyNameDialog = class(ChessDialogScene,false)

function ChangeSociatyNameDialog:ctor()
    super(self,change_sociaty_name_dialog_view)
    self.mBg   = self.m_root:getChildByName("bg")
    self.mEdit = self.mBg:getChildByName("content_view"):getChildByName("edit_bg"):getChildByName("edit")
    self.mEdit:setHintText("点击输入10个字符内的名称",130,95,55)
    self.mTipsView = self.mBg:getChildByName("tips_view")
    self.mTipsView:setVisible(false)
    self:setNeedMask(false)
    self:setMaskDialog(true)
    self.mBg:setEventTouch(self,function()end)
    self:setShieldClick(self,self.dismiss)
    self.mBg:getChildByName("cancel_btn"):setOnClick(self,self.dismiss)
    self.mBg:getChildByName("confirm_btn"):setOnClick(self,self.onConfirmClick)
end

function ChangeSociatyNameDialog:setTipsNum(num,visible)
    num = tonumber(num) or 0
    self.mTipsView:setVisible(visible or false)
    self.mTipsView:getChildByName("bccoin"):setText(num)
end


function ChangeSociatyNameDialog:setConfirmCallBack(obj,func)
    self.mConfirmListener = {}
    self.mConfirmListener.obj = obj
    self.mConfirmListener.func = func
end

function ChangeSociatyNameDialog:onConfirmClick()
    local str = self.mEdit:getText()
    local data = SociatyModuleData.getInstance():getSociatyData()
    str = ToolKit.delStrBlank(str)
    local len = ToolKit.utfstrlen(str)
    if len < 1 or len > 8 then
        ChessToastManager.getInstance():showSingle("公会名字不合法，请重新输入");
        return
    end
    if type(str) ~= "string" or str == "" or str == data.name then 
        ChessToastManager.getInstance():show("输入不合法")
        return 
    end

    if UserInfo.getInstance():getModifyGuildMnickCost() > UserInfo.getInstance():getBccoin() then
        local goods = MallData.getInstance():getGoodsByMoreBccoin(UserInfo.getInstance():getModifyGuildMnickCost())
        ChessToastManager.getInstance():show("元宝不足")
        if not goods then return end
        local payInterface = PayUtil.getPayInstance(PayUtil.s_defaultType);
	    payInterface:buy(goods);
        return
    end

    if type(self.mConfirmListener.func) == "function" then
        self.mConfirmListener.func(self.mConfirmListener.obj,str)
    end
    self:dismiss()
end