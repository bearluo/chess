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
	
	[States.Hall]                           = {MODEL_PATH.."hall/hallState","HallState"};--����
    [States.Console]                        = {MODEL_PATH.."console/consoleState","ConsoleState"};--��������
    [States.ConsoleRoom]                    = {MODEL_PATH.."console/consoleRoom/consoleRoomState","ConsoleRoomState"};--��������
    [States.Room]                           = {MODEL_PATH.."room/RoomState","RoomState"};--����
    [States.Online]                         = {MODEL_PATH.."online/onlineState","OnlineState"};--��������
    [States.OnlineRoom]                     = {MODEL_PATH.."online/onlineRoom/onlineRoomState","OnlineRoomState"};--��������
	[States.UserInfo]                       = {MODEL_PATH.."userInfo/userInfoState","UserInfoState"};--�û���Ϣ
    [States.EndGate]                        = {MODEL_PATH.."endgate/endgateState","EndgateState"};--�оִ�ؿ�
    [States.EndGateSub]                     = {MODEL_PATH.."endgate/endgateSubModel/endgateSubState","EndgateSubState"};--�о�С�ؿ�
    [States.EndingRoom]                     = {MODEL_PATH.."endgate/endgateSubModel/endgateRoom/endgateRoomState","EndgateRoomState"};--�оַ���
    [States.Feedback]                       = {MODEL_PATH.."feedback/feedbackState","FeedbackState"};--��������
    [States.Mall]                           = {MODEL_PATH.."mall/mallState","MallState"};--�̳�
    [States.Rank]                           = {MODEL_PATH.."rank/newRankState","NewRankState"};--���а�
    [States.dapu]                           = {MODEL_PATH.."dapu/dapuState","DapuState"};--����
    [States.Exchange]                       = {MODEL_PATH.."exchange/exchangeState","ExchangeState"};--���һ�
    [States.Watch]                          = {MODEL_PATH.."online/watch/watchState","WatchState"};--��ս
    [States.DapuRoom]                       = {MODEL_PATH.."dapu/dapuRoom/dapuRoomState","DapuRoomState"};--���Ʒ���
    [States.Friends]                        = {MODEL_PATH.."ownModel/friends/friendsState","FriendsState"};--�����б�
    [States.FriendMsg]                      = {MODEL_PATH.."friends/friendMsg/friendMsgState","FriendMsgState"};--��Ϣ����
    [States.FriendChat]                     = {MODEL_PATH.."friends/friendChat/friendChatState","FriendChatState"};--����������
    [States.AddFriends]                     = {MODEL_PATH.."addfriends/addfriendsState","AddFriendsState"};--��Ӻ��ѽ���
    [States.FriendsInfo]                    = {MODEL_PATH.."friendsInfo/friendsInfoState","FriendsInfoState"};--������ϸ��Ϣ
    [States.watchlist]                      = {MODEL_PATH.."watchlist/watchlistState","WatchlistState"};--��ս�û��б�
    [States.FriendRoom]                     = {MODEL_PATH.."online/onlineRoom/friendRoom/friendRoomState","FriendRoomState"};--���ѷ���
    [States.Replay]                         = {MODEL_PATH.."replay/replayState","ReplayState"};--��������
    [States.CustomBoard]                    = {MODEL_PATH.."dapu/customBoard/customBoardState","CustomBoardState"};--�Զ������
    [States.RecentChess]                    = {MODEL_PATH.."dapu/recentChessState","RecentChessState"};--�������
    [States.ReplayRoom]                     = {MODEL_PATH.."dapu/replayRoom/replayRoomState","ReplayRoomState"};--���׻ط�
    [States.Collect]                        = {MODEL_PATH.."replay/collect/collectState","CollectState"};--�ҵ��ղ�
    [States.ChatRoom]                       = {MODEL_PATH.."friends/chatRoom/chatRoomState","ChatRoomState"};--������
    [States.PrivateHall]                    = {MODEL_PATH.."online/private/privateState","PrivateState"};--˽�˷�����
    [States.ownModel]                       = {MODEL_PATH.."ownModel/ownState","OwnState"};-- �ҵ�ģ��
    [States.setModel]                       = {MODEL_PATH.."ownModel/setModel/setState","SetState"};-- ���ý���
    [States.aboutModel]                     = {MODEL_PATH.."ownModel/setModel/aboutModel/aboutState","AboutState"};-- ���ڽ���
    [States.assetsModel]                    = {MODEL_PATH.."ownModel/assetsModel/assetsState","AssetsState"};-- �ҵ��ʲ�
    [States.noticeModel]                    = {MODEL_PATH.."ownModel/noticeModel/noticeState","NoticeState"};-- �ҵ���Ϣ
    [States.shareModel]                     = {MODEL_PATH.."ownModel/shareModel/shareState","ShareState"};-- �������
    [States.gradeModel]                     = {MODEL_PATH.."ownModel/gradeModel/gradeState","GradeState"};-- �ҵĵȼ�  -����
    [States.helpModel]                      = {MODEL_PATH.."ownModel/setModel/helpModel/helpState","HelpState"};-- ��������    
    [States.Comment]                        = {MODEL_PATH.."replay/comment/commentState","CommentState"};-- ���۽���
    [States.findModel]                      = {MODEL_PATH.."findModel/findState","FindState"};-- ���ֽ���
    [States.createEndgate]                  = {MODEL_PATH.."dapu/createEndgate/createEndgateState","CreateEndgateState"};-- �����о�
    [States.playCreateEndgate]              = {MODEL_PATH.."dapu/playCreateEndgateRoom/playCreateEndgateRoomState","PlayCreateEndgateRoomState"};-- �洴���о�
    [States.activity]                       = {MODEL_PATH.."activity/activityState","ActivityState"};-- �
	[States.vipModel]                       = {MODEL_PATH.."vipModule/vipModifyState","VipModifyState"};--vip�޸�
	[States.RecentlyPlayerState]            = {MODEL_PATH.."findModel/recentlyPlayer/recentlyPlayerState","RecentlyPlayerState"};--�������
	[States.commonIssue]                    = {MODEL_PATH.."ownModel/setModel/commonIssueModel/commonIssueState","CommonIssueState"};--��������
};
 