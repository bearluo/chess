require("config/path_config");


States = 
{
	Hall 						= 1;
    Console                     = 2;
   	ConsoleRoom                 = 3;
	Room                        = 4;
	Online                      = 5;
	
    OnlineRoom                  = 6;
	UserInfo                    = 7;
    EndGate                     = 8;
	EndGateSub                  = 9;
	EndingRoom                  = 10;
	Feedback                    = 11;
	Mall                        = 12;
	Rank                        = 13;
    dapu                        = 14;
    Exchange                    = 15;
    Watch                       = 16;
    DapuRoom                    = 17;
    Friends                     = 18;
	FriendMsg                   = 19;
	FriendChat                  = 20;
    AddFriends                  = 21;
    FriendsInfo                 = 22;
    watchlist                   = 23;
    FriendRoom                  = 24;
    Replay                      = 25;
    CustomBoard                 = 26;
    RecentChess                 = 27;
    ReplayRoom                  = 28;
    Collect                     = 29;
    ChatRoom                    = 30;
    PrivateHall                 = 31;
    ownModel                    = 32;
    setModel                    = 33;
    aboutModel                  = 34;
    assetsModel                 = 35;
    noticeModel                 = 36;
    shareModel                  = 37;
    gradeModel                  = 38;
    helpModel                   = 39;
    Comment                     = 40;
    findModel                   = 41;
    createEndgate               = 42;
    playCreateEndgate           = 43;
    activity                    = 44;
    vipModel                    = 45;
    RecentlyPlayerState         = 46;
    commonIssue                 = 47;
};


StatesMap = 
{
	
	[States.Hall]                           = {MODEL_PATH.."hall/hallState","HallState"};--大厅
    [States.Console]                        = {MODEL_PATH.."console/consoleState","ConsoleState"};--单机大厅
    [States.ConsoleRoom]                    = {MODEL_PATH.."console/consoleRoom/consoleRoomState","ConsoleRoomState"};--单机房间
    [States.Room]                           = {MODEL_PATH.."room/RoomState","RoomState"};--房间
    [States.Online]                         = {MODEL_PATH.."online/onlineState","OnlineState"};--联网大厅
    [States.OnlineRoom]                     = {MODEL_PATH.."online/onlineRoom/onlineRoomState","OnlineRoomState"};--联网房间
	[States.UserInfo]                       = {MODEL_PATH.."userInfo/userInfoState","UserInfoState"};--用户信息
    [States.EndGate]                        = {MODEL_PATH.."endgate/endgateState","EndgateState"};--残局大关卡
    [States.EndGateSub]                     = {MODEL_PATH.."endgate/endgateSubModel/endgateSubState","EndgateSubState"};--残局小关卡
    [States.EndingRoom]                     = {MODEL_PATH.."endgate/endgateSubModel/endgateRoom/endgateRoomState","EndgateRoomState"};--残局房间
    [States.Feedback]                       = {MODEL_PATH.."feedback/feedbackState","FeedbackState"};--反馈界面
    [States.Mall]                           = {MODEL_PATH.."mall/mallState","MallState"};--商城
    [States.Rank]                           = {MODEL_PATH.."rank/newRankState","NewRankState"};--排行榜
    [States.dapu]                           = {MODEL_PATH.."dapu/dapuState","DapuState"};--棋牌
    [States.Exchange]                       = {MODEL_PATH.."exchange/exchangeState","ExchangeState"};--棋魂兑换
    [States.Watch]                          = {MODEL_PATH.."online/watch/watchState","WatchState"};--观战
    [States.DapuRoom]                       = {MODEL_PATH.."dapu/dapuRoom/dapuRoomState","DapuRoomState"};--棋牌房间
    [States.Friends]                        = {MODEL_PATH.."ownModel/friends/friendsState","FriendsState"};--好友列表
    [States.FriendMsg]                      = {MODEL_PATH.."friends/friendMsg/friendMsgState","FriendMsgState"};--消息界面
    [States.FriendChat]                     = {MODEL_PATH.."friends/friendChat/friendChatState","FriendChatState"};--聊天主界面
    [States.AddFriends]                     = {MODEL_PATH.."addfriends/addfriendsState","AddFriendsState"};--添加好友界面
    [States.FriendsInfo]                    = {MODEL_PATH.."friendsInfo/friendsInfoState","FriendsInfoState"};--好友详细信息
    [States.watchlist]                      = {MODEL_PATH.."watchlist/watchlistState","WatchlistState"};--观战用户列表
    [States.FriendRoom]                     = {MODEL_PATH.."online/onlineRoom/friendRoom/friendRoomState","FriendRoomState"};--好友房间
    [States.Replay]                         = {MODEL_PATH.."replay/replayState","ReplayState"};--复盘演练
    [States.CustomBoard]                    = {MODEL_PATH.."dapu/customBoard/customBoardState","CustomBoardState"};--自定义棋局
    [States.RecentChess]                    = {MODEL_PATH.."dapu/recentChessState","RecentChessState"};--最近棋盘
    [States.ReplayRoom]                     = {MODEL_PATH.."dapu/replayRoom/replayRoomState","ReplayRoomState"};--棋谱回放
    [States.Collect]                        = {MODEL_PATH.."replay/collect/collectState","CollectState"};--我的收藏
    [States.ChatRoom]                       = {MODEL_PATH.."friends/chatRoom/chatRoomState","ChatRoomState"};--聊天室
    [States.PrivateHall]                    = {MODEL_PATH.."online/private/privateState","PrivateState"};--私人房大厅
    [States.ownModel]                       = {MODEL_PATH.."ownModel/ownState","OwnState"};-- 我的模块
    [States.setModel]                       = {MODEL_PATH.."ownModel/setModel/setState","SetState"};-- 设置界面
    [States.aboutModel]                     = {MODEL_PATH.."ownModel/setModel/aboutModel/aboutState","AboutState"};-- 关于界面
    [States.assetsModel]                    = {MODEL_PATH.."ownModel/assetsModel/assetsState","AssetsState"};-- 我的资产
    [States.noticeModel]                    = {MODEL_PATH.."ownModel/noticeModel/noticeState","NoticeState"};-- 我的消息
    [States.shareModel]                     = {MODEL_PATH.."ownModel/shareModel/shareState","ShareState"};-- 分享界面
    [States.gradeModel]                     = {MODEL_PATH.."ownModel/gradeModel/gradeState","GradeState"};-- 我的等级  -棋力
    [States.helpModel]                      = {MODEL_PATH.."ownModel/setModel/helpModel/helpState","HelpState"};-- 帮助界面    
    [States.Comment]                        = {MODEL_PATH.."replay/comment/commentState","CommentState"};-- 评论界面
    [States.findModel]                      = {MODEL_PATH.."findModel/findState","FindState"};-- 发现界面
    [States.createEndgate]                  = {MODEL_PATH.."dapu/createEndgate/createEndgateState","CreateEndgateState"};-- 创建残局
    [States.playCreateEndgate]              = {MODEL_PATH.."dapu/playCreateEndgateRoom/playCreateEndgateRoomState","PlayCreateEndgateRoomState"};-- 玩创建残局
    [States.activity]                       = {MODEL_PATH.."activity/activityState","ActivityState"};-- 活动
	[States.vipModel]                       = {MODEL_PATH.."vipModule/vipModifyState","VipModifyState"};--vip修改
	[States.RecentlyPlayerState]            = {MODEL_PATH.."findModel/recentlyPlayer/recentlyPlayerState","RecentlyPlayerState"};--最近对手
	[States.commonIssue]                    = {MODEL_PATH.."ownModel/setModel/commonIssueModel/commonIssueState","CommonIssueState"};--常见问题
};
 