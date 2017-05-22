--StarAnim.lua
--Date 2016.8.7
--大炮子弹动画
--endregion

require("swfTween/swfPlayer");
require("swf_anim_info/star_swf_info")
require("swf_anim_pin/star_swf_pin")

StarAnim = class();

--[Comment]
--大炮子弹动画
function StarAnim.ctor(self,parant)
    if not parant then
        return
    end
    self.mParant = parant
    self.mX = 0
    self.mY = 0
end

function StarAnim:dtor()
    if self.startAnimView then
        delete(self.startAnimView);
        self.startAnimView = nil;
    end
end

function StarAnim.play(self,delay)
    self:startAnim(delay)
end

function StarAnim.startAnim(self,delay)
    if self.is_playing_anim then
        self:stop()
    end
    self.is_playing_anim = true
    self.startAnimView = new(SwfPlayer,star_swf_info);
    self.startAnimView:setCompleteEvent(self,self.stop);
    self.startAnimView:setPos(self.mX-128,self.mY-126)
    self.mParant:addChild(self.startAnimView);
    self.startAnimView:play(1,false,1,delay or 1);
end

function StarAnim.stop(self)
    if self.startAnimView then
        delete(self.startAnimView);
        self.startAnimView = nil;
    end
    self.is_playing_anim = false
    self:onAnimEndCallback()
end

function StarAnim:setPos(x,y)
    self.mX = x or self.mX
    self.mY = y or self.mY
end
--[Comment]
--可以设置动画结束回调
function StarAnim.setCallBack(self,obj,func)
    self.m_func = func
    self.m_obj = obj
end

function StarAnim.onAnimEndCallback(self,...)
    if self.m_func and self.m_obj then
        self.m_func(self.m_obj,...)
    end
end