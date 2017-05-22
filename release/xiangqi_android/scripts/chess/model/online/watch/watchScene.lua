
require(BASE_PATH.."chessScene");


WatchScene = class(ChessScene);

WatchScene.s_controls = 
{
    back_btn                    = 1;
    top_view                    = 2;
    teapot_dec                  = 3;
    stone_dec                   = 4;
    watch_list                  = 5;
    refresh_btn                 = 6;
    friend_watch_room_btn       = 7;
    master_watch_room_btn       = 8;
}

WatchScene.s_cmds = 
{
    updata_watch_game           = 1;
    updata_friend_watch_game    = 2;
    updataUserIcon              = 3;
}

WatchScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = WatchScene.s_controls;
    self.m_watch_list_data = {};
    self.m_fwatch_list_data = {};
    self.m_fwatch_list_unique_id = {};
    self:initView();

    self:setSelectClick(true);
end 
WatchScene.resume = function(self)
    ChessScene.resume(self);
    self:resetWatchList();
--    self:removeAnimProp();
--    self:resumeAnimStart();
end;
WatchScene.pause = function(self)
	ChessScene.pause(self);
    self:removeAnimProp();
--    self:pauseAnimStart();
end 


WatchScene.dtor = function(self)
    self.m_watch_list_data = nil;
    delete(self.anim_end);
    delete(self.anim_start);
end 


------------------------------function------------------------------

WatchScene.removeAnimProp = function(self)
    if self.m_anim_prop_need_remove then
        self.m_friends_btn:removeProp(1);
        self.m_master_btn:removeProp(1);
        self.m_friends_btn:removeProp(2);
        self.m_master_btn:removeProp(2);
        self.m_left_leaf:removeProp(1);
        self.m_right_leaf:removeProp(1);
        self.m_anim_prop_need_remove = false;
    end
end

WatchScene.setAnimItemEnVisible = function(self,ret)
    self.m_left_leaf:setVisible(ret);
    self.m_right_leaf:setVisible(ret);
end

WatchScene.resumeAnimStart = function(self,lastStateObj,timer,func)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
   local duration = timer.duration;
   local waitTime = timer.waitTime
   local delay = timer.duration + duration;
   
--   local w,h = self:getSize();
--   if not typeof(lastStateObj,OnlineState) then
--        self.m_root:removeProp(1);
--        self.m_root:addPropTranslate(1,kAnimNormal,duration,waitTime,-w,0,nil,nil);
--   end
    delete(self.anim_start);
   self.anim_start = new(AnimInt,kAnimNormal,0,1,waitTime,-1);
   if self.anim_start then
        self.anim_start:setEvent(self,function()
            self:setAnimItemEnVisible(true);
            delete(self.anim_start);
        end);
   end

    local lw,lh = self.m_left_leaf:getSize();
    self.m_left_leaf:addPropTranslate(1, kAnimNormal, waitTime, delay, -lw, 0, -10, 0);
    local rw,rh = self.m_right_leaf:getSize();
    self.m_right_leaf:addPropTranslate(1, kAnimNormal, waitTime, delay, rw, 0, -10, 0);

    self.m_friends_btn:addPropTransparency(2,kAnimNormal,waitTime,delay,0,1);
    self.m_friends_btn:addPropScale(1,kAnimNormal,waitTime,delay,0.8,1,0.6,1,kCenterXY,75,30);
    self.m_master_btn:addPropTransparency(2,kAnimNormal,waitTime,delay,0,1);
    local anim = self.m_master_btn:addPropScale(1,kAnimNormal,waitTime,delay,0.8,1,0.6,1,kCenterXY,75,30);
    if anim then
        anim:setEvent(self,function()
            self.m_anim_prop_need_remove = true;
            self:removeAnimProp();
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end
        end);
    end

   -- 上部动画
--   local w,h = self.m_top_view:getSize();
--   local anim = self.m_top_view:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, -h, 0);
--   anim:setEvent(self,self.removeAnimProp);

--   local w,h = self.m_refresh_btn:getSize();
--   self.m_refresh_btn:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, -h, 0);
   -- 下部动画
--   local w,h = self.m_watch_list:getSize();
--   self.m_watch_list:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, h, 0);

--   -- 茶壶 石子 后退按钮动画
--   local w,h = self.m_stone_dec:getSize();
--   self.m_stone_dec:addPropTranslate(1, kAnimNormal, duration, delay, w, 0, 0, 0);

--   local w,h = self.m_teapot_dec:getSize();
--   self.m_teapot_dec:addPropTranslate(1, kAnimNormal, duration, delay, -w, 0, 0, 0);

--   self.m_back_btn:addPropTransparency(1,kAnimNormal,duration,delay,0,1);

--   self.m_watch_list:addPropTransparency(1,kAnimNormal,duration,delay,0,1);
   -- 
end

WatchScene.pauseAnimStart = function(self,newStateObj,timer)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = timer.duration + duration;

--   local w,h = self:getSize();
--   if not typeof(newStateObj,OnlineState) then
--       self.m_root:removeProp(1);
--       self.m_root:addPropTranslate(1,kAnimNormal,duration,waitTime,0,-w,nil,nil);
--   end
    delete(self.anim_end);
    self.anim_end = new(AnimInt,kAnimNormal,0,1,delay,-1);
   if self.anim_end then
        self.anim_end:setEvent(self,function()
            self.m_anim_prop_need_remove = true;
            self:removeAnimProp();
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end
            delete(self.anim_end);
        end);
   end

    local lw,lh = self.m_left_leaf:getSize();
    self.m_left_leaf:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, -lw, 0, -10);
    local rw,rh = self.m_right_leaf:getSize();
    local anim = self.m_right_leaf:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, rw, 0, -10);
    if anim then
        anim:setEvent(self,function()
            self:setAnimItemEnVisible(false);
        end);
    end
   -- 上部动画
--   local w,h = self.m_top_view:getSize();
--   local anim = self.m_top_view:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, 0, -h);
--   anim:setEvent(self,self.removeAnimProp);

--   local w,h = self.m_refresh_btn:getSize();
--   self.m_refresh_btn:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, 0, -h);

--   -- 下部动画
----   local w,h = self.m_watch_list:getSize();
----   self.m_watch_list:addPropTranslate(1, kAnimNormal, duration, delay, 0, 0, 0, h);

--   -- 茶壶 石子 后退按钮动画
--   local w,h = self.m_stone_dec:getSize();
--   self.m_stone_dec:addPropTranslate(1, kAnimNormal, duration, delay, 0, w, 0, 0);

--   local w,h = self.m_teapot_dec:getSize();
--   self.m_teapot_dec:addPropTranslate(1, kAnimNormal, duration, delay, 0, -w, 0, 0);

--   self.m_back_btn:addPropTransparency(1,kAnimNormal,duration,delay,1,0);

--   self.m_watch_list:addPropTransparency(1,kAnimNormal,duration,delay,1,0);
--   -- 
end



WatchScene.onWatchBackActionBtnClick = function(self)
    
    self:requestCtrlCmd(WatchController.s_cmds.back_action);

end;

WatchScene.onWatchRefreshBtnClick = function(self)
    if self.m_watchView_click then
        self:masterWactchList();
    else
        self:friendsWactchList();
    end
end;

WatchScene.initView = function(self)
    self.kick_map = {};--好友观战去重用

    self.m_top_view = self:findViewById(self.m_ctrls.top_view);
    self.m_back_btn = self:findViewById(self.m_ctrls.back_btn);
    self.m_left_leaf = self.m_root:getChildByName("Image1");
    self.m_right_leaf = self.m_root:getChildByName("Image2");
--    self.m_stone_dec = self:findViewById(self.m_ctrls.stone_dec);
--    self.m_teapot_dec = self:findViewById(self.m_ctrls.teapot_dec);
    --title
    self.m_refresh_btn = self:findViewById(self.m_ctrls.refresh_btn);

    --棋友观战
    self.m_friends_btn = self:findViewById(self.m_ctrls.friend_watch_room_btn);
    self.m_friends_btn:setOnClick(self,self.friendsWactchList);
    --大师观战
    self.m_master_btn = self:findViewById(self.m_ctrls.master_watch_room_btn);
    self.m_master_btn:setOnClick(self,self.masterWactchList);
    --content
    self.m_watch_list = self:findViewById(self.m_ctrls.watch_list)
    local w,h = self:getSize();
    local cw,ch = self.m_watch_list:getSize();
    self.m_watch_list:setSize(nil,ch+h-System.getLayoutHeight());
    self.m_watch_list_friends_text = self.m_root:getChildByName("friends");
    self.m_watch_list_master_text = self.m_root:getChildByName("master");
    self.m_watch_list_loading_text = self.m_root:getChildByName("loading");
--    self.m_watch_list:setOnItemClick(self,self.onWatchListItemClick);
    self:resetWatchList();
end;

WatchScene.setSelectClick = function(self,flag)
    self.m_watchView_click = flag;
    if flag then
        self.m_friends_btn:setFile("online/watch/friend_watch_room.png");
        self.m_master_btn:setFile("online/watch/master_watch_room_chose.png");
    else
        self.m_friends_btn:setFile("online/watch/friend_watch_room_chose.png");
        self.m_master_btn:setFile("online/watch/master_watch_room.png");
    end
end

WatchScene.resetWatchList = function(self) 
    self.m_watch_list:setVisible(false);
    self.m_watch_list_friends_text:setVisible(false);
    self.m_watch_list_master_text:setVisible(false);
    self.m_watch_list_loading_text:setVisible(true);
end;

WatchScene.onUpdataWatchGame = function(self, data)
    print_string("WatchScene.onUpdataWatchGame" );
    self:resetWatchList();
    self.m_watch_list_loading_text:setVisible(false);

	if not data or table.maxn(data) <= 0 then
        self.m_watch_list_master_text:setVisible(true);
	end

	if data and table.maxn(data) > 0  then
        self.m_watch_list_data = data;
        self.m_watch_adapter = nil;
		self.m_watch_adapter = new(WatchGameItemCacheAdapter,WatchGameItem,self.m_watch_list_data);
        self.m_watch_adapter:setWatchSceneHandler(self);
        self.m_watch_list:setAdapter(self.m_watch_adapter);
        self.m_watch_list:setVisible(true);
	end
end;
-- 更新棋友观战列表
WatchScene.onUpdataFriendsWatchGame = function(self,data)
    print_string("WatchScene.onUpdatafWatchGame" );
    self:resetWatchList();
    self.m_watch_list_loading_text:setVisible(false);

    if not data or table.maxn(data) <= 0 then
        self.m_watch_list_friends_text:setVisible(true);
    end

    local temp_tab = {};
    for k,v in pairs(data) do   
        if v and self.kick_map[v.tid] ~= 1 then
            self.kick_map[v.tid] = 1;
            table.insert(temp_tab,v);
        end
    end

    if temp_tab and table.maxn(temp_tab) > 0 then
        self.m_watch_list_data = temp_tab;
        self.m_watch_adapter = nil;
		self.m_watch_adapter = new(WatchGameItemCacheAdapter,WatchGameItem,self.m_watch_list_data);
        self.m_watch_adapter:setWatchSceneHandler(self);
        self.m_watch_list:setAdapter(self.m_watch_adapter);
        self.m_watch_list:setVisible(true);
    end
end

WatchScene.onWatchListItemClick = function(self,item)
	UserInfo.getInstance():setTid(item.m_obtid);
    self:requestCtrlCmd(WatchController.s_cmds.entry_action);
end;

WatchScene.friendsWactchList = function(self)
    self:setSelectClick(false);
--    self:requestCtrlCmd(WatchController.s_cmds.refresh_friends_game);
    self.kick_map = {};
    self:resetWatchList();
    self:requestCtrlCmd(WatchController.s_cmds.refresh_action,false);
end

WatchScene.masterWactchList = function(self)
    self:setSelectClick(true);
    self:resetWatchList();
    self:requestCtrlCmd(WatchController.s_cmds.refresh_action,true);
end

WatchScene.onUpdataUserIcon = function(self,imageName,uid)
    if not imageName or not uid then return end;
--    if self.m_watch_adapter and self.m_watch_list_data then
--        for i,v in ipairs(self.m_watch_list_data) do
--            if self.m_watch_adapter:isHasView(i) then
--                self.m_watch_adapter:getTmpView(i):updateHeadImg(imageName,uid);
--            end
--        end
--    end
end
---------------------------------config-------------------------------
WatchScene.s_controlConfig = 
{
	[WatchScene.s_controls.back_btn]                    = {"back_btn"};
    [WatchScene.s_controls.refresh_btn]                 = {"refresh_btn"};
    [WatchScene.s_controls.watch_list]                  = {"watch_list"};
    [WatchScene.s_controls.friend_watch_room_btn]       = {"top_view","friend_watch_room_btn"};
    [WatchScene.s_controls.master_watch_room_btn]       = {"top_view","master_watch_room_btn"}; 
	[WatchScene.s_controls.top_view]                    = {"top_view"};
	[WatchScene.s_controls.teapot_dec]                  = {"teapot_dec"};
	[WatchScene.s_controls.stone_dec]                   = {"stone_dec"};
    
};
--定义控件的触摸响应函数
WatchScene.s_controlFuncMap =
{
	[WatchScene.s_controls.back_btn] = WatchScene.onWatchBackActionBtnClick;
    [WatchScene.s_controls.refresh_btn] = WatchScene.onWatchRefreshBtnClick;
    
};
WatchScene.s_cmdConfig = 
{
	[WatchScene.s_cmds.updata_watch_game]		        = WatchScene.onUpdataWatchGame;
    [WatchScene.s_cmds.updata_friend_watch_game]		= WatchScene.onUpdataFriendsWatchGame;
    [WatchScene.s_cmds.updataUserIcon]                  = WatchScene.onUpdataUserIcon;
}































-------------------------------WatchGameItem---------------------------

WatchGameItemCacheAdapter = class(CacheAdapter);

WatchGameItemCacheAdapter.setWatchSceneHandler = function(self,handler)
    self.m_handler = handler;
end

WatchGameItemCacheAdapter.getView = function(self,index)
    local view = self.m_views[index];

	if view and self.m_changedItems[view] then
		self.m_changedItems[view] = nil;
		delete(view);
		self.m_views[index] = nil
	end

    if self.m_views[index] then 
        self.m_views[index]:setVisible(true);
    else
		self.m_views[index] =  Adapter.getView(self,index);
        if self.m_views[index].setWatchSceneHandler then
            self.m_views[index]:setWatchSceneHandler(self.m_handler);
        end
	end

	return self.m_views[index];    
end
------观战列表Item
WatchGameItem = class(Node);
WatchGameItem.ICON_PRE = "record";

WatchGameItem.ctor = function(self,room)
    self.m_data = room;
    self.m_obtid = room.tid;
    require(VIEW_PATH.."watch_list_view_item");
    self.m_root_view = SceneLoader.load(watch_list_view_item);
    self.m_root_view:setAlign(kAlignCenter);
    self:addChild(self.m_root_view);
    local w,h = self.m_root_view:getSize();
    self:setSize(w,h*1.2);

    self.m_btn = self.m_root_view:getChildByName("item_bg");
    self.m_btn:setOnClick(self,self.onClick);
    self.m_btn:setSrollOnClick();

    self.m_red_player_view = self.m_btn:getChildByName("red_player");
    self.m_black_player_view = self.m_btn:getChildByName("black_player");
    self.m_watch_count = self.m_root_view:getChildByName("watch_num_bg"):getChildByName("watch_room_player_num");
    self.m_watch_count:setText("观战人数 "..(room.ob_num or 0));
    self.m_watch_time = self.m_root_view:getChildByName("watch_num_bg"):getChildByName("watch_room_time");
    self.m_watch_time:setText("已进行: "..self:getTime(room.play_time));
    
    self.m_red_player = json.decode(room.red_info);
    self.m_red_name = self.m_root_view:getChildByName("item_bg"):getChildByName("red_player"):getChildByName("name");
--    self.m_red_name1 = self.m_root_view:getChildByName("item_bg"):getChildByName("red_player"):getChildByName("name1"); 
    self.m_red_name:setText(lua_string_sub(self.m_red_player.user_name,6));
--    self.m_red_name1:setText(lua_string_sub(self.m_red_player.user_name,6));
    self.m_red_vip_logo = self.m_red_player_view:getChildByName("vip_logo");
    self.m_red_level_icon = self.m_root_view:getChildByName("item_bg"):getChildByName("red_player"):getChildByName("level_icon");
    self.m_red_level_icon:setFile("common/icon/level_"..(10-UserInfo.getInstance():getDanGradingLevelByScore(self.m_red_player.score))..".png");
    
    self.m_black_player = json.decode(room.black_info);
    self.m_black_name = self.m_root_view:getChildByName("item_bg"):getChildByName("black_player"):getChildByName("name");
--    self.m_black_name1 = self.m_root_view:getChildByName("item_bg"):getChildByName("black_player"):getChildByName("name1");
    self.m_black_name:setText(lua_string_sub(self.m_black_player.user_name,6));
--    self.m_black_name1:setText(lua_string_sub(self.m_black_player.user_name,6));
    self.m_black_vip_logo = self.m_black_player_view:getChildByName("vip_logo");
    self.m_black_level_icon = self.m_root_view:getChildByName("item_bg"):getChildByName("black_player"):getChildByName("level_icon");
    self.m_black_level_icon:setFile("common/icon/level_"..(10-UserInfo.getInstance():getDanGradingLevelByScore(self.m_black_player.score))..".png");
    
    -- 红方头像
    self.m_red_user_head_mask = self.m_root_view:getChildByName("item_bg"):getChildByName("red_player"):getChildByName("head_bg"):getChildByName("head_mask");
    self.m_red_vip_frame = self.m_root_view:getChildByName("item_bg"):getChildByName("red_player"):getChildByName("head_bg"):getChildByName("vip_frame");
    self.m_red_user_head = new(Mask,UserInfo.DEFAULT_ICON[1],"hall/icon_frame_mask.png");
    self.m_red_user_head:setSize(self.m_red_user_head_mask:getSize());
    self.m_red_user_head_mask:addChild(self.m_red_user_head);

    local iconType = tonumber(self.m_red_player.icon);
    if iconType then
        if 0 ~= iconType then
            self.m_red_user_head:setFile(UserInfo.DEFAULT_ICON[iconType]  or UserInfo.DEFAULT_ICON[1]);
        end
    else
        if "" ~= self.m_red_player.icon then --兼容1.7.5之前的版本的头像为""时显示默认头像。
            self.m_red_user_head:setUrlImage(self.m_red_player.icon,UserInfo.DEFAULT_ICON[1]);
        end
    end

--    self.m_red_user_head:setFile(self.m_red_player:getIconFile());
--    local iconType = tonumber(self.m_red_player.icon);
--    if iconType and iconType > 0 then
--        self.m_red_user_head:setFile(UserInfo.DEFAULT_ICON[iconType]);
--    else
--        if iconType == -1 then --兼容1.7.5之前的版本的头像为""时显示默认头像。
--            self.m_red_user_head:setUrlImage(self.m_red_player.icon,UserInfo.DEFAULT_ICON[1]);
--        end
--    end

    -- 黑方头像
    self.m_black_user_head_mask = self.m_root_view:getChildByName("item_bg"):getChildByName("black_player"):getChildByName("head_bg"):getChildByName("head_mask");
    self.m_black_vip_frame = self.m_root_view:getChildByName("item_bg"):getChildByName("black_player"):getChildByName("head_bg"):getChildByName("vip_frame");
    self.m_black_user_head = new(Mask,UserInfo.DEFAULT_ICON[1],"hall/icon_frame_mask.png");
    self.m_black_user_head:setSize(self.m_black_user_head_mask:getSize());
    self.m_black_user_head_mask:addChild(self.m_black_user_head);

    local iconType = tonumber(self.m_black_player.icon);
    if iconType then
        if 0 ~= iconType then
            self.m_black_user_head:setFile(UserInfo.DEFAULT_ICON[iconType] or UserInfo.DEFAULT_ICON[1]);
        end
    else
        if "" ~= self.m_black_player.icon then --兼容1.7.5之前的版本的头像为""时显示默认头像。
            self.m_black_user_head:setUrlImage(self.m_black_player.icon,UserInfo.DEFAULT_ICON[1]);
        end
    end

    local rx,ry = self.m_red_vip_logo:getPos();
    local rw,rh = self.m_red_vip_logo:getSize();
    local bw,bh = self.m_black_vip_logo:getSize();
--    local bvw,bvh = self.m_black_vip_logo:getSize();

    --红方vip
    if self.m_red_player and self.m_red_player.is_vip and self.m_red_player.is_vip == 1 then
        self.m_red_vip_frame:setVisible(true);
        self.m_red_vip_logo:setVisible(true);
        self.m_red_name:setPos(rx+rw+3,-18);
    else
        self.m_red_vip_frame:setVisible(false);
        self.m_red_vip_logo:setVisible(false);
        self.m_red_name:setPos(93,-18);
    end
    --黑方vip
    if self.m_black_player and self.m_black_player.is_vip and self.m_black_player.is_vip == 1 then --self.m_black_player and self.m_black_player.is_vip and self.m_black_player.is_vip == 
        self.m_black_name:setPos(bw+rx+3,-18);
        self.m_black_vip_frame:setVisible(true);
        self.m_black_vip_logo:setVisible(true);
    else
        self.m_black_name:setPos(93,-18);
        self.m_black_vip_frame:setVisible(false);
        self.m_black_vip_logo:setVisible(false);
    end

--    local iconType = tonumber(self.m_black_player.icon);

--    if self.m_black_player.icon == "" then
--        iconType = self.m_black_player:getIconType();
--    end

--    local iconType = tonumber(self.m_black_player.icon);
--    if iconType and iconType > 0 then
--        self.m_black_user_head:setFile(UserInfo.DEFAULT_ICON[iconType]);
--    else
--        if iconType == -1 then --兼容1.7.5之前的版本的头像为""时显示默认头像。
--            self.m_black_user_head:setUrlImage(self.m_black_player.icon,UserInfo.DEFAULT_ICON[1]);
--        end
--    end

end

WatchGameItem.updateHeadImg = function(self,imageName,uid)
--    local uid = tonumber(uid);
--    if uid == self.m_red_player.uid then
--        self.m_red_user_head:setFile(imageName);
--    end
--    if uid == self.m_black_player.uid then
--        self.m_black_user_head:setFile(imageName);
--    end
end

WatchGameItem.onClick = function(self)
    if self.m_handler then
        WatchScene.onWatchListItemClick(self.m_handler,self);
    end
end

WatchGameItem.setWatchSceneHandler = function(self,handler)
    self.m_handler = handler;
end

WatchGameItem.getTime = function(self,time)
    local str = "";
    if time and time > 0 then
        local miao = time%60;
        local temp = time - miao;
        local fen = temp/60;
        str = fen .. "分" .. miao .. "秒";
    else
        str = "0分"
    end
    return str;
end

WatchGameItem.getData = function(self)
	return self.m_data;
end


WatchGameItem.dtor = function(self)
	
end