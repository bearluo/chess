require("common/animFactory");

AnimWin = class(Node);

AnimWin.ctor = function(self)
    self.m_win_test = new(Images,{"animation/win.png","animation/pass.png","drawable/blank.png"});
    self.m_win_test:setLevel(1);
    self.m_win_test:setAlign(kAlignTop);
    self.m_win_shine = new(Images,{"animation/shine.png","drawable/blank.png"});
    self.m_win_shine:setAlign(kAlignTop);
    self.m_win_banners = new(Images,{"animation/red_banners.png","animation/green_banners.png",
                                     "animation/green_cloths.png","animation/gray_banners.png"});
    self.m_win_banners:setLevel(1);
    self.m_win_banners:setAlign(kAlignTop);
    self.m_win_test:setPos(0,80);
    local w,h = self.m_win_shine:getSize();
    w = w*1.3;
    h = h*1.3;
    self.m_win_clip = new(Node);
    self.m_win_clip:setAlign(kAlignTop);
    self.m_win_clip:setSize(w,h);
    self.m_win_shine:setSize(w,h);
    self.m_win_clip:setPos(nil,-110);
--    self.m_win_shine:setClip(0,0,w,h);

    self:addChild(self.m_win_banners);
    self:addChild(self.m_win_clip);
    self.m_win_clip:addChild(self.m_win_shine);
    self:addChild(self.m_win_test);
    self:reset();
end

AnimWin.dtor = function(self)
    delete(self.m_anim_move_banners);
    delete(self.m_anim_scale_winTest);
    delete(self.m_anim_scale_winTest2);
    delete(self.m_anim_win_shine);
    self.m_win_banners:removeProp(1);
    self.m_win_test:removeProp(1);
    self.m_win_test:removeProp(2);
    self.m_win_shine:removeProp(1);
    self.m_win_shine:removeProp(2);
end


-- 观战
AnimWin.setWatch = function(self, file)
    self.m_win_test:setFile(file);
    self.m_win_shine:setImageIndex(1);
    self.m_win_banners:setImageIndex(2);
    
end;  
-- 和棋借用胜利界面
AnimWin.setDraw = function(self, file)
    self.m_win_test:setFile(file);
    self.m_win_shine:setImageIndex(1);
    self.m_win_banners:setImageIndex(1);
    
end;

-- 离线胜利(过关)
AnimWin.setOfflineWin = function(self)
    self.m_win_test:setImageIndex(1);
    self.m_win_banners:setImageIndex(0);
end;

-- 连胜,有点投机取巧
AnimWin.setContinueWin = function(self, img)
    self.m_win_test:setImageIndex(2);
    self.m_win_test:addChild(img);
    img:setAlign(kAlignTop);
--    local imgW,imgH = img:getSize();
--    -- 以banners为参照，居中对齐N连胜
--    self.m_win_banners:setImageIndex(0);
--    local bannersW,bannersH = self.m_win_banners:getSize();
--    img:setPos(-(imgW - bannersW)/2);
end;

AnimWin.reset = function(self)
    self.m_win_test:setVisible(false);
    self.m_win_banners:setVisible(false);
    self.m_win_shine:setVisible(false);
    delete(self.m_anim_move_banners);
    delete(self.m_anim_scale_winTest);
    delete(self.m_anim_scale_winTest2);
    delete(self.m_anim_win_shine);
    self.m_win_banners:removeProp(1);
    self.m_win_test:removeProp(1);
    self.m_win_test:removeProp(2);
    self.m_win_shine:removeProp(1);
    self.m_win_shine:removeProp(2);
end

AnimWin.play = function(self,root)
    if root then
        self:setParent(root);
    end
    self:reset();
    self:run();
end

AnimWin.stop = function(self)
    self.m_status = "stop";
end

AnimWin.run = function(self)
    self.m_status = "run";
    self:step1();
end

AnimWin.RunCount = 0;

AnimWin.bannersMoveH = -40;
AnimWin.bannersMoveDuration = 20;
AnimWin.bannersMoveTime = 200;
AnimWin.bannersMoveNum = AnimWin.bannersMoveTime/AnimWin.bannersMoveDuration;
AnimWin.bannersMove = 0;
AnimWin.bannersMoveStep = AnimWin.bannersMoveH/AnimWin.bannersMoveNum;

AnimWin.step1 = function(self)
    AnimWin.RunCount = 0;
    AnimWin.bannersMove = 0;
    self.m_win_banners:setVisible(true);
    self.m_win_banners:setPos(0,AnimWin.bannersMoveH);
    self.m_anim_move_banners = AnimFactory.createAnimInt(kAnimLoop, 0, 1, AnimWin.bannersMoveDuration, -1);
    self.m_anim_move_banners:setDebugName("AnimWin.m_anim_move_banners");
    self.m_anim_move_banners:setEvent(self,self.step1Func);
    self.m_win_banners:removeProp(1);
    self.m_win_banners:addPropTransparency(1, kAnimNormal, AnimWin.bannersMoveTime, -1, 0.0, 1.0);
end

AnimWin.step1Func = function(self)
    AnimWin.RunCount = AnimWin.RunCount + 1;
    if AnimWin.RunCount >= AnimWin.bannersMoveNum then
        delete(self.m_anim_move_banners);
        self.m_win_banners:setPos(0,0);
        self:step2();
        return;
    end
    self.m_win_banners:setPos(0,AnimWin.bannersMoveH-AnimWin.bannersMove);
    AnimWin.bannersMove = AnimWin.bannersMove + AnimWin.bannersMoveStep;
end

AnimWin.winScaleTestMoveTime = 200;
AnimWin.winScaleTeststartScale = 3;
AnimWin.winScaleTestendScale = 1;

AnimWin.step2 = function(self)
    AnimWin.RunCount = 0;

    self.m_win_test:setVisible(true);
    self.m_anim_scale_winTest = AnimFactory.createAnimInt(kAnimNormal, 0, 1, AnimWin.winScaleTestMoveTime, -1);
    self.m_anim_scale_winTest:setDebugName("AnimWin.m_anim_scale_winTest");
    self.m_anim_scale_winTest:setEvent(self,self.step2Func);
    self.m_win_test:removeProp(1);
    self.m_win_test:removeProp(2);
    self.m_win_test:addPropTransparency(1, kAnimNormal, AnimWin.winScaleTestMoveTime, -1, 0.0, 1.0);
    self.m_win_test:addPropScale(2, kAnimNormal, AnimWin.winScaleTestMoveTime, -1, 
                                            AnimWin.winScaleTeststartScale, AnimWin.winScaleTestendScale,
                                            AnimWin.winScaleTeststartScale, AnimWin.winScaleTestendScale, 1);
end

AnimWin.step2Func = function(self)
    self:step3();
end

AnimWin.winScaleTestMoveTime2 = 200;
AnimWin.winScaleTeststartScale2 = 1;
AnimWin.winScaleTestendScale2 = 1.2;

AnimWin.step3 = function(self)
    AnimWin.RunCount = 0;

    self.m_win_test:setVisible(true);
    self.m_anim_scale_winTest2 = AnimFactory.createAnimInt(kAnimNormal, 0, 1, AnimWin.winScaleTestMoveTime2, -1);
    self.m_anim_scale_winTest2:setDebugName("AnimWin.m_anim_scale_winTest2");
    self.m_anim_scale_winTest2:setEvent(self,self.step3Func);
    self.m_win_test:removeProp(2);
    self.m_win_test:addPropScale(2, kAnimLoop, AnimWin.winScaleTestMoveTime2/2, -1, 
                                            AnimWin.winScaleTeststartScale2, AnimWin.winScaleTestendScale2,
                                            AnimWin.winScaleTeststartScale2, AnimWin.winScaleTestendScale2, 1);
end

AnimWin.step3Func = function(self)
    self.m_win_test:removeProp(2);
    self:step4();
end

AnimWin.winScaleShineMoveTime = 200;
AnimWin.winScaleShineMoveTime2 = 3600;
AnimWin.winScaleShinestartScale = 0;
AnimWin.winScaleShineendScale = 1;

AnimWin.step4 = function(self)
    AnimWin.RunCount = 0;

    self.m_win_shine:setVisible(true);
    self.m_anim_win_shine = AnimFactory.createAnimInt(kAnimNormal, 0, 1, AnimWin.winScaleShineMoveTime, -1);
    self.m_anim_win_shine:setDebugName("AnimWin.m_anim_win_shine");
    self.m_anim_win_shine:setEvent(self,self.step4Func);
    self.m_win_shine:removeProp(1);
    self.m_win_shine:removeProp(2);
    self.m_win_shine:addPropRotate(1, kAnimRepeat, AnimWin.winScaleShineMoveTime2, -1, 0, 360, 1);
    self.m_win_shine:addPropScale(2, kAnimNormal, AnimWin.winScaleShineMoveTime, -1, 
                                            AnimWin.winScaleShinestartScale, AnimWin.winScaleShineendScale,
                                            AnimWin.winScaleShinestartScale, AnimWin.winScaleShineendScale, 1);
end

AnimWin.step4Func = function(self)
--    self.m_win_shine:removeProp(2);
    self:stop();
end