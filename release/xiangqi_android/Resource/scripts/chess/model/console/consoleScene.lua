
require(BASE_PATH.."chessScene");
require("dialog/chioce_dialog");
require("dialog/account_dialog");
require("ui/scrollBtn");
require(VIEW_PATH .."console_boss_view");
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
    dapu_btn                = 8;
}

ConsoleScene.s_cmds = 
{
    update_user_money = 1;
    show_daily_task_dialog = 2;
    update_progress  = 3;
    update_console_config = 4;
}

ConsoleScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = ConsoleScene.s_controls;
    self:initView();
    self:initConsoleGate();--初始化单机关卡
    self:updateLockStatus();
    self:slideToCurrentGate();
end 

ConsoleScene.resume = function(self)
    ChessScene.resume(self);
--    self:removeAnimProp();
--    self:resumeAnimStart();
    if UserInfo.getInstance():getIsFromHall() then
        UserInfo.getInstance():setIsFromHall(false)
        self:checkExistedChess();
    end

    if not self.mIsCheckConsoleConfigVersion then
        self.mIsCheckConsoleConfigVersion = true
        self:showCheckConsoleConfigView()
    else
        self:getConsoleProgress();
    end

    self:onUpdateProgress()
    self:slideToCurrentGate();
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
   delete(self.mBuyChallengeDialog)
   delete(self.helpDialog)
end 



------------------------------function------------------------------
ConsoleScene.initView = function(self)
    self.m_console_view = self.m_root:getChildByName("console_view");

    self.m_title_view = self.m_console_view:getChildByName("console_title_view")
    self.m_title_view:getChildByName("help_btn"):setOnClick(self,self.showHelpDialog)
    self.m_title = self.m_title_view:getChildByName("console_title_texture_bg"):getChildByName("console_title_texture");
    self.m_left_leaf = self.m_title_view:getChildByName("bamboo_left");
    self.m_right_leaf = self.m_title_view:getChildByName("bamboo_right");

    self.m_left_leaf:setFile("common/decoration/left_leaf.png")
    self.m_right_leaf:setFile("common/decoration/right_leaf.png")

    self.m_back_btn = self:findViewById(self.m_ctrls.back_btn);
    self.m_dapu_btn = self.m_console_view:getChildByName("dapu_btn");
    self.m_dapu_tips = self.m_console_view:getChildByName("tips");
    self.m_dapu_tips:setVisible(false)

    self.mStarView = self.m_console_view:getChildByName("star_view")
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
            if kPlatform == kPlatformIOS then
            --     if tonumber(UserInfo.getInstance():getIosAuditStatus()) == 0 then return end;
            --     if tonumber(UserInfo.getInstance():getCanShowIOSAppstoreReview()) == 0 then return end;

            --     UserInfo.getInstance():setCanShowIOSAppstoreReview(0);
            -- -- 判断是不是刚进入这个界面
            --     if self.firstLoaded == nil then 
            --         self.firstLoaded = true;
            --         return;
            --     end;
            --     -- 判断返回这个界面的时候 有没有通关
            --     local lastGate = self.lastGate;
            --     local lastGateSort = self.lastGateSort;

            --     local currentGate = EndgateData.getInstance():getGate();
            --     local currentGateSort = EndgateData.getInstance():getGateSort();
            --     if currentGate.sort < lastGate.sort then
            --         return;
            --     end
            --     if currentGate.sort == lastGate.sort then
            --         if currentGateSort <= lastGateSort then
            --             return;
            --         end
            --     end
                -- require(DIALOG_PATH .. "ios_review_dialog_view");
                -- if not self.reviewDialog then
                --     self.reviewDialog = new(ReviewDialogView);
                -- end
                -- self.reviewDialog:show();
            end
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


ConsoleScene.updateLockStatus = function(self)
    local open_level = ConsoleData.getInstance():getMaxStarOpenLevel()
    for index = 1,  open_level do
        self.m_btn[index]:setLocked(false)
    end
end

ConsoleScene.slideToCurrentGate = function(self)
    if self.m_boss_gallery then
        local open_level = ConsoleData.getInstance():getWillPlayLevel()
        self.m_boss_gallery:slideToIndex(open_level);
    end;
end;

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
-- 进入当前关卡
ConsoleScene.onConsoleDapuBtnClick = function(self)
--    self:requestCtrlCmd(ConsoleController.s_cmds.dapu_action);
    local level = self.m_boss_gallery:getCurrentIndex()
    if level > 0 and level <= COSOLE_MODEL_GATE_NUM then
        self:entryConsoleGame(level)
    end
end

function ConsoleScene:onUpdateStartBtn()
    local level = self.m_boss_gallery:getCurrentIndex()
    local config = ConsoleData.getInstance():getConfigByLevel(level)
    local item = self.m_btn[level]
    if not config or not item then return end
    self.m_dapu_tips:setVisible(false)
    if not item:isLocked() then
        local starNum = item:getStarNum()
        local costMoney = tonumber(config.money) or 0
        if starNum > 0 or costMoney == 0 or level <= ConsoleData.DEFAULT_OPEN_LEVEL then
            self.m_dapu_btn:getChildByName("txt"):setText("免费闯关",0,0)
        else
            self.m_dapu_btn:getChildByName("txt"):setText( string.format("%d金币闯关",costMoney),0,0)
            self.m_dapu_tips:setVisible(true)
        end
        self.m_dapu_btn:setGray(false)
        self.m_dapu_btn:setTransparency(1)
        self.m_dapu_btn:getChildByName("txt"):setTransparency(1)
    else
        self.m_dapu_btn:getChildByName("txt"):setText("未解锁",0,0)
        self.m_dapu_btn:setGray(true)
        self.m_dapu_btn:setTransparency(0.8)
        self.m_dapu_btn:getChildByName("txt"):setTransparency(0.8)
    end
end

ConsoleScene.initConsoleGate = function(self)
    self.m_content_scroll_view = self:findViewById(self.m_ctrls.content_scroll_view);
    self.m_btn = {};
    local rootW, rootH = self:getSize();
    local firstOffset = (rootW - 378) / 2; 
    self.m_boss_gallery = new(Gallery,0,0,rootW,800,450,800, firstOffset);
    self.m_boss_gallery:setAlign(kAlignTop);
    self.m_boss_gallery:setDirection(kHorizontal);
    self.m_boss_gallery:setChangeIndexListener(self,self.onUpdateStartBtn)
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
    local config = ConsoleData.getInstance():getConfigByLevel(level)
    if self.m_btn[level]:isLocked() then
        local msg = "获得一定量星星解锁关卡"
        if config then
            msg = string.format("获得%d颗星后解锁",config.star)
        end
        ChessToastManager.getInstance():showSingle(msg,1500);
        return
    end

    if level > ConsoleData.DEFAULT_OPEN_LEVEL then
        local zhanji = ConsoleData.getInstance():getZhanJiByLevel(level)
        local costMoney = tonumber(config.money) or 0
        local star = zhanji.star
        if costMoney ~= 0 then
            if not star or #star == 0 then
                if not self.mBuyChallengeDialog then
                    self.mBuyChallengeDialog = new(ChioceDialog);
                    self.mBuyChallengeDialog:setMode(ChioceDialog.MODE_COMMON);
                    self.mBuyChallengeDialog:setNeedMask(false)
                end
                self.mBuyChallengeDialog:setMessage( string.format("是否花费%d金币闯关",costMoney));
                self.mBuyChallengeDialog:setNegativeListener(nil,nil);
                self.mBuyChallengeDialog:setPositiveListener(self,function()
                    local params = {}
                    params.console_level = level
                    HttpModule.getInstance():execute(HttpModule.s_cmds.UserBuyLevel,params,"请求中...")
                end);
                self.mBuyChallengeDialog:show();
                return 
            end
        end
    end

    self:requestCtrlCmd(ConsoleController.s_cmds.entryRoom, level);
end;

--检查是否存在单机的象棋棋局，2014/12/22
ConsoleScene.checkExistedChess = function(self)
    local isExistedChess = GameCacheData.getInstance():getBoolean(GameCacheData.CONSOLE_IS_EXISTED_CHESS, false);
    if isExistedChess then
        local gate = GameCacheData.getInstance():getInt(GameCacheData.CONSOLE_PASS_LEVEL,0);
        local message = nil;
        if gate >= 1 and gate <= COSOLE_MODEL_GATE_NUM then
            message = "系统检测到您挑战关卡 ".. User.CONSOLE_TITLE[gate] .." 的棋局尚未结束，是否继续？";
        else
            message = "系统检测到您上一盘棋局没有下完，是否继续？";
        end;
        if not self.m_chioce_dialog then
            self.m_chioce_dialog = new(ChioceDialog);
        end;
		self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE,"好的");
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
end

ConsoleScene.onUpdateProgress = function(self)
    local zhanji = ConsoleData.getInstance():getZhanJi()
    self:updateLockStatus()
    self:setZhanji(zhanji)
    self:updateTotalStarView()
    self:onUpdateStartBtn()
end
--[Comment]
-- 更新总星星界面
function ConsoleScene:updateTotalStarView()
    local max_star = 3 * COSOLE_MODEL_GATE_NUM
    local total_star = ConsoleData.getInstance():getTotalStarNum()
    local str = string.format("%d/%d",total_star,max_star)
    self.mStarView:getChildByName("star_proccess"):setText(str)
end
-- 需求没要求要加载界面
function ConsoleScene:showCheckConsoleConfigView()
    self:requestCtrlCmd(ConsoleController.s_cmds.check_console_config_version)

end

-- 需求没要求要加载界面
function ConsoleScene:dismissCheckConsoleConfigView()

end

--[Comment]
-- 单机配置更新触发界面更新
function ConsoleScene:updateConsoleConfigView()
    local config = ConsoleData.getInstance():getConfig()
    self:dismissCheckConsoleConfigView()
    for index = 1,  COSOLE_MODEL_GATE_NUM do
        self.m_btn[index]:setConfig(config[index .. ""])
    end
end


ConsoleScene.showHelpDialog = function(self)
    if not self.helpDialog then
        self.helpDialog = new(CommonHelpDialog)
        self.helpDialog:setMode(CommonHelpDialog.console_mode)
    end 
    self.helpDialog:show()
end

---------------------------------config-------------------------------
ConsoleScene.s_controlConfig = 
{
	[ConsoleScene.s_controls.back_btn]              = {"console_view","console_back_btn"};
    [ConsoleScene.s_controls.dapu_btn]              = {"console_view","dapu_btn"};
    [ConsoleScene.s_controls.content_scroll_view]   = {"console_view","console_scroll_view"};
    [ConsoleScene.s_controls.console_bottom_view]   = {"console_view","console_bottom_view"};
    [ConsoleScene.s_controls.add_coin_btn]          = {"console_view","console_title_view","console_userinfo","console_user_money_bg"};
    [ConsoleScene.s_controls.console_user_icon]     = {"console_view","console_title_view","console_userinfo","console_user_money_bg","console_user_money"};
    [ConsoleScene.s_controls.console_user_level]    = {"console_view","console_title_view","console_userinfo","console_user_level_bg","console_user_level"};


};
--定义控件的触摸响应函数
ConsoleScene.s_controlFuncMap =
{
	[ConsoleScene.s_controls.back_btn]              = ConsoleScene.onConsoleBackActionBtnClick;
    [ConsoleScene.s_controls.reset_btn]             = ConsoleScene.onConsoleResetBtnClick;
    [ConsoleScene.s_controls.add_coin_btn]          = ConsoleScene.onConsoleAddCoinBtnClick;
    [ConsoleScene.s_controls.dapu_btn]              = ConsoleScene.onConsoleDapuBtnClick;
};

ConsoleScene.s_cmdConfig = 
{
    [ConsoleScene.s_cmds.update_progress]             = ConsoleScene.onUpdateProgress;
    [ConsoleScene.s_cmds.update_console_config]     = ConsoleScene.updateConsoleConfigView;
}































-------------------------------ConsoleBossItem---------------------------

ConsoleBossItem = class(Button,false);


ConsoleBossItem.ctor = function(self,index, room)
    super(self,"drawable/blank.png","drawable/blank.png");
    self.m_index = index;
    self.m_room = room;
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

    self.m_boss_locked_tips = self.m_locked_bg:getChildByName("boss_locked_tips"):getChildByName("tips");

    self.mStarView = self.m_bg:getChildByName("star_view")

    self:setLocked(true);
    self.mStarTab = {}
    local startPos = 0
    for i=1,3 do
        local star = new(Image,"common/decoration/star_dec_4.png")
        star:setPos(startPos)
        startPos = startPos + star:getSize() + 10
        self.mStarTab[i] = star
        self.mStarView:addChild(star)
    end
    self.mStarView:setSize(startPos-10)
    local config = ConsoleData.getInstance():getConfig()
    self:setConfig(config[self.m_index .. ""])
end

ConsoleBossItem.dtor = function(self)

end;

-- 设置战绩
ConsoleBossItem.setZhanji = function(self, zhanji)
    if not zhanji then return end;
    self.m_boss_zhanji:setText("历史战绩：".. ((zhanji and zhanji.wintimes) or 0) .."胜 ".. ((zhanji and zhanji.losetimes) or 0) .."负");

    local star = zhanji.star
    if type(star) ~= "table" then star = {} end
    local starNum = #star
    for i=1,3 do
        if i <= starNum then
            self.mStarTab[i]:setFile("common/decoration/star_dec_3.png")
        else
            self.mStarTab[i]:setFile("common/decoration/star_dec_4.png")
        end
    end
    self.mStarNum = starNum
end

function ConsoleBossItem:getStarNum()
    return self.mStarNum or 0
end

-- 设置战绩
function ConsoleBossItem:setConfig(config)
    if not config then return end
    local star = config.star
    if type(star) == "number" then 
        self.m_boss_locked_tips:setText( string.format("获得%d颗星后解锁",star))
    end
end

ConsoleBossItem.setLocked = function(self, locked)
    self.m_locked = locked or false and true
    self.mStarView:setVisible(not self.m_locked)
    self.m_boss_zhanji:setVisible(not self.m_locked)
    self.m_locked_bg:setVisible(self.m_locked);
    self.m_boss_locked_tips:setVisible(self.m_locked)
end

ConsoleBossItem.isLocked = function(self)
    return self.m_locked
end

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