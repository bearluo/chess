require("config/path_config");

require(BASE_PATH.."chessController");
require(DATA_PATH.."friendsData");

AddFriendsController = class(ChessController);

AddFriendsController.s_cmds = 
{	
    back_action = 1;
    phone_addfriends_btn = 2;
    search_btn = 3;
    tongxunlu_tishi = 4;
    get_recent_player = 5;
};


AddFriendsController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
    self.m_FriendsDatas = self.m_state.m_datas;
end


AddFriendsController.resume = function(self)
	ChessController.resume(self);

    local kind = kGameCacheData:getBoolean(GameCacheData.TONG_XUN_LU);
    if kind~= nil then
       if kind then
          Log.d("ZY AddFriendsController.resume11");
          self:addPhoneFriends();
       end
    end

    if self.m_FriendsDatas ~= nil then
        local postData  = {};
        postData.check_mid = {};
        for i,value in pairs(self.m_FriendsDatas) do 
            local user = {};
            postData.check_mid["mid"..i] = value.mid;
	    end
        self:sendHttpMsg(HttpModule.s_cmds.reportRecommend,postData);
    end 

end

AddFriendsController.dtor = function(self)
    delete(self.FriendsloadingDialog);
end

-------------------------------- function --------------------------------------------

AddFriendsController.loadingTile = function(self)
    delete(self.FriendsloadingDialog);
    self.FriendsloadingDialog = new(HttpLoadingDialog);
    self.FriendsloadingDialog:setType(HttpLoadingDialog.s_type.Normel,"上传通讯录",false);
    self.FriendsloadingDialog:show(nil,false);
    --self.FriendsloadingDialog:setMaskVisible(false);
end

AddFriendsController.loadingTileExit = function(self)
    if self.FriendsloadingDialog~= nil then
        self.FriendsloadingDialog:dismiss();
    end
end

AddFriendsController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end;

AddFriendsController.addPhoneFriends = function(self)
    call_native(kGetPhoneNumByPhoneAndSIM);
end;

AddFriendsController.onGetSearchFriendsResponse = function(self,isSuccess,message)
    if not isSuccess then
        return;
    end
    local message = message.data;
    self:updateView(AddFriendsScene.s_cmds.addFriends,message.list);
end

AddFriendsController.onmailListResponse = function(self,isSuccess,message)
    if not isSuccess then
        Log.d("ZY onmailListResponse isSuccess is false"..message);
        return;
    end
    
    kGameCacheData:saveBoolean(GameCacheData.TONG_XUN_LU,true);
    self:updateView(AddFriendsScene.s_cmds.addPhoneFriends,message);

end


AddFriendsController.SearchFriends = function(self,strdata)
	local post_data = {};
	post_data.keyword = strdata;
    self:sendHttpMsg(HttpModule.s_cmds.searchFriends,post_data,"搜索中");
end;

--拉取手机通讯录
AddFriendsController.onUpdatePhoneFriends = function(self,flag,data)

    Log.i("ZY onUpdatePhoneFriends");
    self:loadingTileExit();
    if not flag or not data or not data.ret then 
        ChessToastManager.getInstance():show("获取通信录失败!");
        return;
    end

    local info = {};
    info.phone_list = data.ret:get_value();
    local str = md5_string(info.phone_list);
    local strmd5 = kGameCacheData:getString(GameCacheData.TONG_XUN_LUMD5);

    if strmd5~= nil then
--        if strmd5 ~= str then -- 占时不做md5 检验通信录是否改变
--            Log.i("ZY onUpdatePhoneFriends1");
            Log.i("ZY onUpdatePhoneFriends4");
            kGameCacheData:saveString(GameCacheData.TONG_XUN_LUMD5,str);
            self:sendHttpMsg(HttpModule.s_cmds.mailListCll,info);
--        end
    else
        Log.i("ZY onUpdatePhoneFriends5");
        kGameCacheData:saveString(GameCacheData.TONG_XUN_LUMD5,str);
        self:sendHttpMsg(HttpModule.s_cmds.mailListCll,info,"搜索中");
    end

end


AddFriendsController.onRecvServerMsgFollowSuccess = function(self,info)
    if not info then return end   --0,陌生人,=1粉丝，=2关注，=3好友
    
    if info.ret == 2 then 
        ChessToastManager.getInstance():show("超出上限！",500);
    elseif info.ret == 0 then
        self:updateView(AddFriendsScene.s_cmds.changeAtt,info);
    end

end

AddFriendsController.onGetDownloadImage = function(self,flag,data) -- 用户头像
    Log.i("FriendsController.onGetDownloadImage");
    if not flag then 
        --下载失败
    end
    local info = json.analyzeJsonNode(data);
    for i,v in pairs(info) do
        Log.i(i ..":".. v );
    end
    self:updateView(AddFriendsScene.s_cmds.change_userIcon,info);
end

AddFriendsController.getRecentPlayer = function(self)
    self:sendHttpMsg(HttpModule.s_cmds.getRecentWarUser);
end

AddFriendsController.onGetRecentGamePlayer = function(self,isSuccess,message)
    if not isSuccess then
        return
    end

    local data = message.data;
    local recentGamer = {};
    recentGamer.total = data.total_no_check:get_value();
    recentGamer.list = {};

    for _,value in pairs(data.list) do
		local user = {};
		user.mid          = tonumber(value.mid:get_value()) or 0;
		user.score        = tonumber(value.score:get_value()) or 0;
        user.mnick        = ToolKit.subString(value.mnick:get_value(),16);
        user.icon_url     = value.icon_url:get_value();
		user.money        = tonumber(value.money:get_value()) or 0;
		user.iconType     = value.iconType:get_value();
		user.mactivetime  = tonumber(value.mactivetime:get_value()) or 0;
        table.insert(recentGamer.list,user);
    end

    if #recentGamer.list > 0 then
        self:updateView(AddFriendsScene.s_cmds.getRecentGamer,recentGamer);
    end
end
------------------------------------------------------------------------------------

AddFriendsController.onUpdateFriendsList = function(self,tab)
    local data = FriendsData.getInstance():getFrendsListData();
    self:updateView(FriendsScene.s_cmds.changeFriendsList,data);
end

AddFriendsController.onUpdateStatus = function(self,tab)
    self:updateView(FriendsScene.s_cmds.changeFriendstatus,tab);
end

AddFriendsController.onUpdateUserData = function(self,tab)
    self:updateView(FriendsScene.s_cmds.changeFriendsData,tab);
end
------------------------------------------------------------------------------------
AddFriendsController.onGetFriendsList = function(self)
    return FriendsData.getInstance():getFrendsListData();
end

AddFriendsController.onGetUserData = function(self,uids)
    return FriendsData.getInstance():getUserData(uids);
end

AddFriendsController.onGetUserStatus = function(self,uids)
    return FriendsData.getInstance():getUserStatus(uids);
end

-------------------------------- config ---------------------------------------------

AddFriendsController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.searchFriends] = AddFriendsController.onGetSearchFriendsResponse;
    [HttpModule.s_cmds.mailListCll] = AddFriendsController.onmailListResponse;
    [HttpModule.s_cmds.getRecentWarUser] = AddFriendsController.onGetRecentGamePlayer;
};


AddFriendsController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	AddFriendsController.s_httpRequestsCallBackFuncMap or {});


--本地事件 包括lua dispatch call事件
AddFriendsController.s_nativeEventFuncMap = {
   [kGetPhoneNumByPhoneAndSIM]               = AddFriendsController.onUpdatePhoneFriends;
   [kCacheImageManager]                      = AddFriendsController.onGetDownloadImage;
   [kFriend_FollowCallBack]                  = AddFriendsController.onRecvServerMsgFollowSuccess;
};

AddFriendsController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	AddFriendsController.s_nativeEventFuncMap or {});


AddFriendsController.s_socketCmdFuncMap = {
--    [FRIEND_CMD_ADD_FLLOW]     = AddFriendsController.onRecvServerMsgFollowSuccess;
}

AddFriendsController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	AddFriendsController.s_socketCmdFuncMap or {});

------------------------------------- 命令响应函数配置 ------------------------
AddFriendsController.s_cmdConfig = 
{
	[AddFriendsController.s_cmds.back_action]		= AddFriendsController.onBack;
    [AddFriendsController.s_cmds.phone_addfriends_btn]		= AddFriendsController.addPhoneFriends;
    [AddFriendsController.s_cmds.search_btn]		= AddFriendsController.SearchFriends;
    [AddFriendsController.s_cmds.tongxunlu_tishi]		= AddFriendsController.loadingTile;
    [AddFriendsController.s_cmds.get_recent_player]		= AddFriendsController.getRecentPlayer;
}


