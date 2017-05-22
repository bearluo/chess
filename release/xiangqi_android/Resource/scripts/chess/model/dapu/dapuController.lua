require("config/path_config");

require(BASE_PATH.."chessController");

DapuController = class(ChessController);

DapuController.s_cmds = 
{	
    onBack = 1;
    updateLocal = 2;
};

DapuController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end


DapuController.resume = function(self)
	ChessController.resume(self);
end


DapuController.exit_action = function(self)
	sys_exit();
end

DapuController.pause = function(self)
	ChessController.pause(self);
	Log.i("DapuController.pause");
end

DapuController.dtor = function(self)

end

-------------------------------- father func -----------------------



-------------------------------- function --------------------------
DapuController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end

DapuController.updateLocal = function(self)
    local uid = UserInfo.getInstance():getUid();
	local keys = GameCacheData.getInstance():getString(GameCacheData.DAPU_KEY .. uid,"");
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

			local mvData_json = json.decode_node(mvData_str);
			local temp = {};
			temp.index = index;
			temp.key = value;
			temp.fileName = mvData_json.fileName:get_value();
			temp.time = mvData_json.time:get_value();
			temp.result = mvData_json.result:get_value();
			temp.rival = mvData_json.rival:get_value();
			temp.mvStr = mvData_json.mvStr:get_value();
			temp.flag = mvData_json.flag:get_value();
			temp.upSex = mvData_json.m_upUser:get_value();
			temp.downSex = mvData_json.m_downUser:get_value();
			temp.m_game_end_type = mvData_json.m_game_end_type:get_value();
			if mvData_json.fenStr then
				temp.fenStr = mvData_json.fenStr:get_value();
			end
			if temp.chessString then
				temp.chessString = mvData_json.chessString:get_value();
			end
			index = index + 1;
			table.insert(data,temp);
		end
	end
    return data;
end


-------------------------------- http event ------------------------

DapuController.onGetConsoleProgressResponse = function(self,isSuccess,message)
    Log.i("onGetConsoleProgressResponse");
    if not isSuccess then
        return ;
    end
end

-------------------------------- config ----------------------------

DapuController.s_httpRequestsCallBackFuncMap  = {
};

DapuController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	DapuController.s_httpRequestsCallBackFuncMap or {});


--本地事件 包括lua dispatch call事件
DapuController.s_nativeEventFuncMap = {
};


DapuController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	DapuController.s_nativeEventFuncMap or {});



DapuController.s_socketCmdFuncMap = {
--	[HALL_SINGLE_BROADCARD_CMD_MSG]  = DapuController.onSingleBroadcastCallback;
}

DapuController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	DapuController.s_socketCmdFuncMap or {});


------------------------------------- 命令响应函数配置 ------------------------
DapuController.s_cmdConfig = 
{
    [DapuController.s_cmds.onBack] = DapuController.onBack;
    [DapuController.s_cmds.updateLocal] = DapuController.updateLocal;
}