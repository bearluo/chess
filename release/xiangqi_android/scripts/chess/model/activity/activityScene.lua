
require(BASE_PATH.."chessScene");
require("view/selectButton");
require("dialog/progress_dialog");
require("dialog/create_room_dialog");
require(DATA_PATH .. "dailyTaskData");
ActivityScene = class(ChessScene);

ActivityScene.s_controls = 
{
    back_btn                = 1;   
    top_view                = 2;
    teapot_dec              = 3;
    stone_dec               = 4;
    activity_handler        = 5;
    daily_task_view         = 6;
}

ActivityScene.s_cmds = 
{
    getActionList           = 1;
    updateDailyItemStatus   = 2;
}

ActivityScene.SHOW_ACTIVITY = 1;
ActivityScene.SHOW_DAILYTASK = 2;

function ActivityScene:ctor(viewConfig,controller)
	self.m_ctrls = ActivityScene.s_controls;
    self.isShowActivity = controller.m_state.m_show_dailyTask;
    self:initView();
end 

function ActivityScene:resume()
    ChessScene.resume(self);
    self:refreshUserInfo();
end

function ActivityScene:pause()
	ChessScene.pause(self);
    self:removeAnimProp();
    call_native(kActivityWebViewClose);
end 

function ActivityScene:dtor()
    self:removeAnimProp();
    delete(self.anim_end);
    delete(self.anim_timer);
end 

------------------------------anim----------------------------------
function ActivityScene:removeAnimProp()
    if self.m_anim_prop_need_remove then
        self.m_title:removeProp(1);
        self.m_title:removeProp(2);
        self.m_leaf_right:removeProp(1);
        self.m_leaf_left:removeProp(1);
        self.m_anim_prop_need_remove = false;
    end
end

function ActivityScene:setAnimItemEnVisible(ret)
    self.m_leaf_right:setVisible(ret);
    self.m_leaf_left:setVisible(ret);
end

function ActivityScene:resumeAnimStart(lastStateObj,timer,func)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    local duration = timer.waitTime;
    local delay = timer.duration + duration;
    delete(self.anim_timer);
    self.anim_timer = new(AnimInt,kAnimNormal,0,1,delay,-1);
    if self.anim_timer then
        self.anim_timer:setEvent(self,function()
            self:setAnimItemEnVisible(true);
            delete(self.anim_timer);
        end);
    end

    -- 上部动画
    self.m_title:addPropTransparency(2,kAnimNormal,duration,delay,0,1);
    self.m_title:addPropScale(1,kAnimNormal,duration,delay,0.8,1,0.6,1,kCenterDrawing);
    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1, kAnimNormal, duration, delay, -lw, 0, -10, 0);
    local rw,rh = self.m_leaf_right:getSize();
    local anim = self.m_leaf_right:addPropTranslate(1, kAnimNormal, duration, delay, rw, 0, -10, 0);
    if anim then
        anim:setEvent(self,function()
            self.m_anim_prop_need_remove = true;
            self:removeAnimProp();
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end
            delete(anim);
        end);
    end
end

function ActivityScene:pauseAnimStart(newStateObj,timer)
   self.m_anim_prop_need_remove = true;
   self:removeAnimProp();
   local duration = timer.duration;
   local waitTime = timer.waitTime
   local delay = waitTime+duration;

    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, -lw, 0, -10);
    local rw,rh = self.m_leaf_right:getSize();
    local anim = self.m_leaf_right:addPropTranslate(1, kAnimNormal, waitTime, -1 , 0, rw, 0, -10);
    if anim then
        anim:setEvent(self,function()
            self:setAnimItemEnVisible(false);
            delete(anim);
        end);
    end
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
end

------------------------------function------------------------------

function ActivityScene:initView()
    self.m_top_view = self:findViewById(self.m_ctrls.top_view);
    self.m_top_title = self.m_top_view:getChildByName("top_title_bg");
    self.m_leaf_right = self.m_root:getChildByName("leaf_right");
    self.m_leaf_left = self.m_root:getChildByName("leaf_left");

    self.m_title = self.m_top_title:getChildByName("top_title");
    self.m_activity_btn = self.m_top_title:getChildByName("activity_btn");
    self.m_activity_btn:setOnClick(self,self.showActivity);
    self.m_daily_task_btn = self.m_top_title:getChildByName("daily_task_btn");
    self.m_daily_task_btn:setOnClick(self,self.showDailyTask);

    self.m_refresh_btn = self.m_top_view:getChildByName("refresh_btn");
    self.m_refresh_btn:setOnClick(self,self.onRefreshView);

    --活动相关
    self.m_activity_handler = self:findViewById(self.m_ctrls.activity_handler);
    local w,h = self:getSize();
    local cw,ch = self.m_activity_handler:getSize();
    self.m_activity_handler:setSize(nil,ch+h-System.getLayoutHeight());  
    self.m_activity_scoll_view = new(ScrollView, 0, 0, cw, ch+h-System.getLayoutHeight(), true);
    self.m_activity_handler:addChild(self.m_activity_scoll_view);
    ActivityManager.setMode(kActivityDebug == 1);

    --每日任务
    self.m_daily_task_view = self:findViewById(self.m_ctrls.daily_task_view);


    if self.isShowActivity then
        self:showActivity(); 
    else
        self:showDailyTask();
    end
end

function ActivityScene:refreshUserInfo()
end

function ActivityScene:onActionBtnClick()
    self:requestCtrlCmd(ActivityController.s_cmds.back_action);
end;

function ActivityScene:onGetActionList(tab)
    self.m_activity_scoll_view:removeAllChildren(true);
    if not tab or type(tab) ~= "table" or #tab == 0 then 
        self.m_activity_handler:getChildByName("no_activity"):setVisible(true);
        return ;
    end
    self.m_activity_handler:getChildByName("no_activity"):setVisible(false);

    for _,data in pairs(tab) do
        local act = new(ActivityItem,data);
        self.m_activity_scoll_view:addChild(act);
    end
end

function ActivityScene:updateDailyItemStatus(index,data)
    if not index or not data then return end
    if self.m_daily_adapter and self.m_daily_task_list then
        self.m_daily_adapter:updateData(index,data);
    end
end


function ActivityScene:showDailyTask()
    self.showStatus = ActivityScene.SHOW_DAILYTASK;
    self:setBtnStatus(self.showStatus);
    if self.m_daily_task_view:getVisible() then
        return
    end
    local label = true;
    self.m_daily_task_view:setVisible(label);
    self.m_activity_handler:setVisible(not label);
    self:createDailyTaskList();
end

function ActivityScene:showActivity()
    self.showStatus = ActivityScene.SHOW_ACTIVITY;
    self:setBtnStatus(self.showStatus);
    if self.m_activity_handler:getVisible() then
        return
    end
    local label = true;
    self.m_daily_task_view:setVisible(not label);
    self.m_activity_handler:setVisible(label);
end

function ActivityScene:createDailyTaskList()
    DailyTaskManager.getInstance():sendGetNewDailyTaskList();
    if self.m_daily_adapter then
        self.m_daily_task_view:removeChild(self.m_daily_task_list,true);
        delete(self.m_daily_adapter);
        delete(self.m_daily_task_list);
        self.m_daily_adapter = nil;
        self.m_daily_task_list = nil;
    end

    local datas = DailyTaskData.getInstance():getDailyTaskData();
    if not datas or type(datas) ~= "table" then return end
    self.m_daily_adapter = new(CacheAdapter,NewDailyItem,datas);
    local dw,dh = self.m_daily_task_view:getSize();
    self.m_daily_task_list = new(ListView,0, 0, dw, dh);
    self.m_daily_task_list:setAdapter(self.m_daily_adapter);
    self.m_daily_task_view:addChild(self.m_daily_task_list);
end

function ActivityScene:onRefreshView()
    if self.showStatus == ActivityScene.SHOW_ACTIVITY then
        self:requestCtrlCmd(ActivityController.s_cmds.get_activity);
    elseif self.showStatus == ActivityScene.SHOW_DAILYTASK then
        self:createDailyTaskList();
    end
end

--[[
    修改顶部btn可选择状态
--]]
function ActivityScene:setBtnStatus(status)
    if status == ActivityScene.SHOW_DAILYTASK then
        self.m_activity_btn:setEnable(true);
        self.m_daily_task_btn:setEnable(false);
    elseif status == ActivityScene.SHOW_ACTIVITY then
        self.m_activity_btn:setEnable(false);
        self.m_daily_task_btn:setEnable(true);
    end
end

---------------------------------config-------------------------------
ActivityScene.s_controlConfig = 
{
	[ActivityScene.s_controls.back_btn]               = {"back_btn"};
    [ActivityScene.s_controls.top_view]               = {"top_view"};
    [ActivityScene.s_controls.teapot_dec]             = {"teapot_dec"};
    [ActivityScene.s_controls.stone_dec]              = {"stone_dec"};
    [ActivityScene.s_controls.activity_handler]       = {"activity_handler"};
    [ActivityScene.s_controls.daily_task_view]        = {"daily_task_view"};
    
};
--定义控件的触摸响应函数
ActivityScene.s_controlFuncMap =
{
	[ActivityScene.s_controls.back_btn]               = ActivityScene.onActionBtnClick;
};

ActivityScene.s_cmdConfig = 
{
    [ActivityScene.s_cmds.getActionList]              = ActivityScene.onGetActionList;
    [ActivityScene.s_cmds.updateDailyItemStatus]      = ActivityScene.updateDailyItemStatus;

}

ActivityItem = class(Node)

ActivityItem.ctor = function(self,data)
    self:setPos(0,0);
    self:setSize(630,320);
    self.m_data = data;
    self.m_btn = new(Button,"common/background/activity_bg.png");
    self.m_btn:setAlign(kAlignCenter);
    self.m_btn:setSize(630,300);
    local str=self.m_data.img_url;
    self.m_btn:setUrlImage(str);
    self.m_btn:setSrollOnClick();
    self.m_btn:setOnClick(self,self.gotoActivity);
    self:addChild(self.m_btn);
end

ActivityItem.gotoActivity = function(self)
    self:showNativeListWebView(self.m_data.info_url);
end

ActivityItem.showNativeListWebView = function(self,url)
    local absoluteX,absoluteY = 0,0;
    local x = absoluteX*System.getLayoutScale();
    local y = absoluteY*System.getLayoutScale();
    local width = System.getScreenWidth();
    local height = System.getScreenHeight();
    NativeEvent.getInstance():showActivityWebView(x,y,width,height,url);
end

----------每日任务node--------------
require(DATA_PATH .. "dailyTaskData")

NewDailyItem = class(Node)
NewDailyItem.s_w = 650;
NewDailyItem.s_h = 128;

NewDailyItem.s_icon = {
    "dailytask/commit_userinfo_icon.png",
    "dailytask/daily_sign_icon.png",
    "dailytask/endgate_icon.png",
    "dailytask/online_game_icon.png",
    "dailytask/up_user_icon.png",
};

NewDailyItem.idToIcon = {
    [1] = "dailytask/endgate_icon.png";
    [2] = "dailytask/online_game_icon.png";
    [3] = "dailytask/daily_sign_icon.png";
    [4] = "dailytask/daily_sign_icon.png";
    [8] = "dailytask/up_user_icon.png";
    [9] = "dailytask/commit_userinfo_icon.png";
    [10] = "dailytask/up_user_icon.png";
}

function NewDailyItem:ctor(data)
    self.m_data = data;
    if not data then return ; end
    self:setSize(NewDailyItem.s_w,NewDailyItem.s_h);
    self.m_bg = new(Image,"drawable/blank.png");
    self.m_bg:setSize(620,100);
    self.m_bg:setAlign(kAlignCenter);
    self:addChild(self.m_bg);

    self.m_bottom_line = new(Image,"common/decoration/line_2.png");
    self.m_bottom_line:setAlign(kAlignBottom);
    self.m_bottom_line:setSize(620,2);
    self:addChild(self.m_bottom_line);

    self.m_icon = new(Image,NewDailyItem.idToIcon[data.id] or "dailytask/daily_sign_icon.png");
    self.m_icon:setAlign(kAlignLeft);
    self.m_icon:setPos(15);
    self.m_bg:addChild(self.m_icon);

    local sx = 42 + self.m_icon:getSize(); 
    local sy = 15;


    self.m_title = new(Text,data.name,nil, nil, nil, nil, 32, 80, 80, 80);
    self.m_progress = new(Text,string.format("(%d/%d)",data.progress or 0,data.num or 0),nil, nil, nil, nil, 32, 80, 80, 80);

    if data.show_progress == 0 then
        self.m_progress:setVisible(false);
    end
    self.m_contentTextTitle = new(Text,"奖励:",nil, nil, nil, nil, 28, 80, 80, 80);
    self.m_contentText = new(Text,data.tip_text,nil, nil, nil, nil, 28, 125, 80, 65);

    self.m_title:setPos(sx,sy);
    
    local ssx = self.m_title:getPos() + self.m_title:getSize();

    self.m_progress:setPos(ssx+5,sy);

    sy = sy + 39;

    self.m_contentTextTitle:setPos(sx,sy);

    sx = sx + self.m_contentTextTitle:getSize();

    self.m_contentText:setPos(sx,sy);

    self.m_btn = new(Button,"common/button/dialog_btn_7_normal.png");
    self.m_text = new(Text,"挑战",nil, nil, nil, nil, 32, 255, 255, 255);
    self.m_text:setAlign(kAlignCenter);
    self.m_btn:addChild(self.m_text);
    
    if data.status == 1 then
        self.m_btn:setFile("common/button/dialog_btn_3_normal.png");
        self.m_text:setText("领取");
    elseif data.status == 2 then
        self.m_btn:setFile("common/button/dialog_btn_9.png");
        self.m_text:setText("已领取");
        self.m_btn:setEnable(false);
    end

    if data.status == 0 and  tonumber(data.jump) == 0 then
        self.m_btn:setFile("common/button/dialog_btn_9.png");
        self.m_text:setText("挑战");
        self.m_btn:setEnable(false);
    end

    self.m_btn:setAlign(kAlignRight);
    self.m_btn:setPos(15);
    self.m_btn:setOnClick(self,self.onBtnClick);
    
    self.m_bg:addChild(self.m_title);
    self.m_bg:addChild(self.m_contentTextTitle);
    self.m_bg:addChild(self.m_contentText);
    self.m_bg:addChild(self.m_btn)
    self.m_bg:addChild(self.m_progress);

end

function NewDailyItem:setOnBtnClick(obj,func)
    self.m_btn_obj = obj;
    self.m_btn_func = func;
end

function NewDailyItem:onBtnClick()
    if self.m_btn_func then
        self.m_btn_func(self.m_btn_obj,self.m_data);
    end
--    if self.m_data.id == 3 or 
    if self.m_data.status == 0 and tonumber(self.m_data.jump)~= 0 then 
        ChessDialogManager.dismissDialog();
        if self.m_data.id == 8 then
            require(MODEL_PATH.."userInfo/userInfoScene");
            UserInfoScene.isShowBangdinDialog = true;
        end
        StateMachine.getInstance():pushState(tonumber(self.m_data.jump),StateMachine.STYPE_CUSTOM_WAIT);
    elseif self.m_data.status == 1 then
        local tips = "领取中...";
--        local post_data = {};
--        post_data.task_id = self.m_data.id;
        DailyTaskManager.getInstance():sendGetNewDailyReward(self.m_data.id,tips)
--        HttpModule.getInstance():execute(HttpModule.s_cmds.GetNewDailyReward,post_data,tips);
    end
end