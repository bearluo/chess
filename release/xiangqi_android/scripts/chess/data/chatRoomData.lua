--region NewFile_1.lua
--Author : FordFan
--Date   : 2015/8/31
--endregion
require("util/game_cache_data");

ChatRoomData = class(GameCacheData,false);

ChatRoomData.ctor = function(self)
    self.m_dict = new(Dict,"chat_rom_list");
    self.m_dict:load();
end

ChatRoomData.init = function(self)
--    self:getRoomData();
end

ChatRoomData.refresh = function(self)
    
end

ChatRoomData.getInstance = function()
    if not ChatRoomData.instance then
		ChatRoomData.instance = new(ChatRoomData);
	end
	return ChatRoomData.instance; 
end

ChatRoomData.dtor = function(self)
end

ChatRoomData.clear = function(self)
    delete(ChatRoomData.instance);
    ChatRoomData.instance = nil;
end

-- 读取房间最后消息
ChatRoomData.getLastRoomMsg = function(self)
    local tabStr = {};
    local tabjson = self:getString(GameCacheData.ROOM_LAST_MSG_DATA .. "data","");
    tabStr = json.decode(tabjson);
    return tabStr;
end
-- 保存房间最后消息
ChatRoomData.saveRoomData = function(self,roomId,time)

    local jsonMsg = self:getString(GameCacheData.ROOM_LAST_MSG_DATA .. "data", "");
    local jsonHistoryMsg = self:getString(GameCacheData.HISTORY_MSG .. roomId,"");
    local lastMsgTab = json.decode(jsonMsg);
    local historyMsgTab = json.decode(jsonHistoryMsg);
    local lastMsg = {};

    if historyMsgTab then
        lastMsg.roomid = roomId;
        lastMsg.name = historyMsgTab[#historyMsgTab].name;
        lastMsg.last_msg = historyMsgTab[#historyMsgTab].msg;
        lastMsg.last_msg_id = historyMsgTab[#historyMsgTab].msg_id;
        lastMsg.time = historyMsgTab[#historyMsgTab].time;
    else
        lastMsg.roomid = roomId;
        lastMsg.name = nil;
        lastMsg.last_msg = "";
        lastMsg.last_msg_id = 0;
        lastMsg.time = time;
        --GameCacheData.getInstance():saveInt(GameCacheData.QUIT_ROOM_TIME,os.time());
    end;

    if not lastMsgTab then 
        lastMsgTab = {};
        table.insert(lastMsgTab,lastMsg);
    else
        for i = 1,#lastMsgTab do
            if lastMsgTab[i].roomid == roomId then
                lastMsgTab[i] = lastMsg;
                self:saveString(GameCacheData.ROOM_LAST_MSG_DATA .. "data",json.encode(lastMsgTab));
                return;
            end
        end
        table.insert(lastMsgTab,lastMsg); 
    end
    self:saveString(GameCacheData.ROOM_LAST_MSG_DATA .. "data",json.encode(lastMsgTab));
end
--其他玩家信息
ChatRoomData.getChatUserInfo = function(self)
    local infoTab = {};
    local tab = self:getString(GameCacheData.CHAT_USER_INFO .. "user_info" ,"");
    infoTab = json.decode(tab);
    return infoTab;
end

--保存玩家信息
ChatRoomData.saveChatOtherUserInfo = function(self,userInfo)
    local  tab = {};
    local infoJson = self:getString(GameCacheData.CHAT_USER_INFO .. "user_info","");
    local infoTab = json.decode(infoJson);
    if infoTab then
         tab = infoTab;
    end
    for i,v in pairs(userInfo) do 
        table.insert(tab,v);
    end
    self:saveString(GameCacheData.CHAT_USER_INFO .. "user_info",json.encode(tab));
end

-- 保存聊天室正在聊的消息 接收到和自己发的消息
ChatRoomData.saveRecvMsg = function(self,msgData,room_id)
    local msgStr = self:getString(GameCacheData.HISTORY_MSG .. room_id,"");
    local msgHistoryTab = {};
    local tab = json.decode(msgStr);
    if tab then
        if #tab < 300 then
            table.insert(tab,msgData);
        else
            table.remove(tab,1);
            table.insert(tab,msgData);
        end
        msgHistoryTab = tab;
    else
        table.insert(msgHistoryTab,msgData);
    end
   self:saveString(GameCacheData.HISTORY_MSG .. room_id,json.encode(msgHistoryTab));
end

--获得历史消息
ChatRoomData.getHistoryMsg = function(self,room_id)
    local jsonStr = self:getString(GameCacheData.HISTORY_MSG .. room_id,"");
    local tab = json.decode(jsonStr);
    local showMsg = {};
    if tab and #tab > 50 then
        for i = #tab, #tab -50+1,-1 do
            table.insert(showMsg,1,tab[i]);
        end;
        return showMsg;
    else 
        return tab;
    end;
end
-- 保存拉取到的历史消息（暂时300条）
ChatRoomData.saveHistoryMsg = function(self,msgUnread,room_id)
    local msgStr = self:getString(GameCacheData.HISTORY_MSG .. room_id,"");
    local msgHistoryTab = {};
    local tab = json.decode(msgStr);
    if tab then
        for i,v in pairs(msgUnread) do
            if #tab < 300 then
                table.insert(tab,v);
            else
                table.remove(tab,1);
                table.insert(tab,v);
            end
        end
        msgHistoryTab = tab;
    else
        for i,v in pairs(msgUnread) do
            table.insert(msgHistoryTab,v);
        end
    end
    self:saveString(GameCacheData.HISTORY_MSG .. room_id,json.encode(msgHistoryTab));
end
