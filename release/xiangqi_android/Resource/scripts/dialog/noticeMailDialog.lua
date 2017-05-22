require(VIEW_PATH .. "notice_mail_dialog_view");
require(BASE_PATH.."chessDialogScene")

NoticeMailDialog = class(ChessDialogScene,false)

function NoticeMailDialog:ctor()
    super(self,notice_mail_dialog_view)

    local contentView = self.m_root:getChildByName("content_view")
    self.mListBg = contentView:getChildByName("list_bg")

    self.mMailViewEmptyView = self.mListBg:getChildByName("mail_view"):getChildByName("empty_view")
    self.mListBg:getChildByName("mail_view"):getChildByName("mask_1"):setLevel(2)
    self.mListBg:getChildByName("mail_view"):getChildByName("mask_2"):setLevel(2)
    self.mMailViewEmptyView:setVisible(false)
    self.mNoticeViewEmptyView = self.mListBg:getChildByName("notice_view"):getChildByName("empty_view")
    self.mListBg:getChildByName("notice_view"):getChildByName("mask_1"):setLevel(2)
    self.mListBg:getChildByName("notice_view"):getChildByName("mask_2"):setLevel(2)
    self.mNoticeViewEmptyView:setVisible(false)


    self.mMailBtn = contentView:getChildByName("mail_btn")
    self.mMailNewBg = self.mMailBtn:getChildByName("new_bg")
    self.mMailNewBg:setVisible(false)
    self.mNoticeBtn = contentView:getChildByName("notice_btn")
    self.mNoticeNewBg = self.mNoticeBtn:getChildByName("new_bg")
    self.mNoticeNewBg:setVisible(false)
    self.mMailBtn:setOnClick(self,self.showMailView)
    self.mNoticeBtn:setOnClick(self,self.showNoticeView)
    self.setCheckStatus(self.mMailBtn,false)
    self.setCheckStatus(self.mNoticeBtn,false)

    self.m_root:getChildByName("cancel_btn"):setOnClick(self,self.dismiss)
--    EventDispatcher.getInstance():register(Event.Call,self,self.onNativeEvent)
    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
end

function NoticeMailDialog:dtor()
--    EventDispatcher.getInstance():unregister(Event.Call,self,self.onNativeEvent)
    EventDispatcher.getInstance():unregister(HttpModule.s_event,self,self.onHttpRequestsCallBack);
end

--function NoticeMailDialog:onNativeEvent(cmd,...)end

NoticeMailDialog.onHttpRequestsCallBack = function(self,command,...)
	Log.i("ChessController.onHttpRequestsCallBack");
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self,...);
	end 
end

function NoticeMailDialog:selectBtn(index)
    self.setCheckStatus(self.mMailBtn,false)
    self.setCheckStatus(self.mNoticeBtn,false)
    self.mListBg:getChildByName("mail_view"):setVisible(false)
    self.mListBg:getChildByName("notice_view"):setVisible(false)
    if index == 1 then
        self.setCheckStatus(self.mMailBtn,true)
        self.mListBg:getChildByName("mail_view"):setVisible(true)
        self.mMailNewBg:setVisible(false)
    else
        self.setCheckStatus(self.mNoticeBtn,true)
        self.mListBg:getChildByName("notice_view"):setVisible(true)
        self.mNoticeNewBg:setVisible(false)
    end
end

function NoticeMailDialog.setCheckStatus(view,flag)
    if not view then return end
    local txt = view:getChildByName("title")
    if flag then
        view:setFile("common/button/table_chose_5.png")
        txt:setColor(95,15,15)
    else
        view:setFile("common/button/table_nor_5.png")
        txt:setColor(230,185,140)
    end
end


function NoticeMailDialog:showMailView()
    if not self.mMailListView then
        local mailView = self.mListBg:getChildByName("mail_view")
        local w,h = mailView:getSize()
        self.mMailListView = new(ScrollView,0, 0, w, h,true)
        self.mMailListView:setOnScrollEvent(self,self.onScroll)
        mailView:setEventTouch(self,self.onTouchEvent)
        mailView:addChild(self.mMailListView)
        self:initMailView()
    end
    self:selectBtn(1)
end

NoticeMailDialog.onScroll = function(self, scroll_status, diffY, totalOffset,isMarginRebounding)
    local viewLength = self.mMailListView:getViewLength(); -- 界面长度
    local frameLength = self.mMailListView:getFrameLength(); -- 可见区域长度
    if frameLength - totalOffset == viewLength and scroll_status == kScrollerStatusStop and not self.mIsNoMoreData then 
        self:getNoticeMsg()
        self.mMailViewScrollY = totalOffset;
    elseif frameLength - totalOffset == viewLength and scroll_status == kScrollerStatusStop and self.mIsNoMoreData then
        ChessToastManager.getInstance():showSingle("没有更多数据了",1000);
    end
end

NoticeMailDialog.getNoticeMsg = function(self)
    if self.mSendNoticeMsging then 
        return 
    end

    if self.mNoMoreData then
        return ;
    end

    self.mSendNoticeMsging = true;
    local tips = "请稍候...";
	local post_data = {};
    post_data.last_id = self.mOffset; --偏移位置
    post_data.num = 10; --数量
    post_data.mid = UserInfo.getInstance():getUid();
    HttpModule.getInstance():execute(HttpModule.s_cmds.UserMailGetMyMail,post_data);
end

NoticeMailDialog.delNoticeMsg = function(self,id)
    local tips = "请稍候...";
	local post_data = {};
	post_data.mail_id = id;
    HttpModule.getInstance():execute(HttpModule.s_cmds.UserMailDel,post_data,tips);
end

NoticeMailDialog.updateNoticeView = function(self,list)
    if list then
		self.mMailListView:removeAllChildren();
        local flag = false;
        self.mMailViewEmptyView:setVisible(false);
        self.mMailItemViews = {};
		for k,v in pairs(list) do
            local msgItem = new(UserInfoSceneNoticeMsgListItem,v,self);
            msgItem:setHandler(self);
			self.mMailListView:addChild(msgItem);
            flag = true;
            self.mMailItemViews[v.id] = msgItem;
		end
        local viewLength = self.mMailListView:getViewLength(); -- 界面长度
        local frameLength = self.mMailListView:getFrameLength(); -- 可见区域长度
        if viewLength > frameLength and self.mMailViewScrollY < frameLength - viewLength then
            self.mMailViewScrollY = frameLength - viewLength;
        elseif viewLength <= frameLength then
            self.mMailViewScrollY = 0;
        end
        if self.mMailViewScrollY ~= 0 then
            self.mMailViewScrollY = self.mMailViewScrollY - 30;
        end
        self.mMailListView:scrollToPos(self.mMailViewScrollY);

        if not flag then 
            self.mMailViewEmptyView:setVisible(true);
        end
	end
    if self.mIsNoMoreData then
        ChessToastManager.getInstance():showSingle("没有更多数据了",1000);
    end
end

function NoticeMailDialog:initMailView()
    self.mMailViewScrollY = 0
    self.mMailItemViews = {}
    self.mIsNoMoreData = false
    self.mSendNoticeMsging = false
    self.mOffset = 0
    self.m_mailDataList = {};
    self.m_mailIdMap = {};
	self.mMailListView:removeAllChildren()
    self:getNoticeMsg()
end

function NoticeMailDialog:checkNeedSeedGetMailMsg()
    local viewLength = self.mMailListView:getViewLength(); -- 界面长度
    local frameLength = self.mMailListView:getFrameLength(); -- 可见区域长度
    return viewLength <= frameLength and not self.mIsNoMoreData
end

function NoticeMailDialog:delNoticeViewItem(id)
    if self.mMailItemViews[id] then
        local x,y = self.mMailListView:getScrollViewPos();
        self.mMailListView:scrollToPos(0);
        delete(self.mMailItemViews[id]);
        self.mMailListView:setScrollEnable(true)
        self.mMailListView:updateScrollView();
        local viewLength = self.mMailListView:getViewLength(); -- 界面长度
        local frameLength = self.mMailListView:getFrameLength(); -- 可见区域长度
        if self:checkNeedSeedGetMailMsg() then
            self:getNoticeMsg()
            self.mMailViewScrollY = y;
        end
        if viewLength > frameLength and y < frameLength - viewLength then
            y = frameLength - viewLength;
        elseif viewLength <= frameLength then
            y = 0;
        end
        self.mMailListView:scrollToPos(y);
    end
end

function NoticeMailDialog:onTouchEvent()
    if UserInfoSceneNoticeMsgListItem.cur_item and UserInfoSceneNoticeMsgListItem.cur_item.status == UserInfoSceneNoticeMsgListItem.STATUS_DEL then
        UserInfoSceneNoticeMsgListItem.cur_item.status = UserInfoSceneNoticeMsgListItem.STATUS_NOR;
        UserInfoSceneNoticeMsgListItem.cur_item.isOnTouchClick = false;
        UserInfoSceneNoticeMsgListItem.cur_item:addScrollAnim();
    end
end


NoticeMailDialog.onUserInfoSceneNoticeMsgListItem = function(self,data)
    if data then
        self:delNoticeMsg(data.id)
	end
end


NoticeMailDialog.delNoticeMsgCallBack = function(self,isSuccess,message)
    Log.i("getNoticeMsgCallBack");
    if HttpModule.explainPHPMessage(isSuccess,message,"操作失败") then return end

    local data = message.data;

	if not data then
		print_string("not data");
		return
	end
	
	local id = data.mail_id:get_value();
    self:delNoticeViewItem(id)
end

-- 拉取mail消息返回
NoticeMailDialog.getUserMailGetMyMailCallBack = function(self,isSuccess,message)
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
        self.mOffset = list[#list].id or self.mOffset;
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
        self:updateNoticeView(self.m_mailDataList)
    else
        -- 屏蔽后续触发的发送消息
        self.mNoMoreData = true;
    end
end

function NoticeMailDialog:showNoticeView()
    if not self.mNoticeListView then
        local noticeView = self.mListBg:getChildByName("notice_view")
        local w,h = noticeView:getSize()
        self.mNoticeListView = new(SlidingLoadView,0, 0, w, h)
        self.mNoticeListView:setOnLoad(self,function(self)
            self:requestNoticeData()
        end)
        self.mNoticeListView:setNoDataTip("没有更多数据");
        noticeView:addChild(self.mNoticeListView)
    end
    self.requestNoticeDataIndex = 0
    self.sendNoticeDataIng = false
    self.sendNoticeDataNoMore = false
    self.mNoticeListView:reset()
    self.mNoticeListView:loadView();
    self:selectBtn(2)
end

function NoticeMailDialog:requestNoticeData()
    if self.sendNoticeDataIng or self.sendNoticeDataNoMore then return end;
    self.sendNoticeDataIng = true;
    self.requestNoticeDataIndex = self.requestNoticeDataIndex or 0;
    local params = {};
	params.offset = self.requestNoticeDataIndex;
	params.limit = 10;
    HttpModule.getInstance():execute(HttpModule.s_cmds.IndexGetBatchNotice,params);
end

NoticeMailDialog.getNoticeDataCallBack = function(self,isSuccess,message)
    if not self.sendNoticeDataIng then return end
    self.sendNoticeDataIng = false
    if not isSuccess or (type(message) == "table" and message.data:get_value() == nil ) then
        if type(message) == "table" and message.flag:get_value() == 10009 then
            self:addNoticeItem({},true);
            self.sendNoticeDataNoMore = true;
            return ;
        end
        return ;
    end
    
    local tab = json.analyzeJsonNode(message.data);
    local list = tab.list;
    if type(list) ~= "table" or #list == 0 then
        if tab.total ~= 0 then
            self:addNoticeItem({},true);
        end
        self.sendNoticeDataNoMore = true;
        return ;
    end
    
    self.requestNoticeDataIndex = self.requestNoticeDataIndex + #list;

    self:addNoticeItem(list,false);
end

NoticeMailDialog.addNoticeItem = function(self,datas,isNoData)
--    for i=1,3 do 
    for i,v in ipairs(datas) do
        local item = new(NoticeMailDialogNoticeItem,v)
        self.mNoticeListView:addChild(item);
    end
--    end
    self.mNoticeListView:loadEnd(isNoData);
end
require("dialog/notice_dialog_new")
function NoticeMailDialog.showNoticeDialog(data)
    if not data then return end

    delete(NoticeMailDialog.m_notice_dialog);
    
    NoticeMailDialog.m_notice_dialog = new(NewNoticeDialog);
    NoticeMailDialog.m_notice_dialog:setTitle(data.ntitle);
    NoticeMailDialog.m_notice_dialog:setContentText(data.ncontent);
    local jump_scene = tonumber(data.jump_scene);
    if jump_scene and jump_scene ~= 0 and StatesMap[jump_scene] and  typeof(self,HallController) then
        NoticeMailDialog.m_notice_dialog:setBtnText("查看");
        NoticeMailDialog.m_notice_dialog:setBtnClick(nil,function()
            StateMachine.getInstance():pushState(jump_scene,StateMachine.STYPE_CUSTOM_WAIT);
        end);
    else
--        NoticeMailDialog.m_notice_dialog:setBtnText();
        NoticeMailDialog.m_notice_dialog:setBtnText("知道了");
        NoticeMailDialog.m_notice_dialog:setBtnClick();
    end
    NoticeMailDialog.m_notice_dialog:show()
end

NoticeMailDialog.s_httpRequestsCallBackFuncMap  = {
    [HttpModule.s_cmds.UserMailGetMyMail] = NoticeMailDialog.getUserMailGetMyMailCallBack;
    [HttpModule.s_cmds.UserMailDel] = NoticeMailDialog.delNoticeMsgCallBack;
    [HttpModule.s_cmds.IndexGetBatchNotice] = NoticeMailDialog.getNoticeDataCallBack;
};
require(VIEW_PATH .. "notice_item")
NoticeMailDialogNoticeItem = class(Node)

NoticeMailDialogNoticeItem.ctor = function(self,data)
    self.m_root = SceneLoader.load(notice_item)
    self:setSize(self.m_root:getSize())
    self:addChild(self.m_root)
    self.mData = data
    local click_btn = self.m_root:getChildByName("click_btn")
    click_btn:getChildByName("time"):setText( os.date("%m月%d日 %H:%M",data.nstart) )
    click_btn:getChildByName("title"):setText(data.ntitle)
    click_btn:setOnClick(self,self.onClick)
end

function NoticeMailDialogNoticeItem:onClick()
    NoticeMailDialog.showNoticeDialog(self.mData)
end