--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23

require(BASE_PATH.."chessController")

UserInfoController = class(ChessController);

UserInfoController.s_cmds = 
{
    saveUserInfo = 1;
    onBack = 2;
    goToMall = 3;
    goToFeedback = 4;
    downLoadHeadImg = 5;
    reLogin = 6;
    getFriendsRank = 7;
    gotoDeck = 8;
};


UserInfoController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end

UserInfoController.dtor = function(self)
end

UserInfoController.resume = function(self)
	ChessController.resume(self);
	Log.i("UserInfoController.resume");

end

UserInfoController.pause = function(self)
	ChessController.pause(self);
	Log.i("UserInfoController.pause");

end

-------------------- func ----------------------------------

UserInfoController.saveUserInfo = function(self,data)
    self.m_fileName = data.fileName;
    local post_data = {};
    post_data.iconType = data.iconType or UserInfo.getInstance():getIconType();
	post_data.mnick = data.name;
	post_data.sex = UserInfo.getInstance():getSex();
    post_data.icon_url = data.icon_url;
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
    if post_data.mnick == UserInfo.getInstance():getName() and post_data.sex == UserInfo.getInstance():getSex() and flag then
        return;
    end
    HttpModule.getInstance():execute(HttpModule.s_cmds.saveUserInfo,post_data,"正在修改用户信息...");
end

UserInfoController.onBack = function(self)
    if not self:updateView(UserInfoScene.s_cmds.closeDialog) then
        StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
    end
end

UserInfoController.goToMall = function(self)
    StateMachine.getInstance():pushState(States.Mall,StateMachine.STYPE_CUSTOM_WAIT);
end

UserInfoController.goToFeedback = function(self)
    require(MODEL_PATH.."feedback/feedbackState");
    FeedbackScene.s_changeState = false;
    StateMachine.getInstance():pushState(States.Feedback,StateMachine.STYPE_CUSTOM_WAIT);
end

UserInfoController.goToDeck = function(self)
    StateMachine.getInstance():pushState(States.vipModel,StateMachine.STYPE_CUSTOM_WAIT);
end

UserInfoController.explainModify = function(self,data)
	local aUser = data.aUser;
	if not aUser then 
		return
	end
    
	local mnick = aUser.mnick:get_value();
	local sex = aUser.sex:get_value();
    local iconType = aUser.iconType:get_value();
    local icon_url = aUser.icon_url:get_value();
    if iconType then
        if iconType > 0 then --1,2,3,4界面自带的头像
            UserInfo.getInstance():setIconFile(UserInfo.DEFAULT .. iconType,UserInfo.DEFAULT_ICON[iconType] or UserInfo.DEFAULT_ICON[1]);
            UserInfo.getInstance():setIconType(iconType);
            UserInfo.getInstance():setIcon();
        elseif iconType == -1 then--本地上传的头像
            if self.m_uploadIcon then -- 自定义头像
                local iconName = nil;

                if UserInfo.getInstance():getLoginType() == LOGIN_TYPE_BOYAA then
           
                    iconName = UserInfo.ICON..PhpConfig.TYPE_BOYAA;

                elseif UserInfo.getInstance():getLoginType() == LOGIN_TYPE_YOUKE then
            
                    iconName = UserInfo.ICON..PhpConfig.TYPE_YOUKE;

                elseif UserInfo.getInstance():getLoginType() == LOGIN_TYPE_weibo then
 
                    iconName = UserInfo.ICON..PhpConfig.TYPE_WEIBO;

                end;


                UserInfo.getInstance():setIconFile(self.m_uploadIcon,iconName..".png");
                UserInfo.getInstance():setIconType(iconType);
                UserInfo.getInstance():setIcon(self.m_uploadIcon);
                self.m_uploadIcon = nil;
            elseif icon_url then -- 系统默认头像
                 local iconName = nil;

                if UserInfo.getInstance():getLoginType() == LOGIN_TYPE_BOYAA then
           
                    iconName = UserInfo.ICON..PhpConfig.TYPE_BOYAA;

                elseif UserInfo.getInstance():getLoginType() == LOGIN_TYPE_YOUKE then
            
                    iconName = UserInfo.ICON..PhpConfig.TYPE_YOUKE;

                elseif UserInfo.getInstance():getLoginType() == LOGIN_TYPE_weibo then
 
                    iconName = UserInfo.ICON..PhpConfig.TYPE_WEIBO;

                end;


                UserInfo.getInstance():setIconFile(icon_url,iconName..".png");
                UserInfo.getInstance():setIconType(iconType);
                UserInfo.getInstance():setIcon(icon_url);               
            end;
        end;
    end;
    if mnick then
        UserInfo:getInstance():setName(mnick);
    end;
    if sex then
	    UserInfo:getInstance():setSex(sex);
    end;
end

UserInfoController.downLoadHeadImg = function(self)
--    先不实现了
--    local url = UserInfo.getInstance():getHeadIconUrl();
--    if url and url ~= "" then
--        local uid = UserInfo.getInstance():getUid();
--        UserInfo.getInstance():downLoadIcon(uid or 0,url);
--    end
end

UserInfoController.onDownLoadImageRequest = function(self,status,json_data)
    if not status or not json_data then 
        return ;
    end
    local imageName = json_data.ImageName:get_value();
--    UserInfo.getInstance():setDownHeadIconFile(UserInfo.getInstance():getUid(),imageName);
    self:updateView(UserInfoScene.s_cmds.updateUserHead);
end


UserInfoController.onUpLoadImageRequest = function(self,status,json_data)
    if not status or not json_data then 
        return ;
    end
    self:upLoadImage(json_data)
end

UserInfoController.upLoadImage = function(self , json_data)
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
			self.m_uploadIcon = icon;
            --UserInfo.getInstance():setIconFile(icon,UserInfo.ICON .. ".png");
--            local iconName = nil;

--            if UserInfo.getInstance():getLoginType() == LOGIN_TYPE_BOYAA then

--                iconName = UserInfo.ICON..PhpConfig.TYPE_BOYAA;

--            elseif UserInfo.getInstance():getLoginType() == LOGIN_TYPE_YOUKE then

--                iconName = UserInfo.ICON..PhpConfig.TYPE_YOUKE;

--            elseif UserInfo.getInstance():getLoginType() == LOGIN_TYPE_weibo then

--                iconName = UserInfo.ICON..PhpConfig.TYPE_WEIBO;

--            end;
--			self.m_icon_img:setFile(iconName .. ".png");
            self:updateView(UserInfoScene.s_cmds.upLoadImage,-1);
            return;
    	end
        
        ChessToastManager.getInstance():show(message);
	end
end
--UserInfoController.upLoadImage();

UserInfoController.reLogin = function(self)
    if not UserInfo.getInstance():isLogin() then
        self.m_hallSocket:closeSocketSync();
        self:login();
    end
end

-------------------------------- father func -----------------------

UserInfoController.onLoginSuccess = function(self,data)
	Log.i("HallController.onLoginSuccess");
    UserInfo.getInstance():setLogin(true);
    self:updateView(UserInfoScene.s_cmds.updateUserInfoView);
    MallData.getInstance():getShopData();
    MallData.getInstance():getPropData();
end

UserInfoController.onLoginFail = function(self,data)
	Log.i("HallController.onLoginFail");
    ChessToastManager.getInstance():show("登录失败");
end

-------------------- http event ----------------------------------------------

UserInfoController.onSaveUserInfo = function(self,isSuccess,message)
    if not isSuccess then
        local message = "用户信息修改失败，稍候再试！";
        ChessToastManager.getInstance():show(message);
        self:updateView(UserInfoScene.s_cmds.updateUserInfoView);
  		return;
    end
    
    if(message.data ~= nil) then
  		self:explainModify(message.data);
  	end
    self:updateView(UserInfoScene.s_cmds.updateUserInfoView);
    self:updateView(UserInfoScene.s_cmds.dismissSelectSexDialog);
end

UserInfoController.onUpdateUserData = function(self,ret)
    for i,v in pairs(ret) do
        if tonumber(v.mid) == UserInfo.getInstance():getUid() then
            self:updateView(UserInfoScene.s_cmds.updateRank,v.rank);
            return ;
        end
    end
end

UserInfoController.s_sid = {
    phone = 1;
    email = 2;
    weichat = 3;
    xinlang = 10;
    boyaa = 40;
}

UserInfoController.onBindWeibo = function(self,flag,json_data)
    if not flag then
        Toast.getInstance():show("登录失败");
        return;
    end
    local bind_uuid = json_data.sitemid:get_value();
    local mid = UserInfo.getInstance():getUid();
    Log.i("kLoginWithWeibo sitemid:"..bind_uuid);
    local post_data = {};
    post_data.bind_uuid = bind_uuid;
    post_data.mid = mid;
    post_data.sid = UserInfoController.s_sid.xinlang;

    HttpModule.getInstance():execute(HttpModule.s_cmds.bindUid,post_data,"绑定中...");
end

UserInfoController.onBindWeChat = function(self,flag,json_data)
    if not flag then
        Toast.getInstance():show("登录失败");
        return;
    end
    local bind_uuid = json_data.openid:get_value();
    local mid = UserInfo.getInstance():getUid();
    Log.i("kLoginWeChat openid:"..bind_uuid);
    local post_data = {};
    post_data.bind_uuid = bind_uuid;
    post_data.mid = mid;
    post_data.sid = UserInfoController.s_sid.weichat;

    HttpModule.getInstance():execute(HttpModule.s_cmds.bindUid,post_data,"绑定中...");
end

UserInfoController.onBindUidResponse = function(self,isSuccess,data,message)
    if not isSuccess then
        ChessToastManager.getInstance():showSingle( message or "请求失败!");
        return ;
    end
    ChessToastManager.getInstance():showSingle("绑定成功!",2000);
    local bind_uuid = data.data.bind_uuid:get_value();
    local sid = data.data.sid:get_value();
    if bind_uuid and sid then
        UserInfo.getInstance():updateBindAccountBySid(sid,bind_uuid);
    end
    self:updateView(UserInfoScene.s_cmds.updateUserInfoView);
end

-------------------- config --------------------------------------------------
UserInfoController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.saveUserInfo]    = UserInfoController.onSaveUserInfo;
    [HttpModule.s_cmds.bindUid]         = UserInfoController.onBindUidResponse;
};

UserInfoController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	UserInfoController.s_httpRequestsCallBackFuncMap or {});

UserInfoController.s_nativeEventFuncMap = {
    [kDownLoadImage] = UserInfoController.onDownLoadImageRequest;
    [kUpLoadImage] = UserInfoController.onUpLoadImageRequest;
    [kFriend_UpdateUserData] = UserInfoController.onUpdateUserData;
    -- 绑定
    [kLoginWithWeibo]       = UserInfoController.onBindWeibo;
    [kLoginWeChat]          = UserInfoController.onBindWeChat;
};

UserInfoController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	UserInfoController.s_nativeEventFuncMap or {});

UserInfoController.s_socketCmdFuncMap = {
--    [HALL_MSG_KICKUSER] = ChessController.onHallMsgKickUserClick;
};

UserInfoController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	UserInfoController.s_socketCmdFuncMap or {});


------------------------------------- 命令响应函数配置 ------------------------
UserInfoController.s_cmdConfig = 
{
    [UserInfoController.s_cmds.saveUserInfo] = UserInfoController.saveUserInfo;
    [UserInfoController.s_cmds.onBack] = UserInfoController.onBack;
    [UserInfoController.s_cmds.goToMall] = UserInfoController.goToMall;
    [UserInfoController.s_cmds.goToFeedback] = UserInfoController.goToFeedback;
    [UserInfoController.s_cmds.downLoadHeadImg] = UserInfoController.downLoadHeadImg;
    [UserInfoController.s_cmds.reLogin] = UserInfoController.reLogin;
    [UserInfoController.s_cmds.gotoDeck] = UserInfoController.goToDeck;
}