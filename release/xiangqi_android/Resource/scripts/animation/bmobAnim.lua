-- bmob.lua
-- Author: JsonPeng
-- Date:   2017-05-16
-- Last modification : XXXX-XX-XX
-- Description: 扔炸弹道具动画
require("swfTween/swfPlayer");
require("swf_anim_info/bmob_hundred_start_swf_info")
require("swf_anim_info/bmob_hundred_end_swf_info")
require("swf_anim_info/bmob_ten_start_swf_info")
require("swf_anim_info/bmob_ten_end_swf_info")
require("swf_anim_info/bmob_start_swf_info")
require("swf_anim_info/bmob_end_swf_info")

require("swf_anim_pin/bmob_hundred_start_swf_pin")
require("swf_anim_pin/bmob_hundred_end_swf_pin")
require("swf_anim_pin/bmob_ten_start_swf_pin")
require("swf_anim_pin/bmob_ten_end_swf_pin")
require("swf_anim_pin/bmob_start_swf_pin")
require("swf_anim_pin/bmob_end_swf_pin")

BmobAnim = class()

BmobAnim.defaultTime = 800

--炸弹动画资源配置表
BmobAnim.resource_list = {
    ["bmob_icon"] = "swf_anim_pin/bmob_start_swf_pin.png",
}

--创建炸弹动画 
function BmobAnim.ctor(self,start_view,end_view,num)
    if not start_view or not end_view then 
        return ;
    end 

    self.num = num or 1;
    self.m_start_view = start_view;
    self.m_end_view = end_view;
    self.m_start_x,self.m_start_y = self.m_start_view:getAbsolutePos();
    self.m_end_x,self.m_end_y = self.m_end_view:getAbsolutePos();
    self.index = 0;
end

--开始动画
function  BmobAnim.play(self)
    kEffectPlayer:playEffect(Effects.AUDIO_SEND_BMOB);
    self:startAnim()
end 

-- 开始动画
function BmobAnim.playHalfAnim(self)
    kEffectPlayer:playEffect(Effects.AUDIO_SEND_BMOB);
    self:bmobFly()
end

function BmobAnim.startAnim(self)
    self.is_playing_anim = true;
    if self.num ==1 then
        self.bmob_startAnim = new(SwfPlayer,bmob_start_swf_info); 
    elseif self.num == 10 then 
        self.bmob_startAnim = new(SwfPlayer,bmob_ten_start_swf_info); 
    elseif self.num == 100 then 
        self.bmob_startAnim = new(SwfPlayer,bmob_hundred_start_swf_info);
    else
        self.bmob_startAnim = new(SwfPlayer,bmob_start_swf_info); 
    end 

    self.bmob_startAnim:setCompleteEvent(self,self.bmobFly);
    self.bmob_startAnim:setAlign(kAlignTop);
    self.bmob_startAnim:setLevel(100);
    self.bmob_startAnim:setPos(0,-30);
    self.m_start_view:addChild(self.bmob_startAnim);
    self.bmob_startAnim:play(1,false,1);
end

function BmobAnim.bmobFly(self)
    self.bmob_startAnim = nil ;
    do 
        self:load();
        self:creatAnim();
    end 
end


-- 加载动画资源
function BmobAnim.load(self)
    if self.num ==1 then 
        self.m_bmob_icon = new(Image,self.resource_list.bmob_icon);
        self.m_bmob_icon:addToRoot();
    elseif self.num ==10 or self.num ==100 then 
        self.m_bmob_icon = new(Image,self.resource_list.bmob_icon);
        self.m_bmob_icon:addToRoot();

        self.m_bmob_icon_middle = new(Image,self.resource_list.bmob_icon);
--        self.m_bmob_icon_middle:setSize(79, 69);

        self.m_bmob_icon_small = new(Image,self.resource_list.bmob_icon);
--        self.m_bmob_icon_small:setSize(63, 55);

        self.m_bmob_icon_middle:addToRoot();
        self.m_bmob_icon_small:addToRoot();
    else 
        self.m_bmob_icon = new(Image,self.resource_list.bmob_icon);
        self.m_bmob_icon:addToRoot();
    end 
end

-- 创建动画
function BmobAnim.creatAnim(self)
    -- 流程动画 
    if self.num ==1 then 
        self.m_bmob_translate_anim = self.m_bmob_icon:addPropTranslate(3, kAnimNormal, BmobAnim.defaultTime, -1, self.m_start_x, self.m_end_x, self.m_start_y, self.m_end_y);
        if self.m_bmob_translate_anim then
            self.m_bmob_translate_anim:setDebugName("BmobAnim|m_bmob_translate_anim");
            self.m_bmob_translate_anim:setEvent(self, self.onBmobTranslateFinish);
        end
    else
        self.m_bmob_translate_anim = self.m_bmob_icon:addPropTranslate(3, kAnimNormal, BmobAnim.defaultTime, -1, self.m_start_x, self.m_end_x, self.m_start_y, self.m_end_y);
        if self.m_bmob_translate_anim then
            self.m_bmob_translate_anim:setDebugName("BmobAnim|m_bmob_translate_anim");
            self.m_bmob_translate_anim:setEvent(self, self.onBmobTranslateFinish);
        end

        self.m_bmob_middle_translate_anim = self.m_bmob_icon_middle:addPropTranslate(3, kAnimNormal, BmobAnim.defaultTime, 80, self.m_start_x, self.m_end_x, self.m_start_y, self.m_end_y);
        if self.m_bmob_middle_translate_anim then
            self.m_bmob_middle_translate_anim:setDebugName("BmobAnim|m_bmob_middle_translate_anim");
        end

        self.m_bmob_middle_transparency_anim = self.m_bmob_icon_middle:addPropTransparency(4, kAnimNormal, 0, -1,1,1);
        if self.m_bmob_middle_transparency_anim then
            self.m_bmob_middle_transparency_anim:setDebugName("BmobAnim|m_bmob_middle_transparency_anim");
        end

        self.m_bmob_small_translate_anim = self.m_bmob_icon_small:addPropTranslate(3, kAnimNormal, BmobAnim.defaultTime, 160, self.m_start_x, self.m_end_x, self.m_start_y, self.m_end_y);
        if self.m_bmob_small_translate_anim then
            self.m_bmob_small_translate_anim:setDebugName("BmobAnim|m_bmob_small_translate_anim");
        end

        self.m_bmob_small_transparency_anim = self.m_bmob_icon_small:addPropTransparency(4, kAnimNormal, 0, -1, 1, 1);
        if self.m_bmob_small_transparency_anim then
            self.m_bmob_small_transparency_anim:setDebugName("BmobAnim|m_bmob_small_transparency_anim");
        end

        if self.m_bmob_small_translate_anim then
            self.m_bmob_small_translate_anim:setEvent(self, self.onBmobTranslateFinish);
        end
    end 
end

function BmobAnim.onBmobTranslateFinish(self)
    if self.num ==1 then 
        self.m_bmob_icon:setVisible(false);
        if self.m_bmob_translate_anim then
            self.m_bmob_icon:removeProp(3);
            self.m_bmob_translate_anim = nil;
            delete(self.m_bmob_icon);
            self.m_bmob_icon = nil;
        end
    else 
        self.m_bmob_icon:setVisible(false);
        self.m_bmob_icon_middle:setVisible(false);
        self.m_bmob_icon_small:setVisible(false);
        if self.m_bmob_translate_anim then
            self.m_bmob_icon:removeProp(3);
            self.m_bmob_translate_anim = nil;
            delete(self.m_bmob_icon);
            self.m_bmob_icon = nil;
        end
        if self.m_bmob_middle_translate_anim then
            self.m_bmob_icon_middle:removeProp(3);
            self.m_bmob_middle_translate_anim = nil;
        end
        if self.m_bmob_middle_transparency_anim then
            self.m_bmob_icon_middle:removeProp(4);
            self.m_bmob_middle_transparency_anim = nil;
        end

        if self.m_bmob_icon_middle then 
            delete(self.m_bmob_icon_middle);
            self.m_bmob_icon_middle = nil;
        end

        if self.m_bmob_small_translate_anim then
            self.m_bmob_icon_small:removeProp(3);
            self.m_bmob_small_translate_anim = nil;
        end

        if self.m_bmob_small_transparency_anim then
            self.m_bmob_icon_small:removeProp(4);
            self.m_bmob_small_transparency_anim = nil;
        end

        if self.m_bmob_icon_small then
            delete(self.m_bmob_icon_small);
            self.m_bmob_icon_small = nil;
        end
    end 
    self:bmobFlyEnd()
end 

function BmobAnim.bmobFlyEnd(self)
    if self.num == 1 then
        self.bmob_endAnim = new(SwfPlayer,bmob_end_swf_info);
        self.bmob_endAnim:setPos(-10,0);
    elseif self.num == 10 then
        self.bmob_endAnim = new(SwfPlayer,bmob_ten_end_swf_info);
        self.bmob_endAnim:setPos(10,-5);
    elseif self.num == 100 then
        self.bmob_endAnim = new(SwfPlayer,bmob_hundred_end_swf_info);
        self.bmob_endAnim:setPos(30,0);
    else
        self.bmob_endAnim = new(SwfPlayer,bmob_end_swf_info);
        self.bmob_endAnim:setPos(0,0);
    end

    self.bmob_endAnim:setAlign(kAlignCenter);
--    self.bmob_endAnim:setPos(20,0);
    self.bmob_endAnim:setCompleteEvent(self,function()
        self.bmob_endAnim = nil
        self.is_playing_anim = false
        self:stop()
    end);
    self.m_end_view:addChild(self.bmob_endAnim)
    self.bmob_endAnim:play(1,false,1);
end 

function BmobAnim.stop(self)
    self.is_playing_anim = false

    if self.bmob_startAnim then
        delete(self.bmob_startAnim);
        self.bmob_startAnim = nil;
    end

    if self.m_bmob_icon then
        self.m_bmob_icon:removeProp(3);
        self.m_bmob_translate_anim = nil;
        delete(self.m_bmob_icon);
        self.m_bmob_icon = nil;
    end

    if self.m_bmob_icon_middle then 
        self.m_bmob_icon_middle:removeProp(3);
        self.m_bmob_icon_middle:removeProp(4);
        self.m_bmob_middle_translate_anim = nil;
        self.m_bmob_middle_transparency_anim = nil;
        delete(self.m_bmob_icon_middle);
        self.m_bmob_icon_middle = nil;
    end

    if self.m_bmob_icon_small then
        self.m_bmob_icon_small:removeProp(3);
        self.m_bmob_icon_small:removeProp(4);
        self.m_bmob_small_translate_anim = nil;
        self.m_bmob_small_transparency_anim = nil;
        delete(self.m_bmob_icon_small);
        self.m_bmob_icon_small = nil;
    end

    if self.bmob_endAnim then
        delete(self.bmob_endAnim);
        self.bmob_endAnim = nil;
    end
    self.is_playing_anim = false
    self:onAnimEndCallback()
end

-- 卸载动画
function BmobAnim.dtor(self)
--    self:stop();
end

--[Comment]
--可以设置动画结束回调
function BmobAnim.setCallBack(self,obj,func)
    self.m_func = func
    self.m_obj = obj
end

function BmobAnim.onAnimEndCallback(self,...)
    if self.m_func and self.m_obj then
        self.m_func(self.m_obj,...)
    end
end