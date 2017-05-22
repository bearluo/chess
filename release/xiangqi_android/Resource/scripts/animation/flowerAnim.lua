--flowerAnim.lua
--Date 2016.8.7
--鲜花动画
--endregion
require("swfTween/swfPlayer");
require("swf_anim_pin/prop_send_flower_end_swf_pin");
require("swf_anim_pin/prop_send_flower_from_swf_pin");
require("swf_anim_pin/prop_send_flower_to_swf_pin");
require("swf_anim_pin/flower_ten_start_swf_pin");
require("swf_anim_pin/flower_hundred_end_swf_pin");
require("swf_anim_pin/flower_hundred_start_swf_pin");

require("swf_anim_info/prop_send_flower_end_swf_info");
require("swf_anim_info/prop_send_flower_from_swf_info");
require("swf_anim_info/prop_send_flower_to_swf_info");
require("swf_anim_info/flower_ten_start_swf_info");
require("swf_anim_info/flower_hundred_end_swf_info");
require("swf_anim_info/flower_hundred_start_swf_info");

FlowerAnim = class()

FlowerAnim.s_plist = {
    {x = 0,y = 0,zoom = 1},
    {x = -20,y = 60,zoom = 0.9},
    {x = 25,y = 65,zoom = 1},
    {x = -25,y = 85,zoom = 0.8},
    {x = 5,y = 95,zoom = 1},
    {x = 35,y = 75,zoom = 0.7},
    {x = -30,y = 130,zoom = 1},
    {x = -6,y = 131,zoom = 0.7},
    {x = 45,y = 95,zoom = 1},
    {x = -45,y = 145,zoom = 0.6},
    {x = 7,y = 137,zoom = 0.6},
    {x = 55,y = 155,zoom = 0.5},
}

FlowerAnim.l_plist = {
    {x = 0,y = 30,zoom = 1},
    {x = -60,y = 10,zoom = 0.9},
    {x = -65,y = 35,zoom = 1},
    {x = -85,y = -15,zoom = 0.8},
    {x = -95,y = 15,zoom = 1},
    {x = -75,y = 45,zoom = 0.7},
    {x = 130,y = 20,zoom = 1},
    {x = -131,y = 14,zoom = 0.7},
    {x = -95,y = 55,zoom = 1},
    {x = -145,y = -35,zoom = 0.6},
    {x = -137,y = 17,zoom = 0.6},
    {x = -155,y = 65,zoom = 0.5},
}

FlowerAnim.r_plist = {
    {x = 0,y = 10,zoom = 1},
    {x = 60,y = -10,zoom = 0.9},
    {x = 65,y = 35,zoom = 1},
    {x = 85,y = -15,zoom = 0.8},
    {x = 95,y = 15,zoom = 1},
    {x = 75,y = 45,zoom = 0.7},
    {x = 130,y = -20,zoom = 1},
    {x = 131,y = 44,zoom = 0.7},
    {x = 95,y = 55,zoom = 1},
    {x = 145,y = 25,zoom = 0.6},
    {x = 137,y = 17,zoom = 0.6},
    {x = 155,y = 65,zoom = 0.5},
}

FlowerAnim.temp_plist = {
    {x = 0, y = 0,zoom = 1},
    {x = -25, y = 15,zoom = 0.8},
    {x = 25, y = 25,zoom = 0.8},
}

--[Comment]
--创建鲜花动画
--startPos: 动画开始view
--endPos: 动画结束view
--angle: 动画旋转角度
function FlowerAnim.ctor(self,startView,endView,angle,num)
    if not startView or not endView then
        return
    end

    self.num = num or 1

    if self.num == 1 then
        self.tab_len = 1
    elseif self.num == 10 then
        self.tab_len = 7
    elseif self.num == 100 then
        self.tab_len = 12
    else
        self.tab_len = 1
    end

    self.plist = FlowerAnim.s_plist

    self.flower_img_tab = {}
    self.flower_fly_anim_tab = {}
    self.startView = startView
    self.endView = endView
    self.angle = angle or 0
end

function FlowerAnim.play(self)
    kEffectPlayer:playEffect(Effects.AUDIO_SEND_FLOWER);
    self:startAnim()
end

function FlowerAnim.playHalfAnim(self)
    kEffectPlayer:playEffect(Effects.AUDIO_SEND_FLOWER);

    if self.angle == 0 then
        self.plist = FlowerAnim.l_plist
    elseif self.angle == 180 then
        self.plist = FlowerAnim.r_plist
    end
    self:flowerFly()
end

--[Comment]
--鲜花开始动画
function FlowerAnim.startAnim(self)
    self.is_playing_anim = true

    if self.num == 1 then
        self.flower_startAnim = new(SwfPlayer,prop_send_flower_from_swf_info);
    elseif self.num == 10 then
        self.flower_startAnim = new(SwfPlayer,flower_ten_start_swf_info);
    elseif self.num == 100 then
        self.flower_startAnim = new(SwfPlayer,flower_hundred_start_swf_info);
    else
        self.flower_startAnim = new(SwfPlayer,prop_send_flower_from_swf_info);
    end


--    self.flower_startAnim = new(SwfPlayer,prop_send_flower_from_swf_info);
    self.flower_startAnim:setCompleteEvent(self,self.flowerFly);
    
    self.flower_startAnim:setAlign(kAlignTop);

    if self.num == 100 then
--        self.flower_startAnim:setPos(10,-40)
        local angle = self.angle - 270
        self.flower_startAnim:addPropRotateSolid(20, angle, kCenterDrawing);
    else
        self.flower_startAnim:setPos(0,-40)
        self.flower_startAnim:addPropRotateSolid(20, self.angle, kCenterDrawing);
    end

    self.flower_startAnim:addPropRotateSolid(20, self.angle, kCenterDrawing);
    self.startView:addChild(self.flower_startAnim);
    self.flower_startAnim:play(1,false,1);
end

--[Comment]
--鲜花飞行
function FlowerAnim.flowerFly(self)
    self.flower_startAnim = nil;
    self.flower_img_tab = {}
    self.flower_fly_anim_tab = {}

    do
        local startX,startY = self.startView:getAbsolutePos();
        local endX,endY = self.endView:getAbsolutePos();
        local y = 0 
        if self.num ~= 1 and self.angle ~= 180 and self.angle ~= 0 then
            y = 100
        end

        for i = 1 ,self.tab_len  do 
            self.flower_img_tab[i] = new(Image,"swf_anim_pin/flower_fly.png");
            self.flower_img_tab[i]:setPos(startX + self.plist[i].x,startY + self.plist[i].y - y)
            self.flower_img_tab[i]:addToRoot();
            self.flower_fly_anim_tab[i] = self.flower_img_tab[i]:addPropTranslate(2, kAnimNormal, (600 +  i * 10), (0 + i * 10), 0, endX - startX, 0, endY - startY + y);
            self.flower_img_tab[i]:addPropScaleSolid(4,self.plist[i].zoom,self.plist[i].zoom,kCenterDrawing)
            self.flower_img_tab[i]:addPropRotateSolid(3, self.angle, kCenterDrawing);
        end
    end
    for j = 1,self.tab_len do
        if self.flower_fly_anim_tab[j] then
            self.flower_fly_anim_tab[j]:setEvent(self,function()
                self:onFlowerFlyEnd(j)
            end)
        end
    end
--    self.flower_rotate_anim = self.flower_img:addPropRotateSolid(3, self.angle, kCenterDrawing);
end

--[Comment]
--鲜花结束
function FlowerAnim.onFlowerFlyEnd(self,index)
    if not index then return end
    self.flower_img_tab[index]:setVisible(false)
    self.flower_img_tab[index]:removeProp(2);
    self.flower_img_tab[index]:removeProp(3);
    self.flower_img_tab[index]:removeProp(4);
    self.flower_fly_anim_tab[index] = nil
    delete(self.flower_img_tab[index])
    self.flower_img_tab[index] = nil
    if index ~= 1 then
        return
    end

--    if self.flower_img then 
--        self.flower_img:removeProp(2);
--        self.flower_fly_anim = nil;
--        self.flower_img:removeProp(3);
--        self.flower_rotate_anim = nil;
--        delete(self.flower_img);
--        self.flower_img = nil;
--    end


    if self.num == 1 then
        self.flower_endAnim = new(SwfPlayer,prop_send_flower_end_swf_info);
    elseif self.num == 10 then
        self.flower_endAnim = new(SwfPlayer,prop_send_flower_end_swf_info);
    elseif self.num == 100 then
        self.flower_endAnim = new(SwfPlayer,flower_hundred_end_swf_info);
--        self:tempHundredAnim()
    else
        self.flower_endAnim = new(SwfPlayer,prop_send_flower_end_swf_info);
    end

--    self.flower_endAnim = new(SwfPlayer,prop_send_flower_end_swf_info);
    self.flower_endAnim:setAlign(kAlignCenter);
    self.flower_endAnim:setLevel(50);
    self.flower_endAnim:setCompleteEvent(self,function()
        self.flower_endAnim = nil
        self.is_playing_anim = false
        self:stop()
    end);
    self.endView:addChild(self.flower_endAnim)
    self.flower_endAnim:play(1,false,1);
end

--没有百连发的动画，暂时用
--function FlowerAnim.tempHundredAnim(self)
--    self.num = 1
--    self.timer = new(AnimInt,kAnimRepeat,0,1,50,-1)
--    self.timer:setEvent(self,function()
--        self.animTempTab[self.num] = new(SwfPlayer,prop_send_flower_end_swf_info);
--        self.animTempTab[self.num]:setPos(FlowerAnim.temp_plist[self.num].x,FlowerAnim.temp_plist[self.num].y)
--        self.animTempTab[self.num]:addPropScaleSolid(10,FlowerAnim.temp_plist[self.num].zoom,FlowerAnim.temp_plist[self.num].zoom,kCenterDrawing)
--        self.animTempTab[self.num]:setAlign(kAlignCenter);
--        self.animTempTab[self.num]:setLevel(100 - self.num);
--        self.animTempTab[self.num]:setCompleteEvent(self,function()
----            self.animTempTab[self.num]:removeProp(10)
----            self.is_playing_anim = false
--            if #self.animTempTab == 3 then
--                self:stop()
--            end
--        end);
--        self.endView:addChild(self.animTempTab[self.num])
--        self.animTempTab[self.num]:play(1,false,1);
--        self.num = self.num + 1
--        if self.num == 4 then
--            delete(self.timer)
--            self.timer = nil
--        end
--    end)



--    for i = 1, self.temp_len do
--        self.animTempTab[i] = new(SwfPlayer,prop_send_flower_end_swf_info);
--        self.animTempTab[i]:setAlign(kAlignCenter);
--        self.animTempTab[i]:setLevel(100);
--        self.animTempTab[i]:setCompleteEvent(self,function()
--            self.animTempTab[i] = nil
----            self.is_playing_anim = false
--            self:stop()
--        end);
--        self.endView:addChild(self.animTempTab[i])
--        self.animTempTab[i]:play(1,false,1);
--    end
--end

function FlowerAnim.stop(self)
    if self.flower_startAnim then
        delete(self.flower_startAnim);
        self.flower_startAnim = nil;
    end

    for i = self.tab_len,1 do
        if self.flower_img_tab[i] then
            self.flower_img_tab[i]:removeProp(2);
            self.flower_img_tab[i]:removeProp(3);
            self.flower_img_tab[i]:removeProp(4);
            delete(self.flower_img_tab[i])
            self.flower_img_tab[i] = nil
        end
        if self.flower_fly_anim_tab[i] then
            delete(self.flower_fly_anim_tab[i])
            self.flower_fly_anim_tab[i] = nil
        end
    end

--    if self.flower_img then
--        self.flower_img:removeProp(2);
--        self.flower_fly_anim = nil;
--        self.flower_img:removeProp(3);
--        self.flower_rotate_anim = nil;
--        delete(self.flower_img);
--        self.flower_img = nil;
--    end
    if self.flower_endAnim then
        delete(self.flower_endAnim);
        self.flower_endAnim = nil;
    end

--    for i = self.temp_len , 1, -1 do
--        if self.animTempTab[i] then
--            self.animTempTab[i]:removeProp(i)
--            delete(self.animTempTab[i])
--            self.animTempTab[i] = nil
--        end
--    end

--    if self.timer then
--        delete(self.timer)
--        self.timer = nil
--    end

    self.is_playing_anim = false
    self:onAnimEndCallback()
end

--[Comment]
--可以设置动画结束回调
function FlowerAnim.setCallBack(self,obj,func)
    self.m_func = func
    self.m_obj = obj
end

function FlowerAnim.onAnimEndCallback(self,...)
    if self.m_func and self.m_obj then
        self.m_func(self.m_obj,...)
    end
end