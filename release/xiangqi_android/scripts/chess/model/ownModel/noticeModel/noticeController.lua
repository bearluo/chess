--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23

require(BASE_PATH.."chessController")

NoticeController = class(ChessController);

NoticeController.s_cmds = 
{
    onBack              = 1;
    del_notice_msg      = 2;
    get_notice_msg      = 3;
    isNoMoreData        = 4;
};

NoticeController.s_limit = 10;--数量

NoticeController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
    self.m_mailDataList = {};
    self.m_mailIdMap = {};
    self.m_offset = 0;
end

NoticeController.dtor = function(self)
end

NoticeController.resume = function(self)
	ChessController.resume(self);
	Log.i("NoticeController.resume");
    if #self.m_mailDataList == 0 then
        self:getNoticeMsg();
    end
end

NoticeController.pause = function(self)
	ChessController.pause(self);
	Log.i("NoticeController.pause");

end

-------------------- func ----------------------------------

NoticeController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end

NoticeController.getNoticeMsg = function(self)
    if self.mSendNoticeMsging then 
        return 
    end

    if self.mNoMoreData then
        return ;
    end

    self.mSendNoticeMsging = true;
    local tips = "请稍候...";
	local post_data = {};
    post_data.last_id = self.m_offset; --偏移位置
    post_data.num = NoticeController.s_limit; --数量
    post_data.mid = UserInfo.getInstance():getUid();
    HttpModule.getInstance():execute(HttpModule.s_cmds.UserMailGetMyMail,post_data);
end

NoticeController.delNoticeMsg = function(self,id)
    local tips = "请稍候...";
	local post_data = {};
	post_data.mail_id = id;
    HttpModule.getInstance():execute(HttpModule.s_cmds.UserMailDel,post_data,tips);
end

--NoticeController.getNoticeMsgCallBack = function(self,isSuccess,message)
--    Log.i("getNoticeMsgCallBack");
--    if not isSuccess or message.data:get_value() == nil then
--        return ;
--    end

--    local data = message.data;

--	if not data then
--		print_string("not data");
--		return
--	end

--	local list  = {}

--	-- type	消息类别	
--	-- 0 系统广播 
--	-- 1 好友邀请  
--	-- 2 支付消息 
--	-- 3 邀请消息 
--	-- 4 赠送消息
----    local cnt = 0;
--	for _,value in pairs(data) do 
----        cnt = cnt + 1;
--		local msg = {};
--		msg.type 			= value.type:get_value();
--		msg.id       		= value.id:get_value();
--		msg.mtime           = value.mtime:get_value();
--		msg.msg 			= value.msg:get_value() or "";
--		msg.button			= value.button:get_value();
--		table.insert(list,msg);
--	end
--    self:updateView(NoticeScene.s_cmds.update_notice_view,list);
----    GameCacheData.getInstance():saveInt(GameCacheData.NOTICE_NUM,cnt);
--end

NoticeController.delNoticeMsgCallBack = function(self,isSuccess,message)
    Log.i("getNoticeMsgCallBack");
    if HttpModule.explainPHPMessage(isSuccess,message,"操作失败") then return end

    local data = message.data;

	if not data then
		print_string("not data");
		return
	end
	
	local id = data.mail_id:get_value();

    self:updateView(NoticeScene.s_cmds.del_notice_view_item,id);
end

-- 拉取mail消息返回
NoticeController.getUserMailGetMyMailCallBack = function(self,isSuccess,message)
    -- 判断是否消息拉取成功
    self.mSendNoticeMsging = false;
    if HttpModule.explainPHPMessage(isSuccess,message,"消息拉取失败") then 
        return ;
    end

    local data = json.analyzeJsonNode(message.data);
    -- 判断数据是否出错
    if not data or type(data) ~= "table" then 
        ChessToastManager.getInstance():showSingle("数据拉取错误");
        return
    end
    local list = data.list;
    if not list or type(list) ~= "table" then 
        ChessToastManager.getInstance():showSingle("数据拉取错误");
        return
    end
    if #list > 0 then
        self.m_offset = list[#list].id or self.m_offset;
    end
    -- 储存数据
    for _,mail in ipairs(list) do
        local id = mail.id;
        if id and self.m_mailIdMap[id] then -- 旧数据更新
            self.m_mailDataList[self.m_mailIdMap[id]] = mail;
        elseif id then --新数据添加
            self.m_mailIdMap[id] = #self.m_mailDataList + 1;
            self.m_mailDataList[self.m_mailIdMap[id]] = mail;
        end
    end
    if self.m_mailDataList[1] then
        GameCacheData.getInstance():saveString(GameCacheData.NOTICE_MAILS_TIME,self.m_mailDataList[1].mail_time);
    end

    if self.m_mailDataList and #self.m_mailDataList == data.total then
        self.mNoMoreData = true;
    end

    -- 更新消息列表
    if #list > 0 then
        self:updateView(NoticeScene.s_cmds.update_notice_view,self.m_mailDataList);
    else
        -- 屏蔽后续触发的发送消息
        self.mNoMoreData = true;
    end
end

NoticeController.isNoMoreData = function(self)
    return self.mNoMoreData;
end

-------------------- config --------------------------------------------------
NoticeController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.UserMailGetMyMail] = NoticeController.getUserMailGetMyMailCallBack;
    [HttpModule.s_cmds.UserMailDel] = NoticeController.delNoticeMsgCallBack;
};


NoticeController.s_nativeEventFuncMap = {
};
NoticeController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	NoticeController.s_nativeEventFuncMap or {});

NoticeController.s_socketCmdFuncMap = {
};
-- 合并父类 方法
NoticeController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	NoticeController.s_httpRequestsCallBackFuncMap or {});

NoticeController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	NoticeController.s_socketCmdFuncMap or {});

------------------------------------- 命令响应函数配置 ------------------------
NoticeController.s_cmdConfig = 
{
    [NoticeController.s_cmds.onBack]                        = NoticeController.onBack;
    [NoticeController.s_cmds.del_notice_msg]                = NoticeController.delNoticeMsg;
    [NoticeController.s_cmds.get_notice_msg]                = NoticeController.getNoticeMsg;
    [NoticeController.s_cmds.isNoMoreData]                  = NoticeController.isNoMoreData;
    
}