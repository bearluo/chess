
require("util/game_cache_data")
NoviceBootData = class(GameCacheData,false);

NoviceBootData.ctor = function(self)
	self.m_dict = new(Dict,"endgate_data");
	self.m_dict:load();
end


NoviceBootProxy = class()
NoviceBootProxy.s_constant = {
    ONLINE_TREASURE_BOX         = "online_treasure_box";        --在线宝箱
    CHESS_MANUAL                = "chess_manual";               --棋谱
    HALL_CHAT                   = "hall_chat";                  --大厅聊天
    ONLINE_ROOM_RESULT_FOLLOW   = "online_room_result_follow";  --联网结算关注提示
    ENDGATE_TITLE               = "endgate_title";              --残局标题提示
    ENDGATE_TITLE_SELECT        = "endgate_title_select";       --残局大关卡选择提示
    FOLLOW_EACH_OTHER = "follow_each_other";                    --提示互相关注成为好友
    RECEIVE_REWARD = "receive_reward";                          --提示用户领取奖励 
}

function NoviceBootProxy.getInstance()
    if not NoviceBootProxy.s_instance then
        NoviceBootProxy.s_instance = new(NoviceBootProxy)
    end
    return NoviceBootProxy.s_instance
end

function NoviceBootProxy:ctor()
    self.mNoviceBootData = new(NoviceBootData)
    self.mGuideTipTab = {}
end

function NoviceBootProxy:isFirstShow(key)
    if not key then return false end
    local uid = UserInfo.getInstance():getUid()
    local time = self.mNoviceBootData:getInt(key .. uid,0)
    return time <= 0
end

function NoviceBootProxy:setGuideTipViewShowTime(key,time)
    if not key then return end
    time = tonumber(time) or os.time()
    local uid = UserInfo.getInstance():getUid()
    self.mNoviceBootData:saveInt(key .. uid,time)
end

--时间纪录清零
function NoviceBootProxy:clearGuideTipViewShowTime(key)
    if not key then return end
    local uid = UserInfo.getInstance():getUid()
    self.mNoviceBootData:saveInt(key .. uid,0)
end 

function NoviceBootProxy:isGuideTipViewNil(key)
    return self.mGuideTipTab[key] == nil
end

require("chess/prefabs/guideTip")
function NoviceBootProxy:getGuideTipView(key)
    if self.mGuideTipTab[key] then return self.mGuideTipTab[key] end
    local guideTip = new(GuideTip)
    guideTip:setReleaseCallBack(self,self.onReleaseGuideTip)
    self.mGuideTipTab[key] = guideTip
    return guideTip
end

function NoviceBootProxy:onReleaseGuideTip(obj)
    for index,value in pairs(self.mGuideTipTab) do
        if value == obj then
            self.mGuideTipTab[index] = nil
        end
    end
end

function NoviceBootProxy:releaseGuideTip(key)
    if self.mGuideTipTab[key] then
        self.mGuideTipTab[key]:setReleaseCallBack(nil,nil)
        delete(self.mGuideTipTab[key])
        self.mGuideTipTab[key] = nil
    end
end
