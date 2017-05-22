require("config/path_config");

require(BASE_PATH.."chessController");

FeedbackController = class(ChessController);
FeedbackController.s_cmds = 
{	
    back_action = 1;
    send_action = 2;
    toPriPage = 3;
    toSerPage = 4;
    getFeedBack = 5;
};

FeedbackController.ctor = function(self, state, viewClass, viewConfig)
	self.m_state = state;
end


FeedbackController.resume = function(self)
	ChessController.resume(self);
	Log.i("FeedbackController.resume");
    self:getFeedBack();
end


FeedbackController.pause = function(self)
	ChessController.pause(self);
	Log.i("FeedbackController.pause");
end

FeedbackController.dtor = function(self)

end

-------------------------------- father func -----------------------


-------------------------------- function --------------------------

FeedbackController.onBack = function(self)
    StateMachine.getInstance():popState(StateMachine.STYPE_CUSTOM_WAIT);
end
-- 反馈升级（上传截图）
FeedbackController.send_action = function(self,content,concact)
    if not content or content == "" then
		print_string("nothing modify");
		local message = "请填写您的意见！";
        ChessToastManager.getInstance():show(message);
		return;
	else
--    'appid' => '平台id', 
--       'game' => '游戏名拼音简称' ,//例如：tx（德州扑克），dn（斗牛），mj2（二人麻将） 
--       'mid'=>'用户id',
--       'username'=>'用户名',
--       'deviceno' => '机器码等客户端标识，用于未登录下提交反馈',
--       'title' => '问题标题', 
--       'ftype' => '1'//默认传1 initfeedback接口返回的类型之一, 
--       'fwords' => '问题内容', 
--       'fcontact' => '备注信息,包括客户端版本号，手机型号，网络环境之类的信息' 
--       'vip' => '0', //用户身份标识 0标识普通用户，1标识付费用户，2标识vip用户, 3标识即是付费用户又vip用户，88标识高级客户
--       'isHall' => 1 //如果是博雅大厅项目，则该字段传1
        local post_data = {};
        post_data.appid = PhpConfig.APPID_FEEDBACK;
        post_data.game = PhpConfig.GAME;
        post_data.ftype = PhpConfig.FTYPE;
        -- post_data.title = PhpInfo.TITLE;  --标题，要改成版本号
        self.m_content = content;
        post_data.fwords = GameString.convert2UTF8(content);
        post_data.fcontact = GameString.convert2UTF8((concact or "no concact!") .. PhpConfig.getFeedBackOSInfo());
        
        HttpModule.getInstance():execute(HttpModule.s_cmds.sendFeedback,post_data,"请稍等...");

	end
end

FeedbackController.toPriPage = function(self)
	local url = "http://www.boyaa.com/mobile/PrivacyPolicy1.html";
	to_web_page(url);
end

FeedbackController.toSerPage = function(self)
	local url = "http://www.boyaa.com/mobile/termsofservice1.html";
	to_web_page(url);
end

FeedbackController.getFeedBack = function(self)
	print_string("FeedBack.getFeedBack in");
	local post_data = {};
	post_data.appid = PhpConfig.APPID_FEEDBACK;
	post_data.game = PhpConfig.GAME;
    HttpModule.getInstance():execute(HttpModule.s_cmds.getFeedBack,post_data);
end

FeedbackController.explainGetResult = function(self,data)

	local ret = data.ret;
	if not ret then 
		print_string("not ret");
		return
	end
	for _,t in pairs(ret) do 
		local msgtitle = t.msgtitle:get_value();
		local rptitle = t.rptitle:get_value();
        local votescore = t.votescore:get_value();
        local fid = t.id:get_value();
        self:updateView(FeedbackScene.s_cmds.addFeedbackLog,msgtitle,rptitle,votescore,fid);
	end
end

FeedbackController.explainSendResult = function(self,data)
	local ret = data.ret;
	if not ret then 
		print_string("not ret");
		return
	end

	local fid = ret.fid:get_value();

	local message = "您的反馈失败 ！";
    if kPlatform == kPlatformIOS then	
	    if fid ~= 0 then
            self:updateView(FeedbackScene.s_cmds.addFeedbackLog,self.m_content or "");
            -- 反馈成功，图片上传走Android
            if self.m_isSendFeedClipImg then
                Log.i("FeedbackController.SendFeedBackImg");
                local post_data = {};
	            post_data.ImageName ="feedback_image";
	            post_data.Url = PhpConfig.FEEDBACK_URL;
                    local param = {};
                    param.fid = fid;
                    param.appid = PhpConfig.APPID_FEEDBACK;
                    param.game = PhpConfig.GAME;
	            post_data.Api = HttpManager.getMethodData(param,PhpConfig.METHOD_FEEDBACK_SENDFEEDBACK_IMG);

	            local dataStr = json.encode(post_data);
	            dict_set_string(kUpLoadFeedBackImage,kUpLoadFeedBackImage..kparmPostfix,dataStr);          
                call_native(kUpLoadFeedBackImage);
            end;   
            message = "您的反馈成功！";
            ChessToastManager.getInstance():show(message);
            self.m_isSendFeedClipImg = false;
            self:updateView(FeedbackScene.s_cmds.set_default_feedback_img);
            return fid;     
	    end
    else
	    if fid ~= 0 then
            self:updateView(FeedbackScene.s_cmds.addFeedbackLog,self.m_content or "");
            -- 反馈成功，图片上传走Android
            if self.m_isSendFeedClipImg then
                Log.i("FeedbackController.SendFeedBackImg");
                local post_data = {};
	            post_data.ImageName ="feedback_image";
	            post_data.Url = PhpConfig.FEEDBACK_URL;
                    local param = {};
                    param.fid = fid;
                    param.appid = PhpConfig.APPID_FEEDBACK;
                    param.game = PhpConfig.GAME;
	            post_data.Api = HttpManager.getMethodData(param,PhpConfig.METHOD_FEEDBACK_SENDFEEDBACK_IMG);

	            local dataStr = json.encode(post_data);
	            dict_set_string(kUpLoadFeedBackImage,kUpLoadFeedBackImage..kparmPostfix,dataStr);          
                call_native(kUpLoadFeedBackImage);
                return fid;
            else
                message = "您的反馈成功！";
                ChessToastManager.getInstance():show(message);
                return fid;
            end;        
	    end
    end;
    ChessToastManager.getInstance():show(message);
	return fid;
end


-------------------------------- http event ------------------------

FeedbackController.sendFeedbackCallBack = function(self,isSuccess,message)
    Log.i("sendFeedbackCallBack");
    if not isSuccess then
        ChessToastManager.getInstance():show("发送失败！");
        return ;
    end
    self:explainSendResult(message);
end

FeedbackController.getFeedBackCallBack = function(self,isSuccess,message)
    Log.i("getFeedBackCallBack");
    if not isSuccess then
        ChessToastManager.getInstance():show("获取失败！");
        return ;
    end
    self:explainGetResult(message);
end

FeedbackController.sendScoreCallBack = function(self, isSuccess,message)
    if not isSuccess then
        self:updateView(FeedbackScene.s_cmds.send_score_callback,false);
        return ;
    end
    self:updateView(FeedbackScene.s_cmds.send_score_callback,true);
end;

FeedbackController.onLoadFeedBackImage= function(self, flag, data)
    if not flag then return end;
    if data and data.imageName then
        -- 是否切图成功
        self.m_isSendFeedClipImg = true;
        self:updateView(FeedbackScene.s_cmds.load_feedback_img, data.imageName:get_value());
    end;
end;


FeedbackController.onUpLoadFeedBackImage= function(self, flag, data)
    if not flag then return end;
    if kPlatform == kPlatformIOS then    
        -- Log.i("FeedbackController.onUpLoadFeedBackImage-->"..json.encode(data));
        -- if data then
        --     -- 上传成功后，恢复默认
        --     self.m_isSendFeedClipImg = false;
        --     self:updateView(FeedbackScene.s_cmds.set_default_feedback_img);
        --     message = "您的反馈成功！";
        --     ChessToastManager.getInstance():show(message);
        -- end;
    else
        Log.i("FeedbackController.onUpLoadFeedBackImage-->"..json.encode(data));
        if data and data.imageName then
            -- 上传成功后，恢复默认
            self.m_isSendFeedClipImg = false;
            self:updateView(FeedbackScene.s_cmds.set_default_feedback_img);
            message = "您的反馈成功！";
            ChessToastManager.getInstance():show(message);
        end;
    end;
end; 

-------------------------------- config ----------------------------

FeedbackController.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.sendFeedback] = FeedbackController.sendFeedbackCallBack;
    [HttpModule.s_cmds.getFeedBack] = FeedbackController.getFeedBackCallBack;
    [HttpModule.s_cmds.sendFeedBackScore] = FeedbackController.sendScoreCallBack;
};

FeedbackController.s_httpRequestsCallBackFuncMap = CombineTables(ChessController.s_httpRequestsCallBackFuncMap,
	FeedbackController.s_httpRequestsCallBackFuncMap or {});


--本地事件 包括lua dispatch call事件
FeedbackController.s_nativeEventFuncMap = {
    [kLoadFeedBackImage]                 = FeedbackController.onLoadFeedBackImage;
    [kUpLoadFeedBackImage]               = FeedbackController.onUpLoadFeedBackImage;
};


FeedbackController.s_nativeEventFuncMap = CombineTables(ChessController.s_nativeEventFuncMap,
	FeedbackController.s_nativeEventFuncMap or {});



FeedbackController.s_socketCmdFuncMap = {
}

FeedbackController.s_socketCmdFuncMap = CombineTables(ChessController.s_socketCmdFuncMap,
	FeedbackController.s_socketCmdFuncMap or {});


------------------------------------- 命令响应函数配置 ------------------------
FeedbackController.s_cmdConfig = 
{
    [FeedbackController.s_cmds.back_action] = FeedbackController.onBack;
    [FeedbackController.s_cmds.send_action] = FeedbackController.send_action;
    [FeedbackController.s_cmds.toPriPage] = FeedbackController.toPriPage;
    [FeedbackController.s_cmds.toSerPage] = FeedbackController.toSerPage;
    [FeedbackController.s_cmds.getFeedBack] = FeedbackController.getFeedBack;
}