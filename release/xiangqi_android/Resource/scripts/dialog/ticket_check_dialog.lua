--region ticketCheckDialog.lua
--Date 2016.11.13
--
--endregion

require(VIEW_PATH .. "ticket_check_dialog");
require(BASE_PATH .. "chessDialogScene");

TicketCheckDialog = class(ChessDialogScene,false);

function TicketCheckDialog.ctor(self)
    super(self,ticket_check_dialog);

    self.mBg = self.m_root:getChildByName("view");
    self.mBg:setEventTouch(self,function()end);

    self.online_view = self.mBg:getChildByName("online_view")
    self.online_tiket_bg = self.online_view:getChildByName("bg")
    self.online_tiket_btn = self.online_view:getChildByName("user_ticket_btn")
    self.online_node_view = self.online_view:getChildByName("view")
    self.online_tiket_btn:setOnClick(self,function()
        self:useTiket()
    end)
    self.online_view:setVisible(false)

    self.offline_view = self.mBg:getChildByName("offline_view")
    self.offline_tiket_bg = self.offline_view:getChildByName("bg")
    self.offline_tiket_title = self.offline_view:getChildByName("title")
    self.offline_node_view = self.offline_view:getChildByName("view")
    self.offline_view:setVisible(false)

    self:setShieldClick(self,function()
        self:dismiss();
    end);

	self:setVisible(false);
    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)
end

function TicketCheckDialog.dtor(self)
    self.mDialogAnim.stopAnim()
end

function TicketCheckDialog.show(self)
    kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);
    self:setVisible(true);
    self.super.show(self,self.mDialogAnim.showAnim);
end

function TicketCheckDialog.isShowing(self)
	return self:getVisible();
end

function TicketCheckDialog.dismiss(self)
    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
end

function TicketCheckDialog.setData(self,data)
    if not data then return end
    self.data = data
end

function TicketCheckDialog.setStyle(self,index)
    local style = index or 109
    if style == 109 then
        self:switchOnline()
        self.online_view:setVisible(true)
        self.offline_view:setVisible(false)
    elseif style == 111 then
        self:switchOffline()
        self.online_view:setVisible(false)
        self.offline_view:setVisible(true)
    end
end

function TicketCheckDialog.switchOnline(self)
    if not self.data then return end
    if self.online_desc then
        delete(self.online_desc)
        self.online_desc = nil
    end

    if self.online_node then
        delete(self.online_node)
        self.online_node = nil
    end

    self.online_node = new(TicketNode,self.data)
    self.online_node:setPos(0,0)
    self.online_node_view:addChild(self.online_node)

    local desc = self.data.desc or ""
    self.online_desc = new(RichText,desc,nil,nil,kAlignTop,nil,30,150,150,150,false,5)
    self.online_desc:setAlign(kAlignTop)
    self.online_desc:setPos(0,266)
    self.online_view:addChild(self.online_desc)
end

function TicketCheckDialog.switchOffline(self)
    if not self.data then return end
    if self.offline_desc then
        delete(self.offline_desc)
        self.offline_desc = nil
    end

    if self.offline_node then
        delete(self.offline_node)
        self.offline_node = nil
    end

    self.offline_node = new(TicketNode,self.data)
    self.offline_node:setPos(0,0)
    self.offline_node_view:addChild(self.offline_node)

    local desc = self.data.desc or ""
    self.offline_desc = new(RichText,desc,nil,nil,kAlignTop,nil,24,150,150,150,false,5)
    self.offline_desc:setAlign(kAlignTop)
    self.offline_desc:setPos(0,522)
    self.offline_view:addChild(self.offline_desc)

    self.offline_title = self.offline_view:getChildByName("name")
    local name = UserInfo.getInstance():getName() or UserInfo.getInstance():getUid() or ""
    self.offline_title:setText(name)

    self.offline_id = self.offline_view:getChildByName("id")
    local id = UserInfo.getInstance():getUid() or ""
    self.offline_id:setText(id)
end

function TicketCheckDialog.useTiket(self)
    if UserInfo.getInstance():isFreezeUser() then return end;
    --跳转联网界面
    self:dismiss()
    StateMachine.getInstance():pushState(States.Compete,StateMachine.STYPE_CUSTOM_WAIT);
end
