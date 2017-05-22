require(NET_PATH.."hall/hallSocketCmd");
require("gameBase/socketReader");

HallSocketReader = class(SocketReader);


HallSocketReader.onHallMsgHeart = function(self,packetId)
    Log.i("==========HallSocketReader.onHallMsgHeart============");
    return;
end;

--大厅登录接口
HallSocketReader.onHallMsgLogin = function(self,packetId)
    local info = {};
 	Log.i("==========HallSocketReader.onHallMsgLogin============");
    info.version = self.m_socket:readInt(packetId, -1);
    info.tid = self.m_socket:readInt(packetId, -1);
    if info.tid > 0 then
        info.ip = self.m_socket:readString(packetId);
        info.port = self.m_socket:readInt(packetId, -1);
        info.level = self.m_socket:readInt(packetId, -1);
        ServerConfig.getInstance():setRoomIpPort(info.ip, info.port);
    end;
	return info;

end

HallSocketReader.onHallMsgGameInfo = function(self,packetId)
    local info = {};
    info.tid = self.m_socket:readInt(packetId, -1);
 	info.svid = self.m_socket:readInt(packetId,-1);  --服务器ID
    UserInfo.getInstance():setTid(info.tid);
    if info.tid > 0 then
        info.ip = self.m_socket:readString(packetId);
        info.port = self.m_socket:readInt(packetId, -1);
        ServerConfig.getInstance():setRoomIpPort(info.ip, info.port);
    end;
    return info;

end

HallSocketReader.onHallMsgGamePlay = function(self,packetId)
  
	local count = self.m_socket:readInt(packetId, -1)
	local info = {};

 	for i=1,count do
		local roomId = self.m_socket:readInt(packetId, -1);
		local playerNum = self.m_socket:readInt(packetId, -1)
		info[i] = playerNum;
	end
    info[count + 1] = self.m_socket:readInt(packetId, -1);
	return info;


end

HallSocketReader.onHallMsgQuickStart = function(self,packetId)
    print_string("======服务器回应快速开始======");

    local info = {};

	info.errorCode = self.m_socket:readShort(packetId, -1);
	info.errorMsg = self.m_socket:readString(packetId );

	info.svid = self.m_socket:readShort(packetId,-1);  --服务器ID
	info.hostIP = self.m_socket:readString(packetId);  --服务器地址
	info.port = self.m_socket:readShort(packetId,-1);      --端口
	info.gameType = self.m_socket:readShort(packetId,-1);   --游戏场类型
	info.ltid = self.m_socket:readShort(packetId,-1);   --棋桌ID
	info.uid = self.m_socket:readInt(packetId,-1);     --用户ID
	-- local moneyType =  self.m_socket:readShort(packetId,-100); --金币场类型

    return info;
end
HallSocketReader.onHallMsgGetRooms = function(self,packetId)
    print_string("=====GetCustomRoomsProc=服务器回应获取成功======");
 	local total =  self.m_socket:readShort(packetId, -1);
 	local count =  self.m_socket:readShort(packetId, -1);

    local info = {};
 	if count >0 then
 		for i=1,count do
 			local room = {};
		  	room.roomID =  self.m_socket:readInt(packetId,-1); --房间ID
		  	room.roomName = self.m_socket:readString(packetId,ERROR_STRING);  --用户昵称
 			room.roomStatus =  self.m_socket:readShort(packetId, -1); --房间状态
 			room.roomCoin =  self.m_socket:readInt(packetId,-1); --房间底注
 			room.TType =  self.m_socket:readShort(packetId, -1); --时间类型
 			room.passwd = self.m_socket:readByte(packetId,ERROR_NUMBER);  --是否需要密码
            room.passWord =  self.m_socket:readString(packetId,ERROR_STRING);--  密码 String 
 			room.redID =  self.m_socket:readInt(packetId,-1); --红方ID
		  	room.redName =  self.m_socket:readString(packetId,ERROR_STRING);   --红方姓名
		  	room.blackID =  self.m_socket:readInt(packetId,-1); --黑方ID
		  	room.blackName =  self.m_socket:readString(packetId,ERROR_STRING);   -- 黑方姓名

		  	if room.roomStatus ~= -1 then 
		  		table.insert(info,room);
		  	end
 		end
 	end
    return info;
end;


HallSocketReader.onHallMsgSearchRoom = function(self, packetId)

    print_string("===HallSearchRoomProc===服务器回应获取成功======");
	local info = {};
 	info.retCode =  self.m_socket:readShort(packetId, -1);

    if info.retCode~=0 then
        return;
    end

 	info.retMsg =  self.m_socket:readString(packetId,ERROR_STRING);
 	info.roomID =  self.m_socket:readInt(packetId,-1); --房间ID
    info.roomName =  self.m_socket:readString(packetId,ERROR_STRING);--房间名称

 	info.roomStatus = self.m_socket:readShort(packetId,-1);--房间状态
	info.roomCoin =  self.m_socket:readInt(packetId,-1);--房间低注
	info.TType =  self.m_socket:readShort(packetId, -1); --时间类型
 	info.passwd = self.m_socket:readByte(packetId,ERROR_NUMBER);  --是否需要密码
    info.passWord =  self.m_socket:readString(packetId,ERROR_STRING);--  密码 String 
 	info.svid =  self.m_socket:readShort(packetId, -1);--服务器ＩＤ
 	info.host =  self.m_socket:readString(packetId,ERROR_STRING);--服务器ip
 	info.port =  self.m_socket:readShort(packetId, -1);--服务器port
 	info.tid =  self.m_socket:readShort(packetId, -1);--服务器port
 	info.redID =  self.m_socket:readInt(packetId,-1); --红方ID
 	info.redName = self.m_socket:readString(packetId,ERROR_STRING);--红方姓名
	info.blackID =  self.m_socket:readInt(packetId,-1); --红方ID
 	info.blackName = self.m_socket:readString(packetId,ERROR_STRING);--黑方姓名

    return info;

    

end;



HallSocketReader.onHallMsgCreateRoom = function(self, packetId)

    local room = {};
  	room.retCode =  self.m_socket:readShort(packetId, -1);

    -- 0 创建成功 其他均不成功
    if room.retCode~=0 then
--        EventDispatcher.getInstance():dispatch(Event.Call, ONLINE_CREATE_CUSTOMROOM_FAIL,room);
        return;
    end
    print_string("eeeeee响应创建自定义房间  "..UserInfo.getInstance():getUid()..": "..UserInfo.getInstance():getIcon().."eeeeee");
 	room.retMsg =  self.m_socket:readString(packetId,ERROR_STRING);
 	room.roomID =  self.m_socket:readInt(packetId,-1); --房间ID
 	room.svid =  self.m_socket:readShort(packetId, -1);
 	room.host =  self.m_socket:readString(packetId,ERROR_STRING);
 	room.port =  self.m_socket:readShort(packetId, -1);
    room.tid =  self.m_socket:readShort(packetId, -1);

    return room;




end;



HallSocketReader.onHallMsgCancelMatch = function(self,packetId)
    
    local info = {};

    info.errorCode = self.m_socket:readShort(packetId, -1);
 	info.errorMsg = self.m_socket:readString(packetId );

    return info;
end

HallSocketReader.onHallMsgKickUser = function(self,packetId)
    local info = {};

    return info;
end


HallSocketReader.onClientMsgRelogin = function(self, packetId)

    print_string("======服务器回应房间CLIENT_MSG_RELOGIN======");
	local info = {};
    info.errorCode = self.m_socket:readShort(packetId,ERROR_NUMBER);  --错误码 0   成功 -1  Tid 不合法，找不到棋桌 -2  棋局已经结束，用户不在棋桌

	info.errorMsg = self.m_socket:readString(packetId,ERROR_STRING); --错误信息
    
    

	info.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);          --  用户ID

	info.tableID = self.m_socket:readShort(packetId,ERROR_NUMBER);     --棋桌ID 

	info.bycoin = self.m_socket:readInt(packetId,ERROR_NUMBER);            -- 元宝 
	info.Count = self.m_socket:readShort(packetId,ERROR_NUMBER);          --一局棋最多悔棋次数 
	info.useBYCoinTb = {};

	for i=1,info.Count do
		info.tb = {};
		info.useBYCoin = self.m_socket:readShort(packetId,ERROR_NUMBER);          	--当前悔棋次数要用到的元宝数 
		info.opponentgetCoin = self.m_socket:readInt(packetId,ERROR_NUMBER);          -- 对手被强制悔棋获得金币数 
		
		info.tb.useBYCoin = info.useBYCoin;
		info.tb.opponentgetCoin = info.opponentgetCoin;
		table.insert(info.useBYCoinTb,info.tb);
	end
    print_string("======服务器回应房间CLIENT_MSG_RELOGIN处理成功======");
    return info;    

end;

HallSocketReader.onClientMsgGiveup  = function(self, packetId)

    local info = {};
	info.errorCode = self.m_socket:readShort(packetId,ERROR_NUMBER);  
	info.errorMsg = self.m_socket:readString(packetId,ERROR_STRING);


    return info;

end;

HallSocketReader.onHallMsgServerPush = function(self, packetId)
    print_string("=========HallServerPushProc服务器推送=========");

 	local uid = self.m_socket:readInt(packetId,-1);--用户ID	Int	4	
 	local retCode = self.m_socket:readShort(packetId, -1); --	-1， 为购买不成功，1为金币购买成功，2为元宝购买成功，3为其他
    
    local info = {};
 	if retCode == 1 then
 		local coin = self.m_socket:readInt(packetId,-1);--金币	Int	4	
 		local bycoin = self.m_socket:readInt(packetId,-1);--	元宝	Int	4	
 		local dealno = self.m_socket:readString(packetId);--订单号
 		local chess_soul_num = self.m_socket:readInt(packetId,-1);--	棋魂	Int	4	
		
		local payLogs = {};
		payLogs.type = 1;
 		payLogs.money = coin or 0;
 		payLogs.bycoin = bycoin or 0;
 		payLogs.dealno = dealno or 0;
 		payLogs.chess_soul_num = chess_soul_num or 0;

		-- print_string("=============payLogs.money ====="..payLogs.money);
		-- print_string("=============payLogs.bycoin ====="..payLogs.bycoin);
		-- print_string("=============payLogs.dealno ====="..payLogs.dealno);
		-- print_string("=============payLogs.chess_soul_num ====="..payLogs.chess_soul_num);
        info = payLogs;
 	elseif retCode == 2 then
 		local orderData = self.m_socket:readString(packetId);--订单号
		local payLogs = {};
		payLogs.type = 2;
		-- print_string("=============orderData====="..orderData);
		payLogs.orderData = orderData;
		local proplist = json.decode(orderData);
		
		if proplist then
			for _,value in pairs(proplist) do 
				local paylog = {};
				if value.pid then
					paylog.pid = value.pid;
				end
				if value.propid then
					paylog.propid = tonumber(value.propid) or 0;
				end
				if value.num then
					paylog.num = tonumber(value.num) or 0;
				end
				table.insert(payLogs,paylog)
			end
		end
        info = payLogs;
	elseif retCode == 3 then
		local data = {};
		local retStr = self.m_socket:readString(packetId);--
		data.type = 3;

		local result = json.decode(retStr);
		if result and result ~= "" then
			data.mid = result.mid;
			data.reward = result.reward;
			data.img = result.img;

			if string.len(data.mid)>5 then
				local endStr = string.sub(data.mid, -1);
				data.mid = string.sub(data.mid, 1, -3) 
				data.mid = data.mid.."XX"..endStr;
			end
			
			-- print_string("=======result.mid======="..result.mid);
			-- print_string("=======result.reward======="..result.reward);
			-- print_string("=======result.img======="..result.img);
            info = data;
		end
	end
    return info;
end

HallSocketReader.onRecvClientWatchLogin = function(self, packetId)
    print_string("======服务器回应房间登陆======");
	local errorCode = self.m_socket:readShort(packetId,ERROR_NUMBER);  --0 正常登录成功  1 已经在此棋桌观战 -1  不成功  
	local errorMsg  = self.m_socket:readString(packetId,ERROR_STRING); --错误信息
	


	local seatID = self.m_socket:readShort(packetId,ERROR_NUMBER);          --座位ID
	local obSID  = self.m_socket:readShort(packetId,ERROR_NUMBER);          --观战服务器ID
	local obTid  = self.m_socket:readShort(packetId,ERROR_NUMBER);          --观战服务器TID

    local info = {};
	if errorCode == 0 or  errorCode == 1 then

		UserInfo.getInstance():setOBSvid(obSID);
		UserInfo.getInstance():setTid(obTid);
		UserInfo.getInstance():setSeatID(seatID);
	else
		return info;
	end

    


	info.tableID = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 棋桌ID
	info.tableStatus = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 棋局状态

	info.gameType = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 棋局类型
	info.cType = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 金币场类型

	info.timeOut1 = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 局时（秒）棋局设置的局时
	info.timeOut2 = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 步时（秒）棋局设置的步时
	info.timeOut3 = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 读秒（秒）棋局设置的读秒


	info.chess_map = {}
	for i = 90,1,-1 do
		info.chess_map[i] = self.m_socket:readByte(packetId,ERROR_NUMBER);        --整盘棋局
	end

	info.chessMan = self.m_socket:readShort(packetId,ERROR_NUMBER);     --最后一步棋子
	info.position1 = self.m_socket:readShort(packetId,ERROR_NUMBER);     --当前位置
	info.position2 = self.m_socket:readShort(packetId,ERROR_NUMBER);     --移动位置


	--玩家1的信息
	local player1ID = self.m_socket:readInt(packetId,ERROR_NUMBER); -- Player1用户ID
	local player1Name = self.m_socket:readString(packetId); -- Player1用户姓名
	local player1Score = self.m_socket:readInt(packetId,ERROR_NUMBER); -- Player1分数
	local player1Coin = self.m_socket:readInt(packetId,ERROR_NUMBER);   --Player1金币
	local player1Sex = self.m_socket:readShort(packetId,ERROR_NUMBER);   -- Player1性别0未知，1男性，2女性
	local player1Wintimes = self.m_socket:readInt(packetId,ERROR_NUMBER);  --player1赢棋盘数
	local player1Losetimes = self.m_socket:readInt(packetId,ERROR_NUMBER);  --player1输棋盘数
	local player1Drawtimes = self.m_socket:readInt(packetId,ERROR_NUMBER);   --Player1和棋盘数
	local player1Icon = self.m_socket:readString(packetId);   --Player1头像链接
	local player1Sitemid = self.m_socket:readString(packetId);--Player1平台ID
	local player1Platurl = self.m_socket:readString(packetId);--Player1平台链接
	local player1Version = self.m_socket:readString(packetId);--Player1版本号
	local player1Source = self.m_socket:readShort(packetId,ERROR_NUMBER);   --player1来源
	local player1Status = self.m_socket:readShort(packetId,ERROR_NUMBER); -- Player1状态
	local player1Flag = self.m_socket:readShort(packetId,ERROR_NUMBER); -- Player1红黑标志 1红方、2黑方
	local player1Auth = self.m_socket:readShort(packetId,ERROR_NUMBER);   --1 个人加V 2 非个人加V 3 达人 0 没有身份 -1 没有身份
	local player1Rank1 = self.m_socket:readInt(packetId,ERROR_NUMBER);   --当前排名  -1则为得不到当前排名
	local player1Title = self.m_socket:readString(packetId);  --Player1等级头衔
	local player1timeOut1 = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 局时（秒）已用的局时
	local player1timeOut2 = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 步时（秒）剩余的步时
	local player1timeOut3 = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 读秒（秒）剩余的读秒


	--玩家2的信息
	local player2ID = self.m_socket:readInt(packetId,ERROR_NUMBER); -- Player1用户ID
	local player2Name = self.m_socket:readString(packetId); -- Player1用户姓名
	local player2Score = self.m_socket:readInt(packetId,ERROR_NUMBER); -- Player1分数
	local player2Coin = self.m_socket:readInt(packetId,ERROR_NUMBER);   --Player1金币
	local player2Sex = self.m_socket:readShort(packetId,ERROR_NUMBER);   -- Player1性别0未知，1男性，2女性
	local player2Wintimes = self.m_socket:readInt(packetId,ERROR_NUMBER);  --player1赢棋盘数
	local player2Losetimes = self.m_socket:readInt(packetId,ERROR_NUMBER);  --player1输棋盘数
	local player2Drawtimes = self.m_socket:readInt(packetId,ERROR_NUMBER);   --Player1和棋盘数
	local player2Icon = self.m_socket:readString(packetId);   --Player1头像链接
	local player2Sitemid = self.m_socket:readString(packetId);--Player1平台ID
	local player2Platurl = self.m_socket:readString(packetId);--Player1平台链接
	local player2Version = self.m_socket:readString(packetId);--Player1版本号
	local player2Source = self.m_socket:readShort(packetId,ERROR_NUMBER);   --player1来源
	local player2Status = self.m_socket:readShort(packetId,ERROR_NUMBER); -- Player1状态
	local player2Flag = self.m_socket:readShort(packetId,ERROR_NUMBER); -- Player1红黑标志 1红方、2黑方
	local player2Auth = self.m_socket:readShort(packetId,ERROR_NUMBER);   --1 个人加V 2 非个人加V 3 达人 0 没有身份 -1 没有身份
	local player2Rank1 = self.m_socket:readInt(packetId,ERROR_NUMBER);   --当前排名  -1则为得不到当前排名
	local player2Title = self.m_socket:readString(packetId);  --Player1等级头衔
	local player2timeOut1 = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 局时（秒）已用的局时
	local player2timeOut2 = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 步时（秒）剩余的步时
	local player2timeOut3 = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 读秒（秒）剩余的读秒

	play1 = new(User) ;
	play1:setUid(player1ID);
	play1:setName(player1Name);
	play1:setScore(player1Score);
	play1:setMoney(player1Coin);
	play1:setSex(player1Sex);
	play1:setWintimes(player1Wintimes);
	play1:setLosetimes(player1Losetimes);
	play1:setDrawtimes(player1Drawtimes);
	play1:setIcon(player1Icon,player1ID);
	play1:setSitemid(player1Sitemid);
	play1:setPlaturl(player1Platurl);
	play1:setVersion(player1Version);
	play1:setSource(player1Source);
	play1:setStatus(player1Status);
	play1:setFlag(player1Flag);
	play1:setAuth(player1Auth);
	play1:setRank(player1Rank1);
	play1:setTitle(player1Title);
	play1:setTimeout1((info.timeOut1 - player1timeOut1));
	play1:setTimeout2(player1timeOut2);
	play1:setTimeout3(player1timeOut3);
--    play1:setVip(player1);
    
    info.player1 = play1;
    


	play2 = new(User) ;
	play2:setUid(player2ID);
	play2:setName(player2Name);
	play2:setScore(player2Score);
	play2:setMoney(player2Coin);
	play2:setSex(player2Sex);
	play2:setWintimes(player2Wintimes);
	play2:setLosetimes(player2Losetimes);
	play2:setDrawtimes(player2Drawtimes);
	play2:setIcon(player2Icon,player2ID);
	play2:setSitemid(player2Sitemid);
	play2:setPlaturl(player2Platurl);
	play2:setVersion(player2Version);
	play2:setSource(player2Source);
	play2:setStatus(player2Status);
	play2:setFlag(player2Flag);
	play2:setAuth(player2Auth);
	play2:setRank(player2Rank1);
	play2:setTitle(player2Title);
	play2:setTimeout1((info.timeOut1 - player2timeOut1));
	play2:setTimeout2(player2timeOut2);
	play2:setTimeout3(player2timeOut3);
--    play2:setVip(player2);

    info.player2 = play2;

    return info;

end;


HallSocketReader.onRecvClientWatchSynData = function(self, packetId)
	local errorCode = self.m_socket:readShort(packetId,ERROR_NUMBER);  --0 正常登录成功  1 已经在此棋桌观战 -1  不成功  
	local errorMsg  = self.m_socket:readString(packetId,ERROR_STRING); --错误信息
    local info = {};
    if errorCode < 0 then
        return info;
    end;
    return self:onRecvClientWatchLogin(packetId);


end;

HallSocketReader.onRecvClientWatchChat = function(self, packetId)
    local info = {};
    info.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);  --uid 
	info.tid  = self.m_socket:readInt(packetId,ERROR_NUMBER); --tid
    info.name = self.m_socket:readString(packetId,ERROR_STRING);
    info.msgType = 1;
    info.message = self.m_socket:readString(packetId,ERROR_STRING);--msg
    return info;

end;


HallSocketReader.onRecvClientMsgLogin = function(self, packetId)

    print_string("======服务器回应房间登陆======");
    local info = {};
	info.errorCode = self.m_socket:readShort(packetId,ERROR_NUMBER);  --0 正常登录成功   1 断线重连成功 -1  Tid 不合法，找不到棋桌  -2  棋局已经结束，用户不在棋桌
	info.errorMsg = self.m_socket:readString(packetId,ERROR_STRING); --错误信息
    info.name = self.m_socket:readString(packetId,ERROR_STRING);     --用户昵称
	info.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);            --用户ID
	info.score = self.m_socket:readInt(packetId,ERROR_NUMBER);          --经验值
	info.level = self.m_socket:readShort(packetId,ERROR_NUMBER);          --等级
	info.status = self.m_socket:readShort(packetId,ERROR_NUMBER);     --用户状态  0 未登录  1已登录 2入座 3等待开局   3正在对弈 4 结束对弈
--    info.is_vip = self.m_socekt:readString(packetId,ERROR_STRING);
	info.bycoin = self.m_socket:readInt(packetId,ERROR_NUMBER);            -- 元宝 
	info.Count = self.m_socket:readShort(packetId,ERROR_NUMBER);          --一局棋最多悔棋次数 
	info.useBYCoinTb = {};

	for i=1,info.Count do
		info.tb = {};
		info.useBYCoin = self.m_socket:readShort(packetId,ERROR_NUMBER);          	  --当前悔棋次数要用到的元宝数 
		info.opponentgetCoin = self.m_socket:readInt(packetId,ERROR_NUMBER);          -- 对手被强制悔棋获得金币数 
		info.tb.useBYCoin = info.useBYCoin;
		info.tb.opponentgetCoin = info.opponentgetCoin;
		table.insert(info.useBYCoinTb,info.tb);
	end

    return info;
	
end;

HallSocketReader.onRecvClientMsgLoginSuccess = function(self, packetId)
   local info = {};
   local roomlevel = self.m_socket:readInt(packetId,-1);--房间等级
   local basechip = self.m_socket:readInt(packetId,-1);--底注
   local money  = self.m_socket:readInt(packetId,-1);--金币
   local score = self.m_socket:readInt(packetId,-1);--积分
   local is_opp = self.m_socket:readInt(packetId,-1);--对手是否存在,0不存在，1存在
   if is_opp == 1 then 
        local opp_id = self.m_socket:readInt(packetId,-1);--对手id
        local opp_money = self.m_socket:readInt(packetId,-1);
        local opp_score = self.m_socket:readInt(packetId,-1);
        local opp_userInfo = self.m_socket:readString(packetId,-1);--对手信息
        local user = new(User);
        userInfo_str = json.decode(opp_userInfo);
        user:setUid(userInfo_str.uid);
		user:setName(userInfo_str.user_name);
		user:setScore(userInfo_str.score);
		user:setLevel(userInfo_str.level);
		user:setIcon(userInfo_str.icon,userInfo_str.uid);
		user:setSex(userInfo_str.sex);
		user:setWintimes(userInfo_str.wintimes);
		user:setLosetimes(userInfo_str.losetimes);
		user:setDrawtimes(userInfo_str.drawtimes);
		user:setSource(userInfo_str.source);
		user:setSitemid(userInfo_str.sitemid);
		user:setPlaturl(userInfo_str.platurl);
		user:setRank(userInfo_str.rank);
		user:setAuth(userInfo_str.auth);
		user:setMoney(userInfo_str.money);
        user:setVip(userInfo_str.is_vip);
        user:setVersion(userInfo_str.version);
        user:setClient_version(userInfo_str.client_version);
        info.user = user;
        
   end;

   return info

end;


HallSocketReader.onRecvServerMsgLoginError = function(self,packetId)
    Log.i("HallSocketReader.onRecvServerMsgLoginError");
    local info = {};
    info.errorCode = self.m_socket:readInt(packetId,-1);
    return info;
end;


HallSocketReader.onRecvServerMsgOtherError = function(self,packetId)
    Log.i("HallSocketReader.onRecvServerMsgOtherError");
    local info = {};
    info.errorCode = self.m_socket:readInt(packetId,-1);
    return info;
end;



HallSocketReader.onRecvClientMsgOppUserInfo = function(self, packetId)
    local info = {};
    local opp_uid = self.m_socket:readInt(packetId,-1);
    local opp_money = self.m_socket:readInt(packetId,-1);
    local opp_score = self.m_socket:readInt(packetId,-1);
    local opp_user = self.m_socket:readString(packetId);
    local user = new(User);
    userInfo_str = json.decode(opp_user);
    user:setUid(userInfo_str.uid);
	user:setName(userInfo_str.user_name);
	user:setScore(userInfo_str.score);
	user:setLevel(userInfo_str.level);
	user:setIcon(userInfo_str.icon,userInfo_str.uid);
	user:setSex(userInfo_str.sex);
	user:setWintimes(userInfo_str.wintimes);
	user:setLosetimes(userInfo_str.losetimes);
	user:setDrawtimes(userInfo_str.drawtimes);
	user:setSource(userInfo_str.source);
	user:setSitemid(userInfo_str.sitemid);
	user:setPlaturl(userInfo_str.platurl);
	user:setRank(userInfo_str.rank);
	user:setAuth(userInfo_str.auth);
	user:setMoney(userInfo_str.money);
    user:setVip(userInfo_str.is_vip);
    user:setVersion(userInfo_str.version);
    user:setClient_version(userInfo_str.client_version);
    info.user = user;
    
    return info;

end;

HallSocketReader.onRecvServerMsgUserReady = function(self, packetId)
    local info = {};
    local uid = self.m_socket:readInt(packetId,-1);
    info.uid = uid;

    return info;

end;

HallSocketReader.onRecvServerMsgGameStart = function(self, packetId)
    local info = {};
    info.round_time = self.m_socket:readShort(packetId,-1);--局时
    info.step_time = self.m_socket:readShort(packetId,-1);--步时
    info.sec_time = self.m_socket:readShort(packetId,-1);--读秒
    info.uid1 =  self.m_socket:readInt(packetId,-1);--玩家1 uid
    info.uid1_money = self.m_socket:readInt(packetId,-1);--玩家1金币
    info.flag1 =  self.m_socket:readShort(packetId,-1);--玩家1红黑标志
    info.uid2 =  self.m_socket:readInt(packetId,-1);--玩家2 uid
    info.uid2_money = self.m_socket:readInt(packetId,-1);--玩家1金币
    info.flag2 =  self.m_socket:readShort(packetId,-1);--玩家2红黑标志
    info.chess_map = {}
	for i = 90,1,-1 do
		info.chess_map[i] = self.m_socket:readByte(packetId,ERROR_NUMBER);--整盘棋局
	end
    return info;

end;

HallSocketReader.onRecvServerMsgTimeCountStart = function(self, packetId)
    local info = {};
    info.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);--开始走棋的uid
    info.multiply = self.m_socket:readInt(packetId,ERROR_NUMBER);--棋局倍数
    info.chess_map = {}
	for i = 90,1,-1 do
		info.chess_map[i] = self.m_socket:readByte(packetId,ERROR_NUMBER);--整盘棋局
	end
    return info;
end;


HallSocketReader.onRecvServerMsgReconnect = function(self, packetId)
    local info = {};

    info.room_level = self.m_socket:readInt(packetId,ERROR_NUMBER); --房间场
    info.base_chip = self.m_socket:readInt(packetId,ERROR_NUMBER); --底注
    info.coin = self.m_socket:readInt(packetId,ERROR_NUMBER);   --自己金币
    info.score = self.m_socket:readInt(packetId,ERROR_NUMBER); -- 自己积分
    info.flag = self.m_socket:readInt(packetId,ERROR_NUMBER); -- 红黑标志

    info.status = self.m_socket:readShort(packetId,ERROR_NUMBER); --棋局状态,1,棋局结束，2，正在对弈，3，抢先，4，让子
    info.first_flag = self.m_socket:readShort(packetId,ERROR_NUMBER); --先手方，1红棋先走，2黑棋先手
    info.multiply = self.m_socket:readShort(packetId,ERROR_NUMBER); --倍数
    info.round_time = self.m_socket:readShort(packetId,ERROR_NUMBER); --局时
    info.step_time = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 步时
    info.sec_time = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 读秒


    info.is_opp = self.m_socket:readInt(packetId,ERROR_NUMBER); --是否有对手
    if 1 == info.is_opp then
        info.opp_uid = self.m_socket:readInt(packetId,ERROR_NUMBER);--对手uid
        info.opp_money = self.m_socket:readInt(packetId,ERROR_NUMBER);--对手金币
        info.opp_score = self.m_socket:readInt(packetId,ERROR_NUMBER); --对手积分
        info.opp_flag = self.m_socket:readInt(packetId,ERROR_NUMBER); --对手红黑标志
        info.opp_user = self.m_socket:readString(packetId,ERROR_NUMBER); --对手信息    
        local user = new(User);
        local opp_user_str = json.decode(info.opp_user);
	    user:setUid(opp_user_str.uid);
	    user:setName(opp_user_str.user_name);
	    user:setScore(opp_user_str.score);
	    user:setLevel(opp_user_str.level);
	    user:setFlag(info.opp_flag);
	    user:setIcon(opp_user_str.icon,opp_user_str.uid);
	    user:setSex(opp_user_str.sex);
	    user:setWintimes(opp_user_str.wintimes);
	    user:setLosetimes(opp_user_str.losetimes);
	    user:setDrawtimes(opp_user_str.drawtimes);
	    user:setSource(opp_user_str.source);
	    user:setSitemid(opp_user_str.sitemid);
	    user:setPlaturl(opp_user_str.platurl);
	    user:setRank(opp_user_str.rank);
	    user:setAuth(opp_user_str.auth);
	    user:setMoney(opp_user_str.money);
        user:setVip(opp_user_str.is_vip);
        user:setVersion(opp_user_str.version);
        user:setClient_version(opp_user_str.client_version);
        --游戏还没有正式开始退出重连，设置时间都是默认值
        user:setTimeout1((info.round_time));
	    user:setTimeout2(info.step_time);
	    user:setTimeout3(info.sec_time);
        if info.status == 2 then--正在对弈
            --自己所剩时间
            info.round_timeout = self.m_socket:readShort(packetId,ERROR_NUMBER); --局时
            info.step_timeout = self.m_socket:readShort(packetId,ERROR_NUMBER); --步时
            info.sec_timeout = self.m_socket:readShort(packetId,ERROR_NUMBER); --读秒

            --对手所剩时间
            info.opp_round_timeout = self.m_socket:readShort(packetId,ERROR_NUMBER); --局时
            info.opp_step_timeout = self.m_socket:readShort(packetId,ERROR_NUMBER); --步时
            info.opp_sec_timeout = self.m_socket:readShort(packetId,ERROR_NUMBER); --读秒        
        
            info.chess_map = {}
            for i = 90,1,-1 do
	            info.chess_map[i] = self.m_socket:readByte(packetId,ERROR_NUMBER);        --整盘棋局
            end
        
            info.chessMan = self.m_socket:readShort(packetId,ERROR_NUMBER);     --棋子
            info.position1 = self.m_socket:readShort(packetId,ERROR_NUMBER);     --当前位置
            info.position2 = self.m_socket:readShort(packetId,ERROR_NUMBER);     --移动位置

            user:setTimeout1((info.round_time - info.opp_round_timeout));
	        user:setTimeout2(info.opp_step_timeout);
	        user:setTimeout3(info.opp_sec_timeout);

--            info.opp_is_back = self.m_socket:readInt(packetId,ERROR_NUMBER);   -- 对手是否进入后台：0 对手在前台 1 对手在后台
--            info.opp_wait_time = self.m_socket:readInt(packetId,ERROR_NUMBER); -- 对手在后台是时间

        elseif info.status == 3 then--抢先状态



        elseif info.status == 4 then--让子状态


        end;


	    info.user = user;

        
    else
        --不存在对手,发送退出房间请求

    end;

    return info;

end;

HallSocketReader.onRecvServerMsgLogoutSuccess = function(self)
    Log.i("HallSocketReader.onRecvServerMsgLogoutSuccess");

end;


HallSocketReader.onRecvServerMsgLogoutFail = function(self,packetId)
    Log.i("HallSocketReader.onRecvServerMsgLogoutFail");
    local info = {};
    info.errCode = self.m_socket:readInt(packetId,999);
    Log.i("HallSocketReader.onRecvServerMsgLogoutFail and info.errCode = "..info.errCode);
end;

HallSocketReader.onRecvServerMsgUserLeave = function(self, packetId)
   Log.i("HallSocketReader.onRecvServerMsgUserLeave"); 
   local info = {};

   info.leave_uid = self.m_socket:readInt(packetId,ERROR_NUMBER);

   return info;
end;


HallSocketReader.onRecvServerMsgForestall = function(self, packetId)
   Log.i("HallSocketReader.onRecvServerMsgForestall");  
   local info = {};

   info.pre_call_uid = self.m_socket:readInt(packetId,ERROR_NUMBER);
   info.curr_uid = self.m_socket:readInt(packetId,ERROR_NUMBER);
   info.multiply = self.m_socket:readInt(packetId,ERROR_NUMBER);
   info.timeout = self.m_socket:readInt(packetId,ERROR_NUMBER);

   return info;
end;

HallSocketReader.onRecvServerMsgForestallNew = function(self, packetId)
   Log.i("HallSocketReader.onRecvServerMsgForestallNew");  
   local info = {};

   info.pre_call_uid = self.m_socket:readInt(packetId,ERROR_NUMBER);--上一个抢先id,=0不存在
   info.pre_call_uid_act = self.m_socket:readInt(packetId,ERROR_NUMBER);--=0取消, !=0为实际倍数
   info.curr_uid = self.m_socket:readInt(packetId,ERROR_NUMBER);--当前抢先id
   info.curr_beishu = self.m_socket:readShort(packetId,ERROR_NUMBER);--抢先到计时
   info.timeout = self.m_socket:readShort(packetId,ERROR_NUMBER);--当前倍数
   info.opt_beishu1 = self.m_socket:readShort(packetId,ERROR_NUMBER);--可选择倍数
   info.opt_beishu2 = self.m_socket:readShort(packetId,ERROR_NUMBER);--可选择倍数
   info.byMultiplyBtn = self.m_socket:readByte(packetId,ERROR_NUMBER);-- 翻倍按钮状态
   return info;
end;

HallSocketReader.onRecvServerMsgHandicap = function(self, packetId)
    Log.i("HallSocketReader.onRecvServerMsgHandicap");  
    local info = {};

    info.red_uid = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.multiply = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.timeout = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.count = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.chesses = {};
    for index = 1,info.count do
	    local chess = {};
	    chess.chessID = self.m_socket:readShort(packetId,ERROR_NUMBER); --棋子ID
	    chess.times = self.m_socket:readShort(packetId,ERROR_NUMBER); --此棋子的倍数
	    table.insert(info.chesses,chess);
    end
    info.byMultiplyBtn = self.m_socket:readByte(packetId,ERROR_NUMBER); -- 翻倍按钮状态
    info.baseMoney = self.m_socket:readInt(packetId,ERROR_NUMBER); -- 底注
    return info;
end;

HallSocketReader.onRecvServerMsgHandicapResult = function(self, packetId)
    Log.i("HallSocketReader.onRecvServerMsgHandicapResult");  
    local info = {};    
    info.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.result = self.m_socket:readShort(packetId,ERROR_NUMBER);
    info.chessId = self.m_socket:readShort(packetId,ERROR_NUMBER);

    return info;

end;


HallSocketReader.onRecvServerMsgCancelMatch = function(self, packetId)
    Log.i("HallSocketReader.onRecvServerMsgCancelMatch");     
    local info = {};    
    info.ret = self.m_socket:readInt(packetId,ERROR_NUMBER);
    return info;

end;



HallSocketReader.onRecvClientWatchList = function(self, packetId)
    Log.i("HallSocketReader.onRecvClientWatchList");  
    local info = {};        
    info.version = self.m_socket:readByte(packetId,ERROR_NUMBER);
    info.total_count = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.total_page = self.m_socket:readShort(packetId,ERROR_NUMBER);
    info.curr_page = self.m_socket:readShort(packetId,ERROR_NUMBER);
    info.item_num = self.m_socket:readShort(packetId,ERROR_NUMBER);
    info.watch_items = {};
    for index = 1, info.item_num do
        local watch_item = {};
        watch_item.tid = self.m_socket:readInt(packetId,ERROR_NUMBER);
        watch_item.red_uid = self.m_socket:readInt(packetId,ERROR_NUMBER);
        watch_item.red_info = self.m_socket:readString(packetId,ERROR_NUMBER);
        watch_item.black_uid = self.m_socket:readInt(packetId,ERROR_NUMBER);
        watch_item.black_info = self.m_socket:readString(packetId,ERROR_NUMBER);
        watch_item.ob_num = self.m_socket:readInt(packetId,ERROR_NUMBER);
        watch_item.play_time = self.m_socket:readInt(packetId,ERROR_NUMBER);
        table.insert(info.watch_items,watch_item);
    end;

    return info;
end;

HallSocketReader.onRecvClientWatchJoin = function(self, packetId)
    Log.i("HallSocketReader.onRecvClientWatchJoin");  
    local info = {};
    info.ret = self.m_socket:readInt(packetId,ERROR_NUMBER); --=0，成功, =1,不存在，=2,其他错误
    if info.ret == 0 then
        info.tid = self.m_socket:readInt(packetId,ERROR_NUMBER);--棋桌id
        info.status = self.m_socket:readShort(packetId,ERROR_NUMBER);--状态
        info.curr_move_flag = self.m_socket:readShort(packetId,ERROR_NUMBER);--当前走棋方
    
        info.round_time = self.m_socket:readInt(packetId,ERROR_NUMBER); --局时
        info.step_time = self.m_socket:readInt(packetId,ERROR_NUMBER);--步时
        info.sec_time = self.m_socket:readInt(packetId,ERROR_NUMBER); --读秒
 
        info.red_uid = self.m_socket:readInt(packetId,ERROR_NUMBER);--红方uid
        info.red_user = self.m_socket:readString(packetId);--红方user信息



        info.black_uid = self.m_socket:readInt(packetId,ERROR_NUMBER);--黑方uid
        info.black_user = self.m_socket:readString(packetId);--黑方user信息

        if info.status == 2 then--server逻辑，只有在状态2（playing）才有下面信息
            info.red_round_timeout = self.m_socket:readShort(packetId,ERROR_NUMBER);   --红方已用局时
            info.red_step_timeout = self.m_socket:readShort(packetId,ERROR_NUMBER);    --红方剩余步时
            info.red_sec_timeout = self.m_socket:readShort(packetId,ERROR_NUMBER);     --红方剩余读秒
            info.black_round_timeout = self.m_socket:readShort(packetId,ERROR_NUMBER); --黑方已用局时
            info.black_step_timeout = self.m_socket:readShort(packetId,ERROR_NUMBER);  --黑方剩余步时
            info.black_sec_timeout = self.m_socket:readShort(packetId,ERROR_NUMBER);   --黑方剩余读秒
     

	        info.chess_map = {}
	        for i = 90,1,-1 do
		        info.chess_map[i] = self.m_socket:readByte(packetId,ERROR_NUMBER);--整盘棋局
	        end    

            info.chessMan = self.m_socket:readShort(packetId,ERROR_NUMBER);     --棋子
            info.position1 = self.m_socket:readShort(packetId,ERROR_NUMBER);     --当前位置
            info.position2 = self.m_socket:readShort(packetId,ERROR_NUMBER);     --移动位置
        end;


        local user = new(User);
        local red_user = json.decode(info.red_user);
	    user:setUid(red_user.uid);
	    user:setName(red_user.user_name);
	    user:setScore(red_user.score);
	    user:setLevel(red_user.level);
	    user:setFlag(FLAG_RED);
	    user:setIcon(red_user.icon,red_user.uid);
	    user:setSex(red_user.sex);
	    user:setWintimes(red_user.wintimes);
	    user:setLosetimes(red_user.losetimes);
	    user:setDrawtimes(red_user.drawtimes);
	    user:setSource(red_user.source);
	    user:setSitemid(red_user.sitemid);
	    user:setPlaturl(red_user.platurl);
	    user:setRank(red_user.rank);
	    user:setAuth(red_user.auth);
	    user:setMoney(red_user.money);
        user:setTimeout1((info.round_time - (info.red_round_timeout or 0)));
	    user:setTimeout2(info.red_step_timeout or 0);
	    user:setTimeout3(info.red_sec_timeout or 0);
        user:setVip(red_user.is_vip);
        user:setVersion(red_user.version);
        user:setClient_version(red_user.client_version);

        info.player1 = user;


        local user = new(User);
        local black_user = json.decode(info.black_user);
	    user:setUid(black_user.uid);
	    user:setName(black_user.user_name);
	    user:setScore(black_user.score);
	    user:setLevel(black_user.level);
	    user:setFlag(FLAG_BLACK);
	    user:setIcon(black_user.icon,black_user.uid);
	    user:setSex(black_user.sex);
	    user:setWintimes(black_user.wintimes);
	    user:setLosetimes(black_user.losetimes);
	    user:setDrawtimes(black_user.drawtimes);
	    user:setSource(black_user.source);
	    user:setSitemid(black_user.sitemid);
	    user:setPlaturl(black_user.platurl);
	    user:setRank(black_user.rank);
	    user:setAuth(black_user.auth);
	    user:setMoney(black_user.money);
        user:setTimeout1((info.round_time - (info.black_round_timeout or 0)));
	    user:setTimeout2(info.black_step_timeout or 0);
	    user:setTimeout3(info.black_sec_timeout or 0);
        user:setVip(black_user.is_vip);
        user:setVersion(black_user.version);
        user:setClient_version(black_user.client_version);
        info.player2 = user;


        return info;
    else
        return;
    end;
end;


HallSocketReader.onRecvServerWatchStart = function(self, packetId)
    local info = {};

	info.tid = self.m_socket:readInt(packetId,ERROR_NUMBER);     --棋桌ID 
	info.status = self.m_socket:readInt(packetId,ERROR_NUMBER);     --棋桌状态

	info.round_time = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 局时（秒）
	info.step_time = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 步时（秒）
	info.sec_time = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 读秒（秒）

	info.red_uid = self.m_socket:readInt(packetId,ERROR_NUMBER);          
	info.black_uid = self.m_socket:readInt(packetId,ERROR_NUMBER);          


	info.chess_map = {}
	for i = 90,1,-1 do
		info.chess_map[i] = self.m_socket:readByte(packetId,ERROR_NUMBER);        --整盘棋局
	end
	return info;    
end;



HallSocketReader.onRecvServerWatchMove = function(self, packetId)
    local info = {};
	info.tid = self.m_socket:readInt(packetId,ERROR_NUMBER);     --棋桌ID 
	info.status = self.m_socket:readInt(packetId,ERROR_NUMBER);     --棋桌状态    
    info.last_move_uid = self.m_socket:readInt(packetId,ERROR_NUMBER);     --最后走棋的id  
    info.chessMan = self.m_socket:readShort(packetId,ERROR_NUMBER);     --棋子
	info.position1 = self.m_socket:readShort(packetId,ERROR_NUMBER);     --当前位置
	info.position2 = self.m_socket:readShort(packetId,ERROR_NUMBER);     --移动位置
    info.ob_num = self.m_socket:readInt(packetId,ERROR_NUMBER);     --观察者数量
    info.red_timeout = self.m_socket:readInt(packetId,ERROR_NUMBER);     --局时（秒）  
    info.black_timeout = self.m_socket:readInt(packetId,ERROR_NUMBER);     --局时（秒）
    return info;
end;



HallSocketReader.onRecvServerWatchDraw = function(self, packetId)
    local info = {};
	info.tid = self.m_socket:readInt(packetId,ERROR_NUMBER);     --棋桌ID 
	info.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);     --求和uid    

    return info;
end;

HallSocketReader.onRecvServerWatchSurrender = function(self, packetId)
    local info = {};
	info.tid = self.m_socket:readInt(packetId,ERROR_NUMBER);     --棋桌ID 
	info.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);     --认输uid    

    return info;
end;


HallSocketReader.onRecvServerWatchUndo = function(self, packetId)
    local info = {};
	info.tid = self.m_socket:readInt(packetId,ERROR_NUMBER);     --棋桌ID 
	info.status = self.m_socket:readInt(packetId,ERROR_NUMBER);  --状态    
	info.curr_move_flag = self.m_socket:readInt(packetId,ERROR_NUMBER); --当前走棋方 
	info.undo_uid = self.m_socket:readInt(packetId,ERROR_NUMBER);     --悔棋方    
    
	info.chessID1 = self.m_socket:readShort(packetId,ERROR_NUMBER);    --棋子ID 0表示当前棋子不可用
	info.position1_1 = self.m_socket:readShort(packetId,ERROR_NUMBER);   --当前位置
	info.position1_2 = self.m_socket:readShort(packetId,ERROR_NUMBER);    --移动位置
	info.eatChessID1 = self.m_socket:readShort(packetId,ERROR_NUMBER);    --被吃棋子ID  0表示没有被吃棋子
	
	info.chessID2 = self.m_socket:readShort(packetId,ERROR_NUMBER); 
	info.position2_1 = self.m_socket:readShort(packetId,ERROR_NUMBER); 
	info.position2_2 = self.m_socket:readShort(packetId,ERROR_NUMBER); 
	info.eatChessID2 = self.m_socket:readShort(packetId,ERROR_NUMBER); 


    return info;    


end;



HallSocketReader.onRecvServerWatchUserLeave = function(self, packetId)
    local info = {};
	info.tid = self.m_socket:readInt(packetId,ERROR_NUMBER);     --棋桌ID 
	info.status = self.m_socket:readInt(packetId,ERROR_NUMBER);     --棋桌状态        
	info.table_count = self.m_socket:readInt(packetId,ERROR_NUMBER);   --棋桌数量，客户端暂时不用
	info.leave_uid = self.m_socket:readInt(packetId,ERROR_NUMBER);     --离开uid    
    return info;
end;

HallSocketReader.onRecvServerWatchGameOver = function(self, packetId)
    local info = {};
	info.tid = self.m_socket:readInt(packetId,ERROR_NUMBER);     --棋桌ID 
	info.status = self.m_socket:readInt(packetId,ERROR_NUMBER);     --棋桌状态           
    info.win_flag = self.m_socket:readShort(packetId,ERROR_NUMBER); 
	info.end_type = self.m_socket:readShort(packetId,ERROR_NUMBER); 

    info.red_turn_money = self.m_socket:readInt(packetId,ERROR_NUMBER);     
    info.red_turn_score = self.m_socket:readInt(packetId,ERROR_NUMBER);         
    info.black_turn_money = self.m_socket:readInt(packetId,ERROR_NUMBER);     
    info.black_turn_score = self.m_socket:readInt(packetId,ERROR_NUMBER);  
    return info;
end;

HallSocketReader.onRecvServerWatchAllReady = function(self, packetId)
    local info = {};
	info.tid = self.m_socket:readInt(packetId,ERROR_NUMBER);     --棋桌ID 
	info.status = self.m_socket:readInt(packetId,ERROR_NUMBER);     --棋桌状态        

    return info;
end;


HallSocketReader.onRecvServerWatchError = function(self, packetId)
    local info = {};
    return info;
end;



HallSocketReader.onRecvClientMsgComein = function(self, packetId)
--    print_string("======服务器回应CLIENT_MSG_COMEIN======");
--	local errorCode = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 错误码 0 无对手 1有对手 -1 棋桌已经满 -8自己为空  UID 不合法，找不到用户
--	local errorMsg = self.m_socket:readString(packetId); -- 错误信息

--    local info = {};
--	info.tableID = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 棋桌ID
--	info.tableStatus = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 棋局状态
--	info.mUserID = self.m_socket:readInt(packetId,ERROR_NUMBER); -- 本人ID
--	info.mSeatID = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 本人座位ID
--	info.mUserStatus = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 本人状态 0 未登录 1已登录 2入座 3等待开局 4正在对弈 5 结束对弈

--	info.mFlag = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 本人红黑标志 1红方、2黑方
--	if(errorCode == -8) then 
--		print_string("进入棋桌失败"..errorMsg);
--	end


--	info.gameType = GAME_TYPE_UNKNOW;
--	info.rank1 = -1;
--	info.coin1 = 0;

--	local user = nil;
--	if (errorCode ~= 0)  then
--		local userID = self.m_socket:readInt(packetId,ERROR_NUMBER); -- 对手ID
--		local seatID = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 对手座位ID
--		local name = self.m_socket:readString(packetId); -- 对手昵称
--		local userStatus = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 对手状态
--		local score = self.m_socket:readInt(packetId,ERROR_NUMBER); -- 对手经验值
--		local level = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 对手等级
--		local flag = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 对手红黑标志 1红方、2黑方
--		local icon = self.m_socket:readString(packetId);   --对手头像链接
--		local sex = self.m_socket:readShort(packetId,ERROR_NUMBER);   -- 对手性别 0未知，1男性，2女性
--		local wintimes = self.m_socket:readInt(packetId,ERROR_NUMBER);  --对手赢棋盘数
--		local losetimes = self.m_socket:readInt(packetId,ERROR_NUMBER);  --对手输棋盘数
--		local drawtimes = self.m_socket:readInt(packetId,ERROR_NUMBER);   --DrawCount
--		local title = self.m_socket:readString(packetId);  --对手等级头衔
--		local source = self.m_socket:readShort(packetId,ERROR_NUMBER);   --对手来源
--		local sitemid = self.m_socket:readString(packetId);--对手平台ID
--		local platurl = self.m_socket:readString(packetId);--对手平台链接

--        local client_version = self.m_socket:readString(packetId);--对手版本（针对1.7.5之前的版本兼容）

--		info.gameType = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 棋局类型  1 普通场	2 十分钟场 3 二十分钟场
--		info.uid1 = self.m_socket:readInt(packetId,ERROR_NUMBER);    --
--		info.rank1 = self.m_socket:readInt(packetId,ERROR_NUMBER);   --当前排名  -1则为得不到当前排名
--		local uid2 = self.m_socket:readInt(packetId,ERROR_NUMBER);    --对手UID
--		local rank2 = self.m_socket:readInt(packetId,ERROR_NUMBER);   --对手当前排名  -1则为得不到当前排名
--		local auth = self.m_socket:readShort(packetId,ERROR_NUMBER);   --1 个人加V 2 非个人加V 3 达人 0 没有身份 -1 没有身份

--		info.coin1 = self.m_socket:readInt(packetId,ERROR_NUMBER);   --自己的金币
--		local coin2 = self.m_socket:readInt(packetId,ERROR_NUMBER);   --对手的金币

--		user = new(User);
--		user:setUid(userID);
--		user:setSeatID(seatID);
--		user:setName(name);
--		user:setStatus(userStatus);
--		user:setScore(score);
--		user:setLevel(level);
--		user:setFlag(flag);
--		user:setIcon(icon,userID);
--		user:setSex(sex);
--		user:setWintimes(wintimes);
--		user:setLosetimes(losetimes);
--		user:setDrawtimes(drawtimes);
--		user:setTitle(title);
--		user:setSource(source);
--		user:setSitemid(sitemid);
--		user:setPlaturl(platurl);
--		user:setRank(rank2);
--		user:setAuth(auth);
--		user:setMoney(coin2);
--        user:setClient_version(tonumber(json.decode_node(client_version).client_version:get_value()));
--        info.user = user;
--	else
--		info.gameType = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 棋局类型  1 普通场	2 十分钟场 3 二十分钟场
--		info.uid1 = self.m_socket:readInt(packetId,ERROR_NUMBER);    --
--		info.rank1 = self.m_socket:readInt(packetId,ERROR_NUMBER);   --当前排名  -1则为得不到当前排名
--		info.coin1 = self.m_socket:readInt(packetId,ERROR_NUMBER);   --自己的金币
--	end
--    return info;

end;



HallSocketReader.onRecvClientMsgStart = function(self, packetId)

    print_string("======服务器回应房间CLIENT_MSG_START======");
	local info = {};
    info.errorCode = self.m_socket:readShort(packetId,ERROR_NUMBER);  --00 成功  -1 Tid 不合法，找不到棋桌 -2 UID 不合法，找不到用户 -3 UID 用户已经不在棋桌 -4玩家正在对战，不可准备 -5 玩家已经准备，不可再准备 -10玩家已经不在当前桌子
	info.errorMsg = self.m_socket:readString(packetId,ERROR_STRING); --错误信息
	info.tableID = self.m_socket:readShort(packetId,ERROR_NUMBER);     --棋桌ID 
	info.tableStatus = self.m_socket:readShort(packetId,ERROR_NUMBER);     --棋桌状态
	info.player1ID = self.m_socket:readInt(packetId,ERROR_NUMBER);          --  玩家1ID
	info.player1Status = self.m_socket:readShort(packetId,ERROR_NUMBER);          --玩家1状态
	info.player2ID = self.m_socket:readInt(packetId,ERROR_NUMBER);          --  玩家2ID
	info.player2Status = self.m_socket:readShort(packetId,ERROR_NUMBER);          --玩家s状态


    return info;

	
end;


HallSocketReader.onRecvClientMsgForestall = function(self, packetId)

    local subcmd = self.m_socket:readSubCmd(packetId);
    print_string("======服务器回应房间CLIENT_MSG_FORESTALLE====== subcmd == " .. subcmd);
    --	当双方都准备开始时，服务推送抢先提醒消息，玩家根据自身状态决定是抢先（黑方），还是等待对方抢先（红方）
    if subcmd == 1 then 
	    print_string("======服务器回应房间CLIENT_MSG_FORESTALLE1======" );
	    local uid = self.m_socket:readInt(packetId,ERROR_NUMBER);         --抢先者ID
	    local flag = self.m_socket:readShort(packetId,ERROR_NUMBER);    -- 用户flag 1 为红方 2 为黑方
	    local tableID = self.m_socket:readShort(packetId,ERROR_NUMBER);  --棋桌ID
	    local waitTime = self.m_socket:readShort(packetId,ERROR_NUMBER);   --等待时间
                        

	    local info = {}

	    info.subcmd =1;
	    info.uid = uid;
	    info.flag = flag;
	    info.tableID = tableID;
	    info.waitTime = waitTime;
    
        return info;

    elseif subcmd == 2 then  --悔棋结果推送
	    print_string("======服务器回应房间CLIENT_MSG_FORESTALLE2======" );

	    local retCode = self.m_socket:readShort(packetId,ERROR_NUMBER);  --0 抢先成功 1黑方放弃抢先 <0失败

	    local errorMsg = self.m_socket:readString(packetId,ERROR_STRING); --错误信息
	
	    local uid = self.m_socket:readInt(packetId,ERROR_NUMBER);           --抢先者ID
		
	    local multiply = self.m_socket:readShort(packetId,ERROR_NUMBER);    --翻倍数
	    local redId = self.m_socket:readInt(packetId,ERROR_NUMBER);  --新的红方ID
	    local blackId = self.m_socket:readInt(packetId,ERROR_NUMBER);  --新的黑方ID  
	    local isContinue = self.m_socket:readByte(packetId,ERROR_NUMBER);  --是否可以继续抢先
	    local waitTime = self.m_socket:readShort(packetId,ERROR_NUMBER);    --等待时间



	    local info = {};
	    info.subcmd = subcmd;
	    info.retCode = retCode;
	    info.errorMsg = errorMsg;
	    info.uid = uid;
	    info.multiply = multiply;
	    info.blackId = blackId;
	    info.redId = redId;
	    info.isContinue = isContinue;
	    info.waitTime = waitTime;
        return info;
    end

    print_string("======服务器回应房间CLIENT_MSG_FORESTALLE处理完毕====== subcmd == " .. subcmd);
    

end;




HallSocketReader.onRecvClientMsgRelogin = function(self, packetId)
    
    print_string("======服务器回应房间CLIENT_MSG_RELOGIN======");
	local info = {};
    info.errorCode = self.m_socket:readShort(packetId,ERROR_NUMBER);  --错误码 0   成功 -1  Tid 不合法，找不到棋桌 -2  棋局已经结束，用户不在棋桌

	info.errorMsg = self.m_socket:readString(packetId,ERROR_STRING); --错误信息
    
    

	info.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);          --  用户ID

	info.tableID = self.m_socket:readShort(packetId,ERROR_NUMBER);     --棋桌ID 

	info.bycoin = self.m_socket:readInt(packetId,ERROR_NUMBER);            -- 元宝 
	info.Count = self.m_socket:readShort(packetId,ERROR_NUMBER);          --一局棋最多悔棋次数 
	info.useBYCoinTb = {};

	for i=1,info.Count do
		info.tb = {};
		info.useBYCoin = self.m_socket:readShort(packetId,ERROR_NUMBER);          	--当前悔棋次数要用到的元宝数 
		info.opponentgetCoin = self.m_socket:readInt(packetId,ERROR_NUMBER);          -- 对手被强制悔棋获得金币数 
		
		info.tb.useBYCoin = info.useBYCoin;
		info.tb.opponentgetCoin = info.opponentgetCoin;
		table.insert(info.useBYCoinTb,info.tb);
	end
    print_string("======服务器回应房间CLIENT_MSG_RELOGIN处理成功======");
    return info;



--	--此接口适用于当用户因网络原因的断线而重连接的情况， RetCode返回0，此时玩家需要主动拉取棋盘信息，同步前后端状态。（注意和0x0100 客户端重连接 区别）
--	EventDispatcher.getInstance():dispatch(Event.Call, ONLINE_RELOGIN_EVENT,errorCode);
--




end;



 HallSocketReader.onRecvClientRoomSyn = function(self, packetId)

    local info = {};
    info.room_level = self.m_socket:readInt(packetId,ERROR_NUMBER); --房间场
    info.base_chip = self.m_socket:readInt(packetId,ERROR_NUMBER); --底注
    info.coin = self.m_socket:readInt(packetId,ERROR_NUMBER);   --自己金币
    info.score = self.m_socket:readInt(packetId,ERROR_NUMBER); -- 自己积分
    info.flag = self.m_socket:readInt(packetId,ERROR_NUMBER); -- 红黑标志

    info.status = self.m_socket:readShort(packetId,ERROR_NUMBER); --棋局状态,1,棋局结束，2，正在对弈，3，抢先，4，让子
    info.first_flag = self.m_socket:readShort(packetId,ERROR_NUMBER); --先手方，1红棋先走，2黑棋先手
    info.multiply = self.m_socket:readShort(packetId,ERROR_NUMBER); --倍数
    info.round_time = self.m_socket:readShort(packetId,ERROR_NUMBER); --局时
    info.step_time = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 步时
    info.sec_time = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 读秒


    info.is_opp = self.m_socket:readInt(packetId,ERROR_NUMBER); --是否有对手
    if 1 == info.is_opp then
        info.opp_uid = self.m_socket:readInt(packetId,ERROR_NUMBER);--对手uid
        info.opp_money = self.m_socket:readInt(packetId,ERROR_NUMBER);--对手金币
        info.opp_score = self.m_socket:readInt(packetId,ERROR_NUMBER); --对手积分
        info.opp_flag = self.m_socket:readInt(packetId,ERROR_NUMBER); --对手红黑标志
        info.opp_user = self.m_socket:readString(packetId,ERROR_NUMBER); --对手信息    
        local user = new(User);
        local opp_user_str = json.decode(info.opp_user);
	    user:setUid(opp_user_str.uid);
	    user:setName(opp_user_str.user_name);
	    user:setScore(info.opp_score);
	    user:setLevel(opp_user_str.level);
	    user:setFlag(info.opp_flag);
	    user:setIcon(opp_user_str.icon,opp_user_str.uid);
	    user:setSex(opp_user_str.sex);
	    user:setWintimes(opp_user_str.wintimes);
	    user:setLosetimes(opp_user_str.losetimes);
	    user:setDrawtimes(opp_user_str.drawtimes);
	    user:setSource(opp_user_str.source);
	    user:setSitemid(opp_user_str.sitemid);
	    user:setPlaturl(opp_user_str.platurl);
	    user:setRank(opp_user_str.rank);
	    user:setAuth(opp_user_str.auth);
	    user:setMoney(info.opp_money);
        user:setVip(opp_user_str.is_vip);
        user:setVersion(opp_user_str.version);
        user:setClient_version(opp_user_str.client_version);
        --游戏还没有正式开始退出重连，设置时间都是默认值
        user:setTimeout1((info.round_time));
	    user:setTimeout2(info.step_time);
	    user:setTimeout3(info.sec_time);
        if info.status == 2 then--正在对弈
            --自己所剩时间
            info.round_timeout = self.m_socket:readShort(packetId,ERROR_NUMBER); --局时
            info.step_timeout = self.m_socket:readShort(packetId,ERROR_NUMBER); --步时
            info.sec_timeout = self.m_socket:readShort(packetId,ERROR_NUMBER); --读秒

            --对手所剩时间
            info.opp_round_timeout = self.m_socket:readShort(packetId,ERROR_NUMBER); --局时
            info.opp_step_timeout = self.m_socket:readShort(packetId,ERROR_NUMBER); --步时
            info.opp_sec_timeout = self.m_socket:readShort(packetId,ERROR_NUMBER); --读秒        
        
            info.chess_map = {}
            for i = 90,1,-1 do
	            info.chess_map[i] = self.m_socket:readByte(packetId,ERROR_NUMBER);        --整盘棋局
            end
        
            info.chessMan = self.m_socket:readShort(packetId,ERROR_NUMBER);     --棋子
            info.position1 = self.m_socket:readShort(packetId,ERROR_NUMBER);     --当前位置
            info.position2 = self.m_socket:readShort(packetId,ERROR_NUMBER);     --移动位置

            user:setTimeout1((info.round_time - info.opp_round_timeout));
	        user:setTimeout2(info.opp_step_timeout);
	        user:setTimeout3(info.opp_sec_timeout);
        elseif info.status == 3 then--抢先状态



        elseif info.status == 4 then--让子状态


        end;


	    info.user = user;

        
    else
        --不存在对手,发送退出房间请求

    end;

    return info;

 end;





 HallSocketReader.onRecvClientMsgWatchlist = function(self, packetId)

    print_string("======服务器回应房间CLIENT_MSG_WATCHLIST======");
	local errorCode = self.m_socket:readShort(packetId,ERROR_NUMBER);  --错误码 0 成功   其他失败
	local errorMsg = self.m_socket:readString(packetId,ERROR_STRING); --错误信息


	if(errorCode == 0) then

	else
		print_string("CLIENT_MSG_WATCHLIST errorCode ~= 0");
		return;
	end
	local total = self.m_socket:readShort(packetId,ERROR_NUMBER);          --总条数

	local count = self.m_socket:readShort(packetId,ERROR_NUMBER);    --当前返回条数

	local list = {}
	for index = 1,count do
		local watcher = {};

		watcher.seatID = self.m_socket:readShort(packetId,ERROR_NUMBER);    --观战座位ID
		watcher.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);    --观战用户ID
		watcher.name = self.m_socket:readString(packetId,ERROR_STRING); --观战用户名称
		watcher.title = self.m_socket:readString(packetId,ERROR_STRING); --观战称号
		watcher.wintimes = self.m_socket:readInt(packetId,ERROR_NUMBER);  --赢棋盘数
		watcher.losetimes = self.m_socket:readInt(packetId,ERROR_NUMBER);  --输棋盘数
		watcher.drawtimes = self.m_socket:readInt(packetId,ERROR_NUMBER);   --和棋盘数
		table.insert(list,watcher);
	end
    print_string("======服务器回应房间CLIENT_MSG_WATCHLIST处理成功======");    
	return total;

 end;




 HallSocketReader.onRecvClientGetOpenboxTime = function(self, packetId)

    print_string("======服务器回应房间CLIENT_GET_OPENBOX_TIME======");
	local errorCode = self.m_socket:readInt(packetId,ERROR_NUMBER);  --0 成功  其他失败
    local info = {};
	info.playtime = self.m_socket:readInt(packetId,ERROR_NUMBER);          --  玩牌时间
	info.openbox_time = self.m_socket:readInt(packetId,ERROR_NUMBER);          --  
	info.openbox_id = self.m_socket:readInt(packetId,ERROR_NUMBER);          -- 奖励id

    return info;

 end;



HallSocketReader.onRecvClientMsgLeave = function(self, packetId)
--    print_string("======服务器回应房间CLIENT_MSG_LEAVE======");
--    local info = {};
--	info.errorCode = self.m_socket:readShort(packetId,ERROR_NUMBER);  --错误码 0 成功   -8自己为空 -10自己已经不在当前桌子
--	info.errorMsg = self.m_socket:readString(packetId,ERROR_STRING); --错误信息

--	info.player1ID = self.m_socket:readInt(packetId,ERROR_NUMBER);          --  用户ID
--	info.player1Status = self.m_socket:readShort(packetId,ERROR_NUMBER);          --用户状态

--	info.tableID = self.m_socket:readShort(packetId,ERROR_NUMBER);     --棋桌ID 
--	info.tableStatus = self.m_socket:readShort(packetId,ERROR_NUMBER);     --棋桌状态

--	info.player2ID = self.m_socket:readInt(packetId,ERROR_NUMBER);          --  玩家2ID
--	info.player2Status = self.m_socket:readShort(packetId,ERROR_NUMBER);          --玩家2状态

--	info.leaveUid = self.m_socket:readInt(packetId,ERROR_NUMBER);          --  离开者ID


--    return info;

end;


HallSocketReader.onRecvClientMsgChat = function(self, packetId)
    local subcmd = self.m_socket:readSubCmd(packetId);

	if subcmd == 1  then   --
		print_string("======服务器回应房间CLIENT_MSG_CHAT====== sumcmd = " ..subcmd);
		local errorCode = self.m_socket:readShort(packetId,ERROR_NUMBER);  --错误码 0 申请成功   -1 Tid 不合法，找不到棋桌 -2 UID 不合法，找不到用户 -3 UID 不合法，找不到对手 -4棋桌状态不是对战状态，不可和棋 -5对手掉线，不能请求和棋
		local errorMsg = self.m_socket:readString(packetId,ERROR_STRING); --错误信息
        local message = self.m_socket:readString(packetId,ERROR_STRING); --自己发出的信息
		if errorCode ~= 0 then
--			print_string("发送聊天信息失败！！！");
            if errorCode == 1 then -- 发送失败（频繁发送）
                ChessToastManager.getInstance():showSingle("亲，消息不能为空或频繁发送哦",1500);
                return;
            else -- ...

            end;
        else
            local info = {};
            info.uid = UserInfo.getInstance():getUid();
            info.message = message;
            info.forbid_time = self.m_socket:readInt(packetId,ERROR_NUMBER);
            return info;
		end

	elseif subcmd == 2 then   --通知
		print_string("======服务器回应房间CLIENT_MSG_CHAT2======" );
        local info = {};

		info.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);         --对手ID
		info.name = self.m_socket:readString(packetId);      			   --名字
		info.msgType = self.m_socket:readShort(packetId,ERROR_NUMBER);   --消息类型
		info.message = self.m_socket:readString(packetId); 
		if not info.uid or not info.name or not info.message then
			print_string("not uid or not name or not message "  );
			return;
		end
		info.message = GameString.convert2UTF8(info.message);
        return info;
    end
end;


HallSocketReader.onRecvClientMsgHandicap = function(self, packetId)
	--	当双方都准备开始时由服务器主动推送给红方和黑方
    local subcmd = self.m_socket:readSubCmd(packetId);
    print_string("======服务器回应房间CLIENT_MSG_HANDICAP====== subcmd == " .. subcmd);


	if subcmd == 1 then 
		print_string("======服务器回应房间CLIENT_MSG_HANDICAP2======" );
		local uid = self.m_socket:readInt(packetId,ERROR_NUMBER);         --让子者ID
		local tableID = self.m_socket:readShort(packetId,ERROR_NUMBER);   --桌位ID
		local waitTime = self.m_socket:readShort(packetId,ERROR_NUMBER);  --等待时间
		local count  = self.m_socket:readShort(packetId,ERROR_NUMBER);  --让子的个数 暂时为3
		local chesses = {};
		for index = 1,count do
			local chess = {};
			chess.chessID = self.m_socket:readShort(packetId,ERROR_NUMBER); --棋子ID
			chess.multiply = self.m_socket:readShort(packetId,ERROR_NUMBER); --此棋子的倍数
			table.insert(chesses,chess);
			print_string("index = " .. index .. "chessID = " .. chess.chessID .. "multiply = " .. chess.multiply);
		end

		local mul = self.m_socket:readShort(packetId,ERROR_NUMBER); --棋局的倍数
		local money = self.m_socket:readInt(packetId,ERROR_NUMBER); --棋局的底注                                 

		local data = {}

		data.subcmd =1;
		data.uid = uid;
		data.tableID = tableID;
		data.waitTime = waitTime;
		data.chesses = chesses;
		data.mul = mul;
		data.money = money;
		print_string("CLIENT_MSG_HANDICAP uid = " .. uid);
		
        return data;
--		EventDispatcher.getInstance():dispatch(Event.Call, ONLINE_HANDICAP_EVENT,data);


	elseif subcmd == 2 then  --让子结果推送
		print_string("======服务器回应房间CLIENT_MSG_HANDICAP3======" );

		local retCode = self.m_socket:readShort(packetId,ERROR_NUMBER);  --0 让子成功 1放弃让子 <0失败

		local errorMsg = self.m_socket:readString(packetId,ERROR_STRING); --错误信息
	
		local multiply = self.m_socket:readShort(packetId,ERROR_NUMBER);    --翻倍数

		local uid = self.m_socket:readInt(packetId,ERROR_NUMBER);           --抢先者ID
		
		local chessMan = self.m_socket:readShort(packetId,ERROR_NUMBER);     --让子的棋子ID（0为不让子)


		self.m_socket:readEnd(packetId);

		local data = {};
		data.subcmd = subcmd;
		data.retCode = retCode;
		data.errorMsg = errorMsg;
		data.uid = uid;
		data.multiply = multiply;
		data.chessMan = chessMan;

        return data;
--		EventDispatcher.getInstance():dispatch(Event.Call, ONLINE_HANDICAP_EVENT,data);

		-- print_string("retCode:" .. retCode );
		-- print_string("errorMsg:" .. errorMsg );

	end


end;


HallSocketReader.onRecvClientMsgMove = function(self, packetId)

 print_string("======服务器回应房间CLIENT_MSG_MOVE======");
	    --[[//错误码 -1 走法不合规则 -2 相同方不可互吃 -3 找不到当前棋桌  -4 对手为空 -5 对方尚未走棋，请等待
        //  -6 客户端状态与服务端状态不一致，需要同步   -8 UID 不合法，找不到用户 -10 自己已经不在当前棋桌
        -9 此走法会导致自己被将军 -11 红方长捉黑方  -12 黑方长捉红方

        //0 成功   1红方胜利  2黑方胜利  9将军]]
    local info = {};
	info.errorCode = self.m_socket:readShort(packetId,ERROR_NUMBER);  --
	info.errorMsg = self.m_socket:readString(packetId,ERROR_STRING); --错误信息

	if info.errorCode < 0 then  --走棋不合法
       
		return info;
    end


	info.chessMan = self.m_socket:readShort(packetId,ERROR_NUMBER);     --棋子
	info.position1 = self.m_socket:readShort(packetId,ERROR_NUMBER);     --当前位置
	info.position2 = self.m_socket:readShort(packetId,ERROR_NUMBER);     --移动位置
	info.tableStatus = self.m_socket:readShort(packetId,ERROR_NUMBER);     --棋局状态
	info.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);          --  走棋者ID
	info.timeout = self.m_socket:readShort(packetId,ERROR_NUMBER);     --局时（秒）
    
    return info;

	


end;






HallSocketReader.onRecvClientMsgDraw1 = function(self, packetId)

	print_string("======服务器回应房间CLIENT_MSG_DRAW1======" );
	local errorCode = self.m_socket:readShort(packetId,ERROR_NUMBER);  --错误码 0 申请成功   -1 Tid 不合法，找不到棋桌 -2 UID 不合法，找不到用户 -3 UID 不合法，找不到对手 -4棋桌状态不是对战状态，不可和棋 -5对手掉线，不能请求和棋
	local errorMsg = self.m_socket:readString(packetId,ERROR_STRING); --错误信息
	if errorCode == -3 then
		print_string("对手不存在");
        return;
	elseif errorCode == -4 then
		print_string("棋桌状态错误");
        return;
	elseif errorCode == -5 then
        local message = "申请失败(对手掉线)";
        return message;
	elseif errorCode == -6 then
        local message = "申请失败(过于频繁)";
        return message;
    end
end;


HallSocketReader.onRecvClientMsgDraw2 = function(self, packetId)

	print_string("======服务器回应房间CLIENT_MSG_DRAW2======" );
    local info = {}
	info.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);         --对手ID
	info.tableID = self.m_socket:readInt(packetId,ERROR_NUMBER);  --棋桌ID
	
    return info;
end;

HallSocketReader.onRecvServerMsgDraw = function(self, packetId)
    
    print_string("======服务器回应房间SERVER_MSG_DRAW======" );

	local errorCode = self.m_socket:readShort(packetId,ERROR_NUMBER);  --错误码 0 申请成功   -1 Tid 不合法，找不到棋桌 -2 UID 不合法，找不到用户 -3 UID 不合法，找不到对手 -4棋桌状态不是对战状态，不可和棋 -5对手掉线，不能请求和棋
	local errorMsg = self.m_socket:readString(packetId,ERROR_STRING); --错误信息
	local info = {};
	info.isOK = self.m_socket:readShort(packetId,ERROR_NUMBER);      --是否同意和棋  1-同意 2 不同意
	info.tableID = self.m_socket:readInt(packetId,ERROR_NUMBER);        --棋桌ID
	info.tableStatus = self.m_socket:readShort(packetId,ERROR_NUMBER);    --棋桌状态
		
	info.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);       --用户ID
	info.uStatus = self.m_socket:readShort(packetId,ERROR_NUMBER);        --用户状态
		
	info.player2ID = self.m_socket:readInt(packetId,ERROR_NUMBER);        --对手ID
	info.player2Status = self.m_socket:readShort(packetId,ERROR_NUMBER);  --对手状态
	info.drawID = self.m_socket:readInt(packetId,ERROR_NUMBER);           --和棋申请者ID

    return info;

end;

HallSocketReader.onRecvClientMsgUndomove = function(self, packetId)
    local subcmd = self.m_socket:readSubCmd(packetId);
    print_string("======服务器回应房间UNDO====== subcmd == " .. subcmd);
    local info = {};
    info.subcmd = subcmd;
	if subcmd == 1  then   --悔棋申请
		print_string("======服务器回应房间CLIENT_MSG_UNDOMOVE====== sumcmd = " ..subcmd);

        info.errorCode = self.m_socket:readShort(packetId,ERROR_NUMBER);  --错误码 0 申请成功   -1 Tid 不合法，找不到棋桌 -2 UID 不合法，找不到用户 -3 UID 不合法，找不到对手 -4棋桌状态不是对战状态，不可和棋 -5对手掉线，不能请求和棋
		info.errorMsg = self.m_socket:readString(packetId,ERROR_STRING); --错误信息
		if info.errorCode ~= 0 then
			print_string("申请悔棋失败！！！");
		end

        return info;
	elseif subcmd == 2 then   --悔棋通知
		print_string("======服务器回应房间CLIENT_MSG_UNDOMOVE2======" );
		info.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);         --对手ID
		info.tableID = self.m_socket:readShort(packetId,ERROR_NUMBER);  --棋桌ID
		info.seatID = self.m_socket:readShort(packetId,ERROR_NUMBER);   --桌位ID
		
        return info;


	elseif subcmd == 3 then  --悔棋结果推送
		print_string("======服务器回应房间SERVER_MSG_UNDO3======" );

		info.errorCode = self.m_socket:readShort(packetId,ERROR_NUMBER);  --错误码 0 申请成功   -1 Tid 不合法，找不到棋桌 -2 UID 不合法，找不到用户 -3 UID 不合法，找不到对手 -4棋桌状态不是对战状态，不可和棋 -5对手掉线，不能请求和棋
		info.errorMsg = self.m_socket:readString(packetId,ERROR_STRING); --错误信息
--		subcmd =3
--errCode
--= -3  对手不存在
--= -4  棋局已结束
--= -5  超出悔棋步数
--= -6  超出悔棋步数

--= 0    悔棋成功
        if info.errorCode == 0 then
            info.isOK = self.m_socket:readShort(packetId,ERROR_NUMBER);      --是否同意和棋  1-同意 2 不同意
		    info.tableID = self.m_socket:readInt(packetId,ERROR_NUMBER);        --棋桌ID
		    info.tableStatus = self.m_socket:readShort(packetId,ERROR_NUMBER);    --棋桌状态

		    info.undoID = self.m_socket:readInt(packetId,ERROR_NUMBER);           --悔棋申请者ID
		


		    info.chessID1 = self.m_socket:readShort(packetId,ERROR_NUMBER);    --棋子ID 0表示当前棋子不可用
		    info.position1_1 = self.m_socket:readShort(packetId,ERROR_NUMBER);   --当前位置
		    info.position1_2 = self.m_socket:readShort(packetId,ERROR_NUMBER);    --移动位置
		    info.eatChessID1 = self.m_socket:readShort(packetId,ERROR_NUMBER);    --被吃棋子ID  0表示没有被吃棋子
		
		    info.chessID2 = self.m_socket:readShort(packetId,ERROR_NUMBER); 
		    info.position2_1 = self.m_socket:readShort(packetId,ERROR_NUMBER); 
		    info.position2_2 = self.m_socket:readShort(packetId,ERROR_NUMBER); 
		    info.eatChessID2 = self.m_socket:readShort(packetId,ERROR_NUMBER); 

		    info.OpponentID = self.m_socket:readInt(packetId,ERROR_NUMBER);           --将要被加金币的用户ID 
		    info.GetCoin = self.m_socket:readInt(packetId,ERROR_NUMBER);          	--获得金币数量 
		    info.Undomovenum = self.m_socket:readShort(packetId,ERROR_NUMBER);
        end

        return info;
		

    elseif subcmd == 10 then         --金币悔棋申请返回
        print_string("======服务器回应房间CLIENT_MSG_UNDOMOVE====== sumcmd = " ..subcmd);
		info.errorCode = self.m_socket:readInt(packetId,ERROR_NUMBER);  --错误码 0 申请成功  1金币不足  2悔棋太频繁  3状态错误
		info.cost_money = self.m_socket:readInt(packetId,ERROR_NUMBER); 
        if info.errorCode ~= 0 then
			print_string("申请悔棋失败！！！");
		end
        return info;

    elseif subcmd == 11 then        --金币悔棋被通知是否同意
        print_string("======服务器回应房间CLIENT_MSG_UNDOMOVE====== sumcmd = " ..subcmd);
		info.money = self.m_socket:readInt(packetId,ERROR_NUMBER); 
        return info;
    elseif subcmd == 13 then       --金币悔棋结果	
		info.isOK = self.m_socket:readShort(packetId,ERROR_NUMBER);      --是否同意悔棋棋  1-同意
		info.uid_1 = self.m_socket:readInt(packetId,ERROR_NUMBER);        --uid_1玩家
        info.changeMoney_1 = self.m_socket:readInt(packetId,ERROR_NUMBER);        --uid_玩家对应变化的金钱
        info.uid_2 = self.m_socket:readInt(packetId,ERROR_NUMBER);        --uid_1玩家
        info.changeMoney_2 = self.m_socket:readInt(packetId,ERROR_NUMBER);        --uid_玩家对应变化的金钱

        return info;
        
	end

	print_string("======服务器回应房间UNDO处理完毕====== subcmd == " .. subcmd);
    

end;



--中级和高级房间开始,server先主动推这个消息.
HallSocketReader.onRecvSetTimeInfo = function(self, packetId)
    local info = {};
    local subcmd = self.m_socket:readSubCmd(packetId);
    info.subcmd = subcmd;
	if subcmd == 1  then   --局时、步时、读秒设置提醒
        info.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);         --优先设置者ID 默认红方先设置

	elseif subcmd == 3 then   --当红方设置完成，推送给黑方
		print_string("======服务器回应房间SET_TIME_INFO3======" );
        
		info.timeOut1 = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 局时（秒）
		info.timeOut2 = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 步时（秒）
		info.timeOut3 = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 读秒（秒）

	end

    return info;

end;





HallSocketReader.onRecvClientMsgSurrender1 = function(self, packetId)

	print_string("======服务器回应房间CLIENT_MSG_SURRENDER1 ======" );
	local errorCode = self.m_socket:readShort(packetId,ERROR_NUMBER);  --错误码 0 申请成功   -1 Tid 不合法，找不到棋桌 -2 UID 不合法，找不到用户 -3 UID 不合法，找不到对手 -4棋桌状态不是对战状态，不可和棋 -5对手掉线，不能请求和棋
	local errorMsg = self.m_socket:readString(packetId,ERROR_STRING); --错误信息
	if errorCode ~= 0 then
		print_string("申请投降失败！！！");
	end  


end;

HallSocketReader.onRecvClientMsgSurrender2 = function(self, packetId)

	print_string("======服务器回应房间CLIENT_MSG_SURRENDER2 ======" );
	local info = {};
    info.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);         --对手ID
	info.tableID = self.m_socket:readInt(packetId,ERROR_NUMBER);  --棋桌ID

    return info;
 

end;


HallSocketReader.onRecvServerMsgSurrender = function(self, packetId)
	print_string("======服务器回应房间SERVER_MSG_SURRENDER======" );

	local errorCode = self.m_socket:readShort(packetId,ERROR_NUMBER);  --错误码 0 申请成功   -1 Tid 不合法，找不到棋桌 -2 UID 不合法，找不到用户 -3 UID 不合法，找不到对手 -4棋桌状态不是对战状态，不可和棋 -5对手掉线，不能请求和棋
	local errorMsg = self.m_socket:readString(packetId,ERROR_STRING); --错误信息
	local info = {};	
	info.isOK = self.m_socket:readShort(packetId,ERROR_NUMBER);      --是否同意投降  1-同意 2 不同意
	info.tableID = self.m_socket:readInt(packetId,ERROR_NUMBER);        --棋桌ID
	info.tableStatus = self.m_socket:readShort(packetId,ERROR_NUMBER);    --棋桌状态
		
	info.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);       --用户ID
	info.uStatus = self.m_socket:readShort(packetId,ERROR_NUMBER);        --用户状态
		
	info.player2ID = self.m_socket:readInt(packetId,ERROR_NUMBER);        --对手ID
	info.player2Status = self.m_socket:readShort(packetId,ERROR_NUMBER);  --对手状态
	info.faultID = self.m_socket:readInt(packetId,ERROR_NUMBER);           --投降申请者ID


    return info;


end;





--HallSocketReader.onRecvServerMsgGameStart = function(self, packetId)

-- print_string("======服务器回应房间SERVER_MSG_GAME_START======");
--    local info = {};
--	info.errorCode = self.m_socket:readShort(packetId,ERROR_NUMBER);  --0 成功  其他失败
--	info.errorMsg = self.m_socket:readString(packetId,ERROR_STRING); --错误信息

--	info.player1ID = self.m_socket:readInt(packetId,ERROR_NUMBER);          --  玩家1ID
--	info.player1Status = self.m_socket:readShort(packetId,ERROR_NUMBER);          --玩家1状态
--	info.player2ID = self.m_socket:readInt(packetId,ERROR_NUMBER);          --  玩家2ID
--	info.player2Status = self.m_socket:readShort(packetId,ERROR_NUMBER);          --玩家s状态

--	info.tableID = self.m_socket:readShort(packetId,ERROR_NUMBER);     --棋桌ID 
--	info.tableStatus = self.m_socket:readShort(packetId,ERROR_NUMBER);     --棋桌状态

--	info.timeOut1 = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 局时（秒）
--	info.timeOut2 = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 步时（秒）
--	info.timeOut3 = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 读秒（秒）

--	info.redID = self.m_socket:readInt(packetId,ERROR_NUMBER);          --  根据红黑方ID是否与自己相符合，决定是否换对调棋桌
--	info.blackID = self.m_socket:readInt(packetId,ERROR_NUMBER);          --  玩家1ID

--	info.boardID = self.m_socket:readString(packetId,ERROR_STRING); --棋局ID()

--	info.chess_map = {}
--	for i = 90,1,-1 do
--		info.chess_map[i] = self.m_socket:readByte(packetId,ERROR_NUMBER);        --整盘棋局
--	end

--	info.ForceUndoMove = self.m_socket:readShort(packetId,ERROR_NUMBER);    -- 强制悔棋 -- 这盘棋是否支持强制悔棋 0 不支持 1 支持 


--    return info;

--end;




HallSocketReader.onRecvServerMsgGameClose = function(self, packetId)

    print_string("======服务器回应房间SERVER_MSG_GAME_CLOSE======");
    local info = {};
    info.tid = self.m_socket:readInt(packetId, ERROR_NUMBER);
    info.table_status = self.m_socket:readShort(packetId, ERROR_NUMBER);
    info.rent = self.m_socket:readInt(packetId, ERROR_NUMBER);

    info.end_type = self.m_socket:readShort(packetId, ERROR_NUMBER);
    info.ready_time = self.m_socket:readShort(packetId, ERROR_NUMBER);
    info.win_flag = self.m_socket:readShort(packetId, ERROR_NUMBER);
    info.multiply = self.m_socket:readShort(packetId, ERROR_NUMBER);


    info.uid1 = self.m_socket:readInt(packetId, ERROR_NUMBER);
    info.money1 = self.m_socket:readInt(packetId, ERROR_NUMBER);
    info.tmoney1 = self.m_socket:readInt(packetId, ERROR_NUMBER);
    info.score1 = self.m_socket:readInt(packetId, ERROR_NUMBER);
    info.tscore1 = self.m_socket:readInt(packetId, ERROR_NUMBER);


    info.uid2 = self.m_socket:readInt(packetId, ERROR_NUMBER);
    info.money2 = self.m_socket:readInt(packetId, ERROR_NUMBER);
    info.tmoney2 = self.m_socket:readInt(packetId, ERROR_NUMBER);
    info.score2 = self.m_socket:readInt(packetId, ERROR_NUMBER);
    info.tscore2 = self.m_socket:readInt(packetId, ERROR_NUMBER);
    info.red_wintimes = self.m_socket:readInt(packetId, ERROR_NUMBER);
    info.black_wintimes = self.m_socket:readInt(packetId, ERROR_NUMBER);


    return info;




--	info.tableID = self.m_socket:readShort(packetId,ERROR_NUMBER);     --棋桌ID 
--	info.tableStatus = self.m_socket:readShort(packetId,ERROR_NUMBER);     --棋桌状态

--	info.player1ID = self.m_socket:readInt(packetId,ERROR_NUMBER);          --  玩家1ID
--	info.player1Status = self.m_socket:readShort(packetId,ERROR_NUMBER);          --玩家1状态
--	info.player2ID = self.m_socket:readInt(packetId,ERROR_NUMBER);          --  玩家2ID
--	info.player2Status = self.m_socket:readShort(packetId,ERROR_NUMBER);          --玩家s状态

--	info.flag = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 棋局结果 0 和棋 1 红方胜利  2 黑方胜利

--	info.scoreRed = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 红方扣/加分
--	info.totalscoreRed = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 红方最新总分
--	info.levelRed = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 

--	info.scoreBlack = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 黑方扣/加分
--	info.totalscoreBlack = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 黑方最新总分
--	info.levelBlack = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 黑方最新等级

--	info.titleRed = self.m_socket:readString(packetId);     -- 红方最新头衔
--	info.titleBlack = self.m_socket:readString(packetId);     -- 黑方最新头衔

--	info.endType = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 游戏结束类型

--	info.redRank = self.m_socket:readInt(packetId,ERROR_NUMBER);                --红方最新排名
--	info.blackRank = self.m_socket:readInt(packetId,ERROR_NUMBER);              --黑方最新排名

--	info.redCoin = self.m_socket:readInt(packetId,ERROR_NUMBER);                --红方扣/加金币
--	info.redTotalCoin = self.m_socket:readInt(packetId,ERROR_NUMBER);              --红方总金币
--	info.redTaxes = self.m_socket:readInt(packetId,ERROR_NUMBER);                --红方棋桌费

--	info.blackCoin= self.m_socket:readInt(packetId,ERROR_NUMBER);              --黑方扣/加金币
--	info.blackTotalCoin = self.m_socket:readInt(packetId,ERROR_NUMBER);            --黑方总金币
--	info.blackTaxes = self.m_socket:readInt(packetId,ERROR_NUMBER);              --黑方棋桌费


--	info.multiply = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 本棋局的倍数 Short 2 1为没有翻倍 >1表示翻的倍数
--    info.redCoinRank = self.m_socket:readInt(packetId,ERROR_NUMBER);    --红方金币排名 Int 4 注：-1说明没有取到排名 
--    info.blackCoinRank = self.m_socket:readInt(packetId,ERROR_NUMBER);    -- 黑方金币排名 Int 4 注：-1说明没有取到排名 
--    info.scoreUser = self.m_socket:readInt(packetId,ERROR_NUMBER);    --  总人数 Int 4 积分排行榜总人数 注：-1说明没有取到总人数 
--    info.coinUser   = self.m_socket:readInt(packetId,ERROR_NUMBER);    -- 总人数 Int 4 金币排行榜总人数 

--	info.redIsVerify = self.m_socket:readByte(packetId,ERROR_NUMBER);  --（红方）是否身份验证 BYTE 1 0 未验证 1-成年人 2-未成年人 
--    info.redOnlineTime = self.m_socket:readInt(packetId,ERROR_NUMBER);    -- （红方）当日在玩时长（分钟） Int 4 

--	info.blackIsVerify = self.m_socket:readByte(packetId,ERROR_NUMBER);  -- （黑方）是否身份验证 BYTE 1 0 未验证 1-成年人 2-未成年人 
--    info.blackOnlineTime = self.m_socket:readInt(packetId,ERROR_NUMBER);    --  （黑方）当日在玩时长（分钟） Int 4 



--    return info;

end;




HallSocketReader.onRecvServerMsgWarning = function(self, packetId)


    local info = {};
	info.type = self.m_socket:readShort(packetId,ERROR_NUMBER);  --消息类型
	info.msg = self.m_socket:readString(packetId,ERROR_STRING); --错误信息    
    return info;
end;

HallSocketReader.onRecvServerMsgTips = function(self, packetId)
    local info = {};
	info.type = self.m_socket:readShort(packetId,ERROR_NUMBER);  --消息类型
	info.msg = self.m_socket:readString(packetId,ERROR_STRING); --错误信息    
    return info;

end;

HallSocketReader.onRecvCustomMsgLoginEnter = function(self, packetId)

    print_string("======CustomRoomGameLoginStartProc======");
    local info ={};
	info.retCode = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 错误码 0 无对手 1有对手 -1 棋桌已经满 -8自己为空  UID 不合法，找不到用户

	if info.retCode < 0 then 
		EventDispatcher.getInstance():dispatch(Event.Call, ONLINE_ENTER_CUSTOMROOM_FAIL,info.retCode);
		return;
	end

	if info.retCode == 2 then 
		EventDispatcher.getInstance():dispatch(Event.Call, ONLINE_ENTER_CUSTOMROOM_FAIL,info.retCode);
		return;
	end
	info.errorMsg = self.m_socket:readString(packetId); -- 错误信息
	info.tableID = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 棋桌ID
	info.tableStatus = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 棋局状态
	info.mUserID = self.m_socket:readInt(packetId,ERROR_NUMBER); -- 本人ID
	info.mSeatID = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 本人座位ID
	info.mUserStatus = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 本人状态 0 未登录 1已登录 2入座 3等待开局 4正在对弈 5 结束对弈
												
	info.mFlag = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 本人红黑标志 1红方、2黑方

	local userInfo = UserInfo.getInstance();
	if info.mUserID  == UserInfo.getInstance():getUid() then  --本人ID是否相同？（有必要？）
		userInfo:setTid(info.tableID) ;
		userInfo:setSeatID(info.mSeatID) ;
		userInfo:setStatus(info.mUserStatus);
		userInfo:setFlag(info.mFlag) ;
	else
		print_string(string.format("mUserID != userInfo.uid mUserID = %d,userInfo.uid = %d",mUserID,userInfo:getUid()));
		return;
	end
	
	info.gameType = GAME_TYPE_UNKNOW;
	info.rank1 = -1;
	info.coin1 = 0;

	local user = nil;
	if (info.retCode ~= 0)  then
		local userID = self.m_socket:readInt(packetId,ERROR_NUMBER); -- 对手ID
		local seatID = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 对手座位ID
		local name = self.m_socket:readString(packetId); -- 对手昵称
		local userStatus = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 对手状态
		local score = self.m_socket:readInt(packetId,ERROR_NUMBER); -- 对手经验值
		local level = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 对手等级
		local flag = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 对手红黑标志 1红方、2黑方
		local icon = self.m_socket:readString(packetId);   --对手头像链接
		local sex = self.m_socket:readShort(packetId,ERROR_NUMBER);   -- 对手性别 0未知，1男性，2女性
		local wintimes = self.m_socket:readInt(packetId,ERROR_NUMBER);  --对手赢棋盘数
		local losetimes = self.m_socket:readInt(packetId,ERROR_NUMBER);  --对手输棋盘数
		local drawtimes = self.m_socket:readInt(packetId,ERROR_NUMBER);   --DrawCount
		local title = self.m_socket:readString(packetId);  --对手等级头衔
		local source = self.m_socket:readShort(packetId,ERROR_NUMBER);   --对手来源
		local sitemid = self.m_socket:readString(packetId);--对手平台ID
		local platurl = self.m_socket:readString(packetId);--对手平台链接

        local client_version = self.m_socket:readString(packetId);--对手版本（针对1.7.5之前的版本兼容）

		info.gameType = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 棋局类型  1 普通场	2 十分钟场 3 二十分钟场
		local uid1 = self.m_socket:readInt(packetId,ERROR_NUMBER);    --
		info.rank1 = self.m_socket:readInt(packetId,ERROR_NUMBER);   --当前排名  -1则为得不到当前排名
		local uid2 = self.m_socket:readInt(packetId,ERROR_NUMBER);    --对手UID
		local rank2 = self.m_socket:readInt(packetId,ERROR_NUMBER);   --对手当前排名  -1则为得不到当前排名
		local auth = self.m_socket:readShort(packetId,ERROR_NUMBER);   --1 个人加V 2 非个人加V 3 达人 0 没有身份 -1 没有身份

		info.coin1 = self.m_socket:readInt(packetId,ERROR_NUMBER);   --自己的金币
		local coin2 = self.m_socket:readInt(packetId,ERROR_NUMBER);   --对手的金币


		local bycoin = self.m_socket:readInt(packetId,ERROR_NUMBER);            -- 元宝 
		local Count = self.m_socket:readShort(packetId,ERROR_NUMBER);          --一局棋最多悔棋次数 
		local useBYCoinTb = {};


		for i=1,Count do
			local tb = {};
			local useBYCoin = self.m_socket:readShort(packetId,ERROR_NUMBER);          	--当前悔棋次数要用到的元宝数 
			local opponentgetCoin = self.m_socket:readInt(packetId,ERROR_NUMBER);          -- 对手被强制悔棋获得金币数 

			tb.useBYCoin = useBYCoin;
			tb.opponentgetCoin = opponentgetCoin;
			table.insert(useBYCoinTb,tb);
		end

		
		-- 元宝 
		UserInfo.getInstance():setBycoin(bycoin);
		-- 对手被强制悔棋获得金币数 
		UserInfo.getInstance():setOpponentgetCoin(opponentgetCoin);
		UserInfo.getInstance():setMaxOnlineUndoCount(Count)--一局棋最多悔棋次数 
		--当前悔棋次数要用到的元宝数
		UserInfo.getInstance():setUseBYCoinTb(useBYCoinTb);

		UserInfo.getInstance():setRank(info.rank1);



        user = new(User) ;
        
		user:setUid(userID);
		user:setSeatID(seatID);
		user:setName(name);
		user:setStatus(userStatus);
		user:setScore(score);
		user:setLevel(level);
		user:setFlag(flag);
		user:setIcon(icon,userID);
		user:setSex(sex);
		user:setWintimes(wintimes);
		user:setLosetimes(losetimes);
		user:setDrawtimes(drawtimes);
		user:setTitle(title);
		user:setSource(source);
		user:setSitemid(sitemid);
		user:setPlaturl(platurl);
		user:setRank(rank2);
		user:setAuth(auth);
		user:setMoney(coin2);
        user:setClient_version(tonumber(json.decode_node(client_version).client_version:get_value()));
        info.user = user;


		
	else
		info.gameType = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 棋局类型  1 普通场	2 十分钟场 3 二十分钟场
		local uid1 = self.m_socket:readInt(packetId,ERROR_NUMBER);    --
		info.rank1 = self.m_socket:readInt(packetId,ERROR_NUMBER);   --当前排名  -1则为得不到当前排名
		
		info.coin1 = self.m_socket:readInt(packetId,ERROR_NUMBER);   --自己的金币

	end

	UserInfo.getInstance():setRank(info.rank1);
	UserInfo.getInstance():setMoney(info.coin1);

    return info;


end;





HallSocketReader.onRecvClientMsgHomepress = function(self, packetId)
    print_string("======服务器回应房间CLIENT_MSG_HOMEPRESS======");
	local errorCode = self.m_socket:readShort(packetId,ERROR_NUMBER);  --错误码 0   成功 -1  Tid 不合法，找不到棋桌 -2  棋局已经结束，用户不在棋桌

	local errorMsg = self.m_socket:readString(packetId,ERROR_STRING); --错误信息


	local data = {};

	data.tid = self.m_socket:readShort(packetId,ERROR_NUMBER);     --棋桌ID 

	data.time = self.m_socket:readShort(packetId,ERROR_NUMBER);   -->0 多久倒计时就会结束 <0 定时器停止

	data.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);          --  按下（或回来）home键的用户ID

	return data;
    

end;




HallSocketReader.onRecvClientMsgHeart = function(self, packetId)

		local errorCode = self.m_socket:readShort(packetId,ERROR_NUMBER);  -- 0 成功  其他失败
		local errorMsg = self.m_socket:readString(packetId,ERROR_STRING); --错误信息

end;


HallSocketReader.onRecvClientWatchHeart = function(self, packetId)

		local errorCode = self.m_socket:readShort(packetId,ERROR_NUMBER);  -- 0 成功  其他失败
		local errorMsg = self.m_socket:readString(packetId,ERROR_STRING); --错误信息

end;









HallSocketReader.onRecvClientWatchLogout = function(self, packetId)
    local errorCode = self.m_socket:readShort(packetId,ERROR_NUMBER);  --错误码 0 成功 
	local errorMsg = self.m_socket:readString(packetId,ERROR_STRING); --错误信息
    if errorCode == 0 then
        Log.i("成功退出观战房间...")
    end;
end;



HallSocketReader.onRecvClientWatchUserlist = function(self, packetId)

    
    print_string("======服务器回应房间CLIENT_WATCH_USERLIST======");
	local errorCode = self.m_socket:readShort(packetId,ERROR_NUMBER);  --错误码 0 成功   其他失败
	local errorMsg = self.m_socket:readString(packetId,ERROR_STRING); --错误信息


	if(errorCode == 0) then

	else
		print_string("CLIENT_WATCH_USERLIST errorCode ~= 0");
		return;
	end
	local total = self.m_socket:readShort(packetId,ERROR_NUMBER);          --总条数
	local count = self.m_socket:readShort(packetId,ERROR_NUMBER);    --当前返回条数

	local list = {}
	for index = 1,count do
		local watcher = {};

		watcher.seatID = self.m_socket:readShort(packetId,ERROR_NUMBER);    --观战座位ID
		watcher.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);    --观战用户ID
		watcher.name = self.m_socket:readString(packetId,ERROR_STRING); --观战用户名称
		watcher.title = self.m_socket:readString(packetId,ERROR_STRING); --观战称号
		watcher.wintimes = self.m_socket:readInt(packetId,ERROR_NUMBER);  --赢棋盘数
		watcher.losetimes = self.m_socket:readInt(packetId,ERROR_NUMBER);  --输棋盘数
		watcher.drawtimes = self.m_socket:readInt(packetId,ERROR_NUMBER);   --和棋盘数
		table.insert(list,watcher);
	end
	
    return total;

end;



HallSocketReader.onRecvClientWatchTrends = function(self, packetId)

    Log.i("==========HallSocketReader.onRecvClientWatchTrends============");
    

    local info = {}
    local subcmd = self.m_socket:readSubCmd(packetId);
    info.subcmd = subcmd;
    print_string(string.format("======服务器回应房间CLIENT_WATCH_TRENDS====== sumcmd = [0x%02x] ",subcmd));
	--此通知既要通知观战者也要通知棋手
	if subcmd == WATCH_SUB_LOGIN  then
        
		local seatID = self.m_socket:readShort(packetId,ERROR_NUMBER); -- 座位ID
	    local userID = self.m_socket:readInt(packetId,ERROR_NUMBER); -- 观战者ID
	    local name = self.m_socket:readString(packetId); -- 观战者昵称
	    local icon = self.m_socket:readString(packetId);   --观战者头像链接
	    local sex = self.m_socket:readShort(packetId,ERROR_NUMBER);   -- 观战者性别 0未知，1男性，2女性
	    local wintimes = self.m_socket:readInt(packetId,ERROR_NUMBER);  --观战者赢棋盘数
	    local losetimes = self.m_socket:readInt(packetId,ERROR_NUMBER);  --观战者输棋盘数
	    local drawtimes = self.m_socket:readInt(packetId,ERROR_NUMBER);   --DrawCount
	    local score = self.m_socket:readInt(packetId,ERROR_NUMBER); -- 观战者经验值
	    local coin = self.m_socket:readInt(packetId,ERROR_NUMBER);   --自己的金币
	    local rank = self.m_socket:readInt(packetId,ERROR_NUMBER);   --观战者当前排名  -1则为得不到当前排名
	    local title = self.m_socket:readString(packetId);  --观战者等级头衔
	    local jsonStr = self.m_socket:readString(packetId); -- 观战者其它信息
 	    print_string("WATCH_SUB_LOGIN name" .. name );
        info.newUser = 1;
        return info;

	elseif subcmd == WATCH_SUB_LEAVE then   --观战者离开通知
		local uid = self.m_socket:readInt(packetId,ERROR_NUMBER);  
        info.newUser = -1;
        return info;

	elseif subcmd == WATCH_MSG_LEAVE then   --棋手离开通知 注：只要有一个下棋者离开就观战结束，所有观战人员都离开
	    info.tableID = self.m_socket:readShort(packetId,ERROR_NUMBER);         -- 棋桌ID
	    info.tableStatus = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 棋局状态
	    info.player1ID = self.m_socket:readInt(packetId,ERROR_NUMBER);         --玩家ID
	    info.player1Status = self.m_socket:readShort(packetId,ERROR_NUMBER); 	 -- 玩家状态
	    info.player2ID = self.m_socket:readInt(packetId,ERROR_NUMBER);         --玩家ID
	    info.player2Status = self.m_socket:readShort(packetId,ERROR_NUMBER);   -- 玩家状态
	    info.leaveID = self.m_socket:readInt(packetId,ERROR_NUMBER);        	 --离开者ID

        return info;

	elseif subcmd == WATCH_MSG_READY then   --棋手准备开始通知
	    info.tableID = self.m_socket:readShort(packetId,ERROR_NUMBER);     --棋桌ID 
	    info.tableStatus = self.m_socket:readShort(packetId,ERROR_NUMBER);     --棋桌状态
	    info.player1ID = self.m_socket:readInt(packetId,ERROR_NUMBER);          --  玩家1ID
	    info.player1Status = self.m_socket:readShort(packetId,ERROR_NUMBER);          --玩家1状态
	    info.player2ID = self.m_socket:readInt(packetId,ERROR_NUMBER);          --  玩家2ID
	    info.player2Status = self.m_socket:readShort(packetId,ERROR_NUMBER);          --玩家s状态

	    info.startID = self.m_socket:readInt(packetId,ERROR_NUMBER);        	 --准备者ID

        return info;

	elseif subcmd == WATCH_MSG_GAME_START then   --棋局开始
	    info.player1ID = self.m_socket:readInt(packetId,ERROR_NUMBER);          --  玩家1ID
	    info.player1Status = self.m_socket:readShort(packetId,ERROR_NUMBER);          --玩家1状态
	    info.player2ID = self.m_socket:readInt(packetId,ERROR_NUMBER);          --  玩家2ID
	    info.player2Status = self.m_socket:readShort(packetId,ERROR_NUMBER);          --玩家s状态

	    info.tableID = self.m_socket:readShort(packetId,ERROR_NUMBER);     --棋桌ID 
	    info.tableStatus = self.m_socket:readShort(packetId,ERROR_NUMBER);     --棋桌状态

	    info.timeOut1 = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 局时（秒）
	    info.timeOut2 = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 步时（秒）
	    info.timeOut3 = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 读秒（秒）

	    info.redID = self.m_socket:readInt(packetId,ERROR_NUMBER);          --  根据红黑方ID是否与自己相符合，决定是否换对调棋桌
	    info.blackID = self.m_socket:readInt(packetId,ERROR_NUMBER);          --  玩家1ID


	    info.chess_map = {}
	    for i = 90,1,-1 do
		    info.chess_map[i] = self.m_socket:readByte(packetId,ERROR_NUMBER);        --整盘棋局
	    end
	    return info;
	elseif subcmd == WATCH_MSG_GAME_CLOSE then   --棋局结束
	    info.tableID = self.m_socket:readShort(packetId,ERROR_NUMBER);     --观战服务器Tid 
	    info.tableStatus = self.m_socket:readShort(packetId,ERROR_NUMBER);     --棋桌状态

	    info.player1ID = self.m_socket:readInt(packetId,ERROR_NUMBER);          --  玩家1ID
	    info.player1Status = self.m_socket:readShort(packetId,ERROR_NUMBER);          --玩家1状态
	    info.player2ID = self.m_socket:readInt(packetId,ERROR_NUMBER);          --  玩家2ID
	    info.player2Status = self.m_socket:readShort(packetId,ERROR_NUMBER);          --玩家s状态

	    info.flag = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 棋局结果 0 和棋 1 红方胜利  2 黑方胜利

	    info.scoreRed = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 红方扣/加分
	    info.totalscoreRed = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 红方最新总分
	    info.levelRed = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 
	    info.titleRed = self.m_socket:readString(packetId);     -- 红方最新头衔
	    info.redRank = self.m_socket:readInt(packetId,ERROR_NUMBER);                --红方最新排名
	    info.redCoin = self.m_socket:readInt(packetId,ERROR_NUMBER);                --红方扣/加金币
	    info.redTotalCoin = self.m_socket:readInt(packetId,ERROR_NUMBER);              --红方总金币
	    info.redTaxes = self.m_socket:readInt(packetId,ERROR_NUMBER);                --红方棋桌费


	    info.scoreBlack = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 黑方扣/加分
	    info.totalscoreBlack = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 黑方最新总分
	    info.levelBlack = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 黑方最新等级
	    info.titleBlack = self.m_socket:readString(packetId);     -- 黑方最新头衔
	    info.blackRank = self.m_socket:readInt(packetId,ERROR_NUMBER);              --黑方最新排名
	    info.blackCoin= self.m_socket:readInt(packetId,ERROR_NUMBER);              --黑方扣/加金币
	    info.blackTotalCoin = self.m_socket:readInt(packetId,ERROR_NUMBER);            --黑方总金币
	    info.blackTaxes = self.m_socket:readInt(packetId,ERROR_NUMBER);              --黑方棋桌费

	    info.endType = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 游戏结束类型

        return info;

	elseif subcmd == WATCH_MSG_MOVE then   --走棋
        
	    info.chessMan = self.m_socket:readShort(packetId,ERROR_NUMBER);     --棋子
	    info.position1 = self.m_socket:readShort(packetId,ERROR_NUMBER);     --当前位置
	    info.position2 = self.m_socket:readShort(packetId,ERROR_NUMBER);     --移动位置
	    info.tableStatus = self.m_socket:readShort(packetId,ERROR_NUMBER);     --棋局状态
	    info.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);          --  走棋者ID
	    info.timeout = self.m_socket:readShort(packetId,ERROR_NUMBER);     --局时（秒）

	    info.errorCode = self.m_socket:readShort(packetId,ERROR_NUMBER);  --走棋结果
	    
        return info;

	elseif subcmd == WATCH_SUB_CHAT then   --观战者聊天信息
	    print_string("======服务器回应房间WATCH_SUB_CHAT======" );
	    info.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);         --对手ID
	    info.name = self.m_socket:readString(packetId);      			   --名字
	    info.msgType = self.m_socket:readShort(packetId,ERROR_NUMBER);   --消息类型
	    info.message = self.m_socket:readString(packetId); 
	    self.m_socket:readEnd(packetId);

	    if not info.uid or not info.name or not info.message then
		    print_string("not uid or not name or not message "  );
		    return;
	    end
	
	    info.message = GameString.convert2UTF8(info.message);

        return info;

	elseif subcmd == WATCH_MSG_CHAT then   --棋手聊天信息
	    print_string("======服务器回应房间WATCH_MSG_CHAT======" );
	    info.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);         --对手ID
	    info.name = self.m_socket:readString(packetId);      			   --名字
	    info.msgType = self.m_socket:readShort(packetId,ERROR_NUMBER);   --消息类型
	    info.message = self.m_socket:readString(packetId); 
	    self.m_socket:readEnd(packetId);

	    if not info.uid or not info.name or not info.message then
		    print_string("not uid or not name or not message "  );
		    return;
	    end
	    info.message = GameString.convert2UTF8(info.message);
	
        return info;

	elseif subcmd == WATCH_MSG_DRAW then   --和棋推送
	    info.tableID = self.m_socket:readShort(packetId,ERROR_NUMBER);     --棋桌ID 
	    info.tableStatus = self.m_socket:readShort(packetId,ERROR_NUMBER);     --棋桌状态
	    info.player1ID = self.m_socket:readInt(packetId,ERROR_NUMBER);          --  玩家1ID
	    info.player1Status = self.m_socket:readShort(packetId,ERROR_NUMBER);          --玩家1状态
	    info.player2ID = self.m_socket:readInt(packetId,ERROR_NUMBER);          --  玩家2ID
	    info.player2Status = self.m_socket:readShort(packetId,ERROR_NUMBER);          --玩家s状态

	    info.drawID = self.m_socket:readInt(packetId,ERROR_NUMBER);        	 --准备者ID

        return info;


	elseif subcmd == WATCH_MSG_SURRENDER then   --投降推送
	    info.tableID = self.m_socket:readShort(packetId,ERROR_NUMBER);         --棋桌ID 
	    info.tableStatus = self.m_socket:readShort(packetId,ERROR_NUMBER);     --棋桌状态
	    info.player1ID = self.m_socket:readInt(packetId,ERROR_NUMBER);          --  玩家1ID
	    info.player1Status = self.m_socket:readShort(packetId,ERROR_NUMBER);          --玩家1状态
	    info.player2ID = self.m_socket:readInt(packetId,ERROR_NUMBER);          --  玩家2ID
	    info.player2Status = self.m_socket:readShort(packetId,ERROR_NUMBER);          --玩家s状态

	    info.faultID = self.m_socket:readInt(packetId,ERROR_NUMBER);        	 --准备者ID
        return info;


	elseif subcmd == WATCH_MSG_UNDOMOVE then   --悔棋推送

	    info.tableID = self.m_socket:readShort(packetId,ERROR_NUMBER);        --棋桌ID
	    info.tableStatus = self.m_socket:readShort(packetId,ERROR_NUMBER);    --棋桌状态

	    info.undoID = self.m_socket:readInt(packetId,ERROR_NUMBER);           --悔棋申请者ID
	


	    info.chessID1 = self.m_socket:readShort(packetId,ERROR_NUMBER);    --棋子ID 0表示当前棋子不可用
	    info.position1_1 = self.m_socket:readShort(packetId,ERROR_NUMBER);   --当前位置
	    info.position1_2 = self.m_socket:readShort(packetId,ERROR_NUMBER);    --移动位置
	    info.eatChessID1 = self.m_socket:readShort(packetId,ERROR_NUMBER);    --被吃棋子ID  0表示没有被吃棋子
	
	    info.chessID2 = self.m_socket:readShort(packetId,ERROR_NUMBER); 
	    info.position2_1 = self.m_socket:readShort(packetId,ERROR_NUMBER); 
	    info.position2_2 = self.m_socket:readShort(packetId,ERROR_NUMBER); 
	    info.eatChessID2 = self.m_socket:readShort(packetId,ERROR_NUMBER); 

        return info;

	elseif subcmd == WATCH_MSG_WARING then   --悔棋推送
        print_string("======服务器回应房间WATCH_MSG_WARING======");

        
	    info.type = self.m_socket:readShort(packetId,ERROR_NUMBER);  --消息类型
	    info.msg = self.m_socket:readString(packetId,ERROR_STRING); --错误信息

        return info;
	end

end;





------------------------------room's hallSocket-----------------------------

HallSocketReader.onRecvHallMsgQuickStart = function(self, packetId)
    Log.i("HallSocketReader.onRecvHallMsgQuickStart");
    
    local errorCode = self.m_socket:readShort(packetId, -1);
    local errorMsg = self.m_socket:readString(packetId );
    if errorCode < 0 then
        return;
    end;
    local info = {};
    info.svid = self.m_socket:readShort(packetId,-1);  --服务器ID
    info.hostIP = self.m_socket:readString(packetId);  --服务器地址
    info.port = self.m_socket:readShort(packetId,-1);      --端口
    info.gameType = self.m_socket:readShort(packetId,-1);   --游戏场类型
    info.ltid = self.m_socket:readShort(packetId,-1);   --棋桌ID
    info.uid = self.m_socket:readInt(packetId,-1);     --用户ID
    -- local moneyType =  self.m_socket:readShort(packetId,-100); --金币场类型
    return info;

end;


--HallSocketReader.onRecvHallMsgGameInfo = function(self, packetId)
-- 	local errorCode = self.m_socket:readShort(packetId, -1);
-- 	local errorMsg = self.m_socket:readString(packetId );
--    local info = {};
--    if errorCode < 0 then

--        return info;
--    end;

-- 	info.svid = self.m_socket:readShort(packetId,-1);  --服务器ID
--	info.hostIP = self.m_socket:readString(packetId);  --服务器地址
--	info.port = self.m_socket:readShort(packetId,-1);      --端口
--	info.gameType = self.m_socket:readShort(packetId,-1);   --游戏场类型
--	info.ltid = self.m_socket:readShort(packetId,-1);   --棋桌ID
--	info.uid = self.m_socket:readInt(packetId,-1);     --用户ID
--	-- local moneyType =  self.m_socket:readShort(packetId,-1); --金币场类型
--    return info;


--end;


HallSocketReader.onRecvClientHallPrivaterRoomList = function(self,packetId)
    local info = {};
    info.version = self.m_socket:readByte(packetId,0);
    info.pageNum = self.m_socket:readInt(packetId,0);
    info.curPage = self.m_socket:readInt(packetId,0);
    info.itemNum = self.m_socket:readInt(packetId,0);
    info.items = {};
    for i=1,info.itemNum do
        info.items[i]={};
        info.items[i].tid = self.m_socket:readInt(packetId,0);
        info.items[i].ownerId = self.m_socket:readInt(packetId,0);
        info.items[i].name = self.m_socket:readString(packetId,"");
        info.items[i].isPassword = self.m_socket:readByte(packetId,0);

        info.items[i].basechip = self.m_socket:readInt(packetId,0);
        info.items[i].tableStatus = self.m_socket:readShort(packetId,0);
        info.items[i].userCount = self.m_socket:readShort(packetId,0);
        info.items[i].round_time = self.m_socket:readShort(packetId,0);
        info.items[i].step_time = self.m_socket:readShort(packetId,0);
        info.items[i].sec_time = self.m_socket:readShort(packetId,0);
    end
    return info;
end

HallSocketReader.onRecvClientHallCreatePrivateRoom = function(self,packetId)
    local info = {};
    info.ret = self.m_socket:readInt(packetId,1);
    info.tid = self.m_socket:readInt(packetId,0);
    info.svid = self.m_socket:readInt(packetId,0);
    info.ip = self.m_socket:readString(packetId,"");
    info.port = self.m_socket:readInt(packetId,0);
    return info;
end

HallSocketReader.onRecvClientHallJoinPrivateRoom = function(self,packetId)
    local info = {};
    info.ret = self.m_socket:readInt(packetId,1);
    info.tid = self.m_socket:readInt(packetId,0);
    info.svid = self.m_socket:readInt(packetId,0);
    info.ip = self.m_socket:readString(packetId,"");
    info.port = self.m_socket:readInt(packetId,0);
    return info;
end

HallSocketReader.onRecvClientHallBroadcastMsg = function(self,packetId)
    local info = {};
    info.msg = self.m_socket:readString(packetId);
    return info;
end

HallSocketReader.onRecvFriendCmdOnlineNum = function(self,packetId)
    local info = {};
    info.uid = self.m_socket:readInt(packetId,0);
    info.online_num = self.m_socket:readInt(packetId,0);
    return info;
end

HallSocketReader.onRecvFriendCmdCheckUserStatus = function(self,packetId)
    local info = {};
    info.item_num = self.m_socket:readInt(packetId,0);
    info.items = {};
    for i=1,info.item_num do
        info.items[i] = {};
        info.items[i].uid = self.m_socket:readInt(packetId,0);
        info.items[i].relation = self.m_socket:readByte(packetId,0); -- =0,陌生人,=1粉丝，=2关注，=3好友
        info.items[i].last_time = self.m_socket:readInt(packetId,0); --最后登录时间, <0为超出最大保存时间
        info.items[i].hallid = self.m_socket:readInt(packetId,0); -- >0标识用户在线
        info.items[i].tid = self.m_socket:readInt(packetId,0); -- >0标识用户在下棋=
        info.items[i].level = self.m_socket:readInt(packetId,0); -- 下棋所在的场次
    end 
    return info;
end

HallSocketReader.onRecvFriendCmdCheckUserData = function(self,packetId)
    local info = {};
    info.item_num = self.m_socket:readInt(packetId,0);
    info.items = {};
    for i=1,info.item_num do
        info.items[i] = {};
        info.items[i].uid = self.m_socket:readInt(packetId,0);
        info.items[i].userInfo = self.m_socket:readString(packetId);
    end 
    return info;
end

HallSocketReader.onRecvFriendCmdGetFriendsNum = function(self,packetId)
    local info = {};
    info.uid = self.m_socket:readInt(packetId,0);
    info.num = self.m_socket:readInt(packetId,0);
    return info;
end

HallSocketReader.onRecvFriendCmdGetFollowNum = function(self,packetId)
    local info = {};
    info.uid = self.m_socket:readInt(packetId,0);
    info.num = self.m_socket:readInt(packetId,0);
    return info;
end

HallSocketReader.onRecvFriendCmdGetFansNum = function(self,packetId)
    local info = {};
    info.uid = self.m_socket:readInt(packetId,0);
    info.num = self.m_socket:readInt(packetId,0);
    return info;
end

HallSocketReader.onRecvFriendCmdGetFriendsList = function(self,packetId)
    local info = {};
    info.uid = self.m_socket:readInt(packetId,0);
    info.total_count = self.m_socket:readShort(packetId,0);
    info.page_num = self.m_socket:readShort(packetId,0);
    info.curr_page = self.m_socket:readShort(packetId,0);
    info.item_num = self.m_socket:readShort(packetId,0);
    info.friend_uid = {};
    for i=1,info.item_num do
        info.friend_uid[i] = self.m_socket:readInt(packetId,0);
    end
    return info;
end

HallSocketReader.onRecvFriendCmdGetFollowList = function(self,packetId)
    local info = {};
    info.uid = self.m_socket:readInt(packetId,0);
    info.total_count = self.m_socket:readShort(packetId,0);
    info.page_num = self.m_socket:readShort(packetId,0);
    info.curr_page = self.m_socket:readShort(packetId,0);
    info.item_num = self.m_socket:readShort(packetId,0);
    info.friend_uid = {};
    for i=1,info.item_num do
        info.friend_uid[i] = self.m_socket:readInt(packetId,0);
    end
    return info;
end

HallSocketReader.onRecvFriendCmdGetFansList = function(self,packetId)
    local info = {};
    info.uid = self.m_socket:readInt(packetId,0);
    info.total_count = self.m_socket:readShort(packetId,0);
    info.page_num = self.m_socket:readShort(packetId,0);
    info.curr_page = self.m_socket:readShort(packetId,0);
    info.item_num = self.m_socket:readShort(packetId,0);
    info.friend_uid = {};
    for i=1,info.item_num do
        info.friend_uid[i] = self.m_socket:readInt(packetId,0);
    end
    return info;
end

HallSocketReader.onRecvFriendCmdGetFollow = function(self,packetId)
    local info = {};
    info.ret = self.m_socket:readInt(packetId,0);
    info.uid = self.m_socket:readInt(packetId,0);
    info.target_uid = self.m_socket:readInt(packetId,0);
    info.relation = self.m_socket:readByte(packetId,0);

    return info;
end

HallSocketReader.onRecvFriendCmdGetFriendsRank = function(self,packetId)
    local info = {};
    info.uid = self.m_socket:readInt(packetId,0);
    info.self_rank = self.m_socket:readInt(packetId,0);
    info.item_num = self.m_socket:readInt(packetId,0);
    info.item = {};
    for i=1,info.item_num do
        info.item[i] = {};
        info.item[i].uid= self.m_socket:readInt(packetId,0);
        info.item[i].score = self.m_socket:readInt(packetId,0);
    end

    return info;
end

HallSocketReader.onRecvFriendCmdGetOnlyFriendsRank = function(self,packetId)
    local info = {};
    info.uid = self.m_socket:readInt(packetId,0);
    info.ret = self.m_socket:readInt(packetId,0);
    info.target_uid = self.m_socket:readInt(packetId,0);
    info.rank = self.m_socket:readInt(packetId,0);

    return info;
end


HallSocketReader.onRecvFriendCmdGetOnlyFriendsNum = function(self,packetId)--好友数目
    local info = {};
    info.uid = self.m_socket:readInt(packetId,0);
    info.num = self.m_socket:readInt(packetId,0);
    return info;
end

HallSocketReader.onRecvFriendCmdGetOnlyFollowNum = function(self,packetId)--关注数目
    local info = {};
    info.uid = self.m_socket:readInt(packetId,0);
    info.num = self.m_socket:readInt(packetId,0);

    return info;
end

HallSocketReader.onRecvFriendCmdGetOnlyFansNum = function(self,packetId)--粉丝数目
    local info = {};
    info.uid = self.m_socket:readInt(packetId,0);
    info.num = self.m_socket:readInt(packetId,0);

    return info;
end


HallSocketReader.onRecvFriendCmdGetUnreadMsg = function(self,packetId)
    local info = {};
    info.uid = self.m_socket:readInt(packetId,0);
    info.unread_msg_num = self.m_socket:readInt(packetId,0);
    if info.unread_msg_num > 0 then
        info.msg = self.m_socket:readString(packetId);
    end
    return info;
end

HallSocketReader.onRecvFriendCmdChatMsg = function(self,packetId)
    local info = {};
    info.uid = self.m_socket:readInt(packetId,0);
    info.ret = self.m_socket:readInt(packetId,0);
    info.msg_id = self.m_socket:readInt(packetId,0);
    info.forbid_time = self.m_socket:readInt(packetId,0);
    return info;
end

HallSocketReader.onRecvServerCreateFriendRoom = function(self,packetId)
    local info = {};
    info.ret = self.m_socket:readInt(packetId,1);
    info.tid = self.m_socket:readInt(packetId,0);
    info.svid = self.m_socket:readInt(packetId,0);
    info.ip = self.m_socket:readString(packetId,"");
    info.port = self.m_socket:readInt(packetId,0);
    return info;
end

HallSocketReader.onRecvServerInviteRequest = function(self,packetId)
    local info = {};
    info.ret = self.m_socket:readInt(packetId,1);
    info.target_uid = self.m_socket:readInt(packetId,0);
    info.target_hallid = self.m_socket:readInt(packetId,0);
    info.target_tid = self.m_socket:readInt(packetId,0);
    info.target_level = self.m_socket:readInt(packetId,0);
    info.relation = self.m_socket:readInt(packetId,0);
    return info;
end

HallSocketReader.onRecvClientInviteNotify = function(self,packetId)
    local info = {};
    info.uid = self.m_socket:readInt(packetId,0);
    info.tid = self.m_socket:readInt(packetId,0);
    info.time_out = self.m_socket:readInt(packetId,0);
    return info;
end

HallSocketReader.onRecvClientInviteResponse = function(self,packetId)
    local info = {};
    info.uid = self.m_socket:readInt(packetId,0);
    info.ret = self.m_socket:readInt(packetId,1);
    return info;
end

HallSocketReader.onRecvClientInviteResponse2 = function(self,packetId)
    local info = {};
    info.target_uid = self.m_socket:readInt(packetId,0);
    info.uid = self.m_socket:readInt(packetId,0);
    info.ret = self.m_socket:readInt(packetId,1);
    return info;
end

HallSocketReader.onRecvServerResetTable = function(self,packetId)
    local info = {};
    info.ret = self.m_socket:readInt(packetId,1);
    info.new_status = self.m_socket:readInt(packetId,0);
    return info;
end

HallSocketReader.onRecvServerSetTime = function(self,packetId)
    local info = {};
    info.uid = self.m_socket:readInt(packetId,0);
    info.time_out = self.m_socket:readInt(packetId,0);
    return info;
end

HallSocketReader.onRecvServerSetTimeNotify = function(self,packetId)
    local info = {};
    info.uid = self.m_socket:readInt(packetId,0);
    info.round_time = self.m_socket:readInt(packetId,0);
    info.step_time = self.m_socket:readInt(packetId,0);
    info.sec_time = self.m_socket:readInt(packetId,0);
    info.time_out = self.m_socket:readInt(packetId,0);
    return info;
end

HallSocketReader.onRecvServerSetTimeResponse = function(self,packetId)
    local info = {};
    info.uid = self.m_socket:readInt(packetId,0);
    info.ret = self.m_socket:readInt(packetId,1);
    return info;
end

HallSocketReader.onRecvServerNewLoginSuccess = function(self,packetId)
    local info = {};
    info.level = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.basechip = self.m_socket:readInt(packetId,ERROR_NUMBER);
    return info;
end

HallSocketReader.onRecvServerNewWatchMsg = function(self,packetId)
    local info = {};
    info.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.name = self.m_socket:readString(packetId,ERROR_STRING);
    info.chat_msg = self.m_socket:readString(packetId,ERROR_STRING);
    info.forbid_time = self.m_socket:readInt(packetId,ERROR_NUMBER);-- forbid_time：-1，屏蔽频繁发送;0，发送成功；>0，禁言时间
    return info;
end

HallSocketReader.onRecvServerNewTableInfo = function(self,packetId)
    print_string("======【观战】桌子信息======HallSocketReader.onRecvServerNewTableInfo");
    local info = {};
    info.tid = self.m_socket:readInt(packetId,ERROR_NUMBER);--棋桌id
    info.status = self.m_socket:readShort(packetId,ERROR_NUMBER);--状态
    info.curr_move_flag = self.m_socket:readInt(packetId,ERROR_NUMBER);--当前走棋方UID
    
    info.round_time = self.m_socket:readInt(packetId,ERROR_NUMBER); --局时
    info.step_time = self.m_socket:readInt(packetId,ERROR_NUMBER);--步时
    info.sec_time = self.m_socket:readInt(packetId,ERROR_NUMBER); --读秒
 
    info.play_count = self.m_socket:readInt(packetId,ERROR_NUMBER); --读秒
    info.red_uid = self.m_socket:readInt(packetId,ERROR_NUMBER);--红方uid
    info.red_user = self.m_socket:readString(packetId);--红方user信息

    info.black_uid = self.m_socket:readInt(packetId,ERROR_NUMBER);--黑方uid
    info.black_user = self.m_socket:readString(packetId);--黑方user信息

    if info.status == 2 then--server逻辑，只有在状态2（playing）才有下面信息
        info.red_round_timeout = self.m_socket:readShort(packetId,ERROR_NUMBER);   --红方已用局时
        info.red_step_timeout = self.m_socket:readShort(packetId,ERROR_NUMBER);    --红方剩余步时
        info.red_sec_timeout = self.m_socket:readShort(packetId,ERROR_NUMBER);     --红方剩余读秒
        info.black_round_timeout = self.m_socket:readShort(packetId,ERROR_NUMBER); --黑方已用局时
        info.black_step_timeout = self.m_socket:readShort(packetId,ERROR_NUMBER);  --黑方剩余步时
        info.black_sec_timeout = self.m_socket:readShort(packetId,ERROR_NUMBER);   --黑方剩余读秒
	    info.chess_map = {}
	    for i = 90,1,-1 do
		    info.chess_map[i] = self.m_socket:readByte(packetId,ERROR_NUMBER);--整盘棋局
	    end    
        info.chessMan = self.m_socket:readShort(packetId,ERROR_NUMBER);     --棋子
        info.position1 = self.m_socket:readShort(packetId,ERROR_NUMBER);     --当前位置
        info.position2 = self.m_socket:readShort(packetId,ERROR_NUMBER);     --移动位置
    end;

    if info.red_user and info.red_user ~= "" then
        local user = new(User);
        local red_user = json.decode(info.red_user);
	    user:setUid(red_user.uid);
	    user:setName(red_user.user_name);
	    user:setScore(red_user.score);
	    user:setLevel(red_user.level);
	    user:setFlag(FLAG_RED);
	    user:setIcon(red_user.icon,red_user.uid);
	    user:setSex(red_user.sex);
	    user:setWintimes(red_user.wintimes);
	    user:setLosetimes(red_user.losetimes);
	    user:setDrawtimes(red_user.drawtimes);
	    user:setSource(red_user.source);
	    user:setSitemid(red_user.sitemid);
	    user:setPlaturl(red_user.platurl);
	    user:setRank(red_user.rank);
	    user:setAuth(red_user.auth);
	    user:setMoney(red_user.money);
        user:setTimeout1((info.round_time - (info.red_round_timeout or 0)));
	    user:setTimeout2(info.red_step_timeout or 0);
	    user:setTimeout3(info.red_sec_timeout or 0);
        user:setVip(red_user.is_vip);
        user:setVersion(red_user.version);
        user:setClient_version(red_user.client_version);
        info.player1 = user;
    end

    if info.black_user and info.black_user ~= "" then
        local user = new(User);
        local black_user = json.decode(info.black_user);
	    user:setUid(black_user.uid);
	    user:setName(black_user.user_name);
	    user:setScore(black_user.score);
	    user:setLevel(black_user.level);
	    user:setFlag(FLAG_BLACK);
	    user:setIcon(black_user.icon,black_user.uid);
	    user:setSex(black_user.sex);
	    user:setWintimes(black_user.wintimes);
	    user:setLosetimes(black_user.losetimes);
	    user:setDrawtimes(black_user.drawtimes);
	    user:setSource(black_user.source);
	    user:setSitemid(black_user.sitemid);
	    user:setPlaturl(black_user.platurl);
	    user:setRank(black_user.rank);
	    user:setAuth(black_user.auth);
	    user:setMoney(black_user.money);
        user:setTimeout1((info.round_time - (info.black_round_timeout or 0)));
	    user:setTimeout2(info.black_step_timeout or 0);
	    user:setTimeout3(info.black_sec_timeout or 0);
        user:setVip(black_user.is_vip);
        user:setVersion(black_user.version);
        user:setClient_version(black_user.client_version);
        info.player2 = user;
    end
    return info;
end

HallSocketReader.onRecvServerNewWatchList = function(self,packetId)
    local info = {};
    info.total_count = self.m_socket:readShort(packetId,ERROR_NUMBER);
    info.page_num = self.m_socket:readShort(packetId,ERROR_NUMBER);
    info.curr_page = self.m_socket:readShort(packetId,ERROR_NUMBER);
    info.item_num = self.m_socket:readShort(packetId,ERROR_NUMBER);
    info.watch_items = {};
    for index = 1, info.item_num do
        local watch_item = {};
        watch_item.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);
        watch_item.userInfo = self.m_socket:readString(packetId,ERROR_STRING);
        table.insert(info.watch_items,watch_item);
    end;
    return info;
end

HallSocketReader.onRecvServerNewPlayerEnter = function(self,packetId)
    local info = {};
    info.tid = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.status = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.play_count = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.userInfo = self.m_socket:readString(packetId,ERROR_STRING);

    local user = new(User);
    local userData = json.decode(info.userInfo);
	user:setUid(userData.uid);
	user:setName(userData.user_name);
	user:setScore(userData.score);
	user:setLevel(userData.level);
	user:setFlag(0);
	user:setIcon(userData.icon,userData.uid);
	user:setSex(userData.sex);
	user:setWintimes(userData.wintimes);
	user:setLosetimes(userData.losetimes);
	user:setDrawtimes(userData.drawtimes);
	user:setSource(userData.source);
	user:setSitemid(userData.sitemid);
	user:setPlaturl(userData.platurl);
	user:setRank(userData.rank);
	user:setAuth(userData.auth);
	user:setMoney(userData.money);
    user:setTimeout1(0);
	user:setTimeout2(0);
	user:setTimeout3(0);
    user:setVip(userData.is_vip);
    user:setVersion(userData.version);
    user:setClient_version(userData.client_version);
    info.player = user;
    return info;
end

HallSocketReader.onRecvServerNewPlayerLeave = function(self,packetId)
    local info = {};
    info.tid = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.status = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.play_count = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.userInfo = self.m_socket:readString(packetId,ERROR_STRING);
    return info;
end

HallSocketReader.onRecvServerNewUpdateTable = function(self,packetId)
    local info = {};
    info.tid = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.status = self.m_socket:readShort(packetId,ERROR_NUMBER);
    info.curr_op_uid = self.m_socket:readInt(packetId,ERROR_NUMBER);
    return info;
end

HallSocketReader.onRecvServerNewGameStart = function(self,packetId)
    local info = {};
	info.tid = self.m_socket:readInt(packetId,ERROR_NUMBER);     --棋桌ID 
	info.status = self.m_socket:readInt(packetId,ERROR_NUMBER);     --棋桌状态
	info.round_time = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 局时（秒）
	info.step_time = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 步时（秒）
	info.sec_time = self.m_socket:readShort(packetId,ERROR_NUMBER);     -- 读秒（秒）
	info.red_uid = self.m_socket:readInt(packetId,ERROR_NUMBER);          
	info.black_uid = self.m_socket:readInt(packetId,ERROR_NUMBER);          
	info.chess_map = {}
	for i = 90,1,-1 do
		info.chess_map[i] = self.m_socket:readByte(packetId,ERROR_NUMBER);        --整盘棋局
	end
	return info;
end

HallSocketReader.onRecvServerNewChessMove = function(self,packetId)
    local info = {};
	info.tid = self.m_socket:readInt(packetId,ERROR_NUMBER);             --棋桌ID 
	info.status = self.m_socket:readInt(packetId,ERROR_NUMBER);          --棋桌状态    
    info.last_move_uid = self.m_socket:readInt(packetId,ERROR_NUMBER);   --最后走棋的id  
    info.chessMan = self.m_socket:readShort(packetId,ERROR_NUMBER);      --棋子
	info.position1 = self.m_socket:readShort(packetId,ERROR_NUMBER);     --当前位置
	info.position2 = self.m_socket:readShort(packetId,ERROR_NUMBER);     --移动位置
--    info.ob_num = self.m_socket:readInt(packetId,ERROR_NUMBER);          --观察者数量
    info.red_timeout = self.m_socket:readInt(packetId,ERROR_NUMBER);     --局时（秒）  
    info.black_timeout = self.m_socket:readInt(packetId,ERROR_NUMBER);   --局时（秒）
    return info;
end

HallSocketReader.onRecvServerNewChessUndo = function(self,packetId)
    local info = {};
	info.tid = self.m_socket:readInt(packetId,ERROR_NUMBER);            --棋桌ID 
	info.status = self.m_socket:readInt(packetId,ERROR_NUMBER);         --状态    
	info.curr_move_flag = self.m_socket:readInt(packetId,ERROR_NUMBER); --当前走棋方 
	info.undo_uid = self.m_socket:readInt(packetId,ERROR_NUMBER);       --悔棋方    
	info.chessID1 = self.m_socket:readShort(packetId,ERROR_NUMBER);     --棋子ID 0表示当前棋子不可用
	info.position1_1 = self.m_socket:readShort(packetId,ERROR_NUMBER);  --当前位置
	info.position1_2 = self.m_socket:readShort(packetId,ERROR_NUMBER);  --移动位置
	info.eatChessID1 = self.m_socket:readShort(packetId,ERROR_NUMBER);  --被吃棋子ID  0表示没有被吃棋子
	info.chessID2 = self.m_socket:readShort(packetId,ERROR_NUMBER); 
	info.position2_1 = self.m_socket:readShort(packetId,ERROR_NUMBER); 
	info.position2_2 = self.m_socket:readShort(packetId,ERROR_NUMBER); 
	info.eatChessID2 = self.m_socket:readShort(packetId,ERROR_NUMBER); 
    return info;
end

HallSocketReader.onRecvServerNewChessDraw = function(self,packetId)
    local info = {};
    info.tid = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);--求和uid
    return info;
end

HallSocketReader.onRecvServerNewChessSurrender = function(self,packetId)
    local info = {};
    info.tid = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);--认输uid
    return info;
end

HallSocketReader.onRecvServerNewGameOver = function(self,packetId)
    local info = {};
    info.tid = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.status = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.win_flag = self.m_socket:readShort(packetId,ERROR_NUMBER);
    info.end_type = self.m_socket:readShort(packetId,ERROR_NUMBER);
    info.red_turn_money = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.red_turn_score = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.black_turn_money = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.black_turn_score = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.red_total_money = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.red_total_score = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.black_total_money = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.black_total_score = self.m_socket:readInt(packetId,ERROR_NUMBER);

    return info;
end

HallSocketReader.onRecvServerNewGetNumber = function(self,packetId)
    local info = {};
    info.ob_num = self.m_socket:readInt(packetId,ERROR_NUMBER);
    return info;
end
----
HallSocketReader.onRecvServerEntryChatRoom = function(self,packetId)
    local info = {};
    info.room_id = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.status = self.m_socket:readInt(packetId,ERROR_NUMBER);    -- =0 成功，=1失败
    return info;
end

HallSocketReader.onRecvServerLeftChatRoom = function(self,packetId)
    local info = {};
    info.room_id = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.status = self.m_socket:readInt(packetId,ERROR_NUMBER);
    return info;
end

HallSocketReader.onRecvServerLastMsg = function(self,packetId)
    local info = {};
    info.room_id = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.unread_msg_num = self.m_socket:readInt(packetId,ERROR_NUMBER);
    return info;
end

HallSocketReader.onRecvServerUserMsg = function(self,packetId)
    local info = {};
    info.room_id = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.status = self.m_socket:readInt(packetId,ERROR_NUMBER);
    return info;
end

HallSocketReader.onRecvServerChatMsg = function(self,packetId)
    local info = {};
    info.room_id = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.msg_json = self.m_socket:readString(packetId,ERROR_STRING);
    return info;
end

HallSocketReader.onRecvServerUnreadMsg = function(self,packetId)
    local info = {};
    info.room_id = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.total_count = self.m_socket:readShort(packetId,0);
    info.page_num = self.m_socket:readShort(packetId,0);
    info.curr_page = self.m_socket:readShort(packetId,0);
    info.item_num = self.m_socket:readShort(packetId,0);
    info.item = {};
    for i = 1,info.item_num do
        info.item[i] = self.m_socket:readString(packetId,ERROR_STRING);
    end
    return info;
end

HallSocketReader.onRecvServerUnreadMsgNum = function(self,packetId)
    local info = {};
    info.room_id = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.unread_msg_num = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.room_user_count = self.m_socket:readInt(packetId,ERROR_NUMBER);
    return info;
end


HallSocketReader.onRecvServerGetMemberList = function(self,packetId)
    local info = {};
    info.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.room_id = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.total_num = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.item = {};
    for i = 1,info.total_num do
        info.item[i] = self.m_socket:readInt(packetId,ERROR_NUMBER);
    end
    return info;
end


HallSocketReader.onRecvServerPropCmdUpdateUserData = function(self,packetId)
    local info = {};
    info.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.ret = self.m_socket:readInt(packetId,ERROR_NUMBER); -- =0,成功.!=0,失败
    info.data_json = self.m_socket:readString(packetId,ERROR_STRING);
    return info;
end
HallSocketReader.onRecvServerPropCmdQueryUserData = function(self,packetId)
    local info = {};
    info.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.ret = self.m_socket:readInt(packetId,ERROR_NUMBER); -- =0,成功.!=0,失败
    info.data_json = self.m_socket:readString(packetId,ERROR_STRING);
    return info;
end

HallSocketReader.onRecvServerFriendsWatchList = function(self,packetId)
    local info = {};
    info.total_count = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.total_page = self.m_socket:readShort(packetId,ERROR_NUMBER);
    info.curr_page = self.m_socket:readShort(packetId,ERROR_NUMBER);
    info.item_num = self.m_socket:readShort(packetId,ERROR_NUMBER);
    info.watch_items = {};
    for index = 1, info.item_num do
        local watch_item = {};
        watch_item.tid = self.m_socket:readInt(packetId,ERROR_NUMBER);
        watch_item.red_uid = self.m_socket:readInt(packetId,ERROR_NUMBER);
        watch_item.red_info = self.m_socket:readString(packetId,ERROR_NUMBER);
        watch_item.black_uid = self.m_socket:readInt(packetId,ERROR_NUMBER);
        watch_item.black_info = self.m_socket:readString(packetId,ERROR_NUMBER);
        watch_item.ob_num = self.m_socket:readInt(packetId,ERROR_NUMBER);
        watch_item.play_time = self.m_socket:readInt(packetId,ERROR_NUMBER);
        table.insert(info.watch_items,watch_item);
    end

    return info;
end

HallSocketReader.onRecvServerClientAllocPrivateRoomNum = function(self,packetId)
    local info = {};
    info.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.private_room_num = self.m_socket:readInt(packetId,ERROR_NUMBER);
    return info;
end

HallSocketReader.onRecvServerFriendCmdGeetPlayerInfo = function(self,packetId)
    local info = {};
    info.uid = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.ob_num = self.m_socket:readInt(packetId,ERROR_NUMBER);
    info.spare_num = self.m_socket:readInt(packetId,ERROR_NUMBER);
    return info;
end


HallSocketReader.onRecvServerClientCmdGetTableStep = function(self,packetId)
    local info = {};
    info.total_count = self.m_socket:readShort(packetId,ERROR_NUMBER);
    info.page_num = self.m_socket:readShort(packetId,ERROR_NUMBER);
    info.curr_page = self.m_socket:readShort(packetId,ERROR_NUMBER);
    info.item_num = self.m_socket:readShort(packetId,ERROR_NUMBER);
    info.handicapschessman = self.m_socket:readShort(packetId,ERROR_NUMBER);
    info.tab_step = {};
    for i = 1,info.item_num do
        info.tab_step[i] = {};
        info.tab_step[i].chessID = self.m_socket:readInt(packetId,ERROR_NUMBER);
        info.tab_step[i].moveFrom = self.m_socket:readInt(packetId,ERROR_NUMBER);
        info.tab_step[i].moveTo = self.m_socket:readInt(packetId,ERROR_NUMBER);
        info.tab_step[i].eat_chess = self.m_socket:readInt(packetId,ERROR_NUMBER);
    end
    return info;
end

HallSocketReader.onRecvFriendCmdChatMsg2 = function(self,packetId)
    local info = {};
    info.uid = self.m_socket:readInt(packetId,0);
    info.ret = self.m_socket:readInt(packetId,0);
    info.msg_id = self.m_socket:readInt(packetId,0);
    info.forbid_time = self.m_socket:readInt(packetId,0);
    return info;
end

HallSocketReader.onRecvServerRoomKickOutUser = function(self,packetId)
    local info = {};
    return info;
end

HallSocketReader.onRecvServerCallTelphoneResponse = function(self,packetId)
--    local info = {};
--    info.wait_time = self.m_socket:readInt(packetId,0);
--    return info;
end

HallSocketReader.onRecvServerCallTelphoneBack = function(self,packetId)
--    local info = {};
--    return info;
end

HallSocketReader.onRecvServerBroadcastUserDisconnect = function(self,packetId)
    local info = {};
    info.uid = self.m_socket:readInt(packetId,0);
    return info;
end

HallSocketReader.onRecvServerBroadcastUserReconnect = function(self,packetId)
    local info = {};
    info.uid = self.m_socket:readInt(packetId,0);
    return info;
end

--------------------------------------config-------------------------------



HallSocketReader.s_severCmdFunMap = {

    [HALL_MSG_HEART]                = HallSocketReader.onHallMsgHeart;
	[HALL_MSG_LOGIN]		        = HallSocketReader.onHallMsgLogin;
    [HALL_MSG_GAMEINFO]             = HallSocketReader.onHallMsgGameInfo;
    [HALL_MSG_GAMEPLAY]             = HallSocketReader.onHallMsgGamePlay;
    [HALL_MSG_GETROOMS]             = HallSocketReader.onHallMsgGetRooms;

    [HALL_MSG_SEARCHROOM]           = HallSocketReader.onHallMsgSearchRoom;
    [HALL_MSG_CREATEROOM]           = HallSocketReader.onHallMsgCreateRoom;

    [HALL_MSG_QUICKSTART]           = HallSocketReader.onHallMsgQuickStart;
    [HALL_MSG_CANCELMATCH]          = HallSocketReader.onHallMsgCancelMatch;
    [HALL_MSG_KICKUSER]             = HallSocketReader.onHallMsgKickUser;

    [HALL_MSG_SERVER_PUSH]          = HallSocketReader.onHallMsgServerPush;

    --大厅roomSocket，giveUp命令
    [CLIENT_MSG_RELOGIN]            = HallSocketReader.onClientMsgRelogin;
    [CLIENT_MSG_GIVEUP]             = HallSocketReader.onClientMsgGiveup;


    [CLIENT_WATCH_LOGIN]            = HallSocketReader.onRecvClientWatchLogin;
    [CLIENT_WATCH_LOGOUT]           = HallSocketReader.onRecvClientWatchLogout;
    [CLIENT_WATCH_USERLIST]         = HallSocketReader.onRecvClientWatchUserlist;
    [CLIENT_WATCH_TRENDS]           = HallSocketReader.onRecvClientWatchTrends;
    [CLIENT_WATCH_SYNCHRODATA]      = HallSocketReader.onRecvClientWatchSynData;
    [CLIENT_WATCH_CHAT]             = HallSocketReader.onRecvClientWatchChat;
    [CLIENT_MSG_LOGIN]              = HallSocketReader.onRecvClientMsgLogin;
    [SERVER_MSG_LOGIN_SUCCESS]      = HallSocketReader.onRecvClientMsgLoginSuccess;
    [SERVER_MSG_LOGIN_ERROR]        = HallSocketReader.onRecvServerMsgLoginError;
    [SERVER_MSG_OTHER_ERROR]        = HallSocketReader.onRecvServerMsgOtherError;
    [SERVER_MSG_OPP_USER_INFO]      = HallSocketReader.onRecvClientMsgOppUserInfo;
    [SERVER_MSG_USER_READY]         = HallSocketReader.onRecvServerMsgUserReady;
    [SERVER_MSG_GAME_START]         = HallSocketReader.onRecvServerMsgGameStart;
    [SERVER_MSG_TIMECOUNT_START]    = HallSocketReader.onRecvServerMsgTimeCountStart;
    [SERVER_MSG_RECONNECT]          = HallSocketReader.onRecvServerMsgReconnect;
    [SERVER_MSG_LOGOUT_SUCCESS]     = HallSocketReader.onRecvServerMsgLogoutSuccess;
    [SERVER_MSG_LOGOUT_FAIL]        = HallSocketReader.onRecvServerMsgLogoutFail;
    [SERVER_MSG_USER_LEAVE]         = HallSocketReader.onRecvServerMsgUserLeave;
    [SERVER_MSG_FORESTALL]          = HallSocketReader.onRecvServerMsgForestall;
    [SERVER_MSG_FORESTALL_NEW]      = HallSocketReader.onRecvServerMsgForestallNew;
    [SERVER_MSG_HANDICAP]           = HallSocketReader.onRecvServerMsgHandicap;
    [SERVER_MSG_HANDICAP_RESULT]    = HallSocketReader.onRecvServerMsgHandicapResult;
    [CLIENT_HALL_CANCEL_MATCH]      = HallSocketReader.onRecvServerMsgCancelMatch;


    --观战
    [CLIENT_WATCH_LIST]             = HallSocketReader.onRecvClientWatchList;
    [CLIENT_WATCH_JOIN]             = HallSocketReader.onRecvClientWatchJoin;
    [SERVER_WATCH_START]            = HallSocketReader.onRecvServerWatchStart;
    [SERVER_WATCH_MOVE]             = HallSocketReader.onRecvServerWatchMove;
    [SERVER_WATCH_DRAW]             = HallSocketReader.onRecvServerWatchDraw;
    [SERVER_WATCH_SURRENDER]        = HallSocketReader.onRecvServerWatchSurrender;
    [SERVER_WATCH_UNDO]             = HallSocketReader.onRecvServerWatchUndo;
    [SERVER_WATCH_USERLEAVE]        = HallSocketReader.onRecvServerWatchUserLeave;
    [SERVER_WATCH_GAMEOVER]         = HallSocketReader.onRecvServerWatchGameOver;
    [SERVER_WATCH_ALLREADY]         = HallSocketReader.onRecvServerWatchAllReady;
    [SERVER_WATCH_ERROR]            = HallSocketReader.onRecvServerWatchError;




    [CLIENT_MSG_COMEIN]             = HallSocketReader.onRecvClientMsgComein;
    [CLIENT_MSG_START]              = HallSocketReader.onRecvClientMsgStart;
    [CLIENT_MSG_FORESTALL]          = HallSocketReader.onRecvClientMsgForestall;
    [CLIENT_MSG_RELOGIN]            = HallSocketReader.onRecvClientMsgRelogin;
    [CLIENT_MSG_SYNCHRODATA]        = HallSocketReader.onRecvClientRoomSyn;
    [CLIENT_MSG_WATCHLIST]          = HallSocketReader.onRecvClientMsgWatchlist;
    [CLIENT_GET_OPENBOX_TIME]       = HallSocketReader.onRecvClientGetOpenboxTime;
    [CLIENT_MSG_LEAVE]              = HallSocketReader.onRecvClientMsgLeave;
    [CLIENT_MSG_CHAT]               = HallSocketReader.onRecvClientMsgChat;
    [CLIENT_MSG_HANDICAP]           = HallSocketReader.onRecvClientMsgHandicap;
    [CLIENT_MSG_MOVE]               = HallSocketReader.onRecvClientMsgMove;
    --求和
    [CLIENT_MSG_DRAW1]              = HallSocketReader.onRecvClientMsgDraw1;
    [CLIENT_MSG_DRAW2]              = HallSocketReader.onRecvClientMsgDraw2;
    [SERVER_MSG_DRAW]               = HallSocketReader.onRecvServerMsgDraw;
    --悔棋
    [CLIENT_MSG_UNDOMOVE]           = HallSocketReader.onRecvClientMsgUndomove;
    [SET_TIME_INFO]                 = HallSocketReader.onRecvSetTimeInfo;
    --认输
    [CLIENT_MSG_SURRENDER1]         = HallSocketReader.onRecvClientMsgSurrender1;
    [CLIENT_MSG_SURRENDER2]         = HallSocketReader.onRecvClientMsgSurrender2;
    [SERVER_MSG_SURRENDER]          = HallSocketReader.onRecvServerMsgSurrender;

--    [SERVER_MSG_GAME_START]         = HallSocketReader.onRecvServerMsgGameStart;
    [SERVER_MSG_GAME_CLOSE]         = HallSocketReader.onRecvServerMsgGameClose;
    [SERVER_MSG_WARING]             = HallSocketReader.onRecvServerMsgWarning;

    [SERVER_MSG_TIPS]               = HallSocketReader.onRecvServerMsgTips;

    [CUSTOMROOM_MSG_LOGIN_ENTER]    = HallSocketReader.onRecvCustomMsgLoginEnter;
    [CLIENT_MSG_HOMEPRESS]          = HallSocketReader.onRecvClientMsgHomepress;


    [CLIENT_MSG_HEART]              = HallSocketReader.onRecvClientMsgHeart;

    [CLIENT_WATCH_HEART]            = HallSocketReader.onRecvClientWatchHeart;



    [HALL_MSG_QUICKSTART]           = HallSocketReader.onRecvHallMsgQuickStart; 
--    [HALL_MSG_GAMEINFO]             = HallSocketReader.onRecvHallMsgGameInfo;


    [CLIENT_HALL_PRIVATEROOM_LIST]  = HallSocketReader.onRecvClientHallPrivaterRoomList;
    [CLIENT_HALL_CREATE_PRIVATEROOM]= HallSocketReader.onRecvClientHallCreatePrivateRoom;
    [CLIENT_HALL_JOIN_PRIVATEROOM]  = HallSocketReader.onRecvClientHallJoinPrivateRoom;
    [CLIENT_HALL_BROADCAST_MGS]     = HallSocketReader.onRecvClientHallBroadcastMsg;

    -- friends  cmd 
    [FRIEND_CMD_ONLINE_NUM]         = HallSocketReader.onRecvFriendCmdOnlineNum;
    [FRIEND_CMD_CHECK_USER_STATUS]  = HallSocketReader.onRecvFriendCmdCheckUserStatus;
    [FRIEND_CMD_CHECK_USER_DATA]    = HallSocketReader.onRecvFriendCmdCheckUserData;
    [FRIEND_CMD_GET_FRIENDS_NUM]    = HallSocketReader.onRecvFriendCmdGetFriendsNum;
    [FRIEND_CMD_GET_FOLLOW_NUM]     = HallSocketReader.onRecvFriendCmdGetFollowNum;
    [FRIEND_CMD_GET_FANS_NUM]       = HallSocketReader.onRecvFriendCmdGetFansNum;
    [FRIEND_CMD_GET_FRIENDS_LIST]   = HallSocketReader.onRecvFriendCmdGetFriendsList;
    [FRIEND_CMD_GET_FOLLOW_LIST]    = HallSocketReader.onRecvFriendCmdGetFollowList;
    [FRIEND_CMD_GET_FANS_LIST]      = HallSocketReader.onRecvFriendCmdGetFansList;
    [FRIEND_CMD_GET_UNREAD_MSG]     = HallSocketReader.onRecvFriendCmdGetUnreadMsg;
    [FRIEND_CMD_CHAT_MSG]           = HallSocketReader.onRecvFriendCmdChatMsg;
    [FRIEND_CMD_CHAT_MSG2]          = HallSocketReader.onRecvFriendCmdChatMsg2;
    [FRIEND_CMD_ADD_FLLOW]          = HallSocketReader.onRecvFriendCmdGetFollow;
    [FRIEND_CMD_SCORE_RANK]         = HallSocketReader.onRecvFriendCmdGetFriendsRank;
    [FRIEND_CMD_CHECK_PLAYER_RANK]  = HallSocketReader.onRecvFriendCmdGetOnlyFriendsRank;



    --好友房
    [CLIENT_HALL_CREATE_FRIENDROOM]         = HallSocketReader.onRecvServerCreateFriendRoom;        --创建挑战房
    [FRIEND_CMD_FRIEND_INVITE_REQUEST]      = HallSocketReader.onRecvServerInviteRequest;        --发起挑战请求
    [FRIEND_CMD_FRIEND_INVIT_NOTIFY]        = HallSocketReader.onRecvClientInviteNotify;         --挑战通知
    [FRIEND_CMD_FRIEND_INVIT_RESPONSE]      = HallSocketReader.onRecvClientInviteResponse;         --挑战通知回复
    [FRIEND_CMD_FRIEND_INVIT_RESPONSE2]     = HallSocketReader.onRecvClientInviteResponse2;         --挑战通知回复(2.0.5)
    [CLIIENT_CMD_RESET_TABLE]               = HallSocketReader.onRecvServerResetTable;           --重置房间状态（读写）

    --设置局时
    [SERVER_BROADCAST_SET_TIME]             = HallSocketReader.onRecvServerSetTime;    --设置时间（读写）
    [SERVER_BROADCAST_SET_TIME_NOTIFY]      = HallSocketReader.onRecvServerSetTimeNotify;    --服务器通知设置时间结果（读）
    [SERVER_BROADCAST_SET_TIME_RESPONSE]    = HallSocketReader.onRecvServerSetTimeResponse;    --是否同意设置时间结果（读写）

    --观战
    [OB_CMD_LOGIN_SUCCESS]                  = HallSocketReader.onRecvServerNewLoginSuccess;               --观战登陆成功
    [OB_CMD_CHAT_MSG]                       = HallSocketReader.onRecvServerNewWatchMsg;               --观战聊天（读写）
    [OB_CMD_GET_TABLE_INFO]                 = HallSocketReader.onRecvServerNewTableInfo;              --获取桌子信息(读写)
    [OB_CMD_GET_OB_LIST]                    = HallSocketReader.onRecvServerNewWatchList;              --获取观战列表（读写）
    [OB_CMD_PLAYER_ENTER]                   = HallSocketReader.onRecvServerNewPlayerEnter;              --广播玩家进入（读）
    [OB_CMD_PLAYER_LEAVE]                   = HallSocketReader.onRecvServerNewPlayerLeave;              --广播玩家离开(读)
    [OB_CMD_UPDATE_TABLE_STATUS]            = HallSocketReader.onRecvServerNewUpdateTable;              --同步更新桌子状态（）
    [OB_CMD_GAMESTART]                      = HallSocketReader.onRecvServerNewGameStart;              --游戏开始（读） 
    [OB_CMD_CHESS_MOVE]                     = HallSocketReader.onRecvServerNewChessMove;              --广播走棋（读）
    [OB_CMD_CHESS_UNDOMOVE]                 = HallSocketReader.onRecvServerNewChessUndo;              --悔棋（读）
    [OB_CMD_CHESS_DRAW]                     = HallSocketReader.onRecvServerNewChessDraw;              --求和（读）
    [OB_CMD_CHESS_SURRENDER]                = HallSocketReader.onRecvServerNewChessSurrender;         --认输（读）
    [OB_CMD_GAMEOVER]                       = HallSocketReader.onRecvServerNewGameOver;               --游戏结束（读）
    [OB_CMD_GET_NUM]                        = HallSocketReader.onRecvServerNewGetNumber;              --观战人数（读写）
    [FRIEND_CMD_GET_FRIEND_OB_LIST] = HallSocketReader.onRecvServerFriendsWatchList;          --棋友观战列表（读写）

    --聊天室
    [CHATROOM_CMD_ENTER_ROOM]               = HallSocketReader.onRecvServerEntryChatRoom;
    [CHATROOM_CMD_LEAVE_ROOM]               = HallSocketReader.onRecvServerLeftChatRoom;
    [CHATROOM_CMD_GET_UNREAD_MSG]           = HallSocketReader.onRecvServerLastMsg;        --获得未读消息数量
    [CHATROOM_CMD_USER_CHAT_MSG]            = HallSocketReader.onRecvServerUserMsg;        --用户发送聊天信息
    [CHATROOM_CMD_BROAdCAST_CHAT_MSG]       = HallSocketReader.onRecvServerChatMsg;        --广播聊天数据
    [CHATROOM_CMD_GET_HISTORY_MSG]          = HallSocketReader.onRecvServerUnreadMsg;      --未读聊天记录
    [CHATROOM_CMD_GET_UNREAD_MSG2]          = HallSocketReader.onRecvServerUnreadMsgNum;
    [CHATROOM_CMD_GET_MEMBER_LIST]          = HallSocketReader.onRecvServerGetMemberList;
    -- prop
    [PROP_CMD_UPDATE_USERDATA]              = HallSocketReader.onRecvServerPropCmdUpdateUserData;    -- 更新道具
    [PROP_CMD_QUERY_USERDATA]               = HallSocketReader.onRecvServerPropCmdQueryUserData;    -- 查询道具
    -- 私人房个数
    [CLIENT_ALLOC_PRIVATEROOMNUM]           = HallSocketReader.onRecvServerClientAllocPrivateRoomNum;
    -- 观战和挑战数据
    [FRIEND_CMD_GET_PLAYER_INFO]            = HallSocketReader.onRecvServerFriendCmdGeetPlayerInfo;
    [CLIENT_CMD_GETTABLESTEP]               = HallSocketReader.onRecvServerClientCmdGetTableStep;
    -- 私人房被踢
    [SERVER_CMD_ROOM_KICK_OUT_USER]         = HallSocketReader.onRecvServerRoomKickOutUser;
    [CLIENT_CMD_CALLTELPHONERESPONSE]       = HallSocketReader.onRecvServerCallTelphoneResponse;
    [CLIENT_CMD_CALLTELPHONEBACK]           = HallSocketReader.onRecvServerCallTelphoneBack;
    
    [SERVER_BROADCAST_USER_DISCONNECT]      = HallSocketReader.onRecvServerBroadcastUserDisconnect;
    [SERVER_BROADCAST_USER_RECONNECT]       = HallSocketReader.onRecvServerBroadcastUserReconnect;
};


HallSocketReader.s_severCmdFunMap           = CombineTables(HallSocketReader.s_severCmdFunMap,
{});
