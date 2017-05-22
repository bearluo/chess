--region dailyTaskData.lua
--Author : FordFan
--createDate   : 2016/4/21
--每日任务数据和管理类


--[[
    每日任务数据类
--]]

DailyTaskData = class()

DailyTaskData.prizeType = 
{
    GOLD = "money";     --金币
    SOUL = "soul";      --棋魂
    PROP = "prop";      --道具
}

DailyTaskData.propType = 
{
    UNDO = "2";      --悔棋
    TIP = "3";       --提示
    REVIVE = "4";    --起死回生
    
}
function DailyTaskData.getInstance()
    if not DailyTaskData.s_instance then
		DailyTaskData.s_instance = new(DailyTaskData);
	end
	return DailyTaskData.s_instance;

end

function DailyTaskData.releaseInstance()
	delete(DailyTaskData.s_instance);
	DailyTaskData.s_instance = nil;
end

function DailyTaskData:ctor()
    self.m_daily_task_data = nil;
    self.m_show_sign = false
    self.need_updata_daily_sign = false
end

function DailyTaskData.setUpdataDailySignStatus(self,ret)
    self.need_updata_daily_sign = ret
end

function DailyTaskData.getUpdataDailySignStatus(self)
    return self.need_updata_daily_sign
end

--保存每日任务数据
function DailyTaskData:setDailyTaskData(data)
    self.m_daily_task_data = data;
end

function DailyTaskData:getDailyTaskData()
    return self.m_daily_task_data;
end

--保存成长任务数据
function DailyTaskData:setGrowTaskData(data)
    self.m_grow_task_data = data;
end

function DailyTaskData:getGrowTaskData()
    return self.m_grow_task_data;
end

--保存更新的每日任务id
function DailyTaskData:setUpdateTaskId(taskId)
    self.m_updata_id= taskId;
end

function DailyTaskData:getUpdateTaskId()
    return self.m_updata_id or -1;
end

function DailyTaskData:setSignShowStatus(ret)
    self.m_show_sign = ret;
end

function DailyTaskData:getSignShowStatus()
    return self.m_show_sign;
end

function DailyTaskData.setDailySignData(self,data)
    self.daily_sign_data = data
end

function DailyTaskData.getDailySignData(self)
    return self.daily_sign_data
end
--[Comment]
-- 是否存在已完成的每日任务未领取
--return:  true-存在   false-不存在
function DailyTaskData:getCompleteStatus()
    local task = self:getDailyTaskData();
    if task then
        for k,v in pairs(task) do
            if tonumber(v.status) == 1 then
                return true;
            end
        end
    end
    return false;
end

--[Comment]
-- 是否存在已完成的成长任务未领取
--return:  true-存在   false-不存在
function DailyTaskData:getGrowTaskCompleteStatus()
    local task = self:getGrowTaskData();
    if task then
        for k,v in pairs(task) do
            if tonumber(v.status) == 1 then
                return true;
            end
        end
    end
    return false;
end
--[[
    每日任务管理类
--]]
require("animation/diceAccountDropMoney");
DailyTaskManager = class()

DailyTaskManager.s_marked = 
{
	RemoveMarked = 1,
};


--[[
    获得类管理实例
--]]
function DailyTaskManager.getInstance()
    if not DailyTaskManager.s_instance then
		DailyTaskManager.s_instance = new(DailyTaskManager);
	end
	return DailyTaskManager.s_instance;
end

function DailyTaskManager.releaseInstance()
	delete(DailyTaskManager.s_instance);
	DailyTaskManager.s_instance = nil;
end

function DailyTaskManager:ctor()
    self.m_dailyListener = {};
--    self.m_tmpDailyListener = {};
    --注册响应事件
    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
end

function DailyTaskManager:onHttpRequestsCallBack(command,...)
	Log.i("DailyTaskManager.onHttpRequestsCallBack");
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self,...);
	end 
end

--[[
    获得每日任务列表
--]]
function DailyTaskManager:sendGetNewDailyTaskList()
    HttpModule.getInstance():execute(HttpModule.s_cmds.GetNewDailyList);
end

--[[
    获得每日任务数据
--]]
function DailyTaskManager:sendGetDailyTaskData()
    HttpModule.getInstance():execute(HttpModule.s_cmds.GetDailyData);
end

--[[
    获得成长任务列表
--]]
function DailyTaskManager:sendGetGrowTaskList()
    HttpModule.getInstance():execute(HttpModule.s_cmds.getGrowTaskList);
end

--[[
    获得每日任务奖励
--]]
function DailyTaskManager:sendGetNewDailyReward(id,tips,isNeedMask,getMoney, callbackFunc)
    if not id then
        ChessToastManager.getInstance():showSingle("领取失败，请稍候再领取");
        return
    end

    local msg = tips;
    local post_data = {};
    post_data.task_id = id;
    self.mGetMoney = getMoney or 0
    HttpModule.getInstance():execute2(HttpModule.s_cmds.GetNewDailyReward,post_data,function (isSuccess,data) 
        if callbackFunc ~= nil then
            callbackFunc(isSuccess,data);
        end
    end);
end

--[[
    获得成长任务奖励
--]]
function DailyTaskManager:sendGetGrowTaskReward(data,tips,isNeedMask,getMoney,callbackFunc)
    if not data or not next(data) then
        ChessToastManager.getInstance():showSingle("领取失败，请稍候再领取");
        return
    end
    local post_data = {};
    post_data.param = data;
    self.mGetMoney = getMoney or 0;

    HttpModule.getInstance():execute2(HttpModule.s_cmds.getGrowTaskReward,post_data, function (isSuccess,data) 
        if callbackFunc ~= nil then
            callbackFunc(isSuccess,data);
        end
    end);
end

--[[
    每日任务列表回调
--]]
function DailyTaskManager:onGetNewDailyListResponse(isSuccess,message)
    if not isSuccess or message.data:get_value() == nil then
        return ;
    end 
    local data = json.analyzeJsonNode(message.data);
    if data.task then
        DailyTaskData.getInstance():setDailyTaskData(data.task);
    end
    
--    DailyTaskData.getInstance():setSignShowStatus(false);
--    if data.task then
--        for k,v in pairs(data.task)  do
--            if v.type == 3 then --or v.id == 17 then
--                if v.status ~= 1 then
--                    DailyTaskData.getInstance():setSignShowStatus(false);
--                    break;
--                end
--            end
--        end
--    end
    self:dispatch()
end

require(PAY_PATH.."exchangePay");
--[[
    每日任务奖励回调
--]]
function DailyTaskManager:onGetNewDailyRewardResponse(isSuccess,message)
    if not isSuccess or message.data:get_value() == nil then
        ChessToastManager.getInstance():show("领取失败");
        return ;
    end
    if self.mGetMoney and self.mGetMoney>0 then 
    --播放金币掉落动画
        DiceAccountDropMoney.play(50);
        --显示tip：获得多少金币
        ChessToastManager.getInstance():showSingle("获得"..self.mGetMoney .."金币",1500);
        self.mGetMoney = 0
    end 
    local data = json.analyzeJsonNode(message.data);
    if data.go_status == 200 then
        self:updateProp(data.prop)
        DailyTaskData.getInstance():setUpdateTaskId(data.task_id);
        self:updateDailyTaskStatus(data.task_id);
    else
        ChessToastManager.getInstance():show("领取失败!");
    end
end

--[[
    成就任务奖励回调
--]]
function DailyTaskManager:onGetGrowTaskRewardResponse(isSuccess,message)
    if not isSuccess then
        ChessToastManager.getInstance():show("领取失败");
        return;
    end
    if self.mGetMoney and self.mGetMoney>0 then 
    --播放金币掉落动画
        DiceAccountDropMoney.play(50);
        --显示tip：获得多少金币
        ChessToastManager.getInstance():showSingle("获得"..self.mGetMoney .."金币",1500);
        self.mGetMoney = 0
    end 
    local data = json.analyzeJsonNode(message.data);
    self:updateGrowTaskStatus(data.series_id,data);
end

--[[
    每日签到任务回调
--]]
function DailyTaskManager:onGetSignRewardResponse(isSuccess,message)
    if not isSuccess then
        local message = "领取失败"
        ChessToastManager.getInstance():showSingle(message);
        return
    else
        local data = DailyTaskData.getInstance():getDailySignData();
        local signData = data.list
        for k,v in pairs(signData) do
            if v then
                local status = tonumber(v.status) or 0
                if status == 1 then
                    v.status = 2
                    break
                end
            end
        end
        data.list = signData
        DailyTaskData.getInstance():setDailySignData(data);
        DailyTaskData.getInstance():setUpdataDailySignStatus(true)
        self:sendGetNewDailyTaskList()
        self:dispatch()
--        self:sendGetNewDailyTaskList();
    end
end

--[[
    获取成长任务回调
--]]
function DailyTaskManager:onGetGrowTaskListResponse(isSuccess,message)
    if not isSuccess or message.data:get_value() == nil then
        return ;
    end 
    local data = json.analyzeJsonNode(message.data);
    if data then
        DailyTaskData.getInstance():setGrowTaskData(data);
    end

--    DailyTaskData.getInstance():setSignShowStatus(false);
--    if data.task then
--        for k,v in pairs(data.task)  do
--            if v.id == 3 or v.id == 17 then
--                if v.status == 1 then
--                    DailyTaskData.getInstance():setSignShowStatus(true);
--                    break;
--                end
--            end
--        end
--    end
    self:dispatch()
end

function DailyTaskManager.onGetDailyDataResponse(self,isSuccess,message)
    if not isSuccess or message.data:get_value() == nil then
        return ;
    end 
    local data = json.analyzeJsonNode(message.data);
    if data then
        if tonumber(data.mid) ~= UserInfo.getInstance():getUid() then return end
        local signData = data.list or {}
        for k,v in pairs(signData) do
            if v then
                v.reward = json.decode(v.reward)
                local status = tonumber(v.status) or 0
                if status == 1 then
                    DailyTaskData.getInstance():setSignShowStatus(true)
                end
            end
        end
        data.list = signData
        DailyTaskData.getInstance():setDailySignData(data);
        self:dispatch()
    end
end


--[[
    更新道具奖励
--]]
function DailyTaskManager:updateProp(prop)
    if not prop then return end
    for i,v in pairs(data.prop) do
        local goods_type = ExchangePay.getStartNum(v.rid);
        if goods_type > 0 then
            self:revisePropById(goods_type,v.num)
        end
    end
end 

--[[
    goodType：道具类型
    num：数量
--]]
function DailyTaskManager:revisePropById(goodType,num)
    if goods_type and num and goods_type > 0 then
        if goods_type == 1 then--生命回复 --已经不要了

	    elseif goods_type == 2 then --悔棋
		    local undoNum = UserInfo.getInstance():getUndoNum();
		    undoNum = undoNum + num; 
		    UserInfo.getInstance():setUndoNum(undoNum);
	    elseif goods_type == 3 then --提示 
		    local tipsNum = UserInfo.getInstance():getTipsNum();
		    tipsNum = tipsNum + num; 
		    UserInfo.getInstance():setTipsNum(tipsNum);
	    elseif goods_type == 4 then --起死回生
		    local reviveNum = UserInfo.getInstance():getReviveNum();
		    reviveNum = reviveNum + num; 
		    UserInfo.getInstance():setReviveNum(reviveNum);
	    elseif goods_type == 5 then --增加生命上限 --已经不要了

        elseif goods_type == 6 then--残局大关 --已经不要了

	    elseif goods_type == 7 then--dapu
	  	    UserInfo.getInstance():setDapuEnable(1);
	    elseif goods_type == 8 then--单机大关 --已经不要了

	    end
	    --回调回去做本地发货或者更新关卡
	    --ExchangePay.uploadOrDownPropData(1);
    end
end

--[[
    更新任务状态
--]]
function DailyTaskManager:updateDailyTaskStatus(taskId)
    if not taskId then return end
    local datas = DailyTaskData.getInstance():getDailyTaskData();
    if datas == nil then return end

    for i,data in pairs(datas) do
        if data.id == taskId then
            data.status = 2;
            self:dispatch(i,data,1)
--            self:updateListView(i,data);
            --todo 更新界面的状态
            return true;
        end
    end
end

--[[
    更新成长任务状态
--]]
function DailyTaskManager:updateGrowTaskStatus(seriesId,resultData)
    if not seriesId or not next(resultData) then return end
    local datas = DailyTaskData.getInstance():getGrowTaskData();
    if datas == nil then return end

    for i,data in pairs(datas) do
        if tonumber(data.series_id) == tonumber(seriesId) then
            if resultData and tonumber(resultData.task_id) ~= 0 then
                data = resultData;
            else
                data.status = resultData.status;
            end;
            self:dispatch(i,data,0);
            return;
        end
    end
end
--[[
    读取奖励数据
    return 奖励的id，奖励的数量
--]]
function DailyTaskManager.processPrizeData(prize)
    if not prize or type(prize)~= "table" then 
        return nil
    end 
    local data ={}
    if prize[DailyTaskData.prizeType.GOLD] then 
        local item = {}
        item.typeId = DailyTaskData.prizeType.GOLD
        item.num = prize.money
        table.insert(data,item)
    end 
    if prize[DailyTaskData.prizeType.SOUL] then
        local item = {}
        item.typeId = DailyTaskData.prizeType.SOUL
        item.num = prize.soul
        table.insert(data,item)
    end   
    if prize[DailyTaskData.prizeType.PROP] then 
        if prize.prop[DailyTaskData.propType.UNDO] then 
            local item = {}
            item.typeId = DailyTaskData.propType.UNDO
            item.num = prize.prop[DailyTaskData.propType.UNDO]
            table.insert(data,item)
        end 
        if prize.prop[DailyTaskData.propType.TIP] then 
            local item = {}
            item.typeId = DailyTaskData.propType.TIP
            item.num = prize.prop[DailyTaskData.propType.TIP]
            table.insert(data,item)
        end 
        if prize.prop[DailyTaskData.propType.REVIVE] then 
            local item = {}
            item.typeId = DailyTaskData.propType.REVIVE
            item.num = prize.prop[DailyTaskData.propType.REVIVE]
            table.insert(data,item)
        end 
    end
    return data
end 

--[[
    领取所有的已完成的任务奖励
--]]
function DailyTaskManager.sendGetAllTaskReward(self,tips,isNeedMask)
    if not DailyTaskData.getInstance():getCompleteStatus() and not DailyTaskData.getInstance():getGrowTaskCompleteStatus() then 
        return 
    end 
    --领取所有的已完成的日常任务
    local dailyTask = DailyTaskData.getInstance():getDailyTaskData()
    if dailyTask then
        for k,v in pairs(dailyTask) do
            if tonumber(v.status) == 1 then
                self:sendGetNewDailyReward(v.id,tips,isNeedMask)
            end
        end
    end
    --领取所有的已完成的成长任务
    local growTask = DailyTaskData.getInstance():getGrowTaskData()
    if growTask then
        for k,v in pairs(growTask) do
            if tonumber(v.status) == 1 then
                local post_data = {};
                post_data.series_id = v.series_id;
                post_data.task_id = v.task_id;
                self:sendGetGrowTaskReward(post_data,tips,isNeedMask)
            end
        end
    end
end 
--[[
    注册回调事件
--]]
function DailyTaskManager:register(obj,func)
    local arr = {};
    arr["obj"] = obj;
    arr["func"] = func;
    if not self.m_dailyListener then 
        self.m_dailyListener = {};
    end
    table.insert(self.m_dailyListener,arr);
end

--[[
    注销回调事件
--]]
function DailyTaskManager:unregister(obj,func)
	if not self.m_dailyListener then return end

    local arr;
    for i,v in pairs(self.m_dailyListener) do
        arr = v;
        if not arr then break end
        if (arr["func"] == func) and (arr["obj"] == obj) then
            table.remove(self.m_dailyListener,i);
            return true
        end
    end
    return false
end 

function DailyTaskManager:dispatch( ...)
	if not self.m_dailyListener then return end;
	self.m_dispatching = true;
    for i,v in pairs(self.m_dailyListener) do
        if not v then return false end
        if v["func"] and v["obj"] then
            v["func"](v["obj"], ...)
        end
    end
end


DailyTaskManager.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.GetNewDailyList]   = DailyTaskManager.onGetNewDailyListResponse;
    [HttpModule.s_cmds.GetNewDailyReward] = DailyTaskManager.onGetNewDailyRewardResponse;
    [HttpModule.s_cmds.getSignReward]     = DailyTaskManager.onGetSignRewardResponse;
    [HttpModule.s_cmds.getGrowTaskList]   = DailyTaskManager.onGetGrowTaskListResponse;
    [HttpModule.s_cmds.getGrowTaskReward] = DailyTaskManager.onGetGrowTaskRewardResponse;
    [HttpModule.s_cmds.GetDailyData]      = DailyTaskManager.onGetDailyDataResponse;

};