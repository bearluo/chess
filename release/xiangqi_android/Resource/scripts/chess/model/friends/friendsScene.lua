require(BASE_PATH.."chessScene");
require("dialog/chioce_dialog");
require("dialog/http_loading_dialog");

require(MODEL_PATH.."friendsInfo/friendsInfoController");

FriendsScene = class(ChessScene);

FriendsScene.s_changeState = true;
FriendsScene.itemType = 0;
FriendsScene.itemPaiHangType = 0;
FriendsScene.FriendsType = 0;

FriendsScene.friendsNum = 0;
FriendsScene.fansNum = 0;
FriendsScene.paiHangRank = {};

FriendsScene.default_icon = "userinfo/women_head02.png";

FriendsScene.s_controls = 
{
	friends_back_btn = 1; --返回
    friends_add_btn = 2; --添加

    friends_btn =3; --好友 好友列表
    att_btn = 4; -- 好友 好友关注
    fans_btn = 5; --好友 好友粉丝

    friendslist_btn = 6; -- 排行榜 好友榜
    charmlist_btn = 7; -- 排行榜 魅力榜
    masterlist_btn = 8; -- 排行榜 大师榜

    friends_list = 9; --好友列表
    attention_list = 10; --关注列表
    fans_list = 11; --粉丝列表
  
    friends_newadd_num = 12;--新增好友数量
    fans_newadd_num = 13; --新增粉丝数量

    friendslist_view = 14; -- 好友榜view
    charmlist_view = 15; -- 魅力榜view
    masterlist_view = 16; -- 大师榜view

    friendslist = 17;
    friendslist_press = 18;
    charmlist = 19;
    charmlist_press = 20;
    masterlist = 21;
    masterlist_press = 22;


    friends = 23;
    friends_press = 24;
    attention = 25;
    attention_press = 26;
    fans = 27;
    fans_press = 28;

    newnum = 29;
    addtile = 30;

    friendsnum = 31;
    follownum = 32;
    fansnum = 33;

    my_rank_frame = 34;
    my_rank_name = 35;
    my_rank_points  = 36;
    my_rank_pos = 37;
--    my_rank_fans = 37;
} 

FriendsScene.s_cmds = 
{
    changeState = 1;
    changeFriendsList = 2;
    changeFollowList = 3;
    changeFansList = 4;

    changeFriendsData = 5;
    changeFriendstatus = 6;

    change_friends = 7;--好友
    change_charm = 8;--魅力
    change_master = 9;--大师榜

    change_userIcon = 10; -- 更新用户头像
    newfriendsNum = 11;

    friends_num = 12;
    follow_num = 13;
    fans_num = 14;

    my_friend_rank = 15;
    my_charm_rank = 16;
    my_master_rank = 17;

}

FriendsScene.ctor = function(self,viewConfig,controller)
	self.m_ctrls = FriendsScene.s_controls;
    self.m_kindNum = controller.m_state.kinf_num;
    --好友
    self.friends_list_check = true;
    self.attention_list_check = false;
    self.fans_list_check = false;

    --排行榜
    self.friendslist_check = true;
    self.charmlistlist_check = false;
    self.masterlist_check = false;

    self:init();

end 

FriendsScene.resume = function(self)
    ChessScene.resume(self);
    self:reset();
end;

FriendsScene.pause = function(self)
	ChessScene.pause(self);

end 

FriendsScene.dtor = function(self)
    delete(self.FriendsloadingDialog);
end 

----------------------------------- function ----------------------------
FriendsScene.init = function(self)
    Log.d("FriendsScene.init");

    FriendsScene.itemType = 1;
    FriendsScene.FriendsType = 1;
    FriendsScene.itemPaiHangType = 1;
    
    self.m_FriendsView = self:findViewById(self.m_ctrls.friends_list); --好于listview
    self.m_AttentionView = self:findViewById(self.m_ctrls.attention_list);--关注listview
    self.m_FansView = self:findViewById(self.m_ctrls.fans_list); -- 粉丝listview

    self.m_FriendslistView = self:findViewById(self.m_ctrls.friendslist_view); 
    self.m_CharmlistView = self:findViewById(self.m_ctrls.charmlist_view);
    self.m_MasterlistView = self:findViewById(self.m_ctrls.masterlist_view); 

    self.charmlist_btn = self:findViewById(self.m_ctrls.charmlist_btn);
    self.friendslist_btn = self:findViewById(self.m_ctrls.friendslist_btn);
    self.masterlist_btn = self:findViewById(self.m_ctrls.masterlist_btn);

    self.friendslist = self:findViewById(self.m_ctrls.friendslist);
    self.friendslist_press = self:findViewById(self.m_ctrls.friendslist_press);
    self.charmlist = self:findViewById(self.m_ctrls.charmlist);
    self.charmlist_press = self:findViewById(self.m_ctrls.charmlist_press);
    self.masterlist = self:findViewById(self.m_ctrls.masterlist);
    self.masterlist_press = self:findViewById(self.m_ctrls.masterlist_press);


    self.friends_btn = self:findViewById(self.m_ctrls.friends_btn);
    self.att_btn = self:findViewById(self.m_ctrls.att_btn);
    self.fans_btn = self:findViewById(self.m_ctrls.fans_btn);

    self.friends = self:findViewById(self.m_ctrls.friends);
    self.friends_press = self:findViewById(self.m_ctrls.friends_press);
    self.attention = self:findViewById(self.m_ctrls.attention);
    self.attention_press = self:findViewById(self.m_ctrls.attention_press);
    self.fans = self:findViewById(self.m_ctrls.fans);
    self.fans_press = self:findViewById(self.m_ctrls.fans_press);
    self.newnum = self:findViewById(self.m_ctrls.newnum);
    self.addtile = self:findViewById(self.m_ctrls.addtile);

    self.friendsnum = self:findViewById(self.m_ctrls.friendsnum);
    self.follownum = self:findViewById(self.m_ctrls.follownum);
    self.fansnum = self:findViewById(self.m_ctrls.fansnum);

    self.friendsnum:setVisible(false);
    self.follownum:setVisible(false); 
    self.fansnum:setVisible(false);

    self.m_root_view = self.m_root;
	self.m_title_view = self.m_root_view:getChildByName("friends_title_view"); 
    self.ranking_list_view = self.m_root_view:getChildByName("ranking_list_view"); 
    self.friends_list_view = self.m_root_view:getChildByName("friends_list_view"); 
    self.m_select_title = self.m_title_view:getChildByName("friends_title_select");
    self.friendsback_select_btn = new(RadioButton,{"common/left_normal.png","common/left_choose.png"});
    self.rule_select_btn = new(RadioButton,{"common/right_normal.png","common/right_choose.png"});
    self.friendsback_select_btn_icon = new(Image,"friends/cfriends_on.png");
    self.rule_select_btn_icon = new(Image,"friends/rankinglist_on.png");
    self.friendsback_select_btn:addChild(self.friendsback_select_btn_icon);
    self.rule_select_btn:addChild(self.rule_select_btn_icon);
    self.m_select_title:addChild(self.friendsback_select_btn);
    self.m_select_title:addChild(self.rule_select_btn);
    self.friendsback_select_btn_icon:setAlign(kAlignCenter);
    self.friendsback_select_btn_icon:setPos(2,-3);
    self.rule_select_btn_icon:setPos(2,0);
    self.m_select_title:setOnChange(self,self.onSelectTitleChangeClick);
    local w = self.friendsback_select_btn:getSize();
    self.rule_select_btn:setPos(w);
    self:changeState(FriendsScene.s_changeState);
  

    self.friends_list_view:setVisible(true);
    self.friendsback_select_btn_icon:setFile("friends/cfriends_on.png");
    self.ranking_list_view:setVisible(false);
    self.rule_select_btn_icon:setFile("friends/rankinglist_off.png");


    self.friends_newadd_num = self:findViewById(self.m_ctrls.friends_newadd_num); --新增好友数量
    self.fans_newadd_num = self:findViewById(self.m_ctrls.fans_newadd_num);--新增粉丝数量

    _,bottom_posY = self:getSize();
    self.m_FriendslistView:setSize(480,540+bottom_posY-800);
    self.m_CharmlistView:setSize(480,540+bottom_posY-800);
    self.m_MasterlistView:setSize(480,540+bottom_posY-800);
    self.m_FriendsView:setSize(480,640+bottom_posY-800);
    self.m_AttentionView:setSize(480,640+bottom_posY-800);
    self.m_FansView:setSize(480,640+bottom_posY-800);
    
    self.m_my_rank_frame = self:findViewById(self.m_ctrls.my_rank_frame);
    self.m_my_rank_name = self:findViewById(self.m_ctrls.my_rank_name);
    self.m_my_rank_points = self:findViewById(self.m_ctrls.my_rank_points);
    self.m_my_rank_pos = self:findViewById(self.m_ctrls.my_rank_pos);
    self.m_my_rank_name:setText(UserInfo.getInstance():getName());
    self.m_my_rank_points:setText("积分：" .. UserInfo.getInstance():getScore());

    self:updateHeadIcon();
    
    self.m_level = new(Image,"userinfo/1.png");
    self.m_level:setAlign(kAlignBottomRight);
    self.m_level:setPos(-8,-10);
    self.my_rank_icon:addChild(self.m_level);
    self.m_level:setFile("userinfo/"..UserInfo.getInstance():getDanGradingLevelByScore(UserInfo.getInstance():getScore())..".png");  --tonumber(self.datas.score)


end

FriendsScene.updateHeadIcon = function(self)
    local user_icon_type = UserInfo.getInstance():getIconType();
    local user_icon_url = UserInfo.getInstance():getIcon();
    print_string("更新头像...");
    if user_icon_type > 0 then
        self.my_rank_icon = new(Image,UserInfo.DEFAULT_ICON[user_icon_type] or UserInfo.DEFAULT_ICON[1]); 
    elseif user_icon_type == 0 then
        self.my_rank_icon = new(Image,FriendsScene.default_icon);
    else
        self.my_rank_icon = new(Image,"userinfo/userHead.png");
        self.my_rank_icon:setUrlImage(user_icon_url);
    end
   
    self.my_rank_icon:setAlign(kAlignCenter);
    self.my_rank_icon:setSize(64,64);
    self.m_my_rank_frame:addChild(self.my_rank_icon);
    
end

--loading界面
FriendsScene.loadingTile = function(self,string)
    delete(self.FriendsloadingDialog);
    self.FriendsloadingDialog = new(HttpLoadingDialog);
    ChessDialogScene.setBgOnTouchClick(self.FriendsloadingDialog,nil);

    self.FriendsloadingDialog:setType(HttpLoadingDialog.s_type.Normel,string,false);
    self.FriendsloadingDialog:show(nil,false);

end

FriendsScene.loadingTileExit = function(self)
    if self.FriendsloadingDialog~= nil then
        self.FriendsloadingDialog:dismiss();
    end
end

----好友列表
FriendsScene.updateFriends_list = function(self)
    local datas = self:requestCtrlCmd(FriendsController.s_cmds.ongetfriendslist);
    self:createFriendsListView(datas);
end

FriendsScene.createFriendsListView = function(self,datas)
    self.m_FriendsView:releaseAllViews();
    delete(self.m_adapter_friends);
    self.m_adapter_friends = nil;
    if not datas or #datas < 1 then 
        return ; 
    end

    self.m_friendListData = datas;
    self.m_adapter_friends = new(CacheAdapter,FriendsItem,datas);
    self.m_FriendsView:setAdapter(self.m_adapter_friends);
end

---- 关注列表
FriendsScene.updateAttention_list = function(self)
    local datas = self:requestCtrlCmd(FriendsController.s_cmds.ongetfollowlist);
    self:createAttentionListView(datas);
end

FriendsScene.createAttentionListView = function(self,datas)
    self.m_AttentionView:releaseAllViews();
    delete(self.m_adapter_attention);
    self.m_adapter_attention = nil;
    if not datas or #datas < 1 then  
        return ; 
    end
    
    self.m_attentionListData = datas;
    self.m_adapter_attention = new(CacheAdapter,FriendsItem,datas);
    self.m_AttentionView:setAdapter(self.m_adapter_attention);

end

---- 粉丝列表
FriendsScene.updateFans_list = function(self)
    local datas = self:requestCtrlCmd(FriendsController.s_cmds.ongetfanslist);
    self:createFansListView(datas);
end

FriendsScene.createFansListView = function(self,datas)
    self.m_FansView:releaseAllViews();
    delete(self.m_adapter_fans);
    self.m_adapter_fans = nil;
    if not datas or #datas < 1 then
        return ; 
    end
    
    self.m_fansListData = datas;
    self.m_adapter_fans = new(CacheAdapter,FriendsItem,datas)
    self.m_FansView:setAdapter(self.m_adapter_fans);

end

---------------------------------列表更新------------------------------------------
---------数据更新接口
FriendsScene.changeDataCall = function(self,state) 
   self:changeFriendsDataCall(state,self.m_adapter_friends);--好友
   self:changeFriendsDataCall(state,self.m_adapter_attention);--关注
   self:changeFriendsDataCall(state,self.m_adapter_fans);--粉丝
   self:changePaiFriendsDataCall(state,self.m_friends_adapter);--排行榜好友

end

---------排行榜好友数据更新实现方法
FriendsScene.changePaiFriendsDataCall = function(self,friendsdata,m_adapte)
    if m_adapte and friendsdata then
        local datas = m_adapte:getData();
        for i,m_da in pairs(datas) do
            for _,sdata in pairs(friendsdata) do
                if m_da.mid == sdata.mid then
                    self:updatePaiFriendsView(i,sdata,m_adapte);
                    break;
                end
            end
        end
    end
end


FriendsScene.updatePaiFriendsView = function(self,index,data,m_adapte)
    if m_adapte then
        m_adapte:updateData(index,data);
    end

end

---------数据更新实现方法
FriendsScene.changeFriendsDataCall = function(self,friendsdata,m_adapte)
    if m_adapte and friendsdata then
        local datas = m_adapte:getData();
        for i,uid in pairs(datas) do
            for _,sdata in pairs(friendsdata) do
                if uid == tonumber(sdata.mid) then
                    self:updateFriendsView(i,tonumber(sdata.mid),m_adapte);
                    break;
                end
            end
        end
    end
end

FriendsScene.updateFriendsView = function(self,index,data,m_adapte)
    if m_adapte then
        m_adapte:updateData(index,data);
    end
end

--------状态更新接口---------------------------------------
FriendsScene.changeStatusCall = function(self,status)
    self:changeFriendsStatusCall(status,self.m_adapter_friends);--好友
    self:changeFriendsStatusCall(status,self.m_adapter_attention);--关注
    self:changeFriendsStatusCall(status,self.m_adapter_fans);--粉丝

    self:changePaiHangStatusCall(status,self.m_charm_adapter); --魅力
    self:changePaiHangStatusCall(status,self.m_master_adapter); --大师
    self:changePaiHangStatusCall(status,self.m_friends_adapter); --好友
    
end

FriendsScene.changePaiHangStatusCall = function(self,status,m_adapte)

    if status and m_adapte then
        local datas = m_adapte:getData();
        for i,uid in pairs(datas) do
            for _,sdata in pairs(status) do
                if uid == sdata.uid and m_adapte:isHasView(i) then
                    local view = m_adapte:getTmpView(i);
                    self:changePaiHangView(view);
                end
            end
        end
    end

end

FriendsScene.changePaiHangView = function(self,view)
    view:changeStatus();
end

--------好友状态更新实现方法
FriendsScene.changeFriendsStatusCall = function(self,status,m_adapte)
   
   if status and m_adapte then
        local datas = m_adapte:getData();
        for i,uid in pairs(datas) do
            for _,sdata in pairs(status) do
                if uid == sdata.uid and m_adapte:isHasView(i) then
                    local view = m_adapte:getTmpView(i);
                    self:changeFriendsView(view,sdata);
                end
            end
        end
   end
end


FriendsScene.changeFriendsView = function(self,view,status)
    --local time = FriendsScene.getTime(status.last_time);

    if view ~= nil and status ~= nil then
        if status.hallid <=0 then --离线
            view.m_icon:setGray(true);
            view.m_title.setText(view.m_title,view.m_title.m_str,nil,nil,100,100,100);
            view.m_contentTextTitle.setText(view.m_contentTextTitle,"积分:",nil, nil,100,100,100);
            view.m_contentText.setText(view.m_contentText,view.m_contentText.m_str,nil, nil,100,100,100);
            if view.last_login_time and view.last_login_time ~= "" then
                view.m_lasttimeTitle.setText(view.m_lasttimeTitle,"最近登陆:",nil, nil,100,100,100);
                view.m_lasttimeTitleNum.setText(view.m_lasttimeTitleNum,view.last_login_time,nil, nil,100,100,100);
            else
                view.m_lasttimeTitle.setText(view.m_lasttimeTitle,"",nil, nil,100,100,100);
                view.m_lasttimeTitleNum.setText(view.m_lasttimeTitleNum,"",nil, nil,100,100,100);
            end
        else --在线
            view.m_icon:setGray(false);
            view.m_title.setText(view.m_title,view.m_title.m_str,nil,nil,70,25,0);
            view.m_contentTextTitle.setText(view.m_contentTextTitle,"积分:",nil, nil,160,100,50);
            view.m_contentText.setText(view.m_contentText,view.m_contentText.m_str,nil, nil,160,100,50);

            view.m_lasttimeTitle.setText(view.m_lasttimeTitle,"在线",nil, nil,160,100,50);
            view.m_lasttimeTitleNum:setVisible(false);
            view.m_lasttimeTitle:setPos(190,0);

            if RoomConfig.getInstance():isPlaying(status) then -- 用户在下棋
                local strname = RoomConfig.getInstance():onGetScreenings(status);
                if strname == nil then
                    view.m_lasttimeTitle.setText(view.m_lasttimeTitle,"在线",nil, nil,160,100,50);
                else
                    view.m_lasttimeTitle.setText(view.m_lasttimeTitle,strname,nil, nil,160,100,50);
                end
            end

        end 
    end     
end


---魅力榜
FriendsScene.changeCharmCall = function(self,datas)
    Log.d("ZY changeCharmCall");
    self:loadingTileExit();
    self.m_CharmlistView:releaseAllViews();
    delete(self.m_charm_adapter);
    self.m_charm_adapter = nil;
    if not datas or #datas < 2 then 
        self.changeCharmData = datas;
        ChessToastManager.getInstance():show("暂无魅力榜!",500);
        return;
    end

    self.changeCharmData = datas;
    self.m_charm_adapter = new(CacheAdapter,RankCharmsItem,datas);
    self.m_CharmlistView:setAdapter(self.m_charm_adapter);

end

--大师榜
FriendsScene.changeMasterCall = function(self,datas)
    Log.d("ZY changeMasterCall");
    self:loadingTileExit();
    self.m_MasterlistView:releaseAllViews();
    delete(self.m_master_adapter);
    self.m_master_adapter = nil;
    if not datas or #datas < 1 then 
        self.masterData = datas;
        ChessToastManager.getInstance():show("暂无大师榜!",500);
        return;
    end

    self.masterData = datas;
    self.m_master_adapter = new(CacheAdapter,RankMasterItem,datas);
    self.m_MasterlistView:setAdapter(self.m_master_adapter);
end

--好友榜
FriendsScene.changeFriendsCall = function(self,datas)
    Log.d("ZY changeFriendsCall");
    self:loadingTileExit();
    self.m_FriendslistView:releaseAllViews();
    delete(self.m_friends_adapter);
    self.m_friends_adapter = nil;
    if not datas or #datas < 1 then
        self.changeFriendsData = datas; 
        ChessToastManager.getInstance():show("暂无好友榜!",500);
        return;
    end

    local ranks  = {};
    local ranktd  = {};
	for i,value in pairs(datas) do 
        local user = {};
		user.mid     = value.uid;
		user.score    = value.score;
        user.rank     = i;
        table.insert(ranks,user);
        table.insert(ranktd,user);
	end

    FriendsScene.paiHangRank = {};
    FriendsScene.paiHangRank = ranktd;

    self.changeFriendsData = datas; 
    self.m_friends_adapter = new(CacheAdapter,RankFriendsItem,ranks);
    self.m_FriendslistView:setAdapter(self.m_friends_adapter);

end

--新增通讯录好友数量
FriendsScene.changeNewfriendsNumCall = function(self,datas)
    Log.d("ZY changeNewfriendsNumCall");
    --a and b -- 如果a 为false，则返回a，否则返回b
    --a or b -- 如果a 为true，则返回a，否则返回b

    if datas == nil then 
        self.addtile:setVisible(false);
        return; 
    end
    
    self.newFriendsDatas = datas.list;
    if self.newFriendsDatas == nil then
        self.addtile:setVisible(false);
    else
        if datas.total == 0 then
            self.addtile:setVisible(false);
        else
            self.addtile:setVisible(true);
            self.newnum.setText(self.newnum,datas.total);
        end
    end

end

FriendsScene.changeFriendsNumCall = function(self,info) --好友数目
    if info == nil then return; end 

    if info.num <= 0 then
        self.friendsnum:setVisible(false);
    else
        local number = "好友："..info.num.."人";
        self.friendsnum:setVisible(true);
        self.friendsnum:setText(number);
    end
       
end

FriendsScene.changeFollowNumCall = function(self,info) --关注数目
    if info == nil then return; end 

    if info.num <= 0 then
        self.follownum:setVisible(false); 
    else
         local number = "关注："..info.num.."人";
         self.follownum:setVisible(true); 
         self.follownum:setText(number); 
    end
      
end

FriendsScene.changeFansNumCall = function(self,info) --粉丝数目
    if info == nil then return; end
      
    if info.num <= 0 then
        self.fansnum:setVisible(false);
    else
        local number = "粉丝："..info.num.."人";
        self.fansnum:setVisible(true);
        self.fansnum:setText(number);
    end
    
end



--------用户头像更新接口
FriendsScene.changeUserIconCall = function(self,data)
    Log.i("changeUserIconCall");
      -- 自己
      self:changeMyRankIconCall(data);
      --好友
      self:changeListUserIconCall(data,self.m_adapter_friends,self.m_friendListData);
      -- 关注
      self:changeListUserIconCall(data,self.m_adapter_attention,self.m_attentionListData);
      -- 粉丝
      self:changeListUserIconCall(data,self.m_adapter_fans,self.m_fansListData);
      -- 好友
      self:changeListUserIconCall2(data,self.m_friends_adapter,self.changeFriendsData);
      -- 魅力
      self:changeListUserIconCall2(data,self.m_charm_adapter,self.changeCharmData);
      -- 大师
      self:changeListUserIconCall2(data,self.m_master_adapter,self.masterData);
end
--------自己排行榜头像更新
FriendsScene.changeMyRankIconCall = function(self,data)
    Log.i("my icon data" .. json.encode(data));
    if tonumber(data.what) ==  tonumber(UserInfo.getInstance():getUid()) then
        self.my_rank_icon:setFile(data.ImageName or "userinfo/userHead.png");
    end
end
--------用户头像更新实现方法
FriendsScene.changeListUserIconCall = function(self,data,m_adapte,datas)
   Log.i("changeListUserIconCall");
   if not datas then
       return;
   end
   if data and m_adapte then
--        local datas = m_adapte:getData();
       for i,v in pairs(datas) do
           if v == tonumber(data.what) and m_adapte:isHasView(i) then
               local view = m_adapte:getTmpView(i);
               view:updateUserIcon(data.ImageName);
           end
       end
   end
end

--------用户头像更新实现方法 2 
FriendsScene.changeListUserIconCall2 = function(self,data,m_adapte,datas)
    Log.i("changeListUserIconCall");
   if not datas then
       return;
   end
   if data and m_adapte then
--        local datas = m_adapte:getData();
        for i,v in pairs(datas) do
            if v.mid == tonumber(data.what) and m_adapte:isHasView(i) then
                local view = m_adapte:getTmpView(i);
                view:updateUserIcon(data.ImageName);
            end
        end
   end
end

-------------------------------------------------------------------------------------------

FriendsScene.getTime = function(time)
    if ToolKit.isSecondDay(time) then
        return os.date("%m-%d",time);-- 08-07格式
    else
        return os.date("%H:%M",time);--%Y/%m/%d %X
    end;
end


FriendsScene.reset = function(self)


    if FriendsScene.FriendsType == 1 then--好友榜

    if self.friends_list_check then --更新好友列表
        local datas = self:requestCtrlCmd(FriendsController.s_cmds.ongetfriendslist);
        if not datas or #datas < 1 then 
            self.m_FriendsView:releaseAllViews();
            delete(self.m_adapter_friends);
            self.m_adapter_friends = nil;
            ChessToastManager.getInstance():show("暂无好友！",500);
        end
    end

    if self.attention_list_check then --更新关注列表
        local datas = self:requestCtrlCmd(FriendsController.s_cmds.ongetfollowlist);
        if not datas or #datas < 1 then 
            self.m_AttentionView:releaseAllViews();
            delete(self.m_adapter_attention);
            self.m_adapter_attention = nil;
            ChessToastManager.getInstance():show("暂无关注！",500);
        end
    end

    if self.fans_list_check then --更新粉丝列表
        local datas = self:requestCtrlCmd(FriendsController.s_cmds.ongetfanslist);
        if not datas or #datas < 1 then 
            self.m_FansView:releaseAllViews();
            delete(self.m_adapter_fans);
            self.m_adapter_fans = nil;
            ChessToastManager.getInstance():show("暂无粉丝！",500);
        end
    end


    self:updateFriends_list();
    self:updateAttention_list();
    self:updateFans_list();
    --更新好友，粉丝新增数量
    self:updateNewNum();

    else
        --排行榜
        if FriendsScene.itemPaiHangType == 1 then
            if not self.changeFriendsData or #self.changeFriendsData < 1 then
                ChessToastManager.getInstance():show("暂无好友榜！",500);
            else
                --self:loadingTile("搜索好友榜信息");
                --self:requestCtrlCmd(FriendsController.s_cmds.change_friends);
            end
        elseif FriendsScene.itemPaiHangType == 2 then
            if not self.changeCharmData or #self.changeCharmData < 1 then
                ChessToastManager.getInstance():show("暂无魅力榜！",500);
            else
                --self:loadingTile("搜索魅力榜信息");
                --self:requestCtrlCmd(FriendsController.s_cmds.change_charm);
            end
        elseif FriendsScene.itemPaiHangType == 3 then
            if not self.masterData or #self.masterData < 1 then
                ChessToastManager.getInstance():show("暂无大师榜！",500);
            else
                --self:loadingTile("搜索大师榜信息");
                --self:requestCtrlCmd(FriendsController.s_cmds.change_master);
            end
        end

    end

    if self.m_kindNum == 10086 then
        self.m_kindNum = 0;
        self.friends_list_view:setVisible(false);
        self.friendsback_select_btn_icon:setFile("friends/cfriends_off.png");
        self.ranking_list_view:setVisible(true);
        self.rule_select_btn_icon:setFile("friends/rankinglist_on.png");

        self.friendsback_select_btn:setChecked(false);
        self.rule_select_btn:setChecked(true);
        self:onSelectTitleChangeClick();
    end

end


FriendsScene.changeFriendsListCall = function(self)

    ChessToastManager.getInstance():clearAllToast();
    if self.friends_list_check then --更新好友列表
        self:updateFriends_list();
    end

    --更新好友，粉丝新增数量
    self:updateNewNum();

end
FriendsScene.changeFollowListCall = function(self)

    if self.attention_list_check then --更新关注列表
        self:updateAttention_list();
    end

end
FriendsScene.changeFansListCall = function(self)

    if self.fans_list_check then --更新粉丝列表
        self:updateFans_list();
    end

    --更新好友，粉丝新增数量
    self:updateNewNum();

end


FriendsScene.updateNewNum = function(self)

    local friendsNum = 0;
    local fansNum = 0;

    local friendsList = self:requestCtrlCmd(FriendsController.s_cmds.ongetfriendslist); 
    local fansList = self:requestCtrlCmd(FriendsController.s_cmds.ongetfanslist); 

    if friendsList~= nil then
        for i,uid in pairs(friendsList) do
                if FriendsData.getInstance():isNewFriends(uid) == 1 then
                    friendsNum = friendsNum + 1;
                end
        end
    end

    if fansList~= nil then
        for i,uid in pairs(fansList) do
                if FriendsData.getInstance():isNewFans(uid) == 1 then
                    fansNum = fansNum + 1;
                end
        end
    end

    --好友和粉丝后面要显示新增加的好友和粉丝的数量
    if friendsNum <= 0 then
        self.friends_newadd_num:setVisible(false);
    else
        self.friends_newadd_num:setVisible(true);
        self.friends_newadd_num.setText(self.friends_newadd_num,"+"..friendsNum);--新增好友数量
    end

    if fansNum <= 0 then
        self.fans_newadd_num:setVisible(false);
    else
        self.fans_newadd_num:setVisible(true);
        self.fans_newadd_num.setText(self.fans_newadd_num,"+"..fansNum);--新增粉丝数量
    end
   

end

FriendsScene.onSelectTitleChangeClick = function(self)

    self:loadingTileExit();

    if self.friendsback_select_btn:isChecked() then
        --更新新好友标签
        self:updateFriends_list();
        self:updateAttention_list();
        self:updateFans_list();

        FriendsScene.FriendsType = 1;
        self.friends_list_view:setVisible(true);
        self.friendsback_select_btn_icon:setFile("friends/cfriends_on.png");

        if FriendsScene.itemType == 1 then  
            local datas = self:requestCtrlCmd(FriendsController.s_cmds.ongetfriendslist);
            if not datas or #datas < 1 then 
                ChessToastManager.getInstance():show("暂无好友！",500);
            end
        end

        if FriendsScene.itemType == 2 then  
            local datas = self:requestCtrlCmd(FriendsController.s_cmds.ongetfollowlist);
            if not datas or #datas < 1 then 
                ChessToastManager.getInstance():show("暂无关注！",500);
            end
        end

        if FriendsScene.itemType == 3 then  
            local datas = self:requestCtrlCmd(FriendsController.s_cmds.ongetfanslist);
            if not datas or #datas < 1 then 
                ChessToastManager.getInstance():show("暂无粉丝！",500);
            end
        end

    else
        self:exitNewTile1();
        self:exitNewTile2();
        self:updateNewNum();
        FriendsScene.FriendsType = 2;
        self.friends_list_view:setVisible(false);
        self.friendsback_select_btn_icon:setFile("friends/cfriends_off.png");
    end

    if self.rule_select_btn:isChecked() then
        self.ranking_list_view:setVisible(true);
        self.rule_select_btn_icon:setFile("friends/rankinglist_on.png");

        if FriendsScene.itemPaiHangType == 1 then
            self:loadingTile("搜索好友榜信息");
            self:requestCtrlCmd(FriendsController.s_cmds.change_friends);
        elseif FriendsScene.itemPaiHangType == 2 then
            self:loadingTile("搜索魅力榜信息");
            self:requestCtrlCmd(FriendsController.s_cmds.change_charm);
        elseif FriendsScene.itemPaiHangType == 3 then
            self:loadingTile("搜索大师榜信息");
            self:requestCtrlCmd(FriendsController.s_cmds.change_master);
        end

    else
        self.ranking_list_view:setVisible(false);
        self.rule_select_btn_icon:setFile("friends/rankinglist_off.png");
    end

end

FriendsScene.changeState = function(self,state)
    if state then
        self.friendsback_select_btn:setChecked(true);
    else
        self.rule_select_btn:setChecked(true);
    end
end
--更新我的排名
FriendsScene.updataMyRank = function(self,info,label)
    print_string("更新我的排名...");
    if label == 1 then
        self.m_my_rank_points:setText("积分：" .. UserInfo.getInstance():getScore());

        self.m_my_rank_pos:setText(info.rank);
    end
    if label == 2 then
        print_string("更新我的魅力排名...");
        local pos = info.rank;
        local temp_pos = "";
        if pos == 0 then
            temp_pos = "5000+";
        else
            temp_pos = pos .."";
        end
        self.m_my_rank_points:setText("粉丝：" .. info.fans_num);
        self.m_my_rank_pos:setText(temp_pos);
    end
    if label == 0 then
        print_string("更新我的大师排名...");
        self.m_my_rank_points:setText("积分：" .. UserInfo.getInstance():getScore());
        local pos = info.rank;
        local temp_pos = "";
        if pos == 0 then
            temp_pos = "5000+";
        else
            temp_pos = pos.."";
        end
         self.m_my_rank_pos:setText(temp_pos);
    end
end

----------------------------------- onClick -------------------------------------

FriendsScene.onFriendsBackBtnClick = function(self) --返回
    Log.d("FriendsScene.onFriendsBackBtnClick");

    self:loadingTileExit();
    if FriendsScene.itemType == 1 then
        self:exitNewTile1();
    elseif FriendsScene.itemType == 3 then
        self:exitNewTile2();
    end
        
    self:requestCtrlCmd(FriendsController.s_cmds.back_action);
end

FriendsScene.onFriendsAddBtnClick = function(self) --添加关注
    Log.d("FriendsScene.onFriendsAddBtnClick"); 
    self:loadingTileExit();

    self:exitNewTile1();
    self:exitNewTile2();
    self:updateNewNum();
    self:requestCtrlCmd(FriendsController.s_cmds.addfriends,self.newFriendsDatas);
end

FriendsScene.onFriendsBtnClick = function(self) -- 切换好友列表
    Log.d("FriendsScene.onFriendsBtnClick");
    if self.friends_list_check == false then
        self.friends_list_check = true;
        self.attention_list_check = false;
        self.fans_list_check = false;


        self.friends_btn:setFile("friends/rankingbtn_press.png");
        self.att_btn:setFile("friends/btn_normal.png");
        self.fans_btn:setFile("friends/btn_normal.png");

        self.friends:setVisible(false);
        self.friends_press:setVisible(true);
        self.attention:setVisible(true); 
        self.attention_press:setVisible(false);
        self.fans:setVisible(true);
        self.fans_press:setVisible(false);

        
        self.m_FriendsView:setVisible(true);
        self.m_AttentionView:setVisible(false);
        self.m_FansView:setVisible(false);

        self.friends_newadd_num.setColor(self.friends_newadd_num,125,70,30);
        self.fans_newadd_num.setColor(self.fans_newadd_num,80,190,130);

        
        local datas = self:requestCtrlCmd(FriendsController.s_cmds.ongetfriendslist);
        if not datas or #datas < 1 then 
            ChessToastManager.getInstance():show("暂无好友！",500);
        end

        FriendsScene.itemType = 1;
        self:updateFriends_list();

        self:exitNewTile2();
        self:updateNewNum();
    end
end


FriendsScene.onFriendsattBtnClick = function(self) --切换关注列表
    Log.d("FriendsScene.onFriendsattBtnClick");
    if self.attention_list_check == false then
        self.friends_list_check = false;
        self.attention_list_check = true;
        self.fans_list_check = false;


        self.friends_btn:setFile("friends/btn_normal.png");
        self.att_btn:setFile("friends/rankingbtn_press.png");
        self.fans_btn:setFile("friends/btn_normal.png");

        self.friends:setVisible(true);
        self.friends_press:setVisible(false);
        self.attention:setVisible(false); 
        self.attention_press:setVisible(true);
        self.fans:setVisible(true);
        self.fans_press:setVisible(false);

       
        self.m_FriendsView:setVisible(false);
        self.m_AttentionView:setVisible(true);
        self.m_FansView:setVisible(false);

        self.friends_newadd_num.setColor(self.friends_newadd_num,80,190,130);
        self.fans_newadd_num.setColor(self.fans_newadd_num,80,190,130);
 
        
        local datas = self:requestCtrlCmd(FriendsController.s_cmds.ongetfollowlist);
        if not datas or #datas < 1 then 
            ChessToastManager.getInstance():show("暂无关注！",500);
        end

        FriendsScene.itemType = 2;
        self:updateAttention_list();

        self:exitNewTile1();
        self:exitNewTile2();
        self:updateNewNum();
    end
end


FriendsScene.onFriendsfansBtnClick = function(self)  --切换粉丝列表
    Log.d("FriendsScene.onFriendsfansBtnClick");
    if self.fans_list_check == false then
        self.friends_list_check = false;
        self.attention_list_check = false;
        self.fans_list_check = true;


        self.friends_btn:setFile("friends/btn_normal.png");
        self.att_btn:setFile("friends/btn_normal.png");
        self.fans_btn:setFile("friends/rankingbtn_press.png");

        self.friends:setVisible(true);
        self.friends_press:setVisible(false);
        self.attention:setVisible(true); 
        self.attention_press:setVisible(false);
        self.fans:setVisible(false);
        self.fans_press:setVisible(true);

        
        self.m_FriendsView:setVisible(false);
        self.m_AttentionView:setVisible(false);
        self.m_FansView:setVisible(true);

        self.friends_newadd_num.setColor(self.friends_newadd_num,80,190,130);
        self.fans_newadd_num.setColor(self.fans_newadd_num,125,70,30);

        
        local datas = self:requestCtrlCmd(FriendsController.s_cmds.ongetfanslist);
        if not datas or #datas < 1 then 
            ChessToastManager.getInstance():show("暂无粉丝！",500);
        end

        FriendsScene.itemType = 3;
        self:updateFans_list();

        self:exitNewTile1();
        self:updateNewNum();
    end
end

FriendsScene.exitNewTile1 = function(self)

    local datas1 = FriendsData.getInstance():getFrendsListData();

    if datas1 then
        for i,v_uid in pairs(datas1) do
            if FriendsData.getInstance():isNewFriends(v_uid) == 1 then
                FriendsData.getInstance():setIsNewFriends(v_uid,0);
            end
        end
    end

end

FriendsScene.exitNewTile2 = function(self)

    local datas2 = FriendsData.getInstance():getFansListData();
    if datas2 then
        for i,v_uid in pairs(datas2) do
            if FriendsData.getInstance():isNewFans(v_uid) == 1 then
                FriendsData.getInstance():setIsNewFans(v_uid,0);
            end
        end
    end

end

-----------------排行榜--------------------------------
FriendsScene.onRankingFriendsBtnClick = function(self)  --切换好友榜
    Log.d("FriendsScene.onRankingFriendsBtnClick");

    if self.friendslist_check == false then
        self.friendslist_check = true;
        self.charmlistlist_check = false;
        self.masterlist_check = false;
    
        self.m_FriendslistView:setVisible(true);
        self.m_CharmlistView:setVisible(false);
        self.m_MasterlistView:setVisible(false);

        self.friendslist_btn:setFile("friends/rankingbtn_press.png");
        self.charmlist_btn:setFile("friends/btn_normal.png");
        self.masterlist_btn:setFile("friends/btn_normal.png");

        self.friendslist:setVisible(false);
        self.friendslist_press:setVisible(true);
        self.charmlist:setVisible(true); 
        self.charmlist_press:setVisible(false);
        self.masterlist:setVisible(true);
        self.masterlist_press:setVisible(false);

        self:loadingTileExit();
        self:loadingTile("搜索好友榜信息");
        
        FriendsScene.itemPaiHangType = 1;
        self:requestCtrlCmd(FriendsController.s_cmds.change_friends);
    end

end


FriendsScene.onRankingCharmBtnClick = function(self)  --切换魅力榜
    Log.d("FriendsScene.onRankingCharmBtnClick");

    if self.charmlistlist_check == false then
        self.friendslist_check = false;
        self.charmlistlist_check = true;
        self.masterlist_check = false;
        
        self.m_FriendslistView:setVisible(false);
        self.m_CharmlistView:setVisible(true);
        self.m_MasterlistView:setVisible(false);

       
        self.charmlist_btn:setFile("friends/rankingbtn_press.png");
        self.masterlist_btn:setFile("friends/btn_normal.png");
        self.friendslist_btn:setFile("friends/btn_normal.png");
        self.friendslist:setVisible(true);
        self.friendslist_press:setVisible(false);
        self.charmlist:setVisible(false); 
        self.charmlist_press:setVisible(true);
        self.masterlist:setVisible(true);
        self.masterlist_press:setVisible(false);

        self:loadingTileExit();
        self:loadingTile("搜索魅力榜信息");
        
        FriendsScene.itemPaiHangType = 2;
        self:requestCtrlCmd(FriendsController.s_cmds.change_charm);
    end
    
end

FriendsScene.onRankingMasterBtnClick = function(self)  --切换大师榜
    Log.d("FriendsScene.onRankingMasterBtnClick");

    if self.masterlist_check == false then
        self.friendslist_check = false;
        self.charmlistlist_check = false;
        self.masterlist_check = true;
    
        self.m_FriendslistView:setVisible(false);
        self.m_CharmlistView:setVisible(false);
        self.m_MasterlistView:setVisible(true);

        self.masterlist_btn:setFile("friends/rankingbtn_press.png");
        self.charmlist_btn:setFile("friends/btn_normal.png");
        self.friendslist_btn:setFile("friends/btn_normal.png");
        self.friendslist:setVisible(true);
        self.friendslist_press:setVisible(false);
        self.charmlist:setVisible(true); 
        self.charmlist_press:setVisible(false);
        self.masterlist:setVisible(false);
        self.masterlist_press:setVisible(true);

        self:loadingTileExit();
        self:loadingTile("搜索大师榜信息");
       
        FriendsScene.itemPaiHangType = 3;
        self:requestCtrlCmd(FriendsController.s_cmds.change_master);

    end

end



----------------------------------- config ------------------------------------------------------------
FriendsScene.s_controlConfig = 
{
	[FriendsScene.s_controls.friends_back_btn] = {"friends_title_view","friends_back_btn"};--返回
	[FriendsScene.s_controls.friends_add_btn] = {"friends_title_view","friends_add_btn"};--添加

	[FriendsScene.s_controls.friends_btn] = {"friends_list_view","friends_menu_bg","friends_btn"}; --好友 好友列表
	[FriendsScene.s_controls.att_btn] = {"friends_list_view","friends_menu_bg","att_btn"};-- 好友 好友关注
	[FriendsScene.s_controls.fans_btn] = {"friends_list_view","friends_menu_bg","fans_btn"};--好友 好友粉丝

    [FriendsScene.s_controls.friends] = {"friends_list_view","friends_menu_bg","friends_btn","friends"}; 
    [FriendsScene.s_controls.friends_press] = {"friends_list_view","friends_menu_bg","friends_btn","friends_press"}; 

	[FriendsScene.s_controls.attention] = {"friends_list_view","friends_menu_bg","att_btn","attention"};
    [FriendsScene.s_controls.attention_press] = {"friends_list_view","friends_menu_bg","att_btn","attention_press"};

    [FriendsScene.s_controls.fans] = {"friends_list_view","friends_menu_bg","fans_btn","fans"};
	[FriendsScene.s_controls.fans_press] = {"friends_list_view","friends_menu_bg","fans_btn","fans_press"};


    [FriendsScene.s_controls.friendslist_btn] = {"ranking_list_view","friendsranking_menu_bg","friendslist_btn"};-- 排行榜 好友榜
	[FriendsScene.s_controls.charmlist_btn] = {"ranking_list_view","friendsranking_menu_bg","charmlist_btn"};--  排行榜 魅力榜
	[FriendsScene.s_controls.masterlist_btn] = {"ranking_list_view","friendsranking_menu_bg","masterlist_btn"};-- 排行榜 大师榜


    [FriendsScene.s_controls.friends_list] = {"friends_list_view","friends_list"};
    [FriendsScene.s_controls.fans_list] = {"friends_list_view","fans_list"};
    [FriendsScene.s_controls.attention_list] = {"friends_list_view","attention_list"};

    [FriendsScene.s_controls.friendsnum] = {"friends_list_view","friends_list","friends_num"};
    [FriendsScene.s_controls.fansnum] = {"friends_list_view","fans_list","fans_num"};
    [FriendsScene.s_controls.follownum] = {"friends_list_view","attention_list","follow_num"};
    

    [FriendsScene.s_controls.friends_newadd_num] = {"friends_list_view","friends_menu_bg","friends_btn","friends_newadd_num"};--新增好友数量
    [FriendsScene.s_controls.fans_newadd_num] = {"friends_list_view","friends_menu_bg","fans_btn","fans_newadd_num"};--新增粉丝数量


    [FriendsScene.s_controls.friendslist_view] = {"ranking_list_view","friendslist_view"};-- 好友榜view
    [FriendsScene.s_controls.charmlist_view] = {"ranking_list_view","charmlist_view"};-- 魅力榜view
    [FriendsScene.s_controls.masterlist_view] = {"ranking_list_view","masterlist_view"};-- 大师榜view


    [FriendsScene.s_controls.friendslist] = {"ranking_list_view","friendsranking_menu_bg","friendslist_btn","friendslist"};
	[FriendsScene.s_controls.friendslist_press] = {"ranking_list_view","friendsranking_menu_bg","friendslist_btn","friendslist_press"};

	[FriendsScene.s_controls.masterlist] = {"ranking_list_view","friendsranking_menu_bg","masterlist_btn","masterlist"};
    [FriendsScene.s_controls.masterlist_press] = {"ranking_list_view","friendsranking_menu_bg","masterlist_btn","masterlist_press"};

	[FriendsScene.s_controls.charmlist] = {"ranking_list_view","friendsranking_menu_bg","charmlist_btn","charmlist"};
	[FriendsScene.s_controls.charmlist_press] = {"ranking_list_view","friendsranking_menu_bg","charmlist_btn","charmlist_press"};

    [FriendsScene.s_controls.addtile] = {"friends_title_view","friends_add_btn","addtile"};
    [FriendsScene.s_controls.newnum] = {"friends_title_view","friends_add_btn","addtile","newnum"};--好友推荐
    
    --我的排名
    [FriendsScene.s_controls.my_rank_frame]  = {"ranking_list_view","my_rank_bg","icon_frame"};
    [FriendsScene.s_controls.my_rank_name]   = {"ranking_list_view","my_rank_bg","name"};
    [FriendsScene.s_controls.my_rank_points] = {"ranking_list_view","my_rank_bg","num"};
    [FriendsScene.s_controls.my_rank_pos]    = {"ranking_list_view","my_rank_bg","rank_icon","my_rank_text"};

};

FriendsScene.s_controlFuncMap =
{
	[FriendsScene.s_controls.friends_back_btn] = FriendsScene.onFriendsBackBtnClick;
    [FriendsScene.s_controls.friends_add_btn] = FriendsScene.onFriendsAddBtnClick;
    --好友
    [FriendsScene.s_controls.friends_btn] = FriendsScene.onFriendsBtnClick;
    [FriendsScene.s_controls.att_btn] = FriendsScene.onFriendsattBtnClick;
    [FriendsScene.s_controls.fans_btn] = FriendsScene.onFriendsfansBtnClick;
    --排行榜
    [FriendsScene.s_controls.friendslist_btn] = FriendsScene.onRankingFriendsBtnClick;
    [FriendsScene.s_controls.charmlist_btn] = FriendsScene.onRankingCharmBtnClick;
    [FriendsScene.s_controls.masterlist_btn] = FriendsScene.onRankingMasterBtnClick;
};


FriendsScene.s_cmdConfig =
{
    [FriendsScene.s_cmds.changeState] = FriendsScene.changeState;
    [FriendsScene.s_cmds.changeFriendsList] = FriendsScene.changeFriendsListCall;
    [FriendsScene.s_cmds.changeFollowList] = FriendsScene.changeFollowListCall;
    [FriendsScene.s_cmds.changeFansList] = FriendsScene.changeFansListCall;
    [FriendsScene.s_cmds.changeFriendsData] = FriendsScene.changeDataCall;
    [FriendsScene.s_cmds.changeFriendstatus] = FriendsScene.changeStatusCall;  
    [FriendsScene.s_cmds.change_charm] = FriendsScene.changeCharmCall;  
    [FriendsScene.s_cmds.change_master] = FriendsScene.changeMasterCall;   
    [FriendsScene.s_cmds.change_friends] = FriendsScene.changeFriendsCall;  
    [FriendsScene.s_cmds.change_userIcon] = FriendsScene.changeUserIconCall;

    [FriendsScene.s_cmds.newfriendsNum] = FriendsScene.changeNewfriendsNumCall;

    [FriendsScene.s_cmds.friends_num] = FriendsScene.changeFriendsNumCall;
    [FriendsScene.s_cmds.follow_num] = FriendsScene.changeFollowNumCall;
    [FriendsScene.s_cmds.fans_num] = FriendsScene.changeFansNumCall;
    
    [FriendsScene.s_cmds.my_friend_rank] = FriendsScene.updataMyRank;
    [FriendsScene.s_cmds.my_charm_rank] = FriendsScene.updataMyRank;
    [FriendsScene.s_cmds.my_master_rank] = FriendsScene.updataMyRank;
}

-------------------------------- private node --------------------------------------------------------
FriendsItem = class(Node)
FriendsItem.s_w = 450;
FriendsItem.s_h = 120;


FriendsItem.idToIcon = UserInfo.DEFAULT_ICON;

FriendsItem.ctor = function(self,dataid)
    self.m_data = dataid;
    if not dataid then return ; end
  
    self.datas = FriendsData.getInstance():getUserData(dataid);
    self.status = FriendsData.getInstance():getUserStatus(dataid);

    self:setSize(FriendsItem.s_w,FriendsItem.s_h);

    self.m_bg = new(Button,"friends/friends_new_item_bg.png");
    self.m_bg:setAlign(kAlignCenter);
    self.m_bg:setOnClick(self,self.onBtnClick);
    self.m_bg:setSrollOnClick();
    self:addChild(self.m_bg);
   
    --头像
    local iconFile = FriendsItem.idToIcon[1];
    

    self.m_icon_bg = new(Image,"friends/friend_icon_frame.png");
    self.m_icon_bg:setAlign(kAlignLeft);
    self.m_icon_bg:setPos(20,-5);
    self.m_bg:addChild(self.m_icon_bg);

    self.m_icon = new(Image,iconFile);

    if self.datas then
        if self.datas.iconType == -1 then
            self.m_icon:setUrlImage(self.datas.icon_url);
        else
            iconFile = FriendsItem.idToIcon[self.datas.iconType] or iconFile;
            self.m_icon:setFile(iconFile);
        end
    end

    self.m_icon:setAlign(kAlignCenter);
    self.m_icon:setSize(64,64);
    self.m_icon_bg:addChild(self.m_icon);
    --段位
    self.m_level = new(Image,"userinfo/1.png");
    self.m_level:setAlign(kAlignBottomRight);
    self.m_level:setPos(-8,-10);
    self.m_icon:addChild(self.m_level);

    --新好友，粉丝
    self.new = new(Image,"friends/newfriends.png");
    self.new:setAlign(kAlignLeft);
    self.new:setPos(-10,-35);
    self.m_icon:addChild(self.new);

    _,bg_posY = self.m_bg:getSize();
    local sx = 35 + self.m_icon:getSize();  
    local sy = -20;


    --最近登录
    self.m_lasttimeTitle = new(Text,"最近登陆:",nil, nil, nil, nil, 20, 100, 100, 100);
    self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 20, 100, 100, 100); 

    --名字
    self.m_title = new(Text,dataid,nil, nil, nil, nil, 28, 70, 25, 0);
    self.m_title:setAlign(kAlignLeft);
    self.m_title:setPos(sx,sy);
    --积分
    self.m_contentTextTitle = new(Text,"积分:",nil, nil, nil, nil, 20, 160, 100, 50);
    self.m_contentText = new(Text,0,nil, nil, nil, nil, 20, 160, 100, 50);
    self.m_contentTextTitle:setAlign(kAlignLeft);
    self.m_contentText:setAlign(kAlignLeft);

    sy = sy + 35;
    self.m_contentTextTitle:setPos(sx,sy);
    sx = sx + self.m_contentTextTitle:getSize();
    self.m_contentText:setPos(sx,sy);


    --a and b -- 如果a 为false，则返回a，否则返回b
    --a or b -- 如果a 为true，则返回a，否则返回b
    if FriendsScene.itemType ~= 2 then
        if FriendsData.getInstance():isNewFriends(dataid) == 1 or FriendsData.getInstance():isNewFans(dataid) == 1 then --判断是否新好友or粉丝标签
            self.new:setVisible(true);
        else
            self.new:setVisible(false);
        end
    else
        self.new:setVisible(false);
    end


    if self.datas ~= nil then
        if self.status ~= nil then
            self.last_login_time = FriendsScene.getTime(tonumber(self.datas.mactivetime)) or "";
            if self.status.hallid <=0 then --离线
                if self.datas.mnick then
                    local lenth = string.lenutf8(GameString.convert2UTF8(self.datas.mnick));
                    if lenth > 10 then    
                        local str  = string.subutf8(self.datas.mnick,1,7).."...";
                        self.m_title.setText(self.m_title,str,nil,nil,100,100,100);
                    else
                        self.m_title.setText(self.m_title,self.datas.mnick,nil,nil,100,100,100);
                    end
                else
                    self.m_title.setText(self.m_title,dataid,nil,nil,100,100,100);
                end
                
                self.m_icon:setGray(true);
                self.m_contentTextTitle.setText(self.m_contentTextTitle,"积分:",nil, nil,100,100,100);
                self.m_contentText.setText(self.m_contentText,self.datas.score,nil, nil,100,100,100);  
                if self.last_login_time and self.last_login_time ~= "" then
                    self.m_lasttimeTitle.setText(self.m_lasttimeTitle,"最近登陆:",nil, nil,100,100,100);
                    self.m_lasttimeTitleNum.setText(self.m_lasttimeTitleNum,self.last_login_time,nil, nil,100,100,100);
                else
                    self.m_lasttimeTitle.setText(self.m_lasttimeTitle,"",nil, nil,100,100,100);
                    self.m_lasttimeTitleNum.setText(self.m_lasttimeTitleNum,"",nil, nil,100,100,100);
                end
                self.m_level:setFile("userinfo/"..UserInfo.getInstance():getDanGradingLevelByScore(tonumber(self.datas.score))..".png");   
                
                self.m_lasttimeTitle:setPos(110,0);
                self.m_lasttimeTitleNum:setPos(185,0);        
            else -- 在线
                if RoomConfig.getInstance():isPlaying(self.status) then -- 用户在下棋
                    local strname = RoomConfig.getInstance():onGetScreenings(self.status);
                    self.m_lasttimeTitleNum:setVisible(false);
                    if strname == nil then
                        self.m_lasttimeTitle.setText(self.m_lasttimeTitle,"在线",nil, nil,160,100,50);
                        self.m_lasttimeTitle:setPos(190,0);
                    else
                        self.m_lasttimeTitle.setText(self.m_lasttimeTitle,strname,nil, nil,160,100,50);
                        self.m_lasttimeTitle:setPos(175,0);
                    end
                else
                    self.m_lasttimeTitle.setText(self.m_lasttimeTitle,"在线",nil, nil,160,100,50);
                    self.m_lasttimeTitleNum:setVisible(false);
                    self.m_lasttimeTitle:setPos(190,0);
                end

                if self.datas.mnick then
                    local lenth = string.lenutf8(GameString.convert2UTF8(self.datas.mnick));
                    if lenth > 10 then    
                        local str  = string.subutf8(self.datas.mnick,1,7).."...";
                        self.m_title.setText(self.m_title,str,nil,nil,70,25,0);
                    else
                        self.m_title.setText(self.m_title,self.datas.mnick,nil,nil,70,25,0);
                    end
                else
                    self.m_title.setText(self.m_title,dataid,nil,nil,70,25,0);
                end
                
                self.m_icon:setGray(false);
                self.m_contentTextTitle.setText(self.m_contentTextTitle,"积分:",nil, nil,160,100,50);
                self.m_contentText.setText(self.m_contentText,self.datas.score,nil, nil,160,100,50);  
                self.m_level:setFile("userinfo/"..UserInfo.getInstance():getDanGradingLevelByScore(tonumber(self.datas.score))..".png"); 

            end
        else
            
            if self.datas.mnick then
                local lenth = string.lenutf8(GameString.convert2UTF8(self.datas.mnick));
                if lenth > 10 then    
                    local str  = string.subutf8(self.datas.mnick,1,7).."...";
                    self.m_title.setText(self.m_title,str,nil,nil,100,100,100);
                else
                    self.m_title.setText(self.m_title,self.datas.mnick,nil,nil,100,100,100);    
                end
            else
                self.m_title.setText(self.m_title,dataid,nil,nil,100,100,100);
            end
            
            self.m_icon:setGray(true);
            self.m_contentTextTitle.setText(self.m_contentTextTitle,"积分:",nil, nil,100,100,100);
            self.m_contentText.setText(self.m_contentText,self.datas.score,nil, nil,100,100,100);  
            self.m_lasttimeTitle.setText(self.m_lasttimeTitle,"",nil, nil,100,100,100);
            self.m_lasttimeTitleNum.setText(self.m_lasttimeTitleNum,"",nil, nil,100,100,100);
            self.m_level:setFile("userinfo/"..UserInfo.getInstance():getDanGradingLevelByScore(tonumber(self.datas.score))..".png");  
            self.m_lasttimeTitle:setPos(110,0);
            self.m_lasttimeTitleNum:setPos(185,0);
        end
    else
        if self.status ~= nil then
            --local time = FriendsScene.getTime(self.status.last_time);
            if self.status.hallid <=0 then --离线
                self.m_icon:setGray(true);
                self.m_title.setText(self.m_title,dataid,nil,nil,100,100,100);
                self.m_contentTextTitle.setText(self.m_contentTextTitle,"积分:",nil, nil,100,100,100);
                self.m_contentText.setText(self.m_contentText,0,nil, nil,100,100,100);  
                self.m_lasttimeTitle.setText(self.m_lasttimeTitle,"",nil, nil,100,100,100);
                self.m_lasttimeTitleNum.setText(self.m_lasttimeTitleNum,"",nil, nil,100,100,100);  
                self.m_lasttimeTitle:setPos(110,0);
                self.m_lasttimeTitleNum:setPos(185,0);         
            else -- 在线
                self.m_icon:setGray(false);
                self.m_title.setText(self.m_title,dataid,nil,nil,70,25,0);
                self.m_contentTextTitle.setText(self.m_contentTextTitle,"积分:",nil, nil,160,100,50);
                self.m_contentText.setText(self.m_contentText,0,nil, nil,160,100,50);  
                self.m_lasttimeTitleNum:setVisible(false);
                
                if RoomConfig.getInstance():isPlaying(self.status) then -- 用户在下棋
                    local strname = RoomConfig.getInstance():onGetScreenings(self.status);
                    if strname == nil then
                        self.m_lasttimeTitle.setText(self.m_lasttimeTitle,"在线",nil, nil,160,100,50);
                        self.m_lasttimeTitle:setPos(190,0);
                    else
                        self.m_lasttimeTitle.setText(self.m_lasttimeTitle,strname,nil, nil,160,100,50);
                        self.m_lasttimeTitle:setPos(175,0);
                    end
                else
                    self.m_lasttimeTitle.setText(self.m_lasttimeTitle,"在线",nil, nil,160,100,50);
                    self.m_lasttimeTitle:setPos(190,0);
                end               
            end
        else
            self.m_icon:setGray(true);
            self.m_title.setText(self.m_title,dataid,nil,nil,100,100,100);
            self.m_contentTextTitle.setText(self.m_contentTextTitle,"积分:",nil, nil,100,100,100);
            self.m_contentText.setText(self.m_contentText,0,nil, nil,100,100,100);  
            self.m_lasttimeTitle.setText(self.m_lasttimeTitle,"",nil, nil,100,100,100);
            self.m_lasttimeTitleNum.setText(self.m_lasttimeTitleNum,"",nil, nil,100,100,100);

            self.m_lasttimeTitle:setPos(110,0);
            self.m_lasttimeTitleNum:setPos(185,0); 
        end
    end

    self.m_lasttimeTitle:setAlign(kAlignCenter);
    self.m_lasttimeTitleNum:setAlign(kAlignCenter);

    self.m_bg:addChild(self.m_lasttimeTitle);
    self.m_bg:addChild(self.m_lasttimeTitleNum);
    self.m_bg:addChild(self.m_title);
    self.m_bg:addChild(self.m_contentTextTitle);
    self.m_bg:addChild(self.m_contentText);

end

FriendsItem.setOnBtnClick = function(self,obj,func)
    self.m_btn_obj = obj;
    self.m_btn_func = func;
end

FriendsItem.onBtnClick = function(self)
    Log.d("FriendsItem.onBtnClick");
    StateMachine.getInstance():pushState(States.FriendsInfo,StateMachine.STYPE_CUSTOM_WAIT,nil,tonumber(self.m_data));
end

FriendsItem.updateUserIcon = function(self,imageName)
    Log.i("FriendsItem.updateUserIcon: "..(imageName or "null"));
    if imageName then
        self.m_icon:setFile(imageName);
    end
end

------------------------------------魅力榜
RankCharmsItem = class(Node)
RankCharmsItem.s_w = 450;
RankCharmsItem.s_h = 120;

RankCharmsItem.ctor = function(self,data)

    if next(data) == nil then   
        return;
    end

    self.datas = data;
    self.status = FriendsData.getInstance():getUserStatus(self.datas.mid);
    self:setSize(RankCharmsItem.s_w,RankCharmsItem.s_h);
    self.m_bg = new(Button,"friends/module_bg.png");
    self.m_bg:setAlign(kAlignCenter);
    self.m_bg:setOnClick(self,self.onBtnClick);
    self.m_bg:setSrollOnClick();
    self:addChild(self.m_bg);

    --头像
    local iconFile = FriendsItem.idToIcon[1];
    self.m_icon_bg = new(Image,"friends/friend_icon_frame.png");
    self.m_icon_bg:setAlign(kAlignLeft);
    self.m_icon_bg:setPos(60,3);
    self.m_bg:addChild(self.m_icon_bg);

    self.m_icon = new(Image,iconFile);
    if self.datas then
        if self.datas.iconType == -1 then
            self.m_icon:setUrlImage(self.datas.icon_url);
        else
            iconFile = FriendsItem.idToIcon[self.datas.iconType] or iconFile;
            self.m_icon:setFile(iconFile);
        end
    end
    self.m_icon:setAlign(kAlignCenter);
    self.m_icon:setSize(64,64);
    self.m_icon_bg:addChild(self.m_icon);
    --段位
    self.m_level = new(Image,"userinfo/1.png");
    self.m_level:setAlign(kAlignBottomRight);
    self.m_level:setPos(-8,-10);
    self.m_icon:addChild(self.m_level);
    self.m_level:setFile("userinfo/"..UserInfo.getInstance():getDanGradingLevelByScore(tonumber(self.datas.score))..".png"); 

    local sx = 75 + self.m_icon:getSize(); 
    local sy = 30 ;

    --名字
    if self.datas.mnick then
        local lenth = string.lenutf8(GameString.convert2UTF8(self.datas.mnick));
        if lenth > 10 then    
            local str  = string.subutf8(self.datas.mnick,1,7).."...";
            self.m_title = new(Text,str,nil, nil, nil, nil,28,250,230,180);
        else
            self.m_title = new(Text,self.datas.mnick,nil, nil, nil, nil,28,250,230,180);   
        end
    else
        self.m_title = new(Text,"未知",nil, nil, nil, nil,28,250,230,180);
    end

    self.m_title:setAlign(kAlignLeft);
    self.m_title:setPos(sx,sy - 40);
    self.m_bg:addChild(self.m_title);

    --粉丝
    if self.datas.score ~= nil then
        local fs = "粉丝:"..self.datas.fans_num.."";
        self.m_fs = new(Text,fs,nil, nil, nil, nil, 20,185,155,110);
    else
        self.m_fs = new(Text,0,nil, nil, nil, nil, 20,185,155,110);
    end
    self.m_fs:setAlign(kAlignLeft);
    self.m_fs:setPos(sx,sy - 10);
    self.m_bg:addChild(self.m_fs);


    --最近登录
    if self.status~= nil then
        if self.status.hallid <=0 then --离线
           self.last_login_time = FriendsScene.getTime(self.datas.mactivetime);
           self.m_lasttimeTitleNum = new(Text,self.last_login_time,nil, nil, nil, nil, 20, 70, 145, 105); 
           self.m_lasttimeTitle = new(Text,"最近登陆:",nil, nil, nil, nil, 20, 70, 145, 105);
           self.m_lasttimeTitle:setPos(110,0);
           self.m_lasttimeTitleNum:setPos(185,0);
        else
            if RoomConfig.getInstance():isPlaying(self.status) then -- 用户在下棋
                local strname = RoomConfig.getInstance():onGetScreenings(self.status);
                self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105); 
                self.m_lasttimeTitleNum:setVisible(false);
                self.m_lasttimeTitle = new(Text,"在线",nil, nil, nil, nil, 20, 70, 145, 105);
                if strname == nil then
                       self.m_lasttimeTitle.setText(self.m_lasttimeTitle,"在线",nil, nil,70,145,105);
                       self.m_lasttimeTitle:setPos(185,0);
                else
                       self.m_lasttimeTitle.setText(self.m_lasttimeTitle,strname,nil, nil,70,145,105);
                       self.m_lasttimeTitle:setPos(180,0);
                end           
           else
                self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105); 
                self.m_lasttimeTitle = new(Text,"在线",nil, nil, nil, nil, 20, 70, 145, 105);
                self.m_lasttimeTitle:setPos(185,0);
           end
           
        end
    else
        self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105); 
        self.m_lasttimeTitle = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105);
        self.m_lasttimeTitle:setPos(110,0);
        self.m_lasttimeTitleNum:setPos(185,0);
    end


    ---名次图标
    if self.datas.rank ~= nil then
        local img_rank =  nil;
	    if self.datas.rank  < 4 and self.datas.rank > 0 then 
		    img_rank = new(Image,string.format("friends/rank_medal%d.png",self.datas.rank));
	    else
		    img_rank = new(Image,"friends/medal_bg.png");
		    local text_rank =  new(Text,self.datas.rank,nil, nil, nil, nil, 24, 70, 145, 105);
            text_rank:setAlign(kAlignCenter);
		    img_rank:addChild(text_rank);
	    end
        img_rank:setPos(sx - 125,sy + 5);
        self.m_bg:addChild(img_rank);
    else
        local img_rank = new(Image,"friends/medal_bg.png");
        local text_rank =  new(Text,1,nil, nil, nil, nil, 24, 70, 145, 105);
        text_rank:setAlign(kAlignCenter);
        img_rank:addChild(text_rank);
        img_rank:setPos(sx - 125,sy + 5);
        self.m_bg:addChild(img_rank);
    end

    self.m_lasttimeTitle:setAlign(kAlignCenter);
    self.m_lasttimeTitleNum:setAlign(kAlignCenter);
    self.m_bg:addChild(self.m_lasttimeTitle);
    self.m_bg:addChild(self.m_lasttimeTitleNum);

end

RankCharmsItem.setOnBtnClick = function(self,obj,func)
    self.m_btn_obj = obj;
    self.m_btn_func = func;
end

RankCharmsItem.onBtnClick = function(self)
    Log.i("RankCharmsItem.onBtnClick");
    StateMachine.getInstance():pushState(States.FriendsInfo,StateMachine.STYPE_CUSTOM_WAIT,nil,tonumber(self.datas.mid));
end

RankCharmsItem.updateUserIcon = function(self,imageName)
    Log.i("FriendsItem.updateUserIcon: "..(imageName or "null"));
    if imageName then
        self.m_icon:setFile(imageName);
    end
end


RankCharmsItem.changeStatus = function(self)
    
    self.status = FriendsData.getInstance():getUserStatus(self.datas.mid);

    --最近登录
    if self.status~= nil then
        if self.status.hallid <=0 then --离线
           if self.last_login_time and self.last_login_time ~= "" then
               self.m_lasttimeTitleNum = new(Text,self.last_login_time,nil, nil, nil, nil, 20, 70, 145, 105); 
               self.m_lasttimeTitle = new(Text,"最近登陆:",nil, nil, nil, nil, 20, 70, 145, 105);
           else
               self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105); 
               self.m_lasttimeTitle = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105);
           end
        else
            if RoomConfig.getInstance():isPlaying(self.status) then -- 用户在下棋
                local strname = RoomConfig.getInstance():onGetScreenings(self.status);
                self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105); 
                self.m_lasttimeTitleNum:setVisible(false);
                self.m_lasttimeTitle = new(Text,"在线",nil, nil, nil, nil, 20, 70, 145, 105);
                if strname == nil then
                       self.m_lasttimeTitle.setText(self.m_lasttimeTitle,"",nil, nil,70,145,105);
                else
                       self.m_lasttimeTitle.setText(self.m_lasttimeTitle,strname,nil, nil,70,145,105);
                end            
           else
                self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105); 
                self.m_lasttimeTitleNum:setVisible(false);
                self.m_lasttimeTitle = new(Text,"在线",nil, nil, nil, nil, 20, 70, 145, 105);
           end
        end
    else
        self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105); 
        self.m_lasttimeTitle = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105);
    end


end


-------------------------------------------大师榜
RankMasterItem = class(Node)
RankMasterItem.s_w = 450;
RankMasterItem.s_h = 120;

RankMasterItem.ctor = function(self,data)

    if next(data) == nil then   
        return;
    end

    self.datas = data;
    self.status = FriendsData.getInstance():getUserStatus(self.datas.mid);
    self:setSize(RankMasterItem.s_w,RankMasterItem.s_h);
    self.m_bg = new(Button,"friends/module_bg.png");
    self.m_bg:setAlign(kAlignCenter);
    self.m_bg:setOnClick(self,self.onBtnClick);
    self.m_bg:setSrollOnClick();
    self:addChild(self.m_bg);

    --头像
    local iconFile = FriendsItem.idToIcon[1];
    self.m_icon_bg = new(Image,"friends/friend_icon_frame.png");
    self.m_icon_bg:setAlign(kAlignLeft);
    self.m_icon_bg:setPos(60,3);
    self.m_bg:addChild(self.m_icon_bg);

    self.m_icon = new(Image,iconFile);
    if self.datas then
        if self.datas.iconType == -1 then
            self.m_icon:setUrlImage(self.datas.icon_url);
        else
            iconFile = FriendsItem.idToIcon[self.datas.iconType] or iconFile;
            self.m_icon:setFile(iconFile);
        end
    end
    self.m_icon:setAlign(kAlignCenter);
    self.m_icon:setSize(64,64);
    self.m_icon_bg:addChild(self.m_icon);
    --段位
    self.m_level = new(Image,"userinfo/1.png");
    self.m_level:setAlign(kAlignBottomRight);
    self.m_level:setPos(-8,-10);
    self.m_icon:addChild(self.m_level);

    if self.datas.score ~= nil then
        self.m_level:setFile("userinfo/"..UserInfo.getInstance():getDanGradingLevelByScore(tonumber(self.datas.score))..".png"); 
    else
        self.m_level:setFile("userinfo/1.png");
    end

    local sx = 75 + self.m_icon:getSize(); 
    local sy = 30 ;

    --名字
    if self.datas.name and #self.datas.name > 1 then
        local lenth = string.lenutf8(GameString.convert2UTF8(self.datas.name) or "");
        if lenth > 10 then    
            local str  = string.subutf8(self.datas.name,1,7).."...";
            self.m_title = new(Text,str,nil, nil, nil, nil,28,250,230,180);
        else
            self.m_title = new(Text,self.datas.name,nil, nil, nil, nil,28,250,230,180);   
        end
    else
        self.m_title = new(Text,"未知",nil, nil, nil, nil,28,250,230,180);
    end

    self.m_title:setAlign(kAlignLeft);
    self.m_title:setPos(sx,sy - 40);
    self.m_bg:addChild(self.m_title);

    --积分
    if self.datas.score ~= nil then
        local fs = "积分："..self.datas.score.."";
        self.m_fs = new(Text,fs,nil, nil, nil, nil, 20,185,155,110);
    else
        self.m_fs = new(Text,0,nil, nil, nil, nil, 20,185,155,110);
    end
    self.m_fs:setAlign(kAlignLeft);
    self.m_fs:setPos(sx,sy - 10);
    self.m_bg:addChild(self.m_fs);


    --最近登录
    if self.status~= nil then
        if self.status.hallid <=0 then --离线
           self.last_login_time = FriendsScene.getTime(self.datas.mactivetime);
           self.m_lasttimeTitleNum = new(Text,self.last_login_time,nil, nil, nil, nil, 20, 70, 145, 105); 
           self.m_lasttimeTitle = new(Text,"最近登陆:",nil, nil, nil, nil, 20, 70, 145, 105);
           self.m_lasttimeTitle:setPos(110,0);
           self.m_lasttimeTitleNum:setPos(185,0);
        else
            if RoomConfig.getInstance():isPlaying(self.status) then -- 用户在下棋
                local strname = RoomConfig.getInstance():onGetScreenings(self.status);
                self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105); 
                self.m_lasttimeTitleNum:setVisible(false);
                self.m_lasttimeTitle = new(Text,"在线",nil, nil, nil, nil, 20, 70, 145, 105);
                if strname == nil then
                       self.m_lasttimeTitle.setText(self.m_lasttimeTitle,"",nil, nil,70,145,105);
                       self.m_lasttimeTitle:setPos(185,0);
                else
                       self.m_lasttimeTitle.setText(self.m_lasttimeTitle,strname,nil, nil,70,145,105);
                       self.m_lasttimeTitle:setPos(180,0);
                end            
           else
                self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105); 
                self.m_lasttimeTitleNum:setVisible(false);
                self.m_lasttimeTitle = new(Text,"在线",nil, nil, nil, nil, 20, 70, 145, 105);
                self.m_lasttimeTitle:setPos(185,0);
           end           
        end
    else
        self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105); 
        self.m_lasttimeTitle = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105);
        self.m_lasttimeTitle:setPos(110,0);
        self.m_lasttimeTitleNum:setPos(185,0);
    end


    ---名次图标
    if self.datas.rank ~= nil then
        local img_rank =  nil;
	    if self.datas.rank  < 4 and self.datas.rank > 0 then 
		    img_rank = new(Image,string.format("friends/rank_medal%d.png",self.datas.rank));
	    else
		    img_rank = new(Image,"friends/medal_bg.png");
		    local text_rank =  new(Text,self.datas.rank,nil, nil, nil, nil, 24, 70, 145, 105);
            text_rank:setAlign(kAlignCenter);
		    img_rank:addChild(text_rank);
	    end
        img_rank:setPos(sx - 125,sy + 5);
        self.m_bg:addChild(img_rank);
    else
        local img_rank = new(Image,"friends/medal_bg.png");
        local text_rank =  new(Text,1,nil, nil, nil, nil, 24, 70, 145, 105);
        text_rank:setAlign(kAlignCenter);
        img_rank:addChild(text_rank);
        img_rank:setPos(sx - 125,sy + 5);
        self.m_bg:addChild(img_rank);
    end

    self.m_lasttimeTitle:setAlign(kAlignCenter);
    self.m_lasttimeTitleNum:setAlign(kAlignCenter);
    self.m_bg:addChild(self.m_lasttimeTitle);
    self.m_bg:addChild(self.m_lasttimeTitleNum);

end

RankMasterItem.setOnBtnClick = function(self,obj,func)
    self.m_btn_obj = obj;
    self.m_btn_func = func;
end

RankMasterItem.onBtnClick = function(self)
    Log.i("RankMasterItem.onBtnClick");
    StateMachine.getInstance():pushState(States.FriendsInfo,StateMachine.STYPE_CUSTOM_WAIT,nil,tonumber(self.datas.mid));
end

RankMasterItem.updateUserIcon = function(self,imageName)
    Log.i("FriendsItem.updateUserIcon: "..(imageName or "null"));
    if imageName then
        self.m_icon:setFile(imageName);
    end
end

RankMasterItem.changeStatus = function(self)
    
    self.status = FriendsData.getInstance():getUserStatus(self.datas.mid);
    --最近登录
    if self.status~= nil then
        if self.status.hallid <=0 then --离线
           if self.last_login_time and self.last_login_time ~= "" then
               self.m_lasttimeTitleNum = new(Text,self.last_login_time,nil, nil, nil, nil, 20, 70, 145, 105); 
               self.m_lasttimeTitle = new(Text,"最近登陆:",nil, nil, nil, nil, 20, 70, 145, 105);
           else
               self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105); 
               self.m_lasttimeTitle = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105);
           end
        else
            if RoomConfig.getInstance():isPlaying(self.status) then -- 用户在下棋
                local strname = RoomConfig.getInstance():onGetScreenings(self.status);
                self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105); 
                self.m_lasttimeTitleNum:setVisible(false);
                self.m_lasttimeTitle = new(Text,"在线",nil, nil, nil, nil, 20, 70, 145, 105);
                if strname == nil then
                       self.m_lasttimeTitle.setText(self.m_lasttimeTitle,"",nil, nil,70,145,105);
                else
                       self.m_lasttimeTitle.setText(self.m_lasttimeTitle,strname,nil, nil,70,145,105);
                end            
           else
                self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105); 
                self.m_lasttimeTitleNum:setVisible(false);
                self.m_lasttimeTitle = new(Text,"在线",nil, nil, nil, nil, 20, 70, 145, 105);
           end
        end
    else
        self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105); 
        self.m_lasttimeTitle = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105);
    end

end

--------------------------------------好友榜
RankFriendsItem = class(Node)
RankFriendsItem.s_w = 450;
RankFriendsItem.s_h = 120;

RankFriendsItem.ctor = function(self,data)

    if next(data) == nil then   
        return;
    end

    self.uid = data.mid;
    self.score = data.score;
    self.datas = FriendsData.getInstance():getUserData(data.mid);
    self.status = FriendsData.getInstance():getUserStatus(data.mid);

    self:setSize(RankFriendsItem.s_w,RankFriendsItem.s_h);
    self.m_bg = new(Button,"friends/module_bg.png");
    self.m_bg:setAlign(kAlignCenter);
    self.m_bg:setOnClick(self,self.onBtnClick);
    self.m_bg:setSrollOnClick();
    self:addChild(self.m_bg);

    self.m_icon_bg = new(Image,"friends/friend_icon_frame.png");
    self.m_icon_bg:setAlign(kAlignLeft);
    self.m_icon_bg:setPos(60,3);
    self.m_bg:addChild(self.m_icon_bg);

    --头像
    self.m_icon = new(Image,"userinfo/userHead.png");
    self.m_icon:setAlign(kAlignCenter);
    self.m_icon:setSize(64,64);
    self.m_icon_bg:addChild(self.m_icon);

    --段位
    self.m_level = new(Image,"userinfo/1.png");
    self.m_level:setAlign(kAlignBottomRight);
    self.m_level:setPos(-8,-10);
    self.m_icon:addChild(self.m_level);

    local sx = 75 + self.m_icon:getSize(); 
    local sy = 30 ;
    

    if self.datas~= nil then
        --头像
        local iconFile = FriendsItem.idToIcon[1];

        if self.uid == UserInfo.getInstance():getUid() then
            if UserInfo.getInstance():getIconType() == -1 then
                self.m_icon:setUrlImage(UserInfo.getInstance():getIcon());
            else
                self.m_icon:setFile(UserInfo.DEFAULT_ICON[UserInfo.getInstance():getIconType()] or UserInfo.DEFAULT_ICON[1]);
            end
        else
            self.m_icon:setFile(iconFile);
        end

        if self.datas.score ~= nil then
            self.m_level:setFile("userinfo/"..UserInfo.getInstance():getDanGradingLevelByScore(tonumber(self.datas.score))..".png"); 
        else
            self.m_level:setFile("userinfo/1.png");
        end 

        --名字
        if self.datas.mnick then
            local lenth = string.lenutf8(GameString.convert2UTF8(self.datas.mnick));
            if lenth > 10 then    
                local str  = string.subutf8(self.datas.mnick,1,7).."...";
                self.m_title = new(Text,str,nil, nil, nil, nil,28,250,230,180);
            else
                self.m_title = new(Text,self.datas.mnick,nil, nil, nil, nil,28,250,230,180);   
            end
        else
            self.m_title = new(Text,"未知",nil, nil, nil, nil,28,250,230,180);
        end

        self.m_title:setAlign(kAlignLeft);
        self.m_title:setPos(sx,sy - 40);
        self.m_bg:addChild(self.m_title);

        --积分
        local fs = "积分："..self.score.."";
        self.m_fs = new(Text,fs,nil, nil, nil, nil, 20,185,155,110);
        self.m_fs:setAlign(kAlignLeft);
        self.m_fs:setPos(sx,sy - 10);
        self.m_bg:addChild(self.m_fs);

        --最近登录
        if self.status~= nil then
            if self.status.hallid <=0 then --离线
               self.last_login_time = FriendsScene.getTime(self.datas.mactivetime);
               self.m_lasttimeTitleNum = new(Text,self.last_login_time,nil, nil, nil, nil, 20, 70, 145, 105); 
               self.m_lasttimeTitle = new(Text,"最近登陆:",nil, nil, nil, nil, 20, 70, 145, 105);
               self.m_lasttimeTitle:setPos(110,0);
               self.m_lasttimeTitleNum:setPos(185,0);
            else
                if RoomConfig.getInstance():isPlaying(self.status) then -- 用户在下棋
                    local strname = RoomConfig.getInstance():onGetScreenings(self.status);
                    self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105); 
                    self.m_lasttimeTitleNum:setVisible(false);
                    self.m_lasttimeTitle = new(Text,"在线",nil, nil, nil, nil, 20, 70, 145, 105);
                    if strname == nil then
                           self.m_lasttimeTitle.setText(self.m_lasttimeTitle,"",nil, nil,70,145,105);
                           self.m_lasttimeTitle:setPos(185,0);
                    else
                           self.m_lasttimeTitle.setText(self.m_lasttimeTitle,strname,nil, nil,70,145,105);
                           self.m_lasttimeTitle:setPos(180,0);
                    end            
               else
                    self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105); 
                    self.m_lasttimeTitleNum:setVisible(false);
                    self.m_lasttimeTitle = new(Text,"在线",nil, nil, nil, nil, 20, 70, 145, 105);
                    self.m_lasttimeTitle:setPos(185,0);
               end
            end
        else
            self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105); 
            self.m_lasttimeTitle = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105);
            self.m_lasttimeTitle:setPos(110,0);
            self.m_lasttimeTitleNum:setPos(185,0);
        end
    
        ---名次图标
        if FriendsScene.paiHangRank ~= nil then
            for _,sdata in pairs(FriendsScene.paiHangRank) do
               if self.uid == sdata.mid then

                    if sdata.rank  < 4 and sdata.rank > 0 then 
		                self.img_rank = new(Image,string.format("friends/rank_medal%d.png",sdata.rank));
	                else
		                self.img_rank = new(Image,"friends/medal_bg.png");
		                self.text_rank =  new(Text,sdata.rank,nil, nil, nil, nil, 24, 70, 145, 105);
                        self.text_rank:setAlign(kAlignCenter);
		                self.img_rank:addChild(self.text_rank);
	                end
                        self.img_rank:setPos(sx - 125,sy + 5);
                        self.m_bg:addChild(self.img_rank);
                  break;
               end
            end
        else
            self.img_rank = new(Image,"friends/medal_bg.png");
            self.text_rank =  new(Text,1,nil, nil, nil, nil, 24, 70, 145, 105);
            self.text_rank:setAlign(kAlignCenter);
            self.img_rank:addChild(self.text_rank);
            self.img_rank:setPos(sx - 125,sy + 5);
            self.m_bg:addChild(self.img_rank);
        end

    else

        if data.rank ~= nil then
	    if data.rank  < 4 and data.rank > 0 then 
		    self.img_rank = new(Image,string.format("friends/rank_medal%d.png",data.rank));
	    else
		    self.img_rank = new(Image,"friends/medal_bg.png");
		    self.text_rank =  new(Text,data.rank,nil, nil, nil, nil, 24, 70, 145, 105);
            self.text_rank:setAlign(kAlignCenter);
		    self.img_rank:addChild(self.text_rank);
	    end
        self.img_rank:setPos(sx - 125,sy + 5);
        self.m_bg:addChild(self.img_rank);
        else
        self.img_rank = new(Image,"friends/medal_bg.png");
        self.text_rank =  new(Text,1,nil, nil, nil, nil, 24, 70, 145, 105);
        self.text_rank:setAlign(kAlignCenter);
        self.img_rank:addChild(self.text_rank);
        self.img_rank:setPos(sx - 125,sy + 5);
        self.m_bg:addChild(self.img_rank);
        end


        self.m_title = new(Text,"未知",nil, nil, nil, nil,28,250,230,180);
        self.m_fs = new(Text,"积分：",nil, nil, nil, nil, 20,185,155,110);
        self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105);
        self.m_lasttimeTitle = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105);

        self.m_title:setAlign(kAlignLeft);
        self.m_title:setPos(sx,sy - 40);
        self.m_bg:addChild(self.m_title);
        self.m_fs:setAlign(kAlignLeft);
        self.m_fs:setPos(sx,sy - 10);
        self.m_bg:addChild(self.m_fs);
        

        self.m_lasttimeTitle:setPos(110,0);
        self.m_lasttimeTitleNum:setPos(185,0);
    end

        self.m_lasttimeTitle:setAlign(kAlignCenter);
        self.m_lasttimeTitleNum:setAlign(kAlignCenter);
        self.m_bg:addChild(self.m_lasttimeTitle);
        self.m_bg:addChild(self.m_lasttimeTitleNum);

end

RankFriendsItem.setOnBtnClick = function(self,obj,func)
    self.m_btn_obj = obj;
    self.m_btn_func = func;
end

RankFriendsItem.onBtnClick = function(self)
    --FriendsInfoController.friendsID = self.datas.uid;
    Log.i("RankFriendsItem.onBtnClick");
    StateMachine.getInstance():pushState(States.FriendsInfo,StateMachine.STYPE_CUSTOM_WAIT,nil,tonumber(self.uid));
end

RankFriendsItem.updateUserIcon = function(self,imageName)
    Log.i("FriendsItem.updateUserIcon: "..(imageName or "null"));
--    if imageName then
--        if self.uid == UserInfo.getInstance():getUid() then
--            self.m_icon:setFile(UserInfo.getInstance():getIconFile());
--        else
--            self.m_icon:setFile(imageName);
--        end
--    end
  
end

RankFriendsItem.changeStatus = function(self)

    self.status = FriendsData.getInstance():getUserStatus(self.uid);

    --最近登录
    if self.status~= nil then
        if self.status.hallid <=0 then --离线
           if self.last_login_time and self.last_login_time ~= "" then
               self.m_lasttimeTitleNum = new(Text,self.last_login_time,nil, nil, nil, nil, 20, 70, 145, 105); 
               self.m_lasttimeTitle = new(Text,"最近登陆:",nil, nil, nil, nil, 20, 70, 145, 105);
           else
               self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105); 
               self.m_lasttimeTitle = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105)
           end
        else
            if RoomConfig.getInstance():isPlaying(self.status) then -- 用户在下棋
                local strname = RoomConfig.getInstance():onGetScreenings(self.status);
                self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105); 
                self.m_lasttimeTitleNum:setVisible(false);
                self.m_lasttimeTitle = new(Text,"在线",nil, nil, nil, nil, 20, 70, 145, 105);
                if strname == nil then
                       self.m_lasttimeTitle.setText(self.m_lasttimeTitle,"",nil, nil,70,145,105);
                else
                       self.m_lasttimeTitle.setText(self.m_lasttimeTitle,strname,nil, nil,70,145,105);
                end            
           else
                self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105); 
                self.m_lasttimeTitleNum:setVisible(false);
                self.m_lasttimeTitle = new(Text,"在线",nil, nil, nil, nil, 20, 70, 145, 105);
           end
        end
    else
        self.m_lasttimeTitleNum = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105); 
        self.m_lasttimeTitle = new(Text,"",nil, nil, nil, nil, 20, 70, 145, 105);
    end

end