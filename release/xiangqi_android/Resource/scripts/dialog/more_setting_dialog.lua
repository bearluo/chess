--region NewFile_1.lua
--Author : FordFan
--Date   : 2015/11/10
--大厅界面更多设置
--endregion

require(VIEW_PATH .. "more_setting_dialog");
require("dialog/setting_dialog");
require("dialog/new_daily_task_dialog");
require(BASE_PATH .. "chessDialogScene");

MoreSettingDialog = class(ChessDialogScene,false);

MoreSettingDialog.getInstance = function()
    if not MoreSettingDialog.s_instance then
        MoreSettingDialog.s_instance = new(MoreSettingDialog);
    end
    return MoreSettingDialog.s_instance;
end


MoreSettingDialog.ctor = function(self)
    super(self,more_setting_dialog);

    self.m_root_view = self.m_root;
    self.m_shareBtn = self.m_root_view:getChildByName("share_btn");
    self.m_feedbackBtn = self.m_root_view:getChildByName("feedback_btn");
    self.m_settingBtn = self.m_root_view:getChildByName("setting_btn");

    self.m_settingBtn:setOnClick(self,self.onSettingClick);
    self.m_feedbackBtn:setOnClick(self,self.onFeedBackClick);
    self.m_shareBtn:setOnClick(self,self.onShareClick);

    self.m_bg = self.m_root_view:getChildByName("blank_bg");
--    self.m_bg:setTransparency(0.85);    

    self:setVisible(false);
end

MoreSettingDialog.dtor = function(self)
    self.m_root_view = nil;
    delete(self.timerAnim);
    self.timerAnim = nil;
    delete(self.animEnd);
    self.animEnd = nil;
    delete(self.settingDialog);
end

MoreSettingDialog.isShowing = function(self)
    return self:getVisible();
end

function MoreSettingDialog:removeAnimProp()
    for i = 1,2 do 
        if not self.m_shareBtn:checkAddProp(i) then
            self.m_shareBtn:removeProp(i);
        end
        if not self.m_feedbackBtn:checkAddProp(i) then
            self.m_feedbackBtn:removeProp(i);
        end
        if not self.m_settingBtn:checkAddProp(i) then
            self.m_settingBtn:removeProp(i);
        end
        if not self.m_bg:checkAddProp(i) then
            self.m_bg:removeProp(i);
        end
    end
end 

MoreSettingDialog.show = function(self)
    kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);

    self:setVisible(true);
    self.super.show(self,false);
    self:removeAnimProp();
    self.isDismissing = false;

    self.m_settingBtn:addPropTransparency(1,kAnimNormal,500,400,0,1);
    self.m_settingBtn:addPropScale(2,kAnimNormal,350,350,0.6,1,0.6,1,kCenterXY,76,190);

    self.m_feedbackBtn:addPropTransparency(1,kAnimNormal,500,250,0,1);
    self.m_feedbackBtn:addPropScale(2,kAnimNormal,350,200,0.6,1,0.6,1,kCenterDrawing);

    self.m_shareBtn:addPropTransparency(1,kAnimNormal,500,100,0,1);
    self.m_shareBtn:addPropScale(2,kAnimNormal,350,100,0.6,1,0.6,1,kCenterXY,81,0);

    self.m_bg:addPropTransparency(1,kAnimNormal,600,-1,0,1);

    self.timerAnim = new(AnimInt,kAnimNormal,0,1,900,-1);
    if self.timerAnim then
        self.timerAnim:setEvent(self,function()
            delete(self.timerAnim);
            self.timerAnim = nil;
            if self.isDismissing then
                self:removeAnimProp();
            end
            self:setShieldClick(self,self.cancel);
        end);
    end
    
end

-- 手指引导动画
MoreSettingDialog.startAnim = function(self)
    --定时器
--    delete(self.m_anim);
--    self.m_anim = new(AnimInt,kAnimNormal,0,1,1000,0);
--    self.m_anim:setEvent(self, function(self)
--            self.m_finger_guide:removeProp(2);
--            self.m_finger_guide:setVisible(true);
--            self.m_finger_guide:addPropTranslate(2, kAnimNormal, 1000, 0, 73, 0, 75, 0);
--			delete(self.m_anim); 
--		end);
end

MoreSettingDialog.cancel = function(self)
    if self.isDismissing then
        return;
    end
    self.isDismissing = true;
    self:dismissAnim();
	self:dismiss(true);
end

MoreSettingDialog.dismiss = function(self,ret)
    if not ret then
        self:removeAnimProp();
        self:setVisible(false);
    end
    self:setShieldClick();
    self.super.dismiss(self,false);
end

MoreSettingDialog.setHandler = function(self,handler)
    self.m_handler = handler;
end

MoreSettingDialog.onSettingClick = function(self)
    self:dismiss();
    if not self.settingDialog then
        self.settingDialog = new(SettingDialog);
    end
    self.settingDialog:show();
end

MoreSettingDialog.onFeedBackClick = function(self)
    if self.m_handler and not self.m_handler:requestCtrlCmd(HallController.s_cmds.isLogined) then self:dismiss(); return end
    self:dismiss();
    if self.m_handler then
        self.m_handler:onFeedBackBtnClick();
    end
end

MoreSettingDialog.onShareClick = function(self)
    if self.m_handler and not self.m_handler:requestCtrlCmd(HallController.s_cmds.isLogined) then self:dismiss(); return end
    StatisticsManager.getInstance():onCountToUM(HALL_MODEL_SHARE_BTN);
    self:dismiss();
    if self.m_handler then
        self.m_handler:onShareClick();
    end
end

function MoreSettingDialog:dismissAnim()
    self:removeAnimProp();
    
    self.m_settingBtn:addPropTransparency(1,kAnimNormal,500,100,1,0);
    self.m_settingBtn:addPropScale(2,kAnimNormal,350,100,1,0,1,0,kCenterXY,76,190);

    self.m_feedbackBtn:addPropTransparency(1,kAnimNormal,500,250,1,0);
    self.m_feedbackBtn:addPropScale(2,kAnimNormal,350,200,1,0,1,0,kCenterDrawing);

    self.m_shareBtn:addPropTransparency(1,kAnimNormal,500,400,1,0);
    self.m_shareBtn:addPropScale(2,kAnimNormal,350,300,1,0,1,0,kCenterXY,81,0);
    self.m_bg:addPropTransparency(1,kAnimNormal,900,-1,1,0);

    self.animEnd = new(AnimInt,kAnimNormal,0,1,900,-1);

    if self.animEnd then
        self.animEnd:setEvent(self,function()
            self:setVisible(false);
            delete(self.animEnd);
            self.animEnd = nil;
            self:removeAnimProp();
        end)
    end
end