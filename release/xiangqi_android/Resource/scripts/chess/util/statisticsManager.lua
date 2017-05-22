--region *.lua
--Date 2016/5/27
--此文件由[BabeLua]插件自动生成
-- FordFan
--endregion

StatisticsManager = class();

StatisticsManager.s_gameType = 
{
    [2] = "console_room";
    [5] = "online_room";
    [8] = "endgame_room";
}

StatisticsManager.s_levelType = 
{
    [0] = nil;
    [201] = "primary";
    [202] = "middle";
    [203] = "master";

}

--StatisticsManager.s_invitePLayChess = 
--{
--    [1] = "qq";
--    [2] = "wechat";
--    [3] = "chat";
--}


--PHP统计的参数与友盟统计的参数不一样
StatisticsManager.SHARE_WAY_QQ = "qq";
StatisticsManager.SHARE_WAY_WECHAT = "wexin";
StatisticsManager.SHARE_WAY_PYQ = "wexin";
StatisticsManager.SHARE_WAY_SMS = "sms";
StatisticsManager.SHARE_WAY_WEIBO = "weibo";
StatisticsManager.SHARE_WAY_CHAT = "chat";

function StatisticsManager.getInstance()
    if not StatisticsManager.s_instance then
		StatisticsManager.s_instance = new(StatisticsManager);
	end
	return StatisticsManager.s_instance;
end

function StatisticsManager.releaseInstance()
	delete(StatisticsManager.s_instance);
	StatisticsManager.s_instance = nil;
end

function StatisticsManager:ctor()
    
    EventDispatcher.getInstance():register(Event.Call,self,self.onNativeCallDone);
end

function StatisticsManager:dtor()
    

end

--[[
    统计到友盟
    参数: event_id 事件id 
          param 自定义后缀（子参数）
--]]
function StatisticsManager:onCountToUM(event_id, param)
    if not event_id then return end
    local event_info = event_id
    if param then 
        event_info = event_id .. "," .. param
    else
        
    end
    sys_set_int("win32_console_color",10);
    print_string("on_event_stat = " .. event_info);
    sys_set_int("win32_console_color",9);

    dict_set_string(ON_EVENT_STAT , ON_EVENT_STAT .. kparmPostfix , event_info);
    call_native(ON_EVENT_STAT);
end

--[[
    统计到PHP
    参数: event_id 事件id 
          param 自定义后缀（子参数）
--]] 
function StatisticsManager:onCountToPHP(event,info)
    if not event or not info then return end

    sys_set_int("win32_console_color",10);
    print_string("on_event_stat = " .. event);
    sys_set_int("win32_console_color",9);

    local post_data = {}
    post_data.param = {}
    post_data.param.mid = UserInfo.getInstance():getUid();
    post_data.param.event = event;
    post_data.param.sub_event = info;
    HttpModule.getInstance():execute(HttpModule.s_cmds.countToPHP,post_data);
end

--[Comment]
--统计参数
StatisticsManager.NEW_USER_COUNT_LOGIN_PAGE = 1; -- 登录界面
StatisticsManager.NEW_USER_COUNT_GIFT_PAGE = 2; -- 礼物界面
StatisticsManager.NEW_USER_COUNT_INTRUCTION_PAGE =3; -- 新手提示界面
StatisticsManager.NEW_USER_COUNT_ONLINE_GAME = 4; -- 联网大厅
StatisticsManager.NEW_USER_COUNT_OFFLINE_GAME = 18; -- 单机
StatisticsManager.NEW_USER_COUNT_SYSTEM_ENDING = 19; -- 残局
StatisticsManager.NEW_USER_COUNT_GUIDANCE_PAGE = 7;  -- 新手引导
StatisticsManager.NEW_USER_COUNT_DAILY_SIGN= 8;-- 每日签到
StatisticsManager.NEW_USER_COUNT_EVALUATION= 9;-- 棋力测评
StatisticsManager.NEW_USER_COUNT_LEVEL= 10;-- 等级称号
StatisticsManager.NEW_USER_COUNT_DOUBLE_PROP= 11;-- 双倍积分
StatisticsManager.NEW_USER_COUNT_ONLINE_1= 12;-- 联网对局1局
StatisticsManager.NEW_USER_COUNT_ONLINE_2= 13;-- 联网对局2局
StatisticsManager.NEW_USER_COUNT_ONLINE_3= 14;-- 联网对局3局
StatisticsManager.NEW_USER_COUNT_ONLINE_4= 15;-- 联网对局4局
StatisticsManager.NEW_USER_COUNT_ONLINE_5= 16;-- 联网对局5局
StatisticsManager.NEW_USER_COUNT_ONLINE_6= 17;-- 联网对局5局以上


--[Comment]
-- 新用户界面跳转
-- HttpModule.s_cmds.UserUserBehaviorStatistic
function StatisticsManager:onNewUserCountToPHP(scene,isNew)
    if not scene or isNew ~= 1 then return end
    if not self.s_newUserEventUnique then
        self.s_newUserEventUnique = {}
    end
    if self.s_newUserEventUnique[scene] then return end
    self.s_newUserEventUnique[scene] = 1
    local post_data = {}
    post_data.scene = scene
    HttpModule.getInstance():execute(HttpModule.s_cmds.UserUserBehaviorStatistic,post_data);
end

--[Comment]
-- 新用户界面跳转
-- HttpModule.s_cmds.UserUserBehaviorStatistic
function StatisticsManager:onNewUserCountToPHPOnilnePlay(isNew)
    if isNew ~= 1 then return end
    self.mOnlinePlayCount = (self.mOnlinePlayCount or 0) + 1
    if self.mOnlinePlayCount < 6 then
        StatisticsManager.getInstance():onNewUserCountToPHP(StatisticsManager["NEW_USER_COUNT_ONLINE_"..self.mOnlinePlayCount],UserInfo.getInstance():getIsFirstLogin())
    else
        StatisticsManager.getInstance():onNewUserCountToPHP(StatisticsManager.NEW_USER_COUNT_ONLINE_6,UserInfo.getInstance():getIsFirstLogin())
    end
end

--[Comment]
--统计跳过新手引导
function StatisticsManager:onCountNewUserSkip(gameType)
    local event = "user_guide";
    local param = StatisticsManager.s_gameType[gameType];
    self:onCountToPHP(event,gameType);
end

--[Comment]
--统计快速开始 
function StatisticsManager:onCountQuickPlay(gotoRoom)
    local event = "quick_start";
    local roomLevel = tonumber(gotoRoom.level); 
    self:onCountToPHP(event,roomLevel);
end

--[Comment]
--统计邀请好友对战
function StatisticsManager:onCountInvitePlayChess(way)
    local event = "flight_invite";
    self:onCountToPHP(event,way);
end

--[Comment]
--统计分享好友邀请
function StatisticsManager:onCountInviteFriends(way)
    local event = "game_share";
    self:onCountToPHP(event,way);
end

--[Comment]
-- event : php 定义的类型
-- way   : 分享类型
function StatisticsManager:onCountShare(event,way)
    if not event or not way then return end
    self:onCountToPHP(event,way);
end

--[Comment]
--统计同屏模式
function StatisticsManager:onCountCustomBoard(way)
    local event = "put_chess";
    self:onCountToPHP(event,way);
end

