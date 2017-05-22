--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require(VIEW_PATH .. "notice_view_mail_dialog_view");
require(BASE_PATH.."chessDialogScene")

NewNoticeDialog = class(ChessDialogScene,false);

NewNoticeDialog.s_max_h = 842;
NewNoticeDialog.s_bg_diff_h = 292;

NewNoticeDialog.ctor = function(self)
    super(self,notice_view_mail_dialog_view);
    self.m_bg = self.m_root:getChildByName("bg"); 

    self:setShieldClick(self,self.dismiss);
    self.m_bg:setEventTouch(self,function()end);

    self.m_title = self.m_bg:getChildByName("title");
    self.m_content_view = self.m_bg:getChildByName("content_view");
    self.m_btn1 = self.m_bg:getChildByName("btn_2");
    self.m_btn1:setOnClick(self,self.onBtnClick);
    --self.m_btn2 = self.m_bg:getChildByName("btn2");
    --self.m_btn2:setOnClick(self,self.dismiss);

    --self.m_blank = self.m_root:getChildByName("blank");
    --self.m_blank:setTransparency(0.2);
    self.close_btn = self.m_bg:getChildByName("close_btn");
    self.close_btn:setOnClick(self,self.dismiss);
    self:setVisible(false);
end

NewNoticeDialog.show = function(self)
    self.m_dismissIng = false;
	self:setVisible(true);
	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW); -- 添加弹窗音效
    self.super.show(self,false);

    if not self.m_bg:checkAddProp(1) then
        self.m_bg:removeProp(1);
    end
    local w,h = self.m_bg:getSize();
    self.m_anim = self.m_bg:addPropTranslate(1, kAnimNormal, 400, -1, 0, 0, -h, 0);
    self.m_anim:setEvent(self,function()
        self.m_bg:removeProp(1);
        delete(self.m_anim);
    end);
end

NewNoticeDialog.setTitle = function(self,text)
    local txt = text or "系统公告";
    self.m_title:setText(txt);

end

NewNoticeDialog.setContentText = function(self,text)
    --[[local txt = text or "";
    self.m_content_view:removeAllChildren(true);
    local w,h = self.m_content_view:getSize();
    local richText = new(RichText,txt,w,0,kAlignTopLeft, nil, 32, 80, 80, 80, true,2);
    
    local w,h = richText:getSize();
    if NewNoticeDialog.s_max_h < h then
        h = NewNoticeDialog.s_max_h;
    end
    self.m_content_view:setSize(nil,h);
    self.m_bg:setSize(nil,NewNoticeDialog.s_bg_diff_h+h);
    self.m_content_view:addChild(richText);
    ]]--
    delete(self.richText);
    local w,h = self.m_content_view:getSize();
    self.richText = new(RichText,text, w, h, kAlignTopLeft, "", 28, 80, 80, 80, true,5);
    self.m_content_view:addChild(self.richText);
end

NewNoticeDialog.setBtnText = function(self,text)
    local txt = text or "查看";
    self.m_btn1:getChildByName("btn_text"):setText(txt);
end

NewNoticeDialog.onBtnClick = function(self)
    if self.m_btn_func and type(self.m_btn_func) == 'function' then
        self.m_btn_func(self.m_btn_obj);
    end
    self:dismiss();
end

NewNoticeDialog.setBtnClick = function(self,obj,func)
    self.m_btn_func = func;
    self.m_btn_obj = obj;
end

NewNoticeDialog.dismiss = function(self)
	kEffectPlayer:playEffect(Effects.AUDIO_DIALOG_SHOW); -- 添加弹窗音效
    self.super.dismiss(self,false);
    if not self.m_bg:checkAddProp(1) then
        self.m_bg:removeProp(1);
    end
    self.m_dismissIng = true;
    local w,h = self.m_bg:getSize();
--    self.m_bg:addPropTransparency(2,kAnimNormal,300,-1,1,0);
    self.m_anim_end = self.m_bg:addPropTranslate(1, kAnimNormal, 200, -1, 0, 0, 0, -h);
    self.m_anim_end:setEvent(self,function()
        self.m_bg:removeProp(1);
        self:setVisible(false);
        delete(self.m_anim_end);
        self.m_dismissIng = false;
    end);
end

NewNoticeDialog.isShowing = function(self)
    if self.m_dismissIng then
        return false;
    end
    return self.super.isShowing(self);
end


NewNoticeDialog.dtor = function(self)
  delete(self.m_anim_end);
  delete(self.m_anim);
end

--endregion
