-- animConsoleUnlockHead.lua
-- Author: Leoli
-- Date: 2016/2/26
-- Description:单机头像解锁动画

AnimConsoleUnlockHead = {};

AnimConsoleUnlockHead.WORD_TIME             = 500; -- 文字显示时间
AnimConsoleUnlockHead.HEAD_TIME             = 500; -- 头像显示时间
AnimConsoleUnlockHead.SUNSHINE_TIME         = 500; -- 阳光显示时间

AnimConsoleUnlockHead.WORD_HIDE_TIME        = 300; -- 文字隐藏时间
AnimConsoleUnlockHead.HEAD_HIDE_TIME        = 300; -- 头像隐藏时间
AnimConsoleUnlockHead.SUNSHINE_HIDE_TIME    = 200; -- 阳光隐藏时间


AnimConsoleUnlockHead.play = function(root,gate_index)
    if not root or not gate_index then return end;
    AnimConsoleUnlockHead.reset();
    AnimConsoleUnlockHead.rootNode = new(Node);
    AnimConsoleUnlockHead.rootNode:setLevel(999);
    AnimConsoleUnlockHead.rootNode:setSize(300,400);
    AnimConsoleUnlockHead.rootNode:setPos(nil,-120);
    AnimConsoleUnlockHead.rootNode:setAlign(kAlignCenter);
    root:addChild(AnimConsoleUnlockHead.rootNode);


    -- 文字(新头像已解锁)：小→大;隐→显;
    AnimConsoleUnlockHead.wordRes = new(Image, "animation/newhead_unlock.png");
    AnimConsoleUnlockHead.wordRes:setAlign(kAlignBottom);
    AnimConsoleUnlockHead.wordRes:setLevel(1);
    AnimConsoleUnlockHead.rootNode:addChild(AnimConsoleUnlockHead.wordRes);
    local wordAnim1 = AnimConsoleUnlockHead.wordRes:addPropScale(0,kAnimNormal,AnimConsoleUnlockHead.WORD_TIME,0,0.5,1,0.5,1,kCenterDrawing);
    local wordAnim2 = AnimConsoleUnlockHead.wordRes:addPropTransparency(1,kAnimNormal,AnimConsoleUnlockHead.WORD_TIME,0,0,1);


    -- 头像：小→大;隐→显;下→上(缓动);
    AnimConsoleUnlockHead.headRes = new(Image, UserInfo.DEFAULT_ICON[gate_index + 4] or UserInfo.DEFAULT_ICON[5]);
    AnimConsoleUnlockHead.headRes:setAlign(kAlignCenter);
    AnimConsoleUnlockHead.headRes:setLevel(1);
    AnimConsoleUnlockHead.rootNode:addChild(AnimConsoleUnlockHead.headRes);
    local headAnim1 = AnimConsoleUnlockHead.headRes:addPropScaleWithEasing(0, kAnimNormal, AnimConsoleUnlockHead.HEAD_TIME, 0,"easeOutBack","easeOutBack", 0.3, 0.7, kCenterDrawing);
    local headAnim2 = AnimConsoleUnlockHead.headRes:addPropTransparency(1,kAnimNormal,AnimConsoleUnlockHead.HEAD_TIME,0,0,1);
    local headAnim3 = AnimConsoleUnlockHead.headRes:addPropTranslateWithEasing(2, kAnimNormal, AnimConsoleUnlockHead.HEAD_TIME, 0, function (...) return 0 end,"easeOutBack", 0, 0, 200, -200);


    -- 光环：隐→显→旋转;
    AnimConsoleUnlockHead.sushineRes = new(Image, "animation/unlock_head_sunshine.png");
    AnimConsoleUnlockHead.sushineRes:setVisible(false);
    AnimConsoleUnlockHead.sushineRes:setAlign(kAlignCenter);
    AnimConsoleUnlockHead.sushineRes:setSize(450,450);
    AnimConsoleUnlockHead.rootNode:addChild(AnimConsoleUnlockHead.sushineRes);
    if headAnim3 then
        headAnim3:setEvent(nil, function() 
             AnimConsoleUnlockHead.sushineRes:setVisible(true);
             local sunshineAnim1 = AnimConsoleUnlockHead.sushineRes:addPropRotate(0,kAnimRepeat,AnimConsoleUnlockHead.SUNSHINE_TIME,0,0,50,kCenterDrawing);
             if sunshineAnim1 then
                sunshineAnim1:setEvent(nil, function(a,b,c,repeat_or_loop_num) 
                    if repeat_or_loop_num == 2 then
                        AnimConsoleUnlockHead.hide();
                    end;
                end)
             end;
        end)        
    end;
end;

AnimConsoleUnlockHead.reset = function()
    if AnimConsoleUnlockHead.wordRes then
        AnimConsoleUnlockHead.wordRes:removeProp(0);
        AnimConsoleUnlockHead.wordRes:removeProp(1);
        delete(AnimConsoleUnlockHead.wordRes);
        AnimConsoleUnlockHead.wordRes = nil;
    end;
    if AnimConsoleUnlockHead.headRes then
        AnimConsoleUnlockHead.headRes:removeProp(0);
        AnimConsoleUnlockHead.headRes:removeProp(1);
        AnimConsoleUnlockHead.headRes:removeProp(2);
        delete(AnimConsoleUnlockHead.headRes);
        AnimConsoleUnlockHead.headRes = nil;
    end;
    if AnimConsoleUnlockHead.sushineRes then
        AnimConsoleUnlockHead.sushineRes:removeProp(0);
        AnimConsoleUnlockHead.sushineRes:removeProp(1);
        delete(AnimConsoleUnlockHead.sushineRes);
        AnimConsoleUnlockHead.sushineRes = nil;
    end;
end;


AnimConsoleUnlockHead.hide = function()
    if AnimConsoleUnlockHead.wordRes then
        AnimConsoleUnlockHead.wordRes:removeProp(0);
        AnimConsoleUnlockHead.wordRes:removeProp(1);
    end;
    if AnimConsoleUnlockHead.headRes then
        AnimConsoleUnlockHead.headRes:removeProp(0);
        AnimConsoleUnlockHead.headRes:removeProp(1);
        AnimConsoleUnlockHead.headRes:removeProp(2);
    end;
    if AnimConsoleUnlockHead.sushineRes then
        AnimConsoleUnlockHead.sushineRes:removeProp(0);
    end;

    -- 文字
    local wordAnim1 = AnimConsoleUnlockHead.wordRes:addPropScaleWithEasing(0, kAnimNormal, AnimConsoleUnlockHead.WORD_HIDE_TIME, 0,"easeInBack","easeInBack", 1.05, -0.55, kCenterDrawing);
    local wordAnim2 = AnimConsoleUnlockHead.wordRes:addPropTransparency(1,kAnimNormal,AnimConsoleUnlockHead.WORD_HIDE_TIME,0,1,0.5);
    if wordAnim1 then
        wordAnim1:setEvent(nil, function() 
            AnimConsoleUnlockHead.wordRes:setVisible(false);        
            AnimConsoleUnlockHead.wordRes:removeProp(0);
            AnimConsoleUnlockHead.wordRes:removeProp(1);
        end)
    end;

    -- 头像
    local headAnim1 = AnimConsoleUnlockHead.headRes:addPropScaleWithEasing(0, kAnimNormal, AnimConsoleUnlockHead.HEAD_HIDE_TIME, 0,"easeInBack","easeInBack", 1.05, -0.55, kCenterDrawing);
    local headAnim2 = AnimConsoleUnlockHead.headRes:addPropTransparency(1,kAnimNormal,AnimConsoleUnlockHead.HEAD_HIDE_TIME,0,1,0.5);
    local headAnim3 = AnimConsoleUnlockHead.headRes:addPropTranslateWithEasing(2, kAnimNormal, AnimConsoleUnlockHead.HEAD_HIDE_TIME, 0, function (...) return 0 end,"easeInBack", 0, 0, 0, 150);
    if headAnim1 then
        headAnim1:setEvent(nil, function() 
            AnimConsoleUnlockHead.headRes:setVisible(false);
            AnimConsoleUnlockHead.headRes:removeProp(0);
            AnimConsoleUnlockHead.headRes:removeProp(1);
            AnimConsoleUnlockHead.headRes:removeProp(2);
        end)
    end;

    -- 阳光
    local sunshineAnim1 = AnimConsoleUnlockHead.sushineRes:addPropScaleWithEasing(0, kAnimNormal, AnimConsoleUnlockHead.SUNSHINE_HIDE_TIME, 0,"easeInBack","easeInBack", 1.05, -0.55, kCenterDrawing);
    local sunshineAnim2 = AnimConsoleUnlockHead.sushineRes:addPropTransparency(1,kAnimNormal,AnimConsoleUnlockHead.SUNSHINE_TIME,0,1,0.5);
    local sunshineAnim3 = AnimConsoleUnlockHead.sushineRes:addPropTranslateWithEasing(2, kAnimNormal, AnimConsoleUnlockHead.SUNSHINE_TIME, 0, function (...) return 0 end,"easeInBack", 0, 0, 0, 150);
    if sunshineAnim1 then
        sunshineAnim1:setEvent(nil, function() 
            AnimConsoleUnlockHead.sushineRes:setVisible(false);
            AnimConsoleUnlockHead.sushineRes:removeProp(0);
            AnimConsoleUnlockHead.sushineRes:removeProp(1);
            AnimConsoleUnlockHead.sushineRes:removeProp(2);
        end)
    end;
end;