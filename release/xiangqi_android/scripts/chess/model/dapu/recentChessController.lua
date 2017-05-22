require("config/path_config");

require(BASE_PATH.."chessController");

RecentChessController = class(ChessController);

RecentChessController.s_cmds = 
{	
    onBack = 1;
    updateLocal = 2;
};

RecentChessController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end


RecentChessController.resume = function(self)
	ChessController.resume(self);
end

RecentChessController.pause = function(self)
	ChessController.pause(self);
	Log.i("RecentChessController.pause");
end

RecentChessController.dtor = function(self)

end

-------------------------------- father func -----------------------



-------------------------------- function --------------------------
RecentChessController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end

RecentChessController.updateLocal = function(self)
    local uid = UserInfo.getInstance():getUid();
	local keys = GameCacheData.getInstance():getString(GameCacheData.RECENT_DAPU_KEY .. uid,"");
	if keys == "" or keys == GameCacheData.NULL then
		return ;
	end
	local keys_table = lua_string_split(keys, GameCacheData.chess_data_key_split);
	local index = 1;
	local data = {};
	for key , value in pairs(keys_table) do
		local mvData_str = GameCacheData.getInstance():getString(value .. uid,"");
		if value ~= "" and value ~= GameCacheData.NULL 
				and mvData_str ~= "" and mvData_str ~= GameCacheData.NULL then

			local mvData_json = json.decode(mvData_str);
			index = index + 1;
			table.insert(data,mvData_json);
		end
	end
    return data;
end
-------------------------------- http event ------------------------



-------------------------------- config ----------------------------

RecentChessController.s_httpRequestsCallBackFuncMap  = {
};

RecentChessController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	RecentChessController.s_httpRequestsCallBackFuncMap or {});


--本地事件 包括lua dispatch call事件
RecentChessController.s_nativeEventFuncMap = {
};


RecentChessController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	RecentChessController.s_nativeEventFuncMap or {});



RecentChessController.s_socketCmdFuncMap = {
--	[HALL_SINGLE_BROADCARD_CMD_MSG]  = RecentChessController.onSingleBroadcastCallback;
}

RecentChessController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	RecentChessController.s_socketCmdFuncMap or {});


------------------------------------- 命令响应函数配置 ------------------------
RecentChessController.s_cmdConfig = 
{
    [RecentChessController.s_cmds.onBack] = RecentChessController.onBack;
    [RecentChessController.s_cmds.updateLocal] = RecentChessController.updateLocal;
}