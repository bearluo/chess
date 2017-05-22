
require(BASE_PATH.."chessScene");
require("view/selectButton");
require("dialog/progress_dialog");
require("dialog/create_room_dialog");
require("dialog/evaluate_dialog");
require(DATA_PATH .. "dailyTaskData");
ActivityScene = class(ChessScene);

ActivityScene.s_controls = 
{
    back_btn                = 1;   
    --top_view                = 2;
    --teapot_dec              = 3;
    --stone_dec               = 4;
    activity_handler        = 5;
    --daily_task_view         = 6;
    --grow_task_view          = 7;
    --btns_content            = 8;

}

ActivityScene.s_cmds = 
{
    getActionList           = 1;
    updateDailyItemStatus   = 2;
    updateGrowItemStatus    = 3;
}

ActivityScene.SHOW_ACTIVITY = 1;
ActivityScene.SHOW_DAILYTASK = 2;
ActivityScene.SHOW_GROWTASK = 3;
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
        --self.m_title:removeProp(1);
        --self.m_title:removeProp(2);
        --self.m_leaf_right:removeProp(1);
        --self.m_leaf_left:removeProp(1);
        self.m_anim_prop_need_remove = false;
    end
end

function ActivityScene:setAnimItemEnVisible(ret)
    --self.m_leaf_right:setVisible(ret);
    --self.m_leaf_left:setVisible(ret);
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
    --self.m_title:addPropTransparency(2,kAnimNormal,duration,delay,0,1);
    --self.m_title:addPropScale(1,kAnimNormal,duration,delay,0.8,1,0.6,1,kCenterDrawing);
    --local lw,lh = self.m_leaf_left:getSize();
    --self.m_leaf_left:addPropTranslate(1, kAnimNormal, duration, delay, -lw, 0, -10, 0);
    --local rw,rh = self.m_leaf_right:getSize();
    --local anim = self.m_leaf_right:addPropTranslate(1, kAnimNormal, duration, delay, rw, 0, -10, 0);
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

    --local lw,lh = self.m_leaf_left:getSize();
    --self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, -lw, 0, -10);
    --local rw,rh = self.m_leaf_right:getSize();
    --local anim = self.m_leaf_right:addPropTranslate(1, kAnimNormal, waitTime, -1 , 0, rw, 0, -10);
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
    --self.m_top_view = self:findViewById(self.m_ctrls.top_view);
    --self.m_top_title = self.m_top_view:getChildByName("top_title_bg");
    --self.m_leaf_right = self.m_root:getChildByName("leaf_right");
    --self.m_leaf_left = self.m_root:getChildByName("leaf_left");

    --self.m_leaf_left:setFile("common/decoration/left_leaf.png")
    --self.m_leaf_right:setFile("common/decoration/right_leaf.png")

    --self.m_title = self.m_top_title:getChildByName("top_title");

    --self.m_refresh_btn = self.m_top_view:getChildByName("refresh_bg"):getChildByName("refresh_btn");
    --self.m_refresh_btn:setOnClick(self,self.onRefreshView);

    -- 活动相关
    self.m_activity_handler = self:findViewById(self.m_ctrls.activity_handler);
    local w,h = self:getSize();
    local cw,ch = self.m_activity_handler:getSize();
    self.m_activity_handler:setSize(nil,ch+h-System.getLayoutHeight());  
    self.m_activity_scoll_view = new(ScrollView, 0, 0, cw, ch+h-System.getLayoutHeight(), true);
    local sw,sh = self.m_activity_scoll_view:getSize()
    self.m_activity_scoll_view:setPos(40,15)
    self.m_activity_scoll_view:setSize(sw-80,sh-15)
    self.m_activity_handler:addChild(self.m_activity_scoll_view);
    ActivityManager.setMode(kActivityDebug == 1);

end

function ActivityScene:refreshUserInfo()
end

function ActivityScene:onActionBtnClick()
    self:requestCtrlCmd(ActivityController.s_cmds.back_action);
end

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

function ActivityScene:onRefreshView()
    self:requestCtrlCmd(ActivityController.s_cmds.get_activity);
end

---------------------------------config-------------------------------
ActivityScene.s_controlConfig = 
{
	[ActivityScene.s_controls.back_btn]               = {"new_style_view","back_btn"};
    --[ActivityScene.s_controls.top_view]               = {"top_view"};
    --[ActivityScene.s_controls.teapot_dec]             = {"teapot_dec"};
    --[ActivityScene.s_controls.stone_dec]              = {"stone_dec"};
    [ActivityScene.s_controls.activity_handler]       = {"new_style_view","activity_handler"};
    --[ActivityScene.s_controls.daily_task_view]        = {"daily_task_view"};
    --[ActivityScene.s_controls.grow_task_view]         = {"grow_task_view"};
    --[ActivityScene.s_controls.btns_content]           = {"btns_content"};
    
    
};
--定义控件的触摸响应函数
ActivityScene.s_controlFuncMap =
{
	[ActivityScene.s_controls.back_btn]               = ActivityScene.onActionBtnClick;
};

ActivityScene.s_cmdConfig = 
{
    [ActivityScene.s_cmds.getActionList]              = ActivityScene.onGetActionList;

}

ActivityItem = class(Node)

ActivityItem.ctor = function(self,data)
    self:setPos(0,0);
    self:setSize(638,320);
    self:setAlign(kAlignTop)
    self.m_data = data;
    self.mBg = new(Image,"common/background/activity_bg_2.png")
    self.mBg:setAlign(kAlignCenter);
    self.m_btn = new(Button,"common/background/activity_bg.png");
    self.m_icon = new(Mask,"common/background/activity_bg.png","common/background/activity_bg.png");
    self.m_icon:setAlign(kAlignCenter);
    self.m_icon:setSize(630,300);
    self.m_btn:setAlign(kAlignCenter);
    self.m_btn:setSize(630,300);
    local str=self.m_data.img_url;
    self.m_icon:setUrlImage(str);
    self.m_btn:setSrollOnClick();
    self.m_btn:setOnClick(self,self.gotoActivity);
    self:addChild(self.mBg);
    self:addChild(self.m_btn);
    self.m_btn:addChild(self.m_icon);
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