--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23

require(BASE_PATH.."chessController")

OwnController = class(ChessController);

OwnController.s_cmds = 
{
    onBack           = 1;
    goToMall         = 2;
    goToFeedback     = 3;
--    getFriendsRank = 4;
    goToChessFriends = 5;
    saveUserInfo     = 6;
    loadFeedbacksdk  = 7;
    modifyUserInfo   = 8;
    userInfo         = 9;
    modifyUserNameByMoney = 10;
};

OwnController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end

OwnController.dtor = function(self)
end

OwnController.resume = function(self)
	ChessController.resume(self);
	Log.i("OwnController.resume");
    if not kFeedbackGameid or not kFeedbackSiteid then
        self:loadFeedbackInfo()
    end
    HttpModule.getInstance():execute(HttpModule.s_cmds.UserGetIsRealNameAuth,{})
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
	Log.i("OwnController.onLoginSuccess")
    self:updateView(OwnScene.s_cmds.updateUserInfoView,true)
    MallData.getInstance():sendGetShopInfo()
    MallData.getInstance():getPropData()
    self:updateView(OwnScene.s_cmds.registerShowDailyTask)
    DailyTaskManager.getInstance():sendGetDailyTaskData()
    DailyTaskManager.getInstance():sendGetNewDailyTaskList();
    DailyTaskManager.getInstance():sendGetGrowTaskList();
end

OwnController.onLoginFail = function(self,data)
	Log.i("OwnController.onLoginFail");
--    ChessToastManager.getInstance():show("登录失败");
end

OwnController.updateUserInfoView = function(self)
    self:updateView(OwnScene.s_cmds.updateUserInfoView);
end

OwnController.goToMall = function(self)
    StateMachine.getInstance():pushState(States.Mall,StateMachine.STYPE_CUSTOM_WAIT);
end

require(MODEL_PATH.."feedback/feedbackState");
OwnController.goToFeedback = function(self)
    FeedbackScene.s_changeState = false;
    if kPlatform == kPlatformIOS then
        StateMachine.getInstance():pushState(States.Feedback,StateMachine.STYPE_CUSTOM_WAIT);
    else
        if not kFeedbackGameid or not kFeedbackSiteid then
            self:loadFeedbackInfo()
            ChessToastManager.getInstance():showSingle("反馈参数出错了:(");
            return;
        end;
        local postData = {};
        postData.game_id = kFeedbackGameid;
        postData.site_id = kFeedbackSiteid;
        postData.uid = UserInfo.getInstance():getUid();
        postData.user_name = UserInfo.getInstance():getName();
        postData.user_icon_url = UserInfo.getInstance():getIcon();
        postData.is_kefu_vip = (tonumber(kIsFeedbackVip) == 1 and "3") or "2"; 
        postData.kefu_vip_level = (tonumber(kIsFeedbackVip) == 1 and kFeedbackVipLevel) or "normal";
        postData.account_type = UserInfo.getInstance():getAccountTypeName();
        postData.client = kIsFeedbackClient;
        dict_set_string(kLoadFeedbackSdk, kLoadFeedbackSdk .. kparmPostfix,json.encode(postData));
        call_native(kLoadFeedbackSdk);
    end;
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

function OwnController:onSaveUserInfo(isSuccess,message)
    if not isSuccess then
        if type(message) == "number" then
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value(),2500);
        end;  
        self:updateView(OwnScene.s_cmds.updateUserInfoView);
  		return;
    end
    if(message.data ~= nil) then
  		self:explainModify(message.data);
  	end
    self:updateView(OwnScene.s_cmds.updateUserInfoView);
end

function OwnController:explainModify(data)
	local aUser = data.aUser;
	if not aUser then 
		return
	end
    
	local mnick = aUser.mnick:get_value();
	local sex = aUser.sex:get_value();
    local iconType = aUser.iconType:get_value();
    local icon_url = aUser.icon_url:get_value();
    UserInfo.getInstance():setIsModifyUserMnick(aUser.enable_modify_nick:get_value());
    if iconType then
        if iconType > 0 then --1,2,3,4界面自带的头像
            UserInfo.getInstance():setIconFile(UserInfo.DEFAULT .. iconType,UserInfo.DEFAULT_ICON[iconType] or UserInfo.DEFAULT_ICON[1]);
            UserInfo.getInstance():setIconType(iconType);
            UserInfo.getInstance():setIcon();
        elseif iconType == -1 then--本地上传的头像
            if icon_url then -- 系统默认头像
                local iconName = UserInfo.ICON;
                UserInfo.getInstance():setIconFile(icon_url,iconName..".png");
                UserInfo.getInstance():setIconType(iconType);
                UserInfo.getInstance():setIcon(icon_url);               
            end
        end
    end
    if mnick then
        UserInfo:getInstance():setName(mnick);
    end
    if sex then
	    UserInfo:getInstance():setSex(sex);
    end
end

function OwnController:upLoadImage(json_data)
--    local a = '{"time":"2015-05-12 17:55:04","flag":"10000","data":{"big":"http:\/\/chesscnmobile.17c.cn\/chess_android\/userIcon\/icon\/6996\/5726996_big.png?v=1431424504","middle":"http:\/\/chesscnmobile.17c.cn\/chess_android\/userIcon\/icon\/6996\/5726996_middle.png?v=1431424504","icon":"http:\/\/chesscnmobile.17c.cn\/chess_android\/userIcon\/icon\/6996\/5726996_icon.png?v=1431424504"}}';
--    json_data = json.decode_node(a);
    
	if not json_data then  --   上传失败           
		 print_string(" UserDisplay.upLoadImage not json_data " );
  		local message = "上传头像失败，稍候再试！";
        ChessToastManager.getInstance():show(message);
    else   -- 上传成功


    	local flag = HttpModule.explainPHPFlag(json_data);
	  	if not flag then
	  		local message = "上传头像失败，稍候再试！";
            ChessToastManager.getInstance():show(message);
	  		return;
	  	end

    	local data = json_data.data;
    	local icon = data.middle:get_value();


	  	local message = "上传头像失败...";
    	if  icon then
            message = "上传头像成功!";
            print_string("UserDisplay.upLoadImage icon = " .. icon);
            local iconName = UserInfo.ICON;
            UserInfo.getInstance():setIconFile(icon,iconName..".png");
            UserInfo.getInstance():setIconType(-1);
            UserInfo.getInstance():setIcon(icon);
            self:updateView(OwnScene.s_cmds.updateUserInfoView);
            return;
    	end
        
        ChessToastManager.getInstance():show(message);
	end
end

function OwnController:onDownLoadImageRequest(status,json_data)
    ChessController.onDownLoadImage(self,status,json_data)
    if not status or not json_data then 
        return ;
    end
    local imageName = json_data.ImageName:get_value();
    self:updateView(OwnScene.s_cmds.updateUserHead);
end

function OwnController:onUpLoadImageRequest(status,json_data)
    if not status or not json_data then 
        return ;
    end
    self:upLoadImage(json_data)
end

function OwnController:onBindWeibo(flag,json_data)
    if self.m_toggleAccountDialog and self.m_toggleAccountDialog:isShowing() then return end -- 登录
    if not flag then
        Toast.getInstance():show("登录失败");
        return;
    end
    ThirdPartyLoginProxy.bindWeibo(json_data)
end

function OwnController:onBindWeChat(flag,json_data)
    if self.m_toggleAccountDialog and self.m_toggleAccountDialog:isShowing() then return end -- 登录
    if not flag then
        Toast.getInstance():show("登录失败");
        return;
    end
    ThirdPartyLoginProxy.bindWeixin(json_data)
end

function OwnController:onBindUidResponse(isSuccess,data,message)
    if not isSuccess then
        ChessToastManager.getInstance():showSingle( message or "请求失败!");
        return ;
    end
    ChessToastManager.getInstance():showSingle("绑定成功!",2000);
    local bind_uuid = data.data.bind_uuid:get_value();
    local sid = data.data.sid:get_value();
    local bindData = nil
    if bind_uuid and sid then
        local temp = {}
        UserInfo.getInstance():updateBindAccountBySid(sid,bind_uuid);
        temp.sid = sid
        temp.bind_uuid = bind_uuid
        bindData = temp
    end
    self:updateView(OwnScene.s_cmds.updateUserInfoView);
end

function OwnController:saveUserInfo(data)
--    self.m_fileName = data.fileName;
    local post_data = {};
    local flag = false;
    if UserInfo.getInstance():getIconType() == data.iconType then
        if data.iconType == -1 then
            if data.icon_url then
                if string.find(UserInfo.getInstance():getIcon(),data.icon_url) then
                    flag = true;
                end
            else
                flag = false;
            end;
        else
            flag = true;
        end
    end
    if data.mnick ~= UserInfo.getInstance():getName() then
	    post_data.mnick = data.name;
    end

    if not flag then
        post_data.iconType = data.iconType or UserInfo.getInstance():getIconType();
        post_data.icon_url = data.icon_url;
    end

    if next(post_data) then
        HttpModule.getInstance():execute(HttpModule.s_cmds.saveUserInfo,post_data,"正在修改用户信息...");
    end
end

function OwnController:loadFeedbackSdk()
    if not kFeedbackGameid or not kFeedbackSiteid then
        self:loadFeedbackInfo()
        ChessToastManager.getInstance():showSingle("反馈参数出错了:(");
        return;
    end;
    local postData = {};
    postData.game_id = kFeedbackGameid;
    postData.site_id = kFeedbackSiteid;
    postData.uid = UserInfo.getInstance():getUid();
    postData.user_name = UserInfo.getInstance():getName();
    postData.user_icon_url = UserInfo.getInstance():getIcon();
    postData.is_kefu_vip = (tonumber(kIsFeedbackVip) == 1 and "3") or "2"; 
    postData.kefu_vip_level = (tonumber(kIsFeedbackVip) == 1 and kFeedbackVipLevel) or "normal";
    postData.account_type = UserInfo.getInstance():getAccountTypeName();
    postData.client = kIsFeedbackClient;
    dict_set_string(kLoadFeedbackSdk, kLoadFeedbackSdk .. kparmPostfix,json.encode(postData));
    call_native(kLoadFeedbackSdk);
end


function OwnController:onUserRealNameAuth(isSuccess,message)
    if HttpModule.explainPHPMessage(isSuccess,message,"认证失败") then
        self:updateView(OwnScene.s_cmds.updateRealName,0)
  		return;
    end
    ChessToastManager.getInstance():showSingle("绑定成功")
    self:updateView(OwnScene.s_cmds.updateRealName,1)
end

function OwnController:onUserGetIsRealNameAuth(isSuccess,message)
    if HttpModule.explainPHPMessage(isSuccess,message,"认证查询失败") then
        self:updateView(OwnScene.s_cmds.updateRealName,-1)
  		return;
    end
    local status = tonumber(message.data.status:get_value()) or 0
    self:updateView(OwnScene.s_cmds.updateRealName,status)
end

function OwnController:modifyUserInfo(data)
    HttpModule.getInstance():execute(HttpModule.s_cmds.uploadMySet,data);
end

function OwnController:modifyUserNameByMoney(data)
    HttpModule.getInstance():execute(HttpModule.s_cmds.UserModifyNameByMoney,data);
end

function OwnController:onChangeAccount()
    self:changeLogin()
end

function OwnController:onModifyInfoCallBack(isSuccess,message)
    if HttpModule.explainPHPMessage(isSuccess,message,"修改失败") then 
        self:updateView(OwnScene.s_cmds.updateUserInfoView);
        return 
    end
    if not message.data or message.data == "" then return end
    if not message.data.aUser or message.data.aUser == "" then return end
    local data = message.data.aUser;
    local aUser = json.analyzeJsonNode(data)
    if aUser.signature then
        local signature = aUser.signature
        UserInfo.getInstance():setSignAture(signature)
    end
    if aUser.sex then
        local sex = aUser.sex
        UserInfo.getInstance():setSex(sex)
    end
    if aUser.iconType then
        local icontype = aUser.iconType
        UserInfo.getInstance():setIconType(icontype)
    end
    if aUser.icon_url then
        local iconurl = aUser.icon_url
        UserInfo.getInstance():setIcon(iconurl)
    end
    if aUser.mnick then
        local mnick = aUser.mnick
        UserInfo.getInstance():setName(mnick)
    end
    UserInfo.getInstance():setIsModifyUserMnick(aUser.enable_modify_nick);
    self:updateView(OwnScene.s_cmds.updateUserInfoView);
end

function OwnController:onModifyNameByMoneyCallBack(isSuccess,message)
    if HttpModule.explainPHPMessage(isSuccess,message,"修改失败") then 
        self:updateView(OwnScene.s_cmds.updateUserInfoView);
        return 
    end
    if not message.data or message.data == "" then return end
    local data = message.data;
    local aUser = json.analyzeJsonNode(data)
--    if aUser.modify_money then
--        local bccoins = aUser.modify_money
--        bccoins = UserInfo.getInstance():getBccoin() - bccoins
--        UserInfo.getInstance():setBccoin(bccoins)
--    end

    if aUser.mnick then
        local mnick = aUser.mnick
        UserInfo.getInstance():setName(mnick)
    end
    self:updateView(OwnScene.s_cmds.updateUserInfoView);
end

-------------------- config --------------------------------------------------
OwnController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.UserMailGetNewMailNumber]    = OwnController.getUserMailGetNewMailNumber;
    [HttpModule.s_cmds.saveUserInfo]                = OwnController.onSaveUserInfo;
    [HttpModule.s_cmds.bindUid]                     = OwnController.onBindUidResponse;
    [HttpModule.s_cmds.UserRealNameAuth]            = OwnController.onUserRealNameAuth;
    [HttpModule.s_cmds.UserGetIsRealNameAuth]       = OwnController.onUserGetIsRealNameAuth;
    [HttpModule.s_cmds.uploadMySet]                 = OwnController.onModifyInfoCallBack;
    [HttpModule.s_cmds.UserModifyNameByMoney]       = OwnController.onModifyNameByMoneyCallBack;
    
};


OwnController.s_nativeEventFuncMap = {
    [kFriend_UpdateUserData]         = OwnController.onUpdateUserData;
    [kDownLoadImage]                 = OwnController.onDownLoadImageRequest;
    [kUpLoadImage]                   = OwnController.onUpLoadImageRequest;
    -- 绑定
    [kLoginWithWeibo]                = OwnController.onBindWeibo;
    [kLoginWeChat]                   = OwnController.onBindWeChat;
};
OwnController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	OwnController.s_nativeEventFuncMap or {});

OwnController.s_socketCmdFuncMap = {
--    [FRIEND_CMD_CHECK_PLAYER_RANK]                  = OwnController.onRecvServerMsgFriendsRankSuccess;
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
--    [OwnController.s_cmds.getFriendsRank]           = OwnController.attentionFriendsCall;
    [OwnController.s_cmds.goToChessFriends]         = OwnController.goToChessFriends;
    [OwnController.s_cmds.saveUserInfo]             = OwnController.saveUserInfo;
    [OwnController.s_cmds.loadFeedbacksdk]          = OwnController.loadFeedbackSdk;
    [OwnController.s_cmds.modifyUserInfo]           = OwnController.modifyUserInfo;
    [OwnController.s_cmds.modifyUserNameByMoney]    = OwnController.modifyUserNameByMoney;
    
    [OwnController.s_cmds.userInfo]                 = OwnController.onChangeAccount;
    
    
}