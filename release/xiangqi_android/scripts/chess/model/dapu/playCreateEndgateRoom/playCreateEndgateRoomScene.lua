require(MODEL_PATH.."/room/roomScene");
require(MODEL_PATH.."room/board")
PlayCreateEndgateRoomScene = class(RoomScene);

PlayCreateEndgateRoomScene.s_controls = 
{
}

PlayCreateEndgateRoomScene.s_cmds = 
{
    startGame = 1;
    showWinDialog = 2;
    showEndingResultDialog = 3;
    setGameOver = 4;
    updateView = 5;
    revive = 6;
    console_gameover = 7;
    dismissTipsNote = 8;
    setMyTurn = 9;
    dismissTips = 10;
    show_submove_text = 11;
    show_tips_text = 12;
    setSubNum = 13;
    showTipsNote = 14;
    preStep = 15;
    use_tip = 16;
    use_undoMove = 17;
    use_revive = 18;
    update_account_rank = 19;
    show_reward = 20;
    set_start_btn_visible = 21;
    update_step_text = 22;
    show_result_dialog = 23;
    update_min_step_text = 24;
    save_chess = 25;
}

PlayCreateEndgateRoomScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = PlayCreateEndgateRoomScene.s_controls;
end 

PlayCreateEndgateRoomScene.resume = function(self)
    ChessScene.resume(self);
    self:init();
end


PlayCreateEndgateRoomScene.pause = function(self)
	ChessScene.pause(self);
	AnimKill.deleteAll();
    AnimTimeout.deleteAll();
    AnimJam.deleteAll();
end 


PlayCreateEndgateRoomScene.dtor = function(self)
    if self.m_noticTipAnim then
        delete(self.m_noticTipAnim);
    end
    delete(self.m_setting_dialog);
    delete(self.m_result_dialog);
    delete(self.m_collection_chioce_dialog);
    delete(self.m_anim_start);
    delete(self.m_anim_end);
end 

----------------------------------- function ----------------------------
PlayCreateEndgateRoomScene.init = function(self)
	self.m_root_view = self.m_root;
    local data = kEndgateData:getPlayCreateEndingData();
	self.m_ending_room_title = self.m_root_view:getChildByName("ending_title_view");
	self.m_ending_title_bg = self.m_ending_room_title:getChildByName("ending_title_bg");
	self.m_ending_title = self.m_ending_title_bg:getChildByName("ending_title");
    local title = data.booth_title or ""
    if ToolKit.utfstrlen(title) > 4 then
        title = ToolKit.GetShortName(title,7);
    end
    self.m_ending_title:setText(title);

	self.m_ending_note_bg = self.m_ending_room_title:getChildByName("ending_room_note_bg");
	self.m_ending_note_text = self.m_ending_note_bg:getChildByName("ending_room_note_text");  --提示信息

    self.m_menu_bg = self.m_root_view:getChildByName("menu_bg");
    self.m_report_btn =self.m_menu_bg:getChildByName("report_btn");
    self.m_report_btn:setOnClick(self,function(self)
        self:requestCtrlCmd(PlayCreateEndgateRoomController.s_cmds.report_ending);
    end);
	--棋盘部分
	self.m_board_view = self.m_root_view:getChildByName("ending_board");

    -- 棋盘适配
    local w,h = self.m_board_view:getSize();
    --确定底边
    local bx,by = self.m_menu_bg:getUnalignPos();
    local x,y = self.m_board_view:getUnalignPos();
    local pw = self.m_root:getSize();
    local ph = by - y;
    if pw > w then
        local diffh = ph - h; -- 增加的高
        local diffw = pw - w; -- 增加的高
        local add = math.min(diffw,diffh);
        local scale = (w+add)/w;
	    self.m_board_view:setSize(w*scale,h*scale);
	    local boardBg = self.m_board_view:getChildByName("ending_board_bg");
        local w,h = boardBg:getSize();
	    boardBg:setSize(w*scale,h*scale);
    end
    -- 棋盘适配 end

    self.m_start_btn = self.m_menu_bg:getChildByName("start_btn");
    self.m_start_btn_title = self.m_start_btn:getChildByName("title");
    local fpconfig = UserInfo.getInstance():getFPcostMoney() or {};
    self.m_start_btn_title:setText((fpconfig.buy_booth or "").."金币挑战");
    self.m_start_btn:setOnClick(self,self.buyEnding);
	local boardBg = self.m_board_view:getChildByName("ending_board_bg");
	local w,h = self.m_board_view:getSize();
	self.m_board = new(Board,w,h,self.m_controller);
	self.m_board_view:addChild(self.m_board);

	self.m_room_menu_view = self.m_root_view:getChildByName("ending_room_menu");

--    self:setStartBtnVisible(true);

    -- 用户信息
    self.m_ending_room_info = self.m_root_view:getChildByName("ending_room_info");
    self.m_min_step_text = self.m_ending_room_info:getChildByName("min_step_text");
    self.m_min_step_text:setText("暂无");
    self.m_step_text = self.m_ending_room_info:getChildByName("step_text");
    self.m_step_text:setText("目前步数:暂无");

    local func =  function(view,enable)
        local tip = view:getChildByName("tip_bg");
        if tip then
            if not enable then
                tip:setVisible(true);
                tip:addPropTransparency(1, kAnimNormal, 100, 1000, 0, 1);
            else
                tip:setVisible(false);
                tip:removeProp(1);
            end
        end
    end


	--悔棋
	self.m_undo_btn = self.m_room_menu_view:getChildByName("ending_undo_btn");
    self.m_undo_btn:setPickable(false);
    self.m_undo_btn:setGray(true);
	self.m_undo_num_bg = self.m_undo_btn:getChildByName("ending_undo_num_bg");
	self.m_undo_num_text = self.m_undo_num_bg:getChildByName("ending_undo_num_text");
	self.m_undo_btn:setOnClick(self,self.undoMove);
    self.m_undo_btn:setOnTuchProcess(self.m_undo_btn,func);


	--提示
	self.m_tip_btn = self.m_room_menu_view:getChildByName("ending_tips_btn");
	self.m_tip_num_bg = self.m_tip_btn:getChildByName("ending_tips_num_bg");
	self.m_tip_num_text = self.m_tip_num_bg:getChildByName("ending_tips_num_text");
	self.m_tip_btn:setOnClick(self,self.tip_action);
    self.m_tip_btn:setOnTuchProcess(self.m_tip_btn,func);
    self.m_tip_btn:setPickable(false);
    self.m_tip_btn:setGray(true);

	--起死回生
--	self.m_reborn_btn = self.m_room_menu1_bg:getChildByName("ending_reborn_btn");
--	self.m_reborn_num_bg = self.m_reborn_btn:getChildByName("ending_reborn_num_bg");
--	self.m_reborn_num_text = self.m_reborn_num_bg:getChildByName("ending_reborn_num_text");
--	self.m_reborn_btn:setOnClick(self,self.revive);
--    self.m_reborn_btn:setOnTuchProcess(self.m_reborn_btn,func);

	--提示是否有变招和注释
	self.m_ending_submove_img = self.m_room_menu_view:getChildByName("ending_submove_img");
    self.m_ending_submove_img:setEventTouch(self,self.onSubmoveImgClick);
	self.m_ending_submove_tips_text = self.m_ending_submove_img:getChildByName("ending_submove_img_text");
	self.m_ending_tips_text = self.m_ending_submove_img:getChildByName("ending_tips_img_text");
	self:dismissTips();

	self.m_submove_view = self.m_room_menu_view:getChildByName("ending_submove_view_bg");
	self.m_select1_btn = self.m_submove_view:getChildByName("ending_submove1_btn");
	self.m_select2_btn = self.m_submove_view:getChildByName("ending_submove2_btn");
	self.m_select3_btn = self.m_submove_view:getChildByName("ending_submove3_btn");
	self:dismissSubMoveTips();


    self.m_select1_btn:setOnClick(self,self.subMove1);
	self.m_select2_btn:setOnClick(self,self.subMove2);
	self.m_select3_btn:setOnClick(self,self.subMove3);

    -- 换边
    self.mChangeFlagBtn = self.m_room_menu_view:getChildByName("change_flag_btn");
    self.mChangeFlagBtn:setOnClick(self,self.showChangeFlagDialog);



	self.m_restart_btn = self.m_root_view:getChildByName("ending_room_restart_btn");
	self.m_restart_btn:setOnClick(self,self.restart_action);
    self.m_restart_btn:setPickable(false);
    self.m_restart_btn:setGray(true);

	self.m_set_btn = self.m_root_view:getChildByName("ending_room_set_btn");
	self.m_set_btn:setOnClick(self,self.setting_action);   

	self.m_leave_btn = self.m_ending_room_title:getChildByName("ending_room_leave_btn");
	self.m_leave_btn:setOnClick(self,self.back_action);  
    self.m_leave_btn:setTransparency(0.6);
    
	self.m_share_btn = self.m_root_view:getChildByName("ending_share_btn");
    if kPlatform == kPlatformIOS then
        if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then 
            self.m_share_btn:setVisible(true);
        else
            self.m_share_btn:setVisible(false);
        end;
    else
        self.m_share_btn:setVisible(true);
    end;
	self.m_share_btn:setOnClick(self,self.shareInfo);
    self.m_share_btn:setPickable(false);
    self.m_share_btn:setGray(true);

end

PlayCreateEndgateRoomScene.buyEnding = function(self)
    self:requestCtrlCmd(PlayCreateEndgateRoomController.s_cmds.buy_ending);
end

PlayCreateEndgateRoomScene.setStartBtnVisible = function(self,visible)
--    self.m_start_btn:setVisible(visible);
    visible = visible and true or false;
    self.m_menu_bg:setVisible(visible);
    self.m_board_view:setPickable(not visible);
    self.mChangeFlagBtn:setPickable(not visible);
end


PlayCreateEndgateRoomScene.setAnimItemEnVisible = function(self,ret)
end

PlayCreateEndgateRoomScene.resumeAnimStart = function(self,lastStateObj,timer)
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;
    delete(self.m_anim_start);
    self.m_anim_start = new(AnimInt,kAnimNormal,0,1,delay,-1);
    if self.m_anim_start then
        self.m_anim_start:setEvent(self,function()
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end
            delete(self.m_anim_start);
        end);
    end
end

PlayCreateEndgateRoomScene.pauseAnimStart = function(self,newStateObj,timer)
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;
    delete(self.m_anim_end);
    self.m_anim_end = new(AnimInt,kAnimNormal,0,1,delay,-1)
    if self.m_anim_end then
        self.m_anim_end:setEvent(self,function()
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end
            delete(self.m_anim_end);
        end);
    end
end

--点击隐藏提示
PlayCreateEndgateRoomScene.onSubmoveImgClick = function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
    if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
        self:dismissTips();
    end
end

--隐藏提醒
PlayCreateEndgateRoomScene.dismissTips = function(self)
	self.m_ending_submove_img:setVisible(false);
end

PlayCreateEndgateRoomScene.dismissSubMoveTips = function(self)
	self.m_select1_btn:setVisible(false);
    self.m_select2_btn:setVisible(false);
    self.m_select3_btn:setVisible(false);
	self.m_submove_view:setVisible(false);
end

PlayCreateEndgateRoomScene.tips_text = {"帮你恢复到前一步","帮你走出当前局面最佳的一步","帮你回到脱谱前一步"};

PlayCreateEndgateRoomScene.updateStepText = function(self,step)
    self.m_step_text:setText("目前步数:"..(step or 0).."步");
end

PlayCreateEndgateRoomScene.updateMinStepText = function(self,step)
    self.m_min_step_text:setText( (step or 0).."步");
end

PlayCreateEndgateRoomScene.startGame = function(self,move)
 
    self.m_undo_btn:setPickable(true);
    self.m_undo_btn:setGray(false);
    self.m_tip_btn:setPickable(true);
    self.m_tip_btn:setGray(false);
    self.m_restart_btn:setPickable(true);
    self.m_restart_btn:setGray(false);
    self.m_share_btn:setPickable(true);
    self.m_share_btn:setGray(false);
    self:updateStepText(0);
    local data = kEndgateData:getPlayCreateEndingData() or {};
    local is_pass = tonumber(data.is_pass) or 0;
    if is_pass ~= 0 and move and type(move) == "table" and #move > 1 then
         self:updateMinStepText(#move-1);
    end

	self:showUndoNum();
	self:showTipsNum();
	self:showRebornNum();

	self:dismissTips();
end

PlayCreateEndgateRoomScene.showWinDialog = function(self)
--    require("dialog/ending_win_dialog");
--    require("dialog/account_dialog");
--    if not self.m_ending_win_dialog then
--		self.m_ending_win_dialog = new(AccountDialog,self);
--	end
--    self.m_endgate_close_flag = 1;
--    local var = {[1] = true, [2] = 2};
--	self.m_ending_win_dialog:show(self,self.m_endgate_close_flag,var,GAME_TYPE_OFFLINE);
--    ToolKit.addEngateLogCount(self.m_ending_win_dialog.m_root_view); 
--    self:updateInfo();
end

PlayCreateEndgateRoomScene.showEndingResultDialog = function(self,flag)
--    require("dialog/ending_result_dialog");
--    if not self.m_ending_result_dialog then
--		self.m_ending_result_dialog = new(EndingResultDialog,self.m_controller);
--	end
--	self.m_ending_result_dialog:setMode(mode);
--	self.m_ending_result_dialog:show();
--    require("dialog/account_dialog");
--    if not self.m_ending_result_dialog then
--		self.m_ending_result_dialog = new(AccountDialog,self);
--	end
--    self.m_endgate_close_flag = flag;
--    local var = {[1] = false, [2] = 2};
--	self.m_ending_result_dialog:show(self,self.m_endgate_close_flag,var,GAME_TYPE_OFFLINE);
--    self:updateInfo();  -- 失败不上传数据
end

-- 保存棋局
PlayCreateEndgateRoomScene.saveChess = function(self,endType)
    self.m_endgate_close_flag = endType;
end

PlayCreateEndgateRoomScene.collection = function(self)
-- 收藏弹窗
    if not self.m_collection_chioce_dialog then
        self.m_collection_chioce_dialog = new(ChioceDialog)
    end;
    self.m_collection_chioce_dialog:setMode(ChioceDialog.MODE_SHOUCANG);  
    self.m_save_cost = UserInfo.getInstance():getFPcostMoney().save_manual;  
    self.m_collection_chioce_dialog:setMessage("是否花费"..(self.m_save_cost or 500) .."金币收藏当前棋谱？");
    self.m_collection_chioce_dialog:setPositiveListener(self, self.saveChesstoMysave);
    self.m_collection_chioce_dialog:show();
end

PlayCreateEndgateRoomScene.saveChesstoMysave = function(self)
    local uid = UserInfo.getInstance():getUid()
    local data = kEndgateData:getPlayCreateEndingData();
    local title = data.booth_title or ""

    local mvData = {};
    mvData.id = time;
    mvData.mid = uid;
    mvData.mnick = UserInfo.getInstance():getName();
    mvData.icon_type = UserInfo.getInstance():getIconType();
    mvData.icon_url = UserInfo.getInstance():getIcon();
    mvData.fileName = "残局回放";
    mvData.red_mid = UserInfo.getInstance():getUid() or 0;
    mvData.black_mid = 0;
    mvData.down_user = UserInfo.getInstance():getUid();
    mvData.red_mnick = UserInfo.getInstance():getName();
    mvData.black_mnick = title;
    mvData.red_icon_url = UserInfo.getInstance():getIcon();
    mvData.red_icon_type = UserInfo.getInstance():getIconType();
    mvData.black_icon_url = nil;
    mvData.black_icon_type = 1;
    mvData.red_level = UserInfo.getInstance():getDanGradingLevel();
    mvData.black_level = 0;
    mvData.red_score = UserInfo.getInstance():getScore();
    mvData.black_score = 0;
    mvData.win_flag = self.m_endgate_close_flag;
    mvData.end_type = 1;
    mvData.flag = FLAG_RED;
    mvData.end_fen = self.m_board.toFen(self.m_board:to_chess_map(),true);
    mvData.manual_type = "5";
    mvData.start_fen = GameCacheData.getInstance():getString(GameCacheData.DAPU_LAST_BORAD_FEN,GameCacheData.NULL);
    mvData.chessString = GameCacheData.getInstance():getString(GameCacheData.DAPU_LAST_CHESS_STR,GameCacheData.NULL);
    mvData.move_list = table.concat(self.m_board:to_mvList(),GameCacheData.chess_data_key_split);
    mvData.createrName = "";
	mvData.time = os.date("%Y/%m/%d",time)
    self:requestCtrlCmd(PlayCreateEndgateRoomController.s_cmds.save_mychess,self.m_collection_chioce_dialog:getCheckState(),mvData);
end

PlayCreateEndgateRoomScene.updateInfo = function(self)

	--保存最新关卡
	kEndgateData:setLatestGate();

	--上传进度
	local tid = kEndgateData:getGateTid();
	local sort = kEndgateData:getGateSort()+1 ;

--	local propinfo = {};
--	local uid = UserInfo.getInstance():getUid();
--	propinfo["1"] = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LIFE_NUM .. uid,ENDING_LIFE_NUM);
--	propinfo["2"]= GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_UNDO_NUM .. uid,ENDING_UNDO_NUM);
--	propinfo["3"]= GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_TIPS_NUM .. uid,ENDING_TIPS_NUM);
--	propinfo["4"] = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_REVIVE_NUM .. uid,ENDING_REVIVE_NUM);
--	propinfo["5"] = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LIFE_LIMIT .. uid,ENDING_LIFELIMIT_NUM);

	local post_data = {};
	post_data.tid = tid;
	post_data.pos = sort;
	post_data.id = kEndgateData:getBoardTableId(); -------- 这个值不知道干嘛的
--	post_data.propinfo = propinfo;
    HttpModule.getInstance():execute(HttpModule.s_cmds.uploadGateInfo,post_data);
end


PlayCreateEndgateRoomScene.onUploadAccountRank = function(self, proportion,leading_number)
    if self.m_ending_win_dialog and self.m_ending_win_dialog:getVisible() then
        self.m_ending_win_dialog:setAccountRank(proportion,leading_number);
    elseif self.m_ending_result_dialog and self.m_ending_result_dialog:getVisible() then
        self.m_ending_result_dialog:setAccountRank(proportion,leading_number);
    end;
end;


PlayCreateEndgateRoomScene.onShowReward = function(self, result)
    if self.m_ending_win_dialog and self.m_ending_win_dialog:getVisible() then
        self.m_ending_win_dialog:showReward(result);
    end;
end;



PlayCreateEndgateRoomScene.setGameOver = function(self,flag,boradCode)
	print_string("PlayCreateEndgateRoomScene.setGameOver");

	if boradCode and boradCode ~= FLAG_RED then
	end

	if flag then
		self.m_restart_btn:setPickable(true);
--		self.m_reborn_btn:setPickable(true);
		self.m_undo_btn:setPickable(false);
		self.m_tip_btn:setPickable(false);

        
		self.m_restart_btn:setGray(false);
--		self.m_reborn_btn:setGray(false);
		self.m_undo_btn:setGray(true);
		self.m_tip_btn:setGray(true);

		self:dismissTipsNote();
	end
end


PlayCreateEndgateRoomScene.dismissTipsNote = function(self)
	self.m_ending_note_bg:setVisible(false);
	--self.m_tip_btn:setEnable(true);
end

PlayCreateEndgateRoomScene.updateView = function(self)
    self:showUndoNum();
    self:showTipsNum();
    self:showRebornNum();
end

--展示悔棋次数
PlayCreateEndgateRoomScene.showUndoNum = function(self)
	local num = UserInfo.getInstance():getUndoNum();
	self.m_undo_num_text:setText(num);

	print_string("PlayCreateEndgateRoomScene.showUndoNum num =  " .. num);
end

--展示提示次数
PlayCreateEndgateRoomScene.showTipsNum = function(self)
	local num = UserInfo.getInstance():getTipsNum();
    self.m_tip_num_text:setText(num);

	print_string("PlayCreateEndgateRoomScene.showTipsNum num =  " .. num);
end

--展示起死回生次数
PlayCreateEndgateRoomScene.showRebornNum = function(self)
--	local num = UserInfo.getInstance():getReviveNum();
--	self.m_reborn_num_text:setText(num);

--	print_string("PlayCreateEndgateRoomScene.showRebornNum num =  " .. num);
end
----------------------------------- click -------------------------------

PlayCreateEndgateRoomScene.shareInfo = function(self)
    self:requestCtrlCmd(PlayCreateEndgateRoomController.s_cmds.shareUrl);
end

PlayCreateEndgateRoomScene.loadNextGate = function(self)
    self:requestCtrlCmd(PlayCreateEndgateRoomController.s_cmds.loadNextGate);
end

PlayCreateEndgateRoomScene.undoMove = function(self)
	self:requestCtrlCmd(PlayCreateEndgateRoomController.s_cmds.onEventStat,WULING_ENDGIN_ROOM_MODEL_UNDO_BTN);

    self:requestCtrlCmd(PlayCreateEndgateRoomController.s_cmds.undoMove);
end

PlayCreateEndgateRoomScene.use_undoMove = function(self)
	self:showUndoNum();
	self:dismissSubMoveTips();
	self:dismissTipsNote();
end

--设置是否是我走
PlayCreateEndgateRoomScene.setMyTurn = function(self,is_my_trun,isGameOver)
	self.m_undo_btn:setPickable(is_my_trun);
	self.m_tip_btn:setPickable(is_my_trun);
	self.m_restart_btn:setPickable(is_my_trun);
--	self.m_reborn_btn:setPickable(is_my_trun);
    
	self.m_undo_btn:setGray(not is_my_trun);
	self.m_tip_btn:setGray(not is_my_trun);
	self.m_restart_btn:setGray(not is_my_trun);
--	self.m_reborn_btn:setGray(not is_my_trun);

	if not is_my_trun then
		self:dismissSubMoveTips();
	end

	if isGameOver then
		self.m_undo_btn:setPickable(false);
		self.m_tip_btn:setPickable(false);
		self.m_restart_btn:setPickable(true);
--		self.m_reborn_btn:setPickable(true);
        
		self.m_undo_btn:setGray(true);
		self.m_tip_btn:setGray(true);
		self.m_restart_btn:setGray(false);
--		self.m_reborn_btn:setGray(false);

	end
end


PlayCreateEndgateRoomScene.tip_action = function(self)
    local data = kEndgateData:getPlayCreateEndingData();
    if tonumber(data.is_pass) == 0 then
        ChessToastManager.getInstance():showSingle("该残局还没有人通关");
        return ;
    end
	self:requestCtrlCmd(PlayCreateEndgateRoomController.s_cmds.onEventStat,WULING_ENDGIN_ROOM_MODEL_TIPS_BTN);

    self:requestCtrlCmd(PlayCreateEndgateRoomController.s_cmds.tip_action);
end

PlayCreateEndgateRoomScene.use_tip = function(self)
	self:showTipsNum();
	self.m_tip_btn:setPickable(false);
	self.m_tip_btn:setGray(true);
	self:dismissTips();
end

--提示有变招
PlayCreateEndgateRoomScene.setSubNum = function(self,num)
	self:dismissTips();
	if num > 0 then
		self.m_select1_btn:setVisible(true);
		self.m_ending_submove_img:setVisible(true);
		self.m_submove_view:setVisible(true);

		self.m_tip_btn:setPickable(false);
	    self.m_tip_btn:setGray(true);
	end

	if num > 1 then
		self.m_select2_btn:setVisible(true);
	end

	if num > 2 then
		self.m_select3_btn:setVisible(true);
	end
end

--显示注释
PlayCreateEndgateRoomScene.showTipsNote = function(self,message)
	self.m_ending_note_text:setText(message);
	self.m_ending_note_bg:setVisible(true);
	self.m_tip_btn:setPickable(false);
	self.m_tip_btn:setGray(true);

	self:dismissTips();
end

--启死回生
PlayCreateEndgateRoomScene.revive = function(self)
--	self:requestCtrlCmd(PlayCreateEndgateRoomController.s_cmds.onEventStat,ENDGIN_ROOM_MODEL_REBORN_BTN);
--	--self.m_game_over = false;

--    self:requestCtrlCmd(PlayCreateEndgateRoomController.s_cmds.revive);

end

PlayCreateEndgateRoomScene.use_revive = function(self)
	self:showRebornNum();
end

--上一步 .. 悔棋
PlayCreateEndgateRoomScene.preStep = function(self)
	self:dismissTips();
end


PlayCreateEndgateRoomScene.subMove1 = function(self)
	
	local move = self:requestCtrlCmd(PlayCreateEndgateRoomController.s_cmds.subMove1);

	if not move then
		print_string("PlayCreateEndgateRoomScene.subMove1 but not move");
		return
	end

	if move.comment then
		local message = move.comment;
		self:showTipsNote(message);
	end

	self.m_board:book_tips(move);

	self:dismissSubMoveTips();
end

PlayCreateEndgateRoomScene.subMove2 = function(self)

	local move = self:requestCtrlCmd(PlayCreateEndgateRoomController.s_cmds.subMove2);

	if not move then
		print_string("PlayCreateEndgateRoomScene.subMove2 but not branch.movelist");
		return
	end


	if move.comment then
		local message = move.comment;
		self:showTipsNote(message);
	end

	self.m_board:book_tips(move);
	self:dismissSubMoveTips();

end

PlayCreateEndgateRoomScene.subMove3 = function(self)

	local move = self:requestCtrlCmd(PlayCreateEndgateRoomController.s_cmds.subMove3);

	if not move then
		print_string("PlayCreateEndgateRoomScene.subMove3 but not branch.movelist");
		return
	end


	if move.comment then
		local message = move.comment;
		self:showTipsNote(message);
	end

	self.m_board:book_tips(move);
	self:dismissSubMoveTips();
end

PlayCreateEndgateRoomScene.restart_action = function(self)
	self:requestCtrlCmd(PlayCreateEndgateRoomController.s_cmds.onEventStat,WULING_ENDGIN_ROOM_MODEL_RESTART_BTN);

	self:requestCtrlCmd(PlayCreateEndgateRoomController.s_cmds.restart);
end

PlayCreateEndgateRoomScene.setting_action = function(self)
	self:requestCtrlCmd(PlayCreateEndgateRoomController.s_cmds.onEventStat,WULING_ENDGIN_ROOM_MODEL_SET_BTN);

	if not self.m_setting_dialog then
        require("dialog/setting_dialog");
		self.m_setting_dialog = new(SettingDialog);
	end
	self.m_setting_dialog:show();
end

PlayCreateEndgateRoomScene.exitRoom = function(self)
    self:back_action();
end;




PlayCreateEndgateRoomScene.back_action = function(self,data)
	self:requestCtrlCmd(PlayCreateEndgateRoomController.s_cmds.onEventStat,WULING_ENDGIN_ROOM_MODEL_EXIT_BTN);
	self:requestCtrlCmd(PlayCreateEndgateRoomController.s_cmds.onBack);
end

PlayCreateEndgateRoomScene.show_submove_text = function(self)
	self.m_ending_submove_tips_text:setVisible(true);
	self.m_ending_tips_text:setVisible(false);
	self.m_ending_submove_img:setVisible(true);
end

PlayCreateEndgateRoomScene.show_tips_text = function(self)
	self.m_ending_submove_tips_text:setVisible(false);
	self.m_ending_tips_text:setVisible(true);
	self.m_ending_submove_img:setVisible(true);
end

PlayCreateEndgateRoomScene.console_gameover = function(self,code,endType)
    self.m_board:console_gameover(code,endType);
end

PlayCreateEndgateRoomScene.ShowResultDialog = function(self,isWin,prize_pool,pass_num)
    if not self.m_result_dialog then
        require(DIALOG_PATH .. "play_create_ending_result_dialog");
        self.m_result_dialog = new(PlayCreateEndingResultDialog);
        self.m_result_dialog:setCollectionListener(self,self.collection);
    end
    local data = kEndgateData:getPlayCreateEndingData() or {};
    local is_pass = tonumber(data.is_pass) or 0;
    self.m_result_dialog:setBoradView(self.m_board_view);
    if isWin then
        self.m_result_dialog:setMode(PlayCreateEndingResultDialog.MODE_NOR,"分享","重来");
        if prize_pool == 0 then
            self.m_result_dialog:setWinText("","","您是第" .. ( pass_num or 0 ) .. "位通关棋友");
        else
            self.m_result_dialog:setWinText("您是第1位通关棋友","+" .. (prize_pool or 0) .. "金币","");
        end

        self.m_result_dialog:setNegativeListener(self,function()
                self:shareInfo();
            end);
        self.m_result_dialog:setPositiveListener(self,function()
                self.m_result_dialog:dismiss();
                self:requestCtrlCmd(PlayCreateEndgateRoomController.s_cmds.restart);
            end);

    else
        self.m_result_dialog:setLoseText();
        if is_pass == 0 then
            self.m_result_dialog:setMode(PlayCreateEndingResultDialog.MODE_NOR,"无解举报","重来");
            self.m_result_dialog:setNegativeListener(self,function()
                self.m_result_dialog:dismiss();
                self:requestCtrlCmd(PlayCreateEndgateRoomController.s_cmds.report_ending);
            end);
        else
            self.m_result_dialog:setMode(PlayCreateEndingResultDialog.MODE_SURE,"重来");
            self.m_result_dialog:setNegativeListener(self,function()
                self.m_result_dialog:dismiss();
            end);
        end
        self.m_result_dialog:setPositiveListener(self,function()
                self.m_result_dialog:dismiss();
                self:requestCtrlCmd(PlayCreateEndgateRoomController.s_cmds.start_action);
            end);
    end
    self.m_result_dialog:show(isWin);
end

PlayCreateEndgateRoomScene.showChangeFlagDialog = function(self)
    if not self.changeFlagDialog then
        self.changeFlagDialog = new(ChioceDialog)
        self.changeFlagDialog:setMode(ChioceDialog.MODE_SURE);
        self.changeFlagDialog:setMessage("是否换边？");
        self.changeFlagDialog:setNegativeListener(nil,nil)
        self.changeFlagDialog:setPositiveListener(self,self.changeFlag)
    end
    self.changeFlagDialog:show();
end

PlayCreateEndgateRoomScene.changeFlag = function(self)
    self:requestCtrlCmd(PlayCreateEndgateRoomController.s_cmds.changeFlag);
end


----------------------------------- config ------------------------------
PlayCreateEndgateRoomScene.s_controlConfig = 
{
};

PlayCreateEndgateRoomScene.s_controlFuncMap =
{
};


PlayCreateEndgateRoomScene.s_cmdConfig =
{
    [PlayCreateEndgateRoomScene.s_cmds.startGame]                 = PlayCreateEndgateRoomScene.startGame;
    [PlayCreateEndgateRoomScene.s_cmds.showWinDialog]             = PlayCreateEndgateRoomScene.showWinDialog;
    [PlayCreateEndgateRoomScene.s_cmds.showEndingResultDialog]    = PlayCreateEndgateRoomScene.showEndingResultDialog;
    [PlayCreateEndgateRoomScene.s_cmds.setGameOver]               = PlayCreateEndgateRoomScene.setGameOver;
    [PlayCreateEndgateRoomScene.s_cmds.updateView]                = PlayCreateEndgateRoomScene.updateView;
    [PlayCreateEndgateRoomScene.s_cmds.revive]                    = PlayCreateEndgateRoomScene.revive;
    [PlayCreateEndgateRoomScene.s_cmds.console_gameover]          = PlayCreateEndgateRoomScene.console_gameover;
    [PlayCreateEndgateRoomScene.s_cmds.dismissTipsNote]           = PlayCreateEndgateRoomScene.dismissTipsNote;
    [PlayCreateEndgateRoomScene.s_cmds.setMyTurn]                 = PlayCreateEndgateRoomScene.setMyTurn;
    [PlayCreateEndgateRoomScene.s_cmds.dismissTips]               = PlayCreateEndgateRoomScene.dismissTips;
    [PlayCreateEndgateRoomScene.s_cmds.show_submove_text]         = PlayCreateEndgateRoomScene.show_submove_text;
    [PlayCreateEndgateRoomScene.s_cmds.show_tips_text]            = PlayCreateEndgateRoomScene.show_tips_text;
    [PlayCreateEndgateRoomScene.s_cmds.setSubNum]                 = PlayCreateEndgateRoomScene.setSubNum;
    [PlayCreateEndgateRoomScene.s_cmds.showTipsNote]              = PlayCreateEndgateRoomScene.showTipsNote;
    [PlayCreateEndgateRoomScene.s_cmds.preStep]                   = PlayCreateEndgateRoomScene.preStep;
    [PlayCreateEndgateRoomScene.s_cmds.use_tip]                   = PlayCreateEndgateRoomScene.use_tip;
    [PlayCreateEndgateRoomScene.s_cmds.use_undoMove]              = PlayCreateEndgateRoomScene.use_undoMove;
    [PlayCreateEndgateRoomScene.s_cmds.use_revive]                = PlayCreateEndgateRoomScene.use_revive;
    [PlayCreateEndgateRoomScene.s_cmds.update_account_rank]       = PlayCreateEndgateRoomScene.onUploadAccountRank;
    [PlayCreateEndgateRoomScene.s_cmds.show_reward]               = PlayCreateEndgateRoomScene.onShowReward;
    [PlayCreateEndgateRoomScene.s_cmds.set_start_btn_visible]     = PlayCreateEndgateRoomScene.setStartBtnVisible;
    [PlayCreateEndgateRoomScene.s_cmds.update_step_text]          = PlayCreateEndgateRoomScene.updateStepText;
    [PlayCreateEndgateRoomScene.s_cmds.show_result_dialog]        = PlayCreateEndgateRoomScene.ShowResultDialog;
    [PlayCreateEndgateRoomScene.s_cmds.update_min_step_text]      = PlayCreateEndgateRoomScene.updateMinStepText;
    [PlayCreateEndgateRoomScene.s_cmds.save_chess]                = PlayCreateEndgateRoomScene.saveChess;
    
    
}





-------------------------------- private node -------------------