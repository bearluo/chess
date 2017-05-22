--region NewFile_1.lua
--Author : BearLuo
--Date   : 2015/4/23

require(BASE_PATH.."chessScene");
require(MODEL_PATH.."online/onlineScene");
require(MODEL_PATH.."findModel/recentlyPlayer/recentlyPlayerItem2");

RecentlyPlayerScene = class(ChessScene);

RecentlyPlayerScene.s_controls = 
{
    recently_player_scorll_view_bg              = 1;
    recently_player_scorll_view                 = 2;
    back_btn                                    = 3;
    recently_no_data_view                       = 4;
    quick_match_btn                             = 5;
    challenge_friends_btn                       = 6;
}

RecentlyPlayerScene.s_cmds = 
{
    add_friend_response = 1;
    addRecentlyPlayerItem       =2;
}

RecentlyPlayerScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = RecentlyPlayerScene.s_controls;

    self.m_root_view = self.m_root
    self.recentlyPlayerScorllViewBg = self:findViewById(self.m_ctrls.recently_player_scorll_view_bg);
    self.recentlyPlayerScorllView = self:findViewById(self.m_ctrls.recently_player_scorll_view);
    self.recentlyNoDataView = self:findViewById(self.m_ctrls.recently_no_data_view);
    self.recentlyNoDataView:setVisible(false);
    self.recentlyPlayerScorllView.m_autoPositionChildren = true;
    self.backBtn = self:findViewById(self.m_ctrls.back_btn);
    
    local w,h = self:getSize();
    local mw,mh = self.recentlyPlayerScorllViewBg:getSize();
    self.recentlyPlayerScorllViewBg:setSize(mw,mh+h-System.getLayoutHeight());
    
    self.recentlyPlayerScorllView:setOnScrollEvent(self,self.onScrollEvent);
    self.recentlyPlayerGroup = {};

    self.loading_view = AnimLoadingFactory.createChessLoadingAnimView()
    self.loading_view:setAlign(kAlignCenter)
    self.loading_view:setPos(nil,-20)
    self.m_root_view:addChild(self.loading_view)
    self.loading_view:start()
end 

RecentlyPlayerScene.resume = function(self)
    ChessScene.resume(self);

end

RecentlyPlayerScene.pause = function(self)
	ChessScene.pause(self);
end 

RecentlyPlayerScene.dtor = function(self)
end 
--占位
RecentlyPlayerScene.setAnimItemEnVisible = function(self,ret)
end

RecentlyPlayerScene.removeAnimProp = function(self)

end

RecentlyPlayerScene.resumeAnimStart = function(self,lastStateObj,timer)

end

RecentlyPlayerScene.pauseAnimStart = function(self,newStateObj,timer)

end


RecentlyPlayerScene.addRecentlyPlayerItem = function(self,datas,isNoData)
    self.loading_view:stop()
    self.loading_view:setVisible(false)
    if type(datas) ~= "table" or isNoData then 
        self.recentlyNoDataView:setVisible(true);
        return 
    end;
    
    if not isNoData then
        self.recentlyNoDataView:setVisible(false);
    end

    if isNoData and #self.recentlyPlayerGroup ~= 0 then
        local w,h = self.recentlyPlayerScorllView:getSize();
        local item = new(Text,"没有更多数据了", w, 100, kAlignCenter, fontName, 30, 80, 80, 80);
        self.recentlyPlayerScorllView:addChild(item);
        self.recentlyPlayerScorllView:updateScrollView();
        self.recentlyPlayerScorllView:setOnScrollEvent(nil,nil);
        return ;
    end

    for i,data in ipairs(datas) do
        local item = new(RecentlyPlayerItem2,data);
        self.recentlyPlayerScorllView:addChild(item);
        item:setFollowBtnClick(self,self.requestFollow);
        self.recentlyPlayerGroup[#self.recentlyPlayerGroup+1] = item;
    end
    self.recentlyPlayerScorllView:updateScrollView();
end

RecentlyPlayerScene.onScrollEvent = function(self,scroll_status, diffY, totalOffset,isMarginRebounding)
    local frameLength = self.recentlyPlayerScorllView:getFrameLength();  -- 显示区域
    local viewLength = self.recentlyPlayerScorllView:getViewLength();    -- 总长度
    if math.abs(totalOffset) >= viewLength - frameLength then
        self:requestCtrlCmd(RecentlyPlayerController.s_cmds.requestFriendsGetRecentWarUser);
    end
end

RecentlyPlayerScene.requestFollow = function(self,data)
    self:requestCtrlCmd(RecentlyPlayerController.s_cmds.requestFollow,data);
end

RecentlyPlayerScene.onFriendsAddFriendResponse = function(self,data)
    if type(self.recentlyPlayerGroup) == "table" then
        for i=1,#self.recentlyPlayerGroup do
            local item = self.recentlyPlayerGroup[i];
            if item and item.getTargetMid and item:getTargetMid() == data.target_mid then
                item:updateRelation(data.relation);
            end
        end
    end
end

RecentlyPlayerScene.quickMatch = function(self)
    self:requestCtrlCmd(RecentlyPlayerController.s_cmds.quickPlay);
end

RecentlyPlayerScene.challengeFriends = function(self)
    if UserInfo.getInstance():isFreezeUser() then return end;
    OnlineScene.changeFriends = true;
    StateMachine.getInstance():pushState(States.Online,StateMachine.STYPE_CUSTOM_WAIT);
end

---------------------- func --------------------
RecentlyPlayerScene.onBackBtnClick = function(self)
    self:requestCtrlCmd(RecentlyPlayerController.s_cmds.onBack);
end
---------------------- config ------------------
RecentlyPlayerScene.s_controlConfig = {
    [RecentlyPlayerScene.s_controls.back_btn]                                   = {"back_btn"};
    [RecentlyPlayerScene.s_controls.recently_player_scorll_view]                = {"recently_player_scorll_view_bg","recently_player_scorll_view"};
    [RecentlyPlayerScene.s_controls.recently_player_scorll_view_bg]             = {"recently_player_scorll_view_bg"};
    [RecentlyPlayerScene.s_controls.recently_no_data_view]                      = {"recently_player_scorll_view_bg","recently_no_data_view"};
    [RecentlyPlayerScene.s_controls.quick_match_btn]                      = {"recently_player_scorll_view_bg","recently_no_data_view","quick_match_btn"};
    [RecentlyPlayerScene.s_controls.challenge_friends_btn]                      = {"recently_player_scorll_view_bg","recently_no_data_view","challenge_friends_btn"};
   
}

RecentlyPlayerScene.s_controlFuncMap = {
    [RecentlyPlayerScene.s_controls.back_btn]                                           = RecentlyPlayerScene.onBackBtnClick;
    [RecentlyPlayerScene.s_controls.quick_match_btn]                                    = RecentlyPlayerScene.quickMatch;
    [RecentlyPlayerScene.s_controls.challenge_friends_btn]                              = RecentlyPlayerScene.challengeFriends;
};

RecentlyPlayerScene.s_cmdConfig =
{
    [RecentlyPlayerScene.s_cmds.add_friend_response]                     = RecentlyPlayerScene.onFriendsAddFriendResponse;
    [RecentlyPlayerScene.s_cmds.addRecentlyPlayerItem]                          = RecentlyPlayerScene.addRecentlyPlayerItem;
    
}