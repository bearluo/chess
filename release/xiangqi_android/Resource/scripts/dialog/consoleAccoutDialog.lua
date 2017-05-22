require(VIEW_PATH .. "console_account_dialog");
require(BASE_PATH.."chessDialogScene")

ConsoleAccoutDialog = class(ChessDialogScene,false)

function ConsoleAccoutDialog:ctor()
    super(self,console_account_dialog)

    self.mAnimView = self.m_root:getChildByName("anim_view")
    self.mAnimIcon = self.mAnimView:getChildByName("anim_icon")
    local x,y = self.mAnimView:getAbsolutePos()
    local w,h = self.mAnimView:getSize()
    self.mAnimView:setClip(x,y,w,h/2)
    self.mResultBg = self.m_root:getChildByName("result_bg")
    self.mCloseBtn = self.m_root:getChildByName("close_btn")
    self.mCloseBtn:setOnClick(self,self.dismiss)
    self.mTaskView = {}
    self.mStarAnim = {}
    for i=1,3 do
        self.mTaskView[i] = self.m_root:getChildByName("task_view_"..i)
    end
    self.mOfflineView = self.m_root:getChildByName("offline_view")
    self.mPlayAgainBtn = self.m_root:getChildByName("play_again_btn")
    self.mPlayNextBtn = self.m_root:getChildByName("play_next_btn")
end

function ConsoleAccoutDialog:show()
    self.super.show(self)
--    if UserInfo.getInstance():isLogin() then
        self.mOfflineView:setVisible(false)
        for i=1,3 do
            self.mTaskView[i]:setVisible(true)
        end
--    else
--        self.mOfflineView:setVisible(true)
--        for i=1,3 do
--            self.mTaskView[i]:setVisible(false)
--        end
--    end
    self.mAnimIcon:addPropRotate(1, kAnimRepeat, 3000, -1, 0, 360, kCenterDrawing)
end

function ConsoleAccoutDialog:dismiss()
    self.super.dismiss(self)
    self.mAnimIcon:removeProp(1)
end

function ConsoleAccoutDialog:setOnPlayAgainBtnClick(obj,func)
    self.mPlayAgainBtn:setOnClick(obj,func)
end
function ConsoleAccoutDialog:setOnPlayNextBtnClick(obj,func)
    self.mPlayNextBtn:setOnClick(obj,func)
end

function ConsoleAccoutDialog:setResult(isWin,finish)
    if isWin then
        self.mResultBg:setFile("animation/red_banners.png")
        self.mAnimIcon:setGray(false)
        self.mResultBg:getChildByName("txt"):setFile("common/decoration/win_icon.png")
        self.mPlayAgainBtn:setPos(-140)
        self.mPlayAgainBtn:setFile("common/button/dialog_btn_8_normal.png")
        self.mPlayNextBtn:setVisible(true)
    else
        self.mResultBg:setFile("animation/gray_banners.png")
        self.mAnimIcon:setGray(true)
        self.mResultBg:getChildByName("txt"):setFile("common/decoration/lose_icon.png")
        self.mPlayAgainBtn:setPos(0)
        self.mPlayAgainBtn:setFile("common/button/dialog_btn_4_normal.png")
        self.mPlayNextBtn:setVisible(false)
    end
    self:setConsoleLevelAndFinishTask(UserInfo.getInstance():getPlayingLevel(),finish)
end

function ConsoleAccoutDialog:setConsoleLevelAndFinishTask(level,finish)
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
    local finishTask = {}
    if finish then
        for i,taskId in ipairs(finish) do
            finishTask[taskId] = 1
        end
    end
    self:setTask(config.rule,self.mFlag,finishTask)
end

function ConsoleAccoutDialog:setTask(task,flag,finishTask)
    if not type(task) == "table" then return end
    for i=1,3 do
        if task[i..""] then
            self:initTaskViewByData(self.mTaskView[i],i,flag,task[i..""],finishTask[i])
        end
    end
end

--[Comment]
-- flag 红黑方
require("animation/starAnim")
function ConsoleAccoutDialog:initTaskViewByData(taskView,taskId,flag,data,finish)
    if not taskView or type(data) ~= "table" then return end
    taskId = tonumber(taskId) or 0
    taskView:removeAllChildren()
    local startPos = 0
    local myOffset = flag * 8
    local oppOffset = ( (flag + 1) * 8 - 1 ) % 16 + 1
    local resMap = UserSetInfo.getInstance():getChessRes()
    local starFile
    if finish then
        starFile = "common/decoration/star_dec_1.png"
    else
        starFile = "common/decoration/star_dec_2.png"
    end
    local star = new(Image,starFile)
    delete(self.mStarAnim[taskId])
    if finish then
        star:setFile("common/decoration/star_dec_2.png")
        self.mStarAnim[taskId] = new(StarAnim,star)
        self.mStarAnim[taskId]:play(taskId*100)
        self.mStarAnim[taskId]:setCallBack(self,function()
            star:setFile("common/decoration/star_dec_1.png")
        end)
    end

    startPos = self:linearLayoutView(taskView,startPos+10,star)
    local pcBgFile = resMap["piece.png"]
    if data.type == ConsoleData.TASK_TYPE_WIN then
        local text1 = new(Text, "过关",width, height, align, fontName, 24, 255, 250, 215)
        local text2 = new(Text, "任务",width, height, align, fontName, 24, 255, 250, 215)
        local node = new(Node)
        node:setSize(text1:getSize(),select(2,text1:getSize())+select(2,text2:getSize())+10)
        node:addChild(text1)
        text1:setAlign(kAlignTop)
        node:addChild(text2)
        text2:setAlign(kAlignBottom)
        startPos = self:linearLayoutView(taskView,startPos,node)
        local text3 = new(Text, "战胜对手",width, height, align, fontName, 30, 254, 183, 33)
        startPos = self:linearLayoutView(taskView,startPos+20,text3)
    elseif data.type == ConsoleData.TASK_TYPE_EAT then
        local text1 = new(Text, "吃子",width, height, align, fontName, 24, 255, 250, 215)
        local text2 = new(Text, "任务",width, height, align, fontName, 24, 255, 250, 215)
        local node = new(Node)
        node:setSize(text1:getSize(),select(2,text1:getSize())+select(2,text2:getSize())+10)
        node:addChild(text1)
        text1:setAlign(kAlignTop)
        node:addChild(text2)
        text2:setAlign(kAlignBottom)
        startPos = self:linearLayoutView(taskView,startPos,node)
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
                local numText = new(Text, string.format("X%d",num),width, height, align, fontName, 30, 254, 183, 33)
                startPos = self:linearLayoutView(taskView,startPos,numText)
                startPos = startPos + 30
            end
        end
    elseif data.type == ConsoleData.TASK_TYPE_PROTECT then
        local text1 = new(Text, "留子",width, height, align, fontName, 24, 255, 250, 215)
        local text2 = new(Text, "任务",width, height, align, fontName, 24, 255, 250, 215)
        local node = new(Node)
        node:setSize(text1:getSize(),select(2,text1:getSize())+select(2,text2:getSize())+10)
        node:addChild(text1)
        text1:setAlign(kAlignTop)
        node:addChild(text2)
        text2:setAlign(kAlignBottom)
        startPos = self:linearLayoutView(taskView,startPos,node)
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
                local numText = new(Text, string.format("X%d",num),width, height, align, fontName, 30, 254, 183, 33)
                startPos = self:linearLayoutView(taskView,startPos,numText)
                startPos = startPos + 30
            end
        end
    else
    end
end

function ConsoleAccoutDialog:linearLayoutView(parent,startPos,child)
    if not parent or not child then return startPos end
    parent:addChild(child)
    local w,h = child:getSize()
    startPos = tonumber(startPos) or 0
    child:setPos(startPos)
    child:setAlign(kAlignLeft)
    return startPos + w
end