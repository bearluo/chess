require(VIEW_PATH .. "select_player_dialog_view");
require(BASE_PATH.."chessDialogScene")

SelectPlayerDialog = class(ChessDialogScene,false);

SelectPlayerDialog.ctor = function(self, room)
	super(self,select_player_dialog_view);
	self.m_root_view = self.m_root;
    self.m_room = room;
    self.m_bg_view = self.m_root_view:getChildByName("bg");
    self:setShieldClick(self,self.quit_game);
    self.m_bg_view:setEventTouch(self.m_bg_view,function() end);
    --title

    --content
    self.m_content_view = self.m_bg_view:getChildByName("content_view");

    self.m_easy_btn = self.m_content_view:getChildByName("easy_btn");
    self.m_easy_btn:setOnClick(self, self.easyBtnClick);

    self.m_normal_btn = self.m_content_view:getChildByName("normal_btn");
    self.m_normal_btn:setOnClick(self, self.normalBtnClick);

    self.m_hard_btn = self.m_content_view:getChildByName("hard_btn");
    self.m_hard_btn:setOnClick(self, self.hardBtnClick);



    --bottom
    self.m_start_btn = self.m_bg_view:getChildByName("start_btn");
    self.m_start_btn:setOnClick(self, self.start_game);
    self.m_close_btn = self.m_bg_view:getChildByName("close_btn");
    self.m_close_btn:setOnClick(self, self.quit_game);
    
    self:setNeedBackEvent(false);
    self:normalBtnClick();
end;


SelectPlayerDialog.dtor = function(self)
    self.super.dismiss(self);
    delete(self.m_root_view);
	self.m_root_view = nil;
end

SelectPlayerDialog.isShowing = function(self)
	return self:getVisible();
end


SelectPlayerDialog.show = function(self)
    self.m_dismissStatus = false;
    local w,h = self.m_bg_view:getSize();
    local anim = self.m_bg_view:addPropTranslate(1,kAnimNormal,400,-1,0,0,h,0);
    if anim then
        anim:setEvent(self,function()
            self.m_bg_view:removeProp(1);
        end);
    end
    self:setVisible(true);
    self.super.show(self,false);
end;

SelectPlayerDialog.easyBtnClick = function(self)
    self.m_easy_btn:setEnable(false);
    self.m_normal_btn:setEnable(true);
    self.m_hard_btn:setEnable(true);
    self.m_room.m_upPlayer_level = 1;
    
    SelectPlayerDialog.resetStar(self.m_easy_btn,true)
    SelectPlayerDialog.resetStar(self.m_normal_btn,false)
    SelectPlayerDialog.resetStar(self.m_hard_btn,false)
end


SelectPlayerDialog.normalBtnClick = function(self)
    self.m_easy_btn:setEnable(true);
    self.m_normal_btn:setEnable(false);
    self.m_hard_btn:setEnable(true);

    SelectPlayerDialog.resetStar(self.m_easy_btn,false)
    SelectPlayerDialog.resetStar(self.m_normal_btn,true)
    SelectPlayerDialog.resetStar(self.m_hard_btn,false)

    self.m_room.m_upPlayer_level = 2;
end



SelectPlayerDialog.hardBtnClick = function(self)
    self.m_easy_btn:setEnable(true);
    self.m_normal_btn:setEnable(true);
    self.m_hard_btn:setEnable(false);

    SelectPlayerDialog.resetStar(self.m_easy_btn,false)
    SelectPlayerDialog.resetStar(self.m_normal_btn,false)
    SelectPlayerDialog.resetStar(self.m_hard_btn,true)

    self.m_room.m_upPlayer_level = 3;
end

SelectPlayerDialog.resetStar = function(view,show)
    local starGroup = view:getChildByName("star");
    if starGroup then
        local childrens = starGroup:getChildren();
        for i,v in pairs(childrens) do
            if v and v.setFile then
                v.setFile(v, show and "online/room/dialog/star_pre.png" or "online/room/dialog/star.png");
            end
        end
    end
end


SelectPlayerDialog.dismiss = function(self,flag)
    local w,h = self.m_bg_view:getSize();
    self.m_bg_view:removeProp(2);
    self.m_dismissStatus = true;
    local anim = self.m_bg_view:addPropTranslate(2,kAnimNormal,400,-1,0,0,0,h);
    anim:setEvent(self,
    function()
        self.m_dismissStatus = false;
        self:setVisible(false);
        self.m_bg_view:removeProp(2);
    end);
    self.super.dismiss(self,false);
    if flag == false then
        return;
    end
    self.m_room:onLineBack();
end

SelectPlayerDialog.quit_game = function(self)
    self.m_room:onLineBack();
end

SelectPlayerDialog.start_game = function(self)
--    self:setVisible(false);
--    self.super.dismiss(self,false);
    self.super.dismiss(self,false);
    local w,h = self.m_bg_view:getSize();
    self.m_bg_view:removeProp(2);
    local anim = self.m_bg_view:addPropTranslate(2,kAnimNormal,400,-1,0,0,0,h);
    anim:setEvent(self,
    function()
        self:setVisible(false);
        self.m_bg_view:removeProp(2);
        self.m_room:matchRoom();
    end);
end