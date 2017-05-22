require("gameBase/httpManager");
require("libs/json_wrap");
require("util/netconfig");

HttpModule = class();

HttpModule.s_event = EventDispatcher.getInstance():getUserEvent();

HttpModule.getInstance = function()
	if not HttpModule.s_instance then 
		HttpModule.s_instance = new(HttpModule);
	end
	return HttpModule.s_instance;
end

HttpModule.releaseInstance = function()
	delete(HttpModule.s_instance);
	HttpModule.s_instance = nil;
end

HttpModule.ctor = function(self)
	self.m_httpManager = new(HttpManager,HttpModule.s_config,HttpModule.postDataOrganizer,HttpModule.urlOrganizer);
	EventDispatcher.getInstance():register(HttpManager.s_event,self,self.onHttpResponse);
end

HttpModule.dtor = function(self)
	EventDispatcher.getInstance():unregister(HttpManager.s_event,self,self.onHttpResponse);
	delete(self.m_httpManager);
	self.m_httpManager = nil;
end


HttpModule.postDataOrganizer = function(method,data,isFeedBack,isNew)  -- post 数据
    if not isNew then
        local post_data = {};
        PhpConfig.genTreeMap(post_data); -- php  必要头请求
	    --调用的PHP方法	
        post_data.method = method;
	    --用户参数
        post_data.param = data;
        post_data.param.method = method;

        local signature = HttpModule.joins(post_data,post_data.mtkey); --签名验证
        post_data.sig = md5_string(signature);
	    local data = "api="..json.encode(post_data);
	    print_string("HttpManager.getData = "  .. data);
	    return data;
    else
        local post_data = {};
        PhpConfig.genTreeMap(post_data); -- php  必要头请求
	    --调用的PHP方法	
        post_data.method = method;
	    --用户参数
        post_data = CombineTables(post_data,data);
        local signature = HttpModule.joins(post_data,post_data.mtkey); --签名验证
        post_data.sig = md5_string(signature);
	    local data = "api="..json.encode(post_data);
	    print_string("HttpManager.getData = "  .. data);
	    return data;
    end
end

HttpModule.postDataOrganizerH5 = function(method,postData)  -- post 数据
	local data = "method="..method;
    for i,v in pairs(postData) do
        data = data.."&"..i.."="..v;
    end
	print_string("HttpManager.getData = "  .. data);
	return data;
end

HttpModule.joins = function(t,mtkey)
  return Joins(t,mtkey);
end

HttpModule.urlOrganizer = function(url,method,httpType)  -- get url 拼接
	if httpType == kHttpPost then
        
		return url;
	end

	return url;
end

HttpModule.execute = function(self,command,data,tip,canCancel,level,isNeedMask)
	self.m_httpManager:execute(command,data,tip,canCancel,level,isNeedMask);
end

HttpModule.execute2 = function(self,command,data,callbackFunc)
    self.m_httpManager:execute2(command,data,callbackFunc)
end


HttpModule.onHttpResponse = function(self,command,errorCode,data)
	local config = HttpModule.s_config[command];
	local method = config[HttpConfigContants.METHOD];

    if errorCode == HttpErrorType.SUCCESSED then
        local flag,message = HttpModule.explainPHPFlag(data);
        EventDispatcher.getInstance():dispatch(HttpModule.s_event,command,flag,data,message);
    else
        EventDispatcher.getInstance():dispatch(HttpModule.s_event,command,false,errorCode);
    end

end

HttpModule.getConfigMap = function(self)
	return self.m_httpManager:getConfigMap();
end

HttpModule.setConfigMap = function(self,configMap)
	self.m_httpManager:setConfigMap(configMap);
end

HttpModule.updateConfig = function(self,index,tab)
    if not tab or type(tab) ~= "table" then return end
    HttpModule.s_config[index] = tab;
    self.m_httpManager:setConfigMap(HttpModule.s_config);
end

HttpModule.explainPHPFlag = function(message)
	if not message  or not message.flag:get_value() then
		return;
	end
	-- Log.i("message.flag =  " .. flag);
    local flag = tonumber(message.flag:get_value());
	print_string("message.flag =  " .. flag);
	if flag == 10000 then 
		return true,"返回成功";
	elseif flag == 10001 then 
		return false , "参数验证失败";
	elseif flag == 10002 then 
		return false , "注册失败";
	elseif flag == 10003 then 
		return false , "没有该用户";
	elseif flag == 10004 then 
		return false , "没有权限/封号";
	elseif flag == 10005 then  
		return false , "参数错误"; 
	elseif flag == 10006 then 
		return false , "参数格式错误";
	elseif flag == 30001 then 
		return false , "匹配、创建棋盘失败";
	elseif flag == 30002 then 
		return false , "棋局保存失败";
	elseif flag == 30003 then 
		return false , "没有棋局记录或获取失败";
	elseif flag == 30004 then 
		return false , "参与或创建的棋局已经超过次数限制（50次)";
	elseif flag == 30005 then 
		return false , "发起或确认求和失败";
	elseif flag == 30006 then 
		return false , "认输失败";
	elseif flag == 30007 then 
		return false , "异步聊天信息保存失败";
	elseif flag == 30008 then 
		return false , "删除已经完成的棋局记录失败";
	elseif flag == 30009 then 
		return false , "重复走棋";
	elseif flag == 30010 then 
		return false , "指定对手不能是自己";
	elseif flag == 40000 then
		return flag;
	elseif flag == 200 then 
		return true,"请求成功 ps：不代表业务逻辑处理成功";
	elseif flag == 100 then 
		return false , "权限检查错误";
	elseif flag == 101 then 
		return false , "少必需参数";
	elseif flag == 102 then 
		return false , "参数格式错误";
	elseif flag == 103 then 
		return false , "方法错误";
	elseif flag == 104 then  
		return false , "注册失败"; 
	elseif flag == 105 then 
		return false , "获取玩家信息失败";
	elseif flag == 106 then 
		return false , "被封号，无法进入";
	elseif flag == 107 then 
		return false , "文件格式上传有误";
    elseif flag == 10 then
        return false, "金币不足";
	elseif flag == 1 then
        return true,"反馈中心请求成功 ps：不代表业务逻辑处理成功";
   elseif flag == 11 then
        return false ,"手机号或邮箱格式不正确";
    elseif flag == 12 then
        return false ,"账号已经绑定";
    elseif flag == 13 then
        return false ,"验证码错误";
    elseif flag == 14 then
        return false ,"用户不存在";
    elseif flag == 15 then
        return false ,"绑定失败";
    elseif flag == 16 then
        return false ,"发送失败";
    elseif flag == 17 then
        return false ,"缺少参数";
    else 
		return false , "未知错误";
	end
end

HttpModule.s_cmds = 
{
	LoginWin32                      = 1,
    GuestZhLogin                    = 2;
    GetDailyList                    = 3;
    GetDailyReward                  = 4;
    GetConsoleProgress              = 5;
    UploadConsoleProgress           = 6;
    saveUserInfo                    = 7;
    checkVersion                    = 8;
    getNotice                       = 9;
    getScoreRank                    = 10;
    getMoneyRank                    = 11;
    getCollapseReward               = 12;
    getUserInfo                     = 13;
    getMallShopInfo                 = 14;
    getPointShopInfo                = 15;
    getUserPointScore               = 16;
    isPointWallAvailable            = 17;
    pointExchange                   = 18;
    downloadGateInfo                = 19;
    getBoothInfo                    = 20;
    uploadGateInfo                  = 21;
    checkEndingUpdate               = 22;
    sendFeedback                    = 23;
    getFeedBack                     = 24;
    getPropList                     = 25;
    getShopInfo                     = 26;
    getWatchGame                    = 29;
    getOnlineReward                 = 30;
    exchangeProp                    = 31;
    uploadOrDownPropData            = 32;
    addDeliverLog                   = 33;
    enthralmentRequest              = 34;
    sendCode                        = 35;
    bindUid                         = 36;
    loginThirdLogin                 = 37;
    getSoulList                     = 38;
    exchangeSoul                    = 39;
    GetNewDailyList                 = 40;
    GetNewDailyReward               = 41;
    getTaskProgress                 = 42;
    statRewardPerLevel              = 43;
    getSoul                         = 44;
    uploadConsole2Php               = 45;
    createOrder                     = 46;
    boothShare                      = 47;
    searchFriends                   = 48;
    charmList                       = 49; -- 魅力榜
    getFriendUserInfo               = 50;
    mailListCll                     = 51;
    chickPaiHangBang                = 52; -- 排行榜查询
    recommendMailListCll            = 53; -- 好友推荐
    reportRecommend                 = 54;
    checkVersion_new                = 55; -- 新的检查更新接口
    shareToBoyaa                    = 56; -- 分享博雅棋友
    goodsUploadProp                 = 57; -- 道具上传
    boyaaSendCode                   = 58; -- boyaa找回密码 电话验证码
    findPasswordByPhone             = 59;
    findPasswordByEmail             = 60;
    shareToPYQ                      = 61; -- 分享朋友圈
    shareToWX                       = 62; -- 分享博雅棋友
    reportBad                       = 63; -- 举报
    uploadConsoleProgress           = 64; -- 上报单机进度
    getConsoleProgress              = 65; -- 同步单机进度
    getRecentWarUser                = 66; -- 最近对战玩家
    getReward                       = 67; -- 新抽奖
    uploadGetuiClientid             = 68; -- 上报个推CID;
    getCityConfig                   = 69; -- 获取城市列表
    saveMychess                     = 70; -- 保存最近棋局到我的收藏
    getMychess                      = 71; -- 获取我的收藏
    getAllChessComment              = 72; -- 获取全部评论
    getHotChessComment              = 73; -- 获取热门评论
    shareComment                    = 74; -- 增加评论
    openOrSelfChess                 = 75; -- 公开或私密棋谱
    delMySaveChess                  = 76; -- 删除我的收藏
    getHotComment                   = 77; -- 获取热门评论
    getAllComment                   = 78; -- 获取全部评论
    setLikeComment                  = 79; -- 点赞或取消赞
    uploadLog                       = 80; -- 分享到微信等平台数据上报
    getMonthCombat                  = 81; -- 获取战绩接口
    v2CheckUpdate                   = 82; -- 残局版本检测
    WulinBoothCreate                = 83; -- 创建武林残局
    WulinBoothBuyBooth              = 84; -- 购买武林残局
    WulinBoothUploadLog             = 85; -- 上传武林残局日志
    WulinBoothUploadMoveList        = 86; -- 通关武林残局上报走法
    WxBoothCreateBooth              = 87; -- 创建微信残局
    WulinBoothExpose                = 88; -- 举报武林残局
    WulinBoothReportCollect         = 89; -- 武林残局收藏上报
    sendFeedBackScore               = 90; -- 发送反馈评分
    IndexGetNotice                  = 91; -- 拉取公告
    WulinBoothReportShare           = 92; -- 武林残局分享上报
    IndexGetActionList              = 93; -- 活动
    getSameCityRecommend            = 94; -- 同城成员推荐
    getSameCityMember               = 95; -- 同城成员
    uploadMySet                     = 96; -- 更新用户设置
    appStorePayOrder                = 97; -- 通知php发货
    appStoreCheckSwitch             = 98; -- appStore审核开关
    appStoreEvaluate                = 99; -- appStore评价配置
    IndexStartConfig                = 100; -- 启动页控制
    IndexClientReportLog            = 101; -- 日志上报php
    UserMailGetMyMail               = 102; -- 获取我的消息
    UserMailAction                  = 103; -- 执行我的消息
    UserMailSeeMail                 = 104; -- 查看我的消息
    UserMailDel                     = 105; -- 删除我的消息
    UserMailGetNewMailNumber        = 106; -- 获取新消息数目
    GetNewBankruptReward            = 107; -- 领取破产补助
    CheckBankruptReward             = 108; -- 查询破产补助
    getCircleDynamics               = 109; -- 加载好友动态
    FriendsGetRecentWarUser         = 110; -- 获取最近对手
    FriendsAddFriend                = 111; -- 添加关注
    WulinBoothRecommend             = 112; -- 获得街边残局推荐棋谱
    WulinBoothMyCreateBooth         = 113; -- 获得街边残局我的创建
    WulinBoothGetBoothTimeList      = 114; -- 获取街边残局 时间排序
    WulinBoothGetBoothJackpotList   = 115; -- 获取街边残局 奖池排序
    getSignReward                   = 116; -- 领取每日签到奖励
    IndexGetPushActionList          = 117; -- 活动强推
    WulinBoothMark                  = 118; -- 标记街边残局
    WulinBoothDelMark               = 119; -- 删除街边残局标记
    WulinBoothGetMyMark             = 120; -- 获得标记街边残局
    countToPHP                      = 121; -- 统计上报
    WulinBoothGetBoothInfo          = 122; -- 获取武林残局数据
    ArenaGetCurrentRank             = 123; -- 获得竞技场本周排行榜
    ArenaGetPrevRank                = 124; -- 获得竞技场上周排行榜
    ArenaGetRuleText                = 125; -- 获取竞技场规则
    BoothBuyGate                    = 126; -- 购买残局
    getSociatyInfo                  = 127; -- 获得棋社信息
    getRecommendSociaty             = 128; -- 获得推荐棋社信息
    createSociaty                   = 129; -- 创建棋社
    applyJoinSociaty                = 130; -- 申请加入棋社
    getSociatyMemberInfo            = 131; -- 获得棋社成员信息
    getSociatyApplyMsg              = 132; -- 获得棋社申请
    managerSociaty                  = 133; -- 管理棋社接口
    modifySociatyInfo               = 134; -- 修改棋社信息
    quitSociaty                     = 135; -- 退出棋社
    sociatyRank                     = 136; -- 棋社排行
    getFeedbackInfo                 = 137; -- 获取反馈信息
    getGrowTaskList                 = 138; -- 获取成就任务列表
    getGrowTaskReward               = 139; -- 获取成就任务奖励
    upLoadLbs                       = 140; -- 上传经纬度
    IndexGetMatchConfig             = 141; -- 比赛房配置
    IndexGameHelp                   = 142; -- 获取帮助文体
    getManualByMid                  = 143; -- 获得棋友公开收藏棋谱
    getFriendCombat                 = 144; -- 获取好友之间对战战绩
    UserRealNameAuth                = 145; -- 上传实名验证
    UserGetIsRealNameAuth           = 146; -- 获得实名认证情况
    IndexCreateShortUrl             = 147; -- 获得短链接
    friendsCharmList                = 148; -- 好友魅力榜
    friendsScoreList                = 149; -- 好友积分榜
    friendsMoneyList                = 150; -- 好友财富榜
    getMatchList                    = 151; -- 获取比赛列表
    joinMatch                       = 152; -- 报名比赛
    MatchRank                       = 153; -- 获取比赛排名
    exitMatch                       = 154; -- 取消报名
    matchStatus                     = 155; -- 更新比赛状态
    MatchRank2                      = 156; -- 比赛房间内刷新排名
    MatchRebuy                      = 157; -- 比赛复活
    MatchGetRebuyMoney              = 158; -- 比赛复活消耗文本
    qrcode                          = 159; -- 兑换码
    saveMychessAndShare             = 160; -- 收藏+分享
    getMatchRule                    = 161; -- 比赛规则
    getUserTicket                   = 162; -- 参赛券
    checkPassword                   = 163; -- 验证邀请码
    getMatchPrize                   = 164; -- 领取比赛奖励
    getGiftWeekRank                 = 165; -- 礼物周排行
    MatchGetHistory                 = 166; -- 获取上期和历史数据
    matchAdDialog                   = 167; -- 比赛广告页宣传
    loadChatRoomInfo                = 168; -- 拉取聊天室列表
    getChatMatchConfig              = 169; -- 获取聊天室友谊赛配置
    getChatRoomManualInfo           = 170; -- 获取聊天室约战棋谱
    MatchGetApplyList               = 171; -- 分页拉取报名名单
    MatchLike                       = 172; -- 比赛点赞
    checkHornMsg                    = 173; -- 检测用户小喇叭
    MatchHallRecommend              = 174; -- 大厅比赛广告
    uploadIosClientid               = 175; -- 上传ios推送token
    GetDailyData                    = 176; -- 获得每日签到数据
    getSociatyVp                    = 177; -- 获取棋社副会长
    guildExpose                     = 178; -- 棋社禁言
    addBlackList                    = 179; -- 加入黑名单
    BlackListGetList                = 180; -- 获取黑名单列表
    BlackListDel                    = 181; -- 从黑名单移除
    IndexGetBatchNotice             = 182; -- 分页拉取公告
    MatchCancelLike                 = 183; -- 取消比赛点赞
    UserUserBehaviorStatistic       = 184; -- 新增用户行为统计
    GetChessManualId                = 185; -- 获取分享棋谱id
    UploadChessShareNum             = 186; -- 上传棋谱分享数量
    GuildCheckGuildExpose           = 187; -- 检测棋社成员禁言状态
    GuildDelGuildExpose             = 188; -- 接触棋社禁言
    getAndroidEvaluateConfig        = 189; -- android 审核开关
    UserGetUserGoodsInfo            = 190; -- 获取用户商品有效期
    UserNewUserEvaluating           = 191; -- 新手评测
    UserGetDoubleCardsInfo          = 192; -- 新手评测获取双倍积分卡
    ArenaGetWitnessContributionRank = 193; -- 获取观战者魅力值贡献者排行榜
    ArenaGetWitnessPresentMoneyRank = 194; -- 获取观战者赠送礼物金币价值排行榜
    UserGetUserGiftNum              = 195; -- 获取对局中用户礼物数量
    UserExchangeHistory             = 196; -- 获取用户兑换历史纪录
    UserModifyNameByMoney           = 197; -- 通过钱修改昵称
    GuildModifyGuildName            = 198; -- 修改棋社名称
    GuildCheckCreateGuildRight      = 199; -- 检测创建棋社条件
    getFriendUserRecordInfo         = 200; -- 获取用户战绩信息
    getFriendUserHonorInfo          = 201; -- 获取用户荣誉信息
    GoodsGetPromotionSaleGoods      = 202; -- 特殊促销商品
    GuildCheckGuildDataLegal        = 203; -- 检测创建棋社参数是否正确
    IndexStatisticGiftInfo          = 204; -- 特殊商品礼包客户端上报
    UserGetSingleProgressCfg        = 205; -- 单机配置
    UserGuns                        = 206; -- 购买单机火炮
    UserBuyJn                       = 207; -- 购买锦囊 
    UserBuyLevel                    = 208; -- 购买关卡
    getUserFreezeType               = 209; -- 获取用户封号类型
    checkoutUserFreezeFrame         = 210; -- 获取用户是否被禁止上传自定义头像
    getIOSReviewPrize               = 211; -- 获取iOS评分奖品
    getPassBoothNumbers             = 212; -- 获取某关残局通过的人数
};
--个推URL------------------------------------------
--测试url：http://192.168.100.148/pokerlord/api.php 
--线上url：http://pcusspll02.ifere.com/pokerlord/api.php 
--个推URL------------------------------------------

--  php 配置
--  URL = 1,
--	METHOD = 2,
--	TYPE = 3,
--	TIMEOUT = 4,
--
require("config/php_config");
HttpModule.initConfig = function()
HttpModule.s_config = 
{
	[HttpModule.s_cmds.LoginWin32] = {
		PhpConfig.new_developUrl,
		"Login.guest",
	},	
    [HttpModule.s_cmds.GuestZhLogin] = {
		PhpConfig.new_developUrl,
	(kPlatform == kPlatformIOS and	"Login.iosLogin") or "Login.guest",
	},
    [HttpModule.s_cmds.GetDailyList] = {
		PhpConfig.GET_DAILY_URL,
		PhpConfig.METHOD_GETDAILYLIST,
	},
    [HttpModule.s_cmds.GetDailyReward] = {
        PhpConfig.GET_DAILY_URL,
        PhpConfig.METHOD_GETDAILYREWARD,
    },
    [HttpModule.s_cmds.GetConsoleProgress] = {
        PhpConfig.CONSOLE_GET_SERVER_DATA_URL,
        PhpConfig.METHOD_GET_CONSOLE_PROGRESS,
    },
    [HttpModule.s_cmds.UploadConsoleProgress] = {
        PhpConfig.CONSOLE_GET_SERVER_DATA_URL,
        PhpConfig.METHOD_SYNC_CONSOLE_PROGRESS,
    },
    [HttpModule.s_cmds.saveUserInfo] = {
        PhpConfig.new_developUrl,
        "User.modify",
    },
    [HttpModule.s_cmds.checkVersion] = {
        PhpConfig.CHECK_VERSION_URL,
        "hall_checkVersion",
    },
    [HttpModule.s_cmds.checkVersion_new] = {
        PhpConfig.new_developUrl,
        "Index.checkVersionV2",
    },
    [HttpModule.s_cmds.getNotice] = {
        PhpConfig.NOTICE_URL,
        PhpConfig.METHOD_NOTICE_GETLIST,
    },
    [HttpModule.s_cmds.getScoreRank] = {
        PhpConfig.new_developUrl,--PhpConfig.SCORE_RANK_URL,
        "RankList.score",
    },
    [HttpModule.s_cmds.getMoneyRank] = {
        PhpConfig.MONEY_RANK_URL,
        "",
    },
    [HttpModule.s_cmds.getCollapseReward] = {
        PhpConfig.COLLAPSE_REWARD_URL,
        PhpConfig.METHOD_COLLAPSE_REWARD,
    },
    [HttpModule.s_cmds.getUserInfo] = {
        PhpConfig.ANSY_URL,
        PhpConfig.METHOD_USERINFO,
    },
    [HttpModule.s_cmds.getMallShopInfo] = {
        PhpConfig.MALL_SHOP_URL,
        "getMallShopInfo",
    },
    [HttpModule.s_cmds.getPointShopInfo] = {
        PhpConfig.POINT_MALL_SHOP_URL,
        "getPointMallShopInfo",
    },
    [HttpModule.s_cmds.getUserPointScore] = {
        PhpConfig.POINT_MALL_SHOP_URL,
        "getUserScore",
    },
    [HttpModule.s_cmds.isPointWallAvailable] = {
        PhpConfig.POINT_MALL_SHOP_URL,
        "isAvailable",
    },
    [HttpModule.s_cmds.pointExchange] = {
        PhpConfig.POINT_MALL_SHOP_URL,
        "exchange",
    },
    [HttpModule.s_cmds.downloadGateInfo] = {
        PhpConfig.ENDING_GAME_URL,
        PhpConfig.METHOD_ENDING_GAME_SEVERDATA,
    },
    [HttpModule.s_cmds.getBoothInfo] = {
        PhpConfig.ENDING_GAME_URL,
        PhpConfig.METHOD_ENDING_GAME_BOOTH_INFO,
    },
    [HttpModule.s_cmds.uploadGateInfo] = {
        PhpConfig.ENDING_GAME_URL,
        PhpConfig.METHOD_ENDING_GAME_RSYNC,
    },
    [HttpModule.s_cmds.checkEndingUpdate] = {
        PhpConfig.ENDING_GAME_URL,
        PhpConfig.METHOD_CHECK_ENDING_UPDATE,
    },
    [HttpModule.s_cmds.sendFeedback] = {
        PhpConfig.FEEDBACK_URL,
        PhpConfig.METHOD_FEEDBACK_SENDFEEDBACK,
    },
    [HttpModule.s_cmds.getFeedBack] = {
        PhpConfig.FEEDBACK_URL,
        PhpConfig.METHOD_GET_FEEDBACK,
    },
    [HttpModule.s_cmds.sendFeedBackScore] = {
        PhpConfig.FEEDBACK_URL,
        PhpConfig.METHOD_SEMD_FEEDBACK_SCORE,
    },

    [HttpModule.s_cmds.getPropList] = {
        PhpConfig.new_developUrl,
        "Goods.getPropConfig",
    },
    [HttpModule.s_cmds.getShopInfo] = {
        PhpConfig.new_developUrl,
        "Goods.getMallShopInfo",
    },
    [HttpModule.s_cmds.getOnlineReward] = {
        PhpConfig.ONLINE_TIME,
        PhpConfig.METHOD_GETONLINE_REWARD,
    },
    [HttpModule.s_cmds.exchangeProp] = {
        PhpConfig.new_developUrl,
        "Goods.exchangeProp",
    },
    [HttpModule.s_cmds.uploadOrDownPropData] = {
        PhpConfig.CONSOLE_GET_SERVER_DATA_URL,
        PhpConfig.METHOD_SYNC_PROPINFO,
    },
    [HttpModule.s_cmds.addDeliverLog] = {
        PhpConfig.ENDING_GAME_URL,
        PhpConfig.METHOD_ADDDELIVERLOG,
    },
    [HttpModule.s_cmds.sendCode] = {
        PhpConfig.new_developUrl,
        "BindAccount.sendCode",
    },
    [HttpModule.s_cmds.bindUid] = {
        PhpConfig.new_developUrl,
        "BindAccount.bind",
    },
    [HttpModule.s_cmds.loginThirdLogin] = {
        PhpConfig.new_developUrl,
        "Login.thirdLogin",
    },
    [HttpModule.s_cmds.getSoulList] = {
        PhpConfig.EXCHANGE_GOODS_LIST,
        PhpConfig.METHOD_GETSOULLIST,
    },
    [HttpModule.s_cmds.exchangeSoul] = {
        PhpConfig.EXCHANGE_GOODS_LIST,
        PhpConfig.METHOD_EXCHANGE_SOUL,
    },
    [HttpModule.s_cmds.GetNewDailyList] = {
        PhpConfig.new_developUrl,
        "Task.getDailyList",
    },
    [HttpModule.s_cmds.GetNewDailyReward] = {
        PhpConfig.new_developUrl,
        "Task.getDailyReward",
    },
    [HttpModule.s_cmds.getTaskProgress] = {
        PhpConfig.getDailyURL,
        "",
    },
    [HttpModule.s_cmds.statRewardPerLevel] = {
        PhpConfig.CONSOLE_GET_SERVER_DATA_URL,
        PhpConfig.METHOD_SYNC_STATREWARDPERLEVEL,
    },
    [HttpModule.s_cmds.getSoul] = {
	    PhpConfig.EXCHANGE_GOODS_LIST;
	    PhpConfig.METHOD_GET_SOUL;
    },
    [HttpModule.s_cmds.uploadConsole2Php] = {
        PhpConfig.new_developUrl,
        "ReportLog.standAlone",
    },
    [HttpModule.s_cmds.uploadConsoleProgress] = {
        PhpConfig.new_developUrl,
        "User.syncSingleProgress",
    },
    [HttpModule.s_cmds.getConsoleProgress] = {
        PhpConfig.new_developUrl,
        "User.getSingleStar",
    },
    [HttpModule.s_cmds.createOrder] = {
        PhpConfig.new_developUrl,
        "Pay.createOrder",
    },
    [HttpModule.s_cmds.boothShare] = {
        PhpConfig.new_developUrl,
        "ReportLog.BoothShare",
    },
    [HttpModule.s_cmds.searchFriends] = {
        PhpConfig.new_developUrl,
        "Friends.search",
    },
    [HttpModule.s_cmds.charmList] = {
        PhpConfig.new_developUrl,
        "RankList.fans",
    }, 
    [HttpModule.s_cmds.getFriendUserInfo] = {
        PhpConfig.new_developUrl,                 
        "User.getUserInfo",
    },
     [HttpModule.s_cmds.getFriendUserRecordInfo] = {
        PhpConfig.new_developUrl,                 
        "User.getUserRecordSheet",
    },
     [HttpModule.s_cmds.getFriendUserHonorInfo] = {
        PhpConfig.new_developUrl,                 
        "User.getUserHonorSheet",
    },
    [HttpModule.s_cmds.mailListCll] = {
        PhpConfig.new_developUrl,
        "Friends.findPhoneBook",
    },
    [HttpModule.s_cmds.chickPaiHangBang] = {
        PhpConfig.new_developUrl,
        "Rank.userSocreRank",
    },
    [HttpModule.s_cmds.recommendMailListCll] = {
        PhpConfig.new_developUrl,
        "Friends.recommend",
    },
    [HttpModule.s_cmds.reportRecommend] = {
        PhpConfig.new_developUrl,
        "Friends.reportCheckRecommend",
    },
    [HttpModule.s_cmds.saveMychess] = {
        PhpConfig.new_developUrl,
        "ChessManual.saveChessManual",
    },
    [HttpModule.s_cmds.getMychess] = {
        PhpConfig.new_developUrl,
        "ChessManual.myCollect",
    },
    [HttpModule.s_cmds.openOrSelfChess] = {
        PhpConfig.new_developUrl,
        "ChessManual.addCollect",
    },
    [HttpModule.s_cmds.delMySaveChess] = {
        PhpConfig.new_developUrl,
        "ChessManual.delCollect",
    },
    [HttpModule.s_cmds.getHotComment] = {
        PhpConfig.new_developUrl,
        "ChessManual.hotComment",
    },
    [HttpModule.s_cmds.getAllComment] = {
        PhpConfig.new_developUrl,
        "ChessManual.allComment",
    },
    [HttpModule.s_cmds.shareComment] = {
        PhpConfig.new_developUrl,
        "ChessManual.addComment",
    },   
    [HttpModule.s_cmds.setLikeComment] = {
        PhpConfig.new_developUrl,
        "ChessManual.likeComment",
    },
    [HttpModule.s_cmds.uploadLog] = {
        PhpConfig.new_developUrl,
        "ChessManual.uploadLog",
    },

    [HttpModule.s_cmds.goodsUploadProp] = {
        PhpConfig.new_developUrl,
        "Goods.uploadProp",
    },
    [HttpModule.s_cmds.boyaaSendCode] = {
        PhpConfig.new_developUrl,
        "BoyaaPassport.sendCode",
    },
    [HttpModule.s_cmds.findPasswordByPhone] = {
        PhpConfig.new_developUrl,
        "BoyaaPassport.findPasswordByPhone",
    },
    [HttpModule.s_cmds.findPasswordByEmail] = {
        PhpConfig.new_developUrl,
        "BoyaaPassport.findPasswordByEmail",
    },
    [HttpModule.s_cmds.reportBad] = {
        PhpConfig.new_developUrl,
        "User.expose",
    },
    [HttpModule.s_cmds.getRecentWarUser] = {
        PhpConfig.new_developUrl,
        "Friends.getRecentWarUser",
    },
    [HttpModule.s_cmds.getReward] = {
        PhpConfig.new_developUrl,
        "User.draw",
    },
    [HttpModule.s_cmds.uploadGetuiClientid] = {
        PhpConfig.new_developUrl,
        "Index.saveGetuiClientId",
    },
    [HttpModule.s_cmds.getCityConfig] = {
        PhpConfig.new_developUrl,
        "Index.getCityConfig",
    },
    [HttpModule.s_cmds.getAllChessComment] = {
        PhpConfig.developUrl,
        "PlayerCircle.AllComment",
    },
    [HttpModule.s_cmds.getHotChessComment] = {
        PhpConfig.developUrl,
        "PlayerCircle.hotComment",
    },
    [HttpModule.s_cmds.getMonthCombat] = {
        PhpConfig.new_developUrl,
        "User.getMonthCombat",
    },
    [HttpModule.s_cmds.v2CheckUpdate] = {
        PhpConfig.new_developUrl,
        "Booth.V2CheckUpdate",
    },
    [HttpModule.s_cmds.WulinBoothCreate] = {
        PhpConfig.new_developUrl,
        "WulinBooth.create",
    },
    [HttpModule.s_cmds.WulinBoothBuyBooth] = {
        PhpConfig.new_developUrl,
        "WulinBooth.buyBooth",
    },
    [HttpModule.s_cmds.WulinBoothUploadLog] = {
        PhpConfig.new_developUrl,
        "WulinBooth.uploadLog",
    },
    [HttpModule.s_cmds.WulinBoothUploadMoveList] = {
        PhpConfig.new_developUrl,
        "WulinBooth.uploadMoveList",
    },
    [HttpModule.s_cmds.WxBoothCreateBooth] = {
        PhpConfig.new_developUrl,
        "WxBooth.createBooth",
    },
    [HttpModule.s_cmds.WulinBoothExpose] = {
        PhpConfig.new_developUrl,
        "WxBooth.expose",
    },
    [HttpModule.s_cmds.WulinBoothReportCollect] = {
        PhpConfig.new_developUrl,
        "WulinBooth.reportCollect",
    },
    [HttpModule.s_cmds.IndexGetNotice] = {
        PhpConfig.new_developUrl,
        "Index.getBatchNotice",
    },
    [HttpModule.s_cmds.WulinBoothReportShare] = {
        PhpConfig.new_developUrl,
        "WulinBooth.reportShare",
    },
    [HttpModule.s_cmds.IndexGetActionList] = {
        PhpConfig.new_developUrl,
        "Index.getActionListV2",
    },
    [HttpModule.s_cmds.getSameCityRecommend] = {
        PhpConfig.new_developUrl,
        "Friends.getSameCityRecommend",
    },
    [HttpModule.s_cmds.getSameCityMember] = {
        PhpConfig.new_developUrl,
        "Friends.getSameCityMember",
    },
    [HttpModule.s_cmds.uploadMySet] = {
        PhpConfig.new_developUrl,
        "User.modify",
    },
    [HttpModule.s_cmds.IndexStartConfig] = {
        PhpConfig.new_developUrl,
        "Index.getBootAdConfig",
    },
    [HttpModule.s_cmds.appStorePayOrder] = {
        PhpConfig.new_developUrl,
        "Pay.payOrder",
    },
    [HttpModule.s_cmds.appStoreCheckSwitch] = {
        PhpConfig.new_developUrl,
        "Index.getIosConfig",
    },
    [HttpModule.s_cmds.appStoreEvaluate] = {
        PhpConfig.new_developUrl,
        "Index.getIosEvaluateConfig",
    },
    [HttpModule.s_cmds.IndexClientReportLog] = {
        PhpConfig.new_developUrl,
        "Index.clientReportLog",
    },
    [HttpModule.s_cmds.UserMailGetMyMail] = {
        PhpConfig.new_developUrl,
        "UserMail.getMyMail",
    },
    [HttpModule.s_cmds.UserMailAction] = {
        PhpConfig.new_developUrl,
        "UserMail.action",
    },
    [HttpModule.s_cmds.UserMailSeeMail] = {
        PhpConfig.new_developUrl,
        "UserMail.seeMail",
    },
    [HttpModule.s_cmds.UserMailDel] = {
        PhpConfig.new_developUrl,
        "UserMail.del",
    },
    [HttpModule.s_cmds.UserMailGetNewMailNumber] = {
        PhpConfig.new_developUrl,
        "UserMail.getNewMailNumber",
    },
    [HttpModule.s_cmds.GetNewBankruptReward] = {
        PhpConfig.new_developUrl,
        "User.getBankruptcyGrant",
    },
    [HttpModule.s_cmds.CheckBankruptReward] = {
        PhpConfig.new_developUrl,
        "User.checkBankruptcyGrant",
    },
    [HttpModule.s_cmds.FriendsGetRecentWarUser] = {
        PhpConfig.new_developUrl,
        "Friends.getRecentWarUser",
    },
    [HttpModule.s_cmds.FriendsAddFriend] = {
        PhpConfig.new_developUrl,
        "Friends.addFriend",
    },
    [HttpModule.s_cmds.WulinBoothRecommend] = {
        PhpConfig.new_developUrl,
        "WulinBooth.recommend",
    },
    [HttpModule.s_cmds.WulinBoothMyCreateBooth] = {
        PhpConfig.new_developUrl,
        "WulinBooth.myCreateBooth",
    },
    [HttpModule.s_cmds.WulinBoothGetBoothTimeList] = {
        PhpConfig.new_developUrl,
        "WulinBooth.getBoothList",
    },
    [HttpModule.s_cmds.WulinBoothGetBoothJackpotList] = {
        PhpConfig.new_developUrl,
        "WulinBooth.getBoothList",
    },
    [HttpModule.s_cmds.getCircleDynamics] = {
        PhpConfig.new_developUrl,
        "ChessManual.getCircleDynamics",
    },
    [HttpModule.s_cmds.getSignReward] = {
        PhpConfig.new_developUrl,
        "Task.getSignReward",
    },
    [HttpModule.s_cmds.IndexGetPushActionList] = {
        PhpConfig.new_developUrl,
        "Index.getPushActionList",
    },
    [HttpModule.s_cmds.WulinBoothMark] = {
        PhpConfig.new_developUrl,
        "WulinBooth.mark",
    },
    [HttpModule.s_cmds.WulinBoothDelMark] = {
        PhpConfig.new_developUrl,
        "WulinBooth.delMark",
    },
    [HttpModule.s_cmds.WulinBoothGetMyMark] = {
        PhpConfig.new_developUrl,
        "WulinBooth.getMyMark",
    },
    [HttpModule.s_cmds.countToPHP] = {
        PhpConfig.getLogUrl(),
        "Index.userBehavior",
    },
    [HttpModule.s_cmds.WulinBoothGetBoothInfo] = {
        PhpConfig.new_developUrl,
        "WulinBooth.getBoothInfo",
    },
    [HttpModule.s_cmds.ArenaGetCurrentRank] = {
        PhpConfig.new_developUrl,
        "Arena.getCurrentRank",
    },
    [HttpModule.s_cmds.ArenaGetPrevRank] = {
        PhpConfig.new_developUrl,
        "Arena.getPrevRank",
    },
    [HttpModule.s_cmds.ArenaGetRuleText] = {
        PhpConfig.new_developUrl,
        "Arena.getRuleText",
    },
    [HttpModule.s_cmds.BoothBuyGate] = {
        PhpConfig.new_developUrl,
        "Booth.buyGate",
    },
    [HttpModule.s_cmds.getSociatyInfo] = {
        PhpConfig.new_developUrl,
        "Guild.info",
    },
    [HttpModule.s_cmds.getRecommendSociaty] = {
        PhpConfig.new_developUrl,
        "Guild.recommend",
    },
    [HttpModule.s_cmds.createSociaty] = {
        PhpConfig.new_developUrl,
        "Guild.create",
    },
    [HttpModule.s_cmds.applyJoinSociaty] = {
        PhpConfig.new_developUrl,
        "Guild.apply",
    },
    [HttpModule.s_cmds.getSociatyMemberInfo] = {
        PhpConfig.new_developUrl,
        "Guild.member",
    },
    [HttpModule.s_cmds.getSociatyApplyMsg] = {
        PhpConfig.new_developUrl,
        "Guild.applyMsg",
    },
    [HttpModule.s_cmds.managerSociaty] = {
        PhpConfig.new_developUrl,
        "Guild.manager",
    },
    [HttpModule.s_cmds.modifySociatyInfo] = {
        PhpConfig.new_developUrl,
        "Guild.modify",
    },
    [HttpModule.s_cmds.quitSociaty] = {
        PhpConfig.new_developUrl,
        "Guild.quit",
    },
    [HttpModule.s_cmds.sociatyRank] = {
        PhpConfig.new_developUrl,
        "Guild.rankList",
    },
    [HttpModule.s_cmds.getFeedbackInfo] = {
        PhpConfig.new_developUrl,
        "Index.getFeedbackInfo",
    },
    [HttpModule.s_cmds.getGrowTaskList] = {
        PhpConfig.new_developUrl,
        "Task.getAchieveList",
    },
    [HttpModule.s_cmds.getGrowTaskReward] = {
        PhpConfig.new_developUrl,
        "Task.getAchieveReward",
    },
    [HttpModule.s_cmds.upLoadLbs] = {
        PhpConfig.new_developUrl,
        "Index.lbs",
    },
    [HttpModule.s_cmds.IndexGetMatchConfig] = {
        PhpConfig.new_developUrl,
        "Index.getMatchConfig",
    },
    [HttpModule.s_cmds.IndexGameHelp] = {
        PhpConfig.new_developUrl,
        "Index.gameHelp",
    },
    [HttpModule.s_cmds.getManualByMid] = {
        PhpConfig.new_developUrl,
        "ChessManual.getManualByMid",
    },
    [HttpModule.s_cmds.getFriendCombat] = {
        PhpConfig.new_developUrl,
        "Friends.getFriendCombat",
    },
    [HttpModule.s_cmds.UserRealNameAuth] = {
        PhpConfig.new_developUrl,
        "User.realNameAuth",
    },
    [HttpModule.s_cmds.UserGetIsRealNameAuth] = {
        PhpConfig.new_developUrl,
        "User.getIsRealNameAuth",
    },
    [HttpModule.s_cmds.IndexCreateShortUrl] = {
        PhpConfig.new_developUrl,
        "Index.createShortUrl",
    },
    [HttpModule.s_cmds.friendsCharmList] = {
        PhpConfig.new_developUrl,
        "RankList.friendFansRank",
    },
    [HttpModule.s_cmds.friendsScoreList] = {
        PhpConfig.new_developUrl,
        "RankList.friendScoreRank",
    },
    [HttpModule.s_cmds.friendsMoneyList] = {
        PhpConfig.new_developUrl,
        "RankList.friendMoneyRank",
    },
    [HttpModule.s_cmds.getMatchList] = {
        PhpConfig.new_developUrl,
        "Match.matchList",
    },
    [HttpModule.s_cmds.getMatchRule] = {
        PhpConfig.new_developUrl,
        "Match.ruleText",
    },
    [HttpModule.s_cmds.joinMatch] = {
        PhpConfig.new_developUrl,
        "Match.joinMatch",
    },
    [HttpModule.s_cmds.MatchRank] = {
        PhpConfig.new_developUrl,
        "Match.rank",
    },
    [HttpModule.s_cmds.exitMatch] = {
        PhpConfig.new_developUrl,
        "Match.exitMatch",
    },
    [HttpModule.s_cmds.matchStatus] = {
        PhpConfig.new_developUrl,
        "Match.matchStatus",
    },
    [HttpModule.s_cmds.MatchRank2] = {
        PhpConfig.new_developUrl,
        "Match.rank",
    },
    [HttpModule.s_cmds.MatchRebuy] = {
        PhpConfig.new_developUrl,
        "Match.rebuy",
    },
    [HttpModule.s_cmds.MatchGetRebuyMoney] = {
        PhpConfig.new_developUrl,
        "Match.getRebuyMoney",
    },
    [HttpModule.s_cmds.qrcode] = {
        PhpConfig.new_developUrl,
        "Index.redeem",
    },
    [HttpModule.s_cmds.saveMychessAndShare] = {
        PhpConfig.new_developUrl,
        "ChessManual.shareNativeManual",
    },
    [HttpModule.s_cmds.getUserTicket] = {
        PhpConfig.new_developUrl,
        "User.getUserTicket",
    },
    [HttpModule.s_cmds.MatchGetHistory] = {
        PhpConfig.new_developUrl,
        "Match.getHistory",
    },
    [HttpModule.s_cmds.checkPassword] = {
        PhpConfig.new_developUrl,
        "Match.checkPassword",
    },
    [HttpModule.s_cmds.getMatchPrize] = {
        PhpConfig.new_developUrl,
        "Match.receiveRankPrize",
    },
    [HttpModule.s_cmds.getGiftWeekRank] = {
        PhpConfig.new_developUrl,
        "User.getGiftWeekRank",
    },
    [HttpModule.s_cmds.matchAdDialog] = {
        PhpConfig.new_developUrl,
        "Match.recommend",
    },
    [HttpModule.s_cmds.checkHornMsg] = {
        PhpConfig.new_developUrl,
        "User.sendHornMessage",
    },
    [HttpModule.s_cmds.loadChatRoomInfo] = {
        PhpConfig.new_developUrl,
        "Index.getChatRoomList",
    },    
    [HttpModule.s_cmds.getChatMatchConfig] = {
        PhpConfig.new_developUrl,
        "Index.getChatMatchConfig",
    },
    [HttpModule.s_cmds.getChatRoomManualInfo] = {
        PhpConfig.new_developUrl,
        "Index.getManualInfo",
    },
    [HttpModule.s_cmds.MatchGetApplyList] = {
        PhpConfig.new_developUrl,
        "Match.getApplyList",
    },
    [HttpModule.s_cmds.MatchLike] = {
        PhpConfig.new_developUrl,
        "Match.like",
    },
    [HttpModule.s_cmds.MatchCancelLike] = {
        PhpConfig.new_developUrl,
        "Match.cancelLike",
    },
    [HttpModule.s_cmds.GetDailyData] = {
        PhpConfig.new_developUrl,
        "Task.getDailySignData",
    },
    [HttpModule.s_cmds.MatchHallRecommend] = {
        PhpConfig.new_developUrl,
        "Match.hallRecommend",
    },
    [HttpModule.s_cmds.uploadIosClientid] = {
        PhpConfig.new_developUrl,
        "Index.saveIosClientId",
    },
    [HttpModule.s_cmds.getSociatyVp] = {
        PhpConfig.new_developUrl,
        "Guild.getGuildVp",
    },
    [HttpModule.s_cmds.guildExpose] = {
        PhpConfig.new_developUrl,
        "Guild.guildExpose",
    },
    [HttpModule.s_cmds.GuildCheckGuildExpose] = {
        PhpConfig.new_developUrl,
        "Guild.checkGuildExpose",
    },
    [HttpModule.s_cmds.GuildDelGuildExpose] = {
        PhpConfig.new_developUrl,
        "Guild.delGuildExpose",
    },
    [HttpModule.s_cmds.addBlackList] = {
        PhpConfig.new_developUrl,
        "BlackList.add",
    },
    [HttpModule.s_cmds.BlackListGetList] = {
        PhpConfig.new_developUrl,
        "BlackList.getList",
    },
    [HttpModule.s_cmds.BlackListDel] = {
        PhpConfig.new_developUrl,
        "BlackList.del",
    },
    [HttpModule.s_cmds.IndexGetBatchNotice] = {
        PhpConfig.new_developUrl,
        "Index.getBatchNotice",
    },
    [HttpModule.s_cmds.UserUserBehaviorStatistic] = {
        PhpConfig.new_developUrl,
        "User.userBehaviorStatistic",
    },
    [HttpModule.s_cmds.GetChessManualId] = {
        PhpConfig.new_developUrl,
        "ChessManual.shareNativeManual",
    },
    [HttpModule.s_cmds.UploadChessShareNum] = {
        PhpConfig.new_developUrl,
        "ChessManual.countShareNumber",
    },
    [HttpModule.s_cmds.getAndroidEvaluateConfig] = {
        PhpConfig.new_developUrl,
        "Index.getAndroidEvaluateConfig",
    },
    [HttpModule.s_cmds.UserGetUserGoodsInfo] = {
        PhpConfig.new_developUrl,
        "User.getUserGoodsInfo",
    },
    [HttpModule.s_cmds.UserNewUserEvaluating] = {
        PhpConfig.new_developUrl,
        "User.newUserEvaluating",
    },
    [HttpModule.s_cmds.UserGetDoubleCardsInfo] = {
        PhpConfig.new_developUrl,
        "User.getDoubleCardsInfo",
    },
    [HttpModule.s_cmds.ArenaGetWitnessContributionRank] = {
        PhpConfig.new_developUrl,
        "Arena.getWitnessContributionRank",
    },
    [HttpModule.s_cmds.ArenaGetWitnessPresentMoneyRank] = {
        PhpConfig.new_developUrl,
        "Arena.getWitnessPresentMoneyRank",
    },
    [HttpModule.s_cmds.UserGetUserGiftNum] = {
        PhpConfig.new_developUrl,
        "User.getUserGiftNum",
    },
    [HttpModule.s_cmds.UserExchangeHistory] = {
        PhpConfig.new_developUrl,
        "User.exchangeHistory",
    },
    [HttpModule.s_cmds.UserModifyNameByMoney] = {
        PhpConfig.new_developUrl,
        "User.modifyNameByMoney",
    },
    [HttpModule.s_cmds.GuildModifyGuildName] = {
        PhpConfig.new_developUrl,
        "Guild.modifyGuildName",
    },
    [HttpModule.s_cmds.GuildCheckCreateGuildRight] = {
        PhpConfig.new_developUrl,
        "Guild.checkCreateGuildRight",
    },
    [HttpModule.s_cmds.GoodsGetPromotionSaleGoods] = {
        PhpConfig.new_developUrl,
        "Goods.getPromotionSaleGoods",
    },
    [HttpModule.s_cmds.GuildCheckGuildDataLegal] = {
        PhpConfig.new_developUrl,
        "Guild.checkGuildDataLegal",
    },
    [HttpModule.s_cmds.IndexStatisticGiftInfo] = {
        PhpConfig.new_developUrl,
        "Index.statisticGiftInfo",
    },
    [HttpModule.s_cmds.UserGetSingleProgressCfg] = {
        PhpConfig.new_developUrl,
        "User.getSingleProgressCfg",
    },
    [HttpModule.s_cmds.UserGuns] = {
        PhpConfig.new_developUrl,
        "User.guns",
    },
    [HttpModule.s_cmds.UserBuyJn] = {
        PhpConfig.new_developUrl,
        "User.buyJn",
    },
    [HttpModule.s_cmds.UserBuyLevel] = {
        PhpConfig.new_developUrl,
        "User.buyLevel",
    },
    [HttpModule.s_cmds.checkoutUserFreezeFrame] = {
        PhpConfig.new_developUrl,
        "User.checkoutUserFreezeFrame",
    },
    [HttpModule.s_cmds.getIOSReviewPrize] = {
        PhpConfig.new_developUrl,
        "User.getPrize",
    },
    [HttpModule.s_cmds.getUserFreezeType] = {
        PhpConfig.new_developUrl,
        "User.getUserFreezeType",
    },
    [HttpModule.s_cmds.getPassBoothNumbers] = {
        PhpConfig.new_developUrl,
        "Booth.getPassBoothNumbers",
    },
};
end

HttpModule.initConfig();
HttpModule.ddmatch_android = "pokerlord/api.php"
HttpModule.develop_pre =  httpUrlAddr or "https://192.168.100.148/";  --正式 
HttpModule.request_url_pre = HttpModule.develop_pre;
HttpModule.develop  = httpUrlAddr or "https://192.168.100.148/";


HttpModule.isOnlineUrlon = true;
HttpModule.isTestOn = true; --上线时候 把它改成false

HttpModule.updateS_config= function()
	if HttpModule.s_config then
		for _,config in pairs(HttpModule.s_config) do
			if config then
				config[HttpConfigContants.URL]  = HttpModule.develop;
			end
		end	
	end
end

HttpModule.setDevelopUrl = function(url)
    HttpModule.develop = url..HttpModule.ddmatch_android;
    HttpModule.request_url_pre = url;
    HttpModule.updateS_config();

    return HttpModule.develop ;
end

HttpModule.saveWebUrl = function(url)
    KGameCacheData:saveString(GameCacheData.WEB_REQUEST_URL,url); 
end

--接入反馈需求
HttpModule.changeFeedBackUrl = function()
    HttpModule.s_config[HttpModule.s_cmds.sendFeedback][HttpConfigContants.URL]  = "https://feedback.kx88.net/api/api.php";
    HttpModule.s_config[HttpModule.s_cmds.GetFeedback][HttpConfigContants.URL]  = "https://feedback.kx88.net/api/api.php";
end

HttpModule.recoverFeedBackUrl = function()
    HttpModule.s_config[HttpModule.s_cmds.sendFeedback][HttpConfigContants.URL]  = HttpModule.develop;
    HttpModule.s_config[HttpModule.s_cmds.GetFeedback][HttpConfigContants.URL]  = HttpModule.develop;
end

HttpModule.explainPHPMessage = function(success,message,defLog)
    if not success then 
        if type(message) == 'table' and message.error then
            ChessToastManager.getInstance():showSingle(message.error:get_value() or defLog,3000);
        else
            ChessToastManager.getInstance():showSingle(defLog,3000);
        end
        return true;
    end
    return false;
end

