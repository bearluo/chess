require("atomAnim/sceneLoaderEx")

require("atomAnim/anim/atomAnimAlpha")
require("atomAnim/anim/atomAnimBezier")
require("atomAnim/anim/atomAnimColor")
require("atomAnim/anim/atomAnimEllipse")
require("atomAnim/anim/atomAnimFrame")
require("atomAnim/anim/atomAnimJump")
require("atomAnim/anim/atomAnimRotate")
require("atomAnim/anim/atomAnimScale")
require("atomAnim/anim/atomAnimTranslate")
require("atomAnim/anim/atomAnimPosSolid")
require("atomAnim/anim/atomAnimSolid")
require("atomAnim/anim/atomAnimBase")
require("atomAnim/atomAnimNode")

AtomAnimLoader = class()

AtomAnimLoader.g_cacheFiles = {}

AtomAnimLoader.cacheFile = function(self, file)
    if AtomAnimLoader.g_cacheFiles[file] then
        return 
    end
    AtomAnimLoader.g_cacheFiles[file] = 1
    require(file)
end

AtomAnimLoader.loadFile = function(self, file, name)
    self:cacheFile(file)
    return self:load(_G[name])
end

AtomAnimLoader.load = function(self, animTable)
    if type(animTable) ~= "table" then 
        return
    end
    self.m_sequence = 0
    local node = self:loadAnimNode(animTable)
    node:addToRoot()
    return node
end

AtomAnimLoader.parseNode = function(self, animTable, parent)
    if animTable ~= nil then
    end
    local ret = SceneLoader.loadFuncMap[animTable.typeName](animTable)
    if ret then
        ret:setVisible(false);
    end
    local xScale = System.getScreenWidth() / System.getLayoutWidth();
	local yScale = System.getScreenHeight() / System.getLayoutHeight();
    if animTable.resourceId ~= nil then
        ret.m_resourceId = animTable.resourceId;
    end
    if animTable.origVisible ~= nil then
        ret.m_origVisible = animTable.origVisible;--原始可见性
    end
    for _, v in ipairs(animTable) do
        if type(v) == "table" then
            local x = v.x and v.x * xScale or v.x;
            local y = v.y and v.y * yScale or v.y;
            local node, flag = AtomAnimLoader:parseNode(v, ret)
            if flag then
                ret:addChild(node);
                if v.xyScale ~= true then
                    drawing_set_position(node.m_drawingID, x or 0, y or 0);
                end
            end
        end
    end
    return ret, true
end

AtomAnimLoader.parseAnimNode = function(self, animTable, parent)
    local xScale = System.getScreenWidth() / System.getLayoutWidth();
	local yScale = System.getScreenHeight() / System.getLayoutHeight();
    for _,v in ipairs(animTable) do
        local node,anim;
        if v.type then  --动画
            anim = self:parseAnim(v, parent)
            parent:addAnim(anim, v.anim, v.autoPlay)
        else            --结点
            local x = v.x and v.x * xScale or v.x;
            local y = v.y and v.y * yScale or v.y;
            node = AtomAnimLoader:parseNode(v, parent);
            parent:addChild(node);
            if v.xyScale ~= true then
                drawing_set_position(node.m_drawingID, x or 0, y or 0);
            end
        end;
    end
end

AtomAnimLoader.parseAnim = function(self, t, parent)
    local func = self.loadAnimFuncMap[t.type]
    if not func then
        error("cannot find anim type: " .. t.anim)
    end
    local ret = func(self, t, parent)
    return ret
end

AtomAnimLoader.loadAnimNode = function(self, animTable)
    local node = new(AtomAnimNode)
    SceneLoader.setBaseInfo(node,animTable)
    self:parseAnimNode(animTable, node)
    return node
end

AtomAnimLoader.findNode = function(self, root, id)
    local children = root:getChildren()
    if not children then
        return nil
    end
    for _, v in pairs(children) do
        if v.m_resourceId == id then
            return v
        else 
            local node = self:findNode(v, id)
            if node then 
                return node
            end
        end
    end
end

--[Comment]
--获取动画序列号，并且递增
AtomAnimLoader.incSequence = function(self)
    local sequence = self.m_sequence;
    self.m_sequence = self.m_sequence + 1;
    return sequence;
end

AtomAnimLoader.loadAnimAlpha = function(self, t, parent)
    local node = self:findNode(parent, t.id);
    local param = {
        node,
        self:incSequence(),
        t.animType,
        t.duration, 
        t.delay,
        t.startValue,
        t.endValue,
        t.easeType,
        t.period
    };
    return new(AtomAnimAlpha, unpack(param));
end

AtomAnimLoader.loadAnimAlphaSolid = function(self, t, parent)
    local node = self:findNode(parent, t.id);
    return new(AtomAnimAlphaSolid, node, t.delay, t.transparency);
end

AtomAnimLoader.loadAnimBezier = function(self, t, parent)
    local node = self:findNode(parent, t.id);
    local param = {
        node,
        self:incSequence(),
        t.animType,
        t.duration, 
        t.delay,
        t.startValueX,
        t.endValueX,
        t.startValueY,
        t.endValueY,
        t.controlValueX,
        t.controlValueY
    }
    return new(AtomAnimBezier, unpack(param));
end

AtomAnimLoader.loadAnimBezierX = function(self, t, parent)
    local node = self:findNode(parent, t.id);
    local param = {
        node,
        self:incSequence(),
        t.animType,
        t.duration, 
        t.delay,
        t.startValue,
        t.endValue,
        t.controlValue
    }
    return new(AtomAnimBezierX, unpack(param));
end

AtomAnimLoader.loadAnimBezierY = function(self, t, parent)
    local node = self:findNode(parent, t.id);
    local param = {
        node,
        self:incSequence(),
        t.animType,
        t.duration, 
        t.delay,
        t.startValue,
        t.endValue,
        t.controlValue
    }
    return new(AtomAnimBezierY, unpack(param));
end

AtomAnimLoader.loadAnimColor = function(self, t, parent)
    local node = self:findNode(parent, t.id);
    local param = {
        node,
        self:incSequence(),
        t.animType,
        t.duration, 
        t.delay,
        t.startValueRed,
        t.endValueRed,
        t.startValueGreen,
        t.endValueGreen,
        t.startValueBlue,
        t.endValueBlue,
        t.easeType,
        t.period
    }
    return new(AtomAnimColor, unpack(param));
end

AtomAnimLoader.loadAnimRed = function(self, t, parent)
    local node = self:findNode(parent, t.id);
    local param = {
        node,
        self:incSequence(),
        t.animType,
        t.duration, 
        t.delay,
        t.startValue,
        t.endValue,
        t.easeType,
        t.period
    }
    return new(AtomAnimRed, unpack(param));
end

AtomAnimLoader.loadAnimGreen = function(self, t, parent)
    local node = self:findNode(parent, t.id);
    local param = {
        node,
        self:incSequence(),
        t.animType,
        t.duration, 
        t.delay,
        t.startValue,
        t.endValue,
        t.easeType,
        t.period
    }
    return new(AtomAnimGreen, unpack(param));
end

AtomAnimLoader.loadAnimBlue = function(self, t, parent)
    local node = self:findNode(parent, t.id);
    local param = {
        node,
        self:incSequence(),
        t.animType,
        t.duration, 
        t.delay,
        t.startValue,
        t.endValue,
        t.easeType,
        t.period
    }
    return new(AtomAnimBlue, unpack(param));
end

AtomAnimLoader.loadAnimColorSolid = function(self, t, parent)
    local node = self:findNode(parent, t.id);
    return new(AtomAnimColorSolid, node, t.delay, t.colorR, t.colorG, t.colorB);
end

AtomAnimLoader.loadAnimEllipse = function(self, t, parent)
    local node = self:findNode(parent, t.id);
    local param = {
        node,
        self:incSequence(),
        t.animType,
        t.duration, 
        t.delay,
        t.centerX,
        t.centerY,
        t.axisX,
        t.axisY,
        t.startAngle,
        t.endAngle
    }
    return new(AtomAnimEllipse, unpack(param));
end

AtomAnimLoader.loadAnimEllipseX = function(self, t, parent)
    local node = self:findNode(parent, t.id);
    local param = {
        node,
        self:incSequence(),
        t.animType,
        t.duration, 
        t.delay,
        t.center,
        t.axis,
        t.startAngle,
        t.endAngle
    }
    return new(AtomAnimEllipseX, unpack(param));
end

AtomAnimLoader.loadAnimEllipseY = function(self, t, parent)
    local node = self:findNode(parent, t.id);
    local param = {
        node,
        self:incSequence(),
        t.animType,
        t.duration, 
        t.delay,
        t.center,
        t.axis,
        t.startAngle,
        t.endAngle
    }
    return new(AtomAnimEllipseY, unpack(param));
end

AtomAnimLoader.loadAnimFrame = function(self, t, parent)
    local node = self:findNode(parent, t.id)
    local param = {
        node,
        self:incSequence(),
        t.animType,
        t.duration,
        t.delay,
        t.num
    }
    return new(AtomAnimFrame, unpack(param));
end

AtomAnimLoader.loadAnimFrameSolid = function(self, t, parent)
    local node = self:findNode(parent, t.id);
    return new(AtomAnimFrameSolid, node, t.delay, t.iterator);
end

AtomAnimLoader.loadAnimJump = function(self, t, parent)
    local node = self:findNode(parent, t.id);
    local param = {
        node,
        self:incSequence(),
        t.animType,
        t.duration, 
        t.delay,
        t.startValueX,
        t.endValueX,
        t.startValueY,
        t.endValueY,
        t.timesX,
        t.timesY,
        t.jumpX,
        t.jumpY
    }
    return new(AtomAnimJump, unpack(param));
end

AtomAnimLoader.loadAnimRotate = function(self, t, parent)
    local node = self:findNode(parent, t.id);
    local param = {
        node,
        self:incSequence(),
        t.animType,
        t.duration, 
        t.delay,
        t.startValue,
        t.endValue,
        t.centerType,
        t.centerX,
        t.centerY,
        t.easeType,
        t.period
    }
    return new(AtomAnimRotate, unpack(param));
end

AtomAnimLoader.loadAnimRotateSolid = function(self, t, parent)
    local node = self:findNode(parent, t.id);
    local param = {
       node,
       t.delay,
       self:incSequence(),
       t.angleValue,
       t.centerType,
       t.centerX,
       t.centerY 
    }
    return new(AtomAnimRotateSolid, unpack(param));
end

AtomAnimLoader.loadAnimScale = function(self, t, parent)
    local node = self:findNode(parent, t.id);
    local param = {
        node,
        self:incSequence(),
        t.animType,
        t.duration, 
        t.delay,
        t.startValueX,
        t.endValueX,
        t.startValueY,
        t.endValueY,
        t.centerType,
        t.centerX,
        t.centerY,
        t.easeType,
        t.period
    }
    return new(AtomAnimScale, unpack(param));
end

AtomAnimLoader.loadAnimScaleX = function(self, t, parent)
    local node = self:findNode(parent, t.id);
    local param = {
        node,
        self:incSequence(),
        t.animType,
        t.duration, 
        t.delay,
        t.startValue,
        t.endValue,
        t.centerType,
        t.centerX,
        t.centerY,
        t.easeType,
        t.period
    }
    return new(AtomAnimScaleX, unpack(param));
end

AtomAnimLoader.loadAnimScaleY = function(self, t, parent)
    local node = self:findNode(parent, t.id);
    local param = {
        node,
        self:incSequence(),
        t.animType,
        t.duration, 
        t.delay,
        t.startValue,
        t.endValue,
        t.centerType,
        t.centerX,
        t.centerY,
        t.easeType,
        t.period
    }
    return new(AtomAnimScaleY, unpack(param));
end

AtomAnimLoader.loadAnimScaleSolid = function(self, t, parent)
    local node = self:findNode(parent, t.id);
    local param = {
        node,
        t.delay,
        self:incSequence(), 
        t.valueX,
        t.valueY,
        t.centerType,
        t.centerX,
        t.centerY
    }
    return new(AtomAnimScaleSolid, unpack(param));
end

AtomAnimLoader.loadAnimTranslate = function(self, t, parent)
    local node = self:findNode(parent, t.id);
    local param = {
        node,
        self:incSequence(),
        t.animType,
        t.duration, 
        t.delay,
        t.startValueX,
        t.endValueX,
        t.startValueY,
        t.endValueY,
        t.easeType,
        t.period
    }
    return new(AtomAnimTranslate, unpack(param));
end

AtomAnimLoader.loadAnimTranslateX = function(self, t, parent)
    local node = self:findNode(parent, t.id);
    local param = {
        node,
        self:incSequence(),
        t.animType,
        t.duration, 
        t.delay,
        t.startValue,
        t.endValue,
        t.easeType,
        t.period
    }
    return new(AtomAnimTranslateX, unpack(param));
end

AtomAnimLoader.loadAnimTranslateY = function(self, t, parent)
    local node = self:findNode(parent, t.id);
    local param = {
        node,
        self:incSequence(),
        t.animType,
        t.duration, 
        t.delay,
        t.startValue,
        t.endValue,
        t.easeType,
        t.period
    }
    return new(AtomAnimTranslateY, unpack(param));
end

--[Comment]
--设置起始位置
AtomAnimLoader.loadAnimPosSolid = function(self, t, parent)
    local node = self:findNode(parent, t.id)
    return new(AtomAnimPosSolid, node, t.delay, t.posX, t.posY);
end

--[Comment]
--设置平移增量
AtomAnimLoader.loadAnimTranslateSolid = function(self, t, parent)
    local node = self:findNode(parent, t.id)
    return new(AtomAnimTranslateSolid, node, t.delay, self:incSequence(), t.tranX, t.tranY);
end

AtomAnimLoader.loadAnimFuncMap = {
    ["AtomAnimAlpha"]               = AtomAnimLoader.loadAnimAlpha,
    ["AtomAnimAlphaSolid"]          = AtomAnimLoader.loadAnimAlphaSolid,
    ["AtomAnimBezier"]              = AtomAnimLoader.loadAnimBezier,
    ["AtomAnimBezierX"]             = AtomAnimLoader.loadAnimBezierX,
    ["AtomAnimBezierY"]             = AtomAnimLoader.loadAnimBezierY,
    ["AtomAnimColor"]               = AtomAnimLoader.loadAnimColor,
    ["AtomAnimRed"]                 = AtomAnimLoader.loadAnimRed,
    ["AtomAnimGreen"]               = AtomAnimLoader.loadAnimGreen,
    ["AtomAnimBlue"]                = AtomAnimLoader.loadAnimBlue,
    ["AtomAnimColorSolid"]          = AtomAnimLoader.loadAnimColorSolid,
    ["AtomAnimEllipse"]             = AtomAnimLoader.loadAnimEllipse,
    ["AtomAnimEllipseX"]            = AtomAnimLoader.loadAnimEllipseX,
    ["AtomAnimEllipseY"]            = AtomAnimLoader.loadAnimEllipseY,
    ["AtomAnimFrame"]               = AtomAnimLoader.loadAnimFrame,
    ["AtomAnimFrameSolid"]          = AtomAnimLoader.loadAnimFrameSolid,
    ["AtomAnimJump"]                = AtomAnimLoader.loadAnimJump,
    ["AtomAnimRotate"]              = AtomAnimLoader.loadAnimRotate,
    ["AtomAnimRotateSolid"]         = AtomAnimLoader.loadAnimRotateSolid,
    ["AtomAnimScale"]               = AtomAnimLoader.loadAnimScale,
    ["AtomAnimScaleX"]              = AtomAnimLoader.loadAnimScaleX,
    ["AtomAnimScaleY"]              = AtomAnimLoader.loadAnimScaleY,
    ["AtomAnimScaleSolid"]          = AtomAnimLoader.loadAnimScaleSolid,
    ["AtomAnimTranslate"]           = AtomAnimLoader.loadAnimTranslate,
    ["AtomAnimTranslateX"]          = AtomAnimLoader.loadAnimTranslateX,
    ["AtomAnimTranslateY"]          = AtomAnimLoader.loadAnimTranslateY,
    ["AtomAnimTranslateSolid"]      = AtomAnimLoader.loadAnimTranslateSolid,
    ["AtomAnimPosSolid"]            = AtomAnimLoader.loadAnimPosSolid
}