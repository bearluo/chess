--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23

require(BASE_PATH.."chessController")

OwnCreateEndgateController = class(ChessController);

OwnCreateEndgateController.s_cmds = 
{
    onBack              = 1;
    onLoadEndgate       = 2;
};


OwnCreateEndgateController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
    self.mWulinBoothOffset = 0;
    self.mWulinBoothNoMore = false;
end

OwnCreateEndgateController.dtor = function(self)
end

OwnCreateEndgateController.resume = function(self)
	ChessController.resume(self);
end

OwnCreateEndgateController.pause = function(self)
	ChessController.pause(self);

end

-------------------- func ----------------------------------

OwnCreateEndgateController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end

function OwnCreateEndgateController.requestWulinBooth(self)
    if self.mWulinBoothSendIng or self.mWulinBoothNoMore then return end
    self.mWulinBoothSendIng = true;
    self.mWulinBoothOffset = self.mWulinBoothOffset or 0;
    local params = {};
	params.limit = 5;
    params.offset = self.mWulinBoothOffset;
    params.sort_type = 'desc';
    HttpModule.getInstance():execute(HttpModule.s_cmds.WulinBoothMyCreateBooth,params);
end

function OwnCreateEndgateController.onWulinBoothResponse(self,isSuccess,message)
    self.mWulinBoothSendIng = false;
    if not isSuccess or message.data:get_value() == nil then
        self:updateView(OwnCreateEndgateScene.s_cmds.add_endgate);
        return ;
    end
    
    local tab = json.analyzeJsonNode(message.data);
    local list = tab.list;
    if type(list) ~= "table" or #list == 0 then
        self:updateView(OwnCreateEndgateScene.s_cmds.add_endgate,{},true);
        self.mWulinBoothNoMore = true;
        return ;
    end

    self.mWulinBoothOffset = self.mWulinBoothOffset + #list;

    self:updateView(OwnCreateEndgateScene.s_cmds.add_endgate,list,false);
end

-------------------- config --------------------------------------------------
OwnCreateEndgateController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.WulinBoothMyCreateBooth]                   = OwnCreateEndgateController.onWulinBoothResponse;
    
};


OwnCreateEndgateController.s_nativeEventFuncMap = {
};
OwnCreateEndgateController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	OwnCreateEndgateController.s_nativeEventFuncMap or {});

OwnCreateEndgateController.s_socketCmdFuncMap = {
};
-- 合并父类 方法
OwnCreateEndgateController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	OwnCreateEndgateController.s_httpRequestsCallBackFuncMap or {});

OwnCreateEndgateController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	OwnCreateEndgateController.s_socketCmdFuncMap or {});

------------------------------------- 命令响应函数配置 ------------------------
OwnCreateEndgateController.s_cmdConfig = {
    [OwnCreateEndgateController.s_cmds.onBack]                          = OwnCreateEndgateController.onBack;
    [OwnCreateEndgateController.s_cmds.onLoadEndgate]                   = OwnCreateEndgateController.requestWulinBooth;
}