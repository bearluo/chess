--region friendMsgScene.lua
--Author : LeoLi
--Date   : 2015/7/14

require(BASE_PATH.."chessScene");
require("dialog/friends_pop_dialog");
require("dialog/city_locate_pop_dialog");
require("animation/loading");

FriendMsgScene = class(ChessScene);

FriendMsgScene.s_controls = 
{
    back_btn = 1;
    send_msg_btn = 2;
    content_view = 3;
    load_view = 4;

}

FriendMsgScene.s_cmds = 
{
     changeFriendsData = 1;  
     changeFriendsMsg  = 2;
     changeFriendsIcon = 3;
     unreadNum = 4;
     entryChatRoom = 5;
}

FriendMsgScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = FriendMsgScene.s_controls;
    self:init();
end 

FriendMsgScene.resume = function(self)
    ChessScene.resume(self);
    self:refreshMsgList();
end;


FriendMsgScene.pause = function(self)
	ChessScene.pause(self);
end 


FriendMsgScene.dtor = function(self)
    ShowMessageAnim.deleteAll();
    Loading.deleteAll();
    delete(self.m_msg_list);
    self.m_msg_list =nil
end 

----------------------------------- function ----------------------------

--初始化部分状态
FriendMsgScene.init = function(self)
    if  self.m_msg_list then
        delete(self.m_msg_list);
        self.m_msg_list = nil
    end;
--    FriendsData.getInstance():createNewChat(1138);
--    FriendsData.getInstance():createNewChat(1139);
--    FriendsData.getInstance():createNewChat(1140);
    self.m_chat_list = FriendsData.getInstance():getChatList();
    self.m_room_list = UserInfo.getInstance():getChatRoomList();
    self.m_content_view = self:findViewById(FriendMsgScene.s_controls.content_view);
    local contentW, contentH = self:getSize();
    self.m_content_view:setSize(contentW, contentH - 70);--70是tittle的高
    self.m_load_view = self:findViewById(FriendMsgScene.s_controls.load_view); 
	local w,h = self.m_content_view:getSize();

    local NVerticalListView = require('ui2.NVerticalListView')
    self.m_msg_list = NVerticalListView.create()
    self.m_content_view:addChild(self.m_msg_list);
    self.m_msg_list:setSize(w, h)
--    local chatList = {};
--    table.insert(chatList, self.m_chat_list);
--    self:initMsgList(chatList[1]);

    self.m_bannerNode = new(Node);
    self.m_bannerNode:setSize(w,100);
    self.m_load_text = new(Text,GameString.convert2UTF8("下拉即可刷新..."));

    self.m_bannerNode:addChild(self.m_load_text);
    self.m_load_text:setAlign(kAlignBottom);
    self.m_load_text:setPos(nil,30);
    self.m_msg_list:setTopBanner(self.m_bannerNode);

    self.m_msg_list:setOnScroll(self.onMsgListScroll, self);
    self.m_msg_list:setOnBeginBouncing(self.onMsgListBeginBouncing, self)
    self.m_msg_list:setOnStop(self.onMsgListStop, self)

    self.m_msg_list:setTopBannerMinSize(50)
	
end


FriendMsgScene.initMsgList = function(self, chatList, publicRoomList, isInsert)
--    local bgNode = new(Node);--此节点解决宽屏msgItem不能居中的问题
--    local w,h = self.m_content_view:getSize();
--    bgNode:setSize(w, 112);
--    local msgNode = new(Node);
--    local msgItem = new(FriendMsgItem, chatList[i], self,i);
--    msgItem:setPos(15, 10);
    if self.m_msg_list:getItemCount() < #self.m_room_list then
        local lastRoomId = ChatRoomData.getInstance():getInt(GameCacheData.LAST_ENTRY_ROOM_ID,0); 
        local j = 1;
        for i = 1, #self.m_room_list do
            local bgNode = new(Node);
            local w,h = self.m_content_view:getSize();
            bgNode:setSize(w, 112);
            local msgNode = new(Node);
            local lastMsg = {};
            if lastRoomId ~= 0 and self.m_room_last_msg then
                for j = 1, #self.m_room_last_msg do
                    if self.m_room_last_msg[j].roomid == publicRoomList[i].id then
--                        local  k = publicRoomList[i].id:get_value();
                        lastMsg = self.m_room_last_msg[j];
                        break;
                    end
                end 
            end
            local city_id = GameCacheData.getInstance():getInt(GameCacheData.LOCATE_CITY_CODE,0);
            local city_name = GameCacheData.getInstance():getString(GameCacheData.LOCATE_CITY_NAME,nil);
            if publicRoomList[i].id == 1001 and city_id ~= 0 then
                publicRoomList[i].id = city_id;
                if city_name then
                    publicRoomList[i].name = city_name .. "棋友聊天室";
                else
                    publicRoomList[i].name = "同城棋友聊天室";
                end
            end
            local msgItem = new(ChatRoomItem, lastMsg,self,i,1,publicRoomList[i]);
            msgItem:setPos(15, 10);
            msgNode:setSize(msgItem:getSize());
            msgNode:addChild(msgItem);
            msgNode.getMsgItem = (function ()
                local currentMsgItem = msgItem 
                return function ()
                    return currentMsgItem
                end 
            end)()
            bgNode:addChild(msgNode); 
            if UserInfo.getInstance():getScore() ~= publicRoomList[i].min_score then -- >=
                self.m_msg_list:addItem(bgNode, j);
                j = j + 1;
            end
            msgNode:setAlign(kAlignLeft); 
            msgNode:setEventDrag(nil, nil);
        end
    end
    
    local tempItemCount = self.m_msg_list:getItemCount() + 1;

    if #chatList == 0 then   
        return;
    end;

    for i = 1, #chatList do
        local bgNode = new(Node);--此节点解决宽屏msgItem不能居中的问题
        local w,h = self.m_content_view:getSize();
        bgNode:setSize(w, 112);
        local msgNode = new(Node);
        local msgItem = new(FriendMsgItem, chatList[i], self,i,0);
        msgItem:setPos(15, 10);
        local msgDelBtn = new(Button,"friends/friend_del_msg.png");
        msgDelBtn:setAlign(kAlignRight)
        msgDelBtn:setSize(96,96);
        msgDelBtn:setPos(15,6);
        msgNode:setSize(msgItem:getSize());
        msgNode:addChild(msgDelBtn);
        msgNode:addChild(msgItem)
        msgNode.getMsgItem = (function ()
            local currentMsgItem = msgItem 
            return function ()
                return currentMsgItem
            end 
        end)()

        msgDelBtn:setOnClick(nil, function()              
            self.m_msg_list:addInvokeOnStop(function ()    
                local uid = msgNode:getMsgItem().m_uid;
                FriendsData.getInstance():removeChat(uid);
                local i = self.m_msg_list:getIndexOfItem(bgNode);
                self.m_msg_list:removeItem(i,true,nil);
                if self.m_msg_list:getItemCount() == 0 then
                    self:toastNoMsg();
                end;
            end)
        end)
        msgDelBtn:setEventDrag(nil, function() end);
        bgNode:addChild(msgNode);
        -- 如果是插入,addItem到1的位置
        if isInsert then 
            self.m_msg_list:addItem(bgNode, tempItemCount);
        else
            self.m_msg_list:addItem(bgNode, self.m_msg_list:getItemCount() + 1);
        end;
        msgNode:setAlign(kAlignCenter); 
        msgNode:setEventDrag(nil, nil);
    end;    

end;

FriendMsgScene.resumeMsgList = function (self)
    -- TODO 恢复暂停
    if self.m_msg_list then
        if self.m_msg_list:isBouncingPaused() then
            self.m_msg_list:resumeBouncing()
        end;
        self.m_isLoadingPlaying = false;
        self.m_refresh = false;
        Loading.deleteAll();
        self.m_msg_list:addInvokeOnStop(function ()
            self:refreshMsgList();
            --self:sendSocketMsg(CHATROOM_CMD_GET_LATEST_MSG,info);
         end);
    end;
end 


FriendMsgScene.refreshMsgList = function(self)
    self.m_room_last_msg = ChatRoomData.getInstance():getLastRoomMsg();
    local lastRoomId = ChatRoomData.getInstance():getInt(GameCacheData.LAST_ENTRY_ROOM_ID,0)
    if self.m_room_last_msg and lastRoomId ~= 0 then
        local packetInfo = {};
        local roomMsg = {};
        for _,v in pairs(self.m_room_last_msg) do
            if v.roomid == lastRoomId then
                roomMsg = v;
                break;
            end
        end

        if roomMsg.roomid then
            packetInfo.room_id = roomMsg.roomid;
            packetInfo.begin_msg_time = roomMsg.time;
            packetInfo.end_msg_time = os.time();
            packetInfo.last_msg_id = roomMsg.last_msg_id;
            self:requestCtrlCmd(FriendMsgController.s_cmds.updataUnReadNum,packetInfo);
        end
        --return;
       
    end
    self:updataChatRoomItem(lastRoomId);


--    self:updataItemPos(lastRoomId);

    local msgList = FriendsData.getInstance():getChatList();

    if #msgList ~= 0 or self.m_room_list then  --or self.m_msg_list
        if self.m_msg_list:getItemCount() == 0 then
            self:initMsgList(msgList,self.m_room_list);
        elseif #msgList ~= 0 then
            local newMsg = {};           
            for k, v in ipairs(msgList) do
                local isUpdateMsg = false;
                local num = self.m_msg_list:getItemCount();
                for i = num - #msgList, num do --#self.m_room_list + 1
                    local msgItem = self.m_msg_list:getItem(i):getChildren()[1].getMsgItem();
                    if v.uid == msgItem.m_uid then
                        msgItem:updateUserMsg(v);
                        isUpdateMsg = true;
                    end;
                end;
                --如果当前条目里没有过此id的消息，则新建一条
                if not isUpdateMsg then 
                    table.insert(newMsg, 1, v);
                end;
            end;   
            self:initMsgList(newMsg,self.m_room_list, true);
        end;
    else
        self:toastNoMsg();
    end;
end;

FriendMsgScene.updataChatRoomItem = function(self,lastRoomId)
    for i = 1, #self.m_room_list do
        local node = self.m_msg_list:getItem(i);     -- getChildren()[1]:getChildren()[2];
        if not node then
            return;
        end
        node = node:getChildren()[1]:getMsgItem();
        node:setUnreadAndMsg();
        if node.m_id == lastRoomId then
            for i, v in pairs(self.m_room_last_msg) do
                if lastRoomId == v.roomid then
                    node:setLastMsg(v);
                    break;
                end
            end
        end
    end
end

FriendMsgScene.toastNoMsg = function(self)
--    ShowMessageAnim.fontSize = 24;
--    ShowMessageAnim.show_time = 1000;
--    ShowMessageAnim.play(self.m_root,"暂无消息");    
    local message =  "暂无消息"; 
    ChessToastManager.getInstance():showSingle(message);   
end;



FriendMsgScene.onMsgListScroll = function(self, offset)
    -- TODO 判断说下拉到一定程度（offset > xxxx），则启动动画。
    if (offset > 50 and offset < 60) and self.m_msg_list:isBouncing() and self.m_refresh and not self.m_isLoadingPlaying then
        self.m_isLoadingPlaying = true;
        Loading.play(self.m_bannerNode);
        -- TODO 更新操作
        local anim = new(AnimInt,kAnimNormal,0,1,1000 , 0);
        anim:setEvent(self, self.resumeMsgList);
    elseif offset > 100 and offset <= 150 then
        self.m_load_text:setText(GameString.convert2UTF8("下拉即可刷新..."));
    elseif offset > 150 then
        self.m_load_text:setText(GameString.convert2UTF8("释放即可刷新..."));
        self.m_refresh = true;
    else
        self.m_load_text:setText("");
    end;
    -- TODO 如果此时动画还没播放完成，那么调用这个来暂停。
    if self.m_msg_list:isBouncing() and (offset == 50) and (not self.isPausedThisTime) and self.m_isLoadingPlaying then
        self.m_msg_list:pauseBouncing();    
        self.isPausedThisTime = true 
    end;
end;

FriendMsgScene.onMsgListBeginBouncing = function (self)    
    -- 开始回弹
    self.isPausedThisTime = false 
end 

FriendMsgScene.onMsgListStop = function (self)
    -- 滚动完全停止

    -- TODO 增加刷新了的内容。

end


FriendMsgScene.onPopDialogSureBtnClick = function(self,adapter, view, index)
    Log.i("FriendMsgScene.onMsgListItemClick");
    if adapter and index then
        local friend = adapter:getTmpView(index);
        if friend and friend.datas then
            StateMachine.getInstance():pushState(States.FriendChat,StateMachine.STYPE_CUSTOM_WAIT,nil,friend.datas);  
        end;    
    end;
end


FriendMsgScene.entryChatRoom = function(self, data, itemType)
    local roomLastMsg = {};
    if itemType == 0 then
        StateMachine.getInstance():pushState(States.FriendChat,StateMachine.STYPE_CUSTOM_WAIT,nil,data,itemType,roomLastMsg);
        return; 
    end

    if itemType == 1 then
        if self.m_room_last_msg then
            for _,v in pairs(self.m_room_last_msg) do
                if v.roomid == data.id then
                    roomLastMsg = v
                break;
                end
            end
        end
    end

    StateMachine.getInstance():pushState(States.ChatRoom,StateMachine.STYPE_CUSTOM_WAIT,nil,data,itemType,roomLastMsg);
end;



----------------------------------- onClick ---------------------------------

FriendMsgScene.onBack = function(self)
    self:requestCtrlCmd(FriendMsgController.s_cmds.onBack);
end


FriendMsgScene.onSendMsg = function(self)
    if not self.m_send_msg_dialog then
        self.m_send_msg_dialog = new(FriendPopDialog,self);
    end
    self.m_send_msg_dialog:setMode(FriendPopDialog.MODE_MSG);
    self.m_send_msg_dialog:setPositiveListener(self, self.onPopDialogSureBtnClick);
    self.m_send_msg_dialog:show();
end;


----------------------------------- function ---------------------------


FriendMsgScene.changeDataCall = function(self, data)
    if self.m_msg_list then
        for i = #self.m_room_list + 1, self.m_msg_list:getItemCount() do
        local msgItem = self.m_msg_list:getItem(i):getChildren()[1].getMsgItem();
            for _,sdata in pairs(data) do
                if msgItem.m_uid == tonumber(sdata.mid) then
                    msgItem:updateUserData(sdata);
                    break;
                end
            end
        end;
    end;    
end;

--走下拉更新消息，不主动接收
FriendMsgScene.changeUserMsgCall = function(self, data)
--    if self.m_msg_list then
--        for i = 1, self.m_msg_list:getItemCount() do
--        local msgItem = self.m_msg_list:getItem(i).getMsgItem();
--            if msgItem.m_uid == tonumber(data.send_uid) then
--                msgItem:updateUserMsg(data);
--                break;
--            end
--        end;
--    end;    
end;



FriendMsgScene.changeUserIconCall = function(self, data)
    Log.i("FriendMsgScene.changeUserIconCall--->>"..json.encode(data));
    if self.m_msg_list and data then
        for i = 1, self.m_msg_list:getItemCount() do
            local msgItem = self.m_msg_list:getItem(i):getChildren()[1].getMsgItem();
            if msgItem.m_uid == tonumber(data.what) then
                msgItem:updateUserIcon(data.ImageName);
                break;
            end
        end;
    end;    
end;

FriendMsgScene.updataRoomUnreadNum = function(self,packetInfo)
    local unreadData = {};
    unreadData.room_id = packetInfo.room_id;
    unreadData.unReadNum = packetInfo.unread_msg_num;

    if unreadData.unReadNum == 0 then
        return;
    end

    for i = 1, self.m_msg_list:getItemCount() do
        local node = self.m_msg_list:getItem(i):getChildren()[1].getMsgItem();
        if unreadData.room_id == node.m_roomData.id then
            node:loadUnReadMsg(unreadData);
            break;
        end
    end
end
-- 判断是否进入聊天室
FriendMsgScene.isEntryChatRoom = function(self,packetInfo)
    self.m_entryRoom = packetInfo;
    local roomdata = {};
    if self.m_entryRoom.status == 0 then 
        for _,v in pairs(self.m_room_list) do 
            if v.id == packetInfo.room_id then
                roomdata = v;
                break;
            end
        end
        self:entryChatRoom(roomdata,1);
    elseif self.m_entryRoom.status == 1 then
        local str = "聊天室已满..."
        ChessToastManager.getInstance():show(str,500);
    else
        local str = "网络已断开...";
        ChessToastManager.getInstance():show(str,500);
    end
end

----------------------------------- config ------------------------------
FriendMsgScene.s_controlConfig = 
{
	[FriendMsgScene.s_controls.back_btn] = {"tittle_view","tittle_bg","back"};
	[FriendMsgScene.s_controls.send_msg_btn] = {"tittle_view","tittle_bg","send"};
    [FriendMsgScene.s_controls.content_view] = {"content_view"};
    [FriendMsgScene.s_controls.load_view] = {"load_view"};


};

FriendMsgScene.s_controlFuncMap =
{
    [FriendMsgScene.s_controls.back_btn] = FriendMsgScene.onBack;
    [FriendMsgScene.s_controls.send_msg_btn] = FriendMsgScene.onSendMsg;



};


FriendMsgScene.s_cmdConfig =
{
    [FriendMsgScene.s_cmds.changeFriendsData] = FriendMsgScene.changeDataCall;
    [FriendMsgScene.s_cmds.changeFriendsMsg]  = FriendMsgScene.changeUserMsgCall;
    [FriendMsgScene.s_cmds.changeFriendsIcon] = FriendMsgScene.changeUserIconCall;
    [FriendMsgScene.s_cmds.unreadNum]   = FriendMsgScene.updataRoomUnreadNum;
    [FriendMsgScene.s_cmds.entryChatRoom]   = FriendMsgScene.isEntryChatRoom;
}


-------------------------------- private node ----------------
FriendMsgScene.default_icon = "userinfo/man_head01.png";
FriendMsgItem = class(Node);

FriendMsgItem.ctor = function(self,data, room,index,itemType,roomData)
    if not data then
        return;
    end;
    -- 1 表示公共聊天室 0 表示好友聊天
    ---onTouchEvent need---
    self.m_roomData = roomData;
    self.m_itemType = itemType;
    self.m_direction = 0; 
    self.m_move_offset = 0;
    ---onTouchEvent need---
    self.m_index = index;
	self.data = data;
    self.m_room = room;

    if itemType == 0 then
        self.m_uid = data.uid;
        self.m_friend_info = FriendsData.getInstance():getUserData(self.data.uid);
    end


	local icon_x,icon_y = 20,15;
    local icon_w,icon_h = 66,66;
	local fontsize = 25;
	local friendName_x,friendName_y = 110,20;
	local time_x ,time_y = 370,65;
	local last_msg_x,last_msg_y = 110,65;
	
	self.m_bg = new(Image,"friends/friend_msg_bg.png");
    self:addChild(self.m_bg);
    self.m_bg:setEventTouch(self, self.onEventTouch);

	if self.m_friend_info or itemType == 1 then
        --未读消息
        self.m_unread_img = new(Image, "friends/friend_tips_img.png",nil,nil,10,10,30,30); 
        self.m_unread_img:setLevel(1);
        self.m_unread_img:setAlign(kAlignTopRight);
        self.m_unread_img:setPos(-12, -5);
        self.m_unread_num = new(Text,"",26, 26, kAlignCenter,nil,15,255, 255, 255);
        self.m_unread_img:addChild(self.m_unread_num);
        self.m_unread_num:setPos(nil, -2);

        if itemType == 1 then
            self.m_unread_img:setVisible(false);
            self.m_chat_icon_frame = new(Image, "friends/friend_icon_frame.png");
            self.m_id = self.m_roomData.id;
            self:setChatRoomIcon(self.m_id);
            self.m_chat_icon_frame:addChild(self.m_unread_img); 
            self.m_bg:addChild(self.m_chat_icon_frame);

            self.m_chat_room_tittle = new(Text,self.m_roomData.name, 0, 0, nil,nil,30,70, 25, 0);
            self.m_chat_room_tittle:setPos(110,20);
            self.m_bg:addChild(self.m_chat_room_tittle);
        else
            --头像
            self.m_friend_icon_frame = new(Image, "friends/friend_icon_frame.png");
            self:setFriendIcon(self.m_friend_info);
            self.m_friend_icon_frame:addChild(self.m_unread_img); 
            self:loadUnReadMsg(self.data);

            --段位
            self.m_score_level = new(Image,"userinfo/"..UserInfo.getInstance():getDanGradingLevelByScore(tonumber(self.m_friend_info.score))..".png");
            self.m_score_level:setAlign(kAlignBottomRight);
            self.m_score_level:setPos(-8,-5);
            self.m_score_level:setLevel(1);
            self.m_friend_icon_frame:addChild(self.m_score_level);

	        self.m_bg:addChild(self.m_friend_icon_frame);

	        self.m_friend_name = new(Text,self.m_friend_info.mnick or "博雅象棋", 0, 0, nil,nil,30,70, 25, 0);
	        self.m_friend_name:setPos(friendName_x,friendName_y);
	        self.m_bg:addChild(self.m_friend_name);

        end
        if self.data.last_msg then
            local lens = string.lenutf8(GameString.convert2UTF8(self.data.last_msg) or "");    
            if  lens > 10 then--限制10字
                self.data.last_msg = GameString.convert2UTF8(string.subutf8(self.data.last_msg,1,10).."...");
            end;
        end;
        self.m_last_msg = new(Text, self.data.last_msg or "", 0, 0, nil,nil,20,160, 100, 50);
	    self.m_last_msg:setPos(last_msg_x,last_msg_y);
	    self.m_bg:addChild(self.m_last_msg);

        self.m_time = new(Text, self:getTime(self.data.time) or "", 0, 0, nil,nil,20,160, 100, 50);
	    self.m_time:setPos(time_x,time_y);
	    self.m_bg:addChild(self.m_time);
    elseif itemType == 0 then
        self.m_friend_icon_frame = new(Image, "friends/friend_icon_frame.png");

        --头像
        self:setFriendIcon(nil);

        --未读消息
        self.m_unread_img = new(Image, "friends/friend_tips_img.png",nil,nil,10,10,30,30); 
        self.m_unread_img:setLevel(1);
        self.m_unread_img:setAlign(kAlignTopRight);
        self.m_unread_img:setPos(-12, -5);
        self.m_unread_num = new(Text,"",26, 26, kAlignCenter,nil,15,255, 255, 255);
        self.m_unread_img:addChild(self.m_unread_num);
        self.m_unread_num:setPos(nil, -2);
        self.m_friend_icon_frame:addChild(self.m_unread_img); 
        self:loadUnReadMsg(self.data);

        --段位
        self.m_score_level = new(Image,"userinfo/1.png");
        self.m_score_level:setLevel(1);
        self.m_score_level:setAlign(kAlignBottomRight);
        self.m_score_level:setPos(-8,-5);
        self.m_friend_icon_frame:addChild(self.m_score_level);


	    self.m_bg:addChild(self.m_friend_icon_frame);

	    self.m_friend_name = new(Text,"博雅象棋", 0, 0, nil,nil,30,70, 25, 0);
	    self.m_friend_name:setPos(friendName_x,friendName_y);
	    self.m_bg:addChild(self.m_friend_name);

        self.m_last_msg = new(Text, "加载中...", 0, 0, nil,nil,20,160, 100, 50);
	    self.m_last_msg:setPos(last_msg_x,last_msg_y);
	    self.m_bg:addChild(self.m_last_msg);

        self.m_time = new(Text, "加载中...", 0, 0, nil,nil,20,160, 100, 50);
	    self.m_time:setPos(time_x,time_y);
	    self.m_bg:addChild(self.m_time);        
    end;
end


FriendMsgItem.setFriendIcon = function(self, data)
    if not data then
        Log.i("FriendMsgItem.setFriendIcon--->>".."data is nil");
    else
        Log.i("FriendMsgItem.setFriendIcon--->>"..json.encode(data));
    end;
   if not data then
        self.m_file_icon = new(Image,FriendMsgScene.default_icon);
   else
        if data.iconType > 0 then
            self.m_file_icon = new(Image,UserInfo.DEFAULT_ICON[data.iconType] or UserInfo.DEFAULT_ICON[1]);
        elseif data.iconType == 0 then
            self.m_file_icon = new(Image,FriendMsgScene.default_icon);
        elseif data.iconType == -1 then
            self.m_file_icon = new(Image,"userinfo/userHead.png");
            self.m_file_icon:setUrlImage(data.icon_url);
--            local imageName = UserInfo.getCacheImageManager(data.icon_url,data.mid);
--            if imageName then
--                self.m_file_icon:setFile(imageName);
--            end          
        end;
    end;
	self.m_friend_icon_frame:setPos(20,15);
    self.m_file_icon:setSize(66, 66);
    self.m_file_icon:setAlign(kAlignCenter);
    self.m_friend_icon_frame:addChild(self.m_file_icon);
end;


FriendMsgItem.loadUnReadMsg = function(self, data)
    if data.unReadNum ~= 0 then
        if not self.m_unread_img:getVisible() then
            self.m_unread_img:setVisible(true);
        end;
        if data.unReadNum > 9 then
            self.m_unread_img:setSize(40,26);
            self.m_unread_num:setSize(40,26);
            self.m_unread_num:setAlign(kAlignCenter);
            if data.unReadNum > 99 then
                self.m_unread_num:setText("99+");
            else
                self.m_unread_num:setText(data.unReadNum);
            end;
        else
            self.m_unread_img:setSize(26,26);
            self.m_unread_num:setSize(26,26);
            self.m_unread_num:setAlign(kAlignCenter);
            self.m_unread_num:setText(data.unReadNum);
        end;
    else
        self.m_unread_img:setVisible(false);
    end;
end;


FriendMsgItem.onRefreshList = function(self)
    self.m_room.m_msg_list:removeItem(self.m_index, true,200);
end;



FriendMsgItem.getTime = function(self, time)
    if ToolKit.isSecondDay(time) then
        return os.date("%m-%d ",time);-- 08-07格式
    else
        return os.date("%H:%M",time);--%Y/%m/%d %X
    end;
end


FriendMsgItem.getSize = function(self)
    local w, h = self.m_bg:getSize();
    return 480, 112;
end

FriendMsgItem.getData = function(self)
	return self.data;
end

FriendMsgItem.setCheckVisible = function(self,isVisible)
	self.m_checkBox:setVisible(isVisible);
	if isVisible == true then
		self.container:setPos(40,0);
	else
		self.container:setPos(0,0);
	end
end

FriendMsgItem.setBgVisible = function(self,isVisible)
	self.m_focus_bg:setVisible(isVisible);
end

FriendMsgItem.updateUserData = function(self, data)
    Log.i("FriendMsgItem.updateUserData--->>"..json.encode(data));
    self.m_friend_info = data;
    self:setFriendIcon(data);
    local msgList = FriendsData.getInstance():getChatList();
    for k,v in ipairs(msgList) do
        if v.uid == self.m_uid then
            self:updateUserMsg(v);
        end;
    end;
    self.m_friend_name:setText(data.mnick);
    self.m_score_level:setFile("userinfo/"..UserInfo.getInstance():getDanGradingLevelByScore(tonumber(data.score))..".png");
end;

FriendMsgItem.updateUserMsg = function(self, data)
    self.m_last_msg:setText(data.last_msg or "");
    self.m_time:setText(self:getTime(data.time));
    self:loadUnReadMsg(data);
end;

FriendMsgItem.updateUserIcon = function(self, icon)
    Log.i("FriendMsgItem.updateUserIcon--->>"..icon);
    self.m_file_icon:setFile(icon or FriendMsgScene.default_icon);
end;


FriendMsgItem.setCheckState = function(self)
	if self.m_checkBox:isChecked() == true then
		self.m_checkBox:setChecked(false);
	else
		self.m_checkBox:setChecked(true);
	end
end

FriendMsgItem.getCheckState = function(self)
	return self.m_checkBox:isChecked();
end

FriendMsgItem.dtor = function(self)
	
end

FriendMsgItem.onAnimLeftCompleted = function(self)
    self.m_bg:removeProp(1);
    self.m_bg:setPos(-100, 0);

end;


FriendMsgItem.onAnimRightCompleted = function(self)
    self.m_bg:removeProp(2);
    self.m_bg:setPos(0, 0);
    
end;

FriendMsgItem.resumeOrginPos = function(self)
    if self.m_move_offset then
        if self.m_move_offset == 0 then
            return false;
        elseif self.m_move_offset == 100 then
            self.m_anim_right = self.m_bg:addPropTranslate(2,kAnimNormal,200,-1,0, (self.m_move_offset ),nil,nil);
            self.m_anim_right:setEvent(self, self.onAnimRightCompleted); 
            self.m_move_offset = 0;
            return true;             
        end;
    end;
end;

FriendMsgItem.resetUnreadMsgNum = function(self)
    FriendsData.getInstance():updateUnreadChatByUid(self.m_uid);
end;

FriendMsgItem.setUnreadAndMsg = function(self)
    local node = self.m_bg:getChildren()[1]:getChildren()[2];
    node:setVisible(false);
end

FriendMsgItem.setLastMsg = function(self,data)
     local node = self.m_bg:getChildren()[3];
     node:setText(data.last_msg);
     node = self.m_bg:getChildren()[4];
     node:setText(self:getTime(data.time));
end

FriendMsgItem.onEventTouch = function(self, finger_action, x, y, drawing_id_first, drawing_id_current)
    if self.m_room.m_msg_list:isBouncing() then
        return;
    end;
    if finger_action == kFingerDown then
        self.m_dragingX = x;
        self.m_dragingY = y;
        self.m_orginX, self.m_orginY = self.m_bg:getPos();
        self:setColor(128,128,128);
        self.m_room.m_msg_list:setFingerActionEnabled(false,false)
        
        if self.m_room.m_msg_list then
            for i = 1, self.m_room.m_msg_list:getItemCount() do
                local msgItem = self.m_room.m_msg_list:getItem(i):getChildren()[1].getMsgItem();
                -- 使得已经滑动的item回到初始位置 
                if msgItem:resumeOrginPos() then
                    -- 代表这一次点击，使得其中某一个item恢复到原位置了
                    -- FriendMsgScene.s_playing_anim为true，就不再响应这一次kFingerCancel or kFingerUp事件
                    FriendMsgScene.s_playing_anim = true;
                end;
            end;
        end;   
    elseif (finger_action == kFingerCancel) or (finger_action == kFingerUp) then 
        self.m_direction = 0;
        self:setColor(255,255,255);
        self.m_room.m_msg_list:setFingerActionEnabled(true,false)

        if not FriendMsgScene.s_playing_anim then
            Log.i("finger_action == kFingerCancel--->"..x.."   m_dragingX"..self.m_dragingX);
            if math.abs(x - self.m_dragingX) < 5 then
                if self.m_friend_info then
                    self.m_room:entryChatRoom(self.m_friend_info,self.m_itemType);
                    self:resetUnreadMsgNum();
                elseif self.m_itemType == 1 then
                    -- 进入公共聊天室
--                    if UserInfo.getInstance():getScore() ~= tonumber(self.m_roomData.min_score:get_value()) then  -- >=
--                    -- 进入聊天室是否成功
--                        self.m_room:requestCtrlCmd(FriendMsgController.s_cmds.toEntryChatRoom,self.m_roomData);
--                    else
--                        local str = "积分不足，无法进入";
--                        ChessToastManager.getInstance():show(str,500);
--                    end;
                    local name = GameCacheData.getInstance():getString(GameCacheData.LOCATE_CITY_NAME,nil);
                    if not name and self.m_roomData.id == 1001 then
                        if not self.m_locate_city_dialog then
                            self.m_locate_city_dialog = new(CityLocatePopDialog);
                        end
                        self.m_locate_city_dialog:show(self);
                    else
                        self.m_room:requestCtrlCmd(FriendMsgController.s_cmds.toEntryChatRoom,self.m_roomData);
                    end
                end
                return;
            end;
            if self.m_isHorizontal then
                -- 向左的动画
                if x - self.m_dragingX < 0 then
                    -- 滑动小于40以内，返回初始位置
                    if math.abs(x - self.m_dragingX) < 40 or self.m_itemType == 1 then
                        self.m_anim_right = self.m_bg:addPropTranslate(2,kAnimNormal,200,-1,0, (self.m_move_offset),nil,nil);
                        if self.m_anim_right then
                            self.m_anim_right:setEvent(self, self.onAnimRightCompleted);
                        end;  
                        self.m_move_offset = 0;   
                    -- 滑动大于40以外，左滑动画开始
                    else
                        self.m_anim_left = self.m_bg:addPropTranslate(1,kAnimNormal,200,-1,0, (self.m_move_offset or 100) -100,nil,nil);
                        self.m_anim_left:setEvent(self, self.onAnimLeftCompleted);
                        self.m_move_offset = 100;                  
                    end;
                -- 向右的动画
                elseif x - self.m_dragingX > 0 then
                    -- 当前位置已经滑到了最左边-100，右滑到初始位置
                    if self.m_orginX == -100 then
                        self.m_anim_right = self.m_bg:addPropTranslate(2,kAnimNormal,200,-1,0, (self.m_move_offset ),nil,nil);
                        if self.m_anim_right then
                            self.m_anim_right:setEvent(self, self.onAnimRightCompleted);
                        end;
                    -- 当前位置滑到最右边（滑出了初始位置），左滑到初始位置
                    else
                        self.m_anim_right = self.m_bg:addPropTranslate(2,kAnimNormal,200,-1,0, - (self.m_move_offset),nil,nil);
                        if self.m_anim_right then
                            self.m_anim_right:setEvent(self, self.onAnimRightCompleted);
                        end;
                    end;
                    self.m_move_offset = 0;
                else
            
                end;
            end;
        else
            FriendMsgScene.s_playing_anim = false;
        end;
    else
        self:setColor(255,255,255);
        if self.m_direction == 0 then 
            if math.abs(x - self.m_dragingX) > 0 and (math.abs(y - self.m_dragingY) < math.abs(x - self.m_dragingX)) then --左
                self.m_direction = 1; 
                self.m_isHorizontal = true;
            elseif math.abs(y - self.m_dragingY) > 0 and (math.abs(y - self.m_dragingY) > math.abs(x - self.m_dragingX)) then --下 
                self.m_direction = 2; 
                self.m_isHorizontal = false;
                self.m_room.m_msg_list:setFingerActionEnabled(true, true)
            else
                
            end 
        elseif (self.m_direction == 1) then
            if not FriendMsgScene.s_playing_anim then
                local friendItemOffsetLeft = 100;
                local friendItemOffsetRight = 30;
                if self.m_itemType == 1 then
                    friendItemOffsetLeft = friendItemOffsetRight;
                end
                if x - self.m_dragingX < 0  and math.abs(x - self.m_dragingX) < friendItemOffsetLeft then
                    self.m_bg:setPos(self.m_orginX + x - self.m_dragingX, self.m_orginY);
                    self.m_move_offset  = math.abs(x - self.m_dragingX + self.m_orginX)
                elseif x - self.m_dragingX > 0 and math.abs(x - self.m_dragingX) < friendItemOffsetRight then
                    self.m_bg:setPos(self.m_orginX + x - self.m_dragingX, self.m_orginY);
                    self.m_move_offset  = math.abs(x - self.m_dragingX + self.m_orginX)
                end;           
            end;               
        elseif (self.m_direction == 2) then
            
        end 
    end
end

-------------------chatMsgNode-----------------------
ChatRoomItem = class(FriendMsgItem);

ChatRoomItem.ctor = function(self,data,room,id,itemType,lastMsg)
    super(self,data,room,index,itemType,lastMsg);
end

ChatRoomItem.dtor = function(self)

end

ChatRoomItem.setChatRoomIcon = function(self,roomId)
    self.m_chat_room_icon = new(Image, "drawable/error_icon.png");
--    local imageName = UserInfo.getCacheImageManager(self.m_roomData.img_url:get_value(),roomId);
--    if imageName then
--        self.m_chat_room_icon:setFile(imageName);
--    end
    self.m_chat_icon_frame:setPos(20,15);
    self.m_chat_room_icon:setSize(66, 66);
    self.m_chat_room_icon:setAlign(kAlignCenter);
    self.m_chat_icon_frame:addChild(self.m_chat_room_icon);
end

--ChatRoomMsgItem.updateUserMsg = function(self, data)
--    self.m_last_msg:setText(data.last_msg or "");
--    self.m_time:setText(self:getTime(data.time));
--    self:loadUnReadMsg(data);
--end