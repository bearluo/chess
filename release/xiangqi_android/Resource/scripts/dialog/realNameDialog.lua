require(VIEW_PATH .. "real_name_dialog_view")

RealNameDialog = class(ChessDialogScene,false)

function RealNameDialog:ctor()
    super(self,real_name_dialog_view)
    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)
    self.mBg = self.m_root:getChildByName("bg")
    self.mBg:setEventTouch(self,function()end)
    self.mNameEdit  = self.mBg:getChildByName("info_bg"):getChildByName("name_view"):getChildByName("edit")
    self.mNumEdit   = self.mBg:getChildByName("info_bg"):getChildByName("num_view"):getChildByName("edit")
    self.mCancelBtn = self.mBg:getChildByName("cancel_btn")
    self.mSureBtn   = self.mBg:getChildByName("sure_btn")

    self.mNameEdit:setHintText("请输入您的真实姓名",165,145,125)
    self.mNumEdit:setHintText("请输入您的证件号码",165,145,125)

    self.mSureBtn:setOnClick(self,self.onSureBtnClick)
    self.mCancelBtn:setOnClick(self,self.dismiss)
    self:setShieldClick(self,self.dismiss)
end

function RealNameDialog:dtor()
    self.mDialogAnim.stopAnim()
end

function RealNameDialog:show()
    self.super.show(self,self.mDialogAnim.showAnim)
    self.mNameEdit:setText()
    self.mNumEdit:setText()
end

function RealNameDialog:onSureBtnClick()
    local name = self.mNameEdit:getText()
    local num  = self.mNumEdit:getText()
    local len = string.len(num)
    if len == 15 or len == 18 then
        self.mSend = true
        local params = {}
        params.param = {}
        params.param.type = 1
        params.param.name = name
        params.param.id_card = num
        HttpModule.getInstance():execute(HttpModule.s_cmds.UserRealNameAuth,params,"验证中...")
        self:dismiss()
    else
        ChessToastManager.getInstance():showSingle("请输入15位或18位号码")
    end 
end

function RealNameDialog:dismiss()
    self.super.dismiss(self,self.mDialogAnim.dismissAnim)
end
