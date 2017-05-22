require(VIEW_PATH .. "grade_config_dialog_view");
require(BASE_PATH.."chessDialogScene")

GradeConfigDialog = class(ChessDialogScene,false);

GradeConfigDialog.ctor = function(self)
	super(self,grade_config_dialog_view);
	self.m_root_view = self.m_root;
    self.m_bg_view = self.m_root_view:getChildByName("bg");
    self:setShieldClick(self,self.dismiss);
    self.m_bg_view:setEventTouch(self.m_bg_view,function() end);

    self.m_introduction_view = self.m_bg_view:getChildByName("introduction_view");
    local w,h = self.m_introduction_view:getSize();

    local str = "棋力等级评测对照国家象棋棋力评测系统，每次会匹配和你棋力相当的对手与你对局，在每个级别中净赢同等级别的对手会晋级。此等级评测系统评测出来的棋力等级，具有极高的权威性。"


    local text = new(RichText,str,w,h,kAlignLeft,nil,30,80,80,80,true,20)
    self.m_introduction_view:addChild(text);

    self.m_content_view = self.m_bg_view:getChildByName("content_view");
    
    local danGrading = UserInfo.getInstance():getDanGrading();

    if danGrading then
        for i,v in pairs(danGrading) do
            local view = self.m_content_view:getChildByName("score_"..i);
            if view then
                view:setText(v.min.."积分");
            end
        end
    end
    self.m_close_btn = self.m_bg_view:getChildByName("close_btn");
    self.m_close_btn:setOnClick(self,self.dismiss);
end


GradeConfigDialog.dtor = function(self)
    delete(self.m_root_view);
end

GradeConfigDialog.isShowing = function(self)
	return self:getVisible();
end


GradeConfigDialog.show = function(self)
    for i = 1,4 do 
        if not self.m_bg_view:checkAddProp(i) then
            self.m_bg_view:removeProp(i);
        end 
    end
    local w,h = self.m_bg_view:getSize();
 --    local anim = self.m_bg_view:addPropTranslateWithEasing(1,kAnimNormal, 400, -1, nil, "easeOutBounce", 0,0, h, -h);
    local anim = self.m_bg_view:addPropTranslate(1,kAnimNormal,400,-1,0,0,h+25,0);
    if anim then
        anim:setEvent(self,function()
            self.m_bg_view:addPropTranslate(4,kAnimNormal,200,-1,0,0,0,-25);
            delete(anim);
            anim = nil;
        end);
    end
    local anim_end = new(AnimInt,kAnimNormal,0,1,600,-1);
    if anim_end then
        anim_end:setEvent(self,function()
            for i = 1,4 do 
                if not self.m_bg_view:checkAddProp(i) then
                    self.m_bg_view:removeProp(i);
                end 
            end
            delete(anim_end);
            anim_end = nil;
        end);
    end
    self:setVisible(true);
    self.super.show(self,false);
end;


GradeConfigDialog.dismiss = function(self)
    for i = 1,4 do 
        if not self.m_bg_view:checkAddProp(i) then
            self.m_bg_view:removeProp(i);
        end 
    end
    local w,h = self.m_bg_view:getSize();
    local anim = self.m_bg_view:addPropTranslate(3,kAnimNormal,300,-1,0,0,0,h);
    self.m_bg_view:addPropTransparency(2,kAnimNormal,200,-1,1,0);
    anim:setEvent(self,
    function()
        self:setVisible(false);
        self.m_bg_view:removeProp(2);
        self.m_bg_view:removeProp(3);
    end);
    self.super.dismiss(self,false);
end
