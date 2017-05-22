require(NET_PATH.."hall/hallSocketCmd");
require("gameBase/socketWriter");
require("chess/util/protobufProxy")

HallSocketWriter = class(SocketWriter);

HallSocketWriter.onHallMsgHeart = function(self,packetId,info)
    
end;







HallSocketWriter.onHallMsgLogin = function(self,packetId,info)
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
    self.m_socket:writeInt(packetId, kServerVersion);
    self.m_socket:writeInt(packetId, PhpConfig.getSid());

end 

HallSocketWriter.onHallMsgGameInfo = function(self,packetId,info) 


    self.m_socket:writeInt(packetId, info.roomType);                       --房间场
    self.m_socket:writeInt(packetId, UserInfo.getInstance():getUid());     --用户ID
    self.m_socket:writeInt(packetId, 0);                                   --命令字版本号
    self.m_socket:writeInt(packetId, info.playerLevel);                    --对手难易等级
    self.m_socket:writeInt(packetId, UserInfo.getInstance():getScore()); 
    self.m_socket:writeInt(packetId, UserInfo.getInstance():getDanGradingLevel()); 

end

HallSocketWriter.onHallMsgGamePlay = function(self,packetId,info)
    if type(info) ~= "table" then return end
    self.m_socket:writeInt(packetId, #info);--房间数;

    for _,level in ipairs(info) do
        self.m_socket:writeInt(packetId, level);
    end
end

HallSocketWriter.onHallMsgAllPlayNum = function (self, packetId, info)
    
end

HallSocketWriter.onHallMsgPrivateRoomPlayNum = function (self, packetId, userId)
    self.m_socket:writeInt(packetId,userId);
end

HallSocketWriter.onSendBankruptConfig = function(self,packetId)
end 

HallSocketWriter.onSendBankruptCount = function(self,packetId,userId)
	self.m_socket:writeInt(packetId,userId);
end

HallSocketWriter.onSendBankruptMoney = function(self,packetId,userId)
	self.m_socket:writeInt(packetId,userId);
end

HallSocketWriter.onSendLoginHall = function(self,packetId,info)
	self.m_socket:writeInt(packetId,info.userId); --UserID	用户ID	Int	4
	self.m_socket:writeShort(packetId,info.isOnline);--isOnline		short	2
	self.m_socket:writeShort(packetId,info.pid);--terminalType	设备号	short	2
	self.m_socket:writeInt(packetId,info.versioncode);--version	版本号	int	
	self.m_socket:writeShort(packetId,info.sid);--sid	short	2
	self.m_socket:writeShort(packetId,info.bid);--bid	short	2

end

HallSocketWriter.onSendStatisInfo = function(self,packetId,info)
	self.m_socket:writeString(packetId,json.encode(info)); --UserID	用户ID	Int	4
end

HallSocketWriter.onSendClientWatchChat = function(self, packetId, info)
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
    self.m_socket:writeInt(packetId,RoomProxy.getInstance():getTid());   --观战棋桌ID
    self.m_socket:writeString(packetId,UserInfo.getInstance():getName());   --观战者用户名
    self.m_socket:writeString(packetId,info);   --聊天信息

end;


HallSocketWriter.onSendClientMsgLogin = function(self, packetId, infoType)
    local userInfo = UserInfo.getInstance();
    self.m_socket:writeInt(packetId, RoomProxy.getInstance():getTid());
    self.m_socket:writeInt(packetId, userInfo:getUid());
    self.m_socket:writeInt(packetId, PhpConfig.getSid());--from?
    self.m_socket:writeInt(packetId, kServerVersion);--ver

    local strInfo = {};
    strInfo.version = PhpConfig.getVersions();  --版本
    strInfo.changeside = "true";  --是否支持换位
    strInfo.money = UserInfo.getInstance():getMoney();
    strInfo.bid = PhpConfig.getBid();
    strInfo.befirst = "true";  --是否支持抢先让子
    strInfo.isundomove = true; --是否支持强制悔棋
    strInfo.client_version = kLuaVersionCode;

    strInfo.user_name = userInfo:getName();
    strInfo.uid = userInfo:getUid();
    strInfo.tid = RoomProxy.getInstance():getTid();
    strInfo.level = userInfo:getLevel();
    strInfo.icon = userInfo:getIcon();--头像链接
    strInfo.sex = userInfo:getSex();--性别
    strInfo.wintimes = userInfo:getWintimes();--赢棋盘数
    strInfo.losetimes = userInfo:getLosetimes();--输棋盘数
    strInfo.drawtimes = userInfo:getDrawtimes();--和棋盘数
    strInfo.score = userInfo:getScore(); --经验值
    strInfo.sitemid = userInfo:getSitemid();--平台ID
    strInfo.platurl = userInfo:getPlaturl();--暂时不传
    strInfo.source = userInfo:getSource();
    strInfo.rank = userInfo:getRank();
    strInfo.auth = userInfo:getAuth();
    strInfo.is_vip = userInfo:getIsVip(); --vip
    strInfo.m_mySet = userInfo:getUserSet()
    local strInfo_str = json.encode(strInfo);
	self.m_socket:writeString(packetId,strInfo_str); --当前使用的版本号
    print_string("userJson_str=============:" .. strInfo_str);		
    if infoType and infoType == 1 then
        self.m_socket:writeInt(packetId,1);
    else
        self.m_socket:writeInt(packetId,0);
    end
    self.m_socket:writeByte(packetId,userInfo:getIsVip());
    local chatRoomInfo = {};
    chatRoomInfo.chatroom_id = userInfo:getCurrentChatRoomId(); 
    chatRoomInfo.msg_id = userInfo:getCurrentChatRoomMsgId();
    local chatRoomInfo_str = json.encode(chatRoomInfo);
	self.m_socket:writeString(packetId,chatRoomInfo_str); --聊天室约战消息
end;

HallSocketWriter.onSendClientMsgForestall = function(self, packetId, info)

	--黑方应答是否抢先，响应同时推送给红方
    local subcmd = self.m_socket:readSubCmd(packetId);
	if subcmd == 2 then
		print_string("=======房间CLIENT_MSG_FORESTALL2数据发送开始====================");
	    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
	    self.m_socket:writeShort(packetId,RoomProxy.getInstance():getTid());   --棋桌
		self.m_socket:writeShort(packetId,UserInfo.getInstance():getSeatID()); --座位
		self.m_socket:writeShort(packetId,info); --1-抢先 0 不抢先
	    print_string("======房间CLIENT_MSG_FORESTALL2数据发送完成======"..info);
	end    

end;

HallSocketWriter.onSendClientRoomSyn = function(self, packetId, info)

    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
    self.m_socket:writeInt(packetId,RoomProxy.getInstance():getTid());   --棋桌


end;

HallSocketWriter.onSendClientMsgWatchlist = function(self, packetId, info)
    
    self.m_socket:writeShort(packetId,RoomProxy.getInstance():getTid());   --棋桌
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id

	self.m_socket:writeShort(packetId,0); --当前页数
	self.m_socket:writeShort(packetId,0);  -- 每页条数


end;



HallSocketWriter.onSendClientGetOpenboxTime = function(self, packetId, info)
    if info then
        self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
        self.m_socket:writeInt(packetId,info);  --领取的金钱数    
    end
end

HallSocketWriter.onSendClientMsgChat = function(self, packetId, message)

    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
    self.m_socket:writeShort(packetId,1);   --目前消息类型设置为 1表用户发送
	self.m_socket:writeString(packetId,message); --座位    
    self.m_socket:writeString(packetId,UserInfo.getInstance():getName());
    self.m_socket:writeString(packetId,PhpConfig.getUUID());
end;


HallSocketWriter.onSendClientMsgHandicap = function(self, packetId, chessID)

	self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
	self.m_socket:writeShort(packetId,RoomProxy.getInstance():getTid());   --棋桌
	self.m_socket:writeShort(packetId,UserInfo.getInstance():getSeatID()); --座位
	self.m_socket:writeShort(packetId,chessID); --让子的棋子ID （0为不让子）    

end;



HallSocketWriter.onSendClientMsgMove = function(self, packetId, info)
	
	self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
	self.m_socket:writeShort(packetId,info.moveChess);   --棋子
	self.m_socket:writeShort(packetId,info.moveFrom); --当前位置
	self.m_socket:writeShort(packetId,info.moveTo); --移动位置
end;



HallSocketWriter.onSendClientMsgDraw1 = function(self, packetId, info)
    
	self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
	self.m_socket:writeInt(packetId,RoomProxy.getInstance():getTid());   --棋桌
--	self.m_socket:writeShort(packetId,UserInfo.getInstance():getSeatID()); --座位
    
end;

HallSocketWriter.onSendClientMsgDraw2 = function(self, packetId, info)
    
	self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
	self.m_socket:writeInt(packetId,RoomProxy.getInstance():getTid());   --棋桌
	self.m_socket:writeShort(packetId,info); --1-同意 2 不同意
    
end;




HallSocketWriter.onSendClientMsgUndomove = function(self, packetId, isOK)
    local subcmd = self.m_socket:readSubCmd(packetId);
    if subcmd == 1 then
	    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
	    self.m_socket:writeInt(packetId,RoomProxy.getInstance():getTid());  --棋桌
    elseif subcmd == 2 then
        self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
	    self.m_socket:writeShort(packetId,RoomProxy.getInstance():getTid());   --棋桌
		self.m_socket:writeShort(packetId,UserInfo.getInstance():getSeatID()); --座位
		self.m_socket:writeShort(packetId,isOK); --1-同意 2 不同意

    elseif subcmd == 12 then
    	self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
	    self.m_socket:writeInt(packetId,RoomProxy.getInstance():getTid());   --棋桌
		self.m_socket:writeShort(packetId,isOK); --1-同意 2 不同意


    end;
end;



HallSocketWriter.onSendSetTimeInfo = function(self, packetId, info)
    local subcmd = self.m_socket:readSubCmd(packetId);
    if subcmd == 2 then
        self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
	    self.m_socket:writeShort(packetId,RoomProxy.getInstance():getTid());   --棋桌
		self.m_socket:writeShort(packetId,UserInfo.getInstance():getSeatID()); --座位

		self.m_socket:writeShort(packetId,info.timeout1);   --局时
		self.m_socket:writeShort(packetId,info.timeout2);   --步时
		self.m_socket:writeShort(packetId,info.timeout3);   --读秒

    elseif subcmd == 4 then

        self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
	    self.m_socket:writeShort(packetId,RoomProxy.getInstance():getTid());   --棋桌
		self.m_socket:writeShort(packetId,UserInfo.getInstance():getSeatID()); --座位

		self.m_socket:writeShort(packetId,info.isOK); --0 不同意 1同意

		self.m_socket:writeShort(packetId,info.timeout1);   --局时
		self.m_socket:writeShort(packetId,info.timeout2);   --步时
		self.m_socket:writeShort(packetId,info.timeout3);   --读秒
    end;


end;




HallSocketWriter.onSendClientMsgSurrender1 = function(self, packetId, isOK)

	self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
	self.m_socket:writeInt(packetId,RoomProxy.getInstance():getTid());   --棋桌
--	self.m_socket:writeShort(packetId,UserInfo.getInstance():getSeatID()); --座位    
end;



HallSocketWriter.onSendClientMsgSurrender2 = function(self, packetId, isOK)

	self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
	self.m_socket:writeInt(packetId,RoomProxy.getInstance():getTid());   --棋桌
	self.m_socket:writeShort(packetId,isOK); --1-同意 2 不同意  
end


HallSocketWriter.onClientMsgReady = function(self, packetId, info)
    Log.i("HallSocketWriter.onClientMsgReady");
    --暂时不需要给server发内容
end

HallSocketWriter.onClientMsgLogout = function(self, packetId, info)
    Log.i("HallSocketWriter.onClientMsgLogout");
    --暂时不需要给server发内容
end
	
HallSocketWriter.onClientMsgOffline = function(self, packetId, info)
    Log.i("HallSocketWriter.onClientMsgOffline");
    --暂时不需要给server发内容
end

HallSocketWriter.onServerMsgForeStall = function(self, packetId, info)
    Log.i("HallSocketWriter.onServerMsgForeStall");
    self.m_socket:writeInt(packetId, info);
end

HallSocketWriter.onServerMsgForeStallNew = function(self, packetId, info)
    Log.i("HallSocketWriter.onServerMsgForeStallNew");
    self.m_socket:writeInt(packetId, info);
end

HallSocketWriter.onServerMsgForeStall320 = function(self, packetId, info)
    Log.i("HallSocketWriter.onServerMsgForeStallNew");
    self.m_socket:writeInt(packetId, info);
end

HallSocketWriter.onServerMsgHandicap = function(self, packetId, info)
    Log.i("HallSocketWriter.onServerMsgHandicap");
    self.m_socket:writeShort(packetId, info);
end;   

HallSocketWriter.onServerMsgHandicapConfirm = function(self, packetId, info)
    Log.i("HallSocketWriter.onServerMsgHandicap");
    self.m_socket:writeInt(packetId, info);
end;    

HallSocketWriter.onClientWatchList = function(self, packetId, info)
    Log.i("HallSocketWriter.onClientWatchList");
    self.m_socket:writeInt(packetId, UserInfo.getInstance():getUid());
    
end;


HallSocketWriter.onClientWatchJoin = function(self, packetId, info)
    Log.i("HallSocketWriter.onClientWatchJoin");
    self.m_socket:writeInt(packetId, UserInfo.getInstance():getUid());
    self.m_socket:writeInt(packetId, RoomProxy.getInstance():getTid());
    
end


HallSocketWriter.onClientHallCancelMatch = function(self, packetId)
    Log.i("HallSocketWriter.onClientHallCancelMatch");
    local config = RoomProxy.getInstance():getCurRoomConfig();
    if config then
        self.m_socket:writeInt(packetId, config.level); 
        self.m_socket:writeInt(packetId, UserInfo.getInstance():getUid());
    end
end

HallSocketWriter.onSendClientHallPrivateRoomList = function(self,packetId,info)
    self.m_socket:writeInt(packetId,info.level);
    self.m_socket:writeInt(packetId,info.uid);
end

HallSocketWriter.onSendClientHallCreatePrivateRoom = function(self,packetId,info)
    self.m_socket:writeInt(packetId,info.level);
    self.m_socket:writeInt(packetId,info.uid);
    self.m_socket:writeString(packetId,info.name);
    self.m_socket:writeString(packetId,info.password);
    self.m_socket:writeInt(packetId,info.basechip);
    self.m_socket:writeInt(packetId,info.round_time);
    self.m_socket:writeInt(packetId,info.step_time);
    self.m_socket:writeInt(packetId,info.sec_time);
    self.m_socket:writeInt(packetId,1);--是否允许观战 1 是 0 不是
end

HallSocketWriter.onSendClientHallJoinPrivateRoom = function(self,packetId,info)
    self.m_socket:writeInt(packetId,info.level);
    self.m_socket:writeInt(packetId,info.uid);
    self.m_socket:writeInt(packetId,info.tid);
    self.m_socket:writeString(packetId,info.password);
end

HallSocketWriter.onSendFriendCmdOnlineNum = function(self,packetId,info)
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
    self.m_socket:writeInt(packetId,0);
end

HallSocketWriter.onSendFriendCmdCheckUserStatus = function(self,packetId,info)
    if not info or not info[1] then return end
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
    self.m_socket:writeInt(packetId,#info);
    for i=1,#info do
        self.m_socket:writeInt(packetId,info[i]);
    end
end

HallSocketWriter.onSendFriendCmdCheckUserData = function(self,packetId,info)
    if not info or not info[1] then return end
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
    self.m_socket:writeInt(packetId,#info);
    for i=1,#info do
        self.m_socket:writeInt(packetId,info[i]);
    end
end

HallSocketWriter.onSendFriendCmdGetFriendsNum = function(self,packetId,info)
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
end

HallSocketWriter.onSendFriendCmdGetFollowNum = function(self,packetId,info)
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
end

HallSocketWriter.onSendFriendCmdGetFansNum = function(self,packetId,info)
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
end

HallSocketWriter.onSendFriendCmdFollowMsg = function(self,packetId,info)
    if not info or not info.target_uid then return end
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
    self.m_socket:writeInt(packetId,info.target_uid);
    self.m_socket:writeInt(packetId,info.op);
end

HallSocketWriter.onSendFriendCmdFriendsRankMsg = function(self,packetId,info)
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
end

HallSocketWriter.onSendFriendCmdOnlyFriendsRankMsg = function(self,packetId,info)
    self.m_socket:writeInt(packetId,info.uid);
    self.m_socket:writeInt(packetId,info.target_uid);
end

--HallSocketWriter.onSendFriendCmdOnlyFriendsNumMsg = function(self,packetId,info)--好友数目
--    self.m_socket:writeInt(packetId,info.uid);
--end

--HallSocketWriter.onSendFriendCmdOnlyFollowNumMsg = function(self,packetId,info)--关注数目
--    self.m_socket:writeInt(packetId,info.uid);
--end

--HallSocketWriter.onSendFriendCmdOnlyFansNumMsg = function(self,packetId,info)--粉丝数目
--    self.m_socket:writeInt(packetId,info.uid);
--end


HallSocketWriter.onSendFriendCmdGetFriendsList = function(self,packetId,info)
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
end

HallSocketWriter.onSendFriendCmdGetFollowList = function(self,packetId,info)
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
end

HallSocketWriter.onSendFriendCmdGetFansList = function(self,packetId,info)
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
end

HallSocketWriter.onSendFriendCmdGetFriendFollowList = function(self,packetId,info)
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
end

HallSocketWriter.onSendFriendCmdGetUnreadMsg = function(self,packetId,info)
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
    self.m_socket:writeInt(packetId,0);
end


HallSocketWriter.onSendFriendCmdRecvMsgCheck = function(self,packetId,info)
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
    self.m_socket:writeInt(packetId,info.msg_id);
end

HallSocketWriter.onSendFriendCmdChatMsg = function(self,packetId,info)
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
    self.m_socket:writeInt(packetId,info.target_uid);
    self.m_socket:writeString(packetId,info.msg);
end

HallSocketWriter.onSendServerCreateFriendRoom = function(self,packetId,info)
    self.m_socket:writeInt(packetId,info.level);
    self.m_socket:writeInt(packetId,info.uid);
end

HallSocketWriter.onSendServerInviteRequest = function(self,packetId,info)
    self.m_socket:writeInt(packetId,info.uid);
    self.m_socket:writeInt(packetId,info.target_uid);
    self.m_socket:writeInt(packetId,info.tid);
    self.m_socket:writeInt(packetId,info.gameTime);
    self.m_socket:writeInt(packetId,info.stepTime);
    self.m_socket:writeInt(packetId,info.secondTime);
end

HallSocketWriter.onSendClientInviteResponse = function(self,packetId,info)
    self.m_socket:writeInt(packetId,info.uid);
    self.m_socket:writeInt(packetId,info.ret);
end

HallSocketWriter.onSendClientInviteResponse2 = function(self,packetId,info)
    self.m_socket:writeInt(packetId,info.uid);
    self.m_socket:writeInt(packetId,info.target_uid);
    self.m_socket:writeInt(packetId,info.ret);
end

HallSocketWriter.onSendClientResetTable = function(self,packetId,info)
    self.m_socket:writeInt(packetId,info.uid);
    self.m_socket:writeInt(packetId,info.status);
end

HallSocketWriter.onSendServerCheckUserState = function(self, packetId, info)
    self.m_socket:writeInt(packetId,info[1]);
    self.m_socket:writeInt(packetId,info[2]);    
end;

HallSocketWriter.onSendCustomStrangerInvite = function(self, packetId, info)
    self.m_socket:writeInt(packetId,info.uid or 0);
    self.m_socket:writeInt(packetId,info.target_uid or 0);
    self.m_socket:writeInt(packetId,info.tid or 0);

    self.m_socket:writeString(packetId,info.name or "");
    self.m_socket:writeString(packetId,info.password);

    self.m_socket:writeInt(packetId,info.basechip or 0);
    self.m_socket:writeInt(packetId,info.round_time or 0);
    self.m_socket:writeInt(packetId,info.step_time or 0);
    self.m_socket:writeInt(packetId,info.sec_time or 0);
end;

HallSocketWriter.onSendCustomStrangerResp = function(self, packetId,info)
    self.m_socket:writeInt(packetId,info.uid);
    self.m_socket:writeInt(packetId,info.target_uid);
    self.m_socket:writeInt(packetId,info.ret);
end;

HallSocketWriter.onSendServerSetTime = function(self,packetId,info)
    self.m_socket:writeInt(packetId,info.gameTime);
    self.m_socket:writeInt(packetId,info.stepTime);
    self.m_socket:writeInt(packetId,info.secondTime);
end

HallSocketWriter.onSendServerSetTimeResponse = function(self,packetId,info)
    self.m_socket:writeInt(packetId,info.uid);
    self.m_socket:writeInt(packetId,info.ret);
end

HallSocketWriter.onSendServerNewWatchMsg = function(self,packetId,info)
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
    self.m_socket:writeString(packetId,UserInfo.getInstance():getName());
    self.m_socket:writeString(packetId,info);
    self.m_socket:writeString(packetId,PhpConfig.getUUID());

end

HallSocketWriter.onSendServerNewTableInfo = function(self,packetId,info)
    self.m_socket:writeInt(packetId,info.tid);
end

HallSocketWriter.onSendServerNewWatchList = function(self,packetId,info)
    self.m_socket:writeInt(packetId,info.tid);
end

HallSocketWriter.onSendServerNewGetNumber = function(self,packetId,info)
    self.m_socket:writeInt(packetId,info.tid);
end

HallSocketWriter.onSendServerNewGetWatchHistoryMsgs = function(self,packetId)
end

-- 2.9.0聊天室改版
-- 第一个参数老版本room_id传php给的整数id,如果不是整数传-1
-- 最后一个补上字符串room_id
HallSocketWriter.onSendServerEntryChatRoom = function(self,packetId,info)
    self.m_socket:writeInt(packetId,tonumber(info.room_id) or -1);
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
    self.m_socket:writeString(packetId,info.room_id.."");
end

HallSocketWriter.onSendServerLeftChatRoom = function(self,packetId,info)
    self.m_socket:writeInt(packetId,tonumber(info.room_id) or -1);
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
    self.m_socket:writeString(packetId,info.room_id.."");
end

HallSocketWriter.onSendServerLastMsg = function(self,packetId,info)
    self.m_socket:writeInt(packetId,tonumber(info.room_id) or -1);
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
    self.m_socket:writeInt(packetId,info.last_msg_id);
    self.m_socket:writeInt(packetId,info.last_msg_time);
    self.m_socket:writeString(packetId,info.room_id.."");
end

HallSocketWriter.onSendServerUserMsg = function(self,packetId,info)
    self.m_socket:writeInt(packetId,tonumber(info.room_id) or -1);
    self.m_socket:writeInt(packetId,info.uid);
    self.m_socket:writeString(packetId,info.name);
    self.m_socket:writeString(packetId,info.msg);
    self.m_socket:writeString(packetId,PhpConfig.getUUID());
    self.m_socket:writeString(packetId,info.room_id.."");
    self.m_socket:writeInt(packetId,info.msg_type or 1);
    self.m_socket:writeString(packetId,info.other or "");
end

HallSocketWriter.onSendClientChatMsg = function(self,packetId,info)
    self.m_socket:writeInt(packetId,tonumber(info.room_id) or -1);
    self.m_socket:writeInt(packetId,info.uid);
    self.m_socket:writeInt(packetId,info.msg_id);
    self.m_socket:writeInt(packetId,info.msg_time);
    self.m_socket:writeString(packetId,info.room_id.."");
end

HallSocketWriter.onSendServerUnreadMsg = function(self,packetId,info)
    self.m_socket:writeInt(packetId,tonumber(info.room_id) or -1);
    self.m_socket:writeInt(packetId,info.uid);
    self.m_socket:writeInt(packetId,info.last_msg_time);  -- 开始时间
    self.m_socket:writeInt(packetId,info.entry_room_time);-- 结束时间
    self.m_socket:writeInt(packetId,info.version);
    self.m_socket:writeString(packetId,info.room_id.."");
end

HallSocketWriter.onSendServerUnreadMsgNew = function(self,packetId,info)
    self.m_socket:writeString(packetId,info.room_id);
    self.m_socket:writeInt(packetId,info.uid);
    self.m_socket:writeInt(packetId,info.last_msg_time);  -- 开始时间
    self.m_socket:writeInt(packetId,info.items);          -- 消息个数
    self.m_socket:writeInt(packetId,info.version);
end

HallSocketWriter.onSendServerChessMatchMsg = function(self,packetId,info)
    self.m_socket:writeString(packetId,info.room_id);
    self.m_socket:writeInt(packetId,info.uid);
    self.m_socket:writeInt(packetId,info.last_msg_time);  -- 开始时间
    self.m_socket:writeInt(packetId,info.items);          -- 消息个数
    self.m_socket:writeInt(packetId,info.version);
end

HallSocketWriter.onSendServerChessMatchMsgNum = function(self,packetId,info)
    self.m_socket:writeString(packetId,info.room_id);
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
    self.m_socket:writeInt(packetId,kLuaVersionCode);
end

HallSocketWriter.onSendServerUnreadMsgWithTime = function(self,packetId,info)
    self.m_socket:writeInt(packetId,tonumber(info.room_id) or -1);
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
    self.m_socket:writeInt(packetId,info.begin_msg_time); -- 开始时间
    self.m_socket:writeInt(packetId,info.end_msg_time); -- 结束时间
    self.m_socket:writeString(packetId,info.room_id.."");
end


HallSocketWriter.onSendServerGetMemberList = function(self, packetId, info)
    self.m_socket:writeInt(packetId,info.uid);
    self.m_socket:writeInt(packetId,tonumber(info.room_id) or -1);
    self.m_socket:writeString(packetId,info.room_id.."");
end;

HallSocketWriter.onSendServerIsActAvaliable = function(self ,packetId, info)
    self.m_socket:writeInt(packetId,info.send_uid);
    self.m_socket:writeInt(packetId,info.check_uid);
end;

HallSocketWriter.onSendServerUpdateCRItem = function(self,packetId,info)
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
    self.m_socket:writeString(packetId,info.room_id.."");
    self.m_socket:writeInt(packetId,info.msg_id);    
end;

HallSocketWriter.onSendPropCmdUpdateUserData = function(self,packetId,info)
    self.m_socket:writeShort(packetId,2);-- type,=1,php, =2,client
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
    self.m_socket:writeShort(packetId,#info);-- 使用道具类型数量
    for i,v in ipairs(info) do
        self.m_socket:writeShort(packetId,v.op); -- =1相加，=2相减，=3覆盖
        self.m_socket:writeShort(packetId,v.op_id); -- 11 => '单机中使用道具', 12 => '残局中使用道具',
        self.m_socket:writeInt(packetId,v.num);--修改数量
        self.m_socket:writeString(packetId,v.prop_id);--道具id
    end
end
HallSocketWriter.onSendPropCmdQueryUserData = function(self,packetId,info)
    self.m_socket:writeShort(packetId,2);-- type,=1,php, =2,client
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
end

HallSocketWriter.onSendServerFriendsWatchList = function(self,packetId,uid)
    self.m_socket:writeInt(packetId,uid);
end

HallSocketWriter.onClientHallNetDataReport = function(self,packetId,info)
    self.m_socket:writeShort(packetId,PhpConfig.getNetTypeLevel());--
    self.m_socket:writeShort(packetId,TerminalInfo.getInstance():getOperatorType() );--
    self.m_socket:writeString(packetId,TerminalInfo.getInstance():getOperator());--
    self.m_socket:writeString(packetId,PhpConfig.getNetType());--
end

HallSocketWriter.onClientAllocPrivateRoomNum = function(self,packetId,info)
    self.m_socket:writeInt(packetId,info.level);--
    self.m_socket:writeInt(packetId,info.uid);--
end

HallSocketWriter.onFriendCmdGeetPlayerInfo = function(self,packetId,info)
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());--
end

HallSocketWriter.onClientCmdGetTableStep = function(self,packetId,info)
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());--
    self.m_socket:writeInt(packetId,RoomProxy.getInstance():getTid() or 0);--
end

HallSocketWriter.onClientGetCurTidStartTime = function(self,packetId,info)
end

HallSocketWriter.onSendFriendCmdChatMsg2 = function(self,packetId,info)
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
    self.m_socket:writeInt(packetId,info.target_uid);
    self.m_socket:writeString(packetId,info.msg);
    self.m_socket:writeInt(packetId,info.isNew);
end

HallSocketWriter.onServerCmdKickPlayer = function(self,packetId,info)
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
end

HallSocketWriter.onClientAllocGetPrivateroomInfo = function(self,packetId,info)
    self.m_socket:writeInt(packetId,info.level or 0);
    self.m_socket:writeInt(packetId,info.tid or 0);
end

HallSocketWriter.onClientCmdForbidUserMsg = function(self,packetId, info)
    self.m_socket:writeInt(packetId,info.opp_id);
    self.m_socket:writeByte(packetId,info.forbid_status);-- 0 屏蔽，1取消屏蔽
end;

HallSocketWriter.onClientCmdGiveGift = function(self,packetId, info)
    self.m_socket:writeInt(packetId,info.target_id);
    self.m_socket:writeInt(packetId,info.gift_type);
    self.m_socket:writeInt(packetId,info.gift_count);
end;


HallSocketWriter.onFastmatchLoginroomRequest = function(self,packetId, infoType)
    local userInfo = UserInfo.getInstance();
    self.m_socket:writeString(packetId, RoomProxy.getInstance():getMatchId());
    self.m_socket:writeInt(packetId, RoomProxy.getInstance():getTid());
    self.m_socket:writeInt(packetId, userInfo:getUid());
    self.m_socket:writeInt(packetId, PhpConfig.getSid());--from?
    self.m_socket:writeInt(packetId, kServerVersion);--ver

    local strInfo = {};
    strInfo.version = PhpConfig.getVersions();  --版本
    strInfo.changeside = "true";  --是否支持换位
    strInfo.money = UserInfo.getInstance():getMoney();
    strInfo.bid = PhpConfig.getBid();
    strInfo.befirst = "true";  --是否支持抢先让子
    strInfo.isundomove = true; --是否支持强制悔棋
    strInfo.client_version = kLuaVersionCode;

    strInfo.user_name = userInfo:getName();
    strInfo.uid = userInfo:getUid();
    strInfo.tid = RoomProxy.getInstance():getTid();
    strInfo.level = userInfo:getLevel();
    strInfo.icon = userInfo:getIcon();--头像链接
    strInfo.sex = userInfo:getSex();--性别
    strInfo.wintimes = userInfo:getWintimes();--赢棋盘数
    strInfo.losetimes = userInfo:getLosetimes();--输棋盘数
    strInfo.drawtimes = userInfo:getDrawtimes();--和棋盘数
    strInfo.score = userInfo:getScore(); --经验值
    strInfo.sitemid = userInfo:getSitemid();--平台ID
    strInfo.platurl = userInfo:getPlaturl();--暂时不传
    strInfo.source = userInfo:getSource();
    strInfo.rank = userInfo:getRank();
    strInfo.auth = userInfo:getAuth();
    strInfo.is_vip = userInfo:getIsVip(); --vip
    strInfo.m_mySet = userInfo:getUserSet()
    local strInfo_str = json.encode(strInfo);
	self.m_socket:writeString(packetId,strInfo_str); --当前使用的版本号
    print_string("userJson_str=============:" .. strInfo_str);		
    if infoType and infoType == 1 then
        self.m_socket:writeInt(packetId,1);
    else
        self.m_socket:writeInt(packetId,0);
    end
end

HallSocketWriter.onFastmatchSignupRequest = function(self,packetId, info)
    self.m_socket:writeInt(packetId,info.level or 0)
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid())
    self.m_socket:writeInt(packetId, 0);                    --命令字版本号
    self.m_socket:writeInt(packetId, 0);                    --对手难易等级
    self.m_socket:writeInt(packetId, UserInfo.getInstance():getScore()); 
    self.m_socket:writeInt(packetId, UserInfo.getInstance():getDanGradingLevel()); 
end

HallSocketWriter.onFastmatchCanclesignupRequest = function(self,packetId, info)
    self.m_socket:writeInt(packetId,info.level or 0)
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid())
end

HallSocketWriter.onFastmatchGetSignupInfo = function(self,packetId, info)
    if type(info) ~= "table" then return end
    self.m_socket:writeByte(packetId,#info)
    for _,level in ipairs(info) do
        self.m_socket:writeInt(packetId,level)
    end
end

HallSocketWriter.onFastmatchGiveUp = function(self,packetId, info)
    self.m_socket:writeString(packetId,RoomProxy.getInstance():getMatchId())
    self.m_socket:writeInt(packetId,RoomProxy.getInstance():getTid())
end

HallSocketWriter.onFastSignUpList = function(self,packetId, info)
    self.m_socket:writeInt(packetId,info.level or 0)
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid())
end

HallSocketWriter.onMatchGettableinfo = function(self,packetId, info)
end

HallSocketWriter.onMatchGetobtableinfo = function(self,packetId, info)
end

HallSocketWriter.onMatchPlayerChangeState = function(self,packetId, info)
    self.m_socket:writeInt(packetId,info.state)
end

HallSocketWriter.onMatchLeaveOb = function(self,packetId, info)
end

HallSocketWriter.onMatchGetRoundIndex = function(self,packetId, info)
end

HallSocketWriter.onMatchEnterObserveTable = function(self,packetId, info)
    self.m_socket:writeString(packetId,RoomProxy.getInstance():getMatchId())
    self.m_socket:writeInt(packetId,RoomProxy.getInstance():getTid())
end

HallSocketWriter.onLoginMatch = function(self,packetId, info)
    self.m_socket:writeInt(packetId,RoomProxy.getInstance():getCurRoomLevel())
    self.m_socket:writeString(packetId,RoomProxy.getInstance():getMatchId())
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid())
end

HallSocketWriter.onQueryGamePlayerStatus = function(self,packetId, info)
    self.m_socket:writeString(packetId,RoomProxy.getInstance():getMatchId())
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid())
end

HallSocketWriter.onUserRequestMatching = function(self,packetId, info)
    self.m_socket:writeInt(packetId,RoomProxy.getInstance():getCurRoomLevel())
    self.m_socket:writeString(packetId,RoomProxy.getInstance():getMatchId())
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid())
end

HallSocketWriter.onGetMatchPlayerInfo = function(self,packetId, info)
    self.m_socket:writeString(packetId,RoomProxy.getInstance():getMatchId())
    self.m_socket:writeInt(packetId,RoomProxy.getInstance():getTid())
    self.m_socket:writeInt(packetId,RoomProxy.getInstance():getMatchRecordId())
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid())
end

HallSocketWriter.onGiveUpTheResurrection = function(self,packetId, info)
    self.m_socket:writeInt(packetId,RoomProxy.getInstance():getCurRoomLevel())
    self.m_socket:writeString(packetId,RoomProxy.getInstance():getMatchId())
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid())
end

HallSocketWriter.onGiveUpTheMatch = function(self,packetId, info)
    self.m_socket:writeInt(packetId,RoomProxy.getInstance():getCurRoomLevel())
    self.m_socket:writeString(packetId,RoomProxy.getInstance():getMatchId())
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid())
end

HallSocketWriter.onCheckOutStatus = function(self,packetId, info)
    self.m_socket:writeInt(packetId,RoomProxy.getInstance():getCurRoomLevel())
    self.m_socket:writeString(packetId,RoomProxy.getInstance():getMatchId())
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid())
end

HallSocketWriter.onGetWatchList = function( self, packetId, info )
    self.m_socket:writeInt(packetId, info.level)
    self.m_socket:writeString(packetId, info.match_id)
    self.m_socket:writeInt(packetId, info.uid)
end

HallSocketWriter.onCheckMatchUserGiftInfo = function( self, packetId, info )
    self.m_socket:writeInt(packetId, RoomProxy.getInstance():getTid())
end

HallSocketWriter.onCheckMatchUserMaxScore = function( self, packetId, info )
    if type(info) ~= "table" or #info > 200 then return end
    self.m_socket:writeInt(packetId,RoomProxy.getInstance():getCurRoomLevel())
    self.m_socket:writeString(packetId,RoomProxy.getInstance():getMatchId())
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid())
    self.m_socket:writeInt(packetId,#info)
    for _,uid in ipairs(info) do
        self.m_socket:writeInt(packetId,uid)
    end
end

HallSocketWriter.onMatchGetWatchTid = function( self, packetId, info )
    self.m_socket:writeInt(packetId,RoomProxy.getInstance():getCurRoomLevel())
    self.m_socket:writeString(packetId,RoomProxy.getInstance():getMatchId())
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid())
end

HallSocketWriter.onMatchCheckUserRank = function( self, packetId, info )
    self.m_socket:writeInt(packetId,RoomProxy.getInstance():getCurRoomLevel())
    self.m_socket:writeString(packetId,RoomProxy.getInstance():getMatchId())
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid())
    self.m_socket:writeInt(packetId,info.check_uid)
end

HallSocketWriter.onMatchGetMatchScore = function( self, packetId, info )
    self.m_socket:writeInt(packetId,RoomProxy.getInstance():getCurRoomLevel())
    self.m_socket:writeString(packetId,RoomProxy.getInstance():getMatchId())
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid())
    self.m_socket:writeInt(packetId,info.check_uid)
end


HallSocketWriter.onSendServerCharmWatchList = function(self,packetId,uid)
    self.m_socket:writeInt(packetId,uid);
end

HallSocketWriter.onCheckRoomTypeByTid = function(self,packetId,info)

    if not info then return end
--    local send = {}
--    send.roomlist = {}
--    local num = info.num
--    local tab = info.tab
--    for _,v in ipairs(info.tab) do
--        local tmp = {}
--        tmp.tid = v
--        table.insert(send.roomlist,tmp)
--    end
--    local write = ProtobufProxy.register("chess/net/pb/match_pb_base64")
--    local pbStr = ProtobufProxy.encode(write.PB_ROOMLIST,send)
--    self.m_socket:writeString(packetId,pbStr)

    if not info then return end
    local num = info.num
    local tab = info.tab
    self.m_socket:writeInt(packetId,num)
    for _,v in ipairs(tab) do
        self.m_socket:writeInt(packetId,tonumber(v))
    end
end

HallSocketWriter.onCheckUserWinCombo = function(self,packetId,info)
    if not info then return end
    local uid = UserInfo.getInstance():getUid()
    self.m_socket:writeInt(packetId,uid)
    self.m_socket:writeInt(packetId,info.target_id)
end

HallSocketWriter.OnThanSizeStart = function(self,packetId,info)
    if not info then return end;
    self.m_socket:writeInt(packetId,info.uid);
    self.m_socket:writeInt(packetId,info.level);
    self.m_socket:writeInt(packetId,info.side);
    self.m_socket:writeInt(packetId,info.from);
    
--    local send = {};
--    send.uid   = info.uid;
--    send.level = info.level;
--    send.side  = info.side;
--    send.from  = info.from;
--    local write = ProtobufProxy.register("chess/net/pb/casinowar_pb_base64");
--    local pbStr = ProtobufProxy.encode(write.PB_StartCasinoWar,send);
--    self.m_socket:writeString(packetId,pbStr);

end
----------------------------------------config--------------------------------------------



HallSocketWriter.s_clientCmdFunMap = {

    [HALL_MSG_HEART]                = HallSocketWriter.onHallMsgHeart;
	[HALL_MSG_LOGIN]		        = HallSocketWriter.onHallMsgLogin;
    [HALL_MSG_GAMEINFO]             = HallSocketWriter.onHallMsgGameInfo;
    [HALL_MSG_GAMEPLAY]             = HallSocketWriter.onHallMsgGamePlay;
    [HALL_MSG_ALL_PLAY_NUM] = HallSocketWriter.onHallMsgAllPlayNum;
    [HALL_MSG_PRIVATE_ROOM_PLAY_NUM] = HallSocketWriter.onHallMsgPrivateRoomPlayNum;

    [CLIENT_MSG_LOGOUT]             = HallSocketWriter.onClientMsgLogout;
    [CLIENT_MSG_READY]              = HallSocketWriter.onClientMsgReady;
    [CLIENT_MSG_OFFLINE]            = HallSocketWriter.onClientMsgOffline;
    [SERVER_MSG_FORESTALL]          = HallSocketWriter.onServerMsgForeStall;
    [SERVER_MSG_HANDICAP]           = HallSocketWriter.onServerMsgHandicap;
    [SERVER_MSG_HANDICAP_CONFIRM]   = HallSocketWriter.onServerMsgHandicapConfirm; 
    [SERVER_MSG_FORESTALL_NEW]      = HallSocketWriter.onServerMsgForeStallNew;
    [SERVER_MSG_FORESTALL_320]      = HallSocketWriter.onServerMsgForeStall320;

    --观战
    [CLIENT_WATCH_LIST]             = HallSocketWriter.onClientWatchList;
    [CLIENT_WATCH_JOIN]             = HallSocketWriter.onClientWatchJoin;


    [CLIENT_HALL_CANCEL_MATCH]      = HallSocketWriter.onClientHallCancelMatch;





    [CLIENT_WATCH_CHAT]             = HallSocketWriter.onSendClientWatchChat;
    [CLIENT_MSG_LOGIN]              = HallSocketWriter.onSendClientMsgLogin;
    [CLIENT_MSG_FORESTALL]          = HallSocketWriter.onSendClientMsgForestall;
    [CLIENT_MSG_SYNCHRODATA]        = HallSocketWriter.onSendClientRoomSyn;
    [CLIENT_MSG_WATCHLIST]          = HallSocketWriter.onSendClientMsgWatchlist;
    [CLIENT_GET_OPENBOX_TIME]       = HallSocketWriter.onSendClientGetOpenboxTime;
    [CLIENT_MSG_CHAT]               = HallSocketWriter.onSendClientMsgChat;
    [CLIENT_MSG_HANDICAP]           = HallSocketWriter.onSendClientMsgHandicap;
    [CLIENT_MSG_MOVE]               = HallSocketWriter.onSendClientMsgMove;
    [CLIENT_MSG_DRAW1]              = HallSocketWriter.onSendClientMsgDraw1;
    [CLIENT_MSG_DRAW2]              = HallSocketWriter.onSendClientMsgDraw2;
    [CLIENT_MSG_UNDOMOVE]           = HallSocketWriter.onSendClientMsgUndomove;
    [SET_TIME_INFO]                 = HallSocketWriter.onSendSetTimeInfo;
    [CLIENT_MSG_SURRENDER1]         = HallSocketWriter.onSendClientMsgSurrender1;
    [CLIENT_MSG_SURRENDER2]         = HallSocketWriter.onSendClientMsgSurrender2;

    [CLIENT_HALL_PRIVATEROOM_LIST]  = HallSocketWriter.onSendClientHallPrivateRoomList;
    [CLIENT_HALL_CREATE_PRIVATEROOM]= HallSocketWriter.onSendClientHallCreatePrivateRoom;
    [CLIENT_HALL_JOIN_PRIVATEROOM]  = HallSocketWriter.onSendClientHallJoinPrivateRoom;
    
    -- friends  cmd 
    [FRIEND_CMD_ONLINE_NUM]         = HallSocketWriter.onSendFriendCmdOnlineNum;
    [FRIEND_CMD_CHECK_USER_STATUS]  = HallSocketWriter.onSendFriendCmdCheckUserStatus;
    [FRIEND_CMD_CHECK_USER_DATA]    = HallSocketWriter.onSendFriendCmdCheckUserData;
    [FRIEND_CMD_GET_FRIENDS_NUM]    = HallSocketWriter.onSendFriendCmdGetFriendsNum;
    [FRIEND_CMD_GET_FOLLOW_NUM]     = HallSocketWriter.onSendFriendCmdGetFollowNum;
    [FRIEND_CMD_GET_FANS_NUM]       = HallSocketWriter.onSendFriendCmdGetFansNum;
    [FRIEND_CMD_GET_FRIENDS_LIST]   = HallSocketWriter.onSendFriendCmdGetFriendsList;
    [FRIEND_CMD_GET_FOLLOW_LIST]    = HallSocketWriter.onSendFriendCmdGetFollowList;
    [FRIEND_CMD_GET_FANS_LIST]      = HallSocketWriter.onSendFriendCmdGetFansList;
    [FRIEND_CMD_GET_FRIEND_FOLLOW_LIST] = HallSocketWriter.onSendFriendCmdGetFriendFollowList;
    [FRIEND_CMD_GET_UNREAD_MSG]     = HallSocketWriter.onSendFriendCmdGetUnreadMsg;
    [FRIEND_CMD_RECV_MSG_CHECK]     = HallSocketWriter.onSendFriendCmdRecvMsgCheck;
    [FRIEND_CMD_CHAT_MSG]           = HallSocketWriter.onSendFriendCmdChatMsg;
    [FRIEND_CMD_CHAT_MSG2]           = HallSocketWriter.onSendFriendCmdChatMsg2;
    [FRIEND_CMD_ADD_FLLOW]          = HallSocketWriter.onSendFriendCmdFollowMsg;
    [FRIEND_CMD_SCORE_RANK]          = HallSocketWriter.onSendFriendCmdFriendsRankMsg;
    [FRIEND_CMD_CHECK_PLAYER_RANK]   = HallSocketWriter.onSendFriendCmdOnlyFriendsRankMsg;


    --好友房
    [CLIENT_HALL_CREATE_FRIENDROOM] = HallSocketWriter.onSendServerCreateFriendRoom;             --创建挑战房
    [FRIEND_CMD_FRIEND_INVITE_REQUEST]      = HallSocketWriter.onSendServerInviteRequest;        --发起挑战请求
    [FRIEND_CMD_FRIEND_INVIT_RESPONSE]      = HallSocketWriter.onSendClientInviteResponse;       --挑战通知回复
    [FRIEND_CMD_FRIEND_INVIT_RESPONSE2]     = HallSocketWriter.onSendClientInviteResponse2;       --挑战通知回复(2.0.5)
    [CLIIENT_CMD_RESET_TABLE]               = HallSocketWriter.onSendClientResetTable;           --重置房间状态（读写）

    --聊天室私人房邀请
    [FRIEND_CMD_GET_USER_STATUS]            = HallSocketWriter.onSendServerCheckUserState;       --聊天室被挑战者是否在线
    [STRANGER_CMD_INVITE_REQUEST]           = HallSocketWriter.onSendCustomStrangerInvite;       --发起挑战请求
    [STRANGER_CMD_INVIT_RESPONSE]           = HallSocketWriter.onSendCustomStrangerResp;         --被挑战者发送接受 or 拒绝请求

    --设置局时
    [SERVER_BROADCAST_SET_TIME]             = HallSocketWriter.onSendServerSetTime;              --设置时间（读写）
    [SERVER_BROADCAST_SET_TIME_RESPONSE]    = HallSocketWriter.onSendServerSetTimeResponse;      --是否同意设置时间结果（读写）
    --好友观战
    [OB_CMD_CHAT_MSG]               = HallSocketWriter.onSendServerNewWatchMsg;               --观战聊天（读写）
    [OB_CMD_GET_TABLE_INFO]         = HallSocketWriter.onSendServerNewTableInfo;              --获取桌子信息(读写)
    [OB_CMD_GET_OB_LIST]            = HallSocketWriter.onSendServerNewWatchList;              --获取观战列表（读写）
    [OB_CMD_GET_NUM]                = HallSocketWriter.onSendServerNewGetNumber;              --观战人数（读写）
    [OB_CMD_GET_HISTORY_MSGS]       = HallSocketWriter.onSendServerNewGetWatchHistoryMsgs;    --观战历史消息（读写）
    [FRIEND_CMD_GET_FRIEND_OB_LIST] = HallSocketWriter.onSendServerFriendsWatchList;          -- 棋友观战列表（读写）
    [OB_CMD_GET_CHARM_OB_LIST]      = HallSocketWriter.onSendServerCharmWatchList;            -- 魅力榜观战列表（读写）

    
    -- 聊天室
    [CHATROOM_CMD_ENTER_ROOM]               = HallSocketWriter.onSendServerEntryChatRoom;
    [CHATROOM_CMD_LEAVE_ROOM]               = HallSocketWriter.onSendServerLeftChatRoom;
    [CHATROOM_CMD_GET_UNREAD_MSG]           = HallSocketWriter.onSendServerLastMsg;   --获得未读消息数量
    [CHATROOM_CMD_USER_CHAT_MSG]            = HallSocketWriter.onSendServerUserMsg;      --用户发送聊天信息
    [CHATROOM_CMD_BROAdCAST_CHAT_MSG]       = HallSocketWriter.onSendClientChatMsg;
    [CHATROOM_CMD_GET_HISTORY_MSG]          = HallSocketWriter.onSendServerUnreadMsg;
    [CHATROOM_CMD_GET_UNREAD_MSG2]          = HallSocketWriter.onSendServerUnreadMsgWithTime;
    [CHATROOM_CMD_GET_MEMBER_LIST]          = HallSocketWriter.onSendServerGetMemberList;
    [CHATROOM_CMD_IS_ACT_AVALIABLE]         = HallSocketWriter.onSendServerIsActAvaliable;
    [CHATROOM_CMD_UPDATE_CHATROOM_ITEM]     = HallSocketWriter.onSendServerUpdateCRItem;
    [CHATROOM_CMD_GET_HISTORY_MSG_NEW]      = HallSocketWriter.onSendServerUnreadMsgNew;
    [CHATROOM_CMD_GET_CHESS_MATCH_MSG]      = HallSocketWriter.onSendServerChessMatchMsg;
    [CHATROOM_CMD_GET_CHESS_MATCH_MSG_NUM]  = HallSocketWriter.onSendServerChessMatchMsgNum;

    -- prop
    [PROP_CMD_UPDATE_USERDATA]      = HallSocketWriter.onSendPropCmdUpdateUserData;
    [PROP_CMD_QUERY_USERDATA]      = HallSocketWriter.onSendPropCmdQueryUserData;
    -- network type
    [CLIENT_HALL_NET_DATA_REPORT]   = HallSocketWriter.onClientHallNetDataReport;
    -- 私人房个数
    [CLIENT_ALLOC_PRIVATEROOMNUM]   = HallSocketWriter.onClientAllocPrivateRoomNum;
    -- 观战和挑战数据
    [FRIEND_CMD_GET_PLAYER_INFO]    = HallSocketWriter.onFriendCmdGeetPlayerInfo;
    [CLIENT_CMD_GETTABLESTEP]       = HallSocketWriter.onClientCmdGetTableStep;
    -- 获取当前棋局开始时间
    [CLIENT_GET_CUR_TID_START_TIME]       = HallSocketWriter.onClientGetCurTidStartTime;
    
    -- 私人房踢人
    [SERVER_CMD_KICK_PLAYER]        = HallSocketWriter.onServerCmdKickPlayer;


    -- 联网房间屏蔽消息
    [CLIENT_CMD_FORBID_USER_MSG]    = HallSocketWriter.onClientCmdForbidUserMsg;

    -- 私人房获取tid和pwd
    [CLIENT_ALLOC_GET_PRIVATEROOM_INFO]        = HallSocketWriter.onClientAllocGetPrivateroomInfo;

    -- 玩家发送礼物
    [CLIIENT_CMD_GIVEGIFT]          = HallSocketWriter.onClientCmdGiveGift;
    -- 登录比赛服务器
    [FASTMATCH_LOGINROOM_REQUEST]   = HallSocketWriter.onFastmatchLoginroomRequest;
    -- 报名
    [FASTMATCH_SIGNUP_REQUEST]      = HallSocketWriter.onFastmatchSignupRequest;
    -- 取消报名
    [FASTMATCH_CANCLESIGNUP_REQUEST]= HallSocketWriter.onFastmatchCanclesignupRequest;
    -- 比赛房间信息
    [FASTMATCH_GET_SIGNUP_INFO]     = HallSocketWriter.onFastmatchGetSignupInfo;
    -- 速赛，放弃比赛
    [FASTMATCH_GIVE_UP]             = HallSocketWriter.onFastmatchGiveUp;
    -- 速战，报名列表
    [FASTMATCH_SIGN_UP_LIST]                = HallSocketWriter.onFastSignUpList; 
    -- 获取比赛桌子信息
    [MATCH_GETTABLEINFO]                    = HallSocketWriter.onMatchGettableinfo;
    -- 获取观战的比赛桌子信息
    [MATCH_GETOBTABLEINFO]                  = HallSocketWriter.onMatchGetobtableinfo;
    -- 玩家在比赛中的状态改变
    [MATCH_PLAYER_CHANGE_STATE]             = HallSocketWriter.onMatchPlayerChangeState;
    -- 玩家在比赛中退出观战
    [MATCH_LEAVE_OB]                        = HallSocketWriter.onMatchLeaveOb;
    -- 玩家在比赛中退出观战
    [MATCH_GET_ROUND_INDEX]                 = HallSocketWriter.onMatchGetRoundIndex;
    -- 比赛进去观战桌子
    [MATCH_ENTER_OBSERVE_TABLE_REQUEST]     = HallSocketWriter.onMatchEnterObserveTable;
    --职业赛
    [LOGIN_MATCH]                           = HallSocketWriter.onLoginMatch;
    [QUERY_GAME_PLAYER_STATUS]              = HallSocketWriter.onQueryGamePlayerStatus;
    [USER_REQUEST_MATCHING]                 = HallSocketWriter.onUserRequestMatching;
    [GET_MATCH_PLAYER_INFO]                 = HallSocketWriter.onGetMatchPlayerInfo;
    [GIVE_UP_THE_RESURRECTION]              = HallSocketWriter.onGiveUpTheResurrection;
    [GIVE_UP_THE_MATCH]                     = HallSocketWriter.onGiveUpTheMatch;
    [CHECK_OUT_STATUS]                      = HallSocketWriter.onCheckOutStatus;
    [COMPETE_WATCH_LIST]                    = HallSocketWriter.onGetWatchList;
    [CHECK_MATCH_USER_GIFT_INFO]            = HallSocketWriter.onCheckMatchUserGiftInfo;
    [CHECK_MATCH_USER_MAX_SCORE]            = HallSocketWriter.onCheckMatchUserMaxScore;
    --获取新的观战桌子
    [MATCH_GET_WATCH_TID]                   = HallSocketWriter.onMatchGetWatchTid;
    --查询用户比赛排名
    [MATCH_CHECK_USER_RANK]                 = HallSocketWriter.onMatchCheckUserRank;
    --获取比赛积分
    [MATCH_GET_MATCH_SCORE]                 = HallSocketWriter.onMatchGetMatchScore;
    
    --职业赛 end
    [CHECK_ROOM_TYPE]                       = HallSocketWriter.onCheckRoomTypeByTid;
    [CHECK_WIN_COMBO]                       = HallSocketWriter.onCheckUserWinCombo;
    [THAN_SIZE_START]                        = HallSocketWriter.OnThanSizeStart;
   
    
};


	