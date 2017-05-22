--ShellAnim.lua
--Date 2016.8.7
--大炮子弹动画
--endregion

require("swfTween/swfPlayer");
require("swf_anim_info/shell_swf_info")
require("swf_anim_pin/shell_swf_pin")

ShellAnim = class();

--[Comment]
--大炮子弹动画
function ShellAnim.ctor(self,parant)
    if not parant then
        return
    end
    self.mParant = parant
    self.mX = 0
    self.mY = 0
end

function ShellAnim:dtor()
    if self.startAnimView then
        delete(self.startAnimView);
        self.startAnimView = nil;
    end
end

function ShellAnim.play(self)
    self:startAnim()
end

function ShellAnim.startAnim(self)
    if self.is_playing_anim then
        self:stop()
    end
    self.is_playing_anim = true
    self.startAnimView = new(SwfPlayer,shell_swf_info);
    self.startAnimView:setCompleteEvent(self,self.stop);
    self.startAnimView:setFrameEvent(self,self.onRemovePc,12)
    self.startAnimView:setLevel(100)
    self.startAnimView:setPos(self.mX-73,self.mY-760)
    self.mParant:addChild(self.startAnimView);
    self.startAnimView:play(1,false,1);
end

function ShellAnim.stop(self)
    if self.startAnimView then
        delete(self.startAnimView);
        self.startAnimView = nil;
    end
    self.is_playing_anim = false
    self:onAnimEndCallback()
end

function ShellAnim:setPos(x,y)
    self.mX = x or self.mX
    self.mY = y or self.mY
end
--[Comment]
--可以设置动画结束回调
function ShellAnim.setCallBack(self,obj,func)
    self.m_func = func
    self.m_obj = obj
end

function ShellAnim.onAnimEndCallback(self,...)
    if self.m_func and self.m_obj then
        self.m_func(self.m_obj,...)
    end
end
--[Comment]
--可以设置移除棋子回调
function ShellAnim.setRemovePcCallBack(self,obj,func)
    self.m_paodanFunc = func
    self.m_paodanObj = obj
end

function ShellAnim.onRemovePc(self,...)
    if self.m_paodanFunc and self.m_paodanObj then
        self.m_paodanFunc(self.m_paodanObj,...)
    end
end