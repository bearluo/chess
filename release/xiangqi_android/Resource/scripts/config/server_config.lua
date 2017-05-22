require("core/object");
require("common/nativeEvent");
require("coreex/systemex");

ServerConfig = class();

ServerConfig.getInstance = function()
	if not ServerConfig.s_instance then
		ServerConfig.s_instance = new(ServerConfig);
	end
	return ServerConfig.s_instance;
end

ServerConfig.releaseInstance = function()
	delete(ServerConfig.s_instance);
	ServerConfig.s_instance = nil;
end

ServerConfig.ctor = function(self)

end

ServerConfig.dtor = function(self) 
	delete(self.m_localConfig);
	self.m_localConfig = nil;
end

ServerConfig.setHallIpPort = function(self,ip,port)
	ServerConfig.hallIp =ip;
	ServerConfig.hallPort =port;
end

ServerConfig.getHallIpPort = function(self)
	return ServerConfig.hallIp,ServerConfig.hallPort;
--    return ServerConfig.hallIp,9005;
end
ServerConfig.setRoomIpPort = function(self,ip,port)
	ServerConfig.roomIp =ip;
	ServerConfig.roomPort =port;
end

ServerConfig.getRoomIpPort = function(self)
	return ServerConfig.roomIp,ServerConfig.roomPort;
end

ServerConfig.getUploadCrashUrl = function(self)
	return 	Config.UPLOAD_CRASH_URL;
end

ServerConfig.getUpdateVersionUrl = function(self)
	return kHttpVersionUrl .. kLineid .. "/";
end

ServerConfig.getUpdateUrl = function(self)
    return kHttpUpdateUrl .. kLineid .. "/";
end

--http://chess148.by.com/tools/japk/_files/jr_landlord/update/458/6.lua
--http://chess148.by.com/tools/japk/_files/bigfile-ws/res_apk/458/update**.zip

--http://chess148.by.com/tools/japk/_files/jr_landlord/update/459/6.lua
--http://chess148.by.com/tools/japk/_files/bigfile-ws/res_apk/459/update**.patch


ServerConfig.getVersionName = function(self)
    return kVersionName;
end

ServerConfig.setCurServerLogin = function(self,isCurServerLogin)
    self.m_isCurServerLogin = isCurServerLogin;
end 

ServerConfig.getCurServerLogin = function(self)
   return self.m_isCurServerLogin or 0;
end
ServerConfig.setReconectParam = function(evidentConTime,evidentConNum, obscureConTime, obscureConNum)
    self.m_evidentConTime = evidentConTime or 1;
    self.m_evidentConNum = evidentConNum or 10;
    self.m_obscureConTime = obscureConTime or 1;
    self.m_obscureConNum = obscureConNum or 10;
end

ServerConfig.getReconectParam = function(self)
    return self.m_evidentConTime or 1, self.m_evidentConNum or 10, self.m_obscureConTime or 1, self.m_obscureConNum or 10;
end

