require(BASE_PATH .. "chessDialogScene");
require(VIEW_PATH .. "good_info_dialog")

GoodInfoDialog = class(ChessDialogScene,false);

function GoodInfoDialog.ctor(self)
    super(self,good_info_dialog);
    self.content_img = self.m_root:getChildByName("content_img");
    self.content_img:setUrlImageDownloadBack(self,self.onContentImgDown)
    self.close_btn = self.m_root:getChildByName("close_btn");
    self.sure_btn = self.m_root:getChildByName("sure_btn");
    self.qiPaiView = self.m_root:getChildByName("qiPaiView");
    self.qiPaiView:setVisible(false)
    self.close_btn:setOnClick(self,self.dismiss)
    self.sure_btn:setOnClick(self,self.onSureBtnClick)
    self.close_btn:setVisible(false)
    self:setShieldClick(self,self.dismiss)
end

function GoodInfoDialog.dtor(self)
end


function GoodInfoDialog.show(self)
    self.super.show(self);
end

function GoodInfoDialog.dismiss(self)
    self.super.dismiss(self);
end

function GoodInfoDialog:setUrlImage(url)
    self.content_img:setSize(171,48)
    self.content_img:setUrlImage(url,"animation/loading/loading_4.png",Image.s_url_type_by_url)
end

function GoodInfoDialog:setSureBtnEvent(obj,func)
    self.mFunc = func
    self.mObj = obj
end

function GoodInfoDialog:onSureBtnClick()
    if type(self.mFunc) == "function" then
        self.mFunc(self.mObj)
    end
end

function GoodInfoDialog:setQipanView()
    self.isQipanView = true
    local view = self.qiPaiView:getChildByName("head")
    local level_icon = view:getChildByName("level")
    local mask = view:getChildByName("mask")
    if not mask then
        mask = new(Mask,UserInfo.DEFAULT_ICON[1],"common/background/head_mask_bg_86.png")
        local w,h = view:getSize()
        mask:setSize(w,h)
        mask:setName("mask")
        view:addChild(mask)
        level_icon:setLevel(3)
    end
    local iconType = UserInfo.getInstance():getIconType()
    if tonumber(iconType) == -1 then
        mask:setUrlImage(UserInfo.getInstance():getIcon())
    else
        local icon = tonumber(iconType) or 1
        mask:setFile(UserInfo.DEFAULT_ICON[icon] or UserInfo.DEFAULT_ICON[1])
    end
    level_icon:setFile( string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevel()))
    local name = self.qiPaiView:getChildByName("name")
    name:setText(UserInfo.getInstance():getName())
    local money_btn = self.qiPaiView:getChildByName("money_btn")
    money_btn:setPickable(false)
    local money_text = money_btn:getChildByName("text")
    money_text:setText("金币:" .. UserInfo.getInstance():getMoneyStr())
--    self.qiPaiView:setVisible(true)
end

function GoodInfoDialog:setNormalView()
    self.isQipanView = false
    self.qiPaiView:setVisible(false)
end

function GoodInfoDialog:onContentImgDown()
    self.qiPaiView:setVisible(self.isQipanView or false)
end