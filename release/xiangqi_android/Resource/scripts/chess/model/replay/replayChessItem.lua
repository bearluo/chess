--region *.lua
--Date
--
--endregion

-- 最近对局/我的收藏/棋友推荐item
ReplayChessItem = class(Node);

ReplayChessItem.WIDTH = 630;
ReplayChessItem.HEIGHT = 330;
ReplayChessItem.s_room = nil;
ReplayChessItem.s_type = nil;


ReplayChessItem.ctor = function(self, data)
--    if not data or data == "" then return end;
    self.m_data = json.decode(data);
    self.m_room = ReplayChessItem.s_room;
    self.m_type = ReplayChessItem.s_type;
    self.m_data.chess_type = self.m_type;
    self:setSize(ReplayChessItem.WIDTH,ReplayChessItem.HEIGHT);
    self:loadView();
    self:initView();
    self:initData();
end;

ReplayChessItem.dtor = function(self)
    
end;

ReplayChessItem.loadView = function(self)
    self.m_root_view = SceneLoader.load(replay_scene_node);
    self:addChild(self.m_root_view);
    -- title
    self.m_title_view = self.m_root_view:getChildByName("title");
        -- common_left_title
        self.m_common_left_title = self.m_title_view:getChildByName("common_left_title");
        self.m_common_left_icon = self.m_common_left_title:getChildByName("replay_icon");
        self.m_common_left_icon_icon = self.m_common_left_title:getChildByName("icon");
        self.m_common_left_icon_icon:setLevel(1);
        self.m_common_left_chess_type = self.m_common_left_title:getChildByName("chess_type");
        -- suggest_left_title
        self.m_suggest_left_title = self.m_title_view:getChildByName("suggest_left_title");
        self.m_suggest_left_title_icon_frame = self.m_suggest_left_title:getChildByName("icon_mask");
        self.m_suggest_left_title_owner_name = self.m_suggest_left_title:getChildByName("owner_name");        
        -- right_title
        self.m_right_title = self.m_title_view:getChildByName("right_title");
        self.m_chess_time = self.m_right_title:getChildByName("chess_time");
    -- content
    self.m_content_view = self.m_root_view:getChildByName("content");
      -- red_user
      self.m_red_user = self.m_content_view:getChildByName("red_user");
        -- icon_frame
        self.m_red_user_icon_frame = self.m_red_user:getChildByName("icon_frame");
        -- vip_frame
        self.m_red_user_vip_frame = self.m_red_user_icon_frame:getChildByName("vip_frame");
        self.m_red_user_vip_frame:setLevel(1);
        -- name
        self.m_red_user_name = self.m_red_user:getChildByName("name");
        -- level
        self.m_red_user_level = self.m_red_user:getChildByName("level");
      -- middle
      self.m_middle_view = self.m_content_view:getChildByName("middle");
        self.m_chess_board = self.m_middle_view:getChildByName("board");
        -- win_txt
        self.m_middle_win_txt = self.m_middle_view:getChildByName("win_bg"):getChildByName("win");
        self.m_middle_entry_btn = self.m_middle_view:getChildByName("entry_btn");
      -- black_user
      self.m_black_user = self.m_content_view:getChildByName("black_user");
        -- icon_frame
        self.m_black_user_icon_frame = self.m_black_user:getChildByName("icon_frame");
        -- vip_frame
        self.m_black_user_vip_frame = self.m_black_user_icon_frame:getChildByName("vip_frame");
        self.m_black_user_vip_frame:setLevel(1);
        -- name
        self.m_black_user_name = self.m_black_user:getChildByName("name");
        -- level
        self.m_black_user_level = self.m_black_user:getChildByName("level");
    -- bottom(btns)
    self.m_bottom_view = self.m_root_view:getChildByName("bottom");
      self.m_bottom_top_line = self.m_bottom_view:getChildByName("top_line");
      
    -- del_btn
    self.m_delete_btn = self.m_root_view:getChildByName("del");
    self.m_delete_btn:setLevel(10);
    self.m_delete_btn:setOnClick(self, function() 
        self:onSetListViewItemClickUnable(true)
        self:deleteSelf("确定删除此棋谱吗?")
    end);
      -- share_btn
      self.m_share_btn = self.m_bottom_view:getChildByName("share_btn");
      self.m_share_btn:setOnClick(self, self.shareSelf);
      self.m_share_btn_txt = self.m_share_btn:getChildByName("num");
      -- save_btn
      self.m_save_btn = self.m_bottom_view:getChildByName("save_btn");
      self.m_save_btn:setOnClick(self, self.saveSelf);
      self.m_save_btn_icon = self.m_save_btn:getChildByName("img");
      self.m_save_btn_txt = self.m_save_btn:getChildByName("num");
      -- comment_btn
      self.m_comment_btn = self.m_bottom_view:getChildByName("comment_btn");
      self.m_comment_btn:setOnClick(self, self.commentSelf);   
      self.m_comment_btn_txt = self.m_comment_btn:getChildByName("num");

      self.m_bottom_line1 = self.m_bottom_view:getChildByName("line1");
      self.m_bottom_line2 = self.m_bottom_view:getChildByName("line2");
      -- front_bg
      self.m_front_bg = self.m_root_view:getChildByName("front_bg");
      self.m_front_bg:setEventTouch(self, function() 
            self:onSetListViewItemClickUnable(false)
      end);
end;


ReplayChessItem.initView = function(self)
    if self.m_type == ReplayScene.REPLAY then
        -- title
        self.m_common_left_title:setVisible(true);
        self.m_suggest_left_title:setVisible(false);
        -- btns
        self.m_delete_btn:setVisible(true);
        self.m_share_btn:setVisible(true);
        self.m_share_btn:setPos(60,0);
        self.m_share_btn_txt:setText("分享");
        self.m_save_btn:setVisible(true);
        self.m_save_btn:setPos(150,0);
        self.m_save_btn_txt:setText("收藏");

        self.m_comment_btn:setVisible(false);
        self.m_bottom_line1:setPos(30,0);
        self.m_bottom_line2:setPos(30,0);
    elseif self.m_type == ReplayScene.MYSAVE then
        -- title
        self.m_common_left_title:setVisible(true);
        self.m_suggest_left_title:setVisible(false);
        -- btns
        if kPlatform == kPlatformIOS then
            if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
                self.m_share_btn:setVisible(true);
            else
                self.m_share_btn:setVisible(false);
            end;            
        else
            self.m_share_btn:setVisible(true);
        end;
        self.m_share_btn:setPos(30);
        self.m_save_btn:setVisible(true);
        self.m_save_btn:setPos(100);
        self.m_comment_btn:setVisible(true);   
        self.m_comment_btn:setPos(30);
        self.m_bottom_line1:setPos(-70,0);
        self.m_bottom_line2:setPos(110,0);
    elseif self.m_type == ReplayScene.SUGGEST then
        -- title
        self.m_common_left_title:setVisible(false);
        self.m_suggest_left_title:setVisible(true);
        -- btns
        self.m_save_btn:setVisible(true);
        self.m_save_btn:setPos(100);
        if kPlatform == kPlatformIOS then
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
        self.m_delete_btn:setVisible(false);
        self.m_bottom_line1:setPos(-70,0);
        self.m_bottom_line2:setPos(110,0);
    end;
end;

ReplayChessItem.initData = function(self)
    if self.m_type == ReplayScene.REPLAY then
        self:initReplayChessState();
    elseif self.m_type == ReplayScene.MYSAVE then
        self:initMysaveChessState();
    elseif self.m_type == ReplayScene.SUGGEST then
        self:initSuggestChessState();
    end;   
    self:initLeftTitle(); 
    self:initUserData();
    self:initChessData();
end;

ReplayChessItem.initLeftTitle = function(self)
    -- manual_type
    if self.m_data.manual_type then
        if tonumber(self.m_data.manual_type) == 1 then
            self.m_common_left_icon:setColor(180,55,55);
            self.m_common_left_chess_type:setColor(180,55,55);
            self.m_common_left_chess_type:setText("联网对战");
        elseif tonumber(self.m_data.manual_type) == 2 then
            self.m_common_left_icon:setColor(55,85,145);
            self.m_common_left_chess_type:setColor(55,85,145);
            self.m_common_left_chess_type:setText("残局挑战");
        elseif tonumber(self.m_data.manual_type) == 3 then
            self.m_common_left_icon:setColor(50,110,30);
            self.m_common_left_chess_type:setColor(50,110,30);
            self.m_common_left_chess_type:setText("单机挑战");
        elseif tonumber(self.m_data.manual_type) == 4 then
            self.m_common_left_icon:setColor(50,110,30);
            self.m_common_left_chess_type:setColor(50,110,30);
            self.m_common_left_chess_type:setText("单机打谱");        
        elseif tonumber(self.m_data.manual_type) == 5 then
            self.m_common_left_icon:setColor(55,85,145);
            self.m_common_left_chess_type:setColor(55,85,145);
            self.m_common_left_chess_type:setText("街边残局");
        elseif tonumber(self.m_data.manual_type) == 6 then
            self.m_common_left_icon:setColor(180,55,55);
            self.m_common_left_chess_type:setColor(180,55,55);
            self.m_common_left_chess_type:setText("联网观战");
        else
            self.m_common_left_icon:setColor(180,55,55);
            self.m_common_left_chess_type:setColor(180,55,55);
        end;
    end;
    -- time
    if self.m_type == ReplayScene.REPLAY then
        if self.m_data.time then
            self.m_chess_time:setText(self.m_data.time);
        else
            self.m_chess_time:setText();
        end; 
    elseif self.m_type == ReplayScene.MYSAVE then
        if self.m_data.add_time then
            self.m_chess_time:setText(os.date("%Y/%m/%d",self.m_data.add_time));
        else
            self.m_chess_time:setText();
        end;        
    elseif self.m_type == ReplayScene.SUGGEST then
        FriendsData.getInstance():getUserData(self.m_data.mid);
        self.m_owner_user_icon = new(Mask,UserInfo.DEFAULT_ICON[1],"userinfo/icon_7070_frame2.png");
        self.m_owner_user_icon:setEventTouch(self, self.toFriendScene);
        self.m_owner_user_icon:setSize(38,38);
        self.m_owner_user_icon:setAlign(kAlignCenter);
        self.m_suggest_left_title_icon_frame:addChild(self.m_owner_user_icon);

        if self.m_data.icon_url then
            self.m_owner_user_icon:setUrlImage(self.m_data.icon_url,UserInfo.DEFAULT_ICON[1]);
        else
            self.m_owner_user_icon:setFile(UserInfo.DEFAULT_ICON[1]);
        end;     
        if self.m_data.mnick then
            self.m_suggest_left_title_owner_name:setText(self.m_data.mnick);
        else
            self.m_suggest_left_title_owner_name:setText("博雅象棋");
        end;      
        if self.m_data.add_time then
            if ToolKit.isSecondDay(self.m_data.add_time) then
                self.m_chess_time:setText(os.date("%Y/%m/%d %H:%M",self.m_data.add_time));
            else
                self.m_chess_time:setText(os.date("%H:%M",self.m_data.add_time));
            end;
        else
            self.m_chess_time:setText();
        end;   
    end;  
end;


ReplayChessItem.toFriendScene = function(self,finger_action,x,y,drawing_id_first,drawing_id_current, event_time)
    self:onSetListViewItemClickUnable(true);
    if finger_action ~= kFingerDown then
        if UserInfo.getInstance():getUid() ~= tonumber(self.m_data.mid) then
            StateMachine.getInstance():pushState(States.FriendsInfo,StateMachine.STYPE_CUSTOM_WAIT,nil,tonumber(self.m_data.mid));
        end;
    end;
end;

ReplayChessItem.initReplayChessState = function(self)
    if self.m_data.is_collect then
        -- 1已收藏，0未收藏
        if tonumber(self.m_data.is_collect) == 1 then 
--            self.m_save_btn:setFile("replay/has_save.png");     
--            self.m_save_btn:setPickable(false);            
        elseif tonumber(self.m_data.is_collect) == 0 then
--            self.m_save_btn:setFile("replay/save.png");
--            self.m_save_btn:setPickable(true);
        end;
    else
       self.m_data.is_collect = 0;
    end;
--    self.m_room:updateRecentChessData(self);
end;


ReplayChessItem.setReplayIsCollect = function(self)
--   if self.m_data.is_collect then
--       if tonumber(self.m_data.is_collect) == 0 then
--            self.m_data.is_collect = 1;
--       else
--            self.m_data.is_collect = 0;
--       end
--   end;
--   self:initReplayChessState();
end;


ReplayChessItem.initSuggestChessState = function(self)
    if self.m_data.is_collect then
        -- 1已收藏，0未收藏
        if tonumber(self.m_data.is_collect) == 1 then 
            self.m_save_btn_icon:setFile("common/has_save.png");                
        elseif tonumber(self.m_data.is_collect) == 0 then
            self.m_save_btn_icon:setFile("common/save.png");
        end;
        self.m_save_btn_txt:setText(self.m_data.collect_num or 0);
        self.m_comment_btn_txt:setText(self.m_data.comment_num or 0);  
        self.m_share_btn_txt:setText(self.m_data.share_num or 0); 
    else
        self.m_data.is_collect = 0;
    end;
end;

ReplayChessItem.setSuggestIsCollect = function(self)
   if tonumber(self.m_data.is_collect) == 0 then
        self.m_data.is_collect = 1;
   else
        self.m_data.is_collect = 0;
   end    
   self:initSuggestChessState();
end;

ReplayChessItem.initMysaveChessState = function(self)
    if self.m_data.collect_type then
        if tonumber(self.m_data.collect_type) == 1 then
            self.m_save_btn_icon:setFile("common/has_save.png");    
            self.m_save_btn_txt:setText(self.m_data.collect_num or 0);
            self.m_comment_btn_txt:setText(self.m_data.comment_num or 0);  
            self.m_share_btn_txt:setText(self.m_data.share_num or 0); 
            self.m_data.is_collect = 1;
        end;
    end;
end;

ReplayChessItem.setOpenOrSelfType = function(self)
--   if tonumber(self.m_data.collect_type) == 1 then
--        self.m_data.collect_type = 2;
--        ChessToastManager.getInstance():showSingle("仅自己可见");
--   else
--        self.m_data.collect_type = 1;
--        ChessToastManager.getInstance():showSingle("公开可见");
--   end    
--   self:initMysaveChessState();
end;


ReplayChessItem.initUserData = function(self)
    -- red_icon
    self.m_red_user_icon = new(Mask,UserInfo.DEFAULT_ICON[1],"userinfo/icon_7070_frame2.png");
    self.m_red_user_icon:setSize(68,68);
    self.m_red_user_icon:setAlign(kAlignCenter);
    self.m_red_user_icon_frame:addChild(self.m_red_user_icon);
    if self.m_data.red_icon_url and self.m_data.red_icon_url ~= "" then
        self.m_red_user_icon:setUrlImage(self.m_data.red_icon_url,UserInfo.DEFAULT_ICON[1]);
    else
        self.m_red_user_icon:setFile(UserInfo.DEFAULT_ICON[1]);
    end;
    -- red_name
    if self.m_data.red_mnick then
        local len = string.lenutf8(GameString.convert2UTF8(self.m_data.red_mnick) or "");
        if len > 4 then
            local name = string.subutf8(self.m_data.red_mnick,1,4);
            self.m_red_user_name:setText(name.."...");
        else
            self.m_red_user_name:setText(self.m_data.red_mnick);
        end;
    else
        self.m_red_user_name:setText("博雅象棋");
    end;
    -- red_level
    if self.m_data.red_level then
        if type(self.m_data.red_level)=="number" then
            self.m_red_user_level:setFile("common/icon/level_"..self.m_data.red_level..".png");
        else
            self.m_red_user_level:setFile("common/icon/level_9.png");
        end;
    else
        self.m_red_user_level:setFile("common/icon/level_9.png");
    end;


    -- black_icon
    self.m_black_user_icon = new(Mask,UserInfo.DEFAULT_ICON[1],"userinfo/icon_7070_frame2.png");
    self.m_black_user_icon:setSize(68,68);
    self.m_black_user_icon:setAlign(kAlignCenter);
    self.m_black_user_icon_frame:addChild(self.m_black_user_icon);
    if self.m_data.black_icon_url and self.m_data.black_icon_url ~= "" then
        self.m_black_user_icon:setUrlImage(self.m_data.black_icon_url,UserInfo.DEFAULT_ICON[1]);
    else
        self.m_black_user_icon:setFile(UserInfo.DEFAULT_ICON[1]);
    end;
    -- black_name
    if self.m_data.black_mnick then
        local len = string.lenutf8(GameString.convert2UTF8(self.m_data.black_mnick) or "");
        if len > 4 then
            local name = string.subutf8(self.m_data.black_mnick,1,4);
            self.m_black_user_name:setText(name.."...");
        else
            self.m_black_user_name:setText(self.m_data.black_mnick);
        end;
    else
        self.m_black_user_name:setText("博雅象棋");
    end;
    -- black_level
    if self.m_data.black_level then
        if type(self.m_data.black_level)=="number" then
            self.m_black_user_level:setFile("common/icon/level_"..self.m_data.black_level..".png");
        else
            self.m_black_user_level:setFile("common/icon/level_9.png");
        end;
    else
        self.m_black_user_level:setFile("common/icon/level_9.png");
    end;
    self:setVip();
end;

ReplayChessItem.setVip = function(self)
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
            self.m_black_user_vip_frame:setVisible(upframeRes.visible);
            local fw,fh = self.m_black_user_vip_frame:getSize();
            if upframeRes.frame_res then
                self.m_black_user_vip_frame:setFile(string.format(upframeRes.frame_res,fw));
            end
        end;

        if downframeRes then 
            self.m_red_user_vip_frame:setVisible(downframeRes.visible);
            local fw,fh = self.m_red_user_vip_frame:getSize();
            if downframeRes.frame_res then
                self.m_red_user_vip_frame:setFile(string.format(downframeRes.frame_res,fw));
            end
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
            self.m_red_user_vip_frame:setVisible(upframeRes.visible);
            local fw,fh = self.m_red_user_vip_frame:getSize();
            if upframeRes.frame_res then
                self.m_red_user_vip_frame:setFile(string.format(upframeRes.frame_res,fw));
            end
        end;

        if downframeRes then 
            self.m_black_user_vip_frame:setVisible(downframeRes.visible);
            local fw,fh = self.m_black_user_vip_frame:getSize();
            if downframeRes.frame_res then
                self.m_black_user_vip_frame:setFile(string.format(downframeRes.frame_res,fw));
            end
        end;        
    else
        
    end;
end;

ReplayChessItem.initChessData = function(self)
    -- chess_board
    self.m_board = new(Board,168,188,self);
    Board.resetFenPiece();
    local chess_map = self.m_board:fen2chessMap(self.m_data.end_fen or "3ak4/4a4/9/7N1/9/9/9/9/9/5K3 r");
    if tonumber(self.m_data.down_user) == tonumber(self.m_data.red_mid) then
        self.m_board.m_flipped = false;
    else
        self.m_board.m_flipped = true;
    end;
    self.m_board:copyChess90(chess_map);
    self.m_chess_board:addChild(self.m_board);

    -- win_flag
    if self.m_data.win_flag then
        local flag = tonumber(self.m_data.win_flag);
        if flag == 0 then
            self.m_middle_win_txt:setText("和棋");
        elseif flag == 1 then
            self.m_middle_win_txt:setText("红胜");
        elseif flag == 2 then
            self.m_middle_win_txt:setText("黑胜");
        end;
    end;
    
end;

------------------------------- function -----------------------------------
ReplayChessItem.setManualId = function(self,id)
    self.m_data.manual_id = id;
end;

ReplayChessItem.getManualId = function(self)
    return self.m_data.manual_id;
end;

ReplayChessItem.getChioceDlgCheckState = function(self)
    if self.m_replayItem_chioce_dialog then
        return self.m_replayItem_chioce_dialog:getCheckState() or false;
    end;
    return false;
end;

ReplayChessItem.getData = function(self)
    return self.m_data or nil;
end;


ReplayChessItem.entryReplayRoom = function(self,finger_action,x,y,drawing_id_first,drawing_id_current)
    Log.i("ReplayChessItem.entryReplayRoom");
--    if self.m_room then
--        self.m_room:entryReplayRoom(self.m_data);
--    end;
end;




ReplayChessItem.deleteSelf = function(self,msg)
--    Log.i("ReplayChessItem.deleteSelf");
--    if self.m_room then
--        self.m_room:resetListViewItemClick(true);
--    end;
--    self:onSetListViewItemClickUnable(true)
    if not self.m_replayItem_chioce_dialog then
        self.m_replayItem_chioce_dialog = new(ChioceDialog);
        self.m_replayItem_chioce_dialog:setMaskDialog(true)
        self.m_replayItem_chioce_dialog:setNeedMask(false)
    end;
    self.m_replayItem_chioce_dialog:setMode(ChioceDialog.MODE_SURE);
    self.m_replayItem_chioce_dialog:setMessage(msg);
    self.m_replayItem_chioce_dialog:setPositiveListener(self,function() 
        if self.m_room and self.m_room.deleteListViewItem then
            self.m_room:deleteListViewItem(self);
        end;   
    end);
    self.m_replayItem_chioce_dialog:show();
end;

ReplayChessItem.shareSelf = function(self)
    self:onSetListViewItemClickUnable(true)
    if self.m_type == ReplayScene.REPLAY then
        if self.m_room and self.m_room.getChessManualId then
            self.m_room:getChessManualId(self);
        end;
    elseif self.m_type == ReplayScene.MYSAVE then
        self:shareChess();     
    elseif self.m_type == ReplayScene.SUGGEST then
        self:shareChess();
    end;
end;

ReplayChessItem.shareChess = function(self)
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
--    if self.m_room then
--        self.m_room:shareChess(manualData);
--    end;
    if not self.commonShareDialog then
        self.commonShareDialog = new(CommonShareDialog);
    end
    self.commonShareDialog:setShareDate(manualData,"manual_share");
    self.commonShareDialog:show();
end

ReplayChessItem.getShareTitle = function(self)
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
                title = "【"..(User.QILI_LEVEL[self.m_data.black_level] or "九级").."】"..(blackName or redId).." 胜 "
                        .."【"..(User.QILI_LEVEL[self.m_data.black_level] or "九级").."】"..(redName or redId);                
            else
                title = "【"..(User.QILI_LEVEL[self.m_data.red_level] or "九级").."】"..(redName or redId).." 平 "
                        .."【"..(User.QILI_LEVEL[self.m_data.black_level] or "九级").."】"..(blackName or blackId);  
            end;
        end;
    end;
    return title;
end;



ReplayChessItem.getShareTime = function(self)
    local addTime = nil;
    if self.m_data then
        if self.m_data.add_time then
            addTime = "对局时间："..os.date("%Y/%m/%d %H:%M",self.m_data.add_time);
        end;
    end;
    return addTime;
end;

ReplayChessItem.saveSelf = function(self)
--    Log.i("ReplayChessItem.saveSelf");
--    if self.m_room then
--        self.m_room:resetListViewItemClick(true);
--    end;
    self:onSetListViewItemClickUnable(true)
--    if not self.m_replayItem_chioce_dialog then
--        self.m_replayItem_chioce_dialog = new(ChioceDialog);
--    end;
--    local save_cost;  
--    self.m_replayItem_chioce_dialog:setMode(ChioceDialog.MODE_SHOUCANG);  
--    if self.m_type == ReplayScene.REPLAY then
--        save_cost = UserInfo.getInstance():getFPcostMoney().save_manual;  
--    elseif self.m_type == ReplayScene.SUGGEST then
--        save_cost = UserInfo.getInstance():getFPcostMoney().collect_manual; 
--    end;
--    self.m_save_cost = save_cost;
--    if tonumber(self.m_save_cost) == 0 then
--        self.m_replayItem_chioce_dialog:setMessage("收藏棋谱免费，确认收藏？");
    if self.m_data.is_collect and tonumber(self.m_data.is_collect) == 1 then
        local msg;
        if self.m_type == ReplayScene.REPLAY then
        elseif self.m_type == ReplayScene.MYSAVE then
            msg = "取消收藏当前棋谱吗?";    
        elseif self.m_type == ReplayScene.SUGGEST then
            msg = "取消收藏当前棋谱吗?";  
        end;
        self:deleteSelf(msg);
    else
        if self.m_room then
            self.m_room:saveChesstoMysave(self);
        end;               
    end;

--    else
--        self.m_replayItem_chioce_dialog:setMessage("是否花费"..(self.m_save_cost or 500) .."金币收藏当前棋谱？");
--        self.m_replayItem_chioce_dialog:setPositiveListener(self,function() 
--            if self.m_room then
--                self.m_room:saveChesstoMysave(self);
--            end;   
--        end);
--        self.m_replayItem_chioce_dialog:show();
--    end;
end;

-- 公开棋谱或私密棋谱
ReplayChessItem.openSelf = function(self)
--    Log.i("ReplayChessItem.openSelf");
    local ret = self:onSetListViewItemClickUnable(true)
    if not ret then return end
--    if self.m_room then
--        self.m_room:resetListViewItemClick(true);
--    else
--        return;
--    end;
    if tonumber(self.m_data.collect_type) == 1 then
        self.m_room:openOrSelfDapu(self,2);
    else
        self.m_room:openOrSelfDapu(self,1);
    end
end;

ReplayChessItem.commentSelf = function(self)
    if UserInfo.getInstance():isFreezeUser() then return end;
    self:onSetListViewItemClickUnable(true)
    UserInfo.getInstance():setDapuSelData(self.m_data);
    StateMachine.getInstance():pushState(States.Comment,StateMachine.STYPE_LEFT_IN);
end;

--[Comment]
--设置注销listview点击事件
function ReplayChessItem.onSetListViewItemClickUnable(self,ret)
    if self.m_room then
        self.m_room:resetListViewItemClick(ret);
        return true
    end;
    return false
end