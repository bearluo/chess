require(MODEL_PATH.."room/roomScene");
require("config/anim_config");
require("dialog/console_win_dialog")
require("dialog/setting_dialog");
require("dialog/chioce_dialog");
require(DATA_PATH.."userSetInfo");
require("dialog/common_share_dialog");
ReplayRoomScene = class(RoomScene);

ReplayRoomScene.s_controls = 
{
    back_btn = 1;
    title = 2;
    step_info = 3;
    step_progress_holder = 4;
    time = 5;
    board = 6;
    left_user = 7;
    right_user = 8;
    share_btn = 9;
    comment_btn = 10;
    collection_btn = 11;
    pre_step = 12;
    next_step = 13;
    title_view = 14;
    novice_guide_view = 15;
    userinfo_view = 16;
    progress_view = 17;
}

ReplayRoomScene.s_cmds = 
{
    updataUserIcon = 1;
    save_mychess   = 2;
}

ReplayRoomScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = ReplayRoomScene.s_controls;
    self:initReplayRoom()
	self:start_action();
end 
ReplayRoomScene.resume = function(self)
    ChessScene.resume(self);
    self:startTimer();
end;


ReplayRoomScene.pause = function(self)
	ChessScene.pause(self);
    self:pauseTimer();
end 


ReplayRoomScene.dtor = function(self)
    ChatMessageAnim.deleteAll();
    delete(self.m_chioce_dialog);
    delete(self.m_novice_guide_anim);
    delete(self.m_anim_start);
    delete(self.m_anim_end);
end 

ReplayRoomScene.onBack = function(self)
    self:requestCtrlCmd(ReplayRoomController.s_cmds.onBack);
end

------------------------------------function----------------------------
ReplayRoomScene.setAnimItemEnVisible = function(self,ret)
end

ReplayRoomScene.resumeAnimStart = function(self,lastStateObj,timer)
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

ReplayRoomScene.pauseAnimStart = function(self,newStateObj,timer)
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

ReplayRoomScene.initReplayRoom = function(self)
	self.m_root_view = self.m_root;

    self.m_room_bg= self.m_root_view:getChildByName("bg");
    local bg = UserSetInfo.getInstance():getBgImgRes();
    self.m_room_bg:setFile(bg or "common/background/room_bg.png");

    self.m_data = UserInfo.getInstance():getDapuSelData();
    self.m_back_btn = self:findViewById(self.m_ctrls.back_btn);
    self.m_back_btn:setTransparency(0.6);
    -- title
    self.m_title_view = self.m_root_view:getChildByName("title_view");
        -- time
        self.m_time_bg = self.m_title_view:getChildByName("time_bg");
        self.m_time_text = self.m_time_bg:getChildByName("time");

        -- share_btn2
        self.m_share_btn2 = self.m_title_view:getChildByName("share_btn2");
        self.m_share_btn2:setVisible(false);
        self.m_share_btn2:setOnClick(self,self.onShareBtnClick);
        -- up_user
        self.m_up_user_view = self.m_title_view:getChildByName("up_user");
            -- up_user_name
            self.m_up_user_name = self.m_up_user_view:getChildByName("up_user_name");
            -- up_user_frame
            self.m_up_user_icon_frame = self.m_up_user_view:getChildByName("up_user_frame");
            -- up_user_level
            self.m_up_user_level = self.m_up_user_view:getChildByName("up_user_level");

            self.m_up_vip_frame = self.m_up_user_icon_frame:getChildByName("up_user_vip_frame");
            self.m_up_vip_frame:setLevel(1);
            self.m_up_vip_logo = self.m_up_user_view:getChildByName("up_user_vip_logo");
            
            self.m_up_vip_flag = self.m_up_user_view:getChildByName("up_user_flag");
            self.m_up_vip_flag:setVisible(false);
        --- down_user
        self.m_down_user_view = self.m_title_view:getChildByName("down_user");
            -- down_user_name
            self.m_down_user_name = self.m_down_user_view:getChildByName("down_user_name");
            -- down_user_frame
            self.m_down_user_icon_frame = self.m_down_user_view:getChildByName("down_user_frame");
            -- down_user_level
            self.m_down_user_level = self.m_down_user_view:getChildByName("down_user_level");
            
            self.m_down_vip_frame = self.m_down_user_icon_frame:getChildByName("down_user_vip_frame");
            self.m_down_vip_frame:setLevel(1);
            self.m_down_vip_logo = self.m_down_user_view:getChildByName("down_user_vip_logo");

            self.m_down_vip_flag = self.m_down_user_view:getChildByName("down_user_flag");
            self.m_down_vip_flag:setVisible(false);
    -- content_view
    self.m_content_view = self.m_root_view:getChildByName("content_view");
        
        -- chess_board
        self.m_board_view = self.m_content_view:getChildByName("board_view");
            -- step 
            self.m_chess_step_text = self.m_board_view:getChildByName("multiple_bg"):getChildByName("step");
            -- board_bg
            self.m_board_bg = self.m_board_view:getChildByName("board_bg");
--            self.m_board_bg:setEventTouch(self, self.onBoardBgTouch);
    -- bottom_view
    self.m_bottom_view = self.m_root_view:getChildByName("bottom_view");
        -- share_btn
        self.m_share_btn = self.m_bottom_view:getChildByName("share_btn");

        -- comment_btn
        self.m_comment_btn = self.m_bottom_view:getChildByName("comment_btn");
        -- collection_btn
        self.m_collection_btn = self.m_bottom_view:getChildByName("collection_btn");
        -- pre_btn
        self.m_pre_btn = self.m_bottom_view:getChildByName("pre_step");
        -- next_btn
        self.m_next_btn = self.m_bottom_view:getChildByName("next_step");

        -- chess_type=1,最近对战;chess_type=2,我的收藏;chess_type=3,棋友推荐;
        if self.m_data.chess_type == 1 then
            self.m_share_btn:setVisible(false);
            self.m_comment_btn:setVisible(false);
            self.m_collection_btn:setVisible(true); 
            self.m_share_btn2:setVisible(false);
        elseif self.m_data.chess_type == 2 then
            self.m_share_btn:setVisible(true);
            self.m_comment_btn:setVisible(true);
            self.m_comment_btn:setPos(184);
            self.m_collection_btn:setVisible(false); 
            self.m_share_btn2:setVisible(false);
	        if kPlatform == kPlatformIOS then
                -- AppStore审核开关，关闭分享和评论
                if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then 
                    self.m_share_btn:setVisible(true);
                    self.m_comment_btn:setVisible(true);
                else
                    self.m_share_btn:setVisible(false);
                    self.m_comment_btn:setVisible(false);
                end;
	        else
                self.m_share_btn:setVisible(true);
                self.m_comment_btn:setVisible(true);                
            end;
        elseif self.m_data.chess_type == 3 then
            self.m_comment_btn:setVisible(true);
            self.m_comment_btn:setPos(8);
            self.m_collection_btn:setVisible(true);  
            self.m_share_btn:setVisible(false);
	        if kPlatform == kPlatformIOS then
                -- AppStore审核开关，关闭分享和评论
                if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then 
                    self.m_comment_btn:setVisible(true);
                    self.m_share_btn2:setVisible(true);
                else
                    self.m_comment_btn:setVisible(false);
                    self.m_share_btn2:setVisible(false);
                end;
	        else
                self.m_comment_btn:setVisible(true);
                self.m_share_btn2:setVisible(true);
            end;
        end;
        --设置棋盘图片
    self.m_board_bg:setFile(UserSetInfo.getInstance():getBoardRes());
--    if UserInfo.getInstance():getIsVip() == 1 then
--        self.m_board_bg:setFile("vip/vip_chess_board.png");
--    end
    ------------view end ------------
    
    -- init_users
    self:initUsersInfo(self.m_data);


    -- 棋盘适配
    local w,h = self.m_board_view:getSize();
    --确定底边
    self.m_progress_view = self:findViewById(self.m_ctrls.progress_view);
    local bx,by = self.m_progress_view:getUnalignPos();
    local x,y = self.m_content_view:getUnalignPos();
    local pw = self.m_root_view:getSize();
    local ph = by - y;
    if pw > w then
        local diffh = ph - h; -- 增加的高
        local diffw = pw - w; -- 增加的高
        local add = math.min(diffw,diffh);
        local scale = (w+add)/w;
	    self.m_content_view:setSize(w*scale,h*scale);
        local w,h = self.m_board_view:getSize();
	    self.m_board_view:setSize(w*scale,h*scale);
        local w,h = self.m_board_bg:getSize();
	    self.m_board_bg:setSize(w*scale,h*scale);
    end
    -- 棋盘适配 end

    -- init_chessboard
	local w,h = self.m_board_view:getSize();
	self.m_board = new(Board,w,h,self,true);
	self.m_board_view:addChild(self.m_board);

    -- progress_bar
    self.m_progress_view = self:findViewById(self.m_ctrls.progress_view);
    self.m_hide_progress = true;
    self.m_step_progress_holder = self:findViewById(self.m_ctrls.step_progress_holder);
    local w,h = self.m_step_progress_holder:getSize();
    self.m_step_progress = new(Slider,w - 100,h,"common/replay_progress_bg.png","common/replay_progress_fg.png","common/decoration/choice_icon.png");
    self.m_step_progress:setAlign(kAlignCenter);
    self.m_step_progress_holder:addChild(self.m_step_progress);

	self.mvList = lua_string_split(self.m_data.move_list,GameCacheData.chess_data_key_split);
	self.mvNum = 1;
	self:setChessStep(self.mvNum-1,#self.mvList);
	self.m_chioce_dialog = new(ChioceDialog);

    self.m_step_progress_index = 0;
    self:updateStepProgress();
    self.m_step_progress:setOnChange(self,self.stepProgressChangeClick)

end;



ReplayRoomScene.initUsersInfo = function(self, data)
    if not data then return end;
    -- up_user
    if not self.m_up_user_icon then
        self.m_up_user_icon = new(Mask,"drawable/blank.png" ,"userinfo/icon_6464_mask.png");
        self.m_up_user_icon:setSize(68,68);
        self.m_up_user_icon:setAlign(kAlignCenter);
        self.m_up_user_icon_frame:addChild(self.m_up_user_icon)
    end;
    -- 确定红黑方币标志
    if tonumber(self.m_data.down_user) == tonumber(self.m_data.red_mid) then
        self.m_up_vip_flag:setFile("common/icon/black_king.png");
        self.m_up_vip_flag:setVisible(true);

        self.m_down_vip_flag:setFile("common/icon/red_king.png");
        self.m_down_vip_flag:setVisible(true);
    else
        self.m_up_vip_flag:setFile("common/icon/red_king.png");
        self.m_up_vip_flag:setVisible(true);
        
        self.m_down_vip_flag:setFile("common/icon/black_king.png");
        self.m_down_vip_flag:setVisible(true);
    end

    local up_icon = nil;
    if (tonumber(self.m_data.down_user) == tonumber(self.m_data.red_mid)) then
        up_icon = self.m_data.black_icon_url;
    else
        up_icon = self.m_data.red_icon_url;
    end;
    if up_icon == "" or not up_icon then 
        local up_icon_type = -1;
        if (tonumber(self.m_data.down_user) == tonumber(self.m_data.red_mid)) then
            up_icon_type = self.m_data.black_icon_type;
        else
            up_icon_type = self.m_data.red_icon_type;
        end;     
        if not up_icon_type then
            up_icon = UserInfo.DEFAULT_ICON[1];
        else
            if up_icon_type > 0 then
                up_icon = UserInfo.DEFAULT_ICON[up_icon_type] or UserInfo.DEFAULT_ICON[1];
            else
                up_icon = UserInfo.DEFAULT_ICON[1];
            end;
        end;
        self.m_up_user_icon:setFile(up_icon);
    else
        self.m_up_user_icon:setUrlImage(up_icon,UserInfo.DEFAULT_ICON[1]); 
    end;
    self.m_up_user_name:setText((((tonumber(self.m_data.down_user) == tonumber(self.m_data.red_mid)) and (self.m_data.black_mnick or "博雅象棋")) or (self.m_data.red_mnick or "博雅象棋")));
    local up_level = 10 - (((tonumber(self.m_data.down_user) == tonumber(self.m_data.red_mid)) and UserInfo.getInstance():getDanGradingLevelByScore(self.m_data.black_score)) 
        or UserInfo.getInstance():getDanGradingLevelByScore(self.m_data.red_score))
    self.m_up_user_level:setFile("common/icon/level_"..up_level ..".png");
    
--    local text = new(Text,self.m_up_user_name:getText(),nil,nil,nil,nil,32);
--    local tw,th = text:getSize();
--    local up_data = (tonumber(self.m_data.down_user) == tonumber(self.m_data.red_mid)) and (self.m_data.black_is_vip) or (self.m_data.red_is_vip);
--    if up_data and up_data == 0 then
--        self.m_up_vip_logo:setPos(tw/2,nil);
--        self.m_up_vip_frame:setVisible(true);
--        self.m_up_vip_logo:setVisible(true);
--    else
--        self.m_up_vip_logo:setPos(0,nil);
--        self.m_up_vip_frame:setVisible(false);
--        self.m_up_vip_logo:setVisible(false);
--    end
    
    -- down_user
    if not self.m_down_user_icon then
        self.m_down_user_icon = new(Mask, "drawable/blank.png" ,"userinfo/icon_6464_mask.png");
        self.m_down_user_icon:setSize(68,68);
        self.m_down_user_icon:setAlign(kAlignCenter);
        self.m_down_user_icon_frame:addChild(self.m_down_user_icon);
    end  

    local down_icon = nil;
    if (tonumber(self.m_data.down_user) == tonumber(self.m_data.red_mid)) then
        down_icon = self.m_data.red_icon_url;
    else
        down_icon = self.m_data.black_icon_url;
    end;    
    if down_icon == "" or not down_icon then 
        local down_icon_type = -1;
        if (tonumber(self.m_data.down_user) == tonumber(self.m_data.red_mid)) then
            down_icon_type = self.m_data.red_icon_type;
        else
            down_icon_type = self.m_data.black_icon_type;
        end;         
        if not down_icon_type then
            down_icon = UserInfo.DEFAULT_ICON[1];
        else
            if down_icon_type > 0 then
                down_icon = UserInfo.DEFAULT_ICON[down_icon_type] or UserInfo.DEFAULT_ICON[1];
            else
                down_icon = UserInfo.DEFAULT_ICON[1];
            end;
        end;
        self.m_down_user_icon:setFile(down_icon);
    else
        self.m_down_user_icon:setUrlImage(down_icon,UserInfo.DEFAULT_ICON[1]); 
    end;

    self.m_down_user_name:setText((((tonumber(self.m_data.down_user) == tonumber(self.m_data.red_mid)) and (self.m_data.red_mnick or "博雅象棋")) or (self.m_data.black_mnick or "博雅象棋")));
    local down_level = 10 - (((tonumber(self.m_data.down_user) == tonumber(self.m_data.red_mid)) and UserInfo.getInstance():getDanGradingLevelByScore(self.m_data.red_score)) 
        or UserInfo.getInstance():getDanGradingLevelByScore(self.m_data.black_score))
    self.m_down_user_level:setFile("common/icon/level_"..down_level ..".png");

--    local text = new(Text,self.m_down_user_name:getText(),nil,nil,nil,nil,32);
--    local tw,th = text:getSize();
--    local down_data = (tonumber(self.m_data.down_user) == tonumber(self.m_data.red_mid)) and (self.m_data.red_is_vip) or (self.m_data.black_is_vip);
--    if down_data and down_data == 0 then
--        self.m_down_vip_logo:setPos(tw/2,nil);
----        self.m_down_vip_frame:setVisible(true);
--        self.m_down_vip_logo:setVisible(true);
--    else
--        self.m_down_vip_logo:setPos(0,nil);
----        self.m_down_vip_frame:setVisible(false);
--        self.m_down_vip_logo:setVisible(false);
--    end

    self:setVip();

end;

ReplayRoomScene.setVip = function(self)
    -- vip
    if (tonumber(self.m_data.down_user) == tonumber(self.m_data.red_mid)) then
        local upframeRes;
        local downframeRes;
        if (tonumber(self.m_data.red_mid) == UserInfo.getInstance():getUid()) then
            downframeRes = UserSetInfo.getInstance():getFrameRes();
            if tonumber(self.m_data.black_mid) ~= 0 then
                local data = FriendsData.getInstance():getUserData(self.m_data.black_mid);
                if data and data.my_set then
                    upframeRes = UserSetInfo.getInstance():getFrameRes(data.my_set.picture_frame);
                end;
            end;
        else    
            if tonumber(self.m_data.red_mid) ~= 0 then 
                local data = FriendsData.getInstance():getUserData(self.m_data.red_mid);
                if data and data.my_set then
                    downframeRes = UserSetInfo.getInstance():getFrameRes(data.my_set.picture_frame);
                end;
            end;
            if tonumber(self.m_data.black_mid) ~= 0 then 
                if (tonumber(self.m_data.black_mid) == UserInfo.getInstance():getUid()) then
                     upframeRes = UserSetInfo.getInstance():getFrameRes();
                else
                    local data = FriendsData.getInstance():getUserData(self.m_data.black_mid);
                    if data and data.my_set then
                        upframeRes = UserSetInfo.getInstance():getFrameRes(data.my_set.picture_frame);
                    end;
                end;
            end;
        end;
        if upframeRes then 
            self.m_up_vip_frame:setVisible(upframeRes.visible);
            local fw,fh = self.m_up_vip_frame:getSize();
            if upframeRes.frame_res then
                self.m_up_vip_frame:setFile(string.format(upframeRes.frame_res,fw));
            end
            self.m_up_vip_logo:setVisible(self.m_up_vip_frame:getVisible());
        end;

        if downframeRes then 
            self.m_down_vip_frame:setVisible(downframeRes.visible);
            local fw,fh = self.m_down_vip_frame:getSize();
            if downframeRes.frame_res then
                self.m_down_vip_frame:setFile(string.format(downframeRes.frame_res,fw));
            end
            self.m_down_vip_logo:setVisible(self.m_down_vip_frame:getVisible());
        end;
    elseif (tonumber(self.m_data.down_user) == tonumber(self.m_data.black_mid)) then
        local upframeRes;
        local downframeRes;
        if (tonumber(self.m_data.black_mid) == UserInfo.getInstance():getUid()) then
            downframeRes = UserSetInfo.getInstance():getFrameRes();
            if tonumber(self.m_data.black_mid) ~= 0 then 
                local data = FriendsData.getInstance():getUserData(self.m_data.red_mid);
                if data and data.my_set then
                    upframeRes = UserSetInfo.getInstance():getFrameRes(data.my_set.picture_frame);
                end;
            end;
        else    
            if tonumber(self.m_data.black_mid) ~= 0 then 
                local data = FriendsData.getInstance():getUserData(self.m_data.black_mid);
                if data and data.my_set then
                    downframeRes = UserSetInfo.getInstance():getFrameRes(data.my_set.picture_frame);
                end;
            end;
            if tonumber(self.m_data.red_mid) ~= 0 then 
                if (tonumber(self.m_data.red_mid) == UserInfo.getInstance():getUid()) then
                     upframeRes = UserSetInfo.getInstance():getFrameRes();
                else
                    local data = FriendsData.getInstance():getUserData(self.m_data.red_mid);
                    if data and data.my_set then
                        upframeRes = UserSetInfo.getInstance():getFrameRes(data.my_set.picture_frame);
                    end;
                end;
            end;
        end;
        if upframeRes then 
            self.m_up_vip_frame:setVisible(upframeRes.visible);
            local fw,fh = self.m_up_vip_frame:getSize();
            if upframeRes.frame_res then
                self.m_up_vip_frame:setFile(string.format(upframeRes.frame_res,fw));
            end
            self.m_up_vip_logo:setVisible(self.m_up_vip_frame:getVisible());
        end;

        if downframeRes then 
            self.m_down_vip_frame:setVisible(downframeRes.visible);
            local fw,fh = self.m_down_vip_frame:getSize();
            if downframeRes.frame_res then
                self.m_down_vip_frame:setFile(string.format(downframeRes.frame_res,fw));
            end
            self.m_down_vip_logo:setVisible(self.m_down_vip_frame:getVisible());
        end;        
    else
        
    end;
end;

ReplayRoomScene.onBoardBgTouch = function(self)
    if self.m_hide_progress then
        local upAnim = self.m_progress_view:addPropTranslate(0,kAnimNormal,300,0,0,0,0,-100);
        if not upAnim then return end;
        upAnim:setEvent(self,function() 
            self.m_progress_view:setPos(nil, 0);
            self.m_progress_view:removeProp(0);
            self.m_bottom_view:setVisible(false);
            self.m_hide_progress = false;
        end)
    else
        self.m_bottom_view:setVisible(true);
        local downAnim = self.m_progress_view:addPropTranslate(1,kAnimNormal,300,0,0,0,0,100);
        if not downAnim then return end;
        downAnim:setEvent(self,function() 
            self.m_progress_view:setPos(nil, -100);
            self.m_progress_view:removeProp(1);
            self.m_hide_progress = true;
        end)        
    end;
end;





ReplayRoomScene.setFuPan = function(self,data)
--    self:findViewById(self.m_ctrls.userinfo_view):setVisible(true);

--    if data.red_mid and data.red_mid ~= 0 then 
--        local red_data = FriendsData.getInstance():getUserData(data.red_mid);
--        if red_data then
--            self:findViewById(self.m_ctrls.left_user):getChildByName("user_name"):setText(red_data.mnick or "博雅象棋");
--            self:findViewById(self.m_ctrls.left_user):getChildByName("level_icon"):setFile("userinfo/"..UserInfo.getInstance():getDanGradingLevelByScore(red_data.score)..".png");            
--            self:findViewById(self.m_ctrls.left_user):getChildByName("level_icon"):setVisible(true);
--            local iconType = red_data.iconType or 0;
--            if iconType == -1 then -- server 传的数据不会出现 用户头像 iconType 为 -1的情况 只可能是自己的头像
--                local imageName = UserInfo.getInstance():loadIcon1(red_data.mid,red_data.icon_url);
--                if imageName then
--                    self:findViewById(self.m_ctrls.left_user):getChildByName("user_icon"):setFile(imageName);
--                end
--            elseif iconType > 0 then
--                self:findViewById(self.m_ctrls.left_user):getChildByName("user_icon"):setFile(UserInfo.DEFAULT_ICON[iconType]);
--            end
--        end
--    elseif data.red_mid == 0 then
--        self:findViewById(self.m_ctrls.left_user):getChildByName("user_name"):setText( data.red_name or "博雅象棋");
--        self:findViewById(self.m_ctrls.left_user):getChildByName("level_icon"):setVisible(false);
--    end

--    if data.black_mid and data.black_mid ~= 0 then 
--        local black_data = FriendsData.getInstance():getUserData(data.black_mid);
--        if black_data then
--            self:findViewById(self.m_ctrls.right_user):getChildByName("user_name"):setText(black_data.mnick or "博雅象棋");
--            self:findViewById(self.m_ctrls.right_user):getChildByName("level_icon"):setFile("userinfo/"..UserInfo.getInstance():getDanGradingLevelByScore(black_data.score)..".png");
--            self:findViewById(self.m_ctrls.right_user):getChildByName("level_icon"):setVisible(false);
--            local iconType = black_data.iconType or 0;
--            if iconType == -1 then -- server 传的数据不会出现 用户头像 iconType 为 -1的情况 只可能是自己的头像
--                local imageName = UserInfo.getInstance():loadIcon1(black_data.mid,black_data.icon_url);
--                if imageName then
--                    self:findViewById(self.m_ctrls.right_user):getChildByName("user_icon"):setFile(imageName);
--                end
--            elseif iconType > 0 then
--                self:findViewById(self.m_ctrls.right_user):getChildByName("user_icon"):setFile(UserInfo.DEFAULT_ICON[iconType]);
--            end
--        end
--    elseif data.black_mid == 0 then
--        self:findViewById(self.m_ctrls.right_user):getChildByName("user_name"):setText( data.black_name or "博雅象棋");
--        self:findViewById(self.m_ctrls.right_user):getChildByName("level_icon"):setVisible(false);
--    end
end

ReplayRoomScene.onUpdataUserIcon = function(self,imageName,uid)
    if not imageName or not uid then return end;
    if self.m_data and self.m_data.red_mid == uid then
        self:findViewById(self.m_ctrls.left_user):getChildByName("user_icon"):setFile(imageName);
    end
    
    if self.m_data and self.m_data.black_icon == uid then
        self:findViewById(self.m_ctrls.right_user):getChildByName("user_icon"):setFile(imageName);
    end
end

ReplayRoomScene.onSaveMychessCallBack = function(self,data)
    if not data then return end;
    if data.cost then
        if data.cost >= 0 then 
            ChessToastManager.getInstance():showSingle("收藏成功！",2000);
        elseif data.cost == -1 then
            -- -1是老版本本地棋谱上传成功
        end;
    end;
end;

ReplayRoomScene.StartNoviceGuide = function(self)
    self.m_novice_guide_view = self:findViewById(self.m_ctrls.novice_guide_view);
    self.m_novice_guide_view:setVisible(true);
    self.m_novice_guide_view:setEventDrag(self,function()end);
    self.m_novice_guide_view:setEventTouch(self,function()end);
    self.m_novice_guide_play_view = self.m_novice_guide_view:getChildByName("novice_guide_pre_step");
    self.m_novice_guide_play_btn = self.m_novice_guide_view:getChildByName("novice_guide_bg"):getChildByName("novice_guide_next_btn");
    self.m_novice_guide_play_btn:setVisible(false);
    self:resetNoviceGuideNotice();
    self.m_novice_guide_view:getChildByName("novice_guide_bg"):getChildByName("novice_guide_notice1"):setVisible(true);
    self:noviceGuidePlayNext(ReplayRoomScene.noviceGuideStep1);
end

ReplayRoomScene.resetNoviceGuideNotice = function(self)
    self.m_novice_guide_view:getChildByName("novice_guide_bg"):getChildByName("novice_guide_notice1"):setVisible(false);
    self.m_novice_guide_view:getChildByName("novice_guide_bg"):getChildByName("novice_guide_notice2"):setVisible(false);
    self.m_novice_guide_view:getChildByName("novice_guide_bg"):getChildByName("novice_guide_notice3"):setVisible(false);
end

ReplayRoomScene.noviceGuidePlayNext = function(self,fun)
    self.m_novice_guide_play_index = 0;
    self.m_novice_guide_anim = AnimFactory.createAnimInt(kAnimLoop,0,1,500,500);
    self.m_novice_guide_anim:setDebugName("ReplayRoomScene.noviceGuideStep1");
    self.m_novice_guide_anim:setEvent(self,fun)
end

ReplayRoomScene.noviceGuideStep1 = function(self)
    self.m_novice_guide_play_index = self.m_novice_guide_play_index + 1;
    self.m_novice_guide_play_view:setVisible(not self.m_novice_guide_play_view:getVisible());
    if self.m_novice_guide_play_index > 5 then
        delete(self.m_novice_guide_anim);
        self.m_novice_guide_play_view = self.m_novice_guide_view:getChildByName("novice_guide_next_step");
        self.m_novice_guide_play_btn:setVisible(true);
        self.m_novice_guide_play_btn:setOnClick(self,
        function(self)
            self.m_novice_guide_play_btn:setVisible(false);
            self:noviceGuidePlayNext(ReplayRoomScene.noviceGuideStep2);
            self:resetNoviceGuideNotice();
            self.m_novice_guide_view:getChildByName("novice_guide_bg"):getChildByName("novice_guide_notice2"):setVisible(true);
        end);
    end
end

ReplayRoomScene.noviceGuideStep2 = function(self)
    self.m_novice_guide_play_index = self.m_novice_guide_play_index + 1;
    self.m_novice_guide_play_view:setVisible(not self.m_novice_guide_play_view:getVisible());
    if self.m_novice_guide_play_index > 5 then
        delete(self.m_novice_guide_anim);
        self.m_novice_guide_play_view = self.m_novice_guide_view:getChildByName("novice_guide_progress");
        self.m_novice_guide_play_btn:setVisible(true);
        self.m_novice_guide_play_btn:setOnClick(self,
        function(self)
            self.m_novice_guide_play_btn:setVisible(false);
            self:noviceGuidePlayNext(ReplayRoomScene.noviceGuideStep3);
            self:resetNoviceGuideNotice();
            self.m_novice_guide_view:getChildByName("novice_guide_bg"):getChildByName("novice_guide_notice3"):setVisible(true);
        end);
    end
end

ReplayRoomScene.noviceGuideStep3 = function(self)
    self.m_novice_guide_play_index = self.m_novice_guide_play_index + 1;
    self.m_novice_guide_play_view:setVisible(not self.m_novice_guide_play_view:getVisible());
    if self.m_novice_guide_play_index > 5 then
        delete(self.m_novice_guide_anim);
        self.m_novice_guide_play_view = self.m_novice_guide_view:getChildByName("novice_guide_progress");
        self.m_novice_guide_play_btn:setVisible(true);
        self.m_novice_guide_play_btn:setOnClick(self,self.noviceGuideEnd);
    end
end

ReplayRoomScene.noviceGuideEnd = function(self)
    delete(self.m_novice_guide_anim);
    self:resetNoviceGuideNotice();
    self.m_novice_guide_view:setVisible(false);
    self.m_novice_guide_play_btn:setVisible(false);
    GameCacheData.getInstance():saveBoolean(GameCacheData.REPLAY_NOVICE_GUIDE..UserInfo.getInstance():getUid(),true);
end

ReplayRoomScene.updateStepProgress = function(self)
    local progress = self.m_step_progress_index / #self.mvList;
    self.m_step_progress:setProgress(progress);
end

ReplayRoomScene.stepProgressChangeClick = function(self,progress)
    self.m_step_progress_index = math.floor(progress*(#self.mvList) + 0.5);
    Log.i("ReplayRoomScene.stepProgressChangeClick2.."..self.m_step_progress_index);
    while(self.m_step_progress_index ~= self.mvNum-1) do
        Log.i(self.mvNum-1);
--        if self.m_step_progress_index == 0 then return end;
        if (self.m_step_progress_index > self.mvNum-1) then
            self:nextStep(-1);
        elseif (self.m_step_progress_index < self.mvNum-1) then
            self:preStep(-1)
        end
    end
end

ReplayRoomScene.updateProgerssTimerClick = function(self)
    if self.m_tesss then
        Log.i("self.m_tesss:"..os.clock()-self.m_tesss);
    end
    self.m_tesss = os.clock();
    
    delete(self.m_updateProgerssTimer);
    self.m_updateProgerssTimer = nil;
end

ReplayRoomScene.start_action = function(self)
--add_time: "1450151280"
--black_icon_type: -1
--black_icon_url: "http://chesscnmobile.17c.cn/chess_android/userIcon/icon/7666/8047666_icon.jpg?v=1442385686"
--black_level: 3
--black_mid: "8047666"
--black_mnick: "xxxx"
--black_score: "1746"
--collect_num: "0"
--comment_num: 0
--down_user: "8047666"
--end_fen: "5a3/5kn1R/9/4R4/2pr5/4c4/2P6/4B4/4A4/2B1Kr3/ w"
--end_type: "1"
--icon_type: -1
--icon_url: "http://chesscnmobile.17c.cn/chess_android/userIcon/icon/7666/8047666_icon.jpg?v=1442385686"
--is_collect: 0
--level: 3
--manual_id: "14299"
--manual_type: "1"
--mid: "8047666"
--mnick: "xxxx"
--move_list: "33956,22356,42436,30053,42953,23354,47048,19259,43178,18507,43466,31322,35204,31098,51915,38984,23242,39320,27017,43385,27241,21812,50371,30293,33988,17203,34436,31129,22696,18499,23384,23353,23386,19016,25450,42409,27483,51786,51383,38743,47046,18232,26475,37783,41925,39827,27495,52123,26467,14407,34663,26742,50887,35530,52075,34698,13958,18231,19403,18792,50595,18503,13622,34439,51142,42149,13365,33956,25652,34950,26468,34692,50887,30329,51142,51336"
--red_icon_type: -1
--red_icon_url: "http://chesscnmobile.17c.cn/chess_android/userIcon/icon/4357/5814357_icon.jpg?v=1444355873"
--red_level: 3
--red_mid: "5814357"
--red_mnick: "159****7560"
--red_score: "1882"
--score: "1746"
--share_num: "0"
--start_fen: "rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR/ w"
--test_md5: "71ad16d957cf65b02a8c8feb0043b24f"
--visit_num: "0"
--win_flag: "2"
	local chess_map = nil;
    Board.resetFenPiece();
	if self.m_data.start_fen and self.m_data.start_fen ~= "null" then
        chess_map = self.m_board:fen2chessMap(self.m_data.start_fen);
	end

    self.m_data.flag = self.m_data.flag or FLAG_RED;
    if tonumber(self.m_data.black_mid) and tonumber(self.m_data.black_mid) == tonumber(self.m_data.down_user) then
        if tonumber(self.m_data.red_mid) and tonumber(self.m_data.red_mid) == tonumber(self.m_data.down_user) then
            self.m_data.flag = FLAG_RED;
        else
            self.m_data.flag = FLAG_BLACK;
        end;
    end

	if(self.m_data.flag == FLAG_RED) then
		self.m_board:newgame(Board.MODE_RED,self.m_data.start_fen,chess_map);
	else
		self.m_board:newgame(Board.MODE_BLACK,self.m_data.start_fen,chess_map);
	end

end

ReplayRoomScene.startTimer = function(self)
    self:setTimer();
    delete(self.m_anim_timer);
    self.m_anim_timer = AnimFactory.createAnimInt(kAnimLoop, 0, 1, 1000*60, -1);
    self.m_anim_timer:setDebugName("ReplayRoomScene.startTimer");
    self.m_anim_timer:setEvent(self,self.setTimer);
end

ReplayRoomScene.pauseTimer = function(self)
    delete(self.m_anim_timer);
end

ReplayRoomScene.setTimer = function(self)
    self.m_time_text:setText(os.date("%H:%M"));
end


--上一步
ReplayRoomScene.preStep = function(self,finger_action)
--	if self.mvNum > 1 then
--        self:removeAnim();
--        if (self.m_step_progress_index == self.mvNum-1) then
--            self.m_step_progress_index = self.m_step_progress_index - 1;
--            self:updateStepProgress();
--        end 
--		self.mvNum = self.mvNum - 1;
--		self.m_board:undoMove();
--		self:setChessStep(self.mvNum-1,#self.mvList);
--	end
	if self.mvNum > 1 then
        self.m_board:undoMove();
        self.mvNum = self.m_board.pos.moveNum;
        self.m_board:hiddenMovePath();
        -- 重置移动轨迹
        if self.mvList[self.mvNum] then
            local mv = tonumber(self.mvList[self.mvNum]);
            if mv then
                local sqSrc = Postion.SRC(mv);
                local sqDst = Postion.DST(mv);
                local sqSrc90 = Board.To90(sqSrc);
                local sqDst90 = Board.To90(sqDst);
                self.m_board:setMovePath(sqSrc90,sqDst90);
            end;
        end;
		self:setChessStep(self.mvNum - 1,#self.mvList);
        if finger_action ~= -1 then
            local pp = (self.mvNum - 1)/(#self.mvList);
            self.m_step_progress:setProgress(pp);
        end;
    end;
end

--下一步 
ReplayRoomScene.nextStep = function(self,finger_action)

	if self.mvNum > #self.mvList then--结束判断
        self:showResultDialog();
	else
		local mv = tonumber(self.mvList[self.mvNum]);
		if mv then
	        if self.m_board.pos:makeMove(mv) then
                self.m_board:chessMove(mv,false)
                self.mvNum = self.m_board.pos.moveNum;
                self:setChessStep(self.mvNum-1,#self.mvList);
	        end
            -- finger_action ~= -1说明来自点击下一步按钮,更新Slider
            -- 为了防止点击Slider，progressBtn自动滑动
            if finger_action ~= -1 then
                local pp = (self.mvNum - 1)/(#self.mvList);
                self.m_step_progress:setProgress(pp);
            end
		else
            self.mvNum = self.m_step_progress_index + 1;
			self:showResultDialog();
		end
	end
end


ReplayRoomScene.console_gameover = function(self,flag,endType)
	self:gameClose(flag,endType);
end

ReplayRoomScene.gameClose = function(self,flag,endType)
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

ReplayRoomScene.setChessStep = function(self,curNum,maxNum)
	self.m_chess_step_text:setText("(步数："..curNum.."/"..maxNum..")");
end


ReplayRoomScene.setBoradCode = function(self,dieChess)
end
ReplayRoomScene.setDieChess = function(self,dieChess)
end

ReplayRoomScene.chessMove = function(self,data)
end

ReplayRoomScene.onTouchUp = function(self)
	return false;
end

ReplayRoomScene.getGameType = function(self)
	return ERROR_NUMBER;
end


ReplayRoomScene.showResultDialog = function(self)
	if self.m_chioce_dialog:isShowing() then
		return;
	end

	local message = "已经演示完毕！";
	self.m_chioce_dialog:setMode(ChioceDialog.MODE_OK,"知道了");
	self.m_chioce_dialog:setMessage(message);
	self.m_chioce_dialog:setPositiveListener();
	self.m_chioce_dialog:show();
end


ReplayRoomScene.removeAnim = function(self)
    AnimCheck.deleteAll();
	AnimKill.deleteAll();
	AnimJam.deleteAll();
	AnimCapture.deleteAll();
	ShockAnim.deleteAll();
end

ReplayRoomScene.onShareBtnClick = function(self)
--    require(BASE_PATH.."chessShareManager");
    local manualData = {};
    manualData.red_mid = self.m_data.red_mid or "0";       --红方uid
    manualData.black_mid = self.m_data.black_mid or "0";    --黑方uid
    manualData.win_flag = self.m_data.win_flag or "1";        --胜利方（1红胜，2黑胜，3平局）
    manualData.manual_type = self.m_data.manual_type or "1";     --棋谱类型，1联网游戏，2残局，3单机游戏，4用户打谱
    manualData.end_type = self.m_data.m_game_end_type or self.m_data.end_type or "1";    --棋盘开局
    manualData.start_fen = self.m_data.fenStr or self.m_data.start_fen;    -- 棋盘开局
    manualData.move_list = self.m_data.mvStr or self.m_data.move_list;     -- 走法，json字符串
    manualData.manual_id = self.m_data.manual_id;       -- 保存的棋谱id
    manualData.mid = self.m_data.mid;                   -- mid     
    manualData.h5_developUrl = PhpConfig.h5_developUrl;       
    manualData.title = self:getShareTitle() or "复盘演练（博雅中国象棋）";
    manualData.description = self:getShareTime() or "复盘让您回顾精彩对局"; 
    local url = require("libs/url");
    local u = url.parse(manualData.h5_developUrl);
    local params = {}
    params.manual_id = manualData.manual_id
    u:addQuery(params);
    manualData.url =  u:build()
    if not self.commonShareDialog then
        self.commonShareDialog = new(CommonShareDialog);
    end
    self.commonShareDialog:setShareDate(manualData,"manual_share");
    self.commonShareDialog:show();

end

ReplayRoomScene.getShareTitle = function(self)
    local title = nil;
    if self.m_data then
        if self.m_data.win_flag then
            local redName = nil;
            local blackName = nil;
            local redId = self.m_data.red_mid or "博雅象棋";
            local idLen = string.lenutf8(GameString.convert2UTF8(redId) or "");
            if idLen > 4 then
                redId = string.subutf8(redId,1,4).."...";
            end;
            local blackId = self.m_data.black_mid or "博雅象棋"
            idLen = string.lenutf8(GameString.convert2UTF8(blackId) or "");
            if idLen > 4 then
                blackId = string.subutf8(blackId,1,4).."...";
            end;
            if self.m_data.red_mnick then
                redName = self.m_data.red_mnick;
                local len = string.lenutf8(GameString.convert2UTF8(redName) or "");
                if len > 4 then
                    redName = string.subutf8(redName,1,4).."...";
                end;
            end;
            if self.m_data.black_mnick then
                blackName = self.m_data.black_mnick;
                local len = string.lenutf8(GameString.convert2UTF8(blackName) or "");
                if len > 4 then
                    blackName = string.subutf8(blackName,1,4).."...";
                end;
            end;
            if tonumber(self.m_data.win_flag) == 1 then
                title = "【"..(User.QILI_LEVEL[self.m_data.red_level] or "九级").."】"..(redName or redId).." 胜 "
                        .."【"..(User.QILI_LEVEL[self.m_data.black_level] or "九级").."】"..(blackName or blackId);
            elseif tonumber(self.m_data.win_flag) == 2 then
                title = "【"..(User.QILI_LEVEL[self.m_data.black_level] or "九级").."】"..(blackName or blackId).." 胜 "
                        .."【"..(User.QILI_LEVEL[nil] or "九级").."】"..(redName or redId);                
            else
                title = "【"..(User.QILI_LEVEL[self.m_data.red_level] or "九级").."】"..(redName or redId).." 平 "
                        .."【"..(User.QILI_LEVEL[self.m_data.black_level] or "九级").."】"..(blackName or blackId);  
            end;
        end;
    end;
    return title;
end;



ReplayRoomScene.getShareTime = function(self)
    local addTime = nil;
    if self.m_data then
        if self.m_data.add_time then
            addTime = "对局时间："..os.date("%Y/%m/%d %H:%M",self.m_data.add_time);
        end;
    end;
    return addTime;
end;

ReplayRoomScene.onCommentBtnClick = function(self)
    if UserInfo.getInstance():isFreezeUser() then return end;
    StateMachine.getInstance():pushState(States.Comment,StateMachine.STYPE_LEFT_IN);
end

ReplayRoomScene.onCollectionBtnClick = function(self)
    if not self.m_chioce_dialog then
        self.m_chioce_dialog = new(ChioceDialog)
    end;
    self.m_chioce_dialog:setMode(ChioceDialog.MODE_SHOUCANG);    
    self.m_save_cost = UserInfo.getInstance():getFPcostMoney().save_manual; 
    if tonumber(self.m_save_cost) == 0 then
--        self.m_chioce_dialog:setMessage("收藏棋谱免费，确认收藏？");
        self:saveChesstoMysave();
    else
        self.m_chioce_dialog:setMessage("是否花费"..(self.m_save_cost or 500) .."金币收藏当前棋谱？");
        self.m_chioce_dialog:setPositiveListener(self, self.saveChesstoMysave);
        self.m_chioce_dialog:show(); 
    end;  
end



-- 收藏到我的收藏
ReplayRoomScene.saveChesstoMysave = function(self)
    -- 收藏到服务器
    self:requestCtrlCmd(ReplayRoomController.s_cmds.save_mychess,self.m_chioce_dialog:getCheckState(),self.m_data);

end;



ReplayRoomScene.onEventTouch = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
    local user_id = 0;
    local down_x = 0;
    if finger_action == kFingerDown then
        down_x = x;
    end
    print_string("pos " .. down_x .. "");
    if down_x < 250 then
        user_id = self.m_data.red_mid;
    else
        user_id = self.m_data.black_mid;
    end
    
    if not user_id then
        return;
    end  
    if user_id ~= 0 then
        if finger_action == kFingerUp then
            StateMachine.getInstance():pushState(States.FriendsInfo,StateMachine.STYPE_CUSTOM_WAIT,nil,user_id);
        end
    else
--        ShowMessageAnim.fontSize = 24;
--        ShowMessageAnim.show_time = 1000;
--        ShowMessageAnim.play(self,"该玩家不存在");
        local message =  "该玩家不存在"; 
        ChessToastManager.getInstance():showSingle(message); 
    end
end

ReplayRoomScene.s_controlConfig = 
{
	[ReplayRoomScene.s_controls.back_btn]                   = {"title_view","back_btn"}; 
    [ReplayRoomScene.s_controls.title]                      = {"title_view","info_bg","title_view","title"};
    [ReplayRoomScene.s_controls.step_info]                  = {"title_view","info_bg","title_view","step_info"};
    [ReplayRoomScene.s_controls.title_view]                 = {"title_view","info_bg","title_view"};
    [ReplayRoomScene.s_controls.time]                       = {"title_view","time_bg","time"};
    [ReplayRoomScene.s_controls.board]                      = {"content_view","board"};
    [ReplayRoomScene.s_controls.left_user]                  = {"content_view","bottom_view","left_icon_bg"};
    [ReplayRoomScene.s_controls.right_user]                 = {"content_view","bottom_view","right_icon_bg"};
    [ReplayRoomScene.s_controls.share_btn]                  = {"bottom_view","share_btn"};
    [ReplayRoomScene.s_controls.comment_btn]                = {"bottom_view","comment_btn"};
    [ReplayRoomScene.s_controls.collection_btn]             = {"bottom_view","collection_btn"};
    [ReplayRoomScene.s_controls.userinfo_view]              = {"content_view","bottom_view"};
    [ReplayRoomScene.s_controls.pre_step]                   = {"bottom_view","pre_step"};
    [ReplayRoomScene.s_controls.next_step]                  = {"bottom_view","next_step"};
    [ReplayRoomScene.s_controls.progress_view]              = {"progress_view"};
    [ReplayRoomScene.s_controls.step_progress_holder]       = {"progress_view","progress_holder"};
    [ReplayRoomScene.s_controls.novice_guide_view]          = {"novice_guide_view"};
    
};

ReplayRoomScene.s_controlFuncMap =
{
    [ReplayRoomScene.s_controls.back_btn]                   = ReplayRoomScene.onBack;
    [ReplayRoomScene.s_controls.share_btn]                  = ReplayRoomScene.onShareBtnClick;
    [ReplayRoomScene.s_controls.comment_btn]                = ReplayRoomScene.onCommentBtnClick;
    [ReplayRoomScene.s_controls.collection_btn]             = ReplayRoomScene.onCollectionBtnClick;
    [ReplayRoomScene.s_controls.pre_step]                   = ReplayRoomScene.preStep;
    [ReplayRoomScene.s_controls.next_step]                  = ReplayRoomScene.nextStep;
};


ReplayRoomScene.s_cmdConfig =
{
    [ReplayRoomScene.s_cmds.updataUserIcon]                 = ReplayRoomScene.onUpdataUserIcon;
    [ReplayRoomScene.s_cmds.save_mychess]                   = ReplayRoomScene.onSaveMychessCallBack;
}