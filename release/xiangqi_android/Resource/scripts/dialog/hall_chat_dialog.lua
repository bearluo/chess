--region hall_chat_dialog.lua
--Author : LeoLi
--Date   : 2015/11/16

require(VIEW_PATH .. "hall_chat_dialog_view");
require(BASE_PATH.."chessDialogScene")
require(DATA_PATH.."chatRoomData");
require("ui2/compat/scrollView2");
require("dialog/user_info_dialog2")
require(VIEW_PATH .. "hall_chat_room_schemes_item");
require(VIEW_PATH .. "hall_chat_room_schemes_item2");

require(VIEW_PATH .. "chess_room_invite_item");
require("dialog/city_locate_pop_dialog")
require("dialog/systemNoticeView")
require(DATA_PATH .."systemNoticeLog");
require("util/analysisNotice")
require("dialog/create_and_check_sociaty_dialog");
require("dialog/chat_room_invite_dialog");
require(MODEL_PATH.."chessSociatyModule/chessSociatyModuleView");
require(MODEL_PATH.."chessSociatyModule/chessSociatyModuleController");
require("dialog/friend_chioce_dialog");
require(DATA_PATH.."friendshipWarData")
HallChatDialog = class(ChessDialogScene,false);
-- 弹窗弹出隐藏时间
HallChatDialog.SHOW_ANIM_TIME    = 400;
HallChatDialog.HIDE_ANIM_TIME    = 200;
-- 左进右出动画时间
HallChatDialog.LIRO_ANIM_TIME    = 300;
-- 左出右进动画时间
HallChatDialog.LORI_ANIM_TIME    = 200;
-- 淡入淡出动画时间
HallChatDialog.FADEIN_ANIM_TIME  = 400;
HallChatDialog.FADEOUT_ANIM_TIME = 400;
-- 聊天室/好友私聊
HallChatDialog.PUBLIC_CHAT       = 1;
HallChatDialog.PRAVITE_CHAT      = 0;

-- 场景
HallChatDialog.ERROR             = 0;  -- 出错了
HallChatDialog.MAIN_CHAT         = 1;  -- 聊天主界面
HallChatDialog.DASHI_CHAT        = 2;  -- 大师聊天
HallChatDialog.CITY_CHAT         = 3;  -- 同城聊天
HallChatDialog.COMMON_CHAT       = 4;  -- 好友私聊
HallChatDialog.CREATE_CHAT       = 5;  -- 创建会话
HallChatDialog.WORLD_CHAT        = 6;  -- 世界聊天
HallChatDialog.NEWPLAYER_CHAT    = 7;  -- 新人聊天
HallChatDialog.HORN_CHAT         = 8;  -- 喇叭
HallChatDialog.CHESSCLUB_LIST    = 9;  -- 棋社列表
HallChatDialog.CHESSCLUB_CHAT    = 10; -- 棋社聊天

HallChatDialog.CHATROOM_TABLE = {};
HallChatDialog.ctor = function(self, room)
    super(self,hall_chat_dialog_view);
    self.mWarData = new (FriendshipWarData)
    self.anim_dlg = AnimDialogFactory.createNormalAnim(self)
    self.m_room = room;
    self.m_rootW, self.m_rootH = self:getSize();
    self.m_current_view = HallChatDialog.MAIN_CHAT;
    -- 约战消息列表
    self.m_chatroom_msg_list = {};
    self.m_chatroom_invite_msg_list = {};
    self:initView();
end;

HallChatDialog.dtor = function(self)
    delete(self.mWarData)
    self.mWarData = nil
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onEventResponse);
    self.anim_dlg:stopAnim()
end;

HallChatDialog.isShowing = function(self)
    return self:getVisible();
end

---------------------------- function --------------------------------
HallChatDialog.initView = function(self)
    -- bg
    self.m_hall_chat_bg = self.m_root:getChildByName("bg");
    ------------- main_chat_view ---------------------
    self.m_main_chat_view = self.m_hall_chat_bg:getChildByName("main_chat");
    -- title
    self.m_main_chat_title_view = self.m_main_chat_view:getChildByName("title");
    -- add_btn
    self.m_add_btn = self.m_main_chat_title_view:getChildByName("add_chat");
    self.m_add_btn:setOnClick(self, self.createChatView);
    -- hide_btn
    self.m_hide_dialog_btn = self.m_main_chat_view:getChildByName("hide_chat_btn");
    self.m_hide_dialog_btn:setOnClick(self, self.dismiss);
    -- content
    self.m_main_chat_content_view = self.m_main_chat_view:getChildByName("content_view");
            
    ------------- create_chat_view -------------------
    self.m_create_chat_view = self.m_hall_chat_bg:getChildByName("create_chat");
    -- title
    self.m_create_chat_title_view = self.m_create_chat_view:getChildByName("title");
    -- back_btn
    self.m_create_chat_back_btn = self.m_create_chat_title_view:getChildByName("back_btn");
    self.m_create_chat_back_btn:setOnClick(self, self.createChatBackToMainChat);
    -- search_view
    self.m_create_chat_search_view = self.m_create_chat_view:getChildByName("search_view");
    -- search_edit_bg
    self.m_create_chat_search_bg = self.m_create_chat_search_view:getChildByName("search_bg");
    -- search_edit
    self.m_create_chat_search_edit = self.m_create_chat_search_bg:getChildByName("search_content");
    self.m_create_chat_search_edit:setHintText("输入好友名称或ID",130,95,55);
    self.m_create_chat_search_edit:setOnTextChange(self, self.searchFriends);
    -- content
    self.m_create_chat_content_view = self.m_create_chat_view:getChildByName("content_view");   

    ---------------- chat_room_view ------------------
    self.m_chat_room_view = self.m_hall_chat_bg:getChildByName("chat_room_view");
    -- title
    self.m_chat_room_title_view = self.m_chat_room_view:getChildByName("title");
    -- chat_name
    self.m_chat_room_title_txt = self.m_chat_room_title_view:getChildByName("title_txt");
    -- people
    self.m_chat_room_people_txt = self.m_chat_room_title_view:getChildByName("people");
    -- select_city
    self.m_chat_room_select_city_btn = self.m_chat_room_title_view:getChildByName("select_city");
    self.m_chat_room_select_city_btn:setOnClick(self, self.showCityLocateDlg);
    -- back_btn
    self.m_chat_room_back_btn = self.m_chat_room_title_view:getChildByName("back_btn");
    self.m_chat_room_back_btn:setOnClick(self, self.chatRoomBackToMainChat);
    --member_btn 
    self.m_chat_room_member_btn = self.m_chat_room_title_view:getChildByName("member_btn");
    self.m_chat_room_member_btn:setOnClick(self, function()
        
        self:onSwitchSociatyView(self.chessClubListBackToSociatyChat)
    end);
    -- content
    self.m_chat_room_view_content_view = self.m_chat_room_view:getChildByName("content_view");  
    -- locate
    self.m_chat_room_view_locate_view = self.m_chat_room_view:getChildByName("locate_city");
    self.m_chat_room_view_locate_view:setLevel(1);
    self.m_chat_room_view_locate_btn = self.m_chat_room_view_locate_view:getChildByName("locate");
    self.m_chat_room_view_locate_btn:setOnClick(self,self.getCurrentLocateInfo);
    -- bottom
    self.m_chat_room_bottom_view = self.m_chat_room_view:getChildByName("bottom_view");
    -- black_bg
    self.m_chat_room_bottom_black_bg = self.m_chat_room_bottom_view:getChildByName("black_bg");
    self.m_chat_room_bottom_black_bg:setEventDrag(self,function()end);
    self.m_chat_room_bottom_black_bg:setEventTouch(self,function(obj,finger_action) 
        if finger_action == kFingerUp then
            self:openMoreAction(false) 
        end;
    end);
    -- bg
    self.m_chat_room_bottom_bg = self.m_chat_room_bottom_view:getChildByName("bg");
    self.m_chat_room_bottom_bg:setEventTouch(self,function() end);
    self.m_chat_room_bottom_bg:setEventDrag(self,function()end);
    -- input
    self.m_chat_room_bottom_input_view = self.m_chat_room_bottom_view:getChildByName("input");
    -- send_edit_bg
    self.m_chat_room_bottom_send_bg = self.m_chat_room_bottom_input_view:getChildByName("send_bg");
    -- send_edit
    self.m_chat_room_bottom_send_edit = self.m_chat_room_bottom_send_bg:getChildByName("send_content");
    self.m_chat_room_bottom_send_edit:setHintText("点击输入聊天内容",165,145,125);
    self.m_chat_room_bottom_send_edit:setOnTextChange(self,self.sendChatRoomMsg);
    -- add_btn
    self.m_chat_room_bottom_add_btn = self.m_chat_room_bottom_input_view:getChildByName("add_btn");
    self.m_chat_room_bottom_add_btn:setOnClick(self,function() self:openMoreAction(true) end);
    -- action
    self.m_chat_room_bottom_action_view = self.m_chat_room_bottom_view:getChildByName("action");
    -- invite_btn
    self.m_chat_room_bottom_invite_btn = self.m_chat_room_bottom_action_view:getChildByName("invite"):getChildByName("btn");
    self.m_chat_room_bottom_invite_btn:setOnClick(self, self.inviteChessGame);
    -- filter_btn
    self.m_chat_room_filter_btn = self.m_chat_room_view:getChildByName("filter");
    self.m_chat_room_filter_btn:setOnClick(self, self.filterChatRoomMsg);
    self.m_chat_room_filter_btn_txt = self.m_chat_room_filter_btn:getChildByName("txt");

    ---------------- chat_invite_view ----------------
    self.m_chat_invite_view = self.m_hall_chat_bg:getChildByName("chat_invite_view");
    -- title
    self.m_chat_invite_title_view = self.m_chat_invite_view:getChildByName("title");
    -- chat_name
    self.m_chat_invite_title_txt = self.m_chat_invite_title_view:getChildByName("title_txt");
    -- back_btn
    self.m_chat_invite_back_btn = self.m_chat_invite_title_view:getChildByName("back_btn");
    self.m_chat_invite_back_btn:setOnClick(self, self.chatInviteBackToMainChat);
    -- content
    self.m_chat_invite_view_content_view = self.m_chat_invite_view:getChildByName("content_view");  

    ---------------- horn_view -----------------------
    self.m_horn_room_view = self.m_hall_chat_bg:getChildByName("horn_view");
    -- title
    self.m_horn_room_title_view = self.m_horn_room_view:getChildByName("title");
    -- horn_name
    self.m_horn_room_title_txt = self.m_horn_room_title_view:getChildByName("title_txt");
    -- back_btn
    self.m_horn_room_back_btn = self.m_horn_room_title_view:getChildByName("back_btn");
    self.m_horn_room_back_btn:setOnClick(self, self.hornRoomBackToMainChat);
    -- content
    self.m_horn_room_view_content_view = self.m_horn_room_view:getChildByName("content_view");  
    local w,h = self.m_horn_room_view_content_view:getSize()
    self.mSystemNotice = new(SystemNoticeView,w,h,self)
    -- bottom
    self.m_horn_room_bottom_view = self.m_horn_room_view:getChildByName("bottom_view");
    -- black_bg
    self.m_horn_room_bottom_black_bg = self.m_horn_room_bottom_view:getChildByName("black_bg");
    -- input
    self.m_horn_room_bottom_input_view = self.m_horn_room_bottom_view:getChildByName("input");
    -- send_edit_bg
    self.m_horn_room_bottom_send_bg = self.m_horn_room_bottom_input_view:getChildByName("send_bg");
    -- send_edit
    self.m_horn_room_bottom_send_edit = self.m_horn_room_bottom_send_bg:getChildByName("send_content");
    self.m_horn_room_bottom_send_edit:setHintText("发布全服喇叭每次需花2万金币",165,145,125);
    self.m_horn_room_bottom_send_edit:setOnTextChange(self,self.sendHornMsg);

    -- mask
    self.m_hall_chat_room_mask = self.m_root:getChildByName("mask");
    self.m_hall_chat_room_mask_bg = self.m_hall_chat_room_mask:getChildByName("bg");
    self.m_hall_chat_room_mask_bg:setTransparency(0.8);
    self.m_hall_chat_room_mask_bg:setEventTouch(self, function() end);
    self.m_hall_chat_mask_left = self.m_hall_chat_room_mask:getChildByName("left");
    self.m_hall_chat_mask_tip = self.m_hall_chat_mask_left:getChildByName("tip");
    self.m_hall_chat_mask_user_tip = self.m_hall_chat_mask_left:getChildByName("user_tip");
    self.m_hall_chat_mask_right = self.m_hall_chat_room_mask:getChildByName("right");
    self.m_hall_chat_mask_btn = self.m_hall_chat_mask_right:getChildByName("btn");
    self.m_hall_chat_mask_btn_txt = self.m_hall_chat_mask_btn:getChildByName("txt");
    self.m_hall_chat_room_mask_status = 0;-- 0：初始状态1：等待，2：准备入场

    self.m_sociaty_view = self.m_hall_chat_bg:getChildByName("sociaty_view")
    if not self.mSocaityModule then
        self.mSocaityModule = new(ChessSociatyModuleView,self)
    end

    ---------------- http_event ---------------------------------
    EventDispatcher.getInstance():register(ChessSociatyModuleView.s_event.Refresh,self,self.onEventResponse);
    EventDispatcher.getInstance():register(Event.Call,self,self.onEventResponse);

    self:setNeedBackEvent(function() 
        if self.m_hall_chat_room_mask:getVisible() then
            if self.m_hall_chat_room_mask_status == 1 then
                self:showCancelChessMatchDlg();
            end;
        else
            self:dismiss();
        end;        
        return true;
    end);
end;

HallChatDialog.show = function(self)
    self:setVisible(true);
    self.super.show(self,self.anim_dlg.showAnim);
    -- leftInAnim
    self.m_root:removeProp(11);
    -- 加载聊天主界面
    self:loadChatInfo();
    -- 加载好友信息
    self:loadFriendsInfo();
    -- 拉取未读消息数量
    self:loadUnreadMsgNum();
    -- 拉取最新消息
    self:loadLatestMsgs();
    -- 更新喇叭消息
    self:loadLatestNotice(); 
end

HallChatDialog.showCancelChessMatchDlg = function(self)
    if not self.m_chioce_dialog then
        self.m_chioce_dialog = new(ChioceDialog);
    end;
	self.m_chioce_dialog:setMode(ChioceDialog.MODE_SURE,"留在聊天","继续离开");
    self.m_chioce_dialog:setMaskDialog(true);
	self.m_chioce_dialog:setMessage("关闭聊天将取消本次约战，是否继续？");
	self.m_chioce_dialog:setPositiveListener(nil,nil);
	self.m_chioce_dialog:setNegativeListener(self,function()
        if self.m_chessMatchItem then
            self.m_chessMatchItem:cancelChessMatch();
        end;
        EffectAnim.scrollUp(self,self.m_hall_chat_room_mask,200,function()
            self.m_hall_chat_room_mask_status = 0;
            self:dismiss();
        end);
    end);
	self.m_chioce_dialog:show();    
end;

HallChatDialog.dismiss = function(self)
    if self.m_hall_chat_room_mask:getVisible() then
        if self.m_hall_chat_room_mask_status == 1 then
            if self.m_chessMatchItem then
                self.m_chessMatchItem:cancelChessMatch();
                EffectAnim.scrollUp(self,self.m_hall_chat_room_mask,50,function()
                    self.m_hall_chat_room_mask_status = 0;
                    self:clearDialog();
                end);
                return;
            end;
        end;
    else    
        self:resetChatDialog();
        self:clearDialog();
    end;
end;

HallChatDialog.clearDialog = function(self)
    self.m_root:removeProp(10);
    if self.m_city_locate_dialog then
        delete(self.m_city_locate_dialog);
        self.m_city_locate_dialog = nil;
    end
    if self.mSystemNotice then
        self.mSystemNotice:switchScene()
    end
    if self.m_chat_inviate_dlg then
        delete(self.m_chat_inviate_dlg);
        self.m_chat_inviate_dlg = nil;
    end;
    -- hideAnim
--    local rightHideAnim = self.m_root:addPropTranslate(11,kAnimNormal,HallChatDialog.HIDE_ANIM_TIME,0,0,-self.m_rootW,nil,nil);
--    if not rightHideAnim then return end;
--    rightHideAnim:setEvent(self, function() 
        self.super.dismiss(self,self.anim_dlg.dismissAnim);
        self:setVisible(false);
        self:resetChatDialog();
        self.m_room:loadLocalUnreadMsgs();
        self.m_room:setHallChatBtnVisible(true);
        self.m_hall_chat_bg:setPickable(true);
        self.hasShowChatRoomInfo = false;
        self.m_chat_room_view_locate_view:setVisible(false);
        self.m_chat_room_select_city_btn:setVisible(false);
        self.m_sociaty_view:setVisible(false)
        if self.mSocaityModule then
            self.mSocaityModule:pause()
        end
--    end)
end;

HallChatDialog.hideChatRoomMask = function(self)
    if self.m_hall_chat_room_mask:getVisible() then
        EffectAnim.scrollUp(self,self.m_hall_chat_room_mask,200,function()
            self.m_hall_chat_room_mask_status = 0;
        end);        
    end;
end;

HallChatDialog.haveUnreadMsgs = function(self)
    local unreadNum = FriendsData.getInstance():getUnreadNum();
    if unreadNum > 0 then 
        return true;
    else
        return false;
    end;
end;

HallChatDialog.resetChatDialog = function(self)
    
    if self.m_current_view == HallChatDialog.MAIN_CHAT then
        self.m_main_chat_view:setVisible(true);
    elseif self.m_current_view == HallChatDialog.DASHI_CHAT or
           self.m_current_view == HallChatDialog.CITY_CHAT or
           self.m_current_view == HallChatDialog.WORLD_CHAT or
           self.m_current_view == HallChatDialog.NEWPLAYER_CHAT or
           self.m_current_view == HallChatDialog.CHESSCLUB_CHAT  then
        -- 离开时保留最后一条消息内容
        ChatRoomData.getInstance():saveRoomData(self.m_chat_room_item:getRoomId(),os.time());
        ChatRoomData.getInstance():clearChatRoomData(self.m_chat_room_item:getRoomId());
        self:toGetUpHistoryMsg(os.time(),self.m_chat_room_item:getRoomId());
        self:leaveChatRoom(self.m_chat_room_item:getRoomId());
        if self.m_chat_room_scroll_msg_view then
            self.m_chat_room_scroll_msg_view:removeAllChildren(true);
        end;
        self.m_chat_room_view:setVisible(false);
        self.m_chat_invite_view:setVisible(false);
        self.m_chat_room_filter_btn:setVisible(false);
        if self.m_chat_invite_scroll_msg_view then
            self.m_chat_invite_scroll_msg_view:removeAllChildren(true);
            delete(self.mWarData)
            self.mWarData = new (FriendshipWarData)
        end;
    elseif self.m_current_view == HallChatDialog.HORN_CHAT then
        self.m_horn_room_view:setVisible(false);
        -- 离开时保留最后一条消息内容
    elseif self.m_current_view == HallChatDialog.COMMON_CHAT then
        self.m_chat_room_view:setVisible(false);
        if self.m_chat_room_scroll_msg_view then
            self.m_chat_room_scroll_msg_view:removeAllChildren(true);
        end;
    elseif self.m_current_view == HallChatDialog.CREATE_CHAT then
        self.m_create_chat_view:setVisible(false);
    elseif self.m_current_view == HallChatDialog.CHESSCLUB_LIST then
--        self.m_chess_club_list:setVisible(false);    
        self:onHideSociatyView()
    end;
    self:openMoreAction(false);
    self.m_main_chat_view:setVisible(true);
    self.m_current_view = HallChatDialog.MAIN_CHAT;
end;

HallChatDialog.loadFriendsInfo = function(self)
    FriendsData.getInstance():getFrendsListData();
end;

-- 加载聊天室主界面item
HallChatDialog.loadChatInfo = function(self)
    if not self.m_main_chat_scroll_view then
        -- 公共聊天室（同城/大师）
        self.m_main_chat_room_list = UserInfo.getInstance():getChatRoomList();
        local contentW,contentH = self.m_main_chat_content_view:getSize();
        self.m_main_chat_scroll_view = new(ScrollView2,0,0,contentW,contentH,true);
        self.m_main_chat_content_view:addChild(self.m_main_chat_scroll_view);
        self.m_chat_room_items = {};
        if self.m_main_chat_room_list then
            for index = 1, #self.m_main_chat_room_list do
                local data = self.m_main_chat_room_list[index];
                self.m_chat_room_items[index] = new(HallChatDialogItem,data,HallChatDialog.PUBLIC_CHAT,self);
                self.m_main_chat_scroll_view:addChild(self.m_chat_room_items[index]);
                self.m_chat_room_items[index]:setPickable(false);
            end;
        end;
        -- 私人聊天数据
        self.m_main_chat_chat_list = FriendsData.getInstance():getChatList();
        if self.m_main_chat_chat_list then
            self.m_chat_list_items = {};
            for index = 1, #self.m_main_chat_chat_list do
                local data = self.m_main_chat_chat_list[index];
                self.m_chat_list_items[index] = new(HallChatDialogItem,data,HallChatDialog.PRAVITE_CHAT,self);
                self.m_main_chat_scroll_view:addChild(self.m_chat_list_items[index]);
            end;
        end;
    else
        self:updateMainChatItem();
    end;
end;
    
HallChatDialog.updateMainChatItem = function(self)
    -- 切换城市更新同城聊天标题
    if self.m_main_chat_room_list then
        for index = 1, #self.m_main_chat_room_list do
            if self.m_main_chat_room_list[index].type and self.m_main_chat_room_list[index].type == "city" then
                if self.m_main_chat_room_list[index].id and self.m_main_chat_room_list[index].id == "1001" then
                    self.m_chat_room_items[index]:setCityCode(UserInfo.getInstance():getProvinceCode());
                    self.m_chat_room_items[index]:setCityName(UserInfo.getInstance():getProvinceName());
                   
                end;
            elseif self.m_main_chat_room_list[index].type and self.m_main_chat_room_list[index].type == "guild" then
             
            end;
        end;
    end;    
    if self.m_main_chat_chat_list then
        for index = 1, #self.m_chat_list_items do
            local child = self.m_chat_list_items[index];
            self.m_main_chat_scroll_view:removeChild(child,true);
        end;
        self.m_chat_list_items = nil;
        self.m_chat_list_items = {};

        delete(self.m_main_chat_chat_list);
        self.m_main_chat_chat_list = nil;
        self.m_main_chat_chat_list = FriendsData.getInstance():getChatList();
        for index = 1, #self.m_main_chat_chat_list do
            local data = self.m_main_chat_chat_list[index];
            self.m_chat_list_items[index] = new(HallChatDialogItem,data,HallChatDialog.PRAVITE_CHAT,self);
            self.m_main_chat_scroll_view:addChild(self.m_chat_list_items[index]);
        end;
    end;
    self.m_main_chat_scroll_view:gotoTop();
    self.m_main_chat_scroll_view:updateScrollView();
end;

HallChatDialog.updateMainPraviteChat = function(self,data,isNew,child)
    local localChatInfo = FriendsData.getInstance():getChatList();
    for i = 1, #localChatInfo do
        if data.send_uid == localChatInfo[i].uid then
            if isNew then
                local tempItem = new(HallChatDialogItem,localChatInfo[i],HallChatDialog.PRAVITE_CHAT,self);
                table.insert(self.m_chat_list_items,tempItem);
                self.m_main_chat_scroll_view:addChild(tempItem);
                self.m_main_chat_scroll_view:childToPos(tempItem,#self.m_chat_room_items + 1);
            else
                self.m_main_chat_scroll_view:childToPos(child,#self.m_chat_room_items + 1);
            end;
        end;
    end;
end;

-- mainChat 拉取最新消息,
HallChatDialog.loadLatestMsgs = function(self)
    for i = 1,#self.m_chat_room_items do
        self:toGetUpHistoryMsg(os.time(),self.m_chat_room_items[i]:getRoomId());
    end;
end;

function HallChatDialog.loadLatestNotice(self)
    for k,v in pairs(self.m_chat_room_items) do
        if v then
            if v:getRoomId() == "horn" then
                v:setNoticeRoomLastMsg()
                break
            end
        end
    end
end

-- mainChat 拉取未读消息
HallChatDialog.loadUnreadMsgNum = function(self)
    -- 聊天室未读消息
    -- 拉取最后一条消息的时间，并设置mainChat聊天室item最后一条消息
    local chatRoomLastMsg = ChatRoomData.getInstance():getLastRoomMsg();
    for i = 1,#self.m_chat_room_items do
        if chatRoomLastMsg then
            for j = 1,#chatRoomLastMsg do
                if self.m_chat_room_items[i]:getRoomId() == chatRoomLastMsg[j].roomid.."" then
                    -- 拉取未读消息
                    local info = {};
                    info.room_id = self.m_chat_room_items[i]:getRoomId();
                    info.uid = UserInfo.getInstance():getUid();
                    info.begin_msg_time = chatRoomLastMsg[j].time or 0;
                    info.end_msg_time = os.time() + 10; -- +10和server时间同步;
                    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_GET_UNREAD_MSG2,info);
                end;
            end;
        end;
    end;
    local commonChatMsg = FriendsData.getInstance():getChatList();
    local originX,originY = self.m_main_chat_scroll_view:getMainNodeWH();
    if self.m_main_chat_scroll_view then
        for index = 1, #self.m_chat_list_items do
            self.m_main_chat_scroll_view:removeChild(self.m_chat_list_items[index],true);
        end;
        self.m_main_chat_scroll_view:updateScrollView();
        self.m_chat_list_items = {};
    end;
    for index = 1,#commonChatMsg do
        self.m_chat_list_items[index] = new(HallChatDialogItem,commonChatMsg[index],HallChatDialog.PRAVITE_CHAT,self);
        self.m_main_chat_scroll_view:addChild(self.m_chat_list_items[index]);       
    end;
    self.m_main_chat_scroll_view:gotoOffset(originY);
    -- 普通聊天未读消息
    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_GET_UNREAD_MSG);
    -- 更新聊天室列表
    HttpModule.getInstance():execute(HttpModule.s_cmds.loadChatRoomInfo,{});
end

HallChatDialog.onMainChatItemClick = function(self, item)
    self.m_hall_chat_bg:setPickable(false);
    self.m_main_chat_item = item;
    if self.m_main_chat_item:getRoomType() == "master" then -- 大师
        self.m_room:entryChatRoom(self.m_main_chat_item:getRoomId());
    elseif self.m_main_chat_item:getRoomType() == "city" then -- 同城
        if self.m_main_chat_item:getRoomId() ~= "0" then
            self.m_room:entryChatRoom(UserInfo.getInstance():getProvinceCode());
        else
            self:loadChatRoomInfo(self.m_main_chat_item,nil,true); 
            self:playMainChat2ChatRoomAnim();
            self.m_chat_room_view_locate_view:setVisible(true);
        end;
    elseif self.m_main_chat_item:getRoomType() == "comm" then -- 世界
        self.m_room:entryChatRoom(self.m_main_chat_item:getRoomId());
    elseif self.m_main_chat_item:getRoomType() == "new" then -- 新人
        self.m_room:entryChatRoom(self.m_main_chat_item:getRoomId());
    elseif self.m_main_chat_item:getRoomType() == "horn" then -- 喇叭
        self:entrySysNoticeRoom();
    elseif self.m_main_chat_item:getRoomType() == "guild" then
        if self.m_main_chat_item:getRoomId() ~= "no_guild" then
            self.m_room:entryChatRoom(self.m_main_chat_item:getRoomId());
        else
            self.m_current_view = HallChatDialog.CHESSCLUB_LIST;
            self:onSwitchSociatyView(self.chessClubListBackToMainChat)         
        end;         
    elseif self.m_main_chat_item:getItemType() == 0 then
        self.m_common_room_from = 1;
        self:loadChatRoomInfo(self.m_main_chat_item);
        self:resetChatRoomView();
    end;
    ToolKit.schedule_once(self,function() self.m_hall_chat_bg:setPickable(true) end,3000);
end;

function HallChatDialog.entrySysNoticeRoom(self)
    self:loadHornRoomInfo(self.m_main_chat_item);
    ToolKit.schedule_once(self,EffectAnim.leftOutRightIn,300,self.m_main_chat_view,self.m_horn_room_view,HallChatDialog.LORI_ANIM_TIME,
                            function() self.m_hall_chat_bg:setPickable(true); end);
    if not self.mSystemNotice then
        local w,h = self.m_horn_room_view_content_view:getSize()
        self.mSystemNotice = new(SystemNoticeView,w,h,self)
    end
    self.mSystemNotice:updataHistoryList()
end


-- 判断是否进入聊天室
HallChatDialog.setEntryChatRoom = function(self,packetInfo)
    if packetInfo.status == 0 then 
        self:loadChatRoomInfo(self.m_main_chat_item,packetInfo.people);
        self:resetChatRoomView();
    elseif packetInfo.status == 1 then
        local str = "聊天室已满"
        ChessToastManager.getInstance():showSingle(str,500);
        self.m_hall_chat_bg:setPickable(true)
    else
        local str = "参数出错了";
        ChessToastManager.getInstance():showSingle(str,500);
        self.m_hall_chat_bg:setPickable(true)
    end
end

HallChatDialog.setCityName = function(self, city)
    if self.m_main_chat_item then
        if self.m_main_chat_item:getRoomId() and self.m_main_chat_item:getRoomId() == UserInfo.getInstance():getProvinceCode() then
            self.m_main_chat_item:setCityName(city);
        end;
    end;
end

HallChatDialog.onCreateChatItemClick = function(self, item)
    self.m_common_room_from = 2;-- 1,from mainChat;2,from createChat
    EffectAnim.fadeInAndOut(self,self.m_chat_room_back_btn,nil,HallChatDialog.FADEIN_ANIM_TIME);
    self:loadChatRoomInfo(item);
    self:resetChatRoomView();
end;

-- 加载聊天室基本信息
HallChatDialog.loadChatRoomInfo = function(self,item,people,notLocate)
    self.m_chat_room_item = item;
    if self.m_chat_room_item:getItemType() == 1 then     -- 聊天室s
        self.m_chat_room_member_btn:setVisible(false)
        if self.m_chat_room_item:getRoomType() == "master" then
	        self.m_current_view = HallChatDialog.DASHI_CHAT;       -- 大师
        elseif self.m_chat_room_item:getRoomType() == "city" then  -- 同城
            self.m_current_view = HallChatDialog.CITY_CHAT;
            -- 显示手动选择地区按钮
            self.m_chat_room_select_city_btn:setVisible(not notLocate);
        elseif self.m_chat_room_item:getRoomType() == "comm" then  -- 世界(有可能增加小型聊天室)
            self.m_current_view = HallChatDialog.WORLD_CHAT;
        elseif self.m_chat_room_item:getRoomType() == "new" then   -- 新手
            self.m_current_view = HallChatDialog.NEWPLAYER_CHAT;
        elseif self.m_chat_room_item:getRoomType() == "horn" then  -- 小喇叭
            self.m_current_view = HallChatDialog.HORN_CHAT;
        elseif self.m_chat_room_item:getRoomType() == "guild" then -- 棋社
            self.m_current_view = HallChatDialog.CHESSCLUB_CHAT;
            self.m_chat_room_member_btn:setVisible(true)
        else
            self.m_current_view = HallChatDialog.ERROR
        end;
        self.m_chat_room_bottom_add_btn:setVisible(true);
        if people then
            self.m_chat_room_people_txt:setVisible(true);
            self.m_chat_room_people_txt:setText("在线："..people);
        else
            self.m_chat_room_people_txt:setVisible(false);
        end;
    elseif self.m_chat_room_item:getItemType() == 0 then -- 好友s
        self.m_current_view = HallChatDialog.COMMON_CHAT;
        self.m_chat_room_bottom_add_btn:setVisible(false);
        self.m_chat_room_people_txt:setVisible(false);
    end;
    self.m_chat_room_title_txt:setText(self.m_chat_room_item:getChatRoomName());
end;

-- 加载喇叭房间聊天信息
HallChatDialog.loadHornRoomInfo = function(self,item)
    self.m_horn_room_item = item;
    self.m_current_view = HallChatDialog.HORN_CHAT;
    self.m_chat_room_title_txt:setText("喇叭");
end;

-- "+"按钮
HallChatDialog.openMoreAction = function(self,flag)
    local w, h = self.m_chat_room_bottom_view:getSize();
    if h == 95 and flag then
        EffectAnim.moveUp(self,self.m_chat_room_bottom_view,300,10,function() 
            self.m_chat_room_bottom_action_view:setVisible(true);
            self.m_chat_room_bottom_black_bg:setVisible(true);      
        end);
    else
        if h == 95 then return end;
        self.m_chat_room_bottom_action_view:setVisible(false);
        self.m_chat_room_bottom_black_bg:setVisible(false);   
        EffectAnim.moveDown(self,self.m_chat_room_bottom_view,95,10,function()end);
    end;
end;

-- 友谊赛约战
HallChatDialog.inviteChessGame = function(self)
    if UserInfo.getInstance():isFreezeUser() then return end;
    if not self:isCanSendMsg() then return end;
    local money = UserInfo.getInstance():getMoney();
	local isCanAccess = RoomProxy.getInstance():checkCanJoinRoom(RoomConfig.ROOM_TYPE_PRIVATE_ROOM,money);
	if not isCanAccess then
        ChessToastManager.getInstance():showSingle("您的金币不足，不能创建友谊赛");
		return;
	end
    self.m_chat_inviate_dlg = new(ChatRoomInviteDialog);
    self.m_chat_inviate_dlg:show(self.m_chat_room_item);
end;

-- 过滤出友谊战
HallChatDialog.filterChatRoomMsg = function(self)
    if lua_multi_click(1) then return end;
    if self.m_hall_chat_room_mask:getVisible() then 
        ChessToastManager.getInstance():showSingle("您已经有个约战了");
        return;
    end;
    ToolKit.schedule_once(self,EffectAnim.leftOutRightIn,300,self.m_chat_room_view,self.m_chat_invite_view,HallChatDialog.LORI_ANIM_TIME,
    function() 
        self:toGetChessMatchMsg(os.time() + 10,self.m_chat_room_item:getRoomId());
        delete(self.m_chat_invite_scroll_msg_view);
        self.m_chat_invite_scroll_msg_view = nil;
        delete(self.mWarData)
        self.mWarData = new (FriendshipWarData)
        local contentW,contentH = self.m_chat_room_view_content_view:getSize();
        self.m_chat_invite_scroll_msg_view = new(ScrollView2,20,20,contentW,contentH+70,true);
        self.m_chat_invite_scroll_msg_view:setOnScroll(self, self.chatInviteViewScroll);
        self.m_chat_invite_view_content_view:addChild(self.m_chat_invite_scroll_msg_view);
    end);
end;

HallChatDialog.sendInviteChess = function(self)
    if self.m_chat_inviate_dlg then
        if false then -- 测试多发约战消息
            ToolKit.schedule_repeat_time(self,function()
                self.m_chat_inviate_dlg:createChessGame();
            end,1000,30);
        else
            self.m_chat_inviate_dlg:createChessGame();
        end;
    end;
end;

-- 1v1 挑战
--详见文档:http://jd.oa.com/wiki/index.php?title=象棋_Server协议文档#.E8.81.8A.E5.A4.A9.E5.AE.A4.E7.BA.A6.E6.88.98.E5.8D.8F.E8.AE.AE.E6.96.87.E6.A1.A3
HallChatDialog.send1v1Chess = function(self)
    local customRoomData = UserInfo.getInstance():getCustomRoomData();
    if not next(customRoomData) then return end;
    local msgdata = {};
	msgdata.room_id = self.m_chat_room_item:getRoomId();
	msgdata.msg = os.date("%m/%d %H:%M:%S",os.time()).." 我正在发起1v1挑战，升级新版本可查看详情";
	msgdata.name = UserInfo.getInstance():getName();
	msgdata.uid = UserInfo.getInstance():getUid();
    msgdata.msg_type = 3;
    local other = {};
    other.tid = RoomProxy.getInstance():getTid();
    other.c_uid = UserInfo.getInstance():getUid();
    other.a_uid = customRoomData.target_uid;
    other.pwd = customRoomData.password;
    other.act = 1;
    other.status = 0;
    other.rm_msgid = 0;
    other.rec_id = "";
    other.rd_t = customRoomData.round_time;
    other.step_t= customRoomData.step_time;
    other.sec_t= customRoomData.sec_time;
    other.base = customRoomData.basechip;
    msgdata.other = json.encode(other);    
    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_USER_CHAT_MSG,msgdata);
end;

HallChatDialog.loadWaitingItem = function(self,item,isWaiting)
    self.m_chessMatchItem = item;
    if isWaiting then
        EffectAnim.scrollDown(self,self.m_hall_chat_room_mask,200,function() 
            self.m_hall_chat_mask_btn:setOnClick(self, function()
                self.m_chessMatchItem:cancelChessMatch();
            end);
            self.m_hall_chat_mask_btn_txt:setText("取消约战");
            self.m_hall_chat_mask_tip:setText("(等待应战)");
            self.m_hall_chat_mask_user_tip:setVisible(false);
        end);
        self.m_hall_chat_room_mask_status = 1;
    else
        self.m_hall_chat_mask_btn:setOnClick(self, function() 
            self.m_chessMatchItem:creatorEntryChessRoom();
            EffectAnim.scrollUp(self,self.m_hall_chat_room_mask,200,function() 
                ChessDialogManager.dismissAllDialog();
            end);
            delete(HallChatDialog.schedule_repeat_anim);
            HallChatDialog.schedule_repeat_anim = nil;
        end);
        HallChatDialog.schedule_repeat_anim = ToolKit.schedule_repeat_time(self,function(self,a,b,c,cur_loopnum) 
            local s = 3 - cur_loopnum;
            self.m_hall_chat_mask_btn_txt:setText("入场("..s.."s)");
            if s <= 0 then
                EffectAnim.scrollUp(self,self.m_hall_chat_room_mask,200,function() 
                    self.m_chessMatchItem:creatorEntryChessRoom();
                end);
            end;
        end,1000,3);
        self.m_hall_chat_mask_btn_txt:setText("入场(3s)");
        self.m_hall_chat_mask_tip:setText("(已应战)");
        self.m_hall_chat_mask_user_tip:setVisible(true);
        self.m_hall_chat_mask_user_tip:setText(self.m_chessMatchItem:getName().." 已经应战");
        self.m_hall_chat_room_mask_status = 2;      
    end;
end;

HallChatDialog.setCurChessMatchItem = function(self,item)
    self.m_chessMatchItem = item;
end;
------------------------------------------------------------------------------------------
-----------------------------聊天室（大师/同城/世界/私聊）--------------------------------
------------------------------------------------------------------------------------------
-- 重置聊天室消息
HallChatDialog.resetChatRoomView = function(self)
    delete(self.m_chat_room_scroll_msg_view);
    self.m_chat_room_scroll_msg_view = nil;
    local contentW,contentH = self.m_chat_room_view_content_view:getSize();
    self.m_chat_room_scroll_msg_view = new(ScrollView2,20,20,contentW,contentH-20,true);
    self.m_chat_room_scroll_msg_view:setOnScroll(self, self.chatRoomScroll);
    self.m_chat_room_view_content_view:addChild(self.m_chat_room_scroll_msg_view);
    if self.m_chat_room_item then
        local historyMsg;
        if self.m_current_view == HallChatDialog.DASHI_CHAT or
           self.m_current_view == HallChatDialog.CITY_CHAT or
           self.m_current_view == HallChatDialog.WORLD_CHAT or
           self.m_current_view == HallChatDialog.NEWPLAYER_CHAT or
           self.m_current_view == HallChatDialog.CHESSCLUB_CHAT then
            historyMsg = ChatRoomData.getInstance():getHistoryMsg(self.m_chat_room_item:getRoomId());
            self:loadLocalHistoryMsgs(historyMsg);
            UserInfo.getInstance():setCurrentChatRoomId(self.m_chat_room_item:getRoomId());
            if not self.hasShowChatRoomInfo then -- 已经显示房间信息了，目前用在同城房间内定位之后，重新加载房间信息
                self:playMainChat2ChatRoomAnim();
            end;
        elseif self.m_current_view == HallChatDialog.COMMON_CHAT then
            historyMsg = FriendsData.getInstance():getChatDataByNum(tonumber(self.m_chat_room_item:getUid()),15);
            self:loadLocalHistoryMsgs(historyMsg);
            --清除未读消息  ???
            self:resetUnreadMsgNum();
            ToolKit.schedule_once(self,self.resetUnreadMsgNum,300,self.m_chat_room_item:getUid());
            if self.m_common_room_from == 1 then -- 1：来自聊天主界面
                ToolKit.schedule_once(self,EffectAnim.leftOutRightIn,300,self.m_main_chat_view,self.m_chat_room_view,HallChatDialog.LORI_ANIM_TIME,
                function() self.m_hall_chat_bg:setPickable(true); end);
            elseif self.m_common_room_from == 2 then -- 1：来自创建会话
                ToolKit.schedule_once(self,EffectAnim.leftOutRightIn,300,self.m_create_chat_view,self.m_chat_room_view,HallChatDialog.LORI_ANIM_TIME,
                function() self.m_hall_chat_bg:setPickable(true); end);
            end;
        end;
        self.m_chat_room_scroll_msg_view:gotoBottom();
    end
end

HallChatDialog.playMainChat2ChatRoomAnim = function(self)
    EffectAnim.leftOutRightIn(self,self.m_main_chat_view,self.m_chat_room_view,HallChatDialog.LORI_ANIM_TIME,function() 
        self.m_hall_chat_bg:setPickable(true); 
        self.hasShowChatRoomInfo = true;
        if self.m_chat_room_scroll_msg_view then
            local child = self.m_chat_room_scroll_msg_view:getChildren();
            local time;
            if #child > 0 then
                time = self.m_chat_room_scroll_msg_view:getChildren()[#child]:getMsgTime() + 1;
            else
                time = 0;
            end;
            self:toGetHistoryMsg(time,self.m_chat_room_item:getRoomId());
            self:toGetChessMatchMsgNum(self.m_chat_room_item:getRoomId());
        end;
    end);   
end;

HallChatDialog.chatRoomScroll = function(self, offset)
    if tonumber(offset) and offset > 75 and not self.m_chat_room_loading then
        self.m_chat_room_loading = true;
        Loading.play(self.m_chat_room_view_content_view,0,0,kAlignTop,function()
            self.m_chat_room_loading = false;
        end,self);
        ToolKit.schedule_once(self,function() 
            if self.m_current_view == HallChatDialog.DASHI_CHAT or
               self.m_current_view == HallChatDialog.CITY_CHAT or
               self.m_current_view == HallChatDialog.WORLD_CHAT or
               self.m_current_view == HallChatDialog.NEWPLAYER_CHAT then
                local time = self.m_chat_room_scroll_msg_view:getChildren()[1]:getMsgTime() - 1;
                self:toGetUpHistoryMsg(time,self.m_chat_room_item:getRoomId());
            elseif self.m_current_view == HallChatDialog.COMMON_CHAT then
                local time = self.m_chat_room_scroll_msg_view:getChildren()[1]:getMsgTime() - 1;
                historyMsg = FriendsData.getInstance():getChatDataByTime(tonumber(self.m_chat_room_item:getUid()),time);
                self:loadHistoryMsgsBytime(historyMsg); 
            end;
        end,1000);
    end;
end;

--更新
HallChatDialog.chatInviteViewScroll = function(self, offset)
    if tonumber(offset) and offset > 75 and not self.m_chat_invite_loading then
        self.m_chat_invite_loading = true;
        Loading.play(self.m_chat_invite_view_content_view,0,0,kAlignTop);
        ToolKit.schedule_once(self,function() 
        if self.m_current_view == HallChatDialog.DASHI_CHAT or
           self.m_current_view == HallChatDialog.CITY_CHAT or
           self.m_current_view == HallChatDialog.WORLD_CHAT or
           self.m_current_view == HallChatDialog.NEWPLAYER_CHAT or
           self.m_current_view == HallChatDialog.CHESSCLUB_CHAT  then
            if #self.m_chat_invite_scroll_msg_view:getChildren() > 0 then
                local time = self.m_chat_invite_scroll_msg_view:getChildren()[1]:getMsgTime() - 1;
                self:toGetChessMatchMsg(time,self.m_chat_room_item:getRoomId());
            end;
        end;    
        end,1000);
    end;
end;

HallChatDialog.createRoomMsg = function(self,data)
    local msg = {};
    if self.m_current_view == HallChatDialog.DASHI_CHAT or
        self.m_current_view == HallChatDialog.CITY_CHAT or
        self.m_current_view == HallChatDialog.WORLD_CHAT or
        self.m_current_view == HallChatDialog.NEWPLAYER_CHAT or
        self.m_current_view == HallChatDialog.CHESSCLUB_CHAT  then
        msg.uid = data.uid;
    elseif self.m_current_view == HallChatDialog.COMMON_CHAT then
        msg.uid = data.send_uid;
    end;
    if msg.uid then
        if msg.uid == UserInfo.getInstance():getUid() then
            msg.name = UserInfo.getInstance():getName();
        else
            local userData = FriendsData.getInstance():getUserData(msg.uid)
            msg.name = userData and userData.mnick;
        end;
        if tonumber(data.msgtype) == 2 then
            msg.name = data.name;
        end;
        msg.msg = data.msg;
        msg.time = data.time
        msg.msg_id = data.msg_id or "";
        msg.room_id = data.room_id or "";
        msg.msgtype = data.msgtype or "1";
        msg.other = data.other or "";
        local item = self:addChatRoomMsg(msg);
        return item, msg.time;
    end

end;

-- 加载本地历史消息
HallChatDialog.loadLocalHistoryMsgs = function(self, historyMsg)
    if historyMsg and #historyMsg > 0 then
        local last_time = 0;
        for i,v in ipairs(historyMsg) do
            local _,time = self:createRoomMsg(v);
            last_time = time;
        end
        return last_time + 1;
    end
end;

-- 向上拉取历史消息返回
HallChatDialog.loadHistoryMsgsBytime = function(self,historyMsg)
    if historyMsg and #historyMsg > 0 then
        local totalOffset = 0;
        for i,v in ipairs(historyMsg) do
            local tempItem,time = self:createRoomMsg(v);
            if tempItem then
                self.m_chat_room_scroll_msg_view:childToPos(tempItem,i);
                local w, h = tempItem:getSize();
                totalOffset = totalOffset + h;
            end;
        end;
        self.m_chat_room_scroll_msg_view:gotoOffset(-totalOffset+80);
    end;
    self.m_chat_room_loading = false;
    Loading.deleteAll();  
end;

-- 加载聊天室约战历史消息
HallChatDialog.loadChatInviteHistoryMsgs = function(self, historyMsg)
    if historyMsg and #historyMsg > 0 then
        local totalOffset = 0;
        local count = #(self.m_chat_invite_scroll_msg_view:getChildren())
        for i,v in ipairs(historyMsg) do
            if i > count then 
                --添加新数据
                local tempItem = self:addChatRoomInviteMsg(v);
                if tempItem then
                    self.m_chat_invite_scroll_msg_view:childToPos(tempItem,i);
                    local w, h = tempItem:getSize();
                    totalOffset = totalOffset + h;
                end;
            else
                --更新原有的数据
                self:updateChatRoomInviteMsg(v,i)
            end 
        end;
        self.m_chat_invite_scroll_msg_view:gotoOffset(-totalOffset+80);
        self.m_chat_invite_loading = false;
        Loading.deleteAll();  
    end;
end;

-- 从time时间点向上拉取历史消息
HallChatDialog.toGetUpHistoryMsg = function(self,time,roomId)
    local info = {};
    info.room_id = roomId;
    info.last_msg_time = time;
    info.items = 15;
    info.version = kLuaVersionCode;
    info.uid = UserInfo.getInstance():getUid();
    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_GET_HISTORY_MSG_NEW,info);
end;

-- 从time时间点向下拉取历史消息
HallChatDialog.toGetHistoryMsg = function(self,time,roomId)
    local info = {};
    info.uid = UserInfo.getInstance():getUid();
    info.room_id = roomId;
    info.last_msg_time = time or 0;
    info.entry_room_time = os.time() + 10; -- +10和server时间同步;
    info.version = kLuaVersionCode;
    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_GET_HISTORY_MSG,info);
end

-- 获取聊天室约战历史消息
HallChatDialog.toGetChessMatchMsg = function(self,time,roomId)
    local info = {};
    info.uid = UserInfo.getInstance():getUid();
    info.room_id = roomId;
    info.last_msg_time = time;
    info.items = 5;
    info.version = kLuaVersionCode;
    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_GET_CHESS_MATCH_MSG,info);
end;

HallChatDialog.toGetChessMatchMsgNum = function(self,roomId)
    local info = {};
    info.room_id = roomId;
    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_GET_CHESS_MATCH_MSG_NUM,info);    
end;

HallChatDialog.addChatRoomMsg = function(self,msgData)
	if not msgData.msg or msgData.msg == "" then
		return
	end
	local data = {};
	data.mnick = GameString.convert2UTF8(msgData.name);
	data.msg = GameString.convert2UTF8(msgData.msg);
    data.send_uid = msgData.uid;
    data.time = msgData.time;
    data.msg_id = msgData.msg_id or "";
    data.room_id = msgData.room_id or "";
    data.msgtype = msgData.msgtype or "";
    data.other = json.decode(msgData.other) or {};
    local num = #(self.m_chat_room_scroll_msg_view:getChildren());
    if num == 0 then
        data.isShowTime = true;
    else
        local item = self.m_chat_room_scroll_msg_view:getChildren()[num]; 
        if ToolKit.isSecondDay(data.time) then
            data.isShowTime = true;
        else
            if ToolKit.isInTenMinute(data.time, item:getMsgTime()) then
                data.isShowTime = false;
            else
                data.isShowTime = true;
            end;
        end;
    end
	local item = self:getCommonRoomChatItem(data);
    if not item then return end;
    if tonumber(data.msgtype) == 2 or tonumber(data.msgtype) == 3 then
        self.m_chatroom_msg_list[data.msg_id..""] = item;
    end;
    self.m_chat_room_scroll_msg_view:addChild(item);
    return item;
end

--[Comment]
-- 活动好友聊天item
function HallChatDialog:getCommonRoomChatItem(data)
    local event,msgData = SchemesProxy.analyzeSchemesStr(data.msg);
    if type(event) == "function" then
        local params = {
            title = "";
            content = "";
            icon_img = "";
        }
        if msgData.method == "gotoCustomEndgateRoom" then
            params.title = "";
            params.content = "#s30#c323232邀您挑战街边残局#n";
            params.icon_img = "common/board_03.png";
        elseif msgData.method == "showSociatyInfoDialog" then
            params.title = ""
            params.content = string.format("大侠，诚意邀请您加入象棋棋社%s，id:%s",msgData.name or "",msgData.sociaty_id or 0);
            params.icon_img = (ChesssociatyModuleConstant.sociaty_icon[tonumber(msgData.mark)] or ChesssociatyModuleConstant.sociaty_icon[1]).file;
        elseif msgData.method == "gotoPrivateRoom" then
            params.title = "呔!某家在私人房,尔等速速来战!";
            params.content = "听闻尔等棋艺甚是精湛,速速前来对弈,某家要与尔等大战三百回合!尔等敢应战否？！";
            params.icon_img = "common/board_03.png";
        else
	        local item = new(HallChatRoomItem,data);
            return item;
        end
        params.msgData = msgData
--        if self:isOverdue(data) then
--            return;
--        end;
	    local item = new(HallChatRoomSchemesItem,self,data,event,params);
        return item;
    else 
        local msgType = data.msgtype;
        if msgType then
            -- 聊天类型：1(普通聊天);2(一对一约战聊天)3(多人约战聊天)...
            if tonumber(msgType) == 1 then  
                return new(HallChatRoomItem, data);
            elseif tonumber(msgType) == 2 or tonumber(msgType) == 3 then
                return new(HallChatRoomInviteItem, data,self);
            else
                return new(HallChatRoomItem, data);
            end;
        else
            return new(HallChatRoomItem, data);
        end;
    end
end
--添加新的友谊战item
HallChatDialog.addChatRoomInviteMsg = function(self,msgData)
	if not msgData.msg or msgData.msg == "" then
		return
	end
	local data = {};
	data.mnick = GameString.convert2UTF8(msgData.name);
	data.msg = GameString.convert2UTF8(msgData.msg);
    data.send_uid = msgData.uid;
    data.time = msgData.time;
    data.msg_id = msgData.msg_id or "";
    data.room_id = msgData.room_id or "";
    data.msgtype = msgData.msgtype or "";
    data.other = json.decode(msgData.other) or {};
	local item = self:getCommonRoomChatItem(data);
    if not item then return end;
    self.m_chatroom_invite_msg_list[data.msg_id..""] = item;
    self.m_chat_invite_scroll_msg_view:addChild(item);
    return item;    
end;

--更新友谊战item
function HallChatDialog.updateChatRoomInviteMsg(self,msgData,index)
    if not msgData.msg or msgData.msg == "" then
		return
	end
	local data = {};
	data.mnick = GameString.convert2UTF8(msgData.name);
	data.msg = GameString.convert2UTF8(msgData.msg);
    data.send_uid = msgData.uid;
    data.time = msgData.time;
    data.msg_id = msgData.msg_id or "";
    data.room_id = msgData.room_id or "";
    data.msgtype = msgData.msgtype or "";
    data.other = json.decode(msgData.other) or {};
    local item = self.m_chat_invite_scroll_msg_view:getChildren()[index]
    item:updateItemWithData(data)
    return item
end

-- 从mainChat到createChatView
HallChatDialog.createChatView = function(self)
    self.m_hall_chat_bg:setPickable(false);
    self.m_current_view = HallChatDialog.CREATE_CHAT;
    self:loadCreateChatView();
    ToolKit.schedule_once(self,EffectAnim.leftOutRightIn,300,self.m_main_chat_view,self.m_create_chat_view,HallChatDialog.LORI_ANIM_TIME,function()
        self.m_hall_chat_bg:setPickable(true);
    end);
end;

-- 加载创建会话列表
HallChatDialog.loadCreateChatView = function(self)
    if self.m_create_chat_scroll_view and #self.m_create_chat_scroll_view:getChildren() > 0 then
        self.m_create_chat_scroll_view:removeAllChildren(true);
        self.m_create_chat_content_view:removeChild(self.m_create_chat_scroll_view,true);
    end;
    self.m_friendUids = FriendsData.getInstance():getFrendsListData();
    if not self.m_friendUids or #self.m_friendUids == 0 then
        return;
    end;
    local contentW,contentH = self.m_create_chat_content_view:getSize();
    self.m_create_chat_scroll_view = new(ScrollView2,0,0,contentW,contentH,true);
    self.m_create_chat_items = {};
    for index = 1, #self.m_friendUids do
        self.m_create_chat_items[index] = new(HallCreateChatDialogItem,self.m_friendUids[index],index,self);
        self.m_create_chat_scroll_view:addChild(self.m_create_chat_items[index]);
    end;
    self.m_create_chat_content_view:addChild(self.m_create_chat_scroll_view);
end;

-- 搜索好友
HallChatDialog.searchFriends = function(self)
    local usr = {};
    local friendName = self.m_create_chat_search_edit:getText();
    if friendName == "" then
        self:showCreateChatFriends(usr,"请您输入好友昵称");
    else
        local friendsUids = FriendsData.getInstance():getFrendsListData();
        local userDatas = FriendsData.getInstance():getUserData(friendsUids);
        if userDatas then
            for index =1 , #userDatas do
                if string.find(GameString.convert2UTF8(userDatas[index].mnick),friendName) then
                    table.insert(usr,tonumber(userDatas[index].mid));
                end;
            end;
        end;
        self:showCreateChatFriends(usr,"很抱歉，没有找到好友");
    end;
end;

HallChatDialog.showCreateChatFriends = function(self, data,msg)
    if #data == 0 then
        ChessToastManager.getInstance():show(GameString.convert2UTF8(msg),2000);
        self:loadCreateChatView();
    else
        if self.m_create_chat_scroll_view and #self.m_create_chat_scroll_view:getChildren() > 0 then
            self.m_create_chat_scroll_view:removeAllChildren(true);
            self.m_create_chat_content_view:removeChild(self.m_create_chat_scroll_view,true);
        end;
        local contentW,contentH = self.m_create_chat_content_view:getSize();
        self.m_create_chat_scroll_view = new(ScrollView2,0,0,contentW,contentH,true);
        self.m_create_chat_items = {};
        for index = 1, #data do
            self.m_create_chat_items[index] = new(HallCreateChatDialogItem,data[index],index,self);
            self.m_create_chat_scroll_view:addChild(self.m_create_chat_items[index]);
        end;
        self.m_create_chat_content_view:addChild(self.m_create_chat_scroll_view);
    end;
end;

-- 创建会话返回mainChat
HallChatDialog.createChatBackToMainChat = function(self)
    self.m_current_view = HallChatDialog.MAIN_CHAT;
    EffectAnim.leftInRightOut(self,self.m_main_chat_view,self.m_create_chat_view,HallChatDialog.LIRO_ANIM_TIME,self.loadUnreadMsgNum);
end


HallChatDialog.onCheckSociaty = function(self, data)
end;

-- 更新聊天室主界面list
HallChatDialog.updateChatRoomList = function(self)
    local chatRoomList = UserInfo.getInstance():getChatRoomList();
    if not chatRoomList then return end;
    if not self.m_main_chat_room_list then return end;
    for i = 1,#chatRoomList do
        for j = 1,#self.m_main_chat_room_list do
            if chatRoomList[i].type == self.m_main_chat_room_list[j].type then
                if chatRoomList[i].type == "horn" then
                elseif chatRoomList[i].type == "master" then 
                elseif chatRoomList[i].type == "comm" then 
                elseif chatRoomList[i].type == "city" then 
                elseif chatRoomList[i].type == "new" then 
                elseif chatRoomList[i].type == "guild" then 
                    if chatRoomList[i].id ~= self.m_main_chat_room_list[j].id then
                        self.m_main_chat_room_list[j].id = chatRoomList[i].id;
                        self.m_chat_room_items[j]:updateMainChatRoomItem(chatRoomList[i]);
                    end;
                    if chatRoomList[i].type == "guild" then 
                        self.m_chat_room_items[j]:updateMainChatRoomName(chatRoomList[i].name);
                    end
                else
                    
                end;
            end;
        end;
    end;
end;

-- 删除聊天室房间内消息list
HallChatDialog.deleteChatRoomMsgList = function(self,data)
    local otherdata = json.decode(data.other);
    local remove_id = otherdata.rm_msgid;
    if tonumber(remove_id) == 0 then return end;
    local child = self.m_chatroom_msg_list[remove_id..""];
    if not child then return end;
    self.m_chat_room_scroll_msg_view:removeChild(child,true);
    local originX,originY = self.m_chat_room_scroll_msg_view:getMainNodeWH();
    if self.m_chat_room_scroll_msg_view:isScrollToBottom() then
        self.m_chat_room_scroll_msg_view:gotoBottom();
    else
        self.m_chat_room_scroll_msg_view:gotoOffset(originY);
    end;
    self.m_chat_room_scroll_msg_view:updateScrollView();
end;

-- 删除聊天室房间内约战消息list
HallChatDialog.deleteChatRoomInviteMsgList = function(self,data)
    local otherdata = json.decode(data.other);
    local remove_id = otherdata.rm_msgid;
    if tonumber(remove_id) == 0 then return end;
    local child = self.m_chatroom_invite_msg_list[remove_id..""];
    --同时删除数据
    self.mWarData:deleteItem(remove_id)
    if not self.m_chat_invite_scroll_msg_view then return end;
    if not child then return end;
    self.m_chat_invite_scroll_msg_view:removeChild(child,true);
    local originX,originY = self.m_chat_invite_scroll_msg_view:getMainNodeWH();
    if self.m_chat_invite_scroll_msg_view:isScrollToBottom() then
        self.m_chat_invite_scroll_msg_view:gotoBottom();
    else
        self.m_chat_invite_scroll_msg_view:gotoOffset(originY);
    end;
    self.m_chat_invite_scroll_msg_view:updateScrollView();
end;

HallChatDialog.reloadCityChatRoomInfo = function(self, data)
    self.m_locating = false;
    if data and next(data) and data.province and data.city then
        local province = data.province:get_value();
        local city = data.city:get_value();
        local provinceCode = 0;
        local provinceName = "";
        local provinceData = CityData.getInstance():getProvinceData();
        if provinceData and #provinceData > 0 then
            for i = 1,#provinceData do
                if string.find(province,provinceData[i].name) then
                    provinceCode = provinceData[i].code;
                    provinceName = provinceData[i].name;
                    break;
                elseif i == #provinceData then
                    provinceCode = provinceData[i].code;
                    provinceName = provinceData[i].name;
                    break;
                end;
            end;
            UserInfo.getInstance():setProvinceCode(provinceCode);
            UserInfo.getInstance():setProvinceName(provinceName);
        end;
        -- 定位成功
        ChessToastManager.getInstance():showSingle("定位成功:"..province..city);
        -- 刷新同城聊天室
        if self.m_current_view == HallChatDialog.CITY_CHAT then
            self:refreshCityRoomInfo();
        else
            self:updateMainChatItem();
        end;
    else
        -- 定位失败，弹选城市弹窗
        if self.m_current_view == HallChatDialog.CITY_CHAT then
            if not self.m_city_locate_dialog then
                self.m_city_locate_dialog = new(CityLocatePopDialog);
                self.m_city_locate_dialog:setDismissCallBack(self,function() 
                    self:refreshCityRoomInfo();
                end);
            end;
            self.m_city_locate_dialog:setLocateBtnEvent(self.getCurrentLocateInfo,self);
            self.m_city_locate_dialog:show(self,true);            
        end;
    end;
end;

HallChatDialog.refreshCityRoomInfo = function(self)
    if UserInfo.getInstance():getProvinceCode() ~= 0 and UserInfo.getInstance():getProvinceName() then
        self.m_main_chat_item:setCityCode(UserInfo.getInstance():getProvinceCode());
        self.m_main_chat_item:setCityName(UserInfo.getInstance():getProvinceName());
        self.m_room:entryChatRoom(UserInfo.getInstance():getProvinceCode());
        -- 隐藏定位
        self.m_chat_room_view_locate_view:setVisible(false);
        -- 显示手动选择地区按钮
        self.m_chat_room_select_city_btn:setVisible(true);
    end;
end;

-- 是否添加新的约战item
HallChatDialog.isAddChessMatchItem = function(self,data)
    local otherdata = json.decode(data.other);
    local status = otherdata.status;
    local c_uid = otherdata.c_uid;
    local a_uid = otherdata.a_uid
    if tonumber(status) == 2 then
        if a_uid == UserInfo.getInstance():getUid() then
            self:acceptorEntryRoom(data);
            return true;
        end;
    elseif tonumber(status) == 3 then -- 3：对局中(自己接到消息，不显示不保存)
        if c_uid == UserInfo.getInstance():getUid() then
            self:creatorEntryRoom(data);
            return true;
        end;
    elseif tonumber(status) == 6 then -- 6：取消约战
        ChessToastManager.getInstance():showSingle((data.name or "").." 取消约战",1600);
        if self.m_hall_chat_room_mask:getVisible() == false then return true end;
        if c_uid == UserInfo.getInstance():getUid() then
            EffectAnim.scrollUp(self,self.m_hall_chat_room_mask,200);
        end;
        return true;
    end;
end

-- 挑战者进入房间
HallChatDialog.acceptorEntryRoom = function(self,data)
    local otherdata = json.decode(data.other);
    UserInfo.getInstance():setCustomRoomType(2);
    UserInfo.getInstance():setCustomRoomID(otherdata.tid);
    UserInfo.getInstance():setCurrentChatRoomId(data.room_id);
    UserInfo.getInstance():setCurrentChatRoomMsgId(data.msg_id);
    RoomProxy.getInstance():setTid(otherdata.tid);
    RoomProxy.getInstance():setSelfRoomPassword(otherdata.pwd)  
    ChessDialogManager.dismissAllDialog(); 
    ToolKit.schedule_once(self,function() 
        RoomProxy.getInstance():gotoPrivateRoom(false)     
    end,100);  
end;

-- 创建者进入房间
HallChatDialog.creatorEntryRoom = function(self,data)
    UserInfo.getInstance():setCurrentChatRoomId(data.room_id);
    UserInfo.getInstance():setCurrentChatRoomMsgId(data.msg_id);
    local otherdata = json.decode(data.other);
    local customData = UserInfo.getInstance():getCustomRoomData();
    if #customData == 0 then -- 如果此时重新启动过(#customData==0)，需重新设置私人房数据
        local roomData = RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_PRIVATE_ROOM);
        local roompwdStr = "boyaa_chess";
        local roomnameStr = "友谊赛";
        local info = {};
        customData.level = roomData.level;
        customData.uid = UserInfo.getInstance():getUid();
        customData.name = roomnameStr;
        customData.password  = roompwdStr;
        customData.basechip  = otherdata.base;
        customData.round_time= otherdata.rd_t * 60;
        customData.step_time= otherdata.step_t;
        customData.sec_time= otherdata.sec_t;
        customData.target_uid = 0;    
        RoomProxy.getInstance():setSelfRoomPassword(roompwdStr);
        RoomProxy.getInstance():setSelfRoomNameStr(roomnameStr);
        RoomProxy.getInstance():setTid(otherdata.tid);
        UserInfo.getInstance():setCustomRoomID(otherdata.tid);
    end;
    customData.target_uid = tonumber(otherdata.a_uid);   
    UserInfo.getInstance():setCustomRoomData(customData);
    UserInfo.getInstance():setCustomRoomType(2);  
    ChessDialogManager.dismissAllDialog(); 
    ToolKit.schedule_once(self,function() 
        RoomProxy.getInstance():gotoPrivateRoom(true) 
    end,100);     

end;

-- chessClubList返回mainChat
HallChatDialog.chessClubListBackToMainChat = function(self)
    self.m_current_view = HallChatDialog.MAIN_CHAT;
    EffectAnim.fadeInAndOut(self,self.m_add_btn,nil,HallChatDialog.FADEIN_ANIM_TIME);
    EffectAnim.leftInRightOut(self,self.m_main_chat_view,self.m_sociaty_view,HallChatDialog.LIRO_ANIM_TIME,self.loadUnreadMsgNum);
end

-- 棋社返回棋社聊天室
HallChatDialog.chessClubListBackToSociatyChat = function(self)
    local data = UserInfo.getInstance():getUserSociatyData()
    if not data or next(data) == nil then 
        self:chessClubListBackToMainChat()
    else
        self.m_current_view = HallChatDialog.CHESSCLUB_CHAT;
        self.m_room:entryChatRoom(self.m_main_chat_item:getRoomId());
        EffectAnim.fadeInAndOut(self,self.m_chat_room_member_btn,nil,HallChatDialog.FADEIN_ANIM_TIME);
        EffectAnim.leftInRightOut(self,self.m_chat_room_view,self.m_sociaty_view,HallChatDialog.LIRO_ANIM_TIME)
    end
end

-- 聊天返回mainChat
HallChatDialog.chatRoomBackToMainChat = function(self)
    if self.m_current_view == HallChatDialog.DASHI_CHAT or
       self.m_current_view == HallChatDialog.CITY_CHAT or
       self.m_current_view == HallChatDialog.WORLD_CHAT or
       self.m_current_view == HallChatDialog.NEWPLAYER_CHAT or
       self.m_current_view == HallChatDialog.CHESSCLUB_CHAT  then
        self:leaveChatRoom(self.m_chat_room_item:getRoomId());
    end;
    self:resetChatDialog();
    self:addLatestMsgToMainChat();
    EffectAnim.leftInRightOut(self,self.m_main_chat_view,self.m_chat_room_view,HallChatDialog.LIRO_ANIM_TIME,self.loadUnreadMsgNum);
    self.hasShowChatRoomInfo = false;
    self.m_chat_room_view_locate_view:setVisible(false);
    self.m_chat_room_select_city_btn:setVisible(false);
end

-- 友谊战列表返回房间
HallChatDialog.chatInviteBackToMainChat = function(self)
    EffectAnim.leftInRightOut(self,self.m_chat_room_view,self.m_chat_invite_view,HallChatDialog.LIRO_ANIM_TIME);
    if true then

    end;
end;

-- 小喇叭聊天返回mainChat
HallChatDialog.hornRoomBackToMainChat = function(self)
    self:loadLatestNotice()
    if self.mSystemNotice then
        self.mSystemNotice:switchScene()
    end
    self.m_current_view = HallChatDialog.MAIN_CHAT;
    EffectAnim.fadeInAndOut(self,self.m_add_btn,nil,HallChatDialog.FADEIN_ANIM_TIME);
    EffectAnim.leftInRightOut(self,self.m_main_chat_view,self.m_horn_room_view,HallChatDialog.LIRO_ANIM_TIME,self.loadUnreadMsgNum);
end

HallChatDialog.leaveChatRoom = function(self, roomId)
	local info = {};
    if not roomId or roomId == "" then return end;
	info.room_id = roomId;
	info.uid = UserInfo.getInstance():getUid();
    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_LEAVE_ROOM,info);
end;

-- 普通聊天返回mainChat
HallChatDialog.commonRoomBack = function(self)
    if self.m_common_room_from == 1 then
        self.m_current_view = HallChatDialog.MAIN_CHAT;
        EffectAnim.fadeInAndOut(self,self.m_add_btn, self.m_common_room_back_btn,HallChatDialog.FADEIN_ANIM_TIME);
        EffectAnim.leftInRightOut(self,self.m_main_chat_view,self.m_common_room_view,HallChatDialog.LIRO_ANIM_TIME,self.loadUnreadMsgNum);
    elseif self.m_common_room_from == 2 then
        self.m_current_view = HallChatDialog.CREATE_CHAT;
        EffectAnim.fadeInAndOut(self,nil, self.m_common_room_back_btn,HallChatDialog.FADEIN_ANIM_TIME);
        EffectAnim.leftInRightOut(self,self.m_create_chat_view,self.m_common_room_view,HallChatDialog.LIRO_ANIM_TIME);
    end;
end

HallChatDialog.getCurrentLocateInfo = function(self)
    local localStr = nil;--GameCacheData.getInstance():getString(GameCacheData.LOCATE_LOCATION_INFO);
    if not localStr or localStr == "" and not self.m_locating then
        self.m_locating = true;
        call_native(kGetLocationInfo);
    end;  
    ChessToastManager.getInstance():showSingle("正在获取位置...",3000);
end;

HallChatDialog.showCityLocateDlg = function(self)
    if not self.m_city_locate_dialog then
        self.m_city_locate_dialog = new(CityLocatePopDialog);
        self.m_city_locate_dialog:setDismissCallBack(self,function() 
            self:refreshCityRoomInfo();
        end);
    end;
    self.m_city_locate_dialog:show(self,false);      
end;

---------------------------- send Msg ------------------------------
-- 发送消息
HallChatDialog.sendMsg = function(self,msgdata)
    if kDebug and false then -- 自动发送(自测时使用)
        local anim = new(AnimInt, kAnimRepeat, 0,1,500,0);
        if anim then
            anim:setEvent(nil, function(a,b,c,repeat_or_loop_num) 
                local msg = msgdata.msg;
                msgdata.msg = msgdata.msg .. repeat_or_loop_num;
                if self.m_current_view == HallChatDialog.DASHI_CHAT or
                   self.m_current_view == HallChatDialog.CITY_CHAT or
                   self.m_current_view == HallChatDialog.WORLD_CHAT or
                   self.m_current_view == HallChatDialog.NEWPLAYER_CHAT or
                   self.m_current_view == HallChatDialog.CHESSCLUB_CHAT  then
                    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_USER_CHAT_MSG,msgdata);
                elseif self.m_current_view == HallChatDialog.COMMON_CHAT then
                    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_CHAT_MSG2,msgdata);
                end;
                msgdata.msg = msg;
                if repeat_or_loop_num == 100 then
                    delete(anim);
                    anim = nil;
                end;
            end);
        end;    
    else 
        if self.m_current_view == HallChatDialog.DASHI_CHAT or
            self.m_current_view == HallChatDialog.CITY_CHAT or
            self.m_current_view == HallChatDialog.WORLD_CHAT or
            self.m_current_view == HallChatDialog.NEWPLAYER_CHAT or
            self.m_current_view == HallChatDialog.CHESSCLUB_CHAT  then
            OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_USER_CHAT_MSG,msgdata);
        elseif self.m_current_view == HallChatDialog.COMMON_CHAT then
            OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_CHAT_MSG2,msgdata);
        end;
    end;
end;

HallChatDialog.isCanSendMsg = function(self)
    if self.m_current_view == HallChatDialog.DASHI_CHAT then
        if UserInfo.getInstance():getScore() < tonumber(self.m_main_chat_item:getRoomMinScore()) then
            ChessToastManager.getInstance():showSingle("在大师聊天室发言需要积分超过1700,先看看大师们交流吧！",2000); 
            return;
        end
    elseif self.m_current_view == HallChatDialog.NEWPLAYER_CHAT then
        if os.time() - UserInfo.getInstance():getRegisterTime() > 30*24*60*60 then -- 30天
            ChessToastManager.getInstance():showSingle("本频道为新人专区，请勿发布消息",2000); 
            return;
        end;
    end;
    return true;
end;

-- 发送消息
HallChatDialog.sendChatRoomMsg = function(self)
    if not self:isCanSendMsg() then return end;
	self.m_chat_room_msg = self.m_chat_room_bottom_send_edit:getText() or "";
    if self.m_chat_room_msg == "" then
        ChessToastManager.getInstance():showSingle("消息不能为空！",800); 
        return;
    end;
    -- 30秒内限制条数
    if not self.m_chat_room_last_msg_time then 
        self.m_chat_room_last_msg_time = os.time();
    end;
    if tonumber(os.time() - self.m_chat_room_last_msg_time) <= 30 then
        self.m_chat_room_remain_items = (self.m_chat_room_remain_items or UserInfo.getInstance():getChatRoomItemCountIn30s()) - 1;
        if self.m_chat_room_remain_items < 0 then
            ChessToastManager.getInstance():showSingle("大侠，稍作休息再继续聊吧",1000); 
            return;
        end;
    else
        self.m_chat_room_last_msg_time = os.time();
        self.m_chat_room_last_msg_time = UserInfo.getInstance():getChatRoomItemCountIn30s();
    end;

    self.m_chat_room_msg = self:return140Str(self.m_chat_room_msg);
    local msgdata = {};
    if self.m_current_view == HallChatDialog.DASHI_CHAT or
       self.m_current_view == HallChatDialog.CITY_CHAT or
       self.m_current_view == HallChatDialog.WORLD_CHAT or
       self.m_current_view == HallChatDialog.NEWPLAYER_CHAT or
       self.m_current_view == HallChatDialog.CHESSCLUB_CHAT  then
	    msgdata.room_id = self.m_chat_room_item:getRoomId();
	    msgdata.msg = self.m_chat_room_msg;
	    msgdata.name = UserInfo.getInstance():getName();
	    msgdata.uid = UserInfo.getInstance():getUid();
        msgdata.msg_type = 1;
        msgdata.other = "";
    elseif self.m_current_view == HallChatDialog.COMMON_CHAT then
        msgdata.msg = self.m_chat_room_msg;
        msgdata.target_uid = tonumber(self.m_chat_room_item:getUid());
        msgdata.isNew = 1;
    end;
    self:sendMsg(msgdata);
    self.m_chat_room_bottom_send_edit:setText(nil);
    self.m_chat_room_scroll_msg_view:gotoBottom();
    self:openMoreAction(false);

end;

HallChatDialog.return140Str = function(self, msg)
    local strMsg = msg;
    local lens = string.lenutf8(GameString.convert2UTF8(msg) or "");    
    if lens > 140 then--限制140字
        strMsg = GameString.convert2UTF8(string.subutf8(msg,1,140));
    end;
    return strMsg;
end;

---------------------------- recv Msg ------------------------------
-- 向下拉取历史消息
HallChatDialog.onRecvServerUnreadMsg = function(self, packetInfo)
    local total_num = packetInfo.total_count;
    local roomId = packetInfo.room_id;
    local page_num = packetInfo.page_num;
    local curr_page = packetInfo.curr_page;
    local item_num = packetInfo.item_num;
    local msgItem = packetInfo.item;
    if not roomId then return end;
    if page_num == 0 then 
        if roomId then
            if self.m_current_view == HallChatDialog.MAIN_CHAT then
                self:leaveChatRoom(roomId);
            end;
        end
        return 
    end
    local tab = {}
    for i,item in ipairs(msgItem) do
        if not FriendsData.getInstance():isInBlacklist(item.uid) then
            table.insert(tab,item)
        end
    end

    ChatRoomData.getInstance():saveHistoryMsg(tab,roomId);
    ChatRoomData.getInstance():saveRoomData(roomId,os.time());
    if (tonumber(curr_page) + 1 == tonumber(page_num)) then
        if self.m_current_view == HallChatDialog.MAIN_CHAT then
            self:addLatestMsgToMainChat(roomId);
            self:leaveChatRoom(roomId);
        elseif self.m_current_view == HallChatDialog.DASHI_CHAT or
               self.m_current_view == HallChatDialog.CITY_CHAT or
               self.m_current_view == HallChatDialog.WORLD_CHAT or
               self.m_current_view == HallChatDialog.NEWPLAYER_CHAT or
               self.m_current_view == HallChatDialog.CHESSCLUB_CHAT  then
            local historyMsg = ChatRoomData.getInstance():getHistoryMsg(roomId);
            self:addLatestMsgToRoom(historyMsg,self.addChatRoomMsg);
            self.m_chat_room_scroll_msg_view:gotoBottom();
            self.m_chat_room_bottom_send_edit:setText(nil);
        end;       
    end;
end

-- 向上拉取历史消息返回（3.0.0新加）
HallChatDialog.onRecvServerUnreadMsgNew = function(self, packetInfo)
    local total_num = packetInfo.total_count;
    local roomId = packetInfo.room_id;
    local page_num = packetInfo.page_num;
    local curr_page = packetInfo.curr_page;
    local item_num = packetInfo.item_num;
    local msgItem = packetInfo.item;
    if not roomId then return end;
    if page_num == 0 then 
        if roomId then
            if self.m_current_view == HallChatDialog.MAIN_CHAT then
                self:leaveChatRoom(roomId);
                self:unLockMainChatItem(roomId);
            end;
        end
        return 
    end
    local tab = {}
    for i,item in ipairs(msgItem) do
        if not FriendsData.getInstance():isInBlacklist(item.uid) then
            table.insert(tab,item)
        end
    end
    ChatRoomData.getInstance():saveHistoryMsg(tab,roomId);
    ChatRoomData.getInstance():saveRoomData(roomId,os.time());
    if (tonumber(curr_page) + 1 == tonumber(page_num)) then
        if self.m_current_view == HallChatDialog.MAIN_CHAT then
            self:addLatestMsgToMainChat(roomId);
            self:unLockMainChatItem(roomId);
            self:leaveChatRoom(roomId);
        elseif self.m_current_view == HallChatDialog.DASHI_CHAT or
               self.m_current_view == HallChatDialog.CITY_CHAT or
               self.m_current_view == HallChatDialog.WORLD_CHAT or
               self.m_current_view == HallChatDialog.NEWPLAYER_CHAT or
               self.m_current_view == HallChatDialog.CHESSCLUB_CHAT  then
               if HallChatDialog.CHATROOM_TABLE[self.m_current_view] == roomId then
                   self:loadHistoryMsgsBytime(msgItem);
                   self.m_chat_room_bottom_send_edit:setText(nil);
               end;
        end;       
    end;
end


-- 拉取友谊战（约战）历史消息新（3.0.0新加）
HallChatDialog.onRecvServerChessMatchMsg = function(self, packetInfo)
    local total_num = packetInfo.total_count;
    local roomId = packetInfo.room_id;
    local page_num = packetInfo.page_num;
    local curr_page = packetInfo.curr_page;
    local item_num = packetInfo.item_num;
    local msgItem = packetInfo.item;
    if not roomId then return end;
    if page_num == 0 then 
        return 
    end
    local itemDatas = self.mWarData:addWarData(msgItem)
    self:loadChatInviteHistoryMsgs(itemDatas);
end;

HallChatDialog.onRecvServerChessMatchMsgNum = function(self,packetInfo)
    local total_num = packetInfo.total_count;
    local roomId = packetInfo.room_id;
    if total_num and tonumber(total_num) > 0 then
        self.m_chat_room_filter_btn:setVisible(true);
        self.m_chat_room_filter_btn_txt:setText(total_num);
    else
        self.m_chat_room_filter_btn:setVisible(false);
    end;    
end;

-- 过滤过期的聊天室邀请消息
HallChatDialog.filterOverdue = function(self,msgTable)
    local returnTable = {};
    for i = 1, #msgTable do
        local event,msgData = SchemesProxy.analyzeSchemesStr(msgTable[i].msg);
        if type(event) == "function" then
            if not self:isOverdue(msgTable[i]) then
                table.insert(returnTable,msgTable[i]);
            end;
        else
            table.insert(returnTable,msgTable[i]);
        end;
    end;
    return returnTable;
end;

HallChatDialog.isOverdue = function(self,data)
    if not data or not data.time then return true end;
    if os.time() - data.time > 3*60 then
        return true
    end
end;

HallChatDialog.addLatestMsgToRoom = function(self, msgTable, func)
    for i,v in ipairs(msgTable) do
        if func then
            func(self,v);
        end;
    end
end;

HallChatDialog.addLatestMsgToMainChat = function(self,roomId)
    local chatRoomLastMsg = ChatRoomData.getInstance():getLastRoomMsg();
    for i = 1,#self.m_chat_room_items do
        if chatRoomLastMsg then
            for j = 1,#chatRoomLastMsg do
                if self.m_chat_room_items[i]:getRoomId() == chatRoomLastMsg[j].roomid.."" then
                    if self.m_chat_room_items[i]:getRoomId() ~= roomId then break end;
                    self.m_chat_room_items[i]:setChatRoomLastMsg(chatRoomLastMsg[j]);
                end;
            end;
        end;
    end;
end;

-- item可点击
HallChatDialog.unLockMainChatItem = function(self,roomId)
    for i = 1,#self.m_chat_room_items do
        if self.m_chat_room_items[i]:getRoomId() == roomId.."" then
            self.m_chat_room_items[i]:setPickable(true);
        end;
    end;
end;

-- 接收server广播的聊天室消息
-- a) 当聊天室内容处于bottom时，加载新消息后scrollView:gotoBottom
-- b) 当聊天室内容不处于bottom，加载消息后scrollView:gotoOffset
-- 为了防止用户向上滑动看历史消息时，新消息过来，scrollView直接
-- 跳到最新消息，打断了用户的浏览

-- msg_json格式：（"uid":"发消息的玩家ID", "name":"玩家名称", 
--"time":"发消息时间", "msg":"消息文本内容", "msg_id":"消息ID", 
--"room_id":"聊天室ID", "msgtype":"消息类型", "other":"约战相关的控制信息"）， 
-- other是一个JSON
HallChatDialog.onRecvServerBroadCastMsg = function(self, data)
	local msgtab = json.decode(data.msg_json);
    if not msgtab then return end;
    local msgData = {};
    msgData.uid = msgtab.uid;
    msgData.name = msgtab.name;
    msgData.time = msgtab.time;
    msgData.msg = msgtab.msg;
    msgData.msg_id = msgtab.msg_id;
    msgData.room_id = msgtab.room_id;
    msgData.msgtype = msgtab.msgtype;
    msgData.other = msgtab.other;
    if FriendsData.getInstance():isInBlacklist(tonumber(msgData.uid)) then return end
    if not self.m_chat_room_item then return end
    if data.room_id == self.m_chat_room_item:getRoomId() then
        if tonumber(msgData.msgtype) and tonumber(msgData.msgtype) > 1 then -- 除了普通消息之外（约多人应战/一对一应战）
            if tonumber(msgData.msgtype) == 2 or tonumber(msgData.msgtype) == 3 then
                self:toGetChessMatchMsgNum(msgData.room_id);
            end;
            ChatRoomData.getInstance():deleteRoomMsg(msgData,data.room_id);
            ChatRoomData.getInstance():saveRoomData(data.room_id,os.time()); 
            self:deleteChatRoomMsgList(msgData);
            self:deleteChatRoomInviteMsgList(msgData);
            if self:isAddChessMatchItem(msgData) then 
                return 
            else
                ChatRoomData.getInstance():saveRecvMsg(msgData,data.room_id);
                ChatRoomData.getInstance():saveRoomData(data.room_id,os.time());               
            end;
        else
            ChatRoomData.getInstance():saveRecvMsg(msgData,data.room_id);
            ChatRoomData.getInstance():saveRoomData(data.room_id,os.time());  
        end;

        local isScrollBottom = self.m_chat_room_scroll_msg_view:isScrollToBottom();
        if isScrollBottom then
            self:addChatRoomMsg(msgData);
            self.m_chat_room_scroll_msg_view:gotoBottom();
        else
            local _,h = self.m_chat_room_scroll_msg_view:getMainNodeWH();
            self:addChatRoomMsg(msgData);
            self.m_chat_room_scroll_msg_view:gotoOffset(h);
        end;
    end;
    if tonumber(msgData.uid) == UserInfo.getInstance():getUid() then
        self:openMoreAction(false);
    end; 

    local msginfo = {};
    msginfo.room_id = data.room_id;
    msginfo.uid = UserInfo.getInstance():getUid();
    msginfo.msg_time = msgtab.time;
    msginfo.msg_id = msgtab.msg_id;
    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_BROAdCAST_CHAT_MSG,msginfo);
end

--广播棋社系统消息
HallChatDialog.onRecvSociatyNoticeMsg = function(self, data)
    --0
    --"{"mid":10001888,"msg":"\u9000\u51fa\u4e86\u68cb\u793e","op":"del_member","role":"3"}"
    --"guild_1019"
    local recv_user_id = data.recv_user_id or 0 
    local chat_room_id  = data.chatRoom_id or ""
    local msgtab = json.decode(data.system_msg);
    if not msgtab then return end;
    local msgData = {};
    msgData.uid = msgtab.mid;
    msgData.msg = msgtab.msg;
    msgData.op = msgtab.op;
    msgData.role = msgtab.role;
    if self.m_chat_room_item then
        if chat_room_id == self.m_chat_room_item:getRoomId() then
            self:addSociatyChatRoomNotice(msgData);
        end
    end
end

function HallChatDialog.addSociatyChatRoomNotice(self,data)
    local node = new(SociatyChatRoomItem,data)
    if not node then return end;
    self.m_chat_room_scroll_msg_view:addChild(node);
end

-- 拉取未读消息数量
HallChatDialog.onRecvServerUnreadMsgNum = function(self, data)
    if not data then return end;
    for i = 1,#self.m_chat_room_items do
        if data.room_id == self.m_chat_room_items[i]:getRoomId() then
            self.m_chat_room_items[i]:setNewMsgNum(data.unread_msg_num,data.room_id);
            self:loadLocalUnreadMsg(self.m_chat_room_items[i],data.room_id);
        end;
    end;
end;

HallChatDialog.loadLocalUnreadMsg = function(self ,item,id)
    local isHasLocalUnreadMsg = GameCacheData.getInstance():getBoolean(GameCacheData.CHAT_IS_HAS_UNREAD_MSG..UserInfo.getInstance():getUid().."_"..(id or "default"),false);
    if isHasLocalUnreadMsg and item then
        item:setNewMsgNum(1,id);
    end;
end;

-- 接收自己发的消息
HallChatDialog.onRecvCommonChatMsg2 = function(self, data)
    if data.ret == 0 then
--        self.m_isSendingMsg = false;
        ------- 本人聊天item -------
        local data ={}
        data.send_uid = UserInfo.getInstance():getUid();
        data.time = os.time();
        if ToolKit.isSecondDay(self.m_chat_room_last_msg_time) then
            data.isShowTime = true;
        else
            if ToolKit.isInTenMinute(self.m_chat_room_last_msg_time, data.time) then
                data.isShowTime = false;
            else
                data.isShowTime = true;
            end;
        end;
        self.m_chat_room_last_msg_time = data.time;
        data.mnick = UserInfo.getInstance():getName();
        data.msg = self.m_chat_room_msg;
        data.msgtype = 1;
        local item = self:getCommonRoomChatItem(data);
        if not item then 
            return 
        end;
        self.m_chat_room_scroll_msg_view:addChild(item);
        FriendsData.getInstance():addChatDataByUid(tonumber(self.m_chat_room_item:getUid()), self.m_chat_room_msg);
        self.m_chat_room_scroll_msg_view:gotoBottom();
        self.m_chat_room_bottom_send_edit:setText(nil);
    elseif data.ret == 1 then
        local show = new(Node);
        local nodebg = new(Image,"common/background/chat_time_bg2.png");
        nodebg:setSize(590,40);
        nodebg:setAlign(kAlignCenter);
        local msg = "*对方当前版本过低，暂不支持聊天功能";
        local text = new(Text,msg,nil,nil,nil,nil,32,80,80,80);
        text:setAlign(kAlignCenter);
        show:setSize(600,100);
        show:addChild(nodebg);
        show:addChild(text);
        self.m_chat_room_scroll_msg_view:addChild(show);
        self.m_chat_room_scroll_msg_view:gotoBottom();
    elseif data.ret == 2 then -- 禁言
--        self.m_isSendingMsg = false;
    elseif data.ret == 3 then -- 屏蔽频繁刷屏（相同内容/空格）
--        self.m_isSendingMsg = false;
        ChessToastManager.getInstance():showSingle("亲，消息不能为空或频繁发送哦",1500);
    else
--        self.m_isSendingMsg = false;
        ChessToastManager.getInstance():showSingle("消息发送失败了",1500);        
    end;   
end;

-- 接收好友发的消息
HallChatDialog.recvCommonRoomMsg = function(self, data)
    if not data then
        return;
    end;
    --只有上方好友发的消息才接收
    if data.send_uid == tonumber(self.m_chat_room_item:getUid()) then
        if ToolKit.isSecondDay(self.m_chat_room_last_msg_time) then
            data.isShowTime = true;
        else
            if ToolKit.isInTenMinute(self.m_chat_room_last_msg_time, data.time) then
                data.isShowTime = false;
            else
                data.isShowTime = true;
            end;
        end;
        self.m_chat_room_last_msg_time = data.time;
        local item = self:getCommonRoomChatItem(data);
        if not item then return end;
        self.m_chat_room_scroll_msg_view:addChild(item);
        self.m_chat_room_scroll_msg_view:gotoBottom();
        self:resetUnreadMsgNum(data.send_uid);
    end;
end;

HallChatDialog.resetUnreadMsgNum = function(self,uid)
    FriendsData.getInstance():updateUnreadChatByUid(tonumber(uid));
end;


HallChatDialog.onRecvServerGetMemberList = function(self, data)
    if self.m_member_from == 2 then -- 同城
        self:loadCityRoomMember(data);
    elseif self.m_member_from == 1 then -- 大师
        self:loadDashiRoomMember(data);
    end;
end;

HallChatDialog.isActionAvaliable = function(self,obj,func)
    self.m_cur_chatroom_obj = obj;
    self.m_cur_chatroom_func = func;
    local msgdata = {};
    msgdata.send_uid = UserInfo.getInstance():getUid();
    msgdata.check_uid = UserInfo.getInstance():getUid();
    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_IS_ACT_AVALIABLE,msgdata);
end;

HallChatDialog.updateItemStatus = function(self,room_id,msg_id)
    local msgdata = {};
    msgdata.room_id = room_id;
    msgdata.msg_id = msg_id;
    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_UPDATE_CHATROOM_ITEM,msgdata);    
end;

HallChatDialog.getChatRoomManualInfo = function(self,chess_id,func)
    local post_data = {};
    post_data.manual_key = chess_id;
    HttpModule.getInstance():execute2(HttpModule.s_cmds.getChatRoomManualInfo,post_data,function(isSuccess,message)
        if not message then return end;
        if not isSuccess then
            if type(message) == "number" then
                return; 
            elseif message.error then
                ChessToastManager.getInstance():showSingle(message.error:get_value(),2000);
                return;
            end;        
        end;
        local msg = json.decode(message);
        if not msg then return end;
        local data = msg.data;        
        if func then
            func(data);
        end;
    end);    
end;

HallChatDialog.onRecvServerIsActAvaliable = function(self, data)
    if data.status == 0 then
        if self.m_cur_chatroom_obj and self.m_cur_chatroom_func then 
            self.m_cur_chatroom_func(self.m_cur_chatroom_obj);
            self.m_cur_chatroom_obj = nil;
            self.m_cur_chatroom_func = nil;
            return;
        end;
        EventDispatcher.getInstance():dispatch(Event.Call,kIsAvaliableChessMatch,data);
    elseif data.status == -1 then
        ChessToastManager.getInstance():showSingle("您已经有个约战了"); 
    elseif data.status == -2 then
        ChessToastManager.getInstance():showSingle("该玩家正在约战"); 
    end;
end;

HallChatDialog.onRecvServerUpdateCRItem = function(self, data)
    if data.status == 0 then
    elseif data.status == -1 then
        for i = 1,#self.m_chat_room_scroll_msg_view:getChildren() do
            local item = self.m_chat_room_scroll_msg_view:getChildren()[i];
            if item and item.getMsgId and item.getRoomId then
                if item:getMsgId() == data.msg_id and item:getRoomId() == data.room_id then
                    item:updateSelf();
                end;
            end;
        end;
    end;
end;
-- 添加关注回调
HallChatDialog.onRecvServerAddFllow = function(self, info)
    if self.m_cur_member then
        self.m_cur_member:onRecvServerAddFllow(info);
    end;
end;

HallChatDialog.onRecvServerCheckUserState = function(self,info)
    EventDispatcher.getInstance():dispatch(Event.Call,kStranger_isOnline,info);
end;

HallChatDialog.sendHornMsg = function(self,info)
    if not self.m_isSendingMsg then
        self.m_isSendingMsg = true;
        self.m_horn_msg = self.m_horn_room_bottom_send_edit:getText() or "";
        if self.m_horn_msg == "" then
            ChessToastManager.getInstance():showSingle("消息不能为空！",800); 
            self.m_isSendingMsg = false;
            return;
        end;
        local len = ToolKit.utfstrlen(self.m_horn_msg)
        if len > 30 then
            ChessToastManager.getInstance():showSingle("喇叭消息不能超过30个字！",800);
            self.m_isSendingMsg = false;
            return
        end
        local lastTime = SystemNotice.getInstance():getMyLastMsgTime();--SystemNotice.getInstance():getLastMsgByTime()
        local nowTime = os.time()
        local difftime = nowTime - lastTime
        if difftime < 30 then
            ChessToastManager.getInstance():showSingle("请不要频繁发布喇叭消息",800);
            self.m_isSendingMsg = false;
            return
        end
        local info = {}
        local str = string.format("#t11%s#j0#i%s#w" .. self.m_horn_msg,UserInfo.getInstance():getName(),UserInfo.getInstance():getUid())
        info.message = str
        HttpModule.getInstance():execute2(HttpModule.s_cmds.checkHornMsg,info,function(isSuccess,resultStr)
            self.m_isSendingMsg = false;
            if not isSuccess then
                ChessToastManager.getInstance():showSingle("发送失败")
                return 
            end
            local data = json.decode(resultStr)
            local errormsg = data.error
            if errormsg then
                ChessToastManager.getInstance():showSingle(errormsg)
                return
            else
                local nowTime = os.time()
                SystemNotice.getInstance():setMyLastMsgTime(nowTime);
            end 
        end)

    else
        ChessToastManager.getInstance():showSingle("正在发送消息...",2000);  
    end
    self.m_horn_room_bottom_send_edit:setText(nil);
end

--切换到棋社界面
function HallChatDialog.onSwitchSociatyView(self,func)
    delete(self.mSocaityModule)
    self.mSocaityModule = new(ChessSociatyModuleView,self)
    local callbackFunc = func or self.chessClubListBackToMainChat
    local start_view = self.m_main_chat_view
    if self.m_current_view == HallChatDialog.CHESSCLUB_CHAT then
        start_view = self.m_chat_room_view
        self:leaveChatRoom(self.m_chat_room_item:getRoomId());
    elseif self.m_current_view == HallChatDialog.CHESSCLUB_LIST then
        start_view = self.m_main_chat_view
    end
    self.mSocaityModule:setBackAction(self,callbackFunc)
    self.mSocaityModule:resume()
    if self.mSocaityModule then
        self.mSocaityModule:switchView()
    end

    ToolKit.schedule_once(self,EffectAnim.leftOutRightIn,200,start_view,self.m_sociaty_view,HallChatDialog.LORI_ANIM_TIME,
                                function() 
                                self.m_hall_chat_bg:setPickable(true);
                                start_view:setVisible(false)
                                self.m_sociaty_view:setVisible(true)
                                end); 
end 

function HallChatDialog.onHideSociatyView(self)
    self:chessClubListBackToMainChat()
end 


---------------------------- event ----------------------------
HallChatDialog.onEventResponse = function(self, cmd, data)
    if cmd == kFriend_UpdateChatMsg then
        if self.m_current_view == HallChatDialog.MAIN_CHAT then
            if data then
                if self.m_chat_list_items then
                    local existItem = nil;-- 是否存在item
                    for index = 1,#self.m_chat_list_items do
                        local uid = self.m_chat_list_items[index]:getUid();
                        if uid and uid == tonumber(data.send_uid) then
                            existItem = self.m_chat_list_items[index];
                            self.m_chat_list_items[index]:updateUserMsgByMsg(data);
                            break;
                        end
                    end;
                    if existItem then
                        -- 交换处理
                        self:updateMainPraviteChat(data,false,existItem);
                    else
                        -- 新建插入处理
                        self:updateMainPraviteChat(data,true);
                    end;
                end;   
            end
        elseif self.m_current_view == HallChatDialog.COMMON_CHAT then
            if data then
                self:recvCommonRoomMsg(data);
            end            
        end;
    elseif cmd == kFriend_UpdateUserData then
        if self.m_current_view == HallChatDialog.MAIN_CHAT then
            if self.m_chat_list_items then
                for index =1,#self.m_chat_list_items do
                    local uid = self.m_chat_list_items[index]:getUid();
                    for _,sdata in pairs(data) do
                        if uid and uid == tonumber(sdata.mid) then
                            self.m_chat_list_items[index]:updateUserData(sdata);
                            break;
                        end
                    end
                end;
            end;
        elseif self.m_current_view == HallChatDialog.DASHI_CHAT or
               self.m_current_view == HallChatDialog.CITY_CHAT or
               self.m_current_view == HallChatDialog.WORLD_CHAT or
               self.m_current_view == HallChatDialog.NEWPLAYER_CHAT or
               self.m_current_view == HallChatDialog.CHESSCLUB_CHAT then
            if self.m_chat_room_scroll_msg_view then
                local childs = self.m_chat_room_scroll_msg_view:getChildren();
                for index =1,#childs do
                    if childs[index] then
                        local uid = childs[index]:getUid();
                        for _,sdata in pairs(data) do
                            if uid and uid == tonumber(sdata.mid) then
                                childs[index]:updateUserData(sdata);
                                break;
                            end
                        end 
                    end;
                end;
            end;                     
        elseif self.m_current_view == HallChatDialog.CREATE_CHAT then
            if self.m_create_chat_scroll_view then
                local childs = self.m_create_chat_scroll_view:getChildren();
                for index =1,#childs do
                    if childs[index] then
                        local uid = childs[index]:getUid();
                        for _,sdata in pairs(data) do
                            if uid and uid == tonumber(sdata.mid) then
                                childs[index]:updateUserData(sdata);
                                break;
                            end
                        end
                    end;
                end;
            end;  
        end;
    elseif cmd == kGetChatRoomInfo then
        self:updateChatRoomList();  
    elseif cmd == kGetProvinceCode then -- 定位
        self:reloadCityChatRoomInfo(data);
    end;
end;

----------------------------------------------------------------
--------------------------聊天主界面item------------------------
----------------------------------------------------------------

HallChatDialogItem = class(Button,false);
HallChatDialogItem.s_width = 720;
HallChatDialogItem.ctor = function(self, data, itemType,room)
    super(self,"drawable/blank.png","drawable/blank.png")
    if not data then return end;
    self.m_data = data;
    self.m_index = index;
    self.m_itemType = itemType;
    self.m_room = room;
    self:setSize(HallChatDialogItem.s_width,170);
    self:setOnClick(self, self.onItemClick);
    self:setSrollOnClick();
    -------- views --------
    self.m_bg = new(Image,"common/background/list_item_bg.png");
    self.m_bg:setPos(0,0);
    self.m_bg:setAlign(kAlignBottom);

    self:addChild(self.m_bg);
    self.m_bg:setEventTouch(nil,nil);

    --未读消息
    self.m_unread_img = new(Image, "dailytask/redPoint.png"); 
    self.m_unread_img:setLevel(1);
    self.m_unread_img:setAlign(kAlignTopRight);

    self.m_unread_num = new(Text,"",26, 26, kAlignCenter,nil,15,255, 255, 255);
    self.m_unread_img:addChild(self.m_unread_num);
    self.m_unread_num:setPos(nil, -2);
    self.m_unread_img:setVisible(false);
    local nameX,nameY = 130, 35;
    local lastMsgX,lastMsgY = 135, 80;
    local timeX,timeY = 30,35;
    -- icon_frame
    self.m_icon_frame = new(Image,"userinfo/icon_9090_frame.png");
    self.m_icon_frame:setPos(20,-5);
    self.m_icon_frame:setAlign(kAlignLeft);
    self.m_icon_frame:addChild(self.m_unread_img);
    self.m_bg:addChild(self.m_icon_frame);

    if self.m_itemType == 0 then
        self.m_uid = self.m_data.uid;
        self.m_friend_info = FriendsData.getInstance():getUserData(self.m_uid);
        if self.m_friend_info then
            -- friend_icon
            self:loadIcon(self.m_friend_info);
            -- friend_name
	        self.m_friend_name = new(Text,self.m_friend_info.mnick or "博雅象棋", 0, 0, nil,nil,36,80, 80, 80);
	        self.m_friend_name:setPos(nameX,nameY);
	        self.m_bg:addChild(self.m_friend_name);
            if self.m_data.last_msg then
                local lens = string.lenutf8(GameString.convert2UTF8(self.m_data.last_msg) or "");    
                if  lens > 10 then--限制10字
                    self.m_data.last_msg = GameString.convert2UTF8(string.subutf8(self.m_data.last_msg,1,10).."...");
                end;
            end;
            -- last_msg
            self.m_last_msg = new(Text, self.m_data.last_msg or "...", 0, 0, nil,nil,28,120, 120, 120);
	        self.m_last_msg:setPos(lastMsgX,lastMsgY);
	        self.m_bg:addChild(self.m_last_msg);
            -- time
            self.m_time = new(Text, self:getTime(self.m_data.time) or "", 0, 0, kAlignRight,nil,24,120, 120, 120);
	        self.m_time:setPos(timeX,timeY);
            self.m_time:setAlign(kAlignTopRight);
	        self.m_bg:addChild(self.m_time); 
        else
            self:loadIcon();
            -- friend_name
	        self.m_friend_name = new(Text,"博雅象棋", 0, 0, nil,nil,36,80, 80, 80);
	        self.m_friend_name:setPos(nameX,nameY);
	        self.m_bg:addChild(self.m_friend_name);
            -- last_msg
            self.m_last_msg = new(Text, self.m_data.last_msg or "...", 0, 0, nil,nil,28,120, 120, 120);
	        self.m_last_msg:setPos(lastMsgX,lastMsgY);
	        self.m_bg:addChild(self.m_last_msg);
            -- time
            self.m_time = new(Text, self:getTime(self.m_data.time) or "", 0, 0, kAlignRight,nil,24,120, 120, 120);
	        self.m_time:setPos(timeX,timeY);
            self.m_time:setAlign(kAlignTopRight);
	        self.m_bg:addChild(self.m_time); 
        end;
        local chat = FriendsData.getInstance():getChatByUid(self.m_uid);
        if chat and chat.unReadNum then
            self:setNewMsgNum(chat.unReadNum,self.m_uid);
        end;
    elseif self.m_itemType == 1 then 
        -- room_id,大师房间用的php提供的id
        -- 同城使用city_code作为room_id
        self.m_chat_room_id = self.m_data.id;
        self.m_chat_room_type = self.m_data.type;
        self.m_min_score = self.m_data.min_score;
        self.m_city_code = UserInfo.getInstance():getProvinceCode();
        self.m_city_name = UserInfo.getInstance():getProvinceName();
        self:loadChatRoomIcon(self.m_data);
        -- chat_room_name
        if self.m_chat_room_type == "master" then
	        self.m_chat_room_name = new(Text, self.m_data.name or "象棋大师聊天室", 0, 0, nil,nil,36,80, 80, 80);
            HallChatDialog.CHATROOM_TABLE[HallChatDialog.DASHI_CHAT] = self.m_chat_room_id.."";
        elseif self.m_chat_room_type == "city" then 
            if not self.m_city_name or self.m_city_name == "" then
                self.m_chat_room_name = new(Text, "同城棋友聊天室", 0, 0, nil,nil,36,80, 80, 80);
            else
                self.m_chat_room_name = new(Text, self.m_city_name.."棋友聊天室", 0, 0, nil,nil,36,80, 80, 80);
                HallChatDialog.CHATROOM_TABLE[HallChatDialog.CITY_CHAT] = self.m_city_code.."";
            end;
        elseif self.m_chat_room_type == "comm" then
            self.m_chat_room_name = new(Text, self.m_data.name or "世界棋友聊天室", 0, 0, nil,nil,36,80, 80, 80);
            HallChatDialog.CHATROOM_TABLE[HallChatDialog.WORLD_CHAT] = self.m_chat_room_id.."";
        elseif self.m_chat_room_type == "new" then
            self.m_chat_room_name = new(Text, self.m_data.name or "新手聊天室", 0, 0, nil,nil,36,80, 80, 80);
            HallChatDialog.CHATROOM_TABLE[HallChatDialog.NEWPLAYER_CHAT] = self.m_chat_room_id.."";
        elseif self.m_chat_room_type == "horn" then -- 小喇叭
            self.m_chat_room_name = new(Text, self.m_data.name or "小喇叭广播", 0, 0, nil,nil,36,80, 80, 80);
            HallChatDialog.CHATROOM_TABLE[HallChatDialog.HORN_CHAT] = self.m_chat_room_id.."";
        elseif self.m_chat_room_type == "guild" then -- 棋社
            self.m_chat_room_name = new(Text, self.m_data.name or "棋社聊天室", 0, 0, nil,nil,36,80, 80, 80);
            HallChatDialog.CHATROOM_TABLE[HallChatDialog.CHESSCLUB_CHAT] = self.m_chat_room_id.."";
        else
            self.m_chat_room_name = new(Text, "聊天室", 0, 0, nil,nil,36,80, 80, 80);
        end;
	    self.m_chat_room_name:setPos(nameX,nameY);
	    self.m_bg:addChild(self.m_chat_room_name);
        -- last_msg
        self.m_chat_room_last_msg = new(Text, self.m_data.last_msg or "...", 0, 0, nil,nil,28,120, 120, 120);
	    self.m_chat_room_last_msg:setPos(lastMsgX,lastMsgY);
	    self.m_bg:addChild(self.m_chat_room_last_msg);
        -- time
        self.m_chat_room_time = new(Text, self:getTime(self.m_data.time) or "", 0, 0, kAlignRight,nil,24,120, 120, 120);
	    self.m_chat_room_time:setPos(timeX,timeY);
        self.m_chat_room_time:setAlign(kAlignTopRight);
	    self.m_bg:addChild(self.m_chat_room_time); 
    else
        return;
    end
end;

HallChatDialogItem.dtor = function(self)
end;

HallChatDialogItem.getRoomMinScore = function(self)
    return self.m_min_score or 0;
end

HallChatDialogItem.getItemType = function(self)
    return self.m_itemType or nil;
end

HallChatDialogItem.getData = function(self)
    return self.m_data or nil;
end

HallChatDialogItem.getIndex = function(self)
    return self.m_index or nil;
end

HallChatDialogItem.getRoomId = function(self)
    if self.m_chat_room_type == "city" then -- 同城聊天返回城市代码
        return self.m_city_code .. "";
    else
        return self.m_chat_room_id;
    end;
end;

HallChatDialogItem.getRoomType = function(self)
    return self.m_chat_room_type or "";
end;


HallChatDialogItem.setCityCode = function(self,code)
    self.m_city_code = code;
    HallChatDialog.CHATROOM_TABLE[HallChatDialog.CITY_CHAT] = self.m_city_code.."";
end;

HallChatDialogItem.getCityCode = function(self)
    return self.m_city_code;
end;

HallChatDialogItem.getChatRoomName = function(self)
    if self.m_itemType == HallChatDialog.PUBLIC_CHAT then 
        return self.m_chat_room_name:getText() or "聊天室";
    elseif self.m_itemType == HallChatDialog.PRAVITE_CHAT then
        return self.m_friend_name:getText() or "博雅中国象棋";
    end;
end;

HallChatDialogItem.setCityName = function(self,city)
    self.m_city_name = city;
    self.m_chat_room_name:setText((self.m_city_name == "" and "同城棋友聊天室") or (self.m_city_name.."棋友聊天室"));
end;

HallChatDialogItem.getCityName = function(self)
    return self.m_city_name;
end;

HallChatDialogItem.setChatRoomLastMsg = function(self, data)
    if not data then return end;
    if not data.name then
        self.m_chat_room_last_msg:setText("...");
    else
        -- msg
        local str = data.name .. "：" ..data.last_msg;
        local lens = string.lenutf8(GameString.convert2UTF8(str) or "");    
        if  lens > 10 then--限制10字
            str = GameString.convert2UTF8(string.subutf8(str,1,10).."...");
        end;
        self.m_chat_room_last_msg:setText(str);
        -- time
        self:setChatRoomMsgTime(self:getTime(data.time));
    end;
end;
-- 设置未读
HallChatDialogItem.setNewMsgNum = function(self, nesMsgNum, id)
    if nesMsgNum ~= 0 then
        self.m_unread_img:setVisible(true);
        GameCacheData.getInstance():saveBoolean(GameCacheData.CHAT_IS_HAS_UNREAD_MSG..UserInfo.getInstance():getUid().."_"..(id or "default"),true);
    end;
end;
-- 设置是否已读
HallChatDialogItem.setHasReadMsgNum = function(self,id)
    self.m_unread_img:setVisible(false);
    GameCacheData.getInstance():saveBoolean(GameCacheData.CHAT_IS_HAS_UNREAD_MSG..UserInfo.getInstance():getUid().."_"..(id or "default"),false);
end;

HallChatDialogItem.getUid = function(self)
    return self.m_uid or nil;
end

HallChatDialogItem.getTime = function(self, time)
    if not time then return nil end;
    return ToolKit.getEasyTime2(time);
end

HallChatDialogItem.setChatRoomMsgTime = function(self, time)
    if self.m_chat_room_time then
        self.m_chat_room_time:setText(time);
    end;
end;

HallChatDialogItem.loadIcon = function(self,data)
    if not data then
        self.m_user_icon = new(Mask,UserInfo.DEFAULT_ICON[1] ,"userinfo/icon_8484_mask.png");
        self.m_user_icon:setSize(84,84);
        self.m_user_icon:setAlign(kAlignCenter);
        self.m_icon_frame:addChild(self.m_user_icon)
--        self.m_icon_frame:addChild(self.m_unread_img);
    else
        local icon = data.icon_url;
        if not self.m_user_icon then
            if not icon then 
                if data.iconType > 0 then
                    icon = UserInfo.DEFAULT_ICON[data.iconType] or UserInfo.DEFAULT_ICON[1];
                else
                    icon = UserInfo.DEFAULT_ICON[1]
                end;
                self.m_user_icon = new(Mask,icon ,"userinfo/icon_8484_mask.png");
            else
                self.m_user_icon = new(Mask,"drawable/blank.png" ,"userinfo/icon_8484_mask.png");
                self.m_user_icon:setUrlImage(icon,UserInfo.DEFAULT_ICON[1]);            
            end;
            self.m_user_icon:setSize(84,84);
            self.m_user_icon:setAlign(kAlignCenter);
            self.m_icon_frame:addChild(self.m_user_icon)
        else
            if not icon then 
                if data.iconType > 0 then
                    icon = UserInfo.DEFAULT_ICON[data.iconType] or UserInfo.DEFAULT_ICON[1];
                else
                    icon = UserInfo.DEFAULT_ICON[1]
                end;
                self.m_user_icon:setFile(icon);
            else
                self.m_user_icon:setUrlImage(icon,UserInfo.DEFAULT_ICON[1]);            
            end;   
        end   
    end;
end

HallChatDialogItem.loadChatRoomIcon = function(self, data)
    if not data then return end;
    self.m_chat_room_icon = new(Image,"drawable/blank.png");
    if self.m_chat_room_type == "horn" then -- 小喇叭
        self.m_chat_room_icon:setFile("common/icon/horn.png");  
    elseif self.m_chat_room_type == "comm" then -- 世界
        self.m_chat_room_icon:setFile("common/icon/world.png"); 
    elseif self.m_chat_room_type == "city" then -- 同城
        self.m_chat_room_icon:setFile("common/icon/tongcheng.png");  
    else
        self.m_chat_room_icon:setFile("common/icon/lts.png");
    end
    self.m_chat_room_icon:setSize(84,84);
    self.m_chat_room_icon:setAlign(kAlignCenter);
    self.m_icon_frame:addChild(self.m_chat_room_icon)
    self.m_icon_frame:setFile("drawable/blank.png");
end;

HallChatDialogItem.updateUserData = function(self, data)
    self.m_friend_info = data;
    self:loadIcon(data);
    local msgList = FriendsData.getInstance():getChatList();
    for k,v in ipairs(msgList) do
        if v.uid == self.m_uid then
            self:updateUserMsgByChatList(v);
        end;
    end;
    self.m_friend_name:setText(data.mnick or "博雅象棋");
end;

HallChatDialogItem.updateUserMsgByChatList = function(self,data)
    self.m_last_msg:setText(data.last_msg or "");
    self.m_time:setText(self:getTime(data.time));
    self:setNewMsgNum(data.unReadNum,self.m_uid);
end

HallChatDialogItem.updateUserMsgByMsg = function(self, data)
    local chat = FriendsData.getInstance():getChatByUid(data.send_uid);
    self.m_last_msg:setText(chat.last_msg or "");
    self.m_time:setText(self:getTime(chat.time));
    self:setNewMsgNum(chat.unReadNum,self.m_uid);
end;

HallChatDialogItem.updateMainChatRoomItem = function(self, data)
    if not data then return end;
    self.m_chat_room_id = data.id or "";
    self.m_chat_room_name:setText(data.name or "聊天室");
    self.m_chat_room_icon:setUrlImage(data.img_url,"common/icon/lts.png");
    HallChatDialog.CHATROOM_TABLE[HallChatDialog.CHESSCLUB_CHAT] = self.m_chat_room_id.."";
end

function HallChatDialogItem:updateMainChatRoomName(name)
    if not name then return end
    self.m_chat_room_name:setText(name or "聊天室")
end

HallChatDialogItem.onItemClick = function(self)
    -- 清除未读消息
    if self.m_data.id and self.m_data.id == "1001" then
        self:setHasReadMsgNum(UserInfo.getInstance():getProvinceCode());
    else
        self:setHasReadMsgNum(self.m_data.id or self.m_data.uid or "0");
    end;
    self.m_room:onMainChatItemClick(self);
end;

function HallChatDialogItem.setNoticeRoomLastMsg(self)
    local data = SystemNotice.getInstance():getLastMsgByTime()
    local tab = AnalysisNotice.getAnalysisData(data)
    if self.tipNode then
        self.m_bg:removeChild(self.tipNode)
    end
    delete(self.tipNode)
    self.tipNode = nil 
    if not next(tab) then
        self.m_chat_room_last_msg:setVisible(true)
        self.m_chat_room_last_msg:setText("...");
    else
        self.m_chat_room_last_msg:setVisible(false)
        self.tipNode = self:createSimpleNode(tab)
        self.m_bg:addChild(self.tipNode)
    end;

end

function  HallChatDialogItem.createSimpleNode(self,tab)
    -- 其他地方需要用，在提取...
    local msgType = 0
    local msgTitle = ""
    local msg = ""
    local msgImg = nil
    for k,v in pairs(tab) do
        if v then
            if v.ctrl == "t" then
                msgType = tonumber(v.text) or 0 
            end
            if v.ctrl == "d" then
                msgTitle = v.text or ""
            end
            if v.ctrl == "w" then
                msg = v.text or "..."
                local len = ToolKit.utf8_len(msg)
                if len > 10 then
                    msg = string.subutf8(msg,1,10) .. "..."
                end
            end
        end
    end
    local node = new(Node)
    node:setSize(HallChatDialogItem.s_width,60)
    node:setAlign(kAlignBottomLeft);
    node:setPos(130, 5)
    

    local msgImg = new(Image,"drawable/blank.png")
    msgImg:setAlign(kAlignTopLeft)
    msgImg:setSize(58,26)
    msgImg:setPos(0,4)
    node:addChild(msgImg)

    local title = new(Text,msgTitle,nil,nil,nil,nil,26,255,255,255)
    title:setAlign(kAlignCenter)
    msgImg:addChild(title)

    local msgText = new(RichText," " .. msg, 450, 60, kAlignTopLeft,nil,30, 80, 80, 80, false, 2)
    msgText:setAlign(kAlignTopLeft)
    node:addChild(msgText)

    if msgType == 11 then
        title:setColor(220,200,170)
        title:setText(msgTitle .. ":")
        title:setAlign(kAlignTopLeft)
    elseif msgType == 12 then
        msgImg:setFile("common/decoration/light_bg.png")
    elseif msgType == 13 then
        msgImg:setFile("common/decoration/import_bg.png")
    elseif msgType == 14 then
        msgImg:setFile("common/decoration/match_bg.png")
    end

    local w,h = title:getSize()
    msgText:setPos(w + 5,0)

    return node
end

----------------------------------------------------------------
--------------------------创建会话item--------------------------
----------------------------------------------------------------

HallCreateChatDialogItem = class(Button,false)
HallCreateChatDialogItem.s_width = 650;
HallCreateChatDialogItem.ctor = function(self, uid, index, room)
    super(self,"drawable/blank.png","drawable/blank.png")
    if not uid then return end;
    self.m_uid = uid;
    self.m_index = index;
    self.m_room = room;    
    self.m_itemType = HallChatDialog.PRAVITE_CHAT;
    self.m_user_data = FriendsData.getInstance():getUserData(self.m_uid);
    self.m_user_status = FriendsData.getInstance():getUserStatus(self.m_uid);
    self:setSize(HallCreateChatDialogItem.s_width,100);
    self:setOnClick(self, self.onItemClick);
    ----------- views -----------
    self.m_bg = new(Image,"drawable/blank.png");
    self.m_bg:setPos(0,0);
    self.m_bg:setSize(HallCreateChatDialogItem.s_width,100);
    self.m_bg:setAlign(kAlignLeft);
    self.m_bg_line = new(Image,"common/decoration/name_line.png");
    self.m_bg_line:setSize(640);
    self.m_bg_line:setAlign(kAlignBottom);
    self.m_bg:addChild(self.m_bg_line);
    self:addChild(self.m_bg);
    self.m_bg:setEventTouch(nil,nil);
    local nameX,nameY = 120, 30;
    local lastMsgX,lastMsgY = 135, 75;
    local timeX,timeY = 20,30;
    -- icon_frame
    self.m_icon_frame = new(Image,"userinfo/icon_7070_frame2.png");
    self.m_icon_frame:setPos(30);
    self.m_icon_frame:setAlign(kAlignLeft);
    self.m_bg:addChild(self.m_icon_frame);
    -- friend_name
	self.m_friend_name = new(Text,"博雅中国象棋", 0, 0, nil,nil,36,80, 80, 80);
	self.m_friend_name:setPos(nameX,nameY);
	self.m_bg:addChild(self.m_friend_name);
    if self.m_user_data then
        self:loadFriendIcon(self.m_user_data);
        self.m_friend_name:setText(self.m_user_data.mnick);
    end;
end;

HallCreateChatDialogItem.dtor = function(self)
end;

HallCreateChatDialogItem.getFriendName = function(self)
    return self.m_friend_name:getText() or "博雅中国象棋";
end;

HallCreateChatDialogItem.getUid = function(self)
    return self.m_uid or 0;
end

HallCreateChatDialogItem.loadFriendIcon = function(self,data)
    if not data then return end;
    local icon = data.icon_url;
    if not self.m_user_icon then
        if not icon then 
            if data.iconType > 0 then
                icon = UserInfo.DEFAULT_ICON[data.iconType] or UserInfo.DEFAULT_ICON[1];
            else
                icon = UserInfo.DEFAULT_ICON[1];
            end;
            self.m_user_icon = new(Mask,icon ,"userinfo/icon_6464_mask.png");
        else
            self.m_user_icon = new(Mask,"drawable/blank.png" ,"userinfo/icon_6464_mask.png");
            self.m_user_icon:setUrlImage(icon,UserInfo.DEFAULT_ICON[1]);            
        end;
        self.m_user_icon:setSize(64,64);
        self.m_user_icon:setAlign(kAlignCenter);
        self.m_icon_frame:addChild(self.m_user_icon)
    else
        if not icon then 
            if data.iconType > 0 then
                icon = UserInfo.DEFAULT_ICON[data.iconType] or UserInfo.DEFAULT_ICON[1];
            else
                icon = UserInfo.DEFAULT_ICON[1]
            end;
            self.m_user_icon:setFile(icon);
        else
            self.m_user_icon:setUrlImage(icon,UserInfo.DEFAULT_ICON[1]);            
        end;   
    end   
end;

HallCreateChatDialogItem.updateUserData = function(self, data)
    self:loadFriendIcon(data);
    self.m_friend_name:setText(data.mnick or "博雅象棋");
end;

HallCreateChatDialogItem.onItemClick = function(self)
    self.m_room:onCreateChatItemClick(self);
end;

HallCreateChatDialogItem.getItemType = function(self)
    return self.m_itemType or nil;
end

HallCreateChatDialogItem.getChatRoomName = function(self)
    return self:getFriendName();
end;

----------------------------------------------------------------
--------------------------chatroom item ------------------------
----------------------------------------------------------------

-- 大师/同城/世界/普通聊天都用的item
HallChatRoomItem = class(Node)
HallChatRoomItem.s_width = 650;
HallChatRoomItem.ctor = function(self, data)
    --{msg_id=-1 recv_uid=1138 send_uid=1140 msg="啊啊啊" isShowTime=true time=1447930284 }
	if data.send_uid == UserInfo.getInstance():getUid() then
        self.m_name = UserInfo.getInstance():getName();
	    self.m_str = data.msg;
        self.m_uid = data.send_uid;
    else
        self.m_friend_info = FriendsData.getInstance():getUserData(data.send_uid);
        self.m_name = data.mnick;
	    self.m_str = data.msg;
        self.m_uid = data.send_uid;
    end
    self.reportData = data.msg or ""

    --时间
    self.m_time_bg = new(Image,"common/background/chat_time_bg2.png",nil,nil,10,10,10,10);
    self.m_time_bg:setSize(136,32);
    self.m_time_bg:setAlign(kAlignTop);
    self.m_time = new(Text, self:getTime(data.time), 0, 0, kAlignRight,nil,20,120, 120, 120);
    self.m_time_str = data.time;
    local timeW,timeH = self.m_time:getSize();
    self.m_time_bg:setSize(timeW + 30);
    self.m_time:setAlign(kAlignCenter);
    self.m_time_bg:addChild(self.m_time);
	self:addChild(self.m_time_bg);
    if not data.isShowTime then
        self.m_time_bg:setVisible(false);
    else
        self.m_time_bg:setVisible(true);
    end;
    self.m_user_icon = new(Mask,"common/background/head_mask_bg_86.png","common/background/head_mask_bg_86.png")
    self.m_user_icon:setFile(UserInfo.DEFAULT_ICON[1]);
    self.m_user_icon:setAlign(kAlignCenter);
    
    self.m_user_icon_click_area = new(Button,"drawable/blank.png");
    self.m_user_icon_click_area:setSize(86,86);
    self.m_user_icon_click_area:setAlign(kAlignCenter);
    self.m_user_icon_click_area:setOnClick(self, self.onItemClick);

    self.m_icon_frame = new(Image,"common/background/head_bg_92.png");
    self.m_icon_frame:addChild(self.m_user_icon_click_area);
    self.m_icon_frame:addChild(self.m_user_icon);
    self.m_icon_frame:setPos(0);
    self:addChild(self.m_icon_frame);
    self.m_vip_frame = new(Image,"vip/vip_110.png");
    self.m_vip_frame:setAlign(kAlignCenter);
    self.m_vip_frame:setVisible(false);
    self.m_vip_logo = new(Image,"vip/vip_logo.png");
    self.m_vip_logo:setVisible(false);
    self.m_user_level = new(Image,"common/icon/level_1.png");
    self.m_icon_frame:addChild(self.m_user_level);
    self.m_name_text = new(Text,self.m_name,nil,nil,nil,nil,24,100,100,100);
    local nw,nh = self.m_name_text:getSize();
    self:addChild(self.m_name_text);

    local itemX, itemY = 10, 30;
    if self.m_uid == UserInfo.getInstance():getUid() then
        self.m_message_bg = new(Image,"common/background/message_bg_7.png",nil, nil,46,46,50,16);
        self.m_message_bg:setPos(itemX + 100, itemY + 50);
        self.m_message_bg:setAlign(kAlignTopRight);
        self.m_icon_frame:setPos(itemX, itemY);
        self.m_icon_frame:setAlign(kAlignTopRight);
        self.m_user_level:setPos(itemX+10, itemY + 65)
        self.m_user_level:setFile(string.format("common/icon/level_%d.png",(10 - tonumber(UserInfo.getInstance():getLevel()))));
        self.m_name_text:setPos(itemX + 120, itemY + 10);
        self.m_name_text:setAlign(kAlignTopRight);
        self.m_vip_logo:setAlign(kAlignTopRight);
        self.m_vip_logo:setPos(itemX + 125 + nw,itemY + 5);
        if UserInfo.getInstance():getIsVip() == 1 then
            self.m_vip_logo:setVisible(true);
            self.m_name_text:setText(self.m_name,nil,nil,200,40,40)
--            self.m_vip_frame:setVisible(true);
        else
            self.m_name_text:setText(self.m_name,nil,nil,100,100,100)
            self.m_vip_logo:setVisible(false);
--            self.m_vip_frame:setVisible(false);
        end
        local frameRes = UserSetInfo.getInstance():getFrameRes();
        self.m_vip_frame:setVisible(frameRes.visible);
        local fw,fh = self.m_vip_frame:getSize();
        if frameRes.frame_res then
            self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
        end
        if UserInfo.getInstance():getIconType() == -1 then
            self.m_user_icon:setUrlImage(UserInfo.getInstance():getIcon());
        else
            local file = UserInfo.DEFAULT_ICON[UserInfo.getInstance():getIconType()] or UserInfo.DEFAULT_ICON[1];
            self.m_user_icon:setFile(file);
        end
    else
        self.m_message_bg = new(Image,"common/background/message_bg_5.png",nil, nil, 46,46,50,16);
        self.m_message_bg:setPos(itemX + 100, itemY + 50);
        self.m_message_bg:setAlign(kAlignTopLeft);
        self.m_icon_frame:setPos(itemX, itemY);
        self.m_icon_frame:setAlign(kAlignTopLeft);
        self.m_user_level:setPos(itemX+10, itemY + 65)
        self.m_name_text:setPos(itemX + 120, itemY + 10);
        self.m_name_text:setAlign(kAlignTopLeft);
        self.m_vip_logo:setAlign(kAlignTopLeft);
        self.m_vip_logo:setPos(itemX + 120,itemY + 5);
        local vw,vh = self.m_vip_logo:getSize();
        if self.m_friend_info then
            if self.m_friend_info.is_vip == 1 then
                self.m_name_text:setPos(itemX + 125 + vw,itemY + 10);
                self.m_name_text:setText(self.m_name,nil,nil,200,40,40)
                self.m_vip_logo:setVisible(true);
--                self.m_vip_frame:setVisible(true);
            else
                self.m_name_text:setPos(itemX + 120, itemY + 10);
                self.m_name_text:setText(self.m_name,nil,nil,100,100,100)
                self.m_vip_logo:setVisible(false);
--                self.m_vip_frame:setVisible(false);
            end;
            self.m_user_level:setFile(string.format("common/icon/level_%d.png",(10-UserInfo.getInstance():getDanGradingLevelByScore(self.m_friend_info.score))));
            if self.m_friend_info.my_set then
                local frameRes = UserSetInfo.getInstance():getFrameRes(self.m_friend_info.my_set.picture_frame or "sys");
                self.m_vip_frame:setVisible(frameRes.visible);
                local fw,fh = self.m_vip_frame:getSize();
                if frameRes.frame_res then
                    self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
                end
            end
            if self.m_friend_info.iconType == -1 then
                self.m_user_icon:setUrlImage(self.m_friend_info.icon_url);
            else
                local file = UserInfo.DEFAULT_ICON[self.m_friend_info.iconType] or UserInfo.DEFAULT_ICON[1];
                self.m_user_icon:setFile(file);
            end
        else
            self.m_name_text:setPos(itemX + 120, itemY + 10);
            self.m_vip_logo:setVisible(false);
--            self.m_vip_frame:setVisible(false);        
            local file = UserInfo.DEFAULT_ICON[1];
            self.m_user_icon:setFile(file);
        end
    end
    self.m_icon_frame:addChild(self.m_vip_frame);
    self:addChild(self.m_vip_logo);
    self:addChild(self.m_message_bg);

    local msgStr, msgW, msgH = self:returnStrAndWH(self.m_str);
	self.m_text = new(TextView,msgStr,msgW,0,nil,nil,28,80,80,80);
    local w,h = self.m_text:getSize();
    self.m_message_bg:setSize(w+50,h+40);

    self.m_text:setAlign(kAlignCenter);
    if self.m_uid == UserInfo.getInstance():getUid() then
        self.m_text:setPos(-5);
    else
        self.m_text:setPos(5);
    end
    self.m_message_bg:addChild(self.m_text);
    local w,h = self.m_message_bg:getSize();
    w = math.max(w,64);
    h = math.max(h,64);
    self.m_message_bg:setSize(w,h);

    local itemW = HallChatRoomItem.s_width;
    local itemH = select(2,self.m_message_bg:getSize()) + select(2,self.m_icon_frame:getSize()) + select(2,self.m_time_bg:getSize());
	self:setSize(itemW,itemH);
end

HallChatRoomItem.dtor = function(self)
    if self.m_userinfo_dialog then
        delete(self.m_userinfo_dialog);
        self.m_userinfo_dialog = nil;
    end;
end


HallChatRoomItem.getUid = function(self)
    return self.m_uid or nil;
end

HallChatRoomItem.getMsgTime = function(self)
    return self.m_time_str or "0";
end

HallChatRoomItem.updateUserData = function(self, data)
    self:loadIcon(data);
    self:setVip(data);
    self:setUserName(data);
    self:setUserLevel(data);
end;

HallChatRoomItem.setUserLevel = function(self,data)
    if data and data.score then
        self.m_user_level:setFile(string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevelByScore(data.score)));
    end;
end;

HallChatRoomItem.returnStrAndWH = function(self, msg)
    local strW, strH = 64,64; -- 默认气泡宽高
    local lens = string.lenutf8(GameString.convert2UTF8(msg) or "");    
    local strMsg = msg;
    if lens > 140 then--限制140字
        lens = 140;
        strMsg = GameString.convert2UTF8(string.subutf8(msg,1,140));
    end;
    local tempMsg = new(Text,msg,0, 0, kAlignLeft,nil,28,80, 80, 80);
    local tempMsgW, tempMsgH = tempMsg:getSize();
    if tempMsgW ~= 0 and tempMsgH ~= 0 then
        if tempMsgW >= 448 then -- 448,32字符宽，14个字
            tempMsgW = 448;
        elseif tempMsgW <= 64 then
            tempMsgW = 64;
        end;
        return strMsg,tempMsgW, tempMsgH;
    end;
    delete(tempMsg)
    return strMsg, strW, strH;
end;

HallChatRoomItem.loadIcon = function(self,data)
    local icon = data.icon_url;
    if not self.m_user_icon then
        if not icon then 
            if data.iconType > 0 then
                icon = UserInfo.DEFAULT_ICON[data.iconType] or UserInfo.DEFAULT_ICON[1];
            else
                icon = UserInfo.DEFAULT_ICON[1]
            end;
            self.m_user_icon = new(Mask,icon ,"common/background/head_mask_bg_46.png");
        else
            self.m_user_icon = new(Mask,"drawable/blank.png" ,"common/background/head_mask_bg_46.png");
            self.m_user_icon:setUrlImage(icon,UserInfo.DEFAULT_ICON[1]);            
        end;
        self.m_user_icon:setSize(46,46);
        self.m_user_icon:setAlign(kAlignCenter);
        self.m_icon_frame:addChild(self.m_user_icon)
    else
        if not icon then 
            if data.iconType > 0 then
                icon = UserInfo.DEFAULT_ICON[data.iconType] or UserInfo.DEFAULT_ICON[1];
            else
                icon = UserInfo.DEFAULT_ICON[1]
            end;
            self.m_user_icon:setFile(icon);
        else
            self.m_user_icon:setUrlImage(icon,UserInfo.DEFAULT_ICON[1]);            
        end;   
    end   
end;

HallChatRoomItem.setVip = function(self, data)
    if data.my_set then
        local frameRes = UserSetInfo.getInstance():getFrameRes(data.my_set.picture_frame or "sys");
        self.m_vip_frame:setVisible(frameRes.visible);
        local fw,fh = self.m_vip_frame:getSize();
        if frameRes.frame_res then
            self.m_vip_frame:setFile(string.format(frameRes.frame_res,fw));
        end
    end
    if data and data.is_vip == 1 then
        local itemX, itemY = 10, 30;
        local vw,vh = self.m_vip_logo:getSize();
        self.m_name_text:setText(self.m_name,nil,nil,200,40,40)
        if data.mid and tonumber(data.mid) == UserInfo.getInstance():getUid() then
            self.m_name_text:setPos(itemX + 120,itemY + 10);
        else
            self.m_name_text:setPos(itemX + 125 + vw,itemY + 10);
        end;
        self.m_vip_logo:setVisible(true);
    else
        self.m_name_text:setText(self.m_name,nil,nil,100,100,100)
    end;    
end;

HallChatRoomItem.setUserName = function(self,data)
    if data and data.mnick then
        self.m_name_text:setText(data.mnick or "博雅象棋");
    end;
end;



HallChatRoomItem.getTime = function(self, time)
    if ToolKit.isSecondDay(time) then
        return os.date("%m-%d %H:%M",time);
    else
        return os.date("%H:%M",time);--%Y/%m/%d %X
    end;
end

HallChatRoomItem.onItemClick = function(self)
    Log.i("HallChatRoomItem.onItemClick--icon click!");
    if self.m_uid == UserInfo.getInstance():getUid() then
        Log.i("HallChatRoomItem.onItemClick--icon click yourself!");
    else
        if not self.m_userinfo_dialog then
            -- TODO UserInfoDialog2 从场景中分离出来的dlg,后续会同步到联网对战
            self.m_userinfo_dialog = new(UserInfoDialog2);
        end;
        if self.m_userinfo_dialog:isShowing() then return end
        local retType = UserInfoDialog2.SHOW_TYPE.CHAT_ROOM
        local id = tonumber(self.m_uid) or 0
        if UserInfo.getInstance():getUid() == id then
            retType = UserInfoDialog2.SHOW_TYPE.ONLINE_ME
        end
        self.m_userinfo_dialog:setShowType(retType)
        self.m_userinfo_dialog:setReportInfo(self.reportData)
        local user = FriendsData.getInstance():getUserData(id);
        self.m_userinfo_dialog:show(user,id);
    end
end

HallChatRoomSchemesItem = class(Node)

function HallChatRoomSchemesItem.ctor(self,handler,data,event,params)
    local msgData = params.msgData
    
    if msgData.method == "gotoCustomEndgateRoom"  then
        self.mRoot = SceneLoader.load(hall_chat_room_schemes_item2);
    elseif msgData.method == "showSociatyInfoDialog"  then
        self.mRoot = SceneLoader.load(hall_chat_room_schemes_item2);
    else
        self.mRoot = SceneLoader.load(hall_chat_room_schemes_item);
    end

    self.mHandler = handler;
    local w,h = self.mRoot:getSize();
    self:setSize(w,h);
    self:addChild(self.mRoot);
    self.mOwnView = self.mRoot:getChildByName("own_view");
    self.mOtherView = self.mRoot:getChildByName("other_view");
    self.mIconBtn = self.mOtherView:getChildByName("icon");
    self.mIconBtn:setOnClick(self,self.onItemClick);
    self.mClickBtn = self.mRoot:getChildByName("click_btn");
    self.mClickBtn:setOnClick(self,function()
            self.mHandler:dismiss();
            event();
        end
    );
    self.mClickBtn:setSrollOnClick();
    self.mData = data;
    if data.send_uid == UserInfo.getInstance():getUid() then
        self.mName = UserInfo.getInstance():getName();
	    self.mStr = data.msg;
        self.mUid = data.send_uid;
        self.mTimeStr = data.time;
        self.mOwnView:setVisible(true);
        self.mOtherView:setVisible(false);
        self.mView = self.mOwnView;
        self.mUserData = {};
        self.mUserData.iconType = UserInfo.getInstance():getIconType();
        self.mUserData.icon_url = UserInfo.getInstance():getIcon();
        self.mUserData.is_vip   = UserInfo.getInstance():getVip();
    else
        self.mUserData = FriendsData.getInstance():getUserData(data.send_uid);
        self.mName = data.mnick;
	    self.mStr = data.msg;
        self.mUid = data.send_uid;
        self.mTimeStr = data.time;
        self.mOwnView:setVisible(false);
        self.mOtherView:setVisible(true);
        self.mView = self.mOtherView;
    end

    self.mNameView = self.mView:getChildByName("name");
    self.mNameView:setText(self.mName,nil,nil,100,100,100);

    self.mIconFrame = self.mView:getChildByName("icon"):getChildByName("mask");
    self.mVipFrame  = self.mView:getChildByName("icon"):getChildByName("vip");
    self.mLevelFrame  = self.mView:getChildByName("icon"):getChildByName("level");
    if data.send_uid == UserInfo.getInstance():getUid() then
        self.mLevelFrame:setFile(string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getLevel()));
    end;
    self.mIconView = self.mView:getChildByName("bg"):getChildByName("icon_view");
    self.mBoardBg = new(Image,params.icon_img)
    self.mBoardBg:setAlign(kAlignCenter)
    self.mIconView:addChild(self.mBoardBg)

    self.mTitle = self.mView:getChildByName("bg"):getChildByName("title");
    self.mTitle:setText(params.title or "");
    self.mContent  = self.mView:getChildByName("bg"):getChildByName("content");
    local width,height = self.mContent:getSize();
    self.mRichText = new(RichText,params.content or "", width, height, kAlignTopLeft, fontName, 24, 100, 100, 100, true,10);
    self.mContent:addChild(self.mRichText);
    self:updateUserData(self.mUserData);

    if self:checkOverdue() then
        self:setPickable(false);
        self.mTitle:setText("");
    end

    if msgData.method == "gotoCustomEndgateRoom"  then
        local w,h = self.mIconView:getSize()
        self.mBoardBg:setSize(w,h)
        if type(msgData) == "table" then
            local sendData = {}
            sendData.booth_id = msgData.booth_id;
            delete(self.mHttp)
            self.mHttp = HttpModule.getInstance():execute2(HttpModule.s_cmds.WulinBoothGetBoothInfo,sendData,function(isSuccess,resultStr,httpRequest)
                if isSuccess then
                    local jsonData = json.decode(resultStr)
                    local data = jsonData.data
                    if type(data) ~= "table" then return end
                    if type(data.mnick) == "string" then 
                        self.mTitle:setText( string.format("创建者：%s",data.mnick or ""))
                    end
                    if type(data.booth_title) == "string" then 
                        local width,height = self.mContent:getSize();
                        delete(self.mRichText)
                        self.mRichText = new(RichText, string.format("#s30#c323232%s#n#l邀您挑战街边残局",data.booth_title or ""), width, height, kAlignLeft, fontName, 24, 100, 100, 100, true,5);
                        self.mContent:addChild(self.mRichText);
                    end
                    if type(data.booth_fen) == "string" then
                        local w,h = self.mBoardBg:getSize()
                        self.mBoardBg:removeAllChildren()
                        local board = new(Board,w,h,self)
                        Board.resetFenPiece();
                        local chess_map = board:fen2chessMap(data.booth_fen);
                        board:copyChess90(chess_map);
                        board:setPickable(false);
                        self.mBoardBg:addChild(board)
                    end
                end
            end);
        end
    elseif msgData.method == "showSociatyInfoDialog"  then
        self:setPickable(true);
        self.mTitle:setText(params.title);
        delete(self.mHttp)
        if msgData.sociaty_id then
            local data = {};
            local ret = {};
            ret.guild_id = msgData.sociaty_id;
            data.param = ret;
            self.mHttp = HttpModule.getInstance():execute2(HttpModule.s_cmds.getSociatyInfo,data,function(isSuccess,resultStr)--,httpRequest)
                if isSuccess then
                    local jsonData = json.decode(resultStr)
                    local errorMsg = jsonData.error
                    if errorMsg then
                        return
                    end
                    local data = jsonData.data
                    if type(data) ~= "table" then return end
                    if type(data.gm_mnick) == "string" then 
                        self.mTitle:setText( string.format("社长：%s",data.gm_mnick or ""))
                    end
                    if type(data.name) == "string" and type(data.id) == "string" then 
                        local width,height = self.mContent:getSize();
                        delete(self.mRichText)
                        self.mRichText = new(RichText, string.format("#s30#c323232%s#n#l#s22#c969696ID %d#n#l邀您加入棋社",data.name or "",data.id or 0), width, height, kAlignLeft, fontName, 24, 100, 100, 100, true,5);
                        self.mContent:addChild(self.mRichText);
                    end
                end
            end)
        end
    else
        local w,h = self.mIconView:getSize()
        self.mBoardBg:setSize(w,h)
    end
end

function HallChatRoomSchemesItem.dtor(self)
    delete(self.mHttp)
end

function HallChatRoomSchemesItem.checkOverdue(self)
    -- 过期隐藏
    if self.mData and tonumber(self.mData.time) then
        local time = tonumber(self.mData.time);
        if TimerHelper.getServerCurTime() - time > 3*60 then
--            self:setTransparency(0.8);
            return true
        end
    end
end

function HallChatRoomSchemesItem.updateUserData(self, data)
    self:loadIcon(data);
    self:setVip(data);
    self:setUserName(data);
    self:setUserLevel(data);
end

function HallChatRoomSchemesItem.loadIcon(self,data)
    if type(data) ~= "table" then return end
    local icon = data.icon_url;
    if not self.mUserIcon then
        if not icon then 
            if data.iconType > 0 then
                icon = UserInfo.DEFAULT_ICON[data.iconType] or UserInfo.DEFAULT_ICON[1];
            else
                icon = UserInfo.DEFAULT_ICON[1]
            end
            self.mUserIcon = new(Mask,icon ,"common/background/head_mask_bg_86.png");
        else
            self.mUserIcon = new(Mask,"drawable/blank.png" ,"common/background/head_mask_bg_86.png");
            self.mUserIcon:setUrlImage(icon,UserInfo.DEFAULT_ICON[1]);            
        end;
        self.mUserIcon:setSize(80,80);
        self.mUserIcon:setAlign(kAlignCenter);
--        self.mUserIcon:setEventTouch(self,self.onTouchUserIcon);
        self.mIconFrame:addChild(self.mUserIcon)
    else
        if not icon then 
            if data.iconType > 0 then
                icon = UserInfo.DEFAULT_ICON[data.iconType] or UserInfo.DEFAULT_ICON[1];
            else
                icon = UserInfo.DEFAULT_ICON[1]
            end;
            self.mUserIcon:setFile(icon);
        else
            self.mUserIcon:setUrlImage(icon,UserInfo.DEFAULT_ICON[1]);            
        end
    end
end

function HallChatRoomSchemesItem.setVip(self, data)
    if data and data.is_vip == 1 then
        self.mNameView:setText(self.mName,nil,nil,200,40,40)
        self.mVipFrame:setVisible(true);
    else
        self.mNameView:setText(self.mName,nil,nil,100,100,100);
        self.mVipFrame:setVisible(false);
    end  
end

function HallChatRoomSchemesItem.setUserName(self,data)
    if data and data.mnick then
        self.mNameView:setText(data.mnick or "博雅象棋");
    end;
end;

function HallChatRoomSchemesItem.setUserLevel(self,data)
    if data and data.score then
        self.mLevelFrame:setFile(string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevelByScore(data.score)));
    end;
end;

function HallChatRoomSchemesItem.getUid(self)
    return self.mUid or nil;
end

function HallChatRoomSchemesItem.getMsgTime(self)
    return self.mTimeStr or "0";
end

function HallChatRoomSchemesItem.onItemClick(self)
    Log.i("HallChatRoomInviteItem.onItemClick--icon click!");
    if self.mUid == UserInfo.getInstance():getUid() then
        Log.i("HallChatRoomInviteItem.onItemClick--icon click yourself!");
    else
        if not self.m_userinfo_dialog then
            -- TODO UserInfoDialog2 从场景中分离出来的dlg,后续会同步到联网对战
            self.m_userinfo_dialog = new(UserInfoDialog2);
        end;
        if self.m_userinfo_dialog:isShowing() then return end
        local retType = UserInfoDialog2.SHOW_TYPE.CHAT_ROOM
        local id = tonumber(self.mUid) or 0
        if UserInfo.getInstance():getUid() == id then
            retType = UserInfoDialog2.SHOW_TYPE.ONLINE_ME
        end
        self.m_userinfo_dialog:setShowType(retType)
        self.m_userinfo_dialog:setReportInfo(self.reportData)
        local user = FriendsData.getInstance():getUserData(id);
        self.m_userinfo_dialog:show(user,id);
    end
end


-- 聊天室约战item
HallChatRoomInviteItem = class(Node)
HallChatRoomInviteItem.s_width = 650;
--scene 就是指HallChatDialog本身
HallChatRoomInviteItem.ctor = function(self, data, scene)
    self.m_root = SceneLoader.load(chess_room_invite_item);
    self:addChild(self.m_root);
    self.m_data = data;
    self.m_scene = scene;
    self.m_other_data = self.m_data.other;
    local w,h = self.m_root:getSize();
    self:setSize(w,h);
    self:initView();
    self:init();
    self:initUserInfo();
    self:initItemInfo();
end

HallChatRoomInviteItem.dtor = function(self)

end


HallChatRoomInviteItem.initView = function(self)
    -- other
    self.m_other_view = self.m_root:getChildByName("other");
    self.m_other_bg = self.m_other_view:getChildByName("other_bg");
    self.m_other_item_bg = self.m_other_bg:getChildByName("bg");
    self.m_other_btn = self.m_other_view:getChildByName("user");
    self.m_other_btn:setOnClick(self,self.onItemClick);
    self.m_other_user_mask = self.m_other_btn:getChildByName("mask");
    self.m_other_user_vip = self.m_other_btn:getChildByName("vip");
    self.m_other_user_name = self.m_other_btn:getChildByName("name");
    self.m_other_user_level = self.m_other_btn:getChildByName("level");

    -- self
    self.m_self_view = self.m_root:getChildByName("self");
    self.m_self_bg = self.m_self_view:getChildByName("self_bg");
    self.m_self_item_bg = self.m_self_bg:getChildByName("bg");
    self.m_self_btn = self.m_self_view:getChildByName("user");
    self.m_self_user_mask = self.m_self_btn:getChildByName("mask");
    self.m_self_user_vip = self.m_self_btn:getChildByName("vip");
    self.m_self_user_name = self.m_self_btn:getChildByName("name");
    self.m_self_user_level = self.m_self_btn:getChildByName("level");

    -- content
    self.m_content_view = self.m_root:getChildByName("content");
    self.m_content_user = self.m_content_view:getChildByName("user");
    self.m_left_user_fight = self.m_content_user:getChildByName("left_fight");
    self.m_left_user = self.m_content_user:getChildByName("left_user");
    self.m_left_user_mask = self.m_left_user:getChildByName("mask");
    self.m_left_user_vip = self.m_left_user:getChildByName("vip");
    self.m_left_user_name = self.m_left_user:getChildByName("name");
    self.m_left_user_level = self.m_left_user:getChildByName("level");
    self.m_left_user_flag_txt = self.m_left_user:getChildByName("flag_txt");

    self.m_right_user_fight = self.m_content_user:getChildByName("right_fight");
    self.m_right_user = self.m_content_user:getChildByName("right_user");
    self.m_right_user_mask = self.m_right_user:getChildByName("mask");
    self.m_right_user_vip = self.m_right_user:getChildByName("vip");
    self.m_right_user_name = self.m_right_user:getChildByName("name");
    self.m_right_user_level = self.m_right_user:getChildByName("level");
    self.m_right_user_flag_txt = self.m_right_user:getChildByName("flag_txt");

    self.m_middle_view = self.m_content_user:getChildByName("middle");
    self.m_action_btn = self.m_middle_view:getChildByName("btn");
    self.m_action_btn_bg = self.m_action_btn:getChildByName("bg");
    self.m_action_txt = self.m_action_btn:getChildByName("txt");
    self.m_vs = self.m_middle_view:getChildByName("vs");
    self.m_vs_txt = self.m_middle_view:getChildByName("txt");
    self.m_bottom_view = self.m_content_view:getChildByName("bottom");
    self.m_bet =  self.m_bottom_view:getChildByName("bet");
    self.m_time =  self.m_bottom_view:getChildByName("time");

    self.m_content_invite = self.m_content_view:getChildByName("invite");
    self.m_content_invite_btn = self.m_content_invite:getChildByName("btn");
    self.m_content_invite_btn:setOnClick(self,function(self)
        self.m_scene:isActionAvaliable(self,function(self) 
            if self:isCanJoinChessMatch() then
                self:sendJoin();
            end;
        end);
    end);
end;

HallChatRoomInviteItem.init = function(self)
    self.m_time_str = self.m_data.time;
    self.m_uid = self.m_data.send_uid;
    self.m_name = self.m_data.mnick;
end;

function HallChatRoomInviteItem.updateItemWithData(self,data)
    self.m_data = data;
    self.m_other_data = self.m_data.other;
    self:init();
    self:initUserInfo();
    self:initItemInfo();
end 

HallChatRoomInviteItem.initUserInfo = function(self)
    if self.m_data.send_uid == UserInfo.getInstance():getUid() then
        self.m_self_view:setVisible(true);
        self.m_other_view:setVisible(false);
        self.m_content_view:setPos(-20);
        self.m_user_icon = self:initUser();
        self.m_user_icon:setUrlImage(UserInfo.getInstance():getIcon());
        self.m_user_icon:setSize(80,80);
        self.m_self_user_mask:addChild(self.m_user_icon);
        self.m_self_user_name:setText(UserInfo.getInstance():getName());
        if UserInfo.getInstance():getIsVip() == 1 then
            self.m_self_user_name:setColor(200,40,40);
        else
            self.m_self_user_name:setColor(100,100,100);
        end;
        self.m_self_user_level:setFile("common/icon/level_"..(10 - tonumber(UserInfo.getInstance():getLevel()))..".png");
        self.m_self_user_vip:addChild(self:loadVip());
    else
        self.m_self_view:setVisible(false);
        self.m_other_view:setVisible(true);
        self.m_content_view:setPos(12);
        self.m_friend_info = FriendsData.getInstance():getUserData(self.m_data.send_uid);
        self:updateOtherInfo(self.m_friend_info);
    end
end

HallChatRoomInviteItem.updateOtherInfo = function(self,data)
    if data then
        self.m_other_user_mask:addChild(self:loadIcon(data));
        self.m_other_user_name:setText(data.mnick);
        if data.is_vip == 1 then
            self.m_other_user_name:setColor(200,40,40);
        else
            self.m_other_user_name:setColor(100,100,100);
        end;
        self.m_other_user_level:setFile(string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevelByScore(data.score)));
        self.m_other_user_vip:addChild(self:loadVip(data));    
    else
        self.m_other_user_mask:addChild(self:loadIcon());
        self.m_other_user_name:setText(self.m_data.mnick or "博雅象棋");
    end
end

HallChatRoomInviteItem.updateItemRightUserInfo = function(self,data)
    if data then
        self.m_right_user_mask:addChild(self:loadIcon(data));
        self.m_right_user_name:setText(self:returnBriefName(data.mnick));
        if data.is_vip == 1 then
            self.m_right_user_name:setColor(200,40,40);
        end;
        self.m_right_user_level:setFile(string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevelByScore(data.score)));
    else
        self.m_right_user_mask:addChild(self:loadIcon());
        self.m_right_user_name:setText("博雅象棋");
    end;
end;

HallChatRoomInviteItem.updateItemLeftUserInfo = function(self,data)
    if data then
        self.m_left_user_mask:addChild(self:loadIcon(data));
        self.m_left_user_name:setText(self:returnBriefName(data.mnick));
        if data.is_vip == 1 then
            self.m_left_user_name:setColor(200,40,40);
        end;
        self.m_left_user_level:setFile(string.format("common/icon/level_%d.png",10-UserInfo.getInstance():getDanGradingLevelByScore(data.score)));   
    else
        self.m_left_user_mask:addChild(self:loadIcon());
        self.m_left_user_name:setText("博雅象棋");
    end;
end;

HallChatRoomInviteItem.initUser = function(self)
    local icon = new(Mask,"common/background/head_mask_bg_86.png","common/background/head_mask_bg_86.png")
    icon:setFile(UserInfo.DEFAULT_ICON[1]);
    icon:setAlign(kAlignCenter);    
    return icon;
end;

HallChatRoomInviteItem.initItemInfo = function(self)
    self:initItemUser();
    self:setContentBtnStatus();
    self:initBottomInfo();
end;

HallChatRoomInviteItem.initItemUser = function(self)
    if self.m_data.send_uid == UserInfo.getInstance():getUid() then
        self.m_item_left_user_icon = self:initUser();
        self.m_item_left_user_icon:setUrlImage(UserInfo.getInstance():getIcon());
        self.m_left_user_mask:addChild(self.m_item_left_user_icon);
        self.m_left_user_name:setText(self:returnBriefName(UserInfo.getInstance():getName()));
        if UserInfo.getInstance():getIsVip() == 1 then
            self.m_left_user_name:setColor(200,40,40);
        else
            self.m_left_user_name:setColor(220,200,170);
        end;
        self.m_left_user_level:setFile("common/icon/level_"..(10 - tonumber(UserInfo.getInstance():getLevel()))..".png");
    else
        local itemLeftUser = FriendsData.getInstance():getUserData(self.m_data.send_uid);
        self:updateItemLeftUserInfo(itemLeftUser);
    end;
    if tonumber(self.m_other_data.status) == 1 then
        if self.m_data.msgtype == 2 then -- 1对1抢先约战
            self.m_right_user_fight:setVisible(true);
            self.m_right_user:setVisible(false);
        elseif self.m_data.msgtype == 3 then -- 1对1指定约战
            self.m_right_user_fight:setVisible(false);
            self.m_right_user:setVisible(true);
            local data = FriendsData.getInstance():getUserData(self.m_other_data.a_uid);
            self:updateItemRightUserInfo(data);
        end;
        if tonumber(self.m_other_data.c_uid) == UserInfo.getInstance():getUid() and tonumber(self.m_other_data.tid) > 0 then
            self.m_scene:loadWaitingItem(self,true);
        elseif tonumber(self.m_other_data.a_uid) == UserInfo.getInstance():getUid() and tonumber(self.m_other_data.tid) > 0 then
            self:showInviteDialog();
        end;
    elseif tonumber(self.m_other_data.status) > 1 then
        self.m_right_user_fight:setVisible(false);
        self.m_right_user:setVisible(true);
        local itemRightUser = FriendsData.getInstance():getUserData(self.m_other_data.a_uid);
        self:updateItemRightUserInfo(itemRightUser);
        if tonumber(self.m_other_data.status) == 2 then
            if tonumber(self.m_other_data.c_uid) == UserInfo.getInstance():getUid() and tonumber(self.m_other_data.tid) > 0 then
                self.m_scene:loadWaitingItem(self,false);
            end;
        elseif tonumber(self.m_other_data.status) == 7 then
            if tonumber(self.m_other_data.c_uid) == UserInfo.getInstance():getUid() and tonumber(self.m_other_data.tid) > 0 then
                self.m_scene:setCurChessMatchItem(self);
                ChessToastManager.getInstance():showSingle("对方拒绝了你的挑战邀请",2000);
            end;           
        elseif tonumber(self.m_other_data.status) == 3 then
            if self.m_other_data.r_uid and self.m_other_data.b_uid then
                if self.m_other_data.r_uid == self.m_other_data.c_uid then -- c_uid:leftUser
                    self.m_left_user_name:setColor(185,15,15);
                    self.m_right_user_name:setColor(70,70,70);
                else
                    self.m_left_user_name:setColor(70,70,70);
                    self.m_right_user_name:setColor(185,15,15);                    
                end;
            end;
        end;
    end;
end;

HallChatRoomInviteItem.setContentBtnStatus = function(self)
    --1	未知状态	int	4	未知状态为0
    --2	等待应战	int	4	状态值为1
    --3	已入场一人	int	4	状态值为2
    --4	对局中	    int	4	状态值为3
    --5	约战结束	int	4	状态值为4
    --6	约战已过期	int	4	状态值为5
    --7	约战已取消	int	4	状态值为6
    if not self.m_other_data then return end;
    if tonumber(self.m_other_data.status) == 1 then
        if self.m_data.send_uid == UserInfo.getInstance():getUid() or self.m_data.msgtype == 3 then
            self.m_action_btn:setOnClick(self,function() 
                ChessToastManager.getInstance():showSingle("请等待棋友应战");
            end);
            self.m_self_item_bg:setFile("common/background/message_red_self.png");
--            self.m_action_btn:setFile("common/button/chat_room_wait.png");
            self.m_action_btn_bg:setFile("common/button/chat_room_wait.png");
            self.m_action_txt:setText("等待应战");
        else
            self.m_other_item_bg:setFile("common/background/message_red_other.png");
            self.m_content_invite:setVisible(true);
            self.m_content_user:setVisible(false);
        end;
        self:updateItemStatus();
    elseif tonumber(self.m_other_data.status) == 2 then
        self:updateItemStatus();
    elseif tonumber(self.m_other_data.status) == 3 then
        self.m_action_btn:setOnClick(self,function(self) 
            ToolKit.schedule_once(self,function() -- 观战延迟1s进入，防止upUser拉不到
                self.m_scene:isActionAvaliable(self,function(self) 
                    ChessDialogManager.dismissAllDialog();
                    ToolKit.schedule_once(self,function() 
                        if UserInfo.getInstance():isFreezeUser() then return end;
                        local roomData = RoomConfig.getInstance():getRoomTypeConfig(RoomConfig.ROOM_TYPE_PRIVATE_ROOM);
                        RoomProxy.getInstance():gotoWatchRoom(self.m_other_data.tid,roomData.level);
                    end,200);
                end);            
            end,1000);
        end);
        self.m_other_item_bg:setFile("common/background/message_green_other.png");
--        self.m_action_btn:setFile("common/button/chat_room_join.png");
        self.m_action_btn_bg:setFile("common/button/chat_room_join.png");
        self.m_action_txt:setText("观战");
        self:updateItemStatus();
    elseif tonumber(self.m_other_data.status) == 4 then
        self.m_scene:getChatRoomManualInfo(self.m_other_data.rec_id,function(data) 
            if not data or not next(data) then return end;
            self.m_dapu_data = data;
            self:setChessDapuWinFlag(data);
        end);
        self.m_action_btn:setOnClick(self,function(self) 
            self.m_scene:isActionAvaliable(self,function(self) 
                if self.m_dapu_data and next(self.m_dapu_data) then
                    ChessDialogManager.dismissAllDialog();
                    ToolKit.schedule_once(self,function() 
                        UserInfo.getInstance():setDapuSelData(self.m_dapu_data);
                        RoomProxy.getInstance():gotoReplayRoom();
                    end,200);
                else
                    ChessToastManager.getInstance():showSingle("棋谱数据出错了");
                end;
            end);
        end);
        self.m_self_item_bg:setFile("common/background/message_yellow_self.png");
        self.m_other_item_bg:setFile("common/background/message_yellow_other.png");
--        self.m_action_btn:setFile("common/button/chat_room_watch.png");
        self.m_action_btn_bg:setFile("common/button/chat_room_watch.png");
        self.m_action_txt:setText("查看棋谱");
        self:updateItemStatus();
    elseif tonumber(self.m_other_data.status) == 5 then
        self.m_action_btn:setOnClick(self,function() 
            -- 删除
        end);
        self.m_self_item_bg:setFile("common/background/message_yellow_self.png");
        self.m_other_item_bg:setFile("common/background/message_yellow_self.png");
--        self.m_action_btn:setFile("common/button/chat_room_wait.png");
        self.m_action_btn_bg:setFile("common/button/chat_room_wait.png");
        self.m_action_txt:setText("已过期");
    elseif tonumber(self.m_other_data.status) == 6 then -- 已取消约战
    elseif tonumber(self.m_other_data.status) == 7 then -- 已拒绝1v1约战
--        self.m_action_btn:setFile("common/button/chat_room_wait.png");
        self.m_action_btn_bg:setFile("common/button/chat_room_wait.png");
        self.m_action_txt:setText("已拒绝");
        self.m_action_btn:setOnClick(self,function()end);
        self:updateItemStatus();
    end;
end;

HallChatRoomInviteItem.isCanJoinChessMatch = function(self)
    if UserInfo.getInstance():isFreezeUser() then return end;
    local money = UserInfo.getInstance():getMoney();
	local isCanAccess = RoomProxy.getInstance():checkCanJoinRoom(RoomConfig.ROOM_TYPE_PRIVATE_ROOM,money);
	if not isCanAccess then
        ChessToastManager.getInstance():showSingle("您的金币不足，不能加入挑战");
		return;
	end    
    return true;
end;

HallChatRoomInviteItem.updateItemStatus = function(self)
    -- 更新本地消息状态
--    self.m_scene:updateItemStatus(self.m_data.room_id,self.m_data.msg_id);
end;

HallChatRoomInviteItem.updateSelf = function(self)
--    self.m_action_btn:setFile("common/button/chat_room_wait.png");
    self.m_action_btn_bg:setFile("common/button/chat_room_wait.png");
    self.m_action_txt:setText("已过期");
    self.m_action_btn:setOnClick(self,function()end);
    self.m_other_data.rm_msgid = self.m_data.msg_id;
    self.m_data.other = json.encode(self.m_other_data);
    ChatRoomData.getInstance():deleteRoomMsg(self.m_data,self.m_data.room_id);
    if self.m_other_data.status == 1 and self.m_other_data.c_uid == UserInfo.getInstance():getUid() then
        EffectAnim.scrollUp(self,self.m_scene.m_hall_chat_room_mask,200);
    end;
end

HallChatRoomInviteItem.setChessDapuWinFlag = function(self,data)
    self.m_left_user_flag_txt:setVisible(true);
    self.m_right_user_flag_txt:setVisible(true);
    self.m_vs_txt:setVisible(true);
    self.m_vs:setVisible(false)
    if self.m_other_data.a_uid == data.red_mid then -- a_uid是itemRightUser
        if data.win_flag == 0 then -- 和棋
            self.m_left_user_flag_txt:setText("和");
            self.m_left_user_flag_txt:setColor(25,115,45);
            self.m_right_user_flag_txt:setText("和");
            self.m_right_user_flag_txt:setColor(25,115,45);
            self.m_left_user_name:setColor(70,70,70);
            self.m_right_user_name:setColor(185,15,15);
        elseif data.win_flag == 1 then-- 红胜
            self.m_left_user_flag_txt:setText("负");
            self.m_left_user_flag_txt:setColor(70,70,70);
            self.m_left_user_name:setColor(70,70,70);
            self.m_right_user_flag_txt:setText("胜");
            self.m_right_user_flag_txt:setColor(185,15,15);
            self.m_right_user_name:setColor(185,15,15);
        elseif data.win_flag == 2 then-- 黑胜
            self.m_left_user_flag_txt:setText("胜");
            self.m_left_user_flag_txt:setColor(185,15,15);
            self.m_left_user_name:setColor(185,15,15);
            self.m_right_user_flag_txt:setText("负");
            self.m_right_user_flag_txt:setColor(70,70,70);
            self.m_right_user_name:setColor(70,70,70);
        else
            self.m_left_user_flag_txt:setVisible(false);
            self.m_right_user_flag_txt:setVisible(false);            
        end
    elseif self.m_other_data.a_uid == data.black_mid then
         if data.win_flag == 0 then -- 和棋
            self.m_left_user_flag_txt:setText("和");
            self.m_left_user_flag_txt:setColor(25,115,45);
            self.m_right_user_flag_txt:setText("和");
            self.m_right_user_flag_txt:setColor(25,115,45);
            self.m_left_user_name:setColor(185,15,15);
            self.m_right_user_name:setColor(70,70,70);
        elseif data.win_flag == 1 then-- 红胜
            self.m_left_user_flag_txt:setText("胜");
            self.m_left_user_flag_txt:setColor(185,15,15);
            self.m_left_user_name:setColor(185,15,15);
            self.m_right_user_flag_txt:setText("负");
            self.m_right_user_flag_txt:setColor(70,70,70);
            self.m_right_user_name:setColor(70,70,70);
        elseif data.win_flag == 2 then-- 黑胜
            self.m_left_user_flag_txt:setText("负");
            self.m_left_user_flag_txt:setColor(70,70,70);
            self.m_left_user_name:setColor(70,70,70);
            self.m_right_user_flag_txt:setText("胜");
            self.m_right_user_flag_txt:setColor(185,15,15);
            self.m_right_user_name:setColor(185,15,15);
        else
            self.m_left_user_flag_txt:setVisible(false);
            self.m_right_user_flag_txt:setVisible(false);            
        end   
    end;
end;

HallChatRoomInviteItem.initBottomInfo = function(self)
    if not self.m_other_data then return end;
    self.m_bet:setText(self.m_other_data.base .. "底注");
    self.m_time:setText(self.m_other_data.rd_t .. "分钟制");
end;

HallChatRoomInviteItem.getMsgId = function(self)
    return self.m_data.msg_id;
end;

HallChatRoomInviteItem.getRoomId = function(self)
    return self.m_data.room_id;
end;

HallChatRoomInviteItem.sendJoin = function(self)
    local msgdata = {};
	msgdata.room_id = self.m_data.room_id;
	msgdata.msg = self:formatSendTime().." 有人应战了，升级新版本可加入观战";
	msgdata.name = UserInfo.getInstance():getName();
	msgdata.uid = UserInfo.getInstance():getUid();
    msgdata.msg_type = self.m_data.msgtype;
    --详见文档:http://jd.oa.com/wiki/index.php?title=象棋_Server协议文档#.E8.81.8A.E5.A4.A9.E5.AE.A4.E7.BA.A6.E6.88.98.E5.8D.8F.E8.AE.AE.E6.96.87.E6.A1.A3
    local other = {};
    other.tid = self.m_other_data.tid or 0;
    other.c_uid = self.m_data.send_uid;
    other.a_uid = UserInfo.getInstance():getUid();
    other.pwd = self.m_other_data.pwd or "boyaa_chess";
    other.act = 2;
    other.status = 0;
    other.rm_msgid = self.m_data.msg_id;
    other.rec_id = "";
    other.rd_t = self.m_other_data.rd_t;
    other.step_t = self.m_other_data.step_t;
    other.sec_t = self.m_other_data.sec_t;
    other.base = self.m_other_data.base;
    msgdata.other = json.encode(other);    
    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_USER_CHAT_MSG,msgdata);    
end;

-- 创建者取消约战
HallChatRoomInviteItem.cancelChessMatch = function(self)
    local msgdata = {};
	msgdata.room_id = self.m_data.room_id;
	msgdata.msg = self:formatSendTime().." 我取消了友谊赛邀请，升级新版本可查看详情";
	msgdata.name = UserInfo.getInstance():getName();
	msgdata.uid = UserInfo.getInstance():getUid();
    msgdata.msg_type = self.m_data.msgtype;
    --详见文档:http://jd.oa.com/wiki/index.php?title=象棋_Server协议文档#.E8.81.8A.E5.A4.A9.E5.AE.A4.E7.BA.A6.E6.88.98.E5.8D.8F.E8.AE.AE.E6.96.87.E6.A1.A3
    local other = {};
    other.tid = self.m_other_data.tid;
    other.c_uid = self.m_data.send_uid;
    other.a_uid = UserInfo.getInstance():getUid();
    other.pwd = "boyaa_chess";
    other.act = 5;
    other.status = 1;
    other.rm_msgid = self.m_data.msg_id;
    other.rec_id = "";
    other.rd_t = self.m_other_data.rd_t;
    other.step_t = self.m_other_data.step_t;
    other.sec_t = self.m_other_data.sec_t;
    other.base = self.m_other_data.base;
    msgdata.other = json.encode(other);    
    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_USER_CHAT_MSG,msgdata);    
end;


HallChatRoomInviteItem.creatorEntryChessRoom = function(self)
    local msgdata = {};
	msgdata.room_id = self.m_data.room_id;
	msgdata.msg = self:formatSendTime().." 我正在进行友谊赛，升级新版本可加入观战";
	msgdata.name = UserInfo.getInstance():getName();
	msgdata.uid = UserInfo.getInstance():getUid();
    msgdata.msg_type = 2;
    --详见文档:http://jd.oa.com/wiki/index.php?title=象棋_Server协议文档#.E8.81.8A.E5.A4.A9.E5.AE.A4.E7.BA.A6.E6.88.98.E5.8D.8F.E8.AE.AE.E6.96.87.E6.A1.A3
    local other = {};
    other.tid = self.m_other_data.tid;
    other.c_uid = self.m_data.send_uid;
    other.a_uid = UserInfo.getInstance():getUid();
    other.pwd = "boyaa_chess";
    other.act = 3;
    other.status = 2;
    other.rm_msgid = self.m_data.msg_id;
    other.rec_id = "";
    other.rd_t = self.m_other_data.rd_t;
    other.step_t = self.m_other_data.step_t;
    other.sec_t = self.m_other_data.sec_t;
    other.base = self.m_other_data.base;
    msgdata.other = json.encode(other);    
    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_USER_CHAT_MSG,msgdata);    
end;

HallChatRoomInviteItem.refuseInvite = function(self)
    local msgdata = {};
	msgdata.room_id = self.m_data.room_id;
	msgdata.msg = self:formatSendTime().." 拒绝了邀请，升级新版本可加入观战";
	msgdata.name = UserInfo.getInstance():getName();
	msgdata.uid = UserInfo.getInstance():getUid();
    msgdata.msg_type = 3;
    --详见文档:http://jd.oa.com/wiki/index.php?title=象棋_Server协议文档#.E8.81.8A.E5.A4.A9.E5.AE.A4.E7.BA.A6.E6.88.98.E5.8D.8F.E8.AE.AE.E6.96.87.E6.A1.A3
    local other = {};
    other.tid = self.m_other_data.tid;
    other.c_uid = self.m_data.send_uid;
    other.a_uid = UserInfo.getInstance():getUid();
    other.pwd = "boyaa_chess";
    other.act = 6;
    other.status = 7;
    other.rm_msgid = self.m_data.msg_id;
    other.rec_id = "";
    other.rd_t = self.m_other_data.rd_t;
    other.step_t = self.m_other_data.step_t;
    other.sec_t = self.m_other_data.sec_t;
    other.base = self.m_other_data.base;
    msgdata.other = json.encode(other);    
    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_USER_CHAT_MSG,msgdata);  
end;

HallChatRoomInviteItem.getUid = function(self)
    return self.m_uid or nil;
end

HallChatRoomInviteItem.getName = function(self)
    return self.m_name or "博雅象棋";
end

HallChatRoomInviteItem.formatSendTime = function(self)
    return os.date("%m/%d %H:%M:%S",os.time())
end;

HallChatRoomInviteItem.updateUserData = function(self, data)
    if not data then return end;
    if data.uid == UserInfo.getInstance():getUid() then return end;
    if data.uid == self.m_data.send_uid or
       data.uid == self.m_other_data.create_id then
       self:updateOtherInfo(data);
       self:updateItemLeftUserInfo(data);
    elseif data.uid == self.m_other_data.a_uid then
        self:updateItemRightUserInfo(data);
    end;
end;

HallChatRoomInviteItem.loadIcon = function(self,data)
    local icon ;
    local user_icon;
    if not data then 
        icon = UserInfo.DEFAULT_ICON[1]
        user_icon = new(Mask,icon ,"common/background/head_mask_bg_86.png");
    else
        if data.iconType > 0 then
            icon = UserInfo.DEFAULT_ICON[data.iconType] or UserInfo.DEFAULT_ICON[1];
            user_icon = new(Mask,icon ,"common/background/head_mask_bg_86.png");
        else
            icon = data.icon_url;
            user_icon = new(Mask,"drawable/blank.png" ,"common/background/head_mask_bg_86.png");
            user_icon:setUrlImage(icon,UserInfo.DEFAULT_ICON[1]);
        end;
    end;
    user_icon:setSize(80,80);
    user_icon:setAlign(kAlignCenter);
    return user_icon; 
end;

HallChatRoomInviteItem.loadVip = function(self, data)
    local frameRes;
    local vip = new(Image,"drawable/blank.png");
    vip:setSize(110,110);
    vip:setAlign(kAlignCenter);
    if not data then
        frameRes = UserSetInfo.getInstance():getFrameRes();
    else
        if data.my_set then
            frameRes = UserSetInfo.getInstance():getFrameRes(data.my_set.picture_frame or "sys");
        end
    end;
    vip:setVisible(frameRes.visible);
    local fw,fh = vip:getSize();
    if frameRes.frame_res then
        vip:setFile(string.format(frameRes.frame_res,fw));
    end
    return vip;   
end;

HallChatRoomInviteItem.returnBriefName = function(self, name)
    local lens = string.lenutf8(GameString.convert2UTF8(name) or ""); 
    local tempName;  
    if lens > 4 then
        tempName = GameString.convert2UTF8(string.subutf8(name,1,3)).."...";
    else
        tempName = name;
    end;
    return tempName;
end;

HallChatRoomInviteItem.setUserName = function(self,data)
    if data and data.mnick then
        self.m_name_text:setText(data.mnick or "博雅象棋");
    end;
end;

HallChatRoomInviteItem.getMsgTime = function(self)
    return self.m_time_str or "0";
end

HallChatRoomInviteItem.getTime = function(self, time)
    if ToolKit.isSecondDay(time) then
        return os.date("%m-%d %H:%M",time);
    else
        return os.date("%H:%M",time);--%Y/%m/%d %X
    end;
end

HallChatRoomInviteItem.onItemClick = function(self)
    Log.i("HallChatRoomInviteItem.onItemClick--icon click!");
    if self.m_uid == UserInfo.getInstance():getUid() then
        Log.i("HallChatRoomInviteItem.onItemClick--icon click yourself!");
    else
        if not self.m_userinfo_dialog then
            -- TODO UserInfoDialog2 从场景中分离出来的dlg,后续会同步到联网对战
            self.m_userinfo_dialog = new(UserInfoDialog2);
        end;
        if self.m_userinfo_dialog:isShowing() then return end
        local retType = UserInfoDialog2.SHOW_TYPE.CHAT_ROOM
        local id = tonumber(self.m_uid) or 0
        if UserInfo.getInstance():getUid() == id then
            retType = UserInfoDialog2.SHOW_TYPE.ONLINE_ME
        end
        self.m_userinfo_dialog:setShowType(retType)
        self.m_userinfo_dialog:setReportInfo(self.reportData)
        local user = FriendsData.getInstance():getUserData(id);
        self.m_userinfo_dialog:show(user,id);
    end
end

HallChatRoomInviteItem.showInviteDialog = function(self)
    local isCanAccess = RoomProxy.getInstance():canAccessRoom(RoomConfig.ROOM_TYPE_FRIEND_ROOM,UserInfo.getInstance():getMoney());
    if not isCanAccess then
        ChessToastManager.getInstance():showSingle( string.format("用户ID:%d向你发起挑战,由于你的金币不足或超出上限,无法接受挑战!",self.m_other_data.c_uid),3000);
        return;
    end

    local friendData = FriendsData.getInstance():getUserData(self.m_other_data.c_uid);

    --根据uid获取用户名和头像
    if not self.m_friendChoiceDialog then
        self.m_friendChoiceDialog = new(FriendChoiceDialog);
    end
    local info = {};
    info.gameTime = self.m_other_data.rd_t;
    info.stepTime = self.m_other_data.step_t;
    info.secondTime = self.m_other_data.sec_t;
    self.m_friendChoiceDialog:setMode(5,friendData,info);
    self.m_friendChoiceDialog:setMaskDialog(true);
    self.m_friendChoiceDialog:setPositiveListener(self,
        function()
            if not UserInfo.getInstance():isFreezeUser() then 
                self:sendJoin();
            end;
        end);
    self.m_friendChoiceDialog:setNegativeListener(self,
        function()
            self:refuseInvite();
        end);
    self.m_friendChoiceDialog:show();    
end;

--棋社系统消息
SociatyChatRoomItem = class(Node)

function SociatyChatRoomItem.ctor(self,data)
    if not data then return end
    self:setSize(660,60)
    self:setAlign(kAlignTop)
    self.m_time = os.time()
    self.bg = new(Image,"common/background/input_bg_3.png",nil,nil,30,30,30,30)
    self.bg:setAlign(kAlignCenter)
    self.bg:setSize(400,50)
    self:addChild(self.bg)

    local msg = data.msg or ""
    self.msg = new(Text,msg,nil,nil,kAlignCenter,nil,24,140,120,90)
    self.msg:setAlign(kAlignCenter)
    self:addChild(self.msg)
end

function SociatyChatRoomItem.dtor(self)
    
end

function SociatyChatRoomItem:getUid()

end

function SociatyChatRoomItem:getMsgId()

end

function SociatyChatRoomItem:getMsgTime()
    return self.m_time
end

