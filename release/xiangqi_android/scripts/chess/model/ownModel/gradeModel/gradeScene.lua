--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23

require(BASE_PATH.."chessScene");


GradeScene = class(ChessScene);

GradeScene.s_controls = 
{
    back_btn                    = 1;
    title_icon                  = 2;
    grade_view                  = 3;
    teapot_dec                  = 4;
    level_icon                  = 5;
    score_info                  = 6;
    level_explain_btn           = 7;
    total_record_btn            = 8;
    last_mouth_record_btn       = 9;
    this_mouth_record_btn       = 10;
    winrate_view                = 11;
    wintimes_view               = 12;
    losetimes_view              = 13;
    drawtimes_view              = 14;
    head_icon_bg                = 15;
}

GradeScene.s_cmds = 
{
}




GradeScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = GradeScene.s_controls;
    self:create();
end 

GradeScene.resume = function(self)
    ChessScene.resume(self);
--    self:removeAnimProp();
--    self:resumeAnimStart();
end

GradeScene.isShowBangdinDialog = false;

GradeScene.pause = function(self)
	ChessScene.pause(self);
    self:removeAnimProp();
--    self:pauseAnimStart();
end 

GradeScene.dtor = function(self)
    delete(self.m_grade_config_dialog);
    delete(self.anim_start);
    delete(self.anim_end);
end 

GradeScene.removeAnimProp = function(self)

    if self.m_anim_prop_need_remove then
        self.m_grade_view:removeProp(1);
        self.m_leaf_left:removeProp(1);
        self.m_title_icon:removeProp(1);
--        self.m_back_btn:removeProp(1);
    --    self.m_top_view:removeProp(1);
    --    self.m_more_btn:removeProp(1);
    --    self.m_bottom_view:removeProp(1);
        self.m_anim_prop_need_remove = false;
    end
end

GradeScene.setAnimItemEnVisible = function(self,ret)
    self.m_leaf_left:setVisible(ret);
end

GradeScene.resumeAnimStart = function(self,lastStateObj,timer)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;
    delete(self.anim_start);
    self.anim_start = new(AnimInt,kAnimNormal,0,1,delay,-1);
    if self.anim_start then
        self.anim_start:setEvent(self,function()
            self:setAnimItemEnVisible(true);
            delete(self.anim_start);
        end);
    end

    self.m_grade_view:addPropTransparency(1,kAnimNormal,waitTime,delay,0,1);
    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, delay, -lw, 0, -10, 0);
    local tw,th = self.m_title_icon:getSize();
    local anim = self.m_title_icon:addPropTranslate(1, kAnimNormal, waitTime, delay, 0, 0, -th, 0);
    if anim then
        anim:setEvent(self,function()
            self.m_anim_prop_need_remove = true;
            self:removeAnimProp();
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end  
        end);   
    end
end

GradeScene.pauseAnimStart = function(self,newStateObj,timer)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;
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

    self.m_grade_view:addPropTransparency(1,kAnimNormal,waitTime,-1,1,0);
    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, -lw, 0, -10);
    local w,h = self.m_title_icon:getSize();
    local anim = self.m_title_icon:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, 0, 0, -h);
    if anim then
        anim:setEvent(self,function()
            self:setAnimItemEnVisible(false);
        end);
    end
end

---------------------- func --------------------
GradeScene.create = function(self)
	self.m_back_btn = self:findViewById(self.m_ctrls.back_btn);
	self.m_title_icon = self:findViewById(self.m_ctrls.title_icon);
    self.m_leaf_left = self.m_root:getChildByName("bamboo_left");

    self.m_grade_view = self:findViewById(self.m_ctrls.grade_view);
    self.m_level_icon = self:findViewById(self.m_ctrls.level_icon);
    self.m_head_icon_bg = self:findViewById(self.m_ctrls.head_icon_bg);
    self.m_vip_frame = self.m_head_icon_bg:getChildByName("vip_frame");
    self.m_icon = new(Mask,"common/background/head_mask_bg_122.png","common/background/head_mask_bg_122.png");
    self.m_icon:setAlign(kAlignCenter);
    self.m_head_icon_bg:addChild(self.m_icon);
    self.m_icon:setAlign(kAlignCenter);
    if UserInfo.getInstance():getIconType() == -1 then
        self.m_icon:setUrlImage(UserInfo.getInstance():getIcon(),UserInfo.DEFAULT_ICON[1]);
    else
        self.m_icon:setFile(UserInfo.DEFAULT_ICON[UserInfo.getInstance():getIconType()] or UserInfo.DEFAULT_ICON[1]);
    end
    self.m_level_icon:setFile(string.format("common/icon/big_level_%d.png",10-UserInfo.getInstance():getDanGradingLevel()));


    self.m_score_info = self:findViewById(self.m_ctrls.score_info);

    local danGrading = UserInfo.getInstance():getDanGrading();
    if danGrading then
        local score = UserInfo.getInstance():getScore();
        local level = UserInfo.getInstance():getDanGradingLevel();
        local str = score .. "积分/";
        if danGrading[level+1] then
            str = str .. danGrading[level+1].name .. danGrading[level+1].min .. "积分";
        else
            str = str .. danGrading[level].name .. danGrading[level].min .. "积分";
        end
        self.m_score_info:setText(str);
    end

    self.m_level_explain_btn = self:findViewById(self.m_ctrls.level_explain_btn);

    self.m_total_record_btn = self:findViewById(self.m_ctrls.total_record_btn);
    self.m_last_mouth_record_btn = self:findViewById(self.m_ctrls.last_mouth_record_btn);
    self.m_this_mouth_record_btn = self:findViewById(self.m_ctrls.this_mouth_record_btn);
    
    local func =  function(view,enable)
        local text = view:getChildByName("text");
        if text then
            if enable then
                text:setColor(135,100,95);
            else
                text:setColor(230,80,50);
            end
        end
    end
 
    self.m_total_record_btn:setOnTuchProcess(self.m_total_record_btn,func)
    self.m_last_mouth_record_btn:setOnTuchProcess(self.m_last_mouth_record_btn,func)
    self.m_this_mouth_record_btn:setOnTuchProcess(self.m_this_mouth_record_btn,func)

    
    self.m_winrate_view = self:findViewById(self.m_ctrls.winrate_view);
    
    self.m_wintimes_view = self:findViewById(self.m_ctrls.wintimes_view);
    self.m_losetimes_view = self:findViewById(self.m_ctrls.losetimes_view);
    self.m_drawtimes_view = self:findViewById(self.m_ctrls.drawtimes_view);

    --vip头像框
--    local is_vip = UserInfo.getInstance():getIsVip();
--    if is_vip and is_vip == 1 then
--        self.m_vip_frame:setVisible(true);
--    else
--        self.m_vip_frame:setVisible(false);
--    end
    local frameRes = UserSetInfo.getInstance():getFrameRes();
    self.m_vip_frame:setVisible(frameRes.visible);
    local fw,fh = self.m_vip_frame:getSize();
    if frameRes.frame_res then
        self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
    end

    self:onThisMouthRecordBtnClick();
end

GradeScene.onBackAction = function(self)
    self:requestCtrlCmd(GradeController.s_cmds.onBack);
end

GradeScene.updateRecordView = function(self,winrate,wintimes,losetimes,drawtimes)
    local firstStr = string.sub(winrate,1,-5);
    local secondStr = string.sub(winrate,-4,-1);
    self.m_winrate_view:getChildByName("winrate_1_text"):setText(firstStr,0,0);
    self.m_winrate_view:getChildByName("winrate_2_text"):setText(secondStr,0,0);
    self.m_winrate_view:setSize(self.m_winrate_view:getChildByName("winrate_1_text"):getSize()+self.m_winrate_view:getChildByName("winrate_2_text"):getSize());

    self.m_wintimes_view:getChildByName("num"):setText(wintimes.."局");
    self.m_losetimes_view:getChildByName("num"):setText(losetimes.."局");
    self.m_drawtimes_view:getChildByName("num"):setText(drawtimes.."局");
end

GradeScene.onTotalRecordBtnClick = function(self)
    self.m_total_record_btn:setEnable(false);
    self.m_last_mouth_record_btn:setEnable(true);
    self.m_this_mouth_record_btn:setEnable(true);

    self:updateRecordView(
        UserInfo.getInstance():getRate(),
        UserInfo.getInstance():getWintimes(),
        UserInfo.getInstance():getLosetimes(),
        UserInfo.getInstance():getDrawtimes()
        );
end

GradeScene.onLastMouthRecordBtnClick = function(self)
    self.m_total_record_btn:setEnable(true);
    self.m_last_mouth_record_btn:setEnable(false);
    self.m_this_mouth_record_btn:setEnable(true);

    self:updateRecordView(
        UserInfo.getInstance():getPrevRate(),
        UserInfo.getInstance():getPrevWintimes(),
        UserInfo.getInstance():getPrevLosetimes(),
        UserInfo.getInstance():getPrevDrawtimes()
        );
end

GradeScene.onThisMouthRecordBtnClick = function(self)
    self.m_total_record_btn:setEnable(true);
    self.m_last_mouth_record_btn:setEnable(true);
    self.m_this_mouth_record_btn:setEnable(false);

    self:updateRecordView(
        UserInfo.getInstance():getCurrentRate(),
        UserInfo.getInstance():getCurrentWintimes(),
        UserInfo.getInstance():getCurrentLosetimes(),
        UserInfo.getInstance():getCurrentDrawtimes()
        );
end

GradeScene.onLevelExplainBtnClick = function(self)
    if not self.m_grade_config_dialog then
        require(DIALOG_PATH.."grade_config_dialog");
        self.m_grade_config_dialog = new(GradeConfigDialog);
    end
    self.m_grade_config_dialog:show();
end
---------------------- config ------------------
GradeScene.s_controlConfig = {
    [GradeScene.s_controls.back_btn]                          = {"back_btn"};
    [GradeScene.s_controls.title_icon]                        = {"title_icon"};
    [GradeScene.s_controls.grade_view]                        = {"grade_view"};
    [GradeScene.s_controls.teapot_dec]                        = {"teapot_dec"};
    [GradeScene.s_controls.level_icon]                        = {"grade_view","level_icon"};
    [GradeScene.s_controls.head_icon_bg]                        = {"grade_view","head_icon_bg"};
    [GradeScene.s_controls.score_info]                        = {"grade_view","score_bg","score_info"};
    [GradeScene.s_controls.level_explain_btn]                 = {"grade_view","level_explain_btn"};
    [GradeScene.s_controls.total_record_btn]                  = {"grade_view","record_view","total_record_btn"};
    [GradeScene.s_controls.last_mouth_record_btn]             = {"grade_view","record_view","last_mouth_record_btn"};
    [GradeScene.s_controls.this_mouth_record_btn]             = {"grade_view","record_view","this_mouth_record_btn"};
    [GradeScene.s_controls.winrate_view]                      = {"grade_view","record_view","winrate_bg","winrate_view"};
    [GradeScene.s_controls.wintimes_view]                     = {"grade_view","record_view","wintimes_view"};
    [GradeScene.s_controls.losetimes_view]                    = {"grade_view","record_view","losetimes_view"};
    [GradeScene.s_controls.drawtimes_view]                    = {"grade_view","record_view","drawtimes_view"};
    [GradeScene.s_controls.head_icon_bg]                      = {"grade_view","head_icon_bg"};
    
}

GradeScene.s_controlFuncMap = {
    [GradeScene.s_controls.back_btn]                            = GradeScene.onBackAction;
    [GradeScene.s_controls.total_record_btn]                    = GradeScene.onTotalRecordBtnClick;
    [GradeScene.s_controls.last_mouth_record_btn]               = GradeScene.onLastMouthRecordBtnClick;
    [GradeScene.s_controls.this_mouth_record_btn]               = GradeScene.onThisMouthRecordBtnClick;
    [GradeScene.s_controls.level_explain_btn]                   = GradeScene.onLevelExplainBtnClick;
};

GradeScene.s_cmdConfig =
{
}