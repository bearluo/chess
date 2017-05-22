--systemNoticeView.lua
--Date 16/12/26
--系统小喇叭

require(DATA_PATH .."systemNoticeLog");
require("util/analysisNotice")

SystemNoticeView = class(Node)

SystemNoticeView.handler = nil

function SystemNoticeView.ctor(self,w,h,scene)
    if not scene then return end
    self.mScene = scene 
    SystemNoticeView.handler = scene
    local sw = w or 650
    local sh = h or 940

    self.root_node = new(Node)
    self.root_node:setSize(sw,sh)
    self.root_node:setAlign(kAlignTop)
    self.notice_scroll = new(ScrollView2,0,20,sw,sh-50,true)
    self.notice_scroll:setAlign(kAlignTop)
    self.notice_scroll:setOnScroll(self,self.systemNoticeScroll)
    self.root_node:addChild(self.notice_scroll)
    if self.mScene.m_horn_room_view_content_view then
        self.mScene.m_horn_room_view_content_view:addChild(self.root_node)
    end
end

function SystemNoticeView.dtor(self)
    delete(self.notice_scroll)
    self.notice_scroll = nil
    delete(self.root_node)
    self.root_node = nil
end

function SystemNoticeView.updataHistoryList(self)
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onEventResponse)
    EventDispatcher.getInstance():register(Event.Call,self,self.onEventResponse)
    if not self.notice_scroll then return end
    local historyMsg = {}
    self.msg_time = os.time()
    self.label_time = self.msg_time
    local historyMsg = SystemNotice.getInstance():getHistoryMsgByTime(0,self.label_time);
    if historyMsg and next(historyMsg)then
--        self.msg_time = historyMsg[#historyMsg].time;
        local isHistory = true
        for i = #historyMsg,1,-1 do
            self:addSystemNotice(historyMsg[i],isHistory);
        end
        self.notice_scroll:gotoBottom()
    end
end

function SystemNoticeView.switchScene(self)
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onEventResponse)
    self.notice_scroll:removeAllChildren(true)
end

--上滑
function SystemNoticeView.systemNoticeScroll(self,offset)
    if tonumber(offset) and offset > 75 and not self.loading then
        self.loading = true;
        Loading.play(self.root_node,0,0,kAlignTop);
        local anim = new(AnimInt, kAnimNormal, 0, 1, 1000,0);
        if anim then 
            anim:setEvent(nil, function() 
                if self.label_time then
                    local item = self.notice_scroll:getChildren()[1]
                    if item then
                        self.label_time = item:getMsgTime()
                    end
                    local historyMsg = SystemNotice.getInstance():getHistoryMsgByTime(0, self.label_time);
                    if historyMsg and next(historyMsg) then
--                        self.label_time = historyMsg[#historyMsg].time;
--                        self.label_time = self.msg_time
                        local totalOffset = 0;
                        local isHistory = true
                        for i,v in ipairs(historyMsg) do
                            local tempItem = self:addSystemNotice(v,isHistory);
                            if tempItem then
                                self.notice_scroll:childToPos(tempItem,1);
                                local w, h = tempItem:getSize();
                                totalOffset = totalOffset + h;
                            end;
                        end;
                        self.notice_scroll:gotoOffset(-totalOffset+80);
                    end;
                end;
                self.loading = false;
                Loading.deleteAll();
            end);
        end;
    end;
end

function SystemNoticeView.addSystemNotice(self,message,isHistory)
    if not message or message == "" then
		return
	end
	local data = message
    local num = #(self.notice_scroll:getChildren())
    
    if num == 0 then
        data.isShowTime = true
        self.label_time = data.time
    else
--        if isHistory then
--            num = 1
--        end
--        local item = self.notice_scroll:getChildren()[num]
        if ToolKit.isSecondDay(data.time) then
            data.isShowTime = true
            self.label_time = data.time
        else
            if ToolKit.isInTenMinute(data.time, self.label_time) then
                data.isShowTime = false
            else
                data.isShowTime = true
                self.label_time = data.time     
            end
        end
    end
	local item = self:getCommonRoomChatItem(data)
--    self.msg_time = data.time
    if item then
        self.notice_scroll:addChild(item)
    end
    if not isHistory then
        self.notice_scroll:gotoBottom()
    end
    return item
end

function SystemNoticeView.getCommonRoomChatItem(self,data)
    --分析内容创建node
    local tab = AnalysisNotice.getAnalysisData(data)
    local item = self:getNode(tab,data)
    return item
end

function SystemNoticeView.onEventResponse(self,cmd, status, data)
    if cmd == kGetSystemNoticeMsg then
        if status then
            self:addSystemNotice(status,false)
        end
    end
end

function SystemNoticeView.getNode(self,tab,data)
    local itemType = 0
    for k,v in pairs(tab) do
        if v then
            if v.ctrl == "t" then
                itemType = tonumber(v.text) or 0 
                break
            end
        end
    end
    local item = nil
    if itemType == 11 then
        local userTab = {}
        userTab.isShowTime = data.isShowTime
        userTab.time = data.time
        for k,v in pairs(tab) do
            if v then
                if v.ctrl == "i" then
                    userTab.send_uid = tonumber(v.text) or 0 
                end
                if v.ctrl == "w" then
                    userTab.msg = v.text or ""
                end
            end
        end
        item = new(HallChatRoomItem,userTab);
    elseif itemType == 0 then
        return nil
    else
        item = new(SystemNoticeNode,tab,data)
    end
    return item
end


--------------------systemNotice node ----------------

SystemNoticeNode = class(Node)

function SystemNoticeNode.ctor(self,tab,data)
    self.richTextNode = nil
    self.imgNode = nil
    self.imgText = nil
    self.jumpScene = 0

    self.isShowTime = data.isShowTime 
    self.msg_time = data.time
    self.analysisTab = tab
    self.data = data or {}
    self:initView()
end

function SystemNoticeNode.dtor(self)

end

function SystemNoticeNode.initView(self)
--    self.node = new(Node)
--    self.node:setSize(660,100)
--    self.node:setAlign(kAlignCenter)
    self.m_time_bg = new(Image,"common/background/chat_time_bg.png");
    self.m_time_bg:setAlign(kAlignTop);
    self.m_time = new(Text, self:getTime(self.msg_time), 0, 0, nil,nil,20,120, 120, 120);
    local timeW,timeH = self.m_time:getSize();
    self.m_time_bg:setSize(timeW + 30);
    self.m_time:setAlign(kAlignCenter);
    self.m_time_bg:addChild(self.m_time);
	self:addChild(self.m_time_bg);
    local w,h = self.m_time_bg:getSize()
    if not self.isShowTime then
        self.m_time_bg:setVisible(false);
        self.diffH = 0
    else
        self.m_time_bg:setVisible(true);
        self.diffH = h + 10
    end

    self.sysBgImage = new(Image,"common/background/input_bg_2.png",nil,nil,33,33,31,31)
    self.sysBgImage:setPos(0,self.diffH)
    self.sysBgImage:setAlign(kAlignTop)

    self.sysBgButton = new(Button,"drawable/blank.png")
    self.sysBgButton:setPos(0,0)
    self.sysBgButton:setAlign(kAlignTopLeft)
    self.sysBgButton:setSrollOnClick(nil,function() end)
    self.sysBgButton:setOnClick(self,self.onItemClick)

    for k,v in pairs( self.analysisTab) do
        if v then
		    local txtInfo = v
		    local text = txtInfo.text
		    if txtInfo.ctrl == "t" then
			    local itemType = tonumber(text)
                if itemType == 12 then
                    self.imgNode = new(Image,"common/decoration/light_bg.png")
                elseif itemType == 13 then
                    self.imgNode = new(Image,"common/decoration/import_bg.png")
                elseif itemType == 14 then
                    self.imgNode = new(Image,"common/decoration/match_bg.png")
                end
                if self.imgNode then
                    self.imgNode:setAlign(kAlignTopLeft)
                    self.imgNode:setPos(40,20 + self.diffH)
                end
		    elseif txtInfo.ctrl == "d" then
                self.imgText = new(Text,text or "系统", 0, 0, nil,nil,20, 255, 255, 255);
                self.imgText:setAlign(kAlignCenter)
                self.imgText:setPos(0,0)
            elseif txtInfo.ctrl == "j" then
			    self.jumpScene = tonumber(text) or 0
		    elseif txtInfo.ctrl == "w" then         
                self.richTextNode = new(RichText,text or "", 540, nil, kAlignTopLeft,nil,28, 80, 80, 80, true, 3);
                self.richTextNode:setAlign(kAlignTopLeft)
                self.richTextNode:setPos(110,20 + self.diffH)
		    end
        end
    end

    if self.imgNode then
        self.imgNode:addChild(self.imgText)
    end
    self:addChild(self.sysBgImage)
    self:addChild(self.imgNode)
    self:addChild(self.richTextNode)
    self:addChild(self.sysBgButton)
    self:setAlign(kAlignTop)
    local w,h = 0,0
    if self.richTextNode then
        w,h = self.richTextNode:getSize()
    end
    self.sysBgImage:setSize(640,h + 40)
    self.sysBgButton:setSize(640,h + 40)
    self:setSize(693,h + 60 + self.diffH)

end

function SystemNoticeNode.onItemClick(self)
    if self.jumpScene and self.jumpScene > 0 then 
        local handler = SystemNoticeView.handler
        if handler then
            handler:dismiss()
        end
        if tonumber(self.jumpScene) == States.Friends then
            TaskScene.s_showRelationshipDialog()
            return
        elseif tonumber(self.jumpScene) == States.Replay then
            TaskScene.s_showReplayDialog()
            return
        end
        StateMachine.getInstance():pushState(self.jumpScene,StateMachine.STYPE_CUSTOM_WAIT)
    end
end

function SystemNoticeNode.getMsgTime(self)
    return self.msg_time or 0
end


function SystemNoticeNode.getTime(self, time)
    if not time then return nil end;
    if ToolKit.isSecondDay(time) then
        return os.date("%m-%d",time);-- 08-07格式
    else
        return os.date("%H:%M",time);--%Y/%m/%d %X
    end;
end