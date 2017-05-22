require("core/object");
require(MODEL_PATH.."room/board");
require(DATA_PATH.."gameData");
require(DATA_PATH.."endgateData");

User = class()

User.AI_TIPS = {
        "两军相争勇者胜",
        "寡士怯双车 士亏应兑车",
        "撑起羊角士 不怕马来将",
        "残棋炮归家",
        "炮进冷巷 难成风浪",
        "真假先手 辨清再走",
        "炮不轻发 马不躁进",
        "死子勿急吃",
        "棋输一步错 棋胜一步巧",
        "宁舍一子 勿失一先",
        "马路要活，车路要畅",
        "开局争先，危局搏杀",
        "马跳窝心，不死也昏",
        "临杀勿急",

};
User.AI_TITLE = {
    	"守关人：藤甲兵",
        "守关人：长戟兵",
        "守关人：丹阳勇士",
        "守关人：炮兵",
        "守关人：折冲彪骑",
	    "守关人：西凉铁骑",
        "守关人：铁戟巨盾",
        "守关人：刀盾前锋",
        "守关人：镇军将军",
        "守关人：车骑将军",
        "守关人：骠骑将军",
        "守关人：丞相",
        "守关人：大司马",
        "守关人：无敌战将",
};

User.AI_NAME = {
	    "藤甲兵",
        "长戟兵",
        "丹阳勇士",
        "炮兵",
        "折冲彪骑",
	    "西凉铁骑",
        "铁戟巨盾",
        "刀盾前锋",
        "镇军将军",
        "车骑将军",
        "骠骑将军",
        "丞相",
        "大司马",
        "无敌战将",
       
};

User.CONSOLE_TITLE = {
	    "初出茅庐",
        "小试牛刀",
        "崭露头角",
        "驰骋沙场",
        "骁勇善战",
	    "横扫千军",
        "运筹帷幄",
        "叱咤风云",
        "震古烁今",
        "问鼎中原",
        "无坚不摧",
        "威震四方",
        "所向无敌",
        "一统江湖",

};
-- 上传旧版棋谱用
User.CONSOLE_INDEX = {
	    ["初出茅庐"] = 1,
        ["小试牛刀"] = 2,
        ["崭露头角"] = 3,
        ["驰骋沙场"] = 4,
        ["骁勇善战"] = 5,
	    ["横扫千军"] = 6,
        ["运筹帷幄"] = 7,
        ["叱咤风云"] = 8,
        ["震古烁今"] = 9,
        ["问鼎中原"] = 10
};
-- 新版单机关卡人物
User.CONSOLE_BOSS = {
	    "console_boss_1",
        "console_boss_2",
        "console_boss_3",
        "console_boss_4",
        "console_boss_5",
	    "console_boss_6",
        "console_boss_7",
        "console_boss_8",
        "console_boss_9",
        "console_boss_10",
        "console_boss_11",
        "console_boss_12",
        "console_boss_13",
        "console_boss_14",
};

User.QILI_LEVEL = {
	    "一级",
        "二级",
        "三级",
        "四级",
        "五级",
	    "六级",
        "七级",
        "八级",
        "九级",
};

User.AI_MODEL = {
	    Board.MODE_RED, Board.MODE_RED, Board.MODE_BLACK, Board.MODE_BLACK, Board.MODE_BLACK,
	    Board.MODE_RED, Board.MODE_RED, Board.MODE_BLACK, Board.MODE_BLACK, Board.MODE_RED,
        Board.MODE_RED, Board.MODE_BLACK, Board.MODE_RED, Board.MODE_BLACK,
};

User.AI_LEVEL_DEFAULT = {
        1,1,2,2,3,
        4,3,4,5,6,
        7,6,7,7,
};
User.MAN_ICON = "userinfo/man_head01.png";
User.WOMAN_ICON = "userinfo/women_head01.png";
User.ICON = "user_icon";
User.UP_ICON = "up_icon";
User.DOWN_ICON = "down_icon";

User.NAME_LEN = 12;


User.ctor = function(self)

	self.m_uid = 0;         --用户ID
	self.m_seatID = 0;    --座位ID
	self.m_name = 0;     --用户昵称
	self.m_score = 0;       --经验值
	self.m_level = 0;       --等级
	self.m_point = 0;     --最后得分
	self.m_vip = 0;        --是否为vip 是否会员 ，1 是 0否
	self.m_sex = 0;        --性别 性别 0 未知 1 男 2 女
	self.m_money = 0;        --游戏币
	self.m_wintimes = 0;   --赢的次数
	self.m_losetimes = 0;   --输的次数
	self.m_drawtimes = 0;   --和的次数
    self.m_isFirst = 0;   --是否是新注册用户
	self.m_title = 0;    --头衔
    self.m_status = 0;    --用户状态  0 未登录  1已登录 2入座 3等待开局   3正在对弈 4 结束对弈
	self.m_flag = 0;      --红黑标志   1红方、2黑方
	self.m_source = 3;    --用户来源 1-Flash  2-IPhone  3-Andrio  4-iPad
	self.m_sitemid = 0;      --用户平台ID
	self.m_platurl = "null";      --用户平台链接
	self.m_rank = 0;            --用户排名  -1则为得不到当前排名
	self.m_auth = 0;           --1 个人加V 2 非个人加V 3 达人 0 没有身份 -1 没有身份

	self.m_big = "";           --大头像
	self.m_icon = "";         --头像

	self.m_timeout1 = 0;
	self.m_timeout2 = 0;
	self.m_timeout3 = 0;

	self.m_coin = 0;             --每盘棋输赢的Money
	self.m_taxes = 0;            --每盘棋的棋桌费

	self.m_bccoins = 0;          --元宝数量


	self.m_start_btn_visible = false;   --玩家的开始按钮是否可见
	self.m_ready_img_visible = false;   --玩家的准备图标是否可见
end

User.dtor = function(self)
	
end

---------------------------设置用户的属性值---------------------
--------------注意  ： 属性的类型检查 及 值的范围---------------
User.setUid = function(self,uid)
	self.m_uid = tonumber(uid);
end
User.getUid = function(self)
	return self.m_uid or 0;
end

User.setSeatID = function(self,seatID)
	self.m_seatID = tonumber(seatID);
end
User.getSeatID = function(self)
	return self.m_seatID or 0;
end

User.setName = function(self,name)
	self.m_name = name;
end

User.getName = function(self)
    return self.m_name or "博雅象棋";
--	if self.m_name then
--		local len = string.len(self.m_name);
--		if len > 12  then
--			local lenutf8 = string.lenutf8(self.m_name);
--			print_string("User.getName " .. len);
--			if lenutf8 == len then
--				return string.subutf8(self.m_name,1,8) .. "...";  --英文
--			elseif lenutf8 <= 4 then                              --中文
--				return string.subutf8(self.m_name,1,4);
--			else
--				return string.subutf8(self.m_name,1,4) .. "...";  --中间值
--			end
--		else
--			return len == 0 and "博雅象棋" or self.m_name;
--		end
--	else
--		return "博雅象棋";
--	end
	-- return (self.m_name == nil or self.m_name == "") and  or string.sub(self.m_name,1,8);
end

User.setScore = function(self,score)
	self.m_score = tonumber(score);
end

User.getScore = function(self)
	return self.m_score or 0;
end

User.setLevel = function(self,level)
	self.m_level = tonumber(level);
end
User.getLevel = function(self)
	return self.m_level or 1;
end

User.setPoint = function(self,point)
	self.m_point = point;
end
User.getPoint = function(self)
	if self.m_point and self.m_point > 0 then
		return "+" .. self.m_point;
	end

	return self.m_point or 0;
end

User.setVip = function(self,vip)
	self.m_vip = vip;
--	self.m_vip = 0;
end

User.getVip = function(self)
	return self.m_vip or 0;
end

User.setSex = function(self,sex)
	self.m_sex = tonumber(sex);
end

User.getSex = function(self)
	return self.m_sex or 0;
end
----性别 性别 0 未知 1 男 2 女
User.getSexString = function(self)
 	if self.m_sex == 1 then
 		return "男";
 	elseif self.m_sex == 2 then
 		return "女";
 	else
 		return "保密";
 	end
end

User.setMoney = function(self,money)
	self.m_money = tonumber(money);
    if RoomProxy.getInstance():checkCanJoinRoom(RoomConfig.ROOM_TYPE_NOVICE_ROOM,self.m_money ) then
        UserInfo.getInstance():setShowBankruptStatus(true);
    end
end

User.getMoney = function(self)
	return self.m_money or 0;
end

User.getMoneyStr = function(self)
	return ToolKit.getMoneyStr(self.m_money) or 0;
end

User.setWintimes = function(self,wintimes)
	self.m_wintimes = tonumber(wintimes);
end
User.getWintimes = function(self)
	return self.m_wintimes or 0;
end

User.setLosetimes = function(self,losetimes)
	self.m_losetimes = tonumber(losetimes);
end
User.getLosetimes = function(self)
	return self.m_losetimes or 0;
end

-- 连胜次数
User.setContinueWintimes = function(self, times)
    self.m_continue_times = times;
end;

User.getContinueWintimes = function(self)
    return self.m_continue_times or 0;
end;

User.setDrawtimes = function(self,drawtimes)
	self.m_drawtimes = tonumber(drawtimes);
end
User.getDrawtimes = function(self)
	return self.m_drawtimes or 0;
end

User.setRegisterTime = function(self,time)
	self.m_register_time = tonumber(time);
end
User.getRegisterTime = function(self)
	return self.m_register_time or 0;
end

User.setCurrentWintimes = function(self,wintimes)
	self.m_current_wintimes = tonumber(wintimes);
end
User.getCurrentWintimes = function(self)
	return self.m_current_wintimes or 0;
end

User.setCurrentLosetimes = function(self,losetimes)
	self.m_current_losetimes = tonumber(losetimes);
end
User.getCurrentLosetimes = function(self)
	return self.m_current_losetimes or 0;
end

User.setCurrentDrawtimes = function(self,drawtimes)
	self.m_current_drawtimes = tonumber(drawtimes);
end
User.getCurrentDrawtimes = function(self)
	return self.m_current_drawtimes or 0;
end

User.setPrevWintimes = function(self,wintimes)
	self.m_prev_wintimes = tonumber(wintimes);
end
User.getPrevWintimes = function(self)
	return self.m_prev_wintimes or 0;
end

User.setPrevLosetimes = function(self,losetimes)
	self.m_prev_losetimes = tonumber(losetimes);
end
User.getPrevLosetimes = function(self)
	return self.m_prev_losetimes or 0;
end

User.setPrevDrawtimes = function(self,drawtimes)
	self.m_prev_drawtimes = tonumber(drawtimes);
end
User.getPrevDrawtimes = function(self)
	return self.m_prev_drawtimes or 0;
end


-- 是否是新注册用户
User.setIsFirstLogin = function(self,isFirst)
	self.m_isFirst = isFirst;
end
User.getIsFirstLogin = function(self)
	return self.m_isFirst or 0;
end


User.getRate = function(self)
	local total = self.m_losetimes + self.m_wintimes;
	local rate = total <= 0 and 0 or self.m_wintimes*100/total;
	return string.format("%.2f%%",rate);
end

User.getRateNum = function(self)
	local total = self.m_losetimes + self.m_wintimes;
	local rate = total <= 0 and 0 or self.m_wintimes/total;
	return rate;
end

User.getGrade = function(self)
	local grade = string.format("%d胜/%d败/%d和",self.m_wintimes,self.m_losetimes,self.m_drawtimes);
	return grade;
end

User.getCurrentRate = function(self)
	local total = self:getCurrentLosetimes() + self:getCurrentWintimes();
	local rate = total <= 0 and 0 or self:getCurrentWintimes()*100/total;
	return string.format("%.2f%%",rate);
end

User.getCurrentRateNum = function(self)
	local total = self:getCurrentLosetimes() + self:getCurrentWintimes();
	local rate = total <= 0 and 0 or self:getCurrentWintimes()/total;
	return rate;
end

User.getPrevRate = function(self)
	local total = self:getPrevLosetimes() + self:getPrevWintimes();
	local rate = total <= 0 and 0 or self:getPrevWintimes()*100/total;
	return string.format("%.2f%%",rate);
end

User.getPrevRateNum = function(self)
	local total = self:getPrevLosetimes() + self:getPrevWintimes();
	local rate = total <= 0 and 0 or self:getPrevWintimes()/total;
	return rate;
end


User.setTitle = function(self,title)
	self.m_title = title;
end

User.getTitle = function(self)
	return self.m_title or "...";
end

User.setStatus = function(self,status)
	self.m_status = tonumber(status);   --用户状态  0 未登录  1已登录 2入座 3等待开局   3正在对弈 4 结束对弈
	self.m_start_btn_visible = (self.m_status <= STATUS_PLAYER_COMING or self.m_status >= STATUS_PLAYER_OVER);
	self.m_ready_img_visible = (self.m_status == STATUS_PLAYER_RSTART);
end
User.getStatus = function(self)
	return self.m_status or 0;
end

User.setFlag = function(self,flag)
	self.m_flag = tonumber(flag);
end
User.getFlag = function(self)
	return self.m_flag or 0;
end

User.setSource = function(self,source)
	self.m_source = tonumber(source);
end
User.getSource = function(self)
	return self.m_source or 3;
end
--用户来源 1-Flash  2-IPhone  3-Andrio  4-iPad
User.getSourceString = function(self)  
	if self.m_source == 1 then
		return "(Flash)";
	elseif self.m_source == 2 then
		return "(IPhone)";
	elseif self.m_source == 3 then
		return "(Andriod)";
	elseif self.m_source == 4 then
		return "(iPad)";
	elseif self.m_source == 10 then
		return "(IPhone)";
	else
		return "(未知)"
	end
end

User.setSitemid = function(self,sitemid)
	self.m_sitemid = sitemid;
end

User.getSitemid = function(self)
	return self.m_sitemid or 0;
end

User.setPlaturl = function(self,platurl)
	self.m_platurl = platurl;
end
User.getPlaturl = function(self)
	return self.m_platurl or "nil";
end

User.setRank = function(self,rank)
	self.m_rank = tonumber(rank);
end
User.getRank = function(self)
	if self.m_rank and self.m_rank <= 0 then
		return "...";
	end
	return self.m_rank or "...";
end
--返回用户的数字形式，有Socket接口需要。
User.getRankNum = function(self)
	local rank = tonumber(self.m_rank) or -1;
	return rank;
end

User.setAuth = function(self,auth)
	self.m_auth = auth;
end
User.getAuth = function(self)
	return self.m_auth or 0;
end

User.setBig = function(self,big)
	self.m_big = big;
end
User.getBig = function(self)
	return m_big or "";
end

User.setIcon = function ( self,icon ,uid)
    Log.i("setIcon icon:"..icon.." uid"..uid);
    if icon == "" then 
        self.m_iconType = 0;
        return     
    end;
    if tonumber(icon) then
        self.m_iconType = tonumber(icon);
        return;
    end;
    self.m_iconType = -1;
	self.m_icon = icon;
end

User.setIconType = function ( self,iconType)
	self.m_iconType = tonumber(iconType);
end

User.getIconType = function ( self)
	return self.m_iconType or 0;
end

User.getIcon = function(self)
	return self.m_icon or "";
end



User.setIconFile = function ( self,url,iconFile )	
	-- GameCacheData.getInstance():saveString("uidicon" .. self:getUid(),url);
	self.m_iconFile = iconFile;
end
--暂时不用判断性别设置头像
User.getIconFile = function(self)
	if not self.m_iconFile then
        if self.m_iconType and self.m_iconType > 0 then
            return UserInfo.DEFAULT_ICON[self.m_iconType] or UserInfo.DEFAULT_ICON[1];
        end
		if self:getSex() == 1 then
			return UserInfo.DEFAULT_ICON[1]; --User.MAN_ICON;
		else
			return UserInfo.DEFAULT_ICON[1]; --User.WOMAN_ICON;
		end
	end
	return self.m_iconFile or "";
end

--局时是否超时
User.isTimeout = function(self)
	return self.m_timeout or false;
end

User.setTimeout1 = function(self,timeout1)
	self.m_timeout1 = timeout1;

	--局时超了
	if self.m_timeout1 <= 0 then
		self.m_timeout = true;
	else
		self.m_timeout = false;
	end

end
User.getTimeout1 = function(self)
	if self.m_timeout1 <= 0 then
		return "00:00";
	end
	local min = math.floor(self.m_timeout1/60);
	local sec = self.m_timeout1%60;
    if string.len(min) == 1 then
        min = "0" .. min;
    end
    if string.len(sec) == 1 then
        sec = "0" .. sec;
    end
	return min .. ":" .. sec;
end
User.timeout1__ = function(self)
	self.m_timeout1 = self.m_timeout1 -1;
	
	--局时超了
	-- if self.m_timeout1 <= 0 then
	-- 	self.m_timeout = true;
	-- end
end

User.setTimeout2 = function(self,timeout2)
	self.m_timeout2 = timeout2;
end
User.getTimeout2 = function(self)
	if self.m_timeout then
		return self:getTimeout3();
	end


	if self.m_timeout2 <= 0 then
		return "00:00";
	end
	local min = math.floor(self.m_timeout2/60);
	local sec = self.m_timeout2%60;
    if string.len(min) == 1 then
        min = "0" .. min;
    end
    if string.len(sec) == 1 then
        sec = "0" .. sec;
    end
	return min .. ":" .. sec,self.m_timeout2;
end
User.timeout2__ = function(self)
	self.m_timeout2 = self.m_timeout2 -1;
end


User.setTimeout3 = function(self,timeout3)
	self.m_timeout3 = timeout3;
end
User.getTimeout3 = function(self)
	if self.m_timeout3 <= 0 then
		return "00:00";
	end
	local min = math.floor(self.m_timeout3/60);
	local sec = self.m_timeout3%60;
    if string.len(min) == 1 then
        min = "0" .. min;
    end
    if string.len(sec) == 1 then
        sec = "0" .. sec;
    end
	return min .. ":" .. sec,self.m_timeout3;
end
User.timeout3__ = function(self)
	self.m_timeout3 = self.m_timeout3 -1;
end

--每局结束输赢多少钱
User.setCoin = function(self,coin)
	self.m_coin = coin;
end
User.getCoin = function(self)

	if self.m_coin and self.m_coin > 0 then
		return "+" .. self.m_coin;
	end

	return self.m_coin or 0;
end

--每局结束台费扣除
User.setTabCoin = function(self,coin)
	self.m_tab_coin = coin;
end

User.getTabCoin = function(self)
	return self.m_tab_coin or 0;
end


-- 设置奖杯
User.setCup = function(self, cup)
    self.m_cup = cup;
end;

User.getCup = function(self)
    return self.m_cup or 0;
end;

User.setTaxes = function(self,taxes)
	self.m_taxes = taxes;
end
User.getTaxes = function(self)
	return self.m_taxes;
end

--博雅币   元宝
User.setBccoin = function(self,bccoin)
	self.m_bccoins = tonumber(bccoin) or 0;
end
User.getBccoin = function(self)
	return self.m_bccoins or 0;
end

User.getStartVisible = function(self)
	return self.m_start_btn_visible or false;
end
User.getReadyVisible = function(self)
	return self.m_ready_img_visible or false;
end

User.setVersion = function(self,version)
	self.m_version = version;
end
User.getVersion = function(self)
	return self.m_version or "...";
end

User.setClient_version = function(self,version)
	self.m_client_version = tonumber(version or 0);
end
User.getClient_version = function(self)
	return self.m_client_version or 0;
end

User.setAIIcon = function(self,file)
    self.m_aiIcom = file;
end

User.getAIIcon = function(self)
    return self.m_aiIcom or "";
end

User.loadIcon = function(self,image_name,url)
end

User.loadIcon1 = function(self,what,url)

	if not url or url == "" then return end
    Log.i("getCacheImageManager url:"..url);
    local info = {};
    info.ImageUrl = url;
    info.ImageName = md5_string(url);
    info.what = what or "unknow";
    
    if UserInfo.s_cacheImage[info.ImageName..".png"] then
        return info.ImageName..".png";
    end

    dict_set_string(kCacheImageManager,kCacheImageManager..kparmPostfix,json.encode(info));
	call_native(kCacheImageManager);
end

User.getUserSet = function(self)
    return self.m_mySet or {};
end

User.setUserSet = function(self,my_set)
    local info = {};
    if type(my_set) ~= "table" then 
        info.picture_frame = "sys";
        info.piece = "sys";
        info.board = "sys";
    else
        info.picture_frame = my_set.picture_frame or "sys";
        info.piece = my_set.piece or "sys";
        info.board = my_set.board or "sys";
    end
    self.m_mySet = info;
end
----------------------------------------------------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--用户具体的信息
UserInfo = class(User);

UserInfo.ICON = "userinfo_icon";
UserInfo.DEFAULT = "default_icon";
UserInfo.DEFAULT_NUM = string.len(UserInfo.DEFAULT) + 1;
UserInfo.DEFAULT_ICON = {
                            -- 系统自带
                            "userinfo/women_head01.png","userinfo/man_head02.png","userinfo/man_head01.png","userinfo/women_head02.png",
                            -- 单机获得
                            "console/console_head_1.png","console/console_head_2.png","console/console_head_3.png","console/console_head_4.png","console/console_head_5.png",
                            "console/console_head_6.png","console/console_head_7.png","console/console_head_8.png","console/console_head_9.png","console/console_head_10.png",
                            "console/console_head_11.png","console/console_head_12.png","console/console_head_13.png","console/console_head_14.png",
                            -- others

                        };
-- 上传php使用
UserInfo.DEFAULT_ICONNAME = {                     
                                -- 系统自带
                                "women_head01.png","man_head02.png","man_head01.png","women_head02.png",
                                -- 单机获得
                                "console_head_1.png","console_head_2.png","console_head_3.png","console_head_4.png","console_head_5.png",
                                "console_head_6.png","console_head_7.png","console_head_8.png","console_head_9.png","console_head_10.png",
                                "console_head_11.png","console_head_12.png","console_head_13.png","console_head_14.png",
                            };

UserInfo.getInstance = function ()
	if not UserInfo.s_instance then
		UserInfo.s_instance = new(UserInfo);
	end
	return UserInfo.s_instance;
end

UserInfo.releaseInstance = function()
	delete(UserInfo.s_instance);
	UserInfo.s_instance = nil;
end


UserInfo.setUid = function(self,uid)
	self.m_uid = tonumber(uid);
	GameCacheData.getInstance():saveInt(GameCacheData.ENDGAME_UID,self.m_uid);
end

UserInfo.getUid = function(self)
    if not self:isLogin() then return 0 end
	if not self.m_uid or self.m_uid == 0 then
		self.m_uid = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_UID,0);
		print_string("UserInfo.getUid uid = " .. self.m_uid);
	end
	return self.m_uid;
end
--[Comment]
-- 离线uid 登录不成功的时候 使用上一次登录成功的uid
UserInfo.getOfflineUid = function(self)
	if not self.m_uid or self.m_uid == 0 then
		self.m_uid = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_UID,0);
		print_string("UserInfo.getUid uid = " .. self.m_uid);
	end
	return self.m_uid;
end

UserInfo.ctor = function (self)
	self.m_svid = 0;
	self.m_serverDomain = "";   --非天梯IP
	self.m_serverPort = 0;
	self.m_LadderServerDomain  = "";  --天梯IP
	self.m_LadderServerPort = 0;
	self.m_ltid = 0 ;   --天梯给我匹配的房间ID 进房间的时候要用
	self.m_usertype = 0;

	self.m_roomDomain = "";
	self.m_roomPort = 0;
	self.m_is_custom_room = false;
    self.ailevelmap = {};
end


UserInfo.login = function(self,data)
	local aUser = data.aUser;
	if not aUser then 
		return
	end
    self:setOpenWeixinShare(aUser.open_weixin_share:get_value()); -- 微信分享开关
    --设置帐号类型
    self:setLogin(true);
    self:setNewUUID(aUser.new_uuid:get_value()) -- 游客登录为nil
    self:setAccountType(tonumber(aUser.account_type:get_value()));
    self:setUpdateFirstLogin(tonumber(aUser.versions_update:get_value()));
    --设置游戏分享qr_code_url 和 qr_code_icon
    self:setGameShareUrl(aUser.game_share_url.qr_code:get_value(),aUser.game_share_url.download_url:get_value());
    PhpConfig.h5_developUrl = aUser.game_share_url.replay_url:get_value() or PhpConfig.h5_developUrl;
    self:setInviteFriendsUrl(aUser.game_share_url.invite_url:get_value());
    self:setShareEndgateUrl(aUser.game_share_url.h5_share_url:get_value());
    self:setQQGroup(aUser.qq_group);
	self:setUid(aUser.mid:get_value());   	--print_string("userinfo:" .. self:getUid());
	self:setName(aUser.mnick:get_value());
	self:setLevel(aUser.level:get_value());
	self:setVip(aUser.vip:get_value());
	self:setSex(aUser.sex:get_value());
	self:setHometown(aUser.hometown:get_value());
    self:setCityCode(aUser.city_code:get_value());
    self:setCityName(aUser.province_name:get_value());
    self:setProvinceCode(aUser.province_code:get_value());
    self:setProvinceName(aUser.province_name:get_value());
	self:setMoney(aUser.money:get_value());
	self:setBccoin(aUser.bccoins:get_value());
	self:setScore(aUser.score:get_value());
	self:setWintimes(aUser.wintimes:get_value());
	self:setLosetimes(aUser.losetimes:get_value());
	self:setDrawtimes(aUser.drawtimes:get_value());
    self:setRegisterTime(aUser.mtime:get_value());
	self:setPrevWintimes(aUser.prev_month_combat_gains.wintimes:get_value());
	self:setPrevLosetimes(aUser.prev_month_combat_gains.losetimes:get_value());
	self:setPrevDrawtimes(aUser.prev_month_combat_gains.drawtimes:get_value());

	self:setCurrentWintimes(aUser.current_month_combat_gains.wintimes:get_value());
	self:setCurrentLosetimes(aUser.current_month_combat_gains.losetimes:get_value());
	self:setCurrentDrawtimes(aUser.current_month_combat_gains.drawtimes:get_value());

    self:setIsFirstLogin(aUser.isFirst:get_value());
    RoomProxy.getInstance():setTid(aUser.tid:get_value());
    self:setIconType(tonumber(aUser.iconType:get_value()));
    self:setIcon(aUser.big:get_value());--从php拉 大/中等大小 的图
    self:setTitle(aUser.designation:get_value());
	self:setSitemid(aUser.sitemid:get_value());
	self:setRank(aUser.rank:get_value()); 
    self:setDanGrading(aUser.dan_grading);
    self:setBindAccount(aUser.bind_account);
    self:setLoginTimes(tonumber(aUser.mentercount:get_value())); -- 登陆次数

    self:setPropInfo(aUser.prop_info); -- :get_value()
--    self:setChatRoomList(aUser.chat_room); --房间配置信息
    self:setFPcostMoney(aUser.sys_cost_money); -- 复盘要花费的(收藏，复制收藏，评论)金币
    self:setIsVip(tonumber(aUser.is_vip:get_value()));
    self:setVipTime(aUser.viptime:get_value());
    self:setTodayFirstLogin(tonumber(aUser.todayFirst:get_value()));
    self:setMactivetime(tonumber(aUser.mactivetime:get_value()));
    self:setShowBankruptStatus(true);
    self:setUserMySet(aUser.my_set:get_value());
    self:setNewPropInfo(aUser.new_prop_info); --:get_value());
    self:setIsReflowUser(aUser.is_reflow_user:get_value());
    self:setSignAture(aUser.signature:get_value())
    self:setUserSociatyData(aUser.guild);
    if aUser.gift:get_value() then
        self:setGift(aUser.gift);
    else
        self:setGift();
    end
    -- 收藏评论

    --局时默认配置
    self:setGameTimeInfo(aUser.chess_game_time);

    --大厅ip和port
    ServerConfig.getInstance():setHallIpPort(aUser.LadderServerDomain:get_value(), aUser.LadderServerPort:get_value());


	self:setUsertype(tonumber(aUser.usertype:get_value()));

    self:setAILevelMap(aUser.ai_level_map);

	self:setActionSwitch(aUser.actionOpen:get_value());
	self:setActionDailyAid(aUser.actionDailyAid:get_value());

    RoomConfig.getInstance():saveRoomConfig(json.analyzeJsonNode(aUser.roomConfig));
	RoomConfig.getInstance():setFreedomRoomTimeConfig(aUser.freedomRoomConfig);

	self:setWebBoothUrl(aUser.share_url:get_value());  --残局分享地址

	PhpConfig.setMtkey(aUser.mtkey:get_value());
	PhpConfig.setMid(aUser.mid:get_value());
    PhpConfig.setAccessToken(aUser.access_token:get_value());
    PhpConfig.setLogUrl(aUser.game_share_url.log_url:get_value());
    local tab = {PhpConfig.getLogUrl(),"Index.userBehavior"};
    HttpModule.getInstance():updateConfig(HttpModule.s_cmds.countToPHP,tab);

	self:setPhoneNo(aUser.phoneNo:get_value()); 
	self:setPromptNum(tonumber(aUser.prompt_num:get_value())); 
	self:setInviteUrl(aUser.invite_url:get_value()); 

	self:setBcPayConfig(aUser.bcPayConfig.mGoodID:get_value(),aUser.bcPayConfig.tGoodID:get_value(),aUser.bcPayConfig.rGoodID:get_value());

	self:setShowBindTips(aUser.isShowBinding:get_value());

	if aUser.saveChessManual and aUser.saveChessManual:get_value() then
		self:setDapuEnable(aUser.saveChessManual:get_value());
	end
    -- 本地保存棋谱上限
	if aUser.saveChessManualLimit and aUser.saveChessManualLimit:get_value() then
		self:setSaveChessLimit(aUser.saveChessManualLimit:get_value());
	end
    -- 自动保存棋谱上限
    if aUser.autoSaveChessManualMax and aUser.autoSaveChessManualMax:get_value() then
		self:setSaveChessManualLimit(aUser.autoSaveChessManualMax:get_value());
	end
	kEndgateData:setWinEndGateGetSoulRate(tonumber(aUser.soulRate.booth_new:get_value()));  --残局
	self:setPassConsoleLayerGetSoulRate(tonumber(aUser.soulRate.alone_big:get_value()));  --单机大关卡	
	self:setWinConsoleGetSoulRate(tonumber(aUser.soulRate.alone_ssu:get_value()));  --单机小关卡


	self:setSoulCount(tonumber(aUser.soul:get_value()));  --棋魂数量=

--    self:setPromptAutofeedtime(tonumber(aUser.prompt_autofeedtime:get_value()));


	self:setPaySid(aUser.payKeys.SID:get_value())
	self:setAppid(aUser.payKeys.APPID:get_value()); 
    if kPlatform == kPlatformIOS then	
        self:setIosAuditStatus(aUser.ios_audit_status:get_value());
        self:setCanShowIOSAppstoreReview(aUser.ioscore:get_value());
    end;
    local isOpenEnthralment  = aUser.enthralment.isOpenEnthralment:get_value();
    local enthralmentStatus  = aUser.enthralment.enthralmentStatus:get_value();

	UserInfo.getInstance():setIsOpenEnthralment(isOpenEnthralment);
	UserInfo.getInstance():setEnthralmentStatus(enthralmentStatus);
    UserInfo.getInstance():setAdsStatus(aUser.mobileAdsButton:get_value(), aUser.mobileAdsScreen:get_value());

    GameData.getInstance():setH5Url(aUser.circle_url:get_value());
	self.m_login = true;
    self.isCustomRoom = false;

    --- 新道具使用 上传 ---
    if ( tonumber(aUser.prop_is_upload:get_value()) == 0 ) then
        local post_data = {};
        post_data.mid = UserInfo.getInstance():getUid();
		local propinfo = {};
		local uid = UserInfo.getInstance():getUid();
		propinfo["1"] = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LIFE_NUM .. uid,ENDING_LIFE_NUM);
		propinfo["2"]= GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_UNDO_NUM .. uid,ENDING_UNDO_NUM);
		propinfo["3"] = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_REVIVE_NUM .. uid,ENDING_TIPS_NUM);
		propinfo["4"]= GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_TIPS_NUM .. uid,ENDING_REVIVE_NUM);
		propinfo["5"] = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LIFE_LIMIT .. uid,ENDING_LIFELIMIT_NUM);
		post_data.prop_info = propinfo;
        local user = UserInfo.getInstance(); -- 第一次把老版本数据转正
        user:setLifeNum(propinfo["1"] or 0);
        user:setUndoNum(propinfo["2"] or 0);
        user:setTipsNum(propinfo["3"] or 0);
        user:setReviveNum(propinfo["4"] or 0);
        user:setLifeLimitNum(propinfo["5"] or 0);
        HttpModule.getInstance():execute(HttpModule.s_cmds.goodsUploadProp,post_data);
    else
        local propinfo = json.decode_node(aUser.prop_info:get_value());
        local user = UserInfo.getInstance();
        user:setLifeNum(propinfo["1"]:get_value() or 0);
        user:setUndoNum(propinfo["2"]:get_value() or 0);
        user:setTipsNum(propinfo["3"]:get_value() or 0);
        user:setReviveNum(propinfo["4"]:get_value() or 0);
        user:setLifeLimitNum(propinfo["5"]:get_value() or 0);
    end
    if aUser.new_uuid:get_value() then
        UserInfo.getInstance():insertCacheAcountList(aUser.new_uuid:get_value(),tonumber(aUser.mid:get_value()));
    end
    UserInfo.getInstance():updateAcountList();
    -- 封号(1,封号状态 10,正常状态)
    self:setUserStatus(tonumber(aUser.mstatus:get_value()));
    self:setUserFreezTime(tonumber(aUser.freeze_time:get_value()));
    self:setUserFreezEndTime(tonumber(aUser.freeze_end_time:get_value()));
    self:setIsModifyUserMnick(aUser.enable_modify_nick:get_value());
    self:setModifyUserMnickCost(aUser.nick_bccoins:get_value())
    self:setModifyGuildMnickCost(aUser.guild_bccoins:get_value())
    
    self.mIsHasEvaluation = tonumber(aUser.valuate:get_value()) or 1

    if tonumber(aUser.isFirst:get_value()) == 1 then
        local headImg = self:getUploadThridHeadImg()
        if headImg and headImg ~= "" then
            local post_data = {};
	        post_data.ImageName = kUpLoadImage2;
	        post_data.ImageUrl = headImg;
	        local dataStr = json.encode(post_data);
	        dict_set_string(kDownLoadImage,kDownLoadImage..kparmPostfix,dataStr);
	        call_native(kDownLoadImage);
        end
    end
    if self:getIsReflowUser() == 1 then
        self:setComeBackRewardNum(aUser.comeback_reward_Num.money:get_value());
        else self:setComeBackRewardNum(aUser.comeback_reward_Num:get_value());
        end
    -- 清理参数
    self:setUploadThridHeadImg()
    self:setLockCompete(aUser.play_limit_config.match_lock:get_value())
    self:setLockRoomChat(aUser.play_limit_config.chat_lock:get_value())

end

-- 客户端生成唯一标识
UserInfo.setNewUUID = function(self, newUUID)
    self.mNewUUID = newUUID;
end

UserInfo.getNewUUID = function(self, newUUID)
    return self.mNewUUID;
end


-- 用户状态（1,封号状态 10,正常状态）
UserInfo.setUserStatus = function(self, status)
    self.m_user_status = status;
--    self.m_user_status = 1;
end

UserInfo.getUserStatus = function(self)
    return self.m_user_status  or 10;
end;

-- 封号截至时间
UserInfo.setUserFreezEndTime = function(self, time)
    self.m_user_freeze_end_time = time;
end;

UserInfo.getUserFreezEndTime = function(self)
    return self.m_user_freeze_end_time  or 0;
end;

-- 封号开始时间
UserInfo.setUserFreezTime = function(self, time)
    self.m_user_freeze_time = time;
end;

UserInfo.getUserFreezTime = function(self)
    return self.m_user_freeze_time  or 0;
end;

-- 封号类型  1:作弊 2：广告 3：脏话 4：自定义
UserInfo.setUserFreezeType = function(self,kind)
    self.m_user_freeze_kind = kind;
end

UserInfo.getUserFreezeType = function(self)
    return tonumber(self.m_user_freeze_kind);
end

-- 封号提示文案
UserInfo.setFreezeTypeText = function (self,text)
    self.m_user_freeze_kindText = text;
end

UserInfo.getFreezeTypeText = function (self)
    return self.m_user_freeze_kindText;
end
-- 是否封号
require("dialog/chioce_dialog");
UserInfo.isFreezeUser = function(self)
    if self:getUserStatus() ~= 10 then
        local info = {};
        info.mid = UserInfo.getInstance():getUid();
        HttpModule.getInstance():execute(HttpModule.s_cmds.getUserFreezeType,info);
        return true;
    else
        return false;
    end;
end;

UserInfo.showFreezeDialog = function (self)
    local tip_msg;
    if self.m_user_freeze_end_time ~= 0 and self.m_user_freeze_time ~= 0 then
        if self.m_user_freeze_time < 365 * 24 * 60 * 60 then
            if self:getUserFreezeType() == 1 then 
                tip_msg = "很抱歉，您的账号有作弊现象，经核实已被冻结，将于"..os.date("%Y-%m-%d %H:%M",self.m_user_freeze_end_time) .."解封，期间无法进行游戏操作，如有疑问，请联系客服。"
            elseif self:getUserFreezeType() == 2 then
                tip_msg = "很抱歉，您的账号多次涉及违规广告，经核实已被冻结，将于"..os.date("%Y-%m-%d %H:%M",self.m_user_freeze_end_time) .."解封，期间无法进行游戏操作，如有疑问，请联系客服。"
            elseif self:getUserFreezeType() == 3 then 
                tip_msg = "很抱歉，您的账号多次涉及非法或不雅语言，经核实已被冻结，将于"..os.date("%Y-%m-%d %H:%M",self.m_user_freeze_end_time) .."解封，期间无法进行游戏操作，如有疑问，请联系客服。"
            elseif self:getUserFreezeType() == 4 then 
                tip_msg = self:getFreezeTypeText();
            end 
        else
            tip_msg = "很抱歉，您的账号被多次举报，经核实已被永久冻结，期间无法进行游戏操作，如有疑问，请联系客服。"
        end;
    else        
        tip_msg = "很抱歉，您的账号被多次举报，经核实已被冻结，期间无法进行游戏操作，如有疑问，请联系客服。"
    end;

    if not self.m_freeze_dialog then
            self.m_freeze_dialog = new(ChioceDialog);
            self.m_freeze_dialog:setLevel(10)
        end;
        self.m_freeze_dialog:setMode(ChioceDialog.MODE_FREEZEUSER);
        self.m_freeze_dialog:setMessage(tip_msg);
        self.m_freeze_dialog:setPositiveListener(self,function() 
            if kPlatform == kPlatformIOS or kPlatform == kPlatformWin32 then
                StateMachine.getInstance():pushState(States.Feedback,StateMachine.STYPE_CUSTOM_WAIT);
            else
                if not kFeedbackGameid or not kFeedbackSiteid then
                    HttpModule.getInstance():execute(HttpModule.s_cmds.getFeedbackInfo);
                    ChessToastManager.getInstance():showSingle("反馈参数出错了:(");
                    return;
                end;
                local postData = {};
                postData.game_id = kFeedbackGameid;
                postData.site_id = kFeedbackSiteid;
                postData.uid = UserInfo.getInstance():getUid();
                postData.user_name = UserInfo.getInstance():getName();
                postData.user_icon_url = UserInfo.getInstance():getIcon();
                postData.is_kefu_vip = (tonumber(kIsFeedbackVip) == 1 and "3") or "2"; 
                postData.kefu_vip_level = (tonumber(kIsFeedbackVip) == 1 and kFeedbackVipLevel) or "normal";
                postData.account_type = UserInfo.getInstance():getAccountTypeName();
                postData.client = kIsFeedbackClient;
                dict_set_string(kLoadFeedbackSdk, kLoadFeedbackSdk .. kparmPostfix,json.encode(postData));
                call_native(kLoadFeedbackSdk);
            end
        end );
        self.m_freeze_dialog:setNegativeListener(self,function() 
            if kPlatform == kPlatformWin32 then
                os.exit();
            end
            sys_exit();
        end);
        self.m_freeze_dialog:show();
        
end

UserInfo.setIsModifyUserMnick = function(self, status)
    self.m_user_is_modify_name = status;
end;
--[Comment]
-- 是否有免费修改次数
UserInfo.getIsModifyUserMnick = function(self)
    return self.m_user_is_modify_name or 0;
end;
--[Comment]
-- 修改昵称花费元宝数
UserInfo.setModifyUserMnickCost = function(self, cost)
    self.m_modify_user_name_cost = tonumber(cost) or 0
end;

UserInfo.getModifyUserMnickCost = function(self)
    return self.m_modify_user_name_cost or 0
end;

--[Comment]
-- 修改棋社昵称花费元宝数
UserInfo.setModifyGuildMnickCost = function(self, cost)
    self.m_modify_guild_name_cost = tonumber(cost) or 0
end;

UserInfo.getModifyGuildMnickCost = function(self)
    return self.m_modify_guild_name_cost or 0;
end;


--function UserInfo:setUpdateFirstLogin(data)
--    self.isFirstLogin = data ;
--end


--function UserInfo:getUpdateFirstLogin()
--    return self.isFirstLogin or 0;
--end

-- 聊天室房间配置
UserInfo.setChatRoomList = function(self,chatRoomList)
    if #chatRoomList == 0 then
        return;
    end
    for i,v in ipairs(chatRoomList) do
        if v and v.type == "guild" and v.id == "" then
            v.id = "no_guild";
        end;
    end;
    self.m_chatRoomList = chatRoomList;
end

UserInfo.getChatRoomList = function(self, isOtherScene)
    if isOtherScene then -- 其他场景过滤掉小喇叭和棋社聊天室
        local filterChatRoomList = {};
        if not self.m_chatRoomList then return end;
        for i,v in ipairs(self.m_chatRoomList) do
            if v and v.type ~= "horn" and v.type ~= "guild" then
                table.insert(filterChatRoomList,v);
            end;
        end;
        return filterChatRoomList;
    else
        return self.m_chatRoomList;
    end;
end

-- 聊天室房间配置
UserInfo.setChatRoomMatchConfig = function(self,config)
    self.m_chatRoomMatchConfig = config;
end

UserInfo.getChatRoomMatchConfig = function(self)
    return self.m_chatRoomMatchConfig or nil;
end

-- 复盘要花费的(收藏，复制收藏，评论)金币
UserInfo.setFPcostMoney = function(self, cost_list)
--    {collect_manual={} save_manual={} comment_manual={} }
    local costList = {}
    -- 复制收藏（h5）
    if cost_list.collect_manual then 
        costList.collect_manual = cost_list.collect_manual:get_value();
    end;
    -- 收藏棋谱(lua内)
    if cost_list.save_manual then 
        costList.save_manual = cost_list.save_manual:get_value();
    end;
    -- 评论
    if cost_list.comment_manual then 
        costList.comment_manual = cost_list.comment_manual:get_value();
    end
    -- 创建武林残局
    if cost_list.create_booth then 
        costList.create_booth = cost_list.create_booth:get_value();
    end
    -- 挑战武林残局
    if cost_list.buy_booth then 
        costList.buy_booth = cost_list.buy_booth:get_value();
    end
    -- 创建棋社
    if cost_list.create_guild then 
        self.create_sociaty_money = cost_list.create_guild:get_value() or 1000000;
    end

    self.m_fp_cost_list = costList;
end

UserInfo.getFPcostMoney = function(self)
    return self.m_fp_cost_list or {};
end;

--账号登陆次数
UserInfo.setLoginTimes = function(self,mentercount)
    self.mentercount = mentercount;
end

UserInfo.getLoginTimes = function(self,mentercount)
    return self.mentercount or 0;
end

--[Comment]
--设置用户棋社数据
UserInfo.setUserSociatyData = function(self,sociatyData)
    if not sociatyData then 
        self.sociaty_data = {}
        return
    end
    
    local ret = {}
    ret = json.analyzeJsonNode(sociatyData); 
    self.sociaty_data = ret;
end

--[Comment]
--获得棋社数据
UserInfo.getUserSociatyData = function(self)
    return self.sociaty_data or {}
end

--[Comment]
--收到广播后设置棋社数据
UserInfo.setUserSociatyData2 = function(self,data)
    if not data or type(data) ~= "table" or next(data) == nil then return end
    for k,v in pairs(data) do
        if not self.sociaty_data[k] or self.sociaty_data[k] ~= v then
            self.sociaty_data[k] = v;
        end
    end
end

--[Comment]
--收到广播后设置棋社数据
UserInfo.clearUserSociatyData = function(self)
    self.sociaty_data = {}
end

--[Comment]
--创建棋社需要金币
UserInfo.getSociatyCreateMoney = function(self)
    if not self.create_sociaty_money or self.create_sociaty_money == "" then
        self.create_sociaty_money = 1000000
    end
    return self.create_sociaty_money
end

--[Comment]
--新道具配置
-- new_prop_info:新的道具类型数据
--by: fordfan
UserInfo.setNewPropInfo = function(self,new_prop_info,ret)
    if not new_prop_info or type(new_prop_info) ~= "table" then 
        self.new_prop_info = {};
        UserSetInfo.getInstance():updateSelectStatus() 
        return;
    end
    if ret then
        self.new_prop_info = new_prop_info;
    else
        self.new_prop_info = json.analyzeJsonNode(new_prop_info);
    end
    UserSetInfo.getInstance():updateSelectStatus()
end

--[Comment]
--新道具配置，返回两个参数
--canUse：可以使用的道具  new_prop_info：所有新道具
--by: fordfan
UserInfo.getNewPropInfo = function(self)
    local canUse_tab = {};
    if not self.new_prop_info or type(self.new_prop_info) ~= "table" then return {} end
    for k,v in pairs(self.new_prop_info) do
        if v then
            if v.is_enabled == 1 and tonumber(v.end_time) > os.time() then
                table.insert(canUse_tab,v);
            end
        end
    end

    return canUse_tab,self.new_prop_info;
end

-- 第一次登陆道具
UserInfo.setPropInfo = function(self,prop_info)
    if not prop_info or not prop_info:get_value() or prop_info == "" then return end
    local info = prop_info:get_value();
    local info_tab = json.decode(info);
    local temp_tab = {};

    if not info_tab then return end;

    for k,v in pairs(info_tab) do
        local data = {};
        if v ~= 0 then
            data.propType = tonumber(k);
            data.propNum = tonumber(v);
            table.insert(temp_tab,data);
        end
    end

    self.m_propInfo = temp_tab;
end

UserInfo.getPropInfo = function(self)
    return self.m_propInfo or nil;
end

UserInfo.setIsVip = function(self,is_vip)
    self.m_is_vip = is_vip
--    self.m_is_vip = 0;
end

UserInfo.getIsVip = function(self)
    return self.m_is_vip or 0 ;
end

UserInfo.getUserSet = function(self)
    return self.m_mySet or {};
end

UserInfo.setUserMySet = function(self,my_set)
    local info = {};
    if not my_set or my_set == "" then 
        info.picture_frame = "sys";
        info.piece = "sys";
        info.board = "sys";
    else
        local tab = json.decode_node(my_set);
        info = json.analyzeJsonNode(tab);
    end
    self.m_mySet = info;
    UserSetInfo.getInstance():updataSelectData(info);
end

--[Comment]
--设置是否是回流用户
--ret: 1- 是  0-否
function UserInfo.setIsReflowUser(self,ret)
    if not ret then return end
    local tmp = tonumber(ret);
    self.m_isReflowUser = tmp;
end

--[Comment]
--设置是否是回流用户
--ret: 1- 是  0-否
function UserInfo.getIsReflowUser(self)
    return self.m_isReflowUser or 0;
end

UserInfo.setMactivetime = function(self,time)
    self.m_mactivetime = time
end

UserInfo.getMactivetime = function(self)
    return self.m_mactivetime or 0;
end

UserInfo.setVipTime = function(self,vipTime)
    self.m_vip_time = tonumber(vipTime) or 0;
end

UserInfo.getVipTime = function(self)
    return self.m_vip_time or 0;
end

UserInfo.getVipTimeText = function(self)
    local nowTime = os.time();
    local endTime = UserInfo.getInstance():getVipTime();

    if not endTime or endTime == 0 or endTime < nowTime then
        return "尚未成为会员"
    end

    local diffTime = endTime - nowTime;
    local time_s = diffTime;
    local time_h = math.ceil(time_s/3600);
    local time_d = math.ceil(time_h/24)
    local time_str = "";
    if time_s > 0 then
        time_str = time_s .. "秒";
    end
    if time_h > 0 then
        time_str = time_h .. "时";
    end
    if time_d > 0 then
        time_str = time_d .. "天";
    end
    return time_str;
end


UserInfo.setTodayFirstLogin = function(self,todayFirst)
    self.m_today_first = todayFirst;
end

UserInfo.getTodayFirstLogin = function(self)
--    return 1
    return self.m_today_first or 0;
end

UserInfo.setUpdateFirstLogin = function(self,data)
    self.updataFirstLogin = data;
end

UserInfo.getUpdateFirstLogin = function(self)
    return self.updataFirstLogin or 0;
end

UserInfo.setConnectHall = function(self, flag)

   self.m_isConnectHall = flag; 
end

UserInfo.getConnectHall = function(self, flag)

    return self.m_isConnectHall or false;
end

UserInfo.getBestAccessRoomId = function(self)

	for i = #self.m_room_list,1,-1 do
		local r = self.m_room_list[i];
		if self.m_money >= r.minmoney then
			if r.maxmoney > 0 and self.m_money < r.maxmoney then
				return r.room_type;
			elseif r.maxmoney == 0 then
				return r.room_type;
			end
		end
	end
	return 0;
end

--设置用户icon的类型：-1代表本地上传。0代表未做任何更改。1，2，3，4分别代表界面上可选的4张头像图标。
UserInfo.setIconType = function(self, Type)
    self.m_userInfo_iconType =  Type;
end;

UserInfo.getIconType = function(self)
    return self.m_userInfo_iconType or 0;
end;

--设置头像
--当有本地上传头像时，Android会将本地头像上传服务器生成url。而默认的本地4个头像不会上传。
--点保存按钮后都会上传一个新的字段iconType给php,-1代表本地上传，1，2，3，4代表4个默认头像。
--所以登陆返回设置头像都回返回iconType, 如果为-1，参数icon为上传服务器生成的url。1，2，3，4
--参数icon为nil。0代表没修改过头像，icon为nil。这样做可以满足本地上传和系统默认头像相互切换的需求。
UserInfo.setIcon = function ( self,icon )
    local iconType = self:getIconType();
    print_string("eeeee iconType " ..iconType .." iconType");
    if 0 ~=  iconType then
        if -1 == iconType then
            self.m_icon = icon;
        elseif 0 < iconType then -- 1,2,3,4
            
            self:setIconFile(nil,UserInfo.DEFAULT_ICON[iconType] or UserInfo.DEFAULT_ICON[1]); 
            print_string("eeeee iconType2 " ..iconType .." iconType");
            self.m_icon = nil;
            if not icon then
                print_string("eeeee iconType > 0 icon is nil");
            else
                print_string("eeeee iconType > 0 icon 不空"..icon);

            end;
            
        end;
    else
        self.m_icon = icon;
    end;
end

UserInfo.setShowBankruptStatus = function(self,ret)
    self.m_show_bankrupt = ret
end

UserInfo.getShowBankruptStatus = function(self)
    return self.m_show_bankrupt;
end


UserInfo.getIcon = function(self)
    if not self.m_icon then
        return (self:getIconType() .."");
    else
        return self.m_icon;
    end;
	
end

UserInfo.setIconFile = function (self,url,iconFile)	
	GameCacheData.getInstance():saveString("uidicon" .. self:getUid()..PhpConfig.getSid(), url);
    GameCacheData.getInstance():saveString("uidiconFile" .. self:getUid()..PhpConfig.getSid(), iconFile);
    --print_string("eeeee uidicon" .. self:getUid()..PhpConfig.getSid().."----->"..url);
    --print_string("eeeee uidiconFile" .. self:getUid()..PhpConfig.getSid().."----->"..iconFile);
    CacheImageManager.registered(nil,url)
	self.m_iconFile = iconFile;
end
UserInfo.getIconFile = function(self)
    self.m_iconFile = GameCacheData.getInstance():getString("uidiconFile" .. self:getUid()..PhpConfig.getSid(), "");
    Log.i("eeeee getIconFile uidiconFile " .." uid " ..self:getUid().." sid:"..PhpConfig.getSid().."----->"..self.m_iconFile);
	if "" == self.m_iconFile then
		if self:getSex() == 1 then
			return User.MAN_ICON;
		else
			return User.WOMAN_ICON;
		end
	end
	return self.m_iconFile or "";
end

UserInfo.setProvinceCode = function(self,province_code)
 	self.m_province_code = tonumber(province_code) or 0;
end
UserInfo.getProvinceCode = function(self)
	return self.m_province_code or 0;
end
UserInfo.setProvinceName = function(self,province_name)
 	self.m_province_name = province_name;
end
UserInfo.getProvinceName = function(self)
	return self.m_province_name or "";
end

UserInfo.setCityCode = function(self,city_code)
 	self.m_city_code = tonumber(city_code) or 0;
end
UserInfo.getCityCode = function(self)
	return self.m_city_code or 0;
end
UserInfo.setCityName = function(self,city_name)
 	self.m_city_name = city_name;
end
UserInfo.getCityName = function(self)
	return self.m_city_name or "";
end
UserInfo.setHometown = function(self,hometown)
 	self.m_hometown = hometown;
end
UserInfo.getHometown = function(self)
	return self.m_hometown or "";
end

UserInfo.setLogin = function(self,login)
	self.m_login = login;
end

UserInfo.isLogin = function(self)
	return self.m_login or false;
end

UserInfo.setMatchTime = function(self,time)
	self.m_matchTime = time;
end
UserInfo.getMatchTime = function(self)
	return self.m_matchTime;
end
--php可配单机AI难度.
UserInfo.setAILevelMap = function(self,aiLevel)
    
    for i = 1, COSOLE_MODEL_GATE_NUM do
        self.ailevelmap[i] = aiLevel["console_"..tostring(i)]:get_value();
    end;
    GameCacheData.getInstance():saveString(GameCacheData.CONSOLE_AI_LEVEL, json.encode(self.ailevelmap));
end
UserInfo.getAILevelMap = function(self)
    if next(self.ailevelmap) == nil then --self.ailevelmap = {};
        local localmap = GameCacheData.getInstance():getString(GameCacheData.CONSOLE_AI_LEVEL,"");
        if localmap == "" then
            print_string("ailevelmap1-------->"..json.encode(User.AI_LEVEL_DEFAULT));
            return User.AI_LEVEL_DEFAULT;
        else
            self.ailevelmap = json.decode(localmap);
            print_string("ailevelmap1-------->"..json.encode(self.ailevelmap));
            return self.ailevelmap;
        end;
    else
        print_string("ailevelmap2-------->"..json.encode(self.ailevelmap));
        return self.ailevelmap;
    end;   
	
end
--set将要开局的关卡
UserInfo.setPlayingLevel = function(self, level)
    self.m_console_playing_level = level;
end;

--get将要开局的关卡
UserInfo.getPlayingLevel = function(self)
    return self.m_console_playing_level;
end;

UserInfo.setUsertype = function(self,usertype)
	self.m_usertype = usertype;
end

--是否要进入联网场
UserInfo.setGoOnline = function(self,flag)
	self.m_go_online = flag;
end

UserInfo.getGoOnline = function(self)
	return self.m_go_online;
end


UserInfo.setNeedUpdateInfo = function(self,flag)
	self.m_need_update = flag;
end
--是否需要重新拉取服务器的用户信息
UserInfo.getneedUpdateInfo = function(self)
	return self.m_need_update or false;
end

UserInfo.setPmode = function(self,pmode)
	self.m_pmode = pmode;
end
UserInfo.getPmode = function(self)
	return self.m_pmode or 4;
end

--保存最近的订单号，方便请求发货
UserInfo.setOrderID = function(self,pid)
	self.m_pid = pid;
end
UserInfo.getOrderID = function(self)
	return self.m_pid;
end

--回归奖励金币数  
UserInfo.setComeBackRewardNum = function(self,comeback_rewardnum)
    self.m_comebackRewardNum = comeback_rewardnum;
end

UserInfo.getComeBackRewardNum = function(self)
    return self.m_comebackRewardNum;
end

UserInfo.setPropid = function(self,propid)
	self.m_propid = propid;
end
UserInfo.getPropid= function(self)
	return self.m_propid;
end

UserInfo.setOrderPid = function(self,pid)
	self.m_pid = pid;
end

UserInfo.getOrderPid= function(self)
	return self.m_pid;
end

UserInfo.setPropPrice = function(self,propPrice)
	self.m_propPrice = propPrice;
end

UserInfo.getPropPrice= function(self)
	return self.m_propPrice;
end

UserInfo.getPayProcuctName = function(self)
	return self.m_payProductName or "";
end

UserInfo.setPayProcuctName = function(self,productName)
	self.m_payProductName = productName;
end

-- 1 游客  2 weibo 3 博雅用户 4.360,5,QQ,6.oppo
UserInfo.getUsertype = function(self)
	if(self.m_usertype == 1) then
		return "状态 : 游客"
	elseif self.m_usertype == 2 then
		return "状态 : 微博用户"
	elseif self.m_usertype == 3 then
		return "状态 : 博雅用户"
	elseif self.m_usertype == 4 then
		return "状态 : 360用户"	
	elseif self.m_usertype == 5 then
		return "状态 : QQ用户"	
	elseif self.m_usertype == 6 then
		return "状态 : oppo用户"						
	else
		return "状态 : 未知"
	end
end

UserInfo.setLoginType = function(self,type)
	self.m_loginType = type;
end

UserInfo.getLoginType = function(self)
	return self.m_loginType or LOGIN_TYPE_YOUKE;
end


UserInfo.setCustomRoomID= function(self,customroomId)
	self.m_customroomId = customroomId;
end
UserInfo.getCustomRoomID= function(self)
	return self.m_customroomId;
end

-- 设置私人房类型
-- a) 0 (普通私人房：联网->私人房->创建房间)
-- b) 1 (邀请私人房：聊天室(或其他场景)->挑战(1v1)->创建私人房)
-- c) 2 (约战私人房：聊天室(或其他场景)->约战(1v1)->创建私人房)
UserInfo.setCustomRoomType= function(self,customRoomType)
	self.m_customRoomType = customRoomType;
end
UserInfo.getCustomRoomType= function(self)
	return self.m_customRoomType or 0;
end

UserInfo.setCustomRoomData= function(self,customRoomData)
	self.m_customRoomData = customRoomData;
end
UserInfo.getCustomRoomData= function(self)
	return self.m_customRoomData or {};
end

UserInfo.setIsCustomRoomPwd = function(self,pwd)
	self.m_pwd= pwd;
end
UserInfo.getIsCustomRoomPwd = function(self)
	return self.m_pwd;
end

UserInfo.setRelogin = function(self,flag)
	self.m_relogin = flag;
end
UserInfo.getRelogin = function(self)
	return self.m_relogin or false;
end

UserInfo.setActionDailyAid = function(self,actionDailyAid)
	self.m_actionDailyAid = actionDailyAid;
end

UserInfo.getActionDailyAid = function(self)
	return self.m_actionDailyAid or 0;
end

UserInfo.setActionSwitch = function(self,action_switch)
	self.m_action_switch = action_switch;
end

UserInfo.getActionSwitch = function(self)
	if self.m_action_switch then
		if self.m_action_switch == 0 then
			return false;
		else
			return true;
		end
	else
		return false;
	end
end


--用户选择的大关卡
UserInfo.setGate = function(self,gate)--对应Gate.java
	self.m_gate = gate;
	self:setGateTid(gate.tid);
end

UserInfo.getGate = function(self)
	return self.m_gate;
end

--用户选择的大关卡TID
UserInfo.setGateTid = function(self,gate_tid)
	self.m_gate_tid = gate_tid;
end
UserInfo.getGateTid = function(self)
	if self.m_gate then
		return self.m_gate.tid;
	else
		return nil;
	end

	--return self.m_gate_tid or 0;
end

--用户选择的大关卡的某一小关
UserInfo.setGateSort = function(self,gate_sort)
	self.m_gate_sort = gate_sort;
end

UserInfo.getGateSort = function(self)
	return self.m_gate_sort or 0;
end

UserInfo.setQuickPlay = function(self,quickPlay)
    self.isQuickPlay = quickPlay;
end

UserInfo.getQuickPlay = function(self)
    return self.isQuickPlay or false;
end


UserInfo.setMultiply = function(self,multiply)
	self.m_multiply = multiply;
end
UserInfo.getMultiply = function(self)
	return self.m_multiply;
end

--是不是最新的关卡
UserInfo.isLatestGate = function(self)
	local uid = self:getUid();
	local latest_tid = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_GATE .. uid,17);
	local latest_sort = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LATETST_SORT .. uid,0);


	local tid = self:getGateTid();
	local sort = self:getGateSort();
	tid = tonumber(tid);
	sort = tonumber(sort);

	print_string(string.format("latest_tid = %d,latest_sort = %d,tid = %d,sort = %d",latest_tid,latest_sort,tid,sort));



	if latest_tid == -1 or  (tid == latest_tid and sort >= latest_sort) then

		return true
	end



	return  false;
end

UserInfo.setLatestGate = function(self)
	print_string("UserInfo.setLatestGate ");
	if not self:isLatestGate() then
		return;
	end

	local uid = self:getUid();
	local tid = UserInfo.getInstance():getGateTid();
	local sort = UserInfo.getInstance():getGateSort();
	
	tid = tonumber(tid);
	sort = tonumber(sort);

	print_string(string.format("tid = %d,sort = %d",tid,sort));
	GameCacheData.getInstance():saveInt(GameCacheData.ENDGAME_LATETST_GATE .. uid,tid);
	GameCacheData.getInstance():saveInt(GameCacheData.ENDGAME_LATETST_SORT .. uid,sort+1);

end


--获取与保存悔棋次数
UserInfo.getUndoNum = function(self)
	local uid = self:getUid();
	local num = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_UNDO_NUM .. uid,ENDING_UNDO_NUM);
	return num;
end
UserInfo.setUndoNum = function(self,num)
	local uid = self:getUid();
	GameCacheData.getInstance():saveInt(GameCacheData.ENDGAME_UNDO_NUM .. uid,num);
end

--获取与保存提示次数
UserInfo.getTipsNum = function(self)
	local uid = self:getUid();
	local num = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_TIPS_NUM .. uid,ENDING_TIPS_NUM);
	return num;
end
UserInfo.setTipsNum = function(self,num)
	local uid = self:getUid();
	GameCacheData.getInstance():saveInt(GameCacheData.ENDGAME_TIPS_NUM .. uid,num);
end

--获取与保存起死回生的次数
UserInfo.getReviveNum = function(self)
	local uid = self:getUid();
	local num = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_REVIVE_NUM .. uid,ENDING_REVIVE_NUM);
	return num;
end
UserInfo.setReviveNum = function(self,num)
	local uid = self:getUid();
	GameCacheData.getInstance():saveInt(GameCacheData.ENDGAME_REVIVE_NUM .. uid,num);
end

--获取与保存生命的次数
UserInfo.getLifeNum = function(self)
	local uid = self:getUid();
	local num = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LIFE_NUM .. uid,ENDING_LIFE_NUM);
	return num;
end

UserInfo.setLifeNum = function(self,num)
	local uid = self:getUid();
	local life_limit = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LIFE_LIMIT .. uid,ENDING_LIFELIMIT_NUM);
	-- if num > life_limit then
	-- 	num = life_limit;
	-- end
	if num < life_limit and EndingTimeUpdate.isRunning() == false then
		EndingTimeUpdate.resetTime();
		EndingTimeUpdate.start();
	elseif num >= life_limit then
		EndingTimeUpdate.stop();
	end

	GameCacheData.getInstance():saveInt(GameCacheData.ENDGAME_LIFE_NUM .. uid,num);
end

--获取与保存生命上线数
UserInfo.getLifeLimitNum = function(self)
	local uid = self:getUid();
	local num = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_LIFE_LIMIT .. uid,ENDING_LIFELIMIT_NUM);
	return num;
end
UserInfo.setLifeLimitNum = function(self,num)
	local uid = self:getUid();
    print_string("=====setLifeLimitNum=====num ==================="..num);


	GameCacheData.getInstance():saveInt(GameCacheData.ENDGAME_LIFE_LIMIT .. uid,num);
end

UserInfo.setGateTids = function(self,tids)
	self.m_tids = tids;
end

UserInfo.getGateTids = function (self)
	return self.m_tids;
end

UserInfo.setPropNum = function(self,propNum)
	self.m_propNum = propNum;
end

UserInfo.getPropNum = function (self)
	return self.m_propNum or 0;
end

--是否为最后一小关
UserInfo.isLastGate = function (self)
	local max = self:getGate().subCount;
	local gate_sort = self:getGateSort();
	if (gate_sort+1) == max then
		return true;
	end
	return false;
end


--获取与保存残局领先程度
UserInfo.getProportion = function(self)
	local uid = self:getUid();
	local num = GameCacheData.getInstance():getInt(GameCacheData.ENDGAME_PROPORTION .. uid,1);
	return num;
end

UserInfo.setProportion = function(self,num)
	local uid = self:getUid();
	GameCacheData.getInstance():saveInt(GameCacheData.ENDGAME_PROPORTION .. uid,num);
end

--游戏结束时候防沉迷提示标志 -- 0 不需要提示 -- 1 提示用户还没有进行防沉迷认证 -- 提示用户为满18周岁 
UserInfo.setPreventAddictedTipsFlag = function(self,flag)
	self.m_prevent_addicted_tips_flag = tonumber(flag);
end

UserInfo.getPreventAddictedTipsFlag = function(self)
	return self.m_prevent_addicted_tips_flag or 0;
end

UserInfo.setIsOpenEnthralment = function(self,flag)
	self.m_isOpenEnthralment = tonumber(flag);
end

UserInfo.getIsOpenEnthralment = function(self)
	return self.m_isOpenEnthralment or 0;
end

-- 0 未验证 1-成年人 2-未成年人 
UserInfo.setEnthralmentStatus = function(self,flag)
	self.m_enthralmentStatus = tonumber(flag);
end

UserInfo.getEnthralmentStatus = function(self)
	return self.m_enthralmentStatus or 0;
end

UserInfo.setOnLineTime = function(self,time)
	self.m_time = tonumber(time);
end

UserInfo.getOnLineTime = function(self)
	return self.m_time or 0;
end

UserInfo.setPhoneNo= function(self,num)
	self.m_phone_num = num;
end

UserInfo.getPhoneNo = function(self)
	return self.m_phone_num;
end

UserInfo.setPromptNum= function(self,num)
	self.m_prompt_num = num;
end

UserInfo.getPromptNum= function(self,num)
	return self.m_prompt_num or 3;
end

UserInfo.setInviteUrl= function(self,invite_url)
	self.m_invite_url = invite_url;
end

UserInfo.getInviteUrl = function(self)
	return self.m_invite_url;
end

UserInfo.setFPlayProgressList = function(self,data)--残局好友进度数据
	self.m_fPlay_ProgressList = data;
end

UserInfo.getFPlayProgressList = function(self)
	return self.m_fPlay_ProgressList;
end

UserInfo.getFreeEndgateData = function(self)--邀请好友数据
	return self.m_free_endgate_data or 0;
end

UserInfo.setFreeEndgateData = function(self,data)
	self.m_free_endgate_data = data;
end

UserInfo.setWebBoothUrl = function(self,url)
	self.m_web_booth_url = url;
	local uid = self:getUid();
	GameCacheData.getInstance():saveString(GameCacheData.ENDGAME_WEBBOOTH_URL .. uid,url);
end

UserInfo.getWebBoothUrl = function(self)
	local uid = self:getUid();
	local default_url = "https://chesstest.boyaa.com:90/webbooth/" --?cid=450";
	local url = GameCacheData.getInstance():getString(GameCacheData.ENDGAME_WEBBOOTH_URL .. uid,default_url);
	return self.m_web_booth_url or url;
end


UserInfo.setShowLoginType = function(self,showloginType)
	self.m_showloginType = showloginType
end

UserInfo.getShowLoginType = function(self)
	return self.m_showloginType;
end

UserInfo.setCoinsPrice = function(self,coinsPrice)
	self.m_coinsPrice = coinsPrice;
end

UserInfo.getCoinsPrice= function(self)
	return self.m_coinsPrice;
end

UserInfo.setCoins = function(self,coins)
	self.m_coins = coins;
end

UserInfo.getCoins= function(self)
	return self.m_coins or 0;
end

UserInfo.setCoinGoodsId = function(self,id)
	self.m_coin_goodsid = id;
end

UserInfo.getCoinGoodsId= function(self)
	return self.m_coin_goodsid or 0;
end

UserInfo.isLastConsoleAI = function(self)
	local curLevel = self:getAILevel();
	local uid = self:getUid();
	local level = GameCacheData.getInstance():getInt(GameCacheData.CONSOLE_MAX_LEVEL .. uid,0);
	if curLevel == level then
		return true;
	end
	return false;
end

UserInfo.setDapuSelData = function(self,dapuSelData)
	self.m_dapuSelData = dapuSelData;
end

UserInfo.getDapuSelData = function(self)
	return self.m_dapuSelData;
end

UserInfo.setDapuDataNeedToSave = function(self,dataTosave)
	self.m_dataToSave = dataTosave;
end

UserInfo.getDapuDataNeedToSave = function(self)
	return self.m_dataToSave;
end


UserInfo.setDapuEnable = function(self,flag)
	local uid = self:getUid();
	GameCacheData.getInstance():saveInt(GameCacheData.DAPU_ENABLE .. uid,flag);
end

UserInfo.getDapuEnable = function(self)
	local uid = self:getUid();
	local flag = GameCacheData.getInstance():getInt(GameCacheData.DAPU_ENABLE .. uid,0);
	
	if flag <= 0 then
		return false;
	else
		return true;
	end
end

UserInfo.setSaveChessLimit = function(self,limit)
	local uid = self:getUid();
	GameCacheData.getInstance():saveInt(GameCacheData.DAPU_LIMIT .. uid,limit);
end

UserInfo.getSaveChessLimit = function(self)
	local uid = self:getUid();
	local limit = GameCacheData.getInstance():getInt(GameCacheData.DAPU_LIMIT .. uid,10);
	return limit;
end


UserInfo.setSaveChessManualLimit = function(self, limit)
	local uid = self:getUid();
	GameCacheData.getInstance():saveInt(GameCacheData.DAPU_AUTOSAVE_LIMIT .. uid,limit);    
end;

UserInfo.getSaveChessManualLimit = function(self)
	local uid = self:getUid();
	local limit = GameCacheData.getInstance():getInt(GameCacheData.DAPU_AUTOSAVE_LIMIT .. uid,50);
	return limit;
end


UserInfo.setCardType = function(self,cardType)
	self.m_cardType = cardType;
end

UserInfo.getCardType = function(self)
	return self.m_cardType or 0; 
end

UserInfo.setNeedShowConsoleAnim = function(self,need)
	self.m_needShowConsoleAnim = need;
end

UserInfo.getNeedShowConsoleAnim = function(self)
	return self.m_needShowConsoleAnim;
end

UserInfo.setHasConsoleNeedBuy = function(self,need)--有单机关卡需要付费
	self.m_hasConNeedBuy = need;
end

UserInfo.isHasConsoleNeedBuy = function(self)
	return self.m_hasConNeedBuy;
end


UserInfo.setDownloadProps = function(self,need) --第一次安装是否更新道具
	local uid = self:getUid();
	GameCacheData.getInstance():saveBoolean(GameCacheData.DOWN_LOAD_PROPS .. uid,need);
end

UserInfo.isDownloadProps = function(self)
	local uid = self:getUid();
	local download = GameCacheData.getInstance():getBoolean(GameCacheData.DOWN_LOAD_PROPS .. uid,true);
	return download;
end

--增加用户的玩单机记录
UserInfo.addPlayConsoleHistory = function(self)

	local uid = self:getUid();
	local time = os.time();
	local history = self:getPlayConsoleHistory();
	if not history or history == "" then
		history = tonumber(time) .. "";
	else
		history = history .. "," .. tonumber(time);
	end
	
	GameCacheData.getInstance():saveString(GameCacheData.CONSOLE_PLAY_HISTORY .. uid,history);
	return history;
end

--获取用户的玩单机记录
UserInfo.getPlayConsoleHistory = function(self)
	local uid = self:getUid();
	local history = GameCacheData.getInstance():getString(GameCacheData.CONSOLE_PLAY_HISTORY .. uid,"");
	return history;
end

--清除用户的玩单机记录
UserInfo.clearPlayConsoleHistory = function(self)
	local uid = self:getUid();
	local history = ""
	GameCacheData.getInstance():saveString(GameCacheData.CONSOLE_PLAY_HISTORY .. uid,history);
end



--增加用户的玩单机记录
UserInfo.addPlayConsoleReward = function(self,reward)

	local uid = self:getUid();
	local reward_str = self:getPlayConsoleReward();
	if not reward_str or reward_str == "" then
		reward_str = reward;
	else
		reward_str = reward_str .. "," .. reward;
	end

	GameCacheData.getInstance():saveString(GameCacheData.CONSOLE_PLAY_REWARD .. uid,reward_str);
	return reward_str;
end

--获取用户的玩单机记录
UserInfo.getPlayConsoleReward = function(self)
	local uid = self:getUid();
	local reward_str = GameCacheData.getInstance():getString(GameCacheData.CONSOLE_PLAY_REWARD .. uid,"");
	return reward_str;
end

--清除用户的玩单机记录
UserInfo.clearPlayConsoleReward = function(self)
	local uid = self:getUid();
	local reward_str = ""
	GameCacheData.getInstance():saveString(GameCacheData.CONSOLE_PLAY_REWARD .. uid,reward_str);
end


 -- 元宝 
UserInfo.setBycoin = function(self,bycoin)
	self.m_bycoin = bycoin;
end

UserInfo.getBycoin = function(self)
	return self.m_bycoin or 0;
end

-- 对手被强制悔棋获得金币数 
UserInfo.setOpponentgetCoin = function(self,opponentgetCoin)
	self.m_opponentgetCoin = opponentgetCoin;
end

UserInfo.getOpponentgetCoin  = function(self)
	return self.m_opponentgetCoin or 0;
end

--一局棋最多悔棋次数 
UserInfo.setMaxOnlineUndoCount = function(self,count)
	self.m_count = count;
end

UserInfo.getMaxOnlineUndoCount = function(self)
	return self.m_count or 0;
end

--当前悔棋次数要用到的元宝数
UserInfo.setUseBYCoinTb = function(self,useBYCoinTb)
	self.m_useBYCoinTb = useBYCoinTb;
end

UserInfo.getUseBYCoinTb = function(self)
	return self.m_useBYCoinTb;
end

--玩残局次数 0屏蔽该功能 1不提示购买，2提示购买
UserInfo.getPlayConsoleCount = function(self)
	local uid = self:getUid();
	local count = GameCacheData.getInstance():getInt(GameCacheData.PLAY_CONSOLE_COUNT .. uid,1);
	return count;
end

UserInfo.setPlayConsoleCount = function(self,count)
	local uid = self:getUid();
	GameCacheData.getInstance():saveInt(GameCacheData.PLAY_CONSOLE_COUNT .. uid,count);
end

--是否玩的用户需要购买 1需要购买，0不需要购买
UserInfo.getPlayConsoleFlag = function(self)
	local uid = self:getUid();
	local flag = GameCacheData.getInstance():getInt(GameCacheData.FIRST_CONSOLE_FLAG .. uid,1);
	return flag;
end

UserInfo.setPlayConsoleFlag = function(self,flag)
	local uid = self:getUid();
	GameCacheData.getInstance():saveInt(GameCacheData.FIRST_CONSOLE_FLAG .. uid,flag);
end

UserInfo.setNetConfigUrl= function(self,netConfigUrl)
	self.m_netConfigUrl = netConfigUrl;
end

UserInfo.getNetConfigUrl = function(self)
	return self.m_netConfigUrl;
end

UserInfo.setNetConfigVersion= function(self,configVersion)
	self.m_configVersion = tonumber(configVersion);
end

UserInfo.getNetConfigVersion = function(self)
	return self.m_configVersion or 0;
end

UserInfo.setNetConfigUpdate= function(self,netConfigUpdate)
	self.m_netConfigUpdate = tonumber(netConfigUpdate);
end

UserInfo.getNetConfigUpdate = function(self)
	return self.m_netConfigUpdate or 0;
end

UserInfo.setNetStatus= function(self,status)
	self.m_status = status;
end

UserInfo.getNetStatus = function(self)
	return self.m_status or 1;
end

--残局
UserInfo.setIsNeedPayGate= function(self,needPay)
	self.m_needPay = needPay;
end

UserInfo.IsNeedPayGate = function(self)
	return self.m_needPay or false;
end

UserInfo.setIsConsoleNeedPay= function(self,needPay)
	self.m_consoleNeedPay = needPay;
end

UserInfo.IsConsoleNeedPayGate = function(self)
	return self.m_consoleNeedPay or false;
end

UserInfo.setIsUnlimited= function(self,isUnlimited)
	self.m_isUnlimited = isUnlimited;
end

UserInfo.IsUnlimited = function(self)
	return self.m_isUnlimited or 1;
end

UserInfo.setIsShowDaliy= function(self,isShowDaliy)
	self.m_isShowDaliy = isShowDaliy;
end

UserInfo.IsShowDaliy= function(self)
	return self.m_isShowDaliy or false;
end


UserInfo.setSoulCount= function(self,soulcount)
	self.m_soulcount= soulcount;
end

UserInfo.getSoulCount= function(self)
	return self.m_soulcount or 0;
end
--象棋主线积分墙版本接入添加：设置/领取用户积分--2014/8/25 
UserInfo.setPoints= function(self, points)
	self.m_points = points;
end

UserInfo.getPoints= function(self)
	return self.m_points or 0;
end

UserInfo.setWinEndGateGetSoulRate= function(self,rate)
	if rate then
		self.m_endgate_getsoul_rate= 100*rate;
	else
		self.m_endgate_getsoul_rate= 0;
	end
end

UserInfo.getWinEndGateGetSoulRate= function(self)
	return self.m_endgate_getsoul_rate or 0;
end

UserInfo.setWinConsoleGetSoulRate= function(self,rate)
	if rate then
		self.m_console_getsoul_rate= 100*rate;
	else
		self.m_console_getsoul_rate= 0;
	end
end

UserInfo.getWinConsoleGetSoulRate= function(self)
	return self.m_console_getsoul_rate or 0;
end

UserInfo.setPassConsoleLayerGetSoulRate= function(self,rate)
	if rate then
		self.m_pass_console_layer_getsoul_rate= 100*rate;
	else
		self.m_pass_console_layer_getsoul_rate= 0;
	end
end

UserInfo.getPassConsoleLayerGetSoulRate= function(self)
	return self.m_pass_console_layer_getsoul_rate or 0;
end

UserInfo.setPayCnHost= function(self,payCnHost)
	self.m_payCnHost= payCnHost;
end

UserInfo.getPayCnHost= function(self)
	return self.m_payCnHost or "https://paycnapi.boyaa.com/";
end


--是否绑定博雅帐号
UserInfo.isBindBoyaa = function(self)
	local bind = GameCacheData.getInstance():getBoolean(GameCacheData.IS_BIND_BOYAA,false);
	return bind;
end

--设置是否绑定博雅帐号
UserInfo.setBindBoyaa = function(self,isBind)
	GameCacheData.getInstance():saveBoolean(GameCacheData.IS_BIND_BOYAA,isBind);
end

--游客帐号是否被绑定
UserInfo.setBindYouke = function(self,isBind)
	GameCacheData.getInstance():saveBoolean(GameCacheData.IS_BIND_YOUKE,isBind);
end

UserInfo.isBindYouke = function(self)
	local bind = GameCacheData.getInstance():getBoolean(GameCacheData.IS_BIND_YOUKE,false);
	return bind;
end

UserInfo.setBoyaaBid = function(self,bid)
	GameCacheData.getInstance():saveInt(GameCacheData.BOYAA_BID,bid);
end

UserInfo.getBoyaaBid = function(self)
	local bid = GameCacheData.getInstance():getInt(GameCacheData.BOYAA_BID,-1);
	return bid;
end

UserInfo.setHasShowBindDialog = function(self,flag)
	self.m_has_show_bind = flag;
end

UserInfo.isHasShowBindDialog = function(self)
	return self.m_has_show_bind or false;
end

UserInfo.setShowBindTips = function(self,flag)
	self.m_showBindTips = flag;
end

UserInfo.getShowBindTips = function(self)
	return self.m_showBindTips or 0;
end

UserInfo.setBcPayConfig = function(self,mGoodID,tGoodID,rGoodID)
	self.m_mGoodID, self.m_tGoodID,self.m_rGoodID= mGoodID,tGoodID,rGoodID;
end

UserInfo.getBcPayConfig = function(self)
	return self.m_mGoodID, self.m_tGoodID,self.m_rGoodID;
end

UserInfo.setPaySid = function(self,sid)
	self.m_pay_sid = sid;
end

UserInfo.getPaySid = function(self)
	return self.m_pay_sid or "7";
end

UserInfo.setAppid = function(self,appid)
	self.m_pay_appid= appid;
end

UserInfo.getAppid = function(self)
	return self.m_pay_appid or "231";
end
if kPlatform == kPlatformIOS then
    ------------------ AppStore审核开关 ------------------
    --第三方分享棋谱开关
    UserInfo.setThirdShareDapuUrl = function(self,status)
	    self.m_thirdpart_dapu_url = status;
    end

    UserInfo.getThirdShareDapuUrl = function(self)
	    return self.m_thirdpart_dapu_url or 0;
    end

    --活动中心开关
    UserInfo.setActivityCenter = function(self,status)
	    self.m_activity_center = status;
    end

    UserInfo.getActivityCenter = function(self)
	    return self.m_activity_center or 0;
    end

    --第三方登录开关
    UserInfo.setThirdPartLogin = function(self,status)
	    self.m_thirdpart_login = status;
    end

    UserInfo.getThirdPartLogin = function(self)
	    return self.m_thirdpart_login or 0;
    end

    --第三方支付开关
    UserInfo.setThirdPartPay = function(self,status)
	    self.m_thirdpart_pay = status;
    end

    UserInfo.getThirdPartPay = function(self)
	    return self.m_thirdpart_pay or 0;
    end

    --第三方分享游戏链接开关
    UserInfo.setThirdShareGameUrl = function(self,status)
	    self.m_thirdpart_game_url= status;
    end

    UserInfo.getThirdShareGameUrl = function(self)
	    return self.m_thirdpart_game_url or 0;
    end

    --ios审核总开关
    UserInfo.setIosAuditStatus = function(self,status)
	    self.m_ios_audit_status= status;
    end

    UserInfo.getIosAuditStatus = function(self)
	    return self.m_ios_audit_status or 0;
    end


    ------------------ AppStore审核开关 ------------------
end;


UserInfo.setAuditStatus = function(self,status)
	self.m_audit_status = tonumber(status)
end

UserInfo.getAuditStatus = function(self)
	return self.m_audit_status or 0;
end

--设置积分墙是否有可领取成功的应用
UserInfo.setPointWallAvailable = function(self,flag)
	self.m_pw_available= flag;
end

UserInfo.getPointWallAvailable = function(self)
	return self.m_pw_available or false;
end


UserInfo.setDebugMode = function(flag)
    UserInfo.s_debug_mode = flag;
end


UserInfo.getDebugMode = function()
    return UserInfo.s_debug_mode or false;
end;


UserInfo.setPromptAutofeedtime = function(self,promptAutofeedtime)
    self.m_prompt_autofeedtime = promptAutofeedtime;
end

UserInfo.getPromptAutofeedtime = function(self)
    return self.m_prompt_autofeedtime;
end

UserInfo.setDanGrading = function(self,dan_grading)
    self.m_dan_grading = {};
    if dan_grading and dan_grading:get_value() then
        for i,v in pairs(dan_grading) do
            self.m_dan_grading[tonumber(i)] = {};
            for j,vv in pairs(v) do
                self.m_dan_grading[tonumber(i)][j] = vv:get_value();
            end
        end
    end
end

UserInfo.getDanGrading = function(self)
    return self.m_dan_grading;
end

UserInfo.getDanGradingName = function(self)
    local score = self:getScore();
    if self.m_dan_grading then
        for i,v in pairs(self.m_dan_grading) do
            if score >= v.min and score < v.max then
                return v.name or "";
            end
        end
    end
    return "";
end


UserInfo.getDanGradingNameByScore = function(self, score)
    if self.m_dan_grading then
        for i,v in pairs(self.m_dan_grading) do
            if score >= v.min and score < v.max then
                return v.name or "";
            end
        end
    end
    return "";
end


UserInfo.getDanGradingLevel = function(self)
    local score = self:getScore();
    if self.m_dan_grading then
        for i,v in pairs(self.m_dan_grading) do
            if score >= v.min and score < v.max then
                return i;
            end
        end
    end
    return 1;
end

UserInfo.getDanGradingLevelByScore = function(self,score)
    score = tonumber(score) or 0;
    if self.m_dan_grading then
        for i,v in pairs(self.m_dan_grading) do
            if score >= v.min and score < v.max then
                return i;
            end
        end
    end
    return 1;
end


UserInfo.setBindAccount = function(self,data)
    self.m_bindAccount = {};
    if data:get_value() == nil then return ;end
    for i,v in pairs(data) do
        self.m_bindAccount[i] = {};
        self.m_bindAccount[i].sid = tonumber(v.sid:get_value());
        self.m_bindAccount[i].bind_uuid = v.bind_uuid:get_value();
    end
end

UserInfo.getBindAccount = function(self)
    return self.m_bindAccount;
end

UserInfo.findBindAccountBySid = function(self,sid)
    if self.m_bindAccount then
        for i,v in pairs(self.m_bindAccount) do
            if v.sid == sid then
                return v.bind_uuid;
            end
        end
    end
end

UserInfo.updateBindAccountBySid = function(self,sid,bind_uuid)
    if self.m_bindAccount then
        for i,v in pairs(self.m_bindAccount) do
            if v.sid == sid then
                v.bind_uuid = bind_uuid;
                return ;
            end
        end
        local insert = {};
        insert.sid = sid;
        insert.bind_uuid = bind_uuid;
        table.insert(self.m_bindAccount,insert);
        return ;
    end
    self.m_bindAccount = {};
    local insert = {};
    insert.sid = sid;
    insert.bind_uuid = bind_uuid;
    table.insert(self.m_bindAccount,insert);
end

UserInfo.setJoinPlayedConsole = function(self, flag)
    self.m_isJoinPlayedConsole = flag;

end;
UserInfo.getJoinPlayedConsole = function(self)
    return self.m_isJoinPlayedConsole

end;


UserInfo.setIsFromHall = function(self, flag)

    self.m_isFromHall = flag;
end;
UserInfo.getIsFromHall = function(self)
    return self.m_isFromHall;

end;

UserInfo.setQQGroup = function(self,group)
    self.m_qqGroup = {};
    if group:get_value() then
        for i,value in pairs(group) do
            self.m_qqGroup[i] = value:get_value();
        end
    end
    local json_order = json.encode(self.m_qqGroup);
    GameCacheData.getInstance():saveString(GameCacheData.QQ_GROUP,json_order);
end

UserInfo.getQQGroupString = function(self)
    local str = "QQ沟通群:";
    if self.m_qqGroup == nil then
        local qqGroupJson = GameCacheData.getInstance():getString(GameCacheData.QQ_GROUP,"");
        if qqGroupJson and qqGroupJson ~= "" then
            self.m_qqGroup = json.decode(qqGroupJson);
        else
            self.m_qqGroup = {}
            self.m_qqGroup[1] = "460628319";
        end
    end
    for i,value in pairs(self.m_qqGroup) do
        str = str .. " " .. value;
    end
    return str;
end

UserInfo.setAdsStatus = function(self, btn, ads)
    self.m_ads_btn_status = btn;--大厅底部按钮状态，0关闭，1显示积分墙，2显示广告sdk
    self.m_is_show_ads =  ads;--退出时否显示插屏广告，0关闭，1显示
    
    if self.m_ads_btn_status and self.m_ads_btn_status == 2 then
        dict_set_string(kAdMananger,kAdMananger..kparmPostfix,AD_SHOW_BANNER_AD_DIALOG);
        call_native(kAdMananger);
    else
        dict_set_string(kAdMananger,kAdMananger..kparmPostfix,AD_REMOVE_RECOMMEND_BAR);
        call_native(kAdMananger);
    end
end;

UserInfo.getAdsStatus = function(self)
    return self.m_ads_btn_status or 0, self.m_is_show_ads or 0;
end;

UserInfo.s_cacheImage = {};
UserInfo.getCacheImageManager = function(url,what)
    if not url then return end
    Log.i("getCacheImageManager url:"..url);
    local info = {};
    info.ImageUrl = url;
    info.ImageName = md5_string(url.."CacheImageManager_0.0");
    info.what = what or "unknow";
    
    if not info.ImageName then return end;

    if UserInfo.s_cacheImage[info.ImageName..".png"] then
        return info.ImageName..".png";
    end

    dict_set_string(kCacheImageManager,kCacheImageManager..kparmPostfix,json.encode(info));
	call_native(kCacheImageManager);
end

UserInfo.saveCacheImageManager = function(name)
    UserInfo.s_cacheImage[name] = 1;
end

UserInfo.setChallenger = function(self, flag)
    self.m_challenger = flag;--是否发起挑战者，true是， false被挑战者， nil无
end

UserInfo.getChallenger = function(self)
    return self.m_challenger;
end

UserInfo.setTargetUid = function(self, uid)
    self.m_targetUid = uid;--是否发起挑战者，true是， false被挑战者， nil无
end

UserInfo.getTargetUid = function(self)
    return self.m_targetUid or 0;
end

UserInfo.setGameTimeInfo = function(self, info)         --棋局配置
    self.m_gameTimeInfo = {}
    local num = 1;
    if info and info:get_value() then
        for i,v in pairs(info) do
            if i == "default" then
                self:setGameTime(v);
            else
                self.m_gameTimeInfo[num] = {};
                self.m_gameTimeInfo[num].level = tonumber(i);
                self.m_gameTimeInfo[num].gameTime = {};
                self.m_gameTimeInfo[num].gameTime[1] = v.round_time[1]:get_value();
                self.m_gameTimeInfo[num].gameTime[2] = v.round_time[2]:get_value();
                self.m_gameTimeInfo[num].gameTime[3] = v.round_time[3]:get_value();
                self.m_gameTimeInfo[num].gameTime[4] = v.round_time[4]:get_value();
                self.m_gameTimeInfo[num].stepTime = {};
                self.m_gameTimeInfo[num].stepTime[1] = v.step_time[1]:get_value();
                self.m_gameTimeInfo[num].stepTime[2] = v.step_time[2]:get_value();
                self.m_gameTimeInfo[num].stepTime[3] = v.step_time[3]:get_value();
                self.m_gameTimeInfo[num].stepTime[4] = v.step_time[4]:get_value();
                self.m_gameTimeInfo[num].secondTime = {};
                self.m_gameTimeInfo[num].secondTime[1] = v.sec_time[1]:get_value();
                self.m_gameTimeInfo[num].secondTime[2] = v.sec_time[2]:get_value();
                self.m_gameTimeInfo[num].secondTime[3] = v.sec_time[3]:get_value();
                num = num + 1;
            end
        end
    end
end

UserInfo.getGameTimeInfoByLevel = function(self,level)
    if self.m_gameTimeInfo then
        for i,v in pairs(self.m_gameTimeInfo) do
            if v.level == level then
                return self.m_gameTimeInfo[i];
            end
        end
    end
end

UserInfo.setGameTime = function(self,info)          --推荐的棋局设置
    self.m_gameTime = {}
    local num = 1;
    if info and info:get_value() then
        for i,v in pairs(info) do
            self.m_gameTime[num] = {};
            self.m_gameTime[num].level = tonumber(i);
            self.m_gameTime[num].gameTime = v.round_time:get_value();
            self.m_gameTime[num].stepTime = v.step_time:get_value();
            self.m_gameTime[num].secondTime = v.sec_time:get_value();
            num = num + 1;
        end
    end
end

UserInfo.getGameTimeByLevel = function(self,level)
    if self.m_gameTime then
        for i,v in pairs(self.m_gameTime) do
            if v.level == level then
                return self.m_gameTime[i];
            end
        end
    end
end

UserInfo.setLastGameTime = function(self,info)              --上一局的棋局设置
    self.m_lastGameTime = info;
end

UserInfo.getLastGameTimeByLevel = function(self,level)
    if self.m_lastGameTime and self.m_lastGameTime.level == level then
        return self.m_lastGameTime;
    end
end

UserInfo.setRoomPlayerNum = function(self,data)              --房间人数data,{0,0,0}
    self.m_roomPlayerNum = data;
end

UserInfo.getRoomPlayerNum = function(self)
    return self.m_roomPlayerNum or {};
end

UserInfo.getAcountList = function(self)
    if not self.m_acountList then
        self.m_acountList = json.decode(GameCacheData.getInstance():getString(GameCacheData.ACOUNT_LIST,nil)) or {};
        -- 这里设计的弄的自己sb了  郁闷
        local list = UserInfo.getDefaultLoginType(self);
        local removelist = UserInfo.getRemoveLoginType(self);
        -- 为了兼容老版本 添加新的登录方式
        for i,v in ipairs(list) do
            local isFind = false
            for j,acount in ipairs(self.m_acountList) do
                if not acount.new_uuid and acount.loginType == v.loginType then
                    isFind = true
                    break
                end
            end
            if not isFind then
                table.insert(self.m_acountList,v)
            end
        end

        for i,v in ipairs(removelist) do
            local isFind = false
            for j,acount in ipairs(self.m_acountList) do
                if not acount.new_uuid and acount.loginType == v.loginType then
                    table.remove(self.m_acountList,j)
                    break
                end
            end
        end

        UserInfo.getInstance():saveAcountList(self.m_acountList);
    end 
    return self.m_acountList;
end

UserInfo.saveAcountList = function(self,datas)
    self.m_acountList = datas;
    GameCacheData.getInstance():saveString(GameCacheData.ACOUNT_LIST,json.encode(self.m_acountList));
    Log.i("aaaaa "..json.encode(self.m_acountList));
end

UserInfo.getDefaultLoginType = function(self)
    local datas = {};
    local data = {};
    data = {};
    data.loginType = UserInfo.s_acountType.youke;--游客
    table.insert(datas,data);
    data = {};
    data.loginType = UserInfo.s_acountType.phone;--手机
    table.insert(datas,data);
    data = {};
    data.loginType = UserInfo.s_acountType.weibo;--微博
    table.insert(datas,data);
    data = {};
    data.loginType = UserInfo.s_acountType.wechat;--微信
    table.insert(datas,data);
    data = {};
    data.loginType = UserInfo.s_acountType.boyaa;--博雅
    table.insert(datas,data);
    data = {};
    data.loginType = UserInfo.s_acountType.qq;--qq
    table.insert(datas,data);
    return datas;
end

UserInfo.getRemoveLoginType = function(self)
    local datas = {};
    local data = {};
--    data = {};
--    data.loginType = UserInfo.s_acountType.youke;--游客
--    table.insert(datas,data);
--    data = {};
--    data.loginType = UserInfo.s_acountType.phone;--手机
--    table.insert(datas,data);
--    data = {};
--    data.loginType = UserInfo.s_acountType.weibo;--微博
--    table.insert(datas,data);
--    data = {};
--    data.loginType = UserInfo.s_acountType.wechat;--微信
--    table.insert(datas,data);
--    data = {};
--    data.loginType = UserInfo.s_acountType.boyaa;--博雅
--    table.insert(datas,data);
--    data = {};
--    data.loginType = UserInfo.s_acountType.qq;--qq
--    table.insert(datas,data);
    return datas;
end



UserInfo.s_acountType = {};
UserInfo.s_acountType.youke = 1;
UserInfo.s_acountType.phone = 2;
UserInfo.s_acountType.weibo = 3;
UserInfo.s_acountType.wechat = 4;
UserInfo.s_acountType.boyaa = 5;
UserInfo.s_acountType.qq    = 6;

UserInfo.getAcountNewUuid = function(self)
    return self.m_acount_new_uuid;
end

UserInfo.setAcountNewUuid = function(self,new_uuid)
    self.m_acount_new_uuid = new_uuid;
end

UserInfo.getAcountLoginType = function(self)
    return self.m_acount_login_type;
end

UserInfo.setAcountLoginType = function(self,login_type)
    self.m_acount_login_type = tonumber(login_type);
end

UserInfo.updateAcountList = function(self) -- flag true 登录第三方返回，false 登录大厅返回
    local datas = self:getAcountList();
    local ret = {};
    local swap = false;
    for i,v in ipairs(datas) do
        if v.mid == self:getUid() then
            swap = true;
            v.name = self:getName();
            v.iconType = self:getIconType();
            v.icon = self:getIcon();
            table.insert(ret,1,v);
        else
            table.insert(ret,v);
        end
    end
    if not swap and self.m_cacheAcountList then
        local user = nil;
        for i,v in ipairs(self.m_cacheAcountList) do
            if v.mid == self:getUid() then
                user = v;
            end
        end
        if user then
            if user.loginType == UserInfo.s_acountType.youke then
                -- 游客不显示头像了  
            else
                local data = {};
                data.new_uuid = user.new_uuid
                data.loginType = user.loginType;
                data.mid = user.mid;
                data.name = self:getName();
                data.iconType = self:getIconType();
                data.icon = self:getIcon();
                table.insert(ret,1,data);
            end
        end
    end
    self:saveAcountList(ret);
end

UserInfo.insertCacheAcountList = function(self,new_uuid,mid)
    if not new_uuid or not mid or not self.m_acount_login_type then return end;
    if not self.m_cacheAcountList then
        self.m_cacheAcountList = {};
    end
    for i,v in ipairs(self.m_cacheAcountList) do
        if v.mid == mid then return end;
    end
    local data = {};
    data.new_uuid = new_uuid;
    data.mid = mid;-- 游客这里是 0
    data.loginType = self.m_acount_login_type;
    table.insert(self.m_cacheAcountList,data);
end

UserInfo.setCustomDapuType = function(self, customtype)
    self.m_custom_dapu_type = customtype;
end;

UserInfo.getCustomDapuType = function(self)
    return self.m_custom_dapu_type or 0; -- 0：默认打谱,1：残局打谱
end;


UserInfo.saveProp = function(id,num)
    num = tonumber(num);
    if not num then return end;

    local user = UserInfo.getInstance();
    if id == kLifeNum then
        user:setLifeNum(num or 0);

    elseif id == kUndoNum then
        user:setUndoNum(num or 0);

    elseif id == kTipsNum then
        user:setTipsNum(num or 0);

    elseif id == kReviveNum then
        user:setReviveNum(num or 0);

    elseif id == kLifeLimitNum then
        user:setLifeLimitNum(num or 0);

    end
end

UserInfo.setGameShareUrl = function(self,qr_code,download_url)
    self.m_qr_code = qr_code;
    self.m_qr_download_url = download_url;
end

UserInfo.getGameShareUrl = function(self)
    return self.m_qr_code,self.m_qr_download_url;
end

UserInfo.setInviteFriendsUrl = function(self,inviteUrl)
    self.mInviteFriendsUrl = inviteUrl;
end

UserInfo.getInviteFriendsUrl = function(self)
    return self.mInviteFriendsUrl;
end

UserInfo.setShareEndgateUrl = function(self,shareEndgateUrl)
    self.mShareEndgateUrl = shareEndgateUrl;
end

UserInfo.getShareEndgateUrl = function(self)
    return self.mShareEndgateUrl;
end

UserInfo.setUploadThridHeadImg = function(self,url)
    self.mUploadThridHeadImg = url;
end

UserInfo.getUploadThridHeadImg = function(self)
    return self.mUploadThridHeadImg;
end

UserInfo.setAccountType = function(self,type)
    self.m_account_type = type;
end

UserInfo.getAccountType = function(self)
    return self.m_account_type;
end

--account_type 账号类型
--VigoXu(徐恩) 11-09 18:04:21
--   10 => '新浪微博',
--        20 => '360',
--        30 => 'QQ',
--        202 => 'OPPO',
--        205 => '联想账号',
--        208 => '中游帐号',
--        210 => '华为账号',
--        213 => '起凡',
--        40 => '博雅通行证',
--        217 => '百度账号',
--        //下面为新加
--        1 => '手机账号',
--        //2 => '邮箱账号',
--        3 => '微信账号',

--        //默认值
--        201 => '游客',
--        318 => '安智账号',
--        319 => '钱宝账号'
UserInfo.getAccountTypeName = function(self)
    if self.m_account_type == 10 then
        return "新浪微博";
    elseif self.m_account_type == 30 then
        return "QQ帐号"
    elseif self.m_account_type == 20 then
        return "360帐号";
    elseif self.m_account_type == 202 then
        return "OPPO账号";
    elseif self.m_account_type == 205 then
        return "联想账号";
    elseif self.m_account_type == 208 then
        return "中游帐号";
    elseif self.m_account_type == 210 then
        return "华为账号";
    elseif self.m_account_type == 213 then
        return "起凡";
    elseif self.m_account_type == 40 then
        return "博雅通行证";
    elseif self.m_account_type == 217 then
        return "百度账号";
    elseif self.m_account_type == 1 then
        return "手机账号";
    elseif self.m_account_type == 2 then
        return "邮箱账号";
    elseif self.m_account_type == 3 then
        return "微信账号";
    elseif self.m_account_type == 101 then
        return "游客";
    elseif self.m_account_type == 301 then
        return "游客";
    elseif self.m_account_type == 103 then
        return "游客";
    elseif self.m_account_type == 104 then
        return "游客";
    elseif self.m_account_type == 201 then
        return "游客";
    elseif self.m_account_type == 318 then
        return "安智账号";
    elseif self.m_account_type == 319 then
        return "钱宝账号";
    elseif self.m_account_type == 317 then
        return "移动MM"
    elseif self.m_account_type == 211 then
        return "联通wo商店"
    elseif self.m_account_type == 204 then
        return "爱游戏"
    elseif self.m_account_type == 320 then
        return "九游账号"
    elseif self.m_account_type == 313 then
        return "联想账号"
    end
    return self.m_account_type;
end

UserInfo.setOpenWeixinShare = function(self,flag)
    self.m_open_weixin_share = flag;
end

UserInfo.getOpenWeixinShare = function(self)
    return self.m_open_weixin_share or 0;
end

--[Comment]
--更新设置列表状态
function UserInfo.updateVipStatus(self,isVip)
    self:setIsVip(isVip);
    local typeStr = "sys";
    if not isVip or isVip == 0 then
        typeStr = "sys";
    else
        typeStr = "vip";
    end

    local info = {};
    info.picture_frame = typeStr;
    info.piece = typeStr;
    info.board = typeStr;
    self:setUserSet(info)
    UserSetInfo.getInstance():setBoardType(typeStr);
    UserSetInfo.getInstance():setChessPieceType(typeStr);
    UserSetInfo.getInstance():setHeadFrameType(typeStr);
end

--[Comment]
function UserInfo.setGift(self,data)
    local tab = {}
    if data then  
        tab = json.analyzeJsonNode(data)
    end
    local temp = {}
    for k,v in pairs(tab) do
        if v then
            temp[v.gift_id] = v.gift_num
        end
    end
    self.m_giftList = temp;
end

--[Comment]
function UserInfo.updataGiftNum(self,gift_type,num)
    if not gift_type or not num then return  end
--    local tab = {}
--    tab.gift_id = gift_type
--    tab.gift_num = num
    if not self.m_giftList or next(self.m_giftList) == nil then
        self.m_giftList = {}
--        self.m_giftListgift_type
--        return
    end
    local n1 = tonumber(self.m_giftList[gift_type .. ""]) or 0 
    self.m_giftList[gift_type .. ""] = num + n1
--    for k,v in pairs(self.m_giftList) do
--        if v then
--            if v.gift_id == gift_type then
--                v.gift_num = v.gift_num + num
--            end
--        end
--    end

end

--[Comment]
--返回收到的礼物
function UserInfo.getGift(self)
    return self.m_giftList or {}
end

--[Comment]
--返回收到的礼物
function UserInfo.getGift2(self)
    return self.m_giftList or {}
end

--[Comment]
--返回礼物数量
--id:  礼物id
function UserInfo.getGiftNum(self,id)
    local num = 0
    if not self.m_giftList then 
        return num 
    else
        num = self.m_giftList[id] or 0
        return  num
    end
end

if kPlatform == kPlatformIOS then
    UserInfo.setIosAppStoreEvaluate = function(self, data)
	    self.m_iosAppStoreEvalue = data.is_open;
	    self.m_continue_win_times = data.day_win;
    end;


    UserInfo.getIosAppStoreEvaluate = function(self, data)
	    return self.m_iosAppStoreEvalue or 0 , self.m_continue_win_times or 2;
    end;

    function UserInfo.setCanShowIOSAppstoreReview(self, yesOrNo)
        -- 1为可以弹窗 0为不可以弹窗
        self.canShowIOSAppstoreReview = tonumber(yesOrNo);
    end

    function UserInfo.getCanShowIOSAppstoreReview(self)
        return self.canShowIOSAppstoreReview;
    end

end;

-- 大厅聊天室30s发送消息限制条数
UserInfo.setChatRoomItemCountIn30s = function(self,count)
    self.m_chatroom_chat_limit_count = count;
end;

UserInfo.getChatRoomItemCountIn30s = function(self)
    return self.m_chatroom_chat_limit_count or 6;
end;

UserInfo.setTicketData = function(self,data)
    self.ticket_data = data
end;

UserInfo.getTicketData = function(self)
    return self.ticket_data or {};
end;

UserInfo.setSignAture = function(self,data)
    self.signAture = data
end;

UserInfo.getSignAture = function(self)
    return self.signAture or ""
end;

UserInfo.setModifyMnick = function(self,flag)
    self.is_modify_mnick = flag;
end;

UserInfo.getModifyMnick = function(self)
    return self.is_modify_mnick or false;
end;

UserInfo.setCurrentChatRoomId = function(self,id)
    self.m_cur_chatroom_id = id;
end;

UserInfo.getCurrentChatRoomId = function(self)
    return self.m_cur_chatroom_id or "";
end;

UserInfo.setCurrentChatRoomMsgId = function(self,id)
    self.m_cur_chatroom_msg_id = id;
end;

UserInfo.getCurrentChatRoomMsgId = function(self)
    return self.m_cur_chatroom_msg_id or 0;
end

--[Comment]
-- 是否新手评测过
UserInfo.isHasEvaluation = function(self)
    return self.mIsHasEvaluation ~= 0
end
--[Comment]
-- 设置新手评测过
UserInfo.setHasEvaluation = function(self)
    self.mIsHasEvaluation = 1
end
--[Comment]
-- 双倍积分卡
UserInfo.setDoubleProp = function(self,use_time,count_time)
    self.m_double_prop = {};
    self.m_double_prop.count_time = tonumber(count_time) or 0
    self.m_double_prop.use_time = tonumber(use_time) or 0
    self.m_double_prop.end_time = os.time() + self.m_double_prop.count_time
end
--[Comment]
-- 是否有双倍积分卡
UserInfo.isHasDoubleProp = function(self)
    if not self.m_double_prop then return false end
    if self.m_double_prop.use_time <= 0 or self.m_double_prop.end_time <= os.time() then return false end
    return true
end
--[Comment]
-- 倒计时
UserInfo.getDoublePropCountTime = function(self,prop)
    if not self.m_double_prop then return 0 end
    return self.m_double_prop.count_time
end
--[Comment]
-- 结束时间
UserInfo.getDoublePropEndTime = function(self,prop)
    if not self.m_double_prop then return 0 end
    return self.m_double_prop.end_time
end
--[Comment]
-- 使用次数
UserInfo.getDoublePropUseTime = function(self,prop)
    if not self.m_double_prop then return 0 end
    return self.m_double_prop.use_time
end

function UserInfo:isLockCompete()
    return self.mIslockCompete == 1
end

function UserInfo:unlockCompete()
    self.mIslockCompete = 0
end

function UserInfo:getLockCompete()
    return self.mLockCompeteCount or 30
end

function UserInfo:setLockCompete(num)
    self.mLockCompeteCount = tonumber(num) or 30
    if self:canUnlockCompete() then 
        self.mIslockCompete = 0 
    else
        self.mIslockCompete = 1
    end
end

function UserInfo:canUnlockCompete()
    return (self:getWintimes() + self:getLosetimes() + self:getDrawtimes()) >= self:getLockCompete()
end

function UserInfo:isLockRoomChat()
    return (self:getWintimes()) <= self:getLockRoomChat()
end

function UserInfo:setLockRoomChat(num)
    self.mLockRoomChatCount = tonumber(num) or 10
end

function UserInfo:getLockRoomChat()
    return self.mLockRoomChatCount or 10
end

--检测用户是否能使用自定义头像的功能，true为不能
function UserInfo:isLockSetCustomAvatar()
    return (self:getWintimes() + self:getLosetimes() + self:getDrawtimes()) < 20
end

--检测是否需要提醒用户去设置昵称,true为需要
function UserInfo:isNeedRemindSetNickname()
    return (self:getWintimes() + self:getLosetimes() + self:getDrawtimes()) >= 15
end

-- 促销商品
function UserInfo:setPromotionSaleGoodsData(data)
    self.mPromotionSaleGoodsData = data
    if self.mPromotionSaleGoodsData and self.mPromotionSaleGoodsData.remain_time then
        self.mPromotionSaleGoodsData.endTime = os.time() + self.mPromotionSaleGoodsData.remain_time
    else
        self.mPromotionSaleGoodsData.endTime = 0
    end
end
-- 促销商品
function UserInfo:getPromotionSaleGoodsData()
    return self.mPromotionSaleGoodsData
end