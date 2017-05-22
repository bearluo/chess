require("atomAnim/atomAnimLoader")
require("atomAnim/atomAnimUtils")

--region atomAnimManager.lua
--Date   : 2015/3/12
--这个用于播放动画编辑器生成的动画文件
AtomAnimManager = class()

AtomAnimManager.instance = nil

AtomAnimManager.getInstance = function()
    if not AtomAnimManager.instance then
        AtomAnimManager.instance = new(AtomAnimManager)
    end
    return AtomAnimManager.instance
end

AtomAnimManager.releaseInstance = function()
    if AtomAnimManager.instance then
        delete(AtomAnimManager.instance)
        AtomAnimManager.instance = nil
    end
end

AtomAnimManager.ctor = function(self)
end

AtomAnimManager.dtor = function(self)
end


--[Comment]
--file : 路径; not nil
--parent : 父亲节点 nil
--x : 播放x坐标; nil
--y : 播放y坐标; nil
--autoRelease ： 是否自动释放 默认为true，如果为false需要手动释放动画
--return AtomAnimNode
AtomAnimManager.playAnim = function(self, luaPath, parent, x, y, autoRelease)
    local anim = nil;
    if AtomAnimUtils.checkPath(luaPath) ~= ATOM_ANIM_PATH_ERROR then
        if require(luaPath) then 
            local name = AtomAnimUtils.getClassName(luaPath)
            anim = AtomAnimLoader:loadFile(luaPath,name);   --anim的类型为AtomAnimNode
            anim:setAutoRelease(autoRelease);
            if parent then
                parent:addChild(anim);
            end
            if x and y then
                anim:setPos(x,y);
            end
            --anim:play();
            if anim ~= nil then
                anim.m_startCallBack = nil;
                anim.startCallBack = function(anim)
                    if anim ~= nil then
                        anim:play();
                        if  anim.m_startCallBack ~= nil then
                            anim.m_startCallBack:dtor();
                            anim.m_startCallBack = nil
                        end
                    end
                end
                anim.m_startCallBack = AtomAnimUtils.delayCall(200, anim, anim.startCallBack);
            end
        end
    end
    return anim;
end