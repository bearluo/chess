--region ChessShareManager.lua
--Author : HenryChen
--createDate   : 2015/9/6
--updateDate   : 2015/9/6
--

ChessShareManager = class();

ChessShareManager.getInstance = function ()
	if not ChessShareManager.s_instance then
		ChessShareManager.s_instance = new(ChessShareManager);
	end
	return ChessShareManager.s_instance;
end

ChessShareManager.releaseInstance = function()
	delete(ChessShareManager.s_instance);
	ChessShareManager.s_instance = nil;
end

ChessShareManager.ctor = function(self)
    EventDispatcher.getInstance():register(Event.Call,self,self.onNativeCallDone);
    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
end

ChessShareManager.dtor = function(self)
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeCallDone);
    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpRequestsCallBack);
end

ChessShareManager.onHttpRequestsCallBack = function(self,command,...)
	Log.i("ChessShareManager.onHttpRequestsCallBack");
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self,...);
	end 
end

ChessShareManager.onNativeCallDone = function(self ,param , ...)
	if self.s_nativeEventFuncMap[param] then
		self.s_nativeEventFuncMap[param](self,...);
	end
end

--发起分享
--manualData棋谱数据
--manualData.red_mid = "800";       --红方uid
--manualData.black_mid = "1234";    --黑发uid
--manualData.win_flag = "1";        --胜利方（1红胜，2黑胜，3平局）
--manualData.manual_type = "1";     --棋谱类型，1联网游戏，2残局，3单机游戏，4用户打谱，5自定义残局
--manualData.start_fen = "";        --棋盘开局
--manualData.move_list = "";        --走法，json字符串
--manualData.end_type = "1";        --结束类型 
--       0 => '异常',
--       1 => '正常结束',
--       2 => '和棋',
--       3 => '认输',
--       4 => '局时超时',
--       5 => '逃跑',
--       6 => '困壁',
--       7 => '用户掉线导致局时超时',
--       8 => '超过60步没有吃子'
ChessShareManager.onShare = function(self,manualData)
    self.m_manualData = manualData;
    local postData = {};
    postData.red_mid = self.m_manualData.red_mid;
    postData.black_mid = self.m_manualData.black_mid;    
    postData.win_flag = self.m_manualData.win_flag;
    postData.manual_type = self.m_manualData.manual_type;
    postData.start_fen = self.m_manualData.start_fen;
    postData.move_list = self.m_manualData.move_list;
    postData.end_type = self.m_manualData.end_type or "0";
    postData.manual_id = self.m_manualData.manual_id;
    postData.mid = self.m_manualData.mid;
    postData.h5_developUrl = self.m_manualData.h5_developUrl;
    postData.title = self.m_manualData.title or "博雅中国象棋";
    postData.description = self.m_manualData.description or ""; 
    postData.url = postData.h5_developUrl.."view/replay/replay.php?manual_id="..postData.manual_id;
    dict_set_string(kShareWebViewShare , kShareWebViewShare .. kparmPostfix,json.encode(postData));
    call_native(kShareWebViewShare);
end

--发起转发
ChessShareManager.onForward = function(self,manualData,news_pid,manual_id)--news_pid文章原始id,manual_id棋谱原始id
    
end

------------------------------native callback-----------------------------------------

ChessShareManager.onUpLoadLog = function(self, status, json_data)
    local postData = {};
    postData.mid = json_data.mid:get_value() or 0; 
    postData.manual_id = json_data.manual_id:get_value() or "";
    HttpModule.getInstance():execute(HttpModule.s_cmds.uploadLog,postData);    
end;



--分享到博雅
ChessShareManager.onShareToBoyaa = function(self,status,json_data)
--    Log.i("ChessShareManager.onShareToBoyaa");
--    if not status or not json_data then
--        Log.i("ChessShareManager.onShareToBoyaa return false");
--        return ;
--    end
--    Log.i("ChessShareManager.onShareToBoyaa");
--    local postData = {};
--    postData.mid = UserInfo.getInstance():getUid(); 
--    postData.red_mid = json_data.red_mid:get_value() or "";
--    postData.black_mid = json_data.black_mid:get_value() or "";  
--    postData.win_flag = json_data.win_flag:get_value() or "";
--    postData.manual_type = json_data.manual_type:get_value() or "";
--    postData.start_fen = json_data.start_fen:get_value() or "";
--    postData.move_list = json_data.move_list:get_value() or "";
--    postData.end_type = json_data.end_type:get_value() or "";
--    postData.news_type = "1";
--    postData.news_title = json_data.news_text:get_value() or "棋局回放";
--    postData.news_abstract = json_data.news_abstract:get_value() or "";
--    postData.news_text = "";
--    postData.news_pid = json_data.news_pid:get_value() or "";
--    postData.manual_id = json_data.manual_id:get_value() or "";
--    HttpModule.getInstance():execute(HttpModule.s_cmds.shareToBoyaa,postData);
end

-- 朋友圈
ChessShareManager.onShareToPYQ = function(self,status,json_data)
--    Log.i("ChessShareManager.onShareToPYQ");
--    if not status or not json_data then
--        Log.i("ChessShareManager.onShareToPYQ return false");
--        return ;
--    end
--    -- 分享到哪里(item的位置)
--    self.m_itemPositon = json_data.itemPosition:get_value() or 1;
--    self.m_qipuName = json_data.qipuName:get_value() or "博雅象棋分享"
--    Log.i("ChessShareManager.onShareToPYQ");
--    local postData = {};
--    postData.mid = UserInfo.getInstance():getUid(); 
--    postData.red_mid = json_data.red_mid:get_value() or "";
--    postData.black_mid = json_data.black_mid:get_value() or "";    
--    postData.win_flag = json_data.win_flag:get_value() or "";
--    postData.manual_type = json_data.manual_type:get_value() or "";
--    postData.start_fen = json_data.start_fen:get_value() or "";
--    postData.move_list = json_data.move_list:get_value() or "";
--    postData.end_type = json_data.end_type:get_value() or "";
--    postData.news_type = "1";
--    postData.news_title = json_data.news_text:get_value() or "棋局回放";
--    postData.news_abstract = "你敢接招吗？你敢接招吗？你敢接招吗？";
--    postData.news_text = "";
--    postData.news_pid = json_data.news_pid:get_value() or "";
--    postData.manual_id = json_data.manual_id:get_value() or "";
--    local needMid = json_data.needMid:get_value() or "1";
--    if needMid == "0" then
--        postData.mid = 0;
--    end
--    HttpModule.getInstance():execute(HttpModule.s_cmds.shareToPYQ,postData);
end



-- 微信
ChessShareManager.onShareToWX = function(self,status,json_data)
--    Log.i("ChessShareManager.onShareToWX");
--    if not status or not json_data then
--        Log.i("ChessShareManager.onShareToWX return false");
--        return ;
--    end
--    -- 分享到哪里(item的位置)
--    self.m_itemPositon = json_data.itemPosition:get_value() or 1;
--    self.m_qipuName = json_data.qipuName:get_value() or "博雅象棋分享"
--    Log.i("ChessShareManager.onShareToWX");
--    local postData = {};
--    postData.mid = UserInfo.getInstance():getUid(); 
--    postData.red_mid = json_data.red_mid:get_value() or "";
--    postData.black_mid = json_data.black_mid:get_value() or "";    
--    postData.win_flag = json_data.win_flag:get_value() or "";
--    postData.manual_type = json_data.manual_type:get_value() or "";
--    postData.start_fen = json_data.start_fen:get_value() or "";
--    postData.move_list = json_data.move_list:get_value() or "";
--    postData.end_type = json_data.end_type:get_value() or "";
--    postData.news_type = "1";
--    postData.news_title = json_data.news_text:get_value() or "棋局回放";
--    postData.news_abstract = "你敢接招吗？你敢接招吗？你敢接招吗？";
--    postData.news_text = "";
--    postData.news_pid = json_data.news_pid:get_value() or "";
--    postData.manual_id = json_data.manual_id:get_value() or "";
--    local needMid = json_data.needMid:get_value() or "1";
--    if needMid == "0" then
--        postData.mid = 0;
--    end
--    HttpModule.getInstance():execute(HttpModule.s_cmds.shareToWX,postData);

end

-----------------------------------------http callback---------------------------------
ChessShareManager.onShareToBoyaaCallBack = function(self,isSuccess,message)
--    if not isSuccess then 
--        Log.i("ChessShareManager.onShareToBoyaa not isSuccess");
--        call_native(kShareToBoyaaFail);
--        return ;
--    end
--    local statusCode = message.flag:get_value() or 0;
--    if statusCode == 10000 then
--        Log.i("ChessShareManager.onShareToBoyaa success");
--        call_native(kShareToBoyaaSuccess);
--    else
--        Log.i("ChessShareManager.onShareToBoyaa fail"..statusCode);
--        call_native(kShareToBoyaaFail);
--    end
end


ChessShareManager.onShareToPYQCallBack = function(self,isSuccess,message)
--    if not isSuccess then 
--        Log.i("ChessShareManager.onShareToPYQCallBack not isSuccess");
--        call_native(kResponseShareInfoFail);
--        return;
--    end
--    local statusCode = message.flag:get_value() or 0;
--    local url = message.data.share_url:get_value() or "";
--    if statusCode == 10000 then
--        local data = {};
--        data.itemPosition = self.m_itemPositon or 1;
--        data.qipuName = self.m_qipuName or "博雅棋局";
--        data.url = url;
--        dict_set_string(kResponseShareInfo , kResponseShareInfo .. kparmPostfix,json.encode(data));
--        call_native(kResponseShareInfo);        
--    else
--        Log.i("ChessShareManager.onShareToPYQCallBack fail"..statusCode);
--        call_native(kResponseShareInfoFail);
--    end
end


ChessShareManager.onShareToWXCallBack = function(self,isSuccess,message)
--    if not isSuccess then 
--        Log.i("ChessShareManager.onShareToWXCallBack fail not isSuccess");
--        call_native(kResponseShareInfoFail);
--        return;
--    end
--    local statusCode = message.flag:get_value() or 0;
--    local url = message.data.share_url:get_value() or "";
--    if statusCode == 10000 then
--        local data = {};
--        data.itemPosition = self.m_itemPositon or 2;
--        data.qipuName = self.m_qipuName or "博雅棋局";
--        data.url = url;
--        dict_set_string(kResponseShareInfo , kResponseShareInfo .. kparmPostfix,json.encode(data));
--        call_native(kResponseShareInfo);        
--    else
--        Log.i("ChessShareManager.onShareToWXCallBack fail"..statusCode);
--        call_native(kResponseShareInfoFail);
--    end
end



----------------------------------------------------------------------------------------
ChessShareManager.s_nativeEventFuncMap = {

    -- 博雅棋友
    [kShareToBoyaa]                         = ChessShareManager.onShareToBoyaa;
    -- 朋友圈
    [kShareToPYQ]                           = ChessShareManager.onShareToPYQ;
    -- 微信
    [kShareToWX]                            = ChessShareManager.onShareToWX;

    [kUpLoadLog]                            = ChessShareManager.onUpLoadLog;
};

ChessShareManager.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.shareToBoyaa]        = ChessShareManager.onShareToBoyaaCallBack;
    [HttpModule.s_cmds.shareToPYQ]          = ChessShareManager.onShareToPYQCallBack;
    [HttpModule.s_cmds.shareToWX]           = ChessShareManager.onShareToWXCallBack;
};