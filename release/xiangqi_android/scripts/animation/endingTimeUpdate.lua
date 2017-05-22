require("config/game_config");
require(DATA_PATH.."userInfo");

EndingTimeUpdate = {}


EndingTimeUpdate.start = function()
	print_string("EndingTimeUpdate.start");

	if not EndingTimeUpdate.hasStarted then
		EndingTimeUpdate.hasStarted = true;

		if EndingTimeUpdate.m_timeoutAnim then
			delete(EndingTimeUpdate.m_timeoutAnim);
			EndingTimeUpdate.m_timeoutAnim = nil;
		end
		
		EndingTimeUpdate.m_timeoutAnim = new(AnimInt,kAnimLoop,0,1,1000,-1);
		EndingTimeUpdate.m_timeoutAnim:setEvent(EndingTimeUpdate,EndingTimeUpdate.coolingTimeRun);
	end
end

EndingTimeUpdate.coolingTimeRun = function()
	EndingTimeUpdate.m_coolingTime = EndingTimeUpdate.getTime();

    if EndingTimeUpdate.m_coolingTime < 0 then 
		EndingTimeUpdate.m_coolingTime = ENDING_LIFE_COOLING_TIME * 60;
    	EndingTimeUpdate.addLifeNum();
	end

	if EndingTimeUpdate.m_onUpdateFunc ~= nil then
        EndingTimeUpdate.m_onUpdateFunc(EndingTimeUpdate.m_onUpdateObj,EndingTimeUpdate.m_coolingTime);
    end

    local uid = UserInfo.getInstance():getUid();
	GameCacheData.getInstance():saveString(GameCacheData.ENDING_UPDATE_LAST_SYS_TIME..uid,"" .. os.time());
	GameCacheData.getInstance():saveString(GameCacheData.ENDING_UPDATE_LAST_TIME..uid,"" .. EndingTimeUpdate.m_coolingTime);
end

EndingTimeUpdate.getTime = function()
	local uid = UserInfo.getInstance():getUid();
	local lastSysTime = tonumber(GameCacheData.getInstance():getString(GameCacheData.ENDING_UPDATE_LAST_SYS_TIME .. uid, "" .. os.time())); --最后一次记录的系统时间
	local lastTime = tonumber(GameCacheData.getInstance():getString(GameCacheData.ENDING_UPDATE_LAST_TIME .. uid, "" .. (ENDING_LIFE_COOLING_TIME*60)));
	if not lastSysTime then
		lastSysTime = os.time();
	end
	if not lastTime then
		lastTime = ENDING_LIFE_COOLING_TIME*60;
	end
	local curTime = os.time();
	local dis = curTime - lastSysTime;

	if dis < 0 then --手动修改时间了。。。
		dis = curTime;
	end

	EndingTimeUpdate.updateEndingLife(dis);

	local time = lastTime - (dis % (60 * ENDING_LIFE_COOLING_TIME));

	return time;
end

EndingTimeUpdate.addLifeNum = function()
	local life_num = UserInfo.getInstance():getLifeNum();		
	local life_limit = UserInfo.getInstance():getLifeLimitNum();
	if life_num < life_limit then
		life_num = life_num + 1;
		UserInfo.getInstance():setLifeNum(life_num);
	end		
end

EndingTimeUpdate.resetTime = function()
    local uid = UserInfo.getInstance():getUid();
	GameCacheData.getInstance():saveString(GameCacheData.ENDING_UPDATE_LAST_SYS_TIME..uid,"" .. os.time());
	GameCacheData.getInstance():saveString(GameCacheData.ENDING_UPDATE_LAST_TIME..uid,"" .. ENDING_LIFE_COOLING_TIME*60);
end

EndingTimeUpdate.updateEndingLife = function(disParam)
	local dis = (disParam)/60;
	if dis > ENDING_LIFE_COOLING_TIME then
		local life_num = UserInfo.getInstance():getLifeNum();		
		local life_limit = UserInfo.getInstance():getLifeLimitNum();
		if life_num < life_limit then
			life_num = life_num + math.floor(dis/ENDING_LIFE_COOLING_TIME);
		end
		if life_num > life_limit then
			life_num = life_limit;
		end
		UserInfo.getInstance():setLifeNum(life_num);
	end
end

EndingTimeUpdate.isRunning = function()
	if EndingTimeUpdate.hasStarted then
		return true;
	end
	return false;
end

EndingTimeUpdate.setListener = function(obj,func)
	EndingTimeUpdate.m_onUpdateFunc = func;
	EndingTimeUpdate.m_onUpdateObj = obj;
end

EndingTimeUpdate.stop = function()
	print_string("EndingTimeUpdate.stop");
	if EndingTimeUpdate.m_timeoutAnim then
		delete(EndingTimeUpdate.m_timeoutAnim);
		EndingTimeUpdate.m_timeoutAnim = nil;
	end
	EndingTimeUpdate.hasStarted = false;
end