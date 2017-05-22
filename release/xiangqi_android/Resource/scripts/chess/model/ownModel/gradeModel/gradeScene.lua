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
    head_icon_bg                = 11;
    rank_item_group             = 12;
    menu_move_img               = 13;
    endgate_progress_txt        = 14;
    console_progress_txt        = 15;
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
    delete(self.mMoveAnim)
    delete(self.mMenuMoveAnim)
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
    self.m_leaf_left:setFile("common/decoration/left_leaf.png")

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
    
    self.m_endgate_progress_txt = self:findViewById(self.m_ctrls.endgate_progress_txt);
    self.m_console_progress_txt = self:findViewById(self.m_ctrls.console_progress_txt);

    local data = EndgateData.getInstance():getEndgateData();
    local uid = UserInfo.getInstance():getUid()
	local latest_tid = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_GATE .. uid,17);
	local latest_sort = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_SORT .. uid,0);
    local endgateProgressStr = ""
    local curGate = nil
    for _,gate in ipairs(data) do
        if gate.tid == latest_tid then
            curGate = gate
            break
        end
    end
    if curGate then
        endgateProgressStr = curGate.title
        if latest_sort <= 1 then latest_sort = 1 end
        if latest_sort >= curGate.chessrecord_size then latest_sort = curGate.chessrecord_size end
        endgateProgressStr = string.format("%s 第%d关",endgateProgressStr,latest_sort)
    end
    self.m_endgate_progress_txt:setText(endgateProgressStr)
    
    local level = GameCacheData.getInstance():getInt(GameCacheData.CONSOLE_MAX_OPENLEVEL..uid, 3);
    if level > #User.CONSOLE_TITLE then level = #User.CONSOLE_TITLE end
    
    self.m_console_progress_txt:setText(User.CONSOLE_TITLE[level])

    self.m_level_explain_btn = self:findViewById(self.m_ctrls.level_explain_btn);

    self.m_total_record_btn = self:findViewById(self.m_ctrls.total_record_btn);
    self.m_last_mouth_record_btn = self:findViewById(self.m_ctrls.last_mouth_record_btn);
    self.m_this_mouth_record_btn = self:findViewById(self.m_ctrls.this_mouth_record_btn);
    self.mMenuMoveImg = self:findViewById(self.m_ctrls.menu_move_img);
    self.mMenuMoveImg:setTransparency(0.5)
    self.mMenuMoveImg:setVisible(false)
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

    self:initRankItemGroup()

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

function GradeScene:initRankItemGroup()
    self.mTotalRecordItems = self:createRankItems()
    self.mLastMouthRecordItems = self:createRankItems()
    self.mThisMouthRecordItems = self:createRankItems()
    self.mRankItemGroup = self:findViewById(self.m_ctrls.rank_item_group)
    local w,h = self:getSize()
    self.mRankItemGroup:addChild(self.mTotalRecordItems)
    self.mRankItemGroup:addChild(self.mLastMouthRecordItems)
    self.mRankItemGroup:addChild(self.mThisMouthRecordItems)
    self.mTotalRecordItems:setAlign(kAlignTop)
    self.mLastMouthRecordItems:setAlign(kAlignTop)
    self.mThisMouthRecordItems:setAlign(kAlignTop)
    self.mTotalRecordItems:setPos(w)
    self.mLastMouthRecordItems:setPos(0)
    self.mThisMouthRecordItems:setPos(-w)
    local user = UserInfo.getInstance()
    self.mTotalRecordItems:updateRecordView(
        user:getRateNum(),
        user:getWintimes(),
        user:getLosetimes(),
        user:getDrawtimes()
    )
    self.mLastMouthRecordItems:updateRecordView(
        user:getPrevRateNum(),
        user:getPrevWintimes(),
        user:getPrevLosetimes(),
        user:getPrevDrawtimes()
    )
    self.mThisMouthRecordItems:updateRecordView(
        user:getCurrentRateNum(),
        user:getCurrentWintimes(),
        user:getCurrentLosetimes(),
        user:getCurrentDrawtimes()
    )

end

require(VIEW_PATH.."grade_rank_view_item")
function GradeScene:createRankItems()
    local node = SceneLoader.load(grade_rank_view_item)
    
    function node:init()
        self.mRecordView = self:getChildByName("record_view")
        self.mWinrateBg = self.mRecordView:getChildByName("winrate_bg")
        self.mWinrateView = self.mRecordView:getChildByName("winrate_view")
        self.mWintimesView = self.mRecordView:getChildByName("wintimes_view")
        self.mLosetimesView = self.mRecordView:getChildByName("losetimes_view")
        self.mDrawtimesView = self.mRecordView:getChildByName("drawtimes_view")
        
    end

    function node:updateRecordView(winrate,wintimes,losetimes,drawtimes)
        local winrateStr = string.format("%.2f%%",winrate*100);
        local firstStr = string.sub(winrateStr,1,-5);
        local secondStr = string.sub(winrateStr,-4,-1);
        local CircleProgress = require("chess.include.circleProgress")
        local circleProgress = new(CircleProgress)
        circleProgress:setProgress(winrate*360)
        self.mWinrateBg:removeAllChildren()
        self.mWinrateBg:addChild(circleProgress)

        self.mWinrateView:getChildByName("winrate_1_text"):setText(firstStr,0,0);
        self.mWinrateView:getChildByName("winrate_2_text"):setText(secondStr,0,0);
        self.mWinrateView:setSize(self.mWinrateView:getChildByName("winrate_1_text"):getSize()+self.mWinrateView:getChildByName("winrate_2_text"):getSize());

        self.mWintimesView:getChildByName("num"):setText(wintimes.."局");
        self.mLosetimesView:getChildByName("num"):setText(losetimes.."局");
        self.mDrawtimesView:getChildByName("num"):setText(drawtimes.."局");
    end

    function node:playAnim(winrate)
        local CircleProgress = require("chess.include.circleProgress")
        local circleProgress = new(CircleProgress)
        local anim = circleProgress:addPropRotate(1, kAnimLoop, 100, -1, 0, -10,kCenterDrawing)
        local index = 0
        anim:setEvent(nil,function()
            if index == 1 then
                circleProgress:removeProp(1)
                circleProgress:setProgress(winrate*360)
            end
            index = index + 1
        end)
        self.mWinrateBg:removeAllChildren()
        self.mWinrateBg:addChild(circleProgress)
    end

    node:init()
    return node
end

GradeScene.onTotalRecordBtnClick = function(self)
    self.m_total_record_btn:setPickable(false);
    self.m_last_mouth_record_btn:setPickable(true);
    self.m_this_mouth_record_btn:setPickable(true);
    self.m_total_record_btn:setEnable(true);
    self.m_last_mouth_record_btn:setEnable(true);
    self.m_this_mouth_record_btn:setEnable(true);
    
    local w,h = self:getSize()
    local start = self.mRankItemGroup:getPos()
    self:startMoveAnim(start,-w,function()
        self.mTotalRecordItems:playAnim(UserInfo.getInstance():getRateNum());
    end)
    self.mTotalRecordItems:playAnim(0);
    
    local start = self.m_total_record_btn:getPos()
    self:startMenuMove(start,function()
        self.m_total_record_btn:setEnable(false);
        self.m_last_mouth_record_btn:setEnable(true);
        self.m_this_mouth_record_btn:setEnable(true);
    end)
end

GradeScene.onLastMouthRecordBtnClick = function(self)
    self.m_total_record_btn:setPickable(true);
    self.m_last_mouth_record_btn:setPickable(false);
    self.m_this_mouth_record_btn:setPickable(true);
    self.m_total_record_btn:setEnable(true);
    self.m_last_mouth_record_btn:setEnable(true);
    self.m_this_mouth_record_btn:setEnable(true);
    local w,h = self:getSize()
    local start = self.mRankItemGroup:getPos()
    self:startMoveAnim(start,0,function()
        self.mLastMouthRecordItems:playAnim(UserInfo.getInstance():getPrevRateNum());
    end)
    self.mLastMouthRecordItems:playAnim(0);

    local start = self.m_last_mouth_record_btn:getPos()
    self:startMenuMove(start,function()
        self.m_total_record_btn:setEnable(true);
        self.m_last_mouth_record_btn:setEnable(false);
        self.m_this_mouth_record_btn:setEnable(true);
    end)
end

GradeScene.onThisMouthRecordBtnClick = function(self)
    self.m_total_record_btn:setPickable(true);
    self.m_last_mouth_record_btn:setPickable(true);
    self.m_this_mouth_record_btn:setPickable(false);
    self.m_total_record_btn:setEnable(true);
    self.m_last_mouth_record_btn:setEnable(true);
    self.m_this_mouth_record_btn:setEnable(true);
    local w,h = self:getSize()
    local start = self.mRankItemGroup:getPos()
    self:startMoveAnim(start,w,function()
        self.mThisMouthRecordItems:playAnim(UserInfo.getInstance():getCurrentRateNum());
    end)
    self.mThisMouthRecordItems:playAnim(0);

    
    local start = self.m_this_mouth_record_btn:getPos()
    self:startMenuMove(start,function()
        self.m_total_record_btn:setEnable(true);
        self.m_last_mouth_record_btn:setEnable(true);
        self.m_this_mouth_record_btn:setEnable(false);
    end)
end

function GradeScene:startMoveAnim(startX,endX,endFunc)
    delete(self.mMoveAnim)
    self.mMoveAnim = AnimFactory.createAnimInt(kAnimLoop, 0, 1, 1000/60, -1)
    self.mMoveAnim:setEvent(startX,function()
            local diff = (endX-startX)*0.1
            startX = startX + diff
            if ( math.abs(endX-startX) < 10 ) then
                delete(self.mMoveAnim)
                self.mRankItemGroup:setPos(endX)
                if type(endFunc) == "function" then
                    endFunc()
                end
                return
            end
            self.mRankItemGroup:setPos(startX)
        end)
end

function GradeScene:startMenuMove(endX,endFunc)
    local startX = self.mMenuMoveImg:getPos()
    local curX = startX
    local diff = endX - startX
    local duration = 1000/60
    local curTime = 0
    local cubicBezier = require("libs.cubicBezier")

    delete(self.mMenuMoveAnim)
    self.mMenuMoveImg:setVisible(true)
    self.mMenuMoveAnim = AnimFactory.createAnimInt(kAnimLoop, 0, 1, duration, -1)
    self.mMenuMoveAnim:setEvent(self,function()
        curTime = curTime + duration

        curX = startX + diff*cubicBezier.cubicBezier(0,0.16,0.28,1.2,curTime/500).y

        if curTime >= 500 then
            curX = endX
            delete(self.mMenuMoveAnim)
            if type(endFunc) == "function" then
                endFunc()
            end
            self.mMenuMoveImg:setVisible(false)
        end
        self.mMenuMoveImg:setPos(curX)
    end)
end

require("dialog/grade_config_dialog");
GradeScene.onLevelExplainBtnClick = function(self)
    if not self.m_grade_config_dialog then
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
    [GradeScene.s_controls.rank_item_group]                   = {"grade_view","record_view","rank_item_group"};
    [GradeScene.s_controls.menu_move_img]                     = {"grade_view","record_view","menu_move_img"};
    [GradeScene.s_controls.head_icon_bg]                      = {"grade_view","head_icon_bg"};
    [GradeScene.s_controls.endgate_progress_txt]              = {"grade_view","offline_progress","endgate","progress_txt"};
    [GradeScene.s_controls.console_progress_txt]              = {"grade_view","offline_progress","console","progress_txt"};

    
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