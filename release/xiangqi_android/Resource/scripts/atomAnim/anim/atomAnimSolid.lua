require("atomAnim/atomAnimUtils")
--region AtomAnimSolid.lua
--Author : KimWang
--Date   : 2015/3/12
--固定动画基类
--该类动画特点：先进行延时然后再改变对应的属性起始值
AtomAnimSolid = class()

--[Comment]
--构造函数
--node  结点
--delay 延时时间
AtomAnimSolid.ctor = function(self, node, delay)
    self.m_node = node;
    self.m_delay = delay or 0;
    self.m_isPlaying = false;   -- 是否还处于延时中
    self.m_isFhished = false;   -- 是否完成一个周期
    self.m_anim = nil;

    if self.m_node then
        self.m_node:setVisible(false);
    end
end

AtomAnimSolid.dtor = function(self)
    self:stop();
end

--[Comment]
--延迟改变属性
--如果上次延迟还没有结束，会先停止上次播放动作
AtomAnimSolid.play = function(self)
    if self.m_isPlaying == true then
        self:stop();
    end
    self.m_isPlaying = true;
    self.m_anim = AtomAnimUtils.delayCall(self.m_delay, self, self.callBack);
end

--[Comment]
--停止
AtomAnimSolid.stop = function(self)
    if self.m_anim ~= nil then
        self.m_anim:dtor();
        self.m_anim = nil;
    end
    self.m_isPlaying = false;
end

--[Comment]
--延时回调
--该函数先停止紧接调用具体的回调函数
AtomAnimSolid.callBack = function(self)
    self:stop();
    if self.m_node ~= nil then
        self:callBackHandler();
    end
    if self.onFinish ~= nil and self.m_isFhished == false then
        self.m_isFhished = true;
        self:onFinish();
    end
end

--[Comment]
--延时回调处理
--这里需要子类重写
AtomAnimSolid.callBackHandler = function(self)
end

-------------------------------AtomAnimIncSolid---------------------------
--固定固定动画
--该类动画特点：先进行延时然后再将其新增的属性值叠加到对象上
AtomAnimIncSolid = class(AtomAnimSolid);

--[Comment]
--构造函数
--node  结点
--delay 延时时间
--sequence 属性序列值
AtomAnimIncSolid.ctor = function(self, node, delay, sequence)
    self.m_sequence = sequence;
end

AtomAnimIncSolid.dtor = function(self)
    self:release();
end

AtomAnimIncSolid.release = function(self)
    if  self.m_node and self.m_node.m_props[self.m_sequence] then
        self.m_node:removeProp(self.m_sequence);
    end
end

--[Comment]
--延时回调处理
--这里需要子类重写
AtomAnimIncSolid.callBackHandler = function(self)
end