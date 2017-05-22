--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--应用启动页面
--endregion
require(VIEW_PATH .. "start_dialog_view");
require("gameBase/gameLayer");

StartDialog = class(GameLayer,false);

StartDialog.SHOW_TIME_DEFAULT = 5000;  --默认显示时间 5s
--StartDialog.s_mask_bg = "drawable/transparent_blank.png"; --默认显示的遮罩
StartDialog.s_dialogLayer = nil;

StartDialog.ctor = function(self,config_data)
    super(self,start_dialog_view);
    if not StartDialog.s_dialogLayer then
        StartDialog.s_dialogLayer = new(Node);
        StartDialog.s_dialogLayer:addToRoot();
        StartDialog.s_dialogLayer:setLevel(101);     
        StartDialog.s_dialogLayer:setFillParent(true,true);
    end

    StartDialog.s_dialogLayer:addChild(self);
    self:setFillParent(true,true);
    self.m_root:setLevel(1);
    self.m_root_view = self.m_root;
    self:setEventTouch(self,self.setShieldClick);
    self.config_data = config_data;
    self:createView(self.config_data);
    self:setVisible(false);
end

StartDialog.dtor = function(self)
    self.m_ad_img:removeProp(1);
    self.timer_anim = nil;
    delete(self.timer_anim);
end

StartDialog.isShowing = function(self)
    return self:getVisible();
end

StartDialog.show = function(self)

    if not self.m_root_view:checkAddProp(1) then
        self.m_root_view:removeProp(1);
    end

    local anim = self.m_root_view:addPropTransparency(1,kAnimNormal,1000,-1,0,1);
    if anim then
        anim:setEvent(self,function()
            self:setVisible(true);
            self.m_root_view:removeProp(1);
            delete(anim);
        end);
    end

    --倒计时计时器
    delete(self.timer_anim);
    self.timer_anim = new(AnimInt,kAnimNormal,0,1,self.show_time,1000);
    self.timer_anim:setEvent(self,self.onTimerRunOut);
end

StartDialog.dismiss = function(self)
--    self.super.dismiss(self,false);
    
    if not self.m_root_view:checkAddProp(1) then
        self.m_root_view:removeProp(1);
    end

    --关闭dialog 1s
    local anim_close = self.m_root_view:addPropTransparency(1,kAnimNormal,500,-1,1,0); 
    if anim_close then
        anim_close:setEvent(self,function()
            self:setVisible(false);
            self.m_root_view:removeProp(1);
            delete(anim_close);
        end);
    end
    delete(self.timer_anim);
end

StartDialog.onTimerRunOut = function(self)
    self:dismiss();
end 

--界面初始化
StartDialog.createView = function(self,data)
    -- 倒计时时间 默认5s
    local show_time = tonumber(data.ad_second) * 1000;  --tonumber里面是毫秒
    self.show_time = show_time or StartDialog.SHOW_TIME_DEFAULT;
    -- 跳转链接地址
    self.jump_url = data.ad_jump_url;
    -- 广告图片展示
    self.m_ad_img = self.m_root_view:getChildByName("bg");
    if data.ad_img_url and data.ad_img_url ~= "" then
        self.m_ad_img:setUrlImage(data.ad_img_url);
    end
    -- 关闭按钮
    self.m_close_btn = self.m_ad_img:getChildByName("close_btn");
    self.m_close_btn:setOnClick(self,self.dismiss);
    -- 跳转按钮
    self.m_jump_btn = self.m_ad_img:getChildByName("jump_btn");
    self.m_jump_btn:setOnClick(self,self.jumpState);

end

--跳转链接
StartDialog.jumpState = function(self)
    if not self.jump_url or self.jump_url == "" then
        self:dismiss();
        return;
    end
    self:showNativeListWebView(self.jump_url);
    self:dismiss();
end;

--跳转广告展示
StartDialog.showNativeListWebView = function(self,url)
    local absoluteX,absoluteY = 0,0;
    local x = absoluteX*System.getLayoutScale();
    local y = absoluteY*System.getLayoutScale();
    local width = System.getScreenWidth();
    local height = System.getScreenHeight();
    NativeEvent.getInstance():showActivityWebView(x,y,width,height,url);
end

StartDialog.setShieldClick = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
    Log.i("StartDialog.setShieldClick");
    if finger_action == kFingerUp and drawing_id_first == drawing_id_current then
        if self:getVisible() then
            self:dismiss();
        end
    end
end