
require("config/path_config");

require(BASE_PATH.."chessController");

VipModifyController = class(ChessController);

VipModifyController.s_cmds = 
{
    onBack         = 1;
    gotoMall       = 2;
    uploadSetType  = 3;
}

VipModifyController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end

VipModifyController.resume = function(self)
	ChessController.resume(self);
    self:uploadSetType();
	Log.i("VipModifyController.resume");
end;

VipModifyController.pause = function(self)
    ChessController.pause(self);
    Log.i("VipModifyController.pause");
end;

VipModifyController.dtor = function(self)
    
end;

VipModifyController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end;

VipModifyController.gotoMall = function(self)
    StateMachine.getInstance():pushState(States.Mall,StateMachine.STYPE_CUSTOM_WAIT);
end

VipModifyController.uploadSetType = function(self)
    local info = {}
    info.version = kLuaVersionCode;
    info.my_set = json.encode(UserSetInfo.getInstance():getMySetType());
    HttpModule.getInstance():execute(HttpModule.s_cmds.uploadMySet,info);
end

VipModifyController.onUploadSetTypeResponse = function(self,isSuccess,message)
    if not isSuccess then
        return
    end

    if not message.data or message.data == "" then return end
    if not message.data.aUser or message.data.aUser == "" then return end
    local aUser = message.data.aUser;
    if not aUser.my_set or aUser.my_set == "" then return end
    local my_set = json.decode(aUser.my_set:get_value());
    --ÆåÅÌ
    UserSetInfo.getInstance():setBoardType(my_set.board);
    --Æå×Ó
    UserSetInfo.getInstance():setChessPieceType(my_set.piece);
    --Í·Ïñ¿ò
    UserSetInfo.getInstance():setHeadFrameType(my_set.picture_frame);

    UserInfo.getInstance():setUserSet(my_set)
end

VipModifyController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.uploadMySet] = VipModifyController.onUploadSetTypeResponse;
};

VipModifyController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	VipModifyController.s_httpRequestsCallBackFuncMap or {});

VipModifyController.s_cmdConfig = 
{
	[VipModifyController.s_cmds.onBack]		         = VipModifyController.onBack;
	[VipModifyController.s_cmds.gotoMall]		     = VipModifyController.gotoMall;
	[VipModifyController.s_cmds.uploadSetType]		 = VipModifyController.uploadSetType;
    
}