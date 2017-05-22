--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/3/18
--此文件由[BabeLua]插件自动生成
require(VIEW_PATH .. "notice_manager_dialog_xml");
require(BASE_PATH.."chessDialogScene");

NoticeManagerDialog = class(ChessDialogScene,false);

NoticeManagerDialog.ctor = function(self)
    super(self,notice_manager_dialog_xml);
	self.m_root_view = self.m_root;
    self.m_bg_view = self.m_root_view:getChildByName("bg_view");

    self.m_close = self.m_bg_view:getChildByName("confirm_btn")
    self.m_close:setOnClick(self,self.dismiss);
    
    self.m_content_view = self.m_bg_view:getChildByName("content_view");
    self.m_content_view.m_autoPositionChildren = true;
    self.m_content_text = self.m_bg_view:getChildByName("text");
end

NoticeManagerDialog.dtor = function(self)
    self:dismiss();
end

NoticeManagerDialog.onHttpRequestsCallBack = function(self,command,...)
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self,...);
	end 
end


NoticeManagerDialog.show = function(self)
    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
    EventDispatcher.getInstance():register(Event.Call,self,self.EventRespone);
    self:getNoticeMsg();
    self.m_content_text:setVisible(false);
    self:setVisible(true);
    self.super.show(self);
end

NoticeManagerDialog.getNoticeMsg = function(self)
    local tips = "请稍候...";
	local post_data = {};
	post_data.method = method;
    HttpModule.getInstance():execute(HttpModule.s_cmds.getNoticeMsg,post_data,tips);
end

NoticeManagerDialog.delNoticeMsg = function(self,ids)
    local tips = "请稍候...";
	local post_data = {};
	post_data.method = method;
	ids = table.concat(ids,",");
	post_data.ids = ids;
    HttpModule.getInstance():execute(HttpModule.s_cmds.delNoticeMsg,post_data,tips);
end

NoticeManagerDialog.dismiss = function(self)

    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpRequestsCallBack);
    EventDispatcher.getInstance():unregister(Event.Call,self,self.EventRespone);

	self:setVisible(false);
    self.super.dismiss(self);
end

NoticeManagerDialog.isShowing = function(self)
    return self:getVisible();
end

NoticeManagerDialog.getNoticeMsgCallBack = function(self,isSuccess,message)
    Log.i("getNoticeMsgCallBack");
    if not isSuccess or message.data:get_value() == nil then
        return ;
    end

    local data = message.data;

	if not data then
		print_string("not data");
		return
	end

	local list  = {}

	-- type	消息类别	
	-- 0 系统广播 
	-- 1 好友邀请  
	-- 2 支付消息 
	-- 3 邀请消息 
	-- 4 赠送消息
	for _,value in pairs(data) do 
		local msg = {};
		msg.type 			= value.type:get_value();
		msg.id       		= value.id:get_value();
		msg.mtime           = value.mtime:get_value();
		msg.msg 			= value.msg:get_value() or "";
		msg.button			= value.button:get_value();
		table.insert(list,msg);
	end
    if list then
		self.m_content_view:removeAllChildren();
--			local datatb = {};
            
--            if self.aa == nil then
--                self.aa = 1;
--			     for i=1,10 do
--			 	    local data = {};
--			 	    data.type = 0; 
--			 	    data.msg = "你哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈快快快快快快";
--			 	    data.mtime = os.time();
--			 	    data.button = "button"

--			 	    table.insert(datatb,data);
--			     end
--                 list = datatb;
--             end
        local flag = false;
        self.m_content_text:setVisible(false);
		for k,v in pairs(list) do
			local msgItem = new(NoticeMsgListItem,v);
			self.m_content_view:addChild(msgItem);
            flag = true;
		end

        if not flag then 
            self.m_content_text:setVisible(true);
        end
	end
end

NoticeManagerDialog.delNoticeMsgCallBack = function(self,isSuccess,message)
    Log.i("getNoticeMsgCallBack");
    if not isSuccess or message.data:get_value() == nil then
        return ;
    end

    local data = message.data;

	if not data then
		print_string("not data");
		return
	end
	
	local result = data.result:get_value();
    if result and result == 1 then
		self:getNoticeMsg();
		self.isDataChanged = true;
	end
end

NoticeManagerDialog.EventRespone = function (self , eventName,data)
	if not eventName then
		return;
	end
	print_string("NoticeManagerDialog.EventRespone eventName = " .. eventName);

	if eventName == MSG_BUTTON_EVENT then
		if data then
			if data.type == 0 then	--系统广播 
				
			elseif data.type == 1 then 	--好友邀请--
				--PHPInterface.delMsg({data.id});
			elseif data.type == 2 then 	--支付消息 
				
			elseif data.type == 3 then  --邀请消息
				
			elseif data.type == 4 then  --赠送消息--
				--PHPInterface.delMsg({data.id});
			end
			self:delNoticeMsg({data.id});
		end
	end
end

NoticeManagerDialog.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.getNoticeMsg] = NoticeManagerDialog.getNoticeMsgCallBack;
    [HttpModule.s_cmds.delNoticeMsg] = NoticeManagerDialog.delNoticeMsgCallBack;
};


NoticeMsgListItem = class(Node);

NoticeMsgListItem.ctor = function(self,data)
	local placeH = 50;
	self.data = data;
	local del_icon_x,del_icon_y = 440,20;
	local msg_fontsize = 28;
	local msg_x,msg_y = 12,85;
	local msg_time_x,msg_time_y = 370,20;
	
	local w = 582;
	local h = 0;

    local titleX,titleY = 12,20;

    local title = "消息";
    if data.type == 0 then	--系统广播 
		title = "系统广播";
	elseif data.type == 1 then 	--好友邀请
		title = "好友邀请";
	elseif data.type == 2 then 	--支付消息 
		title = "支付消息";
	elseif data.type == 3 then  --邀请消息
		title = "邀请消息";
	elseif data.type == 4 then  --赠送消息--
		title = "赠送消息";
    end

    self.m_title_text = new(Text,title,nil,nil,nil,nil,28,200,40,40);
    self.m_title_text:setPos(titleX,titleY);
    self:addChild(self.m_title_text);
  

    local date = os.date("*t",data.mtime);
	self.msg_time = new(Text,string.format("%d-%02d-%02d",date.year,date.month,date.day), nil, nil, nil,nil,28,200,40,40);
	self.msg_time:setPos(msg_time_x,msg_time_y);
	self:addChild(self.msg_time);
	local temp_w ,temp_h = self.msg_time:getSize();
    
    self.m_del_btn = new(Button,"notice/delete.png");
    self.m_del_btn:setOnClick(self,self.onBtnClick);
    self.m_del_btn:setPos(msg_time_x+temp_w+10,msg_time_y-10);
	self:addChild(self.m_del_btn);

	self.m_msg = new(TextView,"     " .. data.msg, 566, 0, nil,nil,msg_fontsize,80,80,80);
	self.m_msg:setPos(msg_x,msg_y);
	self:addChild(self.m_msg);
	local temp_w ,temp_h = self.m_msg:getSize();
	h = h + temp_h + placeH + msg_y;
    
    self.m_space_line = new(Image,"common/decoration/line_2.png");
    self.m_space_line:setPos(10,h - 12);
    self.m_space_line:setSize(560,2);
    self:addChild(self.m_space_line);

	self:setSize(w,h+5);
end

NoticeMsgListItem.getData = function(self)
	return self.data;
end

NoticeMsgListItem.onBtnClick = function(self)
	print_string("NoticeMsgListItem.onBtnClick");
	EventDispatcher.getInstance():dispatch(Event.Call, MSG_BUTTON_EVENT,self.data);
end

NoticeMsgListItem.dtor = function(self)
	
end

--endregion
