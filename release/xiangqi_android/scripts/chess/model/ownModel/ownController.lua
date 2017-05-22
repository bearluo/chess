--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23

require(BASE_PATH.."chessController")

OwnController = class(ChessController);

OwnController.s_cmds = 
{
    onBack = 1;
    goToMall = 2;
    goToFeedback = 3;
    getFriendsRank = 4;
    goToChessFriends = 5;
};


OwnController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end

OwnController.dtor = function(self)
end

OwnController.resume = function(self)
	ChessController.resume(self);
	Log.i("OwnController.resume");
end

OwnController.pause = function(self)
	ChessController.pause(self);
	Log.i("OwnController.pause");

end

-------------------- func ----------------------------------

OwnController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end

OwnController.onLoginSuccess = function(self,data)
	Log.i("OwnController.onLoginSuccess");
    UserInfo.getInstance():setLogin(true);
    self:updateView(OwnScene.s_cmds.updateUserInfoView);
    MallData.getInstance():getShopData();
    MallData.getInstance():getPropData();
end

OwnController.onLoginFail = function(self,data)
	Log.i("OwnController.onLoginFail");
    ChessToastManager.getInstance():show("登录失败");
end

OwnController.updateUserInfoView = function(self)
    self:updateView(OwnScene.s_cmds.updateUserInfoView);
end

OwnController.goToMall = function(self)
    StateMachine.getInstance():pushState(States.Mall,StateMachine.STYPE_CUSTOM_WAIT);
end

OwnController.goToFeedback = function(self)
    require(MODEL_PATH.."feedback/feedbackState");
    FeedbackScene.s_changeState = false;
    StateMachine.getInstance():pushState(States.Feedback,StateMachine.STYPE_CUSTOM_WAIT);
end

OwnController.goToChessFriends = function(self)
    StateMachine.getInstance():pushState(States.Friends,StateMachine.STYPE_CUSTOM_WAIT);
end


--查询单个用户的好友榜排名
OwnController.attentionFriendsCall = function(self)

    local info = {};
    info.target_uid = UserInfo.getInstance():getUid();
    info.uid = UserInfo.getInstance():getUid();

    if info.target_uid == nil or info.uid == nil then --ZHENGYI
        return;
    end
        
    self:sendSocketMsg(FRIEND_CMD_CHECK_PLAYER_RANK,info);
end

--查询单个用户的好友榜排名 callback
OwnController.onRecvServerMsgFriendsRankSuccess = function(self,info)
    if not info then return end   
    self:updateView(OwnScene.s_cmds.updateFriendsRank,info);

end
-- 用户数据更新
OwnController.onUpdateUserData = function(self,ret)
    for i,v in pairs(ret) do
        if tonumber(v.mid) == UserInfo.getInstance():getUid() then
            self:updateView(OwnScene.s_cmds.updateMasterAndFansRank,v);
            return ;
        end
    end
end

OwnController.getUserMailGetNewMailNumber = function(self,isSuccess,message)
    ChessController.getUserMailGetNewMailNumber(self,isSuccess,message);
    self:updateView(OwnScene.s_cmds.updateUserInfoView);
end

-------------------- config --------------------------------------------------
OwnController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.UserMailGetNewMailNumber]    = OwnController.getUserMailGetNewMailNumber;
};


OwnController.s_nativeEventFuncMap = {
    [kFriend_UpdateUserData]                        = OwnController.onUpdateUserData;
};
OwnController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	OwnController.s_nativeEventFuncMap or {});

OwnController.s_socketCmdFuncMap = {
    [FRIEND_CMD_CHECK_PLAYER_RANK]                  = OwnController.onRecvServerMsgFriendsRankSuccess;
};
-- 合并父类 方法
OwnController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	OwnController.s_httpRequestsCallBackFuncMap or {});

OwnController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	OwnController.s_socketCmdFuncMap or {});

------------------------------------- 命令响应函数配置 ------------------------
OwnController.s_cmdConfig = 
{
    [OwnController.s_cmds.onBack]                   = OwnController.onBack;
    [OwnController.s_cmds.goToMall]                 = OwnController.goToMall;
    [OwnController.s_cmds.goToFeedback]             = OwnController.goToFeedback;
    [OwnController.s_cmds.getFriendsRank]           = OwnController.attentionFriendsCall;
    [OwnController.s_cmds.goToChessFriends]         = OwnController.goToChessFriends;
}