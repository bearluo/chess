require(BASE_PATH.."chessScene");


FeedbackScene = class(ChessScene);
FeedbackScene.TIPS = {"很差","不满意","一般","较好","非常好"};
FeedbackScene.MAX_LEN = 144;
FeedbackScene.MAX_CONCACT_LEN = 22;
FeedbackScene.s_changeState = true;

FeedbackScene.s_controls = 
{
    back_btn                    = 1;
    title_view                  = 2;
    version_text                = 3;
    title_icon                  = 4;
    input_content_view          = 5;
    qq_group_text               = 6;
    message_edit                = 7;
    phone_edit                  = 8;
    send_btn                    = 9;
    feedback_record_placeholder = 10;
    feedback_img                = 11;
}

FeedbackScene.s_cmds = 
{
    addFeedbackLog = 1;
    mall_content_view = 2;
    mall_record_placehold = 3;
    mall_shop_placehold = 4;
    mall_prop_placehold = 5;
    mall_userinfo_name_text = 6;
    changeState = 7;
    load_feedback_img = 8;
    set_default_feedback_img = 9;
    send_score_callback = 10;
}

FeedbackScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = FeedbackScene.s_controls;
    self:create();
end 
FeedbackScene.resume = function(self)
    ChessScene.resume(self);
--    self:removeAnimProp();
--    self:resumeAnimStart();
end;


FeedbackScene.pause = function(self)
	ChessScene.pause(self);
    self:removeAnimProp();
--    self:pauseAnimStart();
end 


FeedbackScene.dtor = function(self)
    delete(self.m_anim_start);
    delete(self.m_anim_end);

end 

FeedbackScene.removeAnimProp = function(self)
    if self.m_anim_prop_need_remove then
        self.m_title_icon:removeProp(1);
        self.m_back_btn:removeProp(1);
        self.m_leaf_left:removeProp(1);
--        self.m_title_view:removeProp(1);
--        self.m_input_content_view:removeProp(1);
--        self.m_feedback_record_placeholder:removeProp(1);
        self.m_anim_prop_need_remove = false;
    end
--    self.m_top_view:removeProp(1);
--    self.m_more_btn:removeProp(1);
--    self.m_bottom_view:removeProp(1);
end

FeedbackScene.setAnimItemEnVisible = function(self,ret)
    self.m_leaf_left:setVisible(ret);
--    self.right_leaf:setVisible(ret);
end

FeedbackScene.resumeAnimStart = function(self,lastStateObj,timer)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;
    delete(self.m_anim_start);
    self.m_anim_start = new(AnimInt,kAnimNormal,0,1,delay,-1);
    if self.m_anim_start then
        self.m_anim_start:setEvent(self,function()
            self:setAnimItemEnVisible(true);
            delete(self.m_anim_start);
        end);
    end

    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, delay, -lw, 0, -10, 0);
    local tw,th = self.m_title_icon:getSize();
    local anim = self.m_title_icon:addPropTranslate(1, kAnimNormal, waitTime, delay, 0, 0, -th, 0);
    if anim then
        anim:setEvent(self,function()
            self.m_anim_prop_need_remove = true;
            self:removeAnimProp();
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end  
        end);   
    end
end

FeedbackScene.pauseAnimStart = function(self,newStateObj,timer)
    self.m_anim_prop_need_remove = true;
    self:removeAnimProp();
    local duration = timer.duration;
    local waitTime = timer.waitTime
    local delay = waitTime+duration;
    delete(self.m_anim_end);
    self.m_anim_end = new(AnimInt,kAnimNormal,0,1,delay,-1);
    if self.m_anim_end then
        self.m_anim_end:setEvent(self,function()
            self.m_anim_prop_need_remove = true;
            self:removeAnimProp();
            if not self.m_root:checkAddProp(1) then 
		        self.m_root:removeProp(1);
	        end  
            delete(self.m_anim_end)
        end);
    end

    local lw,lh = self.m_leaf_left:getSize();
    self.m_leaf_left:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, -lw, 0, -10);
    local w,h = self.m_title_icon:getSize();
    local anim = self.m_title_icon:addPropTranslate(1, kAnimNormal, waitTime, -1, 0, 0, 0, -h);
    if anim then
        anim:setEvent(self,function()
            self:setAnimItemEnVisible(false);
        end);
    end
end
----------------------------------- function ----------------------------
FeedbackScene.create = function(self)   
	self.m_root_view = self.m_root;
    self.m_back_btn = self:findViewById(self.m_ctrls.back_btn);
    self.m_leaf_left = self.m_root:getChildByName("bamboo_left");
    self.m_title_view = self:findViewById(self.m_ctrls.title_view);
    self.m_version_text = self:findViewById(self.m_ctrls.version_text);
    self.m_version_text:setText("版本号:"..kLuaVersion);
    self.m_title_icon = self:findViewById(self.m_ctrls.title_icon);
    self.m_input_content_view = self:findViewById(self.m_ctrls.input_content_view);
    self.m_qq_group_text = self:findViewById(self.m_ctrls.qq_group_text);
    self.m_qq_group_text:setText(UserInfo.getInstance():getQQGroupString() or "QQ沟通群：460628319");
    if kPlatform == kPlatformIOS then    
        -- ios 审核关闭QQ群，版本号
        if tonumber(UserInfo.getInstance():getIosAuditStatus()) ~= 0 then
            self.m_version_text:setVisible(true);
            self.m_qq_group_text:setVisible(true);
        else
            self.m_version_text:setVisible(false);
            self.m_qq_group_text:setVisible(false);
        end;
    end;
    self.m_message_edit = self:findViewById(self.m_ctrls.message_edit);
    self.m_phone_edit = self:findViewById(self.m_ctrls.phone_edit);
    self.m_message_edit:setHintText("请填写您宝贵的意见（必填）",165,145,120);
	self.m_message_edit:setOnTextChange(self,self.contentTextChange);
    self.m_phone_edit:setHintText("请留下您的联系方式",165,145,120);
    self.m_feedback_img = self:findViewById(self.m_ctrls.feedback_img);
    self.m_feedback_img:setOnClick(self, self.loadFeedBackimg);
    self.m_send_btn = self:findViewById(self.m_ctrls.send_btn);
    self.m_feedback_record_placeholder = self:findViewById(self.m_ctrls.feedback_record_placeholder);
	local mw,mh = self.m_feedback_record_placeholder:getSize();
    local w,h   = self.m_root:getSize();
    self.m_feedback_record_placeholder:setSize(mw,mh+h-System.getLayoutHeight());
	local w,h = self.m_feedback_record_placeholder:getSize();
	FeedbackScene.feedlog_width  = w - 20;
	FeedbackScene.feedlog_heigth = h - 30;

	self:initFeedBackLog()
    self:contentTextChange();-- 初始化发送按钮
end

FeedbackScene.initFeedBackLog = function(self)

	local data = {};
	data.msgtitle = "博雅中国象棋";
	data.rptitle = "欢迎来到博雅中国象棋！";

	self.m_feedback_log_list = new(ScrollView,0,15,FeedbackScene.feedlog_width,FeedbackScene.feedlog_heigth,true);
	local first = new(FeedbackLogItem,data);
	self.m_feedback_log_list:addChild(first);
	self.m_feedback_record_placeholder:addChild(self.m_feedback_log_list);
	

end

FeedbackScene.addFeedbackLog = function(self,msgtitle,rptitle,votescore,fid)

	
	local data = {};
	data.msgtitle = msgtitle;
	data.rptitle = rptitle;
    data.votescore = votescore;
    data.fid = fid;
	local item = new(FeedbackLogItem,data);
	self.m_feedback_log_list:addChild(item);
    self.m_feedback_log_list:gotoBottom();
	self.m_message_edit:setText();
	self.m_phone_edit:setText();
	print_string("FeedBack.addFeedbackLog = " .. data.msgtitle);
    self:contentTextChange();
end

----------------------------------- onClick ---------------------------------

FeedbackScene.contentTextChange = function(self)
	local content = self.m_message_edit:getText();
	if not content or string.len(content) < 3 then
		self.m_send_btn:setPickable(false);
        self.m_send_btn:setFile("common/button/dialog_btn_9.png");
        
	else
		self.m_send_btn:setPickable(true);
        self.m_send_btn:setFile("common/button/dialog_btn_2_normal.png");
	end
end

FeedbackScene.onSelectTitleChangeClick = function(self)
    if self.feedback_select_btn:isChecked() then
        self.m_content_view:setVisible(true);
        self.feedback_select_btn_icon:setFile("rule/feedback_choose.png");
    else
        self.m_content_view:setVisible(false);
        self.feedback_select_btn_icon:setFile("rule/feedback_normal.png");
    end

    if self.rule_select_btn:isChecked() then
        self.m_rule_content_view:setVisible(true);
        self.rule_select_btn_icon:setFile("rule/game_rule_choose.png");
    else
        self.m_rule_content_view:setVisible(false);
        self.rule_select_btn_icon:setFile("rule/game_rule_normal.png");
    end
end

FeedbackScene.back_action = function(self)
    self:requestCtrlCmd(FeedbackController.s_cmds.back_action);
end

FeedbackScene.send_action = function(self)
    self.m_content = self.m_message_edit:getText();

	if self.m_content and string.len(self.m_content) > FeedbackScene.MAX_LEN then
		self.m_content = string.subutf8(self.m_content,1,FeedbackScene.MAX_LEN);
	end

	self.m_concact = self.m_phone_edit:getText();

	if self.m_concact and string.len(self.m_concact) > FeedbackScene.MAX_CONCACT_LEN then
		self.m_content = string.subutf8(self.m_concact,1,FeedbackScene.MAX_CONCACT_LEN);
	end

    self:requestCtrlCmd(FeedbackController.s_cmds.send_action,self.m_content);
end

FeedbackScene.toPriPage = function(self)
    self:requestCtrlCmd(FeedbackController.s_cmds.toPriPage);
end

FeedbackScene.toSerPage = function(self)
    self:requestCtrlCmd(FeedbackController.s_cmds.toSerPage);
end

FeedbackScene.changeState = function(self,state)
    if state then
        self.feedback_select_btn:setChecked(true);
    else
        self.rule_select_btn:setChecked(true);
    end
end

-- 加载反馈图片
FeedbackScene.loadFeedBackimg = function(self)
    Log.i("FeedbackScene.uploadFeedBackimg");
    local post_data = {};
	post_data.ImageName ="feedback_image";
	post_data.Url = PhpConfig.FEEDBACK_URL;
	post_data.Api = HttpManager.getMethodData(PhpConfig.METHOD_FEEDBACK_SENDFEEDBACK_IMG,PhpConfig.METHOD_FEEDBACK_SENDFEEDBACK_IMG);
	local dataStr = json.encode(post_data);
	dict_set_string(kLoadFeedBackImage,kLoadFeedBackImage..kparmPostfix,dataStr);
	call_native(kLoadFeedBackImage);  
end

-- 加载反馈图片
FeedbackScene.onLoadFeedbackImg = function(self, imagename)
    if imagename then
        Log.i("FeedbackScene.onLoadFeedbackImg"..imagename);
        self.m_feedback_img:setFile(imagename..".png");
    end;
end;

-- 设置默认反馈img
FeedbackScene.onSetDefaultFeedbackImg = function(self)
    self.m_feedback_img:setFile("common/icon/upload_feedback.png");
end;

FeedbackScene.onSendScoreCallback = function(self,flag)
    if flag then
        ChessToastManager.getInstance():showSingle("评分成功！");
        if self.m_feedback_record_placeholder then
            self.m_feedback_record_placeholder:removeAllChildren();
        end;
        self:initFeedBackLog();
        self:requestCtrlCmd(FeedbackController.s_cmds.getFeedBack);
    else
        ChessToastManager.getInstance():showSingle("评分失败！");
    end;
end;



----------------------------------- config ------------------------------
FeedbackScene.s_controlConfig = 
{
    [FeedbackScene.s_controls.back_btn]                                     = {"back_btn"};
    [FeedbackScene.s_controls.title_view]                                   = {"title_view"};
    [FeedbackScene.s_controls.version_text]                                 = {"title_view","version_text"};
    [FeedbackScene.s_controls.title_icon]                                   = {"title_icon"};
    [FeedbackScene.s_controls.input_content_view]                           = {"input_content_view"};
    [FeedbackScene.s_controls.feedback_img]                                 = {"input_content_view","feedback_img"};
    [FeedbackScene.s_controls.qq_group_text]                                = {"input_content_view","qq_group_text"};
    [FeedbackScene.s_controls.message_edit]                                 = {"input_content_view","input_message_bg","message_edit"};
    [FeedbackScene.s_controls.phone_edit]                                   = {"input_content_view","input_phone_bg","phone_edit"};
    [FeedbackScene.s_controls.send_btn]                                     = {"input_content_view","send_btn"};
    [FeedbackScene.s_controls.feedback_record_placeholder]                  = {"feedback_record_placeholder"};
};

FeedbackScene.s_controlFuncMap =
{
    [FeedbackScene.s_controls.send_btn]                                     = FeedbackScene.send_action;
    [FeedbackScene.s_controls.back_btn]                                     = FeedbackScene.back_action;
};


FeedbackScene.s_cmdConfig =
{
    [FeedbackScene.s_cmds.addFeedbackLog]               = FeedbackScene.addFeedbackLog;
    [FeedbackScene.s_cmds.changeState]                  = FeedbackScene.changeState;
    [FeedbackScene.s_cmds.load_feedback_img]            = FeedbackScene.onLoadFeedbackImg;
    [FeedbackScene.s_cmds.set_default_feedback_img]     = FeedbackScene.onSetDefaultFeedbackImg;
    [FeedbackScene.s_cmds.send_score_callback]          = FeedbackScene.onSendScoreCallback;
}



---------------------------------- private node ---------------------------

FeedbackLogItem = class(Node);

FeedbackLogItem.ctor = function(self,data,parent)
	print_string("FeedbackLogItem.ctor = " .. data.msgtitle);
    if not data then return end;
    self.m_parent = parent;
	local left = 15;
	local place_h = 20;

    self.m_fid = data.fid;
	self.m_msgtitle = "问：" .. data.msgtitle;
	if not data.rptitle or  string.len(data.rptitle) < 3 then
        self.m_is_answer = false;
		self.m_rptitle = "[您的反馈正在处理中...]";
	else
        self.m_is_answer = true;
		self.m_rptitle = "答：" .. data.rptitle;
	end

	
	self.m_msgtitle = GameString.convert2UTF8(self.m_msgtitle);
	self.m_rptitle = GameString.convert2UTF8(self.m_rptitle);

	print_string("self.m_msgtitle = " .. self.m_msgtitle);
	print_string("self.m_rptitle = " .. self.m_rptitle);


	self.m_text_ask = new(TextView,self.m_msgtitle,FeedbackScene.feedlog_width - 20,0,kAlignLeft,nil,32,80, 80, 80);

	self.m_text_ask:setPos(left,place_h);
	local w,h = self.m_text_ask:getSize();
	h = h + place_h + 20;
	self.m_text_answer = new(TextView,self.m_rptitle,FeedbackScene.feedlog_width - 20,0,kAlignLeft,nil,32,25,115,40);
	
	self.m_text_answer:setPos(left,h);
	
	local w_answer,h_answer = self.m_text_answer:getSize();

	h = h + h_answer;

    self.m_line = new(Image,"common/decoration/line_2.png");
    self.m_line:setAlign(kAlignBottom);
    self.m_line:setSize(w);

	self:addChild(self.m_text_ask);
	self:addChild(self.m_text_answer);
	self:addChild(self.m_line);
--    data.votescore = 0;
    if tonumber(data.votescore) and tonumber(data.votescore) ~= -1 then -- -1客服没有回复，不可评分
        self.m_comment_view = new(Node);
        -- commentStar
        self.m_comment_star = new(CommentStar, 5);
        self.m_comment_star:setAlign(kAlignTopLeft);
        self.m_comment_star:setStarClickCallback(self, self.setStarTips);
        self.m_comment_star:setStar(5); -- 默认5星
        self.m_comment_view:addChild(self.m_comment_star);
        
        if tonumber(data.votescore) == 0 then
            -- commentTips
            self.m_comment_tip = new(Text,"是否满意客服的回答",nil,nil,nil,nil,28,135,100,95);
            self.m_comment_tip:setAlign(kAlignBottomLeft);
            self.m_comment_view:addChild(self.m_comment_tip);

            -- summitStar
            self.m_comment_btn = new(Button,"common/button/dialog_btn_3_normal.png");
            self.m_comment_btn:setAlign(kAlignRight);
            self.m_comment_btn:setOnClick(self,self.summitScore);
            self.m_summit_txt = new(Text,"提交",nil,nil,nil,nil,32,240,230,210);
            self.m_summit_txt:setAlign(kAlignCenter);
            self.m_comment_btn:addChild(self.m_summit_txt);
            self.m_comment_view:addChild(self.m_comment_btn);

            self.m_comment_star:setStarClickable(true);
            self.m_comment_view:setSize(w,80);
        elseif tonumber(data.votescore) > 0 then
            -- after_summit
            self.m_has_comment_txt = new(Text,"感谢您的评分",nil,nil,nil,nil,28,135,100,95);
            self.m_has_comment_txt:setAlign(kAlignRight);
            self.m_comment_view:addChild(self.m_has_comment_txt);
            self.m_comment_star:setStar(tonumber(data.votescore));
            self.m_comment_star:setStarClickable(false);
            self.m_comment_view:setSize(w,50);
        end;
        self.m_comment_view:setPos(left,h + 10);
        h = h + select(2,self.m_comment_view:getSize());
        self:addChild(self.m_comment_view);
    end;    
	self:setSize(w,h+20);
end


FeedbackLogItem.dtor = function(self)
	
end	



FeedbackLogItem.setStarTips = function(self, star)
    self.m_score = star;
--    if self.m_comment_tip then
--        self.m_comment_tip:setText(FeedbackScene.TIPS[star] or "是否满意客服的回答");
--    end;
end;



FeedbackLogItem.summitScore = function(self)
    local post_data = {};
    post_data.fid = self.m_fid;
    if not self.m_score then
        ChessToastManager.getInstance():showSingle("请您先评分吧",1000);
        return ;
    end;
    post_data.score = self.m_score;
    HttpModule.getInstance():execute(HttpModule.s_cmds.sendFeedBackScore,post_data,"请稍候...");    
end;

