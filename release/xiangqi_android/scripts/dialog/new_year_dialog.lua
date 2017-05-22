--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--endregion

require(VIEW_PATH .. "new_year_dialog_view");
require(BASE_PATH.."chessDialogScene")

NewyearDialog = class(ChessDialogScene,false);

NewyearDialog.ctor = function(self)
    super(self,new_year_dialog_view);

    self.m_bg = self.m_root:getChildByName("bg");
    self.m_btn = self.m_bg:getChildByName("close_btn");
    self.m_btn:setOnClick(self,self.dismiss);
    self.m_btn_text = self.m_btn:getChildByName("text");
    self.time = 6;
    self:setVisible(false);
    self:setLevel(100);
end

NewyearDialog.dtor = function(self)
    delete(self.close_anim);
end

NewyearDialog.isShowing = function(self)
	return self:getVisible();
end

NewyearDialog.show = function(self)
    self:setVisible(true);
    self.super.show(self,false,nil,3);
    delete(self.chlose_anim);
    self.close_anim = new(AnimInt,kAnimRepeat,0,1,5000,-1);
    self.close_anim:setEvent(self,self.timeoutRun);
end


NewyearDialog.timeoutRun = function(self)
    self:dismiss();
    delete(self.close_anim);
end

NewyearDialog.dismiss = function(self)
    self.super.dismiss(self);
    delete(self.close_anim);
    self.close_anim = nil;
end