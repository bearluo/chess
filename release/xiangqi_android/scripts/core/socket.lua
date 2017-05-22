-- socket.lua
-- Author: Vicent Gong
-- Date: 2012-09-30
-- Last modification : 2014-12-04 by cuipeng
-- Description: provide basic wrapper for socket functions

require("core/object");
require("core/constants");

Socket = class();
Socket.s_sockets = {};
Socket.s_socketNames = {};
Socket.defaultOutTime = 6000;

PROTOCOL_TYPE_BUFFER="BUFFER"
PROTOCOL_TYPE_BY9="BY9"
PROTOCOL_TYPE_BY14="BY14"
PROTOCOL_TYPE_QE="QE"
PROTOCOL_TYPE_TEXAS="TEXAS"
PROTOCOL_TYPE_VOICE="VOICE"
PROTOCOL_TYPE_BY7="BY7"

Socket.ctor = function(self,sockName,sockHeader,netEndian, gameId, deviceType, ver, subVer)

	if Socket.s_socketNames[sockName] then
		error("Already have a " .. sockName .. " socket");
		return;
	end
	self.m_name_id = 0;
    self.m_socketName = sockName;
	self.m_socketType = sockName..self.m_name_id;

	Socket.s_socketNames[sockName] = self;

    self.m_sockHeader = sockHeader;
    self.m_netEndian = netEndian;
    self.m_outTime = Socket.defaultOutTime;
	self.m_gameId = gameId;
	self.m_deviceType = deviceType;
	self.m_ver = ver;
	self.m_subVer = subVer;
	
end

Socket.dtor = function(self)
	Socket.s_socketNames[self.m_socketName] = nil;
end


Socket.setOutTime = function(self,outTime)
    self.m_outTime = outTime or self.m_outTime or Socket.defaultOutTime;
end

Socket.setProtocol = function ( self,sockHeader,netEndian )
    self.m_sockHeader = sockHeader;
    self.m_netEndian = netEndian;
	socket_set_protocol ( self.m_socketType, sockHeader, netEndian );
end

Socket.setConnTimeout = function(self,time) 
    socket_set_conn_timeout(self.m_socketType,time);
end


Socket.setEvent = function(self,obj,func)
	self.m_cbObj = obj;
	self.m_cbFunc = func;
end

Socket.onSocketEvent = function(self,eventType, param)
	if self.m_cbFunc then
		self.m_cbFunc(self.m_cbObj,eventType, param);
	end
end

Socket.reconnect = function(self,num,interval)
	
end

Socket.open = function(self,ip,port)
    Socket.s_sockets[self.m_socketType] = nil;
	self.m_name_id = self.m_name_id + 1;
	self.m_socketType = self.m_socketName..self.m_name_id;
    Socket.s_sockets[self.m_socketType] = self;
	self:setProtocol ( self.m_sockHeader, self.m_netEndian );	
    local ret = socket_open(self.m_socketType,ip,port);
    delete(Socket.opening_anim);
    Socket.opening_anim = AnimFactory.createAnimInt(kAnimNormal, 0, 1, self.m_outTime, -1);
    Socket.opening_anim:setDebugName("socket opening_anim");
    Socket.opening_anim:setEvent(self,function(self)
        delete(Socket.opening_anim);
        Socket.s_sockets[self.m_socketType] = nil;
        self:onSocketEvent(kSocketConnectFailed, 0);
    end);
    return ret;
end

Socket.close = function(self,param)
    local ret = 0;
    if Socket.s_sockets[self.m_socketType] then
        delete(Socket.opening_anim);
        Socket.s_sockets[self.m_socketType] = nil;
    end
    ret = socket_close(self.m_socketType,param or -1);
    return ret;
end

Socket.writeBegin = function(self,cmd,ver,subVer,deviceType)
	return socket_write_begin(self.m_socketType,cmd,
		ver or self.m_ver,
		subVer or self.m_subVer,
		deviceType or self.m_deviceType);
end

Socket.writeBegin2 = function(self,cmd,subCmd,ver,subVer,deviceType)
	return socket_write_begin2(self.m_socketType,cmd,subCmd,
		ver or self.m_ver,
		subVer or self.m_subVer,
		deviceType or self.m_deviceType);
end

Socket.writeBegin3 = function(self,cmd,ver,gameId)
	return socket_write_begin3(self.m_socketType,
			ver or self.m_ver,
			cmd,
			gameId or self.m_gameId);
end

Socket.writeBegin4 = function(self,cmd,ver)
	return socket_write_begin4(self.m_socketType,ver or self.m_ver,cmd);
end

Socket.writeByte = function(self,packetId,value)
	return socket_write_byte(packetId,value);
end

Socket.writeShort = function(self,packetId,value)
	return socket_write_short(packetId,value);
end

Socket.writeInt = function(self,packetId,value)
	return socket_write_int(packetId,value);
end

Socket.writeInt64 = function( self,packetId,value )
	return socket_write_int64(packetId,value);
end

Socket.writeString = function(self,packetId,value)
	return socket_write_string(packetId,value);
end

Socket.writeBuffer = function(self,value)
	return socket_write_buffer(self.m_socketType,value);
end

Socket.writeEnd = function(self,packetId)
	return socket_write_end(packetId);
end

Socket.readBegin = function(self,packetId)
	return socket_read_begin(packetId);
end

Socket.readSubCmd = function(self,packetId)
	return socket_read_sub_cmd(packetId);
end

Socket.readByte = function(self,packetId,defualtValue)
	return socket_read_byte(packetId,defualtValue);
end

Socket.readShort = function(self,packetId,defualtValue)
	return socket_read_short(packetId,defualtValue);
end

Socket.readInt = function(self,packetId,defualtValue)
	return socket_read_int(packetId,defualtValue);
end

Socket.readInt64 = function( self,packetId,defualtValue )
	return socket_read_int64(packetId,defualtValue);
end

Socket.readString = function(self,packetId)
	return socket_read_string(packetId);
end

Socket.readEnd = function(self,packetId)
	return socket_read_end(packetId);
end

function event_socket(sockName, eventType, param)
	print_string("##################################"..sockName.."-"..eventType.."-"..param);
	if Socket.s_sockets[sockName] then
        delete(Socket.opening_anim);
		Socket.s_sockets[sockName]:onSocketEvent(eventType, param);
	end
end
