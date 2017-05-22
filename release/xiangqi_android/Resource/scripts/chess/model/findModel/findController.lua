--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23

require(BASE_PATH.."chessController")

FindController = class(ChessController);

FindController.s_cmds = 
{
    onBack              = 1;
    requestFollow       = 2;
    requestWulinBoothRecommend  = 3;
    onEndgateMenuBtnClick = 4;
    requestData         = 5;
    quickPlay           = 6;
    save_mychess        = 7;
    onLoadEndgate       = 8;
};



function FindController.ctor(self, state, viewClass, viewConfig)
	self.m_state = state;
    self:initData();
end


function FindController.dtor(self)
    delete(self.m_forbid_dialog);
end

function FindController.resume(self)
	ChessController.resume(self);
	Log.i("FindController.resume");
    
    if not self.mInit then
        self.mInit = true;
        self:requestFriendsGetRecentWarUser();

    end
end


function FindController.pause(self)
	ChessController.pause(self);
	Log.i("FindController.pause");

end


function FindController.initData(self)
    self.mWulinBoothRecommendOffset = 0;
    self.mSendWulinBoothRecommendNoMore = false;
    self.mWulinBooth = {};
    for i=1,3 do
        self.mWulinBooth[i] = {};
        self.mWulinBooth[i].offset = 0;
        self.mWulinBooth[i].noMore = false;
    end
end

function FindController.requestData(self)
    self:initData();
    self:requestGetActionList();
    self:requestFriendsGetRecentWarUser();
    self:requestWulinBoothRecommend();
end



function FindController.requestGetActionList(self)
    local params = {};
    params.versions = kLuaVersion;
    HttpModule.getInstance():execute(HttpModule.s_cmds.IndexGetActionList,params);
end


function FindController.onIndexGetActionListResponse(self,isSuccess,message)

    if not isSuccess or message.data:get_value() == nil then

        self:updateView(FindScene.s_cmds.init_ad_scroll_view);
        return ;
    end

    local tab = json.analyzeJsonNode(message.data);


    self:updateView(FindScene.s_cmds.init_ad_scroll_view,tab);
end


function FindController.requestFriendsGetRecentWarUser(self)
    local params = {};
    params.mid = UserInfo.getInstance():getUid();
	params.offset = 0;
	params.limit = 3;
    HttpModule.getInstance():execute(HttpModule.s_cmds.FriendsGetRecentWarUser,params);
end


function FindController.onFriendsGetRecentWarUserResponse(self,isSuccess,message)
    if not isSuccess or message.data:get_value() == nil then

        self:updateView(FindScene.s_cmds.init_recently_player_view);
        return ;
    end
    
    local tab = json.analyzeJsonNode(message.data);


    self:updateView(FindScene.s_cmds.init_recently_player_view,tab.list);
end


function FindController.requestFollow(self,data)
    if type(data) ~= "table" then return end
    
    local params = {};
	params.target_mid = data.mid;
    if data.relation == 0 or data.relation == 1 then
	    params.op = 1;
    else
        params.op = 0;
    end

    HttpModule.getInstance():execute(HttpModule.s_cmds.FriendsAddFriend,params);
end

function FindController.onFriendsAddFriendResponse(self,isSuccess,message)
    if HttpModule.explainPHPMessage(isSuccess,message,"操作失败") then
        return ;
    end
    
    local tab = json.analyzeJsonNode(message.data);


    self:updateView(FindScene.s_cmds.add_friend_response,tab);
end


function FindController.requestWulinBoothRecommend(self)
    if self.mSendWulinBoothRecommendNoMore or self.sendWulinBoothRecommendIng then 
        return 
    end
    self.sendWulinBoothRecommendIng = true;

    self.mWulinBoothRecommendOffset = self.mWulinBoothRecommendOffset or 0;
    local params = {};
	params.limit = 3;

    params.offset = self.mWulinBoothRecommendOffset;
    HttpModule.getInstance():execute(HttpModule.s_cmds.WulinBoothRecommend,params);
end


function FindController.onWulinBoothRecommendResponse(self,isSuccess,message)
    self.sendWulinBoothRecommendIng = false;
    if not isSuccess or message.data:get_value() == nil then

        self:updateView(FindScene.s_cmds.wulin_booth_recommend_response);
        return ;
    end
    
    local tab = json.analyzeJsonNode(message.data);
    local list = tab.list;
    if type(list) ~= "table" or #list == 0 then
        self:updateView(FindScene.s_cmds.wulin_booth_recommend_response,{},true,tab.total == 0);
        self.mSendWulinBoothRecommendNoMore = true;
        return ;
    end

    self.mWulinBoothRecommendOffset = self.mWulinBoothRecommendOffset + #list;
    self:updateView(FindScene.s_cmds.wulin_booth_recommend_response,list,false);
end


function FindController.onEndgateMenuBtnClick(self,index)
    if not self.mWulinBooth then return end
    self.mWulinBooth[index].offset = 0;
    self.mWulinBooth[index].noMore = false;
end


function FindController.requestWulinBooth(self,index,sort)
    if self.mWulinBooth[index].sendIng or self.mWulinBooth[index].noMore then return end
    self.mWulinBooth[index].sendIng = true;
    self.mWulinBooth[index].offset = self.mWulinBooth[index].offset or 0;
    local params = {};
	params.limit = 5;

    params.offset = self.mWulinBooth[index].offset;
    params.sort_type = sort;

    if index == 1 then
        HttpModule.getInstance():execute(HttpModule.s_cmds.WulinBoothGetMyMark,params);
    elseif index == 2 then

		params.sort_field = "add_time";
        HttpModule.getInstance():execute(HttpModule.s_cmds.WulinBoothGetBoothTimeList,params);
    elseif index == 3 then

		params.sort_field = "prize_pool";
        HttpModule.getInstance():execute(HttpModule.s_cmds.WulinBoothGetBoothJackpotList,params);
    end
end


function FindController.onWulinBoothGetMyMarkBoothResponse(self,isSuccess,message)
    local index = 1;
    self.mWulinBooth[index].sendIng = false;
    if not isSuccess or message.data:get_value() == nil then

        self:updateView(FindScene.s_cmds.add_endgate,index);
        return ;
    end
    
    local tab = json.analyzeJsonNode(message.data);
    local list = tab.list;
    if type(list) ~= "table" or #list == 0 then

        self:updateView(FindScene.s_cmds.add_endgate,index,{},true);
        self.mWulinBooth[index].noMore = true;
        return ;
    end


    self.mWulinBooth[index].offset = self.mWulinBooth[index].offset + #list;


    self:updateView(FindScene.s_cmds.add_endgate,index,list,false);
end


function FindController.onWulinBoothGetBoothTimeListResponse(self,isSuccess,message)
    local index = 2;
    self.mWulinBooth[index].sendIng = false;
    if not isSuccess or message.data:get_value() == nil then

        self:updateView(FindScene.s_cmds.add_endgate,index);
        return ;
    end
    
    local tab = json.analyzeJsonNode(message.data);
    local list = tab.list;
    if type(list) ~= "table" or #list == 0 then

        self:updateView(FindScene.s_cmds.add_endgate,index,{},true);
        self.mWulinBooth[index].noMore = true;
        return ;
    end
    

    self.mWulinBooth[index].offset = self.mWulinBooth[index].offset + #list;


    self:updateView(FindScene.s_cmds.add_endgate,index,list,false);
end


function FindController.onWulinBoothGetBoothJackpotListResponse(self,isSuccess,message)
    local index = 3;
    self.mWulinBooth[index].sendIng = false;
    if not isSuccess or message.data:get_value() == nil then

        self:updateView(FindScene.s_cmds.add_endgate,index);
        return ;
    end
    
    local tab = json.analyzeJsonNode(message.data);
    local list = tab.list;
    if type(list) ~= "table" or #list == 0 then

        self:updateView(FindScene.s_cmds.add_endgate,index,{},true);
        self.mWulinBooth[index].noMore = true;
        return ;
    end
    

    self.mWulinBooth[index].offset = self.mWulinBooth[index].offset + #list;


    self:updateView(FindScene.s_cmds.add_endgate,index,list,false);
end

function FindController:quickPlay()
    -- 封号状态
    if UserInfo.getInstance():isFreezeUser() then return end;
    -- 判断是否联网
    if not self:isLogined() then return ;end

    local roomConfig = RoomConfig.getInstance();
    local money = UserInfo.getInstance():getMoney();

    local gotoRoom = RoomProxy.getInstance():getMatchRoomByMoney(money);
    
    if not gotoRoom then 
        ChessToastManager.getInstance():showSingle("没有合适的场次");
    else
        RoomProxy.getInstance():gotoLevelRoom(gotoRoom.level)
    end
end


-- isSelf,是否个人收藏
function FindController.onSaveMychess(self,isSelf, chessData)
    local post_data = {};
    post_data.mid = UserInfo.getInstance():getUid();
    post_data.manual_id = chessData.manual_id;
    post_data.collect_type = (isSelf and 2) or 1; -- 收藏类型, 1公共收藏，2人个收藏 
    self:sendHttpMsg(HttpModule.s_cmds.openOrSelfChess,post_data,"请求中...");   
end


function FindController.onSaveChessCallBack(self, flag, message)
    if not flag then
        if type(message) == "number" then
            return; 
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
            return;
        end;        
    end;
    local data = json.analyzeJsonNode(message.data);
    self:updateView(FindScene.s_cmds.save_mychess,data);
end

-------------------- func ----------------------------------


function FindController.onBack(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end

-------------------- config --------------------------------------------------
FindController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.IndexGetActionList]                      = FindController.onIndexGetActionListResponse;
    [HttpModule.s_cmds.FriendsGetRecentWarUser]                 = FindController.onFriendsGetRecentWarUserResponse;
    [HttpModule.s_cmds.FriendsAddFriend]                        = FindController.onFriendsAddFriendResponse;
    [HttpModule.s_cmds.WulinBoothRecommend]                     = FindController.onWulinBoothRecommendResponse;

    [HttpModule.s_cmds.WulinBoothGetMyMark]                     = FindController.onWulinBoothGetMyMarkBoothResponse;
    [HttpModule.s_cmds.WulinBoothGetBoothTimeList]              = FindController.onWulinBoothGetBoothTimeListResponse;
    [HttpModule.s_cmds.WulinBoothGetBoothJackpotList]           = FindController.onWulinBoothGetBoothJackpotListResponse;
    [HttpModule.s_cmds.openOrSelfChess]                         = FindController.onSaveChessCallBack;
};


FindController.s_nativeEventFuncMap = {
};
FindController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	FindController.s_nativeEventFuncMap or {});

FindController.s_socketCmdFuncMap = {
};
-- 合并父类 方法
FindController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	FindController.s_httpRequestsCallBackFuncMap or {});

FindController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	FindController.s_socketCmdFuncMap or {});

------------------------------------- 命令响应函数配置 ------------------------
FindController.s_cmdConfig = 
{
    [FindController.s_cmds.onBack]                          = FindController.onBack;
    [FindController.s_cmds.requestFollow]                   = FindController.requestFollow;
    [FindController.s_cmds.requestWulinBoothRecommend]      = FindController.requestWulinBoothRecommend;

    [FindController.s_cmds.onEndgateMenuBtnClick]           = FindController.onEndgateMenuBtnClick;
    [FindController.s_cmds.onLoadEndgate]                   = FindController.requestWulinBooth;
    [FindController.s_cmds.requestData]                     = FindController.requestData;
    [FindController.s_cmds.quickPlay]                       = FindController.quickPlay;
    [FindController.s_cmds.save_mychess]                    = FindController.onSaveMychess;
    
    
}