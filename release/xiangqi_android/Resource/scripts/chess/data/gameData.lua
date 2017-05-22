--region gameData.lua
--Author : BearLuo
--Date   : 2015/4/15

require(DATA_PATH.."terminalInfo");
GameData = class();

GameData.ctor = function(self)

end

GameData.getInstance = function()
    if not GameData.s_instance then
        GameData.s_instance = new(GameData);
    end
    return GameData.s_instance;
end

GameData.setGetDailyTask = function(self,ret)
    self.m_get_dailyTask = ret;
end

GameData.getGetDailyTask = function(self)
    return self.m_get_dailyTask;
end


-- 为了以后控制流量的
GameData.getDailyListData = function(self,isForce,tip,canCancel,level)
    if not self.m_dailyListData or isForce then
       HttpModule.getInstance():execute(HttpModule.s_cmds.GetDailyList,{},tip,canCancel,level);
       return ; 
    end
    EventDispatcher.getInstance():dispatch(Event.Call, GET_DAILY_LIST_EVENT,self.m_dailyListData);
end

GameData.saveDailyListData = function(self,data)
    if data then
		self.m_dailyListData = {};
		for _,value in pairs(data) do 
			local daily = {};
			if value and value.id then
				daily.id         	= tonumber(value.id:get_value()) or 0;--任务ID 
				daily.type        	= tonumber(value.type:get_value()) or 0;--任务类型（1残局挑战，2联网游戏，3签到，4连续签到）
				daily.name  		= value.name:get_value() or "";--任务名称 
				daily.num       	= tonumber(value.num:get_value()) or 0;--奖励金币数
				daily.reward_gold   = tonumber(value.reward_gold:get_value()) or 0;--前几天登陆 ps: 10  10天前登陆   0 今天登陆
				daily.progress      = tonumber(value.progress:get_value());--当前进度 
				daily.status         = tonumber(value.status:get_value()) or 0;--任务状态（0未达成，1已达成未领取，2已领取）

				-- print_string("============daily.id================"..daily.id);
				-- print_string("============daily.type================"..daily.type);
				-- print_string("============fdaily.name================"..daily.name);
				-- print_string("============daily.num================"..daily.num);
				-- print_string("============daily.reward_gold================"..daily.reward_gold);
				-- print_string("============daily.progress================"..daily.progress);
				-- print_string("============daily.status================"..daily.status);
				table.insert(self.m_dailyListData,daily);				
			end
		end
	end
    EventDispatcher.getInstance():dispatch(Event.Call, GET_DAILY_LIST_EVENT,self.m_dailyListData);
    return self.m_dailyListData;
end

GameData.getDailyRewardData = function(self,data)
	if data then
		local dataTb = {};
		local prizeInfo = data.prizeInfo;
		local prizeInfoTB = {};
		dataTb.got_status =  tonumber(data.got_status:get_value()) or 0;
		dataTb.type =  tonumber(data.type:get_value()) or 0;


		prizeInfoTB.reward = prizeInfo.reward:get_value() or "";
		prizeInfoTB.num = tonumber(prizeInfo.num:get_value()) or 0;
		prizeInfoTB.type = tonumber(prizeInfo.type:get_value()) or 0;
		prizeInfoTB.rid = tonumber(prizeInfo.rid:get_value()) or 0;
		prizeInfoTB.rate = tonumber(prizeInfo.rate:get_value()) or 0;

		dataTb.prizeInfo = prizeInfoTB;

		local nextSignTB = {};
		local next_sign = data.next_sign;
		nextSignTB.id = tonumber(next_sign.id:get_value()) or 0;
		nextSignTB.type = tonumber(next_sign.type:get_value()) or 0;
		nextSignTB.name = next_sign.name:get_value() or "";
		nextSignTB.num = tonumber(next_sign.num:get_value()) or 0;
		nextSignTB.reward_gold = tonumber(next_sign.reward_gold:get_value()) or 0;
		nextSignTB.progress = tonumber(next_sign.progress:get_value()) or 0;
		nextSignTB.status = tonumber(next_sign.status:get_value()) or 0;
		dataTb.next_sign = nextSignTB;

		-- if  dataTb.prizeInfo then
		-- 	if dataTb.prizeInfo.reward then
		-- 		print_string("============dataTb.prizeInfo.reward============"..dataTb.prizeInfo.reward);
		-- 	end
		
		-- 	print_string("============dataTb.prizeInfo.num============"..dataTb.prizeInfo.num);
		-- 	print_string("============dataTb.prizeInfo.type============"..dataTb.prizeInfo.type);
		-- 	print_string("============dataTb.prizeInfo.rid============"..dataTb.prizeInfo.rid);
		-- 	print_string("============dataTb.prizeInfo.rate============"..dataTb.prizeInfo.rate);		
		-- end


		-- if  dataTb.next_sign then
		-- 	if dataTb.next_sign.name then
		-- 		print_string("============dataTb.next_sign.name============"..dataTb.next_sign.name);
		-- 	end
		
		-- 	print_string("============dataTb.next_sign.id============"..dataTb.next_sign.id);
		-- 	print_string("============dataTb.next_sign.type============"..dataTb.next_sign.type);
		-- 	print_string("============dataTb.next_sign.num============"..dataTb.next_sign.num);
		-- 	print_string("============dataTb.next_sign.reward_gold============"..dataTb.next_sign.reward_gold);	
		-- 	print_string("============dataTb.next_sign.progress============"..dataTb.next_sign.progress);	
		-- 	print_string("============dataTb.next_sign.status============"..dataTb.next_sign.status);	
		-- end
        return dataTb;
	end
    return nil;
end

GameData.setUpdateUrl = function(self,url)
    self.m_updateUrl = url;
end

--下载到本地的地址
GameData.getSaveFileUrl = function(self)
    if TerminalInfo.getInstance():isSDCardWritable() then
        Log.i("GameData.getApkUpdatePath isSDCardWritable!");
        local path = System.getStorageUpdatePath();
        Log.i("GameData.getApkUpdatePath path:"..path);
        dict_set_string("patchUpdate" , "dirPath" ,path);--目录全路径
        
        dict_set_string("LuaCallEvent","LuaCallEvent","PatchUpdateDir");

        if System.getPlatform() == kPlatformAndroid then
            call_native("OnLuaCall");
        end 
        return path;
    else
        Log.i("GameData.getApkUpdatePath is not SDCardWritable!");
        return TerminalInfo.getInstance():getInternalUpdatePath();
    end
end

--H5 URL
GameData.setH5Url = function(self,url)
    self.m_h5Url = url;
end

GameData.getH5Url = function(self)
    return self.m_h5Url or "null";
end

--H5 Native URL
GameData.setH5NativeUrl = function(self,url)
    self.m_h5NativeUrl = url;
end

GameData.getH5NativeUrl = function(self)
    return self.m_h5NativeUrl or "";
end

