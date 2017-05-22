--region dailyTaskData.lua
--Author : FordFan
--createDate   : 2016/4/21
--每日任务数据和管理类


--[[
    每日任务数据类
--]]

DailyTaskData = class()

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
end

--保存每日任务数据
function DailyTaskData:setDailyTaskData(data)
    self.m_daily_task_data = data;
end

function DailyTaskData:getDailyTaskData()
    return self.m_daily_task_data;
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

--[[
    每日任务管理类
--]]

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
    获得每日任务奖励
--]]
function DailyTaskManager:sendGetNewDailyReward(id,tips)
    if not id then
        ChessToastManager.getInstance():showSingle("领取失败，请稍候再领取");
        return
    end

    local msg = tips;
    local post_data = {};
    post_data.task_id = id;
    HttpModule.getInstance():execute(HttpModule.s_cmds.GetNewDailyReward,post_data,msg);
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

    DailyTaskData.getInstance():setSignShowStatus(false);
    if data.task then
        for k,v in pairs(data.task)  do
            if v.id == 3 or v.id == 17 then
                if v.status == 1 then
                    DailyTaskData.getInstance():setSignShowStatus(true);
                    break;
                end
            end
        end
    end
    self:dispatch()
end

--[[
    每日任务奖励回调
--]]
function DailyTaskManager:onGetNewDailyRewardResponse(isSuccess,message)
    if not isSuccess or message.data:get_value() == nil then
        ChessToastManager.getInstance():show("领取失败");
        return ;
    end
    require(PAY_PATH.."exchangePay");
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
    每日签到任务回调
--]]
function DailyTaskManager:onGetSignRewardResponse(isSuccess,message)
    if not isSuccess then
        local message = "领取失败"
        ChessToastManager.getInstance():showSingle(message);
        return
    else
        self:sendGetNewDailyTaskList();
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
            self:dispatch(i,data)
--            self:updateListView(i,data);
            --todo 更新界面的状态
            return true;
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
};