--UnionModuleController.lua
--Date 2016.9.3
--同城模块
--endregion

UnionModuleController = class();--{}

UnionModuleController.s_manager = nil;
UnionModuleController.s_httpRequestsCallBackFuncMap = nil

function UnionModuleController.getInstance()
    if not UnionModuleController.s_manager then 
		UnionModuleController.s_manager = new(UnionModuleController);
	end
	return UnionModuleController.s_manager;
end

function UnionModuleController.releaseInstance()
    delete(UnionModuleController.s_manager);
	UnionModuleController.s_manager = nil;
    UnionModuleController.s_httpRequestsCallBackFuncMap = nil;
end

function UnionModuleController.ctor(self)
    self:initHttpmanager()
    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
end

function UnionModuleController.dtor(self)
    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpRequestsCallBack);
end

--[Comment]
--获得同城推荐
function UnionModuleController.onGetUnionRecommend(self)
    local post_data = {};
    post_data.method =  "Friends.getSameCityRecommend";
    post_data.mid = UserInfo.getInstance():getUid();
    post_data.recommend_num = 3;
    post_data.access_token = "chess";
    HttpModule.getInstance():execute(HttpModule.s_cmds.getSameCityRecommend,post_data);
end

function UnionModuleController.onGetUnionRecommendResponse(self,isSuccess,message)
    if not isSuccess then return end

    local data = message.data;
	if not data then
		print_string("not data");
		return
	end

    local unionData = json.analyzeJsonNode(data);
    EventDispatcher.getInstance():dispatch(UnionModuleView.s_event.UpdateView,UnionModuleView.s_cmds.recommendCallBack,unionData);
end

--[Comment]
--获得同城推荐
function UnionModuleController.onGetAllUnionMember(self)
    local post_data = {};
    post_data.method =  "Friends.getSameCityMember";
    post_data.mid = UserInfo.getInstance():getUid();
    post_data.offset = 0;
    post_data.limit = 50;
    HttpModule.getInstance():execute(HttpModule.s_cmds.getSameCityMember,post_data);
end

function UnionModuleController:onGetUnionMemberResponse(isSuccess,message)
    if not isSuccess then return end

    local data = message.data;
	if not data then
		print_string("not data");
		return
	end

    local memberData = json.analyzeJsonNode(data);
    EventDispatcher.getInstance():dispatch(UnionModuleView.s_event.UpdateView,UnionModuleView.s_cmds.unionMemberCallBack,data);
end

--[Comment]
function UnionModuleController.onHttpRequestsCallBack(self,command,...)
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self,...);
	end 
end

--Test
--暂时没想好
function UnionModuleController.initHttpmanager(self)

    UnionModuleController.s_httpRequestsCallBackFuncMap  = {
        [HttpModule.s_cmds.getSameCityRecommend]        = UnionModuleController.onGetUnionRecommendResponse;
        [HttpModule.s_cmds.getSameCityMember]           = UnionModuleController.onGetUnionMemberResponse;   
    };

end