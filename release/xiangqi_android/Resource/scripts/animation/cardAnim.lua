--CardAnim.lua
--Date 2016.8.7
--金卡动画
--endregion

require("swfTween/swfPlayer");
require("swf_anim_info/card_start_swf_info")
require("swf_anim_info/card_end_swf_info")
require("swf_anim_info/card_ten_end_swf_info")
require("swf_anim_info/card_hundred_end_swf_info")

require("swf_anim_pin/card_start_swf_pin")
require("swf_anim_pin/card_end_swf_pin")
require("swf_anim_pin/card_ten_end_swf_pin")
require("swf_anim_pin/card_hundred_end_swf_pin")

CardAnim = class();

--[Comment]
--创建金卡动画
--startPos: 动画开始view
--endPos: 动画结束view
--angle: 动画旋转角度
function CardAnim.ctor(self,startView,endView,num)
    if not startView or not endView then
        return
    end
    self.num = num or 1
    self.startView = startView
    self.endView = endView
    self.angle = angle or 0
end

function CardAnim.play(self)
    kEffectPlayer:playEffect(Effects.AUDIO_SEND_CARD);
    self:startAnim()
end

function CardAnim.playHalfAnim(self)
    kEffectPlayer:playEffect(Effects.AUDIO_SEND_CARD);
    self:cardFly()
end

--[Comment]
--金卡开始动画
function CardAnim.startAnim(self)
    self.is_playing_anim = true
    self.card_startAnim = new(SwfPlayer,card_start_swf_info);
    self.card_startAnim:setCompleteEvent(self,self.cardFly);
    self.card_startAnim:setAlign(kAlignTop);
    self.card_startAnim:setLevel(100);
    self.card_startAnim:setPos(0,-45);
    self.card_startAnim:addPropRotateSolid(20, self.angle, kCenterDrawing);
    self.startView:addChild(self.card_startAnim);
    self.card_startAnim:play(1,false,1);
end

--[Comment]
--金卡飞行
function CardAnim.cardFly(self)
    self.card_startAnim = nil;
    do
        local startX,startY = self.startView:getAbsolutePos();
        local endX,endY = self.endView:getAbsolutePos();
        self.card_img = new(Image,"mall/vip_card.png");
        self.card_img:setPos(startX,startY)
        self.card_img:addToRoot();
        self.card_fly_anim = self.card_img:addPropTranslate(2, kAnimNormal, 600, -1, 0, endX - startX, 0, endY - startY);
    end
    if self.card_fly_anim then
        self.card_fly_anim:setEvent(self,self.onCardFlyEnd)
    end
--    self.egg_rotate_anim = self.card_img:addPropRotate(3, kAnimRepeat, 150, -1, 1, 360, kCenterDrawing);
end

--[Comment]
--金卡结束
function CardAnim.onCardFlyEnd(self)
    if self.card_img then 
        self.card_img:removeProp(2);
        self.card_fly_anim = nil;
--        self.card_img:removeProp(3);
--        self.egg_rotate_anim = nil;
        delete(self.card_img);
        self.card_img = nil;
    end

    if self.num == 1 then
        self.card_endAnim = new(SwfPlayer,card_end_swf_info);
    elseif self.num == 10 then
        self.card_endAnim = new(SwfPlayer,card_ten_end_swf_info);
    elseif self.num == 100 then
        self.card_endAnim = new(SwfPlayer,card_hundred_end_swf_info);
    else
        self.card_endAnim = new(SwfPlayer,card_end_swf_info);
    end

--    self.card_endAnim = new(SwfPlayer,card_end_swf_info);
    self.card_endAnim:setAlign(kAlignCenter);
    self.card_endAnim:setPos(0,-35);
    self.card_endAnim:setCompleteEvent(self,function()
        self.card_endAnim = nil
        self.is_playing_anim = false
        self:stop()
    end);
    self.endView:addChild(self.card_endAnim)
    self.card_endAnim:play(1,false,1);
end

function CardAnim.stop(self)
    if self.card_startAnim then
        delete(self.card_startAnim);
        self.card_startAnim = nil;
    end
    if self.card_img then
        self.card_img:removeProp(2);
        self.card_fly_anim = nil;
        self.card_img:removeProp(3);
        self.egg_rotate_anim = nil;
        delete(self.card_img);
        self.card_img = nil;
    end
    if self.card_endAnim then
        delete(self.card_endAnim);
        self.card_endAnim = nil;
    end
    self.is_playing_anim = false
    self:onAnimEndCallback()
end

--[Comment]
--可以设置动画结束回调
function CardAnim.setCallBack(self,obj,func)
    self.m_func = func
    self.m_obj = obj
end

function CardAnim.onAnimEndCallback(self,...)
    if self.m_func and self.m_obj then
        self.m_func(self.m_obj,...)
    end
end