require("config/roomConfig");
RoomProxy = class();

function RoomProxy.getInstance()
    if not RoomProxy.instance then
        RoomProxy.instance = new(RoomProxy);
    end
    return RoomProxy.instance;
end

function RoomProxy.ctor(self)
    self.mCurRoomType = RoomConfig.ROOM_TYPE_NULL;
end

function RoomProxy.setCurRoomType(self,ctype)
    self.mCurRoomType = ctype;
end

function RoomProxy.getCurRoomType(self)
    return self.mCurRoomType or RoomConfig.ROOM_TYPE_NULL;
end

function RoomProxy.getCurRoomLevel(self)
	return self.mCurRoomConfig.level or 0;
end

function RoomProxy.setCurRoomConfig(self,config)
    self.mCurRoomConfig = config;
end

function RoomProxy.getCurRoomConfig(self)
    return self.mCurRoomConfig;
end

function RoomProxy.changeRoomType(self,ctype)
    self:setCurRoomType(ctype);
end

function RoomProxy.gotoLevelRoom(self,level)
    if UserInfo.getInstance():isFreezeUser() then return end;
    local config = RoomConfig.getInstance():getRoomLevelConfig(level)
    if not config then return end
    self:setCurRoomType(config.room_type);
    self:setCurRoomConfig(config)
    StateMachine.getInstance():pushState(States.OnlineRoom,StateMachine.STYPE_CUSTOM_WAIT);
end

function RoomProxy.gotoPrivateRoom(self,isSelf)
    if UserInfo.getInstance():isFreezeUser() then return end;
    self:setCurRoomType(RoomConfig.ROOM_TYPE_PRIVATE_ROOM);
    self:setCurRoomConfig(RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_PRIVATE_ROOM))
    self:setSelfRoom(isSelf);--  设置是自己创建的房间
    StateMachine.getInstance():pushState(States.OnlineRoom,StateMachine.STYPE_CUSTOM_WAIT);
end

function RoomProxy.gotoFriendRoom(self)
    if UserInfo.getInstance():isFreezeUser() then return end;
    self:setCurRoomType(RoomConfig.ROOM_TYPE_FRIEND_ROOM);
    self:setCurRoomConfig(RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_FRIEND_ROOM))
    StateMachine.getInstance():pushState(States.OnlineRoom,StateMachine.STYPE_CUSTOM_WAIT);
end

function RoomProxy.gotoNoviceRoom(self)
    if UserInfo.getInstance():isFreezeUser() then return end;
    self:setCurRoomType(RoomConfig.ROOM_TYPE_NOVICE_ROOM);
    self:setCurRoomConfig(RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_NOVICE_ROOM))
    StateMachine.getInstance():pushState(States.OnlineRoom,StateMachine.STYPE_CUSTOM_WAIT);
end

function RoomProxy.gotoIntermediateRoom(self)
    if UserInfo.getInstance():isFreezeUser() then return end;
    self:setCurRoomType(RoomConfig.ROOM_TYPE_INTERMEDIATE_ROOM);
    self:setCurRoomConfig(RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_INTERMEDIATE_ROOM))
    StateMachine.getInstance():pushState(States.OnlineRoom,StateMachine.STYPE_CUSTOM_WAIT);
end

function RoomProxy.gotoMasterRoom(self)
    if UserInfo.getInstance():isFreezeUser() then return end;
    self:setCurRoomType(RoomConfig.ROOM_TYPE_MASTER_ROOM);
    self:setCurRoomConfig(RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_MASTER_ROOM))
    StateMachine.getInstance():pushState(States.OnlineRoom,StateMachine.STYPE_CUSTOM_WAIT);
end

function RoomProxy.gotoWatchRoom(self,tid,level)
    if UserInfo.getInstance():isFreezeUser() then return end;
    self:setCurRoomType(RoomConfig.ROOM_TYPE_WATCH_ROOM);
    self:setCurRoomConfig(RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_WATCH_ROOM))
	self:setTid(tid);
    self:setRoomLevel(level);
    StateMachine.getInstance():pushState(States.OnlineRoom,StateMachine.STYPE_CUSTOM_WAIT);
end

function RoomProxy.gotoEndgateRoom(self)
    self:setCurRoomType(RoomConfig.ROOM_TYPE_ENDGATE_ROOM);
    self:setCurRoomConfig(RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_ENDGATE_ROOM))
    StateMachine.getInstance():pushState(States.EndingRoom,StateMachine.STYPE_CUSTOM_WAIT);
end

function RoomProxy.gotoConsoleRoom(self)
    self:setCurRoomType(RoomConfig.ROOM_TYPE_CONSOLE_ROOM);
    self:setCurRoomConfig(RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_CONSOLE_ROOM))
    StateMachine.getInstance():pushState(States.ConsoleRoom,StateMachine.STYPE_CUSTOM_WAIT);
end

function RoomProxy.gotoReplayRoom(self)
    self:setCurRoomType(RoomConfig.ROOM_TYPE_REPLAY_ROOM);
    self:setCurRoomConfig(RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_REPLAY_ROOM))
    StateMachine.getInstance():pushState(States.ReplayRoom,StateMachine.STYPE_CUSTOM_WAIT);
end

function RoomProxy.gotoDapuRoom(self)
    self:setCurRoomType(RoomConfig.ROOM_TYPE_DAPU_ROOM);
    self:setCurRoomConfig(RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_DAPU_ROOM))
    StateMachine.getInstance():pushState(States.CustomBoard,StateMachine.STYPE_CUSTOM_WAIT);
end

function RoomProxy.gotoArenaRoom(self)
    if UserInfo.getInstance():isFreezeUser() then return end;
    self:setCurRoomType(RoomConfig.ROOM_TYPE_ARENA_ROOM);
    self:setCurRoomConfig(RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_ARENA_ROOM))
    StateMachine.getInstance():pushState(States.OnlineRoom,StateMachine.STYPE_CUSTOM_WAIT);
end

function RoomProxy.gotoMoneyMatchRoom(self,roomInfo)
    if UserInfo.getInstance():isFreezeUser() then return end;
    self:setCurRoomType(RoomConfig.ROOM_TYPE_MONEY_MATCH_ROOM);
    self:setCurRoomConfig(RoomConfig.getInstance():getRoomLevelConfig(roomInfo.level))
    self.mMoneyMatchRoomInfo = roomInfo
    StateMachine.getInstance():pushState(States.OnlineRoom,StateMachine.STYPE_CUSTOM_WAIT);
end

function RoomProxy:getMoneyMatchRoomInfo()
    return self.mMoneyMatchRoomInfo
end

function RoomProxy:setMoneyMatchRoomInfo(roomInfo)
    self.mMoneyMatchRoomInfo = roomInfo
end
--[Comment]
-- 职业赛
function RoomProxy.gotoMetierRoom(self,matchId)
    if UserInfo.getInstance():isFreezeUser() then return end;
    local config = RoomConfig.getInstance():getMatchRoomConfig(matchId)
    if not config then return end
    self:setMatchId(matchId)
    self:setCurRoomType(RoomConfig.ROOM_TYPE_METIER_ROOM);
    self:setCurRoomConfig(config)
    self:setIsMatchWatcher(false)
    StateMachine.getInstance():pushState(States.OnlineRoom,StateMachine.STYPE_CUSTOM_WAIT);
end
--[Comment]
-- 职业赛
-- 观战
function RoomProxy.gotoMetierRoomByWatch(self,matchId,tid)
    if UserInfo.getInstance():isFreezeUser() then return end;
    local config = RoomConfig.getInstance():getMatchRoomConfig(matchId)
    if not config then return end
    self:setMatchId(matchId)
    self:setCurRoomType(RoomConfig.ROOM_TYPE_METIER_ROOM);
    self:setCurRoomConfig(config)
    self:setTid(tid)
    self:setIsMatchWatcher(true)
    StateMachine.getInstance():pushState(States.OnlineRoom,StateMachine.STYPE_CUSTOM_WAIT);
end

-- 比赛记录id 用于查询比赛状态
function RoomProxy:setMatchRecordId(matchRecordId)
    self.mMatchRecordId = matchRecordId
end

function RoomProxy:getMatchRecordId()
    return self.mMatchRecordId or 0
end
-- 比赛记录id 用于查询比赛状态
function RoomProxy:setIsMatchWatcher(isWatcher)
    self.mIsWatcher = isWatcher
end

function RoomProxy:isMatchWatcher()
    return self.mIsWatcher or false
end

function RoomProxy.getMatchRoomByMoney(self,money)
    local roomConfig = RoomConfig.getInstance();
    local compareMoney = tonumber(money) or 0;
    local retRoom = nil;
    local data = {};
    data[1] = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_NOVICE_ROOM);
    data[2] = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_INTERMEDIATE_ROOM);
    data[3] = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_MASTER_ROOM);
    for i,room in ipairs(data) do
        if room and compareMoney >= room.minmoney and money < room.maxmoney then
            retRoom = room;
        end
    end
    return retRoom;
end

--能进入场
function RoomProxy.canAccessRoom(self,ctype,money)
    local roomConfig = RoomConfig.getInstance();
    local room = roomConfig:getRoomTypeConfig(ctype);
	if not room or not room.minmoney or not money then
		return false;
	end
	return money >= room.minmoney and money < room.maxmoney;
end 

--能进入场
function RoomProxy.canAccessRoomLevel(self,level,money)
    local roomConfig = RoomConfig.getInstance();
    local room = roomConfig:getRoomLevelConfig(level);
	if not room or not room.minmoney or not money then
		return false;
	end
	return money >= room.minmoney and money < room.maxmoney;
end 

--[Comment]
-- 判断是否破产
function RoomProxy.canCollapseReward(self,money)
    local roomConfig = RoomConfig.getInstance();
	local room = roomConfig:getRoomTypeConfig(RoomConfig.ROOM_TYPE_NOVICE_ROOM);

	if not room or not room.minmoney or not money then
        return	false;
	end
	--是否有满足最低场的最低金额
	return  money < room.minmoney;
end
--[Comment]
-- 判断是否破产
function RoomProxy.checkCanJoinRoom(self,ctype,money)
    local roomConfig = RoomConfig.getInstance();
    local room = roomConfig:getRoomTypeConfig(ctype);

	if not room or not room.minmoney or not money then
        return	false;
	end
    return money >= room.minmoney
end
-- 私人房特有参数 以后进行重构
function RoomProxy.setSelfRoom(self,flag)
    self.mSelfRoom = flag;
end

function RoomProxy.isSelfRoom(self)
    return self.mSelfRoom or false;
end

-- 私人房特有参数 以后进行重构
function RoomProxy.setSelfRoomPassword(self,flag)
    self.mSelfRoomPassword = flag;
end

function RoomProxy.getSelfRoomPassword(self)
    return self.mSelfRoomPassword or "";
end

-- 私人房特有参数 以后进行重构
function RoomProxy.setSelfRoomNameStr(self,flag)
    self.mSelfRoomNameStr = flag;
end

function RoomProxy.getSelfRoomNameStr(self)
    return self.mSelfRoomNameStr or "";
end


-- 房间tid  以后重构到对于房间类里面去
function RoomProxy.setTid(self,tid)
	self.mTid = tid;
end
function RoomProxy.getTid(self)
	return self.mTid or 0;
end

function RoomProxy.setRoomLevel(self,level)
	self.mRoomLevel = level;
end
function RoomProxy.getRoomLevel(self)
	return self.mRoomLevel or 0;
end

-- 比赛id
function RoomProxy.setMatchId(self,matchId)
	self.mMatchId = matchId;
end

function RoomProxy.getMatchId(self)
	return self.mMatchId or 0;
end


--观战SVID
function RoomProxy.setOBSvid(self,obsvid)
	self.m_obsvid = obsvid;
end
function RoomProxy.getOBSvid(self)
	return self.m_obsvid or 0;
end

--[Comment]
--设置当前房间倍数
function RoomProxy.setCurRoomMultiple(self,num)
	self.m_currRoomMutiple = num
end

function RoomProxy.getCurRoomMultiple(self)
	return self.m_currRoomMutiple or 1
end

--[Comment]
--设置好友房是否自己确认时间设置
function RoomProxy:setFriendsAutoSure(isAuto)
    self.mFriendsAutoSure = isAuto
end

function RoomProxy:getFriendsAutoSure(isAuto)
    return self.mFriendsAutoSure or false
end

function RoomProxy.getRoomTypeByMatchId(str)
    if type(str) ~= "string" then return "" end
    local tab = ToolKit.split(str,"|"); 
    return tonumber(tab[1])
end

--[Comment]
-- 追随用户观战
function RoomProxy:followUserByStatus(status)
    if not status then 
        return false,"用户状态未知" 
    end
    local tid,level,matchId = status.tid,status.level,status.matchId
    local matchRoom,noMatchInfo = RoomConfig.getInstance():getMatchRoomConfig(matchId)

    if tid <= 0 then 
        if matchRoom then
            return false,"比赛棋桌还未分配,请稍后再试"
        else
            return false,"用户没在下棋" 
        end
    end

    if noMatchInfo then 
        return false,"操作失败，请再次尝试"
    end

    if matchRoom then 
        local roomType = RoomProxy.getRoomTypeByMatchId(matchId)
        if roomType == RoomConfig.ROOM_TYPE_METIER_ROOM then
            self:gotoMetierRoomByWatch(matchId,tid)
            return true,""
        end
        return false,"该版本不支持此场次"
    end

    local config = RoomConfig.getInstance():getRoomLevelConfig(level)

    if not config then return false,"房间配置不存在" end

    if config.room_type == RoomConfig.ROOM_TYPE_MONEY_MATCH_ROOM then
        ChessToastManager.getInstance():showSingle("该房间不允许观战")
        return false,"该房间不允许观战"
    end
    self:gotoWatchRoom(tid,level)
    return true,""
end

function RoomProxy:setUserWatchMode(ret)
    self.userIsWatchMode = ret
end

function RoomProxy:getUserWatchMode()
    return self.userIsWatchMode or false
end

function RoomProxy:setCurRoomModeIsWatch(flag)
    self.curRoomModeIsWatch = flag
end

function RoomProxy:getCurRoomModeIsWatch(flag)
    return self.curRoomModeIsWatch or false
end


function RoomProxy:setRoomStartTime(time)
    self.curRoomStartTime = tonumber(time) or os.time()
end

function RoomProxy:getRoomStartTime(time)
    return self.curRoomStartTime or os.time()
end

function RoomProxy:sendGetRoomStartTimeCmd()
    OnlineSocketManager.getHallInstance():sendMsg(CLIENT_GET_CUR_TID_START_TIME,{})
end
