--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
CacheImageManager = class();

-- 这次启动下载过的图片 可以直接使用
CacheImageManager.cacheImage = {};

CacheImageManager.listeners = {};
CacheImageManager.isRegister = false;

-- what 唯一图片标识 用图片md5_string(url) 
CacheImageManager.registered = function(view,url)
    if kPlatform == kPlatformIOS then
        -- if not CacheImageManager.isRegister then
        --     Log.i("----------------CacheImageManager.onGetDownloadImage--------callback0");
        --     EventDispatcher.getInstance():register(Event.Call,CacheImageManager,CacheImageManager.onNativeCallDone);
        --     CacheImageManager.isRegister = true;
        -- end
    else
        if not CacheImageManager.isRegister then
            EventDispatcher.getInstance():register(Event.Call,CacheImageManager,CacheImageManager.onNativeCallDone);
            CacheImageManager.isRegister = true;
        end
    end;
    local key = md5_string(url);
    if not key then return end;
    if not CacheImageManager.listeners[key] then
        CacheImageManager.listeners[key] = {};
    end
    table.insert(CacheImageManager.listeners[key],view);
--    Log.i("aaaaaaaaaaaaa");
--    -- 如果已经有图了 就不用注册了
----    if CacheImageManager.cacheImage[key] then
----        Log.i("bbbbbbbbbbbbbbbbb");
----        if view and view.setFile then
----            view:setFile(key..".png");
----            return ;
----        end
----    end
    Log.i("CacheImageManager key;  "..key);
    Log.i("CacheImageManager url;  "..(url or "nil"));
    local info = {};
    info.ImageUrl = url;
    info.ImageName = key;
    info.what = "CacheImageManager_1.0";
    dict_set_string(kCacheImageManager,kCacheImageManager..kparmPostfix,json.encode(info));
	call_native(kCacheImageManager);
    return #CacheImageManager.listeners[key];
end

CacheImageManager.unregistered = function(url,tag)
    local key = md5_string(url);
    if CacheImageManager.listeners[key] and CacheImageManager.listeners[key][tag] then
        CacheImageManager.listeners[key][tag] = nil;
    end
end

CacheImageManager.callBackEvent = function(imageName,what)
    if not imageName and what ~= "CacheImageManager_1.0"  then return end ;
    Log.i("CacheImageManager key;  "..imageName);
    local key = string.sub(imageName,1,-5);
    CacheImageManager.cacheImage[key] = imageName;
    if CacheImageManager.listeners[key] then
        for i,v in pairs(CacheImageManager.listeners[key]) do
            if v and v.setUrlFile then
                v:setUrlFile(imageName);
            end
        end
        CacheImageManager.listeners[key] = {};
    end
end

CacheImageManager.onGetDownloadImage = function(self,flag,data)
    if not flag then 
        --下载失败
    end
    local info = json.analyzeJsonNode(data);
    for i,v in pairs(info) do
        Log.i(v);
    end
    CacheImageManager.callBackEvent(info.ImageName,info.what);
end

CacheImageManager.onNativeCallDone = function(self ,param , ...)
	if param == kCacheImageManager then
        CacheImageManager.onGetDownloadImage(self,...);
    end
end
if kPlatform == kPlatformIOS then
    EventDispatcher.getInstance():register(Event.Call,CacheImageManager,CacheImageManager.onNativeCallDone);
end;
--endregion
