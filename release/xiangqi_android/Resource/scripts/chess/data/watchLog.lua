--region WatchLog.lua
--Date 2016.11.2
--观战聊天记录
--endregion

WatchLog = {}

function WatchLog.getInstance()
    if not WatchLog.instance then
        WatchLog.instance = new(WatchLog);
    end
    return WatchLog.instance;
end

function WatchLog.release()
    delete(WatchLog.instance)
    WatchLog.instance = nil
end

function WatchLog.ctor(self)
    self.watch_gift_log = {}
    self.watch_data_cache = {}
    self.data_index = {}
end

function WatchLog.addGiftLog(self,data)
    if not self.watch_gift_log then
        self.watch_gift_log = {}
    end
    if not data then return end
    table.insert(self.watch_gift_log,data)
end

function WatchLog.clearGiftLog(self,data)
    self.watch_gift_log = {}
end

function WatchLog.updataCache(self,data)
    if not data or type(data) ~= "table" then return end
    local key = tostring(data.sendId) .. tostring(data.targetId) .. tostring(data.gift_type)

    local status = 0
    if self.watch_data_cache[key] then
        self.watch_data_cache[key].giftNum = self.watch_data_cache[key].giftNum + data.giftNum
        --更新node里面数量
        status = 1
    else
        table.insert(self.data_index,key)
        self.watch_data_cache[key] = data
        --创建node
        status = 0
    end

    return key, status
end


GiftLog = {}

function GiftLog.getInstance()
    if not GiftLog.instance then
        GiftLog.instance = new(GiftLog);
    end
    return GiftLog.instance;
end

function GiftLog.release()
    delete(GiftLog.instance)
    GiftLog.instance = nil
end

function GiftLog.ctor(self)
    self.user_gift_log = {}
    self.others_gift_log = {}
end

function GiftLog.saveUserGift(self,gift_num,id,gift_type)
    if not id or not gift_type then return end
    local num = gift_num or 0 
    if not self.user_gift_log[id] then
        self.user_gift_log[id] = {}
    end
    if self.user_gift_log[id] then
        local tempNum = self.user_gift_log[id][gift_type .. ""] or 0
        self.user_gift_log[id][gift_type .. ""] = tempNum + num
    else
        self.user_gift_log[id] = {}
        self.user_gift_log[id][gift_type .. ""] = num
    end
end

function GiftLog.getUserGiftNum(self,id)
    if not id then return end
    local log = self.user_gift_log[id] or {}
    local num = 0
    for k,v in pairs(log) do
        if v then
            num = num + tonumber(v)
        end
    end
    return num
end

function GiftLog.deleteUserGift(self)
    self.user_gift_log = {}
end

function GiftLog.saveOtherGift(self,data)
    
end

function GiftLog.deleteOtherGift(self)
    
end