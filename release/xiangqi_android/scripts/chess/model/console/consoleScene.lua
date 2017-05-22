
require(BASE_PATH.."chessScene");
require("dialog/chioce_dialog");
require("dialog/account_dialog");
require("ui/scrollBtn");
ConsoleScene = class(ChessScene);

ConsoleScene.s_controls = 
{
    back_btn                = 1;
    reset_btn               = 2;
    add_coin_btn            = 3;
    content_scroll_view     = 4;
    console_bottom_view     = 5;
    console_user_icon       = 6;
    console_user_level      = 7;

}

ConsoleScene.s_cmds = 
{
    update_user_money = 1;
    show_daily_task_dialog = 2;
    syn_progress  = 3;
}

ConsoleScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = ConsoleScene.s_controls;
    self:initView();
    self:initConsoleGate();--初始化单机关卡
    self.m_max_level = GameCacheData.getInstance():getInt(GameCacheData.CONSOLE_MAX_OPENLEVEL..UserInfo.getInstance():getUid(), 3);
    self:setLocked();
end 

ConsoleScene.resume = function(self)
    ChessScene.resume(self);
--    self:removeAnimProp();
--    self:resumeAnimStart();
    self:getConsoleProgress();
    if UserInfo.getInstance():getIsFromHall() then
        UserInfo.getInstance():setIsFromHall(false)
        self:checkExistedChess();
    end
end;
ConsoleScene.pause = function(self)
	ChessScene.pause(self);
    self:removeAnimProp();
--    self:pauseAnimStart();
end 


ConsoleScene.dtor = function(self)
    ShowMessageAnim.deleteAll();
    delete(self.m_chioce_dialog);
    self.m_chioce_dialog = nil;
    
   delete(self.m_anim_start);
   delete(self.m_anim);
   delete(self.m_anim_end);
end 



------------------------------function------------------------------
ConsoleScene.initView = function(self)
    self.m_console_view = self.m_root:getChildByName("console_view");

    self.m_title_view = self.m_console_view:getChildByName("console_title_view")
    self.m_title = self.m_title_view:getChildByName("console_title_texture_bg"):getChildByName("console_title_texture");
    self.m_left_leaf = self.m_title_view:getChildByName("bamboo_left");
    self.m_right_leaf = self.m_title_view:getChildByName("bamboo_right");
    self.m_back_btn = self:findViewById(self.m_ctrls.back_btn);
    if kPlatform == kPlatformIOS then
        self.m_more_btn = self.m_console_view:getChildByName("right_now_btn");
        if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
            self.m_more_btn:setVisible(true);
        else
            self.m_more_btn:setVisible(false);
        end;
    end;
end;

ConsoleScene.setAnimItemEnVisible = function(self,ret)
--    self.m_title:setVisible(ret);
    self.m_left_leaf:setVisible(ret);
    self.m_right_leaf:setVisible(ret);
--    for index = 1,10 do
--		self.m_btn[index]:setVisible(ret);
--	end
end

ConsoleScene.resumeAnimStart = function(self,lastStateObj,timer,func)
   self:removeAnimProp();
   self.m_back_btn:setPickable(false);
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
   -- 上部动画
   self.m_title:addPropTransparency(2,kAnimNormal,waitTime,delay,0,1);
   self.m_title:addPropScale(1,kAnimNormal,waitTime,delay,0.8,1,0.6,1,kCenterXY,70,40);
   local lw,lh = self.m_left_leaf:getSize();
   self.m_left_leaf:addPropTranslate(1,kAnimNormal,waitTime,delay,- lw,0,-10,0);
   local rw,rh = self.m_right_leaf:getSize();
    self.m_right_leaf:addPropTranslate(1,kAnimNormal,waitTime,delay,rw,0,-10,0);

    local delayTime = delay;
--    for index = 1,10 do
--        delayTime = delay + index * 100;
--        --660 172
--        self.m_btn[index]:addPropTransparency(2,kAnimNormal,waitTime,delayTime,0,1);
--        self.m_btn[index]:addPropScale(1,kAnimNormal,waitTime,delayTime,0.7,1,0.6,1,kCenterXY,330,140);
--    end
   delete(self.m_anim);
   self.m_anim = new(AnimInt,kAnimNormal,0,1,delayTime,-1);
   if self.m_anim then
       self.m_anim:setEvent(self,function()
            self:removeAnimProp();
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end
            self.m_back_btn:setPickable(true);
            delete(self.m_anim);
       end);
   else
        self.m_back_btn:setPickable(true);
   end
end



ConsoleScene.pauseAnimStart = function(self,newStateObj,timer)
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

    local lw,lh = self.m_left_leaf:getSize();
   self.m_left_leaf:addPropTranslate(1,kAnimNormal,waitTime,-1,0,-lw,0,-10);
   local rw,rh = self.m_right_leaf:getSize();
   local anim = self.m_right_leaf:addPropTranslate(1,kAnimNormal,waitTime,-1,0,rw,0,-10);
   if anim then
        anim:setEvent(self,function()
            self:setAnimItemEnVisible(false);
        end);
   end

--   -- 茶壶 
--   local w,h = self.m_teapot_dec:getSize();
--   self.m_teapot_dec:addPropTranslate(1, kAnimNormal, duration, delay, 0, -w, 0, 0);
--   -- 返回
--   self.m_back_btn:addPropTransparency(1,kAnimNormal,duration,delay,1,0);
end


ConsoleScene.removeAnimProp = function(self)
    self.m_title:removeProp(1);
    self.m_title:removeProp(2);
    self.m_left_leaf:removeProp(1);
    self.m_right_leaf:removeProp(1);
--    self.m_teapot_dec:removeProp(1);
--    self.m_back_btn:removeProp(1);
end


ConsoleScene.initTitleView = function(self)
    
--    self.m_console_user_icon_add = self:findViewById(self.m_ctrls.add_coin_btn);
--    self.m_console_user_icon     = self:findViewById(self.m_ctrls.console_user_icon);
--    self.m_console_user_level    = self:findViewById(self.m_ctrls.console_user_level);

end;

ConsoleScene.refreshUserInfo = function(self)
 
    self.m_console_user_icon:setText(UserInfo.getInstance():getMoneyStr());    
    self.m_console_user_level:setText(UserInfo.getInstance():getDanGradingName())
end;


ConsoleScene.setLocked = function(self)
    for index = 1,  self.m_max_level do
        self.m_btn[index]:setLocked(false)
    end
end

ConsoleScene.setZhanji = function(self, zhanji)
    if not zhanji or table.maxn(zhanji) == 0 then return end;
    for index = 1, COSOLE_MODEL_GATE_NUM do
        self.m_btn[index]:setZhanji(zhanji[index]);
    end;
end;

ConsoleScene.onConsoleBackActionBtnClick = function(self)
    self:requestCtrlCmd(ConsoleController.s_cmds.back_action);
end;

ConsoleScene.quickPlay = function(self)
    local level = GameCacheData.getInstance():getInt(GameCacheData.CONSOLE_HASPASS_LEVEL, 0);
    if level < COSOLE_MODEL_GATE_NUM then
        level = level + 1;
    end;
    self:requestCtrlCmd(ConsoleController.s_cmds.entryRoom, level);
end;

ConsoleScene.onConsoleAddCoinBtnClick = function(self)
    
    self:requestCtrlCmd(ConsoleController.s_cmds.add_coin);

end;

ConsoleScene.initConsoleGate = function(self)
    self.m_content_scroll_view = self:findViewById(self.m_ctrls.content_scroll_view);
    self.m_btn = {};
    local rootW, rootH = self:getSize();
    local firstOffset = (rootW - 378) / 2; 
    self.m_boss_gallery = new(Gallery,0,0,rootW,800,450,800, firstOffset);
    self.m_boss_gallery:setAlign(kAlignTop);
    self.m_boss_gallery:setDirection(kHorizontal);
    self.m_content_scroll_view:addChild(self.m_boss_gallery);
    local y_pos = 0;
    for index = 1, COSOLE_MODEL_GATE_NUM do
        self.m_btn[index] = new(ConsoleBossItem,index,self);
        self.m_btn[index]:setPos(y_pos + firstOffset,nil);
        self.m_boss_gallery:addChildWithAnim(self.m_btn[index],index);
        y_pos = self.m_btn[index].m_width + y_pos;
    end;
end;

ConsoleScene.entryConsoleGame = function(self, level)
    print_string("ConsoleScene.entryConsoleGame in")
    self.currentIndex = level
    if self.m_isChoiceOldGame == true then
        return
    end
    if self.m_btn[level]:isUnLocked() then
        ChessToastManager.getInstance():showSingle("请您先攻克上一关，此关将自动解锁",1500);
        return
    end
    self:requestCtrlCmd(ConsoleController.s_cmds.entryRoom, level);
end;

--检查是否存在单机的象棋棋局，2014/12/22
ConsoleScene.checkExistedChess = function(self)
    local isExistedChess = GameCacheData.getInstance():getBoolean(GameCacheData.CONSOLE_IS_EXISTED_CHESS, false);
    if isExistedChess then
        local message = "系统检测到您上一盘棋局没有下完，是否继续？";
        if not self.m_chioce_dialog then
            self.m_chioce_dialog = new(ChioceDialog);
        end;
		self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE);
		self.m_chioce_dialog:setMessage(message);
		self.m_chioce_dialog:setPositiveListener(self,self.entryConsoleGameFromEixtedChess);
		self.m_chioce_dialog:setNegativeListener(self,self.notEntryConsoleGameFromEixtedChess);
		self.m_chioce_dialog:show();
    end;
end

--加入已存在的单机棋局。2014/12/22
ConsoleScene.entryConsoleGameFromEixtedChess = function(self)
    local level = GameCacheData.getInstance():getInt(GameCacheData.CONSOLE_PASS_LEVEL,1);
    UserInfo.getInstance():setJoinPlayedConsole(true);
	self:requestCtrlCmd(ConsoleController.s_cmds.entryRoom, level)
end;
--不加入已存在的单机棋局。2014/12/22
ConsoleScene.notEntryConsoleGameFromEixtedChess = function(self)
    UserInfo.getInstance():setJoinPlayedConsole(false);
    GameCacheData.getInstance():saveBoolean(GameCacheData.CONSOLE_IS_EXISTED_CHESS, false);
end;


ConsoleScene.getConsoleProgress = function(self)
    self:requestCtrlCmd(ConsoleController.s_cmds.get_progress);
end;


ConsoleScene.onSynProgress = function(self,pass_progress,zhanji)
    -- 1.9.10以前单机保存的进度（兼容）
    local old_native_progress = GameCacheData.getInstance():getInt(GameCacheData.CONSOLE_MAX_OPENLEVEL, 3);
    -- 1.9.10以后单机进度包括uid，非联网uid = 0;
    local uid = UserInfo.getInstance():getUid();
    -- uid == 0表示没登录过帐号
    if uid == 0 then
        local message =  "您处于未联网状态,所有进度数据可能丢失"; 
        ChessToastManager.getInstance():showSingle(message);  
    end;
    local new_native_progress = GameCacheData.getInstance():getInt(GameCacheData.CONSOLE_MAX_OPENLEVEL..UserInfo.getInstance():getUid(), 3);
    local new_native_offline_progress = GameCacheData.getInstance():getInt(GameCacheData.CONSOLE_MAX_OPENLEVEL.."0", 3);
    if new_native_offline_progress > new_native_progress then
        new_native_progress = new_native_offline_progress;
    end;
    if old_native_progress >= new_native_progress then
        GameCacheData.getInstance():saveInt(GameCacheData.CONSOLE_MAX_OPENLEVEL..UserInfo.getInstance():getUid(),old_native_progress);
    else
        GameCacheData.getInstance():saveInt(GameCacheData.CONSOLE_MAX_OPENLEVEL..UserInfo.getInstance():getUid(),new_native_progress);
    end;
    local native_progress = GameCacheData.getInstance():getInt(GameCacheData.CONSOLE_MAX_OPENLEVEL..UserInfo.getInstance():getUid(), 3);

    if pass_progress < COSOLE_MODEL_GATE_NUM then 
        if pass_progress + 1 >= native_progress then
            self.m_max_level = pass_progress+1;
            GameCacheData.getInstance():saveInt(GameCacheData.CONSOLE_MAX_OPENLEVEL..UserInfo.getInstance():getUid(),pass_progress+1);
        else
            self.m_max_level = native_progress;
            GameCacheData.getInstance():saveInt(GameCacheData.CONSOLE_MAX_OPENLEVEL..UserInfo.getInstance():getUid(),native_progress);
            self:requestCtrlCmd(ConsoleController.s_cmds.syn_console, native_progress - 1);
        end;
    else
        self.m_max_level = pass_progress;
        GameCacheData.getInstance():saveInt(GameCacheData.CONSOLE_MAX_OPENLEVEL..UserInfo.getInstance():getUid(),pass_progress);
    end;

    self:setLocked();
    self:setZhanji(zhanji);
end;

---------------------------------config-------------------------------
ConsoleScene.s_controlConfig = 
{
	[ConsoleScene.s_controls.back_btn]              = {"console_view","console_back_btn"};
    [ConsoleScene.s_controls.content_scroll_view]   = {"console_view","console_scroll_view"};
    [ConsoleScene.s_controls.console_bottom_view]   = {"console_view","console_bottom_view"};
    [ConsoleScene.s_controls.add_coin_btn]          = {"console_view","console_title_view","console_userinfo","console_user_money_bg"};
    [ConsoleScene.s_controls.console_user_icon]     = {"console_view","console_title_view","console_userinfo","console_user_money_bg","console_user_money"};
    [ConsoleScene.s_controls.console_user_level]    = {"console_view","console_title_view","console_userinfo","console_user_level_bg","console_user_level"};


};
--定义控件的触摸响应函数
ConsoleScene.s_controlFuncMap =
{
	[ConsoleScene.s_controls.back_btn] = ConsoleScene.onConsoleBackActionBtnClick;
    [ConsoleScene.s_controls.reset_btn] = ConsoleScene.onConsoleResetBtnClick;
    [ConsoleScene.s_controls.add_coin_btn] = ConsoleScene.onConsoleAddCoinBtnClick;
};

ConsoleScene.s_cmdConfig = 
{
    [ConsoleScene.s_cmds.syn_progress]             = ConsoleScene.onSynProgress;

}































-------------------------------ConsoleBossItem---------------------------

ConsoleBossItem = class(Button,false);


ConsoleBossItem.ctor = function(self,index, room)
    super(self,"drawable/blank.png","drawable/blank.png");
    self.m_index = index;
    self.m_room = room;
    require(VIEW_PATH .."console_boss_view");
    self.m_boss_view = SceneLoader.load(console_boss_view);
    self:addChild(self.m_boss_view);
    self:setSize(450,800);
    self.m_bg = self.m_boss_view:getChildByName("bg");
    self.m_locked_bg = self.m_boss_view:getChildByName("lock_bg");
    -- boss_img
    self.m_boss_img_view = self.m_bg:getChildByName("boss_img");
        -- img
        self.m_boss_img = self.m_boss_img_view:getChildByName("img");
    -- boss_name
    self.m_boss_name_view = self.m_bg:getChildByName("boss_name");
        -- name
        self.m_boss_name = self.m_boss_name_view:getChildByName("name");
    -- boss_zhanji
    self.m_boss_zhanji_view = self.m_bg:getChildByName("boss_zhanji");
        -- zhanji
        self.m_boss_zhanji = self.m_boss_zhanji_view:getChildByName("zhanji");
    
    self.m_boss_img:setFile("console/console_boss_"..index ..".png");
--    self.m_boss_img:setFile("console/zhaoyun.png");
    self.m_boss_name:setFile("console/gate_name"..index ..".png");
    self:setLocked(true);
end

ConsoleBossItem.dtor = function(self)

end;

-- 设置战绩
ConsoleBossItem.setZhanji = function(self, zhanji)
    self.m_boss_zhanji:setText("历史战绩：".. ((zhanji and zhanji.wintimes) or 0) .."胜 ".. ((zhanji and zhanji.losetimes) or 0) .."负");
end;


ConsoleBossItem.setLocked = function(self, locked)
    if locked then
        self.m_locked_bg:setVisible(true);
        self.m_boss_zhanji:setVisible(false);
        self.m_locked = true;
    else
        self.m_locked_bg:setVisible(false);
        self.m_boss_zhanji:setVisible(true);   
        self.m_locked = false;
    end;
end;

ConsoleBossItem.isUnLocked = function(self)
    return self.m_locked;
end;



ConsoleBossItem.onClick = function(self,finger_action, x, y, drawing_id_first, drawing_id_current)
    Log.i("ConsoleBossItem.onClick");
    if finger_action == kFingerDown then
        self.m_downX = x;
        self.m_downY = y;
	elseif finger_action == kFingerMove then
--        self.m_curX = x;
--        self.m_curY = y;
	elseif finger_action == kFingerUp then
        self.m_curX = x;
        self.m_curY = y;
        if not self.m_curX or math.abs(self.m_downX - self.m_curX) < 5 then
            self.m_room:entryConsoleGame(self.m_index);
        end;
	elseif finger_action==kFingerCancel then
		
	end
end;