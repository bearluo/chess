-- effectAnim.lua
-- LeoLi
-- 2016/8/26
-- 文件封装了一些常用的效果动画

EffectAnim = class()

EffectAnim.ctor = function(self)

end;

EffectAnim.dtor = function(self)

end;

EffectAnim.getInstance = function(self)
    if not EffectAnim.instance then
        EffectAnim.instance = new(EffectAnim);
    end;
    return EffectAnim.instance;
end;

-- 左出右进动画
EffectAnim.leftOutRightIn = function(obj,leftView, rightView, time,callBackFun)
    leftView:setVisible(true);
    local leftW,leftH = leftView:getSize();
    -- leftSlide
    local leftAnim = leftView:addPropTranslate(0,kAnimNormal,time,-1,0,-leftW,nil,nil);
    if not leftAnim then return end;
    leftAnim:setEvent(nil, function() 
        leftView:removeProp(0);
    end);
    -- leftTransparency
    local leftTransparency = leftView:addPropTransparency(1,kAnimNormal,time,0,1,0);
    if not leftTransparency then return end;
    leftTransparency:setEvent(nil, function() 
        leftView:setVisible(false);
        leftView:removeProp(1);
    end);
    -- rightSlide
    rightView:setVisible(true);
    local rightW,rightH = rightView:getSize();
    local rightAnim = rightView:addPropTranslate(0,kAnimNormal,time,0,rightW,0,nil,nil);
    if not rightAnim then return end;
    rightAnim:setEvent(nil, function() 
        rightView:removeProp(0);
        if callBackFun then
            callBackFun(obj);
        end;
    end);
    -- rightTransparency
    local rightTransparency = rightView:addPropTransparency(1,kAnimNormal,time,0,0,1);
    if not rightTransparency then return end;
    rightTransparency:setEvent(nil, function() 
        rightView:removeProp(1);
    end);
end;

-- 左进右出动画
EffectAnim.leftInRightOut = function(obj,leftView, rightView,time,callBackFun)
    -- leftSlide
    leftView:setVisible(true);
    local leftW,leftH = leftView:getSize();
    local leftAnim = leftView:addPropTranslate(1,kAnimNormal,time,0,-leftW,0,nil,nil);
    if not leftAnim then return end;
    leftAnim:setEvent(nil, function() 
         leftView:removeProp(1);  
         if callBackFun then
            callBackFun(obj);
         end;     
    end)
    -- leftTransparency
    local leftTransparency = leftView:addPropTransparency(2,kAnimNormal,time,0,0,1);
    if not leftTransparency then return end;
    leftTransparency:setEvent(nil, function() 
        leftView:removeProp(2);
    end);
    -- rightSlide
    rightView:setVisible(true);
    local rightW,rightH = rightView:getSize();
    local rightAnim = rightView:addPropTranslate(1,kAnimNormal,time,0,0,rightW,nil,nil);
    if not rightAnim then return end;
    rightAnim:setEvent(nil, function() 
        rightView:removeProp(1);      
    end);
    -- rightTransparency
    local rightTransparency = rightView:addPropTransparency(2,kAnimNormal,time,0,0.05,0);
    if not rightTransparency then return end;
    rightTransparency:setEvent(nil, function() 
        rightView:setVisible(false);
        rightView:removeProp(2);
    end);
end;

-- 淡入淡出动画
EffectAnim.fadeInAndOut = function(obj, fadeInView, fadeOutView ,time,callback)
    if fadeInView then
        fadeInView:setVisible(true); 
        local up_fade_anim = fadeInView:addPropTransparency(1,kAnimNormal,time,0,0,1);
        if not up_fade_anim then return end;
        up_fade_anim:setEvent(nil, function() 
            fadeInView:removeProp(1);
            if callback then
                callback(obj);
            end;      
        end);
    end;

    if fadeOutView then
        fadeOutView:setVisible(true);
        local down_fade_anim = fadeOutView:addPropTransparency(1,kAnimNormal,time,0,1,0);
        if not down_fade_anim then return end;
        down_fade_anim:setEvent(nil, function() 
            fadeOutView:removeProp(1);  
            fadeOutView:setVisible(false);    
            if callback then
                callback(obj);
            end;   
        end);
    end;
end;

-- 从小到大/大到小动画
EffectAnim.scaleBigAndSmall = function(obj, bigView, smallView, time,x,y,callback)
    if bigView then
        bigView:setVisible(true); 
        local big_anim = bigView:addPropScale(11,kAnimNormal,time,0,0.4,1,0.4,1,kCenterXY,x,y);
        if not big_anim then return end;
        big_anim:setEvent(nil, function() 
            bigView:removeProp(11);      
        end);
        local up_big_anim = bigView:addPropTransparency(12,kAnimNormal,time,0,0,1);
        if not up_big_anim then return end;
        up_big_anim:setEvent(nil, function() 
            bigView:removeProp(12);     
            if callback then
                callback(obj);
            end;    
        end);
    end;

    if smallView then
        smallView:setVisible(true);
        local small_anim = smallView:addPropScale(11,kAnimNormal,time,0,1,0.4,1,0.4,kCenterXY,x,y);
        if not small_anim then return end;
        small_anim:setEvent(nil, function() 
            smallView:removeProp(11);      
        end);
        local up_small_anim = smallView:addPropTransparency(12,kAnimNormal,time,0,0,1);
        if not up_small_anim then return end;
        up_small_anim:setEvent(nil, function() 
            smallView:removeProp(12);     
            if callback then
                callback(obj);
            end;    
        end);
    end;

end;

-- 向上滑动动画
EffectAnim.moveUp = function(obj, upView, h,time,callback)
    local upW,upH = upView:getSize();
    local upAnim = new(AnimInt,kAnimRepeat,0,1,time, 0);
    if not upAnim then return end;
    upAnim:setEvent(nil, function() 
        if upH > h then
             upView:removeProp(1);  
             upView:setSize(upW,h);
             if callback then
                callback(obj);
             end; 
             delete(upAnim);
             upAnim = nil;
        else
            upH = upH + 30;
            upView:setSize(upW,upH);
        end;    
    end)    
end;

-- 向下滑动动画
EffectAnim.moveDown = function(obj, downView,h, time,callback)
    local downW,downH = downView:getSize();
    local downAnim = new(AnimInt,kAnimRepeat,0,1,time, 0);
    if not downAnim then return end;
    downAnim:setEvent(nil, function() 
        if downH < h then
             downView:removeProp(1);  
             downView:setSize(downW,h);
             if callback then
                callback(obj);
             end;              
             delete(downAnim);
             downAnim = nil;
        else
            downH = downH - 30;
            downView:setSize(downW,downH);
        end;    
    end)   
end;

-- 下滑动画
EffectAnim.scrollDown = function(obj,scrollDownView,time,callBackFun,var1,var2,var3)
    if scrollDownView then 
        scrollDownView:setVisible(true);
        local scrollW,scrollH = scrollDownView:getSize();
        local scrollDownAnim = scrollDownView:addPropTranslate(0,kAnimNormal,time,0,0,0,-scrollH,0);
        if not scrollDownAnim then return end;
        scrollDownAnim:setEvent(obj, function() 
             scrollDownView:removeProp(0);  
             if callBackFun then
                callBackFun(obj,var1,var2,var3);
             end;     
        end)
        -- leftTransparency
        local scrollDownTransparency = scrollDownView:addPropTransparency(1,kAnimNormal,time,0,0,1);
        if not scrollDownTransparency then return end;
        scrollDownTransparency:setEvent(nil, function() 
            scrollDownView:removeProp(1);
        end);
    end;
end;

-- 上滑动画
EffectAnim.scrollUp = function(obj,scrollUpView,time,callBackFun,var)
    if scrollUpView then 
        scrollUpView:setVisible(true);
        local scrollW,scrollH = scrollUpView:getSize();
        local scrollUpAnim = scrollUpView:addPropTranslate(2,kAnimNormal,time,0,0,0,0,-scrollH);
        if not scrollUpAnim then return end;
        scrollUpAnim:setEvent(obj, function() 
             scrollUpView:removeProp(2);  
        end)
        -- leftTransparency
        local scrollUpTransparency = scrollUpView:addPropTransparency(3,kAnimNormal,time,0,1,0);
        if not scrollUpTransparency then return end;
        scrollUpTransparency:setEvent(nil, function() 
            scrollUpView:removeProp(3);
            scrollUpView:setVisible(false);
            if callBackFun then
                callBackFun(obj,var);
            end;     
        end);
    end;
end;