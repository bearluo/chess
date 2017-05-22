require(VIEW_PATH .. "money_room_game_end_dialog_view")

MoneyRoomGameEndDialog = class(ChessDialogScene,false)

function MoneyRoomGameEndDialog:ctor()
    super(self,money_room_game_end_dialog_view)
    self.mTopView       = self.m_root:getChildByName("top_view")
    self.mContentView   = self.m_root:getChildByName("content_view")
    self.mBoardBg       = self.mContentView:getChildByName("board_bg")
    self.mCloseBtn      = self.m_root:getChildByName("close_btn")
    self.mCloseBtn:setOnClick(self,self.dismiss)
    self.mUpUser        = self.m_root:getChildByName("online_result"):getChildByName("up_user")
    self.mDownUser      = self.m_root:getChildByName("online_result"):getChildByName("down_user")
    self.mSureBtn       = self.m_root:getChildByName("sure_btn")
    self.mSureBtn:setOnClick(self,self.onSureClick)
	local w,h = self.mContentView:getSize();
	self.mBoard = new(Board,w,h,self);
    self.mBoard:setPickable(false)
	self.mContentView:addChild(self.mBoard);
end

function MoneyRoomGameEndDialog:dtor()
    self:blurBehind(false)
end

function MoneyRoomGameEndDialog:show()
    self.super.show(self)
    self:blurBehind(true)
end

function MoneyRoomGameEndDialog:dismiss()
    self.super.dismiss(self)
    self:blurBehind(false)
end

-- 是否虚化房间背景
function MoneyRoomGameEndDialog:blurBehind(isBlur)
    local controller
    local view
    controller = StateMachine.getInstance():getCurrentController();
    if not controller then return end;
    view = controller:getRootView();
    if not view or not view:getID() then return end;

    if isBlur then
        local drawing = view:packDrawing(true);
        self.mBgPackDrawing = drawing;
        local blur = require("libEffect/shaders/blur");
        blur.applyToDrawing(self.mBgPackDrawing,1)
    elseif self.mBgPackDrawing then
        local common = require("libEffect/shaders/common");
        common.removeEffect(self.mBgPackDrawing);
        view:packDrawing(false);
        delete(self.mBgPackDrawing);
        self.mBgPackDrawing = nil;
    end
end

function MoneyRoomGameEndDialog:setContentView(chess_map,model)
    --设置棋盘图片
    self.mBoardBg:setFile(UserSetInfo.getInstance():getBoardRes());
    self.mBoard:synchroBoard(chess_map,model)
end

function MoneyRoomGameEndDialog:setWinView()
    self.mTopView:removeAllChildren(true)
    local animView = new(AnimWin);
    animView:setAlign(kAlignTop);
    self.mTopView:addChild(animView);
    animView:play();  
end

function MoneyRoomGameEndDialog:setLoseView()
    self.mTopView:removeAllChildren(true)
    local animView = new(AnimLose);
    animView:setAlign(kAlignTop);
    self.mTopView:addChild(animView);
    animView:play();  
end

function MoneyRoomGameEndDialog:setUpUser(user,time,winId)
    self:setUser(self.m_root:getChildByName("online_result"):getChildByName("up_user"),user,time,winId)
end

function MoneyRoomGameEndDialog:setDownUser(user,time,winId)
    self:setUser(self.m_root:getChildByName("online_result"):getChildByName("down_user"),user,time,winId)
end

function MoneyRoomGameEndDialog:setUser(view,user,time,winId)
    local bg = view:getChildByName("bg")
    local headView = bg:getChildByName("icon_frame")
    local nick = bg:getChildByName("nick")
    local score = bg:getChildByName("score")
    local flag_img = bg:getChildByName("flag_img")
    local level = bg:getChildByName("level")
    local time_view = bg:getChildByName("time_view")
    local used_time = time_view:getChildByName("used_time")

    headView:removeAllChildren(true)
    local mask = new(Mask,UserInfo.DEFAULT_ICON[1],"hall/icon_frame_mask.png");
    local w,h = headView:getSize()
    mask:setSize(w-5,h-5)
    mask:setAlign(kAlignCenter)
    headView:addChild(mask)
    if iconType == -1 then
        mask:setUrlImage(user:getIcon(),UserInfo.DEFAULT_ICON[1]);
    else
        mask:setFile(UserInfo.DEFAULT_ICON[user:getIconType()] or UserInfo.DEFAULT_ICON[1]);
    end
    nick:setText(user:getName())
    score:setText("积分:" .. user:getScore())
    if winId == user:getUid() then
        flag_img:setFile("dialog/win.png")
        time_view:setColor(255,220,0)
    else
        flag_img:setFile("dialog/lose.png")
        time_view:setColor(120,120,120)
    end
    level:setFile( string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevelByScore(user:getScore())));
    used_time:setText( os.date("%M:%S", math.floor(time)))
end

function MoneyRoomGameEndDialog:onSureClick()
    if type(self.mSureFunc) == "function" then
        self.mSureFunc(self.mSureObj)
    end
    self:dismiss()
end

function MoneyRoomGameEndDialog:setOnSureClick(obj,func)
    self.mSureFunc = func
    self.mSureObj = obj
end