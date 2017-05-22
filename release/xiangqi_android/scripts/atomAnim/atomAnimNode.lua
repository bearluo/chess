require("atomAnim/atomAnimUtils")
require("atomAnim/animEx")
AtomAnimNode = class(Node);

AtomAnimNode.ctor = function(self)
    self.m_anims = {};      --动画数组
    self.m_anim_map = {};   --动画索引，是resourceId作为索引key，value是一组数组
    self.m_autoRelease = true;
    self.m_isPlaying = false;
    self.m_isPause = false; --是否暂停
end;

AtomAnimNode.dtor = function(self)
    if self.m_anims ~= nil and #self.m_anims > 0 then
        self:release();
    end;
    self.m_anims = nil;
    self.m_anim_map = nil;
    self.m_isPlaying = false;
    self.m_isPause = false;
end;

--播放
AtomAnimNode.play = function(self)
    if self.m_isPlaying == true then
        self:stop();
    end
    self.m_isPlaying = true;
    local num = self:getAnimNum();
    if num == 0 then
        self:finish();
        return;
    end;
    num = 0;
    local finish = 0;
    self.m_isFinish = false;
    for k,v in self:playPairs() do
        
        v.onFinish = function(v)
            self:hideNode(v.m_node);
            finish = finish + 1;
            if finish == num then
                self:finish();--所有动画都完成至少一个周期时调用
            end;
        end;

        v.onStart = function(v)
            self:setParentVisible(v.m_node, true);
        end
        
        num = num + 1;
        v:play();
    end;
    if self.m_isPause == true then
        self:pause();
    end
end;

--添加动画索引
AtomAnimNode.addAnimMap = function(self, v)
    if v and v.m_node and v.m_node.m_resourceId then
        self.m_anim_map[v.m_node.m_resourceId] = self.m_anim_map[v.m_node.m_resourceId] or {};
        local len = #self.m_anim_map[v.m_node.m_resourceId];
        self.m_anim_map[v.m_node.m_resourceId][len+1] = v;
    end
end

--判断当前结点是否还在播放
AtomAnimNode.isNodePlaying = function(self, node)
    local ret = false;
    if node and node.m_resourceId and self.m_anim_map and self.m_anim_map[node.m_resourceId] then
        local len = #self.m_anim_map[node.m_resourceId];
        for i = 1, len do
            if self.m_anim_map[node.m_resourceId][i] then
                if self.m_anim_map[node.m_resourceId][i].m_isPlaying == true then
                    ret = true;
                    break;
                end
            end
        end
    end
    return ret;
end

--判断是否播放中
AtomAnimNode.isPlaying = function(self)
    local ret = false;
    if self.m_isPlaying ~= nil then
        ret = self.m_isPlaying;
    end
    return ret;
end

--判断是否暂停
AtomAnimNode.isPause = function(self)
    local ret = false;
    if self.m_isPause ~= nil then
        ret = self.m_isPause;
    end
    return ret;
end

AtomAnimNode.setParentVisible = function(self, node, visible)
    if node and node.m_parent and node.m_parent ~= self then
        if node.m_parent.m_origVisible == true then
            node.m_parent:setVisible(visible);
        end
        self:setParentVisible(node.m_parent, visible);
    end
end

AtomAnimNode.getChildrenVisible = function(self, node)
    local ret = false;
    if node then
        local children = node:getChildren();
        if children then
            for _, v in pairs(children) do
                ret = v:getVisible();
                if ret == true then
                    break;
                end
            end
        end
    end
    return ret;
end

AtomAnimNode.hideNode = function(self, node)
    if node and node ~= self then
        if not self:isNodePlaying(node) then
            if not self:getChildrenVisible(node) then
                node:setVisible(false);
                self:hideNode(node.m_parent);
            end
        end
    end
end

--设置是否自动释放
AtomAnimNode.setAutoRelease = function(self, autoRelease)
    if autoRelease == nil then
        autoRelease = true;
    end
    self.m_autoRelease = autoRelease;
end

--是否自动释放
AtomAnimNode.isAutoRelease = function(self)
    return self.m_autoRelease;
end

--停止播放
AtomAnimNode.stop = function(self)
    self.m_isPlaying = false;
    self.m_isPause = false;
    if self.m_anims then
        for k,v in ipairs(self.m_anims) do
            v[1]:stop();
        end;
    end
end;

--播放完成
AtomAnimNode.finish = function(self)
    if self.m_isFinish == true then
        return;
    end
    self.m_isFinish = true;
    if self.m_autoRelease == true then
       self:release();
    end
    self:onEvent();
end;

-- 动画释放资源
AtomAnimNode.release = function(self)
    if self.m_startCallBack ~= nil then
        self.m_startCallBack:dtor();
        self.m_startCallBack = nil;
    end
    self:stop(); 
    if self.m_anims then
        for k,v in ipairs(self.m_anims) do
            delete(v[1]);
        end;
    end
    
    self.m_anims = {};
    self.m_anim_map = {};

    if self.m_parent then
        self.m_parent:removeChild(self, true);
    end
end

-- 动画事件触发
AtomAnimNode.onEvent = function(self)
    if self.m_eventCallback then
        if self.m_eventCallback.obj and self.m_eventCallback.func then
            self.m_eventCallback.func(self.m_eventCallback.obj, event, anim);
        end
    end
end;

-- 设置事件回调
AtomAnimNode.setEvent = function(self, obj, func)
    self.m_eventCallback = self.m_eventCallback or {};
	self.m_eventCallback.obj = obj;
	self.m_eventCallback.func = func;
end

AtomAnimNode.addAnim = function(self, anim, name, autoPlay)
    self.m_anims[#self.m_anims + 1] = {anim, autoPlay};
    self:addAnimMap(anim);
end

AtomAnimNode.removeAnim = function(self, anim)
    for k,v in ipairs(self.m_anims) do
        if v == anim then
            table.remove(self.m_anims, k);
            return;
        end
    end
end

AtomAnimNode.getAnim = function(self, index)
    local d = self.m_anims[index]
    return d and d[1];
end;

AtomAnimNode.getAnimByName = function(self, name)
    return self.m_anim_map[name];
end;

AtomAnimNode.getAnimNum = function(self)
    local ret = 0;
    if self.m_anims ~= nil then
        ret = #self.m_anims;
    end
    return ret;
end;

AtomAnimNode.animPairs = function(self)
    local i = 1;
    return function()
        local anim = self.m_anims;
        i = i + 1;
        if anim then
            return i, anim[1];
        else
            return nil;
        end
    end
end

AtomAnimNode.playPairs = function(self)
    local i = 1;
    return function()
        local anim = self.m_anims[i];
        while anim and anim[2] == false do
            i = i + 1;
            anim = self.m_anims[i];
        end;
        i = i + 1;
        if anim then
            return i, anim[1];
        else
            return nil;
        end
    end
end

--[Comment]
--通过名字查找子节点
--只支持第一个匹配
--索引名字"A.B.C",A为AtomAnimNode的子节点
AtomAnimNode.findNodeByName = function(self, str)
    local node = self;
    if str ~= nil then
        local paths = AtomAnimUtils.mysplit(str, ".");
        if paths ~= nil and #paths > 0 then
            for _, v in ipairs(paths) do
               node = node:getChildByName(v);
               if node == nil then
                    break;
               end
            end
        end
    end
    if node == self then
        node = nil;
    end
    return node;
end

--暂停，注意暂停不会改变播放状态
AtomAnimNode.pause = function(self)
    self.m_isPause = true;
    if self.m_isPlaying == true then
        if self.m_anims ~= nil then
            for _,v in ipairs(self.m_anims) do
                v[1]:pause();
            end
        end
    end
end

--恢复
AtomAnimNode.resume = function(self)
    self.m_isPause = false;
    if self.m_isPlaying == true then
        if self.m_anims ~= nil then
            for _,v in ipairs(self.m_anims) do
                v[1]:resume();
            end
        end
    end
end