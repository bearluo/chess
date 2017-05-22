--region NewFile_1.lua
--Author : FordFan
--Date   : 2015/11/14
--倒计时
--endregion

require("animation/circleAnimLine");

CountDown = class(Node);

CountDown.ctor = function(self,node,room,time)
    node:addChild(self);
    self.room = room;
    self.m_intestiy = 360;

    self.m_animIndex = {};
    self.isRunning = false;
    
    self:setVisible(false);
    
    self:setPos(0,0);

    local nodeW,nodeH = node:getSize()
    self.m_width    = nodeW*System.getLayoutScale();
    self.m_height   = nodeW*System.getLayoutScale();
    self.m_cirWidth = 0.5*nodeW*System.getLayoutScale(); 

    self.index = 0;

    --time 
    self.m_duration = time 
end

CountDown.dtor = function(self)
    delete(self.m_mainAnim);
    delete(self.m_circle);
end

CountDown.start = function(self,startAngle,angle)
    self.isRunning = true;
    startAngle = startAngle or 0;
    angle = angle or 360;
    self:setVisible(true);
    self.isPause = false;
    self.m_index = 0;
    self.m_circle = new(CircleAnimLine, self.m_cirWidth,self.m_cirWidth, startAngle, angle, self.m_cirWidth + 2.5, self.m_cirWidth - 5.5,self.m_intestiy);
    self:addChild(self.m_circle);

    self.m_mainAnim = new(AnimInt,kAnimRepeat,0,1,self.m_duration/360 ,0);
    self.m_mainAnim:setEvent(self,self.update);
end

CountDown.stop = function(self)
    self:setVisible(false);


    if self.isRunning == true then
--        self.m_mainAnim:dtor();
--        self.m_mainAnim = nil;
        self:onStageEnd();
        self.m_circle:release();

--        self.isRunning = false; 
    end
    
end

CountDown.pause = function(self)
    self.isPause = true;
end

CountDown.run = function(self)
    self.isPause = false;
end

CountDown.update = function(self)
    if self.isPause then return end
--    if self.m_index < #self.m_animIndex then
--        self.m_index = self.m_index + 1;       
--        circle:circleVertexUpdate();
--        
--    else
--        self.m_index = 0;
--        self:onStageEnd();q
--    end
    local num = self.m_circle:circleVertexUpdate();
--    self.m_circle:setColor(0.0,255,0.0);
--    self.m_index = num;
--    if num == 484 then
--        self.animTimer = new(AnimInt,kAnimRepeat,0,1,300,-1);
--        self.animTimer:setEvent(self,self.onTimer);
--    end

    if not num or num == 0 then
        self:onStageEnd();
        self.m_index = 0;
    end
end

CountDown.onStageEnd = function(self)
    if self.isRunning == true then
        self.isRunning = false;
        delete(self.m_mainAnim);
        self.m_mainAnim = nil;

        if self.room.m_up_breath1 and self.room.m_up_breath2 and self.room.m_down_breath1 and self.room.m_down_breath2 then
--        if self.room.animTimer then
            self.room.m_up_breath1:setVisible(false);
            self.room.m_up_breath2:setVisible(false);
            self.room.m_down_breath1:setVisible(false);
            self.room.m_down_breath2:setVisible(false);
--		    delete(self.animTimer);
--		    self.animTimer = nil;
        end
    end
end

--CountDown.onTimer = function(self)
--    local index = self.index;
--    if index == 0 then
--        self.room.breath1:setVisible(false);
--        self.room.breath2:setVisible(false);
--    elseif index == 1 then
--        self.room.breath1:setVisible(true);
--        self.room.breath2:setVisible(false);
--    elseif index == 2 then
--        self.room.breath1:setVisible(false);
--        self.room.breath2:setVisible(true);
--    elseif index == 3 then
--        self.room.breath1:setVisible(true);
--        self.room.breath2:setVisible(false);
--        self.index = 0;
--        return;
--    end
--    self.index = self.index + 1;
--end