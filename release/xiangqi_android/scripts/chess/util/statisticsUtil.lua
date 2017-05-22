
require("util/game_cache_data")
StatisticsUtil = class(GameCacheData,false);

StatisticsUtil.KEY_STATISTICS = "statistics";
StatisticsUtil.UploadFailData = nil;
StatisticsUtil.ctor = function(self)
	self.m_dict = new(Dict,"statistics");
	self.m_dict:load();
end

--*登陆人数
--*登陆人次
--*房间登陆人数
--*房间登陆人次
--*大厅掉线人数
--*大厅正常掉线人次
--*大厅超时掉线人次
--*大厅其他异常掉线人次
--*房间掉线人数
--*房间正常掉线人次
--*房间超时掉线人次
--*房间其他异常掉线人次
--*重连人数
--*重连人次
--*房间登陆错误人数
--*房间登陆错误人次
StatisticsUtil.TYPE_LOGIN                               = 1;
StatisticsUtil.TYPE_PLAY                                = 2;
StatisticsUtil.TYPE_NETWORK_ERROR_OFFLINE               = 3;
StatisticsUtil.TYPE_NETWORK_NORMAL_OFFLINE              = 4;
StatisticsUtil.TYPE_LUA_ERROR                           = 5;
function StatisticsUtil.Log (logType,params)
    local log = {};
    log.log_time = os.time();
    log.log_type = logType;
    log.log_data = params;
    local logs = StatisticsUtil.getLogs();
    table.insert(logs,log);
    StatisticsUtil.saveLogs(logs);
end

function StatisticsUtil.getLogs ()
    local jsonStr = StatisticsUtil.log:getString(StatisticsUtil.KEY_STATISTICS,"");
    local logs = json.decode(jsonStr);
    if logs then 
        return logs 
    end
    return {};
end

function StatisticsUtil.saveLogs (logs)
    if logs and type(logs) == "table" then
        StatisticsUtil.log:saveString(StatisticsUtil.KEY_STATISTICS,json.encode(logs));
    end
end

function StatisticsUtil.getUploadData()
    local jsonStr = StatisticsUtil.log:getString(StatisticsUtil.KEY_STATISTICS,"");
    local logs = json.decode(jsonStr);
    if logs and #logs > 0 then 
        StatisticsUtil.log:saveString(StatisticsUtil.KEY_STATISTICS,"");
        StatisticsUtil.UploadFailData = logs;
        return logs;
    end
    return nil;
end

function StatisticsUtil.onUploadFail()
    if StatisticsUtil.UploadFailData ~= nil then
        local logs = StatisticsUtil.getLogs();
        for i,log in pairs(logs) do
            table.insert(StatisticsUtil.UploadFailData,log);
        end
        StatisticsUtil.saveLogs(StatisticsUtil.UploadFailData);
        StatisticsUtil.UploadFailData = nil;
    end
end

StatisticsUtil.log = new(StatisticsUtil);
--StatisticsUtil.Log (StatisticsUtil.TYPE_LOGIN,"");