require(VIEW_PATH .. "console_ready_dialog_view");
require(BASE_PATH.."chessDialogScene")

ConsoleReadyDialog = class(ChessDialogScene,false)

function ConsoleReadyDialog:ctor()
    super(self,console_ready_dialog_view)
    self:setNeedBackEvent(false)
    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)
    self.mBg = self.m_root:getChildByName("bg")
    self.mTaskView = {}
    for i=1,3 do
        self.mTaskView[i] = self.mBg:getChildByName( string.format("task_%d_view",i))
    end
    self.mPropView = self.mBg:getChildByName("prop_view")
    self.mExchangePropBtn = self.mBg:getChildByName("exchange_prop_btn")
    self.mOfflineTipsView = self.mBg:getChildByName("offline_tips_view")
    self.mOfflineTipsView:setVisible(false)

    self.mStartBtn = self.mBg:getChildByName("start_btn")
    self.mStartBtn:setOnClick(self,self.onStartBtnClick)
    self.mBackBtn = self.mBg:getChildByName("back_btn")
    self.mBackBtn:setOnClick(self,self.onBackBtnClick)
end

function ConsoleReadyDialog:dtor()
    self.mDialogAnim.stopAnim()
    delete(self.mCheckBackDialog)
    delete(self.mExchangePropDialog)
end

function ConsoleReadyDialog:show()
    self.super.show(self,self.mDialogAnim.showAnim)
--    if UserInfo.getInstance():isLogin() then
        self.mPropView:setVisible(true)
        self.mExchangePropBtn:setVisible(true)
        self.mStartBtn:setPos(140)
        self.mOfflineTipsView:setVisible(false)
        for i=1,3 do
            self.mTaskView[i]:setVisible(true)
        end
--    else
--        self.mPropView:setVisible(false)
--        self.mExchangePropBtn:setVisible(false)
--        self.mStartBtn:setPos(0)
--        self.mOfflineTipsView:setVisible(true)
--        for i=1,3 do
--            self.mTaskView[i]:setVisible(false)
--        end
--    end
end

function ConsoleReadyDialog:dismiss()
    self.super.dismiss(self,self.mDialogAnim.dismissAnim)
end

function ConsoleReadyDialog:setConsoleLevel(level)
    if not level then return end
    self.mConsoleLevel = level
    local config = ConsoleData.getInstance():getConfigByLevel(self.mConsoleLevel)
    -- 根据单机模式判断玩家红黑方
    local model = User.AI_MODEL[self.mConsoleLevel];
    if model == Board.MODE_RED then
        self.mFlag = FLAG_RED;
    else
        self.mFlag = FLAG_BLACK;
    end
    self:setTask(config.rule,self.mFlag)
    
    self.mExchangePropCost = tonumber(config.prop_cost) or 1
    self.mExchangePropBtn:removeAllChildren()
    local startPos = 0
    if ConsoleData.getInstance():isHasFreeGun() then
        local text1 = new(Text, "使用火炮(免费)",width, height, align, fontName, 28, 95, 15, 15)
        text1:setAlign(kAlignCenter)
        self.mExchangePropBtn:addChild(text1)
    else
        local linearLayoutView = new(Node)
        linearLayoutView:setAlign(kAlignCenter)
        local text1 = new(Text, "使用火炮(",width, height, align, fontName, 28, 95, 15, 15)
        local yuanbaoImg = new(Image,"common/icon/bccoin_icon_2.png")
        local text2 = new(Text, string.format("%d)",self.mExchangePropCost),width, height, align, fontName, 28, 95, 15, 15)
        startPos = self:linearLayoutView(linearLayoutView,startPos,text1)
        startPos = self:linearLayoutView(linearLayoutView,startPos,yuanbaoImg)
        startPos = self:linearLayoutView(linearLayoutView,startPos,text2)
        linearLayoutView:setSize(startPos,1)
        self.mExchangePropBtn:addChild(linearLayoutView)
    end
    self.mExchangePropBtn:setOnClick(self,self.onExchangePropBtnClick)
    self:setUserGuns(false)
end

function ConsoleReadyDialog:onExchangePropBtnClick()
    StatisticsManager.getInstance():onCountToUM(OFFLINE_CONSOLE_GUNS_BTN_CLICK)
    if ConsoleData.getInstance():isHasFreeGun() then
        local params = {}
        params.console_level = self.mConsoleLevel
        HttpModule.getInstance():execute(HttpModule.s_cmds.UserGuns,params,"使用中")
        self.mExchangePropBtn:setPickable(false)
        return 
    end
    if UserInfo.getInstance():getBccoin() < self.mExchangePropCost then
        ChessToastManager.getInstance():showSingle("元宝不足")
        return 
    end
    local tips = string.format("是否使用%d元宝兑换#c5ffa5e火炮",self.mExchangePropCost)
    if not self.mExchangePropDialog then
        self.mExchangePropDialog = new(ChioceDialog);
        self.mExchangePropDialog:setMode(ChioceDialog.MODE_COMMON);
        self.mExchangePropDialog:setMaskDialog(true)
        self.mExchangePropDialog:setNeedMask(false)
    end
    self.mExchangePropDialog:setMessage(tips);
    self.mExchangePropDialog:setNegativeListener(nil,nil);
    self.mExchangePropDialog:setPositiveListener(self,function()
        local params = {}
        params.console_level = self.mConsoleLevel
        HttpModule.getInstance():execute(HttpModule.s_cmds.UserGuns,params,"兑换中")
        self.mExchangePropBtn:setPickable(false)
    end);
    self.mExchangePropDialog:show();
end

function ConsoleReadyDialog:setUserGuns(isHasGuns)
--    self.mIsHasGuns = isHasGuns
    if isHasGuns then
        self.mExchangePropBtn:setPickable(false)
--        self.mExchangePropBtn:getChildByName("txt"):setText("已购买")
    else
        self.mExchangePropBtn:setPickable(true)
    end
end

function ConsoleReadyDialog:setTask(task,flag)
    if not type(task) == "table" then return end
    for i=1,3 do
        if task[i..""] then
            self:initTaskViewByData(self.mTaskView[i],i,flag,task[i..""])
        end
    end
end

function ConsoleReadyDialog:setStartBtnClickListener(obj,func)
    self.mStartBtnClickListener = {}
    self.mStartBtnClickListener.obj = obj
    self.mStartBtnClickListener.func = func
end

function ConsoleReadyDialog:onStartBtnClick()
    if self.mStartBtnClickListener and type(self.mStartBtnClickListener.func) == "function" then
        self.mStartBtnClickListener.func(obj)
    end
    self:dismiss()
end

function ConsoleReadyDialog:onBackBtnClick() 
--    if self.mIsHasGuns then
--        if not self.mCheckBackDialog then
--            self.mCheckBackDialog = new(ChioceDialog);
--            self.mCheckBackDialog:setMode(ChioceDialog.MODE_COMMON);
--        end
--        self.mCheckBackDialog:setMessage("退出后当前购买的火炮将不会保留,是否还要退出");
--        self.mCheckBackDialog:setNegativeListener(nil,nil);
--        self.mCheckBackDialog:setPositiveListener(self,function()
--            StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT)
--        end);
--        self.mCheckBackDialog:show();
--    else
        StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT)
--    end
end

--[Comment]
-- flag 红黑方
function ConsoleReadyDialog:initTaskViewByData(taskView,taskId,flag,data)
    if not taskView or type(data) ~= "table" then return end
    taskId = tonumber(taskId) or 0
    taskView:removeAllChildren()
    local startPos = 0
    local myOffset = flag * 8
    local oppOffset = ( (flag + 1) * 8 - 1 ) % 16 + 1
    local resMap = UserSetInfo.getInstance():getChessRes()
    local star = new(Image,"common/decoration/star_dec_1.png")
    startPos = self:linearLayoutView(taskView,startPos+10,star)
    if taskId ~= 3 then
        local bottomline = new(Image,"common/decoration/line_9.png")
        bottomline:setSize(554,1)
        bottomline:setAlign(kAlignBottom)
        taskView:addChild(bottomline)
    end
    local pcBgFile = resMap["piece.png"]
    if data.type == ConsoleData.TASK_TYPE_WIN then
        local text1 = new(Text, "过关",width, height, align, fontName, 24, 125, 80, 65)
        local text2 = new(Text, "任务",width, height, align, fontName, 24, 125, 80, 65)
        local node = new(Node)
        node:setSize(text1:getSize(),select(2,text1:getSize())+select(2,text2:getSize())+10)
        node:addChild(text1)
        text1:setAlign(kAlignTop)
        node:addChild(text2)
        text2:setAlign(kAlignBottom)
        startPos = self:linearLayoutView(taskView,startPos,node)
        local line = new(Image,"common/decoration/line_9.png")
        line:setSize(1,80)
        startPos = self:linearLayoutView(taskView,startPos+20,line)
        local text3 = new(Text, "战胜对手",width, height, align, fontName, 30, 245, 85, 40)
        startPos = self:linearLayoutView(taskView,startPos+20,text3)
    elseif data.type == ConsoleData.TASK_TYPE_EAT then
        local text1 = new(Text, "吃子",width, height, align, fontName, 24, 125, 80, 65)
        local text2 = new(Text, "任务",width, height, align, fontName, 24, 125, 80, 65)
        local node = new(Node)
        node:setSize(text1:getSize(),select(2,text1:getSize())+select(2,text2:getSize())+10)
        node:addChild(text1)
        text1:setAlign(kAlignTop)
        node:addChild(text2)
        text2:setAlign(kAlignBottom)
        startPos = self:linearLayoutView(taskView,startPos,node)
        local line = new(Image,"common/decoration/line_9.png")
        line:setSize(1,80)
        startPos = self:linearLayoutView(taskView,startPos+20,line)
        local chess = data.chess
        if type(chess) == "table" then
            for pc,num in pairs(chess) do
                local i = tonumber(pc) or 1
			    local fileStr = piece_resource_id[oppOffset + i] .. ".png"
 			    local file = resMap[fileStr]
                local pcImg = new(Image,file)
                local pcBg = new(Image,pcBgFile)
                pcBg:addChild(pcImg)
                pcBg:addPropScaleSolid(1,0.7,0.7,kCenterDrawing)
                startPos = self:linearLayoutView(taskView,startPos+10,pcBg)
                local numText = new(Text, string.format("X%d",num),width, height, align, fontName, 30, 245, 85, 40)
                startPos = self:linearLayoutView(taskView,startPos,numText)
                startPos = startPos + 30
            end
        end
    elseif data.type == ConsoleData.TASK_TYPE_PROTECT then
        local text1 = new(Text, "留子",width, height, align, fontName, 24, 125, 80, 65)
        local text2 = new(Text, "任务",width, height, align, fontName, 24, 125, 80, 65)
        local node = new(Node)
        node:setSize(text1:getSize(),select(2,text1:getSize())+select(2,text2:getSize())+10)
        node:addChild(text1)
        text1:setAlign(kAlignTop)
        node:addChild(text2)
        text2:setAlign(kAlignBottom)
        startPos = self:linearLayoutView(taskView,startPos,node)
        local line = new(Image,"common/decoration/line_9.png")
        line:setSize(1,80)
        startPos = self:linearLayoutView(taskView,startPos+20,line)
        local chess = data.chess
        if type(chess) == "table" then
            for pc,num in pairs(chess) do
                local i = tonumber(pc) or 0
			    local fileStr = piece_resource_id[myOffset + i] .. ".png"
 			    local file = resMap[fileStr]
                local pcImg = new(Image,file)
                local pcBg = new(Image,pcBgFile)
                pcBg:addChild(pcImg)
                pcBg:addPropScaleSolid(1,0.7,0.7,kCenterDrawing)
                startPos = self:linearLayoutView(taskView,startPos+10,pcBg)
                local numText = new(Text, string.format("X%d",num),width, height, align, fontName, 30, 245, 85, 40)
                startPos = self:linearLayoutView(taskView,startPos,numText)
                startPos = startPos + 30
            end
        end
    else
    end
end

function ConsoleReadyDialog:linearLayoutView(parent,startPos,child)
    if not parent or not child then return startPos end
    parent:addChild(child)
    local w,h = child:getSize()
    startPos = tonumber(startPos) or 0
    child:setPos(startPos)
    child:setAlign(kAlignLeft)
    return startPos + w
end