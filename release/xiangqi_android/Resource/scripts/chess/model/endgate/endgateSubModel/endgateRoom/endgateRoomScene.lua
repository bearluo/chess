require(MODEL_PATH.."/room/roomScene");
require(MODEL_PATH.."room/board")
require(DATA_PATH.."userSetInfo");
require("dialog/common_share_dialog");
EndgateRoomScene = class(RoomScene);

EndgateRoomScene.s_controls = 
{
}

EndgateRoomScene.s_cmds = 
{
    startGame               = 1;
    showWinDialog           = 2;
    showEndingResultDialog  = 3;
    setGameOver             = 4;
    updateView              = 5;
    revive                  = 6;
    console_gameover        = 7;
    dismissTipsNote         = 8;
    setMyTurn               = 9;
    dismissTips             = 10;
    show_submove_text       = 11;
    show_tips_text          = 12;
    setSubNum               = 13;
    showTipsNote            = 14;
    preStep                 = 15;
    use_tip                 = 16;
    use_undoMove            = 17;
    use_revive              = 18;
    update_account_rank     = 19;
    show_reward             = 20;
    shareDialogHide         = 21;
}

EndgateRoomScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = EndgateRoomScene.s_controls;
    self:init();

    call_native("BanDeviceSleep");
end 

EndgateRoomScene.resume = function(self)
    ChessScene.resume(self);
--    self:init();
end


EndgateRoomScene.pause = function(self)
	ChessScene.pause(self);
	AnimKill.deleteAll();
    AnimTimeout.deleteAll();
    AnimJam.deleteAll();
end 


EndgateRoomScene.dtor = function(self)
    call_native("OpenDeviceSleep");
    if self.m_noticTipAnim then
        delete(self.m_noticTipAnim);
    end
    delete(self.m_ending_win_dialog);
    delete(self.m_ending_result_dialog);
    delete(self.m_setting_dialog);
    delete(self.m_anim_start);
    delete(self.m_anim_end);
    delete(self.commonShareDialog);

end 

----------------------------------- function ----------------------------
EndgateRoomScene.init = function(self)
	self.m_root_view = self.m_root;

    self.m_room_bg= self.m_root_view:getChildByName("ending_room_bg");
    local bg = UserSetInfo.getInstance():getBgImgRes();
    self.m_room_bg:setFile(bg or "common/background/room_bg.png");

	self.m_ending_room_title = self.m_root_view:getChildByName("ending_title_view");
	self.m_ending_title_bg = self.m_ending_room_title:getChildByName("ending_title_bg");
	self.m_ending_title = self.m_ending_title_bg:getChildByName("ending_title");
    self.endingNumberBg = self.m_ending_title_bg:getChildByName("endingNumberBg");
	self.m_ending_num = self.endingNumberBg:getChildByName("ending_num");
	self.m_ending_note_bg = self.m_ending_room_title:getChildByName("ending_room_note_bg");
	self.m_ending_note_text = self.m_ending_note_bg:getChildByName("ending_room_note_text");  --提示信息
	self.alreadyPassCountView = self.m_ending_title_bg:getChildByName("alreadyPassCountView");
    self.lineImage = self.m_ending_title_bg:getChildByName("lineImage");

--	self.m_next_gate_btn = self.m_ending_room_title:getChildByName("ending_next_gate_btn");
--	self.m_next_gate_btn:setOnClick(self,self.loadNextGate);


	--棋盘部分
	self.m_board_view = self.m_root_view:getChildByName("ending_board");
    self.m_board_bg = self.m_board_view:getChildByName("ending_board_bg");
     -- 棋盘适配
    local w,h = self.m_board_view:getSize();
	self.m_room_menu_view = self.m_root_view:getChildByName("ending_room_menu");--确定底边
    local bx,by = self.m_room_menu_view:getUnalignPos();
    local x,y = self.m_board_view:getUnalignPos();
    local pw = self.m_root_view:getSize();
    local ph = by - y;
    if pw > w then
        local diffh = ph - h; -- 增加的高
        local diffw = pw - w; -- 增加的高
        local add = math.min(diffw,diffh);
        local scale = (w+add)/w;
        local w,h = self.m_board_view:getSize();
	    self.m_board_view:setSize(w*scale,h*scale);
        local w,h = self.m_board_bg:getSize();
	    self.m_board_bg:setSize(w*scale,h*scale);
    end
    -- 棋盘适配 end
    local w,h = self.m_board_view:getSize();
    self.m_board = new(Board,w,h,self.m_controller);
	self.m_board_view:addChild(self.m_board);
    --设置棋盘图片
    self.m_board_bg:setFile(UserSetInfo.getInstance():getBoardRes());

--    if UserInfo.getInstance():getIsVip() == 1 then
--        boardBg:setFile("vip/vip_chess_board.png");
--    end

--	self.m_room_menu_view = self.m_root_view:getChildByName("ending_room_menu");

    -- 用户信息
--    self.m_ending_room_userinfo = self.m_root_view:getChildByName("ending_room_userinfo");
--    self.m_user_head_bg = self.m_ending_room_userinfo:getChildByName("head_bg");
--    self.m_user_head_icon = new(Mask,"online/room/head_mask.png","online/room/head_mask.png");
--    self.m_user_head_icon:setAlign(kAlignCenter);
--    if UserInfo.getInstance():getIconType() == -1 then
--        self.m_user_head_icon:setUrlImage(UserInfo.getInstance():getIcon());
--    else
--        self.m_user_head_icon:setFile(UserInfo.DEFAULT_ICON[UserInfo.getInstance():getIconType()] or UserInfo.DEFAULT_ICON[1]);
--    end
--    self.m_user_head_bg:addChild(self.m_user_head_icon);

--    self.m_user_level_icon = self.m_ending_room_userinfo:getChildByName("info_bg"):getChildByName("level_icon");
--    self.m_user_level_icon:setFile(string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevel()));
--    self.m_user_name = self.m_ending_room_userinfo:getChildByName("info_bg"):getChildByName("name");
--    self.m_user_name:setText(UserInfo.getInstance():getName());

--    self.m_vip_logo = self.m_ending_room_userinfo:getChildByName("info_bg"):getChildByName("vip_logo");
--    self.m_vip_frame = self.m_ending_room_userinfo:getChildByName("head_bg"):getChildByName("vip_frame");

--    local vx,vy = self.m_vip_logo:getPos();
--    local vw,vh = self.m_vip_logo:getSize();
--    local is_vip = UserInfo.getInstance():getIsVip();
--    if is_vip and is_vip == 1 then
--        self.m_user_name:setPos(vx + vw + 3,-26);
--        self.m_vip_logo:setVisible(true);
----        self.m_vip_frame:setVisible(true);
--    else
--        self.m_user_name:setPos(52,-26);
--        self.m_vip_logo:setVisible(false);
----        self.m_vip_frame:setVisible(false);
--    end
--    local frameRes = UserSetInfo.getInstance():getFrameRes();
--    self.m_vip_frame:setVisible(frameRes.visible);
--    local fw,fh = self.m_vip_frame:getSize();
--    if frameRes.frame_res then
--        self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
--    end

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
	self.m_room_menu1_bg = self.m_room_menu_view:getChildByName("ending_room_menu1_bg");
	self.m_undo_btn = self.m_room_menu1_bg:getChildByName("ending_undo_btn");
	self.m_undo_num_bg = self.m_undo_btn:getChildByName("ending_undo_num_bg");
	self.m_undo_num_text = self.m_undo_num_bg:getChildByName("ending_undo_num_text");
	self.m_undo_btn:setOnClick(self,self.undoMove);
    self.m_undo_btn:setOnTuchProcess(self.m_undo_btn,func);


	--提示
	self.m_tip_btn = self.m_room_menu1_bg:getChildByName("ending_tips_btn");
	self.m_tip_num_bg = self.m_tip_btn:getChildByName("ending_tips_num_bg");
	self.m_tip_num_text = self.m_tip_num_bg:getChildByName("ending_tips_num_text");
	self.m_tip_btn:setOnClick(self,self.tip_action);
    self.m_tip_btn:setOnTuchProcess(self.m_tip_btn,func);

	--起死回生
	self.m_reborn_btn = self.m_room_menu1_bg:getChildByName("ending_reborn_btn");
	self.m_reborn_num_bg = self.m_reborn_btn:getChildByName("ending_reborn_num_bg");
	self.m_reborn_num_text = self.m_reborn_num_bg:getChildByName("ending_reborn_num_text");
	self.m_reborn_btn:setOnClick(self,self.revive);
    self.m_reborn_btn:setOnTuchProcess(self.m_reborn_btn,func);





	--提示是否有变招和注释
	self.m_ending_submove_img = self.m_room_menu1_bg:getChildByName("ending_submove_img");
    self.m_ending_submove_img:setEventTouch(self,self.onSubmoveImgClick);
	--self.m_ending_tips_img = self.m_room_menu1_bg:getChildByName("ending_tips_img");
	self.m_ending_submove_tips_text = self.m_ending_submove_img:getChildByName("ending_submove_img_text");
	self.m_ending_tips_text = self.m_ending_submove_img:getChildByName("ending_tips_img_text");
	self:dismissTips();

	self.m_submove_view = self.m_room_menu1_bg:getChildByName("ending_submove_view_bg");
	self.m_select1_btn = self.m_submove_view:getChildByName("ending_submove1_btn");
	self.m_select2_btn = self.m_submove_view:getChildByName("ending_submove2_btn");
	self.m_select3_btn = self.m_submove_view:getChildByName("ending_submove3_btn");
	self:dismissSubMoveTips();


    self.m_select1_btn:setOnClick(self,self.subMove1);
	self.m_select2_btn:setOnClick(self,self.subMove2);
	self.m_select3_btn:setOnClick(self,self.subMove3);




--	self.m_room_menu2_bg = self.m_root_view:getChildByName("ending_room_menu2_bg");
    self.endingFoldButton = self.m_room_menu_view:getChildByName("endingFoldButton");
    self.endingFoldButton:setOnClick(self, self.endingFoldButtonDidClick);


    self.endingFoldView = self.m_room_menu_view:getChildByName("endingFoldView");
    self.endingFoldView:setVisible(false);

	self.m_restart_btn = self.endingFoldView:getChildByName("ending_room_restart_btn");
	self.m_restart_btn:setOnClick(self,self.restart_action);

	self.m_set_btn = self.endingFoldView:getChildByName("ending_room_set_btn");
	self.m_set_btn:setOnClick(self,self.setting_action);   

	self.m_leave_btn = self.endingFoldView:getChildByName("ending_room_leave_btn");
	self.m_leave_btn:setOnClick(self,self.back_action);  
    --self.m_leave_btn:setTransparency(0.6);

	self.m_share_btn = self.endingFoldView:getChildByName("ending_share_btn");
	self.m_share_btn:setOnClick(self,self.shareInfo);
    if kPlatform == kPlatformIOS then
        if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then 
            self.m_share_btn:setVisible(true);
        else
            self.m_share_btn:setVisible(false);
        end;
    else
        self.m_share_btn:setVisible(true);
    end;
	self.m_chioce_dialog = new(ChioceDialog);

    self.m_downUser = UserInfo.getInstance();
    self.m_downUser:setFlag(FLAG_RED);
end

EndgateRoomScene.setAnimItemEnVisible = function(self,ret)
end

EndgateRoomScene.resumeAnimStart = function(self,lastStateObj,timer)
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

EndgateRoomScene.pauseAnimStart = function(self,newStateObj,timer)
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
EndgateRoomScene.onSubmoveImgClick = function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
    if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
        self:dismissTips();
    end
end

--隐藏提醒
EndgateRoomScene.dismissTips = function(self)
	self.m_ending_submove_img:setVisible(false);
end

EndgateRoomScene.dismissSubMoveTips = function(self)
	self.m_select1_btn:setVisible(false);
    self.m_select2_btn:setVisible(false);
    self.m_select3_btn:setVisible(false);
	self.m_submove_view:setVisible(false);
end

EndgateRoomScene.tips_text = {"帮你恢复到前一步","帮你走出当前局面最佳的一步","帮你回到脱谱前一步"};



EndgateRoomScene.startGame = function(self,board_table)
    self.m_ending_title:setText(kEndgateData:getBoardTableSubTitle());
    self.m_ending_num:removeAllChildren(true);
    local num = board_table.sort + 1;
    local node = new(Node);
    node:setAlign(kAlignCenter);
    self.m_ending_num:addChild(node);
    local width,height = 0,0;
    while num>0 do
        local img = new(Image,"endgate/"..(num%10)..".png");
        img:setAlign(kAlignRight);
        img:setPos(width,0);
        node:addChild(img);
        local w,h = img:getSize();
        width = width + w;
        height = h;
        num = (num-num%10)/10;
    end
    node:setSize(width,height);

	self:showUndoNum();
	self:showTipsNum();
	self:showRebornNum();

	self:dismissTips();

     -- 请求过关的人数
    local param = {};
    param.tid = kEndgateData:getGateTid();
    param.pos = kEndgateData:getGateSort() + 1;
    HttpModule.getInstance():execute2(HttpModule.s_cmds.getPassBoothNumbers, {["param"]=param},
    function(isSuccess, response)
           if isSuccess then
                local jsonData = json.decode(response);
                local data = jsonData.data;
                local countRichText = new(RichText, "#r" .. data.num .. "#cffffff位棋友已经通关", 0, 0, kAlignLeft);
                self.alreadyPassCountView:addChild(countRichText);
                countRichText:setPos(0, 0);
           end
    end);


end
require("dialog/ending_win_dialog");
require("dialog/account_dialog");
EndgateRoomScene.showWinDialog = function(self)
    delete(self.m_ending_win_dialog);
    self.m_ending_win_dialog = nil;
    self.m_ending_win_dialog = new(AccountDialog,self);
    self.m_endgate_close_flag = 1;
    local var = {[1] = true, [2] = 2};
	self.m_ending_win_dialog:show(self,self.m_endgate_close_flag,var,RoomConfig.ROOM_TYPE_ENDGATE_ROOM);
    ToolKit.addEngateLogCount(self.m_ending_win_dialog.m_root_view); 
    self:updateInfo();
end

EndgateRoomScene.showEndingResultDialog = function(self,flag)
--    require("dialog/ending_result_dialog");
--    if not self.m_ending_result_dialog then
--		self.m_ending_result_dialog = new(EndingResultDialog,self.m_controller);
--	end
--	self.m_ending_result_dialog:setMode(mode);
--	self.m_ending_result_dialog:show();
    delete(self.m_ending_result_dialog);
    self.m_ending_result_dialog = nil;
	self.m_ending_result_dialog = new(AccountDialog,self);
    self.m_endgate_close_flag = flag;
    local var = {[1] = false, [2] = 2};
	self.m_ending_result_dialog:show(self,self.m_endgate_close_flag,var,RoomConfig.ROOM_TYPE_ENDGATE_ROOM);
--    self:updateInfo();  -- 失败不上传数据
end

-- 保存棋局
EndgateRoomScene.saveChess = function(self)
    return self:saveChessData();
end


EndgateRoomScene.saveChessData = function(self)
    local uid = UserInfo.getInstance():getUid();
	local keys = GameCacheData.getInstance():getString(GameCacheData.RECENT_DAPU_KEY .. uid,"");
	local keys_table = lua_string_split(keys, GameCacheData.chess_data_key_split);
	local key;
    local time = os.time();
    key = "myRecentChessDataId_"..time;
    if #keys_table < UserInfo.getInstance():getSaveChessManualLimit() then
        table.insert(keys_table,1, key);
    elseif #keys_table == UserInfo.getInstance():getSaveChessManualLimit() then
        table.remove(keys_table,#keys_table);
        table.insert(keys_table,1, key);
    else
        while #keys_table > UserInfo.getInstance():getSaveChessManualLimit() do
            table.remove(keys_table,#keys_table);    
        end;
    end
    local mvData = {};
    mvData.id = time;
    mvData.mid = uid;
    mvData.mnick = UserInfo.getInstance():getName();
    mvData.icon_type = UserInfo.getInstance():getIconType();
    mvData.icon_url = UserInfo.getInstance():getIcon();
    mvData.fileName = "残局回放";
    mvData.red_mid = self.m_downUser:getUid() or 0;
    -- 以前单机或残局mid=0;现mid=-1,为了解决断网玩单机和残局,在复盘最近对局内玩家本身mid=0和AI的mid相同，名字和棋盘不对的bug.
    -- 当连接网络之后，此时用户已经登录，收藏到我的收藏，php保存mid（-1）保存为0，所以不影响线上。
    mvData.black_mid = -1;
    mvData.down_user = self.m_downUser:getUid();
    mvData.red_mnick = self.m_downUser:getName();
    mvData.black_mnick = kEndgateData:getBoardTableSubTitle();
    mvData.red_icon_url = self.m_downUser:getIcon();
    mvData.red_icon_type = self.m_downUser:getIconType();
    mvData.black_icon_url = nil;
    mvData.black_icon_type = 1;
    mvData.red_level = 10 - self.m_downUser:getDanGradingLevel();
    mvData.black_level = 0;
    mvData.red_score = self.m_downUser:getScore();
    mvData.black_score = 0;
    mvData.win_flag = self.m_endgate_close_flag;
    mvData.end_type = 1;
    mvData.flag = FLAG_RED;
    mvData.end_fen = self.m_board.toFen(self.m_board:to_chess_map(),true);
    mvData.manual_type = "2";
    mvData.start_fen = GameCacheData.getInstance():getString(GameCacheData.DAPU_LAST_BORAD_FEN,GameCacheData.NULL);
    mvData.chessString = GameCacheData.getInstance():getString(GameCacheData.DAPU_LAST_CHESS_STR,GameCacheData.NULL);
    mvData.move_list = table.concat(self.m_board:to_mvList(),GameCacheData.chess_data_key_split);
    mvData.createrName = "";
    mvData.is_collect = 0;-- 是否收藏
	mvData.time = os.date("%Y/%m/%d",time)
    -- 结算收藏需要棋谱参数
    self.m_mvData = mvData;
    local mvData_str = json.encode(mvData);
    print_string("mvData_str = " .. mvData_str);
	GameCacheData.getInstance():saveString(GameCacheData.RECENT_DAPU_KEY .. uid,table.concat(keys_table,GameCacheData.chess_data_key_split));
	GameCacheData.getInstance():saveString(key .. uid,mvData_str);
	
	GameCacheData.getInstance():saveString(GameCacheData.DAPU_LAST_BORAD_FEN,GameCacheData.NULL);
	GameCacheData.getInstance():saveString(GameCacheData.DAPU_LAST_CHESS_STR,GameCacheData.NULL);
	return true;	--保存成功

end;



EndgateRoomScene.updateInfo = function(self)

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


EndgateRoomScene.onUploadAccountRank = function(self, proportion,leading_number)
    if self.m_ending_win_dialog and self.m_ending_win_dialog:getVisible() then
        self.m_ending_win_dialog:setAccountRank(proportion,leading_number);
    elseif self.m_ending_result_dialog and self.m_ending_result_dialog:getVisible() then
        self.m_ending_result_dialog:setAccountRank(proportion,leading_number);
    end;
end;


EndgateRoomScene.onShowReward = function(self, result)
    if not result then
        if self.m_ending_win_dialog and self.m_ending_win_dialog:getVisible() then
            self.m_ending_win_dialog:resetChessRandom();
        end;       
        return;
    end;    
    if self.m_ending_win_dialog and self.m_ending_win_dialog:getVisible() then
        self.m_ending_win_dialog:showReward(result);
    end;
end;

EndgateRoomScene.onShareDialogHide = function(self)
    if self.m_ending_win_dialog and self.m_ending_win_dialog:getVisible() then
        self.m_ending_win_dialog:shareDialogHide();
    elseif self.m_ending_result_dialog and self.m_ending_result_dialog:getVisible() then
        self.m_ending_result_dialog:shareDialogHide();
    end;
end


EndgateRoomScene.setGameOver = function(self,flag,boradCode)
	print_string("EndgateRoomScene.setGameOver");
--	self.m_next_gate_btn:setVisible(flag);

	if boradCode and boradCode ~= FLAG_RED then
--		self.m_next_gate_btn:setVisible(false);
	end

	if kEndgateData:isLastGate() == true then
--		self.m_next_gate_btn:setVisible(false);
	end

	if flag then
		self.m_restart_btn:setPickable(true);
		self.m_reborn_btn:setPickable(true);
		self.m_undo_btn:setPickable(false);
		self.m_tip_btn:setPickable(false);

        
		self.m_restart_btn:setGray(false);
		self.m_reborn_btn:setGray(false);
		self.m_undo_btn:setGray(true);
		self.m_tip_btn:setGray(true);

		self:dismissTipsNote();
	end
end


EndgateRoomScene.dismissTipsNote = function(self)
	self.m_ending_note_bg:setVisible(false);
	--self.m_tip_btn:setEnable(true);
end

EndgateRoomScene.updateView = function(self)
    self:showUndoNum();
    self:showTipsNum();
    self:showRebornNum();
end

--展示悔棋次数
EndgateRoomScene.showUndoNum = function(self)
	local num = UserInfo.getInstance():getUndoNum();
	self.m_undo_num_text:setText(num);

	print_string("EndgateRoomScene.showUndoNum num =  " .. num);
end

--展示提示次数
EndgateRoomScene.showTipsNum = function(self)
	local num = UserInfo.getInstance():getTipsNum();
    self.m_tip_num_text:setText(num);

	print_string("EndgateRoomScene.showTipsNum num =  " .. num);
end

--展示起死回生次数
EndgateRoomScene.showRebornNum = function(self)
	local num = UserInfo.getInstance():getReviveNum();
	self.m_reborn_num_text:setText(num);

	print_string("EndgateRoomScene.showRebornNum num =  " .. num);
end
----------------------------------- click -------------------------------

EndgateRoomScene.shareInfo = function(self)
    local data = self:requestCtrlCmd(EndgateRoomController.s_cmds.shareInfo); --shareUrl);
    if not data or type(data) ~= "table" then return end
    if not self.commonShareDialog then
        self.commonShareDialog = new(CommonShareDialog);
    end
    self.commonShareDialog:setShareDate(data,"sys_booth");
    self.commonShareDialog:show();
    self.endingFoldView:setVisible(false);
end

EndgateRoomScene.loadNextGate = function(self)
    self:requestCtrlCmd(EndgateRoomController.s_cmds.loadNextGate);
end

EndgateRoomScene.sharePicture = function(self)
    self:requestCtrlCmd(EndgateRoomController.s_cmds.sharePicture);
end;

EndgateRoomScene.undoMove = function(self)
	self:requestCtrlCmd(EndgateRoomController.s_cmds.onEventStat,ENDGIN_ROOM_MODEL_UNDO_BTN);

    self:requestCtrlCmd(EndgateRoomController.s_cmds.undoMove);
end

EndgateRoomScene.use_undoMove = function(self)
	self:showUndoNum();
	self:dismissSubMoveTips();
	self:dismissTipsNote();
end

--设置是否是我走
EndgateRoomScene.setMyTurn = function(self,is_my_trun,isGameOver)
	self.m_undo_btn:setPickable(is_my_trun);
	self.m_tip_btn:setPickable(is_my_trun);
	self.m_restart_btn:setPickable(is_my_trun);
	self.m_reborn_btn:setPickable(is_my_trun);
    
	self.m_undo_btn:setGray(not is_my_trun);
	self.m_tip_btn:setGray(not is_my_trun);
	self.m_restart_btn:setGray(not is_my_trun);
	self.m_reborn_btn:setGray(not is_my_trun);

	if not is_my_trun then
		self:dismissSubMoveTips();
	end

	if isGameOver then
		self.m_undo_btn:setPickable(false);
		self.m_tip_btn:setPickable(false);
		self.m_restart_btn:setPickable(true);
		self.m_reborn_btn:setPickable(true);
        
		self.m_undo_btn:setGray(true);
		self.m_tip_btn:setGray(true);
		self.m_restart_btn:setGray(false);
		self.m_reborn_btn:setGray(false);

	end
end


EndgateRoomScene.tip_action = function(self)
	self:requestCtrlCmd(EndgateRoomController.s_cmds.onEventStat,ENDGIN_ROOM_MODEL_TIPS_BTN);

    self:requestCtrlCmd(EndgateRoomController.s_cmds.tip_action);
end

EndgateRoomScene.use_tip = function(self)
	self:showTipsNum();
	self.m_tip_btn:setPickable(false);
	self.m_tip_btn:setGray(true);
	self:dismissTips();
end

--提示有变招
EndgateRoomScene.setSubNum = function(self,num)
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
EndgateRoomScene.showTipsNote = function(self,message)
	self.m_ending_note_text:setText(message);
	self.m_ending_note_bg:setVisible(true);
	self.m_tip_btn:setPickable(false);
	self.m_tip_btn:setGray(true);

	self:dismissTips();
end

--启死回生
EndgateRoomScene.revive = function(self)
	self:requestCtrlCmd(EndgateRoomController.s_cmds.onEventStat,ENDGIN_ROOM_MODEL_REBORN_BTN);
	--self.m_game_over = false;

    self:requestCtrlCmd(EndgateRoomController.s_cmds.revive);

end

EndgateRoomScene.use_revive = function(self)
	self:showRebornNum();
end

--上一步 .. 悔棋
EndgateRoomScene.preStep = function(self)
	self:dismissTips();
end


EndgateRoomScene.subMove1 = function(self)
	
	local move = self:requestCtrlCmd(EndgateRoomController.s_cmds.subMove1);

	if not move then
		print_string("EndgateRoomScene.subMove1 but not move");
		return
	end

	if move.comment then
		local message = move.comment;
		self:showTipsNote(message);
	end

	self.m_board:book_tips(move);

	self:dismissSubMoveTips();
end

EndgateRoomScene.subMove2 = function(self)

	local move = self:requestCtrlCmd(EndgateRoomController.s_cmds.subMove2);

	if not move then
		print_string("EndgateRoomScene.subMove2 but not branch.movelist");
		return
	end


	if move.comment then
		local message = move.comment;
		self:showTipsNote(message);
	end

	self.m_board:book_tips(move);
	self:dismissSubMoveTips();

end

EndgateRoomScene.subMove3 = function(self)

	local move = self:requestCtrlCmd(EndgateRoomController.s_cmds.subMove3);

	if not move then
		print_string("EndgateRoomScene.subMove3 but not branch.movelist");
		return
	end


	if move.comment then
		local message = move.comment;
		self:showTipsNote(message);
	end

	self.m_board:book_tips(move);
	self:dismissSubMoveTips();
end

EndgateRoomScene.restart_action = function(self)
	self:requestCtrlCmd(EndgateRoomController.s_cmds.onEventStat,ENDGIN_ROOM_MODEL_RESTART_BTN);

	self:requestCtrlCmd(EndgateRoomController.s_cmds.restart);
    self.endingFoldView:setVisible(false);
end
require("dialog/setting_dialog");
EndgateRoomScene.setting_action = function(self)
	self:requestCtrlCmd(EndgateRoomController.s_cmds.onEventStat,ENDGIN_ROOM_MODEL_SET_BTN);

	if not self.m_setting_dialog then
        
		self.m_setting_dialog = new(SettingDialog);
	end
	self.m_setting_dialog:show();
    self.endingFoldView:setVisible(false);
end

EndgateRoomScene.exitRoom = function(self)
    self:back_action();
end;




EndgateRoomScene.back_action = function(self,data)
	self:requestCtrlCmd(EndgateRoomController.s_cmds.onEventStat,ENDGIN_ROOM_MODEL_EXIT_BTN);
	self:requestCtrlCmd(EndgateRoomController.s_cmds.onBack);
end

EndgateRoomScene.endingFoldButtonDidClick = function (self)
    
    self.endingFoldView:setVisible(not self.endingFoldView:getVisible());

end


EndgateRoomScene.show_submove_text = function(self)
	self.m_ending_submove_tips_text:setVisible(true);
	self.m_ending_tips_text:setVisible(false);
	self.m_ending_submove_img:setVisible(true);
end

EndgateRoomScene.show_tips_text = function(self)
	self.m_ending_submove_tips_text:setVisible(false);
	self.m_ending_tips_text:setVisible(true);
	self.m_ending_submove_img:setVisible(true);
end

EndgateRoomScene.console_gameover = function(self,code,endType)
    self.m_board:console_gameover(code,endType);
end

----------------------------------- config ------------------------------
EndgateRoomScene.s_controlConfig = 
{
};

EndgateRoomScene.s_controlFuncMap =
{
};


EndgateRoomScene.s_cmdConfig =
{
    [EndgateRoomScene.s_cmds.startGame]                 = EndgateRoomScene.startGame;
    [EndgateRoomScene.s_cmds.showWinDialog]             = EndgateRoomScene.showWinDialog;
    [EndgateRoomScene.s_cmds.showEndingResultDialog]    = EndgateRoomScene.showEndingResultDialog;
    [EndgateRoomScene.s_cmds.setGameOver]               = EndgateRoomScene.setGameOver;
    [EndgateRoomScene.s_cmds.updateView]                = EndgateRoomScene.updateView;
    [EndgateRoomScene.s_cmds.revive]                    = EndgateRoomScene.revive;
    [EndgateRoomScene.s_cmds.console_gameover]          = EndgateRoomScene.console_gameover;
    [EndgateRoomScene.s_cmds.dismissTipsNote]           = EndgateRoomScene.dismissTipsNote;
    [EndgateRoomScene.s_cmds.setMyTurn]                 = EndgateRoomScene.setMyTurn;
    [EndgateRoomScene.s_cmds.dismissTips]               = EndgateRoomScene.dismissTips;
    [EndgateRoomScene.s_cmds.show_submove_text]         = EndgateRoomScene.show_submove_text;
    [EndgateRoomScene.s_cmds.show_tips_text]            = EndgateRoomScene.show_tips_text;
    [EndgateRoomScene.s_cmds.setSubNum]                 = EndgateRoomScene.setSubNum;
    [EndgateRoomScene.s_cmds.showTipsNote]              = EndgateRoomScene.showTipsNote;
    [EndgateRoomScene.s_cmds.preStep]                   = EndgateRoomScene.preStep;
    [EndgateRoomScene.s_cmds.use_tip]                   = EndgateRoomScene.use_tip;
    [EndgateRoomScene.s_cmds.use_undoMove]              = EndgateRoomScene.use_undoMove;
    [EndgateRoomScene.s_cmds.use_revive]                = EndgateRoomScene.use_revive;
    [EndgateRoomScene.s_cmds.update_account_rank]       = EndgateRoomScene.onUploadAccountRank;
    [EndgateRoomScene.s_cmds.show_reward]               = EndgateRoomScene.onShowReward;
    [EndgateRoomScene.s_cmds.shareDialogHide]           = EndgateRoomScene.onShareDialogHide;
}





-------------------------------- private node -------------------