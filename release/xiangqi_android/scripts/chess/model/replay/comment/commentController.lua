
require("config/path_config");

require(BASE_PATH.."chessController");
CommentController = class(ChessController);

CommentController.s_cmds = 
{	
    back_action     = 1;
    comment_action  = 2;
    hot_comment     = 3;
    all_comment     = 4;
    set_like        = 5;
};

CommentController.ctor = function(self, state, viewClass, viewConfig)

end

CommentController.resume = function(self)
    ChessController.resume(self);
end;

CommentController.pause = function(self)
    ChessController.pause(self);
end;

CommentController.dtor = function(self)

end;




CommentController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end;


--------------------------------function------------------------------------

-- 发起评论
CommentController.onSendComment = function(self,manualId, msg)
    local post_data = {};
    post_data.mid = UserInfo.getInstance():getUid();
    post_data.manual_id = manualId;
    post_data.comment_text = msg;   
    self:sendHttpMsg(HttpModule.s_cmds.shareComment,post_data);
end;


CommentController.onGetHotComment = function(self, manualId)
    local post_data = {};
    post_data.mid = UserInfo.getInstance():getUid();
    post_data.manual_id = manualId
    self:sendHttpMsg(HttpModule.s_cmds.getHotComment,post_data);

end;

CommentController.onGetAllComment = function(self, manualId,offset,limit)
    local post_data = {};
    post_data.mid = UserInfo.getInstance():getUid();
    post_data.manual_id = manualId
    post_data.offset = offset; 
    post_data.limit = limit;  
    self:sendHttpMsg(HttpModule.s_cmds.getAllComment,post_data);
end;


CommentController.onSetLikeComment = function(self, comment_id, like)
    local post_data = {};
    post_data.mid = UserInfo.getInstance():getUid();
    post_data.comment_id = comment_id
    post_data.is_cancel = ((like == 1) and 0) or 1; 
    self:sendHttpMsg(HttpModule.s_cmds.setLikeComment,post_data);

end;
--------------------------------http----------------------------------------
-- 发送评论回调
CommentController.onShareCommentCallBack = function(self, flag, message)
    if not flag then
        if type(message) == "number" then
            return; 
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
            return;
        end;        
    end;
    local data = json.analyzeJsonNode(message.data);
    self:updateView(CommentScene.s_cmds.add_comment,data);    
end;

-- 获取热门评论回调
CommentController.onGetHotCommentCallBack = function(self, flag, message)
    if not flag then
        if type(message) == "number" then
            return; 
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
            return;
        end;        
    end;
    local data = json.analyzeJsonNode(message.data);
    self:updateView(CommentScene.s_cmds.get_hot_comment,data);
end;


-- 获取全部评论回调
CommentController.onGetAllCommentCallBack = function(self, flag, message)
    if not flag then
        if type(message) == "number" then
            return; 
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
            return;
        end;        
    end;
    local data = json.analyzeJsonNode(message.data);
    self:updateView(CommentScene.s_cmds.get_all_comment,data);

end;


-- 点赞或取消赞回调
CommentController.onSetLikeCommentCallBack = function(self, flag, message)
    if not flag then
        if type(message) == "number" then
            return; 
        elseif message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
            return;
        end;        
    end;
    local data = json.analyzeJsonNode(message.data);
    self:updateView(CommentScene.s_cmds.get_like_num,data);

end;

--------------------------------config--------------------------------------

CommentController.s_cmdConfig = 
{
	[CommentController.s_cmds.back_action]		                = CommentController.onBack;
    [CommentController.s_cmds.comment_action]		            = CommentController.onSendComment;
    [CommentController.s_cmds.hot_comment]		                = CommentController.onGetHotComment;
    [CommentController.s_cmds.all_comment]		                = CommentController.onGetAllComment;
    [CommentController.s_cmds.set_like]		                    = CommentController.onSetLikeComment;
}
CommentController.s_socketCmdFuncMap = {

};

CommentController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.shareComment]                            = CommentController.onShareCommentCallBack;
    [HttpModule.s_cmds.getHotComment]                           = CommentController.onGetHotCommentCallBack;
    [HttpModule.s_cmds.getAllComment]                           = CommentController.onGetAllCommentCallBack;
    [HttpModule.s_cmds.setLikeComment]                          = CommentController.onSetLikeCommentCallBack;
};

CommentController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	CommentController.s_httpRequestsCallBackFuncMap or {});

CommentController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	CommentController.s_socketCmdFuncMap or {});