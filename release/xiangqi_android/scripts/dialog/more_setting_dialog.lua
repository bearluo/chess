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
    self.m_settingBtn = self.m_root_view:getChildByName("setting_btn");
    self.m_dailyTaskBtn = self.m_root_view:getChildByName("daily_task");
    self.m_mallBtn = self.m_root_view:getChildByName("mall_btn");

    self.m_settingBtn:setOnClick(self,self.onSettingClick);
    self.m_dailyTaskBtn:setOnClick(self,self.showDailyTask);
    self.m_mallBtn:setOnClick(self,self.showMall);
    self:setShieldClick(self,self.cancel);

    self.m_bg = self.m_root_view:getChildByName("blank_bg");
    self.m_bg:setTransparency(0.85);    

    self.m_cover = self.m_root_view:getChildByName("cover");
    self.m_finger_guide = self.m_root_view:getChildByName("finger_guide");

    self:setVisible(false);
end

MoreSettingDialog.dtor = function(self)
    self.m_root_view = nil;
    delete(self.dailyTaskDialog);
    delete(self.settingDialog);
    delete(self.m_anim);
end

MoreSettingDialog.isShowing = function(self)
    return self:getVisible();
end

MoreSettingDialog.show = function(self)
    kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW);

    self:setVisible(true);
    self.super.show(self,false);

    self.m_settingBtn:removeProp(1);
    self.m_dailyTaskBtn:removeProp(1);
    self.m_mallBtn:removeProp(1);

    local anim = {};
    anim[1] = self.m_settingBtn:addPropTransparency(1,kAnimNormal,500,500,0,1);
    anim[2] = self.m_dailyTaskBtn:addPropTransparency(1,kAnimNormal,500,300,0,1);
    anim[3] = self.m_mallBtn:addPropTransparency(1,kAnimNormal,500,100,0,1);

    for i,v in pairs(anim) do
        if i == 1 and v then
            v:setEvent(self,function()
                self.m_settingBtn:removeProp(1);
            end);
        elseif i == 2 then
            v:setEvent(self,function()
                self.m_dailyTaskBtn:removeProp(1);
            end);
        elseif i == 3 then
            v:setEvent(self,function()
                self.m_mallBtn:removeProp(1);
            end);
        end
    end
end

-- 手指引导动画
MoreSettingDialog.startAnim = function(self)
    --定时器
    delete(self.m_anim);
    self.m_anim = new(AnimInt,kAnimNormal,0,1,1000,0);
    self.m_anim:setEvent(self, function(self)
            self.m_finger_guide:removeProp(2);
            self.m_finger_guide:setVisible(true);
            self.m_finger_guide:addPropTranslate(2, kAnimNormal, 1000, 0, 73, 0, 75, 0);
			delete(self.m_anim); 
		end);
end

MoreSettingDialog.cancel = function(self)
	print_string("SettingDialog.cancel ");
	self:dismiss();
end

MoreSettingDialog.dismiss = function(self)
    self:setVisible(false);
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

MoreSettingDialog.showDailyTask = function(self)
    if self.m_handler and not self.m_handler:requestCtrlCmd(HallController.s_cmds.isLogined) then self:dismiss(); return end
    if self.m_handler then
        self.m_handler:onActivityBtnClick();
    end
end

MoreSettingDialog.showMall = function(self)
    if self.m_handler and not self.m_handler:requestCtrlCmd(HallController.s_cmds.isLogined) then self:dismiss(); return end
    self:dismiss();
    if self.m_handler then
        self.m_handler:onMallBtnClick();
    end
end