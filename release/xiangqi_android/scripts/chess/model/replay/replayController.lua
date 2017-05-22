
require("config/path_config");

require(BASE_PATH.."chessController");
ReplayController = class(ChessController);

ReplayController.s_cmds = 
{	
    back_action         = 1;
    save_mychess        = 2;
    get_mysavechess     = 3;
    open_self_chess     = 4;
    delete_mysave_chess = 5;
    get_suggestchess    = 6;
};

ReplayController.ctor = function(self, state, viewClass, viewConfig)

end

ReplayController.resume = function(self)
    ChessController.resume(self);
end;

ReplayController.pause = function(self)
    ChessController.pause(self);
end;

ReplayController.dtor = function(self)

end;



--------------------------------function------------------------------------
ReplayController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end;


-- isSelf,是否个人收藏
ReplayController.onSaveMychess = function(self,isSelf, chessData)
    local post_data = {};
    post_data.mid = UserInfo.getInstance():getUid();
    post_data.down_user = chessData.down_user;
    post_data.red_mid = chessData.red_mid;
    post_data.black_mid = chessData.black_mid;
    post_data.red_mnick = chessData.red_mnick;
    post_data.black_mnick = chessData.black_mnick;
    post_data.win_flag = chessData.win_flag;
    post_data.end_type = chessData.end_type;
    post_data.manual_type = chessData.manual_type;
    post_data.start_fen = chessData.start_fen;
    post_data.move_list = chessData.move_list;
    post_data.end_fen = chessData.end_fen;
    post_data.collect_type = (isSelf and 2) or 1; -- 收藏类型, 1公共收藏，2人个收藏 
    post_data.is_old = chessData.is_old or 0;
    self:sendHttpMsg(HttpModule.s_cmds.saveMychess,post_data);
end;


-- 获得我的收藏
ReplayController.onGetMySaveChess = function(self,startIndex,num,ret)
    self.isClick = ret;
    local post_data = {};
    post_data.mid = UserInfo.getInstance():getUid();
    post_data.offset = startIndex;
    post_data.limit = num;
    self:sendHttpMsg(HttpModule.s_cmds.getMychess,post_data);
end;


-- 获得棋友动态
ReplayController.onGetSuggestChess = function(self,startIndex,num,ret)
    self.isClick = ret;
    local post_data = {};
    post_data.mid = UserInfo.getInstance():getUid();
    post_data.offset = startIndex;
    post_data.limit = num;
    self:sendHttpMsg(HttpModule.s_cmds.getCircleDynamics,post_data);
end;

-- 公开或私密棋谱
ReplayController.onOpenOrSelfSaveChess = function(self, manualId, collectType)
    local post_data = {};
    post_data.mid = UserInfo.getInstance():getUid();
    post_data.manual_id = manualId;
    post_data.collect_type = collectType;
    self:sendHttpMsg(HttpModule.s_cmds.openOrSelfChess,post_data);   
end;

-- 删除我的收藏
ReplayController.onDelMySaveChess = function(self, manualId)
     local post_data = {};
    post_data.mid = UserInfo.getInstance():getUid();
    post_data.manual_id = manualId;
    self:sendHttpMsg(HttpModule.s_cmds.delMySaveChess,post_data);     
end;
---- 私密棋谱
--ReplayController.onSelfMySaveChess = function(self)


--end;
--------------------------------http----------------------------------------
-- 收藏到我的收藏回调
ReplayController.onSaveChessCallBack = function(self, flag, message)
    if not flag then
        if type(message) == "number" then
            return; 
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
            return;
        end;        
    end;
    local data = json.analyzeJsonNode(message.data);
    self:updateView(ReplayScene.s_cmds.save_mychess,data);
end;

-- 获取我的收藏回调
ReplayController.onGetMyChessCallBack = function(self, flag, message)
    if not flag then
        self:updateView(ReplayScene.s_cmds.get_mychess,nil); 
        if type(message) == "number" then
            return; 
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
            return;
        end;    
    end;
    local data = json.analyzeJsonNode(message.data);
    data.isClick = self.isClick;
    self:updateView(ReplayScene.s_cmds.get_mychess,data);
end;


-- 获取棋友推荐回调
ReplayController.onGetSuggestCallBack = function(self, flag, message)
    if not flag then
        self:updateView(ReplayScene.s_cmds.get_suggestchess,nil); 
        if type(message) == "number" then
            return; 
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
            return;
        end;   
            
    end;
    local data = json.analyzeJsonNode(message.data);
    data.isClick = self.isClick;
    self:updateView(ReplayScene.s_cmds.get_suggestchess,data);
end;


-- 公开或私密棋谱回调
ReplayController.onOpenOrSelfMyChessCallBack = function(self, flag, message)
    if not flag then
        if type(message) == "number" then
            return; 
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
            return;
        end;        
    end;
    local data = json.analyzeJsonNode(message.data);
    self:updateView(ReplayScene.s_cmds.open_self_chess,data); 
end;


-- 删除我的收藏
ReplayController.onDelMyChessCallBack = function(self,flag,message)
    if not flag then
        if type(message) == "number" then
            return; 
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
            return;
        end;        
    end;
    self:updateView(ReplayScene.s_cmds.del_mysave_chess); 
end;
--------------------------------config--------------------------------------

ReplayController.s_cmdConfig = 
{
	[ReplayController.s_cmds.back_action]		            = ReplayController.onBack;
    [ReplayController.s_cmds.save_mychess]		            = ReplayController.onSaveMychess;
    [ReplayController.s_cmds.get_mysavechess]		        = ReplayController.onGetMySaveChess;
    [ReplayController.s_cmds.get_suggestchess]		        = ReplayController.onGetSuggestChess;
    [ReplayController.s_cmds.open_self_chess]	            = ReplayController.onOpenOrSelfSaveChess;
    [ReplayController.s_cmds.delete_mysave_chess]	        = ReplayController.onDelMySaveChess;
}
ReplayController.s_socketCmdFuncMap = {

};

ReplayController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.saveMychess]                         = ReplayController.onSaveChessCallBack;
    [HttpModule.s_cmds.getMychess]                          = ReplayController.onGetMyChessCallBack;
    [HttpModule.s_cmds.getCircleDynamics]                   = ReplayController.onGetSuggestCallBack;
    [HttpModule.s_cmds.openOrSelfChess]                     = ReplayController.onOpenOrSelfMyChessCallBack;
    [HttpModule.s_cmds.delMySaveChess]                      = ReplayController.onDelMyChessCallBack;
};

ReplayController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	ReplayController.s_httpRequestsCallBackFuncMap or {});

ReplayController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	ReplayController.s_socketCmdFuncMap or {});