
require("config/path_config");

require(BASE_PATH.."chessController");
require(DIALOG_PATH.."progress_dialog");

PrivateController = class(ChessController);

PrivateController.s_cmds = 
{	
    back_action         = 1;
    create_custom_room  = 2;
    get_custom_list     = 3;
    login_private_room  = 4;
};

PrivateController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
    
end

PrivateController.resume = function(self)
    ChessController.resume(self);
    self:onGetCustomList();
end;

PrivateController.pause = function(self)
    ChessController.pause(self);
end;

PrivateController.dtor = function(self)
    delete(self.m_chioce_dialog);
end;

PrivateController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end;

--------------------------------function------------------------------------
PrivateController.onCreateCustomRoom = function(self, data)
    self:sendSocketMsg(CLIENT_HALL_CREATE_PRIVATEROOM, data);
end

PrivateController.onEntryRoom = function(self, index, flag)
    UserInfo.getInstance():setGameType(index);
    StateMachine.getInstance():pushState(States.OnlineRoom,StateMachine.STYPE_CUSTOM_WAIT);
end

PrivateController.onGetCustomList = function(self,flag)
    
    local data = UserInfo.getInstance():getRoomConfigById(4);
    if not data then return end;
    local info = {};
    info.level = data.level;
    info.uid = UserInfo.getInstance():getUid();
    self:sendSocketMsg(CLIENT_HALL_PRIVATEROOM_LIST, info);
    if not flag then
        ProgressDialog.show("正在刷新房间列表...",true);
    end
end

PrivateController.onLoginPrivateRoom = function(self, pwd)
    local roomData = UserInfo.getInstance():getRoomConfigById(4);
    local data = {};
    data.level = roomData.level;
    data.uid = UserInfo.getInstance():getUid();
    data.tid = UserInfo.getInstance():getTid();
    data.password = pwd;
    self:sendSocketMsg(CLIENT_HALL_JOIN_PRIVATEROOM, data);
end


PrivateController.onHallMsgCreateRoom = function(self, info)

    if not info or info.ret ~= 0 then
		if not self.m_chioce_dialog then
            require(DIALOG_PATH.."chioce_dialog");
			self.m_chioce_dialog = new(ChioceDialog);
		end

		self.m_chioce_dialog:setMode(ChioceDialog.MODE_OK);
		local message="创建自定义房间失败";
		self.m_chioce_dialog:setMessage(message);
	    self.m_chioce_dialog:setPositiveListener(nil,nil);
		self.m_chioce_dialog:show();
        return;
    end;

    UserInfo.getInstance():setTid(info.tid);
    UserInfo.getInstance():setGameType(GAME_TYPE_CUSTOMROOM);
    UserInfo.getInstance():setCustomRoomID(info.tid);
    UserInfo.getInstance():setMoneyType(UserInfo.getInstance():getRoomConfigById(4).money);
    UserInfo.getInstance():setSelfRoom(true);--  设置是自己创建的房间
    self:onEntryRoom(GAME_TYPE_CUSTOMROOM);
end

PrivateController.onHallNewMsgGetCustomList = function(self,info)
    ProgressDialog.stop();
    if info.curPage == 0 then
        self.m_custom_list = {};
    end

    if self.m_custom_list then
        for i,v in ipairs(info.items) do
            table.insert(self.m_custom_list,v);
        end
    end
    self:updateView(PrivateScene.s_cmds.get_custom_list, self.m_custom_list);

    if info.curPage == info.pageNum-1 or info.pageNum == 0 then
        self.m_custom_list = nil;
    end
end

PrivateController.onHallJoinPrivateRoom = function(self,info)
    UserInfo.getInstance():setSelfRoom(false);-- 设置不是自己创建的房间
    if info.ret == 0 then
        UserInfo.getInstance():setTid(info.tid);
        UserInfo.getInstance():setGameType(GAME_TYPE_CUSTOMROOM);
        UserInfo.getInstance():setCustomRoomID(info.tid);
        self:onEntryRoom(GAME_TYPE_CUSTOMROOM);
    elseif info.ret == 1 then
        ChessToastManager.getInstance():show("房间已经不存在了");
        self:onGetCustomList();
    else
        ChessToastManager.getInstance():show("密码错误");
        self:updateView(PrivateScene.s_cmds.show_input_pwd_dialog,true);    
    end
end

--------------------------------config--------------------------------------

PrivateController.s_cmdConfig = 
{
    [PrivateController.s_cmds.back_action]                  = PrivateController.onBack;
    [PrivateController.s_cmds.create_custom_room]		    = PrivateController.onCreateCustomRoom;
    [PrivateController.s_cmds.get_custom_list]		        = PrivateController.onGetCustomList;
    [PrivateController.s_cmds.login_private_room]		    = PrivateController.onLoginPrivateRoom;
}

PrivateController.s_socketCmdFuncMap = {
    [CLIENT_HALL_CREATE_PRIVATEROOM]                        = PrivateController.onHallMsgCreateRoom;
    [CLIENT_HALL_PRIVATEROOM_LIST]                          = PrivateController.onHallNewMsgGetCustomList;
    [CLIENT_HALL_JOIN_PRIVATEROOM]                          = PrivateController.onHallJoinPrivateRoom;
};

PrivateController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	PrivateController.s_socketCmdFuncMap or {});

PrivateController.s_httpRequestsCallBackFuncMap  = {
};

PrivateController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	PrivateController.s_httpRequestsCallBackFuncMap or {});

    
PrivateController.s_nativeEventFuncMap = {
    [kCacheImageManager]               = PrivateController.onDownLoadImage;
};
PrivateController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	PrivateController.s_nativeEventFuncMap or {});