require(MODEL_PATH.."room/roomScene");
EvaluationRoomScene = class(RoomScene);

EvaluationRoomScene.s_controls = 
{
}

EvaluationRoomScene.s_cmds = 
{
    updateCountDownView     = 1;
    startCountDownViewAnim  = 2;
    stopCountDownViewAnim   = 3;
    showEvaluationRoomAccountsDialog = 4;
}           

EvaluationRoomScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = EvaluationRoomScene.s_controls;
    self:initEvaluationRoom()
    self:startTime()
    call_native("BanDeviceSleep");
end 

require(DIALOG_PATH .. "evaluationTipsDialog")

EvaluationRoomScene.resume = function(self)
    RoomScene.resume(self);
    if not self.mEvaluationTipsDialog then
        self.mEvaluationTipsDialog = new(EvaluationTipsDialog)
        self.mEvaluationTipsDialog:show(EvaluationRoomController.s_timeset)
        self.mEvaluationTipsDialog:setDismissCallBack(self,self.startGame)
    end
end


EvaluationRoomScene.pause = function(self)
	RoomScene.pause(self);
	AnimKill.deleteAll();
    AnimTimeout.deleteAll();
    AnimJam.deleteAll();
end 


EvaluationRoomScene.dtor = function(self)
    call_native("OpenDeviceSleep");
    delete(self.m_setting_dialog);
	self:stopTime();
    self:stopCountDownViewAnim()
end 

----------------------------function---------------------------
EvaluationRoomScene.setAnimItemEnVisible = function(self,ret)
end

EvaluationRoomScene.resumeAnimStart = function(self,lastStateObj,timer)
end

EvaluationRoomScene.pauseAnimStart = function(self,newStateObj,timer)
end


EvaluationRoomScene.initEvaluationRoom = function(self)
    self:initView()
end

EvaluationRoomScene.initView = function(self)
    self.m_root_view = self.m_root;

    --設置背景圖片
    self.m_room_bg= self.m_root_view:getChildByName("room_bg");
    local bg = UserSetInfo.getInstance():getBgImgRes();
    self.m_room_bg:setFile(bg or "common/background/room_bg.png");
    
    self.m_room_time_text = self.m_root_view:getChildByName("room_time_bg"):getChildByName("room_time")
    self.m_back_btn = self.m_root_view:getChildByName("back_btn")
    self.m_back_btn:setOnClick(self,function()
        self:requestCtrlCmd(EvaluationRoomController.s_cmds.back_action)
    end)
    --棋盘部分
	self.m_board_view = self.m_root_view:getChildByName("board");
	local boardBg = self.m_board_view:getChildByName("board_view");
    -- 棋盘适配
    local w,h = self.m_board_view:getSize();
    self.m_down_view = self.m_root_view:getChildByName("down_model");--确定底边
    local bx,by = self.m_down_view:getUnalignPos();
    local x,y = self.m_board_view:getUnalignPos();
    local pw = self.m_root_view:getSize();
    local ph = by - y;
    if pw > w and RoomProxy.getInstance():getCurRoomType() ~= RoomConfig.ROOM_TYPE_WATCH_ROOM then
        local diffh = ph - h; -- 增加的高
        local diffw = pw - w; -- 增加的高
        local add = math.min(diffw,diffh);
        local scale = (w+add)/w;
	    self.m_board_view:setSize(w*scale,h*scale);
        local w,h = boardBg:getSize();
	    boardBg:setSize(w*scale,h*scale);
        self.m_board_bg = self.m_board_view:getChildByName("board_view"):getChildByName("board_bg");
        local w,h = self.m_board_bg:getSize();
	    self.m_board_bg:setSize(w*scale,h*scale);
    end
    -- 棋盘适配 end
	local w,h = boardBg:getSize();
	self.m_board = new(Board,w,h,self);
	self.m_board_view:addChild(self.m_board);
    
    self.m_board_bg = self.m_board_view:getChildByName("board_view"):getChildByName("board_bg");
    self.m_board_bg:setFile(UserSetInfo.getInstance():getBoardRes());
    
    self.m_up_view1 = new(OnlineUserInfoCommonView,OnlineUserInfoCommonView.ONLINE_UP)
    self.up_turn,self.up_breath1,self.up_breath2,self.m_up_gift_anim_view = self.m_up_view1:getAnimView()
    local ai = new(User)
    ai:setName("测评官")
    ai:setIconType(3)
    self.m_up_view1:resetIconView()
    self.m_up_view1:updateViewData(ai)
    self.m_up_view1:updateVipData()
    self.m_root_view:addChild(self.m_up_view1)

    self.m_down_view1 = new(OnlineUserInfoCommonView,OnlineUserInfoCommonView.ONLINE_DOWN)
    self.down_turn,self.down_breath1,self.down_breath2,self.m_down_gift_anim_view = self.m_down_view1:getAnimView()
    local userData = UserInfo.getInstance()
    self.m_down_view1:resetIconView()
    self.m_down_view1:updateViewData(userData)
    self.m_down_view1:updateVipData()
    self.m_down_view1:updataMoneyData(userData:getMoneyStr())

    self.m_root_view:addChild(self.m_down_view1)
end

EvaluationRoomScene.startGame = function(self)
    self:requestCtrlCmd(EvaluationRoomController.s_cmds.start_game)
end

EvaluationRoomScene.onEvaluationSettingBtnClick = function(self)
	if not self.m_setting_dialog then
		self.m_setting_dialog = new(SettingDialog);
	end
	self.m_setting_dialog:show()
end

EvaluationRoomScene.setBoradCode = function(self, flag, endType)
    self.m_close_flag = flag;
    self.m_game_end_type = endType;
end

EvaluationRoomScene.startTime = function(self)
	self:stopTime();
	self.m_timeAnim = new(AnimInt,kAnimLoop,0,1,1000,-1);
	self.m_timeAnim:setDebugName("Room.startTime.m_timeAnim");
	self.m_timeAnim:setEvent(self,self.timeRun);
end

EvaluationRoomScene.stopTime = function(self)
	if self.m_timeAnim then
		delete(self.m_timeAnim);
		self.m_timeAnim = nil;
	end
end

EvaluationRoomScene.timeRun = function(self)
	local t = os.date("*t");

	local time = string.format("%02d:%02d",t.hour,t.min);
	if t.sec%2 == 1 then
		time = string.format("%02d %02d",t.hour,t.min);
	end

	self.m_room_time_text:setText(time);
end

EvaluationRoomScene.chessMove = function(self,data)
    self:requestCtrlCmd(EvaluationRoomController.s_cmds.chess_move,data)
end
require(DIALOG_PATH .. "evaluationRoomAccountsDialog")
EvaluationRoomScene.showResultDialog = function(self)
    self:requestCtrlCmd(EvaluationRoomController.s_cmds.gameClose,self.m_close_flag,self.m_game_end_type)
end


function EvaluationRoomScene:showEvaluationRoomAccountsDialog(isUploadSuccess,score)
    score = tonumber(score) or 0
    if not self.mEvaluationRoomAccountsDialog then
        self.mEvaluationRoomAccountsDialog = new(EvaluationRoomAccountsDialog)
    end
    if self.m_close_flag == CHESS_MOVE_OVER_RED_WIN then
        self.mEvaluationRoomAccountsDialog:setShowType(EvaluationRoomAccountsDialog.s_showType.WIN)
    elseif self.m_close_flag == CHESS_MOVE_OVER_BLACK_WIN then
        self.mEvaluationRoomAccountsDialog:setShowType(EvaluationRoomAccountsDialog.s_showType.LOSE)
    else
        self.mEvaluationRoomAccountsDialog:setShowType(EvaluationRoomAccountsDialog.s_showType.DRAW)
    end
    self.mEvaluationRoomAccountsDialog:show()
    self.mEvaluationRoomAccountsDialog:reportDataResult(isUploadSuccess,UserInfo.getInstance():getScore(),score-UserInfo.getInstance():getScore())
    UserInfo.getInstance():setScore(score)
end

function EvaluationRoomScene:updateCountDownView(curMode,RedTimeset,BlackTimeset)
    self:updateCountDownUserView(self.m_up_view1,BlackTimeset)
    self:updateCountDownUserView(self.m_down_view1,RedTimeset)
end

function EvaluationRoomScene:updateCountDownUserView(view,timeset)
    local time1,time2 = EvaluationRoomScene.getTimeout1(timeset),EvaluationRoomScene.getTimeout2(timeset)
    local isOutTime = timeset.time1 <= 0
    if isOutTime then
        view:setTimeout2Name("读秒:")
    else
        view:setTimeout2Name("步时:")
    end
    view:updataTimeOutStr(time1,time2)
end

function EvaluationRoomScene:startCountDownViewAnim(curMode,curTime,totalTime)
    -- statrTime 总时间
    curTime = tonumber(curTime) or 0
    totalTime = tonumber(totalTime) or curTime
    if curMode == Board.MODE_RED then
        CountDownAnim.play(self.down_turn,curTime,totalTime)
    else
        CountDownAnim.play(self.up_turn,curTime,totalTime)
    end
end

function EvaluationRoomScene:stopCountDownViewAnim()
    CountDownAnim.stop()
end

EvaluationRoomScene.getTimeout1 = function(timeset)
    local time1 = timeset.time1
    return EvaluationRoomScene.getTimeoutStr(time1)
end

EvaluationRoomScene.getTimeout2 = function(timeset)
    local time1 = timeset.time1
    local time2 = timeset.time2
    local time3 = timeset.time3
	if time1 <= 0 then
		return EvaluationRoomScene.getTimeoutStr(time3)
	end
    return EvaluationRoomScene.getTimeoutStr(time2)
end

EvaluationRoomScene.getTimeoutStr = function(time)
    time = tonumber(time) or 0
	if time <= 0 then
		return "00:00";
	end
	return string.format("%02d:%02d", math.floor(time/60),time%60)
end
---------------------------- config -----------------------------

EvaluationRoomScene.s_controlConfig = 
{

};
--定义控件的触摸响应函数
EvaluationRoomScene.s_controlFuncMap =
{
};

EvaluationRoomScene.s_cmdConfig = 
{
    [EvaluationRoomScene.s_cmds.updateCountDownView]    = EvaluationRoomScene.updateCountDownView;
    [EvaluationRoomScene.s_cmds.startCountDownViewAnim] = EvaluationRoomScene.startCountDownViewAnim;
    [EvaluationRoomScene.s_cmds.stopCountDownViewAnim] = EvaluationRoomScene.stopCountDownViewAnim;
    [EvaluationRoomScene.s_cmds.showEvaluationRoomAccountsDialog] = EvaluationRoomScene.showEvaluationRoomAccountsDialog;
    
}