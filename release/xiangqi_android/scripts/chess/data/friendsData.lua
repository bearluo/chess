--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require("util/game_cache_data")
FriendsData = class(GameCacheData,false);

FriendsData.Cache_Time = 600;
FriendsData.Status_Cache_Time = 10;
FriendsData.ctor = function(self)
    self.m_dict = new(Dict,"friends_data");
	self.m_dict:load();
    self.m_cache_friends_page_tab = {};
    self.m_cache_follow_page_tab = {};
    self.m_cache_fans_page_tab = {};
    self.m_cache_user_status = {};
    self.m_cache_user_data = {};
    self.m_rcache_chat_list = {};
    
    self.m_cache_chat_list = json.decode(self:getString(GameCacheData.FRIEND_CHAT_LIST..UserInfo.getInstance():getUid(),nil));
    self.m_cache_chat_list = self.m_cache_chat_list or {};
    for i,v in pairs(self.m_cache_chat_list) do
        self.m_rcache_chat_list[v.uid] = i;
    end

    self.m_send_cmd_user_status = {};
    self.m_send_cmd_user_data = {};

    self.m_anim = AnimFactory.createAnimInt(kAnimLoop,0,1,1000);
    self.m_anim:setEvent(self,self.animEvent);
    self.m_anim:setDebugName("FriendsData.anim");
end

FriendsData.init = function(self)
    self:getFrendsListData();
    self:getFollowListData();
    self:getFansListData();
end

FriendsData.refresh = function(self)
     self:sendGetFriendsListCmd();
     self:sendGetFollowListCmd();
     self:sendGetFansListCmd();
end

FriendsData.animEvent = function(self)
    if self.m_send_cmd_user_status then
        local send = {};
        for i,v in pairs(self.m_send_cmd_user_status) do
            Log.i (i)
            table.insert(send,i);
            if #send > 100 then
                Log.i("sendCheckUserStatus 分包");
                OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_CHECK_USER_STATUS,send);
                send = {};
            end
        end
        
        if #send > 0 then
            Log.i("sendCheckUserStatus");
            OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_CHECK_USER_STATUS,send);
        end
        self.m_send_cmd_user_status = {};
    end

    if self.m_send_cmd_user_data then
        local send = {};
        for i,v in pairs(self.m_send_cmd_user_data) do
            Log.i (i)
            table.insert(send,i);
        end
        if #send > 0 then
            Log.i("sendCheckUserData");
            local info = {};
            info.mid_arr = {};
            for i,v in pairs(send) do
                info.mid_arr["mid"..i] = v;
            end
            HttpModule.getInstance():execute(HttpModule.s_cmds.getFriendUserInfo,info);
        end
        self.m_send_cmd_user_data = {};
    end

    if not self.upOnlineNumTime or os.time() - self.upOnlineNumTime > 30 then
        self.upOnlineNumTime = os.time();
        if OnlineSocketManager.getHallInstance():isSocketOpen() then
            OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_ONLINE_NUM);
	    end
    end
end

FriendsData.clear = function(self)
    delete(FriendsData.instance);
    FriendsData.instance = nil;
end

FriendsData.dtor = function(self)
    delete(self.m_anim)
end

FriendsData.getInstance = function()
    if not FriendsData.instance then
        FriendsData.instance = new(FriendsData);
    end
    return FriendsData.instance;
end

FriendsData.onFriendCmdOnlineNum = function(self,num)
    if not self.m_friend_online_num or self.m_friend_online_num ~= num then
        self.m_onlineNumChange = true;
    end
    self.m_friend_online_num = num;
    EventDispatcher.getInstance():dispatch(Event.Call,kFriend_UpdateFriendOnlineNum,self.m_friend_online_num);
end

FriendsData.getFriendOnlineNum = function(self)
    return self.m_friend_online_num or 0;
end

FriendsData.sendCheckUserData = function(self,data)
    if not data then return end;
    local tab = {}
    if type(data) ~= "table" then
        table.insert(tab,data);
    else
        tab = data;
    end

    for i,v in ipairs(tab) do
        self.m_send_cmd_user_data[v] = 1;
    end
--    Log.i("sendCheckUserData")
--    table.foreach(tab, function(i, v) Log.i (v) end) ;
--    local info = {};
--    info.mid_arr = {};
--    for i,v in pairs(tab) do
--        info.mid_arr["mid"..i] = v;
--    end
--    HttpModule.getInstance():execute(HttpModule.s_cmds.getFriendUserInfo,info);
    --OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_CHECK_USER_DATA,tab);
end

--FriendsData.onCheckUserData = function(self,data)
--    if not data or not data.items then return end
--    local ret = {};
--    for i,value in ipairs(data.items) do
--       if value.uid and value.userInfo then
--          self.m_cache_user_data[tonumber(value.uid)] = json.decode(value.userInfo);
--          if type(self.m_cache_user_data[tonumber(value.uid)]) == "table" then
--              self.m_cache_user_data[tonumber(value.uid)].saveTime = os.time();
--              table.insert(ret,self.m_cache_user_data[tonumber(value.uid)]);
--              self:saveString(GameCacheData.FRIEND_USER_DATA .. value.uid,json.encode(self.m_cache_user_data[tonumber(value.uid)]));
--          else
--              self.m_cache_user_data[tonumber(value.uid)] = nil;
--          end
--       end
--    end
--    EventDispatcher.getInstance():dispatch(Event.Call,kFriend_UpdateUserData,ret);
--end

FriendsData.onCheckUserData = function(self,data)
    if not data then return end
    local ret = {};
    for i,value in ipairs(data) do
       if value then
          self.m_cache_user_data[value.mid] = value;
          if type(self.m_cache_user_data[value.mid]) == "table" then
              self.m_cache_user_data[value.mid].saveTime = os.time();
              table.insert(ret,self.m_cache_user_data[value.mid]);
              self:saveString(GameCacheData.FRIEND_USER_DATA .. value.mid,json.encode(self.m_cache_user_data[value.mid]));
          else
              self.m_cache_user_data[value.mid] = nil;
          end
       end
    end
    EventDispatcher.getInstance():dispatch(Event.Call,kFriend_UpdateUserData,ret);
end


FriendsData.sendCheckUserStatus = function(self,data)
    if not data then return end
    local tab = {}
    if type(data) ~= "table" then
        table.insert(tab,data);
    else
        tab = data;
    end

    for i,v in ipairs(tab) do
        self.m_send_cmd_user_status[v] = 1;
    end
end

FriendsData.onCheckUserStatus = function(self,data)
    if not data or not data.items then return end
    local needUpdateList = false;
    Log.i("onCheckUserStatus")
    table.foreach(data.items, function(i, v) Log.i (v) end) ;
    for i,value in ipairs(data.items) do
        if tonumber(value.uid) then
            if not self.m_cache_user_status[tonumber(value.uid)] 
                or self.checkUserStatusDifferent(self.m_cache_user_status[tonumber(value.uid)],value) then
                needUpdateList = true;
            end
            self.m_cache_user_status[tonumber(value.uid)] = value;
            if type(self.m_cache_user_status[tonumber(value.uid)]) == "table" then
                self.m_cache_user_status[tonumber(value.uid)].saveTime = os.time();
            else
                self.m_cache_user_status[tonumber(value.uid)] = nil;
            end
        end
    end
    if needUpdateList then
        EventDispatcher.getInstance():dispatch(Event.Call,kFriend_UpdateFriendsList,self:getFrendsListData());
    else
        EventDispatcher.getInstance():dispatch(Event.Call,kFriend_UpdateStatus,data.items);
    end
end

FriendsData.checkUserStatusDifferent = function(user1,user2)
    if type(user1) ~= "table" or type(user2) ~= "table" then 
        Log.e("checkUserStatusDifferent user1 or user2 is not table");
        return false ;
    end
    local status1 = 0; 
    if user1.hallid and user1.hallid > 0 then
        status1 = 1;
    end
--    if user1.tid and user1.tid > 0 then
--        status1 = 2;
--    end

    local status2 = 0;
    if user2.hallid and user2.hallid > 0 then
        status2 = 1;
    end
--    if user2.tid and user2.tid > 0 then
--        status2 = 2;
--    end

    if status1 == status2 then
--        if status1 == 0 then    --都离线
--            if user1.last_time ~= user2.last_time then -- 最后登录时间不一样
--                return true;
--            end
--        elseif status1 == 1 then --在线都在大厅
--            return false;
--        elseif status1 == 2 then --在房间
--            if user1.level ~= user2.level then -- 房间类型不同
--                return true;
--            end
--        end
        return false;
    else
        return true;
    end
    return false;
end


FriendsData.getUserStatus = function(self,data,isCheck)
    if not data then return end
    if isCheck == nil then isCheck = true end
    local tab = {}
    if type(data) ~= "table" then
        table.insert(tab,data);
    else
        tab = data;
    end
    local ret = {};
    local needCheck = {};
    for i,value in ipairs(tab) do
        local status = self.m_cache_user_status[tonumber(value)];
        if status then
            table.insert(ret,status);
            self.m_cache_user_status[tonumber(value)] = status;
            local diff = os.time() - status.saveTime;
            if diff < 0 or diff > FriendsData.Status_Cache_Time then
                table.insert(needCheck,value);
            end
        else
            table.insert(needCheck,value);
        end
    end
    if self.m_onlineNumChange then
        self.m_onlineNumChange = false;
        self:sendCheckUserStatus(self:getFrendsListData());
    end
    if isCheck and #needCheck > 0 then
        self:sendCheckUserStatus(needCheck);
    end
    if type(data) ~= "table" then
        return ret[1];
    end
    return ret;
end

FriendsData.getUserData = function(self,data)
    if not data then return end
    local tab = {}
    if type(data) ~= "table" then
        table.insert(tab,data);
    else
        tab = data;
    end
    local ret = {};
    local needCheck = {};
    for i,value in ipairs(tab) do
        local status = self.m_cache_user_data[tonumber(value)] or json.decode(self:getString(GameCacheData.FRIEND_USER_DATA..(tonumber(value)),nil));
        if status then
            if tonumber(value) == tonumber(UserInfo.getInstance():getUid()) then
                status.iconType = UserInfo.getInstance():getIconType();
                status.icon_url = UserInfo.getInstance():getIcon();
                status.mnick = UserInfo.getInstance():getName();
            end
            table.insert(ret,status);
            self.m_cache_user_data[tonumber(value)] = status;
            local diff = os.time() - status.saveTime;
            if diff < 0 or diff > FriendsData.Cache_Time then
                table.insert(needCheck,value);
            end
        else
            table.insert(needCheck,value);
        end
    end
    if #needCheck > 0 then
        self:sendCheckUserData(needCheck);
    end
    if type(data) ~= "table" then
        return ret[1];
    end
    return ret;
end

FriendsData.setFriendsNum = function(self,num)
    self.m_friendsNum = tonumber(num) or 0;
end

FriendsData.getFriendsNum = function(self)
    return self.m_friendsNum or 0;
end

FriendsData.sendGetFriendsListCmd = function(self)
    if not self.m_sendGetFriendsListCmdTime or os.time() - self.m_sendGetFriendsListCmdTime > 1 then
        self.m_sendGetFriendsListCmdTime = os.time();
        OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_GET_FRIENDS_LIST);
    end
end

FriendsData.sendGetFriendsNumCmd = function(self)
    if not self.m_sendGetFriendsNumCmdTime or os.time() - self.m_sendGetFriendsNumCmdTime > 1 then
        self.m_sendGetFriendsNumCmdTime = os.time();
        OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_GET_FRIENDS_NUM);
    end
end

FriendsData.onGetFriendsNum = function(self,num)
    num = tonumber(num);
    if not num then return end;
    Log.i("onGetFriendsNum"..num);
    if num ~= self:getFriendsNum() or not self.m_sendGetFriendsListTime or os.time() - self.m_sendGetFriendsListTime > FriendsData.Cache_Time then
--        self:setFriendsNum(num)
        self.m_sendGetFriendsListTime = os.time();
        self:sendGetFriendsListCmd();
    end
end

FriendsData.onGetFriendsList = function(self,info)
    if not info then return end
    --Cache
    local num = info.item_num;
    if not num then return end
    Log.i("onGetFriendsList:"..info.curr_page);
    if info.curr_page == 0 then
        self.m_cache_friends_page_tab = {};
    end
    for i=1,num do
        if info.friend_uid[i] then
            table.insert(self.m_cache_friends_page_tab,info.friend_uid[i]);
        end
    end
    if info.curr_page+1 >= info.page_num then
        self:setFriendsNum(#self.m_cache_friends_page_tab);
        self:saveFriendsListData(self.m_cache_friends_page_tab);
    end
end

FriendsData.saveFriendsListData = function(self,data)
    local ret = {};
    local change = {};
    if self.m_friends_page_tab then
        for i,v in pairs(data) do
            if self.m_friends_page_tab[tonumber(v)] then
                ret[v..""] = 0;
                change[tonumber(v)] = self.m_friends_page_tab[tonumber(v)];
            else
                ret[v..""] = 0;
                change[tonumber(v)] = 1;
            end
        end
    else
        for i,v in pairs(data) do
            ret[v..""] = 0;
            change[tonumber(v)] = 0;
        end
    end
    self.m_friends_page_tab = change;
    local saveTab = {};
    saveTab.data = ret;
    saveTab.saveTime = os.time();
    self:saveString(GameCacheData.FRIEND_FRIENDS_PAGE_TAB..UserInfo.getInstance():getUid(),json.encode(saveTab))
    local ret = {};
    for i,v in pairs(self.m_friends_page_tab) do
        table.insert(ret,tonumber(i));
        if v == 1 then
            BottomMenu.getInstance():setOwnBtnTipVisible();
        end
    end
    table.sort(ret,FriendsData.sort_cmp);
    EventDispatcher.getInstance():dispatch(Event.Call,kFriend_UpdateFriendsList,ret);
end

FriendsData.sort_cmp = function(uid_b,uid_a)
    local status_a = FriendsData.getInstance():getUserStatus(uid_a);
    local status_b = FriendsData.getInstance():getUserStatus(uid_b);
    if not status_a and not status_b then
        return false;
    else
        if not status_a then
            return true;
        else
            if status_b then
                if status_a.hallid > 0 then
                    return false;
                end
                return status_b.hallid > 0;
            else
                return false;
            end
        end
    end
    return false;
end

FriendsData.getFrendsListData = function(self)
    local isGetNum = true;
    if not self.m_friends_page_tab then
        local jsonStr = self:getString(GameCacheData.FRIEND_FRIENDS_PAGE_TAB..UserInfo.getInstance():getUid(),nil);
        if not jsonStr then 
            isGetNum = false;
            self:sendGetFriendsListCmd();
            return nil;
        end
        local tab = json.decode(jsonStr);
	    self.m_friends_page_tab = {}
        for i,v in pairs(tab.data) do
            self.m_friends_page_tab[tonumber(i)] = v;
        end
        local diff = os.time() - tab.saveTime;
        if diff < 0 or diff > FriendsData.Cache_Time then
            isGetNum = false;
            self:sendGetFriendsListCmd();
        end
    end
    if isGetNum then
        self:sendGetFriendsNumCmd();
    end
    local ret = {};
    for i,v in pairs(self.m_friends_page_tab) do
        table.insert(ret,tonumber(i));
    end
    table.sort(ret,FriendsData.sort_cmp);
    return ret;
end


FriendsData.isYourFriend = function(self,uid)
    return (self.m_friends_page_tab and self.m_friends_page_tab[uid]) or -1;
end

FriendsData.isYourFollow = function(self,uid)
    return (self.m_follow_page_tab and self.m_follow_page_tab[uid]) or -1;
end

FriendsData.isYourFans = function(self,uid)
    return (self.m_fans_page_tab and self.m_fans_page_tab[uid]) or -1;
end

FriendsData.updateFriendsListData = function(self,info)
    if not info then return end
    local uid = tonumber(info.target_uid);
    if not uid then return end;
    
-- relation, =0,陌生人,=1粉丝，=2关注，=3好友
    if self:isYourFriend(uid) ~= -1 and info.relation ~= 3 then
        if self.m_friends_page_tab and self.m_friends_page_tab[uid] then
            local ret = {};
            for i,v in pairs(self.m_friends_page_tab) do
                if tonumber(i) ~= uid then
                    table.insert(ret,tonumber(i));
                end
            end
            self:saveFriendsListData(ret);
        end
    end

    if self:isYourFollow(uid) ~= -1 and info.relation ~= 2 then
        if self.m_follow_page_tab and self.m_follow_page_tab[uid] then
            local ret = {};
            for i,v in pairs(self.m_follow_page_tab) do
                if tonumber(i) ~= uid then
                    table.insert(ret,tonumber(i));
                end
            end
            self:saveFollowListData(ret);
        end
    end

    if self:isYourFans(uid) ~= -1 and info.relation ~= 1 then
        if self.m_fans_page_tab and self.m_fans_page_tab[uid] then
            local ret = {};
            for i,v in pairs(self.m_fans_page_tab) do
                if tonumber(i) ~= uid then
                    table.insert(ret,tonumber(i));
                end
            end
            self:saveFansListData(ret);
        end
    end

    if self:isYourFriend(uid) == -1 and info.relation == 3 then
        if self.m_friends_page_tab then
            local ret = {};
            table.insert(ret,tonumber(uid));
            for i,v in pairs(self.m_friends_page_tab) do
                table.insert(ret,tonumber(i));
            end
            self:saveFriendsListData(ret);
        end
    end

    if self:isYourFollow(uid) == -1 and info.relation == 2 then
        if self.m_follow_page_tab then
            local ret = {};
            table.insert(ret,tonumber(uid));
            for i,v in pairs(self.m_follow_page_tab) do
                table.insert(ret,tonumber(i));
            end
            self:saveFollowListData(ret);
        end
    end

    if self:isYourFans(uid) == -1 and info.relation == 1 then
        if self.m_fans_page_tab then
            local ret = {};
            table.insert(ret,tonumber(uid));
            for i,v in pairs(self.m_fans_page_tab) do
                table.insert(ret,tonumber(i));
            end
            self:saveFansListData(ret);
        end
    end

    EventDispatcher.getInstance():dispatch(Event.Call,kFriend_FollowCallBack,info);
end

FriendsData.sendGetFollowListCmd = function(self)
    if not self.m_sendGetFollolListCmdTime or os.time() - self.m_sendGetFollolListCmdTime > 1 then
        self.m_sendGetFollolListCmdTime = os.time();
        OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_GET_FOLLOW_LIST);
    end
end

FriendsData.sendGetFansListCmd = function(self)
    if not self.m_sendGetFansListCmdTime or os.time() - self.m_sendGetFansListCmdTime > 1 then
        self.m_sendGetFansListCmdTime = os.time();
        OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_GET_FANS_LIST);
    end
end

FriendsData.sendGetFollowNumCmd = function(self)
    if not self.m_sendGetFollowNumCmdTime or os.time() - self.m_sendGetFollowNumCmdTime > 1 then
        self.m_sendGetFollowNumCmdTime = os.time();
        OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_GET_FOLLOW_NUM);
    end
end

FriendsData.sendGetFansNumCmd = function(self)
    if not self.m_sendGetFansNumCmdTime or os.time() - self.m_sendGetFansNumCmdTime > 1 then
        self.m_sendGetFansNumCmdTime = os.time();
        OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_GET_FANS_NUM);
    end
end

FriendsData.setFollowNum = function(self,num)
    self.m_followNum = tonumber(num) or 0;
end

FriendsData.getFollowNum = function(self)
    return self.m_followNum or 0;
end

FriendsData.setFansNum = function(self,num)
    self.m_fansNum = tonumber(num) or 0;
end

FriendsData.getFansNum = function(self)
    return self.m_fansNum or 0;
end

FriendsData.onGetFollowNum = function(self,num)
    num = tonumber(num);
    if not num then return end;
    Log.i("onGetFollowNum"..num);
    if num ~= self:getFollowNum() then
--        self:setFollowNum(num)
        self:sendGetFollowListCmd();
    end
end

FriendsData.onGetFansNum = function(self,num)
    num = tonumber(num);
    if not num then return end;
    Log.i("onGetFansNum"..num);
    if num ~= self:getFansNum() then
--        self:setFansNum(num)
        self:sendGetFansListCmd();
    end
end

FriendsData.onGetFollowList = function(self,info)
    if not info then return end
    --Cache
    local num = info.item_num;
    if not num then return end
    Log.i("onGetFriendsList:"..info.curr_page);
    if info.curr_page == 0 then
        self.m_cache_follow_page_tab = {};
    end
    for i=1,num do
        if info.friend_uid[i] then
            table.insert(self.m_cache_follow_page_tab,info.friend_uid[i]);
        end
    end
    if info.curr_page+1 >= info.page_num then
        self:setFollowNum(#self.m_cache_follow_page_tab);
        self:saveFollowListData(self.m_cache_follow_page_tab);
    end
end


FriendsData.saveFollowListData = function(self,data)
    local ret = {};
    local change = {};
    if self.m_follow_page_tab then
        for i,v in pairs(data) do
            if self.m_follow_page_tab[tonumber(v)] then
                ret[v..""] = 0;
                change[tonumber(v)] = self.m_follow_page_tab[tonumber(v)];
            else
                ret[v..""] = 0;
                change[tonumber(v)] = 1;
            end
        end
    else
        for i,v in pairs(data) do
            ret[v..""] = 0;
            change[tonumber(v)] = 0;
        end
    end
    self.m_follow_page_tab = change;
    local saveTab = {};
    saveTab.data = ret;
    saveTab.saveTime = os.time();
    self:saveString(GameCacheData.FRIEND_FOLLOW_PAGE_TAB..UserInfo.getInstance():getUid(),json.encode(saveTab));
    local ret = {};
    for i,v in pairs(self.m_follow_page_tab) do
        table.insert(ret,tonumber(i));
        if v == 1 then
            BottomMenu.getInstance():setOwnBtnTipVisible();
        end
    end
    table.sort(ret,FriendsData.sort_cmp);
    EventDispatcher.getInstance():dispatch(Event.Call,kFriend_UpdateFollowList,ret);
end

FriendsData.onGetFansList = function(self,info)
    if not info then return end
    --Cache
    local num = info.item_num;
    if not num then return end
    Log.i("onGetFriendsList:"..info.curr_page);
    if info.curr_page == 0 then
        self.m_cache_fans_page_tab = {};
    end
    for i=1,num do
        if info.friend_uid[i] then
            table.insert(self.m_cache_fans_page_tab,info.friend_uid[i]);
        end
    end
    if info.curr_page+1 >= info.page_num then
        self:setFansNum(#self.m_cache_fans_page_tab);
        self:saveFansListData(self.m_cache_fans_page_tab);
    end
end

FriendsData.saveFansListData = function(self,data)
    local ret = {};
    local change = {};
    if self.m_fans_page_tab then
        for i,v in pairs(data) do
            if self.m_fans_page_tab[tonumber(v)] then
                ret[v..""] = 0;
                change[tonumber(v)] = self.m_fans_page_tab[tonumber(v)];
            else
                ret[v..""] = 0;
                change[tonumber(v)] = 1;
            end
        end
    else
        for i,v in pairs(data) do
            ret[v..""] = 0;
            change[tonumber(v)] = 0;
        end
    end
    self.m_fans_page_tab = change;
    local saveTab = {};
    saveTab.data = ret;
    saveTab.saveTime = os.time();
    self:saveString(GameCacheData.FRIEND_FANS_PAGE_TAB..UserInfo.getInstance():getUid(),json.encode(saveTab));
    local ret = {};
    for i,v in pairs(self.m_fans_page_tab) do
        table.insert(ret,tonumber(i));
        if v == 1 then
            BottomMenu.getInstance():setOwnBtnTipVisible();
        end
    end
    table.sort(ret,FriendsData.sort_cmp);
    EventDispatcher.getInstance():dispatch(Event.Call,kFriend_UpdateFansList,ret);
end

FriendsData.getFollowListData = function(self)
    local isGetNum = true;
    if not self.m_follow_page_tab then
        local jsonStr = self:getString(GameCacheData.FRIEND_FOLLOW_PAGE_TAB..UserInfo.getInstance():getUid(),nil);
        if not jsonStr then 
            isGetNum = false;
            self:sendGetFollowListCmd();
            return nil;
        end
        local tab = json.decode(jsonStr);
        self.m_follow_page_tab = {}
        for i,v in pairs(tab.data) do
            self.m_follow_page_tab[tonumber(i)] = v;
        end
        local diff = os.time() - tab.saveTime;
        if diff < 0 or diff > FriendsData.Cache_Time then
            isGetNum = false;
            self:sendGetFollowListCmd();
        end
    end
    if isGetNum then
        self:sendGetFollowNumCmd();
    end
    local ret = {};
    for i,v in pairs(self.m_follow_page_tab) do
        table.insert(ret,tonumber(i));
    end
    table.sort(ret,FriendsData.sort_cmp);
    return ret;
end

FriendsData.getFansListData = function(self)
    local isGetNum = true;
    if not self.m_fans_page_tab then
        local jsonStr = self:getString(GameCacheData.FRIEND_FANS_PAGE_TAB..UserInfo.getInstance():getUid(),nil);
        if not jsonStr then 
            isGetNum = false;
            self:sendGetFansListCmd();
            return nil;
        end
        local tab = json.decode(jsonStr);
        self.m_fans_page_tab = {}
        for i,v in pairs(tab.data) do
            self.m_fans_page_tab[tonumber(i)] = v;
        end
        local diff = os.time() - tab.saveTime;
        if diff < 0 or diff > FriendsData.Cache_Time then
            isGetNum = false;
            self:sendGetFansListCmd();
        end
    end
    if isGetNum then
        self:sendGetFansNumCmd();
    end
    local ret = {};
    for i,v in pairs(self.m_fans_page_tab) do
        table.insert(ret,tonumber(i));
    end
    table.sort(ret,FriendsData.sort_cmp);
    return ret;
end

FriendsData.isNewFriends = function(self,uid)
    if self.m_friends_page_tab then
        return self.m_friends_page_tab[uid] or 0;
    else
        return 0;
    end
end


FriendsData.setIsNewFriends = function(self,uid,flag)
    if self.m_friends_page_tab and self.m_friends_page_tab[uid] then
        self.m_friends_page_tab[uid] = flag;
    end
end

FriendsData.isNewFollow = function(self,uid)
    if self.m_follow_page_tab then
        return self.m_follow_page_tab[uid] or 0;
    else
        return 0;
    end
end

FriendsData.isNewFans = function(self,uid)
    if self.m_fans_page_tab then
        return self.m_fans_page_tab[uid] or 0;
    else
        return 0;
    end
end

FriendsData.setIsNewFans = function(self,uid,flag)
    if self.m_fans_page_tab and self.m_fans_page_tab[uid] then
        self.m_fans_page_tab[uid] = flag;
    end

end

----------------------- 聊天数据

FriendsData.createNewChat = function(self,uid)
    if self.m_rcache_chat_list[uid] then return false end
    local data = {};
    data.uid = uid;
    data.unReadNum = 0;
    data.time = os.time();
    table.insert(self.m_cache_chat_list,1,data);
    self.m_rcache_chat_list = {};
    for i,v in pairs(self.m_cache_chat_list) do
        self.m_rcache_chat_list[v.uid] = i;
    end
    self:saveChatList();
    return true;
end

FriendsData.getChatByUid = function(self,uid)
    if not self.m_rcache_chat_list[uid] then return end
    return self.m_cache_chat_list[self.m_rcache_chat_list[uid]];
end

FriendsData.getChatList = function(self)
    if #self.m_cache_chat_list == 0 then
        local chatList = self:getString(GameCacheData.FRIEND_CHAT_LIST..UserInfo.getInstance():getUid());
        return json.decode(chatList) or {};
    end;
    return self.m_cache_chat_list;
end

FriendsData.updateChatByUid = function(self,uid,data)
    if not tonumber(uid) or not self.m_rcache_chat_list[uid] then return end
    self.m_cache_chat_list[self.m_rcache_chat_list[uid]].last_msg = data.msg;
    self.m_cache_chat_list[self.m_rcache_chat_list[uid]].time = data.time or os.time();
    self:sortChatList();
    self:saveChatList();
end

FriendsData.saveChatList = function(self)
    self:saveString(GameCacheData.FRIEND_CHAT_LIST..UserInfo.getInstance():getUid(),json.encode(self.m_cache_chat_list));
    EventDispatcher.getInstance():dispatch(Event.Call,kFriend_UpdateChatsList,self.m_cache_chat_list);
end

FriendsData.getChatData = function(self,uid)
    if not tonumber(uid) then return end
    return json.decode(self:getString(GameCacheData.FRIEND_CHAT_DATA..tonumber(uid).."_"..UserInfo.getInstance():getUid(),nil)) or {};
end

FriendsData.saveChatData = function(self,uid,data)
    if not tonumber(uid) then return end
    self:saveString(GameCacheData.FRIEND_CHAT_DATA..tonumber(uid).."_"..UserInfo.getInstance():getUid(),json.encode(data));
end

FriendsData.removeChat = function(self,uid)
    if not tonumber(uid) or not self.m_rcache_chat_list[uid] then return end
    table.remove(self.m_cache_chat_list,self.m_rcache_chat_list[uid]);
    self.m_rcache_chat_list = {};
    for i,v in pairs(self.m_cache_chat_list) do
        self.m_rcache_chat_list[v.uid] = i;
    end
    self:saveChatList();
    self:saveChatData(uid,nil);
end

FriendsData.updateUnreadChatByUid = function(self,uid)
    if not tonumber(uid) or not self.m_rcache_chat_list[uid] then return end
    self.m_cache_chat_list[self.m_rcache_chat_list[uid]].unReadNum = 0;
    self:saveChatList();
end

FriendsData.getUnreadNum = function(self)
    local unReadNum = 0;
    for i,v in pairs(self.m_cache_chat_list) do
        unReadNum = unReadNum + v.unReadNum;
    end
    return unReadNum;
end

FriendsData.addChatDataByUid = function(self,uid,msg)
    if not self.m_rcache_chat_list[uid] then
        self:createNewChat(uid);
    end
    local chatdata = self:getChatData(uid);
    local data = {};
    data.send_uid = UserInfo.getInstance():getUid();
    data.recv_uid = uid;
    data.msg_id = -1;
    data.time = os.time();
    data.msg = msg;
    table.insert(chatdata,data);
    if #chatdata > 1000 then
        table.remove(chatdata,1);
    end
    self:saveChatData(uid,chatdata);
    self:updateChatByUid(uid,data);
end

FriendsData.onGetFriendsMsg = function(self,info)
    if not info then return end
    local data = json.decode(info.msg);
    if not self.m_rcache_chat_list[data.send_uid] then
        self:createNewChat(data.send_uid);
    end
    local chat = self:getChatByUid(data.send_uid);
    chat.unReadNum = chat.unReadNum + 1;
    local chatdata = self:getChatData(data.send_uid);
--    if not chatdata[#chatdata] then
        table.insert(chatdata,data);
        if #chatdata > 50 then
            table.remove(chatdata,1);
        end
        self:saveChatData(data.send_uid,chatdata);
        self:updateChatByUid(data.send_uid,data);
        EventDispatcher.getInstance():dispatch(Event.Call,kFriend_UpdateChatMsg,data);
--    end
    local sendInfo = {};
    sendInfo.msg_id = data.msg_id; -- 不唯一
    OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_RECV_MSG_CHECK,sendInfo);
end

FriendsData.sortChatList = function(self)
    table.sort(self.m_cache_chat_list,FriendsData.sortChat_cmp);
    self.m_rcache_chat_list= {};
    for i,v in pairs(self.m_cache_chat_list) do
        self.m_rcache_chat_list[v.uid] = i;
    end
end

FriendsData.sortChat_cmp = function(data2,data1)
    if not tonumber(data1.time) then
        return true;
    end
    if not tonumber(data2.time) then
        return false;
    end
    return tonumber(data2.time) > tonumber(data1.time);
end
