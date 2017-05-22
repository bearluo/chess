--region WatchItemStyle.lua
--Date 2016.10.31
--聊天文字显示样式
--endregion

require(MODEL_PATH .. "giftModule/giftModuleConstant")

WatchItemStyle = {}

function WatchItemStyle.createNode(data,maxW)
    local nodeData = data or {}
    local userData = data.sendInfo or {}
    local gift = GiftModuleConstant.gift_type[data.gift_type] or {}
    local node = new(Node)
    node:setAlign(kAlignTop);
    node:setSize(720,46)
    node:setPos(0,0)

    local score = tonumber(userData.score) or 1000
    local levelImg = new(Image,"common/icon/level_"..(10 - UserInfo.getInstance():getDanGradingLevelByScore(score))..".png")
    levelImg:setAlign(kAlignLeft)
    levelImg:setPos(18,0)
    node:addChild(levelImg)

    local sendName = userData.user_name or "博雅象棋"
    local name1 = new(Text,sendName,nil, nil, nil, nil, 26, 220, 75, 30)
    name1:setPos(76,0)
    name1:setAlign(kAlignLeft)
    node:addChild(name1)

    local w1,_ = name1:getSize()
    local linkText = new(Text,"给选手",nil, nil, nil, nil, 26, 80, 80, 80)
    linkText:setPos(80 + w1,0)
    linkText:setAlign(kAlignLeft)
    node:addChild(linkText)

    local targetName = nodeData.targetName
    local w2,_ = linkText:getSize()
    local name2 = new(Text,targetName,nil, nil, nil, nil, 26, 80, 80, 80)
    name2:setPos(84 + w1 + w2,0)
    name2:setAlign(kAlignLeft)
    node:addChild(name2)

    local w3,_ = name2:getSize()
    local linkText1 = new(Text,"赠送",nil, nil, nil, nil, 26, 80, 80, 80)
    linkText1:setPos(88 + w1 + w2 + w3,0)
    linkText1:setAlign(kAlignLeft)
    node:addChild(linkText1)

    local w4,_ = linkText1:getSize()
    local giftName = new(Text,gift.name or "未知",nil, nil, nil, nil, 26, 220, 75, 30)
    giftName:setPos(92 + w1 + w2 + w3 + w4,0)
    giftName:setAlign(kAlignLeft)
    node:addChild(giftName)

    local w5,_ = giftName:getSize()
    local giftIcon = new(Image,gift.chat_img)
    giftIcon:setAlign(kAlignLeft)
    giftIcon:setPos(96 + w1 + w2 + w3 + w4 + w5,0)
    node:addChild(giftIcon)

    local w6,_ = giftIcon:getSize()
    local num_view = new(Node)
    num_view:setAlign(kAlignLeft)
    num_view:setSize(34,42)
    num_view:setPos(100 + w1 + w2 + w3 + w4 + w5 + w6,-2)
    node:addChild(num_view)
    local image = new(Image,"watchRoomIcon/watch_x.png")
    image:setPos(-3,1)
    image:setAlign(kAlignLeft)
    num_view:addChild(image)
    local num = nodeData.giftNum
    local tab = WatchItemStyle.countNumImg(num)
    local len = string.len(tostring(num))
    node.imglist = {}
    for i = 1, len do
        node.imglist[i] = new(Image, "watchRoomIcon/num_" .. tab[i] .. ".png")
        node.imglist[i]:setSize(34,42)
        node.imglist[i]:setAlign(kAlignLeft)
        node.imglist[i]:setPos(1 + i * 34,0)
        num_view:addChild(node.imglist[i])
    end

    local itemButton = new(Button,"drawable/blank.png")
    itemButton:setAlign(kAlignLeft)
    itemButton:setPos(16,0)
    itemButton:setSize(680,36)
    node:addChild(itemButton)
    itemButton:setSrollOnClick(nil,function() end)

    function node:getItemButton()
        return itemButton
    end

    return node
end

function WatchItemStyle.createNoNumNode(data)
    local nodeData = data or {}
    local userData = data.sendInfo or {}
    local gift = GiftModuleConstant.gift_type[data.gift_type] or {}
    local node = new(Node)
    node:setAlign(kAlignTop);
    node:setSize(720,46)
    node:setPos(0,0)

    local score = tonumber(userData.score) or 1000
    local levelImg = new(Image,"common/icon/level_"..(10 - UserInfo.getInstance():getDanGradingLevelByScore(score))..".png")
    levelImg:setAlign(kAlignLeft)
    levelImg:setPos(18,0)
    node:addChild(levelImg)

    local sendName = userData.user_name or "博雅象棋"
    local name1 = new(Text,sendName,nil, nil, nil, nil, 26, 220, 75, 30)
    name1:setPos(76,0)
    name1:setAlign(kAlignLeft)
    node:addChild(name1)

    local w1,_ = name1:getSize()
    local linkText = new(Text,"给选手",nil, nil, nil, nil, 26, 80, 80, 80)
    linkText:setPos(80 + w1,0)
    linkText:setAlign(kAlignLeft)
    node:addChild(linkText)

    local targetName = nodeData.targetName
    local w2,_ = linkText:getSize()
    local name2 = new(Text,targetName,nil, nil, nil, nil, 26, 80, 80, 80)
    name2:setPos(84 + w1 + w2,0)
    name2:setAlign(kAlignLeft)
    node:addChild(name2)

    local w3,_ = name2:getSize()
    local linkText1 = new(Text,"赠送",nil, nil, nil, nil, 26, 80, 80, 80)
    linkText1:setPos(88 + w1 + w2 + w3,0)
    linkText1:setAlign(kAlignLeft)
    node:addChild(linkText1)

    local w4,_ = linkText1:getSize()
    local giftName = new(Text,gift.name or "未知",nil, nil, nil, nil, 26, 220, 75, 30)
    giftName:setPos(92 + w1 + w2 + w3 + w4,0)
    giftName:setAlign(kAlignLeft)
    node:addChild(giftName)

    local w5,_ = giftName:getSize()
    local giftIcon = new(Image,gift.chat_img)
    giftIcon:setAlign(kAlignLeft)
    giftIcon:setPos(96 + w1 + w2 + w3 + w4 + w5,0)
    node:addChild(giftIcon)

--    local w6,_ = giftIcon:getSize()
--    local num_view = new(Node)
--    num_view:setAlign(kAlignLeft)
--    num_view:setSize(34,42)
--    num_view:setPos(100 + w1 + w2 + w3 + w4 + w5 + w6,-2)
--    node:addChild(num_view)
--    local image = new(Image,"watchRoomIcon/watch_x.png")
--    image:setPos(-3,1)
--    image:setAlign(kAlignLeft)
--    num_view:addChild(image)
--    local num = nodeData.giftNum
--    local tab = WatchItemStyle.countNumImg(num)
--    local len = string.len(tostring(num))
--    node.imglist = {}
--    for i = 1, len do
--        node.imglist[i] = new(Image, "watchRoomIcon/num_" .. tab[i] .. ".png")
--        node.imglist[i]:setSize(34,42)
--        node.imglist[i]:setAlign(kAlignLeft)
--        node.imglist[i]:setPos(1 + i * 34,0)
--        num_view:addChild(node.imglist[i])
--    end
    
--    local numStr = "X" .. num
--    local giftNum = new(Text,numStr,nil, nil, nil, nil, 26, 80, 80, 80)
--    giftNum:setAlign(kAlignLeft)
--    giftNum:setPos(100 + w1 + w2 + w3 + w4 + w5 + w6,0)
--    node:addChild(giftNum)

    return node
end

function WatchItemStyle.createVipLoginNode(data)
    local nodeData = data or {}
    local userData = json.decode(data.sendInfo) or {}
    local score = userData.score or 1000
    local name = userData.user_name or "博雅象棋"
    local node = new(Node)
    node:setAlign(kAlignTop);
    node:setSize(720,46)
    node:setPos(0,0)

    local logoImg = new(Image,"watchRoomIcon/welcome_chat.png")
    logoImg:setPos(35,0)
    logoImg:setAlign(kAlignLeft)
    node:addChild(logoImg)

    local text1 = new(Text,"欢迎",nil, nil, nil, nil, 26, 80, 80, 80) 
    text1:setPos(64,0)
    text1:setAlign(kAlignLeft)
    node:addChild(text1)

    local w1,_ = text1:getSize()
    local vipLogo = new(Image,"watchRoomIcon/vip_logo_chat.png")
    vipLogo:setPos(68 + w1,0)
    vipLogo:setAlign(kAlignLeft)
    node:addChild(vipLogo)

    local levelImg = new(Image,"common/icon/level_"..(10 - UserInfo.getInstance():getDanGradingLevelByScore(score))..".png")
    levelImg:setPos(118 + w1,0)
    levelImg:setAlign(kAlignLeft)
    node:addChild(levelImg)

    local w2,_ = levelImg:getSize()
    local name = new(Text,name,nil, nil, nil, nil, 26, 255, 40, 40)
    name:setPos(126 + w1 + w2,0)
    name:setAlign(kAlignLeft)
    node:addChild(name)

    local w3,_ = name:getSize()
    local text2 = new(Text,"来到本房间！",nil, nil, nil, nil, 26, 80, 80, 80)
    text2:setPos(130 + w1 + w2 + w3,0)
    text2:setAlign(kAlignLeft)
    node:addChild(text2)

    return node
end

function WatchItemStyle.createLeftDanmuItem(data)

    local node = new(Node)
    node:setLevel(100)
    node.nodeData = data
    node.sendName = data.sendName or ""
    node.targetName = data.targetName or ""
    node.gift = GiftModuleConstant.gift_type[data.gift_type] or {}
    node.key = data.sendId .. data.targetId .. data.gift_type
    node.num = data.giftNum
    node.msgTime = data.msgTime
    node:setAlign(kAlignTopLeft)
    node:setSize(480,92)

    local bgImg = new(Image,"watchRoomIcon/chat_bg.png",nil,nil,70,50,0,0)
    bgImg:setTransparency(0.9)
    bgImg:setAlign(kAlignLeft)
    bgImg:setSize(460,86)
    bgImg:setPos(0,0)
    node:addChild(bgImg)
        
    local sendText = new(Text,node.sendName,nil, nil, nil, nil, 28, 255, 255, 255)
    sendText:setAlign(kAlignTopLeft)
    sendText:setPos(28,16)
    node:addChild(sendText)

    local str = string.format("给 %s 赠送 %s",node.targetName,node.gift.name or "未知")
    local targetStr = new(Text,str,nil, nil, nil, nil, 20, 255, 230, 0)
    targetStr:setAlign(kAlignTopLeft)
    targetStr:setPos(28,52)
    node:addChild(targetStr)

    local giftImg = new(Image,node.gift.img)
    giftImg:setAlign(kAlignTopLeft)
    giftImg:setPos(258,0)
    node:addChild(giftImg)

    local num_view = new(Node)
    num_view:setPos(343,0)
    num_view:setAlign(kAlignTopLeft)
    num_view:setSize(160,92)
    num_view:setVisible(false)
    node:addChild(num_view)

    local image = new(Image,"watchRoomIcon/watch_x.png")
    image:setPos(-3,1)
    image:setAlign(kAlignLeft)
    num_view:addChild(image)

    local len = string.len(tostring(node.num))
    node.imglist = {}
    for i = 1, len do
        node.imglist[i] = new(Image, "")
        node.imglist[i]:setSize(34,42)
        node.imglist[i]:setAlign(kAlignLeft)
        node.imglist[i]:setPos(1 + i * 34,0)
        num_view:addChild(node.imglist[i])
    end
    
    node.anim_step1 = nil
    node.anim_step2 = nil
    node.timer = nil
    node.deleteTimer = nil
    node.giftNum = 0
    node.animStatus = true -- true代表动画进行中 false代表动画结束

    function node:startAnim()
        local w,h = node:getSize()
        node.anim_step1 = node:addPropTranslate(1,kAnimNormal,200,-1,-w,0,0,0);
        if node.anim_step1 then
            node.anim_step1:setEvent(nil,function()
                node:removeProp(1)
                num_view:setVisible(true)
                delete(node.anim_step1)
                node.anim_step1 = nil
                node:numTimer(true)
            end)
        end
    end

    --ret 控制是否是第一次播放动画
    function node:numTimer(ret)
        if node.timer then
            delete(node.timer)
            node.timer = nil
        end
        if ret then
            node:updateNumImg()
            node:numAnim()
        end
        node.timer = new(AnimInt,kAnimRepeat,0,1,100,-1)
        node.timer:setEvent(nil,function()
            if not num_view:checkAddProp(1) then
                num_view:removeProp(1);
            end
            node:updateNumImg()

            if node.animStatus then
                node:numAnim()
            else
                --停止动画 2s后消失
                delete(node.anim_step1)
                delete(node.anim_step2)
                delete(node.timer)
                node:startDeleteTimer()
            end
        end)
    end

    function node:numAnim()
        node.anim_step2 = num_view:addPropScale(1,kAnimNormal,90,-1,0.8,1,0.8,1,kCenterDrawing)
        if node.anim_step2 then
            node.anim_step2:setEvent(nil,function()
                num_view:removeProp(1)
                delete(node.anim_step2)
                node.anim_step2 = nil
            end)    
        end
    end

    function node:updateNumImg()
        if node.giftNum >= node.num then  
            node.animStatus = false
            return
        end
        node.giftNum = node.giftNum + 1
        local numtab = WatchItemStyle.countNumImg(node.giftNum)
        for k,v in pairs(numtab) do
            if v then
                node.imglist[k]:setFile("watchRoomIcon/num_" .. v .. ".png")
            end
        end
    end

    function node:startDeleteTimer()
        node.deleteTimer = new(AnimInt,kAnimNormal,0,1,2000,-1)
        if node.deleteTimer then
            node.deleteTimer:setEvent(nil,function()
                if not node.animStatus then
                    -- 回调 删除node
                    local x,y = node:getPos()
                    node:addPropTranslate(3,kAnimNormal,500,-1,nil,nil,0,- 70)
                    local propanim = node:addPropTransparency(2,kAnimNormal,500,-1,1,0)
                    if propanim then
                        propanim:setEvent(nil,function()
                            node:setVisible(false)
                            node:removeProp(2)
                            node:removeProp(3)
                            if node.obj and type(node.func) == "function" then
                                local obj = node.obj
                                node.func(node.obj,node)
                            end
                        end)
                    end
                end
                delete(node.deleteTimer)
                node.deleteTimer = nil
            end)
        end
    end

    function node:resumeNunAnim()
        node:numTimer(false)
        delete(node.deleteTimer)
        node.deleteTimer = nil
    end

    function node:setEndCallBack(obj,func)
        node.obj = obj
        node.func = func
    end

    function node:updateData(data)
        if not data then return end
        node.num = node.num + tonumber(data.giftNum)
        if node.num == node.giftNum then return end
        node.msgTime = data.msgTime
        if not node.animStatus then
            node.animStatus = true 
            return true
        end
    end

    function node:dtor()
        delete(node.timer)
        node.timer = nil
        delete(node.anim_step1)
        node.anim_step1 = nil
        delete(node.anim_step2)
        node.anim_step2 = nil
        node:removeProp(1)
        num_view:removeProp(1)
    end

    return node
end

function WatchItemStyle.countNumImg(num)
    if not num then return end
    local total = tonumber(num)
    local length = string.len(tostring(num))
    local numTab = {}
    local tempNum = 0
    for i = length,1,-1 do 
        tempNum = total % 10
        numTab[i] = tempNum
        total = (total - tempNum) / 10
    end
    return numTab
end