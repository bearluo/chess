require("core/anim")
--region atomAnimUtils.lua
--Author : KimWang
--Date   : 2015/3/12
--此文件由[BabeLua]插件自动生成
AtomAnimUtils = {};
--[Comment]
--延迟函数
--delay 延时时间(ms)
--obj func参数
--func 回调函数
--返回AnimDouble实例
AtomAnimUtils.delayCall = function(delay, obj, func, animType)
    local anim = nil;
    if func ~= nil then
        animType = animType or kAnimNormal;
        anim = new(AnimDouble, animType, 0, 0, delay, 0);
        anim:setEvent(obj, func);
    end
    return anim;
end

ATOM_ANIM_PATH_ERROR = -1;    --错误路径
AtomAnimUtils.checkPath = function(path)
    local ret = 0;
    if path == nil or path == "" or 
       type(path) ~= "string"    or 
       type(path) == "number" then
       error("Path can't get!!! Please check it");
       ret = ATOM_ANIM_PATH_ERROR;
    end
    return ret;
end

AtomAnimUtils.genRelativePath = function(luaPath)
    if luaPath == nil then
        return;
    end
    local pathTable = AtomAnimUtils.mysplit(luaPath, "/")
    local index = 0
    for k, v in ipairs(pathTable) do
        if v == "scripts" then
            index = k
            break
        end
    end
    local path = ""
    for i = index + 1, #pathTable do
        if i ~= #pathTable then
            path = path..pathTable[i].."/";
        else
            path = path..pathTable[i];
        end
    end 
    path = AtomAnimUtils.mysplit(path, ".")
    return path[1];
end

AtomAnimUtils.getClassName = function(luaPath)
    local classTable = AtomAnimUtils.mysplit(luaPath, "/")
    local className = classTable[#classTable]
    return className
end

AtomAnimUtils.mysplit =  function(inputstr, sep)
    if sep == nil then
        sep = "%s";
    end
    local t={} ; i=1;
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str;
        i = i + 1;
    end
    return t;
end



--endregion
