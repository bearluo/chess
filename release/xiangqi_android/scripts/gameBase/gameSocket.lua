-- gameSocket.lua
-- Author: Vicent Gong
-- Date: 2013-07-15
-- Last modification : 2013-10-12
-- Description: Implement a base class for socket 

require("core/constants");
require("core/object");
require("core/global");
require("core/socket");
require("core/anim");
require("gameBase/socketReader");
require("gameBase/socketWriter");
require("gameBase/socketProcesser")

GameSocket = class();

GameSocket.ctor = function(self, socketType, gameId, deviceType, ver, subVer)
	self.m_socket = self:createSocket(socketType, gameId, deviceType, ver, subVer);
	self.m_socket:setEvent(self,GameSocket.onSocketEvent);

	self.m_heartBeatInterval = 10000;

	self.m_socketReaders = {};
	self.m_socketWriters = {};
	self.m_socketProcessers = {};

	self.m_commonSocketReaders = {};
	self.m_commonSocketWriters = {};
	self.m_commonSocketProcessers = {};

--    self.m_isSocketCloseing = false;
end

GameSocket.dtor = function(self)
	self:stopHeartBeat();

	self.m_socketReaders = {};
	self.m_socketWriters = {};
	self.m_socketProcessers = {};

	self.m_commonSocketReaders = {};
	self.m_commonSocketWriters = {};
	self.m_commonSocketProcessers = {};

	delete(self.m_socket);
	self.m_socket = nil;
end

GameSocket.openSocket = function(self, ip, port)
	if not self:isSocketOpen() then
--        if self:isSocketCloseing() then
--            self:setAfterClosed(function()
--		        self.m_socket:open(ip,port);
--		        self.m_socket:open(ip,port);
--            end);
--        else
		    self.m_socket:open(ip,port);
--		    self.m_socket:open(ip,port);
--        end
	end
end

GameSocket.closeSocketSync = function(self) -- 这个已经不能用了 c层只有异步关闭
	if self.m_socket then
		self:stopHeartBeat();
		self.m_socket:close();
        self.m_isSocketOpen = false;
--		self.m_isSocketCloseing = true;
--        delete(self.m_closeing_anim);
--        self.m_closeing_anim = AnimFactory.createAnimInt(kAnimNormal, 0, 1, 3000, -1);
--        self.m_closeing_anim:setDebugName("socket closeing_anim");
--        self.m_closeing_anim:setEvent(self,GameSocket.onSocketClosed);
	end
end

GameSocket.closeSocketAsync = function(self)
-- 不要了  现在都是同步关闭
--	if self.m_socket then
--		self:stopHeartBeat();
--		self.m_socket:close(0);
----		self.m_isSocketCloseing = true;
--	end
    GameSocket.closeSocketSync(self);
end

GameSocket.setAfterClosed = function(self,func)
    self.m_afterSocketCloseFunc = func;
end

--GameSocket.isSocketCloseing = function(self)
--	return self.m_isSocketCloseing;
--end

GameSocket.isSocketOpen = function(self)
	return self.m_isSocketOpen;
end

GameSocket.sendMsg = function(self, cmd, info, subcmd ,writeType)
	local packetId = self:writeBegin(self.m_socket,cmd, subcmd, writeType);
	self:writePacket(self.m_socket,packetId,cmd,info);
	self:writeEnd(packetId);
	return true;
end

GameSocket.setHeartBeatInterval = function(self, milliSecond)
	self.m_heartBeatInterval = milliSecond;
end

GameSocket.setHeartBeatCmd = function(self, cmd)
	self.m_heartBeatCmd = cmd;
end

GameSocket.addSocketReader = function(self,socketReader)
 	self:addSocketHandler(self.m_socketReaders,SocketReader,socketReader);
end

GameSocket.addSocketWriter = function(self,socketWriter)
	self:addSocketHandler(self.m_socketWriters,SocketWriter,socketWriter);
end

GameSocket.addSocketProcesser = function(self,socketProcesser)
	local ret = self:addSocketHandler(self.m_socketProcessers,SocketProcesser,socketProcesser);
	if ret then
		socketProcesser:setSocketManager(self);
	end
end

GameSocket.removeSocketReader = function(self,socketReader)
	self:removeSocketHandler(self.m_socketReaders,socketReader);
end

GameSocket.removeSocketWriter = function(self,socketWriter)
	self:removeSocketHandler(self.m_socketWriters,socketWriter);
end

GameSocket.removeSocketProcesser = function(self,socketProcesser)
	self:removeSocketHandler(self.m_socketProcessers,socketProcesser);
end

GameSocket.addCommonSocketReader = function(self,socketReader)
	self:addSocketHandler(self.m_commonSocketReaders,SocketReader,socketReader);
end

GameSocket.addCommonSocketWriter = function(self,socketWriter)
	self:addSocketHandler(self.m_commonSocketWriters,SocketWriter,socketWriter);
end

GameSocket.addCommonSocketProcesser = function(self,socketProcesser)
	local ret = self:addSocketHandler(self.m_commonSocketProcessers,SocketProcesser,socketProcesser);
	if ret then
		socketProcesser:setSocketManager(self);
	end
end

GameSocket.removeCommonSocketReader = function(self,socketReader)
	self:removeSocketHandler(self.m_commonSocketReaders,socketReader);
end

GameSocket.removeCommonSocketWriter = function(self,socketWriter)
	self:removeSocketHandler(self.m_commonSocketWriters,socketWriter);
end

GameSocket.removeCommonSocketProcesser = function(self,socketProcesser)
	self:removeSocketHandler(self.m_commonSocketProcessers,socketProcesser);
end

---------------------------------private functions-----------------------------------------

--virtual
GameSocket.createSocket = function(self,socketType, gameId, deviceType, ver, subVer)
	error("Derived class must implement this function");
end

--write packet functions
--virtual
GameSocket.writeBegin = function(self, socket, cmd, subcmd, writeType)
	error("Derived class must implement this function");
end

--virtual
GameSocket.writePacket = function(self, socket, packetId, cmd, info)
	for k,v in pairs(self.m_socketWriters) do
		if v:writePacket(socket,packetId,cmd,info) then
			return true;
		end
	end

	for k,v in pairs(self.m_commonSocketWriters) do
		if v:writePacket(socket,packetId,cmd,info) then
			return true;
		end
	end

	return false;
end

--virtual
GameSocket.writeEnd = function(self, packedId)
	self.m_socket:writeEnd(packedId);
end

--read packet functions
--virtual
GameSocket.readBegin = function(self, packedId)
	return self.m_socket:readBegin(packedId);
end

--virtual
GameSocket.readPacket = function(self, socket, packetId, cmd)
	local packetInfo = nil;	

	for k,v in pairs(self.m_socketReaders) do
		local packetInfo =  v:readPacket(socket,packetId,cmd);
		if packetInfo then
			return packetInfo;
		end
	end

	for k,v in pairs(self.m_commonSocketReaders) do
		local packetInfo =  v:readPacket(socket,packetId,cmd);
		if packetInfo then
			return packetInfo;
		end
	end

	return packetInfo;
end

--virtual
GameSocket.readEnd = function(self, packedId)
	self.m_socket:readEnd(packedId);
end

--process packet functions
--virtual
GameSocket.onReceivePacket = function(self, cmd, info)

	for k,v in pairs(self.m_socketProcessers) do
		local info =  v:onReceivePacket(cmd,info);
		if info then
			return info;
		end
	end

	for k,v in pairs(self.m_commonSocketProcessers) do
		local info = v:onReceivePacket(cmd,info);
		if info then
			for k,v in pairs(self.m_socketProcessers) do
				if v:onCommonCmd(cmd,cmdInfo) then
					break;
				end
			end
			return;
		end
	end

	return false;
end

--socket event functions
--virtual
GameSocket.onSocketConnected = function(self)
	self.m_isSocketOpen = true;
	GameSocket.startHeartBeat(self);
end

--virtual
GameSocket.onSocketReconnecting = function(self)
end

--virtual
GameSocket.onSocketConnectivity = function(self)
	Log.e("onSocketConnectivity");
end

--virtual
GameSocket.onSocketConnectFailed = function(self)
    self.m_isSocketOpen = false;
end

--virtual
GameSocket.onSocketClosed = function(self)
    delete(self.m_closeing_anim);
	self.m_isSocketOpen = false;
--    self.m_isSocketCloseing = false;
    GameSocket.stopHeartBeat(self);
--    if self.m_afterSocketCloseFunc and type(self.m_afterSocketCloseFunc) == 'function' then
--        self.m_afterSocketCloseFunc();
--        self:setAfterClosed();
--    end
end

--virtual
GameSocket.onTimeout = function(self)
	self.m_isSocketOpen = false;
end

GameSocket.parseMsg = function(self, packetId)
	local cmd = self:readBegin(packetId);
    if cmd == CLIENT_MSG_HEART then
        Log.i("接收久违的 room 心跳包");
    end;
	local info = self:readPacket(self.m_socket,packetId,cmd);
	self:readEnd(packetId);
	return cmd,info;
end

GameSocket.onSocketServerPacket = function(self, packetId)
	GameSocket.stopTimer(self);
	local cmd,info = GameSocket.parseMsg(self,packetId);
	GameSocket.onReceivePacket(self,cmd,info);
end

GameSocket.onSocketEvent = function(self, eventType, param)
	if eventType == kSocketConnected then
        self:onSocketConnected();
    elseif eventType == kSocketReconnecting then
        self:onSocketReconnecting();
    elseif eventType == kSocketConnectivity then
        self:onSocketConnectivity(param);
    elseif eventType == kSocketConnectFailed then
        self:onSocketConnectFailed();
    elseif eventType == kSocketRecvPacket then
        self:onSocketServerPacket(param);
    elseif eventType == kSocketSendFailed then -- 发包失败
        to_lua("error.lua");
    elseif eventType == kSocketReadFailed then -- 读包失败
        to_lua("error.lua");
    elseif eventType == kSocketUserClose then--server挂了，socket会收到这个消息
    	self:onSocketClosed();
	end
end

--heart beat 
GameSocket.startHeartBeat = function(self)
	if not self.m_heartBeatCmd then
		return;
	end

	GameSocket.stopHeartBeat(self);

	self.m_heartBeatAnim = new(AnimDouble,kAnimRepeat,0,1,self.m_heartBeatInterval,0);
    self.m_heartBeatAnim:setDebugName("GameSocket.startHeartBeat timer");

	self.m_heartBeatAnim:setEvent(self,GameSocket.onHeartBeat);
end

GameSocket.stopHeartBeat = function(self)
	GameSocket.stopTimer(self);

	delete(self.m_heartBeatAnim);
	self.m_heartBeatAnim = nil;
end

GameSocket.onHeartBeat = function(self)
    local packetId = self:writeBegin(self.m_socket,self.m_heartBeatCmd,nil,1);
    if self.m_heartBeatCmd == CLIENT_MSG_HEART then
        Log.i("发送久违的 room 心跳包");
        self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
	    self.m_socket:writeShort(packetId,UserInfo.getInstance():getTid()); 
    elseif self.m_heartBeatCmd == CLIENT_WATCH_HEART then
    	self.m_socket:writeShort(packetId,UserInfo.getInstance():getOBSvid());   --观战服务器ID
	    self.m_socket:writeShort(packetId,UserInfo.getInstance():getTid());   --观战棋桌ID
	    self.m_socket:writeInt(packetId,UserInfo.getInstance():getUid());  --用户id
	    self.m_socket:writeShort(packetId,UserInfo.getInstance():getSeatID());   --座位ID
    end;

	self:writeEnd(packetId);

	GameSocket.restartTimer(self);
end

GameSocket.onHeartBeatTimeout = function(self)
	GameSocket.stopHeartBeat(self);
	self:onTimeout();
end

GameSocket.restartTimer = function(self)
	self:stopTimer();

	self.m_timeOutAnim = new(AnimInt, kAnimNormal,0,1,self.m_heartBeatInterval*3/4,0);
	self.m_timeOutAnim:setEvent(self, GameSocket.onHeartBeatTimeout);
    self.m_timeOutAnim:setDebugName("GameSocket.startHeartBeat timer");
end

GameSocket.stopTimer = function(self)
	delete(self.m_timeOutAnim);
	self.m_timeOutAnim = nil;
end

GameSocket.addSocketHandler = function(self,vtable,valueType,value)
	if value and (not typeof(value,valueType)) then
		error("add error type to gamesocket");
	end

	if self:checkExist(vtable,value) then
		return false;
	end

	table.insert(vtable,1,value);
	return true;
end

GameSocket.removeSocketHandler = function(self,vtable,value)
	local index = self:getIndex(vtable,value);
	if index ~= -1 then
		table.remove(vtable,index);
		return true;
	end

	return false;
end

GameSocket.getIndex = function(self,vtable,value)
	for k,v in pairs(vtable or {}) do 
		if v == value then
			return k;
		end
	end

	return -1;
end

GameSocket.checkExist = function(self,vtable,value)
	return self:getIndex(vtable,value) ~= -1;
end
