require(VIEW_PATH .. "account_dialog_view");
require(BASE_PATH.."chessDialogScene")
require("util/drawingPack");
AccountDialog = class(ChessDialogScene,false);

AccountDialog.CONTINUE_WIN_TYPE = 1;--连胜后缀
AccountDialog.COIN_WIN_TYPE = 2;--金币后缀
AccountDialog.SCORE_WIN_TYPE = 3;--积分后缀
AccountDialog.NUM_WIN_TYPE = 4;--纯数字
AccountDialog.ctor = function(self, room)
	super(self,account_dialog_view);
	self.m_root_view = self.m_root;
    self.m_room = room;
    -- 联网连胜次数
    self.m_continue_win = 0;
    -- 断网连胜次数
    self.m_offline_continue_win = 0;

    -- content
	self.m_content_view = self.m_root_view:getChildByName("account_content_view");
    self.m_content_bg = self.m_root_view:getChildByName("account_dialog_bg");
    self.m_content_bg:setTransparency(0.4);
    ------- title -------
    self.m_title_view = self.m_content_view:getChildByName("account_title_view");
        -- dynamic_title
        self.m_dynamic_title = self.m_title_view:getChildByName("account_dynamic_title");
            -- dynamic_anim
            self.m_dynamic_anim = self.m_dynamic_title:getChildByName("dynamic_anim");
            -- m_result_txt
            self.m_result_txt = self.m_dynamic_title:getChildByName("dynamic_txt");
        -- account_upuser_info
        self.m_account_upuser_info = self.m_title_view:getChildByName("account_upuser_info");
            -- account_upuser_info_bg
            self.m_account_upuser_info_bg = self.m_account_upuser_info:getChildByName("bg");
                -- upuser_frame
                self.m_account_upuser_frame = self.m_account_upuser_info_bg:getChildByName("upuser_frame");
                -- upuser_name
                self.m_account_upuser_name = self.m_account_upuser_info_bg:getChildByName("upuser_name");
                -- upuser_level
                self.m_account_upuser_level = self.m_account_upuser_info_bg:getChildByName("upuser_level");
        -- close_btn
        self.m_close_btn = self.m_title_view:getChildByName("close_btn");
        self.m_close_btn:setOnClick(self, self.onCancel);
        self.m_check_upuser_btn = self.m_title_view:getChildByName("check_upuser_btn");
        self.m_check_upuser_btn:setOnClick(self, self.onCheckUpUser);
        self.m_save_mychess_btn = self.m_title_view:getChildByName("save_mychess");
        self.m_save_mychess_btn:setOnClick(self, self.onSaveMychess);
    ------- board -------
    self.m_board_view = self.m_content_view:getChildByName("account_board_view");
    ------- result ------
    self.m_result_view = self.m_content_view:getChildByName("account_result_view");
        -- online_result
        self.m_online_result_view = self.m_result_view:getChildByName("online_result");
            -- watch_result
            self.m_watch_result_view = self.m_online_result_view:getChildByName("watch_result");            
                -- up_user
                self.m_up_user_view = self.m_watch_result_view:getChildByName("up_user");
                    -- user
                    self.m_up_user_bg = self.m_up_user_view:getChildByName("bg");
                    self.m_up_user_frame = self.m_up_user_bg:getChildByName("icon_frame");
                    self.m_up_user_nick = self.m_up_user_bg:getChildByName("nick");
                    self.m_up_user_level = self.m_up_user_bg:getChildByName("level");
                    self.m_up_user_coin = self.m_up_user_bg:getChildByName("coin");
                    self.m_up_user_score = self.m_up_user_bg:getChildByName("score");
                    self.m_up_user_score_change = self.m_up_user_bg:getChildByName("score_change");
                    self.m_up_user_win_img = self.m_up_user_bg:getChildByName("win_img");
                    self.m_up_user_lose_img = self.m_up_user_bg:getChildByName("lose_img");
                    self.m_up_user_flag_img = self.m_up_user_bg:getChildByName("flag_img");
                -- down_user
                self.m_down_user_view = self.m_watch_result_view:getChildByName("down_user");
                    -- user
                    self.m_down_user_bg = self.m_down_user_view:getChildByName("bg");
                    self.m_down_user_frame = self.m_down_user_bg:getChildByName("icon_frame");
                    self.m_down_user_nick = self.m_down_user_bg:getChildByName("nick");
                    self.m_down_user_level = self.m_down_user_bg:getChildByName("level");
                    self.m_down_user_coin = self.m_down_user_bg:getChildByName("coin");
                    self.m_down_user_score = self.m_down_user_bg:getChildByName("score");
                    self.m_down_user_score_change = self.m_down_user_bg:getChildByName("score_change");
                    self.m_down_user_win_img = self.m_down_user_bg:getChildByName("win_img");
                    self.m_down_user_lose_img = self.m_down_user_bg:getChildByName("lose_img");
                    self.m_down_user_flag_img = self.m_down_user_bg:getChildByName("flag_img");
            -- self_result
            self.m_self_result_view = self.m_online_result_view:getChildByName("self_result");
            self.m_self_result_bg = self.m_self_result_view:getChildByName("bg");
                -- self_info
                self.m_self_change_coin = self.m_self_result_bg:getChildByName("self_change_coin");
                self.m_self_change_score = self.m_self_result_bg:getChildByName("self_change_score");
                self.m_self_slider_view = self.m_self_result_bg:getChildByName("self_slider_view");
                    -- self_progress
                    self.m_self_score_progress_bg = self.m_self_slider_view:getChildByName("score_process_bg");
                    self.m_self_score_progress_img = self.m_self_score_progress_bg:getChildByName("score_progress_img");
                    self.m_self_score_progress_txt = self.m_self_score_progress_bg:getChildByName("score_progress_txt");
                    self.m_self_score_left_txt = self.m_self_slider_view:getChildByName("left_txt");
                    self.m_self_score_right_txt = self.m_self_slider_view:getChildByName("right_txt");
        -- offline_result
        self.m_offline_result_view = self.m_result_view:getChildByName("offline_result");
            -- reward_bg
            self.m_reward_bg = self.m_offline_result_view:getChildByName("reward_bg");
                self.m_reward_win_chest_bg = {};
                self.m_reward_win_chest_shine = {};
                self.m_reward_win_chest = {};
                self.m_reward_win_tips = {};
                self.m_reward_icon = {};
	            for index = 1,3 do 
		            self.m_reward_win_chest_bg[index] = self.m_reward_bg:getChildByName(string.format("reward_win_chest%d",index));
                    self.m_reward_icon[index] = self.m_reward_win_chest_bg[index]:getChildByName("Image1");
                    self.m_reward_win_chest_shine[index] = self.m_reward_win_chest_bg[index]:getChildByName("shine");
		            self.m_reward_win_chest[index] = self.m_reward_win_chest_bg[index]:getChildByName(string.format("reward_win_chest%d_texture",index));
		            self.m_reward_win_chest[index]:setFile("common/decoration/chest_1.png");
                    self.m_reward_win_chest[index]:setSize(83,79);
		            self.m_reward_win_tips[index] = self.m_reward_win_chest_bg[index]:getChildByName(string.format("reward_win_tips%d",index));
		            self.m_reward_win_tips[index]:setVisible(false);
	            end
	            self.m_reward_win_chest[1]:setEventTouch(self,self.selectFunc1);
	            self.m_reward_win_chest[2]:setEventTouch(self,self.selectFunc2);
	            self.m_reward_win_chest[3]:setEventTouch(self,self.selectFunc3); 

                -- rank_txt
                self.m_rank_txt = self.m_reward_bg:getChildByName("rank_txt");

            -- lose_tips
            self.m_lose_tips = self.m_offline_result_view:getChildByName("lose_tips");
                -- first_line
                self.m_offline_first_line = self.m_lose_tips:getChildByName("first_line");
                -- second_line
                self.m_offline_second_line = self.m_lose_tips:getChildByName("second_line");
                -- third_line
                self.m_offline_third_line = self.m_lose_tips:getChildByName("third_line");
    ------- button ------
    self.m_button_view = self.m_content_view:getChildByName("account_button_view");
        -- button1
        self.m_button_1 = self.m_button_view:getChildByName("account_btn_1");
            -- btn_txt1
            self.m_btn_txt1 = self.m_button_1:getChildByName("btn_txt_1");
        -- button2
        self.m_button_2 = self.m_button_view:getChildByName("account_btn_2");
            -- btn_txt2
            self.m_btn_txt2 = self.m_button_2:getChildByName("btn_txt_2");
        -- button3
        self.m_button_3 = self.m_button_view:getChildByName("account_btn_3");
            -- btn_txt3
            self.m_btn_txt3 = self.m_button_3:getChildByName("btn_txt_3");
        -- share_btn
        self.m_share_btn = self.m_button_view:getChildByName("share_btn");
        self.m_share_btn:setOnClick(self, self.share);
    ------- end --------  
end

AccountDialog.dtor = function(self)
    delete(self.m_root_view);
	self.m_root_view = nil;
    if self.m_chioce_dialog then
        self.m_chioce_dialog:dismiss();
        delete(self.m_chioce_dialog);
    end;
    delete(self.m_timeOutAnim);
    delete(self.m_scale_board);
    self.m_scale_board = nil;
    delete(self.m_mysave_dialog);
    self.m_mysave_dialog = nil;
end


AccountDialog.resetTitleView = function(self)
    if self.m_dynamic_anim then
        self.m_dynamic_anim:removeAllChildren();
    end;
    if self.m_offline_rank then
        self.m_offline_rank:removeAllChildren();
    end;
end;


AccountDialog.resetResultView = function(self)
    if self.m_up_user_score_change then
        self.m_up_user_score_change:removeAllChildren();
    end;
    if self.m_down_user_score_change then
        self.m_down_user_score_change:removeAllChildren();
    end;
end;


AccountDialog.resetRewardView = function(self)
    if self.m_dialog_type == GAME_TYPE_OFFLINE then
	    for index = 1,3 do 
            self.m_reward_win_chest_shine[index]:setVisible(false);
            self.m_reward_icon[index]:setVisible(false);
            self.m_reward_icon[index]:removeProp(1);
		    self.m_reward_win_chest[index]:setFile("common/decoration/chest_1.png");
            self.m_reward_win_chest[index]:setSize(83,79);
            self.m_reward_win_chest[index]:setVisible(true);
            self.m_reward_win_chest[index]:setPickable(true);
		    self.m_reward_win_tips[index]:setText("");
		    self.m_reward_win_tips[index]:setVisible(false);
	    end
	    self.m_reward_win_chest[1]:setEventTouch(self,self.selectFunc1);
	    self.m_reward_win_chest[2]:setEventTouch(self,self.selectFunc2);
	    self.m_reward_win_chest[3]:setEventTouch(self,self.selectFunc3);
    end;
end;

AccountDialog.resetBottomBtns = function(self)
    self:resetShareBtn();
end;

AccountDialog.isShowing = function(self)
	return self:getVisible();
end


AccountDialog.getReasonText = function(self,endType)
	local reason = "";
	if endType == ENDTYPE_SURRENDER then
		reason = "(认输)";
	elseif endType == ENDTYPE_LEAVE then
		reason = "(逃跑)";
	end

	return reason;
end

AccountDialog.resetDialog = function(self)
    -- 重置title
    self:resetTitleView();   
    -- 重置result
    self:resetResultView();
    -- 重置reward
    self:resetRewardView();
    -- 重置按钮
    self:resetBottomBtns();
    -- 重置roombg,消除虚化
    self:blurBehind(false);
end;





-- room:显示dialog的scene
-- flag:0和棋，1红方胜利，2黑方胜利
-- var:联网里传倒计时;断网里传可用变量
-- dialogType:GAME_TYPE_ONLINE or GAME_TYPE_OFFLINE
AccountDialog.show = function(self,room,flag,var,dialogType)
    -- 虚化房间背景
    self:blurBehind(true);
    -- 联网游戏(联网，观战，自定义，好友)
    self.m_dialog_type = dialogType;
    if dialogType == GAME_TYPE_ONLINE then
        self.m_account_again_btn_timeout = var;
	    if not room.m_upUser or not room.m_downUser then
            self:blurBehind(false);
            ChessToastManager.getInstance():showSingle("上家玩家已离开！");
		    print_string("AccountDialog.show but not room.m_upUser or not room.m_downUser");
		    return
	    end
        -- flag == 0和棋，1红方胜利，2黑方胜利
	    if flag == 0 then
		    kEffectPlayer:playEffect(Effects.AUDIO_OVER_DRAW);
			room.m_upUser:setDrawtimes(room.m_upUser:getDrawtimes() + 1);
			room.m_downUser:setDrawtimes(room.m_downUser:getDrawtimes() + 1);
            if UserInfo.getInstance():getGameType() == GAME_TYPE_WATCH then
                self.m_result_txt:setVisible(true);
                self.m_result_txt:setText("双方和棋");
                self:setWatchAnim();
            else    
                self.m_result_txt:setVisible(false);
                self:setDrawAnim();
            end;
            self.m_up_user_flag_img:setFile("dialog/draw.png");
            self.m_down_user_flag_img:setFile("dialog/draw.png");
	    elseif flag == room.m_downUser:getFlag() then 
			room.m_upUser:setLosetimes(room.m_upUser:getLosetimes() + 1);
			room.m_downUser:setWintimes(room.m_downUser:getWintimes() + 1);
		    kEffectPlayer:playEffect(Effects.AUDIO_OVER_WIN);
            if UserInfo.getInstance():getGameType() == GAME_TYPE_WATCH then
                self.m_result_txt:setVisible(true);
                self.m_result_txt:setText((((flag == 1) and "红方") or "黑方").."获胜:"..room.m_downUser:getName());
                self:setWatchAnim();
            else    
                self.m_result_txt:setVisible(false);
                self.m_continue_win = room.m_downUser:getContinueWintimes();
		        if "ios" == System.getPlatform() then
            	    self:isShowIosEvaluate(self.m_continue_win);
		        end;
                self:setWinAnim(room.m_downUser:getCoin());
                self.m_share_btn:setVisible(true);
                self.m_button_1:setPos(-190,nil);
                self.m_button_2:setPos(90,nil);
            end;
            self.m_up_user_flag_img:setFile("dialog/lose.png");
            self.m_down_user_flag_img:setFile("dialog/win.png");
	    else
			room.m_upUser:setWintimes(room.m_upUser:getWintimes() + 1);
			room.m_downUser:setLosetimes(room.m_downUser:getLosetimes() + 1);
		    kEffectPlayer:playEffect(Effects.AUDIO_OVER_LOSE);
            if UserInfo.getInstance():getGameType() == GAME_TYPE_WATCH then
                self.m_result_txt:setVisible(true);
                self.m_result_txt:setText((((flag == 1) and "红方") or "黑方").."获胜:"..room.m_upUser:getName());
                self:setWatchAnim();
            else    
                self.m_result_txt:setVisible(false);
                self.m_continue_win = 0;
                self:setLoseAnim(room.m_downUser:getCoin());
            end;
            self.m_up_user_flag_img:setFile("dialog/win.png");
            self.m_down_user_flag_img:setFile("dialog/lose.png");
	    end
        if UserInfo.getInstance():getGameType() == GAME_TYPE_CUSTOMROOM 
            or UserInfo.getInstance():getGameType() == GAME_TYPE_FRIEND then
               self.m_button_1:setVisible(false); 
        else
            self.m_button_1:setVisible(true); 
        end;
        self.m_button_2:setVisible(true);
        self.m_button_3:setVisible(false);
        if UserInfo.getInstance():getGameType() == GAME_TYPE_WATCH then
            -- 观战双方信息可见，隐藏自己的信息
            self.m_watch_result_view:setVisible(true);
            self.m_self_result_view:setVisible(false);
            self.m_check_upuser_btn:setVisible(false);
            self.m_save_mychess_btn:setVisible(false);
            self.m_btn_txt1:setText("收藏棋局");
            self.m_btn_txt2:setText("继续观战");
            self.m_button_1:setOnClick(self, self.onSaveMychess);
            self.m_button_2:setOnClick(self, self.continueWatch);
            self:showWatchUsersInfo(room);
        else
            -- 非观战双方信息不可见，显示自己的信息
            self.m_watch_result_view:setVisible(false);
            self.m_self_result_view:setVisible(true);
            self.m_check_upuser_btn:setVisible(true);
            self.m_save_mychess_btn:setVisible(true);
            self.m_btn_txt1:setText("换个对手");
            self.m_btn_txt2:setText("再来一局(*)");
            self.m_button_1:setOnClick(self, self.reSelect);
            self.m_button_2:setOnClick(self, self.reStart);
            self:setSelfInfo(room.m_downUser);
        end;
        self:resetSaveBtn();
        
        self.m_online_result_view:setVisible(true);
        self.m_offline_result_view:setVisible(false);

    -- 断网对战(单机，残局)  
    elseif dialogType == GAME_TYPE_OFFLINE then
        self.m_isLastestGate = var[1]; -- 是否最新关卡
        self.m_offline_type = var[2];  -- 1单机，2残局
        self.m_button_1:setVisible(true);
        self.m_button_2:setVisible(true);
        self.m_button_3:setVisible(false);
        self.m_online_result_view:setVisible(false);
        self.m_offline_result_view:setVisible(true);
        self.m_check_upuser_btn:setVisible(false);
        self.m_save_mychess_btn:setVisible(false);
	    if flag == 0 then-- flag == 0和棋，1红方胜利，2黑方胜利
            if self.m_offline_type == 1 then
                self.m_btn_txt1:setText("分享");
                self.m_btn_txt2:setText("再来一局");
            else
                self.m_btn_txt1:setText("分享");
                self.m_btn_txt2:setText("下一关");
            end;
		    kEffectPlayer:playEffect(Effects.AUDIO_OVER_DRAW);
            self.m_dynamic_title:setVisible(true);
--            self.m_static_title:setVisible(false);
            self:setDrawAnim();
            self.m_reward_bg:setVisible(true);
            self.m_lose_tips:setVisible(false);

	    elseif flag ==  room.m_downUser:getFlag() then
            if self.m_offline_type == 1 then
                self.m_btn_txt1:setText("分享");
                self.m_btn_txt2:setText("再来一局");
            else
                self.m_btn_txt1:setText("分享");
                self.m_btn_txt2:setText("下一关");
            end;
            self.m_button_1:setOnClick(self, self.share);
            self.m_button_2:setOnClick(self, self.nextGate);
		    kEffectPlayer:playEffect(Effects.AUDIO_OVER_WIN); 
            self.m_dynamic_title:setVisible(true);
            self.m_content_bg:setVisible(true)
            self.m_offline_continue_win = self.m_offline_continue_win + 1;
 
            self:setOffWinAnim();

            -- 挑战成功，如果最新关，就抽奖；否则提示“领过奖励”
            if self.m_isLastestGate then
                self.m_reward_bg:setVisible(true);
                self.m_lose_tips:setVisible(false);
                -- 已获取奖励，就不可以再点击
                self.m_has_get_chest = false;
            else
                self.m_reward_bg:setVisible(false);
                self.m_lose_tips:setVisible(true); 
                self.m_offline_first_line:setVisible(false);
                self.m_offline_second_line:setVisible(false);
                self.m_offline_third_line:setVisible(true);                  
            end;

	    else
            if self.m_offline_type == 1 then
                self.m_btn_txt1:setText("分享");
                self.m_btn_txt2:setText("再来一局");
            else
                self.m_btn_txt1:setText("分享");
                self.m_btn_txt2:setText("再来一局");
            end;
            self.m_button_1:setOnClick(self, self.share);
            self.m_button_2:setOnClick(self, self.rePlay);
            kEffectPlayer:playEffect(Effects.AUDIO_OVER_LOSE);
            self.m_dynamic_title:setVisible(true);
            self.m_content_bg:setVisible(false)
            self.m_offline_continue_win = 0;
            self:setOffLoseAnim();

            -- 挑战失败,显示提示语
            self.m_reward_bg:setVisible(false);
            self.m_lose_tips:setVisible(true); 
            self.m_offline_first_line:setVisible(true);
            self.m_offline_second_line:setVisible(true);
            self.m_offline_third_line:setVisible(false);                  
	    end       

    end;
    -- board缩略图
    self:showBoardScaleView();

    -- 观战/offline游戏不显示倒计时
    if UserInfo.getInstance():getGameType() ~= GAME_TYPE_WATCH 
        and dialogType == GAME_TYPE_ONLINE then
        self:startTimer();
    end;

    -- 自动保存到“最近对战”(保存联网，观战，单机；残局不保存)
--    if dialogType == GAME_TYPE_ONLINE or 
--       (dialogType == GAME_TYPE_OFFLINE and  self.m_offline_type == 1) then
    self:save();
--    end;

	self:setVisible(true);
    self.super.show(self);
end

AccountDialog.isShowIosEvaluate = function(self, continuswin)
    local is_open, contin_times = UserInfo.getInstance():getIosAppStoreEvaluate();
    if tonumber(is_open) == 1 then
        if tonumber(continuswin) == tonumber(contin_times) then
            GameCacheData.getInstance():saveBoolean(GameCacheData.IS_SHOW_IOS_EVALUATE_DIALOG, true);
        end;
    end;
end;


AccountDialog.showWatchUsersInfo = function(self, room)
	if room.m_downUser then
        if not self.m_user_head_icon then
            self.m_down_user_icon = new(Mask,UserInfo.DEFAULT_ICON[1],"hall/icon_frame_mask.png");
            self.m_down_user_icon:setSize(self.m_down_user_frame:getSize());
            self.m_down_user_frame:addChild(self.m_down_user_icon);
        end
        if room.m_downUser:getIconType() == -1 then
            self.m_down_user_icon:setUrlImage(room.m_downUser:getIcon(),UserInfo.DEFAULT_ICON[1]);
        else
            self.m_down_user_icon:setFile(UserInfo.DEFAULT_ICON[room.m_downUser:getIconType()] or UserInfo.DEFAULT_ICON[1]);
        end

		self.m_down_user_nick:setText(GameString.convert2UTF8(room.m_downUser:getName()));
        self.m_down_user_level:setFile(string.format("common/icon/level_%d.png",10-self:getWatchUserLevel(room.m_downUser:getScore())));
		self.m_down_user_score:setText(GameString.convert2UTF8("积分:" .. room.m_downUser:getScore()));
        local scoreChange = self:getScoreChangeImg(room.m_downUser:getPoint());
        scoreChange:setAlign(kAlignTop);
        self.m_down_user_score_change:addChild(scoreChange);
	end
	if room.m_upUser then
        if not self.m_user_head_icon then
            self.m_up_user_icon = new(Mask,UserInfo.DEFAULT_ICON[1],"hall/icon_frame_mask.png");
            self.m_up_user_icon:setSize(self.m_up_user_frame:getSize());
            self.m_up_user_frame:addChild(self.m_up_user_icon);
        end
        if room.m_upUser:getIconType() == -1 then
            self.m_up_user_icon:setUrlImage(room.m_upUser:getIcon(),UserInfo.DEFAULT_ICON[1]);
        else
            self.m_up_user_icon:setFile(UserInfo.DEFAULT_ICON[room.m_upUser:getIconType()] or UserInfo.DEFAULT_ICON[1]);
        end
		self.m_up_user_nick:setText(GameString.convert2UTF8(room.m_upUser:getName()));
        self.m_up_user_level:setFile(string.format("common/icon/level_%d.png",10-self:getWatchUserLevel(room.m_upUser:getScore())));
		self.m_up_user_score:setText(GameString.convert2UTF8("积分:" .. room.m_upUser:getScore()));
        local scoreChange = self:getScoreChangeImg(room.m_upUser:getPoint());
        scoreChange:setAlign(kAlignTop);
        self.m_up_user_score_change:addChild(scoreChange);
	end 
end;

-- 解锁单机关卡头像
AccountDialog.unlockConsoleHead = function(self,progress)
    local curLevel = UserInfo.getInstance():getPlayingLevel();
    local isPassGate = GameCacheData.getInstance():getBoolean(GameCacheData.CONSOLE_PASS_GATE..UserInfo.getInstance():getUid(), false);
    if progress == COSOLE_MODEL_GATE_NUM then
        GameCacheData.getInstance():saveBoolean(GameCacheData.CONSOLE_PASS_GATE..UserInfo.getInstance():getUid(), true);
    end;
    if progress == curLevel and not isPassGate then
        if progress > 3 then
            AnimConsoleUnlockHead.play(self,progress);
        end;
    end;
end;


-- 获得观战Users棋力等级
AccountDialog.getWatchUserLevel = function(self, score)
    local dan_grade = UserInfo.getInstance():getDanGrading();
    if dan_grade then
        for i,v in pairs(dan_grade) do
            if score >= v.min and score < v.max then
                return i;
            end
        end
    end
    return 1;
end;


AccountDialog.setSelfInfo = function(self, user)
    if not user then return end;
    -- coinChange
    self.m_self_change_coin:removeAllChildren(true);
    local coinChangeImg = self:getCoinChangeImg(user:getCoin());
    coinChangeImg:setAlign(kAlignTopLeft);
    coinChangeImg:setPos(20,20);
    self.m_self_change_coin:addChild(coinChangeImg);
    
    -- scoreChange
    self.m_self_change_score:removeAllChildren(true);
    local scoreChangeImg = self:getScoreChangeImg(user:getPoint());
    scoreChangeImg:setAlign(kAlignTopRight);
    scoreChangeImg:setPos(20,20);
    self.m_self_change_score:addChild(scoreChangeImg);
    
    -- progress
    local dan_grade = UserInfo.getInstance():getDanGrading();
    local score = user:getScore();
    if dan_grade then
        for i,v in pairs(dan_grade) do
            if score >= v.min and score < v.max then
                local rate = tonumber(string.format("%.4f", ((score - v.min)/(v.max - v.min))));
                self.m_self_score_progress_txt:setText((rate * 100).."%");
                local progressW = 550 * rate;
                self.m_self_score_progress_img:setSize(progressW,nil);
                self.m_self_score_left_txt:setText(v.name); 
                if dan_grade[i+1] then
                    self.m_self_score_right_txt:setText(dan_grade[i+1].name);
                else
                    self.m_self_score_right_txt:setText(""); 
                end;
            end
        end
    end
end;



-- 是否虚化房间背景
AccountDialog.blurBehind = function(self, isBlur)
    local controller
    local view
    controller = StateMachine.getInstance():getCurrentController();
    if not controller then return end;
    view = controller:getRootView();
    if not view or not view:getID() then return end;

    if isBlur then
        local drawing = view:packDrawing(true);
        self.m_bg_pack_drawing = drawing;
        local blur = require("libEffect/shaders/blur");
        blur.applyToDrawing(self.m_bg_pack_drawing,1);
    else
        local common = require("libEffect/shaders/common");
        common.removeEffect(self.m_bg_pack_drawing);
        view:packDrawing(false);
        delete(self.m_bg_pack_drawing);
        self.m_bg_pack_drawing = nil;
    end;
end;

AccountDialog.showBoardScaleView = function(self)
    
    self.m_scale_board = drawingShot(self.m_room.m_board_view);
    self.m_scale_board:setPos(0,0);
--    self.m_scale_board:setFillParent(true,true);
    self.m_board_view:removeAllChildren();
--    self.node = new(Node);
--    self.node:setAlign(kAlignCenter);
    local w,h = 587, 660;
    self.m_scale_board:setSize(w,h);
--    self.node:addChild(self.m_scale_board);
    self.m_board_view:addChild(self.m_scale_board);

--    self.m_scale_board:setFillParent(true,true);
--    self.m_scale_board:addPropScale(1,kAnimNormal,1,-1,1,0.7,1,0.7,kCenterDrawing);    
end;


AccountDialog.getCoinChangeImg = function(self, coin)
    if not tonumber(coin) then return end;
    local coin_change = tonumber(coin);
    local coin_change_img = nil;
    if coin_change >= 0 then
        local coin = new(Image,"animation/account/coin.png");
        coin_change_img = ToolKit.int2img(coin_change,coin, AccountDialog.COIN_WIN_TYPE);
    else
        local coin = new(Image,"animation/account/coin_gray.png");
        coin_change_img = ToolKit.int2img(coin_change,coin, AccountDialog.COIN_WIN_TYPE);
    end;    
    return coin_change_img;
end;


AccountDialog.getScoreChangeImg = function(self, score)
    if not tonumber(score) then return end;
    local score_change = tonumber(score);
    local score_change_img = nil;
    if score_change >= 0 then
        local score = new(Image,"animation/account/score.png");
        score_change_img = ToolKit.int2img(score_change,score, AccountDialog.SCORE_WIN_TYPE);
    else
        local score = new(Image,"animation/account/score_gray.png");
        score_change_img = ToolKit.int2img(score_change,score, AccountDialog.SCORE_WIN_TYPE);
    end;    
    return score_change_img;
end;



-- 观战动画设置
AccountDialog.setWatchAnim = function(self)
    self.m_animWatch = new(AnimWin);
    self.m_animWatch:setWatch("animation/game_over.png");
    self.m_animWatch:setAlign(kAlignTop);
    self.m_dynamic_anim:addChild(self.m_animWatch);
    self.m_animWatch:play();  
end;

-- 和棋动画设置
AccountDialog.setDrawAnim = function(self)
    self.m_animWin = new(AnimWin);
    self.m_animWin:setAlign(kAlignTop);
    self.m_animWin:setDraw("animation/draw.png");
    self.m_dynamic_anim:addChild(self.m_animWin);
    self.m_animWin:play();   
end;



-- 联网胜利动画设置
AccountDialog.setWinAnim = function(self, coin_change)
    self.m_animWin = new(AnimWin);
    self.m_animWin:setAlign(kAlignTop);
    if self.m_continue_win > 1 then
        self.m_continue_win_img = new(Image,"animation/continuswin.png");
        local continue_img = ToolKit.int2img(self.m_continue_win, self.m_continue_win_img,AccountDialog.CONTINUE_WIN_TYPE);
        self.m_animWin:setContinueWin(continue_img);
    end;
    self.m_dynamic_anim:addChild(self.m_animWin);
    self.m_animWin:play(); 
     
end;


-- 联网败北动画设置
AccountDialog.setLoseAnim = function(self, coin_change)
    self.m_animLose = new(AnimLose);
    self.m_animLose:setAlign(kAlignTop);
    self.m_dynamic_anim:addChild(self.m_animLose);
    self.m_animLose:play();   
    
end;


-- 离线游戏胜利动画
AccountDialog.setOffWinAnim = function(self)
    self.m_animWin = new(AnimWin);   
    self.m_animWin:setAlign(kAlignTop); 
    self.m_animWin:setOfflineWin();
    if self.m_offline_continue_win > 1 then
        self.m_offline_continue_win_img = new(Image,"animation/continuswin.png");
        local offline_continue_img = ToolKit.int2img(self.m_offline_continue_win, self.m_offline_continue_win_img,AccountDialog.CONTINUE_WIN_TYPE);
        self.m_animWin:setContinueWin(offline_continue_img);
    end;
    self.m_dynamic_anim:addChild(self.m_animWin);
    self.m_animWin:play();  

end;

-- 离线败北动画设置
AccountDialog.setOffLoseAnim = function(self)
    self.m_animLose = new(AnimLose);
    self.m_animLose:setAlign(kAlignTop); 
    self.m_dynamic_anim:addChild(self.m_animLose);
    self.m_animLose:play();   
end;





AccountDialog.startTimer = function(self)
	self:stopTimer();
	self.m_timeOutAnim = new(AnimInt,kAnimLoop,0,1,1000,-1);
	self.m_timeOutAnim:setEvent(self, self.onAgainTimeout);
    self.m_timeOutAnim:setDebugName("AccountDialog.onAgainTimeout timer");
end

AccountDialog.stopTimer = function(self)
   
   if self.m_timeOutAnim then
	    delete(self.m_timeOutAnim);
	    self.m_timeOutAnim = nil;
    end;
end
AccountDialog.onAgainTimeout = function(self)
    Log.i("AccountDialog.onAgainTimeout"..self.m_account_again_btn_timeout);
    self.m_btn_txt2:setText("再来一局("..self.m_account_again_btn_timeout..")");
    if self.m_account_again_btn_timeout <= 0 then
        self.m_room:requestCtrlCmd(OnlineRoomController.s_cmds.client_msg_logout);
        self:stopTimer();
    else
        self.m_account_again_btn_timeout = self.m_account_again_btn_timeout - 1;
    end;
end;

--(暂时移到Room)不能移动到Room，弹出的选择框会因为用户离开而消失!
AccountDialog.canContinue = function(self)
	local gold_type = UserInfo.getInstance():getMoneyType();
	local ctype = UserInfo.getInstance():canAccessRoom(gold_type);
	print_string("AccountDialog.canContinue .. ctype" .. ctype);
	if ctype == 0 then
		--破产
		self:collapse();
    elseif gold_type == 5 then
        if ctype ~= 5 then
            self:exitRoom();
            return false
        end
        return true;
	elseif ctype < gold_type then
		UserInfo.getInstance():setMoneyType(ctype);
		self:goLowRoom();
	elseif ctype > gold_type then
		UserInfo.getInstance():setMoneyType(ctype);
		self:goHighRoom();
	else
		return true;
	end
end

--破产
AccountDialog.collapse = function(self)
	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end

	local message = "您的金币不足以继续游戏,即将返回大厅";
	self.m_chioce_dialog:setMode();
	self.m_chioce_dialog:setMessage(message);
    self.m_chioce_dialog:setNeedBackEvent(false);
	self.m_chioce_dialog:setPositiveListener(self.m_room,self.m_room.exitRoom);
	self.m_chioce_dialog:setNegativeListener(self.m_room,self.m_room.exitRoom);
	self.m_chioce_dialog:show();
end


--前往
AccountDialog.goLowRoom = function(self,ctype)
	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end

	local message = "您的金币不足在该场次游戏,前往低底注场虐菜？";
	self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE);
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:setPositiveListener(self.m_room,self.m_room.changeRoomType);
	self.m_chioce_dialog:setNegativeListener(self.m_room,self.m_room.exitRoom)
	self.m_chioce_dialog:show();
end

AccountDialog.goHighRoom = function(self,ctype)
	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end

	local message = "您的金币超出该场次最高限额,挑战高底注场？";
	self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE);
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:setPositiveListener(self.m_room,self.m_room.changeRoomType);
	self.m_chioce_dialog:setNegativeListener(self.m_room,self.m_room.exitRoom)
	self.m_chioce_dialog:show();
end



AccountDialog.onCancel = function(self)
    self:dismiss();
end

AccountDialog.onCheckUpUser = function(self)
    self.m_account_upuser_info:setVisible(true);
    self.m_dynamic_title:setVisible(false);
    local room = self.m_room;
    if room.m_upUser then
        if not self.m_up_user_head_icon then
            self.m_up_user_head_icon = new(Mask,UserInfo.DEFAULT_ICON[1],"hall/icon_frame_mask.png");
            self.m_up_user_head_icon:setSize(self.m_account_upuser_frame:getSize());
            self.m_account_upuser_frame:addChild(self.m_up_user_head_icon)
        end
        if room.m_upUser:getIconType() == -1 then
            self.m_up_user_head_icon:setUrlImage(room.m_upUser:getIcon(),UserInfo.DEFAULT_ICON[1]);
        else
            self.m_up_user_head_icon:setFile(UserInfo.DEFAULT_ICON[room.m_upUser:getIconType()] or UserInfo.DEFAULT_ICON[1]);
        end
		self.m_account_upuser_name:setText(GameString.convert2UTF8(room.m_upUser:getName()));
        self.m_account_upuser_level:setFile(string.format("common/icon/level_%d.png",10-self:getWatchUserLevel(room.m_upUser:getScore())));        
    end;
end;

AccountDialog.onSaveMychess = function(self)
   -- 收藏弹窗
    if not self.m_mysave_dialog then
        self.m_mysave_dialog = new(ChioceDialog)
    end;
    self.m_mysave_dialog:setMode(ChioceDialog.MODE_SHOUCANG);  
    self.m_save_cost = UserInfo.getInstance():getFPcostMoney().save_manual;  
    self.m_mysave_dialog:setMessage("是否花费"..(self.m_save_cost or 500) .."金币收藏当前棋谱？");
    self.m_mysave_dialog:setPositiveListener(self, self.saveChesstoMysave);
    self.m_mysave_dialog:show();    
end;


AccountDialog.saveChesstoMysave = function(self)
    if self.m_room and self.m_room.m_mvData and next(self.m_room.m_mvData) then
        local chessData = self.m_room.m_mvData;
        local post_data = {};
        post_data.mid = UserInfo.getInstance():getUid();
        post_data.down_user = chessData.down_user;
        post_data.red_mid = chessData.red_mid;
        post_data.black_mid = chessData.black_mid;
        post_data.red_mnick = chessData.red_mnick;
        post_data.black_mnick = chessData.black_mnick;
        post_data.win_flag = chessData.win_flag;
        post_data.end_type = chessData.end_type;
        post_data.manual_type = chessData.manual_type;
        post_data.start_fen = chessData.start_fen;
        post_data.move_list = chessData.move_list;
        post_data.end_fen = chessData.end_fen;
        post_data.collect_type = (self.m_mysave_dialog:getCheckState() and 2) or 1; -- 收藏类型, 1公共收藏，2人个收藏 
        post_data.is_old = chessData.is_old or 0;
        HttpModule.getInstance():execute(HttpModule.s_cmds.saveMychess,post_data);
    end;
end;


AccountDialog.setHasSaved = function(self)
    self.m_save_mychess_btn:setFile("dialog/has_save.png");
    self.m_save_mychess_btn:setPickable(false);
end;

AccountDialog.resetSaveBtn = function(self)
    self.m_save_mychess_btn:setFile("dialog/save_mychess.png");
    self.m_save_mychess_btn:setPickable(true);
end;


AccountDialog.resetShareBtn = function(self)
    self.m_share_btn:setVisible(false);
    self.m_button_1:setPos(-140,nil);
    self.m_button_2:setPos(140,nil);
end;

-- 网络错误，没有发出去抽奖请求可以重新发送
AccountDialog.resetChessRandom = function(self)
    for index = 1, 3 do
        self.m_reward_win_chest[index]:setPickable(true);
    end;   
end;


-- 单机抽奖
AccountDialog.randomChestConsole = function(self,selected)
    for index = 1, 3 do
        if (index - 1) == selected then
            self.m_reward_win_chest[index]:setFile("common/decoration/chest_2.png");
            break;
        end;
        self.m_reward_win_chest[index]:setPickable(false);
    end;
    local anim = new(AnimInt,kAnimNormal,0,1,400,-1);
    if anim then
        anim:setEvent(nil, function() 
            local post_data = {};
	        post_data.draw_type = "alone";
            post_data.click_pos = selected;
            HttpModule.getInstance():execute(HttpModule.s_cmds.getReward,post_data);            
        end);
    end;

--	local rate = UserInfo.getInstance():getWinConsoleGetSoulRate();

--	local drate1 = 0;
--	local drate2 = 0;
--	local drate3 = 0;

--	if rate > 75 then
--		if rate > 95 then
--			drate1 = 75
--			drate2 = 20
--			drate3 = rate -95
--		else
--			drate1 = 75
--			drate2 = rate -75
--		end
--	else
--		drate1 = rate;
--	end

--	local isConnected = UserInfo.getInstance():getConnectHall();
--	if not  isConnected then
--		rate  = 0;--没有网络时候无法获取 几率为0
--	end


--	local chests = {

--		[1]	=  {
--					["name"] = "悔棋",  --名字
--					["probability"] = 75 - drate1, --获取概率
--					["num_pro"] = {[1] = 60,[2] = 30, [3] = 10},  --个数的概率
--					["image"] = "endgate/endgame_undo_icon.png",
--					["cache_name"] = GameCacheData.ENDGAME_UNDO_NUM,
--					["default_num"] = ENDING_UNDO_NUM,
--			   },
--		[2]	=  {
--					["name"] = "起死回生",   --名字
--					["probability"] = 20 - drate2, --获取概率
--					["num_pro"] = {85,10,5}, --个数的概率
--					["image"] = "endgate/ending_reborn_img.png",
--					["cache_name"] = GameCacheData.ENDGAME_REVIVE_NUM,
--					["default_num"] = ENDING_REVIVE_NUM,

--			   },
--		[3]	=  {
--				    ["name"] = "提示",   --名字
--				    ["probability"] = 5 - drate3, --获取概率
--				    ["num_pro"] = {[1] = 85,[2] = 10, [3] = 5},  --个数的概率
--				    ["image"] = "endgate/endgame_tips_icon.png",
--				    ["cache_name"] = GameCacheData.ENDGAME_TIPS_NUM,
--				    ["default_num"] = ENDING_TIPS_NUM,
--		        },

--		[4]	=  {
--					["name"] = "棋魂",   --名字
--					["probability"] = rate, --获取概率
--					["num_pro"] = {[1] = 85,[1] = 10, [1] = 5},  --个数的概率
--					["image"] = "drawable/qi_hun_icon.png",
--					["cache_name"] = GameCacheData.QI_HUN,
--					["default_num"] = 1,
--			    },		   
--	}

--	local random_table = lua_get_random_table(100,6);

--	local chest_pro = {};  --宝箱的概率表
--	for key,value in pairs(chests) do
--		chest_pro[key] = value.probability;
--	end

--	local isQihun = false;

--	for index = 1,3 do
--		local pro_table = chest_pro;
--		local key = lua_get_region_by_random_num(pro_table,random_table[index*2-1]);
--        if key < 1 or key > 4 then
--            key = 1;
--        end
--		pro_table = chests[key]["num_pro"];
--		local num = lua_get_region_by_random_num(pro_table,random_table[index*2]);

--		if key == 4 then
--			num = 1;
--		end

--		self.m_reward_win_tips[index]:setText(string.format("+%d",num));
--		self.m_reward_win_tips[index]:setVisible(true);
--		self.m_reward_win_chest[index]:setFile(chests[key]["image"]);
--		self.m_reward_win_chest[index]:setSize(120,104);

--		self.m_has_get_chest = true; --已获取奖励，就不可以再点击

--		--获取奖励
--		if selected == index then
--			print_string(string.format("key = %d,num = %d,index = %d",key,num,index)); 

--			--背景变成选择状态
--			self.m_reward_win_chest_bg[index]:setFile("endgate/ending_reward_select_img.png");
--			--HeadTurnAnim.play(self.m_console_win_chest[index]);
--			--ShockAnim.play(self.m_console_win_chest[index]);

--			local uid = UserInfo.getInstance():getUid();
--			local cache_key = chests[key]["cache_name"] .. uid;
--			local cahce_num = GameCacheData.getInstance():getInt(cache_key,chests[key]["default_num"]);
--			cahce_num = cahce_num + num ;
--			GameCacheData.getInstance():saveInt(cache_key,cahce_num);

--			if key == 4 then
--				isQiHun = true;
--			end

--			if self.m_room then
--				self.m_room:showUndoNum();
----				self.m_room.m_view:showTipsNum();
--			end

--			--上传统计数据
--			local one_reward = {};
--			one_reward.type = key + 1;
--			one_reward.num = num;
--			one_reward.level = 	 UserInfo.getInstance():getPlayingLevel();
--			one_reward.time = os.time();
--			reward_str = json.encode(one_reward);
--	        local post_data = {};
--	        post_data.reward_str = UserInfo.getInstance():addPlayConsoleReward(reward_str);
--            self.m_room.m_controller:sendHttpMsg(HttpModule.s_cmds.statRewardPerLevel, post_data);
----			PHPInterface.statRewardPerLevel(reward_str);

--		end
--	end

--	if isQiHun and isConnected then
--		isQiHun = false;
--        self.m_room.m_controller:onGetSoul(4);
--	end

end


-- 残局抽奖
AccountDialog.randomChestEndgate = function(self,selected)
    for index = 1, 3 do
        if (index - 1) == selected then
            self.m_reward_win_chest[index]:setFile("common/decoration/chest_2.png");
            break;
        end;
        self.m_reward_win_chest[index]:setPickable(false);
    end; 
     
    local anim = new(AnimInt,kAnimNormal,0,1,400,-1);
    if anim then
        anim:setEvent(nil, function() 
            local post_data = {};
            post_data.draw_type = "booth";
            post_data.click_pos = selected;
            HttpModule.getInstance():execute(HttpModule.s_cmds.getReward,post_data);          
        end);
    end;







--	local chests = nil;
--	local isConnected = false--HallSocket.isConnected();
--	if  isConnected then

--		chests = {

--		[1]	=  {
--					["name"] = "悔棋",  --名字
--					["probability"] = 75-kEndgateData:getWinEndGateGetSoulRate() , --获取概率
--					["num_pro"] = {[1] = 60,[2] = 30, [3] = 10},  --个数的概率
--					["image"] = "drawable/endgame_undo_icon.png",
--					["cache_name"] = GameCacheData.ENDGAME_UNDO_NUM,
--					["default_num"] = ENDING_UNDO_NUM,
--			   },

--		[2]	=  {
--					["name"] = "起死回生",   --名字
--					["probability"] = 20, --获取概率
--					["num_pro"] = {85,10,5}, --个数的概率
--					["image"] = "endgate/ending_reborn_img.png",
--					["cache_name"] = GameCacheData.ENDGAME_REVIVE_NUM,
--					["default_num"] = ENDING_REVIVE_NUM,
--			   },

--		[3]	=  {
--				    ["name"] = "提示",   --名字
--				    ["probability"] = 5, --获取概率
--				    ["num_pro"] = {[1] = 85,[2] = 10, [3] = 5},  --个数的概率
--				    ["image"] = "endgate/endgame_tips_icon.png",
--				    ["cache_name"] = GameCacheData.ENDGAME_TIPS_NUM,
--				    ["default_num"] = ENDING_TIPS_NUM,
--		        },

--		[4]	=  {
--				    ["name"] = "棋魂",   --名字
--				    ["probability"] = kEndgateData:getWinEndGateGetSoulRate(), --获取概率
--				    ["num_pro"] = {[1] = 85,[1] = 10, [1] = 5},  --个数的概率
--				    ["image"] = "drawable/qi_hun_icon.png",
--				    ["cache_name"] = GameCacheData.QI_HUN,
--				    ["default_num"] = 1,
--			    }

--		}
--	else

--		chests = {

--			[1]	=  {
--						["name"] = "悔棋",  --名字
--						["probability"] = 75, --获取概率
--						["num_pro"] = {[1] = 60,[2] = 30, [3] = 10},  --个数的概率
--						["image"] = "endgate/endgame_undo_icon.png",
--						["cache_name"] = GameCacheData.ENDGAME_UNDO_NUM,
--						["default_num"] = ENDING_UNDO_NUM,
--				   },

--			[2]	=  {
--						["name"] = "起死回生",   --名字
--						["probability"] = 20, --获取概率
--						["num_pro"] = {85,10,5}, --个数的概率
--						["image"] = "endgate/ending_reborn_img.png",
--						["cache_name"] = GameCacheData.ENDGAME_REVIVE_NUM,
--						["default_num"] = ENDING_REVIVE_NUM,
--				   },

--			[3]	=  {
--					["name"] = "提示",   --名字
--					["probability"] = 5, --获取概率
--					["num_pro"] = {[1] = 85,[2] = 10, [3] = 5},  --个数的概率
--					["image"] = "endgate/endgame_tips_icon.png",
--					["cache_name"] = GameCacheData.ENDGAME_TIPS_NUM,
--					["default_num"] = ENDING_TIPS_NUM,
--			   }
--		}		
--	end

--	local random_table_num = 6;
--	if isConnected then
--		random_table_num = 8;
--	end

--	local random_table = lua_get_random_table(100,random_table_num);

--	local chest_pro = {};  --宝箱的概率表
--	for key,value in pairs(chests) do
--		chest_pro[key] = value.probability;
--	end

--	local isQiHun = false;
--	for index = 1,3 do
--		local pro_table = chest_pro;
--		local key = lua_get_region_by_random_num(pro_table,random_table[index*2-1]);
--		pro_table = chests[key]["num_pro"];
--		local num = lua_get_region_by_random_num(pro_table,random_table[index*2]);

--		if key == 4 then
--			num = 1;
--		end

--		self.m_reward_win_tips[index]:setText(string.format("+%d",num));
--		self.m_reward_win_tips[index]:setVisible(true);
--		self.m_reward_win_chest[index]:setFile(chests[key]["image"]);
--		self.m_reward_win_chest[index]:setSize(120,104);

--		self.m_has_get_chest = true; --已获取奖励，就不可以再点击

--		--获取奖励
--		if selected == index then
--			print_string(string.format("key = %d,num = %d",key,num)); 

--			--背景变成选择状态
--			self.m_reward_win_chest_bg[index]:setFile("endgate/ending_reward_select_img.png");
--			--HeadTurnAnim.play(self.m_ending_win_chest[index]);
--			--ShockAnim.play(self.m_ending_win_chest[index]);

--			if key == 4 then
--				isQiHun = true;
--			end

--			if key<4 then
--				local uid = UserInfo.getInstance():getUid();
--				local cache_key = chests[key]["cache_name"] .. uid;
--				local cahce_num = GameCacheData.getInstance():getInt(cache_key,chests[key]["default_num"]);
--				cahce_num = cahce_num + num ;
--				GameCacheData.getInstance():saveInt(cache_key,cahce_num);

--				if self.m_room.m_controller then
----					self.m_roomController:showUndoNum();
----					self.m_roomController:showTipsNum();
--                    self.m_room.m_controller:updateView(EndgateRoomScene.s_cmds.updateView);
--				end
--			end
--		end
--	end

--	--抽完奖后上传进度
--	--如果是最新关卡，则上传进度
--	if not isQiHun then
--		self:updateInfo();
--	elseif isConnected then
--		isQiHun = false;
--		self:updateInfo();		
--	end
end


AccountDialog.getChestFile = function(self, rtype,propid)
    if rtype == "prop" then
        -- php定义的道具id对应
        -- 2 => '悔棋',
        -- 3 => '提示',
        -- 4 => '起死回生',
        if propid == 2 then
            return "common/icon/undo_icon.png";
        elseif propid == 3 then
            return "common/icon/tips_icon.png";
        elseif propid == 4 then
            return "common/icon/relive_icon.png";
        else
            return;
        end;
    elseif rtype == "coin" then
        return "mall/mall_list_gold5.png";
    elseif rtype == "soul" then
        return "mall/soul.png";
    else
        return;
    end;
    
end;


AccountDialog.showReward = function(self, result)
--{propid=3 rtype="prop" is_reward=0 num=1 }
--{rtype="coin" is_reward=1 num=107 }
--{propid=3 rtype="prop" is_reward=0 num=1 }
	for index = 1,3 do
        self.m_reward_win_chest[index]:setVisible(false);
		self.m_reward_win_tips[index]:setText(string.format("+%d",result[index].num));
		self.m_reward_win_tips[index]:setVisible(true);
        self.m_reward_icon[index]:setVisible(true);
        self.m_reward_icon[index]:setFile(self:getChestFile(result[index].rtype, result[index].propid) or "endgate/ending_chest_texture.png");
        self.m_reward_icon[index]:addPropScaleSolid(1,0.8,0.8,kCenterDrawing);
--		self.m_reward_win_chest[index]:setFile(self:getChestFile(result[index].rtype, result[index].propid) or "endgate/ending_chest_texture.png");
--		self.m_reward_win_chest[index]:setSize(83,69);
		self.m_has_get_chest = true; --已获取奖励，就不可以再点击
        -- 选中的奖品
		if result[index].is_reward == 1 then
            self.m_reward_win_chest_shine[index]:setVisible(true);
--			self.m_reward_win_chest_bg[index]:setFile("animation/shine.png");
--            self.m_reward_win_chest_bg[index]:setSize(100,100);
--            self.m_reward_win_chest_bg[index]:setAlign(kAlignTop);
		else
            self.m_reward_win_chest_shine[index]:setVisible(false);
        end
	end    
end;


--AccountDialog.updateInfo = function(self)

--	--保存最新关卡
--	kEndgateData:setLatestGate();

--	--上传进度
--	local tid = kEndgateData:getGateTid();
--	local sort = kEndgateData:getGateSort()+1 ;

--	local propinfo = {};
--	local uid = UserInfo.getInstance():getUid();
--	propinfo["1"] = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LIFE_NUM .. uid,ENDING_LIFE_NUM);
--	propinfo["2"]= GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_UNDO_NUM .. uid,ENDING_UNDO_NUM);
--	propinfo["3"]= GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_TIPS_NUM.. uid,ENDING_TIPS_NUM);
--	propinfo["4"] = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_REVIVE_NUM .. uid,ENDING_REVIVE_NUM);
--	propinfo["5"] = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LIFE_LIMIT .. uid,ENDING_LIFELIMIT_NUM);

--	local post_data = {};
--	post_data.tid = tid;
--	post_data.pos = sort;
--	post_data.id = kEndgateData:getBoardTableId(); -------- 这个值不知道干嘛的
--	post_data.propinfo = propinfo;
--    HttpModule.getInstance():execute(HttpModule.s_cmds.uploadGateInfo,post_data);

--	self:updateGateData();
--end



--AccountDialog.updateGateData = function(self)	
--	local gate = kEndgateData:getGate();
--	if gate.progress ~= gate.subCount then
--		gate.progress = kEndgateData:getGateSort()+1;
--		if gate.progress >= gate.subCount then	--通大关啦
--			gate.progress = gate.subCount;
--			local uid = UserInfo.getInstance():getUid();
--			local curGateNum = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_GATE_NUM..uid,1);
--			curGateNum = curGateNum + 1;
--			GameCacheData.getInstance():saveInt(GameCacheData.ENDGAME_GATE_NUM..uid,curGateNum);

--			local tempTid = kEndgateData:getGateTids()[curGateNum];
--			if tempTid then
--				local uid = UserInfo.getInstance():getUid();
--				GameCacheData.getInstance():saveInt(GameCacheData.ENDGAME_LATETST_GATE .. uid,tempTid);
--				GameCacheData.getInstance():saveInt(GameCacheData.ENDGAME_LATETST_SORT .. uid,-1);
--			end
--		end
--		gate.uid = UserInfo.getInstance():getUid();
--		dict_set_string(kUpdateEndGate,kUpdateEndGate..kparmPostfix,json.encode(gate));
--		call_native(kUpdateEndGate);
--	end
--end



-- 第一个宝箱
AccountDialog.selectFunc1 = function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
	 --已获取奖励，就不可以再点击
	if self.m_has_get_chest then
		print_string("AccountDialog.selectFunc1 but self.m_has_get_chest");
		return
	end
	print_string("AccountDialog.selectFunc1");
	if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
       if self.m_offline_type == 1 then
           self:randomChestConsole(0);
       else
           self:randomChestEndgate(0);
       end;
    end
end;



-- 第二个宝箱
AccountDialog.selectFunc2 = function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
    --已获取奖励，就不可以再点击
	if self.m_has_get_chest then
		print_string("AccountDialog.selectFunc2 but self.m_has_get_chest");
		return
	end
	if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
       if self.m_offline_type == 1 then
           self:randomChestConsole(1);
       else
           self:randomChestEndgate(1);
       end;
    end
end;



-- 第三个宝箱
AccountDialog.selectFunc3 = function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
    --已获取奖励，就不可以再点击
	if	self.m_has_get_chest  then
		print_string("AccountDialog.selectFunc3 but self.m_has_get_chest");
		return
	end
	if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
       if self.m_offline_type == 1 then
           self:randomChestConsole(2);
       else
           self:randomChestEndgate(2);
       end;
    end
end;




-- 重来
AccountDialog.rePlay = function(self)
    self.super.dismiss(self);
    self:setVisible(false);
    self:resetDialog();
    if self.m_room then
        self.m_room:restart_action();
    end;
end;


-- 下一关
AccountDialog.nextGate = function(self)
    self.super.dismiss(self);
    self:setVisible(false);
    self:resetDialog();
    if self.m_room.m_controller then
        self.m_room.m_controller:loadNextGate();
    end;
end;


AccountDialog.share = function(self)
    if self.m_room then
        self.m_room:sharePicture();
    end;
end;

-- 换个观战房间
AccountDialog.reSeletcWatch = function(self)
    self.super.dismiss(self);
    self:setVisible(false);
    self:resetDialog();
    if self.m_room then
        self.m_room:exitRoom();
    end
end


-- 继续观战
AccountDialog.continueWatch = function(self)
    self.super.dismiss(self);
    self:setVisible(false);
    self:resetDialog();
    self:setVisible(false);
end;


AccountDialog.reSelect = function(self)
    self:stopTimer();
    self.super.dismiss(self);
    self:resetDialog();
    self:setVisible(false);
    if self.m_room.m_upUser then
        self.m_room:userLeave(self.m_room.m_upUser:getUid(),false);
        self.m_room:matchRoom();
    else
        local gametype = UserInfo.getInstance():getGameType(); --用户的游戏模式
        if gametype ~= GAME_TYPE_CUSTOMROOM and gametype ~= GAME_TYPE_FRIEND then
--            self.m_room:showSelectPlayerDialog();
            self.m_room:matchRoom();
        end
    end
end;

AccountDialog.reStart = function(self)
    self:stopTimer();
    self.super.dismiss(self);
    self:setVisible(false);
    self:resetDialog();
	if UserInfo.getInstance():getGameType() ~= GAME_TYPE_COMPUTER then  --单机
		if self:canContinue() then
            self.m_btn_txt2:setText("再来一局(*)");
            self.m_room:sendReadyMsg();    
        end;
	end 
end


AccountDialog.dismiss = function(self)
	print_string("AccountDialog dismiss");
	UserInfo.getInstance():setPoint(0);
	UserInfo.getInstance():setCoin(0);
    local message = "您确定离开吗？";
	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end

	self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE);
	self.m_chioce_dialog:setMessage(message);
    self.m_chioce_dialog:setPositiveListener(self,self.exitRoom);
	self.m_chioce_dialog:setNegativeListener(self,self.reShow);
	self.m_chioce_dialog:show();
    self:resetDialog();
    self.super.dismiss(self);
    self:resetDialog();
    self:setVisible(false);
end

AccountDialog.dismiss2 = function(self)
    self.super.dismiss(self);
    self:setVisible(false);
end

AccountDialog.exitRoom = function(self)
    self:resetDialog();
    if self.m_room then
        self.m_room:exitRoom();
    end
end;



AccountDialog.reShow = function(self)
    self.super.show(self);
    self:setVisible(true);
end;


AccountDialog.save = function(self)
    self.m_room:saveChess();
--    if self.m_offline_type ~= 2 then
        -- 残局不需要自动保存棋谱
--        if self.m_room:saveChess() then
--		    local autoSaveMsg  = new(Text,"棋局已自动保存到“最近棋谱”",0, 0, kAlignCenter,nil,24,255,255,255);
--            autoSaveMsg:setAlign(kAlignTop);
--            self.m_scale_board:addChild(autoSaveMsg);
--            autoSaveMsg:setPos(0,-18);
--        end
--    end
end


AccountDialog.setAccountRank = function(self, proportion,leading_number)
    if not leading_number or not proportion then return end;
    -- 领先提示
    self.m_rank_txt:setText("您领先了 ".. ((proportion or 0.2032) * 100) .."% 的玩家");
end;

function AccountDialog:getChoiceDialogStatus()
    if self.m_chioce_dialog and self.m_chioce_dialog:isShowing() then
        return true
    end
    return false;
end