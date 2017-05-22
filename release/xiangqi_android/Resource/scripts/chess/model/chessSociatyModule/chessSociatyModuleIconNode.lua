--ChessSociatyModuleIconNode.lua
--Date 2016.8.30
--棋社徽章icon
--endregion

ChessSociatyModuleIconNode = class(Node)

ChessSociatyModuleIconNode.s_w = 116;
ChessSociatyModuleIconNode.s_h = 104;

function ChessSociatyModuleIconNode.ctor(self,data,handler,index)
    if not data then return end
    self.data = data
    self.handler = handler
    self:setAlign(kAlignCenter);
    self:setSize(ChessSociatyModuleIconNode.s_w,ChessSociatyModuleIconNode.s_h)

    self.icon = new(Image,"sociaty_about/r_scholar.png")
    self.icon:setSize(86,86);
    self.icon:setAlign(kAlignCenter)
    self:addChild(self.icon);

    self.select_icon = new(Image,"sociaty_about/sociaty_icon_select.png")
    self.select_icon:setSize(92,92);
    self.select_icon:setAlign(kAlignCenter)
    self.select_icon:setVisible(false)
    self:addChild(self.select_icon);

    self.select_btn = new(Button,"drawable/blank.png")
    self.select_btn:setSize(100,100);
    self.select_btn:setAlign(kAlignCenter)
    self:addChild(self.select_btn);

    self.is_select = false
    self.select_btn:setOnClick(self,self.onSelectIcon);
    self.select_btn:setSrollOnClick()

    self:setNodeData()
end

--[Comment]
--设置icon数据
function ChessSociatyModuleIconNode.setNodeData(self)
    if not self.data then return end
    self.index = self.data.index
    self.icon:setFile(self.data.file)
    if self.data.is_select then
        self.is_select = true
        self.select_icon:setVisible(true)
    end
end

--[Comment]
--选择棋社徽章
function ChessSociatyModuleIconNode.onSelectIcon(self)
    if self.is_select then return end
    self.is_select = true
    self.select_icon:setVisible(true);
    if self.handler then
        self.handler:updataSelectStatus(self.index)
    end
end

--[Comment]
--取消选择棋社徽章
function ChessSociatyModuleIconNode.updataSelectStatus(self)
    self.is_select = false
    self.select_icon:setVisible(false);
end

--[Comment]
--设置按钮选择状态
function ChessSociatyModuleIconNode.setSelectStatus(self,ret)
    local isSelect = false
    if ret then
        isSelect = ret
    end
    self.is_select = isSelect
    self.select_icon:setVisible(isSelect);
end