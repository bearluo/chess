--
-- UI2 Library, Version: 1.0 Alpha (0.99.2.2058-SNAPSHOT)
-- 
-- This file is a part of UI2 Library.
--
-- Author:
-- Xiaofeng Yang     2015
-- Vicent.Gong       2013
--
--

require("core/constants");
require("core/object");
require("ui/node");
require("ui/image");

Slider = class(Node);

Slider.s_defaultBgImage = "ui/sliderBg.png";
Slider.s_defaultFgImage = "ui/sliderFg.png";
Slider.s_defaultButtonImage = "common/decoration/choice_icon.png";

Slider.setDefaultImages = function(bgImage, fgImage, buttonImage)
    Slider.s_bgImage = bgImage or Slider.s_defaultBgImage;
    Slider.s_fgImage = fgImage or Slider.s_defaultFgImage;
    Slider.s_buttonImage = buttonImage or Slider.s_defaultButtonImage;
end

Slider.ctor = function(self, width, height, bgImage, fgImage, buttonImage, leftWidth, rightWidth, topWidth, bottomWidth)
    self.m_bgImage = bgImage or Slider.s_bgImage or Slider.s_defaultBgImage;
    self.m_fgImage = fgImage or Slider.s_fgImage or Slider.s_defaultFgImage;
    self.m_buttonImage = buttonImage or Slider.s_buttonImage or Slider.s_defaultButtonImage;

    self.m_bg = new(Image,self.m_bgImage,nil,nil,leftWidth,rightWidth,topWidth,bottomWidth);
    width = (width and width >= 1) and width or self.m_bg:getSize();
    height = (height and height >= 1) and height or select(2,self.m_bg:getSize());
    
    Slider.setSize(self,width,height);
    
    Slider.addChild(self,self.m_bg);
    self.m_bg:setFillParent(true,true);
    self.m_bg:setEventTouch(self,self.onBackgroundEventTouch);

    self.m_fg = new(Image,self.m_fgImage,nil,nil,leftWidth,rightWidth,topWidth,bottomWidth);

    Slider.addChild(self,self.m_fg);
    self.m_fg:setFillParent(true,true);    
    
    self.m_button = new(Image,self.m_buttonImage);
    Slider.addChild(self,self.m_button);
    self.m_button:setAlign(kAlignLeft);
    self.m_button:setPos(0,0);
    self.m_button:setEventTouch(self,self.onEventTouch);
    
    self.m_width = width;
    Slider.setProgress(self,1.0);

    self.m_changeCallback = {};
end

Slider.setImages = function(self, bgImage, fgImage, buttonImage)
    self.m_bgImage = bgImage or Slider.s_bgImage or Slider.s_defaultBgImage;
    self.m_fgImage = fgImage or Slider.s_fgImage or Slider.s_defaultFgImage;
    self.m_buttonImage = buttonImage or Slider.s_buttonImage or Slider.s_defaultButtonImage;

    self.m_bg:setFile(self.m_bgImage);
    self.m_fg:setFile(self.m_fgImage);
    self.m_button:setFile(self.m_buttonImage);
end

Slider.setProgress = function(self, progress)
    progress = progress > 1 and 1 or progress;
    progress = progress < 0 and 0 or progress;
    self.m_progress = progress;
    
    local buttonW,buttonH = self.m_button:getSize();
    local buttonX = self.m_progress*self.m_width - buttonW/2;
    self.m_button:setPos(buttonX);
    self.m_fg:setClip(0,0,self.m_width*self.m_progress,buttonH);
    if self.m_changeCallback.func then
        self.m_changeCallback.func(self.m_changeCallback.obj,self.m_progress);
    end 
end

Slider.getProgress = function(self)
    return self.m_progress;
end

Slider.setEnable = function(self, enable)
    self.m_button:setPickable(enable);
end

Slider.setButtonVisible = function(self, visible)
    self.m_button:setVisible(visible);
end

Slider.setOnChange = function(self, obj, func)
    self.m_changeCallback.obj = obj;
    self.m_changeCallback.func = func;
end

Slider.dtor = function(self)
    
end

---------------------------------private functions-----------------------------------------

Slider.onEventTouch = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
    if finger_action == kFingerDown then
        self.m_dragingX = x;
        self.m_button:setColor(128,128,128);
    else 
        local bgX, bgY = self:getAbsolutePos();

        local notifyChange = function ()
            if self.m_changeCallback.func then
                self.m_changeCallback.func(self.m_changeCallback.obj,self.m_progress);
            end 
        end

        if (bgX <= x) and (self.m_width + bgX >= x) then 
            local diffX = x - self.m_dragingX;
            local progress = self.m_progress + diffX/self.m_width;
            Slider.setProgress(self,progress);
            self.m_dragingX = x;
        
            notifyChange();
        elseif (x < bgX) and (self.m_progress > 0) then 
            -- 移动太快，刚跳出边界时，校正下。
            Slider.setProgress(self,0);
            self.m_dragingX = bgX;
        
            notifyChange();
        elseif (x > self.m_width + bgX) and (self.m_progress < 1) then 
            -- 移动太快，刚跳出边界时，校正下。
            Slider.setProgress(self,1);
            self.m_dragingX = self.m_width + bgX;
        
            notifyChange();
        end 

        if finger_action ~= kFingerMove then
            self.m_button:setColor(255,255,255);
        end
    end
end

Slider.onBackgroundEventTouch = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
    if finger_action == kFingerDown then
        local bgX, bgY = self:getAbsolutePos();
        local deltaX = x - bgX;
        local progress = deltaX/self.m_width;

        Slider.setProgress(self,progress);
    end 

    self:onEventTouch(finger_action, x, y, drawing_id_first, drawing_id_current);
end
