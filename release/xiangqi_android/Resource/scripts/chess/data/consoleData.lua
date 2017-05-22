--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/24
require("util/game_cache_data")
ConsoleData = class(GameCacheData,false)
ConsoleData.DEFAULT_OPEN_LEVEL = 3
ConsoleData.CONFIG_VERSION = "config_version"
ConsoleData.CONFIG = "config"
ConsoleData.TOTAL_STAR_NUM_ = "total_star_num_"
-- 单机任务类型
ConsoleData.TASK_TYPE_WIN = 0 -- 赢棋
ConsoleData.TASK_TYPE_EAT = 1 -- 吃子
ConsoleData.TASK_TYPE_PROTECT = 2 -- 保子

ConsoleData.ctor = function(self)
	self.m_dict = new(Dict,"console_data")
	self.m_dict:load()
end

function ConsoleData:syncNativeOldData(pass_progress)
    pass_progress = tonumber(pass_progress) or ConsoleData.DEFAULT_OPEN_LEVEL
    -- 1.9.10以前单机保存的进度（兼容）
    local old_native_progress = GameCacheData.getInstance():getInt(GameCacheData.CONSOLE_MAX_OPENLEVEL, ConsoleData.DEFAULT_OPEN_LEVEL)
    -- 1.9.10以后单机进度包括uid，非联网uid = 0
    local uid = UserInfo.getInstance():getOfflineUid()
    local new_native_progress = self:getMaxOpenLevel()
    -- 同步离线记录
    local new_native_offline_progress = GameCacheData.getInstance():getInt(GameCacheData.CONSOLE_MAX_OPENLEVEL.."0", ConsoleData.DEFAULT_OPEN_LEVEL)
    if new_native_offline_progress > new_native_progress then
        new_native_progress = new_native_offline_progress
    end
    local native_progress = ConsoleData.DEFAULT_OPEN_LEVEL
    if old_native_progress >= new_native_progress then
        native_progress = old_native_progress
    else
        native_progress = new_native_progress
    end

    -- 如果本地数据没超过上限
    -- 过的关卡+1 = 解锁关卡
    local max_open_level = native_progress
    if native_progress < COSOLE_MODEL_GATE_NUM then 
        if pass_progress + 1 >= native_progress then
            max_open_level = pass_progress+1
        else
            self:uploadConsoleProgress(native_progress - 1)
        end
    end
   self:setMaxOpenLevel(max_open_level)
end

function ConsoleData:sendSyncPhpOldData()
    if self.mIsSyncOldDataing then return end
    self.mIsSyncOldDataing = true
    HttpModule.getInstance():execute2(HttpModule.s_cmds.getConsoleProgress,function(isSuccess,resultStr)
        self.mIsSyncOldDataing = false
        if isSuccess then
            local jsonData = json.decode(resultStr)
            local errorMsg = jsonData.error
            if errorMsg then
                return
            end
            local data = jsonData.data
            self:syncPhpOldData(data)
        end
    end)
end

function ConsoleData:syncPhpOldData(data)
    if not data or type(data) ~= "table" then return end
    local progress = data.progress["1"]
    local starNum = tonumber(data.starNum) or 0
    local zhanji = self:getZhanJi()
    if type(data.combat_gains) == "table" then 
        for index = 1 , COSOLE_MODEL_GATE_NUM do 
            if not zhanji[index] then zhanji[index] = {} end
            local item = data.combat_gains[index ..""] or {}
            local wintimes = tonumber(item.wintimes) or 0
            local losetimes = tonumber(item.losetimes) or 0
            local star = item.star or {}
            if not zhanji[index].wintimes or zhanji[index].wintimes <= wintimes then
                zhanji[index].wintimes = wintimes
            end
            if not zhanji[index].losetimes or zhanji[index].losetimes <= losetimes then
                zhanji[index].losetimes = losetimes
            end
            if not zhanji[index].star or #zhanji[index].star <= #star then
                zhanji[index].star = star
            end
        end
        self:setZhanJi(zhanji)
    end
    if starNum > self:getTotalStarNum() then
        self:setTotalStarNum(starNum)
    end
    self:syncNativeOldData(progress)
end 

--[Comment]
-- 总星星数
function ConsoleData:getTotalStarNum()
    return self:getInt(ConsoleData.TOTAL_STAR_NUM_ .. UserInfo.getInstance():getOfflineUid(),0)
end

function ConsoleData:setTotalStarNum(num)
    num = tonumber(num) or 0
    self:saveInt(ConsoleData.TOTAL_STAR_NUM_ .. UserInfo.getInstance():getOfflineUid(),num)
end
--[Comment]
-- 设置玩家准备玩的关卡
function ConsoleData:setWillPlayLevel(level)
    local tmp = tonumber(level)
    if tmp and tmp > 0 and tmp <= COSOLE_MODEL_GATE_NUM then
        self.mWillPlayLevel = tmp
    end
end
--[Comment]
-- 获得玩家准备玩的关卡
function ConsoleData:getWillPlayLevel()
    return self.mWillPlayLevel or ConsoleData.getInstance():getMaxStarOpenLevel()
end

--[Comment]
-- 获得战绩
function ConsoleData:getZhanJiByLevel(level)
    return self:getZhanJi()[level]
end

--[Comment]
-- 获得战绩
function ConsoleData:getZhanJi()
    if not self.mZhanJi then 
        local jsonStr = GameCacheData.getInstance():getString(GameCacheData.CONSOLE_ZHANJI..UserInfo.getInstance():getOfflineUid(), "")
        self.mZhanJi = json.decode(jsonStr) or {}
    end
    return self.mZhanJi
end
--[Comment]
-- 设置战绩
function ConsoleData:setZhanJi(zhanji)
    if type(zhanji) ~= "table" then return end 
    self.mZhanJi = zhanji
    GameCacheData.getInstance():saveString(GameCacheData.CONSOLE_ZHANJI..UserInfo.getInstance():getOfflineUid(),json.encode(self.mZhanJi))
end
--[Comment]
-- 老版本关卡过关数据
-- 新版本还是要上传过关数据 关卡解锁改为星星解锁
function ConsoleData:uploadConsoleProgress(progress)
    local post_data = {}
    post_data.progress = {}
    post_data.progress["1"] = tonumber(progress) or 1   
    HttpModule.getInstance():execute2(HttpModule.s_cmds.uploadConsoleProgress,post_data,function(isSuccess,resultStr)
    end)
end
--[Comment]
-- 老版本最高解锁关卡
function ConsoleData:setMaxOpenLevel(maxLevel)
    self.mMaxLevel = tonumber(maxLevel) or self.mMaxLevel or ConsoleData.DEFAULT_OPEN_LEVEL
    GameCacheData.getInstance():saveInt(GameCacheData.CONSOLE_MAX_OPENLEVEL..UserInfo.getInstance():getOfflineUid(),self.mMaxLevel)
end
--[Comment]
-- 获取老版本最高解锁关卡
function ConsoleData:getMaxOpenLevel()
    if not self.mMaxLevel then
        self.mMaxLevel = GameCacheData.getInstance():getInt(GameCacheData.CONSOLE_MAX_OPENLEVEL..UserInfo.getInstance():getOfflineUid(),ConsoleData.DEFAULT_OPEN_LEVEL)
    end
    return self.mMaxLevel
end

--[Comment]
-- 获取新版本最高解锁关卡
-- 最小第三关
function ConsoleData:getMaxStarOpenLevel()
    local totalNum = self:getTotalStarNum()
    local config = self:getConfig()
    local level = ConsoleData.DEFAULT_OPEN_LEVEL
    for index = level+1,  COSOLE_MODEL_GATE_NUM do
        local data = config[index .. ""]
        if not data then break end
        if data.star > totalNum then break end
        level = index
    end
    return level
end
-- 设置免费大炮状态
function ConsoleData:setFreeGunStatus(freeGun)
    self.mFreeGun = tonumber(freeGun)
end
function ConsoleData:isHasFreeGun()
    return self.mFreeGun == 0
end
--[Comment]
-- 获取单机配置版本号
function ConsoleData:getConfigVersion()
    return self:getInt(ConsoleData.CONFIG_VERSION,0)
end
--[Comment]
-- 更新单机配置
function ConsoleData:updateConfig(version,config)
    if not version or type(config) ~= "table" then return end
    self:saveInt(ConsoleData.CONFIG_VERSION,tonumber(version) or 0)
    self:saveString(ConsoleData.CONFIG,json.encode(config))
    self.mConfig = config
end
--[Comment]
-- 获得单机配置
function ConsoleData:getConfig()
    if not self.mConfig then
        local jsonStr = self:getString(ConsoleData.CONFIG,"")
        self.mConfig = json.decode(jsonStr)
    end
    return self.mConfig or {}
end

--[Comment]
-- 获得对应单机等级配置
function ConsoleData:getConfigByLevel(level)
    if not tonumber(level) then return end
    local config = self:getConfig()
    return config[level .. ""]
end

--[Comment]
-- 用户数据不一致的时候会重置
ConsoleData.getInstance = function()

    if ConsoleData.s_init_uid ~= UserInfo.getInstance():getOfflineUid() then
        ConsoleData.releaseInstance()
	    ConsoleData.s_init_uid = UserInfo.getInstance():getOfflineUid()
    end

    if not ConsoleData.s_console_instance then
		ConsoleData.s_console_instance = new(ConsoleData)
    end
	return ConsoleData.s_console_instance
end

ConsoleData.releaseInstance = function()
    delete(ConsoleData.s_console_instance)
    ConsoleData.s_console_instance = nil
end

ConsoleData.ChangeTonumber = function(data)
    if data then
        function analyze(t)
            for i,k in pairs(t) do
                if type(k) == "table" then
                    analyze(k)
                else
                    local a = tonumber(k)
                    if a then
                        t[i] = a
                    end
                end
            end
        end
        analyze(data)
    end
    return data
end
