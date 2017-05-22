--kissANim.lua
--Date 2016.8.7
--飞吻动画
--endregion

require("swfTween/swfPlayer");
require("swf_anim_info/kiss_hundred_start_swf_info")
require("swf_anim_info/kiss_hundred_end_swf_info")
require("swf_anim_info/kiss_ten_start_swf_info")
require("swf_anim_info/kiss_ten_end_swf_info")
require("swf_anim_info/kiss_start_swf_info")
require("swf_anim_info/kiss_end_swf_info")

require("swf_anim_pin/kiss_hundred_start_swf_pin")
require("swf_anim_pin/kiss_hundred_end_swf_pin")
require("swf_anim_pin/kiss_ten_start_swf_pin")
require("swf_anim_pin/kiss_ten_end_swf_pin")
require("swf_anim_pin/kiss_start_swf_pin")
require("swf_anim_pin/kiss_end_swf_pin")

KissAnim = class()

KissAnim.defaultTime = 800

-- 动画资源配置表
KissAnim.resource_list = {
                             ["kiss_icon"] = "swf_anim_pin/kiss_start_swf_pin.png",--"swf_anim_pin/kiss/anim_lips_icon.png",
--                             ["heart_list"] = {
--                                                   "swf_anim_pin/kiss/anim_heart_01.png",
--                                                   "swf_anim_pin/kiss/anim_heart_02.png", 
--                                                   "swf_anim_pin/kiss/anim_heart_03.png", 
--                                                   "swf_anim_pin/kiss/anim_heart_04.png", 
--                                                   "swf_anim_pin/kiss/anim_heart_05.png", 
--                                                   "swf_anim_pin/kiss/anim_heart_06.png", 
--                                                   "swf_anim_pin/kiss/anim_heart_07.png", 
--                                                   "swf_anim_pin/kiss/anim_heart_08.png", 
--                                                   "swf_anim_pin/kiss/anim_heart_09.png",
--                                                   "swf_anim_pin/kiss/anim_heart_10.png",
--                                                   "swf_anim_pin/kiss/anim_heart_11.png",
--                                                   "swf_anim_pin/kiss/anim_heart_12.png",
--                                                  },
--                             ["face_bg"] = "swf_anim_pin/kiss/anim_face_bg.png",
--                             ["eye_list"] = {
--                                                "swf_anim_pin/kiss/anim_face_01.png",
--                                                "swf_anim_pin/kiss/anim_face_02.png",
--                                                "swf_anim_pin/kiss/anim_face_03.png",
--                                            },
--			                 ["hand_list"] = {
--                                                "swf_anim_pin/kiss/anim_hand_01.png",
--                                                "swf_anim_pin/kiss/anim_hand_02.png",
--                                                "swf_anim_pin/kiss/anim_hand_03.png",
--					                            "swf_anim_pin/kiss/anim_hand_04.png",
--                                                "swf_anim_pin/kiss/anim_hand_05.png",
--                                                "swf_anim_pin/kiss/anim_hand_06.png",
--                                             },
                            };

                            --[Comment]
--创建飞吻动画
--startPos: start_view 起始点
--endPos: end_view 结束点 
function KissAnim.ctor(self, start_view, end_view,num)
    if not start_view or not end_view then
        return;
    end

    self.num = num or 1
    self.m_start_view = start_view;
    self.m_end_view = end_view;
    self.m_start_x,self.m_start_y = self.m_start_view:getAbsolutePos();
    self.m_end_x,self.m_end_y = self.m_end_view:getAbsolutePos();
    self.index = 0;
end

-- 开始动画
function KissAnim.play(self)
    kEffectPlayer:playEffect(Effects.AUDIO_SEND_KISS);
    self:startAnim()
--    self:load();
--    self:creatAnim();
end

-- 开始动画
function KissAnim.playHalfAnim(self)
    kEffectPlayer:playEffect(Effects.AUDIO_SEND_KISS);
    self:kissFly()
end


function KissAnim.startAnim(self)
    self.is_playing_anim = true
    if self.num == 1 then
--        self:load();
--        self:creatAnim();
--        return
--    end
        self.kiss_startAnim = new(SwfPlayer,kiss_start_swf_info);
    elseif self.num == 10 then
        self.kiss_startAnim = new(SwfPlayer,kiss_ten_start_swf_info);
    elseif self.num == 100 then
        self.kiss_startAnim = new(SwfPlayer,kiss_hundred_start_swf_info);
    else
        self.kiss_startAnim = new(SwfPlayer,kiss_start_swf_info);
    end

--    self.kiss_startAnim = new(SwfPlayer,card_start_swf_info);
    self.kiss_startAnim:setCompleteEvent(self,self.kissFly);
    self.kiss_startAnim:setAlign(kAlignTop);
    self.kiss_startAnim:setLevel(100);
    self.kiss_startAnim:setPos(0,0);
    self.m_start_view:addChild(self.kiss_startAnim);
    self.kiss_startAnim:play(1,false,1);
end

function KissAnim.kissFly(self)
    self.kiss_startAnim = nil;
    do
        self:load();
        self:creatAnim();
    end
    
end

-- 加载动画资源
function KissAnim.load(self)
    self.m_kiss_icon = new(Image,self.resource_list.kiss_icon);

    self.m_kiss_icon_middle = new(Image,self.resource_list.kiss_icon);
    self.m_kiss_icon_middle:setSize(79, 69);

    self.m_kiss_icon_small = new(Image,self.resource_list.kiss_icon);
    self.m_kiss_icon_small:setSize(63, 55);

    self.m_kiss_icon:addToRoot();
    self.m_kiss_icon_middle:addToRoot();
    self.m_kiss_icon_small:addToRoot();
end

-- 创建动画
function KissAnim.creatAnim(self)
    -- 流程动画                                                     
    self.m_kiss_translate_anim = self.m_kiss_icon:addPropTranslate(3, kAnimNormal, KissAnim.defaultTime, -1, self.m_start_x, self.m_end_x, self.m_start_y, self.m_end_y);
    if self.m_kiss_translate_anim then
        self.m_kiss_translate_anim:setDebugName("KissAnim|m_kiss_translate_anim");
    end

    self.m_kiss_middle_translate_anim = self.m_kiss_icon_middle:addPropTranslate(3, kAnimNormal, KissAnim.defaultTime, 80, self.m_start_x, self.m_end_x, self.m_start_y, self.m_end_y);
    if self.m_kiss_middle_translate_anim then
        self.m_kiss_middle_translate_anim:setDebugName("KissAnim|m_kiss_middle_translate_anim");
    end

    self.m_kiss_middle_transparency_anim = self.m_kiss_icon_middle:addPropTransparency(4, kAnimNormal, 0, -1, 0.6, 0.6);
    if self.m_kiss_middle_transparency_anim then
        self.m_kiss_middle_transparency_anim:setDebugName("KissAnim|m_kiss_middle_transparency_anim");
    end

    self.m_kiss_small_translate_anim = self.m_kiss_icon_small:addPropTranslate(3, kAnimNormal, KissAnim.defaultTime, 160, self.m_start_x, self.m_end_x, self.m_start_y, self.m_end_y);
    if self.m_kiss_small_translate_anim then
        self.m_kiss_small_translate_anim:setDebugName("KissAnim|m_kiss_small_translate_anim");
    end

    self.m_kiss_small_transparency_anim = self.m_kiss_icon_small:addPropTransparency(4, kAnimNormal, 0, -1, 0.3, 0.3);
    if self.m_kiss_small_transparency_anim then
        self.m_kiss_small_transparency_anim:setDebugName("KissAnim|m_kiss_small_transparency_anim");
    end

    if self.m_kiss_small_translate_anim then
        self.m_kiss_small_translate_anim:setEvent(self, self.onKissTranslateFinish);
    end
end

function KissAnim.onKissTranslateFinish(self)
    self.m_kiss_icon:setVisible(false);
    self.m_kiss_icon_middle:setVisible(false);
    self.m_kiss_icon_small:setVisible(false);

    if self.m_kiss_translate_anim then
        self.m_kiss_icon:removeProp(3);
        self.m_kiss_translate_anim = nil;
        delete(self.m_kiss_icon);
        self.m_kiss_icon = nil;
    end

    if self.m_kiss_middle_translate_anim then
        self.m_kiss_icon_middle:removeProp(3);
        self.m_kiss_middle_translate_anim = nil;
    end

    if self.m_kiss_middle_transparency_anim then
        self.m_kiss_icon_middle:removeProp(4);
        self.m_kiss_middle_transparency_anim = nil;
    end

    if self.m_kiss_icon_middle then 
        delete(self.m_kiss_icon_middle);
        self.m_kiss_icon_middle = nil;
    end

    if self.m_kiss_small_translate_anim then
        self.m_kiss_icon_small:removeProp(3);
        self.m_kiss_small_translate_anim = nil;
    end

    if self.m_kiss_small_transparency_anim then
        self.m_kiss_icon_small:removeProp(4);
        self.m_kiss_small_transparency_anim = nil;
    end

    if self.m_kiss_icon_small then
        delete(self.m_kiss_icon_small);
        self.m_kiss_icon_small = nil;
    end


    self:kissFlyEnd()
--    if self.num ~= 1 then 
--        self:kissFlyEnd()
--        return
--    end

--    self.m_heart_timer = new(AnimDouble,kAnimLoop, 0, 1, 100, -1);
--	self.m_heart_timer:setDebugName("KissAnim|m_heart_timer");
--	self.m_heart_timer:setEvent(self, self.onHeartRunTimer);

--    self.m_heart_view = new(Images,self.resource_list.heart_list);
--    self.m_heart_view:addToRoot();
--    local x = self.m_end_x - (self.m_heart_view.m_width / 2 - self.m_end_view.m_width / 2);
--    local y = self.m_end_y - (self.m_heart_view.m_height / 2 - self.m_end_view.m_height / 2);
--    self.m_heart_view:setPos(x, y);  
end

function KissAnim.kissFlyEnd(self)
    if self.num == 1 then
        self.kiss_endAnim = new(SwfPlayer,kiss_end_swf_info);
    elseif self.num == 10 then
        self.kiss_endAnim = new(SwfPlayer,kiss_ten_end_swf_info);
    elseif self.num == 100 then
        self.kiss_endAnim = new(SwfPlayer,kiss_hundred_end_swf_info);
    else
        self.kiss_endAnim = new(SwfPlayer,kiss_end_swf_info);
    end

    self.kiss_endAnim:setAlign(kAlignCenter);
    self.kiss_endAnim:setPos(-6,-8);
    self.kiss_endAnim:setCompleteEvent(self,function()
        self.kiss_endAnim = nil
        self.is_playing_anim = false
        self:stop()
    end);
    self.m_end_view:addChild(self.kiss_endAnim)
    self.kiss_endAnim:play(1,false,1);
end

--function KissAnim.onHeartRunTimer(self)
--    self.index = self.index + 1;
--    self.m_heart_view:setImageIndex(self.index % 12);
--    if self.index % 12 == 0 then 
--        self.m_heart_view:setVisible(false);
--        if self.m_heart_timer then
--            delete(self.m_heart_timer);
--            self.m_heart_timer = nil;
--        end

--        if self.m_heart_view then
--            delete(self.m_heart_view);
--            self.m_heart_view = nil;
--        end

--        self.m_face_bg = new(Image,self.resource_list.face_bg);
--        self.m_face_bg:addToRoot();
--        local x = self.m_end_x - (self.m_face_bg.m_width / 2 - self.m_end_view.m_width / 2);
--        local y = self.m_end_y - (self.m_face_bg.m_height / 2 - self.m_end_view.m_height / 2);
--        self.m_face_bg:setPos(x, y);

--        self.m_eye_view = new(Images,self.resource_list.eye_list);
--        self.m_face_bg:addChild(self.m_eye_view);
--        self.m_eye_view:setAlign(kAlignCenter);

--        self.m_hand_view = new(Images,self.resource_list.hand_list);
--        self.m_face_bg:addChild(self.m_hand_view);
--        self.m_hand_view:setAlign(kAlignBottom);

--        self.m_eye_timer = new(AnimDouble,kAnimRepeat, 0, 1, 100, -1);
--	    self.m_eye_timer:setDebugName("KissAnim|m_eye_timer");
--	    self.m_eye_timer:setEvent(self, self.onEyeRunTimer);

--        self.m_face_transparency_anim = self.m_face_bg:addPropTransparency(8, kAnimNormal, 600, 800, 1.0, 0);
--        if self.m_face_transparency_anim then
--            self.m_face_transparency_anim:setDebugName("KissAnim|m_face_transparency_anim");
--	        self.m_face_transparency_anim:setEvent(self, self.onAnimEnd);
--        end
--    end 
--end

--function KissAnim.onEyeRunTimer(self)
--    self.index = self.index + 1;
--    self.m_eye_view:setImageIndex(self.index % 3);
--    self.m_hand_view:setImageIndex(self.index % 6);
--end


function KissAnim.stop(self)
    self.is_playing_anim = false

    if self.kiss_startAnim then
        delete(self.kiss_startAnim);
        self.kiss_startAnim = nil;
    end

    if self.m_kiss_icon then
        self.m_kiss_icon:removeProp(3);
        self.m_kiss_translate_anim = nil;
        delete(self.m_kiss_icon);
        self.m_kiss_icon = nil;
    end

    if self.m_kiss_icon_middle then 
        self.m_kiss_icon_middle:removeProp(3);
        self.m_kiss_icon_middle:removeProp(4);
        self.m_kiss_middle_translate_anim = nil;
        self.m_kiss_middle_transparency_anim = nil;
        delete(self.m_kiss_icon_middle);
        self.m_kiss_icon_middle = nil;
    end

    if self.m_kiss_icon_small then
        self.m_kiss_icon_small:removeProp(3);
        self.m_kiss_icon_small:removeProp(4);
        self.m_kiss_small_translate_anim = nil;
        self.m_kiss_small_transparency_anim = nil;
        delete(self.m_kiss_icon_small);
        self.m_kiss_icon_small = nil;
    end

    if self.kiss_endAnim then
        delete(self.kiss_endAnim);
        self.kiss_endAnim = nil;
    end
    self.is_playing_anim = false
    self:onAnimEndCallback()
end

--function KissAnim.onAnimEnd(self)
--    self:stop();
--end

--function KissAnim.stop(self)
--    self.is_playing_anim = false

--    if self.m_kiss_translate_anim then
--        self.m_kiss_icon:removeProp(3);
--        self.m_kiss_translate_anim = nil;
--    end

--    if self.m_kiss_middle_translate_anim then
--        self.m_kiss_icon_middle:removeProp(3);
--        self.m_kiss_middle_translate_anim = nil;
--    end

--    if self.m_kiss_middle_transparency_anim then
--        self.m_kiss_icon_middle:removeProp(4);
--        self.m_kiss_middle_transparency_anim = nil;
--    end

--    if self.m_kiss_small_translate_anim then
--        self.m_kiss_icon_small:removeProp(3);
--        self.m_kiss_small_translate_anim = nil;
--    end

--    if self.m_kiss_small_transparency_anim then
--        self.m_kiss_icon_small:removeProp(4);
--        self.m_kiss_small_transparency_anim = nil;
--    end

--    if self.m_kiss_icon then 
--        delete(self.m_kiss_icon);
--        self.m_kiss_icon = nil;
--    end

--    if self.m_kiss_icon_middle then
--        delete(self.m_kiss_icon_middle);
--        self.m_kiss_icon_middle = nil;
--    end

--    if self.m_kiss_icon_small then
--        delete(self.m_kiss_icon_small);
--        self.m_kiss_icon_small = nil;
--    end

--    if self.m_heart_timer then
--        delete(self.m_heart_timer);
--        self.m_heart_timer = nil;
--    end

--    if self.m_heart_view then 
--        delete(self.m_heart_view);
--        self.m_heart_view = nil;
--    end

--    if self.m_eye_timer then
--        delete(self.m_eye_timer);
--        self.m_eye_timer = nil;
--    end

--    if self.m_face_transparency_anim then
--        self.m_face_bg:removeProp(8);
--        self.m_face_transparency_anim = nil;
--    end

--    if self.m_eye_view then 
--        delete(self.m_eye_view);
--        self.m_eye_view = nil;
--    end

--    if self.m_hand_view then 
--        delete(self.m_hand_view);
--        self.m_hand_view = nil;
--    end

--    if self.m_face_bg then 
--        delete(self.m_face_bg);
--        self.m_face_bg = nil;
--    end
--    self:onAnimEndCallback()
--end

-- 卸载动画
function KissAnim.dtor(self)
--    self:stop();
end

--[Comment]
--可以设置动画结束回调
function KissAnim.setCallBack(self,obj,func)
    self.m_func = func
    self.m_obj = obj
end

function KissAnim.onAnimEndCallback(self,...)
    if self.m_func and self.m_obj then
        self.m_func(self.m_obj,...)
    end
end
