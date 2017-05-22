
require(BASE_PATH.."chessDialogScene")
require(VIEW_PATH .. "replay_dialog_view");
require("view/selectButton_nobg");
require("dialog/progress_dialog");
require("dialog/create_room_dialog");
require("animation/TranslateShakeAnim");
require("ui/gallery");
require(VIEW_PATH .."replay_scene_node");
require("dialog/common_help_dialog");
require(VIEW_PATH .."replay_scroll_node");
require(MODEL_PATH .. "replay/replayChessItem")

ReplayDialog = class(ChessDialogScene,false);

ReplayDialog.REPLAY  = 1;-- 最近对局
ReplayDialog.MYSAVE  = 2;-- 我的收藏
ReplayDialog.SUGGEST = 3;-- 棋友动态(推荐)
ReplayDialog.FIRST_CHESS_TIME = 1448899200; -- 2015/12/01 0:0:0(php后台所能查到最早棋谱id时间)
ReplayDialog.ENABLE_IMAGE = "common/button/table_chose_5.png";
ReplayDialog.DISABLE_IMAGE = "common/button/table_nor_5.png";

ReplayDialog.ctor = function(self,room)
    super(self,replay_dialog_view);
    self.anim_dlg = AnimDialogFactory.createNormalAnim(self)
    self.m_room = room;
    self.m_cur_state = ReplayDialog.REPLAY;
    self:initView();
end 

ReplayDialog.show = function(self)
    self:setVisible(true);
    self.super.show(self,self.anim_dlg.showAnim);
end

ReplayDialog.dismiss = function(self)
    self:setVisible(false);
    self.super.dismiss(self,self.anim_dlg.dismissAnim);
end;

ReplayDialog.dtor = function(self)
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onEventResponse);
    self.anim_dlg:stopAnim()
end 

------------------------------function------------------------------
ReplayDialog.initView = function(self)
    --title
    self.m_title_content_view = self.m_root:getChildByName("title_content");
    self.m_title_view = self.m_title_content_view:getChildByName("title");
    self.m_clear_all_btn = self.m_title_view:getChildByName("del");
    self.m_clear_all_btn:setOnClick(self,self.clearAllRecentData);

    -- btns_content
    self.m_btns_content_view = self.m_root:getChildByName("btns_content");
        
       self.m_recent_btn = self.m_btns_content_view:getChildByName("replay_btn"):getChildByName("btn");
       self.m_recent_btn:setOnClick(self, self.showRecentList);
       self.m_recent_btn_txt = self.m_recent_btn:getChildByName("btn_txt");
       self.m_recent_btn_txt:setText("最近对局");
       self.m_recent_btn_txt:setColor(95,15,15);

       self.m_mysave_btn = self.m_btns_content_view:getChildByName("dapu_btn"):getChildByName("btn");
       self.m_mysave_btn:setOnClick(self, self.showMySaveList);
       self.m_mysave_btn_txt = self.m_mysave_btn:getChildByName("btn_txt");
       self.m_mysave_btn_txt:setText("我的收藏");
       self.m_mysave_btn_txt:setColor(230,185,140);
       self.m_mysave_tips = self.m_btns_content_view:getChildByName("dapu_btn"):getChildByName("tips");
       self.m_mysave_line = self.m_btns_content_view:getChildByName("dapu_btn"):getChildByName("select_line");

       self.m_suggest_btn = self.m_btns_content_view:getChildByName("suggest_btn"):getChildByName("btn");
       self.m_suggest_btn:setOnClick(self, self.showSuggestList);
       self.m_suggest_btn_txt = self.m_suggest_btn:getChildByName("btn_txt");
       self.m_suggest_btn_txt:setText("棋友推荐");
       self.m_suggest_btn_txt:setColor(230,185,140);
       self.m_suggest_tips = self.m_btns_content_view:getChildByName("suggest_btn"):getChildByName("tips");
       self.m_suggest_line = self.m_btns_content_view:getChildByName("suggest_btn"):getChildByName("select_line");

    -- content
        self.m_replay_content_view = self.m_root:getChildByName("replay_content");
            -- 最近对战
            self.m_replay_filter_content = self.m_replay_content_view:getChildByName("filter_content");
            self.m_replay_filter_btn = self.m_replay_filter_content:getChildByName("filter_view"):getChildByName("date_btn");
            self.m_replay_filter_btn:setOnClick(self,self.onReplayFilterBtn);
            self.m_recent_tips = self.m_replay_filter_content:getChildByName("tips");

            self.m_replay_filter_txt = self.m_replay_filter_btn:getChildByName("date_txt");
            self.m_replay_filter_view = self.m_replay_content_view:getChildByName("replay_filter_view");
            self.m_replay_filter_view:setOnScroll(self,self.onReplayScrollLVScroll);
            self.m_replay_filter_view:setVisible(false);

            self.m_replayList_view = self.m_replay_content_view:getChildByName("replayList_view");
            self.m_replay_empty_tips =  self.m_replay_content_view:getChildByName("enpty_tips");
            self.m_replay_filter_empty_tips =  self.m_replay_content_view:getChildByName("filter_empty_tips");
        self.m_dapu_content_view  = self.m_root:getChildByName("dapu_content");
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
        self.m_suggest_content_view  = self.m_root:getChildByName("suggest_content");
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
    self.m_bottom_view = self.m_root:getChildByName("bottom_view");
        self.m_back_btn = self.m_bottom_view:getChildByName("back_btn")
        self.m_back_btn:setOnClick(self,self.dismiss);
    -- help_btn
--    self.m_help_btn = self.m_root:getChildByName("help_btn");
--    self.m_help_btn:setOnClick(self,self.showHelpInfo);

    -- date_list
    self.m_date_select_view = self.m_root:getChildByName("date_select_view");
        self.m_date_select_bg = self.m_date_select_view:getChildByName("select_bg");
        self.m_date_select_bg:setTransparency(0.3);
        self.m_date_select_bg:setEventTouch(self, self.dateFilterHide);
        self.m_date_bg = self.m_date_select_view:getChildByName("date_bg");
        self.m_date_select_list = self.m_date_select_view:getChildByName("date_bg"):getChildByName("date_list");
    -- http_event
    EventDispatcher.getInstance():register(Event.Call,self,self.onEventResponse);
    -- show_recent    
--    delete(self.m_init_anim);
--    self.m_init_anim = new(AnimInt,kAnimNormal,0,1,1,1000); 
--    if not self.m_init_anim then return end;
--    self.m_init_anim:setEvent(self,function() 
        self:showRecentList();
--    end);
end;

ReplayDialog.showHelpInfo = function(self)
    if not self.m_help_dialog then
        self.m_help_dialog = new(CommonHelpDialog)
        self.m_help_dialog:setMode(CommonHelpDialog.replay_mode)
    end 
    self.m_help_dialog:show()
end;

-- 最近对局筛选view
ReplayDialog.onReplayScrollLVScroll = function(self,scroll_status,diff, totalOffset)
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
ReplayDialog.onDapuScrollLVScroll = function(self,scroll_status,diff, totalOffset)
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
ReplayDialog.onSuggestScrollLVScroll = function(self,scroll_status,diff, totalOffset)
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

ReplayDialog.onDapuLVScroll = function(self,scroll_status,diff, totalOffset)
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

ReplayDialog.onSuggestLVScroll = function(self,scroll_status,diff, totalOffset)
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
ReplayDialog.loadTips = function(self)
    ChessToastManager.getInstance():showSingle("正在加载数据",1000);
end

ReplayDialog.setAnimItemEnVisible = function(self,ret)
    self.m_bamboo_left_dec:setVisible(ret);
    self.m_bamboo_right_dec:setVisible(ret);
end

ReplayDialog.resumeAnimStart = function(self,lastStateObj,timer,func)
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

ReplayDialog.pauseAnimStart = function(self,newStateObj,timer)
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

ReplayDialog.removeAnimProp = function(self)
    self.m_bamboo_right_dec:removeProp(1);
    self.m_bamboo_left_dec:removeProp(1);
end

ReplayDialog.setBtnSelected = function(self, isSelected)
    if self.m_cur_state == ReplayDialog.REPLAY then
        -- btn_txt颜色
        self.m_recent_btn_txt:setColor(95,15,15);
        self.m_mysave_btn_txt:setColor(230,185,140);
        self.m_suggest_btn_txt:setColor(230,185,140);
        -- btn_select
        self.m_recent_btn:setFile(ReplayDialog.ENABLE_IMAGE);
        self.m_mysave_btn:setFile(ReplayDialog.DISABLE_IMAGE);
        self.m_suggest_btn:setFile(ReplayDialog.DISABLE_IMAGE);
        -- listView
        self.m_replay_content_view:setVisible(true);
        self.m_dapu_content_view:setVisible(false);
        self.m_suggest_content_view:setVisible(false);
        -- clear_btn
        self.m_clear_all_btn:setVisible(true);
    elseif self.m_cur_state == ReplayDialog.MYSAVE then
        -- btn_txt颜色
        self.m_recent_btn_txt:setColor(230,185,140);
        self.m_mysave_btn_txt:setColor(95,15,15);
        self.m_suggest_btn_txt:setColor(230,185,140);
        -- btn_select
        self.m_recent_btn:setFile(ReplayDialog.DISABLE_IMAGE);
        self.m_mysave_btn:setFile(ReplayDialog.ENABLE_IMAGE);
        self.m_suggest_btn:setFile(ReplayDialog.DISABLE_IMAGE);
        -- listView
        self.m_replay_content_view:setVisible(false);
        self.m_dapu_content_view:setVisible(true);
        self.m_suggest_content_view:setVisible(false);
        -- clear_btn
        self.m_clear_all_btn:setVisible(false);
    elseif self.m_cur_state == ReplayDialog.SUGGEST then
        -- btn_txt颜色
        self.m_recent_btn_txt:setColor(230,185,140);
        self.m_mysave_btn_txt:setColor(230,185,140);
        self.m_suggest_btn_txt:setColor(95,15,15);
        -- btn_select
        self.m_recent_btn:setFile(ReplayDialog.DISABLE_IMAGE);
        self.m_mysave_btn:setFile(ReplayDialog.DISABLE_IMAGE);
        self.m_suggest_btn:setFile(ReplayDialog.ENABLE_IMAGE);
        -- listView
        self.m_replay_content_view:setVisible(false);
        self.m_dapu_content_view:setVisible(false);
        self.m_suggest_content_view:setVisible(true);

        -- clear_btn
        self.m_clear_all_btn:setVisible(false);
    end;
end;

ReplayDialog.resetListViewItemClick = function(self, flag)
    if self.m_cur_state == ReplayDialog.REPLAY then
        if flag then
            self.m_replayList_view:setOnItemClick(self, function() end);
            self.m_replay_filter_view:setOnItemClick(self,  function() end);
        else
            self.m_replayList_view:setOnItemClick(self, self.onRecentItemClick);
            self.m_replay_filter_view:setOnItemClick(self, self.onSuggestItemClick);
        end;
    elseif self.m_cur_state == ReplayDialog.MYSAVE then
        if flag then
            self.m_dapuList_view:setOnItemClick(self, function() end);
            self.m_dapu_filter_view:setOnItemClick(self,  function() end);
        else
            self.m_dapuList_view:setOnItemClick(self, self.onMysaveItemClick);
            self.m_dapu_filter_view:setOnItemClick(self, self.onMysaveItemClick);
        end;        

    elseif self.m_cur_state == ReplayDialog.SUGGEST then
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
ReplayDialog.showRecentList = function(self)
    self.m_cur_state = ReplayDialog.REPLAY;
    self:setBtnSelected(true);
    ReplayChessItem.s_room = self;
    ReplayChessItem.s_type = ReplayDialog.REPLAY;
    -- 加载数据
    self:showRecentData();
end;

ReplayDialog.showMySaveList = function(self)
    self.m_cur_state = ReplayDialog.MYSAVE;
    self.m_mysave_list_num = 0;
    self:setBtnSelected(true);
    ReplayChessItem.s_room = self;
    ReplayChessItem.s_type = ReplayDialog.MYSAVE;
    -- 加载数据
    self:showMySaveChess(true);
end;

-- 加载棋友推荐
ReplayDialog.showSuggestList = function(self)
    if UserInfo.getInstance():isFreezeUser() then return end;
    self.m_cur_state = ReplayDialog.SUGGEST;
    self.m_suggest_list_num = 0;
    self:setBtnSelected(true);
    ReplayChessItem.s_room = self;
    ReplayChessItem.s_type = ReplayDialog.SUGGEST;
    -- 加载数据
    self:showSuggestChess(true);
end;


-- 加载最近对局数据
ReplayDialog.showRecentData = function(self)
    local monthArray = ToolKit.getMonthArray(os.time(),ReplayDialog.FIRST_CHESS_TIME);
    table.insert(monthArray,1,-1);
    self.m_date_adapter = new(CacheAdapter,MonthItem,monthArray);
    self.m_date_select_list:setAdapter(self.m_date_adapter);
    self.m_date_select_list:setOnItemClick(self,self.onDateListItemClick);

    local data = self:getRecentChess();
    if not data or not next(data) then 
        self.m_recent_tips:setText("0");
        self.m_replay_empty_tips:setVisible(true);
        return 
    else
        ChessToastManager.getInstance():clearAllToast();
        self.m_recent_tips:setText(#data);
        self.m_replay_empty_tips:setVisible(false);
    end;    
    
    -- 本地棋谱一次性加载完毕，所以不用每次加载
    if not self.m_recent_adapter then
        self.m_recent_adapter = new(CacheAdapter,ReplayChessItem,data);
        self.m_replayList_view:setAdapter(self.m_recent_adapter);
    end;
end;

ReplayDialog.onDateListItemClick = function(self, adapter,item,index,viewX,viewY)
    local time = item:getData();
    if self.m_cur_state == ReplayDialog.REPLAY then
        self.m_date_select_view:setVisible(false);
        if time == -1 then
            self.m_replay_filter_txt:setText("全部棋局");
            self.m_replayList_view:setVisible(true);
            self.m_replay_filter_view:setVisible(false); 
            self.m_replay_filter_view:removeAllChildren();  
            self.m_replay_empty_tips:setVisible(false);
            self:resetReplayListView();
        else
            self.m_replay_cur_month = ToolKit.getOneMonth(time);
            self.m_replay_filter_txt:setText(os.date("%Y/%m",time));
            self.m_replayList_view:setVisible(false);
            self.m_replay_filter_view:setVisible(true);
            self.m_replay_filter_view:removeAllChildren();
            self:resetReplayListViewBytime()
        end;
    elseif self.m_cur_state == ReplayDialog.MYSAVE then
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
    elseif self.m_cur_state == ReplayDialog.SUGGEST then
        self.m_date_select_view:setVisible(false);
        self.m_suggest_filter_view:removeAllChildren(true);
        delete(self.m_suggest_bytime_adapter);
        self.m_suggest_bytime_adapter = nil;
        if time == -1 then
            self.m_suggest_filter_txt:setText("全部棋局");
            self.m_suggestList_view:setVisible(true);
            self.m_suggest_filter_view:setVisible(false); 
            self.m_suggest_empty_tips:setVisible(false);
            self.m_suggest_list_num = 0;
            self:getSuggestChess(0,10);
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
ReplayDialog.addReplayFilterData = function(self)
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

ReplayDialog.getChessByTime = function(self, startTime, endTime, timeItem)
--    if self.m_cur_state == ReplayDialog.REPLAY then
--        local datas = self:getRecentChessByTime(startTime, endTime);
--        for i = 1, #datas do
--            local item = new(ReplayChessItem,datas[i]);
--            timeItem:getContentView():addChild(item);
--        end;
--        timeItem:scrollDown(850);        
--    elseif self.m_cur_state == ReplayDialog.MYSAVE then

--    elseif self.m_cur_state == ReplayDialog.SUGGEST then

--    end;    
end;

-- 获取本地保存的最近对局
ReplayDialog.getRecentChess = function(self)
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
ReplayDialog.getRecentChessByTime = function(self, startTime, endTime)
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
ReplayDialog.updateRecentChess = function(self)
    
    
end;

ReplayDialog.deleteListViewItem = function(self,item)
    if self.m_cur_state == ReplayDialog.REPLAY then
        self:deleteRecentChessData(item);
        if self.m_replayList_view:getVisible() then
            self:resetReplayListView();
        elseif self.m_replay_filter_view:getVisible() then
            self:resetReplayListViewBytime();
        end;
    elseif self.m_cur_state == ReplayDialog.MYSAVE then
        if self.m_dapuList_view:getVisible() then
            self.m_mysave_list_num = 0;
        elseif self.m_dapu_filter_view:getVisible() then
            self.m_mysave_bytime_list_num = 0;
        end;
        self:deleteMysaveChess(item);
    elseif self.m_cur_state == ReplayDialog.SUGGEST then
        if self.m_suggestList_view:getVisible() then
            self.m_suggest_list_num = 0;
        elseif self.m_suggest_filter_view:getVisible() then
            self.m_suggest_bytime_list_num = 0;
        end;
        self:deleteMysaveChess(item);
    end;
end;

-- 重置replayListView
ReplayDialog.resetReplayListView = function(self)
    if self.m_recent_adapter then
        local data = self:getRecentChess();
        if not next(data) or not data  then 
            self.m_recent_tips:setText("0");
            self.m_replay_empty_tips:setVisible(true);
            self.m_replayList_view:removeAllChildren(true);
            self.m_replayList_view:setAdapter(nil);
            delete(self.m_recent_adapter);
            self.m_recent_adapter = nil;
            return 
        else
            ChessToastManager.getInstance():clearAllToast();
            self.m_recent_tips:setText(#data);
            self.m_replay_empty_tips:setVisible(false);
        end;  
        self.m_recent_adapter:changeData(data);
    end;
end;

ReplayDialog.resetReplayListViewBytime = function(self)
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
        self.m_recent_tips:setText(#data);
    end;
end;


ReplayDialog.clearAllRecentData = function(self)
    if not self.m_clear_chioce_dialog then
        self.m_clear_chioce_dialog = new(ChioceDialog);
        self.m_clear_chioce_dialog:setMaskDialog(true)
        self.m_clear_chioce_dialog:setNeedMask(false)
    end;
    self.m_clear_chioce_dialog:setMode(ChioceDialog.MODE_SURE);
    self.m_clear_chioce_dialog:setMessage("是否清空最近对局中所有棋谱？");
    self.m_clear_chioce_dialog:setPositiveListener(self, function() 
        self:deleteAllRecentChessData();  
        if self.m_replayList_view:getVisible() then
            self:resetReplayListView();
        elseif self.m_replay_filter_view:getVisible() then
            self:resetReplayListViewBytime();
        end;
    end);
    self.m_clear_chioce_dialog:show();    
end;



ReplayDialog.deleteAllRecentChessData = function(self)
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
ReplayDialog.deleteRecentChessData = function(self,chessItem)
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


ReplayDialog.updateRecentChessData = function(self,chessItem)
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
ReplayDialog.onRecentItemClick = function(self,adapter,view,index,viewX,viewY)
    Log.i("ReplayDialog.onRecentItemClick");
    self:entryReplayRoom(view:getData());
end;


-- 最近对局itemClick
ReplayDialog.onMysaveItemClick = function(self,adapter,view,index,viewX,viewY)
    Log.i("ReplayDialog.onMysaveItemClick");
    self:entryReplayRoom(view:getData());
end;

-- 最近对局itemClick
ReplayDialog.onSuggestItemClick = function(self,adapter,view,index,viewX,viewY)
    Log.i("ReplayDialog.onSuggestItemClick");
    self:entryReplayRoom(view:getData());
end;

-- 删除我的收藏item
ReplayDialog.deleteMysaveChess = function(self,chessItem)
    self:sendDelMysaveChessRequest(chessItem:getManualId());
end;

-- 删除我的收藏
ReplayDialog.sendDelMysaveChessRequest = function(self, manualId)
    local post_data = {};
    post_data.mid = UserInfo.getInstance():getUid();
    post_data.manual_id = manualId;
    HttpModule.getInstance():execute(HttpModule.s_cmds.delMySaveChess,post_data);  
end;

ReplayDialog.showMySaveChess = function(self,showTips)
    if showTips then
        self:loadTips(); 
    end;
    if self.m_dapuList_view:getVisible() then
        self:getMysaveChess(0,10);
    elseif self.m_dapu_filter_view:getVisible() then
        self:getMysaveChessByTime(0,10,self.m_dapu_cur_month[1],self.m_dapu_cur_month[2]);
    end;
end;

ReplayDialog.showSuggestChess = function(self,showTips)
    if showTips then
        self:loadTips(); 
    end;
    if self.m_suggestList_view:getVisible() then
        self:getSuggestChess(0,10);
    elseif self.m_suggest_filter_view:getVisible() then
        self:getSuggestChessByTime(0,10,self.m_suggest_cur_month[1],self.m_suggest_cur_month[2]);
    end;
end;

-- 收藏棋谱
ReplayDialog.savetoLocal = function(self, chessItem)
    self.m_chess_item = chessItem;
    -- 收藏弹窗
    if not self.m_chioce_dialog then
        self.m_chioce_dialog = new(ChioceDialog)
        self.m_chioce_dialog:setMaskDialog(true)
        self.m_chioce_dialog:setNeedMask(false)
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
ReplayDialog.saveChesstoMysave = function(self,item)
    self.m_chess_item = item;
    self:sendSaveMychessRequest(item:getChioceDlgCheckState(),item:getData());
end;

ReplayDialog.sendSaveMychessRequest = function(self,isSelf, chessData)
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
    post_data.collect_type = (isSelf and 2) or 1; -- 收藏类型, 1公共收藏，2人个收藏 
    post_data.is_old = chessData.is_old or 0;
    HttpModule.getInstance():execute(HttpModule.s_cmds.saveMychess,post_data);   
end;

-- 获取我的收藏
ReplayDialog.getMysaveChess = function(self,start,num)
    self:sendGetMysaveRequest(start, num);
end;

-- 获取指定时间的我的收藏
ReplayDialog.getMysaveChessByTime = function(self,start,num, startTime, endTime)
    self:sendGetMysaveRequest(start, num, startTime, endTime);
end;

ReplayDialog.sendGetMysaveRequest = function(self,start,num, startTime, endTime)
    local post_data = {};
    post_data.mid = UserInfo.getInstance():getUid();
    if startTime and endTime then
        post_data.start_time = startTime;
        post_data.end_time = endTime;
        self.m_mysave_chess_bytime = true;
    else
        self.m_mysave_chess_bytime = false;
    end;
    post_data.offset = start;
    post_data.limit = num;
    HttpModule.getInstance():execute(HttpModule.s_cmds.getMychess,post_data);    
end;

-- 获取棋友动态
ReplayDialog.getSuggestChess = function(self,start,num)
    self:sendGetFriendSuggestRequest(start, num);
end;

-- 获取棋友动态
ReplayDialog.getSuggestChessByTime = function(self,start,num,startTime, endTime)
    self:sendGetFriendSuggestRequest(start, num,startTime, endTime);
end;

ReplayDialog.sendGetFriendSuggestRequest = function(self,start,num, startTime, endTime)
    local post_data = {};
    post_data.mid = UserInfo.getInstance():getUid();
    if startTime and endTime then
        post_data.start_time = startTime;
        post_data.end_time = endTime;
        self.m_suggest_chess_bytime = true;
    else
        self.m_suggest_chess_bytime = false;
    end;
    post_data.offset = start;
    post_data.limit = num;
    HttpModule.getInstance():execute(HttpModule.s_cmds.getCircleDynamics,post_data); 
end;

-- 公开棋谱
ReplayDialog.openOrSelfDapu = function(self,chessItem,collectType)
    self.m_chess_item = chessItem;
    self:sendOpenOrSelfSaveChess(self.m_chess_item:getManualId(),collectType);
end;

-- 公开或私密棋谱
ReplayDialog.sendOpenOrSelfSaveChess = function(self, manualId, collectType)
    local post_data = {};
    post_data.mid = UserInfo.getInstance():getUid();
    post_data.manual_id = manualId;
    post_data.collect_type = collectType;
    HttpModule.getInstance():execute(HttpModule.s_cmds.openOrSelfChess,post_data); 
end;

ReplayDialog.getChessManualId = function(self, chessItem)
    self.m_chess_item = chessItem;
    local chessData = chessItem:getData();
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
    post_data.collect_type = 1; 
    HttpModule.getInstance():execute2(HttpModule.s_cmds.GetChessManualId,post_data,
    function(isSuccess,resultStr) 
         if isSuccess then
            local jsonData = json.decode(resultStr)
            local errorMsg = jsonData.error
            if errorMsg then
                ChessToastManager.getInstance():showSingle(errorMsg or "获得数据失败，请稍后再试") 
                return
            end
            local data = jsonData.data
            if not data or type(data) ~= "table" then return end
            chessItem:setManualId(data.manual_id);
            chessItem:shareChess();
        end       
    end); 
end;

-- 进入房间
ReplayDialog.entryReplayRoom = function(self,data)
      UserInfo.getInstance():setDapuSelData(data);
      RoomProxy.getInstance():gotoReplayRoom();
end;

ReplayDialog.galleryCallback = function(self)
    self:getMysaveChess(self.m_dapu_view:getCurrentIndex(),10);
end

-------------------------------- http --------------------------------
ReplayDialog.onSaveMychessCallBack = function(self,data)
    if not data then return end;
    if data.cost then
        if data.cost >= 0 then 
            ChessToastManager.getInstance():showSingle("收藏成功！",2000);
            if self.m_chess_item then
                if self.m_chess_item.m_type == ReplayDialog.REPLAY then
                    self.m_chess_item:setReplayIsCollect();
                elseif self.m_chess_item.m_type == ReplayDialog.MYSAVE then
                    -- 已经收藏了
                elseif self.m_chess_item.m_type == ReplayDialog.SUGGEST then
                    self.m_chess_item:setSuggestIsCollect();
                end;
            end;
        elseif data.cost == -1 then
            -- -1是老版本本地棋谱上传成功
        end;
    end;
end;


-- 获取我的收藏成功回调
ReplayDialog.onGetMychessCallBack = function(self,data)
    Log.i("ReplayDialog.onGetMychessCallBack");
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
ReplayDialog.onGetMychessByTimeCallBack = function(self, data)
    Log.i("ReplayDialog.onGetMychessByTimeCallBack");
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
ReplayDialog.onGetSuggestCallBack = function(self,data)
    Log.i("ReplayDialog.onGetSuggestCallBack");
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
ReplayDialog.onGetSuggestByTimeCallBack = function(self, data)
    Log.i("ReplayDialog.onGetSuggestByTimeCallBack");
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
ReplayDialog.onOpenOrSelfMychessCallBack = function(self, data)
    self.m_chess_item:setOpenOrSelfType();
end;


-- 删除我的收藏回调
ReplayDialog.onDelMychessCallBack = function(self)
    ChessToastManager.getInstance():showSingle("删除成功！",2000);
    if self.m_cur_state == ReplayDialog.REPLAY then
    elseif self.m_cur_state == ReplayDialog.MYSAVE then
        self:showMySaveChess(false);
    elseif self.m_cur_state == ReplayDialog.SUGGEST then
        self:showSuggestChess(false);
    end;
end;

require("dialog/common_share_dialog");
--[Comment]
--分享棋谱
--data: 复盘数据
function ReplayDialog.shareChess(self,data)
--    if not data then return end
--    local manualData = {};
--    manualData.red_mid = self.m_data.red_mid or "0";       --红方uid
--    manualData.black_mid = self.m_data.black_mid or "0";    --黑方uid
--    manualData.win_flag = self.m_data.win_flag or "1";        --胜利方（1红胜，2黑胜，3平局）
--    manualData.manual_type = self.m_data.manual_type or "1";     --棋谱类型，1联网游戏，2残局，3单机游戏，4用户打谱
--    manualData.end_type = self.m_data.m_game_end_type or self.m_data.end_type or "1";    --棋盘开局
--    manualData.start_fen = self.m_data.fenStr or self.m_data.start_fen;    -- 棋盘开局
--    manualData.move_list = self.m_data.mvStr or self.m_data.move_list;     -- 走法，json字符串
--    manualData.manual_id = self.m_data.manual_id;       -- 保存的棋谱id
--    manualData.mid = self.m_data.mid;                   -- mid     
--    manualData.h5_developUrl = PhpConfig.h5_developUrl;       
--    manualData.title = self:getShareTitle() or "复盘演练（博雅中国象棋）";
--    manualData.description = self:getShareTime() or "复盘让您回顾精彩对局"; 


--    local url = require("libs/url");
--    local u = url.parse(manualData.h5_developUrl);
--    local params = {}
--    params.manual_id = manualData.manual_id
--    u:addQuery(params);
--    manualData.url =  u:build()
--    if not self.commonShareDialog then
--        self.commonShareDialog = new(CommonShareDialog);
--    end
--    self.commonShareDialog:setShareDate(data,"manual_share");
--    self.commonShareDialog:show();

end

ReplayDialog.dateFilterShow = function(self)
    self.m_date_select_view:setVisible(true);
    EffectAnim.getInstance():fadeInAndOut(self.m_date_select_bg,nil,200);
    EffectAnim.getInstance():fadeInAndOut(self.m_date_bg,nil,200);
    EffectAnim.getInstance():scaleBigAndSmall(self.m_date_bg,nil,200,135,0);
end;

ReplayDialog.dateFilterHide = function(self,finger_action,x,y,drawing_id_first,drawing_id_current, event_time)
    if finger_action ~= kFingerDown then
        EffectAnim.getInstance():fadeInAndOut(nil,self.m_date_select_bg,200);
        EffectAnim.getInstance():fadeInAndOut(nil,self.m_date_bg,200);
        EffectAnim.getInstance():scaleBigAndSmall(nil,self.m_date_bg,200,135,0,function()self.m_date_select_view:setVisible(false); end);
    end;
end;

ReplayDialog.onReplayFilterBtn = function(self)
    self:dateFilterShow();
end;

ReplayDialog.onDapuFilterBtn = function(self)
    self:dateFilterShow();
end;

ReplayDialog.onSuggestFilterBtn = function(self)
    self:dateFilterShow();
end;

ReplayDialog.onShareSuccessCallBack = function(self)
    local params = {};
    if self.m_chess_item and self.m_chess_item:getManualId() then
        params.manual_id = self.m_chess_item:getManualId();
        HttpModule.getInstance():execute(HttpModule.s_cmds.UploadChessShareNum,params);
    end;
end;
---------------------------- http_event ----------------------------
ReplayDialog.onEventResponse = function(self, cmd, data)
    if cmd == kReplaySaveMychess then
        self:onSaveMychessCallBack(data);
    elseif cmd == kReplayDelMychess then
        self:onDelMychessCallBack(data);
    elseif cmd == kOpenOrSelfMyChess then
        self:onOpenOrSelfMychessCallBack(data);
    elseif cmd == kReplayGetMySavechess then
        if self.m_mysave_chess_bytime then
            self:onGetMychessByTimeCallBack(data);
        else
            self:onGetMychessCallBack(data);
        end;
    elseif cmd == kReplayFriendSuggestChess then
        if self.m_suggest_chess_bytime then
            self:onGetSuggestByTimeCallBack(data);
        else
            self:onGetSuggestCallBack(data);
        end;
    elseif cmd == kShareSuccessCallBack then
        self:onShareSuccessCallBack();
    end;
end;

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
