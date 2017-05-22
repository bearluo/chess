require("common/animFactory");

AnimLose = class(Node);

AnimLose.ctor = function(self)
    self.m_lose_test = new(Image,"animation/lose.png");
    self.m_lose_test:setAlign(kAlignTop);
    self.m_lose_scale_test = new(Image,"animation/lose.png");
    self.m_lose_scale_test:setAlign(kAlignTop);
    self.m_lose_banners = new(Image,"animation/gray_banners.png");
    self.m_lose_banners:setAlign(kAlignTop);
    self.m_lose_sy = new(Image,"animation/sy.png");
    self:addChild(self.m_lose_banners);
    self:addChild(self.m_lose_test);
    self:addChild(self.m_lose_scale_test);
    self:addChild(self.m_lose_sy);
    self.m_lose_sy:addPropScaleSolid(1, 0.3, 0.3, 1);
    self:reset();
end

AnimLose.dtor = function(self)
    delete(self.m_anim_move_banners);
    delete(self.m_anim_move_loseTest);
    delete(self.m_anim_scale_loseTest);
    delete(self.m_anim_sy);
    self.m_lose_banners:removeProp(1);
    self.m_lose_test:removeProp(1);
    self.m_lose_scale_test:removeProp(1);
    self.m_lose_scale_test:removeProp(2);
    self.m_lose_sy:removeProp(2);
    self.m_lose_sy:removeProp(3);
end

AnimLose.reset = function(self)
    self.m_lose_test:setVisible(false);
    self.m_lose_banners:setVisible(false);
    self.m_lose_scale_test:setVisible(false);
    self.m_lose_sy:setVisible(false);
    self.m_status = "create";
    delete(self.m_anim_move_banners);
    delete(self.m_anim_move_loseTest);
    delete(self.m_anim_scale_loseTest);
    delete(self.m_anim_sy);
    self.m_lose_banners:removeProp(1);
    self.m_lose_test:removeProp(1);
    self.m_lose_scale_test:removeProp(1);
    self.m_lose_scale_test:removeProp(2);
    self.m_lose_sy:removeProp(2);
    self.m_lose_sy:removeProp(3);
end

AnimLose.play = function(self,root)
    if root then
        self:setParent(root);
    end
    self:reset();
    self:run();
end

AnimLose.stop = function(self)
    self.m_status = "stop";
end

AnimLose.run = function(self)
    self.m_status = "run";
    self:step1();
end

AnimLose.RunCount = 0;

AnimLose.bannersMoveW = -50;
AnimLose.bannersMoveDuration = 20;
AnimLose.bannersMoveTime = 200;
AnimLose.bannersMoveNum = AnimLose.bannersMoveTime/AnimLose.bannersMoveDuration;
AnimLose.bannersMove = 0;
AnimLose.bannersMoveStep = AnimLose.bannersMoveW/AnimLose.bannersMoveNum;

AnimLose.step1 = function(self)
    AnimLose.RunCount = 0;
    AnimLose.bannersMove = 0;
    self.m_lose_banners:setVisible(true);
    self.m_lose_banners:setPos(0,AnimLose.bannersMoveW);
    self.m_anim_move_banners = AnimFactory.createAnimInt(kAnimLoop, 0, 1, AnimLose.bannersMoveDuration, -1);
    self.m_anim_move_banners:setDebugName("AnimLose.m_anim_move_banners");
    self.m_anim_move_banners:setEvent(self,self.step1Func);
    self.m_lose_banners:removeProp(1);
    self.m_lose_banners:addPropTransparency(1, kAnimNormal, AnimLose.bannersMoveTime, -1, 0.0, 1.0);
end

AnimLose.step1Func = function(self)
    AnimLose.RunCount = AnimLose.RunCount + 1;
    if AnimLose.RunCount >= AnimLose.bannersMoveNum then
        delete(self.m_anim_move_banners);
        self:step2();
        return;
    end
    self.m_lose_banners:setPos(0,AnimLose.bannersMoveW-AnimLose.bannersMove);
    AnimLose.bannersMove = AnimLose.bannersMove + AnimLose.bannersMoveStep;
end

AnimLose.loseTestMoveH = 60;
AnimLose.loseTestMoveDuration = 20;
AnimLose.loseTestMoveTime = 100;
AnimLose.loseTestMoveNum = AnimLose.loseTestMoveTime/AnimLose.loseTestMoveDuration;
AnimLose.loseTestMove = 0;
AnimLose.loseTestMoveStep = AnimLose.loseTestMoveH/AnimLose.loseTestMoveNum;

AnimLose.step2 = function(self)
    AnimLose.RunCount = 0;
    AnimLose.loseTestMove = 0;
    self.m_lose_test:setVisible(true);
    self.m_lose_test:setPos(0,AnimLose.loseTestMoveH);
    self.m_anim_move_loseTest = AnimFactory.createAnimInt(kAnimLoop, 0, 1, AnimLose.loseTestMoveDuration, -1);
    self.m_anim_move_loseTest:setDebugName("AnimLose.m_anim_move_loseTest");
    self.m_anim_move_loseTest:setEvent(self,self.step2Func);
    self.m_lose_test:removeProp(1);
    self.m_lose_test:addPropTransparency(1, kAnimNormal, AnimLose.loseTestMoveTime, -1, 0.0, 1.0);
end

AnimLose.step2Func = function(self)
    AnimLose.RunCount = AnimLose.RunCount + 1;
    if AnimLose.RunCount >= AnimLose.loseTestMoveNum then
        delete(self.m_anim_move_loseTest);
        self:step3();
        return;
    end
    AnimLose.loseTestMove = AnimLose.loseTestMove + AnimLose.loseTestMoveStep;
end


AnimLose.loseScaleTestMoveTime = 500;
AnimLose.loseScaleTeststartScale = 1;
AnimLose.loseScaleTestendScale = 2;
AnimLose.step3 = function(self)
    AnimLose.RunCount = 0;
    self.m_lose_scale_test:setVisible(true);
    self.m_lose_scale_test:setPos(0,AnimLose.loseTestMoveH);
    self.m_anim_scale_loseTest = AnimFactory.createAnimInt(kAnimNormal, 0, 1, AnimLose.loseScaleTestMoveTime, -1);
    self.m_anim_scale_loseTest:setDebugName("AnimLose.m_anim_scale_loseTest");
    self.m_anim_scale_loseTest:setEvent(self,self.step3Func);
    self.m_lose_scale_test:removeProp(1);
    self.m_lose_scale_test:removeProp(2);
    self.m_lose_scale_test:addPropTransparency(1, kAnimNormal, AnimLose.loseScaleTestMoveTime, -1, 1.0, 0.0);
    self.m_lose_scale_test:addPropScale(2, kAnimNormal, AnimLose.loseScaleTestMoveTime, -1, 
                                            AnimLose.loseScaleTeststartScale, AnimLose.loseScaleTestendScale,
                                            AnimLose.loseScaleTeststartScale, AnimLose.loseScaleTestendScale, 1);
end

AnimLose.step3Func = function(self)
    self.m_lose_scale_test:setVisible(false);
    self:step4();
end


AnimLose.syStartx = 550;
AnimLose.syStarty = -60;

AnimLose.syMoveDuration = 10;
AnimLose.syMoveTime = AnimLose.syMoveDuration*100;
AnimLose.syMoveNum = AnimLose.syMoveTime/AnimLose.syMoveDuration;

AnimLose.syV = 10;
AnimLose.syBaseV = 3;
AnimLose.syA = 0;

AnimLose.syRotate = 0;
AnimLose.syMoveRotate = 115;
AnimLose.syMoveRotateBase = 0.05;
AnimLose.syMoveStepRotate = 360/(AnimLose.syMoveNum/2);
AnimLose.syMoveRotateRuning = false;


AnimLose.syMoveFunc = function(self)
    local x,y = self.m_lose_sy:getPos();
    local rotate = AnimLose.syMoveRotate;
    local v,a = AnimLose.syV,AnimLose.syA;

    local l = AnimLose.syBaseV+math.abs(v+(v+a)/2);
    local retx = x + l*math.cos(rotate*math.pi/180);
    local rety = y + l*math.sin(rotate*math.pi/180);
    self.m_lose_sy:setPos(retx,rety);
    AnimLose.syV = AnimLose.syV + AnimLose.syA;
end

AnimLose.syRotateFunc = function(self)
    if not AnimLose.syMoveRotateRuning then 
        AnimLose.syMoveRotate = AnimLose.syMoveRotate+AnimLose.syMoveRotateBase;
        AnimLose.syRotate = AnimLose.syRotate+AnimLose.syMoveRotateBase;
        self.m_lose_sy:removeProp(2);
        self.m_lose_sy:addPropRotateSolid(2,AnimLose.syRotate,0);
        return ; 
    end
    AnimLose.syMoveRotate = AnimLose.syMoveRotate+AnimLose.syMoveStepRotate;
    AnimLose.syRotate = AnimLose.syRotate+AnimLose.syMoveStepRotate;
    self.m_lose_sy:removeProp(2);
    self.m_lose_sy:addPropRotateSolid(2,AnimLose.syRotate,0);
end

AnimLose.step4 = function(self)
    AnimLose.RunCount = 0;
    AnimLose.syV = 10;
    AnimLose.syA = -AnimLose.syV/(AnimLose.syMoveNum/2);
    AnimLose.syRotate = 0;
    AnimLose.syMoveRotate = 160;
    AnimLose.syMoveRotateRuning = false;
    self.m_lose_sy:setVisible(true);
    self.m_lose_sy:setPos(AnimLose.syStartx,AnimLose.syStarty);
    self.m_anim_sy = AnimFactory.createAnimInt(kAnimLoop, 0, 1, AnimLose.syMoveDuration, -1);
    self.m_anim_sy:setDebugName("AnimLose.m_anim_sy");
    self.m_anim_sy:setEvent(self,self.step4Func);
end

AnimLose.step4Func = function(self)
    AnimLose.RunCount = AnimLose.RunCount + 1;
    if AnimLose.RunCount >= AnimLose.syMoveNum then
        delete(self.m_anim_sy);
        self.m_lose_sy:setVisible(false);
        self:stop();
        return;
    end
    if not AnimLose.syMoveRotateRuning and AnimLose.RunCount == AnimLose.syMoveNum/4 then
        AnimLose.syMoveRotateRuning = true;
        self.m_lose_sy:removeProp(3);
        self.m_lose_sy:addPropScale(3, kAnimNormal,AnimLose.syMoveTime/4,-1,1,0.5,1,0.5,1);
    end

    Log.i("AnimLose.syMoveRotate.."..AnimLose.syMoveRotate);
    Log.i("AnimLose.syRotate.."..AnimLose.syRotate);
    Log.i("AnimLose.syV.."..AnimLose.syV);
--    Log.i("AnimLose.syMoveRotate.."..AnimLose.syMoveRotate);
    self:syMoveFunc();
    self:syRotateFunc();

    if AnimLose.syMoveRotateRuning and AnimLose.RunCount == AnimLose.syMoveNum/2 then
        self.m_lose_sy:removeProp(3)
        self.m_lose_sy:addPropScale(3, kAnimNormal,AnimLose.syMoveTime/4,-1,0.5,1,0.5,1,1);
    end
    if AnimLose.syMoveRotateRuning and AnimLose.RunCount == AnimLose.syMoveNum*3/4 then
        self.m_lose_sy:removeProp(3)
        AnimLose.syMoveRotateRuning = false;
    end

    AnimLose.loseTestMove = AnimLose.loseTestMove + AnimLose.loseTestMoveStep;
end