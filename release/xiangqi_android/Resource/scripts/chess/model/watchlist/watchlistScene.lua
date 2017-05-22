--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23

require(BASE_PATH.."chessScene");

WatchlistScene = class(ChessScene);

WatchlistScene.s_controls = 
{
    watch_back_btn = 1;
    ScrollContentView = 2;
}
WatchlistScene.s_cmds = 
{
    updateWatchUserList = 1;
    updateWatchUserListItem = 2;
    change_userIcon = 3;
}
WatchlistScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = WatchlistScene.s_controls;
    self:create();
end 

WatchlistScene.resume = function(self)
    ChessScene.resume(self);
end;

WatchlistScene.pause = function(self)
	ChessScene.pause(self);
end 

WatchlistScene.dtor = function(self)
end 

WatchlistScene.setListData = function(data)
    WatchlistScene.s_data = data;
end

WatchlistScene.setRedData = function(data)
    WatchlistScene.s_redData = data;
end

WatchlistScene.setBlackData = function(data)
    WatchlistScene.s_blackData = data;
end

---------------------- func --------------------

WatchlistScene.create = function(self)
    self.m_data = WatchlistScene.s_data or {};
    self.m_redData = WatchlistScene.s_redData or nil;
    self.m_blackData = WatchlistScene.s_blackData or nil;
    self.m_btn_list = {};
    self.m_scrollContentView = self:findViewById(self.m_ctrls.ScrollContentView);

    local w,h = self:getSize();
    local mw,mh = self.m_scrollContentView:getSize();
    self.m_scrollContentView:setSize(mw,mh+h-800);
    self.m_startY = 0;
    self:addRedBlackUser(self.m_redData,self.m_blackData);
    self:addWatchUser(self.m_data);
end

WatchlistScene.resetScrollView = function(self)
    self.m_scrollContentView:removeAllChildren(true);
    self.m_btn_list = {};
    self.m_startY = 0;
    self:addRedBlackUser(self.m_redData,self.m_blackData);
    self:addWatchUser(self.m_data);
end

WatchlistScene.addViewToScrollContent = function(self,view,x,y,dy)
    if not view then return end
    view:setPos(x or 0,self.m_startY + (y or 0));
    local vx,vy = view:getPos();
    local vw,vh = view:getSize();
    self.m_startY = vy + vh + (dy or 0);
    self.m_scrollContentView:addChild(view);
end

WatchlistScene.addRedBlackUser = function(self,redData,blackData) 
    local title = new(Text,"对战棋手",nil,nil,kAlignLeft,nil,20,0xe1,0xc8,0x9b);
    self:addViewToScrollContent(title,20,10,15);
    if redData then
        local item = new(WatchlistSceneItem,redData,FLAG_RED);
        item:setOnFollowClick(self,self.onWathcListItemFollowBtnClick);
        item:setAlign(kAlignTop);
        table.insert(self.m_btn_list,item);
        self:addViewToScrollContent(item);
    end
    if blackData then
        local item = new(WatchlistSceneItem,blackData,FLAG_BLACK);
        item:setOnFollowClick(self,self.onWathcListItemFollowBtnClick);
        item:setAlign(kAlignTop);
        table.insert(self.m_btn_list,item);
        self:addViewToScrollContent(item);
    end
    local space = new(Image,"drawable/userinfo_line_texture.png",nil, nil, nil, nil, nil, nil)
    space:setAlign(kAlignTop);
--    space:setFillParent(true,false);
    self:addViewToScrollContent(space,nil,-20);
end

WatchlistScene.addWatchUser = function(self,userTab)
    local title = new(Text,"旁观玩家",nil,nil,kAlignLeft,nil,20,0xe1,0xc8,0x9b);
    self:addViewToScrollContent(title,20,-10,20);
    for i,v in pairs(userTab) do
        if v.uid ~= UserInfo.getInstance():getUid() then
            local item = new(WatchlistSceneItem,v);
            item:setOnFollowClick(self,self.onWathcListItemFollowBtnClick)
            item:setAlign(kAlignTop);
            table.insert(self.m_btn_list,item);
            self:addViewToScrollContent(item);
        end
    end
end


WatchlistScene.setWatchUserListData = function(self,data)
    self.m_data = data or {};
    self:resetScrollView();
end

WatchlistScene.onUpdateWatchUserListItem = function(self,data)
    for i,v in pairs(self.m_btn_list) do
        if v:updateStatus(data.target_uid,data.relation) then
            return ;
        end
    end
end
WatchlistScene.changeUserIconCall = function(self,data)
    for i,v in pairs(self.m_btn_list) do
        if v:updateUserIcon(data) then
            return ;
        end
    end
end
--------------------- click ------------------

WatchlistScene.onBackClick = function(self)
    self:requestCtrlCmd(WatchlistController.s_cmds.back_action);
end

WatchlistScene.onWathcListItemFollowBtnClick = function(self,data)
    self:requestCtrlCmd(WatchlistController.s_cmds.follow_user,data.uid);
end
---------------------- config ------------------
WatchlistScene.s_controlConfig = 
{
    [WatchlistScene.s_controls.watch_back_btn]          = {"watch_title_view","watch_back_btn"};
    [WatchlistScene.s_controls.ScrollContentView]       = {"watch_content_view","ScrollContentView"};
};

WatchlistScene.s_controlFuncMap =
{
	[WatchlistScene.s_controls.watch_back_btn]      = WatchlistScene.onBackClick;
};

WatchlistScene.s_cmdConfig =
{
    [WatchlistScene.s_cmds.updateWatchUserList]     = WatchlistScene.setWatchUserListData;
    [WatchlistScene.s_cmds.updateWatchUserListItem] = WatchlistScene.onUpdateWatchUserListItem;
    [WatchlistScene.s_cmds.change_userIcon]         = WatchlistScene.changeUserIconCall;
}


-------------private node ----

WatchlistSceneItem = class(Node)
WatchlistSceneItem.idToIcon = UserInfo.DEFAULT_ICON[1];

WatchlistSceneItem.ctor = function(self,data,flag)
    if not data then return end;
--    "{"score":1754,"befirst":"true","isundomove":true,
--"bid":"A_201_youke_boyaa","level":8,"icon":"4",
--"drawtimes":2,"auth":0,"rank":"...","source":3,
--"money":994600,"losetimes":68,"sitemid":"307",
--"platurl":"null","client_version":1,"uid":1138,
--"version":"1.9.5","sex":0,"changeside":"true",
--"user_name":"* -T311","tid":0,"wintimes":57}"
    if flag then
        self.m_data = {};
        self.m_data.uid = data.m_uid;
        local userInfo = {};
        userInfo.score = data.m_score;
        userInfo.level = data.m_level;
        userInfo.icon = data.m_icon;
        userInfo.drawtimes = data.m_drawtimes;
        userInfo.auth = data.m_auth;
        userInfo.source = data.m_source;
        userInfo.money = data.m_money;
        userInfo.losetimes = data.m_losetimes;
        userInfo.sitemid = data.m_sitemid;
        userInfo.uid = data.m_uid;
        userInfo.sex = data.m_sex;
        userInfo.user_name = data.m_name;
        userInfo.wintimes = data.m_wintimes;
        self.m_data.userInfo = json.encode(userInfo);
        self.m_userdata = userInfo;
    else
        self.m_data = data;
        self.m_userdata = json.decode(data.userInfo);
    end

    local iconType = tonumber(self.m_userdata.icon);
        
    local iconFile = WatchlistSceneItem.idToIcon[1];

    


    local name = self.m_userdata.user_name or "";
    local sorce = self.m_userdata.score or 0;
    local userIcon = self.m_userdata.icon;
    
    local userLevelIcon = UserInfo.getInstance():getDanGradingLevelByScore(sorce) or 0;
    self.m_bg = new(Image,"common/item_bg.png");
--    self.m_bg:setOnClick(self,self.gotoUserInfoScene);
    self:addChild(self.m_bg);
    self:setSize(self.m_bg:getSize());
    self.m_userIcon_bg = new(Image,"drawable/room_user_icon_bg.png",nil,nil,30,30,30,30);
    self.m_userIcon_bg:setAlign(kAlignLeft);
    self.m_userIcon_bg:setPos(25,-5);
    self.m_userIcon_bg:setSize(74,74);
    self.m_bg:addChild(self.m_userIcon_bg);
    self.m_userIcon = new(Image,iconFile);

    if iconType then
        if 0 ~= iconType then
            iconFile = WatchlistSceneItem.idToIcon[iconType] or iconFile;
            self.m_userIcon:setFile(iconFile);
        end;
    else
        if "" ~= self.m_userdata.icon then --兼容1.7.5之前的版本的头像为""时显示默认头像。
            self.m_userIcon:setUrlImage(self.m_userdata.icon);
        else
            self.m_userIcon:setFile(iconFile);
        end;
    end;


    self.m_userIcon:setAlign(kAlignCenter);
    self.m_userIcon:setSize(64,64);
    self.m_userIcon_bg:addChild(self.m_userIcon);

    self.m_levelIcon = new(Image,"userinfo/"..userLevelIcon..".png");
    self.m_levelIcon:setAlign(kAlignBottomRight);
    self.m_levelIcon:setPos(-2,-5);
    self.m_levelIcon:setSize(24,26);
    self.m_userIcon_bg:addChild(self.m_levelIcon);

    self.m_userName = new(Text,name,nil,nil,kAlignLeft,nil,28,0x46,0x19,0x00);
    self.m_userName:setPos(115,30);
    self.m_bg:addChild(self.m_userName);
    self.m_userScore = new(Text,"积分:"..sorce,nil,nil,kAlignLeft,nil,20,0xa0,0x64,0x32);
    self.m_userScore:setPos(115,65);
    self.m_bg:addChild(self.m_userScore);

    if flag == FLAG_RED then
        self.m_flagIcon = new(Image,"drawable/watchList/red_king.png");
        self.m_flagIcon:setAlign(kAlignTopRight);
        self.m_flagIcon:setPos(115,5);
        self.m_bg:addChild(self.m_flagIcon);
    elseif flag == FLAG_BLACK then
        self.m_flagIcon = new(Image,"drawable/watchList/black_king.png");
        self.m_flagIcon:setAlign(kAlignTopRight);
        self.m_flagIcon:setPos(115,5);
        self.m_bg:addChild(self.m_flagIcon);
    end
    self.m_follow_btn = new(Button,"common/btn_green.png");
    self.m_follow_btn:setAlign(kAlignRight);
    self.m_follow_btn:setPos(20,0);
    self.m_follow_btn:setOnClick(self,self.onFollowBtnClick);
    self.m_bg:addChild(self.m_follow_btn);
    self.m_follow_btn_text = new(Text,"关注",nil,nil,kAlignLeft,nil,28,0xff,0xe6,0xb4);
    self.m_follow_btn_text:setAlign(kAlignCenter);
    self.m_follow_btn_text:setPos(0,-5);
    self.m_follow_btn:addChild(self.m_follow_btn_text);
    if FriendsData.getInstance():isYourFollow(self.m_data.uid) == -1 and 
        FriendsData.getInstance():isYourFriend(self.m_data.uid) == -1  then
        self.m_follow_btn_text:setText("关注");
        self.m_follow_btn:setEnable(true);
    else
        self.m_follow_btn_text:setText("已关注");
        self.m_follow_btn:setEnable(false);
    end
end

WatchlistSceneItem.setOnFollowClick = function(self,obj,func)
    self.m_onFollowClickObj = obj;
    self.m_onFollowClickFunc = func;
end

WatchlistSceneItem.onFollowBtnClick = function(self)
    if self.m_onFollowClickFunc then 
        self.m_onFollowClickFunc(self.m_onFollowClickObj,self.m_data);
    end
end

WatchlistSceneItem.updateStatus = function (self,uid,relation)
-- relation, =0,陌生人,=1粉丝，=2关注，=3好友
    if uid ~= self.m_data.uid then return false end;
    if relation == 2 or relation == 3 then
        self.m_follow_btn_text:setText("已关注");
        self.m_follow_btn:setEnable(false);
    else
        self.m_follow_btn_text:setText("关注");
        self.m_follow_btn:setEnable(true);
    end
    return true;
end

WatchlistSceneItem.updateUserIcon = function(self,data)
    if tonumber(data.what) ~= self.m_data.uid then return false end
    self.m_userIcon:setFile(data.ImageName);
end
--WatchlistSceneItem.gotoUserInfoScene = function(self)
--    require(MODEL_PATH.."friendsInfo/friendsInfoController");
--    FriendsInfoController.friendsID = self.m_data.uid;
--    StateMachine.getInstance():pushState(States.FriendsInfo);
--end