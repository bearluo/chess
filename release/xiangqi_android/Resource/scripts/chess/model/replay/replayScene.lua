
require(BASE_PATH.."chessScene");
require("view/selectButton_nobg");
require("dialog/progress_dialog");
require("dialog/create_room_dialog");
require("animation/TranslateShakeAnim");
require("ui/gallery");
require(VIEW_PATH .."replay_scene_node");
require("dialog/common_help_dialog");
require(VIEW_PATH .."replay_scroll_node");
require(MODEL_PATH .. "replay/replayChessItem")
ReplayScene = class(ChessScene);

ReplayScene.REPLAY  = 1;-- 最近对局
ReplayScene.MYSAVE  = 2;-- 我的收藏
ReplayScene.SUGGEST = 3;-- 棋友动态(推荐)
ReplayScene.FIRST_CHESS_TIME = 1448899200; -- 2015/12/01 0:0:0(php后台所能查到最早棋谱id时间)

ReplayScene.s_controls = 
{
    bamboo_left_dec             = 1;
    bamboo_right_dec            = 2;
    tea_dec                     = 3;
    stone_dec                   = 4;
    back_btn                    = 5;
    title_view                  = 6;
    title_bg                    = 7;
    title_subbg                 = 8;
    replay_content_view         = 9;
    replayList_view             = 10;
    dapu_content_view           = 11;
    dapuList_view               = 12;
    bottom_view                 = 13;
    title_mysave                = 14;
    btns_content_view           = 15;
    suggest_content_view        = 16;
    suggestList_view            = 17;
    clear_all_btn               = 18;
    clear_all_btn_bg            = 19;
    date_select_view            = 20;
}

ReplayScene.s_cmds = 
{
    save_mychess                = 1;
    get_mychess                 = 2;
    open_self_chess             = 3;
    del_mysave_chess            = 4;
    get_suggestchess            = 5;
    get_mychess_bytime          = 6;
    get_suggest_bytime          = 7;
}

ReplayScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = ReplayScene.s_controls;
    self.m_cur_state = ReplayScene.REPLAY;
    self:initView();
end 

ReplayScene.resume = function(self)
    ChessScene.resume(self);
    self:loadTips();
end;

ReplayScene.pause = function(self)
	ChessScene.pause(self);
    self:removeAnimProp();
end 


ReplayScene.dtor = function(self)
    self.m_title_subbg:removeProp(1);
    delete(self.m_animY_down);
    self.m_animY_down = nil;
    delete(self.m_init_anim);
    delete(self.m_anim_start);
    delete(self.m_anim_end);
    delete(self.m_chioce_dialog);
    delete(self.m_help_dialog)
end 

------------------------------function------------------------------



ReplayScene.initView = function(self)
    --bg
    self.m_bamboo_left_dec = self:findViewById(self.m_ctrls.bamboo_left_dec); 
    self.m_bamboo_right_dec = self:findViewById(self.m_ctrls.bamboo_right_dec); 

    self.m_bamboo_left_dec:setFile("common/decoration/left_leaf.png")
    self.m_bamboo_right_dec:setFile("common/decoration/right_leaf.png")

    self.m_tea_dec = self:findViewById(self.m_ctrls.tea_dec); 
    self.m_stone_dec = self:findViewById(self.m_ctrls.stone_dec);

    --title
    self.m_title_view = self:findViewById(self.m_ctrls.title_view);
    self.m_back_btn = self:findViewById(self.m_ctrls.back_btn);
    self.m_title_bg = self:findViewById(self.m_ctrls.title_bg);
    self.m_title_subbg = self:findViewById(self.m_ctrls.title_subbg);
    self.m_clear_btn_bg = self:findViewById(self.m_ctrls.clear_all_btn_bg);
    self.m_clear_all_btn = self:findViewById(self.m_ctrls.clear_all_btn);
    self.m_clear_all_btn:setOnClick(self,self.clearAllRecentData);

    -- btns_content
    self.m_btns_content_view = self:findViewById(self.m_ctrls.btns_content_view);
        
       self.m_recent_btn = self.m_btns_content_view:getChildByName("replay_btn"):getChildByName("btn");
       self.m_recent_btn:setOnClick(self, self.showRecentList);
       self.m_recent_btn_txt = self.m_recent_btn:getChildByName("btn_txt");
       self.m_recent_btn_txt:setText("最近对局");
       self.m_recent_btn_txt:setColor(215,75,45);
       self.m_recent_tips = self.m_btns_content_view:getChildByName("replay_btn"):getChildByName("tips");
       self.m_recent_line = self.m_btns_content_view:getChildByName("replay_btn"):getChildByName("select_line");

       self.m_mysave_btn = self.m_btns_content_view:getChildByName("dapu_btn"):getChildByName("btn");
       self.m_mysave_btn:setOnClick(self, self.showMySaveList);
       self.m_mysave_btn_txt = self.m_mysave_btn:getChildByName("btn_txt");
       self.m_mysave_btn_txt:setText("我的收藏");
       self.m_mysave_btn_txt:setColor(120,80,65);
       self.m_mysave_tips = self.m_btns_content_view:getChildByName("dapu_btn"):getChildByName("tips");
       self.m_mysave_line = self.m_btns_content_view:getChildByName("dapu_btn"):getChildByName("select_line");

       self.m_suggest_btn = self.m_btns_content_view:getChildByName("suggest_btn"):getChildByName("btn");
       self.m_suggest_btn:setOnClick(self, self.showSuggestList);
       self.m_suggest_btn_txt = self.m_suggest_btn:getChildByName("btn_txt");
       self.m_suggest_btn_txt:setText("棋友推荐");
       self.m_suggest_btn_txt:setColor(120,80,65);
       self.m_suggest_tips = self.m_btns_content_view:getChildByName("suggest_btn"):getChildByName("tips");
       self.m_suggest_line = self.m_btns_content_view:getChildByName("suggest_btn"):getChildByName("select_line");

    -- content
        self.m_replay_content_view = self:findViewById(self.m_ctrls.replay_content_view);
            -- 最近对战
            self.m_replay_filter_content = self.m_replay_content_view:getChildByName("filter_content");
            self.m_replay_filter_btn = self.m_replay_filter_content:getChildByName("filter_view"):getChildByName("date_btn");
            self.m_replay_filter_btn:setOnClick(self,self.onReplayFilterBtn);
            self.m_replay_filter_txt = self.m_replay_filter_btn:getChildByName("date_txt");
            self.m_replay_filter_view = self.m_replay_content_view:getChildByName("replay_filter_view");
            self.m_replay_filter_view:setOnScroll(self,self.onReplayScrollLVScroll);
            self.m_replay_filter_view:setVisible(false);

            self.m_replayList_view = self.m_replay_content_view:getChildByName("replayList_view");
            self.m_replay_empty_tips =  self.m_replay_content_view:getChildByName("enpty_tips");
            self.m_replay_filter_empty_tips =  self.m_replay_content_view:getChildByName("filter_empty_tips");
        self.m_dapu_content_view  = self:findViewById(self.m_ctrls.dapu_content_view);
            -- 我的收藏
            self.m_dapu_filter_content = self.m_dapu_content_view:getChildByName("filter_content");
            self.m_dapu_filter_btn = self.m_dapu_filter_content:getChildByName("filter_view"):getChildByName("date_btn");
            self.m_dapu_filter_btn:setOnClick(self,self.onDapuFilterBtn);
            self.m_dapu_filter_txt = self.m_dapu_filter_btn:getChildByName("date_txt");
            self.m_dapu_filter_view = self.m_dapu_content_view:getChildByName("dapu_filter_view");
            self.m_dapu_filter_view:setOnScroll(self,self.onDapuScrollLVScroll);
            self.m_dapu_filter_view:setVisible(false);

            self.m_dapuList_view = self.m_dapu_content_view:getChildByName("dapuList_view");
            self.m_dapuList_view:setOnScroll(self,self.onDapuLVScroll);
            self.m_dapu_empty_tips =  self.m_dapu_content_view:getChildByName("enpty_tips");
            self.m_dapu_filter_empty_tips =  self.m_dapu_content_view:getChildByName("filter_empty_tips");
        self.m_suggest_content_view  = self:findViewById(self.m_ctrls.suggest_content_view);
            -- 棋友动态(推荐)
            self.m_suggest_filter_content = self.m_suggest_content_view:getChildByName("filter_content");
            self.m_suggest_filter_btn = self.m_suggest_filter_content:getChildByName("filter_view"):getChildByName("date_btn");
            self.m_suggest_filter_btn:setOnClick(self,self.onSuggestFilterBtn);
            self.m_suggest_filter_txt = self.m_suggest_filter_btn:getChildByName("date_txt");
            self.m_suggest_filter_view = self.m_suggest_content_view:getChildByName("suggest_filter_view");
            self.m_suggest_filter_view:setOnScroll(self,self.onSuggestScrollLVScroll);
            self.m_suggest_filter_view:setVisible(false);
            self.m_suggestList_view = self.m_suggest_content_view:getChildByName("suggestList_view");
            self.m_suggestList_view:setOnScroll(self,self.onSuggestLVScroll);
            self.m_suggest_empty_tips =  self.m_suggest_content_view:getChildByName("enpty_tips");
            self.m_suggest_filter_empty_tips =  self.m_suggest_content_view:getChildByName("filter_empty_tips");
    -- bottom_view
    self.m_bottom_view = self:findViewById(self.m_ctrls.bottom_view);

    -- decoration
    self.m_teapot_dec = self.m_root:getChildByName("tea_dec");
    -- help_btn
    self.m_help_btn = self.m_root:getChildByName("help_btn");
    self.m_help_btn:setOnClick(self,self.showHelpInfo);

    -- date_list
    self.m_date_select_view = self:findViewById(self.m_ctrls.date_select_view);
    self.m_date_select_bg = self.m_date_select_view:getChildByName("select_bg");
    self.m_date_select_bg:setTransparency(0.3);
    self.m_date_select_bg:setEventTouch(self, self.dateFilterHide);
    self.m_date_bg = self.m_date_select_view:getChildByName("date_bg");
    self.m_date_select_list = self.m_date_select_view:getChildByName("date_bg"):getChildByName("date_list");

    -- show_recent    
    delete(self.m_init_anim);
    self.m_init_anim = new(AnimInt,kAnimNormal,0,1,1,1000); 
    if not self.m_init_anim then return end;
    self.m_init_anim:setEvent(self,function() 
        self:showRecentList();
    end);
end;

ReplayScene.showHelpInfo = function(self)
    if not self.m_help_dialog then
        self.m_help_dialog = new(CommonHelpDialog)
        self.m_help_dialog:setMode(CommonHelpDialog.replay_mode)
    end 
    self.m_help_dialog:show()
end;

-- 最近对局筛选view
ReplayScene.onReplayScrollLVScroll = function(self,scroll_status,diff, totalOffset)
    local lvW, lvH = self.m_replay_filter_view:getSize();
    local viewLength = self.m_replay_filter_view:getViewLength();
    local trueOffset = viewLength - lvH;
    if totalOffset and trueOffset > 0 then
        if (math.abs(tonumber(totalOffset)) >  trueOffset + 50) then
            if not self.m_is_loading_replay_scroll then
                self.m_is_loading_replay_scroll = true;
                if #self.m_replay_local_datas > 0 then
                    self:addReplayFilterData();
                end;
            end;
        elseif math.abs(tonumber(totalOffset)) > trueOffset then
            self.m_is_loading_replay_scroll = false;
        end;
    end;
end;

-- 我的收藏筛选view
ReplayScene.onDapuScrollLVScroll = function(self,scroll_status,diff, totalOffset)
    local lvW, lvH = self.m_dapu_filter_view:getSize();
    local viewLength = self.m_dapu_filter_view:getViewLength();
    local trueOffset = viewLength - lvH;
    if totalOffset and trueOffset > 0 then
        if (math.abs(tonumber(totalOffset)) >  trueOffset + 50) then
            if not self.m_is_loading_dapu_bytime then
                self.m_is_loading_dapu_bytime = true;
                if self.m_masave_bytime_adapter then
                    local start = self.m_masave_bytime_adapter:getCount();
                    self:getMysaveChessByTime(start,10,self.m_dapu_cur_month[1],self.m_dapu_cur_month[2]);
                end;
            end;
        elseif math.abs(tonumber(totalOffset)) > trueOffset then
            self.m_is_loading_dapu_bytime = false;
        end;
    end;
end;

-- 棋谱推荐筛选view
ReplayScene.onSuggestScrollLVScroll = function(self,scroll_status,diff, totalOffset)
    local lvW, lvH = self.m_suggest_filter_view:getSize();
    local viewLength = self.m_suggest_filter_view:getViewLength();
    local trueOffset = viewLength - lvH;
    if totalOffset and trueOffset > 0 then
        if (math.abs(tonumber(totalOffset)) >  trueOffset + 50) then
            if not self.m_is_loading_suggest_bytime then
                self.m_is_loading_suggest_bytime = true;
                if self.m_suggest_bytime_adapter then
                    local start = self.m_suggest_bytime_adapter:getCount();
                    self:getSuggestChessByTime(start,10,self.m_suggest_cur_month[1],self.m_suggest_cur_month[2]);
                end;
            end;
        elseif math.abs(tonumber(totalOffset)) > trueOffset then
            self.m_is_loading_suggest_bytime = false;
        end;
    end;
end;


ReplayScene.onDapuLVScroll = function(self,scroll_status,diff, totalOffset)
    local lvW, lvH = self.m_dapuList_view:getSize();
    local viewLength = self.m_dapuList_view:getViewLength();
    local trueOffset = viewLength - lvH;
    if totalOffset and trueOffset > 0 then
        if (math.abs(tonumber(totalOffset)) >  trueOffset + 50) then
            if not self.m_is_loading_dapu then
                self.m_is_loading_dapu = true;
                local start = self.m_masave_adapter:getCount();
                self:getMysaveChess(start,10); 
            end;
        elseif math.abs(tonumber(totalOffset)) > trueOffset then
            self.m_is_loading_dapu = false;
        end;
    end;
end;


ReplayScene.onSuggestLVScroll = function(self,scroll_status,diff, totalOffset)
    local lvW, lvH = self.m_suggestList_view:getSize();
    local trueOffset = self.m_suggest_list_num * ReplayChessItem.HEIGHT - lvH;
    if totalOffset and trueOffset > 0 then
        if (math.abs(tonumber(totalOffset)) >  trueOffset + 50) then
            if not self.m_is_loading_suggest then
                self.m_is_loading_suggest = true;
                self:getSuggestChess(self.m_suggest_list_num,10); 
            end;
        elseif math.abs(tonumber(totalOffset)) > trueOffset then
            self.m_is_loading_suggest = false;
        end;
    end;
end;




-- 本地数据过多，会有卡顿，加个提示增加体验；加载完成去掉Toast
ReplayScene.loadTips = function(self)
    ChessToastManager.getInstance():showSingle("正在加载数据",1000);
end

ReplayScene.setAnimItemEnVisible = function(self,ret)
    self.m_bamboo_left_dec:setVisible(ret);
    self.m_bamboo_right_dec:setVisible(ret);
end

ReplayScene.resumeAnimStart = function(self,lastStateObj,timer,func)
    self:removeAnimProp(); 
   local duration = timer.duration;
   local waitTime = timer.waitTime
   local delay = waitTime+duration;

    delete(self.m_anim_start);
    self.m_anim_start = new(AnimInt,kAnimNormal,0,1,delay,-1);
    if self.m_anim_start then
        self.m_anim_start:setEvent(self,function()
            self:setAnimItemEnVisible(true);
            delete(self.m_anim_start);
        end);
    end

   local lw,lh = self.m_bamboo_left_dec:getSize();
   self.m_bamboo_left_dec:addPropTranslate(1,kAnimNormal,waitTime,delay,-lw,0,-10,0);
   local rw,rh = self.m_bamboo_right_dec:getSize();
   self.m_bamboo_right_dec:addPropTranslate(1,kAnimNormal,waitTime,delay,rw,0,-10,0);
end


ReplayScene.pauseAnimStart = function(self,newStateObj,timer)
   local duration = timer.duration;
   local waitTime = timer.waitTime
   local delay = waitTime+duration;

   delete(self.m_anim_end);
   self.m_anim_end = new(AnimInt,kAnimNormal,0,1,delay,-1);
   if self.m_anim_end then
        self.m_anim_end:setEvent(self,function()
            self:removeAnimProp();
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end
            delete(self.m_anim_end);
        end);
   end

   local lw,lh = self.m_bamboo_left_dec:getSize();
   self.m_bamboo_left_dec:addPropTranslate(1,kAnimNormal,waitTime,-1,0,-lw,0,-10);
   local rw,rh = self.m_bamboo_right_dec:getSize();
   local anim = self.m_bamboo_right_dec:addPropTranslate(1,kAnimNormal,waitTime,-1,0,rw,0,-10);
   if anim then
        anim:setEvent(self,function()
            self:setAnimItemEnVisible(false);
        end);
   end
end


ReplayScene.removeAnimProp = function(self)
    self.m_bamboo_right_dec:removeProp(1);
    self.m_bamboo_left_dec:removeProp(1);
end



ReplayScene.setBtnSelected = function(self, isSelected)
    if self.m_cur_state == ReplayScene.REPLAY then
        -- btn_txt颜色
        self.m_recent_btn_txt:setColor(215,75,45);
        self.m_mysave_btn_txt:setColor(120,80,65);
        self.m_suggest_btn_txt:setColor(120,80,65);
        -- line
        self.m_recent_line:setVisible(true);
        self.m_mysave_line:setVisible(false);
        self.m_suggest_line:setVisible(false);
        -- listView
        self.m_replay_content_view:setVisible(true);
        self.m_dapu_content_view:setVisible(false);
        self.m_suggest_content_view:setVisible(false);
        -- clear_btn_bg
        self.m_clear_btn_bg:setVisible(true);
    elseif self.m_cur_state == ReplayScene.MYSAVE then
        -- btn_txt颜色
        self.m_recent_btn_txt:setColor(120,80,65);
        self.m_mysave_btn_txt:setColor(215,75,45);
        self.m_suggest_btn_txt:setColor(120,80,65);
        -- line
        self.m_recent_line:setVisible(false);
        self.m_mysave_line:setVisible(true);
        self.m_suggest_line:setVisible(false);
        -- listView
        self.m_replay_content_view:setVisible(false);
        self.m_dapu_content_view:setVisible(true);
        self.m_suggest_content_view:setVisible(false);
        -- clear_btn_bg
        self.m_clear_btn_bg:setVisible(false);
    elseif self.m_cur_state == ReplayScene.SUGGEST then
        -- btn_txt颜色
        self.m_recent_btn_txt:setColor(120,80,65);
        self.m_mysave_btn_txt:setColor(120,80,65);
        self.m_suggest_btn_txt:setColor(215,75,45);
        -- line
        self.m_recent_line:setVisible(false);
        self.m_mysave_line:setVisible(false);
        self.m_suggest_line:setVisible(true);
        -- listView
        self.m_replay_content_view:setVisible(false);
        self.m_dapu_content_view:setVisible(false);
        self.m_suggest_content_view:setVisible(true);

        -- clear_btn_bg
        self.m_clear_btn_bg:setVisible(false);
    end;
end;


ReplayScene.resetListViewItemClick = function(self, flag)
    if self.m_cur_state == ReplayScene.REPLAY then
        if flag then
            self.m_replayList_view:setOnItemClick(self, function() end);
            self.m_replay_filter_view:setOnItemClick(self,  function() end);
        else
            self.m_replayList_view:setOnItemClick(self, self.onRecentItemClick);
            self.m_replay_filter_view:setOnItemClick(self, self.onSuggestItemClick);
        end;
    elseif self.m_cur_state == ReplayScene.MYSAVE then
        if flag then
            self.m_dapuList_view:setOnItemClick(self, function() end);
            self.m_dapu_filter_view:setOnItemClick(self,  function() end);
        else
            self.m_dapuList_view:setOnItemClick(self, self.onMysaveItemClick);
            self.m_dapu_filter_view:setOnItemClick(self, self.onMysaveItemClick);
        end;        

    elseif self.m_cur_state == ReplayScene.SUGGEST then
        if flag then
            self.m_suggestList_view:setOnItemClick(self, function() end);
            self.m_suggest_filter_view:setOnItemClick(self,  function() end);
        else
            self.m_suggestList_view:setOnItemClick(self, self.onSuggestItemClick);
            self.m_suggest_filter_view:setOnItemClick(self, self.onSuggestItemClick);
        end;    
    end;
end;



-- 显示最近棋局列表加动画
ReplayScene.showRecentList = function(self)
    self.m_cur_state = ReplayScene.REPLAY;
    self:setBtnSelected(true);
    ReplayChessItem.s_room = self;
    ReplayChessItem.s_type = ReplayScene.REPLAY;
    -- 加载数据
    self:showRecentData();
end;



ReplayScene.showMySaveList = function(self)
    self.m_cur_state = ReplayScene.MYSAVE;
    self.m_mysave_list_num = 0;
    self:setBtnSelected(true);
    ReplayChessItem.s_room = self;
    ReplayChessItem.s_type = ReplayScene.MYSAVE;
    -- 加载数据
    self:showMySaveChess(true);
end;

-- 加载棋友推荐
ReplayScene.showSuggestList = function(self)
    self.m_cur_state = ReplayScene.SUGGEST;
    self.m_suggest_list_num = 0;
    self:setBtnSelected(true);
    ReplayChessItem.s_room = self;
    ReplayChessItem.s_type = ReplayScene.SUGGEST;
    -- 加载数据
    self:showSuggestChess();
end;


-- 加载最近对局数据
ReplayScene.showRecentData = function(self)
    local monthArray = ToolKit.getMonthArray(os.time(),ReplayScene.FIRST_CHESS_TIME);
    table.insert(monthArray,1,-1);
    self.m_date_adapter = new(CacheAdapter,MonthItem,monthArray);
    self.m_date_select_list:setAdapter(self.m_date_adapter);
    self.m_date_select_list:setOnItemClick(self,self.onDateListItemClick);

    local data = self:getRecentChess();
    if not data or not next(data) then 
        self.m_recent_tips:setText("0/"..UserInfo.getInstance():getSaveChessManualLimit());
        self.m_replay_empty_tips:setVisible(true);
        return 
    else
        ChessToastManager.getInstance():clearAllToast();
        self.m_recent_tips:setText(#data .."/"..UserInfo.getInstance():getSaveChessManualLimit());
        self.m_replay_empty_tips:setVisible(false);
    end;    
    
    -- 本地棋谱一次性加载完毕，所以不用每次加载
    if not self.m_recent_adapter then
        self.m_recent_adapter = new(CacheAdapter,ReplayChessItem,data);
        self.m_replayList_view:setAdapter(self.m_recent_adapter);
    end;
end;

ReplayScene.onDateListItemClick = function(self, adapter,item,index,viewX,viewY)
    local time = item:getData();
    if self.m_cur_state == ReplayScene.REPLAY then
        self.m_date_select_view:setVisible(false);
        if time == -1 then
            self.m_replay_filter_txt:setText("全部棋局");
            self.m_replayList_view:setVisible(true);
            self.m_replay_filter_view:setVisible(false); 
            self.m_replay_filter_view:removeAllChildren();  
            self.m_replay_empty_tips:setVisible(false);
            self.m_clear_btn_bg:setVisible(true);
            self:resetReplayListView();
        else
            self.m_clear_btn_bg:setVisible(false);
            self.m_replay_cur_month = ToolKit.getOneMonth(time);
            self.m_replay_filter_txt:setText(os.date("%Y/%m",time));
            self.m_replayList_view:setVisible(false);
            self.m_replay_filter_view:setVisible(true);
            self.m_replay_filter_view:removeAllChildren();
            self:resetReplayListViewBytime()
        end;
    elseif self.m_cur_state == ReplayScene.MYSAVE then
        self.m_date_select_view:setVisible(false);
        self.m_dapu_filter_view:removeAllChildren(true);
        delete(self.m_masave_bytime_adapter);
        self.m_masave_bytime_adapter = nil;
        if time == -1 then
            self.m_dapu_filter_txt:setText("全部棋局");
            self.m_dapuList_view:setVisible(true);
            self.m_dapu_filter_view:setVisible(false); 
            self.m_dapu_empty_tips:setVisible(false);
            self.m_mysave_list_num = 0;
            self:getMysaveChess(0,10);
        else
            self.m_dapu_cur_month = ToolKit.getOneMonth(time);
            self.m_dapu_filter_txt:setText(os.date("%Y/%m",time));
            self.m_dapuList_view:setVisible(false);
            self.m_dapu_filter_view:setVisible(true);
            self.m_mysave_bytime_list_num = 0;
            self:getMysaveChessByTime(0,10,self.m_dapu_cur_month[1],self.m_dapu_cur_month[2]);
        end;        
    elseif self.m_cur_state == ReplayScene.SUGGEST then
        self.m_date_select_view:setVisible(false);
        self.m_suggest_filter_view:removeAllChildren(true);
        delete(self.m_suggest_bytime_adapter);
        self.m_suggest_bytime_adapter = nil;
        if time == -1 then
            self.m_suggest_filter_txt:setText("全部棋局");
            self.m_suggestList_view:setVisible(true);
            self.m_suggest_filter_view:setVisible(false); 
            self.m_suggest_empty_tips:setVisible(false);
        else
            self.m_suggest_cur_month = ToolKit.getOneMonth(time);
            self.m_suggest_filter_txt:setText(os.date("%Y/%m",time));
            self.m_suggestList_view:setVisible(false);
            self.m_suggest_filter_view:setVisible(true);
            self.m_suggest_bytime_list_num = 0;
            self:getSuggestChessByTime(0,10,self.m_suggest_cur_month[1],self.m_suggest_cur_month[2]);
        end;  
    end;
end;

-- 最近对局筛选数据
ReplayScene.addReplayFilterData = function(self)
    if not self.m_replay_local_datas or not next(self.m_replay_local_datas) then return end;
    local datas = {};
    if #self.m_replay_local_datas > 10 then
        for i = 1, 10 do
            datas[i] = table.remove(self.m_replay_local_datas,1);
        end;
    else
        for i = 1, #self.m_replay_local_datas do
            datas[i] = table.remove(self.m_replay_local_datas,1);
        end;
    end;
    self.m_replay_filter_adapter:appendData(datas);
end;

ReplayScene.getChessByTime = function(self, startTime, endTime, timeItem)
--    if self.m_cur_state == ReplayScene.REPLAY then
--        local datas = self:getRecentChessByTime(startTime, endTime);
--        for i = 1, #datas do
--            local item = new(ReplayChessItem,datas[i]);
--            timeItem:getContentView():addChild(item);
--        end;
--        timeItem:scrollDown(850);        
--    elseif self.m_cur_state == ReplayScene.MYSAVE then

--    elseif self.m_cur_state == ReplayScene.SUGGEST then

--    end;    
end;

-- 获取本地保存的最近对局
ReplayScene.getRecentChess = function(self)
    local uid = UserInfo.getInstance():getUid();
	local keys = GameCacheData.getInstance():getString(GameCacheData.RECENT_DAPU_KEY .. uid,"");
    local data = {};
	if keys == "" or keys == GameCacheData.NULL then
		return data;
	end
	local keys_table = lua_string_split(keys, GameCacheData.chess_data_key_split);
	local index = 1;
	for key , value in pairs(keys_table) do
		local mvData_str = GameCacheData.getInstance():getString(value .. uid,"");
		if value ~= "" and value ~= GameCacheData.NULL 
				and mvData_str ~= "" and mvData_str ~= GameCacheData.NULL then
            local mvData_json = mvData_str;
			index = index + 1;
			table.insert(data,mvData_json);
		end
	end
    return data;
end;

-- 获取本地棋谱
ReplayScene.getRecentChessByTime = function(self, startTime, endTime)
    local uid = UserInfo.getInstance():getUid();
	local keys = GameCacheData.getInstance():getString(GameCacheData.RECENT_DAPU_KEY .. uid,"");
    local data = {};
	if keys == "" or keys == GameCacheData.NULL then
		return data;
	end
	local keys_table = lua_string_split(keys, GameCacheData.chess_data_key_split);
	for key , value in pairs(keys_table) do
		local mvData_str = GameCacheData.getInstance():getString(value .. uid,"");
		if value ~= "" and value ~= GameCacheData.NULL 
				and mvData_str ~= "" and mvData_str ~= GameCacheData.NULL then
            
            local mvData_json =json.decode(mvData_str);
            if mvData_json and mvData_json.id then
                if tonumber(mvData_json.id) >= tonumber(startTime) and tonumber(mvData_json.id) <= tonumber(endTime) then
                    table.insert(data,json.encode(mvData_json));
                end;
            end;
		end
	end
    return data;
end;

-- 更新最近对战
ReplayScene.updateRecentChess = function(self)
    
    
end;

ReplayScene.deleteListViewItem = function(self,item)
    if self.m_cur_state == ReplayScene.REPLAY then
        self:deleteRecentChessData(item);
        if self.m_replayList_view:getVisible() then
            self:resetReplayListView();
        elseif self.m_replay_filter_view:getVisible() then
            self:resetReplayListViewBytime();
        end;
    elseif self.m_cur_state == ReplayScene.MYSAVE then
        if self.m_dapuList_view:getVisible() then
            self.m_mysave_list_num = 0;
        elseif self.m_dapu_filter_view:getVisible() then
            self.m_mysave_bytime_list_num = 0;
        end;
        self:deleteMysaveChess(item);
    elseif self.m_cur_state == ReplayScene.SUGGEST then
    end;
end;

-- 重置replayListView
ReplayScene.resetReplayListView = function(self)
    if self.m_recent_adapter then
        local data = self:getRecentChess();
        if not next(data) or not data  then 
            self.m_recent_tips:setText("0/"..UserInfo.getInstance():getSaveChessManualLimit());
            self.m_replay_empty_tips:setVisible(true);
            self.m_replayList_view:removeAllChildren(true);
            self.m_replayList_view:setAdapter(nil);
            delete(self.m_recent_adapter);
            self.m_recent_adapter = nil;
            return 
        else
            ChessToastManager.getInstance():clearAllToast();
            self.m_recent_tips:setText(#data .."/"..UserInfo.getInstance():getSaveChessManualLimit());
            self.m_replay_empty_tips:setVisible(false);
        end;  
        self.m_recent_adapter:changeData(data);
    end;
end;


ReplayScene.resetReplayListViewBytime = function(self)
    self.m_replay_local_datas = self:getRecentChessByTime(self.m_replay_cur_month[1],self.m_replay_cur_month[2]);
    if not self.m_replay_local_datas or not next(self.m_replay_local_datas) then 
        self.m_replay_empty_tips:setVisible(true);
        self.m_replay_filter_view:setAdapter(nil);
        return 
    else
        self.m_replay_empty_tips:setVisible(false);
    end;
    local datas = {};
    if #self.m_replay_local_datas > 10 then
        for i = 1, 10 do
            datas[i] = table.remove(self.m_replay_local_datas,1);
        end;
    else
        datas = self.m_replay_local_datas;
    end;
    delete(self.m_replay_filter_adapter);
    self.m_replay_filter_adapter = nil;
    self.m_replay_filter_adapter = new(CacheAdapter,ReplayChessItem,datas);
    self.m_replay_filter_view:setAdapter(self.m_replay_filter_adapter);
    local data = self:getRecentChess();
    if not next(data) or not data  then
    else
        self.m_recent_tips:setText(#data .."/"..UserInfo.getInstance():getSaveChessManualLimit());
    end;
end;


ReplayScene.clearAllRecentData = function(self)
    if not self.m_clear_chioce_dialog then
        self.m_clear_chioce_dialog = new(ChioceDialog);
    end;
    self.m_clear_chioce_dialog:setMode(ChioceDialog.MODE_SURE);
    self.m_clear_chioce_dialog:setMessage("是否清空最近对局中所有棋谱？");
    self.m_clear_chioce_dialog:setPositiveListener(self, function() 
        self:deleteAllRecentChessData();
        self:resetReplayListView();   
    end);
    self.m_clear_chioce_dialog:show();    
end;



ReplayScene.deleteAllRecentChessData = function(self)
    local uid = UserInfo.getInstance():getUid();
	local keys = GameCacheData.getInstance():getString(GameCacheData.RECENT_DAPU_KEY .. uid,"");
	if keys == "" or keys == GameCacheData.NULL then
		return ;
	end
	local keys_table = lua_string_split(keys, GameCacheData.chess_data_key_split);
    for key , value in pairs(keys_table) do
        table.remove(keys_table,key);
        local mvData_str = GameCacheData.getInstance():getString(value .. uid,"");
		if value ~= "" and value ~= GameCacheData.NULL and mvData_str ~= "" and mvData_str ~= GameCacheData.NULL then
            GameCacheData.getInstance():saveString(value .. uid,"");
		end
	end       
    GameCacheData.getInstance():saveString(GameCacheData.RECENT_DAPU_KEY .. uid,""); 
end;



-- 删除最近对战item数据
ReplayScene.deleteRecentChessData = function(self,chessItem)
    local uid = UserInfo.getInstance():getUid();
	local keys = GameCacheData.getInstance():getString(GameCacheData.RECENT_DAPU_KEY .. uid,"");
	if keys == "" or keys == GameCacheData.NULL then
		return ;
	end
	local keys_table = lua_string_split(keys, GameCacheData.chess_data_key_split);
	local index = 1;
	local data = {};
    local deleteId = nil;
    if not chessItem:getData().id then
        return;
    else
        deleteId = "myRecentChessDataId_"..chessItem:getData().id;
    end;
    for key , value in pairs(keys_table) do
        if deleteId == value then
            table.remove(keys_table,key);
            GameCacheData.getInstance():saveString(GameCacheData.RECENT_DAPU_KEY .. uid,table.concat(keys_table,GameCacheData.chess_data_key_split));
        		local mvData_str = GameCacheData.getInstance():getString(value .. uid,"");
		    if value ~= "" and value ~= GameCacheData.NULL and mvData_str ~= "" and mvData_str ~= GameCacheData.NULL then
                GameCacheData.getInstance():saveString(deleteId .. uid,"");
		    end
            return true;
        end;
	end    
end;


ReplayScene.updateRecentChessData = function(self,chessItem)
    local uid = UserInfo.getInstance():getUid();
	local keys = GameCacheData.getInstance():getString(GameCacheData.RECENT_DAPU_KEY .. uid,"");
	if keys == "" or keys == GameCacheData.NULL then
		return ;
	end
	local keys_table = lua_string_split(keys, GameCacheData.chess_data_key_split);
	local data = {};
    local updateId = nil;
    if not chessItem:getData().id then 
        return;
    else
        updateId = "myRecentChessDataId_"..chessItem:getData().id;
    end;
    for key , value in pairs(keys_table) do
        if updateId == value then
		    local mvData_str = GameCacheData.getInstance():getString(value .. uid,"");
		    if value ~= "" and value ~= GameCacheData.NULL and mvData_str ~= "" and mvData_str ~= GameCacheData.NULL then
                GameCacheData.getInstance():saveString(value .. uid,json.encode(chessItem:getData()));
		    end
            return true;
        end;
	end       
end;

-- 最近对局itemClick
ReplayScene.onRecentItemClick = function(self,adapter,view,index,viewX,viewY)
    Log.i("ReplayScene.onRecentItemClick");
    self:entryReplayRoom(view:getData());
end;


-- 最近对局itemClick
ReplayScene.onMysaveItemClick = function(self,adapter,view,index,viewX,viewY)
    Log.i("ReplayScene.onMysaveItemClick");
    self:entryReplayRoom(view:getData());
end;

-- 最近对局itemClick
ReplayScene.onSuggestItemClick = function(self,adapter,view,index,viewX,viewY)
    Log.i("ReplayScene.onSuggestItemClick");
    self:entryReplayRoom(view:getData());
end;





-- 删除我的收藏item
ReplayScene.deleteMysaveChess = function(self,chessItem)
    self:requestCtrlCmd(ReplayController.s_cmds.delete_mysave_chess,chessItem:getManualId());
end;


ReplayScene.showMySaveChess = function(self,showTips)
    if showTips then
        self:loadTips(); 
    end;
    if self.m_dapuList_view:getVisible() then
        self:getMysaveChess(0,10);
    elseif self.m_dapu_filter_view:getVisible() then
        self:getMysaveChessByTime(0,10,self.m_dapu_cur_month[1],self.m_dapu_cur_month[2]);
    end;
end;


ReplayScene.showSuggestChess = function(self)
    self:loadTips();
    self:getSuggestChess(0,5); 
end;




-- 收藏棋谱
ReplayScene.savetoLocal = function(self, chessItem)
    self.m_chess_item = chessItem;
    -- 收藏弹窗
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
end;




-- 收藏到我的收藏
ReplayScene.saveChesstoMysave = function(self,item)
    self.m_chess_item = item;
    self:requestCtrlCmd(ReplayController.s_cmds.save_mychess,item:getChioceDlgCheckState(),item:getData());
end;

-- 获取我的收藏
ReplayScene.getMysaveChess = function(self,start,num)
    self:requestCtrlCmd(ReplayController.s_cmds.get_mysavechess,start, num);
end;

-- 获取指定时间的我的收藏
ReplayScene.getMysaveChessByTime = function(self,start,num, startTime, endTime)
    self:requestCtrlCmd(ReplayController.s_cmds.get_mysavechess,start, num, startTime, endTime);
end;


-- 获取棋友动态
ReplayScene.getSuggestChess = function(self,start,num)
    self:requestCtrlCmd(ReplayController.s_cmds.get_suggestchess,start, num);
end;

-- 获取棋友动态
ReplayScene.getSuggestChessByTime = function(self,start,num,startTime, endTime)
    self:requestCtrlCmd(ReplayController.s_cmds.get_suggestchess,start, num,startTime, endTime);
end;



-- 公开棋谱
ReplayScene.openOrSelfDapu = function(self,chessItem,collectType)
    self.m_chess_item = chessItem;
    self:requestCtrlCmd(ReplayController.s_cmds.open_self_chess,self.m_chess_item:getManualId(),collectType);
end;


-- 进入房间
ReplayScene.entryReplayRoom = function(self,data)
      UserInfo.getInstance():setDapuSelData(data);
      RoomProxy.getInstance():gotoReplayRoom();
end;


ReplayScene.onBackActionBtnClick = function(self)
    self:requestCtrlCmd(ReplayController.s_cmds.back_action);
end;



ReplayScene.galleryCallback = function(self)
    self:getMysaveChess(self.m_dapu_view:getCurrentIndex(),10);
end

-------------------------------- http --------------------------------
ReplayScene.onSaveMychessCallBack = function(self,data)
    if not data then return end;
    if data.cost then
        if data.cost >= 0 then 
            ChessToastManager.getInstance():showSingle("收藏成功！",2000);
            if self.m_chess_item then
                if self.m_chess_item.m_type == ReplayScene.REPLAY then
                    self.m_chess_item:setReplayIsCollect();
                elseif self.m_chess_item.m_type == ReplayScene.MYSAVE then
                    -- 已经收藏了
                elseif self.m_chess_item.m_type == ReplayScene.SUGGEST then
                    self.m_chess_item:setSuggestIsCollect();
                end;
            end;
        elseif data.cost == -1 then
            -- -1是老版本本地棋谱上传成功
        end;
    end;
end;


-- 获取我的收藏成功回调
ReplayScene.onGetMychessCallBack = function(self,data)
    Log.i("ReplayScene.onGetMychessCallBack");
    if not data or not next(data) then 
        self.m_mysave_tips:setText("...");
        self.m_dapu_empty_tips:setVisible(true);
        return 
    else
        ChessToastManager.getInstance():clearAllToast();
        self.m_dapu_total_num = data.total;
        self.m_dapu_empty_tips:setVisible(false);
    end; 

    local dapuData = {};
    if not self.m_mysave_list_num then self.m_mysave_list_num = 0 end
    if data.list then
        self.m_mysave_list_num = self.m_mysave_list_num + #data.list;
    else
        return;
    end;
    for i = 1 ,#data.list do
        table.insert(dapuData,json.encode(data.list[i]));
    end;
    if self.m_mysave_list_num > #data.list then
        if self.m_masave_adapter then
            self.m_masave_adapter:appendData(dapuData);
        end;
    else
        -- 每次需重新加载收藏，有可能新增加收藏
        if not next(dapuData) then 
--            ChessToastManager.getInstance():showSingle("没有收藏记录哦");
            self.m_dapu_empty_tips:setVisible(true);
            self.m_dapuList_view:setAdapter(nil);
            return 
        else
            self.m_dapu_empty_tips:setVisible(false);
        end;
        delete(self.m_masave_adapter);
        self.m_masave_adapter = nil;
        self.m_masave_adapter = new(CacheAdapter,ReplayChessItem,dapuData);
        self.m_dapuList_view:setAdapter(self.m_masave_adapter);
    end;
end;

-- 获取时间段我的收藏
ReplayScene.onGetMychessByTimeCallBack = function(self, data)
    Log.i("ReplayScene.onGetMychessByTimeCallBack");
    if not data or not next(data) then 
        return 
    end; 
    local dapuData = {};
    if not self.m_mysave_bytime_list_num then self.m_mysave_bytime_list_num = 0 end
    if data.list then
        self.m_mysave_bytime_list_num = self.m_mysave_bytime_list_num + #data.list;
    else
        return;
    end;
    for i = 1 ,#data.list do
        table.insert(dapuData,json.encode(data.list[i]));
    end;
    if self.m_mysave_bytime_list_num > #data.list then
        if not next(dapuData) then return end;
        if self.m_masave_bytime_adapter then
            self.m_masave_bytime_adapter:appendData(dapuData);
        else
            self.m_masave_bytime_adapter = new(CacheAdapter,ReplayChessItem,dapuData);
            self.m_dapu_filter_view:setAdapter(self.m_masave_bytime_adapter);
        end;
    else
        -- 每次需重新加载收藏，有可能新增加收藏
        if not next(dapuData) then 
            self.m_dapu_empty_tips:setVisible(true);
            self.m_dapu_filter_view:setAdapter(nil);
            return 
        else
            self.m_dapu_empty_tips:setVisible(false);
        end;
        delete(self.m_masave_bytime_adapter);
        self.m_masave_bytime_adapter = nil;
        self.m_masave_bytime_adapter = new(CacheAdapter,ReplayChessItem,dapuData);
        self.m_dapu_filter_view:setAdapter(self.m_masave_bytime_adapter);
    end;    
end;

-- 获取棋友动态成功回调
ReplayScene.onGetSuggestCallBack = function(self,data)
    Log.i("ReplayScene.onGetSuggestCallBack");
    if not data or not next(data) then 
        self.m_suggest_tips:setText("...");
        self.m_suggest_empty_tips:setVisible(true);
        return 
    else
        ChessToastManager.getInstance():clearAllToast();
        self.m_suggest_total_num = data.total;
        self.m_suggest_empty_tips:setVisible(false);
    end; 

    local suggestData = {};
    if not self.m_suggest_list_num then self.m_suggest_list_num = 0 end
    if data.list then
        self.m_suggest_list_num = self.m_suggest_list_num + #data.list;
    else
        return;
    end;
    for i = 1 ,#data.list do
        table.insert(suggestData,json.encode(data.list[i]));
    end;
    if self.m_suggest_list_num > #data.list then
        if self.m_suggest_adapter then
            self.m_suggest_adapter:appendData(suggestData);
        end;
    else
        -- 每次需重新加载收藏，有可能新增加收藏
        if not next(suggestData) then 
            self.m_suggest_empty_tips:setVisible(true);
            self.m_suggestList_view:setAdapter(nil);
            return 
        else
            self.m_suggest_empty_tips:setVisible(false);
        end;
        delete(self.m_suggest_adapter);
        self.m_suggest_adapter = nil;
        self.m_suggest_adapter = new(CacheAdapter,ReplayChessItem,suggestData);
        self.m_suggestList_view:setAdapter(self.m_suggest_adapter);
    end;
end;

-- 获取时间段棋友推荐
ReplayScene.onGetSuggestByTimeCallBack = function(self, data)
    Log.i("ReplayScene.onGetSuggestByTimeCallBack");
    if not data or not next(data) then 
        return 
    end; 
    local suggestData = {};
    if not self.m_suggest_bytime_list_num then self.m_suggest_bytime_list_num = 0 end
    if data.list then
        self.m_suggest_bytime_list_num = self.m_suggest_bytime_list_num + #data.list;
    else
        return;
    end;
    for i = 1 ,#data.list do
        table.insert(suggestData,json.encode(data.list[i]));
    end;
    if self.m_suggest_bytime_list_num > #data.list then
        if not next(suggestData) then return end;
        if self.m_suggest_bytime_adapter then
            self.m_suggest_bytime_adapter:appendData(suggestData);
        else
            self.m_suggest_bytime_adapter = new(CacheAdapter,ReplayChessItem,suggestData);
            self.m_suggest_filter_view:setAdapter(self.m_suggest_bytime_adapter);
        end;
    else
        if not next(suggestData) then 
            self.m_suggest_empty_tips:setVisible(true);
            return 
        else
            self.m_suggest_empty_tips:setVisible(false);
        end;
        delete(self.m_suggest_bytime_adapter);
        self.m_suggest_bytime_adapter = nil;
        self.m_suggest_bytime_adapter = new(CacheAdapter,ReplayChessItem,suggestData);
        self.m_suggest_filter_view:setAdapter(self.m_suggest_bytime_adapter);
    end;    
end;


-- 公开或私密棋谱回调
ReplayScene.onOpenOrSelfMychessCallBack = function(self, data)
    self.m_chess_item:setOpenOrSelfType();
end;


-- 删除我的收藏回调
ReplayScene.onDelMychessCallBack = function(self)
    ChessToastManager.getInstance():showSingle("删除成功！",2000);
    self:showMySaveChess(false);
end;

require("dialog/common_share_dialog");
--[Comment]
--分享棋谱
--data: 复盘数据
function ReplayScene.shareChess(self,data)
    if not data then return end
    if not self.commonShareDialog then
        self.commonShareDialog = new(CommonShareDialog);
    end
    self.commonShareDialog:setShareDate(data,"manual_share");
    self.commonShareDialog:show();

end

ReplayScene.dateFilterShow = function(self)
    self.m_date_select_view:setVisible(true);
    EffectAnim.getInstance():fadeInAndOut(self.m_date_select_bg,nil,200);
    EffectAnim.getInstance():fadeInAndOut(self.m_date_bg,nil,200);
    EffectAnim.getInstance():scaleBigAndSmall(self.m_date_bg,nil,200,135,0);
end;

ReplayScene.dateFilterHide = function(self,finger_action,x,y,drawing_id_first,drawing_id_current, event_time)
    if finger_action ~= kFingerDown then
        EffectAnim.getInstance():fadeInAndOut(nil,self.m_date_select_bg,200);
        EffectAnim.getInstance():fadeInAndOut(nil,self.m_date_bg,200);
        EffectAnim.getInstance():scaleBigAndSmall(nil,self.m_date_bg,200,135,0,function()self.m_date_select_view:setVisible(false); end);
    end;
end;

ReplayScene.onReplayFilterBtn = function(self)
    self:dateFilterShow();
end;

ReplayScene.onDapuFilterBtn = function(self)
    self:dateFilterShow();
end;

ReplayScene.onSuggestFilterBtn = function(self)
    self:dateFilterShow();
end;
---------------------------------config-------------------------------
ReplayScene.s_controlConfig = 
{
    [ReplayScene.s_controls.bamboo_left_dec]            = {"bamboo_left_dec"};
    [ReplayScene.s_controls.bamboo_right_dec]           = {"bamboo_right_dec"};
    [ReplayScene.s_controls.tea_dec]                    = {"tea_dec"};
    [ReplayScene.s_controls.stone_dec]                  = {"stone_dec"};
	[ReplayScene.s_controls.back_btn]                   = {"back_btn"};
    [ReplayScene.s_controls.title_view]                 = {"title_content"};
    [ReplayScene.s_controls.title_bg]                   = {"title_content","title_bg"};
    [ReplayScene.s_controls.title_subbg]                = {"title_content","title_subbg"};
    [ReplayScene.s_controls.title_mysave]               = {"title_content","title_mysave"};
    [ReplayScene.s_controls.clear_all_btn_bg]           = {"title_content","clear_all_bg"};
    [ReplayScene.s_controls.clear_all_btn]              = {"title_content","clear_all_bg","clear_all_btn"};
    [ReplayScene.s_controls.btns_content_view]          = {"btns_content"};

    [ReplayScene.s_controls.replay_content_view]        = {"replay_content"};
    [ReplayScene.s_controls.replayList_view]            = {"replay_content","replayList_view"};
    [ReplayScene.s_controls.dapu_content_view]          = {"dapu_content"};
    [ReplayScene.s_controls.dapuList_view]              = {"dapu_content","dapuList_view"};
    [ReplayScene.s_controls.suggest_content_view]       = {"suggest_content"};
    [ReplayScene.s_controls.suggestList_view]           = {"suggest_content","suggestList_view"};
    [ReplayScene.s_controls.bottom_view]                = {"bottom_view"};
    [ReplayScene.s_controls.date_select_view]           = {"date_select_view"};
   
};

--定义控件的触摸响应函数
ReplayScene.s_controlFuncMap =
{
	[ReplayScene.s_controls.back_btn]                   = ReplayScene.onBackActionBtnClick;
};

ReplayScene.s_cmdConfig = 
{
    [ReplayScene.s_cmds.save_mychess]                   = ReplayScene.onSaveMychessCallBack;
    [ReplayScene.s_cmds.get_mychess]                    = ReplayScene.onGetMychessCallBack;
    [ReplayScene.s_cmds.get_suggestchess]               = ReplayScene.onGetSuggestCallBack;
    [ReplayScene.s_cmds.open_self_chess]                = ReplayScene.onOpenOrSelfMychessCallBack;
    [ReplayScene.s_cmds.del_mysave_chess]               = ReplayScene.onDelMychessCallBack;
    [ReplayScene.s_cmds.get_mychess_bytime]             = ReplayScene.onGetMychessByTimeCallBack;
    [ReplayScene.s_cmds.get_suggest_bytime]             = ReplayScene.onGetSuggestByTimeCallBack;
}

-------------------------- UI ----------------------------
-- MonthItem
MonthItem = class(Node)

MonthItem.ctor = function(self,date)
    if not date then return end;
    self.m_data = date;
    if self.m_data == -1 then
        self.m_date = new(Text,"全部棋局",150,50,kAlignCenter,nil,25,80,80,80);
    else
        self.m_date = new(Text,self:getMonth(self.m_data),150,50,kAlignCenter,nil,28,80,80,80);
    end;
    self.m_date:setAlign(kAlignCenter);
    self:addChild(self.m_date);
    self.m_bottom_line = new(Image,"common/decoration/line_2.png");
    self.m_bottom_line:setSize(155,3);
    self.m_bottom_line:setAlign(kAlignBottom);
    self:addChild(self.m_bottom_line);
    self:setSize(160,50);
end;

MonthItem.dtor = function(self)

end;

MonthItem.getMonth = function(self,time)
   return os.date("%Y/%m",time);
end;

MonthItem.getData = function(self)
    return self.m_data;
end;


-----------------------------------------------------------

-- ReplayScrollItem
ReplayScrollItem = class(Node)

ReplayScrollItem.ctor = function(self, date, room)
    if not date or not next(date) then return end;
    self.m_room = room;
    self.m_start_time = date[1];
    self.m_end_time = date[2];
    self:initView(date[3]);
end;

ReplayScrollItem.dtor = function(self)
    
end;

ReplayScrollItem.initView = function(self,time)
    self.m_root_view = SceneLoader.load(replay_scroll_node);
    self.m_root_view:setAlign(kAlignTopLeft);
    self:addChild(self.m_root_view);
    self.m_title_view = self.m_root_view:getChildByName("title");
    self.m_content_view = self.m_root_view:getChildByName("conent_scroll_view");
    self.m_content_view.m_autoPositionChildren = true;
    self.m_line = self.m_title_view:getChildByName("line");
    self.m_time_bg = self.m_title_view:getChildByName("time_bg");
    self.m_time = self.m_time_bg:getChildByName("weekend_time");
    self.m_time:setText(time);
    self.m_down_up_btn = self.m_time_bg:getChildByName("down_up_btn");
    self.m_down_up_btn:setOnClick(self,self.down_up_btn_click);
    self.m_defaultW, self.m_defaultH = self.m_title_view:getSize();
    self:setSize(self.m_title_view:getSize());
end;

ReplayScrollItem.down_up_btn_click = function(self)
    self.m_room:getChessByTime(self.m_start_time, self.m_end_time,self);
end;

ReplayScrollItem.scrollDown = function(self, toScaleH)
    local w, h = self.m_title_view:getSize();
    if not self.m_is_down_click then
        self.m_is_down_click = true;
        self:downAnim(toScaleH);
        self.m_down_up_btn:setFile("common/icon/up_icon.png");
    else
        self.m_is_down_click = false;
        self:upAnim(h);
        self.m_down_up_btn:setFile("common/icon/launch_icon.png");
    end;    
end;

ReplayScrollItem.getLastTime = function(self)
    return self.m_start_time;
end;

ReplayScrollItem.getContentView = function(self)
    return self.m_content_view;
end;


ReplayScrollItem.downAnim = function(self, h)
    local anim = new(AnimInt, kAnimRepeat, 0,1,10,0);
    if not anim then return end;
    local step = 50;
    anim:setEvent(self, function(a,b,c,repeat_or_loop_num)
        local curW, curH = self:getSize();
        self:setSize(curW,curH + step);
        self:setClip(0,0,curW,curH + step);
        if curH + step >= h then
            self:setSize(curW, h);
            delete(anim);
            anim = nil;
        end;
        self:getParent():getParent():updateScrollView();
    end);
end;

ReplayScrollItem.upAnim = function(self, h)
    local anim = new(AnimInt, kAnimRepeat, 0,1,5,0);
    if not anim then return end;
    local step = 20;
    anim:setEvent(self, function(a,b,c,repeat_or_loop_num)
        local curW, curH = self:getSize();
        self:setSize(curW,curH - step);
        if curH - step <= h then
            self:setSize(self.m_defaultW, self.m_defaultH);
            delete(anim);
            anim = nil;
        end;
        self:getParent():getParent():updateScrollView();
    end);
end;
