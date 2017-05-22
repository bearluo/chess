require(MODEL_PATH.."room/roomScene");
require("config/anim_config");
require("dialog/console_win_dialog")
require("dialog/setting_dialog");
require("dialog/chioce_dialog");
DapuRoomScene = class(RoomScene);

DapuRoomScene.s_controls = 
{

}

DapuRoomScene.s_cmds = 
{
    
}

DapuRoomScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = DapuRoomScene.s_controls;
    self:initDapuRoom()
end 
DapuRoomScene.resume = function(self)
    ChessScene.resume(self);
	self:start_action();
end;


DapuRoomScene.pause = function(self)
	ChessScene.pause(self);
end 


DapuRoomScene.dtor = function(self)
    ChatMessageAnim.deleteAll();
    delete(self.m_chioce_dialog);
end 



------------------------------------function----------------------------

DapuRoomScene.initDapuRoom = function(self)
    
	self.m_root_view = self.m_root;

    self.m_bg = self.m_root_view:getChildByName("room_bg");
    self.m_bg:setSize(self:getSize());

	self.dapu_room_title = self.m_root_view:getChildByName("dapu_room_title");
	self.dapu_title = self.dapu_room_title:getChildByName("dapu_title");

	--棋盘部分
	self.m_board_view = self.m_root_view:getChildByName("board");
	local boardBg = self.m_board_view:getChildByName("board_bg");
	local w,h = boardBg:getSize();
	self.m_board = new(Board,w,h,self,true);
    self.m_board:setRoomMoveEndClick(self,self.moveEndClick);
	self.m_board_view:addChild(self.m_board);

	self.m_room_menu = self.m_root_view:getChildByName("room_menu");
	self.m_load_chess_btn = self.m_room_menu:getChildByName("loadChess_btn");
	self.m_pre_step_btn = self.m_room_menu:getChildByName("pre_step_btn");
	self.m_next_step_btn = self.m_room_menu:getChildByName("next_step_btn");
	self.m_chess_step_text = self.m_room_menu:getChildByName("chess_step_text");

	self.m_load_chess_btn:setOnClick(self,self.loadChessData);
	self.m_pre_step_btn:setOnClick(self,self.preStep);
	self.m_next_step_btn:setOnClick(self,self.nextStep);

	self.currentChessData = UserInfo.getInstance():getDapuSelData();
	self.dapu_title:setText(self.currentChessData.fileName);	
	self.mvList = lua_string_split(self.currentChessData.mvStr,GameCacheData.chess_data_key_split);
	self.mvNum = 1;
	self:setChessStep(self.mvNum-1,#self.mvList);

	self.m_chioce_dialog = new(ChioceDialog);

end;


DapuRoomScene.start_action = function(self)
	local chess_map = nil;
	if self.currentChessData.chessString then
		chess_map = lua_string_split(self.currentChessData.chessString,MV_SPLIT);
	end
	if(self.currentChessData.flag == FLAG_RED) then
		self.m_board:newgame(Board.MODE_RED,self.currentChessData.fenStr,chess_map);
	else
		self.m_board:newgame(Board.MODE_BLACK,self.currentChessData.fenStr,chess_map);
	end
end


DapuRoomScene.loadChessData = function(self)
	StateMachine:getInstance():popState();
	StateMachine.getInstance():pushState(States.dapu,StateMachine.STYPE_CUSTOM_WAIT);
end


--上一步
DapuRoomScene.preStep = function(self)
	if self.mvNum > 1 then
        self:removeAnim();
		self.mvNum = self.mvNum - 1;
		self.m_board:undoMove();
		self:setChessStep(self.mvNum-1,#self.mvList);
	end
end

--下一步
DapuRoomScene.nextStep = function(self)
--	if lua_multi_click(1) then
--		return;
--	end
	if self.mvNum > #self.mvList then--结束判断
		self:showResultDialog();
	else
        self:removeAnim();
		local mv = tonumber(self.mvList[self.mvNum]);
		local code;
		if mv then
--            self.m_next_step_btn:setEnable(false);
--            self.m_pre_step_btn:setEnable(false);
			code = self.m_board:move(mv);
			self.mvNum = self.mvNum + 1;
			self:setChessStep(self.mvNum-1,#self.mvList);
		else
			self:showResultDialog();
			return;
		end
		--接下来判断是不是该挂了。。。
		if self.mvNum > #self.mvList and code and code ~= CHESS_MOVE_OVER_RED_WIN and code ~= CHESS_MOVE_OVER_BLACK_WIN then
			self:gameClose(nil,self.currentChessData.m_game_end_type);
		end
	end
end

DapuRoomScene.console_gameover = function(self,flag,endType)
	self:gameClose(flag,endType);
end

DapuRoomScene.gameClose = function(self,flag,endType)
	if endType == ENDTYPE_KILL then
		AnimKill.play(self.m_root_view,self,self.showResultDialog);
	elseif  endType == ENDTYPE_TIMEOUT then
		AnimTimeout.play(self.m_root_view,self,self.showResultDialog);
	elseif endType == ENDTYPE_JAM then
		AnimJam.play(self.m_root_view,self,self.showResultDialog);
	elseif endType == ENDTYPE_SURRENDER then
		local message = "认输!!!";
		ChatMessageAnim.play(self.m_root_view,3,message);
		self:showResultDialog();
	elseif endType == ENDTYPE_UNLEGAL then
		local message = "长打作负!!!";
		ChatMessageAnim.play(self.m_root_view,3,message);
		self:showResultDialog();
	elseif endType == ENDTYPE_UNCHANGE then
		local message = "双方不变作和!!!";
		ChatMessageAnim.play(self.m_root_view,3,message);
		self:showResultDialog();
	else
		self:showResultDialog();
	end
end

DapuRoomScene.setChessStep = function(self,curNum,maxNum)
	self.m_chess_step_text:setText("步数："..curNum.."/"..maxNum);
end


DapuRoomScene.setBoradCode = function(self,dieChess)
end
DapuRoomScene.setDieChess = function(self,dieChess)
end

DapuRoomScene.chessMove = function(self,data)
end

DapuRoomScene.onTouchUp = function(self)
	return false;
end

DapuRoomScene.getGameType = function(self)
	return ERROR_NUMBER;
end


DapuRoomScene.showResultDialog = function(self)
	if self.m_chioce_dialog:isShowing() then
		return;
	end

	local message = "已经演示完毕！";
	self.m_chioce_dialog:setMode(ChioceDialog.MODE_OK);
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:setPositiveListener();
	self.m_chioce_dialog:show();
end


DapuRoomScene.removeAnim = function(self)
    AnimCheck.deleteAll();
	AnimKill.deleteAll();
	AnimJam.deleteAll();
	AnimCapture.deleteAll();
	ShockAnim.deleteAll();
end