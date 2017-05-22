require(VIEW_PATH .. "select_sex_dialog_view");
require(BASE_PATH.."chessDialogScene")

SelectSexDialog = class(ChessDialogScene,false);

SelectSexDialog.ctor = function(self)
	super(self,select_sex_dialog_view);
	self.m_root_view = self.m_root;
    self.m_bg_view = self.m_root_view:getChildByName("bg");
    self:setShieldClick(self,self.dismiss);
    self.m_bg_view:setEventTouch(self.m_bg_view,function() end);

    self.m_man_btn = self.m_bg_view:getChildByName("man_btn");
    self.m_woman_btn = self.m_bg_view:getChildByName("woman_btn");
    self.m_private_btn = self.m_bg_view:getChildByName("private_btn");
    self.m_close_btn = self.m_bg_view:getChildByName("close_btn");
    
    self.m_man_btn:setOnClick(self,function()
        self:saveUserInfo(1);
    end);
    self.m_woman_btn:setOnClick(self,function()
        self:saveUserInfo(2);
    end);
    self.m_private_btn:setOnClick(self,function()
        self:saveUserInfo(0);
    end);
    self.m_close_btn:setOnClick(self,self.dismiss);
end
----性别 性别 0 未知 1 男 2 女
SelectSexDialog.saveUserInfo = function(self,sex)
    local post_data = {};
--    post_data.iconType = UserInfo.getInstance():getIconType();
--	post_data.mnick = UserInfo.getInstance():getName();
	post_data.sex = sex;
    HttpModule.getInstance():execute(HttpModule.s_cmds.uploadMySet,post_data);
    self:dismiss();
end

SelectSexDialog.dtor = function(self)
    delete(self.m_root_view);
end

SelectSexDialog.isShowing = function(self)
	return self:getVisible();
end


SelectSexDialog.show = function(self)
    local w,h = self.m_bg_view:getSize();
    local anim = self.m_bg_view:addPropTranslate(1,kAnimNormal,300,-1,0,0,h,0);
    if anim then
        anim:setEvent(self,function()
            self.m_bg_view:removeProp(1);
        end);
    end
    self:setVisible(true);
    self.super.show(self,false);
end;


SelectSexDialog.dismiss = function(self)
    local w,h = self.m_bg_view:getSize();
    self.m_bg_view:removeProp(2);
    local anim = self.m_bg_view:addPropTranslate(2,kAnimNormal,300,-1,0,0,0,h);
    anim:setEvent(self,
    function()
        self:setVisible(false);
        self.m_bg_view:removeProp(2);
    end);
    self.super.dismiss(self,false);
end
