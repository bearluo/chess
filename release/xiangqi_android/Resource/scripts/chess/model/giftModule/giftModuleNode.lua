--region giftModuleNode.lua
--Date 2016.11.14
--
--endregion

GiftModuleNode = class(Node)

GiftModuleNode.default_size = {
    [1] = {w = 120,h = 124},
    [2] = {w = 120,h = 124},
}

--我的模块 礼物item有背景,122，124
--ret :是否需要默认
--function GiftModuleNode.ctor(self,ret)
--    self:setAlign(kAlignCenter)
--    if ret then
--        self:initDefaultNode()
--    end
--end 

--function GiftModuleNode.setNodeView(self,xmlView)
--    if xmlView then
--        self.m_root_node = xmlView
--    end
--    self:addChild(self.m_root_node)
--end

--function GiftModuleNode.initDefaultNode(self)
--    self.bg = new(Image,"common/background/prop_lbg.png",nil,nil,40,40,40,40)
--    self.bg:setSize(120,120)
--    self.bg:setAlign(kAlignTop)
--    self:addChild(self.bg)

--    self.bottom_bg = new(Image,"common/background/prop_sbg.png",nil,nil,40,40,0,0)
--    self.bottom_bg:setSize(120,40)
--    self.bottom_bg:setPos(0,4)
--    self.bottom_bg:setAlign(kAlignBottom)
--    self:addChild(self.bottom_bg)

--    self.num_text = new(Text,"",nil,nil,kAlignCenter,nil,28,240,200,160)
--    self.num_text:setPos(0,12)
--    self.num_text:setAlign(kAlignCenter)
--    self:addChild(self.num_text)

--    self.gift_icon = new(Image,"")
--    self.gift_icon:setAlign(kAlignTop)
--    self:addChild(self.gift_icon)
--end

--function GiftModuleNode.setNumDefaultText(self,num)
--    if self.num_text then
--        self.num_text = self.m_root_node:getChildByName("num_text")
--    end
--end

--function GiftModuleNode.updataNum(self)

--end

function GiftModuleNode.createNode(num)
    local node = new(Node)
    node:setAlign(kAlignTop);
    node:setSize(120,124)
    node:setPos(0,0)

    node.node_bg = new(Image,"common/background/prop_lbg.png",nil,nil,40,40,40,40)
    node.node_bg:setAlign(kAlignTop)
    node.node_bg:setSize(120,120)
    node:addChild(node.node_bg)

    node.bottom_bg = new(Image,"common/background/prop_sbg.png",nil,nil,40,40,0,0)
    node.bottom_bg:setAlign(kAlignBottom)
    node.bottom_bg:setSize(120,40)
    node.bottom_bg:setPos(0,4)
    node:addChild(node.bottom_bg)

    node.num_text = new(Text,"",nil,nil,kAlignCenter,nil,28,240,200,160)
    node.num_text:setAlign(kAlignBottom)
    node.num_text:setPos(0,12)
    node:addChild(node.num_text)

    node.gift_icon = new(Image,"")
    node.gift_icon:setAlign(kAlignTop)
    node.gift_icon:setPos(0,0)
    node:addChild(node.gift_icon)

    function node:setPos(x,y)
        local nodeX = x or 0 
        local nodeY = y or 0
        node:setPos(nodeX,nodeY)
    end

    function node:setNumPos(x,y)
        local textX = x or 0
        local textY = y or 12
        if node.num_text then
            node.num_text:setPos(textX,textY)
        end
    end

    function node:setNodeBgSize(w,h)
        local nodeW = w or 120
        local nodeH = h or 120
        if node.node_bg then
            node.node_bg:setPos(nodeW,nodeH)
        end
    end

    function node:updataNum(num)
        if node.num_text then
            node.num_text:setText(num .. "")
        end
    end

--    if num then

--    end
end