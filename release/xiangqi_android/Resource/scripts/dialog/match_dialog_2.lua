require(VIEW_PATH .. "match_dialog_view_2");
MatchDialog2 = class(ChessDialogScene,false);

MatchDialog2.match_time = 10;

MatchDialog2.ctor = function(self) 
    super(self,match_dialog_view_2);
	self.m_root_view = self.m_root;

    self.m_anim_view = {};
    for i=1,3 do
        self.m_anim_view[i] = self.m_root_view:getChildByName("anim_view"):getChildByName("anim_"..i);
    end
    self.m_anim_img_view = self.m_root_view:getChildByName("anim_view");

    self.m_bg_blank = self.m_root_view:getChildByName("bg_blank");
    self.m_bg_blank:setTransparency(0.4);

    self.m_head_bg = self.m_root_view:getChildByName("head_bg");
    self.m_head_mask = self.m_root_view:getChildByName("head_bg"):getChildByName("head_mask");

    self.m_icon = new(Mask,UserInfo.DEFAULT_ICON[1],"online/room/dialog/head_mask_bg_144.png");
    self.m_icon:setSize(self.m_head_mask:getSize());
    self.m_icon:setAlign(kAlignCenter);
    self.m_head_mask:addChild(self.m_icon);

    self.m_background_run_btn = self.m_root_view:getChildByName("background_run_btn")
    self.m_background_run_btn:setOnClick(self,self.onBackGroundRunBtnClick)
    self.m_background_run_btn:setVisible(false)
    self:setNeedBackEvent(false);
end

MatchDialog2.dtor = function(self)
	self.m_root_view = nil;
    self:stopMatchAnim();
    self:stopHeadIconAnim();
    self:stopCountDownAnim()
end

MatchDialog2.show = function(self)
    self.super.show(self);
    self:startMatchAnim();
    self:startCountDownAnim();
end

MatchDialog2.onMatchSuc = function(self,data)
    if not data or not data.user then return end
   
end

MatchDialog2.dismiss = function(self)
    self.super.dismiss(self);
    self:stopMatchAnim();
    self:stopHeadIconAnim();
    self:stopCountDownAnim()
end

MatchDialog2.startCountDownAnim = function(self)
    self:stopCountDownAnim()
    self.m_background_run_btn:setVisible(false)
    self.mCountDownAnim = AnimFactory.createAnimInt(kAnimNormal,0,1,10000,-1)
    self.mCountDownAnim:setEvent(self,function()
        self.m_background_run_btn:setVisible(true)
    end)
end

MatchDialog2.stopCountDownAnim = function(self)
    delete(self.mCountDownAnim)
end

MatchDialog2.setBackGroundRunBtnEvent = function(self,obj,func)
    self.mBackGroundRunBtnEventFunc = func
    self.mBackGroundRunBtnEventObj = obj
end

MatchDialog2.onBackGroundRunBtnClick = function(self)
    if type(self.mBackGroundRunBtnEventFunc) == "function" then
        self.mBackGroundRunBtnEventFunc(self.mBackGroundRunBtnEventObj)
    end
end

MatchDialog2.stopMatchAnim = function(self)
    for i=1,3 do
        self.m_anim_view[i]:removeProp(1);
        self.m_anim_view[i]:removeProp(2);
    end
end

MatchDialog2.startMatchAnim = function(self)
    self:startHeadIconAnim();
    self.m_anim_img_view:setVisible(true);
    for i=1,3 do
        self.m_anim_view[i]:removeProp(1);
        self.m_anim_view[i]:removeProp(2);
        local delay = i*1000;
        local duration = 3000;
        self.m_anim_view[i]:addPropScale(1, kAnimRepeat, duration, delay, 1, 3, 1, 3, kCenterDrawing);
        self.m_anim_view[i]:addPropTransparency(2, kAnimRepeat, duration, delay, 1, 0);
    end
end


MatchDialog2.startHeadIconAnim = function(self)
    self:stopHeadIconAnim();
    self.timer = new(AnimInt,kAnimRepeat,0,1,2500,-1);
    self.timer:setEvent(self,self.updataAnim);
end

MatchDialog2.updataAnim = function(self)
    local n = math.random(18);
    local imgName = UserInfo.DEFAULT_ICON[n];
    if not imgName then
        imgName = UserInfo.DEFAULT_ICON[1];
    end

    for i = 1,3 do
        if not self.m_head_bg:checkAddProp(i) then
            self.m_head_bg:removeProp(i);
        end
    end

    local anim_narrow = self.m_head_bg:addPropScale(3,kAnimNormal,400,-1,1,0.9,1,0.9,kCenterDrawing);
    if anim_narrow then
        anim_narrow:setEvent(self,function()
            self.m_icon:setFile(imgName)
            self.m_head_bg:addPropTransparency(2,kAnimNormal,200,-1,0.8,1);
            self.m_head_bg:removeProp(3);
            delete(anim_narrow);
        end);
    end

    local anim_enlarge = self.m_head_bg:addPropScale(1,kAnimLoop,400,400,1,1.1,1,1.1,kCenterDrawing);
    if anim_enlarge then
        anim_enlarge:setEvent(self,function()
            self.m_head_bg:removeProp(1);
            self.m_head_bg:removeProp(2);
            delete(anim_enlarge);
        end);
    end
end

MatchDialog2.stopHeadIconAnim = function(self)
    for i = 1,3 do
        if not self.m_head_bg:checkAddProp(i) then
            self.m_head_bg:removeProp(i);
        end
    end
    delete(self.timer);
end
