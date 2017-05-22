
require(BASE_PATH.."chessScene");
require("view/selectButton");
require("dialog/progress_dialog");
require("dialog/create_room_dialog");
require("dialog/evaluate_dialog");
require(DATA_PATH .. "dailyTaskData");
TaskScene = class(ChessScene);

TaskScene.s_controls = 
{
    back_btn                = 1;   
    daily_task_view         = 2;
    grow_task_view          = 3;
    btns_content            = 4;
    task_content_view =5;
    switch_task_radio_btn= 6;
    bottom_btn = 7;
}

TaskScene.s_cmds = 
{
    updateDailyItemStatus   = 1;
    updateGrowItemStatus    = 2;
    refreshView             = 3;
}

TaskScene.SHOW_DAILYTASK = 2;
TaskScene.SHOW_GROWTASK = 3;
function TaskScene:ctor(viewConfig,controller)
	self.m_ctrls = TaskScene.s_controls;
    self:initView();
end 

function TaskScene:resume()
    ChessScene.resume(self);
    self:refreshUserInfo();
    self:updataSelectState()
end

function TaskScene:pause()
	ChessScene.pause(self);
    self:removeAnimProp();
    call_native(kActivityWebViewClose);
end 

function TaskScene:dtor()
    self:removeAnimProp();
    delete(self.anim_end);
    delete(self.anim_timer);
    delete(self.mMoveAnim)
    delete(TaskScene.s_relationshipDialog)
    delete(TaskScene.s_replay_dialog)
end 

------------------------------anim----------------------------------
function TaskScene:removeAnimProp()
    if self.m_anim_prop_need_remove then
        --self.m_title:removeProp(1);
        --self.m_title:removeProp(2);
        --self.m_leaf_right:removeProp(1);
        --self.m_leaf_left:removeProp(1);
        self.m_anim_prop_need_remove = false;
    end
end

function TaskScene:setAnimItemEnVisible(ret)
    --self.m_leaf_right:setVisible(ret);
    --self.m_leaf_left:setVisible(ret);
end

function TaskScene:resumeAnimStart(lastStateObj,timer,func)
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

function TaskScene:pauseAnimStart(newStateObj,timer)
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

function TaskScene:initView()
    --self.m_top_view = self:findViewById(self.m_ctrls.top_view);
    --self.m_top_title = self.m_top_view:getChildByName("top_title_bg");
    --self.m_leaf_right = self.m_root:getChildByName("leaf_right");
    --self.m_leaf_left = self.m_root:getChildByName("leaf_left");

    --self.m_leaf_left:setFile("common/decoration/left_leaf.png")
    --self.m_leaf_right:setFile("common/decoration/right_leaf.png")

    --self.m_title = self.m_top_title:getChildByName("top_title");

    self.m_switch_task_radio_btn = self:findViewById(self.m_ctrls.switch_task_radio_btn);
    self.m_task_content_view = self:findViewById(self.m_ctrls.task_content_view)

    local w,h = self:getSize()
    --处理返回上一层界面时，屏幕外的界面在滑动的过程中被显示的问题
    self.m_root:setClip(0,0,w,h)
    self.mMoveW = w
    local cw,ch = self.m_task_content_view:getSize()
    self.m_task_content_view:setSize(nil,ch+h-System.getLayoutHeight())
    -- daily_btn(daily_task_btn)
    --[[
    self.m_daily_task_btn = self.m_btns_content:getChildByName("daily"):getChildByName("btn");
    self.m_daily_task_btn:setOnClick(self,self.showDailyTask);
    self.m_daily_task_btn_txt = self.m_daily_task_btn:getChildByName("btn_txt");
    self.m_daily_task_btn_txt:setColor(135,100,95);
    self.m_daily_task_hint = self.m_daily_task_btn:getChildByName("hint");
    self.m_daily_task_btn_line = self.m_btns_content:getChildByName("daily"):getChildByName("select_line");
    -- grow_btn(grow_task_btn)
    self.m_grow_task_btn = self.m_btns_content:getChildByName("grow"):getChildByName("btn");
    self.m_grow_task_btn:setOnClick(self,self.showGrowTask);
    self.m_grow_task_btn_txt = self.m_grow_task_btn:getChildByName("btn_txt");
    self.m_grow_task_btn_txt:setColor(135,100,95);
    self.m_grow_task_hint = self.m_grow_task_btn:getChildByName("hint");
    self.m_grow_task_btn_line = self.m_btns_content:getChildByName("grow"):getChildByName("select_line");    
  ]]--
    --self.m_refresh_btn = self.m_top_view:getChildByName("refresh_bg"):getChildByName("refresh_btn");
    --self.m_refresh_btn:setOnClick(self,self.onRefreshView);
    self.m_daily_select_btn = new(RadioButton,{"drawable/blank.png","common/button/tab_btn.png"})
	self.m_grow_select_btn = new(RadioButton,{"drawable/blank.png","common/button/tab_btn.png"})
    self.m_daily_select_btn:setAlign(kAlignLeft)
    self.m_grow_select_btn:setAlign(kAlignRight)
    self.m_daily_select_btn:setSize(332,74)
    self.m_grow_select_btn:setSize(332,74)
    self.m_daily_select_btn_txt = new(Text,"日常任务", width, height, align, fontName, 32, 255, 255, 255)
    self.m_grow_select_btn_txt = new(Text,"成长任务", width, height, align, fontName, 32, 255, 255, 255)
    self.m_daily_select_btn_txt:setAlign(kAlignCenter)
    self.m_grow_select_btn_txt:setAlign(kAlignCenter)
    self.m_daily_select_btn:addChild(self.m_daily_select_btn_txt)
    self.m_grow_select_btn:addChild(self.m_grow_select_btn_txt)

    self.m_switch_task_radio_btn:addChild(self.m_grow_select_btn);
    self.m_switch_task_radio_btn:addChild(self.m_daily_select_btn);

     self.m_switch_task_radio_btn:setOnChange(self,self.updataSelectState);
    -- 每日任务
    self.m_daily_task_view = self:findViewById(self.m_ctrls.daily_task_view);
    --self.m_daily_task_view:setPos(0,nil)
    -- 成长任务
    self.m_grow_task_view = self:findViewById(self.m_ctrls.grow_task_view);
    self.m_grow_task_view:setPos(self.mMoveW,nil)
    --self.m_daily_task_hint:setVisible(DailyTaskData.getInstance():getCompleteStatus());
    self.m_daily_select_btn:setChecked(true)
    
    --DailyTaskManager.getInstance():sendGetGrowTaskList();
    --self:showDailyTask()
end

function TaskScene:refreshUserInfo()
end

function TaskScene:onActionBtnClick()
    DailyTaskManager.getInstance():sendGetGrowTaskList();
    DailyTaskManager.getInstance():sendGetNewDailyTaskList();
    self:requestCtrlCmd(TaskController.s_cmds.back_action);
end

function TaskScene.onBottomBtnClick(self)
    DailyTaskManager:getInstance():sendGetAllTaskReward("领取中...",false)
end 

function TaskScene:updateDailyItemStatus(index,data,dataType)
    --self.m_daily_task_hint:setVisible(DailyTaskData.getInstance():getCompleteStatus());
    if not index or not data then -- 内容为nil的广播，新建列表
        self:createDailyTaskList();
    else
        if dataType and tonumber(dataType) ~= 1 then return end;
        if self.m_daily_adapter and self.m_daily_task_list then
            self.m_daily_adapter:updateData(index,data);
        end     
--        if kPlatform == kPlatformIOS then
--            if tonumber(UserInfo.getInstance():getIosAuditStatus()) == 0 then return end;
--            local lastShowDlgTime = GameCacheData.getInstance():getInt(GameCacheData.LAST_SHOWEVADLG_TIME,0);-- 上次显示的时间
--            local isSevenDay = ToolKit.isSevenDay(lastShowDlgTime);-- 是否隔周
--            if not isSevenDay then return end;
--            if not self.m_evaluate_dialog then
--                self.m_evaluate_dialog = new(EvaluateDialog);
--            end;
--            self.m_evaluate_dialog:show();
--            GameCacheData.getInstance():saveInt(GameCacheData.LAST_SHOWEVADLG_TIME,os.time());
--        end;

        if kPlatform == kPlatformIOS then
            if tonumber(UserInfo.getInstance():getIosAuditStatus()) == 0 then return end;
            if tonumber(UserInfo.getInstance():getCanShowIOSAppstoreReview()) == 0 then return end;

            UserInfo.getInstance():setCanShowIOSAppstoreReview(0);
            require(DIALOG_PATH .. "ios_review_dialog_view");
            if not self.reviewDialog then
                self.reviewDialog = new(ReviewDialogView);
            end
            self.reviewDialog:show();
        end

    end
end


function TaskScene:updateGrowItemStatus(index,data,dataType)
    --self.m_grow_task_hint:setVisible(DailyTaskData.getInstance():getGrowTaskCompleteStatus());
    if not index or not data then -- 内容为nil的广播，新建列表
        self:createGrowTaskList();
    else
        if dataType and tonumber(dataType) ~= 0 then return end;
        if self.m_grow_adapter and self.m_grow_task_list then
            self.m_grow_adapter:updateData(index,data);
        end     
    end
end
--展示日常任务
function TaskScene:showDailyTask()
    self.showStatus = TaskScene.SHOW_DAILYTASK;
    self:setBtnStatus(self.showStatus);
    if self.m_daily_task_view:getVisible() then
        return
    end
    self.m_daily_task_hint:setVisible(DailyTaskData.getInstance():getCompleteStatus());
    local label = true;
    self.m_daily_task_view:setVisible(label);
    self.m_grow_task_view:setVisible(not label);
    DailyTaskManager.getInstance():sendGetNewDailyTaskList();
--    self:createDailyTaskList(); -- 上面拉取任务列表成功后会广播创建任务列表事件
end
--展示成长任务
function TaskScene:showGrowTask()
    self.showStatus = TaskScene.SHOW_GROWTASK;
    self:setBtnStatus(self.showStatus);
    if self.m_grow_task_view:getVisible() then
        return
    end
    self.m_grow_task_hint:setVisible(DailyTaskData.getInstance():getGrowTaskCompleteStatus());
    local label = true;
    self.m_daily_task_view:setVisible(not label);
    self.m_grow_task_view:setVisible(label);
    DailyTaskManager.getInstance():sendGetGrowTaskList();
--    self:createGrowTaskList(); -- 上面拉取任务列表成功后会广播创建任务列表事件
end;

function TaskScene:createDailyTaskList()
    if self.m_daily_adapter then
        self.m_daily_task_view:removeChild(self.m_daily_task_list,true);
        delete(self.m_daily_adapter);
        delete(self.m_daily_task_list);
        self.m_daily_adapter = nil;
        self.m_daily_task_list = nil;
    end
    local datas = DailyTaskData.getInstance():getDailyTaskData();
    if not datas or not next(datas) or type(datas) ~= "table" then return end
    self.m_daily_adapter = new(CacheAdapter,DailyTaskNewItem,datas);
    local dw,dh = self.m_daily_task_view:getSize();
    self.m_daily_task_list = new(ListView,0, 0, dw, dh);
    self.m_daily_task_list:setAdapter(self.m_daily_adapter);
    self.m_daily_task_view:addChild(self.m_daily_task_list);
end

function TaskScene:createGrowTaskList()
    if self.m_grow_adapter then
        self.m_grow_task_view:removeChild(self.m_grow_task_list,true);
        delete(self.m_grow_adapter);
        delete(self.m_grow_task_list);
        self.m_grow_adapter = nil;
        self.m_grow_task_list = nil;
    end
    local datas = DailyTaskData.getInstance():getGrowTaskData();
    if not datas or not next(datas) or type(datas) ~= "table" then return end
    self.m_grow_adapter = new(CacheAdapter,GrowTaskNewItem,datas);
    local dw,dh = self.m_grow_task_view:getSize();
    self.m_grow_task_list = new(ListView,0, 0, dw, dh);
    self.m_grow_task_list:setAdapter(self.m_grow_adapter);
    self.m_grow_task_view:addChild(self.m_grow_task_list);
end

function TaskScene:onRefreshView()
    if self.showStatus == TaskScene.SHOW_DAILYTASK then
        DailyTaskManager.getInstance():sendGetNewDailyTaskList();
        self:createDailyTaskList();
    elseif self.showStatus == TaskScene.SHOW_GROWTASK then
        DailyTaskManager.getInstance():sendGetGrowTaskList();
        self:createGrowTaskList();
    end
end

--[[
    修改顶部btn可选择状态
--]]
function TaskScene:setBtnStatus(status)
    if status == TaskScene.SHOW_DAILYTASK then
        self.m_daily_task_btn_txt:setColor(215,75,45);
        self.m_grow_task_btn_txt:setColor(135,100,95);
        self.m_daily_task_btn_line:setVisible(true);
        self.m_grow_task_btn_line:setVisible(false);
    elseif status == TaskScene.SHOW_GROWTASK then
        self.m_daily_task_btn_txt:setColor(135,100,95);
        self.m_grow_task_btn_txt:setColor(215,75,45);
        self.m_daily_task_btn_line:setVisible(false);
        self.m_grow_task_btn_line:setVisible(true);        
    end
end

function TaskScene.s_showRelationshipDialog()
    delete(TaskScene.s_relationshipDialog);
    TaskScene.s_relationshipDialog = new(RelationshipDialog)
    TaskScene.s_relationshipDialog:showFollowView()
    TaskScene.s_relationshipDialog:show()
end

function TaskScene.s_showReplayDialog()
    delete(TaskScene.s_replay_dialog);
    TaskScene.s_replay_dialog = new(ReplayDialog);
    TaskScene.s_replay_dialog:show();
end

TaskScene.updataSelectState = function(self)
    --self.m_daily_task_view:setVisible(true)
    --self.m_grow_task_view:setVisible(true)
    if self.m_daily_select_btn:isChecked() then
        self.m_daily_select_btn_txt:setColor(115,65,35)
        self:startMoveAnim(0)
        if not self.m_daily_adapter then
            DailyTaskManager.getInstance():sendGetNewDailyTaskList();
        end
    else
        self.m_daily_select_btn_txt:setColor(170,135,100)
    end
    
    if self.m_grow_select_btn:isChecked() then
        self.m_grow_select_btn_txt:setColor(115,65,35)
        self:startMoveAnim(-self.mMoveW)
        if not self.m_grow_adapter then
            DailyTaskManager.getInstance():sendGetGrowTaskList();
            return
        end
    else
        self.m_grow_select_btn_txt:setColor(170,135,100)
    end
end

function TaskScene:startMoveAnim(target)
    self:stopMoveAnim()
    target = tonumber(target) or 0
    self.mMoveAnim = AnimFactory.createAnimInt(kAnimLoop, 0, 1, 1000/60, -1)
    local x,y = self.m_task_content_view:getPos()
    local offset = target - x
    self.mMoveAnim:setEvent(self,function()
        local move = offset * 0.2
        offset = offset - move
        local x,y = self.m_task_content_view:getPos()
        if math.abs(offset) < 10 then
            self.m_task_content_view:setPos(target)
            self:stopMoveAnim()
        else
            self.m_task_content_view:setPos(x+move)
        end
    end)
end

function TaskScene:stopMoveAnim()
    delete(self.mMoveAnim)
end
---------------------------------config-------------------------------
TaskScene.s_controlConfig = 
{
	[TaskScene.s_controls.back_btn]               = {"new_style_view","back_btn"};
    --[TaskScene.s_controls.top_view]               = {"top_view"};
    --[TaskScene.s_controls.teapot_dec]             = {"teapot_dec"};
    --[TaskScene.s_controls.stone_dec]              = {"stone_dec"};
    --[TaskScene.s_controls.activity_handler]       = {"activity_handler"};
    [TaskScene.s_controls.bottom_btn] = {"new_style_view","bottom_btn"};
    [TaskScene.s_controls.daily_task_view]        = {"new_style_view","content_view","task_content_view","daily_task_view"};
    [TaskScene.s_controls.grow_task_view]         = {"new_style_view","content_view","task_content_view","grow_task_view"};
    --[TaskScene.s_controls.btns_content]           = {"new_style_view","btns_content"};
    [TaskScene.s_controls.switch_task_radio_btn] = {"new_style_view","content_view","switch_img","switch_task_radio_btn"};
    [TaskScene.s_controls.task_content_view] = {"new_style_view","content_view","task_content_view"};
};
--定义控件的触摸响应函数
TaskScene.s_controlFuncMap =
{
	[TaskScene.s_controls.back_btn]               = TaskScene.onActionBtnClick;
    [TaskScene.s_controls.bottom_btn] = TaskScene.onBottomBtnClick;
};

TaskScene.s_cmdConfig = 
{
    [TaskScene.s_cmds.updateDailyItemStatus]      = TaskScene.updateDailyItemStatus;
    [TaskScene.s_cmds.updateGrowItemStatus]       = TaskScene.updateGrowItemStatus;
    [TaskScene.s_cmds.refreshView]                = TaskScene.onRefreshView;
    
}

----------每日任务node--------------
require(DATA_PATH .. "dailyTaskData")

NewDailyItem = class(Node)
NewDailyItem.s_w = 650;
NewDailyItem.s_h = 128;

NewDailyItem.idToIcon = {
    [1] = "dailytask/endgate_icon.png";
    [2] = "dailytask/online_game_icon.png";
    [3] = "dailytask/daily_sign_icon.png";
    [4] = "dailytask/daily_sign_icon.png";
    [8] = "dailytask/share_icon.png";
    [9] = "dailytask/daily_sign_icon.png";
    [10] = "dailytask/save_icon.png";
    [11] = "dailytask/share_icon.png";
    [14] = "dailytask/commit_userinfo_icon.png";
    [15] = "dailytask/online_game_icon.png";
    [16] = "dailytask/online_game_icon.png";
    [17] = "dailytask/friends_icon.png";
}

function NewDailyItem:ctor(data)
    if not data then return ; end
    self.m_data = data;
    self:setSize(NewDailyItem.s_w,NewDailyItem.s_h);
    self.m_bg = new(Image,"drawable/blank.png");
    self.m_bg:setSize(620,100);
    self.m_bg:setAlign(kAlignCenter);
    self:addChild(self.m_bg);

    self.m_bottom_line = new(Image,"common/decoration/line_2.png");
    self.m_bottom_line:setAlign(kAlignBottom);
    self.m_bottom_line:setSize(620,2);
    self.m_bottom_line:setTransparency(0.6);
    self:addChild(self.m_bottom_line);

    self.m_icon = new(Image,NewDailyItem.idToIcon[tonumber(data.type)] or "dailytask/online_game_icon.png");
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
    
    if tonumber(data.status) == 1 then
        self.m_btn:setFile("common/button/dialog_btn_3_normal.png");
        self.m_text:setText("领取");
    elseif tonumber(data.status) == 2 then
        self.m_btn:setFile("common/button/dialog_btn_9.png");
        self.m_text:setText("已领取");
        self.m_btn:setEnable(false);
    end

    if tonumber(data.status) == 0 and  tonumber(data.jump) == 0 then
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
        if self.m_data.id == 17 then
            local data = {};
            local vipType = 2321;
            if kPlatform == kPlatformIOS then
                vipType = 2324;
                data = MallData.getInstance():getPropById(vipType)
            else
                vipType = 2321;
                data = MallData.getInstance():getGoodsById(vipType)
            end
            if next(data) ~= nil then
                if kPlatform == kPlatformIOS then
                    TaskScene.m_PayInterface = PayUtil.getPayInstance(PayUtil.s_payType.Exchange);
		            data.position = data.id;
		            TaskScene.m_pay_dialog = TaskScene.m_PayInterface:buy(data,data.position);
                else
                    local payData = {}
                    payData.pay_scene = PayUtil.s_pay_scene.default_recommend
                    TaskScene.m_PayInterface = PayUtil.getPayInstance(PayUtil.s_defaultType);
		            data.position = MALL_COINS_GOODS;
		            TaskScene.m_pay_dialog = TaskScene.m_PayInterface:buy(data,payData);
                end
                return
            end
        end
        if tonumber(self.m_data.jump) == States.Online or 
           tonumber(self.m_data.jump) == States.OnlineRoom or 
           tonumber(self.m_data.jump) == States.Comment or 
           tonumber(self.m_data.jump) == States.Compete or
           tonumber(self.m_data.jump) == States.PrivateHall then
            if UserInfo.getInstance():isFreezeUser() then return end;
        end;
        if tonumber(self.m_data.jump) == States.Friends then
            TaskScene.s_showRelationshipDialog()
            return
        elseif tonumber(self.m_data.jump) == States.Replay then
            TaskScene.s_showReplayDialog()
            return
        end
        StateMachine.getInstance():pushState(tonumber(self.m_data.jump),StateMachine.STYPE_CUSTOM_WAIT);
    elseif self.m_data.status == 1 then
        local tips = "领取中...";
        DailyTaskManager.getInstance():sendGetNewDailyReward(self.m_data.id,tips,false)
    end
end


----------成长任务node--------------
require(DATA_PATH .. "dailyTaskData")

GrowTaskItem = class(Node)
GrowTaskItem.s_w = 650;
GrowTaskItem.s_h = 156;

-- 目前php系列任务到114;2016/09/18
GrowTaskItem.idToIcon = {
    [101]  = "dailytask/up_user_icon.png";
    [102]  = "dailytask/online_game_icon.png";
    [103]  = "dailytask/online_game_icon.png";
    [104]  = "dailytask/console_icon.png";
    [105]  = "dailytask/endgate_icon.png";
    [106]  = "dailytask/save_icon.png";
    [107]  = "dailytask/friends_icon.png";
    [108]  = "dailytask/share_icon.png";
    [109]  = "dailytask/friends_icon.png";
    [110]  = "dailytask/commit_userinfo_icon.png";
    [111]  = "dailytask/commit_userinfo_icon.png";
    [112]  = "dailytask/fight_icon.png";
    [113]  = "dailytask/fight_icon.png";
    [114]  = "dailytask/friends_icon.png";
    [115]  = "dailytask/online_game_icon.png";
    [120]  = "dailytask/endgate_icon.png";
}

function GrowTaskItem:ctor(data)
    if not data then return ; end
    self.m_data = data;
    self:setSize(GrowTaskItem.s_w,GrowTaskItem.s_h);
    self.m_bg = new(Image,"drawable/blank.png");
    self.m_bg:setSize(620,156);
    self.m_bg:setAlign(kAlignCenter);
    self:addChild(self.m_bg);

    self.m_bottom_line = new(Image,"common/decoration/line_2.png");
    self.m_bottom_line:setAlign(kAlignBottom);
    self.m_bottom_line:setSize(620,2);
    self.m_bottom_line:setTransparency(0.6);
    self:addChild(self.m_bottom_line);

    self.m_icon = new(Image,GrowTaskItem.idToIcon[tonumber(data.series_id)] or "dailytask/online_game_icon.png");
    self.m_icon:setAlign(kAlignLeft);
    self.m_bg:addChild(self.m_icon);

    local sx = 22 + self.m_icon:getSize(); 
    local sy = 20;

    self.m_title = new(Text,data.name,nil, nil, nil, nil, 32, 80, 80, 80);
--    self.m_progress = new(Text,"",nil, nil, nil, nil, 32, 80, 80, 80);
--    self:setProgress();

    self.m_title:setPos(sx,sy);
    
    local ssx = self.m_title:getPos() + self.m_title:getSize();

--    self.m_progress:setPos(ssx+5,sy);

    sy = sy + 44;

    self.m_progressbar_title = new(Text,"进度:",nil, nil, nil, nil, 28, 80, 80, 80);
    self.m_progressbar_title:setPos(sx, sy);

    self.m_progressbar_bg = new(Image,"dailytask/progressbar_bg.png",nil,nil,20,20,14,14);
    self.m_progressbar_bg:setSize(200,34);
    self.m_progressbar_bg:setPos(sx + 70,sy);
    self.m_progressbar_img = new(Image,"dailytask/progressbar_img.png",nil,nil,7,7,14,14);
    self.m_progressbar_img:setAlign(kAlignLeft);
    self.m_progressbar_img:setPos(12,0);
    self.m_progressbar_bg:addChild(self.m_progressbar_img);
    self.m_progressbar_txt = new(Text,"",nil, nil, kAlignCenter, nil, 28, 235, 225, 190);
    self.m_progressbar_txt:setPos(nil,-2);
    self.m_progressbar_txt:setAlign(kAlignCenter);
    self.m_progressbar_bg:addChild(self.m_progressbar_txt);  
    self:setRateBar();

    sy = sy + 44;
    self.m_contentTextTitle = new(Text,"奖励:",nil, nil, nil, nil, 28, 80, 80, 80);
    self.m_contentText = new(Text,"",nil, nil, nil, nil, 28, 125, 80, 65);
    self.m_contentTextTitle:setPos(sx,sy);
    self:setContentText();

    sx = sx + self.m_contentTextTitle:getSize();
    
    self.m_contentText:setPos(sx,sy);

    self.m_btn = new(Button,"common/button/dialog_btn_7_normal.png");
    self.m_text = new(Text,"挑战",nil, nil, nil, nil, 32, 255, 255, 255);
    self.m_text:setAlign(kAlignCenter);
    self.m_btn:addChild(self.m_text);
    self:setBtnStatus();


    self.m_btn:setAlign(kAlignRight);
    self.m_btn:setPos(15);
    self.m_btn:setOnClick(self,self.onBtnClick);
    
    self.m_bg:addChild(self.m_title);
    self.m_bg:addChild(self.m_contentTextTitle);
    self.m_bg:addChild(self.m_contentText);
    self.m_bg:addChild(self.m_btn)
--    self.m_bg:addChild(self.m_progress);
    self.m_bg:addChild(self.m_progressbar_title);
    self.m_bg:addChild(self.m_progressbar_bg);
end

function GrowTaskItem:dtor()

end;

function GrowTaskItem:setProgress()
    self.m_progress:setText(string.format("(%d/%d)",self.m_data.progress or 0,self.m_data.reach_num or 0));
end;

function GrowTaskItem:setRateBar()
    local rate = (tonumber(self.m_data.progress) or 0)/(tonumber(self.m_data.reach_num) or 1);
    if rate > 1 then rate = 1 end;
--    self.m_progressbar_txt:setText(math.floor(rate * 100).."%");
    self.m_progressbar_txt:setText(string.format("%d/%d",self.m_data.progress or 0,self.m_data.reach_num or 0));
    -- 大于10%,改变绿点宽度
    if rate * 100 > 10 then
        self.m_progressbar_img:setSize((200 - 24) * rate,34); -- 24是progressbar_bg两边缘宽
    end 
end;

function GrowTaskItem:setContentText()
   self.m_contentText:setText(self.m_data.tip_text);
end;

function GrowTaskItem:setBtnStatus()
    if tonumber(self.m_data.status) == 1 then
        self.m_btn:setFile("common/button/dialog_btn_3_normal.png");
        self.m_text:setText("领取");
    elseif tonumber(self.m_data.status) == 2 then
        self.m_btn:setFile("common/button/dialog_btn_9.png");
        self.m_text:setText("已领取");
        self.m_btn:setEnable(false);
    end
end;

function GrowTaskItem:setOnBtnClick(obj,func)
    self.m_btn_obj = obj;
    self.m_btn_func = func;
end

function GrowTaskItem:onBtnClick()
    if self.m_btn_func then
        self.m_btn_func(self.m_btn_obj,self.m_data);
    end
    if tonumber(self.m_data.status) == 0 and tonumber(self.m_data.jump_scene)~= 0 then 
        if tonumber(self.m_data.jump_scene) == States.Online or 
           tonumber(self.m_data.jump_scene) == States.OnlineRoom or 
           tonumber(self.m_data.jump_scene) == States.Comment or 
           tonumber(self.m_data.jump_scene) == States.Compete or
           tonumber(self.m_data.jump_scene) == States.PrivateHall then
            if UserInfo.getInstance():isFreezeUser() then return end;
        end;
        ChessDialogManager.dismissDialog()
        if tonumber(self.m_data.jump_scene) == States.Friends then
            TaskScene.s_showRelationshipDialog()
            return
        elseif tonumber(self.m_data.jump_scene) == States.Replay then
            TaskScene.s_showReplayDialog()
            return
        end

        StateMachine.getInstance():pushState(tonumber(self.m_data.jump_scene),StateMachine.STYPE_CUSTOM_WAIT)
    elseif tonumber(self.m_data.status) == 1 then
        local post_data = {};
        post_data.series_id = self.m_data.series_id;
        post_data.task_id = self.m_data.task_id;
        DailyTaskManager.getInstance():sendGetGrowTaskReward(post_data,"领取中...",false)
    end
end

--每一项具体任务的界面展示基类
require(DATA_PATH .. "dailyTaskData")
require(BASE_PATH.."itemScene")
require(VIEW_PATH.."task_item")
TaskNewItem = class(ItemScene,false)
TaskNewItem.s_w = 678
TaskNewItem.s_h = 170
TaskNewItem.s_controls = 
{
    item_bn = 1;
    get_node = 2;
    complete_degree_tx = 3;
    icon_img = 4;
    name_tx = 5;
    desc_node = 6;
    desc_first_icon_img = 7;
    desc_first_tx = 8;
    desc_second_icon_img = 9;
    desc_second_tx = 10;
    doing_tx = 11;
}
TaskNewItem.idToIcon = 
{
    [1] = "dailytask/endgate_icon.png";
    [2] = "dailytask/online_game_icon.png";
    [3] = "dailytask/daily_sign_icon.png";
    [4] = "dailytask/daily_sign_icon.png";
    [8] = "dailytask/share_icon.png";
    [9] = "dailytask/daily_sign_icon.png";
    [10] = "dailytask/save_icon.png";
    [11] = "dailytask/share_icon.png";
    [14] = "dailytask/commit_userinfo_icon.png";
    [15] = "dailytask/online_game_icon.png";
    [16] = "dailytask/online_game_icon.png";
    [17] = "dailytask/friends_icon.png";

    [101]  = "dailytask/up_user_icon.png";
    [102]  = "dailytask/online_game_icon.png";
    [103]  = "dailytask/online_game_icon.png";
    [104]  = "dailytask/console_icon.png";
    [105]  = "dailytask/endgate_icon.png";
    [106]  = "dailytask/save_icon.png";
    [107]  = "dailytask/friends_icon.png";
    [108]  = "dailytask/share_icon.png";
    [109]  = "dailytask/friends_icon.png";
    [110]  = "dailytask/commit_userinfo_icon.png";
    [111]  = "dailytask/commit_userinfo_icon.png";
    [112]  = "dailytask/fight_icon.png";
    [113]  = "dailytask/fight_icon.png";
    [114]  = "dailytask/friends_icon.png";
    [115]  = "dailytask/online_game_icon.png";
    [120]  = "dailytask/endgate_icon.png";
}

TaskNewItem.prizeIcon = 
{
    [DailyTaskData.prizeType.GOLD] = "mall/mall_list_gold2.png";
    [DailyTaskData.prizeType.SOUL] = "mall/soul_icon.png";
    [DailyTaskData.propType.UNDO] = "mall/undo_icon.png";
    [DailyTaskData.propType.TIP] = "mall/tips_icon.png";
    [DailyTaskData.propType.REVIVE] = "mall/relive_icon.png";
}

TaskNewItem.DEFAULT_ICON = "dailytask/online_game_icon.png"
function TaskNewItem.ctor(self,data)
    super(self,task_item)
    self.mData = data
    self.ctrls = TaskNewItem.s_controls
    self:initView()
    self:updateViewData(data)
    self:setSize(TaskNewItem.s_w,TaskNewItem.s_h)
end  

function TaskNewItem.initView(self)
    self.m_item_bn = self:findViewById(self.ctrls.item_bn)
    self.m_get_node= self:findViewById(self.ctrls.get_node)
    self.m_complete_degree_tx = self:findViewById(self.ctrls.complete_degree_tx)
    self.m_icon_img = self:findViewById(self.ctrls.icon_img)
    self.m_name_tx = self:findViewById(self.ctrls.name_tx)
    self.m_desc_node = self:findViewById(self.ctrls.desc_node)
    self.m_desc_first_icon_img = self:findViewById(self.ctrls.desc_first_icon_img)
    self.m_desc_first_tx = self:findViewById(self.ctrls.desc_first_tx)
    self.m_desc_second_icon_img = self:findViewById(self.ctrls.desc_second_icon_img)
    self.m_desc_second_tx = self:findViewById(self.ctrls.desc_second_tx)
    self.m_doing_tx = self:findViewById(self.ctrls.doing_tx )
end 

function TaskNewItem.updateViewData(self,data)
    if data==nil then return end
    
    if data.name == nil then 
        self.getNode = self:findViewById(self.ctrls.get_node);
        self.getNodeText = self.getNode:getChildByName("get_tx");
        self.getNodeBg = self.getNode:getChildByName("get_img");
        self.getNodeText:setText("已领取");
        self.getNode:setPickable(false);
        self.getNodeBg:setVisible(false);
        return 
    end 
    self:setIcon(data.series_id)
    self:setName(data.name)
    self:setGetBnOrDoing(data.status)
    self:setCompleteDegree(data)
    self:setReward(data.prize)
    --能够获得的金币
    self.mGetMoney = 0
end 

function TaskNewItem.setCompleteDegree(self,data)
    self.m_complete_degree_tx:setText(string.format("%d/%d",data.progress or 0,data.num or 0))
end 

function TaskNewItem.setIcon(self,series_id)
    self.m_icon_img:setFile(TaskNewItem.idToIcon[tonumber(series_id)] or TaskNewItem.DEFAULT_ICON)
end 

function TaskNewItem.setName(self,name)
    self.m_name_tx:setText(name or "")
end 

function TaskNewItem.setGetBnOrDoing(self,status)
    self.getNode = self:findViewById(self.ctrls.get_node);
    self.getNodeText = self.getNode:getChildByName("get_tx");
    self.getNodeBg = self.getNode:getChildByName("get_img");
    if tonumber(status) == 1 then
        self.m_get_node:setVisible(true)
        self.m_doing_tx:setVisible(false)
        self.getNodeText:setText("领取");
        self.getNode:setPickable(true);
        self.getNodeBg:setVisible(true);
    elseif tonumber(status) == 2 then 
        self.m_doing_tx:setText("已领取")
        self.m_get_node:setVisible(false)
        self.m_doing_tx:setVisible(true)
    else
        self.m_get_node:setVisible(false)
        self.m_doing_tx:setVisible(true)
    end
end 

function TaskNewItem.setReward(self,prize)
    local data={}
    data =DailyTaskManager.processPrizeData(prize)
    if data then 
        local count = 1
        for k,v in pairs(data) do
            local num = 0 
            if tonumber(v.num)<1000 then 
                num = tonumber(v.num)
            else
                num = tonumber(v.num) / 1000 .. "k"
            end 
            if count == 1 then 
                --标识该任务能否获得金币
                if v.typeId == DailyTaskData.prizeType.GOLD then 
                    self.mGetMoney = v.num
                end 
                self.m_desc_first_icon_img:setFile(TaskNewItem.prizeIcon[v.typeId])
                self.m_desc_first_tx:setText(num)
                count = 2 
            elseif count == 2 then 
                if v.typeId == DailyTaskData.prizeType.GOLD then 
                    self.mGetMoney = v.num
                end 
                self.m_desc_second_icon_img:setFile(TaskNewItem.prizeIcon[v.typeId])
                self.m_desc_second_tx:setText(num)
                count = 3
            end 
        end 
    end 
end 

function TaskNewItem:setOnBtnClick(obj,func)
    self.m_btn_obj = obj;
    self.m_btn_func = func;
end

function TaskNewItem.onGetClick(self)
    if self.m_btn_func then
        self.m_btn_func(self.m_btn_obj,self.mData);
    end
    if tonumber(self.mData.status) == 1 then
    --TODO: ZJH data为空

        local isDailyTask = typeof(self, DailyTaskNewItem);
        if isDailyTask then
            DailyTaskManager.getInstance():sendGetNewDailyReward(self.mData.id,tips,false,self.mGetMoney,function (successOrFalie,responseJson)
            self.getNode = self:findViewById(self.ctrls.get_node);
            self.getNodeText = self.getNode:getChildByName("get_tx");
            self.getNodeBg = self.getNode:getChildByName("get_img");
            local responseData = json.decode(responseJson);
            local flag = responseData.flag;
            if flag == 10000 then
                self.getNodeText:setText("已领取");
                self.getNode:setPickable(false);
                self.getNodeBg:setVisible(false);
                self:updateViewData(responseData.data);
            end
            end);
        else
            local post_data = {};
            post_data.series_id = self.mData.series_id;
            post_data.task_id = self.mData.task_id;
            DailyTaskManager.getInstance():sendGetGrowTaskReward(post_data,"领取中...",false,self.mGetMoney,function (successOrFalie,responseJson)
            self.getNode = self:findViewById(self.ctrls.get_node);
            self.getNodeText = self.getNode:getChildByName("get_tx");
            self.getNodeBg = self.getNode:getChildByName("get_img");
            local responseData = json.decode(responseJson);
            local flag = responseData.flag;
            if flag == 10000 then
                self.getNodeText:setText("已领取");
                self.getNode:setPickable(false);
                self.getNodeBg:setVisible(false);
                self:updateViewData(responseData.data);
            end
            end);
        end
    end
end 

TaskNewItem.s_controlConfig = 
{
    [TaskNewItem.s_controls.item_bn] = {"item_bn"};
    [TaskNewItem.s_controls.get_node] = {"get_node"};
    [TaskNewItem.s_controls.complete_degree_tx] = {"complete_degree_tx"};
    [TaskNewItem.s_controls.icon_img] = {"icon_img"};
    [TaskNewItem.s_controls.name_tx] = {"name_tx"};
    [TaskNewItem.s_controls.desc_node] = {"desc_node"};
    [TaskNewItem.s_controls.desc_first_icon_img] = {"desc_node","desc_first_icon_img"};
    [TaskNewItem.s_controls.desc_first_tx] = {"desc_node","desc_first_tx"};
    [TaskNewItem.s_controls.desc_second_icon_img] = {"desc_node","desc_second_icon_img"};
    [TaskNewItem.s_controls.desc_second_tx] = {"desc_node","desc_second_tx"};
    [TaskNewItem.s_controls.doing_tx] = {"doing_tx"};
}

TaskNewItem.s_controlFuncMap = 
{
    [TaskNewItem.s_controls.get_node] = TaskNewItem.onGetClick;
}

--日常任务
DailyTaskNewItem = class(TaskNewItem,false)

function DailyTaskNewItem.ctor(self,data)
    super(self,data)
end 

function DailyTaskNewItem.onGetClick(self)
    if self.m_btn_func then
        self.m_btn_func(self.m_btn_obj,self.mData);
    end
    if tonumber(self.m_data.status) == 1 then
        local tips = "领取中...";
        DailyTaskManager.getInstance():sendGetNewDailyReward(self.mData.id,tips,false,self.mGetMoney)
    end
end 

--成长任务
GrowTaskNewItem = class(TaskNewItem,false)

function GrowTaskNewItem.ctor(self,data)
    super(self,data)
end 

function GrowTaskNewItem.setCompleteDegree(self,data)
    self.m_complete_degree_tx:setText(string.format("%d/%d",data.progress or 0,data.reach_num or 0))
end 