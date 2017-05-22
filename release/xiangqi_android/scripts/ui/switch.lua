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

--   Switch是一个用于在“开”、“关”状态切换的控件。“开”、“关”状态由一个背景图片和一个左右移动的切换按钮构成，单击该控件即可实现“开”、“关”状态之间的切换。
-- 控件在“开”、“关”状态之间的切换的过程中，可以设置是否播放切换按钮移动动画。对于切换过程耗时的情况，可以选择在单击时进入pending状态。待任务处理完以后，
-- 调用restore()来恢复到目标状态。
-- 
-- 一些说明：
--     除了按钮图片，其它图片大小应该保持一致。
--     状态切换动画在完成前不接收手指指令。
--     pending状态完成前不接收手指指令，也无法修改状态。
--     setChecked可以随时切换状态并生效，但是没有动画效果。如果当前正处于状态切换动画，那么先停止动画，再执行切换。pending状态是例外，在该状态下无法通过setChecked来切换。
--     如果当前处于pending状态，那么直到pending状态结束前，以上手指、setChecked()等命令无效。
--     为了保持向下兼容，onChange仅仅在用手操作的情况下会通知。为了保持和原有控件行为的一致性，pending结束后若改变开关状态，也会调用onChange。
--     pending状态的动画可以选择是否在原背景图的基础上叠加。
--


require("core/constants");
require("core/object");
require("core/global");
require("ui/node");
require("ui/image");
require("ui/images");

Switch = class(Node);

Switch.s_defaultOnFile = "ui/switchOn.png";
Switch.s_defaultOffFile = "ui/switchOff.png";
Switch.s_defaultButtonFile = "ui/switchButton.png";

Switch.setDefaultImages = function(onFile, offFile, buttonFile)
    Switch.s_onFile = onFile or Switch.s_defaultOnFile;
    Switch.s_offFile = offFile or Switch.s_defaultOffFile;
    Switch.s_buttonFile = buttonFile or Switch.s_defaultButtonFile;
end

--- 状态切换动画的默认总时长。单位：毫秒。
Switch.s_defaultAnimationLength = 150; 

--- 设置状态切换动画的默认总时长。单位：毫秒。
-- @param #number value 新的总时长。
Switch.setDefaultAnimationLength = function (value)
    Switch.s_defaultAnimationLength = value;
end

--- 动画版pending默认的每一帧图片。这是一个数组，每个元素是一个字符串，对应相应的图片文件。
Switch.s_defaultPendingAnimationImages = (function ()
    local images = {};

    for i = 1, 8 do 
        images[i] = 'ui/switchPendingImages/' .. i .. '.png';
    end

    return images;
end)()

--- 设置动画版pending默认的每一帧图片。
-- @param #table value 新的默认每一帧图片。
Switch.setDefaultPendingAnimationImages = function (value)  
    Switch.s_defaultPendingAnimationImages = value;
end

--- 动画版pending的每两帧图片之间的默认间隔时间。单位：毫秒。
Switch.s_defaultPendingAnimationImagesInterval = 60;

--- 设置动画版pending的每两帧图片之间的默认间隔时间。单位：毫秒。
-- @param #number value 新的间隔时间。
Switch.setDefaultPendingAnimationImagesInterval = function (value)
    Switch.s_defaultPendingAnimationImagesInterval = value;
end


--- 静态图片版pending的默认图片。
Switch.s_defaultStaticPendingAnimationImage = 'ui/switchPendingImages/static.png';

--- 设置静态图片版pending的默认图片。
-- @param #string value 新的图片文件。
Switch.setDefaultStaticPendingAnimationImage = function (value)
    Switch.s_defaultStaticPendingAnimationImage = value;
end


Switch.ctor = function(self, width, height, onFile, offFile, buttonFile, pendingAnimationImages, staticPendingAnimationImage)
    onFile = onFile or Switch.s_onFile or Switch.s_defaultOnFile;
    offFile = offFile or Switch.s_offFile or Switch.s_defaultOffFile;
    buttonFile = buttonFile or Switch.s_buttonFile or Switch.s_defaultButtonFile;

    self.m_needAnimation = false;
    self:setPendingCallback(nil, nil);
    self.m_animationProp = nil;
    self.m_pendingAnim = nil;
    self.m_animationLength = Switch.s_defaultAnimationLength;
    self.m_pendingState = false;
    self.m_pendingImagesArray = pendingAnimationImages or Switch.s_defaultPendingAnimationImages;
    self.m_staticPendingImageFile = staticPendingAnimationImage or Switch.s_defaultStaticPendingAnimationImage;
    self.m_pendingAnimationImagesInterval = Switch.s_defaultPendingAnimationImagesInterval;
    self.m_pendingOverlay = false;

    self.m_onImage = new(Image,onFile);
    self.m_offImage = new(Image,offFile);
    self.m_buttonImage = new(Image,buttonFile);
    self.m_buttonImage:setAlign(kAlignLeft);
    self.m_staticPendingImage = new(Image, self.m_staticPendingImageFile);

    self.m_pendingImages = new(Images, self.m_pendingImagesArray);
    self.m_pendingImages:setImageIndex(0);

    local onWidth,onHeight = self.m_onImage:getSize();
    local scale = Switch.calculateScale(self,width,height,onWidth,onHeight);

    width,height = Switch.calculateSize(self,self.m_onImage,scale);
    self.m_buttonWidth,self.m_buttonHeight = Switch.calculateSize(self,self.m_buttonImage,scale);

    self.m_onImage:setSize(width,height);
    self.m_offImage:setSize(width,height);
    self.m_pendingImages:setSize(width,height);
    self.m_staticPendingImage:setSize(width,height);
    self.m_buttonImage:setSize(self.m_buttonWidth,self.m_buttonHeight);
    Switch.addChild(self,self.m_onImage);
    Switch.addChild(self,self.m_offImage);
    Switch.addChild(self,self.m_buttonImage);
    Switch.addChild(self,self.m_pendingImages);
    Switch.addChild(self,self.m_staticPendingImage);

    self.m_pendingImages:setVisible(false);
    self.m_staticPendingImage:setVisible(false);

    Node.setSize(self,width,height);
    Node.setClip(self,self.m_x,self.m_y,self.m_width,self.m_height);

    self:setEventTouch(self,self.onButtonClick);

    Switch.setOn(self);

    self.m_eventCallback = {};

    self:setChecked(true)
end

Switch.setPos = function(self, x, y)
    Node.setPos(self,x,y);
    Node.setClip(self,self.m_x,self.m_y,self.m_width,self.m_height);
end

Switch.setSize = function(self, width, height)

end

Switch.setAlign = function(self, align)
    Node.setAlign(self,align);
    Node.setClip(self,self.m_x,self.m_y,self.m_width,self.m_height);
end

Switch.setClip = function(self, x, y, w, h)

end

Switch.setChecked = function(self,checked)
    if self:isPending() then 
        return;        
    end

    if self.m_animationProp then 
        self:removeAnimationPropIfPossible();
    else 
        if self.m_state == checked then
            return;
        end
    end 

    self:updateChecked(checked);
end


Switch.isChecked = function(self)
    return self.m_state;
end

Switch.isNeedAnimation = function (self)
    return self.m_needAnimation;
end

--- 设置是否启用动画效果。在动画的过程中设置该值，会在下次操作时生效。
-- @param #Switch self 对象实例。
-- @param #boolean value 新的值。
Switch.setNeedAnimation = function (self, value)
    self.m_needAnimation = value;
end

--- 
-- 在刚进入pending状态的时候，会调用func(obj, newChecked)，newChecked为boolean类型，表示目标开关状态。
-- func(obj, newChecked)返回一个boolean值，若返回false，则不进入pending状态，继续播放animation动画；
-- 返回true则会进入pending状态，进入pending状态后通过调用restore来进入目标状态。
-- 用这个函数来设置func和obj。若func为nil，则pending过程不会开始。
-- @param #Switch self 对象实例。
-- @param obj 传给func的值，类型任意。
-- @param #function func 刚进入pending的时候的回调函数。
Switch.setPendingCallback = function (self, obj, func)
    if func then 
        self.m_pendingCallback = function (newChecked)
            return func(obj, newChecked);
        end
    else 
        self.m_pendingCallback = function (...)
            return false;
        end
    end 
end

---
-- 判断当前是否正在pending状态。若在pending状态，必须restore()以后才能继续进行操作。
Switch.isPending = function (self)
    return self.m_pendingState;    
end


Switch.getAnimationLength = function (self)
    return self.m_animationLength;
end

--- 设置状态切换动画的总时长。在动画的过程中设置该值，会在下次操作时生效。
-- @param #Switch self 对象实例。
-- @param #boolean value 新的值。
Switch.setAnimationLength = function (self, value)
    self.m_animationLength = value;
end

--- 设置动画版pending的每两帧图片之间的间隔时间。单位：毫秒。
-- @param #Switch self 对象实例。
-- @param #number value 新的间隔时间。
Switch.setPendingAnimationImagesInterval = function (self, value)
    self.m_pendingAnimationImagesInterval = value;
end


--- 设置pending时的图片是否叠加放在开关图片的上面。若为true，则pending时的图片叠加放在开关图片上面；否则，pending时只显示pending动画。
-- 若在pending的过程中设置该值，会在下次操作时生效。
-- @param #Switch self 对象实例。
-- @param #boolean value 是否形成一个叠加层。
Switch.setPendingOverlay = function (self, value)
    self.m_pendingOverlay = value;
end 

Switch.isPendingOverlay = function (self)
    return self.m_pendingOverlay;
end 

--- 从pending状态返回到正常状态。并且设置目标开关状态为newChecked。
-- @param #Switch self 对象实例。
-- @param #boolean newChecked 目标开关状态。
Switch.restore = function (self, newChecked) 
    if not self:isPending() then 
        return;
    end

    if self.m_pendingAnim then 
        delete(self.m_pendingAnim);
        self.m_pendingAnim = nil;
    end 

    self.m_pendingImages:setVisible(false);
    self.m_staticPendingImage:setVisible(false);

    self.m_pendingState = false;
    
    local invokeStateChange = true;
    if newChecked == self.m_state then 
        invokeStateChange = false;
    end 

    self:updateChecked(newChecked); 

    if invokeStateChange then 
        if self.m_eventCallback.func then
            self.m_eventCallback.func(self.m_eventCallback.obj,self.m_state);
        end
    end 

end

Switch.setOnChange = function(self, obj, func)
    self.m_eventCallback.obj = obj;
    self.m_eventCallback.func = func;
end

Switch.dtor = function(self)
    self:removeAnimationPropIfPossible();

    if self.m_pendingAnim then
        delete(self.m_pendingAnim);
        self.m_pendingAnim = nil;
    end
end

---------------------------------private functions-----------------------------------------

--virtual
Switch.setParent = function(self, parent)
    Node.setParent(self,parent);
    Node.setClip(self,self.m_x,self.m_y,self.m_width,self.m_height);
end

Switch.onButtonClick = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
    if self.m_animationProp then 
        return;
    end 

    if self.m_pendingState then 
        return;
    end

    if finger_action == kFingerDown then
        if self.m_pendingCallback(not self.m_state) then 
            -- enter pending state

            if not self.m_pendingOverlay then 
                self.m_onImage:setVisible(false);
                self.m_offImage:setVisible(false);
                self.m_buttonImage:setVisible(false);
            end

            if self.m_needAnimation then 
                self.m_pendingImages:setVisible(true);
                self.m_staticPendingImage:setVisible(false);

                self.m_pendingAnim = (function ()
                    local index = 0;
                    local imageCount = #(self.m_pendingImagesArray);
                    local anim = new(AnimDouble,kAnimRepeat,0,0,self.m_pendingAnimationImagesInterval,0);        
                    anim:setEvent(nil, function ()
                        index = (index + 1) % imageCount;
                        self.m_pendingImages:setImageIndex( index );
                    end)
                    return anim
                end)()
            else
                self.m_pendingImages:setVisible(false);
                self.m_staticPendingImage:setVisible(true);
            end  

            self.m_pendingState = true;
        else 
            if self.m_needAnimation then 
                self:setWithAnimation(not self.m_state);
            else 
                Switch.setChecked(self,not self.m_state);
                if self.m_eventCallback.func then
                    self.m_eventCallback.func(self.m_eventCallback.obj,self.m_state);
                end
            end 
        end 
    end
end

Switch.calculateScale = function(self, width, height, onWidth, onHeight)
    width = (width and width > 0) and width or onWidth;
    height = (height and height > 0) and height or onHeight;

    local scaleW = width / onWidth;
    local scaleH = height / onHeight;
    local scale = scaleW > scaleH and scaleW or scaleH;

    return scale;
end

Switch.calculateSize = function(self, image, scale)
    local width,height = image:getSize();

    width = width * scale;
    height = height * scale;

    return width,height;
end

Switch.removeAnimationPropIfPossible = function (self)
    if self.m_animationProp then 
        self.m_animationProp = nil;
        self.m_buttonImage:removeProp(0);
    end
end



Switch.setOn = function(self)
    self.m_buttonImage:setVisible(true);
    self.m_buttonImage:setPos(self.m_width - self.m_buttonWidth);
    self.m_offImage:setVisible(false);
    self.m_onImage:setVisible(true);
end

Switch.setOff = function(self, isNeedAnimation)
    self.m_buttonImage:setVisible(true);
    self.m_buttonImage:setPos(0);
    self.m_onImage:setVisible(false);
    self.m_offImage:setVisible(true);
end

Switch.setWithAnimation = function (self, targetState)
    local offX = self.m_width - self.m_buttonWidth;

    if not targetState then 
        offX = - offX;
    end

    self.m_animationProp = self.m_buttonImage:addPropTranslate(
            0,                     
            kAnimNormal,           
            self.m_animationLength,                  
            0,                     
            0,                     
            offX,                  
            0,                     
            0                      
        );

    self.m_animationProp:setEvent(nil, function ()         
        self:removeAnimationPropIfPossible();
        
        if targetState then 
            self:setOn();
        else 
            self:setOff();
        end

        self.m_state = targetState;
        
        if self.m_eventCallback.func then
            self.m_eventCallback.func(self.m_eventCallback.obj,self.m_state);
        end
    end)        
end

Switch.updateChecked = function(self,checked)
    self.m_state = checked;

    if self.m_state then
        Switch.setOn(self, false);
    else
        Switch.setOff(self, false);
    end
end
