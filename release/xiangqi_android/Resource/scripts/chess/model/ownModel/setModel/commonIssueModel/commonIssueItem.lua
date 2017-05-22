--region CommonIssueItem.lua
--Date 2016.10.24
-- test
--endregion

require("ui/foldItem");

CommonIssueItem = class(FoldItem,false)

function CommonIssueItem.ctor(self,data)
    if not data then return end
    self.m_data = data

    local plist = {}
    plist.item_height = 70
    plist.item_width = 550
    plist.btn_height = 70
    plist.btn_width = 550
    plist.status = 0
    plist.speed = 20
    super(self,plist)

    --在初始化后进行自己的初始化
    self:initView()
end

function CommonIssueItem.dtor(self)

end

--[Comment]
--初始化自定义界面
function CommonIssueItem.initView(self)
    local title = new(Text,self.m_data["title"] or "",nil,nil,nil,nil,32,135,100,95)
    title:setAlign(kAlignLeft)
    self.title_btn:addChild(title)

    self.m_bottom_line = new(Image,"common/decoration/line_2.png");
    self.m_bottom_line:setSize(556,2);
    self.m_bottom_line:setAlign(kAlignBottom);
    self.clip_view:addChild(self.m_bottom_line)
end


--[Comment]
--标题按钮点击事件，这里可以先进行自己的操作
function CommonIssueItem.titleClick(self)
    local status = self:getFoldStatus()
    if self.m_status == FoldItem.RETRACT_ITEM or self.m_status == FoldItem.LAUNCH_ITEM then
        return
    end
    self:createText()
    self.super.titleClick(self)
end

function CommonIssueItem.createText(self)
    if not self.m_issue_text then
        self.m_issue_text = new(RichText,self.m_data["text"],545,nil,kAlignTopLeft,nil,28,80,80,80,true,10);
        self.m_issue_text:setAlign(kAlignTop);
        self.m_issue_text:setPos(0,72);
        self.super.updataItem(self,self.m_issue_text)
    end
end

