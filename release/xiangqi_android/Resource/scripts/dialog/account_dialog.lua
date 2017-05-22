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
    EventDispatcher.getInstance():register(Event.Call,self,self.onEventResponse);
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
--        self.m_check_upuser_btn = self.m_title_view:getChildByName("check_upuser_btn");
--        self.m_check_upuser_btn:setOnClick(self, self.onCheckUpUser);
        self.m_save_mychess_btn = self.m_title_view:getChildByName("save_mychess");
        self.m_save_mychess_btn:setOnClick(self, self.onSaveMychess);
    ------- board -------
    self.m_board_view = self.m_content_view:getChildByName("account_board_view");
    ------- online ------
    self.m_online_view = self.m_content_view:getChildByName("account_online_view");
    

    self.m_up_user_view = self.m_online_view:getChildByName("up_user");
        -- user
        self.m_up_user_bg = self.m_up_user_view:getChildByName("bg");
        self.m_up_user_frame = self.m_up_user_bg:getChildByName("icon_frame");
        self.m_up_user_vip = self.m_up_user_frame:getChildByName("vip");
        self.m_up_user_nick = self.m_up_user_bg:getChildByName("nick");
        self.m_up_user_level = self.m_up_user_bg:getChildByName("level");
        self.m_up_user_coin = self.m_up_user_bg:getChildByName("coin");
        self.m_up_user_score = self.m_up_user_bg:getChildByName("score");
        self.m_up_user_coin_icon = self.m_up_user_bg:getChildByName("coin_icon");
        self.m_up_user_score_icon = self.m_up_user_bg:getChildByName("score_icon");
        self.m_up_user_score_change = self.m_up_user_bg:getChildByName("score_change");
        self.m_up_user_score_up = self.m_up_user_score_change:getChildByName("up");
        self.m_up_user_score_down = self.m_up_user_score_change:getChildByName("down");
        self.m_up_user_coin_change = self.m_up_user_bg:getChildByName("coin_change");
        self.m_up_user_coin_up = self.m_up_user_coin_change:getChildByName("up");
        self.m_up_user_coin_down = self.m_up_user_coin_change:getChildByName("down");
        self.m_up_user_cup_change = self.m_up_user_bg:getChildByName("cup_change");
        self.m_up_user_win_img = self.m_up_user_bg:getChildByName("win_img");
        self.m_up_user_lose_img = self.m_up_user_bg:getChildByName("lose_img");
        self.m_up_user_draw_img = self.m_up_user_bg:getChildByName("draw_img");
        self.m_up_user_flag_img = self.m_up_user_bg:getChildByName("flag_img");
        self.m_up_user_bankrupt = self.m_up_user_bg:getChildByName("bankrupt");
        self.m_up_user_guanzhu = self.m_up_user_bg:getChildByName("guanzhu");
        self.m_up_user_guanzhu:setOnClick(self,self.onFollowUpUser);
        self.m_up_user_guanzhu_txt = self.m_up_user_guanzhu:getChildByName("txt");
        self.m_up_user_ready_tip = self.m_up_user_bg:getChildByName("ready_tip");
    self.m_down_user_view = self.m_online_view:getChildByName("down_user");
        self.mRoomDoubleProp = new(RoomDoubleProp)
        self.mRoomDoubleProp:setAlign(kAlignTopRight)
        self.mRoomDoubleProp:setPos(110,0)
        self.mRoomDoubleProp:setVisible(false)
        self.m_down_user_view:addChild(self.mRoomDoubleProp)
        -- user
        self.m_down_user_bg = self.m_down_user_view:getChildByName("bg");
        self.m_down_user_frame = self.m_down_user_bg:getChildByName("icon_frame");
        self.m_down_user_vip = self.m_down_user_frame:getChildByName("vip");
        self.m_down_user_nick = self.m_down_user_bg:getChildByName("nick");
        self.m_down_user_level = self.m_down_user_bg:getChildByName("level");
        self.m_down_user_coin = self.m_down_user_bg:getChildByName("coin");
        self.m_down_user_score = self.m_down_user_bg:getChildByName("score");
        self.m_down_user_coin_icon = self.m_down_user_bg:getChildByName("coin_icon");
        self.m_down_user_score_icon = self.m_down_user_bg:getChildByName("score_icon");
        self.m_down_user_score_change = self.m_down_user_bg:getChildByName("score_change");
        self.m_down_user_score_up = self.m_down_user_score_change:getChildByName("up");
        self.m_down_user_score_down = self.m_down_user_score_change:getChildByName("down");
        self.m_down_user_coin_change = self.m_down_user_bg:getChildByName("coin_change");
        self.m_down_user_coin_up = self.m_down_user_coin_change:getChildByName("up");
        self.m_down_user_coin_down = self.m_down_user_coin_change:getChildByName("down");
        self.m_down_user_cup_change = self.m_down_user_bg:getChildByName("cup_change");
        self.m_down_user_win_img = self.m_down_user_bg:getChildByName("win_img");
        self.m_down_user_lose_img = self.m_down_user_bg:getChildByName("lose_img");
        self.m_down_user_draw_img = self.m_down_user_bg:getChildByName("draw_img");
        self.m_down_user_flag_img = self.m_down_user_bg:getChildByName("flag_img");
        self.m_down_user_bankrupt = self.m_down_user_bg:getChildByName("bankrupt");
        self.m_down_user_guanzhu = self.m_down_user_bg:getChildByName("guanzhu");
         self.m_down_user_guanzhu:setOnClick(self,self.onFollowDownUser);
        self.m_down_user_guanzhu_txt = self.m_down_user_guanzhu:getChildByName("txt");

    ------- result ------
    self.m_result_view = self.m_content_view:getChildByName("account_result_view");
        -- online_result
        self.m_online_result_view = self.m_result_view:getChildByName("online_result");
--            -- watch_result
--            self.m_watch_result_view = self.m_online_result_view:getChildByName("watch_result");            
        -- offline_result
        self.m_offline_result_view = self.m_result_view:getChildByName("offline_result");
            -- reward_bg
            self.m_reward_bg = self.m_offline_result_view:getChildByName("reward_bg");
                self.m_offline_tip = self.m_reward_bg:getChildByName("console_txt");
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
        -- dapu_result
        self.m_dapu_result_view = self.m_result_view:getChildByName("dapu_result");
            -- tips
            self.m_dapu_result_tips = self.m_dapu_result_view:getChildByName("tips");
                -- use_time
                self.m_dapu_use_time = self.m_dapu_result_tips:getChildByName("use_time");
                -- use_step
                self.m_dapu_use_step = self.m_dapu_result_tips:getChildByName("use_step");
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
    
    ------- logo -------
    self.m_logo_view = self.m_content_view:getChildByName("account_logo_view");

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

    self:stopTimer()
    delete(self.m_animLose)
    delete(self.m_animWin)
    delete(self.m_animWatch)
    delete(self.mFollowDialog)
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onEventResponse);
end


function AccountDialog:updateDoublePropView()
    if not self.mRoomDoubleProp then return end
    if not UserInfo.getInstance():isHasDoubleProp() then
        self.mRoomDoubleProp:setVisible(false)
    else
        self.mRoomDoubleProp:setVisible(true)
    end
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
--    if self.m_down_user_cup_change then
--        self.m_down_user_cup_change:removeAllChildren();
--    end;
--    if self.m_up_user_cup_change then
--        self.m_up_user_cup_change:removeAllChildren();
--    end;
--    if self.m_up_user_score_change then
--        self.m_up_user_score_change:removeAllChildren();
--    end;
--    if self.m_down_user_score_change then
--        self.m_down_user_score_change:removeAllChildren();
--    end;
--    if self.m_up_user_coin_change then
--        self.m_up_user_coin_change:removeAllChildren();
--    end;
--    if self.m_down_user_coin_change then
--        self.m_down_user_coin_change:removeAllChildren();
--    end;
    if self.m_down_user_bankrupt then
        self.m_down_user_bankrupt:setVisible(false);
    end;
    if self.m_up_user_bankrupt then
        self.m_up_user_bankrupt:setVisible(false);
    end;
    if self.m_up_user_ready_tip then
        self.m_up_user_ready_tip:setVisible(false);
    end;
end;

AccountDialog.resetRewardView = function(self)
    if self.m_dialog_type == RoomConfig.ROOM_TYPE_CONSOLE_ROOM or 
            self.m_dialog_type == RoomConfig.ROOM_TYPE_ENDGATE_ROOM 
        then
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
    self.m_logo_view:setVisible(false);
    self.m_button_view:setVisible(true);
end;

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
-- dialogType:房间类型
AccountDialog.show = function(self,room,flag,var,dialogType)
    -- 重置房间状态
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.ONLINE_ROOM_RESULT_FOLLOW)
    self:resetDialog();
    -- 虚化房间背景
    self:blurBehind(true);
    -- 联网游戏(联网，观战，自定义，好友,比赛)
    if self.mRoomDoubleProp then
        self.mRoomDoubleProp:setVisible(false)
    end
    self.m_dialog_type = dialogType;
    if dialogType == RoomConfig.ROOM_TYPE_NOVICE_ROOM or 
        dialogType == RoomConfig.ROOM_TYPE_INTERMEDIATE_ROOM or 
        dialogType == RoomConfig.ROOM_TYPE_MASTER_ROOM or 
        dialogType == RoomConfig.ROOM_TYPE_PRIVATE_ROOM or 
        dialogType == RoomConfig.ROOM_TYPE_FRIEND_ROOM or 
        dialogType == RoomConfig.ROOM_TYPE_WATCH_ROOM or  
        dialogType == RoomConfig.ROOM_TYPE_ARENA_ROOM
        then
        if dialogType == RoomConfig.ROOM_TYPE_NOVICE_ROOM or 
            dialogType == RoomConfig.ROOM_TYPE_INTERMEDIATE_ROOM or 
            dialogType == RoomConfig.ROOM_TYPE_MASTER_ROOM or 
            dialogType == RoomConfig.ROOM_TYPE_ARENA_ROOM
        then
            self:updateDoublePropView()
        end
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
            if RoomProxy.getInstance():getCurRoomType() == RoomConfig.ROOM_TYPE_WATCH_ROOM then
                self.m_result_txt:setVisible(true);
                self.m_result_txt:setText("双方和棋");
                self:setWatchAnim();
            else    
                self.m_result_txt:setVisible(false);
                self:setDrawAnim();
            end;
            self.m_up_user_draw_img:setVisible(true);
            self.m_down_user_draw_img:setVisible(true);
	    elseif flag == room.m_downUser:getFlag() then 
			room.m_upUser:setLosetimes(room.m_upUser:getLosetimes() + 1);
			room.m_downUser:setWintimes(room.m_downUser:getWintimes() + 1);
		    kEffectPlayer:playEffect(Effects.AUDIO_OVER_WIN);
            if RoomProxy.getInstance():getCurRoomType() == RoomConfig.ROOM_TYPE_WATCH_ROOM then
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
                self.m_share_btn:setAlign(kAlignBottom);
            end;
            self.m_up_user_lose_img:setVisible(true);
            self.m_down_user_win_img:setVisible(true);
            self.m_up_user_draw_img:setVisible(false);
            self.m_down_user_draw_img:setVisible(false);
	    else
			room.m_upUser:setWintimes(room.m_upUser:getWintimes() + 1);
			room.m_downUser:setLosetimes(room.m_downUser:getLosetimes() + 1);
            if RoomProxy.getInstance():getCurRoomType() == RoomConfig.ROOM_TYPE_WATCH_ROOM then
                self.m_result_txt:setVisible(true);
                self.m_result_txt:setText((((flag == 1) and "红方") or "黑方").."获胜:"..room.m_upUser:getName());
                self:setWatchAnim();
            else    
                self.m_result_txt:setVisible(false);
                self.m_continue_win = 0;
                self:setLoseAnim(room.m_downUser:getCoin());
            end;
            self.m_up_user_win_img:setVisible(true);
            self.m_down_user_lose_img:setVisible(true);
            self.m_up_user_draw_img:setVisible(false);
            self.m_down_user_draw_img:setVisible(false);
	    end
        if RoomProxy.getInstance():getCurRoomType() == RoomConfig.ROOM_TYPE_PRIVATE_ROOM
            or RoomProxy.getInstance():getCurRoomType() == RoomConfig.ROOM_TYPE_FRIEND_ROOM then
               self.m_button_1:setVisible(false); 
               self.m_button_2:setPos(0,0);
               self.m_button_2:setSize(526,nil);
        else
            self.m_button_1:setVisible(true); 
        end;
        self.m_button_1:setVisible(false);
        self.m_button_2:setVisible(true);
        self.m_button_3:setVisible(false);
        if RoomProxy.getInstance():getCurRoomType() == RoomConfig.ROOM_TYPE_WATCH_ROOM then
            -- 观战双方信息可见，隐藏自己的信息
            self.m_save_mychess_btn:setVisible(true);
            self.m_btn_txt2:setText("分享棋局");
            self.m_button_2:setOnClick(self, self.shareFuPan);
            self.m_button_2:setPos(0,0);
            self.m_button_2:setSize(526,nil);
        elseif RoomProxy.getInstance():getCurRoomType() == RoomConfig.ROOM_TYPE_ARENA_ROOM then
            self.m_save_mychess_btn:setVisible(true);
            self.m_btn_txt2:setText("再来一局");
            self.m_button_2:setOnClick(self, self.reSelect);
            self.m_button_2:setPos(0,0);
            self.m_button_2:setSize(526,nil);
        else
            -- 非观战双方信息不可见，显示自己的信息
            self.m_save_mychess_btn:setVisible(true);
            self.m_btn_txt2:setText("再来一局(*)");
            self.m_button_2:setOnClick(self, self.reStart);
            self.m_button_2:setPos(0,0);
            self.m_button_2:setSize(526,nil);
        end;
        self:showUsersInfo(room);
        self:resetSaveBtn();
        self.m_online_view:setVisible(true);
        self.m_board_view:setVisible(false);
        self.m_offline_result_view:setVisible(false);
        self.m_button_view:setSize(nil,400);
        self.m_logo_view:setSize(nil,400);

    -- 断网对战(单机，残局，打谱)  
    elseif dialogType == RoomConfig.ROOM_TYPE_CONSOLE_ROOM or 
            dialogType == RoomConfig.ROOM_TYPE_ENDGATE_ROOM or
            dialogType == RoomConfig.ROOM_TYPE_DAPU_ROOM
        then
        self.m_isLastestGate = var[1]; -- 是否最新关卡
        self.m_offline_type = var[2];  -- 1单机，2残局,3打谱
        self.m_button_1:setVisible(true);
        self.m_button_2:setVisible(true);
        self.m_button_3:setVisible(false);
        self.m_online_view:setVisible(false);
        self.m_offline_result_view:setVisible(true);
        self.m_save_mychess_btn:setVisible(false);
	    if flag == 0 then-- flag == 0和棋，1红方胜利，2黑方胜利
            if self.m_offline_type == 1 then
                self.m_btn_txt1:setText("分享");
                self.m_btn_txt2:setText("再来一局");
            elseif self.m_offline_type == 2 then
                self.m_btn_txt1:setText("分享");
                self.m_btn_txt2:setText("再来一局");
            elseif self.m_offline_type == 3 then
                self.m_btn_txt1:setText("重选模式");
                self.m_btn_txt2:setText("再来一局");
            end;
		    kEffectPlayer:playEffect(Effects.AUDIO_OVER_DRAW);
            if dialogType == RoomConfig.ROOM_TYPE_DAPU_ROOM then
                local timeStep = var[3];
                self.m_result_txt:setVisible(true);
                self.m_result_txt:setText((((flag == 1) and "红方") or "黑方").."获胜:"..room.m_upUser:getName());
                self:setWatchAnim();
                self.m_button_1:setOnClick(self, self.dapuReSelect);
                self.m_button_2:setOnClick(self, self.nextGate);
                self.m_save_mychess_btn:setVisible(true);
                self.m_offline_result_view:setVisible(false);
                self.m_dapu_result_view:setVisible(true);
                self.m_dapu_use_time:setText(timeStep[1] or "");
                self.m_dapu_use_step:setText(timeStep[2] or "");
            else
                self.m_dynamic_title:setVisible(true);
                self:setDrawAnim();
                self.m_reward_bg:setVisible(false);
                self.m_lose_tips:setVisible(true);
                self.m_offline_third_line:setVisible(false); 
                self.m_button_1:setOnClick(self, self.share);
                self.m_button_2:setOnClick(self, self.rePlay);
            end;
	    elseif flag ==  room.m_downUser:getFlag() then
            if self.m_offline_type == 1 then
                self.m_btn_txt1:setText("分享");
                self.m_btn_txt2:setText("再来一局");
                self.m_offline_tip:setText("首次通关可抽取幸运宝箱");
            elseif self.m_offline_type == 2 then
                self.m_btn_txt1:setText("分享");
                self.m_btn_txt2:setText("下一关");
                self.m_offline_tip:setText("首次通关可抽取幸运宝箱");
            elseif self.m_offline_type == 3 then
                self.m_btn_txt1:setText("重选模式");
                self.m_btn_txt2:setText("再来一局");
            end;
            kEffectPlayer:playEffect(Effects.AUDIO_OVER_WIN);
            if dialogType == RoomConfig.ROOM_TYPE_DAPU_ROOM then
                local timeStep = var[3];
                self.m_result_txt:setVisible(true);
                self.m_result_txt:setText((((flag == 1) and "红方") or "黑方").."获胜:"..room.m_upUser:getName());
                self:setWatchAnim();
                self.m_button_1:setOnClick(self, self.dapuReSelect);
                self.m_button_2:setOnClick(self, self.nextGate);
                self.m_save_mychess_btn:setVisible(true);
                self.m_offline_result_view:setVisible(false);
                self.m_dapu_result_view:setVisible(true);
                self.m_dapu_use_time:setText(timeStep[1] or "");
                self.m_dapu_use_step:setText(timeStep[2] or "");
            else
                self.m_button_1:setOnClick(self, self.share);
                self.m_button_2:setOnClick(self, self.nextGate);
                self.m_dynamic_title:setVisible(true);
                self.m_content_bg:setVisible(true)
                self.m_offline_continue_win = self.m_offline_continue_win + 1;
                self:setOffWinAnim();
                -- 挑战成功，如果最新关，就抽奖；否则提示“领过奖励”
                if self.m_isLastestGate then
                    self.m_reward_bg:setVisible(true);
                    self.m_lose_tips:setVisible(false);
                    -- 已获取奖励，就不可以再点击，默认没有领取过
                    self.m_has_get_chest = false;
                else
                    self.m_reward_bg:setVisible(false);
                    self.m_lose_tips:setVisible(true);
                    self.m_offline_first_line:setVisible(false);
                    self.m_offline_second_line:setVisible(false);
                    self.m_offline_third_line:setVisible(true);  
                    if UserInfo.getInstance():isLogin() then
                        self.m_offline_third_line:setText("您在此关已领过奖励！");
                    else
                        self.m_offline_third_line:setText("网络异常");
                    end;                
                end;
            end;
	    else
            if self.m_offline_type == 1 then
                self.m_btn_txt1:setText("分享");
                self.m_btn_txt2:setText("再来一局");
            elseif self.m_offline_type == 2 then
                self.m_btn_txt1:setText("分享");
                self.m_btn_txt2:setText("再来一局");
            elseif self.m_offline_type == 3 then
                self.m_btn_txt1:setText("重选模式");
                self.m_btn_txt2:setText("再来一局");         
            end;
            if dialogType == RoomConfig.ROOM_TYPE_DAPU_ROOM then
                local timeStep = var[3];
                self.m_result_txt:setVisible(true);
                self.m_result_txt:setText((((flag == 1) and "红方") or "黑方").."获胜:"..room.m_upUser:getName());
                self:setWatchAnim();
                self.m_button_1:setOnClick(self, self.dapuReSelect);
                self.m_button_2:setOnClick(self, self.nextGate);
                self.m_save_mychess_btn:setVisible(true);
                self.m_offline_result_view:setVisible(false);
                self.m_dapu_result_view:setVisible(true);
                self.m_dapu_use_time:setText(timeStep[1] or "");
                self.m_dapu_use_step:setText(timeStep[2] or "");
            else
                self.m_button_1:setOnClick(self, self.share);
                self.m_button_2:setOnClick(self, self.rePlay);
                self.m_dynamic_title:setVisible(true);
                self.m_content_bg:setVisible(false)
                self.m_offline_continue_win = 0;
                if dialogType == RoomConfig.ROOM_TYPE_DAPU_ROOM then
                    self:setWatchAnim();
                else
                    self:setOffLoseAnim();
                end;
                -- 挑战失败,显示提示语
                self.m_reward_bg:setVisible(false);
                self.m_lose_tips:setVisible(true); 
                self.m_offline_first_line:setVisible(true);
                self.m_offline_second_line:setVisible(true);
                self.m_offline_third_line:setVisible(false);  
            end;                
	    end       
        if kPlatform == kPlatformIOS then
            if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
                self.m_button_1:setVisible(true);
            else
                self.m_button_1:setVisible(false);
            end;
        else
            self.m_button_1:setVisible(true);
        end;
    end;
    -- board缩略图
    self:showBoardScaleView();

    -- 观战/offline游戏不显示倒计时
    if dialogType == RoomConfig.ROOM_TYPE_NOVICE_ROOM or 
            dialogType == RoomConfig.ROOM_TYPE_INTERMEDIATE_ROOM or 
            dialogType == RoomConfig.ROOM_TYPE_MASTER_ROOM or 
            dialogType == RoomConfig.ROOM_TYPE_PRIVATE_ROOM or 
            dialogType == RoomConfig.ROOM_TYPE_FRIEND_ROOM
        then
        self:startTimer();
    end

    -- 自动保存到“最近对战”
    self:save();

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

-- 2.4.0版本联网，观战，好友，上下用户信息
AccountDialog.showUsersInfo = function(self, room)
	if room.m_downUser then
        if not self.m_user_head_icon then
            self.m_down_user_icon = new(Mask,UserInfo.DEFAULT_ICON[1],"hall/icon_frame_mask.png");
            self.m_down_user_icon:setSize(self.m_down_user_frame:getSize());
            self.m_down_user_frame:addChild(self.m_down_user_icon);
        end
        -- vip
        local data = FriendsData.getInstance():getUserData(room.m_downUser:getUid());
        if data then
            local frameRes = UserSetInfo.getInstance():getFrameRes(data.my_set);
            if frameRes then 
                self.m_down_user_vip:setVisible(frameRes.visible);
                if frameRes.frame_res then
                    self.m_down_user_vip:setFile(string.format(frameRes.frame_res,110));
                end
            end
        end;
        if room.m_downUser:getIconType() == -1 then
            self.m_down_user_icon:setUrlImage(room.m_downUser:getIcon(),UserInfo.DEFAULT_ICON[1]);
        else
            self.m_down_user_icon:setFile(UserInfo.DEFAULT_ICON[room.m_downUser:getIconType()] or UserInfo.DEFAULT_ICON[1]);
        end

		self.m_down_user_nick:setText(GameString.convert2UTF8(room.m_downUser:getName()));
        self.m_down_user_level:setFile(string.format("common/icon/level_%d.png",10-self:getUserLevel(room.m_downUser:getScore())));
		self.m_down_user_score:setText(GameString.convert2UTF8("积分:" .. room.m_downUser:getScore()));
       
        -- 积分变化
        local scoreChange = self:getScoreChangeText(room.m_downUser:getPoint(),room.m_downUser:getUid());
        local sW,sH = self.m_down_user_score:getSize();
        local sX,sY = self.m_down_user_score:getPos();
        self.m_down_user_score_change:setPos(sX+sW,nil);
        self.m_down_user_score_change:setSize(scoreChange:getSize());
        self.m_down_user_score_change:addChild(scoreChange);
        if tonumber(room.m_downUser:getPoint()) and tonumber(room.m_downUser:getPoint()) > 0 then
            self.m_down_user_score_up:setVisible(true);
        elseif tonumber(room.m_downUser:getPoint()) and tonumber(room.m_downUser:getPoint()) < 0 then
            self.m_down_user_score_down:setVisible(true);
        end;
        self.m_down_user_coin:setText("金币:");--..ToolKit.getMoneyStr(room.m_downUser:getMoney()));
        -- 金币变化
        local coinChange = self:getCoinChangeText(room.m_downUser:getCoin(),room.m_downUser:getTabCoin());
        local tabCoinChange = self:getCoinTabText(room.m_downUser:getTabCoin());
        local cW,cH = self.m_down_user_coin:getSize();
        local cX,cY = self.m_down_user_coin:getPos();
        local ccW,ccH = coinChange:getSize();
        local ctW,ctH = 0,0
        if tabCoinChange then
            tabCoinChange:setPos(ccW,1)
            ctW,ctH = tabCoinChange:getSize()
            self.m_down_user_coin_change:addChild(tabCoinChange);
        end
--        self.m_down_user_coin_change:setPos(cW,nil);
--        self.m_down_user_coin_change:setPos((cW - ccW)/2 + ccW,nil);
        self.m_down_user_coin_change:setSize(ctW + ccW,ccH);
        self.m_down_user_coin_change:addChild(coinChange);
--        if tonumber(room.m_downUser:getCoin()) and tonumber(room.m_downUser:getCoin()) > 0 then
--            self.m_down_user_coin_up:setVisible(true);
--        elseif tonumber(room.m_downUser:getCoin()) and tonumber(room.m_downUser:getCoin()) < 0 then
--            self.m_down_user_coin_down:setVisible(true);
--        end;
        -- 奖杯变化（竞技场）
        local cupChange = self:getCupChangeText(room.m_downUser:getCup());
        self.m_down_user_cup_change:addChild(cupChange); 

        -- 是否破产
        if tonumber(room.m_downUser:getMoney()) and  room.m_downUser:getMoney() == 0 then
            self.m_down_user_bankrupt:setVisible(true);
            self.m_up_user_bankrupt:setVisible(false);
        end;

        if room.m_downUser:getUid() ~= UserInfo.getInstance():getUid() then
            self.m_down_user_guanzhu:setVisible(true);
            if self:isFollow(room.m_downUser:getUid()) then
                self.m_down_user_guanzhu_txt:setText("已关注");
            else
                self.m_down_user_guanzhu_txt:setText("+ 关注");
            end;
        end;
        
	end
	if room.m_upUser then
        if not self.m_user_head_icon then
            self.m_up_user_icon = new(Mask,UserInfo.DEFAULT_ICON[1],"hall/icon_frame_mask.png");
            self.m_up_user_icon:setSize(self.m_up_user_frame:getSize());
            self.m_up_user_frame:addChild(self.m_up_user_icon);
        end
        -- vip
        local data = FriendsData.getInstance():getUserData(room.m_upUser:getUid());
        if data then
            local frameRes = UserSetInfo.getInstance():getFrameRes(data.my_set);
            if frameRes then 
                self.m_up_user_vip:setVisible(frameRes.visible);
                if frameRes.frame_res then
                    self.m_up_user_vip:setFile(string.format(frameRes.frame_res,110));
                end
            end
        end;
        if room.m_upUser:getIconType() == -1 then
            self.m_up_user_icon:setUrlImage(room.m_upUser:getIcon(),UserInfo.DEFAULT_ICON[1]);
        else
            self.m_up_user_icon:setFile(UserInfo.DEFAULT_ICON[room.m_upUser:getIconType()] or UserInfo.DEFAULT_ICON[1]);
        end
		self.m_up_user_nick:setText(GameString.convert2UTF8(room.m_upUser:getName()));
        self.m_up_user_level:setFile(string.format("common/icon/level_%d.png",10-self:getUserLevel(room.m_upUser:getScore())));
		self.m_up_user_score:setText(GameString.convert2UTF8("积分:" .. room.m_upUser:getScore()));
        
        -- 积分变化
        local scoreChange = self:getScoreChangeText(room.m_upUser:getPoint(),room.m_upUser:getUid());
        local sW,sH = self.m_up_user_score:getSize();
        local sX,sY = self.m_up_user_score:getPos();
        self.m_up_user_score_change:setPos(sX+sW,nil);
        self.m_up_user_score_change:setSize(scoreChange:getSize());
        self.m_up_user_score_change:addChild(scoreChange);
        if tonumber(room.m_upUser:getPoint()) and tonumber(room.m_upUser:getPoint()) > 0 then
            self.m_up_user_score_up:setVisible(true);
        elseif tonumber(room.m_upUser:getPoint()) and tonumber(room.m_upUser:getPoint()) < 0 then
            self.m_up_user_score_down:setVisible(true);
        end;
        self.m_up_user_coin:setText("金币:")--..ToolKit.getMoneyStr(room.m_upUser:getMoney()));

        -- 金币变化
        local coinChange = self:getCoinChangeText(room.m_upUser:getCoin(),room.m_upUser:getTabCoin());
        local tabCoinChange = self:getCoinTabText(room.m_upUser:getTabCoin());
        local cW,cH = self.m_up_user_coin:getSize();
        local cX,cY = self.m_up_user_coin:getPos();
        local ccW,ccH = coinChange:getSize();
        local ccX,ccY = coinChange:getPos();
        local ctW,ctH = 0,0
        if tabCoinChange then
            tabCoinChange:setPos(ccW,1)
            ctW,ctH = tabCoinChange:getSize()
            self.m_up_user_coin_change:addChild(tabCoinChange);
        end
--        self.m_up_user_coin_change:setPos(cW,nil);
--        self.m_up_user_coin_change:setPos((cW - ccW)/2 + ccW,nil);
        self.m_up_user_coin_change:setSize(ctW + ccW ,ccH);
        self.m_up_user_coin_change:addChild(coinChange);
--        if tonumber(room.m_upUser:getCoin()) and tonumber(room.m_upUser:getCoin()) > 0 then
--            self.m_up_user_coin_up:setVisible(true);
--        elseif tonumber(room.m_upUser:getCoin()) and tonumber(room.m_upUser:getCoin()) < 0 then
--            self.m_up_user_coin_down:setVisible(true);
--        end;
        -- 奖杯变化（竞技场）
        local cupChange = self:getCupChangeText(room.m_upUser:getCup());
        self.m_up_user_cup_change:addChild(cupChange);      

        -- 是否破产
        if tonumber(room.m_upUser:getMoney()) and  room.m_upUser:getMoney() == 0 then
            self.m_up_user_bankrupt:setVisible(true);
            self.m_down_user_bankrupt:setVisible(false);
        end;

        if room.m_upUser:getUid() ~= UserInfo.getInstance():getUid() then
            self.m_up_user_guanzhu:setVisible(true);
            if self:isFollow(room.m_upUser:getUid()) then
                self.m_up_user_guanzhu_txt:setText("已关注");
            else
                self.m_up_user_guanzhu_txt:setText("+ 关注");
                if NoviceBootProxy.getInstance():isFirstShow(NoviceBootProxy.s_constant.ONLINE_ROOM_RESULT_FOLLOW) then
                    local guideTip = NoviceBootProxy.getInstance():getGuideTipView(NoviceBootProxy.s_constant.ONLINE_ROOM_RESULT_FOLLOW)
                    guideTip:setAlign(kAlignCenter)
                    local w,h = self.m_up_user_guanzhu:getSize()
                    guideTip:setTipSize(w+20)
                    guideTip:startAnim()
                    guideTip:setBottomTipText("喜欢TA，点击关注可以快速追踪对方和发起挑战哦",-80,110,250,50,80)
                    self.m_up_user_guanzhu:addChild(guideTip)
                    NoviceBootProxy.getInstance():setGuideTipViewShowTime(NoviceBootProxy.s_constant.ONLINE_ROOM_RESULT_FOLLOW)
                end
            end;
        end;
	end 
    -- 好友/私人房不显示积分信息
    if self.m_dialog_type == RoomConfig.ROOM_TYPE_FRIEND_ROOM
        or self.m_dialog_type == RoomConfig.ROOM_TYPE_PRIVATE_ROOM then
        self.m_down_user_coin_change:setVisible(true);
        self.m_up_user_coin_change:setVisible(true);
        self.m_down_user_cup_change:setVisible(false);
        self.m_up_user_cup_change:setVisible(false);
        self.m_down_user_coin:setVisible(true);
        self.m_down_user_coin_icon:setVisible(true);
        self.m_up_user_coin:setVisible(true);
        self.m_up_user_coin_icon:setVisible(true);
    elseif self.m_dialog_type == RoomConfig.ROOM_TYPE_ARENA_ROOM then -- 竞技场
        self.m_down_user_score_change:setVisible(true);
        self.m_up_user_score_change:setVisible(true);
        self.m_down_user_cup_change:setVisible(true);
        self.m_up_user_cup_change:setVisible(true);
        self.m_down_user_coin_change:setVisible(false);
        self.m_up_user_coin_change:setVisible(false);
        self.m_down_user_coin:setVisible(false);
        self.m_down_user_coin_icon:setVisible(false);
        self.m_up_user_coin:setVisible(false);
        self.m_up_user_coin_icon:setVisible(false);
    else
        if RoomProxy.getInstance():getRoomLevel() == 330 then -- 观战的是竞技场结算显示奖杯，不显示金币
            self.m_down_user_cup_change:setVisible(true);
            self.m_up_user_cup_change:setVisible(true); 
            self.m_down_user_coin_change:setVisible(false);
            self.m_up_user_coin_change:setVisible(false);  
            self.m_down_user_coin:setVisible(false);
            self.m_down_user_coin_icon:setVisible(false);
            self.m_up_user_coin:setVisible(false);
            self.m_up_user_coin_icon:setVisible(false);
        else
            self.m_down_user_cup_change:setVisible(false);
            self.m_up_user_cup_change:setVisible(false); 
            self.m_down_user_coin_change:setVisible(true);
            self.m_up_user_coin_change:setVisible(true);  
            self.m_down_user_coin:setVisible(true);
            self.m_down_user_coin_icon:setVisible(true);
            self.m_up_user_coin:setVisible(true);
            self.m_up_user_coin_icon:setVisible(true);
        end;
        self.m_down_user_score_change:setVisible(true);
        self.m_up_user_score_change:setVisible(true);   
    end;
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

-- 获得Users棋力等级
AccountDialog.getUserLevel = function(self, score)
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
    self.m_board_view:removeAllChildren();
    local w,h = 587, 660;
    self.m_scale_board:setSize(w,h);
    self.m_board_view:addChild(self.m_scale_board);  
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

function AccountDialog.getCoinTabText(self,tabcoin)
    if not tabcoin then return end
    local num = tonumber(tabcoin)
    local tab_change_txt = nil
    if not num or num == 0 then
        return 
    end
    num = "-" .. num 
    tab_change_txt = new(Text,num,nil,nil,kAlignLeft,nil,32,120,120,120);
    return tab_change_txt
end

AccountDialog.getCoinChangeText = function(self, coin, tabcoin)
    if not tonumber(coin) then return end;
    if not tonumber(tabcoin) then return end;
    local coin_change = tonumber(coin);
    local tab_coin = tonumber(tabcoin)
--    local tab_coin_tr = tabcoin
    local coin_change_txt = nil;
    local moneyStr = nil --ToolKit.getMoneyStr(coin_change - tab_coin) .. tab_coin_tr
    if coin_change > 0 then
        moneyStr = "+" .. ToolKit.getMoneyStr(coin_change)
        coin_change_txt = new(Text,moneyStr,nil,nil,kAlignLeft,nil,32,255,220,75);
    elseif coin_change <= 0 then
        moneyStr =  ToolKit.getMoneyStr(coin_change)-- + tab_coin)
        coin_change_txt = new(Text,moneyStr,nil,nil,kAlignLeft,nil,32,200,25,25);
    else
        coin_change_txt = new(Text,"",nil,nil,kAlignLeft,nil,32,200,25,25);
    end;    
    return coin_change_txt;
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

function AccountDialog.getScoreChangeText(self, score,uid)
    if not tonumber(score) then return end;
    local score_change = tonumber(score);
    local score_change_txt = nil;
    if score_change > 0 then
        if UserInfo.getInstance():isHasDoubleProp() and UserInfo.getInstance():getUid() == tonumber(uid) then
            score_change_txt = new(Text,"(+"..score_change.." 双倍)",nil,nil,kAlignLeft,nil,32,255,220,75);
        else
            score_change_txt = new(Text,"(+"..score_change..")",nil,nil,kAlignLeft,nil,32,255,220,75);
        end
    elseif score_change < 0 then
        score_change_txt = new(Text,"("..score_change..")",nil,nil,kAlignLeft,nil,32,200,25,25);
    else
        score_change_txt = new(Text,"",nil,nil,kAlignLeft,nil,32,200,25,25);
    end;    
    return score_change_txt;
end;

function AccountDialog.getCupChangeText(self, cup)
    if not tonumber(cup) then return end;
    local cup_change = tonumber(cup);
    local cup_change_txt = nil;
    if cup_change >= 0 then
        cup_change_txt = new(Text,"奖杯:(+"..cup_change..")",nil,nil,kAlignLeft,nil,32,255,220,75);
    else
        cup_change_txt = new(Text,"奖杯:("..cup_change..")",nil,nil,kAlignLeft,nil,32,200,25,25);
    end;    
    return cup_change_txt;
end;

-- 观战动画设置
AccountDialog.setWatchAnim = function(self)
    delete(self.m_animWatch)
    self.m_animWatch = new(AnimWin);
    self.m_animWatch:setWatch("animation/game_over.png");
    self.m_animWatch:setAlign(kAlignTop);
    self.m_dynamic_anim:addChild(self.m_animWatch);
    self.m_animWatch:play();  
end;

-- 和棋动画设置
AccountDialog.setDrawAnim = function(self)
    delete(self.m_animWin)
    self.m_animWin = new(AnimWin);
    self.m_animWin:setAlign(kAlignTop);
    self.m_animWin:setDraw("animation/draw.png");
    self.m_dynamic_anim:addChild(self.m_animWin);
    self.m_animWin:play();   
end;

-- 联网胜利动画设置
AccountDialog.setWinAnim = function(self, coin_change)
    delete(self.m_animWin)
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
    delete(self.m_animLose)
    self.m_animLose = new(AnimLose);
    self.m_animLose:setAlign(kAlignTop);
    self.m_dynamic_anim:addChild(self.m_animLose);
    self.m_animLose:play();   
    
end;

-- 离线游戏胜利动画
AccountDialog.setOffWinAnim = function(self)
    delete(self.m_animWin)
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
    delete(self.m_animLose)
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
        self.m_button_2:setOnClick(self,self.reSelect);
        self.m_btn_txt2:setText("再来一局");
    else
        self.m_account_again_btn_timeout = self.m_account_again_btn_timeout - 1;
    end;
end;
--[Comment]
--(暂时移到Room)不能移动到Room，弹出的选择框会因为用户离开而消失!
-- 0 不能继续
-- 1 能继续
-- 2 推荐支付
AccountDialog.canContinue = function(self)
    local roomConfig = RoomConfig.getInstance();
    local roomProxy = RoomProxy.getInstance();
    local curRoomType = roomProxy:getCurRoomType();
    local money = UserInfo.getInstance():getMoney();
	local isCanAccess = roomProxy:checkCanJoinRoom(curRoomType,money);
    local canEntryRoom = roomProxy:getMatchRoomByMoney(money);

    if curRoomType == RoomConfig.ROOM_TYPE_FRIEND_ROOM or curRoomType == RoomConfig.ROOM_TYPE_PRIVATE_ROOM then 
        --好友房 私人房 破产直接退出
        if not isCanAccess then
            self:collapse();
            return 0;
        else
            return 1;
        end
    end
    -- 其他房间 如果没有任何可以进入的房间 破产
    -- 这里换房间存在bug  需求暂时砍掉 -- 重构 bearluo
    if not isCanAccess then
        -- 结算的时候判断自己是不是破产了···
        -- 金币场才判断
        if RoomProxy.getInstance():getCurRoomType() == RoomConfig.ROOM_TYPE_NOVICE_ROOM or
            RoomProxy.getInstance():getCurRoomType() == RoomConfig.ROOM_TYPE_INTERMEDIATE_ROOM or
            RoomProxy.getInstance():getCurRoomType() == RoomConfig.ROOM_TYPE_MASTER_ROOM then
            if self:collapseRecommendation() then
                return 2
            else
                return 0 
            end
        else
            self:collapse();
        end
        return 0;
    else
        return 1;
    end
end
--[Comment]
-- 破产推荐购买
function AccountDialog:collapseRecommendation()
    local config = RoomProxy.getInstance():getCurRoomConfig()
    local isHasRecommendation = false
    local goods
    if config then
        local money = UserInfo.getInstance():getMoney()
        goods = MallData.getInstance():getGoodsByMoreMoney(config.minmoney - money)
        if goods then
            isHasRecommendation = true
        end
    end
    if not isHasRecommendation then self:collapse() return false end


	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end
	local message = string.format("您所剩余的金币不足以留在场内,是否立即花%d元购买%s?",goods.price,goods.name);
	self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE);
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:setPositiveListener(self,function()
        local payInterface = PayUtil.getPayInstance(PayUtil.s_defaultType);
        local payData = {}
        payData.pay_scene = PayUtil.s_pay_scene.money_room_recommend
        --  推荐支付方式
		payInterface:createOrder(goods, -1, paydata);
    end);
	self.m_chioce_dialog:setNegativeListener(self.m_room,self.m_room.exitRoom)
    self.m_chioce_dialog:setNeedBackEvent(false)
	self.m_chioce_dialog:show();
    return true
end

--破产
AccountDialog.collapse = function(self)
	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end
	local message = "您的金币不足以继续游戏,即将返回大厅";
	self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE,"知道了");
	self.m_chioce_dialog:setMessage(message);
    self.m_chioce_dialog:setNeedBackEvent(false);
	self.m_chioce_dialog:setPositiveListener(self.m_room,self.m_room.exitRoom);
	self.m_chioce_dialog:setNegativeListener(self.m_room,self.m_room.exitRoom);
	self.m_chioce_dialog:show();
end

--前往
AccountDialog.goLowRoom = function(self)
	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end

	local message = "您的金币不足在该场次游戏,前往低底注场虐菜？";
	self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE,"知道了");
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:setPositiveListener(self.m_room,self.m_room.exitRoom);
	self.m_chioce_dialog:setNegativeListener(self.m_room,self.m_room.exitRoom)
    self.m_chioce_dialog:setNeedBackEvent(false)
	self.m_chioce_dialog:show();
end

AccountDialog.goHighRoom = function(self)
	if not self.m_chioce_dialog then
		self.m_chioce_dialog = new(ChioceDialog);
	end

	local message = "您的金币超出该场次最高限额,挑战高底注场？";
	self.m_chioce_dialog:setMode();
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:setPositiveListener(self.m_room,self.m_room.exitRoom);
	self.m_chioce_dialog:setNegativeListener(self.m_room,self.m_room.exitRoom)
    self.m_chioce_dialog:setNeedBackEvent(false)
	self.m_chioce_dialog:show();
end

AccountDialog.onCancel = function(self)
    self:dismiss();
end

AccountDialog.onSaveMychess = function(self)
   -- 收藏弹窗
    if not self.m_mysave_dialog then
        self.m_mysave_dialog = new(ChioceDialog)
    end;
    self.m_mysave_dialog:setMode(ChioceDialog.MODE_SHOUCANG);  
    self.m_save_cost = UserInfo.getInstance():getFPcostMoney().save_manual;  
    if tonumber(self.m_save_cost) == 0 then
--        self.m_mysave_dialog:setMessage("收藏棋谱免费，确认收藏？");
        self:saveChesstoMysave();
    else
        self.m_mysave_dialog:setMessage("是否花费"..(self.m_save_cost or 500) .."金币收藏当前棋谱？");
        self.m_mysave_dialog:setPositiveListener(self, self.saveChesstoMysave);
        self.m_mysave_dialog:show();   
    end;
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
    else    
        ChessToastManager.getInstance():showSingle("复盘数据不存在")
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
        self.m_reward_win_chest[index]:setPickable(false);
        if (index - 1) == selected then
            local anim = self.m_reward_win_chest[index]:addPropRotate(1, kAnimLoop, 70, -1, -10, 10, kCenterDrawing);
            if anim then
                anim:setEvent(self, function(a, b, c,repeat_or_loop_num) 
                    if repeat_or_loop_num == 15 then
                        self.m_reward_win_chest[index]:removeProp(1);
                        self.m_reward_win_chest[index]:setFile("common/decoration/chest_2.png");
                    end;
                end);
            end;
            break;
        end;
       
    end;
    local anim = new(AnimInt,kAnimNormal,0,1,700,-1);
    if anim then
        anim:setEvent(nil, function() 
            local post_data = {};
	        post_data.draw_type = "alone";
            post_data.click_pos = selected;
            post_data.draw_tid = 1;-- 大关卡
            post_data.draw_pos = UserInfo.getInstance():getPlayingLevel();-- 小关卡
            HttpModule.getInstance():execute(HttpModule.s_cmds.getReward,post_data);            
        end);
    end;
end

-- 残局抽奖
AccountDialog.randomChestEndgate = function(self,selected)
    for index = 1, 3 do
        self.m_reward_win_chest[index]:setPickable(false);
        if (index - 1) == selected then
            local anim = self.m_reward_win_chest[index]:addPropRotate(1, kAnimLoop, 70, -1, -10, 10, kCenterDrawing);
            if anim then
                anim:setEvent(self, function(a, b, c,repeat_or_loop_num) 
                    if repeat_or_loop_num == 15 then
                        self.m_reward_win_chest[index]:removeProp(1);
                        self.m_reward_win_chest[index]:setFile("common/decoration/chest_2.png");
                    end;
                end);
            end;
            break;
        end;
    end; 
     
    local anim = new(AnimInt,kAnimNormal,0,1,700,-1);
    if anim then
        anim:setEvent(nil, function() 
            local post_data = {};
            post_data.draw_type = "booth";
            post_data.click_pos = selected;
            post_data.booth_tid = kEndgateData:getGateTid();-- 大关卡
            post_data.booth_pos = kEndgateData:getGateSort();-- 小关卡
            HttpModule.getInstance():execute(HttpModule.s_cmds.getReward,post_data);          
        end);
    end;
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
		self.m_has_get_chest = true; --已获取奖励，就不可以再点击
        -- 选中的奖品
		if result[index].is_reward == 1 then
            self.m_reward_win_chest_shine[index]:setVisible(true);
            self.m_reward_win_chest[index]:setVisible(false);
            self.m_reward_win_tips[index]:setVisible(true);
   		    self.m_reward_win_tips[index]:setText(string.format("+%d",result[index].num));
		    self.m_reward_icon[index]:setVisible(true);
            self.m_reward_icon[index]:setFile(self:getChestFile(result[index].rtype, result[index].propid) or "endgate/ending_chest_texture.png");
            self.m_reward_icon[index]:addPropScaleSolid(1,0.8,0.8,kCenterDrawing);
		else
            self.m_reward_win_chest_shine[index]:setVisible(false);
            self.m_reward_win_tips[index]:setVisible(false);
            self.m_reward_icon[index]:setVisible(false);
        end
	end    
end;

-- 第一个宝箱
AccountDialog.selectFunc1 = function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
	 --已获取奖励，就不可以再点击
	if self.m_has_get_chest then
		print_string("AccountDialog.selectFunc1 but self.m_has_get_chest");
		return
	end
    local isSocketOpen = OnlineSocketManager.getHallInstance():isSocketOpen();
    if not UserInfo.getInstance():isLogin() or not UserInfo.getInstance():getConnectHall() 
        or not isSocketOpen then
        ChessToastManager.getInstance():showSingle("未连接网络，无法抽取奖励哦");
        return;
    end;
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
    local isSocketOpen = OnlineSocketManager.getHallInstance():isSocketOpen();
    if not UserInfo.getInstance():isLogin() or not UserInfo.getInstance():getConnectHall() 
        or not isSocketOpen then
        ChessToastManager.getInstance():showSingle("未连接网络，无法抽取奖励哦");
        return;
    end;
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
    local isSocketOpen = OnlineSocketManager.getHallInstance():isSocketOpen();
    if not UserInfo.getInstance():isLogin() or not UserInfo.getInstance():getConnectHall() 
        or not isSocketOpen then
        ChessToastManager.getInstance():showSingle("未连接网络，无法抽取奖励哦");
        return;
    end;
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
    -- 单机/残局最新关没有抽取宝箱，弹提示弹窗
    if self.m_offline_type == 1 then
        if not self.m_has_get_chest and self.m_isLastestGate then
            self:loadHasChestCanGet(1);
        else
            self:loadNextGate();
        end;
    elseif self.m_offline_type == 2 then
        if self.m_isLastestGate and not self.m_has_get_chest then
            self:loadHasChestCanGet(2);
        else
            self:loadNextGate(); 
        end;
    elseif self.m_offline_type == 3 then
        self:dapuReplay();
    end;
end;

-- 加载还有宝箱可以领取
AccountDialog.loadHasChestCanGet = function(self,offlineType)
    if not self.m_get_chest_tip_dlg then
        self.m_get_chest_tip_dlg = new(ChioceDialog);
    end;
    self.m_get_chest_tip_dlg:setMode(ChioceDialog.MODE_SURE,"继续","取消");
    if offlineType == 1 then
        self.m_get_chest_tip_dlg:setMessage("宝箱还没有领取，是否放弃奖励？");
        self.m_get_chest_tip_dlg:setPositiveListener(self,function()
            self:loadNextGate();
        end);        
    elseif offlineType == 2 then
        local isSocketOpen = OnlineSocketManager.getHallInstance():isSocketOpen();
        if not UserInfo.getInstance():isLogin() or not UserInfo.getInstance():getConnectHall() 
            or not isSocketOpen then
            self.m_get_chest_tip_dlg:setMessage("联网才能领取宝箱，继续操作将默认放弃奖励，是否继续？");
            self.m_get_chest_tip_dlg:setPositiveListener(self,self.loadNextGate);
        else
            self.m_get_chest_tip_dlg:setMessage("宝箱还没有领取，点击取消可返回领取，继续操作将会为您随机分配奖励");
            self.m_get_chest_tip_dlg:setPositiveListener(self,function()
                self:randomGetChest();
                self:loadNextGate();
            end);
        end;
    end;
    self.m_get_chest_tip_dlg:show();
end;

AccountDialog.randomGetChest = function(self)
    math.randomseed(os.time());
    local selected = math.random(0,2);
    local post_data = {};
    post_data.draw_type = "booth";
    post_data.click_pos = selected;
    HttpModule.getInstance():execute(HttpModule.s_cmds.getReward,post_data);     
end;

AccountDialog.loadNextGate = function(self)
    self.super.dismiss(self);
    self:setVisible(false);
    self:resetDialog();
    if self.m_room.m_controller then
        self.m_room.m_controller:loadNextGate();
    end;
end;

AccountDialog.dapuReplay = function(self)
    self.super.dismiss(self);
    self:setVisible(false);
    self:resetDialog();
    if self.m_room then
        self.m_room:restart_action();
    end;    
end;

AccountDialog.dapuReSelect = function(self)
    self.super.dismiss(self);
    self:setVisible(false);
    self:resetDialog();
    if self.m_room then
        self.m_room:reSelect();
    end;        
end;

AccountDialog.share = function(self)
    self.m_logo_view:setVisible(true);
    self.m_button_view:setVisible(false);
    ToolKit.schedule_once(self,function() 
        if self.m_room then
            self.m_room:sharePicture();
        end;    
    end,100);
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

-- 分享棋局
AccountDialog.shareFuPan = function(self)
    if self.m_room then
        self.m_room:shareFuPan();
    end;
end;

AccountDialog.reSelect = function(self)
    if self.m_room.m_upUser then
        local ret = self:canContinue()
		if ret == 1 then
            self:stopTimer();
            self.super.dismiss(self);
            self:setVisible(false);
            self:resetDialog();  
            
            self.m_room:userLeave(self.m_room.m_upUser:getUid(),false);
            if self.m_room.mModule.matchRoom then
                self.m_room.mModule:matchRoom();
            end
        elseif ret == 0 then 
            self:stopTimer();
            self.super.dismiss(self);
            self:setVisible(false);
            self:resetDialog();  
        elseif ret == 2 then
            -- 推荐支付
        end;
    else
        local roomType = RoomProxy.getInstance():getCurRoomType();
        if roomType ~= RoomConfig.ROOM_TYPE_PRIVATE_ROOM and roomType ~= RoomConfig.ROOM_TYPE_FRIEND_ROOM then
            local ret = self:canContinue()
		    if ret == 1 then
                self:stopTimer();
                self.super.dismiss(self);
                self:setVisible(false);
                self:resetDialog();  
                
                if self.m_room.mModule.matchRoom then
                    self.m_room.mModule:matchRoom();
                end
            elseif ret == 0 then 
                self:stopTimer();
                self.super.dismiss(self);
                self:setVisible(false);
                self:resetDialog();  
            elseif ret == 2 then
                -- 推荐支付
            end;
        else
            self:stopTimer();
            self.super.dismiss(self);
            self:resetDialog();
            self:setVisible(false);
        end
    end
end;

AccountDialog.reStart = function(self)
	if RoomProxy.getInstance():getCurRoomType() ~= RoomConfig.ROOM_TYPE_CONSOLE_ROOM then  --单机
        local ret = self:canContinue()
		if ret == 1 then
            -- 私人房再来一局加好友判断
            local roomType = RoomProxy.getInstance():getCurRoomType()
            if roomType == RoomConfig.ROOM_TYPE_PRIVATE_ROOM and self.m_room and self.m_room.m_upUser then
                local uid = self.m_room.m_upUser:getUid()
                local preUid = AccountDialog.s_preUid
                if uid ~= preUid and FriendsData.getInstance():isYourFriend(uid) == -1 and 
                    FriendsData.getInstance():isYourFollow(uid) == -1 then
                    AccountDialog.s_preUid = uid
                    delete(self.mFollowDialog)
                    self.mFollowDialog = new(ChioceDialog)
                    local message = "您的对手还不是您的好友,互相关注成为好友，可以随时快速约战哦"
                    self.mFollowDialog:setMode(ChioceDialog.MODE_SURE,"关注","忽略");
                    self.mFollowDialog:setMessage(message)
                    self.mFollowDialog:setPositiveListener(self,function()
                        local info = {}
                        info.uid = UserInfo.getInstance():getUid();
                        info.target_uid = uid;
                        info.op = 1;
                        OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_ADD_FLLOW,info);
                    end);
                    self.mFollowDialog:show()
                else
                    self:stopTimer();
                    self.super.dismiss(self);
                    self:setVisible(false);
                    self:resetDialog();  

                    self.m_btn_txt2:setText("再来一局(*)");
                    self.m_room:sendReadyMsg();
                end
            else
                self:stopTimer();
                self.super.dismiss(self);
                self:setVisible(false);
                self:resetDialog();  

                self.m_btn_txt2:setText("再来一局(*)");
                self.m_room:sendReadyMsg();
            end
        elseif ret == 0 then 
            self:stopTimer();
            self.super.dismiss(self);
            self:setVisible(false);
            self:resetDialog();  
        elseif ret == 2 then
            -- 推荐支付
        end;
    else

        self:stopTimer();
        self.super.dismiss(self);
        self:setVisible(false);
        self:resetDialog();
	end 
end

AccountDialog.dismiss = function(self)
    local roomType = RoomProxy.getInstance():getCurRoomType();
    if roomType ~= RoomConfig.ROOM_TYPE_PRIVATE_ROOM and 
        roomType ~= RoomConfig.ROOM_TYPE_FRIEND_ROOM and 
        roomType ~= RoomConfig.ROOM_TYPE_WATCH_ROOM then
        if self.m_room.updateRestartView then
            self.m_room:updateRestartView(true)
        end
    end
    self:resetDialog();
    self:setVisible(false);
    self:stopTimer();
    self.super.dismiss(self,false);
end

AccountDialog.dismiss2 = function(self)
    self.super.dismiss(self);
    self:resetDialog();
    self:stopTimer();
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

AccountDialog.shareDialogHide = function(self)
    if self.m_logo_view then
        self.m_logo_view:setVisible(false);
    end;
    if self.m_button_view then
         self.m_button_view:setVisible(true);       
    end;
end

AccountDialog.onFollowUpUser = function(self)
    NoviceBootProxy.getInstance():releaseGuideTip(NoviceBootProxy.s_constant.ONLINE_ROOM_RESULT_FOLLOW)
    if self.m_room and self.m_room.m_upUser then
        self:toAddFriend(self.m_room.m_upUser:getUid());
    else
        ChessToastManager.getInstance():showSingle("玩家已离开")
    end
end;

AccountDialog.onFollowDownUser = function(self)
    if self.m_room and self.m_room.m_downUser then
        self:toAddFriend(self.m_room.m_downUser:getUid());
    else
        ChessToastManager.getInstance():showSingle("玩家已离开")
    end
end;

AccountDialog.showUpuserReadyTip = function(self)
    if self.m_room and self.m_room.m_upUser then
        self.m_up_user_ready_tip:setVisible(true);
    end
end;

AccountDialog.onEventResponse = function(self, cmd, status)
    --status = {ret=0 uid=10000144 target_uid=10000516 relation=2 }
    if cmd == kFriend_FollowCallBack then
        if status.ret and status.ret == 0 then
            local target_uid = status.target_uid;
            if UserInfo.getInstance():getUid() == target_uid then return end;
            -- 发起关注/取消关注，server返回会先更新FriendData的isYourFollow
            if FriendsData.getInstance():isYourFollow(target_uid) == -1 then
                if FriendsData.getInstance():isYourFriend(target_uid) == -1 then
                    if self.m_up_user_guanzhu_txt and self.m_down_user_guanzhu_txt then
                        if not self.m_room.m_upUser then return end;
                        if self.m_room.m_upUser:getUid() == target_uid then
                            self.m_up_user_guanzhu_txt:setText("+ 关注");
                        else
                            self.m_down_user_guanzhu_txt:setText("+ 关注");
                        end;
                    end;
                else
                    if self.m_up_user_guanzhu_txt and self.m_down_user_guanzhu_txt then
                        if not self.m_room.m_upUser then return end;
                        if self.m_room.m_upUser:getUid() == target_uid then
                            self.m_up_user_guanzhu_txt:setText("已关注");
                        else
                            self.m_down_user_guanzhu_txt:setText("已关注");
                        end;
                    end;                 
                end;
            else
                if self.m_up_user_guanzhu_txt and self.m_down_user_guanzhu_txt then
                    if not self.m_room.m_upUser then return end;
                    if self.m_room.m_upUser:getUid() == target_uid then
                        self.m_up_user_guanzhu_txt:setText("已关注");
                    else
                        self.m_down_user_guanzhu_txt:setText("已关注");
                    end;
                end;
            end;
        end
    end
end;

-- 是否关注
AccountDialog.isFollow = function(self,uid)
    if FriendsData.getInstance():isYourFollow(uid) == -1 then
        if FriendsData.getInstance():isYourFriend(uid) == -1 then
            return false;
        else
            return true;
        end;
    else
        return true;
    end
end;

AccountDialog.toAddFriend = function(self,uid)
    if FriendsData.getInstance():isYourFollow(uid) == -1 then
        if FriendsData.getInstance():isYourFriend(uid) == -1 then
            self:follow(uid);
        else
            self:unFollow(uid);
        end;
    else
        self:unFollow(uid);
    end
end;

-- 关注
AccountDialog.follow = function(self,gz_uid)
    local info = {};
    info.uid = UserInfo.getInstance():getUid();
    info.target_uid = gz_uid;
    info.op = 1;
    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_ADD_FLLOW,info);
end;


--取消关注
AccountDialog.unFollow = function(self,gz_uid)
    local info = {};
    info.uid = UserInfo.getInstance():getUid();
    info.target_uid = gz_uid;
    info.op = 0;
    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_ADD_FLLOW,info);
end