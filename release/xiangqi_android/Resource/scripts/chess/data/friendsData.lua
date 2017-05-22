--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require("util/game_cache_data")
FriendsData = class(GameCacheData,false);

FriendsData.Cache_Time = 600;
FriendsData.Status_Cache_Time = 30;
FriendsData.Combat_Cache_Time = 10;

FriendsData.data = 
{ 
    NORMAL = "_normal_";
    RECORD = "_record_";
    HONOR = "_honor_";
}

FriendsData.event = 
{ 
    NORMAL = 0x111 ;
    RECORD = 0x112 ;
    HONOR = 0x113;
}

FriendsData.ctor = function(self)
    self.m_dict = new(Dict,"friends_data");
	self.m_dict:load();
    self.m_cache_friends_page_tab = {};
    self.m_cache_follow_page_tab = {};
    self.m_cache_fans_page_tab = {};
    self.m_cache_user_status = {};
    self.m_cache_user_combat = {}
    --用户信息的内存缓存
    self.m_cache_user_data = {};
    self.m_cache_user_data.normalFriendsData = {}     --详细信息
    self.m_cache_user_data.recordFriendsData = {}     --战绩信息
    self.m_cache_user_data.honorFriendsData = {}      --荣誉信息

    self.m_rcache_chat_list = {};
    
    self.m_cache_chat_list = json.decode(self:getString(GameCacheData.FRIEND_CHAT_LIST..UserInfo.getInstance():getUid(),nil));
    self.m_cache_chat_list = self.m_cache_chat_list or {};
    for i,v in pairs(self.m_cache_chat_list) do
        if v.uid then
            self.m_rcache_chat_list[v.uid] = i;
        end
    end

    self.m_send_cmd_user_status = {};

    --需要后台请求的数据，针对用户信息
    self.m_send_cmd_user_data = {};   
    self.m_send_cmd_user_record_data = {}
    self.m_send_cmd_user_honor_data = {}       
    self.m_send_cmd_user_combat = {};

    self.m_anim = AnimFactory.createAnimInt(kAnimLoop,0,1,1000);
    self.m_anim:setEvent(self,self.animEvent);
    self.m_anim:setDebugName("FriendsData.anim");
    self.m_anim:setPause(true)

    --self:initFriendsAnim()
end

FriendsData.init = function(self)
    self:getFrendsListData();
    self:getFollowListData();
    self:getFansListData();
    -- 获取黑名单
    self:sendGetBlacklistCmd()
end

FriendsData.refresh = function(self)
     self:sendGetFriendsListCmd();
     self:sendGetFollowListCmd();
     self:sendGetFansListCmd();
end

FriendsData.startAnim = function(self)
    self.m_anim:setPause(false)
end

FriendsData.startRecordAnim = function (self)
    if self.record_anim then 
        self.record_anim:setPause(false)
    end
end

FriendsData.startHonorAnim = function (self)
    if self.honor_anim then 
        self.honor_anim:setPause(false)
    end
end

--初始化获取纪录数据的anim，当前帧执行
FriendsData.initRecordAnim = function (self) 
    if not self.record_anim then 
        self.record_anim = AnimFactory.createAnimInt(kAnimLoop,0,1,1000)
        self.record_anim:setEvent(self,self.recordAnimEvent)
        self.record_anim:setDebugName("FriendsData.recordAnim")
        self.record_anim:setPause(true) 
    end
end 

--初始化获取荣誉数据的anim，当前帧执行
FriendsData.initHonorAnim = function (self)  
    if not self.honor_anim then 
        self.honor_anim = AnimFactory.createAnimInt(kAnimLoop,0,1,1000)
        self.honor_anim:setEvent(self, self.honorAnimEvent)
        self.honor_anim:setDebugName("FriendsData.honorAnim")
        self.honor_anim:setPause(true)
    end
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
            HttpModule.getInstance():execute2(HttpModule.s_cmds.getFriendUserInfo,info,function(isSuccess,resultStr)
                    self:onFriendCmdCheckUserData(isSuccess,resultStr)
                end);
        end
        self.m_send_cmd_user_data = {};
    end

    if self.m_send_cmd_user_combat then
        local send = {};
        for i,v in pairs(self.m_send_cmd_user_combat) do
            Log.i (i)
            table.insert(send,i);
        end
        if #send > 0 then
            Log.i("getFriendCombat");
            local info = {};
            info.mid_arr = {};
            for i,v in pairs(send) do
                info.mid_arr["mid"..i] = v;
            end
            HttpModule.getInstance():execute(HttpModule.s_cmds.getFriendCombat,info);
        end
        self.m_send_cmd_user_combat = {};
    end

    if not self.upOnlineNumTime or os.time() - self.upOnlineNumTime > 30 then
        self.upOnlineNumTime = os.time();
        if OnlineSocketManager.getHallInstance():isSocketOpen() then
            OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_ONLINE_NUM);
	    end
    end
    self.m_anim:setPause(true)
end

--获取纪录信息的执行事件
FriendsData.recordAnimEvent = function (self)
    if self.m_send_cmd_user_record_data then
        local send = {};
        for i,v in pairs(self.m_send_cmd_user_record_data) do
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
            HttpModule.getInstance():execute2(HttpModule.s_cmds.getFriendUserRecordInfo,info,function(isSuccess,resultStr)
                    self:onFriendCmdCheckUserRecordData(isSuccess,resultStr)
                end);
        end
        self.m_send_cmd_user_record_data = {};
    end
    self.record_anim:setPause(true)
end

--获取荣誉信息的执行事件
FriendsData.honorAnimEvent = function (self)
    if self.m_send_cmd_user_honor_data then
        local send = {};
        for i,v in pairs(self.m_send_cmd_user_honor_data) do
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
            HttpModule.getInstance():execute2(HttpModule.s_cmds.getFriendUserHonorInfo,info,function(isSuccess,resultStr)
                    self:onFriendCmdCheckUserHonorData(isSuccess,resultStr)
                end);
        end
        self.m_send_cmd_user_honor_data = {};
    end
    self.honor_anim:setPause(true)
end

--http请求获取个人信息的回调函数
FriendsData.onFriendCmdCheckUserData = function(self,isSuccess,resultStr)
    if not isSuccess then return ;end
    message = json.decode(resultStr);
    local data = message.data;
    local flag = tonumber(message.flag)
    if flag ~= 10000 or type(data) ~= "table" then return end
    self:onCheckUserNormalData(data);
end

--http请求获取战绩信息的回调函数
FriendsData.onFriendCmdCheckUserRecordData = function (self,isSuccess, resultStr)
    if not isSuccess then return ;end
    message = json.decode(resultStr);
    local data = message.data;
    if type(data) ~= "table" then return end
    self:onCheckUserRecordData(data);
end

--http请求获取荣誉信息的回调函数
FriendsData.onFriendCmdCheckUserHonorData = function (self,isSuccess, resultStr)
    if not isSuccess then return ;end
    message = json.decode(resultStr);
    local data = message.data;
    if type(data) ~= "table" then return end
    self:onCheckUserHonorData(data);
end

FriendsData.clear = function(self)
    delete(FriendsData.instance);
    FriendsData.instance = nil;
end

FriendsData.dtor = function(self)
    delete(self.m_anim)
    if self.record_anim then 
        delete(self.record_anim)
    end
    if self.honor_anim then 
        delete(self.honor_anim)
    end
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

--发起后台数据请求 个人信息
--param data 需要被校验的用户id ， 或者用户id列表
--return 
FriendsData.sendCheckUserData = function(self,data)
    if not data then return end;
    local tab = {}
    if type(data) ~= "table" then
        table.insert(tab,data);
    else
        tab = data;
    end

    for i,v in ipairs(tab) do
        if tonumber(v) ~= 0 then
            self.m_send_cmd_user_data[v] = 1;
        end
    end
    self:startAnim();
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

--发起后台数据请求 战绩信息
--param data 需要被校验的用户id ， 或者用户id列表
--return 
FriendsData.sendCheckUserRecordData = function(self,data)
    if not data then return end;
    self:initRecordAnim()
    local tab = {}
    if type(data) ~= "table" then
        table.insert(tab,data);
    else
        tab = data;
    end

    for i,v in ipairs(tab) do
        if tonumber(v) ~= 0 then
            self.m_send_cmd_user_record_data[v] = 1;
        end
    end
    self:startRecordAnim();
end

--发起后台数据请求 荣誉信息
--param data 需要被校验的用户id ， 或者用户id列表
--return 
FriendsData.sendCheckUserHonorData = function(self,data)
    if not data then return end;
    self:initHonorAnim()
    local tab = {}
    if type(data) ~= "table" then
        table.insert(tab,data);
    else
        tab = data;
    end

    for i,v in ipairs(tab) do
        if tonumber(v) ~= 0 then
            self.m_send_cmd_user_honor_data[v] = 1;
        end
    end
    self:startHonorAnim();
end

FriendsData.sendCheckUserCombat = function(self,data)
    if not data then return end;
    local tab = {}
    if type(data) ~= "table" then
        table.insert(tab,data);
    else
        tab = data;
    end

    for i,v in ipairs(tab) do
        if tonumber(v) ~= 0 then
            self.m_send_cmd_user_combat[v] = 1;
        end
    end
    self:startAnim()
end
--FriendsData.onCheckUserNormalData = function(self,data)
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
FriendsData.onGetFriendCombat = function(self,data)
    if type(data) ~= "table" then return end
    
    local info = {};
    for i,v in pairs(data) do
        if v and type(v) == "table" then
            local item = {}
            item.mid            = tonumber(v.mid) or 0
            item.target_mid     = tonumber(v.target_mid) or 0
            item.wintimes       = tonumber(v.wintimes) or 0
            item.losetimes      = tonumber(v.losetimes) or 0
            item.drawtimes      = tonumber(v.drawtimes) or 0
            table.insert(info,item)
        end
    end
    local ret = {};
    for i,value in ipairs(info) do
       if value then
          self.m_cache_user_combat[value.target_mid] = value;
          if type(self.m_cache_user_combat[value.target_mid]) == "table" then
              self.m_cache_user_combat[value.target_mid].saveTime = os.time();
              table.insert(ret,self.m_cache_user_combat[value.target_mid]);
              self:saveString(GameCacheData.FRIEND_USER_COMBAT .. value.mid .."_"..value.target_mid,json.encode(self.m_cache_user_combat[value.target_mid]));
          else
              self.m_cache_user_combat[value.target_mid] = nil;
          end
       end
    end
    EventDispatcher.getInstance():dispatch(Event.Call,kFriend_UpdateUserCombat,ret);
end

--处理个人信息，内存缓存，本地缓存
FriendsData.onCheckUserNormalData = function(self,data)
    if type(data) ~= "table" then return end
    
    local info = {};
    for i,v in pairs(data) do
        --安全处理
        local item = self:analyzeUserNormalData(v);  
        table.insert(info,item);
    end
    local ret = {};
    for i,value in ipairs(info) do
       if value then
          self.m_cache_user_data.normalFriendsData[value.mid] = value;
          if type(self.m_cache_user_data.normalFriendsData[value.mid]) == "table" then
              self.m_cache_user_data.normalFriendsData[value.mid].saveTime = os.time();
              table.insert(ret,self.m_cache_user_data.normalFriendsData[value.mid]);
              self:saveString(GameCacheData.FRIEND_USER_DATA .. FriendsData.data.NORMAL .. value.mid,
              json.encode(self.m_cache_user_data.normalFriendsData[value.mid]));
          else
              self.m_cache_user_data.normalFriendsData[value.mid] = nil;
          end
       end
    end
    EventDispatcher.getInstance():dispatch(Event.Call, kFriend_UpdateUserData, ret);
end

--处理战绩信息，内存缓存，本地缓存
FriendsData.onCheckUserRecordData = function(self,data)
    if type(data) ~= "table" then return end
    
    local info = {};
    for i,v in pairs(data) do
        v.mid = tonumber(i)
        local item = self:analyzeUserRecordData(v);  
        table.insert(info,item);
    end
    local ret = {};
    for i,value in ipairs(info) do
       if value then
          self.m_cache_user_data.recordFriendsData[value.mid] = value;
          if type(self.m_cache_user_data.recordFriendsData[value.mid]) == "table" then
              self.m_cache_user_data.recordFriendsData[value.mid].saveTime = os.time();
              table.insert(ret,self.m_cache_user_data.recordFriendsData[value.mid]);
              self:saveString(GameCacheData.FRIEND_USER_DATA .. FriendsData.data.RECORD .. value.mid,
              json.encode(self.m_cache_user_data.recordFriendsData[value.mid]));
          else
              self.m_cache_user_data.recordFriendsData[value.mid] = nil;
          end
       end
    end
    EventDispatcher.getInstance():dispatch(FriendsData.event.RECORD, ret);
end

--处理荣誉信息，内存缓存，本地缓存
FriendsData.onCheckUserHonorData = function(self,data)
    if type(data) ~= "table" then return end
    
    local info = {};
    for i,v in pairs(data) do
        local item = self:analyzeUserHonorData(v);  
        table.insert(info,item);
    end
    local ret = {};
    for i,value in ipairs(info) do
       if value then
          self.m_cache_user_data.honorFriendsData[value.mid] = value;
          if type(self.m_cache_user_data.honorFriendsData[value.mid]) == "table" then
              self.m_cache_user_data.honorFriendsData[value.mid].saveTime = os.time();
              table.insert(ret,self.m_cache_user_data.honorFriendsData[value.mid]);
              self:saveString(GameCacheData.FRIEND_USER_DATA .. FriendsData.data.HONOR .. value.mid,
              json.encode(self.m_cache_user_data.honorFriendsData[value.mid]));
          else
              self.m_cache_user_data.honorFriendsData[value.mid] = nil;
          end
       end
    end
    EventDispatcher.getInstance():dispatch(FriendsData.event.HONOR, ret);
end

--对用户个人信息数据进行安全处理
function FriendsData:analyzeUserNormalData(data)
    if type(data) ~= "table" then return nil end
    local ret = {};
    ret.mid = tonumber(data.mid) or 0;
    ret.mnick = data.mnick or "";
    if ret.mnick == "" then
        ret.mnick = ret.mid .. ""  -- 如果不存在昵称　则用id 代替
    end
    ret.mactivetime = data.mactivetime or 0;
    ret.iconType = data.iconType or 0;
    ret.score = tonumber(data.score) or 0;
    ret.money = tonumber(data.money) or 0;
    ret.icon_url = data.icon_url;
    ret.rank = tonumber(data.rank) or 0;
    ret.sex = tonumber(data.sex) or 0;
    ret.is_vip = tonumber(data.is_vip) or 0;
    ret.saveTime = tonumber(data.saveTime) or 0;            -- 客户端缓存用户数据的参数
    ret.geo = data.geo;                                     --地理位置
    ret.signature = data.signature;                         --签名 
    ret.wintimes = tonumber(data.wintimes) or 0
    ret.drawtimes = tonumber(data.drawtimes) or 0
    ret.losetimes = tonumber(data.losetimes) or 0
    --获得用户个性装扮
    ret.my_set = {}
    if type(data.my_set) == "string" then
        local info = {}
        if data.my_set == "" then 
            info.picture_frame = "sys";
            info.piece = "sys";
            info.board = "sys";
        else
            local tab = json.decode_node(data.my_set);
            info = json.analyzeJsonNode(tab);
        end
        ret.my_set = info
    elseif type(data.my_set) == "table" then
        ret.my_set = data.my_set
    end
    ret.guild = {}
    if data.guild then  
        if type(data.guild) == "table" then
            for key,v in pairs(data.guild) do
                if v then
                    ret.guild[key] = v
                end
            end
        end
    end

    ret.match_best = {}
    if type(data.match_best) == "string" then
        local info = {}
        if data.match_best == "" then 
            
        else
            local tab = json.decode_node(data.match_best);
            info = json.analyzeJsonNode(tab);
        end
        ret.match_best = info
--        ret.match_best = json.analyzeJsonNode(data.match_best);
    end

    if UserInfo.getInstance():getUid() == ret.mid then
        if next(ret.guild) == nil then
            UserInfo.getInstance():clearUserSociatyData()
            EventDispatcher.getInstance():dispatch(Event.Call,kSociaty_quitSociaty);
        else
            UserInfo.getInstance():setUserSociatyData2(ret.guild)
        end
    end

    return ret;
end

--对用户战绩信息数据进行安全处理
function FriendsData:analyzeUserRecordData(data)
    if type(data) ~= "table" then return nil end
    local ret = {};
    ret.mid = tonumber(data.mid) or 0;
    --ret.score = tonumber(data.score) or 0;
    --ret.money = tonumber(data.money) or 0;
    --ret.drawtimes = tonumber(data.drawtimes) or 0;
    --ret.wintimes = tonumber(data.wintimes) or 0;
    --ret.losetimes = tonumber(data.losetimes) or 0;
    ret.booth_gate_name = ""                 --残局信息
    if data.booth_gate~=nil then 
        ret.booth_gate_name = FriendsData:getBoothgateNameByID(data.booth_gate.ending_name,data.booth_gate.ending_process)
    end
    ret.single_game_name = ""              --单机信息 
    if data.single_game ~=nil then 
        ret.single_game_name = FriendsData:getSingleGameNameByID(data.single_game.tollgate_name, data.single_game.process)
    end     
    ret.saveTime = tonumber(data.saveTime) or 0;            -- 客户端缓存用户数据的参数
    ret.match_best = {}
    if type(data.match_best) == "string" then
        local info = {}
        if data.match_best == "" then 
            
        else
            local tab = json.decode_node(data.match_best);
            info = json.analyzeJsonNode(tab);
        end
        ret.match_best = info
--        ret.match_best = json.analyzeJsonNode(data.match_best);
    end
    return ret;
end

--对用户荣誉信息数据进行安全处理
function FriendsData:analyzeUserHonorData(data)
    if type(data) ~= "table" then return nil end
    local ret = {};
    ret.mid = tonumber(data.mid) or 0;
    ret.master_rank = tonumber(data.master_rank) or 0
    ret.match_rank = tonumber(data.match_rank) or 0
    ret.match_num = tonumber(data.match_num) or 0
    ret.win_time = tonumber(data.win_time) or 0
    ret.rank = tonumber(data.rank) or 0;    --魅力榜排名   
    ret.fans_rank = tonumber(data.fans_rank) or 0;
    ret.friends_num = tonumber(data.friends_num) or 0;
    ret.fans_num = tonumber(data.fans_num) or 0;
    ret.attention_num = tonumber(data.attention_num) or 0;
    ret.charm_value = tonumber(data.charm_value) or 0;
    ret.saveTime = tonumber(data.saveTime) or 0;            -- 客户端缓存用户数据的参数
    ret.gift = {}
    
    if type(data.gift) == "table" then
        for key,val in pairs(data.gift) do
            ret.gift[key] = val
        end
    end

    return ret;
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
        if tonumber(v) ~= 0 then
            self.m_send_cmd_user_status[v] = 1;
        end
    end
    self:startAnim()
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
        EventDispatcher.getInstance():dispatch(Event.Call,kFriend_UpdateFollowList,self:getFollowListData());
    end
    EventDispatcher.getInstance():dispatch(Event.Call,kFriend_UpdateStatus,data.items);
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
            table.insert(ret,status)
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
        return ret[1]
    end
    return ret
end


--获取用户所有数据
--[[
FriendsData.getUserData = function(self,data)
    if not data then return end
    local tab = {}
    if type(data) ~= "table" then
        table.insert(tab,data);
    else
        tab = data
    end
    local ret = {};
    local needCheck = {};
    for i,value in ipairs(tab) do
        local status = self.m_cache_user_data[tonumber(value)] or self:analyzeUserNormalData(json.decode(self:getString(GameCacheData.FRIEND_USER_DATA..(tonumber(value)),nil)));
        if status then
            --判断要查找的用户是否是自己
            if tonumber(value) == tonumber(UserInfo.getInstance():getUid()) then
                status.iconType = UserInfo.getInstance():getIconType();
                status.icon_url = UserInfo.getInstance():getIcon();
                status.mnick = UserInfo.getInstance():getName();
                status.my_set = UserInfo.getInstance():getUserSet()
                status.is_vip = UserInfo.getInstance():getIsVip()
                status.drawtimes = UserInfo.getInstance():getDrawtimes()
                status.losetimes = UserInfo.getInstance():getLosetimes()
                status.wintimes = UserInfo.getInstance():getWintimes()
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
]]--

--获取用户个人信息getNormalFriendsData
--说明 提供刷新机制
--param data 用户的id，可以是单个id，也可以是id列表
--return ret 用户id的个人信息，多少个id，就多少个用户的个人信息 
FriendsData.getUserData = function (self, data)
    if not data then return end
    local tab = {}
    if type(data) ~= "table" then
        table.insert(tab,data)
    else
        tab = data
    end
    local ret = {}
    local needCheck = {}
    for i,value in ipairs(tab) do
        local status = self.m_cache_user_data.normalFriendsData[tonumber(value)] or self:analyzeUserNormalData(json.decode(self:getString(GameCacheData.FRIEND_USER_DATA.. FriendsData.data.NORMAL..(tonumber(value)),nil)));
        if status then
            --判断要查找的用户是否是自己
            if tonumber(value) == tonumber(UserInfo.getInstance():getUid()) then
                status.iconType = UserInfo.getInstance():getIconType();
                status.icon_url = UserInfo.getInstance():getIcon();
                status.mnick = UserInfo.getInstance():getName();
                status.my_set = UserInfo.getInstance():getUserSet()
                status.is_vip = UserInfo.getInstance():getIsVip()
            end
            table.insert(ret,status);
            self.m_cache_user_data.normalFriendsData[tonumber(value)] = status;
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

--获取用户战绩信息
--说明 不提供刷新机制
--param data 用户的id，可以是单个id，也可以是id列表
--return ret 用户id的战绩信息，多少个id，就多少个用户的战绩信息 
FriendsData.getRecordFriendsData = function (self, data)
    if not data then return end    
    local tab = {}
    if type(data) ~= "table" then
        table.insert(tab,data)
    else
        tab = data
    end
    local ret = {}
    local needCheck = {}
    for i,value in ipairs(tab) do
        local status = self.m_cache_user_data.recordFriendsData[tonumber(value)] or self:analyzeUserRecordData(json.decode(self:getString(GameCacheData.FRIEND_USER_DATA.. FriendsData.data.RECORD..(tonumber(value)),nil)));
        if status then
        --[[
            --判断要查找的用户是否是自己
            if tonumber(value) == tonumber(UserInfo.getInstance():getUid()) then
                status.iconType = UserInfo.getInstance():getIconType();
                status.icon_url = UserInfo.getInstance():getIcon();
                status.mnick = UserInfo.getInstance():getName();
                status.my_set = UserInfo.getInstance():getUserSet()
                status.is_vip = UserInfo.getInstance():getIsVip()
            end]]--
            table.insert(ret,status);
            self.m_cache_user_data.recordFriendsData[tonumber(value)] = status;
            local diff = os.time() - status.saveTime;
            if diff < 0 or diff > FriendsData.Cache_Time then
                table.insert(needCheck,value);
            end
        else
            table.insert(needCheck,value);
        end
    end
    if #needCheck > 0 then
        self:sendCheckUserRecordData(needCheck);
    end
    if type(data) ~= "table" then
        return ret[1];
    end
    return ret;
end

--获取用户荣誉信息
--说明 不提供刷新机制
--param data 用户的id，可以是单个id，也可以是id列表
--return ret 用户id的荣誉信息，多少个id，就多少个用户的荣誉信息 
FriendsData.getHonorFriendsData = function (self, data)
    if not data then return end
    local tab = {}
    if type(data) ~= "table" then
        table.insert(tab,data)
    else
        tab = data
    end
    local ret = {}
    local needCheck = {}
    for i,value in ipairs(tab) do
        local status = self.m_cache_user_data.honorFriendsData[tonumber(value)] or self:analyzeUserHonorData(json.decode(self:getString(GameCacheData.FRIEND_USER_DATA.. FriendsData.data.HONOR..(tonumber(value)),nil)));
        if status then
        --[[
            --判断要查找的用户是否是自己
            if tonumber(value) == tonumber(UserInfo.getInstance():getUid()) then
                status.iconType = UserInfo.getInstance():getIconType();
                status.icon_url = UserInfo.getInstance():getIcon();
                status.mnick = UserInfo.getInstance():getName();
                status.my_set = UserInfo.getInstance():getUserSet()
                status.is_vip = UserInfo.getInstance():getIsVip()
            end]]--
            table.insert(ret,status);
            self.m_cache_user_data.honorFriendsData[tonumber(value)] = status;
            local diff = os.time() - status.saveTime;
            if diff < 0 or diff > FriendsData.Cache_Time then
                table.insert(needCheck,value);
            end
        else
            table.insert(needCheck,value);
        end
    end
    if #needCheck > 0 then
        self:sendCheckUserHonorData(needCheck);
    end
    if type(data) ~= "table" then
        return ret[1];
    end
    return ret;
end

FriendsData.getUserCombat = function(self,data)
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
        local status = self.m_cache_user_combat[tonumber(value)]
        if not self.m_cache_user_combat[tonumber(value)] then
            local jsonStr =self:getString(GameCacheData.FRIEND_USER_COMBAT .. UserInfo.getInstance():getUid() .."_"..value,"");
            status = json.decode(jsonStr)
        end
        if status then
            if tonumber(value) == tonumber(UserInfo.getInstance():getUid()) then
                status.iconType = UserInfo.getInstance():getIconType();
                status.icon_url = UserInfo.getInstance():getIcon();
                status.mnick = UserInfo.getInstance():getName();
            end
            table.insert(ret,status);
            self.m_cache_user_combat[tonumber(value)] = status;
            local diff = os.time() - status.saveTime;
            if diff < 0 or diff > FriendsData.Combat_Cache_Time then
                table.insert(needCheck,value);
            end
        else
            table.insert(needCheck,value);
        end
    end
    if #needCheck > 0 then
        self:sendCheckUserCombat(needCheck);
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
--    if not self.m_sendGetFriendsListCmdTime or os.time() - self.m_sendGetFriendsListCmdTime > 1 then
--        self.m_sendGetFriendsListCmdTime = os.time();
    if not self.m_sendGetFriendFollowListCmdTime or os.time() - self.m_sendGetFriendFollowListCmdTime > 1 then
        self.m_sendGetFriendFollowListCmdTime = os.time();
        -- 因为合并了2张表 所以必须这样才能满足需求
--        OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_GET_FRIENDS_LIST);
--        OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_GET_FOLLOW_LIST);
        OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_GET_FRIEND_FOLLOW_LIST);
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
--            BottomMenu.getInstance():setFriendsBtnTipVisible();
        end
    end
--    table.sort(ret,FriendsData.sort_cmp);
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
	    self.m_friends_page_tab = {}
        local jsonStr = self:getString(GameCacheData.FRIEND_FRIENDS_PAGE_TAB..UserInfo.getInstance():getUid(),nil);
        if not jsonStr then 
            isGetNum = false;
            self:sendGetFriendsListCmd();
            return nil;
        end
        local tab = json.decode(jsonStr);
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
--    table.sort(ret,FriendsData.sort_cmp);
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
            local ret = self:getFollowListData()
            self:saveFollowListData(ret);
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
            local ret = self:getFollowListData()
            self:saveFollowListData(ret);
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
--    if not self.m_sendGetFollolListCmdTime or os.time() - self.m_sendGetFollolListCmdTime > 1 then
--        self.m_sendGetFollolListCmdTime = os.time();
    if not self.m_sendGetFriendFollowListCmdTime or os.time() - self.m_sendGetFriendFollowListCmdTime > 1 then
        self.m_sendGetFriendFollowListCmdTime = os.time();
        -- 因为合并了2张表 所以必须这样才能满足需求
--        OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_GET_FRIENDS_LIST);
--        OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_GET_FOLLOW_LIST);
        OnlineSocketManager.getHallInstance():sendMsg(FRIEND_CMD_GET_FRIEND_FOLLOW_LIST);
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
--            BottomMenu.getInstance():setOwnBtnTipVisible();
        end
    end
--    table.sort(ret,FriendsData.sort_cmp);
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
--            BottomMenu.getInstance():setFriendsBtnTipVisible();
        end
    end
--    table.sort(ret,FriendsData.sort_cmp);
    EventDispatcher.getInstance():dispatch(Event.Call,kFriend_UpdateFansList,ret);
end

FriendsData.getFollowListData = function(self)
    local isGetNum = true;
    if not self.m_follow_page_tab then
        self.m_follow_page_tab = {}
        local jsonStr = self:getString(GameCacheData.FRIEND_FOLLOW_PAGE_TAB..UserInfo.getInstance():getUid(),nil);
        if not jsonStr then 
            isGetNum = false;
            self:sendGetFollowListCmd();
            return nil;
        end
        local tab = json.decode(jsonStr);
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
--    table.sort(ret,FriendsData.sort_cmp);
    return ret;
end

FriendsData.getFansListData = function(self)
    local isGetNum = true;
    if not self.m_fans_page_tab then
        self.m_fans_page_tab = {}
        local jsonStr = self:getString(GameCacheData.FRIEND_FANS_PAGE_TAB..UserInfo.getInstance():getUid(),nil);
        if not jsonStr then 
            isGetNum = false;
            self:sendGetFansListCmd();
            return nil;
        end
        local tab = json.decode(jsonStr);
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
--    table.sort(ret,FriendsData.sort_cmp);
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

FriendsData.setIsNewFollow = function(self,uid,flag)
    if self.m_follow_page_tab and self.m_follow_page_tab[uid] then
        self.m_follow_page_tab[uid] = flag;
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
    Log.e("FriendsData.createNewChat---->"..json.encode(self.m_cache_chat_list));
    self.m_rcache_chat_list = {};
    for i,v in pairs(self.m_cache_chat_list) do
        if i and v and v.uid then
            self.m_rcache_chat_list[v.uid] = i;
        end;
    end
    self:saveChatList();
    return true;
end

FriendsData.getChatByUid = function(self,uid)
    if not self.m_rcache_chat_list[uid] then return end
    return self.m_cache_chat_list[self.m_rcache_chat_list[uid]];
end

FriendsData.getChatList = function(self)
    if #self.m_cache_chat_list == 0 then -- {uid=10000592 unReadNum=0 time=1488421643 last_msg="jjfjfj" }
        local chatList = self:getString(GameCacheData.FRIEND_CHAT_LIST..UserInfo.getInstance():getUid());
        return json.decode(chatList) or {};
    else
        for i = 1,#self.m_cache_chat_list do
            if self:isYourFriend(self.m_cache_chat_list[i].uid) == -1 then
                local chatList = self:getString(GameCacheData.FRIEND_CHAT_LIST..UserInfo.getInstance():getUid());
                return json.decode(chatList) or {};
            end;
        end;
    end
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
    if not tonumber(uid) then return {} end
    return json.decode(self:getString(GameCacheData.FRIEND_CHAT_DATA..tonumber(uid).."_"..UserInfo.getInstance():getUid(),nil)) or {};
end

FriendsData.getChatDataByNum = function(self,uid,num)
    if not tonumber(uid) then return end
    local jsonStr = self:getString(GameCacheData.FRIEND_CHAT_DATA..tonumber(uid).."_"..UserInfo.getInstance():getUid(),nil);
    if not jsonStr then return end;
    local tab = json.decode(jsonStr);
    local showMsg = {};
    if tab and #tab > num then
        for i = #tab, #tab -num+1,-1 do
            table.insert(showMsg,1,tab[i]);
        end;
        return showMsg;
    else 
        return tab;
    end;
end

-- 向上拉取历史消息使用，拉取指定时间消息
FriendsData.getChatDataByTime = function(self, uid, time)
    if not tonumber(uid) then return end
    local jsonStr = self:getString(GameCacheData.FRIEND_CHAT_DATA..tonumber(uid).."_"..UserInfo.getInstance():getUid(),nil);
    if not jsonStr then return end;
    local tab = json.decode(jsonStr);
    local showMsg = {};
    if tab and #tab > 0 then
        for i = #tab , 1, -1 do 
            if tab[i] and tab[i].time < time then
                table.insert(showMsg,1,tab[i]);
            end;
            if #showMsg == 15 or i == 1 then
                return showMsg;
            end;
        end;
    end;
    return;
end;


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
    if not uid or not msg then return end
    if not self.m_rcache_chat_list[uid] then
        self:createNewChat(uid);
    end
    local chatdata = self:getChatData(uid);
    if not chatdata then chatdata = {} end;
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
    if FriendsData.getInstance():isInBlacklist(data.send_uid) then return end
    if not self.m_rcache_chat_list[data.send_uid] then
        self:createNewChat(data.send_uid);
    end
    local chat = self:getChatByUid(data.send_uid);
    chat.unReadNum = chat.unReadNum + 1;
    local chatdata = self:getChatData(data.send_uid);
--    if not chatdata[#chatdata] then
        table.insert(chatdata,data);
        if #chatdata > 1000 then
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
        if v.uid then
            self.m_rcache_chat_list[v.uid] = i;
        end
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



function FriendsData:sendGetBlacklistCmd()
    local params = {}
    params.param = {}
    params.param.offset = 0
    params.param.limit  = 50
    HttpModule.getInstance():execute2(HttpModule.s_cmds.BlackListGetList,params,function(isSuccess,resultStr)
        if isSuccess then
            local data = json.decode(resultStr)
            if not data or data.error then 
                return
            end
            self:saveBlacklist(data.data.list)
        end
    end)
end

function FriendsData:saveBlacklist(list)
    list = list or {}
    self.m_cache_blacklist = self.m_cache_blacklist or {}
    local change = false
    if #self.m_cache_blacklist ~= #list then
        change = true
    else
        for i=1,#self.m_cache_blacklist do
            if not list[i] or tonumber(self.m_cache_blacklist[i].mid) ~= tonumber(list[i].mid) then
                change = true
                break
            end
        end
    end
    self.m_cache_blacklist = list
    if change then
        EventDispatcher.getInstance():dispatch(Event.Call,kFriend_BlacklistUpdate);
    end
    local uid = UserInfo.getInstance():getUid()
    self:saveString(GameCacheData.FRIEND_USER_BLACKLIST .. uid,json.encode(self.m_cache_blacklist));
end

function FriendsData:getBlacklist()
    if not self.m_cache_blacklist then
        local uid = UserInfo.getInstance():getUid()
        local str = self:getString(GameCacheData.FRIEND_USER_BLACKLIST .. uid,nil);
        local list = json.decode(str)
        if type(list) ~= "table" then 
            self:sendGetBlacklistCmd() 
        else
            self.m_cache_blacklist = list
        end
    end
    return self.m_cache_blacklist or {}
end

function FriendsData:isInBlacklist(uid)
    local list = self:getBlacklist()
    for i=1,#list do
        if tonumber(uid) == tonumber(list[i].mid) then
            return true
        end
    end
    return false
end

require("chess/data/endgateData")
--通过残局id获取残局名字
function FriendsData:getBoothgateNameByID(id_b,process)
    local datas=EndgateData:getInstance():getEndgateData()
    local latest_sort=tonumber(process) or 0
    local curGate=nil
    local endgateProgressStr = ""
    for _,gate in pairs(datas) do 
        if gate.tid == id_b then
            curGate = gate
            break
        end
    end
    if curGate then
        endgateProgressStr = curGate.title
        if latest_sort <= 1 then latest_sort = 1 end
        if latest_sort >= curGate.chessrecord_size then latest_sort = curGate.chessrecord_size end
        endgateProgressStr = string.format("%s 第%d关",endgateProgressStr,latest_sort)
    end
    return endgateProgressStr
end

--通过单机进度获取当前的单机关卡名
function FriendsData:getSingleGameNameByID(id_b,process)
    local level = tonumber(process) or 1
    if level < 1 then level = 1 end
    if level > #(User.CONSOLE_TITLE) then level =#(User.CONSOLE_TITLE) end
    return User.CONSOLE_TITLE[level]
end