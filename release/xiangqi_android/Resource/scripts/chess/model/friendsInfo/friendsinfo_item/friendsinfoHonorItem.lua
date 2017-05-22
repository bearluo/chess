-- friendsinfoHonorItem.lua
-- Author: ChaoYuan
-- Date:   2017-03-24
-- Last modification : 2017-03-24
-- Description: 荣誉页面
require(BASE_PATH.."itemScene")
FriendsinfoHonorItem = class(ItemScene,false)
FriendsinfoHonorItem.defaultValue = 
{
    MASTER_RANK = "未入榜",
    MATCH_RANK = "暂无",
    WIN_TIME = "-/-",
    CHARM_RANK = "未入榜",
    FANS_NUM = "暂无",
    ATTENTION_NUM = "暂无",
    OTHER_VALUE = "-"
}

FriendsinfoHonorItem.s_controls = {
    master_rank_tx = 1;            --大师榜排名
    match_rank_tx = 2;             --赏金赛最佳排名
    win_time_tx = 3;               --获奖次数
    charm_rank_tx = 4;             --魅力榜排名
    fans_rank_tx = 5;              --粉丝数
    attention_rank_tx = 6;         --关注数
    charm_value_tx = 7;            --魅力值
    gift_num_tx = 8;               --礼物数

    rose_num_tx = 9;               --玫瑰数
    egg_num_tx = 10;               --鸡蛋数
    kiss_num_tx = 11;              --飞吻数
    match_ticket_num_tx = 12;      --比赛券数
}

FriendsinfoHonorItem.ctor = function (self,viewConfig,controller,scene,view)
    super(self, viewConfig, controller, true, view, scene)
    self.ctrls = FriendsinfoHonorItem.s_controls
    self:initView()
    self:initDafaultViewData()           
end

FriendsinfoHonorItem.dtor = function (self)

end

FriendsinfoHonorItem.initView = function (self)
    --获得view的对象
    self.master_rank_tx =self:findViewById(self.ctrls.master_rank_tx)
    self.match_rank_tx =self:findViewById(self.ctrls.match_rank_tx)
    self.win_time_tx =self:findViewById(self.ctrls.win_time_tx)
    self.charm_rank_tx =self:findViewById(self.ctrls.charm_rank_tx)
    self.fans_rank_tx =self:findViewById(self.ctrls.fans_rank_tx)
    self.attention_rank_tx =self:findViewById(self.ctrls.attention_rank_tx)
    self.charm_value_tx =self:findViewById(self.ctrls.charm_value_tx)
    self.gift_num_tx =self:findViewById(self.ctrls.gift_num_tx)
    self.rose_num_tx =self:findViewById(self.ctrls.rose_num_tx)
    self.egg_num_tx =self:findViewById(self.ctrls.egg_num_tx)
    self.kiss_num_tx =self:findViewById(self.ctrls.kiss_num_tx)
    self.match_ticket_num_tx =self:findViewById(self.ctrls.match_ticket_num_tx)

end

FriendsinfoHonorItem.initDafaultViewData = function (self)
    self:setMasterRank()
    self:setMatchRank()
    self:setWinTime()
    self:setCharmRank()
    self:setFansRank()
    self:setAttentionRank()
    self:setCharmValue()

    self:setAllGiftValue()
end

FriendsinfoHonorItem.updateViewData = function (self, data)
    local hdata = data
    if hdata==nil then 
        return 
    end
    self:setMasterRank(hdata.master_rank)
    self:setMatchRank(hdata.match_rank)
    self:setWinTime(hdata.win_time,hdata.match_num)
    self:setCharmRank(hdata.rank)
    self:setFansRank(hdata.fans_num)
    self:setAttentionRank(hdata.attention_num)
    self:setCharmValue(hdata.charm_value)

    self:setAllGiftValue(hdata.gift)
end

------------------------设置view的数据---------------------------
FriendsinfoHonorItem.setMasterRank = function (self , s)
    local ss = tonumber(s) or 0 
    if ss == 0 then 
        ss = FriendsinfoHonorItem.defaultValue.MASTER_RANK
    else
        ss = ss.."名"
    end
    self.master_rank_tx:setText(ss)
end

FriendsinfoHonorItem.setMatchRank = function (self , s)
    local ss = tonumber(s) or 0
    if ss == 0 then 
        ss = FriendsinfoHonorItem.defaultValue.MATCH_RANK
    else
        ss = "第"..ss.."名"
    end
    self.match_rank_tx:setText(ss)
end

FriendsinfoHonorItem.setWinTime = function (self,s , s_all)
    local ss
    if s ~= nil and s_all ~=nil then 
        ss = s.."/"..s_all
    else
        ss = FriendsinfoHonorItem.defaultValue.WIN_TIME
    end
    self.win_time_tx:setText(ss)
end

FriendsinfoHonorItem.setCharmRank = function (self , s)
    local ss = tonumber(s) or 0
    if ss == 0 then 
        ss = FriendsinfoHonorItem.defaultValue.CHARM_RANK
    else
        ss = ss.."名"
    end
    self.charm_rank_tx:setText(ss)
end

--粉丝数量
FriendsinfoHonorItem.setFansRank = function (self,s)
    local ss = tonumber(s) or "暂无"
    self.fans_rank_tx:setText(ss)
end

--关注数
FriendsinfoHonorItem.setAttentionRank = function (self,s)
    local ss = tonumber(s) or "暂无"
    self.attention_rank_tx:setText(ss)
end

FriendsinfoHonorItem.setCharmValue = function (self, num)
    local n = tonumber(num) or "-"
    self.charm_value_tx:setText(n)
end

FriendsinfoHonorItem.setGiftNum = function (self , num)
    local n = tonumber(num) or "-"
    self.gift_num_tx:setText(n)
end

require(MODEL_PATH.."giftModule/giftModuleConstant")

FriendsinfoHonorItem.setAllGiftValue = function (self,giftData)
    local gift = giftData or {}
    local egg_n =  0
    local kiss_n = 0
    local rose_n = 0
    local match_ticket_n = 0
    for _,val in pairs(gift) do
        if val["gift_id"] == "17" then 
            egg_n = tonumber(val["gift_num"]) or 0
        elseif val["gift_id"] == "18" then 
            kiss_n = tonumber(val["gift_num"]) or 0
        elseif val["gift_id"] == "16" then 
            rose_n = tonumber(val["gift_num"]) or 0
        elseif val["gift_id"] == "19" then 
            match_ticket_n = tonumber(val["gift_num"]) or 0
        end
    end
    
    local total_n = egg_n+kiss_n + rose_n + match_ticket_n
    self.egg_num_tx:setText(egg_n )
    self.kiss_num_tx:setText(kiss_n )
    self.rose_num_tx:setText(rose_n)
    self.match_ticket_num_tx:setText(match_ticket_n)
    self:setGiftNum(total_n )
end


FriendsinfoHonorItem.s_controlConfig = {
    [FriendsinfoHonorItem.s_controls.master_rank_tx] = {"rank_node","master_rank_tx"};
    [FriendsinfoHonorItem.s_controls.match_rank_tx] = {"rank_node","match_rank_tx"};
    [FriendsinfoHonorItem.s_controls.win_time_tx] = {"rank_node","win_time_tx"};

    [FriendsinfoHonorItem.s_controls.charm_rank_tx] = {"popularity_node","charm_rank_tx"};
    [FriendsinfoHonorItem.s_controls.fans_rank_tx] = {"popularity_node","fans_rank_tx"};
    [FriendsinfoHonorItem.s_controls.attention_rank_tx] = {"popularity_node","attention_rank_tx"};

    [FriendsinfoHonorItem.s_controls.charm_value_tx] = {"charm_node","charm_value_tx"};
    [FriendsinfoHonorItem.s_controls.gift_num_tx] = {"charm_node","gift_num_tx"};

    [FriendsinfoHonorItem.s_controls.rose_num_tx] = {"flower_node","rose_img","rose_num_tx"};
    [FriendsinfoHonorItem.s_controls.egg_num_tx] = {"flower_node","egg_img","egg_num_tx"};
    [FriendsinfoHonorItem.s_controls.kiss_num_tx] = {"flower_node","kiss_img","kiss_num_tx"};
    [FriendsinfoHonorItem.s_controls.match_ticket_num_tx] = {"flower_node","match_ticket_img","match_ticket_num_tx"};
}