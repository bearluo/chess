require("util/game_cache_data")
UserCacheData = class(GameCacheData,false);
UserCacheData.Cache_Time = 600;
UserCacheData.Status_Cache_Time = 10;

UserCacheData.getInstance = function()
    if not UserCacheData.instance then
        UserCacheData.instance = new(UserCacheData);
    end
    return UserCacheData.instance;
end

UserCacheData.ctor = function(self)
    self.m_dict = new(Dict,"UserCacheData");
	self.m_dict:load();

    self.m_userDataListeners = {};


    self.m_anim = AnimFactory.createAnimInt(kAnimLoop,0,1,1000);
    self.m_anim:setEvent(self,self.animEvent);
    self.m_anim:setDebugName("UserCacheData.anim");

    EventDispatcher.getInstance():register(HttpModule.s_event,self,self.onHttpRequestsCallBack);
end

function UserCacheData.registerUserData(self,uid,userDataListener)
    if self.m_userDataListeners[uid] == nil then
        self.m_userDataListeners[uid] = {};
    end
end
--[Comment]
-- php返回用户数据
function UserCacheData.onGetFriendUserInfo(self,isSuccess,message)
    if not isSuccess then return ;end
    local info = {};
    local data = message.data;
    for i,v in pairs(data) do
        local item = {};
        item.mid = tonumber(v.mid:get_value()) or 0;
        item.mnick = v.mnick:get_value() or "";
        item.mactivetime = v.mactivetime:get_value() or 0;
        item.iconType = v.iconType:get_value() or 0;
        item.score = tonumber(v.score:get_value()) or 0;
        item.money = tonumber(v.money:get_value()) or 0;
        item.drawtimes = tonumber(v.drawtimes:get_value()) or 0;
        item.wintimes = tonumber(v.wintimes:get_value()) or 0;
        item.losetimes = tonumber(v.losetimes:get_value()) or 0;
        item.icon_url = v.icon_url:get_value();
        item.rank = tonumber(v.rank:get_value()) or 0;
        item.sex = tonumber(v.sex:get_value()) or 0;
        item.fans_rank = tonumber(v.fans_rank:get_value()) or 0;
        item.is_vip = tonumber(v.is_vip:get_value());
        item.friends_num = tonumber(v.friends_num:get_value()) or 0;
        item.fans_num = tonumber(v.fans_num:get_value()) or 0;
        item.follows_num = tonumber(v.attention_num:get_value()) or 0;
        table.insert(info,item);
    end
    for i,value in ipairs(data) do
       if value then
          self.m_cache_user_data[value.mid] = value;
          if type(self.m_cache_user_data[value.mid]) == "table" then
              self.m_cache_user_data[value.mid].saveTime = os.time();
              self:saveString(GameCacheData.USER_CACHE_DATA_ .. value.mid,json.encode(self.m_cache_user_data[value.mid]));
          else
              self.m_cache_user_data[value.mid] = nil;
          end
       end
    end
end


UserCacheData.onHttpRequestsCallBack = function(self,command,...)
	Log.i("ChessController.onHttpRequestsCallBack");
	if self.s_httpRequestsCallBackFuncMap[command] then
     	self.s_httpRequestsCallBackFuncMap[command](self,...);
	end 
end


UserCacheData.s_httpRequestsCallBackFuncMap = {
    [HttpModule.s_cmds.getFriendUserInfo]      = UserCacheData.onGetFriendUserInfo;
}
