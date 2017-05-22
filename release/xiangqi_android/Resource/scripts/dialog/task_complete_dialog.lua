--region task_complete_dialog.lua
--Author : LeoLi
--Date   : 2016/9/29

require(VIEW_PATH .. "task_complete_dialog");
require(BASE_PATH.."chessDialogScene")

TaskCompleteDialog = class(ChessDialogScene,false);

TaskCompleteDialog.ctor = function(self)
    super(self,task_complete_dialog);
    self.m_root_view = self.m_root;
    self:initView();
end;

TaskCompleteDialog.dtor = function(self)

end;

TaskCompleteDialog.getInsance = function(self)
    if (not TaskCompleteDialog.instance) then
        TaskCompleteDialog.instance = new(TaskCompleteDialog);
    end;
    return TaskCompleteDialog.instance;
end;

TaskCompleteDialog.initView = function(self)
    self.m_bg = self.m_root_view:getChildByName("bg");
    -- title
    self.m_title = self.m_bg:getChildByName("title");
        -- icon_bg
        self.m_icon_bg = self.m_title:getChildByName("icon_bg");
        self.m_icon = new(Mask,"common/background/head_bg_160.png","common/background/head_bg_160.png");
        self.m_icon:setAlign(kAlignCenter);
        self.m_icon:setUrlImage(UserInfo.getInstance():getIcon(),UserInfo.DEFAULT_ICON[1]);
        self.m_icon_bg:addChild(self.m_icon);
    -- content
    self.m_content = self.m_bg:getChildByName("content");

    -- bottom
    self.m_bottom = self.m_bg:getChildByName("bottom");
        -- share_btn
        self.m_share_btn = self.m_bottom:getChildByName("share_btn");
        self.m_share_btn:setOnClick(self, self.share);
        -- getReward_btn
        self.m_getReward_btn = self.m_bottom:getChildByName("getReward_btn");
        self.m_getReward_btn:setOnClick(self, self.getReward);
    self.mDialogAnim = AnimDialogFactory.createNormalAnim(self)
end;

TaskCompleteDialog.show = function(self, data)
    if not data then return end;
    self.m_data = data;
    local tip = self.m_data.push_tip_text;
    local reward = self.m_data.push_prize_text;
    if not tip or tip == "" or not reward or reward == "" then return end;

    if self.m_tips then
        delete(self.m_tips)
        self.m_tips = nil;
    end;
    self.m_tips = new(RichText,tip or "",440,150,kAlignCenter,nil,46,255,255,255,true,20);
    self.m_tips:setAlign(kAlignCenter);
    self.m_content:addChild(self.m_tips);

    if self.m_rewards then
        delete(self.m_rewards)
        self.m_rewards = nil;
    end;
    self.m_rewards = new(RichText,reward or "",330,33,kAlignCenter,nil,32,125,80,65);
    self.m_rewards:setAlign(kAlignBottom);
    self.m_rewards:setPos(0,-125);
    self.m_content:addChild(self.m_rewards);
    -- show
    self:setVisible(true);
    self.super.show(self,self.mDialogAnim.showAnim);
end;

TaskCompleteDialog.dismiss = function(self)
    self.super.dismiss(self,self.mDialogAnim.dismissAnim);
end;

TaskCompleteDialog.share = function(self)
    local path = System.getStorageImagePath().."egame_share";
    ToolKit.takeShot(self.m_bg.m_drawingID,path);
    EventDispatcher.getInstance():dispatch(Event.Call,kTakeShotComplete);
end;

TaskCompleteDialog.getReward = function(self)
    local post_data = {};
    post_data.series_id = self.m_data.series_id;
    post_data.task_id = self.m_data.task_id;
    DailyTaskManager.getInstance():sendGetGrowTaskReward(post_data,"领取中...")
    self:dismiss();
end;