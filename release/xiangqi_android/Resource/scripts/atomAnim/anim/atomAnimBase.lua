require("core/object")
require("core/drawing")
require("atomAnim/drawingEx")

--region atomAnimBase.lua
--Author : KimWang
--Date   : 2015/3/12
--普通动画基类,注意区分atomAnimSolid
AtomAnimBase = class()

AtomAnimBase.ctor = function(self, node, sequence, animType, duration, delay)
    self.m_node = node
    self.m_sequence = sequence
    self.m_animType = animType
    self.m_duration = duration
    self.m_delay = -1;
    self.m_delayCallBack = delay or -1; --开始播放动画前的延时时间
    self.m_isFhished = false;           --是否完成一个周期
    self.m_node:setVisible(false);      --隐藏结点
end

AtomAnimBase.dtor = function(self)
   self:stop(); 
end

AtomAnimBase.createTimeMap = function(self, delay, duration, atom_time_map)
    self.m_keyStartTime     = delay;
    if self.m_node ~= nil then
        local time = delay + duration;
        atom_time_map = atom_time_map or {};
        atom_time_map["time"] = atom_time_map["time"] or {};
        atom_time_map[time] = atom_time_map[time] or {};
        if self.m_animType == kAnimNormal then
            table.insert(atom_time_map[time], self);
            table.insert(atom_time_map["time"], time);
        end
    end
    return atom_time_map;
end

AtomAnimBase.stopAnimByTimeMap = function(self, atom_time_map)
    if self.m_node ~= nil and atom_time_map ~= nil then
        for i = 1, #atom_time_map["time"] do
            local time = atom_time_map["time"][i];
            if time <= self.m_keyStartTime then
                if atom_time_map[time] ~= nil and #atom_time_map[time] > 0 then
                    for k, v in ipairs(atom_time_map[time]) do
                        if not (v.m_isPlaying == true) then
                            v:stop();
                        end
                    end
                    atom_time_map[time] = {};
                end
            end
        end
    end
end

--[Comment]
--返回动画属性
--这个要求子类重写
AtomAnimBase.addPropEase = function(self)
    return nil;
end

AtomAnimBase.play = function(self)
    if self.m_startCallBack ~= nil then
        self.m_startCallBack:dtor();
        self.m_startCallBack = nil;
    end
    if self.m_isPlaying == true then
        self:stop();
    end
    self.m_isFhished = false;
    self.m_startCallBack = AtomAnimUtils.delayCall(self.m_delayCallBack, self, self.startCallBack);
end

AtomAnimBase.stop = function(self)
    if  self.m_node ~= nil then
        self.m_node:removeAtomPropEase(self.m_sequence)
    end
    
    if self.m_startCallBack ~= nil then
        self.m_startCallBack:dtor();
        self.m_startCallBack = nil;
    end
    
    self.m_anim = nil
    self.m_isPlaying = false  
end

--开始播放时回调
AtomAnimBase.startCallBack = function(self) 
    if self.m_node.m_origVisible == true then
        self.m_node:setVisible(true);
    end
    self.m_isPlaying = true;
    self.m_anim = self:addPropEase();
    if self.m_anim ~= nil and self.m_anim[1] ~= nil then
        self.m_anim[1]:setEvent(self, self.finshCallBack);
        self.m_startCallBack:dtor();
        self.m_startCallBack = nil;
        if self.onStart ~= nil  then
            self:onStart();
        end
    end
end

--播放完成一个周期时回调
AtomAnimBase.finshCallBack = function(self) 
    if self.m_animType == kAnimNormal then
        self.m_isPlaying = false;
    end
    if self.onFinish ~= nil and self.m_isFhished == false then
        self.m_isFhished = true;
        self:onFinish();
    end
end

AtomAnimBase.pause = function(self)
    if self.m_anim ~= nil then
        for _, v in ipairs(self.m_anim) do
            v:pause();
        end
    end
    if self.m_startCallBack ~= nil then
        self.m_startCallBack:pause();
    end
end

AtomAnimBase.resume = function(self)
    if self.m_anim ~= nil then
        for _, v in ipairs(self.m_anim) do
            v:resume();
        end
    end
    if self.m_startCallBack ~= nil then
        self.m_startCallBack:resume();
    end
end