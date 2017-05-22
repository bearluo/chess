-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
require("core/object");
require("core/constants");
require("core/global");

UploadDumpFile = class();
local dUploadUrl = "http://mvusspus01.boyaagame.com/report3.php";
local dDumpPath = "dump";
local dTimeOut = 5000;
local dAppId = 0;
local kUploadDumpFile = "uploadDumpFile";
local kDumpResponse = "uploadDumpFile_response";
local kCommonEvent = "CommonEvent";
local kCode = "code";
local kId = "id";
local kAppId = "appId";
local kFilePath = "filePath";
local kUrl = "url";
local kTimeout = "timeout";

UploadDumpFile.s_objs = CreateTable("k");
UploadDumpFile.request_id = 0;

local function request_destroy(iRequestId)
    local key = getKey(iRequestId);
    dict_delete(key);
end

local function allocId()
    UploadDumpFile.request_id = UploadDumpFile.request_id + 1;
    return UploadDumpFile.request_id;
end

local function getKey(iRequestId)
    return string.format("dumpfile_request_%d", iRequestId or 0);
end

local function getFilePath()
    return sys_get_string(dDumpPath) or "";
end

local function defaultCallBack()
    sys_set_int("delete_dump",0);
end;

UploadDumpFile.getInstance = function()
    if not UploadDumpFile.instance then
        UploadDumpFile.instance = new(UploadDumpFile,6);--象棋 appid 6  引擎部提供
    end
    return UploadDumpFile.instance;
end

UploadDumpFile.ctor = function(self, appid, url, timeout, filePath)
    self.m_requestID = allocId();
    UploadDumpFile.s_objs[self.m_requestID] = self;
    self.m_requestUrl = url or dUploadUrl;
    self.m_filePath = filePath or getFilePath();
    self.m_timeout = timeout or dTimeOut;
    self.m_appId = appid or dAppId;
    self.m_eventCallback = { };
end

--请在wifi网络的情况下调用
UploadDumpFile.execute = function(self, isWifi)
    if not isWifi or System.getPlatform() ~= kPlatformAndroid then
        return;
    end
    if not self.m_appId or self.m_appId == 0 or self.m_filePath == "" then
        return;
    end

    local key = getKey(self.m_requestID);
    dict_set_string(key, kAppId, self.m_appId.."");
    dict_set_string(key, kUrl, self.m_requestUrl.."");
    dict_set_string(key, kFilePath, self.m_filePath.."");
    dict_set_string(key, kTimeout, self.m_timeout.."");
    dict_set_string(kCommonEvent, kCommonEvent, kUploadDumpFile);
    -- 调用方法
    dict_set_int(kUploadDumpFile, kId, self.m_requestID);
    -- 上传id
    call_native(kCommonEvent);
end


UploadDumpFile.setEvent = function(self, obj, func)
    self.m_eventCallback.obj = obj;
    self.m_eventCallback.func = func;
end

UploadDumpFile.dtor = function(self)
    request_destroy(self.m_requestID);
    self.m_requestID = nil;
end


function event_uploadDumpFile_response()
    local requestID = dict_get_int(kDumpResponse, kId, 0);
    local upload = UploadDumpFile.s_objs[requestID];
    --1001：上传成功  1002：上传失败 1003：请求超时 1004：参数错误 1005：响应超时
    upload.m_responseCode = dict_get_int(getKey(requestID), kCode, -1);
    if upload and upload.m_eventCallback.func then
        upload.m_eventCallback.func(upload.m_eventCallback.obj, upload);
    end
    defaultCallBack();
end


property(UploadDumpFile, "m_responseCode", "ResponseCode", true, false);

property(UploadDumpFile, "m_timeout", "Timeout");

property(UploadDumpFile, "m_filePath", "FilePath");

property(UploadDumpFile, "m_requestUrl", "Url");

property(UploadDumpFile, "m_appId", "AppId");

--[[
 local upload = new(UploadDumpFile, 10090);
    upload:setEvent(self,function (self, dump)-- self参数为obj, function 为 func 传进什么obj 回调的时候func的self就会传过来什么
        dict_set_int("upload","responseCode",dump:getResponseCode());
        dict_set_string("upload","filePath",dump:getFilePath());
        dict_set_string("upload","requestID",dump.m_requestID);
        dict_save("upload");
    end);
    upload:excute(true);
--]]

-- endregion

UploadDumpFile.instance = new(UploadDumpFile,6);--象棋 appid 6  引擎部提供
