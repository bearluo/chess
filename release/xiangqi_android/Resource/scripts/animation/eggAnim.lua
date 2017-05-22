--eggAnim.lua
--Date 2016.8.5
--扔鸡蛋动画
--endregion
require("swfTween/swfPlayer");
require("swf_anim_info/egg_start_swf_info")
require("swf_anim_info/prop_egg_end_swf_info")
require("swf_anim_info/egg_ten_start_swf_info")
require("swf_anim_info/egg_hundred_start_swf_info")

require("swf_anim_pin/egg_start_swf_pin")
require("swf_anim_pin/prop_egg_end_swf_pin")


EggAnim = class();

EggAnim.pos_tab = {
    {x = 0,y = -8},
    {x = -40,y = 12},
    {x = 50,y = 4},
    {x = 2,y = 39},
    {x = -50,y = 42},
    {x = 36,y = 58},
}

--[Comment]
--创建鸡蛋动画
--startPos: 动画开始view
--endPos: 动画结束view
--angle: 动画旋转角度
function EggAnim.ctor(self,startView,endView,angle,num)
    if not startView or not endView then
        return
    end
    self.num = num or 1
    self.startView = startView
    self.endView = endView
    self.angle = angle or 0

    if self.num == 1 then
        self.tab_len = 1
    elseif self.num == 10 then
        self.tab_len = 3
    elseif self.num == 100 then
        self.tab_len = 6
    else
        self.tab_len = 1
    end

    self.egg_img_tab = {}
    self.egg_fly_anim_tab = {}
    self.egg_end_anim_tab = {}
end

function EggAnim.play(self)
    kEffectPlayer:playEffect(Effects.AUDIO_SEND_EGG);
    self:startAnim()
end

function EggAnim.playHalfAnim(self)
    kEffectPlayer:playEffect(Effects.AUDIO_SEND_EGG);
    self:eggFly()
end

--[Comment]
--鸡蛋开始动画
function EggAnim.startAnim(self)
    self.is_playing_anim = true

    if self.num == 1 then
        self.egg_startAnim = new(SwfPlayer,egg_start_swf_info);
    elseif self.num == 10 then
        self.egg_startAnim = new(SwfPlayer,egg_ten_start_swf_info);
    elseif self.num == 100 then
        self.egg_startAnim = new(SwfPlayer,egg_hundred_start_swf_info);
    else
        self.egg_startAnim = new(SwfPlayer,egg_start_swf_info);  
    end

--    self.egg_startAnim = new(SwfPlayer,egg_start_swf_info);
    local y = 55
    if self.angle ~= 0 then
        y = 0
    end 
    self.egg_startAnim:setPos(-5,y)
    self.egg_startAnim:setFrameEvent(self,self.eggFly,26);
    self.egg_startAnim:setAlign(kAlignCenter)
    self.egg_startAnim:addPropRotateSolid(20, self.angle, kCenterDrawing);
    self.startView:addChild(self.egg_startAnim);
    self.egg_startAnim:play(1,false,1);
end

--[Comment]
--鸡蛋飞行
function EggAnim.eggFly(self)
    self.egg_startAnim = nil;
    self.egg_img_tab = {}
    self.egg_fly_anim_tab = {}
    do
        local startX,startY = self.startView:getAbsolutePos();
        local endX,endY = self.endView:getAbsolutePos();
        for i = 1 ,self.tab_len  do 
            self.egg_img_tab[i] = new(Image,"mall/egg.png");
            self.egg_img_tab[i]:setPos(startX + EggAnim.pos_tab[i].x,startY + EggAnim.pos_tab[i].y)
            self.egg_img_tab[i]:addToRoot();
            self.egg_fly_anim_tab[i] = self.egg_img_tab[i]:addPropTranslate(2, kAnimNormal, 600, -1, 0, endX - startX, 0, endY - startY);
            self.egg_img_tab[i]:addPropRotate(3, kAnimRepeat, 150, -1, 1, 360, kCenterDrawing);
        end
    end

    for j = 1,self.tab_len do
        if self.egg_fly_anim_tab[j] then
            self.egg_fly_anim_tab[j]:setEvent(self,function()
                self:onEggFlyEnd(j)
            end)
        end
    end

--    if self.egg_fly_anim then
--        self.egg_fly_anim:setEvent(self,self.onEggFlyEnd)
--    end
--    self.egg_rotate_anim = self.egg_img:addPropRotate(3, kAnimRepeat, 150, -1, 1, 360, kCenterDrawing);
end

--[Comment]
--鸡蛋结束
function EggAnim.onEggFlyEnd(self,index)
    local num = 1
    if self.egg_fly_anim_tab then
        num = #self.egg_fly_anim_tab
    end
    local i = index or 1
    if self.egg_img_tab[i] then 
        self.egg_img_tab[i]:removeProp(2);
        self.egg_fly_anim_tab[i] = nil;
        self.egg_img_tab[i]:removeProp(3);
        delete(self.egg_img_tab[i]);
        self.egg_img_tab[i] = nil;
    end
    self.egg_end_anim_tab[i] = new(SwfPlayer,prop_egg_end_swf_info);
    self.egg_end_anim_tab[i]:setAlign(kAlignCenter);

    self.egg_end_anim_tab[i]:setCompleteEvent(self,function()
        self.egg_end_anim_tab[i] = nil
        self.is_playing_anim = false
        self:clear(i)
    end);
    self.egg_end_anim_tab[i]:setPos(EggAnim.pos_tab[i].x,EggAnim.pos_tab[i].y)
    self.endView:addChild(self.egg_end_anim_tab[i])
    self.egg_end_anim_tab[i]:play(1,false,1);
end

function EggAnim.clear(self,index)
    if self.egg_startAnim then
        delete(self.egg_startAnim);
        self.egg_startAnim = nil;
    end

    if self.egg_img_tab[index] then
        self.egg_img_tab[index]:removeProp(2);
        self.egg_img_tab[index]:removeProp(3);
        self.egg_fly_anim_tab[index] = nil
        delete(self.egg_img_tab[index])
        self.egg_img_tab[index] = nil
    end

--    if self.egg_img then
--        self.egg_img:removeProp(2);
--        self.egg_fly_anim = nil;
--        self.egg_img:removeProp(3);
--        self.egg_rotate_anim = nil;
--        delete(self.egg_img);
--        self.egg_img = nil;
--    end
    if self.egg_end_anim_tab[index] then
        delete(self.egg_end_anim_tab[index])
        self.egg_end_anim_tab[index] = nil
    end


--    if self.egg_endAnim then
--        delete(self.egg_endAnim);
--        self.egg_endAnim = nil;
--    end
    if index or index == self.tab_len then
        self:stop()
    end
    self.is_playing_anim = false

end

function EggAnim.stop(self)
    self.is_playing_anim = false
    for i = self.tab_len ,1,-1 do 
        if self.egg_img_tab[i] then
            self.egg_img_tab[i]:removeProp(2);
            self.egg_img_tab[i]:removeProp(3);
            delete(self.egg_img_tab[i])
            self.egg_img_tab[i] = nil
        end
        if self.egg_fly_anim_tab[i] then
            delete(self.egg_fly_anim_tab[i])
            self.egg_fly_anim_tab[i] = nil
        end
        if self.egg_end_anim_tab[i] then
            delete(self.egg_end_anim_tab[i])
            self.egg_end_anim_tab[i] = nil
        end
    end
--    for i = self.tab_len ,1,-1 do 
--        if self.egg_fly_anim_tab[i] then
--            delete(self.egg_fly_anim_tab[i])
--            self.egg_fly_anim_tab[i] = nil
--        end
--    end
--    for i = self.tab_len ,1,-1 do 
--        if self.egg_end_anim_tab[i] then
--            delete(self.egg_end_anim_tab[i])
--            self.egg_end_anim_tab[i] = nil
--        end
--    end
    self:onAnimEndCallback()
end

--[Comment]
--可以设置动画结束回调
function EggAnim.setCallBack(self,obj,func)
    self.m_func = func
    self.m_obj = obj
end

function EggAnim.onAnimEndCallback(self,...)
    if self.m_func and self.m_obj then
        self.m_func(self.m_obj,...)
    end
end