RoomConfig = class(GameCacheData,false);
RoomConfig.ROOM_TYPE_NULL                   = 0;
RoomConfig.ROOM_TYPE_NOVICE_ROOM            = 1;
RoomConfig.ROOM_TYPE_INTERMEDIATE_ROOM      = 2;
RoomConfig.ROOM_TYPE_MASTER_ROOM            = 3;
RoomConfig.ROOM_TYPE_PRIVATE_ROOM           = 4;
RoomConfig.ROOM_TYPE_FRIEND_ROOM            = 5;
RoomConfig.ROOM_TYPE_WATCH_ROOM             = 6;
RoomConfig.ROOM_TYPE_CONSOLE_ROOM           = 7;
RoomConfig.ROOM_TYPE_ENDGATE_ROOM           = 8;
RoomConfig.ROOM_TYPE_ARENA_ROOM             = 9;
RoomConfig.ROOM_TYPE_REPLAY_ROOM            = 10;
RoomConfig.ROOM_TYPE_DAPU_ROOM              = 11;
RoomConfig.ROOM_TYPE_MONEY_MATCH_ROOM       = 12;
RoomConfig.ROOM_TYPE_METIER_ROOM            = 13; --职业赛
RoomConfig.ROOM_TYPE_FAMOUS_ROOM            = 14; --名人赛
--matchid    type|id|比赛日期|时间

RoomConfig.TYPE_NAME = {
	[RoomConfig.ROOM_TYPE_NULL]                     = "room_type_null";                     --未知房间
	[RoomConfig.ROOM_TYPE_NOVICE_ROOM]              = "room_type_novice_room";              --新手房间
	[RoomConfig.ROOM_TYPE_INTERMEDIATE_ROOM]        = "room_type_intermediate_room";        --中级房间
	[RoomConfig.ROOM_TYPE_MASTER_ROOM]              = "room_type_master_room";              --大师房间
	[RoomConfig.ROOM_TYPE_WATCH_ROOM]               = "room_type_watch_room";               --观战房间
	[RoomConfig.ROOM_TYPE_PRIVATE_ROOM]             = "room_type_private_room";             --私人房间
    [RoomConfig.ROOM_TYPE_FRIEND_ROOM]              = "room_type_friend_room";              --好友房间
	[RoomConfig.ROOM_TYPE_CONSOLE_ROOM]             = "room_type_console_room";             --单机房间
    [RoomConfig.ROOM_TYPE_ENDGATE_ROOM]             = "room_type_endgate_room";             --残局房间
    [RoomConfig.ROOM_TYPE_ARENA_ROOM]               = "room_type_arena_room";               --竞技场房间
    [RoomConfig.ROOM_TYPE_REPLAY_ROOM]              = "room_type_replay_room";              --回放房间
    [RoomConfig.ROOM_TYPE_DAPU_ROOM]                = "room_type_dapu_room";                --打谱房间
    [RoomConfig.ROOM_TYPE_MONEY_MATCH_ROOM]         = "room_type_money_match_room";         --金币赛房间
    [RoomConfig.ROOM_TYPE_METIER_ROOM]              = "room_type_metier_room";              --职业赛
    [RoomConfig.ROOM_TYPE_FAMOUS_ROOM]              = "room_type_famous_room";              --名人赛
}

function RoomConfig.getTypeName(ctype)
    local typeName = RoomConfig.TYPE_NAME[ctype] or RoomConfig.TYPE_NAME[RoomConfig.ROOM_TYPE_NULL];
    return typeName;
end

function RoomConfig.getInstance()
    if not RoomConfig.instance then
        RoomConfig.instance = new(RoomConfig);
    end
    return RoomConfig.instance;
end

function RoomConfig.ctor(self)
    self.m_dict = new(Dict,"room_config");
    self.m_dict:load();
end

function RoomConfig.saveRoomConfig(self,roomConfig)
	if not roomConfig then
		print_string("not roomConfig");
		return
	end
    self:saveString("room_config",json.encode(roomConfig));
    self.mRoomConfig = self:explainPHPRoomConfig(roomConfig);
end

function RoomConfig.getRoomConfig(self)
    if not self.mRoomConfig then
        local jsonStr = self:getString("room_config","");
        self.mRoomConfig = self:explainPHPRoomConfig(json.decode(jsonStr));
    end
    return self.mRoomConfig or {};
end
--[Comment]
-- 获取房间类型配置
function RoomConfig.getRoomTypeConfig(self,roomType)
    if roomType == RoomConfig.ROOM_TYPE_MONEY_MATCH_ROOM 
        or roomType == RoomConfig.ROOM_TYPE_METIER_ROOM
        or roomType == RoomConfig.ROOM_TYPE_FAMOUS_ROOM then
        local matchRoomConfig = self:getMatchRoomList();
        local ret = {}
        for _,typeConfig in pairs(matchRoomConfig) do
            if type(typeConfig) == "table" and typeConfig.room_type == roomType then 
                table.insert(ret,typeConfig)
            end
        end
        return ret
    end
    local roomConfig = self:getRoomConfig();
    local ret = {}
    for _,config in pairs(roomConfig) do
        if config.room_type == roomType then
            return config
        end
    end
end

--[Comment]
-- 获取房间配置
function RoomConfig.getRoomLevelConfig(self,roomLevel)
    local matchRoomConfig = self:getMatchRoomList();
    local level = tonumber(roomLevel)
    for _,typeConfig in pairs(matchRoomConfig) do
        if type(typeConfig) == "table" and typeConfig.level == level then 
            return typeConfig
        end
    end

    local roomConfig = self:getRoomConfig();
    return roomConfig[level];
end

--[Comment]
-- 获取比赛房间配置,返回两个参数 第二个参数：是否需要拉比赛配置
function RoomConfig.getMatchRoomConfig(self,matchId)
    if not matchId or matchId == "" then return nil,false end
    local matchRoomConfig = self:getMatchRoomList();
    for _,config in pairs(matchRoomConfig) do
        if type(config) == "table" and config.match_id == matchId then 
            return config,false
        end
    end
    self:sendGetMatchRoomListHttp()
    return nil,true
end


function RoomConfig.explainPHPRoomConfig(self,roomConfig)
    if type(roomConfig) ~= "table" then return {} end
    local ret = {};
    for _,value in pairs(roomConfig) do 
		local room = {};
		room.id       = tonumber(value.id) or 0;
        room.level    = tonumber(value.level) or 0;
		room.name     = value.room_name;
		room.money    = tonumber(value.basechip) or 0;
		room.minmoney = tonumber(value.min_money) or 0;
		room.maxmoney = tonumber(value.max_money) or 0;
		room.roundTime = tonumber(value.round_time) or 0;
		room.stepTime = tonumber(value.step_time) or 0;
		room.secTime = tonumber(value.sec_time) or 0;
		room.rent     = tonumber(value.rent) or 0;
		room.status   =  tonumber(value.room_status) or 0;
		room.type     = tonumber(value.type) or 0;
        room.room_type = tonumber(value.room_type) or 0;
		room.time     = room.roundTime/60;
        room.undomoney = tonumber(value.huiqi_cost_money) or 0;
        room.isShow   = tonumber(value.is_show or 1);
        room.give_up_time = tonumber(value.give_up_time or 0);
        room.beishu_level = tonumber(value.beishu_level or 0);
        room.rangzi_level = tonumber(value.rangzi_level or 0);
        room.least_step   = tonumber(value.least_step or 0)
		ret[room.level] = room;
	end
    return ret;
end

--配置自由场的局时、步时、读秒
function RoomConfig.setFreedomRoomTimeConfig(self,freedomRoomConfig)
    if not freedomRoomConfig then
		print_string("not freedomRoomConfig");
		return
	end

	self.mFreedomRoomSumtime = freedomRoomConfig.sumtime:get_value();
	self.mFreedomRoomSteptime = freedomRoomConfig.steptime:get_value();
	self.mFreedomRoomReadtime = freedomRoomConfig.readtime:get_value();
end

function RoomConfig.getFreedomRoomSumTime(self)
	return self.mFreedomRoomSumtime or 10*60;
end

function RoomConfig.getFreedomRoomStepTime(self)
	return self.mFreedomRoomSteptime or 2*60;
end

function RoomConfig.getFreedomRoomReadTime(self)
	return self.mFreedomRoomReadtime or 60;
end


function RoomConfig.getMatchRoomList(self)
    if not self.mMatchRoomConfig then
        local jsonStr = self:getString("match_room_config_270","")
        local mathcRoomConfig = json.decode(jsonStr)
        local config = {}
        if mathcRoomConfig then
            for roomSort,roomConfig in ipairs(mathcRoomConfig) do
                config[tonumber(roomSort) or 0] = self:explainPHPMatchRoomConfig(roomConfig)
            end
        end
        self.mMatchRoomConfig = config
        self:sendGetMatchRoomListHttp()
    end
    return self.mMatchRoomConfig or {};
end

function RoomConfig.sendGetMatchRoomListHttp(self)
    local sendData = {} 
    HttpModule.getInstance():execute(HttpModule.s_cmds.getMatchList,sendData)
end

function RoomConfig.saveMatchRoomList(self,mathcRoomConfig)
    if not mathcRoomConfig then
		print_string("not mathcRoomConfig");
		return
	end
    self:saveString("match_room_config_270",json.encode(mathcRoomConfig));
    local config = {}
    for roomSort,roomConfig in ipairs(mathcRoomConfig) do
        config[tonumber(roomSort) or 0] = self:explainPHPMatchRoomConfig(roomConfig)
    end
    self.mMatchRoomConfig = config
end

function RoomConfig.explainPHPMatchRoomConfig(self,roomConfig)
    if type(roomConfig) ~= "table" or roomConfig.id == nil then return end
	local room = {};
	room.id       = tonumber(roomConfig.id) or 0;
    room.level    = tonumber(roomConfig.level) or 0;
	room.name     = roomConfig.name;
	room.money    = tonumber(roomConfig.basechip) or 0;
	room.minmoney = tonumber(roomConfig.min_money) or 0;
	room.maxmoney = tonumber(roomConfig.max_money) or 0;
	room.roundTime = tonumber(roomConfig.round_time) or 0;
	room.stepTime = tonumber(roomConfig.step_time) or 0;
	room.secTime = tonumber(roomConfig.sec_time) or 0;
	room.rent     = tonumber(roomConfig.rent) or 0;
	room.status   =  tonumber(roomConfig.room_status) or 0;
	room.type     = tonumber(roomConfig.type) or 0;
    room.room_type = tonumber(roomConfig.type) or 0;
	room.time     = room.roundTime/60;
    room.undomoney = tonumber(roomConfig.huiqi_cost_money) or 0;
    room.isShow   = tonumber(roomConfig.is_show or 1);
    room.give_up_time = tonumber(roomConfig.give_up_time or 0);
    room.beishu_level = tonumber(roomConfig.beishu_level or 0);
    room.rangzi_level = tonumber(roomConfig.rangzi_level or 0);
    room.least_step   = tonumber(roomConfig.least_step or 0)
    -- 比赛房间配置
    room.wait_time    = tonumber(roomConfig.wait_time) or 0
    room.ready_time   = tonumber(roomConfig.ready_time) or 0
    room.sign_time    = tonumber(roomConfig.sign_time) or 0
    room.least_num    = tonumber(roomConfig.least_num) or 0
    room.join_money   = tonumber(roomConfig.join_money) or 0
    room.is_open      = tonumber(roomConfig.is_open) or 0
    room.match_time   = roomConfig.match_time or ""
    room.end_date     = roomConfig.end_date or ""
    room.start_date   = roomConfig.start_date or ""
    room.img_url      = roomConfig.img_url or ""
    room.prize        = roomConfig.prize or ""
    room.short_desc   = roomConfig.short_desc or ""
    room.prize_text     = roomConfig.prize_text or ""
    room.bet            = roomConfig.bet or ""
    room.match_start_time   = tonumber(roomConfig.match_start_time) or 0
    room.match_end_time     = tonumber(roomConfig.match_end_time) or 0
    room.start_sign_time    = tonumber(roomConfig.start_sign_time) or 0
    room.end_sign_time      = tonumber(roomConfig.end_sign_time) or 0
    room.match_id           = roomConfig.match_id or ""
    room.match_status       = tonumber(roomConfig.match_status) or 0
    room.sign_status        = tonumber(roomConfig.sign_status) or 0
    room.diff_time          = tonumber(roomConfig.diff_time) or 0

    room.sort               = tonumber(roomConfig.sort) or 0
    room.repeat_week        = roomConfig.repeat_week or ""
    room.before_show_time   = roomConfig.before_show_time or ""
    room.max_num    = tonumber(roomConfig.max_num) or 0
    room.end_sign_sec       = tonumber(roomConfig.end_sign_sec) or 0
    room.join_num           = tonumber(roomConfig.join_num) or 0

    room.join_min_money       = tonumber(roomConfig.join_min_money) or 0
    room.join_max_money       = tonumber(roomConfig.join_max_money) or 0
    room.join_min_score       = tonumber(roomConfig.join_min_score) or 0
    room.join_max_score       = tonumber(roomConfig.join_max_score) or 0
    room.init_score           = tonumber(roomConfig.init_score) or 0
    room.chat_id              = roomConfig.chat_id
    return room;
end

function RoomConfig.analysisPrize(prize)
    if not prize then return {} end
    local ret = {}
    for key,val in pairs(prize) do
        local startRank = tonumber(val["start"])
        local endRank = tonumber(val["end"])
        if startRank and endRank then
            for i=startRank,endRank do
                ret[i] = Copy(val)
            end
        end
    end
    return ret
end

function RoomConfig.getRoomConfigByType(self)
    if not self.mRoomConfig then
        local jsonStr = self:getString("room_config","");
        self.mRoomConfig = self:explainPHPRoomConfig(json.decode(jsonStr));
    end
    local config = {}
    local temp = {}
    for k,v in pairs(self.mRoomConfig) do 
        if v then
            temp = v
            temp.room_id_type = k
            config[v.room_type or 0] = temp
        end 
    end
    return config or {};
end

function RoomConfig:onGetScreenings(status)
    if not status then return nil end
    local level,matchId = status.level,status.matchId
    local matchRoom = self:getMatchRoomConfig(matchId);

    if matchRoom then 
        if matchRoom.room_type == RoomConfig.ROOM_TYPE_METIER_ROOM then return "职业赛" end
        if matchRoom.room_type == RoomConfig.ROOM_TYPE_MONEY_MATCH_ROOM then return "八人赛" end
        return matchRoom.name 
    end

    local room = self:getRoomLevelConfig(level);
    if room then
        return room.name
    end

    return nil;
end

function RoomConfig:isPlaying(status)
    if not status then return false end
    local tid,level,matchId = status.tid,status.level,status.matchId
    if tid > 0 then return true end
    if matchId and matchId ~= "" then return true end
    return false
end