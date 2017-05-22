--region terminalInfo.lua
--Date
--此文件由[BabeLua]插件自动生成
-- TerminalInfo.lua
-- 终端设备相关信息
require("common/nativeEvent");
require(UPDATE_PATH.."httpFileGrap");

TerminalInfo = class();

TerminalInfo.s_instance = nil;

TerminalInfo.getInstance = function()
	if not TerminalInfo.s_instance then
		TerminalInfo.s_instance = new(TerminalInfo);
	end
	return TerminalInfo.s_instance;
end

TerminalInfo.releaseInstance = function()
	if TerminalInfo.s_instance then
		delete(TerminalInfo.s_instance);
		TerminalInfo.s_instance = nil;
	end
end

TerminalInfo.s_dict_name 						= "TerminalInfoTable";

-- SD卡信息相关
TerminalInfo.s_dict_key_sdcard_state			= "sdcard_state";
-- SIM卡是否存在
TerminalInfo.s_dict_key_is_sim_exist			= "is_sim_exist";
-- SD卡状态
TerminalInfo.s_sdcard_state_unknown				= 0;			-- 未知（除了可读可写，只读状态外的状态）
TerminalInfo.s_sdcard_state_writable			= 1;			-- 可读可写
TerminalInfo.s_sdcard_state_readonly			= 2;			-- 只读

--网络类型
TerminalInfo.s_dict_key_network_type			= "network_type";
--TerminalInfo.s_signalChangeEvent = EventDispatcher.getInstance():getUserEvent();--信号变化

TerminalInfo.ctor = function(self)

end

TerminalInfo.dtor = function(self)

end

TerminalInfo.getOperator = function(self)
    return self.m_operator or "";
end

TerminalInfo.setOperator = function(self, operator)
    self.m_operator = operator;
end

TerminalInfo.getOperatorType = function(self)
    return self.m_operator_type or -1;
end

TerminalInfo.setOperatorType = function(self, operator)
    self.m_operator_type = operator;
end

TerminalInfo.getPhoneImei = function(self)
    return self.m_phoneImei or "";
end

TerminalInfo.setPhoneImei = function(self, phoneImei)
    self.m_phoneImei = phoneImei;
end

TerminalInfo.getSDCardState = function(self)
	call_native("GetSDCardStateForLua");
	local state = dict_get_int(TerminalInfo.s_dict_name, TerminalInfo.s_dict_key_sdcard_state, 0);
	return state;
end

-- 判断SD卡是否可写
-- @return true 可写， false不可写；1可写可读，0未知，2只读
TerminalInfo.isSDCardWritable = function(self)
	return self:getSDCardState() == 1;
end

-- 获取ROM上面的升级文件存储路径，用于当SD不可写的情况
-- /data/data/包名/app_apkUpdate/
TerminalInfo.getInternalUpdatePath = function(self)
	call_native("GetInternalUpdatePathForLua");
	local path = dict_get_string(TerminalInfo.s_dict_name, TerminalInfo.s_dict_key_internal_update_path) or "";
	return path;
end

-- 网络类型
-- -1为没有连接网络或者未知
-- 1为wifi
-- 2为2G
-- 3为3G
-- 4为4G
TerminalInfo.getNetWorkType = function(self)
    local networkTypeFlag = nil;
    call_native("GetNetWorkTypeForLua");
	networkTypeFlag = dict_get_string(TerminalInfo.s_dict_name, TerminalInfo.s_dict_key_network_type) or "-1";
--    Log.i("TerminalInfo.getNetWorkType and networkTypeFlag is " .. networkTypeFlag);
    return tonumber(networkTypeFlag);
end

--网络类型变化、手机信号变化、Wifi强度变化
--networkTypeFlag 1为WIFI 2为2G 3为3G 4为4G
function event_wifiStateChange()
    local networkTypeFlag = dict_get_int("network_info","type",0);
--    Log.i("TerminalInfo.event_wifiStateChange networkTypeFlag " .. networkTypeFlag);
    --暂时不需要分发消息
--    if networkTypeFlag == -1 or networkTypeFlag == 1 then
--        EventDispatcher.getInstance():dispatch(TerminalInfo.s_signalChangeEvent);
--    end
    HttpFileGrap.getInstance():onResponseWifiChange(networkTypeFlag);
end
--endregion
