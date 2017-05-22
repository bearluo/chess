--BigGunAnim.lua
--Date 2016.8.7
--大炮动画
--endregion

require("swfTween/swfPlayer");
require("swf_anim_info/big_gun_swf_info")
require("swf_anim_pin/big_gun_swf_pin")

BigGunAnim = class();

--[Comment]
--大炮动画
function BigGunAnim.ctor(self,parant)
    if not parant then
        return
    end
    self.mParant = parant
    self.startAnimView = new(SwfPlayer,big_gun_swf_info);
    self.startAnimView:setCompleteEvent(self,self.stop);
    self.startAnimView:setFrameEvent(self,self.onSendPaodan,22)
    self.startAnimView:gotoAndStop(5)
    self.mParant:addChild(self.startAnimView);
end

function BigGunAnim:dtor()
    if self.startAnimView then
        delete(self.startAnimView);
        self.startAnimView = nil;
    end
end

function BigGunAnim.play(self)
    self:startAnim()
end

function BigGunAnim.startAnim(self)
    if self.is_playing_anim then
        self:stop()
    end
    self.is_playing_anim = true
    self.startAnimView:play(1,true,1);
end

function BigGunAnim.stop(self)
    self.is_playing_anim = false
    self.startAnimView:gotoAndStop(5)
    self:onAnimEndCallback()
end

--[Comment]
--可以设置动画结束回调
function BigGunAnim.setCallBack(self,obj,func)
    self.m_func = func
    self.m_obj = obj
end

function BigGunAnim.onAnimEndCallback(self,...)
    if self.m_func and self.m_obj then
        self.m_func(self.m_obj,...)
    end
end

--[Comment]
--可以设置发送子弹回调
function BigGunAnim.setPaodanCallBack(self,obj,func)
    self.m_paodanFunc = func
    self.m_paodanObj = obj
end

function BigGunAnim.onSendPaodan(self,...)
    if self.m_paodanFunc and self.m_paodanObj then
        self.m_paodanFunc(self.m_paodanObj,...)
    end
end