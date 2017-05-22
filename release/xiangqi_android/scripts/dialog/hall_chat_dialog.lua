--region hall_chat_dialog.lua
--Author : LeoLi
--Date   : 2015/11/16

require(VIEW_PATH .. "hall_chat_dialog_view");
require(BASE_PATH.."chessDialogScene")
require(DATA_PATH.."chatRoomData");
require("ui2/compat/scrollView2");
require("dialog/user_info_dialog2")
HallChatDialog = class(ChessDialogScene,false);
-- 弹窗弹出隐藏时间
HallChatDialog.SHOW_ANIM_TIME    = 400;
HallChatDialog.HIDE_ANIM_TIME    = 200;
-- 左进右出动画时间
HallChatDialog.LIRO_ANIM_TIME    = 300;
HallChatDialog.LORI_ANIM_TIME    = 300;
-- 淡入淡出动画时间
HallChatDialog.FADEIN_ANIM_TIME  = 400;
HallChatDialog.FADEOUT_ANIM_TIME = 600;
-- 聊天室/好友私聊
HallChatDialog.PUBLIC_CHAT       = 1;
HallChatDialog.PRAVITE_CHAT      = 0;


-- 场景
HallChatDialog.MAIN_CHAT         = 1;  -- 聊天主界面
HallChatDialog.DASHI_CHAT        = 2;  -- 大师聊天
HallChatDialog.CITY_CHAT         = 3;  -- 同城聊天
HallChatDialog.COMMON_CHAT       = 4;  -- 好友私聊
HallChatDialog.CREATE_CHAT       = 5;  -- 创建会话
HallChatDialog.CITY_MEMBER_CHAT  = 6;  -- 同城成员列表
HallChatDialog.DASHI_MEMBER_CHAT = 7;  -- 大师成员列表
HallChatDialog.WORLD_CHAT        = 8;  -- 世界聊天

HallChatDialog.ctor = function(self, room)
    super(self,hall_chat_dialog_view);
    self.m_room = room;
    self.m_rootW, self.m_rootH = self:getSize();
    self.m_current_view = HallChatDialog.MAIN_CHAT;
    self.m_chatroom_msg_list = {};
    self:initView();
end;

HallChatDialog.dtor = function(self)
    EventDispatcher.getInstance():unregister(Event.Call,self,self.onEventResponse);
end;

HallChatDialog.isShowing = function(self)
    return self:getVisible();
end

---------------------------- function --------------------------------
HallChatDialog.initView = function(self)
    -- bg
    self.m_hall_chat_bg = self.m_root:getChildByName("bg");
    -- hide_btn
    self.m_hide_dialog_btn = self.m_hall_chat_bg:getChildByName("hide_chat_btn");
    self.m_hide_dialog_btn:setOnClick(self, self.dismiss);

    local back_btn_func = function(self,enable)
        local view = self:getChildByName("icon");
        if view and view.setFile then
            if enable then
                view:setFile("common/button/back_normal.png");
            else
                view:setFile("common/button/back_press.png");
            end
        end
    end

    local add_chat_func = function(self,enable)
        local view = self:getChildByName("icon");
        if view and view.setFile then
            if enable then
                view:setFile("common/button/create_chat_normal.png");
            else
                view:setFile("common/button/create_chat_press.png");
            end
        end
    end

    local check_member_func = function(self,enable)
        local view = self:getChildByName("icon");
        if view and view.setFile then
            if enable then
                view:setFile("common/button/member_normal.png");
            else
                view:setFile("common/button/member_press.png");
            end
        end
    end
    ----------------- view start -------------------

        ------------- main_chat_view ---------------
        self.m_main_chat_view = self.m_hall_chat_bg:getChildByName("main_chat");
            -- title
            self.m_main_chat_title_view = self.m_main_chat_view:getChildByName("title");
                -- add_btn
                self.m_add_btn = self.m_main_chat_title_view:getChildByName("add_chat");
                self.m_add_btn:setOnClick(self, self.createChatView);
                self.m_add_btn:setOnTuchProcess(self.m_add_btn,add_chat_func);
            -- content
            self.m_main_chat_content_view = self.m_main_chat_view:getChildByName("content_view");
            
        ------------- create_chat_view -------------
        self.m_create_chat_view = self.m_hall_chat_bg:getChildByName("create_chat");
            -- title
            self.m_create_chat_title_view = self.m_create_chat_view:getChildByName("title");
                -- back_btn
                self.m_create_chat_back_btn = self.m_create_chat_title_view:getChildByName("back_btn");
                self.m_create_chat_back_btn:setOnClick(self, self.createChatBackToMainChat);
                self.m_create_chat_back_btn:setOnTuchProcess(self.m_create_chat_back_btn,back_btn_func);
            -- search_view
            self.m_create_chat_search_view = self.m_create_chat_view:getChildByName("search_view");
                -- search_edit_bg
                self.m_create_chat_search_bg = self.m_create_chat_search_view:getChildByName("search_bg");
                    -- search_edit
                    self.m_create_chat_search_edit = self.m_create_chat_search_bg:getChildByName("search_content");
                    self.m_create_chat_search_edit:setHintText("输入框（点击输入）",165,145,125);
                -- search_btn
                self.m_create_chat_search_btn = self.m_create_chat_search_view:getChildByName("search_btn");
                self.m_create_chat_search_btn:setOnClick(self, self.searchFriends);
            -- content
            self.m_create_chat_content_view = self.m_create_chat_view:getChildByName("content_view");   
                -- up_mask
                self.m_create_chat_content_up_mask = self.m_create_chat_content_view:getChildByName("item_up_mask"); 
                self.m_create_chat_content_up_mask:setLevel(1);
                -- down_mask
                self.m_create_chat_content_down_mask = self.m_create_chat_content_view:getChildByName("item_down_mask"); 
                self.m_create_chat_content_down_mask:setLevel(1);
                     
        --------------- member_list_view -----------
--        self.m_member_list_view = self.m_hall_chat_bg:getChildByName("member_list");
--            -- title
--            self.m_member_list_title_view = self.m_member_list_view:getChildByName("title");
--                -- back_btn
--                self.m_member_list_back_btn = self.m_member_list_title_view:getChildByName("back_btn");
--                self.m_member_list_back_btn:setOnClick(self, self.backToRoomView);
--                self.m_member_list_back_btn:setOnTuchProcess(self.m_member_list_back_btn,back_btn_func);
--            -- search_view
--            self.m_member_list_search_view = self.m_member_list_view:getChildByName("search_view");
--                -- search_edit_bg
--                self.m_member_list_search_bg = self.m_member_list_search_view:getChildByName("search_bg");
--                    -- search_edit
--                    self.m_member_list_search_edit = self.m_member_list_search_bg:getChildByName("search_content");
--                    self.m_member_list_search_edit:setHintText("输入框（点击输入）",165,145,125);
--                -- search_btn
--                self.m_member_list_search_btn = self.m_member_list_search_view:getChildByName("search_btn");
--                self.m_member_list_search_btn:setOnClick(self, self.searchMember);
--            -- content
--            self.m_member_list_content_view = self.m_member_list_view:getChildByName("content_view");    
        ----------------- city_room_view -------------
        self.m_city_room_view = self.m_hall_chat_bg:getChildByName("city_room_view");
            -- title
            self.m_city_room_title_view = self.m_city_room_view:getChildByName("title");
                -- city_name
                self.m_city_room_title_txt = self.m_city_room_title_view:getChildByName("title_txt");
                -- back_btn
                self.m_city_room_back_btn = self.m_city_room_title_view:getChildByName("back_btn");
                self.m_city_room_back_btn:setOnClick(self, self.cityRoomBackToMainChat);
                self.m_city_room_back_btn:setOnTuchProcess(self.m_city_room_back_btn,back_btn_func);
                -- show_member_btn
--                self.m_show_city_member_btn  = self.m_city_room_title_view:getChildByName("check_member");
--                self.m_show_city_member_btn:setOnClick(self, self.showCityMemberView);
--                self.m_show_city_member_btn:setOnTuchProcess(self.m_show_city_member_btn,check_member_func);
            -- content
            self.m_city_room_view_content_view = self.m_city_room_view:getChildByName("content_view");  

            -- bottom
            self.m_city_room_bottom_view = self.m_city_room_view:getChildByName("bottom_view");
                -- send_edit_bg
                self.m_city_room_bottom_send_bg = self.m_city_room_bottom_view:getChildByName("send_bg");
                    -- send_edit
                    self.m_city_room_bottom_send_edit = self.m_city_room_bottom_send_bg:getChildByName("send_content");
                    self.m_city_room_bottom_send_edit:setHintText("点击输入聊天内容",165,145,125);
                -- send_btn
                self.m_city_room_bottom_send_btn = self.m_city_room_bottom_view:getChildByName("send_btn");
                self.m_city_room_bottom_send_btn:setOnClick(self, self.sendCityMsg);    
        ---------------- dashi_room_view ------------------
        self.m_dashi_room_view = self.m_hall_chat_bg:getChildByName("dashi_room_view");
            -- title
            self.m_dashi_room_title_view = self.m_dashi_room_view:getChildByName("title");
                -- dashi_name
                self.m_dashi_room_title_txt = self.m_dashi_room_title_view:getChildByName("title_txt");
                -- back_btn
                self.m_dashi_room_back_btn = self.m_dashi_room_title_view:getChildByName("back_btn");
                self.m_dashi_room_back_btn:setOnClick(self, self.dashiRoomBackToMainChat);
                self.m_dashi_room_back_btn:setOnTuchProcess(self.m_dashi_room_back_btn,back_btn_func);
                -- show_member_btn
--                self.m_show_dashi_member_btn  = self.m_dashi_room_title_view:getChildByName("check_member");
--                self.m_show_dashi_member_btn:setOnClick(self, self.showDashiMemberView);
--                self.m_show_dashi_member_btn:setOnTuchProcess(self.m_show_dashi_member_btn,check_member_func);
            -- content
            self.m_dashi_room_view_content_view = self.m_dashi_room_view:getChildByName("content_view");  

            -- bottom
            self.m_dashi_room_bottom_view = self.m_dashi_room_view:getChildByName("bottom_view");
                -- send_edit_bg
                self.m_dashi_room_bottom_send_bg = self.m_dashi_room_bottom_view:getChildByName("send_bg");
                    -- send_edit
                    self.m_dashi_room_bottom_send_edit = self.m_dashi_room_bottom_send_bg:getChildByName("send_content");
                    self.m_dashi_room_bottom_send_edit:setHintText("点击输入聊天内容",165,145,125);
                -- send_btn
                self.m_dashi_room_bottom_send_btn = self.m_dashi_room_bottom_view:getChildByName("send_btn");
                self.m_dashi_room_bottom_send_btn:setOnClick(self, self.sendDashiMsg);     

        ---------------- world_room_view ------------------
        self.m_world_room_view = self.m_hall_chat_bg:getChildByName("world_room_view");
            -- title
            self.m_world_room_title_view = self.m_world_room_view:getChildByName("title");
                -- world_name
                self.m_world_room_title_txt = self.m_world_room_title_view:getChildByName("title_txt");
                -- back_btn
                self.m_world_room_back_btn = self.m_world_room_title_view:getChildByName("back_btn");
                self.m_world_room_back_btn:setOnClick(self, self.worldRoomBackToMainChat);
                self.m_world_room_back_btn:setOnTuchProcess(self.m_world_room_back_btn,back_btn_func);
                -- show_member_btn
--                self.m_show_world_member_btn  = self.m_world_room_title_view:getChildByName("check_member");
--                self.m_show_world_member_btn:setOnClick(self, self.showWorldMemberView);
--                self.m_show_world_member_btn:setOnTuchProcess(self.m_show_world_member_btn,check_member_func);
--                self.m_show_world_member_btn:setVisible(false);
            -- content
            self.m_world_room_view_content_view = self.m_world_room_view:getChildByName("content_view");  

            -- bottom
            self.m_world_room_bottom_view = self.m_world_room_view:getChildByName("bottom_view");
                -- send_edit_bg
                self.m_world_room_bottom_send_bg = self.m_world_room_bottom_view:getChildByName("send_bg");
                    -- send_edit
                    self.m_world_room_bottom_send_edit = self.m_world_room_bottom_send_bg:getChildByName("send_content");
                    self.m_world_room_bottom_send_edit:setHintText("点击输入聊天内容",165,145,125);
                -- send_btn
                self.m_world_room_bottom_send_btn = self.m_world_room_bottom_view:getChildByName("send_btn");
                self.m_world_room_bottom_send_btn:setOnClick(self, self.sendWorldMsg); 
                
        ---------------- common_room_view -----------------
        self.m_common_room_view = self.m_hall_chat_bg:getChildByName("common_room_view");
            -- title
            self.m_common_room_title_view = self.m_common_room_view:getChildByName("title");
                -- user_name
                self.m_common_room_title_txt = self.m_common_room_title_view:getChildByName("user_name");
                -- back_btn
                self.m_common_room_back_btn = self.m_common_room_title_view:getChildByName("back_btn");
                self.m_common_room_back_btn:setOnClick(self, self.commonRoomBack);
                self.m_common_room_back_btn:setOnTuchProcess(self.m_common_room_back_btn,back_btn_func);
            -- content
            self.m_common_room_view_content_view = self.m_common_room_view:getChildByName("content_view");  

            -- bottom
            self.m_common_room_bottom_view = self.m_common_room_view:getChildByName("bottom_view");
                -- send_edit_bg
                self.m_common_room_bottom_send_bg = self.m_common_room_bottom_view:getChildByName("send_bg");
                    -- send_edit
                    self.m_common_room_bottom_send_edit = self.m_common_room_bottom_send_bg:getChildByName("send_content");
                    self.m_common_room_bottom_send_edit:setHintText("点击输入聊天内容",165,145,125);
                -- send_btn
                self.m_common_room_bottom_send_btn = self.m_common_room_bottom_view:getChildByName("send_btn");
                self.m_common_room_bottom_send_btn:setOnClick(self, self.sendCommonMsg);  

        ----------------- view end ------------------- 
     EventDispatcher.getInstance():register(Event.Call,self,self.onEventResponse);
     self.is_new = 0;
end;


HallChatDialog.show = function(self)

    self:setVisible(true);
    self.super.show(self,false);

    -- leftInAnim
    self.m_root:removeProp(11);
    local leftInAnim = self.m_root:addPropTranslateWithEasing(10, kAnimNormal, HallChatDialog.SHOW_ANIM_TIME, -1, "easeOutBack", function (...) return 0 end, -100, 100, 0, 0)
    if not leftInAnim then return end;
    leftInAnim:setEvent(self, function() 
        self:loadChatInfo();
    	-- 拉取未读消息
        self:loadUnreadMsgNum();
    end)
    self:fadeInAndOut(self.m_add_btn);
end

HallChatDialog.dismiss = function(self)
    self.m_root:removeProp(10);
    if self.m_city_locate_dialog then
        delete(self.m_city_locate_dialog);
        self.m_city_locate_dialog = nil;
    end
    -- hideAnim
    local rightHideAnim = self.m_root:addPropTranslate(11,kAnimNormal,HallChatDialog.HIDE_ANIM_TIME,0,0,-self.m_rootW,nil,nil);
    if not rightHideAnim then return end;
    rightHideAnim:setEvent(self, function() 
        self.super.dismiss(self);
        self:setVisible(false);
        self:resetChatDialog();
        self.m_room:changeUnreadMsgNum(self:haveUnreadMsgs());
        self.m_room:setHallChatBtnVisible(true);
    end)
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
    elseif self.m_current_view == HallChatDialog.DASHI_CHAT then
        self.m_dashi_room_view:setVisible(false);
        -- 离开时保留最后一条消息内容
        ChatRoomData.getInstance():saveRoomData(self.m_dashi_room_item:getRoomId(),os.time());
        self:leaveDashiRoom();
    elseif self.m_current_view == HallChatDialog.CITY_CHAT then
        self.m_city_room_view:setVisible(false);
        -- 离开时保留最后一条消息内容
        ChatRoomData.getInstance():saveRoomData(UserInfo.getInstance():getCityCode(),os.time());
        self:leaveCityRoom();
    elseif self.m_current_view == HallChatDialog.WORLD_CHAT then
        self.m_world_room_view:setVisible(false);
        -- 离开时保留最后一条消息内容
        ChatRoomData.getInstance():saveRoomData(self.m_world_room_item:getRoomId(),os.time());
        self:leaveWorldRoom();
    elseif self.m_current_view == HallChatDialog.COMMON_CHAT then
        self.m_common_room_view:setVisible(false);
    elseif self.m_current_view == HallChatDialog.CREATE_CHAT then
        self.m_create_chat_view:setVisible(false);
    elseif self.m_current_view == HallChatDialog.CITY_MEMBER_CHAT then
        self.m_member_list_view:setVisible(false);
        -- 离开时保留最后一条消息内容
        ChatRoomData.getInstance():saveRoomData(UserInfo.getInstance():getCityCode(),os.time());
        self:leaveCityRoom();
    elseif self.m_current_view == HallChatDialog.DASHI_MEMBER_CHAT then
        self.m_member_list_view:setVisible(false);
        -- 离开时保留最后一条消息内容
        ChatRoomData.getInstance():saveRoomData(self.m_dashi_room_item:getRoomId(),os.time());
        self:leaveDashiRoom();
    end;
    self.m_main_chat_view:setVisible(true);
    self.m_current_view = HallChatDialog.MAIN_CHAT;
end;



-- 加载聊天室主界面item
HallChatDialog.loadChatInfo = function(self)
    -- 公共聊天室（同城/大师）
    self.m_main_chat_room_list = UserInfo.getInstance():getChatRoomList();
    -- 私人聊天数据
    self.m_main_chat_chat_list = FriendsData.getInstance():getChatList();
    if self.m_main_chat_scroll_view and #self.m_main_chat_scroll_view:getChildren() > 0 then
        self.m_main_chat_scroll_view:removeAllChildren(true);
    end;
    local contentW,contentH = self.m_main_chat_content_view:getSize();
    self.m_main_chat_scroll_view = new(ScrollView2,0,0,contentW,contentH,true);
    self.m_main_chat_content_view:addChild(self.m_main_chat_scroll_view);
    self.m_chat_room_items = {};
    if self.m_main_chat_room_list then
        for index = 1, #self.m_main_chat_room_list do
            local data = self.m_main_chat_room_list[index];
            self.m_chat_room_items[index] = new(HallChatDialogItem,data,index,HallChatDialog.PUBLIC_CHAT,self);
            self.m_main_chat_scroll_view:addChild(self.m_chat_room_items[index]);
        end;
    end;
    if self.m_main_chat_chat_list then
        self.m_chat_list_items = {};
        for index = 1, #self.m_main_chat_chat_list do
            local data = self.m_main_chat_chat_list[index];
            self.m_chat_list_items[index] = new(HallChatDialogItem,data,index,HallChatDialog.PRAVITE_CHAT,self);
            self.m_main_chat_scroll_view:addChild(self.m_chat_list_items[index]);
        end;
    end;
end;




-- mainChat 拉取未读消息
HallChatDialog.loadUnreadMsgNum = function(self)
    -- 聊天室未读消息
    -- 拉取最后一条消息的时间，并设置mainChat聊天室item最后一条消息
    local chatRoomLastMsg = ChatRoomData.getInstance():getLastRoomMsg();
    local dashi_last_msg_time,city_last_msg_time,world_last_msg_time;
    if chatRoomLastMsg then
        for index = 1,#chatRoomLastMsg do
            if self.m_chat_room_items[1]:getRoomId() == chatRoomLastMsg[index].roomid then
                dashi_last_msg_time = chatRoomLastMsg[index].time;
                self.m_chat_room_items[1]:setChatRoomLastMsg(chatRoomLastMsg[index]);
            elseif UserInfo.getInstance():getCityCode() == chatRoomLastMsg[index].roomid then
                city_last_msg_time = chatRoomLastMsg[index].time;
                self.m_chat_room_items[2]:setChatRoomLastMsg(chatRoomLastMsg[index]);
            elseif self.m_chat_room_items[3]:getRoomId() == chatRoomLastMsg[index].roomid then
                world_last_msg_time = chatRoomLastMsg[index].time;
                self.m_chat_room_items[3]:setChatRoomLastMsg(chatRoomLastMsg[index]); 
            end;
        end;
    end;
    --{unReadNum=0 uid=1141 time=1448007994 last_msg="111111" }
    local commonChatMsg = FriendsData.getInstance():getChatList();
    if self.m_main_chat_scroll_view then
        for index = 1, #self.m_chat_list_items do
            self.m_main_chat_scroll_view:removeChild(self.m_chat_list_items[index],true);
        end;
        self.m_main_chat_scroll_view:updateScrollView();
        self.m_chat_list_items = {};
    end;
    for index = 1,#commonChatMsg do
        self.m_chat_list_items[index] = new(HallChatDialogItem,commonChatMsg[index],index,HallChatDialog.PRAVITE_CHAT,self);
        self.m_main_chat_scroll_view:addChild(self.m_chat_list_items[index]);       
    end;
    -- 大师
    local dashiInfo = {};
	dashiInfo.room_id = 1000;
	dashiInfo.uid = UserInfo.getInstance():getUid();
    dashiInfo.begin_msg_time = dashi_last_msg_time or 0;
    dashiInfo.end_msg_time = os.time();
    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_GET_UNREAD_MSG2,dashiInfo);
    -- 同城
    local cityInfo = {};
	cityInfo.room_id = UserInfo.getInstance():getCityCode();
	cityInfo.uid = UserInfo.getInstance():getUid();
    cityInfo.begin_msg_time = city_last_msg_time or 0;
    cityInfo.end_msg_time = os.time();
    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_GET_UNREAD_MSG2,cityInfo);
    -- 世界
    local worldInfo = {};
	worldInfo.room_id = 1002;
	worldInfo.uid = UserInfo.getInstance():getUid();
    worldInfo.begin_msg_time = world_last_msg_time or 0;
    worldInfo.end_msg_time = os.time();
    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_GET_UNREAD_MSG2,worldInfo);
    -- 普通聊天未读消息
    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_GET_UNREAD_MSG);

end





HallChatDialog.onMainChatItemClick = function(self, item)
    self.m_main_chat_item = item;
    if self.m_main_chat_item:getItemType() == 1 and self.m_main_chat_item:getRoomId() == 1000 then -- 大师
        if UserInfo.getInstance():getScore() < self.m_main_chat_item:getRoomMinScore() then
            ChessToastManager.getInstance():showSingle("积分超过"..self.m_main_chat_item:getRoomMinScore().."就可以在大师聊天室发言哦");
        end;
        self.m_room:entryChatRoom(self.m_main_chat_item:getRoomId());
    elseif self.m_main_chat_item:getItemType() == 1 and self.m_main_chat_item:getRoomId() == 1001 then -- 同城
        if UserInfo.getInstance():getCityName() and UserInfo.getInstance():getCityName() ~= "" then
            self.m_room:entryChatRoom(UserInfo.getInstance():getCityCode());
        else
            require("dialog/city_locate_pop_dialog")
            if not self.m_city_locate_dialog then
                self.m_city_locate_dialog = new(CityLocatePopDialog);
            end;
            self.m_city_locate_dialog:show(self);
        end;
    elseif self.m_main_chat_item:getItemType() == 1 and self.m_main_chat_item:getRoomId() == 1002 then -- 世界
        self.m_room:entryChatRoom(self.m_main_chat_item:getRoomId());
    else
        self:fadeInAndOut(self.m_common_room_back_btn,self.m_add_btn);
        self:leftOutRightIn(self.m_main_chat_view,self.m_common_room_view);
        self.m_current_view = HallChatDialog.COMMON_CHAT;
        self.m_common_room_from = 1;
        self:loadCommonRoomInfo(self.m_main_chat_item);
    end;
end;


-- 判断是否进入聊天室
HallChatDialog.setEntryChatRoom = function(self,packetInfo)
    if packetInfo.status == 0 then 
        if packetInfo.room_id == 1000 then
            self:leftOutRightIn(self.m_main_chat_view,self.m_dashi_room_view,self.resetDashiChatRoomView);
            self.m_current_view = HallChatDialog.DASHI_CHAT;
            self:loadDashiRoomInfo(self.m_main_chat_item);
            local str = "正在加载聊天数据..."
            ChessToastManager.getInstance():showSingle(str,1500);
        elseif packetInfo.room_id == UserInfo.getInstance():getCityCode() then
            self:leftOutRightIn(self.m_main_chat_view,self.m_city_room_view,self.resetCityChatRoomView);
            self.m_current_view = HallChatDialog.CITY_CHAT;
            self:loadCityRoomInfo(self.m_main_chat_item);
            local str = "正在加载聊天数据..."
            ChessToastManager.getInstance():showSingle(str,1500);
        elseif packetInfo.room_id == 1002 then
            self:leftOutRightIn(self.m_main_chat_view,self.m_world_room_view,self.resetWorldChatRoomView);
            self.m_current_view = HallChatDialog.WORLD_CHAT;
            self:loadWorldRoomInfo(self.m_main_chat_item);
            local str = "正在加载聊天数据...";
            ChessToastManager.getInstance():showSingle(str,1500);
        end;
    elseif packetInfo.status == 1 then
        local str = "聊天室已满..."
        ChessToastManager.getInstance():showSingle(str,500);
    else
        local str = "网络已断开...";
        ChessToastManager.getInstance():showSingle(str,500);
    end
end






HallChatDialog.setCityName = function(self, city)
    if self.m_main_chat_item then
        if self.m_main_chat_item:getRoomId() and self.m_main_chat_item:getRoomId() == 1001 then
            self.m_main_chat_item:setCityName(city);
        end;
    end;
end



HallChatDialog.onCreateChatItemClick = function(self, item)
    self.m_create_chat_item = item;
    self:leftOutRightIn(self.m_create_chat_view,self.m_common_room_view);
    self.m_common_room_from = 2;-- 1,from mainChat;2,from createChat
    self.m_current_view = HallChatDialog.COMMON_CHAT;
    self:fadeInAndOut(self.m_common_room_back_btn);
    self:loadCommonRoomInfo(self.m_create_chat_item);
end;

-- 加载大师房间聊天信息
HallChatDialog.loadDashiRoomInfo = function(self,item)
    self.m_dashi_room_item = item;
    self.m_dashi_room_item:setUnreadMsgNum(0);
    self.m_current_view = HallChatDialog.DASHI_CHAT;
    self.m_dashi_room_title_txt:setText("象棋大师聊天室");
--    self:fadeInAndOut(self.m_dashi_room_back_btn);
--    self:fadeInAndOut(self.m_show_dashi_member_btn);
end;

-- 加载同城房间聊天信息
HallChatDialog.loadCityRoomInfo = function(self,item)
    self.m_city_room_item = item;
    self.m_city_room_item:setUnreadMsgNum(0);
    self.m_current_view = HallChatDialog.CITY_CHAT;
    self.m_city_room_title_txt:setText((UserInfo.getInstance():getCityName() or "同城").."棋友聊天室");
end;

-- 加载世界房间聊天信息
HallChatDialog.loadWorldRoomInfo = function(self,item)
    self.m_world_room_item = item;
    self.m_world_room_item:setUnreadMsgNum(0);
    self.m_current_view = HallChatDialog.WORLD_CHAT;
    self.m_world_room_title_txt:setText("世界棋友聊天室");
end;

-- 加载大师成员列表
HallChatDialog.loadDashiRoomMember = function(self, data)
    if not data then return end;
    if self.m_member_list_scroll_view then
        self.m_member_list_scroll_view:removeAllChildren(true);
    else
        local contentW,contentH = self.m_member_list_content_view:getSize();
        self.m_member_list_scroll_view = new(ScrollView2,0,0,contentW,contentH,true);
        self.m_member_list_content_view:addChild(self.m_member_list_scroll_view);
    end;
    self.m_dashi_member_list = {};
    if data.room_id == 1000 then
        for index = 1, data.total_num do
            self.m_dashi_member_list[index] = new(HallMemberDialogItem,tonumber(data.item[index]),index, self);
            self.m_member_list_scroll_view:addChild(self.m_dashi_member_list[index]);
        end;
        if data.total_num == 1 and tonumber(data.item[1]) == UserInfo.getInstance():getUid() then
            local str = "还没有其他人"
            ChessToastManager.getInstance():showSingle(str,2000);
        end;
    end; 

end;
-- 加载同城成员列表
HallChatDialog.loadCityRoomMember = function(self, data)
    if not data then return end;
    if self.m_member_list_scroll_view then
        self.m_member_list_scroll_view:removeAllChildren(true);
    else
        local contentW,contentH = self.m_member_list_content_view:getSize();
        self.m_member_list_scroll_view = new(ScrollView2,0,0,contentW,contentH,true);
        self.m_member_list_content_view:addChild(self.m_member_list_scroll_view);
    end;
    local city_id = UserInfo.getInstance():getCityCode();--GameCacheData.getInstance():getInt(GameCacheData.LOCATE_CITY_CODE,0);
    self.m_city_member_list = {};
    if data.room_id == city_id then
        for index = 1, data.total_num do
            if tonumber(data.item[index]) ~= UserInfo.getInstance():getUid() then
                self.m_city_member_list[index] = new(HallMemberDialogItem,tonumber(data.item[index]),index, self);
                self.m_member_list_scroll_view:addChild(self.m_city_member_list[index]);
            end;
        end;
        if data.total_num == 1 and tonumber(data.item[1]) == UserInfo.getInstance():getUid() then
            local str = "还没有其他人"
            ChessToastManager.getInstance():showSingle(str,2000);
        end;
    end; 
end;

HallChatDialog.onMemberItemClick = function(self, item)
--    self.m_member_list_item = item;
--    if not self.m_member_list_item_dialog then
--        self.m_member_list_item_dialog  = new(UserInfoDialog,self,"up_user_info_",true);
--    end;
--    self.m_member_list_item_dialog:show(self.m_member_list_item:getUserData());
end;









-------------------------------------------------------------------------------------
-----------------------------聊天室（大师/同城/世界）--------------------------------
-------------------------------------------------------------------------------------

-- 设置大师聊天
HallChatDialog.resetDashiChatRoomView = function(self)
    if self.m_dashi_room_scroll_msg_view then
        self.m_dashi_room_scroll_msg_view:removeAllChildren(true);
    else
        local contentW,contentH = self.m_dashi_room_view_content_view:getSize();
        self.m_dashi_room_scroll_msg_view = new(ScrollView2,0,0,contentW,contentH,true);
        self.m_dashi_room_view_content_view:addChild(self.m_dashi_room_scroll_msg_view);
    end;
    self.m_dashi_room_view_content_view:setPickable(false);
    if self.m_dashi_room_item then
        local historyMsg = ChatRoomData.getInstance():getHistoryMsg(self.m_dashi_room_item:getRoomId());
        local last_time = 0;
        if historyMsg then
            for i,v in ipairs(historyMsg) do
                local uid = v.uid;
                if uid then
                    local data = FriendsData.getInstance():getUserData(v.uid)
                    local name = "";
                    if data then
                        name = data.mnick;
                    end
                    self:addDashiChatRoom(name,v.msg,v.uid,v.time);
                end
                last_time = v.time+1;
            end
        end
        self:toGetDashiHistoryMsg(last_time);
        self.m_dashi_room_scroll_msg_view:gotoBottom();
    end
end

HallChatDialog.toGetDashiHistoryMsg = function(self,time)
    if self.m_dashi_room_item then 
        local roomId = self.m_dashi_room_item:getRoomId();
        local info = {};
        info.uid = UserInfo.getInstance():getUid();
        info.room_id = roomId;
        info.last_msg_time = time or 0;
        info.entry_room_time = os.time();
        info.version = kLuaVersionCode;
        OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_GET_HISTORY_MSG,info);
    end
end



-- 设置同城聊天
HallChatDialog.resetCityChatRoomView = function(self)
    if self.m_city_room_scroll_msg_view then
        self.m_city_room_scroll_msg_view:removeAllChildren(true);
    else
        local contentW,contentH = self.m_city_room_view_content_view:getSize();
        self.m_city_room_scroll_msg_view = new(ScrollView2,0,0,contentW,contentH,true);
        self.m_city_room_view_content_view:addChild(self.m_city_room_scroll_msg_view);
    end;
    self.m_city_room_view_content_view:setPickable(false);
    if self.m_city_room_item then
        local historyMsg = ChatRoomData.getInstance():getHistoryMsg(UserInfo.getInstance():getCityCode());
        local last_time = 0;
        if historyMsg then
            for i,v in ipairs(historyMsg) do
                local uid = v.uid;
                if uid then
                    local data = FriendsData.getInstance():getUserData(v.uid)
                    local name = "";
                    if data then
                        name = data.mnick;
                    end
                    self:addCityChatRoom(name,v.msg,v.uid,v.time);
                end
                last_time = v.time+1;
            end
        end
        self:toGetCityHistoryMsg(last_time);
        self.m_city_room_scroll_msg_view:gotoBottom();
    end
end

HallChatDialog.toGetCityHistoryMsg = function(self,time)
    if self.m_city_room_item then 
        local roomId = UserInfo.getInstance():getCityCode();
        local info = {};
        info.uid = UserInfo.getInstance():getUid();
        info.room_id = roomId;
        info.last_msg_time = time or 0;
        info.entry_room_time = os.time();
        info.version = kLuaVersionCode;
        OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_GET_HISTORY_MSG,info);
    end
end


-- 设置世界聊天室
HallChatDialog.resetWorldChatRoomView = function(self)
    if self.m_world_room_scroll_msg_view then
        self.m_world_room_scroll_msg_view:removeAllChildren(true);
    else
        local contentW,contentH = self.m_world_room_view_content_view:getSize();
        self.m_world_room_scroll_msg_view = new(ScrollView2,0,0,contentW,contentH,true);
        self.m_world_room_view_content_view:addChild(self.m_world_room_scroll_msg_view);
    end;
    self.m_world_room_view_content_view:setPickable(false);
    if self.m_world_room_item then
        local historyMsg = ChatRoomData.getInstance():getHistoryMsg(self.m_world_room_item:getRoomId());
        local last_time = 0;
        if historyMsg then
            for i,v in ipairs(historyMsg) do
                local uid = v.uid;
                if uid then
                    local data = FriendsData.getInstance():getUserData(v.uid)
                    local name = "";
                    if data then
                        name = data.mnick;
                    end
                    self:addWorldChatRoom(name,v.msg,v.uid,v.time);
                end
                last_time = v.time+1;
            end
        end
        self:toGetWorldHistoryMsg(last_time);
        self.m_world_room_scroll_msg_view:gotoBottom();
    end
end

HallChatDialog.toGetWorldHistoryMsg = function(self,time)
    if self.m_world_room_item then 
        local roomId = self.m_world_room_item:getRoomId();
        local info = {};
        info.uid = UserInfo.getInstance():getUid();
        info.room_id = roomId;
        info.last_msg_time = time or 0;
        info.entry_room_time = os.time();
        info.version = kLuaVersionCode;
        OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_GET_HISTORY_MSG,info);
    end
end



HallChatDialog.addDashiChatRoom = function(self,name,message,uid,time)
	if not message or message == "" then
		return
	end
	local data = {};
	data.mnick = GameString.convert2UTF8(name);
	data.msg = GameString.convert2UTF8(message);
    data.send_uid = uid;
    data.time = time;
    local num = #(self.m_dashi_room_scroll_msg_view:getChildren());
    if num == 0 then
        data.isShowTime = true;
    else
        local item = self.m_dashi_room_scroll_msg_view:getChildren()[num]; 
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
	local item = new(HallChatRoomItem,data);
    self.m_dashi_room_scroll_msg_view:addChild(item);
    self.m_dashi_room_scroll_msg_view:gotoBottom();
    self.m_dashi_room_bottom_send_edit:setText(nil);
end

HallChatDialog.addCityChatRoom = function(self,name,message,uid,time)
	if not message or message == "" then
		return
	end
	local data = {};
	data.mnick = GameString.convert2UTF8(name);
	data.msg = GameString.convert2UTF8(message);
    data.send_uid = uid;
    data.time = time;

    local num = #(self.m_city_room_scroll_msg_view:getChildren());
    if num == 0 then
        data.isShowTime = true;
    else
        local item = self.m_city_room_scroll_msg_view:getChildren()[num]; 
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

	--self.m_chat_log_adapter:appendData({data});

	local item = new(HallChatRoomItem,data);
    self.m_city_room_scroll_msg_view:addChild(item);
    self.m_city_room_scroll_msg_view:gotoBottom();
    self.m_city_room_bottom_send_edit:setText(nil);
end


HallChatDialog.addWorldChatRoom = function(self,name,message,uid,time)
	if not message or message == "" or not self.m_world_room_scroll_msg_view then
		return
	end

	local data = {};
	data.mnick = GameString.convert2UTF8(name);
	data.msg = GameString.convert2UTF8(message);
    data.send_uid = uid;
    data.time = time;
    local num = #(self.m_world_room_scroll_msg_view:getChildren());
    if num == 0 then
        data.isShowTime = true;
    else
        local item = self.m_world_room_scroll_msg_view:getChildren()[num]; 
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
	local item = new(HallChatRoomItem,data);
    self.m_world_room_scroll_msg_view:addChild(item);
    self.m_world_room_scroll_msg_view:gotoBottom();
    self.m_world_room_bottom_send_edit:setText(nil);

end






-- 加载普通房间聊天信息
HallChatDialog.loadCommonRoomInfo = function(self,item)
    self.m_common_room_item = item;
--    self.m_common_room_item:setUnreadMsgNum(0);
    self.m_common_room_title_txt:setText(item:getFriendName());
    if self.m_common_room_msg_stroll_view then
        self.m_common_room_msg_stroll_view:removeAllChildren(true);
        self.m_common_room_msg_stroll_view:updateScrollView();
    else    
        local commonContentW, commonContentH = self.m_common_room_view_content_view:getSize();
        self.m_common_room_msg_stroll_view = new(ScrollView2, 0,0,commonContentW,commonContentH,true);
        self.m_common_room_view_content_view:addChild(self.m_common_room_msg_stroll_view);
    end;

    local historyMsg = FriendsData.getInstance():getChatData(tonumber(self.m_common_room_item:getUid()));
    for i = 1, #historyMsg do 
        -- 根据已有的时间确定itemtime的显示规则
        if i == 1 then
            historyMsg[i].isShowTime = true;
        elseif ToolKit.isSecondDay(historyMsg[i].time) then
            if ToolKit.isInTenMinute(historyMsg[i].time,historyMsg[i-1].time) then
                historyMsg[i].isShowTime = false;   
            else
                historyMsg[i].isShowTime = true;
            end;
        elseif ToolKit.isInTenMinute(historyMsg[i].time,historyMsg[i-1].time) then
            historyMsg[i].isShowTime = false;
        else
            historyMsg[i].isShowTime = true;
        end;

        local item = new(HallChatRoomItem, historyMsg[i]);
        self.m_common_room_msg_stroll_view:addChild(item); 
    end;
    self.m_common_room_msg_stroll_view:gotoBottom();
    --清除未读消息
    self:resetUnreadMsgNum();
end;




-- 从mainChat到createChatView
HallChatDialog.createChatView = function(self)
    self:fadeInAndOut(self.m_create_chat_back_btn,self.m_add_btn);
    self.m_current_view = HallChatDialog.CREATE_CHAT;
    self:leftOutRightIn(self.m_main_chat_view,self.m_create_chat_view);
    self:loadCreateChatView();
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


-- 搜索成员
--HallChatDialog.searchMember = function(self)
--    local usr = {};
--    local friendName = self.m_member_list_search_edit:getText();
--    if friendName == " " then
--        self:showSearchMemberList(usr,"请您输入成员昵称");
--    else
--        if self.m_member_from == 2 then -- 同城
--            if self.m_city_member_list then
--                for index = 1, #self.m_city_member_list do
--                    if string.find(GameString.convert2UTF8(self.m_city_member_list[index]:getName()),friendName) then
--                        table.insert(usr,tonumber(self.m_city_member_list[index]:getUid()));
--                    end;       
--                end;
--            end;
--        elseif self.m_member_from == 1 then -- 大师
--            if self.m_dashi_member_list then
--                for index = 1, #self.m_dashi_member_list do
--                    if string.find(GameString.convert2UTF8(self.m_dashi_member_list[index]:getName()),friendName) then
--                        table.insert(usr,tonumber(self.m_dashi_member_list[index]:getUid()));
--                    end;       
--                end;
--            end;
--        end;
--        self:showSearchMemberList(usr,"很抱歉，没有找到该成员");
--    end;
--end;


--HallChatDialog.showSearchMemberList = function(self, data,msg)
--    if self.m_member_list_scroll_view then
--        self.m_member_list_scroll_view:removeAllChildren(true);
--    else
--        local contentW,contentH = self.m_member_list_content_view:getSize();
--        self.m_member_list_scroll_view = new(ScrollView2,0,0,contentW,contentH,true);
--        self.m_member_list_content_view:addChild(self.m_member_list_scroll_view);
--    end;  
--    if #data == 0 then
--        ChessToastManager.getInstance():show(GameString.convert2UTF8(msg),2000);
--        if self.m_member_from == 2 then -- 同城
--            self:loadCityData();
--        elseif self.m_member_from == 1 then -- 大师
--            self:loadDashiData();
--        end;
--    else
--        for index = 1, #data do
--            local item = new(HallMemberDialogItem,data[index],index,self);
--            self.m_member_list_scroll_view:addChild(item);
--        end;
--        self.m_member_list_content_view:addChild(self.m_member_list_scroll_view);
--    end;
--end;

-- 搜索好友
HallChatDialog.searchFriends = function(self)
    local usr = {};
    local friendName = self.m_create_chat_search_edit:getText();
    if friendName == " " then
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
    self:fadeInAndOut(self.m_add_btn, self.m_create_chat_back_btn);
    self.m_current_view = HallChatDialog.MAIN_CHAT;
    self:leftInRightOut(self.m_main_chat_view,self.m_create_chat_view);
    -- 拉取未读消息
    self:loadUnreadMsgNum();
end
-- 大师聊天返回mainChat
HallChatDialog.dashiRoomBackToMainChat = function(self)
    -- 离开时保留最后一条消息内容
    ChatRoomData.getInstance():saveRoomData(self.m_dashi_room_item:getRoomId(),os.time());
    self:leaveDashiRoom();
    self.m_current_view = HallChatDialog.MAIN_CHAT;
    self:fadeInAndOut(self.m_add_btn);
    self:leftInRightOut(self.m_main_chat_view,self.m_dashi_room_view);
    -- 拉取未读消息
    self:loadUnreadMsgNum();
end

HallChatDialog.leaveDashiRoom = function(self)
	local info = {};
	info.room_id = self.m_dashi_room_item:getRoomId();
	info.uid = UserInfo.getInstance():getUid();
    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_LEAVE_ROOM,info);
    self.m_dashi_room_scroll_msg_view:removeAllChildren(true);
end;


-- 同城聊天返回mainChat
HallChatDialog.cityRoomBackToMainChat = function(self)
    -- 离开时保留最后一条消息内容
    ChatRoomData.getInstance():saveRoomData(UserInfo.getInstance():getCityCode(),os.time());
    self:leaveCityRoom();
    self.m_current_view = HallChatDialog.MAIN_CHAT;
    self:fadeInAndOut(self.m_add_btn);
    self:leftInRightOut(self.m_main_chat_view,self.m_city_room_view);
    -- 拉取未读消息
    self:loadUnreadMsgNum();
end

HallChatDialog.leaveCityRoom = function(self)
	local info = {};
	info.room_id = UserInfo.getInstance():getCityCode();--GameCacheData.getInstance():getInt(GameCacheData.LOCATE_CITY_CODE,0);
	info.uid = UserInfo.getInstance():getUid();
    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_LEAVE_ROOM,info);
    self.m_city_room_scroll_msg_view:removeAllChildren(true);
end;

-- 世界聊天返回mainChat
HallChatDialog.worldRoomBackToMainChat = function(self)
    -- 离开时保留最后一条消息内容
    ChatRoomData.getInstance():saveRoomData(self.m_world_room_item:getRoomId(),os.time());
    self:leaveWorldRoom();
    self.m_current_view = HallChatDialog.MAIN_CHAT;
    self:fadeInAndOut(self.m_add_btn);
    self:leftInRightOut(self.m_main_chat_view,self.m_world_room_view);
    -- 拉取未读消息
    self:loadUnreadMsgNum();
end

HallChatDialog.leaveWorldRoom = function(self)
	local info = {};
	info.room_id = self.m_world_room_item:getRoomId();
	info.uid = UserInfo.getInstance():getUid();
    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_LEAVE_ROOM,info);
    self.m_world_room_scroll_msg_view:removeAllChildren(true);
end;


-- 普通聊天返回mainChat
HallChatDialog.commonRoomBack = function(self)
    if self.m_common_room_from == 1 then
        self.m_current_view = HallChatDialog.MAIN_CHAT;
        self:fadeInAndOut(self.m_add_btn, self.m_common_room_back_btn);
        self:leftInRightOut(self.m_main_chat_view,self.m_common_room_view);
        -- 拉取未读消息
        self:loadUnreadMsgNum();
    elseif self.m_common_room_from == 2 then
        self.m_current_view = HallChatDialog.CREATE_CHAT;
        self:fadeInAndOut(nil, self.m_common_room_back_btn);
        self:leftInRightOut(self.m_create_chat_view,self.m_common_room_view);
    end;
end


-- 从dashiRoomView到memberView
--HallChatDialog.showDashiMemberView = function(self)
--    self.m_member_from = 1; -- 1,大师聊天室，2,同城聊天室
--    self:fadeInAndOut(self.m_member_list_back_btn);
--    self:leftOutRightIn(self.m_dashi_room_view,self.m_member_list_view);
--    self.m_current_view = HallChatDialog.DASHI_MEMBER_CHAT;
--    self:loadDashiData();
--    -- 刷新成员列表好友关系
--    FriendsData.getInstance():refresh();
--end;


HallChatDialog.loadDashiData = function(self)
    local post_data = {};
    post_data.room_id = 1000;
    post_data.uid = UserInfo.getInstance():getUid();
    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_GET_MEMBER_LIST,post_data);    
end

-- 从cityRoomView到memberView
--HallChatDialog.showCityMemberView = function(self)
--    self.m_member_from = 2; -- 1,大师聊天室，2,同城聊天室
--    self:fadeInAndOut(self.m_member_list_back_btn);
--    self:leftOutRightIn(self.m_city_room_view,self.m_member_list_view);
--    self.m_current_view = HallChatDialog.CITY_MEMBER_CHAT;
--    self:loadCityData();
--    -- 刷新成员列表好友关系
--    FriendsData.getInstance():refresh();
--end;

HallChatDialog.loadCityData = function(self)
    local post_data = {};
    -- 同城聊天room_id传城市代码，非1001
    post_data.room_id = UserInfo.getInstance():getCityCode();
    post_data.uid = UserInfo.getInstance():getUid();
    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_GET_MEMBER_LIST,post_data);    
end;


-- 返回RoomView
--HallChatDialog.backToRoomView = function(self)
--    self:fadeInAndOut(nil, self.m_member_list_back_btn);
--    if self.m_member_from == 2 then
--        self:leftInRightOut(self.m_city_room_view,self.m_member_list_view);
--        self.m_current_view = HallChatDialog.CITY_CHAT;
--    elseif self.m_member_from == 1 then
--        self:leftInRightOut(self.m_dashi_room_view,self.m_member_list_view);
--        self.m_current_view = HallChatDialog.DASHI_CHAT;
--    end;
--end



---------------------------- common anim ---------------------------
-- 左出右进动画
HallChatDialog.leftOutRightIn = function(self,leftView, rightView,callBackFun)
    leftView:setVisible(true);
    local leftW,leftH = leftView:getSize();
    -- leftSlide
    local leftAnim = leftView:addPropTranslate(0,kAnimNormal,HallChatDialog.LORI_ANIM_TIME,-1,0,-leftW,0,0);
    if not leftAnim then return end;
    leftAnim:setEvent(nil, function() 
        leftView:removeProp(0);
    end);
    -- leftTransparency
    local leftTransparency = leftView:addPropTransparency(1,kAnimNormal,HallChatDialog.LORI_ANIM_TIME,0,0.5,0);
    if not leftTransparency then return end;
    leftTransparency:setEvent(nil, function() 
        leftView:setVisible(false);
        leftView:removeProp(1);
    end);
    -- rightSlide
    rightView:setVisible(true);
    local rightW,rightH = rightView:getSize();
    local rightAnim = rightView:addPropTranslate(0,kAnimNormal,HallChatDialog.LORI_ANIM_TIME,0,rightW,0,nil,nil);
    if not rightAnim then return end;
    rightAnim:setEvent(nil, function() 
        rightView:removeProp(0);
        if callBackFun then
            callBackFun(self);
        end;
    end);
    -- rightTransparency
    local rightTransparency = rightView:addPropTransparency(1,kAnimNormal,HallChatDialog.LORI_ANIM_TIME,0,0,1);
    if not rightTransparency then return end;
    rightTransparency:setEvent(nil, function() 
        rightView:removeProp(1);
    end);
end;

-- 左进右出动画
HallChatDialog.leftInRightOut = function(self,leftView, rightView,callBackFun)
    -- leftSlide
    leftView:setVisible(true);
    local leftW,leftH = leftView:getSize();
    local leftAnim = leftView:addPropTranslate(1,kAnimNormal,HallChatDialog.LIRO_ANIM_TIME,0,-leftW,0,nil,nil);
    if not leftAnim then return end;
    leftAnim:setEvent(nil, function() 
         leftView:removeProp(1);  
         if callBackFun then
            callBackFun(self);
         end;     
    end)
    -- leftTransparency
    local leftTransparency = leftView:addPropTransparency(2,kAnimNormal,HallChatDialog.LORI_ANIM_TIME,0,0,1);
    if not leftTransparency then return end;
    leftTransparency:setEvent(nil, function() 
        leftView:removeProp(2);
    end);
    -- rightSlide
    rightView:setVisible(true);
    local rightW,rightH = rightView:getSize();
    local rightAnim = rightView:addPropTranslate(1,kAnimNormal,HallChatDialog.LIRO_ANIM_TIME,0,0,rightW,nil,nil);
    if not rightAnim then return end;
    rightAnim:setEvent(nil, function() 
        rightView:removeProp(1);      
    end);
    -- rightTransparency
    local rightTransparency = rightView:addPropTransparency(2,kAnimNormal,HallChatDialog.LORI_ANIM_TIME,0,0.5,0);
    if not rightTransparency then return end;
    rightTransparency:setEvent(nil, function() 
        rightView:setVisible(false);
        rightView:removeProp(2);
    end);
end;

-- 淡入淡出动画
HallChatDialog.fadeInAndOut = function(self, fadeInView, fadeOutView)
    if fadeInView then
        fadeInView:setVisible(true); 
        local fadeInViewW,fadeInViewH = fadeInView:getSize();
        local up_anim = fadeInView:addPropTranslate(1,kAnimNormal,HallChatDialog.FADEIN_ANIM_TIME,0,0,0,fadeInViewH,0);
        if not up_anim then return end;
        up_anim:setEvent(nil, function() 
            fadeInView:removeProp(1);      
        end);
        local up_fade_anim = fadeInView:addPropTransparency(2,kAnimNormal,HallChatDialog.FADEIN_ANIM_TIME,0,0,1);
        if not up_fade_anim then return end;
        up_fade_anim:setEvent(nil, function() 
            fadeInView:removeProp(2);      
        end);
    end;

    if fadeOutView then
        fadeOutView:setVisible(true);
        local fadeOutViewW,fadeOutViewH = fadeOutView:getSize();
        local down_anim = fadeOutView:addPropTranslate(1,kAnimNormal,HallChatDialog.FADEOUT_ANIM_TIME,0,0,0,0,fadeOutViewH);
        if not down_anim then return end;
        down_anim:setEvent(nil, function()
            fadeOutView:removeProp(1);      
        end);
        local down_fade_anim = fadeOutView:addPropTransparency(2,kAnimNormal,HallChatDialog.FADEOUT_ANIM_TIME,0,1,0);
        if not down_fade_anim then return end;
        down_fade_anim:setEvent(nil, function() 
            fadeOutView:removeProp(2);  
            fadeOutView:setVisible(false);    
        end);
    end;
end;











---------------------------- send Msg ------------------------------

-- 发送大师消息
HallChatDialog.sendDashiMsg = function(self)
    if UserInfo.getInstance():getScore() < self.m_main_chat_item:getRoomMinScore() then
        ChessToastManager.getInstance():showSingle("在大师聊天室发言需要积分超过1700,先看看大师们交流吧！",2000); 
        return;
    end
	self.m_dashi_msg = self.m_dashi_room_bottom_send_edit:getText() or "";
    if self.m_dashi_msg == " " then
        ChessToastManager.getInstance():showSingle("消息不能为空！",800); 
        return;
    end;
    self.m_dashi_msg = self:return140Str(self.m_dashi_msg);
	local msgdata = {};
	msgdata.room_id = self.m_dashi_room_item:getRoomId();
	msgdata.msg = self.m_dashi_msg;
	msgdata.name = UserInfo.getInstance():getName();
	msgdata.uid = UserInfo.getInstance():getUid();

	OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_USER_CHAT_MSG,msgdata);
    self.m_dashi_room_bottom_send_edit:setText(nil);
end;

-- 发送同城消息
HallChatDialog.sendCityMsg = function(self)
	self.m_city_msg = self.m_city_room_bottom_send_edit:getText() or "";
    if self.m_city_msg == " " then
        ChessToastManager.getInstance():showSingle("消息不能为空！",800); 
        return;
    end;
    self.m_city_msg = self:return140Str(self.m_city_msg);
	local msgdata = {};
	msgdata.room_id = UserInfo.getInstance():getCityCode();--GameCacheData.getInstance():getInt(GameCacheData.LOCATE_CITY_CODE,0);
	msgdata.msg = self.m_city_msg;
	msgdata.name = UserInfo.getInstance():getName();
	msgdata.uid = UserInfo.getInstance():getUid();

	OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_USER_CHAT_MSG,msgdata);
    self.m_city_room_bottom_send_edit:setText(nil);
end;

-- 发送世界消息
HallChatDialog.sendWorldMsg = function(self)
	self.m_world_msg = self.m_world_room_bottom_send_edit:getText() or "";
    if self.m_world_msg == " " then
        ChessToastManager.getInstance():showSingle("消息不能为空！",800); 
        return;
    end;
    self.m_world_msg = self:return140Str(self.m_world_msg);
	local msgdata = {};
    msgdata.room_id = self.m_world_room_item:getRoomId();
    msgdata.msg = self.m_world_msg;
    msgdata.name = UserInfo.getInstance():getName();
    msgdata.uid = UserInfo.getInstance():getUid();
--    msgdata.extraMsg = self:getSelfInfo();
    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_USER_CHAT_MSG,msgdata);
    self.m_world_room_bottom_send_edit:setText(nil);
end;

-- 发送普通聊天消息
HallChatDialog.sendCommonMsg = function(self)
    if not self.m_isSendingMsg then
        self.m_isSendingMsg = true;
        self.m_common_chat_msg = self.m_common_room_bottom_send_edit:getText() or "";
        if self.m_common_chat_msg == " " then
            ChessToastManager.getInstance():showSingle("消息不能为空！",800); 
            self.m_isSendingMsg = false;
            return;
        end;
        self.m_common_chat_msg = self:return140Str(self.m_common_chat_msg);
        ------ 发送服务器item --------
        self.m_common_room_cur_data = {};
        self.m_common_room_cur_data.msg = self.m_common_chat_msg;
        self.m_common_room_cur_data.target_uid = tonumber(self.m_common_room_item:getUid());
        self.m_common_room_cur_data.isNew = self.is_new;
        OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_CHAT_MSG2,self.m_common_room_cur_data);
        self.is_new = 1;
    else
        ChessToastManager.getInstance():showSingle("正在发送消息...",2000);  
    end;
    self.m_common_room_bottom_send_edit:setText(nil);

end;

--HallChatDialog.getSelfInfo = function(self)
--    local info = {};
--    info.sex = UserInfo.getInstance():getSex();
--    info.score = UserInfo.getInstance():getScore();
--    info.wintimes = UserInfo.getInstance():getWintimes();
--    info.losetimes = UserInfo.getInstance():getLosetimes();
--    info.drawtimes = UserInfo.getInstance():getDrawtimes();
--    info.rank = UserInfo.getInstance():getRank();
--    info.is_vip = UserInfo.getInstance():getIsVip();
--    info.icon_url = UserInfo.getInstance():getIcon();
--    info.mid = UserInfo.getInstance():getUid();
--    info.mnick = UserInfo.getInstance():getName();
--    return json.encode(info);
--end;


HallChatDialog.return140Str = function(self, msg)
    local strMsg = msg;
    local lens = string.lenutf8(GameString.convert2UTF8(msg) or "");    
    if lens > 140 then--限制140字
        strMsg = GameString.convert2UTF8(string.subutf8(msg,1,140));
    end;
    return strMsg;
end;






---------------------------- recv Msg ------------------------------

--历史未读消息
HallChatDialog.onRecvServerUnreadMsg = function(self, packetInfo)
    local msgUnread = {};
    local total_num = packetInfo.total_count;
    local roomId = packetInfo.room_id;
    local page_num = packetInfo.page_num;
    local curr_page = packetInfo.curr_page;
    local item_num = packetInfo.item_num;

    if page_num == 0 then
        if self.m_current_view == HallChatDialog.DASHI_CHAT then
            local historyMsg = ChatRoomData.getInstance():getHistoryMsg(self.m_dashi_room_item:getRoomId());
            if not historyMsg or #historyMsg == 0 then
                ChessToastManager.getInstance():showSingle("欢迎进入聊天室，来跟其他棋友打个招呼吧",1500);
            end
            self.m_dashi_room_view_content_view:setPickable(true);
        elseif self.m_current_view == HallChatDialog.CITY_CHAT then
            local historyMsg = ChatRoomData.getInstance():getHistoryMsg(UserInfo.getInstance():getCityCode());
            if not historyMsg or #historyMsg == 0 then
                ChessToastManager.getInstance():showSingle("欢迎进入聊天室，来跟其他棋友打个招呼吧",1500);
            end
            self.m_city_room_view_content_view:setPickable(true);
        elseif self.m_current_view == HallChatDialog.WORLD_CHAT then
            local historyMsg = ChatRoomData.getInstance():getHistoryMsg(self.m_world_room_item:getRoomId());
            if not historyMsg or #historyMsg == 0 then
                ChessToastManager.getInstance():showSingle("欢迎进入聊天室，来跟其他棋友打个招呼吧",1500);
            end
            self.m_world_room_view_content_view:setPickable(true);
        end;
        return;
    end
   
    msgItem = packetInfo.item;
    for i = 1,item_num do 
        msgUnread[i] = json.decode(msgItem[i]);
        table.insert(self.m_chatroom_msg_list,msgUnread[i]);
    end

    if (tonumber(curr_page) + 1 == tonumber(page_num)) and #self.m_chatroom_msg_list == total_num  then
        ChatRoomData.getInstance():saveHistoryMsg(self.m_chatroom_msg_list,roomId);
        local historyMsg = self.m_chatroom_msg_list;
        local len = 1;
        if #historyMsg > 50 then
            len = #historyMsg - 50;
        end;
        for i = len, #historyMsg do
            if self.m_current_view == HallChatDialog.DASHI_CHAT then
                self:addDashiChatRoom(historyMsg[i].name,historyMsg[i].msg,historyMsg[i].uid,historyMsg[i].time);
            elseif self.m_current_view == HallChatDialog.CITY_CHAT then
                self:addCityChatRoom(historyMsg[i].name,historyMsg[i].msg,historyMsg[i].uid,historyMsg[i].time);
            elseif self.m_current_view == HallChatDialog.WORLD_CHAT then
                self:addWorldChatRoom(historyMsg[i].name,historyMsg[i].msg,historyMsg[i].uid,historyMsg[i].time);
            end;
        end
        self.m_chatroom_msg_list = {};
        if self.m_current_view == HallChatDialog.DASHI_CHAT then
            self.m_dashi_room_view_content_view:setPickable(true);
        elseif self.m_current_view == HallChatDialog.CITY_CHAT then
            self.m_city_room_view_content_view:setPickable(true);
        elseif self.m_current_view == HallChatDialog.WORLD_CHAT then
            self.m_world_room_view_content_view:setPickable(true);
        end;
    end; 
end

-- 接收server广播的聊天室消息
HallChatDialog.onRecvServerBroadCastMsg = function(self, data)
	local msgtab = json.decode(data.msg_json);
    local msgData = {};
    msgData.uid = msgtab.uid;
    msgData.name = msgtab.name;
    msgData.time = msgtab.time + 1;
    msgData.msg = msgtab.msg;
    msgData.msg_id = msgtab.msg_id;
    ChatRoomData.getInstance():saveRecvMsg(msgData,data.room_id);
    -- ?????? time + 1?
    if self.m_current_view == HallChatDialog.DASHI_CHAT then
        self:addDashiChatRoom(msgtab.name,msgtab.msg,msgtab.uid,msgtab.time + 1);
    elseif self.m_current_view == HallChatDialog.CITY_CHAT then
        self:addCityChatRoom(msgtab.name,msgtab.msg,msgtab.uid,msgtab.time + 1);
    elseif self.m_current_view == HallChatDialog.WORLD_CHAT then
        self:addWorldChatRoom(msgtab.name,msgtab.msg,msgtab.uid,msgtab.time + 1);
    end;
    -- ??????
    local msginfo = {};
    msginfo.room_id = data.room_id;
    msginfo.uid = UserInfo.getInstance():getUid();
    msginfo.msg_time = msgtab.time;
    msginfo.msg_id = msgtab.msg_id;
    OnlineSocketManager.getHallInstance():sendMsg(CHATROOM_CMD_BROAdCAST_CHAT_MSG,msginfo);
end


HallChatDialog.onRecvServerUnreadMsgNum = function(self, data)
    if not data then return end;
    if data.room_id == self.m_chat_room_items[1]:getRoomId() then
        self.m_chat_room_items[1]:setUnreadMsgNum(data.unread_msg_num);
    elseif data.room_id == UserInfo.getInstance():getCityCode() then
        self.m_chat_room_items[2]:setUnreadMsgNum(data.unread_msg_num);
    elseif data.room_id == self.m_chat_room_items[3]:getRoomId() then
        self.m_chat_room_items[3]:setUnreadMsgNum(data.unread_msg_num);
    end;
end;


-- 接收自己发的消息
HallChatDialog.onRecvCommonChatMsg = function(self, data)
    if data.ret == 0 then
        self.m_isSendingMsg = false;
        if data.forbid_time and data.forbid_time > 0 then
            return ;
        end;
        ------- 本人聊天item -------
        local data ={}
        data.send_uid = UserInfo.getInstance():getUid();
        data.time = os.time();
        if ToolKit.isSecondDay(self.m_common_last_msg_time) then
            data.isShowTime = true;
        else
            if ToolKit.isInTenMinute(self.m_common_last_msg_time, data.time) then
                data.isShowTime = false;
            else
                data.isShowTime = true;
            end;
        end;
        self.m_common_last_msg_time = data.time;
        data.mnick = UserInfo.getInstance():getName();
        data.msg = self.m_common_chat_msg;
        local item = new(HallChatRoomItem, data);
        self.m_common_room_msg_stroll_view:addChild(item);
        FriendsData.getInstance():addChatDataByUid(tonumber(self.m_common_room_item:getUid()), self.m_common_chat_msg);
        self.m_common_room_msg_stroll_view:gotoBottom();
        self.m_common_room_bottom_send_edit:setText(nil);
    end;   
    self.m_isSendingMsg = false;
end;
-- 接收自己发的消息
HallChatDialog.onRecvCommonChatMsg2 = function(self, data)
    if data.ret == 0 then
        self.m_isSendingMsg = false;
        ------- 本人聊天item -------
        local data ={}
        data.send_uid = UserInfo.getInstance():getUid();
        data.time = os.time();
        if ToolKit.isSecondDay(self.m_common_last_msg_time) then
            data.isShowTime = true;
        else
            if ToolKit.isInTenMinute(self.m_common_last_msg_time, data.time) then
                data.isShowTime = false;
            else
                data.isShowTime = true;
            end;
        end;
        self.m_common_last_msg_time = data.time;
        data.mnick = UserInfo.getInstance():getName();
        data.msg = self.m_common_chat_msg;
        local item = new(HallChatRoomItem, data);
        self.m_common_room_msg_stroll_view:addChild(item);
        FriendsData.getInstance():addChatDataByUid(tonumber(self.m_common_room_item:getUid()), self.m_common_chat_msg);
        self.m_common_room_msg_stroll_view:gotoBottom();
        self.m_common_room_bottom_send_edit:setText(nil);
    elseif data.ret == 1 then
        local show = new(Node);
        local nodebg = new(Image,"common/background/chat_time_bg.png");
        nodebg:setSize(590,40);
        nodebg:setAlign(kAlignCenter);
        local msg = "*对方当前版本过低，暂不支持聊天功能";
        local text = new(Text,msg,nil,nil,nil,nil,32,80,80,80);
        text:setAlign(kAlignCenter);
        show:setSize(600,100);
        show:addChild(nodebg);
        show:addChild(text);
        self.m_common_room_msg_stroll_view:addChild(show);
        self.m_common_room_msg_stroll_view:gotoBottom();
    elseif data.ret == 2 then -- 禁言
        self.m_isSendingMsg = false;
    elseif data.ret == 3 then -- 屏蔽频繁刷屏（相同内容/空格）
        self.m_isSendingMsg = false;
        ChessToastManager.getInstance():showSingle("亲，消息不能为空或频繁发送哦",1500);
    else
        self.m_isSendingMsg = false;
        ChessToastManager.getInstance():showSingle("消息发送失败了",1500);        
    end;   
end;


-- 接收好友发的消息
HallChatDialog.recvCommonRoomMsg = function(self, data)
    if not data then
        return;
    end;
    --只有上方好友发的消息才接收
    if data.send_uid == tonumber(self.m_common_room_item:getUid()) then
        if ToolKit.isSecondDay(self.m_common_last_msg_time) then
            data.isShowTime = true;
        else
            if ToolKit.isInTenMinute(self.m_common_last_msg_time, data.time) then
                data.isShowTime = false;
            else
                data.isShowTime = true;
            end;
        end;
        self.m_common_last_msg_time = data.time;
        local item = new(HallChatRoomItem, data);
        self.m_common_room_msg_stroll_view:addChild(item);
        self.m_common_room_msg_stroll_view:gotoBottom();
        self:resetUnreadMsgNum();
    end;
end;

HallChatDialog.resetUnreadMsgNum = function(self)
    FriendsData.getInstance():updateUnreadChatByUid(tonumber(self.m_common_room_item:getUid()));
end;


HallChatDialog.onRecvServerGetMemberList = function(self, data)
    if self.m_member_from == 2 then -- 同城
        self:loadCityRoomMember(data);
    elseif self.m_member_from == 1 then -- 大师
        self:loadDashiRoomMember(data);
    end;
end;
-- 添加关注回调
HallChatDialog.onRecvServerAddFllow = function(self, info)
    if self.m_cur_member then
        self.m_cur_member:onRecvServerAddFllow(info);
    end;
end;
--HallChatDialog.onSaveUserInfoCityCode = function(self,isSuccess,message)
--    if not isSuccess then
--        local message = "城市信息修改失败，稍候再试！";
--        ChessToastManager.getInstance():show(message);
--  		return;
--    else

--    end

--end;



---------------------------- event ----------------------------
HallChatDialog.onEventResponse = function(self, cmd, status, data)
    if cmd == kFriend_UpdateChatMsg then
        if self.m_current_view == HallChatDialog.MAIN_CHAT then
            if status then
                if self.m_chat_list_items then
                    for index = 1,#self.m_chat_list_items do
                        local uid = self.m_chat_list_items[index]:getUid();
                        if uid and uid == tonumber(status.send_uid) then
                            self.m_chat_list_items[index]:updateUserMsgByMsg(status);
                            break;
                        end
                    end;
                end;   
            end
        elseif self.m_current_view == HallChatDialog.COMMON_CHAT then
            if status then
                self:recvCommonRoomMsg(status);
            end            
        end;
    elseif cmd == kFriend_UpdateUserData then
        if self.m_current_view == HallChatDialog.MAIN_CHAT then
            if self.m_chat_list_items then
                for index =1,#self.m_chat_list_items do
                    local uid = self.m_chat_list_items[index]:getUid();
                    for _,sdata in pairs(status) do
                        if uid and uid == tonumber(sdata.mid) then
                            self.m_chat_list_items[index]:updateUserData(sdata);
                            break;
                        end
                    end
                end;
            end;
        elseif self.m_current_view == HallChatDialog.DASHI_CHAT then
            if self.m_dashi_room_scroll_msg_view then
                local childs = self.m_dashi_room_scroll_msg_view:getChildren();
                for index =1,#childs do
                    local uid = childs[index]:getUid();
                    for _,sdata in pairs(status) do
                        if uid and uid == tonumber(sdata.mid) then
                            childs[index]:updateUserData(sdata);
                            break;
                        end
                    end
                end;
            end;        
        elseif self.m_current_view == HallChatDialog.CITY_CHAT then
            if self.m_city_room_scroll_msg_view then
                local childs = self.m_city_room_scroll_msg_view:getChildren();
                for index =1,#childs do
                    local uid = childs[index]:getUid();
                    for _,sdata in pairs(status) do
                        if uid and uid == tonumber(sdata.mid) then
                            childs[index]:updateUserData(sdata);
                            break;
                        end
                    end
                end;
            end;  
         elseif self.m_current_view == HallChatDialog.WORLD_CHAT then
            if self.m_world_room_scroll_msg_view then
                local childs = self.m_world_room_scroll_msg_view:getChildren();
                for index =1,#childs do
                    local uid = childs[index]:getUid();
                    for _,sdata in pairs(status) do
                        if uid and uid == tonumber(sdata.mid) then
                            childs[index]:updateUserData(sdata);
                            break;
                        end
                    end
                end;
            end;   
        elseif self.m_current_view == HallChatDialog.CREATE_CHAT then
            if self.m_create_chat_scroll_view then
                local childs = self.m_create_chat_scroll_view:getChildren();
                for index =1,#childs do
                    local uid = childs[index]:getUid();
                    for _,sdata in pairs(status) do
                        if uid and uid == tonumber(sdata.mid) then
                            childs[index]:updateUserData(sdata);
                            break;
                        end
                    end
                end;
            end;               
        elseif self.m_current_view == HallChatDialog.CITY_MEMBER_CHAT then
             if self.m_member_list_scroll_view then
                local childs = self.m_member_list_scroll_view:getChildren();
                for index =1,#childs do
                    local uid = childs[index]:getUid();
                    for _,sdata in pairs(status) do
                        if uid and uid == tonumber(sdata.mid) then
                            childs[index]:updateUserData(sdata);
                            break;
                        end
                    end
                end;
            end;             
        elseif self.m_current_view == HallChatDialog.DASHI_MEMBER_CHAT then
             if self.m_member_list_scroll_view then
                local childs = self.m_member_list_scroll_view:getChildren();
                for index =1,#childs do
                    local uid = childs[index]:getUid();
                    for _,sdata in pairs(status) do
                        if uid and uid == tonumber(sdata.mid) then
                            childs[index]:updateUserData(sdata);
                            break;
                        end
                    end
                end;
            end;    
        end;
    end;
end;
















----------------------------------------------------------------
--------------------------聊天主界面item------------------------
----------------------------------------------------------------


HallChatDialogItem = class(Button,false);

HallChatDialogItem.ctor = function(self, data, index, itemType,room)
    super(self,"drawable/blank.png","drawable/blank.png")
    if not data then return end;
    self.m_data = data;
    self.m_index = index;
    self.m_itemType = itemType;
    self.m_room = room;
    self:setSize(610,135);
    self:setOnClick(self, self.onItemClick);
    self:setSrollOnClick();
    -------- views --------
    self.m_bg = new(Image,"drawable/blank.png");
    self.m_bg:setPos(0,0);
    self.m_bg:setSize(610,135);
    self.m_bg:setAlign(kAlignLeft);
    self.m_bg_line = new(Image,"common/decoration/name_line.png");
    self.m_bg_line:setSize(610);
    self.m_bg_line:setAlign(kAlignBottom);
    self.m_bg:addChild(self.m_bg_line);
    self:addChild(self.m_bg);
    self.m_bg:setEventTouch(nil,nil);

    --未读消息
    self.m_unread_img = new(Image, "dailytask/redPoint.png"); 
    self.m_unread_img:setLevel(1);
    self.m_unread_img:setAlign(kAlignTopRight);
--    self.m_unread_img:setPos(-12, -5);
    self.m_unread_num = new(Text,"",26, 26, kAlignCenter,nil,15,255, 255, 255);
    self.m_unread_img:addChild(self.m_unread_num);
    self.m_unread_num:setPos(nil, -2);
    self.m_unread_img:setVisible(false);
    local nameX,nameY = 130, 30;
    local lastMsgX,lastMsgY = 135, 75;
    local timeX,timeY = 20,30;
    -- icon_frame
    self.m_icon_frame = new(Image,"userinfo/icon_9090_frame.png");
    self.m_icon_frame:setPos(20);
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
            self.m_last_msg = new(Text, self.m_data.last_msg or " ", 0, 0, nil,nil,28,120, 120, 120);
	        self.m_last_msg:setPos(lastMsgX,lastMsgY);
	        self.m_bg:addChild(self.m_last_msg);
            -- time
            self.m_time = new(Text, self:getTime(self.m_data.time) or " ", 0, 0, nil,nil,24,120, 120, 120);
	        self.m_time:setPos(timeX,timeY);
            self.m_time:setAlign(kAlignBottomRight);
	        self.m_bg:addChild(self.m_time); 
        else
            self:loadIcon();
            -- friend_name
	        self.m_friend_name = new(Text,"博雅象棋", 0, 0, nil,nil,36,80, 80, 80);
	        self.m_friend_name:setPos(nameX,nameY);
	        self.m_bg:addChild(self.m_friend_name);
            -- last_msg
            self.m_last_msg = new(Text, self.m_data.last_msg or "加载中...", 0, 0, nil,nil,28,120, 120, 120);
	        self.m_last_msg:setPos(lastMsgX,lastMsgY);
	        self.m_bg:addChild(self.m_last_msg);
            -- time
            self.m_time = new(Text, self:getTime(self.m_data.time) or "加载中...", 0, 0, nil,nil,24,120, 120, 120);
	        self.m_time:setPos(timeX,timeY);
            self.m_time:setAlign(kAlignBottomRight);
	        self.m_bg:addChild(self.m_time); 
        end;
        local chat = FriendsData.getInstance():getChatByUid(self.m_uid);
        if chat and chat.unReadNum then
            self:setUnreadMsgNum(chat.unReadNum);
        end;
    elseif self.m_itemType == 1 then 
        -- room_id,大师房间用的php提供的id
        -- 同城使用city_code作为room_id;
        self.m_chat_room_id = self.m_data.id;
        self.m_min_score = self.m_data.min_score;
        self.m_city_code = UserInfo.getInstance():getCityCode();--GameCacheData.getInstance():getInt(GameCacheData.LOCATE_CITY_CODE,0);
        self.m_city_name = UserInfo.getInstance():getCityName();--GameCacheData.getInstance():getString(GameCacheData.LOCATE_CITY_NAME,nil);
        self:loadChatRoomIcon(self.m_data);
        -- chat_room_name
        if self.m_chat_room_id == 1000 then
	        self.m_chat_room_name = new(Text, self.m_data.name or "象棋大师聊天室", 0, 0, nil,nil,36,80, 80, 80);
        elseif self.m_chat_room_id == 1001 then -- 这1001只为了和大师场区分
            if not self.m_city_name or self.m_city_name == "" then
                self.m_chat_room_name = new(Text, "同城棋友聊天室", 0, 0, nil,nil,36,80, 80, 80);
            else
                self.m_chat_room_name = new(Text, self.m_city_name.."棋友聊天室", 0, 0, nil,nil,36,80, 80, 80);
            end;
        elseif self.m_chat_room_id == 1002 then
            self.m_chat_room_name = new(Text, "世界棋友聊天室", 0, 0, nil,nil,36,80, 80, 80);
        end;
	    self.m_chat_room_name:setPos(nameX,nameY);
	    self.m_bg:addChild(self.m_chat_room_name);
        -- last_msg
        self.m_chat_room_last_msg = new(Text, self.m_data.last_msg or "...", 0, 0, nil,nil,28,120, 120, 120);
	    self.m_chat_room_last_msg:setPos(lastMsgX,lastMsgY);
	    self.m_bg:addChild(self.m_chat_room_last_msg);
        -- time
        self.m_chat_room_time = new(Text, self:getTime(self.m_data.time) or "...", 0, 0, nil,nil,24,120, 120, 120);
	    self.m_chat_room_time:setPos(timeX,timeY);
        self.m_chat_room_time:setAlign(kAlignBottomRight);
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
    return self.m_chat_room_id;
end;

HallChatDialogItem.getCityCode = function(self)
    return self.m_city_code;
end;

HallChatDialogItem.setCityName = function(self,city)
    self.m_city_name = city;
    self.m_chat_room_name:setText(self.m_city_name.."棋友聊天室");
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

--HallChatDialogItem.setCommonChatLastMsg = function(self, lastMsg)
--    if not lastMsg then return end;
--    local str = lastMsg;
--    local lens = string.lenutf8(GameString.convert2UTF8(str) or "");    
--    if  lens > 10 then--限制10字
--        str = GameString.convert2UTF8(string.subutf8(str,1,10).."...");
--    end;   
--    self.m_last_msg:setText(str);
--end;




HallChatDialogItem.setUnreadMsgNum = function(self, unreadNum)
    if unreadNum ~= 0 then
--        if not self.m_unread_img:getVisible() then
            self.m_unread_img:setVisible(true);
--        end;
--        if unreadNum > 9 then
--            self.m_unread_img:setSize(40,26);
--            self.m_unread_num:setSize(40,26);
--            self.m_unread_num:setAlign(kAlignCenter);
--            if unreadNum > 99 then
--                self.m_unread_num:setText("99+");
--            else
--                self.m_unread_num:setText(unreadNum);
--            end;
--        else
--            self.m_unread_img:setSize(26,26);
--            self.m_unread_num:setSize(26,26);
--            self.m_unread_num:setAlign(kAlignCenter);
--            self.m_unread_num:setText(unreadNum);
--        end;
    else
        self.m_unread_img:setVisible(false);
    end;
end;


HallChatDialogItem.getUid = function(self)
    return self.m_uid or nil;
end

HallChatDialogItem.getFriendName = function(self)
    return self.m_friend_name:getText() or "博雅中国象棋";
end;

HallChatDialogItem.getTime = function(self, time)
    if ToolKit.isSecondDay(time) then
        return os.date("%m-%d ",time);-- 08-07格式
    else
        return os.date("%H:%M",time);--%Y/%m/%d %X
    end;
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
    local icon = data.img_url;
    if not icon then
        self.m_chat_room_icon = new(Mask,"","userinfo/icon_8484_mask.png");
    else
        self.m_chat_room_icon = new(Mask,"drawable/blank.png" ,"userinfo/icon_8484_mask.png");
        self.m_chat_room_icon:setUrlImage(icon,UserInfo.DEFAULT_ICON[1]);  
    end;
    self.m_chat_room_icon:setSize(84,84);
    self.m_chat_room_icon:setAlign(kAlignCenter);
    self.m_icon_frame:addChild(self.m_chat_room_icon)
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
    self.m_friend_name:setText(data.mnick);
end;

HallChatDialogItem.updateUserMsgByChatList = function(self,data)
    self.m_last_msg:setText(data.last_msg or "");
    self.m_time:setText(self:getTime(data.time));
    self:setUnreadMsgNum(data.unReadNum);
end

HallChatDialogItem.updateUserMsgByMsg = function(self, data)
    local chat = FriendsData.getInstance():getChatByUid(data.send_uid);
    self.m_last_msg:setText(chat.last_msg or "");
    self.m_time:setText(self:getTime(chat.time));
    self:setUnreadMsgNum(chat.unReadNum);
end;



HallChatDialogItem.onItemClick = function(self)
    self.m_room:onMainChatItemClick(self);
end;















----------------------------------------------------------------
--------------------------创建会话item--------------------------
----------------------------------------------------------------

HallCreateChatDialogItem = class(Button,false)


HallCreateChatDialogItem.ctor = function(self, uid, index, room)
    super(self,"drawable/blank.png","drawable/blank.png")
    if not uid then return end;
    self.m_uid = uid;
    self.m_index = index;
    self.m_room = room;    
    self.m_user_data = FriendsData.getInstance():getUserData(self.m_uid);
    self.m_user_status = FriendsData.getInstance():getUserStatus(self.m_uid);
    self:setSize(610,100);
    self:setOnClick(self, self.onItemClick);
    ----------- views -----------
    self.m_bg = new(Image,"drawable/blank.png");
    self.m_bg:setPos(0,0);
    self.m_bg:setSize(610,100);
    self.m_bg:setAlign(kAlignLeft);
    self.m_bg_line = new(Image,"common/decoration/name_line.png");
    self.m_bg_line:setSize(600);
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
    self.m_friend_name:setText(data.mnick);
end;

HallCreateChatDialogItem.onItemClick = function(self)
    self.m_room:onCreateChatItemClick(self);
end;













----------------------------------------------------------------
--------------------------member_list --------------------------
----------------------------------------------------------------

--HallMemberDialogItem = class(Button,false)


--HallMemberDialogItem.ctor = function(self, uid, index, room)
--    super(self,"drawable/blank.png","drawable/blank.png")
--    if not uid then return end;
--    self.m_uid = uid;
--    self.m_index = index;
--    self.m_room = room;    
--    self.m_user_data = FriendsData.getInstance():getUserData(self.m_uid);
--    self.m_user_status = FriendsData.getInstance():getUserStatus(self.m_uid);

--    self:setSize(610,120);
--    self:setOnClick(self, self.onItemClick);
--    ----------- views -----------
--    self.m_bg = new(Image,"drawable/blank.png");
--    self.m_bg:setPos(0,0);
--    self.m_bg:setSize(610,120);
--    self.m_bg:setAlign(kAlignLeft);
--    self.m_bg_line = new(Image,"common/decoration/name_line.png");
--    self.m_bg_line:setSize(600);
--    self.m_bg_line:setAlign(kAlignBottom);
--    self.m_bg:addChild(self.m_bg_line);
--    self:addChild(self.m_bg);
--    self.m_bg:setEventTouch(nil,nil);
--    local nameX,nameY = 120, 25;
--    local lastMsgX,lastMsgY = 135, 75;
--    local timeX,timeY = 20,30;
--    -- icon_frame
--    self.m_icon_frame = new(Image,"userinfo/icon_7070_frame2.png");
--    self.m_icon_frame:setPos(30);
--    self.m_icon_frame:setAlign(kAlignLeft);
--    self.m_bg:addChild(self.m_icon_frame);
--    -- friend_name
--	self.m_friend_name = new(Text, "博雅中国象棋", 0, 0, nil,nil,36,80, 80, 80);
--	self.m_friend_name:setPos(nameX,nameY);
--    self.m_friend_name:setAlign(kAlignTopLeft);
--	self.m_bg:addChild(self.m_friend_name);
--    if self.m_user_data then
--        self:loadFriendIcon(self.m_user_data);
--        self.m_friend_name:setText(self.m_user_data.mnick);
--    end;
--    -- level
--    self.m_memeber_level = new(Image,"common/icon/level_9.png");
--    self.m_memeber_level:setPos(nameX + 5,nameY + 45);
--    self.m_bg:addChild(self.m_memeber_level);
--    -- level_txt
--    self.m_memeber_level_txt = new(Text,"...",0, 0, nil,nil,28,120, 80, 70);
--    self.m_memeber_level_txt:setPos(nameX + 80,nameY + 45);
--    self.m_bg:addChild(self.m_memeber_level_txt);
--    self:setMemberLevel(self.m_user_data);

--    -- 关注
--    self.m_memeber_gz_btn = new(Button,"common/button/dialog_btn_3_normal.png","common/button/dialog_btn_3_press.png",nil,nil);
--    self.m_memeber_gz_btn:setAlign(kAlignRight);
--    self.m_memeber_gz_btn:setPos(30);
--    self.m_memeber_gz_btn:setSize(150,55);
--    self.m_memeber_gz_btn:setOnClick(self,self.memberGZbtnClick);
--    -- 关注txt
--    self.m_memeber_gz_txt = new(Text,"",0,0,nil,nil,28,240,230,210);
--    self.m_memeber_gz_btn:addChild(self.m_memeber_gz_txt);
--    self.m_memeber_gz_txt:setAlign(kAlignCenter);
--    self.m_bg:addChild(self.m_memeber_gz_btn);
--    if FriendsData.getInstance():isYourFriend(self.m_uid) ~= -1 or 
--        FriendsData.getInstance():isYourFollow(self.m_uid) ~= -1 then
--        self.m_memeber_gz_txt:setText("已关注");
--    else
--        self.m_memeber_gz_txt:setText("加关注");
--    end;
--    -- 如果是自己隐藏关注
--    if (self.m_uid == UserInfo.getInstance():getUid()) then
--        self.m_memeber_gz_btn:setVisible(false);
--    end;

--end;



--HallMemberDialogItem.dtor = function(self)


--end;



----    if not self.m_gz_state then
----        -- 发送关注请求
----        self.m_memeber_gz_txt:setText("已关注");    
----    else
----        self.m_memeber_gz_txt:setText("加关注"); 
----    end;
----    self.m_gz_state = not self.m_gz_state; 

--HallMemberDialogItem.memberGZbtnClick = function(self)
--    self.m_room.m_cur_member = self;
--    if FriendsData.getInstance():isYourFollow(self.m_uid) == -1 then
--        self:follow(self.m_uid);
--    else
--        self:unFollow(self.m_uid);
--    end
--end
----关注
--HallMemberDialogItem.follow = function(self,gz_uid)
--    local info = {};
--    info.uid = UserInfo.getInstance():getUid();
--    info.target_uid = gz_uid;
--    info.op = 1;
--    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_ADD_FLLOW,info);
--end

----取消关注
--HallMemberDialogItem.unFollow = function(self,gz_uid)
--    local info = {};
--    info.uid = UserInfo.getInstance():getUid();
--    info.target_uid = gz_uid;
--    info.op = 0;
--    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_ADD_FLLOW,info);
--end

----更新状态
--HallMemberDialogItem.onRecvServerAddFllow = function(self,info)
--    if info.ret == 0 then
--        -- 发起关注/取消关注，server返回会先更新FriendData的isYourFollow
--        if FriendsData.getInstance():isYourFollow(self.m_uid) == -1 then
--            ChessToastManager.getInstance():showSingle("已取消关注");
--            self.m_memeber_gz_txt:setText("加关注");
--        else

--            ChessToastManager.getInstance():showSingle("关注成功！");
--            self.m_memeber_gz_txt:setText("已关注");
--        end;
--    end
--end





--HallMemberDialogItem.getFriendName = function(self)
--    return self.m_friend_name:getText() or "博雅中国象棋";
--end;

--HallMemberDialogItem.getUid = function(self)
--    return self.m_uid or 0;
--end

--HallMemberDialogItem.loadFriendIcon = function(self,data)
--    local icon = data.icon_url;
--    if not self.m_user_icon then
--        if not icon then 
--            if data.iconType > 0 then
--                icon = UserInfo.DEFAULT_ICON[data.iconType] or UserInfo.DEFAULT_ICON[1];
--            else
--                icon = UserInfo.DEFAULT_ICON[1]
--            end;
--            self.m_user_icon = new(Mask,icon ,"userinfo/icon_6464_mask.png");
--        else
--            self.m_user_icon = new(Mask,"drawable/blank.png" ,"userinfo/icon_6464_mask.png");
--            self.m_user_icon:setUrlImage(icon,"userinfo/women_head01.png");            
--        end;
--        self.m_user_icon:setSize(64,64);
--        self.m_user_icon:setAlign(kAlignCenter);
--        self.m_icon_frame:addChild(self.m_user_icon)
--    else
--        if not icon then 
--            if data.iconType > 0 then
--                icon = UserInfo.DEFAULT_ICON[data.iconType] or UserInfo.DEFAULT_ICON[1];
--            else
--                icon = UserInfo.DEFAULT_ICON[1];
--            end;
--            self.m_user_icon:setFile(icon);
--        else
--            self.m_user_icon:setUrlImage(icon,"userinfo/women_head01.png");            
--        end;   
--    end   
--end;


--HallMemberDialogItem.updateUserData = function(self, data)
--    self:loadFriendIcon(data);
--    self:setMemberLevel(data);
--    self.m_friend_name:setText(data.mnick);
--    self.m_user_data = data;
--end;


--HallMemberDialogItem.setMemberLevel = function(self, data)
--    if not data then return end
--    local up_level = 10 - UserInfo.getInstance():getDanGradingLevelByScore(data.score or 0);
--    self.m_memeber_level:setFile("common/icon/level_"..up_level ..".png");    
--    self.m_memeber_level_txt:setText("积分："..data.score or "...");
--end



--HallMemberDialogItem.getUserData = function(self)
--    return self.m_user_data or nil;
--end;
--HallMemberDialogItem.onItemClick = function(self)
--    self.m_room:onMemberItemClick(self);
--end;

--HallMemberDialogItem.getName = function(self)
--    return self.m_friend_name:getText();
--end;















----------------------------------------------------------------
--------------------------chatroom item ------------------------
----------------------------------------------------------------

-- 大师/同城/世界/普通聊天都用的item
HallChatRoomItem = class(Node)

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
    end;
    --时间
    self.m_time_bg = new(Image,"common/background/chat_time_bg.png");
    self.m_time_bg:setAlign(kAlignTop);
    self.m_time = new(Text, self:getTime(data.time), 0, 0, nil,nil,20,120, 120, 120);
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
    self.m_vip_frame = new(Image,"vip/vip_90.png");
    self.m_vip_frame:setAlign(kAlignCenter);
    self.m_vip_logo = new(Image,"vip/vip_logo.png");

    self.m_name_text = new(Text,self.m_name,nil,nil,nil,nil,24,65,120,190);
    local nw,nh = self.m_name_text:getSize();
    self:addChild(self.m_name_text);

    local itemX, itemY = 10, 30;
    if self.m_uid == UserInfo.getInstance():getUid() then
        self.m_message_bg = new(Image,"common/background/message_bg_2.png",nil, nil,24,24,24,24);
        self.m_message_bg:setPos(itemX + 100, itemY + 50);
        self.m_message_bg:setAlign(kAlignTopRight);
        self.m_icon_frame:setPos(itemX, itemY);
        self.m_icon_frame:setAlign(kAlignTopRight);
        self.m_name_text:setPos(itemX + 120, itemY + 10);
        self.m_name_text:setAlign(kAlignTopRight);
        self.m_vip_logo:setAlign(kAlignTopRight);
        self.m_vip_logo:setPos(itemX + 125 + nw,itemY + 5);
        if UserInfo.getInstance():getIsVip() == 1 then
            self.m_vip_logo:setVisible(true);
--            self.m_vip_frame:setVisible(true);
        else
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
        self.m_message_bg = new(Image,"common/background/message_bg_1.png",nil, nil, 24,24,24,24);
        self.m_message_bg:setPos(itemX + 100, itemY + 50);
        self.m_message_bg:setAlign(kAlignTopLeft);
        self.m_icon_frame:setPos(itemX, itemY);
        self.m_icon_frame:setAlign(kAlignTopLeft);
        self.m_name_text:setPos(itemX + 120, itemY + 10);
        self.m_name_text:setAlign(kAlignTopLeft);
        self.m_vip_logo:setAlign(kAlignTopLeft);
        self.m_vip_logo:setPos(itemX + 120,itemY + 5);
        local vw,vh = self.m_vip_logo:getSize();
        if self.m_friend_info then
            if self.m_friend_info.is_vip == 1 then
                self.m_name_text:setPos(itemX + 125 + vw,itemY + 10);
                self.m_vip_logo:setVisible(true);
                self.m_vip_frame:setVisible(true);
            else
                self.m_name_text:setPos(itemX + 120, itemY + 10);
                self.m_vip_logo:setVisible(false);
                self.m_vip_frame:setVisible(false);
            end;
            if self.m_friend_info.iconType == -1 then
                self.m_user_icon:setUrlImage(self.m_friend_info.icon_url);
            else
                local file = UserInfo.DEFAULT_ICON[self.m_friend_info.iconType] or UserInfo.DEFAULT_ICON[1];
                self.m_user_icon:setFile(file);
            end
        else
            self.m_name_text:setPos(itemX + 120, itemY + 10);
            self.m_vip_logo:setVisible(false);
            self.m_vip_frame:setVisible(false);        
            local file = UserInfo.DEFAULT_ICON[1];
            self.m_user_icon:setFile(file);
        end
    end
    self.m_icon_frame:addChild(self.m_vip_frame);
    self:addChild(self.m_vip_logo);
    self:addChild(self.m_message_bg);

    local msgStr, msgW, msgH = self:returnStrAndWH(self.m_str);
	self.m_text = new(TextView,msgStr,msgW,0,nil,nil,32,80,80,80);
    local w,h = self.m_text:getSize();
    self.m_message_bg:setSize(w+50,h+30);

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

    local itemW = 610;
    local itemH = select(2,self.m_message_bg:getSize()) + select(2,self.m_icon_frame:getSize()) + select(2,self.m_time_bg:getSize());
	self:setSize(itemW,itemH);
end

HallChatRoomItem.dtor = function(self)

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
end;


HallChatRoomItem.returnStrAndWH = function(self, msg)
    local strW, strH = 64,64; -- 默认气泡宽高
    local lens = string.lenutf8(GameString.convert2UTF8(msg) or "");    
    local strMsg = msg;
    if lens > 140 then--限制140字
        lens = 140;
        strMsg = GameString.convert2UTF8(string.subutf8(msg,1,140));
    end;
    local tempMsg = new(Text,msg,0, 0, kAlignLeft,nil,32,80, 80, 80);
    local tempMsgW, tempMsgH = tempMsg:getSize();
    if tempMsgW ~= 0 and tempMsgH ~= 0 then
        if tempMsgW >= 448 then -- 448,32字符宽，14个字
            tempMsgW = 448;
        elseif tempMsgW <= 64 then
            tempMsgW = 64;
        end;
        return strMsg,tempMsgW, tempMsgH;
    end;
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
    if data and data.is_vip == 1 then
        local itemX, itemY = 10, 30;
        local vw,vh = self.m_vip_logo:getSize();
        self.m_name_text:setPos(itemX + 125 + vw,itemY + 10);
        self.m_vip_logo:setVisible(true);
        self.m_vip_frame:setVisible(true);
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
        self.m_extra_msg = FriendsData.getInstance():getUserData(self.m_uid);
        if self.m_extra_msg and  next(self.m_extra_msg) then
            self.m_userinfo_dialog:show(self.m_extra_msg);
        end
    end;
end;