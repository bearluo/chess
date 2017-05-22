--SwitchSelectNode.lua
--Date 2016.10.8
--没有
--end

SwitchSelectNode = class(Node)

function SwitchSelectNode.ctor(self,plist)
    if not plist then return end
    self.plist = plist

    self:setSize(458,92)
    self:setAlign(kAlignTopLeft)

    self.textBg = new(Image,"common/background/input_bg_1.png",nil,nil,32,32,30,30)
    self.textBg:setAlign(kAlignCenter)
    self.textBg:setSize(390,60)
    self:addChild(self.textBg)

    self.text = new(Text,"",nil,nil,kAlignCenter,nil,32,135,100,95)
    self.text:setAlign(kAlignCenter)
    self.textBg:addChild(self.text)

    self.rightBtn = new(Button,"common/button/select_btn.png")
    self.rightBtn:setAlign(kAlignRight)
    self.rightBtn:setPos(0,0)
    self.right_arr = new(Image,"common/icon/select_right.png")
    self.right_arr:setAlign(kAlignCenter);
    self.rightBtn:addChild(self.right_arr)
    self:addChild(self.rightBtn)

    self.leftBtn = new(Button,"common/button/select_btn.png")
    self.leftBtn:setAlign(kAlignLeft)
    self.leftBtn:setPos(0,0)
    self.left_arr = new(Image,"common/icon/select_left.png")
    self.left_arr:setAlign(kAlignCenter);
    self.leftBtn:addChild(self.left_arr)
    self:addChild(self.leftBtn)

    local func = function(view,enable)
        if view then
            if enable then
                view:removeProp(1);
            else
                view:addPropScaleSolid(1,1.1,1.1,1);
            end
        end
    end
    self.leftBtn:setOnClick(self,self.leftBtnClick)
    self.leftBtn:setOnTuchProcess(self.leftBtn,func);
    self.rightBtn:setOnClick(self,self.rightBtnClick)
    self.rightBtn:setOnTuchProcess(self.rightBtn,func);
end

--[Comment]
--设置按钮背景图
function SwitchSelectNode.setBtnBgImg(self,imglist)
    if not imglist or type(imglist) ~= "table" then 
        print_string("set button background image failed !! param is error!!")
        return 
    end
    if next(imglist) == nil then
        print_string("param is null !! use default button image background")
        return
    end

    local nor = imglist[1]
    local press = imglist[2]
    if not press or press == "" then
        press = nor
    end
    local imgtab = {nor,press}
    self.leftBtn:setFile(imgtab);
    self.rightBtn:setFile(imgtab);
end

--[Comment]
--设置按钮图标  左右两个按钮图标
function SwitchSelectNode.setBtnImg(self,imglist)
    if not imglist or type(imglist) ~= "table" then 
        print_string("set button background image failed !! param is error!!")
        return 
    end
    if next(imglist) == nil then
        print_string("param is null !! use default button image background")
        return
    end

    local left = imglist[1]
    local right = imglist[2]
    if left and left ~= "" then
        self.left_arr:setFile(left)
    end
    if right and right ~= "" then
        self.right_arr:setFile(right)
    end
end

--[Comment]
--左侧按钮点击
function SwitchSelectNode.leftBtnClick(self)
    if not self.index or self.index == 1 then
        print_string("已经在最左边了")
        return
    end
    self.index = self.index - 1
    self:setSelectText()
    self:updataBtnGray()
end

--[Comment]
--右侧按钮点击
function SwitchSelectNode.rightBtnClick(self)
    local maxIndex = #self.plist
    if not self.index or self.index == maxIndex then
        print_string("已经在最右边了")
        return
    end
    self.index = self.index + 1
    self:setSelectText()
    self:updataBtnGray()
end

--[Comment]
--设置当前位置
function SwitchSelectNode.setIndex(self,index)
    self.index = index or 1
    self:setSelectText()
    self:updataBtnGray()
end

--[Comment]
--设置当前位置文本
function SwitchSelectNode.updataBtnGray(self)
    local maxIndex = #self.plist
    if self.index == 1 then
        self.leftBtn:setGray(true)
    else
        self.leftBtn:setGray(false)
    end

    if self.index == maxIndex then
        self.rightBtn:setGray(true)
    else
        self.rightBtn:setGray(false)
    end
end

--[Comment]
-- 更新按钮颜色
function SwitchSelectNode.setSelectText(self)
    local index = self.index or 1
    local text = self.plist[index] or ""
    self.text:setText(text)
end


--[Comment]
--获得当前选择
function SwitchSelectNode.getSelectIndex(self)
    return self.index or 1
end
