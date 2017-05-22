--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require(VIEW_PATH .. "push_action_dialog_view");
require(BASE_PATH.."chessDialogScene")

PushActionDialog = class(ChessDialogScene,false);

PushActionDialog.ctor = function(self,data)
    super(self,push_action_dialog_view);
    self.m_data = data;
    self.m_bg = self.m_root:getChildByName("bg"); 

    self:setShieldClick(self,self.dismiss);
    self.m_bg:setEventTouch(self,function()end);

    self.m_closeBtn = self.m_bg:getChildByName("close_btn");
    self.m_closeBtn:setOnClick(self,self.dismiss);

    self.m_contentView = self.m_bg:getChildByName("content_bg"):getChildByName("scroll_view");
    self.m_contentView.m_autoPositionChildren = true;
    local w,h = self.m_contentView:getSize();
    local str = self.m_data.details or ""
    self.m_richText = new(RichText," #l" .. str .. "#l", w, 0, kAlignTopLeft, nil, 30, 80, 80, 80, true,5);
    self.m_imageIcon = new(Image,"common/background/activity_bg.png");
    self.m_imageIcon:setSize(w,nil);
    self.m_imageIcon:setUrlImage(self.m_data.img_url);
    self.m_contentView:addChild(self.m_richText);
    self.m_contentView:addChild(self.m_imageIcon);

    self.m_confirmBtn = self.m_bg:getChildByName("confirm_btn");
    self.m_confirmBtn:setOnClick(self,self.onConfirmBtnClick);
end

PushActionDialog.onConfirmBtnClick = function(self)
    self:showNativeListWebView(self.m_data.info_url);
    self:dismiss();
end

PushActionDialog.showNativeListWebView = function(self,url)
    local absoluteX,absoluteY = 0,0;
    local x = absoluteX*System.getLayoutScale();
    local y = absoluteY*System.getLayoutScale();
    local width = System.getScreenWidth();
    local height = System.getScreenHeight();
    NativeEvent.getInstance():showActivityWebView(x,y,width,height,url);
end

PushActionDialog.dtor = function(self)
end

--endregion
