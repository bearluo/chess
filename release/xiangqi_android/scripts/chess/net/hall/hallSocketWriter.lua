require(NET_PATH.."hall/hallSocketCmd");
require("gameBase/socketWriter");

HallSocketWriter = class(SocketWriter);

HallSocketWriter.onHallMsgHeart = function(self,packetId,info)
    
end;







HallSocketWriter.onHallMsgLogin = function(self,packetId,info)
--    print_string("socket_hall_requestLogin===================="); 	
--    local userJson = {};
--    userJson.version = PhpConfig.getVersions();
--    userJson.bid = PhpConfig.getBid();
--    userJson.money = UserInfo.getInstance():getMoney();
--    local userJson_str = json.encode(userJson);

--    print_string("userJson_str=============:" .. userJson_str);
--    self.m_socket:writeInt(packetId, UserInfo.getInstance():getUid());     --用户ID
--    self.m_socket:writeString(packetId, UserInfo.getInstance():getName());  --用户名称
--    self.m_socket:writeShort(packetId, UserInfo.getInstance():getLevel()); --用户等级
--    self.m_socket:writeByte(packetId, 1);                                  --0 隐 1 显
--    self.m_socket:writeShort(packetId, UserInfo.getInstance():getSvid());  --0    表示正常登录 非0  表示非断线重连
--	  self.m_socket:writeShort(packetId, UserInfo.getInstance():getTid());   --0    表示正常登录 非0  表示非断线重连
--    self.m_socket:writeString(packetId, userJson_str);                     --当前使用的版本号
--    self.m_socket:writeInt(packetId, UserInfo.getInstance():getScore());   --用户的分数
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
    self.m_socket:writeInt(packetId, kServerVersion);
    self.m_socket:writeInt(packetId, PhpConfig.getSid());

end 

HallSocketWriter.onHallMsgGameInfo = function(self,packetId,info)
--    self.m_socket:writeInt(packetId, UserInfo.getInstance():getUid());     --用户ID
--    self.m_socket:writeShort(packetId, UserInfo.getInstance():getLevel()); --用户等级
--    self.m_socket:writeShort(packetId, UserInfo.getInstance():getGameType()); --用户游戏类型
--    self.m_socket:writeShort(packetId, UserInfo.getInstance():getSvid()); --用户等级
--    self.m_socket:writeShort(packetId, UserInfo.getInstance():getMoneyType()); --金币场类型   


    self.m_socket:writeInt(packetId, info.roomType);                       --房间场
    self.m_socket:writeInt(packetId, UserInfo.getInstance():getUid());     --用户ID
    self.m_socket:writeInt(packetId, 0);                                   --命令字版本号
    self.m_socket:writeInt(packetId, info.playerLevel);                    --对手难易等级
    self.m_socket:writeInt(packetId, UserInfo.getInstance():getScore()); 
    self.m_socket:writeInt(packetId, UserInfo.getInstance():getDanGradingLevel()); 

end

HallSocketWriter.onHallMsgGamePlay = function(self,packetId,info)

    self.m_socket:writeInt(packetId, 3);--房间数;
    self.m_socket:writeInt(packetId, UserInfo.getInstance():getRoomConfigById(1).level);--新手场;
    self.m_socket:writeInt(packetId, UserInfo.getInstance():getRoomConfigById(2).level);--中级场;
    self.m_socket:writeInt(packetId, UserInfo.getInstance():getRoomConfigById(3).level);--大师场;

end

HallSocketWriter.onHallMsgGetRooms = function(self,packetId,info)

     self.m_socket:writeInt(packetId, UserInfo.getInstance():getUid());     --用户ID
     self.m_socket:writeShort(packetId, info[1]); --当前页数
     self.m_socket:writeShort(packetId, info[2]); --当前页数

end;

HallSocketWriter.onHallMsgCancelMatch = function(self,packetId,info)

    self.m_socket:writeInt(packetId, UserInfo.getInstance():getUid());

end


HallSocketWriter.onHallMsgCreateRoom = function(self, packetId, info)

     self.m_socket:writeInt(packetId, UserInfo.getInstance():getUid());     --用户ID
     self.m_socket:writeString(packetId, info.roomnameStr); --私人房名称    String       默认为：玩家名字+的房间
     self.m_socket:writeString(packetId, info.roompwdStr); --密码
     self.m_socket:writeInt(packetId, info.coin);     --金币数
     self.m_socket:writeShort(packetId,  info.gameType );     --类型
     self.m_socket:writeShort(packetId, info.leftTimeout1); --局时（秒）
     self.m_socket:writeShort(packetId, info.leftTimeout2); --步时（秒）
     self.m_socket:writeShort(packetId, info.leftTimeout3); --读秒（秒)    

end;



HallSocketWriter.onHallMsgSearchRoom  = function(self, packetId, info)

	print_string("===HallSearchRoomProc==socket_hall_requestLogin====================");    
    
    self.m_socket:writeInt(packetId, UserInfo.getInstance():getUid());     --用户ID
    self.m_socket:writeInt(packetId, info.roomId); --密码
    

end;

HallSocketWriter.onClientMsgRelogin = function(self, packetId, info)

    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
    self.m_socket:writeShort(packetId,UserInfo.getInstance():getTid());   --棋桌
end;

HallSocketWriter.onClientMsgGiveup  = function(self, packetId, info)

    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
    self.m_socket:writeShort(packetId,UserInfo.getInstance():getTid());   --棋桌
end;

HallSocketWriter.onHallMsgResponseServer = function(self, packetId, info)
    self.m_socket:writeInt(packetId, UserInfo.getInstance():getUid());     --用户ID
    self.m_socket:writeString(packetId,info);  --  用户名称
end;


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

HallSocketWriter.onSendClientWatchLogin = function(self, packetId, info)
    Log.i("=======观战房间登陆数据发送开始===================="); 
--    local packetId = self.m_socket:writeBegin(CLIENT_WATCH_LOGIN,MAIN_VER, SUB_VER,DEVICE_TYPE);
 	
    local userJson = {};
    userJson.version = PhpConfig.getVersions();  --版本
    userJson.bid = PhpConfig.getBid();
    local userJson_str = json.encode(userJson);
	
	userInfo = UserInfo.getInstance();

	self.m_socket:writeShort(packetId,userInfo:getOBSvid());   --观战服务器ID
	self.m_socket:writeShort(packetId,userInfo:getTid()); --观战棋桌ID 
	self.m_socket:writeInt(packetId,userInfo:getUid());  --用户id
	self.m_socket:writeString(packetId,userInfo:getName());--用户昵称
	self.m_socket:writeString(packetId,userInfo:getIcon());  --头像链接
	self.m_socket:writeShort(packetId,userInfo:getSex()); --性别 0未知，1男性，2女性
	self.m_socket:writeInt(packetId,userInfo:getWintimes());    --赢棋盘数
	self.m_socket:writeInt(packetId,userInfo:getLosetimes());   --输棋盘数
	self.m_socket:writeInt(packetId,userInfo:getDrawtimes());   --和棋盘数
	self.m_socket:writeInt(packetId,userInfo:getScore());        --经验值
	self.m_socket:writeInt(packetId,userInfo:getMoney());        --自己金币
	self.m_socket:writeInt(packetId,userInfo:getRankNum());        --自己排名
	self.m_socket:writeString(packetId,userInfo:getTitle()); --称号
	self.m_socket:writeString(packetId,userJson_str); --当前使用的版本号
    self.m_socket:writeInt(packetId,userInfo:getIsVip());   --自己是否是vip
--	self.m_socket:writeEnd(packetId);

    Log.i("======房间观战登陆数据发送完成====== tid =" ..userInfo:getTid() );

end;

HallSocketWriter.onSendClientWatchLogout = function(self, packetId, info)

    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());        --用户id
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getTid());    --观战棋桌ID

    
end;


HallSocketWriter.onSendClientWatchUserlist = function(self, packetId, info)

    self.m_socket:writeShort(packetId,UserInfo.getInstance():getOBSvid());   --观战服务器ID
    self.m_socket:writeShort(packetId,UserInfo.getInstance():getTid());   --观战棋桌ID

    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
    self.m_socket:writeShort(packetId,UserInfo.getInstance():getSeatID());   --座位ID

	self.m_socket:writeShort(packetId,0); --当前页数
	self.m_socket:writeShort(packetId,0);  -- 每页条数
    

end;

HallSocketWriter.onSendClientWatchSynData = function(self, packetId, info)
    self.m_socket:writeShort(packetId,UserInfo.getInstance():getOBSvid());   --观战服务器ID
    self.m_socket:writeShort(packetId,UserInfo.getInstance():getTid());   --观战棋桌ID

    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
    self.m_socket:writeShort(packetId,UserInfo.getInstance():getSeatID());   --座位ID



end;

HallSocketWriter.onSendClientWatchChat = function(self, packetId, info)
    
--    self.m_socket:writeShort(packetId,UserInfo.getInstance():getOBSvid());   --观战服务器ID
--    self.m_socket:writeShort(packetId,UserInfo.getInstance():getTid());   --观战棋桌ID
--    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
--    self.m_socket:writeShort(packetId,UserInfo.getInstance():getSeatID());   --座位ID
--    self.m_socket:writeShort(packetId,1);   --目前消息类型设置为 1表用户发送
--	self.m_socket:writeString(packetId,info); 
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getTid());   --观战棋桌ID
    self.m_socket:writeString(packetId,UserInfo.getInstance():getName());   --观战者用户名
    self.m_socket:writeString(packetId,info);   --聊天信息

end;


HallSocketWriter.onSendClientMsgLogin = function(self, packetId, infoType)
    local userInfo = UserInfo.getInstance();
    self.m_socket:writeInt(packetId, userInfo:getTid());
    self.m_socket:writeInt(packetId, userInfo:getUid());
    self.m_socket:writeInt(packetId, PhpConfig.getSid());--from?
    self.m_socket:writeInt(packetId, kServerVersion);--ver

    local strInfo = {};
    strInfo.version = PhpConfig.getVersions();  --版本
    strInfo.changeside = "true";  --是否支持换位
    strInfo.money = UserInfo.getInstance():getMoney();
--    strInfo.ctype = UserInfo.getInstance():getMoneyType(); --金币场类型
    strInfo.bid = PhpConfig.getBid();
    strInfo.befirst = "true";  --是否支持抢先让子
    strInfo.isundomove = true; --是否支持强制悔棋
    strInfo.client_version = kLuaVersionCode;

    strInfo.user_name = userInfo:getName();
    strInfo.uid = userInfo:getUid();
    strInfo.tid = userInfo:getTid();
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
    local strInfo_str = json.encode(strInfo);
	self.m_socket:writeString(packetId,strInfo_str); --当前使用的版本号
    print_string("userJson_str=============:" .. strInfo_str);		
    if infoType and infoType == 1 then
        self.m_socket:writeInt(packetId,1);
    else
        self.m_socket:writeInt(packetId,0);
    end
end;


HallSocketWriter.onSendClientMsgComein = function(self, packetId, info)

	self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
	self.m_socket:writeShort(packetId,UserInfo.getInstance():getLtid());  --棋桌ID  0 表示不指定桌子，由系统配对    


end;


HallSocketWriter.onSendClientMsgStart = function(self, packetId, info)

	self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
	self.m_socket:writeShort(packetId,UserInfo.getInstance():getTid()); --棋桌ID
	self.m_socket:writeShort(packetId,UserInfo.getInstance():getSeatID());   --座位ID    

end;


HallSocketWriter.onSendClientMsgForestall = function(self, packetId, info)

	--黑方应答是否抢先，响应同时推送给红方
    local subcmd = self.m_socket:readSubCmd(packetId);
	if subcmd == 2 then
		print_string("=======房间CLIENT_MSG_FORESTALL2数据发送开始====================");
	    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
	    self.m_socket:writeShort(packetId,UserInfo.getInstance():getTid());   --棋桌
		self.m_socket:writeShort(packetId,UserInfo.getInstance():getSeatID()); --座位
		self.m_socket:writeShort(packetId,info); --1-抢先 0 不抢先
	    print_string("======房间CLIENT_MSG_FORESTALL2数据发送完成======"..info);
	end    

end;



HallSocketWriter.onSendClientMsgRelogin = function(self, packetId, info)
    
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
    self.m_socket:writeShort(packetId,UserInfo.getInstance():getTid());   --棋桌

end;


HallSocketWriter.onSendClientRoomSyn = function(self, packetId, info)

    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getTid());   --棋桌


end;

HallSocketWriter.onSendClientMsgWatchlist = function(self, packetId, info)
    
    self.m_socket:writeShort(packetId,UserInfo.getInstance():getTid());   --棋桌
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id

	self.m_socket:writeShort(packetId,0); --当前页数
	self.m_socket:writeShort(packetId,0);  -- 每页条数


end;



HallSocketWriter.onSendClientGetOpenboxTime = function(self, packetId, info)
    if info then
        self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
        self.m_socket:writeInt(packetId,info);  --领取的金钱数    
    end;
end;



HallSocketWriter.onSendClientMsgLeave = function(self, packetId, info)

    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
    self.m_socket:writeShort(packetId,UserInfo.getInstance():getTid());   --棋桌
	self.m_socket:writeShort(packetId,UserInfo.getInstance():getSeatID()); --座位    
        

end;

HallSocketWriter.onSendClientMsgChat = function(self, packetId, message)

    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
    self.m_socket:writeShort(packetId,1);   --目前消息类型设置为 1表用户发送
	self.m_socket:writeString(packetId,message); --座位    

end;


HallSocketWriter.onSendClientMsgHandicap = function(self, packetId, chessID)

	self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
	self.m_socket:writeShort(packetId,UserInfo.getInstance():getTid());   --棋桌
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
	self.m_socket:writeInt(packetId,UserInfo.getInstance():getTid());   --棋桌
--	self.m_socket:writeShort(packetId,UserInfo.getInstance():getSeatID()); --座位
    
end;

HallSocketWriter.onSendClientMsgDraw2 = function(self, packetId, info)
    
	self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
	self.m_socket:writeInt(packetId,UserInfo.getInstance():getTid());   --棋桌
	self.m_socket:writeShort(packetId,info); --1-同意 2 不同意
    
end;




HallSocketWriter.onSendClientMsgUndomove = function(self, packetId, isOK)
    local subcmd = self.m_socket:readSubCmd(packetId);
    if subcmd == 1 then
	    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
	    self.m_socket:writeInt(packetId,UserInfo.getInstance():getTid());  --棋桌
    elseif subcmd == 2 then
        self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
	    self.m_socket:writeShort(packetId,UserInfo.getInstance():getTid());   --棋桌
		self.m_socket:writeShort(packetId,UserInfo.getInstance():getSeatID()); --座位
		self.m_socket:writeShort(packetId,isOK); --1-同意 2 不同意

    elseif subcmd == 12 then
    	self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
	    self.m_socket:writeInt(packetId,UserInfo.getInstance():getTid());   --棋桌
		self.m_socket:writeShort(packetId,isOK); --1-同意 2 不同意


    end;
end;



HallSocketWriter.onSendSetTimeInfo = function(self, packetId, info)
    local subcmd = self.m_socket:readSubCmd(packetId);
    if subcmd == 2 then
        self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
	    self.m_socket:writeShort(packetId,UserInfo.getInstance():getTid());   --棋桌
		self.m_socket:writeShort(packetId,UserInfo.getInstance():getSeatID()); --座位

		self.m_socket:writeShort(packetId,info.timeout1);   --局时
		self.m_socket:writeShort(packetId,info.timeout2);   --步时
		self.m_socket:writeShort(packetId,info.timeout3);   --读秒

    elseif subcmd == 4 then

        self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
	    self.m_socket:writeShort(packetId,UserInfo.getInstance():getTid());   --棋桌
		self.m_socket:writeShort(packetId,UserInfo.getInstance():getSeatID()); --座位

		self.m_socket:writeShort(packetId,info.isOK); --0 不同意 1同意

		self.m_socket:writeShort(packetId,info.timeout1);   --局时
		self.m_socket:writeShort(packetId,info.timeout2);   --步时
		self.m_socket:writeShort(packetId,info.timeout3);   --读秒
    end;


end;




HallSocketWriter.onSendClientMsgSurrender1 = function(self, packetId, isOK)

	self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
	self.m_socket:writeInt(packetId,UserInfo.getInstance():getTid());   --棋桌
--	self.m_socket:writeShort(packetId,UserInfo.getInstance():getSeatID()); --座位    
end;



HallSocketWriter.onSendClientMsgSurrender2 = function(self, packetId, isOK)

	self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
	self.m_socket:writeInt(packetId,UserInfo.getInstance():getTid());   --棋桌
	self.m_socket:writeShort(packetId,isOK); --1-同意 2 不同意  
end;




HallSocketWriter.onSendCustomMsgLoginEnter = function(self, packetId, pwd)

    local userJson = {};
    userJson.version = PhpConfig.getVersions();  --版本
    userJson.changeside = "true";  --是否支持换位
    userJson.money = UserInfo.getInstance():getMoney();
    userJson.ctype = UserInfo.getInstance():getMoneyType(); --金币场类型
    userJson.bid = PhpConfig.getBid();
    userJson.befirst = "true";  --是否支持抢先让子
    userJson.isundomove = true; --是否支持强制悔棋
    userJson.client_version = kLuaVersionCode;

    local userJson_str = json.encode(userJson);

    print_string("userJson_str=============:" .. userJson_str);	
   	self.m_socket:writeString(packetId,UserInfo.getInstance():getName()); 
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
    self.m_socket:writeShort(packetId,UserInfo.getInstance():getSex());   --棋桌

   	self.m_socket:writeInt(packetId,UserInfo.getInstance():getCustomRoomID()); --
    self.m_socket:writeShort(packetId,UserInfo.getInstance():getTid());   --棋桌
	self.m_socket:writeString(packetId,pwd); 
	self.m_socket:writeString(packetId,UserInfo.getInstance():getIcon()); --头像链接
	self.m_socket:writeString(packetId,UserInfo.getInstance():getSitemid());   --平台ID
	self.m_socket:writeString(packetId,UserInfo.getInstance():getPlaturl());   --平台链接
	self.m_socket:writeString(packetId,userJson_str); --当前使用的版本号
    

end;




HallSocketWriter.onSendClientMsgHomepress  = function(self, packetId, info)
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
    self.m_socket:writeShort(packetId,UserInfo.getInstance():getTid());   --棋桌
    self.m_socket:writeShort(packetId,info);   --2 表示按下home键，游戏后端运行 0 表示游戏回到前端运行，继续游戏
end;



HallSocketWriter.onSendClientMsgHeart   = function(self, packetId, info)

    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
	self.m_socket:writeShort(packetId,UserInfo.getInstance():getTid()); 

end;



HallSocketWriter.onSendClientWatchHeart = function(self, packetId, info)
	self.m_socket:writeShort(packetId,UserInfo.getInstance():getOBSvid());   --观战服务器ID
	self.m_socket:writeShort(packetId,UserInfo.getInstance():getTid());    --观战棋桌ID
	self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());        --用户id
	self.m_socket:writeShort(packetId,UserInfo.getInstance():getSeatID());   --座位ID

end;




HallSocketWriter.onHallMsgQuickStart = function(self, packetId, info)

    self.m_socket:writeInt(packetId, UserInfo.getInstance():getUid());     --用户ID
    self.m_socket:writeShort(packetId, UserInfo.getInstance():getLevel()); --用户等级
    self.m_socket:writeShort(packetId, UserInfo.getInstance():getMoneyType()); --金币场类型

end;


--HallSocketWriter.onHallMsgGameInfo = function(self, packetId, info)

--    self.m_socket:writeInt(packetId, UserInfo.getInstance():getUid());     --用户ID
--    self.m_socket:writeShort(packetId, UserInfo.getInstance():getLevel()); --用户等级
--    self.m_socket:writeShort(packetId, UserInfo.getInstance():getGameType()); --用户游戏类型
--    self.m_socket:writeShort(packetId, UserInfo.getInstance():getSvid()); --用户等级
--    self.m_socket:writeShort(packetId, UserInfo.getInstance():getMoneyType()); --金币场类型    

--end;

HallSocketWriter.onHallMsgCancelMatch = function(self, packetId, info)
    
    self.m_socket:writeInt(packetId, UserInfo.getInstance():getUid());     --用户ID

end;


HallSocketWriter.onClientMsgReady = function(self, packetId, info)
    Log.i("HallSocketWriter.onClientMsgReady");
    --暂时不需要给server发内容
end;

HallSocketWriter.onClientMsgLogout = function(self, packetId, info)
    Log.i("HallSocketWriter.onClientMsgLogout");
    --暂时不需要给server发内容
end;
	
HallSocketWriter.onClientMsgOffline = function(self, packetId, info)
    Log.i("HallSocketWriter.onClientMsgOffline");
    --暂时不需要给server发内容
end;

HallSocketWriter.onServerMsgForeStall = function(self, packetId, info)
    Log.i("HallSocketWriter.onServerMsgForeStall");
    self.m_socket:writeInt(packetId, info);
end;

HallSocketWriter.onServerMsgForeStallNew = function(self, packetId, info)
    Log.i("HallSocketWriter.onServerMsgForeStallNew");
    self.m_socket:writeInt(packetId, info);
end;

HallSocketWriter.onServerMsgHandicap = function(self, packetId, info)
    Log.i("HallSocketWriter.onServerMsgHandicap");
    self.m_socket:writeShort(packetId, info);
end;    


HallSocketWriter.onClientWatchList = function(self, packetId, info)
    Log.i("HallSocketWriter.onClientWatchList");
    self.m_socket:writeInt(packetId, UserInfo.getInstance():getUid());
    
end;


HallSocketWriter.onClientWatchJoin = function(self, packetId, info)
    Log.i("HallSocketWriter.onClientWatchJoin");
    self.m_socket:writeInt(packetId, UserInfo.getInstance():getUid());
    self.m_socket:writeInt(packetId, UserInfo.getInstance():getTid());
    
end;


HallSocketWriter.onClientHallCancelMatch = function(self, packetId,roomid)
    Log.i("HallSocketWriter.onClientHallCancelMatch");
    if UserInfo.getInstance():getRoomConfigById(roomid) then
        self.m_socket:writeInt(packetId, UserInfo.getInstance():getRoomConfigById(roomid).level); 
        self.m_socket:writeInt(packetId, UserInfo.getInstance():getUid());
    end
end;

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

HallSocketWriter.onSendServerEntryChatRoom = function(self,packetId,info)
    self.m_socket:writeInt(packetId,info.room_id);
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
end

HallSocketWriter.onSendServerLeftChatRoom = function(self,packetId,info)
    self.m_socket:writeInt(packetId,info.room_id);
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
end

HallSocketWriter.onSendServerLastMsg = function(self,packetId,info)
    self.m_socket:writeInt(packetId,info.room_id);
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
    self.m_socket:writeInt(packetId,info.last_msg_id);
    self.m_socket:writeInt(packetId,info.last_msg_time);
end

HallSocketWriter.onSendServerUserMsg = function(self,packetId,info)
    self.m_socket:writeInt(packetId,info.room_id);
    self.m_socket:writeInt(packetId,info.uid);
    self.m_socket:writeString(packetId,info.name);
    self.m_socket:writeString(packetId,info.msg);
end

HallSocketWriter.onSendClientChatMsg = function(self,packetId,info)
    self.m_socket:writeInt(packetId,info.room_id);
    self.m_socket:writeInt(packetId,info.uid);
    self.m_socket:writeInt(packetId,info.msg_id);
    self.m_socket:writeInt(packetId,info.msg_time);
end

HallSocketWriter.onSendServerUnreadMsg = function(self,packetId,info)
    self.m_socket:writeInt(packetId,info.room_id);
    self.m_socket:writeInt(packetId,info.uid);
    self.m_socket:writeInt(packetId,info.last_msg_time);  -- 开始时间
    self.m_socket:writeInt(packetId,info.entry_room_time);-- 结束时间
    self.m_socket:writeInt(packetId,info.version);
end

HallSocketWriter.onSendServerUnreadMsgWithTime = function(self,packetId,info)
    self.m_socket:writeInt(packetId,info.room_id);
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
    self.m_socket:writeInt(packetId,info.begin_msg_time); -- 开始时间
    self.m_socket:writeInt(packetId,info.end_msg_time); -- 结束时间
end


HallSocketWriter.onSendServerGetMemberList = function(self, packetId, info)
    self.m_socket:writeInt(packetId,info.uid);
    self.m_socket:writeInt(packetId,info.room_id);
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
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getTid() or 0);--
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

HallSocketWriter.onClientCmdCallTelPhone = function(self,packetId,info)
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());
    self.m_socket:writeInt(packetId,UserInfo.getInstance():getTid() or 0);--
end
----------------------------------------config--------------------------------------------



HallSocketWriter.s_clientCmdFunMap = {

    [HALL_MSG_HEART]                = HallSocketWriter.onHallMsgHeart;
	[HALL_MSG_LOGIN]		        = HallSocketWriter.onHallMsgLogin;
    [HALL_MSG_GAMEINFO]             = HallSocketWriter.onHallMsgGameInfo;
    [HALL_MSG_GAMEPLAY]             = HallSocketWriter.onHallMsgGamePlay;
    [HALL_MSG_GETROOMS]             = HallSocketWriter.onHallMsgGetRooms;
    [HALL_MSG_QUICKSTART]           = HallSocketWriter.onHallMsgQuickStart;
    [HALL_MSG_CANCELMATCH]          = HallSocketWriter.onHallMsgCancelMatch;
    [HALL_MSG_CREATEROOM]           = HallSocketWriter.onHallMsgCreateRoom;
    [HALL_MSG_SEARCHROOM]           = HallSocketWriter.onHallMsgSearchRoom;
    [HALL_MSG_RESPONSE_SERVER]      = HallSocketWriter.onHallMsgResponseServer;


    [CLIENT_MSG_LOGOUT]             = HallSocketWriter.onClientMsgLogout;
    [CLIENT_MSG_READY]              = HallSocketWriter.onClientMsgReady;
    [CLIENT_MSG_OFFLINE]            = HallSocketWriter.onClientMsgOffline;
    [SERVER_MSG_FORESTALL]          = HallSocketWriter.onServerMsgForeStall;
    [SERVER_MSG_HANDICAP]           = HallSocketWriter.onServerMsgHandicap;
    [SERVER_MSG_FORESTALL_NEW]      = HallSocketWriter.onServerMsgForeStallNew;

    --观战
    [CLIENT_WATCH_LIST]             = HallSocketWriter.onClientWatchList;
    [CLIENT_WATCH_JOIN]             = HallSocketWriter.onClientWatchJoin;


    [CLIENT_HALL_CANCEL_MATCH]      = HallSocketWriter.onClientHallCancelMatch;





    [CLIENT_MSG_RELOGIN]            = HallSocketWriter.onClientMsgRelogin;
    [CLIENT_MSG_GIVEUP]             = HallSocketWriter.onClientMsgGiveup;
    [CLIENT_WATCH_LOGIN]            = HallSocketWriter.onSendClientWatchLogin;
    [CLIENT_WATCH_LOGOUT]           = HallSocketWriter.onSendClientWatchLogout;
    [CLIENT_WATCH_USERLIST]         = HallSocketWriter.onSendClientWatchUserlist;
    [CLIENT_WATCH_SYNCHRODATA]      = HallSocketWriter.onSendClientWatchSynData;
    [CLIENT_WATCH_CHAT]             = HallSocketWriter.onSendClientWatchChat;
    [CLIENT_MSG_LOGIN]              = HallSocketWriter.onSendClientMsgLogin;
    [CLIENT_MSG_COMEIN]             = HallSocketWriter.onSendClientMsgComein;
    [CLIENT_MSG_START]              = HallSocketWriter.onSendClientMsgStart;
    [CLIENT_MSG_FORESTALL]          = HallSocketWriter.onSendClientMsgForestall;
    [CLIENT_MSG_RELOGIN]            = HallSocketWriter.onSendClientMsgRelogin;
    [CLIENT_MSG_SYNCHRODATA]        = HallSocketWriter.onSendClientRoomSyn;
    [CLIENT_MSG_WATCHLIST]          = HallSocketWriter.onSendClientMsgWatchlist;
    [CLIENT_GET_OPENBOX_TIME]       = HallSocketWriter.onSendClientGetOpenboxTime;
    [CLIENT_MSG_LEAVE]              = HallSocketWriter.onSendClientMsgLeave;
    [CLIENT_MSG_CHAT]               = HallSocketWriter.onSendClientMsgChat;
    [CLIENT_MSG_HANDICAP]           = HallSocketWriter.onSendClientMsgHandicap;
    [CLIENT_MSG_MOVE]               = HallSocketWriter.onSendClientMsgMove;
    [CLIENT_MSG_DRAW1]              = HallSocketWriter.onSendClientMsgDraw1;
    [CLIENT_MSG_DRAW2]              = HallSocketWriter.onSendClientMsgDraw2;
    [CLIENT_MSG_UNDOMOVE]           = HallSocketWriter.onSendClientMsgUndomove;
    [SET_TIME_INFO]                 = HallSocketWriter.onSendSetTimeInfo;
    [CLIENT_MSG_SURRENDER1]         = HallSocketWriter.onSendClientMsgSurrender1;
    [CLIENT_MSG_SURRENDER2]         = HallSocketWriter.onSendClientMsgSurrender2;


    [CUSTOMROOM_MSG_LOGIN_ENTER]    = HallSocketWriter.onSendCustomMsgLoginEnter;
    [CLIENT_MSG_HOMEPRESS]          = HallSocketWriter.onSendClientMsgHomepress;
    [CLIENT_MSG_HEART]              = HallSocketWriter.onSendClientMsgHeart;
    [CLIENT_WATCH_HEART]            = HallSocketWriter.onSendClientWatchHeart;
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
    --设置局时
    [SERVER_BROADCAST_SET_TIME]             = HallSocketWriter.onSendServerSetTime;              --设置时间（读写）
    [SERVER_BROADCAST_SET_TIME_RESPONSE]    = HallSocketWriter.onSendServerSetTimeResponse;      --是否同意设置时间结果（读写）
    --好友观战
    [OB_CMD_CHAT_MSG]               = HallSocketWriter.onSendServerNewWatchMsg;               --观战聊天（读写）
    [OB_CMD_GET_TABLE_INFO]         = HallSocketWriter.onSendServerNewTableInfo;              --获取桌子信息(读写)
    [OB_CMD_GET_OB_LIST]            = HallSocketWriter.onSendServerNewWatchList;              --获取观战列表（读写）
    [OB_CMD_GET_NUM]                = HallSocketWriter.onSendServerNewGetNumber;              --观战人数（读写）

    [FRIEND_CMD_GET_FRIEND_OB_LIST] = HallSocketWriter.onSendServerFriendsWatchList;          -- 棋友观战列表（读写）
    -- 聊天室
    [CHATROOM_CMD_ENTER_ROOM]               = HallSocketWriter.onSendServerEntryChatRoom;
    [CHATROOM_CMD_LEAVE_ROOM]               = HallSocketWriter.onSendServerLeftChatRoom;
    [CHATROOM_CMD_GET_UNREAD_MSG]           = HallSocketWriter.onSendServerLastMsg;   --获得未读消息数量
    [CHATROOM_CMD_USER_CHAT_MSG]            = HallSocketWriter.onSendServerUserMsg;      --用户发送聊天信息
    [CHATROOM_CMD_BROAdCAST_CHAT_MSG]       = HallSocketWriter.onSendClientChatMsg;
    [CHATROOM_CMD_GET_HISTORY_MSG]          = HallSocketWriter.onSendServerUnreadMsg;
    [CHATROOM_CMD_GET_UNREAD_MSG2]          = HallSocketWriter.onSendServerUnreadMsgWithTime;
    [CHATROOM_CMD_GET_MEMBER_LIST]          = HallSocketWriter.onSendServerGetMemberList;
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
    -- 私人房踢人
    [SERVER_CMD_KICK_PLAYER]        = HallSocketWriter.onServerCmdKickPlayer;
    [CLIENT_CMD_CALLTELPHONE]       = HallSocketWriter.onClientCmdCallTelPhone;
};


	