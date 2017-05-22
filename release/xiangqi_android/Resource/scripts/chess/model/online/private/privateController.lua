
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
    get_sever_room_num = 5;
};

PrivateController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
    
end

PrivateController.resume = function(self)
    ChessController.resume(self);
    self:getSeverRoomNum()
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

PrivateController.onGetCustomList = function(self,flag)
    
    local data = RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_PRIVATE_ROOM);
    if not data then return end;
    local info = {};
    info.level = data.level;
    info.uid = UserInfo.getInstance():getUid();
    self:sendSocketMsg(CLIENT_HALL_PRIVATEROOM_LIST, info);
    self:updateView(PrivateScene.s_cmds.startLoading)
end

PrivateController.onLoginPrivateRoom = function(self, pwd)
    local roomData = RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_PRIVATE_ROOM);
    local data = {};
    data.level = roomData.level;
    data.uid = UserInfo.getInstance():getUid();
    data.tid = RoomProxy.getInstance():getTid();
    data.password = pwd;
    self:sendSocketMsg(CLIENT_HALL_JOIN_PRIVATEROOM, data);
end

function PrivateController.getSeverRoomNum(self)
    local roomConfig = RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_PRIVATE_ROOM); -- 私人房
    if roomConfig then
        local info = {};
        info.level = roomConfig.level;
        info.uid = UserInfo.getInstance():getUid();
        self:sendSocketMsg(CLIENT_ALLOC_PRIVATEROOMNUM,info);
    end
end 
require(DIALOG_PATH.."chioce_dialog");

PrivateController.onHallMsgCreateRoom = function(self, info)

    if not info or info.ret ~= 0 then
		if not self.m_chioce_dialog then
			self.m_chioce_dialog = new(ChioceDialog);
		end

		self.m_chioce_dialog:setMode(ChioceDialog.MODE_OK);
		local message="创建自定义房间失败";
		self.m_chioce_dialog:setMessage(message);
	    self.m_chioce_dialog:setPositiveListener(nil,nil);
		self.m_chioce_dialog:show();
        return;
    end;

    RoomProxy.getInstance():setTid(info.tid);
    UserInfo.getInstance():setCustomRoomID(info.tid);
    RoomProxy.getInstance():gotoPrivateRoom(true)
end

PrivateController.onHallNewMsgGetCustomList = function(self,info)
    self:updateView(PrivateScene.s_cmds.stopLoading)
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
    if info.ret == 0 then
        RoomProxy.getInstance():setTid(info.tid);
        UserInfo.getInstance():setCustomRoomID(info.tid);
        RoomProxy.getInstance():gotoPrivateRoom(false)
    elseif info.ret == 1 then
        ChessToastManager.getInstance():show("已有棋友应战，试试创建房间发起约战吧");
        self:onGetCustomList();
    else
        ChessToastManager.getInstance():show("密码错误");
        self:updateView(PrivateScene.s_cmds.show_input_pwd_dialog,true);    
    end
end

function PrivateController.onGetRoomNumCallBack(self,info)
    if info and info.private_room_num and info.private_room_total_num then
        self:updateView(PrivateScene.s_cmds.setRoomNum,info.private_room_total_num,info.private_room_num);
    end
end 
--------------------------------config--------------------------------------

PrivateController.s_cmdConfig = 
{
    [PrivateController.s_cmds.back_action]                  = PrivateController.onBack;
    [PrivateController.s_cmds.create_custom_room]		    = PrivateController.onCreateCustomRoom;
    [PrivateController.s_cmds.get_custom_list]		        = PrivateController.onGetCustomList;
    [PrivateController.s_cmds.login_private_room]		    = PrivateController.onLoginPrivateRoom;
    [PrivateController.s_cmds.get_sever_room_num]		    = PrivateController.getSeverRoomNum;
}

PrivateController.s_socketCmdFuncMap = {
    [CLIENT_HALL_CREATE_PRIVATEROOM]                        = PrivateController.onHallMsgCreateRoom;
    [CLIENT_HALL_PRIVATEROOM_LIST]                          = PrivateController.onHallNewMsgGetCustomList;
    [CLIENT_HALL_JOIN_PRIVATEROOM]                          = PrivateController.onHallJoinPrivateRoom;
    [CLIENT_ALLOC_PRIVATEROOMNUM] = PrivateController.onGetRoomNumCallBack;
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