--ChessSociatyModuleController.lua
--Date 2016.08.18
--棋社请求接收等控制
--endregion
ChessSociatyModuleController = class();--{}

ChessSociatyModuleController.s_manager = nil;
ChessSociatyModuleController.s_httpManager = nil
ChessSociatyModuleController.s_httpRequestsCallBackFuncMap = nil

function ChessSociatyModuleController.getInstance()
    if not ChessSociatyModuleController.s_manager then 
		ChessSociatyModuleController.s_manager = new(ChessSociatyModuleController);
	end
	return ChessSociatyModuleController.s_manager;
end

function ChessSociatyModuleController.releaseInstance()
    delete(ChessSociatyModuleController.s_manager);
    ChessSociatyModuleController.s_httpManager = nil;
	ChessSociatyModuleController.s_manager = nil;
    ChessSociatyModuleController.s_httpRequestsCallBackFuncMap = nil;
end

function ChessSociatyModuleController.ctor(self)
    self:initHttpmanager()
    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
end

function ChessSociatyModuleController.dtor(self)
    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpRequestsCallBack);
end

--[Comment]
--拉取棋社推荐
--data:需要的参数
function ChessSociatyModuleController.onGetChessSociatyRecommend(self)
    local params = {};
    local ret = {};
    ret.num = 7;
    params.param = ret;
    HttpModule.getInstance():execute(HttpModule.s_cmds.getRecommendSociaty,params)
end

--[Comment]
--拉取棋社推荐回调
function ChessSociatyModuleController.onGetChessSociatyRecommendCallBack(self,isSuccess,message)
    if not isSuccess then
  		return;
    end
    if not message or type(message) ~= "table" then return end
    if not message.data then return end
    local data = {};
    data = json.analyzeJsonNode(message.data)
    EventDispatcher.getInstance():dispatch(ChessSociatyModuleView.s_event.Refresh,ChessSociatyModuleView.s_cmds.recommendCallBack,data);
end

--[Comment]
--搜索棋社
--id:棋社id
function ChessSociatyModuleController.onGetFixedChessSociaty(self,id)
    if not id or type(id) ~= "number" then return end
    local params = {};
    local ret = {};
    ret.guild_id = id;
    params.param = ret;
    HttpModule.getInstance():execute(HttpModule.s_cmds.getSociatyInfo,params)
end

--[Comment]
--搜索棋社回调
function ChessSociatyModuleController.onGetFixedChessSociatyCallBack(self,isSuccess,message)
    if not isSuccess or not message or type(message) ~= "table" then
        local tips = "棋社不存在，请输入正确的棋社ID";
        ChessToastManager.getInstance():show(tips);
  		return;
    end
    local data = {}
    if message and message.data then
        data = json.analyzeJsonNode(message.data)
    end
    SociatyModuleData.getInstance():setSociatyData(data)
    EventDispatcher.getInstance():dispatch(ChessSociatyModuleView.s_event.Refresh,ChessSociatyModuleView.s_cmds.searchCallBack,data);
end

--[Comment]
--创建棋社
--data:包括棋社id，加入理由str
function ChessSociatyModuleController.onCreateSociaty(self,data)
    if not data or type(data) ~= "table" then
        local tips = "棋社创建失败";
        ChessToastManager.getInstance():show(tips);
  		return;
    end
    local params = {};
    local ret = {};
    ret.name = data.name;
    ret.join_type = data.join_type;
    ret.mark = data.mark;
    ret.notice = data.notice;
    params.param = ret;
    HttpModule.getInstance():execute(HttpModule.s_cmds.createSociaty,params)
end

--[Comment]
--创建棋社回调
function ChessSociatyModuleController.onCreateSociatyCallBack(self,isSuccess,message)
    local defLog = "棋社创建失败，请稍后在试";
    local temp = {}
    if not isSuccess then
        temp.isSuccess = false
        if type(message) == 'table' then
            if message.flag and tonumber(message.flag:get_value()) == 10 then
                ChessToastManager.getInstance():showSingle(message.error:get_value());
                EventDispatcher.getInstance():dispatch(ChessSociatyModuleView.s_event.Refresh,ChessSociatyModuleView.s_cmds.createSociatyCallBack,temp);
                return 
            end
            if message.error then
                ChessToastManager.getInstance():showSingle(message.error:get_value() or defLog);
            else
                ChessToastManager.getInstance():showSingle(defLog);
            end
        end
        return 
    end
    local new_sociaty_data = {}
    local data = message.data
    if data then
        local ret = {}
        ret = json.analyzeJsonNode(data); 
        SociatyModuleData.getInstance():setSociatyData(ret)

        local tab = {}
        tab.guild_id = ret.id
        tab.guild_role = 1
        tab.guild_name = ret.name
        UserInfo.getInstance():setUserSociatyData2(tab)      
    end
    temp.isSuccess = true
    EventDispatcher.getInstance():dispatch(ChessSociatyModuleView.s_event.Refresh,ChessSociatyModuleView.s_cmds.createSociatyCallBack,data);
end

--[Comment]
--申请加入棋社
--data:包括棋社id，加入理由str
function ChessSociatyModuleController.onApplyJoinChessSociaty(self,data)
    if not tonumber(data.id) then 
        ChessToastManager.getInstance():showSingle("棋社不存在")
        return 
    end
    local params = {};
    local ret = {};
    ret.guild_id = tonumber(data.id);
    params.param = ret;
    HttpModule.getInstance():execute(HttpModule.s_cmds.applyJoinSociaty,params)
end

--[Comment]
--申请加入棋社回调
function ChessSociatyModuleController.onApplyJoinChessSociatyCallBack(self,isSuccess,message)
    if not message or type(message) ~= "table" then return end
    if not isSuccess  then
        local msg = message.error:get_value() or "申请失败，请稍后再试"
        if msg == "" then 
            msg = "申请失败，请稍后再试" 
        end
        ChessToastManager.getInstance():showSingle(msg,2500)
        return
    end
    local data = {}
    if message then
        data = json.analyzeJsonNode(message.data)
    end
--    if data.status and data.status == 1 then
--        EventDispatcher.getInstance():dispatch(ChessSociatyModuleView.s_event.Refresh,ChessSociatyModuleView.s_cmds.applyJoinSociatyCallBack,isSuccess);
--    end
    ChessToastManager.getInstance():showSingle(data.msg or "申请已发送");
end

--[Comment]
--获得棋社成员信息
function ChessSociatyModuleController.onGetSociatyMemberInfo(self,data)
    if not data or type(data) ~= "table" then return end
    local params = {};
    params.param = data;
    HttpModule.getInstance():execute(HttpModule.s_cmds.getSociatyMemberInfo,params)
end

--[Comment]
--获得棋社成员信息回调
function ChessSociatyModuleController.onGetSociatyMemberInfoCallBack(self,isSuccess,message)
    if not isSuccess or not message or type(message) ~= "table" then
        ChessToastManager.getInstance():showSingle("获得棋社成员失败")
        return
    end
    local data = message.data;
	if not data then
		print_string("not data");
		return
	end
    local info = {};
    info = json.analyzeJsonNode(message.data)
    SociatyModuleData.getInstance():updataSociatyMemberData(info)
--    EventDispatcher.getInstance():dispatch(ChessSociatyModuleView.s_event.Refresh,ChessSociatyModuleView.s_cmds.getSociatymemberInfoCallBack,data);
end

------------------------- 社团内成员相关 ----------------------------
--[Comment]
--退出棋社
--data:
function ChessSociatyModuleController.onQuitSociaty(self,id)
    if not id then return end
    local tab = {}
    tab.guild_id = id
    local data = {}
    data.param = tab
    HttpModule.getInstance():execute(HttpModule.s_cmds.quitSociaty,data)
end

--[Comment]
--退出棋社回调
function ChessSociatyModuleController.onQuitSociatyCallBack(self,isSuccess,message)
    if not isSuccess then
        if not message or type(message) ~= "table" then return end
        local msg = message.error:get_value() or "退出棋社失败"
        ChessToastManager.getInstance():showSingle(msg);
        return
    end
end

--[Comment]
--管理棋社
function ChessSociatyModuleController.onManagerSociaty(self,data)
    if not data or type(data) ~= "table" then return end
    local tab = {}
    tab.param = data
    HttpModule.getInstance():execute(HttpModule.s_cmds.managerSociaty,tab)
end

--[Comment]
--管理棋社回调
function ChessSociatyModuleController.onManagerSociatyCallBack(self,isSuccess,message)
    if not isSuccess then 
        if not message or type(message) ~= "table" then return end
        local msg = message.error
        if msg then
            msg = msg:get_value()
        end
        ChessToastManager.getInstance():showSingle(msg or "操作失败")
        return
    else
        local data = message.data
        if not data then return end
        local info = json.analyzeJsonNode(data)
        local op = info.op
        local target_id = info.target_mid or 0
        if op == ChesssociatyModuleConstant.s_manager_active["OP_TO_GM"] then
            ChessToastManager.getInstance():showSingle(msg or "转让成功")
            local data = {}
            data.guild_role = 2
            UserInfo.getInstance():setUserSociatyData2(data)
            SociatyModuleData.getInstance():clearSociatyMemberData()
            local ret = {};
            ret.guild_id = info.guild_id or 0;
            ret.limit = 10;
            ret.offset = 0;
            self:onGetSociatyMemberInfo()
        elseif op == ChesssociatyModuleConstant.s_manager_active["OP_ADD_VP"] then
            ChessToastManager.getInstance():showSingle(msg or "操作成功")
            FriendsData.getInstance():sendCheckUserData(target_id)
        elseif op == ChesssociatyModuleConstant.s_manager_active["OP_DEL_VP"] then
            ChessToastManager.getInstance():showSingle(msg or "操作成功")
            FriendsData.getInstance():sendCheckUserData(target_id)
        end
    end
end

--[Comment]
--修改棋社信息
function ChessSociatyModuleController.onModifySociatyInfo(self,data)
    if not data  then return end
    local tab = {}
    tab.param = data
    HttpModule.getInstance():execute(HttpModule.s_cmds.modifySociatyInfo,tab)
end

--[Comment]
--修改棋社信息
function ChessSociatyModuleController.onModifySociatyInfoCallBack(self,isSuccess,message)
    if not isSuccess or not message or type(message) ~= "table" then
        ChessToastManager.getInstance():showSingle("棋社信息修改失败")
        return
    end
    if message.flag:get_value() and tonumber(message.flag:get_value()) == 10000 then
        local data = message.data
        if not data then return end
        local info = json.analyzeJsonNode(data)
--        local my_sociaty_data = UserInfo.getInstance():getUserSociatyData()
--        SociatyModuleData.getInstance():onCheckSociatyData(my_sociaty_data.guild_id)
        SociatyModuleData.getInstance():onModifySociatyData(info)
--        EventDispatcher.getInstance():dispatch(ChessSociatyModuleView.s_event.Refresh,ChessSociatyModuleView.s_cmds.modifySociatyInfoCallBack,info);
        return
    end
    ChessToastManager.getInstance():showSingle("棋社信息修改失败")
end

--[Comment]
--棋社禁言
function ChessSociatyModuleController.onForbidUserChat(self,data,callback)
    if not data  then return end
--    local tab = {}
--    tab.param = data
    self.mForbidUserChatCallBack = callback
    HttpModule.getInstance():execute(HttpModule.s_cmds.guildExpose,data)
end

--[Comment]
--棋社解除禁言
function ChessSociatyModuleController.onUnforbidUserChat(self,data,callback)
    if not data  then return end
--    local tab = {}
--    tab.param = data
    self.mUnforbidUserChatCallBack = callback
    HttpModule.getInstance():execute(HttpModule.s_cmds.GuildDelGuildExpose,data)
end
--[Comment]
--棋社禁言回调
function ChessSociatyModuleController.onForbidUserChatCallBack(self,isSuccess,message)
    local func = self.mForbidUserChatCallBack
    self.mForbidUserChatCallBack = nil
    if not isSuccess or not message or type(message) ~= "table" then
        ChessToastManager.getInstance():showSingle("禁言失败")
        return
    end
    if type(func) == "function" then
        pcall(func)
    end
    ChessToastManager.getInstance():showSingle("禁言成功")
end
--[Comment]
--解除棋社禁言回调
function ChessSociatyModuleController.onUnforbidUserChatCallBack(self,isSuccess,message)
    local func = self.mUnforbidUserChatCallBack
    self.mUnforbidUserChatCallBack = nil
    if not isSuccess or not message or type(message) ~= "table" then
        ChessToastManager.getInstance():showSingle("解除禁言失败")
        return
    end
    if type(func) == "function" then
        pcall(func)
    end

    ChessToastManager.getInstance():showSingle("解除禁言成功")
end
--[Comment]
-- 修改棋社名称
function ChessSociatyModuleController.modifyGuildName(self,guild_id,guild_name,callback)
    if not guild_id or not  guild_name then return end
    local params = {}
    params.guild_id = guild_id
    params.guild_name = guild_name
    HttpModule.getInstance():execute(HttpModule.s_cmds.GuildModifyGuildName,params)
end


--[Comment]
--修改棋社名称
function ChessSociatyModuleController.onModifyGuildNameCallBack(self,isSuccess,message)
    if HttpModule.explainPHPMessage(isSuccess,message,"棋社名称修改失败") then return end
    local data = message.data
    if not data then return end
    local info = json.analyzeJsonNode(data)
    local params = {}
    params.name = info.guild_name
    SociatyModuleData.getInstance():onModifySociatyData(params)
--    if info.modify_money then
--        local bccoins = info.modify_money
--        bccoins = UserInfo.getInstance():getBccoin() - bccoins
--        UserInfo.getInstance():setBccoin(bccoins)
--    end
end


------------------- [END] ----------------------------------

--[Comment]
function ChessSociatyModuleController.onHttpRequestsCallBack(self,command,...)
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self,...);
	end 
end

--Test
--暂时没想好
function ChessSociatyModuleController.initHttpmanager(self)

    ChessSociatyModuleController.s_httpRequestsCallBackFuncMap  = {
        [HttpModule.s_cmds.getSociatyInfo]             = ChessSociatyModuleController.onGetFixedChessSociatyCallBack;
        [HttpModule.s_cmds.getRecommendSociaty]        = ChessSociatyModuleController.onGetChessSociatyRecommendCallBack;
        [HttpModule.s_cmds.createSociaty]              = ChessSociatyModuleController.onCreateSociatyCallBack;
        [HttpModule.s_cmds.applyJoinSociaty]           = ChessSociatyModuleController.onApplyJoinChessSociatyCallBack;
        [HttpModule.s_cmds.managerSociaty]             = ChessSociatyModuleController.onManagerSociatyCallBack;
        [HttpModule.s_cmds.modifySociatyInfo]          = ChessSociatyModuleController.onModifySociatyInfoCallBack;
        [HttpModule.s_cmds.quitSociaty]                = ChessSociatyModuleController.onQuitSociatyCallBack;
        [HttpModule.s_cmds.getSociatyMemberInfo]       = ChessSociatyModuleController.onGetSociatyMemberInfoCallBack;
        [HttpModule.s_cmds.guildExpose]                = ChessSociatyModuleController.onForbidUserChatCallBack;
        [HttpModule.s_cmds.GuildDelGuildExpose]        = ChessSociatyModuleController.onUnforbidUserChatCallBack;
        [HttpModule.s_cmds.GuildModifyGuildName]       = ChessSociatyModuleController.onModifyGuildNameCallBack;
    };

end